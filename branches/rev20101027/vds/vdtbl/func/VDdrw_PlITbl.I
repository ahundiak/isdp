/* $Id: VDdrw_PlITbl.I,v 1.20 2001/10/02 16:09:54 paul_noel Exp $  */

/* I/VDS
 * -------------------------------------------------------------------------
 *
 * File:        vdtbl/func/VDdrw_PlITbl.I
 *
 * Description:
 *	Functions used by the "Create Table by Import" command.
 *		VDdrw_placeImportTable
 *		VDtbl_getASCIIrows
 *
 * Dependencies:
 *
 * History:
 *	04/19/01	ylong		Created for CR5006
 *
 * -------------------------------------------------------------------------
 */

class implementation Root;

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <math.h>

#include "VDmaster.h"

#include "igrtypedef.h"
#include "OMerrordef.h"
#include "OMtypes.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMmacros.h"

#include "EMSmsgdef.h"
#include "exmacros.h"
#include "grdpbmacros.h"

#include "v_miscmacros.h"
#include "v_dbgmacros.h"
#include "v_datamacros.h"

#include "VDdrwlo.h"
#include "VDdrwlo_pr.h"
#include "VDtblCmdDef.h"
#include "vdtblmacros.h"

#include "ACattrib.h"
#include "ACrg_collect.h"
#include "macro.h"

#include "vddrwattr.h"
#include "vdparmacros.h"
#include "VDcompmacros.h"
#include "VDdrwtbl.h"
#include "VDCmdDef.h"
#include "v_drwprocess.h"
#include "vdtr_macros.h"
#include "VDassert.h"
#include "vdmiscmacros.h"
#include "VDexp.h"
#include "VDattrexp.h"

#include "FI.h"
#include "VDtblXml.h"

from NDnode		import NDget_objects;
from NDmacro		import ACreturn_foot;
from ACrg_collect	import AClist_attribute;
from VDdrwTbl		import VDgetTableParts,
			       VDgetTableLayoutName,
			       VDgetTotalNbOfRows;
from VDdrwTblHdr	import VDgetRowInfo,
			       VDremoveRow,
			       VDaddAndConstructRows,
			       VDgetCornerPointForRow,
			       VDputConstructInfo,
			       VDconstructHdrTrl,
			       VDgetRowHeight,
			       VDinsertRow,
			       VDrowNoToGRid;
from VDdrwTblRow	import VDgetParentObjectList,
			       VDgetQtyExpr,
			       VDgetRowNumber,
			       VDputQtyExpr,
			       VDisRowLinedOut,
			       VDinitTblRow,
			       VDcreate,
			       VDputUserDefRowFlag,
				VDgetItemNumber,
				VDputItemNumber,
			       VDgetParentSetId;
from VDdrwSet		import VDemptySet, 
			       VDaddObjectsToSet,
			       VDinitSet,
			       VDgetSetObjects;
from ACcpx		import ACfind_temp_obj;
from GRgencs		import GRcvt_to_wld_coords;
from VDdrwlo		import VDdrwlo_gtab;
from VDCmdPlHdr		import VDsetDefaultTblName;

extern IGRlong		VDdrw_addObjectsToTable();

IGRint VDtbl_getAnyrows( struct VDtblStImInfo	*tblInfo,
			 IGRchar              ***txtRows,
			 IGRint                  *nbRow);


/************************************************
 * 
 * get theMapped Delimited string out of the InputStr
 * based upon information from the mapInfo string 
 * comes from tblInfo string in the operations below
 * only applies to the Create Table by Inport command
 * note this only works right now with TXT tables
 *
 ************************************************/
IGRlong VDdrw_getMapDelStr(IGRchar              *inputStr,
			   IGRchar              *buffer,
			   struct VDtblStImInfo	*tblInfo )
{
  IGRint  retFlag     = 0;
  IGRint  i,j;
  IGRint  delCnt      = 0;
  IGRint  wkDelCnt    = 0;
  IGRint  mapPos      = 0;
  IGRint  strLen      = 0;
  IGRint  mapAlloc    = 0;
  IGRint  strItemsCnt = 0;
  IGRchar *p, sep[10],**strItems;
  GRname  buf,mapString,wkBuf;
  
