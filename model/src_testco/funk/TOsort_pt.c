/*
Name

    TOsort_pt

Abstract

    Generates the topological points using the
    point address vector ipt from TOpt_vector.c

Synopsis

int TOsort_pt(topo, ipt)

    struct topology  *topo;	main data structure for the topology
    struct point     **ipt;	vector with the addresses of all points

Description


Return Value

    sts = 0	if process succesful

Notes

Index

Keywords

History

    22 Feb 94   B.Burkhardt     Creation
    20 May 94   B.Burkhardt     Consideration of gaps in the boundary loop
                                of imposed boundaries
*/

#include <stdio.h>
#include <string.h>
#include "TOstruct1.h"
#include "TOtopology.h"
#include "TOproto_ta.h"

static int TOcompx(struct point **a, struct point **b);
static int TOcompy(struct point **a, struct point **b);
static int TOcompz(struct point **a, struct point **b);
static int TOcomparex(struct point **a, struct point **b, double top_tol);
static int TOcomparey(struct point **a, struct point **b, double top_tol);
static int TOcomparez(struct point **a, struct point **b, double top_tol);

int TOsort_pt(struct topology  *topo,
              struct point     **ipt)
            
{
   int i;
   int j;
   int k;
   int sts;
   int num;
   int num_pt;
   int ixstart;
   int ixend;
   int iystart;
   int iyend;
   double top_tol;
   struct plist *plhead= NULL;
   struct plist *pltail= NULL;
   struct top_point *tpp=NULL;
#ifdef DBG
   printf("TOsort_pt\n");
#endif
/*
   get the number of points and the topological tolerance parameter
*/
   num_pt  = topo->pt.num_pt;
   top_tol = topo->pa.topology_tolerance;
/*
   sort the point addresses with respect to the points x- coordinate
*/

   sts = qsort(ipt,num_pt, sizeof(struct point *), TOcompx);

