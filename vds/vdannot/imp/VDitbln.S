/* $Id: VDitbln.S,v 1.1.1.1 2001/01/04 21:07:41 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdannot/imp / VDitbln.S
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDitbln.S,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:41  cvs
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

/*\
ABSTRACT : 

CHANGE HISTORY :
	Hans Frosch    04/08/92 : first implementation
\*/

class specification VDitbln(0:1) of DMtxbln;

instance VDitbln
{
    IGRint		item_nr;		/* Item number		 */
};


 override GRdelete;
 override GRgetobjinfo, NDmove_to_root;
 override gather_data;
 override replace_text;
 override GRxform;

/*\
MOTIVATION

    Specific behaviour for

	GRgetobjinfo	: UI_status when locate
	NDmove_to_root	: - delete itself if no ACcpx remains connected on the
			    parent channel
			  - disconnect from deleted parent if some others remain
			    connected.

	ANadd_text_to_buff : ONLY DIFFERENCE with respect to DMtxbln is a test
			     on character_input (forced to be numeric :isdigit() ).

	txdynamics	: setting GLOBAL VARIABLE : current_item_number;
\*/

message VDget_item_number(int *item_number);

message VDset_item_number(int item_number);

end specification VDitbln;
