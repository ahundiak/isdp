/* $Id: VSdrwcstbmax.I,v 1.3 2001/02/15 23:29:27 ramarao Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:        struct/vsdrawing/VSdrwcstbmax.I
 *
 * Description:
 *      Gets the support axis (centerline) of a beam; axis copied and
 *      translated for use; project the axis on drawing plane for Extract
 *      Drawing process.
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSdrwcstbmax.I,v $
 *      Revision 1.3  2001/02/15 23:29:27  ramarao
 *      Implemented CR# 4038.
 *
 *      Revision 1.2  2001/01/16 22:18:42  ramarao
 *      *** empty log message ***
 *
# Revision 1.2  2000/11/25  19:34:32  pinnacle
# Replaced: struct/vsdrawing/VSdrwcstbmax.I for:  by impd252 for Service Pack
#
# Revision 1.1  2000/11/02  15:29:06  pinnacle
# Created: struct/vsdrawing/VSdrwcstbmax.I by rchennup for Service Pack
#
# Revision 1.2  1998/06/09  15:37:36  pinnacle
# Replaced: vsdrawing/VSdrwcstbmax.I for:  by mdong for struct
#
 *
 * Notes:
 *
 *
 * History:
 *
 * MM/DD/YY     AUTHOR        DESCRIPTION
 * ?/?/?          ?           Creation.
 * 06/09/98      Ming         TR179801121.
 * 11/25/00	adz	      Remove TR 179801121; Check getCrossSectionCS
 ***************************************************************************/
class implementation VSbeam ;

#include <stdio.h>
#include <stdlib.h>
#include "bstypes.h"
#include "EMSmsgdef.h"
#include "vsdrw.h"
#include "vsdatamacros.h"
#include "vsgeommacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "bsmkvec.h"
#include "maidmx.h"
#include "matypemx.h"
#include "vsdrwproto.h"
#include "vspratpt.h"
#include "vsvecmxproto.h"

extern IGRboolean	ASbroadcast_in_progress ;

extern void		VSsetGRids() ;
extern long		EFproject_any_curve_on_planen() ;
/*----------------------------------------------------------------------------*/
long VSdrwCstBeamAxis( msg, inp, xData, option, outp )

