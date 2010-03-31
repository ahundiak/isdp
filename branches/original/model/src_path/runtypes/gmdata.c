/*
  OVERVIEW

  This file contains the memory management related functions that operate
  on the standard geometry types (eg: PWcvpt, PWcvdata, PWsfdata, etc)
*/

#include "igrtypedef.h"
#include "igr.h"

#include "bserr.h"
#include "bsparameters.h"
#include "bsgeom_cvsf.h"
#include "prototypes/bsfreecv.h"

#include "PWminimum.h"
#include "PWerror.h"
#include "PWgmdata.h"
#include "PWapi/mdstptgm.h"

static void cnvt_py_to_cv
(
  int                 num_pts,
  double              *p_pts,
  int                 dim,
  double              tol,
  struct IGRbsp_curve *p_cv
);

/*
   DESCRIPTION

   The following functions initialize the fields of the corresponding 
   structures. Not all structures are amenable to being initialized as they
   have deep nestings or are simply contain pointers that need to be 
   initailized by making other function calls.
*/     

void pwInitCvpt (cvpt, topopos, pt, ptdim, spaninx, spanpar, cvid)
struct PWcvpt *cvpt;
enum PWtopopostype topopos;
double *pt;
int ptdim, spaninx;
double spanpar;
PWobjid cvid;
{
  double *p;

  pwSetTopoposCvpt (cvpt, topopos);
  p = (double *) cvpt->pt;
  p[X] = p[Y] = p[Z] = 0.0;
  memcpy (p, pt, ptdim * sizeof (double));
  cvpt->cvparam.spaninx = spaninx;
  cvpt->cvparam.spanpar = spanpar;
  cvpt->cvid = cvid;

  return;
}


/*
 * Functions Associated with PWcvpt props field.
 *     Following are the properties which can be set on a PWcvpt :
 *  	   PW_TOPOPOS_START    |
 *         PW_TOPOPOS_STOP     |    
 *         PW_TOPOPOS_MIDDLE   |     2 bits
 *         PW_TOPOPOS_UNKNOWN  | 
 *     
 *     These properties requires 2 bits and are stored in the two
 *     right most bits of the properties word.
 */

#define  CVPT_P_TOPOPOS   1  /* position of the topopos bits in the properties 
                                word */

#define  CVPT_N_TOPOPOS   2  /* Number of bits the toppos property requires */


/*
 * Set the TOPOPOS Property
 */

void pwSetTopoposCvpt
( 
  struct PWcvpt         *p_cvpt,
  enum   PWtopopostype  topopos
)
{
  if( topopos == PWtopopos_start )
    pwSetBits(&p_cvpt->props, CVPT_P_TOPOPOS, CVPT_N_TOPOPOS, 
              PW_TOPOPOS_START);  
  else if( topopos == PWtopopos_stop )
     pwSetBits(&p_cvpt->props, CVPT_P_TOPOPOS, CVPT_N_TOPOPOS, 
              PW_TOPOPOS_STOP);  
  else if( topopos == PWtopopos_middle )
    pwSetBits(&p_cvpt->props, CVPT_P_TOPOPOS, CVPT_N_TOPOPOS, 
              PW_TOPOPOS_MIDDLE);  
  else 
    pwSetBits(&p_cvpt->props, CVPT_P_TOPOPOS, CVPT_N_TOPOPOS, 
              PW_TOPOPOS_UNKNOWN);  
}


/*
 * Get the TOPOPOS Property
 */

enum PWtopopostype pwGetTopoposCvpt
(
  struct PWcvpt  *p_cvpt
)
{
  unsigned int props;

  props = pwGetBits(p_cvpt->props, CVPT_P_TOPOPOS, CVPT_N_TOPOPOS);

  if( props == PW_TOPOPOS_START )
    return (enum PWtopopostype) PWtopopos_start;
  else if( props == PW_TOPOPOS_STOP )
    return (enum PWtopopostype) PWtopopos_stop;
  else if( props == PW_TOPOPOS_MIDDLE )
    return (enum PWtopopostype) PWtopopos_middle;
  else 
    return (enum PWtopopostype) PWtopopos_unknown;
}


