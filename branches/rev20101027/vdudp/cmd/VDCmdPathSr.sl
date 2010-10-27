/* $Id: VDCmdPathSr.sl,v 1.1.1.1 2001/01/04 21:09:31 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdudp/cmd / VDCmdPathSr.sl
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDCmdPathSr.sl,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:31  cvs
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

command_string       VDC_M_search, 0, VDSsrch
command_table        "vds.cmd"
class                VDCmdPathSr
super_class          VDS_LOCATE
product_name         "$VDS"


specification

instance
{
 char 	search_path[DI_PATH_MAX];
}

implementation

#include "stdio.h"
#include "string.h"
#include "OMmacros.h"
#include "exmacros.h"
#include "DIdef.h"
#include "DItypedef.h"
#include "DIglob.h"
#include "DIprims.h"

#include "vddirmacros.h"
#include "VDSpathdef.h"
#include "VDSudp_mac.h"
#include "VDSudp_priv.h"

#include "VDSudpco.h"

#include "AS_status.h"


#define AS_DEBUG 1
 
/**********************************************************/

state_table

#include "exdef.h"
#include "lcdef.h"
#include "ex.h"
#include "grmessage.h"
#include "AS_status.h"

#include "VDmsg.h"
#include "VDSudpco.h"

state start
	message_key	VD_M_search
	prompt_key	VD_P_ActSrPthNm
	filter		get_event

  on EX_STRING
	do get_search  
	    on RETURN_CODE = "SEVERE_ERROR"			state haveError
	do display_path						state terminate

  on EX_BACK_UP
	do status_key VD_S_ComTerm				state terminate

state haveError
	status_key VD_E_ErrInCmd
	on ELSE							state terminate


/* -------------------------------------------------------- */
action display_path
{
 char 	msg_stat[DI_PATH_MAX+50 ];

 strcpy(msg_stat, "active search path is now: ");
 strcat(msg_stat,me->search_path);

 UI_status(msg_stat);
}
/* -------------------------------------------------------- */
action get_search
{
long	sts;
char 	out[DI_PATH_MAX];

  me->ret = SUCCESS;

 sts = vds$set_act_path(path_name = me->event1.event.keyin, 
                        const_flag = SEARCH_PATH,
			ret_path   = out);
 strcpy(me->search_path, out);

 if(!(sts&1))
   {
    	printf("error vds$set_act_path\n");
	me->ret = SEVERE_ERROR;
	return OM_S_SUCCESS;
   }
  vd$dir_update_form();
return OM_S_SUCCESS;

}

