#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/dim/dim_utils/asroot.I */
extern IGRint DMcreate_root __((IGRint type, IGRshort construct, IGRint num_parents, struct GRid *src_list, struct GRid *context_list, IGRdouble *attr, struct GRmd_env *md_env, struct GRid *p_root));
extern IGRint DMcopy_roots __((struct GRid dest[], struct GRid src[], IGRint count));
extern IGRint DMcreate_dmplan __((IGRint *msg, struct GRid win, IGRint count, struct GRid list[], struct GRid ctx[], IGRdouble attr[], struct GRmd_env *md_env, struct GRid *plan));

#if defined(__cplusplus)
}
#endif


#undef __
