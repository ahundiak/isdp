class implementation EMSdpr;

#include "EMSdpr.h"
#include "msdef.h"         /* MSSUCC               */
#include "EMSmsgdef.h"     /* EMWRAPUP support     */
#include "EMSlcdef.h"      /* LC_...               */
#include "stdio.h"
#include "emsdef.h"
#include "grerr.h"

%safe
#ifdef DLOAD
extern unsigned char EMS_locate_features;
#else
unsigned char EMS_locate_features=0;
#endif
%endsafe

/*
DLB     02/12/93        Fixed TR119301289.
*/

method GRlocate_owner(IGRlong *EMmsg; struct GRlc_cvl *cvl;
                      struct GRlc_path *path; IGRint *path_position)
{
  IGRlong  OM_stat=OM_S_SUCCESS;
  IGRulong loc_props;
  extern OMuword OPP_EMSsfmacro_class_id, OPP_EMSsfrndbool_class_id;
  extern IGRboolean EFis_dpr_a_feature();

            
  if (!(ME.EMSdpr->dpr_props & EMSIS_ACTIVE_PATH)) goto wrapup;

  /****************************************************************************
   *Fix problem where "rndbool" class are not marked as MACRO (after rc) but is
   * owned by macro obj.  - now fixed... but old design files...
   ***************************************************************************/
  if (!(ME.EMSdpr->dpr_props & EMS_MACRO_STATE) &&
      EFisAncestryValid(EMmsg, my_id, OM_Gw_current_OS, 
                        OPP_EMSsfrndbool_class_id, FALSE))
  {
    GRobjid         maybe_mac_id;
    OM_S_CHANSELECT to_owners;
    OMuword         dumosnum;
    EMmake_chanselect(GRconnector_to_owners, &to_owners);
    OM_stat = om$get_objid_at_index(object = me,
                                    p_chanselect = &to_owners,
                                    index = 0,
                                    objidaddr = &maybe_mac_id,
                                    osnumaddr = &dumosnum);
    if (1 & OM_stat)
    {
      if (EFisAncestryValid(EMmsg, maybe_mac_id, OM_Gw_current_OS, 
                            OPP_EMSsfmacro_class_id, FALSE))
        ME.EMSdpr->dpr_props |= EMS_MACRO_STATE;                            
    }
    else OM_stat = OM_S_SUCCESS;
  }                       
  /**********************************End fix**********************************/

  /****************************************************************************
   *Fix problem where "macro" classes are not marked as assoc.
   * fixed now... but old design files...  
   ***************************************************************************/
  if (!(ME.GRgraphics->properties & GRIS_ASSOCIATIVE) &&
      EFisAncestryValid(EMmsg, my_id, OM_Gw_current_OS, 
                        OPP_EMSsfmacro_class_id, FALSE))
  {
    OM_S_CHANSELECT to_comps;
    IGRshort grprops;
    EMmake_chanselect(GRcmpowner_to_components, &to_comps);
    OM_stat = om$send(msg = message GRgraphics.GRgetprops(EMmsg, &grprops),
                      p_chanselect = &to_comps,
                      from = 0, to = 0);
    if (1 & OM_stat & *EMmsg)
    {
      if (grprops & GRIS_ASSOCIATIVE) 
        ME.GRgraphics->properties |= GRIS_ASSOCIATIVE;  
      if (grprops & GRHAS_EXTERNAL_CONSTRAINT) 
        ME.GRgraphics->properties |= GRHAS_EXTERNAL_CONSTRAINT;  
    }
  }                       
  /**********************************End fix**********************************/


