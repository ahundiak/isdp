/* $Id: VDCmditbln.S,v 1.1.1.1 2001/01/04 21:07:40 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdannot/cmd / VDCmditbln.S
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDCmditbln.S,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:40  cvs
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

class specification VDCmditbln (2:0) of VDCmdAnnot;

#define         GAD_IT_NMBR     21
#define         GAD_IT_QUAN     24
#define         GAD_AUTO_INC    27

override init_type,
	 process_bln_form,
	 LC_selection,
	 place_dimension,
	 display_dimension,
         execute;

end specification VDCmditbln;


