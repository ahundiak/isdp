/* $Id: VDCTBSForm.I,v 1.29.4.1 2003/05/12 19:23:39 ylong Exp $ */

/* --------------------------------------------------------------------
 * I/VDS
 *VDCTBSForm.I
 * File:        vds/vdtbl/cmd / VDVCTBSForm.I
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
 * 01/10/01  pnoel  Creation
 * 11/17/10  ah     SOL10 Frozen stuff
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
/* ---- SPEEDUP -------------------------------------------------------- */

#include "VDCmdDef.h"
#include "FI.h"
#include "FEI.h"
#include "VDassert.h"
#include "VDctx.h"
#include "VDct1Attrs.h"
#include "VDobj.h"
#include "vdtvwtools.h"


VDASSERT_FFN("vds/vdtbl/cmd/VDCTBSForm.I");

IGRstat VDctbsFindNodeIDRow(char *form_ptr,TGRid *nodeID,IGRint *row);
IGRstat VDctbsFindRowNodeID(char *form_ptr,IGRint *row,TGRid *nodeID);


static IGRint  intcmp( int* e1, int* e2 );
extern IGRlong VDtblCmdSetNameID(TGRid  nodeID );
extern IGRlong VDtblCmdSetSelectList( TGRid  **nodeID,IGRint *nodeCnt);
extern IGRlong VDtblCmdGetNameID( TGRid  *nodeID );
extern IGRlong VDtblCmdGetSelectList( TGRid  **nodeID,IGRint *nodeCnt);
extern IGRlong VDtblNodeListPrintTest();
extern IGRlong VDtblCmdReportNameIDParent(char *form_ptr, TGRid  *nodeID );
extern IGRint  VDtvwAddNodeToListUnique(TGRid  *addNode,
					TGRid **nodeList,
					IGRint *nodeListCnt);

/****************************************************************
 *
 * Helper Functions for handling the Create Table By Stage Form
 * Place Table By Stage also uses this form so it may be wise
 * to use these functions for their intended locations carefully
 * Designed to modularize the logic control and make the operations
 * easier fix and to control
 *
 ****************************************************************/
/****************************************************************
 *
 * Get the treeID
 *
 ****************************************************************/
IGRstat VDctbsGetTreeID(char *form_ptr,TGRid *treeID)
{
  VDASSERT_FN("VDctbsGetTreeID");
  IGRint  retFlag = 0;
  TGRid   setID;
  IGRint  row,pos;
  IGRchar setType[128];
  IGRint  nodeClass;
  

  // say hi
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn); 
  }

   // args check
  VDASSERTW(treeID);

  FIfld_get_active_row( form_ptr,
                        VD_STBL_TREESET_FLD,
                        &row,
                        &pos );
  if( row < 0 ) goto wrapup;

  setID.objid = NULL_OBJID;
  vdfrm$GetText( form    = form_ptr,
                 gadget  = VD_STBL_TREESET_FLD,
                 row     = row,
                 col     = 3,
                 objID   = &setID );
   
  if( setID.objid == NULL_OBJID ) goto wrapup;
  // check if the setID is an acceptable type to display
  treeID->objid = NULL_OBJID;
  vdtr$GetSetTree(setID  = &setID,
                  treeID = treeID );

  if( treeID->objid == NULL_OBJID ) goto wrapup;

  retFlag = 1;
 wrapup:
  // say bye
  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}
/****************************************************************
 *
 * Filter treeID for allowed treeID's  for CTBS command
 *
 ****************************************************************/
IGRstat VDctbsFilterTreeID(TGRid *treeID)
{
  VDASSERT_FN("VDctbsFilterTreeID");
  IGRint  retFlag = 0;
  TGRid   setID;
  IGRint  row,pos;
  IGRchar setType[128];
  IGRint  nodeClass;

  traceFlag = 0;
  // say hi
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn); 
  }
  // go home if treeID is NULL
  if( treeID->objid == NULL_OBJID ) goto wrapup;

   vdtr$GetSetType(nodeID = treeID,
                  setType = setType);
  // get the nodeClass
  vd$trget_class(nodeID = treeID,
                 class  = &nodeClass);

  // do the VDAT NodeClass
  if(nodeClass == VDTR_CLASS_VDAT) {
    retFlag = 1;
    goto wrapup;
  }
  // limits for VDct1 nodeClass
  if((strcmp(setType,VDCT1_TREE_TYPE_OUTFIT_TREE)) &&
    (strcmp(setType,VDCT1_TREE_TYPE_PAL_ASSYS)) && 
    (strcmp(setType,VDCT1_TREE_TYPE_CABLE_TREE)) && 
    (strcmp(setType,VDCT1_TREE_TYPE_WWAY_TREE)) && 
    (strcmp(setType,VDCT1_TREE_TYPE_HVAC_TREE)) && 
    (strcmp(setType,VDCT1_TREE_TYPE_PIPE_TREE))) treeID->objid = NULL_OBJID;

  if( treeID->objid == NULL_OBJID ) goto wrapup;
 
  retFlag = 1;
 wrapup:
  // say bye
  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}

/****************************************************************
 *
 * Filter Stages items
 *
 ****************************************************************/
IGRstat VDctbsFilterStages(TGRid *nodeID,IGRchar *stage)
{
  VDASSERT_FN("VDctbsFilterStages");
  IGRint     retFlag = 0;
  TGRid      setID;
  IGRint     row,pos;
  IGRchar    setType[128];
  IGRint     nodeClass;
  TGRobj_env modelOE;

  // say hi
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn); 
  }

  // args check
  VDASSERTW(nodeID);
  VDASSERTW(stage);


  if(!strcmp(stage,"")) goto wrapup;
    if (traceFlag) {
    printf(">>> %s %s %s\n",ffn(),fn,stage); 
  }

   vdtr$GetSetType(nodeID = nodeID,
                  setType = setType);

  // get the nodeClass
  vd$trget_class(nodeID = nodeID,
                 class  = &nodeClass);

  // do the VDat NodeClass
  if(nodeClass == VDTR_CLASS_VDAT) {

    // PM nodes are prohibited if they are leaf
    if(!strcmp(stage,"PM")) {
      vd$trget_modelObject(nodeID  = nodeID,
                             objOE = &modelOE);
      if(modelOE.obj_id.objid != NULL_OBJID) goto wrapup;
    }
    retFlag = 1;
    goto wrapup;
  }
  // do the VDct1 NodeClass
  if(nodeClass == VDTR_CLASS_VDCT1) {
    retFlag = 1;
    goto wrapup;
  }

 wrapup:
  // say bye
  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}

