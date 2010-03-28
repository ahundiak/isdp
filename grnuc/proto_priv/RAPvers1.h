#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/rap/RAPvers.C */
extern int RAP_get_version __((void));

#if defined(__cplusplus)
}
#endif


#undef __
