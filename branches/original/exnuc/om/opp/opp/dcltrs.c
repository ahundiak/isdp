/*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^*/
/* dcltrs.c - functions related to the processing of C declarators	*/ 
/*									*/
/* Object PreProcessor - opp						*/
/* Paul L. Hammond							*/
/* October 1985								*/
/*									*/
/* The dcltr struct is defined in identifier.h				*/
/*									*/
/* The global functions in this file are : 				*/
/*									*/
/*    append_dcltr         - appends a list of dcltr records to another */
/*			     list.					*/
/*    append_dcltr_copy    - appends a copy of a list of dcltr records  */
/*			     to another list of dcltr records.		*/
/*    append_pointer_dcltr - appends a pointer dcltr to a list of dcltr */
/*			     records.					*/
/*    append_array_dcltr   _ appends an array dcltr to a list of dcltr  */
/*			     records. 					*/
/*    append_function_dcltr- appends a function dcltr to a list of      */
/*			     dcltr records.			        */
/*									*/
/*    append_const_dcltr   - appends a const dcltr to a list of dcltr   */
/*                           records.                                   */
/*                                                                      */
/*    append_volatile_dcltr- appends a volatile dcltr to a list of dcltr*/
/*                           records.                                   */
/*                                                                      */
/*    dump_dcltr	   - prints a C declarator from a dcltr list	*/
/*			     attached to an identifier record.		*/
/*									*/
/*    free_dcltr	   - calls "free" with each member of list.     */
/*									*/
/*    setlisttype	   - sets the type_info and tok fields in a list */
/*			     of identifier records.			*/
/*									*/
/*    params_of_func_dcltr - given a identifier_ptr to a function, returns  */
/*			     list of parameter identifiers.		*/
/*									*/
/*    equal_dcltr	   - compares two dcltr lists for equivalence	*/
/*									*/
/*    messagefy_dcltrs	   - given a list of identifiers linked by "link"*/
/*			     convert all array dcltrs on them to pointer*/
/*			     dcltrs.					*/
/*									*/
/*vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv*/

#define NULL 0
#include "dcltrs.h"
#include "oppy.h"
#include "opp.h"
#include "class.h"
#include "identifier.h"
#include "oppmalloc.h"
#include "typeinfo.h"
#include "odinsup.h"
#include "lexinput.h"
#include "char_st.h"
#include "fio.h"
#include "dumpmessage.h"

int total_dcltr_count = 0;

#define new_dcltr() (dcltr_ptr)(total_dcltr_count++, malloc (sizeof (struct dcltr)))

#define freedcltr(d) (--total_dcltr_count, free (d))
/*
  A dcltr record represents either a pointer, an array or a function.
  Routines are provided to append any one of these to a list of dcltrs.
  These are:
   append_pointer_dcltr
   append_function_dcltr
   append_array_dcltr
  each of which calls append_dcltr.

  Each of these functions return a pointer to the resulting list.
*/
  
dcltr_ptr append_dcltr (new, old)
 dcltr_ptr new, old;
 /*
  "new" list of dcltr structs linked by "next"
   is appended to the far end of the "old" list.
   Either list may be empty (NULL).
   Pointer to the resulting list is returned.
 */
 {
  register dcltr_ptr o;

#ifdef DEBUG
  fprintf (stderr, " append_dcltr\n");
#endif
  if (!old) return new; /* That was easy. */

  o = old;
  while (o && o->next) o = o->next; /* find end of old list */
  o->next = new; /* append new list */
  return old;
 } /* append_dcltr */

dcltr_ptr append_dcltr_copy (new, old)
 dcltr_ptr new, old;
 /* Same as append_dcltr (above) except the new list is copied first */
 /* This may not be required - plain append may be fine also will save space. */
 {
  register dcltr_ptr newc=NULL;/* pointer to copy of "new" list */
  register dcltr_ptr n;        /* temporary pointer */
  register dcltr_ptr n1 = 0;   /* pointer to last element in newc list */

#ifdef DEBUG
  fprintf (stderr, " append_dcltr_copy\n");
#endif

  /* copy "new" list to "newc" list - maintain order */
  while (new)
   {
    n = new_dcltr();;
    *n = *new;
    n->index = -1;
    n->next = NULL;
    if (newc)
     n1->next = n;
    else
     newc = n;
    n1 = n;

    new = new->next;
   }

  return append_dcltr (newc, old);
 } /* append_dcltr_copy */

