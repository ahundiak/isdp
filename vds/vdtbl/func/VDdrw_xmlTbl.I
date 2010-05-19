/* $Id: VDdrw_xmlTbl.I,v 1.2 2001/10/10 17:46:58 ylong Exp $ */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdtbl/func/VDdrw_xmlCrTbl.I
 *
 * Description:
 *	Implementation of the following method for VDCmdPlHdr :
 *		placeTblHdr
 *
 * Dependencies:
 *
 * History:
 *
 *	10/10/01	ylong		CREATION
 * -------------------------------------------------------------------*/

class implementation Root;

#include "VDmaster.h"

#include "VDdrwlo.h"
#include "VDdrwlo_pr.h"
#include "VDdrwtbl.h"
#include "VDctx.h"

#include "VDattrexp.h"
#include "VDCmdDef.h"
#include "VDtblCmdDef.h"
#include "VDtblXml.h"

extern IGRint		getNewName();

extern GRclassid	OPP_VDdrwTbl_class_id,
			OPP_VDdrwTblHdr_class_id;

extern ASmake_source_from_env();
extern IGRlong VDtblCmdGetIndexTableType();
extern IGRlong VDdrw_placeStageTable();

from GRgraphics		import	GRchgname;

from VDdrwTbl		import	VDinitTbl,
				VDgetTableParts,
				VDgetTotalNbOfRows,
				VDgetTableLayoutName,
				VDaddHeaders,
				VDputTableType,
				VDputAdsTblName,
				VDputTableLayoutName;

from VDdrwTblHdr	import	VDinitTblHdr,
				VDaddAndConstructRows,
				VDgetRowInfo,
				VDrowNoToGRid,
				VDputTableInfo,
				VDputConstructInfo,
				VDputCsLocation,
				VDsetMatrixFromCS,
				VDcreate,
				VDconstructHdrTrl;
from	VDdrwTblRow	import	VDgetParentObjectList,
				VDgetQtyExpr,
				VDgetRowNumber,
				VDputQtyExpr,
				VDisRowLinedOut,
				VDinitTblRow,
				VDputUserDefRowFlag,
				VDgetItemNumber,
				VDputItemNumber,
				VDgetParentSetId;
from	NDmacro	import		ACreturn_foot;
from	ACcpx	import		ACfind_temp_obj;

/*+fe
 ---------------------------------------------------------------------------
  Function VDdrw_crTblRowsByXml

  Abstract
        Function creates table rows by OPE xml

  Arguments

	struct GRid		*xdomId		I	xdom object
	struct GRid		*tblId		I	table object
	struct GRmd_env		*mod_env	I	object env

  Status/Return Code
      status == OM_S_SUCCESS
 ---------------------------------------------------------------------------
-fe*/

IGRlong	VDdrw_crTblRowsByXml (	struct GRid	*xdomId,
				struct GRid	*tblId,
				struct GRmd_env	*mod_env)
{
    IGRint		i, j, k, x;
    IGRlong		status, msg;
    struct GRid		setId,
			*hdrIds	= NULL,
			collId;
    IGRchar             **txtRows, 
			*colBuf = NULL,
			*buf	= NULL, 
			*txtP	= NULL, 
			*ptr	= NULL,
			attName[40],
			szmsg[1024],
			separator[11],
			loName[VD_DRWLO_CHR_IDFLD],
			tblTypeName[VD_DRWLO_CHR_IDFLD];
		
    IGRint		ind = 0,
			hdrInd = 0,
			nbHdrs = 0,
			startRowNo = 0,
			nbRows = 0, 
			nbCols = 0, 
			nbTxtRows = 0,
			syntaxerror;
    IGRshort		tblType,
			trlType		= VD_DRWLO_EN_BRKTRLR,
			cnstType	= VD_DRW_CNST_TRLR,
			nbDatRecs	= 0,
			nbFixRecs	= 0,
			nbRecs		= 0,
			prop;
    IGRdouble           height;
    VD_execRes		expVal;
    OMuword		os;
    struct VDdrwlo_tab		tblRec;
    struct VDdrwlo_apifix	*fixRecs	= NULL;
    struct VDdrwlo_data		*datRecs	= NULL;
    struct VDdrw_rowInfo	*rows		= NULL;

