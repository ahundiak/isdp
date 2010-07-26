#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/pplsrc/src/cisymb.C */
extern int init_cnst_list __((void));
extern int ciget_symb __((CIcnst_list *L));
extern int ciget_text_attr __((CIcnst_list *L));
extern int ciset_symb __((CIcnst_list *L));
extern int ciset_gal_symb __((CIcnst_list *L));
extern int ci_set_gal_symb __((struct IGRdisplay *display, short *level));
extern int ci_get_gal_symb __((struct IGRdisplay *display, short *level));
extern int ciset_text_attr __((CIcnst_list *L));
extern int CI_SYMB __((char *fname));

#if defined(__cplusplus)
}
#endif


#undef __
