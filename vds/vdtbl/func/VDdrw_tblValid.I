/* $Id: VDdrw_tblValid.I,v 1.5 2002/05/15 13:10:33 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vds/vdtbl/dump/VDdrw_tblValid.I
 *
 * Description: save set Routines
 *
 * Dependencies: 
 *
 * Revision History:
 *      $Log: VDdrw_tblValid.I,v $
 *      Revision 1.5  2002/05/15 13:10:33  ahundiak
 *      *** empty log message ***
 *
 *      Revision 1.4  2002/05/10 17:48:27  ylong
 *      *** empty log message ***
 *
 *      Revision 1.3  2002/05/02 21:15:16  ahundiak
 *      *** empty log message ***
 *
 *      Revision 1.2  2002/05/01 16:26:58  ahundiak
 *      *** empty log message ***
 *
 *      Revision 1.1  2002/04/04 21:03:52  ylong
 *      *** empty log message ***
 *
 *
 * History:
 * MM/DD/YY	AUTHOR		DESCRIPTION
 ***************************************************************************/
class implementation Root;

#include "VDtypedef.h"
#include "VDtblCmdDef.h"
#include "VDdrwtbl.h"
#include "v_dbgmacros.h"
#include "VDobj.h"
#include "vdtr_macros.h"
#include "AS_status.h"
#include "VDmem.h"
#include "dpstruct.h"
#include "vdrefmacros.h"
#include "vdtblmacros.h"
#include "v_drwprocess.h" 
#include "VDobj.h"
#include "VDchn.h"
#include "VDgeom.h"

typedef struct {
	TGRid		rowId;
	TGRid		csId;
	TGRid		hdrId;
	IGRint		nbRows;
	IGRint		startRowNo;
	IGRshort	csLocation;
	IGRshort	tblOrient;
	IGRpoint	hdrCornPt;
	IGRdouble	hdrHeight;
	IGRdouble	csMatrix[16];
} RowInfo;
	
	
	
from	ACcpx		import  ACfind_temp_obj;
from	ACrg_collect	import	AClist_attribute,
				ACset_list_attribute;
from	NDnode		import	NDget_objects;

from	VDdrwTbl	import	VDgetTableLayoutName,
				VDgetTableType,
				VDgetAdsTblName,
				VDgetTableParts,
				VDgetTotalNbOfRows;

from	VDdrwTblHdr	import	VDgetCsLocation,
				VDgetRowInfo,
				VDgetConstructInfo,
				VDgetTableInfo,
				VDgetRowConstructInfo,
				VDgetRowHeight,
				VDgetCornerPointForRow,
				VDputStartRowNo,
				VDrowNoToGRid,
				/*VDsetSizeOfRowHeights,*/
				VDnewRowHeight;

from	VDdrwTblRow	import	VDisRowLinedOut,
				VDisUserDefinedRow,
				VDgetQtyExpr,
				VDgetItemNumber,
				VDgetParentObjectList,
				VDgetCurrentRowValues,
				VDgetTableHeader,
				VDgetRowNumber,
				VDgetParentSetId,
				VDmoveRow,
				VDputRowNumber;

from	GRowner		import	GRget_number_components;
from	GRgencs		import	GRgetmatrix;

/*-------------------------------------------------------------------
 *
 */
