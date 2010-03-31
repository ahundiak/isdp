/* Includes */

#include <stdio.h>
#include <malloc.h>         /* System */
#include <alloca.h>
#include <math.h>
#include <memory.h>

#include "bs.h"
#include "bstypes.h"
#include "bserr.h"        /* BS */
#include "bsgeom_cvsf.h"

#include "PWminimum.h"
#include "PWerror.h"
#include "PWgmdata.h"      /* Pathway */
#include "PWgmint.h"
#include "PWaligngm.h"

/* Prototypes */

#include "PWapi/partgm.h"

#include "bspartofcv.h"
#include "bscvtgeomcv.h"
#include "bsrev_cv.h"

#include "PWapi/samepts.h"
#include "PWapi/mdstptgm.h"
#include "PWapi/revgm.h"

/* Static Functions */

static void get_poly
(
  int num_pts,
  double *p_pts,
  struct PWcvparam *p_startpar,
  struct PWcvparam *p_stoppar,
  struct PWcvparam *p_midpar,
  PWboolean is_3d,
  double lentol,

  int *size,
  int *num_outpts,
  double *p_outpts
);


PWresult pwPartOfPy2d
(
  int num_pts,
  PWpoint2d *p_pts,
  struct PWcvparam *p_startpar,
  struct PWcvparam *p_stoppar,
  struct PWcvparam *p_midpar,

  double lentol,

  int *num_outpts,
  PWpoint2d *p_outpts
)
{
  PWboolean reverse=FALSE;

  if ((p_startpar->spaninx + p_startpar->spanpar) > 
      (p_stoppar->spaninx + p_stoppar->spanpar))
    reverse = TRUE;

  get_poly (num_pts, (double *) p_pts, reverse ? p_stoppar : p_startpar,
            reverse ? p_startpar : p_stoppar, p_midpar, FALSE, lentol, NULL, 
            num_outpts, (double *) p_outpts);

  if (reverse)
    pwRevPy2d (*num_outpts, p_outpts);

  return PW_K_Success;
}

PWresult pwPartOfPy 
(
  int num_pts,
  PWpoint *p_pts,
  struct PWcvparam *p_startpar,
  struct PWcvparam *p_stoppar,
  struct PWcvparam *p_midpar,

  double lentol,

  int *num_outpts,
  PWpoint *p_outpts
)
{
  PWboolean reverse=FALSE;

  if ((p_startpar->spaninx + p_startpar->spanpar) > 
      (p_stoppar->spaninx + p_stoppar->spanpar))
    reverse = TRUE;

  get_poly (num_pts, (double *) p_pts, reverse ? p_stoppar : p_startpar,
            reverse ? p_startpar : p_stoppar, p_midpar, TRUE, lentol, NULL, 
            num_outpts, (double *) p_outpts);

  if (reverse)
    pwRevPy (*num_outpts, p_outpts);

  return PW_K_Success;
}

PWresult pwPartOfCv
(
  struct IGRbsp_curve *p_cv,
  double startpar,
  double stoppar,
  double midpar,

  double lentol,

  struct IGRbsp_curve *p_outcv
)
{
  PWboolean BSsts=TRUE;
  BSrc BSmsg=BSSUCC;

  /* suppress the compiler warning */
  lentol = lentol;
 
  BSsts = BSpartofcv (&BSmsg, p_cv, startpar, midpar, stoppar, p_outcv);
  if (!BSERROR (BSmsg))
  {
    if (((startpar < stoppar) && !(midpar > startpar && midpar < stoppar)) ||
        ((startpar > stoppar) && (midpar > stoppar && midpar < startpar)))
    {
      BSrev_cv (&BSmsg, p_outcv);
    }
    return PW_K_Success;
  }
  else
  {
    return PW_K_Error;
  }
}

PWresult pwPartOfCvdata
(
  struct PWcvdata *p_cvdata,
  struct PWcvparam *p_startpar,
  struct PWcvparam *p_stoppar,
  struct PWcvparam *p_midpar,

  double lentol,

  struct PWcvdata *p_outcvdata
)
{
  PWresult PWsts=PW_K_Success;
  p_outcvdata->datatype = p_cvdata->datatype;

  switch (p_cvdata->datatype)
  {
    case PWcvdata_pt2d :
      memcpy (p_outcvdata->data.pt2d, p_cvdata->data.pt2d, sizeof (PWpoint2d)); 
      break;

    case PWcvdata_pt :
      memcpy (p_outcvdata->data.pt, p_cvdata->data.pt, sizeof (PWpoint)); 
      break;

    case PWcvdata_py2d :
      PWsts = pwPartOfPy2d (p_cvdata->data.py2d.num_pts, 
          p_cvdata->data.py2d.p_pts, p_startpar, p_stoppar, p_midpar, lentol,
          &p_outcvdata->data.py2d.num_pts, p_outcvdata->data.py2d.p_pts);
      break;

    case PWcvdata_py :
      PWsts =  pwPartOfPy (p_cvdata->data.py.num_pts, 
          p_cvdata->data.py.p_pts, p_startpar, p_stoppar, p_midpar, lentol,
          &p_outcvdata->data.py.num_pts, p_outcvdata->data.py.p_pts);
      break;

    case PWcvdata_bspcv :
      PWsts = pwPartOfCv (p_cvdata->data.p_bspcv, p_startpar->spanpar, 
                          p_stoppar->spanpar, p_midpar->spanpar, lentol,
                          p_outcvdata->data.p_bspcv);
      break;

    case PWcvdata_gmbspcv :
      PWsts = pwPartOfCv (p_cvdata->data.p_gmbspcv->bspcv, p_startpar->spanpar, 
        p_stoppar->spanpar, p_midpar->spanpar, lentol, 
        p_outcvdata->data.p_gmbspcv->bspcv);
      if (!IsError (PWsts))
      {
        BSrc BSmsg=BSSUCC;

        p_outcvdata->data.p_gmbspcv->type = 
           (p_cvdata->data.p_gmbspcv->bspcv->order == 3) ? BSCIRC_ARC : 
                                                          BSGEN_BSP_CV;
        BScvtgeomcv (p_outcvdata->data.p_gmbspcv, p_outcvdata->data.p_gmbspcv, 
                     &BSmsg);
      }
      break;

    default :
      PWsts = PW_K_Success;
      break;
  }

  return PWsts;
}

