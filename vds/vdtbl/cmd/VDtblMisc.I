
/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdtbl/cmd / VDtblMisc.I
 *
 * Description:
 *      Implementation of the following methods for VDCmdCrTbl :
 *              my_init
 *              wrap_up
 *              setup_rowList
 *		get_tbl_format
 *		get_tbl_type
 *		get_existing_cs
 *		check_to_locate_cs
 *		validate_assoc_updmode
 *		VDvalidateItemNos
 *		VDrowToBeDeleted
 *		is_table_uptodate
 *
 * Dependencies:
 *
 * History:
 *
 *      04/14/95        R. Manem        Creation
 *      07/14/95        R. Manem        Att driven symbol support
 *      07/20/95        R. Manem        Added VDvalidateItemNos method,
 *					validate expression syntax
 *      07/24/95        R. Manem        Added validate_assoc_updmode method
 *      08/15/95        R. Manem        Save Form Location
 *      10/05/95        R. Manem        Free table layout buffers.
 *      10/10/95        R. Manem        Added is_table_uptodate method
 *      10/12/95        R. Manem        Modified is_table_uptodate method
 *					to remove minimal table update for now.
 *	08/17/00	Ming		for TR179901284
 *	05/22/01	ylong		TR5232
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
#include "exdef.h"
#include "exmacros.h"

#include "v_miscmacros.h"
#include "v_dbgmacros.h"
#include "v_datamacros.h"

#include "macro.h"
#include "nddef.h"
#include "ndmacros.h"

#include "VDdrwlo.h"
#include "VDdrwlo_pr.h"
#include "VDdrwtbl.h"
#include "VDtblCmdDef.h"

#include "v_slcdef.h"
#include "v_slc.h"
#include "VDattrexp.h"

#include "VDCmdDef.h"
#include "FI.h"
#include "FEI.h"
#include "VDobj.h"
#include "VDtblXml.h"

/* 
 * form positions for create/modify table and split table 
 * initialize them to the default form location
 */

%safe
    static int		crXpos = 3, crYpos = 106,
			spXpos = 3, spYpos = 106;
%endsafe

extern GRclassid	OPP_VDdrwTblRow_class_id,
			OPP_VDdrwSet_class_id;

from NDmacro		import	ACreturn_foot;
from VDdrwTblRow	import 	VDdeleteRow;
from VDdrwTblHdr	import	ACfind_temp_obj;
from VDdrwSet		import 	VDinitSet,
				VDaddObjectsToSet;

#define BUFLEN		100

/*+me
 ---------------------------------------------------------------------------
  Public Message my_init

  Abstract
        This method initializes instance data

  Arguments
        IGRlong         *sts            O       Return code

  Notes/Remarks

  Status/Return Code
      status == OM_S_SUCCESS    
 ---------------------------------------------------------------------------
-me*/

method  my_init ( long * sts )
{

    SetProc( VDCmdCrTbl.my_init ); Begin

    *sts = VD_SUCCESS;

    me->tblTypeName[0] = '\0';
    me->tblLayoutName[0] = '\0';
    me->adsTblName[0] = '\0';

    me->formState = VD_TBL_BLNK_DISP_ST;

    me->nbSelCols = 0;
    me->nbNewLocObjs = 0;

    if( me->mytype == CREATE_TABLE )
	FIg_set_text( VD_FP, VD_TBL_FORM_TITLE, "Create Table" );
    else if( me->mytype == MODIFY_TABLE )
	FIg_set_text( VD_FP, VD_TBL_FORM_TITLE, "Modify Table" );

    /* set form position */

    if( me->mytype == SPLIT_TABLE )
	FIf_set_location( VD_FP, spXpos, spYpos );
    else
	FIf_set_location( VD_FP, crXpos, crYpos );
    End
    return OM_S_SUCCESS;
}

/*+me
 ---------------------------------------------------------------------------
  Public Message wrap_up

  Abstract
        This method wraps up the command

  Arguments
        IGRlong         *sts            O       Return code

  Notes/Remarks

  Status/Return Code
      status == OM_S_SUCCESS    
 ---------------------------------------------------------------------------
-me*/