    SetProc( VDdrw_crTblRowsByXml ); Begin

    msg = MSSUCC;
    status = 0;
    strcpy( separator, "|" );

    if( tblId == NULL ) {
	__DBGpr_com(" tblId is NULL\n");
	goto wrapup;
    }

    status = vd$xmltbl_getRowData (	xtreeID		= xdomId,
					separator	= separator,
					rowBuf		= &txtRows,
					nbRows		= &nbTxtRows,
					colBuf		= &colBuf,
					nbCols		= &nbCols);
    if( !(status&1) ) {
	__DBGpr_com("vd$xmltbl_getRowData failed\n");
	goto wrapup;
    }

    if( nbTxtRows < 1 || txtRows == NULL ) goto wrapup;

    /*
    ** get number of table parts(headers)
    */
    nbHdrs = 0;
    status =
    om$send( msg      = message VDdrwTbl.VDgetTableParts(&msg,
                                                         &nbHdrs,
                                                         NULL),
	     senderid = NULL_OBJID,
             targetid = tblId->objid,
             targetos = tblId->osnum );
    if( !(status&msg&1) || (nbHdrs == 0) ) {
	__DBGpr_com("VDdrwTbl.VDgetTableParts failed\n");
	goto wrapup;
    }

    hdrIds = NULL;
    hdrIds = _MALLOC( nbHdrs, struct GRid );
    if( hdrIds == NULL ) goto wrapup;
    status =
    om$send( msg      = message VDdrwTbl.VDgetTableParts(&msg,
                                                         &nbHdrs,
                                                         hdrIds),
             senderid = NULL_OBJID,
             targetid = tblId->objid,
             targetos = tblId->osnum );
    if( !(status&msg&1) ) {
	__DBGpr_com("VDdrwTbl.VDgetTableParts failed !!\n");
	goto wrapup;
    }

    /*
    ** Retrive total No. of rows in the table
    */
    status =
    om$send( msg      = message VDdrwTbl.VDgetTotalNbOfRows(&msg,&nbRows),
             senderid = NULL_OBJID,
             targetid = tblId->objid,
             targetos = tblId->osnum );
    if( !(status&msg&1) ) {
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
      om$send( msg      = message VDdrwTblHdr.VDgetRowInfo(&msg,
                                                           &nbRows,
                                                           &startRowNo),
               senderid = NULL_OBJID,
               targetid = hdrIds[i].objid,
               targetos = hdrIds[i].osnum );
      if( !(status&msg&1) ) goto wrapup;

      for( j = startRowNo ; j < startRowNo+nbRows ; j++ )
      {
        status =
        om$send( msg      = message VDdrwTblHdr.VDrowNoToGRid(
                                                        &msg,
                                                        j,
                                                        &rows[ind].rowId),
                 senderid = NULL_OBJID,
                 targetid = hdrIds[i].objid,
                 targetos = hdrIds[i].osnum );
        if( !(status&msg&1) ) goto wrapup;

        rows[ind].nbObjs = 0;
	ind++;
      }
    }

    nbRows = ind;

    status =
    om$send( msg      = message VDdrwTbl.VDgetTableLayoutName(&msg,
                                                              loName),
             senderid = NULL_OBJID,
             targetid = tblId->objid,
             targetos = tblId->osnum );
    if( !(status&msg&1) ) {
	__DBGpr_com("VDdrwTbl.VDgetTableLayoutName failed\n");
	goto wrapup;
    }

