/*
 * FOR Project PATHWAY
 *     Sanjay  : Creation
 */

/*
 * OVERVIEW
 *     This file consists of OMuse functions related to Edge  
 *     geometry. These functions can fall under any of the
 *     following category.
 *      a. Query
 *      b. Manipulation
 *
 * NOTES
 *     The functions in this file aims at accessing the instance data
 *     of the edge objects and manipulating the same.
 */

class implementation Root;

/* Includes */

#include <stdio.h>
#include <math.h>              /* Standard C */
#include <alloca.h>
#include <memory.h>
#include <malloc.h>

#include "OMminimum.h"
#include "OMprimitives.h"      /* OM stuff */
#include "OMmacros.h"
#include "igetypedef.h"

#include "bs.h"
#include "bstypes.h"
#include "bserr.h"

#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"             /* GRNUC stuff */
#include "godef.h"     
#include "gr.h"
#include "go.h"

#include "emsdef.h"
#include "EMSmsgdef.h"
#include "EMSprop.h"           /* MODEL stuff */
#include "EMSbnddef.h"
#include "EMSbnd.h"

#include "PWminimum.h"
#include "PWgmdata.h"
#include "PWerror.h"           /* PATHWAY stuff */

/* Prototypes */

#include "bschtptstcv.h"

#include "PWapi/edgeom.h"
#include "PWapi/edprops.h"
#include "PWapi/aligngm.h"
#include "PWapi/eded.h"


/* Imports */

from EMSedge import EMgetpygeom, EMgetbcgeom, EMgetedgedef, EMendpts;
from EMSnatedge import EMget_location;

/* Externs */

extern OMuword OPP_EMSbsedge_class_id, OPP_EMSpartedge_class_id;

enum PWcvdatatype  pwGetEdGeomType
(
  PWobjid  edobj,
  PWosnum  os
)
{
  /* status stuff */
  long  OMsts=OM_S_SUCCESS;

  /* edge class id */
  OMuword  edclass;

  /*
   * get the full edge of the incoming edge and get its classid 
   */
  edobj = pwGetEdOfPartEd (edobj, os);
  if (edobj == PW_K_NullObjid)
     return (enum PWcvdatatype) PWcvdata_null;
 
  OMsts = om$get_classid (objid = edobj, osnum = os, p_classid = &edclass);
  if (!(1&OMsts))
    return (enum PWcvdatatype) PWcvdata_null;

  if (om$is_ancestry_valid (subclassid = edclass,
            superclassid = OPP_EMSbsedge_class_id) == OM_S_SUCCESS)
  {
    /* BS edge */

    return (enum PWcvdatatype) PWcvdata_bspcv;
  }
  else
  {
    /* Point/Natural/Linear edge */

    return (enum PWcvdatatype) PWcvdata_py2d;
  }
}

