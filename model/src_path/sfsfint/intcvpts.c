#include <stdio.h>
#include <math.h>
#include <alloca.h>

#include "igrtypedef.h"
#include "igr.h"
#include "bs.h"
#include "bsparameters.h"
#include "bserr.h"
#include "bscveval.h"                  /* BS includes */
#include "bserr.h"
#include "bsgeom_cvsf.h"

#include "PWminimum.h"
#include "PWgmdata.h"
#include "PWerror.h"



PWresult pwGetInternalCvPts
(
  struct PWcvdata     *p_cv,
  int                 numpts,
  enum PWtopopostype  topopos,
  struct PWcvpt       *p_internalpts
)
{
  PWresult              retval;
  short                 dim, order;
  int                   i, j, inx=0, num_points=0;
  int                   blksize=0, tmp_numpts=0;
  long                  rc;
  double                *points=NULL, *knots=NULL, *val=NULL;
  double                delta, initval, param;
  struct IGRbsp_curve   *curve=NULL;

  retval = PW_K_Success;

  switch (p_cv->datatype)
  {
    case PWcvdata_pt2d:
    case PWcvdata_pt:
      points = (p_cv->datatype == PWcvdata_pt2d)? p_cv->data.pt2d : 
                                                  p_cv->data.pt;
      dim = (p_cv->datatype == PWcvdata_pt2d)? 2 : 3;
      blksize = dim * sizeof (double);
      
      /*
       * If the number of output point requested by the user is more
       * than one then make each of the points to be equal to the cvdata
       * point.
       */
      for (i=0; i<numpts; i++)
      {
        memcpy (p_internalpts[i].pt, points, blksize);
        if (p_cv->datatype == PWcvdata_pt2d)
          p_internalpts[i].pt[2] = 0.0;

        p_internalpts[i].cvid = PW_K_NullObjid;

        p_internalpts[i].cvparam.spaninx = 0;
        if (topopos == PWtopopos_start)
          p_internalpts[i].cvparam.spanpar = 0.0;
        else if (topopos == PWtopopos_stop)
          p_internalpts[i].cvparam.spanpar = 1.0;
        else
          p_internalpts[i].cvparam.spanpar = 0.5;
        pwSetTopoposCvpt (p_internalpts, topopos);

        break;
      }/* for number of input points */

    case PWcvdata_py2d:
    case PWcvdata_py:
      num_points = (p_cv->datatype == PWcvdata_py2d)? p_cv->data.py2d.num_pts :
                                                      p_cv->data.py.num_pts ;
      points = (p_cv->datatype == PWcvdata_py2d)? 
                                  (double *) p_cv->data.py2d.p_pts :
                                  (double *) p_cv->data.py.p_pts;
      dim = (p_cv->datatype == PWcvdata_py2d)? 2 : 3;
      blksize = dim*sizeof (double);
      if (topopos == PWtopopos_start)
      {
        /*
         * If user has asked for more than one start point then return 
         * all the points initialized to the start point.
         */
        for (i=0; i<numpts; i++)
        {
          memcpy (p_internalpts[i].pt, points, blksize);
          if (p_cv->datatype == PWcvdata_py2d)
          {
            p_internalpts[i].pt[2] = 0.0;
          }
          p_internalpts[i].cvparam.spaninx = 0;
          p_internalpts[i].cvparam.spanpar = 0.0;
          pwSetTopoposCvpt (&p_internalpts[i], topopos);
          p_internalpts[i].cvid = PW_K_NullObjid; 
        }
      }
      else if (topopos == PWtopopos_middle)
      {
        /*
         * Multiply 'delta' with a magic number '0.9' so that the internal
         *  point generated does not fall at the start/end of any of the 
         * polyline spans.
         */
        delta = 0.9*(double)(num_points - 1)/(double)(numpts + 1);
        for (i=1; i<(numpts + 1); i++)
        {
          inx = i*delta;
          param = i*delta - inx;
          inx *= dim;
          for (j=0; j<dim; j++)
          {
            p_internalpts[i-1].pt[j] = points[inx+j] + param * 
                                       (points[inx+j+dim] - points[inx+j]);
            if (p_cv->datatype == PWcvdata_py2d)
            {
              p_internalpts[0].pt[2] = 0.0;
            }
            p_internalpts[i-1].cvparam.spaninx = inx/dim;
            p_internalpts[i-1].cvparam.spanpar = param;
            pwSetTopoposCvpt (&p_internalpts[i-1], topopos);
            p_internalpts[i-1].cvid = PW_K_NullObjid;
          }
        }
      }
      else if (topopos == PWtopopos_stop)
      {
        for (i=0; i<numpts; i++)
        {
          memcpy (p_internalpts[i].pt, &points[(num_points-1)*dim], blksize);
          if (p_cv->datatype == PWcvdata_py2d)
          {
            p_internalpts[i].pt[2] = 0.0;
          }
          p_internalpts[i].cvparam.spaninx = num_points - 2;
          p_internalpts[i].cvparam.spanpar = 1.0;
          pwSetTopoposCvpt (&p_internalpts[i], topopos);
          p_internalpts[i].cvid = PW_K_NullObjid;
        }
      }
      else
      {
        OnErrorState (TRUE, retval,
                      SetError (PW_K_Pathway, PW_K_InvalidArg), wrapup);
      }     
      break;

    case PWcvdata_bspcv:
    case PWcvdata_gmbspcv:
      if (p_cv->datatype == PWcvdata_bspcv)
      {
        curve = p_cv->data.p_bspcv;
      }
      else 
      {
        curve = p_cv->data.p_gmbspcv->bspcv;
      }
      num_points = curve->num_poles;
      knots = curve->knots;
      order = curve->order;
      val = alloca (numpts * sizeof(double));
      OnErrorState (!val, retval,
                    SetError (PW_K_Pathway, PW_K_Internal), wrapup); 

      if (topopos == PWtopopos_start)
      {
        tmp_numpts = 1;
        val[0] = knots[order-1];
      }
      else if (topopos == PWtopopos_middle)
      {
        tmp_numpts = numpts;
        delta = (knots[num_points] - knots[order-1])/(numpts + 1);
        initval = knots[order-1];
        for (i=0; i<numpts; i++)
        {
          val[i] = initval + (i+1) * delta;
          p_internalpts[i].cvparam.spaninx = 0;
          p_internalpts[i].cvparam.spanpar = val[i];
          pwSetTopoposCvpt (&p_internalpts[i], topopos);
          p_internalpts[i].cvid = PW_K_NullObjid;
        }
      }
      else if (topopos == PWtopopos_stop)
      {
        tmp_numpts = 1;
        val[0] = knots[num_points];
      }
      else
      {
        OnErrorState (TRUE, retval,
                      SetError (PW_K_Pathway, PW_K_InvalidArg), wrapup);
      }
      for (i=0; i<tmp_numpts; i++)
      {
        BScveval (curve, val[i], 0, (IGRpoint *)p_internalpts[i].pt, &rc);
        OnErrorState (rc != BSSUCC, retval,
                      SetError (PW_K_BspMath, PW_K_Internal), wrapup);
      }
      /*
       * If the user wants more than one point at the start or stop position
       * then fill each of the input points with the start/stop point.
       */
      if (topopos == PWtopopos_start || topopos == PWtopopos_stop)
      {
        for (i=0; i<numpts; i++)
        {
          p_internalpts[i].cvparam.spaninx = 0;
          p_internalpts[i].cvparam.spanpar = val[0];
          memcpy(p_internalpts[i].pt, p_internalpts[0].pt, 3*sizeof(double));
          pwSetTopoposCvpt (&p_internalpts[i], topopos);
          p_internalpts[i].cvid = PW_K_NullObjid;
        }
      }
        
       
      break;

    default:
      break;
  }/* end of switch */
  wrapup:
  return (retval);
}
  
