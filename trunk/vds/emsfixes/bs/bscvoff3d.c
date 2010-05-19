/* $Id: bscvoff3d.c,v 1.1.1.1 2001/01/04 21:07:27 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        emsfixes/bs/bscvoff3d.c
 *
 * Description:
 *
 * Dependencies: 
 *
 * Revision History:
 *      $Log: bscvoff3d.c,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:27  cvs
 *      Initial import to CVS
 *
 * Revision 1.1  1998/06/24  14:51:46  pinnacle
 * tr179801103
 *
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 06/24/98  ah      TR179801103 Offset curve, code modified by bspmath group
 ***************************************************************************/
/*
Copyright (C) 1996, 1997, Intergraph Corporation. All rights reserved.

Name
      BScvoff3d

Abstract
      This routine offsets a 2-D or 3-D curve by a given direction point
      or a view normal.

Synopsis
      void BScvoff3d(cv, d, code1, code2, two_d, dir_pt, normal, dir_known, 
           right_side, tmat, off_cv, num_loops, loops, rc)
      struct IGRbsp_curve  *cv
      IGRdouble            d
      IGRboolean           code1
      IGRshort             code2
      IGRboolean           two_d
      IGRpoint             dir_pt
      IGRboolean           dir_known
      IGRvector            normal
      IGRint               *right_side
      IGRdouble            tmat[3][3]
      struct IGRbsp_curve  **off_cv
      IGRint               *num_loops
      struct IGRbsp_curve  ***loops
      BSrc                 *rc

Description
      Input:
         cv - a B-spline curve(2-D or 3-D)
         d  - offset distance

         code1 - FALSE, if extending
                 TRUE, if filleting

         code2 - 0, if no removing loop
                 1, if removing loop and return the array of loops
                 2, if removing loop and don't return the array of loops

         two_d - TRUE, 2-D curve
                 FALSE, 3-D curve

         dir_pt - direction point for offsetting

         normal - if 2-D, normal to planar curve
                  if 3-D, view normal

         dir_known - TRUE, if normal,right_side and tmat are known
                     FALSE, dir_pt should be given.      

         right_side - 1, if T x normal = offset direction.( T is tangent
                         of a point on cv)
                      -1, if T x normal = opposite to offset direction.
         tmat - transformation matrix

     Output:
         off_cv - the offset curve
         num_loops - number of loops
         loops - array of loop curves
         normal - normal vector(described in input)
         right_side - as described in input
         tmat - as described in input

Return Values
     If successful, rc = BSSUCC; else, rc returns an error message.     

Notes
   1. For input, caller needs to assign proper values for cv,d,code1,code2,
      and two_d every time.
      As for dir_known; if TRUE, normal,right_side and tmat should be assigned.
                        if FALSE, dir_pt needs to be assigned.

      If two_d = FALSE, dir_known MUST be TRUE and above mentioned variables
      must be supplied.

   2. If the caller wants to use this routine in a loop for continuous
      offsetting, he can input the dir_pt for the first call and use the
      output variables normal,right_side,and tmat for the inputs of the
      rest of the calls.

   3. If cv is closed and offset distance = 0.0 (< dist_tol), it is the
      user's responsibility to make sure that the start parameter of cv
      is on a part of the curve that is NOT to be removed when removing
      loops.

Index
    md

Keywords

History
    Y. S. Sheng  10/27/87 : Creation date.
    Vivian W.Ye  05/12/88 : If two_d = FALSE, set rc = BSINARG.
    Vivian W.Ye  05/24/88 : Add one option to code2 and replace BSofrmlp
                            by BSofrmlp3.
    Vivian W.Ye  06/15/88 : Replace BSofrmlp2 by BSofrmlp3.
    Vivian W.Ye  07/18/88 : Set in_cv=NULL after assigning in_cv to curve.
    D. Breden    10/03/88 : Call BStst_plan to check planarity of output
                            curve.
    S.G. Catron  02/15/89 : After wrapup, the rc was getting
                            modified.  So, now we stay with the
                            error already found.
    S. C. Wood   07/19/89 : Return error if two_d = FALSE and 
                            dir_known = FALSE.  Cannot calculate a curve
                            normal for 3-D curve.
    S. C. Wood   10/10/89 : Corrected header.
    S. C. Wood   10/16/89 : Added code to shuffle cv if cv is closed and
                            the start parameter is not associated with section
                            of curve that is NOT to be removed.
    S. C. Wood   10/27/89 : Check the start parameter and make sure it is on
                            part of curve that is NOT to be removed when 
                            removing loops ONLY if offset distance (d) > 
                            dist_tol.  See Note #3.
                            Changed dimension of following static arrays:
                            over_pts, over0, over1 from 10 to 20 elements.
    S. C. Wood   01/24/89 : Only remove loops from offset curve (tmp_off_cv)
                            if code2 indicates this AND tmp_off_cv is not a
                            degenerate curve.
    S. C. Wood   02/19/90 : Fixed error in computing mid parameter (par)
                            for call to BSclcvshffl.
    S. C. Wood   06/05/91 : Changed variable dir from IGRint to IGRboolean.
    S. C. Wood   01/14/92 : When determining if curve needs to be shuffled
                            before loop removal, if BScvcvint returns nint = 1,
                            provide memory for tmp_off_cv2 and copy tmp_off_cv
                            into tmp_off_cv2.   If BScvcvint returns 2 inter-
                            section points but these points are within
                            dist_tol of each other, do not shuffle.
    S. C. Wood   05/25/95 : When determining if curve should be shuffled,
                            if BScvcvint returns > 2 unique intersection
                            points, set shuffle = FALSE. Added code for
                            case of n_int = 3 to check if 2 intersection
                            points were at the start and end parameter 
                            (i.e. same point). If so, set shuffle = TRUE.
                            Also, make preliminary check of tangent vector
                            of input curve and offset curve. If the tangents
                            are in opposite directions, set shuffle = TRUE
                            and do not perform line / offset curve inter-
                            section.
                            Fix for TR# 9525705.
    Vivian Y.Hsu 06/05/98  : If rc = BSWARN returned from BSxycvoff,
                             go on to the end, then return it.
*/

