/* $Id: VSdrwcstbmpf.I,v 1.2 2001/01/16 22:18:44 ramarao Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:        vsdrawing/VSdrwcstbmpf.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSdrwcstbmpf.I,v $
 *      Revision 1.2  2001/01/16 22:18:44  ramarao
 *      *** empty log message ***
 *
# Revision 1.2  2000/12/06  23:57:44  pinnacle
# Replaced: struct/vsdrawing/VSdrwcstbmpf.I for:  by jpulapar for Service Pack
#
# Revision 1.1  2000/11/02  15:29:22  pinnacle
# Created: struct/vsdrawing/VSdrwcstbmpf.I by rchennup for Service Pack
#
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.5  1998/01/21  19:17:28  pinnacle
# TR179702512
#
# Revision 1.4  1998/01/21  19:09:02  pinnacle
# TR179702512
#
# Revision 1.3  1998/01/21  17:49:06  pinnacle
# TR179702512
#
# Revision 1.2  1997/09/29  15:37:28  pinnacle
# TR179700969
#
 *
 * History:
 *      MM/DD/YY AUTHOR	DESCRIPTIO
 *      09/26/97 ah     added header
 *      09/29/97 ah	TR179700969 Cardinal Point 
 *      01/21/98 ah     TR179702512 Web Alignment Problem
 *      06/12/00 JDev   etl#4118 curved stiffener drawing axis mismatch 
 ***************************************************************************/

class implementation VSbeam ;

#include <stdio.h>
#include <malloc.h>
#include "madef.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "EMSmsgdef.h"
#include "vsdpb.h"
#include "vsdrw.h"
#include "vsdatamacros.h"
#include "vsgeommacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "maidmx.h"
#include "matypemx.h"
#include "vsbeamproto.h"
#include "vsdrwproto.h"
#include "vsvecmxproto.h"

extern void	VSsetGRids() ;
extern long	EFproject_any_curve_on_planen() ;

extern long VSbeamGetState(struct GRid *beamId, int *state);

/*----------------------------------------------------------------------------*/
long VSdrwGetCardinalPoint( msg, bmId, bmEnv, pm, cardPnt )

long		*msg ;
struct GRid	*bmId ;
struct GRmd_env *bmEnv ;
double		pm ;
IGRpoint	cardPnt ; {

	/*
	 * This function returns the coordinate of the beam's cardinal point
	 * (cardPnt) at parameter (pm).
	 */

	long			sts ;		/* OM completion code.	      */
	VSsuppList		bmSupps ;	/* Supports of beam.	      */
	int			suppCount ;	/* Count of supports.	      */
	VSpartAttr		partAttr ;	/* Attributes of beam.	      */
	VSbeamAttr		beamAttr ;	/* Specific attributes of     */
						/* beam.		      */
	struct GRid		xDef ;		/* Id of cross section	      */
						/* definition.		      */
	IGRmatrix		CS ;		/* CS of cross section	      */
						/* definition.		      */
	struct GRobj_env        bmAxis;

	SetProc( VSdrwGetCardinalPoint ); Begin

	__DBGpr_obj( "Beam", *bmId ) ;


	/*
	 * Get supports of beam.
	 */
	sts = om$send( msg	= message VSpart.VSgetSupports( msg,
								bmEnv,
								&suppCount,
								bmSupps ),
		       senderid = bmId->objid,
		       targetid = bmId->objid,
		       targetos = bmId->osnum ) ;

	__CheckRC( sts, *msg, "VSpart.VSgetSupports", wrapup ) ;

	__DBGpr_obj( "Surface of beam", bmSupps[0]._grid ) ;
	__DBGpr_obj( "Axis    of beam", bmSupps[1]._grid ) ;

	/*
	 * Get type of beam's cardinal point.
	 */
	partAttr.Iwant	  = VS_m_cardPnt ;
	partAttr.specific = (void *) &beamAttr ;

	sts = om$send( msg	= message VSbeam.GRgetattr( msg,
							    (char *)&partAttr ),
		       senderid = bmId->objid,
		       targetid = bmId->objid,
		       targetos = bmId->osnum ) ;

	__CheckRC( sts, *msg, "VSbeam.GRgetattr", wrapup ) ;

	__DBGpr_int( "Type of cardinal point", beamAttr.card ) ;

	/*
	 * Get coordinate system of cross section definition at given parameter.
	 */
/* Addition for etl#4118 begin */
        /*
         * Get axis of beam.
         */
        sts = om$send( msg      = message VSbeam.VSgetSupportAxis(
                                                msg, bmEnv, &bmAxis ),
                       senderid = bmId->objid,
                       targetid = bmId->objid,
                       targetos = bmId->osnum ) ;
        __CheckRC( sts, *msg, "VSbeam.VSgetSupportAxis", wrapup ) ;

        __DBGpr_obj( "Axis of beam", bmAxis._grid ) ;
/* Addition for etl#4118 end */
	// bmSupps+1 commented for etl#4118
	sts = om$send( msg= message VSbeam.VSgetCrossSectionCS( msg,
							      bmEnv,
							      bmSupps,
							      //bmSupps+1,
							      &bmAxis,
							      pm,
							      &xDef,
							      CS ),
		       senderid = bmId->objid,
		       targetid = bmId->objid,
		       targetos = bmId->osnum ) ;
	__CheckRC( sts, *msg, "VSbeam.VSgetCrossSectionCS", wrapup ) ;

/* TR179702512 */
  {	
    IGRboolean  cardOpt = FALSE ;
    int         state;

    VSbeamGetState(bmId,&state);

    if( state & VS_m_NdState ) cardOpt = TRUE ;
    VScardpt_to_point( bmEnv, xDef, &cardOpt, beamAttr.card, cardPnt ) ;
  }

	/*
	 * Compute coordinate of beam's cardinal point.
	 */

	VSmxprodpt( CS, cardPnt, cardPnt ) ;

	__DBGpr_vec( "Cardinal point", cardPnt ) ;

	wrapup :
		End
		return sts ;

} /* VSdrwGetCardinalPoint */
/*----------------------------------------------------------------------------*/
long VSdrwCstBeamProf( msg, inp, xData, outp )

