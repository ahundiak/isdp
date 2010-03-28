#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/rap/RAPfmIsMenu.c */
extern int RAPformIsMenu __((char *formName));

#if defined(__cplusplus)
}
#endif


#undef __
