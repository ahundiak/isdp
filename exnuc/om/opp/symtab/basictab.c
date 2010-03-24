
/*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^*/
/* basictab.c - basic symbol table. - subclass of symtab. 		*/
/*									*/
/* Object PreProcessor - opp						*/
/* Paul L. Hammond							*/
/* October 1985								*/
/* Complete Revision March 19, 1986					*/
/* Made Object Oriented October 31, 1986				*/
/* Object scheme revised December 12, 1986				*/
/*									*/
/* Global Functions :							*/
/*  new_basictab	   - allocates symbol table and returns pointer */
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
/*  level		   - returns level of symbol table		*/
/*									*/
/*  write_protect	   _ disable enter, delete, incr, decr, remove  */
/*									*/
/*  write_enable	   _ enable enter, delete, incr, decr, remove	*/
/*									*/
/* All common declarations relating to symbol table are in symtab.cls.	*/
/*									*/
/*vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv*/

#define NULL 0

#include "basictab.cl"
#include <string.h>
#include "oppmalloc.h"

static int hash (st, name)
 struct basictab *st;
 char *name;
 {
  register unsigned int h = 0, c;
  register char *p;

  for (p = name; c = *p, c; ++p)
   {
    h += h;
    h += c;
   }

  return (h % st->hash_length); 
 } /* hash */

static symbol_ptr lookup_sym (st, name)
 struct basictab *st;
 char  	*name;
 {
  int i;
  register symbol_ptr s;

  i = hash (st, name);

  for (s=st->symtab[i]; s; s=s->next) if (!strcmp (s->name, name)) break;

  if (st->log) fprintf (st->log, "lookup_sym \"%s\" %x\n", name, s);

  return s;
 } /* lookup_sym */

static symbol_ptr lookup_local_sym (st, name)
 struct basictab *st;
 char  	*name;
 {
  int i;
  register symbol_ptr s;

  if (st->log) fprintf (st->log, "lookup_local_sym \"%s\"\n", name);
  i = hash (st, name);

  for (s=st->symtab[i]; s && s->level == st->level; s=s->next)
   if (!strcmp (s->name, name)) return s;

  return 0;
 } /* lookup_local_sym */

static void enter_prehashed_sym (st, s)
 struct basictab *st;
 symbol_ptr s;
 {
  register symbol_ptr p, *pp;

  if (st->flags & F_SYMTAB_NOWRITE) return;

  pp = st->symtab + s->hash_value;

  /* don't enter if already there */
  for (p = *pp; p; p=p->next) if (p==s) return;

  s->level = st->level;
  s->next = *pp;
  *pp = s;
 } /* enter_prehashed_sym */

static void enter_sym (st, s)
 struct basictab *st;
 symbol_ptr s;
 {
  register symbol_ptr *pp;

  if (st->flags & F_SYMTAB_NOWRITE) return;
  if (st->log) fprintf (st->log, "enter_sym %x %s\n", st, s->name);
  pp = st->symtab + (s->hash_value = hash (st, s->name));

  s->level = st->level;
  s->next = *pp;
  *pp = s;
 } /* enter_sym */

static void remove_sym (st, s)
 struct basictab *st;
 symbol_ptr s;
 {
  register symbol_ptr p, *pp;

  if (st->flags & F_SYMTAB_NOWRITE) return;
  for (pp = st->symtab + s->hash_value; p = *pp ; pp = &p->next)
   if (p == s)
    {
     *pp = p->next;
     return;
    }
 } /* remove_sym */

static void increment_sym_level (st)
 struct basictab *st;
 {
  if (st->flags & F_SYMTAB_NOWRITE) return;
  ++st->level;
  if (st->log) fprintf (st->log, "basictab:increment %x = %d\n",st,st->level);
 } /* increment_sym_level */

