/*
	I/STRUCT
*/
/* ---------------------------------------------------------------------------
 *
 * File:        struct/vscmd/VStracflCmdi.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *
 *   MM/DD/YY   AUTHOR   DESCRIPTION
 *   01/14/97   ejm      CR 179603007, Command TRANSFER ELEMENT TO ACTIVE FILE
 *			 Error message needs updating when user does not have
 *			 ALL the parent reference files attached.
 *
 *			 In method, "operation", added code to output message
 *			 in status field indicating that active file was
 *			 missing reference files and sent message to key-in  
 *			 field to use the command, "Review Reference Files",
 *			 to see what reference files were missing.
 * -------------------------------------------------------------------------*/

class implementation VStracflCmd ;

#include <stdio.h>
#include "growner.h"
#include "dpmacros.h"
#include "dpdef.h"
#include "nddef.h"
#include "asmacros.h"
#include "asbox.h"
#include "acrepdef.h"
#include "vs.h"
#include "vspart.h"
#include "vsmiscmacros.h"
#include "vscmddef.h"
#include "vsdbgmacros.h"
#include "vscmdmacros.h"

#include "DIdef.h"        /* for DI_PATH_MAX */
#include "DIprims.h"      /* for di primitives, give_pathname and split */


extern OMuword	OPP_ACconst_class_id,
		OPP_VSimgFeature_class_id ;

from NDnode		import	NDcopy,
				NDconnect ,
				NDget_objects;
from ACncpx		import	ACget_NV_rep ;
from VSfeature		import	VSgetResultType ;
from VSimgFeature	import	VSgetModel ;

