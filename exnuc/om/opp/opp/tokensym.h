
/*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^*/
/* tokensym.h - symbols with token values				*/
/*									*/
/* Object PreProcessor - opp						*/
/* Paul L. Hammond							*/
/* March 21, 1986							*/
/*vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv*/
#ifndef TOKENSYM_INCLUDED
#define TOKENSYM_INCLUDED
#include "symtab.h"

typedef struct token_symbol *tokensym_ptr;

struct token_symbol
 {
  struct symbol s;
  int tok; /* token value */
 };
#endif /* TOKENSYM_INCLUDED */
/* End tokensym.h */

