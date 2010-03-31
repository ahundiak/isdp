class implementation SKimplicit;

#define FIRST 0

extern GRclassid OPP_SKgmhndlpt_class_id;

method SKrecompute_yourself (IGRlong *msg; struct GRmd_env *md_env;
                             IGRshort *lxyz_mattyp; IGRdouble *lxyz_mat)
{
  IGRulong props;
  IGRlong stat_OM;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  props = ME.SKconstraint->props;
  if (! (props & SK_SELFCNSTR || props & SK_INVISIBLEHNDL))
    stat_OM = om$send (msg = message SKconstraint.SKcreate_geom (msg,
               NULL, md_env, NULL), targetid = my_id);

  EMWRAPUP (*msg, stat_OM, "SKimp.SKrecomp");
  return (stat_OM);
}

end implementation SKimplicit;

