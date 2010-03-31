/* ###################   APOGEE COMPILED   ################## */
/*
  DESCRIPTION

    This file contains the implementations of all the post-processing methods
    that are defined at this class. If the difference between potential
    implementation at lower levels is not too much, classid checks are
    performed here to do whatever is special.

  HISTORY

    SS  :  10/12/89  :  Creation
    DLB :  11/27/89  :  Initialized the chan_to_notify chanselector in 
                        the EMpostdelete method.  This was
                        causing memory faults in some cases.
    pp  :  06/06/91  :  Made modifications to notify the batch if this
                        is a subclass of EMSassoc.
*/
    
class implementation EMSsurface;

%safe
#include <math.h>
%endsafe

#include "ndmacros.h" /* For nd$wait_batch */
#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

from EMSboundary import EMpostdelete;
from EMSdpr import EMgetmodinfo;
from EMSxsection import EMupdate;
from EMSmassprop import EMmpdisplay, EMmpdelete;

extern OMuword OPP_EMSassoc_class_id;

method EMpostgeomod (IGRlong *msg; IGRushort options;
                     struct GRmd_env *model_env;
                     OM_p_MESSAGE messg; IGRchar *classinfo)
{
  IGRboolean components_found;
  IGRulong notify_mask;
  IGRint i;
  IGRlong send_rc, msg_loc, stat_OM;
  struct  GRvg_construct construct_list;
  struct EMSmodobjinfo modobjinfo_mem, *modobjinfo;
  enum GRdpmode display_mode;
  OM_S_CHANSELECT chan_to_notify, chan_to_owner, chan_to_loopset;

  *msg = EMS_S_Success;

  modobjinfo = NULL;

  EMmake_chanselect (GRnotify_notification, &chan_to_notify);

  /*
   * Perform the cross-section update if a cross-section exists. This
   * would be a useful send only in the case of this object being subclassed
   * off EMSsolid.
   */

  construct_list.env_info = model_env;
  construct_list.msg = &msg_loc;
  om$send (msg = message EMSxsection.EMupdate (&msg_loc, model_env,
   &construct_list), p_chanselect = &chan_to_notify);

  /*
   * Perform the mass-property update if a mass-prop object exists. This
   * is good for all EMSsurface's.
   */

  display_mode = GRbehe;
  om$send (msg = message EMSmassprop.EMmpdisplay (&msg_loc, model_env,
   &display_mode), p_chanselect = &chan_to_notify);

  if (! (options & EMS_POST_SAVEDSTATE))
    om$send (msg = message EMSmassprop.EMmpdelete (&msg_loc, model_env),
     p_chanselect = &chan_to_notify);

  /*
   * Notify all those connected on my notification channel, that my
   * geometry has been modified. OPPmargs being sent out will not probably
   * make sense, but such is life.
   */

  notify_mask = GR_GEOM_MODIFIED;
  GRnotifylisteners (&send_rc, &msg_loc, &notify_mask,
   messg ? messg : OPPmargs, &my_id);

  /*
   * If components notification is not inhibited, obtain the list of
   * component objects that have been modified at this node (and which are
   * connectable to listeners) and send them appropriate post-processing
   * methods.
   */

/*
 * Modified the following code since it is not longer necessary.
 * Do not define DOGS_EVER_FLY.
 * pp 09/30/91
 */
#if DOGS_EVER_FLY
  if (!(options & EMS_POST_NOCOMPONENTS))
    {
    components_found = FALSE;
    if (classinfo)
      {
      modobjinfo = (struct EMSmodobjinfo *) classinfo;
      components_found = TRUE;
      }
    else if (options & EMS_POST_SAVEDSTATE)
      {
      EMmake_chanselect (GRconnector_to_owners, &chan_to_owner);

      modobjinfo = &modobjinfo_mem;
      stat_OM = om$send (msg = message EMSdpr.EMgetmodinfo (&msg_loc,
                 NULL, modobjinfo), p_chanselect = &chan_to_owner);
      if (!EMSerror (stat_OM & msg_loc))
        components_found = TRUE;
      }
 
    if (components_found)
      {
      /*
       * All those surfaces, loops and edges that were removed/deleted during
       * this operation are sent a post-processing delete message.
       */

      for (i=0; i<modobjinfo->num_sfsdel; i++)
        om$send (msg = message EMSsurface.EMpostdelete (&msg_loc, NULL,
         model_env, OM_Gp_NULL_MESSAGE, NULL),
         targetid = modobjinfo->sfsdel[i]);

      for (i=0; i<modobjinfo->num_lpsdel; i++)
        om$send (msg = message EMSboundary.EMpostdelete (&msg_loc, NULL,
         model_env), targetid = modobjinfo->lpsdel[i]);

      for (i=0; i<modobjinfo->num_edsdel; i++)
        om$send (msg = message EMSboundary.EMpostdelete (&msg_loc, NULL,
         model_env), targetid = modobjinfo->edsdel[i]);

      /*
       * All those surfaces, loops and edges that were modified during this
       * operation are sent a post-processing modified message.
       */

      for (i=0; i<modobjinfo->num_sfsmod; i++)
        om$send (msg = message EMSsurface.EMpostgeomod (&msg_loc,
         EMS_POST_NOCOMPONENTS, model_env, OM_Gp_NULL_MESSAGE, NULL),
         targetid = modobjinfo->sfsmod[i]);

      for (i=0; i<modobjinfo->num_lpsmod; i++)
        om$send (msg = message EMSboundary.EMpostdelete (&msg_loc,
         EMS_POST_NOCOMPONENTS, model_env), targetid = modobjinfo->lpsmod[i]);

      for (i=0; i<modobjinfo->num_edsmod; i++)
        om$send (msg = message EMSboundary.EMpostdelete (&msg_loc,
         EMS_POST_NOCOMPONENTS, model_env), targetid = modobjinfo->edsmod[i]);
      }
    else
      {
      /*
       * The components of this object were not found. If this is a sub-class
       * of EMSsubbs, then send post-delete message to all the components
       * of the loopset that this object might be connected to. If this is
       * not a sub-class of EMSsubbs, then this message send will not make
       * sense.
       */

      EMmake_chanselect (EMSsubbs_to_loopset, &chan_to_loopset);

      om$send (msg = message EMSboundary.EMpostdelete (&msg_loc, NULL,
       model_env), p_chanselect = &chan_to_loopset);
      }
    }
#endif
/* end pp */

ret_end:
  if (modobjinfo && modobjinfo == &modobjinfo_mem)
    {
    if (modobjinfo->num_ptrs_malloced)
      {
      for (i=0; i<modobjinfo->num_ptrs_malloced; i++)
        om$dealloc (ptr = modobjinfo->ptrs_malloced[i]);
      om$dealloc (ptr = modobjinfo->ptrs_malloced);
      }
    }
  return (OM_S_SUCCESS);
}




