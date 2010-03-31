/* ###################   APOGEE COMPILED   ################## */
/*
  DESCRIPTION

    Obtains the extents of the boundaries in parametric space
    of this surface. An array of 4 doubles is output containing
    umin, vmin, umax and vmax.
 
  HISTORY

    SS  :  03/16/90  :  Creation
    NP  :  08/26/92  :  Modified for ANSI compliance. Changed the type of variable 
			"count" to "IGRuint".
*/

class implementation EMSsubbs;

#define UMIN 0
#define VMIN 1
#define UMAX 2
#define VMAX 3

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

from EMSloopset import EMgetrange;

method EMgetuvrange (IGRlong *msg; IGRdouble *uvrange)
{
  IGRuint have_loopset;
  IGRlong msg_loc, stat_OM;
  OM_S_CHANSELECT chan_to_loopset;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  EMmake_chanselect (EMSsubbs_to_loopset, &chan_to_loopset);

  stat_OM = om$get_channel_count (object = me, p_chanselect = &chan_to_loopset,
             count = &have_loopset);
  EMomerr_exit (stat_OM, ret_end);

  if (have_loopset)
    {
    /* 
     * This surface has a loopset and therefore, the range is obtained
     * by querying the same.
     */

    stat_OM = om$send (msg = message EMSloopset.EMgetrange (&msg_loc,
               uvrange), p_chanselect = &chan_to_loopset);
    EMomerr_exit (stat_OM, ret_end);
    EMerr_hndlr (EMSerror (msg_loc), *msg, msg_loc, ret_end);
    }
  else
    {
    /*
     * Since the surface has no boundaries, the entire uv-domain
     * is included.
     */

    uvrange[UMIN] = 0.0;
    uvrange[VMIN] = 0.0;
    uvrange[UMAX] = 1.0;
    uvrange[VMAX] = 1.0;
    }

ret_end:
  EMWRAPUP (*msg, stat_OM, "EMSsubbs.EMgetuvrange");
  return (stat_OM);
  
}

end implementation EMSsubbs;