dcltr_ptr append_bitfield_dcltr (old, width)
 dcltr_ptr old;
 int width;
 /* Bitfields are appended to the front of the list rather than the back */
 {
  register dcltr_ptr d = new_dcltr();

  d->index = -1;
  d->type = dt_bitfield;
  d->next = old;
  d->size = width;

  return d;
 } /* append_bitfield_dcltr */

dcltr_ptr append_pointer_dcltr (old)
 dcltr_ptr old; /* The list to which a pointer dcltr will be appended */
 {
  register dcltr_ptr star;

#ifdef DEBUG
  fprintf (stderr, " append_pointer_dcltr\n");
#endif
  star = new_dcltr();
  star->index = -1;
  star->next = NULL;
  star->type = dt_pointer;
  star->params = NULL;
  star->size = 4;
  return append_dcltr (star, old);
 } /* append_pointer_dcltr */

dcltr_ptr append_const_dcltr (old)
 dcltr_ptr old; /* The list to which a const dcltr will be appended */
 {
  register dcltr_ptr star;

#ifdef DEBUG
  fprintf (stderr, " append_const_dcltr\n");
#endif
  star = new_dcltr();
  star->index = -1;
  star->next = NULL;
  star->type = dt_const;
  star->params = NULL;
  star->size = 0;
  return append_dcltr (star, old);
 } /* append_const_dcltr */

dcltr_ptr append_volatile_dcltr (old)
 dcltr_ptr old; /* The list to which a volatile dcltr will be appended */
 {
  register dcltr_ptr star;

#ifdef DEBUG
  fprintf (stderr, " append_volatile_dcltr\n");
#endif
  star = new_dcltr();
  star->index = -1;
  star->next = NULL;
  star->type = dt_volatile;
  star->params = NULL;
  star->size = 0;
  return append_dcltr (star, old);
 } /* append_volatile_dcltr */

dcltr_ptr append_array_dcltr (old, size)
 dcltr_ptr old;
 int size;
 {
  register dcltr_ptr star;

#ifdef DEBUG
  fprintf (stderr, " append_array_dcltr\n");
#endif
  star = new_dcltr();
  star->index = -1;
  star->next = NULL;
  star->type = dt_array;
  star->params = NULL;
  star->size = size;
  return append_dcltr (star, old);
 } /* append_array_dcltr */

dcltr_ptr append_function_dcltr (old, params)
 dcltr_ptr old;
 identifier_ptr params;
 {
  register dcltr_ptr star;

#ifdef DEBUG
  fprintf (stderr, " append_function_dcltr\n");
#endif
  star = new_dcltr();
  star->index = -1;
  star->next = NULL;
  star->type = dt_function;
  reverse_fields (&params);
  star->params = params;
  star->size = 0;
  return append_dcltr (star, old);
 } /* append_function_dcltr */

static void dump_dcltr2 (afile, d)
 FILE *afile;
 register dcltr_ptr d;
 {
  if (d)
   {
    switch (d->type)
     {
      case dt_pointer :
       if (d->next && (d->next->type != dt_pointer) &&
          (d->next->type != dt_const) && (d->next->type != dt_volatile))
          fprintf (afile, ")");
      break;
      case dt_array :
        if (d->size)
	 fprintf (afile, "[%1d]", d->size);
	else
	 fprintf (afile, "[]");
      break;
      case dt_function :
       {
        register identifier_ptr fp; /* for formal parameters */

	fprintf (afile, "(");
	for (fp = d->params; fp; fp = fp->link)
	 {
          dump_arg(afile, fp);
	  /*fprintf (afile, "%s", fp->s.s.name);*/
	  if (fp->link) fprintf (afile, ",");
	 }
	fprintf (afile, ")");
       }
      break;
      default : break;
     }
    if (d->type != dt_varray) dump_dcltr2 (afile, d->next);
    if (d->type == dt_bitfield) fprintf (afile, ":%d", d->size);
   }
 } /* dump_dcltr2 */

