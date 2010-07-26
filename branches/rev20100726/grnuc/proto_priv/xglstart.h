#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/display/grdisplay/xglstart.C */
extern int XGLOpen __((void));

#if defined(__cplusplus)
}
#endif


#undef __
