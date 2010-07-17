/*
	I/STRUCT
*/ 
class implementation VSjoint ;

#include <math.h>
#include "EMSmsgdef.h"
#include "vs.h"
#include "vsattr.h"
#include "vsplate.h"
#include "vsplatedef.h"
#include "vsiomacros.h"
#include "vsgeommacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Include of prototypes 
 */
#include "bserr.h"
#include "bsparameters.h"
#include "bsmdistsfsf.h"

#define VS_K_FilletWeld 	2
#define TOLERANCE		1.0e-06

/*----------------------------------------------------------------------------*/
method VScstPlPlJoint(	long			*msg ;
			struct GRobj_env	plates[2] ;
			VSdspRep		myRep ;
			struct GRvg_construct	*cst ;
			int			weldSide ;
			struct GRid		*grJoint ) {

	long			sts ;	/* OM return code		*/
	struct GRobj_env	bot0,	/* Bottom surface of plate #0	*/
				top0,	/* Top    surface of plate #0	*/
				bot1,	/* Bottom surface of plate #1	*/
				top1 ;	/* Top    surface of plate #1	*/
	struct GRobj_env	plateObj;/* plate object which has min 	*/
					/* thickness/limiting plate in 	*/
					/* case fillet weld		*/
	int			num,
				weldType = 0 ;
	struct IGRbsp_surface 	*botGeom0 = NULL, 
				*botGeom1 = NULL, 
				*topGeom0 = NULL, 
				*topGeom1 = NULL ;
	double			dist0, 
				dist1 , 
				tolerance ;	/* basis tolerance	     */
	long			rc ;		/* return code for BS	     */
	double			thkPl0, 	/* thickness of first plate  */
				thkPl1, 	/* thickness of second plate */
				thickness ,	/* thickness info	     */
				offTol ;	/* offset tolerance	     */
	VSpartAttr      	myAttr ;        /* My part attributes        */
       	VSplateAttr     	myInfo ;        /* My plate attributes       */

	SetProc( VSjoint_VScstPlPlJoint ) ; Begin ; __DBGpr_me() ;

#ifdef vsDEBUG
	printf( "\tPlate 0 " ) ; ShowObj( &plates[0]._grid ) ;
	printf( "\tPlate 1 " ) ; ShowObj( &plates[1]._grid ) ;
#endif

	/*
	 * Get the joint type, Joint type can either butt weld 
	 * or fillet weld
	 */
	sts = om$send(  msg	= message VSjoint.VSgetJointType(
						msg,
						plates[0],
						plates[1],
						&weldType ),
			targetid = my_id );
	__CheckRC( sts, *msg, "VSjoint.VSgetJointType", wrapup ) ;

	/*
	 * get the bottom surface of the first plate
	 */
	sts = om$send(	msg	= message NDmacro.ACreturn_foot(
				     		msg, VS_K_plBotSfPath,
				     		&bot0._grid, NULL, NULL ),
			targetid= plates[0]._objid,
			targetos= plates[0]._osnum ) ;
	__CheckRC( sts, *msg, "NDmacro.ACreturn_foot", wrapup ) ;

	/*
	 * get the offset surface of the first plate
	 */
	sts = om$send(	msg	= message NDmacro.ACreturn_foot(
				     		msg, VS_K_plTopSfPath,
				     		&top0._grid, NULL, NULL ),
			targetid= plates[0]._objid,
			targetos= plates[0]._osnum ) ;
	__CheckRC( sts, *msg, "NDmacro.ACreturn_foot", wrapup ) ;

	/*
	 * get the bottom surface of the second plate
	 */
	sts = om$send(	msg	= message NDmacro.ACreturn_foot(
				     		msg, VS_K_plBotSfPath,
				     		&bot1._grid, NULL, NULL ),
			targetid= plates[1]._objid,
			targetos= plates[1]._osnum ) ;
	__CheckRC( sts, *msg, "NDmacro.ACreturn_foot", wrapup ) ;

	/*
	 * get the offset surface of the second plate
	 */
	sts = om$send(	msg	= message NDmacro.ACreturn_foot(
				     		msg, VS_K_plTopSfPath,
				     		&top1._grid, NULL, NULL ),
			targetid= plates[1]._objid,
			targetos= plates[1]._osnum ) ;
	__CheckRC( sts, *msg, "NDmacro.ACreturn_foot", wrapup ) ;

	top0.mod_env	= bot0.mod_env	= plates[0].mod_env ;
	top1.mod_env	= bot1.mod_env	= plates[1].mod_env ;

#ifdef vsDEBUG
	printf( "Bot 0" ) ; ShowObj( &bot0._grid ) ;
	printf( "Top 0" ) ; ShowObj( &top0._grid ) ;
	printf( "Bot 1" ) ; ShowObj( &bot1._grid ) ;
	printf( "Top 1" ) ; ShowObj( &top1._grid ) ;
#endif
	/*
	 * The following function supposes that we either have
	 *
	 *    plate 0     plate 1        plate 0     | plate 1
	 *    ----------- ---------  OR  ----------- |
	 *					     |
	 *   but not
	 *
	 *   plate 0
	 *   |
	 *   | -------- plate 1
	 *   |
	 *
	 * Hence we re-invoke it if it fails, swapping 0s and 1s.
	 */
	plateObj.mod_env = plates[1].mod_env ;
	plateObj._grid 	 = plates[1]._grid ;

	/*
	 * Get attributes of first plate.
	 * we are interested in thickness as this will be used for distance
	 * comparison
	 */
	myAttr.Iwant    = VS_m_Thickness | VS_m_CutOff ;
	myAttr.specific = (void *) &myInfo ;

	sts = om$send( msg = message GRvg.GRgetattr( msg, 
						(char *) &myAttr ),
			targetid= plates[0]._objid,
			targetos= plates[0]._osnum  ) ;
	__CheckRC( sts, *msg, "GRvg.GRgetattr", wrapup ) ;

	thkPl0 		= myInfo.thickness ;

	/*
	 * Get the offset tolerance, this is the tolerance used during
	 * the placement of plate
	 */
	BSEXTRACTPAR( msg, BSTOLOFFSET, offTol ) ;
	if( fabs( thkPl0 ) < offTol ) thkPl0 = offTol ;

	/*
	 * Get attributes of second plate.
	 */
	sts = om$send( msg = message GRvg.GRgetattr( msg, 
						(char *) &myAttr ),
			targetid= plates[1]._objid,
			targetos= plates[1]._osnum  ) ;
	__CheckRC( sts, *msg, "GRvg.GRgetattr", wrapup ) ;

	thickness 	= myInfo.thickness ;
	thkPl1 		= myInfo.thickness ;
	if( fabs( thkPl1 ) < offTol ) thkPl1 = offTol ;

	if( weldType == VS_K_FilletWeld ) {
		IGRdouble       *UVpar1 = NULL,
                		*UVpar2 = NULL ;
		IGRpoint        *sfPt1  = NULL,
				*sfPt2  = NULL ;

		/*
		 * Get the limiting and the limited plate.
		 * Weld side has meaning with respect to the limited plated
		 * Hence arrange the first plate plate as the limited plate
		 */
		sts = vs$get_geometry(  msg     = msg,
                                	grobjId = &bot0._grid,
                                	grobjEnv= &bot0.mod_env,
                                	geometry= &botGeom0 ) ;
		__CheckRC( sts, *msg, "vs$get_geometry", wrapup ) ;

		sts = vs$get_geometry(  msg     = msg,
                                	grobjId = &bot1._grid,
                                	grobjEnv= &bot1.mod_env,
                                	geometry= &botGeom1 ) ;
		__CheckRC( sts, *msg, "vs$get_geometry", wrapup ) ;

		sts = vs$get_geometry(  msg     = msg,
                                	grobjId = &top0._grid,
                                	grobjEnv= &top0.mod_env,
                                	geometry= &topGeom0 ) ;
		__CheckRC( sts, *msg, "vs$get_geometry", wrapup ) ;

		sts = vs$get_geometry(  msg     = msg,
                                	grobjId = &top1._grid,
                                	grobjEnv= &top1.mod_env,
                                	geometry= &topGeom1 ) ;
		__CheckRC( sts, *msg, "vs$get_geometry", wrapup ) ;

		/*
		 * Get the minimum distance between plate0->bot and plate1->bot
		 */
		BSmdistsfsf( botGeom0, botGeom1, &num,  &UVpar1,  &UVpar2, 
					&sfPt1, &sfPt2, &dist0, &rc) ;
		BSEXTRACTPAR( &rc, BSTOLBASIS, tolerance );

		_FREE( UVpar1 ) ; _FREE( UVpar2 ) ;
		_FREE( sfPt1  ) ; _FREE( sfPt2  ) ;

		if( dist0 <= tolerance ) {
			/*
			 * Evaluate distance for other surface and check if the
			 * distance is the thickness of plate.  if thickness 
			 * then  then first surface is limited.  
			 * else first surface is limiting
			 */
			BSmdistsfsf( botGeom0, topGeom1, &num,  &UVpar1,  
					&UVpar2, &sfPt1, &sfPt2, &dist1, &rc) ;
			_FREE( UVpar1 ); _FREE( UVpar2 );
			_FREE( sfPt1 ); _FREE( sfPt2 );
			if( fabs( dist1 - thickness ) < TOLERANCE ) {
				/*
				 * plate0 is limited
				 * all surfaces remain as is, no need for
				 * interchanging the surfaces ;
				 */
			} else {
				/*
				 * plate1 is limited
				 * swap top1, top0 and bot1, bot0
				 */
				struct GRobj_env	tmpObj ;

				tmpObj._grid = top0._grid ;	
				tmpObj.mod_env = top0.mod_env ;	
				
				top0._grid = top1._grid ;
				top0.mod_env = top1.mod_env ;

				top1._grid = tmpObj._grid ;
				top1.mod_env = tmpObj.mod_env ;

				tmpObj._grid = bot0._grid ;	
				tmpObj.mod_env = bot0.mod_env ;	
				
				bot0._grid = bot1._grid ;
				bot0.mod_env = bot1.mod_env ;

				bot1._grid = tmpObj._grid ;
				bot1.mod_env = tmpObj.mod_env ;

				plateObj.mod_env = plates[0].mod_env ;
				plateObj._grid 	 = plates[0]._grid ;
			}
			goto PLATE_PLATE_JOINT ;
		}
		BSmdistsfsf( botGeom0, topGeom1, &num,  &UVpar1,  
					&UVpar2, &sfPt1, &sfPt2, &dist0, &rc) ;
		_FREE( UVpar1 ); _FREE( UVpar2 );
		_FREE( sfPt1 ); _FREE( sfPt2 );
		
		if( dist0 <= tolerance ) {

                        /*
                         * Evaluate distance for other surface and check if the
                         * distance is the thickness of plate.  if thickness
                         * then  then first surface is limited.
                         * else first surface is limiting
                         */
			BSmdistsfsf( botGeom0, botGeom1, &num,  &UVpar1,  
					&UVpar2, &sfPt1, &sfPt2, &dist1, &rc) ;

			_FREE( UVpar1 ); _FREE( UVpar2 );
			_FREE( sfPt1 ); _FREE( sfPt2 );
 
			if( fabs( dist1 - thickness ) < TOLERANCE ) {
                                /*
                                 * plate0 is limited
                                 * all surfaces remain as is, no need for
                                 * interchanging the surfaces ;
                                 */
                        } else {
                                /*
                                 * plate1 is limited
                                 * swap top1, top0 and bot1, bot0
                                 */
                                struct GRobj_env         tmpObj ;
 
                                tmpObj._grid = top0._grid ;
                                tmpObj.mod_env = top0.mod_env ;
 
                                top0._grid = top1._grid ;
                                top0.mod_env = top1.mod_env ;

				top1._grid = tmpObj._grid ;
                                top1.mod_env = tmpObj.mod_env ;
 
                                tmpObj._grid = bot0._grid ;
                                tmpObj.mod_env = bot0.mod_env ;
 
                                bot0._grid = bot1._grid ;
                                bot0.mod_env = bot1.mod_env ;
 
                                bot1._grid = tmpObj._grid ;
                                bot1.mod_env = tmpObj.mod_env ;

				plateObj.mod_env = plates[0].mod_env ;
				plateObj._grid 	 = plates[0]._grid ;
                        }
                        goto PLATE_PLATE_JOINT ;
                }

		BSmdistsfsf( topGeom0, botGeom1, &num,  &UVpar1,  
					&UVpar2, &sfPt1, &sfPt2, &dist0, &rc) ;

		_FREE( UVpar1 ); _FREE( UVpar2 );
		_FREE( sfPt1 ); _FREE( sfPt2 );
		if( dist0 <= tolerance ) {

                        /*
                         * Evaluate distance for other surface and check if the
                         * distance is the thickness of plate.  if thickness
                         * then  then first surface is limited.
                         * else first surface is limiting
                         */
			BSmdistsfsf( topGeom0, topGeom1, &num,  &UVpar1,  
					&UVpar2, &sfPt1, &sfPt2, &dist1, &rc) ;

			_FREE( UVpar1 ); _FREE( UVpar2 );
			_FREE( sfPt1 ); _FREE( sfPt2 );

			if( fabs( dist1 - thickness ) < TOLERANCE ) {
                                /*
                                 * plate0 is limited
                                 * all surfaces remain as is, no need for
                                 * interchanging the surfaces ;
                                 */
                        } else {
                                /*
                                 * plate1 is limited
                                 * swap top1, top0 and bot1, bot0
                                 */
                                struct GRobj_env         tmpObj ;
 
                                tmpObj._grid = top0._grid ;
                                tmpObj.mod_env = top0.mod_env ;
 
                                top0._grid = top1._grid ;
                                top0.mod_env = top1.mod_env ;

				top1._grid = tmpObj._grid ;
                                top1.mod_env = tmpObj.mod_env ;
 
                                tmpObj._grid = bot0._grid ;
                                tmpObj.mod_env = bot0.mod_env ;
 
                                bot0._grid = bot1._grid ;
                                bot0.mod_env = bot1.mod_env ;
 
                                bot1._grid = tmpObj._grid ;
                                bot1.mod_env = tmpObj.mod_env ;

				plateObj.mod_env = plates[0].mod_env ;
				plateObj._grid 	 = plates[0]._grid ;
                        }
                        goto PLATE_PLATE_JOINT ;
		}

		BSmdistsfsf( topGeom0, topGeom1, &num,  &UVpar1,  
					&UVpar2, &sfPt1, &sfPt2, &dist0, &rc) ;

		_FREE( UVpar1 ); _FREE( UVpar2 );
		_FREE( sfPt1 ); _FREE( sfPt2 );

		if( dist0 <= tolerance ) {

                        /*
                         * Evaluate distance for other surface and check if the
                         * distance is the thickness of plate.  if thickness
                         * then  then first surface is limited.
                         * else first surface is limiting
                         */
			BSmdistsfsf( topGeom0, botGeom1, &num,  &UVpar1,  
					&UVpar2, &sfPt1, &sfPt2, &dist1, &rc) ;

			_FREE( UVpar1 ); _FREE( UVpar2 );
			_FREE( sfPt1 ); _FREE( sfPt2 );
 
			if( fabs( dist1 - thickness ) < TOLERANCE ) {
                                /*
                                 * plate0 is limited
                                 * all surfaces remain as is, no need for
                                 * interchanging the surfaces ;
                                 */
                        } else {
                                /*
                                 * plate1 is limited
                                 * swap top1, top0 and bot1, bot0
                                 */
                                struct GRobj_env         tmpObj ;
 
                                tmpObj._grid = top0._grid ;
                                tmpObj.mod_env = top0.mod_env ;
 
                                top0._grid = top1._grid ;
                                top0.mod_env = top1.mod_env ;

				top1._grid = tmpObj._grid ;
                                top1.mod_env = tmpObj.mod_env ;
 
                                tmpObj._grid = bot0._grid ;
                                tmpObj.mod_env = bot0.mod_env ;
 
                                bot0._grid = bot1._grid ;
                                bot0.mod_env = bot1.mod_env ;
 
                                bot1._grid = tmpObj._grid ;
                                bot1.mod_env = tmpObj.mod_env ;

				plateObj.mod_env = plates[0].mod_env ;
				plateObj._grid 	 = plates[0]._grid ;
                        }
                        goto PLATE_PLATE_JOINT ;
                }
	} else {
		/*
		 * Plate object used for intesection in case of both side 
		 * welding will be the plate which has smaller thickness
		 */
		if( thkPl0 > thkPl1 ){
			/*
			 * plate1 is limited
			 * swap top1, top0 and bot1, bot0
			 */
			struct GRobj_env         tmpObj ;
 
			tmpObj._grid = top0._grid ;
			tmpObj.mod_env = top0.mod_env ;
			 
			top0._grid = top1._grid ;
			top0.mod_env = top1.mod_env ;
			
			top1._grid = tmpObj._grid ;
			top1.mod_env = tmpObj.mod_env ;
 
			tmpObj._grid = bot0._grid ;
			tmpObj.mod_env = bot0.mod_env ;
 
			bot0._grid = bot1._grid ;
			bot0.mod_env = bot1.mod_env ;
 
			bot1._grid = tmpObj._grid ;
			bot1.mod_env = tmpObj.mod_env ;

			plateObj.mod_env = plates[0].mod_env ;
			plateObj._grid 	 = plates[0]._grid ;
		}
	}

PLATE_PLATE_JOINT :
	sts = VSfindPlateToPlateJoints( msg, &bot0, &top0, &bot1, &top1, cst,
					plateObj, weldSide, grJoint ) ;
	__CheckRC( sts, *msg, "VSfindPlateToPlateJoints", wrapup ) ;
	if( *msg == EMS_I_NoSolution ) *msg = EMS_E_NoSolution ;

#ifdef vsDEBUG
	EFmsgReport( 0, *msg, "VSfindPlateToPlateJoints 1" ) ;
#endif
	/* if( *msg == EMS_I_NoSolution ) {
		sts = VSfindPlateToPlateJoints( msg, &bot1, &top1,
						     &bot0, &top0, cst,
						    plateObj, weldSide, grJoint ) ;
		__CheckRC( sts, *msg, "VSfindPlateToPlateJoints", wrapup ) ;
#ifdef vsDEBUG
	EFmsgReport( 0, *msg, "VSfindPlateToPlateJoints 2" ) ;
#endif
		
		if( *msg == EMS_I_NoSolution ) *msg = EMS_E_NoSolution ;
	} */

	if( *msg & 1 ) {
		struct GRid	moi ;

		moi.objid	= my_id ;
		moi.osnum	= OM_Gw_current_OS ;
		VSlinkGroup( msg, grJoint, &moi ) ;
	}

	wrapup :
		_FREE( botGeom0 );
		_FREE( botGeom1 );
		_FREE( topGeom0 );
		_FREE( topGeom1 );

		End
		return sts ;

} /* method VScstPlPlJoint */
/*----------------------------------------------------------------------------*/

end implementation VSjoint ;