  if (EMS_locate_features)
  { /*Determine if the locate came from a surf of the feature.  If not
     * dont locate the feature.
     */
    OMuint          index;
    OM_S_CHANSELECT to_comps;

    EMmake_chanselect(GRcmpowner_to_components, &to_comps);
    OM_stat = om$get_index(objid_c = my_id,
                           p_chanselect = &to_comps,
                           objid = sender_id,
                           indexaddr = &index);
    if (!(1 & OM_stat)) goto wrapup;

    if (index == 0)
    {
      IGRushort dpr_props;

      OM_stat = om$send(msg = message EMSdpr.EMget_dpr_props(EMmsg,
                              &dpr_props), 
                        targetid = sender_id);
      if (!(1 & OM_stat & *EMmsg))
      {
        OM_stat = OM_S_SUCCESS; 
        *EMmsg = GR_I_NO_RESPONSE;
        goto wrapup;
      }
      else if (!(dpr_props & EMS_MACRO_STATE)) 
      {
        *EMmsg = GR_I_NO_RESPONSE;
        goto wrapup;
      }
    }            
    else if (!EFis_dpr_a_feature(EMmsg, my_id, OM_Gw_current_OS, NULL, 
                                NULL, NULL))
    {
      /*Added else case since my id might be a bool or stitch dpr which
       * has on index 1 a non-added item such as a feature.  So need to
       * return NO_RESPONSE in order to let that item locate - TR119301289.
       */
      *EMmsg = GR_I_NO_RESPONSE;
      goto wrapup;
    }
  }

  *EMmsg = MSSUCC;

  if (EMS_locate_features)
  {
    IGRboolean am_fea_head;
    if (ME.GRgraphics->properties & GRIS_ASSOCIATIVE &&
        EFis_dpr_a_feature(EMmsg, my_id, OM_Gw_current_OS, NULL, 
                           &am_fea_head, NULL))
    {
      if (am_fea_head)
      {
        GRobjid        group_component_id;
        OMuword        group_component_class;
        extern IGRlong EFis_feature_a_group_feature();

        if (EFis_feature_a_group_feature(EMmsg, my_id, OM_Gw_current_OS, 
                                         path, path_position, 
                                         &group_component_id, 
                                         &group_component_class, NULL))
        {
          /*Handle special cases of group features.  Here must locate the
           * group component first then the actual group feature (me).
           */
          IGRuint save_w_count;
          OMuword *save_class;
          
          save_w_count = cvl->classes->w_count;
          save_class = cvl->classes->p_classes;

          cvl->classes->w_count = 1;
          cvl->classes->p_classes = &group_component_class;

          OM_stat = om$send(msg = message GRowner.GRlocate_owner(EMmsg, cvl,
                                  path, path_position),
                            mode = OM_e_wrt_message,
                            targetid = my_id);

          cvl->classes->w_count = save_w_count;
          cvl->classes->p_classes = save_class;
          if (OM_stat == OM_I_STOP_SENDING) goto wrapup;
        }

        OM_stat = om$send(msg = message GRowner.GRlocate_owner(EMmsg, cvl,
                                path, path_position),
                          mode = OM_e_wrt_message,
                          targetid = my_id);
        goto wrapup;
      }
    }
  }

  loc_props = cvl->attributes.obj_attr.owner_action;

  if ( (loc_props & LC_INTERMIDIATE || 
        ME.EMSdpr->dpr_props & EMSIS_ACTIVE_STATE) && !EMS_locate_features )

  {
    OM_stat = om$send(msg = message GRowner.GRlocate_owner(EMmsg, cvl, path,
                      path_position),
                      mode = OM_e_wrt_message,
                      targetid = my_id);
  }
  else 
  {
    OMuint           count;
    OM_S_CHANSELECT  to_owners;

    to_owners.type = OM_e_addr;
    to_owners.u_sel.addr = &ME.GRconnector->to_owners;

    OM_stat = om$get_channel_count(object = me,
                                   p_chanselect = &to_owners,
                                   count = &count);
    if (count)
    {
      if (!(ME.GRgraphics->properties & GR_RIGID_RELATIONSHIP))
      {
        /*Safty check for rigid bit*/
        GRobjid     owner_id;
        OMuword     osnum;
        extern OMuword  OPP_EMScompsurf_class_id;

        OM_stat = om$get_objid_at_index(object = me,
                                        p_chanselect = &to_owners,
                                        index = 0,
                                        objidaddr = &owner_id,
                                        osnumaddr = &osnum);
        if (!(1 & OM_stat)) goto wrapup;
        if (EFisAncestryValid(EMmsg, owner_id, osnum, OPP_EMScompsurf_class_id,
                              FALSE))
        {
          /*Have composite owner but I'm not marked as rigidly owned!!*/
          fprintf(stderr,"Dpr %d has incorrect rigid owner bit.\n", my_id);
          fprintf(stderr,"Model may be corrupt.\n");
          ME.GRgraphics->properties |= GR_RIGID_RELATIONSHIP;
        }                              
      }

      OM_stat = om$send(msg = OPPmargs, 
                        p_chanselect = &to_owners,
                        from = 0,
                        to = 0);
    }
    else if (!EMS_locate_features)
    {
      /*Invalid case detected.*/
      ME.GRgraphics->properties &= ~GR_RIGID_RELATIONSHIP;
      ME.EMSdpr->dpr_props |= EMSIS_ACTIVE_STATE;

      fprintf(stderr,"Dpr %d has incorrect active state bit.\n", my_id);
      fprintf(stderr,"Model may be corrupt.\n");

      OM_stat = om$send(msg = message GRowner.GRlocate_owner(EMmsg, cvl, path,
                              path_position),
                        mode = OM_e_wrt_message,
                        targetid = my_id);
    }
  }

wrapup:
  EMWRAPUP(*EMmsg, OM_stat, "EMSdpr.GRlocate_owner")
  return(OM_stat);
}

