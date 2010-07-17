/*
	I/STRUCT
*/
#include <stdio.h>
#include <math.h>
#include <limits.h>
#include <stdlib.h>
#include "OMerrordef.h"
#include "OMmacros.h"
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

#define MAXROWS	(2*VS_K_MAXCNTPTS)
#define MAXCOLS	(2*VS_K_MAXCNTPTS)

typedef char	SHAPE_PATTERN[MAXROWS][MAXCOLS+1] ;

extern void	VSfindBotLeftCorner(),
		VSgetContourRange(),
		VStranslateContour() ;
/*----------------------------------------------------------------------------*/
int VSeqDblTol( d1, d2 ) double d1, d2 ; {
#define TOLM5	0.00001
	int	eq ;
	if( fabs( d2 - d1 ) <= TOLM5 )	eq = 1 ;
	else				eq = 0 ;

	return eq ;

#undef  TOLM5
} /* VSeqDblTol */
/*----------------------------------------------------------------------------*/
int VSdblCmp( D1, D2 )

#if defined(__STDC__) || defined(__cplusplus)
	const
#endif
void	*D1,
	*D2 ; {

	/*
	 * Compare two doubles, input to `qsort'.
	 */
	int	rc = 0 ;
	double	*d1	= (double *) D1,
		*d2	= (double *) D2 ;

	     if( VSeqDblTol( *d1, *d2 ) )	rc =  0 ;
	else if( *d1 < *d2 )			rc = -1 ;
	else if( *d1 > *d2 )			rc =  1 ;

	return rc ;

} /* VSdblCmp */
/*----------------------------------------------------------------------------*/
int VSmapDouble( mapSize, map, d )

int		mapSize ;
double		map[],
		d ; {

	/*
	 * Maps a double, supposed in `map' to the corresponding index:
	 * If		i (coord in text space ) |--> map[i]
	 * Then this is the inverse of `map'
	 */
	int i ;

	for( i = 0 ; i < mapSize ; i++ ) {
		if( VSeqDblTol( d, map[i] ) ) return i ;
	}

	return -1 ;

} /* VSmapDouble */
/*----------------------------------------------------------------------------*/
void VSmakeMapToTextSpace( contour, mapSize, map )

VSxsPlContour	*contour ;
int		*mapSize ;
double		map[] ; {

	int		i,
			j,
			max ;
	double		sorted1[VS_K_MAXCNTPTS*2] ;

	SetProc( VSmakeMapToTextSpace ) ; Begin

	/*
	 * Fill with all possible values of the coordinates.
	 */
	max = contour->npoints ;
	for( i = j = 0 ; i < max ; i++ ) {
		sorted1[j++] = contour->points[i].coord.x ;
		__DBGpr_dbl( "sorted 1 x", contour->points[i].coord.x ) ;
		sorted1[j++] = contour->points[i].coord.y ;
		__DBGpr_dbl( "sorted 1 y", contour->points[i].coord.y ) ;
	}

	/*
	 * Sort array.
	 */
	max *= 2 ;
	qsort( (char *) sorted1, (unsigned) max, sizeof *sorted1, VSdblCmp ) ;

	/*
	 * Remove dups. `map' will be a mapping
	 *	text space	-->	2D space
	 *	i		|->	map[i]
	 * Note that distances will not be respected: shapes with the same type
	 * but different sizes will be mapped to the same pattern in text space.
	 */
	map[0] = sorted1[0] ;
	for( i = j = 1 ; i < max ; i++ ) {
#ifdef vsDEBUG
		printf( "Dup %g %g", sorted1[i], map[j-1] ) ;
#endif
		if( !VSeqDblTol( sorted1[i], map[j-1] ) ) {
#ifdef vsDEBUG
		printf( " DIFFERENT %g\n", sorted1[i]-map[j-1] ) ;
#endif

			map[j++] = sorted1[i] ;
		}
#ifdef vsDEBUG
		else printf( " EQUAL\n" ) ;
#endif
	}
#ifdef vsDEBUG
	for( i = 0 ; i < max ; i++ ) {
		printf( "sorted1[%d] = %g\n", i, sorted1[i] ) ;
	}
#endif

	max = j ;

#ifdef vsDEBUG
	for( i = 0 ; i < max ; i++ ) {
		printf( "map[%d] = %g\n", i, map[i] ) ;
	}
#endif

	*mapSize = max ;
	End

} /* VSmakeMapToTextSpace */
/*----------------------------------------------------------------------------*/
long VScreateShapeText( msg, contour, text, nbLines )

