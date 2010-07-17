/*
	I/STRUCT
*/
#include <stdio.h>
#include <float.h>
#include "OMerrordef.h"
#include "OMprimindex.h"
#include "OMprimitives.h"
#include "msdef.h"
#include "EMSmsgdef.h"
#include "vssectiondef.h"
#include "vsxsfrpldef.h"
#include "vsxsfrpl.h"
#include "vsdatamacros.h"
#include "VDobj.h"
#include "vsdbgmacros.h"
/*
 * Include of function prototypes.
 */
#include "vsfnditmary.h"
/*----------------------------------------------------------------------------*/
#ifdef vsDEBUG
void VSdump2dPt( t, p ) char *t ; VS2dPoint *p ; {
	printf( "\t%s : x %g y %g\n", t, p->x, p->y ) ;
} /* VSdump2dPt */
#endif
/*----------------------------------------------------------------------------*/
double VSsqDist2dPts( p1, p2 ) VS2dPoint *p1, *p2 ; {
	double	dx = p2->x - p1->x,
		dy = p2->y - p1->y ;

	return dx * dx + dy * dy ;

} /* VSsqDist2dPts */
/*----------------------------------------------------------------------------*/
void VSgetContourRange( contour, range )

VSxsPlContour	*contour ;
VS2dPoint	range[2] ; {

	double	xmin, xmax,
		ymin, ymax,
		x,
		y ;
	int	i ;

	xmin = ymin =  DBL_MAX ;
	xmax = ymax = -DBL_MAX ;

	for( i = 0 ; i < contour->npoints ; i++ ) {
		x = contour->points[i].coord.x ;
		y = contour->points[i].coord.y ;
		if( x < xmin ) xmin = x ;
		if( x > xmax ) xmax = x ;
		if( y < ymin ) ymin = y ;
		if( y > ymax ) ymax = y ;
	}

	range[0].x = xmin ; range[0].y = ymin ;
	range[1].x = xmax ; range[1].y = ymax ;

#ifdef vsDEBUG
	VSdump2dPt( "RANGE PT 0", range + 0 ) ;
	VSdump2dPt( "RANGE PT 1", range + 1 ) ;
#endif

} /* VSgetContourRange */
/*----------------------------------------------------------------------------*/
void VStranslateContour( trans, contour )

VS2dPoint	*trans ;
VSxsPlContour	*contour ; {

	int i ;

	for( i = 0 ; i < contour->npoints ; i++ ) {
		contour->points[i].coord.x += trans->x ;
		contour->points[i].coord.y += trans->y ;
	}
	
} /* VStranslateContour */
/*----------------------------------------------------------------------------*/
#ifdef vsDEBUG
void VSdumpContour( contour ) VSxsPlContour *contour ; {

	int		i ;
	VS2dPoint	range[2],
			trans ;
	char		t[50] ;
	VSxsPlContour 	tmp_contour ;

	tmp_contour = *contour ;

	VSgetContourRange( &tmp_contour, range ) ;

	trans.x = 0 - range[0].x ;
	trans.y = 0 - range[0].y ;

	VStranslateContour( &trans, &tmp_contour ) ;

	for( i = 0 ; i < tmp_contour.npoints ; i++ ) {
		sprintf( t, "Contour pt %d [%c]", i, 'a' + i ) ;
		VSdump2dPt( t, &tmp_contour.points[i].coord ) ;
	}


	for( i = 0 ; i < tmp_contour.nfrontiers ; i++ ) {
		printf( "Frontier %d\n", i ) ;
		printf( "\t 1- pl %d pt %d -- pl %d pt %d\n",
			tmp_contour.frontier[i][0][0].plateNo,
			tmp_contour.frontier[i][0][0].pointNo,
			tmp_contour.frontier[i][0][1].plateNo,
			tmp_contour.frontier[i][1][1].pointNo ) ;
		printf( "\t 2- pl %d pt %d -- pl %d pt %d\n",
			tmp_contour.frontier[i][1][0].plateNo,
			tmp_contour.frontier[i][1][0].pointNo,
			tmp_contour.frontier[i][1][1].plateNo,
			tmp_contour.frontier[i][1][1].pointNo ) ;
	}

} /* VSdumpContour */
#endif
/*----------------------------------------------------------------------------*/
void VSlog2coord( origin, pDefs, logPnt, coordPnt )

