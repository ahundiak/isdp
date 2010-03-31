/*
Name

    TOadd_pl

Abstract

    Add a point to the element list 'plist';
    'plist' belongs to an topological point and contains the addresses of all
    point referencing the current topological point;

Synopsis

    int TOadd_pl(topo,eletail,ipt);

    struct topology *topo;	main data structure for topology;
    struct plist    *eletail;	tail of the current plist, used
				for appending element;
    struct point    *ipt;	address of the point which is to
				append to the list;

Description


Return Value

    sts = NULL			if prcess is succesful;

Notes

Index

Keywords

History

    23 Feb 94   B.Burkhardt     Creation
*/

#include <stdio.h>
#include <string.h>
#include "TOstruct1.h"
#include "TOtopology.h"
#include "TOproto_ta.h"
#include "TOnumbers.h"

int TOadd_pl(struct topology  *topo,
             struct plist     *eletail,
             struct point      *ipt)
 
{
   int            sts;
   struct plist   *pl = NULL; 
   struct memory  *memo = NULL;

   if(eletail == NULL)
   {
      return(-1);
   }
/*
   Add a point to the element list if there is memory available;
   if not then add an element to the memory management list and go on;
*/
   memo = (topo->mo.motail)->next;
   if((BASIC_SIZE -(memo->current - memo->p)) <
      (sizeof(struct plist) + 8 - (sizeof(struct plist)% 8 )))
   {
      sts = TOadd_mo(topo);
      if(sts)
      {
/*       memory allocation failed */
         return(-1);
      }
   memo = (topo->mo.motail)->next;
   }

   pl             = (struct plist *) memo->current;
   memo->current += sizeof(struct plist);
   if((sizeof(struct plist) % 8) !=NULL)
      memo->current += 8 - (sizeof(struct plist) % 8);

   eletail->next->next = pl;
   eletail->next       = pl;
   pl->next            = eletail;
   pl->ipt             = ipt;

   return(0);
}

