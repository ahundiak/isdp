/* ###################   APOGEE COMPILED   ################## */
class implementation EMSgradata;

# include "EMS.h"
# include "emsdef.h"
# include "EMSmsgdef.h"

method EMget_the_edges(IGRlong *EMmsg;
                       IGRshort         options;
                       IGRdouble       *z_vector;
                       struct GRmdenv_info *mdenv_info;
                       IGRint          *num_gralp_edges;
                       IGRint          *num_horiz_edges;
                       IGRint          *num_cusp_edges;                
                       struct GRid     **gralp_edges;
                       struct GRid     **horiz_edges;
                       struct GRid     **cusp_edges)

/*
History

    13 June 91 Jack Creation

Notes
    We don't want to get any edges on this class so just
    return success.    
*/
{
 *EMmsg = EMS_S_Success;

  return(OM_S_SUCCESS);
}

end implementation EMSgradata; 