IGRint	VDtblCheckRowPosition( RowInfo *rowInfo )
{
	IGRlong		status = 0, msg ;
	IGRint		i, k, four = 4;
	IGRint		rowNo, nbRows, startRowNo, maxCnt = 0, cnt = 0;
	TGRid		rowId;
	TGRid		*lineIds = NULL;
	TGRobj_env	footOE;
	IGRshort	matType;
	IGRdouble	xmin =  1.0e12, ymin =  1.0e12, zmin =  1.0e12;
	IGRdouble	xmax = -1.0e12, ymax = -1.0e12, zmax = -1.0e12;
	IGRdouble	matrix[16];
	IGRdouble	pt1[4], pt2[4], pnt[4];
	IGRdouble	rowHeight = 0., totalHeight = 0., newHeight = 0.;
	IGRdouble	dist = 0.;
	TGRbsp_curve	*crv = NULL;
	
	if( !rowInfo ) {
		printf("NULL input for checking row position\n");
		goto wrapup;
	}

	rowId = rowInfo->rowId;
	if( rowId.objid == NULL_OBJID ) {
		printf("Row id is NULL\n");
		goto wrapup;	
	}
	
	vdobj$GetFoot(	objID		= &rowId,
			footName	= "geom",
			footOE		= &footOE);
	if( footOE.obj_id.objid == NULL_OBJID ) {
		printf("Failed to get GRowner for: ");
		vdobj$Print(objID = &rowId);
		goto wrapup;
	}

	status =
	om$send( msg      = message GRowner.GRget_number_components
						( &msg, &maxCnt ),
                 senderid = NULL_OBJID,
            	 targetid = footOE.obj_id.objid,
            	 targetos = footOE.obj_id.osnum );

	if( !(status&msg&1) || maxCnt < 1 ) {
		printf("GRowner.GRget_number_components failed. for row: ");
		vdobj$Print(objID = &rowId);
		goto wrapup;
	}

	lineIds = _MALLOC( maxCnt, TGRid );
	if( !lineIds ) goto wrapup;

	vdchn$GetList(	objOE	= &footOE,
			chnName	= "GRcmpowner.to_components",
			maxCnt	= maxCnt,
			cnt	= &cnt,
			outIDs  = lineIds,
			FltrClNam = "GR3dlineseg" );

	if( cnt < 1 ) {
		printf("vdchn$GetList failed for row: ");
		vdobj$Print(objID = &rowId);
		goto wrapup;
	}

	// check actual boundary in local coordinate system for row
	for( i = 0; i < cnt; i++ ) {
		vdgeom$Get2(	objID	= &lineIds[i],
				crv	= &crv );
		if( !crv ) continue;

		VDgeomGetEndPoints( crv, pt1, pt2 );
		pt1[3] = 1.; pt2[3] = 1.;

		// transform pt1 to local coordinate system
		for( k = 0; k < 4; k++ ) pnt[k] = pt1[k];
		BSmult_mats(4,4, rowInfo->csMatrix,0, 4,1, pnt, 0, pt1, &msg);

		// transform pt2 to local coordinate system
		for( k = 0; k < 4; k++ ) pnt[k] = pt2[k];
		BSmult_mats(4,4, rowInfo->csMatrix,0, 4,1, pnt, 0, pt2, &msg);

		if( xmin > pt1[0] ) xmin = pt1[0];
		if( xmin > pt2[0] ) xmin = pt2[0];

		if( xmax < pt1[0] ) xmax = pt1[0];
		if( xmax < pt2[0] ) xmax = pt2[0];

		if( ymin > pt1[1] ) ymin = pt1[1];
		if( ymin > pt2[1] ) ymin = pt2[1];

		if( ymax < pt1[1] ) ymax = pt1[1];
		if( ymax < pt2[1] ) ymax = pt2[1];

		if( zmin > pt1[2] ) zmin = pt1[2];
		if( zmin > pt2[2] ) zmin = pt2[2];

		if( zmax < pt1[2] ) zmax = pt1[2];
		if( zmax < pt2[2] ) zmax = pt2[2];

		_FREE(crv); // crv is not BS allocated
	}

	// Get actual corner point pt1 in local coordinate
	pt1[0] = xmin;
	if( rowInfo->tblOrient == VD_DRWLO_EN_DESCEND ) {
		pt1[1] = ymax;
	}
	else {
		pt1[1] = ymin;
	}
	pt1[2] = zmin;


	// Get the corner point pt2 that row should be at

	status =
	om$send( msg      = message VDdrwTblRow.VDgetRowNumber
						(&msg,&rowNo),
                 senderid = NULL_OBJID,
            	 targetid = rowId.objid,
            	 targetos = rowId.osnum );
	if( !(status&msg&1) ) {
		printf("VDdrwTblRow.VDgetRowNummer failed.\n");
		goto wrapup;
	}

	nbRows     = rowInfo->nbRows;
	startRowNo = rowInfo->startRowNo;
	
	status =
	om$send( msg      = message VDdrwTblHdr.VDgetRowHeight
						(&msg,rowNo,&rowHeight),
		senderid = NULL_OBJID,
		targetid = rowInfo->hdrId.objid,
		targetos = rowInfo->hdrId.osnum );
	if( !(status&msg&1) ) {
		printf("VDdrwTblHdr.VDgetRowHeight failed.\n");
		goto wrapup;
	}

	newHeight = fabs(ymax - ymin);
	if( fabs(rowHeight - newHeight) > 1.e-3 ) {
		status =
		om$send( msg      = message VDdrwTblHdr.VDnewRowHeight
						(&msg,rowNo,newHeight),
			senderid = NULL_OBJID,
			targetid = rowInfo->hdrId.objid,
			targetos = rowInfo->hdrId.osnum );
		if( !(status&msg&1) ) {
			printf("VDdrwTblHdr.VDnewRowHeight failed.\n");
			goto wrapup;
		}
	}

	if( rowNo == 0 ) {
		totalHeight = 0;
	}
	else if(rowNo <= (nbRows + startRowNo) && rowNo >= startRowNo ) {

		for( i = startRowNo; i < rowNo ; i++ ) {
			status =
			om$send( msg      = message VDdrwTblHdr.VDgetRowHeight
						(&msg,i,&rowHeight),
				senderid = NULL_OBJID,
				targetid = rowInfo->hdrId.objid,
				targetos = rowInfo->hdrId.osnum );
			if( !(status&msg&1) ) {
			 printf("VDdrwTblHdr.VDgetRowHeight failed.\n");
			 goto wrapup;
			}
			
			totalHeight += rowHeight;
		}
		totalHeight += rowInfo->hdrHeight;
	}
	else {
		printf("Invalid row number for row: ");
		vdobj$Print(objID = &rowId);
		status = OM_W_ABORT;
		goto wrapup;
	}

	for( i = 0; i < 3; i++ ) pt2[i] = rowInfo->hdrCornPt[i];

	if( rowInfo->tblOrient == VD_DRWLO_EN_DESCEND ) {
		pt2[1] = pt2[1] - totalHeight;// + rowInfo->hdrHeight;
	}
	else {
		pt2[1] += totalHeight;
	}

	// Now, we have actual corner pt1 and the correct corner pt2

	// get the distance dist between pt1 and pt2
	status = MA2ptdis( &msg, pt1, pt2, &dist );
	if( !(status&msg&1) ) {
		printf("MA2ptdis failed\n");
		goto wrapup;
	}


	// if pt1 is not conincide with pt2, move the row from pt1 to pt2

	if( dist > 1.e-3 ) {
		
		VD_drwtb_getMatrixFrom2Points(	&msg,
						pt1, pt2,
						&rowInfo->csId,
						&matType, matrix);
		if( !(msg&1) ) {
			printf("VD_drwtb_getMatrixFrom2Points failed.\n");
			goto wrapup;
		}

		status =
		om$send(msg      = message VDdrwTblRow.VDmoveRow
						(&msg,&matType,matrix),
			senderid = NULL_OBJID,
			targetid = rowId.objid,
			targetos = rowId.osnum );

		if( !(status&msg&1) ) {
			printf("VDdrwTblRow.VDmoveRow failed.\n");
			goto wrapup;
		}
	}

	status = 1;
wrapup:
	return status;
}

/*-------------------------------------------------------------------
 *
 */
