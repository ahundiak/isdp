/* $Id: VSplcxsect.I,v 1.1.1.1 2001/01/04 21:10:40 cvs Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:        vsgeom/VSplcxsect.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSplcxsect.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:10:40  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.2  1997/09/29  15:36:26  pinnacle
# TR179700969
#
 *
 * History:
 *      MM/DD/YY AUTHOR	DESCRIPTIO
 *      09/26/97 ah     added header
 *      09/29/97 ah	TR179700969 Cardinal Point 
 ***************************************************************************/

class implementation VSbeam ;

#include "OMmacros.h"
#include "grerr.h"
#include "bserr.h"
#include "bstypes.h"
#include "EMSmsgdef.h"
#include "vsdpb.h"
#include "vsRDBmacros.h"
#include "vsbeammacros.h"
#include "vsmiscmacros.h"
#include "vsgeommacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "maidmx.h"
#include "mamulmx.h"
#include "matypemx.h"
#include "bsdotp.h"
#include "vsbeamproto.h"
#include "vsvecmxproto.h"
/*----------------------------------------------------------------------------*/
#if defined(__STDC__) || defined(__cplusplus)
/* ACC bug : won't accept ANSI declaration with args inside and definition
   with args outside a la K&R C when an arg has type (unsigned) short: here
   searchOS causes it to choke...
 */
long VSplace_cross_section(
	long			*msg,
	char			*material,	/* Mat. of X-section	*/
	char			*partType,	/* Family of X-section	*/
	char			*partName,	/* Name of X-section	*/
	OMuword 		searchOS,
	double			xOffset,
	double			yOffset,
	double			rotation,
	IGRboolean		*profOpt,
	enum VScardinal_point	cardinal,
	enum VSsymmetry 	symmetry,
	struct GRobj_env	*surface,	/* Support surface	*/
	struct GRobj_env	*axis,		/* Support axis 	*/
	IGRvector		xDir,		/* X direction		*/
	double			dspRatio,	/* Display ratio	*/
	VSdspRep		dspRep, 	/* Display rep. 	*/
	struct GRvg_construct	*cst,		/* Construction list	*/
	struct GRid		*xSect ) 	/* Created X-section	*/

#else
long VSplace_cross_section(	msg,
				material,	/* Mat. of X-section	*/
				partType,	/* Family of X-section	*/
				partName,	/* Name of X-section	*/
				searchOS,
				xOffset,
				yOffset,
				rotation,
				profOpt,
				cardinal,
				symmetry,
				surface,	/* Support surface	*/
				axis,		/* Support axis 	*/
				xDir,		/* X direction		*/
				dspRatio,	/* Display ratio	*/
				dspRep, 	/* Display rep. 	*/
				cst,		/* Construction list	*/
				xSect ) 	/* Created X-section	*/

long			*msg ;
char			*material,
			*partType,
			*partName ;
OMuword 		searchOS ;
double			xOffset,
			yOffset,
			rotation ;
IGRboolean		*profOpt;
enum VScardinal_point	cardinal ;
enum VSsymmetry 	symmetry ;
struct GRobj_env	*surface,
			*axis ;
IGRvector		xDir ;
double			dspRatio ;
VSdspRep		dspRep ;
struct GRvg_construct	*cst ;
struct GRid		*xSect ;
#endif

