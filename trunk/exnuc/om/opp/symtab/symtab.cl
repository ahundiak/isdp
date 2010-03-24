
/*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^*/
/* symtab.cl -	generic symbol table.					*/
/*	     	Works with symtab.c					*/
/*									*/
/* Object PreProcessor - opp						*/
/* Paul L. Hammond							*/
/* December 12, 1986							*/
/*									*/
/*vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv*/
#ifndef SYMTAB_CLASS_INCLUDED
#define SYMTAB_CLASS_INCLUDED
#include "symtab.h"

extern struct symtab_class symtab_class;

extern void symtab_class_init();

#define F_SYMTAB_NOWRITE 1

#endif /* SYMTAB_CLASS_INCLUDED */
/* End symtab.h */
