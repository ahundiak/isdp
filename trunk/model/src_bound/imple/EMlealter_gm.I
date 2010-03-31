/* ###################   APOGEE COMPILED   ################## */
/*
    gupta : 05/09/88 : Creation
*/

class implementation EMSlinedge;

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

from EMSloop import EMset_props;

method EMalter_geometry (IGRlong               *EMmsg;
                         struct EMSsfintedpar  *inters;
                         IGRboolean            end_truncated)

{
  IGRlong               stat_OM, msg;
  IGRint                i;
  IGRboolean            end_to_truncate;
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

  if (end_to_truncate)
   {
    ME.EMSlinedge->num_points = inters->edgepar.span_inx + 2;
    ME.EMSlinedge->points[2 * ME.EMSlinedge->num_points - 2] = 
                                                 inters->point[0];
    ME.EMSlinedge->points[2 * ME.EMSlinedge->num_points - 1] = 
                                                 inters->point[1];
   }
  else
   {
    ME.EMSlinedge->num_points -= inters->edgepar.span_inx;
    ME.EMSlinedge->points[0] =  inters->point[0];
    ME.EMSlinedge->points[1] =  inters->point[1];
   
    for (i=2; i<(2*ME.EMSlinedge->num_points); i++)
     {
      ME.EMSlinedge->points[i] = ME.EMSlinedge->points[2 *
                                   (inters->edgepar.span_inx) + i];
     }
   }
  
  if (ME.EMSedge->ed_props & EMED_XYZ_CLOSED)
      ME.EMSedge->ed_props &= ~EMED_XYZ_CLOSED;

  if (! (ME.EMSedge->ed_props & EMED_OPEN))
      ME.EMSedge->ed_props |= EMED_OPEN;

  stat_OM = EMsend_loops(&msg, message EMSloop.EMset_props (&msg,
                               EMLP_OPEN, EMS_O_ON), my_id, 0,
                               OM_K_MAXINT, EMLP_ACTIVE, NULL, NULL);
  EMerr_hndlr (! (1 & stat_OM & msg), *EMmsg, EMS_E_LoopError, wrapup);

wrapup:

  EMWRAPUP (*EMmsg, stat_OM, "EMSlinedge.EMalter_geometry");
  return (stat_OM);
}

end implementation EMSlinedge;
