#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/transgo/GUigemapigds.C */
extern void GUinit_map __((IGRlong *msg, IGRchar map_filename[]));
extern void GUigemapigds __((IGRlong *msg, struct GRsymbology *symbology));

#if defined(__cplusplus)
}
#endif


#undef __
