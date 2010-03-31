class implementation EMSpartsupp;

#include "OMmacros.h"
#include "emsdef.h"
#include "EMSopt.h"
#include "asbox.h" /*NULL_GRID*/
#include "nddef.h" /*ND_NEW*/
#include <stdio.h>
#include "EMSdpr.h"
#include "EMSkey.h"
#include "REcurve.h"
#include "REpointer.h"

from EMSsuppress import EMget_suppress_id;
from EMSdpr      import EMget_dpr_props;
from EMSpointer import EMget_pointer_info, EMput_pointer_info;
from EMSassoc   import EMget_info, EMput_info;

/*
Given a group_comp_id get its index stored in the part suppress object.
*/
method EMget_index_of_comp_id(IGRlong *EMmsg; 
                              GRobjid   group_comp_id;
                              IGRushort *group_comp_inx;
                              IGRuint   *total_group_count;
                              IGRushort options)
{
  IGRuint       comp_vla_cnt, ii;


  *EMmsg = EMS_S_Success;

  comp_vla_cnt = om$dimension_of(varray = ME.EMSpartsupp->comp_info);
    
  for(ii=0; ii<comp_vla_cnt; ii++)
  {
    if (ME.EMSpartsupp->comp_info[ii].comp_id == group_comp_id)
    {
      *group_comp_inx = ME.EMSpartsupp->comp_info[ii].comp_index;
      break;
    }
  }

  if (total_group_count) *total_group_count = comp_vla_cnt;
  
  return(OM_S_SUCCESS);
}                              


/*
Get all group comp ides and their indices from the part suppress object.
Note that the ptr id is not returned since it is only needed by the 
move_comp method.
*/
method EMget_comp_info(IGRlong         *EMmsg;
                       IGRuint         *group_count;
                       GRobjid         **group_comp_ids;
                       IGRushort       **group_comp_indices;
                       IGRushort       options)
{
  IGRuint       comp_vla_cnt, ii;


  *EMmsg = EMS_S_Success;

  comp_vla_cnt = om$dimension_of(varray = ME.EMSpartsupp->comp_info);
    
  if (group_count) *group_count = comp_vla_cnt;

  if (group_comp_ids)
  {
    *group_comp_ids = (GRobjid *) 
                      om$malloc(size = comp_vla_cnt * sizeof(GRobjid));
    if (!*group_comp_ids) {*EMmsg = EMS_E_NoDynamicMemory; goto wrapup;}

    for(ii=0; ii<comp_vla_cnt; ii++)
    {
      (*group_comp_ids)[ii] = ME.EMSpartsupp->comp_info[ii].comp_id;
    }
  }

  if (group_comp_indices)
  {
    *group_comp_indices = (IGRushort *) 
                          om$malloc(size = comp_vla_cnt * sizeof(IGRushort));
    if (!*group_comp_indices) {*EMmsg = EMS_E_NoDynamicMemory; goto wrapup;}

    for(ii=0; ii<comp_vla_cnt; ii++)
    {
      (*group_comp_indices)[ii] = ME.EMSpartsupp->comp_info[ii].comp_index;
    }
  }

wrapup:
  EMWRAPUP(*EMmsg, *EMmsg, "partsup.get_comp_info")
  return(OM_S_SUCCESS);
}                              


method EMget_partial_suppress_id(IGRlong         *EMmsg;
                                 GRobjid         *partial_suppress_id;
                                 OMuword         options)
{
  *EMmsg = EMS_S_Success;
  *partial_suppress_id = my_id;
  return(OM_S_SUCCESS);
}                                 



/*
Description
    The pointers & MSC who just generated keys to the components of the feature
    are incorrect because they took into account the group comp id.  Must
    get the keys from the ptrs adjust and store.
*/
#argsused
static IGRlong EFfix_up_ptrs(EMmsg, fea_id, group_comp_id, num_ptrs, ptr_ids,
                             orig_group_owner_id,
                             osnum, to_suppress, options)
