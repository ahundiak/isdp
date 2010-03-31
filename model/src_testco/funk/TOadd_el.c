/*
Name

    TOadd_el

Abstract

    Add an edge to the element list 'elist';
    'elist' belongs to an topological edge and contains the addresses of all
    edges referencing the current topological edge;

Synopsis

    int TOadd_el(topo,eletail,ied);

    struct topology *topo;	main data structure for topology;
    struct elist    *eletail;	tail of the current elist, used
				for appending element;
    struct edge	    *ied;	address of the edge which is to
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

int TOadd_el(struct topology  *topo,
             struct elist     *eletail,
             struct edge      *ied)
 
{
   int            sts;
   struct elist   *el = NULL; 
   struct memory  *memo = NULL;

   if(eletail == NULL)
   {
      return(-1);
   }
/*
   Add edge to the element list if there is memory available;
   if not then add an element to the memory management list and go on;
*/
   memo = (topo->mo.motail)->next;
   if((BASIC_SIZE -(memo->current - memo->p)) <
      (sizeof(struct elist) + 8 - (sizeof(struct elist)% 8 )))
   {
      sts = TOadd_mo(topo);
      if(sts)
      {
         return(-1);
      }
   memo = (topo->mo.motail)->next;
   }

   el             = (struct elist *) memo->current;
   memo->current += sizeof(struct elist);
   if((sizeof(struct elist) % 8) !=NULL)
      memo->current += 8 - (sizeof(struct elist) % 8);

   eletail->next->next = el;
   eletail->next       = el;
   el->next            = eletail;
   el->ied             = ied;

   return(0);
}

