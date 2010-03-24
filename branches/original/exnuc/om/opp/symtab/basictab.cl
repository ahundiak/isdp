
/*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^*/
/* basictab.cl - basic symbol table. - subclass of generic symtab.	*/
/*	     	 Works with basictab.c					*/
/*									*/
/* Object PreProcessor - opp						*/
/* Paul L. Hammond							*/
/* December 12, 1986							*/
/*									*/
/*vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv*/
#ifndef BASICTAB_CLASS_INCLUDED
#define BASICTAB_CLASS_INCLUDED
#include "basictab.h"
#include "symtab.cl"

struct basictab
 {
  struct symtab_class *send; /* must be first field */
  FILE	     *log;
  int 	     level;
  int 	     hash_length;
  long	     flags;
  symbol_ptr symtab[1];
 };

extern struct symtab_class basictab_class;

extern void basictab_class_init ();

#endif /* BASICTAB_CLASS_INCLUDED */
/* End symtab.cl */