void pwFreeCvdataGeom
(
  struct PWcvdata *cvdata
)
{
  long bsrc;

  switch (cvdata->datatype)
  {
    case PWcvdata_py2d:
      if (cvdata->data.py2d.p_pts)
      {
        free (cvdata->data.py2d.p_pts);
        cvdata->data.py2d.p_pts = NULL;
      }
      break;
 
    case PWcvdata_py:
      if (cvdata->data.py.p_pts)
      {
        free (cvdata->data.py.p_pts);
        cvdata->data.py.p_pts = NULL;
      }
      break;

    case PWcvdata_bspcv:
      if (cvdata->data.p_bspcv)
      {
        BSfreecv (&bsrc, cvdata->data.p_bspcv);
        cvdata->data.p_bspcv = NULL;
      }
      break;

    case PWcvdata_gmbspcv:
      if (cvdata->data.p_gmbspcv)
      {
        if (cvdata->data.p_gmbspcv->bspcv)
        {
          BSfreecv (&bsrc, cvdata->data.p_gmbspcv->bspcv);
          cvdata->data.p_gmbspcv->bspcv = NULL;
        }
        if (cvdata->data.p_gmbspcv->array1)
        {
          free (cvdata->data.p_gmbspcv->array1);
          cvdata->data.p_gmbspcv->array1 = NULL;
        }
        free (cvdata->data.p_gmbspcv);
        cvdata->data.p_gmbspcv = NULL;
      }
      break;
  }
  return;
}


/*
  DESCRIPTION

  The following functions converts a poly line into B-spline curve of order 
  two. 
*/

void pwCnvtPyToCv
(
  struct PWpoly       *p_py,
  double              tol,
  struct IGRbsp_curve *p_cv
)
{
  cnvt_py_to_cv (p_py->num_pts, (double *)p_py->p_pts, 3, tol, p_cv);
}

void pwCnvtPy2dToCv
(
  struct PWpoly2d     *p_py,
  double              tol,
  struct IGRbsp_curve *p_cv
)
{
  cnvt_py_to_cv (p_py->num_pts, (double *)p_py->p_pts, 2, tol, p_cv);
}


/*------------------- STATIC FUNCTIONS ------------------------------------*/

static void cnvt_py_to_cv
(
  int                 num_pts,
  double              *p_pts,
  int                 dim,
  double              tol,
  struct IGRbsp_curve *p_cv
)
{
  int     i, j;
  double  step;

  p_cv->rational = FALSE;
  p_cv->periodic = FALSE;
  p_cv->non_uniform = FALSE;

  p_cv->num_boundaries = 0;
  p_cv->bdrys = 0;

  p_cv->planar = TRUE;

  p_cv->num_poles = num_pts;
  p_cv->order = 2;
  p_cv->num_knots = num_pts + 2;
  p_cv->weights = NULL;

  for (i=0; i<num_pts; i++)
    for (j=0; j<dim; j++)
      p_cv->poles[i*3 + j] = p_pts [i*dim + j];

  if (dim == 2)
  {
    for (i=0; i<num_pts; i++)
      p_cv->poles[i*3 + 2] = 0;
  }

  step = 1.0 / (num_pts-1);

  for (i=0; i<2; i++)
    p_cv->knots[i] = 0.0;

  for (i=2; i<num_pts; i++)
    p_cv->knots[i] = p_cv->knots[i-1] + step;

  for (i=num_pts; i<num_pts+2; i++)
    p_cv->knots[i] = 1.0;

  if (pwDistSqPtPt2d (&p_pts[0], &p_pts[(num_pts - 1) * dim]) < tol * tol)
    p_cv->phy_closed = TRUE;
  else
    p_cv->phy_closed = FALSE;

  return;
}

