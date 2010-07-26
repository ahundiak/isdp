
/*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^*/
/* carriers.h								*/
/*vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv*/
#ifndef CARRIERS_INCLUDED
#define CARRIERS_INCLUDED

#include "identifier.h"

typedef struct carrier
 {
  struct carrier *next;
  identifier_ptr cargo;
 } *carrier_ptr;


#if defined(__STDC__) || defined(__cplusplus)
#ifndef __
#define __(args) args
#endif
#else
#ifndef __
#define __(args) ()
#endif
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* carriers.c */
carrier_ptr carrier_node __((identifier_ptr sym));
carrier_ptr reverse_carrier_list __((carrier_ptr list));

#if defined(__cplusplus)
}
#endif

#endif /* CARRIERS_INCLUDED */

