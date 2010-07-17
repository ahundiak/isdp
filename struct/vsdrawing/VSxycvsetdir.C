/* $Id: VSxycvsetdir.C,v 1.1.1.1 2001/01/04 21:10:35 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/STRUCT
 *
 * File:        struct/vsdrawing/VSxycvsetdir.C
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSxycvsetdir.C,v $
 *      Revision 1.1.1.1  2001/01/04 21:10:35  cvs
 *      Initial import to CVS
 *
 * Revision 1.2  1998/08/07  17:33:58  pinnacle
 * Replaced: vsdrawing/VSxycvsetdir.C for:  by mdong for struct
 *
 * Revision 1.1  1998/04/30  10:08:06  pinnacle
 * STRUCT 2.5.1
 *
 * Revision 1.1  1997/05/08  14:03:58  pinnacle
 * Struct 250
 *
 * Revision 1.2  1996/01/31  07:14:14  pinnacle
 * Replaced: vsdrawing/VSxycvsetdir.C for:  by svkadamb for struct
 *
 *
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      07/29/98	Ming		TR179801167
 *
 * -------------------------------------------------------------------*/
#include <stdio.h>
#include <stdlib.h>
#define _INGR_EXTENSIONS
#include <math.h>
#include <values.h>
#include "bserr.h"
#include "msdef.h"
#include "EMSmsgdef.h"
#include "vsdpb.h"
#include "vsdrw.h"
#include "vsgeommacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "bsarclength.h"
#include "bscveval.h"
#include "vsdrwproto.h"
#include "vsvecmxproto.h"
/*----------------------------------------------------------------------------*/
long VSfindDirOfSetOfCurvesInXYPlane( msg, cvCount, cvGeoms, setDir, noDir )

long			*msg ;		/* OUT: Completion code		*/
int			cvCount ;	/* IN : Count of input curves	*/
struct IGRbsp_curve	*cvGeoms[] ;	/* IN : Geoms of input curves	*/
IGRvector		setDir ;	/* OUT: Direction of curves	*/
int			*noDir ; {	/* OUT: TRUE(= no dir)/FALSE	*/

	/*
	 * Finds the direction of a set of curves lying in the xy-plane.
	 * The curve set is first split between "horizontal" and "vertical"
	 * curve, the the respective weight of each subset is computed
	 */
	int		i ;		/* Loop-on-geometries index	*/
	IGRvector	dir,		/* Directions of one curve	*/
			dirH,
			dirV ;
	double		length,		/* Lengths of one curve		*/
			HtotLen,	/* Tot. length of horizontal cvs*/
			VtotLen,	/* Tot. length of vertical   cvs*/
			HmaxLen,	/* Greatest horiz. curve length	*/
			VmaxLen,	/* Greatest vert. curve length	*/
			t0 = 0.,	/* Sart parameter		*/
			t1 = 1. ;	/* End parameter		*/
	VSdirectionType	dType ;		/* Dir. type of one curve 	*/

	if( 1 == cvCount ) {
		return VSfindDirOfCvInXYPlane( msg, cvGeoms[0], setDir, noDir );
	}

	VSzerovc( setDir ) ;

	HmaxLen = VmaxLen = HtotLen = VtotLen = 0 ;

	for( i = 0 ; i < cvCount ; i++ ) {

		VSfindDirOfCvInXYPlane( msg, cvGeoms[i], dir, noDir ) ;
		if( *noDir ) {
			dir[0] = 1 ; dir[1] = dir[2] = 0 ;
		}
		dType = VSgetDirType( dir ) ;

		BSarclength( msg, cvGeoms[i], &t0, &t1, &length ) ;

		switch( dType ) {
			case VShorizontal	:
				HtotLen += length ;
				if( HmaxLen < length ) {
					HmaxLen = length ;
					VSvccpy( dirH, dir ) ;
				}
				break ;
			case VSvertical		:
				VtotLen += length ;
				if( VmaxLen < length ) {
					VmaxLen = length ;
					VSvccpy( dirV, dir ) ;
				}
				break ;
		}
	}

	if( VSzeroDist( HtotLen ) || VSzeroDist( VtotLen ) ) {
		*noDir = TRUE ;
	} else {
		*noDir = FALSE ;	
		if( VtotLen > HtotLen ) {
			VSvccpy( setDir, dirV ) ;
		} else {
			VSvccpy( setDir, dirH ) ;
		}
	}

	*msg = MSSUCC ;

	return *msg & 1 ;

} /* VSfindDirOfSetOfCurvesInXYPlane */
/*----------------------------------------------------------------------------*/
long VSfindXMostCurve( msg, loc, cvCount, cvGeoms, index )

