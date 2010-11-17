/* $Id: VDhdrForm.I,v 1.36.4.1 2003/05/12 19:23:39 ylong Exp $ */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdtbl/cmd / VDhdrForm.I
 *
 * Description:
 *	Implementation of the following methods for VDCmdPlHdr :
 *		init_form
 *		form_notification
 *
 * Dependencies:
 *
 * History:
 *
 *      04/14/95        R. Manem        Creation
 *      04/14/95        R. Manem        Show button
 *      08/25/95        Henk, rmn	Speedup for layout list
 *      01/03/95	Ravi		TR#179528348
 *	09/01/00	Ming		CR179901748
 *	09/28/00	ylong		CR179902010
 *      01/05/01        pnoel           TR4108 fixes
 *	02/03/01	ylong		TR3320
 *	04/19/01	ylong		CR5006
 *	04/24/01	ylong		CR5065
 * -------------------------------------------------------------------*/

class implementation VDCmdPlHdr;

/*
#define vdsDEBUG 
#define vdserrDEBUG
*/

#include <stdio.h>
#include "string.h"

#include "OMmacros.h"
#include "OMprimitives.h"
#include "exproto.h"
#include "exmacros.h"

#include "igewindef.h"

#include "DIdef.h"
#include "DItypedef.h"
#include "DIglob.h"
#include "DIprims.h"

#include "v_miscmacros.h"
#include "v_dbgmacros.h"
#include "v_datamacros.h"

#include "VDdrwlo.h"
#include "VDdrwlo_pr.h"
#include "VDdrwtbl.h"
#include "VDtblCmdDef.h"

#include "vdtblmacros.h"
#include "VDfrm.h"
#include "VDatmacros.h"
#include "vdtr_macros.h"
#include "VDfile.h"
#include "my_slc.h"
#include "vdtvwtools.h"
#include "VDtblXml.h"
/* ---- SPEEDUP -------------------------------------------------------- */

#include "VDCmdDef.h"
#include "FI.h"
#include "FEI.h"
#include "VDxdom.h"

#define BUFSIZE		64

static char	INDEXTABLETYPE[BUFSIZE];
static TGRid    SELECT_NODE;
static TGRid    *SELECT_LIST;
static IGRint   NODE_CNT;


extern IGRint  VDtvwCTBSStartItem(TGRid     *nodeID,
				  IGRint    *xpos,
				  IGRint    *ypos,
				  IGRint    *accept);

IGRlong VDtblCmdSetIndexTableType( IGRchar  *indexType );

IGRlong VDtblCmdSetNameID(TGRid  nodeID );
IGRlong VDtblCmdGetNameID( TGRid *nodeID );

IGRlong VDtblCmdSetSelectList( TGRid  **nodeID,
			       IGRint  *nodeCnt);

IGRlong VDtblPostFileData(Form form);

IGRlong VDtblPostTableData(Form     form,
			   IGRchar *tblLayoutName);

IGRlong VDtblAddToMap(Form form);

IGRlong VDtblSubtractFromMap(Form form);

IGRlong VDtblMatchToMap(Form form);

IGRlong VDtblCheckMapStatus(Form form);

IGRlong VDtblClearMap(Form form);

IGRlong VDtblGetRowCount(Form    form, 
			 IGRint  col, 
			 IGRint *rowCnt);

IGRlong VDtblClearCol(Form   form,
		      IGRint col);

IGRlong VDtblGetfldNames(IGRchar                 *tblLayoutName, 
			 IGRint                   hdrTrlType,
			 IGRchar               ***fldNames,
			 IGRint                  *fldNameCnt);

IGRlong VDtblMapItemMoveUp(Form form);

IGRlong VDtblMapItemMoveDown(Form form);

IGRstat VDhdrGetItems(Form form);

IGRlong VDtblCmdReportNameIDParent(char   *form_ptr, 
				   TGRid  *nodeID );

IGRstat VDhdrGetStyleFile( Form form );

IGRstat VDhdrIsStyleFileValid( Form form );

IGRstat VDhdrGetStyleFileText( Form form );

extern IGRint  VDtvwAddNodeToListUnique(TGRid  *addNode,
					TGRid **nodeList,
					IGRint *nodeListCnt);

static IGRint  intcmp( int* e1, int* e2 );
 
//static   struct VDdrw_mapInfo mapInfo;

/*
** Add "Attribute Driven Symbol" to CTBS for CR5065, by ylong
*/
IGRlong VDtblCmdForm_fillADS( Form form, IGRint gadget )
{
	IGRlong		msg,
			status = OM_S_SUCCESS;
	IGRint		i;
	IGRshort	nbAdsTbls = 0;
	IGRchar		(*adsNames)[VD_DRWLO_CHR_IDFLD] = NULL;

	if( form == NULL ) goto wrapup;

	status = VD_adsym_getnm( &msg, FALSE, &nbAdsTbls, NULL );
	if( !(status&msg&1) ) {
		printf("VD_adsym_getnm failed to get nbAdsTbls\n");
		goto wrapup;
	}

	if( nbAdsTbls )
	{
		adsNames = (IGRchar (*)[VD_DRWLO_CHR_IDFLD]) malloc(
                        sizeof(IGRchar) * VD_DRWLO_CHR_IDFLD * nbAdsTbls );
		if( !adsNames )
		{
			status = 0;
			goto wrapup;
		}
	}
	else goto wrapup;

	status = VD_adsym_getnm( &msg, FALSE, &nbAdsTbls, (IGRchar *)adsNames );

	FIfld_set_list_num_rows( form, gadget, 0, (nbAdsTbls + 1) );
	FIfld_set_list_text( form, gadget, 0, 0, (IGRuchar*)"", FALSE );
	for( i = 0 ; i < nbAdsTbls ; i++ )
	{
		FIfld_set_list_text (	form, gadget, i+1, 0, 
					(IGRuchar*)adsNames[i], FALSE );
	}

wrapup:
	_FREE( adsNames );
	return status;
}


/*+mo
 -------------------------------------------------------------------------
  Overridden Message
        form_notification from CEO

  Abstract
        Form notification routine for the CO

  Arguments
        int           form_label;     label of form which received user  input
        int           gadget_label;   gadget label  which received user  input
        double        value;          value of gadget ( or field row # )
        char          * form_ptr ;    ptr to I/Forms form which received input



 -------------------------------------------------------------------------
-mo*/


