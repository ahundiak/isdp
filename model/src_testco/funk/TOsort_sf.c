/*
Name

    TOsort_sf

Abstract

    Find recursively common edges containing single edges and/or
    'super edges' 

Synopsis

int TOsort_sf(topo,num_se)

struct topology *topo;		main structure for topological data
short           *num_se;        total number of generated super edges

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

int TOsort_sf(struct topology *topo,
              short *num_se)
{
   short           status;
   int             sts = 0;
   struct elist    *tetemp;
   struct top_edge *te;
   struct surface  *sf1;

#ifdef DBG
   printf("TOsort_sf\n");
#endif
   if(topo->te.tehead->next == topo->te.tetail)/* top edge list is empty*/
   {
      return(0);
   }
/*
   take a first surface for investigations;
   use the first top edge in the list
   status is the count for the number of top edges which are 
   not investigated yet
*/ 
   status  = topo->te.num_te;
   te      = topo->te.tehead->next;
   sf1     = te->elehead->next->ied->sf;   
/*
   while atleast one top edge which is not investigated, do
*/
   while(status)
   {
      sts = TOconnect(topo,&status,num_se, sf1);
      if(sts)
      {
         goto wrapup;
      }

      te  = te->next;
/*
      sf1=0 for start initialization;
      while not all top edges are investigated, do
*/
      sf1 = NULL;
      while((!sf1)&&(te!=topo->te.tetail))
      {
/*
         while not the last element is reached and the top edge
         is investigated, take the next in the list
*/
         while((te != topo->te.tetail)&&(te->status == NULL))
            te  = te->next;

         tetemp = te->eletail;
         if(te != topo->te.tetail)
            tetemp = te->elehead->next;
         while(!sf1 && (tetemp != te->eletail))
         {
            sf1    = tetemp->ied->sf;  
            tetemp = tetemp->next; 
         }  
         if(te == topo->te.tetail)status = NULL;
      } /* while((!sf1)&&(te!=topo->te.tetail)) */
      if(te == topo->te.tetail)status = NULL;
   } /* while(status) */
   sts = NULL;
wrapup:
   return(sts);
}