long		*msg ;
int		*nbLines ;
VSxsPlContour	*contour ;
SHAPE_PATTERN	text ; {

	long		sts ;		/* OM return code		*/
	int		i,
			j,
			k,
			max,
			x,		/* x-coord in text space	*/
			y,		/* ycoord in text space		*/
			maxcols ;	/* Max val. of x in text space,
					   ie. rightmost column occupied
					   by pattern.			*/
	VS2dPoint	range[2],	/* Range of contour		*/
			trans ;		/* Translation vector		*/
	char		allDots[MAXCOLS+1] ;
	SHAPE_PATTERN	reduced ;
	int		mapSize ;
	double		map[VS_K_MAXCNTPTS*2] ;

	/*
	 * Init text space with dots. This makes it more readable than blanks.
	 * Also fill `allDots' used to detect empty rows later upon reduction.
	 */
	for( i = 0 ; i < MAXROWS ; i++ ) {
		allDots[i] = '.' ;
		for( j = 0 ; j < MAXCOLS + 1 ; j++ ) {
			text[i][j] = '.' ;
		}
		text[i][MAXCOLS] = '\0' ;
	}
	allDots[MAXCOLS] = '\0' ;

	/*
	 * Translate contour so that bottom left corner is the origin, we'll
	 * start filling text space from its bottom.
	 */
	VSgetContourRange( contour, range ) ;

	trans.x = 0 - range[0].x ;
	trans.y = 0 - range[0].y ;

	VStranslateContour( &trans, contour ) ;

	VSmakeMapToTextSpace( contour, &mapSize, map ) ;

	maxcols = - INT_MAX ;
	for( i = 0 ; i < contour->npoints ; i++ ) {
		/*
		 * Find integer corresponding to x and y coordinates so as
		 * to map to text space.
		 */
		__DBGpr_int( "Mapping point", i ) ; 
		y = VSmapDouble( mapSize, map, contour->points[i].coord.y ) ;
		x = VSmapDouble( mapSize, map, contour->points[i].coord.x ) ;

		if( x == -1 || y == -1 ) {
			/*
			 * Something deadly wrong !
			 */
#ifdef vsDEBUG
	printf( "X or Y not mapped %d %d\n", x, y ) ;
	printf( "Xd %g Yd %g\n", contour->points[i].coord.x,
				 contour->points[i].coord.y ) ;
#endif
			 vs$failure() ;
		}
		/*
		 * Start from bottom (text space has oppposed y-axis as
		 * compared with 3D-space y-axis).
		 */
		k = MAXROWS-1 - y ;
		text[k][x]= 'a' + i ;
		/*
		 * Find row number in text space where pattern starts.
		 */
		if( k < j ) j = k ;
		if( maxcols < x ) maxcols = x ;
	}
	/*
	 * `max' contains the row number where pattern starts.
	 */
	max = j ;

#ifdef vsDEBUG
	for( i = max ; i < MAXROWS ; i++ ) {
		printf( "%s\n", text[i] ) ;
	}
#endif

	/*
	 * Reduce figure in text space: suppress all rows filled with dots.
	 * Eg.
	 *	x..x			x..x
	 *	xxxx			xxxx
	 *	 ..	becomes		xxxx
	 *	 ..			x..x
	 *	xxxx
	 *	x..x
	 */
	for( i = j = 0 ; i < MAXROWS ; i++ ) {
		if( strcmp( text[i], allDots ) ) {
			strcpy( reduced[j], text[i] ) ;
			reduced[j][maxcols+1] = '\0' ;
			j++ ;
		}
	}
	/*
	 * `max' contains the number of rows of pattern.
	 */
	max = j ;

	/*
	 * Reduce again figure in text space: suppress all columns filled with
	 * dots.
	 * Eg.
	 *	xx			xx
	 *	.x.x	becomes		.xx
	 *	x..x			x.x
	 */
	for( j = 0 ; j <= maxcols ; ) {
		k = 1 ;

		for( i = 0 ; i < max ; i++ ) {
			if( reduced[i][j] != '.' ) { k = 0 ; break ; } 
		}
		if( k ) {
			for( k = 0 ; k < max ; k++ ) {
				OM_BLOCK_MOVE(
				/* From	*/  &reduced[k][j+1],
				/* To	*/  &reduced[k][j  ],
				/* Size	*/  ( 1 + strlen( &reduced[k][j+1] ) )
					    * sizeof( char ) ) ;
			}
			maxcols-- ;
			__DBGpr_int( "New maxcols", maxcols ) ;
			/*
			 * Do not decrease `j', this column (former j+1) must
			 * be tested.
			 */
		} else {
			j++ ;
		}
	}

	/*
	 * Copy to output buffer.
	 */
	for( i = 0 ; i < max ; i++ ) {
		strcpy( text[i], reduced[i] ) ;
	}

#ifdef vsDEBUG
	for( i = 0 ; i < max ; i++ ) {
		printf( "--> %s\n", text[i] ) ;
	}
#endif
	/*
	 * Translate back to original location.
	 */
	trans.x = - trans.x ;
	trans.y = - trans.y ;

	VStranslateContour( &trans, contour ) ;

	*nbLines = max ;

	*msg	= MSSUCC ;
	sts	= OM_S_SUCCESS ;

	wrapup :
		return sts ;

} /* VScreateShapeText */
/*----------------------------------------------------------------------------*/
int VSeqShapeTextLine( s1, s2 ) char *s1, *s2 ; {

	/*
	 * Two lines are equal if they contain dots or non-dots at the same
	 * indices (ie. in the same columns).
	 */
	int	l1 = strlen( s1 ),
		l2 = strlen( s2 ) ;

	if( l1 != l2 ) return 0 ;

	while( *s1 ) {
		if( *s1 == '.' ) {
			if( *s2 != '.' ) return 0 ;
		} else {
			if( *s2 == '.' ) return 0 ;
		}
		s1++ ; s2++ ;
	}

	return 1 ;

} /* VSeqShapeTextLine */
/*----------------------------------------------------------------------------*/
int VSshapeMatch( shapeText, nbRows, nbCols, pattern )

