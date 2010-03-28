#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/pplsrc/com/cimem.C */
extern int alloc_ci_data __((int nb_var, int sz_data, int nb_instr, int sz_text, int nb_f_entries, ciinfo **p_code, char **p_data_seg_ad, short **p_text_seg_ad));
extern void free_ci_data __((ciinfo *code, int old));

#if defined(__cplusplus)
}
#endif


#undef __
