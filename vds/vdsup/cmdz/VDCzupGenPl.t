command_string  VDC_M_zupCrvPl, VDSUP_CMD_CRV_PL, VDzupCrvPl
synonym         VDC_M_zupOffPl, VDSUP_CMD_OFF_PL, VDzupOffPl
synonym         VDC_M_zupEquPl, VDSUP_CMD_EQU_PL, VDzupEquPl
synonym	        VDC_M_zupCrvMd, VDSUP_CMD_CRV_MD, VDzupCrvMd
synonym         VDC_M_zupOffMd, VDSUP_CMD_OFF_MD, VDzupOffMd
synonym         VDC_M_zupEquMd, VDSUP_CMD_EQU_MD, VDzupEquMd

class		VDCzupGenPl
super_class	VDCzupGen
product_name	"$VDS"
command_table	"vds.cmd"
options         "siTC"

start_state	start

/* ----------------------------------------------------------
 * The State Table
 */
state_table

#include "VDmsg.h"
#include "VDCzupForm.h"

/* ----------------------------------------------------------
 * STATE start
 */
state start
  on CMD_TYPE = VDSUP_CMD_CRV_PL
    do message_key VD_M_supCrvPl
    state form_infox

  on CMD_TYPE = VDSUP_CMD_OFF_PL
    do message_key VD_M_supOffPl
    state form_infox

  on CMD_TYPE = VDSUP_CMD_EQU_PL
    do message_key VD_M_supEquPl
    state form_infox

  on CMD_TYPE = VDSUP_CMD_CRV_MD
    do message_key VD_M_supCrvMd
    state locate_support

  on CMD_TYPE = VDSUP_CMD_OFF_MD
    do message_key VD_M_supOffMd
    state locate_support

  on CMD_TYPE = VDSUP_CMD_EQU_MD
    do message_key VD_M_supEquMd
    state locate_support


/* -------------------------------------------------------
 * Locate Support Curve
 */
state locate_support

  prompt_key		VD_P_supLocSupport
  locate_properties    "LC_LC_ONLY | LC_DP_ONLY | LC_RW"
  locate_owner         "LC_RIGID_COMP | LC_RIGID_OWNER |
                         LC_FLEX_COMP | LC_FLEX_OWNER  | LC_REF_OBJECTS"
  locate_eligible      "+VDsupGen"
  filter		locate

  on EX_DATA or EX_STRING or EX_OBJID
    do VDCsupSetSupport(&me->ret)
    on RETURN_CODE = 1 state form_infox
                       state locate_support

  on EX_RJT_MOVEON state locate_support
  on EX_BACK_UP    state -


/* --------------------------------------------------------
 * Button Gadget Processing - Locate Object
 */
state locate_object

  prompt_key		VD_P_supLocObj
  locate_properties    "LC_LC_ONLY | LC_DP_ONLY | LC_RW"
  locate_owner         "LC_RIGID_COMP | LC_RIGID_OWNER |
                        LC_FLEX_COMP  | LC_FLEX_OWNER  | LC_REF_OBJECTS"
  locate_eligible      "+GRbspline,EMSsurface,EMSplane,GRcompcurve"
  filter		locate

  on EX_DATA or EX_STRING or EX_OBJID
    do VDCsupSetObject(&me->ret)
    state form_infox

  on EX_RJT_MOVEON state form_infox
  on EX_BACK_UP    state -


/* ----------------------------------------------------------
 * Field Gadget Processing
 * Don't understand 
 */

state form_infox
  on CMD_TYPE < 666   
    do VDCsupSetLocateFlag(&me->ret,0)
    do VDCsupEraseHilite1 (&me->ret)
    state form_info

state form_info

  prompt_key           VD_P_supModForm
  filter               get_event

  on EX_BACK_UP      state start

  on EX_RJT_MOVEON   state .

  on GR_UNKNOWN_TYPE.VDSUP_FRM_B_CANCEL    state terminate
  on GR_UNKNOWN_TYPE.VDSUP_FRM_L_OBJECTS   state locate_object
