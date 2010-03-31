class implementation EMSsurface;

#include "EMS.h"
#include "OMmacros.h"
#include "msdef.h"
#include "growner.h"
#include "emsdef.h"
#include "emserr.h"
#include "EMSmsgdef.h"
#include "emssfintdef.h"

extern GRclassid OPP_GRgrgrp_class_id;
/* pathway flags */
extern IGRboolean _pathway_trim, _pathway_orient;

from GRowner import GRpass_messg;

method EMowner_sfsfint (IGRlong *msg; 
                        struct GRmdenv_info *my_mdenv_info;
                        struct GRid *other_obj;
                        struct GRmdenv_info *other_mdenv_info;
                        IGRushort inters_options;
                        IGRushort outworld_options;
                        IGRushort outparam_option;
                        IGRushort trim_options;
                        struct GRvg_construct *const_list;
                        IGRint *num_inters;
                        struct EMSinters **my_inters, **other_inters;
                        GRobjid *inters_outputobj, *inters_endptsobj;
                        IGRchar *status_str)
{
  IGRboolean invalid_other_obj;
  IGRchar loc_status_str[MS_MAX_MSG_LENGTH];
  IGRlong i, j, len, msg_loc, stat_OM, pass_rc;
  GRclassid other_class, classid;
  GRobjid loc_outputobj, loc_endptsobj, objs[2];
  GRobjid *p_outobj, loc_outobj;
  GRspacenum const_os;
  GRclassid objclass;
  struct GRid my_grid;
  struct EMSdataselect other_data;
  OM_S_CLASSLIST sfclass_list;
  IGRboolean save_pathway_trim, save_pathway_orient;
  extern IGRlong EMintersect_surfaces(), EFbuild_graphic_group();

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;
  
  /*
   * Check if the other object is an owner. If so this message must be
   * passed down to any surfaces that might exist within the owner.
   */

  my_grid.objid = my_id;
  my_grid.osnum = OM_Gw_current_OS;

  om$get_classid (objid = other_obj->objid, osnum = other_obj->osnum,
   p_classid = &other_class);
  if (om$is_ancestry_valid (subclassid = other_class,
       superclassid = OPP_EMSsurface_class_id) != OM_S_SUCCESS)
    {
    invalid_other_obj = FALSE;
    if (om$is_ancestry_valid (subclassid = other_class,
         superclassid = OPP_GRowner_class_id) != OM_S_SUCCESS)
      invalid_other_obj = TRUE;
    EMerr_hndlr (invalid_other_obj, *msg, EMS_E_InvalidArg, ret_end);

    sfclass_list.p_classes = &OPP_EMSsurface_class_id;
    sfclass_list.w_count = 1;
    sfclass_list.w_flags = OM_CLST_subclass;

    return (om$send (msg = message GRowner.GRpass_messg (&pass_rc, NULL,
             OM_e_wrt_object, message EMSsurface.EMowner_sfsfint (msg,
             other_mdenv_info, &my_grid, my_mdenv_info, 
             inters_options, outworld_options, outparam_option, trim_options,
             const_list,
             num_inters, other_inters, my_inters,
             inters_outputobj, inters_endptsobj, status_str),
             other_mdenv_info,
             &sfclass_list, NULL, NULL, NULL, MAXINT), 
             targetid = other_obj->objid, targetos = other_obj->osnum,
             senderid = NULL_OBJID));
    }

  /*
   * The other object is a surface object. Invoke the function to compute
   * the intersection. Any output-objects must be merged into a graphic
   * group.
   */

  if (status_str)
    {
    loc_status_str[0] = NULL;
    len = strlen (status_str);
    if (len)
      {
      for (i=len-1; i>=0; i--)
        if (status_str[i] != '.' && status_str[i] != ' ')
          break;
      strncpy (loc_status_str, status_str, i+1);
      loc_status_str[i+1] = NULL;
      }
    }

  other_data.datatype = EMSdata_object;
  other_data.data.object = other_obj;
  loc_outputobj = NULL_OBJID;
  loc_endptsobj = NULL_OBJID;

  save_pathway_trim = _pathway_trim;
  save_pathway_orient = _pathway_orient;
  _pathway_trim = 0;
  _pathway_orient = 0;

  stat_OM = EMintersect_surfaces (&msg_loc, &my_grid, my_mdenv_info,
             1, &other_data, other_mdenv_info,
             inters_options, outworld_options, outparam_option, trim_options,
             const_list, num_inters, my_inters, other_inters, NULL, NULL,
             inters_outputobj ? &loc_outputobj : NULL,
             inters_endptsobj ? &loc_endptsobj : NULL,
             status_str ? loc_status_str : NULL);

  _pathway_trim = save_pathway_trim;
  _pathway_orient = save_pathway_orient;

  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
  EMerr_hndlr (inters_options & EMS_SFINT_YESORNO && *num_inters,
   stat_OM, OM_I_STOP_SENDING, ret_end);


  for (i=0; i<2; i++)
    {
    p_outobj = (i == 0) ? inters_outputobj : inters_endptsobj;
    loc_outobj = (i == 0) ? loc_outputobj : loc_endptsobj;

    if (p_outobj && loc_outobj != NULL_OBJID)
      {
      if (*p_outobj != NULL_OBJID)
        {
        objs[0] = *p_outobj;
        objs[1] = loc_outobj;
        stat_OM = EFbuild_graphic_group (2, objs, NULL, const_list,
                   p_outobj, &msg_loc);
        EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

        const_os = const_list->env_info->md_id.osnum;
        for (j=0; j<2; j++)
          {
          om$get_classid (objid = objs[i], osnum = const_os,
           p_classid = &objclass);
          if (om$is_ancestry_valid (subclassid = objclass,
               superclassid = OPP_GRgrgrp_class_id) == OM_S_SUCCESS)
            om$send (msg = message GRgraphics.GRdelete (&msg_loc,
             const_list->env_info), targetid = objs[i], targetos = const_os);
          }
        }
      else
        *p_outobj = loc_outobj;
      }
    }

ret_end:
  EMWRAPUP (*msg, stat_OM, "EMsfosfsfint");
  return (stat_OM);
}

end implementation EMSsurface;
