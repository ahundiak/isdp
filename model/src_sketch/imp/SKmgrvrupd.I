class implementation SKmgr;

from SKvariable import SKputvar;
from SKexplicit import SKputval;

method SKvar_update (IGRlong *msg; IGRushort opts;
                     struct SKsolvevars *solvedvars)
{
  IGRushort loc_opts;
  IGRlong msg_loc, stat_OM;
  struct SKsolvevars *varlist;
  
  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  varlist = solvedvars;
  while (varlist)
    {
    if (! (varlist->props & VAR_PSEUDO_VAL) ||
        opts & SK_UPDATE_PSEUDOVAL)
      {
      if (varlist->props & (VAR_PT | VAR_VAL))
        {
        loc_opts = (varlist->props & VAR_X ? SK_OPT_VAR_X : NULL) |
                    (varlist->props & VAR_Y ? SK_OPT_VAR_Y : NULL);
        stat_OM = om$send (msg = message SKvariable.SKputvar (&msg_loc,
                   loc_opts, NULL, NULL, varlist->var),
                   targetid = varlist->varobj);
        }
      else if (varlist->props & VAR_PSEUDO_VAL)
        {
        stat_OM = om$send (msg = message SKexplicit.SKputval (&msg_loc,
                   NULL, *varlist->var, NULL), targetid = varlist->varobj);
        }
      else
        {EMerr_hndlr (TRUE, *msg, EMS_E_InvalidArg, ret_end);}
      EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
      }
    varlist = varlist->next;
    }

ret_end:
  EMWRAPUP (*msg, stat_OM, "SKvarupdate");
  return (stat_OM);
}

end implementation SKmgr;