/*
Description
    Given a feature id return TRUE if it is a group feature.

Return Values
    EMS_S_Success   - if all is well

Notes
    This function returns TRUE only if the "top" feature id given is part
    of a group.

    About parameters:
      options            - none so far.
      group_component_id - the id of the component to the group feature.

    The following classes (and subclasses) are considered valid group features:
      EMSboolfea.

    The following classes (and subclasses) MAY be considered valid group
    features in the future (but not now). 
      EMSsfround,
      EMSsfrndbool.
      
History
   DLB 12/28/92 Creation.
*/

IGRlong EFis_feature_a_group_feature(EMmsg, fea_id, fea_os, 
                                     path, path_position,
                                     group_component_id, 
                                     group_component_class,
                                     options)
IGRlong     *EMmsg;
GRobjid     fea_id;
OMuword     fea_os;
struct GRlc_path *path;
IGRint           *path_position;
GRobjid          *group_component_id;
OMuword          *group_component_class;
OMuword          options;
{
  IGRlong        OM_stat=OM_S_SUCCESS;
  extern OMuword OPP_EMSsfboolfea_class_id,
                 OPP_EMSsfround_class_id,
                 OPP_EMSsfrndbool_class_id;


  *EMmsg = EMS_S_Success;  

  if (EFisAncestryValid(EMmsg, fea_id, fea_os, 
                        OPP_EMSsfboolfea_class_id, FALSE))
  {
    OMuint cmp_cnt;
    OM_S_CHANSELECT to_comps;

    EMmake_chanselect(GRcmpowner_to_components, &to_comps);
    OM_stat = om$get_channel_count(objid = fea_id,
                                   osnum = fea_os,
                                   p_chanselect = &to_comps,
                                   count = &cmp_cnt);
    if (!(1 & OM_stat)) goto wrapup;
                                       
    if (cmp_cnt > 2) /*last state and multiple features*/
    {
      *group_component_id = path[*path_position].lc_info.located_obj.objid;

      om$get_classid(objid = *group_component_id,
                     osnum = fea_os,
                     p_classid = group_component_class);

      return(TRUE);
    }
  }

wrapup:
  EMWRAPUP(*EMmsg, OM_stat, "EFis_fea_a_group_fea")
  return(FALSE);
}
end implementation EMSdpr;

#if DLB_DECIDE_TO_ALLOW_ROUNDS_CONSIDERED_AS_GROUP_FEATURES
      EFisAncestryValid(EMmsg, fea_id, fea_os, 
                        OPP_EMSsfround_class_id, FALSE) ||
      EFisAncestryValid(EMmsg, fea_id, fea_os, 
                        OPP_EMSsfrndbool_class_id, FALSE))

    if (EFisAncestryValid(EMmsg, fea_id, fea_os, 
                          OPP_EMSsfrndbool_class_id, FALSE))
      *group_component_id = path[0].lc_info.located_obj.objid;
    else
#endif