VSxsPlateDef	*pDefs ;
VSlog2dPnt	*logPnt ;
VS2dPoint	*origin,
		*coordPnt ; {

	VSxsPlateDef	*p = pDefs + logPnt->plateNo ;
	double		dx,
			dy ;

	switch( p->type ) {
	default			: /* Should not get here */
	case VS_K_HORIZONTAL	: dx = p->length ; dy = p->thickness ; break ;
	case VS_K_VERTICAL	: dy = p->length ; dx = p->thickness ; break ;
	}

	*coordPnt = *origin ;

	switch( logPnt->pointNo ) {
		case VS_K_BL : break ;
		case VS_K_TL : coordPnt->y += dy ; break ;
		case VS_K_BR : coordPnt->x += dx ; break ;
		case VS_K_TR : coordPnt->x += dx ; coordPnt->y += dy ; break ;
	}

} /* VSlog2coord */
/*----------------------------------------------------------------------------*/
void VSgetCoordCorners( origin, pdefs, plIndex, corners )

int		plIndex ;
VS2dPoint	*origin ;
VSxsPlateDef	*pdefs ;
VScontourPnt	corners[VS_K_NBCORNERS] ; {

	int i ;

	for( i = 0 ; i < VS_K_NBCORNERS ; i++ ) {
		corners[i].log.plateNo = plIndex ;
	}
	corners[0].log.pointNo = VS_K_BL ;
	corners[1].log.pointNo = VS_K_BR ;
	corners[2].log.pointNo = VS_K_TR ;
	corners[3].log.pointNo = VS_K_TL ;

	for( i = 0 ; i < VS_K_NBCORNERS ; i++ ) {
		VSlog2coord( origin, pdefs, &corners[i].log, &corners[i].coord ) ;
	}
} /* VSgetCoordCorners */
/*----------------------------------------------------------------------------*/
void VSfindConnections( pdefs, i1, i2, plcn, plInfos )

VSxsPlateDef	*pdefs ;
int		i1,
		i2 ;