static void dump_dcltr1 (afile, d, inclosed_by_pointer)
 FILE *afile;
 register dcltr_ptr d;
 int inclosed_by_pointer;
 {
  if (d)
   {
    if (d->type != dt_varray)
     dump_dcltr1 (afile, d->next, d->type == dt_pointer);
    switch (d->type)
     {
      case dt_const :
         fprintf (afile, "const ");
      break;
      case dt_volatile :
         fprintf (afile, "volatile ");
      break;
      case dt_pointer :
	 fprintf (afile, "*");
      break;
      case dt_array :
         if (inclosed_by_pointer) fprintf (afile, "(");
      break;
      case dt_function :
         if (inclosed_by_pointer) fprintf (afile, "(");
      break;
      default : break;
     }
   }
 } /* dump_dcltr1 */

void dump_dcltr (afile, s)
 FILE *afile;
 identifier_ptr s;
 {
   register dcltr_ptr d = s->type_info.dcltr_link;

  
   dump_dcltr1 (afile, d, 0);
   fprintf (afile, "%s", s->s.s.name);
   dump_dcltr2 (afile, d);
#ifdef DEBUG
   while (d)
    {
     switch (d->type)
      {
       case dt_pointer : fprintf (stderr,"*");
       break;
       case dt_array : fprintf (stderr,"[]");
       break;
       case dt_function : fprintf (stderr,"()");
       break;
      }
     d=d->next;
    }
   fprintf(stderr,"\n");
#endif
 } /* dump_dcltr */

int equal_dcltr (d, d1)
 register dcltr_ptr d, d1;
 {
  while (d && d1)
   {
    if (d == d1) return 1;
    if (d->type != d1->type) return 0;
    switch (d->type)
     { 
      case dt_bitfield : case dt_varray : case dt_array :
       if (d->size != d1->size) return 0;
       break;
      case dt_function :
       if (d->params != d1->params) return 0;
       break;
     }
    d=d->next;
    d1=d1->next;
   }
  return !d && !d1;
 } /* equal_dcltr */

identifier_ptr params_of_function_dcltr (f)
 register identifier_ptr f;
 {
  if (!f->type_info.dcltr_link)
   {
    printerr (1);
    fprintf (stderr, " identifier \"%s\" should be a function.\n", f->s.s.name);
    file_traceback ();
    return NULL;
   }
  else if (f->type_info.dcltr_link->type != dt_function)
   {
    printerr (1);
    fprintf (stderr, " function \"%s\" must have parameter declaration.\n",
	     f->s.s.name);
    file_traceback ();
    return NULL;
   }
  else
   return f->type_info.dcltr_link->params;
 } /* params_of_function_dcltr */

/* free_dcltr should be called with care. */
/* Parts of dcltr lists are shared when   */
/* typedefs are used which have dcltrs.   */
void free_dcltr (d)
 register dcltr_ptr d;
 {
  dcltr_ptr next_d;
  while (d)
   {
    next_d = d->next;
    freedcltr (d);
    d = next_d;
   }
 }

/*
   The "setlisttype" function sets the type of
   each member in a list of identifier records.
   This type consists of two parts, a typeinfo
   record and a tokentype value which is one of
   FIELD_NAME, VAR_NAME, TYPEDEF_NAME, etc.

   These are stored in the type_info and tok
   fields of each identifier record in the list.

   This function is only loosely related to dcltrs
   and perhaps should be in another source file.
*/

