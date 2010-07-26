#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/event/COptsalsp.I */
extern IGRlong CO_ni_generate_pts_along_element_by_spacing __((IGRlong *msg, struct GRevent *Events[]));

#if defined(__cplusplus)
}
#endif


#undef __
