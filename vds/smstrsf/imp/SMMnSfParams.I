/* $Id: SMMnSfParams.I,v 1.1.1.1 2001/01/04 21:07:38 cvs Exp $  */

/* -------------------------------------------------------------------------
/* I/VDS
 *
 * File:        smstrsf/imp/ SMMnSfParams.I
 *
 * Description:
 *      Implementation of parameter method for Structural surfaces
 *
 *      Methods :
 *            VDgetParameters
 *
 * History:
 *      02/16/95       R. Manem              Creation
 *
 * -------------------------------------------------------------------------
 */


class implementation SMMainSf;

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
			nbAtt;
    IGRchar		tempBuf[256];
    struct GRid         attBox;

    SetProc( SMMainSf.VDgetParameters ); Begin

    __DBGpr_me();

    *msg = MSSUCC;

    *nbParams = 0;
    *parList = NULL;

    /* 
     * get the attribute box 
     */

    status = _VD_SEND_MY( ACcpx.ACfind_temp_obj((IGRint *)msg, 
						"att", 
						&attBox ) );
    __CheckRC( status, *msg, "message ACcpx.ACfind_temp_obj", wrapup );

    __DBGpr_obj( "attribute box id", attBox );

    /* 
     * get the number of attributes
     */
 
    _VD_SEND_OBJ( attBox, ACrg_collect.AClist_attribute(  msg, 0, 
							NULL, &nbAtt ) );
    __CheckRC( status, *msg, "message ACrg_collect.AClist_attribute", wrapup );

    __DBGpr_int( "Number of attributes", nbAtt );

    /*
     * allocate memory for the parameter list
     */

    *parList = _MALLOC( nbAtt, struct ACrg_coll );

    if( !*parList )
        vd_$mem_fail( sts = status );

    /*
     * get the collector attributes
     */

    status = _VD_SEND_OBJ( attBox, ACrg_collect.AClist_attribute( msg,
							nbAtt,
							*parList,
							&nbAtt ) );
    __CheckRC( status, *msg, "message ACrg_collect.AClist_attribute", wrapup );

    /*
     * prefix the attribute names with the collector names 
     */

    for( i = 0 ; i < nbAtt ; i++ )
    {
        tempBuf[0] = '\0';
        sprintf( tempBuf, "%s:%s", "attr", (*parList)[i].name );
        strncpy( (*parList)[i].name, tempBuf, ATTR_NAME );
    }

    *nbParams = nbAtt;

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

end implementation SMMainSf;
