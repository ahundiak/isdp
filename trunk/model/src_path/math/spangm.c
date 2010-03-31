
/* Includes */

#include <math.h>                   /* System Include Stuff */
#include <memory.h>
#include <malloc.h>

#include "bsvalues.h"
#include "igrtypedef.h"
#include "igr.h"        /* BS Include Stuff */
#include "bs.h"
#include "bsparameters.h"
#include "bserr.h"
#include "bsgeom_cvsf.h"
#include "bsalloccv.h"

#include "PWminimum.h"              
#include "PWerror.h"                /* Pathway Include Stuff */
#include "PWgmdata.h"

/* Prototypes */

#include "bsextrcvspn.h"
#include "PWapi/samepts.h"

/* Internal Prototypes */

static PWboolean get_poly_span
(
  int        numpts,
  double     *p_pts,
  PWboolean  is_3d,
  int        spaninx,
  PWboolean  nodegen,
  PWboolean  forward,
  double     lentol,
  double     *p_outpts
);

/*
  DESCRIPTION

    Given the curve data and span index it extracts a span of the curve and
    reutrns it. 

  NOTES

    If the memory is not allocted by the caller, he should make all the po-
    inters of the strucutre (PWcvdata p_span) to point to NULL and call it.
    If the memory pointers points to NULL, memory will be allocated by this
    routine.
*/    

PWresult pwGetSpanCvdata
(
  struct PWcvdata *p_cvdata,
  int             spaninx,
  struct PWcvdata *p_span
)
{
  PWresult  PWsts=PW_K_Success;

  p_span->datatype = p_cvdata->datatype;

  switch (p_cvdata->datatype)
  {
    case PWcvdata_pt2d :
      memcpy (p_span->data.pt2d, p_cvdata->data.pt2d, sizeof (PWpoint2d)); 
      break;

    case PWcvdata_pt :
      memcpy (p_span->data.pt, p_cvdata->data.pt, sizeof (PWpoint)); 
      break;

    case PWcvdata_py2d :
      OnErrorState (spaninx > p_span->data.py2d.num_pts - 2, PWsts, 
                    SetError (PW_K_PathwayMath, PW_K_InvalidArg), wrapup); 
      p_span->data.py2d.num_pts = 2;
      if (!p_span->data.py2d.p_pts)
        p_span->data.py2d.p_pts = (PWpoint2d *) malloc (2 * sizeof (PWpoint2d));

      get_poly_span (p_cvdata->data.py2d.num_pts, 
                     (double *) p_cvdata->data.py2d.p_pts,
                     FALSE, spaninx, FALSE, FALSE, 0, 
                     (double *) p_span->data.py2d.p_pts);
      break;

    case PWcvdata_py :
      OnErrorState (spaninx > p_span->data.py.num_pts - 2, PWsts, 
                    SetError (PW_K_PathwayMath, PW_K_InvalidArg), wrapup); 
      p_span->data.py.num_pts = 2;
      if (!p_span->data.py.p_pts)
        p_span->data.py.p_pts = (PWpoint *) malloc (2 * sizeof (PWpoint));

      get_poly_span (p_cvdata->data.py.num_pts, 
                     (double *) p_cvdata->data.py.p_pts,
                     TRUE, spaninx, FALSE, FALSE, 0, 
                     (double *) p_span->data.py.p_pts);  
      break;

    case PWcvdata_bspcv :
    {
      BSrc        rc=BSSUCC;
      IGRboolean  BSsts=TRUE, planar=FALSE, closure=TRUE;
      struct IGRbsp_curve *p_cv;

      p_cv = p_cvdata->data.p_bspcv ; 
      if (!p_span->data.p_bspcv)
      {
        BSalloccv (p_cv->order, p_cv->num_poles, p_cv->rational, 0, 
                   &p_span->data.p_bspcv, &rc); 
        OnErrorState (BSERROR (rc), PWsts, SetError (PW_K_BspMath,
                      PW_K_DynamicMemory), wrapup); 
      }

      BSsts = BSextrcvspn (&rc, &spaninx, p_cv, p_span->data.p_bspcv, &planar, 
                           &closure);  
      OnErrorState (!BSsts || BSERROR (rc), PWsts, SetError (PW_K_BspMath,
                    PW_K_Internal), wrapup); 

    }
    break; 
            
    case PWcvdata_gmbspcv :
    {
      BSrc        rc=BSSUCC;
      IGRboolean  BSsts=TRUE, planar=FALSE, closure=TRUE;
      struct IGRbsp_curve *p_cv;

      p_cv = p_cvdata->data.p_gmbspcv->bspcv; 
      if (!p_span->data.p_gmbspcv)
      {
        p_span->data.p_gmbspcv = (struct BSgeom_bsp_curve *) malloc (
                                         sizeof (struct BSgeom_bsp_curve));
        BSalloccv (p_cv->order, p_cv->num_poles, p_cv->rational, 0, 
                   &p_span->data.p_gmbspcv->bspcv, &rc); 
        OnErrorState (BSERROR (rc), PWsts, SetError (PW_K_BspMath,
                      PW_K_Internal), wrapup); 
      }

      BSsts = BSextrcvspn (&rc, &spaninx, p_cv, p_span->data.p_gmbspcv->bspcv, 
                           &planar, &closure);  
      OnErrorState (!BSsts || BSERROR (rc), PWsts, SetError (PW_K_BspMath,
                    PW_K_Internal), wrapup); 

    }
    break; 

    default :
      
      PWsts = SetError (PW_K_PathwayMath, PW_K_Internal);
      break;
  }

wrapup :

  PW_Wrapup (PWsts, "pwGetSpanCvdata");
  return PWsts;
}

