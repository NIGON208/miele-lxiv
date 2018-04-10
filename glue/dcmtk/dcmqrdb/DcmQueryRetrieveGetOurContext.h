/* Alex Bettarini - 12 May 2015
 */

#include "dcmtk/dcmqrdb/dcmqrcbg.h"

class DcmQueryRetrieveGetOurContext : public DcmQueryRetrieveGetContext
{
public:
    /** constructor
     *  @param handle reference to database handle
     *  @param options options for the Q/R service
     *  @param priorstatus prior DIMSE status
     *  @param origassoc pointer to DIMSE association
     *  @param origmsgid DIMSE message ID
     *  @param prior DIMSE priority
     *  @param origpresid presentation context ID
     */
    DcmQueryRetrieveGetOurContext(DcmQueryRetrieveDatabaseHandle& handle,
                               const DcmQueryRetrieveOptions& options,
                               DIC_US priorstatus,
                               T_ASC_Association *origassoc,
                               DIC_US origmsgid,
                               T_DIMSE_Priority prior,
                               T_ASC_PresentationContextID origpresid);

    virtual void getNextImage(DcmQueryRetrieveDatabaseStatus * dbStatus);
    
private:
    
};
