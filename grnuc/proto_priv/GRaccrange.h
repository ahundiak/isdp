#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/supfungo/GRaccrange.C */
extern IGRint GRaccumulate_range __((IGRlong *msg, IGRdouble range[], IGRdouble acc_range[]));

#if defined(__cplusplus)
}
#endif


#undef __
