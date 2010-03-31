/* ###################   APOGEE COMPILED   ################## */
class implementation EMSloop;

#include "EMS.h"
#include <stdio.h>
#include "EMSlmdef.h"
#include "OMmacros.h"

extern OMuword OPP_EMSloopset_class_id, OPP_EMSloop_class_id;

method EMgroup_loops (
	IGRlong			*EMmsg;
	GRobjid			gr1_lp_to_connect;
	GRobjid			gr2_lp_to_connect;
	IGRlong			sender_lp_type;
	IGRlong			sender_lp_gr)

/*
 Notes
	This method is currently being used by MAKE FACE
	operation only. It is not clear if it can be
	used in another situation.
	
	The objective of this method is to divide the loops
	of a given loopset into two loopsets in an efficient
	manner. The loop decides which group it has to put
	itself based upon the input information.

	The following assumptions are made:
	  1. There is no P-loop inside a P-loop. Also, there is
	     no C-loop inside a C-loop.
	  2. This method is invoked by my parent loop in the loop 
	     tree.

History
    RC      05/2/87         Creation Date
    RC      11/03/87        Modified for version 1.1.0
    RC      09/20/88        Modified logic for adajacent p_loop
                            and a c-loop.

*/

{
 IGRlong              mthd_stat, OM_stat;
 
 OMuint               num_my_eds, num_sender_eds, chan_count;
 IGRint               i, j;

 GRobjid              lp_to_connect, my_ed_id, sender_ed_id, cm_ed_id;

 IGRboolean           sender_lp_adjacent;
 OMuword              parent_classid, sender_classid;

 OM_S_CHANSELECT      ls_lp_chan, to_inner, to_outter, to_edges_chan,
                      cm_ed_chan;

 OM_S_OBJECT_LINKAGE  lp_cur_owner;
   
 OM_stat = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;
 mthd_stat = EMS_S_Success;

 /*
  * The following assumptions are made for this 
  * method:
  *
  * 1) It is assumed the this method is invoked by
  *    my parent loop on the looptree.
  * 
  * 2) A p-loop loop can not have a p-loop as a child
  *    and vice versa. Similarly, a c-loop can not
  *    have a c-loop as a child and vice versa.
  *
  * I can be either a p-loop or a c-loop. Based upon
  * my loop type, there are two cases:
  *
  * 1) If I am a p-loop, my parent loop is
  *    either a regular c-loop or a dummy c-loop.
  *    There are two cases based upon my parent c-loop 
  *    type:
  *    
  *    a) If my parent c-loop is a dummy c-loop,
  *	    my group is opposite to my parent's group
  *	    (i.e., opposite to sender_lp_gr);
  *
  *    b) If my parent's c-loop is a regular c-loop,
  *	    my group is same as that of parent's group
  *       (i.e., same as sender_lp_gr) provided I am
  *     not adjacent to parent c-loop. If I am adjacent
  *     to parent c-loop, my group is opposite to that
  *     of my parent. If the senderid is not a loop,
  *     it is assumed that I will be the external loop
  *     after grouping.
  *
  *
  * 2) If I am a c-loop (regular or dummy), my parent's
  *    loop is a p-loop. In such a case my group is 
  *	 same as that of my parents' group (i.e, sender_lp_gr).
  */

  if (ME.EMSloop->lp_props & EMLP_PLOOP)
  {

    if (sender_lp_type & EMLP_DUMMY_CLOOP)
    {
	
      if (sender_lp_gr == EMS_MKFACE_GROUP1)
      {
        sender_lp_type = EMLP_PLOOP;
        sender_lp_gr = EMS_MKFACE_GROUP2;
        lp_to_connect = gr2_lp_to_connect;
        gr2_lp_to_connect = my_id;
			
      } /* if (sender_lp_gr == EMS_MKFACE_GROUP1) */
	
      else
      {
        sender_lp_type = EMLP_PLOOP;
        sender_lp_gr = EMS_MKFACE_GROUP1;
        lp_to_connect = gr1_lp_to_connect;
        gr1_lp_to_connect = my_id;
      }

   } /* if (sender_lp_type & EMLP_DUMMY_CLOOP) */

   else
   if (!(sender_lp_type & EMLP_PLOOP))
   {
     /*
      * If I am completely inside my sender c_loop (i.e., none
      * of my edges is a common edge of my sender loop's edges),
      * my_grp should be the same as my sender. Otherwise, it
      * should be opposite to that of my sender.
      */

     OM_stat = EMmake_chanselect (EMSbd_owner_to_comps, &to_edges_chan);
     EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

     OM_stat = EMmake_chanselect (EMSedge_to_common_edge, &cm_ed_chan);
     EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

     OM_stat = om$get_classid (objid = sender_id, 
                   osnum = sender_os, p_classid = &sender_classid);
     EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);
    
     OM_stat = om$is_ancestry_valid (subclassid = sender_classid,
                  superclassid = OPP_EMSloop_class_id);
     EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

     if (OM_stat == OM_S_SUCCESS)
     {                               
      OM_stat = om$get_channel_count (object = me,
                   p_chanselect = &to_edges_chan, count = &num_my_eds);
      EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);
          
      OM_stat = om$get_channel_count (objid = sender_id,
                                     p_chanselect = &to_edges_chan, 
                                     count = &num_sender_eds);
      EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);
          
      sender_lp_adjacent = FALSE;
      for (i = 0; i < num_my_eds; i++)
      {
       OM_stat = om$send (msg = message EMSboundary.EMget_objid (
                           &mthd_stat, &my_ed_id),
                         p_chanselect = &to_edges_chan, from = i, to = i);
       EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_EdgeError,wrapup);

       OM_stat = om$send (msg = message EMSboundary.EMget_objid (
                           &mthd_stat, &cm_ed_id),
                          senderid = my_ed_id, 
                          p_chanselect = &cm_ed_chan);
       EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_EdgeError,wrapup);

       for (j = 0; j < num_sender_eds; j++)
       {
        OM_stat = om$send (msg = message EMSboundary.EMget_objid (
                            &mthd_stat, &sender_ed_id), 
                          senderid = sender_id,
                         p_chanselect = &to_edges_chan, from = j, to = j);
        EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_EdgeError,wrapup);
      
        if (cm_ed_id == sender_ed_id)
        {
          sender_lp_adjacent = TRUE;
          break;
        }
       } /* for (j = 0; j < num_sender_eds; j++) */

       if (sender_lp_adjacent) break;

       } /* for (i = 0; i < num_my_eds; i++) */

      } /* if (OM_stat == OM_S_SUCCESS) */

      sender_lp_type = EMLP_PLOOP;

      if (sender_lp_gr == EMS_MKFACE_GROUP1 )
      {
        if (sender_lp_adjacent)
        {
          sender_lp_gr = EMS_MKFACE_GROUP2;
          lp_to_connect = gr2_lp_to_connect;
          gr2_lp_to_connect = my_id;
        }
        else
        { 
          sender_lp_gr = EMS_MKFACE_GROUP1;
          lp_to_connect = gr1_lp_to_connect;
          gr1_lp_to_connect = my_id;
			
        }

      } /* if (sender_lp_gr == EMS_MKFACE_GROUP1) */
	
      else
      {
        if (sender_lp_adjacent)
        {
          sender_lp_gr = EMS_MKFACE_GROUP1;
          lp_to_connect = gr1_lp_to_connect;
          gr1_lp_to_connect = my_id;
        }
        else
        {
          sender_lp_gr = EMS_MKFACE_GROUP2;
          lp_to_connect = gr2_lp_to_connect;
          gr2_lp_to_connect = my_id;
        }

      } /* else for if (sender_lp_gr == EMS_MKFACE_GROUP1) */

   } /* if (!(sender_lp_type & EMLP_PLOOP)) */

   else
   {
     *EMmsg = EMS_E_Fail;
     fprintf (stderr,"p-lp inside p-lp or wrong loop type\n");
     goto wrapup;
   }

  } /* if (ME.EMSloop->lp_props & EMLP_PLOOP) */
    
  else	/* I am a c-loop (regular or dummy ) */
  {
    sender_lp_type = (ME.EMSloop->lp_props & EMLP_DUMMY_CLOOP) ?
   			         EMLP_DUMMY_CLOOP : 0;
    ME.EMSloop->lp_props &= ~EMLP_DUMMY_CLOOP;

    if (sender_lp_gr == EMS_MKFACE_GROUP1)
    {
      lp_to_connect = gr1_lp_to_connect;
      gr1_lp_to_connect = my_id;
			
    } /* if (sender_lp_gr == EMS_MKFACE_GROUP1) */
	
    else
    {
      lp_to_connect = gr2_lp_to_connect;
      gr2_lp_to_connect = my_id;
    }

  } /* else	I am a c-loop (regular or dummy ) */ 

  /*
   *  if my current owner is same as that of
   *  lp_to_connect, there is nothing to be done.
   *  Otherwise, disconnect myself from my owner 
   * and connect myself to lp_to_connect
   */

  OM_stat = EMmake_chanselect (EMSloop_to_inner, &to_inner);
  EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

  OM_stat = EMmake_chanselect (EMSloop_to_outter, &to_outter);
  EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

  OM_stat = om$get_channel_objects (object = me,
               p_chanselect = &to_outter, list = &lp_cur_owner,
               size = 1, count = &chan_count);
  EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

  if (chan_count != 1)
  {
   if (!chan_count)
    lp_cur_owner.S_objid = NULL_OBJID;
   else
    EMerr_hndlr((chan_count > 1),*EMmsg,EMS_E_ChanCountNot1,wrapup);
   }    

   if (!IF_EQ_OBJID(lp_cur_owner.S_objid, lp_to_connect))
   {    
     if (chan_count)
     {
      OM_stat = om$send (msg = message Root.wild_disconnect (to_outter),
                         targetid = my_id);
      EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);
     }

     /*
      * Depending upon whether the loop I have to connect myself
      * is a loopset or loop, connect my self appropriately.
      */

     OM_stat = om$get_classid (osnum = OM_Gw_current_OS,
                                objid = lp_to_connect,
                                p_classid = &parent_classid);
     EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);
		
     if (parent_classid == OPP_EMSloopset_class_id)
     {

        OM_stat = EMmake_chanselect (EMSloopset_to_loops, &ls_lp_chan);
        EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

        OM_stat = om$send (msg = message Root.connect ( ls_lp_chan,
                            NULL, my_id, OM_Gw_current_OS, to_outter,
                            NULL), targetid = lp_to_connect);
        EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);
        ME.EMSloop->lp_props |= EMLP_EXTERNAL;
      }
      else
      {

        OM_stat = om$send (msg = message Root.connect ( to_inner,
                            NULL, my_id, OM_Gw_current_OS, to_outter,
                            NULL), targetid = lp_to_connect);
        EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

       }

   } /* if (!IF_EQ_OBJID(lp_cur_owner.S_objid, lp_to_connect)) */

    /*
     * send the same message to my childern
     */
  
    OM_stat = om$send (msg = message EMSloop.EMgroup_loops ( &mthd_stat,
                        gr1_lp_to_connect, gr2_lp_to_connect,
                        sender_lp_type, sender_lp_gr),
                       p_chanselect = &to_inner);
    EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_LoopError,wrapup);

wrapup:
  EMWRAPUP (*EMmsg,OM_stat,"In EMSloop.EMgroup_loops");

  return (OM_stat);
}

end implementation EMSloop;