int  pwGetEdGeomSize
(
  PWobjid  edobj,
  PWosnum  os
)
{
  /* status stuff */
  long  OMsts=OM_S_SUCCESS, OMmsg=EMS_S_Success;

  /* edge info */
  struct EMSedgeinfo edinfo;

  /* size */
  int  size=0, dim=2;

  memset (&edinfo, 0, sizeof(struct EMSedgeinfo));

  /* 
   * get the edge info 
   */
  OMsts = om$send (msg = message EMSedge.EMgetedgedef (&OMmsg, NULL, &edinfo),
                   senderid = edobj, 
                   targetid = edobj, 
                   targetos = os);
  if (!(1&OMsts&OMmsg))
    return (int) 0; 

  /*
   * now calculate the size for different edge types
   */
  if (edinfo.edgetype == EMSlinear)
  {
    size = edinfo.specinfo.linedge.num_points * dim * sizeof(double);     
  }
  else if (edinfo.edgetype == EMSnatural)
  {
    size = 2 * dim * sizeof(double);
  }
  else if (edinfo.edgetype == EMSbs)
  {
    size = pwAlignCvSize (edinfo.specinfo.bsedge.num_poles,
                          edinfo.specinfo.bsedge.order,
                         (PWboolean) (edinfo.specinfo.bsedge.bs_props & EMBS_RATIONAL), 
                          (int)0);
  }
  else if (edinfo.edgetype == EMSpt)
  {
    size = 2 * dim * sizeof(double);
  } 
  else if (edinfo.edgetype == EMSpart || edinfo.edgetype == EMSdummy)
  {
    if (edinfo.specinfo.partedge.fulled_type == EMSlinear)
    {
      size = (abs ((edinfo.specinfo.partedge.edbdry[0].span_inx - 
              edinfo.specinfo.partedge.edbdry[1].span_inx)) + 2) * dim * 
              sizeof(double);
    }
    else if (edinfo.specinfo.partedge.fulled_type == EMSnatural)
    {
      size = 2 * dim * sizeof(double);
    }
    else if (edinfo.specinfo.partedge.fulled_type == EMSbs)
    {
      struct EMSbsedgedef *p_bsedge=NULL;
      int    num_poles, order;

      p_bsedge = &edinfo.specinfo.partedge.fulled.bsedge;

      num_poles = (p_bsedge->num_poles + 2 * p_bsedge->order - 1);
      order = p_bsedge->order;

      size = pwAlignCvSize (num_poles, (short)order, 
                            (PWboolean)(p_bsedge->bs_props & EMBS_RATIONAL), (int)0);
    }
    else
      size = 0;
  }
  else 
    size = 0;

  return size;
}

PWresult  pwGetEdDef
(
  PWobjid         edobj,
  PWosnum         os,
  struct PWcvdata *p_eddata
)
{
  /* status stuff */
  long  OMsts=OM_S_SUCCESS, OMmsg=EMS_S_Success;
  PWresult PWsts=PW_K_Success; 

  /* edge info */
  struct EMSedgeinfo edinfo;

  memset (&edinfo, 0, sizeof(struct EMSedgeinfo));

  /* 
   * get the edge info 
   */
  OMsts = om$send (msg = message EMSedge.EMgetedgedef (&OMmsg, NULL, &edinfo),
                   senderid = edobj, 
                   targetid = edobj, 
                   targetos = os);
  if (!(1&OMsts&OMmsg))
    return (int) 0; 

  /*
   * now calculate the size for different edge types
   */
  if (edinfo.edgetype == EMSlinear)
  {
    p_eddata->datatype = PWcvdata_py2d;
    p_eddata->data.py2d.num_pts = edinfo.specinfo.linedge.num_points;
  }
  else if (edinfo.edgetype == EMSnatural)
  {
    p_eddata->datatype = PWcvdata_py2d;
    p_eddata->data.py2d.num_pts = 2;
  }
  else if (edinfo.edgetype == EMSbs)
  {
    p_eddata->datatype = PWcvdata_bspcv;
    p_eddata->data.p_bspcv->num_poles = edinfo.specinfo.bsedge.num_poles;
    p_eddata->data.p_bspcv->order = edinfo.specinfo.bsedge.order;
    p_eddata->data.p_bspcv->rational = 
            (edinfo.specinfo.bsedge.bs_props & EMBS_RATIONAL) ? TRUE : FALSE;
    p_eddata->data.p_bspcv->num_knots = p_eddata->data.p_bspcv->num_poles + 
                                 p_eddata->data.p_bspcv->order;
    p_eddata->data.p_bspcv->num_boundaries = 0;
  }
  else if (edinfo.edgetype == EMSpt)
  {
    p_eddata->datatype = PWcvdata_py2d;
    p_eddata->data.py2d.num_pts = 2;
  } 
  else if (edinfo.edgetype == EMSpart || edinfo.edgetype == EMSdummy)
  {
    if (edinfo.specinfo.partedge.fulled_type == EMSlinear)
    {
      p_eddata->datatype = PWcvdata_py2d;
      p_eddata->data.py2d.num_pts = 
                  abs ((edinfo.specinfo.partedge.edbdry[0].span_inx -
                        edinfo.specinfo.partedge.edbdry[1].span_inx)) + 2;
    }
    else if (edinfo.specinfo.partedge.fulled_type == EMSnatural)
    {
      p_eddata->datatype = PWcvdata_py2d;
      p_eddata->data.py2d.num_pts = 2;
    }
    else if (edinfo.specinfo.partedge.fulled_type == EMSbs)
    {
      struct EMSbsedgedef *p_bsedge=NULL;

      p_bsedge = &edinfo.specinfo.partedge.fulled.bsedge;

      p_eddata->datatype = PWcvdata_bspcv;
      p_eddata->data.p_bspcv->num_poles = p_bsedge->num_poles;
      p_eddata->data.p_bspcv->order = p_bsedge->order;
      p_eddata->data.p_bspcv->rational = 
              (p_bsedge->bs_props & EMBS_RATIONAL) ? TRUE : FALSE;
      p_eddata->data.p_bspcv->num_knots = p_bsedge->num_poles + p_bsedge->order; 
      p_eddata->data.p_bspcv->num_boundaries = 0;
    }
    else
      PWsts = SetError (PW_K_Pathway, PW_K_InvalidArg);
  }
  else 
    PWsts = SetError (PW_K_Pathway, PW_K_InvalidArg);

  return PWsts;
}

