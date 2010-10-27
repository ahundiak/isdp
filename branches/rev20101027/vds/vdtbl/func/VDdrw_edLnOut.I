/* $Id: VDdrw_edLnOut.I,v 1.1 2002/06/06 17:02:20 ylong Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vds/vdtbl/func/VDdrw_edLnOut.I
 *
 * Description: edit lined out row, set row attributes by feet
 *
 * Dependencies: 
 *
 * Revision History:
 *      $Log: VDdrw_edLnOut.I,v $
 *      Revision 1.1  2002/06/06 17:02:20  ylong
 *      *** empty log message ***
 *
 *
 * History:
 * MM/DD/YY	AUTHOR		DESCRIPTION
 * 06/05/02	ylong		Creation for CR6391
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
	IGRdouble	csMatrix[16];
	IGRint		nbCols;
	IGRdouble	*xcor;
} RowDataInfo;
	
#define EPS	1.e-8
	
	
from	ACcpx		import  ACfind_temp_obj;
from	ACrg_collect	import	AClist_attribute,
				ACset_list_attribute;

from	VDdrwTbl	import	VDgetTableParts,
				VDgetTotalNbOfRows;

from	VDdrwTblHdr	import	VDgetRowInfo,
				VDgetTableInfo,
				VDgetRowConstructInfo,
				VDrowNoToGRid;

from	VDdrwTblRow	import	VDisRowLinedOut,
				VDgetParentObjectList;

from	GRowner		import	GRget_number_components;
from	GRgencs		import	GRgetmatrix;
from	GR3dtext	import	GRgetrang;

/*--------------------------------------------------------
 * Input row id, print row attributes
 */
IGRint	VDtblPrintRowAttributes( TGRid *rowId )
{
    IGRint		sts = 0, i;
    IGRint		nbAttrs = 0;
    IGRlong		status, msg;
    TGRid		collId;
    struct ACrg_coll	*attrs = NULL;

    if( !rowId || rowId->objid == NULL_OBJID ) goto wrapup;

    printf("Attributes for: "); vdobj$Print(objID=rowId);

    status =
    om$send(	msg	 = message VDdrwTblRow.ACfind_temp_obj(
                                                                (int *)&msg,
                                                                "coll",
                                                                &collId ),
		senderid = NULL_OBJID,
		targetid = rowId->objid,
		targetos = rowId->osnum );

    if( collId.objid == NULL_OBJID )
    {
	printf("\tNo collector !!!\n");
	goto wrapup;
    }
	
    status =
    om$send( msg      = message ACrg_collect.AClist_attribute(&msg,
                                                              0,
                                                              NULL,
                                                              &nbAttrs),
             senderid = NULL_OBJID,
             targetid = collId.objid,
             targetos = collId.osnum );
    if( !(status&msg&1) || !nbAttrs )
    {
        printf("\tEmpty collector !!!\n");
        goto wrapup;
    }

    attrs = _MALLOC( nbAttrs, struct ACrg_coll);
    if( !attrs ) goto wrapup;

    status =
    om$send( msg      = message ACrg_collect.AClist_attribute(&msg,
                                                              nbAttrs,
                                                              attrs,
                                                              &nbAttrs),
             senderid = NULL_OBJID,
             targetid = collId.objid,
             targetos = collId.osnum );
    if( !(status&msg&1) || !nbAttrs )
    {
        printf("\tEmpty collector !!!\n");
        goto wrapup;
    }
    
    for( i = 0; i < nbAttrs; i++ )
    {
	printf("\tname[%d]: [%s]\n", i, attrs[i].name );
	if( attrs[i].desc.type == AC_ATTRIB_TEXT )
	{ 
	    printf("\tvalue[%d]: [%s]\n", i, attrs[i].desc.value.att_txt);
	}
	else if( attrs[i].desc.type == AC_ATTRIB_DOUBLE )
	{
	    printf("\tvalue[%d]: [%g]\n", i, attrs[i].desc.value.att_exp);
	}
	else printf("\tvalue[%d]: UNKOWN TYPE !!!\n");
    }

    sts = 1;
wrapup:
    _FREE( attrs );
    return sts;
}

/*-------------------------------------------------------------------
 * Set row attrbutes from feet
 */
