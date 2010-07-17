
/* $Id: VCCmdCON.t,v 1.1.1.1 2001/01/04 21:12:30 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/ROUTE
 *
 * File:        vccmdconn/VCCmdCON.t
 *
 * Description:
 *
 *  State table for Connect fibers/leads command
 *
 * Dependencies:
 *
 * Revision History:
 *     $Log: VCCmdCON.t,v $
 *     Revision 1.1.1.1  2001/01/04 21:12:30  cvs
 *     Initial import to CVS
 *
# Revision 1.2  1999/02/18  18:01:16  pinnacle
# Replaced: vccmdconn/VCCmdCON.t for: CR 179701619 by aharihar for route
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.2  1997/11/03  16:44:50  pinnacle
# Replaced: vccmdconn/VCCmdCON.t for:  by impd for route
#
# Revision 1.1  1997/10/30  04:16:58  pinnacle
# Integration of Cable into 02.04.03.04
#
# Revision 1.6  1997/03/19  18:27:18  pinnacle
# Replaced: vccmdconn/VCCmdCON.t for:  by hverstee for cabling
#
# Revision 1.5  1997/01/24  18:02:40  pinnacle
# Replaced: vccmdconn/VCCmdCON.t for:  by hverstee for cabling
#
# Revision 1.4  1997/01/24  16:25:34  pinnacle
# Replaced: vccmdconn/VCCmdCON.t for:  by hverstee for cabling
#
# Revision 1.3  1996/10/07  20:35:42  pinnacle
# Replaced: vccmdconn/VCCmdCON.t for:  by hverstee for cabling
#
# Revision 1.2  1996/08/29  22:47:52  pinnacle
# Replaced: vccmdconn/VCCmdCON.t for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  22:34:12  pinnacle
# Created: vccmdconn/VCCmdCON.t by hverstee for cabling
#
 *
 * History:
 *      MM/DD/YY        AUTHOR        DESCRIPTION
 *
 *      08/21/96          HV            New
 *
 *    18 Feb 1999	Anand		S C C command takes cognisance of
 *    					jumpers. A new form, a new gadget.
 *
 * -------------------------------------------------------------------*/

/*
 *     Command object code to Connect individual fibers to Equipment
 *     connections
 */

class                   VCCmdCON
product_name           "$ROUTE"
command_table          "cable.cmd"
options                "isTC"
start_state             start
command_string          VCC_M_ConnCab,0,VCCnAll


form     VC_CONN_FNAM     , VC_CONN_FORM     , VC_FORMTYPE_USER,"-1","-1"

		/* Added by Anand for CR 179701619 */
form     VC_CONN_JUMP_FNAM, VC_CONN_JUMP_FORM, VC_FORMTYPE_USER,"-1","-1"
		/* Added by Anand for CR 179701619 */



/*=======================================================================*/

state_table
#include        "VCmsg.h"        /* message keys        */
#include        "FI.h"
#include        "VCCmdDef.h"
#include        "VCCmdCON.h"

/*=======================================================================*/
state        start

  message_key       VC_M_ConnCab
  prompt_key        VC_P_SelTerm
  locate_eligible  "+VCTerm"
  dynamics          off
  locate_owner     "VC_LOCATE_ALL" 
  filter            locate

  on EX_DATA or EX_OBJID
        do VCCONRefInfo (&me->ret)
            on ERROR
            state .
        state SetupForm

/*=======================================================================*/
state        SetupForm

  on ELSE
        do VCCONFillForm()
             on ERROR
             state Cleanup
        state ProcForm        
        
/*=======================================================================*/
state ProcForm

  display_form  VC_CONN_FORM
  prompt_key    VC_P_UpdConn
  dynamics      off
  filter        get_event

  on EX_BACK_UP 
        state -

  on EX_FORM_FINISHED
        do VCCONRetCode()

             on RETURN_CODE = FI_CANCEL
             state Cleanup

             on RETURN_CODE = FI_RESET
             state SetupForm

             on RETURN_CODE = FI_ACCEPT
             do VCCONCables (&me->ret)
             state Cleanup

             on RETURN_CODE = FI_EXECUTE
             do VCCONCables (&me->ret)
             state .

		    /* Added by Anand for CR 179701619 */
             on RETURN_CODE = VC_CONGDG_VIEWJUMP
	     state ViewJumper
		    /* Added by Anand for CR 179701619 */


        state .

/*=======================================================================*/
state Cleanup

  on ELSE
             do VCCONCleanup()
             state terminate

 /*========== State ViewJumper added by Anand for CR 179701619 ============*/

state ViewJumper

  display_form  VC_CONN_JUMP_FORM
  prompt        "View details of Jumper(s) connected to terminal"
  dynamics      off
  filter        get_event

  on EX_FORM_FINISHED
    state ProcForm


/*=======================================================================*/


