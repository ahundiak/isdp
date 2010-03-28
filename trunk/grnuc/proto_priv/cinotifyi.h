#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/pplsrc/cinotify/cinotifyi.I */
extern int ci_notification __((int form_label, int gadget_label, double value, Form form));

#if defined(__cplusplus)
}
#endif


#undef __
