/* $Id: VDdrwMgrcrt.I,v 1.1.1.1 2001/01/04 21:08:38 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vddraw/imp/VDdrwMgrcrt.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDdrwMgrcrt.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:08:38  cvs
 *      Initial import to CVS
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
# Revision 1.1  1995/06/27  18:24:36  pinnacle
# Created: vddraw/imp/VDdrwMgrcrt.I by azuurhou for vds.240
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *	06/06/95	adz		creation date
 *
 * -------------------------------------------------------------------*/

class implementation VDS_LOCATE ;

#include	"OMmacros.h"
#include	"OMminimum.h"
#include	"OMindex.h"
#include	"exdef.h"
#include	"exmacros.h"
#include	"expression.h"
#include	"expmacros.h"
#include	"msdef.h"
#include	"igetypedef.h"
#include	"igrtypedef.h"
#include	"gr.h"
#include	"v_dbgmacros.h"

/********************************************************************
  Construct if necessary a VDdrwSuper object in the current directory
*********************************************************************/

void
VD_drwConst_VDdrwMgrSuper( msg, obj )

long			*msg ;
struct	GRid		*obj ;
{
struct	GRid		mod;

	/*
	 * get the module environment 
	 */

	*msg = MSSUCC ;

	ex$get_cur_mod(	id	= &mod.objid,
			osnum	= &mod.osnum);

	obj->objid = NULL_OBJID ;
	obj->osnum = mod.osnum  ;

	/*
	 * call get super
	 */
	ex$get_super(	mod_id		= mod.objid,
	      		mod_osnum	= mod.osnum,
			super_name	= "VDdrw Mgr",
			create		= TRUE,
			super_class	= "VDdrwMgr",
			super_id	= &(obj->objid),
			super_osnum	= &(obj->osnum) );

	__DBGpr_obj( "VDdrwmgr: ", *obj );

}

end implementation VDS_LOCATE ;

