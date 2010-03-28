#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/misc/COcurptfrm.C */
extern IGRlong CO_const_current_pt_form __((IGRlong *msg, struct GRevent *Events[]));
extern void CurrentPt_form_notification __((IGRint form_label, IGRint gadget_label, IGRdouble value, Form form_ptr));

#if defined(__cplusplus)
}
#endif


#undef __
