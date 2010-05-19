/* $Id: VDtblPlace.I,v 1.10 2002/06/06 17:10:25 ylong Exp $ */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdtbl/cmd / VDtblPlace.I
 *
 * Description:
 *      Implementation of the following method for VDCmdCrTbl :
 *              disconnect_rows
 *              place_table
 *              place_headers
 *              handle_row_delete
 *
 * Dependencies:
 *
 * History:
 *
 *      04/14/95        R. Manem        Creation
 *      05/15/95        R. Manem        Modified place_table to first remove
 *					Rows from existing headers 
 *	06/16/95	R. Manem	Do not touch lined-out rows during 
 *					modify table.
 *	06/28/95	R. Manem	Similate recompute for modified rows.
 *      07/14/95        R. Manem        ADS support
 *      07/24/95        R. Manem        exec batch, after emptying set :
 *					to avoid warning messages of support
 *					only elements
 *      09/13/95        R. Manem        Set user defined flag in rows, if
 *                                      there are no parent set objects
 *      09/20/95        R. Manem        Fixed bug in setting up qty in rows
 *      09/28/95        R. Manem        Prevent table corruption when stop
 *					button is clicked during Modify Table
 *	09/01/00	Ming		CR179901748
 *	05/02/01	ylong		TR5070
 *	05/16/02	ylong		TR6281
 *	06/06/02	ylong		CR6391
 * -------------------------------------------------------------------*/

class implementation VDCmdCrTbl;

/*
#define vdsDEBUG
#define vdserrDEBUG
*/

#include <stdio.h>
#include "string.h"

#include "OMmacros.h"
#include "OMprimitives.h"
#include "exproto.h"

#include "godef.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "ACattrib.h"

#include "v_miscmacros.h"
#include "v_dbgmacros.h"
#include "v_datamacros.h"

#include "nddef.h"
#include "ndmacros.h"
#include "macro.h"

#include "vddlodef.h"
#include "vddlomacros.h"
#include "VDdrwlo.h"
#include "VDdrwlo_pr.h"
#include "VDdrwtbl.h"
#include "VDtblCmdDef.h"

#include "VDCmdDef.h"
#include "FI.h"
#include "FEI.h"
#include "VDobj.h"

#include "coparamac.h"

extern GRclassid		OPP_drwTblHdr_class_id;

extern ASmake_source_from_env();
extern VDgetOccName();

from ACcpx		import	ACfind_temp_obj;
from ACrg_collect	import	ACset_list_attribute;
from VDSroot		import	VDcompute, VDcreate;
from GRgencs		import	GRcvt_to_wld_coords;
from GRgraphics		import	GRdisplay;				
from VDdrwSet		import	VDinitSet,
				VDemptySet,
				VDaddObjectsToSet;
from VDdrwTbl		import	VDaddHeaders,
				VDremoveHeaders;
from VDdrwTblHdr	import	VDgetRowInfo,
				VDinitTblHdr,
				VDputTableInfo,
				VDputStartRowNo,
				VDputCsLocation,
				VDgetCsLocation,
				VDsetMatrixFromCS,
				VDdeleteHdr,
				VDremoveRow,
				VDinsertRow,
				VDgetCornerPointForRow,
				VDgetRowHeight,
				VDaddAndConstructRows,
				VDconstructHdrTrl,
				VDputConstructInfo;
from VDdrwTblRow	import	VDinitTblRow,
				VDputQtyExpr,
				VDgetParentSetId,
				VDisRowLinedOut,
				VDputUserDefRowFlag,
				VDputItemNumber,
				VDputRowNumber,
				VDdeleteRow,
				VDgetRowNumber,
				VDgetItemNumber;
from GRvg		import  GRgetname;

/*--------------------------------------------------------------------------
 * 
 */
static IGRint sortRowsByItemNo(	struct VDdrw_rowInfo *r1, 
				struct VDdrw_rowInfo *r2 )
{
  IGRint	nb1 = 1e8, nb2 = 1e8, size; 
  IGRlong	status, msg;
  IGRchar	itemNo1[40], itemNo2[40];

  status = om$send (	msg	 = message VDdrwTblRow.VDgetItemNumber
							( &msg, &size, itemNo1),
			senderid = NULL_OBJID,
			targetid = r1->rowId.objid,
			targetos = r1->rowId.osnum );
  if( (status&msg&1) ) nb1 = atoi( itemNo1 );

  status = om$send (	msg	 = message VDdrwTblRow.VDgetItemNumber
							( &msg, &size, itemNo2),
			senderid = NULL_OBJID,
			targetid = r2->rowId.objid,
			targetos = r2->rowId.osnum );
  if( (status&msg&1) ) nb2 = atoi( itemNo2 );

  return (nb1 - nb2);
}

