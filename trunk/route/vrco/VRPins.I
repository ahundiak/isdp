
/* $Id: VRPins.I,v 1.1.1.1 2001/01/04 21:12:43 cvs Exp $  */

/***********************************************************************
 * I/ROUTE
 *
 * File:        vrco/VRPins.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Log History:
 *	$Log: VRPins.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:12:43  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.1  1997/02/24  21:57:36  pinnacle
# Created: vrco/VRPins.I by hverstee for route
#
 *
 * History:
 *
 ***********************************************************************/

class implementation VRPInsert;

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
  om$send (msg = message VRCOPiping.VRInitInstance (sts),
      targetid = my_id,
          mode = OM_e_wrt_message);

  me->bSKF_up = TRUE;

  status = GRstatus_display_button(1);

  return (OM_S_SUCCESS);
}

method VRSKF_fill  (IGRlong *sts )
{
  IGRint    status;
  IGRlong   retmsg;
  IGRchar   o_lname[16], p_error[30];

  o_lname[0] = '\0';

  FIg_erase  ( me->pSKF, AUTOMATIQUE_GRP );
  FIg_display( me->pSKF, MANUAL_GRP );

  VR$DispCollAttr ( pForm       = me->pSKF,
                    pCollId     = &me->SysParamId,
                    Gadget      = PP_DIAM,
                    pAttrName   = VR_N_GDIAMETER_DB);

  VR$DispCollAttr ( pForm       = me->pSKF,
                    pCollId     = &me->SysParamId,
                    Gadget      = SMALL_DIAMETER,
                    pAttrName   = VR_N_RDIAMETER_DB);

  if (bVR_IS_PID_ACTIVE)
  {
    FIg_display( me->pSKF, SK_PID_SCALE );
    FIg_display( me->pSKF, SK_PID_SCALE_LABEL );

    VR$DispCollAttr ( pForm         = me->pSKF,
                      pCollId       = &me->SysParamId,
                      Gadget        = SK_PID_SCALE,
                      pAttrName     = VR_N_PID_SCALE_DB );
  }
  else
  {
    FIg_erase ( me->pSKF, SK_PID_SCALE );
    FIg_erase ( me->pSKF, SK_PID_SCALE_LABEL );
  }

  status = vd$get_alias (    p_msg      = &retmsg,
                         product        = PIPING,
                         type           = VR_OPTCODE_LIST_NUM,
                         i_code         = me->CmpOption,
                         o_lname        = o_lname,
                         p_error        = p_error       );
  if ( !strlen(o_lname) )
     sprintf(o_lname, "%d", me->CmpOption );

  FIg_set_text (me->pSKF, OPTION, o_lname);

  FIg_set_text (me->pSKF, PP_CMP_NB, me->CmpNumber);

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

       om$send (msg = message VRCOPiping.form_notification
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

    case PP_DIAM:
    case SMALL_DIAMETER:
      FIg_get_value( me->pSKF , PP_DIAM, &d_value);

      FIg_get_value( me->pSKF , SMALL_DIAMETER, &w_value);

      if( w_value > d_value )
      {
        FIg_set_value( me->pSKF , SMALL_DIAMETER,  d_value);

        UI_status ("Second diameter should be greater than red !" );
      }
      break;

    case FI_EXECUTE:

      FIbtn_set_auto_pop_up_on( form_ptr, gadget_label );

      if (bVR_IS_PID_ACTIVE)
      {
        FIg_get_value (me->pSKF, SK_PID_SCALE, &Collection.desc.value.att_exp);
        strcpy( Collection.name, VR_N_PID_SCALE_DB );
        Collection.desc.type = AC_ATTRIB_DOUBLE;
        status = VRUpdateParameterBox( &retmsg, &Collection, &me->SysParamId);
      }

      FIg_get_value (me->pSKF, PP_DIAM, &Collection.desc.value.att_exp);
      strcpy ( Collection.name, VR_N_GDIAMETER_DB );
      Collection.desc.type = AC_ATTRIB_DOUBLE;
      status = VRUpdateParameterBox( &retmsg, &Collection, &me->SysParamId);

      FIg_get_value (me->pSKF, SMALL_DIAMETER, &Collection.desc.value.att_exp);
      strcpy ( Collection.name, VR_N_RDIAMETER_DB );
      Collection.desc.type = AC_ATTRIB_DOUBLE;
      status = VRUpdateParameterBox( &retmsg, &Collection, &me->SysParamId);

      FIg_get_text (me->pSKF, PP_CMP_NB, me->CmpNumber);

      {
        IGRint        o_code;
        IGRchar       i_lname[30], p_error[30];

        FIg_get_text ( me->pSKF, OPTION,i_lname);
        status = vd$get_alias (    p_msg      = &retmsg,
                               product        = PIPING,
                               type           = VR_OPTCODE_LIST_NUM,
                               i_lname        = i_lname,
                               o_code         = &o_code,
                               p_error        = p_error       );
        if ( status != OM_S_SUCCESS )
          me->CmpOption = (IGRshort)atoi(i_lname);
        else
          me->CmpOption = (IGRshort) o_code;
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

end implementation VRPInsert;

