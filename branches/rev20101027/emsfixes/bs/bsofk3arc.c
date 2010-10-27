/*

Copyright (C) 1996, 1997, Intergraph Corporation. All rights reserved.

Name
        BSofk3arc

Abstract
        This routine finds the arc for filleting or extending cases 
        when connecting two offset curves.(used by BS2cvsoffpg)

Synopsis
        void BSofk3arc(cv1,cv2, off1, off2, fillet, d1,d2, normal, 
                right_side, arc_type, arc, rc)
        struct IGRbsp_curve *cv1
        struct IGRbsp_curve *cv2
        struct IGRbsp_curve *off1
        struct IGRbsp_curve *off2
        IGRboolean          fillet
        IGRdouble           d1,d2
        IGRvector           normal
        IGRint              right_side
        IGRint              *arc_type
        struct IGRbsp_curve **arc
        BSrc   *rc

Description
        Input arguments:

            cv1,cv2 - the original B-spline curves
            off1,off2 - offset curves of cv1 and cv2.
            fillet - FALSE, extend case
                     TRUE, fillet case
            d1,d2 - offset distances respect to cv1 and cv2
            normal - normal vector
            right_side - 1, if T x normal = offset direction;
                         -1, if T x normal = opposite to offset direction.
        Output argument:
           
            arc_type - type of returned "arc"
                       = BSCVLINE( -61 ), a line
                       = BSCVLINESTR( -62 ), a line string
                       = BSCVCIRCARC( -63 ), a circular arc
                       = BSCVGENCONC( -64 ), general conic
                       = BSCVGENBSPC( -65 ), general B-spline

            arc - curve generated between cv1 and cv2            

Return Values

        If successful, rc = BSSUCC; else, rc returns an error message
Notes

         Before calling this routine, arc should be initialized to NULL.

Index
    md

Keywords

History
        Y. S. Sheng  11/17337/87  : Creation date.
        Y. S. Sheng  12/08/87  : Compute lder and rder base on cv1 and cv2.
                                 Declare d in collinBSofk3arc.
        Y. S. Sheng  12/21/87  : Modified to extend the offset curves to
                                 the extending intersection point when
                                 curve order is 2.
        Y. S. Sheng  12/22/87  : Make z-values to be the same for all points
                                 pass into BSxln.
        Y. S. Sheng  01/05/88  : Modified to compute lder and rder based on
                                 off1 and off2.
                                 Use the polygons' data to compute lder and 
                                 rder instead of calling BScveval.
        Y. S. Sheng  01/12/88  : Compute lder and nlder based on cv1 if off1
                                 is degenerated.
        Y. S. Sheng  01/12/88  : Make a rational curve to replace the line
                                 and arc as the connection between two offset
                                 curves when fillet = TRUE.
        Y. S. Sheng  01/13/88  : Replace the call from BSarcb3pols to 
                                 BStransconc.
        Y. S. Sheng  01/15/88  : Modified the approach for creating the arc
                                 when fillet = TRUE.
        Y. S. Sheng  01/19/88  : When d1 != d2, if extending both offset curves
                                 can not find intersection, then call 
                                 collinBSofk3arc if collin = TRUE.                               
        Y. S. Sheng  01/26/88  : Add a new argument "arc_type" to specify
                                 the type of "arc".
                                 When d1 != d2, call collinBSofk3arc only if
                                 collin = TRUE and d1, d2 > zero_tol.
        Y. S. Sheng  03/10/88  : Correct index of par2 when assigning to tpar.
        Y. S. Sheng  03/18/88  : Add an include file and redefine the return 
                                 codes of arc_type.
        C. S. Kirby  09/01/88  : Remove several unnecessary variables to
                                 correct lint errors. Use cv2 in code to
                                 avoid lint error of unused argument.
        S.G. Catron  03/03/89  : Make it work for double poles at the
                                 ends.
        S. C. Wood   06/28/89  : Included code to generate a general conic
                                 fillet between off1 and off2 if the tangents
                                 of cv1 and off1 are different OR if the
                                 tangents of cv2 and off2 are different.
        S.G. Catron  07/10/89  : There was a typo in the case of 3 poles
                                 and order 2.  The last knot was not 
                                 being set.
        S.G. Catron  07/11/89  : BScveval wasn't declared in the static
                                 function.
        S. C. Wood   07/24/89  : Added code to handle 3-D cases.  Set z-
                                 values of a, b, p, lder, rder, nlder, and
                                 nrder = 0.0 to determine x-y offset point, 
                                 then assign appropriate z-values back
                                 prior to curve construction.
                                 Set pointers to NULL when deallocating memory.
        S. C. Wood   02/28/90  : Perform individual linear extension on both 
                                 off1 and off2 if order is <= 2.  If off1->
                                 order > 2 and off2->order > 2, generate a
                                 linestring of 4 poles to join off1 and off2.
                                 If either off1->order or off2->order > 2,
                                 linearly extend the offset curve whose order
                                 <= 2 and generate a linestring of 3 poles to
                                 join this extended offset curve and other 
                                 offset curve.
        S. C. Wood   01/17/91  : Call BScvcvint with off1_temp instead of
                                 off1 to get intersection with line2 
                                 (off1_temp is off1 projected onto xy plane).
        S. C. Wood   04/15/92  : Modified to only do linear extension of
                                 off1 and/or off2 if they are order 2, 2D
                                 curves.  Otherwise, generate a linestring
                                 connection.
        S.G. Catron  03/05/93  : When trying to find a new nlder, the
                                 poles were being accessing out of bounds
                                 if num_poles=2.
        S.G. Catron  03/12/93  : Similar change as above, for rational
                                 case.  Also, above change was for end of
                                 off1, but similar change is needed for
                                 start of off2.
        S.C. Wood    04/21/93  : Attempt to deallocate tmp2_knots instead
                                 of tmp2.knots.  Similar problem for
                                 tmp2.poles, tmp2.weights, tmp1.knots, 
                                 tmp1.weights, tmp1.poles. Fix for TR#
                                 9305271.
        S.G. Catron  06/05/00  : For 2 cases, when we create lines between
                                 the offset curves(d1 != d2), we were NOT 
                                 setting the z values back.  They were still
                                 set to 0.0.
        S.G. Catron  07/11/00  : In the case, where we take and intersect the
                                 two tangent lines(infinitely)...check if direction
				 of intersection point is going in the opposite 
				 direction as tangent at the end/beginning, which
                                 would mean we don't want to just move the poles 
				 or even use the intersection point...just create 
				 line between end and start.
        JJ Malosse 20 July 2000: Removed #include bsarcb3pols.h
        S.G. Catron  07/27/00  : Set rc=BSNOSOLUTION if BSxln fails.  Also don't
                                 overwrite this rc at wrapup.   Also don't allocate
                                 line1 and line2.  Just use some static memory.
*********************************************************************************/
#ifdef DONOTSPROTO
#include "ubspmp.h" 
#endif

#ifdef NT 
#include "ubspm.h" 
#else 
#include "bsdefs.h"
#include "bserr.h"
#include "bsparameters.h"
#include "bsmalloc.h"
#include "bsstackalloc.h"
#include "bsconic.h"
#include "bsconicgenx.h"
#include "bsicmpcvoff.h"
#include "bsvalues.h"
#endif
#include <math.h>
#define TRY_NUM 3
#define MAXNUM 100

#define BSVOID

