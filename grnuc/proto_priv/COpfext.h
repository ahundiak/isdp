#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/plotco/COpfext.c */
extern int COget_plotfile_extents __((char *filename, double *x, double *y, char *unit, int *filetype, unsigned *clipbox));
extern int IGDSfile_extents __((int *msg, char *filename, double *x, double *y, char *unit, unsigned *clipbox));
extern int IGMfile_extents __((int *msg, char *filename, double *x, double *y, char *unit));

#if defined(__cplusplus)
}
#endif


#undef __