IGRint	VDtblCheckRowNo(IGRint startRowNo, TGRid hdrId, IGRint *nextNo)
{
	IGRlong		status = 0, msg ;
	IGRint		i;
	IGRint		nbRows = 0, nbObjs = 0, rowNo = 1, startNo;
	TGRid		*rowList = NULL;

	if( hdrId.objid == NULL_OBJID )	{
		goto wrapup;
	}

	status =
	om$send( msg      = message VDdrwTblHdr.VDgetRowInfo
						(&msg,&nbRows,&startNo),
                 senderid = NULL_OBJID,
            	 targetid = hdrId.objid,
            	 targetos = hdrId.osnum );
	if( !(status&msg&1) || !nbRows ) {
		printf("VDdrwTblHdr.VDgetRowInfo failed or no rows.\n");
		goto wrapup;
	}

	rowList = _MALLOC( nbRows + 10, TGRid );
	if( !rowList ) goto wrapup;
	
	vdchn$GetList(	objID	= &hdrId, 
			chnName	= "VDdrwTblHdr.to_tblRows", 
			maxCnt	= nbRows+1, 
			cnt	= &nbRows,
			outIDs	= rowList);

	if( !nbRows ) {
		printf("Failed to get row list\n");
		goto wrapup;
	}

	rowNo = startRowNo;
	for( i = 0; i < nbRows; i++ ) {
		if( rowList[i].objid == NULL_OBJID) continue;
		status =
		om$send(msg      = message VDdrwTblRow.VDputRowNumber
						(&msg,rowNo),
			senderid = NULL_OBJID,
            		targetid = rowList[i].objid,
            		targetos = rowList[i].osnum );

		if( !(status&msg&1) || !nbRows ) {
			printf("VDdrwTblRow.VDputRoWNumber failed.\n");
			continue;
		}

		rowNo++;
	}

	if(nextNo) *nextNo = rowNo;

	status = 1;
wrapup:
	_FREE(rowList);
	return status;
}

/*-------------------------------------------------------------------
 *
 */
