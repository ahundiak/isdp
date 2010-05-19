/* $Id: VDCbro.t,v 1.1.1.1 2001/01/04 21:07:57 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdbro/cmd/VDCbro.t
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDCbro.t,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:57  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/10/29  17:22:00  pinnacle
# ah creation
#
 *
 * History:
 *      MM/DD/YY  AUTHOR  DESCRIPTION
 *      10/29/97  ah      added header
 ***************************************************************************/

command_string  VDC_M_bro, 0, VDbro

class		VDCbro
super_class	VDS_LOCATE
product_name	"$VDS"
command_table	"vds.cmd"
options         "siTC"

start_state	locate_obj

/* ----------------------------------------------------------
 * The State Table
 */
state_table

#include "VDmsg.h"
#include "VDbro.h"
#include "VDCbro.h"

/* -------------------------------------------------------
 * Locate Object
 */
state locate_obj

  message_key           VD_M_bro
  prompt_key		VD_P_broLocObj
  locate_properties    "LC_LC_ONLY | LC_DP_ONLY | LC_RW"
  locate_owner         "LC_RIGID_COMP | LC_RIGID_OWNER |
                         LC_FLEX_COMP | LC_FLEX_OWNER  | LC_REF_OBJECTS"
  locate_eligible      "+GRvg"
  filter		locate

  on EX_DATA or EX_STRING or EX_OBJID
    do VDCbroLocObj(&me->ret)
    on RETURN_CODE = 1 state form_info
                       state locate_obj

  on EX_RJT_MOVEON
    state form_info
 
  on EX_BACK_UP                                         
    state locate_obj

  on 1 state locate_obj


/* ---------------------------------------------------------
 * Form Processing
 */
state form_info

  prompt_key         VD_P_broModForm
  filter             get_event

  on EX_BACK_UP      state locate_obj

  on EX_RJT_MOVEON   state .


  on GR_UNKNOWN_TYPE.VDBRO_FRM_B_CANCEL    state terminate

  on 1 state .
