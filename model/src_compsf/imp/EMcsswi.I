class implementation EMSswcompsf;

#define FIRST  0

extern GRclassid OPP_EMSsfsolid_class_id;

method EMpack_paraminfo (IGRlong *msg; IGRushort opts;
                         struct EMSassoc_params *param_info;
                         IGRint *obj_type;
                         IGRchar **obj_info; IGRint *obj_info_size;
                         IGRint *num_parents;
                         struct GRid **parents, **asparents;
                         struct GRmd_env **md_envs;
                         OM_p_MESSAGE target_messg;
                         enum OM_e_wrt_flag target_messg_wrt_flag)
{
  IGRlong msg_loc, stat_OM;
  GRobjid parentobj, ownobj;
  GRspacenum dumos;
  GRclassid ownclass;
  OM_S_CHANSELECT chan_to_owners;
  enum OM_e_wrt_flag parentobj_mode;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  parentobj = my_id;
  parentobj_mode = OM_e_wrt_parent;

  if (ME.GRgraphics->properties & GR_RIGID_RELATIONSHIP)
    {
    ownobj = NULL_OBJID;
    EMmake_chanselect (GRconnector_to_owners, &chan_to_owners);
    om$get_objid_at_index (object = me, p_chanselect = &chan_to_owners,
     index = FIRST, objidaddr = &ownobj, osnumaddr = &dumos);
    EMerr_hndlr (ownobj == NULL_OBJID, *msg, EMS_E_InvalidCase, ret_end);

    om$get_classid (objid = ownobj, p_classid = &ownclass);
    if (om$is_ancestry_valid (subclassid = ownclass,
         superclassid = OPP_EMSsfsolid_class_id) == OM_S_SUCCESS)
      {
      parentobj = ownobj;
      parentobj_mode = OM_e_wrt_object;
      }
    }
  
  stat_OM = om$send (mode = parentobj_mode,
             msg = message EMSswcompsf.EMpack_paraminfo (&msg_loc, opts,
             param_info,
             obj_type,
             obj_info, obj_info_size,
             num_parents, parents, asparents, md_envs,
             target_messg, target_messg_wrt_flag),
             targetid = parentobj);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

ret_end:
  EMWRAPUP (*msg, stat_OM, "EMswcompsf.EMpackparam");
  return (stat_OM);
}

end implementation EMSswcompsf;



