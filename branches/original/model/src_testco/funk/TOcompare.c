
/* Here are the comparison functions used for Basic Topology */

#include <stdio.h>
#include <string.h>
#include "TOstruct1.h"
#include "TOtopology.h"
#include "TOproto_ta.h"

#define absdif(a,b) ((a>b)?(a-b):(b-a))

int TOcompare(a,b,top_tol)
double top_tol;
struct point **a, **b;
{
   if(absdif(((*a)->x),((*b)->x)) > top_tol) 
      return(((*a)->x < (*b)->x) ? -1 : 1);
   else
   if(absdif(((*a)->y),((*b)->y)) > top_tol) 
      return(((*a)->y < (*b)->y) ? -1 : 1);
   else 
   if(absdif(((*a)->z),((*b)->z)) > top_tol) 
      return(((*a)->z < (*b)->z) ? -1 : 1);
   else return(0);
}
int TOcomparex(struct point **a,struct point **b,double top_tol)
{
   if(absdif(((*a)->x),((*b)->x)) > top_tol) 
      return(((*a)->x < (*b)->x) ? -1 : 1);
   else return(0);
}

int TOcomparey(struct point **a,struct point **b,double top_tol)
{
   if(absdif(((*a)->y),((*b)->y)) > top_tol) 
      return(((*a)->y < (*b)->y) ? -1 : 1);
   else return(0);
}

int TOcomparez(struct point **a,struct point **b,double top_tol)
{
   if(absdif(((*a)->z),((*b)->z)) > top_tol) 
      return(((*a)->z < (*b)->z) ? -1 : 1);
   else return(0);
}

int TOcompx(struct point **a,struct point **b)
{
   return(((*a)->x == (*b)->x) ? 0 : ((*a)->x < (*b)->x) ? -1 : 1);
}

int TOcompy(struct point **a,struct point **b)
{
   return(((*a)->y == (*b)->y) ? 0 : ((*a)->y < (*b)->y) ? -1 : 1);
}

int TOcompz(struct point **a,struct point **b)
{
   return(((*a)->z == (*b)->z) ? 0 : ((*a)->z < (*b)->z) ? -1 : 1);
}
