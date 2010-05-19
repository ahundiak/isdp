/*

Copyright (C) 1996, 1997, Intergraph Corporation. All rights reserved.

Name
    BSsfincktm

Abstract
    This routine given a b-spline surface will increase the 
interior knots to multiplicity order - 1.

Synopsis
    void BSsfincktm(surf, uvopt, isurf, rc)

    struct IGRbsp_surface *surf,
                          *isurf
    IGRint                uvopt
    BSrc                  *rc

Description
    This routine inputs a b-spline surface(surf) and an option on
whether u or v knots are to be increased(uvopt: 0 - u increased, 
1 - v increased, 2 - both increased).  It increases the distinct uv 
knots to (k-1) and returns the surface(isurf).

Return Values
   BSSUCC is returned if all is successful.

Notes
   Caller should allocate the space for the output surface.
A maximum for the number of poles is:

isurf->u_num_poles = (surf->u_num_poles - surf->u_order) *
                     (surf->u_order - 1) + surf->u_order
isurf->v_num_poles = (surf->v_num_poles - surf->v_order) *
                     (surf->v_order - 1) + surf->v_order

Index
    ot

Keywords

History
    S.G. Catron    01/16/89  : Creation date.
    S.R. Meeth     10/19/90  : put in deallocation booleans freeu, freev;
                               initialized unewn, vnewn to appease compiler. 
    P.R. Slubicki  03/17/92  : I removed status and cast all IGRboolean
                               functions to void.
*/
#ifdef DONOTSPROTO
#include "ubspmp.h" 
#endif

#ifdef NT 
#include "ubspm.h" 
#else 
#include "bsdefs.h"
#include "bserr.h"
#include "bsstackalloc.h"
#endif

#define  MAXNUM  120

