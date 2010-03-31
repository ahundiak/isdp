/* ###################   APOGEE COMPILED   ################## */
/* ###################   ANSI   COMPILED   ################## */
class implementation EMSsurface;

#include "EMSkey.h"
#include "EMSdpr.h"

from EMSdpr import EMgetInInfo;

extern OMuword OPP_EMSgraloop_class_id,
               OPP_ACncpx_class_id;

IGRlong EFgenerate_id_from_key(EMmsg, creator_id, creator_os, key_count,
                               key, created_id, options)   
IGRlong           *EMmsg; 
GRobjid           creator_id;
OMuword           creator_os;
IGRint            key_count;
struct EMSkey     *key;
GRobjid           *created_id;
IGRushort options;
/*
Description
    This function will return the created_id given the creator_id and key.

Return Values    
    EMS_S_Success if all is well.
    EMS_I_NotFound if topology mismatch was found.

Notes
    About params:
        creator_id - Id key is relative to.
        key_count - number of keys in the key array.
        key - keys relative to creator_id.
        created_id - returned id.
        options - none so far...

History
    PP  04/29/92    Modified the code to specially handle mismatches
                    that occur for components of a construction macro
    PP  10/10/91    Modified the key generation of graphics loops to
                    not take into account the presence of graphics data
    AIC 08/15/91    Support graphics loops.
    DLB 05/22/91    Support key into ininfo list of DPR.
    DLB 05/20/91    Return EMS_I_NotFound on topology mismatch.
    DLB 05/15/91    Creation.
*/
{
  IGRlong             OM_stat=OM_S_SUCCESS;
  OMuint              count, chan_count;
  GRobjid             lower_item;
  OM_S_CHANSELECT     chansel;
  OM_S_OBJECT_LINKAGE obj_link;
  struct EMSinlist    inlist;
  OMuword             dumosnum, ininf_opts;
  unsigned char       sub_item_type;
  IGRboolean          free_inlist=FALSE;
  extern IGRboolean   EFisAncestryValid();
  extern OMuword      OPP_EMSsubbs_class_id;


  *EMmsg = EMS_S_Success;

/*
 * Added sub-item type check to prevent using the loopset when
 * generating an id for the graphics loops. AIC

  if (key[0].sub_item_type != EMSkey_CONNECTOR && 
      EFisAncestryValid(EMmsg, creator_id, creator_os,
                        OPP_EMSdpr_class_id, FALSE))
 */

  if (key[0].sub_item_type != EMSkey_GRALOOP &&
      key[0].sub_item_type != EMSkey_CONNECTOR && 
      EFisAncestryValid(EMmsg, creator_id, creator_os,
                        OPP_EMSdpr_class_id, FALSE))
  {
    ininf_opts = (EMget_in_inf_NO_SURFS | EMget_in_inf_NO_EDGES_FROM_LOOPS);

    ininf_opts |= key[0].sub_item_type == EMSkey_LOOP ? EMget_in_inf_NO_EDGES :
                                                        EMget_in_inf_NO_LOOPS;

    /*2 situations can exist here:
     * 1. if the key_count is 1 then know that the key is a direct access into
     *    the in info list.  This excludes edges added as part of a loop added.
     *    Here just get the id at the specified index.
     *
     * 2. if the key_count > 1 then the key is to a loop who added the edge
     *    in question.  Here get the loop at the specified index and treat it
     *    as the creator and go on into the key unrollong code below.
     */

    memset((char *) &inlist, '\0', sizeof(struct EMSinlist));
    free_inlist = TRUE;

    OM_stat = om$send(msg = message EMSdpr.EMgetInInfo(EMmsg, &inlist,
                            NULL_OBJID, FALSE, ininf_opts),
                      senderid = NULL_OBJID,
                      targetid = creator_id,
                      targetos = creator_os);
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;

    if (key[0].sub_item_type == EMSkey_LOOP)
    {
      if (key[0].chan_count != inlist.lplist.num_loops)
      {
        *EMmsg = EMS_I_NotFound;
        *created_id = NULL_OBJID;
      }
      else if (key_count == 1)
      {
        *created_id = inlist.lplist.loop_ids[key[0].chan_index];
      }
      else
      {
        lower_item = inlist.lplist.loop_ids[key[0].chan_index];
        key_count--;
        OM_stat = EFgenerate_id_from_key(EMmsg, lower_item, creator_os,
                                         key_count, &key[1], created_id,
                                         options);   
        if (!(1 & OM_stat & *EMmsg)) goto wrapup;
      }
    }
    else
    {
      if (key_count != 1)  /*Safety check*/
      {
        *EMmsg = EMS_E_InvalidArg;
        goto wrapup;
      }

      if (key[0].chan_count != inlist.edlist.num_edges)
      {
        *EMmsg = EMS_I_NotFound;
        *created_id = NULL_OBJID;
      }
      else
      {
        *created_id = inlist.edlist.edge_ids[key[0].chan_index];
      }
    }
    goto wrapup;  /*DONE!!!*/
  }                             

/*
 * Added sub-item type check to prevent using the loopset when
 * generating an id for the graphics loops. AIC

  if (EFisAncestryValid(EMmsg, creator_id, creator_os,
                        OPP_EMSsubbs_class_id, FALSE))
 */

  if (key[0].sub_item_type != EMSkey_GRALOOP &&
      EFisAncestryValid(EMmsg, creator_id, creator_os,
                        OPP_EMSsubbs_class_id, FALSE))
  {
    EMmake_chanselect(EMSsubbs_to_loopset, &chansel);
    OM_stat = om$get_channel_objects(objid = creator_id,
                                     osnum = creator_os,
                                     p_chanselect = &chansel,
                                     list = &obj_link,
                                     size = 1,
                                     count = &count);
    if (!(1 & OM_stat)) goto wrapup;

    creator_id = obj_link.S_objid;
    EMmake_chanselect(EMSloopset_to_loops, &chansel);
  }                                         
  else
  {
    OM_stat = EFget_chan_sel(EMmsg, NULL_OBJID, NULL, FALSE,
                             key[0].sub_item_type, &chansel, NULL);  
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;
  }

  if (key[0].sub_item_type != EMSkey_GRALOOP)
  {
   OM_stat = om$get_channel_count(objid = creator_id,
                                 osnum = creator_os,
                                 p_chanselect = &chansel,
                                 count = &chan_count);
   if (!(1 & OM_stat)) goto wrapup;
  }
  else
  {
   IGRint hi,gi;
   struct GRid graloop_id;

   OM_stat = om$get_channel_count(objid = creator_id,
                                  osnum = creator_os,
                                  p_chanselect = &chansel,
                                  count = &chan_count); /*need ptr to int*/
   if (!(1 & OM_stat)) goto wrapup;                                 

   hi=1;

   for (gi=0;gi<chan_count;gi++)
   {
    OM_stat = om$get_objid_at_index(objid = creator_id,
                                    osnum = creator_os,
                                    index= gi,
                                    p_chanselect = &chansel,
                                    objidaddr = &graloop_id.objid,
                                    osnumaddr = &graloop_id.osnum);
    if (!(1 & OM_stat)) goto wrapup;                                 
    if (!(EFisAncestryValid(EMmsg, graloop_id.objid, 
                                   graloop_id.osnum, 
                              OPP_EMSgraloop_class_id,
                              FALSE))) 
    {
      break;
    }
    else ++hi;
   }
   chan_count = hi;
  } 

/*
 * If the object that I am looking for on the channel is connected on
 * the to_components channel, then we need to look and see if the owner
 * is a construction macro/ci-macro. Because if so, it is likely that
 * the number of components are different when compared with the time
 * when the key was computed. This magic is necessary to take care of
 * the situtation when inputs of a macro are also outputs (contents).
 * Under such a situation, JLA will try to optimise and play games.
 * pp 04/29/92
 */

  if( (chan_count != (IGRint) key[0].chan_count) && 
      (key[0].sub_item_type == EMSkey_CONNECTOR))
  {
     if ( EFisAncestryValid(EMmsg, creator_id, creator_os,
                        OPP_ACncpx_class_id, FALSE))
       chan_count = (IGRint) key[0].chan_count;
  }

/* end pp */

  if( (chan_count != (IGRint) key[0].chan_count) && 
      (key[0].sub_item_type != EMSkey_GRALOOP))
  {
    *EMmsg = EMS_I_NotFound;        
    *created_id = NULL_OBJID;
    goto wrapup;
  }


  OM_stat = om$get_objid_at_index(objid = creator_id,
                                  osnum = creator_os,
                                  p_chanselect = &chansel,
                                  index = key[0].chan_index,
                                  objidaddr = &lower_item,
                                  osnumaddr = &dumosnum);
  if (!(1 & OM_stat)) goto wrapup;

  /*Ensure that the sub item type of the lower_item matches what is expected.*/
  OM_stat = EFget_sub_item_type(EMmsg, lower_item, creator_os, &sub_item_type);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;



  /* 
   * Introduce some leniency here. S/ware may have changed it's behavior so
   * that what was once a part-edge is now recomputed as a full-edge and
   * vice-versa. So don't fail in this case.
   */

  if (key[0].sub_item_type == EMSkey_PARTEDGE ||
      key[0].sub_item_type == EMSkey_EDGE)
  {
    if (sub_item_type == EMSkey_PARTEDGE ||
        sub_item_type == EMSkey_EDGE)
      sub_item_type = key[0].sub_item_type;
  }



  if (sub_item_type != key[0].sub_item_type)
  {
    *EMmsg = EMS_I_NotFound;        
    *created_id = NULL_OBJID;
    goto wrapup;
  }

  key_count--;

  if (!key_count)
  {
    *created_id = lower_item;    
  }
  else
  {
    OM_stat = EFgenerate_id_from_key(EMmsg, lower_item, creator_os, key_count,
                                     &key[1], created_id, options);   
  }

wrapup:
# if DEBUG
  if (*created_id == NULL_OBJID)
   fprintf(stderr,"WARNING! Couldn't generate id from key and creator (%d)\n",
           creator_id);
# endif

  if (free_inlist)
  {
    if (inlist.sflist.surf_ids) om$dealloc(ptr = inlist.sflist.surf_ids);
    if (inlist.lplist.loop_ids) om$dealloc(ptr = inlist.lplist.loop_ids);
    if (inlist.edlist.edge_ids) om$dealloc(ptr = inlist.edlist.edge_ids);
  }
  EMWRAPUP(*EMmsg, OM_stat, "EFgenerate_id_from_key")
  return(OM_stat);
}  
end implementation EMSsurface;
