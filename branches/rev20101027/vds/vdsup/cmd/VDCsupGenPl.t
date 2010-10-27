/* $Id: VDCsupGenPl.t,v 1.1.1.1 2001/01/04 21:09:23 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdsup/cmd/VDCsupGenPl.t
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDCsupGenPl.t,v $
 *      Revision 1.1.1.1  2001/01/04 21:09:23  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.4  1997/10/29  15:21:28  pinnacle
# Added Headers
#
 *
 * History:
 *      MM/DD/YY  AUTHOR  DESCRIPTION
 *      10/29/97  ah      added header
 *      07/11/97  EJM     CR#179701494  Support curve enhancements
 *                        Under state locate_traces, changed state
 *                        form_infox to "state ." Allows user to 
 *                        locate more than one trace curve.
 ***************************************************************************/

command_string  VDC_M_supCrvPl, VDSUP_CMD_CRV_PL, VDsupCrvPl
synonym         VDC_M_supOffPl, VDSUP_CMD_OFF_PL, VDsupOffPl
synonym         VDC_M_supEquPl, VDSUP_CMD_EQU_PL, VDsupEquPl
synonym	        VDC_M_supCrvMd, VDSUP_CMD_CRV_MD, VDsupCrvMd
synonym         VDC_M_supOffMd, VDSUP_CMD_OFF_MD, VDsupOffMd
synonym         VDC_M_supEquMd, VDSUP_CMD_EQU_MD, VDsupEquMd

class		VDCsupGenPl
super_class	VDCsupGen
product_name	"$VDS"
command_table	"vds.cmd"
options         "siTC"

start_state	start

/* ----------------------------------------------------------
 * The State Table
 */
state_table

#include "VDmsg.h"
#include "VDCsupForm.h"

/* ----------------------------------------------------------
 * STATE start
 */
state start
  on CMD_TYPE = VDSUP_CMD_CRV_PL
    do message_key VD_M_supCrvPl
    state is_base_surf_defined

  on CMD_TYPE = VDSUP_CMD_OFF_PL
    do message_key VD_M_supOffPl
    state is_base_surf_defined

  on CMD_TYPE = VDSUP_CMD_EQU_PL
    do message_key VD_M_supEquPl
    state is_base_surf_defined

  on CMD_TYPE = VDSUP_CMD_CRV_MD
    do message_key VD_M_supCrvMd
    state locate_support

  on CMD_TYPE = VDSUP_CMD_OFF_MD
    do message_key VD_M_supOffMd
    state locate_support

  on CMD_TYPE = VDSUP_CMD_EQU_MD
    do message_key VD_M_supEquMd
    state locate_support

/* ------------------------------------------------------
 * Save base surface from one command to another
 */
state is_base_surf_defined
  on CMD_TYPE < 3   
    do VDCsupIsBaseSurfDefined (&me->ret)
    on RETURN_CODE = VDSUP_YES  state locate_base_obj1
                                state locate_base_surf

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

/* -------------------------------------------------------
 * Locate Single Hull Surface
 */
state locate_base_surf

  prompt_key		VD_P_supLocBaseSurf
  locate_properties    "LC_LC_ONLY | LC_DP_ONLY | LC_RW"
  locate_owner         "LC_RIGID_COMP | LC_RIGID_OWNER |
                         LC_FLEX_COMP | LC_FLEX_OWNER  | LC_REF_OBJECTS"
  locate_eligible      "+EMSsurface"
  filter		locate

  on EX_DATA or EX_STRING or EX_OBJID
    do VDCsupSetObject(&me->ret,VDSUP_FRM_F_BASE_SURF)
    do get_initFlag
    on RETURN_CODE = 1 state locate_base_obj1
                       state form_infox

  on EX_RJT_MOVEON state form_infox
  on EX_BACK_UP    state -

/* --------------------------------------------------------
 * Locate Single Base Object
 */
state locate_base_obj1

  prompt_key		VD_P_supLocBaseObj1
  locate_properties    "LC_LC_ONLY | LC_DP_ONLY | LC_RW"
  locate_owner         "LC_RIGID_COMP | LC_RIGID_OWNER |
                        LC_FLEX_COMP  | LC_FLEX_OWNER  | LC_REF_OBJECTS"
  locate_eligible      "+GRbspline,+EMSsurface,EMSplane,GRcompcurve"
  filter		locate

  on EX_DATA or EX_STRING or EX_OBJID
    do VDCsupSetObject(&me->ret,VDSUP_FRM_F_BASE_OBJ1)
    state form_infox

  on EX_RJT_MOVEON state form_infox
  on EX_BACK_UP    state -

/* --------------------------------------------------------
 * Locate Second Base Object
 */
state locate_base_obj2

  prompt_key		VD_P_supLocBaseObj2
  locate_properties    "LC_LC_ONLY | LC_DP_ONLY | LC_RW"
  locate_owner         "LC_RIGID_COMP | LC_RIGID_OWNER |
                        LC_FLEX_COMP  | LC_FLEX_OWNER  | LC_REF_OBJECTS"
  locate_eligible      "+GRbspline,+EMSsurface,EMSplane,GRcompcurve"
  filter		locate

  on EX_DATA or EX_STRING or EX_OBJID
    do VDCsupSetObject(&me->ret,VDSUP_FRM_F_BASE_OBJ2)
    state form_infox

  on EX_RJT_MOVEON state form_infox
  on EX_BACK_UP    state -

