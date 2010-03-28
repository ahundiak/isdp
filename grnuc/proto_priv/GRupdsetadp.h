#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/adpco/GRupdsetadp.C */
extern IGRint GRupdate_setadp __((IGRlong *msg, Form form_ptr, struct EX_var_list var_list[], IGRint *error_index));

#if defined(__cplusplus)
}
#endif


#undef __
