/* $Id: VDrtParams.I,v 1.1.1.1 2001/01/04 21:09:12 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdroot / VDrtParams.I
 *
 * Description:
 *	Implementation of methods  :
 *			VDreviewParameters
 *			VDgetParameters
 *
 * Dependencies:
 *
 * Revision History:
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	02/15/95	R. Manem	Creation
 *
 * -------------------------------------------------------------------*/

/*
	I/VDS
*/
class implementation VDSroot ;

/*
#define vdsDEBUG
#define vdserrDEBUG
*/

#include "EMSmsgdef.h"
#include "v_miscmacros.h"
#include "v_datamacros.h"
#include "v_dbgmacros.h"
#include "ACrg_collect.h"
#include "vdparmacros.h"


/*----------------------------------------------------------------------------*/

method VDreviewParameters(     IGRlong                 *msg;
                               IGRint                  nbParams;
                               struct ACrg_coll        *parList;
                               struct GRmd_env         *md_env )
{
    IGRlong		sts = OM_S_SUCCESS;
    struct GRid 	obj;

    SetProc( VDSroot.VDreviewParameters ); Begin

    __DBGpr_me();

    *msg = MSSUCC;

    obj.osnum = OM_Gw_current_OS;
    obj.objid = my_id;

    sts = vd$review_parameters(	pMsg		= msg,
				pComponent	= &obj,
				NbParams	= nbParams,
				pList		= parList,	
				pMdEnv		= md_env );
    
    CheckRC( sts, *msg );

    End

    return sts;
}

/*----------------------------------------------------------------------------*/
method VDgetParameters(        IGRlong                 *msg;
                               IGRint                  *nbParams;
                               struct ACrg_coll        **parList;
                               struct GRmd_env         *md_env )
{
    IGRlong		sts = OM_S_SUCCESS;
    struct GRid 	obj;

    SetProc( VDSroot.VDgetParameters ); Begin

    __DBGpr_me();

    *msg = MSSUCC;

    *nbParams = 0;
    *parList = NULL;

    obj.osnum = OM_Gw_current_OS;
    obj.objid = my_id;

    /* get number of parameters */

    sts = vd$get_parameters(	sts	= msg,
				object	= &obj,
				md_env	= md_env,
				count	= nbParams );
    CheckRC( sts, *msg );
    
    __DBGpr_int( "nbParams", *nbParams );

    if( !(sts & 1) || !*nbParams )
    {
        *nbParams = 0;
        goto wrapup;
    }

    /* allocate memory */

    *parList = _MALLOC( *nbParams, struct ACrg_coll );

    if( !*parList )
        vd_$mem_fail();

    /* get the parameter list */

    sts = vd$get_parameters(	sts	= msg,
				object	= &obj,
				md_env	= md_env,
				plist	= *parList,
				size	= *nbParams,
				count	= nbParams );
    CheckRC( sts, *msg );
    
wrapup :

    End
    return sts;
}

/*----------------------------------------------------------------------------*/

end implementation VDSroot ;