/****************************************************************
 *
 * Disable Gadgets 26,28,30,36 (Tree Selections)
 * Used to turn off user access to these gadgets until data is 
 * made available
 *
 ****************************************************************/
IGRstat VDctbsDisableTableGadgets(char *form_ptr)
{
  VDASSERT_FN("VDctbsDisableTableGadgets");
  IGRint retFlag = 0;


  traceFlag = 0;
  // say hi
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn); 
  }  

  // args check
  VDASSERTW(form_ptr != '\0');

  FIg_disable( form_ptr, VD_STBL_STAGE_FLD );    // 28  Stages
  FIg_disable( form_ptr, VD_STBL_NAME_FLD );     // 30  Names
  FIg_disable( form_ptr, VD_STBL_CR_TYPE_FLD );  // 26  Table Type
  // FIg_disable( form_ptr, VD_STBL_INDEXTYP_FLD ); // 36  Index Selection

  retFlag = 1;
  
wrapup:
  // say bye
  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}

/****************************************************************
 *
 * Enable Gadgets 26,28,30,36 (Tree Selections)
 * Used to turn ond user access to these gadgets when data is 
 * made available
 *
 ****************************************************************/
IGRstat VDctbsEnableTableGadgets(char *form_ptr)
{
  VDASSERT_FN("VDctbsEnableTableGadgets");
  IGRint retFlag = 0;

  // say hi
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn); 
  }  

  // args check
  VDASSERTW(form_ptr != '\0');

  FIg_enable( form_ptr, VD_STBL_STAGE_FLD );    // 28  Stages
  FIg_enable( form_ptr, VD_STBL_NAME_FLD );     // 30  Names
  FIg_enable( form_ptr, VD_STBL_CR_TYPE_FLD );  // 26  Table Type
 
  retFlag = 1;
  
wrapup:
  // say bye
  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}

/****************************************************************
 *
 * Empty the Table Gadgets
 *
 ****************************************************************/
IGRstat VDctbsEmptyTableGadgets(char *form_ptr)
{
  VDASSERT_FN("VDctbsEmptyTableGadgets");
  IGRint retFlag = 0;

  traceFlag = 0;
  // say hi
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn); 
  }  

  // args check
  VDASSERTW(form_ptr != '\0');

  // reset the gadgets
  FIg_reset( form_ptr, VD_STBL_CR_TYPE_FLD );  // 26  Table Type
  FIg_reset( form_ptr, VD_STBL_STAGE_FLD );    // 28  Stages
  FIg_reset( form_ptr, VD_STBL_NAME_FLD );     // 30  Names

  retFlag = 1;
wrapup:
  // say bye
  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}

/****************************************************************
 *
 * Erase the Table Gadgets
 *
 ****************************************************************/
IGRstat VDctbsEraseTableGadgets(char *form_ptr)
{
  VDASSERT_FN("VDctbsEraseTableGadgets");
  IGRint retFlag = 0;

  traceFlag = 0;
  // say hi
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn); 
  }  

  // args check
  VDASSERTW(form_ptr != '\0');

  // clear gadgets
  FIg_erase( form_ptr, VD_STBL_CR_TYPE_FLD );  // 26  Table Type
  FIg_erase( form_ptr, VD_STBL_STAGE_FLD );    // 28  Stages
  FIg_erase( form_ptr, VD_STBL_NAME_FLD );     // 30  Names  
wrapup:
  // say bye
  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}

/****************************************************************
 *
 * Fill up the Table options for Gadget #26 VD_STBL_CR_TYPE_FLD
 * Used to determine the options for the node selection 
 *
 ****************************************************************/
IGRstat VDctbsFillTableSelOptions(char *form_ptr)
{
  VDASSERT_FN("VDctbsFillTableSelOptions");
  IGRint         retFlag = 0;
  IGRint         nodeClass;
  TGRid          treeID;
  TVDct1JD       treeJD;
  TVDctxBaseInfo  baseInfo;

  // say hi
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn); 
  }  

  // args check
  VDASSERTW(form_ptr != '\0');

  // clear out the form
  VDctbsEmptyTableGadgets(form_ptr);
  VDctbsEnableTableGadgets(form_ptr);
  FIg_reset(form_ptr,VD_STBL_CR_TYPE_FLD);
  
  // get the treeID
  VDctbsGetTreeID(form_ptr,&treeID);
  if(treeID.objid == NULL_OBJID) goto wrapup;
  
  // get the nodeClass
  vd$trget_class(nodeID = &treeID,
                 class  = &nodeClass);

  // do the VDct1 NodeClass
  if(nodeClass == VDTR_CLASS_VDCT1) {
    VDctxGetBaseInfo(&treeID,&baseInfo);
    
    if(!strcmp(baseInfo.setType,VDCT1_TREE_TYPE_PLOT_TREE)) goto wrapup;
    if(!strcmp(baseInfo.setType,VDCT1_TREE_TYPE_STD_PARTS)) goto wrapup;    
    if(!strcmp(baseInfo.setType,VDCT1_TREE_TYPE_STD_ASSYS)) goto wrapup;    
    //if(!strcmp(baseInfo.nodeType,)) goto wrapup;    
  }
  
    // set the list
    vdfrm$SetListText( form = form_ptr,
		       gadget = VD_STBL_CR_TYPE_FLD,
		       row = 0,txt = "Part List");
    vdfrm$SetListText( form = form_ptr,
		       gadget = VD_STBL_CR_TYPE_FLD,
		       row = 1,
		       txt = "Index");
    vdfrm$SetListText( form = form_ptr,
		       gadget = VD_STBL_CR_TYPE_FLD,
		       row = 2,
		       txt = "Model_obj");
    vdfrm$SetListText( form = form_ptr,
		       gadget = VD_STBL_CR_TYPE_FLD,
		       row = 3,
		       txt = "Item");
    
    // set the first selection
    FIg_set_text( form_ptr, VD_STBL_CR_TYPE_FLD, "Part List" );
    FIg_erase(form_ptr,VD_TBL_SELECT_ITEMS);    // 61
    retFlag = 1;
 
