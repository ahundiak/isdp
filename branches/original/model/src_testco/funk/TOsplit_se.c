/*
Name

    TOsplit_se

Abstract

    All elements of a top edge containing atleast one
    super edge will be investigated for splitting

Synopsis

int TOsplit_se(topo)

    struct topology *topo; 	main data structure for the topology
 

Description

Return Value
    sts = 0			if process succesful

Notes

History

    04 Jan 94   B.Burkhardt     Creation
*/
#include <stdio.h>
#include <string.h>
#include <time.h>
#undef clock
#include "TOstruct1.h"
#include "TOtopology.h"
#include "TOproto_ta.h"

int TOsplit_se( struct topology *topo,
                struct edge *ed1,
                struct edge *ed2)

{
   int              sts = NULL;
   int              i = NULL;
   short            ii = NULL;
   short            num_te_tmp = NULL;
   short            num_ii = NULL;
   short            sti_option = 1; /* activate range check */ 
   struct edge      **edge_list = NULL;
   struct edge      *ed[2];
   struct elist     *selhead;
   struct elist     *seltail;
   struct elist     *seltemp;
#ifdef DBG
   printf("TOsplit_se\n");
#endif
   sti_option = 1; /* activate range check in TOedstitch.I
                      called in TOstitch_ed use topo tolerance split*/ 
   num_te_tmp = topo->te.num_te;

   sts = TOinit_el(topo,&selhead,&seltail);
   if(sts)
      goto wrapup;
/*
   fill edge_list with all edges ending in the current
   top point;  
*/
   for(i=0;i<2;i++)
      ed[i] = NULL;
   ed[0] = ed1;
   ed[1] = ed2;
   for(i=0;i<2;i++)
   {
      if(!ed[i])
      {
         sts = -1;
         goto wrapup;
      }
      if(ed[i]->status == 2)
      {
         sts = TOlist_se(topo,seltail,&num_ii,ed[i],ed[i]);
         if(sts)
            goto wrapup;
      }
      else if(ed[i]->status == 1)
      {
         sts = TOadd_el(topo,seltail,ed[i]);
         if(sts)
            goto wrapup;
         num_ii++;
      }
   }
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
      {
         sts = -1;
         goto wrapup;
      }
   } /* if(num_ii) */
   sts = NULL;
   if(topo->te.num_te>num_te_tmp)
      sts = 1;
wrapup: 
/*
   free all elements of list selhead,seltail !!!!!!!!!!
*/
   if(edge_list != NULL)
      free(edge_list);
   return(sts);
}
