#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/gosup/GRtchgclass.I */
extern IGRlong GRtaltchgclass __((IGRlong *msg, struct GRmd_env *env, GRobjid *my_id, IGRint type, IGRchar *classname, IGRushort *properties, IGRchar *geometry, IGRdouble *old_range, IGRdouble *range));

#if defined(__cplusplus)
}
#endif


#undef __