    /*
    ** get the table record
    */
    status = VD_drwlo_gtab( &msg, loName, &tblRec );
    if( !(status&msg&1) ) {
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
    ** get the fixed records
    */
    status = VD_drwlo_gfix( &msg,
                            loName,
                            VD_DRWLO_EN_DATA,
                            (double)0,
                            (double)0,
                            (short)0,
                            NULL,
                            &height,
                            &nbFixRecs,
                            NULL );
    if( !(status&msg&1) ) {
	__DBGpr_com("VD_drwlo_gfix failed\n");
	goto wrapup;
    }

    if( nbFixRecs > 0 )
    {
      fixRecs = _MALLOC( nbFixRecs, struct VDdrwlo_apifix );
      if( fixRecs == NULL ) goto wrapup;
    }
    else nbFixRecs = 0;

    if( nbFixRecs > 0 )
    {
      status = VD_drwlo_gfix( &msg,
                              loName,
                              VD_DRWLO_EN_DATA,
                              (double)0,
                              (double)0,
                              (short)0,
                              NULL,
                              &height,
                              &nbFixRecs,
                              fixRecs );
      if( !(status&msg&1) ) {
	__DBGpr_com("VD_drwlo_gfix failed\n");
	goto wrapup;
      }
    }

    /*
    ** get the list of data records
    */
    status = VD_drwlo_gdata( &msg,
                             loName,
                             (short)VD_DRWLO_EN_DATA,
                             (double)0,
                             (double)0,
                             (short)0,
                             NULL,
                             &height,
                             &nbDatRecs,
                             NULL );
    if( !(status&msg&1) ) {
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
      status = VD_drwlo_gdata( &msg,
                               loName,
                               (short)VD_DRWLO_EN_DATA,
                               (double)0,
                               (double)0,
                               (short)0,
                               NULL,
                               &height,
                               &nbDatRecs,
                               datRecs );
      if( !(status&msg&1) ) {
	__DBGpr_com("VD_drwlo_gdata failed\n");
	goto wrapup;
      }
    }

    nbRecs = nbDatRecs;
    for( i = 0; i < nbFixRecs; i++ ) {
      if( fixRecs[i].rectyp == VD_DRWLO_EN_TEXT ) {
	nbRecs++;
      }
    }

    /*
    ** Table layout and xml input match check
    */
    if( nbRecs < nbCols ) {
      strcpy( szmsg, "The number of columns from layout is greater than ");
      strcat( szmsg, "your data columns. ");
      strcat( szmsg, "Do you still want to place the table?");
      status = GRconfirm_box ( szmsg );
      szmsg[0] = '\0';

      if( !status )
      {
        status = VD_STATUS_ERROR;
        goto wrapup;
      }
      else
        status = VD_STATUS_OK;
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
	"There are expression syntax error, do you still want to place the table? ");

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
                      msg     = message VDdrwTblRow.VDinitTblRow(&msg) );
        CheckRC( status, 1 );

        __DBGpr_obj( "Table row id", rows[i].rowId );

	 if( rows[i].rowId.objid == NULL_OBJID )
        {
          msg = VD_ERROR;
          goto wrapup;
        }


        /*
        ** initialize row object with just the rg-collector
        */
	setId.objid = NULL_OBJID;
        status = om$send( msg      = message VDdrwTblRow.VDcreate(
                                                        &msg,
                                                        0,
                                                        NULL,
                                                        "VDdrwTblRow",
                                                        prop,
                                                        0,
                                                        &setId),
                   senderid = NULL_OBJID,
                   targetid = rows[i].rowId.objid,
                   targetos = rows[i].rowId.osnum );
        if( !(status&msg&1) ) {
		__DBGpr_com("VDdrwTblRow.VDcreate failed\n");
		goto wrapup;
	}

        /*
        ** set user defined row flag
        */
        status =
        om$send( msg      = message VDdrwTblRow.VDputUserDefRowFlag
                                                      (&msg, 1),
                 senderid = NULL_OBJID,
                 targetid = rows[i].rowId.objid,
                 targetos = rows[i].rowId.osnum );
        CheckRC( status, msg );

