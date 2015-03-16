/* Alex Bettarini - 12 Mar 2015
 */

#include "dcmqrsrv.h"

class DcmQueryRetrieveOsiriXSCP : public DcmQueryRetrieveSCP
{
public:
    
    /** constructor
     *  @param config SCP configuration facility
     *  @param options SCP configuration options
     *  @param factory factory object used to create database handles
     */
    DcmQueryRetrieveOsiriXSCP(
                        const DcmQueryRetrieveConfig& config,
                        const DcmQueryRetrieveOptions& options,
                        const DcmQueryRetrieveDatabaseHandleFactory& factory);
    
    void writeErrorMessage( const char *str);
    OFCondition handleAssociation(T_ASC_Association * assoc, OFBool correctUIDPadding);

    OFCondition storeSCP(T_ASC_Association * assoc,
                         T_DIMSE_C_StoreRQ * req,
                         T_ASC_PresentationContextID presId,
                         DcmQueryRetrieveDatabaseHandle& dbHandle,
                         OFBool correctUIDPadding);
    
    //char imageFileName[MAXPATHLEN+1];

private:
    
    int index;
};