#define MAX_NUM	10000000
IGRlong	VDmdTblSetRowItems( struct VDdrw_rowInfo *rows, IGRint nbRows)
{
  IGRlong	status = 0, msg;
  IGRint	i, j, k;
  IGRint	size, request = 0;
  IGRshort	isLinedOut;
  IGRchar	itemNo[40];
  IGRint	*linedOuts = NULL;

  struct LinedOutRecord {
	IGRint	itemNum;
	IGRint	linedOut;
	IGRint	modified;
  } *lnOutRec = NULL;
	

  if( !rows || !nbRows ) goto wrapup;

  lnOutRec = _MALLOC( nbRows, struct LinedOutRecord );
  if ( !lnOutRec ) goto wrapup;

  for( i = 0; i < nbRows; i++ ) {
     lnOutRec[i].itemNum  = -1;
     lnOutRec[i].linedOut = 0;
     lnOutRec[i].modified = 0;
    
     status = om$send (	msg	 = message VDdrwTblRow.VDgetItemNumber
							( &msg, &size, itemNo),
			senderid = NULL_OBJID,
			targetid = rows[i].rowId.objid,
			targetos = rows[i].rowId.osnum );
     if( (status&msg&1) ) {
	lnOutRec[i].itemNum = atoi( itemNo );
     }

     isLinedOut = 0;
     status =
     om$send(	msg      = message VDdrwTblRow.VDisRowLinedOut( &msg,
                                                                &isLinedOut),
		senderid = NULL_OBJID,
		targetid = rows[i].rowId.objid,
		targetos = rows[i].rowId.osnum );
     if( (status&msg&1) ) {
	request = 1;
	lnOutRec[i].linedOut = isLinedOut;
     }
  }

  if( !request ) {
     status = 1;
     goto wrapup;
  }

  /* becareful, rows are not sorted by item number */

  for( i = 0; i < nbRows; i++ ) {

     if( !lnOutRec[i].linedOut || lnOutRec[i].itemNum == -1) continue;

     for( j = 0; j < nbRows; j++ ) 
     {

	if( i == j ) continue;
	if( lnOutRec[j].linedOut || lnOutRec[j].itemNum == -1 ) continue;

	if( lnOutRec[i].itemNum == lnOutRec[j].itemNum ) 
	{
	    for( k = 0; k < nbRows; k++ ) 
	    {
		if( lnOutRec[i].itemNum <= lnOutRec[k].itemNum && i != k &&
		    lnOutRec[k].itemNum > 0 ) 
		{
		    lnOutRec[k].itemNum++;
		    lnOutRec[k].modified = 1;
		}
	    }
	    break;
	}
     }
  }
  
  for( i = 0; i < nbRows; i++ ) {
     if( lnOutRec[i].modified ) {
	sprintf( itemNo, "%d", lnOutRec[i].itemNum );
	status =
	om$send(msg      = message VDdrwTblRow.VDputItemNumber(&msg, itemNo),
		senderid = NULL_OBJID,
		targetid = rows[i].rowId.objid,
		targetos = rows[i].rowId.osnum );
     }
  }

  /* sort rows by item number */
  qsort(	(char *)rows,
		nbRows,
		sizeof(struct VDdrw_rowInfo),
		(int (*)())sortRowsByItemNo );

#ifdef DEBUG
  for( i = 0; i < nbRows; i++ ) {

     *itemNo = 0;
     status = om$send (	msg	 = message VDdrwTblRow.VDgetItemNumber
							( &msg, &size, itemNo),
			senderid = NULL_OBJID,
			targetid = rows[i].rowId.objid,
			targetos = rows[i].rowId.osnum );
      printf("item[%d]: %s, row id: ", i, itemNo);
      vdobj$Print(objID=&rows[i].rowId);
  }
#endif

  status = 1;
wrapup:
  _FREE( lnOutRec );
  return status;
}

/*+me
 ---------------------------------------------------------------------------
  Public Message disconnect_rows

  Abstract
        This method disconnects all the rows of existing header objects.
        Used just before "place_table"

  Arguments
        IGRlong         *sts            O       Return code

  Status code
        status = OM_S_SUCCESS

  Return Code
        *sts = VD_SUCCESS
 ---------------------------------------------------------------------------
-me*/

method  disconnect_rows ( long * sts )
{
    IGRint		i, j,
			nbHdrs,
			nbHdrRows,
			rowNo, startRowNo,
			size = sizeof( struct GRmd_env );
    enum GRdpmode	dpmode;
    IGRlong		msg,
			status = OM_S_SUCCESS;
    struct GRmd_env	mod_env;
    
    SetProc( VDCmdCrTbl.disconnect_rows ); Begin

    *sts = VD_SUCCESS;

    nbHdrs = om$dimension_of( varray = me->hdrIds );
    __DBGpr_int( "Number of headers", nbHdrs );

    /* get current module environment */

    status = gr$get_module_env(	msg	= &msg,
				sizbuf	= &size,
				buffer	= &mod_env );
    __CheckRC( status, msg, "gr$get_module_env", wrapup );
    
    for( i = 0 ; i < nbHdrs ; i++ )
    {
	/* erase the header */

	dpmode = GRbe;
	status =
	_VD_SEND_OBJ( me->hdrIds[i], GRgraphics.GRdisplay(	
						&msg,
						&mod_env.md_env.matrix_type,
						mod_env.md_env.matrix,
						&dpmode,
						&mod_env.md_id ) );
	CheckRC( status, msg );

	status =
	_VD_SEND_OBJ( me->hdrIds[i], VDdrwTblHdr.VDgetRowInfo( 	&msg,
								&nbHdrRows,
								&startRowNo ) );
	__CheckRC( status, msg, "VDdrwTblHdr.VDgetRowInfo", wrapup );
	
	if( !(status & msg & 1) )
	    continue;

	__DBGpr_int( "i", i );
	__DBGpr_int( "\tNumber of rows in header", nbHdrRows );
	__DBGpr_int( "\tStart row number", startRowNo );
				
	for( j = nbHdrRows-1 ; j >= 0 ; j-- )
	{
	    rowNo = startRowNo + j;
	    status =
	    _VD_SEND_OBJ( me->hdrIds[i], VDdrwTblHdr.VDremoveRow(
								&msg,
								0,
								&rowNo,
								NULL ) );
	    __CheckRC( status, msg, "VDdrwTblHdr.VDremoveRow", wrapup );
	}
    }

wrapup :

    if( !(status & msg & 1) )
	*sts = VD_ERROR;
    End
    return OM_S_SUCCESS;
}

