/**********

NOTE, NOTE, NOTE:

DO NOT ACCESS ANY INSTANCE DATA DIRECTLY IN THIS METHOD!!!! THE CLASS OF
OBJECT MAY CHANGE DURING 'EMconstruct_associative'. THE ONLY WAY TO ACCESS
INSTANCE DATA IN SUCH A CASE IS TO SEND A MESSAGE. FOR e.g DO NOT USE
ME.GRgraphics->properties DIRECTLY. INSTEAD SEND GRchgprops MESSAGE.

	SM	04-Jun-92	
*************/
class implementation EMSassoc;
#include "EMS.h"
#include "asbox.h" /* For NULL_GRID */
#include "nddef.h" /* For ND_NC_NEW */
#include "asmacros.h" /* For as$make_source */
#include "emserr.h"
#include "EMSasdef.h" /* For EMS_no_const_assoc */
#include "EMSopt.h"
#include "EMSssprops.h"
#include "EMSprop.h"

extern OMuword OPP_EMSsurface_class_id, OPP_EMSparameter_class_id;
extern OMuword OPP_EMSpointer_class_id;

extern IGRboolean WANT_POST220_BEHAVIOR;

from EMSsubbs   import EMset_props, EMput_range_in_rtree;
from EMSsurface import EMgetactiveid, EMtransform_to_associative;
from EMSpointer import EMinit;

method EMinit_associative  (IGRlong *EMmsg;
                            IGRushort options;
                            IGRint num_parents;
                            struct EMSobject_info *parent_info;
                            IGRint type;
                            IGRuint size;
                            IGRchar *recomp_info;
                            struct GRvg_construct *construct_list)
