/*
Name

    TOinvfred

Abstract

    All free edges will be investigated for splitting

Synopsis

int TOinv_fre_ed(topo)

    struct topology *topo; 	main data structure for the topology
 

Description

Return Value
    sts = 0			if process succesful

Notes

History

    04 Mar 94   B.Burkhardt     Creation
*/
#include <stdio.h>
#include <string.h>
#include <time.h>
#undef clock
#include "TOstruct1.h"
#include "TOtopology.h"
#include "TOproto_ta.h"

int TOinv_fre_ed( struct topology *topo)

{
   int          sts = NULL;
   short        i = NULL;
   short        num_ii = NULL;
   short        sti_option = 11; /* activate range check */ 
   struct edge  **edge_list = NULL;
   struct edge  *etemp;
   struct edge  *seid;
   struct elist *selhead;
   struct elist *seltail;
#ifdef DBG
   printf("TOinv_fre_ed\n");
#endif
/*
   check if list is empty
*/
   etemp  = topo->ed.ehead;
   if(etemp->next == topo->ed.etail)
      goto wrapup;
/* 
   Initialize an edge element list for the members of the outer boundary;
*/
   sts = TOinit_el(topo,&selhead,&seltail);
   if(sts)
   {
      goto wrapup;
   }
/*
   investigate all edges; find all free edges as members of the
   outer boundary
   search for all edges with an empty top edge list and
   which are not element of a super edge
*/
   num_ii = 0;
   while((etemp=etemp->next) != topo->ed.etail)
   {
      if(etemp->num_te == NULL && etemp->status > NULL &&
                                  etemp->status != 9)
      {
/*
         if super edge find basic elements recursively
*/
         if(etemp->status == 2)
         {
            seid = etemp;
            sts = TOlist_se(topo,seltail,&num_ii,seid,etemp);
            if(sts)
               goto wrapup;
         }
   
/*
         don't use part edges; the system will find it's members
         in the edge list
*/
         else if(etemp->status != 3 && etemp->ext)
         {
            sts = TOadd_el(topo,seltail,etemp);
            if(sts)
            {
               goto wrapup;
            }
            num_ii++;
         }
      }
   }
   if(num_ii)
   {
      int num_max;
      struct elist * temp;
      temp = selhead;
 
      num_max = num_ii;
/*
      parts of a super edges may be members of topological edges
      remove them because ramifications are not investigated!
*/
      while(temp->next != seltail)
      {
         while(temp->next->ied->num_te)
         {
            num_ii--;
            if(temp->next->next == seltail)
               break;
            temp->next = temp->next->next;
         }
         temp = temp->next;
      } /* while(temp->next != seltail) */
      if(seltail->next->ied->num_te)
      {
         seltail->next = seltail->next->next;
         num_ii--;
      }

      edge_list = (struct edge **)malloc(num_max* sizeof(struct edge *));
      if(edge_list == NULL)
      {
         sts = -1;
         goto wrapup;
      }
      i = 0;
      temp = selhead;
      while((temp=temp->next) != seltail && temp->ied->ext)
      {
         edge_list[i++] = temp->ied;
#ifdef TEST_INV
#endif
      }
      sts = TOcomp_elist(topo,sti_option,i,edge_list);
      if(sts)
         goto wrapup;
   }/* if(num_ii) */
   sts = NULL;
wrapup:
/*
   free list defined by selhead,seltail !!!!!!!!!!
*/
   if(edge_list != NULL) 
      free(edge_list);
   return(sts);
}
