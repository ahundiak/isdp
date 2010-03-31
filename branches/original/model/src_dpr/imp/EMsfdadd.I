/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfdpr;

#include "EMS.h"
#include "EMSopt.h"
#include "EMSmsgdef.h"
#include "emserr.h"

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

extern OMuword OPP_EMSsldpr_class_id, OPP_EMSsfhist_class_id,
               OPP_EMSslhist_class_id, OPP_EMSsfmove_class_id;

method EMadd(IGRlong *EMmsg; struct GRid *active_state, *saved_state;
             struct GRmd_env *env; IGRushort *option)
/*
Description
    This method will add a state to the tree.  This method should be
    sent to the state being ADDED to the tree.

    Active_state is the currently active state that the new state will be
    added to.    

    Saved_state is the state that WAS active before the local mod was
    performed and an undo was done.

    If saved_state == NULL then add will work as normal ( add to top).

    If the active_state and saved_state are the same id an error condition
    is assumed.

    If the active_state and saved_state are different then this state will
    be inserted after the active state, a history object will be added
    after the saved state and a re-execute will be performed and the
    history object will be active.

Return Values
    EMS_S_Success if all is well

Notes
    This method SHOULD NOT be used for a boolean operation add.

    Currently the only valid option is EMS_DO_DISPLAY.

History
   05/24/91 DLB Connect state on index 0 of to_comps chann.  Also disable
                undo recompute stuff.
   09/28/89 SS  Absorbed the xsection and massprop updates into the
                EMpostgeomod method such that MSC and other notifications
                would be supported.
   09/06/89 gupta Added code for associated mass/area designator
   02/23/89 DLB Reset return codes after send across notification channel.
                The send would result in unknown msg error if any other
                listener was on the channel.  P.S. If you change the way I
                list my dates, I will break both of your legs...

   RC  11/18/88  Added code to update the associated cross_section.
   DLB 10/26/87  Modified for version 1.1.0
   DLB 04/26/87  Added code for insertion in tree
   DLB 03/23/87  Revised and made major modifications
   DLB, AIC, gupta, Chopra .... 01/09/86 : creation date
*/
{
  IGRlong                OM_stat, msg_loc, dumindex;
  GRobjid                *display_ids;
  GRclassid		 myclassid;
  union EMSssi_table     *ssi;
  OM_S_CHANSELECT        to_comps;
  IGRushort              mask;
  struct GRid            my_GRid;
  IGRboolean             action;


  OM_stat = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;
  ssi = NULL;

  OM_stat = EMmake_chanselect (GRcmpowner_to_components, &to_comps);
  if (! (1 & OM_stat)) goto wrapup;

  my_GRid.objid = my_id;
  my_GRid.osnum = OM_Gw_current_OS;
  dumindex = 0;

  if (!saved_state)
  {
    /*Add me (the new state object) to the state tree.*/
    OM_stat = om$send(msg = message GRconnector.GRrigidconn(EMmsg,
                            &my_GRid, &dumindex),
                      targetid = active_state->objid,
                      targetos = active_state->osnum);
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;

    /*Set my active flags to true.*/
    ME.EMSdpr->dpr_props |= EMSIS_ACTIVE_STATE;
    ME.EMSdpr->dpr_props |= EMSIS_ACTIVE_PATH;

    /*The local mod should set the vg props since it wants to display
     * before connecting me to the active state.
     */

    /*Set last state to inactive state.*/
    action = FALSE;
    mask = EMSIS_ACTIVE_STATE;

    OM_stat = om$send(msg = message EMSdpr.EMsetprops(EMmsg, &action, 
                            &mask),
                      targetid = active_state->objid,
                      targetos = active_state->osnum);
    if(!(1 & *EMmsg & OM_stat)&&(OM_stat != OM_W_UNKNOWN_MSG))goto wrapup;

    OM_stat = OM_S_SUCCESS; /*fix the return code*/

   /*
    * Perform the post-processing (update cross section, mass/area designator,
    * MSCs other listeners) if it is not inhibited. 
    */

   if (EMcheck_inhibit_postproc())
     {
     om$send (msg = message EMSsurface.EMpostgeomod (&msg_loc,
      EMS_POST_SAVEDSTATE, env, OPPmargs, NULL),
      targetid = active_state->objid, targetos = active_state->osnum);
 
     EMrestore_postproc();
     }
  } 
  else {*EMmsg = EMS_E_InvalidArg; goto wrapup;}

#if THIS_NUTTY_STUFF_NEEDS_TO_BE_KEPT_IN_FOR_WHO_KNOWS_WHAT_REASON
  {
    if (active_state->objid == saved_state->objid)
    {*EMmsg = EMS_E_InvalidArg; goto wrapup;}

    OM_stat = EMmake_chanselect (GRconnector_to_owners, &to_owners);
    if (! (1 & OM_stat)) goto wrapup;

    /*If the the local mod operation was performed on an independent
     *  surface (the active state) there is a possibliity that the 
     *  local mod removed the active state i.e. split face removes
     *  the face it splits and replaces it with another.
     *
     *  If this is the case then I must handle it thusly...
     */

    OM_stat = om$get_channel_count(objid = active_state->objid,
                                   p_chanselect = &to_owners,
                                   count = &active_count);
    if (!(1 & OM_stat)) goto wrapup;

    if (! active_count)
    {
      OM_stat = om$send(msg = message EMSsfdpr.EMgetownerinfo(EMmsg, 
                              &next_state_GRid, &next_state_index),
                        targetid = my_id);
      if (!(1 & OM_stat & *EMmsg)) goto wrapup;
    }
    else
    {
      /*Get the object that is the next state to the active_state.*/
      OM_stat = om$get_objid_at_index(objid = active_state->objid,
                                      p_chanselect = &to_owners,
                                      index = 0,
                                      objidaddr = &next_state_GRid.objid,
                                      osnumaddr = &next_state_GRid.osnum);
      if (! (1 & OM_stat)) goto wrapup;

      /*Get the index wrt the next state to active state.
       * Must do this since a state needs to keep its last states ordered on
       *  the proper indices (i.e. boolean state).
       */
      OM_stat = om$get_index(objid_c = next_state_GRid.objid,
                             p_chanselect = &to_comps,
                             objid = active_state->objid,
                             indexaddr = &next_state_index);
      if (! (1 & OM_stat)) goto wrapup;

      /*Disconnect the active_state and its next state.*/
      OM_stat = om$send(msg = message GRconnector.GRdisconn(EMmsg,
                              &next_state_GRid),
                        targetid = active_state->objid);
      if (! (1 & OM_stat & *EMmsg)) goto wrapup;


      /*Connect me to the active_state.*/
      OM_stat = om$send(msg = message GRconnector.GRrigidconn(EMmsg,
                              &my_GRid, &dumindex),
                        targetid = active_state->objid);
      if (! (1 & OM_stat & *EMmsg)) goto wrapup;
    }

    /*Connect me to the active_states next state.*/
    OM_stat = om$send(msg = message GRconnector.GRrigidconn(EMmsg,
                            &next_state_GRid, &next_state_index),
                      targetid = my_id);
    if (! (1 & OM_stat & *EMmsg)) goto wrapup;

    /*Prep all of my next states for re-execute.*/
    OM_stat = om$send(msg = message EMSdpr.EMprep_reex(EMmsg, env),
                      targetid = next_state_GRid.objid);
    if (! (1 & OM_stat & *EMmsg)) goto wrapup;

    /*Construct the history object for this state.*/
    OM_stat = om$get_classid(object = me, p_classid = &my_classid);
    if (! (1 & OM_stat)) goto wrapup;

    OM_stat = om$is_ancestry_valid(subclassid = my_classid,
                                   superclassid = OPP_EMSsldpr_class_id);
    if (! (1 & OM_stat)) goto wrapup;

    if (OM_stat == OM_S_SUCCESS)
       construct_class = OPP_EMSslhist_class_id;
    else
       construct_class = OPP_EMSsfhist_class_id;

    OM_stat = om$construct(classid = construct_class,
                           p_objid = &history_GRid.objid);
    if (! (1 & OM_stat)) goto wrapup;

    history_GRid.osnum = OM_Gw_current_OS;

    /*Connect the history object as the next state of the saved state.*/
    OM_stat = om$send(msg = message GRconnector.GRrigidconn(EMmsg, 
                            &history_GRid, &dumindex),
                      targetid = saved_state->objid);
    if (! (1 & OM_stat & *EMmsg)) goto wrapup;
     
    /*Get SSI buffer*/
    OM_stat = om$send(msg = message EMSdpr.EMgetSSIbuffer(EMmsg, 
                            NULL, &ssi),
                      targetid = history_GRid.objid);
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;
    
    /*Store history SSI.*/
    my_info = &ssi->hst_info;

    my_info->added_id = my_id;
    my_info->added_on = active_state->objid;

    OM_stat = om$send(msg = message EMSdpr.EMputSSI(EMmsg, ssi),
                      targetid = history_GRid.objid);
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;       

    /*Set my last states active bits off.*/
    action = FALSE;
    mask = EMSIS_ACTIVE_STATE;

    OM_stat = om$send(msg = message EMSdpr.EMsetprops(EMmsg, &action, 
                            &mask),
                      targetid = active_state->objid);
    if (! (1 & OM_stat & *EMmsg) && (OM_stat != OM_W_UNKNOWN_MSG))
      goto wrapup;

    /*Set my active bits on.*/
    ME.EMSdpr->dpr_props |= (EMSIS_ACTIVE_STATE | EMSIS_ACTIVE_PATH);

   /*
    * Perform the post-processing (update cross section, mass/area designator,
    * MSCs other listeners) if it is not inhibited. 
    */

   if (EMcheck_inhibit_postproc())
     {
     om$send (msg = message EMSsurface.EMpostgeomod (&msg_loc,
      EMS_POST_SAVEDSTATE, env, OPPmargs, NULL),
      targetid = active_state->objid, targetos = active_state->osnum);
 
     EMrestore_postproc();
     }

    /*Send redo to the history state.  I will become inactive after this
     * send and the history state will be active. All relevent states
     * in between will be re-executed.
     */
    display_ids = NULL;
    display_count = 0;
    involk_count = 0;
    OM_stat = om$send(msg = message EMSdpr.EMredo(EMmsg, option, env,
                            &display_ids, &display_count, &involk_count),
                      targetid = history_GRid.objid);
    if (! (1 & OM_stat & *EMmsg)) goto wrapup;

    /*Attempt a graceful recovery from a boolean failure*/
    if (*EMmsg == EMS_I_BoolFail)
    {
      /*Make me inactive*/
      mask = EMS_TEMP_UNDO | *option;
      display_ids = NULL;
      display_count = 0;
      involk_count = 0;

      OM_stat = om$send(msg = message EMSdpr.EMundo(EMmsg, &mask, env,
                              NULL, NULL, NULL, &display_ids,
                              &display_count, &involk_count),
                        targetid = my_id);
      if (!(1 & OM_stat & *EMmsg)) goto wrapup;

      /*Disconnect me from my next states*/
      OM_stat = om$send(msg = message GRconnector.GRdisconn(EMmsg,
                              &next_state_GRid),
                        targetid = my_id);
      if (!(1 & OM_stat & *EMmsg)) goto wrapup;

      /*And from my last state if I have one.*/
      if (active_count)
      {
        OM_stat = om$send(msg = message GRconnector.GRdisconn(EMmsg,
                                &my_GRid),
                          targetid = active_state->objid);
        if (!(1 & OM_stat & *EMmsg)) goto wrapup;

        /*Connect my last and next state together*/
        OM_stat = om$send(msg = message GRconnector.GRrigidconn(EMmsg,
                                &next_state_GRid, &next_state_index),
                          targetid = active_state->objid);
        if (! (1 & OM_stat & *EMmsg)) goto wrapup;
      }          

     /*
      * Perform the post-processing (update cross section,
      * mass/area designator, MSCs other listeners) if it is not inhibited. 
      */

     if (EMcheck_inhibit_postproc())
       {
       om$send (msg = message EMSsurface.EMpostdelete (&msg_loc,
        EMS_POST_NOCOMPONENTS, env, OPPmargs, NULL),
        targetid = my_id);

       EMrestore_postproc();
       }

      /*Prep all next states for re-execute.*/
      OM_stat = om$send(msg = message EMSdpr.EMprep_reex(EMmsg, env),
                      targetid = next_state_GRid.objid);
      if (! (1 & OM_stat & *EMmsg)) goto wrapup;

      /*This send should return the solid to its state before the loc mod
       * was done.
       */
      display_ids = NULL;
      display_count = 0;
      involk_count = 0;

      OM_stat = om$send(msg = message EMSdpr.EMredo(EMmsg, option,
                              env, &display_ids, &display_count,
                              &involk_count),
                        targetid = saved_state->objid);
      if (! (1 & OM_stat & *EMmsg)) goto wrapup;

      if (*EMmsg == EMS_I_BoolFail)
      {
        /*The recovery failed so cleanup the dead parts of the tree. I do
         * this by first determining how far the recompute went.
         */
        OM_stat = om$send(msg = message EMSsurface.EMgetactiveid(EMmsg,
                                &saved_state, NULL),
                          targetid = active_state->objid);
        if (!(1 & OM_stat & *EMmsg)) goto wrapup;        

        /*Now that I know the good parts of the tree, I delete the bad
         * parts. 
         */
        OM_stat = om$send(msg = message EMSdpr.EMtreecleanup(EMmsg, env),
                          senderid = saved_state->objid,
                          p_chanselect = &to_owners, 
                          from = 0, to = 0);
        if (!(1 & OM_stat & *EMmsg)) goto wrapup;
      }

      /*Cleanup:  Delete the history object - A root delete is sufficient
       *          here.
       */

      /*Do a proper disconnect so the rigid rel bit is turned off.*/
      OM_stat = om$send(msg = message GRconnector.GRdisconn(EMmsg, 
                              &history_GRid),
                        targetid = saved_state->objid);
      if (! (1 & OM_stat & *EMmsg)) goto wrapup;

      OM_stat = om$send(msg = message Root.delete(NULL),
                        targetid = history_GRid.objid);
      if (!(1 & OM_stat)) goto wrapup;
   
      /*Tell the outside world what has happened.*/
      *EMmsg = EMS_I_BoolFail;
    }      
    else
    {
     /*
      * Perform the post-processing (update cross section, mass/area
            designator, 
      * MSCs other listeners) if it is not inhibited. 
      */

     if (EMcheck_inhibit_postproc())
      {
       om$send (msg = message EMSsurface.EMpostgeomod (&msg_loc,
        EMS_POST_SAVEDSTATE, env, OPPmargs, NULL),
        targetid = saved_state->objid, targetos = saved_state->osnum);
 
       EMrestore_postproc();
      }
    }
  } 
#endif


  wrapup:
    if (ssi) om$dealloc(ptr = ssi);
    EMWRAPUP(*EMmsg, OM_stat, "In EMSsfdpr.EMadd")
    return(OM_stat);
}

end implementation EMSsfdpr;
