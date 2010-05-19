/* $Id: ACheaderi.I,v 1.1.1.1 2001/01/04 21:07:42 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdassoc/int221 / ACheaderi.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: ACheaderi.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:42  cvs
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
/*  History :
/*	LLC :- 15_9_90	 + creation date
/*
/* */

class implementation ACheader;

#include "OMmacros.h"
#include "OMprimitives.h"

#include "AS_status.h"
#include "nddef.h"
#include "asbox.h"
#include "asmacros.h"

#include "DIdef.h"
#include "DIprims.h"
#include "grownerdef.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "grerr.h"
#include "exmacros.h"

#include "nddef.h"
#include "ndmacros.h"

#define	AS_DEBUG

from	ACcpx_defn	import	ACgive_name;

extern	GRclassid	OPP_ACmodel_mgr_class_id;
extern	GRclassid	OPP_ACheader_class_id;
extern	GRclassid	OPP_ACmodel_class_id;

/* ***************** MSG ACshow_data () *******************************	*/

method ACshow_data ( IGRlong	*msg )

{
IGRint		i;

	/*| initialization */
	*msg = TRUE;

	printf(" hdr origin : X= %f, Y= %f, Z= %f\n", 
				me->origin[0], me->origin[1], me->origin[2] );

	for( i=0; i<3; i++ )
		printf(" matrix row [%d] : %f, %f, %f\n", i, 
						me->matrix[(i*3)],
						me->matrix[(i*3)+1], 
						me->matrix[(i*3)+2] );

	/*| symbologie properties */

return	OM_S_SUCCESS;
}

end implementation ACheader;

