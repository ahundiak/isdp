#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/misc/GRposform.C */
extern IGRint GRposition_form __((Form form, IGRint position));

#if defined(__cplusplus)
}
#endif


#undef __
