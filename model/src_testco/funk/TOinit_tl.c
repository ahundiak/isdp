/*
Name
        TOinit_tl

Abstract
        Allocation of memory for the basic topology data structures.
        Initialization of the lists for:
                - the elements (edges, points, top_edges).
        Define list header and tail:
        The next element after the header is the tail.
        The next element after the tail is the header ==> list is empty.

Synopsis

        sts = TOinit_tl(topo, elehead, eletail)

        struct topology *topo;
        struct telist   **elehead;
        struct telist   **eletail;

Description

        Input:

        topo            the structure with generell informations
                        about list headers and allocated memory;

        Output:
        topo            updated structure topo

Return Values

        sts

Notes

Index

Keywords

History
        B. Burkhardt    02/15/94        Creation date.
*/

#include <stdio.h>
#include <string.h>
#include "TOstruct1.h"
#include "TOtopology.h"
#include "TOproto_ta.h"
#include "TOnumbers.h"

int TOinit_tl(struct topology *topo,
             struct telist   **elehead,
             struct telist   **eletail)

{
   int            sts;
   struct memory  *memo = NULL;

   memo = topo->mo.motail->next;
   if(memo == NULL)
   {
     return(-1);
   }
/*
   Initialize the top edge element list, if there is memory available
   for the list header and tail;
   if not then add an element to the memory management list and go on
*/
   if((BASIC_SIZE -(memo->current - memo->p)) <
      (sizeof(struct telist) + 8 - (sizeof(struct telist)% 8 )))
   {
      sts = TOadd_mo(topo);
      if(sts)
      {
         return(-1);
      }
   }
   memo = (topo->mo.motail)->next;
   *elehead          = (struct telist *) memo->current;
   memo->current    += sizeof(struct telist);
   if((sizeof(struct telist) % 8) !=NULL)
      memo->current += 8 - (sizeof(struct telist) % 8);
   *eletail          =(struct telist *) memo->current;
   memo->current    += sizeof(struct telist);
   if((sizeof(struct telist) % 8) !=NULL)
      memo->current += 8 - (sizeof(struct telist) % 8);
   (*elehead)->next  = *eletail;
   (*eletail)->next  = *elehead;

   return(0);
}