        status = om$send( msg      = message VDdrwTblRow.ACfind_temp_obj(
                                                                (IGRint *)&msg,
                                                                "coll",
                                                                &collId ),
			senderid = NULL_OBJID,
			targetid = rows[i].rowId.objid,
			targetos = rows[i].rowId.osnum );
	if( !(status&msg&1) ) {
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
	   ptr = strstr( txtP, separator);
	   if( ptr != NULL )
	   {
	       *ptr = '\0';
	       VD_stripString( txtP );
	       sprintf( attName, "%d %d", ++x, 1);
	       status = VDputAttInColl( &msg, collId, attName, txtP );
	       CheckRC( status, msg );

	       txtP = ptr + strlen( separator );
	   }
	   else
           {
	       sprintf( attName, "%d %d", ++x, 1 );
	       status = VDputAttInColl( &msg, collId, attName, txtP );
	       CheckRC( status, msg );
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
        om$send( msg      = message VDdrwTblRow.VDputQtyExpr(&msg,
                                                             rows[i].qty),
                 senderid = NULL_OBJID,
                 targetid = rows[i].rowId.objid,
                 targetos = rows[i].rowId.osnum );
        CheckRC( status, msg );

        /*
        ** construct the row
        */
        status =
        om$send( msg      = message VDdrwTblHdr.VDaddAndConstructRows(
                                                        &msg,
                                                        1,
                                                        &rows[i].rowId),
                 senderid = NULL_OBJID,
                 targetid = hdrIds[hdrInd].objid,
                 targetos = hdrIds[hdrInd].osnum );
        if( !(status&msg&1) ) goto wrapup;

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
      om$send( msg      = message VDdrwTblHdr.VDputConstructInfo(&msg,
                                                                 NULL,
                                                                 &trlType,
                                                                 &cnstType),
               senderid = NULL_OBJID,
               targetid = hdrIds[i].objid,
               targetos = hdrIds[i].osnum );
      if( !(status&msg&1) ) goto wrapup;

      status =
      om$send( msg      = message VDdrwTblHdr.VDconstructHdrTrl(&msg),
               senderid = NULL_OBJID,
               targetid = hdrIds[i].objid,
               targetos = hdrIds[i].osnum );
      if( !(status&msg&1) ) goto wrapup;
    }

    status = OM_S_SUCCESS;
    msg   = OM_S_SUCCESS;
    UI_status( "Done..." );


wrapup:
    
    VD_drwlo_iclose( &msg );
    VD_crsrt_iclose( &msg );
    VD_crsum_iclose( &msg );
    VD_adsym_iclose( &msg );

    _FREE( rows );
    _FREE( buf );
    _FREE( colBuf );
    _FREE( hdrIds );
    _FREE( datRecs );
    _FREE( fixRecs );
    _LOOPFREE( txtRows, nbRows );
    
    End
    return status;

}


/*+fe
 ---------------------------------------------------------------------------
  Function VDdrw_crTblByXml

  Abstract
        Function creates table by OPE xml, API for vd$tbl_createByXml()

  Arguments

	struct GRobj_env	*csOE		I	coordinate
	IGRshort		csLocation	I	cs location
	IGRchar			*loName		I	table layout
	IGRchar			*xmlFile	I	xml file name (opt)
	IGRchar			*xmlBuf		I	xml buffer (opt)
	struct GRid		*xtblId		I	xdom object (opt)
	IGRchar			*xslFile	I	xsl file name (opt)
	IGRchar			*xslBuf		I	xsl buffer (opt)
	struct GRid		*xslId		I	xsl object (opt)
	struct GRid		*table 		O	table id (opt)

  Status/Return Code
      status == OM_S_SUCCESS
 ---------------------------------------------------------------------------
-fe*/

IGRlong VDdrw_crTblByXml (	struct GRobj_env	*csOE,
				IGRshort		csLocation,
				IGRchar			*loName,
				IGRchar			*xmlFile,
				IGRchar			*xmlBuf,
				struct GRid		*xtblId,
				IGRchar			*xslFile,
				IGRchar			*xslBuf,
				struct GRid		*xslId,
				struct GRid		*table )
{
    IGRint		partNo = 1;
    IGRshort		prop,
			hdrType = VD_DRWLO_EN_HEADER,
			trlType = VD_DRWLO_EN_TRAILER,
			cnstType = VD_DRW_CNST_HDR;
    IGRlong		status = OM_S_SUCCESS,
			msg;
    IGRchar		*ptr = NULL,
			layoutName[DI_PATH_MAX],
			dirName[DI_PATH_MAX],
			occName[DI_PATH_MAX],
			fileName[DI_PATH_MAX],
			pwdName[DI_PATH_MAX],
			xmlPath[MAXPATHLEN],
			xslPath[MAXPATHLEN];
    OMuword		os;
    struct GRid		tblId,
			hdrId,
			roots[2],
			xdomId,
			xmlId,
			stId,
			dirObj;
    struct VDdrwlo_tab	tblRec;
    struct GRmd_env     mod_env;
    struct ACrg_coll	*Attr  = NULL;
    IGRint		nbAttr = 0;
    IGRint		size = sizeof( struct GRmd_env );
    IGRint		i, cnt = 0;
   

