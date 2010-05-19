/* $Id: VDPtrUtil.I,v 1.1.1.1 2001/01/04 21:09:05 cvs Exp $  */

/* I/VDS
 *
 * File:       vdptrtbl/imp/VDPtrUtil.I
 *
 * Description:
 *
 * Dependencies:
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      -------------------------------------------
 *      09/02/98        Shailesh        Modified VDPGetTrTblId for SIR.
 *                                      refer TR # 179801453
 *      09/28/95        MSM             Creation
 */

class implementation VDPtrTbl;

/*
#define vdsDEBUG
#define vdserrDEBUG
*/

#include <stdio.h>
#include "string.h"

#include "OMmacros.h"
#include "OMprimitives.h"
#include "exproto.h"
#include "exdef.h"
#include "exmacros.h"

#include "v_miscmacros.h"
#include "v_dbgmacros.h"
#include "v_datamacros.h"

#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"

#include "VDPdef.h"
#include "VDPtrTbl.h"
extern WhichAim();

/*+fi
  Internal Function VDPGetTrTblId()

  Abstract
        This returns the Objid of Trans List.
	This also creates the object and initialises if not already created.

  Algorithm
	1. Initialise all variables.
        2. Get the Os Name ( File name ) for the OS.
        3. Check if PME_GLOBAL exists.
        4. If it does not exist create it.
        5. Check if trTbl Object exists.
        6. If it is not there Create it and initialise it.
        7. Add it to the directory system.
        8. return the trTbl ID.

  Notes/Remarks
      <Optional>

  Examples
      <Optional>

  Returns
        Successful Return               OM_S_SUCCESS.

-fi*/

IGRint  VDPGetTrTblId( IGRlong           *msg,
        	       struct GRid       *pTrTblId )
{
    IGRlong             status = OM_S_SUCCESS;
    struct GRid         DirId;
    IGRchar             DirName[DI_PATH_MAX],
			trTblName[DI_PATH_MAX];
    IGRboolean		trTblExist = FALSE;
    OMuword             curOs;
    extern GRclassid	OPP_VDPtrTbl_class_id;


    SetProc( VDPGetTrTblId ); Begin
    if( !msg ) return OM_E_INVARG;

    *msg = MSSUCC;
    pTrTblId->objid = NULL_OBJID;

    ex$get_cur_mod( osnum = &curOs );

    if ( WhichAim == PME ) {
    /* get directory path name */

    status = di$give_pathname(  osnum           = curOs,
                                pathname        = DirName );

    __CheckRC( status, 1, "di$give_pathname", wrapup );
    __DBGpr_str( "Path name", DirName );

    strcat( DirName, PME_GLOBAL_DIR );

    status =
    di$translate ( objname = DirName,
                   p_objid = &DirId.objid,
                   p_osnum = &DirId.osnum ) ;

    __DBGpr_obj( "Dir Id", DirId );

    /*A create PME_GLOBAL if it does not exist     */
    if ( status != DIR_S_SUCCESS )
    {
	DirId.objid = NULL_OBJID;

	status =
	di$mkdir( dirname = DirName,
		  p_dirid = &DirId.objid,
		  p_osnum = &DirId.osnum );

        __DBGpr_obj( "Dir Id", DirId );

         if( status != DIR_S_SUCCESS )
        {
                  /*A Cannot create directory*/
                  di$report_error( sts = status ) ;
                  goto    wrapup;
	}
    }
    else
    {
	sprintf( trTblName,"%s%s",DirName,PME_TRANS_LIST );
	__DBGpr_str( "Transaction Table name", trTblName );
	
	status =
	di$translate  ( objname = trTblName,
			p_objid = &pTrTblId->objid,
			p_osnum = &pTrTblId->osnum ) ;

	__DBGpr_obj( "Trans Tbl Id", *pTrTblId );

        switch( status ) 
	{
         case DIR_S_SUCCESS      :
            trTblExist = TRUE;
            break ;

         case DIR_W_NAME_NOT_FOUND       :
            trTblExist = FALSE ;
            break ;

         default              :
        /*|ERROR : in di$translate*/
            return status ;
         }
    }

    /* If List does not exist create the object and add it to NOD */

    if( !trTblExist )
    {
	pTrTblId->osnum = curOs;

        status =
        om$construct (  classid = OPP_VDPtrTbl_class_id,
                        p_objid = &(pTrTblId->objid),
                        osnum   = pTrTblId->osnum,
                        msg = message VDPtrTbl.VDPinit( msg) );
	__CheckRC( status, *msg,"om$construct", wrapup );
	__DBGpr_obj ( "List Id ", *pTrTblId );

	status =
	di$add_name ( objname = trTblName,
		      osnum   = pTrTblId->osnum,
		      objid   = pTrTblId->objid );
        __CheckRC( status, 1, "di$add_name", wrapup );
    }

    }  // End If PME


    if ( WhichAim() == SIR )
    {
     
    /* get directory path name */

    status = di$give_pathname(  osnum           = curOs,
                                pathname        = DirName );

    __CheckRC( status, 1, "di$give_pathname", wrapup );
    __DBGpr_str( "Path name", DirName );

    strcat( DirName, SIR_GLOBAL_DIR );

    status =
    di$translate ( objname = DirName,
                   p_objid = &DirId.objid,
                   p_osnum = &DirId.osnum ) ;

    __DBGpr_obj( "Dir Id", DirId );

    /*A create SIR_GLOBAL if it does not exist     */
    if ( status != DIR_S_SUCCESS )
    {
	DirId.objid = NULL_OBJID;

	status =
	di$mkdir( dirname = DirName,
		  p_dirid = &DirId.objid,
		  p_osnum = &DirId.osnum );

        __DBGpr_obj( "Dir Id", DirId );

         if( status != DIR_S_SUCCESS )
        {
                  /*A Cannot create directory*/
                  di$report_error( sts = status ) ;
                  goto    wrapup;
	}
    }
    else
    {
	sprintf( trTblName,"%s%s",DirName,SIR_TRANS_LIST );
	__DBGpr_str( "Transaction Table name", trTblName );
	
	status =
	di$translate  ( objname = trTblName,
			p_objid = &pTrTblId->objid,
			p_osnum = &pTrTblId->osnum ) ;

	__DBGpr_obj( "Trans Tbl Id", *pTrTblId );

        switch( status ) 
	{
         case DIR_S_SUCCESS      :
            trTblExist = TRUE;
            break ;

         case DIR_W_NAME_NOT_FOUND       :
            trTblExist = FALSE ;
            break ;

         default              :
        /*|ERROR : in di$translate*/
            return status ;
         }
    }

    /* If List does not exist create the object and add it to NOD */

    if( !trTblExist )
    {
	pTrTblId->osnum = curOs;

        status =
        om$construct (  classid = OPP_VDPtrTbl_class_id,
                        p_objid = &(pTrTblId->objid),
                        osnum   = pTrTblId->osnum,
                        msg = message VDPtrTbl.VDPinit( msg) );
	__CheckRC( status, *msg,"om$construct", wrapup );
	__DBGpr_obj ( "List Id ", *pTrTblId );

	status =
	di$add_name ( objname = trTblName,
		      osnum   = pTrTblId->osnum,
		      objid   = pTrTblId->objid );
        __CheckRC( status, 1, "di$add_name", wrapup );
    }


    } // Ens IF SIR

wrapup :

    End
    return status;
}

end implementation VDPtrTbl;
