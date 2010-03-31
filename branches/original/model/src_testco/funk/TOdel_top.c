/*
Name

    TOdelete_top

Abstract

    Delete the core topology and free all allocated memory

Synopsis

    TOdelete_top(topo)

    struct topologu *topo;	    tail of edge list	

Description

Return Value

Notes

History

    07 Mar 94   B.Burkhardt    	Creation
*/

#include <stdio.h>
#include <string.h>
#include "TOtopology.h"
#include "TOstruct1.h"
#include "TOproto_ta.h"
#include "TOnumbers.h"

int TOdelete_top(struct topology *topo)

{
   struct memory *temp;	    
   struct surface *tempsf;	    
   struct edge *temped;	    

#ifdef DBG
   printf("TOdelete_top\n");
#endif

   /* loop for all surface and delete external data */
   tempsf = topo->sf.sfhead;
   while((tempsf = tempsf->next) != topo->sf.sftail)
   {
      TOdelete_ext_surf(tempsf->ext);
   }

   /* loop for all edges and delete external data */
   temped = topo->ed.ehead;
   while((temped = temped->next) != topo->ed.etail)
   {
      TOdelete_ext_edge(temped->ext);
   }


   temp = topo->mo.mohead->next;
/*
   while the last element in the memory list is not reached, do
*/
   while(temp != topo->mo.motail)
   {
     
/*
      free memory
*/
      if (temp->p)free((char *)temp->p);
      temp    = temp->next;
   }
/*
   free memory list
*/
   while(topo->mo.mohead->next != topo->mo.motail)
   {
      temp                  = topo->mo.mohead->next;
      topo->mo.mohead->next = topo->mo.mohead->next->next;
      free((struct memory *)temp);
   }
   free((struct memory *)topo->mo.mohead);
   free((struct memory *)topo->mo.motail);

/*
   Initialize struct topology
*/
   topo->sf.sfhead = NULL;
   topo->sf.sftail = NULL;
   topo->sf.num_sf = NULL;

   topo->ed.ehead = NULL;
   topo->ed.etail = NULL;
   topo->ed.num_ed = NULL;

   topo->pt.phead = NULL;
   topo->pt.ptail = NULL;
   topo->pt.num_pt = NULL;

   topo->tp.tphead = NULL;
   topo->tp.tptail = NULL;
   topo->tp.num_tp = NULL;

   topo->te.tehead = NULL;
   topo->te.tetail = NULL;
   topo->te.num_te = NULL;

   topo->mo.mohead = NULL;
   topo->mo.motail = NULL;
   
   return(NULL);
}
