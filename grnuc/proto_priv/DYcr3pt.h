#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/cr/DYcr3pt.C */
extern IGRlong DYrbcircle_by_3pt __((struct GRevent *Events[], struct IGRdisplay *display));

#if defined(__cplusplus)
}
#endif


#undef __
