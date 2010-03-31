class implementation SKhorizvert;

method SKevaluate (IGRlong *msg; IGRushort opts;
                   struct SKsolvevars *tosolvevar;
                   struct SKsolvevars **solvedvars;
                   struct SKsolvevars **nosolution_vars)
{
  OMuint              count;
  int                 known_index;
  long                msg_loc, stat_OM;
  double              outval;
  struct SKsolvevars  *varnode_known;
  OM_S_CHANSELECT     chan_to_vars;
  OM_S_OBJECT_LINKAGE objlist [2];
  extern void         SKaddvarlist();
  extern IGRboolean   SKvarlistinx();

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  om$make_chanselect ( channame = "SKconstraint.to_variables",
                       p_chanselect = &chan_to_vars );
  om$get_channel_objects ( object = me, 
                           p_chanselect = &chan_to_vars,
                           list = objlist, 
                           size = 2, 
                           count = &count );
  EMerr_hndlr (count != 2, *msg, EMS_E_InvalidCase, ret_end);

  if (!SKvarlistinx ( *solvedvars, objlist [0].S_objid, 
                      me->props & SK_HORIZONTAL ? VAR_Y : VAR_X,
                      &varnode_known, NULL ))
    if (!SKvarlistinx ( *solvedvars, objlist [1].S_objid, 
                        me->props & SK_HORIZONTAL ? VAR_Y : VAR_X,
                        &varnode_known, NULL ))
    {
      EMerr_hndlr ( 1, *msg, EMS_I_Insufficient, ret_end );
    }
    else
      known_index = 1;
  else
    known_index = 0;
  
  outval = varnode_known->var [me->props & SK_HORIZONTAL ? 1 : 0];
  {
    GRobjid var = objlist [(known_index + 1) % 2].S_objid;
    
    SKaddvarlist ( &msg_loc, NULL, solvedvars, 
                   me->props & SK_HORIZONTAL ? VAR_Y : VAR_X, 
                   var, my_id, my_id, &outval, NULL );
  }
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

ret_end:
  EMWRAPUP (*msg, stat_OM, "SKhorizvert.SKevaluate");

  return stat_OM;
}

end implementation SKhorizvert;

