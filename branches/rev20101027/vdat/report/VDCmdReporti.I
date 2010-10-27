/* $Id: VDCmdReporti.I,v 1.1.1.1 2001/01/04 21:07:43 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	vdat/report/VDCmdReporti.I
 *
 * Description:
 *	Implementation file of functions and method to generate reports.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDCmdReporti.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:43  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/12/31  13:47:44  pinnacle
# Moved from vdastree
#
# Revision 1.3  1997/12/05  09:23:26  pinnacle
# Replaced: vdastree/report/VDCmdReporti.I for:  by ksundar for vds
#
# Revision 1.2  1997/11/21  15:32:52  pinnacle
# ah
#
# Revision 1.1  1997/11/04  17:41:38  pinnacle
# Created: vdastree/report/VDCmdReporti.I by v250_int for vds
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	10/23/97	adz		creation date
 *	11/21/97	ah		added OMmacros.h
 *	12/30/97	ah		moved to vdat
 ***************************************************************************/
class implementation VDCmdReport ;

#include <stdio.h>
#include <sys/param.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <pw.h>			/* For `logname()'	*/
#include <FI.h>
#include "OMversion.h"
#include "OMprimitives.h"
#include "OMmacros.h"
#include "growner.h"
#include "dpmacros.h"
#include "v_globalmsg.h"
#include "v_cmd.h"
#include "v_cmddef.h"
#include "v_miscmacros.h"
#include "vdrptmacros.h"
#include "v_dbgmacros.h"

/*
 * Includes for function prototypes.
 */
%safe
#include "VX_FIproto.h"
%endsafe

extern	char	*VDrp_createFileForm();

%safe
static char	VDrp_curPATH[MAXPATHLEN	+1]	= "."	,
		VDrp_curNAME[FILENAME_MAX+1]	= ""	,
		VDrp_curRGXP[VD_K_MAX_RGXP]	= "*"	,
		VDrp_repNAME[FILENAME_MAX+1]	= ""	,
		VDrp_repRGXP[VD_K_MAX_RGXP]	= "*"	,
		VDrp_repTITLE[MAXPATHLEN +1]	= "Output Report" ;
%endsafe
/*----------------------------------------------------------------------------*/
method createFileForm( long *msg ) {

	strcpy( me->fileInfo.openMode, "w" ) ;
	me->fileInfo.callBack	= NULL ;
	me->fileInfo.curPATH	= VDrp_curPATH ;
	me->fileInfo.curNAME	= VDrp_curNAME ;
	me->fileInfo.curRGXP	= VDrp_curRGXP ;
	me->fileInfo.repNAME	= VDrp_repNAME ;
	me->fileInfo.repRGXP	= VDrp_repRGXP ;
	me->fileInfo.repTITLE	= VDrp_repTITLE ;

	if( !me->fileForm ) {
		me->fileForm = VDrp_createFileForm( 10, 100, &me->fileInfo ) ;
	}
	*msg = me->fileForm ? MSSUCC : MSFAIL ;
	return OM_S_SUCCESS ;

} /* method createFileForm */
/*----------------------------------------------------------------------------*/
method fileFormDismissed( int dismissType ) {

	switch( dismissType ) {
		case VD_K_FILE_ACCEPTED : break ;
		case VD_K_FILE_CANCELED : me->fileInfo.pathName[0] = '\0' ;
					  break ;
	}
	me->fileForm = NULL ;
	return OM_S_SUCCESS ;

} /* method fileFormDismissed */
/*----------------------------------------------------------------------------*/
method discard_all_input( long *msg  ) {

	SetProc( VDCmdReport.discard_all_input ); Begin

	om$vla_set_dimension( varray = me->locObjs, size = 0 ) ;

	*msg = MSSUCC ;
	End
	return OM_S_SUCCESS ;

} /* method discard_all_input */
/*----------------------------------------------------------------------------*/
method fileFormOnOffOut( int Switch /* 0=off, 1=on, 2=out */ ) {

	SetProc( VDCmdReport.fileFormOnOffOut ); Begin

	if( me->fileForm ) {
		__DBGpr_int(" Switch ", Switch );
		switch( Switch ) {
			case 0 : FIf_erase  ( me->fileForm ) ; break ;
			case 1 : FIf_display( me->fileForm ) ; break ;
			case 2 : FIf_delete ( me->fileForm ) ;
				 me->fileForm = NULL ; break ;
		}
	}

	End 
	return OM_S_SUCCESS ;

} /* method fileFormOnOffOut */
/*----------------------------------------------------------------------------*/
method operation( long *msg ) {

	long		sts ;		/* OM return code		*/
	int		objCount ;	/* Number of Objects located    */
	IGRchar		*title = NULL ;
	struct GRobj_env
			*objToReport ;	/* Id + env. of located objects	*/

	SetProc( VDCmdReport.operation ); Begin

	objToReport	= NULL ;
	objCount = om$dimension_of( varray = me->locObjs );

	if( ! objCount ){
		*msg = MSFAIL ;
		goto wrapup;
	}

	objToReport = _MALLOC( objCount, struct GRobj_env ) ;

	sts = om$send( msg	= message VDS_LOCATE.getLocatedObjects(
					msg, objCount, objToReport ),
		       targetid= my_id ) ;
	__CheckRC( sts, *msg, "VDS_LOCATE.getLocatedObjects", wrapup ) ;

	if( strlen( me->fileInfo.repTITLE )){
		title = me->fileInfo.repTITLE ;
	}

	sts = vd$create_report(	msg	= msg,
				fFpath	= me->fileInfo.curPATH,
				fFname	= me->fileInfo.curNAME,
				rFname	= me->fileInfo.repNAME,
				title	= title,
				nbObjs	= objCount,
				objList	= objToReport ) ;

	dp$erase_hilite (msg = msg);
	wrapup :
		_FREE( objToReport ) ;

		me->ret = *msg & 1 ? VD_K_ACT_SUCCESS : VD_K_RESTART_CMD ;

		End
		return OM_S_SUCCESS ;

} /* method operation */

/*----------------------------------------------------------------------------*/

end implementation VDCmdReport ;