IGRlong         *EMmsg;
GRobjid         fea_id, group_comp_id;
IGRuint         *num_ptrs;
GRobjid         **ptr_ids, orig_group_owner_id;
OMuword         osnum;
IGRboolean      to_suppress;
OMuword         options;
{
  IGRlong         OM_stat=OM_S_SUCCESS;
  IGRuint         g_c_inx, child_cnt, ii, info_size, key_size, g_c_cnt=0,
                  ptr_type;
  GRobjid         loc_ptr_id;
  char            *info=NULL;
  struct EMSobjid_key *objid_key = NULL;
  struct EMSkey       *key = NULL;
  struct EMSlong_key  *long_key = NULL;
  OM_S_CHANSELECT to_children, to_comps;
  OMuword         dumosnum;
  extern OMuword  OPP_EMSpointer_class_id, OPP_GAcurve_class_id;


  *EMmsg = EMS_S_Success;

  if (to_suppress)
  {
    *num_ptrs = 0;
    *ptr_ids = NULL;
  }

  EMmake_chanselect(NDchildren_children, &to_children);
  OM_stat = om$get_channel_count(objid = fea_id,
                                 osnum = osnum,
                                 p_chanselect = &to_children,
                                 count = &child_cnt);
  if (!(1 & OM_stat)) goto wrapup;
                                   
  if (!child_cnt) goto wrapup;

  if (to_suppress)
  {
    /*Just allocate memeory for all ptrs.  A bit less efficient but simpler.*/
    *ptr_ids = (GRobjid *) om$malloc(size = child_cnt * sizeof(GRobjid));
    if (!*ptr_ids) {*EMmsg = EMS_E_NoDynamicMemory; goto wrapup;}
  }

  EMmake_chanselect(GRcmpowner_to_components, &to_comps);  
  OM_stat = om$get_index(objid_c = orig_group_owner_id,
                         osnum_c = osnum,
                         p_chanselect = &to_comps,
                         objid = group_comp_id,
                         indexaddr = &g_c_inx);
  if (!(1 & OM_stat)) goto wrapup;

  OM_stat = om$get_channel_count(objid = orig_group_owner_id,
                                 osnum = osnum,
                                 p_chanselect = &to_comps,
                                 count = &g_c_cnt);
  if (!(1 & OM_stat)) goto wrapup;

  if (orig_group_owner_id != fea_id)
  {
    /*group fea is suppressed so all added stuff has been moved to the
     * suppress object which must be used to get count and index.  Then the
     * index and count on the comps chan must be adjusted to refect the
     * base component which is not on the suppres obj.
     */
    g_c_inx++;
    g_c_cnt++;
  }

  for(ii=0; ii<child_cnt; ii++)
  {
    IGRboolean  got_ptr;

    OM_stat = om$get_objid_at_index(objid = fea_id,
                                    osnum = osnum,
                                    p_chanselect = &to_children,
                                    index = ii,
                                    objidaddr = &loc_ptr_id,
                                    osnumaddr = &dumosnum);
    if (!(1 & OM_stat)) goto wrapup;                                    

    if (!(got_ptr = EFisAncestryValid(EMmsg, loc_ptr_id, osnum,
                                      OPP_EMSpointer_class_id, FALSE)) &&
        !EFisAncestryValid(EMmsg, loc_ptr_id, osnum, OPP_GAcurve_class_id, 
                           FALSE)) continue;

    info_size = 0;

    if (info)
    {
      om$dealloc(ptr = info);
      info = NULL;
    }

    if (got_ptr)
    {
      /*Get the ptr info*/
      OM_stat = om$send(msg = message EMSpointer.EMget_pointer_info(EMmsg,
                                      NULL, &ptr_type, &info_size, &info),
                        senderid = fea_id,
                        targetid = loc_ptr_id,
                        targetos = osnum);
      if (!(1 & OM_stat & *EMmsg)) goto wrapup;

      if (!info_size) {*EMmsg = EMS_E_InvalidCase; goto wrapup;}

      if (ptr_type == EMS_ASkey_and_id)
      {
        key_size = (info_size - sizeof (struct EMSobjid_key));
        objid_key = (struct EMSobjid_key *) info;
        key = (struct EMSkey *) objid_key->key_info;
      }
      else if (ptr_type == EMS_ASobject_key)
      {
        key_size = info_size;
        key = (struct EMSkey *) info;
      }
      else if (ptr_type == EMS_ASlong_key)
      {
	long_key = (struct EMSlong_key *)info;
	key = (struct EMSkey *)long_key->key_info;
	if(long_key->noncount_st.offset >0 )
	  key_size = long_key->noncount_st.offset - sizeof(struct EMSlong_key);
	else
	  key_size = info_size - sizeof(struct EMSlong_key);
      }
      else {*EMmsg = EMS_E_InvalidArg; goto wrapup;}
    }
    else
    {
      OM_stat = om$send(msg = message EMSassoc.EMget_info(EMmsg, NULL, 
                                      &ptr_type, &info_size, &info), 
                        senderid = fea_id,
                        targetid = loc_ptr_id,
                        targetos = osnum);
      if (!(1 & OM_stat & *EMmsg)) goto wrapup;

      if (!info_size) {*EMmsg = EMS_E_InvalidCase; goto wrapup;}

      /*Decipher it*/
      if (ptr_type == EMSmsc_id_key)
      {
        key_size = (info_size - sizeof (struct EMSobjid_key));
        objid_key = (struct EMSobjid_key *) info;
        key = (struct EMSkey *) objid_key->key_info;
      }
      else if (ptr_type == EMSmsc_key)
      {
        key_size = info_size;
        key = (struct EMSkey *) info;
      }
      else if( ptr_type == EMSmsc_long_key)
      {
	long_key = (struct EMSlong_key *)info;
	key = (struct EMSkey *)long_key->key_info;
	if(long_key->noncount_st.offset >0 )
	  key_size = long_key->noncount_st.offset - sizeof(struct EMSlong_key);
	else
	  key_size = info_size - sizeof(struct EMSlong_key);
      }
      else {*EMmsg = EMS_E_InvalidArg; goto wrapup;}
    }

    /*Two cases arise based on the key[0] sub item type.
     *  1st. if the type is CONNECTOR then know the key is thru a group comp
     *         id down to a surface or topology.  Here need to adjust the
     *         key based on the new surface index after identified group
     *         comp id is removed.
     *
     *  2nd. if the type is LOOP then know the key is into the SSI to a loop
     *         and perhaps on to an edge.  Here need to determine how many
     *         loops are generated as a result of the identified group comp id
     *         and have the key adjusted to not count for these.
     */

    /*Is key thru a group_comp_id?*/
    if (key[0].sub_item_type == EMSkey_CONNECTOR)
    {
      if (to_suppress)
      {
        /*See if got the ptr to the group_comp_id.  If so record & skip.*/
        if (key[0].chan_index == g_c_inx) 
        {
          (*ptr_ids)[*num_ptrs] = loc_ptr_id;
          (*num_ptrs)++;
        }
        else if (key[0].chan_count > g_c_cnt)
        {
          /*NOOP*/
          /*already suppressed*/
        }
        else 
        {
          key[0].chan_count--;
          if (key[0].chan_index >= g_c_inx) key[0].chan_index--;
        }
      }
      else /*! to_suppress*/
      {
        IGRuint jj;


        for(jj=0; jj<*num_ptrs; jj++)
        {
          if ((*ptr_ids)[jj] == loc_ptr_id) break;
        }
 
        if (jj != *num_ptrs)  /*loc_ptr_id is in ptr list - match*/
        {
          key[0].chan_count = g_c_cnt;
          key[0].chan_index = g_c_inx;
        }
        else if (key[0].chan_count >= g_c_cnt)
        {
          /*NOOP*/
          /*still suppressed*/
        }
        else 
        {
          key[0].chan_count++;
    
          if (key[0].chan_index >= g_c_inx) key[0].chan_index++;
        }
      }
    }
    else if (key[0].sub_item_type == EMSkey_LOOP) /*Is key thru SSI?*/
    {
    }
    else continue; /*none of the above*/

    if (got_ptr)
    {
      OM_stat = om$send(msg = message EMSpointer.EMput_pointer_info(EMmsg,
                                      NULL, ptr_type, info_size, info),
                        senderid = fea_id,
                        targetid = loc_ptr_id,
                        targetos = osnum);
      if (!(1 & OM_stat & *EMmsg)) goto wrapup;
    }
    else
    {
      OM_stat = om$send(msg = message EMSassoc.EMput_info(EMmsg,
                                      NULL, ptr_type, info_size, info),
                        senderid = fea_id,
                        targetid = loc_ptr_id,
                        targetos = osnum);
      if (!(1 & OM_stat & *EMmsg)) goto wrapup;
    }
  }

wrapup:
  if (info) om$dealloc(ptr = info);
  EMWRAPUP(*EMmsg, OM_stat, "boolfea.partialdelfea")
  return(OM_stat);
}


