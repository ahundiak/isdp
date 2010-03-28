#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/manipco/COchfunc.I */
extern IGRint COpre_delete_name __((IGRint name_count));
extern IGRint COpre_undelete_name __((IGRint name_count));
extern IGRint COch_delete __((IGRlong *msg, OM_S_OBJID caller_id, OMuword caller_os, struct GRmd_env *mod, struct GRevent *events[], OM_S_CHANSELECT *gschan, char *userdata));
extern IGRint COch_undelete __((IGRlong *msg, OM_S_OBJID caller_id, OMuword caller_os, struct GRmd_env *mod, struct GRevent *events[], OM_S_CHANSELECT *gschan, char *userdata));
extern IGRint COch_undel_toggle __((IGRlong *msg, OM_S_OBJID caller_id, OMuword caller_os, struct GRmd_env *mod, struct GRevent *events[], OM_S_CHANSELECT *gschan, char *userdata));
extern IGRint COch_name __((IGRlong *msg, OM_S_OBJID caller_id, OMuword caller_os, struct GRmd_env *mod, struct GRevent *events[], OM_S_CHANSELECT *gschan, char *userdata));
extern IGRint COch_dis_on __((IGRlong *msg, OM_S_OBJID caller_id, OMuword caller_os, struct GRmd_env *mod, struct GRevent *events[], OM_S_CHANSELECT *gschan, char *userdata));
extern IGRint COch_dis_off __((IGRlong *msg, OM_S_OBJID caller_id, OMuword caller_os, struct GRmd_env *mod, struct GRevent *events[], OM_S_CHANSELECT *gschan, char *userdata));
extern IGRint COch_loc_on __((IGRlong *msg, OM_S_OBJID caller_id, OMuword caller_os, struct GRmd_env *mod, struct GRevent *events[], OM_S_CHANSELECT *gschan, char *userdata));
extern IGRint COch_loc_off __((IGRlong *msg, OM_S_OBJID caller_id, OMuword caller_os, struct GRmd_env *mod, struct GRevent *events[], OM_S_CHANSELECT *gschan, char *userdata));

#if defined(__cplusplus)
}
#endif


#undef __
