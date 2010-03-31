/*
Name
	TOinit_el

Abstract
	Allocation of memory for a basic topology data structure.
        Initialization of the list 'list'.
	Define list header and tail:
	The next element after the header is the tail.
	The next element after the tail is the header ==> list is empty.
	
Synopsis
	
	sts = TOinit_el(topo, elehead, eletail)
	
	struct topology   *topo;
	struct elist      **elehead;
	struct elist      **eletail;

Description
 
	Input:
	
	topo		the structure with generell informations
			about list headers and allocated memory;

	Output:
 	topo		updated structure topo

Return Values

	sts

Notes

Index

Keywords

History
	B. Burkhardt	02/15/94	Creation date.
*/
		
   #include <stdio.h>
   #include <string.h>
   #include "TOtopology.h"
   #include "TOstruct1.h"
   #include "TOproto_ta.h"
   #include "TOnumbers.h"


int TOinit_el( struct topology *topo,
	       struct elist    **elehead,
	       struct elist    **eletail)
{
   int sts;
   struct memory *memo = NULL;

/*
   no memory list is initialized
*/
   if((topo->mo.mohead == NULL)||(topo->mo.motail == NULL))
   {
      sts = TOinit_mo(topo);
      if(sts)
         return(-1);
   }
/*
   the memory management list is empty
*/
   if(topo->mo.mohead->next == topo->mo.motail)
   {
      sts = TOadd_mo(topo);
      if(sts)
        return(-1);
   }
   memo = topo->mo.motail->next;
/*
   Initialize edge element list, if there is atleast memory available for
   the list header and tail;
   if not add an element to the memory management list and go on
*/
   if((BASIC_SIZE -(memo->current - memo->p)) <=
      (2*sizeof(struct elist) + 16))
   {
      sts = TOadd_mo(topo);
      if(sts)
         return(-1);
      memo = topo->mo.motail->next;
   }
   *elehead          = (struct elist *) memo->current;
   memo->current    += sizeof(struct elist);
   if((sizeof(struct elist) % 8) !=NULL)
      memo->current += 8 - (sizeof(struct elist) % 8);
   *eletail          =(struct elist *) memo->current;
   memo->current    += sizeof(struct elist);
   if((sizeof(struct elist) % 8) !=NULL)
      memo->current += 8 - (sizeof(struct elist) % 8);
   (*elehead)->next  = *eletail;
   (*eletail)->next  = *elehead;
 
   return(0);
}
