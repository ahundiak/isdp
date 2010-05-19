/* $Id: VDrtfindmacr.I,v 1.2 2001/02/22 16:24:25 ramarao Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	vdroot/VDrtfindmacr.I
 *
 * Description:
 *		Find macro of VDSroot subclass objects. This method
 *		is overridden to avoiding the file corruption problem.
 *
 * Dependencies:
 *		ACcpx.S
 *
 * Revision History:
 *	$Log: VDrtfindmacr.I,v $
 *	Revision 1.2  2001/02/22 16:24:25  ramarao
 *	Removed unnecessary debugs.
 *	
 *	Revision 1.1.1.1  2001/01/04 21:09:12  cvs
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
# Revision 1.1  1995/07/11  20:13:48  pinnacle
# Created: vdroot/VDrtfindmacr.I by azuurhou for vds.240
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	07/10/95	adz		creation date
 *
 ***************************************************************************/

class implementation VDSroot;


#include "macro.h"
#include "acmacros.h"
#include "grerr.h"
#include "acrepdef.h"
#include "v_dbgmacros.h"

extern GRclassid OPP_ACtmp_defn_class_id;

from	ACcpx_defn	import	ACreturn_real_def;
from	ACmacro_defn	import	ACgive_upscan;

/* ========================================================================= */

method find_macro( struct GRid *macro )
{
	int		status;
	long		msg ;
	struct	GRid	macroId ;
	GRname		className,
			macroName ;
	extern		GRclassid OPP_ACmacro_defn_class_id;

	/*
	 * Is the occurence already linked to the real macro definition
	 */
	status = OM_W_ABORT;

	status =
	om$send(msg = message ACcpx.find_macro(	macro ),
		targetid = my_id,
		mode = OM_e_wrt_message );
			
	if( !(status&1)) {

	   /*
	    * see is we can get the macro name based on the object
	    * class.
	    */
	   macro->objid = NULL_OBJID;

	   status =
	   om$get_classname(	osnum = OM_Gw_current_OS,
                                objid = my_id,
                                classname = className );

	   status =
	   VDqry_GiveMacroFromClass( &msg, className, macroName );
	   if( status & msg & 1 ){
		
		status =
		ac$find_macro_defn(	action		= ACfind_no_load,
					macro_name	= macroName ,
					p_macro_defn_id	= &macroId );

		if( status&1 ){
		  me->mac_def = macroId ;
		  *macro = me->mac_def ;
		}
	   }
	}

	return( status );
} 

end implementation VDSroot;