IGRint	VDtblSetRowAttFromFeet
(
		TGRid		*rowId,		// in, row id
		IGRint		nbCols,		// in, number of columns
		IGRdouble	*xcor,		// in, column positions, local
		IGRdouble	*trMatrix	// in, transfermation matrix
)						//    from world to table local
{
    IGRlong	status = 0, msg ;
    IGRint	i, k, cnt = 0, maxCnt = 0, lineNo;
    TGRid	collId;
    TGRid	*txtIds = NULL;
    TGRobj_env	footOE;
    IGRshort	matType, world = 1;
    IGRdouble	matrix[16];
    IGRdouble	pt1[4], pt2[4], pnt[4];
    IGRchar	txt[1024], attName[40], invalid[] = "(invlaid)";
    IGRchar	*buf = NULL, *datValue = NULL, **attValues = NULL;
    GRrange	range;
    TACrg_coll	attr;
    IGRint	*colNos = NULL, *linNos = NULL;
	
    if( !rowId || rowId->objid == NULL_OBJID ) {
    	goto wrapup;
    }

    // get graph feet
    vdobj$GetFoot(	objID		= rowId,
			footName	= "geom",
			footOE		= &footOE);

    if( footOE.obj_id.objid == NULL_OBJID ) {
    	//printf("Failed to get GRowner for: ");
    	//vdobj$Print(objID = &rowId);
    	goto wrapup;
    }

    // get max number of graphics
    status =
    om$send( msg      = message GRowner.GRget_number_components
						( &msg, &maxCnt ),
                 senderid = NULL_OBJID,
            	 targetid = footOE.obj_id.objid,
            	 targetos = footOE.obj_id.osnum );

    if( !(status&msg&1) || maxCnt < 1 ) {
    	//printf("GRowner.GRget_number_components failed. for row: ");
    	//vdobj$Print(objID = &rowId);
    	goto wrapup;
    }

    txtIds = _MALLOC( maxCnt, TGRid );
    if( !txtIds ) goto wrapup;

    // get text objects
    vdchn$GetList(	objOE	= &footOE,
			chnName	= "GRcmpowner.to_components",
			maxCnt	= maxCnt,
			cnt	= &cnt,
			outIDs  = txtIds,
			FltrClNam = "GR3dtext" );

    if( cnt < 1 ) {
    	//printf("vdchn$GetList failed for row: ");
    	//vdobj$Print(objID = &rowId);
    	goto wrapup;
    }

    colNos = _MALLOC( cnt, int );
    if( !colNos ) goto wrapup;

    linNos = _MALLOC( cnt, int );
    if( !linNos ) goto wrapup;

    attValues = _MALLOC( cnt, IGRchar * );
    if( !attValues ) goto wrapup;

    status =
    om$send(	msg	 = message VDdrwTblRow.ACfind_temp_obj(
                                                                (int *)&msg,
                                                                "coll",
                                                                &collId ),
		senderid = NULL_OBJID,
		targetid = rowId->objid,
		targetos = rowId->osnum );
    if( !(status&msg&1) ) goto wrapup;

    // check actual boundary in local coordinate system for row
    for( i = 0; i < cnt; i++ ) {

	txt[0] = '\0';
    	VDcvgGetTextInfo(NULL, &txtIds[i], txt, 0, NULL );
	VD_stripString( txt );

	attValues[i] = _MALLOC( (strlen(txt) + 2), IGRchar );
	if( !attValues[i] ) goto wrapup;

	strcpy( attValues[i], txt );

#ifdef DEBUG
    	printf("txtId[%d]: ",i); vdobj$Print(objID=&txtIds[i]);
    	printf("\ttext value: [%s]\n", txt);
#endif

    	status =
	om$send(	msg	 = message GR3dtext.GRgetrang( 
					&msg,
					&footOE.mod_env.md_env.matrix_type,
					footOE.mod_env.md_env.matrix,
					&world,
					range ),
			senderid = NULL_OBJID,
			targetid = txtIds[i].objid,
			targetos = txtIds[i].osnum );
	if( !(status&msg&1) ) goto wrapup;
		
	//printf("\trange: [%g,%g,%g] [%g,%g,%g]\n",
	//		range[0],range[1],range[2],range[3],range[4],range[5]);

    	// transform pt1 to local coordinate system
    	for( k = 0; k < 3; k++ )
	{
	    pnt[k] = range[k];
	}
	pnt[3] = 1;
    	BSmult_mats(4,4, trMatrix,0, 4,1, pnt, 0, pt1, &msg);

    	// transform pt2 to local coordinate system
    	for( k = 0; k < 3; k++ )
	{
	    pnt[k] = range[k+3];
	}
    	pnt[3] = 1.;
    	BSmult_mats(4,4, trMatrix,0, 4,1, pnt, 0, pt2, &msg);

	//printf("\tAfter mapping range: [%g,%g,%g] [%g,%g,%g]\n",
	//	pt1[0],pt1[1],pt1[2],pt2[0],pt2[1],pt2[2]);

	colNos[i] = 0;
	linNos[i] = 1;
	for( k = 0; k < nbCols; k++ )
	{
	    /* catch the overlap			*/
	    /*	left bound -> |    | <- right bound	*/
	    /*	               AAAA  <- inside bound	*/
	    /*	              AAAAAA <- cross bound	*/
	    if( (pt1[0] >  xcor[k] && pt2[0] <  xcor[k+1]) ||
		(pt1[0] <= xcor[k] && pt2[0] >= xcor[k+1]) )
	    {
		colNos[i] = k + 1;
	    }
	}
	if( colNos[i] < 1 ) continue;

	if( i > 0 && colNos[i] == colNos[i-1] )
	{
	    linNos[i] = linNos[i-1] + 1;
	}
    }

#ifdef DEBUG
    for( i = 0; i < cnt; i++ )
    {
	printf("%d - col: %d, lin: %d value: [%s]\n",
		i,colNos[i],linNos[i],attValues[i]);
    }
#endif

    i = 0;
    while ( i < cnt )
    {
	sprintf( attName, "%d %d", colNos[i], linNos[i]);
	if( colNos[i] < 1 )
	{
	    i++;
	    continue;
	}
	
	_FREE(datValue);
	status = VDdrw_getAttFromColl( &msg, rowId, attName, &datValue );

	if( (status&msg&1) && datValue )
	{
	    VD_stripString( datValue );
	    if( datValue[0] != '\0' ) continue;
	}
	
	buf = _MALLOC( strlen( attValues[i] ), IGRchar );
	if( !buf ) goto wrapup;

	strcpy( buf, attValues[i] );

	while( (i < cnt - 1) && (colNos[i] == colNos[i+1]) )
	{
	    i++;
	    buf = _REALLOC( buf, strlen(buf)+strlen(attValues[i])+2, IGRchar);
	    if( !buf ) goto wrapup;
	    strcat( buf, attValues[i] );
	}

	status = VDputAttInColl( &msg, collId, attName, buf );
	//printf("attName: [%s], value: [%s]\n", attName, buf);

	i++;

	_FREE( buf );
    }

    status = 1;
wrapup:
    _LOOPFREE( attValues, cnt );
    _FREE( buf );
    _FREE( datValue );
    _FREE( linNos );
    _FREE( colNos );
    return status;
}

