/*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^*/
/* usagetab.c - usage-recording symbol table. - subclass of hiersymtab	*/
/*									*/
/* Object PreProcessor - opp						*/
/* Paul L. Hammond							*/
/* December 11, 1986							*/
/*									*/
/* Records all symbols found by successfull lookup operations.		*/
/* New tables are initialy in the non-recording state.			*/
/* When in this state, behavior is same as hiersymtab.			*/
/*									*/
/* Overridden symtab Methods :						*/
/*  lookup_symbol	   - records symbol if found			*/
/*  lookup_local_symbol	   - records symbol if found 			*/
/*									*/
/* If the table is in a write protected state, the actions		*/
/* listed for remove and decrement will be omitted.			*/
/*									*/
/* New Methods :							*/
/*  record		   - all subsequent lookups are recorded	*/
/*  usage		   - gets usage list and turns off recording	*/
/*  owner		   - report owner				*/
/*									*/
/* NOTE : Recording is intended to be used with quiescent symbol table.	*/
/*	  If symbols are removed or level decremented, usage list may	*/
/*	  contain symbols which are no longer in the table and may have */
/*	  been deallocated.						*/
/*vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv*/
#include "usagetab.cl"
#include <string.h>
#include "oppmalloc.h"

#define RECORD_IT(OWNER) \
  {\
   register struct table_usage *u;\
   u = (struct table_usage *)lookup_symbol (st->usage_list, name);\
   if (!u || u->sym != s)\
    { /* record used symbol */\
     u = (struct table_usage *) calloc (1, sizeof (*u));\
     u->s = *s;\
     u->sym = s;\
     u->owner = (char *)(OWNER);\
     (void)enter_symbol (st->usage_list, u);\
    }\
  }

static symbol_ptr lookup_sym (st, name)
 struct usagetab *st;
 char  	*name;
 {
  register symbol_ptr s = 0;
  register struct usagetab *t;

  if (st->parent.log)
   fprintf (st->parent.log, ">usagetab_lookup %x \"%s\"\n", st, name);

  for (t = st; t; t = (struct usagetab *) t->parent.next)
   if (s = lookup_symbol (t->parent.tab, name)) break;

  if (s && t->recording_enabled) RECORD_IT (t->owner);

  if (st->parent.log) 
   fprintf (st->parent.log, "<usagetab_lookup %x \"%s\" %x\n", st,name, s);

  return s;
 } /* lookup_sym */

static symbol_ptr lookup_local_sym (st, name)
 struct usagetab *st;
 char  	*name;
 {
  register symbol_ptr s;
  
  if (st->parent.log)
   fprintf (st->parent.log, ">usagetab_lookup_local %x \"%s\"\n", st, name);

  s = lookup_local_symbol (st->parent.tab, name);

  if (s && st->recording_enabled) RECORD_IT (st->owner);

  if (st->parent.log) 
   fprintf (st->parent.log, "<usagetab_lookup_local %x \"%s\" %x\n",st,name,s);

  return s;
 } /* lookup_local_sym */

static void free_it (s) /* used because "free" may be a macro */
 char *s;
 {
  free (s);
 } /* free_it */

static void delete_sym_table (st, dealloc)
 struct usagetab *st;
 void (*dealloc)();
 {
  struct usagetab *t;
  FILE *f;

  if (f = st->parent.log) fprintf (f, ">usagetab_delete %x\n", st);

  if (!(st->parent.flags & F_SYMTAB_NOWRITE))
   {
    for (t = st; t; t = (struct usagetab *) t->parent.next) if (t->usage_list)
     {
      delete_symbol_table (t->usage_list, free_it);
      t->usage_list = 0;
      t->recording_enabled = 0;
     }
  
    hiersymtab_class.parent.delete (st, dealloc);
   } 

  if (f) fprintf (f, "<usagetab_delete %x\n", st);
 } /* delete_sym_table */

static struct usagetab *copy_tab (st, st2)
 struct usagetab *st, *st2;
 {
  struct usagetab *st3;

  if (!st) return st2;

  st3 = (struct usagetab *) calloc (1, sizeof(*st3));
  *st3 = *st;

  st3->parent.flags = 0;
  st3->parent.next = (struct hiersymtab *)copy_tab ((struct usagetab *) st->parent.next, st2);
  st3->recording_enabled = 0;
  st3->usage_list = 0;

  return st3;
 } /* copy_tab */

