#include<stdio.h>
#include<math.h>

#include "PWminimum.h"
#include "PWattrib.h"
#include "PWattribid.h"
#include "PWgmdata.h"
#include "PWerror.h"

#include <OMminimum.h>
#include "bs.h"
#include "bserr.h"
#include "bsparameters.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"
#include "emssfintdef.h"
#include "emsinterdef.h"
#include "emsdattyp.h"
#include "emsinter.h"

#include "PWapi/sfgeom.h"
#include "PWapi/cvgeom.h"
#include "PWapi/mdstptgm.h"

#include "bsmkvec.h"
#include "bschgdeppar.h"
#include "bsmdistptcv.h"
#include "bscvkttol2.h"
#include "bscveval.h"

PWresult    pwGetXyzTanAtIntPt
(
  short                  mattyp,
  PWmatrix               mat,
  struct EMSdataselect   *ingeom,
  PWpoint                inpt,
  double                 xyztol,
  struct PWcvpt          *projpt,
  PWvector               tanvec
)
{
  PWresult               retval=PW_K_Success;
  long                   rc=BSSUCC;
  int                    ptinx=0;
  IGRshort               no_intervals=0, no_params=0;
  PWboolean              set_basistol=FALSE;
  double                 *projected_params=NULL, *interval_params=NULL, 
                         *param=NULL, basis_tol=0 , knot_tol, startknot, 
                         mindist=0, stopknot=0, eval[6];
  struct EMSdataselect   sampledata;
  enum EMSdatatype       dattyp=EMSdata_null;
  union EMSdata          dat;
  struct IGRbsp_curve    *curve3d=NULL;

  memset (&sampledata, 0, sizeof (struct EMSdataselect));
  dattyp = ingeom->datatype;
  dat    = ingeom->data;

  switch (dattyp)
  {
    case EMSdata_poly3d:
    {
      /*
       *  Obtain the projected point corresponding to the input point.
       */
      mindist = pwMinDistSqPtPy (inpt, dat.poly->num_points, 
                                 (PWpoint *)dat.poly->points,
                                 projpt->pt, &(projpt->cvparam));
      /* 
       * Set input cvpt topopos field
       */
      pwSetTopoposCvpt (projpt, PWtopopos_middle);
      if (projpt->cvparam.spaninx == 0 && projpt->cvparam.spanpar==0.0)
        pwSetTopoposCvpt (projpt, PWtopopos_start);

      ptinx = (projpt->cvparam.spaninx + 1)*3;
      if (projpt->cvparam.spanpar == 1.0)
        ptinx += 3;

      if (ptinx == 3*(dat.poly->num_points))
      {
        ptinx -= 3;
        pwSetTopoposCvpt (projpt, PWtopopos_stop);
      }

      /*
       *  Make the output tangent vector taking the span end points
       */
      BSmkvec (&rc, tanvec, &(dat.poly->points[ptinx-3]),
               &(dat.poly->points[ptinx]));
      OnErrorState (rc != BSSUCC, retval,
                    SetError (PW_K_BspMath, PW_K_Internal), wrapup);
    }
    break;

    case EMSdata_curve3d:
    {
      curve3d = dat.curve;
      startknot = curve3d->knots[curve3d->order-1];
      stopknot = curve3d->knots[curve3d->num_poles];

      /* 
       * Extract the basis tol for resetting later.
       */
      BSEXTRACTPAR (&rc, BSTOLBASIS, basis_tol);

      /* 
       * Change the basis tol
       */
      if (xyztol > (stopknot-startknot))
        BSchgdeppar ((stopknot-startknot), &rc);
      else
        BSchgdeppar (xyztol, &rc);

      set_basistol = TRUE;

      /* 
       * Get the knottol to be used during end pt snapping
       */
      BScvkttol2 (curve3d->order, curve3d->knots, curve3d->num_poles,
                  curve3d->poles, curve3d->weights, &knot_tol, &rc );
      OnErrorState (rc != BSSUCC, retval,
                    SetError (PW_K_BspMath, PW_K_Internal), wrapup);

      /* 
       * Get the projection point corresponding to the input point
       */
      BSmdistptcv (dat.curve, inpt, &no_intervals, &no_params,
                   &projected_params, &mindist, &interval_params, &rc);
      OnErrorState (rc != BSSUCC, retval,
                    SetError( PW_K_BspMath, PW_K_Internal), wrapup);

      /*
       * If the projected parameter is very close to the boundary we snap
       * it to the boundary to prevent curve evaluation from barfing.
       */
      if (no_params)
        param = projected_params;
      else if (no_intervals)
        param = interval_params;
      else
      {
        retval = SetError (PW_K_Pathway, PW_K_Internal);
        goto wrapup;
      }

      if (fabs (*param - startknot) <= knot_tol)
      {
        *param = startknot;
        pwSetTopoposCvpt (projpt, PWtopopos_start);
      }
      else if (fabs (*param - stopknot) <= knot_tol)
      {
        *param = stopknot;
        pwSetTopoposCvpt (projpt, PWtopopos_stop);
      }
      else
        pwSetTopoposCvpt (projpt, PWtopopos_middle);

      /* 
       * Get the curve tangent at the projected point
       */
      BScveval (curve3d, *param, 1, (IGRpoint *)eval, &rc);
      OnErrorState (rc != BSSUCC, retval,
                    SetError (PW_K_BspMath, PW_K_Internal), wrapup);

      memcpy (projpt->pt, eval, 3*sizeof(double));
      memcpy (tanvec, &eval[3], 3*sizeof(double));
      projpt->cvparam.spaninx = 0;
      projpt->cvparam.spanpar = *param;
    }
    break;
 
    case EMSdata_object:
    {
      retval = PW_GetCvBspcvStack (dat.object->objid, dat.object->osnum, 
                mattyp, mat, sampledata.data.curve);
      OnErrorCode (retval, wrapup);
      sampledata.datatype = EMSdata_curve3d;

      retval =  pwGetXyzTanAtIntPt (mattyp, mat, &sampledata, inpt, xyztol,
                                    projpt, tanvec);
      OnErrorCode (retval, wrapup);
    } 
    break;

  }

wrapup:

  if (set_basistol)
    BSchgdeppar (basis_tol, &rc);
  if (projected_params)
    free (projected_params);
  if (interval_params)
    free (interval_params);
      
  return retval;

}/* end of function pwGetXyzTanAtIntPt */