/*---------------------------------------------------------------------------
 * Input table, attributes will be set from feet for all lined out rows
 */
IGRint	VDtblSetAttrForLnOutRows ( TGRid	*tblId )
{
    IGRlong		status = 0, msg ;
    IGRdouble		matrix[16], trMatrix[16];
    IGRpoint		pt;
    IGRint		i, j, rowNo;
    IGRint		startRowNo = 0;
    IGRint		nbHdrs = 0, nbRows = 0, nbCols = 0, nbObjs = 0;
    TGRid		*hdrs = NULL;
    TGRid		csId, rowId;
    TGRobj_env		*objOEs = NULL;
    IGRchar		tblLoName[VD_DRWLO_CHR_IDFLD];
    IGRshort		nbFixRecs = 0, isLinedOut = 0;
    IGRdouble		*xcor = NULL, height;

    struct VDdrwlo_apifix	*fixRecs = NULL;

    if( !tblId || tblId->objid == NULL_OBJID ) {
		//printf("Inout table is null\n");
		goto wrapup;
    }

    UI_status("Processing ....");

    status =
    om$send( msg      = message VDdrwTbl.VDgetTableParts(&msg,&nbHdrs,NULL),
                 senderid = NULL_OBJID,
                 targetid = tblId->objid,
                 targetos = tblId->osnum );
    if( !(status&msg&1) ) {
                //printf("VDdrwTbl.VDgetTableParts failed. Quit cmd\n");
                goto wrapup;
    }

    status =
    om$send( msg      = message VDdrwTbl.VDgetTotalNbOfRows(&msg,&nbRows),
                 senderid = NULL_OBJID,
                 targetid = tblId->objid,
                 targetos = tblId->osnum );
           if( !(status&msg&1) ) {
                //printf("VDdrwTbl.VDgetTableNbOfRows failed. Quit cmd\n");
                goto wrapup;
    }

    // process each header
    if( !nbHdrs ) {
	//printf("No headers connected to the table\n");
	goto wrapup;
    }

    hdrs = _MALLOC( nbHdrs, TGRid );
    if( !hdrs ) {
	//printf("Faile to allocate for headers\n");
	goto wrapup;
    }

    status =
    om$send( msg      = message VDdrwTbl.VDgetTableParts(&msg,&nbHdrs,hdrs),
             senderid = NULL_OBJID,
             targetid = tblId->objid,
             targetos = tblId->osnum );
    if( !(status&msg&1) ) {
        //printf("VDdrwTbl.VDgetTableParts failed for headers. Quit cmd\n");
        goto wrapup;
    }

    // get table layout
    status =
    om$send (msg = message VDdrwTblHdr.VDgetTableInfo (
                                                &msg,
                                                tblLoName,
                                                NULL, NULL),
            senderid = NULL_OBJID,
            targetid = hdrs[0].objid,
            targetos = hdrs[0].osnum);
    if( !(status&msg&1) ) {
	//printf("VDdrwTblHdr.VDgetTableInfo failed\n");
	goto wrapup;
    }
	
    /* get the number of fixed components */
    status = VD_drwlo_gfix( &msg,
                            tblLoName,
                            VD_DRWLO_EN_DATA,
                            (double)0,
                            (double)0,
                            (short)0,
                            NULL,
                            &height,
                            &nbFixRecs,
                            NULL );

    if( nbFixRecs < 1 ) goto wrapup;

    fixRecs = _MALLOC( nbFixRecs, struct VDdrwlo_apifix );
    if( !fixRecs ) goto wrapup;

    xcor = _MALLOC( nbFixRecs, IGRdouble );
    if( !xcor ) goto wrapup;

    status = VD_drwlo_gfix( &msg,
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
	    //printf("fixRecs[%d]: %s\n", i, fixRecs[i].VD.tx.Text);
	}

	if( fixRecs[i].rectyp == VD_DRWLO_EN_LINE &&
	    fabs( fixRecs[i].VD.ln.x1 - fixRecs[i].VD.ln.x2) < EPS)
	{
	    for( j = 0; j < nbCols; j++ )
	    {
		if( fabs( fixRecs[i].VD.ln.x1 - xcor[j] ) < EPS )
		{
		    break;
		}
	    }
	    if( j == nbCols ) xcor[nbCols++] = fixRecs[i].VD.ln.x1;
	}
    }

