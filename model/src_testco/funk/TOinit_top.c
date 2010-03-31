/*
Name
	TOinit_topo

Abstract
	Allocation of memory for the basic topology input data data structures.
	Initialization of the lists for:
        	- the topological data
        	  (topological points and edges and the element list headers for
                   edges and points)
	Define list header and tail:
	The next element after the header is the tail.
	The next element after the tail is the header ==> list is empty.
	
Synopsis
	
	sts = TOinit_topo(topo)
	
	struct topology   *topo;

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


int TOinit_topo( struct topology *topo)
{
   int sts;
   struct memory *memo = NULL;

#ifdef DBG         
   printf("TO_init_topo\n");
#endif
/*
   no memory list is initialized
*/
   if((topo->mo.mohead == NULL) || (topo->mo.motail == NULL))
   {
      sts = TOinit_mo(topo);
      if(sts)
      {
         return(-1);
      }
   }
/*
   the memory management list is empty
*/
   if(topo->mo.mohead->next == topo->mo.motail)
   {
      sts = TOadd_mo(topo);
      if(sts)
      {
         return(-1);
      }   
   }
   memo = topo->mo.motail->next;
/*
   Initialize top_point list, if there is atleast memory available for
   the list header and tail;
   if not add an element to the memory management list and go on
*/
   if((BASIC_SIZE - (memo->current - memo->p)) <=
      (2*sizeof(struct top_point) + 16))
   {
      sts = TOadd_mo(topo);
      if(sts)
      {
         return(-1);
      }
      memo = topo->mo.motail->next;
   }
   topo->tp.tphead = (struct top_point *) memo->current;
   memo->current += sizeof(struct top_point);
   if((sizeof(struct top_point) % 8) !=NULL)
      memo->current += 8 - (sizeof(struct top_point) % 8);
   topo->tp.tptail =(struct top_point *) memo->current;
   memo->current += sizeof(struct top_point);
   if((sizeof(struct top_point) % 8) !=NULL)
      memo->current += 8 - (sizeof(struct top_point) % 8);
   (topo->tp.tphead)->next =topo->tp.tptail;
   (topo->tp.tptail)->next =topo->tp.tphead;
   topo->tp.num_tp         = NULL;
 
/*
   Initialize top_edge list, if there is atleast memory available for
   the list header and tail;
   if not add an element to the memory management list and go on
*/
   if((BASIC_SIZE - (memo->current - memo->p)) <=
      (2*sizeof(struct top_edge) + 16))
   {
      sts = TOadd_mo(topo);
      if(sts)
      {
         return(-1);
      }
      memo = topo->mo.motail->next;
   }
   topo->te.tehead  = (struct top_edge *) memo->current;
   memo->current += sizeof(struct top_edge);
   if((sizeof(struct top_edge) % 8) !=NULL)
      memo->current += 8 - (sizeof(struct top_edge) % 8);
   topo->te.tetail  =(struct top_edge *) memo->current;
   memo->current += sizeof(struct top_edge);
   if((sizeof(struct top_edge) % 8) !=NULL)
      memo->current += 8 - (sizeof(struct top_edge) % 8);
   (topo->te.tehead)->next = topo->te.tetail;
   (topo->te.tetail)->next = topo->te.tehead;
   topo->te.num_te        = NULL;

   return(0);
}
