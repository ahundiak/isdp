#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/gosup/GRmakeSuper.I */
extern IGRlong GRmakeSuper __((IGRlong *msg, struct GRid *module_info, IGRchar *Super_name, IGRchar *Super_classname, struct GRid *Super_id));

#if defined(__cplusplus)
}
#endif


#undef __
