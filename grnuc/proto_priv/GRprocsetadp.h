#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/adpco/GRprocsetadp.C */
extern void GRprocess_setadp __((int form_label, int label, double value, Form form_ptr));
extern IGRint GRupdate_setadp_subforms __((struct IGRdisplay *active_display));
extern IGRint GRdisplay_setadp_subforms __((IGRint display));

#if defined(__cplusplus)
}
#endif


#undef __
