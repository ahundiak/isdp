/* $Id: VSplplwldtyp.I,v 1.1.1.1 2001/01/04 21:10:48 cvs Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:	struct/vsjoint/VSplplwldtyp.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VSplplwldtyp.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:10:48  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.1  1997/11/14  12:53:34  pinnacle
# Created: vsjoint/VSplplwldtyp.I by svkadamb for struct
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *			suresh		creation 
 ***************************************************************************/
/*
	I/STRUCT
*/ 
class implementation VSjoint ;

#include <math.h>
#include <values.h>
#include "bserr.h"
#include "EMSmsgdef.h"
#include "vs.h"
#include "vsplatedef.h"
#include "vsbeamdef.h"
#include "vsmiscmacros.h"
#include "vsgeommacros.h"
#include "vsdatamacros.h"
#include "vsdbgmacros.h"

#include "bssfevaln.h"
#include "maang2vc.h"
#include "bsmkvec.h"

#define VS_K_ButtWeld 1
#define VS_K_FilletWeld 2

/*----------------------------------------------------------------------------*/
method VSgetplplweldtype(long			*msg ;
			struct GRobj_env	plates[2] ;
			int			*weldType ) {

	long			sts ;	/* OM return code		*/
	struct GRobj_env	bot0,	/* Bottom surface of plate #0	*/
				bot1;	/* Bottom surface of plate #1	*/
	struct IGRbsp_surface   *botGeom0,
                                *botGeom1;

	IGRvector               botNorm0,
                                botNorm1 ;
        IGRpoint                ptOnBot0,
                                ptOnBot1;
	int			nbNorms,
				isPlanar0,
				isPlanar1 ;
	int			sameSide = 0;
	long			rc;

	SetProc( VSjoint_VSgetplplweldtype ) ; Begin ; __DBGpr_me() ;

	botGeom0 = botGeom1 = NULL ;

	sts = om$send(  msg     = message NDmacro.ACreturn_foot(
                                                msg, VS_K_plBotSfPath,
                                                &bot0._grid, NULL, NULL ),
                        targetid= plates[0]._objid,
                        targetos= plates[0]._osnum ) ;
        __CheckRC( sts, *msg, "NDmacro.ACreturn_foot", wrapup ) ;

	sts = om$send(  msg     = message NDmacro.ACreturn_foot(
                                                msg, VS_K_plBotSfPath,
                                                &bot1._grid, NULL, NULL ),
                        targetid= plates[1]._objid,
                        targetos= plates[1]._osnum ) ;
        __CheckRC( sts, *msg, "NDmacro.ACreturn_foot", wrapup ) ;

	bot0.mod_env  = plates[0].mod_env ;
	bot1.mod_env  = plates[1].mod_env ;

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

        isPlanar0 = vs$is_surface_planar( msg = msg, surfGeom = botGeom0 ) ;
        isPlanar1 = vs$is_surface_planar( msg = msg, surfGeom = botGeom1 ) ;

	BSsfevaln( botGeom0, 0.5, 0.5, 1, &nbNorms, ptOnBot0,
                   (IGRvector *) botNorm0, &rc ) ;
        if( BSERROR( rc) ) vs$error( msgval = EMS_E_SurfaceError ) ;
 
        BSsfevaln( botGeom1, 0.5, 0.5, 1, &nbNorms, ptOnBot1,
                   (IGRvector *) botNorm1, &rc ) ;
        if( BSERROR( rc ) ) vs$error( msgval = EMS_E_SurfaceError ) ;
 
        __DBGpr_vec( "Normal of bot 0", botNorm0 ) ;
        __DBGpr_vec( "Normal of bot 1", botNorm1 ) ;

	if( isPlanar0 && isPlanar1 ) {
		double	angle[3] ;

		MAang2vc( &rc, botNorm0, botNorm1, angle );

		if( fabs( angle[1] ) <= fabs( sin( 10*M_PI/180 ) ) ) {
			*weldType = VS_K_ButtWeld ;
		} else {
			*weldType = VS_K_FilletWeld ;
		}
		goto wrapup ;
	} else {
		int		nb_norms ;
		IGRpoint	ptOnSf0 ;
		IGRvector	sfNorm1,
				vecToBot0,
				vecToBot1 ;
		double		angle[3] ,
				upar = 0.0,
				vpar = 0.0 ;
		for( upar = 0.0 ; upar < = 1.0 ; upar = upar + 1.0 ) {

			BSsfevaln( botGeom0, upar, vpar, 1, &nb_norms, ptOnSf0,
       		            		(IGRvector *) sfNorm1, &rc ) ;
       		 	if( BSERROR( rc ) ) vs$error( msgval = EMS_E_SurfaceError ) ;

			BSmkvec (&rc, vecToBot0, ptOnSf0, ptOnBot1 );
			BSmkvec (&rc, vecToBot1, ptOnSf0, ptOnBot1 );

			MAang2vc( &rc, vecToBot0, vecToBot1, angle );

			if( angle[2] >=0.0 ) sameSide++ ;
		}
		if( sameSide > 1 ) {
			*weldType = VS_K_ButtWeld ;
		} else {
			*weldType = VS_K_FilletWeld ;
		}
			
	}

	wrapup :
		_FREE( botGeom0 ) ; _FREE( botGeom1 ) ;
		End
                return sts ;

}/* method VSgetplplweldtype */
/*----------------------------------------------------------------------------*/

end implementation VSjoint ;

