
/*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^*/
/* functions.c - functions related to C function declarations		*/
/*		 in class implementation files.				*/
/*									*/
/* Object ProProcessor - opp						*/
/* Paul L. Hammond							*/
/* October 1985								*/
/*									*/
/* Global functions defined in this file :				*/
/* 	verify_function     - verifies that the formal parameters	*/
/*			      coincide with the parameter declarations. */
/*			      Writes the function header and provides a */
/*			      message buffer for sends.			*/
/*	end_function	    - Called when function body is complete.    */
/*	declaring_function_parameter - Called for each parameter	*/
/*				       between header and block.	*/
/*vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv*/

#define NULL 0
#include <stdio.h>
#include <cppout.h>
#include "oppmalloc.h"
#include "identifier.h"
#include "oppy.h"
#include "opp.h"
#include "dcltrs.h"
#include "lex3.h"
#include "char_st.h"
#include "fio.h"
#include "lexinput.h"
#include "dumpmessage.h"

void verify_function (f, p)
 identifier_ptr *f; /* function */
 identifier_ptr *p; /* parameter declarations */
 {
  register identifier_ptr m;
  extern int found_argsused;

  /* First ... verify that formal parameters and their declarations coincide. */

  /* Write function header */
  if (found_argsused)
   {
    fprintf(oppout, "/* ARGSUSED */\n");
    ++cur_out_line;
    found_argsused = 0;
   }
  cur_out_line += 1 + dump_arg (oppout, *f);
  fprintf (oppout, "\n");

  if (!(*f)->type_info.dcltr_link)
   {
    printerr (1);
    fprintf (stderr, " missing semicolon on previous line.\n");
    file_traceback ();
    return;
   }
  for (m = params_of_function_dcltr (*f); m; m= m->link)
   {
    register identifier_ptr m1 = (identifier_ptr)lookup_local_symbol (sym_table, m->s.s.name);
    if (m1)
     {
      fprintf (oppout, "  ");
      cur_out_line += 1 + dump_arg (oppout, m1);
      mark_symbol_written(m1);
      fprintf (oppout, ";\n");
     }
    /*else
     {
      printerr (1);
      fprintf (stderr, " formal parameter \"%s\" is not given a type.\n",
               m->s.s.name);
      file_traceback ();
     }*/
   }
  /* any unwritten declared parameters are garbage */
  for (m = *p; m; m = m->link)
   if (!(m->flags & F_IDENTIFIER_WRITTEN))
    {
     printerr (1);
     fprintf (stderr, " item declared is not a parameter.\n");
     fprintf (stderr, " - \"");
     dump_arg (stderr, m);
     fprintf (stderr, "\"\n");
     file_traceback ();
    }

  fprintf (oppout, " {\n");
  ++cur_out_line;
 } /* verify_function */

/* This function is needed because "free" is sometimes a macro. */
static void free_it (p)
 identifier_ptr p;
 {
  if (p->s.tok == STRUCT_NAME || p->s.tok == UNION_NAME)
   while (p->field_link)
    {
     identifier_ptr next = p->field_link->link;
     free_it (p->field_link);
     p->field_link = next;
    }
   else
    {
     dcltr_ptr d = p->type_info.dcltr_link;
     while (d && d->index == -1)
      {
       dcltr_ptr next_d = d->next;
       freedcltr (d);
       d = next_d;
      }
    }
  free (p);
 } /* free_it */

void end_function (f)
 identifier_ptr f;
 {
  dcltr_ptr dp;
  identifier_ptr p;

  /* free formal parameter list */
  if ((dp = f->type_info.dcltr_link) && dp->type == dt_function)
   while (p = dp->params)
    {
     dp->params = p->link;
     free (p);
    }

  decrement_symbol_level (sym_table, free_it);
  decrement_symbol_level (tag_table, free_it);
 } /* end_function */

void declaring_function_parameter (type, dcltr_list)
 struct Type_Info type;
 identifier_ptr dcltr_list;
 {
  setlisttype (dcltr_list, type, VAR_NAME);
 } /* declaring_function_parameter */
