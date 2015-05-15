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
#import "dimse.h"

#include "DcmQueryRetrieveOsiriSCP.h"
#include "DcmQueryRetrieveGetOsiriContext.h"

BOOL forkedProcess = NO;

static char *last(char *p, int c)
{
    char *t;              /* temporary variable */
    
    if ((t = strrchr(p, c)) != NULL) return t + 1;
    
    return p;
}

static void getCallback(
                        /* in */
                        void *callbackData,
                        OFBool cancelled, T_DIMSE_C_GetRQ *request,
                        DcmDataset *requestIdentifiers, int responseCount,
                        /* out */
                        T_DIMSE_C_GetRSP *response, DcmDataset **stDetail,
                        DcmDataset **responseIdentifiers)
{
#if 0
    DcmQueryRetrieveGetContext *context = OFstatic_cast(DcmQueryRetrieveGetContext *, callbackData);
#else
    DcmQueryRetrieveGetOsiriContext *context = OFstatic_cast(DcmQueryRetrieveGetOsiriContext *, callbackData);
#endif
    context->callbackHandler(cancelled, request, requestIdentifiers, responseCount, response, stDetail, responseIdentifiers);
    
#if 1 // @@@ TODO Issue #19
    if( forkedProcess == NO)
        [[NSThread currentThread] setProgress:1.0/
                                                 (response->NumberOfCompletedSubOperations+
                                                  response->NumberOfFailedSubOperations+
                                                  response->NumberOfWarningSubOperations+
                                                  response->NumberOfRemainingSubOperations)
                                                 *
                                                 (response->NumberOfCompletedSubOperations+
                                                  response->NumberOfFailedSubOperations+
                                                  response->NumberOfWarningSubOperations)];
#endif
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

#pragma mark - class DcmQueryRetrieveOsiriSCP

// Line 362
DcmQueryRetrieveOsiriSCP::DcmQueryRetrieveOsiriSCP(
                                                     const DcmQueryRetrieveConfig& config,
                                                     const DcmQueryRetrieveOptions& options,
                                                     const DcmQueryRetrieveDatabaseHandleFactory& factory)
: DcmQueryRetrieveSCP(config, options, factory)
{
    index=0;
//    DCM_dcmdataLogger.setLogLevel(OFLogger::WARN_LOG_LEVEL);
//    DCM_dcmqrdbLogger.setLogLevel(OFLogger::WARN_LOG_LEVEL);
}

void DcmQueryRetrieveOsiriSCP::writeErrorMessage( const char *str)
{
    if( options_.singleProcess_)
    {
        if( str)
            [[AppController sharedAppController] performSelectorOnMainThread: @selector(displayListenerError:)
                                                                  withObject: [NSString stringWithUTF8String: str]
                                                               waitUntilDone: NO];
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

OFCondition DcmQueryRetrieveOsiriSCP::handleAssociation(T_ASC_Association * assoc, OFBool correctUIDPadding)
{
    index = 0;
    return DcmQueryRetrieveSCP::handleAssociation(assoc, correctUIDPadding);
}

OFCondition DcmQueryRetrieveOsiriSCP::getSCP(T_ASC_Association * assoc,
                                             T_DIMSE_C_GetRQ * request,
                                             T_ASC_PresentationContextID presID,
                                             DcmQueryRetrieveDatabaseHandle& dbHandle)
{
    OFCondition cond = EC_Normal;

#if 1
    DcmQueryRetrieveGetOsiriContext context(dbHandle, options_, STATUS_Pending, assoc, request->MessageID, request->Priority, presID);
#else
    DcmQueryRetrieveGetContext context(dbHandle, options_, STATUS_Pending, assoc, request->MessageID, request->Priority, presID);
#endif
    
    DIC_AE aeTitle;
    aeTitle[0] = '\0';
    ASC_getAPTitles(assoc->params, NULL, aeTitle, NULL);
    context.setOurAETitle(aeTitle);
    
    OFString temp_str;
    DCMQRDB_INFO("Received Get SCP:" << OFendl << DIMSE_dumpMessage(temp_str, *request, DIMSE_INCOMING));
    
    cond = DIMSE_getProvider(assoc, presID, request,
                             getCallback, &context, options_.blockMode_, options_.dimse_timeout_);
    if (cond.bad()) {
        DCMQRDB_ERROR("Get SCP Failed: " << DimseCondition::dump(temp_str, cond));
    }
    return cond;
}

OFCondition DcmQueryRetrieveOsiriSCP::storeSCP(
                                                T_ASC_Association * assoc,
                                                T_DIMSE_C_StoreRQ * request,
                                                T_ASC_PresentationContextID presId,
                                                DcmQueryRetrieveDatabaseHandle& dbHandle,
                                                OFBool correctUIDPadding)
{
#if 0
    // TODO: call base class instead of repeating this block of code (need to resolve imageFileName)
    DcmQueryRetrieveSCP::storeSCP(assoc,request,presId,dbHandle,correctUIDPadding);
#else
    OFCondition cond = EC_Normal;
    OFCondition dbcond = EC_Normal;
    char imageFileName[MAXPATHLEN+1];
    DcmFileFormat dcmff;

    if ([[NSUserDefaults standardUserDefaults] boolForKey: @"verbose_dcmtkStoreScu"])
    {
#ifndef NDEBUG
        OFLog::configure(OFLogger::DEBUG_LOG_LEVEL);
        //DCM_dcmdataLogger.setLogLevel(OFLogger::DEBUG_LOG_LEVEL);
        //DCM_dcmqrdbLogger.setLogLevel(OFLogger::DEBUG_LOG_LEVEL);
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
        /* callback will send back SOP class not supported status */
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
    
#if 1
    FILE * pFile = fopen ("/tmp/kill_all_storescu", "r");
    if( pFile)
    {
        fclose (pFile);
        cond = ASC_abortAssociation(assoc);
    }
#endif
    
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
    
#if 1
    static_cast<DcmQueryRetrieveOsiriXDatabaseHandle *>(&dbHandle) -> updateLogEntry(dset);
#endif

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

