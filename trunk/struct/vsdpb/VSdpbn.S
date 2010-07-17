/* $Id: VSdpbn.S,v 1.1.1.1 2001/01/04 21:10:32 cvs Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:	structvsdpb/VSdpbn.S
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VSdpbn.S,v $
 *	Revision 1.1.1.1  2001/01/04 21:10:32  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.1  1997/11/14  13:33:04  pinnacle
# Created: vsdpb/VSdpbn.S by svkadamb for struct
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *			suresh		creation 
 ***************************************************************************/
/*
	I/STRUCT
*/
class specification VSdpbn(0:0) of VSdpb ;

#ifndef OM_D_MACROS
#	include "OMmacros.h"
#endif
#ifndef igetypedef_include
#	include "igetypedef.h"		/* IGE typedefs GR*		*/
#endif
#ifndef igrtypedef_include
#	include "igrtypedef.h"		/* Typedef IGR*			*/
#endif
#ifndef gr_include
#	include "gr.h"			/* Typedef GR*			*/
#endif
#include "vspart.h"
#include "vsweld.h"
#include "vsdpb.h"

override	wake_up,
		sleep ;

end specification VSdpbn ;

