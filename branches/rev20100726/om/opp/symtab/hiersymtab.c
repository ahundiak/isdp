
/*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^*/
/* hiersymtab.c - hierarchical symbol table manipulations		*/
/*									*/
/* Object PreProcessor - opp						*/
/* Paul L. Hammond							*/
/* November 3, 1986							*/
/*									*/
/* Global Functions :							*/
/*  new_hiersymtab         - allocates symbol table and returns pointer */
/*									*/
/* Methods :								*/
/*  lookup_symbol	   - returns pointer - NULL if not found	*/
/*  lookup_local_symbol	   - only looks in current level		*/
/*									*/
/*  enter_symbol							*/
/*  enter_prehashed_symbol - must have been previously entered		*/
/*									*/
/*  remove_symbol	   - no effect if not there			*/
/*									*/
/*  increment_symbol_level - enters new local scope			*/
/*  decrement_symbol_level - purges symbols and passes back for disposal*/
/*									*/
/*  delete_symbol_table    - purges all symbols down to level etc.	*/
/*									*/
/*  process_symbol_table   - applies a function to all members		*/
/*									*/
/* All common declarations relating to symbol table are in symtab.cls.	*/
/*									*/
/*vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv*/

#include "hiersymtab.cl"
#include "basictab.h"
#include <string.h>
#include "oppmalloc.h"

static symbol_ptr lookup_sym (st, name)
 struct hiersymtab *st;
 char  	*name;
 {
  register symbol_ptr s = 0;
  register struct hiersymtab *t;

  if (st->log) fprintf (st->log, ">hier_lookup_sym %x \"%s\"\n", st, name);

  for (t = st; t; t = t->next)
   if (s = lookup_symbol (t->tab, name)) break;

  if (st->log) fprintf (st->log, "<hier_lookup_sym %x \"%s\" %x\n", st,name, s);

  return s;
 } /* lookup_sym */

static symbol_ptr lookup_local_sym (st, name)
 struct hiersymtab *st;
 char  	*name;
 {
  if (st->log) fprintf (st->log, "hier_lookup_local_sym \"%s\"\n", name);

  return lookup_local_symbol (st->tab, name);
 } /* lookup_local_sym */

static void enter_prehashed_sym (st, s)
 struct hiersymtab *st;
 symbol_ptr s;
 {
  if (st->flags & F_SYMTAB_NOWRITE) return;

  enter_prehashed_symbol (st->tab, s);
 } /* enter_prehashed_sym */

static void enter_sym (st, s)
 struct hiersymtab *st;
 symbol_ptr s;
 {
  if (st->flags & F_SYMTAB_NOWRITE) return;

  enter_symbol (st->tab, s);
 } /* enter_sym */

static void remove_sym (st, s)
 struct hiersymtab *st;
 symbol_ptr s;
 {
  if (st->flags & F_SYMTAB_NOWRITE) return;

  remove_symbol (st->tab, s);
 } /* remove_sym */

static void increment_sym_level (st)
 struct hiersymtab *st;
 {
  if (st->flags & F_SYMTAB_NOWRITE) return;
  if (st->log) fprintf (st->log, "(increment_symbol_level %x\n", st);
  increment_symbol_level (st->tab);
 } /* increment_sym_level */

static void decrement_sym_level (st, dealloc)
 struct hiersymtab *st;
 void (*dealloc)();
 {
  if (st->flags & F_SYMTAB_NOWRITE) return;
  if (st->log) fprintf (st->log, ")decrement_symbol_level %x\n", st);

  decrement_symbol_level (st->tab, dealloc);
 } /* decrement_sym_level */


/* The following static variables are used by
   "hier_process" with "process_sym_table". */
static symtab_ptr processed_names;
static void (*process_function)();
static void hier_process (p) /* invoked only via process_sym_table */
 symbol_ptr p;
 {
  /* If no symbol of this name has been processed, process this one. */
  if (!lookup_symbol (processed_names, p->name))
   {
    symbol_ptr p2 = malloc (sizeof (*p2));
    p2->name = p->name; /* share */
    enter_symbol (processed_names, p2);
    process_function (p);
   }
 } /* hier_process */

