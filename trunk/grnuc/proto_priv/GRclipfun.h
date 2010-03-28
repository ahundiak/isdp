#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/supfungo/GRclipfun.I */
extern IGRint GRclip_function __((IGRlong *msg, struct GRid *obj_id, struct GRfunction_info *fun_info));

#if defined(__cplusplus)
}
#endif


#undef __
