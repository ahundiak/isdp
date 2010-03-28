#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/transgo/GUchkovrflow.c */
extern IGRboolean GUcheck_overflow __((IGRlong *msg, IGRlong *num_values, IGRdouble *values, IGRdouble *max_overflow));

#if defined(__cplusplus)
}
#endif


#undef __