VSxsPlConn	*plcn ;
VSxsPlInfo	*plInfos ; {


	/*
	 * Plate #2 is positionned wrt plate #1.
	 * We suppose that plate lengths are bigger than thicknesses.
	 */
	VSxsPlateDef	*pdef1 = pdefs + i1,
			*pdef2 = pdefs + i2 ;
	VS2dPoint	origin ;

	/*
	 * Set origin to bottom left corner of plate #1 (that at index `i1').
	 */
	origin = plInfos[i1].corners[0].coord ;

	switch( pdef1->type ) {

	case VS_K_HORIZONTAL	:
		switch( plcn->side1 ) {

		case VS_K_TOP	:
			/*
			 * 	  +-+
			 *	  |2|		     +------+
			 *	  | |		     |2     |
			 *   <off>O-+		<off>O------+
			 *   +--------+		+--------+
			 *   |1       |		|1       |
			 *   +--------+		+--------+ (unlikely case)
			 */
			if( pdef2->type == VS_K_VERTICAL ) {
				origin.x += plcn->offset ;
				origin.y += pdef1->thickness ;
			} else {
				origin.x += plcn->offset ;
				origin.y += pdef1->thickness ;
			}
			break ;

		case VS_K_BOTTOM:
			/*
			 *   +--------+		+--------+
			 *   |1       |		|1       |
			 *   +--------+		+--------+ (unlikely case)
			 *   <off>+-+		<off>+------+
			 *	  |2|		     |2	    |
			 *	  | |		     O------+
			 * 	  O-+
			 */
			if( pdef2->type == VS_K_VERTICAL ) {
				origin.x += plcn->offset ;
				origin.y -= pdef2->length ;
			} else {
				origin.x += plcn->offset ;
				origin.y -= pdef2->thickness ;
			}
			break ;

		case VS_K_LEFT	:
			/*
			 * +-+					  +--------+
			 * |2|+--------+		+--------+|1       |
			 * | ||1       |		|2       |+--------+
			 * | |+--------+		O--------+X Off
			 * | |^				(unlikely case)
			 * O-+v
			 *
			 */
			if( pdef2->type == VS_K_VERTICAL ) {
				origin.x -= pdef2->thickness ;
				origin.y += plcn->offset ; /* offset < 0 */
			} else {
				origin.x -= pdef2->length ;
				origin.y += plcn->offset ; /* offset < 0 */
			}
			break ;

		case VS_K_RIGHT	:
			/*	     +-+
			 * +--------+|2|		+--------+
			 * |1       || |		|1       |+--------+
			 * +--------+| |		+--------+|2       |
			 *          ^| |		     Off XO--------+
			 *        off| |		(unlikely case)
			 *	    vO-+
			 */
			if( pdef2->type == VS_K_VERTICAL ) {
				origin.x += pdef1->length ;
				origin.y += plcn->offset ; /* offset < 0 */
			} else {
				origin.x += pdef1->length ;
				origin.y += plcn->offset ; /* offset < 0 */
			}
			break ;
		}
		break ;

	case VS_K_VERTICAL	:

		switch( plcn->side1 ) {

		case VS_K_BOTTOM:
 			/*
 			 *	+-+		 +-+
 			 *	|1|		 |1|
 			 *	| |		 | |
 			 * <off>+-+	    Off	X+-+
 			 * +---------+		+-+   (unlikely case)
 			 * |2	     |		|2|
 			 * O---------+		O-+  
 			 */
			if( pdef2->type == VS_K_HORIZONTAL ) {
				origin.x += plcn->offset ; /* offset < 0 */
				origin.y -= pdef2->thickness ;
			} else {
				origin.x += plcn->offset ; /* offset < 0 */
				origin.y -= pdef2->length ;
			}
			break ;

		case VS_K_TOP	:
 			/*
 			 * +---------+		+-+
 			 * |2	     |		|2|
 			 * O---------+		O-+
 			 * <off>+-+	    Off X+-+  (unlikely case)
 			 *	|1|		 |1|
 			 *	| |		 | |
 			 *	+-+		 +-+
 			 */
			if( pdef2->type == VS_K_HORIZONTAL ) {
				origin.x += plcn->offset ; /* offset < 0 */
				origin.y += pdef1->length ;
			} else {
				origin.x += plcn->offset ; /* offset < 0 */
				origin.y += pdef1->length ;
			}
			break ;

		case VS_K_LEFT	:
			/*
			 *       +-+		+-++-+
			 *       |1|		|2||1|
			 * +----+| |		| || |
			 * |2   || |		O-+| |
			 * O----+| |		  ^| |
			 *      ^| |		off| |
			 *    off| |		  v+-+
			 *      v+-+
			 */
			if( pdef2->type == VS_K_HORIZONTAL ) {
				origin.x -= pdef2->length ;
				origin.y += plcn->offset ;
			} else {
				origin.x -= pdef2->thickness ;
				origin.y += plcn->offset ;
			}
			break ;
			
		case VS_K_RIGHT	:
			/*
			 * +-+			+-++-+
			 * |1|+--------+	|1||2|
			 * | ||2       |	| || |
			 * | |O--------+	| |O-+
			 * | |^			| |^
			 * | |off		| |off
			 * +-+v			+-+v
			 */
			if( pdef2->type == VS_K_HORIZONTAL ) {
				origin.x += pdef1->thickness ;
				origin.y += plcn->offset ;
			} else {
				origin.x += pdef1->thickness ;
				origin.y += plcn->offset ;
			}
			break ;
			
		}
		break ;		
	}

	VSgetCoordCorners( &origin, pdefs, i2, plInfos[i2].corners ) ;

} /* VSfindConnections */
/*----------------------------------------------------------------------------*/
void VScomputeCoordinates( npdefs, pdefs, nplcns, plcns, plInfos )

int		npdefs,
		nplcns ;
