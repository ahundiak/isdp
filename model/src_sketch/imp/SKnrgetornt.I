class implementation SKnormal;

#include <values.h>

#define FIRST	0
#define SECOND	1
#define THIRD	2
#define FOURTH	3

method SKgetrelornt (IGRlong *msg; struct SKsolvevars *solvedvals;
                     IGRdouble *angto_firstseg; GRobjid ptobjs[2][2])
{
  OMuint count;
  IGRlong stat_OM;
  OM_S_CHANSELECT chan_to_pts;
  OM_S_OBJECT_LINKAGE objlist[4];

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  if (ptobjs)
    {
    EMmake_chanselect (SKconstraint_to_variables, &chan_to_pts);
    count = 0;
    om$get_channel_objects (object = me, p_chanselect = &chan_to_pts,
     size = 4, count = &count, list = objlist);
    EMerr_hndlr (count < 3 || count > 4, *msg, EMS_E_InvalidCase, ret_end);

    ptobjs[FIRST][FIRST] = objlist[FIRST].S_objid;
    ptobjs[FIRST][SECOND] = objlist[SECOND].S_objid;
    ptobjs[SECOND][FIRST] = objlist[count == 3 ? FIRST : THIRD].S_objid;
    ptobjs[SECOND][SECOND] = objlist[count == 3 ? THIRD : FOURTH].S_objid;
    }

  if (angto_firstseg)
    *angto_firstseg = 90.0;

ret_end:
  EMWRAPUP (*msg, stat_OM, "SKnormal.SKgetornt");
  return (stat_OM);
}


end implementation SKnormal;
