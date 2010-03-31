/*
Name

    TOconnect

Abstract

    Find recursively super edges

Synopsis

int TOconnect( topo,status,num_se,sf1)

struct topology *topo;		main structure for topological data
short           *status;
short           *num_se;        total number of generated super edges
struct surface  *sf1;

Description


Return Value

    sts = NULL	if succesful

Notes

Index

Keywords

History

    01 Mar 94   B.Burkhardt     Creation
*/

#include <stdio.h>
#include <string.h>
#include "TOstruct1.h"
#include "TOtopology.h"
#include "TOproto_ta.h"

int TOconnect( struct topology *topo,
               short *status, short *num_se,struct surface *sf1)
{
   int j, jj;
   int sts = 0;
   struct surface *sf2;
   struct top_edge *te;
   struct point *pt;
   struct point *p1[2];
   struct plist *pltemp;
   struct elist *feltemp;
   struct telist *teltemp;
   struct top_point *tpt[2];

/*
   start with the first edge in the edge list of the current surface
   while the last edge in the surface edge list is not reached, do
*/
   feltemp = sf1->elehead->next;
   while(feltemp != sf1->eletail)
   {
/*
      the edge has a neighbour and is not used as element
      of a super edge
*/    
      if(((feltemp->ied->num_te != NULL)&&
          (feltemp->ied->status  > NULL)  )||
         (feltemp->ied->status  == 10     )  )
      {  
         teltemp = feltemp->ied->elehead->next;
         while((teltemp != feltemp->ied->eletail) &&
               (teltemp->ied->status > NULL))
         {
            te         = teltemp->ied;
            *status = *status - 1;
/*
            the standard case is manifold geometry;
            the top edge has two members
*/
            if(te->num_ele == 2)    
            {
/*
               Use the free edges in the end points of the top edge
               and try to build super edges.
               tpt[0:1] are the topological points at start and end
               of the top edge.
               investigations are only done when the top points
               are outer points.
*/
               tpt[0] = te->elehead->next->ied->p1->tp;
               tpt[1] = te->elehead->next->ied->p2->tp;
               for(j=0; j<2; j++)
               {
                  jj    = 0;
                  p1[0] = NULL;
                  p1[1] = NULL;
                  if(tpt[j]->status > 2)
                  continue;
                  pltemp = tpt[j]->elehead->next;
/*
                  for all elements of the point list, do
*/
                  while(pltemp != tpt[j]->eletail)
                  {
/*
                     edge status <0 ==> edge is member of a super edge
                     edge status =0 ==> edge is degenerated
*/
                     if(pltemp->ipt->ed->status <= NULL)
                     {
                        pltemp  = pltemp->next;
                        continue;
                     }
                     if(((pltemp->ipt->ed->status > NULL)&&
                        ((pltemp->ipt->ed != te->elehead->next->ied)&&
                        (pltemp->ipt->ed != te->elehead->next->next->ied)))&&
                        (!p1[0] || !p1[1]))
                     {
/*
                        take the corresponding point of the edge not in tpt[j]
*/
                        pt = pltemp->ipt->ed->p1;
                        if(pt->tp == tpt[j])
                        pt = pltemp->ipt->ed->p2;
/*
                        ... and ask if it is an outer point
*/
                        if(pt->status > 2)
                           continue;
                        p1[jj++] = pt;
                     }/*end of if(tpt...*/   
                     pltemp  = pltemp->next;
                  }/*end of while(pltemp != tpt[j]->eletail)*/
/*
                  two points for a super edge are found
*/
                  if(p1[0] != NULL && p1[1] != NULL &&
                     p1[0]->tp != p1[1]->tp && 
                     p1[0]->tp != tpt[j] && p1[1]->tp != tpt[j])
                  {
                     sts = TOsuper_ed(topo,p1,num_se);
                     if(sts<NULL)
                        goto wrapup;
                     if(sts > NULL)
                        *status = *status + 1;
                  }/*end of if(p1...*/    
               }/*end of for(j=...*/    
               te->status = NULL; 
/*
               All top edges are investigated
*/
               if(*status == NULL)
               {
                  sts = NULL;
                  goto wrapup;
               }
/*
               continue recursion with a neighbour of the current surface.
               use  
*/
               sf2 = teltemp->ied->elehead->next->ied->sf;
               if((sf2 == NULL) || (sf1 == sf2))
                  sf2 = teltemp->ied->elehead->next->next->ied->sf;
               if(sf2 == NULL)
               {
                  sts = *num_se;
                  goto wrapup;
               }  
               sts = TOconnect(topo,status,num_se, sf2);
               if(sts)
               {
                  goto wrapup;
               }
            }/*end of if(te->num_ele == 2 */
            else /* case ramifications, not implemented yet */
            {
               teltemp = feltemp->ied->eletail;
            } /*end of if(te->num_te == 2) */
         }/*end of if(sf1...*/
      }/*end of while(teltemp..*/
      feltemp = feltemp->next; 
   }/*end of while(feltemp != sf1->eletail)*/
   sts = NULL;
wrapup:
   return(sts);
}