#include "bsdefs.h"
#include "bserr.h"
#include "bsmalloc.h"
#include "bsstackalloc.h"
#define BSVOID
#include "bsparameters.h"

#define MAXSIZE 100

void BScvoff3d(
struct IGRbsp_curve  *cv,
IGRdouble            d,
IGRboolean           code1,
IGRshort             code2,
IGRboolean           two_d,
IGRpoint             dir_pt,
IGRvector            normal,
IGRboolean           dir_known,
IGRint               *right_side,
IGRdouble            tmat[3][3],
struct IGRbsp_curve  **off_cv,
IGRint               *num_loops,
struct IGRbsp_curve  ***loops,
BSrc                 *rc)
{
#include "bsdbgrc.h"
#include "bsalloccv.h"
#include "bsfndoffdir.h"
#include "bsofchkln.h"
#include "bsxycvoff.h"
#include "bsofnorm.h"
#include "bsofrmlp3.h"
#include "bstst_plan.h"
#include "bscv_copy.h"
#include "bscvoton.h"
#include "bscvntoo.h"
#include "bscnvtomkt.h"
#include "bsfreecv.h"
#include "bscveval.h"
#include "bslngen.h"
#include "bscvcvint.h"
#include "bscv_slfint.h"
#include "bsclcvshffl.h"
#include "bscvkttol2.h"
#include "bstagsort.h"
#include "bststcvdegn.h"
#include "bsdistptpt.h"
#include "bsdotp.h"
#include "bsnorvec.h"
	
     IGRboolean status;
     struct IGRbsp_curve *curve = NULL, *new_cv = NULL,
                         *in_cv = NULL, *offxy_cv = NULL,
                         *tmp_off_cv = NULL, *tmp_off_cv2 = NULL;
     IGRboolean right,line;
     IGRpoint   pzero;
     IGRvector  in_norm, new_norm;
     IGRdouble  scale;
     IGRint     i, j;
     IGRpoint   eval_cv[2], eval_off[2];
     IGRdouble  eval_dotp;
     struct
       IGRbsp_curve *con_line = NULL;
     IGRint     num_alloc_int, num_alloc_over, n_int, nover;
     IGRpoint   int_pts[10], *xint_pts = NULL;
     IGRpoint   over_pts[20], *xover_pts = NULL;
     IGRdouble  par0[10], par1[10], *xpar0 = NULL, *xpar1 = NULL;
     IGRdouble  over0[20], over1[20], *xover0 = NULL, *xover1 = NULL;
     IGRboolean out_pt_alloc, out_over_alloc;
     IGRdouble  par;
     IGRint     num_deriv, type;
     IGRboolean shuffle = FALSE;
     IGRdouble  *a_par = NULL, *b_par = NULL;
     IGRdouble  *c_over = NULL, *d_over = NULL, *e_over = NULL, *f_over = NULL;
     IGRlong    npoles;
     IGRint     num_values, *ind = NULL, ind2[MAXSIZE];
     IGRdouble  *tmp_pars = NULL, tmp_pars2[MAXSIZE];
     IGRboolean alloc_tmp_pars = FALSE, alloc_ind = FALSE;
     IGRdouble  dist_tol, int_ptdist;
     IGRboolean degen, dir;
     BSrc       rc1,rco;

     status = TRUE;
     *rc = BSSUCC;
     rc1 = BSSUCC;
     rco = BSSUCC;

     *num_loops = 0;

     /** Convert cv to multiple end knots **/

     BSalloccv(cv->order, cv->num_poles, cv->rational, 0, &in_cv, rc);
     if(BSERROR(*rc)) 
       goto wrapup;

     status = BScv_copy(rc,cv,in_cv);
     if(! status) 
       goto wrapup;

     status = BScnvtomkt(rc, in_cv);
     if(! status) 
       goto wrapup;

     /**------------------------------------------------------
       Check for legal inputs and find normal if necessary
     ---------------------------------------------------------**/

     BSofchkln(in_cv, &line, rc);
     if(BSERROR(*rc)) 
       goto wrapup;

     if( two_d )
     {
        if(! in_cv->planar  &&  !line)
        {
           *rc = BSINARG;
           goto wrapup;
        }
        else
        {
           if( ! dir_known )
           {                
              /****************************
                 find the unit normal of a plane where cv is on
              *****************************/

              BSofnorm(in_cv,  dir_pt, dir_known, in_norm, &right, &curve, 
                     normal, rc);
              if(BSERROR(*rc)) 
                goto wrapup;
           }
           else
           {
              curve = in_cv;
              in_cv = NULL;
           }
        }
     }
     else
     {
        if (! dir_known)
        {
           *rc = BSINARG;  /* cannot calculate normal given dir_pt */
           goto wrapup;
        }
        curve = in_cv;
        in_cv = NULL;
     }

     /**------------------------------------------------
       Find offset direction and transformation matrix
     --------------------------------------------------**/

     if(! dir_known)
     {
        BSfndoffdir(curve, dir_pt, normal, right_side, tmat, rc);
        if(BSERROR(*rc)) 
          goto wrapup;
     }

     /**----------------------------------------------
        Transform curve from old to new coordinates    
     -----------------------------------------------**/

     for(i=0; i < 3; i++)
     {
        pzero[i] = 0.0;
     }
     scale = 1.0;

     BSalloccv(curve->order, curve->num_poles, curve->rational,
            0, &new_cv, rc);
     if(BSERROR(*rc)) 
       goto wrapup;

     status = BScvoton(rc, pzero, tmat, &scale, curve, new_cv);
     if(! status) 
       goto wrapup;

     /**----------------------------------------------
       Offset the new_cv with x and y coordinates only
     --------------------------------------------------**/

     new_norm[0] = 0.0;   /** transformed normal **/
     new_norm[1] = 0.0;
     new_norm[2] = 1.0;

     BSxycvoff(new_cv, d, code1, new_norm, *right_side, &offxy_cv, rc);
     if (*rc == BSWARN)
     {
       /* rc = BSWARN means that we have a solution with question.
          The offset curve is not within the tolerance.
          V.Hsu 6/5/98 */
                  
       rco = *rc;
       *rc = BSSUCC;
     }

     if(BSERROR(*rc)) 
       goto wrapup;

     /**------------------------------------------------------------
       Transform back the tmp_off_cv to original coordinate sysytem     
       and assign the z-coordinate back to the polygons of off_cv.
     --------------------------------------------------------------**/

     BSalloccv(offxy_cv->order, offxy_cv->num_poles, 
          offxy_cv->rational, 0, &tmp_off_cv, rc);
     if(BSERROR(*rc)) 
       goto wrapup;

     status = BScvntoo(rc, pzero, tmat, &scale, offxy_cv, tmp_off_cv);
     if(! status) 
       goto wrapup;

     /**----------------------------------------------
       Removing loops from tmp_off_cv 
     ----------------------------------------------**/

     BSEXTRACTPAR(rc, BSTOLLENVEC, dist_tol);

     BStstcvdegn(tmp_off_cv, &degen, rc);
     if (BSERROR(*rc))
        goto wrapup;

     if((code2 == 1 || code2 == 2) && !degen)
     {
        if (curve->phy_closed)
        {
           /* If curve is closed, determine if start parameter is on part
              of tmp_off_cv that you want to keep when removing loops.  If
              it is not, shuffle the curve. */

           if (d > dist_tol)
           {
              /* Only if offset distance is > dist_tol do we check the start
                 parameter and make sure it is on part of curve that is NOT to
                 be removed when removing loops */
	
              num_deriv = 1;
              par = curve->knots[curve->order - 1];
              BScveval(curve, par, num_deriv, eval_cv, rc);
              if (BSERROR(*rc))
                 goto wrapup;

              par = tmp_off_cv->knots[tmp_off_cv->order - 1];    
              BScveval(tmp_off_cv, par, num_deriv, eval_off, rc);
              if (BSERROR(*rc))
                 goto wrapup;
              
              (void)BSnorvec(rc, eval_cv[1]);
              if (BSERROR(*rc))
                 goto wrapup;

              (void)BSnorvec(rc, eval_off[1]);
              if (BSERROR(*rc))
                 goto wrapup;

              /* If tangent vectors at start point of offset curve
                 and input curve are in opposite direction, set 
                 shuffle = TRUE and bypass line / offset curve intersection. */
              eval_dotp = BSdotp(rc, eval_off[1], eval_cv[1]);
              if (eval_dotp < 0.0)
              {
                 shuffle = TRUE;
              }
              else
              {
                 BSalloccv(2, 2, FALSE, 0, &con_line, rc);
                 if (BSERROR(*rc))
                    goto wrapup;

                 /* Generate a line connecting points on curve and tmp_off_cv
                    associated with the start parameter */
                 status = BSlngen(rc, eval_cv[0], eval_off[0], con_line, &type);
                 if (BSERROR(*rc))
                   goto wrapup;

                 num_alloc_int = 10;
                 num_alloc_over = 10;
 
                 /* If the constructed line intersects tmp_off_cv more than once
                    and these intersections are not the start and end points of 
                    tmp_off_cv, shuffle the curve */
                 BScvcvint(con_line, tmp_off_cv, FALSE, num_alloc_int, 
                           num_alloc_over, int_pts, par0, par1, over_pts, over0,
                           over1, &n_int, &nover, &out_pt_alloc, &out_over_alloc,
                           &xint_pts, &xpar0, &xpar1, &xover_pts, &xover0,
                           &xover1, rc);
                 if (BSERROR(*rc))
                    goto wrapup;

                 if (n_int <= 1)
                 {
                    shuffle = FALSE;
                 }
                 else
                 {
                    if (n_int == 2)
                    {
                       if (! out_pt_alloc)
                       {
                          int_ptdist = BSdistptpt(rc, int_pts[0], int_pts[1]);
                          if (BSERROR(*rc))
                             goto wrapup;

                          if (int_ptdist > dist_tol)
                          {
                             /* If tmp_off_cv is closed, and par = start
                                parameter of tmp_off_cv, BScvcvint will return 2
                                intersection points for constructed line and 
                                off_cv -- the start AND end point of tmp_off_cv.*/
                             if (par1[0] == tmp_off_cv->knots[tmp_off_cv->order-1]
                                 && par1[n_int-1] == 
                                     tmp_off_cv->knots[tmp_off_cv->num_poles])
                             {
                                 shuffle = FALSE;
                             }
                             else
                             {
                                shuffle = TRUE;
                             }
                          }
                          else
                          {
                             /* int_pts are within tolerance--do not shuffle*/
                             shuffle = FALSE;
                          }
                       }
                       else
                       {
                          int_ptdist = BSdistptpt(rc, xint_pts[0], xint_pts[1]);
                          if (BSERROR(*rc))
                             goto wrapup;

                          if (int_ptdist > dist_tol)
                          {
                             if (xpar1[0] == tmp_off_cv->knots
                                               [tmp_off_cv->order - 1]
                                 && xpar1[n_int-1] == 
                                       tmp_off_cv->knots[tmp_off_cv->num_poles])
                             {
                                 shuffle = FALSE;
                             }
                             else
                             {
                                shuffle = TRUE;
                             }
                          }
                          else
                          {
                             /* xint_pts are within tolerance--do not shuffle*/
                             shuffle = FALSE;
                          }
                       }
                    }
                    else
                    {
                       /* n_int > 2 */
                       /* If n_int == 3 and 2 of the intersections are
	   	          the start and end (par = 0.0 and 1.0) point
                          of the offset curve, set shuffle = TRUE.
                          Otherwise, set shuffle = FALSE. */
                       if (n_int == 3)
                       {
                          if (! out_pt_alloc)
                          {
                             int_ptdist = BSdistptpt(rc, int_pts[1], int_pts[2]);
                             if (BSERROR(*rc))
                                goto wrapup;

                             if (int_ptdist > dist_tol)
                             {
                                if (par1[1] == tmp_off_cv->knots[tmp_off_cv->order-1]
                                    && par1[2] == 
                                     tmp_off_cv->knots[tmp_off_cv->num_poles])
                                {
                                    shuffle = FALSE;
                                }
                                else
                                {
                                   shuffle = TRUE;
                                }
                             }
                             else
                             {
                                /* int_pts are within tolerance--do not shuffle*/
                                shuffle = TRUE;
                             }
                          }
                          else
                          {
                             int_ptdist = BSdistptpt(rc, xint_pts[1], xint_pts[2]);
                             if (BSERROR(*rc))
                                goto wrapup;

                             if (int_ptdist > dist_tol)
                             { 
                                if (xpar1[1] == tmp_off_cv->knots
                                               [tmp_off_cv->order - 1]
                                    && xpar1[2] == 
                                       tmp_off_cv->knots[tmp_off_cv->num_poles])
                                {
                                    shuffle = FALSE;
                                }
                                else
                                {
                                   shuffle = TRUE;
                                }
                             }
                             else
                             {
                                /* xint_pts are within tolerance--do not shuffle*/
                                shuffle = TRUE;
                             }
                          }
                       }
                       else
                       {
                          /* n_int > 3 */
                          shuffle = FALSE;
                       }
                    }
                 }   /* end if (n_int <= 1) */
              }   /* end if (eval_dotp < 0.0) */

              if (shuffle)
              {
                 /* INCLUDE CODE TO SHUFFLE CURVE !!!!! */
                 status = BScv_slfint(rc, tmp_off_cv, &n_int, &a_par, &b_par,
                            &nover, &c_over, &d_over, &e_over, &f_over);
                 if (BSERROR(*rc))
                    goto wrapup;

                 if ((n_int * 2) > MAXSIZE)
                 {
                    tmp_pars = (IGRdouble *)BSstackalloc((unsigned)
                                   (n_int * 2) * sizeof(IGRdouble));
                    if (! tmp_pars)
                    {
                       *rc = BSNOSTKMEMORY;
                       goto wrapup;
                    }
                    alloc_tmp_pars = TRUE;

                    ind = (IGRint *)BSstackalloc((unsigned)(n_int*2) * 
                              sizeof(IGRint));
                    if (! ind)
                    {
                       *rc = BSNOSTKMEMORY;
                       goto wrapup;
                    }
                    alloc_ind = TRUE;
                 }
                 else
                 {
                    tmp_pars = tmp_pars2;
                    ind = ind2;
                 }

                 i = 0;
                 j = 0;
                 while (i < (n_int * 2))
                 {
                     tmp_pars[i] = a_par[j];
                     tmp_pars[i + 1] = b_par[j];
                     j = j + 1;
                     i = i + 2;
                 }
                 num_values = n_int * 2;
                 status = BStagsort(rc, &num_values, tmp_pars, ind);
                 if (BSERROR(*rc))
                    goto wrapup;

                 par = (tmp_pars[ind[0]] + tmp_pars[ind[1]]) / 2.0;
                 dir = 1;
                 npoles = tmp_off_cv->num_poles * 2 - 1;
                 BSalloccv(tmp_off_cv->order, npoles, tmp_off_cv->rational,
                           0, &tmp_off_cv2, rc);
                 if(BSERROR(*rc))
                   goto wrapup;

                 status = BSclcvshffl(rc,tmp_off_cv,&par,&dir,tmp_off_cv2);
                 if (BSERROR(*rc))
                    goto wrapup;
              }
              else
              {
                  BSalloccv(tmp_off_cv->order, tmp_off_cv->num_poles, 
                            tmp_off_cv->rational, 0, &tmp_off_cv2, rc);
                  if(BSERROR(*rc))
                    goto wrapup;
	
                  status = BScv_copy(rc, tmp_off_cv, tmp_off_cv2);
                  if(! status) 
                     goto wrapup;
              }   /* end if (shuffle) */
           }
           else
           {
             BSalloccv(tmp_off_cv->order, tmp_off_cv->num_poles, 
                        tmp_off_cv->rational, 0, &tmp_off_cv2, rc);
              if(BSERROR(*rc))
                goto wrapup;

              status = BScv_copy(rc, tmp_off_cv, tmp_off_cv2);
              if(! status) 
                 goto wrapup;
	
           }   /* end if (d > dist_tol) */
        }
        else
        {
           BSalloccv(tmp_off_cv->order, tmp_off_cv->num_poles, 
                     tmp_off_cv->rational, 0, &tmp_off_cv2, rc);
           if(BSERROR(*rc))
             goto wrapup;

           status = BScv_copy(rc, tmp_off_cv, tmp_off_cv2);
           if(! status) 
             goto wrapup;
        }   /* end if (curve->phy_closed) */

        BSofrmlp3(tmp_off_cv2, code2, num_loops, loops, off_cv, rc);
        if(BSERROR(*rc)) 
           goto wrapup; 
     }  
     else
     {
        /* If not removing loops or offset curve is degenerate... */
        BSalloccv(tmp_off_cv->order, tmp_off_cv->num_poles, 
                  tmp_off_cv->rational, 0, off_cv, rc);
        if(BSERROR(*rc))
           goto wrapup;
	
        status = BScv_copy(rc, tmp_off_cv, *off_cv);
        if(! status) 
          goto wrapup;

        *num_loops = 0;
     }   /* end if ((code2 == 1 || code2 == 2) && !degen) */
 

     if ( (*off_cv)->num_poles == 2 )
     {
        (*off_cv)->planar = FALSE;
     }
     else
     {
        BStst_plan( (*off_cv)->num_poles, (*off_cv)->poles,
                    (*off_cv)->weights, &(*off_cv)->planar, new_norm,rc);
     }

     wrapup:
       if (alloc_tmp_pars)
       {
          BSstackdealloc((char *) tmp_pars);
          tmp_pars = NULL;
       }
       if (alloc_ind)
       {
          BSstackdealloc((char *) ind);
          ind = NULL;
       }
       if (a_par)
       {
          BSdealloc((char *) a_par);
          a_par = NULL;
       }
       if (b_par)
       {
          BSdealloc((char *) b_par);
          b_par = NULL;
       }
       if (c_over)
       {
          BSdealloc((char *) c_over);
          c_over = NULL;
       }
       if (d_over)
       {
          BSdealloc((char *) d_over);
          d_over = NULL;
       }
       if (e_over)
       {
          BSdealloc((char *) e_over);
          e_over = NULL;
       }
       if (f_over)
       {
          BSdealloc((char *) f_over);
          f_over = NULL;
       }
       if (xover1)
       {
          BSdealloc((char *) xover1);
          xover1 = NULL;
       }
       if (xover0)
       {
          BSdealloc((char *) xover0);
          xover0 = NULL;
       }
       if (xover_pts)
       {
          BSdealloc((char *) xover_pts);
          xover_pts = NULL;
       }
       if (xpar1)
       {
          BSdealloc((char *) xpar1);
          xpar1 = NULL;
       }
       if (xpar0)
       {
          BSdealloc((char *) xpar0);
          xpar0 = NULL;
       }
       if (xint_pts)
       {
          BSdealloc((char *) xint_pts);
          xint_pts = NULL;
       }
       if(con_line)
       {
           status = BSfreecv(&rc1, con_line);
           if (BSOKAY(*rc) && BSERROR(rc1))
             *rc = rc1;
           con_line = NULL;
       }
       if(tmp_off_cv2)
       {
           status = BSfreecv(&rc1, tmp_off_cv2);
           if (BSOKAY(*rc) && BSERROR(rc1))
             *rc = rc1;
           tmp_off_cv2 = NULL;
       }
       if(tmp_off_cv)
       {
           status = BSfreecv(&rc1, tmp_off_cv);
           if (BSOKAY(*rc) && BSERROR(rc1))
             *rc = rc1;
           tmp_off_cv = NULL;
       }
       if(offxy_cv)
       {
           status = BSfreecv(&rc1, offxy_cv);
           if (BSOKAY(*rc) && BSERROR(rc1))
             *rc = rc1;
           offxy_cv = NULL;
       }
       if(new_cv)
       {
           status = BSfreecv(&rc1, new_cv);
           if (BSOKAY(*rc) && BSERROR(rc1))
             *rc = rc1;
           new_cv = NULL;
       }
       if(curve)
       {
           status = BSfreecv(&rc1, curve);
           if (BSOKAY(*rc) && BSERROR(rc1))
             *rc = rc1;
           curve = NULL;
       }
       if(in_cv)
       {
           status = BSfreecv(&rc1, in_cv);
           if (BSOKAY(*rc) && BSERROR(rc1))
             *rc = rc1;
           in_cv = NULL;
       }
       if( BSOKAY(*rc) && BSERROR(rco))
         *rc = rco;

       if(BSERROR(*rc))
           BSdbgrc(*rc,"BScvoff3d");
       return;
}     
