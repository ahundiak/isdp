/*
	I/STRUCT
*/
class implementation VSshellExp ;

#include <stdio.h>
#include "dpdef.h"
#include "EMSmsgdef.h"
#include "msmacros.h"
#include "vsglobalmsg.h"
#include "vsdatamacros.h"
#include "vsgeommacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"

#define	VD_DEBUG
#include	<VDdebug.h>
/*
 * Includes of function prototypes.
 */
#include "EMSwrmacros.h"

extern long	VSsxExpandShell() ;
extern long	VSsxGetClosedInnerBoundaries() ;
extern long	VSsxExpandCurve() ;

extern OMuword	OPP_EMSplane_class_id ;

from EMSplane	import EMplane_of_curve ;

/*----------------------------------------------------------------------------*/
method ACconstruct_feet( long			*msg ;
			 int			purpose,
						count ;
			 struct GRid		list[] ;
			 struct GRmd_env	*MyEnv ;
			 int			*feetCount ;
			 struct GRid		*feetList )
{
	long			sts ;	       /* OM return code.	      */
	int			i,	       /* Loop index.		      */
				nbBound,       /* Number of closed inner      */
					       /* boundaries of shell.	      */
				nbImp ;        /* Number of closed inner      */
					       /* boundaries of shell to      */
					       /* impose onto shell expansion */
					       /* plane.		      */
	struct GRvg_construct	cst ;	       /* My construction list.       */
	struct GRsymbology	symb ;	       /* My symbology. 	      */
	struct GRid		imageOfShell,  /* Image of shell.	      */
				*boundaries ;  /* List of closed inner	      */
					       /* boundaries of shell.	      */
	struct GRobj_env	*objEnvs ;     /* List of obj env.	      */
	struct IGRpolyline	polyline ;     /* Polyline of shell expansion */
					       /* or inner boundary expanded. */
	struct GRobj_env	input[4] ;     /* Input parents.	      */
	struct GRlc_info	cvInfo ;       /* Curve information.	      */
	double			baseLine[3],   /* Baseline point.	      */
				beginPoint[3], /* Begin point.		      */
				endPoint[3] ;  /* End point.		      */
	double			yTrans ;       /* y translation of shell      */
					       /* expansion.		      */

	SetProc( VSshellExp_ACconstruct_feet ) ; Begin ; __DBGpr_me() ;

        __enterMethod ( name = "ACconstruct_feet" //, argfmt = "", args = ``
        );

	*feetCount	  = 0 ;
	feetList[0].objid = NULL_OBJID ;

	imageOfShell.objid	 = NULL_OBJID ;
	cvInfo.located_obj.objid = NULL_OBJID ;

	nbBound    = nbImp = 0 ;
	boundaries = NULL ;

	objEnvs    = NULL ;

	polyline.num_points = 0 ;
	polyline.points     = NULL ;

	if( count < 1 ) vs$inv_arg() ;

	sts = om$send( msg	= message GRvg.GRgetsymb( msg,
							  &symb ),
		       mode	= purpose & VS_K_InitialPlacement
					? OM_e_wrt_message
					: OM_e_wrt_object,
		       targetid = my_id ) ;

	__CheckRC( sts, *msg, "GRvg.GRgetsymb", wrapup ) ;

	/*
	 * Get parents.
	 */
	sts = om$send( msg	= message VScpx.VSget_graphic_input( msg,
								     count,
								     list,
								     input ),
		       targetid = my_id ) ;

	__CheckRC( sts, *msg, "VScpx.VSget_graphic_input", wrapup ) ;

	/*
	 * Get baseline point.
	 */
	sts = om$send( msg	= message VSshellExp.VSget_baseline_point(
								     msg,
								     MyEnv,
								     baseLine ),
		       targetid = my_id ) ;

	__CheckRC( sts, *msg, "VSshellExp.VSget_baseline_point", wrapup ) ;

	__DBGpr_vec( "Baseline point", baseLine ) ;

	/*
	 * Get limiting points.
	 */
	sts = om$send( msg	= message VSshellExp.VSget_limiting_points(
								     msg,
								     MyEnv,
								     beginPoint,
								     endPoint ),
		       targetid = my_id ) ;

	__CheckRC( sts, *msg, "VSshellExp.VSget_limiting_points", wrapup ) ;

	__DBGpr_vec( "Begin point", beginPoint ) ;
	__DBGpr_vec( "End   point", endPoint   ) ;

	/*
	 * Expand shell.
	 */
	sts = VSsxExpandShell( msg,
			       &input[0]._grid,
			       &input[0].mod_env,
			       beginPoint[0],
			       endPoint[0],
			       baseLine[2],
			       &polyline ) ;

	__CheckRC( sts, *msg, "VSsxExpandShell", wrapup ) ;

	if( !polyline.num_points ) vs$failure() ;

	/*
	 * Find y translation and translate above polyline.
	 */
	ex$message( msgnumb = VS_gI_Processing, justification = CENTER_JUS ) ;

	yTrans = IGE_DESIGN_LIMITS_MAX ;

	for( i=0; i<polyline.num_points; i++ )
		if( yTrans > polyline.points[3*i+1] )
			yTrans = polyline.points[3*i+1] ;

	yTrans *= -1 ;

	sts = om$send( msg	= message VSshellExp.VSstore_y_translation(
								       msg,
								       MyEnv,
								       yTrans ),
		       targetid = my_id ) ;

	for( i=0; i<polyline.num_points; i++ )
		polyline.points[3*i+1] += yTrans ;

