class implementation Root;

#include <alloca.h>
#include "OMerrordef.h"
#include "OMmacros.h"
#include "OMindex.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "igetypedef.h"
#include "dp.h"
#include "gr.h"
#include "godef.h"
#include "go.h"
#include "msdef.h"
#include "EMSmsgdef.h"
#include "emserr.h"
#include "emsdef.h"
#include "ex.h"
#include "griodef.h"
#include "grio.h"
#include "lcdef.h"
#include "lc.h"
#include "EMSlcdef.h"
#include "EMSlc.h"
#include "exdef.h"


/*
  DESCRIPTION

    Investigates the input cvl-structure and determines the
    response the user had given.

  HISTORY

    SS  :  04/05/88  :  Creation
    SS  :  04/04/89  :  Modified manner in which the logic determines
                        whether or not the object was accepted.
    SA  :  05/10/90  :  Added the response-type EMSauto_stack.
*/

void EMgetcvlresp (cvl, resp)
struct GRlc_cvl *cvl;
enum EMSuser_responses *resp;
{
  IGRint io_response;
  IGRlong accmask, auto_acc;
  struct LC_action_args *act;
  struct LC_select_args *sel;

  act = (struct LC_action_args *) cvl->locate_args;
  sel = (struct LC_select_args *) act->loc_select_args;
  auto_acc = (sel->display_flag & NO_ACC_REJ_CYCLE ||
              sel->display_flag & LC_ACC_ONE_ELEMENT ||
	      sel->display_flag & LC_ACC_TWO_ELEMENT);
  io_response = *sel->response;
  accmask = sel->eventmask;
  
  if (*act->rc == LC_OBJ_LOCATED)
    *resp = EMSuser_accept;
  else if  ((io_response == CLEAR_STACK) ||
            (io_response == TERMINATE))
    *resp = EMSuser_kill;
  else if ((io_response == COMMAND) ||
           (io_response == D_COMMAND) ||
           (io_response == HELP) ||
           (io_response == EXEC) ||
           (io_response == CMD_STRING) ||
           (io_response == TOGGLE_COMMAND) ||
           (io_response == STRING) ||
           (io_response == EX_CMD_KEY) ||
           (io_response == EX_POCKET) ||
           (io_response == EX_CMD_KEY))
    *resp = EMSuser_stack;
  else if (auto_acc && *act->rc == LC_OBJS_IN_STACK)
    *resp = EMSauto_stack;
  else
    *resp = EMSuser_unknown;

  return;
}


/*
  DESCRIPTION

    Function to obtain the GRlc_info structure(s) that are to be
    looked at by the originator of the locate process. These contain
    information about the located object(s) if any. The user must input
    an array of two elements of GRlc_infos to accomodate a maximum
    of two located-objects (unless the caller is sure about it being
    otherwise).

  HISTORY

    SS  :  04/05/88  :  Creation
*/

void EMgetlocobj (msg, cvl, numlcinfo, lcinfos)
IGRlong *msg;
struct GRlc_cvl *cvl;
IGRint *numlcinfo;
struct GRlc_info *lcinfos;
{
  struct LC_action_args *act;
  struct LC_select_args *sel;
  struct GRevent *accevent;

  *msg = EMS_S_Success;
  act = (struct LC_action_args *) cvl->locate_args;
  sel = (struct LC_select_args *) act->loc_select_args;
  accevent = sel->acc_event1;
  if (*numlcinfo = accevent->num_id)
    OM_BLOCK_MOVE (accevent->located_object, lcinfos, *numlcinfo *
     sizeof (struct GRlc_info));
}


/*
  DESCRIPTION

    This function moves the channel connections of a specified channel from
    one object to another.  The object the channel connections are being moved
    to may have existing connections on the specified channel.  Also, the
    order of the connections on the other side of the specified connection
    will be maintained if the channel is ordered.

  HISTORY

    WBC  :  04/05/88  :  Creation
*/

void EMmovechan(msg, from_chanselect, from_objid, from_osnum,
                to_chanselect, to_objid, to_osnum)

