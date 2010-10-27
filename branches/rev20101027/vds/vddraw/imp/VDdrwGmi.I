/* $Id: VDdrwGmi.I,v 1.1.1.1 2001/01/04 21:08:38 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vddraw/imp/VDdrwGmi.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDdrwGmi.I,v $
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
# Revision 1.1  1995/06/27  18:23:56  pinnacle
# Created: vddraw/imp/VDdrwGmi.I by azuurhou for vds.240
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	06/06/95	adz		creation date
 *
 * -------------------------------------------------------------------*/

class implementation VDdrwGm;

#include "grerr.h"
#include "OMmacros.h"
#include "vds.h"
#include "VDmsg.h"
#include "v_miscmacros.h"
#include "v_dbgmacros.h"

/*+mo
 -------------------------------------------------------------------------

  Overridden Message
       GRgetobjinfo from GRgraphics

  Abstract

	Reports information about the object. 
	It has been overriden to display the type of the main surface when it
	is located (status field).

  Arguments

      IGRlong		*msg             O   	completion code
      struct GRobj_info	*info            O	structure for information about
                                 		the object

  Status/Return Code
     OM_S_SUCCESS	if success;
     OM_E_ABORT		if fails

 -------------------------------------------------------------------------
-mo*/

method GRgetobjinfo(IGRlong *msg; struct GRobj_info *info)
{
	/*
	 * Get the object information of the owner object.
	 */
	IGRint			sts = OM_S_SUCCESS ;
	struct	GRid		ownId ,
				my_GRid ;
	GRname			ownName ;
	VDobjDef		objDef ;

	SetProc( VDdrwGm_GRgetobjinfo ); Begin

	*msg 	= MSSUCC ;

	my_GRid.objid	= my_id ;
	my_GRid.osnum	= OM_Gw_current_OS ;

	ASget_as_owner( &my_GRid, &ownId );

	if( IF_NULL_OBJID( ownId.objid )) goto wrapup ;

	__DBGpr_obj(" Owner Obj" , ownId );

	sts =
	_VD_SEND_OBJ( ownId, VDSroot.VDgetObjDef( msg, &objDef ));
	__CheckRC( sts, *msg, "VDSroot.VDgetObjDef", wrapup );

	strcpy( ownName, VDmsgkey2string( objDef.info ));

	/*
	 * Set owner object information.
	 */
	sprintf( info->type, "Geom -%s ",  ownName );

	*msg = MSSUCC;
	End ;
	return OM_S_SUCCESS;

	wrapup :
		strcpy( info->type, " Geom " );
		*msg = MSSUCC;
		End ;
		return OM_S_SUCCESS;
}

/*----------------------------------------------------------------------------*/

method VDgetObjDef( long *msg ; VDobjDef *myDef ) {

	long		sts ;	/* OM return code	*/

	/*
	 * name.
	 */
	myDef->info		= VD_I_ObjDrwGm ;
	myDef->type		= 0 ;

	sts	= OM_S_SUCCESS ;
	*msg	= MSSUCC ;

	return sts ;

} /* method VDgetObjDef */

/*----------------------------------------------------------------------------*/

end implementation VDdrwGm;
