class implementation VDCmdgrset;



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


#define _start 0
#define _loc_elm 1
#define _make_set 2

method check_set_name ( long * sts )
{
  int		  status = OM_S_SUCCESS;

	long		sts1, ret_msg;
	struct GRid	grid;

	*sts = NOT_FOUND ;

	sts1 = vd$setname_togrid( set_name = me->event1.event.keyin,
				  set_grid = &grid,
                                );
	*sts    = ( sts1 == 1 ) ? FOUND : NOT_FOUND;
	ret_msg = ( sts1 == 1 ) ? FOUND : NOT_FOUND;
quit:
  return OM_S_SUCCESS;
}

method save_set_name ( long * sts )
{
  int		  status = OM_S_SUCCESS;

	sprintf( me->name, "%s", me->event1.event.keyin );
quit:
  return OM_S_SUCCESS;
}

method make_set_of_objects ( long * sts )
{
  int		  status = OM_S_SUCCESS;

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

quit:
  return OM_S_SUCCESS;
}

method process_locate ( long * sts )
{
  int		  status = OM_S_SUCCESS;


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
quit:
  return OM_S_SUCCESS;
}

end implementation VDCmdgrset;
