
/*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^*/
/* symtab.c -	generic symbol table.					*/
/*									*/
/* Object PreProcessor - opp						*/
/* Paul L. Hammond							*/
/* December 12, 1986							*/
/*									*/
/*vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv*/
#include <stdlib.h>
#include "symtab.cl"

struct symtab_class symtab_class = {0};

static int symtab_initialized = 0;

static void symtab_unsupported (st)
 symtab_ptr st;
 {
  fprintf (stderr, "fatal : unsupported symbol table method.\n");
  fprintf (stderr, " - table address = %x\n", st);
  fprintf (stderr, " - class address = %x\n", *st);
  exit (1);
 } /* symtab_unsupported */

void symtab_class_init ()
 {
  if (symtab_initialized) return;

  symtab_initialized = 1;

  /* new messages */
  symtab_class.delete 		= symtab_unsupported;
  symtab_class.process 		= symtab_unsupported;
  symtab_class.process_local	= symtab_unsupported;
  symtab_class.increment_level	= symtab_unsupported;
  symtab_class.decrement_level	= symtab_unsupported;
  symtab_class.enter		= symtab_unsupported;
  symtab_class.enter_prehashed	= symtab_unsupported;
  symtab_class.lookup		= (symbol_ptr(*)())symtab_unsupported;
  symtab_class.lookup_local	= (symbol_ptr(*)())symtab_unsupported;
  symtab_class.remove		= symtab_unsupported;
  symtab_class.level		= (int(*)())symtab_unsupported;
  symtab_class.write_protect    = symtab_unsupported;
  symtab_class.write_enable	= symtab_unsupported;

 } /* symtab_class_init */