wrapup:
  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  }

  
  return retFlag;
}

/****************************************************************
 *
 * Fill Stages List
 *
 ****************************************************************/
IGRstat VDctbsFillStagesList(char *form_ptr)
{
  VDASSERT_FN("VDctbsFillStagesList");
  IGRint retFlag = 0;
  TGRid  treeID;
  TGRid   *nodeIDs;
  IGRint  i,j,cnt,listCnt,nodeTypeCnt,selectionType,Selflag,nodeClass;
  IGRchar nodeTypeList[128][128],nodeType[128];
  TGRobj_env modelOE;
  
  // say hi
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn); 
  }
  UI_status( "Filling Stages List" );
  // args check
  VDASSERTW(form_ptr != '\0');

  /* init */
  nodeIDs = NULL;

  // first things first reset the form
  FIg_reset( form_ptr, VD_STBL_STAGE_FLD );    // 28  Stages
  Selflag = FALSE;

  // get the treeID
  VDctbsGetTreeID(form_ptr,&treeID);
  VDctbsFilterTreeID( &treeID );
  if(traceFlag) printf("Tree ID data [%d] [%d]\n",treeID.osnum,treeID.objid);
  if(treeID.objid == NULL_OBJID) {
    VIg_set_text(form_ptr,10,"Tree does not place tables");
    goto wrapup;
  }
  
  

  // get the nodes below the treeID
  cnt = 0;
  selectionType = VDTR_FIND_ALL;
  vd$trget_nodes(nodeID       = &treeID,
                 lookupType   = selectionType,
		 frozen	      = 1,
                 outID        = &nodeIDs,
                 cnt          = &cnt);
  if(cnt < 1) {
    /* malloc the and set cnt to 1  and nodeIDs[0] = treeID*/
    cnt = 1;
    nodeIDs = _MALLOC( (cnt) , TGRid );
    nodeIDs[0] = treeID;
    VIg_set_text(form_ptr,10,"Tree has no assemblies");
  }
  else {
   VIg_set_text(form_ptr,10,"");
  }
  
  
  
  // loop through and make a list of stages
  // set up the first ID
  // get the nodeClass
  vd$trget_class(nodeID = &treeID,
                 class  = &nodeClass);

  // do the VDct1 NodeClass
  // if(nodeClass == VDTR_CLASS_VDCT1) {
    
    vdtr$GetNodeType(nodeID   = &treeID,
		     nodeType = nodeType);
    // }
    //else
    //{
    //  vdtr$GetNodeType(nodeID   = &nodeIDs[0],
    //	     nodeType = nodeType);
    //  }
  
  if( strlen(nodeType) )
  {
    strcpy( nodeTypeList[0], nodeType );
    nodeTypeCnt = 1;
  } 
  
  // loop through the IDs and fetch the names matching the text
  for(i = 0;i < cnt;i++) {
    nodeType[0] = '\0';

    vdtr$GetNodeType(nodeID   = &nodeIDs[i],
		     nodeType = nodeType);
    for( j = 0 ; j < nodeTypeCnt ; j++ )
    {
      if( !(strcmp(nodeType, nodeTypeList[j])) ) break;
    }
    if( j == nodeTypeCnt )
    {
      if(VDctbsFilterStages(&nodeIDs[i],nodeType))
      {
        strcpy( nodeTypeList[j], nodeType );
        nodeTypeCnt++;
      }
    }
  }
  // load up the gadget row count
  FIfld_set_num_rows( form_ptr, VD_STBL_STAGE_FLD, nodeTypeCnt ); // #28

  // set the text field to the first one
  FIg_set_text( form_ptr, VD_STBL_STAGE_FLD, nodeTypeList[0] );

  for(i = 0;i < nodeTypeCnt;i++) {
  // load up the rows
  FIfld_set_list_text( form_ptr,
                       VD_STBL_STAGE_FLD,  // #28
                       i,
                       0,
                       (unsigned char *)(nodeTypeList[i]),
                       Selflag );
  }

  retFlag = 1;
wrapup:
  
    if(nodeIDs) _FREE(nodeIDs);
  UI_status( "Done" );
  // say bye
  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}


/****************************************************************
 *
 * Fill Names List 
 *
 ****************************************************************/
