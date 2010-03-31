/*
  OVERVIEW

  This file contains external APIs to query the properties of parametric 
  space curves on a surface. Useful for setting properties on edge objects.

  NOTES

  HISTORY

  Sanjay     09/10/95      Original Creation
  Aditya     10/14/96      Created the wrapper function to expose this as
                           an API and moved it from its original location
                           in src_path/map/mapcvonsf.c.
*/

/* Includes */

#include <stdio.h>
#include <math.h>
#include <memory.h>         /* System */
#include <bsvalues.h> 

#include "igrtypedef.h"
#include "igr.h"        
#include "bs.h"
#include "bsparameters.h"   /* BS math */
#include "bsgeom_cvsf.h"
#include "bsvalues.h"

#include "emsedgedef.h"
#include "EMSprop.h"        /* MODEL */

#include "PWminimum.h"
#include "PWgmdata.h"       /* Pathway */
#include "PWerror.h"

/* Prototypes */

#include "bssfeval.h"

#include "PWapi/samepts.h"    
#include "PWapi/mdstptgm.h"
#include "PWapi/partol.h"
#include "PWapi/ptpargm.h"
#include "PWapi/edtype.h"
#include "PWapi/isopts.h"   /* Pathway */

static void get_mapped_curve_props
(
  struct PWcvdata *p_uvcv,
  struct IGRbsp_surface *p_sfgeom,
  double xyztol,
  double uvtol,

  int    *props
);

/*
  ABSTRACT
  This function will evaluate the input parametric space curve with respect
  to the input surface and return its properties. Typically these properties
  will inform whether the curve is closed in uv & xyz, degeneracy,
  iso-parametric orientation, alignment with seam etc. Checks are made with
  respect to the xyz and parametric tolerances provided by the caller.

  NOTES

  The caller should ensure that the input curve is a parametric curve and
  that the surface geometry is the one on which the curve lies.
  Memory for the props should be provided by the caller.
  These properties are defined in "$MODEL/include/EMSprop.h".

*/

PWresult pwGetUvCvdataProps
(
  struct PWcvdata *p_uvcv,
  struct IGRbsp_surface *p_sfgeom,
  double xyztol,
  double uvtol,
  int    *props
)
{
  PWresult PWsts=PW_K_Success;

  OnErrorState( !p_uvcv || p_uvcv->datatype == PWcvdata_null || !p_sfgeom || 
                !props, PWsts, SetError(PW_K_Pathway, PW_K_InvalidArg), wrapup);

  get_mapped_curve_props ( p_uvcv, p_sfgeom, xyztol, uvtol, props);

wrapup:

  PW_Wrapup (PWsts, "pwGetUvCvdataProps");
  return(PWsts);
}


/* ---------------------------- Static Functions ---------------------------- */


/*
  ABSTRACT

  Gets the mapped curve properties.

  NOTES

  These properties are defined in "$MODEL/include/EMSprop.h".

*/