method form_notification( int      form_label;
                          int      gadget_label;
                          double   value;
                          char     *form_ptr )
{
    IGRint		i, j,
			row, pos,
			sel,
			screen,
			resp;
    IGRshort		nbLayouts = 0;
    IGRlong		msg,
			status = OM_S_SUCCESS;
    IGRchar		buffer[VD_DRWLO_CHR_IDFLD],
                        buf[BUFSIZE],
			tblNameBuf[BUFSIZE],
			crtypeBuf[BUFSIZE],
			indexType[BUFSIZE],
			stagetypeBuf[BUFSIZE],
			pre_name[BUFSIZE],
			tblName[DI_PATH_MAX],
			stagenameBuf[DI_PATH_MAX],
			nbLoStr[8] = "",
			*ptr = NULL,
			(*loDescs)[VD_DRWLO_CHR_DESC] = NULL,
			(*loNames)[VD_DRWLO_CHR_IDFLD] = NULL;
    OMuword		os;
    struct GRid		obj,
			tblLayoutId,
			setID,
			treeID,
			*nodeList;
    IGRint		stagecount, Selflag, flag, idsp, cntnode,isXML = 0;
    IGRchar		*stagetype, temp[100];
    IGRint		nodeTypeCnt;
    IGRchar		nodeType[128],nodeName[128],firstStage[128];
    IGRchar             fileName[24];
    IGRchar             filePath[1023];
    IGRchar             *attr1,*attr2;
    IGRchar             type[80];
    TGRid               *nodeIDs = NULL ;
    TGRid               *selIDs = NULL;
    TGRid               parID;

    typedef char	StringType[80];
    StringType		*strList = NULL;
    IGRint		*intList = NULL;
    IGRint              selectionType;
    IGRint              sts;
    IGRint              selIDsCnt;
    IGRint              selected;
    IGRint              displayed = 0;
    IGRint              localDir;
    IGRint              itemNoOpt = 0, startNo = 1;
    IGRchar             selBuf[128],stageBuf[128],indexBuf[128], dbgBuf[128];
    IGRchar             pwdPath[1023],fullPath[1023];
    IGRdouble           height;
    IGRshort            nbDatRecs	= 0;
    IGRint              num_rows        = 0;
    
    struct VDdrwlo_data *datRecs        = NULL;
    SetProc( VDCmdPlHdr.form_notification ); Begin

    Selflag = FALSE;
    stagetype = NULL;
    nodeList = NULL;
    pwdPath[0] = '\0';
    fullPath[0] = '\0';


__DBGpr_int("------- me->mytype", me->mytype);

    FIfld_set_text( VD_FP, FI_MSG_FIELD, 0, 0, "", FALSE );
    
    switch( gadget_label )
    {

      case FI_ACCEPT  :  // 1
      case FI_EXECUTE :  // 2
	    /* 
	     * must save the parameters 
	     */

          __DBGpr_com(" FI_ACCEPT in form_notification");
	  __DBGpr_int(" mytype ", me->mytype);

	  // handle traps for CTBS 
	  if(me->mytype == VD_CMD_STBL_PL) {
	    
	    // trap out no valid treeID
	    VDctbsGetTreeID( VD_FP,&treeID);
	    VDctbsFilterTreeID( &treeID );
	    if(treeID.objid == NULL_OBJID) {
	      vdfrm$SetText( form    = VD_FP,
			     txt     = "Please Select a valid Tree" );
	      break;
	    }
	    
	    // check the selection and the Stage fields for data. If none break
	    FIg_get_text( VD_FP, VD_STBL_STAGE_FLD, stageBuf );
	    FIg_get_text( VD_FP, VD_STBL_CR_TYPE_FLD, selBuf );
	    FIg_get_text( VD_FP, VD_STBL_INDEXTYP_FLD, indexBuf );
	    
	    
	    if((!strcmp(stageBuf,"")) || (!strcmp(selBuf,""))) {
	      vdfrm$SetText( form    = VD_FP,
			     txt     = "Please Select a valid Tree" );
	      break;
	    }
	    
	    
	    if((!strcmp(selBuf,"Index"))  && (!strcmp(indexBuf,""))) {
	      vdfrm$SetText( form    = VD_FP,
			     txt     = "No Index Selected" );
	      break;
	    }

	    
	    if(!strcmp(selBuf,"Item")) {
	      if(!(VDtvwIsItemAccepted())) { 
		vdfrm$SetText( form    = VD_FP,
			       txt     = "No Items Selected" );
		break;
	      }
	    }
	  }
	  
	  /* cs location */
	  
	  FIg_get_state( VD_FP, VD_HDR_TBL_LOC_BTN, &sel );
	  if( sel )
	    me->csLocation = VD_DRW_CS_LOC_RIGHT;
	  else
	    me->csLocation = VD_DRW_CS_LOC_LEFT;
	  
	  __DBGpr_int( "cs location (1=left) ", me->csLocation );
	  
	  /* table layout name */
	  
	  FIfld_get_active_row( VD_FP, VD_HDR_FMT_LIST_FLD, &row, &pos );
	  FIfld_get_text( 	VD_FP, VD_HDR_FMT_LIST_FLD, row, 0, 
				VD_DRWLO_CHR_IDFLD, 
				(unsigned char *)me->tblLayoutName, 
				&sel, &pos );
	  
	  if( !sel || !strlen( me->tblLayoutName ) )
	  {
	    FIfld_set_text( VD_FP, FI_MSG_FIELD, 0, 0, 
			    "Select a table layout", FALSE );
	    break;
	  }
	  
	  __DBGpr_str( "Table layout name", me->tblLayoutName );
	  
	  /* table name */
	  FIfld_get_text( VD_FP, VD_HDR_TBL_NAME_FLD, 0, 0, BUFSIZE,
			  (unsigned char *)tblNameBuf, &sel, &pos );
	  
	  __DBGpr_str( "Table name", tblNameBuf );
	  
	  ex$get_cur_mod( osnum	= &os );
	  status = 
	  di$give_pathname(	osnum		= os,
				pathname	= me->tblName );
	  __CheckRC( status, 1, "di$give_pathname", wrapup );

	  __DBGpr_str("tblName ",me->tblName);
	  
	  ptr = me->tblName + strlen( me->tblName );
	  sprintf( ptr, ":usr:drw_tables:%s", tblNameBuf );
	  __DBGpr_str( "Complete Table name ", me->tblName );
	  
	  /* delete preview window, if it exists */
	  status = _VD_SEND_MY( VDCmdPlHdr.VDdelPreviewWindow( &msg ) );
	  CheckRC( status, msg );
	  
	  /* Modified by Ming for CR179901748 */
	  if( me->mytype == VD_CMD_STBL_PL )
	  {
	    FIfld_get_active_row( VD_FP,
				  VD_STBL_TREESET_FLD,
				  &row,
				  &pos );
	    if( row < 0 ) break;
	    
	    setID.objid = NULL_OBJID;
	    vdfrm$GetText( form    = VD_FP,
			   gadget  = VD_STBL_TREESET_FLD,
			   row     = row,
			   col     = 3,
			   objID   = &setID );
	    
	    if( setID.objid == NULL_OBJID ) break;
	    
	    treeID.objid = NULL_OBJID;
	    vdtr$GetSetTree(setID  = &setID,
			    treeID = &treeID );
	    
	    if( treeID.objid == NULL_OBJID ) break;
	    
	    /* set item number option for TR3320 */
	    FIg_get_state( VD_FP, VD_STBL_ITEM_TGL, &itemNoOpt );
	    if( itemNoOpt ) {
		FIg_get_text(VD_FP, VD_STBL_STARTNO_FLD, temp);
		startNo = atoi(temp);
		if( startNo < 1 ) {
		   startNo = 1;
		   FIg_set_text(VD_FP, VD_STBL_STARTNO_FLD, "1");
		}
	    }
	
	    FIg_get_text( VD_FP, VD_STBL_STAGE_FLD, stagetypeBuf );
    
	    // stagetypeBuf must have something to select from
	    if( strlen(stagetypeBuf) )
	    {

	      FIg_get_text( VD_FP, VD_STBL_NAME_FLD, stagenameBuf );
	      
	      status =
		om$vla_set_dimension( varray  = me->locObjs,
				      size    = 1 );

	      {
		int		cnt;
		char		nodeName[128];
		
		cnt = 0;
		
		// load the selection into the list
		/* 
		 * this is unconditional to the treeID
		 * if this is wrong it will be wiped out later on
		 */
		me->locObjs[0].obj_id = treeID;
                /* do this the old way for VDatBase */
                if(vdobj$IsAncestryValid(objID          = &treeID,
                                         superClassName = "VDatBase")) {
                  // lookup all the nodes per the treeID
                  selectionType = VDTR_FIND_ALL;
                  vd$trget_nodes(nodeID       = &treeID,
			         lookupType   = selectionType,
				 frozen       = 1,
                                 outID        = &nodeIDs,
                                 cnt          = &cnt);
		
                  __DBGpr_int("VDTR_FIND_ALL cnt", cnt);

                  // loop down and get each nodeName and nodeType
                  for( i = 0; i < cnt; i++ )
                  {
                    nodeName[0] = '\0';
                    nodeType[0] = '\0';
                    vdtr$GetNodeName(nodeID   = &nodeIDs[i], nodeName = nodeName);
                    vdtr$GetNodeType(nodeID   = &nodeIDs[i], nodeType = nodeType);
                    // if they match the selection criterion
                    if( !(strcmp(nodeType, stagetypeBuf)) &&
                        !(strcmp(nodeName, stagenameBuf)) )
                    {
                      // load the selection into the list
                      me->locObjs[0].obj_id = nodeIDs[i];

		      sprintf( dbgBuf, "[%d,%d]:%s %s", 
                               nodeIDs[i].osnum,nodeIDs[i].objid,nodeType,nodeName);
		      __DBGpr_str("nodeID ", dbgBuf );
                      break;
                    }
                  }
                } else {
                  /* everyone else but VDatBase this way */
                  me->locObjs[0].obj_id = SELECT_NODE; 
                }
                
	      }

	      FIg_get_text( VD_FP, VD_STBL_CR_TYPE_FLD, crtypeBuf );
	      if( !strcmp(crtypeBuf, VD_STBL_PART_LIST) )
	      {
		__DBGpr_com("select_flag = VD_DRW_STBL_PLIST" );
		me->select_flag = VD_DRW_STBL_PLIST;
	      }
	      else if( !strcmp(crtypeBuf, VD_STBL_INDEX) )
	      {
		__DBGpr_com("select_flag = VD_DRW_STBL_INDEX" );
		me->select_flag = VD_DRW_STBL_INDEX;
		
		FIg_get_text( VD_FP,
			      VD_STBL_INDEXTYP_FLD,
			      indexType ); // 36
		
		if(strcmp(indexType,"")) VDtblCmdSetIndexTableType( indexType );
	      }
	      else if( !strcmp(crtypeBuf, VD_STBL_MODEL) )
	      {
		__DBGpr_com("select_flag = VD_DRW_STBL_MODEL" );
		me->select_flag = VD_DRW_STBL_MODEL;
	      }
	      else if( !strcmp(crtypeBuf, VD_STBL_ITEM) )
	      {
		__DBGpr_com("select_flag = VD_DRW_STBL_ITEM" );
		me->select_flag = VD_DRW_STBL_ITEM;
	      }
	    }
	  }	  
 
	  /* added for TR5006, Create Table by Import, by ylong */
	  if( me->mytype == VD_CMD_ITBL_PL )
	  {
	     IGRchar	separator[10];
	     GRname	filename;
	     IGRint     mapRows;

	     filename[0]  = '\0';
	     separator[0] = '\0';

	     FIg_get_text( VD_FP, VD_ITBL_IMPORTF_FLD, filename );
	     if( !VD_wordcount( filename ) )
	     {
		FIfld_set_text( VD_FP, FI_MSG_FIELD, 0, 0, 
			    "Import file name not input yet", FALSE );
		break;
	     }
	     /* check to see if the style field is displayed */
	     FIg_is_displayed(VD_FP,VD_ITBL_STYLE_FLD,&displayed);
	     
	     if(displayed == 1) {
	       FIg_get_text( VD_FP, VD_ITBL_STYLE_FLD, filename );
	       if( !VD_wordcount( filename ) )
	       {
		 FIfld_set_text( VD_FP, FI_MSG_FIELD, 0, 0, 
				 "Import Style Sheet not input yet", FALSE );
		 break;
	       }
	     }
	     

	     FIg_get_text( VD_FP, VD_ITBL_SEPARATOR_FLD, separator );
	     if( !VD_wordcount( separator ) ) 
             {
                FIfld_set_text( VD_FP, FI_MSG_FIELD, 0, 0,
                            "Separator not input yet", FALSE );
                break;
             } 
	     VDtblGetRowCount( VD_FP, 1, &mapRows);
	     if(mapRows < 1) {
	       FIfld_set_text( VD_FP, FI_MSG_FIELD, 0, 0,
			       "You must select a map", FALSE );
	       break;
	     }
	  }

    	  switch( gadget_label )
    	  {

      	   case FI_ACCEPT  :  // 1
	  	/* put the response in the queue */
	  	resp = VD_FORM_ACCEPT;
	  	ex$putque(	msg		= &msg,
				response 	= &resp );

	        __DBGpr_com(" FI_ACCEPT in form_notification end!");

		break;
      	    case FI_EXECUTE :  // 2
		/* put the response in the queue */
	  	resp = VD_FORM_EXECUTE;
	  	ex$putque(	msg		= &msg,
				response 	= &resp );

                __DBGpr_com(" FI_EXECUTE in form_notification end!");
		break;
	    }

	    _FREE( nodeIDs );

	    break;
  
      case FI_CANCEL :  // 4
	      
	      resp = VD_FORM_CANCEL;
            
	      ex$putque(	msg		= &msg,
				response 	= &resp );
	      break;
    
      case VD_HDR_SRCH_BTN : // 16
    
	    /* clear the list */
	    // gadget VD_HDR_FMT_LIST_FLD #13
	    FIfld_set_num_rows( VD_FP, VD_HDR_FMT_LIST_FLD, 0 );
    
	    /* get the table type */
	    // gadget VD_HDR_TBL_TYPE_FLD #14
	    FIfld_get_text( VD_FP, VD_HDR_TBL_TYPE_FLD, 0, 0,
			    VD_DRWLO_CHR_IDFLD, (unsigned char *)buffer,
			    &sel, &pos );
    
	    __DBGpr_str( "Table type", buffer );
    
	    ex$get_cur_mod( osnum	= &os );
    
	    /* get all the layouts */
	    status = vd$tbldlo_idx(	msg 	= &msg,
					status 	= status,
					osnum	= os,
					typin 	= buffer,
					p_count = &nbLayouts);
    
	    __CheckRC( status, msg, "vd$tbldlo_idx ", wrapup );
	    __DBGpr_int( "No of layouts found", nbLayouts );
    
	    if( !nbLayouts )
	    {
	      FIfld_set_text( VD_FP, FI_MSG_FIELD, 0, 0, 
			      "No layouts found", FALSE );
	      goto wrapup;
	    }
    
	    loNames = (IGRchar (*)[VD_DRWLO_CHR_IDFLD]) malloc(
			      sizeof(IGRchar) * VD_DRWLO_CHR_IDFLD * nbLayouts );
	    loDescs = (IGRchar (*)[VD_DRWLO_CHR_DESC]) malloc(
			      sizeof(IGRchar) * VD_DRWLO_CHR_DESC * nbLayouts );
	    if( !loNames  || !loDescs)
	    {
	      me->state = _terminate;
	      __DBGpr_com( "form_notification: ERROR in dynamic allocation" );
	      UI_status( "Error encountered : command terminated" );
      
	      /* put que */
      
	      resp = VD_FORM_CANCEL;
	      ex$putque(	msg		= &msg,
				response 	= &resp );
	      goto wrapup;
	    }
    
    status = vd$tbldlo_idx(	msg = &msg,
				status = status,
				osnum	= os,
				typin = buffer,
				p_nams = ((char *)loNames),
				p_desc = ((char *)loDescs),
				p_count = &nbLayouts);
    
    __CheckRC( status, msg, "vd$tbldlo_idx : list", wrapup );
    
    __DBGpr_int( "No of layouts found", nbLayouts );
    
    /* set the number of layouts found */
    
    sprintf( nbLoStr, "%d", nbLayouts );
    /* VD_HDR_NB_FMTS_TXT #13 */
    FIg_erase( VD_FP, VD_HDR_NB_FMTS_TXT );
    FIg_set_text( VD_FP, VD_HDR_NB_FMTS_TXT, nbLoStr );
    FIg_display( VD_FP, VD_HDR_NB_FMTS_TXT );
    
    /* print message in field */
    
    FIfld_set_text( VD_FP, FI_MSG_FIELD, 0, 0,
		    "Searching for table layouts", FALSE );
    
    /* get the table records for the layout names and update the form */
    
    for( i = 0 ; i < nbLayouts  ; i++ )
    {
      /* gadget defined by VD_HDR_FMT_LIST_FLD #17 */
      FIfld_set_text( VD_FP, VD_HDR_FMT_LIST_FLD, i, 0, 
		      loNames[i], FALSE );
      FIfld_set_text( VD_FP, VD_HDR_FMT_LIST_FLD, i, 1, 
		      loDescs[i], FALSE );
    }
    
    /* clear message field */
    
    FIfld_set_text( VD_FP, FI_MSG_FIELD, 0, 0, "", FALSE );
    
    break;
    // tree list
  case VD_HDR_FMT_LIST_FLD : // 17
    /* update the table name field */
    FIfld_get_active_row( VD_FP, VD_HDR_FMT_LIST_FLD, &row, &pos );
    FIfld_get_text( 	VD_FP, VD_HDR_FMT_LIST_FLD, row, 0, 
			VD_DRWLO_CHR_IDFLD, 
			(unsigned char *)buffer,
			&sel, &pos );
    if( sel && strlen( buffer ) )
    {
      __DBGpr_com("we have a selection of a TableName");
      status =
	_VD_SEND_MY( VDCmdPlHdr.VDsetDefaultTblName( &msg ) );
      CheckRC( status, msg );
      /* only applies to the CTBI command  to update some form stuff */
      if( me->mytype == VD_CMD_ITBL_PL ) {
	VDtblPostTableData(VD_FP,me->tblLayoutName);
	VDtblMatchToMap(VD_FP);
      } 

      FIg_get_state ( VD_FP,VD_HDR_SHOW_BTN,&sel );
      
      if ( sel && me->windowId.objid != NULL_OBJID ) {
	status = _VD_SEND_MY( VDCmdPlHdr.VDdelPreviewWindow( &msg ) );
	CheckRC( status, msg );
	FIfld_set_text( VD_FP, FI_MSG_FIELD, 0, 0, "", FALSE );
	me->windowId.objid = NULL_OBJID;
	goto step0;
      }
    }
    break;
    // table name field
  case VD_HDR_TBL_NAME_FLD : // 24
    
    /* get the current table name */
    FIfld_get_text( VD_FP, VD_HDR_TBL_NAME_FLD, 0, 0, BUFSIZE,
		    (unsigned char *)tblNameBuf, &sel, &pos );
    
    __DBGpr_str( "Table name", tblNameBuf );
    
    /* if NULL, give it the default name */
    
    if( !strlen( tblNameBuf ) )
    {
      status =
	_VD_SEND_MY( VDCmdPlHdr.VDsetDefaultTblName( &msg ) );
      CheckRC( status, msg );
    }
    else
    {
      /* if not NULL, check if name already exists */
      
      ex$get_cur_mod( osnum	= &os );
      
      status = 
	di$give_pathname(	osnum		= os,
				pathname	= tblName );
      __CheckRC( status, 1, "di$give_pathname", wrapup );
      
      __DBGpr_str( "Path name ", tblName );
      
      ptr = tblName + strlen( tblName );
      sprintf( ptr, ":usr:drw_tables:%s", tblNameBuf );
      __DBGpr_str( "Complete Table name ", tblName );
      
	status = di$translate(	objname	= tblName,
				p_objid	= &obj.objid,
				p_osnum	= &obj.osnum );
	if( status == DIR_S_SUCCESS )
	{
	  /* name already exists, so give it the default name */
	  status = _VD_SEND_MY( VDCmdPlHdr.VDsetDefaultTblName( &msg ) );
	  CheckRC( status, msg );
	}
	else{
	  strcpy( me->tblName, tblName );
	}
    }

	__DBGpr_str(" tblName", tblName );

    break;
            // This case if for the Show Button on the Form
  case VD_HDR_SHOW_BTN :  // 20
    /* delete preview window, if it exists */
	 /* TR#179528348  -Ravi */
    
   FIg_get_state ( VD_FP,VD_HDR_SHOW_BTN,&sel );
    if ( !sel && me->windowId.objid != NULL_OBJID ) {
      status = _VD_SEND_MY( VDCmdPlHdr.VDdelPreviewWindow( &msg ) );
      CheckRC( status, msg );
      FIfld_set_text( VD_FP, FI_MSG_FIELD, 0, 0, "", FALSE );
      me->windowId.objid = NULL_OBJID;
      break;
    }
    
 step0:
    /* get the name of the table layout */
    
    FIfld_get_active_row( VD_FP, VD_HDR_FMT_LIST_FLD, &row, &pos );
	    FIfld_get_text( 	VD_FP, VD_HDR_FMT_LIST_FLD, row, 0, 
				VD_DRWLO_CHR_IDFLD, 
				(unsigned char *)me->tblLayoutName,
				&sel, &pos );
	    if( !sel || !strlen( me->tblLayoutName ) )
	    {
	      FIfld_set_text( VD_FP, FI_MSG_FIELD, 0, 0, 
			      "No layout selected", FALSE );
	      FIg_set_state_off( VD_FP,VD_HDR_SHOW_BTN );
	      break;
	    }

	    __DBGpr_str( "layout name for show", me->tblLayoutName );
	    
	    FIfld_set_text( VD_FP, FI_MSG_FIELD, 0, 0, "Processing ...", FALSE );
	    /* get grid of table layout */
	    
	    status = VD_drwlo_getid(	&msg,
					me->tblLayoutName,
					NULL,
					&tblLayoutId );
	    CheckRC( status, msg );

	    if( !(status & msg & 1) )
	    {
        	__DBGpr_com( "form_notification: ERROR in VD_drwlo_getid" );
		FIfld_set_text( VD_FP, FI_MSG_FIELD, 0, 0, 
					"Error encountered", FALSE );
		break;
	    }

	    __DBGpr_obj( "Table layout id", tblLayoutId );


	    /* get active screen */

	    FIf_get_screen( VD_FP, &screen );

	    /* show the graphics in a window */

	    VD_drwlo_preview( 	&msg,
				&me->windowId,
				tblLayoutId,
				VD_DRWLO_EN_HEADER,
				BORDER,
				5, 490,
				990, 300,
				screen,
				&me->showOwnerId );

	    __DBGpr_obj( "Window id", me->windowId );
	    __DBGpr_obj( "Show owner id", me->showOwnerId );

	    FIfld_set_text( VD_FP, FI_MSG_FIELD, 0, 0, "", FALSE );

	    break;

      /* Added by Ming for CR179901748 */
      case VD_STBL_TREESET_FLD:  // 31

            VDctbsFillTableSelOptions(VD_FP);
            //if(!(sts & 1)) goto wrapup;
            
            VDctbsFillStagesList(VD_FP);

            VDctbsFillNamesList(VD_FP);

            VDctbsFillIndexTypeList(VD_FP);
	    break;

      case VD_STBL_CR_TYPE_FLD: // 26

	    FIg_get_text( VD_FP, VD_STBL_CR_TYPE_FLD, crtypeBuf );

	    if( strlen(crtypeBuf) )
 	    {
	      if( !strcmp(crtypeBuf, VD_STBL_INDEX) )
	      {
		FIg_display( VD_FP, VD_STBL_INDEXTYP_TXT );
		FIg_display( VD_FP, VD_STBL_INDEXTYP_FLD ); // 36
		FIg_reset( VD_FP, VD_STBL_INDEXTYP_FLD ); // 36
		
		FIfld_get_num_rows( VD_FP, VD_STBL_STAGE_FLD, &row );
		FIfld_set_num_rows( VD_FP, VD_STBL_INDEXTYP_FLD, row ); //36
		FIg_erase( VD_FP,VD_TBL_SELECT_ITEMS);    // 61
		if( row >= 0 )
		{
		  for( i = 0 ; i < row ; i++ )
                  {
		    nodeType[0] = '\0';
                    FIfld_get_list_text( VD_FP,
                                         VD_STBL_STAGE_FLD,
                                         i,
                                         0,
					 20,
                                         (unsigned char *)nodeType,
                                         &Selflag );
                    
                    FIfld_set_list_text( VD_FP,
                                         VD_STBL_INDEXTYP_FLD,
                                         i,
                                         0,
                                         (unsigned char *)nodeType,
                                         Selflag );  // 36
                  }
		}
	      }
  	      else if( !strcmp(crtypeBuf, VD_STBL_PART_LIST) )
	      {
		FIg_reset( VD_FP, VD_STBL_INDEXTYP_FLD ); // 36
		FIg_erase( VD_FP, VD_STBL_INDEXTYP_TXT );
		FIg_erase( VD_FP, VD_STBL_INDEXTYP_FLD ); // 36
		FIg_erase( VD_FP,VD_TBL_SELECT_ITEMS);    // 61
              }
  	      else if( !strcmp(crtypeBuf, VD_STBL_MODEL) )
	      {
		FIg_reset( VD_FP, VD_STBL_INDEXTYP_FLD ); // 36
		FIg_erase( VD_FP, VD_STBL_INDEXTYP_TXT );
		FIg_erase( VD_FP, VD_STBL_INDEXTYP_FLD ); // 36
		FIg_erase( VD_FP,VD_TBL_SELECT_ITEMS);    // 61
              }
	      else if( !strcmp(crtypeBuf, VD_STBL_ITEM) ) {
		/* item selection setup the button here*/
		FIg_display( VD_FP, VD_TBL_SELECT_ITEMS); // 61
	      }
	      
	    }

            // set the indextype field
            VDctbsFillIndexTypeList( VD_FP );
	    break;
            // This is the gadget that contains the list of Stages to be selected
      case VD_STBL_STAGE_FLD:  // 28

          // set the names field
          VDctbsFillNamesList( VD_FP );

          // set the indextype field
          VDctbsFillIndexTypeList( VD_FP );
          
	    break;
      case VD_STBL_STARTNO_FLD:
	  FIg_get_text(VD_FP, VD_STBL_STARTNO_FLD, temp);
	  startNo = atoi(temp);
	  if( startNo < 1 ) {
	     startNo = 1;
	     FIg_set_text(VD_FP, VD_STBL_STARTNO_FLD, "1");
	  }
	  
          break;

      case VD_STBL_ADS_FLD:
//	  FIg_get_text(VD_FP, VD_STBL_ADS_FLD, ADS_TABLE_NAME);
	  break;

      case VD_STBL_ITEM_TGL:
	  FIg_get_state( VD_FP, VD_STBL_ITEM_TGL, &itemNoOpt );
	  if( itemNoOpt ) {
		FIg_display(VD_FP, VD_STBL_STARTNO_FLD);
		FIg_display(VD_FP, VD_STBL_STARTNO_TXT);
	  }
	  else {
		FIg_erase (VD_FP, VD_STBL_STARTNO_FLD);
		FIg_erase (VD_FP,VD_STBL_STARTNO_TXT);
	  }

	  break;

      case VD_STBL_NAME_FLD:  // 30
	  
	  // Verify the name selection if valid or fix it
	  VDctbsValidateSelName(VD_FP);
	  // set the indextype field
	  VDctbsFillIndexTypeList( VD_FP );
	  break;
	  // This contains the index type selection
      case VD_STBL_INDEXTYP_FLD:  // 36
	break;
      case VD_ITBL_IMPORTF_TXT: // 43
	/* 
	 *this is actually the button to cause 
	 * the selection of a file from the browse 
	 */

	/* set the selection open with a starter */
	fileName[0] = '\0';
	strcpy(type,"*.xml *.XML *.txt *.TXT");
	/* no limit on the selection types */
	flag = 0;
	/* preset the selected flag to allow user change */
	selected = 0;
	/* set the flag for the local file dir and lock it */
	localDir = 1;
	
	/* disable the VD_FP form now */
	FIg_disable(VD_FP, 0);
	strcpy(filePath,"");
	/* call the browser */
	vdfile$BrowseFiles(Dir      = pwdPath,
			   Name     = fileName,
			   Path     = filePath,
			   // Type     = type,
			   Flag     = &flag,
			   Selected = &selected,
			   LocalDir = &localDir);
	
	/* enable the VD_FP form */
	FIg_enable(VD_FP, 0);

	/* set the value to the VD_FP gadget */
	/* 
	 * it really doesn't matter if any selection was made 
	 * any file or none to the field if the selection is yes
	 */
	if(selected & 1) {
	  FIg_set_text( VD_FP, VD_ITBL_IMPORTF_FLD, filePath );

	  /* update form if table layout found from import file */
          if(VDdrw_ITBLsetFormByImport( VD_FP, filePath ) )
          {
            FIfld_get_active_row( VD_FP, VD_HDR_FMT_LIST_FLD, &row, &pos );
            FIfld_get_text(     VD_FP, VD_HDR_FMT_LIST_FLD, row, 0,
                                VD_DRWLO_CHR_IDFLD,
                                (unsigned char *)me->tblLayoutName,
                                &sel, &pos );
            status =
            _VD_SEND_MY( VDCmdPlHdr.VDsetDefaultTblName( &msg ) );
            CheckRC( status, msg );
          }
	}

	/* update ITBL file update of  col #0 here CR5006 ~pn */
	__DBGpr_com("exectution VDtblPostFileData 1");
        //isXML = VDdrw_CheckIfXML(fileName);
	VDtblPostFileData(VD_FP);
	VDtblMatchToMap(VD_FP);
	break;

      case VD_ITBL_IMPORTF_FLD:
	/* update form based on import file */
	FIg_get_text( VD_FP, VD_ITBL_IMPORTF_FLD, fileName );
        if(VDdrw_ITBLsetFormByImport( VD_FP, fileName ) )
        {
          FIfld_get_active_row( VD_FP, VD_HDR_FMT_LIST_FLD, &row, &pos );
          FIfld_get_text(       VD_FP, VD_HDR_FMT_LIST_FLD, row, 0,
                                VD_DRWLO_CHR_IDFLD,
                                (unsigned char *)me->tblLayoutName,
                                &sel, &pos );
          status =
          _VD_SEND_MY( VDCmdPlHdr.VDsetDefaultTblName( &msg ) );
          CheckRC( status, msg );
        }

	/* activate ITBL file update of col #0 here cr5006 ~pn */
      __DBGpr_com("exectution VDtblPostFileData 2");
	VDtblPostFileData(VD_FP);
	VDtblMatchToMap(VD_FP);
      __DBGpr_com("update the #0 col here file selection");
	break;
	
      case VD_ITBL_COLS_FLD: /* selection of the ITBL cols list */
	/* may have no real function right now */
	break;
	
      case VD_ITBL_ADD_BTN: /* selection of the ITBL add button */
	__DBGpr_com("add item button clicked");
	VDtblAddToMap(VD_FP);
	break;
	
      case VD_ITBL_SUB_BTN: /* selection of the ITBL subtract button */
	__DBGpr_com("subtract item button clicked");
	VDtblSubtractFromMap(VD_FP);
	break;

      case VD_ITBL_UP_BTN:  /* selection of the move map item up button */
	VDtblMapItemMoveUp(VD_FP);
	break;

      case VD_ITBL_DN_BTN:  /* selection of the move map item Down button */
	VDtblMapItemMoveDown(VD_FP);
	break;
      case VD_TBL_SELECT_ITEMS: /* button to select items command  61*/ 
	VDhdrGetItems(VD_FP);
	/* 
	 * this is done to make the ITEM_LIST local and to make it completely
	 * independent of anything that happened over in the selection operations
	 */
	
	break;

	/* the style selection button */
      case VD_ITBL_STYLE_BTN:
	VDhdrGetStyleFile( VD_FP );
	VDtblMatchToMap(VD_FP);
	break;

	/* the style selection text gadget */
      case VD_ITBL_STYLE_FLD:
	VDhdrGetStyleFileText( VD_FP );
	VDtblMatchToMap(VD_FP);
	break;
       default :
	
	break;
    }
    
wrapup :
    __DBGpr_com(" Free strList ");
    _FREE( strList );

    __DBGpr_com(" Free intList ");
    _FREE( intList );

    __DBGpr_com(" Free loNames ");
    _FREE( loNames );

    __DBGpr_com(" Free loDescs ");
    _FREE( loDescs );

    __DBGpr_com(" Free Done ");
    UI_status("Do Something");
    
   End
   return OM_S_SUCCESS;
}

