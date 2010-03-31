/*
  FILE DESCRIPTION

  This file contains the functions that deal with curve-data (PWcvdata) and
  it's length. 
*/

#include <math.h>
#include <alloca.h>

#include "bs.h"
#include "bserr.h"
#include "bsparameters.h"
#include "prototypes/bsarclen2.h"
#include "prototypes/bsiarcln.h"

#include "PWminimum.h"
#include "PWerror.h"
#include "PWgmdata.h"
#include "PWapi/cvlenquery.h"
#include "PWapi/mdstptgm.h"


/*
  DESCRIPTION

  The following function returns the length of the given curve data.

  HISTORY

  SS  :  03/01/96  :  Creation
*/
  
double pwCvdataLen
(
  struct PWcvdata *cvdata
)
{
  PWboolean stat;
  int i, numpts;
  double cvlen=0.0, startpar, endpar, midpar;
  BSrc bsrc;
  PWpoint2d *pts2d;
  PWpoint *pts;
  struct IGRbsp_curve *cv;

  switch (cvdata->datatype)
  {
    case PWcvdata_pt2d:
    case PWcvdata_pt:
      cvlen = 0.0;
      break;

    case PWcvdata_py2d:
      numpts = cvdata->data.py2d.num_pts;
      pts2d = cvdata->data.py2d.p_pts;
      for (i=0; i<numpts-1; i++)
        cvlen += pwDistPtPt2d (pts2d[i], pts2d[i+1]);
      break;

    case PWcvdata_py:
      numpts = cvdata->data.py.num_pts;
      pts = cvdata->data.py.p_pts;
      for (i=0; i<numpts-1; i++)
        cvlen += pwDistPtPt (pts[i], pts[i+1]);
      break;

    case PWcvdata_bspcv:
    case PWcvdata_gmbspcv:
      cv = cvdata->datatype == PWcvdata_bspcv ? 
            cvdata->data.p_bspcv : cvdata->data.p_gmbspcv->bspcv;
      startpar = cv->knots[cv->order-1];
      endpar = cv->knots[cv->num_poles];
      midpar = (startpar + endpar) / 2.0;
      BSarclen2 (&bsrc, &stat, cv, &startpar, &endpar, &midpar, &cvlen);
      break;
    }
      
  return (cvlen);
}


/*
  DESCRIPTION

  This function returns the struct PWcvparam along the given curve data,
  which is at a length of 'length_along' from the starting point. The length
  is measured along the curve. If the 'length_along' exceeds the total length,
  the endpoint parameter is returned.

  
  HISTORY

  SS  :  03/01/96  :  Creation
*/

void pwParAtCvdataLen
(
  struct PWcvdata *cvdata,
  double length_along,
  struct PWcvparam *cvpar
)
{
  PWboolean found=FALSE;
  int numpts, i;
  double seglen, cvlen=0.0, startpar, endpar;
  BSrc bsrc;
  PWpoint2d *pts2d=NULL;
  PWpoint *pts=NULL;
  struct IGRbsp_curve *cv;
  enum PWcvdatatype cvtype;

  cvtype = cvdata->datatype;  
  switch (cvtype)
  {
    case PWcvdata_pt2d:
    case PWcvdata_pt:
      cvpar->spaninx = 0;
      cvpar->spanpar = 0.0;
      break;

    case PWcvdata_py2d:
    case PWcvdata_py:
      if (cvtype == PWcvdata_py2d)
      {
        numpts = cvdata->data.py2d.num_pts;
        pts2d = cvdata->data.py2d.p_pts;
      }
      else
      {
        numpts = cvdata->data.py.num_pts;
        pts = cvdata->data.py.p_pts;
      }
      for (i=0; i<numpts-1; i++)
      {
        if (cvtype == PWcvdata_py2d)        
          seglen = pwDistPtPt2d (pts2d[i], pts2d[i+1]);
        else
          seglen = pwDistPtPt (pts[i], pts[i+1]);

        if (cvlen + seglen > length_along)
        {
          cvpar->spaninx = i;
          cvpar->spanpar = (length_along - cvlen) / seglen;
          found = TRUE;
          break;
        }
        else
          cvlen += seglen;
      }
      if (!found)
      {
        cvpar->spaninx = numpts-2;
        cvpar->spanpar = 1.0;
      }
      break;

    case PWcvdata_bspcv:
    case PWcvdata_gmbspcv:
      cv = cvdata->datatype == PWcvdata_bspcv ? 
            cvdata->data.p_bspcv : cvdata->data.p_gmbspcv->bspcv;
      startpar = cv->knots[cv->order-1];
      endpar = cv->knots[cv->num_poles];
   
      cvpar->spaninx = 0;
      BSiarcln (&bsrc, cv, &startpar, &length_along, &endpar, 
       &cvpar->spanpar);
      break;
    }
      
  return;
}
