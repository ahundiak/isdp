/* $Id: VDtblXml.I,v 1.26 2002/05/11 02:59:23 ylong Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vds/vdtbl/xml/VDtblXml.I
 *
 * Description: save set Routines
 *
 * Dependencies: 
 *
 * Revision History:
 *      $Log: VDtblXml.I,v $
 *      Revision 1.26  2002/05/11 02:59:23  ylong
 *      *** empty log message ***
 *
 *      Revision 1.25  2002/05/02 18:15:17  ahundiak
 *      *** empty log message ***
 *
 *      Revision 1.24  2002/05/02 16:56:20  ahundiak
 *      *** empty log message ***
 *
 *      Revision 1.23  2002/05/02 16:50:00  ahundiak
 *      *** empty log message ***
 *
 *      Revision 1.22  2002/04/23 14:56:48  ylong
 *      *** empty log message ***
 *
 *      Revision 1.21  2002/04/23 14:10:41  ylong
 *      *** empty log message ***
 *
 *      Revision 1.20  2001/11/16 15:25:36  ahundiak
 *      ah
 *
 *      Revision 1.19  2001/10/26 22:05:54  ylong
 *      *** empty log message ***
 *
 *      Revision 1.18  2001/10/18 14:11:10  ahundiak
 *      ah
 *
 *      Revision 1.17  2001/10/17 15:12:35  ylong
 *      *** empty log message ***
 *
 *      Revision 1.16  2001/09/24 20:37:15  ylong
 *      *** empty log message ***
 *
 *      Revision 1.15  2001/09/19 19:18:58  ylong
 *      *** empty log message ***
 *
 *      Revision 1.14  2001/09/14 18:31:16  ylong
 *      *** empty log message ***
 *
 *      Revision 1.13  2001/09/11 20:39:19  ylong
 *      TR5581
 *
 *      Revision 1.12  2001/09/10 14:14:58  ylong
 *      *** empty log message ***
 *
 *      Revision 1.10  2001/09/07 18:15:20  ylong
 *      *** empty log message ***
 *
 *      Revision 1.9  2001/09/06 14:40:16  ahundiak
 *      ah
 *
 *      Revision 1.8  2001/08/31 22:09:27  ylong
 *      *** empty log message ***
 *
 *      Revision 1.7  2001/08/29 21:07:43  ylong
 *      *** empty log message ***
 *
 *      Revision 1.6  2001/08/22 18:19:51  ylong
 *      *** empty log message ***
 *
 *      Revision 1.5  2001/08/20 23:43:12  ylong
 *      *** empty log message ***
 *
 *      Revision 1.4  2001/08/20 17:20:35  ylong
 *      *** empty log message ***
 *
 *      Revision 1.3  2001/08/17 20:16:36  ylong
 *      *** empty log message ***
 *
 *      Revision 1.2  2001/08/17 16:20:16  ylong
 *      *** empty log message ***
 *
 *      Revision 1.1  2001/08/16 22:02:41  ylong
 *      Export table to xml
 *
 *
 * History:
 * MM/DD/YY	AUTHOR		DESCRIPTION
 * 07/18/01	ylong		Creation
 * 10/18/01     ah              Removed refs to cDom
 * 11/16/01     ah              Don't free pointers from VDctxGetTxtAtrPtr any more
 ***************************************************************************/
class implementation Root;

#include "VDtypedef.h"
#include "VDtblCmdDef.h"
#include "VDdrwtbl.h"
#include "v_dbgmacros.h"
#include "VDctx.h"
#include "VDobj.h"
#include "vdtr_macros.h"
#include "AS_status.h"
#include "VDmem.h"
#include "dpstruct.h"
#include "vdrefmacros.h"
#include "VDdrwlo.h"
#include "vdtblmacros.h"
#include "VDtblXml.h"
#include "v_drwprocess.h" 

from	GRvg		import	GRputname;
from	VDbuf		import	vdbufSetData;
from	VDdrwTbl	import	VDgetTableLayoutName;
from	VDdrwTbl	import	VDgetTableType;
from	VDdrwTbl	import	VDgetAdsTblName;
from	VDdrwTbl	import	VDgetTableParts;
from	VDdrwTblHdr	import	VDgetCsLocation;
from	VDdrwTblHdr	import	VDgetRowInfo;
from	VDdrwTblHdr	import	VDgetConstructInfo;
from	VDdrwTblHdr	import	VDgetTableInfo;
from	VDdrwTblHdr	import	VDrowNoToGRid;
from	VDdrwTblRow	import	VDgetQtyExpr;
from	VDdrwTblRow	import	VDisRowLinedOut;
from	VDdrwTblRow	import	VDisUserDefinedRow;
from	VDdrwTblRow	import	VDgetItemNumber;
from	VDdrwTblRow	import	VDgetParentObjectList;
from	VDdrwTblRow	import	VDgetCurrentRowValues;
from	VDdrwTblRow	import	ACfind_temp_obj; 
from	VDdrwTblRow	import	VDgetTableHeader;
from	VDdrwlo		import	VDdrwlo_gfld;
from	VDdrwlo		import	VDdrwlo_xhtf;
from	VDdrwlo		import	VDdrwlo_xfld;
from	VDdrwlo		import	VDdrwlo_ghtf;

/*
 * Global flag to indicate if user overwritten values should be kept
 * during "Modify Table"
 */
%safe
static	IGRshort	TblUserValueFlag = 0;
static	struct	GRid	XmlTblID = { (IGRushort) -1, (IGRuint) -1 };
static	VDxtblFldOpt	*flds;
%endsafe


/*
 * Global xml table used to save table and then recover user's values
 */

/*--------------------------------------------------------------------------- 
 * 
 */ 
IGRshort VDtblSetUserValueFlag ()
{
	TblUserValueFlag = !TblUserValueFlag;
	if( TblUserValueFlag ) {
		UI_status( "User Value Flag is ON for Modify Table");
	}
	else {
		UI_status( "User Value Flag is OFF for Modify Table");
	}

	return TblUserValueFlag;
}

/*--------------------------------------------------------------------------- 
 * 
 */ 
IGRshort VDtblGetUserValueFlag ()
{
	return TblUserValueFlag;
}

/*--------------------------------------------------------------------------- 
 * 
 */ 
IGRlong	VDtblXmlGetObjFromXnode (	TGRid	*xnodeID,	// in
					TGRid	*objID )	// out
{
	IGRlong		status = 0, msg ;
	IGRchab		buf, fileName;
	IGRchar		*ptr = NULL;
	
	if( !xnodeID || !objID ) goto wrapup;
	objID->objid = NULL_OBJID;

	buf[0] = '\0';
	VDctxGetTxtAtr ( xnodeID, VD_XTBL_ATTR_TXT_OBJID, buf );
	if( buf[0] == '\0' ) goto wrapup;

	strcpy( fileName, buf );
	if( !(ptr = strchr( fileName, ':') ) ) goto wrapup;
	*ptr = '\0';
	
	VDosGetFileNameOS ( fileName, &objID->osnum );
	if( objID->osnum == OM_K_NOT_AN_OS ) goto wrapup;

	objID->objid = atoi( ++ptr );

	status = 1;
wrapup:
	return status;
}

/*---------------------------------------------------------------------------
 *
 */
IGRlong VDtblXmlDelXmlTblID()
{
	IGRlong		status = 0;

	if( XmlTblID.objid != NULL_OBJID ) {
		VDctxDeleteNode( &XmlTblID );
		XmlTblID.objid = NULL_OBJID;
	}
	
	status = 1;
wrapup:
	return status;
}

/*---------------------------------------------------------------------------
 *
 */
IGRlong VDtblXmlGetXmlTblID( TGRid	*xtblID )
{
	IGRlong		status = 0;

	*xtblID = XmlTblID;
	
	status = 1;
wrapup:
	return status;
}


/*---------------------------------------------------------------------------
 *
 */
IGRlong VDtblXmlSetXmlTblID (	TGRid	*tblID,
				IGRchar	*xBuf,
				IGRchar	*xFile,
				TGRid	*xtblID )
{
	IGRlong		status = 0, msg ;
	TGRid		xID;

	if( (!tblID || tblID->objid == NULL_OBJID) &&
	    (!xBuf) && (!xFile) ) goto wrapup;

	xID.objid = NULL_OBJID;
	if( xtblID ) xtblID->objid = NULL_OBJID;

	if( tblID && tblID->objid != NULL_OBJID) {
		status =  vd$xmltbl_create (	tblID	= tblID,
						xtreeID	= &xID );
	}
	if( xBuf ) {
		VDxdomCreateTreeFromXmlBuf( xBuf, &xID );
	}
	if( xFile ) {
		VDxdomCreateTreeFromXmlFile( xFile, &xID );
	}

	if( (status&1) && xID.objid != NULL_OBJID ) {
		if( XmlTblID.objid != NULL_OBJID ) {
			VDctxDeleteNode( &XmlTblID );
		}
		XmlTblID = xID;
		if( xtblID ) *xtblID = xID;
	}
	else {
		goto wrapup;
	}

	status = 1;
wrapup:
	return status;
}

