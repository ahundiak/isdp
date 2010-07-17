/*
	I/STRUCT
Abstract
	Builds a root complex which is a kind of graphic group which may be
	indexed into with names for components.

Arguments
	OUT	long		*msg		Completion code.
	IN	char		*name		Name of root complex def.
	IN	int		count		Count of components or feet.
	IN	struct GRid	*ids		Ids of components or feet.
	IN	char		**names		Names of components or feet.
	IN	struct GRmd_env	*cpx_env	Of root complex.
	IN	OMuword		cpx_os		Where to build root complex.
	OUT	OM_S_OBJID	*p_cpx_id	Id of complex built.
*/
class implementation VScpx ;

#include "acmacros.h"
#include "vsdbgmacros.h"

from	ci_mac_def	import	ACplace ;

extern struct GRid 	AC_construct_id ;
/*----------------------------------------------------------------------------*/
long VSbuildRootComplex( msg, name, count, ids,
			 names, cpx_env, cpx_os, p_cpx_id )

long		*msg ;
char		*name ;
int		count ;
struct GRid	*ids ;
char		**names ;
struct GRmd_env	*cpx_env ;
OMuword		cpx_os ;
OM_S_OBJID	*p_cpx_id ; {

	long		sts ;	/* OM return code	*/
	int		ACrc ;	/* AC return code	*/
	struct GRid	macDef ;/* Macro definition	*/

	extern OMuword	OPP_ci_mac_def_class_id,
			OPP_ACncpx_class_id ;

	sts = ac$find_macro_defn(	action		= ACfind_load,
					macro_name	= name,
					p_macro_defn_id	= &macDef ) ;
	if( !( sts & 1 ) ) {

		sts = om$construct(
			classid	= OPP_ci_mac_def_class_id,
			msg	= message ci_mac_def.ACplace(
					&ACrc,
					0,		/* Properties	*/
					name,		/* Name of def.	*/
					"",		/* Int. name	*/
					0,		/* Int. size	*/
					0,		/* Count of tmps*/
					NULL,		/* Names of tmps*/
					NULL,		/* Types of tmps*/
					0,		/* Temp feet num*/
					NULL,		/* Temp feet ind*/
					NULL,		/* Temp feet nms*/
					0,		/* Int feet num	*/
					NULL,		/* Int feet nms	*/
					NULL,		/* Int feet typs*/
					count,		/* Count of feet*/
					names,		/* Names of feet*/
					NULL,		/* Types of feet*/
					NULL ),		/* Orders of feet*/
			osnum	= AC_construct_id.osnum,
			p_objid	= &macDef.objid ) ;

		*msg = ACrc ? MSSUCC : MSFAIL ;
		__CheckRC( sts, *msg, "ci_mac_def.ACplace", wrapup ) ;
	}

	sts = om$construct(
			classid	= OPP_ACncpx_class_id,
			msg	= message ACncpx.ACmroot_place(
							&ACrc,
							0,
							name,
							count,
							ids,
							cpx_env ),
			osnum	= cpx_os,
			p_objid	= p_cpx_id ) ;

	*msg = ACrc ? MSSUCC : MSFAIL ;
	__CheckRC( sts, *msg, "ci_mac_def.ACplace", wrapup ) ;

	wrapup :
		return sts ;

} /* VSbuildRootComplex */
/*----------------------------------------------------------------------------*/

end implementation VScpx ;