#ifdef DEBUG
    for( i = 0; i < nbCols; i++ )
    {
	    printf("xcor[%d]: %g\n", i, xcor[i]);
    }
#endif

    nbCols--;
    if( nbCols < 2 ) goto wrapup;

    for( i = 0; i < nbHdrs; i++ ) {

	// get nbRows and startRowNo
	status =
        om$send( msg      = message VDdrwTblHdr.VDgetRowInfo
                                                     (&msg,&nbRows,&startRowNo),
                 senderid = NULL_OBJID,
                 targetid = hdrs[i].objid,
                 targetos = hdrs[i].osnum );
	if( !(status&msg&1)) {
		//printf("Failed to get RowIfo for header %d\n", i);
		continue;
	}
		
	// get table orient, header corner and cs
	status =
        om$send( msg      = message VDdrwTblHdr.VDgetRowConstructInfo
                                                    (	&msg,
							0,	// rowNo
							NULL,	// layout
							NULL,	// orient
							&csId,
							NULL,
							NULL),
                 senderid = NULL_OBJID,
                 targetid = hdrs[i].objid,
                 targetos = hdrs[i].osnum );
	if( !(status&msg&1)) {
		//printf("Failed to get construct info for header %d\n", i);
		continue;
	}

		
	// get cs matrix
	status =
        om$send( msg      = message GRgencs.GRgetmatrix ( &msg, matrix),
                 senderid = NULL_OBJID,
                 targetid = csId.objid,
                 targetos = csId.osnum );
	if( !(status&msg&1)) {
		//printf("Failed to get cs matrix for header %d\n", i);
		continue;
	}

#ifdef DEBUG
	printf("csId: "); vdobj$Print(objID = &csId);
		
	for( j = 0; j < 4; j++ )
	{
	    printf("cs matrix: [%g,%g,%g,%g]\n",
			matrix[4*j+0],
			matrix[4*j+1],
			matrix[4*j+2],
			matrix[4*j+3] );
	}
#endif

	// get inverse matrix from cs matrix
	BSinv_mat( 4, matrix, trMatrix, &msg );
	if( msg != BSSUCC ) {
		//printf("BSinv_mat failed for header %d\n", i);
		goto wrapup;
	}

#ifdef DEBUG
	for( j = 0; j < 4; j++ )
	{
	    printf("cs inverse matrix: [%g,%g,%g,%g]\n",
			trMatrix[4*j+0],
			trMatrix[4*j+1],
			trMatrix[4*j+2],
			trMatrix[4*j+3] );
	}
#endif

	for( j = 0; j < nbRows; j++ ) {

	    status =
	    om$send(msg      = message VDdrwTblHdr.VDrowNoToGRid
                                                     (  &msg,
                                                        j+startRowNo, 
							&rowId),
			senderid = NULL_OBJID,
			targetid = hdrs[i].objid,
			targetos = hdrs[i].osnum );
	    if( !(status&msg&1)) {
		//printf("ERROR: Failed to get row %d\n", j);
		goto wrapup;
	    }

	    isLinedOut = 0;
	    nbObjs     = 0;

	    status =
	    om$send(msg      = message VDdrwTblRow.VDisRowLinedOut
                                                     ( &msg, &isLinedOut ),
			senderid = NULL_OBJID,
			targetid = rowId.objid,
			targetos = rowId.osnum );
	    if( !(status&msg&1) ) {
		isLinedOut = 0;
	    }
	    
#if 0	/* Only check lined out row */
	    /*
	     * The method only return the number of ACpretends from VDdrwSet
	     * instead of the actual number of model objects connected to 
	     * VDdrwSet if we only aks to return nbObjs. Therefore, have to
	     * call the method again to return nbObjs and object list, so
	     * that the actual nbObjs is returned.
	     */
	    status =
	    om$send(msg      = message VDdrwTblRow.VDgetParentObjectList
                                                     ( &msg, &nbObjs, NULL ),
			senderid = NULL_OBJID,
			targetid = rowId.objid,
			targetos = rowId.osnum );
	    if( (status&msg&1) && nbObjs )
	    {
		objOEs = _MALLOC( nbObjs, TGRobj_env );
		if( !objOEs ) goto wrapup;

		status =
		om$send(msg      = message VDdrwTblRow.VDgetParentObjectList
                                                     ( &msg, &nbObjs, objOEs ),
			senderid = NULL_OBJID,
			targetid = rowId.objid,
			targetos = rowId.osnum );
	 	if( !(status&msg&1) ) nbObjs = 0;
		_FREE( objOEs );
	    }
	    else nbObjs = 0;

	    if( isLinedOut || !nbObjs )
#endif
	    if( isLinedOut )
	    {
		// real work
		VDtblSetRowAttFromFeet ( &rowId, nbCols, xcor, trMatrix );
	    }
	}
    }

    status = 1;
wrapup:
    UI_status("");
    _FREE(xcor);
    _FREE(hdrs);
    _FREE(fixRecs);
    return status;
}

end implementation Root;
