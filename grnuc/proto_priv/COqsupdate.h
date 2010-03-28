#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/plotco/COqsupdate.C */
extern int COqsupdate __((PIplotdata *pd, int form_label, int gadget_label, double value, Form form));
extern IGRint COqsgetq __((IGRchar *queue, IGRchar *cmdline));

#if defined(__cplusplus)
}
#endif


#undef __
