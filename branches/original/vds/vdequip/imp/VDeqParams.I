/* $Id: VDeqParams.I,v 1.1.1.1 2001/01/04 21:08:43 cvs Exp $  */

/* -------------------------------------------------------------------------
/* I/VDS
 *
 * File:        vdequip/imp/ VDeqParams.I
 *
 * Description:
 *      Implementation of parameter method for Equipment objects.
 *
 *      Methods :
 *            VDgetParameters
 *
 * History:
 *      02/16/95       R. Manem              Creation
 *
 * -------------------------------------------------------------------------
 */


class implementation VDequipment;

/*
#define vdsDEBUG
#define vdserrDEBUG
*/

#include "string.h"
#include "ACattrib.h"
#include "ACrg_collect.h"

#include "exmacros.h"
#include "vdparmacros.h"

#include "VDSequipdef.h"

#include "EMSmsgdef.h"
#include "v_miscmacros.h"
#include "v_datamacros.h"
#include "v_dbgmacros.h"

from ACrg_collect	import	AClist_attribute;

/*+mo
 -------------------------------------------------------------------------

  Overridden Message
        VDgetParameters from VDSroot

  Abstract

	Returns the list of all parameters

  Arguments
        IGRlong           *msg      O      Completion code.
        IGRint            *nbParams O      Number of parameters
        struct ACrg_coll  **parList O      List of parameters
        struct GRmd_env   *md_env   I      Module environment of object


  Status/Return Code
      OM_S_SUCCESS      if success
      OM_E_NODYNMEM     not enough dynamic memory
      OM_W_ABORT        if some other error

 -------------------------------------------------------------------------
-mo*/

method VDgetParameters(        IGRlong                 *msg;
                               IGRint                  *nbParams;
                               struct ACrg_coll        **parList;
                               struct GRmd_env         *md_env )
{
    IGRlong             status = OM_S_SUCCESS;
    IGRint		i,
			nbStatAtt,
			nbDynAtt;
    IGRchar		tempBuf[256];
    struct GRid         dyn_box, 
			stat_box;

    SetProc( VDequipment.VDgetParameters ); Begin

    __DBGpr_me();

    *msg = MSSUCC;

    *nbParams = 0;
    *parList = NULL;

    /* 
     * get the static attribute collector 
     */

    status = _VD_SEND_MY( ACcpx.ACfind_temp_obj((IGRint *)msg, 
						"syspara", 
						&stat_box ) );
    __CheckRC( status, *msg, "message ACcpx.ACfind_temp_obj", wrapup );

    __DBGpr_obj( "stat_box id", stat_box );

    /* 
     * get the number of static attributes
     */
 
    _VD_SEND_OBJ( stat_box, ACrg_collect.AClist_attribute(  msg, 0, 
							NULL, &nbStatAtt ) );
    __CheckRC( status, *msg, "message ACrg_collect.AClist_attribute", wrapup );

    __DBGpr_int( "Number of static attributes", nbStatAtt );

    /* 
     * get the dynamic box collector
     */

    status = _VD_SEND_MY( ACcpx.ACfind_temp_obj((IGRint *)msg,
                                                "userpara",
                                                &dyn_box ) );
    __CheckRC( status, *msg, "message ACcpx.ACfind_temp_obj", wrapup );

    __DBGpr_obj( "dyn_box id", dyn_box );

    /* 
     * get the number of dynamic attributes
     */

    _VD_SEND_OBJ( dyn_box, ACrg_collect.AClist_attribute(  msg, 0,
                                                        NULL, &nbDynAtt ) );
    __CheckRC( status, *msg, "message ACrg_collect.AClist_attribute", wrapup );

    __DBGpr_int( "Number of dynamic attributes", nbDynAtt );

    /*
     * allocate memory for the parameter list
     */

    *nbParams = nbStatAtt + nbDynAtt;

    __DBGpr_int( "Total number of Params", *nbParams );

    *parList = _MALLOC( *nbParams, struct ACrg_coll );

    if( !*parList )
        vd_$mem_fail( sts = status );

    /*
     * get the static attributes
     */

    status = _VD_SEND_OBJ( stat_box, ACrg_collect.AClist_attribute( msg,
								nbStatAtt,
								*parList,
								&nbStatAtt ) );
    __CheckRC( status, *msg, "message ACrg_collect.AClist_attribute", wrapup );

    /*
     * get the dynamic attributes
     */

    status = _VD_SEND_OBJ( dyn_box, ACrg_collect.AClist_attribute( 
							msg,
                                                        nbDynAtt,
                                                        &(*parList)[nbStatAtt],
                                                        &nbDynAtt ) );
    __CheckRC( status, *msg, "message ACrg_collect.AClist_attribute", wrapup );

    
    /*
     * delete the "mark_user" attribute, if present 
     */

    VDDelOneAttrib( *parList, nbParams, "mark_user" );

    __DBGpr_int( "Number of Params after deleting mark_user", *nbParams );

    /*
     * prefix the attribute names with the collector names 
     */

    for( i = 0 ; i < nbStatAtt ; i++ )
    {
        tempBuf[0] = '\0';
        sprintf( tempBuf, "%s:%s", FEET_STAT_BOX, (*parList)[i].name );
        strncpy( (*parList)[i].name, tempBuf, ATTR_NAME );
    }

    for( i = nbStatAtt ; i < *nbParams ; i++ )
    {
        tempBuf[0] = '\0';
        sprintf( tempBuf, "%s:%s", FEET_DYN_BOX, (*parList)[i].name );
        strncpy( (*parList)[i].name, tempBuf, ATTR_NAME );
    }

    __DBGpr_com( "Prefixed attribute names" );

    End
    return status;

wrapup :

    /* some error has occurred */

    _FREE( *parList );
    *parList = NULL;
    *nbParams = 0;

    End
    return status;
}

end implementation VDequipment;
