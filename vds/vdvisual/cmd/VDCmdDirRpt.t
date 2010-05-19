/* $Id: VDCmdDirRpt.t,v 1.1.1.1 2001/01/04 21:09:32 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdvisual/cmd / VDCmdDirRpt.t
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDCmdDirRpt.t,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:32  cvs
 *	Initial import to CVS
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
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

/*
 *
 *      Filename:       VDrepdir.t
 *      Author:         Radhai Manem
 *
 *      Date:           June 1994
 *      Type:           Slic File
 *      Process by:     slic -isCT VDCmdDirRpt.t
 *
 *      Description:
 *        
 *        This is the command table for the Report Directory Command.
 *
 *
 *      History:
 *      June   1994    Creation date.
 *
 */


command_string  VDC_M_RpDr,0,VDRpDr
class           VDCmdDirFrm
start_state     start
product_name    "$VDS"
command_table   "vds.cmd"
options         "isTC"

state_table

#include "DIdef.h"
#include "VDmsg.h"

#define DEF_FILE    "report_file"

state start
   message_key   VD_M_RpDr
   prompt_key    VD_P_EnFlRtDf
   execute       display_default
   filter        get_event 
   on TEXT_VALUE
        do report_dir                              state terminate

   on EX_BACK_UP                                        state -
