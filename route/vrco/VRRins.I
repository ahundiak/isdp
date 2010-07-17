
/* $Id: VRRins.I,v 1.1.1.1 2001/01/04 21:12:43 cvs Exp $  */

/***********************************************************************
 * I/ROUTE
 *
 * File:        vrco/VRRins.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Log History:
 *	$Log: VRRins.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:12:43  cvs
 *	Initial import to CVS
 *	
# Revision 1.2  1998/08/05  15:59:46  pinnacle
# Replaced: vrco/VRRins.I for:  by lawaddel for route
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.2  1998/01/14  18:39:22  pinnacle
# Replaced: vrco/VRRins.I for:  by lawaddel for route
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.1  1997/02/24  21:57:18  pinnacle
# Created: vrco/VRRins.I by hverstee for route
#
 *
 * History:
 *    12/Jan/98     law     CR179701945 - Throat radius fields
 *    25/Jul/98     law     CR179801144 - Tier fields
 *
 ***********************************************************************/

class implementation VRRInsert;

#include <stdio.h>
#include <stdlib.h>
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "VRDbStruct.h"
#include "VRcmd.h"
#include "VRMcForm.h"
#include "VRPid.h"
#include "acrepdef.h"
#include "VRutildef.h"
#include "VRutilmacros.h"
#include "vdpktdef.h"
#include "vdpktmacros.h"
#include "VDmacdef.h"
#include "vdsmacros.h"
#include "VDSutil.h"
#include "vrco_pto.h"

%safe
#include "VX_FIproto.h"
#include <math.h>
%endsafe

#define VR_OPTCODE_LIST_NUM  400

from         ACncpx import  ACgive_structure;

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method VRInitInstance( IGRlong *sts )
{
  IGRint    status;

  extern
  int         GRstatus_display_button();

  status =
  om$send (msg = message VRCORway.VRInitInstance (sts),
      targetid = my_id,
          mode = OM_e_wrt_message);

  me->bSKF_up = TRUE;

  status = GRstatus_display_button(1);

  return (OM_S_SUCCESS);
}

