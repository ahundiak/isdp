/* $Id: VDCmdReport.S,v 1.1.1.1 2001/01/04 21:07:43 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	vdat/report/VDCmdReport
 *
 * Description:
 *		This will be a general reporting class to permit 
 *		users to generate reports form any select set 
 *		and any flexible report layout file.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDCmdReport.S,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:43  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/12/31  13:47:44  pinnacle
# Moved from vdastree
#
# Revision 1.1  1997/11/04  17:41:28  pinnacle
# Created: vdastree/report/VDCmdReport.S by v250_int for vds
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	10/23/97	adz		creation date
 *      12/31/97        ah              moved to vdat
 *
 ***************************************************************************/
class specification VDCmdReport (1:0) of VDS_LOCATE ;

#include "v_cmd.h"

instance VDCmdReport {

	/*
	 * Pointer to input-file-name form.
	 */
	char		*fileForm ;

	VD_fileFormInfo	fileInfo ;
} ;

message createFileForm( long *msg ) ;

message discard_all_input( long *msg ) ;

message process_locate( long *msg ) ;

message fileFormDismissed( int dismissType ) ;

message fileFormOnOffOut( int Switch /* 0=off, 1=on, 2=out */ ) ;

message operation( long * msg ) ;

end specification VDCmdReport ;
