/*
	I/STRUCT

Abstract
	Sorts the two sub-surfaces which are results of a split done with the
	make-face message. The sort criterion is the following: the first
	surface is the one whose common edge with the other surface has the
	same orientation as the splitting curve.

Arguments
	OUT	long		*msg		Completion code
	IN	struct GRid	*surf1		First sub-surface to sort
	IN	struct GRid	*surf2		Second sub-surface to sort
	IN	struct GRmd_env	*surf_env	Module env. of surf1 and surf2
	IN	struct GRobj_env*curve		Splitting curve
	OUT	struct GRid	*first		First sub-surface after sorting
	OUT	struct GRid	*second		Second sub-surface after sorting

Note
	"first" and "second" may point to the same memory as "surf1" and
	"surf2".
*/
class implementation EMSsubbs ;

#include <stdlib.h>
#include "bstypes.h"
#include "growner.h"
#include "msdef.h"
#include "asmacros.h"
#include "vsdpb.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "bscveval.h"
#include "bsmdstptcv.h"
#include "bsdotp.h"
#include "ASbs_support.h"
#include "EMSutlmacros.h"

from	EMSedge	import	EMget_bcxyz_geom ;
/*----------------------------------------------------------------------------*/
long VSsort_sub_surfaces( msg, surf1, surf2, surf_env, curve, first, second )

long			*msg ;
struct GRid		*surf1,
			*surf2,
			*first,
			*second ;
struct GRmd_env 	*surf_env ;
struct GRobj_env	*curve ; {

	long		sts,		/* OM return code		*/
			bsRC ;		/* BS completion code		*/
	int		array_size,	/* For get-edges message	*/
			num_edges1,	/* Edge count in 1st surface	*/
			num_edges2,	/* Edge count in 2nd surface	*/
			ie1,		/* Loop-on-edges index		*/
			ie2,		/* Loop-on-edges index		*/
			found ;		/* Index of common edge		*/
	struct GRid	*edges1,	/* Edge list in 1st surface	*/
			*edges2,	/* Edge list in 2nd surface	*/
			Surf1,		/* So "first" and "second" may	*/
			Surf2 ;		/*  be the same as "surf[12]"	*/
	struct IGRbsp_curve
			bc_edge,	/* Geometry of common edge	*/
			*bc_curve ;	/* Geometry of input curve	*/
	double		dist,
			pt_curve[6],
			pt_edge[6],
			par_curve ;	/* Parameter on curve or edge	*/
	OM_S_CHANSELECT	edge_chan ;	/* Common-edge channel		*/

	edges1 = edges2 = NULL ;
	bc_edge.poles = bc_edge.knots = bc_edge.weights = NULL;

	Surf1 = *surf1 ; Surf2 = *surf2 ;
	array_size = 0 ;
	num_edges1 = 0 ;
	sts = om$send(	msg	= message EMSsubbs.EMget_edges(	msg,
								OM_K_MAXINT,
								EMS_OPT_ALL,
								surf_env,
								&edges1,
								&array_size,
								&num_edges1 ),
			senderid = Surf1.objid,
			targetid = Surf1.objid,
			targetos = Surf1.osnum);
	__CheckRC( sts, *msg, "EMSsubbs.EMget_edges", wrapup ) ;

	array_size = 0;
	num_edges2 = 0;
	sts = om$send(	msg	= message EMSsubbs.EMget_edges(	msg,
								OM_K_MAXINT,
								EMS_OPT_ALL,
								surf_env,
								&edges2,
								&array_size,
								&num_edges2 ),
			senderid = Surf2.objid,
			targetid = Surf2.objid,
			targetos = Surf2.osnum);
	__CheckRC( sts, *msg, "EMSsubbs.EMget_edges", wrapup ) ;

	ems$make_chanselect( chan_label    = EMSedge_to_common_edge,
			     chan_selector = &edge_chan ) ;

	/*
	 * Find common egde
	 */
	for( found = -1, ie1 = 0 ; ie1 < num_edges1 ; ie1++ ) {

		for( ie2 = 0 ; ie2 < num_edges2 ; ie2++ ) {

			sts = om$is_objid_on_channel(
					osnum_c		= edges1[ie1].osnum,
					objid_c		= edges1[ie1].objid,
					objid  		= edges2[ie2].objid,
					osnum2 		= edges2[ie2].osnum,
					p_chanselect	= &edge_chan ) ;
			if( sts & 1 ) {
				found = ie1 ;
				ie1 = num_edges1 ;
				ie2 = num_edges2 ;
			}
		}
	}

	if( found == -1 ) { *msg = MSFAIL ; goto wrapup ; }

	/* compute a point and tangent on edge 1 */

	sts = om$send(	msg	= message EMSedge.EMget_bcxyz_geom(
								msg,
								&surf_env->md_env,
								&Surf1,
								NULL,
								0,
								OM_K_MAXINT,
								FALSE,
								NULL,
								&bc_edge ),
			 senderid = edges1[found].objid,
			 targetid = edges1[found].objid,
			 targetos = edges1[found].osnum ) ;
	__CheckRC( sts, *msg, "EMSedge.EMget_bcxyz_geom", wrapup ) ;

	BScveval( &bc_edge, 0.5, 1, (IGRpoint *) pt_edge, &bsRC ) ;

	/* compute corresponding tangent on original curve */
  
	sts = as$getabsg( as_grid = &curve->_grid, bc = (char**) &bc_curve ) ;
	__CheckRC( sts, 1, "as$getabsg", wrapup ) ;

	BSmdstptcv( bc_curve, pt_edge, &par_curve, pt_curve, &dist, &bsRC ) ;
	BScveval( bc_curve, par_curve, 1, (IGRpoint *) pt_curve, &bsRC ) ;

	/*
	 * Sort surfaces using scalar product of tangent vectors.
	 */
	if( BSdotp( &bsRC, pt_curve + 3, pt_edge + 3 ) < 0 ) {
		*first = Surf2 ; *second = Surf1 ;
	} else {
		*first = Surf1 ; *second = Surf2 ;
	}
	wrapup :
		_FREE( edges1 ) ;
		_FREE( edges2 ) ;
		_FREE( bc_edge.poles ) ;
		_FREE( bc_edge.knots ) ;
		_FREE( bc_edge.weights);

		return *msg & 1 ;

} /* VSsort_sub_surfaces */
/*----------------------------------------------------------------------------*/

end implementation EMSsubbs ;
