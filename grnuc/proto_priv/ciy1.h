#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/pplsrc/cci/ciy.c */
extern int yywrap __((void));
extern int YYinit __((void));
extern int yyerror __((char *s));
extern int YYlegal __((PCIcontext *c));
extern int ENDexp __((void));
extern int yyparse __((void));

#if defined(__cplusplus)
}
#endif


#undef __
