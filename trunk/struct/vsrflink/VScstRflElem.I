/*
	I/STRUCT
*/ 
class implementation VSrflPlate ;

#include "EMSmsgdef.h"
#include "vsmiscmacros.h"
#include "vsdatamacros.h"
#include "vsdbgmacros.h"

extern OMuword	OPP_VSrflPlate_class_id,
		OPP_VSrfvPlate_class_id,
		OPP_VSrflBeam_class_id,
		OPP_VSrfsBeam_class_id ;
/*----------------------------------------------------------------------------*/
long VScstRflStructElem( msg, refPlateId, refPlateEnv, rflPlateEnv, rflPlateId )

long		*msg ;
struct GRid	*refPlateId,
		*rflPlateId ;
struct GRmd_env	*refPlateEnv,
		*rflPlateEnv ; {

	long			sts ;
	struct GRvg_construct	cst ;
	struct VScnst_list	args ;
	struct GRobj_env	plInRef ;
	unsigned long		type,
				attr ;
	OMuword			clid ;

	plInRef._grid	= *refPlateId ;
	plInRef.mod_env	= *refPlateEnv ;

	vs$fill_cnst_list(	Msg		= msg,
				Env_info	= rflPlateEnv,
				Class_attr	= &args,
				Cnst_list	= cst ) ;

	args.parent_count	= 1 ;
	args.parent_list	= &plInRef ;
	args.representation	= 0 ;
	args.feature_att	= NULL ;

	sts = om$send(	msg	= message VSpart.VSgetUserEditableAttr(
							msg, &type, &attr ),
			senderid= refPlateId->objid,
			targetid= refPlateId->objid,
			targetos= refPlateId->osnum ) ;
	__CheckRC( sts, *msg, "VSfeature.VSgetResultType", wrapup ) ;

	switch( type ) {
		case VS_m_SRC_PLATE : clid = OPP_VSrflPlate_class_id ; break ;
		case VS_m_VAR_PLATE : clid = OPP_VSrfvPlate_class_id ; break ;
		case VS_m_SRC_BEAM  : clid = OPP_VSrflBeam_class_id  ; break ;
		case VS_m_STF_BEAM  : clid = OPP_VSrfsBeam_class_id  ; break ;
		default		    : vs$inv_arg() ;
	}

	rflPlateId->osnum = rflPlateEnv->_MD_OS ;
	sts = om$construct(
			classid	= clid,
			osnum	= rflPlateId->osnum,
			p_objid	= &rflPlateId->objid,
			msg	= message GRgraphics.GRconstruct( &cst ) ) ;

	if( !( sts & 1 & *msg ) ) rflPlateId->objid = NULL_OBJID ;

	wrapup :
	return sts ;

} /* VScstRflStructElem */
/*----------------------------------------------------------------------------*/

end implementation VSrflPlate ;

