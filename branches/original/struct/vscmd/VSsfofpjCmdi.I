/*
	I/STRUCT
*/
class implementation VSsfofpjCmd ;

#include <stdio.h>
#include <stdlib.h>
#include "exmacros.h"
#include "growner.h"
#include "gr.h"
#include "go.h"
#include "acrepdef.h"
#include "EMSmsgdef.h"
#include "vsdef.h"
#include "vs.h"
#include "vscmdmacros.h"
#include "vscmddef.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"

from GRgraphics	import GRconstruct ;
/*----------------------------------------------------------------------------*/
method suppressAutoHilite() {

	me->suppressHilite = TRUE ;

	return OM_S_SUCCESS ;

} /* method suppressAutoHilite */
/*----------------------------------------------------------------------------*/
method construct_surface( long *msg ) {

	long			sts ;
	struct GRobj_env	*located = NULL ;
	struct GRobj_env	parents[3] ;      /* 0 : plane		      */
						  /* 1 : curve		      */
						  /* 2 : width of surface     */
	struct GRvg_construct	cst ;
	struct VScnst_list	attr ;
	struct GRid		surface ;         /* Surface constructed      */
	int			i ;
	extern OMuword		OPP_VSsurfOfProj_class_id ;

	/*
	 * Get located objects :
	 *	"me->oprtrCount"	= number of located curves
	 *	"1"			= the located plane
	 */
	located = _MALLOC( me->oprtrCount + 1, struct GRobj_env ) ;
	if( !located ) {
		*msg = EMS_E_NoDynamicMemory ; sts = OM_W_ABORT ; goto wrapup ;
	}
	sts = om$send( msg	= message VSlocateCmd.getLocObjs(
					msg, me->oprtrCount + 1, located ),
		       targetid= my_id ) ;
	__CheckRC( sts, *msg, "VSlocateCmd.getLocObjs", wrapup ) ;

	/*
	 * Fill construction list.
	 */
	vs$cnstDefaults(	msg	= msg,
				symb_id	= me->ModuleInfo.md_id,
				symb 	= &me->ActiveRep,
				level	= &me->ActiveLevel,
				display	= &me->ActiveDisplay ) ;

	vs$fill_cnst_list( Cnst_list	= cst,
			   Msg		= msg,
			   Env_info	= &me->cstEnv,
			   Display	= &me->ActiveDisplay,
			   Level	= me->ActiveLevel,
			   Class_attr	= &attr ) ;
			   
	parents[0]		= located[0] ;		/* plane	  */
	parents[2].obj_id	= me->expression ;      /* width	  */
	parents[2].mod_env	= located[0].mod_env ;	/* doesn't matter */
	
	attr.parent_count	= 3 ;
	attr.representation	= AC_NO_REP ;
	attr.feature_att	= NULL ;
	
	for( i = 0 ; i < me->oprtrCount ; i++ ) {
		
		parents[1] 	 = located[i+1] ;

		attr.parent_list = parents ;

		/*
		 * Construct surface.
		 */
		sts = om$construct(
			classid	= OPP_VSsurfOfProj_class_id,
			osnum	= me->cstEnv._MD_OS,
			p_objid = &surface.objid,
			msg	= message GRgraphics.GRconstruct( &cst ) ) ;
		__CheckRC( sts, *msg, "GRgraphics.GRconstruct", wrapup ) ;

		surface.osnum = me->cstEnv._MD_OS ;

		vs$bulk_display( grids	= &surface,
				 theEnv = &me->cstEnv,
				 dpmode = GRbd ) ;
	}

	wrapup :
		_FREE( located ) ;

		*msg = ( *msg & 1 & sts ) ? VS_K_ACT_SUCCESS :
		                            VS_K_RESTART_CMD ;

		return OM_S_SUCCESS ;

} /* method construct_surface */
/*----------------------------------------------------------------------------*/

end implementation VSsfofpjCmd ;
