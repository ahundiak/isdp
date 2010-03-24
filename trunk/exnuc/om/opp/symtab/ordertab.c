/*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^*/
/* ordertab.c - symbol table that maintains the order in which symbols	*/
/*               are entered. - subclass of hiersymtab                  */
/*	     	 Works with ordertab.c					*/
/*									*/
/* Maintains a linked list of all symbols entered.			*/
/*									*/
/* Overridden symtab Methods :						*/
/*  enter_symbol	   - enters then adds to linked list		*/
/*  enter_prehashed_symbol						*/
/*  process_symbol_table   - process in order entered.			*/
/*  process_local_symbols						*/
/*  remove_symbol          - removes from linked list.			*/
/*  delete_symbol_table    - frees linked list.				*/
/*  decrement_symbol_level - removes symbols from linked list		*/
/*									*/
/* Overridden hiersymtab Methods :					*/
/*  hiersymtab_attach  - makes an ordertab instead of a hiersymtab	*/
/*vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv*/
#include "ordertab.cl"
#include <malloc.h>
#include <string.h>

/* The following static variables are used by
   "order_process" with "process_symbol_table". */

static symtab_ptr processed_names = 0;
static void (*process_function)() = 0;
static int in_process = 0;

int order_processed_name (name)
 char *name;
 {
  if (!in_process) return 0;
  if (!lookup_symbol (processed_names, name))
   {
    symbol_ptr p2 = (symbol_ptr)malloc (sizeof (*p2));
    p2->name = name; /* share */
    enter_symbol (processed_names, p2);
    return 0;
   }
  return 1;
 } /* order_processed_name */

static void process_unique (p)
 symbol_ptr p;
 {
  /* If no symbol of this name has been processed, process this one. */
  if (p->level) return;
  if (!lookup_symbol (processed_names, p->name))
   {
    process_function (p);
    order_processed_name(p->name);
   }
 } /* process_unique */

static void call_free (t)
 char *t;
 {
  free (t);
 } /* call_free */

static void process_order_list(p)
 struct table_order *p;
 {
  if (p)
   {
    if (!p->next)
      process_unique(p->sym);
    else
     {
      process_order_list(p->next);
      process_unique(p->sym);
     }
   }
 } /* process_order_list */

static void process_table_list (p, process)
 struct hiersymtab *p;
 void (*process)();
 {
   if (!p->next)
    {
     process_order_list(((struct ordertab *)p)->head);
     if (!p->send)
      process_symbol_table(p->tab, process);
    }
   else
    {
     process_table_list(p->next, process);
     process_order_list(((struct ordertab *)p)->head);
     if (!p->send)
      process_symbol_table(p->tab, process);
    }   
 } /* process_table_list */

static int transaction_counter = 0;

static void order_process (st, process)
 struct ordertab *st;
 void (*process)();
 {
  int i_created_it = 0;

  if (!process) return;

  if (st->parent.log) fprintf (st->parent.log, ">order_process %x\n", st);
  if (!processed_names)
   {
    processed_names = new_basictab (251, st->parent.log);
    ++transaction_counter;
    in_process = 1;
    i_created_it = 1;
   }

  if (st->transaction == transaction_counter) return;
  st->transaction = transaction_counter;

  process_function = process;
  process_table_list(&st->parent, process);

  if (i_created_it)
   {
    delete_symbol_table (processed_names, call_free);
    processed_names = 0;
    in_process = 0;
   }

  if (st->parent.log) fprintf (st->parent.log, "<order_process %x\n", st);
 } /* order_process */

static void order_process_local (st, process)
 struct ordertab *st;
 void (*process)();
 {
  int i_created_it = 0;

  if (!process) return;

  if (st->parent.log) fprintf (st->parent.log, ">order_process_local %x\n", st);

  if (!processed_names)
   {
    processed_names = new_basictab (251, st->parent.log);
    i_created_it = 1;
   }
  process_function = process;

  process_order_list(st->head);
  process_symbol_table(((struct hiersymtab *)st)->tab, process);

  if (i_created_it)
   {
    delete_symbol_table (processed_names, call_free);
    processed_names = 0;
   }
  if (st->parent.log) fprintf (st->parent.log, "<order_process_local %x\n", st);
 } /* order_process_local */