IGRstat VDctbsFillNamesList(char *form_ptr)
{
  VDASSERT_FN("VDctbsFillNamesList");
  IGRint  retFlag = 0;
  TGRid   treeID,nodeID,setID,testID;
  TGRid   *nodeIDs,*nameIDs;
  IGRchar nodeType[128],nodeName[128],stagetypeBuf[128];
  IGRint  i,j,cnt,nodeNameCnt,selectionType,Selflag,nameIDsCnt;
  IGRchar nodeNameList[128][128];
  typedef char	StringType[80];
  StringType		*strList = NULL;
  IGRint  *intList = NULL;
  IGRint  row,pos,activeRow,nodeIDsCnt,nodeClass,isTree = 0;
  TVDctxBaseInfo baseInfo;
  
  // say hi
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn); 
  }
  UI_status( "Filling Names List" );
  /* inits */
  nodeIDs = NULL;
  intList = NULL;
  strList = NULL;
  activeRow = -1;
  

  /* 
   * Some housekeeping chores
   * clean up any allocation of memory to the static list of nameIDs
   */

  /* 
   * Why get nameIDs and do not use it at all ????? Commented by ylong
   *
  VDtblCmdGetSelectList( &nameIDs,&nameIDsCnt );
  nameIDsCnt = 0;
  nameIDs = _MALLOC( 1, struct GRid );
  */

  /* Added by ylong to replace above lines */
  VDtblCmdGetSelectList( &nameIDs,&nameIDsCnt );
  _FREE(nameIDs);
  nameIDsCnt = 0;
  nameIDs = _MALLOC( 1, struct GRid );

  // get the Stage listed in the gadget
  // needs to clean out the gadget better! set numrows = 0 etc
  FIg_get_text( form_ptr, VD_STBL_STAGE_FLD, stagetypeBuf );
  if(!strcmp(stagetypeBuf,"")) goto wrapup;
  // if there is a listed stage in the gadget
  if( strlen(stagetypeBuf) )
  {
    // reset the name field
    FIg_reset( form_ptr, VD_STBL_NAME_FLD );
    // get the active setID row
    FIfld_get_active_row( form_ptr,
                          VD_STBL_TREESET_FLD,  // #31
                          &row,
                          &pos );
    if( row < 0 ) goto wrapup;
    activeRow = row;
    if(traceFlag) printf("activeRow [%d]\n",activeRow);
    
    setID.objid = NULL_OBJID;
    // get the actual setID
    vdfrm$GetText( form    = form_ptr,
                   gadget  = VD_STBL_TREESET_FLD, // #31
                   row     = row,
                   col     = 3,
                   objID   = &setID );
    if( setID.objid == NULL_OBJID ) goto wrapup;
    
    treeID.objid = NULL_OBJID;
    // get the treeID from the setID
    vdtr$GetSetTree(setID  = &setID,
                    treeID = &treeID );
    
    if( treeID.objid == NULL_OBJID ) goto wrapup;
    
    {
      cnt = 0;
      // get all the nodes for this treeID
      selectionType = VDTR_FIND_ALL;
      vd$trget_nodes(nodeID       = &treeID,
                     lookupType   = selectionType,
		     frozen       = 1,
                     outID        = &nodeIDs,
                     cnt          = &cnt);

      row = 0;
      nodeType[0] = '\0';
      nodeName[0] = '\0';
      // get the treeID nodeType
      vdtr$GetNodeType(nodeID   = &treeID,
		       nodeType = nodeType);

      // if the stagetypeBuf matches is is only the treeID nodeName to load into the gadget
      if( !strcmp( stagetypeBuf, nodeType) ) {
	vdtr$GetNodeName(nodeID   = &treeID,
			 nodeName = nodeName);
	// add the new name to the field
	FIg_set_text( form_ptr, VD_STBL_NAME_FLD, nodeName ); // #30
        nameIDs[nameIDsCnt].osnum = treeID.osnum;
        nameIDs[nameIDsCnt].objid = treeID.objid;
        nameIDsCnt++;
	isTree = 1;
      }
      // is is not the treeID
      else {
	// loop through the nodes
	for( i = 0; i < cnt; i++ )
	{
	  nodeType[0] = '\0';
	  nodeName[0] = '\0';
	  // get the node type
	  vdtr$GetNodeType(nodeID   = &nodeIDs[i],
			   nodeType = nodeType);
	  
	  if( !strcmp( stagetypeBuf, nodeType) )
	  {
	    // if the type is ok get the name
	    vdtr$GetNodeName(nodeID   = &nodeIDs[i],
			     nodeName = nodeName);
	    // add the new name to the field
	    FIg_set_text( form_ptr, VD_STBL_NAME_FLD, nodeName ); // #30
	    break;
	  }
	}
      }
      
      strList = _CALLOC(cnt + 1, StringType);
      intList = _CALLOC(cnt + 1, IGRint);
      if(isTree) {
	vdtr$GetNodeName(nodeID   = &treeID,
			 nodeName = nodeName);
	strcpy(strList[row], nodeName);
        if(isdigit(nodeName[0])) {
          intList[row] = atoi(nodeName);
        }
	row++;
      }
      else {
	for( i = 0; i < cnt; i++ )
	{
	  nodeType[0] = '\0';
	  nodeName[0] = '\0';
	  vdtr$GetNodeType(nodeID   = &nodeIDs[i],
			   nodeType = nodeType);
	  
	  if( !strcmp( stagetypeBuf, nodeType) )
	  {
	    vdtr$GetNodeName(nodeID   = &nodeIDs[i],
			     nodeName = nodeName);
	    
	    strcpy(strList[row], nodeName);
	    if(isdigit(nodeName[0]))  {
	      intList[row] = atoi(nodeName);
	    }
            /* add the ID to the list */
            
            nameIDs[nameIDsCnt].objid = nodeIDs[i].objid;
            nameIDs[nameIDsCnt].osnum = nodeIDs[i].osnum;
            nameIDsCnt++;
            
            /* allocate some more memory */
            nameIDs = _REALLOC(nameIDs,nameIDsCnt + 1, TGRid);
	    row++;
	  }
	}
      }

      // get the nodeClass
      vd$trget_class(nodeID = &treeID,
		     class  = &nodeClass);  
      // do the VDAT stuff the old way without change (sorted numbers etc)
      if(nodeClass == VDTR_CLASS_VDAT) {
	if(!isdigit(strList[0][0])) {
	  qsort((char*)strList,row,sizeof(StringType),(int(*)())strcmp);
	  
	  for(i = 0; i < row; i++) {
	    vdfrm$SetListText( form   = form_ptr,
			       gadget = VD_STBL_NAME_FLD,
			       row    = i,
			       txt    = strList[i]);
	  }
	}
	else {
	  qsort((char*)intList,row,sizeof(int),(int(*)())intcmp);
	  for(i = 0; i < row; i++) {
	    sprintf(nodeName, "%d", intList[i]);
	    vdfrm$SetListText( form   = form_ptr,
			       gadget = VD_STBL_NAME_FLD,
			       row    = i,
			       txt    = nodeName);
	  }
	}
      }
      // do the VDct1 stuff the new way 
      if(nodeClass == VDTR_CLASS_VDCT1) {
	for(i = 0; i < row; i++) {
	  vdfrm$SetListText( form   = form_ptr,
			     gadget = VD_STBL_NAME_FLD,
			     row    = i,
			     txt    = strList[i]);
	}
      }
      /* end location to fix */    
    }
  }
  
  retFlag = 1;

