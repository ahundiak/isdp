/*
Name
	TOadd_ed

Abstract
	add one edge to the linked list
	
Synopsis
	
    sts = TOadd_ed(topo,ext,status,edid0,edid1,edid2,sf,
                 p1,p2,num_te,elehead,eletail)

    struct topology *topo;
    Ext_data_edge        *ext;
    short           status;
    struct edge     *edid0;
    struct edge     *edid1;
    struct edge     *edid2;
    struct surface  *sf;
    struct point    *p1;
    struct point    *p2;
    short           num_te;
    struct telist   *elehead;
    struct telist   *eletail;


Description
 
	Input:
        ext		reference to EMS dependent edge geometry data
    	status 		state of the edge generation state is status = 1
    	*edid0 		pointer to an edge or super edge 
    	*edid1 		pointer to an edge or super edge 
                        building the current  one
    	*edid2 		=NULL for a simple edge;
                        for a super edge the pointer to a edge or super edge
    	*sf		reference to the surface 
    	*p1		reference to one end point of the edge
    	*p2		reference to the second end point of the edge
    	num_te		number of topological edges referencing the current
                        edge

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
	B. Burkhardt	21/06/94	Improve comment
*/
		
#include <stdio.h>
#include <string.h>
#include "TOstruct1.h"
#include "TOtopology.h"
#include "TOproto_ta.h"
#include "TOnumbers.h"

int TOadd_ed(struct topology *topo,
             struct Ext_data_edge *ext,
             short           status,
             struct edge     *edid0,
             struct edge     *edid1,
             struct edge     *edid2,
             struct surface  *sf,
             struct point    *p1,
             struct point    *p2,
             short           num_te,
             struct telist   **elehead,
             struct telist   **eletail)
 
{
   
   int            sts;
   struct edge    *ee;
   struct memory  *memo = NULL;

   if(topo->ed.ehead == NULL)
   {
      return(-1);
   }
/*
   Add edge to list if there is memory available
   if not then add an element to the memory management list and go on
*/
   memo = (topo->mo.motail)->next;
   if(memo == NULL)
   {
     return(-1);
   }
   if((BASIC_SIZE -(memo->current - memo->p)) <
      (sizeof(struct edge) + 8 - (sizeof(struct edge)% 8 )))
   {
      sts = TOadd_mo(topo);
      if(sts)
      {
         return(-1);
      }
      memo = (topo->mo.motail)->next;
   }

   ee             = (struct edge *) memo->current;
   memo->current += sizeof(struct edge);
   if((sizeof(struct edge) % 8) !=NULL)
      memo->current += 8 - (sizeof(struct edge) % 8);

   topo->ed.num_ed             += 1;
   (topo->ed.etail)->next->next = ee;  
   (topo->ed.etail)->next       = ee;  
   ee->next                     = topo->ed.etail;
   ee->ext                      = ext;
   ee->status                   = status;
   if(edid0 == NULL)
      ee->edid0                    = ee;
   else
      ee->edid0                    = edid0;
   ee->edid1                    = edid1;
   ee->edid2                    = edid2;
   ee->sf                       = sf;
   ee->p1                       = p1;
   ee->p2                       = p2; 
   ee->num_te                   = num_te; 
/*
   initialize the telist for the current edge
*/
   sts = TOinit_tl(topo,elehead,eletail);
   if(sts)
   {
     return(-1);
   }

   ee->elehead       = *elehead;
   ee->eletail       = *eletail;

   return(0);
}