IGRint	VDtblDumpRow(TGRid *tblHdrId, TGRid rowId, FILE* fp, char **txtBuf)
{
	IGRlong		status = 0, msg ;
	IGRint		i, j, rowNo, emptyLen;
	IGRint		nbRows = 0, nbObjs = 0;
	IGRint		tblPartNo,startRowNo;
	IGRshort	hdrType,trailType,consType,tblOrient,csLoc;
	IGRshort	linedOut, usrFlag;
	IGRdouble	cornerPt[3], rowHeight;
	IGRchar		txt[128], txt1[128], txt2[128], txt3[128], buf[1024];
	IGRchar		*txtOut = NULL;
	TGRobj_env	*objOEs = NULL;
	TGRid		setId, csId, collId, hdrId;

	IGRint			nbAttrs = 0, nbPaths = 0;
	struct ACrg_coll	*attrs  = NULL;

	struct VDdrwlo_qtyExp	qty;

	if( !fp && !txtBuf ) goto wrapup;
	if( txtBuf ) *txtBuf = NULL;
	if( rowId.objid == NULL_OBJID ) goto wrapup;
	if( !tblHdrId || tblHdrId->objid == NULL_OBJID ) {
		status =
        	om$send( msg      = message VDdrwTblRow.VDgetTableHeader
               			                         (&msg,&hdrId,NULL),
			senderid = NULL_OBJID,
			targetid = rowId.objid,
			targetos = rowId.osnum );
		if( !(status&msg&1) ) {
			printf("The row is not connected to header\n");
			//goto wrapup;
        	}
	}
	else hdrId = *tblHdrId;

	vdobj$Get(	objID		= &rowId,
			className	= txt);
	
	// report row number and id
	status =
        om$send( msg      = message VDdrwTblRow.VDgetRowNumber
                                        (&msg,&rowNo),
                 senderid = NULL_OBJID,
                 targetid = rowId.objid,
                 targetos = rowId.osnum );
        if( !(status&msg&1) ) {
                printf("VDdrwTblRow.VDgetItemNumber failed\n");
		rowNo = -1;
        }
	
	strcpy(buf, "  ");
	sprintf(txt1, "[%d] %d,%d", rowNo,rowId.osnum,rowId.objid);
	sprintf(txt, "%-16s", txt1);
	strcat(buf, txt);

	// report item number
	status =
        om$send( msg      = message VDdrwTblRow.VDgetItemNumber
                                        (&msg,&i,txt),
                 senderid = NULL_OBJID,
                 targetid = rowId.objid,
                 targetos = rowId.osnum );
        if( !(status&msg&1) ) {
                printf("VDdrwTblRow.VDgetItemNumber failed\n");
		strcpy(txt, "-1");
        }
	
	sprintf(txt1, "[%s]", txt);
	sprintf(txt, "%-8s", txt1);
	strcat(buf, txt);

	// report lined out
	status =
        om$send( msg      = message VDdrwTblRow.VDisRowLinedOut
                                        (&msg,&linedOut),
                 senderid = NULL_OBJID,
                 targetid = rowId.objid,
                 targetos = rowId.osnum );
        if( !(status&msg&1) ) {
                printf("VDdrwTblRow.VDisRowLinedOut failed\n");
		linedOut = -1;
        }
	sprintf(txt1, "[%d]", linedOut);
	sprintf(txt, "%-8s", txt1);
	strcat(buf, txt);

	// report UserDefined
	status =
        om$send( msg      = message VDdrwTblRow.VDisUserDefinedRow
                                        (&msg,&usrFlag),
                 senderid = NULL_OBJID,
                 targetid = rowId.objid,
                 targetos = rowId.osnum );
        if( !(status&msg&1) ) {
                printf("VDdrwTblRow.VDisUserDefinedRow failed\n");
		usrFlag = -1;
        }

	sprintf(txt1, "[%d]", usrFlag);
	sprintf(txt, "%-8s", txt1);
	strcat(buf, txt);

	// report Expression for quantity
	status =
        om$send( msg      = message VDdrwTblRow.VDgetQtyExpr
                                        (&msg,&qty),
                 senderid = NULL_OBJID,
                 targetid = rowId.objid,
                 targetos = rowId.osnum );
        if( !(status&msg&1) ) {
                printf("VDdrwTblRow.VDgetQtyExpr failed\n");
		qty.nSflag = -1;
		qty.szExp[0] = '\0';
        }
	
	sprintf(txt1,"[%d]-[%s]", qty.nSflag,qty.szExp);
	sprintf(txt, "%-20s", txt1);
	strcat(buf, txt);

if( tblHdrId ) 
{
	// report row corner and height
	status =
        om$send( msg      = message VDdrwTblHdr.VDgetRowHeight
                              (&msg,rowNo,&rowHeight),
                 senderid = NULL_OBJID,
                 targetid = hdrId.objid,
                 targetos = hdrId.osnum );
        if( !(status&msg&1) ) {
                printf("VDdrwTblHdr.VDgetRowHeight failed\n");
		rowHeight = -1;
        }
	sprintf(txt1,"[%g]", rowHeight);
	sprintf(txt, "%-10s", txt1);
	strcat(buf, txt);
	
	cornerPt[0] = -999;
	cornerPt[1] = -999;
	cornerPt[2] = -999;
	status =
        om$send( msg      = message VDdrwTblHdr.VDgetCornerPointForRow
                              (&msg,rowNo,cornerPt),
                 senderid = NULL_OBJID,
                 targetid = hdrId.objid,
                 targetos = hdrId.osnum );
        if( !(status&msg&1) ) {
                printf("VDdrwTblHdr.VDgetCornerPointForRow failed\n");
        }

	sprintf(txt1, "[%g,%g,%g]",cornerPt[0],cornerPt[1],cornerPt[2]);
	sprintf(txt, "%-30s", txt1);
	strcat(buf, txt);
}
	txtOut = _CALLOC( strlen(buf)+1, char );
	if( !txtOut ) goto wrapup;
	strcpy( txtOut, buf );
	emptyLen = strlen(buf);
	
	// report parent object list, directly to fp in case overflow

	status =
        om$send( msg      = message VDdrwTblRow.VDgetParentSetId
                                        (&msg,&setId),
                 senderid = NULL_OBJID,
                 targetid = rowId.objid,
                 targetos = rowId.osnum );
        if( !(status&msg&1) ) {
                printf("VDdrwTblRow.VDgetParentSetId failed for rowNo: [%d]\n",
			 rowNo);
        }
	else {
		sprintf(txt1, "(%d,%d) ", setId.osnum,setId.objid);
		sprintf(txt2, "%s%ds", "%-", strlen(txt1));
		sprintf(buf, txt2, txt1);
		txtOut = _REALLOC( txtOut, strlen(txtOut)+strlen(buf)+2, char );
		strcat( txtOut, buf );

		status =
		om$send( msg      = message VDdrwTblRow.VDgetParentObjectList
					(&msg,&nbObjs,NULL),
			senderid = NULL_OBJID,
			targetid = rowId.objid,
			targetos = rowId.osnum );
	      if( !(status&msg&1) || nbObjs < 1) {
		   //printf("VDdrwTblRow.VDgetParentObjectList failed for rowNo: [%d]\n", rowNo);
	      }
	      else {

		objOEs = _MALLOC(nbObjs, TGRobj_env);
		if(!objOEs) {
			printf("Cannot allocate parent objects for row %d\n",rowNo);
			goto wrapup;
		}

		status =
		om$send( msg      = message VDdrwTblRow.VDgetParentObjectList
                                        (&msg,&nbObjs,objOEs),
			senderid = NULL_OBJID,
			targetid = rowId.objid,
			targetos = rowId.osnum );
		if( !(status&msg&1) ) {
			printf("VDdrwTblRow.VDgetParentObjectList failed\n");
        	}
		for( i = 0; i < nbObjs; i++ ) {
			sprintf(buf,"%d,%d|",
				objOEs[i].obj_id.osnum,objOEs[i].obj_id.objid);
			txtOut = _REALLOC( txtOut, strlen(txtOut)+strlen(buf)+2, char );
			strcat( txtOut, buf );

		}
	    }
	}

	txtOut = _REALLOC( txtOut, strlen(txtOut)+3, char );
	strcat( txtOut, "\n" );

	status = 
	om$send ( msg      = message ACcpx.ACfind_temp_obj(
							(int *)&msg,
							"coll",
                                                        &collId ),
                        senderid = NULL_OBJID,
                        targetid = rowId.objid,
                        targetos = rowId.osnum );
        if( !(status&1) || collId.objid == NULL_OBJID ) {
		printf("failed to get collId for the row\n");
	}
	else {
		status =
		om$send( msg      = message ACrg_collect.AClist_attribute(
							    &msg,
                                                            0,
                                                            NULL,
                                                            &nbAttrs),
			senderid = NULL_OBJID,
			targetid = collId.objid,
			targetos = collId.osnum );
		if( !(status&msg&1) || (nbAttrs<1) ) {
			printf("failed to get nbAttrs\n");
		}
	}

	if( (status&msg&1) && nbAttrs > 0 ) {
		attrs = _MALLOC(nbAttrs, struct ACrg_coll);
		if( !attrs ) goto wrapup;
	}

	if( (status&msg&1) && nbAttrs ) {
	    status =
	    om$send(	msg      = message ACrg_collect.AClist_attribute(&msg,
                                                            nbAttrs,
                                                            attrs,
                                                            &nbAttrs),
			senderid = NULL_OBJID,
			targetid = collId.objid,
			targetos = collId.osnum );
	    if( (status&msg&1) ) {
		if( !strcmp( attrs[0].name, "occurance_count" ) &&
		    attrs[0].desc.type == AC_ATTRIB_TEXT )
		{
		     nbPaths = atoi(attrs[0].desc.value.att_txt );
		}
		else nbPaths = 0;

		for( i = 1; i < nbPaths; i++ ) {
			buf[0] = '\0';
			for( j = 0; j < emptyLen; j++ ) strcat(buf, " ");
			strcat( buf, attrs[i].desc.value.att_txt );
			strcat( buf, "\n" );
			txtOut = _REALLOC( txtOut, strlen(txtOut)+strlen(buf)+2, char );
			strcat( txtOut, buf );
		}
	    }
	}

	if( fp ) fprintf(fp, txtOut );
	if( txtBuf ) *txtBuf = txtOut;

	status = 1;
wrapup:
	if(!txtBuf) _FREE(txtOut);
	_FREE(objOEs);
	_FREE(attrs);
	return status;
}

/*---------------------------------------------------------------------------
 *
 */
