/* $Id: VScstgrfred.I,v 1.1.1.1 2001/01/04 21:10:43 cvs Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:	struct/vsjoint/VScstgrfred.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VScstgrfred.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:10:43  cvs
 *	Initial import to CVS
 *	
# Revision 1.2  1999/01/05  09:28:14  pinnacle
# Replaced: vsjoint/VScstgrfred.I for:  by manoj for struct
#
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.2  1997/11/14  12:57:22  pinnacle
# Replaced: vsjoint/VScstgrfred.I for:  by svkadamb for struct
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *			suresh		modification 
*      01/04/99	manoj		modification fot TR #179900008 
 ***************************************************************************/
class implementation EMSedge ;

#include "OMmacros.h"
#include "msdef.h"
#include "bserr.h"
#include "comiscmac.h"
#include "vsmiscmacros.h"
#include "vsgeommacros.h"
#include "vsdatamacros.h"
//#define   vsDEBUG
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "bsalloccv.h"
#include "bsfreecv.h"
#include "bspartofcv.h"

extern struct GRid	NULL_GRID ;
extern OMuword	OPP_GR3dlineseg_class_id,
		OPP_GRbcsubbc_class_id ;
/*----------------------------------------------------------------------------*/
long VScstGraphicsFromEdge( msg, edgeId, edgeGeom, cst, graphics )

long			*msg ;
struct GRid		*edgeId ;
struct IGRbsp_curve	*edgeGeom ;
struct GRvg_construct	*cst ;
struct GRid		*graphics ; {

	long			sts ;
	unsigned char		edCvType ;
	OMuword			edCvClassid ;
	struct GRvg_construct	locCst ;

	SetProc( VScstGraphicsFromEdge ); Begin 

	graphics->objid = NULL_OBJID ;
	if( edgeId ) {
		if( IF_EQ_GRID( *edgeId , NULL_GRID ) )  goto next_step ;
		sts = om$send(	msg	= message EMSedge.EMget_props_type(
							msg, NULL, &edCvType ),
				senderid= edgeId->objid,
				targetid= edgeId->objid,
				targetos= edgeId->osnum ) ;
		__CheckRC( sts, *msg, "EMget_props_type", wrapup ) ;

		sts = EFget_classid_for_an_edge_type( &edCvClassid, edCvType ) ;
		if( !sts ) { *msg = MSINARG ; sts = OM_E_INVARG ; goto wrapup ; }
	} else {
next_step :
		edCvClassid = vs$is_curve_linear(
						msg		= msg,
						curveGeom	= edgeGeom )
		     	? OPP_GR3dlineseg_class_id
		     	: OPP_GRbcsubbc_class_id ;
	}
	/** added to solve Tr#179900008  :Starts***/
	if (  edCvClassid  == OPP_GR3dlineseg_class_id && edgeGeom->num_poles > 2){ 
		edCvClassid =OPP_GRbcsubbc_class_id ; 
	}
	/** added to solve Tr#179900008  :Ends***/

	graphics->osnum = cst->env_info->_MD_OS ;

	sts = om$construct(	classid	= edCvClassid,
				osnum	= graphics->osnum,
				p_objid	= &graphics->objid ) ;
	if( !( sts & 1 ) ) vs$om_error( sts = sts ) ;

#ifdef vsDEBUG
	ShowObj( graphics ) ;
#endif

	vs$fill_cnst_list(	Msg		= msg,
				Env_info	= cst->env_info,
				Level		= cst->level,
				Display		= cst->display,
				Geometry	= edgeGeom,
				Cnst_list	= locCst ) ;

	sts = om$send(	msg	= message GRgraphics.GRconstruct( &locCst ),
			senderid= graphics->objid,
			targetid= graphics->objid,
			targetos= graphics->osnum ) ;
	__CheckRC( sts, *msg, "GRgraphics.GRconstruct", wrapup ) ;
#ifdef vsDEBUG
	ShowObj( graphics ) ;
#endif

	wrapup :
		if( !( sts & 1 & *msg ) ) {
			vs$bulk_delete(	grids	= graphics,
					theEnv	= locCst.env_info ) ;
		}
		End
		return sts ;

} /* VScstGraphicsFromEdge */
/*----------------------------------------------------------------------------*/
long VScstGraphicsFromEdgePortions( msg, edgeGeom, count, tStart, tEnd, cst,
					graphics )

long			*msg ;
struct IGRbsp_curve	*edgeGeom ;
int			count ;
double			*tStart,
			*tEnd ;
struct GRvg_construct	*cst ;
struct GRid		*graphics ; {

	long			rc,
				sts ;
	int			i ;
	struct GRvg_construct	locCst ;
	struct IGRbsp_curve	*partGeom = NULL ;

	if( !count ) vs$inv_arg() ;
	__DBGpr_int(" count " , count );
	for( i = 0 ; i < count ; i++ ) {
		BSalloccv(	edgeGeom->order,
				edgeGeom->num_poles + 2 * edgeGeom->order - 1,
				edgeGeom->rational,
				0,
				&partGeom,
				msg ) ;
		if( BSERROR( *msg ) ) vs$mem_fail() ;

		BSpartofcv(	msg,
				edgeGeom,
				tStart[i],
				0.5 * ( tStart[i] + tEnd[i] ),
				tEnd[i],
				partGeom ) ;
		if( BSERROR( *msg ) ) vs$failure() ;

		sts = VScstGraphicsFromEdge(	msg,
						(struct GRid *) NULL,
						partGeom,
						cst,
						graphics + i ) ;
		__CheckRC( sts, *msg, "VScstGraphicsFromEdge", wrapup ) ;
		__DBGpr_obj(" graphics edge " , graphics[i]);
		BSfreecv( &rc, partGeom ) ; partGeom = NULL ;
	}
	*msg= MSSUCC ;
	sts = OM_S_SUCCESS ;

	wrapup :
		if( partGeom ) BSfreecv( &rc, partGeom ) ; 
		if( !( sts & 1 & *msg ) ) {
			vs$bulk_delete(	grids	= graphics,
					count	= count,
					theEnv	= locCst.env_info ) ;
		}

		return sts ;

} /* VScstGraphicsFromEdgePortions */
/*----------------------------------------------------------------------------*/

end implementation EMSedge ;
