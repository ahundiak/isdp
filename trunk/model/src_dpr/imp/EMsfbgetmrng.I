class implementation EMSsfboolean;

#include "emsdef.h"
#include "EMSmsgdef.h"
#include "EMSdpr.h"

method EMgetModRange(IGRlong *EMmsg; 
                     struct EMSinlist *inlist; 
                     GRobjid nodes_side_id; 
                     struct GRmd_env *env)
/*
Description
    Get the range of the nodes_side_id and dump in inlist structure.

History
    DLB    11/30/92   Handle case of nodes_side_id equal to my_id.  This will
                      occur if IMMEDIATE_OP uneval of the DPR node.
                      The whole idea of getting the mod range is if
                      the area part of a boolean is being unevaluated which
                      results in the negative part becoming area.  If 
                      IMMEDIATE_OP case this is not an issue.  Therefore
                      simply return without getting a mod id or range.
    DLB    11/28/89   Creation.
*/
{
  IGRlong          OM_stat=OM_S_SUCCESS;
  enum EMSbooltype general_type;


  *EMmsg = EMS_S_Success;

  if (nodes_side_id == my_id)
  {
    goto wrapup;  /*See history note above. DLB 11/30/92*/
  }

  /* Get the operation type. */
  OM_stat = om$send(msg = message EMSsfboolean.EMget_operation_type(
                          EMmsg, NULL, NULL, &general_type, NULL, NULL, NULL,
                          NULL, NULL, NULL, NULL, NULL), 
                   targetid = my_id);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;

  if (general_type == EMSbool_difference)
  {
    OMuint     nodes_inx;
    IGRboolean world=TRUE;
    OM_S_CHANSELECT to_comps;

    EMmake_chanselect(GRcmpowner_to_components, &to_comps);
    OM_stat = om$get_index(object_c = me,
                           p_chanselect = &to_comps,
                           objid = nodes_side_id,
                           indexaddr = &nodes_inx);
    if (!(1 & OM_stat) || (nodes_inx == 0))
    {
      inlist->modlist.mod_id = nodes_side_id;

      OM_stat = om$send(msg = message GRgraphics.GRgetrang(EMmsg,
                              &env->md_env.matrix_type,
                              env->md_env.matrix,
                              &world, 
                              inlist->modlist.range),
                        targetid = nodes_side_id);
      if (!(1 & OM_stat & *EMmsg)) goto wrapup;
    }
  }

wrapup:
  EMWRAPUP(*EMmsg, OM_stat, "sfb.getModRng")
  return(OM_stat);
}
end implementation EMSsfboolean;
