/* $Id: VSxycurvebox.C,v 1.1.1.1 2001/01/04 21:10:34 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/STRUCT
 *
 * File:        struct/vsdrawing/VSxycurvebox.C
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSxycurvebox.C,v $
 *      Revision 1.1.1.1  2001/01/04 21:10:34  cvs
 *      Initial import to CVS
 *
 * Revision 1.1  1998/04/30  10:08:06  pinnacle
 * STRUCT 2.5.1
 *
 * Revision 1.1  1997/05/08  14:03:58  pinnacle
 * Struct 250
 *
 * Revision 1.3  1996/01/31  07:09:40  pinnacle
 * Replaced: vsdrawing/VSxycurvebox.C for:  by svkadamb for struct
 *

 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *
 * -------------------------------------------------------------------*/

/*
	I/STRUCT
*/
#define _INGR_EXTENSIONS
#include <math.h>
#include <values.h>
#include "bserr.h"
#include "bstypes.h"
#include "bsconic.h"
#include "bsparameters.h"
#include "ma.h"
#include "msdef.h"
#include "vsdrw.h"
#include "vsgeommacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "maidmx.h"
#include "matrnmx.h"
#include "matypemx.h"
#include "mawclsmx.h"
#include "maxrotmx.h"
#include "bsbx2.h"
#include "bscrossp.h"
#include "bscveval.h"
#include "bsnorvec.h"
#include "vsvecmxproto.h"


#define COS45    (M_SQRT2/2.0)	/* Cos(  45 degrees ) */
#define COS135	( - COS45 )	/* Cos( 135 degrees ) */
#define _X	0
#define _Y	1
#define _Z	2
/*----------------------------------------------------------------------------*/
VSdirectionType VSgetDirType( dirVector ) IGRvector dirVector ; {
	/*
	 * `dirVector' is supposed to be
	 * - in the xy-plane
	 * - with a positive y
	 */
	IGRvector	dirUnit ;
	long		bsRC ;

	BSnorvec( &bsRC, VSvccpy( dirUnit, dirVector ) ) ;

	return dirUnit[_X] >= COS45 || dirUnit[_X] <= COS135 ? VShorizontal
							     : VSvertical ;
} /* VSgetDirType */
/*----------------------------------------------------------------------------*/
long VSfindBoxOfCvInXYPlane( msg, cvGeom, direction, bx )

