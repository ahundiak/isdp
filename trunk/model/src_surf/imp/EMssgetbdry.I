/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsubbs;

/* HISTORY:

Long Ago:  ??  Creation
08/26/92:  NP  Modified for ANSI compliance. Changed type of variable "has_loopset"
	       to IGRuint.
*/


#include "EMS.h"
#include "emsdef.h"
#include "EMSopt.h"
#include "OMmacros.h"

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

from EMSloopset import EMlsgetbdry;

method EMssgetbdry (IGRlong *msg;
                    IGRshort *mattyp; IGRmatrix mat;
                    IGRushort options;
                    IGRint *numbdrys;
                    struct IGRpolyline **xyzbdrys, **uvbdrys;
                    IGRdouble **lpranges; IGRushort **lpprops;
                    GRobjid **lpids)
{
  IGRboolean in_world = TRUE;
  IGRint stat_OM, dum;
  IGRuint has_loopset;
  IGRlong msg_loc;
  struct IGRbsp_surface *srfgeom;
  struct EMSpartolbasis partolbas;
  struct GRmdenv_info mdenv_info;
  struct GRid my_grid;
  OM_S_CHANSELECT chan_to_loopset;
  extern IGRint EMgetvggeom();
  
  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  srfgeom = NULL;

  EMmake_chanselect (EMSsubbs_to_loopset, &chan_to_loopset);
  stat_OM = om$get_channel_count (object = me, p_chanselect = &chan_to_loopset,
             count = &has_loopset);
  EMomerr_exit (stat_OM, ret_end);

  if (!has_loopset)
    {
    /*
     * This surface has no loopset. The boundary has to be obtained
     * using a dummy loopset attached to this surface.
     */

    mdenv_info.matrix_type = *mattyp;
    OM_BLOCK_MOVE (mat, mdenv_info.matrix, sizeof (IGRmatrix));
    stat_OM = om$send (msg = message EMSsurface.EMmk_nat_bdry (&msg_loc,
               &mdenv_info, NULL), targetid = my_id);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_SurfaceError,
     ret_end);
    }

  my_grid.objid = my_id;
  my_grid.osnum = OM_Gw_current_OS;
  stat_OM = EMgetvggeom (&msg_loc, mattyp, mat, &my_grid, &srfgeom, NULL);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

  stat_OM = om$send (msg = message EMSsubbs.EMpartolbasis (&msg_loc,
             mattyp, mat, &in_world, FALSE, &partolbas.tol),
             targetid = my_id);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_SurfaceError,
   ret_end);
  partolbas.is_valid = TRUE;

  stat_OM = om$send (msg = message EMSloopset.EMlsgetbdry (&msg_loc, 
             mattyp, mat, srfgeom, &partolbas, options, numbdrys,
             xyzbdrys, uvbdrys, lpranges, lpprops, lpids),
             p_chanselect = &chan_to_loopset);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_LoopsetError,
   ret_end);

  if (!has_loopset)
    {
    /*
     * This surface had no loopset. The dummy loopset may now be
     * deleted.
     */

    stat_OM = om$send (msg = message Root.delete (TRUE),
               p_chanselect = &chan_to_loopset);
    EMomerr_exit (stat_OM, ret_end);
    }

ret_end:
  if (srfgeom)
    om$dealloc (ptr = srfgeom);

  EMWRAPUP (*msg, stat_OM, "EMSsubbs.EMssgetbdry");
  return (stat_OM);
}

end implementation EMSsubbs;
