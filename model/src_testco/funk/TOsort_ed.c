/*
Name

    TOsort_ed

Abstract

    Finds all edges of an arbitrary set of surfaces
    with common endpoints
    the list of topological points from TOsort_pt.c is used

Synopsis

int TOsort_ed(topo)

    struct topology 	*topo;		main data structure for topology	

Description


Return Value

    sts = 0	if process is succesful

Notes

Index

Keywords

History

    22 Feb 94   B.Burkhardt     Creation
    22 May 94   B.Burkhardt     don't reduce state of the top_point, when
                                edges are only connected at the end_points
*/
#include <stdio.h>
#include <string.h>
#include "TOstruct1.h"
#include "TOtopology.h"
#include "TOproto_ta.h"

int TOsort_ed(struct topology *topo)
{
   int i;
   int j;
   int sts;
   short sti_option = NULL; /* compare edges without range check */
   struct plist *tptemp ;
   struct edge *etemp1 ;
   struct edge *edtemp ;
   struct elist *elehead =NULL;
   struct elist *eletail =NULL;
   struct telist *teltemp;
   struct top_edge *tte=NULL;
#ifdef DBG
   printf("TOsort_ed \n");
#endif

   i            = 0;
/*
   return edge list is empty;
*/
   edtemp = topo->ed.ehead;
   if(edtemp->next == topo->ed.etail)
      return(-1);
/*
   loop over all edges
   find all edge pairs whith common end points;
   
*/
   while(((edtemp=edtemp->next) != topo->ed.etail))
   {
      if(edtemp->status != 10 && edtemp->status != 9 &&
         edtemp->p1->tp->status>1 && edtemp->p2->tp->status>1&&
         edtemp->p1->tp != edtemp->p2->tp)
      {
         j = 1;
/*
      use the edges starting in one tp and investigate if there are
      some ending in the second tp of the current edge 
*/
         tptemp = edtemp->p1->tp->elehead;
         while((tptemp=tptemp->next) != edtemp->p1->tp->eletail)
         {
/*
            no element in te list, tp's of etemp1 not identical
            but tp's for edtemp and etemp1 are identical
*/
            etemp1 = tptemp->ipt->ed;
            teltemp = etemp1->elehead->next;
            if((etemp1         != edtemp->edid0&&
                etemp1->status != 10 && edtemp->status != 10) &&
               (teltemp == etemp1->eletail &&
                etemp1->p1->tp != etemp1->p2->tp) &&
               (etemp1->p1->tp==edtemp->p2->tp || 
                etemp1->p2->tp==edtemp->p2->tp)) 
            {
               sts = TOstitch_ed(topo,sti_option,etemp1,edtemp,
                                 NULL, NULL, NULL, NULL, NULL, NULL,
                                 NULL, NULL, NULL);
               if(sts<NULL)
                  goto wrapup;
               if(!sts) /* stitch failed only ends connected*/
               {
                  etemp1->status = 10;
                  edtemp->status = 10;
#ifdef NOT_USED
                  edtemp->p1->tp->status = edtemp->p1->tp->status - 1;
                  edtemp->p2->tp->status = edtemp->p2->tp->status - 1;
#endif
               }
               else /* compare succesful */
               {
                  /* ramification curve, not implemented yet
                  if(j >2)
                  {
                     break;
                  } 
                  */
                  if(j == 1) /* create new top edge */
                  {
                     sts = TOadd_te(topo,1,1,&elehead,&eletail); 
                     if(sts)
                        goto wrapup;
                     tte = topo->te.tetail->next;
                  }
                  edtemp->p1->tp->status = edtemp->p1->tp->status - 1;
                  edtemp->p2->tp->status = edtemp->p2->tp->status - 1;
                  edtemp->num_te         = 1;
                  teltemp                = edtemp->eletail;
                  sts = TOadd_tl(topo,teltemp,tte);
                  if(sts)
                     goto wrapup;
                  etemp1->num_te         = 1;
                  teltemp                = etemp1->eletail;
                  sts = TOadd_tl(topo,teltemp,tte);
                  if(sts)
                     goto wrapup;
                  sts = TOadd_el(topo,eletail,edtemp);
                  if(sts)
                     goto wrapup;
                  sts = TOadd_el(topo,eletail,etemp1);
                  if(sts)
                     goto wrapup;
                  tte->status          = tte->status + 1;
                  tte->num_ele         = tte->num_ele + 1;
                  j++;
               }/* end of if(!sts)*/ 
            }/* end of if((etemp1...*/   
         }/* end of while(tptemp!=...ueber alle elemente des tp */
      }/* end of if(edtemp->... nur elemente in tp mit status>1*/
   }/* end of while(edtemp != etail) */
   sts = NULL;
wrapup:
   return(sts);
}
