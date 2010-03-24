/*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^*/
/* usagetab.cl - usage-recording symbol table. - subclass of hiersymtab	*/
/*	     	 Works with usagetab.c					*/
/*									*/
/* Object PreProcessor - opp						*/
/* Paul L. Hammond							*/
/* December 11, 1986							*/
/*									*/
/* Records all symbols found by successfull lookup operations.		*/
/*									*/
/* Overridden symtab Methods :						*/
/*  lookup_symbol	   - records symbol if found			*/
/*  lookup_local_symbol	   - records symbol if found 			*/
/*									*/
/*  remove_symbol	   - if in usage list, removed from usage list  */
/*  decrement_symbol_level - purged symbols are removed from usage list	*/
/*  delete_symbol_table    - deletes usage list.			*/
/*									*/
/* If the table is in a write protected state, the actions		*/
/* listed for remove and decrement will be omitted.			*/
/*									*/
/* New Methods :							*/
/*  record		   - all subsequent lookups are recorded	*/
/*  usage		   - gets usage list and turns off recording	*/
/*									*/
/* NOTE : Recording is intended to be used with quiescent symbol table.	*/
/*	  Level changing operations may not work while recording.	*/
/*vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv*/
#ifndef USAGETAB_CLASS_INCLUDED
#define USAGETAB_CLASS_INCLUDED
#include "usagetab.h"
#include "hiersymtab.cl"

struct usagetab
 {
  struct hiersymtab parent;
  basictab_ptr usage_list;
  char *owner; 		 /* a pointer to anything */
  int recording_enabled; /* boolean */
 };

#endif /* USAGETAB_CLASS_INCLUDED */
/* End usagetab.cl */
