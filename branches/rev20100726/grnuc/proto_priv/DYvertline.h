#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/ln/DYvertline.C */
extern IGRlong DYrb_vertical_line __((struct GRevent *Events[], struct IGRdisplay *ActiveDisplay));

#if defined(__cplusplus)
}
#endif


#undef __