wrapup:
 if(nodeIDs) _FREE( nodeIDs );
  if(strList) _FREE( strList );
  if(intList) _FREE( intList );
  if(row) {

    /* 
     * set this to the first node in the nodeIDs list 
     */
    vdtr$GetNodeName(nodeID = &nameIDs[0],nodeName = nodeName);
    FIg_set_text( form_ptr, VD_STBL_NAME_FLD, nodeName); 

  }

  /* bat a little cleanup in presentation of the associated list */
   vdtvw$FormMakeTextItemsAUp(form    = form_ptr,
			      gadget  = VD_STBL_NAME_FLD,
			      flag    = 0,
			      addItem = 0);
   
  if(nameIDsCnt == 0) nameIDs[0].objid = NULL_OBJID;
  VDtblCmdSetNameID(nameIDs[0]);
  VDtblCmdReportNameIDParent(form_ptr,&nameIDs[0]);
  VDtblCmdSetSelectList( &nameIDs,&nameIDsCnt);

 
  UI_status( "Done" );
  
  // say bye
  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}

/****************************************************************
 *
 * Validate the name selection on the Create Table By Stage form
 * If the name is not in the list return the name back to that 
 * which is at the top of the list (SELECT_NODE)
 *
 ****************************************************************/

IGRstat VDctbsValidateSelName( IGRchar *form_ptr )
{
  
  VDASSERT_FN("VDctbsValidateSelName");
  IGRint retFlag = 0;
  IGRint nameOK = 0;
  IGRint i,rows,selFlag,row,nodeListCnt,pos,sFlag;
  IGRchar nameSelection[128],listName[128],testSelect[128],buf[128];
  TGRid   *nodeList,nodeID,selNodeID;

  
  
  // say hi
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn); 
  }  
  UI_status("Validating Name Entry");
 
  // args check
  VDASSERTW(form_ptr != '\0');

  /* checking to see if the value in the text box is a selection */
  FIg_get_text(form_ptr,VD_STBL_NAME_FLD,nameSelection);

  /* get the number of list rows */
  row = 0;
  selFlag = 0;
  rows = 0;
  /* check the list to see if it is selected */
  FIfld_get_list_num_rows(form_ptr,VD_STBL_NAME_FLD,0,&rows);

  /* this is always an invalid input case */
  if(rows < 1) {
    FIg_set_text(form_ptr,VD_STBL_NAME_FLD,"");
    selNodeID.objid = NULL_OBJID;
    VDtblCmdSetNameID(selNodeID);
    goto wrapup;
  }
  
  /* check to see if the item is actually from the list not user input */
  for(i = 0;i < rows;i++) {
    FIfld_get_list_text(form_ptr,VD_STBL_NAME_FLD,i,0,128,(unsigned char *)buf,&selFlag);
    if(selFlag == 1) {
      if(traceFlag) printf("\n\nTHE SELECTED ROW WAS [%d]\n\n",i);
      row = i;
      break;
    } 
  }

  if(traceFlag) printf("buf[%s] row[%d] Selflag[%d] rows[%d]\n",buf,row,selFlag,rows);
  
  if(selFlag == 0) {
    /* this is from a user input needs checked from the list */
    for(i = 0;i < rows;i++) {
      FIfld_get_list_text(form_ptr,VD_STBL_NAME_FLD,i,0,128,(unsigned char *)buf,&sFlag);
      if(!strcmp(buf,nameSelection)) {
	row = i;
	break;
      }
    }
  }

  /* fetch the text from the row (this can default to row[0]) */
  FIfld_get_list_text(form_ptr,VD_STBL_NAME_FLD,row,0,128,(unsigned char *)buf,&selFlag);
  /* set the row text */
  FIg_set_text(form_ptr,VD_STBL_NAME_FLD,buf);

  /* fetch the selNodeID to match to the row */
  VDctbsFindRowNodeID(form_ptr,&row,&selNodeID);
  if(traceFlag) printf("row[%d] selNodeID[%d][%d]\n",row,selNodeID.osnum,selNodeID.objid);
  VDtblCmdSetNameID(selNodeID);
  VDtblCmdReportNameIDParent(form_ptr,&selNodeID);
  retFlag = 1;
wrapup:
  UI_status("Done");

  // say bye
  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}

/****************************************************************
 *
 * Fill the Index Type List
 *
 ****************************************************************/
