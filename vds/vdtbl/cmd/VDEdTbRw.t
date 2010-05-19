/* $Id: VDEdTbRw.t,v 1.1.1.1 2001/01/04 21:09:26 cvs Exp $  */
/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdannot/cmd/VDEdTbRw.t
 *
 * Description:
 *      State table file of Command object for "Edit Table Row"
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDEdTbRw.t,v $
 *      Revision 1.1.1.1  2001/01/04 21:09:26  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.2  1997/05/28  18:18:56  pinnacle
# Replaced: vdtbl/cmd/VDEdTbRw.t for:  by mdong for vds
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.10  1996/05/10  17:41:20  pinnacle
# Replaced: vdtbl/cmd/VDEdTbRw.t for:  by yzhu for vds.240
#
# Revision 1.9  1995/10/12  21:14:20  pinnacle
# Replaced: vdtbl/cmd/VDEdTbRw.t for:  by yzhu for vds.240
#
# Revision 1.8  1995/08/31  18:18:06  pinnacle
# Replaced: vdtbl/cmd/VDEdTbRw.t for:  by yzhu for vds.240
#
# Revision 1.7  1995/08/23  19:35:36  pinnacle
# Replaced: vdtbl/cmd/VDEdTbRw.t for:  by yzhu for vds.240
#
# Revision 1.6  1995/08/09  21:07:30  pinnacle
# Replaced: vdtbl/cmd/VDEdTbRw.t for:  by yzhu for vds.240
#
#
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      06/10/95        Y.Zhu           Creation
 *
 * -------------------------------------------------------------------*/
command_string  VDC_M_VDEdRow,0,VDEdRow
class           VDCmdEdTbRw
super_class     VDS_LOCATE
command_table   "vds.cmd"
product_name    "$VDS"
options         "TCis"

form            "VDeditTblRow", 0, 0, "-1", "-1"
start_state     start

state_table

#include "VDmsg.h"
#include "VDdrwtbl.h"
#include "VDtblCmdDef.h"
#include "VDCmdDef.h"

state start
        /*
         * In this state, set mesage and prompt, ask the user to locate row
         * object.
         */

        message_key             VD_M_VDEdRow
        prompt_key              VD_P_IdTblRow
        locate_owner            "LC_RIGID_COMP | LC_RIGID_OWNER |
                                 LC_FLEX_COMP  | LC_FLEX_OWNER  |
                                 LC_REF_OBJECTS "
        accept                  "Accept (locate next object) / Reject"
	locate_eligible         "VDdrwTblRow"
        filter                  locate


             on EX_RJT_MOVEON
                                                        state start

             on EX_DATA
	        do VDis_table_uptodate
            	   on RETURN_CODE = VD_ERROR 		  state terminate

                do VDlocateRow
                   on RETURN_CODE = VD_ERROR
                      do status "Please locate table row" state .
                   on RETURN_CODE = VD_ETR_LINE_OUT
                      do status "Can not edit line out row" state start
                do VDgetRowInfo
                   on RETURN_CODE = VD_ERROR
                      do status "Can not get row info"    state .
                do display_form            0 
                do VDinitFrm1                
                   on RETURN_CODE = VD_ERROR
                      do status "Can not set form"    
                      do erase_form 0                     state .
                                                          state form_info

             on GR_UNKNOWN_TYPE.VD_ETR_FORM_INFO
                do VDreturnForm( &me->ret )
                    on RETURN_CODE = VD_ETR_FORM_EXECUTE
                                                          state start
                    on RETURN_CODE = VD_ETR_FORM_ACCEPT
                                 do erase_form 0	  state terminate
                                                          state . 

        on EX_FORM_FINISHED
                do erase_form 0                         state terminate

state form_info
        /*
         * In this state, set prompt to "Modify attributes",
         * ask user to change selected row attributes,
         */

        message_key             VD_M_VDEdRow
        prompt                  "Edit attributes in the form"
        dynamics                off   
        filter                  get_event

        on EX_RJT_MOVEON
                                                          state .

        on GR_UNKNOWN_TYPE.VD_ETR_FORM_INFO
                do VDreturnForm( &me->ret )
                    on RETURN_CODE = VD_ETR_FORM_EXECUTE
                        do VDupdateRow         	          state .
                    on RETURN_CODE = VD_ETR_FORM_ACCEPT
                        do VDupdateRow                    
                        do erase_form 0                   state terminate
                    on RETURN_CODE = VD_ETR_FORM_NEXTROW  state .
                    on RETURN_CODE = VD_ETR_FORM_PREVROW  state .  
                    on RETURN_CODE = VD_ETR_SCRL_LIF_BTN  state .  
                    on RETURN_CODE = VD_ETR_SCRL_RIG_BTN  state .  
                                                          state .

        on EX_FORM_FINISHED
                do erase_form 0                         state terminate

at delete       do free_instance
at wakeup       do VDset_form_pos
at sleep        do VDsave_form_pos

