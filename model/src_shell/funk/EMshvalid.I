/* ###################   APOGEE COMPILED   ################## */
/*
  DESCRIPTION

    Unless otherwise noted, this file contains the set of validator functions
    that can be used to validate the reuse of shell objects. The first
    function in this file - EMisshellvalid - is the default which gets
    invoked when the function pointer is set to NULL.

    The other functions in this file are user defined for special tasks

    Each function must have exactly the same formal arguments - i) a pointer
    to a long for the return message code, ii) an optional pointer to an
    additional information packet, iii) a pointer to the GRid structure
    containing the shell object-id to be validated (if NULL, the call
    is treated as a noop, except for the valid return of output argument-v,
    iv) a Boolean flag indicating whether the shell object and/or it's
    environment can be altered to transform it into a valid shell object,
    and v) an output integer that gives the identification number (a defined
    constant in this file) for the function. 

  NOTES

    An important point to stress here is that argument-iii, the additional
    information argument, is purely optional - that is - the caller may call
    the validator function without this addtional information. The action
    in this case should be appropriate.

    Every validator function has a unique identification number associated
    to it. These are defined at the top of this file. It is the number
    returned as argument-iv. The function EMvfunc_by_ident enables
    the calling of the validation functions by a unique number. For example:
    such numbers may be stored away in the data-base somewhere to retain
    a "pointer" to a particular validator function. This function also
    returns the pointer to the actual validator-function that it thus
    calls.

  HISTORY
 
    SS  :  05/02/88  :  Creation
    WBC :  04/30/91  :  Commented out references to the MSCEXISTS bits.
    WBC :  05/29/91  :  Uncommented out references to the MSCEXISTS bits.
*/

class implementation Root;

#include "EMS.h"
#include "OMerrordef.h"
#include "OMprimitives.h"
#include "OMmacros.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "igetypedef.h"
#include "dp.h"
#include "gr.h"
#include "godef.h"
#include "go.h"
#include "EMSmsgdef.h"
#include "EMSobjmgrdef.h"
#include "EMSprop.h"
#include "EMSopt.h"
#include "EMSstruct.h"
#include "emserr.h"
#include "emsdef.h"

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

extern GRclassid OPP_EMSloop_class_id;

from EMSloop import EMset_props;
from EMSedge import EMset_props;
from EMSboundary import EMchkbindings;
from EMSnatedge import EMmake_natural_edge;
from EMSsubbs import EMget_natedge_info;

/*
 * The function which enables calling the appropriate validator-function
 * given it's identifier.
 */

IGRboolean EMvfunc_by_ident (ident, msg, info, shellobj, readonly, vfunc)
IGRint ident;
IGRlong *msg;
IGRchar *info;
struct GRid *shellobj;
IGRboolean readonly;
IGRboolean (**vfunc)();
{
  IGRboolean objvalid;
  IGRboolean (*loc_vfunc)();
  IGRboolean EMisshellvalid();
  IGRboolean EMvalid_xyz_counterpart();
  IGRboolean EMlsvalidator();

  objvalid = FALSE;
  switch (ident)
    {
    case EMSvfunc_isshellvalid:
      loc_vfunc = EMisshellvalid;
      break;

    case EMSvfunc_valid_xyz_counterpart:
      loc_vfunc = EMvalid_xyz_counterpart;
      break;

    case EMSvfunc_lsvalidator:
      loc_vfunc = EMlsvalidator;
      break;

    default:
      loc_vfunc = NULL;
      *msg = EMS_E_Fail;
      return (FALSE);
    }

  if (shellobj && loc_vfunc)
    objvalid = (*loc_vfunc) (msg, info, shellobj, readonly, &ident);
  if (vfunc)
    *vfunc = loc_vfunc;
  return (objvalid);
}



/*
 * The following are the validator functions that follow a strict protocol
 * defined in the header in this file.
 */

