#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/cr/DYelcnt.C */
extern IGRlong DYrbellcnt __((struct GRevent *Events[], struct IGRdisplay *display));

#if defined(__cplusplus)
}
#endif


#undef __