/*+me
 ---------------------------------------------------------------------------
  Public Message place_table

  Abstract
        This method generates the body of the table by constructing the
        row objects and the trailer.  For "Modify Table" and "Split Table"
        the old row objects are either moved or reconstructed.

  Arguments
        IGRlong         *sts            O       Return code

  Notes/Remarks

  Status/Return Code
      status == OM_S_SUCCESS
 ---------------------------------------------------------------------------
-me*/

method place_table( IGRlong	*sts )
{
    IGRint		i, j, 
			rowNo,
			nbObjs,
			nbHdrs,
			nbCpyHdrs,
			nbRows,
			nbHdrRows,
			startRowNo,
			hdrInd, cpyInd,
			size = sizeof( struct GRmd_env ),
			*lastRowNos = NULL;
    IGRshort		prop,
			newFlag,
			isLinedOut,
			trlType = VD_DRWLO_EN_BRKTRLR,
			cnstType = VD_DRW_CNST_TRLR;
    IGRchar		csType[] = "rectangular";
    IGRlong		msg,
			status = OM_S_SUCCESS;
    IGRdouble		oldPoint[3],
			oldWldPnt[3],
			rowHeight;
    OMuword		os;
    struct GRid		setId,
			collId,
			*gridList = NULL;
    struct GRmd_env	mod_env;
    IGRchar		occurance_name[240];
    struct ACrg_coll    *Attr;
    IGRint              nbAttr;
    IGRchar             szmsg[200];
    VD_drwLoInfo	drwInfo;
			
    
    SetProc( VDCmdCrTbl.place_table ); Begin

    *sts = VD_SUCCESS;
    Attr = NULL;

    nbHdrs = om$dimension_of( varray = me->hdrIds );
    __DBGpr_int( "Number of headers", nbHdrs );

    /* get current module environment */

    status = gr$get_module_env(	msg	= &msg,
				sizbuf	= &size,
				buffer	= &mod_env );
    CheckRC( status, msg );
    
    /* get current osnum */

    ex$get_cur_mod( osnum = &os );
    __DBGpr_int( "Current osnum ", os );

    /* make a GRid array using the GRobj_env array of located objects */

    nbObjs = om$dimension_of(	varray	= me->locObjs );

    if( nbObjs )
    {
    	gridList = _MALLOC( nbObjs, struct GRid );
    	if( !gridList )
    	{
	    *sts = VD_ERROR;
	    UI_status( "Error encountered : command terminated" );
	    goto wrapup;
    	}

    	for( i = 0 ; i < nbObjs ; i++ )
	    gridList[i] = me->locObjs[i].obj_id;
    }

    /* construct the row objects where necessary */

    nbRows = om$dimension_of( varray	= me->rows );
    __DBGpr_int( "Dimension of rows ", nbRows );

    prop = AChdr_nodisplay | AChdr_noprotect | AChdr_nocompute;

    for( i = 0 ; i < nbRows ; i++ )
    {
	/* 
	 * if row has been modified, set up the templates correctly
	 */

	if( me->rows[i].flag == VD_DRW_ROW_MOD )
	{
	    isLinedOut = 0;
	    status =
	    _VD_SEND_OBJ( me->rows[i].rowId, VDdrwTblRow.VDisRowLinedOut( 
								&msg,
								&isLinedOut ) );
	    CheckRC( status, msg );

	    if( isLinedOut )
	    {
		me->rows[i].flag = VD_DRW_ROW_OLD;
	    }
	    else
	    {
		/* get collector id */

		collId.objid = NULL_OBJID;
		status = 
		_VD_SEND_OBJ( me->rows[i].rowId, ACcpx.ACfind_temp_obj(
								(int *)&msg,
								"coll",
								&collId ) );
		CheckRC( status, msg );
		//__CheckRC( status, msg, "ACcpx.ACfind_temp_obj", wrapup );

		__DBGpr_obj( "collector id", collId );

		/* empty collector 

		status = 
		_VD_SEND_OBJ( collId, ACrg_collect.ACset_list_attribute( &msg,
								0, NULL ) );
	 	__CheckRC( status, msg, "collect.ACset_list_attribute", wrapup );
		*/

		/* get parent setId */

		status =
		_VD_SEND_OBJ( me->rows[i].rowId, VDdrwTblRow.VDgetParentSetId(
								&msg, 
								&setId ) );

		/* if there is no parent set (general table rows), continue */

		if( !( status & msg & 1) )
		    continue;

		__DBGpr_obj( "parent set id", setId );

		/* empty set */

		status = _VD_SEND_OBJ( setId, VDdrwSet.VDemptySet( &msg ) );
		__CheckRC( status, msg, "VDdrwSet.VDemptySet", wrapup );

		/* update the delete of support only elements */

		nd$exec_batch();

		if( !me->rows[i].nbObjs )
		    continue;

		/* add the appropriate parents */

		status =
		_VD_SEND_OBJ( setId, VDdrwSet.VDaddObjectsToSet( 
					&msg,
					me->rows[i].nbObjs,
					&gridList[me->rows[i].startIndex]) );
		__CheckRC( status, msg, "VDdrwSet.VDaddObjectsToSet", wrapup );
	    }
	}

	if( me->rows[i].rowId.objid == NULL_OBJID )
	{
	    /* must construct the row object */

	    me->rows[i].rowId.osnum = os;

	    status =
	    om$construct(	classid	= OPP_VDdrwTblRow_class_id,
				osnum	= me->rows[i].rowId.osnum,
				p_objid	= &me->rows[i].rowId.objid,
				msg	= message VDdrwTblRow.VDinitTblRow( 
								&msg ) );
	    CheckRC( status, 1 );
	   
	    __DBGpr_obj( "Table row id", me->rows[i].rowId );

	    if( me->rows[i].rowId.objid == NULL_OBJID )
	    {
		*sts = VD_ERROR;
		UI_status( "Error encountered : command terminated" );
		goto wrapup;
	    }

	    /* 
	     * Construct and initialize the parent set objects if needed.
	     * Initialize the templates
	     */

	    if( me->rows[i].nbObjs )
	    {
		/* must construct the set object */

		setId.osnum = os;
		setId.objid = NULL_OBJID;

		status =
		om$construct(	classid	= OPP_VDdrwSet_class_id,
				osnum	= setId.osnum,
				p_objid	= &setId.objid,
				msg	= message VDdrwSet.VDinitSet( &msg ) );
		CheckRC( status, 1 );

		if( setId.objid == NULL_OBJID )
		{
		    *sts = VD_ERROR;
		    UI_status( "Error encountered : command terminated" );
		    goto wrapup;
		}

		__DBGpr_obj( "Constructed set id", setId );

		/* add the row objects to the set */

		status =
		_VD_SEND_OBJ( setId, VDdrwSet.VDaddObjectsToSet(	
					&msg,
					me->rows[i].nbObjs,
					&gridList[me->rows[i].startIndex]) );
		__CheckRC( status, msg, "VDdrwSet.VDaddObjectsToSet", wrapup );

		/* Added by Ming for CR179901748 */
	        nbAttr = me->rows[i].nbObjs + 1;
		Attr = _MALLOC( nbAttr, struct ACrg_coll );
                if( Attr )
                {
                  strcpy( Attr[0].name, "occurance_count" );
                  Attr[0].desc.type = AC_ATTRIB_TEXT;
	          occurance_name[0] = '\0';
		  sprintf( occurance_name, "%d", me->rows[i].nbObjs );
		  strcpy( Attr[0].desc.value.att_txt, occurance_name );

 		  for( j = 1 ; j < nbAttr ; j++ )
		  {
 		    sprintf( Attr[j].name, "occurance_%d", j );
                    Attr[j].desc.type = AC_ATTRIB_TEXT;

		    status = VDtblRowExecPplName( &msg, 
				&gridList[me->rows[i].startIndex+j-1],
				&me->rows[i].rowId, "VDrow_info", "name",
				Attr[j].desc.value.att_txt );
		    if( !(status&1&msg) )
 		    {
	 	      strcpy( Attr[j].desc.value.att_txt, "unknown" );
		    }
		  }
	        }
		else
                {
                  _FREE( Attr );
                  Attr = NULL;
                  nbAttr = 0;
                }

	    	/* initialize row object with the templates */
                
	    	status =
	    	_VD_SEND_OBJ( me->rows[i].rowId, VDdrwTblRow.VDcreate(
							&msg,
							nbAttr,
							Attr, 
							"VDdrwTblRow",
							prop,
							1,
							&setId ) );
	    	__CheckRC( status, msg, "VDdrwTblRow.VDcreate", wrapup );

                _FREE( Attr );
                Attr = NULL;
	    }
	    else
	    {

	    	/* initialize row object with just the rg-collector */
	    	status =
	    	_VD_SEND_OBJ( me->rows[i].rowId, VDdrwTblRow.VDcreate(
							&msg,
							0, NULL,
							"VDdrwTblRow",
							prop,
							0,
							NULL ) );
	    	__CheckRC( status, msg, "VDdrwTblRow.VDcreate", wrapup );

		/* set user defined row flag */

		status =
		_VD_SEND_OBJ( me->rows[i].rowId, VDdrwTblRow.VDputUserDefRowFlag
							( &msg, 1 ) );
		CheckRC( status, msg );
	    }
	}
    }

    /* process the form inputs */

    if( me->mytype == CREATE_TABLE || me->mytype == MODIFY_TABLE )
    {
    	status =
    	_VD_SEND_MY( VDCmdCrTbl.VDprocessCreateForm( &msg ) );
    	__CheckRC( status, msg, "VDCmdCrTbl.VDprocessCreateForm", wrapup );
    }

    /* TR6281
    ** reorganize rows so that positions of lined out rows are decided by
    ** their item numbers, and their item numbers can not be resued. 
    ** only for Modify Table command
    */
    status = vd$drw_layout_info (	msg     = &msg,
					type    = VD_K_drwLO_tblLinedOut,
					info    = &drwInfo );
    if( (status&msg&1) && drwInfo.val.iValue )
    {
	status = VDmdTblSetRowItems(me->rows, nbRows);
	CheckRC( status, 1);
    }

    nbCpyHdrs = om$dimension_of( varray = me->cpyHdrs );
    __DBGpr_int( "Number of copy headers", nbCpyHdrs );

    /* compute the last row number in the header copies */

    lastRowNos = _MALLOC( nbCpyHdrs, IGRint );
    if( !lastRowNos )
    {
	*sts = VD_ERROR;
	UI_status( "Error encountered : command terminated" );
	goto wrapup;
    }

    for( i = 0 ; i < nbCpyHdrs ; i++ )
    {
	lastRowNos[i] = 0;

	/* get the row info */

	status =
	_VD_SEND_OBJ( me->cpyHdrs[i], VDdrwTblHdr.VDgetRowInfo( &msg,
								&nbHdrRows,
								&startRowNo ) );
	CheckRC( status, msg );
	if( !(status & msg & 1) )
	    continue;

	__DBGpr_int( "i", i );
	__DBGpr_int( "\tNumber of header rows in copy", nbHdrRows );
	__DBGpr_int( "\tStart row number", startRowNo );

	lastRowNos[i] = startRowNo + nbHdrRows - 1;
    }

    /* 
     * more rows may have been added in the form, all the excess rows
     * will be accomodated in the last header.  The number of rows in 
     * the first nbHdrs-1 will be the same as before.
     *
     * if rows are deleted, then, old row numbers may exceed the nbRows value
     * So, retain the larger of the two values.
     */

    if( lastRowNos[nbCpyHdrs-1] < nbRows )
    	lastRowNos[nbCpyHdrs-1] = nbRows;

    /* for "Create Table", splitLocs does not exist : allocate one elem space */

    if( me->mytype == CREATE_TABLE )
    {
    	status = om$vla_set_dimension(	varray	= me->splitLocs,
					size	= 1 );
    	__CheckRC( status, 1, "om$vla_set_dimension", wrapup );
    }
    
    me->splitLocs[nbHdrs-1] = nbRows;

#ifdef vdsDEBUG
    printf("\n\tList of last row numbers :\n");
    for( i = 0 ; i < nbCpyHdrs ; i++ )
        printf("\t\t# %d : %d\n", i, lastRowNos[i] );

    printf("\n\tList of split locations :\n");
    for( i = 0 ; i < nbHdrs ; i++ )
        printf("\t\t# %d : %d\n", i, me->splitLocs[i] );
#endif

    /* construct/compute/move each row object */

    hdrInd = 0;
    for( i = 0 ; i < nbRows ; i++ )
    {
	sprintf( szmsg,
                 "Constructing or Recomputing Table Row: i = %d",
                 i );
        UI_status( szmsg );

	__DBGpr_int( "\n\tRow index ", i );

	if( i+1 > me->splitLocs[hdrInd] )
	    hdrInd++;
	__DBGpr_int( "Header index ", hdrInd );

	IGEresetstop();

	if( me->rows[i].flag == VD_DRW_ROW_NEW )
	{
	    /* set up the qty computation structure */
	
	    status =
	    _VD_SEND_OBJ( me->rows[i].rowId, VDdrwTblRow.VDputQtyExpr( 
							&msg,
							me->rows[i].qty ) );
	    CheckRC( status, msg );

	    /* construct the row */

	    status =
	    _VD_SEND_OBJ( me->hdrIds[hdrInd], VDdrwTblHdr.VDaddAndConstructRows(
							&msg,
							1,
							&me->rows[i].rowId ) );
	    __CheckRC( status, msg, "VDdrwTblHdr.VDaddAndConstructRows", wrapup );

	}
	else if( me->rows[i].flag == VD_DRW_ROW_MOD )
	{
	    /* set up the qty computation structure */
	
	    status =
	    _VD_SEND_OBJ( me->rows[i].rowId, VDdrwTblRow.VDputQtyExpr( 
							&msg,
							me->rows[i].qty ) );
	    CheckRC( status, msg );
	    /* insert the row and recompute it */

	    newFlag = 2;

	    status =
	    _VD_SEND_OBJ( me->hdrIds[hdrInd], VDdrwTblHdr.VDinsertRow( 
							&msg, 
							&newFlag,
							i+1,
							me->rows[i].rowId,
							NULL, NULL ) );
	    __CheckRC( status, msg, "VDdrwTblHdr.VDinsertRow", wrapup );

	}
	else if( me->rows[i].flag == VD_DRW_ROW_OLD )
	{
	    /* 
	     * must move the row 
	     */

#if 0	/* remove this part for CR6391, make lined out row editable */

	    /* get the old row number */

	    status =
	    _VD_SEND_OBJ( me->rows[i].rowId, VDdrwTblRow.VDgetRowNumber( &msg,
								&rowNo ) );
	    __CheckRC( status, msg, "VDdrwTblRow.VDgetRowNumber", wrapup );

	    __DBGpr_int( "Old row number ", rowNo );

	    /* get the copy header index for this row */

	    cpyInd = 0;
	    while( rowNo > lastRowNos[cpyInd] )
		cpyInd++;

	    __DBGpr_int( "Copy header index", cpyInd );

	    /* get the old corner point for the row */

	    status =
	    _VD_SEND_OBJ( me->cpyHdrs[cpyInd], VDdrwTblHdr.
				VDgetCornerPointForRow( &msg, 
							rowNo,
							oldPoint ) );
	    __CheckRC( status, msg, "VDdrwTblHdr.VDgetCornerPointForRow", wrapup );
	    
	    /* get row height */

	    status =
	    _VD_SEND_OBJ( me->cpyHdrs[cpyInd], VDdrwTblHdr.VDgetRowHeight( 
							&msg, 
							rowNo,
							&rowHeight ) );
	    __CheckRC( status, msg, "VDdrwTblHdr.VDgetRowHeight", wrapup );
	    __DBGpr_dbl( "Old row Height ", rowHeight );

	    /* convert oldPoint to world coordinates */

	    __DBGpr_obj( "Cs objid", me->cs[cpyInd].obj_id );

	    status =
	    _VD_SEND_OBJ( me->cs[cpyInd].obj_id, GRgencs.GRcvt_to_wld_coords(	
								&msg,
								csType,
								1,
								oldPoint,
								oldWldPnt ) );
	    __CheckRC( status, msg, "GRgencs.GRcvt_to_wld_coords", wrapup );

	    newFlag = 0;
#endif
	    newFlag = 2; /* CR6391 */

	    __DBGpr_obj( "Header id to insert row", me->hdrIds[hdrInd] );

	    status =
	    _VD_SEND_OBJ( me->hdrIds[hdrInd], VDdrwTblHdr.VDinsertRow( 
							&msg, 
							&newFlag,
							i+1,
							me->rows[i].rowId,
							NULL,
							NULL ));
							/* replaced for CR6391
							&rowHeight,
							oldWldPnt ) );
							*/
	    __CheckRC( status, msg, "VDdrwTblHdr.VDinsertRow", wrapup );
	}
    }

    UI_status("");

    /* reconstruct the trailers */

    for( i = 0 ; i < nbHdrs ; i++ )
    {
	/* the last one is a trailer */

	if( i == nbHdrs-1 )
	    trlType = VD_DRWLO_EN_TRAILER;
	    
	status =
	_VD_SEND_OBJ( me->hdrIds[i], VDdrwTblHdr.VDputConstructInfo( 
								&msg,
								NULL, 
								&trlType,
								&cnstType ) );
	__CheckRC( status, msg, "VDdrwTblHdr.VDputConstructInfo", wrapup );

	status =
	_VD_SEND_OBJ( me->hdrIds[i], VDdrwTblHdr.VDconstructHdrTrl( &msg ) );
	__CheckRC( status, msg, "VDdrwTblHdr.VDconstructHdrTrl", wrapup );
    }

wrapup :

    _FREE( gridList );
    _FREE( Attr );
    _FREE( lastRowNos );
    End
    return OM_S_SUCCESS;
}

