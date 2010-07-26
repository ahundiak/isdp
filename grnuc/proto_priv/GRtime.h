#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/symbgo/GRtime.C */
extern IGRint GRtime __((time_t *tloc));

#if defined(__cplusplus)
}
#endif


#undef __
