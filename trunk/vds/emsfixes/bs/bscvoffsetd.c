/* $Id: bscvoffsetd.c,v 1.1.1.1 2001/01/04 21:07:27 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        emsfixes/bs/bscvoffsetd.c
 *
 * Description:
 *
 * Dependencies: 
 *
 * Revision History:
 *      $Log: bscvoffsetd.c,v $
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
    BScvoffsetd

Abstract

    This function generates the offset curve to a given curve and
    an option is given for inputting the normal of the planar curve
    (used for computing offset direction) or an offset  direction point.

Synopsis
    void BScvoffsetd(in_cv,d,q_pnt,dir_know,code1,code2,right,
                      in_norm,off_cur,num_cur,array,rc)
    BSrc     *rc
    struct IGRbsp_curve *in_cv
    IGRdouble  d
    IGRpoint   q_pnt
    IGRboolean dir_know
    IGRint     code1
    IGRint     code2
    IGRboolean *right
    IGRdouble  in_norm[3]
    struct IGRbsp_curve **off_cur
    IGRint     *num_cur
    struct IGRbsp_curve ***array

Description

    Input arguments:

       in_cv - data structure of a B-spline curve
       d - offset distance
       q_pnt - direction point for offset

       dir_know - = TRUE, offset direction is known
                  = FALSE, otherwise

       code1 - option number
               = 0, extend to intersection
               = 1,filleting

       code2 - option number
               = 0, do not remove loops
               = 1, remove loops and return the array of loops
               = 2, remove loops and don't return the array of loops

       right -  TRUE, input normal is the same as
                      the one used for calculating offset
                      poles. (see NOTES)
                FALSE, otherwise.      

       in_norm[3] - normal vector for calculating offset poles.
                    if dir_know is TRUE, in_norm is assigned when input.
                    else, normal is not assigned. (see NOTES)      

    Output arguments:

       rc - completion code message
            =BSSUCC, if successful

       right -  TRUE, input normal "in_norm" is the same as
                      the one used for calculating offset
                      poles. (see NOTES)
                FALSE, otherwise.      

       in_norm[3] - normal vector for calculating offset poles.

       off_cur - the offset curve
       num_cur - number of loops created
       array - pointer to an array of pointers to loops

Return Values

       If successful, rc = BSSUCC; else, rc returns an error code.
Notes

          When input:

             if dir_know = TRUE then
                 in_norm is given by the user and "right" is assigned
                 as follows:                 

                 if T x in_norm is the offset direction then
                    the caller should assign right = TRUE. 
                    (T is the tangent vector of a point on curve)
                 else
                    right = FALSE

                 q_pnt is not needed in this case so we can set it
                 to NULL.

             else

                 offset direction point q_pnt should be given
                 in_norm and "right" will be assigned in this routine.
             end

          When output:

             in_norm and "right" should return proper values. 


Index
    md

Keywords

History
        Y. S. Sheng   06/08/87  : Creation date.
        Y. S. Sheng   12/09/87  : Change call from BSsub_cvoff to 
                                  BScvoff3d.
                                  Change to new header.
        Vivian W.Ye   05/23/88  : Add one option to code2.
        Tai-Sheng Jeffrey Liu  07/14/88  : Delete unused variable.
        S.G. Catron   02/15/89  : After wrapup, the rc was getting
                                  modified.  So, now we stay with the
                                  error already found.
        S. C. Wood    10/10/89  : Remove return of error message if
                                  in_curve is non-planar AND not a line.
                                  Call BScvoff3d with two_d indicator equal
                                  FALSE.  Add call to BSofnorm to calculate 
                                  tmp_in_norm and tmp_right if dir_known = 
                                  FALSE and set tmp_dir_known = TRUE.  Also
                                  add call to BSfndoffdir to return tmp_tmat
                                  to be sent to BScvoff3d.
        S. C. Wood    11/06/90  : Set tmp_in_norm = in_norm and tmp_dir_know
                                  = TRUE if dir_know = TRUE for call to
                                  BScvoff3d.
        S. C. Wood    02/05/92  : If offset distance is negative, reverse the
                                  right_side boolean and use the ABS(d) for
                                  offset distance.
    Vivian Y.Hsu 06/05/98  : If rc = BSWARN returned from BScvoff3d,
                             go on to the end, then return it.
*/
#include "bsdefs.h"
#include "bserr.h"

