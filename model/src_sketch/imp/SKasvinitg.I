class implementation SKasvlgrnd;

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

from SKvariable import SKgetmgr;

method SKinit_assocvl_ground (IGRlong *msg; IGRushort options;
                              struct GRid *expression_id;
                              IGRchar *expression_name;
                              GRobjid mgrobj;
                              IGRchar *moreinfo;
                              GRobjid *vgval)
{
  IGRint msg_loc;
  IGRlong stat_OM, status;
  struct GRid expvarid;
  OM_S_CHANSELECT chan_to_mgr, chan_to_mgrcnstrs;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  /*
   * Mark this constraint as being newly added
   */

  if (options & SK_OPT_MARK_AS_NEWADD)
    ME.SKconstraint->props |= SK_NEWADD;
  if (options & SK_OPT_MARK_AS_USERADD)
    ME.SKconstraint->props |= SK_USERADD;

  /*
   * Connect myself to the expression variable as my parent and initialize
   * my variables instance data with the value from the expression. The
   * latter is done by simulating a recompute on the ground.
   */

  if (expression_name)
    {
    status = di$translate (objname = expression_name,
              p_objid = &expvarid.objid, p_osnum = &expvarid.osnum);
    EMerr_hndlr (status != DIR_S_SUCCESS, *msg, EMS_E_Fail, ret_end);
    }
  else if (expression_id)
    expvarid = *expression_id;
  else
    {EMerr_hndlr (TRUE, *msg, EMS_E_InvalidArg, ret_end);}

  stat_OM = om$send (msg = message NDnode.NDconnect (1, &expvarid, NULL_GRID,
             ND_NEW), targetid = my_id);
  EMomerr_exit (stat_OM, ret_end);

  stat_OM = om$send (msg = message NDnode.NDupdate (&msg_loc, NULL,
                           1, &expvarid, NULL,NULL,NULL,NULL), 
                     targetid = my_id);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

  /*
   * Connect myself to the sketch-manager (if not inhibited).
   */

  if (! (options & SK_OPT_NO_MGR_CONNECT))
    {
    EMmake_chanselect (SKconstraint_to_mgr, &chan_to_mgr);
    EMmake_chanselect (SKmgr_to_constrs, &chan_to_mgrcnstrs);

    stat_OM = om$send (msg = message Root.connect (chan_to_mgr, MAXINT,
               mgrobj, OM_Gw_current_OS, chan_to_mgrcnstrs, MAXINT),
               targetid = my_id);
    EMomerr_exit (stat_OM, ret_end);
    }

ret_end:
  EMWRAPUP (*msg, stat_OM, "SKasvlgrnd.SKinit");
  return (stat_OM);
}

end implementation SKasvlgrnd;
