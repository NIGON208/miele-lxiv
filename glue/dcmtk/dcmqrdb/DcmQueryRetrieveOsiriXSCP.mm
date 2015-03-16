/* Alex Bettarini - 12 Mar 2015
 */

#include <stdio.h>
#import "browserController.h"
#import "AppController.h"
#import "DicomDatabase.h"

#include "osconfig.h"    /* make sure OS specific configuration is included first */
#include "dcmqrsrv.h"
#include "dcmqropt.h"
#include "dcfilefo.h"
#include "dcmqrdba.h"
#include "dcmqrcbf.h"    /* for class DcmQueryRetrieveFindContext */
#include "dcmqrcbm.h"    /* for class DcmQueryRetrieveMoveContext */
#include "dcmqrcbg.h"    /* for class DcmQueryRetrieveGetContext */
#include "dcmqrcbs.h"    /* for class DcmQueryRetrieveStoreContext */
#include "dcmetinf.h"
#include "dul.h"
#import "dcmqrdbq.h"
#include "dcdeftag.h"

#include "DcmQueryRetrieveOsiriXSCP.h"
#import "dimse.h"

BOOL forkedProcess = NO;

static char *last(char *p, int c)
{
    char *t;              /* temporary variable */
    
    if ((t = strrchr(p, c)) != NULL) return t + 1;
    
    return p;
}

// See DIMSE_StoreProviderCallback in dimse.h
static void storeCallback(/* in */
                          void *callbackData,
                          T_DIMSE_StoreProgress *progress,  /* progress state */
                          T_DIMSE_C_StoreRQ *req,           /* original store request */
                          char *imageFileName,              /* being received into */
                          DcmDataset **imageDataSet,        /* being received into */
                          /* out */
                          T_DIMSE_C_StoreRSP *rsp,          /* final store response */
                          DcmDataset **stDetail)
{
    DcmQueryRetrieveStoreContext *context = OFstatic_cast(DcmQueryRetrieveStoreContext *, callbackData);
    context->callbackHandler(progress,
                             req,
                             imageFileName,
                             imageDataSet,
                             rsp,
                             stDetail);
}

#pragma mark - class DcmQueryRetrieveOsiriXSCP

// Line 362
DcmQueryRetrieveOsiriXSCP::DcmQueryRetrieveOsiriXSCP(
                                                     const DcmQueryRetrieveConfig& config,
                                                     const DcmQueryRetrieveOptions& options,
                                                     const DcmQueryRetrieveDatabaseHandleFactory& factory)
: DcmQueryRetrieveSCP(config, options, factory)
{
    index=0;
}

void DcmQueryRetrieveOsiriXSCP::writeErrorMessage( const char *str)
{
    if( options_.singleProcess_)
    {
        if( str)
            [[AppController sharedAppController] performSelectorOnMainThread: @selector(displayListenerError:) withObject: [NSString stringWithUTF8String: str] waitUntilDone: NO];
    }
    else
    {
        char dir[ 1024];
        sprintf( dir, "%s", "/tmp/error_message");
        unlink( dir);
        
        FILE * pFile = fopen (dir,"w+");
        if( pFile)
        {
            fprintf( pFile, "%s", str);
            fclose (pFile);
        }
    }
}

OFCondition DcmQueryRetrieveOsiriXSCP::handleAssociation(T_ASC_Association * assoc, OFBool correctUIDPadding)
{
    index = 0;
    return DcmQueryRetrieveSCP::handleAssociation(assoc, correctUIDPadding);
}

