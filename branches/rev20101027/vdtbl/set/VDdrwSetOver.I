/* $Id: VDdrwSetOver.I,v 1.1.1.1 2001/01/04 21:09:30 cvs Exp $  */
/*--------------------------------------------------------------------------
/* I/VDS
 *
 * File:        vdtbl/set / VDdrwSetOver.I
 *
 * Description:
 *	Implementation of overridden methods
 *
 * Dependencies:
 *
 * History:
 *      
 *	04/14/95	R. Manem	Creation
 *	10/10/95	R. Manem	Free lObjs pointer in NDmove_to_root
 *
 * -------------------------------------------------------------------------
 */

class implementation VDdrwSet;

/*
#define vdsDEBUG
#define vdserrDEBUG
*/

#include "v_miscmacros.h"
#include "v_dbgmacros.h"
#include "v_datamacros.h"

#include "OMmacros.h"
#include "OMprimitives.h"

#include "emsdef.h"
#include "EMSutlmacros.h"

#include "nddef.h"
#include "ndmacros.h"

#include "asbox.h"

from VDdrwTblRow		import	VDparentSetEmpty;

/*+mo
 ---------------------------------------------------------------------------
  Overridden Message
        NDplace from NDnode

  Abstract
        Do nothing.  No graphical components

  Arguments
        struct GRas     *assoc_list     I       associative information
        struct GRmd_env *md_env         I       module env
        char            *go_cnst_lis    I       full construction for the
                                                corresponding graphic object

 ---------------------------------------------------------------------------
-mo*/

method NDplace(	struct GRas	*asso_lis;
		struct GRmd_env	*mod_env;
		char		*go_cnst_lis )
{
    SetProc( VDdrwSet.NDplace ) ; Begin

    End

    return OM_S_SUCCESS;
}

/*+mo
 ---------------------------------------------------------------------------
  Overridden Message
        NDcompute_node from NDnode

  Abstract
        Do nothing.  No graphical components

  Arguments
        IGRlong         *msg            O       return code
        IGRint          cn_type         I       reserved
        IGRint          count           I       number of roots
        struct GRid     *list           I       list of roots
        struct GRmd_env *md_env         I       module env

 ---------------------------------------------------------------------------
-mo*/

method  NDcompute_node ( IGRlong         *msg;
                         IGRint          cn_type;
                         int             count;
                         struct GRid     *list;
                         struct GRmd_env *mod_env )
{
    SetProc( VDdrwSet.NDcompute_node ) ; Begin

    *msg = MSSUCC;

    End
    return OM_S_SUCCESS;
}

/*+mo
 ---------------------------------------------------------------------------
  Overridden Message
        NDmove_to_root from NDnode

  Abstract
        When any of the parents is deleted, this message is received.
        Get the new list of parents. If one or more, put myself in the
        wait_batch, so that the dependent row object will recompute.  Else
        send VDparentSetEmpty message to the row object.

  Arguments
        IGRlong         *msg            O       return code
        struct GRid     *src_grid       O       GRid of the created object
        struct GRmd_env *md_env         I       module env
 ---------------------------------------------------------------------------
-mo*/

method NDmove_to_root(	IGRlong		*msg;
			struct GRid	*src_grid;
			struct GRmd_env	*md_env )
{
    IGRint		nbObjs = 0;
    IGRlong		status = OM_S_SUCCESS;
    struct GRid		obj;
    struct GRobj_env	*lObjs = NULL;

    SetProc( VDdrwSet.NDmove_to_root ) ; Begin

    *msg = MSSUCC;

    /* get number of objects in the set */

    status =
    _VD_SEND_MY( VDdrwSet.VDgetSetObjects( 	msg,
						&nbObjs,
						NULL ) );
    CheckRC( status, *msg );

    __DBGpr_int( "Number of parents in set", nbObjs );

    if( nbObjs )
    {
	/* allocate memory */

	lObjs = _MALLOC( nbObjs, struct GRobj_env );
	if( !lObjs )
	vd_$mem_fail( sts = status );

	/* get list of objects (valid) */

	status =
	_VD_SEND_MY( VDdrwSet.VDgetSetObjects(	msg,
						&nbObjs,
						lObjs ) );
	CheckRC( status, *msg );
    }

    __DBGpr_int( "Number of valid parents in set", nbObjs );

    if( nbObjs > 0 )
    {
        /* execute myself to recompute the dependent row object */

        obj.objid = my_id;
        obj.osnum = OM_Gw_current_OS;

        nd$wait_batch(	type    = GR_GEOM_POSTED,
                        nb_obj  = 1,
                        l_object= &obj );
        nd$exec_batch();
    }
    else
    {
        /* send VDparentSetEmpty message to the row object */

        status =
        _VD_SEND_CHAN( ND_children, VDdrwTblRow.VDparentSetEmpty( msg ) );
        CheckRC( status, *msg );
    }
     
wrapup :

    _FREE( lObjs );
    End
    return OM_S_SUCCESS;
}

end implementation VDdrwSet;

