/*
Name

    TOcomp_elist

Abstract

    All edges in a given list will be 
    investigated for splitting

Synopsis

int TOcomp_elist(topo,sti_option,num_ii,edge_list)

    struct topology *topo; 	main data structure for the topology
    short           sti_option; kind of edge comparing, see TOedstitch.I
    short           num_ii;     number of list elements in edge_list
    struct edge     **edge_list;list of edge pointers to compare 

Description

Return Value
    sts = 0			if process succesful

Notes

History

    04 Jan 94   B.Burkhardt     Creation
    20 May 94   B.Burkhardt     special for closed edges
*/
#include <stdio.h>
#include <string.h>
#include <time.h>
#undef clock
#include "TOstruct1.h"
#include "TOtopology.h"
#include "TOproto_ta.h"

int TOcomp_elist( struct topology *topo,
                  short           sti_option,
                  short           num_ii,
                  struct edge     **edge_list) 

{
   short              ii  = NULL;
   short              jj  = NULL;
   int                sts = NULL;
   struct edge      **edge_list1 = NULL;
   struct elist *selhead;
   struct elist *seltail;
   struct elist *seltemp;

   for(ii=0; ii<num_ii; ii++)
   {
      for(jj=ii+1; jj<num_ii; jj++)
      {
/* 
         rules for selection of edge paires to compare:
         - edges of one surface only if both edges marked as seam
         - not the edge with itself
         - edge is not part of a top edge
         - edge is not a super edge
         - edges are not members of the same super edge (stored in edid2)
         - if all free edges are to investigate don't use neighbors
*/
         if((edge_list[ii]->edid0 != edge_list[jj]->edid0 &&
             edge_list[ii]->num_te == NULL &&
             edge_list[jj]->num_te == NULL &&
             edge_list[ii]->status !=  2 && edge_list[jj]->status !=  2 &&
             edge_list[ii]->status != -2 && edge_list[jj]->status != -2 )||
            ((edge_list[ii]->status <= NULL &&
              edge_list[ii]->edid2 != edge_list[jj]->edid2)||
             (edge_list[jj]->status <= NULL &&
              edge_list[ii]->edid2 != edge_list[jj]->edid2)))
         { 
/*
            if edge is parent of part edges use the part edges for stitching
*/
            if(edge_list[ii]->status != 3 &&
               edge_list[jj]->status != 3)
            {
               sts = TOstitch_ed(topo,sti_option,
                                 edge_list[ii],edge_list[jj],
                                 NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
               if(sts<NULL)
                  goto wrapup;
            }/* status!=3 */
            else
            { /* case status =3 */
               short i1     = NULL;
               short num_pe = NULL;

               sts = TOinit_el(topo,&selhead,&seltail);
               if(sts)
                  goto wrapup;
               if(edge_list[ii]->status == 3)
               {
                  sts = TOlist_pe(topo,seltail,&num_pe,edge_list[ii]);
                  if(sts)
                     goto wrapup;
               }
               else
               {
                  sts = TOadd_el(topo,seltail,edge_list[ii]);
                  if(sts)
                     goto wrapup;
                  num_pe++;
               }
               if(edge_list[jj]->status == 3)
               {
                  sts = TOlist_pe(topo,seltail,&num_pe,edge_list[jj]);
                  if(sts)
                     goto wrapup;
               }
               else
               {
                  sts = TOadd_el(topo,seltail,edge_list[jj]);
                  if(sts)
                     goto wrapup;
                  num_pe++;
               }
               if(num_pe)
               {
                  edge_list1 = (struct edge  **)
                               malloc(num_pe*sizeof(struct edge*));
                  if(edge_list1 == NULL)
                  {
                     sts = -1;
                     goto wrapup;
                  }
               }
               seltemp=selhead;
               while((seltemp=seltemp->next) !=seltail)
               {
                  if(!seltemp->ied->num_te)
                  edge_list1[i1++] = seltemp->ied;
               }
               sts = TOcomp_elist(topo,sti_option,i1,edge_list1);
               if(sts)
                  goto wrapup;
               continue;
            }
         }
      } /* for(jj=...*/
   } /* for (ii=... */
   sts = NULL;
wrapup: 
   if(edge_list1 != NULL)
      free(edge_list1);
   return(sts);
}