static void call_free (t)
 char *t;
 {
  free (t);
 } /* call_free */

static void process_sym_table (st, process)
 struct hiersymtab *st;
 void (*process)();
 {
  struct hiersymtab *p;

  if (st->log) fprintf (st->log, ">hier_process_sym_table %x\n", st);
  processed_names = new_basictab (251, st->log);
  process_function = process;

  for (p = st; p; p=p->next) process_symbol_table (p->tab, hier_process);

  delete_symbol_table (processed_names, call_free);
  if (st->log) fprintf (st->log, "<hier_process_sym_table %x\n", st);
 } /* process_sym_table */

static void process_one_table (st, process)
 struct hiersymtab *st;
 void (*process)();
 {
  if (st->log) fprintf (st->log, ">hier_process_one_table %x\n", st);

  process_symbol_table (st->tab, process);

  if (st->log) fprintf (st->log, "<hier_process_one_table %x\n", st);
 } /* process_one_table */

static void delete_sym_table (st, dealloc)
 struct hiersymtab *st;
 void (*dealloc)();
 {
  if (st->flags & F_SYMTAB_NOWRITE) return;

  delete_symbol_table (st->tab, dealloc);

  while (st)
   {
    struct hiersymtab *next_st = st->next;
    free (st);
    st = next_st;
   }
 } /* delete_sym_table */

static int get_level (st)
 struct hiersymtab *st;
 {
  return symbol_table_level (st->tab);
 } /* get_level */

static void protect (st)
 struct hiersymtab *st;
 {
  st->flags |= F_SYMTAB_NOWRITE;
 } /* protect */

static void enable (st)
 struct hiersymtab *st;
 {
  st->flags &= ~F_SYMTAB_NOWRITE;
 } /* enable */

static void attach_hier_symbol_table (st, st2)
 struct hiersymtab *st, *st2;
 {
  struct hiersymtab *st3;

  st3 = (struct hiersymtab *) malloc (sizeof(*st3));
  st3->send = 0; /* no one is sending to this one */
  st3->tab =  (basictab_ptr)st2;
  st3->log = st->log;
  st3->flags = st->flags;

  st3->next = st->next;
  st->next = st3;
 } /* attach_hier_symbol_table */

struct hiersymtab_class hiersymtab_class = {0};

static int hiersymtab_initialized = 0;

void hiersymtab_class_init ()
 {
  if (hiersymtab_initialized) return;

  hiersymtab_initialized = 1;

  symtab_class_init ();

  hiersymtab_class.parent = symtab_class; /* inherit methods */

  /* override methods */
  hiersymtab_class.parent.delete 	= delete_sym_table;
  hiersymtab_class.parent.process 	= process_sym_table;
  hiersymtab_class.parent.process_local = process_one_table;
  hiersymtab_class.parent.increment_level = increment_sym_level;
  hiersymtab_class.parent.decrement_level = decrement_sym_level;
  hiersymtab_class.parent.enter		= enter_sym;
  hiersymtab_class.parent.enter_prehashed = enter_prehashed_sym;
  hiersymtab_class.parent.lookup	= lookup_sym;
  hiersymtab_class.parent.lookup_local	= lookup_local_sym;
  hiersymtab_class.parent.remove	= remove_sym;
  hiersymtab_class.parent.level		= get_level;
  hiersymtab_class.parent.write_protect = protect;
  hiersymtab_class.parent.write_enable	= enable;

  /* new methods */
  hiersymtab_class.attach = attach_hier_symbol_table;
 
 } /* hiersymtab_class_init */ 

hiersymtab_ptr new_hiersymtab (hash_length, log)
 int hash_length;
 FILE *log;
 {
  struct hiersymtab *st = (struct hiersymtab *) malloc (sizeof(*st));

  if (!hiersymtab_initialized) hiersymtab_class_init ();

  st->send = &hiersymtab_class;
  st->tab = new_basictab (hash_length, log);
  st->log = log;
  st->flags = 0;
  st->next = 0;

  return (hiersymtab_ptr) st;
 } /* new_hiersymtab */

