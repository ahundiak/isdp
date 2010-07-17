/*
        I/STRUCT
*/
class implementation VSfeature ;

#include "vsglobalmsg.h"
#include "vsdbgmacros.h"

#define ANCESTRY( sub, super )\
	( om$is_ancestry_valid( superclassid = OPP_##super##_class_id,\
				subclassid   = (sub) )\
		== OM_S_SUCCESS )
#define DCL_CLASSID( Class ) extern OMuword OPP_##Class##_class_id
/*----------------------------------------------------------------------------*/
static int VSgetFeatureType( element ) struct GRid *element ; {

	long		sts,
			msg ;
	unsigned long	type ;
	int		ftype ;

	sts = om$send(	msg	= message VSfeature.VSgetResultType(
								&msg, &type ),
			senderid= NULL_OBJID,
			targetid= element->objid,
			targetos= element->osnum ) ;
	if( sts & 1 & msg ) {
		     if( type & VS_m_BEAM ) 	ftype = VS_K_BEAMtype  ;
		else if( type & VS_m_PLATE )	ftype = VS_K_PLATEtype ;
		else if( type & VS_m_JOINT )	ftype = VS_K_JOINTtype ;
		else				ftype = VS_K_UNKNOWNtype ;
	} else					ftype = VS_K_UNKNOWNtype ;

	return ftype ;

} /* VSgetFeatureType */
/*----------------------------------------------------------------------------*/
static int VSgetObjectType( object ) struct GRid *object ; {

	int	type ;
	OMuword	clid ;
	DCL_CLASSID( GRcurve		) ;
	DCL_CLASSID( GRpoint		) ;
	DCL_CLASSID( GRlinear		) ;
	DCL_CLASSID( EMSsolid		) ;
	DCL_CLASSID( EMSplane		) ;
	DCL_CLASSID( EMSsurface		) ;
	DCL_CLASSID( VSfeature		) ;
	DCL_CLASSID( expression		) ;
	DCL_CLASSID( ACrg_collect	) ;
	DCL_CLASSID( VSsharedData	) ;

	if( !( om$get_classid(	objid		= object->objid,
				osnum		= object->osnum,
				p_classid	= &clid ) & 1 ) ) {
		return VS_K_UNKNOWNtype ;
	}
	/*
	 * Test for points BEFORE curves.
	 */
	     if( ANCESTRY( clid, GRpoint	) ) type = VS_K_POINTtype ;
	else if( ANCESTRY( clid, GRlinear	) ) type = VS_K_LINEtype ;
	else if( ANCESTRY( clid, GRcurve	) ) type = VS_K_CURVEtype ;
	/*
	 * Test for solids BEFORE surfaces.
	 */
	else if( ANCESTRY( clid, EMSsolid	) ) type = VS_K_SOLIDtype ;
	else if( ANCESTRY( clid, EMSplane	) ) type = VS_K_PLANEtype ;
	else if( ANCESTRY( clid, EMSsurface	) ) type = VS_K_SURFACEtype ;
	else if( ANCESTRY( clid, VSfeature	) ) type = VSgetFeatureType( object ) ;
	else if( ANCESTRY( clid, expression	) ) type = VS_K_EXPRtype ;
	else if( ANCESTRY( clid, ACrg_collect	) ) type = VS_K_COLLECTIONtype ;
	else if( ANCESTRY( clid, VSsharedData	) ) type = VS_K_COLLECTIONtype ;
	else					    type = VS_K_UNKNOWNtype ;

	return type ;

} /* VSgetObjectType */
/*----------------------------------------------------------------------------*/
int VSgetOperatorType( header, graphic )

