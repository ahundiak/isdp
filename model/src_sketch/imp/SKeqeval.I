class implementation SKequal;

#define FIRST  0
#define SECOND 1

method SKevaluate (IGRlong *msg; IGRushort opts;
                   struct SKsolvevars *tosolvevar;
                   struct SKsolvevars **solvedvars;
                   struct SKsolvevars **nosolution_vars)
{
  IGRboolean 		found, var_known[2];
  IGRshort 		i, oppi;
  OMuint 		count;
  IGRlong 		msg_loc, stat_OM;
  IGRdouble 		outval;
  GRobjid 		var[2];
  struct SKsolvevars 	*varnode[2];
  OM_S_CHANSELECT 	chan_to_vars;
  OM_S_OBJECT_LINKAGE 	objlist[2];
  extern void 		SKaddvarlist();
  extern IGRboolean 	SKvarlistinx();

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  om$make_chanselect (channame = "SKconstraint.to_variables",
                      p_chanselect = &chan_to_vars);

  om$get_channel_objects (object = me, p_chanselect = &chan_to_vars,
                          list = objlist, size = 2, count = &count);
  EMerr_hndlr (count != 2, *msg, EMS_E_InvalidCase, ret_end);

  var[FIRST] = objlist[FIRST].S_objid;
  var[SECOND] = objlist[SECOND].S_objid;
  var_known[FIRST] = SKvarlistinx (*solvedvars, var[FIRST], VAR_SOMEVAL,
                                   &varnode[FIRST], NULL);
  var_known[SECOND] = SKvarlistinx (*solvedvars, var[SECOND], VAR_SOMEVAL,
                                    &varnode[SECOND], NULL);
  found = FALSE;
  for (i=FIRST, oppi=SECOND; i<=SECOND; i++, oppi--)
    if (tosolvevar->varobj == var[i])
    {
      EMerr_hndlr (var_known[i], *msg, EMS_I_Redundant, ret_end);
      EMerr_hndlr (!var_known[oppi], *msg, EMS_I_Insufficient, ret_end);
     
      outval = *varnode[oppi]->var;
      SKaddvarlist (&msg_loc, NULL, solvedvars, VAR_PSEUDO_VAL, var[i], my_id,
                    my_id, &outval, NULL);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

      *tosolvevar->var = outval;
      found = TRUE;
    }
  EMerr_hndlr (!found, *msg, EMS_E_InvalidArg, ret_end);

ret_end:
  EMWRAPUP (*msg, stat_OM, "SKequal.SKevaluate");
  return (stat_OM);
}

end implementation SKequal;
