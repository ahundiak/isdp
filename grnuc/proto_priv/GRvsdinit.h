#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/grio/getevent/GRvsdinit.C */
extern IGRlong GRvsdinit __((void));

#if defined(__cplusplus)
}
#endif


#undef __