/*+me
 ---------------------------------------------------------------------------
  Public Message place_headers

  Abstract
        This method generates the required headers and trailers for
        "Split Table" command.

  Arguments
        IGRlong         *sts            O       Return code

  Status code
        status = OM_S_SUCCESS

  Return Code
        *sts = VD_SUCCESS
 ---------------------------------------------------------------------------
-me*/

method  place_headers( long * sts )
{
    IGRint		i, 
			partNo,
			startRowNo,
			nbOldHdrs, nbTotHdrs,
			size = sizeof( struct GRmd_env );
    IGRshort		csLoc,
			prop,
			hdrType = VD_DRWLO_EN_BRKHDR,
			cnstType = VD_DRW_CNST_HDR;
    IGRlong		msg,
			status = OM_S_SUCCESS;
    OMuword		os;
    struct GRid		root;
    struct GRmd_env	mod_env;
    struct VDdrwlo_tab	tblRec;
    

    SetProc( VDCmdCrTbl.place_headers ); Begin
    *sts = VD_SUCCESS;

    /* get current module environment */

    status = gr$get_module_env(	msg	= &msg,
				sizbuf	= &size,
				buffer	= &mod_env );
    __CheckRC( status, msg, "gr$get_module_env", wrapup );
    
    /* get current osnum */

    status = ex$get_cur_mod( osnum = &os );

    nbOldHdrs = om$dimension_of( varray = me->hdrIds );
    nbTotHdrs = om$dimension_of( varray = me->splitLocs );

    __DBGpr_int( "Number of old headers ", nbOldHdrs );
    __DBGpr_int( "Total Number of headers ", nbTotHdrs );

    /* if no more headers are needed, update startRowNo for all headers  */

    if( nbOldHdrs == nbTotHdrs )
	goto UPD_STARTROWNO;

    /* delete excess headers, if any */

    if( nbTotHdrs < nbOldHdrs )
    {
	/* disconnect the headers from the table object */

	status =
	_VD_SEND_OBJ( me->tblObj.obj_id, VDdrwTbl.VDremoveHeaders( 
						&msg,
						nbOldHdrs-nbTotHdrs,
						&me->hdrIds[nbTotHdrs] ) );
	__CheckRC( status, msg, "VDdrwTbl.VDremoveHeaders", wrapup );

	for( i = nbOldHdrs-1 ; i >= nbTotHdrs ; i-- )
	{
	    status =
	    _VD_SEND_OBJ( me->hdrIds[i], VDdrwTblHdr.VDdeleteHdr( &msg ) );
	    CheckRC( status, msg );
	}

	/* resize the vla */

	status = om$vla_set_dimension(	varray	= me->hdrIds,
					size	= nbTotHdrs );
	CheckRC( status, 1 );

	goto UPD_STARTROWNO;
    }

    /* 
     * at this point, nbTotHdrs > nbOldHdrs, new headers must be created
     * allocate space for new headers 
     */

    status = om$vla_set_dimension( 	varray	= me->hdrIds,
					size 	= nbTotHdrs );
    __CheckRC( status, 1, "om$vla_set_dimension", wrapup );

    /* 
     * get the table location w.r.t cs (left/right) from the first copy 
     * of header 
     */

    status =
    _VD_SEND_OBJ( me->cpyHdrs[0], VDdrwTblHdr.VDgetCsLocation(	&msg,
								&csLoc ) );
    __CheckRC( status, msg, "VDdrwTblHdr.VDgetCsLocation", wrapup );
    __DBGpr_int( "Table location (left/right)", csLoc );
    
    /* construct the required headers */

    for( i = nbOldHdrs ; i < nbTotHdrs ; i++ )
    {
	/* construct the table header object */

	me->hdrIds[i].osnum = os;
	me->hdrIds[i].objid = NULL_OBJID;

	status =
	om$construct(	classid	= OPP_VDdrwTblHdr_class_id,
			osnum	= me->hdrIds[i].osnum,
			p_objid	= &me->hdrIds[i].objid,
			msg	= message VDdrwTblHdr.VDinitTblHdr( &msg ) );
	__CheckRC( status, 1, "construct VDdrwTbl", wrapup );

	__DBGpr_obj( "Table Header id", me->hdrIds[i] );

	if( me->hdrIds[i].objid == NULL_OBJID )
	{
	    status = OM_E_ABORT;
	    goto wrapup;
	}

	/* get table record */

	status = VD_drwlo_gtab( &msg, me->tblLayoutName, &tblRec );
	__CheckRC( status, msg, "VD_drwlo_gtab", wrapup );

	/* put table info */

	partNo = i+1;
	__DBGpr_int( "Table part number", partNo );
	__DBGpr_int( "Table direction", tblRec.direct );

	status =
	_VD_SEND_OBJ( me->hdrIds[i], VDdrwTblHdr.VDputTableInfo( 	
							&msg,
							me->tblLayoutName,
							&partNo,
							&tblRec.direct ) );
	__CheckRC( status, msg, "VDdrwTblHdr.VDputTableInfo", wrapup );

	/* put cs location */

	status =
	_VD_SEND_OBJ( me->hdrIds[i], VDdrwTblHdr.VDputCsLocation( 	
							&msg,
							csLoc ) );
	__CheckRC( status, msg, "VDdrwTblHdr.VDputCsLocation", wrapup );

	/* 
         * put header and toConstruct types 
         * trailer type will be set by the place_table method
	 */

	status =
	_VD_SEND_OBJ( me->hdrIds[i], VDdrwTblHdr.VDputConstructInfo(
							&msg,
							&hdrType,
							NULL,
							&cnstType ) );
	__CheckRC( status, msg, "VDdrwTblHdr.VDputConstructInfo", wrapup );

	/* create and initialize templates */

	ASmake_source_from_env(	&me->cs[i].obj_id,
				&me->cs[i].mod_env,
				&root, 0 );

	prop = AChdr_nodisplay | AChdr_noprotect | AChdr_nocompute;
	status =
	_VD_SEND_OBJ( me->hdrIds[i], VDdrwTblHdr.VDcreate(	
							&msg,
							0, NULL,
							"VDdrwTblHdr",
							prop,
							1,
							&root ) );
	__CheckRC( status, msg, "VDdrwTblHdr.VDcreate", wrapup );
						
	/* construct the header */

	status =
	_VD_SEND_OBJ( me->hdrIds[i], VDdrwTblHdr.VDconstructHdrTrl( &msg ) );
	__CheckRC( status, msg, "VDdrwTblHdr.VDconstructHdrTrl", wrapup );

	/* update tMatrix */

	status =
	_VD_SEND_OBJ( me->hdrIds[i], VDdrwTblHdr.VDsetMatrixFromCS( &msg ) );
	__CheckRC( status, msg, "VDdrwTblHdr.VDsetMatrixFromCS", wrapup );

	/* add the header object to the table */

	status =
	_VD_SEND_OBJ( me->tblObj.obj_id, VDdrwTbl.VDaddHeaders( 
							&msg,
							1,
							&me->hdrIds[i] ) );
	__CheckRC( status, msg, "VDdrwTbl.VDaddHeaders", wrapup );
    }

UPD_STARTROWNO :

    /* update startRowNo for all headers */

    startRowNo = 1;
    for( i = 0 ; i < nbTotHdrs ; i++ )
    {
	/* put startRowNo */

	__DBGpr_int( "StartRowNo ", startRowNo );
	status =
	_VD_SEND_OBJ( me->hdrIds[i], VDdrwTblHdr.VDputStartRowNo( 	
							&msg,
							startRowNo ) );
	__CheckRC( status, msg, "VDdrwTblHdr.VDputCsLocation", wrapup );

	startRowNo = me->splitLocs[i] + 1;
    }

wrapup :

    if( !(status & msg & 1) )
    {
	*sts = VD_ERROR;
	UI_status( "Error encountered : command terminated" );
    }
    End
    return OM_S_SUCCESS;
}

