#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/gosup/GRbcpart.c */
extern IGRlong GRbc_part __((struct IGRbsp_curve *curve, int order, IGRlong num_poles, IGRboolean rational, IGRshort num_boundaries));

#if defined(__cplusplus)
}
#endif


#undef __
