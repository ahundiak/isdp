class implementation VDCmdExDr;

#include <stdio.h>
#include <math.h>
#include "OMmacros.h"
#include "OMprimitives.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"
#include "go.h"
#include "igrdp.h"
#include "dp.h"
#include "dpmacros.h"
#include "macro.h"
#include "nddef.h"
#include "ndmacros.h"
#include "FI.h"
#include "DIdef.h"
#include "DItypedef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "DImacros.h"
#include "v_miscmacros.h"
#include "v_dbgmacros.h"

#include "madef.h"
#include "AS_status.h"
#include "VDmsg.h"

from	GRgraphics	import	GRdisplay;
from	NDmacro		import	ACreturn_foot;

method status_disp()
{
int		sts = OM_S_SUCCESS ;

	SetProc( status_disp ); Begin 

	sts =
	_VD_SEND_WRT_M( my_id, CEO.status_disp() );
	CheckRC( sts, 1 );

	FIf_reset( me->status_display_form_ptr );

	if( me->status_display_form_ptr ){
		/*
		 * Set state of the Three gadgets.
		 */
		__DBGpr_int(" locGroup ", me->locGroup );

		FIg_set_state(	me->status_display_form_ptr, 
				VD_K_LOC_SELECT, me->locGroup );
	}

	if( me->form_requested ){
		FIf_display( me->status_display_form_ptr );
	}

	End ;
	return OM_S_SUCCESS ;
}

method form_notification(	int form_label ;
				int gadget_label ;
				double value ;
				char * form_ptr )
{
int			sts = OM_S_SUCCESS;

	SetProc( form_notification ); Begin

	if ( form_ptr == NULL ) return( OM_E_INVARG );

	switch( gadget_label )
	{
	case FI_CANCEL :
		FIf_erase( form_ptr );
		me->form_requested = 0 ;
		break;

	case VD_K_LOC_SELECT :

	        FIg_get_state(  form_ptr, gadget_label, &sts );
		me->locGroup  = sts ;

		__DBGpr_int(" SELECT_STATE ", me->locGroup );
		break;
	default:
		__DBGpr_com(" Invalid Option " );
		goto wrapup ;
	}
	
	wrapup:
		End ;
		return OM_S_SUCCESS;
}

method addLocatedObject (	long		*sts;
				struct GRid	*objToAdd ;
				struct GRmd_env	*envToAdd ;
				int		index )
{
int			sizeLoc = 0,
			i ;
struct	GRobj_env	*pLoc;

	SetProc( addLocatedObject ); Begin

	*sts = OM_S_SUCCESS;

#ifdef	vdsDEBUG
	if( envToAdd ){
		__DBGpr_obj("OBJECT ", *objToAdd );
		__DBGpr_mat("MATRIX ", envToAdd->_MATRIX );
	}
#endif

	pLoc	= me->ObjList ; 
	sizeLoc = om$dimension_of( varray = me->ObjList );
		
	/*
	 * Check if object is already in list.
	 */
	for( i=0 ; i<sizeLoc ; i++ ) {
		if(	objToAdd->objid == pLoc[i].obj_id.objid &&
			objToAdd->osnum == pLoc[i].obj_id.osnum ) {
			*sts = ALREADY_LOC ; goto quit ;
		}
	}

	if( index >= sizeLoc ) {
		/*
		 * Add.
		 */
		if( index == OM_K_MAXINT ) {
			/*
			 * Add at the end.
			 */
			index = sizeLoc ;
		}

		if(! om$vla_set_dimension(	varray	= me->ObjList,
						size	= index + 1 )){
			printf("ERROR dynamic allocation\n");
			*sts = OM_E_ABORT;
			goto quit;
		}

		me->ObjList[index].obj_id = *objToAdd ;
		me->MaxObjList ++ ;

		if( envToAdd ) {
		      me->ObjList[index].mod_env	= *envToAdd ;
		} 
		else {
			ex$get_modid(
				mod_osnum = objToAdd->osnum,
				mod_id	  = &me->ObjList[index]._md_id ) ;

			me->ObjList[index]._md_os	 = objToAdd->osnum ;
			me->ObjList[index]._matrix_type = MAIDMX ;
			MAidmx( &sts, me->ObjList[index]._matrix ) ;
		}
	}  /* ( index >= sizeLoc ) */

	/*
	 * verify if the object in the reference list and remove if needed.
	 */

	*sts = OM_S_SUCCESS;
	goto quit;

quit:
	End ;
	return OM_S_SUCCESS;
}

method dpLocObjs ( long *sts ; int from_index ; enum GRdpmode dpmode )
{
int			status = OM_S_SUCCESS;
int			i,
			count = 0 ;
struct GRid		modObj,
			actMod;
struct	GRobj_env	*pList ;

	SetProc( dpLocObjs ); Begin
	
	*sts = OM_S_SUCCESS;

	pList = me->ObjList ;
	count = om$dimension_of( varray = me->ObjList );

	if( !count ) { *sts = NO_LOC_OBJ ; goto quit ; }

	if( from_index >= count ) { *sts = INVINDEX ; goto quit ; }

	status =
	ex$get_cur_mod( id = &actMod.objid, osnum = &actMod.osnum ) ;

	for(i = from_index; i< count; i++){

 	    if( pList[i]._objid != NULL_OBJID ) {

		modObj.objid = NULL_OBJID ;

		_VD_SEND_OBJ(	pList[i]._grid,
				NDmacro.ACreturn_foot(
					sts, "", &modObj, NULL, NULL ));

		if( modObj.objid != NULL_OBJID){

       	 		_VD_SEND_OBJ(	modObj,
					GRgraphics.GRdisplay(
						sts,
                                        	&pList[i]._matrix_type,
                                        	pList[i]._matrix,
                                        	&dpmode,
                                        	&actMod ));
		}
	    }
	}

	status = OM_S_SUCCESS;
	goto quit;

	quit:
		End ;
		return OM_S_SUCCESS;
}

end implementation VDCmdExDr;
