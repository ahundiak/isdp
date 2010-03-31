
/*
Name

    TOadd_tl

Abstract

    Add a topological edge to the element list 'telist';
    'telist' belongs to an edge and contains the addresses of all
    top_edges referencing the current edge;

Synopsis

    int TOadd_tl(topo,eltail, ied);

    struct topology  *topo;	main data structure for topology;
    struct telist    *eletail;	tail of the current telist, used
				for appending element;
    struct top_edge  *ied;	address of the top_edge which is to
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

int TOadd_tl(struct topology  *topo,
             struct telist    *eletail,
             struct top_edge  *ied)
 
{
   int          sts;
   struct telist *tl = NULL; 
   struct memory  *memo = NULL;

   if(eletail == NULL)
   {
      return(-1);
   }
/*
   Add an top_edge to the element list if there is memory available;
   if not then add an element to the memory management list and go on
*/
   memo = (topo->mo.motail)->next;
   if((BASIC_SIZE -(memo->current - memo->p)) <
      (sizeof(struct telist) + 8 - (sizeof(struct telist)% 8 )))
   {
      sts = TOadd_mo(topo);
      if(sts)
      {
/*       memory allocation failed */
         return(-1);
      }
      memo = (topo->mo.motail)->next;
   }

   tl             = (struct telist *) memo->current;
   memo->current += sizeof(struct telist);
   if((sizeof(struct elist) % 8) !=NULL)
      memo->current += 8 - (sizeof(struct telist) % 8);

   eletail->next->next = tl;
   eletail->next       = tl;
   tl->next            = eletail;
   tl->ied             = ied;

   return(0);
}

