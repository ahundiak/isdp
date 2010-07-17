/* $Id: VSbmcentaxis.I,v 1.2 2001/01/17 00:13:41 ramarao Exp $  */
 
/***************************************************************************
 * I/STRUCT
 *
 * File:        struct/vsbeam/VSbmcentaxis.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSbmcentaxis.I,v $
 *      Revision 1.2  2001/01/17 00:13:41  ramarao
 *      *** empty log message ***
 *
# Revision 1.1  2001/01/11  15:58:46  pinnacle
# Created: struct/vsbeam/VSbmcentaxis.I by rchennup for Service Pack
#
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.1  1997/10/06  09:26:14  pinnacle
# Created: vsbeam/VSbmcentaxis.I by svkadamb for struct
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *                      suresh          creation
 ***************************************************************************/
/*
	I/STRUCT
*/
class implementation Root;

/* -------------------------------------------------------------------------
   Doc : VSgetBeamCentroidalaxis

   Description : This function generates centroidal axis of a given beam

   History :
   08-12-1997	Suresh	Creation

   Algorithm :
   ----------

	For a linear beam,

	  o  extract profile at begining of the beam
	  o  compute centroid of the profile
	  o  Generate a copy of the support axis of beam and transform
	     the copy to the centroid.  The transformed line is the
	     centroidal axis of the beam

	For a curved beam,

	1) stroke the axis into a line string ( select few points
						on the axis at reasonable
						interval )
	2) for each point of the linestring of parameter t,
	   generate a profile w/ VSbeam.VSextractProfile
	3) compute centroid Gi of each profile (GRcurve.GRcenter)
	   and delete the curve
	4) Generate curve from the all the centroids thus obtaining
	   centroidal axis
-----------------------------------------------------------------------------*/
#include  "OMminimum.h"
#include  "OMprimitives.h"
#include  "OMerrordef.h"
#include  "igetypedef.h"
#include  "igrtypedef.h"
#include  "igr.h"
#include  "gr.h"
#inlcude  "growner.h"
#include  "grdpbdef.h"
#include  "grdpbmacros.h"
#include  "acrepdef.h"
#include  "igrdp.h"
#include  "dpdef.h"
#include  "dp.h"
#include  "madef.h"
#include  "godef.h"
#include  "vsdef.h"
#include  "vs.h"
#include  "vsmiscmacros.h"
#include  "vsdbgmacros.h"

#define AXIS_POINTS	51

extern  OMuword		OPP_GRlinear_class_id;
extern  OMuword		OPP_GRbcsubbc_class_id;


from   VSfeature  import   VSgetSupports;
from   VSbeam     import   VSextractProfile, VSgetSupportAxis;
from   GRvg	  import   GRcenter;
from   GRcurve	  import   GRendpts;
from   GRgraphics import   GRcopy;
from   GRgraphics import   GRxform;
from   GRgraphics import   GRconstruct;
from   GRgraphics import   GRdelete;

