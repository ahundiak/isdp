/* ###################   APOGEE COMPILED   ################## */
class implementation EMSedittree;

#include "EMS.h"
#include "msdef.h" /* MS message codes */
#include "emsdef.h"
#ifdef DEBUG
#include "stdio.h"
#endif

method GRdisyourself(IGRlong *EMmsg; IGRshort *mx_type; 
                     IGRmatrix matrix;  enum GRdpmode *mode;
                     struct IGRaltdisplay *alt_symb; 
                     struct DP_information *sp_info; 
                     OM_p_KEY_DESC range_key)
{
  IGRlong           OM_stat=OM_S_SUCCESS;

#ifdef DEBUG
  fprintf(stderr,"EMetdisplay - disyourselfing node %d\n",
          ME.EMSedittree->node_id); 
#endif

  *EMmsg = MSSUCC;

  OM_stat = om$send(msg = message GRgraphics.GRdisyourself(EMmsg, mx_type, 
                          matrix, mode, alt_symb, sp_info, range_key), 
                    targetid = ME.EMSedittree->node_id,
                    targetos = ME.EMSedittree->node_os);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;                    

  wrapup:
    EMWRAPUP (*EMmsg, OM_stat, "EMSedittree.GRdisyourself");
    return(OM_stat);
}
end implementation EMSedittree;
