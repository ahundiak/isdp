/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsubbs;

# include "EMS.h"
# include "msdef.h" /* MS message codes */
# include "madef.h"
# include "EMSssprops.h"
# include "godef.h"
# include "gocmacros.h"
# include "EMSfrtdef.h"

extern  OMuword     OPP_EMSchatch_class_id;

from EMSgradata import EMreset, EMget_class_info, EMchangeClass,
                       EMdelete_nat_gradata;

method GRputattr(IGRlong *EMmsg; IGRchar *attr)
/* 
DESCRIPTION

    This method loads the "class specific" attributes into a surface
    object.

RETURN VALUES

    EMmsg               MSSUCC if success
                        MSINARG if rule line counts are not in the set
                        [2,256] or polygon and pattern are both
                        turned off

HISTORY

    29 May 1993 Jack   Initialized gradata_classid to 0 to fix uninitialized memory
                       read (Purify).
    May 15,90: Inasu   Modified to take care of the problem when the surface
                       is cross hatched and key in nos of u's and v's are
                       same as the existing one for the surface.
                       (Fix for TR 90n0347).
    28 Apr 88   AIC     Arguments to EMSgradata.EMreset changed.
    dhm    04/05/88   add GR_NOTIFY_LISTENERS.
    10/02/87 : AIC, RC : Only change FRT classes if the attributes are
                         passed in and the polydis and surfdis flags are
                         the same.
    09/24/87 : RC  : If there is EMSchatch frt, change its class to
                     EMSgradata.
    07/15/87 : AIC : Rewritten for the new display functionality. The
                     default number of rule lines is the number of
                     internal multiple knots.
    03/27/87 : rlw : Rewritten due to the fact that the rule line counts
                     were compressed into one short and slow rule line
                     spacing was removed.
    09/21/86 : rlw : OM 4.0 conversion and bit field additions
    07/14/86 : rlw : The beginning
*/
{
  IGRlong           sts;
  struct IGResbs    *element_specific, default_attributes;
  OM_S_CHANSELECT   to_helpers;
  OMuword           gradata_classid = 0;
  GRobjid           newobjid;

  /*
   * Initialize
   */
  sts = OM_S_SUCCESS;
  *EMmsg = MSSUCC;

  to_helpers.type = OM_e_addr;
  to_helpers.u_sel.addr = &me^^EMSrequester.to_helpers;

  if(attr) element_specific = (struct IGResbs *) attr;

  else /* Use default display attributes */
  {
    element_specific = &default_attributes;
    default_attributes.u_rules = 0;
    default_attributes.v_rules = 0;
    default_attributes.is_polydis = FALSE;
    default_attributes.is_surfdis = TRUE;
    default_attributes.is_slowdis = FALSE;
    default_attributes.type = 0;
  }

  /*
   * Check validity
   */
  if((element_specific->u_rules < 0) ||
     (element_specific->u_rules > 255) ||
     (element_specific->v_rules < 0) ||
     (element_specific->v_rules > 255) ||
     (! element_specific->is_surfdis))
  {
    *EMmsg = MSINARG;
    goto wrapup;
  }

  /* Check whether the surface has a EMSchatch and use this info  to take
     care of the problem of nos of u_line=v_line=0 and the surface is cross
     hatched.
  */
     
   *EMmsg = EMS_I_NoResponse;
   sts = om$send(msg = message EMSgradata.EMget_class_info(
                  EMmsg, &gradata_classid, NULL),
                 p_chanselect = &to_helpers);
   if(sts IS OM_W_UNKNOWN_MSG) sts = OM_S_SUCCESS;
   if(! (1 & sts & *EMmsg)) goto wrapup;


  if((element_specific->u_rules ISNT me^^EMSsubbs.u_rules) ||
     (element_specific->v_rules ISNT me^^EMSsubbs.v_rules) ||
     (gradata_classid IS OPP_EMSchatch_class_id))
  {

   /*
    * If the surface has a EMSchatch frt, change its class
    * to EMSgradata. -- RC 
    */

/* The following lines were moved up 
 * *EMmsg = EMS_I_NoResponse;
 * sts = om$send(msg = message EMSgradata.EMget_class_info(
 *                EMmsg, &gradata_classid, NULL),
 *               p_chanselect = &to_helpers);
 * if(sts IS OM_W_UNKNOWN_MSG) sts = OM_S_SUCCESS;
 * if(! (1 & sts & *EMmsg)) goto wrapup;
 */

   if((*EMmsg ISNT EMS_I_NoResponse) && 
      (gradata_classid IS OPP_EMSchatch_class_id))
   {
    OM_S_CHANSELECT  sf_ls_chan;
    OMuint           count;

    sf_ls_chan.type = OM_e_addr;
    sf_ls_chan.u_sel.addr = &ME.EMSsubbs->to_loopset;

    sts = om$get_channel_count(object = me, p_chanselect = &sf_ls_chan,
                               count = &count);
    if (!(1&sts)) goto wrapup;

    /*
     * If the surface does not have a loopset and has a chatch
     * object, the chatch object should be deleted.
     */
    if (count)
    {
      sts = om$send(msg = message EMSgradata.EMchangeClass(
                     EMmsg, OPP_EMSgradata_class_id,
                     &OM_GS_NULL_MESSAGE, &newobjid),
                    p_chanselect = &to_helpers);
      if(sts IS OM_W_UNKNOWN_MSG) sts = OM_S_SUCCESS;
      if(! (1 & sts & *EMmsg)) goto wrapup;
     }
     else
     {
      sts = om$send(msg = message EMSgradata.EMdelete_nat_gradata(
                        EMmsg),
                    p_chanselect = &to_helpers);
      if(sts IS OM_W_UNKNOWN_MSG) sts = OM_S_SUCCESS;
      if (!(1&sts& *EMmsg)) goto wrapup;
     }

    } /* if(*EMmsg ISNT EMS_I_NoResponse) &&
         (gradata_classid IS OPP_EMSchatch_class_id)) */
    else
    {
     sts = om$send(msg = message EMSgradata.EMreset(
                    EMmsg,
                    EMS_O_OUTOFDATE),
                   p_chanselect = &to_helpers);
     if(sts IS OM_W_UNKNOWN_MSG) sts = OM_S_SUCCESS;
     if(! (1 & *EMmsg & sts)) goto wrapup;
    }

  } /* if((element_specific->u_rules ISNT me^^EMSsubbs.u_rules) ||
          (element_specific->v_rules ISNT me^^EMSsubbs.v_rules)) */

  /*
   * Change the instance data
   */
  if(element_specific->is_polydis) me^^EMSsubbs.ss_props |= EMSIS_POLYDIS;
  else me^^EMSsubbs.ss_props &= ~EMSIS_POLYDIS;

  me^^EMSsubbs.u_rules = element_specific->u_rules;
  me^^EMSsubbs.v_rules = element_specific->v_rules;

wrapup:
  GR_NOTIFY_LISTENERS(EMmsg, &sts, GR_ATTR_MODIFIED);
  EMSmsgReport(sts, "EMSsubbs.GRputattr", FALSE);
  if EMSmsgReport(*EMmsg, "EMSsubbs.GRputattr", FALSE) sts = OM_E_ABORT;
  return(sts);
}

end implementation EMSsubbs;
