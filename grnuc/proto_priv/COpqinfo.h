#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/plotco/COpqinfo.C */
extern int COpqinfo __((char *plotter_queue, double *x, double *y, char *plotter_unit));
extern int COspqlist __((Form form, int *qcount));
extern int COspformatqinfo __((char *queue, double x, double y, char *unit, char *buf));

#if defined(__cplusplus)
}
#endif


#undef __
