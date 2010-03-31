/*
Name
	TOadd_sf

Abstract
	add one surface to the linked list
	
Synopsis
	
   	sts = TOadd_sf(topo,ext,num_ed, elehead, eletail)
 
	Input:

        struct topology	*topo;
	struct Ext_data_surface *ext;
	short		num_ed;

	Output:

	struct elist	elehead;
	struct elist	eletail;

Description

Return Values

	sts

Notes

Index

Keywords

History
	B. Burkhardt	02/16/94	Creation date.
*/
		
   #include <stdio.h>
   #include <string.h>
   #include "TOtopology.h"
   #include "TOstruct1.h"
   #include "TOproto_ta.h"
   #include "TOnumbers.h"

int TOadd_sf(struct topology *topo,
           struct Ext_data_surface   *ext,
           short             num_ed,
           struct elist	     **elehead,
           struct elist	     **eletail)

{
   int            sts;
   struct surface *ff;
   struct memory  *memo = NULL;

   if(topo->sf.sfhead == NULL)
   {
      sts = TOinit_input(topo);
      if(sts)
         return(-1);
   }
/*
   Add surface to list if there is memory available
   if not then add an element to the memory management list and go on
*/
   memo = (topo->mo.motail)->next;
   if((BASIC_SIZE -(memo->current - memo->p)) <
      (sizeof(struct surface) + 8 - (sizeof(struct surface)% 8 )))
   {
      sts = TOadd_mo(topo);
      if(sts)
      {
/* memory allocation failed */
         return(-1);
      }
   memo = (topo->mo.motail)->next;
   }
   ff             = (struct surface *) memo->current;
   memo->current += sizeof(struct surface);
   if((sizeof(struct surface) % 8) !=NULL)
      memo->current += 8 - (sizeof(struct surface) % 8);

   topo->sf.num_sf              += 1;
   (topo->sf.sftail)->next->next = ff;
   (topo->sf.sftail)->next       = ff;
   ff->next                      = topo->sf.sftail;
   ff->ext                       = ext;
   ff->num_ed                    = num_ed;

/*
   initialize the elist for the current surface
*/
   sts = TOinit_el(topo,elehead,eletail);
   if(sts)
   {
/*   memory allocation failed */
     return(-1);
   }
   ff->elehead        = *elehead;
   ff->eletail        = *eletail;

   return(0);
}