/*+me
 ---------------------------------------------------------------------------
  Public Message init_form

  Abstract
        This method initializes the form

  Arguments
        IGRlong         *sts            O       Return code

  Notes/Remarks

  Status/Return Code
      status == OM_S_SUCCESS
 ---------------------------------------------------------------------------
-me*/

method  init_form ( long * sts )
{
    IGRint		i, 
			itemNoOpt = 0;
    IGRshort		nbTypes   = 0;
    IGRlong		msg,
			status = OM_S_SUCCESS;
    IGRchar		(*tblTypes)[VD_DRWLO_CHR_IDFLD] = NULL;
    Form		tmp_ptr;
    
    
    SetProc( VDCmdPlHdr.init_form ); Begin

    *sts = VD_SUCCESS;
    
    /* init some things */
    
    SELECT_NODE.objid = NULL_OBJID;
    SELECT_LIST = NULL;
    NODE_CNT = 0;
    
    
    /* get the list of table types */

    status = VD_drwlo_gettp( &msg, &nbTypes, NULL );
    CheckRC( status, msg );

    __DBGpr_int( "Number of table types", nbTypes );

    if( !(status & msg & 1) || !nbTypes )
    {
	*sts = VD_ERROR;
	UI_status( "No table layouts found : command terminated" );
	goto wrapup;
    }

    tblTypes = (IGRchar (*)[VD_DRWLO_CHR_IDFLD]) malloc(
			sizeof(IGRchar) * VD_DRWLO_CHR_IDFLD * nbTypes );
    if( !tblTypes )
    {
	*sts = VD_ERROR;
        __DBGpr_com( "init_form : ERROR in dynamic allocation" );
	UI_status( "Error in dynamic allocation : command terminated" );
	goto wrapup;
    }
    
    status = VD_drwlo_gettp( &msg, &nbTypes, (IGRchar *)tblTypes );
    __CheckRC( status, msg, "VD_drwlo_gettp : list", wrapup );

    __DBGpr_int( "Number of table types", nbTypes );
    /* Modified by Ming for CR179901748 */
    if( me->mytype == VD_CMD_TBL_HDR )
    {
      __DBGpr_com("doing setup VD_CMD_TBL_HDR");
      FIg_erase( VD_FP, VD_STBL_CR_TYPE_TXT );
      FIg_erase( VD_FP, VD_STBL_CR_TYPE_FLD );
      FIg_erase( VD_FP, VD_STBL_STAGE_TXT );
      FIg_erase( VD_FP, VD_STBL_STAGE_FLD );
      FIg_erase( VD_FP, VD_STBL_NAME_TXT );
      FIg_erase( VD_FP, VD_STBL_NAME_FLD );
      FIg_erase( VD_FP, VD_STBL_TREESET_FLD );
      FIg_erase( VD_FP, VD_STBL_INDEXTYP_TXT );
      FIg_erase( VD_FP, VD_STBL_INDEXTYP_FLD ); 
      FIg_erase( VD_FP, VD_STBL_TBL_TITLE );
      FIg_erase( VD_FP, VD_ITBL_TBL_TITLE );
      FIg_erase( VD_FP, VD_STBL_FILE_TXT );
      FIg_erase( VD_FP, VD_STBL_SET_TXT );
      FIg_erase( VD_FP, VD_STBL_TYPE_TXT );
      FIg_erase( VD_FP, VD_STBL_ITEM_TGL );
      FIg_erase( VD_FP, VD_STBL_ITEM_TXT );
      FIg_erase( VD_FP, VD_STBL_STARTNO_FLD );
      FIg_erase( VD_FP, VD_STBL_STARTNO_TXT );
      FIg_erase( VD_FP, VD_STBL_ADS_FLD );
      FIg_erase( VD_FP, VD_STBL_ADS_TXT );

      FIg_erase( VD_FP, VD_ITBL_IMPORTF_TXT);
      FIg_erase( VD_FP, VD_ITBL_IMPORTF_FLD);
      FIg_erase( VD_FP, VD_ITBL_SEPARATOR_TXT);
      FIg_erase( VD_FP, VD_ITBL_SEPARATOR_FLD);

      FIg_display( VD_FP, VD_HDR_TBL_TITLE );
      /* erase the VD_CMD_ITBL_PL stuff */
      FIg_erase( VD_FP,VD_ITBL_COLS_FLD);
      FIg_erase( VD_FP,VD_ITBL_DAT_TXT);
      FIg_erase( VD_FP,VD_ITBL_MAP_TXT);
      FIg_erase( VD_FP,VD_ITBL_COL_TXT);
      FIg_erase( VD_FP,VD_ITBL_ADD_BTN);
      FIg_erase( VD_FP,VD_ITBL_SUB_BTN);
      FIg_erase( VD_FP,VD_ITBL_MVS_TXT);
      FIg_erase( VD_FP, VD_ITBL_UP_BTN);
      FIg_erase( VD_FP, VD_ITBL_DN_BTN);
      FIg_erase( VD_FP, VD_ITBL_MID_LINE);
      FIg_erase( VD_FP, VD_ITBL_STYLE_FLD);
      FIg_erase( VD_FP, VD_ITBL_STYLE_BTN);
    }
    else if( me->mytype == VD_CMD_STBL_PL )
    {
      __DBGpr_com("doing setup VD_CMD_STBL_PL");
      FIg_display( VD_FP, VD_STBL_CR_TYPE_TXT );
      FIg_display( VD_FP, VD_STBL_CR_TYPE_FLD );
      FIg_display( VD_FP, VD_STBL_STAGE_TXT );
      FIg_display( VD_FP, VD_STBL_STAGE_FLD );
      FIg_display( VD_FP, VD_STBL_NAME_TXT );
      FIg_display( VD_FP, VD_STBL_NAME_FLD );
      FIg_display( VD_FP, VD_STBL_TREESET_FLD );
      FIg_display( VD_FP, VD_STBL_TBL_TITLE );
      FIg_display( VD_FP, VD_STBL_FILE_TXT );
      FIg_display( VD_FP, VD_STBL_SET_TXT );
      FIg_display( VD_FP, VD_STBL_TYPE_TXT );
      FIg_display( VD_FP, VD_STBL_ITEM_TGL );
      FIg_display( VD_FP, VD_STBL_ITEM_TXT );
      FIg_display( VD_FP, VD_STBL_ADS_FLD );
      FIg_display( VD_FP, VD_STBL_ADS_TXT );
      FIg_display( VD_FP, VD_ITBL_IMPORTF_TXT);
      FIg_display( VD_FP, VD_ITBL_IMPORTF_FLD);
      FIg_get_state( VD_FP, VD_STBL_ITEM_TGL, &itemNoOpt );
      if( itemNoOpt ) {
        FIg_display( VD_FP, VD_STBL_STARTNO_FLD );
        FIg_display( VD_FP, VD_STBL_STARTNO_TXT );
      }
      else {
        FIg_erase( VD_FP, VD_STBL_STARTNO_FLD );
        FIg_erase( VD_FP, VD_STBL_STARTNO_TXT );
      }

      FIg_erase( VD_FP, VD_HDR_TBL_TITLE );
      FIg_erase( VD_FP, VD_STBL_INDEXTYP_TXT );
      FIg_erase( VD_FP, VD_STBL_INDEXTYP_FLD );
      FIg_erase( VD_FP, VD_ITBL_TBL_TITLE );
      /* erase the VD_CMD_ITBL_PL stuff */
      FIg_erase( VD_FP,VD_ITBL_COLS_FLD);
      FIg_erase( VD_FP,VD_ITBL_DAT_TXT);
      FIg_erase( VD_FP,VD_ITBL_MAP_TXT);
      FIg_erase( VD_FP,VD_ITBL_COL_TXT);
      FIg_erase( VD_FP,VD_ITBL_ADD_BTN);
      FIg_erase( VD_FP,VD_ITBL_SUB_BTN);
      FIg_erase( VD_FP,VD_ITBL_MVS_TXT);
      FIg_erase( VD_FP, VD_ITBL_UP_BTN);
      FIg_erase( VD_FP, VD_ITBL_DN_BTN);
      FIg_erase( VD_FP, VD_ITBL_STYLE_FLD);
      FIg_erase( VD_FP, VD_ITBL_STYLE_BTN);
      FIg_erase( VD_FP, VD_ITBL_SEPARATOR_TXT);
      FIg_erase( VD_FP, VD_ITBL_SEPARATOR_FLD);
      FIg_erase( VD_FP, VD_ITBL_MID_LINE);
      FIg_erase( VD_FP, VD_ITBL_IMPORTF_TXT);
      FIg_erase( VD_FP, VD_ITBL_IMPORTF_FLD);
      VDtrTblMgrFillSets( VD_FP, VD_STBL_TREESET_FLD );
      VDtblCmdForm_fillADS( VD_FP, VD_STBL_ADS_FLD );
    }
    else if( me->mytype == VD_CMD_ITBL_PL )
    {
      __DBGpr_com("doing setup VD_CMD_ITBL_PL");
      FIg_erase( VD_FP, VD_STBL_CR_TYPE_TXT );
      FIg_erase( VD_FP, VD_STBL_CR_TYPE_FLD );
      FIg_erase( VD_FP, VD_STBL_STAGE_TXT );
      FIg_erase( VD_FP, VD_STBL_STAGE_FLD );
      FIg_erase( VD_FP, VD_STBL_NAME_TXT );
      FIg_erase( VD_FP, VD_STBL_NAME_FLD );
      FIg_erase( VD_FP, VD_STBL_TREESET_FLD );
      FIg_erase( VD_FP, VD_STBL_INDEXTYP_TXT );
      FIg_erase( VD_FP, VD_STBL_INDEXTYP_FLD );
      FIg_erase( VD_FP, VD_STBL_TBL_TITLE );
      FIg_erase( VD_FP, VD_STBL_FILE_TXT );
      FIg_erase( VD_FP, VD_STBL_SET_TXT );
      FIg_erase( VD_FP, VD_STBL_TYPE_TXT );
      FIg_erase( VD_FP, VD_STBL_ITEM_TGL );
      FIg_erase( VD_FP, VD_STBL_ITEM_TXT );
      FIg_erase( VD_FP, VD_STBL_STARTNO_FLD );
      FIg_erase( VD_FP, VD_STBL_STARTNO_TXT );
      FIg_erase( VD_FP, VD_STBL_ADS_FLD );
      FIg_erase( VD_FP, VD_STBL_ADS_TXT );

      FIg_erase( VD_FP, VD_HDR_TBL_TITLE );
      FIg_erase( VD_FP, VD_ITBL_TBL_TITLE );

      FIg_display( VD_FP, VD_ITBL_TBL_TITLE );
      FIg_display( VD_FP, VD_ITBL_IMPORTF_TXT);
      FIg_display( VD_FP, VD_ITBL_IMPORTF_FLD);
      FIg_display( VD_FP, VD_ITBL_SEPARATOR_TXT);
      FIg_display( VD_FP, VD_ITBL_SEPARATOR_FLD);
      __DBGpr_com("displaying the gadgets for cols");
      FIg_display( VD_FP, VD_ITBL_COLS_FLD);
      FIg_display( VD_FP, VD_ITBL_DAT_TXT);
      FIg_display( VD_FP, VD_ITBL_MAP_TXT);
      FIg_display( VD_FP, VD_ITBL_COL_TXT);
      FIg_display( VD_FP, VD_ITBL_ADD_BTN);
      FIg_display( VD_FP, VD_ITBL_SUB_BTN);
      FIg_display( VD_FP, VD_ITBL_MVS_TXT);
      FIg_display( VD_FP, VD_ITBL_UP_BTN);
      FIg_display( VD_FP, VD_ITBL_DN_BTN);
      FIg_display( VD_FP, VD_ITBL_MID_LINE);
      // FIg_display( VD_FP, VD_ITBL_STYLE_FLD);
      // FIg_display( VD_FP, VD_ITBL_STYLE_BTN);  
    }

    /* set number of types found in the form */

    FIfld_set_text( VD_FP, VD_HDR_TBL_TYPE_FLD, 0, 0, 
			tblTypes[0], FALSE );

    /* update the associative list of table types in the form */
 
    __DBGpr_com( "List of table types" );

    for( i = 0 ; i < nbTypes ; i++ )
    {
	VDfld_set_list_text( VD_FP, VD_HDR_TBL_TYPE_FLD, i, 0,
				tblTypes[i], FALSE );
    }
    
    
wrapup :

    if(tblTypes) _FREE( tblTypes );

    if( *sts == VD_ERROR )
	me->state = _terminate;
    End
    return OM_S_SUCCESS;
}


