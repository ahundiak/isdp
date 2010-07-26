#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/adpco/GRchgadplnwt.C */
extern void GRchg_adp_line_weight __((int form_label, int label, double value, Form form_ptr));

#if defined(__cplusplus)
}
#endif


#undef __