method VRSKF_fill  (IGRlong *sts )
{
  IGRint    status;
/* Added for CR179801144 */
  struct ret_struct       ParamAttr;
  IGRint                  FootIndex = -1, retstatus;
  IGRint shape_code;

  status = OM_S_SUCCESS;
  *sts   = MSSUCC;

  FIg_erase  ( me->pSKF, AUTOMATIQUE_GRP );
  FIg_display( me->pSKF, MANUAL_GRP );

/*    Erase line number fields   */
  FIg_erase ( me->pSKF, 38 );
  FIg_erase ( me->pSKF, 226 );

/*    Erase shape fields         */
  FIg_erase ( me->pSKF, 22);
  FIg_erase ( me->pSKF, RW_C_SHAPE);
  FIg_erase ( me->pSKF, RW_R_SHAPE);
  FIg_erase ( me->pSKF, RW_C_SHAPE2);
  FIg_erase ( me->pSKF, RW_R_SHAPE2);
  FIg_erase ( me->pSKF, RW_T_SHAPE);
  FIg_erase ( me->pSKF, RW_TEXT_SHAPE2);

  if (bVR_IS_PID_ACTIVE)
  {
    FIg_display( me->pSKF, HV_SYMB_SCALE );
    FIg_display( me->pSKF, HV_SYMB_SCALE_LABEL );

    VR$DispCollAttr ( pForm         = me->pSKF,
                      pCollId       = &me->SysParamId,
                      Gadget        = HV_SYMB_SCALE,
                      pAttrName     = VR_N_PID_SCALE_DB );
  }
  else
  {
    FIg_erase ( me->pSKF, HV_SYMB_SCALE );
    FIg_erase ( me->pSKF, HV_SYMB_SCALE_LABEL );
  }

  VR$DispCollAttr ( pForm       = me->pSKF,
                    pCollId     = &me->SysParamId,
                    Gadget      = RW_WIDTH,
                    pAttrName   = VR_N_WIDTH1_DB);

  VR$DispCollAttr ( pForm       = me->pSKF,
                    pCollId     = &me->SysParamId,
                    Gadget      = RW_DEPTH,
                    pAttrName   = VR_N_DEPTH1_DB);

  VR$DispCollAttr ( pForm       = me->pSKF,
                    pCollId     = &me->SysParamId,
                    Gadget      = SMALL_RW_WIDTH,
                    pAttrName   = VR_N_WIDTH2_DB);

  VR$DispCollAttr ( pForm       = me->pSKF,
                    pCollId     = &me->SysParamId,
                    Gadget      = SMALL_RW_DEPTH,
                    pAttrName   = VR_N_DEPTH2_DB);

  /* Below added for CR179701945 - Throat radius field */
  VR$DispCollAttr ( pForm       = me->pSKF,
                    pCollId     = &me->SysParamId,
                    Gadget      = HV_THROAT_RADIUS,
                    pAttrName   = VR_N_THROAT_DB);

  VR$DispCollAttr ( pForm       = me->pSKF,
                    pCollId     = &me->SysParamId,
                    Gadget      = HV_TRAN_LENGTH,
                    pAttrName   = VR_N_TRANS_L_DB);

  FIg_set_text (me->pSKF, RW_CMP_NB, me->CmpNumber);
  /* CR179801144 - if rectangular tray, display tiers */
   /* Unknown program flow. set defaults for missing parameters */
  /*C Get shape code */
  status =
         om$send( msg      = message ACncpx.ACgive_structure
                                                   ( &retstatus,
                                                     &FootIndex,
                                                     VR_N_SHAPE_IN,
                                                     &ParamAttr,
                                                     &me->ModuleInfo),
         targetid = me->SysParamId.objid,
         targetos = me->SysParamId.osnum );

  shape_code = (IGRint) ParamAttr.var.root_pm_st.value;
  if(shape_code == VR_RECT)
  {
    /* set default values */
    VR$DispCollAttr ( pForm       = me->pSKF,
                    pCollId     = &me->SysParamId,
                    Gadget      = SP_TIER_SK1,
                    pAttrName   = VR_N_DEPTH1_DB);

    VR$DispCollAttr ( pForm       = me->pSKF,
                    pCollId     = &me->SysParamId,
                    Gadget      = SP_TIER_SK2,
                    pAttrName   = VR_N_DEPTH2_DB);

    FIg_set_value( me->pSKF , N_TIER_SK1,  1 );
    FIg_set_value( me->pSKF , N_TIER_SK1,  2 );
    /* Try to set collection values */
    VR$DispCollAttr ( pForm       = me->pSKF,
                    pCollId     = &me->SysParamId,
                    Gadget      = SP_TIER_SK1,
                    pAttrName   = VR_N_TIERSP1_DB);

    VR$DispCollAttr ( pForm       = me->pSKF,
                    pCollId     = &me->SysParamId,
                    Gadget      = SP_TIER_SK2,
                    pAttrName   = VR_N_TIERSP2_DB);

    VR$DispCollAttr ( pForm       = me->pSKF,
                    pCollId     = &me->SysParamId,
                    Gadget      = N_TIER_SK1,
                    pAttrName   = VR_N_NUMTIER1_IN);

    VR$DispCollAttr ( pForm       = me->pSKF,
                    pCollId     = &me->SysParamId,
                    Gadget      = N_TIER_SK2,
                    pAttrName   = VR_N_NUMTIER2_IN);

  }
  else /* Added for CR179801144 */
  {
    FIg_erase ( me->pSKF, N_TIER_SK1 );
    FIg_erase ( me->pSKF, N_TIER_SK2 );
    FIg_erase ( me->pSKF, SP_TIER_SK1 );
    FIg_erase ( me->pSKF, SP_TIER_SK2 );
  }
  return (OM_S_SUCCESS);
}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method form_notification ( int      form_label ;
                           int      gadget_label ;
                           double   value ;
                           char   * form_ptr )
{
  IGRint       status;
  IGRlong      retmsg;
  IGRdouble    d_value, w_value;
/* tier processing added for CR179801144 */
  IGRint       shape_code;
  IGRdouble       no_tier;
  IGRdouble    tier_sp;
  struct GRid             my_grid;
  struct ret_struct       ParamAttr;
  IGRint                  FootIndex = -1, retstatus;

  struct  ACrg_coll  Collection;

  if (form_label != VRSKF_FLAB)
  {
    return (

       om$send (msg = message VRCORway.form_notification
                               (form_label, gadget_label, value, form_ptr),
               mode = OM_e_wrt_message,
           targetid = my_id));
  }

  /*   let the form take care of itself, ONLY at reset or execute
       do the required actions     */

  /* CR179801144 */
  my_grid.objid = my_id;
  my_grid.osnum = OM_Gw_current_OS;

  switch (gadget_label)
  {
    case FI_RESET:
      status =
      om$send (msg = message VRCmpMgr.VRSKF_fill (&retmsg),
          targetid = my_id);
      break;

    /* tier processing for CR179801144 */
    case N_TIER_SK1:
    case SP_TIER_SK1:
    case N_TIER_SK2:
    case SP_TIER_SK2:
      FIg_get_value( me->pSKF , N_TIER_SK1, &no_tier);
      FIg_get_value( me->pSKF , SP_TIER_SK1, &tier_sp);

      status = VRcomp_rw_tier_depth( NULL, my_grid,
                                 no_tier, tier_sp, &d_value );

      FIg_set_value( me->pSKF , RW_DEPTH,  d_value);
      if((gadget_label == N_TIER_SK2) || (gadget_label == SP_TIER_SK2))
      {
        FIg_get_value( me->pSKF , N_TIER_SK2, &no_tier);
        FIg_get_value( me->pSKF , SP_TIER_SK2, &tier_sp);

        status = VRcomp_rw_tier_depth( NULL, my_grid,
                                 no_tier, tier_sp, &d_value );

        FIg_set_value( me->pSKF , SMALL_RW_DEPTH,  d_value);
      }
    case RW_DEPTH:
    case SMALL_RW_DEPTH:
    case RW_WIDTH:
    case SMALL_RW_WIDTH:
      FIg_get_value( me->pSKF , RW_WIDTH, &d_value);
      FIg_get_value( me->pSKF , SMALL_RW_WIDTH, &w_value);

      if( w_value > d_value )
      {
        FIg_set_value( me->pSKF , SMALL_RW_WIDTH,  d_value);

        UI_status ("Second size cannot be greater than first");
      }
      break;

    case FI_EXECUTE:

      FIbtn_set_auto_pop_up_on( form_ptr, gadget_label );

      FIg_get_value (me->pSKF, RW_WIDTH, &Collection.desc.value.att_exp);
      strcpy ( Collection.name, VR_N_WIDTH1_DB );
      Collection.desc.type = AC_ATTRIB_DOUBLE;
      status = VRUpdateParameterBox( &retmsg, &Collection, &me->SysParamId);

      FIg_get_value (me->pSKF, RW_DEPTH, &Collection.desc.value.att_exp);
      strcpy ( Collection.name, VR_N_DEPTH1_DB );
      Collection.desc.type = AC_ATTRIB_DOUBLE;
      status = VRUpdateParameterBox( &retmsg, &Collection, &me->SysParamId);

      FIg_get_value (me->pSKF, SMALL_RW_WIDTH, &Collection.desc.value.att_exp);
      strcpy ( Collection.name, VR_N_WIDTH2_DB );
      Collection.desc.type = AC_ATTRIB_DOUBLE;
      status = VRUpdateParameterBox( &retmsg, &Collection, &me->SysParamId);

      FIg_get_value (me->pSKF, SMALL_RW_DEPTH, &Collection.desc.value.att_exp);
      strcpy ( Collection.name, VR_N_DEPTH2_DB );
      Collection.desc.type = AC_ATTRIB_DOUBLE;
      status = VRUpdateParameterBox( &retmsg, &Collection, &me->SysParamId);

      FIg_get_text (me->pSKF, RW_CMP_NB, me->CmpNumber);
      /* CR179801144-add Tier processing */
      status =
         om$send( msg      = message ACncpx.ACgive_structure
                                                   ( &retstatus,
                                                     &FootIndex,
                                                     VR_N_SHAPE_IN,
                                                     &ParamAttr,
                                                     &me->ModuleInfo),
         targetid = me->SysParamId.objid,
         targetos = me->SysParamId.osnum );

      shape_code = (IGRint) ParamAttr.var.root_pm_st.value;

      if(shape_code == VR_RECT)
      {
        FIg_get_value (me->pSKF, SP_TIER_SK1, &Collection.desc.value.att_exp);
        strcpy ( Collection.name, VR_N_TIERSP1_DB );
        Collection.desc.type = AC_ATTRIB_DOUBLE;
        status = VRUpdateParameterBox( &retmsg, &Collection, &me->SysParamId);
        FIg_get_value (me->pSKF, SP_TIER_SK2, &Collection.desc.value.att_exp);
        strcpy ( Collection.name, VR_N_TIERSP1_DB );
        Collection.desc.type = AC_ATTRIB_DOUBLE;
        status = VRUpdateParameterBox( &retmsg, &Collection, &me->SysParamId);
        FIg_get_value (me->pSKF, N_TIER_SK1, &Collection.desc.value.att_exp);
        strcpy ( Collection.name, VR_N_NUMTIER1_IN );
        Collection.desc.type = AC_ATTRIB_DOUBLE;
        status = VRUpdateParameterBox( &retmsg, &Collection, &me->SysParamId);
        FIg_get_value (me->pSKF, N_TIER_SK2, &Collection.desc.value.att_exp);
        strcpy ( Collection.name, VR_N_NUMTIER2_IN );
        Collection.desc.type = AC_ATTRIB_DOUBLE;
        status = VRUpdateParameterBox( &retmsg, &Collection, &me->SysParamId);
      }
      else
      {
        IGRdouble dvalue;
        dvalue = 1.;
        FIg_get_value (me->pSKF, RW_DEPTH, &Collection.desc.value.att_exp);
        strcpy ( Collection.name, VR_N_TIERSP1_DB );
        Collection.desc.type = AC_ATTRIB_DOUBLE;
        status = VRUpdateParameterBox( &retmsg, &Collection, &me->SysParamId);
        FIg_get_value (me->pSKF, SMALL_RW_DEPTH, &Collection.desc.value.att_exp);
        strcpy ( Collection.name, VR_N_TIERSP2_DB );
        Collection.desc.type = AC_ATTRIB_DOUBLE;
        status = VRUpdateParameterBox( &retmsg, &Collection, &me->SysParamId);
        Collection.desc.value.att_exp = 1.;
        strcpy ( Collection.name, VR_N_NUMTIER1_IN );
        Collection.desc.type = AC_ATTRIB_DOUBLE;
        status = VRUpdateParameterBox( &retmsg, &Collection, &me->SysParamId);
        Collection.desc.value.att_exp = 1.;
        strcpy ( Collection.name, VR_N_NUMTIER2_IN );
        Collection.desc.type = AC_ATTRIB_DOUBLE;
        status = VRUpdateParameterBox( &retmsg, &Collection, &me->SysParamId);

      }

      FIf_erase (me->pSKF);
      _put_response( resp = EX_FORM_FINISHED );
      break;

    default:
      break;
  }

  quit:
  return (OM_S_SUCCESS);
}/* end form_notification */

end implementation VRRInsert;