/*----------------------------------------------------------------------------*/
method locate_action_handler(	int			*keepIt ;
				enum GRlocate_action	*action ;
				struct GRlc_info	*entry ;
				struct LC_action_args	*args ) {

	long		sts,
			msg ;
	unsigned long	type ;
	struct GRid	as_grid ;
	struct GRid	*buffer;
	int		rflCount, i, nbChild;
	char		childClass[OM_K_MAXCLASS_LEN] ;

	*keepIt = FALSE ;

	if( entry->located_obj.osnum == me->ModuleInfo._MD_OS ) goto wrapup ;
	
	/*
	 *  Get the pretendin and check if any reference link objects
	 *  exists. Do not select those objects which already have link.	
	 */
	as$make_source ( go_grid         = entry->located_obj,
                         mod_env         = &entry->module_info,
                         as_os           = entry->located_obj.osnum,
                         as_grid         = &as_grid ) ;

        sts = om$send( msg =    message NDnode.NDget_objects (
							ND_CHILDREN | ND_IN_BUF,
                                                        NULL,
                                                        0,
                                                        &buffer,
                                                        0,
                                                        OM_K_MAXINT,
                                                        &nbChild ),
                        targetid = as_grid.objid,
                        targetos = as_grid.osnum );

        rflCount = 0;
        if( nbChild >= 1 ) {
                for( i = 0; i < nbChild ; i++ ) {
                        om$get_classname (
                                        classname       = childClass,
                                        objid           = buffer[i].objid,
                                        osnum           = buffer[i].osnum );
			/*
			 * If any more link objects are added up , 
			 * add here also.
			 */
			if( ( strcmp("VSrflPlate", childClass ) == 0 ) ||
			    ( strcmp("VSrfvPlate", childClass ) == 0 ) ||
			    ( strcmp("VSrflBeam",  childClass ) == 0 ) ||
			    ( strcmp("VSrfsBeam",  childClass ) == 0 )  )
                                rflCount++;
                }

                if( rflCount >=1 ) {
                        ex$message ( field         = ERROR_FIELD ,
                                     justification = CENTER_JUS ,
                                     in_buff       = "Already Link Exists" );
                        VS_Wait_timer( 10 ) ;
			*keepIt = FALSE ; goto wrapup ;
  		}
	}


	if( vs$is_ancestry_valid(	object	= &entry->located_obj,
					classid	= OPP_ACconst_class_id ) ) {
		*keepIt = TRUE ; goto wrapup ;
	}

	sts = om$send(	msg	= message VSfeature.VSgetResultType(
								&msg, &type ),
			targetid= entry->located_obj.objid,
			targetos= entry->located_obj.osnum ) ;
	if( !( sts & 1 & msg ) ) goto wrapup ;

	if( type & VS_m_PLATE ) {
		*keepIt = TRUE ;
	} else if( type & VS_m_BEAM ) {
		if( type & VS_m_IMG_generic ) {
			struct GRid	mdl ;
			sts = om$send(	msg	= message VSimgFeature.VSgetModel(
								&mdl, NULL ),
					targetid= entry->located_obj.objid,
					targetos= entry->located_obj.osnum ) ;
			if( !( sts & 1 ) ) goto wrapup ;
			sts = om$send(	msg	= message VSfeature.VSgetResultType(
								&msg, &type ),
					targetid= mdl.objid,
					targetos= mdl.osnum ) ;
			if( !( sts & 1 & msg ) ) goto wrapup ;
		}
		if( type & VS_m_SRC_generic ) {

			*keepIt = TRUE ;
		}
	}

	wrapup :
	return OM_S_SUCCESS ;

} /* method locate_action_handler */
/*----------------------------------------------------------------------------*/
method operation( long *msg ) {

	long			sts ;		/* OM return code	*/
	struct GRobj_env	locObj ;	/* One located objects	*/
	int			i,
				nbSuccesses ;
	struct GRid		rfl ;
#define CONST 		1
#define STRUCT_ELEM	2

	int			what ;

        char   status_string[55];  /* max 54 characters in status field */
	IGRchar full_name[DI_PATH_MAX]; /* 1023 chars max */
	IGRchar active_fname[DI_PATH_MAX];




	for( i = 0, nbSuccesses = 0 ; i < me->oprtrCount ; i++ ) {
		sts = om$send(	msg	= message VSlocateCmd.getLocObjAtIndex(
							msg, i, &locObj ),
				targetid= my_id ) ;
		__CheckRC( sts, *msg, "VSlocateCmd.getLocObjAtIndex", wrapup ) ;

		if( vs$is_ancestry_valid(
				object	= &locObj._grid,
				classid	= OPP_ACconst_class_id ) ) {

			if( vs$is_ancestry_valid(
				object	= &locObj._grid,
				classid	= OPP_VSimgFeature_class_id ) ) {
				what = STRUCT_ELEM ;
			} else {
				what = CONST ;
			}
		} else what = STRUCT_ELEM ;

		if( what == CONST ) {

			long		rc ;
			struct GRid	source ;

			sts = om$send(	msg	= message NDnode.NDcopy(
								msg,
								0,
								&locObj.mod_env,
								&me->ModuleInfo,
								&rfl ),
					targetid= locObj._objid,
					targetos= locObj._osnum ) ;

			if( !( sts & 1 ) ) continue ;

			sts = as$make_source(
					go_grid = locObj._grid,
					mod_env = &locObj.mod_env,
					as_os	= me->ModuleInfo.md_id.osnum,
					as_grid = &source ) ;
			if( !( sts & 1 ) ) continue ;


		       	sts = om$change_class(	objid		= rfl.objid,
						osnum		= rfl.osnum,
						classname	= "VDrflconst" ) ;
			if( !( sts & 1 ) ) continue ;

			sts = om$send(	msg	= message NDnode.NDconnect(
								1,
								&source,
								NULL_GRID,
								ND_NEW ),
					targetid = rfl.objid,
					targetos = rfl.osnum ) ;
			if( !( sts & 1 ) ) continue ;

			VSfindFindNameForRflElem( &rc, &locObj._grid, &rfl ) ;
		} else {
			sts = VScstRflStructElem(	msg,
							&locObj._grid,
							&locObj.mod_env,
							&me->ModuleInfo,
							&rfl ) ;

		  /* If status indicates non-success, retrieve the pathname */
		  /* for the active file and put a message in the status    */
		  /* field stating that a reference file is missing.        */
		  /* For CR 179603007.                                      */

		  if( !( sts & 1 ) )
		  {
		    sts = di$give_pathname( osnum = rfl.osnum,
					    pathname = full_name );
		    if( sts != DIR_S_SUCCESS )
		      di$report_error( sts = sts,comment = "di_give_pathname" );

		    sts = di$split(pathname = full_name,
                                   name     = active_fname);
		    if( sts != DIR_S_SUCCESS )
		      di$report_error( sts = sts, comment = "di_split" );

		    status_string[0] = '\0';
                    strcat( status_string, "Transfer elem failed: " );
                    strcat( status_string, active_fname );
                    strcat( status_string, " missing ref file" );
		    UI_status( status_string );
		    VS_Wait_timer( 120 );

		    UI_echo("      Use command, \"Review Reference Files\"");

		  } /* if( sts != 1 ) */

		} /* else from if( what == CONST ) */

		if( sts & 1 & *msg ) {
			vs$bulk_display(	grids	= &rfl,
						theEnv	= &me->ModuleInfo ) ;
			nbSuccesses++ ;
		}
	}
	*msg = nbSuccesses == me->oprtrCount ? MSSUCC : MSFAIL ;
	wrapup :
		me->ret = *msg & 1 ? VS_K_ACT_SUCCESS : VS_K_RESTART_CMD ;

		return OM_S_SUCCESS ;

} /* method operation */
/*----------------------------------------------------------------------------*/

end implementation VStracflCmd ;
