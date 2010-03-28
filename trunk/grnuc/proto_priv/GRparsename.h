#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/detailco/GRparsename.C */
extern IGRint GRrfparsenames __((IGRlong *msg, IGRchar string[], IGRchar filename[], IGRchar saveview_name[]));

#if defined(__cplusplus)
}
#endif


#undef __
