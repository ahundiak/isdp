/* $Id: VDintf.t,v 1.1.1.1 2001/01/04 21:08:52 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdintf/cmd / VDintf.t
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDintf.t,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:52  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/08/04  17:00:22  pinnacle
# Created: vdintf/cmd/VDintf.t by jwfrosch for vds
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	08/16/94	HF		Partial rewrite to COB (except for execute method)
 *					Added Options Form functionality
 *
 * -------------------------------------------------------------------*/

/*
 * Command object for: VDS Interference Analysis
 */

class			VDintf
super_class		"VDS_LOCATE"

command_string		VDC_M_IntfAna,0,VDIntfAnl
product_name		"$VDS"
command_table		"vds.cmd"
status_display		"VDintfOpt","-1","-1"
options			"isTC"

start_state		start

state start

    status_key		EMS_I_InvkStatusFrm
    filter		get_event
    on EX_STRING	state terminate
    on EX_FORM_FINISHED	state terminate
    on TERMINATE	state terminate

at init do VDintf_init( &me->ret )
