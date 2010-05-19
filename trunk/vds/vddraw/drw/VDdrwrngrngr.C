/* $Id: VDdrwrngrngr.C,v 1.2 2001/02/15 00:36:04 ramarao Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	vddraw/drw/Vddrwrngrngr.C
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDdrwrngrngr.C,v $
 *	Revision 1.2  2001/02/15 00:36:04  ramarao
 *	Removed v_dbgmacros.h include file.
 *	
 *	Revision 1.1.1.1  2001/01/04 21:08:37  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.1  1996/07/19  20:33:52  pinnacle
 * Create VDS 241 project
 *
 * Revision 1.1  1995/06/27  18:28:28  pinnacle
 * Created: vddraw/drw/VDdrwrngrngr.C by azuurhou for vds.240
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *			adz		creation date
 *
 ***************************************************************************/

#include <stdio.h>
#include "OMminimum.h"
#include "OMerrordef.h"
#include "bsparameters.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "bstypes.h"
#include "ma.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "godef.h"
#include "go.h"
#include "msdef.h"
#include "v_vedef.h"
/*
 * Includes of function prototypes.
 */
#include "bsbxint.h"
#include "bsxtractpar.h"
#include "maoptsxfo.h"
#include "matypemx.h"
#include "mayrotmx.h"
#include "v_visedproto.h"

/*----------------------------------------------------------------------------*/
long VD_veRangeRangeRelationShip( msg, range0, range1, viewVector, relationship )

