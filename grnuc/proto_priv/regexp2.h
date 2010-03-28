#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/pplsrc/cci/SUNregex/regexp.c */
extern regexp *regcomp __((char *exp));
static char *reg __((int paren, int *flagp));
static char *regbranch __((int *flagp));
static char *regpiece __((int *flagp));
static char *regatom __((int *flagp));
static char *regnode __((int op));
static void regc __((int b));
static void reginsert __((int op, char *opnd));
static void regtail __((char *p, char *val));
static void regoptail __((char *p, char *val));
extern int regexec __((regexp *prog, char *string));
static int regtry __((regexp *prog, char *string));
static int regmatch __((char *prog));
static int regrepeat __((char *p));
static char *regnext __((char *p));
extern void regdump __((regexp *r));
static char *regprop __((char *op));
static int strcspn __((char *s1, char *s2));

#if defined(__cplusplus)
}
#endif


#undef __