/*---------------------------------------------------------------------------
 *
 */
IGRlong VDtblXmlGetRowDataFromXml(	TGRid	*xtblID,
					IGRchar	*xmlBuf,
					IGRchar	*xmlFile,
					IGRchar	*separator,
					IGRint	rowInd,
					IGRchar	***rowBuf,
					IGRint	*nbRows,
					IGRint	colInd,
					IGRchar	**colBuf,
					IGRint	*nbCols )
{
	IGRlong		status = 0, msg ;
	IGRint		MAXLEN = 128, len, ind, cnt = 0;
	IGRint		colNo, rowCnt = 0;
	IGRint		i, j, k;
	TGRid		xtreeID;
	IGRchar		sep[80];
	IGRchar		**data, *ptr = NULL;
	IGRchar		*value = NULL; /* don't free it, internal pointer */
	IGRchab		buf;
	TVDctxNodeList	rowList;
	TVDctxNodeList	cellList;
	TVDctxNodeList	collList;
	

	VDctxInitNodeList(&rowList);
	VDctxInitNodeList(&collList);

	if( rowBuf ) *rowBuf = NULL;
	if( nbRows ) *nbRows = 0;
	if( colBuf ) *colBuf = NULL;
	if( nbCols ) *nbCols = 0;

	if( !xtblID && !xmlBuf && !xmlFile ) goto wrapup;

	if( (rowBuf && !nbRows) || (!rowBuf && nbRows) ) {
		printf("Input to vd$xmltbl_getRowData is not appropriate\n");
		goto wrapup;
	}
	if( (colBuf && !nbCols) || (!colBuf && nbCols) ) {
		printf("Input to vd$xmltbl_getRowData is not appropriate\n");
		goto wrapup;
	}

	if( separator ) strcpy ( sep, separator );
	else		strcpy( sep, "|" );

	xtreeID.objid = NULL_OBJID;

	if( xtblID && xtblID->objid != NULL_OBJID ) {
		xtreeID = *xtblID;
	}
	else if( xmlBuf && xmlBuf[0] != '\0' ) {
		VDxdomCreateTreeFromXmlBuf( xmlBuf, &xtreeID );
	}
	else if( xmlFile && xmlFile[0] != '\0' ) {
		VDxdomCreateTreeFromXmlFile( xmlFile, &xtreeID );
	}

	if( xtreeID.objid == NULL_OBJID ) goto wrapup;

	VDctxGetNodeListByType ( &xtreeID, VD_XTBL_NODE_TYPE_COL, &collList );
	if( collList.cnt == 0 ) goto wrapup;

	if( colBuf ) 
	{
		ind = 0;

	 	/* default to export all columns */
		if( colInd < 0 ) { 
			cnt = collList.cnt;
		}
		else if( colInd >= 0 && colInd < collList.cnt ) {
			cnt = 1;
			ind = colInd;
		}
		else {
			cnt = 0;
		}

		len = 0;
		for( i = ind; i < (ind + cnt); i++ ) {
			VDctxGetTxtAtr( &collList.listIDs[i], 
					VD_XTBL_COL_ATTR_TXT_TITLE, 
					buf);
			len += (strlen( buf ) + strlen( sep ) + 4 );
		}

		if( len > 0 ) {
			*colBuf = _CALLOC( len, IGRchar );
			if( !colBuf ) goto wrapup;
		}
		
		for( i = 0; i < cnt; i++ ) {
			VDctxGetTxtAtr( &collList.listIDs[i+ind], 
					VD_XTBL_COL_ATTR_TXT_TITLE, 
					buf);
			VD_stripString(buf);
			if( buf[0] == '\0' ) strcpy( buf, " " );
			
			strcat( *colBuf, buf );
			if( i < (cnt-1) )strcat( *colBuf, sep );
		}

		if( nbCols ) *nbCols = cnt;
	}

	if( !rowBuf ) goto wrapup;

	VDctxGetNodeListByType ( &xtreeID, VD_XTBL_NODE_TYPE_ROW, &rowList );
	if( rowList.cnt == 0 ) goto wrapup;

	if( rowBuf ) 
	{
		ind = 0;

		/* default to export all rows */
		if( rowInd < 0 ) {
			cnt = rowList.cnt;
		}
		/* export specific row by index */
		else if( rowInd >= 0 && rowInd < rowList.cnt ) {
			cnt = 1;
			ind = rowInd;
		}
		/* index is beyond the max row number */
		else {
			cnt = 0;
		}

		if( cnt > 0 ) {
			data = _CALLOC( cnt, IGRchar * );
			if( !data ) goto wrapup;
			for( i = 0; i < cnt; i++ ) data[i] = NULL;
		}

		for( i = 0; i < cnt; i++ ) {
		    VDctxInitNodeList(&cellList);
		    VDctxGetNodeListByType(	&rowList.listIDs[i+ind], 
						VD_XTBL_NODE_TYPE_CELL, 
						&cellList );
		    if( cellList.cnt < 1 ) {
			continue;
		    }

		    len = collList.cnt*( strlen( sep ) + 1 ) ;
		    for( j = 0; j < cellList.cnt; j++ ) {
		    	VDctxGetTxtAtrPtr( &cellList.listIDs[j], 
		    			VD_XTBL_CELL_ATTR_TXT_VALUE, 
		    			&value);
		    	len += ( strlen( value ) + 1 );
		    }


		    data[rowCnt] = _CALLOC( len, IGRchar );
		    if( !data[rowCnt] ) goto wrapup;

		    data[rowCnt][0] = '\0';
		    for( k = 1; k <= collList.cnt; k++ ) {
		    	for( j = 0; j < cellList.cnt; j++ ) {
		    		VDctxGetTxtAtr( &cellList.listIDs[j], 
		    			VD_XTBL_CELL_ATTR_INT_COLNO, 
		    			buf);

		    		colNo = atoi(buf) ;
		    		if( k == colNo ) {
		    			VDctxGetTxtAtrPtr(&cellList.listIDs[j], 
		    				VD_XTBL_CELL_ATTR_TXT_VALUE, 
		    				&value);
		    			VD_stripString(value);
		    			strcat( data[rowCnt], value );
		    			break;
		    		}
		    	}
		    	if( j == cellList.cnt ) {
		    		strcat( data[rowCnt], " " );
		    	}
		    	if( k < collList.cnt ) strcat( data[rowCnt], sep );
		    }

		    VDctxFreeNodeList(&cellList);
		    rowCnt++;
		}

		*rowBuf = data;
		if( nbRows ) *nbRows = rowCnt;
	}
	

	status = 1;
wrapup:
	if( !rowBuf ) _LOOPFREE( data, rowCnt );
	VDctxFreeNodeList(&rowList);
	VDctxFreeNodeList(&collList);
	return status;
}

/*--------------------------------------------------------------------------- 
 * 
 */ 
IGRlong	VDtblXmlCrTblNode (	TGRid	*tblID,
				IGRchar	*desc,
				TGRid	*xtblID )
{
	IGRlong		status = 0, msg ;
	GRname		tblName;
	IGRchab		idBuf, nameBuf, descBuf, typBuf, procBuf;
	IGRchab		tblFile;
	TGRid		xtreeID;
	

	if( !xtblID || !tblID || tblID->objid == NULL_OBJID ) goto wrapup;

	VDctxCreateXdomTree(VD_XTBL_NODE_TYPE_TBL, NULL, &xtreeID);

	*idBuf = *nameBuf = *descBuf = *typBuf = *procBuf = 0;


	/*
	 * Get all attributes needed
	 */

	VDosGetFileName(tblID->osnum, tblFile);
	sprintf(idBuf, "%s:%d", tblFile, tblID->objid);

	vdobj$Get (	objID	= tblID,
			objName	= nameBuf );

	descBuf[0] = '\0';
	if( desc ) strcpy( descBuf, desc );

	/*
	 * Set attibutes
	 */
	VDctxAppTxtAtr(&xtreeID, VD_XTBL_TBL_ATTR_TXT_TBLID, idBuf);
	VDctxAppTxtAtr(&xtreeID, VD_XTBL_TBL_ATTR_TXT_NAME,  nameBuf);
	VDctxAppTxtAtr(&xtreeID, VD_XTBL_TBL_ATTR_TXT_DESC,  descBuf);

	*xtblID = xtreeID;

	status = 1;
wrapup:
	return status;
}



/*---------------------------------------------------------------------------
 *
 */
