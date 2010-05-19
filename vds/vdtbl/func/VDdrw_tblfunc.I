/* $Id: VDdrw_tblfunc.I,v 1.36 2002/06/06 17:01:57 ylong Exp $  */

/* I/VDS
 * -------------------------------------------------------------------------
 *
 * File:        vdtbl/func/VDdrw_tblfunc.I
 *
 * Description:
 *         API routines for table.
 *		VDdrw_getObjectsFromTable
 *		VDdrw_reviewTable
 *		VDdrw_addObjectsToTable
 *		VDdrw_processTableObjects
 *		VDdrw_getTableHeaderAttr
 *		VDdrw_setTableHeaderAttr
 *		VDdrw_getTblSrc
 *		VDtbl_get_hdrtbl
 *
 * Dependencies:
 *
 * History:
 *      07/19/00        Ming            Created
 *	02/01/01	ylong		TR3309, added VDdrw_removeLinedOutRow()
 *	02/19/01	ylong		added func VDtbl_get_hdrtbl()
 *	03/06/01	ylong		added VDdrw_removeInvalidRow()
 *	05/22/01	ylong		added VDdrw_getTblSrc()
 *	02/20/02	ylong		CR6009, CR6010 and CR6039
 *	06/05/02	ylong		CR6391
 * -------------------------------------------------------------------------
 */

class implementation Root;

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <math.h>

#include "igrtypedef.h"
#include "OMerrordef.h"
#include "OMtypes.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMmacros.h"

#include "EMSmsgdef.h"
#include "exmacros.h"
#include "macro.h"
#include "ndmacros.h"
#include "nddef.h"
#include "batch.h"
#include "grdpbmacros.h"
#include "grdpbdef.h"
#include "asmacros.h"
#include "asbox.h"

#include "v_miscmacros.h"
#include "v_dbgmacros.h"
#include "v_datamacros.h"
#include "v_slc.h"

#include "VDdrwlo.h"
#include "VDdrwlo_pr.h"
#include "VDtblCmdDef.h"

#include "ACattrib.h"
#include "ACrg_collect.h"

#include "vddrwattr.h"
#include "vdparmacros.h"
#include "VDcompmacros.h"
#include "VDCmdDef.h"
#include "VDattrexp.h"
#include "VDdrwtbl.h"
#include "VDsa.h"
#include "v_drwprocess.h"
#include "vdtblmacros.h"
#include "VDctx.h"
#include "VDtblXml.h"
#include "VDobj.h"
#include "VDchn.h"

%safe
static  IGRshort        sum_sort_flag = 1;
static	IGRint		percent;
%endsafe

from NDnode		import NDget_objects,
			       NDdisconnect,
			       NDconnect,
			       NDchange_connect;
from NDmacro		import ACreturn_foot,
			       ACtest_consumed;
from ACrg_collect	import AClist_attribute,
			       ACget_named_attribute,
			       ACset_list_attribute;
from VDdrwTbl		import VDgetTableParts,
			       VDgetTableLayoutName,
			       VDremoveHeaders,
			       VDgetTotalNbOfRows;
from VDdrwTblHdr	import VDgetRowInfo,
			       VDremoveRow,
			       VDaddAndConstructRows,
			       VDgetCornerPointForRow,
			       VDputConstructInfo,
			       VDconstructHdrTrl,
			       VDgetRowHeight,
			       VDinsertRow,
			       VDdeleteHdr,
			       VDrowNoToGRid;
from VDdrwTblRow	import VDgetParentObjectList,
			       VDgetQtyExpr,
			       VDgetRowNumber,
			       VDputQtyExpr,
			       VDisRowLinedOut,
			       VDconstructRow,
			       VDinitTblRow,
			       VDputLineOutFlag,
			       VDcreate,
			       VDdeleteRow,
			       VDputUserDefRowFlag,
			       VDgetParentSetId,
			       VDputItemNumber,
			       VDputRowNumber,
			       VDgetItemNumber,
			       VDgetTableHeader,
			       VDgetCurrentRowValues ;
from VDdrwSet		import VDemptySet, 
			       VDaddObjectsToSet,
			       VDinitSet,
			       VDgetSetObjects;
from ACcpx		import ACfind_temp_obj;
from GRgencs		import GRcvt_to_wld_coords;
from GRgraphics		import GRdisplay;

extern GRclassid 	OPP_VDdrwSet_class_id;
extern GRclassid 	OPP_VDdrwTblRow_class_id;
extern struct ext_list  NDdelete;

%safe
static	FILE	*UTAD_fp = stdout; 
static	int	UTAD_dbg = 0;
%endsafe

#define	UTAD_INFO( info ) \
	if( UTAD_dbg ) printf(" Line: %d - %s failed\n", __LINE__, (info) );

/*
#define	UTAD_SetProc( p ) char __FUNC__[40]; strcpy( __FUNC__, #p )

#define	UTAD_Begin \
	if( UTAD_dbg ) printf("%s:%d >> %s: BEGIN\n", \
			__FILE__,__LINE__,__FUNC__ );

#define UTAD_END \
	if( UTAD_dbg ) printf("%s:%d << %s: END\n", \
			__FILE__,__LINE__, __FUNC__ );
*/

int VDtbl_setDbg( char *filename, int dbgSt )
{
	SetProc( VDtbl_setDbg ); Begin

	if( dbgSt ) {
		if( filename && *filename ) {
			UTAD_fp = fopen( filename, "w" );
			if(!UTAD_fp) {
				__DBGpr_str("Failed to open file", filename);
			}
		}
		else {
			UTAD_fp = stdout;
		}
		
		UTAD_dbg = 1;
	}
	else {
		UTAD_dbg = 0;
		if( UTAD_fp != NULL && UTAD_fp != stdout ) {
			fclose( UTAD_fp );
			UTAD_fp = NULL;
		}
	}

	End
	return 1;
}

int VDtbl_getDbgState() {
	return UTAD_dbg;
}

IGRshort VDdrw_setSumSortFlag()
{
        sum_sort_flag = !sum_sort_flag;
        return sum_sort_flag;
}

IGRshort VDdrw_getSumSortFlag()
{
        return sum_sort_flag;
}

/*-------------------------------------------------- */

IGRlong VDtblPrintPrcInfo( struct PrcInfo *prcInfo )
{
    long        status, msg;
    char        buf[1024];
 
    SetProc( VDtblPrintPrcInfo ); Begin
 
    if( !UTAD_dbg || prcInfo == NULL) goto wrapup;
 
    sprintf(buf,"prcInfo[%d] %d,%d - %d,%d tbl %d, pr:%d, path:%s, pcmk:%s, type:%s \n",
                 prcInfo->process,
                 prcInfo->model.obj_id.osnum, prcInfo->model.obj_id.objid,
                 prcInfo->modelNew.obj_id.osnum, prcInfo->modelNew.obj_id.objid,
                 prcInfo->drwtbl.obj_id.objid,
                 prcInfo->pretend.objid, prcInfo->path, prcInfo->pcmk, prcInfo->type );
    fprintf(UTAD_fp, buf);
    fflush( UTAD_fp );
 
wrapup:
    End
    return 1;
}
/*--------------------------------------------------
 */
IGRlong VDtblPrintRowInfo( struct VDdrw_rowInfo const *rowInfo )
{
    long	status, msg;
    int		rowNo, size;
    short	lnOut = 0;
    char	buf[1024], txt[128], itemNo[20];
    TGRid	rowId;

    SetProc( VDtblPrintRowInfo ); Begin

    if( !UTAD_dbg || rowInfo == NULL) goto wrapup;

    rowId = rowInfo->rowId;

    if( rowId.objid != NULL_OBJID ) {
       status =
       om$send( msg      = message VDdrwTblRow.VDgetRowNumber(  &msg,
                                                             &rowNo),
	        senderid = NULL_OBJID,
                targetid = rowId.objid,
                targetos = rowId.osnum );
       if( !(status&msg&1) ) rowNo = -1;

       status = om$send(   msg      = message VDdrwTblRow.VDgetItemNumber
                                                ( &msg, &size, itemNo),
			   senderid = NULL_OBJID,
			   targetid = rowId.objid,
			   targetos = rowId.osnum );
       if( !(status&msg&1) ) {
	   strcpy(itemNo, "N");
       }

       lnOut = 0;
       status =
       om$send(	msg      = message VDdrwTblRow.VDisRowLinedOut(&msg,
                                                            &lnOut),
		senderid = NULL_OBJID,
		targetid = rowId.objid,
		targetos = rowId.osnum );
       if( !(status&msg&1) ) lnOut = -1;

       sprintf(txt,", rowNo: %d, item: %s, lnOut: %d\n",
		rowNo, itemNo, lnOut);
    }
    else {
        rowId.osnum = -1;
	txt[0] = '\n';
    }
	    
    buf[0] = '\0';
    sprintf(buf,"rowInfo - id: %d,%d, nbObjs: %d, startInd: %d, flag: %d",
		rowId.osnum, rowId.objid, 
		rowInfo->nbObjs, rowInfo->startIndex, rowInfo->flag);
    strcat(buf, txt);

    fprintf(UTAD_fp, buf);
    fflush( UTAD_fp );

wrapup:
    End
    return 1;
}

/*--------------------------------------------------
 */
IGRlong VDtblPrintRow( TGRid const *rowId )
{
	long	status = 0, msg;
	int	i;
	int	rowNo, size;
	short	lnOut = 0;
	char	buf[1024], txt[128], itemNo[20];

	SetProc( VDtblPrintRow ); Begin

	if( !UTAD_dbg ) goto wrapup;

	    if( rowId->objid == NULL_OBJID ) {
		fprintf(UTAD_fp, "print row: id is NULL\n");
    		fflush( UTAD_fp );
		return 1;
	    }

            status =
            om$send( msg      = message VDdrwTblRow.VDgetRowNumber(  &msg,
                                                                 &rowNo),
		     senderid = NULL_OBJID,
                     targetid = rowId->objid,
                     targetos = rowId->osnum );
	    if( !(status&msg&1) ) rowNo = -1;

 	    status = om$send(	msg    = message VDdrwTblRow.VDgetItemNumber
                                                ( &msg, &size, itemNo),
				senderid = NULL_OBJID,
                                targetid = rowId->objid,
                                targetos = rowId->osnum );
             if( !(status&msg&1) ) {
		strcpy(itemNo, "N");
	     }

	     lnOut = 0;
             status =
             om$send( msg      = message VDdrwTblRow.VDisRowLinedOut(&msg,
                                                                &lnOut),
                     senderid = NULL_OBJID,
                     targetid = rowId->objid,
		     targetos = rowId->osnum );
	    if( !(status&msg&1) ) lnOut = -1;
	    
	    sprintf(buf, "rowNo: %d, id: %d,%d, item: %s, lnOut: %d\n",
			rowNo, rowId->osnum, rowId->objid, 
			itemNo, lnOut);
	    fprintf(UTAD_fp, "%s", buf);
	    fflush( UTAD_fp );

	End
wrapup:
	return 1;
}

/* ------------------------------------------------------------------
 */
static int setLineOut( struct VDdrw_rowInfo *r1, struct VDdrw_rowInfo *r2 )
{
	IGRlong		status = 0, msg = 0;
	IGRshort	linOut1 = 0, linOut2 = 0;
	IGRint		nb1 = 0, nb2 = 0, size;
	IGRchar		itemNo[40];

	if( r1->rowId.objid != NULL_OBJID ) {
            status =
            om$send(	msg      = message VDdrwTblRow.VDisRowLinedOut
							(&msg, &linOut1),
			senderid = NULL_OBJID,
			targetid = r1->rowId.objid,
			targetos = r1->rowId.osnum );
	    if( !(status&msg&1) ) linOut1 = 0;

 	    status = om$send(	msg    = message VDdrwTblRow.VDgetItemNumber
                                                ( &msg, &size, itemNo),
				senderid = NULL_OBJID,
                                targetid = r1->rowId.objid,
                                targetos = r1->rowId.osnum );
             if( (status&msg&1) ) {
		nb1 = atoi( itemNo );
	     }
	}

	if( r2->rowId.objid != NULL_OBJID ) {
            status =
            om$send( msg      = message VDdrwTblRow.VDisRowLinedOut(&msg,
                                                                &linOut2),
                     senderid = NULL_OBJID,
                     targetid = r2->rowId.objid,
		     targetos = r2->rowId.osnum );
	    if( !(status&msg&1) ) linOut2 = 0;

	    *itemNo = 0;
 	    status = om$send(	msg    = message VDdrwTblRow.VDgetItemNumber
                                                ( &msg, &size, itemNo),
                                senderid = NULL_OBJID,
                                targetid = r2->rowId.objid,
                                targetos = r2->rowId.osnum );
            if( (status&msg&1) ) {
		nb2 = atoi( itemNo );
	    }
	}

	if( !linOut1 && !linOut2 ) return 0;
	if(  linOut1 &&  linOut2 ) return (nb1 - nb2);

	return ( linOut1 - linOut2 );
}

/* ------------------------------------------------------------------
 */
static int sortLineOutByItemNo(	struct VDdrw_rowInfo *r1, 
				struct VDdrw_rowInfo *r2 )
{
	IGRlong	status = 0, msg = 0;
	IGRchar	itemNo[40];
	IGRint	size;
	IGRint	nb1 = 0;
	IGRint	nb2 = 0;

	if( r1->rowId.objid != NULL_OBJID ) {
 	     status = om$send ( msg    = message VDdrwTblRow.VDgetItemNumber
                                                ( &msg, &size, itemNo),
                                senderid = NULL_OBJID,
                                targetid = r1->rowId.objid,
                                targetos = r1->rowId.osnum );
             if( (status&msg&1) ) {
		nb1 = atoi( itemNo );
	     }
	}

	*itemNo = 0;
	if( r2->rowId.objid != NULL_OBJID ) {
 	     status = om$send ( msg    = message VDdrwTblRow.VDgetItemNumber
                                                ( &msg, &size, itemNo),
                                senderid = NULL_OBJID,
                                targetid = r2->rowId.objid,
                                targetos = r2->rowId.osnum );
             if( (status&msg&1) ) {
		nb2 = atoi( itemNo );
	     }
	}

	return (nb1 - nb2);
}

/* ------------------------------------------------------------------
 * Sort list so that newly added objects are at the end of the list
 */
static int setAppendList( struct PrcInfo *e1, struct PrcInfo *e2 )
{
        if( e1->process == NEW_MODEL && e2->process != NEW_MODEL ) {
                return 1;
        }
        else if( e1->process != NEW_MODEL && e2->process == NEW_MODEL ) {
                return -1;
        }
        else {
                return 0;
        }
}


/* ------------------------------------------------------------------
 */
static int setRowsByItemNo( struct VDdrw_rowInfo *r1, struct VDdrw_rowInfo *r2 )
{
	IGRlong		status = 0, msg = 0;
	IGRint		size;
	IGRshort	nb1 = 0, nb2 = 0;
	IGRchar		itemNo[80];

	*itemNo = 0;
	status =
        om$send( msg      = message VDdrwTblRow.VDgetItemNumber(
                                                        &msg, 
							&size,
							itemNo),
		 senderid = NULL_OBJID,
		 targetid = r1->rowId.objid,
		 targetos = r1->rowId.osnum );

	if( (status&msg&1) ) nb1 = atoi(itemNo);

	*itemNo = 0;
	status =
        om$send( msg      = message VDdrwTblRow.VDgetItemNumber(
                                                        &msg, 
							&size,
							itemNo),
		 senderid = NULL_OBJID,
		 targetid = r2->rowId.objid,
		 targetos = r2->rowId.osnum );

	if( (status&msg&1) ) nb2 = atoi(itemNo);

	return (nb1 - nb2);
}


/*+fe
 -------------------------------------------------------------------------
  Function VDdrw_getObjectsFromTable

  Abstract
        Function retrieves all objects from the existing table

  Arguments

        IGRlong         *msg            O       return code
	struct GRid	*tblId		I	table ID
        IGRint		*count          O	No. of objects added
	struct PrcInfo	**objectList	O	object list added

  Returns
        OM_S_SUCCESS    = if success
        OM_E_ABORT      = if error
 ------------------------------------------------------------------------- -fe*/
IGRlong VDdrw_getObjectsFromTable( IGRlong	  *msg,
			           struct GRid    *tblId,
				   IGRint	  *count,
			           struct PrcInfo **objectList )
{
    IGRint		 i, j, k;
    IGRlong		 status;
    IGRint		 ind = 0,
			 nbRows = 0,
			 nbObjs,
			 tolNbObjs,
			 nbHdrRows,
			 tmpNbObjs,
			 nbParents,
			 nbHdrs,
			 startRowNo;
    struct GRid		 *hdrId,
			 footId,
			 parentIds[2],
			 setId;
    struct VDdrw_rowInfo *rowIds;
    struct GRobj_env     *locObject;
    OM_S_OBJID           mdId;
    IGRshort             matType,
			 isLinedOut;
    IGRmatrix            mat;
    struct ACrg_coll     Attr;
    IGRchar		 occurrance_name[50];
    IGRchar		 szmsg[128];


    SetProc( VDdrw_getObjectsFromTable ); Begin

    *msg      = MSSUCC;
    status    = 0;
    locObject = NULL;
    hdrId     = NULL;
    rowIds    = NULL;

    if( tblId == NULL ) goto wrapup;

    /*
    ** get number of table parts(headers)
    */
    nbHdrs = 0;
    status =
    om$send( msg      = message VDdrwTbl.VDgetTableParts(msg,
                                                         &nbHdrs,
                                                         NULL),
	     senderid = NULL_OBJID,
             targetid = tblId->objid,
             targetos = tblId->osnum );

    if( !(status&*msg&1) || (nbHdrs <= 0) ) 
    {
	UTAD_INFO("VDdrwTbl.VDgetTableParts");
	goto wrapup;
    }

    hdrId = _MALLOC( nbHdrs, struct GRid );
    if( hdrId == NULL ) goto wrapup;

    status =
    om$send( msg      = message VDdrwTbl.VDgetTableParts(msg,
                                                         &nbHdrs,
                                                         hdrId),
             senderid = NULL_OBJID,
    	     targetid = tblId->objid,        
             targetos = tblId->osnum );

    if( !(status&*msg&1) ) 
    {
	UTAD_INFO("VDdrwTbl.VDgetTableParts");
	goto wrapup;
    }

    /*
    ** Retrive total No. of rows in the table
    */
    status =
    om$send( msg      = message VDdrwTbl.VDgetTotalNbOfRows(msg,&nbRows),
             senderid = NULL_OBJID,
             targetid = tblId->objid,
             targetos = tblId->osnum );
    if( !(status&*msg&1) )
    {
	UTAD_INFO("VDdrwTbl.VDgetTotalNbOfRows");
	goto wrapup;
    }

    if( nbRows > 0 )
    {
      /*
      ** allocate memory for rows
      */
      rowIds = _MALLOC( nbRows, struct VDdrw_rowInfo );
      if( !rowIds ) goto wrapup;
    }
    else
    {
      *count = 0;
      status = OM_S_SUCCESS;
      goto wrapup;
    }

    /* 
    ** Retrieve all model objects.
    */
    ind = 0;
    tolNbObjs = 0;
    for( i = 0 ; i < nbHdrs ; i++ )
    {
      status =
      om$send( msg      = message VDdrwTblHdr.VDgetRowInfo(msg,
                                                           &nbHdrRows,
                                                           &startRowNo),
	       senderid = NULL_OBJID,
               targetid = hdrId[i].objid,
               targetos = hdrId[i].osnum );
      if( !(status&*msg&1) ) 
      {
	UTAD_INFO("VDdrwTblHdr.VDgetRowInfo");
	goto wrapup;
      }

      for( j = startRowNo ; j < startRowNo+nbHdrRows ; j++ )
      {
        nbObjs = 0;

        status =
        om$send( msg      = message VDdrwTblHdr.VDrowNoToGRid(
							msg,
                                                        j,
                                                        &rowIds[ind].rowId),
                 senderid = NULL_OBJID,
                 targetid = hdrId[i].objid,
                 targetos = hdrId[i].osnum );
        if( !(status&*msg&1) ) 
	{
	   UTAD_INFO("VDdrwTblHdr.VDrowNoToGRid");
	   goto wrapup;
	}

        isLinedOut = 0;
        status =
        om$send( msg      = message VDdrwTblRow.VDisRowLinedOut(msg,
                                                                &isLinedOut),
                 senderid = NULL_OBJID,
                 targetid = rowIds[ind].rowId.objid,
                 targetos = rowIds[ind].rowId.osnum );
        CheckRC( status, *msg );

        if( isLinedOut ) 
        {
          rowIds[ind].nbObjs = 0;
        }
	else
        {
          status =
          om$send( msg      = message VDdrwTblRow.VDgetParentObjectList(
							msg,
							&rowIds[ind].nbObjs,
							NULL),
		   senderid = NULL_OBJID,
                   targetid = rowIds[ind].rowId.objid,
                   targetos = rowIds[ind].rowId.osnum );
          if( !(status&*msg&1) ) 
	  {
		UTAD_INFO("VDdrwTblRow.VDgetParentObjectList");
		goto wrapup;
	  }
  	}

        tolNbObjs += rowIds[ind].nbObjs;
        ind++;
      }
    }

    nbRows = ind;

    if( count ) *count = tolNbObjs;
    if( !objectList )
    {
      status = OM_S_SUCCESS;
      *msg   = OM_S_SUCCESS;
      goto wrapup;
    }

    /*
    ** set up memory for object list contained in the existing table
    */
    if( objectList && (tolNbObjs>0) )
    {
      if( *objectList != NULL )
      {
 	printf("(*objectList) must be NULL\n");
        goto wrapup;
      }
      *objectList = _MALLOC( tolNbObjs*2, struct PrcInfo );
      if( !(*objectList) ) goto wrapup;

      occurrance_name[0] = '\0';
      for( i = 0 ; i < tolNbObjs*2 ; i++ )
      {
        strcpy( (*objectList)[i].path, occurrance_name );
        strcpy( (*objectList)[i].pcmk, occurrance_name );
        strcpy( (*objectList)[i].type, occurrance_name );
      }

      locObject = _MALLOC( tolNbObjs*2, struct GRobj_env );
      if( locObject == NULL ) goto wrapup;
    }
    else
    {
      status = OM_S_SUCCESS;
      goto wrapup;
    }

    UI_status("Locating objects from table rows...");
    ind = 0;
    tolNbObjs = 0;
    for( i = 0 ; i < nbRows ; i++ )
    {
      percent = 100*(1+i)/nbRows;
      if( !(percent%10) ) {
        sprintf( szmsg, "Locating objects from table row %d%s", percent, "%" );
        UI_status( szmsg );
      }

      tmpNbObjs = 0;
      if( rowIds[i].nbObjs > 0 )
      {
	struct GRid *pretend;

	/*
	** This part should be replaced by VDdrwTblRow.VDgetParentObjectList
	** to get objects, and VDdrw_getAttFromColl to get named attributes
	*/

        setId.objid = NULL_OBJID;
        status =
        om$send( msg      = message VDdrwTblRow.VDgetParentSetId(
                                                        msg,
                                                        &setId),
                 senderid = NULL_OBJID,
                 targetid = rowIds[i].rowId.objid,
                 targetos = rowIds[i].rowId.osnum );
        if( !(status&*msg&1) ) 
	{
	   UTAD_INFO("VDdrwTblRow.VDgetParentSetId");
	   goto wrapup;
	}

        /*
        ** get the current module id 
        */
        status = ex$get_modid( mod_osnum = setId.osnum,
                               mod_id    = &mdId );

        status =
        om$send( msg      = message NDnode.NDget_objects(ND_ROOT | ND_IN_BUF,
							 NULL,
							 0,
							 &pretend,
							 0,
							 OM_K_MAXINT,
							 &tmpNbObjs),
		 senderid = NULL_OBJID,
                 targetid = setId.objid,
                 targetos = setId.osnum );
        if( !(status&1) )
	{
	   UTAD_INFO("NDnode.NDget_objects"); 
	   goto wrapup;
	}

        for( j = 0 ; j < tmpNbObjs ; j++ )
        {
	  (*objectList)[ind+j].pretend = pretend[j];

	  footId.objid = NULL_OBJID;
	  status =
          om$send( msg      = message NDmacro.ACreturn_foot(msg,
							    "",
							    &footId,
							    &matType,
                                                            mat),
		   senderid = NULL_OBJID,
		   targetid = pretend[j].objid,
		   targetos = pretend[j].osnum );

  	  if( !(status&*msg&1) ||
	      (footId.objid==NULL_OBJID) ||
	      (NDin_buffer(footId, &NDdelete) != -1) )
          {
	    locObject[ind+j].obj_id.objid = NULL_OBJID;
	    locObject[ind+j].obj_id.osnum = 0;

	    /*
      	    ** retrieve all the parents of table row
      	    */
    	    status =
    	    om$send( msg      = message NDnode.NDget_objects(
						     ND_ROOT,
                                                     parentIds,
                                                     2,
                                                     NULL,
                                                     0,
                                                     OM_K_MAXINT,
                                                     &nbParents),
             	     senderid = NULL_OBJID,
             	     targetid = rowIds[i].rowId.objid,
             	     targetos = rowIds[i].rowId.osnum );
            if( !(status&1) || (nbParents<=0) ) 
	    {
	      status = 1;
	      *msg = 1;
	      continue;
 	    }
	    
  	    occurrance_name[0] = '\0';
 	    sprintf( occurrance_name, "occurance_%d", j+1 );
	    strcpy( Attr.name, occurrance_name );
            status =
    	    om$send( msg      = message ACrg_collect.ACget_named_attribute(
						msg,
						&Attr),
		     senderid = NULL_OBJID,
                     targetid = parentIds[0].objid,
             	     targetos = parentIds[0].osnum );
    	    if( !(status&*msg&1) )
	    {
	      status = 1;
	      *msg = 1;
	      continue;
 	    }

	    if( Attr.desc.type == AC_ATTRIB_TEXT )
	      strcpy( (*objectList)[ind+j].path, Attr.desc.value.att_txt );
   	    else
	      continue;
          }
	  else
	  {
	    locObject[ind+j]._grid = footId;
            locObject[ind+j]._md_os = footId.osnum;
            locObject[ind+j]._md_id = mdId;
            locObject[ind+j]._matrix_type = matType;

            for( k = 0 ; k < 16 ; k++ )
              locObject[ind+j]._matrix[k] = mat[k];
	  }
        }

        rowIds[i].nbObjs = tmpNbObjs;

        for( j = ind ; j < ind+rowIds[i].nbObjs ; j++ )
        {
          (*objectList)[tolNbObjs].model = locObject[j];
          (*objectList)[tolNbObjs].VDdrwSet = setId;
          (*objectList)[tolNbObjs].drwtbl.obj_id = rowIds[i].rowId;
          (*objectList)[tolNbObjs].modelNew.obj_id.objid = NULL_OBJID;
          (*objectList)[tolNbObjs].application = TABLE;
        
          tolNbObjs++;
        }

        ind += rowIds[i].nbObjs;
      }     
    }
    UI_status( "Complete Locating objects from table rows" );