void BSsfincktm(
struct IGRbsp_surface *surf,
IGRint                uvopt,
struct IGRbsp_surface *isurf,
BSrc                  *rc)
{
#ifndef DONOTSPROTO
#include "bsdbgrc.h"
#include "bssadd_kts.h"
#include "bssfkttol2.h"
#include "bssf_copy.h"
#endif 

   IGRboolean freeu=FALSE,freev=FALSE;
   IGRint  i,j, ndist, unewn=0, vnewn=0, mul,
           tuvopt;
   IGRdouble  *unewknots=NULL, aunewknots[MAXNUM],
              *vnewknots=NULL, avnewknots[MAXNUM],
              knot_tol;

   *rc = BSSUCC;

   BSsfkttol2(surf->u_order, surf->v_order, surf->u_knots, surf->v_knots,
              surf->u_num_poles, surf->v_num_poles, surf->poles,
              surf->weights, &knot_tol, rc);
   if(BSERROR(*rc))
      goto wrapup;

   if( uvopt == 0 || uvopt == 2 )
   {
      /* find the number of distinct u interior knots */
      ndist = 0;
      for(i=surf->u_order; i< surf->u_num_poles; i++)
      {
         if((surf->u_knots[i+1] - surf->u_knots[i] ) > knot_tol)
         {
            ndist += 1;
         }
      }   
      /* now allocate "unewknots" appropriately */
      unewn = surf->u_order + ndist * (surf->u_order -1) + surf->u_order;
      if( unewn > MAXNUM )
      {
         freeu = TRUE;
         unewknots = (IGRdouble *)BSstackalloc((unsigned)( unewn * sizeof
                            (IGRdouble )));
         if(! unewknots )
         {
            *rc = BSNOSTKMEMORY;
            goto wrapup;
         }
      }
      else
      {
         unewknots = &aunewknots[0];
      }
      /* loop over the knots creating a knot array where all distinct 
         knots have multiplicity order -1 */
      unewn = surf->u_order;
      for(i=0; i< unewn; i++)
         unewknots[i] = surf->u_knots[i];
         
      mul = 1;
      for(i=surf->u_order; i< surf->u_num_poles; i++)
      {
         unewknots[unewn] = surf->u_knots[i];
         unewn += 1;
         while((surf->u_knots[i+1] - surf->u_knots[i] ) < knot_tol)
         {
            unewknots[unewn] = unewknots[unewn -1];
            unewn += 1;
            mul += 1;
            i += 1;
         }
         if( mul < surf->u_order - 1)
         {
            /* add knot to k-1 */
            for(j=mul; j< surf->u_order-1; j++)
            {
               unewknots[unewn] = surf->u_knots[i];
               unewn += 1;
            }         
         }
         mul = 1;
      }
      for(i=unewn,j=surf->u_num_poles; j< surf->u_num_knots; j++,i++)
         unewknots[i] = surf->u_knots[j];
   }
   if( uvopt == 1 || uvopt == 2 )
   {
      /* find the number of distinct v interior knots */
      ndist = 0;
      for(i=surf->v_order; i< surf->v_num_poles; i++)
      {
         if((surf->v_knots[i+1] - surf->v_knots[i] ) > knot_tol)
         {
            ndist += 1;
         }
      }   
      /* now allocate "vnewknots" appropriately */
      vnewn = surf->v_order + ndist * (surf->v_order -1) + surf->v_order;
      if( vnewn > MAXNUM )
      {
         freev = TRUE;
         vnewknots = (IGRdouble *)BSstackalloc((unsigned)( vnewn * sizeof
                             (IGRdouble )));
         if(! vnewknots )
         {
            *rc = BSNOSTKMEMORY;
            goto wrapup;
         }
      }
      else
      {
         vnewknots = &avnewknots[0];
      }
      /* loop over the knots creating a knot array where all distinct 
         knots have multiplicity order -1 */
      vnewn = surf->v_order;
      for(i=0; i< vnewn; i++)
         vnewknots[i] = surf->v_knots[i];
         
      mul = 1;
      for(i=surf->v_order; i< surf->v_num_poles; i++)
      { 
         vnewknots[vnewn] = surf->v_knots[i];
         vnewn += 1;
         while((surf->v_knots[i+1] - surf->v_knots[i] ) < knot_tol)
         {
            vnewknots[vnewn] = vnewknots[vnewn -1];
            vnewn += 1;
            mul += 1;
            i += 1;
         }
         if( mul < surf->v_order - 1)
         {
            /* add knot to k-1 */
            for(j=mul; j< surf->v_order-1; j++)
            {
               vnewknots[vnewn] = surf->v_knots[i];
               vnewn += 1;
            }         
         }
         mul = 1;
      }
      for(i=vnewn,j=surf->v_num_poles; j< surf->v_num_knots; j++,i++)
         vnewknots[i] = surf->v_knots[j];
   }
   if( uvopt == 0 )
   {
      if( unewn > surf->u_num_poles )
         BSsadd_kts(surf, uvopt, unewn, unewknots, vnewn, vnewknots,
                    isurf, rc);   
      else
         (void) BSsf_copy(rc, surf, isurf);
   }
   else
   {
      if( uvopt == 1 )
      {   
         if( vnewn > surf->v_num_poles )
            BSsadd_kts(surf, uvopt, unewn, unewknots, vnewn, vnewknots, 
                       isurf, rc);   
         else
            (void) BSsf_copy(rc, surf, isurf);
      }
      else
      {
         if( vnewn == surf->v_num_poles  && unewn == surf->u_num_poles)
            (void) BSsf_copy(rc, surf, isurf);
         else
         {
            tuvopt = 2;
            if( vnewn == surf->v_num_poles )
               tuvopt = 0;
            if( unewn == surf->u_num_poles)
               tuvopt = 1;
            BSsadd_kts(surf, tuvopt, unewn, unewknots, vnewn, vnewknots, 
                       isurf, rc);   
         }
      }
   }

   wrapup:
   if( freeu && unewknots )
      BSstackdealloc((char *)unewknots);
   if( freev && vnewknots )
      BSstackdealloc((char *)vnewknots);

{
if(BSERROR(*rc))
    BSdbgrc(*rc,"BSsfincktm");
return;
}
}
