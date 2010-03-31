/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsubbs;
/*
HISTORY:

Long Ago: ?? 	Creation
08/26/92: NP 	Modified for ANSI compliance.

*/


#include "madef.h"
#include "godef.h"
#include "EMSopt.h"
#include "ndmacros.h"
#include "nddef.h" /* For ND_COMP */

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

from EMSboundary import EMpostdelete, EMpostxform_xyz, EMpostrtree;
from EMSboundary import EMsendtomsc;
from NDnode import NDmove_to_root;

extern OMuword OPP_EMSassoc_class_id;

method EMpostxform (IGRlong *msg; IGRushort options;
                    struct GRmd_env *model_env;
                    IGRshort *xmattyp; IGRmatrix xmat; 
                    OM_p_MESSAGE messg; IGRchar *moreinfo)
{
  IGRulong notify_mask;
  IGRlong send_rc, msg_loc;
  OM_S_CHANSELECT chan_to_loopset;
  struct GRid child_GRid;
  int i;
  extern IGRboolean ASbroadcast_in_progress;

  *msg = EMS_S_Success;

  /*
   * Take care of processing the model-space counterparts.
   */

  if (! (options & EMS_POST_NOCOMPONENTS))
    {
    EMmake_chanselect (EMSsubbs_to_loopset, &chan_to_loopset);
  
    om$send (msg = message EMSboundary.EMpostxform_xyz (&msg_loc, NULL,
     model_env, xmattyp, (IGRmatrix *) xmat), p_chanselect = &chan_to_loopset);
    }

  /*
   * Notify all those connected on my notification channel, that my
   * geometry has been modified. OPPmargs being sent out will not probably
   * make sense, but such is life.
   */

  notify_mask = GR_GEOM_XFORMED;
  GRnotifylisteners (&send_rc, &msg_loc, &notify_mask,
   messg ? messg : OPPmargs, &my_id);

/*
 * If I am subclass off EMAsurface then also notify the batch. 
 * pp 06/06/91
 */

  if (EFisAncestryValid(&msg_loc, my_id, OM_Gw_current_OS, 
                          OPP_EMSassoc_class_id, FALSE) &&
      !ASbroadcast_in_progress)
  {
    IGRuint children_count = 0;
    IGRint comp_type;
    struct GRid my_GRid;
    OM_S_CHANSELECT to_children;

    EMmake_chanselect(NDchildren_children, &to_children);
/*
 * I am determining the children count to avoid the problem of notifying
 * the batch when I am being copied and xformed. This will not be necessary
 * once GRNUC sets the bit to enable us to differentiate between the two.
 * When I am copied, there should not be any objects on the children channel.
 * pp 06/15/91
 */

    om$get_channel_count(p_chanselect = &to_children,
                         objid = my_id,
                         count = &children_count);


    my_GRid.objid = my_id;
    my_GRid.osnum = OM_Gw_current_OS;
    comp_type = ND_COMP;

    for (i=0;i<children_count;i++)
    {
     om$get_objid_at_index(objid = my_id,
                           p_chanselect = &to_children,
                           index = i,
                           objidaddr = &child_GRid.objid,
                           osnumaddr = &child_GRid.osnum);

     nd$wait_batch(
                   type = GR_GEOM_POSTED,
                   l_object = &child_GRid,
                   l_obj_info = &comp_type,
                   nb_obj = 1);
    }
  }

ret_end:
  return (OM_S_SUCCESS);
}

method EMpostdelete (IGRlong *msg; IGRushort options;
                     struct GRmd_env *model_env;
                     OM_p_MESSAGE messg; IGRchar *moreinfo)
{
  IGRlong msg_loc;
  extern IGRboolean ASbroadcast_in_progress;
  OM_S_CHANSELECT chan_to_loopset;

  *msg = EMS_S_Success;

  /*
   * Take care of processing the model-space counterparts. For now
   * just delete them.
   */

  if (! (options & EMS_POST_NOCOMPONENTS))
    {
    EMmake_chanselect (EMSsubbs_to_loopset, &chan_to_loopset);

    om$send (msg = message EMSboundary.EMpostdelete (&msg_loc, NULL,
     model_env), p_chanselect = &chan_to_loopset);
    }

  /*
   * In addition to the specialized processing for EMSsubbs, also perform
   * the general post-processing for all surfaces (EMSsurface).
   */

  om$send (mode = OM_e_wrt_message, msg = message EMSsurface.EMpostdelete (msg,
   options, model_env, messg, moreinfo), targetid = my_id);
/*
 * Support for handling associative children.
 * pp 06/09/91
 */

  if (EFisAncestryValid(&msg_loc, my_id, OM_Gw_current_OS, 
                          OPP_EMSassoc_class_id, FALSE) &&
      !ASbroadcast_in_progress)
  {
   OM_S_CHANSELECT to_children;
   struct GRid src_grid;

   EMmake_chanselect(NDchildren_children, &to_children);

/*
 * Send a NDmove_to_root message to my children.
 */
    if (!ASbroadcast_in_progress)
    {
     om$send (msg = message NDnode.NDmove_to_root(&msg_loc, &src_grid,
                   model_env),
             p_chanselect = &to_children);
    }
   }

ret_end:
  return (OM_S_SUCCESS);
}