method  wrap_up ( long * sts )
{
    IGRint		i,
			nbHdrs;
    IGRlong		msg,
			status = OM_S_SUCCESS;

    SetProc( VDCmdCrTbl.wrap_up ); Begin

    *sts = VD_SUCCESS;

    /* delete the temporary copies of the table headers */

    nbHdrs = om$dimension_of( varray	= me->cpyHdrs );
    __DBGpr_int( "Number of copies of header ", nbHdrs );

    for( i = 0 ; i < nbHdrs ; i++ )
    {
	status = 
	_VD_SEND_OBJ( me->cpyHdrs[i], Root.delete( 0 ) );
	CheckRC( status, 1 );
    }

    /* store location of form */

    if( me->mytype == SPLIT_TABLE )
	FIf_get_location( VD_FP, &spXpos, &spYpos );
    else
	FIf_get_location( VD_FP, &crXpos, &crYpos );

    /* end of table layout interface */

    VD_drwlo_iclose( &msg );
    VD_crsrt_iclose( &msg );
    VD_crsum_iclose( &msg );
    VD_adsym_iclose( &msg );
    End
    return OM_S_SUCCESS;
}

/*+me
 ---------------------------------------------------------------------------
  Public Message setup_rowList

  Abstract
        This method sets up the row info list 

  Arguments
        IGRlong         *sts            O       Return code

  Notes/Remarks
        It increases the dimension of me->rows by the specified number,
        and initialized the list.

  Status Code
      status == OM_S_SUCCESS

  Return Code
      *sts =    VD_SUCCESS (if success)
                VD_ERROR (no memory)
 ---------------------------------------------------------------------------
-me*/

method setup_rowList(	long 	*sts )
{
    IGRint		i,
			objInd,
			nbElms,
			vlaSize;
    IGRlong		status = OM_S_SUCCESS;

    SetProc( VDCmdCrTbl.setup_rowList ); Begin

    *sts = VD_SUCCESS;

    nbElms = me->nbNewLocObjs;
    __DBGpr_int( "Number of newly located objs ", nbElms );

    vlaSize = om$dimension_of( varray	= me->rows );
    __DBGpr_int( "Old size of me->rows ", vlaSize );

    vlaSize += nbElms;
    __DBGpr_int( "New size of me->rows ", vlaSize );

    status = om$vla_set_dimension(	varray	= me->rows,
					size	= vlaSize );
    __CheckRC( status, 1, "om$vla_set_dimension", wrapup);

    objInd = om$dimension_of( varray = me->locObjs )  - 1;
    __DBGpr_int( "Total number of located objects ", objInd+1 );

    /* initialize the entries */

    for( i = vlaSize-1 ; nbElms > 0 ; i--, nbElms--, objInd-- )
    {
	me->rows[i].rowId.objid = NULL_OBJID;
	me->rows[i].nbObjs = 1;
	me->rows[i].startIndex = objInd;
	me->rows[i].qty.nSflag = VD_DRWLO_EN_COUNT;
        me->rows[i].qty.szExp[0] = '\0';
	me->rows[i].flag = VD_DRW_ROW_NEW;
    }

#ifdef vdsDEBUG
    printf("\n\tRow information :\n");
    for( i = 0 ; i < vlaSize ; i++ )
	printf("\t\tnbObjs = %d, startIndex = %d, flag = %d\n",
		me->rows[i].nbObjs, me->rows[i].startIndex, me->rows[i].flag );
#endif

wrapup :
    if( !(status & 1) )
    {
	*sts = VD_ERROR;

        if( status == OM_E_NODYNMEM )
	    UI_status( "Error in dynamic allocation : command terminated" );
        else
	    UI_status( "Error encountered : command terminated" );	
    }
    End
    return OM_S_SUCCESS;
}

/*+me
 ---------------------------------------------------------------------------
  Public Message get_tbl_format

  Abstract
        This method gets the table format based on the table layout name, and
        stores the information in the instance data
	Syntax of expression fields is checked, and if there is an error,
	the command will be terminated.
	Item number gadget is enabled or disabled appropriately.

  Arguments
        IGRlong         *sts            O       Return code

  Notes/Remarks

  Status Code
      status == OM_S_SUCCESS

  Return Code
      *sts =    VD_SUCCESS  if success
                VD_ERROR if  no memory
 ---------------------------------------------------------------------------
-me*/

