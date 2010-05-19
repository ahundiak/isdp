/*

Copyright (C) 1996, 1997, Intergraph Corporation. All rights reserved.

Name
    BScvsfpchtb

Abstract
    This routine constructs the insert tables and lookup tables for 
curve-surface intersection.

Synopsis
    void BScvsfpchtb( curve, surf, min1, max1, min2, max2, netpt1, netpt2, 
                      midpt1, midpt2, num_level, rng_ptr, srng, num, unum, 
                      vnum, par, upar, vpar, insert1, insert2, lookup, num_look,
                      look_ct, max, u_max, v_max, rc )

    struct IGRbsp_curve         *curve
    struct IGRbsp_surface       *surf
    IGRpoint                    min1, max1, min2, max2
    IGRpoint                    *netpt1, *netpt2
    IGRpoint                    *midpt1, *midpt2
    IGRint                      num_level      
    struct BStree_ptr           *rng_ptr[RNGNUM]
    IGRint                      srng    
    IGRint                      num, unum, vnum
    IGRdouble                   *par, *upar, *vpar
    IGRint                      *insert1, *insert2
    IGRint                      **lookup
    IGRint                      *num_look      
    IGRint                      *look_ct       
    IGRint                      *max, *u_max, *v_max
    BSrc                        *rc            

Description
    Given a curve(curve ) and a surface(surf), minimum and maximum range points 
(min1, max1, min2 and max2), arrays of node points (netpt1 and netpt2), arrays 
of midpoints for point arrays (midpt1 and midpt2), number of levels on range 
tree for (num_level), range tree for (rng_ptr), indicator for curve or surface 
with range tree (srng), number of parameters on curve and surface(num, unum 
and vnum) and  arrays of parameters (par, upar, and vpar).  This routine 
constructs the insert tables for chord height tolerance (insert1 and insert2), 
the lookup table for possible intersections (lookup)[number of lookup arrays - 
num_look and counter - look_ct] and determines the maximum number to insert in 
each direction (max, u_max and v_max).

Return Values
    If memory cannot be allocated, rc returns BSNOMEMORY. If memory is 
attempted to be allocated beyond the bounds of lookup, rc returns BSINVCHT.
If no errors occur, rc returns BSSUCC.

Notes
    This is a specialized subroutine for BScvsfintrg. Insert1, insert2 and the
first array for lookup must be allocated before this routine is called - 
this is done by BScvsfnpint.

    RNGNUM is defined to be 20.

Index
    md

Keywords

History
    S.G. Catron      01/06/88   : Creation date.
    Vivian Y.Hsu     03/20/98   : Fixed a memory crash problem. Move
                                  num_look++ arfer the check statement
                                  if (num_look + 1 == 50).
*/
#include <math.h>
#include "bsdefs.h"
#include "bserr.h"
#include "bssfsf_int2.h"
#include "bsmalloc.h"
#define MAXLOOKUP 50

