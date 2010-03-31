class implementation EMSdpr;

#include "EMSdpr.h"
#include "emsdef.h"

extern OMuword OPP_EMSsfmacro_class_id;

method EMget_feature_definition(IGRlong    *EMmsg;
                                IGRint     *feature_cnt;
                                GRobjid    **feature_ids;
                                IGRushort  options)

/*
Description
    Get the definition of a feature if sent to any part of the feature.

Return Values
    EMS_S_Success     if all is well.
    EMS_I_InvalidSend if sent to a non-feature.

Notes
    This message is primarily used to get all the DPR parts of a macro type
    feature.  If sent to a DPR thats part of a macro, this message will
    return all DPR ids that make up the macro INCLUDING the macro object.
    If sent to a DPR that is a feature but is not a macro feature, then only
    the one DPR will be return.  0 will be returned if sent to a DPR that is
    not considered a feature.

    Therefore, a macro feature can be determined by the feature_cnt return
    count (>1 - macro feature, 1 - nonmacro feature, 0 - nonfeature).
    
    About parameters:
      options - none so far.
               
      feature_cnt - must be provided.
      feature_ids - will be return the feature ids in a bottom up fashion i.e.
                    the macro feature id will be the last id in the list.

                    feature_ids may be passed as NULL if the user only
                    wants the count (perhaps for pre-allocation of memory).

                    *feature_ids should be passed as NULL if the user has
                    not pre-allocated memory.  Otherwise this routine will 
                    assume memory exists and use it.                    
History
   DLB 11/20/92 Creation.
*/
{
  IGRlong         OM_stat=OM_S_SUCCESS;
  IGRboolean      is_fea, is_fea_macro, is_fea_head, am_a_fea_head;
  extern IGRboolean EFis_dpr_a_feature();


  *EMmsg = EMS_S_Success;

  is_fea = EFis_dpr_a_feature(EMmsg, my_id, OM_Gw_current_OS, NULL,
                              &am_a_fea_head, &is_fea_macro);
  if (!(1 & *EMmsg)) goto wrapup;

  if (!is_fea) 
  {
    *feature_cnt = 0;
    *EMmsg = EMS_I_InvalidSend; 
    goto wrapup;
  }

  if (!is_fea_macro)
  {
    *feature_cnt = 1;

    if (feature_ids)
    {
      if (! *feature_ids)
      {
        *feature_ids = (GRobjid *) om$malloc(size = sizeof(GRobjid));
        if (! *feature_ids) {*EMmsg = EMS_E_NoDynamicMemory;goto wrapup;}
      }
      *feature_ids[0] = my_id;
    }
  }
  else
  {
    /*Dont know where within the feature I am at so first build the 
     * ids list going down then going up to the macro.  I will be inefficient
     * here wrt time in order to save code & complexity.
     */
    OMuint          num_feas=1; /*Start with me!!!*/
    GRobjid         cur_id, top_id, bot_id;
    OM_S_CHANSELECT to_comps, to_owners;
    OMuword         cur_os;


    EMmake_chanselect(GRconnector_to_owners, &to_owners);        
    EMmake_chanselect(GRcmpowner_to_components, &to_comps);

    bot_id = cur_id = my_id;
    while (TRUE)
    {
      OM_stat = om$get_objid_at_index(objid = cur_id,
                                      p_chanselect = &to_comps,
                                      index = 0,
                                      objidaddr = &cur_id,
                                      osnumaddr = &cur_os);
      if (!(1 & OM_stat)) goto wrapup;
    
      if (EFisAncestryValid(EMmsg, cur_id, cur_os, OPP_EMSdpr_class_id, FALSE)
          && EFis_dpr_a_feature(EMmsg, cur_id, cur_os, NULL, 
                                &is_fea_head, &is_fea_macro))
      {
        /*component id is a feature*/
        if (!is_fea_head && is_fea_macro)
        {
          /*not a fea head and is part of a macro so part of me...continue*/
          num_feas++;
          bot_id = cur_id;
        }
        else break;
      }
      else break;
    }

    if (am_a_fea_head) /*gotten from first is_dpr_a_feature call*/
    {
      /*NOOP - num_fea count is correct*/
    }                          
    else
    {
      /*now go figure out where the feature head is*/
      cur_id = my_id;
      while (TRUE)
      {
        OM_stat = om$get_objid_at_index(objid = cur_id,
                                        p_chanselect = &to_owners,
                                        index = 0,
                                        objidaddr = &cur_id,
                                        osnumaddr = &cur_os);
        if (!(1 & OM_stat)) goto wrapup;
    
        if (EFisAncestryValid(EMmsg, cur_id, cur_os, OPP_EMSdpr_class_id,
                              FALSE))
        {
          EFis_dpr_a_feature(EMmsg, cur_id, cur_os, NULL, 
                             &is_fea_head, &is_fea_macro);

          /*owner id is a dpr*/
          if (is_fea_head || is_fea_macro)
          {
            /*It is my head or part of me*/
            num_feas++;

            if (is_fea_head) break; /*its my head!*/
          }
          else break;
        }
        else break;
      }
    }

    *feature_cnt = num_feas;

    if (feature_ids)
    {
      OMuint ii;

      if (! *feature_ids)
      {
        *feature_ids = (GRobjid *)om$malloc(size = num_feas * sizeof(GRobjid));
        if (! *feature_ids) {*EMmsg = EMS_E_NoDynamicMemory;goto wrapup;}
      }

      (*feature_ids)[0] = bot_id;
      cur_id = bot_id;

      for(ii=1; ii<num_feas; ii++)
      {
        OM_stat = om$get_objid_at_index(objid = cur_id,
                                        p_chanselect = &to_owners,
                                        index = 0,
                                        objidaddr = &cur_id,
                                        osnumaddr = &cur_os);
        if (!(1 & OM_stat)) goto wrapup;

        (*feature_ids)[ii] = cur_id;
      }
    }
  }    

wrapup:
  EMWRAPUP(*EMmsg, OM_stat, "dpr.get_fea_definition")
  return(OM_stat);
}

