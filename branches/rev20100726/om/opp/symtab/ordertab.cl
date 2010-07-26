/*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^*/
/* ordertab.cl - symbol table that maintains the order in which symbols */
/*               are entered. - subclass of hiersymtab                  */
/*	     	 Works with ordertab.c					*/
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
#ifndef ORDERTAB_CLASS_INCLUDED
#define ORDERTAB_CLASS_INCLUDED
#include "ordertab.h"
#include "hiersymtab.cl"

struct ordertab
 {
  struct hiersymtab	parent;
  struct table_order	*head;
  void			*owner;
  int			transaction;	/* avoid duplicates during process */
 };

#endif /* ORDERTAB_CLASS_INCLUDED */
/* End ordertab.cl */