SHAPE_PATTERN	shapeText ;
int		nbRows,
		nbCols ;
char		*pattern ; {

	int	i ;

	for( i = 0 ; i < nbRows ; i++ ) {
		if( !VSeqShapeTextLine( shapeText[i], pattern ) ) {
			return 0 ;
		}
		pattern += nbCols + 1 ;
	}
	return 1 ;

} /* VSshapeMatch */
/*----------------------------------------------------------------------------*/
long VSgetShapeTypeFromText( msg, nbLines, shapeText, type )

long		*msg ;
int		nbLines,
		*type ;
SHAPE_PATTERN	shapeText ; {

	/*
	 * In the following patterns below, the shape of the profile may be
	 * retrieved by connecting the letters in alphabetical order.
	 * E.g for T :
	 *
	 *	h-----g
	 *	|     |      
	 *	a-b e-f
	 *	  | |
	 *	  c-d
	 *
	 * Note that the algorithm below only tests for the presence of a dot
	 * or a non-dot character. The letters might as well all be x's.
	 * They have been differentiated just for the purpose of readablity.
	 */

	static char
/* VS_K_T_SHAPE		*/	T[3][5]		= {	"h..g",
							"abef",
							".cd." },
/* VS_K_I_SHAPE		*/	I[4][5]		= {	"l..k",
							"abij",
							"dchg",
							"e..f" },
/* VS_K_L_SHAPE		*/	L[3][4]		= {	"af.",
							".ed",
							"b.c" },
				/*
				 * Gamma is L upside down.
				 */
/* VS_K_GAMMA_SHAPE	*/	GAMMA[3][4]	= {	"f.e",
							".cd",
							"ab." },
				/*
				 * H is a horizontal I
				 * ( vertical bar of I = horizontal bar of H).
				 */
/* VS_K_H_SHAPE		*/	H[4][5]		= {	"lkgh",
							".ji.",
							".cd.",
							"abef" },
/* VS_K_C_SHAPE		*/
				C[4][4]		= {	"h.g",
							".ef",
							".dc",
							"a.b" },

/* VS_K_BAR_SHAPE 	*/ 	BAR[2][3]	= {	"dc",
							"ab" },
							
/* VS_K_SQUARE_BAR	*/	SQUARE[4][6]	= {	"j...i",
							".c.d.",
							"..fe.",
							"abg.h" } ;

	long		sts ;

	*type = VS_K_UNKNOWN_SHAPE ;

	switch( nbLines ) {
		case 2 :
			if( VSshapeMatch( shapeText, 2, 2, &BAR[0][0] 	 ) ) {
				__DBGpr_com( "It's a BAR!!!" ) ;
				*type = VS_K_BAR_SHAPE ;
				break ;
			}
	
			vs$failure() ;

		case 3 :
			if( VSshapeMatch( shapeText, 3, 4, &T[0][0] 	 ) ) {
				__DBGpr_com( "It's a T!!!" ) ;
				*type = VS_K_T_SHAPE ;
				break ;
			}
			if( VSshapeMatch( shapeText, 3, 3, &L[0][0] 	 ) ) {
				__DBGpr_com( "It's an L!!!" ) ;
				*type = VS_K_L_SHAPE ;
				break ;
			}
			if( VSshapeMatch( shapeText, 3, 3, &GAMMA[0][0]	 ) ) {
				__DBGpr_com( "It's a GAMMA!!!" ) ;
				*type = VS_K_GAMMA_SHAPE ;
				break ;
			}

			vs$failure() ;

		case 4 :
			if( VSshapeMatch( shapeText, 4, 4, &I[0][0] 	 ) ) {
				__DBGpr_com( "It's an I!!!" ) ;
				*type = VS_K_I_SHAPE ;
				break ;
			}

			if( VSshapeMatch( shapeText, 4, 4, &H[0][0] 	 ) ) {
				__DBGpr_com( "It's an H!!!" ) ;
				*type = VS_K_H_SHAPE ;
				break ;
			}

			if( VSshapeMatch( shapeText, 4, 3, &C[0][0] 	 ) ) {
				__DBGpr_com( "It's a C!!!" ) ;
				*type = VS_K_C_SHAPE ;
				break ;
			}

			if( VSshapeMatch( shapeText, 4, 5, &SQUARE[0][0] ) ) {
				__DBGpr_com( "It's a SQUARE!!!" ) ;
				*type = VS_K_SQUARE_SHAPE ;
				break ;
			}

			vs$failure() ;

		default :
			vs$failure() ;
	}

	*msg	= MSSUCC ;
	sts	= OM_S_SUCCESS ;

	wrapup :
		__DBGpr_int( "Shape type", *type ) ;

		return sts ;

} /* VSgetShapeTypeFromText */
/*----------------------------------------------------------------------------*/
void VSassignNamesToContourFaces( contour, shapeType, nmIndices )