IGRlong VDtblXmlCrLayoutNode (	TGRid	*tblID,
				TGRid	*xtblID,
				TGRid	*xloID )
{
	IGRlong		status = 0, msg ;
	IGRshort	i, nbLayouts = 0;
	TGRid		xID;
	IGRchab		adsName, loName, loType, loDesc;
	IGRchar		(*loDescs)[VD_DRWLO_CHR_DESC] = NULL,
			(*loNames)[VD_DRWLO_CHR_IDFLD] = NULL;
	
	if( !tblID || tblID->objid == NULL_OBJID ) {
		goto wrapup;
	}

	*loName = 0;
	*loType = 0;
	*loDesc = 0;
	*adsName = 0;

	/*
	 * Create layout node
	 */
	VDctxCreateNode(xtblID, VD_XTBL_NODE_TYPE_LO, NULL, &xID);

	/*
	 * Get info from table
	 */

	/* get layout name */
	status = om$send(msg	 = message VDdrwTbl.VDgetTableLayoutName (
							&msg,
							loName ),
			senderid = NULL_OBJID,
			targetid = tblID->objid,
			targetos = tblID->osnum);
	CheckRC( status, msg );

	/* get layout type */
	status = om$send(msg     = message VDdrwTbl.VDgetTableType (
							&msg,
							loType ),
			senderid = NULL_OBJID,
			targetid = tblID->objid,
			targetos = tblID->osnum);
	CheckRC( status, msg );

	/* get ads table name */
	status = om$send(msg     = message VDdrwTbl.VDgetAdsTblName (
							&msg,
							adsName ),
			senderid = NULL_OBJID,
			targetid = tblID->objid,
			targetos = tblID->osnum);
	CheckRC( status, msg );


	/* get layout description */

	status = vd$tbldlo_idx (	msg     = &msg,
					status  = status,
                                        osnum   = tblID->osnum,
                                        typin   = loType,
                                        p_count = &nbLayouts);
	CheckRC( status, msg );

	if( (status&msg&1) && nbLayouts > 0 ) {
		loNames = (IGRchar (*)[VD_DRWLO_CHR_IDFLD]) malloc(
			sizeof(IGRchar) * VD_DRWLO_CHR_IDFLD * nbLayouts );
		loDescs = (IGRchar (*)[VD_DRWLO_CHR_DESC]) malloc(
			sizeof(IGRchar) * VD_DRWLO_CHR_DESC * nbLayouts );
	}

	if( loNames != NULL && loDescs != NULL ) {
		status = vd$tbldlo_idx (	msg	= &msg,
						status	= status,
						osnum	= tblID->osnum,
						typin	= loType,
						p_nams	= ((char *)loNames),
						p_desc	= ((char *)loDescs),
						p_count	= &nbLayouts);
		for ( i = 0; i < nbLayouts; i++ ) {
			if( !strcmp( loName, loNames[i] ) ) {
				strcpy( loDesc, loDescs[i] );
				break;
			}
		}
	}

	/*
	 * Add attribute to layout node
	 */
	VDctxAppTxtAtr( &xID, VD_XTBL_LO_ATTR_TXT_LAYOUT, loName );
	VDctxAppTxtAtr( &xID, VD_XTBL_LO_ATTR_TXT_TBLTYP, loType );
	VDctxAppTxtAtr( &xID, VD_XTBL_LO_ATTR_TXT_DESC,   loDesc );
	VDctxAppTxtAtr( &xID, VD_XTBL_LO_ATTR_TXT_ADS,    adsName );

	if( xloID ) *xloID = xID;

	status = 1;
wrapup:
	_FREE( loNames );
	_FREE( loDescs );
	return status;
}

/*---------------------------------------------------------------------------
 *
 */
IGRlong	VDtblXmlCrHdrNode ( 	TGRid	*hdrID, 
				TGRid	*xtblSet, 
				TGRid	*xhdrID )
{
	IGRlong		status = 0;
	GRname		fileName;
	IGRchab		buf;
	TGRid		xID;

	if( !hdrID   || hdrID->objid   == NULL_OBJID )
	{
		goto wrapup;
	}

	/*
	 * Create header node
	 */
	VDctxCreateNode( xtblSet, VD_XTBL_NODE_TYPE_HDR, NULL, &xID );
	if( xID.objid == NULL_OBJID ) goto wrapup;

	/*
	 * Add attibutes
	 */
	VDosGetFileName ( hdrID->osnum, fileName );
	sprintf( buf, "%s:%d", fileName, hdrID->objid );
	VDctxAppTxtAtr( &xID, VD_XTBL_HDR_ATTR_TXT_HDRID, buf );
	
	status = 1;
wrapup:
	return status;
}


/*---------------------------------------------------------------------------
 *
 */
static IGRint	VDtblXml_sortHtfByCol(	struct VDdrwlo_db_htf	*e1,
					struct VDdrwlo_db_htf	*e2 )
{
	IGRint	ret = 0;

	ret = e1->align_bot - e2->align_bot;

	if( !ret ) {
		return ( e1->align_lcol - e2->align_lcol );
	}
	else {
		return ret;
	}
}


/*---------------------------------------------------------------------------
 *
 */
