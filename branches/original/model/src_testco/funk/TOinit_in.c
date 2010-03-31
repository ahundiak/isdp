/*
Name
	TOinit_input

Abstract
	Allocation of memory for the basic topology data structures.
	Initialization of the lists for:
        	- the geometrical input data
        	  (surfaces, edges, points and the element list headers for
                   edges and topological edges)
	Define list header and tail:
	The next element after the header is the tail.
	The next element after the tail is the header ==> list is empty.
	
Synopsis
	
	sts = TOinit_input(topo)
	
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
#include <time.h>
#include "TOtopology.h"
#include "TOstruct1.h"
#include "TOproto_ta.h"
#include "TOnumbers.h"


int TOinit_input( struct topology *topo)
{
   int sts;
   struct memory *memo = NULL;

#ifdef DBG
printf("TOinit_input\n");
#endif
/*
   no memory list is initialized
*/
   if((topo->mo.mohead == NULL) || (topo->mo.motail == NULL))
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
      sts  = TOadd_mo(topo);
      if(sts)
         return(-1);
   }
   memo = topo->mo.motail->next;
/*
   Initialize surface_list, if there is atleast memory available for
   the list header and tail;
   if not add an element to the memory management list and go on
*/
   if((BASIC_SIZE - (memo->current - memo->p)) <=
      (2*sizeof(struct surface) + 16))
   {
      sts  = TOadd_mo(topo);
      if(sts)
         return(-1);
      memo = topo->mo.motail->next;
   }
   topo->sf.sfhead = (struct surface *) memo->current;
   memo->current  += sizeof(struct surface);
   if((sizeof(struct surface) % 8) !=NULL)
      memo->current += 8 - (sizeof(struct surface) % 8);
   topo->sf.sftail =(struct surface *) memo->current;
   memo->current  += sizeof(struct surface);
   if((sizeof(struct surface) % 8) !=NULL)
      memo->current += 8 - (sizeof(struct surface) % 8);
   (topo->sf.sfhead)->next =topo->sf.sftail;
   (topo->sf.sftail)->next =topo->sf.sfhead;
   topo->sf.num_sf         = NULL;
 
/*
   Initialize edge list, if there is atleast memory available for
   the list header and tail;
   if not add an element to the memory management list and go on
*/
   if((BASIC_SIZE - (memo->current - memo->p)) <=
      (2*sizeof(struct edge) + 16))
   {
      sts  = TOadd_mo(topo);
      if(sts)
         return(-1);
      memo = topo->mo.motail->next;
   }
   topo->ed.ehead  = (struct edge *) memo->current;
   memo->current += sizeof(struct edge);
   if((sizeof(struct edge) % 8) !=NULL)
      memo->current += 8 - (sizeof(struct edge) % 8);
   topo->ed.etail  =(struct edge *) memo->current;
   memo->current += sizeof(struct edge);
   if((sizeof(struct edge) % 8) !=NULL)
      memo->current += 8 - (sizeof(struct edge) % 8);
   (topo->ed.ehead)->next = topo->ed.etail;
   (topo->ed.etail)->next = topo->ed.ehead;
   topo->ed.num_ed        = NULL;
/*
   Initialize point list, if there is atleast memory available for
   the list header and tail;
   if not add an element to the memory management list and go on
*/
   if((BASIC_SIZE - (memo->current - memo->p)) <=
      (2*sizeof(struct point) + 16))
   {
      sts  = TOadd_mo(topo);
      if(sts)
         return(-1);
      memo = topo->mo.motail->next;
   }
   topo->pt.phead  = (struct point *) memo->current;
   memo->current += sizeof(struct point);
   if((sizeof(struct point) % 8) !=NULL)
      memo->current += 8 - (sizeof(struct point) % 8);
   topo->pt.ptail  =(struct point *) memo->current;
   memo->current += sizeof(struct point);
   if((sizeof(struct point) % 8) !=NULL)
      memo->current += 8 - (sizeof(struct point) % 8);
   (topo->pt.phead)->next = topo->pt.ptail;
   (topo->pt.ptail)->next = topo->pt.phead;
   topo->pt.num_pt        = NULL;

   return(0);
}
