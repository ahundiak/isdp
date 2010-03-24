
/*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^*/
/* lexinput.c - handles input and imports for lex. 			*/
/*									*/
/* Object PreProcessor - opp						*/
/* Paul L. Hammond							*/
/* October 1985								*/
/*									*/
/* Global functions :							*/
/* 	printerr	- prints error header on stderr			*/
/*	yywrap		- called by lex when end of file is found	*/
/*			  continues with previous file (if any).	*/
/*	yyerror		- called by yacc when a syntax error is found	*/
/*									*/
/* Global Variables :							*/
/*	include_report	- if true, a report is sent to stderr of all	*/
/*			  imported class activities.			*/
/*	opp_error_count - count of calls to printerr			*/
/*vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv*/

#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include "lexinput.h"
#include "identifier.h"
#include "opp.h"
#include "oppy.h"
#include "lex3.h"
#include "cpp.h"
#include "fio.h"

/* Global Variable Definitions */
int include_report = 0;
int opp_error_count = 0;

int printerr (level)
 int level;
 {
  fprintf (stderr, "\"%s\", line %1d:",lex_filename,active_stream->tok.line_no);
  switch (level)
   {
    case 0 :
     fprintf (stderr, "warning:");
     break;
    case 2 :
     fprintf (stderr, "fatal:");
   
    default : opp_error_count++;
   }
  return 0;
 } /* printerr */

int yyerror (s)
 char *s;
 {
  printerr (1); fprintf (stderr, "%s\7\n",s);
  file_traceback ();
  return 0;
 }