long			*msg ;		/* OUT: Completion code		*/
struct IGRbsp_curve	*cvGeom ;	/* IN : Geometry of curve	*/
IGRvector		direction ;	/* IN : Direction of curve	*/
IGRpoint		bx[4] ; {	/* OUT: Box points of curve	*/

	int		i ;		/* Favorite loop index		*/
	short		_4	= 4,	/* For MAtrnmx			*/
			mxType ;	/* A matrix type		*/
	IGRmatrix	l2w,		/* Local-to-world matrix	*/
			w2l ;		/* World-to-local matrix	*/
	double		t ;		/* Parameter on curve		*/
	IGRpoint	strk[101],	/* Stroke points		*/
			lBx[4] ;	/* Box in local co-ordinates	*/
	IGRvector	orthodir,	/* Vector orth. to `direction'	*/
			vz ;		/* `orthodir' x `direction'	*/
	long		nPts ;		/* # of points - for BSbx2()	*/

	if( vs$is_curve_linear( msg = msg, curveGeom = cvGeom ) ) {
		/*
		 * Take end points (ordering using the value of y). If it's a
		 * point, all box points will be the same.
		 */
		double		*p1	= cvGeom->poles + 0,
				*p2	= cvGeom->poles + 3 ;

		if( p2[1] < p1[1] ) {
			double *tmp = p1 ; p1 = p2 ; p2 = tmp ;
		}

		VSvccpy( bx[0], p1 ) ;
		VSvccpy( bx[1], p2 ) ;
		VSvccpy( bx[2], p2 ) ;
		VSvccpy( bx[3], p1 ) ;
		goto wrapup ;
	}

	if( NULL == direction ) {
		for( i = 0 ; i <= 100 ; i++ ) {
			t = i * 0.01 ;
			BScveval( cvGeom, t, 0, (IGRpoint *) strk[i], msg ) ;
		}
		nPts = 101 ;
		BSbx2( msg, &nPts, strk, NULL, bx[0], bx[2] ) ;
		bx[1][0] = bx[2][0] ; bx[1][1] = bx[0][1] ; bx[1][2] = bx[0][2];
		bx[3][0] = bx[0][0] ; bx[3][1] = bx[2][1] ; bx[3][2] = bx[2][2];

		goto wrapup ;
	}

	/*
	 * Compute vector directly orthogonal to direction in xy-plane.
	 */
	orthodir[0] = -direction[1] ;
	orthodir[1] =  direction[0] ;
	orthodir[2] =  direction[2] ;

	BScrossp( msg, direction, orthodir, vz ) ;

	MAidmx( msg, l2w ) ;

	for( i = 0 ; i < 3 ; i++ ) {
		l2w[i*4+0] = direction[i] ;
		l2w[i*4+1] = orthodir [i] ;
		l2w[i*4+2] = vz[i] ;
	}
	MAtrnmx( msg, &_4, l2w, w2l  ) ;

	/*
	 * Note: `w2'l and `l2w' have the same matrix type.
	 */
	MAtypemx( msg, w2l, &mxType ) ;

	/*
	 * Align curve along `direction'.
	 */
	vs$xform_curve(	msg		= msg,
			mxType		= mxType,
			transMx		= w2l,
			curveGeom	= cvGeom ) ;

	/*
	 * Find smallest box (in fact a rectangle) encompassing curve. Do not
	 * use BSbx2 directly: it returns too big a box; first stroke curve
	 * and the apply BXbox2 to set of stroke points.
	 */
	for( i = 0 ; i <= 100 ; i++ ) {
		t = i * 0.01 ;
		BScveval( cvGeom, t, 0, (IGRpoint *) strk[i], msg ) ;
	}
	nPts = 101 ;
	BSbx2( msg, &nPts, strk, NULL, lBx[0], lBx[2] ) ;
	lBx[1][0] = lBx[2][0] ; lBx[1][1] = lBx[0][1] ; lBx[1][2] = lBx[0][2];
	lBx[3][0] = lBx[0][0] ; lBx[3][1] = lBx[2][1] ; lBx[3][2] = lBx[2][2];

	/*
	 * Map box to world co-ordinates.
	 */
	for( i = 0 ; i < 4 ; i++ ) {
		VSmxprodpt( l2w, lBx[i], bx[i] ) ;
	}

	/*
	 * Map curve back to world co-ordinates.
	 */
	vs$xform_curve(	msg		= msg,
			mxType		= mxType,
			transMx		= l2w,
			curveGeom	= cvGeom ) ;

	wrapup :
		*msg = MSSUCC ;
		return 1 ;

} /* VSfindBoxOfCvInXYPlane */
/*----------------------------------------------------------------------------*/
void VSgetJustPntsOfBlk( block, direction, justPnts )