  if(!inputStr) goto wrapup;
  if(!buffer) goto wrapup;

  /* copy across the input string to the output if we are doing nothing */
  strcpy(buffer,inputStr);

  /* handle the txt stuff here */
  if(!strcmp(tblInfo->mapInfo.type,VD_DRW_TYPE_TXT)) {
    strcpy(mapString,"");
    for(j = 0;j < tblInfo->mapInfo.rows;j++) {
      mapPos = atoi(tblInfo->mapInfo.maps[j]);
      printf("at VDdrwUnMakeSepDataString Location #1a\n");
      printf("inputStr[%s]\n",inputStr);
      printf("separator[%s]\n",tblInfo->separator);
      VDdrwUnMakeSepDataString(inputStr,
			       tblInfo->separator,
			       &strItems,
			       &strItemsCnt);
      printf("at VDdrwUnMakeSepDataString Location #1b\n");
      if(mapPos < strItemsCnt) {
	strcpy(buf,strItems[i]);
      } else {
	strcpy(buf," ");
      }
      if((!strcmp(buf,"")) && (mapPos == 0)) strcpy(buf," ");
      strcpy(wkBuf,buf);
      if(j > 0) {
	sprintf(wkBuf,"%s%s",sep,buf);
      }
      sprintf(mapString,"%s%s",mapString,wkBuf);
    }

    /* fill in the rest of the record */
    strcpy(buf," ");
    for(j = tblInfo->mapInfo.rows; j < delCnt+1;j++) {
      strcpy(wkBuf,buf);
      if(j > 0) {
	sprintf(wkBuf,"%s%s",sep,buf);
      }
      sprintf(mapString,"%s%s",mapString,wkBuf);
    }
    
    strcpy(buffer,mapString);
  } /* done working on txt item */

  /* handle the xml stuff */
  if(!strcmp(tblInfo->mapInfo.type,VD_DRW_TYPE_XML)) {
    /* no op for now put XML parser stuff here */
  }

  /* handle the ppl stuff */
  if(!strcmp(tblInfo->mapInfo.type,VD_DRW_TYPE_PPL)) {
    /* no op for now put PPL parser stuff here */
  }
  
  retFlag = 1;
wrapup:
  if(strItemsCnt > 0) _LOOPFREE( strItems,strItemsCnt);
  
  __DBGpr_com("<<< VDtbl_getMapDelStr\n");
  return retFlag;
  
}

/* gets the file data 
 * cleans it a bit for use later 
 */
