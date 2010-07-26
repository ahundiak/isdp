#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/adpco/GRadpintrcpt.C */
extern void GRadp_intercept __((Form form_ptr, int xpos, int ypos, int button, int trans, int t_tag));
extern void GRget_adp_size __((Form form_ptr));

#if defined(__cplusplus)
}
#endif


#undef __
