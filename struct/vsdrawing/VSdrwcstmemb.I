/*
	I/STRUCT
*/
class implementation VSbeam ;

#include <stdlib.h>
#include "OMmacros.h"
#include "EMSmsgdef.h"
#include "vsdrw.h"
#include "vsvedef.h"
#include "vsdatamacros.h"
#include "vsgeommacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsdrwproto.h"
#include "vsfndslsinmc.h"
#include "vsvecmxproto.h"
#include "vsvirtualinf.h"
#include "vsvisedproto.h"

extern OMuword	OPP_EMSsolid_class_id ;

extern void	VSsetGRids() ;

#define FOOT_UNKNOWN	0
#define FOOT_CURVE	1
#define FOOT_SURFACE	2
#define FOOT_SOLID	3

/*----------------------------------------------------------------------------*/
static long VSdrwFindSolidsSurfsToExtractMember( msg, memberId, memberEnv,
						 viewVector, elmList, elmEnv,
						 elmCount, ssList, ssCount )

long			*msg ;
struct GRid		*memberId ;
struct GRmd_env 	*memberEnv ;
double			*viewVector ;
struct GRid		*elmList ;
struct GRmd_env 	*elmEnv ;
int			elmCount ;
struct GRobj_env	**ssList ;
int			*ssCount ; {

	/*
	 * Given a member ( memberId, memberEnv ) to extract, the view vector
	 * ( viewVector ) of extraction and the list of located elements
	 * ( elmList, elmEnv, elmCount ), this function returns the
	 * solids / surfaces ( ssList, ssCount ) near to the menber which
	 * to be used for extracting member.
	 *
	 * Note :
	 * ------
	 *	'*ssList' is allocated and hence must be freed by the caller
	 *	with 'free( *ssList )'.
	 */

	long			sts ;	/* OM completion code.		      */
	struct GRid		*list,	/* List of located elements to get    */
					/* its solids/surfaces feet.	      */
				virId ; /* Virtual element of located elm.    */
	struct GRmd_env 	virEnv ;/* Virtual env. 		      */
	int			i,	/* Loop index.			      */
				count,	/* Size of the above list.	      */
				relShip;/* Relation ship between two ranges.  */
	GRrange 		memRng, /* Range of member.		      */
				virRng ;/* Range of virtual element.	      */
	short			world ; /* Compute range in world coordinate. */

	list  = NULL ;
	count = 0 ;

	*ssList  = NULL ;
	*ssCount = 0 ;

	/*
	 * Allocate memory.
	 */
	if( !( list = _MALLOC( elmCount, struct GRid ) ) ) vs$mem_fail() ;

	/*
	 * Get range of member to extract.
	 */
	world = TRUE ;
	sts = om$send( msg	= message GRgraphics.GRgetrang(
						       msg,
						       &memberEnv->_MATRIX_TYPE,
						       memberEnv->_MATRIX,
						       &world,
						       memRng ),
		       senderid = memberId->objid,
		       targetid = memberId->objid,
		       targetos = memberId->osnum ) ;

	__CheckRC( sts, *msg, "GRgraphics.GRgetrang", wrapup ) ;

	__DBGpr_vec( "Range of member min", memRng	) ;
	__DBGpr_vec( "Range of member max", memRng +3	) ;

	/*
	 * For each located elements, if range of virtual parent of located
	 * element is in front or intersect range of member, keep located
	 * element. Otherwise reject it.
	 */
	for( i=0; i<elmCount; i++ ) {

		sts = VSgetVirtualInfo( msg,
					elmList +i,
					&virEnv,
					&virId ) ;

		if( !( sts & 1 & *msg ) ) continue ;

		sts = om$send( msg	= message GRgraphics.GRgetrang(
							   msg,
							   &virEnv._MATRIX_TYPE,
							   virEnv._MATRIX,
							   &world,
							   virRng ),
			       senderid = virId.objid,
			       targetid = virId.objid,
			       targetos = virId.osnum ) ;

		if( !( sts & 1 & *msg ) ) continue ;

		sts = VSveRangeRangeRelationShip( msg,
						  virRng,
						  memRng,
						  viewVector,
						  &relShip ) ;

		if( !( sts & 1 & *msg ) 		||
		    relShip == VS_K_0_IN_FRONT_OF_1	||
		    relShip == VS_K_0_AT_THE_BACK_OF_1	) continue ;

		list[count++] = elmList[i] ;
	}

	__DBGpr_objlist( "List of elements to get solid / surface",
			 count, list ) ;

	/*
	 * Get solids / surfaces of located elements on found list.
	 */
	if( count ) {
		sts =  VSfindSolidsSurfacesInMacroSet( msg,
						       list,
						       elmEnv,
						       count,
						       ssList,
						       ssCount ) ;

		__CheckRC( sts, *msg, "VSfindSolidsSurfacesInMacroSet",
			   wrapup ) ;
	}

	sts  = OM_S_SUCCESS ;
	*msg = MSSUCC ;

	wrapup :
		_FREE( list ) ;

		return sts ;

} /* VSdrwFindSolidsSurfsToExtractMember */
/*----------------------------------------------------------------------------*/
static long VSdrwGetFootGraphicType( msg, footId, footEnv, footType )