method EMmove_comp(IGRlong    *EMmsg; 
                   GRobjid    dpr;
                   IGRboolean to_partial_suppress;
                   GRobjid    group_comp_id;
                   OMuword    options)
/*
Description
    This message will move the given group_comp_id from the dpr to the 
    partial suppress object (if to_partial_suppress == TRUE) or the
    other way (if FALSE).

Returned values
    EMS_S_Success if all is well.

Notes
    Since the feature is most likely suppressed at the invocation of this
    method, the group comp ids will be on an EMSsuppress object on the
    child channel.  This message checks for such a case and properly handles
    it.
    
    About parameters:
      to_partial_suppress - If TRUE move group_comp_id  to the partial suppress
                            object. 
                            Else move it from partail suppress object back to
                            dpr. 
      options     - None so far.
       
History
    12/30/92    DLB     Creation.
*/ 
{
  IGRlong     OM_stat=OM_S_SUCCESS;
  IGRlong     owner_index=MAXINT, ii;
  IGRuint     group_comp_count=0, group_comp_inx, num_ptrs=0, total_ptrs;
  GRobjid     orig_group_owner, *ptr_ids=NULL;
  struct GRid owner_GRid;
  OM_S_CHANSELECT to_comps, to_children;
  IGRushort       dpr_props;
  IGRboolean      have_suppress_obj;
  

  *EMmsg = EMS_S_Success;
  
  group_comp_count = om$dimension_of(varray = ME.EMSpartsupp->comp_info);

  owner_GRid.osnum = OM_Gw_current_OS;

  EMmake_chanselect(GRcmpowner_to_components, &to_comps);

  OM_stat = om$send(msg = message EMSdpr.EMget_dpr_props(EMmsg, &dpr_props),
                    targetid = dpr);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;
                      
  if (dpr_props & EMS_NULL_STATE)
  {
    /*This is the typical case here where the dpr has already been unevaluated
     * in preparation for the partial delete/suppress.  In this case there
     * should be an EMSsuppress object on the child channel which contains all
     * the added group components on its comps channel.  This object is where
     * the movement should occur from & to.
     */
    GRobjid suppress_id=NULL_OBJID;

    EMmake_chanselect(NDchildren_children, &to_children);

    OM_stat = om$send(msg = message EMSsuppress.EMget_suppress_id(EMmsg,
                            &suppress_id, NULL),
                      senderid = dpr,
                      p_chanselect = &to_children);
    if (OM_stat == OM_W_UNKNOWN_MSG) OM_stat = OM_S_SUCCESS;
    else if (!(1 & OM_stat & *EMmsg)) goto wrapup;

    if (suppress_id == NULL_OBJID) {*EMmsg = EMS_E_InvalidCase; goto wrapup;}
    else orig_group_owner = suppress_id;

    have_suppress_obj = TRUE;
  }                                                  
  else 
  {
    have_suppress_obj = FALSE;
    orig_group_owner = dpr;   
  } 

  if (to_partial_suppress)
  {
    OM_stat = EFfix_up_ptrs(EMmsg, dpr, group_comp_id, &num_ptrs, &ptr_ids,
                            orig_group_owner, OM_Gw_current_OS, TRUE, NULL);
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;

    OM_stat = om$get_index(objid_c = orig_group_owner,
                           p_chanselect = &to_comps,
                           objid = group_comp_id,
                           indexaddr = &group_comp_inx);
    if (!(1 & OM_stat)) goto wrapup;                           

    if (!have_suppress_obj)
      group_comp_inx--; /*Subtract due to the base solid on the comps chan.*/

    if (!group_comp_count)
    {
      OM_stat = om$vla_set_dimension(varray = ME.EMSpartsupp->comp_info,
                                     size = 1);
      if (!(1 & OM_stat)) goto wrapup;                                     

      ME.EMSpartsupp->comp_info[0].comp_id = group_comp_id;
      ME.EMSpartsupp->comp_info[0].num_ptrs = num_ptrs;        
      ME.EMSpartsupp->comp_info[0].comp_index = group_comp_inx;        

      if (num_ptrs)
      {
        OM_stat = om$vla_set_dimension(varray = ME.EMSpartsupp->ptr_ids,
                                       size = num_ptrs); 
        if (!(1 & OM_stat)) goto wrapup;
        
        OM_BLOCK_MOVE(ptr_ids, ME.EMSpartsupp->ptr_ids, 
                      num_ptrs * sizeof(GRobjid));
      }
    }
    else
    {
      /*Determine the real index to store since the comps chan is relative.*/
      while (TRUE)
      {
        for(ii=0; ii<group_comp_count; ii++)
        {
          if (ME.EMSpartsupp->comp_info[ii].comp_index == group_comp_inx)
          {
            group_comp_inx++;
            break;
          }          
        }
        if (ii == group_comp_count) break; /*Made it all the way thru list*/
      }

      /*Got a good index now so store it*/
      OM_stat = om$vla_set_dimension(varray = ME.EMSpartsupp->comp_info,
                                     size = group_comp_count + 1);
      if (!(1 & OM_stat)) goto wrapup;                                     

      ME.EMSpartsupp->comp_info[group_comp_count].comp_id = group_comp_id;
      ME.EMSpartsupp->comp_info[group_comp_count].num_ptrs = num_ptrs;
      ME.EMSpartsupp->comp_info[group_comp_count].comp_index = group_comp_inx;

      /*Determine where to store new ptrs and how many*/
      for(ii=0, total_ptrs=0; ii<group_comp_count; ii++)
      {
        total_ptrs += ME.EMSpartsupp->comp_info[ii].num_ptrs;
      }
      
      if (total_ptrs + num_ptrs)
      {
        OM_stat = om$vla_set_dimension(varray = ME.EMSpartsupp->ptr_ids,
                                       size = total_ptrs + num_ptrs);
        if (!(1 & OM_stat)) goto wrapup;                                     
  
        OM_BLOCK_MOVE(ptr_ids, &ME.EMSpartsupp->ptr_ids[total_ptrs],
                      num_ptrs * sizeof(GRobjid));
      }
    }

    /*Now move the group comp id from the dpr to me*/
    owner_GRid.objid = orig_group_owner;
    OM_stat = om$send(msg = message GRconnector.GRdisconn(EMmsg,
                            &owner_GRid), 
                      targetid = group_comp_id);
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;

    owner_GRid.objid = my_id;
    OM_stat = om$send(msg = message GRconnector.GRrigidconn(EMmsg,
                            &owner_GRid, &owner_index),
                      targetid = group_comp_id);
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;                        

    (void) EFsetsfstate(EMmsg, group_comp_id, OM_Gw_current_OS, EMS_O_OFF);
  }
  else
  {
    OMuint          group_comp_loc;
    OM_S_CHANSELECT to_comps;


    /*Safety check.*/
    EMmake_chanselect(GRcmpowner_to_components, &to_comps);
    OM_stat = om$is_objid_on_channel(object_c = me,
                                     p_chanselect = &to_comps,
                                     objid = group_comp_id);
    if (!(1 & OM_stat) || !group_comp_count) 
    {*EMmsg = EMS_E_InvalidCase; goto wrapup;}

    /*Get the stored index.*/
    for(ii=0; ii<group_comp_count; ii++)
    {
      if (ME.EMSpartsupp->comp_info[ii].comp_id == group_comp_id) break;
    }

    /*Better have found one!*/
    if (ii == group_comp_count) {*EMmsg = EMS_E_InvalidCase; goto wrapup;}

    group_comp_loc = ii;

    group_comp_inx = ME.EMSpartsupp->comp_info[ii].comp_index;

    if (group_comp_inx != 0)
    {
      /*Need to find the real index due to rel ordered chan*/
      while (TRUE)
      {
        for(ii=0; ii<group_comp_count; ii++)
        {
          if (ME.EMSpartsupp->comp_info[ii].comp_index == (group_comp_inx - 1))
          {
            group_comp_inx--;
            break;
          }          
        }
        if (ii == group_comp_count) break; /*Made it all the way thru list*/
        if (group_comp_inx == 0) break; /*cant be any lower*/
      }
    }

    if (!have_suppress_obj)
      group_comp_inx++; /*Add due to the base solid on the comps chan.*/

    owner_GRid.objid = my_id;
    OM_stat = om$send(msg = message GRconnector.GRdisconn(EMmsg,
                            &owner_GRid), 
                      targetid = group_comp_id);
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;

    owner_GRid.objid = orig_group_owner;
    owner_index = group_comp_inx;
    OM_stat = om$send(msg = message GRconnector.GRrigidconn(EMmsg,
                            &owner_GRid, &owner_index),
                      targetid = group_comp_id);
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;                        

    (void) EFsetsfstate(EMmsg, group_comp_id, OM_Gw_current_OS, EMS_O_ON);

    num_ptrs = ME.EMSpartsupp->comp_info[group_comp_loc].num_ptrs;

    if (num_ptrs)
    {
      IGRuint all_ptr_cnt, above_cnt;
      GRobjid *tmp_p_ptr_ids;

      for(ii=0, total_ptrs=0; ii<group_comp_loc; ii++)
      {
        total_ptrs += ME.EMSpartsupp->comp_info[ii].num_ptrs;
      }
  
      tmp_p_ptr_ids = &ME.EMSpartsupp->ptr_ids[total_ptrs];

      OM_stat = EFfix_up_ptrs(EMmsg, dpr, group_comp_id, 
                              &num_ptrs,
                              &tmp_p_ptr_ids, 
                              orig_group_owner, OM_Gw_current_OS, FALSE, NULL);
      if (!(1 & OM_stat & *EMmsg)) goto wrapup;
  
      /*Clean ptr_ids out of ptr vla*/
      all_ptr_cnt = om$dimension_of(varray = ME.EMSpartsupp->ptr_ids);

      above_cnt = all_ptr_cnt - total_ptrs - num_ptrs;
      if (above_cnt)
      {
        OM_BLOCK_MOVE(&ME.EMSpartsupp->ptr_ids[total_ptrs+num_ptrs], 
                      &ME.EMSpartsupp->ptr_ids[total_ptrs], 
                      above_cnt * sizeof(GRobjid));
      }      

      OM_stat = om$vla_set_dimension(varray = ME.EMSpartsupp->ptr_ids,
                                     size = total_ptrs + above_cnt);
      if (!(1 & OM_stat)) goto wrapup;
    }    

    /*Clean this group_comp_id out of the group_info vla*/
    if (group_comp_loc != (group_comp_count - 1))
    {
      OM_BLOCK_MOVE(&ME.EMSpartsupp->comp_info[group_comp_loc+1],
                    &ME.EMSpartsupp->comp_info[group_comp_loc],
                    (group_comp_count - group_comp_loc - 1) * 
                    sizeof(struct EMScomp_vla_struct));
    }

    OM_stat = om$vla_set_dimension(varray = ME.EMSpartsupp->comp_info,
                                   size = group_comp_count - 1);
    if (!(1 & OM_stat)) goto wrapup;                                     

    if (group_comp_count == 1) *EMmsg = EMS_I_WasLastGroupComp;
  }

wrapup:
  if (ptr_ids) om$dealloc(ptr = ptr_ids);
  EMWRAPUP(*EMmsg, OM_stat, "partsupp.EMmove_comp")
  return(OM_stat);  
}                      