VSxsPlateDef	*pdefs ;
VSxsPlConn	*plcns ;
VSxsPlInfo	*plInfos; {

	int		i,
			j,
			k,
			l,
			connections[VS_K_MAX_XSPLATES],
			maxcnxs ;
	VS2dPoint	origin ;

	SetProc( VScomputeCoordinates ) ; Begin

	/*
	 * It is supposed that the connections plcns are relative to the
	 * plate #0, and are deduced from one another, ie. connection 0-1
	 * sets the coordinates of 1 and connection 1-2 sets those of 2,
	 * deduced from those of 1, themselves deduced from those of 0.
	 */
	/*
	 * Compute the coordinates of all plate corners as well as connection
	 * points relative to the the left bottom corner of the first plate
	 * taken as the origin (0,0).
	 */
	origin.x = origin.y = 0 ;

	/*
	 * Init all plInfos: corners coordinates will be definitively set later
	 * but the logical points must be set (we do not know which is the
	 * starting plate).
	 */
	for( i = 0 ; i < npdefs ; i++ ) {
		VSgetCoordCorners( &origin, pdefs, i, plInfos[i].corners ) ;
	}

	for( i = 0 ; i < npdefs ; i++ ) {
		/*
		 * Init plate info.
		 */
		plInfos[i].def = pdefs[i] ;

		/*
		 * Find connections with plate #i
		 */
		for( j = k = 0 ; j < nplcns ; j++ ) {
			if( plcns[j].plate1 == i /* && plcns[j].plate2 > i */ ) {
				connections[k++] = j ;
			}
		}
		maxcnxs = k ;

		for( l = 0 ; l < maxcnxs ; l++ ) {

			k = connections[l] ;
#ifdef vsDEBUG
	printf( "*- Connection of %d is %d with %d\n", i, k, plcns[k].plate2 ) ;
#endif
			VSfindConnections(
				pdefs,
				i,			/* 1st plate (abs) */
				(int) plcns[k].plate2,	/* 2nd plate (rel) */
				plcns + k,		/* Connection info */
				plInfos ) ;		/* Updated	   */
		}
	}

	End

} /* VScomputeCoordinates */
/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
long VSmergeContours( msg, plInfo1, plInfo2, cnxPts1, cnxPts2, side1, side2,
		      contour )

long		*msg ;
VSxsPlInfo	*plInfo1,
		*plInfo2 ;
VScontourPnt	cnxPts1[2],
		cnxPts2[2] ;
int		side1,
		side2 ;
VSxsPlContour	*contour ; {

	long		sts ;
	VScontourPnt	tmp[100] ;
	int		i1 = -1,
			i2 = -1,
			j1,
			j2,
			i,
			j,
			k ;

	/*
	 * Merge corner points of plate #2 into contour.
	 * We have to insert the corner points of plate #2 between those
	 * of plate # 1 already in contour.
	 * 1) look for cnxPts1[0] and cnxPts1[1] which are the points
	 * of plate #1 already in contour between which plate #2 must be
	 * inserted.
	 * 2) Insert corner points of plate #2 at P2 (P2 = cnxPts1[1]).
	 *		+---------------+
	 *		|       1	|
	 *		+--+ +----------+
	 *		P1 |a|Q1   +-+  P2	P1 = cnxPts1[0]
	 *		   | |     |2|		P2 = cnxPts1[1]
	 *		   +-+     +-+
	 * "a" previously inserted has added points to the contour
	 * (here we insert plate #2 between Q1 and P2).
	 */

	SetProc( VSmergeContours ) ; Begin

	__DBGpr_int( "Nb contour points", contour->npoints ) ;
	
	/*
	 * See if points of plate #1 are already in contour.
	 */
	for( i = 0 ; i < contour->npoints ; i++ ) {
		if( contour->points[i].log.plateNo == cnxPts1[0].log.plateNo
		    && contour->points[i].log.pointNo == cnxPts1[0].log.pointNo ) {
		    	i1 = i ;
		    	break ;
		}
	}

	for( i = 0 ; i < contour->npoints ; i++ ) {
		if( contour->points[i].log.plateNo == cnxPts1[1].log.plateNo
		    && contour->points[i].log.pointNo == cnxPts1[1].log.pointNo ) {
		    	i2 = i ;
		    	break ;
		}
	}

	if( i1 == -1 ) {
		__DBGpr_com( "Could not find i1" ) ;
		vs$failure() ;
	}

	if( i2 == -1 ) {
		__DBGpr_com( "Could not find i2" ) ;
		vs$failure() ;
	}

	__DBGpr_int( "i1", i1 ) ;
	__DBGpr_int( "i2", i2 ) ;

	/*
	 * First and second point of plate #2 to insert.
	 */
	j1 = cnxPts2[0].log.pointNo ;
	j2 = cnxPts2[1].log.pointNo ;

	__DBGpr_int( "j1", j1 ) ;
	__DBGpr_int( "j2", j2 ) ;

	/*
	 * Insert points of plate #2 from j2 to j1, beware that we have a
	 * circular succession 0,1,2,3,0. Hence if j2=2, we must copy 2,3,0,1.
	 */
	__DBGpr_int( "Insert at", i2 ) ;

	for( k = 0, i = i2 ; i < contour->npoints ; i++, k++ ) {
		tmp[k] = contour->points[i] ;
	}

	for( j = j2, i = i2 ; i < i2 + VS_K_NBCORNERS ; i++ ) {
		if( j >= VS_K_NBCORNERS ) j = 0 ;
		contour->points[i] = plInfo2->corners[j++] ;
	}

	for( i = i2 + VS_K_NBCORNERS, j = 0 ; j < k ; i++, j++ ) {
		contour->points[i] = tmp[j] ;
	}
	contour->npoints += VS_K_NBCORNERS ;

	/*
	 * We save the inter-plate frontier as the two logical segments
	 * [cnxPts1[0],cnxPts1[1]] and [cnxPts2[0],cnxPts2[1]]
	 */
	i = contour->nfrontiers ;
	contour->frontier[i][0][0] = cnxPts1[0].log ;
	contour->frontier[i][0][1] = cnxPts1[1].log ;
	contour->frontier[i][1][0] = cnxPts2[0].log ;
	contour->frontier[i][1][1] = cnxPts2[1].log ;
	contour->nfrontiers += 1 ;

	sts	= OM_S_SUCCESS ;
	*msg	= MSSUCC ;

	wrapup :
		End
		return sts ;

} /* VSmergeContours */
/*----------------------------------------------------------------------------*/
void VSgetConnPnts( plInfo, side, cnxpt1, cnxpt2 )

