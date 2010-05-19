/* $Id: VDtblRecomp.I,v 1.1.1.1 2001/01/04 21:09:27 cvs Exp $ */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdtbl/cmd / VDrecomp.I
 *
 * Description:
 *      Implementation of the following method for VDCmdLineOut :
 *              recompute_table
 *
 * Dependencies:
 *
 * History:
 *
 *      10/05/95        R. Manem        Creation
 *
 * -------------------------------------------------------------------*/


class implementation VDCmdCrTbl;

/*
#define vdsDEBUG
#define vdserrDEBUG
*/

#include <stdio.h>
#include "string.h"

#include "OMmacros.h"
#include "OMprimitives.h"

#include "v_miscmacros.h"
#include "v_dbgmacros.h"
#include "v_datamacros.h"

#include "VDCmdDef.h"

/*+me
 ---------------------------------------------------------------------------
  Public Message recompute_table

  Abstract
        This method recomputes the table

  Arguments
        IGRlong         *sts            O       Return code

  Status/Return Code
      *sts = VD_SUCCESS
 ---------------------------------------------------------------------------
-me*/

method  recompute_table ( long * sts )
{
    IGRlong		msg = MSSUCC,
			status = OM_S_SUCCESS;

    SetProc( VDCmdCrTbl.recompute_table ); Begin

    *sts = VD_SUCCESS;

    me->tblObj.obj_id = me->event1.located_object[0].located_obj;
    me->tblObj.mod_env = me->event1.located_object[0].module_info;

    __DBGpr_obj( "Table Id", me->tblObj.obj_id );

    /* recompute the table */

    UI_status( "Recomputing table ..." );

    status = VDdrw_recomputeTable( &msg, me->tblObj.obj_id, 1, 1 );
    CheckRC( status, msg );

    /* clear status field */

    UI_status( "" );

wrapup :
    End
    return OM_S_SUCCESS;
}

end implementation VDCmdCrTbl;