/*+me
 ---------------------------------------------------------------------------
  Public Message handle_row_delete

  Abstract
        This method deletes the row objects whose rows were deleted or
        summarized in the form.  The last headers without any rows will
        also be deleted, and the splitLocs vla will be updated.

  Arguments
        long         *sts            O       Return code

  Status code
        status = OM_S_SUCCESS

  Return Code
        *sts = VD_SUCCESS
                VD_ERROR if error
 ---------------------------------------------------------------------------
-me*/

method  handle_row_delete( long * sts )
{
    IGRint		i, ind,
			nbRowsDel,
			nbRows, nbHdrs,
			size = sizeof( struct GRmd_env ),
			nbToDel;
    IGRlong		msg,
			status = OM_S_SUCCESS;
    struct GRmd_env	mod_env;

    SetProc( VDCmdCrTbl.handle_row_delete ); Begin

    *sts = VD_SUCCESS;

    /* delete the row objects */

    nbRowsDel = om$dimension_of( varray = me->rowsDel );
    __DBGpr_int( "Number of rows to delete", nbRowsDel );

    for( i = 0 ; i < nbRowsDel ; i++ )
    {
	status =
	_VD_SEND_OBJ( me->rowsDel[i], VDdrwTblRow.VDdeleteRow( &msg ) );
	CheckRC( status, msg );
    }

    /* get current module environment */

    status = gr$get_module_env(	msg	= &msg,
				sizbuf	= &size,
				buffer	= &mod_env );
    __CheckRC( status, msg, "gr$get_module_env", wrapup );
    
    nbRows = om$dimension_of( varray = me->rows );
    __DBGpr_int( "Total number of rows", nbRows );

    nbHdrs = om$dimension_of( varray = me->hdrIds );
    __DBGpr_int( "Number of headers ", nbHdrs );

    /* delete excess headers */

    nbToDel = 0;
    ind = nbHdrs - 1;
    while( ind > 0 && nbRows <= me->splitLocs[ind-1] )
    {
	/* first disconnect the header from the table object */

	status =
	_VD_SEND_OBJ( me->tblObj.obj_id, VDdrwTbl.VDremoveHeaders( 
						&msg,
						1,
						&me->hdrIds[ind] ) );
	__CheckRC( status, msg, "VDdrwTbl.VDremoveHeaders", wrapup );

	status =
	_VD_SEND_OBJ( me->hdrIds[ind], VDdrwTblHdr.VDdeleteHdr(	&msg ) );
	CheckRC( status, msg );

	nbToDel++;
	ind--;
    }

    __DBGpr_int( "NUmber to delete", nbToDel );

    if( !nbToDel )
	goto wrapup;

    nbHdrs -= nbToDel;
    __DBGpr_int( "New number of headers", nbHdrs );

    /* resize the hdrIds vla */

    status = om$vla_set_dimension(	varray	= me->hdrIds,
					size	= nbHdrs );
    CheckRC( status, 1 );

    /* resize the splitLocs vla */

    status = om$vla_set_dimension(	varray	= me->splitLocs,
					size	= nbHdrs );
    CheckRC( status, 1 );

    me->splitLocs[nbHdrs-1] = nbRows;

wrapup :

    if( !(status & msg & 1) )
	*sts = VD_ERROR;
    End
    return OM_S_SUCCESS;
}

end implementation VDCmdCrTbl;
