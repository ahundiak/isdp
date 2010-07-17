/*
	I/STRUCT
*/
class implementation VSelonspCmd;

#include <stdlib.h>
#include "OMmacros.h"
#include "exdef.h"
#include "exmacros.h"
#include "msdef.h"
#include "COBmacros.h"
#include "comiscmac.h"
#include "lcdef.h"
#include "growner.h"
#include "grgsdef.h"
#include "grgsmacros.h"
#include "nddef.h"
#include "asmacros.h"
#include "EMSmsgdef.h"
#include "grdpbmacros.h"
#include "vsdef.h"
#include "vsdbgmacros.h"
#include "vsmiscmacros.h"
#include "vscmddef.h"
/*
 * Includes for function prototypes.
 */
#include "vselmsonsupp.h"
#include "vsstrngproto.h"
#include "vsvirtualinf.h"

from GRgrset    import GSend_transition, GSstart_transition;
from GRgrset	import GSobject_add ;
from VSfeature	import VSgetSupportedElements ;
/*----------------------------------------------------------------------------*/
method GetAndPutElemsOnGS( int *sts ) {

	long		sts = OM_S_SUCCESS,
			msg ;
	struct GRid	ASsupport,
			gs ;
	struct GRobj_env*supports	= NULL ;
	long		size ;
	int		j,
			k,
			count,
			properties	= LC_DP_ONLY | LC_LC_ONLY | LC_RW,
			resp ;
	struct GRmd_env	VisObjMdEnv ;
	struct GRevent	event ;
	struct GRid	*resList	= NULL ;
	struct GRid	sv_id;
			
	gs.objid = NULL_OBJID ;

	/*
	 * Get located supports.
	 */	 
	supports = _MALLOC( me->oprndCount, struct GRobj_env ) ;
	if( !supports ) { msg = EMS_E_NoDynamicMemory ; goto wrapup ; }

	sts = om$send(	msg	= message VSlocateCmd.getLocObjs(
					&msg, me->oprndCount, supports ),
			targetid= my_id ) ;
	__CheckRC( sts, msg, "VSlocateCmd.getLocObjs", wrapup ) ;

	/*
	 * Init the graphics set.
	 * `flag = 2' means to construct a graphics set that is to be
	 * used as a select set.
	 */ 
	gs.osnum = me->ModuleInfo.md_id.osnum ;
	sts = gr$gsinit(	msg	= &msg,
				flag	= 2,
				p_objid	= &gs.objid,
			 	osnum	= gs.osnum ) ;
	if( !( sts & 1 & msg ) ) goto wrapup ;

	sts = om$send ( msg = message GRgrset.GSstart_transition (
						&msg, 
						&me->ModuleInfo, 
						&properties, 
						NULL, 
						&sv_id),
			targetid = gs.objid,
			targetos = gs.osnum);


	/*
	 * For all the supports, get its beam (or stiffener) children and add 
	 * them to graphics set.
	 */
	for( j = 0 ; j < me->oprndCount ; j++ ) {
		
		if( me->mytype == 0 ) {
			/*
			 * Command is 'Select Beams On Surface'.
 			 * Retrieve ASsource of the surface.
	 	 	 */
		 	sts = as$make_source(	go_grid	= supports[j].obj_id,
						mod_env	= &supports[j].mod_env,
						as_os	= supports[j]._osnum,
						as_grid	= &ASsupport ) ;

			sts = VSgetElementsOnSupport(	&msg,
							&ASsupport,
							VS_m_SRC_BEAM,
							TRUE,
							&count,
							&resList ) ;
			__CheckRC( sts, msg, "VSgetElementsOnSupport", wrapup );
		} else {
			/*
			 * Command is 'Select Stiffeners On Plate'.
			 */
			sts = om$send(
				msg	= message VSfeature.VSgetSupportedElements(
								&msg,
								TRUE,
								&count,
								&resList ),
				targetid = supports[j]._objid,
				targetos = supports[j]._osnum ) ;
			__CheckRC( sts, msg, "VSfeature.VSgetSupportedElements", wrapup);

		}

		for( k = 0 ; k < count ; k++ ) {
	
			sts = VSgetVirtualInfo( &msg,
						resList + k,
						&VisObjMdEnv,
						NULL ) ;
			__CheckRC( sts, msg, "VSgetVirtualInfo", wrapup ) ;

			/*
			 * Add the visible object to graphics set.
			 */		 
			sts = om$send(	msg	= message GRgrset.GSobject_add(
								&msg,
								resList + k,
								&VisObjMdEnv,
								&properties,
								NULL,
								NULL ),
				       targetid = gs.objid,
				       targetos = gs.osnum ) ;
			__CheckRC( sts, msg, "GRgrset.GSobject_add", wrapup ) ;

		} /* end for k ... */

		_FREE( resList ) ; resList = NULL ;

	} /* end for i ... */

	sts = om$send (msg = message GRgrset.GSend_transition (
							&msg,
                	                                NULL),
			targetid = gs.objid, 
			targetos = gs.osnum);

   	sts = gr$gsinqcount (  msg = &msg, 
				  count = &count,
            			  object_id = &gs );

   	if (count)
   	{
      		sts = gr$gsput_select_set (	msg = &msg, 
						mod_env = &me->ModuleInfo,
               					select_set_id = &gs );
   	} else {
		sts = MSFAIL;
	}

	/*
	 * Put the graphics set onto the event queue.
	 * Format event structure.
	 */
	co$build_button( msg	  = &msg,
			 objid    = me->event1.event.button.objid,
			 osnum	  = me->event1.event.button.osnum,
			 button	  = &event.event.button ) ;
			 
	event.num_id = 1 ;
	event.located_object[0].located_obj = gs ;
	event.located_object[0].module_info = me->ModuleInfo ; 

	/*
	 * Put EX_OBJID event on front of software queue.
	 */
	
	size = sizeof( struct GRevent ) - sizeof( long ) * 2 ;

	resp = EX_OBJID ;
	
	ex$putque( msg		= &msg,
		   byte 	= &size,
		   response 	= &resp,
		   buffer	= (char *) &event.event.button ) ;
		   
	wrapup :
		_FREE( supports );
		/*
		 * Just in case we exited 'for' loop prematurely without freeing
		 * this baby.
		 */
		_FREE( resList ) ;
		if( sts & 1 ) {
			me->ret = VS_K_ACT_SUCCESS ;
		} else {
			me->ret = VS_K_RESTART_CMD ;
			if( !IF_NULL_OBJID( gs.objid ) ) {
				gr$gsdissolve( msg = &msg, object_id = &gs ) ;
			}
		}
	
	return OM_S_SUCCESS ;

} /* method GetAndPutElemsOnGS */
/*----------------------------------------------------------------------------*/


end implementation VSelonspCmd ;