IGRlong	VDtblXmlCrLoColNodes (	TGRid	*tblID, 
				TGRid	*xloID,
				TGRid	**xcolIDs,
				IGRint	*nbCols)
{
	IGRlong		status = 0, msg;
	IGRint		i, j;
	IGRshort	count      = 0,
			nbDatRecs  = 0,
			nbHdrRecs  = 0,
			nbHdrFlds  = 0;

	IGRchab		buf;
	IGRchar		tblLoName[VD_DRWLO_CHR_IDFLD];
	VDosnum		osnum;

	IGRdouble	height;
	TGRid		LGRID,
			*xIDs = NULL;

	struct	VDdrwlo_data	*datRecs = NULL;
	struct	VDdrwlo_db_fld	*recs    = NULL;
	struct	VDdrwlo_db_fld	*hdrRecs = NULL;
	struct	VDdrwlo_db_htf	*hdrFlds = NULL;

	if( !tblID || tblID->objid == NULL_OBJID ) goto wrapup;
	if( nbCols ) *nbCols = 0;

	/*
	 * Get table layout name
	 */
	status =
	om$send (msg = message VDdrwTbl.VDgetTableLayoutName (
                        			&msg, 
						tblLoName ),
		senderid = NULL_OBJID,
		targetid = tblID->objid,
		targetos = tblID->osnum);
	__CheckRC( status, msg, "VDdrwTbl.VDgetTableLayoutName", wrapup );

	/*
	 * Get layout object id
	 */
	ex$get_cur_mod(osnum = &osnum);

	vd$tbldlo_old (	msg = &msg,
                 	osnum = osnum,
                 	tabnam = tblLoName,
                 	GRid = &LGRID);
	if( !(msg&1) ) goto wrapup;

	/*
	 * Get data components
	 */

	status = VD_drwlo_gdata (	&msg,
					tblLoName,
					VD_DRWLO_EN_DATA,
					(double)0,
					(double)0, 
					(short)0,
					NULL,
					&height,
					&nbDatRecs,
					NULL );
	__CheckRC( status, msg, "VD_drwlo_gdata", wrapup );

	if( nbDatRecs )
	{
		/* allocate memory */

		datRecs = _MALLOC( nbDatRecs, struct VDdrwlo_data );

		if( !datRecs ) goto wrapup;

		/* get the list of replaceable components */

		status = VD_drwlo_gdata(&msg,
					tblLoName,
					VD_DRWLO_EN_DATA,
					(double)0,
					(double)0, 
					(short)0,
					NULL,
					&height,
					&nbDatRecs,
					datRecs );
		__CheckRC( status, msg, "VD_drwlo_gdata", wrapup );
	}


	/*
	 * Get table header field ids, including field postions from return
	 */

	status =
	om$send(msg	 = message VDdrwlo.VDdrwlo_ghtf (
        				 	&msg,
						VD_DRWLO_EN_HEADER,
						NULL,
						&nbHdrFlds,
						NULL),
		senderid = NULL_OBJID,
		targetid = LGRID.objid,
		targetos = LGRID.osnum );
	__CheckRC( status, msg, "VDdrwlo.VDdrwlo_gfld", wrapup );

	if( nbHdrFlds ) {
		hdrFlds = _MALLOC( nbHdrFlds, struct VDdrwlo_db_htf);
		if( !hdrFlds ) goto wrapup;

		status =
		om$send(msg	 = message VDdrwlo.VDdrwlo_ghtf (
       	 				 	&msg,
						VD_DRWLO_EN_HEADER,
						NULL,
						&nbHdrFlds,
						hdrFlds),
			senderid = NULL_OBJID,
			targetid = LGRID.objid,
			targetos = LGRID.osnum );
		__CheckRC( status, msg, "VDdrwlo.VDdrwlo_gfld", wrapup );
	}

	/*
	 * Sort htf in bottom line order
	 */
	qsort( (char*)hdrFlds, 
		nbHdrFlds, 
		sizeof(struct VDdrwlo_db_htf), 
		(int(*)())VDtblXml_sortHtfByCol); 

	/*
	 * discard any fields with higher bottom lines
	 */

	count = nbHdrFlds;
	for( i = 0; i < nbHdrFlds; i++ ) {
		if( hdrFlds[i].align_bot > 1 ) count--;
	}

	nbHdrFlds = count;
	nbHdrRecs = count;

	/*
	 * Allocate data columns
	 */
	hdrRecs = _MALLOC(nbHdrFlds, struct VDdrwlo_db_fld);
	if( !hdrRecs ) goto wrapup;

	/*
	 * For each data column, get further info, including titles 
	 * shown in the header
	 */

	for( i = 0; i < nbHdrFlds; i++ ) 
	{
#ifdef DEBUG
		printf("\tfldid: [%s], lcol: %d, rcol: %d, top: %d, bot: %d\n",
			hdrFlds[i].fieldid, 
			hdrFlds[i].align_lcol, 
			hdrFlds[i].align_rcol, 
			hdrFlds[i].align_top, 
			hdrFlds[i].align_bot);
#endif

		_FREE( recs );
		count = 0;

		status =
		om$send(msg	 = message VDdrwlo.VDdrwlo_gfld (
						&msg,
              					VD_DRWLO_EN_HEADER,
              					VD_DRWLO_EN_ALL,
						hdrFlds[i].fieldid,
              					VD_DRWLO_EN_ALL,
						&count,
						NULL),
			senderid = NULL_OBJID,
			targetid = LGRID.objid,
			targetos = LGRID.osnum );
		__CheckRC( status, msg, "VDdrwlo.VDdrwlo_gfld", wrapup );

		if( !count ) continue;

		recs = _MALLOC( count, struct VDdrwlo_db_fld );
		if( !recs ) goto wrapup;
		
		status =
		om$send(msg	 = message VDdrwlo.VDdrwlo_gfld (
						&msg,
              					VD_DRWLO_EN_HEADER,
              					VD_DRWLO_EN_ALL,
						hdrFlds[i].fieldid,
              					VD_DRWLO_EN_ALL,
						&count,
						recs),
			senderid = NULL_OBJID,
			targetid = LGRID.objid,
			targetos = LGRID.osnum );
		__CheckRC( status, msg, "VDdrwlo.VDdrwlo_gfld", wrapup );
		
		hdrRecs[i] = recs[0];
		hdrRecs[i].col_seqno = hdrFlds[i].align_lcol;

		/* in case title has more than one lines */
		for( j = 1; j < count; j++ ) {
			strcat( hdrRecs[i].Ftext, " " );
			strcat( hdrRecs[i].Ftext, recs[j].Ftext );
		}
#ifdef DEBUG
		printf("\t\thdrRecs[%d]: id[%s], txt[%s], lin[%d], col[%d]\n",
			 i, hdrRecs[i].fieldid, hdrRecs[i].Ftext, hdrRecs[i].lin_seqno, hdrRecs[i].col_seqno);
#endif
	}

	/*
	 * Create xml nodes for colums and set attibutes
	 */

	xIDs = _MALLOC( nbHdrRecs, TGRid );
	if( !xIDs ) goto wrapup;

	for( i = 0; i < nbHdrRecs; i++ ) {
	   VDctxCreateNode(xloID, VD_XTBL_NODE_TYPE_COL, NULL, &xIDs[i]);
		
	   VDctxAppTxtAtr(&xIDs[i],VD_XTBL_COL_ATTR_TXT_FLDID, hdrRecs[i].fieldid);
	   VDctxAppTxtAtr(&xIDs[i],VD_XTBL_COL_ATTR_TXT_TITLE, hdrRecs[i].Ftext);
	   VDctxAppIntAtr(&xIDs[i],VD_XTBL_COL_ATTR_INT_COLNO, hdrRecs[i].col_seqno);
	   VDctxAppIntAtr(&xIDs[i],VD_XTBL_COL_ATTR_INT_LINNO, hdrRecs[i].lin_seqno);
	   for( j = 0; j < nbDatRecs; j++ ) {
	      if( hdrRecs[i].col_seqno == datRecs[j].colno ) {
		VDctxAppIntAtr(&xIDs[i],VD_XTBL_COL_ATTR_INT_GRPTYP, datRecs[j].grptyp);
		VDctxAppIntAtr(&xIDs[i],VD_XTBL_COL_ATTR_INT_RECTYP, datRecs[j].rectyp);
		VDctxAppIntAtr(&xIDs[i],VD_XTBL_COL_ATTR_INT_DATTYP, datRecs[j].datatyp);
		break;
	      }
	   }
	}

	if( xcolIDs ) *xcolIDs = xIDs;
	if( nbCols )  *nbCols  = nbHdrRecs;

	status = 1;
wrapup:
	if( !xcolIDs ) _FREE( xIDs );
	_FREE( recs );
	_FREE( datRecs );
	_FREE( hdrRecs );
	_FREE( hdrFlds );

	return status;
}


/*---------------------------------------------------------------------------
 *
 */
IGRlong	VDtblXmlCrObjNodes (	TGRid	*rowID, 
				TGRid	*xobjSet, 
				TGRid	**xobjIDs,
				IGRint	*nbObjIDs)
{
	IGRlong			status   = 0, msg;
	IGRchab			buf, objFile;
	IGRint			i, nbObjs;
	TGRid			*xIDs    = NULL;
	TGRobj_env		*objOEs  = NULL;

	if( !rowID || rowID->objid  == NULL_OBJID ) goto wrapup;
	if( nbObjIDs ) *nbObjIDs = 0;
	
	/*
	 * Get the number of objects from table row
	 */
	status =
	om$send(msg	 = message VDdrwTblRow.VDgetParentObjectList(
        				 		 &msg,
               					 	 &nbObjs,
               						 NULL),
		senderid = NULL_OBJID,
		targetid = rowID->objid,
		targetos = rowID->osnum );
	__CheckRC( status, msg, "VDdrwTblRow.VDgetParentObjectList", wrapup );

	if( !(status&msg&1) || nbObjs < 1 ) goto wrapup;

	/*
	 * Allocate and get the objects
	 */

	objOEs = _MALLOC( nbObjs, TGRobj_env );
	if( !objOEs ) goto wrapup;

	xIDs = _MALLOC( nbObjs, TGRid );
	if( !xIDs ) goto wrapup;

	status =
	om$send(msg	 = message VDdrwTblRow.VDgetParentObjectList(
        				 		 &msg,
        					 	 &nbObjs,
        						 objOEs ),
		senderid = NULL_OBJID,
		targetid = rowID->objid,
		targetos = rowID->osnum );
	__CheckRC( status, msg, "VDdrwTblRow.VDgetParentObjectList", wrapup );

	/*
	 * Loop through the objects and create xml node for each object
	 */

	for( i = 0; i < nbObjs; i++ ) {

		/* 
		 * create xml object node
		 */
		VDctxCreateNode(xobjSet, VD_XTBL_NODE_TYPE_OBJ, NULL, &xIDs[i]);

		/*
		 * set object attributes
		 */
		buf[0] = '\0';
		objFile[0] = '\0';
		VDosGetFileName ( objOEs[i].obj_id.osnum, objFile );
		sprintf( buf, "%s:%d", objFile, objOEs[i].obj_id.objid );
		VDctxAppTxtAtr(&xIDs[i],VD_XTBL_OBJ_ATTR_TXT_OBJID,buf);

		buf[0] = '\0';
		status = VDtblRowExecPplName (	&msg,
						&objOEs[i].obj_id,
						rowID,
						"VDrow_info",
						"name",
						buf );
		VDctxAppTxtAtr(&xIDs[i],VD_XTBL_OBJ_ATTR_TXT_PATH, buf);
	}

	if( xobjIDs ) *xobjIDs = xIDs;
	if( nbObjIDs ) *nbObjIDs = nbObjs;

	status = 1;
wrapup:
	if( !xobjIDs || !(status&1) ) _FREE( xIDs );
	_FREE( objOEs );
	return status;
}

/*---------------------------------------------------------------------------
 *
 */
