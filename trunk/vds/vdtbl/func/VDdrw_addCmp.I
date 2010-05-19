/* $Id: VDdrw_addCmp.I,v 1.1.1.1 2001/01/04 21:09:27 cvs Exp $  */

/* I/VDS
 * -------------------------------------------------------------------------
 *
 * File:        vdtbl/func / VDdrw_addCmp.I
 *
 * Description:
 *	Function :  VD_drwtb_addComponents
 *
 *
 * Dependencies:
 *
 * History:
 *
 *	04/14/95	R. Manem	Creation
 *
 * -------------------------------------------------------------------------
 */

class implementation Root;

/*
#define vdsDEBUG
#define vdserrDEBUG
*/

#include <stdio.h>

#include "igrtypedef.h"
#include "igetypedef.h"
#include "OMerrordef.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "igetypedef.h"
#include "gr.h"
#include "growner.h"

#include "v_miscmacros.h"
#include "v_dbgmacros.h"
#include "v_datamacros.h"

#include "emsdef.h"
#include "EMSutlmacros.h"

from GRowner		import	GRadd_components;

/*+fe
 -------------------------------------------------------------------------
  Function VD_drwtb_addComponents

  Macro Name
        None

  Abstract
	Function adds the given list of components to the specified owner 
	object. All components must have the same module environment

  Arguments

	IGRlong		*msg	    	O	return code
	struct GRmd_env	*md_env		I	Module environment
	IGRint		nbComps		I 	Number of components
	struct GRid	*compIds	I	List of components
	struct GRid	ownerId		I 	Id of the owner object
	
	
  Notes/Remarks

  Returns
	OM_S_SUCCESS	= if success
	OM_E_ABORT	= if error
 -------------------------------------------------------------------------
-fe*/

IGRlong VD_drwtb_addComponents(	IGRlong		*msg,
				struct GRmd_env	*md_env,
				IGRint		nbComps,
				struct GRid	*compIds,
				struct GRid	ownerId )
{
    IGRint		i;
    IGRlong		status = OM_S_SUCCESS;
    struct GRobj_env	*objs = NULL;

    SetProc( VD_drwtb_addComponents ); Begin

    *msg = MSSUCC;

    if( !nbComps )
	goto wrapup;

    /* allocate space for the obj envs */

    objs = _MALLOC( nbComps, struct GRobj_env );

    if( !objs )
	vd_$mem_fail( sts = status );

    for( i = 0 ; i < nbComps ; i++ )
    {
	objs[i].obj_id = compIds[i];
	objs[i].mod_env = *md_env;
    }

    status =
    _VD_SEND_OBJN( ownerId, GRowner.GRadd_components(	msg,
							md_env,
							&nbComps,
							objs,
							NULL, NULL ) );
    CheckRC( status, *msg );
    
wrapup :

    _FREE( objs );

    End
    return status;
}

end implementation Root;
