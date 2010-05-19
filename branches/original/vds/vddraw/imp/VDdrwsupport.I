/* $Id: VDdrwsupport.I,v 1.1.1.1 2001/01/04 21:08:38 cvs Exp $ */
/*---------------------------------------------------------------------------
/*  I/VDS
 *
 * File:        vddraw/imp/VDdrwsupport.I
 *
 * Description:
 *
 *      Implementation of user attributes support functions for 2d/3d and
 *	2d/3d View Visualization objects.
 *      
 * Revision History:
 *	$Log: VDdrwsupport.I,v $
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
# Revision 1.2  1995/08/07  20:20:56  pinnacle
# Replaced: vddraw/imp/VDdrwsupport.I for:  by azuurhou for vds.240
#
# Revision 1.1  1995/06/27  18:27:40  pinnacle
# Created: vddraw/imp/VDdrwsupport.I by azuurhou for vds.240
#
 *
 * History:
 *
 *      08/15/94	R.Manem			Creation date.
 *
 * -------------------------------------------------------------------------
 */

class implementation VDSroot;

#include "string.h"
#include "OMmacros.h"
#include "OMprimitives.h"
#include "exproto.h"
#include "ACrg_collect.h"

#include "ms.h"
#include "msdef.h"
#include "msmacros.h"
#include "AS_status.h"
#include "vddrwattr.h"
#include "vdparmacros.h"
#include "v_miscmacros.h"
#include "v_dbgmacros.h"

extern	OMuword		OPP_VDdrw2d_class_id,
			OPP_VDdrw3d_class_id ;

/* -------------------------------------------------------------------------- */

/*+fe
Function   VDdrw_ConstructVDdrw()

Abstract
	This function constructs a VDdrw2d/VDdrw3d object and set some
	instance values.

Arguments
	OUT	IGRlong		*msg		return status
	IN	IGRint		type		Object Type (see vddrwattr.h)
	IN/OUT	struct GRid	*elmId		Object Identifiers.
	IN	struct GRmd_env	*elmEnv		Module Environment
	INT	struct GRobj_env *dady		Parent object.
	
Return status
	OM_S_SUCCESS	oke.
	OM_E_ABORT	otherwise.

History
	06/06/95	adz		creation date
-fe*/

long VDdrw_ConstructVDdrw ( msg, type, elmId, elmEnv, dady )

IGRlong		*msg;			/* return status             */
IGRushort	type;			/* Object Type               */
struct GRid	*elmId;			/* Object Id.   	     */
struct GRmd_env	*elmEnv	;		/* Module Environment        */
struct GRobj_env *dady ;		/* Parent Object	     */
	
{
	/*
	 * Construct an new object and store instance data from the 
	 * parent object in the constructed object. 
	 */
	IGRint			sts = OM_S_SUCCESS;
	GRname			modMacro, modName, modDesign ;
	OMuword			classId ;
	VDdrwObjInfo		objInfo ;
	VDpartAttr		attr ;

	SetProc( VDdrw_ConstructVDdrw  ); Begin

	*msg		= MSSUCC;

	if( type & VD_O_drw3d ){
		__DBGpr_com(" Construct VDdrw3d ");
		classId = OPP_VDdrw3d_class_id ;
	}
	else{
		__DBGpr_com(" Construct	VDdrw2d ");
		classId	= OPP_VDdrw2d_class_id ;
	}

        if( !(vd_$is_ancestry_valid(    object  = elmId,
                                        classid = classId ))){

		elmId->osnum	= elmEnv->_MD_OS ;
		elmId->objid	= NULL_OBJID ;
	
		sts =
		om$construct(	classid = classId ,
				osnum   = elmId->osnum,
				p_objid = &(elmId->objid) );
		__CheckRC( sts, 1, "om$construct", wrapup );
	
		attr.Iwant	 = VD_I_drwInitialization ;
		sts =
		_VD_SEND_OBJN(  *elmId, GRvg.GRputattr( msg, (char *)&attr ));
		__CheckRC( sts, *msg, "GRvg.GRputattr", wrapup );
	}

	/*
	 * Add the parent information to the object.
         *              - macro name,
         *              - occurence name,
         *              - design file name,
	 */
	sts =
	VD_drwGetObjFeetInfo( msg, dady, modMacro, modName, modDesign );
	__CheckRC( sts, *msg, "VD_drwGetObjFeetInfo", wrapup );