IGRint	VDtblDumpHeaderAndRows(IGRint nth, TGRid hdrId, FILE *fp)
{
	IGRlong		status = 0, msg ;
	IGRint		i;
	IGRint		nbRows = 0;
	IGRint		rowNo,tblPartNo,startRowNo;
	IGRshort	hdrType,trailType,consType,tblOrient,csLoc;
	IGRdouble	cornerPt[3];
	IGRchar		txt[128], txt1[128], txt2[128], txt3[128], buf[1024];
	TGRid		rowId, rowList[1000], csId;

	buf[0] = '\0';

	if( !fp ) goto wrapup;
	if( hdrId.objid == NULL_OBJID ) goto wrapup;

	vdobj$Get(	objID		= &hdrId,
			className	= txt1);
	VDobjGetPath(NULL, &hdrId, txt2);
	
	fprintf(fp, "%s[%d] %d,%d %s info:\n", 
		txt1,nth,hdrId.osnum, hdrId.objid,txt2);

	// report nbRows and startRowNo
	status =
	om$send( msg      = message VDdrwTblHdr.VDgetRowInfo(&msg,&nbRows,&startRowNo),
                 senderid = NULL_OBJID,
            	 targetid = hdrId.objid,
            	 targetos = hdrId.osnum );
	if( !(status&msg&1) ) {
		printf("VDdrwTblHdr.VDgetRowInfo failed. Quit reporting it\n");
	}

	sprintf(txt1, "%-25s[%d]\n", "\tnbRows:", nbRows);
	strcat(buf, txt1);

	sprintf(txt1, "%-25s[%d]\n", "\tstartRowNo:", startRowNo);
	strcat(buf, txt1);

	// report ConstructInfo
	status =
        om$send( msg      = message VDdrwTblHdr.VDgetConstructInfo
					( &msg,&hdrType,&trailType,&consType),
                 senderid = NULL_OBJID,
                 targetid = hdrId.objid,
                 targetos = hdrId.osnum );
        if( !(status&msg&1) ) {
                printf("VDdrwTblHdr.VDgetRowInfo failed. Quit reporting it\n");
        }
	sprintf(txt1, "%-25s[%d]\n", "\theaderType:", hdrType);
	strcat(buf, txt1);

	sprintf(txt1, "%-25s[%d]\n", "\ttrailerType:", trailType);
	strcat(buf, txt1);

	sprintf(txt1, "%-25s[%d]\n", "\ttoConstructType:", consType);
	strcat(buf, txt1);

	// report TableInfo
	status =
        om$send( msg      = message VDdrwTblHdr.VDgetTableInfo
					( &msg,txt1,&tblPartNo,&tblOrient),
                 senderid = NULL_OBJID,
                 targetid = hdrId.objid,
                 targetos = hdrId.osnum );
        if( !(status&msg&1) ) {
                printf("VDdrwTblHdr.VDgetTableInfo failed. Quit reporting it\n");
        }
	sprintf(txt1, "%-25s[%d]\n", "\ttblPartNo:", tblPartNo);
	strcat(buf, txt1);

	sprintf(txt1, "%-25s[%d]\n", "\ttblOrient:", tblOrient);
	strcat(buf, txt1);
	
	// report RowConstructInfo and cs location
	status =
        om$send( msg      = message VDdrwTblHdr.VDgetRowConstructInfo
			    ( &msg,nth,txt1,&tblOrient,&csId,cornerPt,txt2),
                 senderid = NULL_OBJID,
                 targetid = hdrId.objid,
                 targetos = hdrId.osnum );
        if( !(status&msg&1) ) {
                printf("VDdrwTblHdr.VDgetRowConstructInfo failed. Quit reporting it\n");
        }

	status =
        om$send( msg      = message VDdrwTblHdr.VDgetCsLocation( &msg,&csLoc),
                 senderid = NULL_OBJID,
                 targetid = hdrId.objid,
                 targetos = hdrId.osnum );
        if( !(status&msg&1) ) {
                printf("VDdrwTblHdr.VDgetCsLocation failed. Quit reporting it\n");
                goto wrapup;
        }

	sprintf(txt1, "%-25s[%d]\n", "\tcsLocation:", csLoc);
	strcat(buf, txt1);

	sprintf(txt1, "%-25s[%g,%g,%g]\n", "\tcornerPoint:",
			cornerPt[0],cornerPt[1],cornerPt[2]);
	strcat(buf, txt1);

	vdchn$GetList(	objID	= &hdrId, 
			chnName	= "VDdrwTblHdr.to_tblRows", 
			maxCnt	= 500, 
			cnt	= &nbRows,
			outIDs	= rowList);
	sprintf(txt1, "%-25s[%d]\n", "\tnbRows from channel:", nbRows);
	strcat(buf, txt1);

	// header done
	fprintf(fp, buf);

	// dump rows
	strcpy(buf, "  ");
        sprintf(txt, "%-16s", "Object");	strcat(buf, txt);
        sprintf(txt, "%-8s",  "Item");		strcat(buf, txt);
	sprintf(txt, "%-8s",  "LnOut");		strcat(buf, txt);
	sprintf(txt, "%-8s",  "usFlg");		strcat(buf, txt);
	sprintf(txt, "%-20s", "QtyExp");	strcat(buf, txt);
	sprintf(txt, "%-10s", "Height");	strcat(buf, txt);
	sprintf(txt, "%-30s", "Corner");	strcat(buf, txt);
	sprintf(txt, "%-30s", "Parents");	strcat(buf, txt);
	strcat(buf, "\n");
	fprintf(fp, buf);
	
	for( i = 0; i < nbRows; i++ ) {
		VDtblDumpRow(&hdrId, rowList[i], fp, NULL);
	}

	status = 1;
wrapup:
	return status;
}

/*---------------------------------------------------------------------------
 *
 */
