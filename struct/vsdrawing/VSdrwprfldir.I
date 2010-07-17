/*
	I/STRUCT
*/
class implementation VSbeam ;

#include <string.h>
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"
#include "vsglobalmsg.h"
#include "vsmiscmacros.h"
#include "vsdrwdef.h"
#include "vsdrw.h"
#include "vsdrwapi.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsdrwproto.h"
#include "vsvecmxproto.h"

#define ALONG_X	1
#define ALONG_Y	2
#define ALONG_Z	3
#define OPP_X	(-1)
#define OPP_Y	(-2)
#define OPP_Z	(-3)
/*----------------------------------------------------------------------------*/
long VSfindProfileX( msg, inp, xData, pfDir, pfDirASCII )

long		     *msg ;		/* OUT: Completion code		     */
const VSdrwInputData *inp ;		/* IN : Data input to interpreter    */
const VSdrwExecData  *xData ;		/* IN : Data modified by interpreter */
int		     *pfDir ;		/* OUT: Direction of profile	     */
char		     pfDirASCII[3]; {	/* OUT: Direction of profile (string)*/

	long		sts,		/* OM return code		*/
			rc ;		/* Other completion code	*/
	VSsuppList	bmSupps ;	/* Supports of beam (sf + axis)	*/
	int		count ;		/* Count of supports		*/
	IGRmatrix	prflCS ;	/* Matrix of profile		*/
	IGRvector	xp,		/* X-axis of profile		*/
			yp,		/* Y-axis of profile		*/
			zp ;		/* Z-axis of profile		*/
	struct GRid	prflDef ;	/* Id of profile definition	*/
	VSdirectionType	dir ;		/* Direction of profile		*/
	char		*p ;		/* A utility pointer		*/

	*msg = MSFAIL ;

	*pfDirASCII = '\0' ;

	/*
	 * Input element must be a beam/stiffener
	 */
	if(    xData->parsedElmType != VS_gI_Beam
	    && xData->parsedElmType != VS_gI_Stiffener ) goto wrapup ;

	sts = om$send(	msg	= message VSpart.VSgetSupports(
					&rc, inp->elmEnv, &count, bmSupps ),
			senderid= NULL_OBJID,
			targetid= inp->elmId->objid,
			targetos= inp->elmId->osnum ) ;
	if( !( sts & 1 & rc ) ) goto wrapup ;

	sts = om$send(	msg	= message VSbeam.VSgetCrossSectionCS(
								&rc,
								inp->elmEnv,
								bmSupps + 0,
								bmSupps + 1,
								0.0,
								&prflDef,
								prflCS ),
			senderid= NULL_OBJID,
			targetid= inp->elmId->objid,
			targetos= inp->elmId->osnum ) ;
	if( !( sts & 1 & rc ) ) goto wrapup ;

	xp[0] = prflCS[0] ; xp[1] = prflCS[4] ; xp[2] = prflCS[ 8] ;
	yp[0] = prflCS[1] ; yp[1] = prflCS[5] ; yp[2] = prflCS[ 9] ;
	zp[0] = prflCS[2] ; zp[1] = prflCS[6] ; zp[2] = prflCS[10] ;

	__DBGpr_vec( "X profile", xp ) ;
	__DBGpr_vec( "Y profile", yp ) ;
	__DBGpr_vec( "Z profile", zp ) ;

	if( zp[1] < 0 ) VSnegvc( zp, zp ) ;
	dir = VSgetDirType( zp ) ;

	switch( xData->parsedViewType ) {
		case VSfromTop		:
		case VSfromBottom	:
		__DBGpr_com( "Top/bottom" ) ;
		switch( dir ) {
			default			:
			case VShorizontal	:
				__DBGpr_com( "Horizontal Z" ) ;
				if( xp[1] > 0 ) *pfDir = ALONG_Y ;
				else		*pfDir = OPP_Y ;
				break ;
			case VSvertical		:
				__DBGpr_com( "Vertical Z" ) ;
				if( xp[0] > 0 ) *pfDir = ALONG_X ;
				else		*pfDir = OPP_X ;
				break ;
		}
		break ;
		case VSendOn		:
			if( xp[0] > 0 ) *pfDir = ALONG_X ;
			else		*pfDir = OPP_X ;
			break ;
		case VSfromSide		:
		switch( dir ) {
			default			:
			case VShorizontal	:
				if( xp[2] > 0 ) *pfDir = ALONG_Z ;
				else		*pfDir = OPP_Z ;
				break ;
			case VSvertical		:
				if( yp[2] > 0 ) *pfDir = ALONG_X ;
				else		*pfDir = OPP_X ;
				break ;
		}
		break ;
	}

	switch( *pfDir ) {
		case ALONG_X	: p = "+x" ;  break ;
		case OPP_X	: p = "-x" ;  break ;
		case ALONG_Y	: p = "+y" ;  break ;
		case OPP_Y	: p = "-y" ;  break ;
		case ALONG_Z	: p = "+z" ;  break ;
		case OPP_Z	: p = "-z" ;  break ;
		default		: p = ""   ; break ;
	}
	strcpy( pfDirASCII, p ) ;

	*msg = MSSUCC ;
	wrapup :
		return *msg & 1 ;

} /* VSfindProfileX */
/*----------------------------------------------------------------------------*/

end implementation VSbeam ;