method get_tbl_format( long *sts )
{
    IGRint		i,rc, syntaxerror,
			nbTxt;
    IGRshort		nbFixRecs,
			nbDatRecs;
    IGRlong		msg,
			status = OM_S_SUCCESS;
    IGRdouble		height;
    VD_execRes		expVal;
    SetProc( VDCmdCrTbl.get_tbl_format); Begin
    
    *sts = VD_SUCCESS;
   /* get the list of data records */

    status = VD_drwlo_gdata(    &msg,
                                me->tblLayoutName,
                                VD_DRWLO_EN_DATA,
                                0, 0,
                                0, NULL,
                                &height,
                                &nbDatRecs,
                                NULL );
    __CheckRC( status, msg, "VDdrwlo_gdata", wrapup );

    __DBGpr_int( "Number of data records", nbDatRecs );

    status = om$vla_set_dimension(	varray	= me->datRecs,
					size	= (IGRint)nbDatRecs );
    __CheckRC( status, 1, "om$vla_set_dimension", wrapup );

    status = VD_drwlo_gdata(    &msg,
                                me->tblLayoutName,
                                VD_DRWLO_EN_DATA,
                                0, 0,
                                0, NULL,
                                &height,
                                &nbDatRecs,
                                me->datRecs );
    __CheckRC( status, msg, "VD_drwlo_gdata", wrapup);

    /* get the list of fixed records */

    status = VD_drwlo_gfix(	&msg,
				me->tblLayoutName,
				VD_DRWLO_EN_DATA,
				0, 0,
				0, NULL,
				&height,
				&nbFixRecs,
				NULL );
    __CheckRC( status, msg, "VDdrwlo_gfix", wrapup );

    __DBGpr_int( "Number of fixed records", nbFixRecs );

    status = om$vla_set_dimension(	varray	= me->fixRecs,
					size	= (IGRint)nbFixRecs );
    __CheckRC( status, 1, "om$vla_set_dimension", wrapup);

    status = VD_drwlo_gfix(	&msg,
				me->tblLayoutName,
				VD_DRWLO_EN_DATA,
				0, 0,
				0, NULL,
				&height,
				&nbFixRecs,
				me->fixRecs );
    __CheckRC( status, msg, "VDdrwlo_gfix", wrapup );

    /* retain only the fixed text components */

    nbTxt = 0;
    for( i = 0 ; i < nbFixRecs ; i++ )
	if( me->fixRecs[i].rectyp == VD_DRWLO_EN_TEXT )
	    me->fixRecs[nbTxt++] = me->fixRecs[i];

    __DBGpr_int( "Number of fixed text components", nbTxt );

    /* resize the vla */

    status = om$vla_set_dimension( 	varray	= me->fixRecs,
					size	= nbTxt );

    /* validate the syntax of expressions if any */

    syntaxerror = 0;
    for( i = 0 ; i < nbDatRecs ; i++ )
	if( me->datRecs[i].rectyp == VD_DRWLO_EN_EXPRESSION )
	{
	    status = VD_expParse(	me->datRecs[i].Text,
					FALSE,
					VD_EXP_WARNING,
					0, NULL,
					&expVal );

/*	    __CheckRC( status, 1, "VD_expParse", wrapup ); */

            if( !(status&1) ) {
               printf("        Expression syntax error in column %d\n",
                        me->datRecs[i].colno);
               syntaxerror = 1;
            } 
	}

    rc = 0;

    if( syntaxerror ) { 
        rc = GRconfirm_box(" There are expression syntax error, do you still want to create the table? ");

       if( !rc )
        {
            status = VD_STATUS_ERROR;      
            goto wrapup;
        }
        else
            status = VD_STATUS_OK;
    }
 
    if( me->tblType == VD_DRW_TBLTYPE_BOM )
    {
	for( i = 0 ; i < nbDatRecs ; i++ )
	    if( me->datRecs[i].rectyp == VD_DRWLO_EN_ITEMNO )
		break;

	if( i >= nbDatRecs )
	    FIg_disable( VD_FP, VD_TBL_GEN_ITEMNBS_BTN );
	else
	    FIg_enable( VD_FP, VD_TBL_GEN_ITEMNBS_BTN );
    }

wrapup :
    if( !(status & msg & 1) )
    {
	*sts = VD_ERROR;

        if( status == OM_E_NODYNMEM )
	    UI_status( "Error in dynamic allocation : command terminated" );
        else if( status == VD_STATUS_ERROR )
	    UI_status( "Syntax error in table layout expression: command terminated" );
        else
	    UI_status( "Error encountered :  command terminated" );
    }
    End
    return OM_S_SUCCESS;
}

