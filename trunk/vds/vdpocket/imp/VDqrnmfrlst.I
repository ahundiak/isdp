/* $Id: VDqrnmfrlst.I,v 1.1.1.1 2001/01/04 21:09:01 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdpocket/imp / VDqrnmfrlst.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDqrnmfrlst.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:01  cvs
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
Name
	VDqrnmfrlst.I

Description

	This file contains support functions for the query object.

Notes

abstract

history

   16/08/94 : ADZ - First inplementation.
*/


class implementation VDquery ; 

#include	"vdqrydef.h"


int	VDqryNameFromAttrList( iname, oname )
IGRchar			*iname;
IGRchar			*oname;
{
	if( ! iname ){
		/*
		 * nothing to check ..
		 */
		return FALSE ;
	}

	/*
	 * test on attribute name "select"
	 */

        if( strncmp( iname, VD_qry_nmSelect, VD_qry_szSelect ) == 0 ){

		strcpy( oname,	VD_qry_nmSelect );
		return TRUE;
	}

	/*
	 * test on attribute name "where"
	 */

        if( strncmp( iname, VD_qry_nmWhere, VD_qry_szWhere ) == 0 ){

		strcpy( oname,	VD_qry_nmWhere );
		return TRUE;
	}

	/*
	 * test on attribute name "comment"
	 */

        if( strncmp( iname, VD_qry_nmComment, VD_qry_szComment ) == 0 ){

		strcpy( oname,	VD_qry_nmComment );
		return TRUE;
	}

	return FALSE;
}

end implementation VDquery;
