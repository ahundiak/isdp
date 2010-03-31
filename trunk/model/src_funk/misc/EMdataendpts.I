class implementation Root;

#include "EMS.h"
#include "OMerrordef.h"
#include "OMprimitives.h"
#include "OMmacros.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "igetypedef.h"
#include "dp.h"
#include "godef.h"
#include "gr.h"
#include "go.h"
#ifndef BASE_EMS
#include "exmacros.h"
#endif
#include "emsdattyp.h"
#include "emsinterdef.h"
#include "emsinter.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "EMSprop.h"
#include "EMSopt.h"
#include "emssfintdef.h"
#include "emssfint.h"
#include "emsdef.h"
#include "emsmacros.h"
#include "emserr.h"
#include "emsedgedef.h"
#include "emsgetgeom.h"
#include "bserr.h"
#include "bsparameters.h"
#include "bsconic.h"
#include "EMSmsgdef.h"
#include "mabcendpts.h"
#include "bsparameters.h"
#include "bsdistptpts.h"
#include "bscveval.h"
#include "bsalloccv.h"
#include "bscv_copy.h"
#include "bsrev_cv.h"
#include "bsfreecv.h"

#include "PWminimum.h"
#include "PWerror.h"
#include "PWgmdata.h"
#include "PWapi/mx.h"
#include "PWapi/cvgeom.h"

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

#define X 0
#define Y 1
#define Z 2

#define FIRST  0
#define SECOND 1

#define START  0
#define STOP   1

#define NUM_INTERNAL_SAMPLES 3


extern GRclassid OPP_GRpoint_class_id;

from GRvg        import GRgetsize, GRgetgeom ;
from GRcurve     import GRendpts;


/*
   ABSTRACT:
    
    This function obtains a given number of points lying at the ends of
    the input intersection data. The input data could be a polyline-structure,
    curve buffer or a curve object. The point-data is 3-dimensional and the
    curve is assumed to be of GRcurve type.
 
   HISTORY:
   
   ??????   ???  Creation.
   06/06/93 NP   Moved from EMintsupp.I to here.
   07/08/93 SudhaModified for BSprototypes ansification

*/

IGRint EMgetendpts_xyz (msg, mattyp, mat, indata, indata_rev, 
                        numpts, start_pts, stop_pts)
