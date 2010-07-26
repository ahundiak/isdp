#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/locate/locate/GRfindmod.C */
extern int GRfindmod __((struct GRid *id));

#if defined(__cplusplus)
}
#endif


#undef __