{

	struct GRid	sectDef ;
	long		sts,		/* OM completion code		*/
			bsRC ;		/* BS return code		*/
	double		*mapMx; 	/* Matrix fr. reference position*/
					/* ... to final pos. for section*/
	short		four = 4 ;	/* For MAmulmx ...		*/
	IGRpoint	pntAtX ;	/* Point of section on curve	*/
	IGRvector	tanAtX, 	/* Tangent to curve at section	*/
			normAtX,	/* Surface normal at section	*/
			xvecAtX,	/* xvecAtX = normAtX ^ tanAtX	*/
			vector ;	/* Auxilliary vector		*/
	IGRmatrix	csAtX,		/* Coordinate system at section */
			auxMx1, 	/* Auxilliary matrix #1 	*/
			auxMx2 ,	/* Auxilliary matrix #2 	*/
			auxMx3 ;	/* Auxilliary matrix #3 	*/
	struct GRobj_env
			libSect ;	/* Section in macro library	*/
	IGRmatrix	xCS ;		/* CS for final placement	*/
	short		Xmat_type ;	/* Type of above matrix 	*/
	short		action, 	/* For change-properties	*/
			xProps ;	/* Properties of cross-section	*/
	IGRboolean	*cardOpt ;

	*msg		= MSFAIL ;
	sts		= OM_W_ABORT ;
	xSect->objid	= NULL_OBJID ;

	/*
	 * Get CS from curve and surface.
	 */
	sts = vs$getCS_from_cv_and_sf(	msg	= msg,
					surface = surface,
					curve	= axis,
					pntParm = 0.,	/* Start point */
					origin	= pntAtX,
					tangent = tanAtX,
					normal	= normAtX,
					binormal= xvecAtX ) ;
	__CheckRC( sts, *msg, "vs$getCS_from_cv_and_sf", wrapup ) ;

	/*
	 * Set the computed x-vector to the same direction of the given
	 * direction.
	 */
	if( xDir && (BSdotp( &bsRC, xDir, xvecAtX ) <0.) ) {
		/* Reverse x-vector */
		VSnegvc( xvecAtX, xvecAtX ) ;
	}

	/*
	 * Get section set from RDB cache.
	 */
	vs$load_part_from_RDB(	msg		= msg,
				material	= material,
				family		= partType,
				part		= partName,
				osnum		= searchOS,
				object		= &sectDef ) ;
	__CheckRC( 1, *msg, "vs$load_part_from_RDB", wrapup ) ;

	/* The following steps compute the local transformation of the section.
	 * 1.- Take into account origin + cardinal[ point.
	 */
	if( !profOpt ) {
		IGRboolean	tmpOpt = FALSE ;
		cardOpt = &tmpOpt ;
	}else {
		cardOpt = profOpt;
	}
	// TR179700969
	VScardpt_to_vector( 	cst->env_info, 
				sectDef, 
				cardOpt, 
				cardinal, 
				vector );
	profOpt = cardOpt ;

	MAidmx( &bsRC, auxMx1 );
	auxMx1[ 3] = vector[0] ;
	auxMx1[ 7] = vector[1] ;
	auxMx1[11] = vector[2] ;

	/*
	 * 2.- Take into account the symmetry if any: mapMx will be auxMx2
	 */
	if( symmetry != VS_e_No_Symm )
		mapMx = VSmirrormx( symmetry, auxMx1, auxMx2 ) ;
	else	mapMx = VSmxcpy( auxMx2, auxMx1 ) ;

	/*
	 * 3.- Take into account the rotation if any: mapMx will be auxMx1
	 */
	if( rotation != 0. )
		mapMx = VSrotatemx( rotation, mapMx, auxMx1 ) ;
	else	mapMx = VSmxcpy( auxMx1, auxMx2 ) ;

	/*
	 * 4.- Take into account the offset if any: mapMx will be auxMx2
	 */
	if( xOffset != 0. || yOffset != 0. ) {
		vector[0] = xOffset ;
		vector[1] = yOffset ;
		vector[2] = 0 ;
		mapMx = VStranslatemx( vector, mapMx, auxMx2 ) ;
	} else	mapMx = VSmxcpy( auxMx2, auxMx1 ) ;

	VSmkmatrix( VSzerovc( vector ), xvecAtX, normAtX, tanAtX, csAtX ) ;

	/*
	 * Section is in the Oxy plane of the world co-ordinated system,
	 * it will undergo the local transformation, then be mapped on site,
	 * whence the following matrix product.
	 */
	MAmulmx( &bsRC, &four, &four, &four, csAtX, mapMx, auxMx1 ) ;

	/*
	 * Multiply by display ratio (if any) to have section bigger than life.
	 */
	VSscalemx( dspRatio, auxMx1, auxMx2 ) ;

	/*
	 * ... And finally translate to the point on curve: mapMx will be auxMx2
	 */
	mapMx = VStranslatemx( pntAtX, auxMx2, auxMx3 ) ;

	VSmxcpy( xCS, mapMx ) ;

	/*
	 * Extract a copy of section from section set and plate it
	 * on site.
	 */
	sts = vs$get_graphic_section(	msg		= msg,
					sectDef 	= &sectDef,
					representation	= dspRep,
					section 	= &libSect ) ;
	__CheckRC( sts, *msg, "vs$get_graphic_section", wrapup ) ;

	/*
	 * Place section on site.
	 */
	MAtypemx( &bsRC, xCS, &Xmat_type ) ;

	sts = vs$mapProfileToSite(	msg		= msg,
					cst		= cst,
					mapMx		= xCS,
					mxType		= &Xmat_type,
					copy		= TRUE,
					originPrfl	= &libSect,
					onSitePrfl	= xSect ) ;
	__CheckRC( sts, *msg, "vs$mapProfileToSite", wrapup ) ;

	/*
	 * Change section properties to those requested.
	 */
	action = 1 ; xProps = cst->properties ;
	sts = om$send(	msg	= message GRgraphics.GRchgprops(
								msg,
								&action,
								&xProps ),
			senderid= xSect->objid,
			targetid= xSect->objid,
			targetos= xSect->osnum ) ;
	__CheckRC( sts, *msg, "GRgraphics.GRchgprops", wrapup ) ;

	if( !( xProps & GRIS_LOCATABLE ) ) {
		/*
		 * NOTE: since curve is composite and GRowner sets displayable
		 * and locatable at the same time when only displayable or
		 * locatable is requested, we clear that bit afterwards.
		 */
		action = 0 ; xProps = GRIS_LOCATABLE ;
		sts = om$send(	msg	= message GRgraphics.GRchgprops(
								msg,
								&action,
								&xProps ),
				senderid= xSect->objid,
				targetid= xSect->objid,
				targetos= xSect->osnum ) ;
		__CheckRC( sts, *msg, "GRgraphics.GRchgprops", wrapup ) ;
	}
	*msg = MSSUCC ;
	sts = OM_S_SUCCESS ;

	wrapup :
		if( !( sts & 1 & *msg ) ) {
			vs$bulk_delete( count	= 1,
					grids	= xSect,
					theEnv	= cst->env_info ) ;
		}
		return sts ;

} /* VSplace_cross_section */
/*----------------------------------------------------------------------------*/

end implementation VSbeam ;
