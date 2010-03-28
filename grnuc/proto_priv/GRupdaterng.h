#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/gosup/GRupdaterng.I */
extern IGRlong GRupdaterng __((IGRlong *msg, struct GRmd_env *md_info, struct GRpost_info *post_info, GRobjid *objid, IGRushort *properties, GRrange old_range, GRrange new_range));

#if defined(__cplusplus)
}
#endif


#undef __
