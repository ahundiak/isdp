#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/assoc/condit/COm_condit1.I */
extern int COm_condit_router __((int form_label, int label, double value, char *form_ptr));
extern int COm_condit_option __((int form_label, int label, double value, char *form_ptr));
extern int COm_condit_delete_form __((void));

#if defined(__cplusplus)
}
#endif


#undef __