IGRlong	VDtblXmlCrCellNodes (	TGRid	*rowID, 
				TGRid	*xcellSet, 
				TGRid	**xcellIDs,
				IGRint	*nbCells )
{
	IGRlong		status     = 0, msg;
	IGRint		i,j, 
			len,
			ind,
			nbObjs     = 0,
			nbTxt      = 0,
			nbTotal    = 0,
			nbValues   = 0,
			*lineNos   = NULL,
			*colNos    = NULL;

	GRname		buf;
	IGRchar		tblLoName[VD_DRWLO_CHR_IDFLD],
			attName[80],
			*datValue  = NULL,
			**values   = NULL,
			**defaults = NULL;

	IGRdouble	height;

	TGRid		*xIDs      = NULL,
			hdrID,
			collID;

	TGRobj_env	*lObjs     = NULL;

	IGRshort	nbFixRecs, nbDatRecs, found;

	struct	VDdrwlo_apifix	*fixRecs = NULL;
	struct	VDdrwlo_data	*datRecs = NULL;
	struct	VDdrwlo_qtyExp	qty;


	if( !rowID || rowID->objid == NULL_OBJID ) goto wrapup;
	if( nbCells ) *nbCells = 0;

	/*
	 * Get table header
	 */
	status =
	om$send (msg = message VDdrwTblRow.VDgetTableHeader (
                        			&msg, 
						&hdrID, 
						NULL),
		senderid = NULL_OBJID,
		targetid = rowID->objid,
		targetos = rowID->osnum);
	__CheckRC( status, msg, "VDdrwTblRow.VDgetTableHeader", wrapup );

	/*
	 * Get table layout name
	 */
	status =
	om$send (msg = message VDdrwTblHdr.VDgetTableInfo (
                        			&msg, 
						tblLoName, 
						NULL, NULL),
		senderid = NULL_OBJID,
		targetid = hdrID.objid,
		targetos = hdrID.osnum);
	__CheckRC( status, msg, "VDdrwTblRow.VDgetTableInfo", wrapup );

	/*
	 * Get collector from row
	 */
	status =
	om$send (msg = message VDdrwTblRow.ACfind_temp_obj ( 
							(int*)&msg, 
							"coll", 
							&collID ),
		senderid = NULL_OBJID,
		targetid = rowID->objid,
		targetos = rowID->osnum);
	__CheckRC( status, msg, "VDdrwTblRow.ACfind_temp_obj", wrapup );

	/*
	 *  get number of objects 
	 */
	status =
	om$send (msg = message VDdrwTblRow.VDgetParentObjectList (
							&msg,
							&nbObjs,
							NULL ),
		senderid = NULL_OBJID,
		targetid = rowID->objid,
		targetos = rowID->osnum);
	__CheckRC( status, msg, "VDdrwTblRow.VDgetParentObjectList", wrapup );

	if( nbObjs ) {
		lObjs = _MALLOC( nbObjs, TGRobj_env );
		if( !lObjs ) goto wrapup;
		status =
		om$send (msg = message VDdrwTblRow.VDgetParentObjectList (
								&msg,
								&nbObjs,
								lObjs ),
			senderid = NULL_OBJID,
			targetid = rowID->objid,
			targetos = rowID->osnum);
		CheckRC( status, msg );
	}

	/* get qty structure */

	status =
	om$send( msg     = message VDdrwTblRow.VDgetQtyExpr ( &msg, &qty ) ,
		senderid = NULL_OBJID,
		targetid = rowID->objid,
		targetos = rowID->osnum );
	CheckRC( status, msg );

	/* get the number of fixed components */
	status = VD_drwlo_gfix(	&msg,
				tblLoName,
				VD_DRWLO_EN_DATA,
				(double)0,
				(double)0, 
				(short)0,
				NULL,
				&height,
				&nbFixRecs,
				NULL );
	__CheckRC( status, msg, "VD_drwlo_gfix", wrapup );

	if( nbFixRecs )
	{
		fixRecs = _MALLOC( nbFixRecs, struct VDdrwlo_apifix );
		if( !fixRecs ) goto wrapup;

		status = VD_drwlo_gfix(	&msg,
					tblLoName,
					VD_DRWLO_EN_DATA,
					(double)0,
					(double)0, 
					(short)0,
					NULL,
					&height,
					&nbFixRecs,
					fixRecs );
		__CheckRC( status, msg, "VD_drwlo_gfix", wrapup );

		/* retain texts only */

		for( i = 0 ; i < nbFixRecs ; i++ )
		{
			if( fixRecs[i].rectyp == VD_DRWLO_EN_TEXT ) {
				fixRecs[nbTxt++] = fixRecs[i];
			}
		}

		nbFixRecs = nbTxt;
	}

	/* get the number of replaceable components */

	status = VD_drwlo_gdata (	&msg,
					tblLoName,
					VD_DRWLO_EN_DATA,
					(double)0,
					(double)0, 
					(short)0,
					NULL,
					&height,
					&nbDatRecs,
					NULL );
	__CheckRC( status, msg, "VD_drwlo_gdata", wrapup );

	if( nbDatRecs )
	{
		/* allocate memory */

		datRecs = _MALLOC( nbDatRecs, struct VDdrwlo_data );

		if( !datRecs ) goto wrapup;

		/* get the list of replaceable components */

		status = VD_drwlo_gdata(&msg,
					tblLoName,
					VD_DRWLO_EN_DATA,
					(double)0,
					(double)0, 
					(short)0,
					NULL,
					&height,
					&nbDatRecs,
					datRecs );
		__CheckRC( status, msg, "VD_drwlo_gdata", wrapup );
	}

	nbTotal = nbFixRecs + nbDatRecs;
	if( !nbTotal ) goto wrapup;

	lineNos = _MALLOC( nbTotal, IGRint );
	if( !lineNos ) goto wrapup;

	colNos = _MALLOC( nbTotal, IGRint );
	if( !colNos ) goto wrapup;

	values = _MALLOC( nbTotal, IGRchar * );
	if( !values ) goto wrapup;

	defaults = _MALLOC( nbTotal, IGRchar * );
	if( !defaults ) goto wrapup;

	/* initialize pointers */

	for( i = 0 ; i < nbTotal ; i++ ) {
		values[i]   = NULL;
		defaults[i] = NULL;
	}

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

		defaults[ind] = _MALLOC( len, IGRchar);
		if( !(defaults[ind]) ) goto wrapup;

		strcpy( defaults[ind], fixRecs[i].VD.tx.Text );

		_FREE( datValue );
		status = VDdrw_getAttFromColl(&msg, collID, attName,&datValue);
		if( status & msg & 1 )
		{
			found = 1;
			len = strlen( datValue ) + 1;
		}

		values[ind] = _MALLOC( len, IGRchar );
		if( !(values[ind]) ) goto wrapup;

		if( found ) {
			strcpy( values[ind], datValue );
		}
		else {
			strcpy( values[ind], fixRecs[i].VD.tx.Text );
		}

		lineNos[ind] = fixRecs[i].VD.tx.lineno;
		colNos[ind]  = fixRecs[i].VD.tx.colno;

		ind++;
	}

	/*
	 * get replaceable component values
	 */

	for( i = 0 ; i < nbDatRecs ; i++ )
	{
		/* first look if value is present in collector */

		attName[0] = '\0';
		sprintf(attName, "%d %d", datRecs[i].colno, datRecs[i].lineno);
		found = 0;

		_FREE( datValue );
		status = VDdrw_getAttFromColl(&msg, collID, attName,&datValue);
		if( (status & msg & 1) )
		{
			found = 1;
		}

		/* get field value */

		status = VDdrw_getFldValue (	&msg,
						nbObjs,
						lObjs,
						datRecs[i],
						qty,
						rowID,
						&defaults[ind] );
		CheckRC( status, msg );

		if( !found && (status & msg & 1) ) {
			_FREE( datValue );
			datValue = _MALLOC((strlen(defaults[ind])+1), IGRchar);
			if( !datValue ) goto wrapup;
			strcpy( datValue, defaults[ind] );
		}
		
		len = strlen( datValue );

		/* allocate memory for output string value */

		values[ind] = _MALLOC( len+1, IGRchar );

		if( !( values[ind] ) ) goto wrapup;

		strcpy( values[ind], datValue );

		lineNos[ind] = datRecs[i].lineno;
		colNos[ind]  = datRecs[i].colno;

		ind++;
	}

	nbValues = ind;

	if ( !nbValues ) goto wrapup;

	xIDs = _MALLOC( nbValues, TGRid );
	if( !xIDs ) goto wrapup;
	
	/* 
	 * pick value for column flds->colNos[j] which is found match in colNos
	 */
	for ( i = 0; i < nbValues; i++ ) {
	    if( flds ) {
		for(j = 0; j < flds->cnt && colNos[i] != flds->colNos[j]; j++);
		if( j == flds->cnt ) continue;
	    }
	    VDctxCreateNode (xcellSet, VD_XTBL_NODE_TYPE_CELL, NULL, &xIDs[i]);
		
	    VDctxAppIntAtr(&xIDs[i], VD_XTBL_CELL_ATTR_INT_COLNO, colNos[i]);
	    VDctxAppIntAtr(&xIDs[i], VD_XTBL_CELL_ATTR_INT_LINNO, lineNos[i]);
	    VDctxAppTxtAtr(&xIDs[i], VD_XTBL_CELL_ATTR_TXT_VALUE, values[i]);
	    VDctxAppTxtAtr(&xIDs[i], VD_XTBL_CELL_ATTR_TXT_DEFAULT, defaults[i]);
	}

	/* 
	 * set empty for column flds->colNos[j] which is no match in colNos
	 */
	if( flds ) {
	   for(j = 0; j < flds->cnt; j++) {
		for(i = 0; i < nbValues && colNos[i] != flds->colNos[j]; j++);
		if( i < nbValues ) continue;
		VDctxCreateNode (xcellSet, VD_XTBL_NODE_TYPE_CELL, NULL, &xIDs[j]);
		
		VDctxAppIntAtr(&xIDs[j], VD_XTBL_CELL_ATTR_INT_COLNO, flds->colNos[j]);
		VDctxAppIntAtr(&xIDs[j], VD_XTBL_CELL_ATTR_INT_LINNO, flds->linNos[j]);
		VDctxAppTxtAtr(&xIDs[j], VD_XTBL_CELL_ATTR_TXT_VALUE, "");
		VDctxAppTxtAtr(&xIDs[j], VD_XTBL_CELL_ATTR_TXT_DEFAULT, "");
	   }
	}

	if( xcellIDs ) *xcellIDs = xIDs;
	if( nbCells )  *nbCells = nbValues;

	status = 1;
