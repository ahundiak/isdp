/* $Id: VSplcskinsrf.I,v 1.2 2002/06/05 21:03:56 ramarao Exp $ */
/* --------------------------------------------------------------------
 * I/STRUCT
 *
 * File:        struct/vsbmsupp/VSplcskinsrf.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VSplcskinsrf.I,v $
 *	Revision 1.2  2002/06/05 21:03:56  ramarao
 *	*** empty log message ***
 *	
 *	Revision 1.1.1.1  2001/01/04 21:10:21  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.3  1998/02/20  20:26:00  pinnacle
# CR179800676
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *	02/20/96	K.V.Suresh	
 *	01/22/98	adz		Changes trace/cross entries.
 *	02/20/98        ah              Pinnacle Header did not have log in it				
 * -------------------------------------------------------------------*/

class implementation Root;

#include "OMprimitives.h"
#include "EMSmsgdef.h"
#include "OMmacros.h"
#include "nddef.h"
#include "vsplatedef.h"
#include "vsbmsuppdef.h"
#include "vsedgedef.h"
#include "vsedgemacros.h"
#include "vsjointdef.h"
#include "vsdatamacros.h"
#include "vsmiscmacros.h"
#include "vsgeommacros.h"
#include "vsdbgmacros.h"
#include "bserr.h"
#include "madef.h"

/*
 * Include of prototypes
 */
#include "vsvecmxproto.h"
#include "mainvmx.h"
#include "bscveval.h"
#include "bsnorvec.h"
#include "bsprptonsf.h"
#include "bscrossp.h"
#include "bsmdistptcv.h"
#include "bsparameters.h"
#include "maidmx.h"
#include "mamulmx.h"
#include "matypemx.h"

from GRcurve	import	GRtotlength ;
from GRgraphics import	GRaltconstruct,
			GRxform ;
from EMSgenbs	import	EMplace_skinning_surface ;

extern OMuword	OPP_GR3dlineseg_class_id ;
extern OMuword	OPP_EMSgenbs_class_id ;

extern long 	VSgetRelativeAngle(),
		VSgetModifParams() ;
