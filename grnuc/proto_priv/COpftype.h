#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/plotco/COpftype.c */
extern int COpftype __((char *filename, int *filetype));

#if defined(__cplusplus)
}
#endif


#undef __