   ixstart    = 0;
   i          = 0;
/*
   classification of the points wrt the toplogical tolerance in
   x,y,z coordinates;
   while last point is not reached, do
*/
   while(i<(num_pt-1))
   {
/*
      ...classification in x;
         all points with a distance in x less than top_tol are belonging
         to one class;
         
*/
      while((i<num_pt-1)&&
            (!(sts = TOcomparex(&(ipt[i]),&(ipt[i+1]),top_tol))))
         i++;
      ixend   = i;
      iystart = ixstart;
      j       = ixstart;
      num     = ixend - ixstart + 1;
      if(num == 1)
      {
         sts = TOadd_tp(topo,1,1,&plhead,&pltail);
         if(sts)
            return(-1);
         tpp              = topo->tp.tptail->next;
         sts = TOadd_pl(topo,pltail,ipt[ixstart]);
         if(sts)
            return(-1);
         ipt[ixstart]->tp = tpp;
         tpp->status      = NULL;
      }
/*
      ...all elements of a x- class are sorted in y;
*/
      if(num > 1)
         qsort(&ipt[ixstart],num, sizeof(struct point *), TOcompy);
/*
      ...over all elements of the x- class;
*/
      while(j<ixend)
      {  
/*
      ...generate classes by comparing the y coordinates;
*/  
         while((j<ixend)&&
               (!(sts = TOcomparey(&(ipt[j]),&(ipt[j+1]),top_tol))))
            j++;
         iyend = j;
         k     = iystart;
         num   = iyend - iystart + 1;
         if(num == 1)
         {
            sts = TOadd_tp(topo,1,1,&plhead,&pltail);
            if(sts)
               return(-1);
            tpp              = topo->tp.tptail->next;
            sts = TOadd_pl(topo,pltail,ipt[iystart]);
            if(sts)
               return(-1);
            ipt[iystart]->tp = tpp;
            tpp->status      = NULL;
            if(j == ixend-1)
            {
               sts = TOadd_tp(topo,1,1,&plhead,&pltail);
               if(sts)
                  return(-1);
               tpp              = topo->tp.tptail->next;
               sts = TOadd_pl(topo,pltail,ipt[ixend]);
               if(sts)
                  return(-1);
               ipt[ixend]->tp   = tpp;
               tpp->status      = NULL;
            }
         }
/*
         ...all elements of the y classes are sorted in z;
*/
         if(num>1)
            qsort(&ipt[iystart],num, sizeof(struct point *), TOcompz);
/*
         ...generate classes by comparing the z coordinates;
            the members of each z class are identical with
            a topological point;
*/          
         while(k<iyend)
         {
            sts = TOadd_tp(topo,1,1,&plhead,&pltail);
            if(sts)
               return(-1);
            tpp              = topo->tp.tptail->next;
            sts = TOadd_pl(topo,pltail,ipt[k]);

            if(sts)
               return(-1);
            ipt[k]->tp         = tpp;
            k++;
            while(k<=iyend)
            {
               if((!(sts = TOcomparez(&(ipt[k-1]),&(ipt[k]),top_tol))))
               {
                  sts = TOadd_pl(topo,pltail,ipt[k]);
                  if(sts)
                     return(-1);
                  tpp->num_ele += 1;
                  ipt[k]->tp    = tpp;
                  k++;
               }
               else
               {
                  sts = TOadd_tp(topo,1,1,&plhead,&pltail);
                  if(sts)
                     return(-1);
                  tpp         = topo->tp.tptail->next;
                  sts = TOadd_pl(topo,pltail,ipt[k]);
                  if(sts)
                     return(-1);
                  ipt[k]->tp  = tpp;
                  tpp->status = NULL;
                  k++;
               }
            }/* end while(k<=iyend) */
            tpp->status     = 0;
            if(tpp->num_ele > 1) 
               tpp->status     = 1;
            if(tpp->num_ele > 2) 
               tpp->status     = 2;
            if(tpp->num_ele > 4) 
               tpp->status     = 3 + tpp->num_ele/2;
         }/* end while(k<iyend) */
         iystart = iyend+1;
         j       = j + 1;
         if(j == ixend)
         {
            sts = TOadd_tp(topo,1,1,&plhead,&pltail);
            if(sts)
               return(-1);
            tpp              = topo->tp.tptail->next;
            sts = TOadd_pl(topo,pltail,ipt[j]);
            if(sts)
               return(-1);
            ipt[j]->tp = tpp;
            tpp->status      = NULL;
         }
      }/* end while(j<ixend) */
      ixstart = ixend+1;
      i       = i + 1;
      if(i == num_pt - 1)
      {
         sts = TOadd_tp(topo,1,1,&plhead,&pltail);
         if(sts)
            return(-1);
         tpp              = topo->tp.tptail->next;
         sts = TOadd_pl(topo,pltail,ipt[i]);
         if(sts)
            return(-1);
         ipt[i]->tp = tpp;
         tpp->status      = NULL;
      }
   }/* end while(i<(num_pt-1)*/
   for(i=0;i<num_pt;i++)
   {
      if(ipt[i]->tp == NULL)
      {
         ipt[i]->tp =ipt[i]->tp ;
         return(-1);
      }
      if(ipt[i]->tp->num_ele > 1) 
         ipt[i]->tp->status     = 1;
      if(ipt[i]->tp->num_ele > 2) 
         ipt[i]->tp->status     = 2;
      if(ipt[i]->tp->num_ele > 4) 
         ipt[i]->tp->status     = 3 + ipt[i]->tp->num_ele/2;
   }
   return(0);
}

/*
   Here are the comparison functions used for Basic Topology
   in TOsort_pt.c
 */

#define absdif(a,b) ((a>b)?(a-b):(b-a))

static int TOcomparex(struct point **a,struct point **b,double top_tol)
{
   if(absdif(((*a)->x),((*b)->x)) > top_tol) 
      return(((*a)->x < (*b)->x) ? -1 : 1);
   else return(0);
}

static int TOcomparey(struct point **a,struct point **b,double top_tol)
{
   if(absdif(((*a)->y),((*b)->y)) > top_tol) 
      return(((*a)->y < (*b)->y) ? -1 : 1);
   else return(0);
}

static int TOcomparez(struct point **a,struct point **b,double top_tol)
{
   if(absdif(((*a)->z),((*b)->z)) > top_tol) 
      return(((*a)->z < (*b)->z) ? -1 : 1);
   else return(0);
}

static int TOcompx(struct point **a,struct point **b)
{
   return(((*a)->x == (*b)->x) ? 0 : ((*a)->x < (*b)->x) ? -1 : 1);
}

static int TOcompy(struct point **a,struct point **b)
{
   return(((*a)->y == (*b)->y) ? 0 : ((*a)->y < (*b)->y) ? -1 : 1);
}

static int TOcompz(struct point **a,struct point **b)
{
   return(((*a)->z == (*b)->z) ? 0 : ((*a)->z < (*b)->z) ? -1 : 1);
}
