/* $Id: VDrowAttrVal.I,v 1.2 2001/05/03 14:24:43 ylong Exp $  */
/*--------------------------------------------------------------------------
/* I/VDS
 *
 * File:        vdtbl/imp / VDrowAttrVal.I
 *
 * Description:
 *	Implementation of the following methods  for VDdrwTblRow :
 *		VDgetCurrentRowValues
 *
 * Dependencies:
 *
 * History:
 *      
 *	04/14/95	R. Manem	Creation
 *    	06/16/95        R. Manem        Integrated rg-collector functions
 *                                    	for unlimited string lengths
 *	07/19/95	R. Manem	Removed VDputOverriddenValues method
 *	05/02/01	ylong		TR5070
 * -------------------------------------------------------------------------
 */

class implementation VDdrwTblRow;

/*
#define vdsDEBUG
#define vdserrDEBUG
*/

#include <stdio.h>
#include <string.h>

#include "OMmacros.h"
#include "OMprimitives.h"

#include "v_miscmacros.h"
#include "v_dbgmacros.h"
#include "v_datamacros.h"

#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "gr.h"

#include "emsdef.h"
#include "EMSutlmacros.h"

#include "VDdrwlo.h"
#include "VDdrwlo_pr.h"

#include "vdcolldef.h"

from VDdrwTblHdr	import	VDgetTableInfo;

/*+me
 -------------------------------------------------------------------------
  Public Message VDgetCurrentRowValues

  Abstract
        This message will return the existing row values.  Useful during
        Modify Table command.

  Arguments
        IGRlong         *msg       O     Return code
        IGRint          *nbValues  O     Number of values in the list
        IGRint          **lineNos  O     list of line numbers
        IGRint          **colNos   O     Corresponding list of column numbers
        IGRchar         ***values  O     List of values

  Notes/Remarks
        The memory for each of the values will be allocated, as also the
        memory for the list of pointers to the values.  All double values
        will be converted to string type.
        Memory for lineNos and colNos array will be allocated.

  Status/Return Code
     status == OM_S_SUCCESS    if success;
 -------------------------------------------------------------------------
-me*/