IGRlong *msg;
IGRshort *mattyp;
IGRmatrix mat;
struct EMSdataselect *indata;
IGRboolean indata_rev;
IGRint numpts;
IGRdouble *start_pts, *stop_pts;
{
  IGRint in_numpts, blksize, stat_OM, i;
  IGRlong msg_loc;
  IGRdouble *in_pts, *start_loc, *stop_loc;
  struct IGRbsp_curve *cv;
  struct IGRpolyline poly;
  void EMrevpyline();

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  cv = NULL;

  if (indata_rev)
    {
    start_loc = stop_pts;
    stop_loc = start_pts;
    }
  else
    {
    start_loc = start_pts;
    stop_loc = stop_pts;
    }

  if (numpts == 1)
    {
    switch (indata->datatype)
      {
      case EMSdata_object:
        stat_OM = om$send (msg = message GRcurve.GRendpts (&msg_loc,
                   mattyp, mat, start_loc, stop_loc), 
                   targetid = indata->data.object->objid,
                   targetos = indata->data.object->osnum,
                   senderid = NULL_OBJID);
        EMomerr_exit (stat_OM, ret_end);
        EMerr_hndlr (EMis_error (msg_loc), *msg, EMS_E_OMerror, ret_end);
        break;
      case EMSdata_poly3d:
        in_numpts = indata->data.poly->num_points;
        in_pts = indata->data.poly->points;
        blksize = 3 * sizeof (IGRdouble);
        OM_BLOCK_MOVE (in_pts, start_loc, blksize);
        OM_BLOCK_MOVE (&in_pts[(in_numpts-1)*3], stop_loc, blksize);
        break;
      case EMSdata_curve3d:
        cv = indata->data.curve;
        in_numpts = indata->data.curve->num_poles;
        in_pts = indata->data.curve->poles;
        blksize = 3 * sizeof (IGRdouble);
        OM_BLOCK_MOVE (in_pts, start_loc, blksize);
        OM_BLOCK_MOVE (&in_pts[(in_numpts-1)*3], stop_loc, blksize);
        if (cv->rational)
          for (i=0; i<3; i++)
            {
            start_loc[i] /= cv->weights[0];
            stop_loc[i] /= cv->weights[in_numpts-1];
            }
        break;
      default:
        *msg = EMS_E_InvalidArg;
      }
    }
  else
    {
    switch (indata->datatype) 
      {
      case EMSdata_object:
        stat_OM = om$send (msg = message GRvg.GRgetsize (&msg_loc, mattyp,
                   mat, (IGRlong *) &blksize), 
		   targetid = indata->data.object->objid,
                   targetos = indata->data.object->osnum,
                   senderid = NULL_OBJID);
        EMomerr_exit (stat_OM, ret_end);
        EMerr_hndlr (EMis_error (msg_loc), *msg, EMS_E_OMerror, ret_end);

        cv = (struct IGRbsp_curve *) om$malloc (size = blksize);
        EMerr_hndlr (!cv, *msg, EMS_E_NoDynamicMemory, ret_end);

        stat_OM = om$send (msg = message GRvg.GRgetgeom (&msg_loc, mattyp,
                   mat, (IGRchar *) cv), targetid = indata->data.object->objid,
                   targetos = indata->data.object->osnum,
                   senderid = NULL_OBJID);
        EMomerr_exit (stat_OM, ret_end);
        EMerr_hndlr (EMis_error (msg_loc), *msg, EMS_E_OMerror, ret_end);

        in_numpts = cv->num_poles;
        in_pts = cv->poles;
        blksize = numpts * 3 * sizeof (IGRdouble);
        OM_BLOCK_MOVE (in_pts, start_loc, blksize);
        OM_BLOCK_MOVE (&in_pts[(in_numpts-numpts)*3], stop_loc, blksize);
        poly.num_points = numpts;
        poly.points = stop_loc;
        EMrevpyline (&msg_loc, &poly, 3, MAXINT);
        break;
      case EMSdata_poly3d:
        in_numpts = indata->data.poly->num_points;
        in_pts = indata->data.poly->points;
        blksize = numpts * 3 * sizeof (IGRdouble);
        OM_BLOCK_MOVE (in_pts, start_loc, blksize);
        OM_BLOCK_MOVE (&in_pts[(in_numpts-numpts)*3], stop_loc, blksize);
        poly.num_points = numpts;
        poly.points = stop_loc;
        EMrevpyline (&msg_loc, &poly, 3, MAXINT);
        break;
      case EMSdata_curve3d:
        cv = indata->data.curve;
        in_numpts = indata->data.curve->num_poles;
        in_pts = indata->data.curve->poles;
        blksize = numpts * 3 * sizeof (IGRdouble);
        OM_BLOCK_MOVE (in_pts, start_loc, blksize);
        OM_BLOCK_MOVE (&in_pts[(in_numpts-numpts)*3], stop_loc, blksize);
        if (cv->rational)
          for (i=0; i<numpts*3; i++)
            {
            start_loc[i] /= cv->weights[i/3];
            stop_loc[i] /= cv->weights[in_numpts-numpts+(i/3)];
            }
        poly.num_points = numpts;
        poly.points = stop_loc;
        EMrevpyline (&msg_loc, &poly, 3, MAXINT);
        break;
      default:
        *msg = EMS_E_InvalidArg;
      }
    }
ret_end:
  if (cv && indata->datatype == EMSdata_object)
    om$dealloc (ptr = cv);
  EMWRAPUP (*msg, stat_OM, "EMgetendpts_xyz");
  return (stat_OM);
}

end implementation Root;