IGRlong           *msg;
OM_S_CHANSELECT   from_chanselect;
OM_S_OBJID        from_objid;
OMuword           from_osnum;
OM_S_CHANSELECT   to_chanselect;
OM_S_OBJID        to_objid;
OMuword           to_osnum;
{
/*
  extern char *stackalloc();
  extern void stackfree();
*/
  IGRlong status;
  IGRint  channelcount,
         channel_index,
         i;
  OM_S_OBJECT_LINKAGE *channel_objects;
  OM_S_CHANSELECT     chanselector;

  *msg = EMS_S_Success;
  channel_objects = NULL;

  status = om$get_channel_count(objid = from_objid,
                                osnum = from_osnum,
                                p_chanselect = &from_chanselect,
                                count = (OMuint *)&channelcount);
  EMerr_hndlr(! (1 & status), *msg, EMS_E_Fail, finish);

  if (channelcount)
  {
    channel_objects = (OM_S_OBJECT_LINKAGE *) stackalloc(channelcount * sizeof(OM_S_OBJECT_LINKAGE));
    EMerr_hndlr(! channel_objects, *msg, EMS_E_NoDynamicMemory, finish);

    status = om$get_channel_objects(objid = from_objid,
                                    osnum = from_osnum,
                                    p_chanselect = &from_chanselect,
                                    list = channel_objects,
                                    size = channelcount,
                                    count = (OMuint *)&channelcount);
    EMerr_hndlr(! (1 & status), *msg, EMS_E_Fail, finish);

    for (i = 0; i < channelcount; i++)
    {
      chanselector.type = OM_e_num;
      chanselector.u_sel.number = channel_objects[i].channum;

      status = om$get_index(osnum_c = channel_objects[i].osnum,
                            objid_c = channel_objects[i].S_objid,
                            p_chanselect = &chanselector,
                            objid = from_objid,
                            osnum2 = from_osnum,
                            indexaddr = (OMuint *)&channel_index);
      EMerr_hndlr(! (1 & status), *msg, EMS_E_Fail, finish);

      status = om$send(msg = message Root.disconnect(chanselector, from_objid,
                                                   from_osnum, from_chanselect),
                       targetid = channel_objects[i].S_objid,
                       targetos = channel_objects[i].osnum,
                       senderid = NULL_OBJID);
      EMerr_hndlr(! (1 & status), *msg, EMS_E_Fail, finish);

      status = om$send(msg = message Root.connect(chanselector, OM_K_MAXINT,
                                                  to_objid, to_osnum,
                                                  to_chanselect, channel_index),
                       targetid = channel_objects[i].S_objid,
                       targetos = channel_objects[i].osnum,
                       senderid = NULL_OBJID);
      EMerr_hndlr(! (1 & status), *msg, EMS_E_Fail, finish);
    }
  }
finish:

  if (channel_objects)
    stackfree(channel_objects);
}


/*
  DESCRIPTION

    Function to move the father, children and notification objects from
    the current object to the new object.  Existence of the father and
    children channels will have to be checked for both objects.  If the
    current object is connected to an ASsource object via the notification
    channel and the new object is an associative object, the objects on the
    father and children channels of the ASsource object will be moved to
    the new object and the ASsource object will be deleted.

  HISTORY

    WBC :  04/11/91  :  Creation
*/

extern OMuword OPP_NDnodein_class_id;
extern OMuword OPP_ASsource_class_id;
extern OMuword OPP_ASsourcein_class_id;

void EMchgobj_movechans (msg, cur_stkobj, new_stkobj)
IGRlong *msg;
struct GRid *cur_stkobj;
struct GRid *new_stkobj;
{
  IGRlong status;
  IGRint channelcount;
  IGRint i;
  IGRint num_assoc_objs=0;
  struct GRid *assoc_objects;
  struct GRid *assoc_list;
  OM_S_OBJECT_LINKAGE *notify_objects;
  OM_S_CHANSELECT childchanselect;
  OM_S_CHANSELECT fatherchanselect;
  OM_S_CHANSELECT notifychanselect;
  OMuword classid;

  *msg = EMS_S_Success;
  notify_objects = NULL;

