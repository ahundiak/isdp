/* $Id: bs2cvsoffpg.c,v 1.1.1.1 2001/01/04 21:07:26 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        emsfixes/bs/bs2cvsoffpg.c
 *
 * Description:
 *
 * Dependencies: 
 *
 * Revision History:
 *      $Log: bs2cvsoffpg.c,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:26  cvs
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
    BS2cvsoffpg


Abstract
    This routine offsets the polygons for two curves.

Synopsis
    void BS2cvsoffpg(cv1, cv2, position, d, fillet,  right_side,
                     nor_vec, after_int, ref_pt, off1, off2, gap, off12, 
                     degen, rc)
                     
    struct IGRbsp_curve *cv1
    struct IGRbsp_curve *cv2
    IGRint              position
    IGRdouble           d
    IGRboolean          fillet
    IGRint              right_side
    IGRvector           nor_vec
    IGRboolean          *after_int
    IGRpoint            ref_pt
    struct IGRbsp_curve *off1
    struct IGRbsp_curve *off2
    IGRboolean          *gap
    struct IGRbsp_curve **off12
    IGRint              *degen
    BSrc                *rc
  
Description

    Input:
       cv1 - 1st original curve
       cv2 - 2nd original curve

       position - indicator of the positions of cv1 and cv2
                  1 : start(first two curves of the composite curve or
                            first two spans of the curve.
                            off1 and off2 are not available when input.)
                  2 : middle ( off1 is already available)
                  3 : end (off1 is available)
                  4 : only 2 curves exist in the composite curve
                      (off1 and off2 are not available)
       d - offset distance

       fillet - TRUE, use fillet connection
                FALSE, use extended segment as connection

       right_side - +1, if tangent of a point on a curve cross with
                        nor_vec gets the offset direction
                    -1, if opposite direction to offset is obtained by
                        crossing the tangent of a point on curve with 
                        nor_vec.

       nor_vec - view normal or normal to the planar curve 

       after_int - TRUE, if previous offset case is intersecting.
                   FALSE, otherwise.

       ref_pt - intersection point on off1 if after_int = TRUE.

       off1 - offset of cv1
       off2 - offset of cv2

    Output:

       after_int - TRUE, if offset case is intersecting.
                   FALSE, otherwise.

       par - intersection point on off2 if after_int = TRUE.

       off1 - offset of cv1
       off2 - offset of cv2

       gap - if TRUE, off12 exists
             else, no off12

       off12 - arc or linestring to connect off1 and off2

       degen - 0, both cv1 and cv2 are valid
               1, cv1 is degenerated
               2, cv2 is degenerated
               3, both cv1 and cv2 are degenerated

Return Values
       If successful, rc = BSSUCC; else, rc = error message.

Notes
       off1 and off2 MUST be allocated memory--NOT static memory!!!

       Off12 needs to be set to NULL before this routine is called.

Index
    md

Keywords

History
       Y. S. Sheng  09/16/87  : Creation date.
       Y. S. Sheng  12/08/87  : Revise the declaration of degen to be 
                                IGRint.
       Y. S. Sheng  12/22/87  : Check if off12 has an address,then set 
                                gap = TRUE. 
       Y. S. Sheng  01/26/88  : Add an argument "arc_type" in BSofk3arc.
       Vivian W.Ye  05/12/88  : Replace BSmdistptcv by BSmdstptcv.
       S. C. Wood   07/14/89  : Added code to handle 3-D offset cases.
                                Temporarily set z coordinates of cv1 and
                                cv2 to 0.0 to check for degeneracy.
                                Copy offset curves (off1, off2) into new
                                curves (off1_temp, off2_temp) and
                                set z values for new curves equal 0.0
                                to be sent to BSmdstptcv to return minimum
                                distance between offset curve and intersection
                                point which is returned from BScvint_trm.
       S. C. Wood   09/28/89  : Replace call to BScvint_trm to BScvinttrmd
                                (copy of BScvint_trm with offset distances
                                as arguments).
       S. C. Wood   12/14/89  : If BScvinttrmd returns rc = BSNOSOLUTION, 
                                call BSexttrmcmp to extend off1 and off2
                                to point of intersection or construct line
                                between these 2 curves if the extensions
                                do not intersect within desired tolerance.
                                Set gap = TRUE if BSexttrmcmp is called.
       S. C. Wood   12/18/89  : Always copy new_off1 into off1 and new_off2
                                into off2 when returning from BSexttrmcmp
                                whether the curves were polynomially extended
                                or linearly extended and connected.
                                Set temporary vector (tmp_nor_vec) equal
                                (0, 0, 1) to be sent to BSzigzag to deter-
                                mine type of connection between 2 curves.
       S. C. Wood   12/31/92  : Allocate more memory as is now required for
                                output curves from BSexttrmcmp.
                                Set poles, weights, and knots of off1 =
                                those of new_off1 if new_off1 is larger
                                than off1. Similar for off2.
       S. C. Wood   01/05/92  : After calling BSexttrmcmp, check if off12
                                (line) exists.  If so, set gap = TRUE.
       S. C. Wood   01/07/92  : Initialize *off12 = NULL at beginning of
                                routine.
       S. C. Wood   02/24/93  : Initialize gap = FALSE.
       S.G. Catron  12/05/97  : Check "polyext" after BSexttrmcmp, if
                                -1 or -2, then set degen = |polyext|.
       Vivian Y.Hsu 06/05/98  : If rc = BSWARN returned from BSspnoffset,
                                go on to the end, then return it.
*/