IGRint	VDtblExport ( TGRid *tblId, IGRchar *fileName )
{
	IGRlong		status = 0, msg ;
	IGRint		i;
	IGRint		nbHdrs = 0, nbRows = 0;
	IGRchar		txt[128], txt1[128], txt2[128], txt3[128], buf[1024];
	TGRid		*hdrs = NULL;
	FILE		*fp = NULL;

	if( !tblId || tblId->objid == NULL_OBJID ) {
		printf("Inout table is null\n");
		goto wrapup;
	}

	UI_status("Processing ....");

	fp = fopen( fileName, "wt" );
	if( !fp ) {
		printf("Open file failed\n");
		goto wrapup;
	}

	// report table info

	vdobj$Get(	objID		= tblId,
			className	= txt1);
	VDobjGetPath(NULL, &tblId, txt2);
	
	sprintf( buf,	"Table [%d,%d] %s %s info:\n",
			tblId->osnum,tblId->objid,txt1,txt2);
	fprintf(fp, buf);

	// report table layout name
	status =
	om$send( msg      = message VDdrwTbl.VDgetTableLayoutName(&msg, txt),
                 senderid = NULL_OBJID,
            	 targetid = tblId->objid,
            	 targetos = tblId->osnum );
	if( !(status&msg&1) ) {
		printf("VDdrwTbl.VDgetTableLayoutName failed. Quit cmd\n");
		goto wrapup;
	}
	sprintf(buf, "%-25s[%s]\n", "\tlayout:", txt);
	
	// report table attribute driven symbol table name
	status =
	om$send( msg      = message VDdrwTbl.VDgetAdsTblName(&msg, txt),
                 senderid = NULL_OBJID,
            	 targetid = tblId->objid,
            	 targetos = tblId->osnum );
	if( !(status&msg&1) ) {
		printf("VDdrwTbl.VDgetAdsTblName failed. Quit cmd\n");
		goto wrapup;
	}
	sprintf(txt1, "%-25s[%s]\n", "\tads:", txt);
	strcat(buf, txt1);
	
	// report table layout type
	status =
	om$send( msg      = message VDdrwTbl.VDgetTableType(&msg, txt),
                 senderid = NULL_OBJID,
            	 targetid = tblId->objid,
            	 targetos = tblId->osnum );
	if( !(status&msg&1) ) {
		printf("VDdrwTbl.VDgetTableType failed. Quit cmd\n");
		goto wrapup;
	}
	sprintf(txt1, "%-25s[%s]\n", "\tlayout type:", txt);
	strcat(buf, txt1);

	// report table the number of table headers
	status =
        om$send( msg      = message VDdrwTbl.VDgetTableParts(&msg,&nbHdrs,NULL),
                 senderid = NULL_OBJID,
                 targetid = tblId->objid,
                 targetos = tblId->osnum );
        if( !(status&msg&1) ) {
                printf("VDdrwTbl.VDgetTableParts failed. Quit cmd\n");
                goto wrapup;
        }
	sprintf(txt1, "%-25s[%d]\n", "\theader count:", nbHdrs);
	strcat(buf, txt1);

	// report total row number
	status =
        om$send( msg      = message VDdrwTbl.VDgetTotalNbOfRows(&msg,&nbRows),
                 senderid = NULL_OBJID,
                 targetid = tblId->objid,
                 targetos = tblId->osnum );
        if( !(status&msg&1) ) {
                printf("VDdrwTbl.VDgetTableNbOfRows failed. Quit cmd\n");
                goto wrapup;
        }
	sprintf(txt1, "%-25s[%d]\n", "\trow count:", nbRows);
	strcat(buf, txt1);

	// done table info report
	fprintf(fp, buf);

	// process each header
	if( !nbHdrs ) {
		printf("No headers connected to the table\n");
		goto wrapup;
	}

	hdrs = _MALLOC( nbHdrs, TGRid );
	if( !hdrs ) {
		printf("Faile to allocate for headers\n");
		goto wrapup;
	}

	status =
        om$send( msg      = message VDdrwTbl.VDgetTableParts(&msg,&nbHdrs,hdrs),
                 senderid = NULL_OBJID,
                 targetid = tblId->objid,
                 targetos = tblId->osnum );
        if( !(status&msg&1) ) {
                printf("VDdrwTbl.VDgetTableParts failed for headers. Quit cmd\n");
                goto wrapup;
        }

	for(i = 0; i < nbHdrs; i++ ) {
		VDtblDumpHeaderAndRows(i, hdrs[i], fp);
	}
	
	status = 1;
wrapup:
	_FREE(hdrs);
	if(fp) fclose(fp) ;
	return status;
}

/*---------------------------------------------------------------------------
 *
 */
