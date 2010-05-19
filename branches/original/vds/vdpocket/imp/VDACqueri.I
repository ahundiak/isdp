/* $Id: VDACqueri.I,v 1.1.1.1 2001/01/04 21:09:01 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdpocket/imp / VDACqueri.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDACqueri.I,v $
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
# Revision 1.6  1995/08/30  15:36:42  pinnacle
# Replaced: vdpocket/imp/VDACqueri.I for:  by yzhu for vds.240
#
# Revision 1.5  1995/04/10  14:07:24  pinnacle
# Replace: vdpocket/imp/VDACqueri.I by yzhu for OPE
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

  ABSTRACT :
  --------

    The purpose of the objects of this class is to handle a directory
  mechanism for the objects with a query capability.
*/

class implementation ACncpx;

#define NOT_SHARABLE
#define NOT_COSHARABLE

#include <ctype.h>


#include "coimport.h"
#include "OMminimum.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igewindef.h"
#include "wl.h"
#include "igecolordef.h"
#include "igecolor.h"
#include "igrdef.h"
#include "igr.h"
#include "gr.h"
#include "igrdp.h"
#include "dp.h"
#include "go.h"
#include "lcdef.h"
#include "grio.h"
#include "lc.h"
#include "msdef.h"
#include "VDquery.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "DIomac.h"
#include "igecolmacros.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "exdef.h"
#include "exmacros.h"

#include "vdpardef.h"
#include "vdparmacros.h"
#include "v_dbgmacros.h"
#include "VDmem.h"


/* #define DEBUG	1  */ 

static	OM_S_OBJID	VDquery_dir;
static	OMuword		VDquery_os;
static	struct GRmd_env	VDquery_env;

static	int		VDQYblank;

	int		VDQYstatus;

/******************************************************************************

Function:
    
    VDDIprocess_query

Description:

    This method process the query on the given object. It returns 
    success if the object pass the query.

    note: the status >= 0 means successful.
******************************************************************************/

VDDIprocess_query( query, my_os, my_id, my_env, syntax1 )
IGRchar		*query;		/* (I) the query to be processed   */
OMuword		*my_os;		/* (I) the os of that object	   */
OM_S_OBJID	*my_id;		/* (I) the object to test query on */
struct GRmd_env *my_env;	/* (I) the env of that object      */
IGRint		syntax1;	/* (I) check the syntax only	(1)*/
{
int		status;
extern char *   qy_ptr ;

        SetProc( Function VDDIprocess_query ); Begin

	VDquery_dir = *my_id;
	VDquery_os = *my_os;
	VDquery_env = *my_env;
	VDQYstatus = FALSE;
	VDQYblank = syntax1;

        qy_ptr = query ;
        status = qy_yyparse ( ) ;
        
        End
	return status;
}

/******************************************************************************

Function:
    
    VDquery

Description:

    This function return the status of the test "att oper op2".
    att is got by sending a ACgive_structure to the object with the name
    of the attribute (op1) to test the attribute value or the GRgetsymb
    to test the symbology of the object.

******************************************************************************/


VDquery ( op1, oper, op2 )
IGRchar		*op1, *op2;
IGRint		oper;
{
IGRlong			msg;
IGRint			status = OM_S_SUCCESS,
			operator = VD_cnt_qry_NONE ;
struct	GRobj_env	objEnv;
        SetProc( Function VDquery ); Begin


	objEnv.obj_id.objid	= VDquery_dir ;
	objEnv.obj_id.osnum	= VDquery_os  ;
	objEnv.mod_env		= VDquery_env ;

	if ( VDQYblank )	return NULL;

	status =
	vd$query_on_attr(	msg		= &msg,
				object		= &objEnv,
				operant1	= op1,
				operator	= oper,
				operant2	= op2 );

        End
	return ( status & msg & 1 );
}


end implementation ACncpx;



