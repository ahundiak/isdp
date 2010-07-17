/* $Id: VSbmgetxsCS.I,v 1.1.1.1 2001/01/04 21:10:11 cvs Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:        vsbeam/VSbmgetxsCS.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSbmgetxsCS.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:10:11  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.6  1998/01/21  19:35:18  pinnacle
# TR179702512
#
# Revision 1.5  1998/01/21  17:01:20  pinnacle
# TR179702512
#
# Revision 1.4  1998/01/20  19:28:10  pinnacle
# Replaced: vsbeam/VSbmgetxsCS.I for:  by svkadamb for struct
#
# Revision 1.3  1997/11/27  10:58:20  pinnacle
# Replaced: vsbeam/VSbmgetxsCS.I for:  by svkadamb for struct
#
# Revision 1.2  1997/09/29  14:50:50  pinnacle
# TR179700969
#
 *
 * History:
 *      MM/DD/YY AUTHOR	DESCRIPTION
 *      01/21/98 ah     TR179702512 Web Alignment Problem
 *	01/19/98 Suresh The get_state is being forward to the source im case it
 *			is not the source generic.
 *	11/27/97 Suresh The state used for cardinal points must be obtained 
 *			 from the source element or else it will fail for 
 *			ornBeams.
 *      09/26/97 ah     added header
 *      09/29/97 ah	TR179700969 Cardinal Point 
 ***************************************************************************/

class implementation VSbeam ;

#include "madef.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "bstypes.h"
#include "bserr.h"
#include "vsdef.h"
#include "vsdpb.h"
#include "vsrfldef.h"
#include "vsgeommacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
#include "EMSssprops.h"
#include "EMSmsgdef.h"
/*
 * Includes of function prototypes.
 */
#include "bsdotp.h"
#include "maidmx.h"
#include "mamulmx.h"
#include "vsbeamproto.h"
#include "vsophstproto.h"
#include "vsvecmxproto.h"

extern long VSbeamGetState(struct GRid *beamId, int *state);

extern long	VSfindIfXvecOfPrflReversed
				__((	long*,
					OM_S_OBJID,
					OMuword,
					struct GRmd_env*,
					struct GRobj_env*,
					struct GRobj_env*,
					int* )) ;
extern long	VSgetVectorFrColl __((	long*,
					struct GRid*,
					GRname,
					GRname,
					GRname,
					IGRvector )) ;