IGRstat VDctbsFillIndexTypeList(char *form_ptr)
{
  VDASSERT_FN("VDctbsFillIndexTypeList");
  IGRint  retFlag = 0;
  TGRid   treeID,nodeID,selNodeID;
  TGRid   *nodeIDs = NULL;
  IGRchar selType[128],nodeType[128],nodeName[128];
  IGRint  i,j,cnt,nodeTypeCnt,selectionType,Selflag,sts,gotComm,rows;
  IGRchar nodeTypeList[128][128],*ptr;
  IGRchar bufT[128],bufN[128],buf[128];
  TGRobj_env modelOE;  
  VDioBufDat info;
  
  
  
  // say hi
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn); 
    /* include this line only for testing of the nodeList  in VDctbsFillNamesList */
    //VDtblNodeListPrintTest();
  }
  UI_status("Filling Index Type List");
 
  // args check
  VDASSERTW(form_ptr != '\0');

  /* inits */
  nodeIDs = NULL;
  selNodeID.objid == NULL_OBJID;
  VDtblCmdGetNameID(&selNodeID);

  // read the Selection, Stages and Names gadgets
  FIg_reset( form_ptr, VD_STBL_INDEXTYP_FLD ); // 36  Index Selection

  // read the stages gadget text
  selType[0] = '\0';
  vdfrm$GetText( form    = form_ptr,
                 gadget  = VD_STBL_CR_TYPE_FLD, // 26
                 txt     = selType );
  
  // read the stages gadget text
  nodeType[0] = '\0';
  vdfrm$GetText( form    = form_ptr,
                 gadget  = VD_STBL_STAGE_FLD, // 28
                 txt     = nodeType );
  
  // read the name gadget text
  nodeName[0] = '\0';
  vdfrm$GetText( form    = form_ptr,
                 gadget  = VD_STBL_NAME_FLD, // 30
                 txt     = nodeName );
  
  // if these gadgets are empty don't allow any index selection
  /* note:  It is ok for the nodeName to be blank because many
   * SA_AST nodes are blank in their names
   */
  if((selType == '\0') ||
     (nodeType == '\0')) {
    FIg_erase( form_ptr, VD_STBL_INDEXTYP_FLD ); // 36  Index Selection
    FIg_erase( form_ptr, VD_STBL_INDEXTYP_TXT ); // 35   text 
    goto wrapup;;
  }

  if(strcmp(selType,"Index")) {
    //FIg_disable( form_ptr, VD_STBL_INDEXTYP_FLD ); // 36  Index Selection
    FIg_erase( form_ptr, VD_STBL_INDEXTYP_FLD ); // 36  Index Selection
    FIg_erase( form_ptr, VD_STBL_INDEXTYP_TXT ); // 35   text 
    goto wrapup;
  }
    // first things first enable and reset the form
  FIg_enable( form_ptr, VD_STBL_INDEXTYP_FLD ); // 36  Index Selection
  FIg_reset( form_ptr, VD_STBL_INDEXTYP_FLD ); // 36  Index Selection
  FIg_enable( form_ptr, VD_STBL_INDEXTYP_TXT ); // 35   text 
  Selflag = FALSE;
  
  // get the treeID
  VDctbsGetTreeID(form_ptr,&treeID);
  VDctbsFilterTreeID( &treeID );
  if(treeID.objid == NULL_OBJID) {
    if(traceFlag) printf("Wrapup @LOC1\n");
    goto wrapup;
  }

  if(traceFlag) printf("The treeID[%d][%d]\n",treeID.osnum,treeID.objid);
  if(selNodeID.objid == NULL_OBJID) goto wrapup;
  
  /* be extra careful */
  if(treeID.osnum != selNodeID.osnum) goto wrapup;


  // from selNodeID get the nodeIDs related
  cnt = 0;
  selectionType = VDTR_FIND_ALL;
  vd$trget_nodes(nodeID       = &selNodeID,
                 lookupType   = selectionType,
		 frozen       = 1,
                 outID        = &nodeIDs,
                 cnt          = &cnt);
  if (cnt < 1) {
    if(traceFlag) printf("addFileInfo @LOC4\n");
    FIfld_set_num_rows(form_ptr,VD_STBL_INDEXTYP_FLD,0);
    goto addFileInfo;
  }
  
  //   loop through the IDs and fetch the names matching the text

  nodeTypeCnt = 0;
  for(i = 0;i < cnt;i++) {
    nodeType[0] = '\0';
    vdtr$GetNodeType(nodeID   = &nodeIDs[i],
                     nodeType = nodeType);

    for( j = 0 ; j < nodeTypeCnt ; j++ )
    {
      if( !(strcmp(nodeType, nodeTypeList[j])) ) {
	break;
      }
    }

    if( j == nodeTypeCnt )
    {
      if(VDctbsFilterStages(&nodeIDs[i],nodeType)) {
        strcpy( nodeTypeList[nodeTypeCnt], nodeType );
        nodeTypeCnt++;
      }
    }
  }
  if(nodeIDs)  _FREE(nodeIDs);
 
  // load up the gadget row count
  if(nodeTypeCnt >= 1) FIfld_set_num_rows( form_ptr, VD_STBL_INDEXTYP_FLD, nodeTypeCnt ); // #36

  FIg_set_text( form_ptr, VD_STBL_INDEXTYP_FLD, nodeTypeList[0] );

  for(i = 0;i < nodeTypeCnt;i++) {
  // load up the rows
    FIfld_set_list_text( form_ptr,
                         VD_STBL_INDEXTYP_FLD,  // #36
                         i,
                         0,
                         (unsigned char *)(nodeTypeList[i]),
                         Selflag );
  }

addFileInfo:
  FIfld_get_num_rows(form_ptr,VD_STBL_INDEXTYP_FLD,&rows);
  if(traceFlag) printf("number of rows in the gadget used is [%d]\n",rows);
  
  // get the expr_table data
  VDtbl_get_expr_file( &info );
  ptr = info.filebuf;
  strcpy(buf,ptr);
  gotComm = 0;

  // loop through the data from the file
  for(i = 0;i < info.lines;i++) {
    strcpy(buf,ptr);
    ptr += VDTR_BUF_SIZE;
    sts = VDtrGetTreeCommand(buf);

    // we have a treeType to compare to
    if(sts == 1) {
      // get out of here if it is another command we are done
      if(gotComm & 1) goto wrapup;
      vdtr$GetNodeType(nodeID   = &treeID,
                       nodeType = bufT);
      // it matches the command string start loading expressions now
      if(!strcmp(buf,bufT))  gotComm = 1;
    }
    // we have a possible expression to load up
    if(sts == -1){
      if(gotComm){
        // up the count and add the goods to the index list
        nodeTypeCnt++;
        FIfld_set_num_rows( form_ptr, VD_STBL_INDEXTYP_FLD, nodeTypeCnt ); // #36
        FIfld_set_list_text( form_ptr,
                             VD_STBL_INDEXTYP_FLD,  // #36
                             (nodeTypeCnt -1),
                             0,
                             (unsigned char *)(buf),
                             Selflag );
      }
    }
  }

  retFlag = 1;