	attr.Iwant		= VD_I_drwAllObjInfo ;
	objInfo.objMacro	= modMacro ;
	objInfo.objName		= modName ;
	objInfo.objDesign	= modDesign ;
	attr.specific		= (void *) & objInfo ;
	sts =
	_VD_SEND_OBJN(  *elmId, GRvg.GRputattr( msg, (char *)&attr ));
	__CheckRC( sts, *msg, "GRvg.GRputattr", wrapup );

	wrapup :

		if( !(sts & *msg & 1 )){
		    if( elmId->objid != NULL_OBJID ){
			/*
			 * Delete object.
			 */
			sts =
			vd_$bulk_delete(	count	= 1,
						grids	= elmId,
						theEnv	= elmEnv );
			elmId->objid = NULL_OBJID ;
		    }
		}
		
		End ;
		return sts ;
}


/* -------------------------------------------------------------------------- */

long VDdrw_Init2dVwInfo( msg, vwInfo )

IGRlong		*msg;			/* return status             */
VDdrw2dVwInfo	*vwInfo ;		/* Information structure     */
	
{
	/*
	 * Construct an new object 
	 */
	SetProc( VDdrw_Init2dVwInfo  ); Begin

	*msg	= MSSUCC ;

        vwInfo->intName		= NULL ;
        vwInfo->visFile		= NULL ;
        vwInfo->trsFile		= NULL ;
        vwInfo->prjVec		= NULL ;
        vwInfo->prjPnt		= NULL ;
        vwInfo->objLev		= NULL ;
        vwInfo->drwLbsys	= NULL ;

	End ;
	return OM_S_SUCCESS ;
}

/* -------------------------------------------------------------------------- */

long VDdrw_IntObjInfo( msg, objInfo )

IGRlong		*msg;			/* return status             */
VDdrwObjInfo	*objInfo ;		/* Information structure     */
	
{
	/*
	 * Construct an new object 
	 */

	SetProc( VDdrw_InitVwInfo  ); Begin

	*msg	= MSSUCC ;

	objInfo->objMacro	= NULL ;
        objInfo->objName	= NULL ;
        objInfo->objDesign	= NULL ;

	End ;
	return OM_S_SUCCESS ;
}

/*+fe
Function   VDdrw_ConstMacroVw()

Abstract
	This function constructs a macro of VDdrw2dVw/VDdrw3dVw object. 

Arguments
	OUT	IGRlong		*msg		return status
	IN	IGRint		type		Object Type (see vddrwattr.h)
	IN/OUT	struct GRid	*elmId		Object Identifiers.
	IN	struct GRmd_env	*elmEnv		Module Environment
	IN	IGRint		prop		Construction Properties.
	IN	IGRint		nbRoots		Number of Parents
	IN	struct GRid	Roots		Parent objects.
	
Return status
	OM_S_SUCCESS	oke.
	OM_E_ABORT	otherwise.

History
	06/06/95	adz		creation date
-fe*/

long VDdrw_ConstMacroVw ( msg, type, elmId, elmEnv, prop, nbRoots, Roots )

IGRlong		*msg;			/* return status             */
IGRushort	type;			/* Object Type               */
struct GRid	*elmId;			/* Object Id.   	     */
struct GRmd_env	*elmEnv	;		/* Module Environment        */
IGRint		prop;			/* Construction properties   */
IGRint		nbRoots;		/* Number of Roots connected */
struct GRid	*Roots;			/* List of Roots Objects     */
	
{
	/*
	 * Construct an macro object 
	 */
	IGRint			sts = OM_S_SUCCESS;
	IGRchar			*macName ;
	struct	GRmd_env	*dummy ;

	SetProc( VDdrw_ConstMacroVw ); Begin

	*msg	= MSSUCC;
	dummy	= elmEnv ;	/* Avoid compilation warning	*/

	macName = ( type & VD_O_drw3d ) ? VDdrw_M_3dVw : VDdrw_M_2dVw ;

	sts =
	_VD_SEND_OBJN(	*elmId,
			VDSroot.VDcreate(	msg,
                                                0,
                                                NULL,
                                                macName,
                                                prop,
                                                nbRoots,
                                                Roots ));
	__CheckRC( sts, *msg, "VDSroot.VDcreate", wrapup );

	wrapup:

		End;
		return sts ;
}

end implementation VDSroot;
 