  if (cur_stkobj->objid != new_stkobj->objid ||
      cur_stkobj->osnum != new_stkobj->osnum)
    {
    /* if both the current located object and the new object are associative
     * objects in the same object space, move the objects on the children
     * and father channels from the ASsource object to the new object and
     * delete the ASsource object; if the current located object is
     * connected to an ASsource object via the notification channel and the
     * new object is an associative object and the new object and the
     * ASsource object are in the same object space, move the objects on the
     * children and father channels from the ASsource object to the new
     * object and delete the ASsource object
     */

    status = om$make_chanselect(channame = "GRnotify.notification", 
                                p_chanselect = &notifychanselect);
    EMerr_hndlr(! (1 & status), *msg, EMS_E_Fail, finish);

    status = om$get_classid(osnum = new_stkobj->osnum,
                            objid = new_stkobj->objid,
                            p_classid = &classid);
    EMerr_hndlr(! (1 & status), *msg, EMS_E_Fail, finish);

    status = om$is_ancestry_valid(subclassid = classid,
                                  superclassid = OPP_NDnodein_class_id);
    EMerr_hndlr(! (1 & status), *msg, EMS_E_Fail, finish);

    if (status != OM_I_INVANCESTRY)
    {
      assoc_list = NULL;

      if (cur_stkobj->osnum == new_stkobj->osnum)
      {
        status = om$get_classid(osnum = cur_stkobj->osnum,
                                objid = cur_stkobj->objid,
                                p_classid = &classid);
        EMerr_hndlr(! (1 & status), *msg, EMS_E_Fail, finish);

        status = om$is_ancestry_valid(subclassid = classid,
                                      superclassid = OPP_NDnodein_class_id);
        EMerr_hndlr(! (1 & status), *msg, EMS_E_Fail, finish);

        if (status != OM_I_INVANCESTRY)
        {
          assoc_list = cur_stkobj;
          num_assoc_objs = 1;
        }
      }

      if (! assoc_list)
      {
        /* either the current and new objects are not in the same object
         * space or the current object is not associative; see if the
         * current object is connected to an ASsource object (indirectly
         * associative)
         */

        status = om$get_channel_count(objid = cur_stkobj->objid,
                                      osnum = cur_stkobj->osnum,
                                      p_chanselect = &notifychanselect,
                                      count = (OMuint *)&channelcount);
        EMerr_hndlr(! (1 & status), *msg, EMS_E_Fail, finish);

        if (channelcount)
        {
          notify_objects = (OM_S_OBJECT_LINKAGE *) stackalloc(channelcount * sizeof(OM_S_OBJECT_LINKAGE));
          EMerr_hndlr(! notify_objects, *msg, EMS_E_NoDynamicMemory, finish);

          assoc_objects = NULL;
          assoc_objects = (struct GRid *) stackalloc(channelcount * sizeof(struct GRid));
          EMerr_hndlr(! assoc_objects, *msg, EMS_E_NoDynamicMemory, finish);

          status = om$get_channel_objects(objid = cur_stkobj->objid,
                                          osnum = cur_stkobj->osnum,
                                          p_chanselect = &notifychanselect,
                                          list = notify_objects,
                                          size = channelcount,
                                          count = (OMuint *)&channelcount);
          EMerr_hndlr(! (1 & status), *msg, EMS_E_Fail, finish);

          for (num_assoc_objs = 0, i = 0; i < channelcount; i++)
          {
            status = om$get_classid(osnum = notify_objects[i].osnum,
                                    objid = notify_objects[i].S_objid,
                                    p_classid = &classid);
            EMerr_hndlr(! (1 & status), *msg, EMS_E_Fail, finish);

            if (((classid == OPP_ASsource_class_id) ||
                 (classid == OPP_ASsourcein_class_id)) &&
                (new_stkobj->osnum == notify_objects[i].osnum))
            {
              assoc_objects[num_assoc_objs].objid = notify_objects[i].S_objid;
              assoc_objects[num_assoc_objs].osnum = notify_objects[i].osnum;
              num_assoc_objs++;
            }
          }

          if (num_assoc_objs)
            assoc_list = assoc_objects;
        }
      }

      if (assoc_list)
      {
        status = om$make_chanselect(channame = "NDchildren.children", 
                                    p_chanselect = &childchanselect);
        EMerr_hndlr(! (1 & status), *msg, EMS_E_Fail, finish);

        status = om$make_chanselect(channame = "NDfather.father", 
                                    p_chanselect = &fatherchanselect);
        EMerr_hndlr(! (1 & status), *msg, EMS_E_Fail, finish);

        for (i = 0; i < num_assoc_objs; i++)
        {
          /* find the objects connected to the objects in the associative list
           * on the children and parent channels, disconnect them, then connect
           * the objects that were connected to the associative objects to the
           * new_stkobj object; the message Root.move_chan can't be used since
           * the new_stkobj may already have objects connected on these
           * channels which would cause Root.move_chan to fail; also can't use
           * Root.set_operation message because it does not preserve the
           * ordering of the objects on the channel, which is important for
           * the dimensioning commands (and possibly others)
           */

          EMmovechan(msg, childchanselect, assoc_list[i].objid,
                     assoc_list[i].osnum, childchanselect, new_stkobj->objid,
                     new_stkobj->osnum);
          if (! (*msg & 1)) goto finish;

          EMmovechan(msg, fatherchanselect, assoc_list[i].objid,
                     assoc_list[i].osnum, fatherchanselect, new_stkobj->objid,
                     new_stkobj->osnum);
          if (! (*msg & 1)) goto finish;

          if (notify_objects)
          {
            /* delete the ASsource object since its no longer needed */

            status = om$send(msg = message Root.delete(FALSE),
                             targetid = assoc_list[i].objid,
                             targetos = assoc_list[i].osnum,
                             senderid = NULL_OBJID);
            EMerr_hndlr(! (1 & status), *msg, EMS_E_Fail, finish);
          }
        }
      }
    }

    /* can't use EMmovechan since the notify channel is not ordered */

    status = om$send(msg = message Root.set_operation(notifychanselect,
                                                      cur_stkobj->objid,
                                                      cur_stkobj->osnum,
                                                      notifychanselect,
                                                      new_stkobj->objid,
                                                      new_stkobj->osnum,
                                                      notifychanselect,
                                                      'u', 0),
                     targetid = new_stkobj->objid,
                     targetos = new_stkobj->osnum,
                     senderid = NULL_OBJID);
    EMerr_hndlr(! (1 & status), *msg, EMS_E_Fail, finish);
    }
finish:

