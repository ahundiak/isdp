#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/assoc/gopara/ASsupport.I */
extern int AStransaction __((void));
extern int COpara_init __((void));
extern int ASassoc_init __((void));
extern int ASmake_source_from_env __((struct GRid *go, struct GRmd_env *mod_env, struct GRid *source, int option));
extern int ASmake_source __((struct GRid go, struct GRid context, GRspacenum as_osnum, struct GRid *as, int option));
extern int ASmake_source_from_go __((IGRint *msg, struct GRid *go, struct GRid *context, GRspacenum as_osnum, struct GRid *as));
extern int ASget_mac_owner __((struct GRid *go, struct GRid *mc_own));
extern int ASget_as_owner __((struct GRid *go, struct GRid *owner));
extern int ASget_source __((struct GRid *go, struct GRid *context, struct GRid *as, GRspacenum as_osnum));
extern int ASany_give_struct __((GRobjid object_id, GRspacenum object_os, struct GRmd_env *md_env, struct ret_struct *inst));
extern int ASgo_give_structure __((GRobjid object_id, GRspacenum object_os, struct GRmd_env *md_env, struct ret_struct *inst));
extern int AScircle_give_struct __((GRobjid object_id, GRspacenum object_os, struct GRmd_env *md_env, struct ret_struct *inst));
extern int ASline_give_struct __((GRobjid object_id, GRspacenum object_os, struct GRmd_env *md_env, struct ret_struct *inst));
extern int ASpoint_give_struct __((GRobjid object_id, GRspacenum object_os, struct GRmd_env *md_env, struct ret_struct *inst));
extern int ASref_give_struct __((GRobjid object_id, GRspacenum object_os, struct GRmd_env *md_env, struct ret_struct *refdef));
extern int ASplane_give_struct __((GRobjid object_id, GRspacenum object_os, struct GRmd_env *md_env, struct ret_struct *inst));
extern int AStext_give_struct __((GRobjid object_id, GRspacenum object_os, struct GRmd_env *md_env, struct ret_struct *textdef));
extern IGRint ASgive_size_st __((IGRint type));
extern int ASfind_modifier __((struct GRid object, struct GRid other, struct GRid *modifier));
extern int AScontrole_rtree __((IGRchar *string, IGRint code));

#if defined(__cplusplus)
}
#endif


#undef __