method EMpostdelete (IGRlong *msg; IGRushort options;
                     struct GRmd_env *model_env;
                     OM_p_MESSAGE messg; IGRchar *moreinfo)
{
  IGRulong notify_mask;
  IGRlong send_rc, msg_loc, stat_OM;
  enum GRdpmode display_mode;
  OM_S_CHANSELECT chan_to_notify;

  *msg = EMS_S_Success;

  /*
   * Perform the necessary procedure for mass-property deletion. This
   * is good for all EMSsurface's.
   */
  EMmake_chanselect (GRnotify_notification, &chan_to_notify);

  display_mode = GRbehe;
  om$send (msg = message EMSmassprop.EMmpdisplay (&msg_loc, model_env,
   &display_mode), p_chanselect = &chan_to_notify);

  om$send (msg = message EMSmassprop.EMmpdelete (&msg_loc, model_env),
   p_chanselect = &chan_to_notify);

  /*
   * Notify all those connected on my notification channel, that I
   * have been deleted. OPPmargs being sent out will not probably make sense,
   * but such is life.
   */

  notify_mask = GR_DELETED;
  GRnotifylisteners (&send_rc, &msg_loc, &notify_mask,
   messg ? messg : OPPmargs, &my_id);

ret_end:
  return (OM_S_SUCCESS);
}

end implementation EMSsurface; 
