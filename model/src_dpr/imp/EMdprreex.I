/* ###################   APOGEE COMPILED   ################## */
class implementation EMSdpr;

#include "emsdef.h"     
#include "EMSdpr.h"     /* EMchanstruct */
#include "EMSopt.h"
#include "EMSasopts.h"  /*  For EMSasconst_recompute */
#include "msdef.h"      /* MS_MAX_MSG_LENGTH */
#include "msmacros.h"   /* ex$message */
#include "EMS_I.h"      /* EMS_I_ProcessingSomething etc. */
#include "msdef.h"
#include "msmacros.h"
#include "ECmsg.h"

from EMSassoc import EMconstruct_associative;

method EMreexecute(IGRlong           *EMmsg; 
                   IGRushort *option; 
                   struct GRmd_env   *env; 
                   IGRint            parent_count;
                   struct GRid       *parent_list;
                   IGRuint   type;
                   IGRchar           *recomp_info;
                   struct GRvg_construct *construct_list)
/*
Description
    Recompute the dpr operation.

Return values
    EMS_S_Success if all is well

History
    02/05/92    DLB Reset OM_stat to good status if loc_msg indicates failure.
    01/24/92    pp  GR_ISASSOC bit was being set in all conditions.
                    Corrected the same
    05/07/91    DLB Set GRIS_ASSOC only if already set.
    04/30/91    DLB Move EMget_info out and support it as an incoming param.
    04/18/91    DLB Set GRIS_ASSOCIATIVE and (perhaps)
                    GRHAS_EXTERNAL_CONSTRAINT.
    03/21/91    DLB Pass out construct_associative return msg.
    03/14/91    DLB Change to 1.4 ND system. 
    02/19/91    DLB Check for ND_UPD_NOT_MODIFIED to indicate recompute
                    failure.
    01/24/91    DLB Display_ids and count no longer used here.  The EMSdprparam
                    object has replaced'em.
    11/26/90    DLB If recompute is successful set ACTIVE STATE/PATH bits on.
    10/31/90    DLB Creation.  Boo!!
*/
{
  IGRlong               OM_stat=OM_S_SUCCESS, loc_msg=EMS_S_Success;
  IGRboolean            rigid, has_external_constraint, is_associative,
                        is_post_220;


  *EMmsg = EMS_S_Success;
  
  rigid = ME.GRgraphics->properties & GR_RIGID_RELATIONSHIP;
  is_associative = ME.GRgraphics->properties & GRIS_ASSOCIATIVE;
  has_external_constraint = 
                        ME.GRgraphics->properties & GRHAS_EXTERNAL_CONSTRAINT;
  is_post_220 = ME.GRgraphics->properties & GRIS_POST220_OBJECT; 

  OM_stat = om$send(msg = message EMSassoc.EMconstruct_associative(&loc_msg,
                          EMSasconst_recompute, my_id, parent_count, 
                          (IGRchar *) parent_list,
                          type, recomp_info,
                          construct_list),
                    targetid = my_id);

  if (rigid) ME.GRgraphics->properties |= GR_RIGID_RELATIONSHIP;
  if (is_associative) ME.GRgraphics->properties |= GRIS_ASSOCIATIVE;
  if (has_external_constraint)
    ME.GRgraphics->properties |= GRHAS_EXTERNAL_CONSTRAINT;
  if (is_post_220)
    ME.GRgraphics->properties |= GRIS_POST220_OBJECT;

  ME.EMSdpr->dpr_props |= (EMSIS_ACTIVE_STATE | EMSIS_ACTIVE_PATH);

  ex$message(msgnumb = EMS_I_ProcessingComplete);

  if (!(1 & OM_stat & loc_msg) ||
      loc_msg == EMS_I_CantRecompute ||
      loc_msg == EMS_I_Fail)
  {
    if (EMS_SeverityLevel(loc_msg) == FATL)
    {
      ex$message(msgnumb = EMS_F_SevereFailure)
      loc_msg = EMS_F_Fail;
    }
    else
    {
      loc_msg = EMS_I_Fail;
    }
    OM_stat = OM_S_SUCCESS;
  }
  else /*It was successful.*/
  {
    /*Adjust this and next states composite to surface indices.*/
    OM_stat = EFadjust_inx(EMmsg, my_id, OM_Gw_current_OS, NULL);
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;  
  }
  
  *EMmsg = loc_msg;

wrapup:
  EMWRAPUP(*EMmsg, OM_stat, "dpr.EMreex")
  return(OM_stat);
}
end implementation EMSdpr;
