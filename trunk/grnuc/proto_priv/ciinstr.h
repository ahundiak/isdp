#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/pplsrc/cci/ciinstr.c */
extern void INSreset __((void));
static int INStextalloc __((void));
static int INSalloc __((void));
extern int genins __((int type, PCIlist *args));
extern int gen __((int type, int npm, int pm0, int pm1, int pm2, int pm3));
extern int INSjmp __((char *lab, int typ, int val));
extern int ARRcpy __((int to, int from));
extern int INSpush __((PCIlist *args));

#if defined(__cplusplus)
}
#endif


#undef __
