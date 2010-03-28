class implementation ASnode ;

#include "AS_status.h"
#include "bserr.h"
#include "bsparameters.h"

extern double  BSdotp(),
	       BSdistptpts() ;

/*----------------------------------------------------------------------------*/
long ASisPtHiddenByElem( msg, elemId, elemEnv, pnt, viewVect, hidden )

long		*msg ;		/* Completion code.		*/
struct GRid	*elemId ;	/* Element Id.			*/
struct GRmd_env *elemEnv ;	/* Element Env. 		*/
IGRpoint	pnt ;		/* Point to check.		*/
IGRvector	viewVect ;	/* View vector. 		*/
int		*hidden  ;	/* TRUE -> Hidden point,	*/
				/* FALSE -> Visible point.	*/
/*.ASisPtHiddenByElem*/ {

	long		sts ;
	IGRpoint	p2,
			prjPnt,
			line_pt ;
	IGRvector	pntVec ;
	double		line_pm,
			tollenvec ;
	struct GRparms	prjParms ;
	struct IGRline	line ;

	*hidden = FALSE ;

	/*"Point : %g %g %g\n", pnt[0], pnt[1], pnt[2]*/
	/*"Element : [%d,%d]\n", elemId->osnum, elemId->objid*/

	/*
	 * Construct a line which haves the direction of view vector and
	 * go throught by the point to check.
	 */
	line.point1 = pnt ;
	line.point2 = p2 ;

	p2[0] = viewVect[0] + pnt[0] ;
	p2[1] = viewVect[1] + pnt[1] ;
	p2[2] = viewVect[2] + pnt[2] ;

	/*
	 * Project the constructed line onto element.
	 */
	sts = om$send( msg	= message GRgraphics.GRlnproject(
						msg,
						&elemEnv->md_env.matrix_type,
						elemEnv->md_env.matrix,
						&line,
						line_pt,
						prjPnt,
						&line_pm,
						&prjParms ),
		       senderid = elemId->objid,
		       targetid = elemId->objid,
		       targetos = elemId->osnum ) ;

	as$status( sts =  sts, action = GOTO_VALUE, value = wrapup ) ;
	as$status( sts = *msg, action = GOTO_VALUE, value = wrapup ) ;

	/*"Project point : %g %g %g\n", prjPnt[0], prjPnt[1], prjPnt[2]*/

	/*
	 * If the point of the line (line_pt) is different from the project
	 * point found, that means the point is visible.
	 */
	BSEXTRACTPAR( msg, BSTOLLENVEC, tollenvec ) ;

	if( BSdistptpts( msg, line_pt, prjPnt ) > tollenvec ) {
		/*|Point is VISIBLE*/
	} else {
		/*
		 * If the dot product between the vector (point to check,
		 * project point) and the view vector is >0 then the point is
		 * hidden.
		 */
		BSmkvec( msg, pntVec, pnt, prjPnt ) ;
		if( BSdotp( msg, viewVect, pntVec ) >0 ) {
			/*|Point is HIDDEN*/
			*hidden = TRUE ;
		} else {
			/*|Point is VISIBLE*/
		}
	}

	*msg = MSSUCC ;

	wrapup :
	return sts ;

} /* ASisPtHiddenByElem */
/*----------------------------------------------------------------------------*/

end implementation ASnode ;
