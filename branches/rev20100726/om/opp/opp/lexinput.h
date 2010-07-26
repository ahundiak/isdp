
/*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^*/
/* lexinput.h - handles input and imports for lex via yyin.		*/
/*									*/
/* Object PreProcessor - opp						*/
/* Paul L. Hammond							*/
/* March 21, 1986							*/
/*									*/
/*vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv*/
#ifndef LEXINPUT_INCLUDED
#define LEXINPUT_INCLUDED

extern int include_report;
extern int opp_error_count;

#if defined(__STDC__) || defined(__cplusplus)
#ifndef __
#define __(args) args
#endif
#else
#ifndef __
#define __(args) ()
#endif
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* lexinput.c */
int printerr __((int level));
int yyerror __((char *s));

#if defined(__cplusplus)
}
#endif

#endif /* LEXINPUT_INCLUDED */
/* End lexinput.h */