/*+me
 ---------------------------------------------------------------------------
  Public Message get_tbl_type

  Abstract
        This method returns the type of the table : bom or non-bom

  Arguments
        IGRlong         *sts            O       Return code

  Notes/Remarks

  Status/Return Code
      *sts =    VD_DRW_TBLTYPE_BOM ( Bom table header located )
                VD_DRW_TBLTYPE_GEN ( General table header located )
		VD_ERROR	   ( Unknown table type )

 ---------------------------------------------------------------------------
-me*/

method  get_tbl_type ( long * sts )
{
    IGRlong	tblSrc = 0;

    SetProc( VDCmdCrTbl.get_tbl_type); Begin
    
    *sts = VD_SUCCESS;

    *sts = me->tblType;

    /*
     * This check block is added for TR5232, refere to command table
     */
    if( me->mytype == MODIFY_TABLE ) {
	VDdrw_getTblSrc( me->tblObj.obj_id, &tblSrc );
	if( tblSrc == VD_CMD_ITBL_PL ) {
		*sts = VD_DRW_TBLTYPE_GEN;
	}
    }

    End
    return OM_S_SUCCESS;
}

/*+me
 ---------------------------------------------------------------------------
  Public Message get_existing_cs

  Abstract
        This method gets the existing coordinate systems from the
        different individual table headers in the table.

  Arguments
        IGRlong         *sts            O       Return code

  Notes/Remarks

  Status/Return Code
      *sts =    VD_SUCCESS
                VD_ERROR           (if error)
 ---------------------------------------------------------------------------
-me*/

method  get_existing_cs ( long * sts )
{
    IGRint		i, j,
			nbHdrs, maxCs,
			nbNeededCs;
    IGRshort		matType;
    IGRdouble		mat[16];
    IGRlong 		msg,
			status = OM_S_SUCCESS;
    OM_S_OBJID		modId;

    SetProc( VDCmdCrTbl.get_existing_cs ); Begin

    *sts = VD_SUCCESS;

    nbNeededCs = om$dimension_of( varray = me->splitLocs );
    __DBGpr_int( "Number of cs needed ", nbNeededCs );

    nbHdrs = om$dimension_of( varray = me->hdrIds );
    __DBGpr_int( "Number of headers ", nbHdrs );

    if( nbNeededCs > nbHdrs )
	maxCs = nbNeededCs;
    else
	maxCs = nbHdrs;
    __DBGpr_int( "Number of cs for vla allocation ", maxCs );

    /* allocate memory for all the needed cs */

    status = om$vla_set_dimension(	varray	= me->cs,
					size	= maxCs );
    __CheckRC( status, 1, "om$vla_set_dimension", wrapup );
   
    /* get current os */

    status = ex$get_cur_mod(	id	= &modId );
    __CheckRC( status, 1, "ex$get_cur_mod", wrapup );

    /* get the cs */

    for( i = 0 ; i < nbHdrs ; i++ )
    {
	status =
	_VD_SEND_OBJ( me->hdrIds[i], VDdrwTblHdr.ACfind_temp_obj(
							(int *)&msg,
							"cs",
							&me->cs[i].obj_id ) );
	__CheckRC( status, msg, "VDdrwTblHdr.ACfind_temp_obj", wrapup );

	status =
	_VD_SEND_OBJ( me->cs[i].obj_id, NDmacro.ACreturn_foot( 	
							&msg,
							"",
							&me->cs[i].obj_id,
							&matType, mat ) );
	__CheckRC( status, msg, "NDmacro.ACreturn_foot", wrapup );

	me->cs[i]._md_os = me->cs[i].obj_id.osnum;
	me->cs[i]._md_id = modId;
	me->cs[i]._matrix_type = matType;
	for( j = 0 ; j < 16 ; j++ )
	    me->cs[i]._matrix[j] = mat[j] ;
	
	__DBGpr_obj( "Coordinate system id", me->cs[i].obj_id );
    }
	
    me->nbCs = nbHdrs;
	
wrapup :

    if( !(status & msg & 1) )
    {
	*sts = VD_ERROR;

        if( status == OM_E_NODYNMEM )
	    UI_status( "Error in dynamic allocation : command terminated" );
        else
	    UI_status( "Error encountered :  command terminated" );
    }
    End;
    return OM_S_SUCCESS;
}

