#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/plotco/COsppfname.C */
extern int COsppfname __((PIplotdata *pd, int form_label, int gadget_label, double value, Form form, char *name));
extern int COspclearsize __((Form form, PIplotdata *pd));

#if defined(__cplusplus)
}
#endif


#undef __