long			*msg ;
VSdrwInputData		*inp ;
VSdrwExecData		*xData ;
VSdrwGraphicGroup	*outp ; {

	/*
	 * This function extracts the profile of a beam.
	 */

	long			sts ;		/* OM completion code.	      */
	VSsuppList		bmSupps ;	/* Supports of beam.	      */
	int			suppCount ;	/* Count of supports.	      */
	IGRpoint		ptOnAxis ;	/* Point of view plane onto   */
						/* axis.		      */
	double			pm ;		/* Parameter of the above.    */
	struct GRvg_construct	cst ;		/* Construction list for      */
						/* output merged profile.     */
	struct GRid		profile ;	/* Profile of beam.	      */
	struct GRid		mergedPrf ;	/* Merged profile.	      */
	IGRmatrix		idmx,		/* Matrix identity.	      */
				scaleMx ;	/* Scaling matrix.	      */
	short			scaleMxType ;	/* Type of scaleMx.	      */
	IGRpoint		cardPnt,	/* Cardinal point of beam.    */
				cardPntScale ;	/* Scale of Cardinal point    */
						/* without translation.       */
	OMuword 		outClassid ;	/* Classid of projected       */
						/* profile.		      */
	short			action = 1,	/* Action to set properties.  */
				props ; 	/* Properties of output       */
						/* merged profile.	      */
	struct GRmd_env 	axisEnv ;	/* Real env of axis.	      */

	SetProc( VSdrwBeamProfile ); Begin

	__DBGpr_obj( "Beam to draw", *(inp->elmId) ) ;

	VSsetGRids( inp->drwInfo.drwEnv->_MD_OS, 1, &mergedPrf ) ;
	VSsetGRids( inp->drwInfo.drwEnv->_MD_OS, 1, &profile   ) ;

	/*
	 * Allocate memory for output curve.
	 */
	outp->count = 0 ;
	if( !( outp->list = _MALLOC( 1, struct GRid ) ) ) vs$mem_fail() ;
	VSsetGRids( inp->drwInfo.drwEnv->_MD_OS, 1, outp->list ) ;

	/*
	 * Construct construction list for output curve.
	 */
	vs$fill_cnst_list( Msg		= msg,
			   Env_info	= inp->drwInfo.drwEnv,
			   Level	= xData->overrides.elmLevel,
			   Display	= &xData->overrides.elmDisplay,
			   Cnst_list	= cst ) ;

	/*
	 * Get supports of beam.
	 */
	sts = om$send( msg	= message VSpart.VSgetSupports( msg,
								inp->elmEnv,
								&suppCount,
								bmSupps ),
		       senderid = inp->elmId->objid,
		       targetid = inp->elmId->objid,
		       targetos = inp->elmId->osnum ) ;

	__CheckRC( sts, *msg, "VSpart.VSgetSupports", wrapup ) ;

	__DBGpr_obj( "Surface of beam", bmSupps[0]._grid ) ;
	__DBGpr_obj( "Axis    of beam", bmSupps[1]._grid ) ;

	/*
	 * Get parameter point to extract profile.
	 */
	axisEnv.md_id = bmSupps[1].mod_env.md_id ;
	VSmulmx( bmSupps[1]._matrix, inp->elmEnv->_MATRIX, axisEnv._MATRIX,
		 &axisEnv._MATRIX_TYPE ) ;

	sts = VSdrwFindPointOfViewPlaneOnAxis( msg,
					       &bmSupps[1]._grid,
					       &axisEnv,
					       inp->drwInfo.viewPlane,
					       ptOnAxis,
					       &pm ) ;

	__CheckRC( sts, *msg, "VSdrwFindPointOfViewPlaneOnAxis", wrapup ) ;

	__DBGpr_dbl( "Parameter to get profile", pm ) ;

	/*
	 * Get profile at found parameter.
	 */
	sts = om$send(	msg	= message VSbeam.VSextractProfile( msg,
								   inp->elmEnv,
								   bmSupps,
								   bmSupps + 1,
								   pm,
								   &cst,
								   AC_3D_REP,
								   &profile ),
			senderid= inp->elmId->objid,
			targetid= inp->elmId->objid,
			targetos= inp->elmId->osnum ) ;
	__CheckRC( sts, *msg, "VSbeam.VSextractProfile", wrapup ) ;

	__DBGpr_obj( "Profile of beam", profile ) ;

	/*
‚	 * Merge profile to one curve.
	 */
	sts = vs$mergeCompCurve( msg		= msg,
				 ccId		= &profile,
				 ccEnv		= cst.env_info,
				 cst		= &cst,
				 delInputCv	= TRUE,
				 mergedCvId	= &mergedPrf ) ;

	__CheckRC( sts, *msg, "vs$mergeCompCurve", wrapup ) ;

	__DBGpr_obj( "Merged profile", mergedPrf ) ;

	VSsetGRids( inp->drwInfo.drwEnv->_MD_OS, 1, &profile ) ;

	/*
	 * Scale merged profile if requested.
	 */
	if( xData->overrides.dpAttr.scale != 1. ) {
		__DBGpr_dbl( "Scale of profile", xData->overrides.dpAttr.scale);

		/*
		 * Get cardinal point of beam at found parameter.
		 */
		sts = VSdrwGetCardinalPoint( msg,
					     inp->elmId,
					     inp->elmEnv,
					     pm,
					     cardPnt ) ;

		__CheckRC( sts, *msg, "VSdrwGetCardinalPoint", wrapup ) ;

		__DBGpr_vec( "Cardinal point of beam", cardPnt ) ;

		/*
		 * Construct scaling matrix.
		 */
		MAidmx( msg, idmx ) ;
		VSscalemx( xData->overrides.dpAttr.scale, idmx, scaleMx ) ;

		/*
		 * Find the translation to have the scaling profile with
		 * respect to axis.
		 *
		 *				    -----------
		 *					 |
		 *	------- 			 |
		 *	   |				 |
		 *	   |		=>		 |
		 *	   |	   (scaling without	 |
		 *	*------     translation)	 |
		 *	^				 |
		 *	|		      * <-  -----------
		 *     axis		      ^  ^
		 *			      |   \
		 *			     axis   translation
		 */
		VSmxprodvc( scaleMx, cardPnt, cardPntScale ) ;

		__DBGpr_vec( "Cardinal point scale", cardPntScale ) ;

		scaleMx[3]  = cardPnt[0] - cardPntScale[0] ;
		scaleMx[7]  = cardPnt[1] - cardPntScale[1] ;
		scaleMx[11] = cardPnt[2] - cardPntScale[2] ;

		MAtypemx( msg, scaleMx, &scaleMxType ) ;

		__DBGpr_mat( "Scaling matrix", scaleMx ) ;

		/*
		 * Scale merged profile.
		 */
		sts = om$send( msg	= message GRgraphics.GRxform(
							     msg,
							     cst.env_info,
							     &scaleMxType,
							     scaleMx,
							     &mergedPrf.objid ),
			       senderid = mergedPrf.objid,
			       targetid = mergedPrf.objid,
			       targetos = mergedPrf.osnum ) ;

		__CheckRC( sts, *msg, "GRgraphics.GRxform", wrapup ) ;
	}

	/*
	 * Project merged profile to drawing plane.
	 */
	sts = EFproject_any_curve_on_planen( msg,
					     &cst,
					     &mergedPrf,
					     cst.env_info,
					     inp->drwInfo.drwPlane,
					     inp->drwInfo.viewVector,
					     outp->list,
					     &outClassid ) ;

	__CheckRC( sts, *msg, "EFproject_any_curve_on_planen", wrapup ) ;

	/*
	 * Set filled display for projected merged profile if requested.
	 */
	if( xData->overrides.dpAttr.filledDisplay ) {
		__DBGpr_com( "Draw profile with filled display" ) ;

		props  = GRFILLED_DISPLAY ;

		sts = om$send( msg	= message GRgraphics.GRchgprops(
								       msg,
								       &action,
								       &props ),
			       senderid = outp->list->objid,
			       targetid = outp->list->objid,
			       targetos = outp->list->osnum ) ;

		__CheckRC( sts, *msg, "GRgraphics.GRchgprops", wrapup ) ;
	}

	outp->count = 1 ;

	*msg = MSSUCC ;
	sts  = OM_S_SUCCESS ;

	wrapup :
		if( !( sts & 1 & *msg ) ) {
			if( outp->list ) {
				vs$bulk_delete( grids  = outp->list,
						theEnv = cst.env_info ) ;

				_FREE( outp->list ) ;
				outp->list  = NULL ;
				outp->count = 0 ;
			}
		}

		vs$bulk_delete( grids  = &mergedPrf,
				theEnv = cst.env_info ) ;

		vs$bulk_delete( grids  = &profile,
				theEnv = cst.env_info ) ;

		End
		return sts ;

} /* VSdrwCstBeamProf */
/*----------------------------------------------------------------------------*/

end implementation VSbeam ;