VSxsPlContour	*contour ;
int		shapeType,
		nmIndices[VS_K_sc_MAXFACES] ; {

	int	i,
		BLindex,
		max = contour->npoints ;

#define NEXT( k ) ( (k) >= max - 1 ? (k) - max + 1 : (k) + 1 )

	VSfindBotLeftCorner( contour, &BLindex ) ;
	i = BLindex ;

	__DBGpr_int( "BLindex", BLindex ) ;

	switch( shapeType ) {

	case  VS_K_I_SHAPE	:
		nmIndices[i] = VS_K_sc_FlgInfE		; i = NEXT( i ) ;
		nmIndices[i] = VS_K_sc_FlgInfR		; i = NEXT( i ) ;
		nmIndices[i] = VS_K_sc_FlgInfIRS	; i = NEXT( i ) ;
		nmIndices[i] = VS_K_sc_WebR		; i = NEXT( i ) ;
		nmIndices[i] = VS_K_sc_FlgSupIRS	; i = NEXT( i ) ;
		nmIndices[i] = VS_K_sc_FlgSupR		; i = NEXT( i ) ;
		nmIndices[i] = VS_K_sc_FlgSupE		; i = NEXT( i ) ;
		nmIndices[i] = VS_K_sc_FlgSupL		; i = NEXT( i ) ;
		nmIndices[i] = VS_K_sc_FlgSupILS	; i = NEXT( i ) ;
		nmIndices[i] = VS_K_sc_WebL		; i = NEXT( i ) ;
		nmIndices[i] = VS_K_sc_FlgInfILS	; i = NEXT( i ) ;
		nmIndices[i] = VS_K_sc_FlgInfL		; i = NEXT( i ) ;
		break ;

	case  VS_K_L_SHAPE	:
		nmIndices[i] = VS_K_sc_FlgInfE		; i = NEXT( i ) ;
		nmIndices[i] = VS_K_sc_FlgInfR		; i = NEXT( i ) ;
		nmIndices[i] = VS_K_sc_FlgInfIRS	; i = NEXT( i ) ;
		nmIndices[i] = VS_K_sc_WebR		; i = NEXT( i ) ;
		nmIndices[i] = VS_K_sc_FlgSupE		; i = NEXT( i ) ;
		nmIndices[i] = VS_K_sc_WebL		; i = NEXT( i ) ;
		break ;

	case  VS_K_T_SHAPE	:
		nmIndices[i] = VS_K_sc_FlgInfE		; i = NEXT( i ) ;
		nmIndices[i] = VS_K_sc_WebR		; i = NEXT( i ) ;
		nmIndices[i] = VS_K_sc_FlgSupIRS	; i = NEXT( i ) ;
		nmIndices[i] = VS_K_sc_FlgSupR		; i = NEXT( i ) ;
		nmIndices[i] = VS_K_sc_FlgSupE		; i = NEXT( i ) ;
		nmIndices[i] = VS_K_sc_FlgSupL		; i = NEXT( i ) ;
		nmIndices[i] = VS_K_sc_FlgSupILS	; i = NEXT( i ) ;
		nmIndices[i] = VS_K_sc_WebL		; i = NEXT( i ) ;
		break ;

	case  VS_K_GAMMA_SHAPE	:
		nmIndices[i] = VS_K_sc_FlgInfE		; i = NEXT( i ) ;
		nmIndices[i] = VS_K_sc_WebR		; i = NEXT( i ) ;
		nmIndices[i] = VS_K_sc_FlgSupIRS	; i = NEXT( i ) ;
		nmIndices[i] = VS_K_sc_FlgSupR		; i = NEXT( i ) ;
		nmIndices[i] = VS_K_sc_FlgSupE		; i = NEXT( i ) ;
		nmIndices[i] = VS_K_sc_WebL		; i = NEXT( i ) ;
		break ;

	case  VS_K_H_SHAPE	:
		/*
		 * Consider an H as an I tilted towards the left:
		 *
		 *        <--+
		 *  +-+ +-+  |		+-------+
		 *  | | | |  |		|       |
		 *  | +-+ |		+--+ +--+
		 *  | +-+ |	==>	   | |
		 *  | | | |		+--+ +--+
		 *  O-+ +-+		|       |
		 *			+-------O
		 */
		nmIndices[i] = VS_K_sc_FlgInfR		; i = NEXT( i ) ;
		nmIndices[i] = VS_K_sc_FlgInfIRS	; i = NEXT( i ) ;
		nmIndices[i] = VS_K_sc_WebR		; i = NEXT( i ) ;
		nmIndices[i] = VS_K_sc_FlgSupIRS	; i = NEXT( i ) ;
		nmIndices[i] = VS_K_sc_FlgSupR		; i = NEXT( i ) ;
		nmIndices[i] = VS_K_sc_FlgSupE		; i = NEXT( i ) ;
		nmIndices[i] = VS_K_sc_FlgSupL		; i = NEXT( i ) ;
		nmIndices[i] = VS_K_sc_FlgSupILS	; i = NEXT( i ) ;
		nmIndices[i] = VS_K_sc_WebL		; i = NEXT( i ) ;
		nmIndices[i] = VS_K_sc_FlgInfILS	; i = NEXT( i ) ;
		nmIndices[i] = VS_K_sc_FlgInfL		; i = NEXT( i ) ;
		nmIndices[i] = VS_K_sc_FlgInfE		; i = NEXT( i ) ;
		break ;

	case VS_K_C_SHAPE	:
		nmIndices[i] = VS_K_sc_FlgInfE		; i = NEXT( i ) ;
		nmIndices[i] = VS_K_sc_FlgInfR		; i = NEXT( i ) ;
		nmIndices[i] = VS_K_sc_FlgInfIRS	; i = NEXT( i ) ;
		nmIndices[i] = VS_K_sc_WebR		; i = NEXT( i ) ;
		nmIndices[i] = VS_K_sc_FlgSupIRS	; i = NEXT( i ) ;
		nmIndices[i] = VS_K_sc_FlgSupR		; i = NEXT( i ) ;
		nmIndices[i] = VS_K_sc_FlgSupE		; i = NEXT( i ) ;
		nmIndices[i] = VS_K_sc_WebL		; i = NEXT( i ) ;
		break ;

	case VS_K_BAR_SHAPE	:
		nmIndices[i] = VS_K_sc_FlgInfE		; i = NEXT( i ) ;
		nmIndices[i] = VS_K_sc_WebR		; i = NEXT( i ) ;
		nmIndices[i] = VS_K_sc_FlgSupE		; i = NEXT( i ) ;
		nmIndices[i] = VS_K_sc_WebL		; i = NEXT( i ) ;
		break ;
		
	case VS_K_SQUARE_SHAPE	:
		nmIndices[i] = VS_K_sc_FlgInfL_2	; i = NEXT( i ) ;
		nmIndices[i] = VS_K_sc_WebL_2		; i = NEXT( i ) ;
		nmIndices[i] = VS_K_sc_FlgSupE_2	; i = NEXT( i ) ;
		nmIndices[i] = VS_K_sc_WebR_2		; i = NEXT( i ) ;
		nmIndices[i] = VS_K_sc_FlgInfE_2	; i = NEXT( i ) ;
		nmIndices[i] = VS_K_sc_FlgInfILS_2	; i = NEXT( i ) ;
		nmIndices[i] = VS_K_sc_FlgInfE		; i = NEXT( i ) ;
		nmIndices[i] = VS_K_sc_WebR		; i = NEXT( i ) ;
		nmIndices[i] = VS_K_sc_FlgSupE		; i = NEXT( i ) ;
		nmIndices[i] = VS_K_sc_WebL		; i = NEXT( i ) ;
		break ;
	}
#undef NEXT

} /* VSassignNamesToContourFaces */
/*----------------------------------------------------------------------------*/
void VSgetMassPropsMap( contour, type, nmIndices, plToBmFace )

