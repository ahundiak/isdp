/*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^*/
/* class.c - support of classes						*/
/*									*/
/* Object PreProcessor (opp)						*/
/* Paul L. Hammond							*/
/* Aug 21, 1986								*/
/*									*/
/* This file was added for opp/om v4.0					*/
/*									*/
/*vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv*/

#include <string.h>
#include "class.h"
#include "../opp/y.tab.h"
#include "oppmalloc.h"
#include "carriers.h"
#include "oppydefs.h"
#include "opp.h" /* for opping_for_discos */
#include "hiersymtab.h"
#include "oppface.h"

struct opp_class_def *new_class (name)
 char *name;
 {
  struct opp_class_def *c;

  c = (struct opp_class_def *) malloc (sizeof (*c) + strlen (name) + 1);

  c->name = strcpy ((char *)(c + 1), name);
  c->instance_fields = 0;	/* linked by "link" */
  c->messages = 0;		/* linked by "link" */
  c->message_count = 0;
  c->sym_tab = 0;		/* all non-tag symbols known by class */
  c->tag_tab = 0;		/* all tag symbols known by class */
  c->define_tab = 0;		/* cpp macros */
  c->omdef_tab = 0;		/* omdef macros */
  c->filename_tab = 0;	/* included files */
  c->flags = 0;		/* ??? */
  c->parent_count = 0;	/* dimension of A_parents */
  c->A_parents = 0;	/* array of parent classes */
  c->major_version = 0; 
  c->minor_version = 0;

  c->override_list = 0;
  c->component_list = 0;
  c->component_count = 0;

  c->indexed_enum_list = 0;
  c->next_enum_index = 0;

  c->basic_sharing.list = 0;
  c->basic_sharing.count = 0;

  c->struct_sharing.list = 0;
  c->struct_sharing.count = 0;

  c->enum_sharing.list = 0;
  c->enum_sharing.count = 0;

  c->share_list = 0;
  c->dcltr_count = 0;

  c->phantom_count = 0;
  c->reject_list = 0;
  c->inherited_methods = 0;

  return c;
 } /* new_class */

void attach_tables (cl1, cl2)
 struct opp_class_def *cl1, *cl2;
 {
#define ATTACH_ONE(TAB) \
   hiersymtab_attach ((hiersymtab_ptr)cl1->TAB, cl2->TAB);\

  ATTACH_ONE (sym_tab); 
  ATTACH_ONE (tag_tab); 
  ATTACH_ONE (define_tab); 
  ATTACH_ONE (omdef_tab); 
  ATTACH_ONE (filename_tab);
#undef ATTACH_ONE
 } /* attach_tables */

void hook_up_parents (cl, car)
 struct opp_class_def *cl;
 carrier_ptr car;
 {
  carrier_ptr cp = 0;
  int i, parent_count = 0;

#ifdef DEBUG
  printf ("hook_up_parents\n");
#endif

  if (!car) return;

  /* reverse list of parent classes */
  while (car)
   {
    carrier_ptr next_car = car->next;
    car->next = cp;
    cp = car;
    car = next_car;
    ++parent_count; 
   }

  cl->parent_count = parent_count;
  cl->A_parents = (struct opp_class_def **) malloc(sizeof(*cl->A_parents)*parent_count);
  for (i = 0; cp; ++i)
   {
    carrier_ptr next_cp = cp->next;
    {
     identifier_ptr s = cp->cargo;

     lookup_class (s->s.s.name, &s->classdef);

     attach_tables (cl, s->classdef);

     if (s->s.tok == IDENTIFIER)
      {/* substitute class symbol from class */
       s = (identifier_ptr)lookup_symbol (s->classdef->sym_tab, s->s.s.name);
       remove_symbol (cl->sym_tab, cp->cargo);
       /* free (cp->cargo); */
       if (s) cp->cargo = s;
      }
    }
    cl->A_parents[i] = (struct opp_class_def *)cp->cargo;
#ifdef DEBUG
    printf (" parent is %s\n", cp->cargo->s.s.name);
#endif
    free (cp);
    cp = next_cp;
   }
 } /*  hook_up_parents */