long		*msg ;
struct GRid	*footId ;
struct GRmd_env *footEnv ;
int		*footType ; {

	/*
	 * Given a foot ( footId, footEnv ), this function returns the graphic
	 * type of the foot ( curve, surface or solid ) in 'footType'.
	 *
	 * Values of 'footType' :
	 * ======================
	 *
	 *	- Foot is a curve	: FOOT_CURVE
	 *	- Foot is a surface	: FOOT_SURFACE
	 *	- Foot is a solid	: FOOT_SOLID
	 *	- Unknown graphic type	: FOOT_UNKNOWN
	 */

	long		sts ;		/* OM completion code.		      */
	struct GRprops	properties ;	/* Geometric properties of foot.      */

	*footType = FOOT_UNKNOWN ;

	/*
	 * Get geometric properties of foot.
	 */
	sts = om$send( msg	= message GRvg.GRgeomprops(
							 msg,
							 &footEnv->_MATRIX_TYPE,
							 footEnv->_MATRIX,
							 &properties ),
		       senderid = footId->objid,
		       targetid = footId->objid,
		       targetos = footId->osnum ) ;

	__CheckRC( sts, *msg, "GRvg.GRgeomprops", wrapup ) ;

	/*
	 * See graphic type of foot.
	 */
	if( properties.type == GRCURVE ) *footType = FOOT_CURVE ;
	else if( properties.type == GRSURFACE )
		if( vs$is_ancestry_valid( object  = footId,
					  classid = OPP_EMSsolid_class_id ) )
		     *footType = FOOT_SOLID ;
		else *footType = FOOT_SURFACE ;

	sts  = OM_S_SUCCESS ;
	*msg = MSSUCC ;

	wrapup :
		return sts ;

} /* VSdrwGetFootGraphicType */
/*----------------------------------------------------------------------------*/
long VSdrwCstConstMember( msg, inp, xData, member, outp )

