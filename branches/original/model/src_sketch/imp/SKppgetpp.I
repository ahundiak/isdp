class implementation SKptpt;

#define FIRST  0
#define SECOND 1

#define V 0

method SKgetptptinfo (IGRlong *msg; struct SKsolvevars *solvedvars;
                      IGRdouble *value; GRobjid ptobjs[2])
{
  OMuint count;
  IGRlong stat_OM;
  struct SKsolvevars *thisvar;
  OM_S_CHANSELECT chan_to_pts;
  OM_S_OBJECT_LINKAGE varlist[2];
  extern IGRboolean SKvarlistinx();

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
   list = varlist, size = 2, count = &count);
  EMerr_hndlr (count != 2, *msg, EMS_E_InvalidCase, ret_end);

  ptobjs[FIRST] = varlist[FIRST].S_objid;
  ptobjs[SECOND] = varlist[SECOND].S_objid;

ret_end:
  EMWRAPUP (*msg, stat_OM, "SKgetptptinfo");  
  return (stat_OM);
}

end implementation SKptpt;