static void order_enter_prehashed (st, s)
 struct ordertab *st;
 symbol_ptr s;
 {
  struct table_order *p;

  if (st->parent.flags & F_SYMTAB_NOWRITE) return;

  p = (struct table_order *)calloc(1, sizeof(*p));
  p->sym = s;
  p->next = st->head;
  st->head = p;

  enter_prehashed_symbol (st->parent.tab, s);
 } /* order_enter_prehashed */

static void order_enter (st, s)
 struct ordertab *st;
 symbol_ptr s;
 {
  struct table_order *p;

  if (st->parent.flags & F_SYMTAB_NOWRITE) return;

  p = (struct table_order *)malloc(sizeof(*p));
  p->sym = s;
  p->next = st->head;
  st->head = p;

  enter_symbol (st->parent.tab, s);
 } /* order_enter */

static void remove_from_table_order(st, s)
 struct ordertab *st;
 symbol_ptr s;
 {
  struct table_order *p, *prev;

  prev = 0;
  p = st->head;
  while (p)
   {
    if (p->sym == s)
     {
      if (!prev)
       st->head = p->next;
      else
       prev->next = p->next;
      free(p);
      break;
     }
    prev = p;
    p = p->next;
   }
 } /* remove_from_table_order */

static void order_remove (st, s)
 struct ordertab *st;
 symbol_ptr s;
 {
  if (st->parent.flags & F_SYMTAB_NOWRITE) return;

  remove_from_table_order(st, s);
  remove_symbol (st->parent.tab, s);
 } /* order_remove */

static void order_delete (st, dealloc)
 struct ordertab *st;
 void (*dealloc)();
 {
  struct ordertab *t;
  FILE *f;

  if (f = st->parent.log) fprintf (f, ">ordertab_delete %x\n", st);

  if (!(st->parent.flags & F_SYMTAB_NOWRITE))
   {
    for (t = st; t; t = (struct ordertab *) t->parent.next)
     {
      struct table_order *p;

      for (p = t->head; p;)
       {
        struct table_order *next;

        next = p->next;
        free(p);
        p = next;
       }
      t->head = 0;
     }  
    hiersymtab_class.parent.delete (st, dealloc);
   } 

  if (f) fprintf (f, "<ordertab_delete %x\n", st);
 } /* order_delete */

static void order_attach (st, st2)
 struct ordertab *st, *st2;
 {
  struct ordertab *st3;

  st3 = (struct ordertab *) malloc (sizeof(*st3));
  st3->parent.send = 0; /* no one is sending to this one */
  st3->parent.tab =  (basictab_ptr)st2;
  st3->parent.log = st->parent.log;
  st3->parent.flags = st->parent.flags;

  st3->parent.next = st->parent.next;
  st->parent.next = (struct hiersymtab *)st3;

  st3->head = 0;
  st3->owner = 0;
  st3->transaction = 0;
 } /* order_attach */

static struct dealloc
{
 void           (*dealloc_function)();
 void           *st;
 struct dealloc *next;
} *dealloc_stack = 0;

static void push_dealloc_function(st, dealloc)
 void *st;
 void (*dealloc)();
 {
  struct dealloc *p;

  p = (struct dealloc *)malloc(sizeof(*p));
  p->st = st;
  p->dealloc_function = dealloc;

  p->next = dealloc_stack;
  dealloc_stack = p;
 } /* push_dealloc_function */

static void pop_dealloc_function()
 {
  struct dealloc *p;

  p = dealloc_stack->next;
  free(dealloc_stack);
  dealloc_stack = p;
 } /* pop_dealloc_function */

static void order_dealloc(s)
 symbol_ptr s;
 {
   if (dealloc_stack->dealloc_function)
    { 
     remove_from_table_order((struct ordertab *)dealloc_stack->st, s);
     dealloc_stack->dealloc_function(s);
    }
 } /* order_dealloc */

