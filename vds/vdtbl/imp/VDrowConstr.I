/* $Id: VDrowConstr.I,v 1.1.1.1 2001/01/04 21:09:28 cvs Exp $  */
/*--------------------------------------------------------------------------
/* I/VDS
 *
 * File:        vdtbl/imp / VDrowConstr.I
 *
 * Description:
 *	Implementation of the following method for VDdrwTblRow :
 *		VDconstructRow
 *
 * Dependencies:
 *
 * History:
 *      
 *	04/14/95	R. Manem	Creation
 *
 * -------------------------------------------------------------------------
 */

class implementation VDdrwTblRow;

/*
#define vdsDEBUG
#define vdserrDEBUG
*/

#include <stdio.h>

#include "OMmacros.h"
#include "OMprimitives.h"

#include "v_miscmacros.h"
#include "v_dbgmacros.h"
#include "v_datamacros.h"

#include "emsdef.h"
#include "EMSutlmacros.h"

#include "godef.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"

#include "nddef.h"

#include "VDdrwlo.h"
#include "VDdrwtbl.h"

from VDdrwSet		import	VDdeleteSet;

/*+me
 -------------------------------------------------------------------------
  Public Message VDconstructRow

  Abstract
        This method constructs the feet of the row object and 
        does ACchange_feet

  Arguments
        IGRlong         *msg      O     Return code

  Notes/Remarks

  Status/Return Code
      status == OM_S_SUCCESS    if success;
 -------------------------------------------------------------------------
-me*/


method  VDconstructRow(   IGRlong         *msg )
{
    IGRint		nbRoots,
			nbFeet,
			size = sizeof( struct GRmd_env );
    IGRlong		status = OM_S_SUCCESS;
    enum GRdpmode	dpmode = GRbd;
    struct GRmd_env	mod_env;
    struct GRid		roots[2],
			feet[2];

    SetProc( VDdrwTblRow.VDconstructRow ); Begin

    *msg = MSSUCC;

    /* get the current module env */

    status =
    gr$get_module_env(	msg	= msg,
			sizbuf	= &size,
			buffer	= &mod_env );
    CheckRC( status, *msg );

    /* get the template objects */

    status =
    _VD_SEND_MY( NDnode.NDget_objects(	ND_ROOT,
					roots,
					2,
					NULL,
					0,
					OM_K_MAXINT,
					&nbRoots ) );
    __CheckRC( status, *msg, "NDnode.NDget_objects", wrapup );

    __DBGpr_objlist( "List of roots for row", nbRoots, roots );

    /* construct the feet */

    status =
    _VD_SEND_MY( ACncpx.ACconstruct_feet(	msg,
						0,
						nbRoots,
						roots,
						&mod_env,
						&nbFeet,
						feet ) );
    __CheckRC( status, *msg, "ACncpx.ACconstruct_feet", wrapup );

    __DBGpr_objlist( "List of feet ", nbFeet, feet );
   
    /* change feet */

    _VD_SEND_MY( ACncpx.ACchange_feet(	nbFeet,
					feet,
					&mod_env ) );
    __CheckRC( status, *msg, "ACncpx.ACchange_feet", wrapup );

    /* display myself */

    status =
    _VD_SEND_MY( GRgraphics.GRdisplay(	msg,
					&mod_env.md_env.matrix_type,
					mod_env.md_env.matrix,
					&dpmode,
					&mod_env.md_id ) );
    CheckRC( status, *msg );

wrapup :
    End
    return status;
}

end implementation VDdrwTblRow;