IGRlong	VDtbl_getASCIIinput (	IGRchar	*filename, 
				IGRint	rowInd,
				IGRchar	***rowBuf, 
				IGRint	*nbRows,
				IGRint	colInd,
				IGRchar	**colBuf,
				IGRint	*nbCols,
				IGRchar	*layout,
				IGRchar	*separator )
{
	IGRlong		status = 0, msg;
	FILE		*fp = NULL;
	GRname		buf, colNos;
	IGRint		i, j, cnt = 0, rowCnt = 0, nb1 = 0, nb2 = 0;
	IGRchar		*ptr = NULL, *ptr1 = NULL, sep[12];
	IGRchar		tblLoName[128];
	IGRshort	cols[100], colCnt = 0, nbDatRecs = 0;
	IGRdouble	height;
	
		
	if( rowBuf ) *rowBuf = NULL;
	if( nbRows ) *nbRows = 0;
	if( colBuf ) *colBuf = NULL;
	if( nbCols ) *nbCols = 0;
	if( separator ) separator[0] = '\0';

	sep[0] = '\0';
	colNos[0] = '\0';

	if( !filename || filename[0] == '\0' ) goto wrapup;

	/*
	** open file
	*/
	fp = (FILE*)VD_openFile( &msg, filename, "r" );
	if( !(msg & 1) || fp == NULL ) {
		 __DBGpr_str("ASCII table file not found",filename);
                goto wrapup;
        }

	/*
	** get table layout, separator and count rows
	*/

	while( fgets( buf, DI_PATH_MAX, fp ) ) {
		VD_stripString(buf);
		if( !VD_wordcount( buf ) )  continue;

		/* get layout name */
		if( buf[0] == '%' && (ptr = strstr( buf, "Layout" )) ) {
		    if( ptr ) {
			ptr += (strlen( "Layout" ) + 2);
			VD_stripString(ptr);
			strcpy( tblLoName, ptr );
			while((ptr=strrchr(tblLoName, '\n'))) *ptr = '\0';
		    }
		    if( layout ) {
			strcpy( layout, tblLoName );
		    }
		}
				
		/* get selected column numbers */
		if( buf[0] == '%' && (ptr = strstr( buf, "Col " )) ) {
			if( (ptr = strchr( buf, '\'' )) ) strcpy(colNos, ++ptr);
			if( (ptr = strchr( colNos, '\'' )) ) *ptr = '\0';
			VD_stripString(colNos);
		}

		/* get selected columns */
		if( colBuf ) {
		    if( buf[0] == '%' && (ptr = strstr( buf, "Columns" )) ) {
			ptr = strchr( buf, '\'' );
			VD_stripString(ptr);
			*colBuf = _CALLOC( strlen( buf ) + 1, IGRchar );
			if( !(*colBuf) ) goto wrapup;
			strcpy( *colBuf, buf );
			ptr = strrchr( *colBuf, '\'' );
			if( ptr ) *ptr = '\0';
		    }
		}

		/* get separator */
		if( buf[0] == '%' && (ptr = strstr( buf, "Separator" )) ) {
			ptr = strchr( buf, '\'' );
                        if( ptr ) {
                                ++ptr;
                                strcpy( sep, ptr );
                                ptr = strrchr( sep, '\'' );
                                if( ptr ) *ptr = '\0';
                        }

			if( separator ) {
				strcpy( separator, sep );
		    	}
		}

		if( !rowBuf && !nbRows 
		     && buf[0] != '#' && buf[0] != '%' && !isspace( buf[0] ) )
		{
			break;
		}

		/* count rows */
		if( buf[0] != '#' && buf[0] != '%' && !isspace(buf[0]) ) {
			rowCnt++;
		}
	}

	if( rowInd < 0 ) {
		cnt = rowCnt;
	}
	else if( rowInd >= 0 && rowInd < rowCnt ) {
		cnt = 1;
	}
	else {
		printf("Row index is beyond the range\n");
		goto wrapup;
	}

	if( nbRows ) *nbRows = cnt;

	if( !rowBuf ) {
		status = 1;
		goto wrapup;
	}

	*rowBuf = _CALLOC( cnt, IGRchar * );
	if( *rowBuf == NULL ) {
		__DBGpr_com("_CALLOC failed for *rowBuf\n");
		goto wrapup;
	}

	rewind(fp);

	/*
	 * Map rowBuf 
	 */
	
	colCnt = 0;

	status = VD_drwlo_gdata(&msg,
				tblLoName,
				VD_DRWLO_EN_DATA,
				(double)0,
				(double)0,
				(short)0,
				NULL,
				&height,
				&nbDatRecs,
				NULL );

	if( colNos[0] != '\0' )  /* comply with original design */
	{
	   ptr = strtok( colNos, sep );
	   if( ptr ) nb1 = atoi( ptr );

	   for( i = 1; i < nb1; i++ ) {
		cols[colCnt] = 0;
		++colCnt;
	   }


	   while( ptr != NULL ) {
		nb1 = atoi( ptr );
		cols[colCnt] = 1;
		++colCnt;

		ptr = strtok( NULL, sep );
		if( ptr ) {
			nb2 = atoi( ptr );
		}
		else 	  nb2 = -1;

		for( i = 1; i < nb2-nb1; i++ ) {
			cols[colCnt] = 0;
			++colCnt;
		}
	   }

	   for( i = 0; i < nbDatRecs-nb1; i++ ) {
		cols[colCnt] = 0;
		++colCnt;
	   }
	}

	/*
	** read rows
	*/
	cnt = 0;
	while( fgets( buf, DI_PATH_MAX, fp ) ) {
		VD_stripString(buf);
		if( !VD_wordcount( buf ) )  continue;

		while(buf[strlen(buf)-1] == '\n' ) 
			buf[strlen(buf)-1] = '\0';
		if(buf[0] == '#' || buf[0] == '%' || buf[0] == '\0' ){
			continue;
		}

		if(rowInd >= 0 && rowInd == cnt) {
			(*rowBuf)[0] = 
				_CALLOC( (strlen(buf)+colCnt*(strlen(sep)+1)+2),
					 IGRchar );
			if( (*rowBuf)[0] == NULL ) {
				__DBGpr_com("_CALLOC failed for (*rowBuf)\n");
				goto wrapup;
			}
			else {
				strcpy( (*rowBuf)[0], buf );
				break;
			}
		}
		else if( rowInd < 0 ) {
			(*rowBuf)[cnt]  = 
				_CALLOC( (strlen(buf)+colCnt*(strlen(sep)+1)+2),
					 IGRchar );
			if( (*rowBuf)[cnt] == NULL ) {
				__DBGpr_com("_CALLOC failed for (*rowBuf)\n");
				goto wrapup;
			}
			strcpy( (*rowBuf)[cnt], buf );
		}
		
		cnt++;
	}

	/*
	 * Rebuild output buffers
	 */

	if( !colCnt ) {
		status = 1;
		goto wrapup;
	}

	for( i = 0; i < cnt; i++ ) {

		buf[0] = '\0';
		ptr = (*rowBuf)[i];
		if( !ptr ) continue;
		for( j = 0; j < colCnt; j++ ) {
			if( !cols[j] ) {
				strcat( buf, " " );
				strcat( buf, sep );
			}
			else if( ptr ) {
				ptr1 = strstr( ptr, sep );
				if( ptr1 ) {
					*ptr1 = '\0';
					ptr1 += strlen(sep);
				}
				if( VD_wordcount( ptr ) ) strcat( buf, ptr );
				else			  strcat( buf, " " );
				ptr = ptr1;
				if( ptr ) strcat( buf, sep );
			}
		}
		strcpy( (*rowBuf)[i], buf );
	}

	status = 1;
wrapup:
	if( fp ) fclose( fp );
	return status;
}