static void collinBSofk3arc(
IGRpoint            a,
IGRpoint            p,
IGRpoint            b,
IGRdouble           d,
IGRvector           normal,
IGRint              right_side,
struct IGRbsp_curve *cv1,
struct IGRbsp_curve *cv2,
struct IGRbsp_curve *off1,
struct IGRbsp_curve *off2,
IGRboolean          fillet,
IGRvector           lder,
IGRvector           rder,
IGRboolean          off1_3d,
IGRboolean          off2_3d,
IGRint              *arc_type,
struct IGRbsp_curve **arc,
BSrc                *rc )
{
#ifndef DONOTSPROTO
#include "bsalloccv.h"
#include "bscrossp.h"
#include "bsnorvec.h"
#include "bsarc3pts.h"
#include "bscrossp.h"
#include "bslenvec.h"
#include "bsconic32.h"
#include "bscveval.h"
#endif 

    IGRboolean status = TRUE;
    IGRboolean lin_ext1=FALSE, lin_ext2=FALSE;
    IGRint     i,j;
    IGRvector  ba,v;    
    IGRpoint   a1s,b1s,p3;
    IGRdouble  t_a, t_b, t_p;
    IGRdouble  len1, len2;
    IGRdouble  cross_tol;
    IGRint     num_deriv;
    IGRpoint   eval1[2], eval1_off[2], eval2[2], eval2_off[2];
    IGRvector  vec1, vec2;
    IGRvector  veca, vecb, avg_vec;
    IGRpoint   tanpta, tanptb, midpt;
    IGRvector  plane_normal;

    /* Calculate original z-values for a, b, and p and store in t_a, t_b, 
       and t_p, respectively. */
    if (off1->rational)
    {
       t_a = off1->poles[3 * (off1->num_poles - 1) + 2] / 
                off1->weights[off1->num_poles - 1];	
    }
    else
    {
       t_a = off1->poles[3 * (off1->num_poles - 1) + 2];
    }

    if (off2->rational)
    {
       t_b = off2->poles[2] / off2->weights[0];
    }
    else
    {
       t_b = off2->poles[2];
    }

    t_p = t_b;

    /* a, p, and b are collinear */

    if( fillet )
    {
       /** Calculate tangents at end of cv1 and off1 and tangents at
           start of cv2 and off2.  If tangents of cv1 and off1 are
           different, or tangents of cv2 and off2 are different, 
           do not construct circular arc fillet.  Construct a general
           conic fillet **/

       BSEXTRACTPAR(rc, BSTOLCOLLINVEC, cross_tol);
       
       num_deriv = 1;
       BScveval(cv1, cv1->knots[cv1->num_poles], num_deriv, eval1, rc);
       if(BSERROR(*rc)) 
         goto wrapup;

       BScveval(off1, off1->knots[off1->num_poles], num_deriv,
                eval1_off, rc);
       if(BSERROR(*rc)) 
         goto wrapup;

       /* Set z-values of eval1 and eval1_off = 0.0 for 3-D case.
          (07/24/89) */
       eval1[1][2] = 0.0;
       eval1_off[1][2] = 0.0;

       BScrossp(rc, eval1[1], eval1_off[1], vec1);
       if(BSERROR(*rc)) 
         goto wrapup;

       BScveval(cv2, cv2->knots[cv2->order - 1], num_deriv, eval2, rc);
       if(BSERROR(*rc)) 
         goto wrapup;

       BScveval(off2, off2->knots[off2->order - 1], num_deriv,
                eval2_off, rc);
       if(BSERROR(*rc)) 
         goto wrapup;

       /* Set z-values of eval2 and eval2_off = 0.0 for 3-D case.
          (07/24/89) */
       eval2[1][2] = 0.0;
       eval2_off[1][2] = 0.0;

       BScrossp(rc, eval2[1], eval2_off[1], vec2);
       if(BSERROR(*rc)) 
          goto wrapup;

       len1 = BSlenvec(rc, vec1);
       len2 = BSlenvec(rc, vec2);

       if (len1 <= cross_tol && len2 <= cross_tol)
       {
          for(i=0; i < 2; i++)
          {
              ba[i] = b[i] - a[i];
          }
          /* Set z-value of ba = 0.0. (07/24/89) */
          ba[2] = 0.0;

          status = BScrossp(rc,ba,normal,v);
          if(! status) 
            goto wrapup;

          status = BSnorvec(rc,v);
          if(! status) 
            goto wrapup;

          for(i=0; i < 2; i++)
          {
             p3[i] = (a[i] + b[i])/ 2.0 + (d * right_side * v[i]);
          }

          /* Set z-values of a and b back to original values, and set z-value 
             of p3 = original z-value of p. (07/24/89) */
          a[2] = t_a;
          b[2] = t_b;
          p3[2] = t_p;

          BSalloccv(3, 7, TRUE, 0, arc, rc);
          if(BSERROR(*rc)) 
            goto wrapup;

          status = BSarc3pts(rc,a,p3,b,*arc);
          if(! status) 
            goto wrapup; 

          *arc_type = BSCVCIRCARC;  /* circular arc */
       }
       else
       {
          BSalloccv(BSORDERCONICGEN, BSPOLESMXCONICGEN, TRUE, 0, arc, rc);
          if(BSERROR(*rc)) 
            goto wrapup;

          if (off1->rational)
          {
             for (i = 0; i < 2; ++i)
             {
                 veca[i] = a[i] - off1->poles[3 * (off1->num_poles  - 2) + i]/
                           off1->weights[off1->num_poles - 2];
             }
          }
          else
          {
             for (i = 0; i < 2; ++i)
             {
                 veca[i] = a[i] - off1->poles[3 * (off1->num_poles  - 2) + i];
             }
          }
          
          if (off2->rational)
          {
             for (i = 0; i < 2; ++i)
             {
                 vecb[i] = off2->poles[i + 3] / off2->weights[1] - b[i];
             }
          }
          else
          {
             for (i = 0; i < 2; ++i)
             {
                 vecb[i] = off2->poles[i + 3] - b[i];
             }
          }

          /* Set z-values of veca and vecb = 0.0. (07/24/89) */
          veca[2] = 0.0;
          vecb[2] = 0.0;

          status = BSnorvec(rc,veca);
          if(! status) 
            goto wrapup;

          status = BSnorvec(rc,vecb);
          if(! status) 
            goto wrapup;

          for (i = 0; i < 3; ++i)
          {
              tanpta[i] = a[i] + veca[i];
              tanptb[i] = b[i] + vecb[i];

              /* Average of vectors calculated by subtracting because 
                 veca and vecb are not oriented the same */
              avg_vec[i] = (veca[i] - vecb[i]) / 2;
          }

          status = BSnorvec(rc,avg_vec);
          if(! status) 
            goto wrapup;
 
          for (i = 0; i < 2; ++i)
          {
              midpt[i] = p[i] + d * avg_vec[i];
          }

          /* Set z-values of a and b back to original values, set z-value 
             of midpt = original z-value of p, tanpta = original z-value
             of a, and tanptb = original z-value of b. (07/24/89) */
          a[2] = t_a;
          b[2] = t_b;
          midpt[2] = t_p;
          tanpta[2] = t_a;
          tanptb[2] = t_p;

          BSconic32(rc, a, midpt, b, tanpta, tanptb, (*arc), plane_normal, 
                    arc_type);
          if(BSERROR(*rc)) 
            goto wrapup;

           *arc_type = BSCVGENCONC;   /* general conic */
       }
    }
    else
    {
       /** extending case **/

       for(i=0; i < 3; i++)
       {
          a1s[i] = a[i] + d * lder[i];
          b1s[i] = b[i] - d * rder[i];
       }
       /* Note: a1s[2] and b1s[2] will = 0.0. (07/24/89) */

       /* Set z-values of a1s and b1s = original z-values of a and b, 
          respectively. (07/24/89) */
       a1s[2] = t_a;
       b1s[2] = t_b;

/*???*/
       a[2] = t_a;
       b[2] = t_b;
/*???*/

       /* Set booleans indicating if off1 and off2 can be linearly extended.
          Linearly extend only if order <= 2 and curve is not 3D. */
       if (off1->order <= 2 && !off1_3d)
          lin_ext1 = TRUE;

       if (off2->order <= 2 && !off2_3d)
          lin_ext2 = TRUE;

       /* If off1=>order > 2 or 3D and off2->order > 2 or 3D, do not extend.
          Insert a linestring of 4 poles to join the curves. */
       if (!lin_ext1 && !lin_ext2)
       {
          BSalloccv(2, 4, FALSE, 0, arc, rc);
          if(BSERROR(*rc)) 
            goto wrapup;

          (*arc)->order = 2;
          (*arc)->non_uniform = TRUE;
          (*arc)->rational = FALSE;
          (*arc)->periodic = FALSE;
          (*arc)->num_poles = 4;
          (*arc)->num_knots = 6;
          (*arc)->weights = NULL;
          (*arc)->planar = FALSE;
          (*arc)->phy_closed = FALSE;
          for(i=0; i < 3; i++)
          {
              (*arc)->poles[i] = a[i];
              (*arc)->poles[3 + i] = a1s[i];
              (*arc)->poles[6 + i] = b1s[i];
              (*arc)->poles[9 + i] = b[i];
          }
          (*arc)->knots[0] = 0.0;
          (*arc)->knots[1] = 0.0;
          (*arc)->knots[2] = .25;
          (*arc)->knots[3] = .75;
          (*arc)->knots[4] = 1.0;
          (*arc)->knots[5] = 1.0;

          *arc_type = BSCVLINESTR; /* a linestring */

       }
       else
       {
          if (!lin_ext1 && lin_ext2)
          {
             /* Linearly extend off2 but do not extend off1.  Generate a
                linestring of 3 poles. */

             if(off2->rational)
             {
                for(j=0; j < 3; j++)
                {
                  off2->poles[j] = b1s[j] * off2->weights[0];
                }
             }
             else
             {
                for(j=0; j < 3; j++)
                {
                  off2->poles[j] = b1s[j];
                }
             }

             BSalloccv(2, 3, FALSE, 0, arc, rc);
             if(BSERROR(*rc)) 
               goto wrapup;

             (*arc)->order = 2;
             (*arc)->non_uniform = TRUE;
             (*arc)->rational = FALSE;
             (*arc)->periodic = FALSE;
             (*arc)->num_poles = 3;
             (*arc)->num_knots = 5;
             (*arc)->weights = NULL;
             (*arc)->planar = FALSE;
             (*arc)->phy_closed = FALSE;
             for(i=0; i < 3; i++)
             {
                 (*arc)->poles[i] = a[i];
                 (*arc)->poles[3 + i] = a1s[i];
                 (*arc)->poles[6 + i] = b1s[i];
             }
             (*arc)->knots[0] = 0.0;
             (*arc)->knots[1] = 0.0;
             (*arc)->knots[2] = .33333;
             (*arc)->knots[3] = 1.0;
             (*arc)->knots[4] = 1.0;

             *arc_type = BSCVLINESTR; /* a linestring */

          }
          else
          {
             if (lin_ext1 && !lin_ext2)
             {
                /* Linearly extend off1 but do not extend off2.  Generate
                   a linestring of 3 poles. */

                if(off1->rational)
                {
                   for(j=0; j < 3; j++)
                   {
                      off1->poles[3 * (off1->num_poles -1) + j] = 
                                  a1s[j] * off1->weights[off1->num_poles -1];
                   }
                }
                else
                {
                   for(j=0; j < 3; j++)
                   {
                      off1->poles[3 * (off1->num_poles -1) + j] = a1s[j];
                   }
                }

                BSalloccv(2, 3, FALSE, 0, arc, rc);
                if(BSERROR(*rc)) 
                  goto wrapup;

                (*arc)->order = 2;
                (*arc)->non_uniform = TRUE;
                (*arc)->rational = FALSE;
                (*arc)->periodic = FALSE;
                (*arc)->num_poles = 3;
                (*arc)->num_knots = 5;
                (*arc)->weights = NULL;
                (*arc)->planar = FALSE;
                (*arc)->phy_closed = FALSE;
                for(i=0; i < 3; i++)
                {
                    (*arc)->poles[i] = a1s[i];
                    (*arc)->poles[3 + i] = b1s[i];
                    (*arc)->poles[6 + i] = b[i];
                }
                (*arc)->knots[0] = 0.0;
                (*arc)->knots[1] = 0.0;
                (*arc)->knots[2] = .66667;
                (*arc)->knots[3] = 1.0;
                (*arc)->knots[4] = 1.0;

                *arc_type = BSCVLINESTR; /* a linestring */

             }
             else
             {
                /* Off1->order <= 2 and is 2D and off2->order <= 2 and is 2D.
                   Linearly extend both off1 and off2. Generate a linestring 
                   of 2 poles joining off1 and off2. */
                if(off1->rational)
                {
                   for(j=0; j < 3; j++)
                   {
                      off1->poles[3 * (off1->num_poles -1) + j] = 
                                  a1s[j] * off1->weights[off1->num_poles -1];
                   }
                }
                else
                {
                   for(j=0; j < 3; j++)
                   {
                      off1->poles[3 * (off1->num_poles -1) + j] = a1s[j];
                   }
                }

                if(off2->rational)
                {
                   for(j=0; j < 3; j++)
                   {
                      off2->poles[j] = b1s[j] * off2->weights[0];
                   }
                }
                else
                {
                   for(j=0; j < 3; j++)
                   {
                      off2->poles[j] = b1s[j];
                   }
                }

                BSalloccv(2, 2, FALSE, 0, arc, rc);
                if(BSERROR(*rc)) 
                  goto wrapup;

                (*arc)->order = 2;
                (*arc)->non_uniform = FALSE;
                (*arc)->rational = FALSE;
                (*arc)->periodic = FALSE;
                (*arc)->num_poles = 2;
                (*arc)->num_knots = 4;
                (*arc)->weights = NULL;
                (*arc)->planar = FALSE;
                (*arc)->phy_closed = FALSE;
                for(i=0; i < 3; i++)
                {
                    (*arc)->poles[i] = a1s[i];
                    (*arc)->poles[3 + i] = b1s[i];
                }
                (*arc)->knots[0] = 0.0;
                (*arc)->knots[1] = 0.0;
                (*arc)->knots[2] = 1.0;
                (*arc)->knots[3] = 1.0;

                *arc_type = BSCVLINE; /* a line */

             }  /* end if (lin_ext1 && !lin_ext2) */
          }   /* end if (!lin_ext1 && lin_ext2) */
       }   /* end if (!lin_ext1 && !lin_ext2) */

    }  /** end of if fillet **/
    wrapup:
      return;
}