#include <math.h>
#define BSVOID
#include "bsdefs.h"
#include "bserr.h"
#include "bsmalloc.h"
#include "bsstackalloc.h"
#include "bsparameters.h"
#define MAXSIZE 100

void BS2cvsoffpg(
struct IGRbsp_curve *cv1,
struct IGRbsp_curve *cv2,
IGRint              position,
IGRdouble           d,
IGRboolean          fillet,
IGRint              right_side,
IGRvector           nor_vec,
IGRboolean          *after_int,
IGRpoint            ref_pt,
struct IGRbsp_curve *off1,
struct IGRbsp_curve *off2,
IGRboolean          *gap,
struct IGRbsp_curve **off12,
IGRint              *degen,
BSrc                *rc)
{
#include "bsdbgrc.h"
#include "bststcvdegn.h"
#include "bsspnoffset.h"
#include "bscvinttrmd.h"
#include "bsalloccv.h"
#include "bscvkttol2.h"
#include "bsofk3arc.h"
#include "bscveval.h"
#include "bsptcvgen.h"
#include "bsmdstptcv.h"
#include "bsexttrmcmp.h"
#include "bszigzag.h"
#include "bsnorvec.h"
#include "bscv_copy.h"
#include "bscvsplit.h"
#include "bslngen.h"
#include "bsfreecv.h"


    IGRboolean status=TRUE,degn1,degn2;
    IGRboolean planar = TRUE;
    IGRint     arc_type;
    IGRpoint   base;
    IGRdouble  par;
    IGRdouble  *tpol_ptr=NULL, *twt_ptr = NULL, *tknot_ptr = NULL;
    IGRdouble  tpol,tdeg;
    IGRdouble  knot_tol1;
    IGRpoint   lder,rder;    

    IGRpoint   p1,p2,p3;
    IGRpoint   eval_1[2],eval_2[2],point[1];
    IGRint     joint,num_derv,j,i;
    IGRdouble  dist;
    IGRdouble  *z1_temp = NULL, *z2_temp = NULL;
    IGRdouble  z1_temp2[MAXSIZE], z2_temp2[MAXSIZE];
    struct IGRbsp_curve *l_cur = NULL, *r_cur = NULL;
    struct IGRbsp_curve *off1_temp = NULL, *off2_temp = NULL;
    struct IGRbsp_curve *new_off1 = NULL, *new_off2 = NULL;
    IGRboolean polyext = FALSE;
    IGRvector  tmp_nor_vec;
    IGRlong    npoles;
    BSrc       rc1 = BSSUCC, rco = BSSUCC;

    status = TRUE;
    *rc = BSSUCC;

    /* Initialize off12 */
    *off12 = NULL;
    *gap = FALSE;
    *degen = FALSE;
    if( position != 5 )
    {
      /**------------------------------------------------------------------
          Allocate temporary arrays for storing z coordinates of cv1 and cv2
       ---------------------------------------------------------------------**/

       if (cv1->num_poles > MAXSIZE)
       {
          z1_temp = (IGRdouble *)BSstackalloc((unsigned)(cv1->num_poles * 
                    sizeof(IGRdouble)));
          if(! z1_temp)
          {
             *rc = BSNOSTKMEMORY;
             goto wrapup;
          }
       }
       else
       {
          z1_temp = z1_temp2;
       }
 
       if (cv2->num_poles > MAXSIZE)
       {
          z2_temp = (IGRdouble *)BSstackalloc((unsigned)(cv2->num_poles * 
                      sizeof( IGRdouble)));
          if(! z2_temp)
          {
             *rc = BSNOSTKMEMORY;
             goto wrapup;
          }
       }
       else
       {
          z2_temp = z2_temp2;
       }

       for(i=0; i < cv1->num_poles; i++)
       {
          z1_temp[i] = cv1->poles[3 * i + 2];
          cv1->poles[3 * i + 2] = 0;
       }

       for(i=0; i < cv2->num_poles; i++)
       {
          z2_temp[i] = cv2->poles[3 * i + 2];
          cv2->poles[3 * i + 2] = 0;
       }

       /** Check degeneration of cv1 and cv2 **/
       BStstcvdegn(cv1, &degn1, rc);
       if(BSERROR(*rc)) goto wrapup;

       BStstcvdegn(cv2, &degn2, rc);
       if(BSERROR(*rc)) goto wrapup;
   
       if( degn1 )
       {
           if( degn2 )
               *degen = 3;
           else 
               *degen = 1;
       }
       else
       {
           if( degn2 )           
              *degen = 2;

           else
              *degen = 0;
       }
     /*----------------------------------------------------------
       Reset z coordinates of cv1 and cv2 back to original values 
      ------------------------------------------------------------*/
       for(i=0; i < cv1->num_poles; i++)
       {
          cv1->poles[3 * i + 2] = z1_temp[i];
       }

       for(i=0; i < cv2->num_poles; i++)
       {
          cv2->poles[3 * i + 2] = z2_temp[i];
       }
    }
    /*--------------------
       offset cv1 and cv2 
       --------------------*/
    if( *degen != 0 )
    {
        goto wrapup;
    }
    else
    {
        /** cv1 and cv2 are valid curves **/

        if((position == 1) || (position == 4))
        {
           BSspnoffset(cv1, d, nor_vec, right_side, off1, rc);
           if(BSERROR(*rc)) goto wrapup;

           BSspnoffset(cv2, d, nor_vec, right_side, off2, rc);
           if(BSERROR(*rc)) goto wrapup;
          
           /*---------------------------------------------------
              Make copy of off1 and off2 and set z values = 0.0
              for referencing.
             ----------------------------------------------------*/

           BSalloccv(off1->order, off1->num_poles, off1->rational,
                     0, &off1_temp, rc);
           if(BSERROR(*rc)) 
             goto wrapup;

           status = BScv_copy(rc, off1, off1_temp);
           if(! status) 
             goto wrapup;

           for (i = 0; i < off1_temp->num_poles; ++i)
           { 
               off1_temp->poles[3 * i + 2] = 0.0;
           }

           BSalloccv(off2->order, off2->num_poles, off2->rational,
                     0, &off2_temp, rc);
           if(BSERROR(*rc)) 
             goto wrapup;

           status = BScv_copy(rc, off2, off2_temp);
           if(! status) 
             goto wrapup;

           for (i = 0; i < off2_temp->num_poles; ++i)
           { 
               off2_temp->poles[3 * i + 2] = 0.0;
           }
        }
        else if (position == 2 || position == 3 )
        {
           BSalloccv(off1->order, off1->num_poles, off1->rational,
                     0, &off1_temp, rc);
           if(BSERROR(*rc)) 
             goto wrapup;

           status = BScv_copy(rc, off1, off1_temp);
           if(! status) 
             goto wrapup;

           for (i = 0; i < off1_temp->num_poles; ++i)
           { 
               off1_temp->poles[3 * i + 2] = 0.0;
           }

           BSspnoffset(cv2, d, nor_vec, right_side, off2, rc);
           if (*rc == BSWARN)
           {
             /* Continue when rc = BSWARN returned from BSspnoffset.
                It means that it didn't reach the tolerance. 
                V.Hsu 6/4/98 */
             rco = *rc;
             *rc = BSSUCC;
           }

           if(BSERROR(*rc)) 
             goto wrapup;

            BSalloccv(off2->order, off2->num_poles, off2->rational,
                      0, &off2_temp, rc);
            if(BSERROR(*rc)) 
              goto wrapup;

            status = BScv_copy(rc, off2, off2_temp);
            if(! status) 
              goto wrapup;

            for (i = 0; i < off2_temp->num_poles; ++i)
            { 
                off2_temp->poles[3 * i + 2] = 0.0;
            }
        }

        /** check connection type between off1 and off2 **/           

        tpol = cv1->knots[cv1->num_poles];
        tdeg = cv2->knots[cv2->order - 1];
        num_derv = 1;

        BScveval(cv1,tpol,num_derv,eval_1,rc);
        if (BSERROR(*rc)) goto wrapup;

        for(j=0; j < 2; j++)
        {
            p2[j] = eval_1[0][j];
            lder[j] = eval_1[1][j];
        }
        p2[2] = 0.0;
        lder[2] = 0.0;

        BScveval(cv2,tdeg,num_derv,eval_2,rc);
        if (BSERROR(*rc)) goto wrapup;

        for(j=0; j < 2; j++)
        {
            rder[j] = eval_2[1][j];
        }
        rder[2] = 0.0;

/*        status = BSnorvec(rc, lder);
        if(! status) goto wrapup;

        status = BSnorvec(rc, rder);
        if(! status) goto wrapup;
*/
        for(j=0; j < 3; j++)
        {
            p1[j] = p2[j] - lder[j];
            p3[j] = p2[j] + rder[j];
        }

        tmp_nor_vec[0] = 0.0;
        tmp_nor_vec[1] = 0.0;
        tmp_nor_vec[2] = 1.0;
        status = BSzigzag(rc, p1,p2,p3,tmp_nor_vec,&right_side,&joint);
        if(! status) goto wrapup;

        if(joint == 1)
        {
            if(*after_int)
            {
                /** trim off1 **/

                BSalloccv(off1->order, off1->num_poles, off1->rational,
                          0, &l_cur, rc);
                if(BSERROR(*rc)) goto wrapup;
                l_cur->num_boundaries = 0;

                BSalloccv(off1->order, off1->num_poles, off1->rational,
                          0, &r_cur, rc);
                if(BSERROR(*rc)) goto wrapup;
                r_cur->num_boundaries = 0;

                BScvkttol2(off1->order, off1->knots, off1->num_poles, 
                   off1->poles, off1->weights, &knot_tol1, rc);
                if(BSERROR(*rc)) goto wrapup;

                BSmdstptcv(off1_temp,ref_pt,&par,base,&dist,rc);
                if(BSERROR(*rc)) goto wrapup;
                
                status = BScvsplit(rc,off1,&par,l_cur,r_cur,&planar);
                if(! status) goto wrapup;

                /**-----------------------------------------------------
                  If  r_cur is degenerated, make it to be point curve
                -------------------------------------------------------**/

                if(fabs(par - off1->knots[off1->num_poles]) < knot_tol1)
                {
                    num_derv = 0;
                    BScveval(off1,off1->knots[off1->num_poles],num_derv,
                             point,rc);
                    if (BSERROR(*rc)) goto wrapup;

                    BSptcvgen(point[0], off1->order,off1->rational,r_cur,rc);
                    if(BSERROR(*rc)) goto wrapup;
                }
                status = BScv_copy(rc, r_cur,off1);
                if(! status) goto wrapup;
            }                               
            *gap = FALSE;
            *after_int = FALSE;
            goto wrapup;
        }
        else if(joint == 2)
        {
         /** intersection case -- if 3-D, can have apparent intersection
             in x-y coordinates but z coordinates do not intersect. In
             this case there is a gap, so construct a line in this gap
             joining off1 and off2 **/

               BScvinttrmd(d, d, off1, off2,position,ref_pt, after_int, degen,
                           rc);
               if(BSERROR(*rc)) 
               {
                 if (*rc != BSNOSOLUTION)
                    goto wrapup;
               }

               *gap = FALSE;

               /* If no solution is returned by BScvinttrmd, call BSexttrmcmp
                  to extend off1 and off2 to intersection point or construct
                  line between these 2 curves if extensions do not intersect
                  within desired tolerance. */
               if (*degen != 0 || *rc == BSNOSOLUTION)            
               {
                  *rc = BSSUCC;
                  npoles = off1->num_poles + 2 + (2 * (off1->order -2));
                  BSalloccv(off1->order, npoles, off1->rational,
                            0, &new_off1, rc);
                  if(BSERROR(*rc)) 
                    goto wrapup;

                  npoles = off2->num_poles + 2 + (2 * (off2->order -2));
                  BSalloccv(off2->order, npoles, off2->rational,
                            0, &new_off2, rc);
                  if(BSERROR(*rc)) 
                    goto wrapup;

                  BSexttrmcmp(off1, off2, d, d, after_int, ref_pt, off12, 
                             &polyext, new_off1, new_off2, rc);
                  if (BSERROR(*rc))
                  {
                     if( *rc == BSNOSOLUTION )
                     {
                        *degen = 3;
                        *rc = BSSUCC;
                     }
                     goto wrapup;
                  }
                  if (*off12)
                    *gap = TRUE;
                  if( polyext == -1 || polyext == -2)
                     *degen = ABS(polyext);

                  if (new_off1->num_poles > off1->num_poles)
                  {
                     tpol_ptr = new_off1->poles;                      
                     twt_ptr = new_off1->weights;
                     tknot_ptr = new_off1->knots;

                     new_off1->poles = off1->poles;
                     new_off1->weights = off1->weights;
                     new_off1->knots = off1->knots;

                     off1->poles = tpol_ptr;
                     off1->weights = twt_ptr;
                     off1->knots = tknot_ptr;

                     off1->order = new_off1->order;
                     off1->periodic = new_off1->periodic;
                     off1->non_uniform = new_off1->non_uniform;
                     off1->rational = new_off1->rational;
                     off1->num_poles = new_off1->num_poles;
                     off1->num_knots = new_off1->num_knots;
                     off1->planar = new_off1->planar;
                     off1->phy_closed = new_off1->phy_closed;
                     off1->num_boundaries = new_off1->num_boundaries;
                  }
                  else
                  {
                     BScv_copy(rc, new_off1, off1);
                     if (BSERROR(*rc))
                        goto wrapup;
                  }
               
                  if (new_off2->num_poles > off2->num_poles)
                  {
                     tpol_ptr = new_off2->poles;                      
                     twt_ptr = new_off2->weights;
                     tknot_ptr = new_off2->knots;

                     new_off2->poles = off2->poles;
                     new_off2->weights = off2->weights;
                     new_off2->knots = off2->knots;

                     off2->poles = tpol_ptr;
                     off2->weights = twt_ptr;
                     off2->knots = tknot_ptr;

                     off2->order = new_off2->order;
                     off2->periodic = new_off2->periodic;
                     off2->non_uniform = new_off2->non_uniform;
                     off2->rational = new_off2->rational;
                     off2->num_poles = new_off2->num_poles;
                     off2->num_knots = new_off2->num_knots;
                     off2->planar = new_off2->planar;
                     off2->phy_closed = new_off2->phy_closed;
                     off2->num_boundaries = new_off2->num_boundaries;
                  }
                  else
                  {
                     BScv_copy(rc, new_off2, off2);
                     if (BSERROR(*rc))
                        goto wrapup;
                  }
               }

               goto wrapup;
        }                
        else
        {
            /** extending or filleting case **/

            if(*after_int)
            {
                /** trim off1 **/

                BSalloccv(off1->order, off1->num_poles, off1->rational,
                          0, &l_cur, rc);
                if(BSERROR(*rc)) goto wrapup;
                l_cur->num_boundaries = 0;

                BSalloccv(off1->order, off1->num_poles, off1->rational,
                          0, &r_cur, rc);
                if(BSERROR(*rc)) goto wrapup;
                r_cur->num_boundaries = 0;

                BScvkttol2(off1->order, off1->knots, off1->num_poles, 
                   off1->poles, off1->weights, &knot_tol1, rc);
                if(BSERROR(*rc)) goto wrapup;


                BSmdstptcv(off1_temp,ref_pt,&par,base,&dist,rc);
                if(BSERROR(*rc)) goto wrapup;
                
                status = BScvsplit(rc,off1,&par,l_cur,r_cur,&planar);
                if(! status) goto wrapup;

                /**-----------------------------------------------------
                  If  r_cur is degenerated, make it to be point curve
                ------------------------------------------------------**/

                if(fabs(par - off1->knots[off1->num_poles]) < knot_tol1)
                {
                    num_derv = 0;
                    BScveval(off1,off1->knots[off1->num_poles],num_derv,
                             point,rc);
                    if (BSERROR(*rc)) goto wrapup;

                    BSptcvgen(point[0],off1->order,off1->rational,r_cur, rc);
                    if(BSERROR(*rc)) goto wrapup;
                }
                status = BScv_copy(rc, r_cur,off1);
                if(! status) goto wrapup;
            }                               
            p2[2] = eval_1[0][2];  /** assign z-values back **/


            *off12 = NULL;
            BSofk3arc(cv1, cv2, off1, off2, fillet, d, d, nor_vec,
                      right_side, &arc_type,off12, rc);
            if(BSERROR(*rc)) goto wrapup;

            if(*off12)
            {
               *gap = TRUE;
            }
            else
            {
               *gap = FALSE;
            }
            *after_int = FALSE;
        }
    }

    wrapup:

      if(new_off2)
      {
         status = BSfreecv(&rc1, new_off2);
         if (BSOKAY(*rc) && BSERROR(rc1))
           *rc = rc1;
         new_off2 = NULL;
      }
      if(new_off1)
      {
         status = BSfreecv(&rc1, new_off1);
         if (BSOKAY(*rc) && BSERROR(rc1))
           *rc = rc1;
         new_off1 = NULL;
      }
      if(l_cur)
      {
         status = BSfreecv(&rc1, l_cur);
         if (BSOKAY(*rc) && BSERROR(rc1))
           *rc = rc1;
         l_cur = NULL;
      }
      if(r_cur)
      {
         status = BSfreecv(&rc1, r_cur);
         if (BSOKAY(*rc) && BSERROR(rc1))
           *rc = rc1;
         r_cur = NULL;
      }
      if(off2_temp)
      {
         status = BSfreecv(&rc1, off2_temp);
         if (BSOKAY(*rc) && BSERROR(rc1))
           *rc = rc1;
         off2_temp = NULL;
      }
      if(off1_temp)
      {
         status = BSfreecv(&rc1, off1_temp);
         if (BSOKAY(*rc) && BSERROR(rc1))
           *rc = rc1;
         off1_temp = NULL;
      }

      if (cv2->num_poles > MAXSIZE)
      {
         if (z2_temp)
         {
            BSstackdealloc((char *) z2_temp);
            z2_temp = NULL;
         }
      }

      if (cv1->num_poles > MAXSIZE)
      {
         if (z1_temp)
         {
            BSstackdealloc((char *) z1_temp);
            z1_temp = NULL;
         }
      }

      if (BSOKAY(*rc) && BSERROR(rco))
        *rc = rco;

      if(BSERROR(*rc))
          BSdbgrc(*rc,"BS2cvsoffpg");
      return;

}