IGRlong VDtblCmdSetIndexTableType( IGRchar  *indexType )
{
  IGRlong status;


  status = 0;

  if( indexType )
    strcpy( INDEXTABLETYPE, indexType );
  else
    goto wrapup;

  status = OM_S_SUCCESS;
  

wrapup:
  return status;
}

IGRlong VDtblCmdGetIndexTableType( IGRchar  *indexType )
{
  IGRlong status;

 
  status = 0;

  if( indexType )
    strcpy( indexType, INDEXTABLETYPE );
  else
    goto wrapup;

  status = OM_S_SUCCESS;
  

wrapup:
 
  return status;
}

IGRlong VDtblCmdSetNameID(TGRid  nodeID )
{
  IGRlong status;
  status = 0;
 
  SELECT_NODE = nodeID;
  
  status = OM_S_SUCCESS;
  

wrapup:
  return status;
}

IGRlong VDtblCmdReportNameIDParent(char *form_ptr, TGRid  *nodeID )
{
  IGRlong status;
  IGRchar buf[128];
  TGRid   parID,treeID;
  IGRchar nodeType[128],nodeName[128];

  status = 0;
  strcpy(buf,"");
  if( nodeID ) {
    if(nodeID->objid == NULL_OBJID) {
      strcpy(buf,"Tree does not place tables");
      goto wrapup;
    }
    
    VDctbsGetTreeID(form_ptr,&treeID);
    if(nodeID->objid == treeID.objid) {
      sprintf(buf,"Selected Tree Top: [%d,%d]",treeID.osnum,treeID.objid);
      goto wrapup;
    } else {
      VDctxGetTreeParent(nodeID,&parID);
      if(parID.objid == NULL_OBJID) {
	strcpy(buf,"Unable to Get Selection Parent");
	goto wrapup;
      }
      vdtr$GetNodeType(nodeID = &parID,nodeType = nodeType);
      vdtr$GetNodeName(nodeID = &parID,nodeName = nodeName);
      sprintf(buf,"P[%s %s] N[%d,%d]",nodeType,nodeName,nodeID->osnum,nodeID->objid);
      goto wrapup;
    }
  } else {
    strcpy(buf,"Selected Invalid Node");
    goto wrapup;
  }
  
  
wrapup:
  status = OM_S_SUCCESS;
  VIg_set_text(form_ptr,10,buf);
  return status;
}

IGRlong VDtblCmdGetNameID( TGRid  *nodeID )
{
  IGRlong status;

  status = 0;
  if(nodeID) {
    *nodeID = SELECT_NODE;
  } else {
    goto wrapup;
  }
  

  status = OM_S_SUCCESS;
  

wrapup:
  return status;
}
IGRlong VDtblCmdSetSelectList( TGRid  **nodeID,IGRint *nodeCnt )
{

  IGRlong status;
  IGRint i;

  status = 0;
 
  if( *nodeID ) SELECT_LIST = *nodeID;
  else goto wrapup;

  if( nodeCnt ) NODE_CNT = *nodeCnt;
  else goto wrapup;

  status = OM_S_SUCCESS;
  

wrapup:
  return status;
}

IGRlong VDtblCmdGetSelectList( TGRid  **nodeID,IGRint *nodeCnt )
{
  IGRlong status;

  status = 0;
  
  if( *nodeID )
    *nodeID = SELECT_LIST;
  else
    goto wrapup;
  if( nodeCnt )
    *nodeCnt = NODE_CNT;
  else
    goto wrapup;
  status = OM_S_SUCCESS;
  

wrapup:
  return status;
}

IGRlong VDtblNodeListPrintTest()
{
  IGRint i;
  TVDctxBaseInfo baseInfo;
  TGRid testID;

   printf("\n\n***************** Node Test Print ****************\n");
  
 
  for(i = 0; i < NODE_CNT;i++) {
    testID = SELECT_LIST[i];
    
    VDctxGetBaseInfo(&testID,&baseInfo);
  
  printf("node [%s][%s] [%d][%d] #[%d]\n",baseInfo.nodeType,baseInfo.nodeName,SELECT_LIST[i].osnum,SELECT_LIST[i].objid,i);
    
  }
  testID = SELECT_NODE;
  VDctxGetBaseInfo(&testID,&baseInfo);
  printf("SELECT_NODE [%s][%s] [%d][%d]\n",baseInfo.nodeType,baseInfo.nodeName,SELECT_NODE.osnum,SELECT_NODE.objid);
  printf("***************** Node Test Print ****************\n");
  
}


static IGRint  intcmp( int* e1, int* e2 )
{
	return (*e1 - *e2);
}

/* display routines for CTBI stuff */
/************************************************************
 *
 * Display the Tables column #2 stuff 
 * added for CR5006 (Create Table by Import) ~pn
 *
 ************************************************************/
IGRlong VDtblPostTableData(Form form,IGRchar *tblLayoutName)
{
  IGRint        retFlag = 0;
  IGRchar	filename[80], separator[10],partPath[1024],buf1[1024];
  IGRchar       **fileLines,*p,buf[1024],attr1[1024];
  IGRint        col0    = 0;
  IGRint        col1    = 1;
  IGRint        col2    = 2;
  IGRint        sts     = 0;
  IGRint        fileSts = 0;
  IGRint        status  = 0;
  IGRint        lineCnt = 0;
  IGRint        colCnt  = 0;
  IGRint        recCnt  = 0;
  IGRint        rows    = 0;
  IGRint        i       = 0;
  IGRlong		msg;
  IGRdouble           height;
  IGRshort            nbDatRecs	= 0;
  IGRint              num_rows  = 0;
  struct VDdrwlo_data      *datRecs	= NULL;
  struct  VDdrwlo_apifix   *fldRecs     = NULL;
  IGRchar       **fldNames;
  IGRint         fldNameCnt = 0;
  
  
  __DBGpr_com(">>> VDtblPostTableData");
  if(!tblLayoutName) {
    /* clear out the col #2 */
    FIfld_get_num_rows(form, VD_ITBL_COLS_FLD, &rows);
    if(rows < colCnt) rows = colCnt;
    FIfld_set_num_rows(form, VD_ITBL_COLS_FLD, rows);
    strcpy(buf,"");
    for(i = 0;i < rows;i++) {
      FIfld_set_text( form, VD_ITBL_COLS_FLD, i, col2, buf, FALSE);
    }
    goto wrapup;
  }
  
  
  if(strcmp(tblLayoutName,"")) {
    
    /* use this location for ITBL update col #2 CR5006 ~pn */
 
    /* just go get the info if or if not it comes back */
    VDtblGetfldNames(tblLayoutName, 
		     1,
		     &fldNames,
		     &fldNameCnt);
    if(fldNameCnt == 0) goto wrapup;
    /* loop through and print on the form the data */
    
    FIfld_get_num_rows(form, VD_ITBL_COLS_FLD, &num_rows);
    strcpy(buf,"");
    for(i = 0;i <num_rows;i++) {
      FIfld_set_text( form, VD_ITBL_COLS_FLD, i, 2, buf, FALSE);
    }
    /* max the number of rows on the form */
    if(num_rows < fldNameCnt) {
      FIfld_set_num_rows( form, VD_ITBL_COLS_FLD,fldNameCnt);
    }
    /* set the data into the col #2 slot */
    for(i = 0;i <fldNameCnt;i++){
      sprintf(attr1,"%s",fldNames[i]);
      if(i == 0) {
	if(!strcmp(attr1,"")) {
	  strcpy(attr1,"*Key*");
	}
      }
      
      /* need to get some data here from col Names on header */
      
      sprintf(buf,"C%d  %s",i+1,attr1);
      if(i > 8) sprintf(buf,"C%d %s",i+1,attr1);
      FIfld_set_text( form, VD_ITBL_COLS_FLD, i, 2, buf, FALSE);
    }
  }
  FIfld_set_text( form, FI_MSG_FIELD, 0, 0,"", FALSE );
  _FREE( datRecs );
  _FREE( fldRecs );
  _LOOPFREE( fldNames,fldNameCnt);
  retFlag = 1;
wrapup:
  __DBGpr_com("<<< VDtblPostTableData");
  return retFlag;
}

