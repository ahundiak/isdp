/*
  NOTE

    It is important that the "pts" argument be a 3D array of pts, in case
    the datatype is of "curve3d", since the "BScveval" and "BScvarreval" only
    work on 3D points.  It is necessary to pass arrays of 3D points for
    UV data too. It is safe to always pass a 3D array of doubles for "pts"
    when dealing with UV points.

    OUYTPUT TYPE:

    It is important to realize how the output will be returned from this 
    function. It is assumed that the space allocated by the user for the output
    is ALWAYS an array of 3d points, as above. If the dataselect type is:

    poly2d : Output array will contain contiguous 2d points (NO z-coord).

    poly3d : Output will be contiguous array of 3d points.

    curve3d: Output array will contain contiguous 3d points. Here, if the caller
             knows the geometry pertains to UV space, he/she should call the 
             function EM3dto2d() subsequently to convert data into contiguous 
             2d array without the z coordinate.
            
    object:  Output will be a contiguous array of 2d/3d points depending on
             whether it is an EMSedge object or a GRcurve object. 
    
  HISTORY 

    SS  :  10/15/87  :  Creation
    NP  :  06/04/92  :  Added the NOTE above. Important.
  Sudha :  07/08/93  :  Modified for BSprototypes ansification
    SS  :  08/09/93  :  Works for EMSedge object too.
    NP  :  09/22/93  :  EMgeteddata is replaced by EMgetedgeom due to addition
                        of a paramater.
    NP  :  10/11/93  :  Wrong output (3d insteadof 2d) returned for EMSedge 
                        object geometry. Fixed. Also added "OUTPUT TYPE" notes.
*/

#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMmacros.h"
#include "OMerrordef.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "gr.h"
#include "bserr.h"
#include "EMSmsgdef.h"
#include "emsdef.h"
#include "emsdattyp.h"
#include "emsinter.h"
#include "emserr.h"
#include "emsgetgeom.h"
#include "bscveval.h"
#include "bscvarreval.h"

#define INIT_PARAMBUFF_SIZE  20

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

extern GRclassid OPP_GRcurve_class_id;
extern void EM3dto2d();


IGRlong EMinternalpt (msg, mattyp, mat, ingeom, loc, num, pts)
IGRlong *msg;
IGRshort *mattyp;
IGRmatrix mat;
struct EMSdataselect *ingeom;
enum EMScvinttype loc;
IGRint num;
IGRdouble *pts;
{
  IGRboolean is_curve;
  IGRshort dim, order;
  IGRint i, j, inx, num_points;
  IGRint blksize;
  IGRlong msg_loc, stat_OM;
  IGRdouble *points, *knots, valmem[INIT_PARAMBUFF_SIZE], *val;
  IGRdouble delta, initval, param;
  GRclassid classid;
  struct EMSdataselect simpledata;
  union EMSdata dat;
  struct IGRbsp_curve *curve;
  enum EMSdatatype dattyp;
  IGRlong EMgetvggeom();

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  is_curve = UNDEFINED;
  simpledata.datatype = EMSdata_null;
  val = NULL;

  dattyp = ingeom->datatype;
  dat = ingeom->data;
  switch (dattyp)
    {
    case EMSdata_poly2d:
    case EMSdata_poly3d:
      num_points = dat.poly->num_points;
      points = dat.poly->points;
      dim = (dattyp == EMSdata_poly2d ? 2 : 3);
      blksize = dim * sizeof (IGRdouble);
      if (loc == EMScvint_lfend)
        OM_BLOCK_MOVE (points, pts, blksize);
      else if (loc == EMScvint_middle)
        {
        delta = (IGRdouble) (num_points - 1) / (IGRdouble) (num + 1);
        for (i=1; i<num+1; i++)
          {
          inx = i * delta;
          param = i * delta - inx;
          inx *= dim;
          for (j=0; j<dim; j++)
            pts[j] = points[inx+j] + 
                      param * (points[inx+j+dim] - points[inx+j]);
          pts += dim;
          }
        }
      else if (loc == EMScvint_rtend)
        OM_BLOCK_MOVE (&points[(num_points-1)*dim], pts, blksize);
      else
        EMerr_hndlr (TRUE, *msg, EMS_E_InvalidArg, ret_end);
      break;

    case EMSdata_curve3d:
      curve = dat.curve;
      num_points = curve->num_poles;
      knots = curve->knots;
      order = curve->order;
      val = valmem;
      if (loc == EMScvint_lfend)
        {
        num = 1;
        val[0] = knots[order-1];
        }
      else if (loc == EMScvint_middle)
        {
        if (num > INIT_PARAMBUFF_SIZE)
          {
          val = (IGRdouble *) om$malloc (size = num * sizeof (IGRdouble));
          EMerr_hndlr (!val, *msg, EMS_E_NoDynamicMemory, ret_end);
          }
        delta = (knots[num_points] - knots[order-1]) / (num + 1);
        initval = knots[order-1];
        for (i=0; i<num; i++)
          val[i] = initval + (i+1) * delta;
        }
      else if (loc == EMScvint_rtend)
        {
        num = 1;
        val[0] = knots[num_points];
        }
      else
        EMerr_hndlr (TRUE, *msg, EMS_E_InvalidArg, ret_end);
      if (num == 1)
        BScveval (curve, val[0], 0, (IGRpoint *)pts, &msg_loc);
      else
        BScvarreval (&msg_loc, curve, val, num, 0, pts);
      EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);
      break;

    case EMSdata_object:
      om$get_classid (objid = dat.object->objid, osnum = dat.object->osnum,
       p_classid = &classid);
      if (om$is_ancestry_valid (subclassid = classid,
           superclassid = OPP_GRcurve_class_id) == OM_S_SUCCESS)
        is_curve = TRUE;
      else
        is_curve = FALSE;

      if (is_curve)
        stat_OM = EMgetvggeom (&msg_loc, mattyp, mat, dat.object,
                   &simpledata.data.curve, &simpledata.datatype);
      else
        stat_OM = EMgetedgeom (&msg_loc, EMSedgeom_logical, dat.object, 
                               &simpledata);
      EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
      
      EMinternalpt (&msg_loc, mattyp, mat, &simpledata, loc, num, pts);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

      /* If object was an edge with curve3d geometry, the output of above call
       * is an array of 3d points. Convert it to 2d.
       */
      if (!is_curve && (simpledata.datatype == EMSdata_curve3d))
            EM3dto2d (pts, num);

      if (is_curve)
        {
        om$dealloc (ptr = simpledata.data.curve);
        simpledata.datatype = EMSdata_null;
        }
      else
        EMdataselect_data_free (&msg_loc, &simpledata, 1);
      break;

    default:
      *msg = EMS_E_InvalidArg;
    }

ret_end:
  if (is_curve != UNDEFINED)
    {
    if (simpledata.datatype != EMSdata_null)
      {
      if (is_curve)
        om$dealloc (ptr = simpledata.data.curve);
      else
        EMdataselect_data_free (&msg_loc, &simpledata, 1);
      }
    }
  
  if (val && num > INIT_PARAMBUFF_SIZE)
    om$dealloc (ptr = val);
   
  EMWRAPUP (*msg, stat_OM, "EMinternalpt");
  return (stat_OM);
}
