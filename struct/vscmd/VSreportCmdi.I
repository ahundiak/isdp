/*
	I/STRUCT
*/
class implementation VSreportCmd ;

#include <stdio.h>
#include <sys/param.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <pw.h>			/* For `logname()'	*/
#include <FI.h>
#include "OMversion.h"
#include "growner.h"
#include "vsglobalmsg.h"
#include "vscmddef.h"
#include "vscmdmacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes for function prototypes.
 */
%safe
#include "VX_FIproto.h"
%endsafe
#include "vsgetmsgkey.h"
#include "vsgrenvproto.h"
#include "vsioproto.h"

#define	VS_JN_REPORT	0	/* Reports on joints	*/
#define	VS_BM_REPORT	1	/* Reports on beams	*/
#define	VS_PL_REPORT	2	/* Reports on plates	*/
%safe
static char	curPATH[MAXPATHLEN	+1]	= ".",
		curNAME[FILENAME_MAX	+1]	= "",
		curRGXP[VS_K_MAX_RGXP]		= "*" ;
%endsafe
/*----------------------------------------------------------------------------*/
static void VSreportHeader( rF, title ) FILE *rF ; char *title ; {

	char				model[OM_K_MAXOSNAME_LEN] ;
	extern INGR_S_PRODUCT_DEF	STRUCT_appl_version_id ;

	ex$filename( name = model, len = OM_K_MAXOSNAME_LEN ) ;

	fprintf( rF,
		 "# %s\n# %s\n# User: %s\n# File: %s\n# Date: %s\n# Time: %s\n\n",
		 STRUCT_appl_version_id.curr_version,
		 title,
		 vslogname(),
		 model,
		 VSdate(),
		 VStime() ) ;

} /* VSreportHeader */
/*----------------------------------------------------------------------------*/
method createFileForm( long *msg ) {

	strcpy( me->fileInfo.openMode, "w" ) ;
	me->fileInfo.callBack= NULL ;
	me->fileInfo.curPATH = curPATH ;
	me->fileInfo.curNAME = curNAME ;
	me->fileInfo.curRGXP = curRGXP ;
	if( !me->fileForm ) {
		me->fileForm = VScreateFileForm( 10,
						 100,
						 &me->fileInfo ) ;
	}
	*msg = me->fileForm ? MSSUCC : MSFAIL ;
	return OM_S_SUCCESS ;

} /* method createFileForm */
/*----------------------------------------------------------------------------*/
method fileFormDismissed( int dismissType ) {

	switch( dismissType ) {
		case VS_K_FILE_ACCEPTED : break ;
		case VS_K_FILE_CANCELED : me->fileInfo.pathName[0] = '\0' ;
					  break ;
	}
	me->fileForm = NULL ;
	return OM_S_SUCCESS ;

} /* method fileFormDismissed */
/*----------------------------------------------------------------------------*/
method fileFormOnOffOut( int Switch /* 0=off, 1=on, 2=out */ ) {

	if( me->fileForm ) {
		switch( Switch ) {
			case 0 : FIf_erase  ( me->fileForm ) ; break ;
			case 1 : FIf_display( me->fileForm ) ; break ;
			case 2 : FIf_delete ( me->fileForm ) ;
				 me->fileForm = NULL ; break ;
		}
	}

	return OM_S_SUCCESS ;

} /* method fileFormOnOffOut */
/*----------------------------------------------------------------------------*/
method operation( long *msg ) {

	long		sts ;		/* OM return code		*/
	FILE		*rF = NULL,	/* Report file			*/
			*fF = NULL ;	/* Format file			*/
	char		*title,		/* Title of report		*/
			*fFname,	/* Name of format file		*/
			fFpath[1+PATH_MAX] ;
					/* Pathname of format file	*/
	int		rc ;		/* Return code of print function*/
	struct GRobj_env
			*objToReport ;	/* Id + env. of located objects	*/

#define VS_K_WLREP_NM "config/reports/report.jn"
#define VS_K_BMREP_NM "config/reports/report.bm"
#define VS_K_PLREP_NM "config/reports/report.pl"

	objToReport = NULL ;

	switch( me->mytype ) {
		case VS_JN_REPORT	: title = "Weld report"	 ;
					  fFname= VS_K_WLREP_NM	 ; break ;
		case VS_BM_REPORT	: title = "Beam report"  ;
					  fFname= VS_K_BMREP_NM	 ; break ;
		case VS_PL_REPORT	: title = "Plate report" ;
					  fFname= VS_K_PLREP_NM	 ; break ;
		default			: *msg  = MSINARG	 ; goto wrapup ;
	}

	/*
	 * Look for report-format file in product paths.
	 */
	VSfindFileInPwdOrPath( msg, fFname, fFpath ) ;

	if( !( *msg & 1 ) ) {
		ex$message(	msgnumb		= VSgetMsgKey( *msg ),
				field		= ERROR_FIELD,
				justification	= CENTER_JUS ) ;
		VS_Wait_timer( 100 ) ; *msg = MSFAIL ; goto wrapup ;
	}

	fF = VSopenFile( msg, fFpath, "r" ) ;

	if( !fF ) {
		ex$message(	msgnumb		= VSgetMsgKey( *msg ),
				field		= ERROR_FIELD,
				justification	= CENTER_JUS ) ;
		VS_Wait_timer( 100 ) ; *msg = MSFAIL ; goto wrapup ;
	}

	rF = VSopenFile( msg, me->fileInfo.pathName, "w" ) ;

	if( !rF ) {
		ex$message(	msgnumb		= VSgetMsgKey( *msg ),
				field		= ERROR_FIELD,
				justification	= CENTER_JUS ) ;
		VS_Wait_timer( 100 ) ; *msg = MSFAIL ; goto wrapup ;
	}

	VSreportHeader( rF, title ) ;

	objToReport = _MALLOC( me->oprndCount, struct GRobj_env ) ;

	sts = om$send( msg	= message VSlocateCmd.getLocObjs(
					msg, me->oprndCount, objToReport ),
		       targetid= my_id ) ;
	__CheckRC( sts, *msg, "VSlocateCmd.getLocObjs", wrapup ) ;

	rc = VSreportObjects( fF, rF, me->oprndCount, objToReport ) ;

	if( !rc ) {
		/*
		 * Output error.
		 */
		ex$message(	msgnumb		= VS_gE_WriteFile,
				field		= ERROR_FIELD,
				justification	= CENTER_JUS ) ;

	} else {
		ex$message(	msgnumb		= VS_gI_CreatedObj,
				field		= ERROR_FIELD,
				justification	= CENTER_JUS,
				type		= "%s",
				var		= `me->fileInfo.pathName` ) ;
	}
	VS_Wait_timer( 100 ) ;

	*msg = MSSUCC ;

	wrapup :
		_FREE( objToReport ) ;
		if( fF ) fclose( fF ) ;
		if( rF ) fclose( rF ) ;

		me->ret = *msg & 1 ? VS_K_ACT_SUCCESS : VS_K_RESTART_CMD ;
		return OM_S_SUCCESS ;

} /* method operation */
/*----------------------------------------------------------------------------*/

end implementation VSreportCmd ;
