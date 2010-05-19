/* $Id: VDtxldr.S,v 1.1.1.1 2001/01/04 21:07:41 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdannot/imp / VDtxldr.S
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDtxldr.S,v $
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
# Revision 1.2  1995/11/20  15:13:32  pinnacle
# Replaced: vdannot/imp/VDtxldr.S for:  by tlbriggs for vds.240
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
	04/08/92 	Ad Zuurhout     first implementation
 *	11/20/95	tlb		Remove override on get_dim_params
 *
 * -------------------------------------------------------------------*/

class specification VDtxldr(2:0) of DMtxldr;


instance VDtxldr
{
/*  variable IGRchar	format[80];	/* Formatted Text string	*/
/*  variable IGRchar	params[80];	/* Parameters List		*/
};



#include "expression.h"

override DMcompute_node;
override GRgetobjinfo;
override NDmove_to_root;
override gather_data;

/*\
MOTIVATION

    Specific behaviour for

	GRgetobjinfo	: UI_status when locate
	NDmove_to_root	: - delete itself if no ACcpx remains connected on the
			    parent channel
			  - disconnect from deleted parent if some others remain
			    connected.
	gather_data	: - delete the second root AN_ROOT_ELEM2
\*/

end specification VDtxldr;