VSxsPlContour	*contour ;
int		type,
		nmIndices[VS_K_sc_MAXFACES],
		plToBmFace[VS_K_MAX_XSPLATES] ; {

	int	faceNm[VS_K_MAX_XSPLATES],
		n,
		faceNo,
		i ;

	/*
	 * Set beam faces to use in order to compute mass properties of plates
	 * composing beam.
	 */
	switch( type ) {
	case VS_K_C_SHAPE	:
	case VS_K_H_SHAPE	:
	case VS_K_I_SHAPE	:
		faceNm[0] = VS_K_sc_FlgInfE ;
		faceNm[1] = VS_K_sc_WebR ;
		faceNm[2] = VS_K_sc_FlgSupE ;
		n = 3 ;
		break ;
	case VS_K_L_SHAPE	:
		faceNm[0] = VS_K_sc_FlgInfE ;
		faceNm[1] = VS_K_sc_WebR ;
		n = 2 ;
		break ;
	case VS_K_GAMMA_SHAPE	:
	case VS_K_T_SHAPE	:
		faceNm[0] = VS_K_sc_FlgSupE ;
		faceNm[1] = VS_K_sc_WebR ;
		n = 2 ;
		break ;
	case VS_K_BAR_SHAPE 	:
		faceNm[0] = VS_K_sc_WebR ;
		n = 1 ;
		break ;
	case VS_K_SQUARE_SHAPE	:
		faceNm[0] = VS_K_sc_WebL ;
		faceNm[1] = VS_K_sc_FlgInfE ;
		faceNm[2] = VS_K_sc_WebR ;
		faceNm[3] = VS_K_sc_FlgSupE ;
		n = 4 ;
		break ;
	default			: /* Should not get here */
		n = 0 ;
		break ;
		
	}

	for( i = 0 ; i < n ; i++ ) {
		/*
		 * Find face number of profile from its name.
		 */
		VSfind_item_in_array(	faceNm[i],
					nmIndices,
					(int) contour->npoints,
					&faceNo ) ;
		if( faceNo == -1 ) {
			/*
			 * Internal bug.
			 */
			fprintf( stderr,
				 "In VSgetMassPropsMap cannot find face no\n" ) ;
			break ;
		}
		/*
		 * Get plate to which point belongs (face numbers match point
		 * numbers), and map plate # to face name.
		 */
		plToBmFace[contour->points[faceNo].log.plateNo] = faceNm[i] ;
	}

} /* VSgetMassPropsMap */
/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
long VSnameContourFaces( msg, contour, plCount, plInfos,
			 type, nmIndices, plToBmFace )

