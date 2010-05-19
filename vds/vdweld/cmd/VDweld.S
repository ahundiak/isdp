/* $Id: VDweld.S,v 1.1.1.1 2001/01/04 21:09:33 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdweld/cmd/VDweld.S
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDweld.S,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:33  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.3  1997/12/09  16:22:18  pinnacle
# Replaced: vdweld/cmd/*.[IS] for:  by impd for vds
#
# Revision 1.2  1997/11/26  21:36:42  pinnacle
# Replaced: vdweld/cmd/VDweld.S for:  by impd for vds
#
# Revision 1.1  1997/11/21  17:08:04  pinnacle
# Created: vdweld/cmd/VDweld.S by impd for vds
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	11/21/97	  HF		Override at VDS level of some COweld methods :
 *					init, execute, LC_selection, wakeup, delete, notify_form, display_form
 *					Cooperates with file $VDS/config/weld_symbols in order
 *					to make placement of Welding Symbols user customizable
 * -------------------------------------------------------------------*/

class specification VDweld(1:0) of COweld;

override init, execute, LC_selection, wakeup, delete, notify_form, display_form;

end specification VDweld;