/************************************************************
 *
 * Display the XML file data to the map etc
 *
 ************************************************************/
IGRlong VDtblPostXMLFileData(Form form)
{
  IGRint        retFlag = 0;
  IGRchar	filename[80], separator[10],partPath[1024],xslFileName[80];
  IGRchar       **fileLines,*p,buffer[1024],*attrVal,attrData[1024],*r;
  IGRchar       *colBuf,**strsOut;
  IGRchar       nodeType[1028],styleSheetName[1028];
  IGRchar       f_href[1028];
  IGRchar       f_type[1028];
  IGRint        col0    = 0;
  IGRint        col1    = 1;
  IGRint        col2    = 2;
  IGRint        sts     = 0;
  IGRint        fileSts = 0;
  IGRint        lineCnt = 0;
  IGRint        colCnt  = 0;
  IGRint        rows    = 0;
  IGRint        i       = 0;
  IGRint        j       = 0;
  IGRint        strLen  = 0;
  IGRint        nbCols  = 0;
  IGRint        xmlData = 0;
  IGRint        fileIsXML   = 0;
  IGRint        strsOutCnt  = 0;
  IGRchar       buf[128];
  TGRid         xmlTreeID,xslTreeID,xmlOutTreeID;
  TGRid        *xmlListIDs = NULL;
  IGRint        xmlListIDsCnt = 0;
  IGRint        child = 1;
  IGRint        fldsCnt = 0;
  TVDfld        flds[VDFLD_MAX_CNT];
  IGRint        xpos = 0;
  IGRint        ypos = 0;
  IGRint        accept = 0;  

  __DBGpr_com(">>> VDtblPostXMLFileData");
  /* inits */
  filename[0]       = '\0';
  separator[0]      = '\0';
  buffer[0]         = '\0';
  nodeType[0]       = '\0';
  styleSheetName[0] = '\0';
  f_type[0]         = '\0';
  f_href[0]         = '\0';
  xslFileName[0]    = '\0';
  colBuf            = NULL;
  xmlTreeID.objid    = NULL_OBJID;
  xslTreeID.objid    = NULL_OBJID; 
  xmlOutTreeID.objid = NULL_OBJID;
  
  if(form == NULL) goto wrapup;

  /* read the file name */
  FIg_get_text( form, VD_ITBL_IMPORTF_FLD, filename );
  
  FIfld_get_num_rows(form, VD_ITBL_COLS_FLD, &rows);
  if( !VD_wordcount( filename ) )
  {
    FIfld_set_text( form, FI_MSG_FIELD, 0, 0, 
		    "Import file name not input yet", FALSE );
    VDtblClearCol(form,0);
    VDtblClearCol(form,1);
    goto wrapup;
  }
  /* read the sep name */	     
  FIg_get_text( form, VD_ITBL_SEPARATOR_FLD, separator );
  if( !VD_wordcount( separator ) ) 
  {
    FIfld_set_text( form, FI_MSG_FIELD, 0, 0,
		    "Separator not input yet", FALSE );
    goto wrapup;
  }   
  
  /* validate the file opens ok (0nly from approved Path list) */
  strcpy(partPath,"");
  __DBGpr_str( "filename", filename );

  fileSts = vd$xmltbl_getRowData (xmlFile         = filename,
				  separator       = separator,
				  colBuf          = &colBuf,
				  nbCols          = &nbCols  );
  
  /* if it did opened */
  //if(lineCnt > 0) {	// replaced by ylong 10-16-01
  if(nbCols > 0) {
    /* make the selection of a stylesheet disappear */
    FIg_set_text( form, VD_ITBL_STYLE_FLD,"");
    FIg_erase( form, VD_ITBL_STYLE_FLD);
    FIg_erase( form, VD_ITBL_STYLE_BTN);

    /*
     * This option only works if the table is OPE 
     * so post it here 
     */
    /* clear out the col #0 */
    FIfld_set_num_rows(form, VD_ITBL_COLS_FLD, rows);
    strcpy(buffer,"");
    for(i = 0;i < rows;i++) {
      FIfld_set_text( form, VD_ITBL_COLS_FLD, i, col0, buffer, FALSE);
    }
    /* loop around putting in the numbers on col #0 */
    for(i = 0;i < nbCols;i++) {
      VDdrwUnMakeSepDataString(colBuf,separator,&strsOut,&strsOutCnt);
      strcpy(attrData,strsOut[i]);
      
      strLen = strlen(attrData);
      r = attrData;
      for(j = 0;j < strLen;j++) {
	if(!(*r == ' ')) {
	  strcpy(attrData,r);
	  break;
	}
	r++;
      }
      sprintf(buffer,"C%d  %s",i+1,attrData); 
      if(i > 8) sprintf(buffer,"C%d %s",i+1,attrData);  
      FIfld_set_text( form, VD_ITBL_COLS_FLD, i, col0, buffer, FALSE);
    }
    /* finish up with a blank line */
    strcpy(buffer,"C0 *BLANK LINE*");
    FIfld_set_text( form, VD_ITBL_COLS_FLD, i, col0, buffer, FALSE);
    if(i < 2) VIg_set_text(form,10,"Table may not be valid.");
    if(i < 1) VIg_set_text(form,10,"Table is not valid.");
    retFlag = 1;
    goto wrapup;
  } else {
    /* so lets make an xml tree here */
    VDxdomCreateTreeFromXmlFile   (filename,&xmlTreeID);
    /* no xmlTreeID is a mistake! not proper tree */
    if(xmlTreeID.objid == NULL_OBJID) {
      r = strrchr(filename,'/');
      r++;
      strcpy(filename,r);
      sprintf(buf,"Bad XML: %s",filename);
      FIfld_set_text( form, FI_MSG_FIELD, 0, 0,
		      buf, FALSE );
      FIg_erase( form, VD_ITBL_STYLE_FLD);
      FIg_erase( form, VD_ITBL_STYLE_BTN);
      FIg_set_text( form, VD_ITBL_IMPORTF_FLD,"");
      VDtblClearCol(form,0);
      VDtblClearCol(form,1);
      goto wrapup;
    }
    
    /* lets fetch if any its internal nodes */
    vdfile$GetNodeList(nodeID      = &xmlTreeID,
		       child       = &child,
		       nodeList    = &xmlListIDs,
		       nodeListCnt = &xmlListIDsCnt);

    /* no nodes is a mistake! (no data) */
    if(xmlListIDsCnt < 1) {
      r = strrchr(filename,'/');
      r++;
      strcpy(filename,r);
      sprintf(buf,"No XML Data: %s",filename);
      FIfld_set_text( form, FI_MSG_FIELD, 0, 0,
		      buf, FALSE );
      FIg_erase( form, VD_ITBL_STYLE_FLD);
      FIg_erase( form, VD_ITBL_STYLE_BTN);
      FIg_set_text( form, VD_ITBL_IMPORTF_FLD,"");
      VDtblClearCol(form,0);
      VDtblClearCol(form,1);
      goto wrapup;	
    }
    /* display the style file button and field */
    FIg_display( form, VD_ITBL_STYLE_FLD);
    FIg_display( form, VD_ITBL_STYLE_BTN);

    /* set the style file field to blank */
    FIg_set_text( form, VD_ITBL_STYLE_FLD,"");

    /* sweep through and find <ISDP-stylesheet> href... */
    nodeType[0] = '\0';
    xslTreeID.objid == NULL_OBJID;
    vdtr$GetDocStyleSheetID(xmlID  = &xmlTreeID,
			    filter = "ISDP-stylesheet",
			    xslID  = &xslTreeID,
			    xslSS  = xslFileName);
    
    FIg_set_text( form, VD_ITBL_STYLE_FLD,xslFileName);
#if 0
    for(i = 0;i < xmlListIDsCnt;i++) {
      VDctxGetNodeType(&xmlListIDs[i],nodeType);
      if(!strcmp(nodeType,"ISDP")) {
	/* fetch the node attributes */
	VDctxGetFldAtrsID(NULL,&xmlListIDs[i],&fldsCnt,flds);
	for(j = 0;j < fldsCnt;j++) {
	  /* get the field description */
	  VDfldGetFldDesc(&flds[j],buffer);
	  p = strstr(buffer,"HREF");
	  if(p != NULL) {
	    vdtr$GetDelimitedStr(impStr = p,
				 outStr = xslFileName,
				 delChr = '=',
				 posStr = 2);
	    VD_stripString( xslFileName );
	    FIg_set_text( form, VD_ITBL_STYLE_FLD,xslFileName);
	    break;
	  }
	}
	break;
      }
    }  
#endif    
  }
  
  /* if there is no style sheet */
  FIg_get_text( form,VD_ITBL_STYLE_FLD, xslFileName);
  if(!strcmp(xslFileName,"")) {
    sprintf(buf,"Stylesheet Needed.");
    FIfld_set_text( form, FI_MSG_FIELD, 0, 0,
		    buf, FALSE ); 
    /* clear out the map */
    strcpy(buffer,"");
    for(i = 0;i < rows;i++) {
      FIfld_set_text( form, VD_ITBL_COLS_FLD, i, col0, buffer, FALSE);
    }
    FIg_set_text( form, VD_ITBL_STYLE_FLD,"");
    goto wrapup;
  }

  /* need to process the xsl and xml to make new xml tree */
  // VDxdomCreateStyleSheetFromFile(xslFileName,&xslTreeID);
  /* clear out the col #0 */
  FIfld_set_num_rows(form, VD_ITBL_COLS_FLD, rows);
  strcpy(buffer,"");
  for(i = 0;i < rows;i++) {
    FIfld_set_text( form, VD_ITBL_COLS_FLD, i, col0, buffer, FALSE);
  }
  /* check for valid xslTreeID */
  if(xslTreeID.objid == NULL_OBJID) {
    sprintf(buf,"Valid Stylesheet needed.");
    FIfld_set_text( form, FI_MSG_FIELD, 0, 0,
		    buf, FALSE ); 
    FIg_set_text( form, VD_ITBL_STYLE_FLD,"");
    goto wrapup;
  }

  /* need to process the xsl and xml trees into xmlOutTreeID */
  VDxdomApplyStyleSheet(&xslTreeID,&xmlTreeID,NULL,&xmlOutTreeID);
  if(xmlOutTreeID.objid == NULL_OBJID) {
    goto wrapup;
  }

  /* Why call this again ? ylong 10-16-01
  fileSts = vd$xmltbl_getRowData (xtreeID         = &xmlOutTreeID,
				  separator       = separator,
				  colBuf          = &colBuf,
				  nbCols          = &nbCols  );
  */

  /* loop around putting in the numbers on col #0 */
  for(i = 0;i < nbCols;i++) {
    VDdrwUnMakeSepDataString(colBuf,separator,&strsOut,&strsOutCnt);
    strcpy(attrData,strsOut[i]);
    
    strLen = strlen(attrData);
    r = attrData;
    for(j = 0;j < strLen;j++) {
      if(!(*r == ' ')) {
	strcpy(attrData,r);
	break;
      }
      r++;
    }
    sprintf(buffer,"C%d  %s",i+1,attrData); 
    if(i > 8) sprintf(buffer,"C%d %s",i+1,attrData);  
    FIfld_set_text( form, VD_ITBL_COLS_FLD, i, col0, buffer, FALSE);
  }

  /* finish up with a blank line */
  strcpy(buffer,"C0 *BLANK LINE*");
  FIfld_set_text( form, VD_ITBL_COLS_FLD, i, col0, buffer, FALSE);
  if(i < 2) VIg_set_text(form,10,"Table may not be valid.");
  if(i < 1) VIg_set_text(form,10,"Table is not valid.");
  
  retFlag = 1;
wrapup:

  if(xmlTreeID.objid != NULL_OBJID)    VDxdomDeleteNode(&xmlTreeID);
  if(xslTreeID.objid != NULL_OBJID)    VDxdomDeleteStyleSheet(&xslTreeID);
  if(xmlOutTreeID.objid != NULL_OBJID) VDxdomDeleteNode(&xmlOutTreeID);

  __DBGpr_com("<<< VDtblPostXMLFileData Free first ");
  if(lineCnt > 0)        _LOOPFREE( fileLines, lineCnt );
  if(strsOutCnt > 0)     _LOOPFREE( strsOut,strsOutCnt );
  if(xmlListIDsCnt > 0)  _FREE( xmlListIDs );
  if(nbCols > 0)         _FREE(colBuf);

  __DBGpr_com("<<< VDtblPostXMLFileData");

  return retFlag;
}

/************************************************************
 *
 * Display the CTBI column #0 list of ASCII data
 * added for CR5006 (Create Table by Import) ~pn
 * note this is specifically for the ASCII tables and 
 * now handles XML (basic format for tables)
 * updates form to handle Sep() disappear on XML file
 *
 ************************************************************/
