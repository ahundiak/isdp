#include "bs.h"
#include "bserr.h"

#include "PWminimum.h"
#include "PWerror.h"
#include "PWgmdata.h"

/* Prototypes */

#include "bsrev_cv.h"
#include "PWapi/revgm.h"
#include "PWapi/memfunc.h"

/*
  ABSTRACT
 
  Reverses the curve data.

  NOTES

  None. 
*/


void pwRevCvdata
(
  struct PWcvdata *p_cvdata
)
{
  PWboolean  BSsts = TRUE;
  BSrc       BSmsg = BSSUCC;

  switch(p_cvdata->datatype)
  {
    case PWcvdata_py2d:
        pwRevPy2d (p_cvdata->data.py2d.num_pts, p_cvdata->data.py2d.p_pts);
        break;

    case PWcvdata_py:
        pwRevPy (p_cvdata->data.py.num_pts, p_cvdata->data.py.p_pts);
        break;

    case PWcvdata_bspcv:
        BSsts = BSrev_cv(&BSmsg, p_cvdata->data.p_bspcv);
        break;

    case PWcvdata_gmbspcv:
        BSsts = BSrev_cv(&BSmsg, p_cvdata->data.p_gmbspcv->bspcv);
        break;

    default: 
        break;
  }
  
  return;
}

/*
  ABSTRACT

  Following functions reverses the poly line. Two seperate functions are 
  available for 2D and 3D.

  NOTES

  None
*/

void pwRevPy2d
(
  int num_pts,
  PWpoint2d *p_pts
)
{
  int knt=0, num_iter=0;

  num_iter = num_pts / 2;
  for (knt=0; knt<num_iter; knt++)
    pwSwapPt2d (p_pts[knt], p_pts[num_pts-1-knt]);

  return;
}

void pwRevPy
(
  int num_pts,
  PWpoint *p_pts
)
{
  int knt=0, num_iter=0;

  num_iter = num_pts / 2;
  for (knt=0; knt<num_iter; knt++)
    pwSwapPt (p_pts[knt], p_pts[num_pts-1-knt]);

  return;
}
