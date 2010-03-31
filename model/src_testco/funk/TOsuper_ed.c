
/*
Name

    TOsuper_ed

Abstract

    Adds a super edge to the edge list, their points to the point list
    and include the points to the point element list of the top point
    try to build a  top edge using this super edge;
    recursive function

Synopsis

int TOsuper_ed(topo, p, num_se)

    struct topology  *topo;	main data structure for the topology
    struct point     **p;	the pointer to the two endpoints of
                                a super edge
    short            *num_se;	the current number of super edges

Description


Return Value

    sts = 0	if process succesful

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

int TOsuper_ed(struct topology *topo,
               struct point    **p,
               short           *num_se)
{
   int              sts = NULL; 
   int              sts1 = NULL; 
   short            status; 
   double           point[3];
   struct Ext_data_edge  *nullid= NULL;
   struct edge      *new_ed;
   struct telist    *tlhead;
   struct telist    *tltail;
   struct plist     *pltail;
/*
   add the super_edge to the edge list
*/
   status   = 2;
   sts = TOadd_ed(topo,nullid,status,NULL,p[0]->ed,p[1]->ed,NULL,
                NULL,NULL,NULL,&tlhead,&tltail);
   if(sts)
      goto wrapup;
   new_ed = topo->ed.etail->next;
/*
   now add the points to point list and
   include points into the point lists of corresponding top point
   and write point addresses as start/end point of the super edge
   the status of the edges which are elements of the super edge
   is negated  
*/      
   point[0] = p[0]->x;
   point[1] = p[0]->y;
   point[2] = p[0]->z;
   sts = TOadd_pt(topo,1,point,new_ed,p[0]->tp);
   if(sts)
      goto wrapup;
   new_ed->p1     = topo->pt.ptail->next;
   pltail = p[0]->tp->eletail;
   sts = TOadd_pl(topo,pltail,topo->pt.ptail->next);
   if(sts)
      goto wrapup;
   p[0]->tp->num_ele += 1;
   p[0]->ed->status   = -p[0]->ed->status;

   point[0] = p[1]->x;
   point[1] = p[1]->y;
   point[2] = p[1]->z;
   sts = TOadd_pt(topo,1,point,new_ed,p[1]->tp);
   if(sts)
      goto wrapup;
   new_ed->p2     = topo->pt.ptail->next;
   pltail = p[1]->tp->eletail;
   sts = TOadd_pl(topo,pltail,topo->pt.ptail->next);
   if(sts)
      goto wrapup;
   p[1]->tp->num_ele += 1;
   p[1]->ed->status   = -p[1]->ed->status;
/*
   now try to connect the super edge with another edge or super edge
   via common end points
   sts>0 if succesful
*/
   *num_se += 1;
   sts1 = TOfind_ed(topo, num_se,new_ed);      
   if(sts1 < NULL)
      sts = sts1;
   else if(sts1 > NULL)
      sts = 1;
wrapup:
   return( sts);
}
