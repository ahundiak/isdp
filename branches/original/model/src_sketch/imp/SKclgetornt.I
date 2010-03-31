class implementation SKcollinear;

#include <values.h>

#define FIRST	0
#define SECOND  1
#define MIDDLE	1
#define LAST    2

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

method SKgetrelornt (IGRlong *msg; struct SKsolvevars *solvedvars;
                     IGRdouble *angto_firstseg; GRobjid ptobjs[2][2])
{
  OMuint count;
  IGRlong stat_OM;
  OM_S_CHANSELECT chan_to_pts;
  OM_S_OBJECT_LINKAGE objlist[3];

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  if (ptobjs)
    {
    EMmake_chanselect (SKconstraint_to_variables, &chan_to_pts);
    count = 0;
    om$get_channel_objects (object = me, p_chanselect = &chan_to_pts,
     size = 3, count = &count, list = objlist);
    EMerr_hndlr (count != 3, *msg, EMS_E_InvalidCase, ret_end);

    ptobjs[FIRST][FIRST] = objlist[MIDDLE].S_objid;
    ptobjs[FIRST][SECOND] = objlist[LAST].S_objid;
    ptobjs[SECOND][FIRST] = objlist[MIDDLE].S_objid;
    ptobjs[SECOND][SECOND] = objlist[FIRST].S_objid;
    }

  if (angto_firstseg)
    *angto_firstseg = 180.0;

ret_end:
  EMWRAPUP (*msg, stat_OM, "SKcollinear.SKgetornt");
  return (stat_OM);
}


end implementation SKcollinear;