IGRlong VDtblPostASCIIFileData(Form form)
{
  IGRint        retFlag = 0;
  IGRchar	filename[80], separator[10],partPath[1024];
  IGRchar       **fileLines,*p,buffer[1024],*attrVal,attrData[1024],*r;
  IGRchar       *colBuf,**strsOut;
  IGRint        col0    = 0;
  IGRint        col1    = 1;
  IGRint        col2    = 2;
  IGRint        sts     = 0;
  IGRint        fileSts = 0;
  IGRint        lineCnt = 0;
  IGRint        colCnt  = 0;
  IGRint        rows    = 0;
  IGRint        i       = 0;
  IGRint        j       = 0;
  IGRint        strLen  = 0;
  IGRint        nbCols  = 0;
  IGRint        xmlData = 0;
  IGRint        fileIsXML   = 0;
  IGRint        strsOutCnt  = 0;
  IGRchar       buf[128];
  
  
  __DBGpr_com(">>> VDtblPostASCIIFileData");
  /* inits */
  filename[0] = '\0';
  separator[0] = '\0';
  buffer[0] = '\0';

  if(form == NULL) goto wrapup;

  /* read the file name */
  /* if this is going to be ASCII forget any XML stuff */
  FIg_erase( form, VD_ITBL_STYLE_FLD);
  FIg_erase( form, VD_ITBL_STYLE_BTN);
  FIg_set_text( form, VD_ITBL_STYLE_FLD,"");

  FIg_get_text( form, VD_ITBL_IMPORTF_FLD, filename );
  FIfld_get_num_rows(form, VD_ITBL_COLS_FLD, &rows);
  if( !VD_wordcount( filename ) )
  {
    FIfld_set_text( form, FI_MSG_FIELD, 0, 0, 
		    "Import file name not input yet", FALSE );

    VDtblClearCol(form,0);
    VDtblClearCol(form,1);
    goto wrapup;
  }

  /* read the sep name */	     
  FIg_get_text( form, VD_ITBL_SEPARATOR_FLD, separator );
  if( !VD_wordcount( separator ) ) 
  {

    FIfld_set_text( form, FI_MSG_FIELD, 0, 0,
		    "Separator not input yet", FALSE );
    goto wrapup;
  }   
  /* validate the file opens ok (0nly from approved Path list) */
  strcpy(partPath,"");
  __DBGpr_str( "filename", filename );
  fileSts = vd$astbl_getRowData ( filename = filename,
				  rowBuf   = &fileLines,
				  nbRows   = &lineCnt );

  /* if it did not open */
  if(!(fileSts & 1)) {
    r = strrchr(filename,'/');
    strcpy(filename,r);
    r++;
    sprintf(buf,"No Data: %s",filename);
    FIfld_set_text( form, FI_MSG_FIELD, 0, 0,
		    buf, FALSE );
    FIg_set_text( form, VD_ITBL_IMPORTF_FLD,"");
    VDtblClearCol(form,0);
    VDtblClearCol(form,1);
    goto wrapup;
  }
  /* if it had no data */
  if(lineCnt < 1) {
    r = strrchr(filename,'/');
    strcpy(filename,r);
    r++;
    sprintf(buf,"No Data: %s",filename);
    FIfld_set_text( form, FI_MSG_FIELD, 0, 0,
		    buf, FALSE );
    FIg_set_text( form, VD_ITBL_IMPORTF_FLD,"");
    VDtblClearCol(form,0);
    VDtblClearCol(form,1);
    goto wrapup;
  }
  sts = 0;
  for(i = 0;i < lineCnt;i++) {
    strcpy(buffer,fileLines[i]);
    p = NULL;
    p = strstr(buffer,separator);
    if(p != NULL) {
      sts = 1;
      break;
    } 
  }
  /* if no seps in file rows question continue */
  if(!(sts & 1)) {
    strcpy(buffer,"File data lacks separators: Use Anyway?");
    sts = 0;
    sts = GRconfirm_box(buffer);
    if(!(sts & 1)) {
      /* blank the file name on the form */
      FIg_set_text( form, VD_ITBL_IMPORTF_FLD, "" );
      /* clean up column #0 */
      strcpy(buffer,"");
      for(i = 0;i < rows;i++) {
	FIfld_set_text( form, VD_ITBL_COLS_FLD, i, col0, buffer, FALSE);
      }
      goto wrapup;
    }
  }
  /* count up the number of cols in the data */
  strcpy(buffer,fileLines[0]);
  VDdrwGetTokenCnt(buffer,
		   separator,
		   &colCnt);
  
  /* clear out the col #0 */
  FIfld_set_num_rows(form, VD_ITBL_COLS_FLD, rows);
    strcpy(buffer,"");
    for(i = 0;i < rows;i++) {
      FIfld_set_text( form, VD_ITBL_COLS_FLD, i, col0, buffer, FALSE);
    }
    VDdrwUnMakeSepDataString(fileLines[0],separator,&strsOut,&strsOutCnt);
    /* loop around putting in the numbers on col #0 */
    for(i = 0;i < colCnt;i++) {
      strcpy(attrData,strsOut[i]);
      strLen = strlen(attrData);
      r = attrData;
      for(j = 0;j < strLen;j++) {
	if(!(*r == ' ')) {
	  strcpy(attrData,r);
	  break;
	}
	r++;
      }
      sprintf(buffer,"C%d  %s",i+1,attrData); 
      if(i > 8) sprintf(buffer,"C%d %s",i+1,attrData);  
      FIfld_set_text( form, VD_ITBL_COLS_FLD, i, col0, buffer, FALSE);
    }
  
  /* finish up with a blank line */
  strcpy(buffer,"C0 *BLANK LINE*");
  FIfld_set_text( form, VD_ITBL_COLS_FLD, i, col0, buffer, FALSE);
  if(i < 2) VIg_set_text(form,10,"Table may not be valid.");
  if(i < 1) VIg_set_text(form,10,"Table is not valid.");
  
  retFlag = 1;
wrapup:
  __DBGpr_com("<<< VDtblPostASCIIFileData Free first ");
  if(lineCnt > 0) _LOOPFREE( fileLines, lineCnt );
  if(strsOutCnt > 0) _LOOPFREE( strsOut,strsOutCnt );
  if(colBuf) _FREE( colBuf );
  __DBGpr_com("<<< VDtblPostASCIIFileData");
  return retFlag;
}

/************************************************************
 *
 * clntrol the posting of FileData (by type) 
 * Controls built to handle specific data types packaged here
 *
 ************************************************************/
IGRlong VDtblPostFileData(Form form)
{
  IGRlong    retFlag = 0;
  IGRchar    fileName[1023];
  IGRint     isFileXML = 0;
  IGRchar    *p;
  
  
  
  __DBGpr_com(">>> VDtblPostASCIIFileData");

  /* check to see if the file is selected */
  FIg_get_text( form, VD_ITBL_IMPORTF_FLD, fileName );
  if(!strcmp(fileName,"")) goto wrapup;
  
  /* check to see if it is XML */
  isFileXML = VDdrw_CheckIfXML(fileName);

  if(isFileXML == 1) {
    VDtblPostXMLFileData(form);
  }  else {
    VDtblPostASCIIFileData(form);
  }

  /* check the final status */
  FIg_get_text( form, VD_ITBL_IMPORTF_FLD, fileName );
  retFlag = 1;
  
 wrapup:
  if(!strcmp(fileName,"")) {
    FIg_erase( form, VD_ITBL_STYLE_FLD);
    FIg_erase( form, VD_ITBL_STYLE_BTN);
     FIg_set_text( form, 10, "Invalid FileName Selected." ); 
  }
  __DBGpr_com("<<< VDtblPostFileData");
  return retFlag;
}

/************************************************************
 *
 * Hit the Add button 
 * 
 ************************************************************/
IGRlong VDtblAddToMap(Form form)
{
  IGRint       retFlag  = 0;
  IGRint       col0     = 0;
  IGRint       col1     = 1;
  IGRint       col2     = 2;
  IGRint       row      = 0;
  IGRint       rows     = 0;
  IGRint       sel      = 0;
  IGRint       pos      = 0;
  IGRint       i        = 0;
  IGRint       colRows1 = 0;
  IGRint       colRows2 = 0;
  IGRint       colRows0 = 0;
  IGRchar      buf[1024];
  
  __DBGpr_com(">>> VDtblAddToMap");
  /* check if there is anything to map */
  if(!VDtblCheckMapStatus(form)) goto wrapup;

  /* get the highlighted item */
  FIfld_get_active_row( form, VD_ITBL_COLS_FLD, &row, &pos );
  /* make sure the highlite is in the right column */
  FIfld_get_text( 	form, VD_ITBL_COLS_FLD, row, col0, 
			30, 
			(unsigned char *)buf, 
			&sel, &pos );
  /* be a bit careful */
  if(!(sel & 1)) goto wrapup;
  /* remove the highlight */
  FIfld_set_text( form, VD_ITBL_COLS_FLD, row, col0, buf, FALSE);  
  /* if there is any room to add to the map this item at next row */
  VDtblGetRowCount(form, 2, &colRows2);
  VDtblGetRowCount(form, 1, &colRows1);
  if(colRows2 <= colRows1) goto wrapup;
  /* add the row at the bottom of col1 */
  FIfld_set_text( form, VD_ITBL_COLS_FLD, colRows1, col1, buf, FALSE);  
  
  retFlag  = 1;
wrapup:
  __DBGpr_com("<<< VDtblAddToMap");
  return retFlag;
}

/************************************************************
 *
 * Hit the Subtract button 
 * 
 ************************************************************/
IGRlong VDtblSubtractFromMap(Form form) 
{
  IGRint       retFlag = 0;
  IGRint       status  = 0;
  IGRint       row     = 0;
  IGRint       rows    = 0;
  IGRint       pos     = 0;
  IGRint       sel     = 0;
  IGRint       col1    = 1;
  IGRint       i       = 0;
  IGRchar      buf[1024];
  
  
  __DBGpr_com(">>> VDtblSubtractFromMap");
  /* check if there is anything to map */
  if(!VDtblCheckMapStatus(form)) goto wrapup;
  
  /* get the highlighted item */
  FIfld_get_active_row( form, VD_ITBL_COLS_FLD, &row, &pos );
  /* make sure the highlite is in the right column */ 
  FIfld_get_text( 	form, VD_ITBL_COLS_FLD, row, col1, 
			30, 
			(unsigned char *)buf, 
			&sel, &pos );
  /* be a bit careful */
  if(!(sel & 1)) goto wrapup;
  /* get the max number of rows */
  FIfld_get_num_rows( form, VD_ITBL_COLS_FLD, &rows );
  /* clear out the selected row */
  strcpy(buf,"");
  /* blank this line only */
  FIfld_set_text( form, VD_ITBL_COLS_FLD, row, col1, buf, FALSE);  
  /* if it is selection outside of data */
  if(row >= rows) {
    goto wrapup;
  }
  /* collapse the other rows up */
  for(i = row;i < rows;i++) {
    /* get the next higher row */
    FIfld_get_text( 	form, VD_ITBL_COLS_FLD, i+1, col1, 
			30, 
			(unsigned char *)buf, 
			&sel, &pos );
    /* copy it here */
    FIfld_set_text( form, VD_ITBL_COLS_FLD, i, col1, buf, FALSE);  
  }

  retFlag = 1;
wrapup:
  __DBGpr_com("<<< VDtblSubtractFromMap");
  return retFlag;
}
/************************************************************
 *
 * Fill the Col #1 with a 1:1 match
 * 
 ************************************************************/
IGRlong VDtblMatchToMap(Form form)
{
  IGRint       retFlag  = 0;
  IGRint       colRows0 = 0;
  IGRint       colRows2 = 0;
  IGRint       maxRows  = 0;
  IGRint       sel      = 0;
  IGRint       pos      = 0;
  IGRint       col0     = 0;
  IGRint       col1     = 1;
  IGRint       i        = 0;
  IGRchar      buf[1024];
  
  
  __DBGpr_com(">>> VDtblMatchToMap");
  /* check if there is anything to map */
  if(!VDtblCheckMapStatus(form)) goto wrapup;
  VDtblGetRowCount(form, 0, &colRows0);
  VDtblGetRowCount(form, 2, &colRows2);
  /* set the maximum rows to display */
  maxRows = colRows0;
  if(colRows0 > colRows2) maxRows = colRows2;
  /* unconditionally clear out the map Col */
  VDtblClearMap(form);
  /* write over the data */
  for(i = 0;i < maxRows;i++) {
    FIfld_get_text( form, VD_ITBL_COLS_FLD, i, col0, 
		    30, 
		    (unsigned char *)buf, 
		    &sel, &pos ); 
    FIfld_set_text( form, VD_ITBL_COLS_FLD, i, col1, buf, FALSE);   
  }
  /* 
   * fill in the blank row notices
   * eyewash: Has no real value to user but is pretty
   * and may make user understand what is going on 
   * better
   */
  strcpy(buf,"C0 *Blank Line*");
  if( maxRows < colRows2) {
    for(i = maxRows;i < colRows2;i++) {
      FIfld_set_text( form, VD_ITBL_COLS_FLD, i, col1, buf, FALSE);   
    }
  }
  
  
  
  retFlag = 1;
wrapup:
  __DBGpr_com("<<< VDtblMatchToMap");
  return retFlag;
}
/************************************************************
 *
 * Clear Map if no data to work with
 * 
 ************************************************************/
IGRlong VDtblCheckMapStatus(Form form)
{
  IGRint       retFlag = 0;
  IGRint       rows    = 0;
  IGRint       col     = 0;
  IGRint       i       = 0;
  IGRint       status  = 0;
  IGRint       sel     = 0;
  IGRint       pos     = 0;
  IGRchar      buf[1024];  
  __DBGpr_com(">>> VDtblCheckMapStatus");
  /* get the number of rows on the form */
  FIfld_get_num_rows( form, VD_ITBL_COLS_FLD, &rows );
  /* check the col #0 for any data */
  for(i = 0;i < rows;i++) {
    FIfld_get_text( form, VD_ITBL_COLS_FLD, i, col, 
		    30, 
		    (unsigned char *)buf, 
		    &sel, &pos );
    if(strcmp(buf,"")) {
      status = 1;
      break;
    }
  }
  if(!(status&1)) {
    VDtblClearMap(form);
    goto wrapup;
  }
  
  /* check the col #2 for any data */
  status = 0;
  col = 2;
  for(i = 0;i < rows;i++) {
    FIfld_get_text( form, VD_ITBL_COLS_FLD, i, col, 
		    30, 
		    (unsigned char *)buf, 
		    &sel, &pos );
    if(strcmp(buf,"")) {
      status = 1;
      break;
    }
  }
  if(!(status&1)) {
    VDtblClearMap(form);
    goto wrapup;
  }
  
  
  retFlag = 1;
wrapup:
  __DBGpr_com("<<< VDtblCheckMapStatus");
  return retFlag;
}
/************************************************************
 *
 * Clear Col unconditionally
 * 
 ************************************************************/
IGRlong VDtblClearCol(Form form,IGRint col)
{
  IGRint       retFlag = 0;
  IGRint       rows    = 0;
  IGRint       i       = 0;
  IGRchar      buf[1024];
  
  __DBGpr_com(">>> VDtblClearCol");
  strcpy(buf,"");
  FIfld_get_num_rows( form, VD_ITBL_COLS_FLD, &rows );
  for(i = 0;i < rows;i++) {
     FIfld_set_text( form, VD_ITBL_COLS_FLD, i, col, buf, FALSE);  
  }
  
  retFlag = 1;
wrapup:
  __DBGpr_com("<<< VDtblClearCol");
  return retFlag;
}
/************************************************************
 *
 * Clear Map unconditionally
 * 
 ************************************************************/
IGRlong VDtblClearMap(Form form)
{
  IGRint       retFlag = 0;
  IGRint       rows    = 0;
  IGRint       col     = 1;
  IGRint       i       = 0;
  IGRchar      buf[1024];
  
  __DBGpr_com(">>> VDtblClearMap");
  strcpy(buf,"");
  FIfld_get_num_rows( form, VD_ITBL_COLS_FLD, &rows );
  for(i = 0;i < rows;i++) {
     FIfld_set_text( form, VD_ITBL_COLS_FLD, i, col, buf, FALSE);  
  }
  
  retFlag = 1;
wrapup:
  __DBGpr_com("<<< VDtblClearMap");
  return retFlag;
}

/************************************************************
 *
 * Get the number of rows in a col with data 
 * this applies only to the VD_ITBL_COLS_FLD gadget 
 * 
 ************************************************************/
