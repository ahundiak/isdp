/*
  OVERVIEW

  This file consists of functions related to Curve geometry. 

  HISTORY

  Sanjay  01/95   Creation
*/

class implementation GRbspline;

#include <math.h>

#include "OMmacros.h"
#include "bs.h"
#include "EMSmsgdef.h"
#include "PWminimum.h"
#include "PWgmdata.h"
#include "PWerror.h"
#include "PWapi/cvgeom.h" 
#include "PWapi/mx.h" 
#include "PWapi/clsid.h" 

#include "bstrfrhommx.h"
#include "bscvoton.h"

extern PWclassid OPP_GR3dpoint_class_id, OPP_GRbspline_class_id,
                 OPP_GRlinear_class_id;

from GRlinear import GRgetpolyline;


/*
  ABSTRACT

  Obtain the given curve's geometry in a B-spline format. The transformation
  matrix that needs to be applied to the stored geometry is also supplied. 
  The caller inputs the pointer to a B-spline curve structure that has
  it's poles/weights and knots pointers pointing to a valid memory location
  and sufficient memory.

  NOTES

  Please note that the caller must allocate the sufficient geometry. One can
  get the size by calling the function pwGetCvSize.
*/

PWresult pwGetCvAsBspline
(
  PWobjid                 cvobj, 
  PWosnum                 os,
  short                   mattyp,
  PWmatrix                matrix,
  struct IGRbsp_curve     *p_cvgeom
)
{
  long msg=EMS_S_Success;
  PWresult result=PW_K_Success;

  OnErrorState (!p_cvgeom, result, SetError (PW_K_Pathway, PW_K_Memory),
   wrapup);

  result = om$send (msg = message GRvg.GRgetgeom (&msg, &mattyp, matrix,
            (IGRchar *) p_cvgeom), senderid = cvobj, targetid = cvobj,
            targetos = os);
  OnErrorState (IsError (result & msg), result, PW_K_Error, wrapup);

wrapup:
  PW_WrapupId (result, "GetCvAsBsp", cvobj);
  return (result);
}


/*
  ABSTRACT

  Obtain the given curve's geometry's B-spline format's size in bytes. 
  This includes the size for the IGRbsp_curve structure + the memory needed
  to hold the poles/knots/weights + any padding necessary to get 8-bute
  alignment.

  NOTES
 
  None.
*/

int  pwGetCvSize 
(
  PWobjid  cvobj,
  PWosnum  os
)
{
  short mattyp=MAIDMX;
  long msg=EMS_S_Success;
  PWresult result=PW_K_Success;
  long size=0; 
  IGRmatrix idmx;

  pwIdMx (idmx);
  result = om$send (msg = message GRvg.GRgetsize (&msg, &mattyp, idmx, &size),
           senderid = cvobj, targetid = cvobj, targetos = os);
  OnErrorState (IsError (result & msg) || !size, result, PW_K_Error, wrapup);

wrapup:
  PW_WrapupId (result, "GetCvSize", cvobj);
  return (size);
}

/*
  ABSTRACT

  Extracts the curve's geometry in it's natural format. If it is a point a 
  point will be returned, if it is a linear element it is returned in polyline
  format otherwise it will be returned in B-spline format. 

  NOTES

  One can get the required size by calling the function pwGetCvAsCvdataSize.
  All the memory must be allocated by the caller. One should use the macro
  rather than the function calls.
*/