/*----------------------------------------------------------------------------*/
method VSgetCrossSectionCS(	long			*msg ;
				struct GRmd_env		*myEnv ;
				struct GRobj_env	*surface,
							*axis ;
				double			pntParm ;
				struct GRid		*xDef ;
				IGRmatrix		xCS ) {

	long		sts,		/* OM return code		   */
			bsRC ;		/* BS return code		   */
	int             haveDir,	/* Have to recompute x-vector ?    */
			xIsReversed ;
	double 		*mapMx;		/* Matrix fr. reference position   */
					/* ... to final pos. for section   */
	short		_4 = 4 ;	/* For MAmulmx ...		   */
	IGRpoint	pntAtX ;	/* Point of section on curve	   */
	IGRvector	tanAtX,		/* Tangent to curve at section 	   */
			normAtX,	/* Surface normal at section	   */
			xvecAtX,	/* xvecAtX = normAtX ^ tanAtX	   */
			xDir,		/* Available direction of x-vector */
			vector ;	/* Auxilliary vector		   */
	IGRmatrix 	csAtX,		/* Coordinate system at section	   */
			auxMx1,		/* Auxilliary matrix #1		   */
			auxMx2 , 	/* Auxilliary matrix #2		   */
			auxMx3 ; 	/* Auxilliary matrix #3		   */
	VSpartAttr	part ;		/* My part attributes		   */
	VSbeamAttr	myAttr ;	/* My beam attributes		   */
	struct GRid	topBeam ;

	SetProc( VSbeam_VSgetCrossSectionCS ) ; Begin ; __DBGpr_me() ;

	if( pntParm < 0. || pntParm > 1. ) {
		sts = OM_W_ABORT ; *msg = MSINARG ; goto wrapup ;
	}

	__DBGpr_dbl( "CS at pm", pntParm ) ;

	/*
	 * Retrieve attributes.
	 */
	part.Iwant	=  VS_m_xOffset
			 | VS_m_yOffset
			 | VS_m_RotAngle
			 | VS_m_cardPnt
			 | VS_m_Symmetry ;
	part.specific	= (void *) &myAttr ;
	sts = om$send(	msg	= message GRvg.GRgetattr( msg, (char *) &part ),
			targetid= my_id ) ;
	__CheckRC( sts, *msg, "GRvg.GRgetattr", wrapup ) ;

	__DBGpr_obj( "Surface", surface->_grid ) ;
	__DBGpr_mat( "Surface mx", surface->_matrix ) ;
	/* 
	 * Get CS from curve and surface at parameter on axis.
	 */
	sts = vs$getCS_from_cv_and_sf( 	msg	= msg,
					surface	= surface,
					curve	= axis,
					pntParm	= pntParm, 
					origin	= pntAtX,
					tangent	= tanAtX,
					normal	= normAtX,
					binormal= xvecAtX ) ;
	__CheckRC( sts, *msg, "vs$getCS_from_cv_and_sf", wrapup ) ;

	__DBGpr_vec( "x at X", xvecAtX ) ;
	__DBGpr_vec( "y at X", normAtX ) ;
	__DBGpr_vec( "z at X", tanAtX ) ;

	{
		VSopHistory	*history = NULL ;
		extern OMuword	OPP_VSrfsBeam_class_id ;

		sts = om$send(	msg	= message VSfeature.VSgetOperationHistory(
							msg, myEnv, &history ),
				targetid= my_id ) ;
		__CheckRC( sts, *msg, "VSfeature.VSgetOperationHistory", wrapup ) ;

		topBeam.objid = history->resultId ;
		topBeam.osnum = history->resultOs ;
		VSfreeOpHistory( history ) ;

		if( !vs$is_ancestry_valid(
					object	= &topBeam,
					classid	= OPP_VSrfsBeam_class_id ) ) {
			topBeam.objid = NULL_OBJID ;
		}
	}
	/*
	 * Get available direction of x-vector CS.
	 */
	if( IF_NULL_OBJID( topBeam.objid ) ) {
		sts = om$send(
			msg	= message VSbeam.VSgetXdirectionForCrossSectionCS(
							msg, &haveDir, xDir ),
			targetid= my_id ) ;
	} else {
		sts = om$send(
			msg	= message VSbeam.VSgetXdirectionForCrossSectionCS(
							msg, &haveDir, xDir ),
			targetid= topBeam.objid,
			targetos= topBeam.osnum ) ;
	}	       
	__CheckRC( sts, *msg, "VSbeam.VSgetXdirectionForCrossSectionCS", 
		   wrapup ) ;

	/*
	 * Recompute x-vector CS.
	 */
	xIsReversed = FALSE ;
	if( *msg == EMS_I_Fail ) {
		int	reversed ;
		sts = VSfindIfXvecOfPrflReversed(	msg,
							my_id,
							OM_Gw_current_OS,
							myEnv,
							surface,
							axis,
							&reversed ) ;
		if( ( sts & 1 & *msg ) && reversed ) {
			VSnegvc( xvecAtX, xvecAtX ) ;
			xIsReversed = TRUE ;
		}
	} else {
		
		if( haveDir && BSdotp( &bsRC, xDir, xvecAtX ) < 0. ) {
			__DBGpr_com( "REVERSE x-vector" ) ;
			VSnegvc( xvecAtX, xvecAtX ) ;
			xIsReversed = TRUE ;
		} else  __DBGpr_com( "DON'T REVERSE x-vector" ) ;
	}

	/*
	 * Find reference section and copy/map it to site.
	 */
	sts = om$send(	msg	= message VSbeam.VSgetProfileDef( msg, xDef ),
			targetid= my_id ) ;
	__CheckRC( sts, *msg, "VSbeam.VSgetProfileDef", wrapup ) ;
	__DBGpr_obj( "Id of reference section", *xDef ) ;

/* TR179700969
 * TR179702512 
 * Take origin and cardinal point into account.
*/
  {	
    IGRboolean  cardOpt = FALSE ;
    int	        state ;
    struct GRid stateID;

    stateID.objid = my_id;
    stateID.osnum = OM_Gw_current_OS ;

    VSbeamGetState(&stateID,&state);

    if( state & VS_m_NdState ) cardOpt = TRUE ;

    VScardpt_to_vector(myEnv, *xDef, &cardOpt, myAttr.card, vector );
  }

	MAidmx( &bsRC, auxMx1 );
	auxMx1[ 3] = vector[0] ;
	auxMx1[ 7] = vector[1] ;
	auxMx1[11] = vector[2] ;
	__DBGpr_mat( "Card points", auxMx1 ) ;

	/*
	 * Take into account the symmetry if any: mapMx will be auxMx2
	 */
	if( myAttr.sym != VS_e_No_Symm ) 
		mapMx = VSmirrormx( myAttr.sym, auxMx1, auxMx2 ) ;
	else	mapMx = VSmxcpy( auxMx2, auxMx1 ) ;
	__DBGpr_mat( "Symmetry", mapMx ) ;

	/*
	 * Take into account the rotation if any: mapMx will be auxMx1
	 */
	__DBGpr_dbl( "rotation", myAttr.rotat ) ;
	if( myAttr.rotat != 0. )
		mapMx = VSrotatemx( myAttr.rotat, mapMx, auxMx1 ) ;
	else	mapMx = VSmxcpy( auxMx1, auxMx2 ) ;
	__DBGpr_mat( "Rotation", mapMx ) ;

	/*
	 * Take into account the offset if any: mapMx will be auxMx2
	 */
	if( myAttr.xoff != 0. || myAttr.yoff != 0. ) {
		vector[0] = myAttr.xoff ;
		vector[1] = myAttr.yoff ;
		vector[2] = 0 ;
		mapMx = VStranslatemx( vector, mapMx, auxMx2 ) ;
	} else	mapMx = VSmxcpy( auxMx2, auxMx1 ) ;
	__DBGpr_mat( "Offset", mapMx ) ;

        VSmkmatrix( VSzerovc( vector ), xvecAtX, normAtX, tanAtX, csAtX ) ;
        __DBGpr_mat( "Site CS", csAtX ) ;

	/*
	 * Transform section CS to curve CS : rotation only.
	 */
	MAmulmx( &bsRC, &_4, &_4, &_4, csAtX, mapMx, auxMx1 ) ;
	__DBGpr_mat( "Ref to curve", auxMx1 ) ;

	/*
	 * And finally translate to the point on curve: mapMx will be auxMx2.
	 */ 
	__DBGpr_vec( "Point at X", pntAtX ) ;
	mapMx = VStranslatemx( pntAtX, auxMx1, auxMx3 ) ;
	__DBGpr_mat( "Translate to curve", mapMx ) ;

	VSmxcpy( xCS, mapMx ) ;

	__DBGpr_mat( "CS", xCS ) ;

	/*
	 * Map matrix to beam coordinates.
	 */
	if( myEnv->_MATRIX_TYPE != MAIDMX ) {
		short xCStype ;
		VSmulmx( myEnv->_MATRIX, xCS, xCS, &xCStype ) ;
	}

	__DBGpr_mat( "CS mapped to beam coords", xCS ) ;

	wrapup :
		End
		return sts ;

} /* method VSgetCrossSectionCS */
/*----------------------------------------------------------------------------*/

end implementation VSbeam ;

