/* $Id: VSjnntfylis.I,v 1.1.1.1 2001/01/04 21:10:47 cvs Exp $ pinnacle Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:	struct/vsjoint/VSjnntfylis.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VSjnntfylis.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:10:47  cvs
 *	Initial import to CVS
 *	
# Revision 1.2  1999/01/05  09:29:22  pinnacle
# Replaced: vsjoint/VSjnntfylis.I for:  by manoj for struct
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	unknown 	unknown		creation 
 *      01/04/99	manoj		modification  for TR #179900008
 ****************************************************************************/
class implementation VSjoint ;

#include "bstypes.h"
#include "dpmacros.h"
#include "acrepdef.h"
#include "vsmiscmacros.h"
#include "vsgeommacros.h"
//#define vsDEBUG
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "bscveval.h"
#include "bsmkvec.h"
#include "bsnorvec.h"
#include "bsorthovec.h"
/*----------------------------------------------------------------------------*/
method GRnotifylis( long *msg, *OMmsg, *mask ; OM_S_MESSAGE *graphics_msg ) {


	long			sts,		/* OM return code	*/
				rc ;		/* Completion code	*/
	struct GRgraphics_GRdisyourself_Msg
				*args ;		/* Args of notified msg	*/
	IGRpoint		pnt ;		/* Point on curve of jnt*/
	struct GRid		grJoint ;	/* Sender graphic joint	*/
	short			jnGrProps ;	/* Properties of above	*/
	struct GRsymbology	jnSymb ;	/* Symbology of above	*/
	struct DP_information	*dpInfo ;	/* Display information	*/
	struct IGRaltdisplay	*altSymb,	/* Alternate symbology	*/
				altDsp ;	/* As above but local	*/
	enum GRdpmode		*dpMode ;	/* Display mode		*/
	struct IGRbsp_curve	*jnGeom ;	/* Geom. of gr. joint	*/
	unsigned char		style ;		/* Style of symbol	*/
	IGRvector		normal,		/* Normal at pt. on cv.	*/
				tangent ;	/* Tangent at pt. on cv.*/	

	SetProc( VSjoint_GRnotifylis ) ; Begin ; __DBGpr_me() ;

	if( *mask != GR_DISPLAYED ) goto wrapup ;
  
	args	= (struct GRgraphics_GRdisyourself_Msg *)
						graphics_msg->p_arglist ;
	dpInfo	= args->sp_info ;
	altSymb	= args->alt_symb ;
	dpMode	= args->mode ;

	/*
	 * I am notified by a component of my joint group to which we listen.
	 * This means we're in AC_2D_REP (otherwise we are not a listener).
	 */
	grJoint.objid = sender_id ;
	grJoint.osnum = sender_os ;

	sts = om$send(	msg	= message GRgraphics.GRgetprops(
							&rc, &jnGrProps ),
			targetid= grJoint.objid,
			targetos= grJoint.osnum ) ;
	if( !( sts & 1 & rc ) ) goto wrapup ;

	sts = om$send(	msg	= message GRvg.GRgetsymb( msg, &jnSymb ),
			targetid= grJoint.objid,
			targetos= grJoint.osnum ) ;
	if( !( sts & 1 & rc ) ) goto wrapup ;

	if( !    ( (  ( jnGrProps & GRIS_DISPLAYABLE )
		   || *dpMode == GRhdo
		   || *dpMode == GRhhdo
		   || *dpMode == GRheo
		   || *dpMode == GRbdheo
		   || *dpMode == GRbeheo  )
		&& DPlevel_on( jnSymb.level, dpInfo ) ) ) {
			goto wrapup ;
	}

	sts = om$send(	msg	= message GRvg.GRgenabsg(
							&rc,
							args->mx_type,
							args->matrix,
							(char **) &jnGeom ),
			targetid= grJoint.objid,
			targetos= grJoint.osnum ) ;
	if( !( sts & 1 & rc ) ) goto wrapup ;
	//The part "nGeom->num_poles < 3 " in the following "if" condition
	//in itroduced for TR No. 179900008 

	if( vs$is_curve_linear( msg = &rc, curveGeom = jnGeom	) && jnGeom->num_poles < 3 ) {
		int		i ;

		__DBGpr_vec( "Lineseg pt 0", jnGeom->poles ) ;
		__DBGpr_vec( "Lineseg pt 1", jnGeom->poles + 3 ) ;
	
		BSmkvec( &rc, tangent, jnGeom->poles, jnGeom->poles + 3 ) ;
		BSnorvec( &rc, tangent ) ;
		__DBGpr_vec( "Tangent", tangent ) ;
		BSorthovec( &rc, tangent, normal ) ;
		BSnorvec( &rc, normal ) ;
		for( i = 0 ; i < 3 ; i++ ) {
			pnt[i] = 0.5 * ( jnGeom->poles[i] + jnGeom->poles[i+3] ) ;
		}
	} else {
		double	eval[9] ;
		int	i ;

		BScveval( jnGeom, 0.5, 2, (IGRpoint *) eval, &rc ) ;
		for( i = 0 ; i < 3 ; i++ ) {
			pnt[i]		= eval[  i] ;
			tangent[i]	= eval[3+i] ;
			normal[i] 	= eval[6+i] ;
		}
		BSnorvec( &rc, tangent ) ;
		BSorthovec( &rc, tangent, normal ) ;
		BSnorvec( &rc, normal ) ;
	}
	if( !altSymb ) {
		altDsp.color		= &jnSymb.display_attr.color ;
		altDsp.weight		= &jnSymb.display_attr.weight ;
		altDsp.style		= &jnSymb.display_attr.style ;
	} else {
		altDsp.color  = ( altSymb->color ) ? altSymb->color
					  : &jnSymb.display_attr.color ;
		altDsp.weight = ( altSymb->weight ) ? altSymb->weight
					  : &jnSymb.display_attr.weight ;
		altDsp.style  = ( altSymb->style ) ? altSymb->style
					  : &jnSymb.display_attr.style ;
	}
	style = 2 ;
	altDsp.style = &style ;

	VSdrawViewIndepLineSeg( &rc, *dpMode, &altDsp, dpInfo,
				pnt, tangent, normal ) ;

	wrapup :
		/*
		 * Be optimistic and do not disturb the system for a display
		 * that failed.
		 */
		*msg = MSSUCC ;
		End
		return *OMmsg = OM_S_SUCCESS ;

} /* method GRnotifylis */
/*----------------------------------------------------------------------------*/

end implementation VSjoint ;