    SetProc( VDCmdPlHdr.placeTblHdr ); Begin

    msg = VD_SUCCESS;
    pwdName[0] ='\0';
    occName[0] ='\0';
    xmlPath[0] = '\0';
    xslPath[0] = '\0';
    xdomId.objid = NULL_OBJID;
    xmlId.objid = NULL_OBJID;
    stId.objid = NULL_OBJID;

    /* check input coordinate system */
    if( !csOE || csOE->obj_id.objid == NULL_OBJID ) {
	goto wrapup;
    }

    /* check input table layout */
    if( !loName || loName[0] == '\0' ) {
	goto wrapup;
    }

    /* check input xml */
    if( xmlFile && xmlFile[0] != '\0' ) {
	status = vd$file_path( msg			= &msg,
			fileToFind			= xmlFile,
			dirToSearchFirst		= ".",
			dirInProdPathToSearchThen	= "config/xml",
			absPathName			= xmlPath );
	if( !(status&msg&1) || xmlPath[0] == '\0' ) {
	  printf("Could not find xml file %s\n", xmlFile);
	  goto wrapup;
	}

	VDxdomCreateTreeFromXmlFile( xmlPath, &xdomId );
    }
    else if( xmlBuf && xmlBuf[0] != '\0' ) {
	VDxdomCreateTreeFromXmlBuf( xmlBuf, &xdomId );
    }
    else if( xtblId && xtblId->objid != NULL_OBJID ) {
	xdomId = *xtblId;
    }

    if( xdomId.objid == NULL_OBJID ) goto wrapup;

    /* check input xsl */
    if( xslFile && xslFile[0] != '\0' ) {
	status = vd$file_path( msg			= &msg,
			fileToFind			= xslFile,
			dirToSearchFirst		= ".",
			dirInProdPathToSearchThen	= "config/xslt",
			absPathName			= xslPath );
	if( !(status&msg&1) || xslPath[0] == '\0' ) {
		printf("Could not find style sheet file %s\n", xslFile);
	}
	else {
		VDxdomCreateStyleSheetFromFile( xslPath, &stId );
	}
    }
    else if( xslBuf && xslBuf[0] != '\0' ) {
	VDxdomCreateTreeFromXmlBuf( xslBuf, &stId );
    }
    else if( xslId && xslId->objid != NULL_OBJID ) {
	stId = *xslId;
    }

    if( xdomId.objid == NULL_OBJID ) goto wrapup;
    /* get current osnum */
    ex$get_cur_mod( osnum = &os );

    /* get current directory */
    status = di$pwd( dirname = pwdName );
    if( status != DIR_S_SUCCESS ){
	printf(" Can't get current directory name \n");
	goto wrapup;
    }

    __DBGpr_int( "Current osnum", os );

    /* get table record */

    strcpy( layoutName, loName);
    status = VD_drwlo_gtab( &msg, layoutName, &tblRec );
    __CheckRC( status, msg, "VD_drwlo_gtab", wrapup );

    /* construct the table object */

    tblId.osnum = os;
    tblId.objid = NULL_OBJID;
    status =
    om$construct(	classid	= OPP_VDdrwTbl_class_id,
			osnum	= tblId.osnum,
			p_objid	= &tblId.objid,
			msg	= message VDdrwTbl.VDinitTbl( &msg ) );
    __CheckRC( status, 1, "construct VDdrwTbl", wrapup );

    __DBGpr_obj( "Table id", tblId );

    if( tblId.objid == NULL_OBJID ) {
	goto wrapup;
    }