VSxsPlInfo	*plInfo ;
int		side ;
VScontourPnt	*cnxpt1,
		*cnxpt2 ; {

	int	i1,
		i2,
		i,
		no ;

	/*
	 * We order points counterclockwise: beware of values of i1 and i2:
	 *
	 *		      top
	 *		TL ----<---- TR
	 *		|	      |
	 *	left	V	      ^ right
	 *		|	      |
	 *		BL ---->---- BR
	 *		    bottom
	 */
	switch( side ) {
		default		: /* Should not get here */
		case VS_K_TOP	: i1 = VS_K_TR ; i2 = VS_K_TL ; break ;
		case VS_K_BOTTOM: i1 = VS_K_BL ; i2 = VS_K_BR ; break ;
		case VS_K_RIGHT	: i1 = VS_K_BR ; i2 = VS_K_TR ; break ;
		case VS_K_LEFT  : i1 = VS_K_TL ; i2 = VS_K_BL ; break ;
	}

	for( i = 0 ; i < VS_K_NBCORNERS ; i++ ) {
		no = plInfo->corners[i].log.pointNo ;
		if( no == i1 ) {
			*cnxpt1 = plInfo->corners[i] ;
		} else if( no == i2 ) {
			*cnxpt2 = plInfo->corners[i] ;
		}
	}
#ifdef vsDEBUG
	printf( "Connect point 1 plateNo %d pointNo %d\n",
		cnxpt1->log.plateNo, cnxpt1->log.pointNo ) ;
	printf( "Connect point 2 plateNo %d pointNo %d\n",
		cnxpt1->log.plateNo, cnxpt1->log.pointNo ) ;
#endif
} /* VSgetConnPnts */
/*----------------------------------------------------------------------------*/
void VSrmNonCornerPnts( contour ) VSxsPlContour *contour ; {

	/*
	 * Remove from contour points which are not corners, eg. in an L-shaped
	 * contour:
	 *
	 *		+-+
	 *		| |
	 *		| |
	 *		| +---+
	 *		|     |
	 *		+-+---+
	 *		P Q   R		Q must be removed
	 *
	 *	1) Q corresponds to two points: one of P1, one of P2.
	 *	2) P, Q and R are collinear, in our simplified case here, either
	 *	Px = Qx = Rx or Py = Qy = Ry.
	 */

	int		i,
			j,
			next_i,
			next_next,
			max = contour->npoints ;
	VScontourPnt	*p = contour->points ;
	char		rm[VS_K_MAXCNTPTS] ;

	SetProc( VSrmNonCornerPnts ) ; Begin

#define EQCOORDS( u, v, c ) ( VSeqDblTol( p[(u)].coord.c, p[(v)].coord.c ) )

	/*
	 * Remove duplicates.
	 */
	for( i = j = 0 ; i < max ; i++ ) {
		if( i == max - 1 ) {
			next_i = 0 ;
		} else {
			next_i = i + 1 ;
		}

		if(    EQCOORDS( i, next_i, x )
		    && EQCOORDS( i, next_i, y ) ) {
		       	__DBGpr_int( "Duplicate point to remove", i ) ;
		       	rm[i] = 1 ; j++ ;
		} else {
			rm[i] = 0 ;
		}
	}
	if( j ) {
		for( i = j = 0 ; i < max ; i++ ) {
			if( !rm[i] ) {
				p[j++] = p[i] ;
			}
		}
		contour->npoints = max = j ;
		__DBGpr_int( "New count of pnts", j ) ;
	}

	for( i = j = 0 ; i < max ; i++ ) {
		if( i == max - 2 ) {
			next_i		= i + 1 ;
			next_next	= 0 ;
		} else if( i == max - 1 ) {
			next_i		= 0 ;
			next_next	= 1 ;
		} else {
			next_i		= i + 1 ;
			next_next	= i + 2 ;
		}
#ifdef vsDEBUG
{ char t[20] ;
sprintf( t, "i         = %d", i ) ; VSdump2dPt( t, &p[i        ].coord ) ;
sprintf( t, "next_i    = %d", next_i ) ; VSdump2dPt( t, &p[next_i   ].coord ) ;
sprintf( t, "next_next = %d", next_next ) ; VSdump2dPt( t, &p[next_next].coord ) ;
printf( "i = next_i x ? %d\n", EQCOORDS( i, next_i, x ) ) ;
printf( "i = next_i y ? %d\n", EQCOORDS( i, next_i, y ) ) ;
printf( "next_i = next_next x ? %d\n", EQCOORDS( next_i, next_next, x ) ) ;
printf( "next_i = next_next y ? %d\n", EQCOORDS( next_i, next_next, y ) ) ;
}
#endif
		if(	  EQCOORDS( i     , next_i   , x )
		       && EQCOORDS( next_i, next_next, x )
		    ||    EQCOORDS( i     , next_i   , y )
		       && EQCOORDS( next_i, next_next, y ) ) {
		       	__DBGpr_int( "Corner point to remove", next_i ) ;
		       	rm[next_i] = 1 ; j++ ;
		} else {
			rm[next_i] = 0 ;
		}
	}

	if( j ) {
		for( i = j = 0 ; i < max ; i++ ) {
			if( !rm[i] ) {
				p[j++] = p[i] ;
			}
		}
		contour->npoints = j ;
		__DBGpr_int( "New count of pnts", j ) ;
	}

	End
#undef EQCOORDS

} /* VSrmNonCornerPnts */
/*----------------------------------------------------------------------------*/
void VSfindBotLeftCorner( contour, index )

