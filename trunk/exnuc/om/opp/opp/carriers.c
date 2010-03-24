
/*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^*/
/* carriers.c - support for carrier structs				*/
/*vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv*/

#include "carriers.h"
#include "oppmalloc.h"

carrier_ptr carrier_node (sym)
 identifier_ptr sym;
 {
  carrier_ptr p = (carrier_ptr) malloc (sizeof (struct carrier));

  p->next = 0;
  p->cargo = sym;
  return p;
 } /* carrier_node */

carrier_ptr reverse_carrier_list (list)
 carrier_ptr list;
 {
  carrier_ptr result = 0;

  while (list)
   {
    carrier_ptr cp = list->next;
    list->next = result;
    result = list;
    list = cp;
   }
  
  return result;
 } /* reverse_carrier_list */