static void attach_table (st, st2)
 struct usagetab *st, *st2;
 {
  if (st->parent.log)
   fprintf (st->parent.log, ">usagetab_attach %x : %x\n", st, st2);

  if (st->parent.flags & F_SYMTAB_NOWRITE) return;

  st->parent.next = (struct hiersymtab *)copy_tab (st2, (struct usagetab *) st->parent.next);

  if (st->parent.log)
   fprintf (st->parent.log, "<usagetab_attach %x : %x\n", st, st->parent.next);
 } /* attach_table */

static struct table_usage *usage_list;

static void add_to_list (s)
 struct table_usage *s;
 {
  if (!usage_list)
   {
    s->s.next = (struct symbol *)s;
    usage_list = s;
   }
  else
   {
    s->s.next = usage_list->s.next;
    usage_list->s.next = (struct symbol *)s;
   }
 } /* add_to_list */

static struct table_usage *get_usage_list (st)
 struct usagetab *st;
 {
  struct usagetab *t;

  if (st->parent.log) fprintf (st->parent.log, ">usagetab_usage %x\n", st);

  usage_list = 0;

  if (st->usage_list) delete_symbol_table (st->usage_list, add_to_list);

  for (t = st; t; t = (struct usagetab *) t->parent.next)
   {
    t->usage_list = 0;
    t->recording_enabled = 0;
   }

  if (st->parent.log)
   fprintf (st->parent.log, ">usagetab_usage %x : %x\n", st, usage_list);

  return usage_list;
 } /* get_usage_list */

static char *get_owner (st)
 struct usagetab *st;
 {
  return st->owner;
 } /* get_owner */

static void recording_on (st, mode, hashlength)
 struct usagetab *st;
 int mode; /* 0 - just ancestors. 1 - all tables */
 int hashlength; /* for recording tables */
 {
  struct usagetab *t;

  if (st->parent.log)
   fprintf (st->parent.log, ">usagetab_recording %x : %d\n", st, mode);

  for (t = mode ? st : (struct usagetab *) st->parent.next; t;
       t = (struct usagetab *) t->parent.next)
   t->recording_enabled = 1;

  st->usage_list = new_basictab (hashlength, st->parent.log);

  if (st->parent.log)
   fprintf (st->parent.log, "<usagetab_recording %x\n", st);
 } /* recording_on */

static int usagetab_initialized = 0;

struct usagetab_class usagetab_class = {0};

void usagetab_class_init ()
 {
  if (usagetab_initialized) return;

  usagetab_initialized = 1;

  hiersymtab_class_init ();

  usagetab_class.parent = hiersymtab_class; /* inherit methods */

  /* override symtab messages */
  usagetab_class.parent.parent.delete       = delete_sym_table;
  usagetab_class.parent.parent.lookup	    = lookup_sym;
  usagetab_class.parent.parent.lookup_local = lookup_local_sym;

  /* override hiersymtab messages */
  usagetab_class.parent.attach	= attach_table;

  /* new methods */
  usagetab_class.usage  = get_usage_list;
  usagetab_class.owner  = get_owner;
  usagetab_class.record = recording_on;
 }

usagetab_ptr new_usagetab (hashlength, log, owner)
 int hashlength;
 FILE *log;
 char *owner;
 {
  struct usagetab *st = (struct usagetab *) calloc (1, sizeof(*st));

  if (log) fprintf (log, ">new_usagetab %x : %d %x\n", st, hashlength, owner);

  if (!usagetab_initialized) usagetab_class_init ();

  st->parent.send = (struct hiersymtab_class *) &usagetab_class;
  st->parent.log = log;
  st->parent.flags = 0;
  st->parent.tab = new_basictab (hashlength, log);
  st->parent.next = 0;
  st->usage_list = 0;
  st->recording_enabled = 0;
  st->owner = owner;

  if (log) fprintf (log, "<new_usagetab %x : %d %x\n", st, hashlength, owner);
  return (usagetab_ptr) st;
 } /* new_usagetab */