VSxsPlContour	*contour ;
int		*index ; {

	/*
	 * Find the index of the bottom left corner of the contour:
	 *
	 *	+-----+
	 *	|     |
	 *	+-+ +-+
	 *	  | |
	 *	  | |
	 *	  X-+	X = bottom left corner
	 *
	 *	It is the point on the line at minimum y that has the minimum x.
	 */

	double		xmin	= DBL_MAX,
			ymin	= DBL_MAX ;
	int		i,
			max	= contour->npoints ;
	VScontourPnt	*p	= contour->points ;
	
	/*
	 * Find minimum y.
	 */
	for( i = 0 ; i < max ; i++ ) {
		if( p[i].coord.y <= ymin ) ymin = p[i].coord.y ;
	}
		
	__DBGpr_dbl( "Minimum y", ymin ) ;

	/*
	 * Find point.
	 */
	for( i = 0 ; i < max ; i++ ) {
		if( p[i].coord.y == ymin && p[i].coord.x <= xmin ) {
			xmin	= p[i].coord.x ;
			*index	= i ;
		} 
	}

#ifdef vsDEBUG
	VSdump2dPt( "Bot Left Corner", &p[*index].coord ) ;
#endif

} /* VSfindBotLeftCorner */
/*----------------------------------------------------------------------------*/
long VSgetContour( msg, npdefs, pdefs, nplcns, plcns, contour, shapeDescr )

long		*msg ;
int		npdefs,
		nplcns ;
