class implementation SKmgr;

/*
  ABSTRACT

    This implementation provides the GRdelete override at SKmgr class
    object.

  HISTORY

     RC  :  05/26/90  :  Creation Date
*/

from SKvariable import SKintdelete;


method GRdelete(IGRlong *msg; struct GRmd_env *md_env)
{

 OM_S_CHANSELECT   mgr_cnstrs_chan, mgr_pts_chan;

 IGRlong  OM_stat;

 /* ***************************************************************** */

 OM_stat = OM_S_SUCCESS;
 *msg = EMS_S_Success;

 /*
  * o Delete the constraint objects. Constraint objects will delete
  *   their respective geometry.
  * o Delete graphics  elements.
  * o Delete the pt variables.
  */

OM_stat = om$make_chanselect (channame = "SKmgr.to_vars",
                              p_chanselect = &mgr_pts_chan);
EMerr_hndlr (!(1&OM_stat), *msg, EMS_E_OMerror, wrapup);

OM_stat = om$make_chanselect (channame = "SKmgr.to_constrs",
                              p_chanselect = &mgr_cnstrs_chan);
EMerr_hndlr (!(1&OM_stat), *msg, EMS_E_OMerror, wrapup);

OM_stat = om$send (msg = message GRgraphics.GRdelete (msg, md_env),
                    p_chanselect = &mgr_cnstrs_chan);
EMerr_hndlr (!(1&OM_stat&*msg), *msg, EMS_E_Fail, wrapup);

OM_stat = om$send (mode = OM_e_wrt_message,
                   msg = message GRowner.GRdelete (msg, md_env),
                   targetid = my_id);
EMerr_hndlr (!(1&OM_stat&*msg),*msg,EMS_E_Fail,wrapup);                   

OM_stat = om$send (msg = message SKvariable.SKintdelete (msg, NULL, md_env),
                   p_chanselect = &mgr_pts_chan);
EMerr_hndlr (!(1&OM_stat), *msg, EMS_E_OMerror, wrapup);

wrapup:
  EMWRAPUP (*msg, OM_stat, "SKmgr.GRdelete");
  return (OM_stat);
}

end implementation SKmgr;
