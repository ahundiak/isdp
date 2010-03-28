#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/gosup/GRcheckrel.c */
extern IGRlong GRcheckrel __((IGRlong *msg, IGRlong *prism_rel, IGRlong *relationship));

#if defined(__cplusplus)
}
#endif


#undef __