method EMpostgeomod (IGRlong *msg; IGRushort options;
                     struct GRmd_env *model_env;
                     OM_p_MESSAGE messg; IGRchar *classinfo)
{
 IGRlong msg_loc;
 extern IGRboolean ASbroadcast_in_progress;

  om$send (mode = OM_e_wrt_message, msg = message EMSsurface.EMpostgeomod (msg,
   options, model_env, messg, classinfo), targetid = my_id);

  if ((EFisAncestryValid(&msg_loc, my_id, OM_Gw_current_OS, 
                         OPP_EMSassoc_class_id, FALSE)) &&
     (sender_id == my_id) && 
     !(ME.GRgraphics->properties & GRIS_ASSOCIATIVE)
     && !ASbroadcast_in_progress)
  {
    IGRuint children_count = 0;
    IGRint comp_type;
    IGRint i;
    struct GRid my_GRid, child_GRid;
    OM_S_CHANSELECT to_children;

    EMmake_chanselect(NDchildren_children, &to_children);
/*
 * I am determining the children count to avoid problems with entities
 * which have owners. Entities which have owners do not need to be notified
 * since they should already know of the modification that has occurred.
 * A case in point: conversion to plane stuff.
 *
 * pp 08/02/93
 */

    om$get_channel_count(p_chanselect = &to_children,
                         objid = my_id,
                         count = &children_count);


    my_GRid.objid = my_id;
    my_GRid.osnum = OM_Gw_current_OS;
    comp_type = ND_COMP;

    for (i=0;i<children_count;i++)
    {
     om$get_objid_at_index(objid = my_id,
                           p_chanselect = &to_children,
                           index = i,
                           objidaddr = &child_GRid.objid,
                           osnumaddr = &child_GRid.osnum);

     nd$wait_batch(
                   type = GR_GEOM_POSTED,
                   l_object = &child_GRid,
                   l_obj_info = &comp_type,
                   nb_obj = 1);
    }
  }
/* end pp */

  return (OM_S_SUCCESS);
}

method EMpostrtree (IGRlong *msg; IGRushort options;
                    IGRboolean add; struct GRmd_env *model_env;
                    OM_p_MESSAGE messg; IGRchar *moreinfo)
{
  IGRulong notify_mask;
  IGRlong send_rc, msg_loc;

  *msg = EMS_S_Success;

  /*
   * Take care of processing the model-space counterparts. 
   */
/*  05/08/91 - WBC - using batch mechanism to update model-space counterparts
  if (! (options & EMS_POST_NOCOMPONENTS))
    {
    OM_S_CHANSELECT chan_to_loopset;

    EMmake_chanselect (EMSsubbs_to_loopset, &chan_to_loopset);

    om$send (msg = message EMSboundary.EMpostrtree (&msg_loc, add,
     NULL, model_env), p_chanselect = &chan_to_loopset);
    }
*/
  /*
   * Notify all those connected on my notification channel, that my
   * geometry has been modified. OPPmargs being sent out will not probably
   * make sense, but such is life.
   */

  notify_mask = GR_RTREE_MANIPULATION;
  GRnotifylisteners (&send_rc, &msg_loc, &notify_mask,
   messg ? messg : OPPmargs, &my_id);

ret_end:
  return (OM_S_SUCCESS);
}

method EMpostsymmod (IGRlong *msg; IGRushort options;
                     IGRushort symtype;
                     struct GRsymbology *symb;
                     OM_p_MESSAGE messg; IGRchar *classinfo)
{
  IGRlong msg_loc;
  OM_S_CHANSELECT chan_select;

  *msg = EMS_S_Success;

  /*
   * Take care of processing the model-space counterparts. Basically,
   * have this message sent to all the MSCs.
   */

  if (! (options & EMS_POST_NOCOMPONENTS))
    {
    EMmake_chanselect (EMSsubbs_to_loopset, &chan_select);
  
    om$send (msg = message EMSboundary.EMsendtomsc (&msg_loc, messg,
     EMSmsc_edges | EMSmsc_innerloops), p_chanselect = &chan_select);

    EMmake_chanselect (EMSrequester_to_helpers, &chan_select);

    om$send (msg = message EMSboundary.EMsendtomsc (&msg_loc, messg,
     EMSmsc_edges | EMSmsc_innerloops), p_chanselect = &chan_select);
    }

ret_end:
  return (OM_S_SUCCESS);
}


end implementation EMSsubbs;
