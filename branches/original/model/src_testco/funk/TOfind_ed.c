/*
Name

    TOfind_ed

Abstract

    use a super edge to find a top edge with another edge or super edge
    if succesfull continue with TOsuper_ed

Synopsis

int TOfind(topo, num_se, ed)

    struct topology  *topo;	main data structure for the topology
    short            *num_se;	the current number of super edges
    struct edge      *ed;	the pointer to the super edge

Description


Return Value

    sts = 0	if process succesful

Notes

Index

Keywords

History

    22 Feb 94   B.Burkhardt     Creation
*/

#include <stdio.h>
#include <string.h>
#include "TOstruct1.h"
#include "TOtopology.h"
#include "TOproto_ta.h"

int TOfind_ed(struct topology *topo,
              short           *num_se,
              struct edge     *ed)

{
   short            j   = 1;
   short            jte = 1;
   short            jj  = NULL;
   int              sts = NULL;
   struct point     *pt;
   struct point     *p1[2];
   struct top_point *tpt[2];
   struct edge      *etemp1;
   struct plist     *pltemp;
/*
   check the top points of the current edge;
   if their status is 1 they are ready;
*/
   if(ed->p1->tp->status>1 && ed->p2->tp->status>1)
   {
      jte = 1;
/*
      investigate all edges starting in the first top point
       if their is one ending in the second top point
*/
      pltemp = ed->p1->tp->elehead->next;
      while(pltemp != ed->p1->tp->eletail)
      {
/*
         the edge is different from the current and doesn't belong
         to a top edge; you can check if the top points identical
*/
         if((((pltemp->ipt->ed        != ed)&&
              (pltemp->ipt->ed        != ed->edid0)&&
              (pltemp->ipt->ed        != ed->edid1)&&
              (pltemp->ipt->ed        != ed->edid2))&&

             (pltemp->ipt->ed->num_te == NULL))&&
 
            ((pltemp->ipt->ed->p1->tp == ed->p2->tp) || 
             (pltemp->ipt->ed->p2->tp == ed->p2->tp))) 
         {
/*
            part edge processing for two edges;
            each of them can be an edge or super edge;
*/
            sts = TOsplit_se(topo,pltemp->ipt->ed,ed);
            if(sts <NULL)
            {
               goto wrapup;
            }
            else if(sts) /* top edge found */
            {
               jte++;
               ed->status = -ed->status;
               etemp1         = pltemp->ipt->ed;
               etemp1->status = -etemp1->status;
               ed->p1->tp->status = ed->p1->tp->status - 1;
               ed->p2->tp->status = ed->p2->tp->status - 1;
            }
#ifdef TEST_RAMIF
            if(jte>2) /* case jte>2 ramifications not implemented yet
                       the top edge exists already; ad an element */  
            {
               jte++;
               etemp1             = pltemp->ipt->ed;
               sts = TOsplit_se(topo,pltemp->ipt->ed,ed);
               if(sts<NULL)
               {
                  goto wrapup;
               }
               else if(sts)
               {
                  etemp1->status     = -etemp1->status;
                  ed->p1->tp->status = ed->p1->tp->status - 1;
                  ed->p2->tp->status = ed->p2->tp->status - 1;
               }/*if(sts<NULL) */
            }/*end of jte>2 */    
#endif
         }/* end if(((ed->p1... common end points */
         pltemp = pltemp->next;
      }/* end while(pltemp != ed->.....  over all elements of top point */
   }/* end if(ed->p1... check the number of elements in tp */

/*
   if top edge creating was succesful try to build super edges
   at the end points of the new top edge
*/
   if(jte == 2)
   {
      tpt[0] = ed->p1->tp;
      tpt[1] = ed->p2->tp;
      for(j=0; j<2; j++)
      {
         jj    = 0;
         p1[0] = NULL;
         p1[1] = NULL;
         if(tpt[j]->status > 2)  /* only outer points are of interest */
            continue;
/*
         over all members of the top point
*/
         pltemp = tpt[j]->elehead;
         while((pltemp=pltemp->next) != tpt[j]->eletail && jj<2)
         {
/*
            if edge is part of super edge or top edge continue
*/
            if(pltemp->ipt->ed->status <= NULL)
               continue; 
/* 
            look if the top points of the complement edge end points
            are outer points
*/
            if(pltemp->ipt->ed->status > NULL &&
               pltemp->ipt->ed->status != 2 &&
               pltemp->ipt->ed->status != 3 &&
               pltemp->ipt->ed->status != 4)
            {
               pt = pltemp->ipt->ed->p1;
               if(pt->tp == tpt[j])
               pt = pltemp->ipt->ed->p2;
               if(pt->tp->status > 2)
                  continue;
               p1[jj++] = pt;
            }/*end of if(tpt...*/
         }/* while((pltemp=pltemp->next) != tpt[j]->eletail && jj<2) */
         if(p1[0] != NULL && p1[1] != NULL &&
            p1[0]->tp != p1[1]->tp &&
            p1[0]->tp != tpt[j] && p1[1]->tp != tpt[j])

         {   
            sts = TOsuper_ed(topo,p1,num_se);
            if(sts < NULL)
               goto wrapup;
#ifdef TEST_RECURS
            if(sts >= NULL)
            {
               printf("super edge %d : ",*num_se);
               printf("p1= %6.3f %6.3f %6.3f p2= %6.3f %6.3f %6.3f\n",
               p1[0]->x,p1[0]->y,p1[0]->z,p1[1]->x,p1[1]->y,p1[1]->z);
            } 
#endif
         }/*end of if(p1...*/
      }/*end of for(j=...*/
   }/* if(num_te_el> 0) */    
   sts = NULL;
wrapup:
   return(sts);
}