long  VSgetBeamCentroidalAxis (
	long			*msg,	  /* O - return status		*/
	struct  GRid  		beam,	  /* I - beam objid		*/
	struct  GRmd_env	*bmEnv,	  /* I - beam mod_env		*/
	struct  GRmd_env	*axisEnv, /* I - centroidal axis mod_env*/
	struct  GRid		*CentAxis /* O - centroidal axis	*/
)
{
long			sts;
int			ii, jj, count;
VSsuppList		supports;
OMuword			axis_classid;
struct GRvg_construct   cst;
int			numberOfBytes,
			BytesReceived;
short			ActiveLevel;
struct IGRdisplay	ActiveDisplay;
struct GRid		xsId, SupportAxis;
IGRpoint		centroid,
			AxisStartPt,
			AxisEndPt;
IGRmatrix		xmat;
short			xmat_type;
IGRpoint		centroidal_pts[AXIS_POINTS];
double			param, 
			crv_pts[AXIS_POINTS*3];
struct IGRbsp_curve     *cv_geom = NULL;


	*msg = 1;

	numberOfBytes = sizeof ( ActiveLevel );

	gr$get_active_layer( 	msg    = msg,
				sizbuf = &numberOfBytes,
				buffer = &ActiveLevel,
				nret   = &BytesReceived );

	numberOfBytes = sizeof ( ActiveDisplay );

	gr$get_active_display( 	msg    = msg,
				sizbuf = &numberOfBytes,
				buffer = &ActiveDisplay,
				nret   = &BytesReceived );
	/*
	 * get the axis of the beam
	 * message VSfeature.VSgetSupports: the 1st element returned is
	 * the support surface, the second is the axis.
	 */
	sts = om$send ( msg = message VSfeature.VSgetSupports ( 
							msg,
							bmEnv,
							&count,
							supports ),
		 	targetid = beam.objid,
			targetos = beam.osnum,
			senderid = NULL_OBJID );
	__CheckRC( sts, *msg, "VSfeature.VSgetSupports", wrapup );

	sts = om$get_classid (  osnum     = supports[1].obj_id.osnum,
				objid     = supports[1].obj_id.objid,
				p_classid = &axis_classid );

	/* 
	 * fillconstruction list for beam profile 
	 */
	cst.msg	= msg;
	cst.env_info = axisEnv;
	cst.level    = ActiveLevel;
	cst.display  = &ActiveDisplay;

	if ( om$is_ancestry_valid (
		subclassid   = axis_classid,
		superclassid = OPP_GRlinear_class_id ) == OM_S_SUCCESS )
   	{
		/*
		 * Axis is a line. Get beam profile at starting point of 
		 * axis. Get the centroid of the profile. Transform copy of 
		 * axis to the centroid of the profile.
		 */

		sts = om$send(  msg     = message VSbeam.VSextractProfile(
						msg,
						bmEnv,
						&supports[0],
						&supports[1],
						0.,
						&cst,
						AC_3D_REP,
						&xsId ),
				senderid= NULL_OBJID,
				targetid= beam.objid,
				targetos= beam.osnum ) ;
		__CheckRC( sts, *msg, "VSbeam.VSextractProfile", wrapup );

		sts = om$send ( msg = message GRvg.GRcenter (
						msg,
						&axisEnv->md_env.matrix_type,
						axisEnv->md_env.matrix,
						centroid ),
					senderid = NULL_OBJID,
					targetid = xsId.objid,
					targetos = xsId.osnum );
		__CheckRC( sts, *msg, "GRvg.GRcenter", wrapup );

		sts = om$send ( msg = message GRcurve.GRendpts (
				msg,
				&bmEnv->md_env.matrix_type,
				bmEnv->md_env.matrix,
				/*
				&supports[1].mod_env.md_env.matrix_type,
				supports[1].mod_env.md_env.matrix,
				*/
				AxisStartPt,
				AxisEndPt ),
				senderid = NULL_OBJID,
				targetid = supports[1].obj_id.objid,
				targetos = supports[1].obj_id.osnum );
		__CheckRC( sts, *msg, "GRcurve.GRendpts", wrapup );

		/* 
		 * form the transformtion matrix 
		 */
		MAidmx ( msg, xmat );
		xmat[3]  = centroid[0] - AxisStartPt[0];
		xmat[7]  = centroid[1] - AxisStartPt[1];
		xmat[11] = centroid[2] - AxisStartPt[2];

		MAtypemx( msg, xmat, &xmat_type );

		SupportAxis.osnum = axisEnv->md_id.osnum;
		/* 
		 * Use bmEnv for source mod env as supports[1].mod_env is always
		 * identity. ( it does not seem to be set at all ).
		 */
		sts = om$send ( msg = message GRgraphics.GRcopy (
						msg,
						bmEnv, 
						/* &supports[1].mod_env, */ 
						axisEnv,
						&SupportAxis.objid ),
				senderid = NULL_OBJID,
				targetid = supports[1].obj_id.objid,
				targetos = supports[1].obj_id.osnum );

		CentAxis->osnum = axisEnv->md_id.osnum;
		sts = om$send ( msg = message GRgraphics.GRxform (
						msg,
						axisEnv,
						&xmat_type,
						xmat,
						&CentAxis->objid ),
				senderid = NULL_OBJID,
				targetid = SupportAxis.objid,
				targetos = SupportAxis.osnum );
		__CheckRC( sts, *msg, "GRgraphics.GRxform", wrapup );

		sts = om$send ( msg = message GRgraphics.GRdelete ( msg, 
								    axisEnv ),
				senderid = NULL_OBJID,
				targetid = xsId.objid,
				targetos = xsId.osnum );
	} else {
		/* 
		 * curved beam.  For each of the AXIS_POINTS, extract profile 
		 * and profile's centroid.  Generate a curve out of the 
		 * centriods.
		 */
		for( ii=0; ii<AXIS_POINTS; ii++ )
		{
			param = ii / (double)( AXIS_POINTS - 1);
			sts = om$send(  msg = message VSbeam.VSextractProfile(
							msg,
							bmEnv,
							&supports[0],
							&supports[1],
							param,
							&cst,
							AC_3D_REP,
							&xsId ),
				senderid= NULL_OBJID,
				targetid= beam.objid,
				targetos= beam.osnum ) ;
			__CheckRC(sts,*msg,"VSbeam.VSextractProfile", wrapup );

			sts = om$send ( msg = message GRvg.GRcenter ( 
						msg,
						&axisEnv->md_env.matrix_type,
						axisEnv->md_env.matrix,
						centroidal_pts[ii] ),
					senderid = NULL_OBJID,
					targetid = xsId.objid,
					targetos = xsId.osnum );
			__CheckRC(sts,*msg,"VSbeam.VSextractProfile", wrapup );

			sts = om$send ( msg = message GRgraphics.GRdelete ( 
								msg, 
								axisEnv ),
					senderid = NULL_OBJID,
					targetid = xsId.objid,
					targetos = xsId.osnum );
		}

		/* 
		 * copy centroidal points to crv_pts. crv_pts is required 
		 * by fit_unifm_cv.
		 */       

		for(ii=0; ii<AXIS_POINTS; ii++)
			for(jj=0; jj<3; jj++)
			    crv_pts[ii*3+jj] = centroidal_pts[ii][jj];

		sts = fit_unifm_cv ( 	AXIS_POINTS, 
					crv_pts, 
					4, 
					FALSE, 
					NULL, 
					&cv_geom );

		cst.newflag    = FALSE;
		cst.geometry   = (char *) cv_geom;
		cst.class_attr = NULL;
		cst.properties = GRIS_LOCATABLE | GRIS_DISPLAYABLE;
		cst.name       = NULL;

		CentAxis->osnum = axisEnv->md_id.osnum;

		sts = om$construct ( 	classid    = OPP_GRbcsubbc_class_id,
			  		osnum      = axisEnv->md_id.osnum,
					p_objid    = &CentAxis->objid,
					msg        = message 
					         GRgraphics.GRconstruct(&cst) );
		__CheckRC( sts, 1, "GRbcsubbc.GRconstruct", wrapup );
	}

wrapup :
	_FREE( cv_geom );
	return  sts;
}

