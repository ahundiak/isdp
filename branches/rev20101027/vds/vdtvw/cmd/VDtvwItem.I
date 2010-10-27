/* $Id: VDtvwItem.I,v 1.13 2001/11/14 17:06:21 ylong Exp $  */


/***************************************************************************
 * I/VDS
 *
 * File:        vds/vdtvw/cmd/VDtvwItem.I
 *
 * Description: 
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 06/25/01  pn      Creation
 ***************************************************************************/

// Generic node operations routines

class implementation VDct1Base;
/*
#define vdsDEBUG 
#define vdserrDEBUG
*/

#include "vdtvw.h"
#include "vdtr_macros.h"
#include "VDmem.h"
#include "VDassert.h"
#include "VDfrm.h"
#include <sys/stat.h>
#include "ci.h"
#include <dirent.h>
#include "VDppl1.h"
#include "dpmacros.h"
#include "VDtreeSaveSet.h"
#include "vdtvwtools.h"
#include "vdsmacros.h"

VDASSERT_FFN("vds/vdtvw/VDtvwItem.I");
/*
 * function prototypes
 */
IGRint VDtvwAttrViewCtrl(char *form);

IGRint VDtvwIndexRangeCtrl(char *form);

IGRint VDtvwSetRootID(TGRid *nodeID);

IGRint VDtvwGetNodeIDTest(TGRid *nodeID);

IGRint VDtvwRootIDCtrl(char *form);

IGRint VDtvwCTBSStartItem(TGRid  *basenodeID,
			  IGRint *xpos,
			  IGRint *ypos,
			  IGRint *accept);

IGRstat VDtvwTreeAction(Form form);

IGRstat VDtvwGetToggleState(char *form,
			    IGRint *modTog,
			    IGRint *stageTog,
			    IGRint *nameTog,
			    IGRint *attrTog,
			    IGRint *itemTog);

IGRstat VDtvwToggleViewCtrl(char *form);

IGRint VDtvwGetSelectionText(char    *form,
			     IGRchar *sets,
			     IGRchar *stage,
			     IGRchar *name,
			     IGRchar *afrom,
			     IGRchar *ato,
			     IGRchar *attrName,
			     IGRchar *attrValue);

IGRint VDtvwGetRollText(char *form,
			IGRchar *hilite,
			IGRchar *parent,
			IGRchar *bln);

IGRint VDtvwTextBoxCtrl(char *form);

IGRint VDtvwIsAcceptOK(Form form,IGRint *acceptOK);

IGRint VDtvwAcceptCtrl(Form form);

IGRint VDtvwSetToText(Form form);

IGRint VDtvwSetFromText(Form form);

IGRint VDtvwFromToCtrl(Form form);

IGRint VDtvwGetHilitedNodesList(Form    form,
			       IGRint  gadget,
			       TGRid **nodeIDs,
			       IGRint *nodeIDsCnt);

IGRint VDtvwRefreshTree(Form form);

IGRint VDtvwGetFromToRange(Form form,
			   IGRint *fromRow,
			   IGRint *toRow);

IGRint VDtvwGetRootID(TGRid *nodeID);

IGRint VDtvwBlnRollTextCtrl(Form form);

IGRint VDtvwSetFormSettings(Form form);

IGRint VDtvwGetFormSettings(Form form);

IGRint VDtvwSetDefaultFormSettings();

IGRint VDtvwHiliteItemsCtrl(Form form);

IGRint VDtvwHiliteItemCtrl(Form form);

IGRint VDtvwFillSetsFromFile(Form form);

IGRint VDtvwSaveSaveSet(Form form);

IGRint VDtvwLoadSaveSet(Form form);

IGRint VDtvwDeleteSaveSet(Form form);

IGRint VDtvwIsItemAccepted();

IGRint VDtvwGetItemList(TGRid **itemList,
			IGRint *itemListCnt);

IGRint VDtvwListsSelection(Form form,IGRint gadget);

IGRint VDtvwAddSelections( Form form );
IGRint VDtvwClrSelections( Form form );
IGRint VDtvwSetItemList (	TGRid	*itemList, 
				IGRint	itemCnt, 
				TGRid	rootID,
				TGRid	setID );

%safe
static TGRid rootID;
static TGRid setID;
static TGRid fromID;
static TGRid toID;
static IGRint xPos;
static IGRint yPos;
static TGRid *hListIDs;
static IGRint hListIDsCnt;
static IGRint AcceptStatus;
static VDtvwFrmSet mem;
static char *VD_FP;
%endsafe

extern VDtrGetTest();
/* ----------------------------------------
 * form notification routine ~pn*
 * ***/
IGRint VDtvwNotifyForm(char *form,IGRint gadget)
{
    VDASSERT_FN("notifyForm");

    IGRint retFlag = 1;
    IGRint sts,i;
    IGRchar DirName[1023];
    IGRint togStatus = 0;
    IGRchar buf[128];
    IGRint  state = 0;
    TGRid   *nodeIDs,nodeID;
    IGRint  nodeIDsCnt;
    IGRint  row,pos,selFlag;
    IGRchar attr[2];
    IGRchar data[128];
    IGRint  chk = 0;

    nodeIDs = NULL;
    
        /* say hi */
    if (traceFlag) {
      printf("\n\n>>> %s %s gadget [%d]\n",ffn(),fn,gadget);
      printf("rootID[%d][%d]\n\n",rootID.osnum,rootID.objid);
      
    }

    /* make sure the form pointer storage is ok */
    VD_FP = form;
    
    /* keep track of the form position */
    FIf_get_location(form, &xPos, &yPos);
    if(traceFlag) printf("form_notification xPos[%d] yPos[%d]\n",xPos,yPos);
    

    UI_status("Processing Request");
    
    strcpy(buf,"");
    FIg_set_text(form, 10,buf );
    UI_status(buf);
    switch(gadget) {
      /* the cancel button was selected */
      case FI_CANCEL:
	if(traceFlag) printf("FI_CANCEL\n");
	if(hListIDsCnt > 0) {
	  if(traceFlag) printf("Freeing hlistIDs3\n");
	  _FREE( hListIDs );
	  hListIDsCnt = 0;
	  AcceptStatus = 0;
	}
	
	break;

        /*the ACCEPT button was selected */
      case FI_ACCEPT:
	/* do the action here */
	if(traceFlag) printf("FI_ACCEPT\n");
	AcceptStatus = 1;
        break;

	/* multicolumn */
      case VDTVW_MCOL_TREE:
	if(traceFlag) printf("VDTVW_MCOL_TREE\n");
	/* 
	 * check to see if the selection is row[0] 
	 * if so neutralize any effect and go home
	 */

	/* get the active row on the multicolumn form */
	FIfld_get_active_row( form,VDTVW_MCOL_TREE,&row,&pos );
	if(traceFlag) printf("multicol row[%d] active\n",row);
	
	FIfld_get_select( form,VDTVW_MCOL_TREE,row ,2,&selFlag ) ; 
	
	/* get the selected ID  and data */
	VDtvwFormGetTreeRowData(form,VDTVW_MCOL_TREE,row,attr,exp,data,&nodeID,&selFlag,&pos);
#if 0
	/* Why not? ylong */
	if(row == 0) {
	  if(selFlag == 1) {
	    /* reset the selFlag to 0 */
	    selFlag = 0;
	    /* reset the text hilite */
	    VDtvwFormSetUnHiliteNode(form,VDTVW_MCOL_TREE,&nodeID);
	    /* notify the user what happened */
	    FIg_set_text(form, 10,"Root Node cannot be selected here.");
	    retFlag = 1;
	    goto wrapup;
	  }
	}
#endif	

	VDtvwGetHilitedNodesList(form,
				 VDTVW_MCOL_TREE,
				 &hListIDs,
				 &hListIDsCnt);
	VDtvwNotifyIfNodeSel(form,VDTVW_MCOL_TREE);
	VDtvwTreeAction(form);
	VDtvwSetToText(form);
	VDtvwSetFromText(form);
	VDtvwFromToCtrl(form);
	VDtvwHiliteItemCtrl(form);
	break;
	
	/* toggles */
      case VDTVW_TG_ITEM:
	if(traceFlag) printf("VDTVW_TG_ITEM\n");
	VDtvwToggleViewCtrl(form);
	VDtvwIndexRangeCtrl(form);	
	VDtvwFormFillAttrNameList(form);
	VDtvwFormFillAttrValuesList(form);
	VDtvwBlnRollTextCtrl(form);
	break; 

      case VDTVW_TG_MOD:
	if(traceFlag) printf("VDTVW_TG_MOD\n");
	VDtvwFormFillAttrNameList(form);
	VDtvwFormFillAttrValuesList(form);
	VDtvwBlnRollTextCtrl(form);
	break; 

      case VDTVW_TG_STAGE:
	if(traceFlag) printf("VDTVW_TG_STAGE\n");
	VDtvwFormFillAttrNameList(form);
	break; 

      case VDTVW_TG_NAME:
	if(traceFlag) printf("VDTVW_TG_NAME\n");
	VDtvwFormFillAttrNameList(form);
	break;
	
      case VDTVW_TG_ATTR:
	if(traceFlag) printf("VDTVW_TG_ATTR\n");
	VDtvwToggleViewCtrl(form);
	VDtvwFormFillAttrNameList(form);
	VDtvwFormFillAttrValuesList(form);
	VDtvwBlnRollTextCtrl(form);
	VDtvwToggleViewCtrl(form);
	break;
	
	
	/* rolling text boxes */
      case VDTVW_RT_HI:
	if(traceFlag) printf("VDTVW_RT_HI\n");

	/* tell the hilite gadget to do its thing */
	VDtvwHiliteItemsCtrl(form);
	break;
	
      case VDTVW_T_BLN:
	if(traceFlag) printf("VDTVW_T_BLN\n");
	break;
	
      case VDTVW_RT_ALL:
	if(traceFlag) printf("VDTVW_RT_ALL\n");
	VDtvwFormFillAttrNameList(form);
	VDtvwFormFillAttrValuesList(form);
	VDtvwBlnRollTextCtrl(form);
	break;
	
	
	/* text boxes */
      case VDTVW_T_SETS:
	if(traceFlag) printf("VDTVW_T_SETS\n");
	break;
		
      case VDTVW_T_STAGE:
	if(traceFlag) printf("VDTVW_T_STAGE\n");
	VDtvwFormFillNamesList(form,VDTVW_T_NAME,VDTVW_MCOL_TREE);
	VDtvwFormFillAttrNameList(form);
	VDtvwFormFillAttrValuesList(form);
	VDtvwBlnRollTextCtrl(form);
	break;
	
      case VDTVW_T_NAME:
	if(traceFlag) printf("VDTVW_T_NAME\n");
	VDtvwFormFillAttrNameList(form);
	VDtvwFormFillAttrValuesList(form);
	VDtvwBlnRollTextCtrl(form);
	break;
	
      case VDTVW_T_ANAME: 
	if(traceFlag) printf("VDTVW_T_ANAME\n");
	VDtvwFormFillAttrValuesList(form);
	VDtvwBlnRollTextCtrl(form);
	break;
	
      case VDTVW_T_AVAL:
	if(traceFlag) printf("VDTVW_T_AVAL\n");
	VDtvwBlnRollTextCtrl(form);
	break;
	
      case VDTVW_T_FROM:
	if(traceFlag) printf("VDTVW_T_FROM\n");
	VDtvwFormFillAttrNameList(form);
	VDtvwFormFillAttrValuesList(form);
	VDtvwBlnRollTextCtrl(form);
	break;
	
      case VDTVW_T_TO:
	if(traceFlag) printf("VDTVW_T_,VDTVW_T_ANAMETO\n");
	VDtvwFormFillAttrNameList(form);
	VDtvwFormFillAttrValuesList(form,VDTVW_T_AVAL,VDTVW_T_ANAME);
	VDtvwBlnRollTextCtrl(form);
	break;
	
	
	/* buttons */
      case VDTVW_B_SEL_1:
      case VDTVW_B_SEL_3:
	/* give a status notice for users */
	FIg_set_text(form,10,"Processing Selection.");
	UI_status("Processing Selection");

	if(traceFlag) printf("VDTVW_B_SEL_3\n");
	VDtvwListsSelection(form,gadget);	
	VDtvwGetHilitedNodesList(form,
				 VDTVW_MCOL_TREE,
				 &hListIDs,
				 &hListIDsCnt);
	VDtvwHiliteItemsCtrl(form);
	FIg_set_text(form,10,"Done Processing Selection.");
	UI_status("Done Processing Selection");
	break;
	
      case VDTVW_B_CLR_1:
      case VDTVW_B_CLR_3:
      case VDTVW_B_CLR_2:
	if(traceFlag) printf("VDTVW_B_CLR_3\n");
	/* give a status notice for users */
	FIg_set_text(form,10,"Processing Clear.");
	UI_status("Processing Clear");
	VDtvwListsSelection(form,gadget);
	VDtvwGetHilitedNodesList(form,
				 VDTVW_MCOL_TREE,
				 &hListIDs,
				 &hListIDsCnt);
	VDtvwHiliteItemsCtrl(form);
	FIg_set_text(form,10,"Done Processing Clear.");
	UI_status("Done Processing Clear");
	break;
	
      case VDTVW_B_LOAD_SS:
	if(traceFlag) printf("VDTVW_B_LOAD_SS\n");	
	VDtvwLoadSaveSet(form);
	break;
	
      case VDTVW_B_SAVE_SS:
	if(traceFlag) printf("VDTVW_B_SAVE_SS\n");
	VDtvwSaveSaveSet(form);
	break;
	
      case VDTVW_B_DEl_SS:
	if(traceFlag) printf("VDTVW_B_DEl_SS\n");
	VDtvwDeleteSaveSet(form);
	break;
	
      case VDTVW_C_SETS:
	FIg_get_state( form, VDTVW_C_SETS, &chk );
	if( chk ) {
	  FIg_set_state( form, VDTVW_C_EXPR, !chk );
	  FIg_enable( form, VDTVW_G_SS );
	  FIg_disable( form, VDTVW_T_EXPR );
	}
	else {
	  FIg_set_state( form, VDTVW_C_SETS, !chk );
	}
	break;

      case VDTVW_C_EXPR:
	FIg_get_state( form, VDTVW_C_EXPR, &chk );
	if( chk ) {
	  FIg_set_state( form, VDTVW_C_SETS, !chk );
	  FIg_disable( form, VDTVW_G_SS );
	  FIg_enable( form, VDTVW_T_EXPR );
	}
	else {
	  FIg_set_state( form, VDTVW_C_EXPR, !chk );
	}
	break;
	
      case VDTVW_B_ADD_SS:
	VDtvwAddSelections( form );
	break;

      case VDTVW_B_CLR_SS:
	VDtvwClrSelections( form );
	break;

      case VDTVW_B_FROM:
	if(traceFlag) printf("VDTVW_B_FROM\n");
	FIg_get_state(form,VDTVW_B_FROM,&state);
	if(state & 1) {
	  FIg_set_state_off(form,VDTVW_B_TO);
	  FIg_set_text(form, VDTVW_T_FROM,"");
	  fromID.objid = NULL_OBJID;
	}
	
	break;
	
      case VDTVW_B_TO:
	if(traceFlag) printf("VDTVW_B_TO\n");
	FIg_get_state(form,VDTVW_B_TO,&state);
	if(state & 1) {
	  FIg_set_state_off(form,VDTVW_B_FROM);
	  FIg_set_text(form, VDTVW_T_TO,"");
	  if(traceFlag) printf("setting toID to NULL\n");
	  
	  toID.objid = NULL_OBJID;
	}
	
	break;


        /* default does nothing */
      default:
        break;

    }
    VDtvwToggleViewCtrl(form); 
    VDtvwTextBoxCtrl(form);
    VDtvwAcceptCtrl(form);
    VDtvwRefreshTree(form);
    if(toID.objid != mem.toID.objid) {
      VDtvwFormFillAttrNameList(form);
      VDtvwFormFillAttrValuesList(form);
      VDtvwBlnRollTextCtrl(form);
    }
    if(fromID.objid != mem.fromID.objid) {
      VDtvwFormFillAttrNameList(form);
      VDtvwFormFillAttrValuesList(form);
      VDtvwBlnRollTextCtrl(form);
    }
    retFlag = 1;
wrapup:
    /* tell the hilite gadget to do its thing */
    VDtvwGetFormSettings(form);
    VDtvwGetHilitedNodesList(form,
			     VDTVW_MCOL_TREE,
			     &hListIDs,
			     &hListIDsCnt);
    if(nodeIDsCnt > 0) _FREE( nodeIDs );
    UI_status("Do Something");
    /* say bye */
    if (traceFlag) {
      printf("frm->fromID[%d][%d] toID[%d][%d]\n",fromID.osnum,fromID.objid,toID.osnum,toID.objid);
      printf("<<< %s %s(%d)\n",ffn(),fn,retFlag);
    }
    
    return retFlag;
}


