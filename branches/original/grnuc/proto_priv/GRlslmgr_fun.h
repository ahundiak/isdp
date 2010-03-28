#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/symbgo/GRlslmgr_fun.I */
extern IGRint GRlslmgr_fun __((IGRlong *msg, IGRint type, IGRchar *arg1, IGRchar *arg2, IGRchar *arg3, IGRchar *arg4));

#if defined(__cplusplus)
}
#endif


#undef __
