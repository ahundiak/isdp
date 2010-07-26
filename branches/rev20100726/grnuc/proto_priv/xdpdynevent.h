#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/display/grdisplay/xdpdynevent.C */
extern int GRXget_button_data __((IGRint hwwin_no, IGRint *button, IGRint *transition, IGRint *x, IGRint *y, IGRint *but_state, IGRint *pan_state, IGRint *state, Bool (*predproc_ptr )()));
extern IGRint NEDPdynevent __((IGRint hwwin_no, IGRint *state, IGRint *pan_state, IGRint *pan_point, IGRint *but_state));
extern Bool predproc __((Display *display, XEvent *event, char *arg));
extern Bool ignore_noexpose __((Display *display, XEvent *event, char *arg));

#if defined(__cplusplus)
}
#endif


#undef __
