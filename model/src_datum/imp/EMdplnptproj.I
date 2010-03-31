/*
Notes

 This override projects the input point onto the infinite definition of the
 reference plane.

 The argument 'proj_parms' can be NULL.

Bugs
 The (u, v) values for the projected point obviously do not make sense for
 the reference plane. Hence (0, 0) is always returned. One possible solution
 is to always have a plane geometry encompassing min/max design space limits
 and then evaluate a consistent pair of uv parameters.

History

 2/10/93   SM     Creation.
 6/23/93   Sudha  modified for BSprototype ansification

*/
class implementation EMSdatpln;

#include "EMSmsgdef.h"
#include "bserr.h"
#include "emserr.h"
#include "bsproj1.h"

method GRptproject(
  IGRlong       *EMmsg;                   /* Error return code */
  IGRshort      *matrix_type;           /* My matrix type */
  IGRmatrix     matrix;                 /* My module matrix */
  IGRpoint      point;                  /* The input point */
  IGRpoint      proj_pt;                /* The projected point */
  struct        GRparms *proj_parms)    /* The projected parms */

{
 IGRlong		sts = OM_S_SUCCESS;
 struct IGRplane	myplane;
 IGRvector		normal;
 IGRpoint		plpoint;
 IGRlong		rc;

 *EMmsg = EMS_S_Success;
 /*
 * Initialize the projection parameters
 */
 if(proj_parms)
  {
   proj_parms->u = 0.0;
   proj_parms->v = 0.0;
   proj_parms->polygon_inx = 0;
   proj_parms->leaf_id.objid = my_id;
   proj_parms->leaf_id.osnum = OM_Gw_current_OS;
  }

 myplane.point = plpoint;
 myplane.normal = normal;

 /* Get my plane definition.
 */
 sts = om$send(msg = message EMSdatpln.GRdetplane(EMmsg, matrix_type, matrix, 
       &myplane), targetid = my_id);
 if(!(1&*EMmsg&sts)) goto wrapup;

 /* Project away..
 */
 (void) BSproj1(&rc, point, myplane.normal, myplane.point, proj_pt);
 if(rc!=BSSUCC)
  {
   *EMmsg = EMS_E_Fail;
   goto wrapup;
  }

wrapup:
EMWRAPUP(*EMmsg, sts, "EMSdatpln.GRptproject");
return(sts);
}

end implementation EMSdatpln;