IGRlong VDtblGetRowCount(Form form, IGRint col, IGRint *rowCnt)
{
  IGRint       retFlag = 0;
  IGRint       rows    = 0;
  IGRint       i       = 0;
  IGRint       sel     = 0;
  IGRint       pos     = 0;
  IGRchar      buf[1024];
  IGRchar      *p;
  
  __DBGpr_com(">>> VDtblGetRowCount");
  *rowCnt = 0;
  FIfld_get_num_rows( form, VD_ITBL_COLS_FLD, &rows );
  for(i = 0;i < rows;i++) {
    FIfld_get_text( form, VD_ITBL_COLS_FLD, i, col, 
		    30, 
		    (unsigned char *)buf, 
		    &sel, &pos ); 
    p = buf;
    
    if(*p == 'C') *rowCnt = *rowCnt + 1;
  }
  retFlag = 1;
wrapup:
  __DBGpr_com("<<< VDtblGetRow Count");
  return retFlag;
}

/************************************************************
 *
 * Get the header data for use elsewhere 
 * 
 ************************************************************/
IGRlong VDtblGetfldNames(IGRchar                 *tblLayoutName, 
			 IGRint                   hdrTrlType,
			 IGRchar                 ***fldNames,
			 IGRint                  *fldNameCnt)

{
  IGRint       retFlag = 0;
  IGRdouble    height;
  IGRshort     count   = 0;
  IGRint       nameCnt = 0;
  IGRint       workCnt = 0;
  IGRint       status  = 0;
  IGRint       j       = 0;
  IGRint       i       = 0;
  IGRint       line1   = 1;
  IGRint       Line3   = 3;
  IGRint       Line4   = 4;
  IGRlong      msg;
  IGRdouble    *fldLocation,fldData;
  IGRchar      buf1[1024], buf2[1024];
  struct  VDdrwlo_apifix	*fldRecs = NULL;
			
  /* init */
  buf1[0] = '\0';
  buf2[0] = '\0'; 
  *fldNameCnt = 0;
  
  __DBGpr_com(">>> VDtblGetfldNames");
  /* if no data  or pointers */
  if(tblLayoutName[0] == '\0') {
    goto wrapup;
  }
  if(!fldNameCnt) {
    goto wrapup;
  }
  status =
    VD_drwlo_gfix( &msg,
		   tblLayoutName,
		   hdrTrlType,
		   0, 0,
		   0, NULL,
		   &height,	
		   &count,
		   NULL );
  /* fail out if nothing found */
  if(count < 1) goto wrapup;
  if(!(status & 1)) goto wrapup;
  /* allocate space for the records */
  
  _FREE( fldRecs );
  fldRecs = _MALLOC( (count), struct VDdrwlo_apifix );
  
  /* get the list of fixed components */
  status =
    VD_drwlo_gfix( &msg,
		   tblLayoutName,
		   hdrTrlType,
		   0, 0,
		   0, NULL,
		   &height,	
		   &count,
		   fldRecs );
 
  if(!(status & 1)) goto wrapup;
  /* count up the number of names */
  for(i = 0;i < count;i++) {
    if(( fldRecs[i].rectyp != VD_DRWLO_EN_LINE ) && (i > 1)) {
      strcpy(buf1,"");
      if((fldRecs[i -1].VD.ln.y1 == 0) && (fldRecs[i -1].VD.ln.x1 != 0)) {
	if(fldRecs[i].VD.tx.ch_wdt > 0) {
	  sprintf(buf1,fldRecs[i].VD.tx.Text);
	}
	else {
	  strcpy(buf1,"");
	}
	nameCnt++;    
      }
    } 
  }
  /* allocate the fldLocation memory stuff */
  fldLocation = _MALLOC( (nameCnt),IGRdouble);
  /* get the list of location values */
  for(i = 0;i < count;i++) {
    if(( fldRecs[i].rectyp != VD_DRWLO_EN_LINE )  && (i > 1)) {
      if((fldRecs[i -1].VD.ln.y1 == 0) && (fldRecs[i -1].VD.ln.x1 != 0)) {
	fldLocation[workCnt] = fldRecs[i].VD.ln.x1;
	workCnt++;
      }
    } 
  }

  /* order the numbers of the locations */
  for(i = 0;i < workCnt;i++) {
    for(j = 0;j < workCnt -1;j++) {
      if(fldLocation[j] > fldLocation[j+1] ) {
	/* execute a swap */
	fldData = fldLocation[j];
	fldLocation[j] = fldLocation[j+1];
	fldLocation[j+1] = fldData;
      } 
    }
  }
  
  /* allocate the memory for the fldNames  pointers */
  *fldNames = _MALLOC( (nameCnt),IGRchar *);

  /* start going through the list getting the names */
  for(i = 0;i < count;i++) {
    if(( fldRecs[i].rectyp != VD_DRWLO_EN_LINE ) && (i > 1)) {
      strcpy(buf1,"");
      if((fldRecs[i -1].VD.ln.y1 == 0) && (fldRecs[i -1].VD.ln.x1 != 0)) {
	if(fldRecs[i].VD.tx.ch_wdt > 0) {
	  sprintf(buf1,fldRecs[i].VD.tx.Text);
	}
	else {
	  strcpy(buf1,"");
	}
	/* find the location to place this buf1 */
	fldData = fldRecs[i].VD.ln.x1;
	for(j = 0;j < workCnt;j++) {
	  /* if it matches the value */
	  if(fldLocation[j] == fldData) {
	    /* allocate the memory for this location */
	    (*fldNames)[j]  = _MALLOC( (sizeof(buf1) + 1), IGRchar  );
	    strcpy((*fldNames)[j],buf1);
	    break;
	  }
	}
      }
    } 
  }

  /* tell the outside world how many names there are */
  *fldNameCnt = nameCnt;
  retFlag = 1;
  

 wrapup:
  _FREE( fldRecs);
  _FREE( fldLocation);
  
  __DBGpr_com("<<< VDtblGetfldNames");
  return retFlag;
}
/************************************************************
 *
 * Make the storage of the Map
 * Allocates memory in the mapInfo->maps segment
 * this is allocation of * and ** pointers
 * user must _LOOPFREE any memory used when done
 * 
 ************************************************************/
IGRlong VDtblSaveMap(Form form,struct VDtblStImInfo *tblInfo)
{
  IGRint       retFlag = 0;
  IGRint       rows    = 0;
  IGRint       col1    = 1;
  IGRint       sel     = 0;
  IGRint       pos     = 0;
  IGRint       size    = 30;
  IGRint       row     = 0;
  IGRint       strLen  = 0;
  IGRchar      buf[1024],outStr[1024],inStr[1024],*p,separator[10];
  
  __DBGpr_com(">>> VDtblSaveMap");
  if(tblInfo == NULL) goto wrapup;

  /* inits */
  buf[0] = '\0';
  outStr[0] = '\0';
  inStr[0] = '\0';


  /* do a clean up of the previous allocation of maps */
  rows = tblInfo->mapInfo.rows;
  if(rows > 0) _LOOPFREE( tblInfo->mapInfo.maps,rows);
  /* get the number of rows of data in the map */
  VDtblGetRowCount(form, col1, &rows);

  /* add in the specific count of the maps */
  tblInfo->mapInfo.rows = rows;

  /* no rows means go home */
  if(rows == 0) goto wrapup;

  /* allocate the memory  to the *map pointers */
  if(rows > 0) {
    tblInfo->mapInfo.maps = _MALLOC( rows, IGRchar *);
  }
  /* get the separator */
  FIg_get_text( form, VD_ITBL_SEPARATOR_FLD, separator );
  VD_stripString( separator );
  strcpy(tblInfo->separator,separator);

  /* determine the type of the data in the file */
  strcpy(tblInfo->mapInfo.type,VD_DRW_TYPE_TXT);
  for(row = 0;row < rows;row++) {
    FIfld_get_text(form,VD_ITBL_COLS_FLD, row,col1,size,(unsigned char *)buf,&sel,&pos);
    p = NULL;
    p = strrchr(buf,'(');
    if(!(p == NULL)) {
      p++;
      strcpy(buf,p);
      p = strrchr(buf,')');
      if(!(p == NULL)) {
	/* this is TXT */
	strcpy(tblInfo->mapInfo.type,VD_DRW_TYPE_TXT);
	break;
      }
    } else {
      p = strrchr(buf,'<');
      if(!(p == NULL)) {
	p++;
	strcpy(buf,p);
	p = strrchr(buf,'>');
	if(!(p == NULL)) {
	  /* this is XML */
	  strcpy(tblInfo->mapInfo.type,VD_DRW_TYPE_XML);
	  break;
	}
      }
    } /* put test for ppl here */
  }

  /* do the TXT type stuff */
  if(!strcmp(tblInfo->mapInfo.type,VD_DRW_TYPE_TXT)) {
    /* get the data */
    for(row = 0;row < rows;row++) {
      /* read the specific rows */
      FIfld_get_text(form,VD_ITBL_COLS_FLD, row,col1,size,(unsigned char *)buf,&sel,&pos);
      /* do some string clipping for this stuff */
      strcpy(inStr,buf);
      vdtr$GetDelimitedStr(impStr = inStr,
			   outStr = outStr,
			   delChr = ' ',
			   posStr = 1);
            vdtr$GetDelimitedStr(impStr = outStr,
				 outStr = buf,
				 delChr = 'C',
				 posStr = 2);
      strLen = strlen(buf);
      strLen++;
      /* allocate the memory for the buf */
      tblInfo->mapInfo.maps[row] = _MALLOC( (strLen), IGRchar);
      strcpy(tblInfo->mapInfo.maps[row],buf);
    }
  }
  
  /* do the XML Type stuff */
  if(!strcmp(tblInfo->mapInfo.type,VD_DRW_TYPE_XML)) {
        for(row = 0;row < rows;row++) {
      /* read the specific rows */
      FIfld_get_text(form,VD_ITBL_COLS_FLD, row,col1,size,(unsigned char *)buf,&sel,&pos);
      /* do some string clipping for this stuff */
      strcpy(inStr,buf);
      vdtr$GetDelimitedStr(impStr = inStr,
			   outStr = outStr,
			   delChr = ' ',
			   posStr = 2);

      strLen = strlen(outStr);
      strLen++;
      /* allocate the memory for the buf */
      tblInfo->mapInfo.maps[row] = _MALLOC( (strLen), IGRchar);
      strcpy(tblInfo->mapInfo.maps[row],outStr);
    }
  }
  
  /* do the PPL Type stuff */
  if(!strcmp(tblInfo->mapInfo.type,VD_DRW_TYPE_PPL)) {
    /* no op for now */
  }
 
  retFlag = 1;
wrapup:
  __DBGpr_com("<<< VDtblSaveMap");
  return retFlag;
}

/************************************************************
 *
 * Move item in map up
 * 
 ************************************************************/
IGRlong VDtblMapItemMoveUp(Form form)
{
  IGRint       retFlag = 0;
  IGRint       rows    = 0;
  IGRint       col1    = 1;
  IGRint       col2    = 2;
  IGRint       mapCols = 0;
  IGRint       tblCols = 0;
  IGRint       row     = 0;
  IGRint       pos     = 0;
  IGRint       sel     = 0;
  IGRint       i       = 0;
  IGRint       sPos    = 0;
  IGRchar      buf[128],buf1[128];
  
  __DBGpr_com(">>> VDtblMapItemMoveUp");
  /* args check */
  if(!form) goto wrapup;

  /* init */
  buf[0] = '\0';
  buf1[0] = '\0';  

  /* get the active row index */
  FIfld_get_active_row( form, VD_ITBL_COLS_FLD, &row, &sPos );

  /* secure the number of columns in the map */
  VDtblGetRowCount( form, 
		    col1, 
		    &mapCols );
  if(mapCols < 1) goto wrapup;

  /* secure the number of columns in the table */
  VDtblGetRowCount( form, 
		    col2, 
		    &tblCols );
  if(tblCols < 1) goto wrapup;
  if(tblCols > mapCols) mapCols = tblCols;

  for(row = 0;row < mapCols;row++) {
    FIfld_get_text( form, VD_ITBL_COLS_FLD, row, col1, 
		    30, 
		    (unsigned char *)buf, 
		    &sel, &pos );
    if(sel & 1) break;
  }
  if(!(sel & 1)) goto wrapup;

  /* if there is a selected row with text in it */
  if(strcmp(buf,"")) 
  {
    /* is it on top? */
    if(row == 0) goto wrapup;

    /* is it out of range */
    if(row >= mapCols) goto wrapup;
    
    /* get the next row content up */
    FIfld_get_text( form, VD_ITBL_COLS_FLD, row-1, col1, 
		    30, 
		    (unsigned char *)buf1, 
		    &sel, &pos );
    /* kick off the swap */
    if(strcmp(buf1,"")) {
      	FIfld_set_text( form, VD_ITBL_COLS_FLD, row, col1, buf1, FALSE);
	FIfld_set_text( form, VD_ITBL_COLS_FLD, row-1, col1, buf, TRUE);   
    }   
  }   
  if(sPos > 2) sPos--;
  if(sPos < 2) sPos  = 2;
  FIfld_set_active_row( form, VD_ITBL_COLS_FLD, row -1, sPos);

  retFlag = 1;
wrapup:
  __DBGpr_com("<<< VDtblMapItemMoveUp");
  return retFlag;
}
/************************************************************
 *
 * Move item in map down
 * 
 ************************************************************/
IGRlong VDtblMapItemMoveDown(Form form)
{
  IGRint       retFlag = 0;
  IGRint       rows    = 0;
  IGRint       col1    = 1;
  IGRint       col2    = 2;
  IGRint       mapCols = 0;
  IGRint       tblCols = 0;
  IGRint       row     = 0;
  IGRint       pos     = 0;
  IGRint       sel     = 0;
  IGRint       i       = 0;
  IGRint       sPos    = 0;
  IGRchar      buf[128],buf1[128];
  
  __DBGpr_com(">>> VDtblMapItemMoveDown");
  /* args check */
  if(!form) goto wrapup;

  /* init */
  buf[0] = '\0';
  buf1[0] = '\0';  

  /* get the active row index */
  FIfld_get_active_row( form, VD_ITBL_COLS_FLD, &row, &sPos );

  /* secure the number of columns in the map */ 
  VDtblGetRowCount( form, 
		    col1, 
		    &mapCols );
  if(mapCols < 1) goto wrapup;

  /* secure the number of columns in the table */
  VDtblGetRowCount( form, 
		    col2, 
		    &tblCols );
  if(tblCols < 1) goto wrapup;
  if(tblCols > mapCols) mapCols = tblCols;
  

  /* find any highlighted in map */ 
  for(row = 0;row < mapCols;row++) {
    FIfld_get_text( form, VD_ITBL_COLS_FLD, row, col1, 
		    30, 
		    (unsigned char *)buf, 
		    &sel, &pos );
    if(sel & 1) break;
  }
  if(!(sel & 1)) goto wrapup;
  
  /* if there is a selected row with text in it */
  if(strcmp(buf,""))
  {
    /* is it on the bottom */
    if(row == mapCols -1) goto wrapup;

    /* is it out of range */
    if(row >= mapCols) goto wrapup;

    /* get the next row content down */
    FIfld_get_text( form, VD_ITBL_COLS_FLD, row+1, col1, 
		    30, 
		    (unsigned char *)buf1, 
		    &sel, &pos );
    /* kick off the swap */
    if(strcmp(buf1,"")) {
      	FIfld_set_text( form, VD_ITBL_COLS_FLD, row, col1, buf1, FALSE);
	FIfld_set_text( form, VD_ITBL_COLS_FLD, row+1, col1, buf, TRUE);
    }
  }

  /* reset the scroll */
  if(sPos > 7) sPos  = 7;
  if(sPos < 7) sPos++;
  FIfld_set_active_row( form, VD_ITBL_COLS_FLD, row +1, sPos);


  retFlag = 1;
wrapup:
  __DBGpr_com("<<< VDtblMapItemMoveDown");
  return retFlag;
}