VSxsPlateDef	*pdefs ;
VSxsPlConn	*plcns ;
VSxsPlContour	*contour ;
VSxsPlShpDesc	*shapeDescr ; {

	long		sts ;
	int		i,
			j,
			k ;
	VSxsPlInfo	plInfos[VS_K_MAX_XSPLATES] ;
	int		connections[VS_K_MAX_XSPLATES],
			maxcnxs ;

	if( npdefs > VS_K_MAX_XSPLATES || nplcns > VS_K_MAX_XSPLATES ) {
		vs$inv_arg() ;
	}
	/*
	 * Compute coordinates of plate corners.
	 */
	VScomputeCoordinates( npdefs, pdefs, nplcns, plcns, plInfos ) ;

#ifdef vsDEBUG
	for( i = 0 ; i < npdefs ; i++ ) {
		for( j = 0 ; j < 4 ; j++ ) {
			printf( "pl %d pt %d x = %g y = %g\n",
				i, plInfos[i].corners[j].log.pointNo,
				plInfos[i].corners[j].coord.x,
				plInfos[i].corners[j].coord.y ) ;
		}
	}
#endif
	/*
	 * Init contour with corners of 1st plate.
	 */
	for( i = 0 ; i < VS_K_NBCORNERS ; i++ ) {
		contour->points[i] = plInfos[0].corners[i] ;
	}
	contour->npoints	= VS_K_NBCORNERS ;
	contour->nfrontiers	= 0 ;

	for( i = 0 ; i < npdefs ; i++ ) {

		int l ;

		/*
		 * Find connections with plate #i
		 */
		for( j = k = 0 ; j < nplcns ; j++ ) {
			if( plcns[j].plate1 == i /* && plcns[j].plate2 > i */ ) {
				if( k >= VS_K_MAX_XSPLATES ) vs$inv_arg() ;
				connections[k++] = j ;
			}
		}
		maxcnxs = k ;

		for( l = 0 ; l < maxcnxs ; l++ ) {
			VScontourPnt	cnxPts1[2],
					cnxPts2[2] ;

			k = connections[l] ;	

			/*
			 * Insert plate #2 between points delimiting connection
			 * side of plate #1.
			 */
#ifdef vsDEBUG
	printf( "Connection of %d is %d with %d\n", i, k, plcns[k].plate2 ) ;
#endif

			j = plcns[k].plate2 ;
			VSgetConnPnts( plInfos + i, (int) plcns[k].side1,
					cnxPts1 + 0, cnxPts1 + 1 ) ;
			VSgetConnPnts( plInfos + j, (int) plcns[k].side2,
					cnxPts2 + 0, cnxPts2 + 1 ) ;

			sts = VSmergeContours(
				msg,
				plInfos + i		, plInfos + j,
				cnxPts1			, cnxPts2,
				(int) plcns[k].side1	, (int) plcns[k].side2,
				contour ) ;
			__CheckRC( sts, *msg, "VSmergeContours", wrapup ) ;
		}
	}

#ifdef vsDEBUG
	VSdumpContour( contour ) ;
	VSfindBotLeftCorner( contour, &i ) ;
#endif

	VSrmNonCornerPnts( contour ) ;

	VSnameContourFaces(	msg,
				contour,
				npdefs,
				plInfos,
				&shapeDescr->shapeType,
				shapeDescr->nmIndices,
				shapeDescr->plToBmFace ) ;
 
	__DBGpr_int( "Shape type", shapeDescr->shapeType ) ;
	__DBGpr_int( "VSnameContourFaces *msg", *msg ) ;

	sts = OM_S_SUCCESS ;
	*msg= MSSUCC ;

	wrapup :
		return sts ;

} /* VSgetContour */
/*----------------------------------------------------------------------------*/
long VSgetContourParameters( msg, contour, shapeType, nmIndices, parms )

long		*msg ;
VSxsPlContour	*contour ;
int		shapeType,
		nmIndices[] ;
