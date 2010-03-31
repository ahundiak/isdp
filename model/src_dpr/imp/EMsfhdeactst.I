/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfhist;

#include "EMS.h"
#include "EMSdpr.h"         /*EMSinlist; KNOWN_DEPENDENT*/

method EMdeactivateState(IGRlong *EMmsg; struct EMSinlist *inlist;
                         IGRushort flags, options; 
                         IGRint *display_count; GRobjid **display_ids;
                         struct GRmd_env *env)
/*
Description
    This message will deactivate those states of a DPR tree needed in
    order to unevaluate a particular node.

Return Values    
    EMS_S_Success if all is well.

Notes
    About parameters:
        inlist  - contains surf/loop/edge ids that have been added so far. 
        flags   - indicates status of this state.  Current values are
                  EMdeact_st_KNOWN_DEPENDENT - this state is a dependent of
                  the node to unevaluate so it must be deactivated.
        options - EMdeact_st_ADD_MANAGER - add a manager to the states being
                    unevaluated. 
                    This option should be specified when the unevaluated node
                    will be reevaluated without control being returned to the
                    user. 
                  EMdeact_st_DELETE_SSI - delete the the SSI info.
                  EMdeact_st_DO_DISPLAY - if internal display is wanted.
        display_count - for use when doing internal display
        display_ids   - dito.

    About this particular override:
        This override does nothing but blow away the history object and repair
        the tree.  The reason for doing such a thing is obvious; the history
        object just doesn't make sense in a random access tree.

History
    DLB 12/07/88 Creation.
*/
{
  IGRlong           OM_stat=OM_S_SUCCESS;
  OMuint            count;
  GRobjid           my_comp_id;
  OM_S_CHANSELECT   to_owners, to_comps;
  struct GRid       temp_GRid;
  OMuword           dumosnum;


  *EMmsg = EMS_S_Success;

  EMmake_chanselect(GRconnector_to_owners, &to_owners);

  /*Send this message on to the owner.*/
  OM_stat = om$send(msg = message EMSdpr.EMdeactivateState(EMmsg, inlist,
                          flags, options, display_count,display_ids, env),
                    p_chanselect = &to_owners);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;

  /*Now remove me from the tree.*/
  EMmake_chanselect(GRcmpowner_to_components, &to_comps);

  /*Get my last states id (there will only be one since I am a history).*/
  OM_stat = om$get_objid_at_index(object = me,
                                  p_chanselect = &to_comps,
                                  index = 0,
                                  objidaddr = &my_comp_id,
                                  osnumaddr = &dumosnum);
  if (! (1 & OM_stat)) goto wrapup;

  OM_stat = om$get_channel_count(object = me,
                                 p_chanselect = &to_owners,
                                 count = &count);
  if (count)
  {
    /*Move my to_owners channel to the component id.  Due to a send being in
     * progress on the to_comps channel I cannont disconnect me and to a
     * move_chan.  Therefore I will leave me connected to the comp_id and
     * do a set operation.
     */
    OM_stat = om$send(msg = message Root.set_operation(to_owners, my_id,
                            OM_Gw_current_OS, to_owners, my_comp_id,
                            OM_Gw_current_OS, to_owners, 'U', NULL),
                      targetid = my_comp_id);
    if (!(1 & OM_stat)) goto wrapup;
  }

  /*Disconnect me from my last state.*/
  temp_GRid.objid = my_id;
  temp_GRid.osnum = OM_Gw_current_OS;
  OM_stat = om$send(msg = message GRconnector.GRdisconn(EMmsg, &temp_GRid),
                    targetid = my_comp_id);
  if (! (1 & OM_stat & *EMmsg)) goto wrapup;

  if (ME.GRgraphics->properties & GR_RIGID_RELATIONSHIP)
  {
    /*Handle setting of my_comp_id's RIGID_RELATIONSHIP bit.*/
    IGRboolean        action=TRUE;
    IGRshort          mask=GR_RIGID_RELATIONSHIP;

    OM_stat = om$send(msg = message GRgraphics.GRchgprops(EMmsg, &action,
                            &mask), 
                      targetid = my_comp_id);
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;
  }

  if (ME.EMSdpr->dpr_props & EMSIS_ACTIVE_STATE)
  {
    /*Handle setting of my_comp_id's ACTIVE_STATE bit.*/
    IGRboolean        action=TRUE;
    IGRushort mask=EMSIS_ACTIVE_STATE;

    OM_stat = om$send(msg = message EMSdpr.EMsetprops(EMmsg, &action, &mask),
                      targetid = my_comp_id);
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;
  }

  /*Delete me.*/
  OM_stat = om$send(msg = message Root.delete(NULL),
                    targetid = my_id);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;

  wrapup:
    EMWRAPUP(*EMmsg, OM_stat, "EMSsfhist.EMdeactivateState")
    return(OM_stat);
}
end implementation EMSsfhist;