IGRboolean EMisshellvalid (msg, info, shellobj, readonly, ident)
IGRlong *msg;
IGRchar *info;
struct GRid *shellobj;
IGRboolean readonly;
IGRint *ident;
{
  IGRboolean objvalid;
  OMuint chancount;
  IGRlong stat_OM;
  OM_S_CHANSELECT chan;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  objvalid = FALSE;
  if (! shellobj)
    goto ret_end;

  stat_OM = EMmake_chanselect (GRconnector_to_owners, &chan);
  EMomerr_exit (stat_OM, ret_end);

  stat_OM = om$get_channel_count (objid = shellobj->objid, 
             p_chanselect = &chan, count = &chancount);
  if (stat_OM != OM_S_SUCCESS || !chancount)
    {
    stat_OM = EMmake_chanselect (GRnotify_notification, &chan);
    EMomerr_exit (stat_OM, ret_end);

    stat_OM = om$get_channel_count (objid = shellobj->objid, 
               p_chanselect = &chan, count = &chancount);
    if (stat_OM != OM_S_SUCCESS || !chancount)
      objvalid = TRUE;
    }
 
ret_end:
  *ident = EMSvfunc_isshellvalid;
  return (EMSerror (*msg & stat_OM) ? FALSE : objvalid);
}


/*
   Special purpose validator function called to validate shell that
   are being used for model-space coutnerparts of uv-elements on a surface

   BUGS: The xyz_counterpart object can be entered into a name-directory
   hence making it invalid as a shell object. But this fact is not currently
   checked for. The xyz_counterpart might have message interception set
   up for it, but it is not being checked for here.
*/


