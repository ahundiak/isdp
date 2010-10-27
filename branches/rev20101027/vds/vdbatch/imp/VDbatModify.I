/* $Id: VDbatModify.I,v 1.1.1.1 2001/01/04 21:07:56 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	vdbatch/imp/VDbatModify.I
 *
 * Description:
 *		This function will be called by the visualization
 *		set objects to keep the Control Object data persistant
 *		with the design file activities.
 *
 * Dependencies:
 *		VDbatData.S
 *		VDdrw2dVw.S
 *		VDdrw3dVw.S
 *
 * Revision History:
 *	$Log: VDbatModify.I,v $
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
# Revision 1.1  1995/07/25  21:02:52  pinnacle
# Created: vdbatch/imp/VDbatModify.I by azuurhou for vds.240
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	07/18/95	adz		creation date
 *
 ***************************************************************************/

class implementation VDSroot;

#include <stdio.h>
#include <string.h>

#include "OMerrordef.h"

#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "DImacros.h"

#include "vds.h"
#include "vdbatdrw.h"
#include "vdbatdrwmac.h"
#include "vddrwattr.h"
#include "v_datamacros.h"
#include "v_miscmacros.h"
#include "v_dbgmacros.h"

from	VDmdlview	import	VDmv_give_name_desc ;
from	VDviewvol	import	VDvv_give_name_desc ;
from	VDbatData	import	VDretrieveData;

extern	OMuword		OPP_GRdrawview_class_id ;
extern	OMuword		OPP_VDmdlview_class_id ;
extern	OMuword		OPP_VDviewvol_class_id ;
extern	OMuword		OPP_EMSsolid_class_id ;


#define	VD_S_drwName_DV		"DrwView"
#define	VD_S_drwName_VV		"ViewVol"
#define	VD_S_drwName_MV		"ModView"
#define	VD_S_drwName_SD		"Solid"

/*---------------------------------------------------------------------------*/
long VDbat_GiveObjectInfo( msg, elmId, props, fName, uName, uDesc )

long		*msg ;
struct	GRid	*elmId ;
IGRlong		*props ;
IGRchar		*fName ;
IGRchar		*uName ;
IGRchar		*uDesc ;
{
	/*
	 * This function will control the input element 'elmId' and 
	 * returns it properties types 'props'.
	 * When NULL pointer is given for 'props' nothing will be returned.
	 */
	IGRint			sts = OM_S_SUCCESS;
	GRname			name ,
				name1 ; 

	SetProc( VDbat_GiveObjectInfo ); Begin

	*msg = MSSUCC ;

	if( props ) 	*props = 0 ;
	strcpy( fName, "" );
	strcpy( uName, "" );
	strcpy( uDesc, "" );

	if( vd_$is_ancestry_valid(	object	= elmId,
					classid	= OPP_GRdrawview_class_id )){

		if( props )	*props	= VD_DV ;
		strcpy( fName, VD_S_drwName_DV );
		sts =
		_VD_SEND_OBJN( *elmId, GRgraphics.GRgetname( msg, name ));
		if( name[0] != '\0' ){ di$split( pathname=name, name=uName ); }
		goto wrapup ;
	}

	if( vd_$is_ancestry_valid(	object  = elmId,
					classid = OPP_VDviewvol_class_id )){

		if( props ) 	*props = VD_VV ;
		strcpy( fName, VD_S_drwName_VV );
		sts =
		_VD_SEND_OBJN(	*elmId,
				VDviewvol.VDvv_give_name_desc(msg,name,name1));
		 __CheckRC( sts,*msg,"VDviewvol.VDvv_give_name_desc",wrapup );

		strcpy( uName, name ); strcpy( uDesc, name1 );
		goto wrapup;
	}

	if( vd_$is_ancestry_valid(	object	= elmId,
					classid	= OPP_VDmdlview_class_id )){

		if( props )	*props	= VD_MDLV ;
		strcpy( fName, VD_S_drwName_MV );
		sts =
		_VD_SEND_OBJN(*elmId,
				VDmdlview.VDmv_give_name_desc(msg,name,name1));
		__CheckRC( sts,*msg,"VDviewvol.VDvv_give_name_desc",wrapup );

		strcpy( uName, name ); strcpy( uDesc, name1 );
		goto wrapup ;
	}

	if( vd_$is_ancestry_valid(	object  = elmId,
					classid = OPP_EMSsolid_class_id )){

		if( props ) 	*props = VD_SOLID ;
		strcpy( fName, VD_S_drwName_SD );
		sts =
		_VD_SEND_OBJN(*elmId, GRgraphics.GRgetname( msg, name ));
		if( name[0] != '\0' ){ di$split( pathname=name, name=uName ); }
		goto wrapup;
	}

	*msg = MSFAIL ;

	wrapup :

		return sts ;
}

/*---------------------------------------------------------------------------*/

long VDbat_UpdateControlData( msg, mdEnv, vwId, action )