static PWresult  get_edgeom 
(
  PWobjid          edobj,
  PWosnum          os,
  PWboolean        reverse,
  struct PWcvdata  *p_cvdata
)
{
  /* status stuff */
  long     OMsts=OM_S_SUCCESS, OMmsg=EMS_S_Success;
  PWresult PWsts = PW_K_Success;

  int  size=0;

  p_cvdata->datatype = pwGetEdGeomType (edobj, os);     
 
  if (p_cvdata->datatype == PWcvdata_null)
    return (SetError(0,PW_K_InvalidArg));


  if (p_cvdata->datatype == PWcvdata_py2d)
  {
    struct IGRpolyline poly;

    /*
     * if the memory is not allocated, allocate the memory
     */
    if (!p_cvdata->data.py2d.p_pts)
    {
      size = pwGetEdGeomSize (edobj, os);
      if (!size)
        return (SetError(0,PW_K_InvalidArg));

      p_cvdata->data.py2d.p_pts = (PWpoint2d *) malloc (size);
      if (!p_cvdata->data.py2d.p_pts)
        return (SetError(0,PW_K_DynamicMemory));
    }

    poly.num_points = 0; 
    poly.points = (double *) p_cvdata->data.py2d.p_pts;

    /*
     * get the geometry
     */
    OMsts = om$send (msg = message EMSedge.EMgetpygeom (&OMmsg, 0, OM_K_MAXINT,
                                   reverse, NULL, &poly, NULL, NULL),
                     senderid = edobj,
                     targetid = edobj,
                     targetos = os);
    p_cvdata->data.py2d.num_pts = poly.num_points;
  }
  else
  {
    /*
     * if the memory is not allocated, allocate the memory
     */
    if (!p_cvdata->data.p_bspcv)
    {
      size = pwGetEdGeomSize (edobj, os);
      if (!size)
        return (SetError(0,PW_K_InvalidArg));
 
      p_cvdata->data.p_bspcv = (struct IGRbsp_curve *) malloc(size);
      if (!p_cvdata->data.p_bspcv)
        return (SetError(0,PW_K_DynamicMemory));
    }

    /*
     * get the edge definition and Align the memory.
     */
    PWsts = pwGetEdDef (edobj, os, p_cvdata);
    if (IsError(PWsts)) return SetError (PW_K_Pathway, PW_K_Internal);

    pwAlignCvGeom (p_cvdata->data.p_bspcv->num_poles,
                   p_cvdata->data.p_bspcv->order,
                   p_cvdata->data.p_bspcv->rational,
                   p_cvdata->data.p_bspcv->num_boundaries,
                   p_cvdata->data.p_bspcv);

    /*
     * get the geometry
     */
    OMsts = om$send (msg = message EMSedge.EMgetbcgeom (&OMmsg, 0, OM_K_MAXINT,
                                   reverse, NULL, p_cvdata->data.p_bspcv, NULL,
                                   NULL),
                     senderid = edobj,
                     targetid = edobj,
                     targetos = os);
  }

  if (!(1&OMsts&OMmsg))
    return (SetError(0,PW_K_InvalidArg));
  else
    return PW_K_Success;
}

