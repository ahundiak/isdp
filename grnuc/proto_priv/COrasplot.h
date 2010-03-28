#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/plotco/COrasplot.C */
extern IGRint COinitraspf __((IGRlong *msg, IGRchar *plotfile));
extern IGRint COcloseraspf __((IGRlong *msg));
extern IGRint COgetraspf __((IGRlong *msg, IGRchar *filename, FILE **fileptr));

#if defined(__cplusplus)
}
#endif


#undef __
