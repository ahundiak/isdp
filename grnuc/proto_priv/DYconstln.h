#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/ln/DYconstln.C */
extern IGRlong DYrbconstruct_line __((struct GRevent *Events[], struct IGRdisplay *display));

#if defined(__cplusplus)
}
#endif


#undef __
