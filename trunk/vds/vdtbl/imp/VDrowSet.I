/* $Id: VDrowSet.I,v 1.1.1.1 2001/01/04 21:09:28 cvs Exp $  */
/*--------------------------------------------------------------------------
/* I/VDS
 *
 * File:        vdtbl/imp / VDrowSet.I
 *
 * Description:
 *	Implementation of the following methods  for VDdrwTblRow :
 *		VDgetParentObjectList
 *		VDgetParentSetId
 *		VDparentSetEmpty
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

#include "v_miscmacros.h"
#include "v_dbgmacros.h"
#include "v_datamacros.h"

#include "VDdrwlo.h"
#include "VDdrwtbl.h"

from VDdrwSet		import	VDgetSetObjects;

/*+me
 -------------------------------------------------------------------------
  Public Message VDgetParentObjectList

  Abstract
        This method returns the list of parent 3D objects connected indirectly
        through the associative set.

  Arguments
        IGRlong                 *msg      O     Return code
        IGRint                  *nbObjs   O     Number of objects
        struct GRobj_env        *list     O     List of objects.

  Notes/Remarks
        Memory must be allocated for list by the caller.

  Status/Return Code
      status == OM_S_SUCCESS    always ;
 -------------------------------------------------------------------------
-me*/

method  VDgetParentObjectList(  IGRlong                 *msg;
                                IGRint                  *nbObjs;
                                struct GRobj_env        *list )
{
    IGRlong             status = OM_S_SUCCESS;
    struct GRid		setId;

    SetProc( VDdrwTblRow.VDgetParentObjectList ); Begin
    *msg = MSSUCC;

    *nbObjs = 0;

    status =
    _VD_SEND_MY( VDdrwTblRow.ACfind_temp_obj( 	(int *)msg,
						"objs",
						&setId ) );
    __CheckRC( status, *msg, "VDdrwTblRow.ACfind_temp_obj", wrapup );

    status =
    _VD_SEND_OBJ( setId, VDdrwSet.VDgetSetObjects(	msg,
							nbObjs,
							list ) );
    __CheckRC( status, *msg, "VDdrwSet.VDgetSetObjects", wrapup );
    
wrapup :
    *msg = MSSUCC;

    End
    return OM_S_SUCCESS;
}


/*+me
 -------------------------------------------------------------------------
  Public Message VDgetParentSetId

  Abstract
        This method returns the GRid of the VDdrwSet parent object.

  Arguments
        IGRlong                 *msg      O     Return code
        struct GRid             *setId    O     GRid of set

  Notes/Remarks

  Status/Return Code
      status == OM_S_SUCCESS    if success;
 -------------------------------------------------------------------------
-me*/


method  VDgetParentSetId(       IGRlong         *msg;
                                struct GRid     *setId )
{
    IGRlong             status = OM_S_SUCCESS;

    SetProc( VDdrwTblRow.VDgetParentSetId ); Begin
    *msg = MSSUCC;

    status =
    _VD_SEND_MY( VDdrwTblRow.ACfind_temp_obj(   (int *)msg,
                                                "objs",
                                                setId ) );
    __CheckRC( status, *msg, "VDdrwTblRow.ACfind_temp_obj", wrapup );

wrapup :
    End
    return status;
}

/*+me
 -------------------------------------------------------------------------
  Public Message VDparentSetEmpty

  Abstract
        This message notifies the row that the parent set has become empty.
        This message will be sent by the parent set during its NDmove_to_root
        execution, if it finds that all its parents have been deleted.
        The method should do line-out handling.

  Arguments
        IGRlong         *msg      O     Return code

  Notes/Remarks

  Status/Return Code
      status == OM_S_SUCCESS    if success;
 -------------------------------------------------------------------------
-me*/

method  VDparentSetEmpty( IGRlong  *msg )
{
    IGRlong		status = OM_S_SUCCESS;

    SetProc( VDdrwTblRow.VDparentSetEmpty ); Begin

    *msg = MSSUCC;

    /* 
     * convert myself to a line-out row : set line out bit
     */

    me->rowInfo |= VD_ROW_LINEOUT;

    /* recompute the row */

    status = _VD_SEND_MY( VDdrwTblRow.VDconstructRow( msg ) );
    CheckRC( status, *msg );

    End
    return status;
}

end implementation VDdrwTblRow;

