/* $Id: VDDeItmPre.t,v 1.1.1.1 2001/01/04 21:07:40 cvs Exp $  */
/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdannot/cmd/VDDeItmPre.t
 *
 * Description:
 *      State table file of Command object for "Define Item Prefix Definitions"
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDDeItmPre.t,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:40  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.2  1995/07/26  15:46:20  pinnacle
# Replaced: vdannot/cmd/VDDeItmPre.t for:  by yzhu for vds.240
#
# Revision 1.1  1995/07/13  18:25:32  pinnacle
# Created: vdannot/cmd/VDDeItmPre.t by yzhu for vds.240
#
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      07/10/95        Y.Zhu           Creation
 *
 * -------------------------------------------------------------------*/

command_string  VDC_M_DeItmPre,0,VDDeItPrDf
class           VDCmdDeItPr
super_class     VDS_LOCATE
command_table   "vds.cmd"
product_name    "$VDS"
options         "TCis"

form            "VDdefItmPrefix", 0, 0, "-1", "-1"
start_state     start

state_table

#include "VDmsg.h"
#include "VDSannot.h"
#include "VDCmdDef.h"                  /* VD_ERROR  */A

state start
        /*
         * In this state, set mesage and prompt, ask the user to run form
         */

        display_form            0 
/*        message_key             VD_M_DeItmPre    */
        message                 "Define Item Prefix Definition"
        prompt                  "Set Prefix and Query"
        dynamics                off
        filter                  get_event


        on EX_RJT_MOVEON 			          state .

        on GR_UNKNOWN_TYPE.VD_DIPD_FORM_INFO
                do VDItmPreReturnFrm( &me->ret )
                    on RETURN_CODE = VD_DIPD_FORM_EXECUTE
                        do VDsetItmPreDef		  state . 
                    on RETURN_CODE = VD_DIPD_FORM_ACCEPT
                        do VDsetItmPreDef 
                           on RETURN_CODE = VD_SUCCESS    state terminate 
                      					  state . 
                    on RETURN_CODE = VD_DIPD_FORM_CANCEL  state terminate
                                                          state .

        on EX_FORM_FINISHED
                do erase_form 0                           state terminate

at init 	do VDinitPfxFrm( ) 