	/*
	 * Fill construction list.
	 */
	vs$fill_cnst_list( Env_info	= MyEnv,
			   Display	= &symb.display_attr,
			   Level	= symb.level,
			   Cnst_list	= cst ) ;

	/*
	 * Construct a plane whose boundary is the above polyline.
	 */
	imageOfShell.osnum = cst.env_info->_MD_OS ;

	sts = om$construct( classid	= OPP_EMSplane_class_id,
			    osnum	= imageOfShell.osnum,
			    p_objid	= &imageOfShell.objid ) ;

	__CheckRC( sts, 1, "om$construct", wrapup ) ;

	cvInfo.located_obj.osnum = cst.env_info->_MD_OS ;
	cvInfo.module_info	 = *cst.env_info ;

	sts = EFplace_line_string( NULL_OBJID,
				   &cst,
				   polyline.num_points,
				   polyline.points,
				   &cvInfo.located_obj.objid,
				   msg ) ;

	__CheckRC( sts, *msg, "EFplace_line_string", wrapup ) ;

	sts = om$send( msg	= message EMSplane.EMplane_of_curve( msg,
								     &cst,
								     &cvInfo,
								     NULL,
								     NULL,
								     TRUE,
								     TRUE,
								     NULL,
								     NULL ),
		       targetid = imageOfShell.objid,
		       targetos = imageOfShell.osnum ) ;

	__CheckRC( sts, *msg, "EMSplane.EMplane_of_curve", wrapup ) ;

	__DBGpr_obj( "Image of shell", imageOfShell ) ;

	/*
	 * Find a copy of closed inner boundaries of shell.
	 */
	sts = VSsxGetClosedInnerBoundaries( msg,
					    &input[0]._grid,
					    &input[0].mod_env,
					    &nbBound,
					    &boundaries ) ;

	__CheckRC( sts, *msg, "VSsxGetClosedInnerBoundaries", wrapup ) ;

	/*
	 * For each boundaries, expand it and impose it onto image of shell.
	 */
	if( nbBound ) {
		if( !( objEnvs = _MALLOC( nbBound +1, struct GRobj_env ) ) )
			vs$mem_fail() ;

		objEnvs[0]._grid   = imageOfShell ;
		objEnvs[0].mod_env = *cst.env_info ;

		for( i=0; i<nbBound; i++ ) {
			objEnvs[i+1]._osnum  = cst.env_info->_MD_OS ;
			objEnvs[i+1]._objid  = NULL_OBJID ;
			objEnvs[i+1].mod_env = *cst.env_info ;
		}

		for( i=0; i<nbBound; i++ ) {

			_FREE( polyline.points ) ;
			polyline.points     = NULL ;
			polyline.num_points = 0 ;

			sts = VSsxExpandCurve( msg,
					       &input[0]._grid,
					       &input[0].mod_env,
					       boundaries +i,
					       cst.env_info,
					       beginPoint[0],
					       endPoint[0],
					       baseLine[2],
					       &polyline ) ;

			if( !polyline.num_points ) continue ;

			__CheckRC( sts, *msg, "VSsxExpandCurve", wrapup ) ;

			ex$message( msgnumb	  = VS_gI_Processing,
				    justification = CENTER_JUS ) ;

			for( i=0; i<polyline.num_points; i++ )
				polyline.points[3*i+1] += yTrans ;

			sts = EFplace_line_string( NULL_OBJID,
						   &cst,
						   polyline.num_points,
						   polyline.points,
						   &objEnvs[nbImp+1]._objid,
						   msg ) ;

			__CheckRC( sts, *msg, "EFplace_line_string", wrapup ) ;

			nbImp++ ;
		}

		if( nbImp ) {
			sts = vs$imposeBoundaries( msg		= msg,
						   surface	= objEnvs +0,
						   bndryCount	= nbImp,
						   bndryList	= objEnvs +1,
						   sfIsPlanar	= TRUE ) ;

			__CheckRC( sts, *msg, "vs$imposeBoundaries", wrapup ) ;
		}
	}

	feetList[0]	= imageOfShell ;
	*feetCount	= 1 ;

	/*
	 * Update object tag, don't check return code: will be
	 * OM_W_NOTTAGGED if object has no tag connection.
	 */
	om$change_tag_version() ;

	sts  = OM_S_SUCCESS ;
	*msg = MSSUCC ;

	wrapup :
		ex$message( msgnumb = VS_gI_EmptyMessage ) ;

		if( !( sts & 1 & *msg ) ) {
			vs$bulk_delete( grids  = &imageOfShell,
					theEnv = cst.env_info ) ;

			if( purpose & VS_K_InitialPlacement ) {
				if( *msg & 1 ) *msg = MSFAIL ;
				sts = OM_W_ABORT ;
			} else {
				if( *msg & 1 ) *msg = EMS_E_NoSolution ;
				sts = OM_S_SUCCESS ;
			}
		}

		vs$bulk_delete( grids  = &cvInfo.located_obj,
				theEnv = &cvInfo.module_info ) ;

		if( nbBound && boundaries )
			vs$bulk_delete( count  = nbBound,
					grids  = boundaries,
					theEnv = cst.env_info ) ;

		if( nbBound && objEnvs )
			vs$bulk_delete( count	= nbBound,
					objenvs = objEnvs +1 ) ;

		_FREE( boundaries      ) ;
		_FREE( objEnvs	       ) ;
		_FREE( polyline.points ) ;

        __exitMethod ( name = "ACconstruct_feet", argfmt = "sts = %d, msg = %#x", args = `sts, *msg` );

		End

		return sts ;

} /* method ACconstruct_feet */
/*----------------------------------------------------------------------------*/

end implementation VSshellExp ;
