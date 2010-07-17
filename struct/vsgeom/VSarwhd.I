/*
	I/STRUCT
*/
class implementation GR3dlinestr ;

#include "bstypes.h"
#include "EMSmsgdef.h"
#include "vsmiscmacros.h"
/*
 * Includes of function prototypes.
 */
#include "bscrossp.h"
#include "vsvecmxproto.h"

#define LENGTH_FRACTION	0.25
#define LENGTH_FACTOR_1	0.85
#define LENGTH_FACTOR_2	0.075
/*----------------------------------------------------------------------------*/
long VScstArrowHead( msg, origin, tangent, normal, cst, size, length,
			viewIndep, arrow )

long			*msg ;
IGRpoint		origin ;	/* Origin of arrow head		*/
IGRvector		tangent,	/* Unit tangent vector		*/
			normal ;	/* Unit normal vector		*/
struct GRvg_construct	*cst ;		/* For arrow head		*/
double			size,		/* Size of arrow		*/
			length ;	/* Some characteristic length	*/
int			viewIndep ;	/* View independent ?		*/
struct GRid		*arrow ; {	/* Id of created arrow head	*/

	long		sts,			/* OM return code	*/
			bsRC ;			/* BS return code	*/
	int		i,			/* Loop index		*/
			j ;			/* Loop index		*/
	IGRpoint	arwPoint[2],		/* Arrow end points	*/
			arwHead[2][3] ;		/* Head points		*/
  	IGRvector	normals[2],		/* Both normals		*/
  			binormal ;		/* The other normal	*/
	struct IGRpolyline
			linestring ;		/* Line string data	*/
	double		ptList[21],		/* Line string points	*/
			val1,			/* Temp. value		*/
			val2,			/* Temp. value		*/
			delta ;			/* Temp. value		*/
	struct GRvg_construct
			locCst ;		/* For line string	*/
	extern OMuword	OPP_GR3dlinestr_class_id ;

	/*
	 * If arrow size is input, take it, else use the characteristic
	 * length.
	 */
	if( size > 0 )	length = size ;
	else		length *= LENGTH_FRACTION ;
	/*
	 * Create end points of arrow body.
	 */
	for( i = 0 ; i < 3 ; i++ ) {
		arwPoint[0][i] = origin[i] ;
		arwPoint[1][i] = origin[i] + length * tangent[i] ;
	}

	/*
	 * Generate another normal which is perpendicular to the normal
	 * (supposed to be a unit vector) and the tangent vector.
	 */
	BScrossp( &bsRC, tangent, normal, binormal ) ;
	VSvccpy( &normals[0][0], normal   ) ;
	VSvccpy( &normals[1][0], binormal ) ;

	for( j = 0 ; j < 2 ; j++ ) {
    		for( i = 0 ; i < 3 ; i++ ) {
    			delta = length * tangent[i] ;

			val1 = arwPoint[0][i] + LENGTH_FACTOR_1 * delta ;
			val2 = LENGTH_FACTOR_2 * length * normals[j][i] ;
			/*
			 * Here `delta' is used to move back arrow head points
			 * to the origin.
			 */
			arwHead[j][0][i] = val1 + val2		- delta ;
			arwHead[j][1][i] = arwPoint[1][i]	- delta ;
			arwHead[j][2][i] = val1 - val2		- delta ;
    		}
	}

	/*
	 * Construct line string representing arrow head.
	 */
	linestring.points	= ptList ;
	if( viewIndep ) {
		linestring.num_points	= 7 ;
	} else {
		linestring.num_points	= 3 ;
	}		

	VSvccpy( ptList +  0, &arwHead[0][0][0] ) ;	/* 0 */
	VSvccpy( ptList +  3, &arwHead[0][1][0] ) ;	/* 1 */
	VSvccpy( ptList +  6, &arwHead[0][2][0] ) ;	/* 2 */
	VSvccpy( ptList +  9, &arwHead[0][1][0] ) ;	/* 3 */
	VSvccpy( ptList + 12, &arwHead[1][0][0] ) ;	/* 4 */
	VSvccpy( ptList + 15, &arwHead[1][1][0] ) ;	/* 5 */
	VSvccpy( ptList + 18, &arwHead[1][2][0] ) ;	/* 6 */

	locCst		= *cst ;
	locCst.msg	= msg ;
	locCst.geometry	= (char *) &linestring ;

	*msg = EMS_E_OMerror ;
	arrow->osnum = locCst.env_info->_MD_OS ;

	sts = om$construct(	classid	= OPP_GR3dlinestr_class_id,
				osnum	= arrow->osnum,
				p_objid	= &arrow->objid ) ;

	if( sts & 1 ) {
		sts = om$send(	msg	= message GRgraphics.GRaltconstruct(
								&locCst ),
				senderid= arrow->objid,
				targetid= arrow->objid,
				targetos= arrow->osnum ) ;
		if( !( sts & 1 & *msg ) ) {
			om$send(msg	= message Root.delete( 0 ),
				senderid= arrow->objid,
				targetid= arrow->objid,
				targetos= arrow->osnum ) ;
		}
	}

	return sts ;

} /* VScstArrowHead */
/*----------------------------------------------------------------------------*/

end implementation GR3dlinestr ;