/*-----------------------------------------------------------
 * Pre-set item list from outside before access
 */
IGRint VDtvwSetItemList (	TGRid	*itemList, 
				IGRint	itemCnt, 
				TGRid	newRoot, 
				TGRid	newSet )
{
	IGRint	sts = 0, i;


	hListIDsCnt  = 0;
	rootID.objid = NULL_OBJID;
	setID.objid  = NULL_OBJID;
	if( hListIDs ) _FREE( hListIDs );

	if( !itemList || itemCnt < 1 ) goto wrapup;

	hListIDs = _MALLOC( itemCnt, TGRid );
	if( !hListIDs ) goto wrapup;

	hListIDsCnt = itemCnt;
	for ( i = 0; i < itemCnt; i++ ) {
		hListIDs[i] = itemList[i];
	}

	AcceptStatus = 1;
	rootID = newRoot;
	setID  = newSet;

	sts = 1;
wrapup:
	return sts;
}

/*-----------------------------------------------------------
 * Add nodes to the selections
 */
IGRint VDtvwAddSelections( Form form )
{
	IGRint	sts = 0;
	IGRint	chk = 0;
	IGRint	nodeListCnt = 0, 
		selListCnt  = 0,
		row, nbRows = 0,
		i, sel, eq = 0, cnt = 0;
	TGRid	*nodeList = NULL, 
		objID,
		ssRoot;
	GRname	name;
	
	if ( !form ) goto wrapup;

	FIg_get_state( form, VDTVW_C_SETS, &chk );
	name[0] = '\0';

	/* save set is checked */
	if( chk ) {
		FIg_get_text(form, VDTVW_T_SETS, name);
		if( name[0] == '\0' ) {
			FIg_set_text( form, 10, "Missing Saved Set Name");
			UI_status("Missing Save Set Name");
			goto wrapup;
		}

		UI_status("Loading Saved Set ...");
		sts = vd$TreeSet_getSaveSet (	setName   = name,
						treeSetID = &setID,
						rootID    = &ssRoot,
						objList   = &nodeList,
						count     = &nodeListCnt);
	
		if( !sts || nodeListCnt < 1 || !nodeList ) {
			FIg_set_text( form, 10, "Failed to load Saved Set");
			UI_status("Failed to load Saved Set");
			goto wrapup;
		}
	}
	/* else conditional expression is checked */
	else {
		FIg_get_text(form, VDTVW_T_EXPR, name);
		if( name[0] == '\0' ) {
			FIg_set_text( form, 10, "Missing Expression Name");
			UI_status("Missing Expression Name");
			goto wrapup;
		}
				
		UI_status("Loading Objects by Expression ...");
		VDtrGetNodeListByEXP(&rootID, name, &nodeList, &nodeListCnt);
		if( nodeListCnt < 1 || !nodeList ) {
			FIg_set_text( form, 10, "Failed to load Exp Objects");
			UI_status("Failed to load Exp Objects");
			goto wrapup;
		}
	}

	FIfld_get_num_rows(form, VDTVW_MCOL_TREE, &nbRows);
	if( nbRows < 1 ) goto wrapup;

	for( row = 0; row < nbRows; row++ ) {
		sel = 0;
		FIfld_get_select( form, VDTVW_MCOL_TREE, row, 2, &sel ) ; 
		if( sel ) selListCnt++;
	}

	if( selListCnt ) {
		cnt = nodeListCnt;
		nodeListCnt += selListCnt;
		nodeList = _REALLOC( nodeList, nodeListCnt, TGRid );
		if( nodeList == NULL ) goto wrapup;
		for( row = 0; row < nbRows; row++ ) {
			sel = 0;
			FIfld_get_select(form, VDTVW_MCOL_TREE, row, 2, &sel); 
			if( !sel ) continue;

			objID.objid = NULL_OBJID;
			vdfrm$GetText(	form	= form,
					gadget	= VDTVW_MCOL_TREE,
					row	= row,
					col	= 3,
					txt	= name );
			vdfrm$GetText(	form	= form,
					gadget	= VDTVW_MCOL_TREE,
					row	= row,
					col	= 3,
					objID	= &objID );
			eq = 0;
			for( i = 0; i < cnt; i++ ) {
				if( nodeList[i].objid == objID.objid ) {
					eq = 1;
					break;
				}
			}
			if( eq || objID.objid == NULL_OBJID ) continue;
			nodeList[cnt] = objID;
			cnt++;
		}
		nodeListCnt = cnt;
	}

	/*
	sts = VDtrStExpandTree(	form,
				VDTVW_MCOL_TREE,
				&setID,
				nodeList,
				nodeListCnt);
	
	*/
	for(i = 0;i < nodeListCnt;i++) {
	   VDtvwFormSetHiliteNodeExp(form,VDTVW_MCOL_TREE,nodeList[i],rootID);
	}

	sts = 1;
wrapup:
	_FREE( nodeList );
	return sts;
}


/*------------------------------------------------------------
 * Clear selections
 */
IGRint VDtvwClrSelections( Form form )
{
	IGRint	sts = 0;
	IGRint	row, nbRows = 0;
	IGRint	sel;

	FIfld_get_num_rows(form, VDTVW_MCOL_TREE, &nbRows);
	if( nbRows < 1 ) goto wrapup;

	for( row = 0; row < nbRows; row++ ) {
		sel = 0;
		FIfld_get_select( form, VDTVW_MCOL_TREE, row, 2, &sel ) ; 
		if( sel ) FIfld_set_select( form, VDTVW_MCOL_TREE, row, 2, 0);
	}

	sts = 1;
wrapup:
	return sts;
}

/*****************************************************
 *
 * Handle the MultiColumn display stuff ~pn
 *
 *****************************************************/