/*
Description
    Given a dpr id return TRUE if it is a feature or part of a feature.

Return Values
    EMS_S_Success   - if all is well

Notes
    This function returns TRUE only if the "top" dpr id of a macro feature
    is given.  If a member of a macro feature is given then FALSE is returned
    along with the EMmsg of EMS_I_NotUnique.

    About parameters:
      options         - none so far.
      is_feature_head - returned as TRUE if the given dpr is the feature head.
      is_feature_macro- returned as TRUE if the given dpr is part of macro
                        feature.

    Obviously if got a feature & is_feature_macro is FALSE then is_feature_head
    will be TRUE. 

    The following classes (and subclasses) are considered valid features:
      EMSlift,
      EMSsfmkface,
      EMSsfround,
      EMSsfrndbool,
      EMSslslotfea,
      EMSslboolfea,
      EMSshslbool,
      
    The following classes (and subclasses) are not considered features at this
    point:
      EMSsfspltwsf,
      EMSsfboolean (certain subclasses are considered features - see above).

    The following classes (and subclasses) will never be considered features:
      EMSsfrembnd,
      EMSsfunitesf,
      EMSsfspltwsf,
      EMSsfsplit,
      EMSsfmove,
      EMSsfstitch.

History
   DLB 01/07/93 dpr is not a feature if not associative.
   DLB 11/20/92 Creation.
*/

IGRboolean EFis_dpr_a_feature(EMmsg, fea_id, fea_os, options, 
                              is_feature_head, is_feature_macro)
IGRlong     *EMmsg;
GRobjid     fea_id;
OMuword     fea_os;
OMuword     options;
IGRboolean  *is_feature_head, *is_feature_macro;
{
  IGRlong        OM_stat=OM_S_SUCCESS;
  IGRushort      dpr_props; 
  IGRboolean     is_bool=FALSE, is_mac, got_a_fea=FALSE;
  extern OMuword OPP_EMSsfboolean_class_id,
                 OPP_EMSlift_class_id, 
                 OPP_EMSsfmkface_class_id, 
                 OPP_EMSsfaddraft_class_id,
                 OPP_EMSsfround_class_id;

  *EMmsg = EMS_S_Success;  

  OM_stat = om$send(msg = message EMSdpr.EMget_dpr_props(EMmsg, &dpr_props),
                    senderid = NULL_OBJID,
                    targetid = fea_id,
                    targetos = fea_os);  
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;

  is_mac = EFisAncestryValid(EMmsg, fea_id, fea_os, 
                             OPP_EMSsfmacro_class_id, FALSE);

  is_bool = EFisAncestryValid(EMmsg, fea_id, fea_os, 
                              OPP_EMSsfboolean_class_id, FALSE);

  if (dpr_props & EMS_MACRO_STATE || 
      is_mac || is_bool ||
      EFisAncestryValid(EMmsg, fea_id, fea_os, 
                        OPP_EMSlift_class_id, FALSE) ||
      EFisAncestryValid(EMmsg, fea_id, fea_os, 
                        OPP_EMSsfaddraft_class_id, FALSE) ||
      EFisAncestryValid(EMmsg, fea_id, fea_os, 
                        OPP_EMSsfmkface_class_id, FALSE) ||
      EFisAncestryValid(EMmsg, fea_id, fea_os, 
                        OPP_EMSsfround_class_id, FALSE))
  {
    if (is_bool)
    { /*only certain types of booleans are features*/
      extern OMuword OPP_EMSsfrndbool_class_id, 
                     OPP_EMSslslotfea_class_id,
                     OPP_EMSslboolfea_class_id,
                     OPP_EMSshslbool_class_id;
      if (EFisAncestryValid(EMmsg, fea_id, fea_os,
                            OPP_EMSsfrndbool_class_id, FALSE) ||
          EFisAncestryValid(EMmsg, fea_id, fea_os, 
                            OPP_EMSslboolfea_class_id, FALSE) ||
          EFisAncestryValid(EMmsg, fea_id, fea_os, 
                            OPP_EMSslslotfea_class_id, FALSE) ||
          EFisAncestryValid(EMmsg, fea_id, fea_os, 
                            OPP_EMSshslbool_class_id, FALSE)) got_a_fea = TRUE;
    }
    else got_a_fea = TRUE;
  }                          

  if (got_a_fea)
  {
    if (is_feature_macro)
    {
      if ((dpr_props & EMS_MACRO_STATE) || is_mac)
        *is_feature_macro = TRUE;
      else
        *is_feature_macro = FALSE;
    }
  
    if (is_feature_head)
    {
      if (!(dpr_props & EMS_MACRO_STATE))
        *is_feature_head = TRUE;
      else  
        *is_feature_head = FALSE;
    }
  }

wrapup:
  EMWRAPUP(*EMmsg, OM_stat, "EFis_dpr_a_feature")
  return(got_a_fea);  
}
end implementation EMSdpr;