/*
Delete the group comp id from instance data and the actual object.
This will occur during a partial fea del clean up process issued by
the fea del command.
Note that if only 1 group comp id has been suppressed then the entire 
EMSpartsupp object will be deleted along with the group_comp_id.
*/
method EMdelete_group_comp(IGRlong     *EMmsg;
                           GRobjid     group_comp_id;
                           struct GRmd_env *env;
                           OMuword         options)
{
  IGRlong       OM_stat=OM_S_SUCCESS;
  IGRuint       ii, group_comp_count, group_comp_loc;  


  group_comp_count = om$dimension_of(varray = ME.EMSpartsupp->comp_info);

  for(ii=0; ii<group_comp_count; ii++)
  {
    if (ME.EMSpartsupp->comp_info[ii].comp_id == group_comp_id) break;
  }

  if (!group_comp_count || ii == group_comp_count) /*Better find one!*/
  {*EMmsg = EMS_E_InvalidCase; goto wrapup;}

  group_comp_loc = ii;

  if (group_comp_count > 1)
  {
    /*Delete the group comp id*/
    OM_stat =om$send(msg = message GRgraphics.GRdelete(EMmsg, env),
                     targetid = group_comp_id);
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;                   

    /*Clean this group_comp_id out of the group_info vla*/
    if (group_comp_loc != (group_comp_count - 1))
    {
      OM_BLOCK_MOVE(&ME.EMSpartsupp->comp_info[group_comp_loc+1],
                    &ME.EMSpartsupp->comp_info[group_comp_loc],
                    (group_comp_count - group_comp_loc - 1) * 
                    sizeof(struct EMScomp_vla_struct));
    }

    OM_stat = om$vla_set_dimension(varray = ME.EMSpartsupp->comp_info,
                                   size = group_comp_count - 1);
    if (!(1 & OM_stat)) goto wrapup;                                     
  }
  else
  {
    /*No other group comps so just delete me*/
    OM_stat =om$send(msg = message GRgraphics.GRdelete(EMmsg, env),
                     targetid = my_id);
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;                   
  }  

wrapup:
  EMWRAPUP(*EMmsg, OM_stat, "partsupp.EMdelete_groupo_comp")
  return(OM_stat);  
}                           


method NDmove_to_root(IGRlong *EMmsg; struct GRid *src_grid;
                      struct GRmd_env *env)
{
  return(om$send(msg = message GRgraphics.GRdelete(EMmsg, env),
                 targetid = my_id));
}                      


method NDcompute_node(IGRlong *msg; IGRint cn_type;
                      IGRint count; struct GRid list []; 
                      struct GRmd_env *md_env)
{
  *msg = ND_COMP_SUCC;  
  return(OM_S_SUCCESS);
}                       


method debug()
{
  OMuint vla_cnt, ii;
  
  vla_cnt = om$dimension_of(varray = ME.EMSpartsupp->comp_info);

  fprintf(stderr, "partsupp - num comp_info = %d\n", vla_cnt);
  
  for(ii=0; ii<vla_cnt; ii++)
  {
    fprintf(stderr, 
     "	comp_info[%d]\n	comp_id = %d\n	num_ptrs = %d\n	comp_index = %d\n", 
            ii, ME.EMSpartsupp->comp_info[ii].comp_id, 
            ME.EMSpartsupp->comp_info[ii].num_ptrs, 
            ME.EMSpartsupp->comp_info[ii].comp_index); 
  }   

  return(OM_S_SUCCESS);
}

end implementation EMSpartsupp;
