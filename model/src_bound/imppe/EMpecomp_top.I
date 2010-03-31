/* ###################   APOGEE COMPILED   ################## */
class implementation EMSpartedge;

#include "EMS.h"
#include "emsmacros.h"
#include "emserr.h"
#include "OMmacros.h"

extern OMuword OPP_EMSnatedge_class_id;

method EMcompress_top(IGRlong *EMmsg;
                      struct EMSpartolbasis *partolbasis;
                      GRobjid    *new_objid)
/*
Description

Return values
    
History
  PP : 12/02/87    Calling a macro to put the partinfo structure
  DLB 4/22/87
*/
{
 IGRlong             OM_stat = OM_S_SUCCESS;
 OM_S_OBJECT_LINKAGE owned_id;
 OM_S_CHANSELECT     to_edge, to_owner, to_assoc, to_common_edge;
 OMuint              count;
 OMuword             owned_class;
 struct EMSpartedinfo partinfo;

 *EMmsg = EMS_S_Success;
 *new_objid = my_id;

 to_edge.type = OM_e_addr;
 to_edge.u_sel.addr = &ME.EMSbd_owner->to_comps;

 if (ME.EMSedge->ed_props & EMED_NATURAL)
 {
   /*I am natural so I simply connect myself to my natural edge somewhere
    * below and throw away all of the garbage in between.
    */

   /*Get the edge id I own*/
   OM_stat = om$get_channel_objects(object = me,
                                    p_chanselect = &to_edge,
                                    list = &owned_id,
                                    size = 1,
                                    count = &count);
   if ( !(1 & OM_stat) || (!count) ) goto wrapup;
 
   /*If it is a natural edge then all done*/
   OM_stat = om$get_classid(objid = owned_id.S_objid,
                            p_classid = &owned_class);
   if (! (1 & OM_stat)) goto wrapup;

   if (owned_class != OPP_EMSnatedge_class_id)
   {
     /*No so disconnect from the edge I own and reconnect me to my natural 
      * edge somewhere below.
      */
     OM_stat = om$send(msg = message Root.wild_disconnect(to_edge),
                       targetid = my_id);
     if (! (1 & OM_stat)) goto wrapup;
   
     OM_stat = om$send(msg = message EMSedge.EMconnect_to_ne(EMmsg, 
                             &my_id),
                       targetid = owned_id.S_objid);
     if (! (1 & OM_stat & *EMmsg)) goto wrapup;

     /*Done, perform delete on the edge I own and all below*/
     OM_stat = om$send(msg = message Root.delete(NULL), 
                       targetid = owned_id.S_objid);
     if (! (1 & OM_stat)) goto wrapup;
   }
 }
 else   /*Non-natural partedge*/
 {

   /*The processing for non-natural is somewhat different. I contain a
    * segment of the edge I own.  So for compression I ask my owned edges
    * to construct a new owned edge of the same size as I represent.  I
    * replace all of these partedges the original edge with the new edge. 
    * I may then throw away me and below including the owned non-natural
    * edge. 
    */

   /*Make the new edge.  The edge I own could be a linear or bs edge.
    * Due to this I send to that edge with my span and it makes the proper
    * edge and returns me the id.
    */

   EMput_partinfo (partinfo);

   OM_stat = om$send(msg = message EMSedge.EMconstruct_seg(EMmsg,
                           &partinfo, partolbasis, new_objid),
                     p_chanselect = &to_edge);
   if (! (1 & OM_stat & *EMmsg)) goto wrapup;

   /*Move my owners to the new edge*/
   OM_stat = EMmake_chanselect (EMSedge_to_owner, &to_owner);
   if (! (1 & OM_stat)) goto wrapup;
 
   OM_stat = om$send(msg = message Root.move_chan(to_owner, my_id,
                           OM_Gw_current_OS, to_owner),
                     targetid = *new_objid);
   if (! (1 & OM_stat)) goto wrapup;

   /*Move my common edges to the new edge*/
   OM_stat = EMmake_chanselect (EMSedge_to_common_edge, &to_common_edge);
   if (! (1 & OM_stat)) goto wrapup;

   OM_stat = om$send(msg = message Root.move_chan(to_common_edge, my_id,
                           OM_Gw_current_OS, to_common_edge),
                     targetid = *new_objid);
   if (! (1 & OM_stat)) goto wrapup;

   /*Move my association stuff to the new edge*/
   OM_stat = EMmake_chanselect (GRnotify_notification, &to_assoc);
   if (! (1 & OM_stat)) goto wrapup;

   OM_stat = om$send(msg = message Root.move_chan(to_assoc, my_id,
                           OM_Gw_current_OS, to_assoc),
                     targetid = *new_objid);
   if (! (1 & OM_stat)) goto wrapup;

   /*Since partedge has disappeared and a new edge has taken its place,
    * any associations should probably be told that the edge has changed.
    * This means broadcasting a message across the assoc channel.  I don't
    * do it now since all of this stuff is pretty unstable.
    */

   /*Delete me and all below*/
   OM_stat = om$send(msg = message Root.delete(NULL), targetid = my_id);
   if (! (1 & OM_stat)) goto wrapup;
 }     

 wrapup:
  EMWRAPUP(*EMmsg, OM_stat, "In EMSpartedge.EMcompress_top");
  return (OM_stat);
}

end implementation EMSpartedge;
