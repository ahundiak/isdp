/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsurface;

#include <stdio.h>
#include <alloca.h>
#include "EMSkey.h"
#include "EMSdpr.h"
#include "EMSprop.h"

/* Until som_get_classid is fixed to handle deleted objects, validate */
#define VALIDATE 1

from EMSloop import EMget_props;

extern OMuword OPP_EMSedge_class_id,
               OPP_EMSloop_class_id,
               OPP_EMSgraloop_class_id,
               OPP_EMSloopset_class_id,
               OPP_GRconnector_class_id;

IGRlong EFgenerate_key_from_id(EMmsg, created_id, created_os, creator_id,
                               key_count, key, recurse_count, options)   
IGRlong           *EMmsg; 
GRobjid           created_id;
OMuword           created_os;
GRobjid           creator_id;
IGRint            *key_count;
struct EMSkey     **key;
IGRint            recurse_count;
IGRushort options;
/*
Description
    This function will compute and return the key from the creator_id down to
    the created_id of interest.  EFgenerate_id_from_key may then be used to
    get back the id.

Return Values    
    EMSS_S_Success if all is well.

Notes
    About params:
        creator_id, created_id - key will be computed from the creator id 
                                 down to the created_id.
        key_count - number of key structs returned.  Must be initialized to 0.
        key - if key is passed as NULL, only the key_count will be returned.
              if key is passed as !NULL, it contain the array of keys.  
              if *key is passed as NULL, memory will be allocated via 
                om$malloc and must be freed by the caller via om$dealloc.
              if *key is passed as !NULL, memory is assumed to already be
                allocated.
        recurse_count - Set to 0.  Used internally for recursion.
        options - none so far...

History
    DLB 12/08/92    Was assuming all added geom to a DPR was of class EMSsubbs.
                    Many features added sfsolid or compsf class geom which
                    then owns the EMSsubbs.  Therefore check for class
                    EMSsurface instead of EMSsubbs.
    DLB 05/27/92    Perform sanity check to ensure that created really is an
                    edge.
    DLB 10/11/91    Check for active loop when getting ssi->loop to edge key.
                    This handles a crazy round case of a loop and and then
                    removed within the SAME operation.
    PP  10/10/91    Modified the id generation mechanism to ignore the
                    presence of graphics data
    AIC 08/15/91    Support graphics loops.
    DLB 05/29/91    When going up, if at an edge get the active loop as the
                    upper_item.
    DLB 05/22/91    Fix for key thats ininfo relative.
    DLB 05/14/91    Creation.
*/
{
  IGRlong             OM_stat=OM_S_SUCCESS;
  IGRint              count, chan_label;
  OMuint              ii;
  GRobjid             upper_item, loopset_item;
  OM_S_CHANSELECT     chansel;
  OM_S_OBJECT_LINKAGE obj_link, *big_obj_link=NULL;
  struct EMSinlist    inlist;
  IGRboolean          upper_item_is_subbs=FALSE, free_inlist=FALSE;
  unsigned char       sub_item_type;
  extern IGRboolean   EFisAncestryValid();
  extern OMuword      OPP_EMSdpr_class_id, OPP_EMSsubbs_class_id;  
  IGRlong             EFget_chan_sel();   
  IGRlong             EFget_sub_item_type();


  *EMmsg = EMS_S_Success;

#if DEBUG
  if (recurse_count == 0)
  {
    fprintf(stderr, 
            "creator_id = %d,   created_id = %d\n", creator_id, created_id);
  }
#endif  

  if (created_id == creator_id)
  {
    *EMmsg = EMS_I_InvalidSend;
    goto wrapup;
  }

  if (recurse_count == 0 &&
      EFisAncestryValid(EMmsg, creator_id, created_os, OPP_EMSdpr_class_id,
                        VALIDATE))
  {
    /*DPR was the creator so see if the created id exists in the in-info.*/

    /*First see if the created is a surface.  If so then just go on and
     * generate the key (DPR->surface).
     */
    if (!EFisAncestryValid(EMmsg, created_id, created_os,
                           OPP_EMSsurface_class_id, VALIDATE)) /*DLB 12/08/92*/
    {
      OMuint     list_index;
      IGRboolean found_created=FALSE, in_edge_list=FALSE, created_is_a_loop,
                 part_of_created_loop=FALSE;

      created_is_a_loop = EFisAncestryValid(EMmsg, created_id, created_os,
                                            OPP_EMSloop_class_id, VALIDATE);

      /*Get the loop in info regardless of what the created is*/
      free_inlist = TRUE;
      memset((char *) &inlist, '\0', sizeof(struct EMSinlist));

      OM_stat = EFfind_created(EMmsg, created_id, creator_id, created_os,
                               &inlist, &found_created, &in_edge_list,
                               &list_index, EFfind_created_NO_EDGES); 
      if (!(1 & OM_stat & *EMmsg)) goto wrapup;

      /*If anything is found then it must be a loop.  Only need to generate the
       * key into the ininfo.loop_id list.  If not found, then there are 3
       * cases to check:
       *
       * 1. the edge or loop is part of an added surface.  In this case just
       *    generate the key from the DPR to the item (DPR->surf->loop etc.).
       *
       * 2. the edge is part of a loop added.  In this case we must make the
       *    key into the ininfo.loop_id list and then key from that loop id
       *    down to the edge.
       *
       * 3. the edge is an independently created item.  In this case just 
       *    generate the key into the ininfo.edge_id list.
       * 
       */

      if (!found_created && !created_is_a_loop)
      {
        /*Gets bit tricky since the created is an edge.  See if the edge is 
         * owned by any of the loops returned from the EFfind_created call.
         */
        GRobjid *lp_in;
        IGRushort lpprops;
        extern OMuint OM_Gf_verbose_warning;

        /*Perform sanity check to ensure that created really is an edge.*/
        if (!EFisAncestryValid(EMmsg, created_id, created_os,
                               OPP_EMSedge_class_id, VALIDATE))
        {
          if (OM_Gf_verbose_warning)
          {
            fprintf(stderr,
             "ERROR! created must be edge but isnt! creator(%d) created(%d)\n",
             creator_id, created_id);
          }
          *EMmsg = EMS_I_InvalidSend;   /*Dont know what else to do...*/
          goto wrapup;
        }

        for(ii=0, lp_in=inlist.lplist.loop_ids;
            ii<inlist.lplist.num_loops;
            ii++, lp_in++)
        {
          OM_stat = om$send(msg = message EMSloop.EMget_props(EMmsg, &lpprops),
                            senderid = NULL_OBJID,
                            targetid = *lp_in,
                            targetos = created_os);
          if (!(1 & OM_stat & *EMmsg)) goto wrapup;

          if (lpprops & EMLP_ACTIVE && 
              EFis_edge_owned_by_edlp(EMmsg,
                                      created_id,
                                      *lp_in,
                                      created_os)) break;
          else if (!(1 & *EMmsg)) goto wrapup;
        }

        if (ii == inlist.lplist.num_loops)
        {
          /*Didn't find the edge as part of the created loops.  Now see 
           * if the created edge is part of the created edge list but not
           * part of edges resulting from created loops.
           *
           * If it is NOT found then the edge is part of a surface added by the
           * DPR so get the full key from the DPR to the edge.
           */
          inlist.lplist.num_loops = inlist.edlist.num_edges = 0; /*Needed?*/
          OM_stat = EFfind_created(EMmsg, created_id, creator_id, created_os,
                                   &inlist, &found_created, &in_edge_list,
                                   &list_index,
                                   EFfind_created_NO_LOOPS | 
                                   EFfind_created_NO_EDGES_FROM_LOOPS); 
          if (!(1 & OM_stat & *EMmsg)) goto wrapup;
        }
        else
        {
          /*The created edge is part of a created loop.  So generate the
           * key from the ininfo to the loop to the edge.
           */
          (*key_count)++; /*Provide empty space for the DPR->loop key.*/
            
          OM_stat = EFgenerate_key_from_id(EMmsg, created_id, created_os,
                                           *lp_in, key_count, key,
                                           recurse_count, options);
          if (!(1 & OM_stat & *EMmsg)) goto wrapup;

          list_index = ii;
          in_edge_list = FALSE;
          found_created = TRUE;
          part_of_created_loop = TRUE;
        }
      }

      if (found_created)
      {
        if (key && ! *key)
        {
          *key = (struct EMSkey *) om$malloc(size = sizeof(struct EMSkey));
          if (! *key) {*EMmsg = EMS_E_NoDynamicMemory; goto wrapup;}
        }

        if (key && *key)
        {
          if (in_edge_list)
          {
            (*key)->sub_item_type = EMSkey_EDGE;
            (*key)->chan_count = inlist.edlist.num_edges;
          }
          else
          {
            (*key)->sub_item_type = EMSkey_LOOP;
            (*key)->chan_count = inlist.lplist.num_loops;

          }

          (*key)->chan_index = list_index;
        }

        if (!part_of_created_loop) (*key_count)++;  
        goto wrapup;
      }
    }                          
  }                        

  recurse_count++;

  /*Figure out the chansel going up.*/
  OM_stat = EFget_chan_sel(EMmsg, created_id, created_os, TRUE, NULL,
                           &chansel, &chan_label);  
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;

  /*Get the upper item id.*/
  upper_item = NULL_OBJID;

  if (chan_label == EMSedge_to_owner)
  {
    /* Handle case of edge with more than one loop.
     * In this case, get the active loop.
     * Note that the created_id may not be an edge here which explains the 
     * above chan_label check.
     */
    OM_stat = om$get_channel_count(objid = created_id,
                                   osnum = created_os,
                                   p_chanselect = &chansel,
                                   count = (OMuint *) &count);
    if (!(1 & OM_stat)) goto wrapup;

    if (count)
    {
      OMuword loop_props;

      big_obj_link = (OM_S_OBJECT_LINKAGE *) stackalloc
                     (count * sizeof(OM_S_OBJECT_LINKAGE));
      if (!big_obj_link) {*EMmsg = EMS_E_NoStackMemory; goto wrapup;}

      OM_stat = om$get_channel_objects(objid = created_id,
                                       osnum = created_os,
                                       p_chanselect = &chansel,
                                       list = big_obj_link,
                                       size = count,
                                       count =(OMuint *) &count);
      if (!(1 & OM_stat)) goto wrapup;

      /*Start out assuming the upper_item is the first object (an efficiency
       * issue only.
       */
      upper_item = big_obj_link[0].S_objid;

      for(ii=0; ii<count; ii++)
      {
        OM_stat = om$send(msg = message EMSloop.EMget_props(EMmsg,
                                &loop_props),
                          senderid = NULL_OBJID,
                          targetid = big_obj_link[ii].S_objid,
                          targetos = created_os);
        if (OM_stat == OM_W_UNKNOWN_MSG)
        {
          OM_stat = OM_S_SUCCESS;
          continue;
        }
        else if (!(1 & OM_stat & *EMmsg)) goto wrapup;

        if (loop_props & EMLP_ACTIVE)
        {
          upper_item = big_obj_link[ii].S_objid;
          break;
        }
      }
    }
  }

  if (upper_item == NULL_OBJID)
  {
    /*Creator was not an edge or something goofy must have happened.*/
    obj_link.S_objid = NULL_OBJID;
    OM_stat = om$get_channel_objects(objid = created_id,
                                     osnum = created_os,
                                     p_chanselect = &chansel,
                                     list = &obj_link,
                                     size = 1,
                                     count = (OMuint *)&count);
    if (!(1 & OM_stat)) goto wrapup;

    upper_item = obj_link.S_objid;
  }

  if (upper_item == NULL_OBJID)
  {
    /*created_id is part of inactive stuff.*/
    *EMmsg = EMS_E_InvalidCase;
    goto wrapup;
  }

  if (EFisAncestryValid(EMmsg, upper_item, created_os,
                        OPP_EMSloopset_class_id, VALIDATE))
  {
    /*Sneak past the loopset on up to the surface.  This effectively makes the 
     * loopset non-existent.  Special processing is then done when computing
     * the surface_to_loops key (see below).
     */
    upper_item_is_subbs = TRUE;
    loopset_item = upper_item;

    EMmake_chanselect(EMSloopset_to_surface, &chansel);
    OM_stat = om$get_channel_objects(objid = upper_item,
                                     osnum = created_os,
                                     p_chanselect = &chansel,
                                     list = &obj_link,
                                     size = 1,
                                     count = (OMuint *)&count);
    if (!(1 & OM_stat)) goto wrapup;

    upper_item = obj_link.S_objid;
  }                      

  if (upper_item == creator_id)
  {
    /*Reached the top.*/
    if (key && ! *key)
    {
      *key = (struct EMSkey *) om$malloc
             (size = recurse_count * sizeof(struct EMSkey));
      if (! *key) {*EMmsg = EMS_E_NoDynamicMemory; goto wrapup;}
    }
  }
  else 
  {
    /*Recurse on up*/
    OM_stat = EFgenerate_key_from_id(EMmsg, upper_item, created_os, creator_id,
                                     key_count, key, recurse_count, options);
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;
  }

  if (key && *key)
  {
    OMuint chan_count, chan_index;
    
    OM_stat = EFget_sub_item_type(EMmsg, created_id, created_os, 
                                  &sub_item_type);
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;      

    (*key)[*key_count].sub_item_type = sub_item_type;

/*
 * Added support check for EMSkey_LOOP to prevent the graphics loop
 * case from being derailed on the loopset. AIC
 *
    if (upper_item_is_subbs)
 */

    if (upper_item_is_subbs && (sub_item_type == EMSkey_LOOP))
    {
      /*The upper item is the subbs so pretend the loops are on its channel.
       *  But in reality the chan_count and chan_index is relative to the
       *  EMSloopset.to_loops channel.
       */
      upper_item = loopset_item;
      EMmake_chanselect(EMSloopset_to_loops, &chansel);      
    }
    else
    {
      OM_stat = EFget_chan_sel(EMmsg, NULL_OBJID, NULL, FALSE,
                               sub_item_type, &chansel, NULL);
      if (!(1 & OM_stat & *EMmsg)) goto wrapup;
    }

    if (sub_item_type == EMSkey_GRALOOP)
    {
     IGRint hi,gi;

     struct GRid graloop_id;

     OM_stat = om$get_channel_count(objid = upper_item,
                                   osnum = created_os,
                                   p_chanselect = &chansel,
                                   count = (OMuint *)&chan_count); /*need ptr to int*/
     if (!(1 & OM_stat)) goto wrapup;                                 

     hi=1;

     for (gi=0;gi<chan_count;gi++)
     {
      OM_stat = om$get_objid_at_index(objid = upper_item,
                                      osnum = created_os,
                                      index= gi,
                                      p_chanselect = &chansel,
                                      objidaddr = &graloop_id.objid,
                                      osnumaddr = &graloop_id.osnum);
      if (!(1 & OM_stat)) goto wrapup;                                 
      if (!(EFisAncestryValid(EMmsg, graloop_id.objid, 
                                   graloop_id.osnum, 
                              OPP_EMSgraloop_class_id,
                              VALIDATE))) 
      {
       break;
      }
      else ++hi;
     }
     chan_count = hi;
    }
    else
    {
     OM_stat = om$get_channel_count(objid = upper_item,
                                   osnum = created_os,
                                   p_chanselect = &chansel,
                                   count = (OMuint *)&chan_count); /*need ptr to int*/
     if (!(1 & OM_stat)) goto wrapup;                                 
    }

    (*key)[*key_count].chan_count = chan_count;

    OM_stat = om$get_index(objid_c = upper_item,
                           osnum_c = created_os,
                           p_chanselect = &chansel,
                           objid = created_id,
                           osnum2 = created_os,
                           indexaddr = &chan_index);  /*need ptr to int*/
    if (!(1 & OM_stat)) goto wrapup;                         

    (*key)[*key_count].chan_index = chan_index;
  }

  (*key_count)++;

#if DEBUG
  if (recurse_count <= 1 && key)
  {
    for(ii=0; ii<(*key_count); ii++)
    {
      fprintf(stderr, "key[%d].chan_count = %d\n", ii, (*key)[ii].chan_count);
      fprintf(stderr, "key[%d].chan_index = %d\n", ii, (*key)[ii].chan_index);
      fprintf(stderr, "key[%d].sub_item_type = %d\n\n", 
                                                 ii, (*key)[ii].sub_item_type);
    }
  }
#endif

wrapup:
  if (free_inlist)
  {
    if (inlist.sflist.surf_ids) om$dealloc(ptr = inlist.sflist.surf_ids);
    if (inlist.lplist.loop_ids) om$dealloc(ptr = inlist.lplist.loop_ids);
    if (inlist.edlist.edge_ids) om$dealloc(ptr = inlist.edlist.edge_ids);
  }
  if (big_obj_link) stackfree(big_obj_link);
  EMWRAPUP(*EMmsg, OM_stat, "EFgenerate_key_from_id")
  return(OM_stat);
}  
    

