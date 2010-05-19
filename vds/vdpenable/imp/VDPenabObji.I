/* $Id */

/* I/Vds
 *
 *
 * File:        vdpenable/imp/VDPenabObji.I
 *
 * Description:
 *      Implementation of the following methods for VDPenabObj 
 *
 * Dependencies:
 *
 * History:
 *
 *      09/26/95        MSM        Creation
 *
 */

class implementation VDPenabObj;

/*
#define vdsDEBUG
#define vdserrDEBUG
*/

#include <stdio.h>

#include "OMmacros.h"
#include "OMprimitives.h"
#include "exproto.h"
#include "exdef.h"
#include "exmacros.h"

#include "godef.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"

#include "v_miscmacros.h"
#include "v_dbgmacros.h"
#include "v_datamacros.h"

#include "VDPdef.h"

/*+me
  Public Message VDPinit

  Abstract
        This message initialises the Object created. 

  Algorithm
        1. Check for arguments.
        2. Set the size in instance data to 0.

  Arguments
        IGRlong          *msg     I/O    return message
                                         MSSUCC/MSFAIL.

  Notes/Remarks

  Examples

  Status/Return Code
      status == OM_S_SUCCESS    if success;
      status == OM_E_xxx        ...

-me*/
method VDPinit( IGRlong *msg )
{
    IGRlong		status = OM_S_SUCCESS;

    SetProc( VDPenabObj.VDPinit ); Begin
    if( !msg )
	return OM_E_INVARG;

    *msg = MSSUCC;

    om$vla_set_dimension( varray = me->enabObj, size = 0 );

    End
    return status;
}

/*+me
  Public Message VDPEnableObject

  Abstract
        This message adds the ObjId of the object to the enabled list. 

  Algorithm

  Arguments
        IGRlong          *msg     I/O    return message
                                         MSSUCC/MSFAIL.

  Notes/Remarks

  Examples

  Status/Return Code
      status == OM_S_SUCCESS    if success;
      status == OM_E_xxx        ...

-me*/
method VDPEnableObject( IGRlong *msg; GRobjid VDSobjid)
{
    IGRlong		status = OM_S_SUCCESS;
    IGRint		size;

    SetProc( VDPenabObj.VDPEnableObject ); Begin
    if( !msg )
	return  OM_E_INVARG;

    *msg = MSSUCC;

    size = om$dimension_of(varray = me->enabObj );
    __DBGpr_int(" Size of array: ", size );

    size++;
    status = om$vla_set_dimension( varray = me->enabObj, size = size );
    __CheckRC( status, 1, "om$vla_set_dimension", wrapup );

    me->enabObj[size-1] = VDSobjid;

wrapup:
    End
    return status;
}

/*+me
  Public Message VDPDisableObject

  Abstract
        This message deletes the ObjId of the object from the enabled list. 

  Algorithm

  Arguments
        IGRlong          *msg     I/O    return message
                                         MSSUCC/MSFAIL.

  Notes/Remarks

  Examples

  Status/Return Code
      status == OM_S_SUCCESS    if success;
      status == OM_E_xxx        ...

-me*/
method VDPDisableObject (IGRlong *msg; GRobjid VDSobjid )
{
    IGRlong		status = OM_S_SUCCESS;
    IGRint		i=0,size,
			row_to_delete;

    SetProc( VDPenabObj.VDPDisableObject ); Begin
    if( !msg )
	return  OM_E_INVARG;

    *msg = MSSUCC;

    size = om$dimension_of(varray = me->enabObj );
    __DBGpr_int(" Size of array: ", size );
    while( i < size && me->enabObj[i] != VDSobjid )
	i++;
    if( i != size )
    {
	row_to_delete = i;
	for ( i = row_to_delete; i < size-1; i++ )
	    me->enabObj[i] = me->enabObj[i+1];
	size--;
	status = om$vla_set_dimension( varray = me->enabObj, size = size );
	CheckRC( status, 1 );
    }
    End
    return status;
}

/*+me
  Public Message VDPIsObjEnabled

  Abstract
        This message verifies if an object is in the list or not

  Algorithm

  Arguments
        IGRlong          *msg     I/O    return message
                                         MSSUCC/MSFAIL.

  Notes/Remarks

  Examples

  Status/Return Code
      status == OM_S_SUCCESS    if success;
      status == OM_E_xxx        ...

-me*/
method VDPIsObjEnabled ( IGRlong *msg; GRobjid VDSobjid; IGRboolean *bEnabled)
{
    IGRlong		status = OM_S_SUCCESS;
    IGRint		i=0,size;

    SetProc( VDPenabObj.VDPIsObjEnabled ); Begin
    if( !msg )
	return  OM_E_INVARG;

    *bEnabled = FALSE;
    *msg = MSSUCC;
    size = om$dimension_of(varray = me->enabObj );
    __DBGpr_int(" Size of array: ", size );

    while( i < size && me->enabObj[i] != VDSobjid )
	i++;
    if( i != size )
	*bEnabled = TRUE;

    End
    return status;
}

method   VDPgetPMenabledList (  IGRlong         *msg;
				IGRint          *nbObjs;
				struct GRobj_env       **listObjs )
{
    IGRlong		status = OM_S_SUCCESS;
    IGRint		i=0,
			size = sizeof( struct GRmd_env );
    OMuword		curOs;
    struct GRmd_env	mod_env;

    SetProc( VDPenabObj.VDPgetPMenabledList ); Begin
    if( !msg )
	return  OM_E_INVARG;

    *nbObjs = 0;
    *listObjs = NULL;
    *msg = MSSUCC;

    *nbObjs = om$dimension_of(varray = me->enabObj );
    __DBGpr_int(" Size of array: ", *nbObjs );

    /* get the current module env */

    gr$get_module_env(  msg     = msg,
                        sizbuf  = &size,
                        buffer  = &mod_env );

    ex$get_cur_mod( osnum = &curOs );
    if ( *nbObjs )
	*listObjs = _MALLOC ( *nbObjs, struct GRobj_env );

    for( i =0; i < *nbObjs; i++ )
    {
	(*listObjs)[i].obj_id.objid = me->enabObj[i];
	(*listObjs)[i].obj_id.osnum = curOs;
	(*listObjs)[i].mod_env = mod_env;
    }

    End
    return status;
}

end implementation VDPenabObj;