long  VSgetFinalBeamCentroidalAxis (
	long			*msg,	  /* O - return status		*/
	struct  GRid  		beam,	  /* I - beam objid		*/
	struct  GRmd_env	*bmEnv,	  /* I - beam mod_env		*/
	struct  GRmd_env	*axisEnv, /* I - centroidal axis mod_env*/
	struct  GRid		*CentAxis /* O - centroidal axis	*/
)
{
long			sts;
int			ii, jj, count;
VSsuppList		supports;
OMuword			axis_classid;
struct GRvg_construct   cst;
int			numberOfBytes,
			BytesReceived;
short			ActiveLevel;
struct IGRdisplay	ActiveDisplay;
struct GRid		xsId, SupportAxis;
IGRpoint		centroid,
			AxisStartPt,
			AxisEndPt;
IGRmatrix		xmat;
short			xmat_type;
IGRpoint		centroidal_pts[AXIS_POINTS];
double			param, 
			crv_pts[AXIS_POINTS*3];
struct IGRbsp_curve     *cv_geom = NULL;


	*msg = 1;

	numberOfBytes = sizeof ( ActiveLevel );

	gr$get_active_layer( 	msg    = msg,
				sizbuf = &numberOfBytes,
				buffer = &ActiveLevel,
				nret   = &BytesReceived );

	numberOfBytes = sizeof ( ActiveDisplay );

	gr$get_active_display( 	msg    = msg,
				sizbuf = &numberOfBytes,
				buffer = &ActiveDisplay,
				nret   = &BytesReceived );
	/*
	 * get the axis of the beam
	 * message VSfeature.VSgetSupports: the 1st element returned is
	 * the support surface, the second is the axis.
	 */
	sts = om$send ( msg = message VSfeature.VSgetSupports ( 
							msg,
							bmEnv,
							&count,
							supports ),
		 	targetid = beam.objid,
			targetos = beam.osnum,
			senderid = NULL_OBJID );
	__CheckRC( sts, *msg, "VSfeature.VSgetSupports", wrapup );

        sts = om$send(  msg      = message VSbeam.VSgetSupportAxis(
                                                  msg, bmEnv, supports+1 ),
                    	senderid = beam.objid,
                    	targetid = beam.objid,
                    	targetos = beam.osnum ) ;
        __CheckRC( sts, *msg, "VSbeam.VSgetSupportAxis", wrapup ) ;

	sts = om$get_classid (  osnum     = supports[1].obj_id.osnum,
				objid     = supports[1].obj_id.objid,
				p_classid = &axis_classid );

	/* 
	 * fillconstruction list for beam profile 
	 */
	cst.msg	= msg;
	cst.env_info = axisEnv;
	cst.level    = ActiveLevel;
	cst.display  = &ActiveDisplay;

	if ( om$is_ancestry_valid (
		subclassid   = axis_classid,
		superclassid = OPP_GRlinear_class_id ) == OM_S_SUCCESS )
   	{
		/*
		 * Axis is a line. Get beam profile at starting point of 
		 * axis. Get the centroid of the profile. Transform copy of 
		 * axis to the centroid of the profile.
		 */

		sts = om$send(  msg     = message VSbeam.VSextractProfile(
						msg,
						bmEnv,
						&supports[0],
						&supports[1],
						0.,
						&cst,
						AC_3D_REP,
						&xsId ),
				senderid= NULL_OBJID,
				targetid= beam.objid,
				targetos= beam.osnum ) ;
		__CheckRC( sts, *msg, "VSbeam.VSextractProfile", wrapup );

		sts = om$send ( msg = message GRvg.GRcenter (
						msg,
						&axisEnv->md_env.matrix_type,
						axisEnv->md_env.matrix,
						centroid ),
					senderid = NULL_OBJID,
					targetid = xsId.objid,
					targetos = xsId.osnum );
		__CheckRC( sts, *msg, "GRvg.GRcenter", wrapup );

		sts = om$send ( msg = message GRcurve.GRendpts (
				msg,
				&bmEnv->md_env.matrix_type,
				bmEnv->md_env.matrix,
				/*
				&supports[1].mod_env.md_env.matrix_type,
				supports[1].mod_env.md_env.matrix,
				*/
				AxisStartPt,
				AxisEndPt ),
				senderid = NULL_OBJID,
				targetid = supports[1].obj_id.objid,
				targetos = supports[1].obj_id.osnum );
		__CheckRC( sts, *msg, "GRcurve.GRendpts", wrapup );

		/* 
		 * form the transformtion matrix 
		 */
		MAidmx ( msg, xmat );
		xmat[3]  = centroid[0] - AxisStartPt[0];
		xmat[7]  = centroid[1] - AxisStartPt[1];
		xmat[11] = centroid[2] - AxisStartPt[2];

		MAtypemx( msg, xmat, &xmat_type );

		SupportAxis.osnum = axisEnv->md_id.osnum;
		/* 
		 * Use bmEnv for source mod env as supports[1].mod_env is always
		 * identity. ( it does not seem to be set at all ).
		 */
		sts = om$send ( msg = message GRgraphics.GRcopy (
						msg,
						bmEnv, 
						/* &supports[1].mod_env, */ 
						axisEnv,
						&SupportAxis.objid ),
				senderid = NULL_OBJID,
				targetid = supports[1].obj_id.objid,
				targetos = supports[1].obj_id.osnum );

		CentAxis->osnum = axisEnv->md_id.osnum;
		sts = om$send ( msg = message GRgraphics.GRxform (
						msg,
						axisEnv,
						&xmat_type,
						xmat,
						&CentAxis->objid ),
				senderid = NULL_OBJID,
				targetid = SupportAxis.objid,
				targetos = SupportAxis.osnum );
		__CheckRC( sts, *msg, "GRgraphics.GRxform", wrapup );

		sts = om$send ( msg = message GRgraphics.GRdelete ( msg, 
								    axisEnv ),
				senderid = NULL_OBJID,
				targetid = xsId.objid,
				targetos = xsId.osnum );
	} else {
		/* 
		 * curved beam.  For each of the AXIS_POINTS, extract profile 
		 * and profile's centroid.  Generate a curve out of the 
		 * centriods.
		 */
		for( ii=0; ii<AXIS_POINTS; ii++ )
		{
			param = ii / (double)( AXIS_POINTS - 1);
			sts = om$send(  msg = message VSbeam.VSextractProfile(
							msg,
							bmEnv,
							&supports[0],
							&supports[1],
							param,
							&cst,
							AC_3D_REP,
							&xsId ),
				senderid= NULL_OBJID,
				targetid= beam.objid,
				targetos= beam.osnum ) ;
			__CheckRC(sts,*msg,"VSbeam.VSextractProfile", wrapup );

			sts = om$send ( msg = message GRvg.GRcenter ( 
						msg,
						&axisEnv->md_env.matrix_type,
						axisEnv->md_env.matrix,
						centroidal_pts[ii] ),
					senderid = NULL_OBJID,
					targetid = xsId.objid,
					targetos = xsId.osnum );
			__CheckRC(sts,*msg,"VSbeam.VSextractProfile", wrapup );

			sts = om$send ( msg = message GRgraphics.GRdelete ( 
								msg, 
								axisEnv ),
					senderid = NULL_OBJID,
					targetid = xsId.objid,
					targetos = xsId.osnum );
		}

		/* 
		 * copy centroidal points to crv_pts. crv_pts is required 
		 * by fit_unifm_cv.
		 */       

		for(ii=0; ii<AXIS_POINTS; ii++)
			for(jj=0; jj<3; jj++)
			    crv_pts[ii*3+jj] = centroidal_pts[ii][jj];

		sts = fit_unifm_cv ( 	AXIS_POINTS, 
					crv_pts, 
					4, 
					FALSE, 
					NULL, 
					&cv_geom );

		cst.newflag    = FALSE;
		cst.geometry   = (char *) cv_geom;
		cst.class_attr = NULL;
		cst.properties = GRIS_LOCATABLE | GRIS_DISPLAYABLE;
		cst.name       = NULL;

		CentAxis->osnum = axisEnv->md_id.osnum;

		sts = om$construct ( 	classid    = OPP_GRbcsubbc_class_id,
			  		osnum      = axisEnv->md_id.osnum,
					p_objid    = &CentAxis->objid,
					msg        = message 
					         GRgraphics.GRconstruct(&cst) );
		__CheckRC( sts, 1, "GRbcsubbc.GRconstruct", wrapup );
	}

wrapup :
	_FREE( cv_geom );
	return  sts;
}

end implementation Root;
