#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/gosup/GRaltchgclas.I */
extern IGRlong GRaltchgclass __((IGRlong *msg, struct GRmd_env *env, GRobjid *my_id, IGRchar *classname, IGRushort *properties, IGRchar *geometry, IGRshort *chan_flag, IGRshort *del_flag, GRobjid *new_objid));

#if defined(__cplusplus)
}
#endif


#undef __
