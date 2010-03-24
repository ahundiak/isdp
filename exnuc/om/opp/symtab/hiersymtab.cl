
/*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^*/
/* hiersymtab.cl - hierachical symbol table. - subclass of symtab	*/
/*	     	   Works with hiersymtab.c				*/
/*									*/
/* Object PreProcessor - opp						*/
/* Paul L. Hammond							*/
/* December 12, 1986							*/
/*									*/
/*vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv*/
#ifndef HIERSYMTAB_CLASS_INCLUDED
#define HIERSYMTAB_CLASS_INCLUDED
#include "hiersymtab.h"
#include "symtab.cl"
#include "basictab.h"

struct hiersymtab
 {
  struct hiersymtab_class	*send;
  basictab_ptr	 		tab;
  long				flags;
  FILE				*log;
  struct hiersymtab		*next;
 };

extern struct hiersymtab_class hiersymtab_class;

extern void hiersymtab_class_init();

#endif /* HIERSYMTAB_CLASS_INCLUDED */
/* End hiersymtab.cl */