/*+me
 ---------------------------------------------------------------------------
  Public Message validate_assoc_updmode

  Abstract
        This method validates associative update mode.  If it is set
        to delayed, the command must be terminated.

  Arguments
        IGRlong         *sts            O       Return code

  Status code
        status = OM_S_SUCCESS

  Return Code
      *sts =    VD_ERROR        if invalid mode
                VD_SUCCESS      if valid mode
 ---------------------------------------------------------------------------
-me*/

method  validate_assoc_updmode( long * sts )
{
    IGRint		mode;
    IGRlong		status = OM_S_SUCCESS;

    SetProc( VDCmdCrTbl.validate_assoc_updmode ); Begin

    *sts = VD_SUCCESS;
    status = nd$mod_batch(	request		= ND_INQ,
				p_ret_mode	= &mode );
    CheckRC( status, 1 );

    if( mode == ND_DEFER )
    {
	*sts = VD_ERROR;
	UI_status( "Cannot modify table in 'delayed' associative update mode" );
        me->state = _terminate;
    }
    End
    return OM_S_SUCCESS; 
}

/*+me
 ---------------------------------------------------------------------------
  Public Message check_to_locate_cs

  Abstract
        This method determines whether any more coordinate systems need to
        be located or not.

  Arguments
        IGRlong         *sts            O       Return code

  Notes/Remarks

  Status/Return Code
      *sts =    VD_TBL_LOCATE_CS        (if cs is needed)
                VD_TBL_NO_CS_NEEDED     (if no cs is needed)
 ---------------------------------------------------------------------------
-me*/

method  check_to_locate_cs( long * sts )
{
    IGRint		nbNeededCs;
  
    SetProc( VDCmdCrTbl.check_to_locate_cs ); Begin

    nbNeededCs = om$dimension_of( varray = me->splitLocs );
    __DBGpr_int( "Number of cs needed ", nbNeededCs );

    __DBGpr_int( "Number of available cs ", me->nbCs );

    if( me->nbCs < nbNeededCs )
    {
	*sts = VD_TBL_LOCATE_CS;

    	/* set up the prompt for the next locate */

    	me->prompt[0] = '\0';
    	sprintf( me->prompt, "Identify coordinate system # %d", me->nbCs + 1 );
    	__DBGpr_str( "Prompt string", me->prompt );
    }
    else
	*sts = VD_TBL_NO_CS_NEEDED;

    End;
    return OM_S_SUCCESS;
}

/*+me
 ---------------------------------------------------------------------------
  Public Message VDvalidateItemNos

  Abstract
        This method checks for uniqueness of item numbers.

  Arguments
        IGRlong         *msg            O       Return code
        IGRchar         *messStr        O       Message to be displayed in
                                                message field of form, in
                                                case of incorrect item nos
	IGRint		bufSize		I	Size of message string
  Status
        status = OM_S_SUCCESS

 ---------------------------------------------------------------------------
-me*/