IGRint	VDtblValidateRows ( TGRid	*tblId )
{
	IGRlong		status = 0, msg ;
	IGRdouble	rhDim, matrix[16];
	IGRpoint	pt;
	IGRint		i, j, rowNo;
	IGRint		nbHdrs = 0, nbRows = 0, startRowNo = 1, nextNo;
	TGRid		*hdrs = NULL;
	TGRid		csId;
	RowInfo		rowInfo;

	if( !tblId || tblId->objid == NULL_OBJID ) {
		printf("Inout table is null\n");
		goto wrapup;
	}

	UI_status("Processing ....");

	status =
        om$send( msg      = message VDdrwTbl.VDgetTableParts(&msg,&nbHdrs,NULL),
                 senderid = NULL_OBJID,
                 targetid = tblId->objid,
                 targetos = tblId->osnum );
        if( !(status&msg&1) ) {
                printf("VDdrwTbl.VDgetTableParts failed. Quit cmd\n");
                goto wrapup;
        }

	status =
        om$send( msg      = message VDdrwTbl.VDgetTotalNbOfRows(&msg,&nbRows),
                 senderid = NULL_OBJID,
                 targetid = tblId->objid,
                 targetos = tblId->osnum );
        if( !(status&msg&1) ) {
                printf("VDdrwTbl.VDgetTableNbOfRows failed. Quit cmd\n");
                goto wrapup;
        }

	// process each header
	if( !nbHdrs ) {
		printf("No headers connected to the table\n");
		goto wrapup;
	}

	hdrs = _MALLOC( nbHdrs, TGRid );
	if( !hdrs ) {
		printf("Faile to allocate for headers\n");
		goto wrapup;
	}

	status =
        om$send( msg      = message VDdrwTbl.VDgetTableParts(&msg,&nbHdrs,hdrs),
                 senderid = NULL_OBJID,
                 targetid = tblId->objid,
                 targetos = tblId->osnum );
        if( !(status&msg&1) ) {
                printf("VDdrwTbl.VDgetTableParts failed for headers. Quit cmd\n");
                goto wrapup;
        }

	startRowNo = 1;
	for(i = 0; i < nbHdrs; i++ ) {
		status = VDtblCheckRowNo(startRowNo, hdrs[i], &nextNo);
		if( !status ) {
			printf("VDtblCheckRowNo failed for startNo %d",startRowNo);
			continue;
		}
		
		status =
		om$send( msg      = message VDdrwTblHdr.VDputStartRowNo
							(&msg,startRowNo),
			senderid = NULL_OBJID,
			targetid = hdrs[i].objid,
			targetos = hdrs[i].osnum );
		if( !(status&msg&1) ) {
			printf("VDdrwTblHdr.VDputStartRowNo failed for startNo %d",startRowNo);
			continue;
		}

		rhDim = (double)(nextNo - startRowNo + 2);

		// fix the dimension of rowHeights
		status =
                om$send( msg      = message VDdrwTblHdr.VDgetRowHeight
                                                     (&msg,-1,&rhDim),
                        senderid = NULL_OBJID,
                        targetid = hdrs[i].objid,
                        targetos = hdrs[i].osnum );
/*
                om$send( msg      = message VDdrwTblHdr.VDsetSizeOfRowHeights
                                                     (&msg),
                        senderid = NULL_OBJID,
                        targetid = hdrs[i].objid,
                        targetos = hdrs[i].osnum );
*/

		startRowNo = nextNo;
	}
	
	// fix row positions

	for( i = 0; i < nbHdrs; i++ ) {

		// get nbRows and startRowNo
		status =
                om$send( msg      = message VDdrwTblHdr.VDgetRowInfo
                                                     (&msg,&nbRows,&startRowNo),
                        senderid = NULL_OBJID,
                        targetid = hdrs[i].objid,
                        targetos = hdrs[i].osnum );
		if( !(status&msg&1)) {
			printf("Failed to get RowIfo for header %d\n", i);
			continue;
		}
		
		// get header corner
		status =
                om$send( msg      = message VDdrwTblHdr.VDgetCornerPointForRow
                                                     (&msg,0,rowInfo.hdrCornPt),
                        senderid = NULL_OBJID,
                        targetid = hdrs[i].objid,
                        targetos = hdrs[i].osnum );
		if( !(status&msg&1)) {
			printf("Failed to get corner for header %d\n", i);
			continue;
		}
		
		// get header height by corner
		status =
                om$send( msg      = message VDdrwTblHdr.VDgetCornerPointForRow
                                                   (&msg,startRowNo,pt),
                        senderid = NULL_OBJID,
                        targetid = hdrs[i].objid,
                        targetos = hdrs[i].osnum );
		if( !(status&msg&1)) {
			printf("Failed to get height for header %d\n", i);
			continue;
		}
		rowInfo.nbRows    = nbRows;
		rowInfo.hdrHeight = fabs(rowInfo.hdrCornPt[1] - pt[1]);
		
		// get cs location
		status =
                om$send( msg      = message VDdrwTblHdr.VDgetCsLocation
                                                     (&msg,&rowInfo.csLocation),
                        senderid = NULL_OBJID,
                        targetid = hdrs[i].objid,
                        targetos = hdrs[i].osnum );
		if( !(status&msg&1)) {
			printf("Failed to get cs location for header %d\n", i);
			continue;
		}

		// get table orient, header corner and cs
		status =
                om$send( msg      = message VDdrwTblHdr.VDgetRowConstructInfo
                                                     (	&msg,
							0,	// rowNo
							NULL,	// layout
							&rowInfo.tblOrient,
							&csId,
							rowInfo.hdrCornPt,
							NULL),
                        senderid = NULL_OBJID,
                        targetid = hdrs[i].objid,
                        targetos = hdrs[i].osnum );
		if( !(status&msg&1)) {
			printf("Failed to get construct info for header %d\n", i);
			continue;
		}

		
		// get cs matrix
		status =
                om$send( msg      = message GRgencs.GRgetmatrix
                                                     (	&msg,
							matrix),
                        senderid = NULL_OBJID,
                        targetid = csId.objid,
                        targetos = csId.osnum );
		if( !(status&msg&1)) {
			printf("Failed to get cs matrix for header %d\n", i);
			continue;
		}
		
		// get inverse matrix from cs matrix
		BSinv_mat( 4, matrix, rowInfo.csMatrix, &msg );
		if( msg != BSSUCC ) {
			printf("BSinv_mat failed for header %d\n", i);
			goto wrapup;
		}

		rowInfo.csId       = csId;
		rowInfo.hdrId      = hdrs[i];
		rowInfo.startRowNo = startRowNo;

		rowNo = startRowNo;
		for( j = 0; j < nbRows; j++ ) {
			status =
                	om$send(msg      = message VDdrwTblHdr.VDrowNoToGRid
                                                     (	&msg,
							rowNo, &rowInfo.rowId),
				senderid = NULL_OBJID,
				targetid = hdrs[i].objid,
				targetos = hdrs[i].osnum );
			if( !(status&msg&1)) {
				printf("ERROR: Failed to get row %d\n", j);
				goto wrapup;
			}
			rowNo++;

			// real work
			VDtblCheckRowPosition( &rowInfo );
		}
	}

	status = 1;
wrapup:
	_FREE(hdrs);
	return status;
}

/*---------------------------------------------------------------------------
 *
 */
