#include <stdio.h>
#include <math.h>
#include <memory.h>


#include "PWminimum.h"
#include "PWattrib.h"
#include "PWattribid.h"
#include "PWgmdata.h"
#include "PWerror.h"
#include "PWapi/mdstptgm.h"
#include "bs.h"
#include "bserr.h"
#include "bsparameters.h"
#include "bschgdeppar.h"
#include "bscvkttol2.h"
#include "bsmdistptcv.h"
#include "bscveval.h"

#include "PWapi/edprops.h"
#include "PWapi/edgeom.h"
#include "PWapi/mdstptgm.h"

PWresult    pwEdPtProject
(
  struct PWid     *p_edid,
  int             numpts,
  PWpoint2d       *pts,
  double          uvtol,
  struct PWcvpt   *p_cvpt
)
{
  PWresult               retval=PW_K_Success;
  long                   rc=BSSUCC;
  short                  no_params=0, no_intervals=0;
  int                    i=0;
  struct PWcvdata        cvdata;
  PWpoint2d              startpt, stoppt;
  PWpoint                proj_pt, point_to_be_projected;
  PWboolean              closed=FALSE, reversed=FALSE, bssts=TRUE;
  struct IGRbsp_curve    *p_edgeom=NULL;
  double                 startpar=0, stoppar=0, knot_tol,*projected_params=NULL,
                         tmp_prjparam=0, *interval_params=NULL, min_dist=0,
                         basis_tol=0, dist=0;


  PWpoint2d              minpt;
  struct PWcvparam       minpar, tmppar;
  double                 sqdist;

  /*
   * Initialize the output
   */
  memset (p_cvpt, 0, sizeof (struct PWcvpt));
  startpt[0] = startpt[1] = stoppt[0] = stoppt[1] = minpt[0] = minpt[1] = 0.0;
  proj_pt[0] = proj_pt[1] = proj_pt[2] = 0.0;
  /*
   * Get the geometry of the input edge object
   */
  retval = PW_GetNatEdGeomStack (p_edid->objid, p_edid->osnum, cvdata);

  if ( cvdata.data.py2d.num_pts == 0 && cvdata.data.py.num_pts == 0 )
    goto wrapup;      /* We must be dealing with an unknown object... */

  closed = !(pwIsEdOpen (p_edid->objid, p_edid->osnum)) ;
  reversed = pwIsEdRev (p_edid->objid, p_edid->osnum);
  /*
   * Get the end points for this edge object
   */
  pwGetEdEndPts (p_edid->objid, p_edid->osnum, startpt, stoppt);

  if (cvdata.datatype == PWcvdata_bspcv)
  {
    bssts = BSEXTRACTPAR (&rc, BSTOLBASIS, basis_tol);
    OnErrorState (!bssts, retval,
                  SetError (PW_K_Pathway, PW_K_Internal), wrapup);
    BSchgdeppar (uvtol, &rc);
    OnErrorState (rc != BSSUCC, retval,
                  SetError (PW_K_Pathway, PW_K_Internal), wrapup);
    p_edgeom = cvdata.data.p_bspcv;
    /*
     * Get the knot tolerance for this edge
     */
    BScvkttol2 (p_edgeom->order, p_edgeom->knots, p_edgeom->num_poles,
                p_edgeom->poles, p_edgeom->weights, &knot_tol, &rc);
    OnErrorState (rc != BSSUCC, retval,
                  SetError (PW_K_Pathway, PW_K_Internal), wrapup);
    startpar = p_edgeom->knots[p_edgeom->order-1];
    stoppar  = p_edgeom->knots[p_edgeom->num_poles];

    for (i=0; i< numpts; i++)
    {
      point_to_be_projected[X] =  pts[i][0];
      point_to_be_projected[Y] =  pts[i][1];
      point_to_be_projected[Z] =  0.0;
      BSmdistptcv (p_edgeom, point_to_be_projected, &no_intervals,
                   &no_params, &projected_params, &min_dist,
                   &interval_params, &rc);
      OnErrorState (rc != BSSUCC, retval,
                    SetError (PW_K_Pathway, PW_K_Internal), wrapup);
      /*
       * If there are distinct parameters then return the first
       * parameter and its associated point as the result
       * else if there are intervals over which the condition
       * of minimum distance occurs then return the starting point
       * of the interval as the result else something is messed up
       * and invalid arguments is returned
       */
      if (no_params)
        tmp_prjparam = projected_params[0];
      else if (no_intervals)
        tmp_prjparam = interval_params[0];
      /*
       * If the projected parameter is very close to the boundary
       * we snap it to the boundary to prevent curve evaluation
       * from barfing.
       */
      if (fabs (tmp_prjparam - startpar) <= knot_tol)
        tmp_prjparam = startpar;
      else if (fabs(tmp_prjparam - stoppar) <= knot_tol)
        tmp_prjparam = stoppar;

      p_cvpt[i].cvparam.spaninx = 0;
      p_cvpt[i].cvparam.spanpar = tmp_prjparam;

      p_cvpt[i].p_attrib = NULL;
      pwCreateDoubleAttrib (&((p_cvpt[i]).p_attrib),
                            PW_AttribIdent (PW_K_Pathway,
                            PW_K_DistanceAttr, NULL), min_dist );

      pwSetTopoposCvpt (&(p_cvpt[i]), PWtopopos_unknown);

      BScveval (p_edgeom, tmp_prjparam, 0, &(proj_pt), &rc);
      OnErrorState (rc != BSSUCC, retval,
                    SetError (PW_K_Pathway, PW_K_Internal), wrapup);

      p_cvpt[i].pt[U] = proj_pt[X];
      p_cvpt[i].pt[V] = proj_pt[Y];

      if ((dist = pwDistPtPt2d (startpt, p_cvpt[i].pt)) < uvtol)
        pwSetTopoposCvpt (&(p_cvpt[i]), PWtopopos_start);
      else if ((dist = pwDistPtPt2d(stoppt, p_cvpt[i].pt)) < uvtol)
        pwSetTopoposCvpt( &(p_cvpt[i]), PWtopopos_stop );
      else
        pwSetTopoposCvpt( &(p_cvpt[i]), PWtopopos_middle );
      /*
       * Correction to location may be needed if the point to be
       * projected is at the end-point of a closed curve.
       */
      if (closed && (pwGetTopoposCvpt (&(p_cvpt[i])) != PWtopopos_middle))
      {
        if (fabs(tmp_prjparam - startpar) < fabs(tmp_prjparam - stoppar))
          pwSetTopoposCvpt (&(p_cvpt[i]), reversed ? PWtopopos_stop :
                            PWtopopos_start );
        else
          pwSetTopoposCvpt (&(p_cvpt[i]), reversed ? PWtopopos_start :
                            PWtopopos_stop );
      }
    }
    BSchgdeppar (basis_tol, &rc);
    OnErrorState (rc != BSSUCC, retval,
                  SetError (PW_K_Pathway, PW_K_Internal), wrapup);
   }/* end of PWcvdata_bspcv */
   else if (cvdata.datatype == PWcvdata_py2d)
   {
     for (i=0; i<numpts; i++)
      {
        /*
         * Calculate the minimum distance point on the polyline
         * corresponding to this point
         */
        sqdist = pwMinDistSqPtPy2d (pts[i], cvdata.data.py2d.num_pts,
                                    cvdata.data.py2d.p_pts, minpt,
                                    &minpar);
        p_cvpt[i].pt[U] = minpt[U];
        p_cvpt[i].pt[V] = minpt[V];
        p_cvpt[i].cvparam.spaninx = minpar.spaninx;
        p_cvpt[i].cvparam.spanpar = minpar.spanpar;
        p_cvpt[i].p_attrib = NULL;
        pwCreateDoubleAttrib (&((p_cvpt[i]).p_attrib),
                              PW_AttribIdent (PW_K_Pathway,
                              PW_K_DistanceAttr, NULL), sqrt( sqdist ) );
        /*
         * Fill in the relative location of the projected point in
         * the return argument. (check)
         */
        if ((dist = pwDistPtPt2d (startpt, p_cvpt[i].pt) ) < uvtol )
          pwSetTopoposCvpt (&(p_cvpt[i]), PWtopopos_start);
        else if ((dist= pwDistPtPt2d (stoppt, p_cvpt[i].pt)) < uvtol )
          pwSetTopoposCvpt (&(p_cvpt[i]), PWtopopos_stop);
        else
          pwSetTopoposCvpt (&(p_cvpt[i]), PWtopopos_middle);
        /*
         * Handle the closed edges (check)
         */
        if (closed && (pwGetTopoposCvpt( &(p_cvpt[i])) != PWtopopos_middle))
         {
           startpar = 0.0;
           stoppar  = cvdata.data.py2d.num_pts -1.0;
           tmp_prjparam = (minpar.spaninx + minpar.spanpar);

           if (fabs(tmp_prjparam - startpar) < fabs(tmp_prjparam - stoppar))
             pwSetTopoposCvpt (&(p_cvpt[i]), reversed ? PWtopopos_stop :
                               PWtopopos_start);
           else
             pwSetTopoposCvpt (&(p_cvpt[i]), reversed ? PWtopopos_start :
                               PWtopopos_stop);
         }
      }/* for numpts */
   }/* else  cvdata.datatype == PWcvdata_poly2d */

   /* (check) natural edge and point edge */

   /* Convert the generated parameters into an internal one
    */
   for (i=0; i<numpts; i++)
   {
     retval = pwCvtToEdPar (p_edid->objid, p_edid->osnum,
                            &(p_cvpt[i].cvparam), &tmppar);
      OnErrorCode (retval, wrapup);
      p_cvpt[i].cvparam = tmppar;
   }
   wrapup:
   return (retval);
}/* end of function pwEdPtProject */

