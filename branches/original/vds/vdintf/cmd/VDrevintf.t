/* $Id: VDrevintf.t,v 1.1.1.1 2001/01/04 21:08:52 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdintf/cmd / VDrevintf.t
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDrevintf.t,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:52  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.5  1998/01/26  19:50:42  pinnacle
# Replaced: vdintf/cmd/VDrevintf.t for:  by impd for vds
#
# Revision 1.4  1998/01/26  16:47:42  pinnacle
# Replaced: vdintf/cmd/VDrevintf.t for:  by impd for vds
#
# Revision 1.3  1997/12/31  17:16:58  pinnacle
# Replaced: vdintf/cmd/VDrevintf.t for:  by jwfrosch for vds
#
# Revision 1.2  1997/08/21  13:36:28  pinnacle
# Replaced: vdintf/cmd/VDrevintf*.[ISt] for:  by jwfrosch for vds
#
# Revision 1.1  1997/08/04  17:00:32  pinnacle
# Created: vdintf/cmd/VDrevintf.t by jwfrosch for vds
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	07/16/97	HF		Command to Review <Assoc> VDS Interferences
 *
 * -------------------------------------------------------------------*/

class			VDrevintf
super_class		"VDS_LOCATE"

command_string		VDC_M_IntfRev,0,VDIntfRev
product_name		"$VDS"
command_table		"vds.cmd"
status_display		"VDintfRev","-1","-1"
options			"isTC"

start_state		start

state start

/*
    status_key		EMS_I_InvkStatusFrm
    message_key	  	VD_M_IntfRev
*/
    filter		get_event
/*
    on EX_STRING	state terminate
*/
    on EX_FORM_FINISHED	state terminate

at init do VDintf_init( &me->ret )