static PWresult get_edgeom_linear
(
  PWobjid          edobj,
  PWosnum          os,
  PWboolean        reverse,
  struct PWpoly2d  *p_edpy
)
{
  /* status stuff */
  PWresult PWsts=PW_K_Success; 

  /* local variables */
  int    size=0;

  /* original geometry of the edge */
  struct PWcvdata eddata;

  /*
   * As this function need to allocate the memory all the time, make the
   * pointers point to NULL
   */ 
  p_edpy->num_pts = 0;
  p_edpy->p_pts = NULL;

  /*
   * get the edge geometry type 
   */
  if (pwGetEdGeomType (edobj, os) == PWcvdata_bspcv)
  {
    BSrc       rc=BSSUCC;
    int        num_pts=0, pt;
    IGRpoint   *p_pts=NULL;
    double     *p_pars=NULL;
    PWboolean  is_xyz=FALSE;

    /*
     * get the size of the original edge geometry
     */
    size = pwGetEdGeomSize (edobj, os);

    /*
     * allocate the memory and get the original geometry.
     */
    eddata.data.p_bspcv = (struct IGRbsp_curve *) alloca (size);
    if (!eddata.data.p_bspcv)
      return SetError (PW_K_Pathway, PW_K_DynamicMemory);

    PWsts = get_edgeom (edobj, os, reverse, &eddata);
    if (IsError (PWsts))
      return SetError (PW_K_Pathway, PW_K_DynamicMemory);

    /*
     * Now stroke the curve by using current chord height tolerance
     */
    BSchtptstcv (eddata.data.p_bspcv, &num_pts, &p_pts, &p_pars, &rc);
    if (BSERROR(rc))
      return SetError (PW_K_Pathway, PW_K_Internal);

    /*
     * allocate the memory for the polyline geometry
     */
    p_edpy->num_pts = num_pts;
    p_edpy->p_pts = (PWpoint2d *) malloc (num_pts * sizeof(PWpoint2d));
    if (!p_edpy->p_pts)
      return SetError (PW_K_Pathway, PW_K_DynamicMemory);

    /*
     * Logic to make sure the stroked points are within the parametric space 
     * of the surface (I am assuming [0,1] space). This is needed for BSedges 
     * which are tangent to natural edges because the stroked data may, and 
     * in one case did, have sufficent noise to push it outside parametric 
     * space.  (rlw)
     * Don't do this if this edge is an XYZ-edge. - (SS)
     */
    is_xyz = pwIsEdXYZ (edobj, os);

    for (pt=0; pt<num_pts; pt++)
    {
      if (!is_xyz)
      {
        if (p_pts[pt][U] < 0.0)
          p_pts[pt][U] = 0.0;
        else if (p_pts[pt][U] > 1.0)
          p_pts[pt][U] = 1.0;

        if (p_pts[pt][V] < 0.0)
          p_pts[pt][V] = 0.0;
        else if (p_pts[pt][V] > 1.0)
          p_pts[pt][V] = 1.0;
      }

      p_edpy->p_pts[pt][U] = p_pts[pt][U];   
      p_edpy->p_pts[pt][V] = p_pts[pt][V];   
    }
  }
  else 
  {
    eddata.data.py2d.num_pts = 0;
    eddata.data.py2d.p_pts = NULL;

    PWsts = get_edgeom (edobj, os, reverse, &eddata);
    if (IsError (PWsts))
      return SetError (PW_K_Pathway, PW_K_DynamicMemory);

    p_edpy->num_pts = eddata.data.py2d.num_pts;
    p_edpy->p_pts = eddata.data.py2d.p_pts;
  }

  return PW_K_Success;
}

