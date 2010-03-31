/*
Name
	TOinit_mo

Abstract
	allocation of memory
	initialization of the memory list: 
	define list header and tail;
	the next element after the header is the tail;
	the next element after the tail is the header ==> list is empty;
	
Synopsis
	
	sts = TOinit_mo(topo)
	
	struct topology *topo;

Description
 
	Input:

	Output:

Return Values

	sts

Notes

Index

Keywords

History
	B. Burkhardt	11/11/93	Creation date.
*/
		
#include <stdio.h>
#include <string.h>
#include "TOtopology.h"
#include "TOstruct1.h"
#include "TOproto_ta.h"
#include "TOnumbers.h"


int TOinit_mo(struct topology *topo)
{
int             sts;

#ifdef DBG
printf("TOinit_mo\n");
#endif
   topo->mo.mohead  = (struct memory * )malloc(sizeof(struct memory ));
   if(topo->mo.mohead == NULL)
      return(-1);
   topo->mo.motail  = (struct memory * )malloc(sizeof(struct memory ));
   if(topo->mo.motail == NULL)
   {
      return(-1);
   }
   topo->mo.mohead->next = topo->mo.motail;
   topo->mo.motail->next = topo->mo.mohead;

   sts = TOadd_mo(topo);
   if(sts)
   {
      return(-1);
   }

   /* initialize the free lists */
   topo->fl.free_surface   = NULL;
   topo->fl.free_edge      = NULL;
   topo->fl.free_point     = NULL;
   topo->fl.free_top_point = NULL;
   topo->fl.free_top_edge  = NULL;

   topo->fl.free_elist   = NULL;
   topo->fl.free_plist   = NULL;
   topo->fl.free_telist  = NULL;

   return(0);
}