/* ***************************************************************************
Description
 This method constructs the source objects for each parent and connects
 them to me (dummy object). The parents are connected in the order in which
 they appear in the list array. After that an EMconstruct_associative
 message is sent to myself.

Arguments
Input
  options: ubiquitous argument - see EMSasdef.h
  num_parents : number of parents.
  list : GRid and module environment of parents.
  type : Type to interpret the recomputation information.
  size : Size of recomputation data. If there does not exist
         any recomputation data then the same may be set to NULL. This
         typically but not necessarily corresponds to a structure
         declaration which are defined in EMSas.h.
  recomp_info: character pointer to internal data. An EMput_info is message
         is sent with recomp_info as argument for storage of the same
         into the vla. If there does not exist any internal data then
         the same should be set to NULL.
  construct_list : Construction information

Output
 EMmsg: Completion code.

Notes
 Upon exit the completion code will be one of the following:
 EMS_S_Success : If all is well.
 EMS_E_Fail : If there is an error in storing recomputation data.


WARNING
 This routine is very finely tuned. Please attempt to make modifications
 very carefully. It has a high probability of disturbing the balance in
 the universe.

Assumptions
 We are not going to have a composite surface/solid who is not subclassed
 off of NDnodein.

History
 Creation : PP : 07/31/88
 Rewritten for 2.0 : PP : 03/02/91
 mrm    04/04/91    added option to allow caller to omit the
                    EMconstruct_associative message send
 DLB    04/09/91    If any parents are external constraints then set the
                    GRHAS_EXTERNAL_CONSTRAINT bit.
 DLB    04/18/91    Always set GRIS_ASSOCIATIVE bit.
 DLB    05/03/91    Support now options.
 PP     05/04/91    Connect the parents after construct_associative.
 DLB    05/10/91    Pull out source creation and put it in EMmake_source msg.
 jhw    06/03/91    Added send of autodimension message.
 pp     06/19/91    Setting the externally constrained bit after the 
                    connection to the parents is done.
 pp     07/23/91    Support for stop
 pp     10/04/91    Setting ASbroadcast_in_progress to be true before
                    calling EMconstruct_associative to prevent the 
                    construction from adding any elements to the batch
 Jack   11/21/91    Added a second condition for sending the EMautodim 
                    message.  The construct_list must not be NULL.  This
                    was done since the options EMSinit_dont_connect_parents
                    and EMSasconst_noautodimension have the same value.
 SM     02/26/92    In the EMautodim message-send use loc_sts & loc_msg
		    so as not to overwrite return codes from
		    construct_assoc.
SM/SAM  01/27/93    After construct_assoc, put reduced surface range in the
                    Rtree. This is necessitated because the artificial setting
                    of ASbroadcast_in_progress to TRUE,per notes above,prevents
                    the reduced range from being posted automatically. See
                    src_surf/imp/EMssDisYours.I for more info.
 Rajiv  06/08/93    Added a call to EMset_units_convert_flag to set the units
                    convert bit in case of autodimensions.
 WBC    11/19/93    Only update the rtree after EMconstruct_associative
                    is called if EMconstruct_associative returns success
                    (TR#119313285).

******************************************************************* */
{
 IGRlong     status=OM_S_SUCCESS;
 struct GRid *source_list=NULL;
 IGRboolean save_broadcast_flag;
 extern IGRboolean ASbroadcast_in_progress;
 IGRshort action = 1, grprops = GRIS_ASSOCIATIVE;

 *EMmsg = EMS_S_Success;

 /* Set the property GRIS_POST220_OBJECT on 2.4. For an
    explanation of this property see $GRNUC/include/godef.h.

    Sunit 5/19/93.
 */
 if(WANT_POST220_BEHAVIOR)
  {
   IGRboolean action = TRUE;
   IGRshort mask = GRIS_POST220_OBJECT;
   status = om$send(msg = message GRgraphics.GRchgprops(EMmsg, &action, 
            &mask), targetid = my_id);
  }

 source_list = (struct GRid *)alloca(sizeof(struct GRid) * num_parents);
 EMerr_hndlr(!source_list, *EMmsg, EMS_E_DynamicMemoryAllocated, wrapup);

 status = om$send(msg = message EMSassoc.EMmake_source(EMmsg, NULL,
                        num_parents, parent_info, source_list),
                  targetid = my_id);
 EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

 if (!(options & EMSinit_dont_store_recomp_info))
 {
   status = om$send(msg = message EMSassoc.EMput_info(EMmsg, NULL, type, size, 
                          recomp_info),
                    targetid = my_id);
   EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
 }

 if (!(options & EMS_no_const_assoc))
 {
  IGRlong loc_sts=OM_S_SUCCESS, loc_msg=EMS_S_Success;

  save_broadcast_flag = ASbroadcast_in_progress;
  ASbroadcast_in_progress = TRUE;

  status = om$send (msg = message EMSassoc.EMconstruct_associative(EMmsg,
                          NULL,
                          NULL_OBJID, num_parents,
                          (IGRchar *)source_list,
                          type,
                          recomp_info,
                          construct_list),
                    targetid = my_id);
  ASbroadcast_in_progress = save_broadcast_flag;

  if ((1 & status) &&
      (construct_list && construct_list->env_info))
  {
   IGRuchar sfchange = GEOMETRICAL;
   IGRlong rc;

/*
 *  The property EMSIS_RTREE_RANGE_GOOD should be used internally
 *  --vidya 10/06/93
   IGRuchar sfchange = TOPOLOGICAL;
   (void) om$send(msg = message EMSsubbs.EMset_props(&rc, 
          EMSIS_RTREE_RANGE_GOOD, EMS_O_OFF), 
          targetid = my_id);
 */

    (void) om$send(msg = message EMSsubbs.EMput_range_in_rtree(&rc, 
                   NULL, NULL, NULL, sfchange, 
                    &construct_list->env_info->md_id), 
           targetid = my_id);
  }

  /* DO NOT USE 'status' AND 'EMmsg' VARIABLES FROM THIS POINT ONWARDS
     UNLESS AN ERROR CODE HAS TO BE RETURNED. THIS IS REQUIRED SO THAT
     INFORMATIONAL MESSAGES FROM THE ABOVE SEND ARE PRESERVED FOR THE
     COMMAND OBJECT DURING INITIAL PLACEMENT.
  */

/*
 * If the user has hit the stop button then we stop all processing
 * and goto wrapup.
 * pp 07/13/91
 */
  if (*EMmsg == EMS_I_Interrupt)
   goto wrapup;
/* end pp */
  EMerr_hndlr(!(1&status), *EMmsg, *EMmsg, wrapup);

  loc_sts = om$send(msg = message GRgraphics.GRchgprops(&loc_msg, &action, 
            &grprops), targetid = my_id);
  if (!(1 & loc_sts & loc_msg)) {*EMmsg = loc_msg; goto wrapup;}
	
  /* ME.GRgraphics->properties |= GRIS_ASSOCIATIVE;  -- SM 04-Jun-92*/
 }

 if (num_parents && !(options & EMSinit_dont_connect_parents))
 {
  IGRlong loc_sts=OM_S_SUCCESS;

  loc_sts = om$send(msg = message NDnode.NDconnect (num_parents,source_list,
                         NULL_GRID, ND_ADD), 
                   targetid = my_id);
  EMerr_hndlr (!(1&loc_sts), *EMmsg, EMS_E_Fail, wrapup);
 }

/*
 * Set the externally constrained bit.
 * pp 06/19/91
 */

 if (!(options & EMS_no_const_assoc))
 {
  IGRlong loc_sts=OM_S_SUCCESS, loc_msg=EMS_S_Success;

  loc_sts = om$send(msg = message GRgraphics.GRchgprops(&loc_msg, &action, 
            &grprops), targetid = my_id);
  if (!(1 & loc_sts & loc_msg)) {*EMmsg = loc_msg; goto wrapup;}

  /** ME.GRgraphics->properties |= GRIS_ASSOCIATIVE;  SM 04-June-92 **/

  loc_sts = om$send(msg = message EMSassoc.EMexternal_constraint_changed
                          (&loc_msg, EMext_const_chg_CHECK),
                    targetid = my_id);
  if (!(1 & loc_sts & loc_msg)) {*EMmsg = loc_msg; goto wrapup;}
 }

 /*
  * Perform auto-dimensioning if requested and if the caller passed
  * in a construct_list.
  */
 if (((!(options & EMSasconst_noautodimension)) && (construct_list != NULL)) &&
     !(options & EMSasconst_no_autodimension))
 {
    IGRlong loc_sts=OM_S_SUCCESS, loc_msg=EMS_S_Success;

    loc_sts = om$send ( msg = message EMSassoc.EMautodim
                                                ( &loc_msg,
                                                  construct_list->env_info ),
                       targetid = my_id );

    if ((loc_sts == OM_W_REJECTED_METHOD) || (loc_sts == OM_W_UNKNOWN_MSG))
        loc_sts = OM_S_SUCCESS;
    else if (!(1 & loc_sts & loc_msg)) 
     {
      *EMmsg = loc_msg; 
      goto wrapup;
     }
    else
     {
      /*
       * Set the units conversion property bit for the auto-dimensions.
       * Rajiv Agrawal 6/8/93
       */
       loc_sts = EMset_units_convert_flag (&loc_msg, NULL, 
                 construct_list->env_info, my_id );
     }
 }

wrapup:

 /* 
    Set the GRIS_POST220_OBJECT property again, just incase is was 
    re-initialized.
    Sunit 5/19/93.
 */
 if(WANT_POST220_BEHAVIOR)
  {
   IGRboolean action = TRUE;
   IGRshort mask = GRIS_POST220_OBJECT;
   IGRlong loc_msg;
   (void) om$send(msg = message GRgraphics.GRchgprops(&loc_msg, &action, 
          &mask), targetid = my_id);
  }

 EMWRAPUP (*EMmsg, status, "assoc.init_associative_const")

 return (status);
}
end implementation EMSassoc;

/*
   else 
   {
      OM_S_OBJID new_objid;
      status = OM_S_SUCCESS;
      if ((ptr_GRid->objid == active_GRid.objid) &&
          (context_GRid.objid != NULL_OBJID))
      {
       status = om$send (msg = message EMSsurface.EMtransform_to_associative
                             (EMmsg, &new_objid),
                       targetid = active_GRid.objid,
                       targetos = active_GRid.osnum);
       EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_OMerror, wrapup);
       active_GRid.objid = new_objid;
       make_source = FALSE;  
       source_list[i] = active_GRid;
      }
   }
*/
