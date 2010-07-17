/*
	I/STRUCT
*/ 
class implementation VSproffrplts ;

#include "OMmacros.h"
#include "EMSmsgdef.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"
#include "vssectiondef.h"
#include "vsxsfpmacros.h"
#include "vsmiscmacros.h"
#include "vsdatamacros.h"
#include "vsdbgmacros.h"

extern OMuword		OPP_GRcompcurve_class_id ;
extern OMuword		OPP_VSxscurve_class_id ;
extern void		VSgetContourRange() ;
extern void		VStranslateContour() ;

from GRcurve		import GRrevparm ;
from GRcompcurve	import EMmakecomp ;
from VScompcurve	import VSinitMapping ;
/*----------------------------------------------------------------------------*/
method ACconstruct_feet(long		*msg ;
			int		purpose,
					count ;
			struct GRid	list[] ;
			struct GRmd_env	*MyEnv ;
			int		*feetCount ;
			struct GRid 	*feetList ) {

#define MAX		VS_K_MAXCNTPTS

	long		sts,		/* OM return code		*/
			badCv ;		/* Bad curve in composite	*/
	struct GRvg_construct
			cst ;		/* My construction list		*/
	struct GRsymbology
			mySymb ;	/* My symbology			*/
	int		nbPlates,	/* Count of plate defs		*/
			nbCnxs,		/* Count of connections		*/
			i ;		/* Loop index			*/
	VSxsPlContour	contour ;	/* Contour of connected plates	*/
	VS2dPoint	range[2],	/* Range of contour		*/
			origin ;	/* Origin of contour		*/
	IGRpoint	pts[MAX] ;	/* Point coords for 3D contour	*/
	struct GRid	lSegs3D[MAX],	/* Line segments of 3D contour	*/
			lSegsEnv[4],	/* Line segments of env. contour*/
			compCv3D,	/* Composite curve for 3D rep	*/
			compCvEnv ;	/* Composite curve for env. rep	*/
	struct GRlc_info
			lsInfo[MAX] ;	/* Info for line segments	*/
	struct ret_struct
			CSrs ;		/* Returned structure of CS	*/
	VSxsPlShpDesc	shapeDescr ;	/* Description of contour shape	*/

	compCv3D.objid = compCvEnv.objid = NULL_OBJID ;
	VSsetGRids( MyEnv->_MD_OS, MAX, lSegs3D ) ;
	VSsetGRids( MyEnv->_MD_OS,   4, lSegsEnv) ;

	nbPlates = om$dimension_of( varray = me->plateDefs ) ;
	nbCnxs	 = om$dimension_of( varray = me->plateCnxs ) ;
	if( !nbPlates ) vs$inv_arg() ;

	sts = om$send(	msg	= message NDnode.NDgive_structure(
							msg, &CSrs, MyEnv ),
			targetid= list[0].objid,
			targetos= list[0].osnum ) ;
	__CheckRC( sts, *msg, "NDnode.NDgive_structure", wrapup ) ;

	origin.x = CSrs.var.ref_st.t[3] ;
	origin.y = CSrs.var.ref_st.t[7] ;
#ifdef vsDEBUG
	VSdump2dPt( "Origin", &origin ) ;
#endif

	sts = vs$getContour(	msg		= msg,
				nbPlates	= nbPlates,
				plates		= me->plateDefs,
				nbCnxs		= nbCnxs,
				connections	= me->plateCnxs,
				contour		= &contour,
				shapeDescr	= &shapeDescr ) ;
	__CheckRC( sts, *msg, "vs$getContour", wrapup ) ;

	if( shapeDescr.shapeType == VS_K_UNKNOWN_SHAPE ) vs$inv_arg() ;

#ifdef vsDEBUG
	{ VSxsPlParms	parms ;
		VSgetContourParameters( msg, &contour,
				shapeDescr.shapeType, shapeDescr.nmIndices, &parms);
		printf( "\tWidth	%g\n", parms.width ) ;
		printf( "\tHeight	%g\n", parms.height ) ;
		printf( "\tFlg thk	%g\n", parms.flgThickness ) ;
		printf( "\tWeb thk	%g\n", parms.webThickness ) ;
	}

#endif

	VStranslateContour( &origin, &contour ) ;

	/*
	 * Convert 2D points to 3D points, set z-coordinate to 0, we shall
	 * construct the contour in the z=0 plane. Since contour is closed,
	 * # of points = # of line segments.
	 */
	for( i = 0 ; i < contour.npoints ; i++ ) {
		pts[i][0] = contour.points[i].coord.x ;
		pts[i][1] = contour.points[i].coord.y ;
		pts[i][2] = 0 ;
	}

	/*
	 * Fill construction list.
	 */
	sts = om$send(	msg	= message GRvg.GRgetsymb( msg, &mySymb ),
			mode	= purpose & VS_K_InitialPlacement
					? OM_e_wrt_message
					: OM_e_wrt_object,
			targetid= my_id ) ;
	__CheckRC( sts, *msg, "GRvg.GRgetsymb", wrapup ) ;

	vs$fill_cnst_list(	Env_info	= MyEnv,
				Display		= &mySymb.display_attr,
				Level		= mySymb.level,
				Cnst_list	= cst ) ;

	/*
	 * Construct line segments joining points so as to make a CLOSED
	 * contour.
	 */
	sts = VSjointPtsWithLineSegs( msg, contour.npoints, pts, &cst,
				      lSegs3D ) ;
	__CheckRC( sts, *msg, "VSjointPtsWithLineSegs", wrapup ) ;

	/*
	 * Create composite curve.
	 */
	compCv3D.osnum = cst.env_info->_MD_OS ;
	sts = om$construct(	classid	= OPP_VSxscurve_class_id,
				osnum	= compCv3D.osnum,
				p_objid	= &compCv3D.objid ) ;
	if( !( sts & 1 ) ) vs$om_error( sts = sts ) ;

	for( i = 0 ; i < contour.npoints ; i++ ) {
		lsInfo[i].located_obj	= lSegs3D[i] ;
		lsInfo[i].module_info	= *cst.env_info ;
	}
	sts = om$send(	msg	= message GRcompcurve.EMmakecomp(
								msg,
								cst.env_info,
								contour.npoints,
								lsInfo,
								&badCv ),
			targetid= compCv3D.objid,
			targetos= compCv3D.osnum ) ;
	__CheckRC( sts, *msg, "GRcompcurve.EMmakecomp", wrapup ) ;

	sts = om$send(	msg	= message VScompcurve.VSinitMapping(
						msg, shapeDescr.nmIndices ),
			targetid= compCv3D.objid,
			targetos= compCv3D.osnum ) ;
	__CheckRC( sts, *msg, "VScompcurve.VSinitMapping", wrapup ) ;

	/*
	 * Since the contour points where given counter-clockwise and we have
	 * the convention of clockwise-oriented profiles, we reverse the para-
	 * metrization.
	 */
	sts = om$send(	msg	= message GRcurve.GRrevparm( msg, cst.env_info),
			targetid= compCv3D.objid,
			targetos= compCv3D.osnum ) ;
	__CheckRC( sts, *msg, "GRcurve.GRrevparm", wrapup ) ;

#ifdef vsDEBUG
	sts = om$send(	msg	= message Root.debug(),
			targetid= compCv3D.objid,
			targetos= compCv3D.osnum ) ;

	{ VSxsPlParms	parms ;
		VSgetContourParameters( msg, &contour, shapeDescr.shapeType,
						shapeDescr.nmIndices, &parms);
		printf( "\tWidth	%g\n", parms.width ) ;
		printf( "\tHeight	%g\n", parms.height ) ;
		printf( "\tFlg thk	%g\n", parms.flgThickness ) ;
		printf( "\tWeb thk	%g\n", parms.webThickness ) ;
	}

#endif
	/*
	 * Create envelope curve, use range of contour.
	 */
	VSgetContourRange( &contour, range ) ;

	pts[0][0] = range[0].x ; pts[0][1] = range[0].y ;
	pts[1][0] = range[1].x ; pts[1][1] = range[0].y ;
	pts[2][0] = range[1].x ; pts[2][1] = range[1].y ;
	pts[3][0] = range[0].x ; pts[3][1] = range[1].y ;

	sts = VSjointPtsWithLineSegs( msg, 4, pts, &cst, lSegsEnv ) ;
	__CheckRC( sts, *msg, "VSjointPtsWithLineSegs", wrapup ) ;

	for( i = 0 ; i < 4 ; i++ ) {
		lsInfo[i].located_obj	= lSegsEnv[i] ;
		lsInfo[i].module_info	= *cst.env_info ;
	}

	compCvEnv.osnum = cst.env_info->_MD_OS ;
	sts = om$construct(	classid	= OPP_GRcompcurve_class_id,
				osnum	= compCvEnv.osnum,
				p_objid	= &compCvEnv.objid ) ;
	if( !( sts & 1 ) ) vs$om_error( sts = sts ) ;

	sts = om$send(	msg	= message GRcompcurve.EMmakecomp(
								msg,
								cst.env_info,
								4,
								lsInfo,
								&badCv ),
			targetid= compCvEnv.objid,
			targetos= compCvEnv.osnum ) ;
	__CheckRC( sts, *msg, "GRcompcurve.EMmakecomp", wrapup ) ;

	*feetCount	= 2 ;
	feetList[0]	= compCv3D ;
	feetList[1]	= compCvEnv;

	*msg	= MSSUCC ;
	sts	= OM_S_SUCCESS ;

	wrapup :
		if( !( sts & 1 & *msg ) ) {

			vs$bulk_delete(	grids	= &compCv3D,
					theEnv	= MyEnv ) ;
			vs$bulk_delete(	grids	= &compCvEnv,
					theEnv	= MyEnv ) ;
			vs$bulk_delete(	grids	= lSegs3D,
					count	= MAX,
					theEnv	= MyEnv ) ;
			vs$bulk_delete(	grids	= lSegsEnv,
					count	= 4,
					theEnv	= MyEnv ) ;
		}
		return sts ;

} /* method ACconstruct_feet */
/*----------------------------------------------------------------------------*/

end implementation VSproffrplts ;