/*---------------------------------------------------------------------------*/
long	VSgetXformMx(	long		*msg,	    /* O:return code	     */
			IGRvector	xDir,	    /* I:x-dirction of the CS*/
			IGRvector	yDir,	    /* I:y-dirction of the CS*/
			IGRvector	zDir,	    /* I:z-dirction of the CS*/
			IGRpoint	pntOnCurve, /* I:Point On curve where
							 CS to be defined    */
			double		angle,	    /* I:the angle of rotation
							 in radians	     */
			IGRmatrix	xCS )	    /* O:the transformation 
							 matrix 	     */
{
	long		bsRC;
	IGRmatrix	csAtSite,
			auxMx1,
			auxMx2,
			auxMx3,
			auxMx4,
			rotMx ;
	double		*mapMx ;
	IGRvector	vector ;
	short		mxSize = 4;
	double		rotInv[16] ;
	IGRboolean	stsFlag ;       

	angle *= -1.0 ;
/*
	memset ( csAtSite, 0, sizeof(IGRmatrix) );
	memset ( auxMx1  , 0, sizeof(IGRmatrix) );
	memset ( auxMx2  , 0, sizeof(IGRmatrix) );
	memset ( auxMx3  , 0, sizeof(IGRmatrix) );
	memset ( auxMx4  , 0, sizeof(IGRmatrix) );
	memset ( rotMx   , 0, sizeof(IGRmatrix) );
	memset ( rotInv  , 0, sizeof(IGRmatrix) );
	memset ( xCS     , 0, sizeof(IGRmatrix) );
*/
	/*
	 * Fill an Identity matrix
	 */
	MAidmx( &bsRC, auxMx1 );
        
	/*
	 * Rotate the matrix with the given angle 'angle' must be in radians
	 */
	mapMx = VSrotatemx( angle, auxMx1, rotMx ) ;
	__DBGpr_mat( "rotaion at base CS", rotMx) ;

	stsFlag = MAinvmx(&bsRC,&mxSize, rotMx, rotInv) ;

	__DBGpr_vec(" X - Direction", xDir );
	__DBGpr_vec(" Y - Direction", yDir );
	__DBGpr_vec(" Z - Direction", zDir );

	/*
	 * Make a matrix with the given x,y,z Direction
	 */ 
	VSmkmatrix( VSzerovc( vector ), xDir, yDir, zDir, auxMx2 ) ;
        
	/*
	 * now translate the matrix to the point on curve
	 */
	mapMx = VStranslatemx( pntOnCurve, auxMx2, csAtSite ) ;
	__DBGpr_mat( "Site CS", csAtSite) ;
        
	stsFlag = MAinvmx(&bsRC,&mxSize, csAtSite, mapMx) ;

	/*
	 * Apply the rotation matrix only
	 */
	MAmulmx( &bsRC, &mxSize, &mxSize, &mxSize, rotInv, mapMx,auxMx3  ) ;

	MAmulmx( &bsRC, &mxSize, &mxSize, &mxSize, auxMx2, auxMx3, auxMx4 ) ;
        
	/*
	 * Now do the the translation so that the newCS will be on the curve
	 */
	mapMx = VStranslatemx( pntOnCurve, auxMx4, xCS ) ;
	__DBGpr_mat( "CS", xCS ) ;

	*msg = MSSUCC ;

	return OM_S_SUCCESS ;

} /*  VSgetXformMx */
/*---------------------------------------------------------------------------*/
long	VSgetXdirForTwist(
long			*msg,		/* O return code		  */
struct GRobj_env	axis,		/* I Axis of the beam		  */
struct GRobj_env	plSupp, 	/* I Plate side of stiffener	  */
double			parmOnCurve,	/* I parm value on axis 	  */
struct GRvg_construct	*cst,		/* I Construction list		  */
double			angle,		/* I angle of rot about normal	  */
struct GRid		*lineObj,	/* O Line segment in Xdir if NULL */
					/*   no object is constructed	  */
IGRmatrix		csMx	)	/* O local cs without without     */
					/*   applying the rotation 'angle'*/
{
	long			sts ;
	struct IGRbsp_curve	*cvGeom;
	struct IGRbsp_surface	*sfGeom ;
	struct IGRpolyline	polyline;
	struct GRvg_construct	newCst ;
	int			i ;
	IGRmatrix		auxMx1 ;
	double			*mapMx ;
	double			dist,
				upar, 
				vpar,
				parms[2],
				line[6],
				eval[6] ;
	IGRvector		xDir,
				yDir, 
				zDir,
				vector ;
	IGRboolean		onSurf, 
				stsFlag ;
	IGRpoint		pt ;
	IGRmatrix		transMx ;
	IGRshort		transMxType;

	cvGeom = NULL ;
	sfGeom = NULL ;
	
	sts = MSFAIL ;
	if(lineObj) lineObj->objid = NULL_OBJID ;

	/*
	 * Get the geometry of the axis( curve )
	 */
	vs$get_geometry(	msg	= msg,
				grobjId = &axis._grid,
				grobjEnv= &axis.mod_env,
				geometry= &cvGeom );
	__CheckRC( 1, *msg, "vs$get_geometry", wrapup ) ;

	/*
	 * Get the geometry of the plate side surface
	 */
	vs$get_geometry(	msg	= msg,
				grobjId = &plSupp._grid,
				grobjEnv= &plSupp.mod_env,
				geometry= &sfGeom );
	__CheckRC( 1, *msg, "vs$get_geometry", wrapup ) ;

	/*
	 * Get the point and the tangent of the curve at the 
	 * given parameter  'parmOnCurve'
	 */
	BScveval( cvGeom, parmOnCurve, 1, (IGRpoint *) eval, msg ) ;
	if( BSERROR( *msg ) ) { *msg = EMS_E_BSerror ; goto wrapup ; }

	/*
	 * Normalise the tangent vector
	 */
	BSnorvec( msg, eval + 3 ) ;

	/*
	 * the tangent vector will be the z-direction of the new C.S
	 */
	for( i=0; i<3; i++ ) {
		pt[i] = eval[i] ;
		zDir[i] = eval[i+3];
	}

	/*
	 * get the paramters of the surface at the point on the curve
	 */
	stsFlag = BSprptonsf( msg, sfGeom, pt, &upar, &vpar, &onSurf );
	if( BSERROR( *msg ) ) { *msg = EMS_E_BSerror ; goto wrapup ; }

	parms[0] = upar ;
	parms[1] = vpar ;

	/*
	 * get the normal of the surface at the params
	 */
	vs$get_normal(	msg    = msg ,
			sfId   = &plSupp._grid ,
			sfEnv  = &plSupp.mod_env ,
			parm   = parms ,
			normal = yDir );
	__CheckRC( 1, *msg, "vs$get_normal", wrapup ) ;

	/*
	 * Noraml to the surface at the params will be the y-direction
	 */
	BSnorvec( msg, yDir ) ;

	/*
	 * The cross product results in the x-direction
	 */
	stsFlag = BScrossp(msg, yDir, zDir,xDir);
	if( BSERROR( *msg ) ) { *msg = EMS_E_BSerror ; goto wrapup ; }

	BSnorvec( msg, xDir ) ;

	/*
	 * Make a matrix with the given x,y,z Direction
 	 */
	VSmkmatrix( VSzerovc( vector ), xDir, yDir, zDir, auxMx1 ) ;
	
	/*
	 * now translate the matrix to the point on curve
	 */
	mapMx = VStranslatemx( eval+0, auxMx1, csMx ) ;
	__DBGpr_mat( "Site CS", csMx) ;

	if( lineObj == NULL )  {

		*msg = MSSUCC ;

		_FREE(cvGeom) ;
		_FREE(sfGeom) ;		

		return OM_S_SUCCESS ;
	}

	lineObj->objid = NULL_OBJID ;

/*	dist = 100.0; */
	{
	IGRdouble len ;
	sts = om$send( msg =message GRcurve.GRtotlength(
					msg,
					&axis.mod_env._MATRIX_TYPE,
					axis.mod_env._MATRIX,
					&len ),
			senderid = axis._objid ,
			targetid = axis._objid ,
			targetos = axis._osnum );
	dist = len/10;
	}
	
	/*
	 * fill the points to construct a line segment
	 */
	for( i=0 ; i<3 ; i++ ) {
		line[i]  = eval[i] - xDir[i]*dist ;
		line[i+3]= eval[i] + xDir[i]*dist ;
	}
//	printf("line = %lg, %lg, %lg, %lg, %lg, %lg\n",line[0],line[1],line[2],line[3],line[4],line[5]);

	polyline.num_points = 2 ;
	polyline.points = line ;

	/*
	 * Fill the new construction with the line geometry 
	 */
	vs$fill_cnst_list(	Msg		= msg,
				Env_info	= cst->env_info,
				Display 	= cst->display,
				Level		= cst->level,
				Properties 	= 0,
				Geometry	= &polyline,
				Cnst_list	= newCst ) ;

	lineObj->osnum = axis._osnum ;

	om$construct(	classid = OPP_GR3dlineseg_class_id ,
			osnum	= axis._osnum ,
			p_objid = &lineObj->objid );
	__DBGpr_obj("lineOj", *lineObj );

	/*
	 * Construct the line segment
	 */
	sts = om$send(	msg	= message GRgraphics.GRaltconstruct( &newCst ),
			senderid= lineObj->objid,
			targetid= lineObj->objid,
			targetos= lineObj->osnum );
	__CheckRC(1,sts, "GRgraphics.GRaltconstruct", wrapup );

	/*
	 * Get the transformation matrix with the desired rotation
	 * rotation angle being in radians
	 */
	sts = VSgetXformMx( msg, xDir, yDir, zDir, eval + 0, angle, transMx ) ;

	MAtypemx( msg, transMx, &transMxType ) ;
/*
	printf("lineObj = [%d,%d], transMxType = %d\n",lineObj->osnum, lineObj->objid,transMxType);
	printf("\t\t%lg, %lg, %lg, %lg\n\t\t%lg, %lg, %lg, %lg\n",transMx[0],transMx[1],transMx[2],transMx[3],
	       							  transMx[4],transMx[5],transMx[6],transMx[7]);
	printf("\t\t%lg, %lg, %lg, %lg\n\t\t%lg, %lg, %lg, %lg\n",transMx[8],transMx[9],transMx[10],transMx[11],
								  transMx[12],transMx[13],transMx[14],transMx[15]);
*/
	/*
	 * Tranform the line segment with the new transformation matrix.
	 */
	sts = om$send(	msg	= message GRgraphics.GRxform(
						msg,
						cst->env_info,
						&transMxType,
						transMx,
						&lineObj->objid ),
			senderid= NULL_OBJID,
			targetid= lineObj->objid,
			targetos= lineObj->osnum );

	*msg = MSSUCC;

wrapup:
	if( !(sts & *msg & 1 ) ) {
		if( lineObj->objid !=NULL_OBJID ) {
			/*
			 * Delete the construct GR3dlineseg
			 */
			vs$bulk_delete( count   = 1,
					grids   = lineObj,
					theEnv  = cst->env_info );
		}
	}

	_FREE(cvGeom) ;
	_FREE(sfGeom) ;

	return ( sts & *msg & 1 ) ;

} /* VSgetXdirForTwist */
/*----------------------------------------------------------------------------*/
long VSplaceSkinningSurface(    
	IGRlong 		*msg,
	struct GRobj_env	axis,
	struct GRobj_env	surface,
	struct GRvg_construct	*cst,
	int			twsCnt ,
	struct VStws_info	*twsInfo ,
	struct GRobj_env	*skinSurf )
{
	long			sts ;
	struct GRid		lineObj ;
	double			defAng, u_par ;
	int			i, ii,
				count =0;

