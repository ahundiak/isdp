#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/dim/dim_co/gtforms.I */
extern int ANget_tol_symbol __((int g_label, int *symbol_num, struct GTattr *gtattr, Form form));

#if defined(__cplusplus)
}
#endif


#undef __