IGRlong EFget_chan_sel(EMmsg, item_id, item_os, look_up, sub_item_type,
                       chansel, chan_label) 
IGRlong          *EMmsg;
GRobjid          item_id;
GRobjid          item_os;
IGRboolean       look_up;
unsigned char    sub_item_type;
OM_S_CHANSELECT  *chansel;
IGRint           *chan_label;

/*
Description
    Get either the upper or lower chanselector of the specified item.    

Notes
    If looking down the item_id and item_os are ignored.

History
    AIC     08/15/91    Support graphics loops.
    DLB     05/31/91    Add chan_label parameter.
    DLB     05/14/91    Creation.
*/
{
  IGRlong      OM_stat=OM_S_SUCCESS;
  IGRint       loc_chan_label;
  IGRboolean   EFisAncestryValid();


  *EMmsg = EMS_S_Success;

  if (look_up)
  {
    if (EFisAncestryValid(EMmsg, item_id, item_os, OPP_EMSedge_class_id,
                          VALIDATE)) 
    {
      loc_chan_label = EMSedge_to_owner;
    }
    /* Added check for graphics loops. (Must be before check for loops). AIC */
    else if (EFisAncestryValid(EMmsg, item_id, item_os,
                               OPP_EMSgraloop_class_id, VALIDATE)) 
    {
      loc_chan_label = EMShelper_to_requesters;
    }
    else if (EFisAncestryValid(EMmsg, item_id, item_os,
                               OPP_EMSloop_class_id, VALIDATE)) 
    {
      loc_chan_label = EMSloop_to_outter;
    }
    else if (EFisAncestryValid(EMmsg, item_id, item_os,
                               OPP_GRconnector_class_id, VALIDATE)) 
    {
      loc_chan_label = GRconnector_to_owners;
    }
    else
    {
      *EMmsg = EMS_E_InvalidArg;
      goto wrapup;
    }
  }
  else /*look down*/
  {
    switch(sub_item_type)
    {
      case EMSkey_CONNECTOR:
      {
        loc_chan_label = GRcmpowner_to_components;
        break;
      }

      /* Added check for EMSkey_GRALOOP. AIC */
      case EMSkey_GRALOOP:
      {
        loc_chan_label = EMSrequester_to_helpers;
        break;
      }

      case EMSkey_LOOP:
      {
        loc_chan_label = EMSloop_to_inner;
        break;
      }

      case EMSkey_EDGE:
      case EMSkey_PARTEDGE:
      {
        loc_chan_label = EMSbd_owner_to_comps;
        break;
      }

      default:
      {
        *EMmsg = EMS_E_InvalidArg;
        goto wrapup;
      }
    }
  }
  
  OM_stat = EMmake_chanselect(loc_chan_label, chansel);
  if (!(1 & OM_stat)) goto wrapup;

  if (chan_label) *chan_label = loc_chan_label;

wrapup:
  EMWRAPUP(*EMmsg, OM_stat, "EFget_chan_sel")
  return(OM_stat);
} 


