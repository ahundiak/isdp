/*
Name
	TOadd_mo

Abstract
	add one element to the linked list for memory management
	
Synopsis
	
   	sts = TOadd_mo(topo)

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
#include "TOstruct1.h"
#include "TOtopology.h"
#include "TOproto_ta.h"
#include "TOnumbers.h"

int TOadd_mo(struct topology *topo)
{
   struct memory   *new_mo = NULL;
#ifdef DBG
   printf("TOadd_mo called\n");
#endif
   new_mo = (struct memory *)malloc(sizeof(struct memory));
   if(new_mo == NULL)
   {
#ifdef DBG
printf("Memory allocation failed in TOadd_mo\n");
#endif
      return(-1);
   }  
   (topo->mo.motail)->next->next = new_mo;
   (topo->mo.motail)->next       = new_mo;
   new_mo->next                 = topo->mo.motail;
   new_mo->p                    = (char *)malloc(BASIC_SIZE);
   if(new_mo->p == NULL)
   {
#ifdef DBG
printf("Memory allocation failed in TOadd_mo\n");
#endif
      return(-1);
   }  
   new_mo->current              = new_mo->p;

   return(0);
}