wrapup:
  FIfld_get_num_rows(form_ptr,VD_STBL_INDEXTYP_FLD,&rows);
  /* bat cleanup on the form */
  if(rows > 0) {
    vdfrm$GetListText( form   = form_ptr,
		       gadget = VD_STBL_INDEXTYP_FLD,
		       row    = 0,
		       txt    = buf);
    FIg_get_text(form_ptr,VD_STBL_INDEXTYP_FLD,nodeType);
    if(!strcmp(nodeType,"")) {
      FIg_set_text(form_ptr,VD_STBL_INDEXTYP_FLD,buf);
    }
  }
  _FREE( nodeIDs );
  UI_status("Done");

  // say bye
  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}

/*****************************************************************
 *
 * find number of occurances in a list of a stage and name
 * find the row on the form where this matches Match up the ID
 * set it as selected row
 * this does not have a problem with alphabetic or ordered lists
 * because if the list has multiples of the same name because they 
 * do not represent any change of order
 * loads the text into the text gadget to match
 *
 *****************************************************************/
IGRstat VDctbsFindNodeIDRow(char *form_ptr,TGRid *nodeID,IGRint *row) 
{
  VDASSERT_FN("VDctbsFindNodeIDRow");
  IGRint  retFlag = 0;
  TGRid   treeID;
  IGRint  gadgetrow,rows,i,j,itemCnt,selectionType,cnt,rowCnt;
  IGRchar nodeName[128],nodeType[128],buf[128],selType[128],selName[128];
  TGRid   *nodeIDs;
  TGRid   *nodeList;
  IGRint  nodeListCnt;
  
  
  
  // say hi
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn); 
  }
  *row = -1;
  /* args */
  VDASSERTW(form_ptr);
  VDASSERTW(nodeID);
  if(nodeID->objid == NULL_OBJID) goto wrapup;
  
  /* get the treeID */
  VDctbsGetTreeID(form_ptr,&treeID);
  if(treeID.objid == NULL_OBJID) {
    goto wrapup;
  }

  /* get the number of rows on the form */
  FIfld_get_num_rows(form_ptr,VD_STBL_NAME_FLD,&rows);
  if(rows < 1) goto wrapup;
  
  /* get the nodeName and nodeType */
  vdtr$GetNodeType(nodeID = nodeID,nodeType = selType);
  vdtr$GetNodeName(nodeID = nodeID,nodeName = selName);
  
  /* get all the nodes for this treeID */
  selectionType = VDTR_FIND_ALL;
  vd$trget_nodes(nodeID       = &treeID,
		 lookupType   = selectionType,
		 frozen       = 1,
		 outID        = &nodeIDs,
		 cnt          = &cnt);
  if(cnt < 1) goto wrapup;
  /* loop through and count a list of nodes matching Stage and Name */
  itemCnt = 0;
  for(i = 0;i < cnt;i++) {
    /* get each line's data */
    vdtr$GetNodeType(nodeID = &nodeIDs[i],nodeType = nodeType);
    vdtr$GetNodeName(nodeID = &nodeIDs[i],nodeName = nodeName);
    if((!strcmp(nodeType,selType)) && (!strcmp(nodeName,selName))) {
      itemCnt++;
    }
    /* if we found the match */
    if(nodeIDs[i].objid == nodeID->objid) break;  
  }
  /* nothing found go to wrapup */
  if(itemCnt < 1) goto wrapup;
  /* loop through the rows and find the gadget row that matches  for selection */
  rowCnt = 0;
  for(gadgetrow = 0;gadgetrow < rows;gadgetrow++) {
    /* read the row */
    vdfrm$GetListText( form   = form_ptr,
		       gadget = VD_STBL_NAME_FLD,
		       row    = gadgetrow,
		       txt    = nodeName);
    if(!strcmp(nodeName,selName)) {
      rowCnt++;
    }
    if(rowCnt == itemCnt) {
      *row = gadgetrow;
      FIfld_set_list_select(form_ptr, VD_STBL_NAME_FLD,gadgetrow, 0, 1);
      FIg_set_text( form_ptr, VD_STBL_NAME_FLD, nodeName );
      retFlag = 1;
      goto wrapup;
    }
  } 

wrapup:
      
  if(cnt > 1) _FREE(nodeIDs);
  
  // say bye
  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}

/*****************************************************************
 *
 * find number of occurances in a list of a stage and name
 * Match up the ID from a list to the active row in the text gadget
 * output is the nodeID input is the row
 *
 *****************************************************************/
