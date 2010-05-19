/* $Id: VDGetCodList.C,v 1.1.1.1 2001/01/04 21:09:31 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdutil / VDGetCodList.C
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDGetCodList.C,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:31  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.1  1996/07/19  20:33:52  pinnacle
 * Create VDS 241 project
 *
 * Revision 1.1  1994/11/14  22:42:32  pinnacle
 * Create vds.240 from vds.232
 *
 * Revision 1.1  1994/11/08  16:07:00  pinnacle
 * create vds.232
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

#include <stdio.h>
#include "OMerrordef.h"
#include "igrtypedef.h"
#include "PDUerror.h"
#include "VDmacdef.h"
#include "vdbmacros.h"

#define	  MAX_WORD 81   /* 81 because 80 +\0 =81 */

IGRint	VDget_codelist_sname(
IGRlong		*msg,		/* O - return message, 1, if success; 0, if failure */
IGRint		Product,	/* I - product to get list from, see VDmacdef.h */
IGRint		list_num,	/* I - list number for the required list        */
IGRchar		***sname_lst,	/* O - list of short names */
IGRint		*nb_sname	/* O - size of the list    */
)
{

	char	*table=NULL;
	char	search[MAX_WORD];

	*msg = 1;

	if( VDSverify_login() != PDM_S_SUCCESS )
	{
	   UI_status ( "User not logged into the Database");
	   *msg = 0;
	   return(OM_E_ABORT);
	}

	switch ( Product ) {
	case VDS:
		table = "VDS_CODELIST";
		break;
	case PIPING:
		table = "PIPING_CODELIST";
		break;
	case HVAC:
		table = "HVAC_CODELIST";
		break;
	case CABLING:
		table = "RWAY_CODELIST";
		break;
	case STRUCT:
		table = "STRUCT_CODELIST";
		break;
	default :
		return OM_E_INVARG;
	}

	sprintf ( search, "list_num = %d", list_num );
        vdb$RisSelect( select = "short_txt,long_txt",
		       table_name = table,
		       where = search,
		       numselect = 2,
		       p_numrows = nb_sname,
		       p_buffer  = sname_lst );


	return(OM_S_SUCCESS);

}