IGRlong EFget_sub_item_type(EMmsg, sub_item_id, sub_item_os, sub_item_type)
IGRlong       *EMmsg;
GRobjid       sub_item_id;
OMuword       sub_item_os;
unsigned char *sub_item_type;
/*
Description
    Return the sub item type given the sub item id.

History
    AIC     08/15/91    Added support for graphics loops.
    DLB     05/15/91    Creation.
*/
{
  extern OMuword OPP_EMSpartedge_class_id;
  extern IGRboolean   EFisAncestryValid();


  *EMmsg = EMS_S_Success;
    
  /* Added support for graphics loops. AIC */
  if (EFisAncestryValid(EMmsg, sub_item_id, sub_item_os,
                             OPP_EMSgraloop_class_id, VALIDATE)) 
  {
    *sub_item_type = EMSkey_GRALOOP;
  }
  else if (EFisAncestryValid(EMmsg, sub_item_id, sub_item_os,
                        OPP_GRconnector_class_id, VALIDATE)) 
  {
    *sub_item_type = EMSkey_CONNECTOR;
  }
  else if (EFisAncestryValid(EMmsg, sub_item_id, sub_item_os,
                             OPP_EMSloop_class_id, VALIDATE)) 
  {
    *sub_item_type = EMSkey_LOOP;
  }
  else if (EFisAncestryValid(EMmsg, sub_item_id, sub_item_os,
                             OPP_EMSpartedge_class_id, VALIDATE)) 
  {
    *sub_item_type = EMSkey_PARTEDGE;
  }
  else if (EFisAncestryValid(EMmsg, sub_item_id, sub_item_os,
                             OPP_EMSedge_class_id, VALIDATE)) 
  {
    *sub_item_type = EMSkey_EDGE;
  }
  else
  {
    *sub_item_type = EMSkey_UNKNOWN;
    *EMmsg = EMS_E_InvalidArg;
  }

  return(OM_S_SUCCESS);
}
end implementation EMSsurface;