wrapup:
	if( !xcellIDs ) _FREE( xIDs );
	_LOOPFREE( values,   nbTotal );
	_LOOPFREE( defaults, nbTotal );
	_FREE( datValue );
	_FREE( lineNos );
	_FREE( colNos );
	_FREE( lObjs );
	_FREE( fixRecs );
	_FREE( datRecs );

	return status;
}



/*---------------------------------------------------------------------------
 *
 */
IGRlong	VDtblXmlCrRowNodes (	TGRid	*hdrID, 
				TGRid	*xtblSet, 
				TGRid	**xrowIDs,
				IGRint	*nbRowIDs)
{
	IGRlong			status   = 0, msg;
	IGRchab			buf, stsMsg,
				qtyExp,
				itemNo,
				objPath,
				tblFile,
				objFile;
	IGRint			nbRows   = 0, startNo = 0;
	IGRint			i, bufSize;
	TGRid			*xIDs    = NULL;
	TGRid			*hdrIDs  = NULL;
	TGRid			xobjSet;
	TGRid			xcellSet;
	struct	VDdrw_rowInfo	*rows    = NULL;
	IGRshort		rowInfo = 0,
				isLinedOut = 0,
				isUserDef = 0 ;
	struct VDdrwlo_qtyExp	qty;

	if( !hdrID || hdrID->objid == NULL_OBJID ) goto wrapup;
	if( nbRowIDs ) *nbRowIDs = 0;
	
	/*
	 * Get the number of rows from input header
	 */
	status =
	om$send(msg	 = message VDdrwTblHdr.VDgetRowInfo (	&msg,
								&nbRows,
								&startNo ),
		senderid = NULL_OBJID,
		targetid = hdrID->objid,
		targetos = hdrID->osnum );
	__CheckRC( status, msg, "VDdrwTblHdr.VDgetRowInfo", wrapup );

	if( nbRows < 1 ) goto wrapup;

	/*
	 * Allocate rowInfo and xml rows
	 */
	rows = _MALLOC( nbRows, struct VDdrw_rowInfo );
	if( !rows ) goto wrapup;

	xIDs = _MALLOC( nbRows, TGRid );
	if( !xIDs ) goto wrapup;

	/*
	 * Get file name
	 */
	VDosGetFileName ( hdrID->osnum, tblFile );

	/*
	 * Loop through table rows, create xml rows and xml objects nunder
	 * each row
	 */

	for( i = 0; i < nbRows; i++ ) {

		sprintf( stsMsg, "Processing rows: %s%d", "%", 
				(100*(i+1))/nbRows );
		UI_status( stsMsg );

		/*
		 * Get table row ids from hdr
		 */
		status =
		om$send( msg	 = message VDdrwTblHdr.VDrowNoToGRid(
							&msg,
							(startNo + i),
							&rows[i].rowId),
			senderid = NULL_OBJID,
			targetid = hdrID->objid,
			targetos = hdrID->osnum );
		CheckRC( status, msg );
		if( !(status&msg&1) ) continue;
		
		/*
		 * Get ItemNumber
		 */
		status =
		om$send( msg     = message VDdrwTblRow.VDgetItemNumber (
							&msg,
							&bufSize,
							itemNo ) ,
			senderid = NULL_OBJID,
			targetid = rows[i].rowId.objid,
			targetos = rows[i].rowId.osnum );
		CheckRC( status, msg );
							
		/*
		 * Get rowInfo
		 */
		rowInfo = 0;

		status =
		om$send( msg     = message VDdrwTblRow.VDgetQtyExpr (
							&msg,
							&qty ) ,
			senderid = NULL_OBJID,
			targetid = rows[i].rowId.objid,
			targetos = rows[i].rowId.osnum );
		CheckRC( status, msg );
		if( (status&msg&1) && qty.nSflag ) {
			rowInfo |= VD_ROW_QTY_EXPRESSION;
		}
							
		status =
		om$send( msg     = message VDdrwTblRow.VDisRowLinedOut (
							&msg,
							&isLinedOut ) ,
			senderid = NULL_OBJID,
			targetid = rows[i].rowId.objid,
			targetos = rows[i].rowId.osnum );
		CheckRC( status, msg );
		if( (status&msg&1) && isLinedOut ) {
			rowInfo |= VD_ROW_LINEOUT;
		}
							
		status =
		om$send( msg     = message VDdrwTblRow.VDisUserDefinedRow (
							&msg,
							&isUserDef ) ,
			senderid = NULL_OBJID,
			targetid = rows[i].rowId.objid,
			targetos = rows[i].rowId.osnum );
		CheckRC( status, msg );
		if( (status&msg&1) && isUserDef ) {
			rowInfo |= VD_ROW_USER_DEFINED;
		}
		
		/*
		 * Create xml row node
		 */
		VDctxCreateNode(xtblSet, VD_XTBL_NODE_TYPE_ROW, NULL, &xIDs[i]);

		/*
		 * Set attributes to xml row node
		 */

		sprintf( buf, "%s:%d", tblFile, rows[i].rowId.objid );
		VDctxAppTxtAtr(&xIDs[i], VD_XTBL_ROW_ATTR_TXT_ROWID,  buf);

		VDctxAppIntAtr(&xIDs[i], VD_XTBL_ROW_ATTR_INT_ROWNO, (startNo+i));

		VDctxAppTxtAtr(&xIDs[i], VD_XTBL_ROW_ATTR_TXT_ITEMNO,itemNo);

		VDctxAppIntAtr(&xIDs[i], VD_XTBL_ROW_ATTR_INT_INFO, rowInfo);

		VDctxAppTxtAtr(&xIDs[i], VD_XTBL_ROW_ATTR_TXT_QTYEXP,qty.szExp);

		/*
		 * Create xml object set node for each table row
		 */
		VDctxCreateNode(&xIDs[i],VD_XTBL_NODE_TYPE_OBJS,NULL,&xobjSet);

		/*
		 * Create xml object nodes under object set
		 */
		status = VDtblXmlCrObjNodes (	&rows[i].rowId, 
						&xobjSet, 
						NULL, NULL);

		/*
		 * Create xml cell set node for each table row
		 */
		VDctxCreateNode (	&xIDs[i], 
					VD_XTBL_NODE_TYPE_CELLS, 
					NULL,
					&xcellSet);

		/*
		 * Create xml cell nodes from each table row
		 */
		status = VDtblXmlCrCellNodes (	&rows[i].rowId, 
						&xcellSet, 
						NULL, NULL);
	}
	UI_status("");

	if( xrowIDs ) *xrowIDs = xIDs;
	if( nbRowIDs ) *nbRowIDs = nbRows;

	status = 1;
wrapup:
	if( !xrowIDs || !(status&1) ) _FREE( xIDs );
	_FREE( hdrIDs );
	_FREE( rows );
	return status;
}


/*---------------------------------------------------------------------------
 *
 */