IGRpoint	block[4] ;	/* IN : Box points of block	*/
IGRvector	direction ;	/* IN : Direction of block	*/
VSblkJustPnts	*justPnts ; {	/* OUT: Justification points	*/

	/*
	 * The input block and direction vector are supposed to be in the
	 * xy-plane.
	 * By convention, the x-axis points towards the "right" and the y-axis
	 * towards the "top".
	 * The points in the block are supposed to be ordered anti-clockwise:
	 *
	 *           3		The block may be rotated, nonetheless
	 *         /  \		two consecutive sides are orthogonal to
	 *        /    \	each other.
	 *       /      2
	 *      /      /
	 *	0     /
	 *	 \   /
	 *	  \ /
	 *	   1
	 *
	 * `direction' is supposed to be normalized and always point towards
	 * the "top" :
	 *                ^  ^
	 *   -> or <- or / or \
	 */

	double	*botLeft,
		*botRight,
		*topRight,
		*topLeft ;
	int	i ;

	       if( direction[0] >= COS45 ) { /* angle between    0 and  45 */
			botLeft	= block[0] ;
			botRight= block[1] ;
			topRight= block[2] ;
			topLeft = block[3] ;
	} else if( direction[0] >= COS135 ) { /* angle between  45 and 135 */
			botLeft	= block[3] ;
			botRight= block[0] ;
			topRight= block[1] ;
			topLeft = block[2] ;
	} else {			      /* angle between 135 and 180 */ 
			botLeft	= block[2] ;
			botRight= block[3] ;
			topRight= block[0] ;
			topLeft = block[1] ;
	}

	for( i = 0 ; i < 3 ; i++ ) {
		justPnts->BotLeft [i] = botLeft [i] ;
		justPnts->BotRight[i] = botRight[i] ;
		justPnts->TopRight[i] = topRight[i] ;
		justPnts->TopLeft [i] = topLeft [i] ;
		justPnts->BotMid  [i] = 0.5 * ( botLeft [i] + botRight[i] ) ;
		justPnts->TopMid  [i] = 0.5 * ( topLeft [i] + topRight[i] ) ;
		justPnts->RightMid[i] = 0.5 * ( botRight[i] + topRight[i] ) ;
		justPnts->LeftMid [i] = 0.5 * ( botLeft [i] + topLeft [i] ) ;
		justPnts->Center  [i] = 0.5 * ( botLeft [i] + topRight[i] ) ;
	}

} /* VSgetJustPntsOfBlk */
/*----------------------------------------------------------------------------*/
long VSfindEndPtsCvInXYPlane( msg, cvGeom, cvDir,
				endPt1, endPt2, endTn1, endTn2, swapped )

long			*msg ;		/* OUT: Completion code		*/
struct IGRbsp_curve	*cvGeom ;	/* IN : Geometry of curve	*/
VSdirectionType		cvDir ;		/* IN : Type of curve direction	*/
IGRpoint		endPt1,		/* OUT: First  end point	*/
			endPt2 ;	/* OUT: Second end point	*/
IGRvector		endTn1,		/* OUT: Tangent at 1st end point*/
			endTn2 ;	/* OUT: Tangent at 2nd end point*/
