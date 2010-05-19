/* $Id: SMcompParams.I,v 1.1.1.1 2001/01/04 21:07:33 cvs Exp $  */

/* -------------------------------------------------------------------------
/* I/VDS
 *
 * File:        smcomp/imp/ SMcompParams.I
 *
 * Description:
 *      Implementation of parameter method for Compartment objects.
 *
 *      Methods :
 *            VDgetParameters
 *
 * History:
 *      02/16/95       R. Manem              Creation
 *
 * -------------------------------------------------------------------------
 */


class implementation SMcomp;

/*
#define vdsDEBUG
#define vdserrDEBUG
*/

#include "string.h"
#include "ACattrib.h"
#include "ACrg_collect.h"

#include "exmacros.h"
#include "vdparmacros.h"

#include "EMSmsgdef.h"
#include "v_miscmacros.h"
#include "v_datamacros.h"
#include "v_dbgmacros.h"

from ACrg_collect	import	AClist_attribute;
from expression		import	NDgive_value;

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
			nbUserDynAtt;
    IGRchar		tempBuf[256];
    IGRdouble		value = 0.0;
    struct GRid         userDynBox,
			myfoot;

    SetProc( SMcomp.VDgetParameters ); Begin

    __DBGpr_me();

    *msg = MSSUCC;

    *nbParams = 0;
    *parList = NULL;

    /* 
     * get the static attribute collector 
     */

    status = _VD_SEND_MY( ACcpx.ACfind_temp_obj((IGRint *)msg, 
						"user_dyn", 
						&userDynBox ) );
    __CheckRC( status, *msg, "message ACcpx.ACfind_temp_obj", wrapup );

    __DBGpr_obj( "user dyn box id", userDynBox );

    /* 
     * get the number of user and dynamic attributes
     */
 
    _VD_SEND_OBJ( userDynBox, ACrg_collect.AClist_attribute(  msg, 0, 
							NULL, &nbUserDynAtt ) );
    __CheckRC( status, *msg, "message ACrg_collect.AClist_attribute", wrapup );

    __DBGpr_int( "Number of attributes", nbUserDynAtt );

    /*
     * allocate memory for the parameter list
     * No of parameters = nb of attributes + 3 (volume, area, floor_area)
     */

    *parList = _MALLOC( (nbUserDynAtt+3), struct ACrg_coll );

    if( !*parList )
        vd_$mem_fail( sts = status );

    /*
     * get the collector attributes
     */

    status = _VD_SEND_OBJ( userDynBox, ACrg_collect.AClist_attribute( msg,
							nbUserDynAtt,
							*parList,
							&nbUserDynAtt ) );
    __CheckRC( status, *msg, "message ACrg_collect.AClist_attribute", wrapup );

    /*
     * prefix the attribute names with the collector names 
     */

    for( i = 0 ; i < nbUserDynAtt ; i++ )
    {
        tempBuf[0] = '\0';
        sprintf( tempBuf, "%s:%s", "attr", (*parList)[i].name );
        strncpy( (*parList)[i].name, tempBuf, ATTR_NAME );
    }

    *nbParams = nbUserDynAtt;

    /*
     * get "volume" foot
     */

    status = _VD_SEND_MY( NDmacro.ACreturn_foot( msg, "volume", &myfoot, 
						 NULL, NULL ) );
    CheckRC( status, *msg );
    __DBGpr_obj( "volume foot id", myfoot );

    if( status & *msg & 1 )
    {
        status = _VD_SEND_OBJ( myfoot, expression.NDgive_value( &value ) );
        __DBGpr_dbl( "volume expression value", value );

        if( status & 1)
        {
            strcpy( (*parList)[*nbParams].name, "volume" );
            (*parList)[*nbParams].desc.type = AC_ATTRIB_DOUBLE;
            (*parList)[*nbParams].desc.value.att_exp = value;
            (*nbParams)++;
        }
    }

    /*
     * get "area" foot
     */

    status = _VD_SEND_MY( NDmacro.ACreturn_foot( msg, "area", &myfoot,
                                                 NULL, NULL ) );
    CheckRC( status, *msg );
    __DBGpr_obj( "area foot id", myfoot );

    if( status & *msg & 1 )
    {
        status = _VD_SEND_OBJ( myfoot, expression.NDgive_value( &value ) );
        __DBGpr_dbl( "area expression value", value );

        if( status & 1)
        {
            strcpy( (*parList)[*nbParams].name, "area" );
            (*parList)[*nbParams].desc.type = AC_ATTRIB_DOUBLE;
            (*parList)[*nbParams].desc.value.att_exp = value;
            (*nbParams)++;
        }
    }

    /*
     * get "floor_area" foot
     */

    status = _VD_SEND_MY( NDmacro.ACreturn_foot( msg, "floor_area", &myfoot,
                                                 NULL, NULL ) );
    CheckRC( status, *msg );
    __DBGpr_obj( "floor_area foot id", myfoot );

    if( status & *msg & 1 )
    {
        status = _VD_SEND_OBJ( myfoot, expression.NDgive_value( &value ) );
        __DBGpr_dbl( "floor_area expression value", value );

        if( status & 1)
        {
            strcpy( (*parList)[*nbParams].name, "floor_area" );
            (*parList)[*nbParams].desc.type = AC_ATTRIB_DOUBLE;
            (*parList)[*nbParams].desc.value.att_exp = value;
            (*nbParams)++;
        }
    }

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

end implementation SMcomp;
