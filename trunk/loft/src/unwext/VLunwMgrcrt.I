/* $Id: VLunwMgrcrt.I,v 1.3 2001/02/20 16:22:17 build Exp $  */

/*************************************************************************
 * I/LOFT
 *
 * File:        src/unwext/VLunwMgrcrt.I
 *
 * Description: Functions relating to Unwrap Manager.
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VLunwMgrcrt.I,v $
 *      Revision 1.3  2001/02/20 16:22:17  build
 *      Included VDobj.h file.
 *
 *      Revision 1.2  2001/02/20 01:07:23  build
 *      Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *      Revision 1.1.1.1  2001/01/04 21:11:43  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:32:50  pinnacle
# LOFT 2.5.1
#
# Revision 1.1  1997/10/28  15:30:14  pinnacle
# Created: src/unwext/VLunwMgrcrt.I by rchennup for loft
#
 *
 * History:
 *      MM/DD/YY   AUTHOR       DESCRIPTION
 *      10/28/97   Rama Rao     File Creation
 *************************************************************************/

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
#include        "VDobj.h"
#include	"vldbgmacros.h"

/********************************************************************
  Construct if necessary a VLunwSuper object in the current directory
*********************************************************************/

void
VL_unwConst_VLunwMgrSuper( msg, obj )

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
			super_name	= "VLunw Mgr",
			create		= TRUE,
			super_class	= "VLunwMgr",
			super_id	= &(obj->objid),
			super_osnum	= &(obj->osnum) );

	__DBGpr_obj( "VLunwmgr: ", *obj );

}

end implementation VDS_LOCATE ;

