#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/detailco/COdtloption.I */
extern int file_compare_func __((char **file1, char **file2));

#if defined(__cplusplus)
}
#endif


#undef __
