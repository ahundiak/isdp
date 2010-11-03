/*
  DESCRIPTION
    Converts a wireframe element or a composite curve into a profile.
    The components are converted to their SKclass equivalents.
    SKptvars are also created.  No constraints are placed.

  HISTORY
    Rajiv Agrawal : 12/12/92 : Removed the creation of automatic constraints
                    since this will be controlled by the user.
                    As usual, major cleanup.

*/

class implementation SKmgr;

#include "emsdef.h"
#include "emserr.h"
#include "EMSmsgdef.h"

from SKgeometry  import SKcreate_constraint_points;
from SKgeometry  import SKcreate_self_constraints;

extern OMuword OPP_SKmgr_class_id, OPP_SKcompcurve_class_id;

long EFcreate_profile ( msg, opts, comp_curve, md_env, origin, x_axis, z_axis,
                        mgr_GRid, cv_GRid )
long                  *msg;
unsigned short        opts;
struct GRid           *comp_curve;
struct GRmd_env       *md_env;
IGRdouble             *origin;
IGRdouble             *x_axis;
IGRdouble             *z_axis;
struct GRid           *mgr_GRid, *cv_GRid;
{
  int 			element_no, count;
  long               	status, owners_index;
  struct GRid        	sk_curve, skmgr_GRid;
  GRobjid		first, last;
  OMuword            	sk_classid;
  OMuword            	dum_os;
  struct GRsymbology 	symb;
  OM_S_CHANSELECT 	to_components;

  status = OM_S_SUCCESS;
  *msg = EMS_S_Success;

  ASsuper_construct();

  if (mgr_GRid->objid == NULL_OBJID)
  {
    dum_os = md_env->md_id.osnum;

    status = om$construct(classid = OPP_SKmgr_class_id,
        osnum = dum_os,
        p_objid = &skmgr_GRid.objid,
        msg = message SKmgr.SKinit(msg, NULL, NULL, origin, 
        x_axis, z_axis));
    EMerr_hndlr(!(1&status&*msg), *msg, EMS_E_Fail, ret_end);
    skmgr_GRid.osnum = dum_os;
  }
  else
  {
    skmgr_GRid = *mgr_GRid;
  }

  EFchange_to_sketch(msg, comp_curve, md_env, &sk_curve);
  EMerr_hndlr(!(1&*msg), *msg, EMS_E_Fail, ret_end);

  /* the symbology of the profile should be the one of the curve */
  status = om$send ( msg = message GRvg.GRgetsymb ( msg, &symb ),
      senderid = NULL_OBJID,
      targetid = sk_curve.objid,
      targetos = sk_curve.osnum );
  EMerr_hndlr ( !(1 & status&*msg ), *msg, EMS_E_Fail, ret_end );
  status = om$send ( msg = message GRvg.GRputsymb ( msg, &symb ),
      senderid = NULL_OBJID,
      targetid = skmgr_GRid.objid,
      targetos = skmgr_GRid.osnum );
  EMerr_hndlr ( !(1 & status&*msg ), *msg, EMS_E_Fail, ret_end );

  owners_index = 0;
  status = om$send (msg = message GRconnector.GRrigidconn(msg, 
      &skmgr_GRid, &owners_index),
      senderid = NULL_OBJID,
      targetid = sk_curve.objid,
      targetos = sk_curve.osnum);
  EMerr_hndlr(!(1&status&*msg), *msg, EMS_E_Fail, ret_end);

  status = om$get_classid (objid = sk_curve.objid,
      osnum = sk_curve.osnum,
      p_classid = &sk_classid);
  EMerr_hndlr(!(1&status&*msg), *msg, EMS_E_OMerror, ret_end);

  if (sk_classid == OPP_SKcompcurve_class_id)
  {
     count = 0;
     status = om$send (msg = message GRowner.GRget_number_components(msg,
                             &count),
                       targetid = sk_curve.objid,
                       targetos = sk_curve.osnum,
                       senderid = NULL_OBJID);
     EMerr_hndlr(!(1&status&*msg), *msg, EMS_E_Fail, ret_end);
    
     status = EMmake_chanselect(GRcmpowner_to_components, &to_components);

     element_no = 0;
     first = last = NULL_OBJID;
     status = om$send (msg = message SKgeometry.SKcreate_constraint_points(msg,
                             opts, &md_env->md_env.matrix_type, md_env->md_env.matrix, 
                             skmgr_GRid.objid, &first, &last, &element_no, count),
                       p_chanselect = &to_components,
                       senderid = sk_curve.objid,
                       targetos = sk_curve.osnum);
     EMerr_hndlr(!(1&status&*msg), *msg, EMS_E_Fail, ret_end);
  }
  else
  {
    element_no = 0;
    count = 1;
    first = last = NULL_OBJID;
    status = om$send (msg = message SKgeometry.SKcreate_constraint_points(msg,
                            opts, &md_env->md_env.matrix_type, md_env->md_env.matrix, 
                            skmgr_GRid.objid, &first, &last, &element_no, count),
                      senderid = NULL_OBJID,
                      targetid = sk_curve.objid,
                      targetos = sk_curve.osnum);
    EMerr_hndlr(!(1&status&*msg), *msg, EMS_E_Fail, ret_end);
  }


   status = om$send (msg = message SKgeometry.SKcreate_self_constraints
                            (msg, NULL, md_env, NULL, NULL),
                      targetid = sk_curve.objid, 
                      targetos = sk_curve.osnum, 
                      senderid = NULL_OBJID);
   EMerr_hndlr (EMSerror (status & *msg), *msg, EMS_E_Fail, ret_end);

  if (mgr_GRid->objid == NULL_OBJID)
    *mgr_GRid = skmgr_GRid;
  if (cv_GRid)
    *cv_GRid = sk_curve;

ret_end:
  EMWRAPUP ( *msg, status, "In EFcreate_profile error" );
  return status;
}

end implementation SKmgr;

