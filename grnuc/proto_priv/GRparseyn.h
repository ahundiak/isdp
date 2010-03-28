#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/symbco/GRparseyn.C */
extern IGRint GRparseyn __((IGRlong *msg, IGRchar string[], IGRint *flag));

#if defined(__cplusplus)
}
#endif


#undef __
