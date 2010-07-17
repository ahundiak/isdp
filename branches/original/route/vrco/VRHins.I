
/* $Id: VRHins.I,v 1.1.1.1 2001/01/04 21:12:42 cvs Exp $  */

/***********************************************************************
 * I/ROUTE
 *
 * File:        vrco/VRHins.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Log History:
 *	$Log: VRHins.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:12:42  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.2  1997/02/27  18:28:54  pinnacle
# Replaced: vrco/VRHins.I for:  by hverstee for route
#
# Revision 1.1  1997/02/24  21:57:00  pinnacle
# Created: vrco/VRHins.I by hverstee for route
#
 *
 * History:
 *
 ***********************************************************************/

class implementation VRHInsert;

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
  om$send (msg = message VRCOHvac.VRInitInstance (sts),
      targetid = my_id,
          mode = OM_e_wrt_message);

  me->bSKF_up = TRUE;

  status = GRstatus_display_button(1);

  return (OM_S_SUCCESS);
}

method VRSKF_fill  (IGRlong *sts )
{
  IGRint      status;

  status = OM_S_SUCCESS;
  *sts   = MSSUCC;

  FIg_erase  ( me->pSKF, AUTOMATIQUE_GRP );
  FIg_display( me->pSKF, MANUAL_GRP );

/*    Erase line number fields   */
  FIg_erase ( me->pSKF, 49 );
  FIg_erase ( me->pSKF, 226 );

/*    Erase shape fields         */
  FIg_erase ( me->pSKF, 22);
  FIg_erase ( me->pSKF, HV_TEXT_SHAPE2);

  FIg_erase ( me->pSKF, HV_C_SHAPE);
  FIg_erase ( me->pSKF, HV_R_SHAPE);
  FIg_erase ( me->pSKF, HV_O_SHAPE);
  FIg_erase ( me->pSKF, HV_RS_SHAPE);
  FIg_erase ( me->pSKF, HV_C_SHAPE2);
  FIg_erase ( me->pSKF, HV_R_SHAPE2);
  FIg_erase ( me->pSKF, HV_O_SHAPE2);
  FIg_erase ( me->pSKF, HV_RS_SHAPE2);

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
                    Gadget      = HV_WIDTH,
                    pAttrName   = VR_N_WIDTH1_DB);

  VR$DispCollAttr ( pForm       = me->pSKF,
                    pCollId     = &me->SysParamId,
                    Gadget      = HV_DEPTH,
                    pAttrName   = VR_N_DEPTH1_DB);

  VR$DispCollAttr ( pForm       = me->pSKF,
                    pCollId     = &me->SysParamId,
                    Gadget      = SMALL_HV_WIDTH,
                    pAttrName   = VR_N_WIDTH2_DB);

  VR$DispCollAttr ( pForm       = me->pSKF,
                    pCollId     = &me->SysParamId,
                    Gadget      = SMALL_HV_DEPTH,
                    pAttrName   = VR_N_DEPTH2_DB);

  VR$DispCollAttr ( pForm       = me->pSKF,
                    pCollId     = &me->SysParamId,
                    Gadget      = HV_THROAT_RADIUS,
                    pAttrName   = VR_N_THROAT_DB);

  VR$DispCollAttr ( pForm       = me->pSKF,
                    pCollId     = &me->SysParamId,
                    Gadget      = HV_TRAN_LENGTH,
                    pAttrName   = VR_N_TRANS_L_DB);


  FIg_set_text (me->pSKF, HV_CMP_NB, me->CmpNumber);

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

  struct  ACrg_coll  Collection;

  if (form_label != VRSKF_FLAB)
  {
    return (

       om$send (msg = message VRCOHvac.form_notification
                               (form_label, gadget_label, value, form_ptr),
               mode = OM_e_wrt_message,
           targetid = my_id));
  }

  /*   let the form take care of itself, ONLY at reset or execute
       do the required actions     */

  switch (gadget_label)
  {
    case FI_RESET:
      status =
      om$send (msg = message VRCmpMgr.VRSKF_fill (&retmsg),
          targetid = my_id);
      break;

    case HV_WIDTH:
    case HV_DEPTH:
    case SMALL_HV_DEPTH:
    case SMALL_HV_WIDTH:
      FIg_get_value( me->pSKF , HV_WIDTH, &d_value);
      FIg_get_value( me->pSKF , SMALL_HV_WIDTH, &w_value);

      if( w_value > d_value )
      {
        FIg_set_value( me->pSKF , SMALL_HV_WIDTH,  d_value);

        UI_status ("Second size cannot be greater than first");
      }
      break;

    case FI_EXECUTE:

      FIbtn_set_auto_pop_up_on( form_ptr, gadget_label );

      if (bVR_IS_PID_ACTIVE)
      {
        FIg_get_value (me->pSKF, HV_SYMB_SCALE, &Collection.desc.value.att_exp);
        strcpy( Collection.name, VR_N_PID_SCALE_DB );
        Collection.desc.type = AC_ATTRIB_DOUBLE;
        status = VRUpdateParameterBox( &retmsg, &Collection, &me->SysParamId);
      }

      FIg_get_value (me->pSKF, HV_WIDTH, &Collection.desc.value.att_exp);
      strcpy ( Collection.name, VR_N_WIDTH1_DB );
      Collection.desc.type = AC_ATTRIB_DOUBLE;
      status = VRUpdateParameterBox( &retmsg, &Collection, &me->SysParamId);

      FIg_get_value (me->pSKF, HV_DEPTH, &Collection.desc.value.att_exp);
      strcpy ( Collection.name, VR_N_DEPTH1_DB );
      Collection.desc.type = AC_ATTRIB_DOUBLE;
      status = VRUpdateParameterBox( &retmsg, &Collection, &me->SysParamId);

      FIg_get_value (me->pSKF, SMALL_HV_WIDTH, &Collection.desc.value.att_exp);
      strcpy ( Collection.name, VR_N_WIDTH2_DB );
      Collection.desc.type = AC_ATTRIB_DOUBLE;
      status = VRUpdateParameterBox( &retmsg, &Collection, &me->SysParamId);

      FIg_get_value (me->pSKF, SMALL_HV_DEPTH, &Collection.desc.value.att_exp);
      strcpy ( Collection.name, VR_N_DEPTH2_DB );
      Collection.desc.type = AC_ATTRIB_DOUBLE;
      status = VRUpdateParameterBox( &retmsg, &Collection, &me->SysParamId);

      FIg_get_value (me->pSKF,HV_THROAT_RADIUS, &Collection.desc.value.att_exp);
      strcpy ( Collection.name, VR_N_THROAT_DB );
      Collection.desc.type = AC_ATTRIB_DOUBLE;
      status = VRUpdateParameterBox( &retmsg, &Collection, &me->SysParamId);

      FIg_get_value (me->pSKF,HV_TRAN_LENGTH, &Collection.desc.value.att_exp);
      strcpy ( Collection.name, VR_N_TRANS_L_DB );
      Collection.desc.type = AC_ATTRIB_DOUBLE;
      status = VRUpdateParameterBox( &retmsg, &Collection, &me->SysParamId);

      FIg_get_text (me->pSKF, HV_CMP_NB, me->CmpNumber);

      FIf_erase (me->pSKF);
      _put_response( resp = EX_FORM_FINISHED );
      break;

    default:
      break;
  }

  quit:
  return (OM_S_SUCCESS);
}/* end form_notification */

end implementation VRHInsert;

