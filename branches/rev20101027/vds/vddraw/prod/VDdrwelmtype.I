/* $Id: VDdrwelmtype.I,v 1.1.1.1 2001/01/04 21:08:38 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	vddraw/prod/VDdrwelmtype.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDdrwelmtype.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:38  cvs
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
# Revision 1.1  1995/08/16  14:52:18  pinnacle
# Created: vddraw/prod/VDdrwelmtype.I by azuurhou for vds.240
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	08/12/95	adz		creation date
 *
 ***************************************************************************/

class implementation VDSroot ;

#include <stdlib.h>
#include <string.h>
#include <math.h>
#define _INGR_EXTENSIONS
#include "v_dbgmacros.h"
#include "VSdrw.h"

extern	long	VS_gI_Beam ;
extern	long	VS_gI_Plate ;
extern	long	VS_gI_Stiffener ;
extern	long	VS_gI_Joint ;
extern	long	VS_gI_InAsbly ;

/*----------------------------------------------------------------------------*/

long	VDdrw_get_ElmType( out )

struct VS_s_drwExecData		*out ; {

	SetProc( VDdrw_get_ElmType ); Begin

	__DBGpr_str(" ElmDesc : ", out->parsedElmDesc );

	if( !strcmp( out->parsedElmDesc, "beam" )){
		out->parsedElmType	= VS_gI_Beam ;
		return TRUE ;
	}

	if( !strcmp( out->parsedElmDesc, "stiffener" )){
		out->parsedElmType	= VS_gI_Stiffener ;
		return TRUE ;
	}

	if( !strcmp( out->parsedElmDesc, "plate" )){
		out->parsedElmType	= VS_gI_Plate ;
		return TRUE ;
	}

	if( !strcmp( out->parsedElmDesc, "joint" )){
		out->parsedElmType	= VS_gI_Joint ;
		return TRUE ;
	}

	out->parsedElmType	= VS_gI_InAsbly ;

	End
	return TRUE ;
	
}


end implementation VDSroot ;

