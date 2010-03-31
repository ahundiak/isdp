/* ###################   APOGEE COMPILED   ################## */
/*
  DESCRIPTION

    This function adds on the input geometry to the intersection list.
    'Tis written to work with the requirements of the ExecuteCurveFunction
    method for the surface-edges.

  HISTORY
   
    SS  :  03/08/88  :  Creation
    SM  :  02-Jun-88 :  ExecuteCurveFunction now also passes the edge type.
			It is a pointer so that NULL can mean unknown or
			don't care.
    NP  :  27-May-93 :  Function name "EMmkintlist" has changed to 
                        "EMmakeintlist" to reflect addition of two new 
                        parameters "cvtype_a" and  "cvtype_b".
*/

#include "EMS.h"
#include "OMminimum.h"
#include "OMmacros.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "igetypedef.h"
#include "dp.h"
#include "godef.h"
#include "gr.h"
#include "go.h"
#include "emsdattyp.h"
#include "emsinter.h"
#include "emsdef.h"
#include "emserr.h"
#include "EMSmsgdef.h"
#include "emssfcvs.h"

IGRint EMcatcvdata (geom, inters, invoker_info)
struct IGRpolyline *geom;
struct EMSinters **inters;
struct EMSinvoker_info *invoker_info;
{
  IGRint msg_loc, blksize;
  struct EMSdataselect uvdata;
  struct GRid dumobj;
  struct IGRpolyline *py;
  void EMmakeintlist();
  IGRint flags;
  IGRuchar *curve_type;

  flags = invoker_info->flags;
  curve_type = invoker_info->cvtype;

  blksize = geom->num_points * 2 * sizeof (IGRdouble);
  py = (struct IGRpolyline *) malloc (sizeof (struct IGRpolyline));
  py->points = (IGRdouble *) malloc (blksize);
  EMerr_hndlr (!py || !py->points, msg_loc, EMS_I_Stop, ret_end);

  dumobj.objid = NULL_OBJID;
  uvdata.datatype = EMSdata_poly2d;
  py->num_points = geom->num_points;
  OM_BLOCK_MOVE (geom->points, py->points, blksize);
  uvdata.data.poly = py;
  
  EMmakeintlist (&msg_loc, inters, NULL, &dumobj, NULL, NULL, NULL,NULL,NULL, 
	NULL, &uvdata, NULL, 
   FALSE, FALSE, NULL, NULL, NULL, NULL, NULL, NULL, TRUE, FALSE);
  EMerr_hndlr (EMSerror (msg_loc), msg_loc, EMS_I_Stop, ret_end);

ret_end:
  return (msg_loc);
}
