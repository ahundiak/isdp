class implementation SKhorizvert;

#define FIRST  0
#define SECOND 1

method SKgetabsornt (IGRlong *msg; struct SKsolvevars *solvedvars;
                     IGRdouble *angle; GRobjid ptobjs[2])
{
  OMuint              count;
  IGRlong             stat_OM;
  OM_S_CHANSELECT     chan_to_pts;
  OM_S_OBJECT_LINKAGE objlist[2];

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  if (ptobjs)
    {
    EMmake_chanselect (SKconstraint_to_variables, &chan_to_pts);
    count = 0;
    om$get_channel_objects (object = me, p_chanselect = &chan_to_pts,
     size = 2, count = &count, list = objlist);
    EMerr_hndlr (count != 2, *msg, EMS_E_InvalidCase, ret_end);

    ptobjs[FIRST] = objlist[FIRST].S_objid;
    ptobjs[SECOND] = objlist[SECOND].S_objid;
    }

  if (angle)
    {
    if (ME.SKconstraint->props & SK_HORIZONTAL)
      *angle = 0;
    else
      *angle = 90;
    }

ret_end:
  EMWRAPUP (*msg, stat_OM, "SKhorver.SKgetornt");
  return (stat_OM);
}

end implementation SKhorizvert;