IGRboolean EMvalid_xyz_counterpart (msg, info, shell, readonly, ident)
IGRlong *msg;
IGRchar *info;
struct GRid *shell;
IGRboolean readonly;
IGRint *ident;
{
  IGRboolean objvalid;
  OMuint chancount;
  IGRlong msg_loc, stat_OM;
  GRspacenum os, intercept_os;
  GRobjid obj, ownerobj, uvobj, intercept_obj;
  GRclassid uvobjclass;
  OM_S_CHANSELECT chan_to_notif, chan_to_owner, chan_to_comps;
  IGRlong EMmanipentry();

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  objvalid = FALSE;
  if (! shell)
    goto ret_end;

  os = shell->osnum;
  obj = shell->objid;

  /*
   * If the shell object is being intercepted by some other object,
   * then it not usable as a shell anymore.
   */

  stat_OM = om$get_intercept (osnum = os, objid = obj, 
             p_target_osnum = &intercept_os, p_target_objid = &intercept_obj);
  if (stat_OM == OM_S_SUCCESS)
    goto ret_end;
    
  /*
   * If there is no connection on the notification channel and
   * if it not connected to an owner which has something on the notification
   * channel, this shell object is useable. This object might have components
   * but that does not affect it's eligibility. The children are simply
   * disconnected. But some processing might be necessary to update the
   * model-space-counterpart table and also if necessary some processing on
   * the owner if one exists.
   */

  stat_OM = EMmake_chanselect (GRnotify_notification, &chan_to_notif);
  EMomerr_exit (stat_OM, ret_end);

  stat_OM = om$get_channel_count (objid = obj, osnum = os,
             p_chanselect = &chan_to_notif, count = &chancount);
  EMomerr_exit (stat_OM, ret_end);

  if (!chancount)
    {
    /*
     * This xyz-object has nothing on the notification
     * channel. Check further for eligibility.
     */

    stat_OM = EMmake_chanselect (GRcmpowner_to_components, &chan_to_comps);
    EMomerr_exit (stat_OM, ret_end);

    stat_OM = EMmake_chanselect (GRconnector_to_owners, &chan_to_owner);
    EMomerr_exit (stat_OM, ret_end);

    stat_OM = om$get_channel_count (objid = obj, osnum = os,
               p_chanselect = &chan_to_owner, count = &chancount);
    EMomerr_exit (stat_OM, ret_end);

    if (chancount)
      {
      /*
       * This xyz-object has an owner. Check to see if the owner has
       * anything on the notification channel. If it does, then this
       * xyz-object is not eligible.
       */

      stat_OM = om$get_objid_at_index (objid = obj, osnum = os,
                 p_chanselect = &chan_to_owner, index = 0, 
                 objidaddr = &ownerobj, osnumaddr = &os);
      EMomerr_exit (stat_OM, ret_end);

      stat_OM = om$get_channel_count (objid = ownerobj, osnum = os,
                 p_chanselect = &chan_to_notif, count = &chancount);
      EMomerr_exit (stat_OM, ret_end);

      if (!chancount && !readonly)
        {
        /*
         * The owner has nothing on the notification channel and the owner
         * can be disconnected from this child. Therefore, the given 
         * xyz-object is eligible. But the owner will no longer be valid. 
         * So the owner is disconnected from it's components. The model-space
         * counterpart manager's table is updated and the owner's corresponding
         * loop's property word is updated to indicate that it's model-space
         * counterpart does not exist anymore (uv-space object is assumed to
         * be a loop). The processing for the input shell object is handled
         * in a common place down below.
         */

        stat_OM = om$send (msg = message Root.wild_disconnect (chan_to_comps),
                   targetid = ownerobj, targetos = os, senderid = NULL_OBJID);
        EMomerr_exit (stat_OM, ret_end);

        stat_OM = EMmanipentry (&msg_loc, os, EMScp_sfbdry, 
                   EMScpmanip_del | EMScpmanip_cpwise, 1, &uvobj, &ownerobj);
        EMomerr_exit (stat_OM, ret_end);
        EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

        stat_OM = om$send (msg = message EMSloop.EMset_props (&msg_loc,
                   EMLP_MSCEXISTS, EMS_O_OFF), targetid = uvobj,
                   targetos = os, senderid = NULL_OBJID);
        EMomerr_exit (stat_OM, ret_end);

        objvalid = TRUE;
        }
      }
    else
      {
      /*
       * The given shell-object does not have an owner and neither
       * does it have anything on it's notification channel. Therefore,
       * this object is eligible.
       */

      objvalid = TRUE;
      }

    if (objvalid && !readonly)
      {
      /* This object has been pronounced valid. Some processing is
       * necessary before return. Check if the given object has any
       * children (if it of a class eligible to have children). If it
       * does, disconnect them. Delete this object's entry from the 
       * model-space counterpart table. Also, set the uv-objects property
       * bit off which indicates presence of the model-space counterpart. 
       */

      chancount = 0;
      stat_OM = om$get_channel_count (objid = obj, 
                 p_chanselect = &chan_to_comps, count = &chancount);
      if (stat_OM == OM_S_SUCCESS && chancount)
        {
        stat_OM = om$send (msg = message Root.wild_disconnect (chan_to_comps),
                   targetid = obj, targetos = os, senderid = NULL_OBJID);
        EMomerr_exit (stat_OM, ret_end);
        }

      stat_OM = EMmanipentry (&msg_loc, os, EMScp_sfbdry, 
                 EMScpmanip_del | EMScpmanip_cpwise, 1, &uvobj, &obj);
      EMomerr_exit (stat_OM, ret_end);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
     
      if (!IF_NULL_OBJID (uvobj))
        {
        stat_OM = om$get_classid (objid = uvobj, p_classid = &uvobjclass);
        EMomerr_exit (stat_OM, ret_end);
  
        stat_OM = om$is_ancestry_valid (subclassid = uvobjclass,
                   superclassid = OPP_EMSloop_class_id);
        EMomerr_exit (stat_OM, ret_end);

        if (stat_OM == OM_S_SUCCESS)
          stat_OM = om$send (msg = message EMSloop.EMset_props (&msg_loc,
                     EMLP_MSCEXISTS, EMS_O_OFF), targetid = uvobj, 
                     targetos = os, senderid = NULL_OBJID);
        else
          stat_OM = om$send (msg = message EMSedge.EMset_props (&msg_loc,
                     EMED_MSCEXISTS, EMS_O_OFF), targetid = uvobj, 
                     targetos = os, senderid = NULL_OBJID);
        EMomerr_exit (stat_OM, ret_end);
        }
      }
    }
 
ret_end:
  *ident = EMSvfunc_valid_xyz_counterpart;
  return (EMSerror (*msg & stat_OM) ? FALSE : objvalid);
}


/*
 * Function that the shell-manager may call to see if the loopset in it's
 * data-base is currently a candidate as a shell loopset. This function
 * is currently used in the file EMsslocate.I
 */

#define FIRST_EDGE 1
#define LAST_EDGE  4