    for( i = 0 ; i < tolNbObjs ; i++ )
    {
      if( (*objectList)[i].model.obj_id.objid != NULL_OBJID )
      {
	if( !(1&(status = om$is_objid_valid(
		osnum = (*objectList)[i].model.obj_id.osnum,
		objid = (*objectList)[i].model.obj_id.objid))) )
        {
	  (*objectList)[i].model.obj_id.objid = NULL_OBJID;
	  (*objectList)[i].model.obj_id.osnum = 0;
        }
      }
    }
 
    *count = tolNbObjs;

    status = OM_S_SUCCESS;
    *msg   = OM_S_SUCCESS;


wrapup:
    _FREE( locObject );
    _FREE( hdrId );
    _FREE( rowIds );

    End
    return status;
} /* VDdrw_getObjectsFromTable */


/*+me
 ---------------------------------------------------------------------------
  Public Function VDdrw_summ_and_sort_objs

  Abstract
        This function summarizes and sorts the newly located objects.

 ---------------------------------------------------------------------------
-me*/

IGRlong  VDdrw_summ_and_sort_objs( IGRlong 	        *msg,
				   struct VDdrwlo_tab   *tblRec,
				   IGRint	        *nbObjs,
				   IGRint	        *nbRows,
 				   IGRint		*addCnt,
				   struct VDdrw_rowInfo **rows,
				   struct GRobj_env	*totalList )
{
    IGRint               i, j,
                         nbNewRows;
    IGRlong              status = OM_S_SUCCESS, locmsg;
    struct VDrowinfo     *sortRows = NULL;
    IGRshort             isLinedOut, numLinedOut;
    struct VDdrw_rowInfo *LinedOut = NULL;
    IGRint               tmpnb;


    SetProc( VDdrw_summ_and_sort_objs ); Begin

    *msg = MSSUCC;
    if( !sum_sort_flag ) goto wrapup;

    status = 0;

    /* Added by Ming for TR179900821 */
    if( *nbRows > *nbObjs ) tmpnb = *nbRows;
    else tmpnb = *nbObjs;


    /*
     * Ad: Code needs to get reviewed for optimilization.
     */
    numLinedOut = 0;
    for( i = 0 ; i < *nbRows ; i++ )
    {
      isLinedOut = 0;
      status =
      om$send( msg      = message VDdrwTblRow.VDisRowLinedOut(msg,
							      &isLinedOut),
               senderid = NULL_OBJID,
               targetid = (*rows)[i].rowId.objid,
               targetos = (*rows)[i].rowId.osnum );
      CheckRC( status, *msg );

      if( isLinedOut ) 
      {
	 numLinedOut++;
      }
    }

    if( UTAD_dbg ) {
        fprintf( UTAD_fp, "\nVDdrw_summ_and_sort_objs: input objects[%d]\n", *nbObjs );
	for( i = 0; i < *nbObjs; i++ ) {
		
	   fprintf(UTAD_fp,"object[%d]: %d,%d\n",
		i,totalList[i].obj_id.osnum,totalList[i].obj_id.objid);
	}

        fprintf( UTAD_fp, "VDdrw_summ_and_sort_objs: numLineOut:%d\n", numLinedOut );
    }

    if( numLinedOut )
    {
      LinedOut = _MALLOC( numLinedOut, struct VDdrw_rowInfo );
      if( !LinedOut )
      {
        *msg = VD_ERROR;
        goto wrapup;
      }

      /*
       * sort rows so that lined out rows are at bottom of the list
       */
      qsort (	(char *)(*rows),
		(*nbRows),
		sizeof(struct VDdrw_rowInfo),
		(int (*)())setLineOut );

      /* Added by Ming for TR179900821 */
      for( i = 0 ; i < numLinedOut ; i++ )
      {
	   memcpy(	(char *) &LinedOut[i],
			(char *) &(*rows)[(*nbRows)-numLinedOut+i],
			sizeof( struct VDdrw_rowInfo ) ) ;
      }
    }

    if( UTAD_dbg ) {
        fprintf( UTAD_fp, "\n\nSumm_and_Sort LineOut Objects %d \n", numLinedOut );
        for(i = 0; i < numLinedOut; i++ ) {
           VDtblPrintRowInfo( &LinedOut[i] );
        }
   
        fprintf( UTAD_fp, "\n\nSumm_and_Sort ACTIVE Objects %d \n", (*nbRows)-numLinedOut );
        for(i = 0; i < (*nbRows)-numLinedOut; i++ ) {
           VDtblPrintRowInfo( &(*rows)[i] );
        }
    }

    *rows = _REALLOC( (*rows), tmpnb+numLinedOut, struct VDdrw_rowInfo );
    if( !(*rows) ) goto wrapup;

    /*
     * Initialize the new values of the table.
     */
    {
	IGRint	lastInd;
	IGRint	ind;

	ind  =  (*nbRows)-numLinedOut-1;
	lastInd = (*rows)[ind].startIndex + (*rows)[ind].nbObjs;

        for( i=(*nbRows)-numLinedOut; i<tmpnb+numLinedOut ; i++ ){
            (*rows)[i].rowId.objid = NULL_OBJID;
            (*rows)[i].nbObjs = 0;
            (*rows)[i].startIndex = lastInd;
            (*rows)[i].qty.nSflag = VD_DRWLO_EN_COUNT;
            (*rows)[i].qty.szExp[0] = '\0';
            (*rows)[i].flag = VD_DRW_ROW_NEW;
	}
    }
	

   /*
   **  Added by ylong for TR179900885, always sum and sort sort all objects
   **  whenever new objs added to table. To resume it to previous version,
   **  just remove following two lines and restore original parameters for
   **  func call VDsort_tbl().
   */
    nbNewRows = *nbObjs ;
    if( UTAD_dbg ) {
        fprintf( UTAD_fp, "LINE: %d - nbNewRows:%d\n", __LINE__, nbNewRows );
    }

    /*
    ** summarize the objects
    */
    if( UTAD_dbg ) {
        fprintf( UTAD_fp, "\n\nBefore VDdrw_summarizeObjs Objects [%d] \n", nbNewRows );
        for(i = 0; i < nbNewRows ; i++ ) {
           VDtblPrintRowInfo( &(*rows)[i] );
        }
    }

    status = VDdrw_summarizeObjs( msg,
                                  tblRec->SumFil,
                                  &nbNewRows,
                                  &(*rows)[0],
                                  &totalList[0] );
    if( !(status&*msg&1) )
    {
	UTAD_INFO("VDdrw_summarizeObjs");
	goto wrapup;
    }

    __DBGpr_int( "Number of rows after summarization", nbNewRows );

    if( UTAD_dbg ) {
        fprintf( UTAD_fp, "\n\nAfter VDdrw_summarizeObjs Objects [%d] \n", nbNewRows );
        for(i = 0; i < nbNewRows; i++ ) {
           VDtblPrintRowInfo( &(*rows)[i] );
        }
    }

    *nbRows = nbNewRows;
    __DBGpr_int( "New size of me->rows vla", *nbRows );

    if( nbNewRows < 1 )
    {
      *msg = VD_ERROR;
      goto wrapup;
    }

    if( UTAD_dbg ) {
        fprintf( UTAD_fp, "\n\n*nbRows  [%d] \n", *nbRows );
        fprintf( UTAD_fp, "\n\nnumLinedOut  [%d] \n", numLinedOut );
    }

    /* Added by Ming for TR179900821 */
    for( i = *nbRows ; i < *nbRows + numLinedOut ; i++ )
    {
      memcpy( (char *) &(*rows)[i],
              (char *) &LinedOut[i-(*nbRows)],
              sizeof( struct VDdrw_rowInfo ) ) ;
    }

    if( UTAD_dbg ) {
        fprintf( UTAD_fp, "\n\n*nbRows  [%d] \n", *nbRows );
        fprintf( UTAD_fp, "\n\nnumLinedOut  [%d] \n", numLinedOut );
        for(i = 0; i < *nbRows+numLinedOut; i++ ) {
           VDtblPrintRowInfo( &(*rows)[i] );
        }
    }

    *nbRows += numLinedOut;

    if( UTAD_dbg ) {
        fprintf( UTAD_fp, "\n\n*nbRows  [%d] \n", *nbRows );
        fprintf( UTAD_fp, "\n\nnumLinedOut  [%d] \n", numLinedOut );
    }

    /*
    ** sort the objects
    */

    /*
    ** allocate memory for rowinfo structures
    */
    if( nbNewRows > 0 )
    {
      sortRows = _MALLOC( nbNewRows, struct VDrowinfo );
      if( !sortRows )
      {
        *msg = VD_ERROR;
        goto wrapup;
      }
    }
    else goto wrapup;

    /*
    ** initialize buffer
    */
    for( i = 0 ; i < nbNewRows ; i++ )
    {
      sortRows[i].start_rindex = (*rows)[i].startIndex;
      sortRows[i].nbsumobjs    = (*rows)[i].nbObjs;
      sortRows[i].qty.nSflag   = (*rows)[i].qty.nSflag;
      strcpy( sortRows[i].qty.szExp, (*rows)[i].qty.szExp );

      __DBGpr_int( "Index", i );
      __DBGpr_int( "\t\tstart_rindex", sortRows[i].start_rindex );
      __DBGpr_int( "\t\tnbsumobjs", sortRows[i].nbsumobjs );
      __DBGpr_str( "\t\t\tqty expr", sortRows[i].qty.szExp );
    }

    /*
    ** don't check for return codes for sorting.  It does not matter even if
    ** some error occured, can still continue with the processing, with the
    ** unsorted rows
    */

    if( UTAD_dbg ) {
        fprintf( UTAD_fp, "\n\ns BEFORE VDsort_tbl: nbNewRows  [%d] \n", nbNewRows );
        for(i = 0; i < nbNewRows; i++ ) {
           VDtblPrintRowInfo( &(*rows)[i] );
        }
    }

    VDsort_tbl( &locmsg,
                tblRec->SortFil,
		&totalList[0],
                sortRows,
                *nbObjs, //me->nbNewLocObjs, changed for TR179900885
                nbNewRows );

    /*
    ** update the sorted row info's number of objects
    */
    for( i = 0 ; i < nbNewRows ; i++ )
    {
      (*rows)[i].nbObjs = sortRows[i].nbsumobjs;
      (*rows)[i].qty.nSflag   = sortRows[i].qty.nSflag;
      strcpy( (*rows)[i].qty.szExp, sortRows[i].qty.szExp );
    }

    if( UTAD_dbg ) {
        fprintf( UTAD_fp, "\n\ns AFTER VDsort_tbl: nbNewRows  [%d] \n", nbNewRows );
        for(i = 0; i < nbNewRows; i++ ) {
           VDtblPrintRowInfo( &(*rows)[i] );
        }
    }

    /*
    ** update the startIndex for all rows
    */
    (*rows)[0].startIndex = 0;
    for( i = 1 ; i < nbNewRows ; i++ )
        (*rows)[i].startIndex = (*rows)[i-1].startIndex + (*rows)[i-1].nbObjs;

    status = OM_S_SUCCESS;
    *msg   = OM_S_SUCCESS;


wrapup :

    _FREE( LinedOut );
    _FREE( sortRows );

    End
    return status;
} /* VDdrw_summ_and_sort_objs */

/*+fe
 -------------------------------------------------------------------------
  Function VDdrw_getTableRowAttr

  Abstract
        Function adds given objects into the existing table

  Arguments

        IGRlong         *msg            O       return code
        IGRint		ind		I	order of row
	struct GRid     *gridList	I	object list
	struct VDdrw_rowInfo *rows	I 	row list
        IGRint		*nbAttr		O	no. of attributes
        struct ACrg_coll **Attr		O	attribute list

  Returns
        OM_S_SUCCESS    = if success
        OM_E_ABORT      = if error
 ------------------------------------------------------------------------- -fe*/
IGRlong VDdrw_getTableRowAttr( IGRlong 		    *msg,
			       IGRint		    ind,
			       struct GRid          *gridList,
			       struct VDdrw_rowInfo *rows,
			       IGRint  		    *nbAttr,
			       struct ACrg_coll     **Attr ) 
{
    IGRint		  j;
    IGRlong		  status;
    IGRchar               occurance_name[240], pcmk[128];


    SetProc( VDdrw_getTableRowAttr ); Begin

    status = 0;
    *msg   = MSSUCC;

    if( nbAttr == NULL || 
	Attr == NULL || 
	gridList == NULL || 
	rows == NULL ) goto wrapup;

    *nbAttr = rows[ind].nbObjs + 1;
    if( *nbAttr <= 1 )
    {
      *nbAttr = 0;
      status  = 1;
      *msg    = 1;
      goto wrapup;
    }

    (*Attr) = _MALLOC( (*nbAttr), struct ACrg_coll );
    if( !(*Attr) ) goto wrapup;

    strcpy( (*Attr)[0].name, "occurance_count" );
    (*Attr)[0].desc.type = AC_ATTRIB_TEXT;
    occurance_name[0] = '\0';
    sprintf( occurance_name, "%d", rows[ind].nbObjs );
    strcpy( (*Attr)[0].desc.value.att_txt, occurance_name );

    for( j = 1 ; j < (*nbAttr) ; j++ )
    {
      sprintf( (*Attr)[j].name, "occurance_%d", j );
      (*Attr)[j].desc.type = AC_ATTRIB_TEXT;

      status = VDtblRowExecPplName( msg, &gridList[rows[ind].startIndex+j-1],
			&rows[ind].rowId, "VDrow_info", "name",
			(*Attr)[j].desc.value.att_txt );
      if( !(status&1&(*msg)) )
      {
        strcpy( (*Attr)[j].desc.value.att_txt, "unknown" );
      }
    }

    status = OM_S_SUCCESS;
    *msg   = OM_S_SUCCESS;


wrapup:

    End
    return status;
} /* VDdrw_getTableRowAttr */

/*+fe
 -------------------------------------------------------------------------
  Function VDdrw_addObjectsToTable

  Abstract
        Function adds given objects into the existing table

  Arguments

        IGRlong         *msg            O       return code
	struct GRid	*tblId		I	table ID
        IGRint		*count          I	No. of objects added
	struct GRid	*objectList	I	object list added

  Returns
        OM_S_SUCCESS    = if success
        OM_E_ABORT      = if error
 ------------------------------------------------------------------------- -fe*/
IGRlong VDdrw_addObjectsToTable( IGRlong	 *msg,
			         struct GRid     *tblId,
				 struct PrcInfo  *newList,
				 IGRint		 newCnt,
				 struct VDtblStImInfo	*tblInfo )
{
    IGRint		  i, j;
    IGRlong		  status;
    IGRint		  nbRows,
			  nbHdrs,
			  syntaxerror,
			  curCnt,
			  hdrInd,
			  nbNewObjs,
			  objInd,
		  	  mode,
			  nbAttr;
    struct GRid		  *gridList,
			  setId,
			  *hdrId;
    struct VDdrw_rowInfo  *rows;
    OMuword               os;
    IGRchar		  layoutName[VD_DRWLO_CHR_IDFLD],
                          tblTypeName[VD_DRWLO_CHR_IDFLD];
    struct VDdrwlo_tab    tblRec;
    IGRshort		  tblType,
			  nbDatRecs,
			  trlType = VD_DRWLO_EN_BRKTRLR,
			  cnstType = VD_DRW_CNST_TRLR,
			  prop ;
    struct VDdrwlo_data   *datRecs;
    IGRdouble		  height;
    struct PrcInfo        *curList;
    VD_execRes            expVal;
    struct GRobj_env	  *locObject;
    struct ACrg_coll      *Attr;
    IGRchar               occurance_name[240], pcmk[128];
    IGRchar               szmsg[200];
    IGRint		  itemNoOpt = 0, startNo = -1;
    IGRchar		  itemNo[40];


    SetProc( VDdrw_addObjectsToTable ); Begin

    *msg      = MSSUCC;
    status    = 0;
    curCnt    = 0;
    curList   = NULL;
    hdrId     = NULL;
    datRecs   = NULL;
    rows      = NULL;
    Attr      = NULL;
    locObject = NULL;
    gridList  = NULL;

    if( tblId == NULL ) goto wrapup;
    if( newList == NULL || newCnt == 0 ) 
    {
      printf("object list input is empty!\n");
      goto wrapup;
    }

    /* 
    ** recompute the table
    */
    UI_status( "Creating table ..." );

    /*
    ** Get object list of the existing table
    */
    status = vd$tbl_getObjects( msg        = msg,
                                tblId      = tblId,
                                count      = &curCnt,
                                objectList = &curList );
    if( !(status&*msg&1) )
    {
	UTAD_INFO("vd$tbl_getObjects");
	goto wrapup;
    }

    /*
    ** Check if the table is  a new one. if not, goto wrapup.
    */
    if( curCnt > 0 ) 
    {
      printf("It is not a new table!\n");
      goto wrapup;
    }

    /*
    ** get number of table parts(headers)
    */
    nbHdrs = 0;
    status =
    om$send( msg      = message VDdrwTbl.VDgetTableParts(msg,
                                                         &nbHdrs,
                                                         NULL),
	     senderid = NULL_OBJID,
             targetid = tblId->objid,
             targetos = tblId->osnum );
    if( !(status&*msg&1) || (nbHdrs <= 0) )
    {
	UTAD_INFO("VDdrwTbl.VDgetTableParts");
	goto wrapup;
    }

    /*
    ** allocate memory for headers, copy and coordinate systems
    */
    hdrId = NULL;
    if( nbHdrs > 0 )
    {
      hdrId = _MALLOC( nbHdrs, struct GRid );
      if( hdrId == NULL ) goto wrapup;
    }
    else goto wrapup;

    status =
    om$send( msg      = message VDdrwTbl.VDgetTableParts(msg,
                                                         &nbHdrs,
                                                         hdrId),
             senderid = NULL_OBJID,
             targetid = tblId->objid,
             targetos = tblId->osnum );
    if( !(status&*msg&1) )
    {
	UTAD_INFO("VDdrwTbl.VDgetTableParts");
	goto wrapup;
    }

    status =
    om$send( msg      = message VDdrwTbl.VDgetTableLayoutName(msg,
                                                              layoutName),
             senderid = NULL_OBJID,
             targetid = tblId->objid,
             targetos = tblId->osnum );
    if( !(status&*msg&1) )
    {
	UTAD_INFO("VDdrwTbl.VDgetTableLayoutName");
	goto wrapup;
    }

    /*
    ** get the table record
    */
    status = VD_drwlo_gtab( msg, layoutName, &tblRec );
    if( !(status&*msg&1) )
    {
	UTAD_INFO("VD_drwlo_gtab");
	goto wrapup;
    }

    /*
    ** store the type of the table
    */
    strcpy( tblTypeName, tblRec.Tabtyp );

    if( !strcmp( tblTypeName, VD_DRW_BOM_TYPE_NAME ) ||
        strstr( tblTypeName, VD_DRW_BOMX_TYPE_NAME ) )
        tblType = VD_DRW_TBLTYPE_BOM;
    else
        tblType = VD_DRW_TBLTYPE_GEN;

    /*
    ** get the list of data records
    */
    status = VD_drwlo_gdata( msg,
                             layoutName,
                             VD_DRWLO_EN_DATA,
                             0,
			     0,
                             0,
			     NULL,
                             &height,
                             &nbDatRecs,
                             NULL );
    if( !(status&*msg&1) )
    {
	UTAD_INFO("VD_drwlo_gdata");
	goto wrapup;
    }

    __DBGpr_int( "Number of data records", nbDatRecs );

    if( nbDatRecs > 0 )
    {
      datRecs = _MALLOC( nbDatRecs, struct VDdrwlo_data );
      if( datRecs == NULL ) goto wrapup;
    }
    else nbDatRecs = 0;

    if( nbDatRecs > 0 )
    {
      status = VD_drwlo_gdata( msg,
                               layoutName,
                               VD_DRWLO_EN_DATA,
                               0,
			       0,
                               0,
			       NULL,
                               &height,
                               &nbDatRecs,
                               datRecs );
      if( !(status&*msg&1) )
      {
	UTAD_INFO("VD_drwlo_gdata");
	goto wrapup;
      }
    }

    /*
    ** validate the syntax of expressions if any
    */
    syntaxerror = 0;
    for( i = 0 ; i < nbDatRecs ; i++ )
    {
      if( datRecs[i].rectyp == VD_DRWLO_EN_EXPRESSION )
      {
        status = VD_expParse( datRecs[i].Text,
                              FALSE,
                              VD_EXP_WARNING,
                              0,
			      NULL,
                              &expVal );
        if( !(status&1) )
        {
          printf("Expression syntax error in column %d\n", datRecs[i].colno);
          syntaxerror = 1;
        }
      }
    }

    status = 0;
    if( syntaxerror )
    {
      status = GRconfirm_box(" There are expression syntax error, do you still want to update the table? ");

      if( !status )
      {
        status = VD_STATUS_ERROR;
        goto wrapup;
      }
      else
        status = VD_STATUS_OK;
    }

    /*
    ** retrieve the existing objects
    */
    locObject = _MALLOC( newCnt, struct GRobj_env );
    if( locObject == NULL ) goto wrapup;

    nbNewObjs = 0;
    for( i = 0 ; i < newCnt ; i++ )
    {
      if( newList[i].model.obj_id.objid != NULL_OBJID )
      {
        newList[i].model.mod_env._MD_OS = newList[i].model.obj_id.osnum;
        status = ex$get_modid(mod_osnum = newList[i].model.mod_env._MD_OS,
                              mod_id    = &newList[i].model.mod_env._MD_ID );
        locObject[nbNewObjs] = newList[i].model;
 	nbNewObjs++;
      }
    }

    newCnt = nbNewObjs;

    /*
    ** Allocate the table row objects
    */
    rows = _MALLOC( newCnt, struct VDdrw_rowInfo );
    if( rows == NULL ) goto wrapup;

    nbNewObjs = newCnt;
    objInd = newCnt - 1;

    /*
    ** initialize the entries
    */
    for( i = newCnt-1 ; nbNewObjs > 0 ; i--, nbNewObjs--, objInd-- )
    {
      rows[i].rowId.objid = NULL_OBJID;
      rows[i].nbObjs = 1;
      rows[i].startIndex = objInd;
      rows[i].qty.nSflag = VD_DRWLO_EN_COUNT;
      rows[i].qty.szExp[0] = '\0';
      rows[i].flag = VD_DRW_ROW_NEW;
    }

    nbRows = newCnt;

    /*
    ** summarization and sorting of the table rows
    */
    status = VDdrw_summ_and_sort_objs( msg,
				       &tblRec,
				       &newCnt,
                                       &nbRows,
                                       &newCnt,
                                       &rows,
				       locObject );
    if( !(status&*msg&1) )
    {
	UTAD_INFO("VDdrw_summ_and_sort_objs");
	goto wrapup;
    }

    /*
    ** get current osnum
    */
    ex$get_cur_mod( osnum = &os );

    /*
    ** make a GRid array using the PrcInfo array of total objects
    */
    if( newCnt > 0 )
    {
      gridList = _MALLOC( newCnt, struct GRid );
      if( !gridList )
      {
        *msg = VD_ERROR;
        goto wrapup;
      }

      for( i = 0 ; i < newCnt ; i++ )
      {
        gridList[i] = locObject[i].obj_id;
      }
    }

