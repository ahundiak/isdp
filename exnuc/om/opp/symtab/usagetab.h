
/*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^*/
/* usagetab.h - usage-recording symbol table. - subclass of hiersymtab	*/
/*	     	 Works with usagetab.c					*/
/*									*/
/* Object PreProcessor - opp						*/
/* Paul L. Hammond							*/
/* December 11, 1986							*/
/*									*/
/* Records all symbols found by successfull lookup operations.		*/
/* New tables are initialy in the non-recording state.			*/
/* When in this state, behavior is same as hiersymtab.			*/
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
/*  owner		   - report owner				*/
/*									*/
/* NOTE : This is intended to be used with quiescent symbol tables.	*/
/*	  Level changing operations may not work.			*/
/*vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv*/
#ifndef USAGETAB_INCLUDED
#define USAGETAB_INCLUDED
#include "hiersymtab.h"

struct table_usage
 {
  struct symbol s; /* circularly linked by s.next */
  symbol_ptr sym;  /* pointer to used symbol */
  char *owner;	   /* a pointer to anything */
 };

struct usagetab_class
 {
  struct hiersymtab_class parent;
  void (*record) (/* usagetab_ptr tab; int mode; int hashlength*/); 
#define usagetab_record(p0,p1,p2) (*p0)->record((p0),(p1),(p2))
  char *(*owner) (/* usagetab_ptr tab; */);
#define usagetab_owner(p0) (*p0)->owner(p0)
  struct table_usage *(*usage) (/* usagetab_ptr tab; */); /* circular list */
#define usagetab_usage(p0) (*p0)->usage(p0)
 };

typedef struct usagetab_class **usagetab_ptr;

extern usagetab_ptr new_usagetab (/* int hashlength; FILE *log; char *owner*/);

#endif /* USAGETAB_INCLUDED */
/* End usagetab.h */
