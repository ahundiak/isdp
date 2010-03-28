#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/adpco/GRprocadp.C */
extern void GRprocess_adp __((int form_label, int label, double value, Form form_ptr));

#if defined(__cplusplus)
}
#endif


#undef __