method  VDvalidateItemNos(      IGRlong         *msg;
                                IGRchar         *messStr;
				IGRint		bufSize )
{
    IGRint		i, j, k,
			ind1, ind2,
			len, maxLen = 0,
			nbDatRecs,
			col = 0, 
			row, 
			line = 0, 
			mcf,
			sel, pos,
			nbRows,
			found = 0;
    IGRchar		buffer[BUFLEN],
			*itemBuf = NULL,
			tmpBuf[20];

    IGRlong		status = OM_S_SUCCESS;

    SetProc( VDCmdCrTbl.VDvalidateItemNos ); Begin
    *msg = MSSUCC;

    __DBGpr_int( "Message Buffer size", bufSize );

    if( bufSize < 40 )
    {
	__DBGpr_com( "Message Buffer size is too small" );
	*msg = MSFAIL;
	goto wrapup;
    }

    /* if not BOM, return success */

    if( me->tblType != VD_DRW_TBLTYPE_BOM )
	goto wrapup;

    nbDatRecs = om$dimension_of( varray = me->datRecs );
    __DBGpr_int( "Number of data records", nbDatRecs );

    /* get item number column */

    for( i = 0 ; i < nbDatRecs ; i++ )
	if( me->datRecs[i].rectyp == VD_DRWLO_EN_ITEMNO )
	{
	    col = me->datRecs[i].colno;
	    line = me->datRecs[i].lineno;
	    break;
	}

    if( i >= nbDatRecs )
	goto wrapup;

    mcf = VD_TBL_INV_COLDISP_FLD;

    /* check if present in vis col mcf */

    for( i = 0 ; i < me->nbSelCols ; i++ )
	if( me->selColList[i] == col )
	{
	    col = i + 1;
	    mcf = VD_TBL_VIS_COLDISP_FLD;
	    break;
	}

    __DBGpr_int( "Column number for item number", col );
    __DBGpr_int( "mcf value", mcf );

    nbRows = om$dimension_of( varray = me->rows );
    __DBGpr_int( "Number of rows", nbRows );

    if( !nbRows )
	goto wrapup;

    /* compute max item number string length */

    row = line - 1;
    for( i = 0 ; i < nbRows ; i++, row += me->maxLinesPerRow )
    {
	FIfld_get_text_length( VD_FP, mcf, row, col, &len );
	if( len > maxLen )
	    maxLen = len;
    }

    __DBGpr_int( "Maximum length of item number str", maxLen );

    if( maxLen <= BUFLEN )
	itemBuf = buffer;
    else
    {
	/* allocate memory */

	itemBuf = _MALLOC( maxLen, IGRchar );
	if( !itemBuf )
	{
	    status = OM_E_NODYNMEM;
	    *msg = MSFAIL;
	    goto wrapup;
	}
    }
	
    /* process item numbers : remove leading and trailing blanks */
	    
    row = line - 1;
    for( i = 0 ; i < nbRows ; i++, row += me->maxLinesPerRow )
    {
	FIfld_get_text( VD_FP, mcf, row, col, maxLen, 
				(unsigned char *)itemBuf, &sel, &pos );
	__DBGpr_str( "Item number string", itemBuf );


	j = strlen( itemBuf );
	__DBGpr_int( "Item buf strlen", j );

	if( !j )
	    continue;

	/* remove leading white space */

	k = 0;
	while( itemBuf[k] != '\0' && 
			( itemBuf[k] == ' ' || itemBuf[k] == '\t' ) )
	    k++;

	/* remove trailing white space */

	j--;
	while( j >= k && ( itemBuf[j] == ' ' || itemBuf[j] == '\t' ) )
	    j--;

	itemBuf[j+1] = '\0';
	FIfld_set_text( VD_FP, mcf, row, col, &itemBuf[k], FALSE );
	__DBGpr_str( "Processed Item Number string", &itemBuf[k] ); 
    }

    if( itemBuf != buffer )
	_FREE( itemBuf );

    itemBuf = NULL;

    /* allocate memory for all item numbers */

    itemBuf = _MALLOC( maxLen * nbRows, IGRchar );
    if( !itemBuf )
    {
	status = OM_E_NODYNMEM;
	*msg = MSFAIL;
	goto wrapup;
    }

    row = line - 1;
    j = 0;
    for( i = 0 ; i < nbRows ; i++, row += me->maxLinesPerRow, j += maxLen )
    {
	FIfld_get_text( VD_FP, mcf, row, col, maxLen, 
				(unsigned char *)&itemBuf[j], &sel, &pos );
	__DBGpr_str( "Item number string", &itemBuf[j] );
    }

    /* check for uniqueness */

    strcpy( messStr, "Item number duplicated in rows : " );

    ind1 = 0;
    for( i = 0 ; i < nbRows ; i++, ind1 += maxLen )
    {
	if( !strlen( &itemBuf[ind1] ) )
	    continue;

	ind2 = ind1 + maxLen;
	for( j = i+1 ; j < nbRows ; j++, ind2 += maxLen )
	    if( !strcmp( &itemBuf[ind1], &itemBuf[ind2] ) )
	    {
		if( !found )
		{
		    /* first time : put the ith row number */

		    tmpBuf[0] = '\0';
		    sprintf( tmpBuf, "%d, %c", i+1, '\0' );
		    strcat( messStr, tmpBuf );
		}

		found = 1;
		tmpBuf[0] = '\0';
		sprintf( tmpBuf, "%d, %c", j+1, '\0' ); 
		if( strlen( messStr ) > bufSize-10 )
		{
		    strcat( messStr, "......." );
		    goto wrapup;
		}
		else
		    strcat( messStr, tmpBuf );

		__DBGpr_str( "messStr", messStr );
	    }
	if( found )
	    goto wrapup;
    }

wrapup :

    if( !found )
	messStr[0] = '\0';
    else
    {
	/* remove the last extra comma */
		
	messStr[ strlen(messStr) - 2 ] = '\0';
    }
    __DBGpr_str( "Message buffer", messStr );

    _FREE( itemBuf );
    End
    return status;
}


