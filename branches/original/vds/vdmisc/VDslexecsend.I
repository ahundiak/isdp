/*
	I/VDS	Copy
*/
class implementation VDSroot ;

#include <stdio.h>
#include <string.h>
#include "acrepdef.h"
#include "EMSmsgdef.h"
#include "v_slc.h"
#include "v_miscmacros.h"
#include "v_dbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "maidmx.h"
#include "v_chgsymb.h"
#include "v_expvalue.h"
#include "v_strngproto.h"
#include "v_virtualinf.h"

from ACcpx_defn	import	ACgive_name ;
/*----------------------------------------------------------------------------*/
int VD_fillConst( msg, rs, constant )

long			*msg ;
const struct ret_struct	*rs ;
VD_execRes		*constant ; {


	*msg = MSSUCC ;
	switch( rs->type ) {
		case double_type :

			constant->type	= VD_double ;
			constant->_dval	= rs->var.root_pm_st.value ;
		break ;

		case text_type	:

		constant->type	= VD_string ;
			strcpy( constant->_sval, rs->var.text_st.text_string );
			break ;

		default	:
			*msg = MSINARG ; break ;
	}

	return *msg & 1 ;

} /* VD_fillConst */
/*----------------------------------------------------------------------------*/
int VD_genOutput( msg, inParms, val, outParms, res )

long			*msg ;
VD_execIN		*inParms ;
VD_execRes		*val ;
VD_execOUT		*outParms ;
VD_execRes		*res ; {

	long			sts = OM_S_SUCCESS ;
	OM_S_OBJID		copyId ;
	OMuword			copyOs ;
	struct GRobj_env	*object ;

	if( outParms->count >= outParms->size ) {
		*msg = MSINARG ;
		goto wrapup ;
	}

	if( val->type != VD_object ) {

		VD_cstExp( msg, inParms, val, outParms, res ) ;
		goto wrapup ;
	}
	
	object = &val->_oval ;

	/*
	 * Copy object, if message GRcopy is not understood then we
	 * probably have an expression.
	 */
	copyOs = inParms->cst->env_info->_MD_OS ;

	sts = om$send(	msg	= message GRgraphics.GRcopy(
						msg,
			/* From env	*/	&object->mod_env,
			/* To env	*/	inParms->cst->env_info,
						&copyId ),
			senderid= object->_objid,
			targetid= object->_objid,
			targetos= object->_osnum ) ;

	if( sts == OM_W_UNKNOWN_MSG ) {
		/*
		 * Does not understand GRcopy: must be an expression.
		 */
		struct ret_struct	rs ;
		VD_execRes		value ;
		
		sts = om$send(	msg	= message NDnode.NDgive_structure(
						msg, &rs, &object->mod_env ),
				senderid= object->_objid,
				targetid= object->_objid,
				targetos= object->_osnum ) ;
		__CheckRC( sts, *msg, "NDnode.NDgive_structure", wrapup ) ;

		if( VD_fillConst( msg, &rs, &value ) ) {
			VD_cstExp( msg, inParms, &value, outParms, res ) ;
		}

	} else {
		__CheckRC( sts, *msg, "GRgraphics.GRcopy", wrapup ) ;

		outParms->OUTPUT[outParms->count].objid = copyId ;
		outParms->OUTPUT[outParms->count].osnum = copyOs ;

		/*
		 * Make copied graphic have our symbology and properties.
		 */
		VD_chgSymbAndProps(	msg,
					&outParms->OUTPUT[outParms->count],
					inParms->cst->level,
					inParms->cst->display,
					inParms->cst->properties ) ;
		outParms->count++ ;
	}


	*msg = MSSUCC ;

	wrapup :
		if( !( sts & 1 ) ) if( *msg & 1 ) *msg = EMS_E_OMerror ;

		return *msg & 1 ;

} /* VD_genOutput */
/*----------------------------------------------------------------------------*/
int VD_evalCpxType( msg, inObj, objtype, res )

long			*msg ;
struct GRobj_env	*inObj ;
char			*objtype ;
VD_execRes		*res ; {

	long		sts ;
	struct GRid	macDef ;
	char		*name ;

	res->type = VD_int ;
	res->_ival= FALSE ;

	sts = om$send(	msg	= message ACcpx.find_macro( &macDef ),
			senderid= inObj->_objid,
			targetid= inObj->_objid,
			targetos= inObj->_osnum ) ;
	if( !( sts & 1 ) ) goto wrapup ;

	sts = om$send(	msg	= message ACcpx_defn.ACgive_name( &name ),
			senderid= inObj->_objid,
			targetid= macDef.objid,
			targetos= macDef.osnum ) ;
	if( !( sts & 1 ) ) goto wrapup ;

	res->_ival = VD_matchRE( objtype, name ) ;

	wrapup :
		*msg = MSSUCC ;

		return *msg & 1 ;

} /* VD_evalCpxType */
/*----------------------------------------------------------------------------*/
#ifdef	NOT_USED

int VD_evalObj( msg, inParms, objectAlias, res )