    prop = AChdr_nodisplay | AChdr_noprotect | AChdr_nocompute;
    /*
    ** construct row object if it is null
    */
    for( i = 0 ; i < nbRows ; i++ )
    {
        if( rows[i].rowId.objid != NULL_OBJID ) goto wrapup;

        /*
 	** must construct the row object
 	*/
        rows[i].rowId.osnum = os;

        status =
        om$construct( classid = OPP_VDdrwTblRow_class_id,
                      osnum   = rows[i].rowId.osnum,
                      p_objid = &rows[i].rowId.objid,
                      msg     = message VDdrwTblRow.VDinitTblRow(msg) );
    	CheckRC( status, 1 );

        __DBGpr_obj( "Table row id", rows[i].rowId );

        if( rows[i].rowId.objid == NULL_OBJID )
        {
          *msg = VD_ERROR;
          goto wrapup;
        }

        /*
        ** Construct and initialize the parent set objects if needed.
        ** Initialize the templates
        */

        if( rows[i].nbObjs > 0 )
        {
          /*
	  ** must construct the set object
	  */
          setId.osnum = os;
          setId.objid = NULL_OBJID;

          status =
          om$construct( classid = OPP_VDdrwSet_class_id,
                        osnum   = setId.osnum,
                        p_objid = &setId.objid,
                        msg     = message VDdrwSet.VDinitSet( msg ) );
	  CheckRC( status, 1 );

          if( setId.objid == NULL_OBJID )
          {
            *msg = VD_ERROR;
            goto wrapup;
          }

          __DBGpr_obj( "Constructed set id", setId );

          /*
	  ** add the row objects to the set
 	  */
          status =
	  om$send( msg      = message VDdrwSet.VDaddObjectsToSet(
                                        msg,
                                        rows[i].nbObjs,
                                        &gridList[rows[i].startIndex]),
		   senderid = NULL_OBJID,
                   targetid = setId.objid,
                   targetos = setId.osnum );
	  if( !(status&*msg&1) )
	  {
		UTAD_INFO("VDdrwSet.VDaddObjectsToSet");
		goto wrapup;
	  }

 	  nbAttr = rows[i].nbObjs + 1;
          Attr = _MALLOC( nbAttr, struct ACrg_coll );
          if( Attr )
          {
            strcpy( Attr[0].name, "occurance_count" );
            Attr[0].desc.type = AC_ATTRIB_TEXT;
            occurance_name[0] = '\0';
            sprintf( occurance_name, "%d", rows[i].nbObjs );
            strcpy( Attr[0].desc.value.att_txt, occurance_name );

            for( j = 1 ; j < nbAttr ; j++ )
            {
              sprintf( Attr[j].name, "occurance_%d", j );
              Attr[j].desc.type = AC_ATTRIB_TEXT;

              status = VDtblRowExecPplName( msg, 
			&gridList[rows[i].startIndex+j-1],
			&rows[i].rowId,
                        "VDrow_info", "name", Attr[j].desc.value.att_txt );
              if( !(status&1&(*msg)) )
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

          /*
	  ** initialize row object with the templates
	  */
          status =
	  om$send( msg      = message VDdrwTblRow.VDcreate(
                                                        msg,
                                                        nbAttr,
                                                        Attr,
                                                        "VDdrwTblRow",
                                                        prop,
                                                        1,
                                                        &setId),
		   senderid = NULL_OBJID,
                   targetid = rows[i].rowId.objid,
             	   targetos = rows[i].rowId.osnum );
          if( !(status&*msg&1) )
	  {
		UTAD_INFO("VDdrwTblRow.VDcreate");
		goto wrapup;
	  }

          _FREE( Attr );
          Attr = NULL;
        }
        else
        {
          /*
	  ** initialize row object with just the rg-collector
	  */
	  status =
          om$send( msg      = message VDdrwTblRow.VDcreate(
                                                        msg,
                                                        0,
                                                        NULL,
                                                        "VDdrwTblRow",
                                                        prop,
                                                        0,
                                                        &setId),
                   senderid = NULL_OBJID,
                   targetid = rows[i].rowId.objid,
                   targetos = rows[i].rowId.osnum );
          if( !(status&*msg&1) )
	  {
		UTAD_INFO("VDdrwTblRow.VDcreate");
		goto wrapup;
	  }

          /*
	  ** set user defined row flag
	  */
          status =
	  om$send( msg      = message VDdrwTblRow.VDputUserDefRowFlag
                                                        (msg, 1),
    	  	   senderid = NULL_OBJID,
                   targetid = rows[i].rowId.objid,
                   targetos = rows[i].rowId.osnum );
	  CheckRC( status, *msg );
        }

    }

    /*
    ** generate item number for each row if applicable
    */
    if( tblInfo->itemNoOpt ) 
    {
	for( i = 0; i < nbRows; i++ ) 
	{
	   sprintf(itemNo, "%d", (i+tblInfo->startItemNo) );

	   status =
           om$send( msg      = message VDdrwTblRow.VDputItemNumber(
                                                        msg, 
							itemNo),
		    senderid = NULL_OBJID,
		    targetid = rows[i].rowId.objid,
		    targetos = rows[i].rowId.osnum );
	}
    }

    /*
    ** construct/compute/move each row object
    */
    UI_status("Constructing Table Rows...");
    hdrInd = 0;
    for( i = 0 ; i < nbRows ; i++ )
    {
        if( rows[i].flag != VD_DRW_ROW_NEW ) continue;

        percent = 100*(1+i)/nbRows;
        if( !(percent%10) ) {
          sprintf( szmsg, "Constructing Table Rows %d%s", percent, "%" );
          UI_status( szmsg );
        }

        /*
  	** set up the qty computation structure
 	*/
        status =
        om$send( msg      = message VDdrwTblRow.VDputQtyExpr(msg,
                                                             rows[i].qty),
                 senderid = NULL_OBJID,
                 targetid = rows[i].rowId.objid,
                 targetos = rows[i].rowId.osnum );
	CheckRC( status, *msg );

        /*
        ** construct the row
        */
        status =
        om$send( msg      = message VDdrwTblHdr.VDaddAndConstructRows(
                                                        msg,
                                                        1,
                                                        &rows[i].rowId),
                 senderid = NULL_OBJID,
                 targetid = hdrId[hdrInd].objid,
                 targetos = hdrId[hdrInd].osnum );
        if( !(status&*msg&1) )
	{
	    UTAD_INFO("VDdrwTblHdr.VDaddAndConstructRows");
	    goto wrapup;
	}
    }

    UI_status( "End of Contructing Table Row..." );

    /*
    ** reconstruct the trailers 
    */
    for( i = 0 ; i < nbHdrs ; i++ )
    {
      /* 
      ** the last one is a trailer 
      */
      if( i == nbHdrs-1 )
            trlType = VD_DRWLO_EN_TRAILER;

      status =
      om$send( msg      = message VDdrwTblHdr.VDputConstructInfo(msg,
                                                                 NULL,
                                                                 &trlType,
                                                                 &cnstType),
       	       senderid = NULL_OBJID,
               targetid = hdrId[i].objid,
               targetos = hdrId[i].osnum );
      if( !(status&*msg&1) )
      {
	UTAD_INFO("VDdrwTblHdr.VDputConstructInfo");
	goto wrapup;
      }

      status =
      om$send( msg      = message VDdrwTblHdr.VDconstructHdrTrl(msg),
 	       senderid = NULL_OBJID,
               targetid = hdrId[i].objid,
               targetos = hdrId[i].osnum );
      if( !(status&*msg&1) )
      {
	UTAD_INFO("VDdrwTblHdr.VDconstructHdrTrl");
	goto wrapup;
      }
    }

    status = OM_S_SUCCESS;
    *msg   = OM_S_SUCCESS;
    UI_status( "Done..." );


wrapup:
    VD_drwlo_iclose( msg );
    VD_crsrt_iclose( msg );
    VD_crsum_iclose( msg );
    VD_adsym_iclose( msg );

    _FREE( rows );
    _FREE( curList );
    _FREE( locObject );
    _FREE( hdrId );
    _FREE( Attr );
    _FREE( datRecs );
    _FREE( gridList );

    End
    return status;
} /* VDdrw_addObjectsToTable */

/*+fe
 -------------------------------------------------------------------------
  Function VDdrw_getTableHeaderAttr

  Abstract
        Function retrieves attributes from the existing table header

  Arguments

        IGRlong          *msg            O      return code
	struct GRid	 *tblId		 I	table ID
	IGRchar		 *attrName	 I      specified attribute's name.
						optional.
        IGRint		 *attrCnt        O	No. of attributes
	struct ACrg_coll **attrList	 O	attribute list
	struct GRid	 *nodeIds	 O	node IDs
	IGRint		 *nodeCnt	 O	node count

  Returns
        OM_S_SUCCESS    = if success
        OM_E_ABORT      = if error
 ------------------------------------------------------------------------- -fe*/
IGRlong VDdrw_getTableHeaderAttr( IGRlong	   *msg,
			          struct GRid      *tblId,
				  IGRchar	   *attrName,
				  IGRint	   *attrCnt,
			          struct ACrg_coll **attrList,
				  IGRint	   *nodeCnt,
				  struct GRid	   **nodeIds )
{
    IGRint		 i, cnt = 0;
    IGRlong		 status;
    IGRint		 nbHdrs,
			 sizeAttr,
			 nbParents;
    struct GRid		 *hdrIds = NULL,
			 *parentIds = NULL, footId;
    IGRmatrix            mat;
    IGRshort	         matType;


    SetProc( VDdrw_getTableHeaderAttr ); Begin


    *msg     = MSSUCC;
    status   = 0;
    hdrIds   = NULL;
    if( nodeIds ) *nodeIds = NULL;
    if( attrCnt ) *attrCnt = 0;
    if( attrList ) {
	if( *attrList ) _FREE( *attrList );
    }

    if( tblId == NULL ) goto wrapup;

    /*
    ** get number of table headers
    */
    nbHdrs = 0;
    status =
    om$send( msg      = message VDdrwTbl.VDgetTableParts(msg,
                                                         &nbHdrs,
                                                         NULL),
	     senderid = NULL_OBJID,
             targetid = tblId->objid,
             targetos = tblId->osnum );

    if( !(status&*msg&1) || (nbHdrs <= 0) )
    { 
	UTAD_INFO("VDdrwTbl.VDgetTableParts");
	goto wrapup;
    }

    hdrIds = _MALLOC( nbHdrs, struct GRid );
    if( hdrIds == NULL ) goto wrapup;

    status =
    om$send( msg      = message VDdrwTbl.VDgetTableParts(msg,
                                                         &nbHdrs,
                                                         hdrIds),
             senderid = NULL_OBJID,
    	     targetid = tblId->objid,        
             targetos = tblId->osnum );
    if( !(status&*msg&1) )
    {
	UTAD_INFO("VDdrwTbl.VDgetTableParts");
	goto wrapup;
    }

    /*
    ** retrieve all the parents of table header
    */
    nbParents = 0;
    status =
    om$send( msg      = message NDnode.NDget_objects(ND_ROOT,
                                                     NULL,
                                                     0,
                                                     NULL,
                                                     0,
                                                     OM_K_MAXINT,
                                                     &nbParents),
             senderid = NULL_OBJID,
             targetid = hdrIds[0].objid,
             targetos = hdrIds[0].osnum );
    if( !(status&*msg&1) )
    {
	UTAD_INFO("NDnode.NDget_objects");
	goto wrapup;
    }
    __CheckRC( status, 1, "NDnode.NDget_objects", wrapup );

    if( nbParents < 1 ) goto wrapup;

    parentIds = _MALLOC( nbParents, struct GRid );
    if( !parentIds )
        {
            printf( "Error in dynamic allocation\n" );
            status = OM_E_NODYNMEM;
            goto wrapup;
    }

    status =
    om$send( msg      = message NDnode.NDget_objects(ND_ROOT,
                                                     parentIds,
                                                     nbParents,
                                                     NULL,
                                                     0,
                                                     OM_K_MAXINT,
                                                     &nbParents),
             senderid = NULL_OBJID,
             targetid = hdrIds[0].objid,
             targetos = hdrIds[0].osnum );
    __CheckRC( status, 1, "NDnode.NDget_objects", wrapup );


    /* 
     * get nodeIds if applied
     */
    if( nodeIds ) 
    {
	if( (nbParents-2) < 1 ) 
	{
	    *nodeCnt = 0;
	    *nodeIds = NULL;
	    goto wrapup;
	}

	*nodeIds = _MALLOC( (nbParents-2), struct GRid );

	if( !(*nodeIds) )
        {
            printf( "Error in dynamic allocation\n" );
            status = OM_E_NODYNMEM;
            goto wrapup;
	}

	cnt = 0;
	for( i = 0; i < (nbParents-2); i++ )
	{
	   status =
	   om$send( msg      = message NDmacro.ACreturn_foot(msg,
                                                          "",
                                                          &footId,
                                                          &matType,
                                                          mat),
                   senderid = NULL_OBJID,
                   targetid = parentIds[i+2].objid,
                   targetos = parentIds[i+2].osnum );

           if(status&*msg&1)
	   {
	      (*nodeIds)[cnt] = footId;
	      cnt++;
	   }
	}
	*nodeCnt = cnt;
    }

    if( !attrList && !attrCnt ) {
        status   = OM_S_SUCCESS;
        *msg     = OM_S_SUCCESS;
	goto wrapup;
    }

    /*
    ** retrieve attributes
    */
    status =
    om$send( msg      = message ACrg_collect.AClist_attribute(msg,
                                                              0,
                                                              NULL,
                                                              &sizeAttr),
             senderid = NULL_OBJID,
             targetid = parentIds[0].objid,
             targetos = parentIds[0].osnum );
    if( !(status&*msg&1) || (sizeAttr < 1) )
    {
	UTAD_INFO("ACrg_collect.AClist_attribute");
	goto wrapup;
    }

    if( attrCnt ) *attrCnt = sizeAttr;


    if( attrList == NULL ) 
    {
      status = OM_S_SUCCESS;
      goto wrapup;
    }

    if( !((*attrList) = _MALLOC(*attrCnt, struct ACrg_coll)) ) goto wrapup;

    status =
    om$send( msg      = message ACrg_collect.AClist_attribute(msg,
                                                              sizeAttr,
                                                              (*attrList),
                                                              &sizeAttr),
             senderid = NULL_OBJID,
             targetid = parentIds[0].objid,
             targetos = parentIds[0].osnum );
    if( !(status&*msg&1) )
    {
	UTAD_INFO("ACrg_collect.AClist_attribute");
	goto wrapup;
    }

    if( attrName != NULL )
    {
      for( i = 0 ; i < sizeAttr ; i++ )
      {
        if( !(strcmp((*attrList)[i].name, attrName)) )
        {
	  memcpy( (char *) &((*attrList)[0]), 
		  (char *) &((*attrList)[i]),
		  sizeof(struct ACrg_coll) );
          break;
        }
      }

      if( i == sizeAttr ) 
      {
        if( attrCnt ) *attrCnt = 0;
        status   = OM_S_SUCCESS;
        *msg     = OM_S_SUCCESS;
        goto wrapup;
      }

      if( !((*attrList) = _REALLOC( (*attrList), 1, struct ACrg_coll)) ) 
	goto wrapup;

      if( attrCnt ) *attrCnt = 1;
    }

    status = OM_S_SUCCESS;
    *msg   = OM_S_SUCCESS;


wrapup:
    _FREE( hdrIds );
    _FREE( parentIds );

    End
    return status;
} /* VDdrw_getTableHeaderAttr */

/*+fe
 -------------------------------------------------------------------------
  Function VDdrw_setTableHeaderAttr

  Abstract
        Function sets attributes in the existing table header

  Arguments

        IGRlong          *msg            O      return code
	struct GRid	 *tblId		 I	table ID
        IGRint		 attrCnt         I	No. of attributes
	struct ACrg_coll *attrList	 I	attribute list

  Returns
        OM_S_SUCCESS    = if success
        OM_E_ABORT      = if error
 ------------------------------------------------------------------------- -fe*/
IGRlong VDdrw_setTableHeaderAttr( IGRlong	   *msg,
			          struct GRid      *tblId,
				  IGRint	   attrCnt,
			          struct ACrg_coll *attrList )
{
    IGRint		 i, j;
    IGRlong		 status;
    IGRint		 nbHdrs,
			 sizeAttr,
			 newAttrCnt,
			 nbAttr,
			 nbParents;
    struct GRid		 *hdrIds,
			 parentIds[3];
    struct ACrg_coll	 *attr_tmp,
			 *newAttr;


    SetProc( VDdrw_setTableHeaderAttr ); Begin


    *msg     = MSSUCC;
    status   = 0;
    nbAttr   = 0;
    hdrIds   = NULL;
    attr_tmp = NULL;
    newAttr  = NULL;

    if( tblId == NULL || attrCnt == 0 || attrList == NULL ) goto wrapup;

    /*
    ** get number of table headers
    */
    nbHdrs = 0;
    status =
    om$send( msg      = message VDdrwTbl.VDgetTableParts(msg,
                                                         &nbHdrs,
                                                         NULL),
	     senderid = NULL_OBJID,
             targetid = tblId->objid,
             targetos = tblId->osnum );
    if( !(status&*msg&1) || (nbHdrs <= 0) )
    {
	UTAD_INFO("VDdrwTbl.VDgetTableParts");
	goto wrapup;
    }

    hdrIds = _MALLOC( nbHdrs, struct GRid );
    if( hdrIds == NULL ) goto wrapup;

    status =
    om$send( msg      = message VDdrwTbl.VDgetTableParts(msg,
                                                         &nbHdrs,
                                                         hdrIds),
             senderid = NULL_OBJID,
    	     targetid = tblId->objid,        
             targetos = tblId->osnum );
    if( !(status&*msg&1) ) goto wrapup;

    /*
    ** retrieve all the parents of table header
    */
    status =
    om$send( msg      = message NDnode.NDget_objects(ND_ROOT,
                                                     parentIds,
                                                     3,
                                                     NULL,
                                                     0,
                                                     OM_K_MAXINT,
                                                     &nbParents),
             senderid = NULL_OBJID,
             targetid = hdrIds[0].objid,
             targetos = hdrIds[0].osnum );
    __CheckRC( status, 1, "NDnode.NDget_objects", wrapup );

    if( nbParents == 0 ) goto wrapup;

    /*
    ** retrieve attributes
    */
    status =
    om$send( msg      = message ACrg_collect.AClist_attribute(msg,
                                                              0,
                                                              NULL,
                                                              &nbAttr),
             senderid = NULL_OBJID,
             targetid = parentIds[0].objid,
             targetos = parentIds[0].osnum );
    if( !(status&*msg&1) )
    {
	UTAD_INFO("ACrg_collect.AClist_attribute");
	goto wrapup;
    }

    if( nbAttr > 0 )
    {
      if( !(attr_tmp = _MALLOC(nbAttr, struct ACrg_coll)) ) goto wrapup;

      sizeAttr = nbAttr;
      status =
      om$send( msg      = message ACrg_collect.AClist_attribute(msg,
                                                                sizeAttr,
                                                                attr_tmp,
                                                                &nbAttr),
               senderid = NULL_OBJID,
               targetid = parentIds[0].objid,
               targetos = parentIds[0].osnum );
      if( !(status&*msg&1) )
      {
	UTAD_INFO("ACrg_collect.AClist_attribute");
	goto wrapup;
      }

      if( !(newAttr = _MALLOC(nbAttr+attrCnt, struct ACrg_coll)) ) goto wrapup;

      for( i = 0 ; i < nbAttr ; i++ ) 
      {
        memcpy( (char *)&(newAttr[i]), 
		(char *)&(attr_tmp[i]), 
		sizeof(struct ACrg_coll) );
      }

      newAttrCnt = nbAttr;
      for( j = 0 ; j < attrCnt ; j++ )
      {
        for( i = 0 ; i < nbAttr ; i++ )
        {
  	  if( !(strcmp(attrList[j].name, attr_tmp[i].name)) )
  	  {
            memcpy( (char *)&(newAttr[i]), 
		    (char *)&(attrList[j]), 
		    sizeof(struct ACrg_coll) );
	    break;
	  }
	}

 	if( i == nbAttr )
	{
          memcpy( (char *)&(newAttr[newAttrCnt]), 
		  (char *)&(attrList[j]), 
		  sizeof(struct ACrg_coll) );
	  newAttrCnt++;
	}
      }
    }
    else
    {
      if( !(newAttr = _MALLOC(attrCnt, struct ACrg_coll)) ) goto wrapup;

      for( i = 0 ; i < attrCnt ; i++ ) newAttr[i] = attrList[i];
      {
	memcpy( (char *)&(newAttr[i]),
                (char *)&(attrList[i]),
                sizeof(struct ACrg_coll) );
      }

      newAttrCnt = attrCnt;
    }

    /*
    ** set new attribute list
    */
    status =
    om$send( msg      = message ACrg_collect.ACset_list_attribute(msg,
								  newAttrCnt,
                                                                  newAttr),
             senderid = NULL_OBJID,
             targetid = parentIds[0].objid,
             targetos = parentIds[0].osnum );
    if( !(status&*msg&1) )
    {
	UTAD_INFO("ACrg_collect.ACset_list_attribute");
	goto wrapup;
    }

    status = OM_S_SUCCESS;
    *msg   = OM_S_SUCCESS;


wrapup:
    _FREE( hdrIds );
    _FREE( newAttr );
    _FREE( attr_tmp );

    End
    return status;
} /* VDdrw_setTableHeaderAttr */

/*+fe
 -------------------------------------------------------------------------
  Function VDcheckPieceMarkChange

  Abstract
	 Function checks whether the piece mark was changed for a object 

  Returns
        OM_S_SUCCESS    = if success
        OM_E_ABORT      = if error
 ------------------------------------------------------------------------- -fe*/
IGRlong VDcheckPieceMarkChange( IGRlong	    *msg,
			        struct GRid newObj,
			        struct GRid tblRow,
			  	int 	    *isModified ) 
{
  IGRint           i,
		   nbObjs;
  IGRlong          status;
  struct GRid	   collId;
  struct GRobj_env *objList;
  IGRchar	   newPcmk[128], oldPcmk[128], *syntax;
  struct ACrg_coll Attr;


  SetProc( VDcheckPieceMarkChange ); Begin

  *msg       = MSSUCC;
  status     = 0;
  nbObjs     = 0;
  objList    = NULL;
  newPcmk[0] = '\0';
  oldPcmk[0] = '\0';

  if( newObj.objid == NULL_OBJID || 
      tblRow.objid == NULL_OBJID ||
      isModified   == NULL ) goto wrapup;

  __DBGpr_obj( "new object: ", newObj );
  __DBGpr_obj( "table row object: ", tblRow );

  /*
  ** Get piece mark no. for new object.
  */
  vdsa$GetStruct( objID   = &newObj,
                  name    = "SA_AST:StagingTree:0:pcmk",
                  txt     = newPcmk );

  __DBGpr_str( "piece mark no. of new object: ", newPcmk );

  /*
  ** get all objects in a table row.
  */
  status =
  om$send( msg      = message VDdrwTblRow.VDgetParentObjectList(
                                                msg,
                                                &nbObjs,
                                                NULL),
           senderid = NULL_OBJID,
           targetid = tblRow.objid,
           targetos = tblRow.osnum );
  if( !(status&*msg&1) )
  {
	UTAD_INFO("VDdrwTblRow.VDgetParentObjectList");
	goto wrapup;
  }

  __DBGpr_int( "no. of objects in a row: ", nbObjs );

  if( nbObjs <= 0 ) 
  {
    status = 1;
    *msg   = 1;
    *isModified = 0;
    goto wrapup;
  }

  objList = _MALLOC( nbObjs, struct GRobj_env );
  if( !objList ) goto wrapup;

  status =
  om$send( msg      = message VDdrwTblRow.VDgetParentObjectList(
                                                msg,
                                                &nbObjs,
                                                objList),
           senderid = NULL_OBJID,
           targetid = tblRow.objid,
           targetos = tblRow.osnum );
  if( !(status&*msg&1) )
  {
	UTAD_INFO("VDdrwTblRow.VDgetParentObjectList");
	goto wrapup;
  }

  for( i = 0 ; i < nbObjs ; i++ )
  {
    if( IF_EQ_GRID( objList[i].obj_id, newObj ) )
    {
      /*
      ** find collector object
      */
      status =
      om$send( msg      = message ACcpx.ACfind_temp_obj((int *)msg,
                                                        "coll",
                                                        &collId),
                   senderid = NULL_OBJID,
                   targetid = tblRow.objid,
                   targetos = tblRow.osnum );
      if( !(status&*msg&1) )
      {
	UTAD_INFO("ACcpx.ACfind_temp_obj");
	goto wrapup;
      }

      __DBGpr_obj( "collId: ", collId );

      /*
      ** find attribute
      */
      Attr.name[0] = '\0';
      sprintf( Attr.name, "occurance_%d", i+1 );
      status =
      om$send( msg      = message ACrg_collect.ACget_named_attribute(
                                                msg,
                                                &Attr),
               senderid = NULL_OBJID,
               targetid = collId.objid,
               targetos = collId.osnum );
      if( !(status&*msg&1) || 
          Attr.desc.type != AC_ATTRIB_TEXT )
      {
        status = 1;
        *msg   = 1;
        *isModified = 0;
        goto wrapup;
      }
    
      status = VDtblRowExecPplCheck( msg, &newObj, &tblRow, "VDrow_info", 
			     "check", Attr.desc.value.att_txt, isModified );
      if( !(status&1&(*msg)) )
      {
        status = 1;
        *msg   = 1;
        *isModified = 0;
        goto wrapup;
      }

      break;
    }
  }

  status = OM_S_SUCCESS;
  *msg   = OM_S_SUCCESS;


wrapup:

  _FREE( objList );
  End
  return status;
} /* VDcheckPieceMarkChange */

/*+fe
 -------------------------------------------------------------------------
  Function VDgetModelNameFromTblDrwSet

  Abstract
	 Function retrieves all objects from a table row drwset

  Returns
        OM_S_SUCCESS    = if success
        OM_E_ABORT      = if error
 ------------------------------------------------------------------------- -fe*/
IGRlong VDgetModelNameFromTblRow( IGRlong	   *msg,
			          struct GRid      *rowId,
			  	  int 		   *nbObjs,
			  	  GRname 	   **modelName ) 
{
  IGRint           i,
		   nbParents,
		   nbAttr,
		   nbOcc,
		   sizeAttr;
  IGRlong          status;
  struct GRid	   parentIds[3];
  struct ACrg_coll *attr_list;


  SetProc( VDgetModelNameFromTblRow ); Begin

  *msg      = MSSUCC;
  status    = 0;
  nbParents = 0;
  nbOcc     = 0;
  nbAttr    = 0;
  attr_list = NULL;

  if( !(rowId) || !(nbObjs) ) goto wrapup;

  /*
  ** retrieve all the parents of table row
  */
  status =
  om$send( msg      = message NDnode.NDget_objects(ND_ROOT,
                                                   parentIds,
                                                   3,
                                                   NULL,
                                                   0,
                                                   OM_K_MAXINT,
                                                   &nbParents),
           senderid = NULL_OBJID,
           targetid = rowId->objid,
           targetos = rowId->osnum );
  if( !(status&&1) || (nbParents<=0) )
  {
	UTAD_INFO("NDnode.NDget_objects");
	goto wrapup;
  }

  /*
  ** retrieve attributes
  */
  status =
  om$send( msg      = message ACrg_collect.AClist_attribute(msg,
                                                            0,
                                                            NULL,
                                                            &nbAttr),
           senderid = NULL_OBJID,
           targetid = parentIds[0].objid,
           targetos = parentIds[0].osnum );
  if( !(status&*msg&1) || (nbAttr<=1) )
  {
	UTAD_INFO("ACrg_collect.AClist_attribute");
	goto wrapup;
  }

  if( !(attr_list = _MALLOC(nbAttr, struct ACrg_coll)) ) goto wrapup;

  sizeAttr = nbAttr;
  status =
  om$send( msg      = message ACrg_collect.AClist_attribute(msg,
                                                            sizeAttr,
                                                            attr_list,
                                                            &nbAttr),
           senderid = NULL_OBJID,
           targetid = parentIds[0].objid,
           targetos = parentIds[0].osnum );
  if( !(status&*msg&1) || (nbAttr<=1) )
  {
	UTAD_INFO("ACrg_collect.AClist_attribute");
	goto wrapup;
  }

  nbOcc = atoi( attr_list[0].desc.value.att_txt );
  *nbObjs = nbOcc;

  if( !(modelName) )
  {
    status = OM_S_SUCCESS;
    goto wrapup;
  }
  
  if( nbOcc > 0 )
  {
    if( (*modelName) != NULL )
    {
      printf("(*modelName) must be NULL!\n");
    }
    *modelName = _MALLOC( nbOcc, GRname );
    if( *modelName == NULL ) goto wrapup;
  }

  for( i = 0 ; i < nbOcc ; i++ )
  {
    strcpy( (*modelName)[i], attr_list[i+1].desc.value.att_txt );
  }

  status = OM_S_SUCCESS;
  *msg   = OM_S_SUCCESS;


wrapup:

  _FREE( attr_list );
  End
  return status;
} /* VDgetModelNameFromTblRow */

/*+fe
 -------------------------------------------------------------------------
  Function VDtblProcCurList()

  Abstract
	 Function processes the current object list

  Returns
        OM_S_SUCCESS    = if success
        OM_E_ABORT      = if error
 -----------------------------------------------------------------------= -fe*/
IGRlong VDtblProcCurList( IGRlong	   *msg,
			  struct PrcInfo   *curList,
			  int 		   curCnt,
			  GRname 	   *modNames, 
			  struct GRobj_env *newList,
			  int 		   newCnt )
{
  IGRint           i, j, k;
  IGRlong          status, isConsumed = 0;
  struct GRobj_env childEnv; 
  GRname           *myModel;
  IGRboolean       nameFound ;
  IGRint           matchIndex = -1;
  IGRint	   nbmyModel, isModified;
  IGRchar	   *syntax, className[80];
  IGRchar	   szmsg[128];


  SetProc( VDtblProcCurList ); Begin

  *msg      = MSSUCC;
  status    = 0;
  myModel   = NULL;
  nbmyModel = 0;

  UI_status("Processing table objects...");
  for( i = 0 ; i < curCnt ; i++ )
  {
    percent = 100*(1+i)/curCnt;
    if( !(percent%10) ) {
       sprintf( szmsg, "Processing table objects %d%s", percent, "%" );
       UI_status( szmsg );
    }

    curList[i].application = TABLE;

    nameFound = 0;
    if( curList[i].model.obj_id.objid == NULL_OBJID )
    {
      curList[i].process = DELETE;
      curList[i].modelNew.obj_id.objid = NULL_OBJID;

      /*
      ** model object not found for table row (connect, delete)
      ** get the model object name and search in the objOS for that name
      */
      nbmyModel = 0;
      status = VDgetModelNameFromTblRow( msg,
					 &(curList[i].drwtbl.obj_id),
					 &nbmyModel,
					 &myModel );
      if( (!(status&1)) || (myModel == NULL) )
      {
	_FREE( myModel );
	myModel = NULL;
        continue;
      }

      for( k = 0 ; k < nbmyModel ; k++ )
      {
        syntax = NULL;
	syntax = strrchr( myModel[k], ':' );
        if( syntax )
 	{
	  syntax++;
	  strcpy( myModel[k], syntax );
	}

	syntax = NULL;
	syntax = strrchr( myModel[k], '-' );
 	if( syntax ) *syntax = '\0';

        syntax = NULL;
        for( j = 0 ; j < newCnt ; j++ )
        {
	  syntax = strrchr( modNames[j], ':' );
	  if( syntax )
          {
            syntax++;
            strcpy( modNames[j], syntax );
          }

          if( !strcmp(myModel[k], modNames[j]) )
          {
            nameFound = 1;
            matchIndex= j;
            break;
          }
        }

        if( nameFound ) break;
      }

      if( nameFound )
      {
        curList[i].process = CONNECT;
        curList[i].modelNew = newList[matchIndex];
      }

      _FREE( myModel );
      myModel = NULL;
    }
    else
    {
      childEnv.obj_id.objid = NULL_OBJID;

      /*
      ** model object found  for drawing(migrate, modified, unchanged,..)
      */
      status =om$send( msg      = message NDmacro.ACtest_consumed(&isConsumed),
                       senderid = NULL_OBJID,
                       targetid = curList[i].model.obj_id.objid,
                       targetos = curList[i].model.obj_id.osnum );

      if( !isConsumed )
      {
        isModified = 0;
        status = VDcheckPieceMarkChange( msg,
					 curList[i].model.obj_id,
					 curList[i].drwtbl.obj_id,
					 &isModified );
        if( isModified ) curList[i].process = MODIFY;
	else
          curList[i].process = UNCHANGED;
        curList[i].modelNew.obj_id.objid = NULL_OBJID;
      }
      else
      { 
        VDatGetConsumingChild( &curList[i].model, &childEnv );
        if(childEnv.obj_id.objid == NULL_OBJID)
	{
          curList[i].process = UNCHANGED;
          curList[i].modelNew.obj_id.objid = NULL_OBJID;
          continue;
        }

        className[0] = '\0';
        status = om$get_classname( objid = childEnv.obj_id.objid,
                                   osnum = childEnv.obj_id.osnum,
                                   classname = className );

        if( strcmp(className, "VSbooPlate") &&
            strcmp(className, "VSholPlate") &&
            strcmp(className, "VSsubPlate") &&
	    strcmp(className, "VSbooBeam" ) )
        {
          curList[i].process = UNCHANGED;
          curList[i].modelNew.obj_id.objid = NULL_OBJID;
	  curList[i].modelNew.obj_id.osnum = 2;
          continue;
        }

        curList[i].modelNew = childEnv;
        curList[i].process  = MIGRATE;
      }
    }

    /* 
     * For MIGRATE and CONNECT cases, 05-12-02, -yl-
     * Check if modelNew is already in model list
     * If found match, curList[i].process should be assigned DELETE
     */

    if( curList[i].process == MIGRATE || curList[i].process == CONNECT )
    {
	for( k = 0; k < curCnt; k++ )
	{
	    if(IF_EQ_GRID(curList[i].modelNew.obj_id, curList[k].model.obj_id))
	    {
		curList[i].process			= DELETE;
		curList[i].model.obj_id.objid		= NULL_OBJID;
		curList[i].modelNew.obj_id.objid	= NULL_OBJID;
	    }
	}
    }
  }

  UI_status( "Complete processing table objects" );

  status  = OM_S_SUCCESS;
  *msg    = OM_S_SUCCESS;


wrapup:
  _FREE( myModel );
  End
  return status;
} /* VDtblProcCurList */

/*+fe
 -------------------------------------------------------------------------
  Function VDdrw_reviewTable

  Abstract
        Function checks the new object list with the object list of an 
        existing table.  It also review all the objects and supply the 
	corespondent info. for each object.  It outputs the total list which 
 	contains all the objects from new list and existing list. The 
	function is interfaced by vd$review_table() macro.

  Arguments

        OUT     long                   *msg       Completion code.
        IN      const struct PrcInfo   *curList   existing list of objects
        IN      int                    curCnt
        IN      struct PrcInfo         *newList   list objects from node
        IN      int                    newCnt
        OUT     struct PrcInfo         **outList  old+updated new list
        OUT     int                    *outCnt

  Returns
        OM_S_SUCCESS    = if success
        OM_E_ABORT      = if error
 ------------------------------------------------------------------------- -fe*/
IGRlong VDdrw_reviewTable( IGRlong	    *msg,
			   struct PrcInfo   *curList, 
			   int 		    curCnt, 
			   struct GRobj_env *newList, 
			   int 		    newCnt, 
			   struct PrcInfo   **outList, 
			   int 		    *outCnt )
{
  IGRint           i, j,
		   ret, process = -1,
		   tmpCount = 0;
  IGRlong          status,
		   isConsumed = 0;
  IGRboolean       foundFlag = 0;
  GRname           *modNames = NULL; // names of the model objs in newList
  struct GRobj_env *tmpList = NULL;
  struct GRid      rowId;
  IGRchar	   path[128], *ptr = NULL;


  SetProc( VDdrw_reviewTable ); Begin

  if( (!curList) || (curCnt <= 0) || (!newList) || (newCnt <= 0) ) goto wrapup;

  *msg   = MSSUCC;
  status = 0;

  tmpList = _MALLOC( newCnt, struct GRobj_env );
  if( !tmpList ) goto wrapup;

  for( i = 0 ; i < newCnt ; i++ )
  {
    if( newList[i].obj_id.objid != NULL_OBJID )
    {
      tmpList[tmpCount] = newList[i];
      tmpCount++;
    } 
  }
 
  newCnt = tmpCount;

  tmpCount = 0;

  modNames = _MALLOC( newCnt, GRname );
  if( !modNames ) goto wrapup;

  rowId.objid = NULL_OBJID;
  for( i = 0 ; i < newCnt ; i++ )
  {

    modNames[i][0] = '\0';
    /*
    ret = vdobj$Get( objID = &tmpList[i].obj_id, objPath = path );
    ptr = strstr(path, ":ref:");
    if( ptr != NULL )	ptr = ptr + 5;
    else		ptr = path;
    strcpy(modNames[i], ptr);
    if( (!(ret&1)) || modNames[i][0] == '\0' )
      __DBGpr_obj( "failed VDgetOccName for",tmpList[i].obj_id );
    */
    status = VDtblRowExecPplName(	msg,
					&tmpList[i].obj_id,
					&rowId,
					"VDrow_info",
					"name",
					path);
    if( !(status&*msg&1) ) path[0] = '\0';
    strcpy(modNames[i], path);
  }

  if( (*outList) != NULL )
  {
    printf("(*outList) must be NULL!\n" );
    goto wrapup;
  }
  *outList = _MALLOC( (curCnt+newCnt), struct PrcInfo );
  for( i = 0 ; i < (curCnt+newCnt) ; i++ )
  {
    (*outList)[i].model.obj_id.objid    = NULL_OBJID;
    (*outList)[i].modelNew.obj_id.objid = NULL_OBJID;
    (*outList)[i].drwtbl.obj_id.objid   = NULL_OBJID;
    (*outList)[i].pretend.objid         = NULL_OBJID;
    (*outList)[i].VDdrwSet.objid 	= NULL_OBJID;
    (*outList)[i].application 		= TABLE;
    (*outList)[i].path[0]      	 	= '\0';
    (*outList)[i].pcmk[0]      	 	= '\0';
    (*outList)[i].type[0]      	 	= '\0';
    (*outList)[i].process		= -1;
  }

  /*
  ** process the curList and decide the state of the parent (processed, ...)
  */
  status = VDtblProcCurList( msg, 
			     curList,
			     curCnt,
			     modNames,
			     tmpList,
			     newCnt );
  if( !(status&1) )
  {
	UTAD_INFO("VDtblProcCurList");
	goto wrapup;
  }

  /*
  ** start comparing each model obj in tmpList with all those in the current
  ** list and fill the output list accordingly
  */
  for( j = 0 ; j < newCnt ; j++ )
  {
    foundFlag = 0;

    /*
    ** check if the new list object is not in the current list
    */
    for( i = 0 ; i < curCnt ; i++ )
    {
      if( IF_EQ_GRID( tmpList[j].obj_id, curList[i].model.obj_id ) ||
          IF_EQ_GRID( tmpList[j].obj_id, curList[i].modelNew.obj_id) )
      {
        foundFlag =1;
        break;
      }
    }

    if( !foundFlag )
    {
      (*outList)[tmpCount].model 	 	 = tmpList[j];
      (*outList)[tmpCount].process      	 = NEW_MODEL;
      (*outList)[tmpCount].modelNew.obj_id.objid = NULL_OBJID;
      (*outList)[tmpCount].drwtbl.obj_id.objid   = NULL_OBJID;
      (*outList)[tmpCount].pretend.objid         = NULL_OBJID;
      (*outList)[tmpCount].VDdrwSet.objid 	 = NULL_OBJID;
      (*outList)[tmpCount].application 		 = TABLE;
      (*outList)[tmpCount].path[0]      	 = '\0';
      (*outList)[tmpCount].pcmk[0]      	 = '\0';
      (*outList)[tmpCount].type[0]      	 = '\0';
      tmpCount++;
      continue;
    }

    foundFlag = 0;

    for( i = 0 ; i < curCnt ; i++ )
    {
      switch( curList[i].process )
      {
        case CONNECT :
        case MIGRATE :
          if( IF_EQ_GRID( tmpList[j].obj_id, curList[i].modelNew.obj_id ) )
          {
	     memcpy(	(char *) &(*outList)[tmpCount],
			(char *) &curList[i],
			sizeof( struct PrcInfo ) ) ;

             tmpCount++;
             foundFlag = 1;
          }

          break;

        case MODIFY :
        case UNCHANGED :
          if( IF_EQ_GRID( tmpList[j].obj_id, curList[i].model.obj_id ) )
          {
	     memcpy(	(char *) &(*outList)[tmpCount],
			(char *) &curList[i],
			sizeof( struct PrcInfo ) ) ;

            tmpCount++;
            foundFlag = 1;
          }

          break;
      }

      if( foundFlag ) break;
    }
  }

  /*
  ** fill the drawings to be deleted at the end
  */
  for( i = 0 ; i < curCnt ; i++ )
  {
    if( curList[i].process == DELETE )
    {
       memcpy(	(char *) &(*outList)[tmpCount], 
		(char *) &curList[i],
		sizeof( struct PrcInfo ) ) ;
      (*outList)[tmpCount].model.obj_id.objid    = NULL_OBJID;
      (*outList)[tmpCount].modelNew.obj_id.objid = NULL_OBJID;
      (*outList)[tmpCount].process 		 = DELETE;
      (*outList)[tmpCount].application 		 = TABLE;
      tmpCount ++;
    }
  }


  *outCnt = tmpCount;

  status = OM_S_SUCCESS;
  *msg   = OM_S_SUCCESS;


wrapup:
  _FREE( tmpList ); tmpList = NULL;
  _FREE(modNames); modNames= NULL;

  End
  return status;
} /* VDdrw_reviewTable */

/*+fe
 -------------------------------------------------------------------------
  Function VDdrw_checkTableRecords

  Abstract
        Function checks and returns all existing records in a table.

  Arguments

        IGRlong            *msg            O    return code
	struct GRid	   *tblId	   I	table ID
	struct VDdrwlo_tab *tblRec	   O	Table records

  Returns
        OM_S_SUCCESS    = if success
        OM_E_ABORT      = if error
 ------------------------------------------------------------------------- -fe*/
IGRlong VDdrw_checkTableRecords( IGRlong	    *msg,
			         struct GRid        *tblId,
				 struct VDdrwlo_tab *tblRec )
{
    IGRlong		  status;
    IGRint		  i, syntaxerror;
    IGRchar		  layoutName[VD_DRWLO_CHR_IDFLD];
    IGRshort		  nbFixRecs,
			  nbDatRecs;
    struct VDdrwlo_data   *datRecs;
    IGRdouble		  height;
    VD_execRes            expVal;


    SetProc( VDdrw_checkTableRecords ); Begin

    *msg       = MSSUCC;
    status     = 0;
    datRecs    = NULL;

    if( tblId == NULL || tblRec == NULL ) goto wrapup;
    __DBGpr_obj( "Table Id: ", *tblId );

    status =
    om$send( msg      = message VDdrwTbl.VDgetTableLayoutName(msg,
                                                              layoutName),
             senderid = NULL_OBJID,
             targetid = tblId->objid,
             targetos = tblId->osnum );
    if( !(status&*msg&1) )
    {
	UTAD_INFO("VDdrwTbl.VDgetTableLayoutName");
	goto wrapup;
    }
    __DBGpr_str( "Table layout name: ", layoutName );

    /*
    ** get the table record
    */
    status = VD_drwlo_gtab( msg, layoutName, tblRec );
    if( !(status&*msg&1) )
    {
	UTAD_INFO("VD_drwlo_gtab");
	goto wrapup;
    }
    __DBGpr_str( "Table type: ", tblRec->Tabtyp );

    /*
    ** get the list of data records
    */
    status = VD_drwlo_gdata( msg,
                             layoutName,
                             VD_DRWLO_EN_DATA,
                             0, 
			     0,
                             0, 
			     NULL,
                             &height,
                             &nbDatRecs,
                             NULL );
    if( !(status&*msg&1) )
    {
	UTAD_INFO("VD_drwlo_gdata");
	goto wrapup;
    }

    __DBGpr_int( "Number of data records: ", nbDatRecs );

    if( nbDatRecs > 0 )
    {
      datRecs = _MALLOC( nbDatRecs, struct VDdrwlo_data );
      if( datRecs == NULL ) goto wrapup;
    }
    else nbDatRecs = 0;

    if( nbDatRecs )
    {
      status = VD_drwlo_gdata( msg,
                               layoutName,
                               VD_DRWLO_EN_DATA,
                               0, 
			       0,
                               0, 
			       NULL,
                               &height,
                               &nbDatRecs,
                               datRecs );
      if( !(status&*msg&1) )
      {
	UTAD_INFO("VD_drwlo_gdata");
	goto wrapup;
      }
    }

    /*
    ** get the list of fixed records
    */
    status = VD_drwlo_gfix( msg,
                            layoutName,
                            VD_DRWLO_EN_DATA,
                            0, 0,
                            0, NULL,
                            &height,
                            &nbFixRecs,
                            NULL );
      if( !(status&*msg&1) )
      {
	UTAD_INFO("VD_drwlo_gdata");
	goto wrapup;
      }
    __DBGpr_int( "Number of fixed records", nbFixRecs );

    if( nbDatRecs == 0 && nbFixRecs == 0 ) 
    {
      printf("No any record in the table!\n");
      goto wrapup;
    }

    /*
    ** validate the syntax of expressions if any
    */
    syntaxerror = 0;
    for( i = 0 ; i < nbDatRecs ; i++ )
    {
      if( datRecs[i].rectyp == VD_DRWLO_EN_EXPRESSION )
      {
        status = VD_expParse( datRecs[i].Text,
                              FALSE,
                              VD_EXP_WARNING,
                              0,
			      NULL,
                              &expVal );
        if( !(status&1) )
        {
          printf("Expression syntax error in column %d\n", datRecs[i].colno);
          syntaxerror = 1;
        }
      }
    }

    status = 0;
    if( syntaxerror )
    {
      status = GRconfirm_box(" There are expression syntax error, do you still want to update the table? ");

      if( !status )
      {
        status = VD_STATUS_ERROR;
        goto wrapup;
      }
      else
        status = VD_STATUS_OK;
    }

    status = OM_S_SUCCESS;
    *msg   = OM_S_SUCCESS;

wrapup:
    _FREE( datRecs );

    End
    return status;
} /* VDdrw_checkTableRecords */

/*+fe
 -------------------------------------------------------------------------
  Function VDdrw_retrieveTableRowInfo

  Abstract
        Function retrieves all row info. in a table 

  Arguments

        IGRlong         *msg            O       return code
	struct GRid	*tblId		I	table ID
        IGRint		**lastRowNos    O	No. of last row in a table
        IGRint		**splitLocs     O	location of split table
        IGRint		*nbOldRows      O	no. of rows in the table
	struct VDdrw_rowInfo **oldRows	O	row list

  Returns
        OM_S_SUCCESS    = if success
        OM_E_ABORT      = if error
 ------------------------------------------------------------------------- -fe*/
IGRlong VDdrw_retrieveTableRowInfo( IGRlong	  	 *msg,
			            struct GRid    	 *tblId,
				    IGRint	   	 **lastRowNos,
				    IGRint	   	 **splitLocs,
				    IGRint	   	 *nbOldRows,
				    struct VDdrw_rowInfo **oldRows )
{
    IGRint		  i, j;
    IGRlong		  status;
    IGRint		  nbHdrs,
			  startRowNo,
			  nbHdrRows,
			  ind;
    struct GRid		  *hdrId;
    IGRshort		  isLinedOut;


    SetProc( VDdrw_retrieveTableRowInfo ); Begin

    *msg       = MSSUCC;
    status     = 0;
    startRowNo = 0;
    nbHdrRows  = 0;
    hdrId      = NULL;

    if( tblId      == NULL || 
	oldRows    == NULL || 
	lastRowNos == NULL || 
	splitLocs  == NULL || 
	nbOldRows  == NULL ) goto wrapup;

    /*
    ** get total number of old rows
    */
    *nbOldRows = 0;
    status =
    om$send( msg      = message VDdrwTbl.VDgetTotalNbOfRows(msg,
                                                            nbOldRows),
  	     senderid = NULL_OBJID,
             targetid = tblId->objid,
             targetos = tblId->osnum );
    if( !(status&*msg&1) || (*nbOldRows<=0) )
    {
	UTAD_INFO("VDdrwTbl.VDgetTotalNbOfRows");
	goto wrapup;
    }
    __DBGpr_int( "Total number of old rows: ", *nbOldRows );

    (*oldRows) = _MALLOC( (*nbOldRows)*2, struct VDdrw_rowInfo );
    if( (*oldRows) == NULL ) goto wrapup;

    /*
    ** get number of table parts(headers)
    */
    nbHdrs = 0;
    status =
    om$send( msg      = message VDdrwTbl.VDgetTableParts(msg,
                                                         &nbHdrs,
                                                         NULL),
             senderid = NULL_OBJID,
             targetid = tblId->objid,
             targetos = tblId->osnum );
    if( !(status&*msg&1) || (nbHdrs <= 0) )
    {
	UTAD_INFO("VDdrwTbl.VDgetTableParts");
	goto wrapup;
    }
    __DBGpr_int( "Total number of table headers: ", nbHdrs );

    /*
    ** allocate memory for headers
    */
    hdrId = _MALLOC( nbHdrs, struct GRid );
    if( hdrId == NULL ) goto wrapup;

    status =
    om$send( msg      = message VDdrwTbl.VDgetTableParts(msg,
                                                         &nbHdrs,
                                                         hdrId),
             senderid = NULL_OBJID,
             targetid = tblId->objid,
             targetos = tblId->osnum );
    if( !(status&*msg&1) )
    {
	UTAD_INFO("VDdrwTbl.VDgetTableParts");
	goto wrapup;
    }

    /*
    ** allocate space for split locations and last row no. 
    */
    (*splitLocs) = _MALLOC( nbHdrs, IGRint );
    if( !(*splitLocs) )
    {
      UI_status( "Error in dynamic allocation : command terminated" );
      goto wrapup;
    }
    (*lastRowNos) = _MALLOC( nbHdrs, IGRint );
    if( !(*lastRowNos) )
    {
      UI_status( "Error in dynamic allocation : command terminated" );
      goto wrapup;
    }

    ind = 0;
    for( i = 0 ; i < nbHdrs ; i++ )
    {
      /*
      ** get row information
      */
      status =
      om$send( msg      = message VDdrwTblHdr.VDgetRowInfo(msg,
                                                           &nbHdrRows,
                                                           &startRowNo),
               senderid = NULL_OBJID,
               targetid = hdrId[i].objid,
               targetos = hdrId[i].osnum );
      if( !(status&*msg&1) )
      {
	UTAD_INFO("VDdrwTblHdr.VDgetRowInfo");
	goto wrapup;
      }
      __DBGpr_int( "i: ", i );
      __DBGpr_int( "No of rows in header: ", nbHdrRows );
      __DBGpr_int( "StartRow number: ", startRowNo );

      /* 
      ** splitLocs stores the last row number in the corresponding header 
      */
      (*splitLocs)[i] = startRowNo + nbHdrRows - 1;
      (*lastRowNos)[i] = startRowNo + nbHdrRows - 1;

      /*
      ** for each row, get the rowId, number of model objects, and qty
      */
      for( j = startRowNo ; j < (startRowNo + nbHdrRows) ; j++ )
      {
        status =
        om$send( msg      = message VDdrwTblHdr.VDrowNoToGRid(
                                                msg,
                                                j,
                                                &(*oldRows)[ind].rowId),
	         senderid = NULL_OBJID,
                 targetid = hdrId[i].objid,
                 targetos = hdrId[i].osnum );
        if( !(status&*msg&1) )
	{
	    UTAD_INFO("VDdrwTblHdr.VDrowNoToGRid");
	    goto wrapup;
	}
        __DBGpr_obj( "row Id: ", (*oldRows)[ind].rowId );

        isLinedOut = 0;
        status =
        om$send( msg      = message VDdrwTblRow.VDisRowLinedOut(msg,
                                                                &isLinedOut),
                 senderid = NULL_OBJID,
                 targetid = (*oldRows)[ind].rowId.objid,
                 targetos = (*oldRows)[ind].rowId.osnum );
        CheckRC( status, *msg );

        if( isLinedOut ) (*oldRows)[ind].nbObjs = 0;
        else
        {
	  status =
          om$send( msg      = message VDdrwTblRow.VDgetParentObjectList(
						msg, 
						&(*oldRows)[ind].nbObjs,
						NULL),
		   senderid = NULL_OBJID,
                   targetid = (*oldRows)[ind].rowId.objid,
                   targetos = (*oldRows)[ind].rowId.osnum );
          __DBGpr_int( "No of objects in a row: ", (*oldRows)[ind].nbObjs );
        }

        status =
        om$send( msg      = message VDdrwTblRow.VDgetQtyExpr(
                                                msg, 
                                                &(*oldRows)[ind].qty),
                 senderid = NULL_OBJID,
                 targetid = (*oldRows)[ind].rowId.objid,
                 targetos = (*oldRows)[ind].rowId.osnum );
	if( !(status&*msg&1) )
	{
	   UTAD_INFO("VDdrwTblRow.VDgetQtyExpr");
	   goto wrapup;
	}

	ind++;
      }
    }

    *nbOldRows = ind;

    /* 
    ** initialize the old row entries 
    */
    (*oldRows)[0].startIndex = 0;
    (*oldRows)[0].flag = VD_DRW_ROW_OLD;

    for( i = 1 ; i < *nbOldRows ; i++ )
    {
      (*oldRows)[i].startIndex = 
        (*oldRows)[i-1].startIndex + (*oldRows)[i-1].nbObjs;
      (*oldRows)[i].flag = VD_DRW_ROW_OLD;
    }

    status = OM_S_SUCCESS;
    *msg   = OM_S_SUCCESS;

wrapup:
    _FREE( hdrId );

    End
    return status;
} /* VDdrw_retrieveTableRowInfo */

/*+fe
 -------------------------------------------------------------------------
  Function VDdrw_getTotalTableObjects

  Abstract
        Function gets all objects which need to add in the table.  

  Arguments

        IGRlong         *msg            O       return code
        IGRint		newCnt		I       No. of new objects
        struct PrcInfo  *newList	I       New object list
        IGRint		nbOldRows       I       No. of rows in existing table
        struct VDdrw_rowInfo *oldRows   I       Existing table row list
        IGRint		*curCnt		O       No. of objects in the existing
						table which need to be
						kept for new table.
        IGRint		*totalCnt	O       Total no. of objs in new table.
        struct GRobj_env **locObject    O	objs list in new table.

  Returns
        OM_S_SUCCESS    = if success
        OM_E_ABORT      = if error
 ------------------------------------------------------------------------- -fe*/
IGRlong VDdrw_getTotalTableObjects( IGRlong	         *msg,
				    IGRint               newCnt,
				    struct PrcInfo       *newList,
				    IGRint	         nbOldRows,
				    struct VDdrw_rowInfo *oldRows,
				    IGRint 		 *curCnt,
				    IGRint		 *totalCnt,
				    struct GRobj_env     **locObject )
{
    IGRint		  i, j, k, ret, isModified;
    IGRlong		  status;
    IGRint		  nbTxt,
			  tmpNbObjs,
			  ind,
			  totalNewCnt;
    struct GRid		  setId,
			  collId,
			  footId;
    struct GRobj_env	  *tolLocObj;
    struct PrcInfo 	  *newListCpy;
    OM_S_OBJID            mdId;
    IGRmatrix             mat;
    IGRshort		  matType;
    IGRchar		  pcmkNew[128], pcmkOld[128], *syntax;
    struct ACrg_coll      Attr;


    SetProc( VDdrw_getTotalTableObjects ); Begin

    *msg       = MSSUCC;
    status     = 0;
    newListCpy = NULL;
    tolLocObj  = NULL;
    syntax     = NULL;

    //if( !newCnt || !nbOldRows ) goto wrapup;
    if( nbOldRows == 0 ) goto wrapup;
    //if( newList   == NULL ||
    if( oldRows   == NULL ||
        curCnt    == NULL ||
	totalCnt  == NULL ||
	locObject == NULL ) goto wrapup;

    *curCnt = oldRows[nbOldRows-1].startIndex + oldRows[nbOldRows-1].nbObjs;

    /*
    ** set up memory for object list contained in the existing table
    */
    if( *curCnt > 0 )
    {
      (*locObject) = _MALLOC( (*curCnt)*2, struct GRobj_env );
      if( (*locObject) == NULL ) goto wrapup;
    }

    /*
    ** retrieve the existing objects
    */
    ind = 0;
    for( i = 0 ; i < nbOldRows ; i++ )
    {
      tmpNbObjs = 0;
      if( oldRows[i].nbObjs > 0 )
      {
	struct GRid *pretend;

	/*
	** This part should be replaced by VDdrwTblRow.VDgetParentObjectList
	** to get objects, and VDdrw_getAttFromColl to get named attributes
	*/

	setId.objid = NULL_OBJID;
        status =
        om$send( msg      = message VDdrwTblRow.ACfind_temp_obj(
                                                        (int *)msg,
							"objs",
                                                        &setId),
                 senderid = NULL_OBJID,
                 targetid = oldRows[i].rowId.objid,
                 targetos = oldRows[i].rowId.osnum );
        if( !(status&*msg&1) )
	{
	   UTAD_INFO("VDdrwTblRow.ACfind_temp_obj");
	   goto wrapup;
	}
        __DBGpr_obj( "setId: ", setId );

        /*
        ** get the current module id
        */
        status = ex$get_modid( mod_osnum = setId.osnum,
                               mod_id    = &mdId );

 	status =
        om$send( msg      = message NDnode.NDget_objects(ND_ROOT | ND_IN_BUF,
                                                         NULL,
                                                         0,
                                                         &pretend,
                                                         0,
                                                         OM_K_MAXINT,
                                                         &tmpNbObjs),
                 senderid = NULL_OBJID,
                 targetid = setId.objid,
                 targetos = setId.osnum );
        if( !(status&*msg&1) )
	{
	   UTAD_INFO("NDnode.NDget_objects");
	   goto wrapup;
	}

	for( j = 0 ; j < tmpNbObjs ; j++ )
        {
          footId.objid = NULL_OBJID;
          status =
          om$send( msg      = message NDmacro.ACreturn_foot(msg,
                                                            "",
                                                            &footId,
                                                            &matType,
                                                            mat),
                   senderid = NULL_OBJID,
                   targetid = pretend[j].objid,
                   targetos = pretend[j].osnum );

          if( !(status&*msg&1) ||
              (footId.objid==NULL_OBJID) ||
              (NDin_buffer(footId, &NDdelete) != -1) )
          {
            (*locObject)[ind+j].obj_id.objid = NULL_OBJID;
            (*locObject)[ind+j].obj_id.osnum = 0;
	  }
          else
          {
            (*locObject)[ind+j]._grid = footId;
            (*locObject)[ind+j]._md_os = footId.osnum;
            (*locObject)[ind+j]._md_id = mdId;
            (*locObject)[ind+j]._matrix_type = matType;

            for( k = 0 ; k < 16 ; k++ )
              (*locObject)[ind+j]._matrix[k] = mat[k];
          }
          __DBGpr_obj( "footId: ", footId );
	}

        ind += tmpNbObjs;
      }
    }

    *curCnt = ind;

    if( *curCnt > 0 )
    {
      tolLocObj = _MALLOC( ((*curCnt)+(2*newCnt)), struct GRobj_env );
      if( tolLocObj == NULL ) goto wrapup;
    }

    newListCpy = _MALLOC( newCnt + 2, struct PrcInfo );
    if( newListCpy == NULL ) goto wrapup;

    /*
    ** Check the new list
    */
    totalNewCnt = 0;
    for( i = 0 ; i < newCnt ; i++ )
    {
      if( newList[i].modelNew.obj_id.objid != NULL_OBJID )
      {
	newListCpy[totalNewCnt].model = newList[i].modelNew;
	newListCpy[totalNewCnt].modelNew = newList[i].model;
	newListCpy[totalNewCnt].process = newList[i].process;
	newListCpy[totalNewCnt].drwtbl = newList[i].drwtbl;
	totalNewCnt++;
      }
      else if( newList[i].model.obj_id.objid != NULL_OBJID )
      {
	newListCpy[totalNewCnt].model = newList[i].model;
	newListCpy[totalNewCnt].process = newList[i].process;
	newListCpy[totalNewCnt].drwtbl = newList[i].drwtbl;
        totalNewCnt++;
      }
    }

    /*
    ** Check the existing object list in table with the new list
    */
    tmpNbObjs = 0;
    for( i = 0 ; i < nbOldRows ; i++ )
    {
      if( oldRows[i].nbObjs == 0 )
      {
	 if( UTAD_dbg )
	 {
	    fprintf(UTAD_fp, "#### Following row is empty and ignored. Need Lined out ???\n");
            VDtblPrintRowInfo( &oldRows[i] );
	 }
	 continue;
      }

      ind = 0;
      for( k = 0 ; k < totalNewCnt ; k++ )
      {
	if( newListCpy[k].process != CONNECT ||
	    !IF_EQ_GRID( newListCpy[k].drwtbl.obj_id, oldRows[i].rowId ) ) 
	{ continue; }

	tolLocObj[tmpNbObjs] = newListCpy[k].model;
        newListCpy[k].model.obj_id.objid = NULL_OBJID;
        newListCpy[k].model.obj_id.osnum = 0;
        tmpNbObjs++;
        ind++;
      }

      for( j = oldRows[i].startIndex ; 
           j < oldRows[i].startIndex+oldRows[i].nbObjs ; j++ )
      {

        for( k = 0 ; k < totalNewCnt ; k++ )
        {
	  if(newListCpy[k].process != MIGRATE ||
	     !IF_EQ_GRID( newListCpy[k].drwtbl.obj_id, oldRows[i].rowId ) ||
	     !IF_EQ_GRID((*locObject)[j].obj_id,newListCpy[k].modelNew.obj_id))
	  { continue; }

          /*
          ** Get piece mark no. of new object.
          */
          pcmkNew[0] = '\0';
          vdsa$GetStruct( objID   = &newListCpy[k].model.obj_id,
                          name    = "SA_AST:StagingTree:0:pcmk",
                          txt     = pcmkNew );

	  /*
  	  ** get collector id
 	  */
	  status =
          om$send( msg      = message ACcpx.ACfind_temp_obj((int *)msg,
                                                            "coll",
                                                            &collId),
                   senderid = NULL_OBJID,
                   targetid = oldRows[i].rowId.objid,
                   targetos = oldRows[i].rowId.osnum );
          if( !(status&*msg&1) ) continue;

          /*
          ** Get piece mark no. of old object.
          */
	  Attr.name[0] = '\0';
          sprintf( Attr.name, "occurance_%d", j-oldRows[i].startIndex+1 );
          status =
          om$send( msg      = message ACrg_collect.ACget_named_attribute(
                                                msg,
                                                &Attr),
                   senderid = NULL_OBJID,
                   targetid = collId.objid,
                   targetos = collId.osnum );
          if( !(status&*msg&1) || (Attr.desc.type != AC_ATTRIB_TEXT) )
          {
            status = 1;
            *msg = 1;
            continue;
          }

	  isModified = 0;
          status = VDtblRowExecPplCheck( msg, &newListCpy[k].model.obj_id, 
				&oldRows[i].rowId, "VDrow_info", "check",
				Attr.desc.value.att_txt, &isModified );
	  if( isModified )
	  {
	    tolLocObj[tmpNbObjs] = newListCpy[k].modelNew;
            newListCpy[k].modelNew.obj_id.objid = NULL_OBJID;
            newListCpy[k].modelNew.obj_id.osnum = 0;
            tmpNbObjs++;
            ind++;
	  }

	  break;
        }

	for( k = 0 ; k < totalNewCnt ; k++ )
        {
	  if( newListCpy[k].model.obj_id.objid == NULL_OBJID ) continue;
	  if( IF_EQ_GRID((*locObject)[j].obj_id, newListCpy[k].model.obj_id) &&
	      newListCpy[k].process != MODIFY )
          {
	    tolLocObj[tmpNbObjs] = (*locObject)[j];
	    newListCpy[k].model.obj_id.objid = NULL_OBJID;
	    newListCpy[k].model.obj_id.osnum = 0;
	    tmpNbObjs++;
	    ind++;
	    break;
          }
	}
      }

      if( ind > 0 ) 
      {
	oldRows[i].nbObjs = ind;
      }
      else  
      {
        oldRows[i].nbObjs = 0;
      }

      if( i > 0 )
        oldRows[i].startIndex = oldRows[i-1].startIndex + oldRows[i-1].nbObjs;
    }

    /*
     * process lined out row separately in case missing cases
     */
    for( i = 0 ; i < nbOldRows ; i++ )
    {
      if( oldRows[i].nbObjs == 0 )
      {
	status = 
	om$send( msg      = message VDdrwTblRow.VDputLineOutFlag(msg, 1),
 	         senderid = NULL_OBJID,
                 targetid = oldRows[i].rowId.objid,
                 targetos = oldRows[i].rowId.osnum );
        CheckRC( status, *msg );

	/* CR6391, let lined out row editable
	status =
        om$send( msg      = message VDdrwTblRow.VDconstructRow(msg),
                 senderid = NULL_OBJID,
                 targetid = oldRows[i].rowId.objid,
                 targetos = oldRows[i].rowId.osnum );
	*/
      }
    }

    if( (*locObject) != NULL )
    {
      (*locObject) = 
	_REALLOC( (*locObject), (*curCnt)+totalNewCnt, struct GRobj_env );
    }
    else
    {
      (*locObject) = 
	_MALLOC( (*curCnt)+totalNewCnt, struct GRobj_env );
    }

    if( !(*locObject) ) goto wrapup;

    *curCnt = tmpNbObjs;

    for( i = 0 ; i < tmpNbObjs ; i++ ) (*locObject)[i] = tolLocObj[i];
    
    nbTxt = 0;
    for( i = 0 ; i < totalNewCnt ; i++ )
    {
      if( newListCpy[i].model.obj_id.objid != NULL_OBJID )
      {
	(*locObject)[tmpNbObjs] = newListCpy[i].model;
	tmpNbObjs++;
 	nbTxt++;
      }
    }

    *totalCnt = tmpNbObjs;

    status = OM_S_SUCCESS;
    *msg   = OM_S_SUCCESS;

wrapup:
    _FREE( newListCpy );
    _FREE( tolLocObj );

    End
    return status;
} /* VDdrw_getTotalTableObjects */

/*+fe
 -------------------------------------------------------------------------
  Function VDdrw_connectToNewParent

  Abstract
        Function adds new parent to table header.

  Returns
        OM_S_SUCCESS    = if success
        OM_E_ABORT      = if error
 ------------------------------------------------------------------------- -fe*/
IGRlong VDdrw_connectToNewParent( IGRlong          *msg,
                                  struct GRid      *nodes,
				  IGRint	   nbNodes,
                                  struct GRid      hdrId,
                                  struct GRmd_env  mod_env )
{
    IGRlong              status;
    IGRint               i,nbParents;
    //struct GRid          parentIds[3], newParent,
    struct GRid          *parentIds = NULL,
                         ctxId;


    SetProc( VDdrw_connectToNewParent ); Begin

    *msg     = MSSUCC;
    status   = 0;

    if( !nodes || hdrId.objid == NULL_OBJID ) goto wrapup;

    /*
    ** retrieve all the parents of table header
    */
    nbParents = 0;
    status =
    om$send( msg      = message NDnode.NDget_objects(ND_ROOT,
                                                     NULL,
                                                     0,
                                                     NULL,
                                                     0,
                                                     OM_K_MAXINT,
                                                     &nbParents),
             senderid = NULL_OBJID,
             targetid = hdrId.objid,
             targetos = hdrId.osnum );
    __CheckRC( status, *msg, "NDnode.NDget_objects", wrapup );

    parentIds = _MALLOC( nbParents, struct GRid );
    if( !parentIds )
        {
            printf( "Error in dynamic allocation\n" );
            status = OM_E_NODYNMEM;
            goto wrapup;
    }

    status =
    om$send( msg      = message NDnode.NDget_objects(ND_ROOT,
                                                     parentIds,
                                                     nbParents,
                                                     NULL,
                                                     0,
                                                     OM_K_MAXINT,
                                                     &nbParents),
             senderid = NULL_OBJID,
             targetid = hdrId.objid,
             targetos = hdrId.osnum );
    __CheckRC( status, *msg, "NDnode.NDget_objects", wrapup );

    status =
    om$send( msg      = message NDnode.NDdisconnect(nbParents,
                                                    parentIds),
             senderid = NULL_OBJID,
             targetid = hdrId.objid,
             targetos = hdrId.osnum );

    parentIds = _REALLOC( parentIds, (nbNodes+2), struct GRid );
    if( !parentIds )
        {
            printf( "Error in dynamic allocation\n" );
            status = OM_E_NODYNMEM;
            goto wrapup;
    }

    for( i = 0; i < nbNodes; i++ ) 
    {
       status =
       GRfindcontext( msg, NULL, NULL, &nodes[i].osnum, &ctxId );
       CheckRC( status, 1 );

       if( !(status & *msg & 1) ) ctxId = NULL_GRID;

       status = as$make_source( go_grid      = nodes[i],
                             context_grid = ctxId,
                             as_os        = mod_env.md_id.osnum,
                             as_grid      = &parentIds[i+2] );
    }

    nbParents = nbNodes + 2;
    status =
    om$send( msg      = message NDnode.NDconnect(nbParents,
                                                 parentIds,
                                                 NULL_GRID,
                                                 ND_ADD),
             senderid = NULL_OBJID,
             targetid = hdrId.objid,
             targetos = hdrId.osnum );


    /* may need the mod_env from parent, instead of current ? */
/*
    status = as$make_source( go_grid      = parent,
                             mod_env      = &mod_env,
                             as_grid      = &newParent );
    CheckRC( status, 1 );

    status =
    om$send(	msg      = message NDnode.NDchange_connect ( 
						1, 
						&parentIds[2], 
						&newParent ),
		senderid = NULL_OBJID,
		targetid = hdrId.objid,
		targetos = hdrId.osnum );
    CheckRC( status, 1 );
*/

    status = OM_S_SUCCESS;
    *msg   = OM_S_SUCCESS;


wrapup:
   _FREE( parentIds );
    End
    return status;
} /* VDdrw_connectToNewParent */

/*+f
 -------------------------------------------------------------------------
  Function VDdrw_removeInvalidRow

  Abstract

        Function removes and deletes invalid rows

  Arguments

        IGRlong			*msg		O       return code
        IGRint			newCnt          I	No. of new objects
	struct PrcInfo		*newList	I	new object list
        IGRint			nbRows          I	No. of new tbl rows
	struct VDdrw_rowInfo	*rows		I	new tbl object list

  Returns
 ------------------------------------------------------------------------- -fe*/
IGRlong	VDdrw_removeInvalidRow (
		IGRlong			*msg,
		IGRint			newCnt,
		struct PrcInfo		*newList,
		IGRint			nbRows,
		struct VDdrw_rowInfo	*rows)
			
				
{
    IGRlong		status;
    IGRint		i, j, cnt, ind;
    IGRint		invalid = 0;
    IGRint		nbValues = 0, *lineNos = NULL, *colNos = NULL;
    IGRchar		**values = NULL, *ptr = NULL;
    struct GRid		hdrId;

    SetProc( VDdrw_removeInvalidRow ); Begin; 

    if( newCnt < 1 || newList == NULL ) goto wrapup;
    if( nbRows < 1 || rows    == NULL ) goto wrapup;

    for(i = 0; i < newCnt; i++)
    {
      if( newList[i].process != MIGRATE ) {
         continue;
      }

      status = om$send( msg      = message VDdrwTblRow.VDgetCurrentRowValues( 
					   msg,
                                           &nbValues,
                                           &lineNos,
                                           &colNos,
                                           &values ),
		senderid = NULL_OBJID,
		targetid = newList[i].drwtbl.obj_id.objid, 
		targetos = newList[i].drwtbl.obj_id.osnum);
      
      if( !(status&(*msg)&1) || nbValues < 1 ) continue; 

      for( j = 0; j < nbValues; j++ )
      {
	 /* have to peel '(' from values for string comparison */
	 ptr = strchr(values[j], '(' ); 
	 if( ptr != NULL ) strcpy(values[j], ++ptr);

	 if( !strncasecmp( values[j], "INVALID", 7 ) ) 
	 {
	    invalid = 1;
	    break;
         }
      }
      if( j == nbValues ) continue;
      
      status = vd$tbl_get_hdrtbl(	msg	= msg, 
					rowID	= &newList[i].drwtbl.obj_id, 
					hdrID	= &hdrId);
      if( !(status&(*msg)&1) ) {
	UTAD_INFO("vd$tbl_get_hdrtbl");
	goto wrapup;
      }

      status = om$send( msg      = message VDdrwTblHdr.VDremoveRow (
						msg,
                                                1,
                                                NULL,
                                                &newList[i].drwtbl.obj_id),
                       senderid = NULL_OBJID,
                       targetid = hdrId.objid,
                       targetos = hdrId.osnum );
	printf("Warning: invalid row[%d,%d] is delete !!!\n",
		newList[i].drwtbl.obj_id.osnum,newList[i].drwtbl.obj_id.objid);
    }

    status = OM_S_SUCCESS;
    *msg   = OM_S_SUCCESS;

wrapup:
    _LOOPFREE( values, nbValues );
    _FREE(lineNos);
    _FREE(colNos);
    End
    return status;
}

/*+fe
-------------------------------------------------------------------------
  Function VDdrw_removeLinedOutRow

  Abstract

        Function removes and deletes lined out rows if piece marks not changed
	for TR3309, by ylong.

  Arguments

        IGRlong			*msg		O       return code
        IGRint			newCnt          I	No. of new objects
	struct PrcInfo		*newList	I	new object list
        IGRint			nbRows          I	No. of new tbl rows
	struct VDdrw_rowInfo	*rows		I	new tbl object list

  Returns
        OM_S_SUCCESS    = if success
        OM_E_ABORT      = if error
 ------------------------------------------------------------------------- -fe*/
IGRlong	VDdrw_removeLinedOutRow (
		IGRlong			*msg,
		IGRint			newCnt,
		struct PrcInfo		*newList,
		IGRint			nbRows,
		struct VDdrw_rowInfo	*rows)
			
				
{
    IGRlong		status;
    IGRint		i, j, cnt, ind;
    IGRshort		isLinedOut;
    IGRchar		pcmkOld[80], pcmkNew[80], *strPtr = NULL;
    struct GRid		hdrId, collId;
    struct ACrg_coll    attr;

    SetProc( VDdrw_removeLinedOutRow ); Begin

    for(i = 0; i < newCnt; i++)
    {
      // check if status is MIGRATE
      if( newList[i].process != MIGRATE ) {
        continue;
      }

      __DBGpr_obj("row id from newList with MIGRATE", newList[i].drwtbl.obj_id);

      // check if the row is lined out
      isLinedOut = 0;
      status =
      om$send( msg      = message VDdrwTblRow.VDisRowLinedOut(msg,&isLinedOut),
               senderid = NULL_OBJID,
               targetid = newList[i].drwtbl.obj_id.objid,
               targetos = newList[i].drwtbl.obj_id.osnum );
      CheckRC( status, *msg );
      if( !(status&*msg&1) || !isLinedOut ) continue;

      __DBGpr_obj("lined out row id", newList[i].drwtbl.obj_id);

      // check if the attribute for the row, containing path and pcmk, is empty

      status =
      om$send( msg      = message ACcpx.ACfind_temp_obj((int *)msg,
                                                        "coll",
                                                        &collId),
               senderid = NULL_OBJID,
               targetid = newList[i].drwtbl.obj_id.objid,
               targetos = newList[i].drwtbl.obj_id.osnum );
      if( !(status&*msg&1) ) continue;

      strcpy( attr.name, "occurance_1");
      status =
      om$send( msg      = message ACrg_collect.ACget_named_attribute
						(msg, &attr),
               senderid = NULL_OBJID,
               targetid = collId.objid,
               targetos = collId.osnum );
      if( !(status&*msg&1) || (attr.desc.type != AC_ATTRIB_TEXT) )
      {
        continue;
      }

      strPtr = strstr(attr.desc.value.att_txt, ":ref:");
      if( strPtr == NULL ) {
	strPtr = attr.desc.value.att_txt;
      }
      else {
	strPtr += 5;
      }
      strcpy( pcmkOld, strPtr);
      if( pcmkOld[0] == '\0' ) continue;
      __DBGpr_str("pcmkOld", pcmkOld);

      // find added row which replaces lined out and check its pcmk 
      ind = -1;
      for( j = 0; j < nbRows; j++ )
      {
        if( rows[j].flag != VD_DRW_ROW_NEW )  continue;

        status =
        om$send( msg      = message ACcpx.ACfind_temp_obj((int *)msg,
                                                          "coll",
                                                          &collId),
                 senderid = NULL_OBJID,
                 targetid = rows[j].rowId.objid,
                 targetos = rows[j].rowId.osnum );
        if ( !(status&*msg&1) ) continue;

        strcpy( attr.name, "occurance_1");
        status =
        om$send( msg      = message ACrg_collect.ACget_named_attribute
  						(msg, &attr),
                 senderid = NULL_OBJID,
                 targetid = collId.objid,
                 targetos = collId.osnum );
        if( !(status&*msg&1) || (attr.desc.type != AC_ATTRIB_TEXT) )
        {
          continue;
        }

        strPtr = strstr(attr.desc.value.att_txt, ":ref:");
        if( strPtr == NULL ) {
           strPtr = attr.desc.value.att_txt;
        }
        else {
           strPtr += 5;
        }
        strcpy( pcmkNew, strPtr);

        if( pcmkNew[0] == '\0' || strcmp(pcmkOld,pcmkNew) ) continue;

        status = vd$tbl_get_hdrtbl(	msg	= msg, 
					rowID	= &newList[i].drwtbl.obj_id, 
					hdrID	= &hdrId);
	if( !(status&(*msg)&1) )
	{
	   UTAD_INFO("vd$tbl_get_hdrtbl");
	   goto wrapup;
	}

        status =
        om$send( msg      = message VDdrwTblHdr.VDremoveRow (
						msg,
                                                1,
                                                NULL,
                                                &newList[i].drwtbl.obj_id),
                 senderid = NULL_OBJID,
                 targetid = hdrId.objid,
                 targetos = hdrId.osnum );
        if( !(status&*msg&1) ) {
		printf("Failed to remove the row with lined out\n");
	}
	else {
		printf("Warning: Lined out row[%d,%d] is delete !!!\n",
		newList[i].drwtbl.obj_id.osnum,newList[i].drwtbl.obj_id.objid);
	}

        break; 
      }

    }

    status = OM_S_SUCCESS;
    *msg   = OM_S_SUCCESS;

wrapup:
    End
    return status;
}

/*+fe
 -------------------------------------------------------------------------
  Function VDtbl_get_hdrtbl

  Abstract

	get table header and/or table id from a table row id, implemented for 
	vd$tbl_get_hdrtbl()

  Arguments

        IGRlong			*msg		O       return code
	struct	GRid		*rowID		I	table row id
	struct	GRid		*hdrID		O	table header id
	struct	GRid		*tblID		O	table id
  Returns
        OM_S_SUCCESS    = if success
        OM_E_ABORT      = if error
 ------------------------------------------------------------------------- -fe*/
IGRlong	VDtbl_get_hdrtbl (	IGRlong		*msg,
				struct	GRid	*rowID,
				struct	GRid	*hdrID,
				struct	GRid	*tblID) 
{
    IGRlong		status;
    struct	GRid	hdr, tbl;

    status = OM_E_ABORT;
    *msg   = OM_E_ABORT;

    if( (hdrID == NULL && tblID == NULL) || 
	 rowID == NULL || rowID->objid == NULL_OBJID ) 
    {
	__DBGpr_com("Error input to get table or header");
	goto wrapup;
    }

    hdr.objid = NULL_OBJID;
    tbl.objid = NULL_OBJID;

    status =
    om$send( msg      = message VDdrwTblRow.VDgetTableHeader(msg,
                                                         &hdr,
                                                         &tbl),
	     senderid = NULL_OBJID,
             targetid = rowID->objid,
             targetos = rowID->osnum );
    if( !(status&*msg&1) ) 
    {
	UTAD_INFO("VDdrwTbl.VDgetTableNbOfRows");
	goto wrapup;
    }
    
    if( hdrID ) *hdrID = hdr;
    if( tblID ) *tblID = tbl;

    status = OM_S_SUCCESS;
    *msg   = OM_S_SUCCESS;

wrapup:
    return status;
}


IGRlong VDdrw_validTable( TGRid	*tblId )
{
	IGRlong		status = 0, msg;
	IGRint		i, j;
	IGRint		nbRows = 0, nbHdrs = 0, chnCnt = 0, cnt = 0;
	TGRid		*hdrIds = NULL;

	status =
        om$send( msg      = message VDdrwTbl.VDgetTotalNbOfRows(&msg,&nbRows),
                 senderid = NULL_OBJID,
                 targetid = tblId->objid,
                 targetos = tblId->osnum );
        if( !(status&msg&1) ) {
                UTAD_INFO("VDdrwTbl.VDgetTableNbOfRows");
                goto wrapup;
        }
	
	status =
	om$send( msg      = message VDdrwTbl.VDgetTableParts(
							&msg,
                                                        &nbHdrs,
                                                        NULL),
	        senderid = NULL_OBJID,
                targetid = tblId->objid,
                targetos = tblId->osnum );
        if( !(status&msg&1) || (nbHdrs < 1) ) 
        {
		UTAD_INFO("VDdrwTbl.VDgetTableNbOfRows");
		goto wrapup;
	}

	hdrIds = _MALLOC( nbHdrs, TGRid );
	if( !hdrIds ) goto wrapup;

	status =
	om$send( msg      = message VDdrwTbl.VDgetTableParts(
							&msg,
                                                        &nbHdrs,
                                                        hdrIds),
	        senderid = NULL_OBJID,
                targetid = tblId->objid,
                targetos = tblId->osnum );
        if( !(status&msg&1) || (nbHdrs < 1) ) 
	
	for( i = 0; i < nbHdrs; i++ )
	{
	   cnt = 0;
	   vdchn$GetList (	objID   = &hdrIds[i],
				chnName = "VDdrwTblHdr.to_tblRows",
				maxCnt  = nbRows*2,
				cnt     = &cnt );
	   chnCnt += cnt;
	}

	if( chnCnt < nbRows ) 
	{
	   VDtblValidateRows ( tblId );
	}

	status = 1;
wrapup:
	_FREE(hdrIds);
	return status;
}


/*-------------------------------------------------------------------------
 * In case some rows missing from old rows, add them to the ouput
 */
IGRlong VDdrw_validRows(	struct VDdrw_rowInfo	*oldRows, 
				IGRint			nbOldRows,
				struct VDdrw_rowInfo	*rows,
				IGRint			*nbRows )
{
    IGRlong		status = 0, msg;
    IGRshort		isLinedOut = 0, found = 0;
    IGRint		i, j, nbNewRows = 0;
    IGRint		dupCnt = 0, *dupIndex = NULL;
    IGRint		missingCnt	= 0,	ind = 0;
    TGRid		*missingRowIds	= NULL;

    if( !oldRows || !rows ) goto wrapup;

    /*
     * Catch old rows not found in the rows
     */

    if ( (missingRowIds = _MALLOC( 1, TGRid ) ) == NULL ) goto wrapup;
    
    for( i = 0; i < nbOldRows; i++ )
    {
	/* search object match in rows */
	for (	j = 0; 
		j < *nbRows && !IF_EQ_GRID( oldRows[i].rowId, rows[j].rowId );
		j++ );

	/* get it */
	if( j == *nbRows )
	{
	    missingRowIds = _REALLOC( missingRowIds, missingCnt+1, TGRid );
	    if( !missingRowIds ) goto wrapup;
	    missingRowIds[missingCnt] = oldRows[i].rowId;
	    missingCnt++;
	}
    }

    /*
     * If there are no missing rows at all, wrapup
     */
    if( !missingCnt ) {
	status = 1;
	//goto wrapup;
    }

    dupIndex = _MALLOC( *nbRows, IGRint );
    if( !dupIndex ) goto wrapup;
    for( i = 0; i < *nbRows; i++ ) dupIndex[i] = 0;

    for( i = 0; i < *nbRows; i++ )
    {
	isLinedOut = 0;
	status =
	om$send(msg      = message VDdrwTblRow.VDisRowLinedOut( &msg,
								&isLinedOut),
		senderid = NULL_OBJID,
		targetid = rows[i].rowId.objid,
		targetos = rows[i].rowId.osnum );
	CheckRC( status, msg );

	if( !(status&msg&1) || !isLinedOut ) continue;
	
	/*
	 * Set row info, which row is lined out but nbObjs > 0
	 */
	if( rows[i].nbObjs > 0 )
	{
	    rows[i].flag = VD_DRW_ROW_OLD;
	    rows[i].nbObjs = 0;

	    /*
	     * Search possible duplicate row in rows
	     */
	    for( j = 0; j < *nbRows; j++ )
	    {
		/* ignore same object */
		if( j == i || dupIndex[j] ) continue;

		/* catch the duplicate row */
		if( IF_EQ_GRID( rows[i].rowId, rows[j].rowId ) )
		{
		    found = 1;
		    break;
		}
	    }

	    if( found )
	    {
		if( ind < missingCnt )
		{
		    rows[j].rowId = missingRowIds[ind];
		    rows[j].flag  = VD_DRW_ROW_OLD;
		    ind++;
		}
		else
		{
		   dupIndex[j] = 1;
		}
	    }
	}
    }

    nbNewRows = *nbRows;

    for( i = 0; i < *nbRows; i++ ) 
    {

	if( dupIndex[i] ) 
	{
	    nbNewRows--;
	    for( j = i; j < nbNewRows; j++ ) 
	    {
		memcpy(	(char *) &rows[j], (char *) &rows[j+1],
			sizeof( struct VDdrw_rowInfo ) ) ;

		dupIndex[j] = dupIndex[j+1];
	    }
	}
    }

    *nbRows = nbNewRows;

    status = 1;
wrapup:
    _FREE( missingRowIds );
    _FREE( dupIndex );
    return status;
}

/*---------------------------------------------------------------------
 */
IGRlong	VDdrw_getObjMatchFromRow(	struct GRid		objId, 
					struct RowItemInfo	*rowInfo,
					IGRint			nbRows,
					struct GRid		*objIds,
					IGRint			*index )
{
   IGRlong		status = 0;
   IGRint		i, j, n;

   for( i = 0; i < nbRows; i++ ) 
   {
      for( j = 0; j < rowInfo[i].nbObjs; j++ ) 
      {
	n = j + rowInfo[i].startIndex;
        if( IF_EQ_GRID(objId, objIds[n]) )
        {
	   *index = i;
	   return 1;
	}
      }
   }

wrapup:
   return status;
}

#define MAX_NUM	1e10
/*---------------------------------------------------------------------
 * Set item number for each row
 */
IGRlong	VDdrw_setItemNo (	struct	GRid		*xtblId,
				struct	GRid		*gridList,
				struct	VDdrw_rowInfo	*rows, 
				IGRint			nbRows, 
				IGRint			nbAddRows, 
				IGRlong			usrOpt )
{
    IGRlong		status = 0, msg = 0;
    IGRint		i, j, k, l, m, n, cnt;
    IGRint		size, nb = 0, startNo = 0, objInd = 0;
    IGRint		minNo = MAX_NUM, maxNo = 0;
    IGRchar		itemNo[80];
    IGRshort		isLinedOut, itemFlag = 0;
    IGRint		*maxObjs = NULL, maxInd, max = 0;
    IGRint		nbOldRows = 0,   nbNewRows = 0;
    IGRint		nbOldObjs = 0,   nbNewObjs = 0;
    struct RowItemInfo	*oldRows = NULL, *newRows = NULL;
    struct GRid		*oldObjs = NULL, *newObjs = NULL;
    TVDctxNodeList	xobjList, xrows;

    SetProc( VDdrw_setItemNo ); Begin

    VDctxInitNodeList(&xobjList);
    VDctxInitNodeList(&xrows);

    if( !rows || nbRows < 1 ) goto wrapup;

    VDdrwTblCMD_getStartItemNo( itemNo );
    VD_stripString( itemNo );

    if( isdigit(itemNo[0]) )	startNo = atoi( itemNo );
    else			itemNo[0] = '\0';

    if( UTAD_dbg )
    {
       fprintf( UTAD_fp, "Item - startNo: [%d], itemNo: [%d]\n",startNo,itemNo);
    }

    /*
     * Overwrite case and wipe out case
     */
    if(  (usrOpt & VD_TBL_ITEMNO_OVERW) || 
	((usrOpt & VD_TBL_ITEMNO_MANUAL) && startNo == 0) )
    {
       nb = startNo ;
       for( i = 0; i < nbRows; i++ )
       {
          isLinedOut = 0;
          status =
          om$send( msg      = message VDdrwTblRow.VDisRowLinedOut
						( &msg, &isLinedOut),
               senderid = NULL_OBJID,
               targetid = rows[i].rowId.objid,
               targetos = rows[i].rowId.osnum );
          if( isLinedOut ) continue;

	  if( startNo > 0 ) sprintf( itemNo, "%d", nb );
	  status = om$send ( msg    = message VDdrwTblRow.VDputItemNumber
                                                ( &msg, itemNo),
                            senderid = NULL_OBJID,
                            targetid = rows[i].rowId.objid,
                            targetos = rows[i].rowId.osnum );
	  if( (status&msg&1) ) nb++;
       }

       status = 1;
       goto wrapup;
    }

    /*
     * Process AUTO and MANUAL
     */

    if( !xtblId )
    {
	UTAD_INFO( "Finding xml table pointer");
	goto wrapup;
    }
    if( xtblId->objid == NULL_OBJID )
    {
	UTAD_INFO( "Finding xml table id");
	goto wrapup;
    }

    /*
     * process new rows and objects.
     */
    nbNewRows = nbRows;
    if( nbNewRows ) newRows = _MALLOC( nbNewRows, struct RowItemInfo );
    if( !newRows ) goto wrapup;

    nbNewObjs = 0;
    for( i = 0; i < nbNewRows; i++ ) {
       newRows[i].rowId		= rows[i].rowId;
       newRows[i].nbObjs	= rows[i].nbObjs;
       newRows[i].startIndex	= rows[i].startIndex;
       newRows[i].flag		= rows[i].flag;
       newRows[i].itemNo	= -1;
       nbNewObjs += rows[i].nbObjs;
       if( newRows[i].nbObjs == 0 )
       {
	   /*
	    * the number of objects is 0 means the row is lined out, so
	    * reserve its item number
	    */
	   status =
           om$send( msg      = message VDdrwTblRow.VDgetItemNumber(
                                                        &msg, 
							&size,
							itemNo),
		    senderid = NULL_OBJID,
		    targetid = newRows[i].rowId.objid,
		    targetos = newRows[i].rowId.osnum );
	   if( (status&msg&1) ) newRows[i].itemNo = atoi(itemNo);
       }
    }

    // new objects in new rows
    if( nbNewObjs ) newObjs = _MALLOC( nbNewObjs, struct GRid );
    if( !newObjs )
    {
	goto wrapup;
    }

    for( i = 0; i < nbNewObjs; i++ ) {
       newObjs[i] = gridList[i];
    }

    /* 
     * process old rows and objects from xml. 
     * Be careful, nbXX may be 0 !!! Handle it later
     */
    VDctxGetNodeListByType(xtblId, VD_XTBL_NODE_TYPE_OBJ, &xobjList);
    if( xobjList.cnt < 1 ) 
    {
	UTAD_INFO( "VDctxGetNodeListByType" );
	goto wrapup;
    }

    nbOldObjs = xobjList.cnt;
    VDctxFreeNodeList(&xobjList);
    if( nbOldObjs ) oldObjs = _MALLOC( nbOldObjs, struct GRid );
    if( !oldObjs )
    {
	UTAD_INFO( "VDctxFreeNodeList" );
	goto wrapup;
    }

    VDctxGetNodeListByType(xtblId, VD_XTBL_NODE_TYPE_ROW, &xrows);
    if( xrows.cnt < 1 ) 
    {
	UTAD_INFO("VDctxGetNodeListByType");
	goto wrapup;
    }

    nbOldRows = xrows.cnt;
    if( nbOldRows ) oldRows = _MALLOC( nbOldRows, struct RowItemInfo );
    if( !oldRows ) goto wrapup;

    objInd = 0;
    for( i = 0; i < nbOldRows; i++ ) {

	oldRows[i].rowId.objid = NULL_OBJID;
	oldRows[i].itemNo = -1;
	oldRows[i].nbObjs = 0;

	/* get old row id */

        VDtblXmlGetObjFromXnode(&xrows.listIDs[i], &oldRows[i].rowId);

	/* get item number */

	VDctxGetTxtAtr (	&xrows.listIDs[i],
				VD_XTBL_ROW_ATTR_TXT_ITEMNO,
				itemNo );

	VD_stripString( itemNo );
	if( isdigit( *itemNo ) ) {
	   itemFlag = 1;
	   oldRows[i].itemNo = atoi( itemNo );
	}
	if( minNo > oldRows[i].itemNo ) minNo = oldRows[i].itemNo;
	if( maxNo < oldRows[i].itemNo ) maxNo = oldRows[i].itemNo;

	/* get object info for the row */

        VDctxGetNodeListByType(	&xrows.listIDs[i], 
				VD_XTBL_NODE_TYPE_OBJ, 
				&xobjList);
	oldRows[i].nbObjs = xobjList.cnt;
	oldRows[i].startIndex = objInd;

	/* get objects for the row */

	for( j = 0; j < oldRows[i].nbObjs; j++ ) {
           VDtblXmlGetObjFromXnode(&xobjList.listIDs[j], &oldObjs[j+objInd]);
	}
        VDctxFreeNodeList(&xobjList);

	objInd += oldRows[i].nbObjs;
    }
    
    /*
     * for auto mode, if the old table was not itemized, the new table 
     * is also not itemized
     */
    if( usrOpt & VD_TBL_ITEMNO_AUTO && !itemFlag )
    {
        status = 1;
        goto wrapup;
    }

    maxObjs = _MALLOC( nbNewRows, IGRint );
    if( !maxObjs ) goto wrapup;
    for( i = 0; i < nbNewRows; i++ ) maxObjs[i] = 0;

    for( i = 0; i < nbOldRows; i++ ) 
    {
	maxInd = 0;
	for( k = 0; k < nbNewRows; k++ ) maxObjs[k] = 0;

	for( j = 0; j < oldRows[i].nbObjs; j++ ) 
	{
	   l = j + oldRows[i].startIndex;
	   status = 
	   VDdrw_getObjMatchFromRow(oldObjs[l],newRows,nbNewRows,newObjs, &k);

	   if( status ) maxObjs[k] += 1;
	}

	if( !oldRows[i].nbObjs ) continue;

	max = 0; maxInd = -1;
	for( k = 0; k < nbNewRows; k++)
	{
	   if( maxObjs[k] > max ) 
	   {
		max = maxObjs[k];
		maxInd = k;
	   }
	}

	if(maxInd >= 0 && newRows[maxInd].itemNo < 0 && newRows[maxInd].nbObjs)
	{
	   newRows[maxInd].itemNo = oldRows[i].itemNo;
	   sprintf( itemNo, "%d", newRows[maxInd].itemNo );

	   status =
           om$send( msg      = message VDdrwTblRow.VDputItemNumber(
                                                        &msg, 
							itemNo),
		    senderid = NULL_OBJID,
		    targetid = newRows[maxInd].rowId.objid,
		    targetos = newRows[maxInd].rowId.osnum );
	}
    }

    /* get next available item number */

    if( usrOpt & VD_TBL_ITEMNO_AUTO ) 
    {
        if( maxNo < 1 || minNo < 1 ) 
	{
	   goto wrapup;
	}
        max = maxNo + 1;
    }
    else max = startNo; /* usrOpt & VD_TBL_ITEMNO_MANUAL */
    
    *itemNo = 0;
    for( i = 0; i < (nbNewRows - nbAddRows); i++ )
    {
	if( newRows[i].itemNo > 0 || !newRows[i].nbObjs ) continue;

	/*
	 * check available item number between minNo and maxNo
	 */
	nb = minNo; 
	itemFlag = 0;
	while( nb < maxNo && !itemFlag ) 
	{
	    for(j = 0; 
		j < (nbNewRows - nbAddRows) && nb != newRows[j].itemNo; 
		j++ );
	    
	    if( j == (nbNewRows - nbAddRows) ) 
	    {
	 	itemFlag = 1;
	    }
	    else nb++;
	} 

	minNo = nb;
	/* if nb is not used in current i loop it may be used in next i loop */

	/*
	 * set minNo to the row, if it has old obj, 
	 * else use next available number
	 */
	if( itemFlag && minNo < maxNo )
	{
	    itemFlag = 0;
	    for( j = 0; j < newRows[i].nbObjs; j++ )
	    {
	      for( k = 0; k < nbOldObjs; k++ ) 
	      {
		if(IF_EQ_GRID( newObjs[j+newRows[i].startIndex], oldObjs[k]))
		{
		    itemFlag = 1;
		    newRows[i].itemNo = minNo;
	    	    sprintf( itemNo, "%d", minNo++ );
		    break;
		}
	      }
	      if( itemFlag ) break;
	    }
	   
	}
	else if (max > 0)
	{
	   newRows[i].itemNo = max;
	   sprintf( itemNo, "%d", max++ );
	}
	status =
        om$send( msg      = message VDdrwTblRow.VDputItemNumber(
                                                        &msg, 
							itemNo),
		 senderid = NULL_OBJID,
		 targetid = newRows[i].rowId.objid,
		 targetos = newRows[i].rowId.osnum );
    }

    for( i = (nbNewRows - nbAddRows); i < nbNewRows; i++ )
    {
	if( newRows[i].itemNo > 0 || !newRows[i].nbObjs ) continue;

	sprintf( itemNo, "%d", max++ );
        om$send( msg      = message VDdrwTblRow.VDputItemNumber(
                                                        &msg, 
							itemNo),
		 senderid = NULL_OBJID,
		 targetid = newRows[i].rowId.objid,
		 targetos = newRows[i].rowId.osnum );
    }

    /*
     * finally, sort rows by item number upon CR6039
     */
    qsort ( (char *)rows,
             nbRows,
             sizeof(struct VDdrw_rowInfo),
             (int (*)())setRowsByItemNo );


    status = 1;
wrapup:
    VDctxFreeNodeList(&xobjList);
    VDctxFreeNodeList(&xrows);
    _FREE( maxObjs );
    _FREE( newObjs );
    _FREE( newRows );
    _FREE( oldObjs );
    _FREE( oldRows );
    End
    return status;
}

/*---------------------------------------------------------
 */
IGRlong	VDdrw_setRowsAndObjs (	IGRlong			*msg,		// out
				struct VDdrwlo_tab	*tblRec,	// in
				IGRlong			appendFlag,	// in
				struct PrcInfo		*newList,	// in
				IGRint			newCnt,		// in
				struct VDdrw_rowInfo	*oldRows, 	// in
				IGRint			nbOldRows, 	// in
				struct VDdrw_rowInfo	**rows,		// out
				IGRint			*nbRows, 	// out
				struct GRobj_env	**objOEs,	// out
				IGRint			*objCnt, 	// out
				IGRint			*nbNewRows)	// out

{
    IGRlong	status		= 0;
    IGRint	i;
    IGRint	nbAddRows	= 0,
    		nbCurRows	= 0,
		curObjCnt	= 0,
		curAddCnt	= 0,
		curListCnt	= 0,
		curTotalCnt	= 0,
		addObjCnt	= 0,
		objInd		= 0,
		zero		= 0;

    TGRobj_env	*curObjOEs	= NULL;
    TGRobj_env	*addObjOEs	= NULL;

    struct PrcInfo		*curList = NULL;
    struct VDdrw_rowInfo	*addRows = NULL;
    struct VDdrw_rowInfo	*curRows = NULL;

    /*
     * Following declarations for fix missing row problem. just save old
     * rows before they are modified by VDdrw_getTotalTableObjects().
     * XML table is only available for some cases, instead evry case, so
     * don't expect to get old rows from it.
     */
    struct VDdrw_rowInfo	*origRows	= NULL;
    IGRint			nbOrigRows	= 0;

    SetProc( VDdrw_setRowsAndObjs ); Begin

    *msg = 0;

    if( !tblRec ) goto wrapup;
    if( !newList || !newCnt ) goto wrapup;
    if( !rows    || !nbRows ) goto wrapup;
    if( !objOEs  || !objCnt ) goto wrapup;

    *nbNewRows	= 0;
    *nbRows	= 0;
    *objCnt	= 0;
    *rows	= NULL;
    *objOEs	= NULL;

    /*
     * Save oldRows before it is changed
     */
    if( !(origRows = _MALLOC( nbOldRows, struct VDdrw_rowInfo )) ) goto wrapup;
    nbOrigRows = nbOldRows;
    for( i = 0; i < nbOrigRows; i++ )
    {
	memcpy(	(char *) &origRows[i], (char *) &oldRows[i],
		sizeof( struct VDdrw_rowInfo ) ) ;
    }

    if( UTAD_dbg ) {
	fprintf( UTAD_fp, "###### Old rows before summ and sort ######\n");
	for(i = 0; i < nbOldRows; i++ ) {
	   VDtblPrintRowInfo( &oldRows[i] );
	}
    }

    /*
     * For appending new objects to the bottom of the table
     */
    if( appendFlag )
    {
	/*
	 * first, seperate current objects in the table and the added ones
	 */
	for( i = 0; i < newCnt; i++ )
	{
	    if(	newList[i].process > DELETE &&
		newList[i].model.obj_id.objid != NULL_OBJID )
	    {
		addObjCnt++;
	    }
	    else
	    {
		curListCnt++;
	    }
	}

	if( UTAD_dbg ) {
	  fprintf( UTAD_fp, "\nAppend[%d] addObjCnt %d - curListCnt %d \n", __LINE__, addObjCnt, curListCnt );
	  fprintf( UTAD_fp, "\nAppend[%d] newCnt %d \n", __LINE__, newCnt );
	}

	nbAddRows = addObjCnt;

	if( addObjCnt )
	{
	   if( !(addObjOEs = _MALLOC(addObjCnt, TGRobj_env)) ) goto wrapup;
	}

	if( curListCnt )
	{
	   if( !(curList = _MALLOC(curListCnt, struct PrcInfo)) ) goto wrapup;
	}

	addObjCnt = 0;
	curListCnt = 0;
	for( i = 0; i < newCnt; i++ )
	{
	    if( newList[i].process > DELETE &&
		newList[i].model.obj_id.objid != NULL_OBJID )
            {
		addObjOEs[addObjCnt] = newList[i].model;
		addObjCnt++;
	    }
	    else
	    {
		memcpy(	(char *) &curList[curListCnt],
			(char *) &newList[i],
			sizeof( struct PrcInfo ) ) ;
		curListCnt++;
	    }
	}
	if( UTAD_dbg ) {
	  fprintf( UTAD_fp, "\nAppend[%d] addObjCnt %d - curListCnt %d \n", __LINE__, addObjCnt, curListCnt );
	}

	/*
	 * process current list
	 */
	status = VDdrw_getTotalTableObjects (	msg,
						curListCnt,
						curList,
						nbOldRows,
						oldRows,
						&curObjCnt,
						&curTotalCnt,
						&curObjOEs );
	if( !(status&*msg&1) ) 
	{
	   UTAD_INFO("VDdrw_getTotalTableObjects");
	   goto wrapup;
	}

	if( UTAD_dbg ) {
	  fprintf( UTAD_fp, "\nAppend[%d] curTotalCnt %d - curObjCnt %d \n", __LINE__, curTotalCnt, curObjCnt );
	}

	curAddCnt  = curTotalCnt - curObjCnt;
	nbCurRows  = nbOldRows  + curAddCnt;

	if( UTAD_dbg ) {
	  fprintf( UTAD_fp, "\nAppend[%d] nbCurRows %d - curAddCnt; %d \n", __LINE__, nbCurRows, curAddCnt );
	  fprintf( UTAD_fp, "\nAppend[%d] nbCurRows %d - nbOldRows; %d \n", __LINE__, nbCurRows, nbOldRows );
	}
	
	if(!(curRows = _MALLOC( nbCurRows, struct VDdrw_rowInfo))) goto wrapup;

	for( i = 0; i < nbOldRows; i++ )
	{
	    memcpy (	(char *) &curRows[i],
			(char *) &oldRows[i],
			sizeof( struct VDdrw_rowInfo ) ) ;
	}

	for( i = nbOldRows, objInd = curObjCnt; i < nbCurRows; i++, objInd++ )
	{
	    curRows[i].rowId.objid = NULL_OBJID;
	    curRows[i].nbObjs = 1;
	    curRows[i].startIndex = objInd;
	    curRows[i].qty.nSflag = VD_DRWLO_EN_COUNT;
	    curRows[i].qty.szExp[0] = '\0';
	    curRows[i].flag = VD_DRW_ROW_NEW;
	}

	if( curTotalCnt > 0 )
	{

	    if( UTAD_dbg ) {
		fprintf( UTAD_fp, "\nAppend[%d] call VDdrw_summ_and_sort_objs \n", __LINE__ );
	    }
	    status = VDdrw_summ_and_sort_objs (	msg,
						tblRec,
						&curTotalCnt,
						&nbCurRows,
						&curAddCnt,
						&curRows,
						curObjOEs );
	    if( !(status&*msg&1) ) 
	    {
		UTAD_INFO("VDdrw_summ_and_sort_objs");
		goto wrapup;
	    }
	}

	/*
	 * process newly added objects
	 */
	if( nbAddRows )
	{
	    if(!(addRows = _MALLOC( nbAddRows, struct VDdrw_rowInfo))) 
	    {
		goto wrapup;
	    }

	    for( i = 0; i < nbAddRows; i++ )
	    {
		addRows[i].rowId.objid = NULL_OBJID;
		addRows[i].nbObjs = 1;
		addRows[i].startIndex = i;
		addRows[i].qty.nSflag = VD_DRWLO_EN_COUNT;
		addRows[i].qty.szExp[0] = '\0';
		addRows[i].flag = VD_DRW_ROW_NEW;
	    }

	    if( UTAD_dbg ) {
		fprintf( UTAD_fp, "\nAppend[%d] call VDdrw_summ_and_sort_objs \n", __LINE__ );
	    }
	    status = VDdrw_summ_and_sort_objs (	msg,
						tblRec,
						&addObjCnt,
						&nbAddRows,
						&zero,
						&addRows,
						addObjOEs);
	    if( !(status&*msg&1) ) 
	    {
		UTAD_INFO("VDdrw_summ_and_sort_objs");
		goto wrapup;
	    }
	}

	/*
	 * process current objects and added object togather
	 */
	if( UTAD_dbg ) {
	  fprintf( UTAD_fp, "\nAppend[%d] nbCurRows %d - nbAddRows; %d \n", __LINE__, nbCurRows, nbAddRows );
	}

	*nbRows    = nbCurRows + nbAddRows;
	if( !(*rows = _MALLOC( (*nbRows), struct VDdrw_rowInfo )) ) goto wrapup;

	for( i = 0; i < nbCurRows; i++ )
	{
	    memcpy (	(char *) &(*rows)[i],
			(char *) &curRows[i],
			sizeof( struct VDdrw_rowInfo ) ) ;
	}
	for( i = 0; i < nbAddRows; i++ )
	{
	    memcpy (	(char *) &(*rows)[i+nbCurRows],
			(char *) &addRows[i],
			sizeof( struct VDdrw_rowInfo ) ) ;
	    
	    (*rows)[i+nbCurRows].startIndex += curTotalCnt;
	}

	if( UTAD_dbg ) {
	  fprintf( UTAD_fp, "###### Append: %d nbRows[%d] ######\n", __LINE__ , *nbRows );
	  for(i = 0; i < *nbRows; i++ ) {
	    VDtblPrintRowInfo( &(*rows)[i] );
          }
        }
	
	if( UTAD_dbg ) {
	  fprintf( UTAD_fp, "\nAppend[%d] curTotalCnt %d - addObjCnt %d \n", __LINE__, curTotalCnt, addObjCnt );
	}

	*objCnt = curTotalCnt + addObjCnt;

	if( *objCnt )
	{
	    if( !(*objOEs = _MALLOC( *objCnt, TGRobj_env )) ) goto wrapup;
	}

	for( i = 0; i < curTotalCnt; i++ )
	{
	    (*objOEs)[i] = curObjOEs[i];
	}
	for( i = 0; i < addObjCnt; i++ )
	{
	    (*objOEs)[i+curTotalCnt] = addObjOEs[i];
	}

	*nbNewRows = nbAddRows;
	if( UTAD_dbg ) {
	  fprintf( UTAD_fp, "\nAppend[%d] nbNewRows %d - nbAddRows %d \n", __LINE__, *nbNewRows, nbAddRows );
	}

    } /* END if append objects to the table */

    else 
    {
	status = VDdrw_getTotalTableObjects (	msg,
						newCnt,
						newList,
						nbOldRows,
						oldRows,
						&curObjCnt,
						objCnt,
						objOEs );
	if( !(status&*msg&1) ) goto wrapup;

	addObjCnt = *objCnt - curObjCnt;
	*nbRows   = nbOldRows + addObjCnt;

	if( !(*rows = _MALLOC( (*nbRows), struct VDdrw_rowInfo )) ) goto wrapup;

	for( i = 0; i < nbOldRows; i++ )
	{
	    memcpy (	(char *) &(*rows)[i],
			(char *) &oldRows[i],
			sizeof( struct VDdrw_rowInfo ) ) ;
	}

	for( i = nbOldRows, objInd = curObjCnt; i < *nbRows; i++, objInd++ )
	{
	    (*rows)[i].rowId.objid = NULL_OBJID;
	    (*rows)[i].nbObjs = 1;
	    (*rows)[i].startIndex = objInd;
	    (*rows)[i].qty.nSflag = VD_DRWLO_EN_COUNT;
	    (*rows)[i].qty.szExp[0] = '\0';
	    (*rows)[i].flag = VD_DRW_ROW_NEW;
	}

	status = VDdrw_summ_and_sort_objs (	msg,
						tblRec,
						objCnt,
						nbRows,
						&addObjCnt,
						rows,
						*objOEs );
	if( !(status&*msg&1) ) goto wrapup;

	*nbNewRows = *nbRows - nbOldRows;
    }

    if( UTAD_dbg ) {
	fprintf( UTAD_fp, "###### Rows after summ and sort ######\n");
	for(i = 0; i < *nbRows; i++ ) {
	   VDtblPrintRowInfo( &(*rows)[i] );
	}
    }
   
    /*
     * Validate row to make sure no rows missing.
     */
    VDdrw_validRows( origRows, nbOrigRows, *rows, nbRows );

    if( UTAD_dbg ) {
	fprintf( UTAD_fp, "###### Rows after validate ######\n");
	for(i = 0; i < *nbRows; i++ ) {
	   VDtblPrintRowInfo( &(*rows)[i] );
	}
    }

    *msg   = MSSUCC;
    status = OM_S_SUCCESS;
wrapup:
    _FREE( curObjOEs );
    _FREE( addObjOEs );
    _FREE( curList );
    _FREE( addRows );
    _FREE( curRows );
    _FREE( origRows );
    End
    return status;
} /* VDdrw_setRowsAndObjs */

/*-------------------------------------------------------------------------
 * If "maintain overwritten attributes" required, recover these attributes.
 */
IGRlong VDdrw_recoverUsrVals(	IGRlong			*msg,
				struct GRid		*xtblId,
				struct GRid		*gridList,
				struct VDdrw_rowInfo	*rows,
				IGRint			nbRows )
{
      IGRlong		status = 0;
      IGRint		i, j;
      struct GRid	*curObjs = NULL;
      struct GRid	xrowId, xobjSet, collId;
      TVDctxNodeList	xobjList;
      TVDctxNodeList	xcellList;
      IGRchar		usrVal[1024], defVal[1024], buf[1024];
      GRname		attName;

      *msg = MSSUCC;
      VDctxInitNodeList(&xcellList);
      VDctxInitNodeList(&xobjList);

      if( !xtblId || xtblId->objid == NULL_OBJID ) goto wrapup;
      if( !rows   || !nbRows || !gridList ) goto wrapup;

      VDctxGetNodeListByType(xtblId, VD_XTBL_NODE_TYPE_OBJ, &xobjList);

      if( !xobjList.cnt ) goto wrapup;

      curObjs = _CALLOC( xobjList.cnt, struct GRid );
      if( !curObjs ) goto wrapup;

      for( i = 0; i < xobjList.cnt; i++ )
      {
        VDtblXmlGetObjFromXnode(&xobjList.listIDs[i], &curObjs[i]);
      }

      for( i = 0 ; i < nbRows ; i++ )
      {
	if( rows[i].rowId.objid == NULL_OBJID ) continue;
	
        status =
        om$send(	msg      = message ACcpx.ACfind_temp_obj (
							(int *)msg,
							"coll",
							&collId),
			senderid = NULL_OBJID,
			targetid = rows[i].rowId.objid,
			targetos = rows[i].rowId.osnum );
        if( !(status&*msg&1) ) continue;

	xrowId.objid = NULL_OBJID;
        xobjSet.objid = NULL_OBJID;
        VDctxInitNodeList(&xcellList);
	for( j = 0 ; j < xobjList.cnt; j++ )
        {
          if( IF_EQ_GRID( curObjs[j], gridList[rows[i].startIndex] ) )
          {
            VDctxGetTreeParent( &xobjList.listIDs[j], &xobjSet );
            if( xobjSet.objid != NULL_OBJID )
            {
              VDctxGetTreeParent( &xobjSet, &xrowId );
            }

            if( xrowId.objid != NULL_OBJID )
            {
              VDctxGetNodeListByType (        &xrowId,
                                              VD_XTBL_NODE_TYPE_CELL,
                                              &xcellList);
            }
            break;
          } 
	}

	if( xcellList.cnt < 1 ) continue;
	
	for( j = 0; j < xcellList.cnt; j++ )
	{
	  VDctxGetTxtAtr (	&xcellList.listIDs[j],
				VD_XTBL_CELL_ATTR_TXT_VALUE,
				usrVal );
          VDctxGetTxtAtr (	&xcellList.listIDs[j],
				VD_XTBL_CELL_ATTR_TXT_DEFAULT,
				defVal );
	  if( !strcmp( usrVal, defVal ) ) continue;

	  VDctxGetTxtAtr (	&xcellList.listIDs[j],
				VD_XTBL_CELL_ATTR_INT_COLNO,
				buf );
	  strcpy( attName, buf );
	  buf[0] = '\0';
	  VDctxGetTxtAtr (    &xcellList.listIDs[j],
                              VD_XTBL_CELL_ATTR_INT_LINNO,
                              buf );
	  strcat( attName, " " );
	  strcat( attName, buf );

	  VDputAttInColl( msg, collId, attName, usrVal );
	}
      }

      status = OM_S_SUCCESS; 
wrapup:
      /* clean up bufs */
      _FREE( curObjs );
      VDctxFreeNodeList(&xobjList);
      VDctxFreeNodeList(&xcellList);
      return status;
}

/*+fe
 -------------------------------------------------------------------------
  Function VDdrw_processTableObjects

  Abstract
        Function reviews all existing objects in a table with given objects 
        to create new table.

  Arguments

        IGRlong         *msg            O       return code
	struct GRid	*tblId		I	table ID
	struct GRid	nodeId		I	root node ID
        IGRint		*count          I	No. of new objects
	struct PrcInfo	*newList	I	new list
	IGRint		newCnt		I	new count
	IGRlong		usrOpt		I	options: VD_TBL_USR_VAL
							 VD_TBL_APP_NEW
						one or both selections, bit def
	struct GRid	*xtblId		I	xml table tree ID

  Returns
        OM_S_SUCCESS    = if success
        OM_E_ABORT      = if error
 ------------------------------------------------------------------------- -fe*/
IGRlong VDdrw_processTableObjects( IGRlong	  *msg,
			           struct GRid    *tblId,
			           struct GRid    *nodeIds,
				   IGRint	  nbNodes,
				   struct PrcInfo *newList,
				   IGRint	  newCnt,
				   IGRlong	  usrOpt,
				   struct GRid	  *xtblId )
{
    IGRint		  i, j, k;
    IGRlong		  status;
    IGRint		  nbRows,
			  nbAddRows,
			  nbCpyHdrs,
			  nbHdrRows,
			  nbHdrs,
			  startRowNo,
			  *lastRowNos,
			  *splitLocs,
			  curCnt,
			  totalCnt,
			  tmpNbObjs,
			  addCnt,
			  hdrInd,
			  ind,
			  nbNewObjs,
			  objInd,
			  nbOldRows,
			  nbCs,
		  	  mode,
			  rowNo,
			  cpyInd,
			  nbAttr,
			  size = sizeof( struct GRmd_env );
    struct GRid		  setId,
			  collId,
			  rowId,
			  *gridList,
 			  *cpyIds,
			  *csIds,
			  *hdrId;
    struct VDdrw_rowInfo  *rows, *oldRows;
    OMuword               os;
    struct VDdrwlo_tab    tblRec;
    IGRshort		  newFlag,
			  isLinedOut,
			  trlType = VD_DRWLO_EN_BRKTRLR,
			  cnstType = VD_DRW_CNST_TRLR,
			  prop, delFlag = 0;
    struct GRmd_env       mod_env;
    enum GRdpmode         dpmode;
    IGRdouble             oldPoint[3],
			  oldWldPnt[3],
                          rowHeight;
    IGRchar		  csType[] = "rectangular";
    struct GRobj_env	  *locObject;
    struct ACrg_coll      *Attr;
    IGRchar               szmsg[200];


    SetProc( VDdrw_processTableObjects ); Begin

    *msg       = MSSUCC;
    status     = 0;
    curCnt     = 0;
    nbOldRows  = 0;
    totalCnt   = 0;
    addCnt     = 0;
    Attr       = NULL;
    cpyIds     = NULL;
    csIds      = NULL;
    gridList   = NULL;
    hdrId      = NULL;
    lastRowNos = NULL;
    splitLocs  = NULL;
    locObject  = NULL;
    oldRows    = NULL;
    rows       = NULL;

    if( tblId == NULL ) goto wrapup;
    if( newList == NULL || newCnt <= 0 )
    {
      printf("New object list is empty!\n");
      goto wrapup;
    }

    /*
    ** validates associative update mode.  If it is set
    ** to delayed, the function must be exited
    */
    status = nd$mod_batch( request    = ND_INQ,
                           p_ret_mode = &mode );
    if( mode == ND_DEFER )
    {
	__DBGpr_com("associative update mode = ND_DEFER");
	printf("\n\nAssociative update mode = ND_DEFER\n");
        *msg = VD_ERROR;
        goto wrapup;
    }

    /* 
    ** recompute the table
    */
    UI_status( "Recomputing table ..." );

    /*
    ** get current module environment
    */
    status = gr$get_module_env( msg     = msg,
                                sizbuf  = &size,
                                buffer  = &mod_env );
    /*
    ** get number of table parts(headers)
    */
    nbHdrs = 0;
    status =
    om$send( msg      = message VDdrwTbl.VDgetTableParts(msg,
                                                         &nbHdrs,
                                                         NULL),
	     senderid = NULL_OBJID,
             targetid = tblId->objid,
             targetos = tblId->osnum );
    if( !(status&*msg&1) || (nbHdrs <= 0) ) 
    {
	UTAD_INFO("VDdrwTbl.VDgetTableParts(msg");
	__DBGpr_com("VDdrwTbl.VDgetTableParts failed");
	goto wrapup;
    }

    /*
    ** allocate memory for headers, copy and coordinate systems
    */
    hdrId = _MALLOC( nbHdrs * 3, struct GRid );
    if( hdrId == NULL ) goto wrapup;

    status =
    om$send( msg      = message VDdrwTbl.VDgetTableParts(msg,
                                                         &nbHdrs,
                                                         hdrId),
             senderid = NULL_OBJID,
             targetid = tblId->objid,
             targetos = tblId->osnum );
    if( !(status&*msg&1) ) {
	UTAD_INFO("VDdrwTbl.VDgetTableParts");
	__DBGpr_com("VDdrwTbl.VDgetTableParts");
	goto wrapup;
    }

    /*
    ** copy header
    */
    cpyIds = &(hdrId[nbHdrs]);
    nbCpyHdrs = nbHdrs;

    for( i = 0 ; i < nbHdrs ; i++ )
    {
      cpyIds[i].osnum = hdrId[i].osnum;

      status =
      om$construct_and_copy(  objid   	      = hdrId[i].objid,
                              obj_osnum       = hdrId[i].osnum,
                              osnum           = hdrId[i].osnum,
                              p_objid         = &(cpyIds[i].objid) );
    }

    /*
    ** get the coordinate systems
    */
    csIds = &(hdrId[nbHdrs*2]);

    for( i = 0 ; i < nbHdrs ; i++ )
    {
      status =
      om$send( msg      = message VDdrwTblHdr.ACfind_temp_obj((int *)msg,
                                                              "cs",
                                                              &(csIds[i])),
	       senderid = NULL_OBJID,
               targetid = hdrId[i].objid,
               targetos = hdrId[i].osnum );
      if( !(status&*msg&1) ) 
      {
	UTAD_INFO("VDdrwTblHdr.ACfind_temp_obj");
	__DBGpr_com("VDdrwTblHdr.ACfind_temp_obj failed");
	goto wrapup;
      }

      status =
      om$send( msg      = message NDmacro.ACreturn_foot(msg,
							"",
                                                        &(csIds[i]),
                                                        NULL,
							NULL),
	       senderid = NULL_OBJID,
               targetid = csIds[i].objid,
               targetos = csIds[i].osnum );
      if( !(status&*msg&1) ) 
      {
	 UTAD_INFO("NDmacro.ACreturn_foot");
	 __DBGpr_com("NDmacro.ACreturn_foot failed");
	 goto wrapup;
      }
    }

    nbCs = nbHdrs;

    /*
    ** connect new parent nodeId to table header
    */
    if( nodeIds )
    {
      status = VDdrw_connectToNewParent( msg,
                                         nodeIds,
					 nbNodes,
                                         hdrId[0],
                                         mod_env );
    }

    /*
    ** Check the table records and return it.
    */
    status = VDdrw_checkTableRecords( msg, tblId, &tblRec );
    if( !(status&*msg&1) ) 
    {
	UTAD_INFO("VDdrw_checkTableRecords");
	__DBGpr_com("VDdrw_checkTableRecords failed");
	goto wrapup; 
    }

    /*
    ** Retrieve existing row info. in the table
    */
    status = VDdrw_retrieveTableRowInfo( msg,
					 tblId,
					 &lastRowNos,
					 &splitLocs,
					 &nbOldRows,
					 &oldRows );
    if( !(status&*msg&1) )
    {
	UTAD_INFO("VDdrw_retrieveTableRowInfo");
	__DBGpr_com("VDdrw_retrieveTableRowInfo failed");
	goto wrapup; 
    }

    /*
    ** Set table rows and objects (order and properties)
    */
    if( UTAD_dbg )
    {
        fprintf(UTAD_fp, "\n###### Rows information after review #####\n");
        for( i = 0; i < newCnt; i++ )
        {
           VDtblPrintPrcInfo( newList +i );
        }
    }
    status = VDdrw_setRowsAndObjs (	msg, 
					&tblRec,
					(usrOpt & VD_TBL_APP_NEW),
					newList,
					newCnt,
					oldRows, 
					nbOldRows, 
					&rows, 
					&nbRows, 
					&locObject,
					&totalCnt,
					&nbAddRows);

    if( !(status&*msg&1) )
    {
	UTAD_INFO("VDdrw_setRowsAndObjs");
	__DBGpr_com("VDdrw_setRowsAndObjs failed");
	goto wrapup;
    }

    /*
    ** CR6391, set row attributes from feet
    */
    VDtblSetAttrForLnOutRows( tblId );

    /*
    ** disconnect rows from the existing table
    */
    for( i = 0 ; i < nbHdrs ; i++ )
    {
      /*
      ** erase the header
      */
      dpmode = GRbe;
      status =
      om$send( msg      = message GRgraphics.GRdisplay(
                                                msg,
                                                &mod_env.md_env.matrix_type,
                                                mod_env.md_env.matrix,
                                                &dpmode,
                                                &mod_env.md_id),
              senderid = NULL_OBJID,
              targetid = hdrId[i].objid,
              targetos = hdrId[i].osnum );

      status =
      om$send( msg      = message VDdrwTblHdr.VDgetRowInfo(msg,
                                                           &nbHdrRows,
                                                           &startRowNo),
 	       senderid = NULL_OBJID,
               targetid = hdrId[i].objid,
               targetos = hdrId[i].osnum );
      if( !(status&*msg&1) ) continue;

      __DBGpr_int( "i", i );
      __DBGpr_int( "\tNumber of rows in header", nbHdrRows );
      __DBGpr_int( "\tStart row number", startRowNo );

      /*
       * delete existing rows that are not in the new row list
       */
      for( j = nbHdrRows-1 ; j >= 0 ; j-- )
      {
        rowNo = startRowNo + j;

	status =
	om$send( msg	  = message VDdrwTblHdr.VDrowNoToGRid (	msg,
								rowNo,
								&rowId),
		 senderid = NULL_OBJID,
                 targetid = hdrId[i].objid,
                 targetos = hdrId[i].osnum );
        if( !(status&*msg&1) ) continue;

	delFlag = 0;

        status =
        om$send( msg      = message VDdrwTblHdr.VDremoveRow(msg,
                                                            delFlag,
                                                            &rowNo,
                                                            NULL),
		 senderid = NULL_OBJID,
                 targetid = hdrId[i].objid,
                 targetos = hdrId[i].osnum );
        //if( !(status&*msg&1) ) goto wrapup;
      }
    }

    tmpNbObjs = 0;
    ind = nbHdrs - 1;
    while( ind > 0 && nbRows <= splitLocs[ind-1] )
    {
      /* 
      ** first disconnect the header from the table object 
      */
      status =
      om$send( msg      = message VDdrwTbl.VDremoveHeaders(
                                                msg,
                                                1,
                                                &hdrId[ind]),
               senderid = NULL_OBJID,
               targetid = tblId->objid,
               targetos = tblId->osnum );
      if( !(status&*msg&1) ) {
	  UTAD_INFO("VDdrwTbl.VDremoveHeaders");
	  __DBGpr_com("VDdrwTbl.VDremoveHeaders");
	  goto wrapup;
      }

      status =
      om$send( msg      = message VDdrwTblHdr.VDdeleteHdr(msg),
   	       senderid = NULL_OBJID,
               targetid = hdrId[ind].objid,
               targetos = hdrId[ind].osnum );

      tmpNbObjs++;
      ind--;
    }

    if( tmpNbObjs > 0 )
    {
      nbHdrs   -= tmpNbObjs;
      nbCpyHdrs = nbHdrs;
      nbCs      = nbHdrs;
      splitLocs[nbHdrs-1] = nbRows;
    }

    UI_status( "WARNING: Do not hit the stop button" );

    for( i = 0 ; i < nbRows ; i++ )
    {
	if( rows[i].flag == VD_DRW_ROW_OLD ) rows[i].flag = VD_DRW_ROW_MOD;
    }

    /*
    ** get current osnum
    */
    ex$get_cur_mod( osnum = &os );

    /*
    ** make a GRid array using the PrcInfo array of total objects
    */
    if( totalCnt )
    {
      gridList = _MALLOC( totalCnt, struct GRid );
      if( !gridList )
      {
        *msg = VD_ERROR;
        goto wrapup;
      }

      for( i = 0 ; i < totalCnt ; i++ )
      {
        gridList[i] = locObject[i].obj_id;
	__DBGpr_obj("gridList", gridList[i]);
      }
    }

    /*
    ** construct row object if it is null
    */

    prop = AChdr_nodisplay | AChdr_noprotect | AChdr_nocompute;

    UI_status("Constructing Table Rows...");
    for( i = 0 ; i < nbRows ; i++ )
    {
      /*
      ** if row has been modified, set up the templates correctly
      */
      percent = 100*(1+i)/nbRows;
      if( !(percent%10) ) {
         sprintf( szmsg, "Constructing Table Rows %d%s", percent, "%" );
         UI_status( szmsg );
      }

      if( rows[i].flag == VD_DRW_ROW_MOD )
      {
        isLinedOut = 0;
        status =
        om$send( msg      = message VDdrwTblRow.VDisRowLinedOut(msg,
                                                                &isLinedOut),
                 senderid = NULL_OBJID,
                 targetid = rows[i].rowId.objid,
		 targetos = rows[i].rowId.osnum );
        CheckRC( status, *msg );
        if( isLinedOut )
        {
          rows[i].flag = VD_DRW_ROW_OLD;
        }
        else
        {
          /*
	  ** get collector id 
	  */
          status =
          om$send( msg      = message ACcpx.ACfind_temp_obj((int *)msg,
                                                            "coll",
                                                            &collId),
		   senderid = NULL_OBJID,
                   targetid = rows[i].rowId.objid,
                   targetos = rows[i].rowId.osnum );
          if( !(status&*msg&1) ) 
	  {
	     UTAD_INFO("ACcpx.ACfind_temp_obj");
	     goto wrapup;
	  }

          __DBGpr_obj( "collector id", collId );

          /*
	  ** empty collector 
	  */
          status =
	  om$send( msg      = message ACrg_collect.ACset_list_attribute(
								msg,
                                                                0,
								NULL),
		   senderid = NULL_OBJID,
                   targetid = collId.objid,
                   targetos = collId.osnum );
          if( !(status&*msg&1) ) 
	  {
	     UTAD_INFO("ACcpx.ACfind_temp_obj");
	     goto wrapup;
	  }

          /*
	  ** get parent setId 
	  */
   	  setId.objid = NULL_OBJID;
          status =
	  om$send( msg      = message VDdrwTblRow.VDgetParentSetId(msg,
                                                                   &setId),
		   senderid = NULL_OBJID,
                   targetid = rows[i].rowId.objid,
                   targetos = rows[i].rowId.osnum );

          /*
	  ** if there is no parent set (general table rows), continue
  	  */
          if( !(status&*msg&1) ) continue;

          __DBGpr_obj( "parent set id", setId );

          /*
          ** empty set
 	  */
          status = 
	  om$send( msg      = message VDdrwSet.VDemptySet(msg),
	  	   senderid = NULL_OBJID,
                   targetid = setId.objid,
                   targetos = setId.osnum );
          if( !(status&*msg&1) ) 
	  {
	     UTAD_INFO("ACcpx.ACfind_temp_obj");
	     goto wrapup;
	  }

          /*
	  ** update the delete of support only elements
	  */
          nd$exec_batch();

          if( !rows[i].nbObjs ) continue;

          /*
          ** add the appropriate parents
          */
          status =
 	  om$send( msg      = message VDdrwSet.VDaddObjectsToSet(
                                        msg,
                                        rows[i].nbObjs,
                                        &gridList[rows[i].startIndex]),
		   senderid = NULL_OBJID,
                   targetid = setId.objid,
                   targetos = setId.osnum );
          if( !(status&*msg&1) )
	  {  
	     UTAD_INFO("VDdrwSet.VDaddObjectsToSet");
	     goto wrapup;
	  }

          /*
          ** Add attributes to row object
          */
	  status = VDdrw_getTableRowAttr( msg,
					  i,
					  gridList,
					  rows,
					  &nbAttr,
					  &Attr );
	  if( !(status&*msg&1) )
	  {
	     UTAD_INFO("VDdrw_getTableRowAttr");
	     goto wrapup;
	  }

  	  status =
          om$send( msg      = message ACrg_collect.ACset_list_attribute(
                                                                msg,
                                                                nbAttr,
                                                                Attr),
                   senderid = NULL_OBJID,
                   targetid = collId.objid,
                   targetos = collId.osnum );
          if( !(status&*msg&1) ) 
	  {
	     UTAD_INFO("ACcpx.ACfind_temp_obj");
	     goto wrapup;
	  }

	  _FREE( Attr );
          Attr = NULL;
          nbAttr = 0;
        }
      }

      if( (rows[i].rowId.objid == NULL_OBJID) && 
	  (rows[i].nbObjs > 0) )
      {
        /*
 	** must construct the row object
 	*/
        rows[i].rowId.osnum = os;

        status =
        om$construct( classid = OPP_VDdrwTblRow_class_id,
                      osnum   = rows[i].rowId.osnum,
                      p_objid = &(rows[i].rowId.objid),
                      msg     = message VDdrwTblRow.VDinitTblRow(msg) );
    	CheckRC( status, 1 );

        __DBGpr_obj( "Table row id", rows[i].rowId );

        if( rows[i].rowId.objid == NULL_OBJID )
        {
	  UTAD_INFO("om$construct");
          *msg = VD_ERROR;
          goto wrapup;
        }

        /*
        ** Construct and initialize the parent set objects if needed.
        ** Initialize the templates
        */

        /*
	** must construct the set object
	*/
        setId.osnum = os;
        setId.objid = NULL_OBJID;

        status =
        om$construct( classid = OPP_VDdrwSet_class_id,
                      osnum   = setId.osnum,
                      p_objid = &(setId.objid),
                      msg     = message VDdrwSet.VDinitSet(msg) );
	CheckRC( status, 1 );

        if( setId.objid == NULL_OBJID )
        {
	  UTAD_INFO("om$construct");
          *msg = VD_ERROR;
          goto wrapup;
        }

        __DBGpr_obj( "Constructed set id", setId );

        /*
	** add the row objects to the set
 	*/
        status =
	om$send( msg      = message VDdrwSet.VDaddObjectsToSet(
                                        msg,
                                        rows[i].nbObjs,
                                        &gridList[rows[i].startIndex]),
	         senderid = NULL_OBJID,
                 targetid = setId.objid,
                 targetos = setId.osnum );
	if( !(status&*msg&1) )
	{
	   UTAD_INFO("VDdrwSet.VDaddObjectsToSet");
	   goto wrapup;
	}

        /*
        ** Add attributes to row object
        */
	status = VDdrw_getTableRowAttr( msg,
			  		i,
					gridList,
					rows,
					&nbAttr,
					&Attr );
	if( !(status&*msg&1) )
	{
	   UTAD_INFO("VDdrw_getTableRowAttr");
	   goto wrapup;
	}

        /*
	** initialize row object with the templates
	*/
        status =
	om$send( msg      = message VDdrwTblRow.VDcreate(
                                                        msg,
                                                        nbAttr,
                                                        Attr,
                                                        "VDdrwTblRow",
                                                        prop,
                                                        1,
                                                        &setId),
		 senderid = NULL_OBJID,
                 targetid = rows[i].rowId.objid,
             	 targetos = rows[i].rowId.osnum );
        if( !(status&*msg&1) )
	{
	   UTAD_INFO("VDdrwTblRow.VDcreate");
	   goto wrapup;
	}

	_FREE( Attr );
        Attr = NULL;
      }
    }
    UI_status( "Constructing rows done" );

    /*
    ** Recover user overwrtten values if applied
    */
    if( (usrOpt&VD_TBL_USR_VAL) && xtblId && xtblId->objid != NULL_OBJID )
    {
	status = VDdrw_recoverUsrVals( msg, xtblId, gridList, rows, nbRows );
    }

    if( UTAD_dbg ) 
    {
	fprintf(UTAD_fp, "\n###### Rows before reset item numbers #####\n");
	for( i = 0; i < nbRows; i++ ) 
	{
	   VDtblPrintRowInfo( &rows[i] );
	}
    }

    /*
    ** Set item number for each row if applied
    */

    VDdrw_setItemNo( xtblId, gridList, rows, nbRows, nbAddRows, usrOpt );

    if( UTAD_dbg ) 
    {
	fprintf(UTAD_fp, "\n###### Rows after reset item numbers #####\n");
	for( i = 0; i < nbRows; i++ ) 
	{
	   VDtblPrintRowInfo( &rows[i] );
	}
    }

    /*
    ** more rows may have been added in the form, all the excess rows
    ** will be accomodated in the last header.  The number of rows in
    ** the first nbHdrs-1 will be the same as before.
    **
    ** if rows are deleted, then, old row numbers may exceed the nbRows value
    ** So, retain the larger of the two values.
    */
    if( lastRowNos[nbCpyHdrs-1] < nbRows )
        lastRowNos[nbCpyHdrs-1] = nbRows - 1;

    splitLocs[nbHdrs-1] = nbRows;

    /*
    ** construct/compute/move each row object
    */
    UI_status("Computing Table Rows...");
    hdrInd = 0;
    for( i = 0 ; i < nbRows ; i++ )
    {
      percent = 100*(1+i)/nbRows;
      if( !(percent%10) ) {
         sprintf( szmsg, "Computing Table Rows %d%s", percent, "%" );
         UI_status( szmsg );
      }

      if( i+1 > splitLocs[hdrInd] ) hdrInd++;

      IGEresetstop();

      if( rows[i].rowId.objid != NULL_OBJID )
      {
        if( rows[i].flag == VD_DRW_ROW_NEW )
        {
          /*
  	  ** set up the qty computation structure
 	  */
          status =
          om$send( msg      = message VDdrwTblRow.VDputQtyExpr(msg,
                                                               rows[i].qty),
                   senderid = NULL_OBJID,
                   targetid = rows[i].rowId.objid,
                   targetos = rows[i].rowId.osnum );
	  CheckRC( status, *msg );

          /*
          ** construct the row
          */
          status =
          om$send( msg      = message VDdrwTblHdr.VDaddAndConstructRows(
                                                        msg,
                                                        1,
                                                        &rows[i].rowId),
                   senderid = NULL_OBJID,
                   targetid = hdrId[hdrInd].objid,
                   targetos = hdrId[hdrInd].osnum );
          if( !(status&*msg&1) ) 
	  {
	     UTAD_INFO("ACcpx.ACfind_temp_obj");
	     goto wrapup;
	  }
        }
        else if( rows[i].flag == VD_DRW_ROW_MOD )
        {
          /*
	  ** set up the qty computation structure
	  */
	  status =
          om$send( msg      = message VDdrwTblRow.VDputQtyExpr(msg,
                                                               rows[i].qty),
                   senderid = NULL_OBJID,
                   targetid = rows[i].rowId.objid,
                   targetos = rows[i].rowId.osnum );
	  CheckRC( status, *msg );

          /*
	  ** insert the row and recompute it
 	  */
          newFlag = 2;

          status =
	  om$send( msg      = message VDdrwTblHdr.VDinsertRow(
                                                        msg,
                                                        &newFlag,
                                                        i+1,
                                                        rows[i].rowId,
                                                        NULL,
							NULL),
		   senderid = NULL_OBJID,
                   targetid = hdrId[hdrInd].objid,
                   targetos = hdrId[hdrInd].osnum );
          if( !(status&*msg&1) )
	  {
	     UTAD_INFO("VDdrwTblHdr.VDinsertRow");
	     goto wrapup;
	  }
        }
        else if( rows[i].flag == VD_DRW_ROW_OLD )
        {

	  struct GRid *pretend;

          /*
          ** must move the row
          */

#if 0	  /* remove this part for CR6391 */

          /*
	  ** get the old row number
	  */
          status =
  	  om$send( msg      = message VDdrwTblRow.VDgetRowNumber(msg,
                                                                 &rowNo),
		   senderid = NULL_OBJID,
                   targetid = rows[i].rowId.objid,
                   targetos = rows[i].rowId.osnum );
          if( !(status&*msg&1) )
	  {
	     UTAD_INFO("VDdrwTblRow.VDgetRowNumber");
	     goto wrapup;
	  }

          __DBGpr_int( "Old row number ", rowNo );

          /*
	  ** get the copy header index for this row
	  */

          cpyInd = 0;
          while( rowNo > lastRowNos[cpyInd] )
            cpyInd++;

          __DBGpr_int( "Copy header index", cpyInd );

          /* 
	  ** get the old corner point for the row
	  */

          status =
          om$send( msg      = message VDdrwTblHdr.VDgetCornerPointForRow(
							msg,
                                                        rowNo,
                                                        oldPoint),
		   senderid = NULL_OBJID,
                   targetid = cpyIds[cpyInd].objid,
                   targetos = cpyIds[cpyInd].osnum );

          if( !(status&*msg&1) )
	  {
	      UTAD_INFO("VDdrwTblHdr.VDgetCornerPointForRow");
	      goto wrapup;
	  }

          /* 
	  ** get row height
	  */
          status =
	  om$send( msg      = message VDdrwTblHdr.VDgetRowHeight(
                                                        msg,
                                                        rowNo,
                                                        &rowHeight),
		   senderid = NULL_OBJID,
                   targetid = cpyIds[cpyInd].objid,
                   targetos = cpyIds[cpyInd].osnum );
          if( !(status&*msg&1) )
	  {
	     UTAD_INFO("VDdrwTblHdr.VDgetRowHeight");
	     goto wrapup;
	  }

          __DBGpr_dbl( "Old row Height ", rowHeight );

          /*
	  ** convert oldPoint to world coordinates 
	  */
          __DBGpr_obj( "Cs objid", csIds[cpyInd] );

          status =
	  om$send( msg      = message GRgencs.GRcvt_to_wld_coords(msg,
                                                                  csType,
                                                                  1,
                                                                  oldPoint,
                                                                  oldWldPnt),
		   senderid = NULL_OBJID,
                   targetid = csIds[cpyInd].objid,
                   targetos = csIds[cpyInd].osnum );
          if( !(status&*msg&1) ) 
	  {
	     UTAD_INFO("GRgencs.GRcvt_to_wld_coords");
	     goto wrapup;
	  }

          newFlag = 0;
#endif
          newFlag = 2;	/* CR6391, let lined out row editable */

          __DBGpr_obj( "Header id to insert row", hdrId[hdrInd] );

          status =
	  om$send( msg      = message VDdrwTblHdr.VDinsertRow(
                                                        msg,
                                                        &newFlag,
                                                        i+1,
                                                        rows[i].rowId,
							NULL,
							NULL ),
							/* replaced for CR6391
                                                        &rowHeight,
                                                        oldWldPnt),
							*/
		   senderid = NULL_OBJID,
                   targetid = hdrId[hdrInd].objid,
                   targetos = hdrId[hdrInd].osnum );
          if( !(status&*msg&1) )
	  {
	     UTAD_INFO("VDdrwTblHdr.VDinsertRow");
	     goto wrapup;
	  }

          /*
	  ** get parent setId 
	  */
 	  setId.objid = NULL_OBJID;
          status =
	  om$send( msg      = message VDdrwTblRow.VDgetParentSetId(msg,
                                                                   &setId),
		   senderid = NULL_OBJID,
                   targetid = rows[i].rowId.objid,
                   targetos = rows[i].rowId.osnum );

          /*
	  ** if there is no parent set (general table rows), continue
  	  */
          if( (status&*msg&1) && (setId.objid != NULL) )
	  {
            __DBGpr_obj( "parent set id", setId );
	    tmpNbObjs = 0;
	    status =
            om$send( msg      = message NDnode.NDget_objects(
							 ND_ROOT | ND_IN_BUF,
                                                         NULL,
                                                         0,
                                                         &pretend,
                                                         0,
                                                         OM_K_MAXINT,
                                                         &tmpNbObjs),
                     senderid = NULL_OBJID,
                     targetid = setId.objid,
                     targetos = setId.osnum );

            if( tmpNbObjs > 0 )
 	    {
	      status =
              om$send( msg      = message NDnode.NDdisconnect(tmpNbObjs,
							      pretend),
		       senderid = NULL_OBJID,
                       targetid = setId.objid,
                       targetos = setId.osnum );
	    }

            /*
	    ** update the delete of support only elements
	    */
            nd$exec_batch();
	  }
        }
      }
    }

    /*
    ** reconstruct the trailers 
    */
    for( i = 0 ; i < nbHdrs ; i++ )
    {
      /* 
      ** the last one is a trailer 
      */
      if( i == nbHdrs-1 )
            trlType = VD_DRWLO_EN_TRAILER;

      status =
      om$send( msg      = message VDdrwTblHdr.VDputConstructInfo(msg,
                                                                 NULL,
                                                                 &trlType,
                                                                 &cnstType),
       	       senderid = NULL_OBJID,
               targetid = hdrId[i].objid,
               targetos = hdrId[i].osnum );
      if( !(status&*msg&1) ) 
      {
	UTAD_INFO("VDdrwTblHdr.VDputConstructInfo");
	goto wrapup;
      }

      status =
      om$send( msg      = message VDdrwTblHdr.VDconstructHdrTrl(msg),
 	       senderid = NULL_OBJID,
               targetid = hdrId[i].objid,
               targetos = hdrId[i].osnum );
      if( !(status&*msg&1) )
      {
	 UTAD_INFO("VDconstructHdrTrl");
	 goto wrapup;
      }
    }

    /*
     * remove and delete row objects if they are MAGRATE and lined out 
     * but corresponding new added rows have the same pcmks.
     *  by ylong for TR3309
     */
    VDdrw_removeLinedOutRow (msg, newCnt, newList, nbRows, rows);

    VDdrw_removeInvalidRow (msg, newCnt, newList, nbRows, rows);

    status = OM_S_SUCCESS;
    *msg   = OM_S_SUCCESS;
    UI_status( "Done..." );


wrapup:
    VD_drwlo_iclose( msg );
    VD_crsrt_iclose( msg );
    VD_crsum_iclose( msg );
    VD_adsym_iclose( msg );

    _FREE( rows );
    _FREE( oldRows );
    _FREE( lastRowNos );
    _FREE( splitLocs );
    _FREE( locObject );
    _FREE( hdrId );
    _FREE( Attr );
    _FREE( gridList );

    if( UTAD_dbg )
    {
	
       if( !(status&*msg&1) ) fprintf(UTAD_fp, "\n#### Update Table Failed  ####\n");
       else fprintf(UTAD_fp, "\n#### Update Table is done successfully ####\n");
    }
    End
    return status;
} /* VDdrw_processTableObjects */

/*+fe
 -------------------------------------------------------------------------
  Function VDdrw_getTblSrc

  Abstract

	get table info about what command was used to generate the table,
	"Create Table by Stage", "Create Table by Imput" or "Create Table"

  Arguments

	struct	GRid		tblId		I	table id
	IGRlong			*tblSrc		O	table type
  Returns
        OM_S_SUCCESS    = if success
        OM_E_ABORT      = if error
 ------------------------------------------------------------------------- -fe*/
IGRlong	VDdrw_getTblSrc( struct GRid tblId, IGRlong *tblSrc )
{
    IGRlong		status = 0, msg;
    IGRint		nbHdrs = 0;
    struct GRid		collId, *hdrIds = NULL;
    struct ACrg_coll	attr;
    

    if( tblId.objid == NULL_OBJID || !tblSrc ) goto wrapup;
    *tblSrc = 0;

    nbHdrs = 0;
    status =
    om$send( msg      = message VDdrwTbl.VDgetTableParts(&msg,
                                                         &nbHdrs,
                                                         NULL),
	     senderid = NULL_OBJID,
             targetid = tblId.objid,
             targetos = tblId.osnum );
    if( !(status&msg&1) || (nbHdrs < 1) ) 
    {
	UTAD_INFO("VDdrwTbl.VDgetTableParts");
	goto wrapup;
    }

    if((hdrIds = _MALLOC( nbHdrs, struct GRid )) == NULL ) goto wrapup;
    
    status =
    om$send( msg      = message VDdrwTbl.VDgetTableParts(&msg,
                                                         &nbHdrs,
                                                         hdrIds),
             senderid = NULL_OBJID,
    	     targetid = tblId.objid,        
             targetos = tblId.osnum );
    if( !(status&msg&1) || (nbHdrs < 1) ) 
    {
	UTAD_INFO("VDdrwTbl.VDgetTableParts");
	goto wrapup;
    }
    if( hdrIds[0].objid == NULL_OBJID ) goto wrapup;

    status =
    om$send (	msg      = message ACcpx.ACfind_temp_obj((int *)&msg,
                                                        "coll",
                                                        &collId),
		senderid = NULL_OBJID,
		targetid = hdrIds[0].objid,
		targetos = hdrIds[0].osnum );
    if( !(status&msg&1) ) 
    {
	UTAD_INFO("ACcpx.ACfind_temp_obj");
	goto wrapup;
    }
    
    /*
     * If table created by stage ?
     */
    strcpy( attr.name, "node_path" );
    status =
    om$send (	msg      = message ACrg_collect.ACget_named_attribute(
                                              &msg,
                                              &attr),
		senderid = NULL_OBJID,
		targetid = collId.objid,
		targetos = collId.osnum );
    if( status&msg&1 )
    {
	*tblSrc = VD_CMD_STBL_PL;
        status = OM_S_SUCCESS;
        goto wrapup;
    }
	
    /*
     * If table created by import ?
     */
    strcpy( attr.name, "file_name" );
    status =
    om$send (	msg      = message ACrg_collect.ACget_named_attribute(
                                              &msg,
                                              &attr),
		senderid = NULL_OBJID,
		targetid = collId.objid,
		targetos = collId.osnum );
    if( status&msg&1 )
    {
	*tblSrc = VD_CMD_ITBL_PL;
        status = OM_S_SUCCESS;
        goto wrapup;
    }
	
    /*
     * else table created by Place Table Header/Create Table
     */
    *tblSrc = VD_CMD_TBL_HDR;
	
    status = OM_S_SUCCESS;
wrapup:
    _FREE(hdrIds);
    return status;
}

end implementation Root;
