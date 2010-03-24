
/*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^*/
/* identifier.c - support routines for identifier tokensyms		*/
/*									*/
/* Object PreProcessor - opp						*/
/* Paul L. Hammond							*/
/* March 20, 1986							*/
/*									*/
/* Global Functions :							*/
/*	new_identifier- allocation and initialization function		*/
/*	append_fields - appends a list of symbol records to the end of  */
/*			another list linked by "link".			*/
/*	reverse_fields- reverses a list of symbols linked by "link".	*/
/*	free_link     - frees a list of symbols linked by "link".	*/
/*      process_purged_identifier - reinserts purged symbols		*/
/*									*/
/*vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv*/
#define NULL 0
#include <stdio.h>
#include <string.h>
#include "identifier.h"
#include "oppy.h"
#include "lexinput.h"
#include "dcltrs.h"
#include "class.h"
#include "oppmalloc.h"

symtab_ptr sym_table, tag_table;

identifier_ptr append_fields (new, old)
 identifier_ptr new, old;
 {
  identifier_ptr s;

  if (!old) return new;

  s = old;
  while (s->link) s = s->link;
  s->link = new;

  return old;
 } /* append_fields */

void reverse_fields (m)
 identifier_ptr *m;
 {
  identifier_ptr b, a = *m;
  *m = NULL;

  while (a)
   {
    b = a->link;
    a->link = *m;
    *m = a;
    a = b;
   }

 } /* reverse_fields */

void free_link (s)
 identifier_ptr s;
 {
  while (s)
   {
    register identifier_ptr next_s = s->link;
/*
    free_dcltr (s->type_info.dcltr_link);
*/
    free (s);
    s = next_s;
   }
 } /* free_link */ 

identifier_ptr new_identifier (name)
 char *name;
 {
  identifier_ptr s;

  s = (identifier_ptr) malloc (sizeof(*s) + strlen(name) + 1);
  s->s.s.name = strcpy ((char *)(s+1), name);
  s->s.tok = IDENTIFIER;
  s->subtype = 0; /* unused */
  s->link = NULL;
  s->field_link = NULL;
  s->classdef = active_class;
  s->copy_of_me = NULL;
  s->type_info = empty_type;
  s->index = -1;
  s->flags = 0;
  
  return s;
 } /* new_identifier */

identifier_ptr new_phantom_identifier (cls)
 struct opp_class_def *cls;
 {
  char name [40];
  identifier_ptr p;

  sprintf (name, "%s_Phantom%d", cls->name, cls->phantom_count++);

  p = new_identifier (name);
  p->flags |= F_IDENTIFIER_PHANTOM;
  return p;
 } /* new_phantom_identifier */

void process_purged_identifier (s)
 identifier_ptr s;
 {
  char *text;

  switch (s->s.tok)
   {
    case STRUCT_NAME : text = "struct"; break;
    case UNION_NAME  : text = "union";  break;
    default : return;
   }

  if (!s->field_link) enter_prehashed_symbol (tag_table, s);
 } /* process_purged_identifier */

