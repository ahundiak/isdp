/*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^*/
/* ordertab.h - symbol table that maintains the order in which symbols	*/
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
#ifndef ORDERTAB_INCLUDED
#define ORDERTAB_INCLUDED
#include "hiersymtab.h"

struct table_order
 {
  struct symbol		*sym;  /* pointer to used symbol */
  struct table_order	*next;
 };

struct ordertab_class
 {
  struct hiersymtab_class parent;
 };

typedef struct ordertab_class **ordertab_ptr;

extern ordertab_ptr new_ordertab (/* int hashlength; FILE *log; void *owner; */);

#endif /* ORDERTAB_INCLUDED */
/* End ordertab.h */