static void get_mapped_curve_props
(
  struct PWcvdata *p_uvcv,
  struct IGRbsp_surface *p_sfgeom,
  double xyztol,
  double uvtol,

  int    *props
)
{
  PWresult PWsts=PW_K_Success;
  BSrc BSmsg=BSSUCC;
  double u_min=0, v_min=0, u_max=0, v_max=0;

  *props = 0;

  u_min = p_sfgeom->u_knots [p_sfgeom->u_order-1];
  v_min = p_sfgeom->v_knots [p_sfgeom->v_order-1];
  u_max = p_sfgeom->u_knots [p_sfgeom->u_num_poles];
  v_max = p_sfgeom->v_knots [p_sfgeom->v_num_poles];

  switch (p_uvcv->datatype)
   {
    case PWcvdata_pt2d :
      *props |= EMED_DEGENERATE;
      *props |= EMED_XYZ_CLOSED;
    break;

    case PWcvdata_py2d :
    {
      int isodir=0;
      struct PWpoly2d *p_py=NULL;

      p_py = &p_uvcv->data.py2d;

      /*
       * added so that for those which lie on the natural boundary
       * we can knock of the points if the num of points is greater
       * than 2
       */
      if (pwIsUvPtsIso (p_py->num_pts, p_py->p_pts, uvtol, &isodir))
      {
        if(p_py->num_pts > 2)
        {
          if ((isodir == U) ?
               (fabs (p_py->p_pts[0][U] - u_min) <= MINDOUBLE ||
               fabs (u_max - p_py->p_pts[0][U]) <= MINDOUBLE) :
               (fabs (p_py->p_pts[0][V] - v_min) <= MINDOUBLE ||
               fabs (v_max - p_py->p_pts[0][V]) <= MINDOUBLE))
          {
            *props |= EMED_NATURAL;
            memcpy(&p_py->p_pts[1],&p_py->p_pts[p_py->num_pts-1],
                   sizeof(PWpoint2d));
            p_py->num_pts = 2;
          }
        }
      }

      /*
       * replacing MINDOUBLE with uvtol
       */
      if (p_py->num_pts == 2 &&
          pwIsUvPtsIso (2, p_py->p_pts, uvtol, &isodir))
      {
        *props |= EMED_ISO;

        if ((isodir == U) ?
              (fabs (p_py->p_pts[0][U] - u_min) <= MINDOUBLE ||
               fabs (u_max - p_py->p_pts[0][U]) <= MINDOUBLE) :
              (fabs (p_py->p_pts[0][V] - v_min) <= MINDOUBLE ||
               fabs (v_max - p_py->p_pts[0][V]) <= MINDOUBLE))
        {
          *props |= EMED_NATURAL;
        }

        if (p_sfgeom->u_phy_closed && isodir == U)
        {
          if ((p_py->p_pts[0][U] - u_min) <= MINDOUBLE ||
              (u_max - p_py->p_pts[0][U]) <= MINDOUBLE)
            *props |= EMED_SEAM;
        }
        else if (p_sfgeom->v_phy_closed && isodir == V)
        {
          if ((p_py->p_pts[0][V] - v_min) <= MINDOUBLE ||
              (v_max - p_py->p_pts[0][V]) <= MINDOUBLE)
            *props |= EMED_SEAM;
        }
      }

      if (!pwIsSamePt2d (p_py->p_pts[0],
                         p_py->p_pts[ p_py->num_pts-1],
                         uvtol))
      {
        *props |= EMED_OPEN;
      }
      else
      {
        if (p_py->num_pts == 2)
        {
          *props |= EMED_DEGENERATE;
        }
        /***
        *props |= EMED_XYZ_CLOSED;
        ***/
      }
    }
    break;

    case PWcvdata_bspcv :
	 case PWcvdata_gmbspcv :
    {
      struct IGRbsp_curve *p_cv=NULL;

      p_cv = p_uvcv->datatype == PWcvdata_bspcv ? p_uvcv->data.p_bspcv :
                                          p_uvcv->data.p_gmbspcv->bspcv;
      if (p_cv->num_poles == 2)
      {
         if (pwIsSamePt2d (&(p_cv->poles[0]), &(p_cv->poles[3]), uvtol))
           *props |= EMED_DEGENERATE;
      }
      if (p_cv->phy_closed)
        *props |= EMED_XYZ_CLOSED;
      else
        *props |= EMED_OPEN;
    }
    break;

    default :
    break;
  }

  /* if (!((*props) & EMED_XYZ_CLOSED)) */
  /*
   * Tip of a cone is both EMED_XYZ_CLOSED and EMED_DEGENERATE
   */

  {
    PWpoint start_uvpt, stop_uvpt, start_xyzpt, stop_xyzpt;
    struct PWcvparam param;
    PWpoint  mid_uvpt, mid_xyzpt;
    memset (&param, 0, sizeof (struct PWcvparam));

    pwGetEndPtCvdata (p_uvcv, FALSE, FALSE, start_uvpt);
    pwGetEndPtCvdata (p_uvcv, FALSE, TRUE, stop_uvpt);

    pwGetEndCvparCvdata (p_uvcv, FALSE, TRUE, &param);

    param.spaninx = param.spaninx/2;
    param.spanpar = param.spanpar/2.0;

    PWsts = pwPtAtParCvdata (p_uvcv, &param, mid_uvpt);
    OnErrorCode (PWsts, wrapup);

    BSsfeval (p_sfgeom, start_uvpt[U], start_uvpt[V], 0,
              (PWpoint *) &start_xyzpt[0], &BSmsg); 
     OnErrorState (BSERROR (BSmsg), PWsts, SetError (PW_K_BspMath,
                  PW_K_Internal), wrapup);

    BSsfeval (p_sfgeom, stop_uvpt[U], stop_uvpt[V], 0,
            (PWpoint *) &stop_xyzpt[0], &BSmsg);
    OnErrorState (BSERROR (BSmsg), PWsts, SetError (PW_K_BspMath,
                  PW_K_Internal), wrapup);

    BSsfeval (p_sfgeom, mid_uvpt[U], mid_uvpt[V], 0,
            (PWpoint *) &mid_xyzpt[0], &BSmsg);
    OnErrorState (BSERROR (BSmsg), PWsts, SetError (PW_K_BspMath,
                  PW_K_Internal), wrapup);

    if (pwIsSamePt (start_xyzpt, stop_xyzpt, xyztol))
    {
      if (pwIsSamePt (start_xyzpt, mid_xyzpt, xyztol))
      {
        *props |= EMED_DEGENERATE;
      }
      *props |= EMED_XYZ_CLOSED;
    }
  }
  if (*props & EMED_DEGENERATE)
   {
    if (*props & EMED_ISO)
    {
      *props &= ~EMED_ISO;
    }
  }
 wrapup :
 return;
}   