/*+fe
 -------------------------------------------------------------------------
  Function VDdrw_placeImportTable

  Abstract
        Function creates the table based on the inputs - table header
	object ID, table object ID and input ascii file 

  Arguments

        IGRlong         *msg            O       return code
	struct GRid	*tblId		I	table ID
	IGRchar		*filename	I	ascii file name
	IGRchar		*separator	I	separator 
	struct GRmd_env	*mod_env	I	Module environment 

  Returns
        OM_S_SUCCESS    = if success
        OM_E_ABORT      = if error
 -------------------------------------------------------------------------
-fe*/

IGRlong VDdrw_placeImportTable (	IGRlong			*msg,
					struct GRid		*tblId,
					struct GRmd_env		*mod_env,
					struct VDtblStImInfo	*tblInfo )
{
    IGRint		i, j, k, x;
    IGRlong		status;
    struct GRid		setId,
			*hdrId	= NULL,
			collId;
    IGRchar             **txtRows, 
			*buf	= NULL, 
			*txtP	= NULL, 
			*txt	= NULL, 
			*ptr	= NULL,
                        *p      = NULL,
                        **delStr = NULL,
			attName[40],
			szmsg[128],
			layoutName[VD_DRWLO_CHR_IDFLD],
			tblTypeName[VD_DRWLO_CHR_IDFLD];
		
    IGRint		ind = 0,
			hdrInd = 0,
			nbHdrs = 0,
			startRowNo = 0,
			nbRows = 0, 
			nbTxtRows = 0,
                        strLen = 0,
                        delStrCnt = 0,
                        rows_cnt = 0,
			syntaxerror;
    IGRshort		tblType,
			trlType		= VD_DRWLO_EN_BRKTRLR,
			cnstType	= VD_DRW_CNST_TRLR,
			nbDatRecs	= 0,
			prop;
    IGRdouble           height;
    VD_execRes		expVal;
    OMuword		os;
    struct VDdrwlo_tab		tblRec;
    struct VDdrwlo_data		*datRecs	= NULL;
    struct VDdrw_rowInfo	*rows		= NULL;