  if (notify_objects)
    stackfree(notify_objects);
}


/*
  DESCRIPTION

    Function to replace the current GRlc_info structure(s) that are
    stored in the cvl structure. These GRlc_info structures are the
    ones that are looked at by the originator of the locate when a 
    locate has been successful. Also, if a stack entry exists, it is
    changed to be the first of the GRlc_infos passed in.

  HISTORY

    SS  :  04/05/88  :  Creation
    WBC :  04/05/91  :  Now call the function EMchgobj_movechans to move
                        the objects on the current object's channels to the
                        new object's channel.
    SCW :  03/12/93  :  Added class checking around the channel manipulation
                        function calls.
*/

extern OMuword OPP_EMSboundary_class_id;

void EMchglocobj (msg, cvl, numlcinfo, lcinfos)
IGRlong *msg;
struct GRlc_cvl *cvl;
IGRint numlcinfo;
struct GRlc_info *lcinfos;
{
  IGRlong msg_loc;
  struct LC_action_args *act;
  struct LC_select_args *sel;
  struct GRid cur_stkobj;
  struct GRid new_stkobj;
  struct GRevent *accevent;
  void EMchgstkobj();
  IGRboolean EFisAncestryValid();

  *msg = EMS_S_Success;

  if (numlcinfo && lcinfos)
    {
    act = (struct LC_action_args *) cvl->locate_args;
    sel = (struct LC_select_args *) act->loc_select_args;
    accevent = sel->acc_event1;

    OM_BLOCK_MOVE (&accevent->located_object[0].located_obj,
     &cur_stkobj, sizeof (struct GRid));
    OM_BLOCK_MOVE (&lcinfos->located_obj, &new_stkobj, sizeof (struct GRid));

    /* 
     * Check to see if we are dealing with edges, loops, etc.
     * If we are, we do not need to do the channel manipulations
     */
    if( !EFisAncestryValid( msg,
                            new_stkobj.objid,
                            new_stkobj.osnum,
                            OPP_EMSboundary_class_id,
                            0 ))
    {    
       EMchgobj_movechans(&msg_loc, &cur_stkobj, &new_stkobj);
    }

    OM_BLOCK_MOVE (lcinfos, accevent->located_object, numlcinfo *
      sizeof (struct GRlc_info));
    EMchgstkobj (msg, cvl, lcinfos);
    }
}


