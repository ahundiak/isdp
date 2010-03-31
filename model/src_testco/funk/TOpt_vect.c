
/*
Name

    TOpt_vector

Abstract

    Generates a vector used in qsort with the list addresses of points

Synopsis

    TOpt_vector(topo, ipt);
    struct topology 	*topo;	main structure for topology data
    struct point	**ipt;	vector of point addresses

Description


Return Value

    sts = 0		if process succesful

Notes

Index

Keywords

History

    22 Feb 94   B.Burkhardt     Creation
*/
#include <stdio.h>
#include <string.h>
#include "TOstruct1.h"
#include "TOtopology.h"
#include "TOproto_ta.h"


int TOpt_vector(struct topology *topo, struct point **ipt)
{
   int i;
   struct point *ptemp;

   i     = 0;
   ptemp = topo->pt.phead;
/*
   return if point list is empty;
*/
   if(ptemp->next == topo->pt.ptail)
      return(1);
/*
   fill address vector while last list element is not reached;
*/
   while((ptemp=ptemp->next) != topo->pt.ptail)
      ipt[i++] = ptemp;
   if(i!= topo->pt.num_pt)
      return(1);
   return(0);
}
