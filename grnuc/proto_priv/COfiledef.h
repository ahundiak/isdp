#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/plotco/COfiledef.c */
extern int COfiledef __((int read_flag, char *grnucpath, char *plotfile, char *queue, char *ctable, char *iplot, char *rendattr, char *port, int *window));

#if defined(__cplusplus)
}
#endif


#undef __
