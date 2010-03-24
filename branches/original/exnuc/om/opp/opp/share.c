
/*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^*/
/* share.c - support for shared dcltrs.					*/
/*									*/
/* Object PreProcessor - opp						*/
/* Paul L. Hammond							*/
/* January 31, 1986							*/
/*									*/
/* Global Functions :							*/
/*	share_type		*/
/*	share_dcltrs			*/
/*	dump_dcltrs			*/
/*									*/
/*vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv*/
#define NULL 0
#include "oppmalloc.h"
#include "share.h"
#include <stdio.h>
#include "opp.h"
#include "typeinfo.h"
#include "class.h"
#include "oppy.h"
#include "identifier.h"
#include "dcltrs.h"
#include "odinsup.h"

void delete_sharing (shares)
 struct share_descr shares;
 {
  while (shares.list)
   {
    struct terminal_type_info *t = shares.list->next;
    free (shares.list);
    shares.list = t;
   }
 } /* delete_sharing */

struct terminal_type_info *share_type (typ, p, p_shares)
 int typ;
 identifier_ptr p;
 struct share_descr *p_shares;
 {
  register struct terminal_type_info **pt = 0, *t;

  if (!p || p->s.tok != CHANNEL_NAME)
   {
    for (pt= &p_shares->list; *pt; pt= &(*pt)->next)
     if (((*pt)->typ == typ) && ((*pt)->sym == p)) return *pt;
   }

  t = (struct terminal_type_info *) malloc(sizeof (struct terminal_type_info));
  t->typ = typ;
  t->sym = p;
  t->next = 0;

  if (p && p->s.tok == CHANNEL_NAME)
   t->index = 0;
  else
   {
    t->index = p_shares->count++;
    *pt = t;
   }

  return t;
 } /* share_type */

static void dump_basic_terminals ()
 /* Dumps basic dcltrs from active_class->basic_sharing.list into oppout. */
 {
  static char size_of_basic_type []=  /* indexed by "oppdecldef.h" */
   {sizeof (int), sizeof (long), sizeof (short), sizeof (unsigned),
    sizeof (unsigned long), sizeof (unsigned short), sizeof (float),
    sizeof (double), sizeof (char)};

  static char allignment_of_basic_type [] =  /* indexed by "oppdecldef.h" */
   {sizeof (int), sizeof (long), sizeof (short), sizeof (unsigned),
    sizeof (unsigned long), sizeof (unsigned short), sizeof (float),
    sizeof (int)/*double*/, sizeof (char)};

  register struct terminal_type_info *t;

  if (!(t = active_class->basic_sharing.list)) return;

  fprintf (oppout, 
	  "static struct OM_basic_dcltr OPPbasic_dcltr_index[] =\n {\n");

  for (; t; t=t->next)
   fprintf (oppout, "  { %d, %d, %d },\n",
	    t->typ, 
            allignment_of_basic_type [t->typ],
            size_of_basic_type [t->typ]);

  fprintf (oppout, " };\n");
 } /* dump_basic_terminals */

static void dump_struct_terminals ()
 /* Dumps struct terminal dcltrs from active_class->struct_sharing.list into oppout. */
 {
  register struct terminal_type_info *t;

  if (!(t = active_class->struct_sharing.list)) return;

  fprintf (oppout, 
	  "static struct OM_composite_dcltr OPPstruct_dcltr_index[] =\n {\n");

  for (; t; t=t->next)
   fprintf (oppout, "  { %d, %d, 0, &OPPindexed_struct[%d] },\n",
	    t->typ, 4/*type_allignment (s->type_info)*/, t->sym->index);

  fprintf (oppout, " };\n");
 } /* dump_struct_terminals */

static void dump_enum_terminals ()
 /* Dumps enum dcltrs from active_class->enum_sharing.list into oppout. */
 {
  register struct terminal_type_info *t;

  if (!(t = active_class->enum_sharing.list)) return;

  fprintf (oppout, 
	  "static struct OM_enum_dcltr OPPenum_dcltr_index[] =\n {\n");

  for (; t; t=t->next)
   fprintf (oppout, 
 	    "  { %d,0,0, &OPPindexed_enum[%d] },\n",
	    OM_enum,
	    t->sym->index);

  fprintf (oppout, " };\n");
 } /* dump_enum_terminals */

static dcltr_ptr share_dcltr (newd, term)
 dcltr_ptr newd;
 struct terminal_type_info *term;
 {
  register struct sharing **p;

  for (p = &active_class->share_list; *p; p= &(*p)->next)
   if ((*p)->term == term && equal_dcltr (newd, (*p)->d))
    {
     while (newd && newd->index == -1)
      {
       struct dcltr *d = newd->next;
       freedcltr (newd);
       newd = d;
      }
     return (*p)->d;
    }

  *p = (struct sharing *) malloc (sizeof (struct sharing));
  (*p)->term = term;
  (*p)->d = newd;
  (*p)->next = 0;

  newd->index = active_class->dcltr_count++;
  return newd;
 } /* share_dcltr */

void share_dcltrs (d, term)
 dcltr_ptr *d;
 struct terminal_type_info *term;
 {
  if (!*d || (*d)->index >= 0) return;

  share_dcltrs (&(*d)->next, term);

  *d = share_dcltr (*d, term);

 } /* share_dcltrs */

static void dump_non_terminals ()
 {
  register struct sharing *sh;

  if (!(sh = active_class->share_list)) return;

  fprintf (oppout, 
  	   "static struct OM_non_terminal_dcltr OPPdcltr_index[] =\n {\n");

  for (; sh; sh=sh->next)
   {
    register dcltr_ptr t = sh->d;
    int dcltr_type;

    switch (t->type)
     {
      case dt_array    : dcltr_type = OM_array;    break;
      case dt_pointer  : dcltr_type = OM_pointer;  break;
      case dt_function : dcltr_type = OM_function; break;
      case dt_varray   : dcltr_type = OM_varray;   break;
      case dt_bitfield : dcltr_type = OM_bitfield; break;
      default          : dcltr_type = 0;   	   break;
     }
  
    /* fix allignment later */
    fprintf (oppout, "  { %d, 4, %d,",dcltr_type, t->size);
    lookup_dcltr (t->next, sh->term);
    fprintf (oppout, "  },\n");
   }
  fprintf (oppout, " };\n");

 } /* dump_non_terminals */

void dump_dcltrs ()
 {
  dump_basic_terminals ();
  dump_struct_terminals ();
  dump_enum_terminals ();
  dump_non_terminals ();
 } /* dump_dcltrs */

void delete_dcltr_sharing (share_list)
 struct sharing *share_list;
 {
  while (share_list)
   {
    struct sharing *p = share_list->next;
    freedcltr (share_list->d);
    free (share_list);
    share_list = p;
   }
  } /* delete_dcltr_sharing */
