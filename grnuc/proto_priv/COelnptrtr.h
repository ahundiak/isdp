#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/cr/COelnptrtr.I */
extern IGRboolean COelnptrtr __((IGRlong *msg, struct GRevent *Events[], IGRshort *NumberOfEvents, struct IGRbsp_curve *ellipse));

#if defined(__cplusplus)
}
#endif


#undef __
