#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/rfsup/GRget_Super.I */
extern IGRlong GRget_Super_info __((IGRlong *msg, IGRchar *osname, struct GRid *Super_id));

#if defined(__cplusplus)
}
#endif


#undef __
