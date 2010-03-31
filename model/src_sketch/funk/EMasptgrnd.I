/*
   DESCRIPTION

     This message creates associative grounds on the element being passed
     in and connects the same to sketch_mgr. If the element is a line segment
     then the function will construct two associative grounds at its end
     points and for an arc it constructs three points.
 
     The point variables constructed are returned in vgptid. The space
     for this must be allocated by the caller. Currently if it is
     a line - space for 2 objids.
 
   RETURN CODES

     EMS_S_Success : If everything goes well.
     EMS_E_Fail : Some sort of an error.
     EMS_E_NotSupported : Grounds on this object not supported
  
  HISTORY
    
    pp  :  09/14/90  : Creation
    SS  :  06/19/91  : Redid some of the stuff
*/

class implementation SKgeometry;

#include "OMmacros.h"
#include "dimdload.h"
#include "dimmacros.h"
#include "dim.h"
#include "dimsrc.h"
#include "dpmacros.h"
#include "nddef.h"
#include "ndmacros.h"

#define RETURN_POINTS 1

from SKasptgrnd import SKinit_assocpt_ground;
from GRlinear import GRgetpolyline;

extern GRclassid OPP_GR3dlineseg_class_id;

void EMasptgrnd (msg, options, md_env, geomid, skmgrid,
                 num_vgpts, vgpts)
IGRlong *msg;
IGRushort options;
struct GRmd_env *md_env; 
struct GRid *geomid, *skmgrid;
IGRint *num_vgpts;
GRobjid *vgpts;
{
  IGRboolean 		stat_func, cycle_created;
  IGRlong 		msg_loc, stat_OM;
  IGRint 		i, action, num_roots;
  IGRdouble 		as_attr[10];
  IGRpoint 		pts[2];
  GRclassid 		geom_classid;
  GRobjid 		asptgrnd_objid;
  struct 		IGRpolyline py;
  struct 		GRid root_GRid[3], context_GRid;
 
  stat_OM = OM_S_SUCCESS;
  *msg = EMS_S_Success;

  *num_vgpts = 0;

  om$get_classid (osnum = geomid->osnum, objid = geomid->objid,
   p_classid = &geom_classid);

  if (om$is_ancestry_valid (subclassid = geom_classid,
       superclassid = OPP_GR3dlineseg_class_id) == OM_S_SUCCESS)
    {
    action = RETURN_POINTS;
    py.points = (double *) pts;
    stat_OM = om$send (msg = message GRlinear.GRgetpolyline(&msg_loc,
               &md_env->md_env.matrix_type, md_env->md_env.matrix,
               &action, &py), targetid = geomid->objid,
               targetos = geomid->osnum, senderid = NULL_OBJID);
    EMerr_hndlr (EMSerror (msg_loc & stat_OM), *msg, EMS_E_Fail, ret_end);

    context_GRid.objid = NULL_OBJID;

    as_attr[0] = DMkeypt;
    OM_BLOCK_MOVE (pts[0], &as_attr[1], sizeof (IGRpoint));
    stat_func = DMcreate_root (1, geomid, &context_GRid, as_attr, 
                 md_env, &root_GRid[0]);
    EMerr_hndlr (EMSerror (stat_func), *msg, EMS_E_Fail, ret_end);
 
    OM_BLOCK_MOVE (pts[1], &as_attr[1], sizeof (IGRpoint));
    stat_func = DMcreate_root (1, geomid, &context_GRid, as_attr, 
                 md_env, &root_GRid[1]);
    EMerr_hndlr (EMSerror (stat_func), *msg, EMS_E_Fail, ret_end);

    num_roots = 2;
    }
  else
    {
    *msg = EMS_E_NotSupported;
    goto ret_end;
    }

  /*
   * Check if the creation of these grounds to the sketch manager,
   * introduces a cycle into the system.
   */

  cycle_created = nd$dep_exist (l_root = skmgrid, nb_root = 1,
                   l_tip = &root_GRid[0], nb_tip = 1);
  EMerr_hndlr (cycle_created, *msg, EMS_I_InvalidCase, ret_end);

  /*
   * Create the associative point ground objects
   */

  for (i=0; i<num_roots; i++)
    {
    stat_OM = om$construct (classid = OPP_SKasptgrnd_class_id,
               p_objid = &asptgrnd_objid, osnum = skmgrid->osnum,
               msg = message SKasptgrnd.SKinit_assocpt_ground (&msg_loc,
               NULL, md_env, &root_GRid[i], NULL, skmgrid->objid, NULL,
               &vgpts[i]));
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

    (*num_vgpts)++;
    }

ret_end:
  EMWRAPUP (*msg, stat_OM, "EFasptgrnd");
  return;
}

end implementation SKgeometry;
