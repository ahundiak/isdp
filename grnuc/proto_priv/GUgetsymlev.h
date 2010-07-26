#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/transgo/GUgetsymlev.C */
extern IGRint GUset_symb __((IGRlong *msg, struct GRsymbology *symb, IGRshort *props, IGRboolean *set));
extern IGRint GUget_symb_level __((IGRlong *msg, struct GRsymbology *symb));
extern int GUinit_symb __((void));
extern int GUaddcount __((void));
extern IGRshort GUsubcount __((void));

#if defined(__cplusplus)
}
#endif


#undef __