long			*msg ;
VSdrwInputData		*inp ;
VSdrwExecData		*xData ;
IGRchar			*option ;
VSdrwGraphicGroup 	*outp ; {

	/*
	 * This function extracts the projection of the beam's axis.
	 */

	long			sts ;		/* OM completion code.	      */
	struct GRobj_env	bmAxis ;	/* Axis of beam		      */
	struct GRvg_construct	cst ;		/* Construction list for      */
						/* wireframe elements.	      */
	struct GRid		wfAxis, 	/* Wireframe of the axis.     */
				prjCv,		/* Projected wireframe.       */
				ofAxis ;	/* Offseted axis.	      */
	struct GRmd_env 	axisEnv ;	/* Real env. of axis.	      */
	double			cardPnt[3],	/* Cardinal point of beam.    */
				midPnt[3],	/* Middle point of axis.      */
				transVec[3],	/* Translation vector.	      */
				transMx[16] ;	/* Translation matrix.	      */
	short			transMxType ;	/* Type of translation matrix.*/
	OMuword 		pjClassid ;	/* Class of the above	      */
	IGRboolean		saveBroadcast ;

	SetProc( VSdrwBeamAxis ); Begin

	__DBGpr_obj( "Beam to draw", *(inp->elmId) ) ;

	wfAxis.objid = prjCv.objid = ofAxis.objid = NULL_OBJID ;

	/*
	 * Allocate memory for output curves.
	 */
	outp->count = 0 ;
	if( !( outp->list = _MALLOC( 1, struct GRid ) ) ) vs$mem_fail() ;
	VSsetGRids( inp->drwInfo.drwEnv->_MD_OS, 1, outp->list ) ;

	/*
	 * Construct construction list for wireframe elements.
	 */
	vs$fill_cnst_list( Msg		= msg,
			   Env_info	= inp->drwInfo.drwEnv,
			   Level	= xData->overrides.elmLevel,
			   Display	= &xData->overrides.elmDisplay,
			   Cnst_list	= cst ) ;

	/*
	 * Get axis of beam.
	 */
	sts = om$send( msg	= message VSbeam.VSgetSupportAxis(
						msg, inp->elmEnv, &bmAxis ),
		       senderid = inp->elmId->objid,
		       targetid = inp->elmId->objid,
		       targetos = inp->elmId->osnum ) ;
	__CheckRC( sts, *msg, "VSbeam.VSgetSupportAxis", wrapup ) ;

	__DBGpr_obj( "Axis of beam", bmAxis._grid ) ;

	axisEnv.md_id = bmAxis.mod_env.md_id ;
	VSmulmx( bmAxis._matrix, inp->elmEnv->_MATRIX, axisEnv._MATRIX,
		 &axisEnv._MATRIX_TYPE ) ;

	/*
	 * Copy axis.
	 */
	saveBroadcast = ASbroadcast_in_progress ;
	ASbroadcast_in_progress = TRUE ;

	sts = vs$grCopy( msg	= msg,
			 frEnv	= &axisEnv,
			 frObj	= &bmAxis._grid,
			 toEnv	= cst.env_info,
			 toObj	= &wfAxis ) ;
	__CheckRC( sts, *msg, "vs$grCopy", wrapup ) ;

	ASbroadcast_in_progress = saveBroadcast ;

        __DBGpr_str( "Option String", option );

	/*
	 * Translate axis to cardinal point of beam.
	 */
	sts = VSdrwGetCardinalPoint( msg,
				     inp->elmId,
				     inp->elmEnv,
				     0.5,
				     cardPnt ) ;
	__CheckRC( sts, *msg, "VSdrwGetCardinalPoint", wrapup ) ;

	__DBGpr_vec( "Cardinal point", cardPnt ) ;

	sts = VSptatpr( msg,
			cst.env_info,
			wfAxis.objid,
			0.5,
			midPnt ) ;

	__CheckRC( sts, *msg, "VSptatpr", wrapup ) ;

	__DBGpr_vec( "Middle point of axis", midPnt ) ;

	BSmkvec( msg, transVec, midPnt, cardPnt ) ;

	__DBGpr_vec( "Translation vector", transVec ) ;

	/*
	 * Translate axis.
	 */
	MAidmx( msg, transMx ) ;
	VStranslatemx( transVec, transMx, transMx ) ;
	MAtypemx( msg, transMx, &transMxType ) ;

	sts = om$send( msg	= message GRgraphics.GRxform( msg,
							      cst.env_info,
							      &transMxType,
							      transMx,
							      &wfAxis.objid ),
		       senderid = wfAxis.objid,
		       targetid = wfAxis.objid,
		       targetos = wfAxis.osnum ) ;

	__CheckRC( sts, *msg, "GRgraphics.GRxform", wrapup ) ;

        if( !strcmp( option, "bottom" ) )
        {
           struct GRobj_env     beamOE;

           beamOE.obj_id  = *(inp->elmId);
           beamOE.mod_env = *(inp->elmEnv);

           sts = VSdrwGetTrimmedAxis( msg, &beamOE, VS_K_nmFlgInfE,
                                      &wfAxis, cst.env_info ) ;
        }

	/*
	 * Project translated axis onto drawing plane.
	 */
	sts = EFproject_any_curve_on_planen(	msg,
						&cst,
						&wfAxis,
						cst.env_info,
						inp->drwInfo.drwPlane,
						inp->drwInfo.viewVector,
						&prjCv,
						&pjClassid ) ;

	__CheckRC( sts, *msg, "EFproject_any_curve_on_planen", wrapup );

	/*
	 * Offset projected axis of input offset distance if any.
	 */
	if( xData->overrides.dpAttr.offset != 0. ) {
		__DBGpr_dbl( "Offset distance", xData->overrides.dpAttr.offset);

		sts = vs$offsetCurve( msg	= msg,
				      cvEnv	= cst.env_info,
				      cvId	= &prjCv,
				      offset	= xData->overrides.dpAttr.offset,
				      normal	= inp->drwInfo.drwPlane->normal,
				      cst	= &cst,
				      offCvId	= &ofAxis ) ;

		__CheckRC( sts, *msg, "vs$offsetCurve", wrapup ) ;

		vs$bulk_delete( grids  = &prjCv,
				theEnv = cst.env_info ) ;

		(outp->list)[0] = ofAxis ;
	} else	(outp->list)[0] = prjCv  ;

	__DBGpr_obj( "Axis", (outp->list)[0] ) ;

	outp->count = 1 ;

	*msg = MSSUCC ;
	sts  = OM_S_SUCCESS ;

	wrapup :
		if( !( sts & 1 & *msg ) ) {
			vs$bulk_delete( grids	= &prjCv,
					theEnv	= cst.env_info ) ;

			vs$bulk_delete( grids	= &ofAxis,
					theEnv	= cst.env_info ) ;

			_FREE( outp->list ) ;
			outp->list  = NULL ;
			outp->count = 0 ;
		}

		vs$bulk_delete( grids	= &wfAxis,
				theEnv	= cst.env_info ) ;

		End
		return sts ;

} /* VSdrwCstBeamAxis */
/*----------------------------------------------------------------------------*/

end implementation VSbeam ;
