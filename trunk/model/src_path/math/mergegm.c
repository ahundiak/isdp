/*
  OVERVIEW

  NOTES

  HISTORY
*/

/* Includes */

#include <stdio.h>
#include <math.h>
#include <malloc.h>
#include <memory.h>
#include <alloca.h>

#include "bs.h"
#include "bserr.h"
#include "bsparameters.h"
#include "bsgeom_cvsf.h"
#include "madef.h"

#include "PWminimum.h"
#include "PWerror.h"
#include "PWgmdata.h"
#include "PWgmint.h"

#include "bsalloccv.h"
#include "bscv_copy.h"
#include "bsmerge_cv.h"

#include "PWapi/mergegm.h"
#include "PWapi/cvgeom.h"
#include "PWapi/dotp.h"
#include "PWapi/normvec.h"
#include "PWapi/mkvec.h"
#include "PWapi/pytocv.h"
#include "PWapi/mdstptgm.h"
#include "PWapi/ptpargm.h"
  
/*
  Valid Combinations : 
*/

PWresult pwMergeCvdata
(
  struct PWcvdata *p_cv1,
  struct PWcvdata *p_cv2,
  double lentol,
  
  struct PWcvdata *p_outcv
)
{
  PWresult PWsts=PW_K_Success;
  BSrc BSmsg=BSSUCC;
  PWboolean BSsts=TRUE;

  enum PWcvdatatype cv1_type=PWcvdata_null, cv2_type=PWcvdata_null, 
                    outcv_type=PWcvdata_null;
  int num_pts1=0, num_pts2=0;
  double *p_pts1=NULL, *p_pts2=NULL, dist=0;
  PWpoint stoppt, startpt;

  p_outcv->datatype = PWcvdata_null;
  memset (startpt, 0, sizeof (PWpoint));
  memset (stoppt, 0, sizeof (PWpoint));
  pwGetEndPtCvdata (p_cv1, FALSE, TRUE, stoppt);
  pwGetEndPtCvdata (p_cv2, FALSE, FALSE, startpt);
  dist = pwDistPtPt (stoppt, startpt);
  OnErrorState (dist > lentol, PWsts, SetError (PW_K_Pathway, PW_K_InvalidArg),
                wrapup);

  cv1_type = p_cv1->datatype;
  cv2_type = p_cv2->datatype;

  if (cv1_type == PWcvdata_pt2d && cv2_type == PWcvdata_pt2d)
  {
    outcv_type = PWcvdata_pt2d;
  } 
  else if ((cv1_type == PWcvdata_py2d && cv2_type == PWcvdata_py2d) ||
           (cv1_type == PWcvdata_py2d && cv2_type == PWcvdata_pt2d) ||
           (cv1_type == PWcvdata_pt2d && cv2_type == PWcvdata_py2d))
  {
    outcv_type = PWcvdata_py2d;
  }
  else if (cv1_type == PWcvdata_pt && cv2_type == PWcvdata_pt)
  {
    outcv_type = PWcvdata_pt;
  }
  else if ((cv1_type == PWcvdata_py && cv2_type == PWcvdata_py) ||
           (cv1_type == PWcvdata_py && cv2_type == PWcvdata_pt) ||
           (cv1_type == PWcvdata_pt && cv2_type == PWcvdata_py))
  {
    outcv_type = PWcvdata_py;
  }
  else
  {
    outcv_type = PWcvdata_bspcv;
  }

  if (outcv_type == PWcvdata_pt2d)
  {
    memcpy (p_outcv->data.pt2d, p_cv1->data.pt2d, sizeof (PWpoint2d));
  }
  else if (outcv_type == PWcvdata_pt)
  {
    memcpy (p_outcv->data.pt, p_cv1->data.pt, sizeof (PWpoint));
  }
  else if (outcv_type == PWcvdata_py2d)
  {
    num_pts1 = (cv1_type == PWcvdata_py2d) ? p_cv1->data.py2d.num_pts : 1;
    num_pts2 = (cv2_type == PWcvdata_py2d) ? p_cv2->data.py2d.num_pts : 1;

    p_pts1 = &p_cv1->data.py2d.p_pts[0][0]; 
    p_pts2 = &p_cv2->data.py2d.p_pts[0][0]; 

    if (num_pts1 > 1 && num_pts2 > 1)
    {
      PWvector2d vec1, vec2;

      pwMakeVec2d (&p_pts1[(num_pts1 -2) * 2], &p_pts1[(num_pts1 - 1) * 2],
                   vec1);
      pwMakeVec2d (&p_pts2[0], &p_pts2[2], vec2);
      pwNormVec2d (vec1, vec1);
      pwNormVec2d (vec2, vec2);
      if (fabs (pwDot2d (vec1, vec2) - 1.0) <= lentol)
      {
        p_outcv->data.py2d.num_pts = num_pts1 + num_pts2 - 2;
        p_outcv->data.py2d.p_pts = (PWpoint2d *) malloc (
                  p_outcv->data.py2d.num_pts * sizeof (PWpoint2d));
        memcpy (&p_outcv->data.py2d.p_pts[0][0], p_pts1, 
                (num_pts1-1) * sizeof (PWpoint2d));
        memcpy (&p_outcv->data.py2d.p_pts[num_pts1-1][0], &p_pts2[2], 
                (num_pts2-1) * sizeof (PWpoint2d));
      }
      else
      {
        p_outcv->data.py2d.num_pts = num_pts1 + num_pts2 - 1;
        p_outcv->data.py2d.p_pts = (PWpoint2d *) malloc (
                  p_outcv->data.py2d.num_pts * sizeof (PWpoint2d));
        memcpy (&p_outcv->data.py2d.p_pts[0][0], p_pts1, 
                num_pts1 * sizeof (PWpoint2d));
        memcpy (&p_outcv->data.py2d.p_pts[num_pts1][0], &p_pts2[2], 
                (num_pts2-1) * sizeof (PWpoint2d));
      }
    }
    else if (num_pts1 > 1)
    {
      p_outcv->data.py2d.num_pts = num_pts1;
      p_outcv->data.py2d.p_pts = (PWpoint2d *) malloc (num_pts1 * 
                                                       sizeof (PWpoint2d));
      memcpy (&p_outcv->data.py2d.p_pts[0][0], p_pts1, 
              num_pts1 * sizeof (PWpoint2d));
    }
    else
    {
      p_outcv->data.py2d.num_pts = num_pts2;
      p_outcv->data.py2d.p_pts = (PWpoint2d *) malloc (num_pts2 * 
                                                       sizeof (PWpoint2d));
      memcpy (&p_outcv->data.py2d.p_pts[0][0], p_pts2, 
              num_pts2 * sizeof (PWpoint2d));
    }
  }
  else if (outcv_type == PWcvdata_py)
  {
    num_pts1 = (cv1_type == PWcvdata_py) ? p_cv1->data.py.num_pts : 1;
    num_pts2 = (cv2_type == PWcvdata_py) ? p_cv2->data.py.num_pts : 1;

    p_pts1 = &p_cv1->data.py.p_pts[0][0]; 
    p_pts2 = &p_cv2->data.py.p_pts[0][0]; 

    if (num_pts1 > 1 && num_pts2 > 1)
    {
      PWvector vec1, vec2;

      pwMakeVec (&p_pts1[(num_pts1 -2) * 3], &p_pts1[(num_pts1 - 1) * 3],
                 vec1);
      pwMakeVec (&p_pts2[0], &p_pts2[3], vec2);
      pwNormVec (vec1, vec1);
      pwNormVec (vec2, vec2);
      if (fabs (pwDot (vec1, vec2) - 1.0) <= lentol)
      {
        p_outcv->data.py.num_pts = num_pts1 + num_pts2 - 2;
        p_outcv->data.py.p_pts = (PWpoint *) malloc (
                  p_outcv->data.py.num_pts * sizeof (PWpoint));
        memcpy (&p_outcv->data.py.p_pts[0][0], p_pts1, 
                (num_pts1-1) * sizeof (PWpoint));
        memcpy (&p_outcv->data.py.p_pts[num_pts1-1][0], &p_pts2[3], 
                (num_pts2-1) * sizeof (PWpoint));
      }
      else
      {
        p_outcv->data.py.num_pts = num_pts1 + num_pts2 - 1;
        p_outcv->data.py.p_pts = (PWpoint *) malloc (
                  p_outcv->data.py.num_pts * sizeof (PWpoint));
        memcpy (&p_outcv->data.py.p_pts[0][0], p_pts1, 
                num_pts1 * sizeof (PWpoint));
        memcpy (&p_outcv->data.py.p_pts[num_pts1][0], &p_pts2[3], 
                (num_pts2-1) * sizeof (PWpoint));
      }
    }
    else if (num_pts1 > 1)
    {
      p_outcv->data.py.num_pts = num_pts1;
      p_outcv->data.py.p_pts = (PWpoint *) malloc (num_pts1 * 
                                                       sizeof (PWpoint));
      memcpy (&p_outcv->data.py.p_pts[0][0], p_pts1, 
              num_pts1 * sizeof (PWpoint));
    }
    else
    {
      p_outcv->data.py.num_pts = num_pts2;
      p_outcv->data.py.p_pts = (PWpoint *) malloc (num_pts2 * 
                                                       sizeof (PWpoint));
      memcpy (&p_outcv->data.py.p_pts[0][0], p_pts2, 
              num_pts2 * sizeof (PWpoint));
    }
  }
  else
  {
    struct IGRbsp_curve *p_bscv1=NULL, *p_bscv2=NULL;
    struct IGRbsp_curve bscv1, bscv2;

    if (cv1_type == PWcvdata_py)
    {
      p_bscv1 = &bscv1;
      PWsts = PW_AllocBspCvStack (p_cv1->data.py.num_pts, 2, 0, (*p_bscv1));
      OnErrorCode (PWsts, wrapup);
      pwCnvtPyToCv (&p_cv1->data.py, lentol, p_bscv1);
    }
    else if (cv1_type == PWcvdata_bspcv)
    {
      p_bscv1 = p_cv1->data.p_bspcv;
    }
   
    if (cv2_type == PWcvdata_py)
    {
      p_bscv2 = &bscv2;
      PWsts = PW_AllocBspCvStack (p_cv2->data.py.num_pts, 2, 0, (*p_bscv2));
      OnErrorCode (PWsts, wrapup);
      pwCnvtPyToCv (&p_cv2->data.py, lentol, p_bscv2);
    }
    else
    {
      p_bscv2 = p_cv2->data.p_bspcv;
    }

    if (p_bscv1 && p_bscv2)
    {
      long num_poles=0; short order=0; PWboolean rational=FALSE;

      rational = p_bscv1->rational || p_bscv2->rational;

      if (p_bscv1->order == p_bscv2->order)
      {
        num_poles = p_bscv1->num_poles + p_bscv2->num_poles - 1;
        order = p_bscv1->order; 
      }
      else if (p_bscv1->order > p_bscv2->order)
      {
        num_poles = p_bscv1->num_poles + p_bscv2->num_poles +
                    ((p_bscv2->num_poles - p_bscv2->order + 2) * 
                     (p_bscv1->order - p_bscv2->order));
        order = p_bscv1->order; 
      }
      else
      {
        num_poles = p_bscv2->num_poles + p_bscv1->num_poles +
                    ((p_bscv1->num_poles - p_bscv1->order + 2) * 
                     (p_bscv2->order - p_bscv1->order));
        order = p_bscv2->order; 
      }

      BSalloccv (order, num_poles, rational, 0, &p_outcv->data.p_bspcv, 
                 &BSmsg);
      OnErrorState (BSERROR (BSmsg), PWsts, SetError (PW_K_Pathway, 
                    PW_K_Memory), wrapup);

      BSsts = BSmerge_cv (&BSmsg, p_bscv1, p_bscv2, p_outcv->data.p_bspcv);
      OnErrorState (!BSsts || BSERROR (BSmsg), PWsts, SetError (PW_K_Pathway, 
                    PW_K_Internal), wrapup);
    }
    else if (p_bscv1)
    {
      BSalloccv (p_bscv1->order, p_bscv1->num_poles, p_bscv1->rational, 0, 
                 &p_outcv->data.p_bspcv, &BSmsg);
      OnErrorState (BSERROR (BSmsg), PWsts, SetError (PW_K_Pathway, 
                    PW_K_Memory), wrapup);

      BSsts = BScv_copy (&BSmsg, p_bscv1, p_outcv->data.p_bspcv);
      OnErrorState (!BSsts || BSERROR (BSmsg), PWsts, SetError (PW_K_Pathway, 
                    PW_K_Internal), wrapup);
    }
    else
    {
      BSalloccv (p_bscv2->order, p_bscv2->num_poles, p_bscv2->rational, 0, 
                 &p_outcv->data.p_bspcv, &BSmsg);
      OnErrorState (BSERROR (BSmsg), PWsts, SetError (PW_K_Pathway, 
                    PW_K_Memory), wrapup);

      BSsts = BScv_copy (&BSmsg, p_bscv2, p_outcv->data.p_bspcv);
      OnErrorState (!BSsts || BSERROR (BSmsg), PWsts, SetError (PW_K_Pathway, 
                    PW_K_Internal), wrapup);
    }
  }

  p_outcv->datatype = outcv_type;

wrapup :

  PW_Wrapup (PWsts, "pwMergeCvdata");
  return PWsts;
}