/* --------------------------------------------------------
 * Locate Direction Point
 */
state locate_dir

  prompt_key		VD_P_supLocDir
  locate_properties    "LC_LC_ONLY | LC_DP_ONLY | LC_RW"
  locate_owner         "LC_RIGID_COMP | LC_RIGID_OWNER |
                        LC_FLEX_COMP  | LC_FLEX_OWNER  | LC_REF_OBJECTS"
  locate_eligible      "+GR3dpoint"
  filter		locate

  on EX_DATA or EX_STRING or EX_OBJID
    do VDCsupSetObject(&me->ret,VDSUP_FRM_F_DIR)
    state form_infox

  on EX_RJT_MOVEON state form_infox
  on EX_BACK_UP    state -


/* --------------------------------------------------------
 * Locate Selection Point
 */
state locate_sel

  prompt_key		VD_P_supLocSel
  locate_properties    "LC_LC_ONLY | LC_DP_ONLY | LC_RW"
  locate_owner         "LC_RIGID_COMP | LC_RIGID_OWNER |
                        LC_FLEX_COMP  | LC_FLEX_OWNER  | LC_REF_OBJECTS"
  locate_eligible      "+GR3dpoint"
  filter		locate

  on EX_DATA or EX_STRING or EX_OBJID
    do VDCsupSetObject(&me->ret,VDSUP_FRM_F_SEL)
    state form_infox

  on EX_RJT_MOVEON state form_infox
  on EX_BACK_UP    state -

/* --------------------------------------------------------
 * Locate Trace Curves
 */
state locate_traces

  prompt_key		VD_P_supLocLimits
  locate_properties    "LC_LC_ONLY | LC_DP_ONLY | LC_RW"
  locate_owner         "LC_RIGID_COMP | LC_RIGID_OWNER |
                        LC_FLEX_COMP  | LC_FLEX_OWNER  | LC_REF_OBJECTS"
  locate_eligible      "+GRbspline,+EMSsurface,EMSplane,GRcompcurve"
  filter		locate

  on EX_DATA or EX_STRING or EX_OBJID
    do VDCsupSetTraces(&me->ret)
    state .

  on EX_RJT_MOVEON state form_infox
  on EX_BACK_UP    state -

/* --------------------------------------------------------
 * Locate Triming Object
 */
state locate_trim1

  prompt_key		VD_P_supLocTrim1
  locate_properties    "LC_LC_ONLY | LC_DP_ONLY | LC_RW"
  locate_owner         "LC_RIGID_COMP | LC_RIGID_OWNER |
                        LC_FLEX_COMP  | LC_FLEX_OWNER  | LC_REF_OBJECTS"
  locate_eligible      "+GRbspline,+EMSsurface,EMSplane,GRcompcurve"
  filter		locate

  on EX_DATA or EX_STRING or EX_OBJID
    do VDCsupSetObject(&me->ret,VDSUP_FRM_F_TRIM1)
    state form_infox

  on EX_RJT_MOVEON state form_infox
  on EX_BACK_UP    state -

/* --------------------------------------------------------
 * Locate Triming Object
 */
state locate_trim2

  prompt_key		VD_P_supLocTrim2
  locate_properties    "LC_LC_ONLY | LC_DP_ONLY | LC_RW"
  locate_owner         "LC_RIGID_COMP | LC_RIGID_OWNER |
                        LC_FLEX_COMP  | LC_FLEX_OWNER  | LC_REF_OBJECTS"
  locate_eligible      "+GRbspline,+EMSsurface,EMSplane,GRcompcurve"
  filter		locate

  on EX_DATA or EX_STRING or EX_OBJID
    do VDCsupSetObject(&me->ret,VDSUP_FRM_F_TRIM2)
    state form_infox

  on EX_RJT_MOVEON state form_infox
  on EX_BACK_UP    state -

/* ----------------------------------------------------------
 * Form Processing
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
  on GR_UNKNOWN_TYPE.VDSUP_FRM_B_BASE_SURF state locate_base_surf
  on GR_UNKNOWN_TYPE.VDSUP_FRM_B_BASE_OBJ1 state locate_base_obj1
  on GR_UNKNOWN_TYPE.VDSUP_FRM_B_BASE_OBJ2 state locate_base_obj2
  on GR_UNKNOWN_TYPE.VDSUP_FRM_B_TRIM1     state locate_trim1
  on GR_UNKNOWN_TYPE.VDSUP_FRM_B_TRIM2     state locate_trim2
  on GR_UNKNOWN_TYPE.VDSUP_FRM_B_TRACE_ADD state locate_traces
  on GR_UNKNOWN_TYPE.VDSUP_FRM_B_DIR       state locate_dir
  on GR_UNKNOWN_TYPE.VDSUP_FRM_B_SEL       state locate_sel
  on GR_UNKNOWN_TYPE.VDSUP_FRM_B_RESET     state start
