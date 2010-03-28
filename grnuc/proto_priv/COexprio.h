#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/grio/expreval/COexprio.C */
extern IGRint COexpr_input __((void));
extern IGRint COexpr_unput __((IGRchar c));

#if defined(__cplusplus)
}
#endif


#undef __
