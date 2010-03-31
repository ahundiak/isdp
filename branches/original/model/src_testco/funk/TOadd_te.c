/*
Name
	TOadd_te

Abstract
	add one edge to the linked list
	
Synopsis
	
    sts = TOadd_te(topo,status,num_ele,elehead,eletail)

    struct topology *topo;
    short           status;
    short           num_ele;
    struct telist   **elehead;
    struct telist   **eletail;


Description
 
	Input:
    	status 		state of the edge generation state is status = 1
    	num_ele		number of edges belonging to the current
                        topological edge

	Output:

    	**elehead	list header for topological edges
    	**eletail	list tail for topological edges

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

int TOadd_te(struct topology *topo,
             short           status,
             short           num_ele,
             struct elist   **elehead,
             struct elist   **eletail)
 
{
   
   int                sts;
   struct top_edge    *ee;
   struct memory      *memo = NULL;

   num_ele = num_ele;	/*make the compiler happy */
   if(topo->te.tehead == NULL)
   {
      return(-1);
   }
/*
   Add top_edge to list if there is memory available
   if not then add an element to the memory management list and go on
*/
   memo = (topo->mo.motail)->next;
   if((BASIC_SIZE -(memo->current - memo->p)) <
      (sizeof(struct top_edge) + 8 - (sizeof(struct top_edge)% 8 )))
   {
      sts = TOadd_mo(topo);
      if(sts)
      {
/*       memory allocation failed */
         return(-1);
      }
   memo = (topo->mo.motail)->next;
   }

   ee             = (struct top_edge *) memo->current;
   memo->current += sizeof(struct top_edge);
   if((sizeof(struct top_edge) % 8) !=NULL)
      memo->current += 8 - (sizeof(struct top_edge) % 8);

   topo->te.num_te              += 1;
   (topo->te.tetail)->next->next = ee;  
   (topo->te.tetail)->next       = ee;  
   ee->next                      = topo->te.tetail;
   ee->status                    = status;
   ee->num_ele                   = num_ele; 
/*
   initialize the elist for the current top_edge
*/
   sts = TOinit_el(topo,elehead,eletail);
   if(sts)
   {
/*   memory allocation failed */
     return(-1);
   }

   ee->elehead       = *elehead;
   ee->eletail       = *eletail;

   return(0);
}