static PWresult get_edgeom_bspline
(
  PWobjid              edobj,
  PWosnum              os,
  PWboolean            reverse,
  struct IGRbsp_curve  **p_edcv
)
{
  /* status stuff */
  PWresult PWsts=PW_K_Success; 
   
  /* edge geometry data */
  struct PWcvdata eddata;

  /*
   * get the edge geometry type
   */
  if (pwGetEdGeomType (edobj, os) == PWcvdata_bspcv)
  {
    eddata.data.p_bspcv = *p_edcv;

    PWsts = get_edgeom (edobj, os, reverse, &eddata);
    if (IsError (PWsts))
      return PWsts;

    if (!*p_edcv)
      *p_edcv = eddata.data.p_bspcv;

    return PWsts;
  }
  else
  {
    int    i=0;
    double step; 

    /*
     * get the original geometry.
     */
    eddata.data.py2d.num_pts = 0; 
    eddata.data.py2d.p_pts = (PWpoint2d *) alloca(pwGetEdGeomSize (edobj, os)); 
    if (!eddata.data.py2d.p_pts)
      return SetError (PW_K_Pathway, PW_K_DynamicMemory);

    PWsts = get_edgeom (edobj, os, reverse, &eddata);
    if (IsError (PWsts))
      return SetError (PW_K_Pathway, PW_K_DynamicMemory);

    /*
     * As we have got the poles in two dimensional array, we need to rearrange
     * into 3 dimensional.
     */
    if (!*p_edcv)
    {
      int size;

      size = pwAlignCvSize (eddata.data.py2d.num_pts, 2, FALSE, 0);

      *p_edcv = (struct IGRbsp_curve *) malloc (size);
      if (!(*p_edcv))
        return SetError (PW_K_Pathway, PW_K_DynamicMemory);
    }

    pwAlignCvGeom (eddata.data.py2d.num_pts, 2, FALSE, 0, (*p_edcv));
    
    for (i=0; i<eddata.data.py2d.num_pts; i++)
    {
      (*p_edcv)->poles[i*3] = eddata.data.py2d.p_pts[i][U];
      (*p_edcv)->poles[i*3+1] = eddata.data.py2d.p_pts[i][V];
      (*p_edcv)->poles[i*3+2] = 0;
    }
    
    /*
     * Now that we have got the poles, frame the curve structure.
     */
    (*p_edcv)->num_poles = eddata.data.py2d.num_pts; 
    (*p_edcv)->order = 2; (*p_edcv)->num_knots = (*p_edcv)->num_poles + 2; 
    (*p_edcv)->non_uniform = FALSE;
    (*p_edcv)->rational = FALSE; (*p_edcv)->weights = NULL;
    (*p_edcv)->periodic = FALSE; (*p_edcv)->planar = TRUE;
    (*p_edcv)->phy_closed = !pwIsEdOpen (edobj, os);
    (*p_edcv)->num_boundaries = 0; (*p_edcv)->bdrys = NULL;

    step = 1.0 / ((*p_edcv)->num_poles - 1);
    for (i=0; i<2; i++)
      (*p_edcv)->knots[i] = 0;
    for (i=2; i<(*p_edcv)->num_poles; i++)
      (*p_edcv)->knots[i] =  (*p_edcv)->knots[i-1] + step;
    for (i=(*p_edcv)->num_poles; i<(*p_edcv)->num_knots; i++)
      (*p_edcv)->knots[i] = 1.0;
  }  

  return PW_K_Success;
}