IGRlong	VDtblXmlCrTblSetNodes (	TGRid	*tblID, 
				TGRid	*xtblID, 
				TGRid	**xtblSets,
				IGRint	*nbTblSets )
{
	IGRlong		status	= 0, msg;
	IGRint		nbHdrs	= 0, i;
	TGRid		*hdrIDs	= NULL;
	TGRid		*xsetIDs= NULL;
	IGRchab		buf;
	IGRint		nbRows,
			startNo,
			partNo;
	IGRshort	hdrTyp,
			trlTyp,
			cnsTyp,
			csLoc,
			tblOrient;

	if( !tblID  || tblID->objid  == NULL_OBJID )
	{
		goto wrapup;
	}
	if( nbTblSets ) *nbTblSets = 0;

	/*
	 */

	status =
	om$send( msg     = message VDdrwTbl.VDgetTableParts(
							&msg,
                                                        &nbHdrs,
                                                        NULL),
		senderid = NULL_OBJID,
		targetid = tblID->objid,
		targetos = tblID->osnum );

	__CheckRC( status, msg, "VDdrwTbl.VDgetTableParts",wrapup);

	if( nbHdrs < 1 ) goto wrapup;

	hdrIDs = _MALLOC( nbHdrs, struct GRid );
	if( hdrIDs == NULL ) goto wrapup;

	status =
	om$send(msg      = message VDdrwTbl.VDgetTableParts(
							&msg,
                                                        &nbHdrs,
                                                        hdrIDs),
		senderid = NULL_OBJID,
		targetid = tblID->objid,
		targetos = tblID->osnum );
	__CheckRC( status, msg, "VDdrwTbl.VDgetTableParts", wrapup);

	/*
	 * Create table set nodes
	 */

	xsetIDs  = _MALLOC( nbHdrs, struct GRid );
	if( xsetIDs == NULL ) goto wrapup;

	for( i = 0; i < nbHdrs; i++ ) {

	   /*
	    * create table set node
	    */
	   VDctxCreateNode(xtblID, VD_XTBL_NODE_TYPE_TBLSET, NULL, &xsetIDs[i]);


	   /*
	    * get attribute values
	    */

	   status =
	   om$send(msg	 = message VDdrwTblHdr.VDgetRowInfo (	&msg,
								&nbRows,
								&startNo ),
			senderid = NULL_OBJID,
			targetid = hdrIDs[i].objid,
			targetos = hdrIDs[i].osnum );
	   CheckRC( status, msg );
	   
	   status =
	   om$send(msg	 = message VDdrwTblHdr.VDgetConstructInfo (
								&msg,
								&hdrTyp,
								&trlTyp,
								&cnsTyp ),
			senderid = NULL_OBJID,
			targetid = hdrIDs[i].objid,
			targetos = hdrIDs[i].osnum );
	   CheckRC( status, msg );
	   
	   status =
	   om$send(msg	 = message VDdrwTblHdr.VDgetTableInfo (
								&msg,
								buf,
								&partNo,
								&tblOrient ),
			senderid = NULL_OBJID,
			targetid = hdrIDs[i].objid,
			targetos = hdrIDs[i].osnum );
	   CheckRC( status, msg );
	   
	   status =
	   om$send(msg	 = message VDdrwTblHdr.VDgetCsLocation (
								&msg,
								&csLoc ),
			senderid = NULL_OBJID,
			targetid = hdrIDs[i].objid,
			targetos = hdrIDs[i].osnum );
	   CheckRC( status, msg );


	   /*
	    * set attribute values to table set node
	    */

	   VDctxAppIntAtr( &xsetIDs[i], VD_XTBL_TBLSET_ATTR_INT_PTNO, partNo);

	   VDctxAppIntAtr( &xsetIDs[i], VD_XTBL_TBLSET_ATTR_INT_ORIENT, tblOrient);

	   VDctxAppIntAtr( &xsetIDs[i], VD_XTBL_TBLSET_ATTR_INT_CSLOC, csLoc);

	   VDctxAppIntAtr( &xsetIDs[i], VD_XTBL_TBLSET_ATTR_INT_HDRTYP, hdrTyp);

	   VDctxAppIntAtr( &xsetIDs[i], VD_XTBL_TBLSET_ATTR_INT_TRLTYP, trlTyp);

	   VDctxAppIntAtr( &xsetIDs[i], VD_XTBL_TBLSET_ATTR_INT_CONSTYP, cnsTyp);

	   VDctxAppIntAtr( &xsetIDs[i], VD_XTBL_TBLSET_ATTR_INT_START, startNo);

	   VDctxAppIntAtr( &xsetIDs[i], VD_XTBL_TBLSET_ATTR_INT_NBROWS, nbRows);

	   /*
	    * create header node under table set
	    */
	   VDtblXmlCrHdrNode( &hdrIDs[i], &xsetIDs[i], NULL );
	   CheckRC( status, msg );
	   
	   /*
	    * create row nodes under table set
	    */
	   VDtblXmlCrRowNodes( &hdrIDs[i], &xsetIDs[i], NULL, NULL );
	   CheckRC( status, msg );
	}
	
	if( xtblSets ) *xtblSets = xsetIDs;
	if( nbTblSets ) *nbTblSets = nbHdrs;

	status = 1;
wrapup:
	_FREE( hdrIDs );
	if( !xtblSets || !(status&1)) _FREE( xsetIDs );
	return status;
}


/*---------------------------------------------------------------------------
 *
 */
IGRlong	VDtblXmlCrTblSetsNode (	TGRid	*tblID, 
				TGRid	*xtreeID, 
				TGRid	*xtblSetsID )
{
	IGRlong		status = 0, msg ;
	IGRint		nbAttrs	= 0, nbNodes = 0, i;
	IGRshort	crTyp;
	TGRid		*nodeIDs = NULL, xID;
	IGRchab		buf, fileName;
	TACrg_coll	*attrList = NULL;

	if (	!tblID   || tblID->objid  == NULL_OBJID )
	{
		goto wrapup;
	}

	/*
	 * Get attributes
	 */

	status = vd$tbl_getAttributes (	msg		= &msg,
					tblId		= tblID,
					nodeIds		= &nodeIDs,
					nodeCnt		= &nbNodes,
					attrCnt		= &nbAttrs,
					attrList	= &attrList );

	if( nbAttrs > 1 && attrList != NULL ) {
		if( !strcmp( attrList[0].name, "node_path") ) {
			crTyp = VD_CMD_STBL_PL;
		}
		else if( !strcmp( attrList[0].name, "file_name" ) ) {
			crTyp = VD_CMD_ITBL_PL;
		}
		else {
			crTyp = -1;	// unkown
		}
	}
	else {
		crTyp = VD_CMD_TBL_HDR;
	}

#ifdef DEBUG
	printf("root node: "); vdobj$Print(objID=&nodeIDs[0]);
	for( i = 0; i < nbAttrs; i++ ) {
		printf("attrList[%d] -- name: [%s], value: [%s]\n",
			i, attrList[i].name, attrList[i].desc.value.att_txt);
	}
#endif

	VDctxCreateNode(xtreeID, VD_XTBL_NODE_TYPE_TBLSETS, NULL, &xID);
	VDctxAppIntAtr(&xID, VD_XTBL_TBLSETS_ATTR_INT_CRTYP, crTyp );

	switch ( crTyp ) {
	
	case VD_CMD_STBL_PL:
		VDosGetFileName(nodeIDs[0].osnum, fileName);
		sprintf( buf, "%s:%d", fileName, nodeIDs[0].objid );
		VDctxAppTxtAtr(&xID, VD_XTBL_TBLSETS_ATTR_TXT_ROOT, buf);
		
		VDctxAppTxtAtr(&xID, VD_XTBL_TBLSETS_ATTR_TXT_PATH, 
					attrList[0].desc.value.att_txt);
		VDctxAppTxtAtr(&xID, VD_XTBL_TBLSETS_ATTR_TXT_PROC, 
					attrList[1].desc.value.att_txt);
		VDctxAppTxtAtr(&xID, VD_XTBL_TBLSETS_ATTR_TXT_INDEX, 
					attrList[2].desc.value.att_txt);
		break;

	case VD_CMD_ITBL_PL:
		VDctxAppTxtAtr(&xID, VD_XTBL_TBLSETS_ATTR_TXT_FILE,
					attrList[0].desc.value.att_txt);
		VDctxAppTxtAtr(&xID, VD_XTBL_TBLSETS_ATTR_TXT_SEPAR,
					attrList[1].desc.value.att_txt);
		break;

	case VD_CMD_TBL_HDR:
		break;

	default:
		break;
	};
	
	if( xtblSetsID ) *xtblSetsID = xID;

	status = 1;
wrapup:
	_FREE( attrList );
	_FREE( nodeIDs );
	return status;
}

/*---------------------------------------------------------------------------
 * Modify xml by field option. Current version only works with column option
 */
