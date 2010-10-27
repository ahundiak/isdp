/*
 * I/VDS --
 *
 */
command_string	VDC_M_ElSetDef,0,VDStDfElm
class	        VDCmdgrset
super_class     VDS_LOCATE	
product_name	"$VDS"
options		"SITC"
command_table	"vds.cmd"
spec_path	"$VDS/spec"

start_state     start	

/*---------------------------------------------------------------------------*/
/*

Description

   This is the command class for creating a set

*/

/*----------------------------------------------------------------------------*/

specification

instance 
{
	char	                	name[32];     /* set name  */
        variable struct GRobj_env       locObjs[0]; /* selected objects  */ 
        int                             numobjs;
}

/*----------------------------------------------------------------------------*/

implementation

#include <stdio.h>
#include "OMprimitives.h"
#include "OMmacros.h"
#include "asmacros.h"
#include "coparamac.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "AS_status.h"
#include "vdsetmacros.h"
#include "v_miscmacros.h"
#include "v_dbgmacros.h"

#define FOUND		2001
#define NOT_FOUND	2002
#define INVALID_NAME	2003

/*
 * Global defined module environment.
 */

from	GRgraphics	import	GRconstruct;
from	GRowner		import	GRadd_components;
from	GRconnector	import	GRflexconn;
from    VDgrset         import  VDSet_flag;

/*------------------------------- state table --------------------------------*/

state_table

#include	"VDSFilter.h"
#include	"VDmsg.h"

#define FOUND		2001
#define NOT_FOUND	2002

state	start

	message_key	VD_M_ElSetDef
	prompt_key	VD_P_DESGiveSetName
	filter	        get_event

	on EX_BACK_UP					state .

	on EX_STRING
	  do check_set_name
		on RETURN_CODE = FOUND
		    do status_key VD_S_DESDuplicate	state .

		on RETURN_CODE = NOT_FOUND
		    do status " "
		    do save_set_name			state loc_elm

		on ELSE					state .
							state .

state	loc_elm

	message_key	VD_M_ElSetDef
	prompt_key	VD_P_DESIdElmSet
        locate_mask     "GRm_DATA | GRm_OBJID | GRm_RJT_MOVEON |
                         GRm_STRING | GRm_BACK_UP"
        locate_owner    " LC_RIGID_COMP | LC_RIGID_OWNER |
                        LC_FLEX_COMP | LC_FLEX_OWNER | LC_REF_OBJECTS " 
        filter          vds_locate

	on EX_BACK_UP						state -

	on EX_DATA or EX_OBJID
		do process_locate				state make_set 


state make_set

	execute make_set_of_objects

	on ELSE							state start

/*--------------------------------- state table ------------------------------*/

action check_set_name
{
	long		sts1, ret_msg;
	struct GRid	grid;

	*sts = NOT_FOUND ;

	sts1 = vd$setname_togrid( set_name = me->event1.event.keyin,
				  set_grid = &grid,
                                );
	*sts    = ( sts1 == 1 ) ? FOUND : NOT_FOUND;
	ret_msg = ( sts1 == 1 ) ? FOUND : NOT_FOUND;
}

/*----------------------------------------------------------------------------*/	

action save_set_name
{
	sprintf( me->name, "%s", me->event1.event.keyin );
}

/*---------------------------------------------------------------------------*/

action make_set_of_objects
{
long			sts1, msg;
struct GRid		set_id;
int                     flag;

/*
 * Construct the VDgrset object
 */
        set_id.objid = NULL_OBJID;

	sts1 = vd$create_set( set_name        =  me->name,
                              delete_existing =  0,
			      comps           =  me->locObjs,
			      numcomps        =  me->numobjs,
			      set_env         =  &me->ModuleInfo,
			      set_grid        =  &set_id );

        if( set_id.objid != NULL_OBJID ){
             status =
             om$send( msg = message VDgrset.VDSet_flag( &msg, 0 ),
                      targetid = set_id.objid,
                      targetos = set_id.osnum );
             as$status(); 
        }

	return( OM_S_SUCCESS );

}

/*----------------------------------------------------------------------------*/

action process_locate
{

long              msg;
int               i;
struct GRobj_env  *locobjs = NULL,
		  *tempobjs = NULL;


     /* get the list of located objects */

     status =
     as$start_fence( set = &me->event1.located_object[0].located_obj,
                     nb_obj           = &me->numobjs,
                     p_obj_env        = &locobjs,
                     response         = me->response,
                     response_data    = me->response_data );
  
     if( !(status & 1) || !me->numobjs )
     {
          goto wrapup;
     }

     tempobjs = _MALLOC( me->numobjs, struct GRobj_env );
     if( !tempobjs )
     {
          printf("\nERROR : Dynamic allocation\n");
          goto wrapup;
     }

     for( i = 0 ; i < me->numobjs ; i++ )
          tempobjs[i] = locobjs[i];
     
     status =
     VD_objCheckInputOnCorrObject(   &msg,
                                     &me->numobjs, 
                                     &tempobjs );
     status = om$vla_set_dimension( varray      = me->locObjs,
                                    size        = me->numobjs );
     for( i = 0 ; i < me->numobjs ; i++ ){
        me->locObjs[i] = tempobjs[i];
     }

wrapup :
     _FREE( tempobjs );

     ASend_fence();
     dp$erase_hilite( msg = sts );

     return OM_S_SUCCESS;
}

/*----------------------------------------------------------------------------*/
