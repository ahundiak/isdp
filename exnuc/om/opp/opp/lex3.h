
/*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^*/
/* opplex.h - lexical analyser for opp					*/
/* 									*/
/* Object Preprocessor - opp						*/
/* Paul L. Hammond							*/
/* March 21, 1986							*/
/* 									*/
/* This lexical analyser replaces that produced by the unix "lex".	*/
/* It is considerably (4X) faster and provides equivalent functionality.*/
/* 									*/
/*vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv*/
#ifndef OPPLEX_INCLUDED
#define OPPLEX_INCLUDED
#include <stdio.h>

#define YYTEXT_LENGTH 100

extern char *lex_filename;	/* pointer to filename of last tok */

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

/* lex3.c */
void lex_init_new_file __((void));
void process_percent __((void));
int yylex __((void));
void init_reserved_table __((void));

#if defined(__cplusplus)
}
#endif

#endif /* OPPLEX_INCLUDED */
/* End opplex.h */