IGRstat VDtvwTreeAction(Form form)
{
  VDASSERT_FN("VDtvwTreeAction");
  IGRint  retFlag = 0;
  IGRchar buf[128],attr[128],exp[128],data[128];
  IGRint  row,col,rpos,cpos,pos,gadget,selFlag;
  TGRid   rowID;
  
  // say hi
  if (traceFlag) {
    printf("**>> %s %s\n",ffn(),fn); 
  }
  
  /* inits */
  gadget = VDTVW_MCOL_TREE;
  row = col = rpos = cpos = selFlag = 0;

  /* get the active row */ 
  FIfld_get_active_row( form, gadget, &row, &rpos );

  /* get the active column */
  FImcf_get_active_col(form, gadget, &col, &cpos);
  
  /* is it selected? */
  VIfld_get_text(form, gadget,row,col,80, buf,&selFlag,&pos);
  if(traceFlag) printf("\n\nrow[%d] col[%d] selFlag[%d]\n",row,col,selFlag);

  /* is it an expansion/contraction? */
  if(col < 2) {
    if(selFlag & 1) {
      /* go set the expansion to unhilited on the form and invert if need be */
      if(!strcmp(buf,EXP_EXP)) VIfld_set_text(form, gadget, row, col, EXP_CON, 0);
      if(!strcmp(buf,EXP_CON)) VIfld_set_text(form, gadget, row, col, EXP_EXP, 0);
      if(!strcmp(buf,EXP_EMP)) VIfld_set_text(form, gadget, row, col, EXP_EMP, 0);
    }
    /* start working down the issue */ 
    VDtvwFormGetTreeRowData(form,gadget,row,attr,exp,data,&rowID,&selFlag,&pos);
    if(traceFlag) printf("\n\n\trowID [%d][%d]\n",rowID.osnum,rowID.objid);
  
    /* attribute expansion/collapse */
    if(col == 0) {
      if(!strcmp(buf,EXP_EXP)) {
	VDtvwFormContractAttrs(form,VDTVW_MCOL_TREE,&rowID);
      }
      if(!strcmp(buf,EXP_CON)) {
	VDtvwFormExpandAttrs(form,VDTVW_MCOL_TREE,&rowID);	
      }
    }
    /* tree expansion/collapse */
    if(col == 1) {
      if(!strcmp(buf,EXP_EXP)) {
	VDtvwFormContractNode(form,VDTVW_MCOL_TREE,rowID);
      }
      if(!strcmp(buf,EXP_CON)) {
	VDtvwFormExpandNode(form,VDTVW_MCOL_TREE,&rowID);
      }
    }
  } else {
    /* a node was selected */
  }
  

  

  retFlag = 1;
  
 wrapup:
  // say bye 
  if (traceFlag) {
    printf("<<** %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}

/*****************************************************
 *
 * call the whole thing from the CTBS form ~pn
 *
 *****************************************************/
IGRint VDtvwCTBSStartItem(TGRid *basenodeID,
			  IGRint *xpos,
			  IGRint *ypos,
			  IGRint *accept)
{
  VDASSERT_FN("VDtvwCTBSStartItem");
  IGRint  i,retFlag = 0;
  IGRchar buf[128];
  IGRchar pplName[128];
  IGRchar funcName[128];
  TGRid   pID,*p;

   /* inits */
  pplName[0] = '\0';
  funcName[0] = '\0';

  // say hi
  if (traceFlag) {
    printf("**>> %s %s basenodeID[%d][%d]\n",ffn(),fn,basenodeID->osnum,basenodeID->objid); 
  }

  UI_status("Loading Form ...");
  if(rootID.objid != basenodeID->objid) {
    if(hListIDsCnt > 0) _FREE( hListIDs );
    hListIDsCnt = 0;
    AcceptStatus = 0;
  }
  
 
  strcpy(pplName,"COztns");
  strcpy(funcName,"main");
  xPos = *xpos;
  yPos = *ypos;
  if(traceFlag) printf("got xPos[%d] yPos[%d]\n",xPos,yPos);

  VDtvwSetRootID(basenodeID);
  
  ci$exec( file_name = pplName,
           sender_id = NULL_OBJID,
           entry     = funcName  );
  if(traceFlag) printf("current xPos[%d] yPos[%d]\n",xPos,yPos);

  *xpos = xPos;
  *ypos = yPos;

  *accept = AcceptStatus;  
  
wrapup:
  // say bye 
  if (traceFlag) {
    printf("<<** %s %s %d basenodeID[%d][%d]\n",ffn(),fn,retFlag,basenodeID->osnum,basenodeID->objid);
  }
  return retFlag;
}

/*****************************************************
 *
 * Init the form ~pn
 *
 *****************************************************/
IGRint VDtvwInitForm(char *form)
{
  VDASSERT_FN("VDtvwInitForm");
  IGRint  retFlag = 0;
  IGRchar buf[128];
  TGRid   nodeID,setID,childID;
  IGRint  i,rows = 0,row = 0;
  IGRint  gadget;
  IGRint  offset = 0;
  IGRint  attrFlag = 0;
  IGRint  exprFlag = 0;
  IGRint  selFlag = 0;
  IGRint  acceptOK = 0;
  
  
  
  // say hi
  if (traceFlag) {
    printf("**>> %s %s\n",ffn(),fn); 
  }

  VD_FP = form;

  FIg_set_text(form,10,"Loading Form ...");
  UI_status("Form Loading");
 
  nodeID.objid = NULL_OBJID;
  fromID.objid = NULL_OBJID;
  toID.objid = NULL_OBJID;
  gadget = VDTVW_MCOL_TREE;
  
  nodeID.osnum = rootID.osnum;
  nodeID.objid = rootID.objid;
 
  FIf_set_location(form, xPos, yPos);

  /* display the nodes and expand one level for initial view # */
  VDtvwFormPlaceNodeTop(form,
			VDTVW_MCOL_TREE,
			&nodeID);
  
  VDtvwFormExpandNode(form,
		      VDTVW_MCOL_TREE,
		      &nodeID);
  VIfld_get_num_rows(form, VDTVW_MCOL_TREE, &rows);
  if(rows >1) VIfld_set_text(form, gadget, row, 1, EXP_EXP, 0);

  /* turn off the All/model option gadget if this is a not a VDct1Base class tree */
    if(!(vdobj$IsAncestryValid(objID          = &nodeID,
			       superClassName = "VDct1Base"))) {
      FIg_erase(form,VDTVW_TG_MOD);
    }
    
  /* grey out the accept button until some selection is made on the form */
  FIg_disable(form,FI_ACCEPT);
  VDtvwSetFormSettings(form);
  

  if(nodeID.objid == NULL_OBJID) {
    strcpy(buf,"You must select a set.");
    FIg_set_text(form,10,buf);
  } else {
    sprintf(buf,"rootID [%d,%d]",nodeID.osnum,nodeID.objid);
    if(traceFlag) printf("%s\n",buf);
    FIg_set_text(form, 10,buf );
  }

  for(i = 0;i < hListIDsCnt;i++) {
    VDtvwFormSetHiliteNodeExp(form,VDTVW_MCOL_TREE,hListIDs[i],rootID);
  }

  /* check for hilites  on the form for the Accept control operations */
  VDtvwIsAcceptOK(form,&acceptOK);
  if(acceptOK == 1) FIg_enable(form,FI_ACCEPT);

  /* fill up the list of available sets */
  VDtvwFillSetsFromFile(form);

  /* fill up the list of conditional expression */
  VDtvwFillExprFromFile(form);

  /* tell the hilite gadget to do its thing */
  VDtvwHiliteItemsCtrl(form);
  
 retFlag = 1;
  
wrapup:
 VDtvwRefreshTree(form);
 // say bye 
 if (traceFlag) {
   printf("Init Form done rootID[%d][%d]\n",rootID.osnum,rootID.objid);
   printf("<<** %s %s %d\n",ffn(),fn,retFlag);
 }
  return retFlag;
}
/********************************************
 *
 * Get the Text Box data from the form selection
 * stuff ~pn
 *
 ********************************************/
IGRint VDtvwGetSelectionText(char    *form,
			     IGRchar *sets,
			     IGRchar *stage,
			     IGRchar *name,
			     IGRchar *afrom,
			     IGRchar *ato,
			     IGRchar *attrName,
			     IGRchar *attrValue)
{
  VDASSERT_FN("VDtvwGetSelectionText");
  IGRint retFlag = 0;
 
  /* say hi */
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

  /* fetch the items from the form */
  FIg_get_text(form,VDTVW_T_SETS,sets);
  FIg_get_text(form,VDTVW_T_STAGE,stage);
  FIg_get_text(form,VDTVW_T_NAME,name);
  FIg_get_text(form,VDTVW_T_FROM,afrom);
  FIg_get_text(form,VDTVW_T_TO,ato);
  FIg_get_text(form,VDTVW_T_ANAME,attrName);
  FIg_get_text(form,VDTVW_T_AVAL,attrValue);
  retFlag = 1;
wrapup:
  /* say bye */
  if (traceFlag) printf("<<< %s %s(%d)\n",ffn(),fn,retFlag);
  return retFlag;
}

/********************************************
 *
 * Get the Text Box status from the form selection
 * stuff (rolling text boxes) ~pn
 *
 ********************************************/
IGRint VDtvwGetRollText(char *form,
			IGRchar *hilite,
			IGRchar *parent,
			IGRchar *bln)
{
  VDASSERT_FN("VDtvwGetRollText");
  IGRint retFlag = 0;

  /* say hi */
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
  /* fetch the items from the form */
  FIg_get_text(form,VDTVW_RT_HI,hilite);
  FIg_get_text(form,VDTVW_RT_ALL,parent);
  FIg_get_text(form,VDTVW_T_BLN,bln);
  retFlag = 1;
wrapup:
  /* say bye */
  if (traceFlag) printf("<<< %s %s(%d)\n",ffn(),fn,retFlag);
  return retFlag;
}




/*****************************************************
 *
 * reports on the form for toggles
 * gets data on their state ~pn
 *
 *****************************************************/
IGRstat VDtvwGetToggleState(char *form,
			    IGRint *modTog,
			    IGRint *stageTog,
			    IGRint *nameTog,
			    IGRint *attrTog,
			    IGRint *itemTog)
{
  VDASSERT_FN("VDtvwToggleViewCtrl");
  IGRint  retFlag = 0;
  IGRint  flag = 0;

  // say hi
  if (traceFlag) {
    printf("**>> %s %s\n",ffn(),fn); 
  }
  /* argument check */
  VDASSERTW(form);

  /* inits just to keep out possible junk */
  *modTog = 0;
  *stageTog = 0;
  *nameTog = 0;
  *attrTog = 0;
  *itemTog = 0;

  /* check the status of the following toggles */
  VDfrmGetState(form,VDTVW_TG_MOD,modTog);
  VDfrmGetState(form,VDTVW_TG_STAGE,stageTog);
  VDfrmGetState(form,VDTVW_TG_NAME,nameTog);
  VDfrmGetState(form,VDTVW_TG_ATTR,attrTog);
  VDfrmGetState(form,VDTVW_TG_ITEM,itemTog);

  retFlag = 1;
  
wrapup:
  // say bye 
  if (traceFlag) {
    printf("<<** %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}
/*****************************************************
 *
 * options for controls based upon text box selection
 * and text box content. ~pn
 *
 *****************************************************/
IGRint VDtvwTextBoxCtrl(char *form)
{
  VDASSERT_FN("VDtvwTextBoxCtrl");
  IGRint retFlag = 0;
  IGRint modTog,stageTog,nameTog,attrTog,itemTog;
  IGRchar hilite[128],parent[128],bln[128];
  IGRchar sets[128],stage[128],name[128],afrom[128],ato[128],attrName[128],attrValue[128];
  IGRint  row,rows;
  IGRchar setsText[128];
  
  
  /* say hi */
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
  /* get the data from the rolling text boxes */
  VDtvwGetRollText(form,hilite,parent,bln);

  /* get the data from the other text boxes */
  VDtvwGetSelectionText(form,sets,stage,name,afrom,ato,attrName,attrValue);

  /* get the toggle settings off the form */
  VDtvwGetToggleState(form,&modTog,&stageTog,&nameTog,&attrTog,&itemTog);

  {
	IGRint	chk_sets = 0, chk_expr = 0;
	FIg_get_state( form, VDTVW_C_SETS, &chk_sets );
	FIg_get_state( form, VDTVW_C_EXPR, &chk_expr );
	if( chk_sets == chk_expr ) {
	  chk_sets = 1;
	  chk_expr = 0;
	  FIg_set_state( form, VDTVW_C_SETS, chk_sets );
	  FIg_set_state( form, VDTVW_C_EXPR, chk_expr );
	}

	if( chk_sets ) {
	  FIg_enable(  form, VDTVW_G_SS );
	  FIg_disable(  form, VDTVW_T_EXPR );
	}
	else {
	  FIg_disable(  form, VDTVW_G_SS );
	  FIg_enable(  form, VDTVW_T_EXPR );
	}
  }

  if(itemTog == 0)  FIg_enable(form,VDTVW_TG_ATTR);
  
  
  retFlag = 1;
wrapup:
  /* say bye */
  if (traceFlag) printf("<<< %s %s(%d)\n",ffn(),fn,retFlag);
  return retFlag;
}

/********************************************
 *
 * Turn on or off the Accept button based upon
 * content of the selection ~pn
 *
 ********************************************/
IGRint VDtvwAcceptCtrl(Form form)
{
  VDASSERT_FN("VDtvw");
  IGRint retFlag = 0;
  IGRint acceptOK = 0;
  
  /* say hi */
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

  /* args check */
  VDASSERTW(form);
  
  /* check to see if it is ok */
  VDtvwIsAcceptOK(form,&acceptOK);
  
  /* do it */
  if(acceptOK & 1) {
    FIg_enable(form,FI_ACCEPT);
  } else {
    FIg_disable(form,FI_ACCEPT);
  }
  
  retFlag = 1;
wrapup:
  /* say bye */
  if (traceFlag) printf("<<< %s %s(%d)\n",ffn(),fn,retFlag);
  return retFlag;
}

/********************************************
 *
 * Verify if Accept is to be on or off
 * reads the list of nodes to see if any
 * are selected if so it says OK! ~pn
 *
 ********************************************/
IGRint VDtvwIsAcceptOK(Form form,IGRint *acceptOK)
{
  VDASSERT_FN("VDtvwIsAcceptOK");
  IGRint retFlag = 0;
  IGRint row,rows,selFlag,pos;
  IGRchar attr[128],exp[128],data[128];
  TGRid   nodeID;
 
  /* say hi */
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

  /* inits */
  row = rows = selFlag = pos = 0;
  *acceptOK = 0;
  
  VDASSERTW(form);
 
  /* get the number of rows posted already */
  VIfld_get_num_rows(form, VDTVW_MCOL_TREE, &rows);
  for(row = 0; row < rows;row++) {
    
    VDtvwFormGetTreeRowData(form,VDTVW_MCOL_TREE,row,attr,exp,data,&nodeID,&selFlag,&pos);
  
    if(selFlag == 1) {
      *acceptOK = 1;
      break;
    }
  }
  

  retFlag = 1;
wrapup:
  /* say bye */
  if (traceFlag) printf("<<< %s %s(%d)\n",ffn(),fn,retFlag);
  return retFlag;
}

/*****************************************************
 *
 * options control on the form for toggles
 * controls visibility of items  based upon
 * the toggles 
 * this is for devices in the status box below ~pn
 *
 *****************************************************/
IGRstat VDtvwToggleViewCtrl(char *form)
{
  VDASSERT_FN("VDtvwToggleViewCtrl");
  IGRint  retFlag = 0;
  IGRint  flag = 0;
  IGRint  modTog,stageTog,nameTog,attrTog,itemTog;

  // say hi
  if (traceFlag) {
    printf("**>> %s %s\n",ffn(),fn); 
  }
  /* argument check */
  VDASSERTW(form);

  /* check the status of the following toggles */
  VDtvwGetToggleState(form,
		      &modTog,
		      &stageTog,
		      &nameTog,
		      &attrTog,
		      &itemTog);

  if(traceFlag) printf("attrTog[%d]\n",attrTog);
  
  /*
   * modTog is ignored here since it does not set the visibility of anything
   * in this process 
   */
  /* some default switch settings */
  /* if any selection options in (item) turn on buttons otherwise off */

  if(itemTog == 0) {
    if(stageTog == 1) {
      FIg_enable(form,VDTVW_T_STAGE);
      FIg_display(form,VDTVW_T_STAGE);
    }
    if(nameTog == 1) {
      FIg_enable(form,VDTVW_T_NAME);
      FIg_display(form,VDTVW_T_NAME);
    }
    
  }
  
  if((nameTog == 0) && (stageTog == 0) && (attrTog == 0)) {
    FIg_disable(form,VDTVW_B_SEL_1);
    FIg_disable(form,VDTVW_B_CLR_1);
  } else {
    FIg_enable(form,VDTVW_B_SEL_1);
    FIg_enable(form,VDTVW_B_CLR_1);  
  }
  
  if(nameTog == 1)  {
    FIg_set_state_on(form,VDTVW_TG_STAGE);
    stageTog = 1;
    if(itemTog == 0) {
      FIg_enable(form,VDTVW_T_STAGE);
      FIg_display(form,VDTVW_T_STAGE);
    }
  }
  
  if((attrTog == 1) && (itemTog == 0))   {
    FIg_set_state_on(form,VDTVW_TG_STAGE);
    stageTog = 1;
    FIg_enable(form,VDTVW_T_STAGE);
    FIg_display(form,VDTVW_T_STAGE);
  }
  
  if(attrTog == 0) {
    FIg_disable(form,VDTVW_T_BLN);
  } else {
    FIg_enable(form,VDTVW_T_BLN);
  }
  
  

  if((stageTog == 0) && (nameTog == 0)) {
    FIg_disable( form, VDTVW_T_NAME);
    FIg_disable(form,VDTVW_T_STAGE);
  }
  if(stageTog == 1) {
     FIg_display( form, VDTVW_T_STAGE);
     FIg_enable( form, VDTVW_T_STAGE);
     FIg_display( form, VDTVW_T_NAME);
     if(nameTog == 0) {
       FIg_disable( form, VDTVW_T_NAME);
     } 
  }
  if(nameTog == 1) {
    FIg_display( form, VDTVW_T_STAGE);
    FIg_display( form, VDTVW_T_NAME);
    FIg_enable( form, VDTVW_T_STAGE);
    FIg_enable( form, VDTVW_T_NAME);
  }
  if(itemTog == 0) {
    if(stageTog == 1) {
      FIg_enable(form,VDTVW_T_STAGE);
      FIg_display(form,VDTVW_T_STAGE);
    }
  }
  

  
  VDtvwIndexRangeCtrl(form);
  retFlag = 1;
  
wrapup:
  // say bye 
  if (traceFlag) {
    printf("<<** %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}


/*****************************************************
 *
 * Display or Remove Attribute Selection options
 * *flag == 0 removes the items from view
 * *flag == 1 places the items in view ~pn
 *
 *
 *****************************************************/
IGRint VDtvwAttrViewCtrl(char *form)
{
  VDASSERT_FN("VDtvwAttrViewCtrl");
  IGRint  retFlag = 0;
  IGRint  flag = 0;

   
  
  // say hi
  if (traceFlag) {
    printf("**>> %s %s\n",ffn(),fn); 
  }
 
  VDASSERTW(form);
  /* get the toggle flag */
  VDfrmGetState(form,VDTVW_TG_ATTR,&flag);
  FIg_display( form, VDTVW_L_ANAME);
  FIg_display( form, VDTVW_L_AVAL);
  FIg_display( form, VDTVW_T_AVAL);
  FIg_display( form, VDTVW_T_ANAME);
  FIg_display( form, VDTVW_L_BLN);
  FIg_display( form, VDTVW_T_BLN);
  /* erase any if no */
  if(flag == 0) {
    if(traceFlag) printf("erasing\n");
    FIg_disable( form, VDTVW_L_ANAME);
    FIg_disable( form, VDTVW_L_AVAL);
    FIg_disable( form, VDTVW_T_AVAL);
    FIg_disable( form, VDTVW_T_ANAME);
    FIg_disable( form, VDTVW_L_BLN);
    FIg_disable( form, VDTVW_T_BLN);
  }
  /* desplay any if yes */
  if(flag == 1) {
    if(traceFlag) printf("displaying\n");

    FIg_enable( form, VDTVW_L_ANAME);
    FIg_enable( form, VDTVW_L_AVAL);
    FIg_enable( form, VDTVW_T_AVAL);
    FIg_enable( form, VDTVW_T_ANAME);
    FIg_enable( form, VDTVW_L_BLN);
    FIg_enable( form, VDTVW_T_BLN);
  } 

  retFlag = 1;
  
wrapup:
  // say bye 
  if (traceFlag) {
    printf("<<** %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}

/*****************************************************
 *
 * Display or Remove gadgets related to "Index" and "Range" selection
 * *flag == 0 removes the items from view
 * *flag == 1 places the items in view ~pn
 *
 *
 *****************************************************/
IGRint VDtvwIndexRangeCtrl(char *form)
{
  VDASSERT_FN("VDtvwIndexRangeCtrl");
  IGRint  retFlag = 0;
  IGRint  flag = 0;

  traceFlag = 0;
 
  // say hi
  if (traceFlag) {
    printf("**>> %s %s\n",ffn(),fn); 
  }
 
  VDASSERTW(form);
  /* get the toggle flag */
  VDfrmGetState(form,VDTVW_TG_ITEM,&flag);

  /* index is the option */
  if(flag == 0) {
    FIg_erase( form, VDTVW_T_FROM);
    FIg_erase( form, VDTVW_T_TO);    
    FIg_erase( form, VDTVW_B_FROM);
    FIg_erase( form, VDTVW_B_TO);
    FIg_erase( form, VDTVW_B_SEL_2);
    FIg_erase( form, VDTVW_B_CLR_2);
    FIg_display( form, VDTVW_T_STAGE);
    FIg_display( form, VDTVW_T_NAME);
    FIg_display( form, VDTVW_L_STAGE);
    FIg_display( form, VDTVW_L_NAME);
    FIg_display( form, VDTVW_TG_STAGE);
    FIg_display( form, VDTVW_TG_NAME);
    FIg_display( form, VDTVW_B_SEL_1);
    FIg_display( form, VDTVW_B_CLR_1);
  }
  /* range is the option */
  if(flag == 1) {
    FIg_erase( form, VDTVW_T_STAGE);
    FIg_erase( form, VDTVW_T_NAME);
    FIg_erase( form, VDTVW_L_STAGE);
    FIg_erase( form, VDTVW_L_NAME);    
    FIg_erase( form, VDTVW_TG_STAGE);
    FIg_erase( form, VDTVW_TG_NAME);
    FIg_erase( form, VDTVW_B_SEL_1);
    FIg_erase( form, VDTVW_B_CLR_1);
    FIg_display( form, VDTVW_T_FROM);
    FIg_display( form, VDTVW_T_TO);
    FIg_display( form, VDTVW_B_FROM);
    FIg_display( form, VDTVW_B_TO);
    FIg_display( form, VDTVW_B_SEL_2);
    FIg_display( form, VDTVW_B_CLR_2);
  }

  retFlag = 1;
  
wrapup:
  // say bye 
  if (traceFlag) {
    printf("<<** %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}
/********************************************
 *
 * Get the rootID ~pn
 *
 ********************************************/
IGRint VDtvwGetRootID(TGRid *nodeID)
{
  VDASSERT_FN("VDtvwGetRootID");
  IGRint retFlag = 0;
   
  
  /* say hi */
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
  
  VDASSERTW(nodeID);
  /* new rootID */
  nodeID->osnum = rootID.osnum;
  nodeID->objid = rootID.objid;

  retFlag = 1;
wrapup:
  /* say bye */
  if (traceFlag) printf("<<< %s %s(%d)\n",ffn(),fn,retFlag);
  return retFlag;
}
/********************************************
 *
 * Set the rootID ~pn*
 * (Called to set the rootID from CTBS)
 *
 ********************************************/
IGRint VDtvwSetRootID(TGRid *nodeID)
{
  VDASSERT_FN("VDtvwSetRootID");
  IGRint retFlag = 0;
  
  /* say hi */
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
  VDASSERTW(nodeID);
  if(!((rootID.objid == nodeID->objid) && (rootID.osnum == nodeID->osnum))) {
    /* new rootID */
    rootID.osnum = nodeID->osnum;
    rootID.objid = nodeID->objid;
    if(hListIDsCnt > 0) _FREE( hListIDs );
    hListIDsCnt = 0;
    AcceptStatus = 0;
  } 

  VDctxGetTreeCP(NULL,nodeID,&setID);
  
  retFlag = 1;
wrapup:
  /* say bye */
  if (traceFlag) printf("<<< %s %s(%d)\n",ffn(),fn,retFlag);
  return retFlag;
}
/********************************************
 *
 * Control the activity of the gadgets 
 * for the user based rootID ~pn
 *
 ********************************************/
IGRint VDtvwRootIDCtrl(char *form)
{
  VDASSERT_FN("VDtvwRootIDCtrl");
  IGRint retFlag = 0;
  
  /* say hi */
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
  if(rootID.objid == NULL_OBJID) {
    /* turn off the gadgets for user control */
    FIg_disable(form, VDTVW_B_SEL_1);
    FIg_disable(form, VDTVW_B_CLR_1);
    FIg_disable(form, VDTVW_T_STAGE);
    FIg_disable(form, VDTVW_T_NAME);
    FIg_disable(form, VDTVW_TG_ITEM);
    FIg_disable(form, VDTVW_TG_MOD);
    FIg_disable(form, VDTVW_TG_STAGE);
    FIg_disable(form, VDTVW_TG_NAME);
    FIg_disable(form, VDTVW_TG_ATTR);
    FIg_disable(form, VDTVW_L_STAGE);
    FIg_disable(form, VDTVW_L_NAME);
    FIg_disable(form, VDTVW_L_ITEMS);
    FIg_disable(form, VDTVW_L_ATTR);
    FIg_disable(form, VDTVW_RT_ALL);
  } else {
    /* turn on the gadgets for user control */
    FIg_enable(form, VDTVW_B_SEL_1);
    FIg_enable(form, VDTVW_B_CLR_1);
    FIg_enable(form, VDTVW_T_STAGE);
    FIg_enable(form, VDTVW_T_NAME);
    FIg_enable(form, VDTVW_TG_ITEM);
    FIg_enable(form, VDTVW_TG_MOD);
    FIg_enable(form, VDTVW_TG_STAGE);
    FIg_enable(form, VDTVW_TG_NAME);
    FIg_enable(form, VDTVW_TG_ATTR);
    FIg_enable(form, VDTVW_L_STAGE);
    FIg_enable(form, VDTVW_L_NAME);
    FIg_enable(form, VDTVW_L_ITEMS);
    FIg_enable(form, VDTVW_L_ATTR);
    FIg_enable(form, VDTVW_RT_ALL);
  }
  
  
 
  retFlag = 1;
wrapup:
  /* say bye */
  if (traceFlag) printf("<<< %s %s(%d)\n",ffn(),fn,retFlag);
  return retFlag;
}

/********************************************
 *
 * From/To list control ~pn
 *
 ********************************************/
IGRint VDtvwFromToCtrl(Form form)
{
  VDASSERT_FN("VDtvwFromToCtrl");
  IGRint retFlag = 0;
  IGRint row = 0;
   
  
  
  /* say hi */
  if (traceFlag) {
    printf("\n>>> %s %s \n",ffn(),fn);
    printf("fromID[%d][%d] toID[%d][%d]\n",fromID.osnum,fromID.objid,toID.osnum,toID.objid);
  }
  
  /* find fromID's row */
  VDtvwFormFindNode(form,VDTVW_MCOL_TREE,fromID,&row);
  if(traceFlag) printf("row selected is [%d]\n",row);
  
  if(row < 0) fromID.objid = NULL_OBJID;

  /* set null to "" */
  if(fromID.objid == NULL_OBJID) FIg_set_text( form, VDTVW_T_FROM, "" ); 
  
  /* find toID's row */
  VDtvwFormFindNode(form,VDTVW_MCOL_TREE,toID,&row);
  if(row < 0) toID.objid = NULL_OBJID;

  /* set null to "" */
  if(toID.objid == NULL_OBJID) FIg_set_text( form, VDTVW_T_TO, "" ); 

  retFlag = 1;
wrapup:
  /* say bye */
  if (traceFlag) printf("<<< %s %s(%d)\n",ffn(),fn,retFlag);
  return retFlag;
}

/********************************************
 *
 * Set the "Form" text ~pn
 *
 ********************************************/
IGRint VDtvwSetFromText(Form form)
{
  VDASSERT_FN("VDtvwSetFromText");
  IGRint retFlag = 0;
  IGRint state,row,pos,selFlag,i,sts;
  IGRchar attr[128],exp[128],data[128],*p;
  TGRid   nodeID;
  TGRid  *cohortIDs;
  IGRint  cohortIDsCnt = 0;
   
  /* say hi */
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

  /* checks */
  VDASSERTW(form);
  
  /* inits */
  strcpy(attr,EXP_EMP);
  strcpy(attr,EXP_EMP);
  strcpy(data,"");
  
  /* get the button status */
  FIg_get_state(form,VDTVW_B_FROM,&state);
  if(state != 1) goto wrapup;
  FIg_set_state(form,VDTVW_B_FROM,0);
  FIg_set_text(form,VDTVW_T_FROM,"");
  toID.objid == NULL_OBJID;

  /* get the active row on the multicolumn form */
  FIfld_get_active_row( form,VDTVW_MCOL_TREE,&row,&pos );
  FIfld_get_select( form,VDTVW_MCOL_TREE,row ,2,&selFlag ) ; 

  /* get the selected ID  and data */
  VDtvwFormGetTreeRowData(form,VDTVW_MCOL_TREE,row,attr,exp,data,&nodeID,&selFlag,&pos);
  if(traceFlag) printf("##### nodeID[%d][%d]\n",nodeID.osnum,nodeID.objid);
  
  if(nodeID.objid == NULL_OBJID) goto wrapup;

  if(traceFlag) printf("getting cohorts for nodeID[%d][%d]\n",nodeID.osnum,nodeID.objid);
  /* get my cohorts */
  sts = vdtvw$GetCohortList(nodeID      = nodeID,
			    nodesOut    = &cohortIDs,
			    nodesOutCnt = &cohortIDsCnt);
  
  if(traceFlag) printf("cohortIDsCnt[%d] sts [%d] toID[%d][%d]\n",
		       cohortIDsCnt,sts,toID.osnum,toID.objid);

  /* get the "TO" value  and check if it is ok with this selection */
  if(toID.objid != NULL_OBJID) {
    if((cohortIDsCnt < 1) || (sts == 0)) {
      /* it was not in the list so lets clean up and get out of here */
      fromID.objid == NULL_OBJID;
      FIg_set_text(form,VDTVW_T_FROM,"");
      /* post the selection back to whatever it was */
      if(selFlag & 1) {
	selFlag = 0;
      } else {
	selFlag = 1;
      }
      FIfld_set_select(form,VDTVW_MCOL_TREE,row,2,selFlag); 
      /* print message to the user */
      FIg_set_text(form,10,"Invalid Input");
      
      /* go home */
      retFlag = 1;
      goto wrapup;
      
    }

    if(traceFlag) printf("checking to see if toID is in the list\n");
    if(!(vdtvw$IsNodeInList(nodeID  = &toID,
			    List    = cohortIDs,
			    ListCnt = cohortIDsCnt))) {
      if(traceFlag) printf("It was not in the list\n");
      /* it was not in the list so lets clean up and get out of here */
      fromID.objid == NULL_OBJID;
      FIg_set_text(form,VDTVW_T_FROM,"");
      /* post the selection back to whatever it was */
      if(selFlag & 1) {
	selFlag = 0;
      } else {
	selFlag = 1;
      }
      FIfld_set_select(form,VDTVW_MCOL_TREE,row,2,selFlag); 
      /* print message to the user */
      FIg_set_text(form,10,"[From] Invalid: Level must be same as [To]");

      /* go home */
      retFlag = 1;
      goto wrapup;
    }
  }
  
  
  /* clip the string */
  p = data;
  for(i = 0;i < strlen(data);i++) {
    if(!(*p == ' ')) {
      strcpy(data,p);
      break;
    }
    p++;
  }
  /* place the data in the textbox */
  FIg_set_text(form,VDTVW_T_FROM,data);
  

  /* notifiy the fromID */
  fromID = nodeID;
 

  /* post the selection back to whatever it was */
  if(selFlag & 1) {
    selFlag = 0;
  } else {
    selFlag = 1;
  }
  if(traceFlag) printf("setting row[%d] to select[%d]\n",row,selFlag);
  FIfld_set_select(form,VDTVW_MCOL_TREE,row,2,selFlag); 
  
  retFlag = 1;
 wrapup:
  if(cohortIDsCnt > 0) _FREE(cohortIDs);
  /* say bye */
  if (traceFlag) printf("<<< %s %s(%d)\n",ffn(),fn,retFlag);
  return retFlag;
}

/********************************************
 *
 * Set the "To" text ~pn
 *
 ********************************************/
IGRint VDtvwSetToText(Form form)
{
  VDASSERT_FN("VDtvwSetToText");
  IGRint retFlag = 0;
  IGRint state,row,pos,selFlag,i,sts;
  IGRchar attr[128],exp[128],data[128],*p;
  TGRid   nodeID;
  TGRid  *cohortIDs;
  IGRint  cohortIDsCnt = 0;
  
  /* say hi */
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

  /* checks */
  VDASSERTW(form);
  
  /* inits */
  strcpy(attr,EXP_EMP);
  strcpy(attr,EXP_EMP);
  strcpy(data,"");
  
  /* get the button status */
  FIg_get_state(form,VDTVW_B_TO,&state);
  if(state != 1) goto wrapup;
  FIg_set_state(form,VDTVW_B_TO,0);
  FIg_set_text(form,VDTVW_T_TO,"");
  toID.objid == NULL_OBJID;

  /* get the active row on the multicolumn form */
  FIfld_get_active_row( form,VDTVW_MCOL_TREE,&row,&pos );
  FIfld_get_select( form,VDTVW_MCOL_TREE,row ,2,&selFlag ) ; 

  /* get the selected ID  and data */
  VDtvwFormGetTreeRowData(form,VDTVW_MCOL_TREE,row,attr,exp,data,&nodeID,&selFlag,&pos);
  if(traceFlag) printf("##### nodeID[%d][%d]\n",nodeID.osnum,nodeID.objid);
  if(nodeID.objid == NULL_OBJID) goto wrapup;
  
  /* get my cohorts */
  if(traceFlag) printf("nodeID[%d][%d]\n",nodeID.osnum,nodeID.objid);
  sts = vdtvw$GetCohortList(nodeID      = nodeID,
			    nodesOut    = &cohortIDs,
			    nodesOutCnt = &cohortIDsCnt);

  if(traceFlag) printf("cohortIDsCnt[%d] sts [%d] fromID [%d][%d]\n",
		       cohortIDsCnt,sts,fromID.osnum,fromID.objid);
  /* get the "From" value  and check if it is ok with this selection */
  if(fromID.objid != NULL_OBJID) {

    if((cohortIDsCnt < 1) || (sts == 0)) {
      /* it was not in the list so lets clean up and get out of here */
      toID.objid == NULL_OBJID;
      FIg_set_text(form,VDTVW_T_TO,"");
      /* post the selection back to whatever it was */
      if(selFlag & 1) {
	selFlag = 0;
      } else {
	selFlag = 1;
      }
      FIfld_set_select(form,VDTVW_MCOL_TREE,row,2,selFlag); 
      /* print message to the user */
      FIg_set_text(form,10,"Invalid Input");
    
      /* go home */
      retFlag = 1;
      goto wrapup;
      
    }


    if(traceFlag) printf("checking if the fromID is in the list\n");
    if(!(vdtvw$IsNodeInList(nodeID  = &fromID,
			    List    = cohortIDs,
			    ListCnt = cohortIDsCnt))) {
      if(traceFlag) printf("It was not in the list\n");
      /* it was not in the list so lets clean up and get out of here */
      toID.objid == NULL_OBJID;
      FIg_set_text(form,VDTVW_T_TO,"");
      /* post the selection back to whatever it was */
      if(selFlag & 1) {
	selFlag = 0;
      } else {
	selFlag = 1;
      }
      FIfld_set_select(form,VDTVW_MCOL_TREE,row,2,selFlag); 
      /* print message to the user */
      FIg_set_text(form,10,"[To] Invalid: Level must be same as [From]");

      /* go home */
      retFlag = 1;
      goto wrapup;
    }
  }

  /* clip the string */
  p = data;
  for(i = 0;i < strlen(data);i++) {
    if(!(*p == ' ')) {
      strcpy(data,p);
      break;
    }
    p++;
  }
  /* place the data in the textbox */
  FIg_set_text(form,VDTVW_T_TO,data);

  /* notifiy the toID */
  toID = nodeID;
  
    /* post the selection back to whatever it was */
  if(selFlag & 1) {
    selFlag = 0;
  } else {
    selFlag = 1;
  }
  if(traceFlag) printf("setting row[%d] to select[%d]\n",row,selFlag);
  FIfld_set_select(form,VDTVW_MCOL_TREE,row,2,selFlag);
  
  retFlag = 1;
 wrapup:
  if(cohortIDsCnt > 0) _FREE(cohortIDs);
  /* say bye */
  if (traceFlag) printf("<<< %s %s(%d)\n",ffn(),fn,retFlag);
  return retFlag;
}

/********************************************
 *
 * Get a test ID form wenwen1.a file ~pn
 * used for test operations only delete when done
 *
 ********************************************/
IGRint VDtvwGetNodeIDTest(TGRid *nodeID)
{
  VDASSERT_FN("VDtvwGetNodeIDTest");
  IGRint retFlag = 0;
  
  /* say hi */
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
  
  VDASSERTW(nodeID);
  nodeID->osnum = 2;
  nodeID->objid = 1237;
  //nodeID->objid = NULL_OBJID;
  retFlag = 1;
wrapup:
  /* say bye */
  if (traceFlag) printf("<<< %s %s(%d)\n",ffn(),fn,retFlag);
  return retFlag;
}

/********************************************
 *
 * fetch a list of hilited nodes from form ~pn*
 *
 ********************************************/
  /*
   * This is supposed to leave the hListIDs list allocated on exit
   * frees the list on entry to reset it accordingly
   */
IGRint VDtvwGetHilitedNodesList(Form    form,
			       IGRint  gadget,
			       TGRid **nodeIDs,
			       IGRint *nodeIDsCnt)
{
  VDASSERT_FN("VDtvwGetHilitedNodesList");
  IGRint retFlag = 0;
  IGRint row,rows,i,cnt,selFlag,pos;
  IGRchar attr[128],exp[128];
  IGRchar data[128];
  TGRid  nodeID,printID;
  
  traceFlag = 0;
  
  /* say hi */
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

  /* Inits */
  if(*nodeIDsCnt > 0) _FREE( *nodeIDs );
  *nodeIDsCnt  = 0;
  nodeID.objid = NULL_OBJID;
  if (traceFlag) printf("\t>>> %s %s loc #1\n",ffn(),fn);
  /* args */
  VDASSERTW(form);
  if(gadget < 11)  goto wrapup;
  
  /* fetch the number of rows */
  VIfld_get_num_rows(form, gadget, &rows);
  if(rows < 1) {
    goto wrapup;
  }
  
  if (traceFlag) printf("\t>>> %s %s loc #2\n",ffn(),fn);
  /* count up the hilited IDs */
  cnt = 0;
  for(row = 0;row < rows;row++) {
    selFlag = 0;
    VDtvwFormGetTreeRowData(form,gadget,row,attr,exp,data,&nodeID,&selFlag,&pos);
    if(traceFlag) printf("nodeID[%d][%d] [%d]\n",nodeID.osnum,nodeID.objid,selFlag);
    if(selFlag == 1) cnt++;
  }
  if (traceFlag) printf("\t>>> %s %s loc #3 cnt = [%d]\n",ffn(),fn,cnt);
  if(cnt & 0) {
    goto wrapup;
  }
  if (traceFlag) printf("\t>>> %s %s loc #4\n",ffn(),fn);
  /* allocate the memory for the nodeIDs */
  if(cnt < 1) {
    *nodeIDsCnt = 0;
    goto wrapup;
  }
  *nodeIDs = NULL;
  if(traceFlag)  printf("allocated [%d]\n",(cnt + 1));
  
  *nodeIDs = _MALLOC( (cnt + 1) , TGRid );
  if(*nodeIDs == NULL) goto wrapup;
  /* place the nodeIDs in a list */
  cnt = 0;
  for(row = 0;row < rows;row++) {
    nodeID.objid == NULL_OBJID;
    selFlag = 0;
    VDtvwFormGetTreeRowData(form,gadget,row,attr,exp,data,&nodeID,&selFlag,&pos);
    
    if(selFlag == 1) {
      (*nodeIDs)[cnt].osnum = nodeID.osnum;
      (*nodeIDs)[cnt].objid = nodeID.objid;
      /*
      if(traceFlag) {
	printID.osnum = (*nodeIDs)[cnt].osnum;
	printID.objid = (*nodeIDs)[cnt].objid;
	
	printf("placed cnt[%d] row [%d] node [%d][%d]\n",cnt,row,
	       printID.osnum,printID.objid);
      }
      */
      cnt++;
    }
  }
  *nodeIDsCnt = cnt;
  retFlag = 1;
wrapup:
  /* say bye */
  if (traceFlag) printf("<<< %s %s(%d)\n",ffn(),fn,retFlag);
  return retFlag;
  /*
   * This is supposed to leave the hListIDs list allocated on exit
   * frees the list on entry to reset it accordingly
   */
}


/********************************************
 *
 * Used by the PPL to notify if the form has been
 * cancel ~pn
 *
 ********************************************/
IGRint VDtvwSetCancelStatus()
{
  VDASSERT_FN("VDtvwSetCancelStatus");
  IGRint retFlag = 0;
  
  /* say hi */
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
  
  AcceptStatus = 0;

  retFlag = 1;
wrapup:
  /* say bye */
  if (traceFlag) printf("<<< %s %s(%d)\n",ffn(),fn,retFlag);
  return retFlag;
}
/********************************************
 *
 * refresh the node status in the multicol
 * gadget  (num_rows) ~pn
 *
 ********************************************/
IGRint VDtvwRefreshTree(Form form)
{
  VDASSERT_FN("VDtvwRefreshTree");
  IGRint retFlag = 0;
  IGRint rows;
 
  /* say hi */
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
  
  /* fetch the number of rows */
  rows = 0;
  VIfld_get_num_rows(form,VDTVW_MCOL_TREE,&rows);
  
  /* update the number of rows */
  FIfld_set_num_rows(form,VDTVW_MCOL_TREE,rows);


  retFlag = 1;
wrapup:
  /* say bye */
  if (traceFlag) printf("<<< %s %s(%d)\n",ffn(),fn,retFlag);
  return retFlag;
}

/********************************************
 *
 * fetch the fromID and the toID ~pn
 * this is in order not by way of selection
 * but actual presentation order
 *
 ********************************************/
IGRint VDtvwGetFromToRange(Form form,IGRint *fromRow,IGRint *toRow)
{
  VDASSERT_FN("VDtvwGetFromToRange");
  IGRint retFlag = 0;
  IGRint beginRow,endRow,tmpRow;
  
  /* say hi */
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

  /* init */
  *fromRow = -1;
  *toRow   = -1;
  
  /* check theID status */
  if(!((fromID.objid != NULL_OBJID) && (toID.objid != NULL_OBJID))) goto wrapup;
  
    /* find fromID's row */
  VDtvwFormFindNode(form,VDTVW_MCOL_TREE,fromID,&beginRow);
  if(beginRow < 0) goto wrapup;

  /* find toID's row */
  VDtvwFormFindNode(form,VDTVW_MCOL_TREE,toID,&endRow);
  if(endRow < 0) goto wrapup;

  /* check the order and swap if need be */
  if(endRow < beginRow) {
    tmpRow = endRow;
    endRow = beginRow;
    beginRow = tmpRow;
  }
  *fromRow = beginRow;
  *toRow   = endRow;

  retFlag = 1;
wrapup:
  /* say bye */
  if (traceFlag) printf("<<< %s %s(%d)\n",ffn(),fn,retFlag);
  return retFlag;
}

/********************************************
 *
 * fetches the fromID and toID for use anywhere
 * good  for list generation ~pn
 *
 ********************************************/
IGRint VDtvwGetRangeIDs(TGRid *fID,TGRid *tID)
{
  VDASSERT_FN("VDtvwGetRangeIDs");
  IGRint retFlag = 0;

   
  
  /* say hi */
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
  
  tID->osnum = toID.osnum;
  tID->objid = toID.objid;
  
  fID->osnum = fromID.osnum;
  fID->objid = fromID.objid;

  retFlag = 1;
wrapup:
  /* say bye */
  if (traceFlag) printf("<<< %s %s(%d)\n",ffn(),fn,retFlag);
  return retFlag;
}

/********************************************
 *
 * limit the options available for the user
 * on the text gadget for boolean
 * This is important since there are several 
 * types of search criterion and some
 * do not apply if the data in the text box 
 * has changed ~pn
 *
 ********************************************/
IGRint VDtvwBlnRollTextCtrl(Form form)
{
  VDASSERT_FN("VDtvwBlnRollTextCtrl");
  IGRint retFlag = 0;
  IGRchar buf[128];
  IGRint  modTog,stageTog,nameTog,attrTog,itemTog;
  IGRchar sets[128],stage[128],name[128],afrom[128],ato[128],attrName[128],attrValue[128];
  IGRchar *p,blnTxt[128];
  IGRint  rows = 0;

   
  
  /* say hi */
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

  /* args */
  VDASSERTW(form);

  /* check the status of the following toggles */
  VDtvwGetToggleState(form,&modTog,&stageTog,&nameTog,&attrTog,&itemTog);

  /* if there is no reason to go here don't */
  if(attrTog & 0) goto wrapup;
  
 /* get the data from the text boxes */
  VDtvwGetSelectionText(form,sets,stage,name,afrom,ato,attrName,attrValue);

  /* get the text data from the box */
  FIg_get_text(form,VDTVW_T_BLN,blnTxt);

  
  /* clear up the form */
  FIg_reset( form,VDTVW_T_BLN );
  FIg_display( form,VDTVW_T_BLN ); 
  FIg_enable( form,VDTVW_T_BLN ); 


  if(traceFlag) printf("Setting the initial values\n");
  vdfrm$SetListText( form = form,gadget = VDTVW_T_BLN,row = 0,txt = "=");
  vdfrm$SetListText( form = form,gadget = VDTVW_T_BLN,row = 1,txt = "!=");
  
  /* check to see if there is a '*' in the field (wildcard) */
  p = NULL;
  p = strchr(attrValue,'*');
  if(p == NULL) {
    /* this means no wildcards */
    if(traceFlag) printf("found no wildcards \n");
    vdfrm$SetListText( form = form,gadget = VDTVW_T_BLN,row = 2,txt = "<");
    vdfrm$SetListText( form = form,gadget = VDTVW_T_BLN,row = 3,txt = ">");
    vdfrm$SetListText( form = form,gadget = VDTVW_T_BLN,row = 4,txt = "<=");
    vdfrm$SetListText( form = form,gadget = VDTVW_T_BLN,row = 5,txt = ">=");
  } 
  
  /* get the number of rows */
  VIfld_get_num_rows(form,VDTVW_T_BLN, &rows);
  if(rows < 2) {
    if((strcmp(blnTxt,"=")) && (strcmp(blnTxt,"!="))) strcpy(blnTxt,"=");
  }
  
  if(!strcmp(blnTxt,""))  strcpy(blnTxt,"=");
  
  FIg_set_text( form,VDTVW_T_BLN,blnTxt);


  retFlag = 1;
  
wrapup:
 
  /* say bye */
  if (traceFlag) printf("<<< %s %s(%d)\n",ffn(),fn,retFlag);
  return retFlag;
}

/********************************************
 *
 * Get the data from the form  and
 * save it for use in reset operations ~pn
 *
 ********************************************/
IGRint VDtvwGetFormSettings(Form form)
{
  VDASSERT_FN("VDtvwGetFormSettings");
  IGRint retFlag = 0;
  IGRint modTog,stageTog,nameTog,attrTog,itemTog;
  IGRchar hilite[128],parent[128],bln[128];
  IGRchar sets[128],stage[128],name[128],afrom[128],ato[128],attrName[128],attrValue[128];
  IGRint  iParent = 0,iHilite = 0;
  
   
  
  /* say hi */
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

  /* args check */
  VDASSERTW(form);

  /* check the status of the following toggles */
  VDtvwGetToggleState(form,&modTog,&stageTog,&nameTog,&attrTog,&itemTog);

 /* get the data from the text boxes */
  VDtvwGetSelectionText(form,sets,stage,name,afrom,ato,attrName,attrValue);

  /* get the data from the rolling text boxes */
  VDtvwGetRollText(form,hilite,parent,bln);
  
  if(!strcmp(parent,"All"))       iParent = 2;
  if(!strcmp(parent,"One Level")) iParent = 1;
  if(!strcmp(parent,"Parent"))    iParent = 0;
  if(!strcmp(hilite,"None"))      iHilite = 0;
  if(!strcmp(hilite,"Model Obj")) iHilite = 1;
  if(!strcmp(hilite,"Drawing"))   iHilite = 2;
  if(!strcmp(hilite,"ALL"))       iHilite = 3;

  mem.itemTog  = itemTog;
  mem.modTog   = modTog;
  mem.stageTog = stageTog;
  mem.nameTog  = nameTog;
  mem.attrTog  = attrTog;
  mem.hilite   = iHilite;
  mem.parent   = iParent;
  strcpy(mem.sets,sets);
  strcpy(mem.stage,stage);
  strcpy(mem.name,name);
  strcpy(mem.afrom,afrom);
  strcpy(mem.ato,ato);
  strcpy(mem.attrName,attrName);
  strcpy(mem.attrValue,attrValue);
  strcpy(mem.bln,bln);
  mem.fromID.osnum = fromID.osnum;
  mem.toID.osnum   = toID.osnum;
  mem.fromID.objid = fromID.objid;
  mem.toID.objid   = toID.objid;

  retFlag = 1;
wrapup:
  /* say bye */
  if (traceFlag) printf("<<< %s %s(%d)\n",ffn(),fn,retFlag);
  return retFlag;
}

/********************************************
 *
 * Set the settings of the form for use ~pn
 *
 ********************************************/
IGRint VDtvwSetFormSettings(Form form)
{
  VDASSERT_FN("VDtvwSetFormSettings");
  IGRint retFlag = 0;
  IGRchar *p;


  /* say hi */
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

  /* args check */
  VDASSERTW(form);

  /* if it is not the same set the default settings */
  if(!((rootID.objid == mem.rootID.objid) && (rootID.osnum == mem.rootID.osnum))) {
    if(traceFlag) printf("We set the defaults\n");
    
    VDtvwSetDefaultFormSettings();
  }
  
  /* set the form with the data */
  rootID = mem.rootID;
  fromID = mem.fromID;
  toID   = mem.toID;

  /* set the toggles */
  FIg_set_state(form,VDTVW_TG_ITEM ,mem.itemTog);
  FIg_set_state(form,VDTVW_TG_MOD  ,mem.modTog);
  FIg_set_state(form,VDTVW_TG_STAGE,mem.stageTog);
  FIg_set_state(form,VDTVW_TG_NAME ,mem.nameTog);
  FIg_set_state(form,VDTVW_TG_ATTR ,mem.attrTog);

  /* set the RT text box */
  if(traceFlag) printf("setting active VDTVW_RT_ALL (%s)\n",mem.parent);
  FIfld_set_active_row(form,VDTVW_RT_ALL,mem.parent,0);
  FIfld_set_active_row(form,VDTVW_RT_HI ,mem.hilite,0);

  /* control the filling in of data and view of controls */
  VDtvwFormFillStageList(form,VDTVW_T_STAGE,VDTVW_MCOL_TREE);
  if(strcmp(mem.stage,"")) FIg_set_text(form,VDTVW_T_STAGE,mem.stage);
  VDtvwFormFillNamesList(form,VDTVW_T_NAME,VDTVW_MCOL_TREE);
  if(strcmp(mem.name,"")) FIg_set_text(form,VDTVW_T_NAME,mem.name);
  VDtvwRootIDCtrl(form);
  VDtvwToggleViewCtrl(form);
  VDtvwTextBoxCtrl(form);
  VDtvwFormFillAttrNameList(form);

  FIg_set_text(form,VDTVW_T_ANAME,mem.attrName);
  // VDtvwFormFillAttrValuesList(form,VDTVW_T_AVAL,VDTVW_T_ANAME);
  FIg_set_text(form,VDTVW_T_AVAL,mem.attrValue);
 
  FIg_set_text(form,VDTVW_T_FROM,mem.afrom);
  FIg_set_text(form,VDTVW_T_TO,mem.ato);

  VDtvwBlnRollTextCtrl(form);
  FIg_set_text(form,VDTVW_T_BLN,mem.bln);
  VDtvwAttrViewCtrl(form);
  retFlag = 1;
wrapup:
  VDtvwGetFormSettings(form);
  /* say bye */
  if (traceFlag) printf("<<< %s %s(%d)\n",ffn(),fn,retFlag);
  return retFlag;
}

/********************************************
 *
 *  Set the default settings for the from
 *  Does not update the form itself ~pn
 *
 ********************************************/
IGRint VDtvwSetDefaultFormSettings()
{
  VDASSERT_FN("VDtvwSetDefaultFormSettings");
  IGRint retFlag = 0;
  
  

  /* say hi */
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
  mem.itemTog  = 0;
  mem.modTog   = 0;
  mem.stageTog = 0;
  mem.nameTog  = 0;
  mem.attrTog  = 0;
  mem.parent   = 0;
  if(traceFlag) printf("Defaultsetting mem.hilite\n");
  mem.hilite   = 0;
  if(traceFlag) printf("Defaultset     mem.hilite\n");
  strcpy(mem.sets,"");
  strcpy(mem.stage,"");
  strcpy(mem.name,"");
  strcpy(mem.afrom,"");
  strcpy(mem.ato,"");
  strcpy(mem.attrName,"");
  strcpy(mem.attrValue,"");
  strcpy(mem.bln,"=");
  mem.rootID = rootID;
  fromID.objid = NULL_OBJID;
  toID.objid = NULL_OBJID;
  mem.fromID = fromID;
  mem.toID   = toID;

  retFlag = 1;
wrapup:
  /* say bye */
  if (traceFlag) printf("<<< %s %s(%d)\n",ffn(),fn,retFlag);
  return retFlag;
}


/********************************************
 *
 * Hilite the nodes * ~pn*
 *
 ********************************************/
/*
 * this uses the hlistIDs and but it does not
 * in any way set or allocate memory
 * it does not release it when done by design
 * this merely uses the data
 */
IGRint VDtvwHiliteItemsCtrl(Form form)
{
  VDASSERT_FN("VDtvwHiliteItemsCtrl");
  IGRchar hiliteStr[128];
  TGRid   rowID,*drawings;
  IGRint  retFlag = 0;
  IGRint  i = 0;
  IGRint  vdct1 = 0,vdat = 0;
  IGRchar data[128],attr[128],exp[128];
  IGRint  selFlag,pos,row,sts;
  enum GRdpmode mode;
  TGRobj_env     modelOE;

  
  
  /* say hi */
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
  //  if(traceFlag) goto wrapup;
  
  /* args */
  VDASSERTW(form);
  if(rootID.objid == NULL_OBJID) goto wrapup;

  /* inits */
  drawings = NULL;
  dp$erase_hilite(msg = &sts);
  if(traceFlag) printf("note the items should be unhilited now!!\n");
  
  vdct1 = vdobj$IsAncestryValid(objID = &rootID,
				superClassName = "VDct1Base");
  vdat = vdobj$IsAncestryValid(objID = &rootID,
				superClassName = "VDatBase");
  /* get the form stuff */
  FIfld_get_active_row(form,VDTVW_RT_HI,&row,&pos);
  
  strcpy(hiliteStr,"None");
  if(row == 3)strcpy(hiliteStr,"All");
  if(row == 1)strcpy(hiliteStr,"Model Obj");
  if(row == 2)strcpy(hiliteStr,"Drawing");

  if(hListIDsCnt == 0) goto wrapup;
  mode = GRhd;
  
  for(i = 0;i < hListIDsCnt;i++) {
   
    // Is it VDatBase
    if(vdat == 1) {
      if(traceFlag) printf("vdat hListIDs[%d] [%d][%d]\n",
			   i,hListIDs[i].osnum,hListIDs[i].objid);
      
      VDatPKTDisplayNode ( &hListIDs[i], mode, hiliteStr );
    }
    
    // Is it VDct1Base
    if(vdct1 == 1) {
      if(traceFlag) printf("vdct1 hListIDs[%d] [%d][%d]\n",
			   i,hListIDs[i].osnum,hListIDs[i].objid);
      VDct1PKTDisplayNode ( &hListIDs[i], mode, hiliteStr );
    }
  }

  retFlag = 1;
wrapup:
  /* say bye */
  if (traceFlag) printf("<<< %s %s(%d)\n",ffn(),fn,retFlag);
  return retFlag;
}	

/********************************************
 *
 * Hilite or unhilite an item from the user
 * active row selection ~pn
 *
 ********************************************/
IGRint VDtvwHiliteItemCtrl(Form form)
{
  VDASSERT_FN("VDtvwHiliteItemCtrl");
  IGRint retFlag = 0;
  IGRint  i,j,row,rows,selFlag,pos,offsetCnt = 0,rowOffsetCnt = 0;
  IGRchar attr[128],exp[128],data[128],hiliteStr[128],*p;
  IGRint vdat = 0,vdct1 = 0;
  TGRid   rowID;
  enum GRdpmode mode;

  
  
  /* say hi */
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

  /* args */
  VDASSERTW(form);
  
  /*  get the active row in the gadget */
  FIfld_get_active_row( form,VDTVW_MCOL_TREE,&row,&pos );

  /* get the selected ID  and data */
  VDtvwFormGetTreeRowData(form,VDTVW_MCOL_TREE,row,attr,exp,data,&rowID,&selFlag,&pos);
  if(rowID.objid == NULL_OBJID) goto wrapup;
  
  /* the the hilite control's data */
  FIfld_get_active_row(form,VDTVW_RT_HI,&row,&pos);
  strcpy(hiliteStr,"None");
  if(row == 3)strcpy(hiliteStr,"All");
  if(row == 1)strcpy(hiliteStr,"Model Obj");
  if(row == 2)strcpy(hiliteStr,"Drawing");

  /* set the mode */
  mode = GRhe;
  if(selFlag  == 1) mode = GRhd;

  /* get the ancestry stuff going  */
  // Is it VDatBase
  if(vdobj$IsAncestryValid(objID = &rowID,
			   superClassName = "VDatBase")) {
    vdat = 1;
    VDatPKTDisplayNode ( &rowID, mode, hiliteStr );
  }
  
  // Is it VDct1Base
  if(vdobj$IsAncestryValid(objID = &rowID,
			   superClassName = "VDct1Base")) {
    vdct1 = 1;
    VDct1PKTDisplayNode ( &rowID, mode, hiliteStr );
  }
  
  /* if we are hiliting we are done */
  if(selFlag == 1) {
    retFlag = 1;
    goto wrapup;
  }
  /* this is the unhilite and he is complicated because of dependencies */
  /* set the mode for hiliting */
  mode = GRhd;
  /* get the offset number of blanks in the row */
  p = data;
  for(i = 0;i < strlen(data);i++) {
    if(!(*p == ' ')) break;
    p++;
    offsetCnt++;
  }

  /*  get the active row in the gadget */
  FIfld_get_active_row( form,VDTVW_MCOL_TREE,&row,&pos );

  /* get the number of rows */ 
  VIfld_get_num_rows(form,VDTVW_MCOL_TREE,&rows);

  /* get the row location */
  VDtvwFormFindNode(form,VDTVW_MCOL_TREE,rowID,&row);

  /* loop through the remaining rows and rehilite any selected rows */
  row++;
  for(i = row;i < rows;i++) {
    VDtvwFormGetTreeRowData(form,VDTVW_MCOL_TREE,row,attr,exp,data,&rowID,&selFlag,&pos);
    if(rowID.objid == NULL_OBJID) continue;
    if(selFlag == 1) {
      /* get the offset */
      rowOffsetCnt = 0;
      p = data;
      for(i = 0;i < strlen(data);i++) {
	if(!(*p == ' ')) break;
	p++;
	rowOffsetCnt++;
      }
      if(rowOffsetCnt <= offsetCnt) break;
      if(vdat == 1) {
	VDatPKTDisplayNode ( &rowID, mode, hiliteStr );
      }
      if(vdct1 == 1) {
	VDct1PKTDisplayNode ( &rowID, mode, hiliteStr );
      }
    }
    row++;
  }
  
  retFlag = 1;
wrapup:
  /* say bye */
  if (traceFlag) printf("<<< %s %s(%d)\n",ffn(),fn,retFlag);
  return retFlag;
}

/*****************************************************************
 *
 * Read data list from a file
 *
 *****************************************************************/
IGRint	VDtvwReadFileData(
                                IGRchar         *fileName,
                                IGRchar         *path,
                                IGRchar         *listName,
                                IGRchar         **list,
                                IGRint          *itemLen,
                                IGRint          *count )
{
        IGRlong         sts = 0, msg;
        IGRint          maxLen = 0, cnt = 0;
        IGRchar         filePath[80], buf[80], tmpBuf[80];
        IGRchar         *ptr = NULL;
        FILE            *fp = NULL;

        filePath[0]     = '\0';

        if( !listName || !list || !itemLen || !count ) goto wrapup;

        *list = NULL;
        *count = 0;


        vd$file_path(   msg                             = &msg,
                        fileToFind                      = fileName,
                        dirToSearchFirst                = ".",
                        dirInProdPathToSearchThen       = path,
                        absPathName                     = filePath);


        if( !(msg&1) || filePath[0] == '\0' ) goto wrapup;

        fp = (FILE*)VD_openFile( &msg, filePath, "r" );
        if( !fp ) goto wrapup;

        while( fgets( buf, DI_PATH_MAX, fp ) ) {
                while( (ptr = strchr( buf, '\n' ) ) != NULL ) *ptr = ' ';
                VD_stripString(buf);

                if( buf[0] != '%' ) continue;
                buf[0] = ' ';
                VD_stripString(buf);
                if( !strcmp( buf, listName ) ) {
                        while( fgets( tmpBuf, DI_PATH_MAX, fp ) ) {
                                if( tmpBuf[0] == '%' ) break;
                                if( tmpBuf[0] == '#' ) {
                                        tmpBuf[0] = ' ';
                                        VD_stripString(tmpBuf);

                                        if( strlen(tmpBuf) > maxLen )
                                                maxLen = strlen(tmpBuf);
                                        cnt++;
                                }
                        }
                        break;
                }
        }

        maxLen++;
        *count = cnt;
        if( maxLen*cnt < 1 ) goto wrapup;

        *list = _MALLOC( cnt*maxLen, IGRchar );
        if( !list ) goto wrapup;

        rewind(fp);

        cnt = 0;
        while( fgets( buf, DI_PATH_MAX, fp ) ) {
           while( (ptr = strchr( buf, '\n' ) ) != NULL ) *ptr = ' ';
           VD_stripString(buf);
           if( buf[0] != '%' ) continue;
           buf[0] = ' ';
           VD_stripString(buf);
           if( !strcmp( buf, listName ) ) {
              while( fgets( tmpBuf, DI_PATH_MAX, fp ) ) {
                 if( tmpBuf[0] == '%' ) break;
                 if( tmpBuf[0] == '#' ) {
                    tmpBuf[0] = ' ';
                    while( (ptr = strchr( tmpBuf, '\n' ) ) != NULL ) *ptr = ' ';
                    VD_stripString(tmpBuf);
                    strcpy( &(*list)[cnt*maxLen], tmpBuf );
                    cnt++;
                 }
              }
              break;
           }
        }
        *itemLen = maxLen;

        sts = 1;
wrapup:
        return sts;
}

/*****************************************************************
 * 
 * Fill up conditional expression from file config/drawing/expr_tbl
 *
 *****************************************************************/
IGRint  VDtvwFillExprFromFile ( Form form )
{
	IGRlong         retFlag = 0;
        IGRint          i;
        IGRint          exprLen = 0,
                        exprCnt = 0;
        IGRchar         *exprList = NULL;
	IGRchar		nodeType[80];
	TGRid		treeID;

	if( !form ) goto wrapup;

	VDctxGetTree( &rootID, &treeID );
	VDctxGetNodeType( &treeID, nodeType );

	VDtvwReadFileData (	"expr_table",
				"config/drawing",
				nodeType,
				&exprList,
				&exprLen,
				&exprCnt );

	if( exprCnt < 1 || !exprList ) goto wrapup;

	FIfld_set_list_num_rows(form, VDTVW_T_EXPR, 0, exprCnt);

	for( i = 0; i < exprCnt; i++ ) {
		vdfrm$SetListText (	form   = form,
					gadget = VDTVW_T_EXPR,
					row    = i,
					txt   = &exprList[i*exprLen]);
	}

        retFlag = 1;
wrapup:
        _FREE( exprList );
        return retFlag;

}


/********************************************
 *
 * Manage the save_set stuff ~pn*
 *
 ********************************************/
/*
 * (zzz) 
 * this could be where the allocation gets messed up
 * it needs checked as to the name list stuff
 */
IGRint VDtvwFillSetsFromFile(Form form)
{
  VDASSERT_FN("VDtvwFillSetsFromFile");
  IGRint retFlag = 0;
  IGRint   nameListCnt,i;
  GRname  *nameList;
  
  /* say hi */
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

  /* args */
  VDASSERTW(form);
  
  /* init */
  nameListCnt = 0;
  nameList = NULL;
  FIfld_set_list_num_rows(form,VDTVW_T_SETS,0,0);
  if(traceFlag) printf("setID[%d][%d]\n",setID.osnum,setID.objid);
  /* get the setsList */
  vd$TreeSet_getList(	treeSetID = &setID,
			nameList  = &nameList,
			count     = &nameListCnt);
  if(nameListCnt < 1) {
    if(traceFlag) printf("went wrapup no nameListCnt\n");
    goto wrapup;
  }
  
  
  /* cycle through and load up the associated list */
  for(i = 0;i < nameListCnt;i++) {
    if(traceFlag) printf("nameList[%d] [%s]\n",i,nameList[i]);
    vdfrm$SetListText( form   = form,
                       gadget = VDTVW_T_SETS,
                       row    = i,
                       txt    = nameList[i]);
  }

  /* make it pretty but don't add the first item to the box */
  VDtvwFormMakeTextItemsUniqueAUp(form,VDTVW_T_SETS,0,0);
  
  retFlag = 1;
wrapup:
  if(nameListCnt > 0) _FREE( nameList );
  /* say bye */
  if (traceFlag) printf("<<< %s %s(%d)\n",ffn(),fn,retFlag);
  return retFlag;
}

/********************************************
 *
 * Save a SaveSet ~pn*
 *
 ********************************************/
/*
 * This uses the hListIDs but does not 
 * allocate or free by design
 * merely uses the data
 */
IGRint VDtvwSaveSaveSet(Form form)
{
  VDASSERT_FN("VDtvwSaveSaveSet");
  IGRint retFlag = 0;
  IGRchar buf[128],saveSetName[128],rowText[128],*p;
  IGRint  row,rows,success = 0;;
  
  /* say hi */
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

  /* buf set */
  strcpy(buf,"");

  /* get the saveSet name for use */
  FIg_get_text(form,VDTVW_T_SETS,saveSetName);

  /* validate the save set name */
  p = saveSetName;
  for(row = 0;row < strlen(saveSetName);row++) {
    if(!(*p == ' ')) {
      success = 1;
      break;
    }
      p++;
  }
  if(success == 0) {
    strcpy(buf,"Invalid SaveSet name");
    goto wrapup;
  }
  success = 0;
  success = vd$TreeSet_create(	setName   = saveSetName,
				treeSetID = &setID,
				rootID    = &rootID,
				objList   = hListIDs,
				count     = hListIDsCnt,
				check     = TRUE);
  if(success == 0) sprintf(buf,"Not Saved [%s] SaveSet",saveSetName);
  if(success == 1) sprintf(buf,"Saved [%s] SaveSet",saveSetName);

  if(success == 0) goto wrapup;

  if(traceFlag) {
    printf("\nSaveSet Save [%s]\n",saveSetName);
    printf("setID[%d][%d]  rootID[%d][%d]\n",
	   setID.osnum,setID.objid,rootID.osnum,rootID.objid);
    printf("Saved IDs [%d]\n",hListIDsCnt);
  }
  
  
  
  /* update the text gadget */
  VDtvwFillSetsFromFile(form);
  FIg_set_text(form,VDTVW_T_SETS,saveSetName);

  retFlag = 1;
wrapup:

  FIg_set_text(form,10,buf);
  /* say bye */
  if (traceFlag) printf("<<< %s %s(%d)\n",ffn(),fn,retFlag);
  return retFlag;
}

/********************************************
 *
 * Load a SaveSet ~pn*
 *
 ********************************************/
IGRint VDtvwLoadSaveSet(Form form)
{
  VDASSERT_FN("VDtvwLoadSaveSet");
  IGRint retFlag = 0;
  IGRchar buf[128],saveSetName[128],rowText[128],*p;
  IGRint  row,rows,success = 0;
  TGRid   nodeID,*nodeList;
  IGRint  i,nodeListCnt,acceptOK = 0;
  
  /* reset the defaults */
  VDtvwSetDefaultFormSettings();

  /* grey out the accept button until some selection is made on the form */
  FIg_disable(form,FI_ACCEPT);
  VDtvwSetFormSettings(form);

  /* display the nodes and expand one level for initial view */
  VDtvwFormPlaceNodeTop(form,
			VDTVW_MCOL_TREE,
			&rootID);

  VDtvwAddSelections( form );

  /* check for hilites  on the form for the Accept control operations */
  VDtvwIsAcceptOK(form,&acceptOK);
  if(acceptOK == 1) FIg_enable(form,FI_ACCEPT);

  retFlag = 1;
wrapup:
  VDtvwRefreshTree(form);
  FIg_set_text(form,10,buf);
  if(nodeListCnt > 0) _FREE(nodeList);

  /* say bye */
  if (traceFlag) printf("<<< %s %s(%d)\n",ffn(),fn,retFlag);
  return retFlag;
}

/********************************************
 *
 * Delete a SaveSet ~pn
 *
 ********************************************/
IGRint VDtvwDeleteSaveSet(Form form)
{
  VDASSERT_FN("VDtvwDeleteSaveSet");
  IGRint retFlag = 0;
  IGRchar buf[128],saveSetName[128],rowText[128],*p;
  IGRint  row,rows,success = 0;
  
  /* say hi */
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

  /* buf set */
  strcpy(buf,"");

  /* get the saveSet name for use */
  FIg_get_text(form,VDTVW_T_SETS,saveSetName);
  
  /* if there is not a value make sure to say so */
  strcpy(buf,"No set to delete");
  p = saveSetName;
  for(row = 0;row < strlen(saveSetName);row++) {
    if(!(*p == ' ')) {
      sprintf(buf,"SaveSet [%s] Doesn't exist",saveSetName);
      success = 1;
      break;
    }
      p++;
  }
  if(success == 0) goto wrapup;
  success = 0;
  
  /* get the number of rows in the text gadget */
  VIfld_get_num_rows(form,VDTVW_T_SETS,&rows);

  /* loop though the associated list and see if the item is there to delete */
  for(row = 0;row < rows;row++) {
    vdfrm$GetListText( form   = form,
		       gadget = VDTVW_T_SETS,
		       row    = row,
		       txt    = rowText);
    if(!strcmp(saveSetName,rowText)) {
      sprintf(buf,"Deleted [%s] SaveSet",saveSetName);
      success = 1;
      break;
    }
  }
  if(success == 0) goto wrapup;
  
  /* delete it then */
  success = vd$TreeSet_delete (setName   = saveSetName,
			       treeSetID = &setID);
  if(success == 0) {
    sprintf(buf,"Not Deleted [%s] SaveSet",saveSetName);
  } else {
    FIg_set_text( form,VDTVW_T_SETS,"");
    VDtvwFillSetsFromFile(form);
  }
  
  
  retFlag = 1;
wrapup:
  FIg_set_text(form,10,buf);

  /* say bye */
  if (traceFlag) printf("<<< %s %s(%d)\n",ffn(),fn,retFlag);
  return retFlag;
}
/********************************************
 *
 * Get the status for AcceptStatus and hListIDsCnt
 * as a return value for the function ~pn
 *
 ********************************************/
IGRint VDtvwIsItemAccepted()
{
  VDASSERT_FN("VDtvwIsItemAccepted");
  IGRint retFlag = 0;
  
  /* say hi */
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
  if((AcceptStatus == 1) && (hListIDsCnt > 0)) {
    retFlag = 1;
  }
  
wrapup:
  /* say bye */
  if (traceFlag) printf("<<< %s %s(%d)\n",ffn(),fn,retFlag);
  return retFlag;
}

/********************************************
 *
 * Get the ItemList for use by others
 * this is isolated by copy from the form 
 * internal buffers
 * it is also protected from sending out any values
 * if the AcceptStatus == 0 ~pn*
 *
 ********************************************/
/*
 * This is intended to give access to the hListIDs by passing
 * the data to another allocated list
 * Does not free the itemList needs freed in calling routine
 */
IGRint VDtvwGetItemList(TGRid **itemList,IGRint *itemListCnt)
{
  VDASSERT_FN("VDtvw");
  IGRint retFlag = 0;
  IGRint i;
  
  /* say hi */
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
  
  /* bat cleanup first */
  if(*itemListCnt > 0) _FREE( *itemList );
  *itemListCnt = 0;
  
  if(AcceptStatus == 1) {
    for(i = 0;i < hListIDsCnt;i++) {
      VDtvwAddNodeToListUnique(&hListIDs[i],itemList,itemListCnt);
    }
  }
  
  retFlag = 1;
wrapup:
  /* say bye */
  if (traceFlag) printf("<<< %s %s(%d)\n",ffn(),fn,retFlag);
  return retFlag;
}
/********************************************
 *
 * Get the full Range selected 
 *
 ********************************************/
IGRint VDtvwGetRangeIDsList(TGRid **rangeIDs,IGRint *rangeIDsCnt)
{
  VDASSERT_FN("VDtvwGetRangeIDsList");
  IGRint retFlag = 0;
  TGRid     nodeID;
  TGRid    *cohortIDs;
  IGRint    cohortIDsCnt = 0;
  IGRint    fromRow = 0;
  IGRint    toRow   = 0;
  IGRint    row     = 0;
  IGRint    sts     = 0;
  IGRint    state,pos,selFlag;
  IGRchar   attr[128],exp[128],data[128];
  IGRint    modTog,stageTog,nameTog,attrTog,itemTog;

  /* say hi */
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

  /* clean up the input */
  if(*rangeIDsCnt > 0) _FREE(*rangeIDs);
  *rangeIDsCnt = 0;

  /* no form we cannot do any business */
  if(!VD_FP) goto wrapup;

  /* get the toggle settings off the form */
  VDtvwGetToggleState(VD_FP,&modTog,&stageTog,&nameTog,&attrTog,&itemTog);
  /* don't get a list unless we are going for a range list */
  if(itemTog == 0) {
    retFlag = 1;
    goto wrapup;
  }

  if(fromID.objid == NULL_OBJID)  goto wrapup;
  if (toID.objid == NULL_OBJID) goto wrapup;
  
  /* fetch the start and finish rows */
  VDtvwGetFromToRange(VD_FP,&fromRow,&toRow);
  
  /* get the cohorts list */
  sts = vdtvw$GetCohortList(nodeID      = fromID,
			    nodesOut    = &cohortIDs,
			    nodesOutCnt = &cohortIDsCnt);
  if(traceFlag) printf("cohortIDsCnt [%d]\n",cohortIDsCnt);
  if(cohortIDsCnt == 0) goto wrapup;
  /* loop through rows on the form and fetch the nodeID(s) */
  for(row = fromRow; row <= toRow;row++) {
    VDtvwFormGetTreeRowData(VD_FP,VDTVW_MCOL_TREE,row,attr,exp,data,&nodeID,&selFlag,&pos);
    if((nodeID.objid != NULL_OBJID) && (nodeID.osnum == fromID.osnum)) {
      if(vdtvw$IsNodeInList(nodeID  = &nodeID,
			      List    = cohortIDs,
			      ListCnt = cohortIDsCnt)) {
	VDtvwAddNodeToListUnique(&nodeID,rangeIDs,rangeIDsCnt);
      }
    }
  }
  if(*rangeIDsCnt == 0) goto wrapup;
  
  retFlag = 1;
wrapup:

  if(cohortIDsCnt > 0) _FREE(cohortIDs);
  /* say bye */
  if (traceFlag) printf("<<< %s %s(%d)\n",ffn(),fn,retFlag);
  return retFlag;
}

/*********************************************
 *
 * Pick up the nodes matching the Stage 
 * definition for use in making a list set
 *
 *********************************************/

IGRint VDtvwGetStageIDsList(TGRid **stageIDs,IGRint *stageIDsCnt)
{
  VDASSERT_FN("VDtvwGetStageIDsList");
  IGRint  retFlag = 0;
  IGRint  modTog,stageTog,nameTog,attrTog,itemTog;
  IGRchar sets[128],stage[128],name[128],afrom[128],ato[128],attrName[128],attrValue[128];
  TGRid  *defIDs,rootID;
  IGRint  defIDsCnt = 0;
  IGRint  child = 1;
  IGRchar hilite[128],parent[128],bln[128];

  /* say hi */
  if (traceFlag) printf("\n\n\n\n>>> %s %s doinit\n",ffn(),fn);

  /* some clean up */
  if(*stageIDsCnt > 0) _FREE( *stageIDs);
  *stageIDsCnt = 0;

  /* checks */
  if(!VD_FP) goto wrapup;

 /* fetch the rootID */
 VDtvwFormGetTreeID(VD_FP,VDTVW_MCOL_TREE,&rootID);
 if(rootID.objid == NULL_OBJID) goto wrapup;

 /* get the toggle settings off the form */
 VDtvwGetToggleState(VD_FP,&modTog,&stageTog,&nameTog,&attrTog,&itemTog);

 /* get the text box data from the form */
  VDtvwGetSelectionText(VD_FP,sets,stage,name,afrom,ato,attrName,attrValue);

  /* only for Stage selections */
 if(itemTog == 1) goto wrapup;

 /* start fetching the definition lists */
 if(nameTog == 1) {
   if(traceFlag) printf("a fetching stage/name list child[%d] rootID [%d][%d]\n",
			child,rootID.osnum,rootID.objid);
   if(traceFlag) printf("stage [%s] name [%s] \n",stage,name);
  
    vdfile$GetNodeList(nodeID      = &rootID,
		       type        = stage, 
		       name        = name,
		       child       = &child,
		       nodeList    = stageIDs,
		       nodeListCnt = stageIDsCnt);

  } else if (stageTog == 1) {
   if(traceFlag) printf("b fetching stage list child[%d] rootID [%d][%d]\n",
			child,rootID.osnum,rootID.objid);
   if(traceFlag) printf("stage [%s]\n",stage);
    vdfile$GetNodeList(nodeID      = &rootID,
		       type        = stage, 
		       child       = &child,
		       nodeList    = stageIDs,
		       nodeListCnt = stageIDsCnt);
  }

 //if(traceFlag) print("stageIDsCnt = %d\n",stageIDsCnt);
 //if(traceFlag) printf("Returned from getting a list \n");
 if(traceFlag) printf("stageIDsCnt = %d\n",*stageIDsCnt);
  if(*stageIDsCnt < 1) goto wrapup;
  retFlag = 1;

wrapup:

  /* say bye */
  if (traceFlag) printf("<<< %s %s(%d)\n",ffn(),fn,retFlag);
  return retFlag;
}

/*******************************************
 *
 * get the definition IDS
 *
 *******************************************/
IGRint VDtvwGetDefIDsList(TGRid **defIDs,IGRint *defIDsCnt)
{
  VDASSERT_FN("VDtvwGetDefIDsList");
  IGRint  retFlag = 0;
  IGRint  modTog,stageTog,nameTog,attrTog,itemTog;
  IGRint  i;

  /* say hi */
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

  /* some cleanup init */
  if(*defIDsCnt > 0) _FREE( *defIDs);
  *defIDsCnt = 0;

  /* get the toggle settings off the form */
  VDtvwGetToggleState(VD_FP,&modTog,&stageTog,&nameTog,&attrTog,&itemTog);

  /* fetch the definition stuff */
  if(itemTog & 1) {

    /* range fetch the definition list*/
    if(traceFlag) printf("rangeIDs list\n");
    VDtvwGetRangeIDsList(defIDs,defIDsCnt);

  } else {
    /* index fetch the definition list*/
    if(traceFlag) printf("stageIDs list\n");
    VDtvwGetStageIDsList(defIDs,defIDsCnt);
  }

  retFlag = 1;
wrapup:

  /* say bye */
  if (traceFlag) printf("<<< %s %s(%d)\n",ffn(),fn,retFlag);
  return retFlag;
}


#if 0
/********************************************
 *
 * 
 *
 ********************************************/
IGRint VDtvw(TGRid *nodeID)
{
  VDASSERT_FN("VDtvw");
  IGRint retFlag = 0;
  traceFlag = 1;
  
  /* say hi */
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
  

  retFlag = 1;
wrapup:
  /* say bye */
  if (traceFlag) printf("<<< %s %s(%d)\n",ffn(),fn,retFlag);
  return retFlag;
}
#endif	   
end implementation VDct1Base;

