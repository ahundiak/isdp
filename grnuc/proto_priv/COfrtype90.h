#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/plotco/COfrtype90.c */
extern IGRint COfindrastype90 __((IGRlong *msg, IGRchar *plotfile, IGRchar *rasfile, IGRchar *shvar));

#if defined(__cplusplus)
}
#endif


#undef __
