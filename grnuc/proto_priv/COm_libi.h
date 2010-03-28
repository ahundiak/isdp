#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/assoc/nmacro_co/COm_libi.I */
extern int COm_lib_review __((int f_label, int g_label, double value, char *fp));
extern int COm_lib_router __((int f_label, int g_label, double value, char *fp));

#if defined(__cplusplus)
}
#endif


#undef __
