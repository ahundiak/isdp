/* ###################   APOGEE COMPILED   ################## */
/*
    gupta : 05/06/88 : Creation
*/

class implementation EMSbsedge;

#include "EMS.h"
#include "emsdef.h"
#include "emserr.h"
#include "emsdattyp.h"
#include "emsinterdef.h"
#include "emsinter.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "EMSmsgdef.h"
#include "emsmacros.h"
#include "emssfint.h"
#include "emsedgedef.h"

from EMSloop import EMset_props;

method EMalter_geometry (IGRlong               *EMmsg;
                         struct EMSsfintedpar  *inters;
                         IGRboolean            end_truncated)

{
  IGRlong               stat_OM, msg;
  IGRboolean            end_to_truncate;
  struct IGRbsp_curve   edgeom;
  struct EMSpartedinfo  partinfo;
  IGRint                EMsend_loops();

/*--------------------------------------------------------------------*/

  *EMmsg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  end_to_truncate = end_truncated;

  if (ME.EMSedge->ed_props & EMED_REVERSED)
   {
    if (end_truncated) end_to_truncate = FALSE;
    else if (! end_truncated) end_to_truncate = TRUE;
   }

  partinfo.edprops = NULL;
  partinfo.edtype = EMfreeform_curve;
  edgeom.poles = NULL;
  edgeom.knots = NULL;
  edgeom.weights = NULL;

  if (end_to_truncate)
   {     
    partinfo.edbdry[0].span_inx = 0;
    partinfo.edbdry[0].param = 0.0;
    partinfo.edbdry[1].span_inx = inters->edgepar.span_inx;
    partinfo.edbdry[1].param = inters->edgepar.param;
   }
  else
   {      
    partinfo.edbdry[0].span_inx = inters->edgepar.span_inx;
    partinfo.edbdry[0].param = inters->edgepar.param;
    partinfo.edbdry[1].span_inx = 0;
    partinfo.edbdry[1].param = 1.0;
   }

  stat_OM = om$send (msg = message EMSedge.EMgetbcgeom (&msg, 0,
                           MAXINT, 
                    (ME.EMSedge->ed_props & EMED_REVERSED) ? TRUE : FALSE,
                           &partinfo, &edgeom, NULL, NULL), 
                     targetid = my_id); 
  EMerr_hndlr (! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError,wrapup);

  stat_OM = om$send (msg = message EMSedge.EMputbcgeom (&msg, 0,
                           FALSE, &edgeom),
                     targetid = my_id); 
  EMerr_hndlr (! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError,wrapup);

  if (ME.EMSedge->ed_props & EMED_XYZ_CLOSED)
      ME.EMSedge->ed_props &= ~EMED_XYZ_CLOSED;

  if (! (ME.EMSedge->ed_props & EMED_OPEN))
      ME.EMSedge->ed_props |= EMED_OPEN;

  stat_OM = EMsend_loops(&msg, message EMSloop.EMset_props (&msg,
                               EMLP_OPEN, EMS_O_ON), my_id, 0,
                               OM_K_MAXINT, EMLP_ACTIVE, NULL, NULL);
  EMerr_hndlr (! (1 & stat_OM & msg), *EMmsg, EMS_E_LoopError, wrapup);

wrapup:

  if (edgeom.poles) om$dealloc (ptr = edgeom.poles);
  if (edgeom.knots) om$dealloc (ptr = edgeom.knots);
  if (edgeom.weights) om$dealloc (ptr = edgeom.weights);

  EMWRAPUP (*EMmsg, stat_OM, "EMSbsedge.EMalter_geometry");
  return (stat_OM);
}

end implementation EMSbsedge;
