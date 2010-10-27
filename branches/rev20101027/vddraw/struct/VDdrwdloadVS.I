/* $Id: VDdrwdloadVS.I,v 1.1.1.1 2001/01/04 21:08:38 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vddraw/struct/VDdrwdloadVS.I
 *
 * Description:
 *		This function will dynamic load a correction file, which
 *		can only be loaded when I/STRUCT is active. 
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDdrwdloadVS.I,v $
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
# Revision 1.4  1995/10/26  19:51:54  pinnacle
# Replaced: vddraw/struct/VDdrwdloadVS.I for:  by sundar for vds.240
#
# Revision 1.3  1995/08/25  15:46:20  pinnacle
# Replaced: vddraw/struct/VDdrwdloadVS.I for:  by azuurhou for vds.240
#
# Revision 1.2  1995/08/21  16:26:56  pinnacle
# Replaced: vddraw/struct/VDdrwdloadVS.I for:  by azuurhou for vds.240
#
# Revision 1.1  1995/08/16  14:50:30  pinnacle
# Created: vddraw/struct/VDdrwdloadVS.I by azuurhou for vds.240
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	08/15/95	adz		creation date.
 *	08/21/95	adz		Invalid product checking.
 *
 * -------------------------------------------------------------------*/

class implementation VDSroot ;

#include <stdio.h>
#include <string.h>
#include "DIdef.h"
#include "v_dbgmacros.h"
#include "vdprdmacros.h"

/*--------------------------------------------------------------------------*/

VDdrw_load_Structure( msg )
IGRlong			*msg ;
{
	long			sts;
	char			dlFile[DI_PATH_MAX];

	/*
	 * Check if I/STRUCT is active. When this is the case.
	 * load a correction file to recognize the global element Types
	 * of I/STRUCT elements.
	 */

	SetProc( VDdrw_load_Structure ); Begin

	*msg = 1;

	sts = vd$prd_get_product_info( logo = VD_PROD_LOGO_STRUCT );
	if( ! sts ){
		return OM_S_SUCCESS ;
	}

	/*
	 * Get I/VDS product path.
	 */
	
	sts =
	vd$prd_get_product_info(run_name  = VD_PROD_NAME_VDS,
			     	conf_path = dlFile    );

	if ( !sts )	return OM_S_SUCCESS ;

	#ifdef ENV5
                strcat( dlFile, "config/dload/prod/vddraw.o" );
        #else
                strcat( dlFile, "config/dload/prod/vddraw.so" );
        #endif

	ems_dload( dlFile );

	End ;
	return OM_S_SUCCESS ;
}

/*----------------------------------------------------------------------------*/

end implementation VDSroot ;