void BScvoffsetd(
struct IGRbsp_curve *in_cv,
IGRdouble           d,
IGRpoint            q_pnt,
IGRboolean          dir_know,
IGRint              code1,
IGRint              code2,
IGRboolean          *right,
IGRdouble           in_norm[3],
struct IGRbsp_curve **off_cur,
IGRint              *num_cur,
struct IGRbsp_curve ***array,
BSrc                *rc )
{
#include "bsofchkln.h"
#include "bscvoff3d.h"
#include "bsalloccv.h"
#include "bstrans2.h"
#include "bsfreecv.h"
#include "bscv_copy.h"
#include "bscnvtomkt.h"
#include "bsofnorm.h"
#include "bsfndoffdir.h"
		
     IGRboolean status = TRUE;
     IGRboolean fillet;
     IGRint     right_side;
     IGRdouble  tmat[3][3];
     struct IGRbsp_curve *in_curve = NULL, *in_curve2 = NULL;
     IGRshort   rm_loop;
     IGRvector  tmp_in_norm;
     IGRboolean tmp_dir_know, tmp_right, reset_d = FALSE;
     BSrc       rc1, rc2,rco;

     *rc = BSSUCC;
     rc1 = BSSUCC;     
     rc2 = BSSUCC;     
     rco = BSSUCC;

     *num_cur = 0;
     
     /** Convert in_cv to multiple end knots **/

     BSalloccv(in_cv->order, in_cv->num_poles, in_cv->rational,
                  0, &in_curve, rc);
     if(BSERROR(*rc))
     {
         status = FALSE;
         goto wrapup;
     }
     status = BScv_copy(rc,in_cv,in_curve);
     if(! status) goto wrapup;

     status = BScnvtomkt(rc, in_curve);
     if(! status) goto wrapup;


     /**----------------------------
        Prepare input for BScvoff3d
     -------------------------------**/

     /*
         if dir_know = TRUE, find the transformation matrix to be input to
      BScvoff3d.
         if dir_know = FALSE, calculate unit normal to plane containing 
      in_curve and boolean indicating if this unit normal X tangent vector
      = offset direction (tmp_in_norm, right_side) and set tmp_dir_know =
      TRUE to call BScvoff3d. 
     */

     if(dir_know)
     {
        tmp_dir_know = TRUE;

        tmp_in_norm[0] = in_norm[0];
        tmp_in_norm[1] = in_norm[1];
        tmp_in_norm[2] = in_norm[2];

        BStrans2(in_norm, TRUE, tmat, rc);
        if (BSERROR(*rc)) 
           goto wrapup;
        if(*right)
        {
           right_side = 1;
        }
        else
        {
           right_side = -1;
        }

        BSalloccv(in_curve->order, in_curve->num_poles, in_curve->rational,
                  0, &in_curve2, rc);
        if(BSERROR(*rc))
        {
            status = FALSE;
            goto wrapup;
        }
        status = BScv_copy(rc,in_curve,in_curve2);
        if(! status) 
          goto wrapup;
     }
     else
     {
        BSofnorm(in_curve, q_pnt, dir_know, in_norm, &tmp_right, &in_curve2,
                 tmp_in_norm,rc);
        if(BSERROR(*rc))
          goto wrapup;

        tmp_dir_know = TRUE;

        if(tmp_right)
        {
           right_side = 1;
        }
        else
        {
           right_side = -1;
        }

        BSfndoffdir(in_curve2, q_pnt, tmp_in_norm, &right_side, tmat, rc);
        if(BSERROR(*rc)) 
           goto wrapup;

        if (d < 0.0)
        {
           /* negative offset distance -- reverse right_side indicator */
           right_side = -right_side;
           d = ABS(d);
           reset_d = TRUE;
        }       
     }
    
     if(code1 == 1)
     {
        fillet = TRUE;
     }
     else
     {
        fillet = FALSE;
     }

     rm_loop = code2;

     BScvoff3d(in_curve2, d, fillet, rm_loop, FALSE, q_pnt, tmp_in_norm, 
               tmp_dir_know, &right_side, tmat, off_cur, num_cur, array, rc);
     if (*rc == BSWARN)
     {
       /* rc = BSWARN means that we have a solution with question.
          The offset curve is not within the tolerance.
          V.Hsu 6/5/98 */
                  
       rco = *rc;
       *rc = BSSUCC;
     }


     if(BSERROR(*rc)) goto wrapup;

     if(! dir_know)
     {
        if(right_side == 1)
        {
           *right = TRUE;
        }
        else
        {
           *right = FALSE;
        }
     }

     if (reset_d)
        d = -d;

     wrapup:
       if(BSERROR(*rc))
       {
          status = FALSE;
       }
       if(in_curve2)
       {
           status = BSfreecv(&rc1,in_curve2);
           if (BSOKAY(*rc) && BSERROR(rc1))
              *rc = rc1;
       }
       if(in_curve)
       {
           status = BSfreecv(&rc2,in_curve);
           if (BSOKAY(*rc) && BSERROR(rc2))
              *rc = rc2;
       }
       if( BSOKAY(*rc) && BSERROR(rco))
         *rc = rco;

       if(BSERROR(*rc))
           BSdbgrc(*rc,"BScvoffsetd");
}

