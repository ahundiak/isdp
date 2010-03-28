#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/grio/expreval/COexprlib.C */
extern IGRlong COexpr_sin __((IGRdouble *arg, struct COexpr_stacktype *result));
extern IGRlong COexpr_cos __((IGRdouble *arg, struct COexpr_stacktype *result));
extern IGRlong COexpr_tan __((IGRdouble *arg, struct COexpr_stacktype *result));
extern IGRlong COexpr_sec __((IGRdouble *arg, struct COexpr_stacktype *result));
extern IGRlong COexpr_cosec __((IGRdouble *arg, struct COexpr_stacktype *result));
extern IGRlong COexpr_cotan __((IGRdouble *arg, struct COexpr_stacktype *result));
extern IGRlong COexpr_log __((IGRdouble *arg, struct COexpr_stacktype *result));
extern IGRlong COexpr_sqrt __((IGRdouble *arg, struct COexpr_stacktype *result));

#if defined(__cplusplus)
}
#endif


#undef __
