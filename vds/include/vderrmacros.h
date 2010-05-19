/* $Id: vderrmacros.h,v 1.1.1.1 2001/01/04 21:07:31 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/include / vderrmacros.h
 *
 * Description:
 *		Error macros for I/VDS.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vderrmacros.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:31  cvs
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
 * Revision 1.3  1996/05/21  05:55:28  pinnacle
 * Replaced: include/vderrmacros.h for:  by msbraju for vds.240
 *
 * Revision 1.2  1995/08/21  18:58:42  pinnacle
 * Replaced: include/vderrmacros.h for:  by azuurhou for vds.240
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
 *	08/30/94	raju		First version.
 *	08/21/95	adz		Combined with v_dbgmacros.h
 *
 * -------------------------------------------------------------------*/

#ifndef vderrmacros_included
#define vderrmacros_included

#include "OMerrordef.h"

#ifdef VDS_DBG
#	define  VD_VERBOSE	1
#else
#	define  VD_VERBOSE	0
#endif

#ifndef	v_debug_include
#	include "v_dbgmacros.h"
#endif


#define VDS_ERR_HNDLR(desc, stat, msg, verbose, label) \
	if ( ( !(stat&1) || !(msg&1) ) && !verbose ) \
			goto label; \
	else if ( !(stat&1) || !(msg&1) || verbose ) \
		if( !VDerrHndlr(desc,stat,msg,verbose,__FILE__,__LINE__ ) ) \
			goto label;

#define VDS_ERR_CONTINUE(desc, stat, msg, verbose) \
	if ( !(stat&1) || !(msg&1) || verbose ) \
		if( !VDerrHndlr(desc,stat,msg,verbose,__FILE__,__LINE__ ) ) \
			continue;

#define VDS_ERR_RPT(desc, stat, msg, verbose) \
	if ( !(stat&1) || !(msg&1) || verbose ) \
		VDerrHndlr(desc,stat,msg,verbose,__FILE__,__LINE__ )

#endif

