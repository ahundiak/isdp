/* $Id: VDreportproc.I,v 1.1.1.1 2001/01/04 21:07:43 cvs Exp $ */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vdat/reports/VDrplocate.I
 *
 * Description:
 *      Implementation of the following methods for VDCmdReport :
 *              process_locate
 *
 * Dependencies:
 *
 * History:
 *	10/23/97	adz		Creation Date.
 *	12/30/97	ah		moved to vdat
 *
 * -------------------------------------------------------------------*/


class implementation VDCmdReport;

/*
#define vdsDEBUG
#define vdserrDEBUG
*/

#include <stdio.h>
#include "string.h"

#include "OMmacros.h"
#include "OMprimitives.h"
#include "exproto.h"
#include "v_cmddef.h"
#include "v_miscmacros.h"
#include "vdsetmacros.h"
#include "v_dbgmacros.h"
#include "v_datamacros.h"

#include "go.h"
#include "macro.h"
#include "nddef.h"

#include "FI.h"
#include "FEI.h"

#include "coparamac.h"

/*+me
 ---------------------------------------------------------------------------
  Public Message process_locate

  Abstract
        This method processes the located set of objects for Report

  Arguments
        IGRlong         *sts            O       Return code

  Notes/Remarks

  Status Code
      status == OM_S_SUCCESS

  Return Code
      *sts =    VD_K_ACT_SUCCESS
                VD_ERROR (no memory)
		VD_RESTART_CMD (no objects located)
 ---------------------------------------------------------------------------
-me*/

method process_locate ( long * sts )
{
    IGRint		i,
			nbObjs = 0;
    IGRlong		msg = 1 ;
    struct GRid		setId;
    struct GRmd_env	setEnv;
    struct GRobj_env	*listObjs = NULL ;

    SetProc( VDCmdReport.process_locate ); Begin

    *sts = VD_K_ACT_SUCCESS;

    /* make graphic set, if necessary */
    VD_MakeGRsetOfObject(	&msg,
				&me->ModuleInfo,
				&me->event1.located_object[0].located_obj,
				&me->event1.located_object[0].module_info,
				&setId,
				&setEnv,
				0 );

    /* eliminate dangles, header, row, check for ownership of located objects */

    *sts =
    vd$filter_objects(	msg	= &msg,
			setId	= &setId );

    /* get the list of located objects */

    ACset_disthruref();

    *sts =
    as$start_fence(	set		= &setId,
			set_env		= &setEnv,
			nb_obj		= &nbObjs,
			p_obj_env	= &listObjs,
			response_data	= me->response_data );
			
    __DBGpr_int( "No of objects located", nbObjs );

    __CheckRC( *sts, 1, "as$start_fence", wrapup );

    ACreset_disthruref();

    /*
     * Filter out the objects : replace drawing objects with their parents
     * VDdrw_filterListOfObjects( &msg, &nbObjs, &tmpLObjs );
     */

    if( !nbObjs )
    {
        *sts = VD_K_NO_OBJ;
	goto wrapup;
    }

    *sts = om$vla_set_dimension(	varray = me->locObjs, size = 0 );
    __CheckRC( *sts, 1, "om$vla_set_dimension", wrapup );

    for( i = 0 ; i < nbObjs ; i++ )
    {
	    *sts =
	    _VD_SEND_MY( VDS_LOCATE.addLocatedObject(	&msg,
							&listObjs[i].obj_id,
							&listObjs[i].mod_env,
							OM_K_MAXINT ) );
	    __CheckRC( *sts, msg, "VDS_LOCATE.addLocatedObject", wrapup );
    }

    /* total number of objects */

    nbObjs = om$dimension_of( varray	= me->locObjs );

    /* number of located objects */
    __DBGpr_int( "Number of located objects", nbObjs );

#ifdef vdsDEBUG
    printf("\n\tFinal list of objects\n");
    for( i = 0 ; i < nbObjs ; i++ )
        printf("\t\tObj # %d = [%d, %d]\n", i, 	me->locObjs[i].obj_id.objid,
						me->locObjs[i].obj_id.osnum );
#endif

wrapup :

	if( !(*sts & msg & 1) ){
		*sts = VD_K_RESTART_CMD ;
		UI_status( "Error encountered : command terminated" );
	}
	ASend_fence();
	_FREE( listObjs );

        me->ret = *sts & 1 ? VD_K_ACT_SUCCESS : VD_K_RESTART_CMD ;

	End
	return OM_S_SUCCESS;
}

end implementation VDCmdReport;