void BSofk3arc(
struct IGRbsp_curve *cv1,
struct IGRbsp_curve *cv2,
struct IGRbsp_curve *off1,
struct IGRbsp_curve *off2,
IGRboolean          fillet,
IGRdouble           d1,
IGRdouble           d2,
IGRvector           normal,
IGRint              right_side,
IGRint              *arc_type,
struct IGRbsp_curve **arc,
BSrc                *rc )
{
#ifndef DONOTSPROTO
#include "bsdbgrc.h"
#include "bsalloccv.h"
#include "bststcvdegn.h"
#include "bscveval.h"
#include "bslenvec.h"
#include "bstransconc.h"
#include "bsarc3pts.h"
#include "bsprepcarc.h"
#include "bsxln.h"
#include "bscoincida.h"
#include "bscollin.h"
#include "bscrossp.h"
#include "bsnorvec.h"
#include "bsmerge_cv.h"
#include "bscirrdcr.h"
#include "bscv_copy.h"
#include "bslngen.h"
#include "bstagsort.h"
#include "bsactivsplt.h"
#include "bscvoton.h"
#include "bsdistptpt.h"
#include "bscvcvint.h"
#include "bsfreecv.h"
#include "bstrans2.h"
#include "bsmkvec.h"
#include "bsdotp.h"
#endif 



    IGRboolean collin,degen,coinc;
    IGRboolean status = TRUE, tst_plan = TRUE;
    IGRboolean dummy1 = TRUE;
    IGRboolean dummy8,dummy9;
    IGRboolean off1_3d, off2_3d;
    IGRint     i,j,k;
    IGRint     type,n_int,num_over,num_deriv;
    IGRint     *subs = NULL, *subs1 = NULL;
    IGRlong    maxnum;
    IGRdouble  tpol,dist_tol,zero_tol,cross_tol, vec_tol=1e-15;
    IGRdouble  rr,ss,dmax,dmin;
    IGRdouble  triple[3][3];
    IGRpoint   a,b,ap,bp;
    IGRdouble  t_a, t_b, t_p, tst_z;
    IGRpoint   a_start, b_end;
    IGRpoint   eval[2],p;
    IGRpoint   eval1[2], eval2[2], eval1_off[2], eval2_off[2];
    IGRpoint   a1,b1,x_pnt;
    IGRpoint   end_pt,tan_pt;
    IGRvector  m_vec, b_vec, lder,rder,nlder,nrder;         
    IGRvector  unit_plan_normal;
    IGRvector  vec1, vec2, tnor;
    IGRpoint   tmp1_poles[MAXNUM], tmp2_poles[MAXNUM], pzero;
    IGRdouble  tmp1_weights[MAXNUM], tmp2_weights[MAXNUM];
    IGRdouble  tmp1_knots[MAXNUM], tmp2_knots[MAXNUM];
    IGRdouble  tmat[3][3], scale;
    IGRdouble  radius,ffpar,tpar = 0.0,midpar;
    IGRdouble  d;
    IGRdouble  len1, len2;
    IGRpoint   *dummy2=NULL, *dummy5=NULL;
    IGRdouble  dummy3,dummy4,dummy6,dummy7;
    IGRdouble  *int_pts = NULL, *par1 = NULL, *par2 = NULL;
    IGRdouble  *end_pts = NULL, *over1 = NULL, *over2 = NULL, max;
    IGRboolean alloc_tmp1_poles = FALSE, alloc_tmp1_weights = FALSE, 
               alloc_tmp1_knots = FALSE;
    IGRboolean alloc_tmp2_poles = FALSE, alloc_tmp2_weights = FALSE, 
               alloc_tmp2_knots = FALSE;
    struct IGRbsp_curve *off1_temp = NULL, *off2_temp = NULL, 
                        *line1 = NULL, *line2 = NULL,
                        *act1_cur = NULL, *act2_cur = NULL,
                        *sub_cv = NULL, *sub_line = NULL, *fil_arc = NULL,
                        *circle = NULL, *tptr = NULL, tmp1, tmp2, sline1, sline2;
    IGRdouble lpoles1[6], lpoles2[6], lknots1[4], lknots2[4];
    BSrc       rc2 = BSSUCC, rc3 = BSSUCC,
               rc4 = BSSUCC, rc5 = BSSUCC, rc6 = BSSUCC, rc7 = BSSUCC,
               rc8 = BSSUCC, rc9 = BSSUCC, rc10 = BSSUCC; 

    *rc = BSSUCC;

    tptr = cv2;   /* These lines of code are to avoid the lint */
    tptr = tptr;  /*  error for unused argument (cv2)          */

    *arc_type = BSCVGENBSPC; /** initialized to general B-spline **/

    BSEXTRACTPAR(rc, BSTOLLENVEC, dist_tol);
    BSEXTRACTPAR(rc, BSTOLCLOSETOZERO, zero_tol);

    /* If normal vector is not (0, 0, 1), transform curves so that normal
       = (0, 0, 1).  (normal = plane normal for 2D curves and view vector
       for 3D curves). */
    maxnum = off1->num_poles;
    if(maxnum > MAXNUM )
    {
       tmp1.poles = (IGRdouble *)BSstackalloc((unsigned)(maxnum *
                           sizeof(IGRpoint)));
       if(! tmp1.poles )
       {
          *rc = BSNOSTKMEMORY;
          goto wrapup;
       }
       alloc_tmp1_poles = TRUE;

       if(off1->rational)
       {
          tmp1.weights = (IGRdouble *)BSstackalloc((unsigned)(maxnum *
                                sizeof(IGRdouble)));
          if(! tmp1.weights )
          {
             *rc = BSNOSTKMEMORY;
             goto wrapup;
          }
          alloc_tmp1_weights = TRUE;
       }
    }
    else
    {
       tmp1.poles = &tmp1_poles[0][0];
       if( off1->rational)
          tmp1.weights = tmp1_weights;
    }
    tmp1.bdrys = NULL;
    if( maxnum + off1->order > MAXNUM )
    {
       tmp1.knots = (IGRdouble *)BSstackalloc((unsigned)( (maxnum +
                           off1->order) * sizeof(IGRdouble)));
       if(! tmp1.knots )
       { 
          *rc = BSNOSTKMEMORY;
          goto wrapup;
       }
       alloc_tmp1_knots = TRUE;
    }
    else
    {
       tmp1.knots = tmp1_knots;
    }

    maxnum = off2->num_poles;
    if(maxnum > MAXNUM )
    {
       tmp2.poles = (IGRdouble *)BSstackalloc((unsigned)(maxnum *
                           sizeof(IGRpoint)));
       if(! tmp2.poles )
       {
          *rc = BSNOSTKMEMORY;
          goto wrapup;
       }
       alloc_tmp2_poles = TRUE;

       if(off2->rational)
       {
          tmp2.weights = (IGRdouble *)BSstackalloc((unsigned)(maxnum *
                                sizeof(IGRdouble)));
          if(! tmp2.weights )
          {
             *rc = BSNOSTKMEMORY;
             goto wrapup;
          }
          alloc_tmp2_weights = TRUE;
       }
    }
    else
    {
       tmp2.poles = &tmp2_poles[0][0];
       if( off2->rational)
          tmp2.weights = tmp2_weights;
    }
    tmp2.bdrys = NULL;
    if( maxnum + off1->order > MAXNUM )
    {
       tmp2.knots = (IGRdouble *)BSstackalloc((unsigned)( (maxnum +
                           off2->order) * sizeof(IGRdouble)));
       if(! tmp2.knots )
       { 
          *rc = BSNOSTKMEMORY;
          goto wrapup;
       }
       alloc_tmp2_knots = TRUE;
    }
    else
    {
       tmp2.knots = tmp2_knots;
    }

   if (ABS(normal[0]) < vec_tol && ABS(normal[1]) < vec_tol &&
       ABS(normal[2] - 1.0) < vec_tol)
   {
      /* vec is within tolerance of (0, 0, 1) -- set tnor = (0, 0, 1) and
         copy cv1 into new_cv1 and cv2 into new_cv2 */
      tnor[0] = 0.0;
      tnor[1] = 0.0;
      tnor[2] = 1.0;

      (void)BScv_copy(rc, off1, &tmp1);
      if (BSERROR(*rc))
         goto wrapup;

      (void)BScv_copy(rc, off2, &tmp2);
      if (BSERROR(*rc))
         goto wrapup;
   }
   else
   {
      /* Transform cv1 and cv2 to be in xy plane */
      BStrans2(normal, TRUE, tmat, rc);
      if (BSERROR(*rc)) 
         goto wrapup;

      tnor[0] = 0.0;  /** transformed normal **/
      tnor[1] = 0.0;
      tnor[2] = 1.0;

      pzero[0] = 0.0;
      pzero[1] = 0.0;
      pzero[2] = 0.0;

      scale = 1.0;
      status = BScvoton(rc, pzero, tmat, &scale, off1, &tmp1);
      if (! status) 
         goto wrapup;

      status = BScvoton(rc, pzero, tmat, &scale, off2, &tmp2);
      if (! status) 
         goto wrapup;
      
   }  /* end if (ABS(normal[0]) < vec_tol && ABS(normal[1]) < vec_tol &&... */

    /* Check if off1 and off2 are 2D or 3D curves. Set booleans to be used
       later. */
    tst_z = tmp1.poles[2];
    j = 1;
    off1_3d = FALSE;
    while (j < tmp1.num_poles && !off1_3d)
    {
        if (ABS(tmp1.poles[3*j+2] - tst_z) > zero_tol)
           off1_3d = TRUE;
        ++j;
    }

    tst_z = tmp2.poles[2];
    j = 1;
    off2_3d = FALSE;
    while (j < tmp2.num_poles && !off2_3d)
    {
         if (ABS(tmp2.poles[3*j+2] - tst_z) > zero_tol)
            off2_3d = TRUE;
         ++j;
    }

    /**-----------------------------------------------------
       Find the last point on off1 and the 1st point on off2.
       Since off1 and off2 both have multiple end knots, we can
       use the end poles as the end points of the curves.       
    --------------------------------------------------------**/

    max = 0.0;
    if(off1->rational)
    {
       for(i=0; i <= 2; i++)
       {
          a[i] = off1->poles[3 * (off1->num_poles -1) + i] / 
                 off1->weights[off1->num_poles -1];
          lder[i] = off1->poles[3 * (off1->num_poles -1) + i] / 
                    off1->weights[off1->num_poles -1] - 
                    off1->poles[3 * (off1->num_poles -2)+ i] / 
                    off1->weights[off1->num_poles -2];
          nlder[i] = lder[i];
          if( ABS(nlder[i]) > max )
             max = ABS(nlder[i]);
       }
       if( max * max < MINFLOAT && off1->num_poles > 2)
       {
          /* try to find a new nlder */
          for(i=0; i <= 2; i++)
          {
             lder[i] = off1->poles[3 * (off1->num_poles -1) + i] / 
                       off1->weights[off1->num_poles -1] - 
                       off1->poles[3 * (off1->num_poles -3) + i] / 
                       off1->weights[off1->num_poles -3];
             nlder[i] = lder[i];
          }
       }          
    }
    else
    {
       for(i=0; i <= 2; i++)
       {
          a[i] = off1->poles[3 * (off1->num_poles -1) + i];
          lder[i] = off1->poles[3 * (off1->num_poles -1) + i] -
                      off1->poles[3 * (off1->num_poles -2) +i];
          nlder[i] = lder[i];
          if( ABS(nlder[i]) > max )
             max = ABS(nlder[i]);
       }
       if( max * max < MINFLOAT && off1->num_poles > 2)
       {
          /* try to find a new nlder */
          for(i=0; i <= 2; i++)
          {
             lder[i] = off1->poles[3 * (off1->num_poles -1) + i] -
                         off1->poles[3 * (off1->num_poles -3) +i];
             nlder[i] = lder[i];
          }
       }  
    }    

    /* Store z-value of a in temporary variable (t_a) and set z-values
       of a, lder, and nlder = 0.0 (necessary for 3-D case)  07/24/89 */
    t_a = a[2];
    a[2] = 0.0;
    lder[2] = 0.0;
    nlder[2] = 0.0;

    max = 0.0;
    if(off2->rational)
    {
       for(i=0; i <= 2; i++)
       {
          b[i] = off2->poles[i] / off2->weights[0];
          rder[i] = off2->poles[3 + i] / off2->weights[1] -
                     off2->poles[i] / off2->weights[0];
          nrder[i] = rder[i];
          if( ABS(nrder[i]) > max )
             max = ABS(nrder[i]);
       }
       if( max * max < MINFLOAT && off2->num_poles > 2)
       {
           /* try to find a new nrder */
          for(i=0; i <= 2; i++)
          {
             rder[i] = off2->poles[6 + i] / off2->weights[2] -
                       off2->poles[i] / off2->weights[0];
             nrder[i] = rder[i];
          }
       }
    }
    else
    {
       for(i=0; i <= 2; i++)
       {
          b[i] = off2->poles[i];
          rder[i] = off2->poles[3 + i] - off2->poles[i];
          nrder[i] = rder[i];
          if( ABS(nrder[i]) > max )
             max = ABS(nrder[i]);
       }
       if( max * max < MINFLOAT && off2->num_poles > 2)
       {
          for(i=0; i <= 2; i++)
          {
             rder[i] = off2->poles[6 + i] - off2->poles[i];
             nrder[i] = rder[i];
          }
       }
    }    

    /* Store z-value of b in temporary variable (t_b) and set z-values
       of a, rder, and nrder = 0.0 (necessary for 3-D case)  07/24/89 */
    t_b = b[2];
    b[2] = 0.0;
    rder[2] = 0.0;
    nrder[2] = 0.0;

    /* Make copy of off1 and off2 into off1_temp and off2_temp and set 
       z-coordinates of poles of off1_temp and off2_temp = 0.0.  Use
       off1_temp and off2_temp to calculate intersections prior to 
       construction of fillet.  (07/24/89) */
        
    BSalloccv(off1->order, off1->num_poles, off1->rational, 0, &off1_temp, rc);
    if(BSERROR(*rc)) 
      goto wrapup;

    status = BScv_copy(rc, off1, off1_temp);
    if(! status) 
      goto wrapup;

    for (i = 0; i < off1_temp->num_poles; ++i)
    { 
        off1_temp->poles[3 * i + 2] = 0.0;
    }

    BSalloccv(off2->order, off2->num_poles, off2->rational, 0, &off2_temp, rc);
    if(BSERROR(*rc)) 
      goto wrapup;

    status = BScv_copy(rc, off2, off2_temp);
    if(! status) 
      goto wrapup;

    for (i = 0; i < off2_temp->num_poles; ++i)
    { 
        off2_temp->poles[3 * i + 2] = 0.0;
    }

    /**-----------------------------------------------------------
       If off1  is a point curve, compute lder and nlder with cv1.
       Note : use off1_temp with z-values = 0.0 to test degeneracy (07/24/89)
    --------------------------------------------------------------**/

    BStstcvdegn(off1_temp, &degen, rc);
    if(BSERROR(*rc)) 
      goto wrapup;

    if(degen)
    {
       if(cv1->rational)
       {
          for(i=0; i <= 2; i++)
          {
             lder[i] = cv1->poles[3 * (cv1->num_poles -1) + i] / cv1->weights[
                     cv1->num_poles -1] - cv1->poles[3 * (cv1->num_poles -2)
                      + i] / cv1->weights[cv1->num_poles -2];
             nlder[i] = lder[i];
          }
       }
       else
       {
          for(i=0; i <= 2; i++)
          {
             lder[i] = cv1->poles[3 * (cv1->num_poles -1) + i] -
                         cv1->poles[3 * (cv1->num_poles -2) +i];
             nlder[i] = lder[i];
          }
       }    
       /* Set z-values of lder and nlder = 0.0 for 3-D case (07/24/89) */
       lder[2] = 0.0;
       nlder[2] = 0.0;
    }

    status = BSnorvec(rc, nlder);
    if(! status) 
      goto wrapup;

    status = BSnorvec(rc, nrder);
    if(! status) 
      goto wrapup;
    
    tpol = cv1->knots[cv1->num_poles];
    BScveval(cv1,tpol, 0, (IGRpoint *)p,rc);
    if (BSERROR(*rc)) 
       goto wrapup;

    /* Set z-values of p = 0.0 for 3-D cases. (07/24/89) */
    t_p = p[2];
    p[2] = 0.0;

    /**----------------------------------------------------------------
      check if a, b, and p are collinear? if TRUE, means off1 and off2
      will intersect at infinity and we will make fillet or line string
      to connect with off1 and off2; if FALSE, means off1 and off2 
      can intersect within a certain range of extension.         
    ------------------------------------------------------------------**/

    collin = BScollin(rc,a,p,b);
    if(BSERROR(*rc)) 
      goto wrapup;

    /** if a,p and b are coincide, return the offset curves as they are. **/

    for(i=0; i < 3; i++)
    {
       triple[0][i] = a[i];
       triple[1][i] = p[i];
       triple[2][i] = b[i];
    }
    coinc = BScoincida(3, triple, rc);
    if(coinc || BSERROR(*rc)) 
      goto wrapup;

    if( d1 > d2 )
    {
       dmax = d1;
       dmin = d2;
    }
    else
    {
       dmax = d2;
       dmin = d1;
    }
    d = (d1 + d2) / 2;



    if(fabs(d1 - d2) < dist_tol)
    {
       if(collin)
       {
          collinBSofk3arc(a,p,b,d,normal,right_side,cv1,cv2,off1,off2,fillet,
                          nlder,nrder,off1_3d,off2_3d,arc_type,arc,rc);
          if(BSERROR(*rc)) 
            goto wrapup;
       }
       else
       {
          if( fillet )
          {
             /** filleting case **/

             /** Calculate tangents at end of cv1 and off1 and tangents at
                 start of cv2 and off2.  If tangents of cv1 and off1 are
                 different, or tangents of cv2 and off2 are different, 
                 do not construct circular arc fillet.  Construct a general
                 conic fillet **/

             BSEXTRACTPAR(rc, BSTOLCOLLINVEC, cross_tol);
        
             num_deriv = 1;
             BScveval(cv1, cv1->knots[cv1->num_poles], num_deriv, eval1, rc);
             if(BSERROR(*rc)) 
               goto wrapup;

             BScveval(off1, off1->knots[off1->num_poles], num_deriv,
                      eval1_off, rc);
             if(BSERROR(*rc)) 
               goto wrapup;

             /* Set z-values of eval1 and eval1_off = 0.0 for 3-D case.
                (07/24/89) */
             eval1[1][2] = 0.0;
             eval1_off[1][2] = 0.0;

             BScrossp(rc, eval1[1], eval1_off[1], vec1);
             if(BSERROR(*rc)) 
               goto wrapup;

             BScveval(cv2, cv2->knots[cv2->order - 1], num_deriv, eval2, rc);
             if(BSERROR(*rc)) 
               goto wrapup;

             BScveval(off2, off2->knots[off2->order - 1], num_deriv,
                      eval2_off, rc);
             if(BSERROR(*rc)) 
               goto wrapup;

             /* Set z-values of eval2 and eval2_off = 0.0 for 3-D case.
                (07/24/89) */
             eval2[1][2] = 0.0;
             eval2_off[1][2] = 0.0;

             BScrossp(rc, eval2[1], eval2_off[1], vec2);
             if(BSERROR(*rc)) 
               goto wrapup;

             len1 = BSlenvec(rc, vec1);
             len2 = BSlenvec(rc, vec2);

             if (len1 <= cross_tol && len2 <= cross_tol)
             {
                for(j=0; j < 3; j++)
                {
                   ap[j] = a[j] - p[j];
                   bp[j] = b[j] - p[j];
                }

                status = BScrossp(rc,ap,bp,m_vec);
                if(! status) 
                  goto wrapup;
                      
                BSalloccv(3, 7, TRUE, 0, arc, rc);
                if(BSERROR(*rc)) 
                  goto wrapup;

                /* Set z-values of a, p, and b back to original values
                   (t_a, t_b, t_p, respectively) (07/24/89) */
                a[2] = t_a;
                b[2] = t_b;
                p[2] = t_p;

                status = BSprepcarc(rc,a,p,b,m_vec,*arc, unit_plan_normal,
                                    &type);
                if(! status) 
                  goto wrapup;
  
                *arc_type = BSCVCIRCARC;   /* circular arc */
             }
             else
             {
                /* the end tangents of cv1 and off1 are not equal OR 
                   the start tangents of cv2 and off2 are not equal */

                if (off1->rational)
                {
                   for (i = 0; i < 2; ++i)
                   {
	                a_start[i] = off1->poles[i] / off1->weights[0];
	           }
                }
                else
                {
                   for (i = 0; i < 2; ++i)
                   {
	                a_start[i] = off1->poles[i];
	           }
                }

                if (off2->rational)
                {
                   for (i = 0; i < 2; ++i)
                   {
	                b_end[i] = off2->poles[3 * (off2->num_poles - 1)+i]/
	                           off2->weights[off2->num_poles - 1];
	           }
	        }
                else
                {
                   for (i = 0; i < 2; ++i)
                   {
                       b_end[i] = off2->poles[3 * (off2->num_poles - 1)+i];
	           }
                }

                /* Set z-values of a_start and b_end = 0.0 to find x-y
                   intersection. (07/24/89) */
                a_start[2] = 0.0;
                b_end[2] = 0.0;

                BSalloccv(BSORDERCONICGEN, BSPOLESMXCONICGEN, TRUE, 0, arc, 
                          rc);
                if(BSERROR(*rc)) 
                  goto wrapup;

                status = BSxln(rc, a_start, a, b, b_end, x_pnt);
                if(! status) 
                  goto wrapup;

                /* Set z-values of a, b, and p back to original values and
                   set z_value of x_pnt = p[2]. Note: p[2]=a[2]=b[2]
                   (07/24/89) */
                a[2] = t_a;
                b[2] = t_b;
                p[2] = t_p;
                x_pnt[2] = p[2];

                BStransconc(a, x_pnt, b, p, *arc, rc);
                if(BSERROR(*rc)) 
                  goto wrapup;               

                *arc_type = BSCVGENCONC;   /* general conic */

             }
          }
          else
          {
             /** extending case **/

             for(j=0; j < 3; j++)
             {
               a1[j] = a[j] + lder[j];
               b1[j] = b[j] - rder[j];
             }

             status = BSxln(rc,a,a1,b,b1, x_pnt);
             if(status)
             {
                /* Set z-value of x_pnt = t_p and set z-values of a & b back
                   to original value. (07/24/89) */
                x_pnt[2] = t_p;
                a[2] = t_a;
                b[2] = t_b;

                if(off1->order == 2 && !off1_3d)
                {
                   if(off1->rational)
                   {
                      for(j=0; j < 3; j++)
                      {
                         off1->poles[3 * (off1->num_poles -1) +j]
                         = x_pnt[j] * off1->weights[off1->num_poles -1];
                      }
                   }
                   else
                   {
                      for(j=0; j < 3; j++)
                      {
                         off1->poles[3 * (off1->num_poles -1) +j]
                         = x_pnt[j];
                      }
                   }                    

                   if(off2->order == 2 && !off2_3d)
                   {
                      if(off2->rational)
                      {
                         for(j=0; j < 3; j++)
                         {
                            off2->poles[j] = x_pnt[j] * off2->weights[0];
                         }
                      }
                      else
                      {
                         for(j=0; j < 3; j++)
                         {
                            off2->poles[j] = x_pnt[j];
                         }
                      }                    
                   }
                   else
                   {
                       /** off1 is order 2 and 2d and off2 is not order 2
                           or not 2d. Make a line from x_pnt to 1st pole of 
                           off2. **/

                       BSalloccv(2, 2, FALSE, 0, arc, rc);
                       if(BSERROR(*rc)) 
                         goto wrapup;

                       (*arc)->order = 2;
                       (*arc)->non_uniform = FALSE;
                       (*arc)->rational = FALSE;
                       (*arc)->periodic = FALSE;
                       (*arc)->num_poles = 2;
                       (*arc)->num_knots = 4;
                       (*arc)->weights = NULL;
                       (*arc)->planar = FALSE;
                       (*arc)->phy_closed = FALSE;
                       for(k=0; k < 3; k++)
                       {
                          (*arc)->poles[k] = x_pnt[k];
                          (*arc)->poles[3 + k] = b[k];
                       }
                       (*arc)->knots[0] = 0.0;
                       (*arc)->knots[1] = 0.0;
                       (*arc)->knots[2] = 1.0;
                       (*arc)->knots[3] = 1.0;

                       *arc_type = BSCVLINE;  /* a line */
                    }
                 }
                 else
                 {
                    /** off1 is not order 2 or not 2d**/

                    if(off2->order == 2 && !off2_3d)
                    {
                       BSalloccv(2, 2, FALSE, 0, arc, rc);
                       if(BSERROR(*rc)) 
                         goto wrapup;

                       (*arc)->order = 2;
                       (*arc)->non_uniform = FALSE;
                       (*arc)->rational = FALSE;
                       (*arc)->periodic = FALSE;
                       (*arc)->num_poles = 2;
                       (*arc)->num_knots = 4;
                       (*arc)->weights = NULL;
                       (*arc)->planar = FALSE;
                       (*arc)->phy_closed = FALSE;
                       for(k=0; k < 3; k++)
                       {
                          (*arc)->poles[k] = a[k];
                          (*arc)->poles[3 + k] = x_pnt[k];
                       }
                       (*arc)->knots[0] = 0.0;
                       (*arc)->knots[1] = 0.0;
                       (*arc)->knots[2] = 1.0;
                       (*arc)->knots[3] = 1.0;

                       *arc_type = BSCVLINE;  /* a line */

                       if(off2->rational)
                       {
                          for(j=0; j < 3; j++)
                          {
                             off2->poles[j] = x_pnt[j] * off2->weights[0];
                          }
                       }
                       else
                       {
                          for(j=0; j < 3; j++)
                          {
                             off2->poles[j] = x_pnt[j];
                          }
                       }                    
                    }
                    else
                    {
                       /** Both off1 and off2 are not order 2 or not 2d **/

                       BSalloccv(2, 3, FALSE, 0, arc, rc);
                       if(BSERROR(*rc)) 
                         goto wrapup;

                       (*arc)->order = 2;
                       (*arc)->non_uniform = FALSE;
                       (*arc)->rational = FALSE;
                       (*arc)->periodic = FALSE;
                       (*arc)->num_poles = 3;
                       (*arc)->num_knots = 5;
                       (*arc)->weights = NULL;
                       (*arc)->planar = TRUE;
                       (*arc)->phy_closed = FALSE;
                       for(k=0; k < 3; k++)
                       {
                          (*arc)->poles[k] = a[k];
                          (*arc)->poles[3 + k] = x_pnt[k];
                          (*arc)->poles[6 + k] = b[k];
                       }
                       (*arc)->knots[0] = 0.0;
                       (*arc)->knots[1] = 0.0;
                       (*arc)->knots[2] = 0.5;
                       (*arc)->knots[3] = 1.0;
                       (*arc)->knots[4] = 1.0;

                       *arc_type = BSCVLINESTR;  /* line string */
                    }
                 }
             }
             else
             {
                 *rc = BSNOSOLUTION;
                 goto wrapup;
             }
          }
       }
    }
    else
    {
       /*------------------------------
          d1 > d2  or d2 > d1
       ------------------------------*/
          line1 = &sline1;
          line1->poles = lpoles1;
          line1->knots = lknots1;
          line2 = &sline2;
          line2->poles = lpoles2;
          line2->knots = lknots2;
          /** make an extended line along the tangent direction of the last
              point of off1 **/

          for(i=0; i < 2; i++)
          {
             a1[i] = a[i] + TRY_NUM * dmax * nlder[i]; 
          }
          /* Set a1[2] = 0.0 (07/24/89) */
          a1[2] = 0.0;

          status = BSlngen(rc, a, a1, line1, &type);
          if(! status) 
            goto wrapup;

          /** find the intersection between line1 and off2_temp 
              Note: this is finding x-y intersection; in essence, 
              intersection of line1 in x-y plane and projection
              of off2 onto x-y plane. (07/24/89) **/      
    
          BScvcvint(line1, off2_temp, dummy1, 0,0, dummy2, & dummy3, &dummy4,
             dummy5, &dummy6, &dummy7, &n_int, &num_over, &dummy8, &dummy9,
             (IGRpoint **)&int_pts, &par1, &par2, (IGRpoint **)&end_pts,
             &over1, &over2, rc);
          if(BSERROR(*rc)) 
            goto wrapup;

          if(end_pts) BSdealloc((char *)end_pts); end_pts = NULL;
          if(over1) BSdealloc((char *)over1); over1 = NULL;
          if(over2) BSdealloc((char *)over2); over2 = NULL;

          if(n_int >= 1)
          {
             if(n_int > 1)
             {
                subs = (IGRint *)BSstackalloc((unsigned)(n_int * sizeof(
                            IGRint)));
                if(! subs)
                {
                   *rc = BSNOSTKMEMORY;
                   goto wrapup;
                }
                status = BStagsort(rc, &n_int, par1, subs);
                if(! status) 
                  goto wrapup;

                rr = par1[subs[n_int -1]];
                ss = par2[subs[n_int -1]];
                for(j=0; j < 3; j++)
                {
                   x_pnt[j] = int_pts[3 * (subs[n_int -1] -1) +j];
                }
               /* Note : x_pnt[2] will = 0.0 because BScvcvint returned
                  intersection of line1 and off2 projected only x-y plane.
                  (07/24/89) */
             }
             else
             {
                rr = par1[0];
                ss = par2[0];
                for(j=0; j < 3; j++)
                {
                   x_pnt[j] = int_pts[j];
                }
             }

            /* Note : x_pnt[2] will = 0.0 because BScvcvint returned
               intersection of line1 and off2 projected only x-y plane.
               (07/24/89) */

             if(int_pts) BSdealloc((char *)int_pts); int_pts = NULL;
             if(par1) BSdealloc((char *)par1); par1 = NULL;
             if(par2) BSdealloc((char *)par2); par2 = NULL;

             if(fillet)
             {

                radius = (dmin + dmax) / 2.0;
                BSalloccv(BSCIRCLE_ORDER, BSCIRCLE_NUM_POLES_MAX,
                  TRUE, 0, &circle, rc);
                if(BSERROR(*rc)) 
                  goto wrapup;
                
                status = BScirrdcr(rc, &radius, x_pnt, circle);
                if(! status) 
                  goto wrapup;

                /* Find intersection of circle and off2_temp (this will
                   be an x-y intersection). (07/24/89) */

                BScvcvint(circle, off2_temp, dummy1, 0,0, dummy2, & dummy3, 
                  &dummy4, dummy5, &dummy6, &dummy7, &n_int, &num_over, 
                  &dummy8, &dummy9, (IGRpoint **)&int_pts, &par1, &par2,
                  (IGRpoint **)&end_pts, &over1, &over2, rc);
                if(BSERROR(*rc)) 
                  goto wrapup;

                if(end_pts) BSdealloc((char *)end_pts); end_pts = NULL;
                if(over1) BSdealloc((char *)over1); over1 = NULL;
                if(over2) BSdealloc((char *)over2); over2 = NULL;

                if(n_int >=1 )
                {
                   if(n_int > 1)
                   {
                      subs1 = (IGRint *)BSstackalloc((unsigned)(n_int * sizeof(
                                 IGRint)));
                      if(! subs1)
                      {
                         *rc = BSNOSTKMEMORY;
                         goto wrapup;
                      }
                      status = BStagsort(rc, &n_int, par2, subs1);
                      if(! status) 
                        goto wrapup;
                      
                      for(j=0; j < n_int; j++)
                      {
                         if(par2[subs1[j]] > ss )
                         {
                            tpar = par2[subs1[j]];
                            break;
                         }
                      } 
                   }
                   else
                   {
                      /** n_int = 0 **/
                   
                      tpar = par2[0];
                   }
                   if(int_pts) BSdealloc((char *)int_pts); int_pts = NULL;
                   if(par1) BSdealloc((char *)par1); par1 = NULL;
                   if(par2) BSdealloc((char *)par2); par2 = NULL;
                }
                else
                {
                   /** no intersection points **/

                   tpar = off2->knots[off2->num_poles];
                }

                midpar = (ss + off2->knots[off2->num_poles]) / 2;

                if(midpar > tpar)
                {
                   ffpar = tpar;
                }
                else
                {
                   ffpar = midpar;
                }

                /**-----------------------------------------------
                   Modified on 1/12/88:
                   Make a rational curve to replace the line and arc
                   as the connection between two offset curves.
                ----------------------------------------------------**/

                BSalloccv(BSORDERCONICGEN, BSPOLESMXCONICGEN,
                  TRUE, 0, arc, rc);
                if(BSERROR(*rc)) 
                  goto wrapup;
                
                BScveval(off2,ffpar, 1, eval,rc);
                if (BSERROR(*rc)) 
                   goto wrapup;

                for(j=0; j < 2; j++)
                {
                   end_pt[j] = eval[0][j];
                   tan_pt[j] = end_pt[j] - eval[1][j];
                }

                /* Set z-values of end_pt and tan_pt = 0.0 (07/24/89) */
                end_pt[2] = 0.0;
                tan_pt[2] = 0.0;

                status = BSxln(rc, a, a1, end_pt, tan_pt, x_pnt);
                if(! status) 
                  goto wrapup;

                /* Set z-values of a and p back to original values and
                   set z-values of x_pnt and end_pt = original z-value
                   of p. (07/24/89) */
                a[2] = t_a;
                p[2] = t_p;
                x_pnt[2] = p[2];
                end_pt[2] = p[2];

                BStransconc(a, x_pnt, end_pt, p, *arc, rc);
                if(BSERROR(*rc)) 
                   goto wrapup;               

                *arc_type = BSCVGENCONC;   /* general conic */

                /** trim off2 **/

                BSalloccv(off2->order, off2->num_poles, off2->rational,
                   0, &act2_cur, rc);
                if(BSERROR(*rc)) 
                  goto wrapup;

                status = BSactivsplt(rc, off2, &ffpar, &off2->knots[
                            off2->num_poles], act2_cur, &tst_plan);
                if(! status) 
                  goto wrapup;

                status = BScv_copy(rc, act2_cur, off2);
                if(! status) 
                  goto wrapup;

             }
             else
             {
                /**----------------------------------------
                   extending case: extend off1 and trim off2
                -------------------------------------------**/

                /* Set z-values of x_pnt = original z-values of p.
                   (07/24/89) */
                x_pnt[2] = t_p;

                if(off1->order == 2 && !off1_3d)
                {
                   if(off1->rational)
                   {
                      for(j=0; j < 3; j++)
                      {
                         off1->poles[3 * (off1->num_poles -1) +j]
                         = x_pnt[j] * off1->weights[off1->num_poles -1];
                      }
                   }
                   else
                   {
                      for(j=0; j < 3; j++)
                      {
                         off1->poles[3 * (off1->num_poles -1) +j]
                         = x_pnt[j];
                      }
                   }                    
                }
                else
                {
                   BSalloccv(line1->order, line1->num_poles, line1->rational,
                      0, arc, rc);
                   if(BSERROR(*rc)) 
                     goto wrapup;

                   status = BSactivsplt(rc, line1, 
                               &line1->knots[line1->order -1], &rr, *arc, 
                               &tst_plan);
                   if(! status) 
                     goto wrapup;
                   /* S.G. Catron 06/05/00 */
                   /* we have to set the z back correctly */
                   (*arc)->poles[2] = t_a;
                   (*arc)->poles[5] = x_pnt[2];
                   *arc_type = BSCVLINE;   /* a line */
                }
 
                BSalloccv(off2->order, off2->num_poles, off2->rational,
                   0, &act2_cur, rc);
                if(BSERROR(*rc)) 
                  goto wrapup;

                status = BSactivsplt(rc, off2, &ss, &off2->knots[
                            off2->num_poles], act2_cur, &tst_plan);
                if(! status) 
                  goto wrapup;

                status = BScv_copy(rc, act2_cur, off2);
                if(! status) 
                  goto wrapup;
             }
          }
          else
          {
             /** "line1" does not intersect with off2 and we need to create
                 a tangent line "line2 at the starting point of off2 to 
                 see if there is an intersection between line2 and off1 **/

             for(i=0; i < 2; i++)
             {
                b1[i] = b[i] - TRY_NUM * dmax * nrder[i]; 
             }
             /* Set z-value of b1 = 0.0. (07/24/89) */
             b1[2] = 0.0;

             status = BSlngen(rc, b, b1, line2, &type);
             if(! status) 
               goto wrapup;

             /** find the intersection between off1_temp and line2
                 Note: this is finding x-y intersection; in essence, 
                 intersection of line2 which is  in x-y plane and projection
                 of off1 onto x-y plane. (07/24/89) **/      
    
             BScvcvint(off1_temp, line2, dummy1,0,0, dummy2, &dummy3, &dummy4,
                dummy5, &dummy6, &dummy7, &n_int, &num_over, &dummy8, &dummy9,
                (IGRpoint **)&int_pts, &par1, &par2, (IGRpoint **)&end_pts,
                &over1, &over2, rc);
             if(BSERROR(*rc)) 
               goto wrapup;

             if(end_pts) BSdealloc((char *)end_pts); end_pts = NULL;
             if(over1) BSdealloc((char *)over1); over1 = NULL;
             if(over2) BSdealloc((char *)over2); over2 = NULL;
            
             if(n_int >= 1)
             {
                if(n_int > 1)
                {
                   subs = (IGRint *)BSstackalloc((unsigned)(n_int * sizeof(
                               IGRint)));
                   if(! subs)
                   {
                      *rc = BSNOSTKMEMORY;
                      goto wrapup;
                   }
                   status = BStagsort(rc, &n_int, par1, subs);
                   if(! status) 
                     goto wrapup;

                   rr = par1[subs[n_int -1]];
                   ss = par2[subs[n_int -1]];
                   for(j=0; j < 3; j++)
                   {
                      x_pnt[j] = int_pts[3 * (subs[n_int -1] -1) +j];
                   }
                }
                else
                {
                   rr = par1[0];
                   ss = par2[0];
                   for(j=0; j < 3; j++)
                   {
                      x_pnt[j] = int_pts[j];
                   }
                }

                if(int_pts) BSdealloc((char *)int_pts); int_pts = NULL;
                if(par1) BSdealloc((char *)par1); par1 = NULL;
                if(par2) BSdealloc((char *)par2); par2 = NULL;


                if(fillet)
                {
                   radius = (dmin + dmax) / 2.0;
                   BSalloccv(BSCIRCLE_ORDER, BSCIRCLE_NUM_POLES_MAX,
                     TRUE, 0, &circle, rc);
                   if(BSERROR(*rc)) 
                     goto wrapup;
                
                   status = BScirrdcr(rc, &radius, x_pnt, circle);
                   if(! status) 
                     goto wrapup;

                /* Find intersection of circle and off1_temp (this will
                   be an x-y intersection). (07/24/89) */

                   BScvcvint(off1_temp,circle, dummy1, 0,0, dummy2, & dummy3, 
                     &dummy4, dummy5, &dummy6, &dummy7, &n_int, &num_over, 
                     &dummy8, &dummy9,(IGRpoint **)&int_pts, &par1, &par2,
                     (IGRpoint **)&end_pts, &over1, &over2, rc);
                   if(BSERROR(*rc)) 
                     goto wrapup;

                   if(end_pts) BSdealloc((char *)end_pts); end_pts = NULL;
                   if(over1) BSdealloc((char *)over1); over1 = NULL;
                   if(over2) BSdealloc((char *)over2); over2 = NULL;

                   if(n_int >=1 )
                   {
                      if(n_int > 1)
                      {
                         subs1 = (IGRint *)BSstackalloc((unsigned)
                                   (n_int * sizeof(IGRint)));
                         if(! subs1)
                         {
                            *rc = BSNOSTKMEMORY;
                            goto wrapup;
                         }
                         status = BStagsort(rc, &n_int, par1, subs1);
                         if(! status) 
                           goto wrapup;
                      
                         tpar = par1[subs1[0]];
                      } 
                      else
                      {
                         /** n_int = 0 **/
                   
                         tpar = par1[0];
                      }
                      if(int_pts) BSdealloc((char *)int_pts); int_pts = NULL;
                      if(par1) BSdealloc((char *)par1); par1 = NULL;
                      if(par2) BSdealloc((char *)par2); par2 = NULL;
                   }
                   else
                   {
                      /** no intersection points **/
  
                      tpar = off1->knots[off1->order -1];
                   }

                   midpar = (rr + off1->knots[off1->order -1]) / 2;

                   if(midpar > tpar)
                   {
                      ffpar = midpar;
                   }
                   else
                   {
                      ffpar = tpar;
                   }


                  /**-----------------------------------------------
                     Modified on 1/12/88:
                     Make a rational curve to replace the line and arc
                     as the connection between two offset curves.
                  ----------------------------------------------------**/

                  BSalloccv(BSORDERCONICGEN, BSPOLESMXCONICGEN,
                    TRUE, 0, arc, rc);
                  if(BSERROR(*rc)) 
                    goto wrapup;
                
                  BScveval(off1,ffpar, 1, eval,rc);
                  if (BSERROR(*rc)) 
                     goto wrapup;

                  for(j=0; j < 2; j++)
                  {
                     end_pt[j] = eval[0][j];
                     tan_pt[j] = end_pt[j] + eval[1][j];
                  }
                  end_pt[2] = 0.0;
                  tan_pt[2] = 0.0;

                  status = BSxln(rc, end_pt, tan_pt, b, b1, x_pnt);
                  if(! status) 
                    goto wrapup;

                  /* Set z-values of b and p back to original values and
                     set z-values of end_pt and x_pnt to original z-value
                     of p. (07/24/89) */
                  b[2] = t_b;
                  p[2] = t_p;
                  end_pt[2] = p[2];
                  x_pnt[2] = p[2];

                  BStransconc(end_pt, x_pnt, b, p, *arc, rc);
                  if(BSERROR(*rc)) 
                    goto wrapup;               

                  *arc_type = BSCVGENCONC;  /* general conic */

                  /** trim off1 **/

                  BSalloccv(off1->order, off1->num_poles, off1->rational,
                      0, &act1_cur, rc);
                  if(BSERROR(*rc)) 
                    goto wrapup;

                  status = BSactivsplt(rc, off1, &off1->knots[off1->order -1],
                            &ffpar, act1_cur, &tst_plan);
                  if(! status) 
                    goto wrapup;

                  status = BScv_copy(rc, act1_cur, off1);
                  if(! status) 
                    goto wrapup;

                }
                else
                {
                   /**-----------------------------------
                      extending case: trim off1 and extend off2
                   ---------------------------------------**/

                   /* Set z-value of x_pnt = original z-value of p.
                      (07/24/89) */
                   x_pnt[2] = t_p;

                   if(off2->order == 2 && !off2_3d)
                   {
                      if(off2->rational)
                      {
                         for(j=0; j < 3; j++)
                         {
                            off2->poles[j] = x_pnt[j] * off1->weights[0];
                         }
                      }
                      else
                      {
                         for(j=0; j < 3; j++)
                         {
                            off2->poles[j] = x_pnt[j];
                         }
                      }                    
                   }
                   else
                   {
                      BSalloccv(line2->order, line2->num_poles,
                                line2->rational, 0, arc, rc);
                      if(BSERROR(*rc)) 
                        goto wrapup;

                      status = BSactivsplt(rc, line2, 
                                  &line2->knots[line2->order -1], &ss, *arc,
                                  &tst_plan);
                      if(! status) 
                        goto wrapup;
                      /* we need to set the z values back for our line */
                      /* S.G. Catron 06/05/00 */
                      (*arc)->poles[2] = x_pnt[2];
                      (*arc)->poles[5] = t_b;
                      *arc_type = BSCVLINE;  /* a line */
                   }
 
                   BSalloccv(off1->order, off1->num_poles, off1->rational,
                       0, &act1_cur, rc);
                   if(BSERROR(*rc)) 
                     goto wrapup;

                   status = BSactivsplt(rc, off1, &off1->knots[off1->order -1],
                            &rr, act1_cur, &tst_plan);
                   if(! status) 
                     goto wrapup;
 
                   status = BScv_copy(rc, act1_cur, off1);
                   if(! status) 
                     goto wrapup;
                }
             }
             else
             {
                /** Find intersection between infinite lines "line1"
                    and "line2" **/

                if( collin  && (d1 > zero_tol) && (d2 > zero_tol))
                {
                   collinBSofk3arc(a,p,b,d,normal,right_side,cv1,cv2,off1,off2,
                       fillet,nlder,nrder,off1_3d,off2_3d,arc_type,arc,rc);

                   goto wrapup;
                }
                for(j=0; j < 3; j++)
                {
                    a1[j] = a[j] + lder[j];
                    b1[j] = b[j] - rder[j];
                }
                /* Note: a1[2] and b1[2] will = 0.0. (07/24/89) */

                status = BSxln(rc,a,a1,b,b1, x_pnt);
                if(! status) 
                  goto wrapup;

                /* Set z-values of a, b and p back to original values, and
                   set z-value of x_pnt = original z-value of p.(07/24/89) */
                a[2] = t_a;
                b[2] = t_b;
                p[2] = t_p;
                x_pnt[2] = t_p;

                if(fillet)
                {
                    BSalloccv(BSORDERCONICGEN, BSPOLESMXCONICGEN,
                       TRUE, 0, arc, rc);
                    if(BSERROR(*rc)) 
                      goto wrapup;

                    BStransconc(a, x_pnt, b, p, *arc, rc);
                    if(BSERROR(*rc)) 
                      goto wrapup;

                    *arc_type = BSCVGENCONC;  /* general conic */
                }
                else
                {
                   /** extending case **/
                   (void)BSmkvec(rc, m_vec, a, x_pnt);
                   if(BSERROR(*rc)) 
                      goto wrapup;
                   (void)BSmkvec(rc, b_vec, x_pnt, b );
                   if(BSERROR(*rc)) 
                      goto wrapup;
                   /*  check if direction of intersection point is going in the
                       opposite direction as tangent at the end/beginning, which
                       would mean we don't want to just move the poles or even use
                       the intersection point...just create line between end and start */
                   if( BSdotp(rc, m_vec, lder) < 0 || BSdotp(rc, b_vec, rder ) < 0 )
                   {
                      /* just create line between a and b */

                      BSalloccv(2, 2, FALSE, 0, arc, rc);
                      if(BSERROR(*rc)) 
                         goto wrapup;

                      (*arc)->order = 2;
                      (*arc)->non_uniform = FALSE;
                      (*arc)->rational = FALSE;
                      (*arc)->periodic = FALSE;
                      (*arc)->num_poles = 2;
                      (*arc)->num_knots = 4;
                      (*arc)->weights = NULL;
                      (*arc)->planar = FALSE;
                      (*arc)->phy_closed = FALSE;
                      for(k=0; k < 3; k++)
                      {
                         (*arc)->poles[k] = a[k];
                         (*arc)->poles[3 + k] = b[k];
                      }
                      (*arc)->knots[0] = 0.0;
                      (*arc)->knots[1] = 0.0;
                      (*arc)->knots[2] = 1.0;
                      (*arc)->knots[3] = 1.0;
                      *arc_type = BSCVLINE;
                      goto wrapup;                                         
                   }
                   if(off1->order == 2 && !off1_3d)
                   {
                      if(off1->rational)
                      {
                         for(j=0; j < 3; j++)
                         {
                            off1->poles[3 * (off1->num_poles -1) +j]
                            = x_pnt[j] * off1->weights[off1->num_poles -1];
                         }
                      }
                      else
                      {
                         for(j=0; j < 3; j++)
                         {
                            off1->poles[3 * (off1->num_poles -1) +j]
                            = x_pnt[j];
                         }
                      }                    

                      if(off2->order == 2 && !off2_3d)
                      {
                         if(off2->rational)
                         {
                            for(j=0; j < 3; j++)
                            {
                               off2->poles[j] = x_pnt[j] * off2->weights[0];
                            }
                         }
                         else
                         {
                            for(j=0; j < 3; j++)
                            {
                               off2->poles[j] = x_pnt[j];
                            }
                         }                    
                      }
                      else
                      {
                          /** off1 is order 2 and off2 is not order 2 or not
                              2d. Make a line from x_pnt to 1st pole of off2**/

                          BSalloccv(2, 2, FALSE, 0, arc, rc);
                          if(BSERROR(*rc)) 
                            goto wrapup;

                          (*arc)->order = 2;
                          (*arc)->non_uniform = FALSE;
                          (*arc)->rational = FALSE;
                          (*arc)->periodic = FALSE;
                          (*arc)->num_poles = 2;
                          (*arc)->num_knots = 4;
                          (*arc)->weights = NULL;
                          (*arc)->planar = FALSE;
                          (*arc)->phy_closed = FALSE;
                          for(k=0; k < 3; k++)
                          {
                             (*arc)->poles[k] = x_pnt[k];
                             (*arc)->poles[3 + k] = b[k];
                          }
                          (*arc)->knots[0] = 0.0;
                          (*arc)->knots[1] = 0.0;
                          (*arc)->knots[2] = 1.0;
                          (*arc)->knots[3] = 1.0;

                          *arc_type = BSCVLINE;  /* a line */
                       }
                    }
                    else
                    {
                       /** off1 is not order 2 **/

                       if(off2->order == 2 && !off2_3d)
                       {
                          BSalloccv(2, 2, FALSE, 0, arc, rc);
                          if(BSERROR(*rc)) 
                            goto wrapup;

                          (*arc)->order = 2;
                          (*arc)->non_uniform = FALSE;
                          (*arc)->rational = FALSE;
                          (*arc)->periodic = FALSE;
                          (*arc)->num_poles = 2;
                          (*arc)->num_knots = 4;
                          (*arc)->weights = NULL;
                          (*arc)->planar = FALSE;
                          (*arc)->phy_closed = FALSE;
                          for(k=0; k < 3; k++)
                          {
                             (*arc)->poles[k] = a[k];
                             (*arc)->poles[3 + k] = x_pnt[k];
                          }
                          (*arc)->knots[0] = 0.0;
                          (*arc)->knots[1] = 0.0;
                          (*arc)->knots[2] = 1.0;
                          (*arc)->knots[3] = 1.0;

                          *arc_type = BSCVLINE; /* a line */

                          if(off2->rational)
                          {
                             for(j=0; j < 3; j++)
                             {
                                off2->poles[j] = x_pnt[j] * off2->weights[0];
                             }
                          }
                          else
                          {
                             for(j=0; j < 3; j++)
                             {
                                off2->poles[j] = x_pnt[j];
                             }
                          }                    
                       }
                       else
                       {
                          /** Both off1 and off2 are not order 2 or not 2d **/ 
                          BSalloccv(2, 3, FALSE, 0, arc, rc);
                          if(BSERROR(*rc)) 
                            goto wrapup;

                          (*arc)->order = 2;
                          (*arc)->non_uniform = FALSE;
                          (*arc)->rational = FALSE;
                          (*arc)->periodic = FALSE;
                          (*arc)->num_poles = 3;
                          (*arc)->num_knots = 5;
                          (*arc)->weights = NULL;
                          (*arc)->planar = TRUE;
                          (*arc)->phy_closed = FALSE;
                          for(k=0; k < 3; k++)
                          {
                             (*arc)->poles[k] = a[k];
                             (*arc)->poles[3 + k] = x_pnt[k];
                             (*arc)->poles[6 + k] = b[k];
                          }
                          (*arc)->knots[0] = 0.0;
                          (*arc)->knots[1] = 0.0;
                          (*arc)->knots[2] = 0.5;
                          (*arc)->knots[3] = 1.0;
                          (*arc)->knots[4] = 1.0;

                          *arc_type = BSCVLINESTR;  /* a line string */

                       }
                    }
                }
             }
          } /* end of if(status) */
    }

    wrapup:
      if(subs)
      {
        BSstackdealloc((char *)subs);
        subs = NULL;
      }
      if(subs1) 
      {
        BSstackdealloc((char *)subs1);
        subs1 = NULL;
      }

      if(act1_cur)
      {
         BSfreecv(&rc3, act1_cur);
         act1_cur = NULL;
      }
      if(act2_cur)
      {
         BSfreecv(&rc4, act2_cur);
         act2_cur = NULL;
      }
      if(fil_arc)
      {
         BSfreecv(&rc5, fil_arc);
         fil_arc = NULL;
      }
      if(sub_cv)
      {
         BSfreecv(&rc6, sub_cv);
         sub_cv = NULL;
      }
      if(sub_line)
      {
         BSfreecv(&rc7, sub_line);
         sub_line = NULL;
      }
      if(circle)
      {
         BSfreecv(&rc8, circle);
         circle = NULL;
      }
      if (off2_temp)
      {
         BSfreecv(&rc9, off2_temp);
         off2_temp = NULL;
      }
      if (off1_temp)
      {
         BSfreecv(&rc10, off1_temp);
         off1_temp = NULL;
      }

     if (tmp2.knots && alloc_tmp2_knots)
         BSstackdealloc((char *) tmp2.knots);
 
     if (tmp2.weights && alloc_tmp2_weights)
         BSstackdealloc((char *) tmp2.weights);

      if (tmp2.poles && alloc_tmp2_poles)
         BSstackdealloc((char *) tmp2.poles);

      if (tmp1.knots && alloc_tmp1_knots)
         BSstackdealloc((char *) tmp1.knots);

      if (tmp1.weights && alloc_tmp1_weights)
         BSstackdealloc((char *) tmp1.weights);

      if (tmp1.poles && alloc_tmp1_poles)
         BSstackdealloc((char *) tmp1.poles);

      if(BSOKAY(*rc) && ( BSERROR(rc3)
         || BSERROR(rc4) || BSERROR(rc5) || BSERROR(rc6) || BSERROR(rc7)
           || BSERROR(rc8) || BSERROR(rc9) || BSERROR(rc10)) )
      {
         *rc = BSFAIL;
      }

      if(BSERROR(*rc))
          BSdbgrc(*rc,"BSofk3arc");
      return;
}
