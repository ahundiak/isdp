/*
Name
	TOlist_pe

Abstract
	finds recursive all low level part edges of an surface edge and puts
	them in to a linked list

Synopsis

	sts = TOlist_pe(topo,seltail,num_pe,edid)

        struct topology *topo;		main structure for topological data
	struct elist	*seltail;	pointer to the tail of the list
	short         	*num_pe;	number of list elements
	struct edge	*edid;		pointer to a super edge

Description

Return Value

	int		sts;

Notes
	the elist must be initialized with init_el before using in  TOlist_pe

History

	06 Dec 93	B.Burkhardt	Creation
*/

#include <stdio.h>
#include <string.h>
#include "TOtopology.h"
#include "TOstruct1.h"
#include "TOproto_ta.h"
#include "TOnumbers.h"

int TOlist_pe( struct topology *topo,
               struct elist    *seltail,
               short           *num_pe,
               struct edge     *edid)

{
   int    sts;

   if((edid->edid1)&&((edid->edid1->status == 3)))
   {

      sts = TOlist_pe(topo,seltail,num_pe,edid->edid1);
      if(sts)
      {
         return(-1);
      }
   }
   else if((edid->edid1)&&(edid->edid1->status == 4)&&
           (edid->edid1->ext))
   {
      sts = TOadd_el(topo,seltail,edid->edid1);
      if(sts)
      {
         return(-1);
      }
      *num_pe +=1;
   }
   if((edid->edid2)&&((edid->edid2->status == 3)))
   {
      sts = TOlist_pe(topo,seltail,num_pe,edid->edid2);
      if(sts)
      {
         return(-1);
      }
   }
   else if((edid->edid2)&&(edid->edid2->status == 4)&&
           (edid->edid2->ext))
   {
      sts = TOadd_el(topo,seltail,edid->edid2);
      if(sts)
      {
         return(-1);
      }
      *num_pe +=1;
   }
   return(0);
}

