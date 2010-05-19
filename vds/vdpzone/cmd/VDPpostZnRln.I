/* $Id:*/

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdpzone /cmd
 *
 * Description:
 *
 *	1. VDPpostSpatialRelnship
 *	2. VDPplaceSpatialContext
 *
 * Dependencies:
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *
 *      10/4/95         MSM             creation
 *	10/3/96		MSM		FIX TR# 179603235.  Set osnum to osnum
 *					of the compartment located.
 * -------------------------------------------------------------------*/

class implementation VDPRoot;

/*
#define vdsDEBUG
#define vdserrDEBUG
*/

#include <stdio.h>
#include "string.h"

#include "OMerrordef.h"
#include "igrtypedef.h"
#include "igetypedef.h"

#include "OMmacros.h"
#include "OMprimitives.h"
#include "exproto.h"
#include "exdef.h"
#include "exmacros.h"

#include "VDSutil.h"

#include "v_miscmacros.h"
#include "v_dbgmacros.h"
#include "v_datamacros.h"

#include "ACrg_collect.h"
#include "ACattrib.h"

#include "msdef.h"

#include "VDPdm2.h"
#include "VDPtrTbl.h"
#include "VDPDatFrmDf.h"
#include "VDPEqpBuf.h"
#include "VDPdef.h"
#include "VDPzone.h"

from VDPenabObj import VDPIsObjEnabled;

extern GRclassid	OPP_SMcomp_class_id;

/*+fi
  Internal function VDPpostSpatialRelnship

  Abstract
  This function posts the relationship between a zone and the items contained
  in the zone.

-fi*/

int	VDPpostSpatialRelnship (   long			*msg,
				   IGRchar		ContextType,
				/*   IGRchar		*ContextId, */
				   struct GRid		GRobjId,
				   int			nbObjs,
				   struct GRobj_env	*Objs )
{
    int			i, inlen, code, index=0, ObjIndex, actualObjs,
			outlen, dstat, mfail;
    char		*inbuf=NULL;
    char		*outbuf, *errmsg=0;
    char		tmpstr[20], VDSobjid[10];
    char		FileId[VDPOBID_LEN];
    OMuword		curOs;
    struct GRid		EnabListId;
    IGRboolean		bFlag=FALSE;
    IGRlong		status = OM_S_SUCCESS;
    GRclassid		ClassId;

    SetProc ( VDPpostSpatialRelnship ); Begin

    *msg = MSSUCC;

    /* approximately 35 bytes per object */
    inbuf = _MALLOC ( 35 * nbObjs + 100, char ); 
    if ( inbuf == NULL )
    {
	UI_status ( "No Dynamic memory available" );
	return OM_E_ABORT;
    }

    ex$get_cur_mod ( osnum = &curOs );
    status = VDPGetFileId( msg, GRobjId.osnum, FileId );
    __CheckRC( status, *msg, "VDPGetFileId", wrapup );

    __DBGpr_str("FileId ", FileId );

    /* Add the code to the beginning of the buffer */

    if ( ContextType == 'Z' )
	code = VDP_POST_ZONERELN;
    else if (ContextType == 'C' )
	code = VDP_POST_COMPRELN;
    else
    {
	UI_status (" Unknown Context Type" );
	return OM_E_ABORT;
    }

    inlen = 0;

    memcpy( &inbuf[index], &code, sizeof(int));
    inlen += sizeof(int);
    index = inlen;

    tmpstr[0] = '\0';
    sprintf( tmpstr, "%d\0", GRobjId.objid );
    __DBGpr_str ( "Context GR ObjId ", tmpstr );

    strcpy( &inbuf[index], tmpstr );
    inlen += strlen(tmpstr) +1;
    index = inlen;

    strcpy( &inbuf[index], FileId );
    inlen += strlen(FileId) +1;
    index = inlen;
/*
    strcpy( &inbuf[index], ContextId );
    inlen += strlen(ContextId) +1;
    index = inlen;
*/

    memcpy( &inbuf[index], &nbObjs, sizeof(int));
    ObjIndex = index;
    inlen += sizeof(int);
    index = inlen;

    actualObjs = nbObjs;