    /* create directory ":<filename>:usr:drw_tables" if not present */
    VDosGetFileName( os, fileName );
    if( fileName[0] == '\0' ) {
        __DBGpr_com( "File name is empty" );
	goto wrapup;
    }
    sprintf( dirName, ":%s:usr:drw_tables", fileName );

    __DBGpr_str( "Directory name", dirName );

    status = di$translate(	objname	= dirName,
				osnum	= os,
				p_objid	= &dirObj.objid,
				p_osnum	= &dirObj.osnum );

    if( status != DIR_S_SUCCESS )
    {
	status = di$mkdir(	dirname	= dirName,
				osnum	= os,
				p_dirid	= &dirObj.objid,
				p_osnum	= &dirObj.osnum );
	CheckRC( status, 1 );
    }
 
    status = di$cd( dirname = dirName );
    if( status != DIR_S_SUCCESS ){
	printf(" Can't go to directory: %s \n", dirName );
	goto wrapup;
    }

    /* get current env */
    status = gr$get_module_env(	msg     = &msg,
				sizbuf  = &size,
				buffer  = &mod_env );

    /* name it */
    status = getNewName( layoutName , dirName , occName );
    __DBGpr_str( "Occc name ", occName );
    sprintf( dirName, "%d:%d", occName );

    status =
    om$send (	msg	 = message GRgraphics.GRchgname (	&msg, 
								&mod_env, 
								occName ),
		senderid = NULL_OBJID,
		targetid = tblId.objid,
		targetos = tblId.osnum );
    CheckRC( status, msg );
 
    /* put table layout name */
    status =
    om$send (  msg      = message VDdrwTbl.VDputTableLayoutName( &msg, 
							          loName ),
		senderid = NULL_OBJID,
		targetid = tblId.objid,
		targetos = tblId.osnum );
    CheckRC( status, msg );

    /* put table type */
    status =
    om$send (   msg      = message VDdrwTbl.VDputTableType(&msg,tblRec.Tabtyp),
		senderid = NULL_OBJID,
		targetid = tblId.objid,
		targetos = tblId.osnum );
    CheckRC( status, msg );

    /* construct the table header object */
    hdrId.osnum = os;
    hdrId.objid = NULL_OBJID;
 
    status =
    om$construct(	classid	= OPP_VDdrwTblHdr_class_id,
			osnum	= hdrId.osnum,
			p_objid	= &hdrId.objid,
			msg	= message VDdrwTblHdr.VDinitTblHdr( &msg ) );

    __CheckRC( status, 1, "construct VDdrwTbl", wrapup );

    __DBGpr_obj( "Table Header id", hdrId );

    if( hdrId.objid == NULL_OBJID )
	goto wrapup;

    /* put table info */
    status =
    om$send (	msg	 = message VDdrwTblHdr.VDputTableInfo( 	&msg,
							loName,
							&partNo,
							&tblRec.direct ) ,
		senderid = NULL_OBJID,
		targetid = hdrId.objid,
		targetos = hdrId.osnum );
    __CheckRC( status, msg, "VDdrwTblHdr.VDputTableInfo", wrapup );

    /* put cs location */
    status =
    om$send (   msg      = message VDdrwTblHdr.VDputCsLocation( &msg,
							csLocation ), 
		senderid = NULL_OBJID,
		targetid = hdrId.objid,
		targetos = hdrId.osnum );
    __CheckRC( status, msg, "VDdrwTblHdr.VDputCsLocation", wrapup );

    /* put construct info : header, trailer, toConstruct types */

    status =
    om$send (   msg      = message VDdrwTblHdr.VDputConstructInfo(&msg,
							&hdrType,
							&trlType,
							&cnstType ),
		senderid = NULL_OBJID,
		targetid = hdrId.objid,
		targetos = hdrId.osnum );
    __CheckRC( status, msg, "VDdrwTblHdr.VDputConstructInfo", wrapup );

    /* create and initialize templates */

    ASmake_source_from_env(   &csOE->obj_id,
                              &csOE->mod_env,
                              &(roots[0]), 0 );

    prop = AChdr_nodisplay | AChdr_noprotect | AChdr_nocompute;

