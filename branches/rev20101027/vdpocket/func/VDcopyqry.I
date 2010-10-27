/* $Id: VDcopyqry.I,v 1.1.1.1 2001/01/04 21:09:00 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdpocket/func / VDcopyQry.I
 *
 * Description:
 *    This file include function used for copy a query to a new query and 
 *    change name A to A1 if A exists in the design file
 *
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDcopyqry.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:00  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.3  1995/09/20  14:42:18  pinnacle
# Replaced: vdpocket/func/VDcopyqry.I for:  by yzhu for vds.240
#
# Revision 1.2  1995/08/30  15:40:38  pinnacle
# Replaced: vdpocket/func/VDcopyqry.I for:  by yzhu for vds.240
#
# Revision 1.1  1995/07/13  18:29:50  pinnacle
# Created: vdpocket/func/VDcopyqry.I by yzhu for vds.240
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *      07/12/95        Yzhu            create
 * -------------------------------------------------------------------*/

class implementation Root;

#include <ctype.h>
#include <stdio.h>		/* FILE type */

#include "OMerrordef.h"
#include "OMmacros.h"
#include "OMminimum.h"
#include "igrtypedef.h"
#include "igetypedef.h"      /* must be behind OMminimum.h */
#include "igewindef.h"
#include "wl.h"
#include "igecolordef.h"
#include "igecolor.h"
#include "igrdef.h"
#include "igr.h"
#include "griodef.h"
#include "gr.h"
#include "igrdp.h"
#include "dp.h"
#include "go.h"
#include "ex.h"
#include "exdef.h"
#include "exmacros.h"
#include "grio.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "VDQYdef.h"

#include "v_miscmacros.h"
#include "v_dbgmacros.h"
#include "v_datamacros.h"
#include "vdmemmacros.h"
#include "VDmem.h"

#include "vdsupmacros.h"

#define MAXQRYNAME   80

from VDquery import VDsetPfxInfo, VDgive_query;

/*--------------------------------------------------------------------------
Function: VDcopyQry

Description:
    This function is used for copy a query to a new query and
    change name A to A1The new query is  in the design file. 
    old one could be design or ref file


Argument
    IGRlong *ms;                  O
    IGRchar *inQryName;           I
    struct GRid inQryId;          I
    struct GRid *outQryid;        O
    struct GRmd_env *outQryenv;   O
    IGRchar *outQryName           O
Return Status

    status	= OM_S_SUCCESS       if success	 
    status	= OM_E_ABORT	     if unsuccess 
   
-------------------------------------------------------------------------*/
IGRlong VDcopyQry(msg, inQryName, inQryId, outQryId, outQryenv, outQryName)
IGRlong 	*msg;
IGRchar 	*inQryName;
struct GRid 	inQryId;
struct GRid 	*outQryId;
struct GRmd_env *outQryenv;
IGRchar 	*outQryName;
{
IGRint			status = OM_S_SUCCESS ;
struct GRid             module;
struct GRid             *qry_id_list = NULL;
struct GRmd_env         *qry_env_list = NULL;
IGRchar                 **qry_name_list = NULL,
                        **qry_desc_list  = NULL;
struct GRid             qryId;
IGRlong                 NumberOfBytes,
                        BytesReceived;
IGRint                  Nflag1, i, num_qry;
IGRchar                 testName[80];
IGRchar 	        query[4096];
IGRint                  index;
IGRchar                 *select = NULL,
                        *where = NULL,
                        *comment = NULL ;

    SetProc( VDcopyQry); Begin
    *msg = MSSUCC;

    /* get current module */ 
    status =
    ex$get_cur_mod(  id      = &module.objid,
                     osnum   = &module.osnum );
    __CheckRC( status, 1, "ex$get_cur_mod", wrapup ); 

    /* get module env */
    NumberOfBytes = sizeof( struct GRmd_env);
    gr$get_module_env(      msg    = msg,
                            sizbuf = &NumberOfBytes,
                            buffer = outQryenv,
                            nret   = &BytesReceived);
    if(!(*msg&1)) {
             status = OM_E_ABORT; 
             goto wrapup;
    }
 

    /* get all queries including ref file */

    status = VDget_qry_list ( msg, &num_qry,  &qry_id_list, &qry_env_list,
                           &qry_name_list, &qry_desc_list  );
    __CheckRC( status, *msg, "VDget_qry_list", wrapup );

    if ( num_qry == 0 ) { 
       status = OM_E_ABORT;
       goto wrapup;
    }
    
    index = 1;
    Nflag1 = TRUE; 
    while(Nflag1 ){
         testName[0] = '\0'; 
         sprintf( testName, "%s_%d", inQryName,  index );
         Nflag1 = FALSE;
         for ( i = 0;  i< num_qry; i++) {
            if( !strcmp(qry_name_list[i],testName)) {
                   Nflag1 = TRUE;
                   index = index + 1;
                   break;
            } 
         }  
    } 
    /* set out query name */
    outQryName[0] = '\0';
    strcpy(outQryName, testName);

    /*
     * create the query.
     */
    status =
    om$send(msg = message VDquery.VDgive_query(
                                                msg,
                                                &select,
                                                &where,
                                                &comment ),
            targetid = inQryId.objid,
            targetos = inQryId.osnum,
            senderid = NULL_OBJID );
    __CheckRC( status, *msg, "VDquery.VDgive_queryVD", wrapup );

    query[0] = '\0';
    strcat( query, select);
    strcat( query, " ");
    strcat( query, where);
    
    qryId.objid = NULL_OBJID;
    qryId.osnum = module.osnum;

    VDqry_create_object( msg, &qryId, outQryName, query, comment );

    if( qryId.objid == NULL_OBJID && (! (*msg&1)) ){
                /*
                 * error in construction.
                 */
                UI_status( " Error during construction query object" );
                status = OM_E_ABORT;
                goto wrapup;
     }
     *outQryId = qryId;

wrapup:
    _FREE(select);  
    _FREE(where);  
    _FREE(comment);  
    _FREE( qry_id_list );
    _FREE( qry_env_list );
    VDfree_str_list ( qry_name_list, num_qry );
    VDfree_str_list ( qry_desc_list, num_qry );

    End
    return status;
} /* VDcopyQry */

end implementation Root;