OFCondition DcmQueryRetrieveOsiriXSCP::storeSCP(
                                                T_ASC_Association * assoc,
                                                T_DIMSE_C_StoreRQ * request,
                                                T_ASC_PresentationContextID presId,
                                                DcmQueryRetrieveDatabaseHandle& dbHandle,
                                                OFBool correctUIDPadding)
{
    OFCondition cond = EC_Normal;
    OFCondition dbcond = EC_Normal;
    char imageFileName[MAXPATHLEN+1];
    DcmFileFormat dcmff;
    
    //DCM_dcmqrdbLogger.isEnabledFor(OFLogger::WARN_LOG_LEVEL);
    if ([[NSUserDefaults standardUserDefaults] boolForKey: @"verbose_dcmtkStoreScu"])
    {
#ifndef NDEBUG
        OFLog::configure(OFLogger::DEBUG_LOG_LEVEL);
#else
        OFLog::configure(OFLogger::INFO_LOG_LEVEL);
#endif
    }
    else
    {
        OFLog::configure(OFLogger::ERROR_LOG_LEVEL);        
    }
    
    DcmQueryRetrieveStoreContext context(dbHandle, options_, STATUS_Success, &dcmff, correctUIDPadding);
    
    OFString temp_str;
    DCMQRDB_INFO("Received Store SCP:" << OFendl << DIMSE_dumpMessage(temp_str, *request, DIMSE_INCOMING));
    
    if (!dcmIsaStorageSOPClassUID(request->AffectedSOPClassUID)) {
        /* callback will send back sop class not supported status */
        context.setStatus(STATUS_STORE_Refused_SOPClassNotSupported);
        /* must still receive data */
        strcpy(imageFileName, NULL_DEVICE_NAME);
    } else if (options_.ignoreStoreData_) {
        strcpy(imageFileName, NULL_DEVICE_NAME);
    } else {
        dbcond = dbHandle.makeNewStoreFileName(
                                               request->AffectedSOPClassUID,
                                               request->AffectedSOPInstanceUID,
                                               imageFileName);
        
        if (dbcond.bad())
        {
            DCMQRDB_ERROR("storeSCP: Database: makeNewStoreFileName Failed");
            /* must still receive data */
            strcpy(imageFileName, NULL_DEVICE_NAME);
            /* callback will send back out of resources status */
            context.setStatus(STATUS_STORE_Refused_OutOfResources);
        }
    }
    
    FILE * pFile = fopen ("/tmp/kill_all_storescu", "r");
    if( pFile)
    {
        fclose (pFile);
        cond = ASC_abortAssociation(assoc);
    }
    
#ifdef LOCK_IMAGE_FILES
    /* exclusively lock image file */
#ifdef O_BINARY
    int lockfd = open(imageFileName, (O_WRONLY | O_CREAT | O_TRUNC | O_BINARY), 0666);
#else
    int lockfd = open(imageFileName, (O_WRONLY | O_CREAT | O_TRUNC), 0666);
#endif
    if (lockfd < 0)
    {
        DCMQRDB_ERROR("storeSCP: file locking failed, cannot create file");
        
        /* must still receive data */
        strcpy(imageFileName, NULL_DEVICE_NAME);
        
        /* callback will send back out of resources status */
        context.setStatus(STATUS_STORE_Refused_OutOfResources);
    }
    else
        dcmtk_flock(lockfd, LOCK_EX);
#endif
    
    context.setFileName(imageFileName);
    
    // store SourceApplicationEntityTitle in metaheader
    if (assoc && assoc->params)
    {
        const char *aet = assoc->params->DULparams.callingAPTitle;
        if (aet) dcmff.getMetaInfo()->putAndInsertString(DCM_SourceApplicationEntityTitle, aet);
    }
    
    DcmDataset *dset = dcmff.getDataset();
    
    /* we must still retrieve the data set even if some error has occured */
    
    if (options_.bitPreserving_)
    { /* the bypass option can be set on the command line */
        cond = DIMSE_storeProvider(assoc, presId, request,
                                   imageFileName, (int)options_.useMetaheader_,
                                   NULL,
                                   storeCallback,
                                   (void*)&context, options_.blockMode_, options_.dimse_timeout_);
    }
    else
    {
        cond = DIMSE_storeProvider(assoc, presId, request,
                                   (char *)NULL, (int)options_.useMetaheader_,
                                   &dset,
                                   storeCallback,
                                   (void*)&context, options_.blockMode_, options_.dimse_timeout_);
    }
    
    static_cast<DcmQueryRetrieveOsiriXDatabaseHandle *>(&dbHandle) -> updateLogEntry(dset);
    
    if (cond.bad())
    {
        DCMQRDB_ERROR("Store SCP Failed: " << DimseCondition::dump(temp_str, cond));
        writeErrorMessage( cond.text());
    }
    
    if (!options_.ignoreStoreData_ &&
        (cond.bad() || (context.getStatus() != STATUS_Success)))
    {
        /* remove file */
        if (strcmp(imageFileName, NULL_DEVICE_NAME) != 0) // don't try to delete /dev/null
        {
            DCMQRDB_INFO("Store SCP - status:" << context.getStatus()
                         << " Deleting Image File:" << imageFileName);
            unlink(imageFileName); // The file in TEMP.noindex is deleted
        }
        dbHandle.pruneInvalidRecords();
    }
    
#ifdef LOCK_IMAGE_FILES
    /* unlock image file */
    if (lockfd >= 0)
    {
        dcmtk_flock(lockfd, LOCK_UN);
        close(lockfd);
    }
#endif
    
    // Extra stuff for OsiriX:
    // It moves the retrieved file from TEMP to INCOMING
    
    if (strcmp(imageFileName, NULL_DEVICE_NAME) != 0)
    {
        char dir[ 1024];
        sprintf( dir, "%s/%s",
                [[BrowserController currentBrowser] cfixedIncomingNoIndexDirectory],
                last( imageFileName, '/'));
        rename( imageFileName, dir); // Moving the file from TEMP.noindex to INCOMING.noindex
        
        if( forkedProcess == NO && index == 0)
        {
            [[DicomDatabase activeLocalDatabase] initiateImportFilesFromIncomingDirUnlessAlreadyImporting];
        }
        
        index++;
    }
    
    return cond;
}

