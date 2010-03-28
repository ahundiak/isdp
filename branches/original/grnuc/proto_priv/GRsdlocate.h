#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/symbgo/GRsdlocate.C */
extern IGRint GRsd_locate_in_all_sl __((IGRlong *msg, IGRchar *sd_name, struct GRmd_env *sl_env, struct GRid *sd_id));
extern IGRint GRsd_locate_in_asl __((IGRlong *msg, IGRchar *sd_name, struct GRmd_env *sl_env, struct GRid *sd_id));
extern IGRint GRsd_locate __((IGRlong *msg, IGRint num_OS, GRspacenum *p_OS, IGRchar *sd_name, OM_S_OBJARRAY *p_OBJARRAY, GRspacenum *p_loc_OS));
extern IGRint GRsd_add __((IGRlong *msg, GRspacenum sl_osnum, IGRchar *sd_name, GRobjid sd_objid));
extern IGRint GRsd_remove __((IGRlong *msg, GRspacenum sl_osnum, IGRchar *sd_name, GRobjid sd_objid));

#if defined(__cplusplus)
}
#endif


#undef __
