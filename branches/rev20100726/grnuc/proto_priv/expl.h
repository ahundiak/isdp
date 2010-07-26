#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/assoc/expression/expl.C */
extern char my_getc __((FILE *expyin));
extern int expylex __((void));
extern int expywrap __((void));
extern int assign __((char *text, int type, struct data_struct *dat));
extern int display __((struct data_struct dat));
extern int expylook __((void));
extern int expyback __((int *p, int m));
extern int expyinput __((void));
extern int expyoutput __((int c));
extern int expyunput __((int c));

#if defined(__cplusplus)
}
#endif


#undef __