    SetProc( VDdrw_placeImportTable ); Begin

    *msg = MSSUCC;
    hdrId = NULL;
    status = 0;

    if( tblId == NULL ) {
	__DBGpr_com(" tblId is NULL\n");
	goto wrapup;
    }

    /* get the rows of any type */
    status = VDtbl_getAnyrows(tblInfo,
			      &txtRows,
			      &nbTxtRows);

    /* reorient the data to match the map of the table to be placed */
    VDtbl_getMapOrientData(tblInfo,
			   &txtRows,
			   &nbTxtRows);
    
    if( !(status&1) || nbTxtRows < 1) {
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
    if( !(status&*msg&1) || (nbHdrs == 0) ) {
	__DBGpr_com("VDdrwTbl.VDgetTableParts failed\n");
	goto wrapup;
    }

    hdrId = NULL;
    hdrId = _MALLOC( nbHdrs, struct GRid );
    if( hdrId == NULL ) goto wrapup;
    status =
    om$send( msg      = message VDdrwTbl.VDgetTableParts(msg,
                                                         &nbHdrs,
                                                         hdrId),
             senderid = NULL_OBJID,
             targetid = tblId->objid,
             targetos = tblId->osnum );
    if( !(status&*msg&1) ) {
	__DBGpr_com("VDdrwTbl.VDgetTableParts failed !!\n");
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
    if( !(status&*msg&1) ) {
	__DBGpr_com("VDdrwTbl.VDgetTotalNbOfRows failed\n");
	goto wrapup;
    }

    if( nbRows > 0 )
    {
      /*
      ** allocate memory for rows
      */
      rows = _MALLOC( nbRows, struct VDdrw_rowInfo );
      if( !rows ) {
	__DBGpr_com("_MALLOC( failed for rows\n");
	goto wrapup;
      }
    }

    /*
    ** Retrieve all existing rows
    */
    ind = 0;
    for( i = 0 ; i < nbHdrs ; i++ )
    {
      status =
      om$send( msg      = message VDdrwTblHdr.VDgetRowInfo(msg,
                                                           &nbRows,
                                                           &startRowNo),
               senderid = NULL_OBJID,
               targetid = hdrId[i].objid,
               targetos = hdrId[i].osnum );
      if( !(status&*msg&1) ) goto wrapup;

      for( j = startRowNo ; j < startRowNo+nbRows ; j++ )
      {
        status =
        om$send( msg      = message VDdrwTblHdr.VDrowNoToGRid(
                                                        msg,
                                                        j,
                                                        &rows[ind].rowId),
                 senderid = NULL_OBJID,
                 targetid = hdrId[i].objid,
                 targetos = hdrId[i].osnum );
        if( !(status&*msg&1) ) goto wrapup;

        rows[ind].nbObjs = 0;
	ind++;
      }
    }

    nbRows = ind;

    status =
    om$send( msg      = message VDdrwTbl.VDgetTableLayoutName(msg,
                                                              layoutName),
             senderid = NULL_OBJID,
             targetid = tblId->objid,
             targetos = tblId->osnum );
    if( !(status&*msg&1) ) {
	__DBGpr_com("VDdrwTbl.VDgetTableLayoutName failed\n");
	goto wrapup;
    }

    /*
    ** get the table record
    */
    status = VD_drwlo_gtab( msg, layoutName, &tblRec );
    if( !(status&*msg&1) ) {
	__DBGpr_com("VD_drwlo_gtab failed\n");
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
                             (short)VD_DRWLO_EN_DATA,
                             (double)0,
                             (double)0,
                             (short)0,
                             NULL,
                             &height,
                             &nbDatRecs,
                             NULL );
    if( !(status&*msg&1) ) {
	__DBGpr_com("VD_drwlo_gdata failed\n");
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
                               (short)VD_DRWLO_EN_DATA,
                               (double)0,
                               (double)0,
                               (short)0,
                               NULL,
                               &height,
                               &nbDatRecs,
                               datRecs );
      if( !(status&*msg&1) ) {
	__DBGpr_com("VD_drwlo_gdata failed\n");
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
          __DBGpr_int("Expression syntax error in column", datRecs[i].colno);
          syntaxerror = 1;
        }
      }
    }

