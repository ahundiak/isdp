/*
Name

    TOsplit_ed

Abstract

    All free edges ending in one topological point will be 
    investigated for splitting

Synopsis

int TOsplit_ed(topo)

    struct topology *topo; 	main data structure for the topology
 

Description

Return Value
    sts = 0			if process succesful

Notes

History

    04 Jan 94   B.Burkhardt     Creation
    04 May 94   B.Burkhardt     Special for degenerated edges
*/
#include <stdio.h>
#include <string.h>
#include <time.h>
#undef clock
#include "TOstruct1.h"
#include "TOtopology.h"
#include "TOproto_ta.h"

int TOsplit_ed( struct topology *topo)

{
   int              sts = NULL;
   short            ii = NULL;
   short            num_ii = NULL;
   short            sti_option = 1; /* activate range check */ 
   struct top_point *tptemp;
   struct plist     *pltemp;
   struct edge      **edge_list = NULL;
   struct edge      *etemp;
   struct edge      *seid;
   struct elist     *selhead;
   struct elist     *seltail;
   struct elist     *seltemp;
#ifdef DBG
   printf("TOsplit_ed\n");
#endif
   sti_option = 1; /* activate range check in TOedstitch.I
                      called in TOstitch_ed use topo tolerance split*/ 
/*
   if list is empty goto wrapup
   else investigate all list elements
   top points with state = 2 and state >3 may have unsatisfied members
*/
   tptemp = topo->tp.tphead;
   if(tptemp->next == topo->tp.tptail)
      goto wrapup;
   while((tptemp=tptemp->next) != topo->tp.tptail)
   {
      if(tptemp->status == 2 || tptemp->status > 3)
      {
         sts = TOinit_el(topo,&selhead,&seltail);
         if(sts)
            goto wrapup;
/*
         fill edge_list with all edges ending in the current
         top point;  
*/
         pltemp = tptemp->elehead;
         while((pltemp=pltemp->next) != tptemp->eletail)
         {
            if(pltemp->ipt->ed->status > NULL &&
               pltemp->ipt->ed->status != 9)
            {
               if(pltemp->ipt->ed->status == 2)
               {
                  seid = pltemp->ipt->ed;
                  etemp = pltemp->ipt->ed;
                  sts = TOlist_se(topo,seltail,&num_ii,seid,etemp);
                  if(sts)
                     goto wrapup;
               }
               else if((pltemp->ipt->ed->status == 1 ||
                        pltemp->ipt->ed->status == 10)||
                       (pltemp->ipt->ed->status == 4 &&
                        !pltemp->ipt->ed->num_te))
               {
                  sts = TOadd_el(topo,seltail,pltemp->ipt->ed);
                  if(sts)
                     goto wrapup;
                  num_ii++;
               } /* if(pltemp->ipt->ed->status == 2) */
            } /* if(pltemp->ipt->ed->status > NULL) */
         } /* while((pltemp=pltemp->next) != tptemp->eletail) */
         if(num_ii)
         {
            edge_list = (struct edge **)malloc(num_ii*sizeof(struct edge *));
            if(edge_list == NULL)
            {
               sts = -1;
               goto wrapup;
            }
            ii      = NULL; 
            seltemp = selhead;
            while((seltemp=seltemp->next) !=seltail)
               edge_list[ii++] = seltemp->ied;
            sts = TOcomp_elist(topo,sti_option,ii,edge_list);
            if(sts)
               goto wrapup;
         } /* if(num_ii) */
/*
         free elements of list 
*/
         if(edge_list != NULL)
         {
            free(edge_list);
            edge_list = NULL;
         }
      } /* tptemp->status == 2 || >3 */   
      tptemp->status = 1;
   } /* tptemp!=top->tp.tptail */
   sts = NULL;
wrapup: 
   if(edge_list != NULL)
      free(edge_list);
   return(sts);
}
