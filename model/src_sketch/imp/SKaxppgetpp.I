class implementation SKaxisptpt;

#define ORIGIN  0
#define MEASURE 1
#define AXIS_1  2
#define AXIS_2  3

#define V 0

method SKgetptptinfo (IGRlong *msg; struct SKsolvevars *solvedvars;
                      IGRdouble *value; GRobjid ptobjs[4])
{
  OMuint              count;
  IGRlong             stat_OM;
  struct SKsolvevars  *thisvar;
  OM_S_CHANSELECT     chan_to_pts;
  OM_S_OBJECT_LINKAGE varlist[4];
  extern IGRboolean   SKvarlistinx();

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  if (!SKvarlistinx (solvedvars, my_id, VAR_SOMEVAL, &thisvar, NULL))
  {
    *value = ME.expression->value;
    if (ME.SKconstraint->props & SK_NOVALUE)
      *msg = EMS_I_NotFound;
  }
  else
    *value = thisvar->var[V];

  EMmake_chanselect (SKconstraint_to_variables, &chan_to_pts);
  om$get_channel_objects (object = me, p_chanselect = &chan_to_pts,
                          list = varlist, size = 4, count = &count);
  EMerr_hndlr (count < 2 || count > 4, *msg, EMS_E_InvalidCase, ret_end);

  if (ptobjs)
  {
    ptobjs[ORIGIN] = varlist[ORIGIN].S_objid;
    ptobjs[MEASURE] = varlist[MEASURE].S_objid;
    if (count == 2) 
    {
      ptobjs[AXIS_1] = ptobjs[ORIGIN];
      ptobjs[AXIS_2] = ptobjs[MEASURE];
    }
    else if (count == 3)
    {
      ptobjs[AXIS_1] = varlist[AXIS_1].S_objid;
      ptobjs[AXIS_2] = ptobjs[ORIGIN];
    }
    else if (count == 4)
    {
      ptobjs[AXIS_1] = varlist[AXIS_1].S_objid;
      ptobjs[AXIS_2] = varlist[AXIS_2].S_objid;
    }
  }

ret_end:
  EMWRAPUP (*msg, stat_OM, "SKaxisptpt.SKgetptptinfo");  
  return (stat_OM);
}

end implementation SKaxisptpt;