PWresult pwGetEdGeom
(
  PWobjid          edobj,
  PWosnum          os,
  struct PWcvdata  *p_cvdata
)
{
  return (get_edgeom (edobj, os, FALSE, p_cvdata));
}

PWresult pwGetEdGeomAsLinear
(
  PWobjid          edobj,
  PWosnum          os,
  struct PWpoly2d  *p_py2d
)
{
  return (get_edgeom_linear (edobj, os, FALSE, p_py2d));
}

PWresult pwGetEdGeomAsBspline
(
  PWobjid              edobj,
  PWosnum              os,
  struct IGRbsp_curve  **p_curve
)
{
  return (get_edgeom_bspline (edobj, os, FALSE, p_curve));
}

PWresult pwGetNatEdGeom
(
  PWobjid          edobj,
  PWosnum          os,
  struct PWcvdata  *p_cvdata
)
{
  return (get_edgeom (edobj, os, pwIsEdRev(edobj, os), p_cvdata));
}

PWresult pwGetNatEdGeomAsLinear
(
  PWobjid          edobj,
  PWosnum          os,
  struct PWpoly2d  *p_py2d
)
{
  return (get_edgeom_linear (edobj, os, pwIsEdRev(edobj, os), p_py2d));
}

PWresult pwGetNatEdGeomAsBspline
(
  PWobjid              edobj,
  PWosnum              os,
  struct IGRbsp_curve  **p_curve
)
{
  return (get_edgeom_bspline (edobj, os, pwIsEdRev(edobj, os), p_curve));
}

void pwGetEdEndPts
(
  PWobjid    edobj,
  PWosnum    os,
  PWpoint2d  startpt,
  PWpoint2d  stoppt
)
{
  /* status stuff */
  long  OMsts=OM_S_SUCCESS, OMmsg=EMS_S_Success;

  /*
   * get the end points of the edge
   */
  OMsts = om$send (msg = message EMSedge.EMendpts (&OMmsg, (double *) startpt,
                                 (double *) stoppt, NULL, NULL, NULL),
                   senderid = edobj, targetid = edobj, targetos = os);
  return ;
}

void pwGetEdEndPars
(
  PWobjid           edobj,
  PWosnum           os,
  struct PWcvparam  *p_startpar,
  struct PWcvparam  *p_stoppar
)
{
  /* status stuff */
  long  OMsts=OM_S_SUCCESS, OMmsg=EMS_S_Success;

  /* edge bounds */
  struct EMSedgebound start, stop;

  /*
   * get the end points of the edge
   */
  OMsts = om$send (msg = message EMSedge.EMendpts (&OMmsg, NULL, NULL, &start, 
                                 &stop, NULL),
                   senderid = edobj, targetid = edobj, targetos = os);
  if (!(1&OMsts&OMmsg))
    return;

  if (p_startpar)  
  {
    p_startpar->spaninx = (int) start.span_inx;
    p_startpar->spanpar = start.param;
  }

  if (p_stoppar)
  {
    p_stoppar->spaninx = (int) stop.span_inx;
    p_stoppar->spanpar = stop.param;
  }

  return ;
}


/*
 * ASSUMPTION :
 * ------------
 *    THE INCOMING PARAMETER VALUES ARE IN NATURAL FORMAT
 */

