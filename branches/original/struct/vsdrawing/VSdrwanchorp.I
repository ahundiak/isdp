/*
	I/STRUCT
*/
class implementation ACncpx ;

#include <string.h>
#include <stdio.h>
#include <malloc.h>
#include "dp.h"
#include "godef.h"
#include "go.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "growner.h"
#include "fontdef.h"
#include "font.h"
#include "EMSmsgdef.h"
#include "vsdef.h"
#include "vsslcdef.h"
#include "vsslc.h"
#include "vsdrwdef.h"
#include "vsdrw.h"
#include "VSdrwgrammar.h"
#include "vsmeasmacros.h"
#include "vsdatamacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"

/*
 * Includes of function prototypes.
 */
#include "maptplpro.h"
#include "vsdrwproto.h"
#include "vsvecmxproto.h"

from GRcurve	import GRendpts ;
/*----------------------------------------------------------------------------*/
int VSdrwAnchorPoint( msg, inp, xData, member, whichPoint )

long			*msg ;	      /* OUT: Completion code		     */
const VSdrwInputData	*inp ;	      /* IN : Data input to interpreter	     */
VSdrwExecData		*xData ;      /* I/O: Data modified during execution */
const char		*member ;     /* IN : Name of member of macro occ.   */
VSdrwAnchorType		whichPoint ; {/* IN : Which point to use 	     */

/*
 *	Which-point not specified in the setup file : `whichPoint' defaulted
 *	to `VSdrwAnchorCtrOfBox' ( corresponding to 'average-point' ) meaning
 *	center of range box.
 *
 *	a) If which-point is not specified or is 'average-point' the following
 *	   will be done :
 *	- the range of the member will be computed
 *	- the center of the range box will be projected onto the
 *	  drawing sheet and will be taken as the anchor point
 *
 *	This behavior above will of course give the expected result if the
 *	member is a point or a coordinate system since their range boxes are
 *	reduced to a point.
 *
 *	b) If which-point is 'center' :
 *	- if member is a closed curve, its center will be computed and then
 *	  projected onto the drawing sheet, if it is not closed its mid-point
 *	  will be used.
 *	- if member is a point (or a coordinate system) the point (or the
 *	  origin) will be projected onto the drawing sheet.
 *	- if member is a surface, the point at u=0.5, v=0.5 will be projected
 *	  onto the drawing sheet.
 *	- if member is a solid or a composite surface, the center of the range
 *	  box will be used as in a)
 *
 *	c) If which-point is 'center-of-gravity'
 *	- member is a point : use point as in a)
 *	- member is a coordinate system : use origin as in a)
 *	- member is a curve : use center as in b)
 *	- member is a surface or a solid : use center of gravity.
 *
 */
	long			sts ;		/* Return status	*/
	struct GRid		memberId ;	/* Id of member		*/
	struct GRmd_env		memberEnv ;	/* Mod. env. of member	*/
	struct GRprops		gprops ;	/* Geom. props. of memb.*/
	int			gtype ;		/* Graphic type of memb.*/
	GRrange			memberRng ;	/* Range of member	*/
	IGRboolean		world = TRUE ;	/* For GRgetrang	*/
	IGRpoint		pnt ;		/* Anchor before proj.	*/

	if( !*member ) {
		if( xData->verbose ) {
			VSdrwPrintf( "!!! Empty member for anchor point\n" ) ;
		}
		vs$inv_arg() ;
	}
	/*
	 * Get id of member to be used to evaluate the anchor point.
	 */
	sts = om$send(	msg	= message NDmacro.ACreturn_foot(
						msg,
						(char*) member,
						&memberId,
						&memberEnv._MATRIX_TYPE,
						memberEnv._MATRIX ),
			senderid= inp->elmId->objid,
			targetid= inp->elmId->objid,
			targetos= inp->elmId->osnum ) ;
	if( !( sts & 1 & *msg ) ) {
		if( xData->verbose ) {
			VSdrwPrintf( "!!! Cannot find '%s' in const '%s'\n",
					member, inp->constDefName ) ;
		}
		goto wrapup ;
	}

	VSmulmx( inp->elmEnv->_MATRIX, memberEnv._MATRIX, memberEnv._MATRIX,
		 &memberEnv._MATRIX_TYPE ) ;

	memberEnv.md_id = inp->elmEnv->md_id ;

	sts = om$send(	msg	= message GRvg.GRgeomprops(
							msg,
							&memberEnv._MATRIX_TYPE,
							memberEnv._MATRIX,
							&gprops ),
			senderid= memberId.objid,
			targetid= memberId.objid,
			targetos= memberId.osnum ) ;
	__CheckRC( sts, *msg, "GRvg.GRgeomprops", wrapup ) ;

	switch( gprops.type ) {
		case GRCURVE	:
			gtype =    gprops.subtype == GRLN
			        && gprops.phy_closed	  ? VS_K_POINTtype
			        			  : VS_K_CURVEtype ;
			break ;
		
		case GRSURFACE	:
			gtype = gprops.subtype == GRSS	? VS_K_SURFACEtype
							: VS_K_SOLIDtype ;
			break ;

		case GRLBSYS	: gtype = VS_K_POINTtype ; break ;
		default		: gtype = VS_K_POINTtype ; break ;
	}

	switch( gtype ) {

		case VS_K_CURVEtype	:

		if( whichPoint == VSdrwAnchorCtrOfBox ) goto USE_RANGE ;
		if( gprops.phy_closed ) {
			sts = om$send(	msg	= message GRvg.GRcenter(
							msg,
							&memberEnv._MATRIX_TYPE,
							memberEnv._MATRIX,
							pnt ),
					senderid= memberId.objid,
					targetid= memberId.objid,
					targetos= memberId.osnum ) ;
			__CheckRC( sts, *msg, "GRvg.GRcenter", wrapup ) ;
		} else {
			IGRpoint	pt1,
					pt2 ;
			sts = om$send(	msg	= message GRcurve.GRendpts(
							msg,
							&memberEnv._MATRIX_TYPE,
							memberEnv._MATRIX,
							pt1,
							pt2 ),
					senderid= memberId.objid,
					targetid= memberId.objid,
					targetos= memberId.osnum ) ;
			__CheckRC( sts, *msg, "GRcurve.GRendpts", wrapup ) ;
			VSmidpoint( pt1, pt2, pnt ) ;
		}
		break ;

		case VS_K_SURFACEtype	:

		if( whichPoint == VSdrwAnchorCtrOfGrv ) {
			sts = vs$get_area_props(	msg	= msg,
							surfId	= &memberId,
							surfEnv	= &memberEnv,
							centroid= pnt ) ;
			__CheckRC( sts, *msg, "vs$get_area_props", wrapup ) ;

		} else if( whichPoint == VSdrwAnchorCenter ) {
			double	UV[2] ;

			UV[0] = UV[1] = 0.5 ;
			sts = om$send(	msg	= message GRvg.EMptatpr(
							msg,
							&memberEnv._MATRIX_TYPE,
							memberEnv._MATRIX,
							UV,
							2,
							pnt ),
					senderid= memberId.objid,
					targetid= memberId.objid,
					targetos= memberId.osnum ) ;
			__CheckRC( sts, *msg, "GRvg.EMptatpr", wrapup ) ;
        	} else goto USE_RANGE ;
		break ;
			

		case VS_K_SOLIDtype	:
		case VS_K_POINTtype	:
		USE_RANGE		:

		sts = om$send(	msg	= message GRgraphics.GRgetrang(
							msg,
							&memberEnv._MATRIX_TYPE,
							memberEnv._MATRIX,
							&world,
							memberRng ),
				senderid= memberId.objid,
				targetid= memberId.objid,
				targetos= memberId.osnum ) ;
		__CheckRC( sts, *msg, "GRgraphics.GRgetrang", wrapup ) ;
		VSmidpoint( memberRng + 0, memberRng + 3, pnt ) ;
		break ;

	}
	wrapup :
		if( !( sts & 1 & *msg ) ) {
			pnt[0] = pnt[1] = pnt[2] = 0. ;
		}
		/*
		 * Project point onto drawing sheet.
		 */
		MAptplproj(	msg,
				(IGRpoint *) pnt,
				inp->drwInfo.drwPlane,
				xData->anchorPoint ) ;
		xData->txPosHelper = VSuseAnchorPoint ;

		return OM_S_SUCCESS ;

} /* VSdrwAnchorPoint */
/*----------------------------------------------------------------------------*/

end implementation ACncpx ;

