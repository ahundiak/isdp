/*
Name
	TOadd_tp

Abstract
	add one top_point to the linked list
	
Synopsis
	
    sts = TOadd_tp(topo,status,num_ele,elehead,eletail)

    struct topology *topo;
    short           status;
    short           num_ele;
    struct plist    **elehead;
    struct plist    **eletail;


Description
 
	Input:
    	status 		state of the top_point; generation state is status = 1
    	num_ele		number of points belonging to the current
                        topological point

	Output:

    	**elehead	list header for point list
    	**eletail	list tail for point list

Return Values

	sts

Notes

Index

Keywords

History
	B. Burkhardt	11/11/93	Creation date.
*/
		
#include <stdio.h>
#include <string.h>
#include "TOstruct1.h"
#include "TOtopology.h"
#include "TOproto_ta.h"
#include "TOnumbers.h"

int TOadd_tp(struct topology *topo,
             short           status,
             short           num_ele,
             struct plist    **elehead,
             struct plist    **eletail)
 
{
   
   int            sts;
   struct top_point    *pp;
   struct memory  *memo = NULL;

   if(topo->tp.tphead == NULL)
   {
      return(-1);
   }
/*
   Add top_point to list if there is memory available
   if not then add an element to the memory management list and go on
*/
   memo = (topo->mo.motail)->next;
   if((BASIC_SIZE -(memo->current - memo->p)) <
      (sizeof(struct top_point) + 8 - (sizeof(struct top_point)% 8 )))
   {
      sts = TOadd_mo(topo);
      if(sts)
      {
/*       memory allocation failed */
         return(-1);
      }
      memo = (topo->mo.motail)->next;
   }

   pp             = (struct top_point *) memo->current;
   memo->current += sizeof(struct top_point);
   if((sizeof(struct top_point) % 8) !=NULL)
      memo->current += 8 - (sizeof(struct top_point) % 8);

   topo->tp.num_tp             += 1;
   (topo->tp.tptail)->next->next = pp;  
   (topo->tp.tptail)->next       = pp;  
   pp->next                     = topo->tp.tptail;
   pp->status                   = status;
   pp->num_ele                  = num_ele; 
/*
   initialize the tplist for the current top_point
*/
   sts = TOinit_pl(topo,elehead,eletail);
   if(sts)
   {
/*     memory allocation failed */
     return(-1);
   }

   pp->elehead       = *elehead;
   pp->eletail       = *eletail;

   return(0);
}

