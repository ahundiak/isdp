/*
	I/STRUCT
*/
class implementation VSvirtcmp ;

#include "nddef.h"
#include "asmacros.h"
#include "EMSmsgdef.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsobjgarbage.h"

extern OMuword	OPP_ASsource_class_id,
		OPP_ASsourcein_class_id,
		OPP_NDnode_class_id,
		OPP_EMAplane_class_id,
		OPP_EMAsubbs_class_id,
		OPP_EMAproject_class_id,
		OPP_EMAcone_class_id,
		OPP_EMAcylindr_class_id,
		OPP_EMAelpcone_class_id,
		OPP_EMAelpcyl_class_id,
		OPP_EMAelpsoid_class_id,
		OPP_EMAgenbs_class_id,
		OPP_EMApcone_class_id,
		OPP_EMApcylindr_class_id,
		OPP_EMApsphere_class_id,
		OPP_EMAptorus_class_id,
		OPP_EMArevol_class_id,
		OPP_EMAsphere_class_id,
		OPP_EMAtorus_class_id,
		OPP_EMSplane_class_id,
		OPP_EMSsubbs_class_id,
		OPP_EMSproject_class_id,
		OPP_EMScone_class_id,
		OPP_EMScylindr_class_id,
		OPP_EMSelpcone_class_id,
		OPP_EMSelpcyl_class_id,
		OPP_EMSelpsoid_class_id,
		OPP_EMSgenbs_class_id,
		OPP_EMSpcone_class_id,
		OPP_EMSpcylindr_class_id,
		OPP_EMSpsphere_class_id,
		OPP_EMSptorus_class_id,
		OPP_EMSrevol_class_id,
		OPP_EMSsphere_class_id,
		OPP_EMStorus_class_id ;
/*----------------------------------------------------------------------------*/
long VS_EMA_to_EMS( EMA_object )

struct GRid	*EMA_object ; {

	long		sts ;
	char		EMSclass[OM_K_MAXCLASS_LEN] ;
	OMuword		EMAclassid,
			EMSclassid ;

	sts = om$get_classid(	objid		= EMA_object->objid,
				osnum		= EMA_object->osnum,
				p_classid	= &EMAclassid ) ;

	if( !( sts & 1 ) ) goto wrapup ;

		if( EMAclassid == OPP_EMAplane_class_id )
			EMSclassid = OPP_EMSplane_class_id ;

	else	if( EMAclassid == OPP_EMAproject_class_id )
			EMSclassid = OPP_EMSproject_class_id ;

	else	if( EMAclassid == OPP_EMAsubbs_class_id )
			EMSclassid = OPP_EMSsubbs_class_id ;

	else	if( EMAclassid == OPP_EMAcone_class_id )
			EMSclassid = OPP_EMScone_class_id ;

	else	if( EMAclassid == OPP_EMAcylindr_class_id )
			EMSclassid = OPP_EMScylindr_class_id ;

	else	if( EMAclassid == OPP_EMAelpcone_class_id )
			EMSclassid = OPP_EMSelpcone_class_id ;

	else	if( EMAclassid == OPP_EMAelpcyl_class_id )
			EMSclassid = OPP_EMSelpcyl_class_id ;

	else	if( EMAclassid == OPP_EMAelpsoid_class_id )
			EMSclassid = OPP_EMSelpsoid_class_id ;

	else	if( EMAclassid == OPP_EMAgenbs_class_id )
			EMSclassid = OPP_EMSgenbs_class_id ;

	else	if( EMAclassid == OPP_EMApcone_class_id )
			EMSclassid = OPP_EMSpcone_class_id ;

	else	if( EMAclassid == OPP_EMApcylindr_class_id )
			EMSclassid = OPP_EMSpcylindr_class_id ;

	else	if( EMAclassid == OPP_EMApsphere_class_id )
			EMSclassid = OPP_EMSpsphere_class_id ;

	else	if( EMAclassid == OPP_EMAptorus_class_id )
			EMSclassid = OPP_EMSptorus_class_id ;