PWresult  pwCvtToEdPar
(
  PWobjid          edobj,
  PWosnum          os,
  struct PWcvparam *p_inpar,
  struct PWcvparam *p_outpar
)
{
  /* class of the edge */
  PWclassid  ed_class=0;

  /* status stuff */
  long      OMsts = OM_S_SUCCESS;

  /*
   * get the class id of the edge
   */
  OMsts = om$get_classid (objid = edobj, osnum = os, p_classid = &ed_class);
  if (!(1&OMsts))
    return SetError (PW_K_Pathway, PW_K_InvalidArg);

  /*
   * If it is a part edge, the incoming parameter info. need to be transformed
   * to the full edge's geometry, otherwise the incoming parmeter info. same as
   * the out going parameter info.
   */

  if (om$is_ancestry_valid (subclassid = ed_class,
            superclassid = OPP_EMSpartedge_class_id) == OM_S_SUCCESS)
  {
    /* end pars of the edge */
    struct PWcvparam  start_par, stop_par;
    struct PWcvparam  *tstart_par=NULL, *tstop_par=NULL;

    /*
     * get the end pars of the edge
     */
    pwGetEdEndPars (edobj, os, &start_par, &stop_par);

    /*
     * arrange the start and stop parameters in the ascending order.
     */
    if (start_par.spaninx + start_par.spanpar < 
        stop_par.spaninx + stop_par.spanpar)
    {
      tstart_par = &start_par;
      tstop_par  = &stop_par;
    }
    else
    {
      tstart_par = &stop_par;
      tstop_par  = &start_par;
    }

    /*
     * If it is a BS edge : 
     *   Span index always ZERO.
     *   Span Parameter is calculated by using linear interpolation.
     * else any other edge (could be linear)
     *   Span index is calculated with respect to the start par span index.
     *   Span parameter is calculated by linear interpolation if it is falling
     *   in any of the start/stop spans otherwise the incoming parameter is it
     *   self represents the correct spanpar. 
     */
    if (pwGetEdGeomType (edobj, os) == PWcvdata_bspcv)
    {
      /*
       * For a BS edge
       */
      p_outpar->spaninx = 0;
      p_outpar->spanpar = tstart_par->spanpar + 
              (tstop_par->spanpar - tstart_par->spanpar) * p_inpar->spanpar ;
    }
    else
    {
      /*
       * For a Linear Edge
       */
      if (tstart_par->spaninx == tstop_par->spaninx)
        p_outpar->spaninx = tstart_par->spaninx;
      else
        p_outpar->spaninx = p_inpar->spaninx + tstart_par->spaninx +
                            (tstart_par->spanpar == 1.0 ? 1 : 0);

      if (tstart_par->spaninx == tstop_par->spaninx)
      {
        p_outpar->spanpar = tstart_par->spanpar + 
               (tstop_par->spanpar - tstart_par->spanpar) * p_inpar->spanpar;
      }
      else if (tstart_par->spaninx == p_outpar->spaninx)
      {
        p_outpar->spanpar = tstart_par->spanpar + (1.0 - tstart_par->spanpar) *
                                                  p_inpar->spanpar;
      }
      else if (tstop_par->spaninx == p_outpar->spaninx)
      {
        p_outpar->spanpar = tstop_par->spanpar * p_inpar->spanpar;
      }
      else
      {
        p_outpar->spanpar = p_inpar->spanpar;
      }
    }
  }
  else
    *p_outpar = *p_inpar;

  return PW_K_Success;
}

PWresult pwGetNatEdLocation
(
  PWobjid  edobj,
  PWosnum  os,
  int      *location
)
{
  /* status stuff */
  long      OMsts=OM_S_SUCCESS, OMmsg=EMS_S_Success;

  short     loc_location=0;

  if (!pwIsEdNatural (edobj, os))
    return SetError (PW_K_Pathway, PW_K_InvalidArg);

  OMsts = om$send (msg = message EMSnatedge.EMget_location (&OMmsg, 
                                 &loc_location),
                   senderid = edobj, targetid = edobj, targetos = os);
  if (!(1&OMsts&OMmsg))
    return SetError (PW_K_Pathway, PW_K_Internal);

  *location = (int) loc_location;

  return PW_K_Success;
}

end implementation Root;
