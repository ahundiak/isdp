#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/cr/DYcr2ptrad.C */
extern IGRlong DYrbcircle_by_2pts_radius __((struct GRevent *Events[], struct IGRdisplay *display));

#if defined(__cplusplus)
}
#endif


#undef __