void setlisttype (list, type, tok)
 identifier_ptr list;	/* List of identifier records */
 struct Type_Info type;
 int tok;
 {
  register identifier_ptr s; /* for list traversal */
  dcltr_ptr dp; /* temporary */

  /* Assign types to members of list. */
  /* Append type's dcltr list to the dcltr list on each member of "list". */
  /* This part of the dcltr list comes from a typedef and is shared by all*/
  /* members of "list" as well as by all other variables of the same type.*/
  if (type.std_class != variable_class)
   {
    struct identifier_symbol id;

    id.type_info = type;
    share_terminal_dcltr (&id);
    type.term = id.type_info.term;

    for (s=list; s; s=s->link)
     {
      s->flags &= ~F_IDENTIFIER_MARKED;
      dp = s->type_info.dcltr_link;
      s->type_info = type;
      s->type_info.dcltr_link = append_dcltr (type.dcltr_link, dp);
      s->s.tok = tok;
      share_dcltrs (&s->type_info.dcltr_link, type.term);
      if (s->copy_of_me)
       {
	s->copy_of_me->type_info.std_class = s->type_info.std_class;
	if (!equivalent_type (s->type_info, s->copy_of_me->type_info))
	 {
	  /*printerr (1);
	  fprintf (stderr, " inconsistent declaration of %s.\n", s->s.s.name);
	  file_traceback ();*/
	  s->copy_of_me->type_info.std_class = extern_class;
	 }
       }
     }
   }
  else
   { /* variable length array(s) */
    dcltr_ptr typedef_dcltr = NULL;
    identifier_ptr vla_struct;

    vla_struct = (identifier_ptr)lookup_symbol (tag_table, "OM_sd_varlenarr_descr");
    if (!vla_struct)
     {
      printerr (1);
      fprintf (stderr, "OM_sd_varlenarr_descr must be declared before VLA\n");
      file_traceback ();
     }

    type.std_class = noclass;

    if (type.dcltr_link)
     {
      /* make copy of type's dcltr list */
      typedef_dcltr = append_dcltr_copy (type.dcltr_link, typedef_dcltr);
     }
    for (s=list; s; s=s->link)
     {
      s->flags &= ~F_IDENTIFIER_MARKED;
      dp = s->type_info.dcltr_link;
      s->type_info = type;
      s->s.tok = tok;

      if (typedef_dcltr) dp = append_dcltr (typedef_dcltr, dp);

      s->type_info.dcltr_link = dp;

      if (dp && dp->type == dt_array)
       {
        dp->type = dt_varray;
       }
      else
       {
        printerr (1);
	fprintf (stderr, " \"variable\" instance fields must be arrays.\n");
	file_traceback ();
       }
      share_terminal_dcltr (s);
      share_dcltrs (&s->type_info.dcltr_link, s->type_info.term);

       {
        /* insert dummy field */
        char name [100], *pname;
	identifier_ptr t;

	strcpy (name, s->s.s.name);
	strcat (name, "_descr");
	t = new_identifier (name);
	pname = t->s.s.name;
	*t = *s;
	s->flags |= F_IDENTIFIER_DUMMY;
   	t->s.s.name = pname;
	t->type_info = empty_type;
	t->type_info.type_link = vla_struct;
	s->link = t;
        s = t;
       }
     }
   }
 } /* setlisttype */

void messagefy_dcltrs (s)
 register identifier_ptr s;
 {
  register dcltr_ptr d, p;

  for (;s; s=s->link)
   {
    if ((d = s->type_info.dcltr_link) && d->type == dt_array)
     {
      /* copy dcltr and convert */
      s->type_info.dcltr_link = p = new_dcltr();
      *p = *d;
      p->index = -1;
      p->type = dt_pointer;
     }
    else if (!d && s->type_info.typedefName)
     {
      /* if arg is a typedef and the typedef is an array, convert
         the type so it will be expanded into a pointer. */

      struct Type_Info t;
      carrier_ptr c;

      t = s->type_info;
      for (c = s->type_info.typedefName; c; c = c->next)
       t = merge_type_info (t, c->cargo->type_info, 0);
      if ((d = t.dcltr_link) && d->type == dt_array)
      {
       /* copy dcltr and convert */
       t.dcltr_link = p = new_dcltr();
       *p = *d;
       p->index = -1;
       p->type = dt_pointer;

       s->type_info = t;
       c = s->type_info.typedefName;
       if (c)
        {
         s->type_info.typedefName = c->next;
         free(c);
        }
       s->type_info.std_class = noclass;
      }
     }
   }
 } /* messagefy_dcltrs */

void report_dcltr ()
 {
  printf (" %d declarators allocated occupying %d bytes.\n", total_dcltr_count,
	total_dcltr_count * sizeof (struct dcltr));
 } /* report_dcltr */

int last_dcltr_is_ptr (p)
 dcltr_ptr p;
 {
  if (!p) return 0;

  while (p->next) p = p->next;

  return p->type == dt_pointer;
 } /* dcltr_has_ptr */
