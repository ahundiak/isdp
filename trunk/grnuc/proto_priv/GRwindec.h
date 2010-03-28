#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/misc/GRwindec.c */
#ifdef RUN_X
extern int GRget_decoration __((Window w, int x, int y, int *xdecor, int *ydecor, int *xoffset, int *yoffset));
#endif
extern int GRget_form_decoration __((int *xdecor, int *ydecor));
extern int GRget_form_offset __((int *xoffset, int *yoffset));

#if defined(__cplusplus)
}
#endif


#undef __