static void get_poly
(
  int num_pts,
  double *p_pts,
  struct PWcvparam *p_startpar,
  struct PWcvparam *p_stoppar,
  struct PWcvparam *p_midpar,
  PWboolean is_3d,
  double lentol,

  int *size,
  int *num_outpts,
  double *p_outpts
)
{
  int dim=0, knt=0, inx=0, num_spans=0;
  PWboolean is_closed=FALSE;
  double partol=0, dist=0, midpar=0;
  struct PWcvparam loc_startpar, loc_stoppar;
  PWboolean reverse=FALSE;

  dim = is_3d ? 3 : 2;
  is_closed = is_3d ? 
                 pwIsSamePt (&p_pts[0], &p_pts[(num_pts-1) * dim], lentol) :
                 pwIsSamePt2d (&p_pts[0], &p_pts[(num_pts-1) * dim], lentol);

  inx = p_startpar->spaninx;
  dist = is_3d ? pwDistPtPt (&p_pts[inx * dim], &p_pts[(inx+1) * dim]) :
                 pwDistPtPt2d (&p_pts[inx * dim], &p_pts[(inx+1) * dim]);
  partol = lentol / dist;
  if (fabs (p_startpar->spanpar - 1.0) < partol)
  {
    if (is_closed && p_startpar->spaninx == num_pts -1)
      loc_startpar.spaninx = 0;
    else
      loc_startpar.spaninx = p_startpar->spaninx + 1;
    loc_startpar.spanpar = 0.0;
  }
  else
  {
    memcpy (&loc_startpar, p_startpar, sizeof (struct PWcvparam));
  }

  inx = p_stoppar->spaninx;
  dist = is_3d ? pwDistPtPt (&p_pts[inx * dim], &p_pts[(inx+1) * dim]) :
                 pwDistPtPt2d (&p_pts[inx * dim], &p_pts[(inx+1) * dim]);
  partol = lentol / dist;
  if (fabs (p_stoppar->spanpar - 0.0) < partol)
  {
    if (is_closed && p_startpar->spaninx == 0)
      loc_stoppar.spaninx = num_pts - 1;
    else
      loc_stoppar.spaninx = p_stoppar->spaninx - 1;
    loc_stoppar.spanpar = 1.0;
  }
  else
  {
    memcpy (&loc_stoppar, p_stoppar, sizeof (struct PWcvparam));
  }

  midpar=0;
  midpar = p_midpar->spaninx + p_midpar->spanpar;

  if (is_closed && !(midpar > (loc_startpar.spaninx + loc_startpar.spanpar) &&
      midpar < (loc_stoppar.spaninx + loc_stoppar.spanpar)))
  {
    reverse = TRUE;
    num_spans = loc_startpar.spaninx + (num_pts - loc_stoppar.spaninx) + 1;  
  }
  else
  {
    num_spans = (loc_stoppar.spaninx - loc_startpar.spaninx) + 1;
  }     

  if (size) 
    *size = (num_spans + 1) * dim * sizeof (double);
 
  if (num_outpts)
    *num_outpts = num_spans + 1;

  if (p_outpts)
  {
    int inx1=0, inx2=0;
    PWpoint startpt, stoppt;

    inx1 = loc_startpar.spaninx;
    inx2 = loc_stoppar.spaninx;

    for (knt=0; knt<dim; knt++)
    {
      startpt[knt] = p_pts[inx1*dim + knt] + loc_startpar.spanpar * 
                       (p_pts[(inx1+1)*dim + knt] - p_pts[inx1*dim + knt]);
      stoppt[knt] = p_pts[inx2*dim + knt] + loc_stoppar.spanpar * 
                       (p_pts[(inx2+1)*dim + knt] - p_pts[inx2*dim + knt]);
    }

    memcpy (&p_outpts[0], startpt, dim * sizeof(double));
    memcpy (&p_outpts[num_spans * dim], stoppt, dim * sizeof(double));

    if (num_spans - 1)
    {
      if (is_closed && reverse)
      {
        for (knt=loc_startpar.spaninx, inx=1; knt >=0; knt--, inx++)
          memcpy (&p_outpts[inx * dim], &p_pts[knt * dim], 
                  dim * sizeof (double));
        for (knt=1; knt <= loc_stoppar.spaninx ; knt++, inx++)
          memcpy (&p_outpts[inx * dim], &p_pts[knt * dim], 
                  dim * sizeof (double));
      }
      else
      {
        memcpy (&p_outpts[dim], &p_pts[(loc_startpar.spaninx+1) * dim],
                (num_spans - 1) * dim * sizeof (double));
      }
    }
  }  
}
