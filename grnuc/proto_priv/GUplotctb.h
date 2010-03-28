#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/transgo/GUplotctb.C */
extern IGRint GUplotctb __((IGRlong *msg, struct rgb_entry plotctb[]));

#if defined(__cplusplus)
}
#endif


#undef __