long		*msg ;
const GRrange 	range0 ;
const GRrange 	range1 ;
const IGRvector	viewVector ;
int		*relationship ; {

	/*
	 * This function determines either if range #0 and range #1 intersect,
	 * if range #0 total hides range #1, if range #0 partial hides
	 * range #1, if range #0 is in front of range #1 or range #0 is at the
	 * back of range #1 with respect to the view vector.
	 *
	 * Return value of 'relationship' ( defined in vsvedef.h ) :
	 * =========================================================
	 *
	 * - range #0 and range #1 intersect	: VD_K_INTERSECT
	 * - range #0 totally hides range #1	: VD_K_0_TOTALLY_HIDES_1
	 * - range #0 partially hides range #1	: VD_K_0_PARTIALLY_HIDES_1
	 * - range #0 is in front of range #1	: VD_K_0_IN_FRONT_OF_1
	 * - range #0 is behind of range #1	: VD_K_0_AT_THE_BACK_OF_1
	 *
	 */

	long		sts,		/* Completion code.		      */
			bsRC,		/* BS return code.		      */
			num_pts ;	/* Number of corner points.	      */
	int		i ;		/* Loop index.			      */
	double		matrix[16],	/* Matrix of rotation of new system   */
					/*  where view vector is the y-axis   */
			tol,tols,	/* basis tolerance range offsets      */
			corner0[8*3],	/* Corner points of range #0.	      */
			corner1[8*3] ;	/* Corner points of range #1.	      */
	short		matrix_type ;	/* Matrix type of the above.	      */
	GRrange 	n_range0,	/* Range #0 in new coordinate system. */
			n_range1 ;	/* Range #1 in new coordinate system. */
	GRrange		rng0 ;		/* Virtual Range with tolerance offset*/

	sts  = OM_S_SUCCESS ;
	*msg = MSSUCC ;

/**
	__DBGpr_vec( "Min of range #0", range0	  ) ;
	__DBGpr_vec( "Max of range #0", range0 +3 ) ;
	__DBGpr_vec( "Min of range #1", range1	  ) ;
	__DBGpr_vec( "Max of range #1", range1 +3 ) ;
	__DBGpr_vec( "View vector", viewVector	  ) ;
 **/

	/*
	 * Reduce the range of the reference object a fraction smaller to
	 * avoid unnecessary comparison of edges and reference surfaces.
	 */
	
	BSxtractpar( &bsRC, BSTOLBASIS, & tol );
	tols = 20 * tol ;
	tol  = 10 * tol ;
	for( i=0; i<3 ; i++ ){
		if( range0[i+3] - range0[i] > tols ){
			rng0[i]   = range0[i]   + tol ;
			rng0[i+3] = range0[i+3] - tol ;
		}
		else{
			rng0[i]   = range0[i] ;
			rng0[i+3] = range0[i+3] ;
		}
	}

	/*
	 * See if the two ranges intersect.
	 */
	if( BSbxint( &bsRC, (double*) rng0,
			    (double*)(rng0 +3),
			    (double*) range1,
			    (double*)(range1 +3) ) ) {
		*relationship = VD_K_INTERSECT ;
		goto wrapup ;
	}

	/*
	 * Find rotation matrix where the view vector is the y-axis.
	 */
	MAyrotmx( &bsRC, (double*) viewVector, matrix ) ;

/**
	__DBGpr_mat( "Rotation matrix", matrix ) ;
 **/

	MAtypemx( &bsRC, matrix, &matrix_type ) ;

	/*
	 * Find 8 corner points of the two ranges.
	 *
	 *	    7---------------- 6
	 *	    /.		    /|
	 *	   / .		   / |
	 *	  /  .		  /  |
	 *	 /   .		 /   |
	 *     3-----------------2   |
	 *	|    .		|    |
	 *	|   4...........|..../5
	 *	|   .		|   /
	 *	|  .		|  /
	 *	| .		| /
	 *	|.		|/
	 *	-----------------
	 *	0		1
	 */
	corner0[ 0] = corner0[ 9] = corner0[12] = corner0[21] = rng0[0] ;
	corner0[ 1] = corner0[ 4] = corner0[ 7]	= corner0[10] = rng0[1] ;
	corner0[ 2] = corner0[ 5] = corner0[14] = corner0[17] = rng0[2] ;
	corner0[ 3] = corner0[ 6] = corner0[15] = corner0[18] = rng0[3] ;
	corner0[13] = corner0[16] = corner0[19] = corner0[22] = rng0[4] ;
	corner0[ 8] = corner0[11] = corner0[20] = corner0[23] = rng0[5] ;

	corner1[ 0] = corner1[ 9] = corner1[12] = corner1[21] = range1[0] ;
	corner1[ 1] = corner1[ 4] = corner1[ 7]	= corner1[10] = range1[1] ;
	corner1[ 2] = corner1[ 5] = corner1[14] = corner1[17] = range1[2] ;
	corner1[ 3] = corner1[ 6] = corner1[15] = corner1[18] = range1[3] ;
	corner1[13] = corner1[16] = corner1[19] = corner1[22] = range1[4] ;
	corner1[ 8] = corner1[11] = corner1[20] = corner1[23] = range1[5] ;

	/*
	 * Compute the two ranges in the new system.
	 */
	num_pts = 8 ;

	MAoptsxform( &bsRC, &num_pts, &matrix_type, matrix, corner0, corner0 ) ;
	MAoptsxform( &bsRC, &num_pts, &matrix_type, matrix, corner1, corner1 ) ;

	n_range0[0] = n_range0[1] = n_range0[2] = GRDGNLIMITS_MAX_D ;
	n_range0[3] = n_range0[4] = n_range0[5] = GRDGNLIMITS_MIN_D ;

	n_range1[0] = n_range1[1] = n_range1[2] = GRDGNLIMITS_MAX_D ;
	n_range1[3] = n_range1[4] = n_range1[5] = GRDGNLIMITS_MIN_D ;

	for( i=0; i<num_pts; i++ ) {
		n_range0[0] = corner0[3*i  ] < n_range0[0] ? corner0[3*i  ]
							   : n_range0[0] ;
		n_range0[1] = corner0[3*i+1] < n_range0[1] ? corner0[3*i+1]
							   : n_range0[1] ;
		n_range0[2] = corner0[3*i+2] < n_range0[2] ? corner0[3*i+2]
							   : n_range0[2] ;
		n_range0[3] = corner0[3*i  ] > n_range0[3] ? corner0[3*i  ]
							   : n_range0[3] ;
		n_range0[4] = corner0[3*i+1] > n_range0[4] ? corner0[3*i+1]
							   : n_range0[4] ;
		n_range0[5] = corner0[3*i+2] > n_range0[5] ? corner0[3*i+2]
							   : n_range0[5] ;

		n_range1[0] = corner1[3*i  ] < n_range1[0] ? corner1[3*i  ]
							   : n_range1[0] ;
		n_range1[1] = corner1[3*i+1] < n_range1[1] ? corner1[3*i+1]
							   : n_range1[1] ;
		n_range1[2] = corner1[3*i+2] < n_range1[2] ? corner1[3*i+2]
							   : n_range1[2] ;
		n_range1[3] = corner1[3*i  ] > n_range1[3] ? corner1[3*i  ]
							   : n_range1[3] ;
		n_range1[4] = corner1[3*i+1] > n_range1[4] ? corner1[3*i+1]
							   : n_range1[4] ;
		n_range1[5] = corner1[3*i+2] > n_range1[5] ? corner1[3*i+2]
							   : n_range1[5] ;
	}

/**
	__DBGpr_vec( "New min of range #0", n_range0	) ;
	__DBGpr_vec( "New max of range #0", n_range0 +3 ) ;
	__DBGpr_vec( "New min of range #1", n_range1	) ;
	__DBGpr_vec( "New max of range #1", n_range1 +3 ) ;
 **/

	/*
	 * See if range #0 is at the back of range #1.
	 */
	if( n_range0[1] < n_range1[1] ) {
		*relationship = VD_K_0_AT_THE_BACK_OF_1 ;
		goto wrapup ;
	}

	/*
	 * See if range #0 totally hides range #1.
	 */
	if( n_range1[0] >= n_range0[0]	&&
	    n_range1[0] <= n_range0[3]	&&
	    n_range1[2] >= n_range0[2]	&&
	    n_range1[2] <= n_range0[5]	&&
	    n_range1[3] >= n_range0[0]	&&
	    n_range1[3] <= n_range0[3]	&&
	    n_range1[5] >= n_range0[2]	&&
	    n_range1[5] <= n_range0[5]	) {
		*relationship = VD_K_0_TOTALLY_HIDES_1 ;
		goto wrapup ;
	}

	/*
	 * See if range #0 partially hides range #1.
	 */
	if( n_range0[3] < n_range1[0]	||
	    n_range0[5] < n_range1[2]	||
	    n_range0[0] > n_range1[3]	||
	    n_range0[2] > n_range1[5]	) {
		*relationship = VD_K_0_IN_FRONT_OF_1 ;
	} else {
		*relationship = VD_K_0_PARTIALLY_HIDES_1 ;
	}

	wrapup :
		return sts ;

} /* VD_veRangeRangeRelationShip */
/*----------------------------------------------------------------------------*/
