#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/displayco/COdlsfunc.C */
extern void dls_form_init __((IGRint create, Form *dls_form_ptr));
extern int dls_form_notification __((IGRint form_label, IGRint gadget_label, IGRdouble value, Form form_ptr));

#if defined(__cplusplus)
}
#endif


#undef __
