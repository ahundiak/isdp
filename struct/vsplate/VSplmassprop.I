/* $Id: VSplmassprop.I,v 1.1.1.1 2001/01/04 21:10:53 cvs Exp $  */
/***************************************************************************
* I/STRUCT
*
* File: vsplate/VSplmassprop.I        
*
* Description:
*	Mass property calculations for plates
* Dependencies:
*
* Revision History:
*      $Log: VSplmassprop.I,v $
*      Revision 1.1.1.1  2001/01/04 21:10:53  cvs
*      Initial import to CVS
*
# Revision 1.2  2000/02/01  16:14:44  pinnacle
# (No comment)
#
*
* History:
*      MM/DD/YY  AUTHOR  DESCRIPTION
*      01/24/2000Jayadev changes for TR179901004
***************************************************************************/

/*
	I/STRUCT
*/
class implementation VSplate ;

#include "OMerrordef.h"
#include "msdef.h"
#include "EMSmsgdef.h"
#include "vsmeasmacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
#include "vsdpbmacros.h"
#include "vsRDBmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsRDBproto.h"
/*----------------------------------------------------------------------------*/
method VSgetMassProperties(	long		*msg ;
				struct GRmd_env	*myEnv ;
				VSintegral	*mp ) {

	long		sts ;		/* OM return code		*/
/*	int		toggle ;	   Mass props toggle		*/
	struct GRid	output,		/* My output			*/
			botSurf ;	/* Bottom surface of plate	*/
	VSdspRep	myRep ;		/* My display representation	*/
	VSpartAttr	myAttr ;	/* My part attributes		*/
	VSplateAttr	myInfo ;	/* My plate attributes		*/
	double		density ;	/* Density of plate's material	*/
	char            errString[128];
	/*
	 * Force exact computation of mass properties if compute-toggle is ON.
	 */
/*
	* Commented for CR 179528562
	  Keeping the code in case if we want to revert it one day

	vs$get_massp_toggle(	msg	= msg,
				p_toggle= &toggle ) ;
	if( toggle ) {
*/
		/*
		 * Precise (and slow) computation of the mass properties (if
		 * I am in 3d ).
		 * What kind of display am I in ?
		 */
		sts = om$send(	msg	= message ACncpx.ACget_NV_rep( &myRep ),
				targetid= my_id ) ;

/*	} else { */
		/*
		 * We'll have a fast approximated computation of the mass
		 * properties.
		 */
/*		myRep = AC_2D_REP ;
	} */

	/*
	 * Get graphic output (a solid or a surface according to the rep.).
	 */
	sts = om$send(	msg	= message NDmacro.ACreturn_foot(
							msg,
							VS_K_plGrCmpName,
							&output,
							NULL, NULL ),
			targetid= my_id ) ;
	*msg = *msg ? MSSUCC : MSFAIL ;
	__CheckRC( sts, *msg, "NDmacro.ACreturn_foot", wrapup ) ;

	/*
	 * Compute dimensions (width and length) using the bottom surface of
	 * the plate.
	 */
	sts = om$send(	msg	= message NDmacro.ACreturn_foot(
			      				msg,
			      				VS_K_plBotSfPath,
			      				&botSurf,
			      				NULL, NULL ),
			targetid= my_id ) ;
	*msg = *msg ? MSSUCC : MSFAIL ;
	__CheckRC( sts, *msg, "NDmacro.ACreturn_foot", wrapup ) ;

	/* CH 10 Juillet 95
	 * It seems that the computation are effected by the range
	 * of the surfaces. It seems better to do the computation
	 * on surfaces on which a reduced range has been done.
	 * To avoid some side effect we will copy the original
	 * surface and perform a reduce range
	 */
	 
	
	 	 	 	 
	sts = vs$getSfDimensions(	msg	= msg,
					surfId	= &botSurf,
					surfEnv	= myEnv,
					width	= mp->dims + 0,
					length	= mp->dims + 1 ) ;
	__CheckRC( sts, *msg, "vs$getSfDimensions", wrapup ) ;
	mp->dims[2] = 0 ;

	myAttr.Iwant	= VS_m_MatType | VS_m_MatGrade | VS_m_Thickness ;
	myAttr.specific	= (void *) &myInfo ;
	sts = om$send(	msg	= message GRvg.GRgetattr(
							msg, (char *) &myAttr ),
			targetid= my_id ) ;
	__CheckRC( sts, *msg, "GRvg.GRgetattr", wrapup ) ;

	/*
	 * The following call will fail if user has not logged into PDM, if so
	 * set density to 1.
	 */
	vs$extract_density_from_RDB(	msg	= msg,
					errStr  = errString,
					material= myAttr.info.material,
					grade	= myAttr.info.grade,
					density	= &density ) ;
	//if( !( *msg & 1 ) ) density = 1 ; - commented for TR179901004
	// The following error_check added for TR179901004
        if( !( *msg & 1 ) )
	{
	   UI_status(errString);
           *msg = MSFAIL;
	   goto wrapup;
	}

	/*
	 * Get volume, area, principal axes and centroid of plate. Do what you
	 * can according to your display representation ... 
	 */
	switch( myRep & ~AC_SUB_REP ) {
	
	case AC_2D_REP		:
			vs$get_area_props(	msg	= msg,
						surfId	= &botSurf,
						surfEnv	= myEnv,
						centroid= mp->centroid,
						area	= &mp->area,
						moment	= mp->MofI.array ) ;
			mp->volume	= mp->area * myInfo.thickness ;
			mp->mass	= mp->volume * density ;
			break ;

	case AC_ENV_REP		:
	case AC_3D_REP		:
			vs$get_mass_props(	msg	= msg,
						surfEnv	= myEnv,
						surfId	= &output,
						density	= density,
						centroid= mp->centroid,
						volume	= &mp->volume,
						mass	= &mp->mass,
						moment	= mp->MofI.array ) ;


			/*
			 * To get the area, we use the bottom surface of the
			 * solid.
			 */
			vs$get_area_props(	msg	= msg,
						surfId	= &botSurf,
						surfEnv	= myEnv,
						area	= &mp->area ) ;
			break ;
	}

	/*
	 * The area is the sum of the area of the top and bottom surfaces
	 * since this area may be used to compute the amount of paint needed
	 * to cover the plate.
	 */
	mp->area *= 2 ;

	wrapup :
		return sts ;

} /* method VSgetMassProperties */
/*----------------------------------------------------------------------------*/
method VSgetPlateWidthLength(	long		*msg ;
				struct GRmd_env	*myEnv ;
				double		*width,
						*length ; ) {

	long		sts ;		/* OM return code		*/
	struct GRid	botSurf ;	/* Bottom surface of plate	*/

	*width = *length = 0 ;

	sts = om$send(	msg	= message NDmacro.ACreturn_foot(
			      				msg,
			      				VS_K_plBotSfPath,
			      				&botSurf,
			      				NULL, NULL ),
			targetid= my_id ) ;
	__CheckRC( sts, *msg, "NDmacro.ACreturn_foot", wrapup ) ;

	sts = vs$getSfDimensions(	msg	= msg,
					surfId	= &botSurf,
					surfEnv	= myEnv,
					width	= width,
					length	= length ) ;
	__CheckRC( sts, *msg, "vs$getSfDimensions", wrapup ) ;

	wrapup :
		return sts ;

} /* method VSgetPlateWidthLength */
/*----------------------------------------------------------------------------*/

end implementation VSplate ;