struct GRid	*header,
		*graphic ; {

	/*
	 * This is a most un-object function since it tests class ids to
	 * know an object type. BUT: ASsources and ACpretend have no get-type
	 * messages of their own (since they pretend), EMS has now way of tel-
	 * ling a solid from a surface, the others have get-type messages, but
	 * one does not know which to send anyway because there is no generic
	 * one for all.
	 */
 
	int	type ;
	OMuword	classid ;
	DCL_CLASSID( ASsource	) ;
	DCL_CLASSID( ACpretend	) ;

	if( !( om$get_classid(	objid		= header->objid,
				osnum		= header->osnum,
				p_classid	= &classid ) & 1 ) ) {
		type = VS_K_UNKNOWNtype ;

	} else if(    ANCESTRY( classid, ASsource  )
		  || ANCESTRY( classid, ACpretend ) ) {

		type = VSgetObjectType( graphic ) ;
	} else {
		type = VSgetObjectType( header ) ;
	}
	return type ;

} /* VSgetOperatorType */
/*----------------------------------------------------------------------------*/
long VSgetOperatorTypeMsgKey( optype ) int optype ; {

	long k ;

	switch( optype ) {
		case VS_K_PLATEtype	: k = VS_gI_Plate	; break ;
		case VS_K_BEAMtype    	: k = VS_gI_Beam   	; break ;
		case VS_K_JOINTtype    	: k = VS_gI_Joint   	; break ;
		case VS_K_POINTtype	: k = VS_gI_Point	; break ;
		case VS_K_LINEtype	: k = VS_gI_LineSegment	; break ;
		case VS_K_CURVEtype	: k = VS_gI_Curve	; break ;
		case VS_K_PLANEtype 	: k = VS_gI_Surface	; break ;
		case VS_K_SURFACEtype 	: k = VS_gI_Surface	; break ;
		case VS_K_SOLIDtype	: k = VS_gI_Solid	; break ;
		case VS_K_EXPRtype	: k = VS_gI_Expression	; break ;
		case VS_K_COLLECTIONtype: k = VS_gI_Collection	; break ;
		case VS_K_UNKNOWNtype	:
		default		  	: k = VS_gI_UnkOptr	; break ;

	}
	return k ;

} /* VSgetOperatorTypeMsgKey */
/*----------------------------------------------------------------------------*/
long VSgetOperandTypeMsgKey( optype ) int optype ; {

	long k ;

	switch( optype ) {
		case VS_m_SRC_PLATE	: k = VS_gI_SrcPlate	; break ;
		case VS_m_IMB_PLATE	: k = VS_gI_ImbPlate	; break ;
		case VS_m_MRK_PLATE	: k = VS_gI_MrkPlate	; break ;
		case VS_m_SPL_PLATE	: k = VS_gI_SplPlate	; break ;
		case VS_m_SUB_PLATE	: k = VS_gI_SubPlate	; break ;
		case VS_m_BOO_PLATE	: k = VS_gI_BooPlate	; break ;
		case VS_m_GAP_PLATE	: k = VS_gI_GapPlate	; break ;
		case VS_m_VAR_PLATE	: k = VS_gI_VarPlate	; break ;
		case VS_m_STF_BEAM	: k = VS_gI_Stiffener	; break ;
		case VS_m_SRC_BEAM	: k = VS_gI_SrcBeam	; break ;
		case VS_m_BOO_BEAM	: k = VS_gI_BooBeam	; break ;
		case VS_m_ORN_BEAM	: k = VS_gI_OrnBeam	; break ;
		case VS_m_XTR_BEAM	: k = VS_gI_XtrBeam	; break ;
		case VS_m_SPL_BEAM	: k = VS_gI_SplBeam	; break ;
		case VS_m_SUB_BEAM	: k = VS_gI_SubBeam	; break ;
		case VS_m_SRC_JOINT	:
		case VS_m_MOD_JOINT	:
		case VS_m_DIV_JOINT	:
		case VS_m_SUB_JOINT	: k = VS_gI_Joint	; break ;
		default			: k = VS_gI_UnkOptn	; break ;
	}
	return k ;

} /* VSgetOperandTypeMsgKey */
/*----------------------------------------------------------------------------*/

end implementation VSfeature ;

