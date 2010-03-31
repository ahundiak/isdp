/*
Name
	TOlist_se

Abstract
	finds recursive all edges of a super edge and puts
	them in to a linked list

Synopsis

	sts = TOlist_se(topo,seltail,num,seid,edid)

        struct topology *topo;          generell topo structure
	struct elist	*seltail;	pointer to the tail of the list
	short    	*num;		number of elements
	struct edge	*seid;		pointer to the highest level super edge
	struct edge	*edid;		pointer to a super edge

Description

Return Value

	int		sts;

Notes
	the elist must be initialized with init_el before using in  TOlist_se

History

	06 Dec 93	B.Burkhardt	Creation
*/

#include <stdio.h>
#include <string.h>
#include "TOtopology.h"
#include "TOstruct1.h"
#include "TOproto_ta.h"
#include "TOnumbers.h"

int TOlist_se(
              struct topology *topo,    /* generell topo structure */
              struct elist    *seltail, /* tail of the list */
              short           *num,     /* count for number of elements */
              struct edge     *seid,    /* highest level super edge */
              struct edge     *edid)    /* super edge */

{
   int    sts;

   if((edid->edid1)&&((edid->edid1->status == 2)||(edid->edid1->status == -2)))
   {
      sts = TOlist_se(topo,seltail,num,seid,edid->edid1);
      if(sts)
      {
         return(-1);
      }
   }
   else if((edid->edid1&&edid->edid1->ext)&&edid->edid1->status != 3)
   {
      edid->edid1->edid2  = seid;
/*      edid->edid1->num_te = seid->num_te; !!!!!!!*/
      sts = TOadd_el(topo,seltail,edid->edid1);
      if(sts)
      {
         return(-1);
      }
      *num +=1;
   }
   if((edid->edid2)&&((edid->edid2->status == 2)||(edid->edid2->status ==-2)))
   {
      sts = TOlist_se(topo,seltail,num,seid,edid->edid2);
      if(sts)
      {
         return(-1);
      }
   }
   else if((edid->edid2&&edid->edid2->ext)&&edid->edid2->status != 3)
   {
      edid->edid2->edid2  = seid;
/*      edid->edid2->num_te = seid->num_te; !!!!!!!*/
      sts = TOadd_el(topo,seltail,edid->edid2);
      if(sts)
      {
         return(-1);
      }
      (*num) +=1;
   }
   return(0);
}