void BScvsfpchtb(
struct IGRbsp_curve         *curve,
struct IGRbsp_surface       *surf,
IGRpoint                    min1,
 IGRpoint	 max1,
 IGRpoint	 min2,
 IGRpoint	 max2,
IGRpoint                    *netpt1,
 IGRpoint                    	 *netpt2,
IGRpoint                    *midpt1,
 IGRpoint                    	 *midpt2,
IGRint                      num_level,
struct BStree_ptr           *rng_ptr[RNGNUM],
IGRint                      srng ,
IGRint                      num,
 IGRint	 unum,
 IGRint	 vnum,
IGRdouble                   *par,
 IGRdouble                   	 *upar,
 IGRdouble                   	 *vpar,
IGRint                      *insert1,
 IGRint                      	 *insert2,
IGRint                      **lookup,
IGRint                      *num_look,
IGRint                      *look_ct,
IGRint                      *max,
 IGRint                      	 *u_max,
 IGRint                      	 *v_max,
BSrc                        *rc)
{
#include "bsdbgrc.h"
#include "bsset_rng.h"
#include "bscvset_rng.h"
#include "bscmp_rng.h"
#include "bsspnnumins.h"
#include "bspchnumins.h"


IGRpoint            srange[2];       /* range of patch on s1                  */
IGRboolean          in_limit;        /* indicator that patch is in limits of  */
                                     /*  other surface                        */
IGRint              sub1, sub2,      /* temporary subscripts                  */
                    sub3, sub4;
IGRint              i,j,jj,k,kk;     /* loop counters                         */
IGRint              *ind_u = NULL,   /* indexes returned from BScmp_rng       */
                    *ind_v = NULL;
IGRint              lvl;             /* temporary number of levels            */
IGRlong             tot1,tot2;       /* total number of boxes on s1 and s2    */
IGRint              n;               /* number of pairs of indices returned   */
                                     /*  from BScmp_rng                       */
IGRboolean          all_pch=FALSE;   /* indicator to calculate all insert     */
                                     /*  values                               */
IGRpoint            avgpt;           /* average point                         */
IGRdouble           dist;            /* distance between avgpt and midpoint   */
IGRdouble           temp;            /* temporary variable                    */

   *rc = BSSUCC;

   /* Create lookup table of possible patch intersections */

   ind_u = (IGRint *)BSmalloc((unsigned)(200 * sizeof(IGRint)));
   if (! ind_u)
   {
      *rc = BSNOMEMORY;
      goto wrapup;
   }
   ind_v = (IGRint *)BSmalloc((unsigned)(200 * sizeof(IGRint)));
   if (! ind_v)
   {
      *rc = BSNOMEMORY;
      goto wrapup;
   }

   tot1 = num - 1;
   tot2 = (unum - 1) * (vnum - 1);
   for (i=0;i < tot1 ; i++)
   {
      insert1[i] = -1;
   }
   for (i=0; i < (tot2 * 2); i++)
   {
      insert2[i] = -1;
   }

   kk = 0;
   if (srng == 1)
   {
      /* range tree is for curve */
      for (j=0;j < (vnum - 1); j++)
      {
         for (i=0;i < (unum - 1);i++)
         {
            sub1 = j * unum + i;
            sub2 = sub1 + 1;
            sub3 = (j + 1) * unum + i;
            sub4 = sub3 + 1;
    
            /* Calculate average net point and distance         */
            /*  between this point and the appropriate midpoint */

            dist = 0;
            for (jj=0;jj < 3;jj++)
            {
               avgpt[jj] = (netpt2[sub1][jj] + netpt2[sub2][jj] + 
                            netpt2[sub3][jj] + netpt2[sub4][jj]) / 4;
               temp = midpt2[kk][jj] - avgpt[jj];
               dist += (temp * temp);
            }
            dist = sqrt(dist) * .5;
            kk++;
            /* using net points for this span of the surface, see if the range
               (min max boxes) intersect */
            BSset_rng( netpt2[sub1], netpt2[sub2], netpt2[sub3], netpt2[sub4], 
                       dist, min1, max1, srange, &in_limit, rc );
            if (BSERROR(*rc))
               goto wrapup;

            if (in_limit)
            {
               /* the ranges do intersect */
               n = 0;
               lvl = num_level;
               BScmp_rng( srange, lvl, rng_ptr, 0, &n, &ind_u, &ind_v, rc );
               if (BSERROR(*rc))
                  goto wrapup;

               if (n)
               {
                  sub1 = j * (unum - 1) + i;
                  /* set the insertion boolean to something beside -1, to insure
                     that this span is checked for number of insertions */
                  insert2[sub1 * 2] = 0;
                  for (k=0;k < n;k++)
                  {
                     lookup[*num_look][*look_ct] = ind_u[k];
                     lookup[*num_look][*look_ct + 1] = ind_v[k];
                     lookup[*num_look][*look_ct + 2] = i;
                     lookup[*num_look][*look_ct + 3] = j;
                     (*look_ct) += 4;
                     if (*look_ct == 400)
                     {
                        if (*num_look + 1 == MAXLOOKUP)
                        {
                           *rc = BSINVCHT;
                           goto wrapup;
                        }
                        (*num_look)++;
                        *look_ct = 0;
                        lookup[*num_look] = (IGRint *)BSmalloc
                           ((unsigned)(400 * sizeof(IGRint)));
                        if (! lookup[*num_look])
                        {
                           *rc = BSNOMEMORY;
                           goto wrapup;
                        }
                     }
                     /* ind_v[]'s should be 0 since this is rng tree for the
                        curve */
                     insert1[ind_u[k] ] = 0;
                  }
               }
            }
         }
      }
   }
   else
   {
      /* rng_tree is for the surface */
      /* loop over the spans of the curve */
      for (j=0; j < (num - 1); j++)
      {
         /* Calculate average net point and distance         */
         /*  between this point and the appropriate midpoint */
         dist = 0;
         for (jj=0;jj < 3;jj++)
         {
            avgpt[jj] = (netpt1[j][jj] + netpt1[j + 1][jj] )/ 2;
            temp = midpt1[kk][jj] - avgpt[jj];
            dist += (temp * temp);
         }
         dist = sqrt(dist) * .5;
         kk++;
         /* see if this span of net points intersect with the surface min max
            box */
         BScvset_rng( netpt1[j], netpt1[j + 1], dist, min2, max2, srange, 
                      &in_limit, rc );
         if (BSERROR(*rc))
            goto wrapup;
         if (in_limit)
         {
            /* the ranges do intersect */
            n = 0;
            lvl = num_level;
            /* compare the ranges and find the indices on the surface of where
               the overlaps are */
            BScmp_rng( srange, lvl, rng_ptr, 0, &n, &ind_u, &ind_v, rc );
            if (BSERROR(*rc))
               goto wrapup;
            if (n)
            {
               /* set this insertion boolean to something beside -1, to insure
                  that this span is checked later for number of insertions */
               insert1[j] = 0;
               for (k=0; k < n ; k++)
               {
                  lookup[*num_look][*look_ct] = j;
                  lookup[*num_look][*look_ct + 1] = 0;
                  lookup[*num_look][*look_ct + 2] = ind_u[k];
                  lookup[*num_look][*look_ct + 3] = ind_v[k];
                  (*look_ct) += 4;
                  if (*look_ct == 400)
                  {
                     if (*num_look + 1 == MAXLOOKUP)
                     {
                        *rc = BSINVCHT;
                        goto wrapup;
                     }
                     (*num_look)++;
                     *look_ct = 0;
                     lookup[*num_look] = (IGRint *)BSmalloc
                     ((unsigned)(400 * sizeof(IGRint)));
                     if (! lookup[*num_look])
                     {
                        *rc = BSNOMEMORY;
                        goto wrapup;
                     }
                  }
                  /* also set the suface insertion boolean to something 
                     beside -1, to insure it is checked later for number 
                     of insertions */
                  sub2 = ind_v[k] * (unum - 1) + ind_u[k];
                  insert2[sub2 * 2] = 0;
               }
            }
         }
      }
   }

   /* Construct tables of insert numbers for both surfaces */
 
   BSspnnumins( curve, num, par, insert1, max, rc );
   if (BSERROR(*rc))
      goto wrapup;

   BSpchnumins( surf, unum, vnum, upar, vpar, all_pch, insert2, u_max, 
                v_max, rc );
   if (BSERROR(*rc))
      goto wrapup;

   wrapup:
     if (ind_v)
        BSdealloc((char *)ind_v);
     if (ind_u)
       BSdealloc((char *)ind_u);
   {
   if(BSERROR(*rc))
       BSdbgrc(*rc,"BScvsfpchtb");
   return;
   }
}
