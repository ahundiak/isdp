class implementation SKfixang;

#define FIRST  0
#define SECOND 1

method SKgetabsornt (IGRlong *msg; struct SKsolvevars *solvedvars;
                     IGRdouble *angle; GRobjid ptobjs[2])
{
  IGRboolean found, vertical, negaxis, clockwise;
  OMuint count;
  IGRlong msg_loc, stat_OM;
  IGRdouble loc_ang;
  struct SKsolvevars *thisvar;
  OM_S_CHANSELECT chan_to_pts;
  OM_S_OBJECT_LINKAGE objlist[2];
  extern IGRboolean SKvarlistinx();

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  if (ptobjs)
    {
    EMmake_chanselect (SKconstraint_to_variables, &chan_to_pts);
    stat_OM = om$get_channel_objects (object = me, p_chanselect = &chan_to_pts,
               size = 2, count = &count, list = objlist);
    EMerr_hndlr (EMSerror (stat_OM) || count != 2, *msg, EMS_E_InvalidCase,
     ret_end);

    ptobjs[FIRST] = objlist[FIRST].S_objid;
    ptobjs[SECOND] = objlist[SECOND].S_objid;
    }

  if (angle)
    {
    stat_OM = om$send (msg = message SKexplicit.SKgetval (&msg_loc, &loc_ang),
               targetid = my_id);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_InvalidCase,
     ret_end);
    if (msg_loc == EMS_I_NotFound)
      {
      found = SKvarlistinx (solvedvars, my_id, VAR_SOMEVAL, &thisvar, NULL);
      EMerr_hndlr (!found, *msg, EMS_I_NotFound, ret_end);
      loc_ang = thisvar->var[0];
      }

    vertical = !(ME.SKconstraint->props & SK_HORIZONTAL);
    negaxis = ME.SKconstraint->props & SK_NEGATIVE_AXIS;
    clockwise = ME.SKconstraint->props & SK_CLOCKWISE_ANGLE;
  
    if (clockwise)
      loc_ang = -loc_ang;
    if (negaxis)
      loc_ang += 180.0;
    if (vertical)
      loc_ang += 90.0;
    *angle = loc_ang;
    }

ret_end:
  EMWRAPUP (*msg, stat_OM, "SKfixang.SKgetornt");
  return (stat_OM);
}

end implementation SKfixang;