    for ( i = 0; i < nbObjs; i++ )
    {
	om$get_classid ( objid = Objs[i].obj_id.objid,
			 osnum = Objs[i].obj_id.osnum,
			 p_classid = &ClassId );
	if ( om$is_ancestry_valid 
			( subclassid = ClassId,
			  superclassid = OPP_SMcomp_class_id ) == OM_S_SUCCESS)
	{
	    actualObjs--;
	    continue;
	}
	EnabListId.objid = NULL_OBJID;

	__DBGpr_obj ("Object ", Objs[i].obj_id );
	status = VDPGetEnabledListId ( msg, Objs[i].obj_id.osnum, &EnabListId);
	__DBGpr_obj( "Enabled List Id", EnabListId );
	if ( EnabListId.objid != NULL_OBJID )
	{
	    bFlag = FALSE;
	    status =
	    _VD_SEND_OBJN( EnabListId, VDPenabObj.VDPIsObjEnabled (
                                                        msg,
                                                        Objs[i].obj_id.objid,
                                                        &bFlag ));
	    CheckRC( status, *msg );
	}

	__DBGpr_int ( "bFlag ", bFlag );
	if( bFlag == TRUE )
	{

	    sprintf(VDSobjid,"%d\0", Objs[i].obj_id.objid );
	    __DBGpr_str ( "VDS objid ", VDSobjid );
	    
	    strcpy( &inbuf[index], VDSobjid );
	    inlen += strlen(VDSobjid) + 1;
	    index = inlen;

	    VDPGetFileId( msg, Objs[i].obj_id.osnum, FileId );
	    __DBGpr_str ( "File Id ", FileId );

	    strcpy( &inbuf[index], FileId );
	    inlen += strlen(FileId) +1;
	    index = inlen;
	}
	else
	    actualObjs--;
    }

    /* Copy the actual number of objects being sent */

    memcpy ( &inbuf[ObjIndex], &actualObjs, sizeof(int));

    dstat = POSTMAN_REQUEST_ON_CLIX (	inlen,
					inbuf,
					&outlen,
					&outbuf,
					&mfail,
					&errmsg );
    if(dstat || mfail) 
    {
	if(!errmsg || (errmsg && !errmsg[0]))
	    errmsg="No error msg but should be";
        if ( strlen(errmsg ) > 63 )
           errmsg[63] = '\0';
	UI_status( errmsg );
	_FREE ( inbuf );
        return OM_E_ABORT;
    }

    __DBGpr_int("dstat:", dstat );
    __DBGpr_int("mfail:", mfail );
    __DBGpr_str("errmsg:", errmsg );

wrapup :
    _FREE ( inbuf );
    End
    return OM_S_SUCCESS;
}

/*+fi
  Internal function VDPplaceSpatialContext

  Abstract
  This function reserves the selected occurrence in the Placement List in 
  PME database.

-fi*/

IGRint	VDPplaceSpatialContext ( long		*msg,
				 IGRchar	ContextType,
				 char		*ObId,
				 char		*Fileid,
				 int		VDSobjid )
{
    int			i, inlen, code, index=0,
			outlen, dstat, mfail;
    char		inbuf[100],tmpstr[20];
    char		*outbuf, *errmsg=0;

    SetProc ( VDPplaceSpatialContext ); Begin

    *msg = MSSUCC;

    for ( i=0; i<100; i++ ) inbuf[i]='\0';

    code = VDP_PLACE_ZONE;
    if ( ContextType == 'Z' )
	code = VDP_PLACE_ZONE;
    else if (ContextType == 'C' )
	code = VDP_PLACE_CMPT;

    inlen = 0;
    memcpy( &inbuf[index], &code, sizeof(int));
    inlen += sizeof(int);
    index = inlen;

    strcpy( &inbuf[index], ObId );
    inlen += strlen(ObId) + 1;
    index = inlen;

    tmpstr[0]='\0';
    sprintf(tmpstr,"%d",VDSobjid);
    strcpy( &inbuf[index], tmpstr );
    inlen += strlen(tmpstr) + 1;
    index = inlen;

    strcpy( &inbuf[index], Fileid );
    inlen += strlen(Fileid) + 1;
    index = inlen;

    dstat = POSTMAN_REQUEST_ON_CLIX (	inlen,
					inbuf,
					&outlen,
					&outbuf,
					&mfail,
					&errmsg );
    if(dstat || mfail) 
    {
	if(!errmsg || (errmsg && !errmsg[0]))
	    errmsg="No error msg but should be";
        if ( strlen(errmsg ) > 63 )
           errmsg[63] = '\0';
	UI_status( errmsg );
        return 0;
    }

   __DBGpr_int("dstat:", dstat );
   __DBGpr_int("mfail:", mfail );
   __DBGpr_str("errmsg:", errmsg );

    End
    return OM_S_SUCCESS;
}
				
end implementation VDPRoot;
