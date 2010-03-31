/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfboolean;

#include "emsdef.h"     
#include "EMSdpr.h"     /* EMchanstruct */
#include "bserr.h"
#include "bsparameters.h"
#include "EMSopt.h"
#include "emssfintdef.h"
#include "OMmacros.h"
#include "msdef.h"      /* MS_MAX_MSG_LENGTH */
#include "msmacros.h"   /* ex$message */
#include "EMS_I.h"      /* EMS_I_ProcessingSomething etc. */
#include "EMS_F.h"
#include "msdef.h"
#include "msmacros.h"
#include "ECmsg.h"

extern OMuword OPP_EMSsolid_class_id;

method EMreexecute(IGRlong              *EMmsg;
                   IGRushort    *option;
                   struct GRmd_env      *env;
                   IGRint               parent_count;
                   struct GRid          *parent_list;
                   IGRuint      type;
                   IGRchar              *recomp_info;
                   struct GRvg_construct *construct_list)
/*
Description
    Recompute the boolean/saveside operation.

Return values
    EMS_S_Success if all is well

History
    07/09/93    GMK TR 119300819, If i p - s s and no intersection then
                    leave the operation as EMbool_saveside.
    04/30/91    DLB Support new params.  Removed the last of the int plane svsd
                    code.
    04/08/91    DLB Moved op-type processing to sfb.construct_associative.
    03/29/91    DLB Support new construct_list parameter.
    03/21/91    DLB Send wrt parent EMreexecute.  And push some code to there 
                    and EMconstruct_associative.
    03/18/91    DLB If no intersections or non-fatal failure return EMS_E_Fail.
                    Change parms to parent_count, parent_list.
    03/08/91    DLB Mod to use dpr param object for display.  Also removed 
                    display_ids and display_count params.
    11/14/89    DLB If i p - s s and no intersection then convert to a standard
                    surface boolean.
    10/22/89    DLB Once again changed the logic for handling i p - s s
                    failures due to no intersection.  I hope this is the 
                    final change...
    09/29/89    DLB Set active state and path bits if failure due to no
                    intersection.
    07/21/89    DLB Removed reset of UNEVAL and NULL bits since the boolean
                    send already did this.
    06/21/89    DLB Added check for DISJ_DUE_TO_RETRY bit in the operation 
                    instance variable.  If this bit is set perform the
                    boolean with general type.  Otherwise use the exact type.
    05/31/89    DLB Added code to handle failure of intersect plane - save
                    side operations (namely no intersections).
    05/17/89    DLB Added code to correct composite to surface indices due
                    to random access tree editing.
    05/08/89    DLB Added option to perform disjoint boolean if applicable.
                    Also changed om$is_ancestry_valid calls to
                    EFisAncestryValid. 
    Jan/09/1989 jBk Replaced em$xsMessage invocations with ex$message
                    invocations.
                    Accordingly, replaced EMScimacros.h inclusion
                    with inclusion of msmacros.h.
    06/01/88    DLB Modified Sunit's saveside code to check for the
                    special saveside condition.  If it exists the
                    plane is gotten off of the ids vla rather than
                    off of the to_comps channel.
    11 May 1988 SM  If operation is save side on a surface/composite surface
                    send options EMSsfbool_opt_OpenIntPossible and
                    EMSsfbool_opt_SingleTopology for the boolean operation.
    09 May 1988 jBk Fixed oversight made upon conversion to message
                    subsystem.
    14 Apr 1988 jBk Removed all special cases for different boolean
                    types except for the case of EMSbool_saveside
                    where the infinite plane must be recomputed.
                    Converted to the message subsystem and removed
                    sleep invocations.
    19 Feb 1988 SS  Changed the arguments to EMboolean method
    04 Dec 1987 jBk Added message send for EMSbool_hollowDif and
                    EMSbool_disjointU.
                    Added status field messages for EMSbool_hollowDif
                    and EMSbool_disjointU.
    11/05/87    DLB Modified for version 1.1.0.
    29 Jul 1987 SM  Added code to regenerate the plane for intersect
                    plane save side operations.
    04/29/87    DLB Creation.
*/
{
 IGRlong               OM_stat=OM_S_SUCCESS, msgNumber;
 enum EMSbooltype      exact_type;
 IGRchar               status_str_array[MS_MAX_MSG_LENGTH+1];


 *EMmsg = EMS_S_Success;

 /* Get the operation type. */
 OM_stat = om$send(msg = message EMSsfboolean.EMget_operation_type(
                         EMmsg, NULL, &exact_type, NULL, NULL, NULL,
                         NULL, NULL, NULL, NULL, NULL, &msgNumber),
                   targetid = my_id);
 if (!(1 & OM_stat & *EMmsg)) goto wrapup;

 if (*option & EMS_DO_DISPLAY)
 {
   ex$message(msgnumb = msgNumber, buff = status_str_array);
   ex$message(msgnumb = EMS_I_ProcessingSomething,
              var = status_str_array, 
              type = "%s");
 }

 OM_stat = om$send(mode = OM_e_wrt_parent,
                   msg = message EMSsfboolean.EMreexecute(EMmsg, 
                         option, env, parent_count, parent_list,
                         type, recomp_info,
                         construct_list), 
                   targetid = my_id);

 if (*EMmsg == EMS_I_NoIntersection)
 {
   ex$message(msgnumb = EMS_I_SfSlEltsNoIntersect);

   /*If op is a saveside and no intersections found, leave plane on channel
    * since above nodes may still depend on it.  Previously, the plane was
    * removed from the channel and put on the vla.
    */

   if (exact_type == EMSbool_saveside && EFisAncestryValid(EMmsg, my_id, 
                                                         OM_Gw_current_OS,
                                                         OPP_EMSsolid_class_id,
                                                         FALSE)) 
   {
     /* GMK     TR 119300819
      * leaving the operation as EMSbool_saveside
      * -------------------------------------------------------------------
      *No intersections on a SOLID save side will result in a ill defined
      * condition.  For now I'll convert to a standard difference operation.
      *
      *   ex$message(msgnumb = EMS_E_ConvetIpssToBoolDiff)
      *   ME.EMSsfboolean->operation = EMSbool_difference;
      *--------------------------------------------------------------------
      *******/
   }

   /*If no inters then the active state and path bits need to be set here.*/
   ME.EMSdpr->dpr_props |= (EMSIS_ACTIVE_STATE | EMSIS_ACTIVE_PATH);

   *EMmsg = EMS_I_Fail;
   OM_stat = OM_S_SUCCESS;
 }

wrapup:
  EMWRAPUP(*EMmsg, OM_stat, "sfb.reex")
  return(OM_stat);
}
end implementation EMSsfboolean;
