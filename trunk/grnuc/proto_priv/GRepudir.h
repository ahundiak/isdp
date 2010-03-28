#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/ptngo/GRepudir.C */
extern IGRint GRepudir __((IGRlong *msg, struct IGRbsp_curve *curve, struct GRparms *start, struct GRparms *dir, struct GRparms *end, IGRshort *ascending));

#if defined(__cplusplus)
}
#endif


#undef __