PWresult pwGetCvAsCvdata
(
  PWobjid          cvobj,
  PWosnum          os,
  short            mattyp,
  PWmatrix         matrix,
  struct PWcvdata  *p_cvdata
)
{
  long msg=EMS_S_Success;
  PWresult result=PW_K_Success;
  
  OnErrorState (!p_cvdata, result, SetError (PW_K_Pathway, PW_K_Memory),
   wrapup);

  p_cvdata->datatype = pwGetCvType (cvobj, os);
  OnErrorState (p_cvdata->datatype == PWcvdata_null, result, 
                SetError (PW_K_Pathway, PW_K_InvalidArg), wrapup);

  if (p_cvdata->datatype == PWcvdata_bspcv)
  {
    result =  pwGetCvAsBspline (cvobj, os, mattyp, matrix, 
                                p_cvdata->data.p_bspcv);
    OnErrorState (IsError (result), result, result, wrapup);
  }
  else
  {
    struct IGRpolyline poly;
    int action=1;
    long OMsts=OM_S_SUCCESS, OMmsg=EMS_S_Success;
   
    poly.num_points = 0; 
    poly.points = (p_cvdata->datatype == PWcvdata_pt) ? p_cvdata->data.pt :
                   &p_cvdata->data.py.p_pts[0][0];

    OMsts = om$send (msg = message GRlinear.GRgetpolyline (&OMmsg, &mattyp, 
                                   matrix, &action,  &poly),
                     senderid = cvobj,
                     targetid = cvobj,
                     targetos = os);
    OnErrorState (IsError (OMsts & msg), result, PW_K_Error, wrapup);

    if (p_cvdata->datatype == PWcvdata_py) 
      p_cvdata->data.py.num_pts = poly.num_points;
  }

wrapup : 

  PW_WrapupId (result, "GetCvAsBsp", cvobj);
  return (result);
}

enum PWcvdatatype pwGetCvType
(
  PWobjid cvobj, 
  PWosnum os
)
{
  PWclassid cvclass=0;

  cvclass = omClassidFromObjid (cvobj, os);

  if (omIsAncestryValid (cvclass, OPP_GR3dpoint_class_id))
    return PWcvdata_pt;
  else if (omIsAncestryValid (cvclass, OPP_GRlinear_class_id))
    return PWcvdata_py;
  else if (omIsAncestryValid (cvclass, OPP_GRbspline_class_id))
    return PWcvdata_bspcv;
  else
    return PWcvdata_null;
}

int pwGetCvAsCvdataSize
(
  PWobjid cvobj,
  PWosnum os
)
{
  PWresult result=PW_K_Success;
  int size=0;
  enum PWcvdatatype cvtype=PWcvdata_null;

  cvtype = pwGetCvType (cvobj, os);

  if (cvtype == PWcvdata_py)
  {
    struct IGRpolyline poly;
    int action=0;
    long OMsts=OM_S_SUCCESS, OMmsg=EMS_S_Success;
    short mattyp=MAIDMX;
    PWmatrix idmx;

    poly.num_points = 0; 
    poly.points = NULL; 

    OMsts = om$send (msg = message GRlinear.GRgetpolyline (&OMmsg, &mattyp, 
                                   pwIdMx (idmx), &action,  &poly),
                     senderid = cvobj,
                     targetid = cvobj,
                     targetos = os);
    OnErrorState (IsError (OMsts & OMmsg), result, PW_K_Error, wrapup);

    size = poly.num_points * sizeof (PWpoint);
  }
  else if (cvtype == PWcvdata_bspcv)
  {
    size = pwGetCvSize (cvobj, os);
  }

wrapup : 

  return size;
}


PWresult pwGetCvEndPts
(
  PWobjid          cvobj,
  PWosnum          os,
  short            mattyp,
  PWmatrix         matrix,
  PWpoint          Start,
  PWpoint 	   End
)
{
  PWresult result=PW_K_Success; 
  long OMsts=OM_S_SUCCESS, OMmsg=EMS_S_Success;

  OMsts = om$send (msg = message GRcurve.GRendpts(&OMmsg, &mattyp, 
                                   matrix, Start, End),
                     senderid = cvobj,
                     targetid = cvobj,
                     targetos = os);
  OnErrorState (IsError (OMsts & OMmsg), result, PW_K_Error, wrapup);

wrapup : 

  PW_WrapupId (result, "pwGetCvEndPts", cvobj);
  return (result);
}





end implementation GRbspline;
