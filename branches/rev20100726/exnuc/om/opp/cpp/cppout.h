/*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^*/
/* cppout.h - global declarations for cppout.c				*/
/*									*/
/* Paul L. Hammond							*/
/* March 10, 1987							*/
/*vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv*/
#ifndef CPPOUT_INCLUDED
#define CPPOUT_INCLUDED

#include "tok.h"

extern int cur_out_line; /* current line in output file */
extern int last_line;    /* previous source line transfered to output */ 
extern char *last_file;  /* source of previous token transfered to output */

#define PITS(A,B) {char *c=B; while (*c) {putc (*c,A); if (*(c++) == '\n') { cur_out_line++; last_line++; } } }

#define MARKIT \
 if (emit_lines) \
  { \
   fprintf (oppout,"\n#line %d \"%s\"\n",last_line,convert_filename(last_file));\
   cur_out_line+=2; \
  }
 
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

/* cppout.c */
char *convert_filename __((char *name));
void get_to_line __((FILE *oppout, int line, char *name));
void output_tok __((FILE *oppout, struct cpp_token *ta));
void oat __((FILE *oppout));
#ifdef WIN32
extern void fdumpitf (FILE *oppout, char *fmt, ...);
extern void rdumpitf (char *filename, int line_no, FILE *oppout, char *fmt, ...);
#else
void fdumpitf __((FILE *oppout, char *fmt, ...));
void rdumpitf __((char *filename, int line_no, FILE *oppout, char *fmt, ...));
#endif
void suspend __((void));
void restore __((void));
void merge __((FILE *filea, FILE *fileb));

#if defined(__cplusplus)
}
#endif

#if defined(CLIX) || defined(SUNOS) || defined(IRIX)
#define convert_filename(F)	F
#endif

#endif /* CPPOUT_INCLUDED */