VSxsPlParms	*parms ; {

	long		sts ;
	int		i1,
			i2,
			size = contour->npoints ;
	VS2dPoint	range[2] ;
	VScontourPnt	*p = contour->points ;

#define GETFACENO( F, NO )\
	VSfind_item_in_array( (F), nmIndices, size, NO ) ;

	VSgetContourRange( contour, range ) ;
	parms->width	= range[1].x - range[0].x ;
	parms->height	= range[1].y - range[0].y ;

	switch( shapeType ) {
	case VS_K_SQUARE_SHAPE	:
		GETFACENO( VS_K_sc_WebL		, &i1 ) ;
		GETFACENO( VS_K_sc_WebL_2	, &i2 ) ;
		if( i1 == -1 || i2 == -1 ) vs$failure() ;
		parms->webThickness = p[i2].coord.x - p[i1].coord.x ;

		GETFACENO( VS_K_sc_FlgSupE_2	, &i1 ) ;
		GETFACENO( VS_K_sc_FlgSupE	, &i2 ) ;
		if( i1 == -1 || i2 == -1 ) vs$failure() ;
		parms->flgThickness = p[i2].coord.y - p[i1].coord.y ;
		break ;
		
	case VS_K_BAR_SHAPE	:
		GETFACENO( VS_K_sc_WebL		, &i1 ) ;
		GETFACENO( VS_K_sc_WebR		, &i2 ) ;
		if( i1 == -1 || i2 == -1 ) vs$failure() ;
		parms->webThickness = p[i2].coord.x - p[i1].coord.x ;
		parms->flgThickness = 0 ;
		parms->width	    = 0 ;
		break ;

	case VS_K_I_SHAPE	:
	case VS_K_T_SHAPE	:
		GETFACENO( VS_K_sc_WebL		, &i1 ) ;
		GETFACENO( VS_K_sc_WebR		, &i2 ) ;
		if( i1 == -1 || i2 == -1 ) vs$failure() ;
		parms->webThickness = p[i2].coord.x - p[i1].coord.x ;

		GETFACENO( VS_K_sc_FlgSupIRS	, &i1 ) ;
		GETFACENO( VS_K_sc_FlgSupE	, &i2 ) ;
		if( i1 == -1 || i2 == -1 ) vs$failure() ;
		parms->flgThickness = p[i2].coord.y - p[i1].coord.y ;
		break ;

	case VS_K_H_SHAPE	:
		GETFACENO( VS_K_sc_WebR		, &i1 ) ;
		GETFACENO( VS_K_sc_WebL		, &i2 ) ;
		if( i1 == -1 || i2 == -1 ) vs$failure() ;
		parms->webThickness = p[i2].coord.y - p[i1].coord.y ;

		GETFACENO( VS_K_sc_FlgSupIRS	, &i1 ) ;
		GETFACENO( VS_K_sc_FlgSupE	, &i2 ) ;
		if( i1 == -1 || i2 == -1 ) vs$failure() ;
		parms->flgThickness = p[i2].coord.x - p[i1].coord.x ;
		break ;

	case VS_K_GAMMA_SHAPE	:
		GETFACENO( VS_K_sc_WebL		, &i1 ) ;
		GETFACENO( VS_K_sc_WebR		, &i2 ) ;
		if( i1 == -1 || i2 == -1 ) vs$failure() ;
		parms->webThickness = p[i2].coord.x - p[i1].coord.x ;

		GETFACENO( VS_K_sc_FlgSupIRS	, &i1 ) ;
		GETFACENO( VS_K_sc_FlgSupE	, &i2 ) ;
		if( i1 == -1 || i2 == -1 ) vs$failure() ;
		parms->flgThickness = p[i2].coord.y - p[i1].coord.y ;
		break ;

	case VS_K_L_SHAPE	:
	case VS_K_C_SHAPE	:
		GETFACENO( VS_K_sc_WebL		, &i1 ) ;
		GETFACENO( VS_K_sc_WebR		, &i2 ) ;
		if( i1 == -1 || i2 == -1 ) vs$failure() ;
		parms->webThickness = p[i2].coord.x - p[i1].coord.x ;

		GETFACENO( VS_K_sc_FlgInfR	, &i1 ) ;
		GETFACENO( VS_K_sc_FlgInfIRS	, &i2 ) ;
		if( i1 == -1 || i2 == -1 ) vs$failure() ;
		parms->flgThickness = p[i2].coord.y - p[i1].coord.y ;
		break ;

	default	: vs$inv_arg() ;
	}

	sts = OM_S_SUCCESS ;
	*msg= MSSUCC ;

	wrapup :
		return sts ;

} /* VSgetContourParameters */
/*----------------------------------------------------------------------------*/