long		*msg ;
VD_execIN	*inParms ;
char		*objectAlias ;
VD_execRes	*res ; {

	int	i ;

	res->type		= VD_object ;
	res->_oval._objid	= NULL_OBJID ;
 
	/*
	 * Translate alias -> input number.
	 */
	if( ( i = vd_$searchAlias(	table	= inParms->aliases,
					alias	= objectAlias ) ) == -1 ) {
		*msg = MSINARG ;

	} else {
		VD_getVirtualInfo( msg, &inParms->INPUT[i],
				  &res->_oval.mod_env, &res->_oval._grid ) ;

	}

	return *msg & 1 ;

} /* VD_evalObj */

#endif

/*----------------------------------------------------------------------------*/
int VD_getObjVal( msg, object, res )

long			*msg ;
const struct GRobj_env	*object ;
VD_execRes		*res ; {

	long			sts ;
	struct ret_struct	rs ;

	sts = om$send(	msg	= message NDnode.NDgive_structure(
				msg, &rs, (struct GRmd_env*) &object->mod_env ),
			senderid= object->_objid,
			targetid= object->_objid,
			targetos= object->_osnum ) ;
	__CheckRC( sts, *msg, "NDnode.NDgive_structure", wrapup ) ;

	VD_fillConst( msg, &rs, res ) ;

	wrapup :
		return *msg & 1 ;

} /* VD_getObjVal */
/*----------------------------------------------------------------------------*/
int VD_evalPath( msg, object, ftName, res )

long		*msg ;
VD_execRes	*object,
		*ftName ;
VD_execRes	*res ; {

	long			sts ;

	res->type = VD_object ;

	if( object->type != VD_object || ftName->type != VD_string ) {
		*msg = MSINARG ; goto wrapup ;
	}

	sts = om$send(	msg	= message NDmacro.ACreturn_foot(
						msg,
						ftName->_sval,
						&res->_oval._grid,
						&res->_oval._matrix_type,
						res->_oval._matrix ),
			senderid= object->_oval._objid,
			targetid= object->_oval._objid,
			targetos= object->_oval._osnum ) ;
	*msg = *msg ? MSSUCC : MSFAIL ;
	__CheckRC( sts, *msg, "NDmacro.ACreturn_foot", wrapup ) ;

	res->_oval.mod_env.md_id = object->_oval.mod_env.md_id ;

	wrapup :

		return *msg & 1 ;

} /* VD_evalPath */
/*----------------------------------------------------------------------------*/
int VD_cstExp( msg, inParms, value, outParms, res )

long		*msg ;
VD_execIN	*inParms ;
VD_execRes	*value ;
VD_execOUT	*outParms ;
VD_execRes	*res ; {

	double		dval ;
	OMuword		expOs ;
	OM_S_OBJID	expId ;

	if( outParms->count >= outParms->size ) {
		*msg = MSINARG ;
		goto wrapup ;
	}

	expOs = inParms->cst->env_info->_MD_OS ;

	switch( value->type ) {
		case VD_int	: dval = value->_ival ; goto DOUBLE_EXP ;
		case VD_double	: dval = value->_dval ;
		DOUBLE_EXP	:
			*msg = VD_createExp( NULL, dval, expOs, &expId ) ;
			if( !( *msg & 1 ) ) {
				*msg = MSFAIL ;
			}
			break ;

		case VD_string	:
			*msg = VD_createTextExp( NULL, value->_sval, expOs, 
						&expId ) ;
			if( !( *msg & 1 ) ) {
				*msg = MSFAIL ; goto wrapup ;
			}
			break ;

		default		:
			*msg = MSINARG ;
			goto wrapup ;
	}

	outParms->OUTPUT[outParms->count].objid = expId ;
	outParms->OUTPUT[outParms->count].osnum = expOs ;

	res->_oval._grid	= outParms->OUTPUT[outParms->count] ;
	res->_oval._matrix_type	= MAIDMX ;
	MAidmx( msg, res->_oval._matrix ) ;
	
	outParms->count++ ;

	*msg = MSSUCC ;

	wrapup :
		return *msg & 1 ;

} /* VD_cstExp */
/*----------------------------------------------------------------------------*/
int VD_evalRepresentation( msg, object, res )

long			*msg ;
struct GRobj_env	*object ;
VD_execRes		*res ; {

	long		sts ;
	VD_dspRep	rep ;
	char		*s = "" ;

	sts = om$send(	msg	= message ACncpx.ACget_NV_rep( &rep ),
			senderid= object->_objid,
			targetid= object->_objid,
			targetos= object->_osnum ) ;

	/*
	 * In case of error (object does not understand above message), or
	 * no rep, result will be "".
	 */
	if( sts & 1 ) {
		     if( rep & AC_2D_REP  )	s = "2d" ;
		else if( rep & AC_3D_REP  )	s = "3d" ;
		else if( rep & AC_ENV_REP )	s = "env";
	}
	res->type = VD_string ;
	strcpy( res->_sval, s ) ;

	*msg = MSSUCC ;
	return TRUE ;

} /* VD_evalRepresentation */

/*----------------------------------------------------------------------------*/

end implementation VDSroot ;