int			*swapped ; {	/* OUT: TRUE if 1st & 2d swapped*/

	/*
	 * Returns the end points of a curve in the xy-plane in an ordered
	 * fashion : the first end point of the curve is either the uppermost
	 * or the leftmost end point, depending upon the direction of the curve,
	 * likewise the second end point will either be the lowermost or the
	 * rightmost one. A tangent vector at each point is also returned such
	 * that :
	 * - it is normalized
	 * - it points away from the curve :
	 *
	 * for open curves :
	 *
	 *	        endPt1        endPt2
	 *	tan1 <--x----curve----x--> tan2
	 *
	 * for closed curves :
	 *
	 *	     endPt1 = endPt2
	 *	...---------x-------...
	 *          tan2 <-- --> tan1
	 */
	IGRpoint	evl[2][2] ;
	int		i1,
			i2 ;

#define PNT	0
#define TAN	1
#define _1ST	0
#define _2ND	1

	*swapped = FALSE ;

	if(    vs$is_curve_linear( msg = msg, curveGeom = cvGeom )
	    && VSeqPoints( cvGeom->poles + 0, cvGeom->poles + 3 ) ) {
		/*
		 * It's a point: put two horizontal and opposite tangents.
		 */

		VSvccpy( endPt2, VSvccpy( endPt1, cvGeom->poles + 0 ) ) ;
		endTn1[_X] = -( endTn2[_X] = 1 ) ;
		endTn1[_Y] = endTn2[_Y] = 0 ;
		endTn1[_Z] = endTn2[_Z] = 0 ;

	} else if( cvGeom->phy_closed ) { 
		/*
		 * Test this after the above since points are closed curves...
		 */
		BScveval( cvGeom, 0., 1, (IGRpoint *) evl[_1ST], msg ) ;
		VSvccpy( endPt2, VSvccpy( endPt1, evl[_1ST][PNT] ) ) ;
		BSnorvec( msg, VSvccpy( endTn2, evl[_1ST][TAN] ) ) ;
		VSnegvc( endTn2, endTn1 ) ;

	} else {
		BScveval( cvGeom, 0., 1, (IGRpoint *) evl[_1ST], msg ) ;
		BScveval( cvGeom, 1., 1, (IGRpoint *) evl[_2ND], msg ) ;

		/*
		 * Find first end point (either uppermost or leftmost).
		 */
		switch( cvDir ) {
			default			:
			case VShorizontal	: /* 1 = leftmost	*/

				if( evl[_1ST][PNT][_X] < evl[_2ND][PNT][_X] ) {
					i1 = _1ST ; i2 = _2ND ;
				} else {
					i1 = _2ND ; i2 = _1ST ;
				}
				break ;

			case VSvertical		: /* 1 = uppermost	*/

				if( evl[_1ST][PNT][_Y] < evl[_2ND][PNT][_Y] ) {
					i1 = _2ND ; i2 = _1ST ;
				} else {
					i1 = _1ST ; i2 = _2ND ;
				}
				break ;
		}
		VSvccpy( endPt1, evl[i1][PNT] ) ;
		VSvccpy( endPt2, evl[i2][PNT] ) ;
		BSnorvec( msg, VSvccpy( endTn1, evl[i1][TAN] ) ) ;
		BSnorvec( msg, VSvccpy( endTn2, evl[i2][TAN] ) ) ;

		if( _1ST == i1 ) {
			VSnegvc( endTn1, endTn1 ) ;
		} else {
			VSnegvc( endTn2, endTn2 ) ;
		}
		*swapped = _2ND == i1 ;
	}

	*msg = MSSUCC ;

	return *msg & 1 ;

} /* VSfindEndPtsCvInXYPlane */
/*----------------------------------------------------------------------------*/
long VSfindMidPtCvInXYPlane( msg, cvGeom, midPt, midTn )

long			*msg ;		/* OUT: Completion code		*/
struct IGRbsp_curve	*cvGeom ;	/* IN : Geometry of curve	*/
IGRpoint		midPt ;		/* OUT: Mid point of curve	*/
IGRvector		midTn ; {	/* OUT: Tangent at mid point	*/

	IGRpoint	evl[2] ;

	/*
	 * Returns the mid point of a curve in the xy-plane as well as
	 * a tangent vector at the midpoint such that :
	 * - it is normalized
	 * - it points "upwards" (towards the positive y's )
	 */
	if(    vs$is_curve_linear( msg = msg, curveGeom = cvGeom )
	    && VSeqPoints( cvGeom->poles + 0, cvGeom->poles + 3 ) ) {
		/*
		 * It's a point: put one horizontal tangent.
		 */
		VSvccpy( midPt, cvGeom->poles + 0 ) ;
		midTn[_X] = 1 ; midTn[_Y] = midTn[_Z] = 0 ;
	} else {
		BScveval( cvGeom, 0.5, 1, (IGRpoint *) evl, msg ) ;

		VSvccpy( midPt, evl[PNT] ) ;
		BSnorvec( msg, VSvccpy( midTn, evl[TAN] ) ) ;

		if( evl[TAN][_Y] < 0 ) VSnegvc( midTn, midTn ) ;
	}

	*msg = MSSUCC ;
	return *msg & 1 ;

} /* VSfindMidPtCvInXYPlane */
/*----------------------------------------------------------------------------*/