/*+me
 ---------------------------------------------------------------------------
  Public Message VDrowToBeDeleted

  Abstract
        This method puts the row to be deleted in the instance vla

  Arguments
        IGRlong         *msg            O       Return code

  Status code
        status = OM_S_SUCCESS

  Return Code
        *sts = VD_SUCCESS
 ---------------------------------------------------------------------------
-me*/

method  VDrowToBeDeleted (      IGRlong         *msg;
                                struct GRid     rowId )
{
    IGRint		size = 0;
    IGRlong		status = OM_S_SUCCESS;

    SetProc( VDCmdCrTbl.VDrowToBeDeleted ); Begin

    *msg = MSSUCC;
    __DBGpr_obj( "Row to be deleted", rowId );

    if( rowId.objid == NULL_OBJID )
	goto wrapup;

    size = om$dimension_of( varray = me->rowsDel );
    __DBGpr_int( "Current size of rowsDel ", size );

#ifdef vdsDEBUG
{
    IGRint	i;
    /* verify that this is not already in the list */

    for( i = 0 ; i < size ; i++ )
	if( me->rowsDel[i].objid == rowId.objid && 
			me->rowsDel[i].osnum == rowId.osnum )
	    break;

    if( i < size )
    {
	printf("\n\n\tError : rowId already in list\n");
	goto wrapup;
    }
}
#endif

    /* resize vla */
  
    status = om$vla_set_dimension(	varray	= me->rowsDel,
					size	= size+1 );
    __CheckRC( status, 1, "om$vla_set_dimension", wrapup );

    me->rowsDel[size] = rowId;

wrapup :
    End
    return status;
}

/*+me
 ---------------------------------------------------------------------------
  Public Message is_table_uptodate

  Abstract
        This method checks if the table rows are up-to-date w.r.t the
        model objects.

  Arguments
        IGRlong         *sts            O       Return code

  Notes/Remarks

  Status/Return Code
      *sts =    VD_SUCCESS if up-to-date
                VD_ERROR if tbl rows need recomputing
 ---------------------------------------------------------------------------
-me*/

method  is_table_uptodate ( long * sts )
{
    IGRint		upToDate = 1;

#ifdef MIN_TBL_UPDATE	/* -----------Begin MIN_TBL_UPDATE------------ */
    IGRint		rc;
#endif			/* -----------End MIN_TBL_UPDATE--------------- */

    IGRlong		msg,
			status = OM_S_SUCCESS;

    SetProc( VDCmdCrTbl.is_table_uptodate ); Begin

    *sts = VD_SUCCESS;

    __DBGpr_obj( "Table id", me->tblObj.obj_id );

    /* Commented by Ming for TR179901284
    status = VDdrw_checkDependency( &msg, &upToDate );
    */
    __DBGpr_int( "FIle uptodate", upToDate );

    /* abort command if design file is not up to date */

    /* Commented by Ming for TR179901284
    if( !upToDate )
    {
	*sts = VD_ERROR;
	goto wrapup;
    }
    */

#ifdef MIN_TBL_UPDATE	/* -----------Begin MIN_TBL_UPDATE------------ */

    status = VDdrw_checkTblDependency( 	&msg, &me->tblObj.obj_id, NULL,
					FALSE, &upToDate );
    CheckRC( status, msg );

    __DBGpr_int( "uptodate flag", upToDate );

    if( !upToDate )
    {
	/* check if user wants to update */

	rc = GRconfirm_box( "Ref. files have been modified. Update table dependencies?" );

	if( !rc )
	{
	    *sts = VD_ERROR;
	    goto wrapup;
	}

	/* update the dependencies */

	VDdrw_checkTblDependency(	&msg, &me->tblObj.obj_id, NULL,
					TRUE, &upToDate );
    }

#endif			/* -----------End MIN_TBL_UPDATE--------------- */

wrapup :
    End
    return OM_S_SUCCESS;
}
    

end implementation VDCmdCrTbl;
