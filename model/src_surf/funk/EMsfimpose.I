/*
  ABSTRACT

    This function takes is an EMSinters list (inters) for a surface object
    (sfobj) as input and imposes this intersection list as the new boundary.
    
  OPTIONS

    - trace_opts, bool_opts. Specifiable as before.
    - dprobj may be NULL_OBJID. In this case, no save state is done.
    - display_count, display_ids can be NULL. In this case, no display
      takes place.

  ALGORITHM
  
    TBD
*/

class implementation EMSsubbs;

#include "emssfintdef.h"

/* pathway flags */
extern IGRboolean _pathway_trim, _pathway_orient;

   
IGRlong EMimpose_boundary_w_intersection (msg, trace_opts, bool_opts, md_env,
                                          sfobj, inters, dprobj, 
                                          display_count, display_ids)
IGRlong *msg;
IGRushort trace_opts, bool_opts;
struct GRmd_env *md_env;
GRobjid sfobj;
struct EMSinters *inters;
GRobjid dprobj;
IGRint *display_count;
struct GRid **display_ids;
{
  IGRint stat_OM;
  IGRlong msg_loc;
  IGRushort loc_opts;
  GRspacenum os;
  struct GRid tmpid;
  struct EMSinters *p_inters;
  struct EMSintobj *p_intobj;
  struct EMSsftracedata sftrace;

  IGRboolean save_pathway_trim, save_pathway_orient;

  *msg = msg_loc = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  os = md_env->md_id.osnum;

  /*
   * If any of the uv-dataselects are not yet EMSedges, convert them
   * to be so.
   */

  for (p_inters=inters; p_inters; p_inters=p_inters->next)
    {
    p_intobj = p_inters->cvs;
    while (p_intobj)
      {
      EMconvert_to_edge (&msg_loc, p_intobj, os);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
      if (p_intobj->other_intobj_node)
        {
        EMconvert_to_edge (&msg_loc, p_intobj->other_intobj_node, os);
        EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
        }
      p_intobj = p_intobj->next;
      }
    }

  /*
   * Trace the input EMSinters list. Use the options passed in.
   */

  loc_opts = trace_opts | EMS_SFINT_SKIPSFINT;

  save_pathway_trim = _pathway_trim;
  save_pathway_orient = _pathway_orient;
  _pathway_trim = 0;
  _pathway_orient = 0;

  stat_OM = EMintersect_surfaces (&msg_loc, NULL, &md_env->md_env, 
             0, NULL, NULL, loc_opts, NULL, NULL, NULL, NULL, NULL,
             &inters, NULL, &sftrace, NULL, NULL, NULL, NULL);

  _pathway_trim = save_pathway_trim;
  _pathway_orient = save_pathway_orient;

  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
  
  tmpid.objid = dprobj;
  tmpid.osnum = os;
  loc_opts = bool_opts | 
             (display_count && display_ids ? EMSsfbool_opt_display : NULL);
  if (inters)
  {
    stat_OM = EMboolean_surfaces_w_intersection (&msg_loc, &tmpid,
               EMSbool_intersect, md_env, sfobj, 0, NULL, inters, NULL,
               &sftrace, NULL, NULL, NULL, loc_opts,
               display_count, display_ids, NULL);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
  }

ret_end:
/* fix for mlk */
  EMsfinttrace_free (&msg_loc, sftrace.num_grps, sftrace.num_subgrps_grp,
     sftrace.num_elems_subgrp, sftrace.elems, sftrace.subgrp_rev,
     sftrace.elem_rev, sftrace.grp_closed, sftrace.subgrp_closed);

  EMWRAPUP (*msg, stat_OM, "EMimpose_boundary_w_intersection");
  return (stat_OM);
}

end implementation EMSsubbs;
