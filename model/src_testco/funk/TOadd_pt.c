

/*
Name
	TOadd_pt

Abstract
	add one point to the linked list
	
Synopsis
	
sts = TOadd_pt(topo,status,pt,ed,tp)
             struct topology  *topo,
             short            status,
             double           pt[3],
             struct edge      *ed,
             struct top_point *tp);

Description
 
	Input:
    	status 		state of the edge generation state is status = 1
    	x      		x- coordinate of the point
    	y      		y- coordinate of the point
    	z      		z- coordinate of the point
    	*ed		reference to the edge
    	*tp		reference to the topological point

	Output:

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

int TOadd_pt( struct topology  *topo,
            short            status,
            double           pt[3],
            struct edge      *ed,
            struct top_point *tp)
 
{
   int          sts;
   struct point *pp = NULL; 
   struct memory  *memo = NULL;

   if(topo->pt.phead == NULL)
   {
      return(-1);
   }
/*
   Add a point to the list if there is memory available
   if not then add an element to the memory management list and go on
*/
   memo = (topo->mo.motail)->next;
   if((BASIC_SIZE -(memo->current - memo->p)) <
      (sizeof(struct point) + 8 - (sizeof(struct point)% 8 )))
   {
      sts = TOadd_mo(topo);
      if(sts)
      {
/* memory allocation failed */
         return(-1);
      }
   memo = (topo->mo.motail)->next;
   }

   pp             = (struct point *) memo->current;
   memo->current += sizeof(struct point);
   if((sizeof(struct point) % 8) !=NULL)
      memo->current += 8 - (sizeof(struct point) % 8);

   topo->pt.num_pt             += 1;
   (topo->pt.ptail)->next->next = pp;  
   (topo->pt.ptail)->next       = pp;  
   pp->next                     = topo->pt.ptail;
   pp->status                   = status;
   pp->x                        = pt[0];
   pp->y                        = pt[1];
   pp->z                        = pt[2];
   pp->ed                       = ed;
   pp->tp                       = tp;

   return(0);
}