method  VDgetCurrentRowValues(  IGRlong         *msg;
                                IGRint          *nbValues;
                                IGRint          **lineNos;
                                IGRint          **colNos;
                                IGRchar         ***values )
{
    IGRint			i, 
				len,	
				nbObjs = 0,
				nbTxt = 0,
				nbTotal = 0,
				ind;
    IGRshort			nbFixRecs, nbDatRecs,
				found;
    IGRchar			tblLoName[VD_DRWLO_CHR_IDFLD],
				attName[80],
				*datValue = NULL;
    OMuint			cnt = 0;
    IGRlong			status = OM_S_SUCCESS;
    IGRdouble			height;

    struct GRid			hdrId,
				myGrid,
				collId;
    struct GRobj_env		*lObjs = NULL;
    struct VDdrwlo_apifix	*fixRecs = NULL;
    struct VDdrwlo_data		*datRecs = NULL;
    struct VDdrwlo_qtyExp	qty;
    GRobjlink			obj;
    OM_S_CHANSELECT		toHdrChan;

    SetProc( VDdrwTblRow.VDgetCurrentRowValues ); Begin

    *msg = MSSUCC;

    if( !nbValues || !lineNos || !colNos || !values )
    {
	status = OM_E_ABORT;
	__DBGpr_com( "Invalid arguments" );
	goto wrapup;
    }

    myGrid.objid = my_id;
    myGrid.osnum = OM_Gw_current_OS;

    /* initialize output values */

    *nbValues = 0;
    *lineNos = NULL;
    *colNos = NULL;
    *values = NULL;

    /* select header channel */

    status = 
    om$make_chanselect(	channame	= "VDdrwTblRow.to_tblHdr",
			p_chanselect	= &toHdrChan );
    __CheckRC( status, 1, "selecting toHdrChan", wrapup );

    /* get the header id */

    status =
    om$get_channel_objects(	objid		= my_id,
				p_chanselect	= &toHdrChan,
				size		= 1,
				list		= &obj,
				count		= &cnt );
    __CheckRC( status, 1, "get_channel_objects", wrapup );

    __DBGpr_int( "Number of headers on channel", cnt );

    if( cnt != 1 )
    {
	status = OM_E_ABORT;
	__DBGpr_com( "Invalid count of header objects" );
	goto wrapup;
    }

    hdrId.objid = obj.S_objid;
    hdrId.osnum = obj.osnum;
    __DBGpr_obj( "Header object", hdrId );

    /* get the table layout name */

    status =
    _VD_SEND_OBJ( hdrId, VDdrwTblHdr.VDgetTableInfo(	msg,
							tblLoName,
							NULL, NULL ) );
    __CheckRC( status, *msg, "VDdrwTblHdr.VDgetTableInfo", wrapup );

    __DBGpr_str( "Table layout name ", tblLoName );

    /* get the collector id */

    collId.objid = NULL_OBJID ;
    status =
    _VD_SEND_MY( VDdrwTblRow.ACfind_temp_obj( (int *)msg, "coll", &collId ) );
    //__CheckRC( status, *msg, "VDdrwTblRow.ACfind_temp_obj", wrapup );
    CheckRC( status, *msg );

    __DBGpr_obj( "collector id ", collId );

    /* 
     * get the list of parent objects 
     */

    /* get number of objects */

    status =
    _VD_SEND_MY( VDdrwTblRow.VDgetParentObjectList(	msg,
							&nbObjs, 
							NULL ) );
    __CheckRC( status, *msg, "VDdrwTblRow.VDgetParentObjectList", wrapup );

    if( nbObjs )
    {
    	/* allocate memory */

	lObjs = _MALLOC( nbObjs, struct GRobj_env );
	if( !lObjs )
	    vd_$mem_fail( sts = status );

	status =
	_VD_SEND_MY( VDdrwTblRow.VDgetParentObjectList(	msg,
							&nbObjs,
							lObjs ) );
    	__CheckRC( status, *msg, "VDdrwTblRow.VDgetParentObjectList", wrapup );

#ifdef vdsDEBUG
	printf( "\n\tList of parent objects\n" );

	for( i = 0 ; i < nbObjs ; i++ )
	    printf( "\t\t# %d : [%d, %d]\n", i, lObjs[i].obj_id.objid,
						lObjs[i].obj_id.osnum );
#endif

    }
    
    /* get qty structure */

    status = _VD_SEND_MY( VDdrwTblRow.VDgetQtyExpr( msg, &qty ) );
    CheckRC( status, *msg );

    /* get the number of fixed components */

    status = VD_drwlo_gfix(	msg,
				tblLoName,
				VD_DRWLO_EN_DATA,
				0, 0,
				0, NULL,
				&height,
				&nbFixRecs,
				NULL );
    __CheckRC( status, *msg, "VD_drwlo_gfix", wrapup );
    __DBGpr_int( "Number of fixed components", nbFixRecs );

    if( nbFixRecs )
    {
    	/* allocate memory */

	fixRecs = _MALLOC( nbFixRecs, struct VDdrwlo_apifix );

	if( !fixRecs )
	    vd_$mem_fail( sts = status );

    	/* get the list of fixed components */

	status = VD_drwlo_gfix(	msg,
				tblLoName,
				VD_DRWLO_EN_DATA,
				0, 0,
				0, NULL,
				&height,
				&nbFixRecs,
				fixRecs );
    	__CheckRC( status, *msg, "VD_drwlo_gfix", wrapup );

    	/* retain texts only */

	for( i = 0 ; i < nbFixRecs ; i++ )
	    if( fixRecs[i].rectyp == VD_DRWLO_EN_TEXT )
		fixRecs[nbTxt++] = fixRecs[i];

	nbFixRecs = nbTxt;
	__DBGpr_int( "Number of fixed texts", nbFixRecs );
    }

    /* get the number of replaceable components */

    status = VD_drwlo_gdata(	msg,
				tblLoName,
				VD_DRWLO_EN_DATA,
				0, 0,
				0, NULL,
				&height,
				&nbDatRecs,
				NULL );
    __CheckRC( status, *msg, "VD_drwlo_gdata", wrapup );
    __DBGpr_int( "Number of data records ", nbDatRecs );

    if( nbDatRecs )
    {
    	/* allocate memory */

	datRecs = _MALLOC( nbDatRecs, struct VDdrwlo_data );

	if( !datRecs )
	    vd_$mem_fail( sts = status );

    	/* get the list of replaceable components */

	status = VD_drwlo_gdata(	msg,
					tblLoName,
					VD_DRWLO_EN_DATA,
					0, 0,
					0, NULL,
					&height,
					&nbDatRecs,
					datRecs );
    	__CheckRC( status, *msg, "VD_drwlo_gdata", wrapup );
    }

    nbTotal = nbFixRecs + nbDatRecs;
    __DBGpr_int( "Total number of values ", nbTotal );

    if( !nbTotal )
	goto wrapup;

    /* allocate memory for output lists */

    *lineNos = _MALLOC( nbTotal, IGRint );

    if( !(*lineNos) )
	vd_$mem_fail( sts = status );

    *colNos = _MALLOC( nbTotal, IGRint );

    if( !(*colNos) )
	vd_$mem_fail( sts = status );

    *values = _MALLOC( nbTotal, IGRchar * );

    if( !(*values) )
	vd_$mem_fail( sts = status );

    /* initialize pointers */

    for( i = 0 ; i < nbTotal ; i++ )
	(*values)[i] = NULL;

    /*
     * get fixed component values
     */

    ind = 0;

    for( i = 0 ; i < nbFixRecs ; i++ )
    {
	attName[0] = '\0';
	sprintf( attName, "%d %d", fixRecs[i].VD.tx.colno, 
					fixRecs[i].VD.tx.lineno );

	found = 0;
	len = strlen( fixRecs[i].VD.tx.Text ) + 1;

	_FREE( datValue );
	datValue = NULL;
        if( collId.objid != NULL_OBJID ){
	  status = VDdrw_getAttFromColl( msg, collId, attName, &datValue );
	  if( status & *msg & 1 )
	  {
	    found = 1;
	    len = strlen( datValue ) + 1;
	  }
	}

	/* allocate memory for output string value */

	(*values)[ind] = _MALLOC( len, IGRchar );

	if( !( (*values)[ind] ) )
	    vd_$mem_fail( sts = status );

	if( found )
	    strcpy( (*values)[ind], datValue );
	else
	    strcpy( (*values)[ind], fixRecs[i].VD.tx.Text );

	(*lineNos)[ind] = fixRecs[i].VD.tx.lineno;
	(*colNos)[ind] = fixRecs[i].VD.tx.colno;

	ind++;
    }

    /*
     * get replaceable component values
     */

    for( i = 0 ; i < nbDatRecs ; i++ )
    {
	/* first look if value is present in collector */

	attName[0] = '\0';
	sprintf( attName, "%d %d", datRecs[i].colno, 
					datRecs[i].lineno );

	_FREE( datValue );
	datValue = NULL;
	status = VDdrw_getAttFromColl( msg, collId, attName, &datValue );

	if( !(status & *msg & 1) )
	{
	    /* get field value */

	    _FREE( datValue );
	    datValue = NULL;
	    status = VDdrw_getFldValue(	msg,
					nbObjs,
					lObjs,
					datRecs[i],
					qty,
					&myGrid,
					&datValue );
	    __CheckRC( status, *msg, "VDdrw_getFldValue", wrapup );
	}

	if( !datValue || !(len = strlen( datValue) ) )
	    continue;

	__DBGpr_int( "Data value length", len );
	__DBGpr_str( "Data value", datValue );
     
	/* allocate memory for output string value */

	(*values)[ind] = _MALLOC( len+1, IGRchar );

	if( !( (*values)[ind] ) )
	    vd_$mem_fail( sts = status );

	strcpy( (*values)[ind], datValue );

	(*lineNos)[ind] = datRecs[i].lineno;
	(*colNos)[ind] = datRecs[i].colno;

	ind++;
    }

    /* 
     * if we have come this far, it means, everything is OK :
     * so set the return codes to success.  Otherwise, problems occur when
     * attributes are not found in the collector and there are only text fields
     * and no data fields.
     */

    status = OM_S_SUCCESS;
    *msg = MSSUCC;

    *nbValues = ind;
    __DBGpr_int( "Total number of values", *nbValues );

wrapup :

    _FREE( datValue );

    _FREE( fixRecs );
    _FREE( datRecs );
    _FREE( lObjs );

    End
    return status;
}

end implementation VDdrwTblRow;

