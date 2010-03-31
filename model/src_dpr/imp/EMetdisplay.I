/* ###################   APOGEE COMPILED   ################## */
class implementation EMSedittree;

#include "EMS.h"
#include "msdef.h" /* MS message codes */
#include "emsdef.h"
#ifdef DEBUG
#include "stdio.h"
#endif

method GRdisplay(IGRlong *EMmsg;  
                 IGRshort *matrix_type; 
                 IGRmatrix matrix;
                 enum GRdpmode *mode; 
                 struct GRid *display_info)
{
  IGRlong           OM_stat=OM_S_SUCCESS;

#ifdef DEBUG
  fprintf(stderr,"EMetdisplay - displaying node %d\n",
          ME.EMSedittree->node_id); 
#endif

  *EMmsg = MSSUCC;

  OM_stat = om$send(msg = message GRgraphics.GRdisplay(EMmsg, matrix_type, 
                          matrix, mode, display_info),
                    targetid = ME.EMSedittree->node_id,
                    targetos = ME.EMSedittree->node_os);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;                    

  wrapup:
    EMWRAPUP (*EMmsg, OM_stat, "EMSedittree.GRdisplay");
    return(OM_stat);
}
end implementation EMSedittree;
