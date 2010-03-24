

/*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^*/
/* basictab.h -	basic symbol table. - subclass of symtab.		*/
/*	     	Works with basictab.c					*/
/*									*/
/* Object PreProcessor - opp						*/
/* Paul L. Hammond							*/
/* December 12, 1986							*/
/*									*/
/*vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv*/
#ifndef BASICTAB_INCLUDED
#define BASICTAB_INCLUDED
#include "symtab.h"

#define basictab_ptr symtab_ptr

extern basictab_ptr new_basictab (/* int hash_length; FILE *log */);
/* "hash_length" should be a prime number for best effect.  4*hashlength
   bytes are allocated.
   "log" is a pointer to an open file on which all symbol table operations
   are to be recorded.  This is intended for used in debugging.  If zero
   is passed, no logging is done.
*/

/* for compatibility with old stuff */
#define new_symbol_table new_basictab

#endif /* BASICTAB_INCLUDED */

