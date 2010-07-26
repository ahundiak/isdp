#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/symbco/GRcvttime.C */
extern IGRint GRcvt_time_to_ascii __((IGRlong *msg, time_t *input_time, IGRchar string[]));

#if defined(__cplusplus)
}
#endif


#undef __