	else	if( EMAclassid == OPP_EMArevol_class_id )
			EMSclassid = OPP_EMSrevol_class_id ;

	else	if( EMAclassid == OPP_EMAsphere_class_id )
			EMSclassid = OPP_EMSsphere_class_id ;

	else	if( EMAclassid == OPP_EMAtorus_class_id )
			EMSclassid = OPP_EMStorus_class_id ;

	else		EMSclassid = OM_K_NOTUSING_CLASSID ;

	if( EMSclassid != OM_K_NOTUSING_CLASSID ) {
		om$get_classname(	classid		= EMSclassid,
					classname	= EMSclass ) ;

		sts = om$change_class(	osnum		= EMA_object->osnum,
					objid		= EMA_object->objid,
					classname	= EMSclass ) ;
	}


	wrapup :
		return sts ;

} /* VS_EMA_to_EMS */
/*----------------------------------------------------------------------------*/
long VSmakeVirtualComponent(	msg,
				modEnv,
				virtualOwner,
				grObj,
				path,
				virtualCmp )
/*
 * Makes a virtual component of `grObj', associated with `virtualOwner'.
 * `modEnv' is the module environment of `grObj'.
 */

long		*msg ;
struct GRmd_env	*modEnv ;
GRname		path ;
struct GRid	*virtualOwner,
		*grObj,
		*virtualCmp ; {

	long		sts ;
	char		*newClass ;

	/*
	 * KLUDGE ALERT !!!!!
	 * If incomming object is an EMAsomething, then as$make_source will
	 * merely return this EMAsomething although it has been moved to root,
	 * and we won't get an ASsource which we badly need for what we're
	 * doing here. The following function will perform a change-class
	 * (yuck!) to turn our EMAsomething into an EMSsomething which is
	 * not subclass of NDnode.
	 */
	sts = VS_EMA_to_EMS( grObj ) ;
	__CheckRC( sts, 1, "VS_EMA_to_EMS", wrapup ) ;

	*msg = MSFAIL ;
	sts = as$make_source(	go_grid	= *grObj,
				mod_env	= modEnv,
				as_grid	= virtualCmp ) ;
	__CheckRC( sts, 1, "ASmake_source_from_env", wrapup ) ;

	if( vs$is_ancestry_valid(	object	= virtualCmp,
					classid	= OPP_ASsource_class_id ) ) {
		newClass = "VSvirtcmp" ;
	} else if( vs$is_ancestry_valid(object	= virtualCmp,
					classid	= OPP_ASsourcein_class_id ) ) {
		newClass = "VSvirtcmpref" ;
	} else {
		sts = OM_W_ABORT ; *msg = MSFAIL ; goto wrapup ;
	}

	*msg = EMS_E_OMerror ;
	sts = om$change_class(	osnum		= virtualCmp->osnum,
				objid		= virtualCmp->objid,
				classname	= newClass ) ;
	__CheckRC( sts, 1, "om$change_class", wrapup ) ;

	/*
	 * Now tell virtual component which is its virtual owner.
	 */
	sts = om$send(	msg	= message VSvirtcmp.VSputVirtualOwner(
						msg, virtualOwner, path ),
			senderid= virtualCmp->objid,
			targetid= virtualCmp->objid,
			targetos= virtualCmp->osnum ) ;
	__CheckRC( sts, *msg, "VSvirtcmp.VSputVirtualOwner", wrapup ) ;

	/*
	 * We want this guy never to stay around !
	 */
	sts = om$send(	msg	= message NDnode.NDchg_state(
						ND_DEL_NO_CH | ND_WAIT_DEL,
						ND_DEL_NO_CH | ND_WAIT_DEL ),
			senderid= virtualCmp->objid,
			targetid= virtualCmp->objid,
			targetos= virtualCmp->osnum ) ;

	VSrecordTmpObj( virtualCmp, modEnv ) ;

	wrapup :
		return sts ;

} /* VSmakeVirtualComponent */
/*----------------------------------------------------------------------------*/

end implementation VSvirtcmp ;