IGRint	VDtblValidOTMpath( TGRid *rowId )
{
	IGRlong		status = 0, msg;
	IGRint		i;
	IGRint		nbObjs = 0, index;
	TGRid		collId;
	TGRobj_env	*objOEs = NULL;

	IGRint			nbOldAttrs	= 0;
	struct ACrg_coll	*attrs		= NULL;
	struct ACrg_coll	*oldAttrs	= NULL;

	if( !rowId || rowId->objid == NULL_OBJID ) goto wrapup;

	status =
	om$send(msg      = message ACcpx.ACfind_temp_obj (	(int*)&msg,
								"coll",
								&collId),
		senderid = NULL_OBJID,
		targetid = rowId->objid,
		targetos = rowId->osnum );
	if( !(status&msg&1) || collId.objid == NULL_OBJID ) goto wrapup;

	status =
	om$send(msg      = message ACrg_collect.AClist_attribute(
								&msg,
								0,
								NULL,
								&nbOldAttrs),
		senderid = NULL_OBJID,
		targetid = collId.objid,
		targetos = collId.osnum );
	if( !(status&msg&1) ) {
		nbOldAttrs = 0;
	}

	if( nbOldAttrs ) {

		/* may need to store user value. do it later */

		oldAttrs = _MALLOC(nbOldAttrs, struct ACrg_coll);
		if( !oldAttrs ) goto wrapup;

		status =
		om$send(msg      = message ACrg_collect.AClist_attribute(
								&msg,
								nbOldAttrs,
								oldAttrs,
								&nbOldAttrs),
			senderid = NULL_OBJID,
			targetid = collId.objid,
			targetos = collId.osnum );
		if( !(status&msg&1) || !oldAttrs ) {
			goto wrapup;
		}

		status =
		om$send( msg      = message ACrg_collect.ACset_list_attribute(
                                                                &msg,
                                                                0,
                                                                NULL),
			senderid = NULL_OBJID,
			targetid = collId.objid,
			targetos = collId.osnum );
		if( !(status&msg&1) ) goto wrapup;

	}

	status =
	om$send(msg      = message VDdrwTblRow.VDgetParentObjectList(
                                                        &msg,
                                                        &nbObjs,
                                                        NULL),
		senderid = NULL_OBJID,
		targetid = rowId->objid,
		targetos = rowId->osnum );

	if( !(status&msg&1) ) goto wrapup;

	if( !nbObjs ) {
		status = 1;
		goto wrapup;
	}
	objOEs = _MALLOC( nbObjs, struct GRobj_env );
	if( !objOEs ) goto wrapup;


	status =
	om$send(msg      = message VDdrwTblRow.VDgetParentObjectList(
                                                        &msg,
                                                        &nbObjs,
                                                        objOEs),
		senderid = NULL_OBJID,
		targetid = rowId->objid,
		targetos = rowId->osnum );

	if( !(status&msg&1) ) goto wrapup;

	attrs = _MALLOC( (nbOldAttrs + nbObjs + 1), struct ACrg_coll );
	if( !nbObjs ) goto wrapup;

	attrs[0].desc.type = AC_ATTRIB_TEXT;
	strcpy(  attrs[0].name, "occurance_count" );
	sprintf( attrs[0].desc.value.att_txt, "%d", nbObjs );
	
	for( i = 0; i < nbObjs; i++ ) {
		attrs[i+1].desc.type = AC_ATTRIB_TEXT;
		sprintf( attrs[i+1].name, "occurance_%d", i+1);

		status = 
		VDtblRowExecPplName (	&msg, &objOEs[i], rowId, 
					"VDrow_info", "name", 
					attrs[i+1].desc.value.att_txt );
		if( !(status&msg&1) ) {
			printf("VDtblRowExecPplName failed\n");
			goto wrapup;
		}

	}

	status =
	om$send( msg      = message ACrg_collect.ACset_list_attribute(
                                                           &msg,
                                                           1 + nbObjs,
                                                           attrs),
		senderid = NULL_OBJID,
		targetid = collId.objid,
		targetos = collId.osnum );
	if( !(status&msg&1) ) goto wrapup;

	status = 1;
wrapup:
	_FREE(objOEs);
	_FREE(attrs);
	_FREE(oldAttrs);
	return (int)status;
}


/*---------------------------------------------------------------------------
 *
 */
IGRint	VDtblValidateOTMpaths ( TGRid	*tblId )
{
	IGRlong		status = 0, msg ;
	IGRdouble	rhDim, matrix[16];
	IGRchar		path[80];
	IGRint		i, j, rowInd, rowCnt;
	IGRint		nbHdrs   = 0, nbRows = 0, nbNodes = 0, nbAttrs = 0;
	TGRid		*hdrIds  = NULL;
	TGRid		*rowList = NULL;
	TGRid		rowId;
	

	if( !tblId || tblId->objid == NULL_OBJID ) {
		printf("Inout table is null\n");
		goto wrapup;
	}

	UI_status("Processing ....");

	/*
	 * Need to check if table is from a OTM tree
 	 */

	status =
        om$send( msg      = message VDdrwTbl.VDgetTableParts(&msg,&nbHdrs,NULL),
                 senderid = NULL_OBJID,
                 targetid = tblId->objid,
                 targetos = tblId->osnum );
        if( !(status&msg&1) ) {
                printf("VDdrwTbl.VDgetTableParts failed. Quit cmd\n");
                goto wrapup;
        }

	status =
        om$send( msg      = message VDdrwTbl.VDgetTotalNbOfRows(&msg,&nbRows),
                 senderid = NULL_OBJID,
                 targetid = tblId->objid,
                 targetos = tblId->osnum );
        if( !(status&msg&1) ) {
                printf("VDdrwTbl.VDgetTableNbOfRows failed. Quit cmd\n");
                goto wrapup;
        }

	// process each header
	if( !nbHdrs ) {
		printf("No headers connected to the table\n");
		goto wrapup;
	}

	hdrIds = _MALLOC( nbHdrs, TGRid );
	if( !hdrIds ) {
		printf("Faile to allocate for headers\n");
		goto wrapup;
	}

	/*
	 * Process rows
	 */
	status =
        om$send( msg      = message VDdrwTbl.VDgetTableParts(&msg,&nbHdrs,hdrIds),
                 senderid = NULL_OBJID,
                 targetid = tblId->objid,
                 targetos = tblId->osnum );
        if( !(status&msg&1) ) {
                printf("VDdrwTbl.VDgetTableParts failed for headers. Quit cmd\n");
                goto wrapup;
        }

	rowList = _MALLOC( nbRows, TGRid );
	if( rowList == NULL ) goto wrapup;

	rowInd = 0;
	for(i = 0; i < nbHdrs; i++ ) {

		if( hdrIds[i].objid == NULL_OBJID ) continue;

		rowCnt = 0;
		vdchn$GetList(	objID	= &hdrIds[i], 
				chnName	= "VDdrwTblHdr.to_tblRows", 
				maxCnt	= nbRows, 
				cnt	= &rowCnt,
				outIDs	= &rowList[rowInd]);
		rowInd += rowCnt;
	}
	
	nbRows = rowInd;

	for( i = 0; i < nbRows; i++ ) {
		VDtblValidOTMpath( &rowList[i] );
	}
	
	status = 1;
wrapup:
	_FREE(hdrIds);
	_FREE(rowList);
	return status;
}

end implementation Root;
