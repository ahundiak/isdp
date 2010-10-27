/* $Id: VDPversInfo.I,v 1.1.1.1 2001/01/04 21:09:05 cvs Exp $  */

/* I/VDS
 *
 * File:       vdptrtbl/imp/VDPverInfo.I
 *
 * Description:
 *
 * Dependencies:
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      -------------------------------------------
 *      11/03/95        MSM             Creation
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

#include "grdpbmacros.h"
#include "grdpbdef.h"

#include "ACdb_info.h"
#include "ACrg_collect.h"

#include "vdparmacros.h"
#include "VDPdef.h"
#include "VDPtrTbl.h"

#define PME_VERSIONED_ITEMS	":PME_VERSION"

from ACrg_collect import ACset_list_attribute;

IGRint	VDPsavePmeItemInfo( IGRlong *msg, struct GRid Obj )
{
    struct ACobj_info_1		ObjInfo;
    OMuword			curOs;
    IGRint			count, size, ret_size, nbAttr;
    IGRlong 			status=OM_S_SUCCESS;
    IGRchar             	DirName[DI_PATH_MAX],
				PathName[DI_PATH_MAX];
    IGRchar             	CollName[DI_PATH_MAX];
    struct GRid			DirId, CollId;
    struct GRmd_env		MdEnv;
    struct ACrg_coll		*Coll;

    SetProc ( VDPsavePmeItemInfo ); Begin
    *msg = MSSUCC;
    /* get the Object Type */

    count = 1;
    status = VdsGet_db_info( &Obj, &ObjInfo, count );
    /* Get DB info & quantity */

    /* get the corresponding Collector */
    status = VDPgetTemplateData( msg, ObjInfo.quantity, &nbAttr, &Coll );

    ex$get_cur_mod( osnum = &curOs );

    /* get directory path name */
    status = di$give_pathname(  osnum           = curOs,
                                pathname        = PathName );
    __CheckRC( status, 1, "di$give_pathname", wrapup );
    __DBGpr_str( "Path name", DirName );

    sprintf( DirName,"%s%s%s",PathName, PME_GLOBAL_DIR, PME_VERSIONED_ITEMS );

    status =
    di$translate ( objname = DirName,
		   p_objid = &DirId.objid,
		   p_osnum = &DirId.osnum );
    __DBGpr_obj( "Dir Id", DirId );

    /*A create PME_VERSION if it does not exist     */
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
	    /* Cannot create directory*/
	    di$report_error( sts = status ) ;
	    goto    wrapup;
        }
    }

    /* create an ACrg_collect Object */

    sprintf( CollName,"%s:%d", DirName, Obj.objid  );
    __DBGpr_str( "Collector name", CollName );

    CollId.objid = NULL_OBJID;

    status = VDgetVdCollId( msg, CollName, TRUE, TRUE, &CollId );
    __DBGpr_obj ( "Coll Id", CollId );

    /* Get the attribute values from the Component Object */
    
    size = sizeof( struct GRmd_env ) ;

    gr$get_module_env(  msg    = msg,
			sizbuf = &size,
			buffer = &MdEnv,
			nret   = &ret_size );

    status =
    vd$review_params( 	pMsg 		= msg,
			pComponent 	= &Obj,
			pMdEnv		= &MdEnv,
			pList		= Coll,
			NbParams	= nbAttr );
    CheckRC( status, *msg );

    status =
    _VD_SEND_OBJN( CollId, ACrg_collect.ACset_list_attribute(
							msg,
							nbAttr,
							Coll ) );
    CheckRC( status, *msg );

wrapup:
    _FREE(Coll);
    End
    return status;
}

end implementation VDPtrTbl;
