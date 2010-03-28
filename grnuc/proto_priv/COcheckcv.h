#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/misc/COcheckcv.C */
extern IGRlong COcheck_curve __((IGRlong *msg, struct IGRbsp_curve *curve));

#if defined(__cplusplus)
}
#endif


#undef __