long			*msg ;
VSdrwInputData		*inp ;
VSdrwExecData		*xData ;
const char		*member ;
VSdrwGraphicGroup	*outp ; {

	long			sts ;	    /* OM completion code.	      */
	int			i,	    /* Loop index.		      */
				ssCount,    /* Count of solids / surfaces     */
					    /* of located elements.	      */
				count,	    /* Count of output. 	      */
				footType ;  /* Graphic type of foot.	      */
	struct GRid		footId,     /* Id of foot.		      */
				*list ;     /* List of output.		      */
	struct GRobj_env	*ssList ;   /* List of solids / surfaces      */
					    /* of located elements.	      */
	struct GRmd_env 	footEnv ;   /* Mod. env. of foot.	      */
	struct GRvg_construct	cst ;	    /* Construction list for	      */
					    /* projected wireframes.	      */
	struct IGRdisplay	dspVis,     /* Display for visible wireframes.*/
				dspHid ;    /* Display for hidden wireframes. */
	OMuword 		footClassid;/* Classid of output ( used in    */
					    /* case of foot is a curve ).     */

	SetProc( VSdrwCstConstMember ); Begin

	__DBGpr_obj( "Construction to draw", *(inp->elmId) ) ;

	count = 0 ;
	list  = NULL ;

	ssCount     = 0 ;
	ssList	    = NULL ;

	sts  = OM_S_SUCCESS ;
	*msg = MSSUCC ;

	if( !*member ) {
		if( xData->verbose )
		       VSdrwPrintf( "!!! Member not specified for const '%s'\n",
					 inp->constDefName ) ;
		*msg = MSFAIL ;
		goto wrapup ;
	}

	/*
	 * Get foot to project.
	 */
	sts = om$send(	msg	= message NDmacro.ACreturn_foot(
							  msg,
							  (char *) member,
							  &footId,
							  &footEnv._MATRIX_TYPE,
							  footEnv._MATRIX ),
		  	senderid= inp->elmId->objid,
			targetid= inp->elmId->objid,
			targetos= inp->elmId->osnum ) ;

	if( !( sts & 1 & *msg ) ) {
		if( xData->verbose )
			VSdrwPrintf( "!!! Cannot find '%s' in const '%s'\n",
					  member, inp->constDefName ) ;
		goto wrapup ;
	}

	VSmulmx( inp->elmEnv->_MATRIX, footEnv._MATRIX, footEnv._MATRIX,
		 &footEnv._MATRIX_TYPE ) ;

	footEnv.md_id = inp->elmEnv->md_id ;

	/*
	 * Get solids / surfaces for processing hidden lines.
	 */
	__DBGpr_int( "Count of located elements", inp->toBeDrawn.elmCount ) ;
	__DBGpr_objlist( "Element", inp->toBeDrawn.elmCount,
				    inp->toBeDrawn.elmList ) ;

	if( inp->toBeDrawn.elmCount > 1 ) {
		sts = VSdrwFindSolidsSurfsToExtractMember(
							msg,
							&footId,
							&footEnv,
							inp->drwInfo.viewVector,
							inp->toBeDrawn.elmList,
							inp->elmEnv,
							inp->toBeDrawn.elmCount,
							&ssList,
							&ssCount ) ;

		__CheckRC( sts, *msg, "VSdrwFindSolidsSurfsToExtractMember",
			   wrapup ) ;

		/*
		 * The construction to be drawn is also on the list of located
		 * elements. So, swap the last solid / surface with the foot
		 * to project.
		 */
		for( i=0; i<ssCount; i++ ) {
			if( IF_EQ_GRID( ssList[i]._grid, footId ) ) {
				struct GRobj_env	tmpObj ;

				tmpObj		  = ssList[ssCount-1] ;
				ssList[ssCount-1] = ssList[i] ;
				ssList[i]	  = tmpObj ;

				ssCount-- ;

				break ;
			}
		}
	}

	__DBGpr_int( "Count of located solids / surfaces", ssCount ) ;

#ifdef vsDEBUG
	for( i=0; i<ssCount; i++ )
		__DBGpr_obj( "Solid / Surface", ssList[i]._grid ) ;
#endif

	/*
	 * Fill construction list for projected wireframes.
	 */
	vs$fill_cnst_list( Msg		= msg,
			   Env_info	= inp->drwInfo.drwEnv,
			   Level	= xData->overrides.elmLevel,
			   Display	= &xData->overrides.elmDisplay,
			   Cnst_list	= cst ) ;

	dspVis = dspHid = xData->overrides.elmDisplay ;
	dspHid.style = xData->overrides.dpAttr.hiddenStyle ;

	/*
	 * Project foot with hidden lines.
	 */
	sts = VSdrwGetFootGraphicType( msg,
				       &footId,
				       &footEnv,
				       &footType ) ;

	__CheckRC( sts, *msg, "VSdrwGetFootGraphicType", wrapup ) ;

	switch( footType ) {
	case FOOT_SOLID 	:
		__DBGpr_com( "Foot is a SOLID" ) ;

		sts = VSdrwProjectSolidWithHiddenLines( msg,
							&footId,
							&footEnv,
							ssCount,
							ssList,
							inp->drwInfo.viewVector,
							inp->drwInfo.drwPlane,
							&dspHid,
							&dspVis,
							&cst,
							&count,
							&list ) ;

		__CheckRC( sts, *msg, "VSdrwProjectSolidWithHiddenLines",
			   wrapup ) ;
		break ;

	case FOOT_SURFACE	:
		__DBGpr_com( "Foot is a SURFACE" ) ;

		sts = VSdrwProjectSurfaceWithHiddenLines(
							msg,
							&footId,
							&footEnv,
							ssCount,
							ssList,
							inp->drwInfo.viewVector,
							inp->drwInfo.drwPlane,
							&dspHid,
							&dspVis,
							&cst,
							&count,
							&list ) ;

		__CheckRC( sts, *msg, "VSdrwProjectSurfaceWithHiddenLines",
			   wrapup ) ;
		break ;

	case FOOT_CURVE 	:
		__DBGpr_com( "Foot is a CURVE" ) ;

		if( !( list = _MALLOC( 1, struct GRid ) ) ) vs$mem_fail() ;

		sts = VSdrwProjectWireframeWithHiddenParts(
							msg,
							&footId,
							&footEnv,
							ssCount,
							ssList,
							&cst,
							&dspVis,
							&dspHid,
							inp->drwInfo.drwPlane,
							inp->drwInfo.viewVector,
							list,
							&footClassid ) ;

		__CheckRC( sts, *msg, "VSdrwProjectWireframeWithHiddenParts",
			   wrapup ) ;

		count = 1 ;
		break ;

	default 		:
		if( xData->verbose )
			VSdrwPrintf( "!!! Cannot extract member '%s'\n",
					  inp->constDefName ) ;
	}

	sts  = OM_S_SUCCESS ;
	*msg = MSSUCC ;

	wrapup :
		if( sts & 1 & *msg ) {
			outp->list  = list ;
			outp->count = count ;
		} else {
			_FREE( list   ) ;
		}
		_FREE( ssList ) ;

		End
		return sts ;

} /* VSdrwCstConstMember */
/*----------------------------------------------------------------------------*/

end implementation VSbeam ;
