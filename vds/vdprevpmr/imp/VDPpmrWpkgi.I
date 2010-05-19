/* $Id */

/* I/Vds
 *
 *
 * File:        vdppmrrev/imp/VDPpmrWpkgi.I
 *
 * Description:
 *      Implementation of the following methods for VDPpmrWpkg 
 *
 * Dependencies:
 *
 * History:
 *
 *      09/26/95        MSM        Creation
 *
 */

class implementation VDPpmrWpkg;

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
        2. query the DM2 server for all the work packages for the given file

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
    IGRint		i, size=0,
			NotesLen=0;
    IGRchar		FileId[VDPOBID_LEN];
    struct VDPwrkPkg1	*workPkg=NULL;
    OMuword		curOs;

    SetProc( VDPpmrWpkg.VDPinit ); Begin
    if( !msg )
	return OM_E_INVARG;

    *msg = MSSUCC;

    ex$get_cur_mod( osnum = &curOs );

    /* Call DM2 database for Work packages */
    status = VDPGetFileId ( msg, curOs, FileId );
    __CheckRC ( status, *msg, "VDPGetFileId", wrapup );

    status = VDPgetPMRworkPackage ( msg, FileId, &size, &workPkg );
    __CheckRC ( status, *msg, "VDPgetPMRworkPackage", wrapup );

    __DBGpr_int ( "Size ", size );
    /* Initialise Dummy Data */

/*
    workPkg = _MALLOC( 2, struct VDPwrkPkg1 );
    size = 2;

    for ( i = 0; i < size; i++ )
    {
    	workPkg[i].objid = 1000*i +1000;
	workPkg[i].Notes = _MALLOC ( 81, IGRchar );
	sprintf( workPkg[i].Notes,"%s %d \0","This is not a long Note ", workPkg[i].objid );
	__DBGpr_str("Notes ...", workPkg[i].Notes );
    }

*/

    /* Allocate memory in the VLA */
    om$vla_set_dimension( varray = me->workPackage, size = size );

    /* Allocate memory for Notes and set the instance */
    NotesLen = 0;
    /* Compute total length of all notes */
    for ( i = 0; i < size; i++ )
	NotesLen += strlen(workPkg[i].Notes) +1;

    status = om$vla_set_dimension( varray = me->Notes, size = NotesLen );
    __CheckRC( status, 1, "vla_set_dimension", wrapup );

    NotesLen = 0;
    for ( i = 0; i < size; i++ )
    {
	me->workPackage[i].objid = workPkg[i].objid;
	__DBGpr_int( "NotesLen", NotesLen );
	me->workPackage[i].NotesIndex = NotesLen;
	strcpy( &me->Notes[NotesLen], workPkg[i].Notes );
	__DBGpr_int(" Objid :", me->workPackage[i].objid );
	__DBGpr_str(" Notes :", &me->Notes[NotesLen] );
	NotesLen += strlen(workPkg[i].Notes)+1;
    }

wrapup :
    for ( i =0; i< size; i++ )
	_FREE( workPkg[i].Notes );
    _FREE(workPkg);
    End
    return status;
}

/*+me
  Public Message VDPcheckWorkPackage

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
method VDPcheckWorkPackage( IGRlong *msg; struct VDPwrkPkg workPkg )
{
    IGRlong		status = OM_S_SUCCESS;
    IGRint		i, size;

    SetProc( VDPpmrWpkg.VDPcheckWorkPackage ); Begin
    if( !msg )
	return  OM_E_INVARG;

    *msg = MSSUCC;

    size = om$dimension_of(varray = me->workPackage );
    __DBGpr_int(" Size of array: ", size );

    i = 0;
    while ( me->workPackage[i].objid != workPkg.objid )
	i++;
    /* set the i th object to set */

    End
    return status;
}

/* The Caller has to free up both the work package Buffer and the 
   individual Notes */

method VDPgetWorkPkg( IGRlong *msg; IGRint *nbObjs; struct VDPwrkPkg1 **WorkPkgs )
{
    IGRlong		status = OM_S_SUCCESS;
    IGRint		i;

    SetProc( VDPpmrWpkg.VDPgetWorkPkg ); Begin
    if( !msg )
	return  OM_E_INVARG;

    *msg = MSSUCC;
    *WorkPkgs = NULL;

    *nbObjs = om$dimension_of(varray = me->workPackage );
    __DBGpr_int(" Size of array: ", *nbObjs );

    /* Allocate memory for the Work Package Structure */

    if ( *nbObjs )
    {
        *WorkPkgs = _MALLOC ( *nbObjs, struct VDPwrkPkg1 );
	if ( !*WorkPkgs )
	{
	    UI_status("Error in dynamic allocation of memory" );
	    return OM_E_NODYNMEM;
	}
    }

    /* Initialise the pointers to NULL */
    for ( i = 0; i < *nbObjs; i++ )
	(*WorkPkgs)[i].Notes = NULL;

    /* Allocate memory for Notes and set the instance */
    for ( i = 0; i < *nbObjs; i++ )
    {
	(*WorkPkgs)[i].objid = me->workPackage[i].objid;

	(*WorkPkgs)[i].Notes = _MALLOC ( strlen(&me->Notes[me->workPackage[i].NotesIndex]) +1, IGRchar );
	if ( !(*WorkPkgs)[i].Notes )
	{
	    UI_status ( "Error in dynamic allocation of memory" );
	    return OM_E_NODYNMEM;
	}
	strcpy((*WorkPkgs)[i].Notes, &me->Notes[me->workPackage[i].NotesIndex]);
	__DBGpr_int("Objid :", (*WorkPkgs)[i].objid );
	__DBGpr_str("Notes :", (*WorkPkgs)[i].Notes );
    }

    End
    return status;
}

end implementation VDPpmrWpkg;
