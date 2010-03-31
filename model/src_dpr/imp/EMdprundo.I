class implementation EMSdpr;

#define INITIAL 2
#define INCREMENT 4

#include "EMSopt.h"
#include "EMSmsgdef.h"
#include "emsdef.h"
#include "EMSdpr.h"
#include "EMSkey.h"
#include "EMSssprops.h"
#include "go.h"
#include "gr.h"
#include "grdpb.h"
#include "grdpbmacros.h"

extern OMuword OPP_GRvg_class_id, OPP_EMSsfimpbnd_class_id;


from EMSxsection import EMdeact_xsection;
from EMSmassprop import EMmpdisplay;
from EMSdprparam import EMput_compute_info;
from EMSparameter import EMparam_delete;
from EMSpointerA import EMstore_key_from_id;
from EMSsubbs import EMset_props, EMput_range_in_rtree;

method EMundo(IGRlong           *EMmsg; 
              IGRushort *option; 
              struct GRmd_env   *my_env; 
              struct GRid       **active_state; 
              IGRint            *num, *buff_size; 
              GRobjid           **display_ids; 
              IGRint            *display_count, *involk_count)
/*
Description
    This method will undo one or more states depending on where the
    message is sent in the tree.  
    The message must be sent to a state in the tree that is part of the 
    active path.  If the message is sent to a state below the active 
    state then an undo will occur from the active state down to AND
    INCLUDING the state the message was originally sent to.  
     
    The options for undo are:
   
    EMS_UNDO_SAVE - Do not delete the state being undone.
    EMS_UNDO_DELETE - Delete the state being undone and cleanup above.
    EMS_GET_ACTIVE_STATES - Can be ORed in with either of the above to ask
                            for the now active states after an undo has 
                            occurred. 
    EMS_DO_DISPLAY - Display only the affected surfaces.  This is an
                     optimization feature since the display of a complex
                     solid is terribly slow.
    EMS_DONT_REDRAW - (valid only with EMS_DO_DISPLAY) Don't redraw the 
                      surfaces on completion of the undo.  Instead return
                      the ids to the sender.

    When this message is involked for the first time the following
    parameters should be set as follows:

     *active_state = NULL
     *num          = 0
     *buff_size    = 0
     *display_ids  = NULL
     *display_count= 0
     *involk_count = 0

Return Values
    EMmsg - EMS_S_Success if all is well
            EMS_E_ChanCountWrong if discrepencies in the tree are found

    active_state - will be the array of active states IF bit was set in 
                   the option parameter, otherwise NULL.

    num - will be the number of elements in the array above.     

    display_ids   - for internal use only.
    display_count - for internal use only.
    involk_count  - for internal use only.


Notes
    The first state that receives this message WILL be undone.  

    This method allocates the array for the returned last state id's if
    the option was EMS_GET_ACTIVE_STATES. Because of this, who ever involks
    this method should deallocate the memory when done with it (by
    om$dealloc). 

    If the undo option is NOT EMS_GET_ACTIVE_STATES then the active_state, 
    num, and buff_size parameters may be passed as NULL.

    If the undo option is NOT EMS_DO_DISPLAY then the display_ids and 
    display_count parameters may be passed as NULL.

    If the undo option is NOT EMS_DO_DISPLAY then the involk_count parameter
    may be passed as NULL. 

    The display ids array will be freed internally (and set to NULL) unless
    the EMS_DONT_REDRAW option is specified.


History
   gupta, DLB, others too numerous to mention...   01/09/86  creation date
   DLB    03/23/87   Revised for new class structure (major modifications)
   DLB    11/02/87   Modified for version 1.1.0
   DLB    03/08/88   Added code for selective display during multiple undo
   DLB    05/04/88   Added shell invocation code.
   RC     11/18/88   Added code to undo the associated cross_section, 
                     if one exists.
   DLB    11/19/88   Added EMS_DONT_REDRAW option.
   DLB    05/23/89   Added EMrecompinfodelete send.
   gupta  09/06/89   Added code for mass/area designator display
   SM	  29-Sep-89  Donot abort if error occurs on the notification side.
   RC     11/21/89   Notify the listeners only if the option is 
                     EMS_UNDO_DELETE
   RC     12/11/89   Intialize the display mode.
   SS     02/08/90   Support of EMS_UNDO_DONTDELME
   DLB    11/19/90   Added orient toggle and connect top sends.
   DLB    01/15/91   Changed compute_info stuff to use param object.
   DLB    02/05/92   Added EMS_UNDO_DONTCLEANOWN & EMS_UNDO_DONTDISCONCOMPS
                     options.
   DLB    02/13/92   Added EMS_UNDO_SENDSTOREKEY option support.
   SM     02/26/93   send the EMput_range_in_rtree message to the components
                     after making them active. This is to ensure posting
                     the uptodate range.
*/
{
 IGRlong             OM_stat;
 OMuint              i, count;
 struct GRid         *temp, my_GRid;
 IGRboolean          action, found_me;
 enum GRdpmode       display_mode;
 IGRushort   mask;
 IGRshort            deact_option;
 OM_S_CHANSELECT     to_owners, to_comps;
  
 struct GRmd_env     display_env; //added for RFA
 IGRboolean          aflag = 0;
  
 gr$get_module_env(buffer = &display_env);


 OM_stat = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;
 
 if (! (ME.EMSdpr->dpr_props & EMSIS_ACTIVE_PATH)) goto wrapup;

 my_GRid.objid = my_id;
 my_GRid.osnum = OM_Gw_current_OS;

 if (*option & EMS_DO_DISPLAY) (*involk_count)++;

 EMmake_chanselect(GRconnector_to_owners, &to_owners);
 EMmake_chanselect(GRcmpowner_to_components, &to_comps);

 if (! (ME.EMSdpr->dpr_props & EMSIS_ACTIVE_STATE))
 {
   /*send on up the tree*/
   OM_stat = om$send(msg = message EMSdpr.EMundo( EMmsg, option, my_env,
                           active_state, num, buff_size, display_ids,
                           display_count, involk_count ),  
                     p_chanselect = &to_owners);
   if(OM_stat == OM_W_UNKNOWN_MSG) OM_stat = OM_S_SUCCESS;
   if (! (1  & OM_stat & *EMmsg)) goto wrapup;

   if (*option & EMS_GET_ACTIVE_STATES)
   {
     /*The next states method had no way of knowing who involked it so
      * it put my object id (an active state) in the array.  But now I will
      * be inactive.  So throw out the bad id and compress the array.
      */
     found_me = FALSE;
     temp = *active_state;
     for (i = 0; i < *num; i++)
     {
       if (found_me)
        temp[i-1] = temp[i];
         
       if (my_id == temp[i].objid) found_me = TRUE;
     }
     if (found_me) *num -= 1;    
   }
 } /*end if*/

 /*A problem arises with the advent of multiple undo and dprs with history
  * states.  The problem is that this state (my_id) MAY have been deleted by
  * a history state somewhere above. 
  * The solution to this problem is to determine if I am active and if
  * not return with no further processing.  This is valid since after
  * sending undo to my owner I have to be active unless I no longer exist.
  */
 
 if (!(ME.EMSdpr->dpr_props & EMSIS_ACTIVE_STATE)) 
 {
   OM_stat = OM_S_SUCCESS; 
   goto wrapup;
 }

 if (!(ME.EMSdpr->dpr_props & EMS_UNEVAL_STATE))
 {
   /*Deactive me.
    *This involves changing the topology back to the way it was before my
    * state was added.  
    *
    *The option is used to determine if the savestate stuff should be deleted.
    */

   if (*option & EMS_UNDO_SENDSTOREKEY)
   {
     IGRlong loc_msg;
     OM_S_CHANSELECT to_children;

     /*Notify the child ptrs that they need to convert their ids to keys*/
     EMmake_chanselect(NDchildren_children, &to_children);
     om$send(msg = message EMSpointerA.EMstore_key_from_id(&loc_msg, 
                   EMS_OPT_STORE_ID, NULL), 
              p_chanselect = &to_children);
   }

   if (ME.EMSdpr->dpr_props & EMS_ORIENT_FLIPPED)
   {
     /*Need to flip back my orientation since the deact will also flip it.
      * Note- The most efficient way of doing this is for the deact code
      *       to recognize the bit and not flip.  However, due to the
      *       uncertainty of such a change, and little time to make it, I
      *       will just be a little less efficient.
      */
     OM_stat = om$send(msg = message EMSdpr.EMtoggleOrient(EMmsg, NULL),
                       targetid = my_id);
     if (!(1 & OM_stat & *EMmsg)) goto wrapup;
   }

   deact_option = *option;
   OM_stat = om$send(msg = message EMSdpr.EMdeactivate(EMmsg, &deact_option,
                           my_env, display_ids, display_count),
                     targetid = my_id);
   if (! (1 & OM_stat & *EMmsg)) goto wrapup;
 }

 if (*option & EMS_DISCONNECT_TOP && !(ME.EMSdpr->dpr_props & EMS_NULL_STATE))
 {
   struct EMScompute_info compute_info;
   IGRlong EFsend_to_param();


   compute_info.computed_id = my_id;
   compute_info.ssi = NULL;
   compute_info.ri = NULL;
   compute_info.con_top = NULL; 
   compute_info.added_geom.num_added = 0;
   compute_info.added_geom.added_ids = NULL;
   compute_info.added_geom.added_inx = NULL;

   OM_stat = om$send(msg = message EMSdpr.EMconnectTopology(EMmsg,
                           &compute_info.con_top,
                           EMconnect_top_DISCONNECT),
                     targetid = my_id);
   if (!(1 & OM_stat & *EMmsg)) goto wrapup;

   OM_stat = EFsend_to_param(EMmsg, message EMSdprparam.EMput_compute_info(
                                    EMmsg, 1, &compute_info, NULL),
                             my_id, OM_Gw_current_OS, NULL, NULL);
   if (!(1 & OM_stat & *EMmsg)) goto wrapup;
 }

 if (!(*option & EMS_UNDO_SAVE))
 {
   /*Now delete all recompute info.  There may not be any.*/
   OM_stat = om$send(msg = message EMSdpr.EMrecompinfodelete(EMmsg, my_env,
                           RIDEL_DEL_COMP_RI, NULL),
                     targetid = my_id);
   if (! (1 & OM_stat & *EMmsg)) goto wrapup;                   
 }

 /*
  * If it is EMS_UNDO_DELETE, Undo the cross section attached and also
  * update the mass properties info. -- RC
  */

 if (*option & EMS_UNDO_DELETE)
 {
   OM_S_CHANSELECT  notify_chan;
   IGRint           num_child_ids;
   struct GRid      *child_ids;
 
   child_ids = NULL;
 
   EMmake_chanselect(GRnotify_notification, &notify_chan);
   om$send(msg = message EMSxsection.EMdeact_xsection(EMmsg, 
                 (IGRshort *) option, my_env, display_ids, display_count),
           p_chanselect = &notify_chan);
   *EMmsg = EMS_S_Success;
 
   EFgetobjids(EMmsg, &my_GRid, &to_comps, &child_ids,
                &num_child_ids, OPP_GRvg_class_id, NULL, 0);
   EMerr_hndlr(! (1 & *EMmsg), *EMmsg, *EMmsg, wrapup);
 
   display_mode=GRbehe;
   om$send(msg = message EMSmassprop.EMmpdisplay(EMmsg,
                 my_env, &display_mode),
           p_chanselect = &notify_chan);
   *EMmsg = EMS_S_Success;
 
   display_mode=GRbd;
   for(i=0; i<num_child_ids; i++)
   {
     om$send(msg = message EMSmassprop.EMmpdisplay(EMmsg,
                   my_env, &display_mode),
             senderid = child_ids[i].objid,
             p_chanselect = &notify_chan);
     *EMmsg = EMS_S_Success;
   }
   if (child_ids) om$dealloc(ptr = child_ids);
 } /* if (*option & EMS_UNDO_DELETE) */
  
 if ( (*option & EMS_DO_DISPLAY) && !(*option & EMS_DONT_REDRAW) )
 {
   if (*involk_count == 1) 
   {
     /*This is the first invocation of this method so redisplay.*/

     /*IMPORTANT NOTE:  If the this was an undo delete type operation then
      *                 some surfaces stored in the display_ids array may no
      *                 longer exist.  Therefore each id is checked for
      *                 validity before sent a display message.  It is felt
      *                 that this would be faster and use less code than
      *                 throwing out the bad ids as they are deleted 
      *                 (in deactivate).
      */

     aflag = pwIsActivationOn();
     display_mode = GRbd;
     for (i=0; i<*display_count; i++)
     {
       if (om$is_objid_valid(objid = (*display_ids)[i]) == OM_S_SUCCESS)
       {
         OM_stat = om$send(msg = message GRgraphics.GRdisplay(EMmsg, 
                                 aflag?&display_env.md_env.matrix_type:
                                       &my_env->md_env.matrix_type,
                                 aflag?display_env.md_env.matrix:
                                       my_env->md_env.matrix, 
                                 &display_mode,
                                 aflag?&display_env.md_id:
                                       &my_env->md_id),
                           targetid = (*display_ids)[i]);
         if (!(1 & OM_stat & *EMmsg)) goto wrapup;
       }
     }
   }
 }

 /*Activate the state(s) before me (set active bit in dpr_props)*/
 action = TRUE;
 mask = EMSIS_ACTIVE_STATE;

 /*NOTE- My last state may be of class other than dpr in which case it won't
  *      understand this message.  So I just check the return 
  *      om message and ignore an unknown msg warning.
  */

 OM_stat = om$send(msg = message EMSdpr.EMsetprops(EMmsg, &action, 
                         &mask),
                   p_chanselect = &to_comps);
 if(!(1 & *EMmsg & OM_stat) && (OM_stat != OM_W_UNKNOWN_MSG))goto wrapup;

 /* Post the possibly reduced surface ranges into the Rtree.
  * The unknown message to the owners will eventually hit the leaf
    surfaces.

    It is important to pass the change flag as GEOMETRICAL because of the
    possibility of increased surface range.
 */
if( (*option & EMS_UNDO_DELETE) && EFisAncestryValid(EMmsg, my_id, 
    OM_Gw_current_OS, OPP_EMSsfimpbnd_class_id))
 {
  IGRuchar sfchange = GEOMETRICAL;
  IGRlong rc;

/*
 *
 *     The property EMSIS_RTREE_RANGE_GOOD should be used internally
 *     and should not be touched --- vidya 10/6/93
  (void) om$send(msg = message EMSsubbs.EMset_props(&rc, 
         EMSIS_RTREE_RANGE_GOOD, EMS_O_OFF), p_chanselect = &to_comps);
*/
  (void) om$send(msg = message EMSsubbs.EMput_range_in_rtree(&rc, 
         NULL, NULL, NULL, sfchange, &my_env->md_id), 
         p_chanselect = &to_comps);
 }

 OM_stat = OM_S_SUCCESS;

 if (*option & EMS_GET_ACTIVE_STATES)
 {
   /*The option requests that I return all of the states that become
    * active as a result of the undo operation.
    * The array size is not determinate because multiple states may be
    * undone at one time.
    */

   /*Get total number of components I have*/
   OM_stat = om$get_channel_count(object = me, 
                                  p_chanselect = &to_comps,
                                  count = &count);
   if(! (1 & OM_stat)) goto wrapup;

   if (! *active_state)
   {
     /*The array has not yet been allocated so allocate it!*/
     *buff_size = count + INITIAL;
     *num = 0;
     
     *active_state = (struct GRid *) om$malloc
                      (size = *buff_size * sizeof(struct GRid));
     if (! *active_state)
     {*EMmsg = EMS_E_NoDynamicMemory; goto wrapup;}
   }
   else if (*buff_size < (count + *num))
   {
     *buff_size += (count + INCREMENT);

     temp = (struct GRid *) om$realloc 
            (ptr = (IGRchar *) *active_state, 
             size = *buff_size * sizeof(struct GRid));
     if (! temp)
     {*EMmsg = EMS_E_NoDynamicMemory; goto wrapup;}
                  
     *active_state = temp;
   }
    
   /*Get the object_ids on my comps channel.
    *
    *Note that one of these last states could have involked me by
    * its own undo operation.  I can determine which one sent me the
    * message (senderid) but I cannot determine what method involked
    * me.  Therefore, I will leave it up to the sending method to 
    * throw out the duplicate ids (undo will throw them out - SEE ABOVE).
    */
   
   temp = *active_state;  /*Because Green Hills makes a stupid compiler*/

   for (i = 0; i < count; i++)
   {
     OM_stat = om$get_objid_at_index(object = me,
                                     p_chanselect = &to_comps,
                                     index = i,
                                     objidaddr = &temp[*num].objid,
                                     osnumaddr = &temp[*num].osnum);
     if (! (1 & OM_stat)) goto wrapup;

     (*num)++;
   }              
 } /*end if*/

 if (!(*option & EMS_UNDO_SAVE))
 {
   ME.EMSdpr->dpr_props |= EMS_UNEVAL_STATE | EMS_NULL_STATE; 

   if (!(*option & EMS_UNDO_DONTCLEANOWN))
   {
     /*Delete me and everyone above*/
     OM_stat = om$send(msg = message EMSdpr.EMtreecleanup(EMmsg, my_env),
                       p_chanselect = &to_owners);
     if(!(1 & *EMmsg & OM_stat) && (OM_stat != OM_W_UNKNOWN_MSG)) goto wrapup;
   }

   if (!(*option & EMS_UNDO_DONTDISCONCOMPS))
   {
     /*I must disconnect my components before I delete in order to set their 
      * rigid relation bits correctly.
      */
     OM_stat = om$send(msg = message GRconnector.GRdisconn(EMmsg, &my_GRid),
                       p_chanselect = &to_comps);
     if (!(1 & OM_stat & *EMmsg)) goto wrapup;
   }

   if (!(*option & EMS_UNDO_DONTDELME))
   {
     OM_stat = om$send(msg = message GRgraphics.GRdelete(EMmsg, my_env),
                       targetid = my_id);
     if (! (1 & OM_stat)) goto wrapup;
   }
 }
 else
 {
   /*I am not active or in the active path*/
   ME.EMSdpr->dpr_props &= ~(EMSIS_ACTIVE_STATE | EMSIS_ACTIVE_PATH);

   /*I am not locatable or displayable*/
   ME.GRgraphics->properties &= ~(GRIS_LOCATABLE | GRIS_DISPLAYABLE);
 }

 wrapup:
  if (*option & EMS_DO_DISPLAY)
  {
    (*involk_count)--;
    if ( !(*involk_count) && !(*option & EMS_DONT_REDRAW) ) 
    {
      if (*display_ids) 
      { 
        om$dealloc(ptr = *display_ids);
        *display_ids = NULL;
      }
    }
  }

  EMWRAPUP(*EMmsg, OM_stat, "In EMSdpr.EMundo")
  return(OM_stat);
}
end implementation EMSdpr;