    status = 0;
    if( syntaxerror )
    {
      status = GRconfirm_box (
	"There are expression syntax error, do you still want to update the table? ");

      if( !status )
      {
        status = VD_STATUS_ERROR;
        goto wrapup;
      }
      else
        status = VD_STATUS_OK;
    }

    /*
    ** Allocate the rows for new rows from ascii file
    */
    if( rows != NULL ) rows = _REALLOC( rows, nbTxtRows, struct VDdrw_rowInfo );
    else rows = _MALLOC( nbTxtRows, struct VDdrw_rowInfo );
    if( rows == NULL ) goto wrapup;

    for( i = nbRows; i < nbRows + nbTxtRows; i ++ ) {     
      rows[i].rowId.objid = NULL_OBJID;
      rows[i].nbObjs = 0;
      rows[i].startIndex = i;
      rows[i].qty.nSflag = VD_DRWLO_EN_COUNT;
      rows[i].qty.szExp[0] = '\0';
      rows[i].flag = VD_DRW_ROW_NEW;
    }

    nbRows += nbTxtRows;


    /*
    ** need sum and sort functions here for ascii rows !! Do it later
    */

    /*
    ** get current osnum
    */
    ex$get_cur_mod( osnum = &os );

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
        ** initialize row object with just the rg-collector
        */
	setId.objid = NULL_OBJID;
        status = om$send( msg      = message VDdrwTblRow.VDcreate(
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
        if( !(status&*msg&1) ) {
		__DBGpr_com("VDdrwTblRow.VDcreate failed\n");
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

        status = om$send( msg      = message VDdrwTblRow.ACfind_temp_obj(
                                                                (IGRint *)msg,
                                                                "coll",
                                                                &collId ),
			senderid = NULL_OBJID,
			targetid = rows[i].rowId.objid,
			targetos = rows[i].rowId.osnum );
	if( !(status&*msg&1) ) {
		__DBGpr_com("VDdrwTblRow.ACfind_temp_obj failed\n");
		goto wrapup;
	}
	
        /*
	** set collector
	** scan txtRows: AAA|BBB|CCC|DDD
        */
	_FREE( buf );
	buf = _CALLOC( (strlen(txtRows[i]) + 1), char);	
	if( buf == NULL ) goto wrapup;
	strcpy(buf, txtRows[i]);
	txtP = buf;
	x = 0;
	
	while ( txtP ) {
	   ptr = strstr( txtP, tblInfo->separator);
	   if( ptr != NULL )
	   {
	       *ptr = '\0';
	       VD_stripString( txtP );
	       sprintf( attName, "%d %d", ++x, 1);
	       status = VDputAttInColl( msg, collId, attName, txtP );
	       CheckRC( status, *msg );

	       txtP = ptr + strlen( tblInfo->separator );
	   }
	   else
           {
	       sprintf( attName, "%d %d", ++x, 1 );
	       status = VDputAttInColl( msg, collId, attName, txtP );
	       CheckRC( status, *msg );
		txtP = NULL;
	   }
	}
    }

    UI_status( "Done setting up the col values in the row" );

    /*
    ** construct/compute/move each row object
    */
    hdrInd = 0;
    for( i = 0 ; i < nbRows ; i++ )
    {
        if( rows[i].flag != VD_DRW_ROW_NEW ) continue;

        sprintf( szmsg, "Constructing Table Row: i = %d", i );
        UI_status( szmsg );

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
        if( !(status&*msg&1) ) goto wrapup;

    }
    UI_status( "Complete Contructing Table Row" );

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
      if( !(status&*msg&1) ) goto wrapup;

      status =
      om$send( msg      = message VDdrwTblHdr.VDconstructHdrTrl(msg),
               senderid = NULL_OBJID,
               targetid = hdrId[i].objid,
               targetos = hdrId[i].osnum );
      if( !(status&*msg&1) ) goto wrapup;
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
    _FREE( buf );
    _FREE( txt );
    _FREE( hdrId );
    _FREE( datRecs );
    _LOOPFREE( txtRows, nbRows );
    
    End
    return status;
}

IGRlong	VDdrw_ITBLsetFormByImport (	Form	form, 
					IGRchar	*impFile )
{
	IGRlong		status = 0, msg;
	IGRshort	sel, nbLayouts = 0;
	IGRint		i;
	IGRchar		separator[80], buf[DI_PATH_MAX], *ptr = NULL;
	IGRchar		nbLoStr[8] = "",
			(*loDescs)[VD_DRWLO_CHR_DESC] = NULL,
			(*loNames)[VD_DRWLO_CHR_IDFLD] = NULL;
	GRname		layout;
	VDosnum		osnum;
	struct GRid	layoutID;
	struct VDdrwlo_tab	tblRec;

	if( !form || !impFile || impFile[0] == '\0' ) goto wrapup;

	vd$astbl_getRowData (	filename	= impFile,
				layout		= layout,
				separator	= separator);


	if( separator[0] != '\0' ) {
		FIg_set_text( form, VD_ITBL_SEPARATOR_FLD, separator );
	}

	if( layout[0] == '\0' ) goto wrapup;

	layoutID.objid = NULL_OBJID;

	ex$get_cur_mod(osnum = &osnum);

	vd$tbldlo_old ( msg	= &msg,
                        osnum	= osnum,
                        tabnam	= layout,
                        GRid	= &layoutID);
        if( !(msg&1) || layoutID.objid == NULL_OBJID ) goto wrapup;

	status =
        om$send(msg      = message VDdrwlo.VDdrwlo_gtab ( &msg, &tblRec ),
		senderid = NULL_OBJID,
		targetid = layoutID.objid,
		targetos = layoutID.osnum );
	if( !(status&msg&1) ) goto wrapup;

	FIg_set_text( form, VD_HDR_TBL_TYPE_FLD, tblRec.Tabtyp );

	status = vd$tbldlo_idx(     msg     = &msg,
                                    status  = status,
                                    osnum   = osnum,
                                    typin   = tblRec.Tabtyp,
                                    p_count = &nbLayouts);

        __CheckRC( status, msg, "vd$tbldlo_idx ", wrapup );
        __DBGpr_int( "No of layouts found", nbLayouts );

        if( !nbLayouts ) {
             goto wrapup;
        }

        loNames = (IGRchar (*)[VD_DRWLO_CHR_IDFLD]) malloc(
                          sizeof(IGRchar) * VD_DRWLO_CHR_IDFLD * nbLayouts );
        loDescs = (IGRchar (*)[VD_DRWLO_CHR_DESC]) malloc(
                          sizeof(IGRchar) * VD_DRWLO_CHR_DESC * nbLayouts );
        if( !loNames  || !loDescs)
        {
              goto wrapup;
        }

	status = vd$tbldlo_idx( msg     = &msg,
                                status  = status,
                                osnum   = osnum,
                                typin   = tblRec.Tabtyp,
                                p_nams  = ((char *)loNames),
                                p_desc  = ((char *)loDescs),
                                p_count = &nbLayouts);

	__CheckRC( status, msg, "vd$tbldlo_idx : list", wrapup );

	sprintf( nbLoStr, "%d", nbLayouts );

	FIfld_set_num_rows( form, VD_HDR_FMT_LIST_FLD, 0 );
	FIg_erase( form, VD_HDR_NB_FMTS_TXT );
	FIg_set_text( form, VD_HDR_NB_FMTS_TXT, nbLoStr );
	FIg_display( form, VD_HDR_NB_FMTS_TXT );

	for( i = 0 ; i < nbLayouts  ; i++ )
	{
		if( !strcmp( layout, loNames[i]) ) {
			FIfld_set_active_row(form, VD_HDR_FMT_LIST_FLD, i, 1 );
			sel = 1;
		}
		else {
			sel = 0;
		}
		FIfld_set_text(form, VD_HDR_FMT_LIST_FLD, i, 0, loNames[i],sel);
		FIfld_set_text(form, VD_HDR_FMT_LIST_FLD, i, 1, loDescs[i],sel);
	}

	status = 1;
wrapup:
	_FREE( loNames );
	_FREE( loDescs );
	return status;
	
}
					
/************************************************
 *
 * Get ASCII or XML table rows
 * may be other types in the future
 *
 ************************************************/
IGRint VDtbl_getAnyrows(struct VDtblStImInfo	*tblInfo,
			 IGRchar              ***txtRows,
			 IGRint                  *nbRow)
{
  IGRint retFlag = 0;
  IGRint sts = 0,i;
  IGRchar buf[128];
  TGRid   xmlTreeID,xmlOutTreeID,xslTreeID;
  
  __DBGpr_com(">>> VDtbl_getAnyrows");
  /* init the values */
  xmlTreeID.objid = NULL_OBJID;
  xslTreeID.objid = NULL_OBJID;
  xmlOutTreeID.objid = NULL_OBJID;

  /* do a really basic check */
  if(!strcmp(tblInfo->importFile,"")) goto wrapup;
  
  /* do an XML check */
  sts = VDdrw_CheckIfXML(tblInfo->importFile);
  
  if(sts == 0) {
    /* not xml files */
    retFlag = vd$astbl_getRowData (	filename	= tblInfo->importFile,
					rowBuf		= txtRows,
					nbRows		= nbRow );

  } else {
    /* xml files */
    if(!strcmp(tblInfo->styleSheet,"")) {
      /* if this is already OPE format xml */
      
    retFlag = vd$xmltbl_getRowData (xmlFile         = tblInfo->importFile,
				    separator       = tblInfo->separator,
				    rowBuf          = txtRows,
				    nbRows          = nbRow);
    } else {
      /* if this is not OPE format xml */
      /* make an xmlTreeID */
      VDxdomCreateTreeFromXmlFile   (tblInfo->importFile,&xmlTreeID);
      if(xmlTreeID.objid == NULL_OBJID) goto wrapup;
      /* make an xslTreeID */
      VDxdomCreateStyleSheetFromFile(tblInfo->styleSheet,&xslTreeID);
      if(xslTreeID.objid == NULL_OBJID) goto wrapup;

      /* make an xmlOutTreeID */
      VDxdomApplyStyleSheet(&xslTreeID,&xmlTreeID,NULL,&xmlOutTreeID);
      if(xmlOutTreeID.objid == NULL_OBJID) goto wrapup;

      retFlag = vd$xmltbl_getRowData (xtreeID         = &xmlOutTreeID,
				      separator       = tblInfo->separator,
				      rowBuf          = txtRows,
				      nbRows          = nbRow);
      
    }
    
  }

  wrapup:
  if(xmlTreeID.objid != NULL_OBJID)    VDxdomDeleteNode(&xmlTreeID);
  if(xslTreeID.objid != NULL_OBJID)    VDxdomDeleteStyleSheet(&xslTreeID);
  if(xmlOutTreeID.objid != NULL_OBJID) VDxdomDeleteNode(&xmlOutTreeID);

  
  __DBGpr_com("<<< VDtbl_getAnyrows");
  
  return retFlag;
  
}

/**********************************************************
 *
 * Reorient the text lines to the map
 *
 **********************************************************/
IGRint VDtbl_getMapOrientData(struct VDtblStImInfo *tblInfo,
			      IGRchar            ***txtRows,
			      IGRint               *nbTxtRows)

{
  IGRint retFlag = 0;
  IGRint sts = 0,i;
  IGRchar buf[128];
 __DBGpr_com(">>> VDtbl_getMapOrientData");
  /* check the data */
  if(!txtRows) goto wrapup;
  if(*nbTxtRows < 1) goto wrapup;
  VDdrwApplyMapToDataStrs(txtRows,
			  nbTxtRows,
			  tblInfo->separator,
			  tblInfo->mapInfo.maps,
			  tblInfo->mapInfo.rows);
    
  wrapup:
 __DBGpr_com("<<< VDtbl_getMapOrientData");
  return retFlag;
}

end implementation Root;