static void order_decrement (st, dealloc)
 struct ordertab *st;
 void (*dealloc)();
 {
  if (st->parent.flags & F_SYMTAB_NOWRITE) return;
  if (st->parent.log) fprintf (st->parent.log, ">order_decrement %x\n", st);

  push_dealloc_function((void *)st, dealloc);
  decrement_symbol_level (st->parent.tab, order_dealloc);
  pop_dealloc_function();
 } /* order_decrement */

static void dump_table_order (p)
 struct table_order *p;
 {
  printf("-----------------------------\n");
  printf("p  ..............  0x%.8x\n", p);
  printf("p.sym  ..........  0x%.8x\n", p->sym);
  printf("p.sym.name  .....  %s\n", p->sym->name);
  printf("p.next  .........  0x%.8x\n", p->next);
  printf("-----------------------------\n");
 } /* dump_table_order */

void order_dump (st)
 struct ordertab *st;
 {
  struct table_order *p;

  for (p = st->head; p; p = p->next)
   dump_table_order(p);

 } /* order_dump */

static int ordertab_initialized = 0;

struct ordertab_class ordertab_class = {0};

void ordertab_class_init ()
 {
  if (ordertab_initialized) return;

  ordertab_initialized = 1;

  hiersymtab_class_init ();

  ordertab_class.parent = hiersymtab_class; /* inherit methods */

  /* override symtab messages */
  ordertab_class.parent.parent.process		= order_process;
  ordertab_class.parent.parent.process_local	= order_process_local;
  ordertab_class.parent.parent.enter		= order_enter;
  ordertab_class.parent.parent.enter_prehashed	= order_enter_prehashed;
  ordertab_class.parent.parent.remove		= order_remove;
  ordertab_class.parent.parent.delete		= order_delete;
  ordertab_class.parent.parent.decrement_level	= order_decrement;
  
  /* override hiersymtab messages */
  ordertab_class.parent.attach			= order_attach;
 }

ordertab_ptr new_ordertab (hashlength, log, owner)
 int hashlength;
 FILE *log;
 void *owner;
 {
  struct ordertab *st = (struct ordertab *) calloc (1, sizeof(*st));

  if (log) fprintf (log, ">new_ordertab %x : %d\n", st, hashlength);

  if (!ordertab_initialized) ordertab_class_init ();

  st->parent.send = (struct hiersymtab_class *) &ordertab_class;
  st->parent.log = log;
  st->parent.flags = 0;
  st->parent.tab = new_basictab (hashlength, log);
  st->parent.next = 0;

  st->owner = owner;
  st->head = 0;
  st->transaction = 0;

  if (log) fprintf (log, "<new_ordertab %x : %d\n", st, hashlength);
  return (ordertab_ptr) st;
 } /* new_ordertab */

#define PRINTTAB(N)	{ int i; for (i = 0; i < (N); ++i) printf("  "); }
void process_ordertab_list(t, indent, prefix, get_owner_name)
 struct ordertab *t;
 int indent;
 char *prefix;
 char *(*get_owner_name)();
 {
  struct hiersymtab *p = (struct hiersymtab *)t;
  int i;
  char *name = get_owner_name(t->owner);

  PRINTTAB(indent)
  if (prefix) printf(prefix);
  printf("0x%.8x %s tab=0x%.8x\n", t, name ? name : "link", p->tab);
  if (*((char **)p->tab) == (char *)&ordertab_class)
    process_ordertab_list((struct ordertab *)p->tab, indent + 1, (char *)0, 
                          get_owner_name);
  for (i = 0, p = (struct hiersymtab *)t->parent.next; p; ++i, p = p->next)
   {
    char prefix2[200];
    sprintf(prefix2, "%s[%d]  ", name ? name : "link", i);
    process_ordertab_list((struct ordertab *)p, indent + 1, prefix2, get_owner_name);
   }
 } /* print_ordertab_list */
#undef PRINTTAB

