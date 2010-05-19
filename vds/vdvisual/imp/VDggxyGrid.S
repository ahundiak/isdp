/* $Id: VDggxyGrid.S,v 1.1.1.1 2001/01/04 21:09:32 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdvisual/imp / VDggxyGrid.S
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDggxyGrid.S,v $
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

class specification VDggxyGrid (0:0) of NDnodein, IGEgragad ;

#include "dpstruct.h"

/*
	Abstract class for gragad of a window grid which display a plane set
	on an axis.
*/

override NDcompute_node,
	 DPview_vol,
	 DPscroll,
	 DPcenter,
	 DPwnarea,
	 DPzoom,
	 DPfit,
	 DPset,
	 DProtate,
	 DPcvt_persp,
	 DPset_persp,
	 DPlevels,
	 dynamics,
	 delete,
	 DPshading_allowed ;

message get_axis_displayed( long	*msg ;
			    int 	*axis ) ;

message change_axis_to_display( long	*msg ;
				int	new_axis ) ;

message set_gragad_struct( struct DPgra_gad	*gragad_struct ) ;

end specification VDggxyGrid ;
