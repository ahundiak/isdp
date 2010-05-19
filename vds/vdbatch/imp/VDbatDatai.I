/* $Id: VDbatDatai.I,v 1.1.1.1 2001/01/04 21:07:56 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	vdbatch/imp/VDbatDatai.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDbatDatai.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:56  cvs
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
# Revision 1.2  1995/08/31  21:49:32  pinnacle
# Replaced: ./vdbatch/imp/VDbatDatai.I for:  by azuurhou for vds.240
#
# Revision 1.1  1995/07/25  21:20:48  pinnacle
# Created: vdbatch/imp/VDbatDatai.I by azuurhou for vds.240
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	07/25/95	raju		creation date
 *	09/01/95	adz		update 
 *
 ***************************************************************************/

class implementation VDbatData;

#include <stdio.h>
#include "OMerrordef.h"
#include "OMmacros.h"
#include "exmacros.h"
#include "vdbatdrw.h"
#include "v_miscmacros.h"
#include "v_dbgmacros.h"

/*----------------------------------------------------------------------------
File : VDbatDatai.I

Desc :	This file contains wakeup, VDretrieveData, VDpostData methods
	and VDgetBatDataObj function.

	Raju  7/13/1995		Creation.
-----------------------------------------------------------------------------*/

/*-----------------------------------------------------------------------------
Doc : method wakeup

Desc :  Method to initialize instance data of this object.

-----------------------------------------------------------------------------*/
method wakeup( long *msg )
{
	long		sts = OM_S_SUCCESS;

	SetProc( VDBatData_wakeup ); Begin 

	*msg = MSSUCC;

	me->nbDv = 0;
	me->queue[0] = '\0';
	me->login[0] = '\0';
	me->passwd[0] = '\0';

	End ;
	return sts;
}

/*-----------------------------------------------------------------------------
Doc : method VDretrieveData

Desc :  Method to retrieve the instance data of this object.

-----------------------------------------------------------------------------*/
method VDretrieveData (
  IGRlong		*msg;
  IGRlong		*nbDv;
  VDdrwBatchInfo	**batchInfo;
  IGRchar		*queue;
  IGRchar		*login;
  IGRchar		*passwd;
  IGRboolean		*procType;
  struct GRid		*locateWin;
)
{
	long		sts, ii;

	SetProc( VDBatData_VDretrieveData ); Begin

	sts	= OM_S_SUCCESS;
	*msg	= MSSUCC;

	if ( nbDv )	*nbDv = me->nbDv;
	if ( queue  )	strcpy( queue,  me->queue );
	if ( login  )	strcpy( login,  me->login );
	if ( passwd )	strcpy( passwd, me->passwd );
	if ( procType ) *procType = me->procType;
	if ( locateWin ) *locateWin = me->locateWin;


	if ( ! nbDv || *nbDv == 0 ) goto wrapup;

	__DBGpr_int(" NbDv ", *nbDv );

	if( batchInfo ){

		*batchInfo = NULL ;
		*batchInfo = _MALLOC( *nbDv, VDdrwBatchInfo );

		for(ii=0; ii<*nbDv; ii++)
			(*batchInfo)[ii] = me->batchInfo[ii];
	}

	wrapup:
		End ;
		return sts ;
}


/*-----------------------------------------------------------------------------
Doc : method VDpostData

Desc :  Method to post the instance data of this object.

-----------------------------------------------------------------------------*/
method VDpostData (	IGRlong		*msg;
			IGRlong		nbDv;
			VDdrwBatchInfo	*batchInfo;
			IGRchar		*queue;
			IGRchar		*login;
			IGRchar		*passwd;
			IGRboolean	*procType;
			struct GRid	*locateWin; )

{
	long		sts, ii;

	SetProc( VDBatData_VDpostData ); Begin

	sts	= OM_S_SUCCESS;
	*msg	= MSSUCC;

	__DBGpr_int(" nbDv ", nbDv );

	me->nbDv = nbDv;

	sts =
	om$vla_set_dimension(	varray	=  me->batchInfo,
				size	=  nbDv );

	VDbat_InitBatchInfo( nbDv, me->batchInfo );

	for(ii=0; ii<nbDv; ii++)	me->batchInfo[ii] = batchInfo[ii];

	if ( queue )	strcpy( me->queue, queue );

	if ( login )	strcpy( me->login, login );

	if ( passwd )	strcpy( me->passwd, passwd );

	if ( procType ) me->procType = *procType;

	if ( locateWin ) me->locateWin = *locateWin;

	End ;
	return sts;
}

/*-----------------------------------------------------------------------------
Doc : function VDgetBatDataObj

Desc :  This function returns GRid of VDbatData if it exists. If not,
	it creates an object, send the message wakeup to the object and
	returns GRid.
‚
-----------------------------------------------------------------------------*/
long  VDgetBatDataObj(	long		*msg,
			struct GRid	*dataObj )
{
	long		sts;
	struct GRid	mod;

	SetProc( VDgetBatDataObj ); Begin

	*msg = MSSUCC;

	ex$get_cur_mod( id	= &mod.objid,
			osnum	= &mod.osnum);

	dataObj->osnum = mod.osnum;

#ifdef	OLD_VERSION

	sts =
	ex$get_super(	mod_id		= mod.objid,
			mod_osnum	= mod.osnum,
			super_name	= "VDbatData",
			create		= FALSE,
			super_class	= "VDbatData",
			super_id	= &(dataObj->objid),
			super_osnum	= &(dataObj->osnum),
			wakeup_flag	= FALSE	);
#endif

	sts =
	ex$get_objid_from_NOD(
			NODname         = "IGENOD",
			objname         = "VDbatData",
			pobjid          = &(dataObj->objid),
			modid           = mod.objid,
			mod_osnum       = mod.osnum);
	if ( !(sts&1) ){

		__DBGpr_com(" Construct New Objects ");

		sts =
		ex$get_super(
			mod_id		= mod.objid,
			mod_osnum	= mod.osnum,
			super_name	= "VDbatData",
			create		= TRUE,
			super_class	= "VDbatData",
			super_id	= &(dataObj->objid),
			super_osnum	= &(dataObj->osnum),
			wakeup_flag	= TRUE );

		__DBGpr_obj(" VDBatData ", *dataObj );

		sts =
		_VD_SEND_OBJN(	*dataObj, VDbatData.wakeup( msg ));
	}

	return sts;
}

end implementation VDbatData;
