/*
	I/STRUCT
*/
class implementation VSplate ;

#include <string.h>
#include <math.h>
#include "bserr.h"
#include "bsparameters.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"
#include "vsdrwdef.h"
#include "vsdrw.h"
#include "vsglobalmsg.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "bsdotp.h"
#include "bsorthovec.h"
#include "vsdrwproto.h"
#include "vsvecmxproto.h"

#define ALONG_X	1
#define ALONG_Y	2
#define ALONG_Z	3
#define OPP_X	(-1)
#define OPP_Y	(-2)
#define OPP_Z	(-3)
/*----------------------------------------------------------------------------*/
long VSfindPlateX( msg, inp, xData, plDir, plDirASCII )

long		     *msg ;		/* OUT: Completion code		     */
const VSdrwInputData *inp ;		/* IN : Data input to interpreter    */
const VSdrwExecData  *xData ;		/* IN : Data modified by interpreter */
int		     *plDir ;		/* OUT: Direction of plate	     */
char		     plDirASCII[3]; {	/* OUT: Direction of plate (string)  */

	/*
	 * This function implements the Drawing Extraction language function
	 * "plate-direction()".
	 * It returns the side of the drawing sheet towards which the matter of
	 * the plate is. This side is determined with respect to the graphic
	 * object representing the plate on the drawing sheet, for instance
	 * if the edge of the bottom of plate is drawn on the drawing sheet:
	 *
	 * Model				Drawing sheet	x
	 *							^
	 * +---------------------+				|
	 * |                     |				---> y
	 * +---------------------+		-----------------------
	 *
	 * Above the matter is towards "+x".
	 * We have four cases to handle corresponding on how the plate was
	 * extracted :
	 * 1 "projection"	: project plate onto drawing sheet
	 * 2 "intersection"	: intersect plate and plane of view then project
	 * 	                  intersection onto drawing sheet.
	 * 3 "contour"		: draw contour of plate onto drawing sheet
	 * 4 "edge"		: draw edge of plate onto drawing sheet
	 *
	 * 1 and 3 are similar (contour is like projection but disregards
	 * possible holes in the plate).
	 * 2 and 4 are similar since projections of edges of the bottom side
	 * of the plate (2) or projections of the intersection of the bottom
	 * side of the plate with the view plane are returned.
	 * For 1 and 3 the direction can only be "+z" or "-z" (the plate is
	 * seen from front).
	 * For 2 and 4 the direction can only be "+x", "-x", "+y", "-y" (the
	 * plate is seen from the side).
	 *
	 * Remember that the drawing plane is normal to the z-axis of the global
	 * coordinate system.
	 */

	long		sts ;		/* OM return code		*/
	IGRvector	nrmlToSide,	/* Normal to bottom side	*/
			pjOfNrml,	/* Projection of normal		*/
			vcInDrwPlane ;	/* A vector in the drawing plane*/
	char		*p ;		/* A utility pointer		*/

	*msg = MSFAIL ;
	*plDirASCII = '\0' ;

	/*
	 * Input element must be a plate.
	 */
	if( xData->parsedElmType != VS_gI_Plate ) goto wrapup ;

	sts = om$send( msg	= message VSfeature.VSgetNormalOfComponent(
					msg, inp->elmEnv, VS_K_plBotSfPath,
					0.5, 0.5, nrmlToSide ),
		       senderid = inp->elmId->objid,
		       targetid = inp->elmId->objid,
		       targetos = inp->elmId->osnum ) ;
	__CheckRC( sts, *msg, "VSfeature.VSgetNormalOfComponent", wrapup ) ;

	switch( inp->viewType ) {

		default			: /* Should never get here */
		case VSunknownViewType	:
/* ALAIN
/*			 * Decide according to choice of graphic output.
/*			switch( xData->graphicType ) {
/*				case VSdrwProjection	:
/*				case VSdrwContour	: goto FROM_SIDE ;
/*				case VSdrwIntersection	:
/*				case VSdrwEdge		: goto FROM_TOP_BOT ;
/*				default			:
/*					/* Should not get here */
/*					goto wrapup ;
/*			}
/* */
			goto wrapup ;
			break ;

		case VSfromTop		:
		case VSfromBottom	:
		FROM_TOP_BOT		:
			/*
			 * Get any vector in the drawing plane and project
			 * the normal to the bottom side of the plate onto
			 * a plane orthogonal to the drawing plane (ie.
			 * orthogonal to the vector in the drawing plane) along
			 * the view vector.
			 */
			if(  VScolinearVectors( inp->drwInfo.drwPlane->normal,
					        inp->drwInfo.viewVector ) ) {
				*plDir = BSdotp( msg,
						 nrmlToSide,
						 inp->drwInfo.drwPlane->normal )
					  >= 0 ? ALONG_Z : OPP_Z ;
				
			} else {
				BSorthovec(	msg,
						inp->drwInfo.drwPlane->normal,
						vcInDrwPlane ) ;
				if( !VSpjVcOnPlAlongVc(	nrmlToSide,
							vcInDrwPlane,
							inp->drwInfo.viewVector,
							pjOfNrml ) )
					goto wrapup ;
				*plDir = pjOfNrml[2] >= 0 ? ALONG_Z : OPP_Z ;
			}
			break ;

		case VSfromSide		:
		FROM_SIDE		:
			/*
			 * Project normal to bottom side of plate onto drawing
			 * sheet along view vector.
			 */
			if( !VSpjVcOnPlAlongVc(	nrmlToSide,
						inp->drwInfo.drwPlane->normal,
						inp->drwInfo.viewVector,
						pjOfNrml ) ) goto wrapup ;
			switch( VSgetDirType( pjOfNrml ) ) {
				case VShorizontal	:
					*plDir = pjOfNrml[0] >= 0 ? ALONG_X
								  : OPP_X ;
					break ;
				case VSvertical		:
					*plDir = pjOfNrml[1] >= 0 ? ALONG_Y
								  : OPP_Y ;
					break ;
			}
			break ;
	}

	switch( *plDir ) {
		case ALONG_X	: p = "+x" ;  break ;
		case OPP_X	: p = "-x" ;  break ;
		case ALONG_Y	: p = "+y" ;  break ;
		case OPP_Y	: p = "-y" ;  break ;
		case ALONG_Z	: p = "+z" ;  break ;
		case OPP_Z	: p = "-z" ;  break ;
		default		: p = ""   ;  break ;
	}

	strcpy( plDirASCII, p ) ;
	*msg = MSSUCC ;

	wrapup :
		return *msg & 1 ;

} /* VSfindPlateX */
/*----------------------------------------------------------------------------*/

end implementation VSplate ;