static void decrement_sym_level (st, dealloc)
 struct basictab *st;
 void (*dealloc)();
 {
  symbol_ptr purge_list = NULL;
  register symbol_ptr *p;

#ifdef DEBUG
  fprintf (stderr, " decrement_sym_level- st = %d dealloc = %d\n",
	   st, dealloc);
#endif

  if (st->flags & F_SYMTAB_NOWRITE) return;
  for (p = st->symtab + st->hash_length; --p >= st->symtab; ) if (*p)
   {
    register symbol_ptr s, prev = 0;

    for (s = *p; s && (s->level == st->level); prev = s, s=s->next );

    if (prev)
     {
      prev->next = purge_list;
      purge_list = *p;
      *p = s;
     }
   } /* for */

  --st->level;

  if (dealloc)
   { /* Process all purged symbols */
    register symbol_ptr s = purge_list;
    while (s)
     {
      symbol_ptr next_s = s->next;
      dealloc (s);
      s = next_s;
     }
   }
  if (st->log) fprintf (st->log, "basictab:decrement %x = %d\n",st,st->level);
 } /* decrement_sym_level */

static void process_sym_table (st, process)
 struct basictab *st;
 void (*process)();
 {
  register symbol_ptr s, *pp;

  if (!process) return;

  for (pp = st->symtab + st->hash_length; --pp >= st->symtab; )
   for (s = *pp; s; ) 
    {
     register symbol_ptr next_s = s->next;
     process (s);
     s = next_s;
    }
 } /* process_sym_table */

static void process_locs (st, process)
 struct basictab *st;
 void (*process)();
 {
  register symbol_ptr s, *pp;

  if (!process) return;

  for (pp = st->symtab + st->hash_length; --pp >= st->symtab; )
   for (s = *pp; s && s->level == st->level; ) 
    {
     register symbol_ptr next_s = s->next;
     process (s);
     s = next_s;
    }
 } /* process_locs */

static void delete_sym_table (st, dealloc)
 struct basictab *st;
 void (*dealloc)();
 {
  if (st->flags & F_SYMTAB_NOWRITE) return;

  if (dealloc) process_sym_table (st, dealloc);

  free (st);
 } /* delete_sym_table */

static int get_level (st)
 struct basictab *st;
 {
  return st->level;
 } /* get_level */

static void protect (st)
 struct basictab *st;
 {
  st->flags |= F_SYMTAB_NOWRITE;
 } /* protect */

static void enable (st)
 struct basictab *st;
 {
  st->flags &= ~F_SYMTAB_NOWRITE;
 } /* enable */

static int basictab_initialized = 0;

struct symtab_class basictab_class = {0};

void basictab_class_init ()
 {
  if (basictab_initialized) return;

  basictab_initialized = 1;

  symtab_class_init ();

  basictab_class = symtab_class; /* inherit methods */

  /* override methods */
  basictab_class.delete 	= delete_sym_table;
  basictab_class.process 	= process_sym_table;
  basictab_class.process_local	= process_locs;
  basictab_class.increment_level = increment_sym_level;
  basictab_class.decrement_level = decrement_sym_level;
  basictab_class.enter		= enter_sym;
  basictab_class.enter_prehashed = enter_prehashed_sym;
  basictab_class.lookup		= lookup_sym;
  basictab_class.lookup_local	= lookup_local_sym;
  basictab_class.remove		= remove_sym;
  basictab_class.level		= get_level;
  basictab_class.write_protect	= protect;
  basictab_class.write_enable	= enable;

 } /* basictab_class_init */ 

basictab_ptr new_basictab (hash_length, log)
 int hash_length;
 FILE *log;
 {
  register symbol_ptr *p;
  struct basictab *st =
   (struct basictab *) malloc (sizeof(*st) +
			      (hash_length-1) * sizeof (symbol_ptr));

  if (!basictab_initialized) basictab_class_init ();

  if (log) fprintf (log, "new_symbol_table %x %d\n", st, hash_length);
  st->hash_length = hash_length;
  st->log = log;
  st->level = 0;
  st->flags = 0;
  st->send = &basictab_class;
  for (p = st->symtab + hash_length; p > st->symtab; *--p = NULL);

  return (basictab_ptr) st;
 } /* new_basictab */