/*
  DESCRIPTION

    Given the poly data and span index it extracts the span of the polyline
    which is non-degenerate and returns it. If no  non-degenerate  span  is 
    found in the forward direction then it returns failure  and  the  first  
    span will be returned.

  NOTES

    If the incoming span is a degenerate one then the stop point point will
    be shifted to adjacent span by keeping the start of the given span alw-   
    ays same. Two seperate functions exists to deal with 2D and 3D.
*/

PWboolean pwGetNonDegenSpanPy
(
  struct PWpoly *p_py,
  int           spaninx,
  double        lentol,
  PWpoint       outpts[2]
)
{
  return (get_poly_span (p_py->num_pts, (double *) p_py->p_pts, TRUE, spaninx, 
                         TRUE, TRUE, lentol, (double *) outpts)); 
}

PWboolean pwGetNonDegenSpanPy2d
(
  struct PWpoly2d *p_py,
  int             spaninx,
  double          lentol,
  PWpoint2d       outpts[2]
)
{
  return (get_poly_span (p_py->num_pts, (double *) p_py->p_pts, FALSE, spaninx, 
                         TRUE, TRUE, lentol, (double *) outpts));
}

static PWboolean get_poly_span
(
  int        numpts,
  double     *p_pts,
  PWboolean  is_3d,
  int        spaninx,
  PWboolean  nodegen,
  PWboolean  forward, /* only in the forward direction */
  double     lentol,
  double     *p_outpts
)
{
  int        dim=0, inx=0, size, incr=0;
  PWboolean  middle=FALSE;

  dim    = is_3d ? 3 : 2;
  inx    = spaninx;
  size   = dim * sizeof(double);
  incr   = (spaninx == numpts-2) ? -1 : 1;
  middle = (spaninx == 0 || spaninx == numpts-2) ? FALSE : TRUE;

  memcpy (&p_outpts[0], &p_pts[inx*dim], 2 * size);
 
  while (nodegen)
  {
    if (is_3d ? !pwIsSamePt (&p_outpts[0], &p_outpts[dim], lentol) : 
                !pwIsSamePt2d (&p_outpts[0], &p_outpts[dim], lentol))
      return TRUE; 

    inx += incr;

    if (inx < 0 || inx > (numpts - 2)) 
    {
      if (middle && !forward)
      {
        middle = FALSE;
        inx  = spaninx;
        incr = -1;
        memcpy (&p_outpts[0], &p_pts[(inx-1) * dim], 2 * size);
      }
      else 
        return FALSE;
    }

    if (incr < 0)
      memcpy (&p_outpts[0], &p_pts[inx*dim], size);
    else
      memcpy (&p_outpts[dim], &p_pts[(inx+1)*dim], size);
  }

  if (nodegen)
  {
    memcpy (&p_outpts[0], &p_pts[inx*dim], 2 * size);
    return FALSE;
  }
  else 
    return TRUE;
}