long			*msg ;		/* OUT: Completion code		*/
VSdrwTxLoc		loc ;		/* IN : Top, bottom, left, right*/
int			cvCount ;	/* IN : Count of input curves	*/
struct IGRbsp_curve	*cvGeoms[] ;	/* IN : Geoms of input curves	*/
int			*index ; {	/* OUT: Index of "X" most curve	*/

	/*
	 * Finds <X>most ( <X> = upper, lower, left, right ) curve among a set
	 * of curves all supposed to lie in the xy-plane.
	 */
	IGRpoint	pnt ;		/* Stroke point			*/
	int		i,		/* Loop-on-curves index		*/
			ixmost = 0,	/* Index of <X>most curve	*/
			j ;		/* Loop-on-points index		*/
	double		t,		/* Parameter on curve		*/
			maxCoord ;
        IGRvector       cvDir, dir;
        int             hasNoDir;
        VSdirectionType cvDirType, dType;

	switch( loc ) {
		default		:
		case VStop	:
		case VSright	: maxCoord = - MAXDOUBLE ; break ;
		case VSbottom	:
		case VSleft	: maxCoord =   MAXDOUBLE ; break ;
	}

        /* TR179801167 by Ming */
        VSfindDirOfSetOfCurvesInXYPlane( msg,
                                         cvCount,
                                         cvGeoms,
                                         cvDir,
                                         &hasNoDir );
        cvDirType = VSgetDirType( cvDir ) ;

	for( i = 0 ; i < cvCount ; i++ ) {

		/* TR179801167 by Ming */
          	VSfindDirOfCvInXYPlane( msg, cvGeoms[i], dir, &hasNoDir ) ;
          	if( hasNoDir )
          	{
            	  dir[0] = 1 ; dir[1] = dir[2] = 0 ;
          	}
          	dType = VSgetDirType( dir ) ;

          	if( dType != cvDirType ) continue;

		for( j = 0 ; j <= 100 ; j++ ) {
			t = j * 0.01 ;
			BScveval( cvGeoms[i], t, 0, (IGRpoint *) pnt, msg ) ;
			switch( loc ) {
				default		:
				case VStop	:
					if( pnt[1] > maxCoord ) {
						maxCoord = pnt[1] ;
						ixmost = i ;
					}
					break ;
				case VSright	:
					if( pnt[0] > maxCoord ) {
						maxCoord = pnt[0] ;
						ixmost = i ;
					}
					break ;
				case VSbottom	:
					if( pnt[1] < maxCoord ) {
						maxCoord = pnt[1] ;
						ixmost = i ;
					}
					break ;
				case VSleft	:
					if( pnt[0] < maxCoord ) {
						maxCoord = pnt[0] ;
						ixmost = i ;
					}
					break ;
			}
		}
	}

	*msg = MSSUCC ;
	*index = ixmost ;

	return *msg & 1 ;

} /* VSfindXMostCurve */
/*----------------------------------------------------------------------------*/
long VSfindCenterOfSetOfCurvesInXYPlane( msg, cvCount, cvGeoms, center )

long			*msg ;		/* OUT: Completion code		*/
int			cvCount ;	/* IN : Count of input curves	*/
struct IGRbsp_curve	*cvGeoms[] ;	/* IN : Geoms of input curves	*/
IGRpoint		center ; {	/* OUT: Center of curves	*/

	/*
	 * Finds the center of set of curves all supposed to lie in the 
	 * xy-plane.
	 */
	IGRpoint	pnt ;		/* Stroke point			*/
	int		i,		/* Loop-on-curves index		*/
			j,		/* Loop-on-points index		*/
			k,		/* Loop-on-coordinates index	*/
			n ;		/* Number of points		*/
	double		t ;		/* Parameter on curve		*/

	n = 0 ; VSzerovc( center ) ;
	for( i = 0 ; i < cvCount ; i++ ) {
		for( j = 0 ; j <= 100 ; j++ ) {
			t = j * 0.01 ;
			BScveval( cvGeoms[i], t, 0, (IGRpoint *) pnt, msg ) ;
			for( k = 0 ; k < 3 ; k++ ) {
				center[k] += pnt[k] ;
			}
			n++ ;
		}
	}
	for( k = 0 ; k < 3 ; k++ ) {
		center[k] /= n ;
	}

	*msg = MSSUCC ;
	return *msg & 1 ;

} /* VSfindCenterOfSetOfCurvesInXYPlane */
/*----------------------------------------------------------------------------*/

