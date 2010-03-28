#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/grio/expreval/COexpreval.C */
extern IGRlong COexpreval __((IGRlong *ReturnMsg, IGRint ScaleFlag, IGRchar *Expression, IGRchar *UnitType, IGRdouble *Result));

#if defined(__cplusplus)
}
#endif


#undef __
