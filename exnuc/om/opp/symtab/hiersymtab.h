
/*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^*/
/* hiersymtab.h - hierachical symbol table. - subclass of symtab	*/
/*	     	  Works with hiersymtab.c				*/
/*									*/
/* Object PreProcessor - opp						*/
/* Paul L. Hammond							*/
/* October 30, 1986							*/
/*									*/
/* Derived from and built on top of the basic symbol table provided by	*/
/* basictab.h/basictab.c.						*/
/*									*/
/*vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv*/
#ifndef HIERSYMTAB_INCLUDED
#define HIERSYMTAB_INCLUDED
#include "symtab.h"

struct hiersymtab_class
 {
  struct symtab_class parent;
  void (*attach) (/* hiersymtab_ptr htab; symbol_table_ptr *tab */);
#define hiersymtab_attach(htab,tab) (*htab)->attach ((htab), (tab))
 };

typedef struct hiersymtab_class **hiersymtab_ptr;

hiersymtab_ptr new_hiersymtab (/* int hash_length; FILE *log */);

#define new_hier_symbol_table new_hiersymtab

#endif /* HIERSYMTAB_INCLUDED */
/* End hiersymtab.h */