IGRlong	VDtblXmlModifyByOpt (	TGRid		*xtreeID,
				IGRchar		**xmlBuf,
				IGRchar		*xmlFile,
				VDxtblFldOpt	*flds )
{
	IGRlong		status = 0, msg ;
	IGRint		i, j, cnt, colNo;
	GRname		buf;
	TGRid		*delListIDs = NULL, xmlID ;
	TVDctxNodeList	cellList;

	VDctxInitNodeList(&cellList);

	if( !flds    || !flds->cnt || !flds->colNos ) goto wrapup;
	if( !xtreeID && !xmlBuf && !xmlFile )  goto wrapup;

	if( xtreeID ) {
		xmlID = *xtreeID;
	}
	if ( xmlBuf ) {
		VDxdomCreateTreeFromXmlBuf( xmlBuf, &xmlID );
	}
	if( xmlFile ) {
		VDxdomCreateTreeFromXmlFile ( xmlFile, &xmlID );
	}

	VDctxGetNodeListByType ( &xmlID, VD_XTBL_NODE_TYPE_CELL, &cellList );
	if( !cellList.cnt || !cellList.listIDs ) goto wrapup;

	delListIDs = _MALLOC( cellList.cnt, TGRid );
	if( !delListIDs ) goto wrapup;

	cnt = 0;
	for( i = 0; i < cellList.cnt; i++ ) {
		VDctxGetTxtAtr( &cellList.listIDs[i], 
				VD_XTBL_CELL_ATTR_INT_COLNO, 
				buf);
		colNo = atoi( buf );
		for( j = 0; j < flds->cnt; j++ ) {
			if( colNo == flds->colNos[j] ) break;
		}

		if( j == flds->cnt ) {
			delListIDs[cnt] = cellList.listIDs[i];
			cnt++;
		}
	}
	
	for( i = 0; i < cnt; i++ ) {
		VDctxDeleteNode( &delListIDs[i] );
	}

	if( xmlBuf ) {
		_FREE( *xmlBuf );
		VDctxSaveTreeToXmlBuf ( &xmlID, xmlBuf );
	}

	if( xmlFile ) {
		VDctxSaveTreeToXmlFile ( &xmlID, xmlFile );
	}

	status = 1;
wrapup:
	if( !xtreeID ) VDctxDeleteNode( &xmlID );
	VDctxFreeNodeList(&cellList);
	_FREE(delListIDs);
	return status;
}


/*---------------------------------------------------------------------------
 *
 */
IGRlong	VDtblXmlCreate (	TGRid		*tblID,
				VDxtblFldOpt	*fldOpt,
				IGRchar		*xmlFile,
				IGRchar		*domName,
				TGRid		*domID,
				TGRid		*xtreeID,
				IGRchar		**xmlBuf )
{
	IGRlong		status = 0, msg ;

	IGRchab		msgTxt;
	IGRchar		pwdName[DI_PATH_MAX];
	IGRchar		path[DI_PATH_MAX];
	IGRchar		*buf = NULL;
	GRname		curFileName;
	GRname		tblName, xtblName;
	VDosnum		osnum;
	TGRid		dirObj;
	TGRid		xtblID, xloID, tblSetsID;
	TGRid		objID;
	DIgrid		*objIDs = NULL;
	IGRint		cnt = 0, bufLen = 0;

	xtblID.objid	= NULL_OBJID;
	xloID.objid	= NULL_OBJID;
	tblSetsID.objid	= NULL_OBJID;
	dirObj.objid	= NULL_OBJID;

	if( domID ) domID->objid = NULL_OBJID;
	if( xtreeID ) xtreeID->objid = NULL_OBJID;
	if( xmlBuf ) *xmlBuf = NULL;

	pwdName[0] ='\0';
	status = di$pwd( dirname = pwdName );
	as$status();

	if( !tblID || tblID->objid == NULL_OBJID ) goto wrapup;
	
	if( fldOpt ) {
		flds = fldOpt;
	}

	/*
	 * Create xml root
	 */
	status = VDtblXmlCrTblNode ( tblID, "desc", &xtblID );
	as$status();

	/*
	 * Create table layout node and add it to xml tree
	 */
	status  = VDtblXmlCrLayoutNode ( tblID, &xtblID, &xloID );
	as$status();

	/*
	 * Create layout column nodes under layout node
	 * Will move this call to VDtblXmlCrLayoutNode
	 */
	status  = VDtblXmlCrLoColNodes ( tblID, &xloID, NULL, NULL );
	as$status();

	/*
	 * Create xml table sets node
	 */
	status  = VDtblXmlCrTblSetsNode ( tblID, &xtblID, &tblSetsID );
	as$status();

	/*
	 * Create xml table set nodes under sets node
	 */
	status  = VDtblXmlCrTblSetNodes ( tblID, &tblSetsID, NULL, NULL );
	as$status();

#ifdef DEBUG
	VDctxSaveTreeToXmlFile( &xtblID, "xmltbl");
	VDgtkShowTreeID(&xtblID);
{
	IGRchar		**rowBuf;
	IGRint		nbRows = 0;
	IGRchar		*colBuf;
	IGRint		nbCols = 0, m, n;

	vd$xmltbl_getRowData (
			xtreeID		= &xtblID,
			separator	= "|",
			rowInd		= 1,
			rowBuf		= &rowBuf,
			nbRows		= &nbRows,
			colBuf		= &colBuf,
			colInd		= 5,
			nbCols		= &nbCols );

	printf("Columns: [%s]\n", colBuf);

	printf("\nRows, cnt = %d:\n", nbRows);
	for( n = 0; n < nbRows; n++ ) {
		printf("\trow[%d]: [%s]\n", n, rowBuf[n]);
	}


	_FREE( colBuf );
	_LOOPFREE( rowBuf, nbRows );
}
#endif
	UI_status("Processing ....");

	/*
	 * Output result based on request
	 */

	/* Save xml tree to a file */
	if( xmlFile ) VDctxSaveTreeToXmlFile( &xtblID, xmlFile);

	/* Save xml to buffer */
	if( xmlBuf ) VDctxSaveTreeToXmlBuf ( &xtblID, xmlBuf);

	/* Output xml tree id */
	if( xtreeID ) *xtreeID = xtblID;

	/* Create dom object if required */

	if( !domID ) {
		status = 1;
		goto wrapup;
	}

	ex$get_cur_mod(osnum = &osnum);
	VDosGetFileName(osnum, curFileName);
	sprintf(path, ":%s:%s", curFileName, VD_XTBL_DIR);

	status = di$translate ( objname = path,
				osnum   = osnum,
				p_objid = &dirObj.objid,
				p_osnum = &dirObj.osnum );
	if( !(status&1) ) {
		status = di$mkdir (	dirname = path,
					osnum   = osnum,
					p_dirid = &dirObj.objid,
					p_osnum = &dirObj.osnum );
		as$status();

		status = di$cd( dirname = path );
		as$status();
        }
	else {
		status = di$cd( dirname = path );
        }

	vdobj$Get( objID = tblID, objName = tblName);

	if( !domName || *domName == 0 ) {
		sprintf( xtblName, "%s_xml", tblName);
	}
	else {
		strcpy( xtblName, domName);
	}

	di$find( regexp = xtblName, grids = &objIDs, ptr = &cnt );

	/*
	 * objID is saved under filename:usr:dooms with doomXXX,
	 * but GRputname moves it to correct dir. We may implement our own
	 * create function to handle it later
	 */

	if( cnt ) {
		if( domName && *domName != 0 ) {
			sprintf (
			    msgTxt,
			    "%s already exists. Do you want to overwrite it?", 
			    xtblName );

		  if( !GRconfirm_box(msgTxt) ) {
			goto wrapup;
		  }
		}

		VDctxSaveTreeToXmlBuf(&xtblID, &buf);
		bufLen = strlen( buf ) + 1;
                status = om$send (      msg      = message VDbuf.vdbufSetData
                                                        (1,0,bufLen,buf),
                                senderid = NULL_OBJID,
                                targetid = objIDs[0].objid,
                                targetos = objIDs[0].osnum);
		msg = 1;
		CheckRC( status, msg );

	}
	else {
		VDdoomCreateFromTree(&xtblID, &objID);

		status = om$send(msg     = message GRvg.GRputname (&msg, xtblName),
                                 senderid = NULL_OBJID,
                                 targetid = objID.objid,
                                 targetos = objID.osnum);
		CheckRC( status, msg );
	}

	if( (status&msg&1) ) {
		*domID = objID;
	}
	else {
		goto wrapup;
	}

		
	status = 1;
wrapup:
	flds = NULL;
	_FREE( buf );
	_FREE( objIDs );

	if( !xtreeID && xtblID.objid != NULL_OBJID ) {
		VDctxDeleteNode(&xtblID);
	}

	if( pwdName[0] != '\0' ){
		di$cd( dirname = pwdName );
	}

	return status;
}


end implementation Root;