    /*
    ** set attributes into table header
    */
    if( xmlFile ) {
       nbAttr = ceil(((double)strlen(xmlFile))/(ATTR_TXT - 1));
       Attr = _MALLOC( nbAttr, struct ACrg_coll );

       if( Attr )
       {
	   for( i = 0; i < nbAttr; i++ ) 
	   {
             Attr[i].desc.type = AC_ATTRIB_TEXT;
	     cnt = i*(ATTR_TXT - 1);
	     strncpy (	Attr[i].desc.value.att_txt, 
			&xmlFile[cnt],  
			(ATTR_TXT - 1) );
	     sprintf(Attr[i].name, "xml_file_name%d", i);
   	   }

           strcpy( Attr[0].name, "xml_file_name" );
       }
       else
       {
           _FREE( Attr );
           Attr = NULL;
           nbAttr = 0;
       }
    }
    else if( xmlBuf ) {
       Attr = _MALLOC( 1, struct ACrg_coll );
       strcpy( Attr[0].name, "xml_buffer" );
       strcpy( Attr[0].desc.value.att_txt, xmlBuf );
    }
    else if( xtblId ) {
       Attr = _MALLOC( 1, struct ACrg_coll );
       strcpy( Attr[0].name, "xdom_object" );
       sprintf( Attr[0].desc.value.att_txt, "%s:%d", fileName, xtblId->objid );
    }

    status =
    om$send (	msg	 = message VDdrwTblHdr.VDcreate( &msg,
                                                nbAttr,
                                                Attr,
                                                "VDdrwTblHdr",
                                                prop,
                                                1,
                                                roots), 
		senderid = NULL_OBJID,
		targetid = hdrId.objid,
		targetos = hdrId.osnum );

    __CheckRC( status, msg, "VDdrwTblHdr.VDcreate", wrapup );

    /* construct the header */

    status =
    om$send (	msg	 = message VDdrwTblHdr.VDconstructHdrTrl( &msg ), 
		senderid = NULL_OBJID,
		targetid = hdrId.objid,
		targetos = hdrId.osnum );
    __CheckRC( status, msg, "VDdrwTblHdr.VDconstructHdrTrl", wrapup );

    /* update tMatrix */
    status =
    om$send (	msg	 = message VDdrwTblHdr.VDsetMatrixFromCS( &msg ),
		senderid = NULL_OBJID,
		targetid = hdrId.objid,
		targetos = hdrId.osnum );
    __CheckRC( status, msg, "VDdrwTblHdr.VDsetMatrixFromCS", wrapup );

    /* add the header object to the table */

    status =
    om$send (	msg	 = message VDdrwTbl.VDaddHeaders( &msg,
                                                  1,
                                                  &hdrId ),
		senderid = NULL_OBJID,
		targetid = tblId.objid,
		targetos = tblId.osnum );
    __CheckRC( status, msg, "VDdrwTbl.VDaddHeaders", wrapup );

    if( stId.objid != NULL_OBJID ) {
	VDxdomApplyStyleSheet ( &stId, &xdomId, NULL, &xmlId );
	if( xmlId.objid == NULL_OBJID ) {
	   UI_status("Failed to apply the style sheet to the xml input");
	   goto wrapup;
	}
    	status = VDdrw_crTblRowsByXml (	&xmlId, &tblId, &mod_env);
    }
    else {
    	status = VDdrw_crTblRowsByXml (	&xdomId, &tblId, &mod_env);
    }

    __CheckRC( status, msg, "VDdrw_placeStageTable", wrapup );

    if( table ) *table = tblId;

    status = OM_S_SUCCESS;

wrapup :

    _FREE(Attr);

    if( xmlId.objid != NULL_OBJID ) {
	VDctxDeleteNode( &xmlId );
    }

    if( !xtblId && xdomId.objid != NULL_OBJID ) {
	VDctxDeleteNode( &xdomId );
    }

    if( !xslId && stId.objid != NULL_OBJID ) {
	VDxdomDeleteStyleSheet( &stId );
    }

    if( pwdName[0] != '\0' ){
	status = di$cd( dirname = pwdName );
	if( status != DIR_S_SUCCESS ){
		printf(" Can't change working directory to : %s\n", pwdName );
	}
    }

    End
    return status;
}

end implementation Root;