IGRboolean EMlsvalidator (msg, sfinfo, ls_shid, readonly, ident)
IGRlong *msg;
struct EMSgrobj *sfinfo;
struct GRid *ls_shid;
IGRboolean readonly;
IGRint *ident;
{
  IGRboolean ls_shvalid;
  IGRuchar cvtypes[4];
  IGRushort edprops[4];
  OMuint count;
  IGRint  i, j;
  IGRlong msg_loc, stat_OM;
  GRobjid sfobj, components[5]; 
  GRspacenum os;
  struct GRmdenv_info *mdenv;
  OM_S_CHANSELECT chan_to_loopset, chan_to_surface;
/*   OM_S_CHANSELECT chan_to_edges, chan_to_commedge; ---  variable not used */
OM_S_CHANSELECT chan_to_commedge;
  OM_S_OBJECT_LINKAGE objlink;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  ls_shvalid = FALSE;
  if (! ls_shid)
    goto ret_end;

  /*
   * Check if this loopset has any bindings/obligations which prevent it
   * from being used as a shell. That is, been modified to non-natural
   * or it has entered any relationship with any other object. If it
   * is considered obligated, this loopset is no longer a valid shell.
   */

  os = ls_shid->osnum;
  stat_OM = om$send (msg = message EMSboundary.EMchkbindings (&msg_loc,
             NULL, components), targetid = ls_shid->objid, targetos = os,
             senderid = NULL_OBJID);
  EMomerr_exit (stat_OM, ret_end);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

  if (msg_loc != EMS_S_Success)
    goto ret_end;

  if (!readonly)
    {
    /*
     * The given shell loopset must be disconnected from the surface
     * to which it is currently attached and connected to and initialized
     * with respect to the input surface (if one has been passed in). But
     * if it is already connected to the final surface, leave the loopset
     * alone.
     */

    if (sfinfo)
      {
      sfobj = sfinfo->grid.objid;
      mdenv = sfinfo->envptr ? sfinfo->grenv.ptr : &sfinfo->grenv.val;
      }
    else
      sfobj = NULL_OBJID;

    stat_OM = EMmake_chanselect (EMSloopset_to_surface, &chan_to_surface);
    EMomerr_exit (stat_OM, ret_end);
  
    stat_OM = om$get_channel_objects (objid = ls_shid->objid, osnum = os,
               p_chanselect = &chan_to_surface, list = &objlink, size = 1,
               count = &count);
    EMomerr_exit (stat_OM, ret_end);

    if (count && objlink.S_objid != sfobj)
      {
      stat_OM = om$send (msg = message Root.wild_disconnect (chan_to_surface),
               targetid = ls_shid->objid, targetos = os, 
               senderid = NULL_OBJID);
      EMomerr_exit (stat_OM, ret_end);
      }

    if (sfinfo && (!count || objlink.S_objid != sfobj))
      {
      stat_OM = EMmake_chanselect (EMSsubbs_to_loopset, &chan_to_loopset);
      EMomerr_exit (stat_OM, ret_end);
  
      stat_OM = om$send (msg = message Root.connect (chan_to_surface, NULL,
                 sfobj, os, chan_to_loopset, NULL), targetid = ls_shid->objid,
                 targetos = os,  senderid = NULL_OBJID);
      EMomerr_exit (stat_OM, ret_end);
      
      stat_OM = om$send (msg = message EMSsubbs.EMget_natedge_info (&msg_loc,
                 mdenv, cvtypes, edprops), targetid = sfobj, targetos = os,
                 senderid = NULL_OBJID);
      EMomerr_exit (stat_OM, ret_end);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_SurfaceError, ret_end);

      stat_OM = EMmake_chanselect (EMSedge_to_common_edge, &chan_to_commedge);
      EMomerr_exit (stat_OM, ret_end);

      for (i=FIRST_EDGE, j=0; i<=LAST_EDGE; i++, j++)
        {
        stat_OM = om$send (msg = message EMSnatedge.EMmake_natural_edge
                   (&msg_loc, j, &cvtypes[j], &edprops[j]), 
                   targetid = components[i], targetos = os, 
                   senderid = NULL_OBJID);
        EMomerr_exit (stat_OM, ret_end);
        EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_EdgeError, ret_end);

        if (j<2)
          {
          stat_OM = om$send (msg = message Root.wild_disconnect 
                     (chan_to_commedge), targetid = components[i], 
                     targetos = os, senderid = NULL_OBJID);
          EMomerr_exit (stat_OM, ret_end);

          if (edprops[j] & EMED_SEAM)
            {
            stat_OM = om$send (msg = message Root.connect (chan_to_commedge, 0,
                       components[i], os, chan_to_commedge, 0),
                       targetid = components[i+2], targetos = os,
                       senderid = NULL_OBJID);
            EMomerr_exit (stat_OM, ret_end);
            }
          }
        }
      }
    }
  ls_shvalid = TRUE;

ret_end:
  *ident = EMSvfunc_lsvalidator;
  return (EMSerror (*msg & stat_OM) ? FALSE : ls_shvalid);
}

end implementation Root;