/****************************************************************
 *
 * Checks the style file selection 
 * cleans up invalid input and reports results
 *
 ****************************************************************/

IGRstat VDhdrIsStyleFileValid( Form form )
{
  IGRint     retFlag = 0;
  IGRint    flag = 0;
  IGRint    selected = 0;
  IGRchar   fileName[128];
  IGRchar   filePath[1023];
  IGRchar   pwdPath[1023];
  IGRint    localDir = 1;
  IGRchar  *p;
  IGRint    fileLinesCnt = 0;
  IGRchar **fileLines;
  IGRint    sts = 0;

  // say hi
  __DBGpr_com(">>> VDhdrIsStyleFileValid");


  /* Get the text gadget's content */
  FIg_get_text( form, VD_ITBL_STYLE_FLD,filePath);
  /* no message on just blank style file */
  if(!strcmp(filePath,"")) goto wrapup;
  
  /* if it is not long enough we have a problem */
  if(strlen(filePath) < 5) {
    goto wrapup;
  }
  
  /* make sure it is case insensitive */
  VDstrupr(filePath);

  /* check for .xsl extension */
  p = strstr(filePath,".XSL");
  if(p == NULL) {
    goto wrapup;
  }
  /* check by position now just to be sure */
  if(strlen(p) > 4) {
    goto wrapup;
  }
  /*
   * This only checks the file for extension up to this point
   * any validity of the file content should be checked after this point
   * first by opening and checking for tags to match valid
   * then by actual operational trial
   */
  /* put any further validity checks here */
  FIg_get_text( form, VD_ITBL_STYLE_FLD,filePath);

  /* open the file and read the lines */
  sts = vdio$ReadAnyFile(fileName  = filePath,
			 partPath  = "",
			 fileLines = &fileLines,
			 lineCnt   = &fileLinesCnt);
  if((fileLinesCnt < 1)  || (sts == 0))goto wrapup;
  
  
  retFlag = 1;
 wrapup:
  if(fileLinesCnt > 0) _LOOPFREE( fileLines,fileLinesCnt );

  /* any failure to be valid removes the file from consideration */
  if(retFlag == 0) {
    FIg_set_text( form, VD_ITBL_STYLE_FLD,"");
  }
  
  // say bye
  __DBGpr_com("<<< VDhdrIsStyleFileValid");
  return retFlag;

}
/****************************************************************
 *
 * Gets the StyleFile placed in the gadget by a Button selection
 *
 ****************************************************************/

IGRstat VDhdrGetStyleFile( Form form )
{
  IGRint  retFlag = 0;
  IGRint  flag = 0;
  IGRint  fileSts = 0;
  IGRchar **fileLines;
  IGRint  lineCnt = 0;
  IGRchar buffer[1028];
  IGRchar *colBuf;
  IGRint  nbCols = 0;
  IGRint  i = 0;
  IGRint  j = 0;
  IGRint  col0 = 0;
  IGRint  strLen = 0;
  IGRchar **strsOut;
  IGRint  strsOutCnt = 0;
  IGRchar attrData[128];
  IGRint  selected = 0;
  IGRchar fileName[128];
  IGRchar xslFilePath[1023],*p,*r;
  IGRchar xmlFilePath[1023],separator[10];
  IGRchar pwdPath[1023];
  IGRint localDir = 1;
  TGRid  xmlTreeID,xslTreeID,xmlOutTreeID;

  // say hi
  __DBGpr_com(">>> VDhdrGetStyleFile");
  FIg_disable( form,0 );
  /* inits */
  pwdPath[0]  = '\0';
  xslTreeID.objid = NULL_OBJID;
  xmlTreeID.objid = NULL_OBJID;
  xmlOutTreeID.objid = NULL_OBJID;
  
  /* clean out the map */
  VDtblClearCol(form,0);
  VDtblClearCol(form,1);
  FIg_set_text( form, VD_ITBL_STYLE_FLD,"");

  /* fetch a file path */
  vdfile$BrowseFiles(Dir      = pwdPath,
		     Name     = fileName,
		     Path     = xslFilePath,
		     Flag     = &flag,
		     Selected = &selected,
		     LocalDir = &localDir);
  
  /* filter out any invalid file types */
  p = strstr(xslFilePath,".xsl");
  if(p == NULL) goto wrapup;
  if(strcmp(p,".xsl")) {
    goto wrapup;
  }
  if(selected == 0) goto wrapup;
  
  if(selected == 1) {
    /* set the file into the gadget */
    FIg_set_text( form, VD_ITBL_STYLE_FLD,xslFilePath);
  }
  
  /* process the map stuff now */
  FIg_get_text( form, VD_ITBL_IMPORTF_FLD,xmlFilePath);
  if(!strcmp(xmlFilePath,"")) {
    goto wrapup;
  }


  VDxdomCreateTreeFromXmlFile   (xmlFilePath,&xmlTreeID);
  VDxdomCreateStyleSheetFromFile(xslFilePath,&xslTreeID);
  if(xmlTreeID.objid == NULL_OBJID) {
    FIg_set_text (form,10,"Invalid XML File.");
    goto wrapup;
  }
  
  if(xslTreeID.objid == NULL_OBJID) {
    FIg_set_text (form,10,"Invalid StyleSheet.");
    FIg_set_text (form,VD_ITBL_STYLE_FLD,"");
    goto wrapup;
  }
  
  VDxdomApplyStyleSheet(&xslTreeID,&xmlTreeID,NULL,&xmlOutTreeID);
  if(xmlOutTreeID.objid == NULL_OBJID) {
    FIg_set_text (form,10,"Invalid OPE/XML File");    
    goto wrapup;
  }
  
  /* set up the map with the correct data */
  fileSts = vd$xmltbl_getRowData (xtreeID         = &xmlOutTreeID,
				  separator       = separator,
				  colBuf          = &colBuf,
				  nbCols          = &nbCols  );
  /* loop around putting in the numbers on col #0 */
  for(i = 0;i < nbCols;i++) {
    VDdrwUnMakeSepDataString(colBuf,separator,&strsOut,&strsOutCnt);
    strcpy(attrData,strsOut[i]);
    
    strLen = strlen(attrData);
    r = attrData;
    for(j = 0;j < strLen;j++) {
      if(!(*r == ' ')) {
	strcpy(attrData,r);
	break;
      }
      r++;
    }
    sprintf(buffer,"C%d  %s",i+1,attrData); 
    if(i > 8) sprintf(buffer,"C%d %s",i+1,attrData);  
    FIfld_set_text( form, VD_ITBL_COLS_FLD, i, col0, buffer, FALSE);
  }
  
  /* finish up with a blank line */
  strcpy(buffer,"C0 *BLANK LINE*");
  FIfld_set_text( form, VD_ITBL_COLS_FLD, i, col0, buffer, FALSE);
  if(i < 2) VIg_set_text(form,10,"Table may not be valid.");
  if(i < 1) VIg_set_text(form,10,"Table is not valid.");

  retFlag = 1;
 wrapup:
  if(xmlTreeID.objid != NULL_OBJID)    VDxdomDeleteNode(&xmlTreeID);
  if(xslTreeID.objid != NULL_OBJID)    VDxdomDeleteStyleSheet(&xslTreeID);
  if(xmlOutTreeID.objid != NULL_OBJID) VDxdomDeleteNode(&xmlOutTreeID);
  if(nbCols) _FREE(colBuf);
   if(strsOutCnt > 0) _LOOPFREE( strsOut,strsOutCnt );
  
  /* make the form reappear */
  FIg_enable( form,0 );
  // say bye
  __DBGpr_com("<<< VDhdrGetStyleFile");
  return retFlag;

}


/****************************************************************
 *
 * Gets the StyleFile placed in the gadget by a text selection
 *
 ****************************************************************/

IGRstat VDhdrGetStyleFileText( Form form )
{
  IGRint  retFlag = 0;
  IGRint  flag = 0;
  IGRint  fileSts = 0;
  IGRchar **fileLines;
  IGRint  lineCnt = 0;
  IGRchar buffer[1028];
  IGRchar *colBuf;
  IGRint  nbCols = 0;
  IGRint  i = 0;
  IGRint  j = 0;
  IGRint  col0 = 0;
  IGRint  strLen = 0;
  IGRchar **strsOut;
  IGRint  strsOutCnt = 0;
  IGRchar attrData[128];
  IGRint  selected = 0;
  IGRchar fileName[128];
  IGRchar xslFilePath[1023],*p,*r;
  IGRchar xmlFilePath[1023],separator[10];
  IGRchar pwdPath[1023];
  IGRint localDir = 1;
  TGRid  xmlTreeID,xslTreeID,xmlOutTreeID;

  // say hi
  __DBGpr_com(">>> VDhdrGetStyleFileText");

  FIg_disable( form,0 );
  /* inits */
  pwdPath[0]  = '\0';
  xslTreeID.objid = NULL_OBJID;
  xmlTreeID.objid = NULL_OBJID;
  xmlOutTreeID.objid = NULL_OBJID;
  
  /* clean out the map */
  VDtblClearCol(form,0);
  VDtblClearCol(form,1);
 
  /* get the file from the gadget */
  FIg_get_text( form, VD_ITBL_STYLE_FLD,xslFilePath);
  if(!strcmp(xslFilePath,"")) {
    FIg_set_text( form, VD_ITBL_STYLE_FLD,"");
    FIg_set_text( form,10,"Select Style Sheet.");
    goto wrapup;
  }
  
  p = strstr(xslFilePath,".xsl");
  if(p == NULL) {
    FIg_set_text( form, VD_ITBL_STYLE_FLD,"");
    FIg_set_text( form, VD_ITBL_STYLE_FLD,"");
    FIg_set_text( form,10,"Invalid Style Sheet not .xsl.");
    goto wrapup;
  }
  if(strcmp(p,".xsl")) {
    FIg_set_text( form,10,"Invalid Style Sheet not .xsl.");
    goto wrapup;
  }
  
  
  
  /* process the map stuff now */
  FIg_get_text( form, VD_ITBL_IMPORTF_FLD,xmlFilePath);
  if(!strcmp(xmlFilePath,"")) {
    goto wrapup;
  }
  
  VDxdomCreateTreeFromXmlFile   (xmlFilePath,&xmlTreeID);
  VDxdomCreateStyleSheetFromFile(xslFilePath,&xslTreeID);
  if(xmlTreeID.objid == NULL_OBJID) {
    FIg_set_text (form,10,"Invalid XML File.");
    goto wrapup;
  }
  
  if(xslTreeID.objid == NULL_OBJID) {
    FIg_set_text (form,10,"Invalid StyleSheet.");
    FIg_set_text (form,VD_ITBL_STYLE_FLD,"");
    goto wrapup;
  }
  
  VDxdomApplyStyleSheet(&xslTreeID,&xmlTreeID,NULL,&xmlOutTreeID);
  if(xmlOutTreeID.objid == NULL_OBJID) {
    FIg_set_text (form,10,"Invalid OPE/XML File");    
    goto wrapup;
  }
  
  /* set up the map with the correct data */
  fileSts = vd$xmltbl_getRowData (xtreeID         = &xmlOutTreeID,
				  separator       = separator,
				  colBuf          = &colBuf,
				  nbCols          = &nbCols  );
  
  /* loop around putting in the numbers on col #0 */
  for(i = 0;i < nbCols;i++) {
    VDdrwUnMakeSepDataString(colBuf,separator,&strsOut,&strsOutCnt);
    strcpy(attrData,strsOut[i]);
    
    strLen = strlen(attrData);
    r = attrData;
    for(j = 0;j < strLen;j++) {
      if(!(*r == ' ')) {
	strcpy(attrData,r);
	break;
      }
      r++;
    }
    sprintf(buffer,"C%d  %s",i+1,attrData); 
    if(i > 8) sprintf(buffer,"C%d %s",i+1,attrData);  
    FIfld_set_text( form, VD_ITBL_COLS_FLD, i, col0, buffer, FALSE);
  }
  
  /* finish up with a blank line */
  strcpy(buffer,"C0 *BLANK LINE*");
  FIfld_set_text( form, VD_ITBL_COLS_FLD, i, col0, buffer, FALSE);
  if(i < 2) VIg_set_text(form,10,"Table may not be valid.");
  if(i < 1) VIg_set_text(form,10,"Table is not valid.");

  retFlag = 1;
 wrapup:
  if(xmlTreeID.objid != NULL_OBJID)    VDxdomDeleteNode(&xmlTreeID);
  if(xslTreeID.objid != NULL_OBJID)    VDxdomDeleteStyleSheet(&xslTreeID);
  if(xmlOutTreeID.objid != NULL_OBJID) VDxdomDeleteNode(&xmlOutTreeID);
  if(nbCols > 0) _FREE(colBuf);
  if(strsOutCnt > 0) _LOOPFREE( strsOut,strsOutCnt );
  
 
  /* make the form reappear */
  FIg_enable( form,0 );
  // say bye
  __DBGpr_com("<<< VDhdrGetStyleFileText");
  return retFlag;

}

/****************************************************************
 *
 * Gets the PPL up and running to select items
 *
 ****************************************************************/

IGRstat VDhdrGetItems( Form form )
{
  IGRint  retFlag = 0;  
  TGRid   nodeID;
  IGRint  xpos,ypos,accept = 0;

  // say hi
  __DBGpr_com(">>> VDhdrGetItems");
  /* init */
  nodeID.objid = NULL_OBJID;

  FIf_erase( form );
  FIf_get_location(form, &xpos, &ypos);
  
  if(SELECT_NODE.objid == NULL_OBJID) goto wrapup;
  VDtvwCTBSStartItem(&SELECT_NODE,&xpos,&ypos,&accept); 
  FIf_set_location(form, xpos, ypos);
  FIf_display( form );
  retFlag = accept;
  

 wrapup:
  // say bye
  __DBGpr_com("<<< VDhdrGetItems");
  return retFlag;

}


end implementation VDCmdPlHdr;