IGRlong			*msg;
struct	GRmd_env	*mdEnv ;
struct	GRid		*vwId ;
IGRint			action ;	/* Action type process	*/
{
	/*
	 * This function will get the visualization set name and
	 * check if it exist in the control data.
	 * Based on the process request, we will change the control
	 * data information.
	 * Possible actions:
	 *	- delete: Object will be deleted and the control object
	 *		need to cleanup this information in the data 
	 *		structure. Also the status will be set to new.
	 *		The procSts will be set to NEW.
	 */
	IGRint			sts = OM_S_SUCCESS ,
				i, type; 
	IGRlong			dvCount ;
	struct	GRid		cntlObj ;
	VDobjDef		objDef ;
	VDpartAttr		attr ;
	VDdrwBatchInfo		*info,		/* Retrieve structure	*/
				infoStr ;	/* Set structure	*/

	SetProc( VDbat_UpdateControlData ); Begin

	*msg	= MSSUCC ;
	info	= NULL ;
	dvCount	= 0 ;
	action	= 0 ;		/* not used.	*/


	if( ! vwId || ! mdEnv ){
		sts = OM_E_INVARG ;
		goto wrapup ;
	}

	/*
	 * Get the control object.
	 */
	cntlObj.objid	= NULL_OBJID ;
	sts = VDgetBatDataObj( msg, &cntlObj );
	__CheckRC( sts, *msg, "VDgetBatDataObj", wrapup );

	if( cntlObj.objid == NULL_OBJID )	goto wrapup ;

	/*
	 * retrieve the information from the 
	 */
	sts =
	_VD_SEND_OBJN(	cntlObj,
			VDbatData.VDretrieveData(	msg,
							&dvCount,
							&info,
							NULL,
							NULL,
							NULL,
							NULL,
							NULL ));
	__CheckRC( sts, *msg, "VDbatData.VDretrieveData", wrapup );

	if( ! dvCount )	goto wrapup ;

	/*
	 * Get the name of the visualization set.
	 */
	attr.Iwant = VD_I_drwInternalName ;
	sts =
	_VD_SEND_OBJN(	*vwId, GRvg.GRgetattr( msg, (char *)&attr ));
	__CheckRC( sts, *msg, "GRvg.GRgetattr", wrapup );

	if( strlen( attr.aString ) == 0 )	goto wrapup ;

	/*
	 * Get process type.
	 */
	sts =
	_VD_SEND_OBJN(	*vwId, VDSroot.VDgetObjDef( msg, &objDef ));
	__CheckRC( sts, *msg, "VDSroot.VDgetObjDef", wrapup );

	/*
	 * Check if name exist in control data.
	 */
	for( i=0 ; i<dvCount ; i++ ){

	  if( objDef.type & VD_O_drw2d ){
	    if( ! strcmp( info[i].drw2dVw, attr.aString )) break ;
	  }
	  else{
	    if( ! strcmp( info[i].drw3dVw, attr.aString )) break ;
	  }
	}

	if( i==dvCount )	goto wrapup ;

	/*
	 * Get the information from the control object.
	 */
	sts =
	vd$drw_batch_info( msg = msg , index = i, info = &infoStr,
			   type = VD_B_drw_SolProp | VD_B_drw_ProcSts |
				  VD_B_drw_2dVw    | VD_B_drw_3dVw );
	__CheckRC( sts, *msg, "vd$drw_batch_info", wrapup );

	/*
	 * Clean the field in the control data object.
	 */
	if( objDef.type & VD_O_drw2d ){
		strcpy( infoStr.drw2dVw, "" );
		infoStr.props &= ~(VD_EXTR_OK | VD_EXTR_NEW );
		infoStr.props |= VD_EXTR_NEW ;
		infoStr.procSts = VD_B_drwInitialSts ;
		type	= VD_B_drw_2dVw | VD_B_drw_SolProp | VD_B_drw_ProcSts ;
	}
	else{	strcpy( infoStr.drw3dVw, "" );
		type	= VD_B_drw_3dVw ;

		if( ! strlen( infoStr.drw2dVw )){
			/*
			 * No 2d visualization set.
			 */
			infoStr.procSts = VD_B_drwInitialSts ;
			infoStr.props &= ~(VD_EXTR_OK | VD_EXTR_NEW );
			infoStr.props |= VD_EXTR_NEW ;
			type = type | VD_B_drw_SolProp | VD_B_drw_ProcSts ;
		}
	}

	/*
	 * Post the information into the control object.
	 */
	sts =
	vd$drw_batch_info(msg = msg , index = i, info = &infoStr,
			  type = type, set_inq = VD_B_drw_SET );
	__CheckRC( sts, *msg, "vd$drw_batch_info", wrapup );
				
	wrapup:
		_FREE( info );
		End ;
		return sts ;
}

/*---------------------------------------------------------------------------*/

end implementation VDSroot;
