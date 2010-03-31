/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfhist;

#include "EMS.h"
#include "EMSopt.h"

#define INITIAL 2
#define INCREMENT 4

method EMundo(IGRlong           *EMmsg;
              IGRushort *option;
              struct GRmd_env   *my_env;
              struct GRid       **active_state; 
              IGRint            *num, *buff_size;
              GRobjid           **display_ids;
              IGRint            *display_count, *involk_count)
/*
Description
    See EMdprundo.I file for a description of this method.

History
   DLB    03/14/88  Added selective display code
   DLB    11/06/87  Modified for version 1.1.0
   DLB    05/07/87  Creation
*/

{
 IGRlong             OM_stat;
 IGRint              i, count;
 IGRlong             next_to_last_index;
 GRobjid  my_last_state_id;
 GRobjid             lm_id, lm_next_state_id,
                     lm_last_state_id;  
 union EMSssi_table  *ssi;
 struct EMShstssi_table *my_info;
 struct GRid         *temp,  temp_GRid;
 OM_S_CHANSELECT     to_comps, to_owners;
 IGRushort   mask, undo_option;
 OMuword             dumosnum;
 IGRboolean          action, found_me, special_active = FALSE;


 OM_stat = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;
 ssi = NULL;
 
 if (! ME.EMSdpr->dpr_props & EMSIS_ACTIVE_PATH) goto wrapup;

 OM_stat = EMmake_chanselect (GRconnector_to_owners, &to_owners);
 if (! (1 & OM_stat)) goto wrapup;

 OM_stat = EMmake_chanselect (GRcmpowner_to_components, &to_comps);
 if (! (1 & OM_stat)) goto wrapup;

 if (! (ME.EMSdpr->dpr_props & EMSIS_ACTIVE_STATE))
 {
   /*Send on up the tree to make me active.*/
   OM_stat = om$send(msg = OPPmargs,
                     p_chanselect = &to_owners,
                     from = 0, to = 0);
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
 } /*End if*/

 /*Deactive me.*/

 /*I am not active or in the active path.*/
 ME.EMSdpr->dpr_props &= ~EMSIS_ACTIVE_STATE;
 ME.EMSdpr->dpr_props &= ~EMSIS_ACTIVE_PATH;                  

 /*I am not locatable or displayable.*/
 ME.GRgraphics->properties &= ~GRIS_LOCATABLE;
 ME.GRgraphics->properties &= ~GRIS_DISPLAYABLE;

 /*Activate the state before me (set active bit in dpr_props).*/
 action = TRUE;
 mask = EMSIS_ACTIVE_STATE;

 OM_stat = om$send(msg = message EMSdpr.EMsetprops(EMmsg, &action, 
                         &mask),
                   p_chanselect = &to_comps);
 if(!(1 & *EMmsg & OM_stat)) goto wrapup;

 /*If this is a temp undo then I am done*/
 if (*option & EMS_TEMP_OP) goto wrapup;

 /*Continue....*/

 /*Get my last states id (there will only be one since I am a history).*/
 OM_stat = om$get_objid_at_index(object = me,
                                 p_chanselect = &to_comps,
                                 index = 0,
                                 objidaddr = &my_last_state_id,
                                 osnumaddr = &dumosnum);
 if (! (1 & OM_stat)) goto wrapup;

 /*Disconnect me from my last state.*/
 temp_GRid.objid = my_id;
 temp_GRid.osnum = OM_Gw_current_OS;
 OM_stat = om$send(msg = message GRconnector.GRdisconn(EMmsg, &temp_GRid),
                   targetid = my_last_state_id);
 if (! (1 & OM_stat & *EMmsg)) goto wrapup;

 /*Send EMundo (temp) to my corresponding local mod object.*/
 OM_stat = om$send(msg = message EMSdpr.EMgetSSI(EMmsg, &ssi),
                   targetid = my_id);
 if (!(1 & OM_stat & *EMmsg)) goto wrapup;

 my_info = &ssi->hst_info;

 undo_option = EMS_TEMP_UNDO;

 if (*option & EMS_DO_DISPLAY) undo_option |= EMS_DO_DISPLAY;

 OM_stat = om$send(msg = message EMSdpr.EMundo(EMmsg, &undo_option,
                         my_env, NULL, NULL, NULL, display_ids,
                         display_count, involk_count),
                   targetid = my_info->added_id);
 if (! (1 & OM_stat & *EMmsg)) goto wrapup;

 /*Get my associated local mods id.*/
 lm_id = my_info->added_id;

 /*Get my local mods next state id*/
 OM_stat = om$get_objid_at_index(objid = lm_id,
                                 p_chanselect = &to_owners,
                                 index = 0,
                                 objidaddr = &lm_next_state_id,
                                 osnumaddr = &dumosnum);
 if (! (1 & OM_stat)) goto wrapup;

 /*Get my local mods last state id (there will only be one).*/
 lm_last_state_id = my_info->added_on;

 /*There is a special case when the added local mod may have actually 
  * removed the state that it was to add to. A split face will remove
  * the surface being split and replace it with the new split surfs.  In
  * this case the surface being split is also the active state.  So to make
  * a long story short, I must check for this case like so...
  */

 OM_stat = om$is_objid_on_channel(objid_c = lm_id,
                                  p_chanselect = &to_comps,
                                  objid = lm_last_state_id);
 if (!(1 & OM_stat) && (OM_stat != OM_W_NOTONCHAN)) goto wrapup;

 if (OM_stat == OM_W_NOTONCHAN) special_active = TRUE;
            
 if (!special_active)
 {
   /*Disconnect my local mod from its last state*/
   temp_GRid.objid = lm_id;
   OM_stat = om$send(msg = message GRconnector.GRdisconn(EMmsg, &temp_GRid),
                     targetid = lm_last_state_id);
   if (! (1 & OM_stat & *EMmsg)) goto wrapup;
 }

 /*Get the local mods next state index relative to the next state.*/
 OM_stat = om$get_index(objid_c = lm_next_state_id,
                        p_chanselect = &to_comps,
                        objid = lm_id,
                        indexaddr = (OMuint *) &next_to_last_index);
 if (! (1 & OM_stat)) goto wrapup;

 /*Disconnect my local mod from its next state (active index)*/
 temp_GRid.objid = lm_next_state_id;
 OM_stat = om$send(msg = message GRconnector.GRdisconn(EMmsg, &temp_GRid),
                   targetid = lm_id);
 if (!(1 & OM_stat & *EMmsg)) goto wrapup;

 /*If I got to this point I know this is an undo delete operation so
  * kill the localmod.
  */

 OM_stat = om$send(msg = message GRgraphics.GRdelete(EMmsg, my_env),
                   targetid = lm_id);
 if (! (1 & OM_stat & *EMmsg)) goto wrapup;

 if (!special_active)
 {
   /*Connect my local mods last state id to local mods next state id*/
   temp_GRid.objid = lm_next_state_id;
   OM_stat = om$send(msg = message GRconnector.GRrigidconn(EMmsg,
                           &temp_GRid, &next_to_last_index),
                     targetid = lm_last_state_id);
   if (! (1 & OM_stat & *EMmsg)) goto wrapup;
 }

 /*Prep for re-execute*/
 OM_stat = om$send(msg = message EMSdpr.EMprep_reex(EMmsg, my_env),
                   targetid = lm_next_state_id);
 if (! (1 & OM_stat & *EMmsg)) goto wrapup;

 /*Redo to my last state (preforming re-execute)*/
 { 
   IGRushort redo_opt = 0;
   
   OM_stat = om$send(msg = message EMSdpr.EMredo(EMmsg, &redo_opt, my_env, 
                           NULL, NULL, NULL),
                     targetid = my_last_state_id);
   if (! (1 & OM_stat & *EMmsg)) goto wrapup;
 }

 /*Return the new active id if asked for*/
 if (*option & EMS_GET_ACTIVE_STATES)
 {
   /*The option requests that I return all of the states that become
    * active as a result of the undo operation.
    * The array size is not determinate because multiple states may be
    * undone at one time.
    */

   /*I know I have one last state*/
   count = 1;

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
    
   /*Put my last state id on the array*/
   (*active_state)[*num].objid = my_last_state_id;
   (*active_state)[*num].osnum = OM_Gw_current_OS; 
   (*num)++;
 } /*End if*/

 /*As stated before, I know this is an undo delete operation.*/

 /*Delete me and all associated with me*/
 OM_stat = om$send(msg = message GRgraphics.GRdelete(EMmsg, my_env),
                   targetid = my_id);
 if(!(1 & *EMmsg & OM_stat)) goto wrapup;

 wrapup:
  if (ssi) om$dealloc(ptr = ssi);
  EMWRAPUP(*EMmsg, OM_stat, "In EMSsfhist.EMundo")
  return(OM_stat);
}
end implementation EMSsfhist;
