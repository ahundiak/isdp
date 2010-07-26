#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/misc/GRudir.C */
extern IGRint GRudir __((IGRlong *msg, struct IGRbsp_curve *curve, IGRdouble *start, IGRdouble *dir, IGRdouble *end, IGRshort *ascending, IGRshort *cross));

#if defined(__cplusplus)
}
#endif


#undef __
