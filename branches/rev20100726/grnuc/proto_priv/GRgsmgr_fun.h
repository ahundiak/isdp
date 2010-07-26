#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/fencego/GRgsmgr_fun.I */
extern IGRint GRgsmgr_fun __((IGRlong *msg, IGRint type, IGRchar *arg1, IGRchar *arg2, IGRchar *arg3, IGRchar *arg4, IGRchar *arg5, IGRchar *arg6));

#if defined(__cplusplus)
}
#endif


#undef __