	IGRlong 		num_cross,
				num_trace ;
	struct GRlc_info	trcobj;
	struct GRlc_info	tangent_surfaces[4];
	struct GRlc_info	*xsObj = NULL;
	IGRboolean		surface_is_open ,
				absolute_orientation ,
				no_height_scaling ;

	struct IGRbsp_curve	*shape_law,
				*orient_law;
	double			*upar, *angAtParm ;
	IGRvector		yDir, zDir ;
	IGRpoint		pntOnCurve ;
	IGRmatrix		csMx ;

	double			step, stAng, edAng, angle ;

	shape_law = orient_law = NULL;

	upar = angAtParm = NULL ;
	skinSurf->_objid = NULL_OBJID ;
	if( ! twsCnt ) { *msg = MSINARG ; return OM_W_ABORT ; }

	if( !( upar = _MALLOC( twsCnt, double ) ) ) vs$mem_fail() ;
	if( !( angAtParm = _MALLOC( twsCnt, double ) ) ) vs$mem_fail() ;

	defAng = 0.0 ;
	upar[0] = 0.;
	upar[1] = 1.;
	for( i = 0; i < twsCnt ; i++ ) {
		sts = VSgetXdirForTwist(msg,
					axis,
					surface,
					upar[i],
					cst,
					defAng,
					&lineObj,
					csMx );
		__CheckRC(sts, *msg, "VSgetXdirForTwist", wrapup );

		for ( ii=0; ii<3; ii++ ) {
			yDir[ii] = csMx[(ii*4+1)] ;
			zDir[ii] = csMx[(ii*4+2)] ;
		 	pntOnCurve[ii] = csMx[(4*ii+3)] ;
		}

		angle = (PI/180)*twsInfo[i].angle ;

		sts = VSgetRelativeAngle (	yDir,
						zDir,
						angle,
						twsInfo[i].refType,
						pntOnCurve,
						&angAtParm[i] ) ;
		vs$bulk_delete(	count	= 1,
				grids	= &lineObj,
				theEnv	= cst->env_info );


	}
	stAng = angAtParm[0] ;
	edAng = angAtParm[1] ;
	angle = stAng ;

// HF: 04/10/97 Temporarily disable interpolation because of Intel/Solaris problem

#ifdef	INTERPOLATE_TRACE
	step = (edAng - stAng )/10 ;
	for( u_par=0.; u_par<=1.0; u_par=u_par+0.1 ) {
#else
	step = (edAng - stAng )/1.0 ;
	for( ii=0,u_par=0.; ii<2; ii++,u_par=1. ) {
#endif
		sts = VSgetXdirForTwist(msg,
					axis, 
					surface, 
					u_par,	
					cst,
					angle,
					&lineObj,
					csMx ) ;
		__CheckRC(sts, *msg, "VSgetXdirForTwist", wrapup );
//	printf("lineObj = [%d,%d], count = %d, angle = %lg, u_par = %lg\n", lineObj.osnum, lineObj.objid, count,angle,u_par);
		count++ ;
		angle = angle + step ;
		if( count > 1 ) {
		if( !( xsObj = _REALLOC( xsObj, count, struct GRlc_info ) ) )
			vs$mem_fail();
		} else {
		if( !( xsObj = _MALLOC( count, struct GRlc_info ) ) )
			vs$mem_fail();
		}
		xsObj[count-1].located_obj = lineObj ;
		xsObj[count-1].module_info = *(cst->env_info) ;
		xsObj[count-1].geom_parms.u = 0;
		xsObj[count-1].geom_parms.polygon_inx = 0;
	}

	sts = om$construct(	classid = OPP_EMSgenbs_class_id,
				osnum	 = cst->env_info->md_id.osnum ,
				p_objid  = &skinSurf->_objid ) ;

	skinSurf->_osnum = cst->env_info->md_id.osnum ;
	skinSurf->mod_env= *(cst->env_info) ;

	__DBGpr_obj(" Twisted Surface", skinSurf->_grid );

	num_trace = 1 ;
	num_cross = count ;
	surface_is_open = TRUE ;
	absolute_orientation = FALSE ;
	no_height_scaling = TRUE ;

	trcobj.located_obj = axis._grid ;
	trcobj.module_info = axis.mod_env ;

	tangent_surfaces[0].located_obj.objid = NULL_OBJID ;
	tangent_surfaces[0].module_info  = *(cst->env_info) ;
	tangent_surfaces[1].located_obj.objid = NULL_OBJID ;
	tangent_surfaces[1].module_info  = *(cst->env_info) ;
	tangent_surfaces[2].located_obj.objid = NULL_OBJID ;
	tangent_surfaces[2].module_info  = *(cst->env_info) ;
	tangent_surfaces[3].located_obj.objid = NULL_OBJID ;
	tangent_surfaces[3].module_info  = *(cst->env_info) ;

	sts = om$send(msg = message EMSgenbs.EMplace_skinning_surface(
						msg,
						cst,
						num_cross,
						xsObj,
						num_trace,
						&trcobj,
						surface_is_open,
						tangent_surfaces,
						absolute_orientation,
						no_height_scaling,
						shape_law,
						orient_law ),
		senderid = skinSurf->_objid,
		targetid = skinSurf->_objid,
		targetos = skinSurf->_osnum );
	__CheckRC( sts, *msg, " Place Skin Surface", wrapup );

	__DBGpr_obj( " Skin Surface", skinSurf->_grid );

wrapup :
	if( !(sts & *msg & 1 ) ) {
		if( skinSurf->_objid != NULL_OBJID ) {
			/*
			 * Delete the construct EMSgenbs
			 */
			vs$bulk_delete( count   = 1,
					grids   = &skinSurf->_grid ,
					theEnv  = &skinSurf->mod_env ) ;
		}
	}

	for( i=0; i<count; i++ ) {
		vs$bulk_delete(	count	= 1,
				grids	= &xsObj[i].located_obj,
				theEnv	= &xsObj[i].module_info );
	}

	_FREE( xsObj );
	_FREE( upar );
	_FREE( angAtParm );
	
	return ( sts & *msg & 1 ) ;
}
/*----------------------------------------------------------------------------*/
end implementation Root;