/*
  DESCRIPTION

    Function to replace the object in the current GRlc_stack 
    in the cvl structure. This object is the one to which control
    returns after the accept/reject cycle has been resumed after an
    interruption by command-stacking.

  HISTORY

    SS  :  07/19/88  :  Creation
    SA  :  05/10/90  :  Modified to put object in end of stack
    WBC :  04/05/91  :  Now call the function EMchgobj_movechans to move
                        the objects on the current object's channels to the
                        new object's channel.
    WBC :  03/24/93  :  Added class checking around the channel manipulation
                        function calls (same as SCW change to EMchglocobj).
*/

void EMchgstkobj (msg, cvl, lcinfo)
IGRlong *msg;
struct GRlc_cvl *cvl;
struct GRlc_info *lcinfo;
{
  IGRlong msg_loc;
  struct LC_action_args *act;
  struct GRlc_stack *stack;
  struct GRid cur_stkobj;
  struct GRid new_stkobj;
  IGRboolean EFisAncestryValid();

  act = (struct LC_action_args *) cvl->locate_args;
  stack = act->stack;
  *msg = EMS_S_Success;
  if (stack->num_entries)
    {
    OM_BLOCK_MOVE (&stack->entry[stack->num_entries - 1].located_obj,
     &cur_stkobj, sizeof (struct GRid));
    OM_BLOCK_MOVE (&lcinfo->located_obj, &new_stkobj, sizeof (struct GRid));

    /* 
     * Check to see if we are dealing with edges, loops, etc.
     * If we are, we do not need to do the channel manipulations
     */
    if( !EFisAncestryValid( msg,
                            new_stkobj.objid,
                            new_stkobj.osnum,
                            OPP_EMSboundary_class_id,
                            0 ))
    {    
        EMchgobj_movechans (&msg_loc, &cur_stkobj, &new_stkobj);
    }

    OM_BLOCK_MOVE (lcinfo, &stack->entry[stack->num_entries - 1],
     sizeof (struct GRlc_info));
    }
}


/*
  DESCRIPTION

    Function to clear the current GRlc_stack in the cvl structure.

  HISTORY

    SS  :  08/16/90  :  Creation
*/

void EMclearstack (msg, cvl)
IGRlong *msg;
struct GRlc_cvl *cvl;
{
  struct LC_action_args *act;
  struct GRlc_stack *stack;

  *msg = EMS_S_Success;

  act = (struct LC_action_args *) cvl->locate_args;
  stack = act->stack;
  stack->num_entries = 0;

  return;
}


/*
  DESCRIPTION

    Return a TRUE/FALSE value indicating whether there was a hit or
    not. That is, whether all the criteria (including geometric closeness
    to the user-input) was satisified. 

  HISTORY

    SS  :  05/18/88  :  Creation
    SCW :  03/12/93  :  Added the argsused to get rid of the compiler
                        warning.
*/

#argsused
IGRboolean EMnogeomhit (cvl)
struct GRlc_cvl *cvl;
{
  IGRboolean validinfo;
  GRobjid srfid, graid, edid;
  enum EMSsrfloctype loctype;
  extern IGRboolean EMsrfloc_getinfo();

  validinfo = EMsrfloc_getinfo (&srfid, &graid, &loctype, &edid);
  if (validinfo && loctype == EMSsrfloc_null)
    return (TRUE);
  else
    return (FALSE);
}

end implementation Root;