IGRstat VDctbsFindRowNodeID(char *form_ptr,IGRint *row,TGRid *nodeID) 
{
  VDASSERT_FN("VDctbsFindRowNodeID");
  IGRint  retFlag = 0;
  TGRid   treeID;
  IGRint  gadgetrow,rows,i,j,itemCnt,selectionType,cnt,rowCnt,pos,selFlag;
  IGRchar nodeName[128],nodeType[128],buf[128],selType[128],selName[128];
  TGRid   *nodeIDs;
  TGRid   *nodeList;
  TGRid   selNodeID;
  IGRint  nodeListCnt = 0;
  
  
  // say hi
  if (traceFlag) {
    printf(">>> %s %s row[%d]\n",ffn(),fn,*row); 
  }
  
  /* args */
  VDASSERTW(form_ptr);
  VDASSERTW(nodeID);
    /* init */
  nodeID->objid = NULL_OBJID;
  nodeListCnt = 0;
  cnt = pos = rowCnt = itemCnt = i = j = rows = gadgetrow = 0;

  /* get the treeID */
  VDctbsGetTreeID(form_ptr,&treeID);
  if(treeID.objid == NULL_OBJID) {
    goto wrapup;
  }
 
  /* get the number of rows on the form */
  FIfld_get_list_num_rows(form_ptr,VD_STBL_NAME_FLD,0,&rows);
  if(rows < 1) goto wrapup;
  if(*row >= rows) goto wrapup;
  if(*row < 0) goto wrapup;
  
  /* fetch the stage for the selection */
  FIg_get_text(form_ptr,VD_STBL_STAGE_FLD,selType);
  if(!strcmp(selType,"")) goto wrapup;


  /* read the text on the row */
  vdfrm$GetListText( form   = form_ptr,
		     gadget = VD_STBL_NAME_FLD,
		     row    = *row,
		     txt    = selName);
  /* PLEASE NOTE THIS VALUE CAN BE BLANK AND MEAN SOMETHING */
  /* get all the nodes for this treeID */
  vd$trget_nodes(nodeID       = &treeID,
		 lookupType   = VDTR_FIND_ALL,
		 frozen       = 1,
		 outID        = &nodeIDs,
		 cnt          = &cnt);
  if(cnt < 1) goto wrapup;

  /* start adding to a list any matching nodes */
  /* do the tree first */
  nodeListCnt = 0;
  vdtr$GetNodeType(nodeID   = &treeID,
		   nodeType = nodeType);
  vdtr$GetNodeName(nodeID   = &treeID,
		     nodeName = nodeName);
  
  if((!strcmp(selType,nodeType)) && (!strcmp(selName,nodeName))) {
      /* add in this matching node */
    VDtvwAddNodeToListUnique(&treeID,&nodeList,&nodeListCnt);
    }

  /* loop through and add up a list of nodes matching the name and type */
  for(i = 0;i < cnt;i++) {
    vdtr$GetNodeType(nodeID   = &nodeIDs[i],
		     nodeType = nodeType);
    vdtr$GetNodeName(nodeID   = &nodeIDs[i],
		     nodeName = nodeName);
   
    if((!strcmp(selType,nodeType)) && (!strcmp(selName,nodeName))) {
      /* add in this matching node */
      VDtvwAddNodeToListUnique(&nodeIDs[i],&nodeList,&nodeListCnt);
    }
  }
  
  if(nodeListCnt < 1) {
    goto wrapup;
  }
  
  if(*row == 0) {
    *nodeID = nodeList[0];
    goto wrapup;
  }
  /* loop through the rows on the form and see how many match the name before (*row) */
  itemCnt = 0;
  for(i = 0;i <= *row;i++) {
    FIfld_get_list_text(form_ptr,VD_STBL_NAME_FLD,i,0,128,(unsigned char *)buf,&selFlag);
    if(!strcmp(buf,selName)) {
      itemCnt++;
    }
  }
  if(itemCnt <= nodeListCnt) {
    nodeID->osnum = nodeList[itemCnt-1].osnum;
    nodeID->objid = nodeList[itemCnt-1].objid;
  }
  
  retFlag = 1;
wrapup:
  if(traceFlag) printf("nodeID[%d][%d]\n",nodeID->osnum,nodeID->objid);
  if(cnt > 0) _FREE( nodeIDs );
  if(nodeListCnt > 0) _FREE( nodeList );
  
  // say bye
  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}

/**************************************************
 *
 * Compose a string from a set of strings
 * that is <strData><SeperatorString><strData> etc
 *
 * sepStrBuf is declared so big as to prevent any 
 * accidents and get rid of memory allocation stuff
 *
 **************************************************/
IGRstat VDtblMakeSepDataString(IGRchar   *sepString,
			       IGRchar   *separator,
			       IGRchar  **strsIn,
			       IGRint     strsInCnt)
{
  IGRint retFlag = 0;
  IGRint i;
  IGRchar sepStrBuf[8192];
  IGRchar strBuf[1028];
  VDASSERT_FN("VDtblMakeSepDataString");

  traceFlag = 1;
  
  // say hi
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn); 
  }  

  /* args check */
  VDASSERTW(sepString);
  VDASSERTW(separator);
  VDASSERTW(strsIn);
  if(strsInCnt < 1) goto wrapup;
  
  /* initialize the data string */
  sepString[0] = '\0';
  sepStrBuf[0] = '\0';
  for(i = 0;i < strsInCnt;i++) {
    strcpy(strBuf,strsIn[i]);
    if(i < (strsInCnt -1)) strcat(strBuf,separator);
    strcat(sepStrBuf,strBuf);
  }
  /* copy it to the sepSting */
  strcpy(sepString,sepStrBuf);
  retFlag = 1;

 wrapup:
  // say bye
  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}
/**************************************************
 *
 * Decompose a string to a set of strings
 * that is <strData><SeperatorString><strData> etc
 *
 * sepStrBuf is declared so big as to prevent any 
 * accidents and get rid of memory allocation stuff
 *
 **************************************************/
IGRstat VDtblUnMakeSepDataString(IGRchar   *sepString,
				 IGRchar   *separator,
				 IGRchar ***strsOut,
				 IGRint    *strsOutCnt)
{
  IGRint  retFlag      = 0;
  IGRint  i            = 0;
  IGRint  sepStrLen    = 0;
  IGRint  lenRemain    = 0;
  IGRint  separatorLen = 0;
  IGRint  sepStrCnt    = 0;
  IGRchar sepStrBuf[8192],strBuf[1028];
  IGRchar *p,*q;
  VDASSERT_FN("VDtblUnMakeSepDataString");

  traceFlag = 1;
  
  // say hi
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn); 
  }  

  /* args check */
  VDASSERTW(sepString);
  VDASSERTW(separator);
  VDASSERTW(strsOut);
 
  /* initialize the data string */
  sepString[0] = '\0';
  sepStrBuf[0] = '\0';

  /* clean up any memory allocation troubles */
  if(*strsOutCnt > 0) _LOOPFREE( *strsOut,*strsOutCnt );
  *strsOutCnt = 0;

  /* copy the string over to work */
  strcpy(sepStrBuf,sepString);

  /* start looping through and getting the seperator strings */
  p = strtok(sepStrBuf,sepString);
  if(p == NULL) goto wrapup;
  vdtvw$AddStrList(item    = p,
		   List    = strsOut,
		   ListCnt = strsOutCnt);
  do {
    p = strtok(NULL,sepString);
    if(p) vdtvw$AddStrList(item    = p,
			   List    = strsOut,
			   ListCnt = strsOutCnt);
  } while(p);

  retFlag = 1;

 wrapup:
  // say bye
  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}



static IGRint  intcmp( int* e1, int* e2 )
{
	return (*e1 - *e2);
}


end implementation VDCmdPlHdr;
