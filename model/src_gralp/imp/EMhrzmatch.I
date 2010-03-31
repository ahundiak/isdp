/* ###################   APOGEE COMPILED   ################## */
/*                                                            */
/*
  EMhrzmatch.I

  Match this horizon loop onto a new surface.
  
  History:

    AIC  02 Aug 91   Creation.
    Jack 17 Sep 91   Replaced me->z parm in call to EMget_graphics_edges
                     with the GRid of the reference plane associated with
                     the old horizon loop.
    Jack 27 Sep 91   Changed so that only the cusp is created.  The new
                     associative stuff will take care of the horizon
                     edges. 
                     
*/
class implementation EMShorizon;

#include "OMmacros.h"

from EMSsubbs import EMget_graphics_edges;

method EMmatch_graphics_loops(IGRlong *EMmsg; struct GRmd_env *md_env;
                              GRobjid new_objid; GRspacenum new_osnum)
{
  IGRlong   sts;
  struct EMSobject_info parents[2];
  
  parents[1].grid.objid = new_objid;  
  parents[1].grid.osnum = new_osnum;  
  parents[1].env.md_id.objid = md_env->md_id.objid;
  parents[1].env.md_id.osnum = md_env->md_id.osnum;
  parents[1].env.md_env.matrix_type = md_env->md_env.matrix_type;
  OM_BLOCK_MOVE(md_env->md_env.matrix,parents[1].env.md_env.matrix,
               (16 * sizeof(IGRdouble)));


  sts = om$send(msg = message EMSsubbs.EMget_graphics_edges(
                      EMmsg,
                      NULL,
                      parents,
                      EMS_OPT_ONLY_CUSP,
                      NULL, 
                      NULL, 
                      NULL, 
                      NULL,
                      NULL, 
                      NULL),
                targetid = new_objid, targetos = new_osnum);
     if(! (1 & sts & *EMmsg)) goto wrapup;
     
wrapup:
  EMWRAPUP(*EMmsg, sts, "In EMShorizon.EMmatch_graphics_loops")  

  return sts;
}

end implementation EMShorizon;