long		*msg ;
VSxsPlContour	*contour ;
int		plCount ;
VSxsPlInfo	plInfos[] ;
int		*type,
		nmIndices[VS_K_sc_MAXFACES],
		plToBmFace[VS_K_MAX_XSPLATES] ; {
	/*
	 * Assigns a name to each side of the input contour, using a pattern
	 * recognition (pompous wording!) technique:
	 * the end points of the line segments makeing the countour are mapped
	 * to characters in a text space (one point -> one character (y -> row,
	 * x -> column), after ad hoc processing of the point coordinates.
	 * The resultant text is then compared with predifined patterns to find
	 * the shape of the profile (I,T, etc.), then its faces are named.
	 */
	long		sts ;
	int		nbLines,
			shapeType ;	/* Type of shape: I, L, etc	*/
	SHAPE_PATTERN	text ;

	/*
	 * Fill text space.
	 */
	sts = VScreateShapeText( msg, contour, text, &nbLines ) ;
	__CheckRC( sts, *msg, "VScreateShapeText", wrapup ) ;

	/*
	 * Now try to recognize shape.
	 */
	sts = VSgetShapeTypeFromText( msg, nbLines, text, &shapeType ) ;

	__DBGpr_int( "shapeType", shapeType ) ;

	if( ( *type = shapeType ) != VS_K_UNKNOWN_SHAPE ) {
		VSassignNamesToContourFaces(	contour,
						shapeType,
						nmIndices ) ;
		VSgetMassPropsMap(	 contour,
					 shapeType,
					 nmIndices,
					 plToBmFace ) ;
	}
	__DBGpr_int( "*type", *type ) ;

	wrapup :
		return sts ;

} /* VSnameContourFaces */
/*----------------------------------------------------------------------------*/
