#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/pplsrc/cci/cil.c */
extern int LEXoch __((char *s));
extern double LEXxreal __((char *h));
extern void LEXsharp __((char *pattern, char *lextext));
static int LEXident __((char *lextext, YYSTYPE *token));
extern int LEXstring __((char *text, PCIstring *p_str));
static int LEXunknown __((int c));
extern void LEXinit __((void));
extern int yylex __((void));
extern int yylook __((void));
extern int yyback __((int *p, int m));
extern int yyinput __((void));
extern int yyoutput __((int c));
extern int yyunput __((int c));

#if defined(__cplusplus)
}
#endif


#undef __
