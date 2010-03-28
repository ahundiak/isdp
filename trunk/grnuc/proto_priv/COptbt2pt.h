#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/event/COptbt2pt.C */
extern IGRlong CO_ni_point_between_2_pts __((IGRint *ReturnMsg, struct GRevent *Events[]));

#if defined(__cplusplus)
}
#endif


#undef __
