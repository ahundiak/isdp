#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/displayco/DPpattern.C */
extern IGRint DPpattern __((unsigned short pattern, IGRchar *buff));

#if defined(__cplusplus)
}
#endif


#undef __
