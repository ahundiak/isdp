/* $Id: VDtrToolsTbl.I,v 1.30 2001/10/02 21:37:58 paul_noel Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdct1/tools/VDtrToolsTbl.I
 *
 * Description: basic node tools additional
 *
 * Dependencies: $Log: VDtrToolsTbl.I,v $
 * Dependencies: Revision 1.30  2001/10/02 21:37:58  paul_noel
 * Dependencies: *** empty log message ***
 * Dependencies:
 * Dependencies: Revision 1.29  2001/10/02 15:59:32  paul_noel
 * Dependencies: Update for new tools for ppls
 * Dependencies:
 * Dependencies: Revision 1.28  2001/08/11 17:13:31  paul_noel
 * Dependencies: Moved File opening manipulations to vdtvwtools.h
 * Dependencies:
 * Dependencies: Revision 1.27  2001/08/01 14:56:33  paul_noel
 * Dependencies: Add Item selection to processes
 * Dependencies:
 * Dependencies: Revision 1.26  2001/07/17 12:47:53  paul_noel
 * Dependencies: fix get trees/sets
 * Dependencies:
 * Dependencies: Revision 1.25  2001/05/30 16:10:57  paul_noel
 * Dependencies: Fix missing reference Trees TR5192
 * Dependencies:
 * Dependencies: Revision 1.24  2001/05/25 13:35:51  paul_noel
 * Dependencies: *** empty log message ***
 * Dependencies:
 * Dependencies: Revision 1.23  2001/05/17 18:11:51  paul_noel
 * Dependencies: Update vdtr$GetDelimitedStr function to allow unlimited size of input string used in CR5006
 * Dependencies:
 * Dependencies: Revision 1.22  2001/05/07 13:41:03  paul_noel
 * Dependencies: Append Named File option added
 * Dependencies:
 * Dependencies: Revision 1.21  2001/04/11 18:43:47  paul_noel
 * Dependencies: Add VDio_read_anyFile
 * Dependencies:
 * Dependencies: Revision 1.20  2001/03/21 18:37:41  paul_noel
 * Dependencies: Fixing _FREE issue
 * Dependencies:
 * Dependencies: Revision 1.19  2001/03/19 20:30:32  paul_noel
 * Dependencies: Fix _FREE problem
 * Dependencies:
 * Dependencies: Revision 1.18  2001/03/15 15:34:13  paul_noel
 * Dependencies: fix expression eval issue tr 4901
 * Dependencies:
 * Dependencies: Revision 1.17  2001/03/14 15:05:17  paul_noel
 * Dependencies: *** empty log message ***
 * Dependencies:
 * Dependencies: Revision 1.16  2001/03/09 16:47:53  paul_noel
 * Dependencies: Added functions vdtr$GetAllSets vdtr$IsSet vdtr$IsTree vdtr$IsNode
 * Dependencies:
 * Dependencies: Revision 1.15  2001/03/05 21:32:47  paul_noel
 * Dependencies: *** empty log message ***
 * Dependencies:
 * Dependencies: Revision 1.14  2001/03/02 13:12:58  paul_noel
 * Dependencies: *** empty log message ***
 * Dependencies:
 * Dependencies: Revision 1.13  2001/02/28 16:10:01  paul_noel
 * Dependencies: adjust get_nodeInfo
 * Dependencies:
 * Dependencies: Revision 1.12  2001/02/28 15:40:26  paul_noel
 * Dependencies: test function modified
 * Dependencies:
 * Dependencies: Revision 1.11  2001/02/27 14:05:19  paul_noel
 * Dependencies: Edits to make available tree/node selection on Paths
 * Dependencies:
 * Dependencies: Revision 1.10  2001/02/26 17:49:37  paul_noel
 * Dependencies: *** empty log message ***
 * Dependencies:
 * Dependencies: Revision 1.9  2001/02/26 12:42:26  paul_noel
 * Dependencies: Add generic ID process for table nodeList
 * Dependencies:
 * Dependencies: Revision 1.8  2001/02/25 21:31:53  paul_noel
 * Dependencies: Macros for general use on table nodeLists
 * Dependencies:
 * Dependencies: Revision 1.7  2001/02/23 16:47:23  paul_noel
 * Dependencies: Added new functionality for node Paths
 * Dependencies:
 * Dependencies: Revision 1.6  2001/02/20 15:44:54  ahundiak
 * Dependencies: ah
 * Dependencies:
 * Dependencies: Revision 1.5  2001/02/19 17:32:11  paul_noel
 * Dependencies: new tools added including a generic file opener
 * Dependencies:
 * Dependencies: Revision 1.4  2001/02/17 14:53:05  ahundiak
 * Dependencies: *** empty log message ***
 * Dependencies:
 * Dependencies: Revision 1.3  2001/02/13 15:20:07  jayadev
 * Dependencies: vd$exp_evaluate args changed
 * Dependencies:
 * Dependencies: Revision 1.2  2001/02/09 18:14:18  paul_noel
 * Dependencies: *** empty log message ***
 * Dependencies:
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 01/30/01  pn      Creation
 * 04/11/01  pn      added VDio_read_anyFile
 * 04/26/01  pn      added VDio_append_named_file
 ***************************************************************************/

// Generic node operations routines

class implementation Root;
#include "vdtr_macros.h"
#include "VDmem.h"
#include "VDassert.h"
#include "VDtypedefc.h"
#include "VDexp.h"
#include "vdsmacros.h"
#include "VDiofile.h"
#include "VDctx.h"
#include "VDfrm.h"
#include "vdtvwtools.h"
#include "VDxdom.h"
#include "VDfile.h"
#include "grio.h"
#include "griomacros.h"


FILE   *VDtrCmdSetOpenListOfSets();

IGRstat VDtrGetTest();

IGRstat VDtrGetCmdLineInput(IGRchar *prompt, 
			    IGRchar *answer);

IGRstat VDtrGetCmdLineYNInput(IGRchar *prompt);

IGRstat VDtrGetXMLSchemaView(TGRid *xmlSchemaID);
IGRstat VDtrGetXSLStyleSheetView(TGRid *xmlSchemaID,
				 TGRid *xslStyleSheetID);

VDASSERT_FFN("vdct1/tools/VDtrToolsTbl.I");


extern VDtvwAddNodeToListUnique(TGRid  *addNode,
				TGRid **nodeList,
				IGRint *nodeListCnt);

extern VDtvwGetItemList(TGRid **itemList,
			IGRint *itemListCnt);


extern  UI_message(); /* Fct to display the message field        */
extern  UI_prompt();  /* Fct to display the prompt field         */
extern  UI_status();  /* Fct to display the status field         */


/*****************************************************
 *
 * Fills a gadget with the VDat and VDct1 Trees list and 
 * the final row is filled with the treeID
 * wrapped by VDtrTblMgrFillSets(..)
 * 
 *****************************************************/
IGRstat VDtrTblMgrFillSet(char *VD_FP, IGRint gadget, IGRint *row)
{
  VDASSERT_FN("VDtrTblMgrFillSet");
  IGRstat  retFlag = 0;
  TGRid    mgrID,setID,setsID,rdbSetID,setTreeID;
  IGRchar  setName[128];
  IGRchar  setType[128];
  IGRchar  setBase[128];
  IGRchar  *pnt;
  IGRchar  refName[DI_PATH_MAX];
  IGRint   i,osnum;
  TVDctxBaseInfo baseInfo;

  // say hi
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn); 
  }

  // args checks
  VDASSERTW(VD_FP);
  VDASSERTW(gadget); 
 
  for(osnum = 0; VDosValidate(osnum); osnum++) {
    
    // OS Name
    di$give_pathname(osnum = osnum, pathname = refName);
    pnt = strrchr(refName,':');
    if (pnt) strcpy(refName,pnt+1);
    
    // get the AT manager
    vdat$GetSetMgr(osnum = osnum, mgrID = &mgrID);
    
    // Get the sets for the VDat Trees
    VDatGetSets(&mgrID,&setsID);
    if (setsID.objid != NULL_OBJID) {
      // Cycle Through
      for(i = 0; VDatGetChildObject(&setsID,i,&setID); i++) {
	// Show name for now
	VDahFrmSetTextRC(VD_FP,gadget,*row,0,refName);
	
	// Show name for now
	*setName = 0;
	VDatGetBaseName(&setID,setName);
	VDahFrmSetTextRC(VD_FP,gadget,*row,1,setName);
	
	// Get the set type
	VDatRDBGetSet  (&setID,&rdbSetID);
        VDctxGetBaseInfo(&rdbSetID,&baseInfo);
        strcpy(setType,baseInfo.setType);
        
	//VDatGetBaseName(&rdbSetID,setType);
	VDahFrmSetTextRC(VD_FP,gadget,*row,2,setType);
	
	// Store the id
	VDahFrmSetGRid(VD_FP,gadget,*row,3,&setID);
	
	// Next Row
	*row = *row + 1;
      }
      // done getting the VDatSets
    }
  }
  /* fix for TR5192 ~pn 5/30/2001 */
  for(osnum = 0; VDosValidate(osnum); osnum++) { 
  // get the VDct1MgrID
    VDct1GetManager(osnum,&mgrID);
    /* end alterations TR5192 */

    // OS Name
    di$give_pathname(osnum = osnum, pathname = refName);
    pnt = strrchr(refName,':');
    if (pnt) strcpy(refName,pnt+1);
    if (mgrID.objid != NULL_OBJID) {
      for(i = 0;VDctxGetNthMgrChild(&mgrID,i,&setID);i++) {
      // for(i = 0;vdct1$GetMgrChild(objID = &mgrID, nth = i, outID = &setID); i++) {
	// get the treeID for each set
	VDctxGetTree(&setID,&setTreeID);
	// Show name for now
	VDahFrmSetTextRC(VD_FP,gadget,*row,0,refName);
	// get the tree data and set it on the form
	VDtrget_nodeName(&setTreeID,setName);
	VDtrget_nodeType(&setTreeID,setType);
	VDahFrmSetTextRC(VD_FP,gadget,*row,1,setName);
 	VDahFrmSetTextRC(VD_FP,gadget,*row,2,setType);
	// Store the id
	VDahFrmSetGRid(VD_FP,gadget,*row,3,&setTreeID);
	// Next Row
	*row = *row + 1;
      }
    }
    /* TR5192 added bracket to match osnum loop above */
  }
  
  
  
  // done getting the VDct1Sets
  if(*row > 0) retFlag = 1;
wrapup:
  // say bye 
  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}

/*****************************************************
 *
 * Generic Replacement for  
 * VDatCMDMgrFillSets( VD_FP, VD_STBL_TREESET_FLD )
 * used to fill up the list of sets in Gadget #31 in
 * Create Table By Stage Command
 * might be useful for filling a list of VDat and VDct1
 * sets in almost any form gadget since this is pretty
 * generic stuff
 *
 *****************************************************/
IGRstat VDtrTblMgrFillSets(char *VD_FP, IGRint gadget )
{
  VDASSERT_FN("VDtrTblMgrFillSets");
  IGRint    row,sts1,sts2;
  VDosnum   osnum;
  IGRstat   retFlag = 0;

  // say hi
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn); 
  }

  // args checks
  VDASSERTW(VD_FP);
  VDASSERTW(gadget);
  
  // Clear Field
  VIfld_set_num_rows(VD_FP,gadget,0);
  row = 0;

   retFlag  = VDtrTblMgrFillSet(VD_FP, gadget, &row);  

wrapup:
  // say bye 


  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}
/* --------------------------------------------------------
 * Look through config directories for list of sets
 */
FILE *VDtrCmdSetOpenListOfSets()
{
  IGRint i;
  IGRchar buf[DI_PATH_MAX];

  FILE *file;

  // Look in local directory
  file = fopen("expr_table","rt");
  if (file) return file;
  
  // Look in config directory
  for(i = 0; 1; i++) {
    
    // Product specific loading
    *buf = 0;
    ex$get_path( index = i,
		 path  = buf,
		 len   = sizeof(buf),
		 type  = EX_CONFIG_PATH );
    if (*buf == 0) {
      file = NULL;
      return file;
    }
   
    strcat(buf,"/config/drawing/expr_table");
    
    file = fopen(buf,"rt");
    if (file != NULL) return file;
  }
}

/*****************************************************
 *
 * Get the file command string parsed from a unparsed
 * input such as comes from a file read
 * does not include spaces in the string or '\n'
 * returns 1 if it is a command string
 * returns -1 if it is a dependency
 * fileString returns blank if not 
 *
 *****************************************************/
IGRstat VDtrGetTreeCommand(IGRchar *fileString)
{
  VDASSERT_FN("VDtrGetTreeCommand");
  IGRstat  retFlag = 0;
  IGRchar  buf[128];
  IGRint   i,stringLength;
  IGRchar  *p;
 
  // say hi
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn); 
  }
  VDASSERTW(fileString);
 
  p = fileString;
  stringLength = strlen(fileString);
  strcpy(buf,"");

  // go home if it is not a command string of some type
  if((!(*p == '#')) && (!(*p == '%'))) goto wrapup;
  if(*p == '%') {
    // success start the string
    retFlag = 1;
    p++;
  }
  if(*p == '#') {
    // success start the string
    retFlag = -1;
    p++;
  }
  for(i = 0; i < stringLength; i++) {
    if(retFlag != 0) {
      if((!(*p == ' ')) && (!(*p == '\n'))) sprintf(buf,"%s%c",buf,*p);
      p++;
    }
  }
  strcpy(fileString,buf);
  if(!(strcmp(fileString,""))) retFlag = 0;
  if(traceFlag) printf("printing buf [%s]\n",buf);
wrapup:
  // say bye 


  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}
/*****************************************************
 *
 * Delimited string recovery function
 * clips out from a delimited string  a string
 * that is based upon the position of delimiters in 
 * the source string
 * Default delimiter is ':'
 * warning: outStr dimension is determined by the user
 * who calls this function.  MAKE IT BIG ENOUGH!
 * inpStr may be any size.  MALLOC will handle it.
 *
 *****************************************************/
IGRstat VDtrGetDelimitedStr(IGRchar *inpStr,
			    IGRchar *outStr,
			    IGRchar delChr,
			    IGRint  posStr)
{
  IGRstat  retFlag = 0;
  VDASSERT_FN("VDtrGetDelimitedStr");
  IGRchar  *ptr;
  IGRchar  *localString,*locStr,*wkStr,buf[1024];
  IGRint   stringLength,pos,i,j,posCnt,memAlloc;
  
  // say hi
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn); 
  }
  VDASSERTW(inpStr);
  VDASSERTW(outStr);
  
  /* check the string length coming in */
  memAlloc = 0;
  stringLength = strlen(inpStr);
  /* handle if the string gets too long! */
  if(stringLength > 1024) {
    /* allocate the memory for localString to the new length */
    memAlloc = 1;
    locStr = _MALLOC( (stringLength +1), IGRchar );
    /* copy the data local */
    strcpy(locStr,inpStr);
    /* set the pointer to the allocated location */
    localString = locStr;
  } else {
    /* copy local to the predefined size character array no allocation */
    strcpy(buf,inpStr);
    localString = buf;
  }
  
  // verify the posStr values and inits
  posStr--;
  
  strcpy(outStr,"");
  if(posStr < 0) goto wrapup;

  // there must be a string to clip
  if(stringLength < 2) goto wrapup;
  ptr = localString;
  posCnt = 0;
  // loop through and get the delimiter based upon the positon
  for(i = 0;i < stringLength; i++) {
    if(posCnt == posStr) break;
    if(*ptr == delChr) posCnt++;
    ptr++;
  }
  if(i == stringLength) goto wrapup;
  stringLength = strlen(ptr);
  // loop through and get the string clip
  for(i = 0; i < stringLength; i++) {
    // stop if you hit another delimiter or end line
    if((*ptr == delChr) || (*ptr == '\n')) {
      retFlag = 1;
      goto wrapup;
    }
    // add the character to the outStr
    sprintf(outStr,"%s%c",outStr,*ptr);
    // increment the ptr
    ptr++;
  }
  
wrapup:
  // say bye 

  if(memAlloc) {
    _FREE( locStr );
  }
  
  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}

/*****************************************************
 *
 * Specialized device for getting all treeIDs
 * MEMORY ALLOCATED
 * all variables are outputs
 * 
 *****************************************************/
IGRstat VDtrGetAllTrees(TGRid **treeList,IGRint *treeCnt)
{
  VDASSERT_FN("VDtrGetAllTrees");
  IGRstat  retFlag = 0;
  TGRid    mgrID,setID,setsID,rdbSetID,setTreeID;
  IGRchar  setName[128];
  IGRchar  setType[128];
  IGRchar  setBase[128];
  TGRid    *setList = NULL;
  IGRint   setListCnt = 0;
  IGRchar  *pnt;
  IGRchar  refName[DI_PATH_MAX];
  IGRint   i,osnum,objCnt= 0;

  // say hi
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn); 
  }

  // args checks
  VDASSERTW(treeList);
  VDASSERTW(treeCnt);
  
  // init
  *treeCnt = 0;
  _FREE(*treeList);

  /* fetch all the sets */
  vdtr$GetAllSets(setList = &setList, 
		 setCnt   = &setListCnt);
  if(setListCnt < 1) {
    if(traceFlag) printf("we did not get any sets \n");
    goto wrapup;
  }
  
  /* lets look at the results */
  for(i = 0;i < setListCnt;i++) {
    VDctxGetTree(&setList[i],&setTreeID);
    VDtvwAddNodeToListUnique(&setTreeID,
			     treeList,
			     treeCnt);
  }

  retFlag = 1;
  _FREE(setList);

wrapup:
  // say bye 
  if (traceFlag) {
    printf("<<< %s %s %d trees[%d]\n",ffn(),fn,retFlag,*treeCnt);
  }
  return retFlag;
}
/*****************************************************
 *
 * Specialized device for getting all setIDs
 * MEMORY ALLOCATED
 * all variables are outputs
 * 
 *****************************************************/
IGRstat VDtrGetAllSets(TGRid **setList,IGRint *setCnt)
{
  VDASSERT_FN("VDtrGetAllSets");
  IGRstat  retFlag = 0;
  TGRid    mgrID,setID,setsID,rdbSetID,setTreeID;
  IGRchar  setName[128];
  IGRchar  setType[128];
  IGRchar  setBase[128];
  IGRchar  *pnt;
  IGRchar  refName[DI_PATH_MAX];
  IGRint   i,osnum,objCnt= 0;

  // say hi
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn); 
  }

  // args checks
  VDASSERTW(setList);
  VDASSERTW(setCnt);
  
  // init
  *setCnt = 0;
  _FREE(*setList);
  
  for(osnum = 0; VDosValidate(osnum); osnum++) {
    // get the VDct1MgrID
    VDct1GetManager(osnum,&mgrID);
    if (mgrID.objid != NULL_OBJID) {
      for(i = 0;VDctxGetNthMgrChild(&mgrID,i,&setID);i++) {
	// get the treeID for each set
	if(setID.objid != NULL_OBJID) {
	  VDctxGetTree(&setID,&setTreeID);
	  /* ADD IT TO THE LIST */
	  VDtvwAddNodeToListUnique(&setTreeID,
				   setList,
				   setCnt);
	}
      }
    }
  }
  for(osnum = 0; VDosValidate(osnum); osnum++) {
   // get the AT manager
    vdat$GetSetMgr(osnum = osnum, mgrID = &mgrID);
    if(mgrID.objid != NULL_OBJID) {
      // Get the sets for the VDat Trees
      VDatGetSets(&mgrID,&setsID);
      if (setsID.objid != NULL_OBJID) {
	// Cycle Through
	for(i = 0; VDatGetChildObject(&setsID,i,&setID); i++) {
	  /* ADD IT TO THE LIST */
	  if(setID.objid != NULL_OBJID) {

	    VDtvwAddNodeToListUnique(&setID,
				     setList,
				     setCnt);
	  }
	}
      }
    }
  }
  
  retFlag = 1;

wrapup:
  // say bye 
  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}

/* ------------------------------------------------------------------------
 *
 * Function to handle SA_EXP expressions 
 * for a root node
 * MEMORY IS ALLOCATED FOR **nodeList
 *
 * ------------------------------------------------------------------------
 */

IGRstat VDtrGetNodeListByEXP(TGRid *rootNode,IGRchar *attrExp,TGRid **nodeList,IGRint *nodeCnt) 
{
  VDASSERT_FN("VDtrGetNodeListByEXP");
  IGRchar          indexType[128],desc[128];
  IGRint           i,retFlag = 0;
  IGRstat          status = 0;
  IGRint           tmpNodeCount = 0,
                   jntNum = 0;
  IGRboolean       flag;
  IGRdouble        dblNum = 0;
  IGRchar          nodeName[128],nodeType[128],buf[128],*p;
  struct GRid      *tmpNodeList,
                   *localNodeList;
  struct GRobj_env modelObj,objectOE;
  struct ACrg_coll   rg_coll;
  
  // say hi
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn); 
  }

  // Args check
  VDASSERTW(rootNode);
  VDASSERTW(attrExp);

  // init
  *nodeCnt = 0;
  *nodeList = NULL;
  nodeName[0] = '\0';
  nodeType[0] = '\0';
  buf[0] = '\0';
  flag = FALSE;
  tmpNodeList = NULL;
  
  
   // get all the nodes under the root node
  status = vd$trget_nodes( nodeID     = rootNode,
                           lookupType = VDTR_FIND_ALL_NODE,
                           outID      = &tmpNodeList,
                           cnt 	      = &tmpNodeCount ) ;
  if((tmpNodeCount == 0) || (tmpNodeList == NULL))
    {
      if(traceFlag) printf("%s %s: wrapup on no results from tmpNodeList \n",ffn(),fn);
      goto wrapup;
    }
  if(traceFlag) printf("%s %s: We now have the tmpNodeList [%d] nodes\n",ffn(),fn,tmpNodeCount);

  // allocate the memory
  *nodeList = _MALLOC( tmpNodeCount, struct GRid );

  // need to look up the expression from the current attrExp!


  // loop through the tmpNodeList and update it nodeList
  for(i = 0;i < tmpNodeCount;i++) {

    /* 
     *get the  expression evaluation results 
     */
    objectOE.obj_id = tmpNodeList[i];
    flag = FALSE;

    vdtr$GetDelimitedStr(impStr = attrExp,
                         outStr = buf,
                         delChr = ':',
                         posStr = 2);

    vd$exp_evaluate(flag     = &flag,
                    expName  = buf,
                    object   = &objectOE,
                    rgColl   = &rg_coll);
    if(traceFlag) {
      if(flag){
        printf("flag returned TRUE\n");
      }
      else{
        printf("flag returned FALSE\n");
      }
      
    }
    
    if(flag) {
      if(traceFlag) {
        vdtr$GetNodeType(nodeID = &tmpNodeList[i],
                         nodeType = nodeType);
        vdtr$GetNodeName(nodeID = &tmpNodeList[i],
                         nodeName = nodeName);
        printf("Adding node [%d] [%d] [%s %s] to list\n"
               ,tmpNodeList[i].osnum,tmpNodeList[i].objid,nodeName,nodeType);
      }
      
      (*nodeList)[*nodeCnt] = tmpNodeList[i];
      *nodeCnt = *nodeCnt + 1;
    }
  }

  retFlag = 1;
wrapup:
  // no memory leaks ever!
  _FREE( tmpNodeList );
  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}


/* -------------------------------------------------------------------------
 *
 * Function to get nodelists based on selection criterion and processes
 * I = nodePath 
 * I = nodeProcess ("INDEX") etc
 * I = nodeIndex
 * 0 = nodeList (list of nodes) Memory allocated behind this
 * 0 = nodeCnt  (count of nodes in list) 
 *
 * ------------------------------------------------------------------------- 
*/
IGRstat VDtrGetTreeObjectsByProcess(IGRchar *nodePath, IGRchar *nodeProcess, IGRchar *nodeIndex, TGRid **nodeList,IGRint *nodeCnt)
{
  VDASSERT_FN("VDtrGetTreeObjectsByProcess");
  IGRchar          indexType[128];
  IGRint           i,retFlag = 0;
  IGRstat          status = 0;

  struct GRid      rootNode,treeID;
  struct GRobj_env modelObj;

  // say hi
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn); 
  }
  // args check
  VDASSERTW(nodePath);
  VDASSERTW(nodeProcess);
  VDASSERTW(nodeIndex);
  
  // inits
  *nodeCnt = 0;
  *nodeList = NULL;
  VDstrupr(nodeProcess);
  /* get the rootNode */
  vdtr$GetNodeFromPath(nodePath = nodePath,
                       nodeID   = &rootNode,
                       treeID   = &treeID);
  if(rootNode.objid == NULL_OBJID) goto wrapup;

  /* call the process to get all the nodes */
  vdtr$GetTreeObjectsByProcessID(nodeID      = &rootNode,
                                 nodeProcess = nodeProcess,
                                 nodeIndex   = nodeIndex,
                                 nodeList    = nodeList, 
                                 nodeCnt     = nodeCnt);
 
  if((nodeCnt == 0) || (*nodeList == NULL)) goto wrapup;
 
  retFlag = 1;
  
wrapup:
  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}
/* -------------------------------------------------------------------------
 *
 * Function to get nodelists based on selection criterion and processes
 * I = nodePath 
 * I = nodeProcess ("INDEX") etc
 * I = nodeIndex
 * 0 = nodeList (list of nodes) Memory allocated behind this
 * 0 = nodeCnt  (count of nodes in list) 
 *
 * ------------------------------------------------------------------------- 
*/
IGRstat VDtrGetTreeObjectsByProcessID(TGRid *nodeID, IGRchar *nodeProcess, IGRchar *nodeIndex, TGRid **nodeList,IGRint *nodeCnt)
{
  VDASSERT_FN("VDtrGetTreeObjectsByProcessID");
  IGRchar          indexType[128];
  IGRint           i,retFlag = 0;
  IGRstat          status = 0;
  IGRint           tmpNodeCount = 0,
                   localNodeCount = 0;
  struct GRid      *tmpNodeList,rootNode,treeID;
  struct GRobj_env modelObj;
  
  // say hi
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn); 
  }
  // args check
  VDASSERTW(nodeID);
  VDASSERTW(nodeProcess);
  VDASSERTW(nodeIndex);
  if(nodeID->objid == NULL_OBJID) goto wrapup;
  // inits
  *nodeCnt = 0;
  *nodeList = NULL;
  tmpNodeList = NULL;
  VDstrupr(nodeProcess);

  rootNode.osnum = nodeID->osnum;
  rootNode.objid = nodeID->objid;
  if(rootNode.objid == NULL_OBJID) goto wrapup;

  // this value "part_list" is from the gadget on the form.
  if( !(strcmp(nodeProcess, "PART_LIST")) )
  {
    if(traceFlag) printf("+++>Call: vd$trget_nodes VDTR_FIND_CHILD_NODE nodeList\n");
    status = vd$trget_nodes( nodeID     = &rootNode,
                             lookupType = VDTR_FIND_CHILD_NODE,
                             outID      = nodeList,
                             cnt        = nodeCnt ) ;
    
    if( !( status & 1) || *nodeCnt <= 0 ) goto wrapup;
  }

    else if( !(strcmp(nodeProcess, "INDEX")) )
    {
      strcpy( indexType, nodeIndex );

      // See if it is a exp
      if (!strncmp(indexType,VDSA_KEY_SA_EXP,VDSA_KEY_SA_EXPn)) {
        //printf("Would have tired an expression here!\n");
        VDtrGetNodeListByEXP( &rootNode,indexType,nodeList,nodeCnt);
        if(traceFlag) printf("%s %s: nodeCnt [%d]\n",ffn(),fn,nodeCnt);
        
      }
      else {
        // it is not an expression so go get the data directly
        if(traceFlag) printf("+++>Call: vd$trget_nodes VDTR_FIND_ALL_NODE nodeList\n");
        status = vd$trget_nodes( nodeID     = &rootNode,
                                 nodeType   = indexType,
                                 lookupType = VDTR_FIND_ALL_NODE,
                                 outID      = nodeList,
                                 cnt 	  = nodeCnt ) ;
      }
      if( !(status & 1) || *nodeCnt <= 0 ) goto wrapup;
    }

    /**************************************************/
    else if( !(strcmp(nodeProcess, "MODEL_OBJ")) )
    {
      if(traceFlag) printf("+++>Call:  vd$trget_nodes VDTR_FIND_ALL_NODE tmpNodeList\n");
      status = vd$trget_nodes( nodeID     = &rootNode,
                               lookupType = VDTR_FIND_ALL_NODE,
			       outID      = &tmpNodeList,
                               cnt 	  = &tmpNodeCount ) ;

      if( !(status & 1) || tmpNodeCount <= 0 ) goto wrapup;

      if( tmpNodeCount > 0 )
      {
        if(traceFlag) printf("+++>Call: _MALLOC( nodeList\n");
        *nodeList = _MALLOC( tmpNodeCount, struct GRid );
        if( !(nodeList) ) goto wrapup;

        *nodeCnt = 0;
        for( i = 0 ; i < tmpNodeCount ; i++ )
        {
          if(traceFlag) printf("+++>Call: vd$trget_modelObject\n");
          status = vd$trget_modelObject( nodeID = &tmpNodeList[i],
	  			         objOE = &modelObj );
	  if( status && (modelObj.obj_id.objid != NULL_OBJID) )
          {
             (*nodeList)[*nodeCnt] = modelObj.obj_id;
 	    *nodeCnt = *nodeCnt + 1;
	  }
        }
        _FREE ( tmpNodeList );
      }
      else
	*nodeCnt = 0;
        if(*nodeCnt == 0) {
          _FREE( *nodeList );
        }
        
    } else if (!(strcmp(nodeProcess,"ITEM"))) {
      VDtvwGetItemList(nodeList,nodeCnt);
    }

  
  retFlag = 1;
  
wrapup:
  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}

/*****************************************************
 *
 * Tracking function to report the current Path
 * does not actually provide the path just prints
 * it out for tracking purposes.
 *
 *****************************************************/
IGRstat VDtrTrackPath(IGRchar *title)
{
  VDASSERT_FN("VDtrTrackPath");
  IGRstat  retFlag = 0;
  IGRchar  pwdName[DI_PATH_MAX];
  IGRstat  status = 0;
  

  // say hi
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn); 
  }

    /* get current directory */
    status = di$pwd( dirname = pwdName );
    if( status != DIR_S_SUCCESS ){
	printf(" Can't get current directory name \n");
	goto wrapup;
    }
    
    printf("\n************** %s ***************\n",title);
    printf("%s\n",pwdName);
    printf("****** END *** %s ***************\n\n",title);
    
    retFlag = 1;

wrapup:
  // say bye 


  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}

/*****************************************************
 *
 *  Just a  test
 *
 *****************************************************/
IGRstat VDtrGetTest()
{
  VDASSERT_FN("VDtrGetTest");
  IGRstat  retFlag = 0;
  IGRint   i,j,treeCnt,setCnt;
  TGRid   *treeList,*setList,childID,nodeID;
  TVDctxBaseInfo baseInfo;
  IGRchar  fileName[1023],nodeName[128];
  IGRint   xpos = 0;
  IGRint   ypos = 0;
  IGRint   accept = 0;
  IGRchar  filePaht[1023];
  IGRint   localDir = 1;
  IGRint   flag = 0;
  IGRchar  pwdPath[1023];
  IGRchar  filePath[1023];
  IGRint   selected = 0;
  TGRid    xslTreeID;
  TGRid    xmlTreeID;

  // say hi
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn); 
  }

  pwdPath[0] = '\0';
  filePath[0] = '\0';
  fileName[0] = '\0';

  /* set the fileName in this case */
  // strcpy(fileName,"plates_ad1.xml");

  // if(traceFlag) printf("\n\n Test OK [%s] \n\n",fileName);

  vdfile$BrowseFiles(Dir      = pwdPath,
		     Name     = fileName,
		     Path     = filePath,
		     Flag     = &flag,
		     Selected = &selected,
		     LocalDir = &localDir);
  if(traceFlag) printf("\n\n Test OK [%s] \n\n",filePath);
  /* open the xml file and make a dom tree */
  VDxdomCreateTreeFromXmlFile(filePath,&nodeID);

  vdfile$BrowseFiles(Dir      = pwdPath,
		     Name     = fileName,
		     Path     = filePath,
		     Flag     = &flag,
		     Selected = &selected,
		     LocalDir = &localDir);

  /* need to process the xsl and xml to make new xml tree */
  VDxdomCreateStyleSheetFromFile(filePath,&xslTreeID);
  VDxdomApplyStyleSheet(&xslTreeID,&nodeID,NULL,&xmlTreeID);
  if(nodeID.objid != NULL_OBJID)    VDxdomDeleteNode(&nodeID);
  if(xslTreeID.objid != NULL_OBJID) VDxdomDeleteStyleSheet(&xslTreeID);
  
  VDctxGetNodeName(&xmlTreeID,nodeName);
  printf("nodeName is [%s]\n",nodeName);
  
  
  /* feed the top node of this tree to TNS form */
  if(xmlTreeID.objid != NULL_OBJID) {
    if(traceFlag) printf("xmlTreeID [%d][%d]\n",xmlTreeID.osnum,xmlTreeID.objid);
    VDtvwCTBSStartItem(&xmlTreeID,&xpos,&ypos,&accept); 
    if(traceFlag) printf("TNS Done\n");
  } else {
    if(traceFlag) printf("the xmlTreeID was NULL \n");
  }
  
  VDxdomDeleteNode(&xmlTreeID);
  retFlag = 1;
  
wrapup:
  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}


/*****************************************************
 *
 *  Handle for PPL to do some work showing content of 
 *  XML files and etc
 *  zits
 *
 *****************************************************/
IGRstat VDtrXMLandXSLView()
{
  VDASSERT_FN("VDtrXMLandXSLView");
  IGRstat  retFlag = 0;
  IGRchar  prompt[1023], answer[1023],buf[1023],*p,*q;
  struct GRevent          event;
  IGRint   msg = 0;
  IGRint   sts = 1;
  IGRint   fxSts = 0;
  TGRid    xmlSchemaID,xslStyleSheetID,xmlOutSchemaID;
  IGRint   xpos = 0;
  IGRint   ypos = 0;
  IGRint   accept = 0;

  // say hi
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn); 
  }

  /* inits */
  xmlSchemaID.objid      == NULL_OBJID;
  xslStyleSheetID.objid  == NULL_OBJID;
  xmlOutSchemaID.objid   == NULL_OBJID;
  
  while(sts == 1) {
    strcpy(prompt,"Get XML file");
    sts = vdtr$GetCmdLineYNInput(prompt = prompt);  
    if(sts == 1) {
      /* respond to input and loop back on bad input */
      fxSts = VDtrGetXMLSchemaView(&xmlSchemaID);
      if(fxSts == 0) goto wrapup;
      fxSts = VDtrGetXSLStyleSheetView(&xmlSchemaID,&xslStyleSheetID);
      if(fxSts == 0) goto wrapup;
      VDxdomApplyStyleSheet(&xslStyleSheetID,&xmlSchemaID,NULL,&xmlOutSchemaID);
      if(vdtr$GetCmdLineYNInput(prompt = "Display XML File Created")) {
	strcpy(buf,"Display XML File Created");
	UI_status(buf);
	VDtvwCTBSStartItem(&xmlOutSchemaID,&xpos,&ypos,&accept); 
      }
      vdtr$SaveXMLTreeToFile(xmlID = &xmlOutSchemaID);
     
    }
    if(xmlSchemaID.objid != NULL_OBJID) {
      VDxdomDeleteNode(&xmlSchemaID);
      xmlSchemaID.objid = NULL_OBJID;
    }
    
    if(xslStyleSheetID.objid != NULL_OBJID) {
      VDxdomDeleteStyleSheet(&xslStyleSheetID);
      xslStyleSheetID.objid = NULL_OBJID;
    }
    
    if(xmlOutSchemaID.objid != NULL_OBJID) {
      VDxdomDeleteNode(&xmlOutSchemaID);
      xmlOutSchemaID.objid = NULL_OBJID;
    }
    
  }
  
  UI_status("Done");

  retFlag = 1;
  
wrapup:
  /* clean up the ID's */
    if(xmlSchemaID.objid != NULL_OBJID) {
      VDxdomDeleteNode(&xmlSchemaID);
      xmlSchemaID.objid = NULL_OBJID;
    }
    UI_status("Done");
    if(xslStyleSheetID.objid != NULL_OBJID) {
      VDxdomDeleteStyleSheet(&xslStyleSheetID);
      xslStyleSheetID.objid = NULL_OBJID;
    }
    
    if(xmlOutSchemaID.objid != NULL_OBJID) {
      VDxdomDeleteNode(&xmlOutSchemaID);
      xmlOutSchemaID.objid = NULL_OBJID;
    }
  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}

/*****************************************************
 *
 * Fetches a Yes/No answer and returns it as
 * No  == 0
 * Yes == 1
 * function return
 * input is the request string and it is always 
 * added with the Y/N? request.
 * accepts any input repeats until a correct return is 
 * made will compare case independent
 *
 *****************************************************/
IGRstat VDtrGetCmdLineYNInput(IGRchar *prompt)
{
  VDASSERT_FN("VDtrGetCmdLineYNInput");
  IGRstat  retFlag = 0;
  IGRstat  inputOK = 0;
  IGRchar  locPrompt[1023];
  IGRchar  answer[1023],*p;

  // say hi
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn); 
  }

  /* args check */
  if(!prompt) goto wrapup;
  if(!strcmp(prompt,"")) goto wrapup;

  /* inits */
  answer[0] = '\0';
  locPrompt[0] = '\0';
  
  /* make the prompt string */
  sprintf(locPrompt,"%s: Y/N?",prompt);
 
  while(inputOK == 0) {
    VDtrGetCmdLineInput(locPrompt,answer);
    p = answer;
    if((*p == 'y') || (*p == 'Y')) {
      retFlag = 1;
      inputOK = 1;
    }
    if((*p == 'n') || (*p == 'N')) {
      inputOK = 1;
    }
  }

wrapup:
  // say bye 


  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}

/*****************************************************
 *
 * Get the Input from the command line on the I/VDS
 * screen
 *
 *****************************************************/
IGRstat VDtrGetCmdLineInput(IGRchar *prompt, IGRchar *answer)
{
  VDASSERT_FN("VDtrGetCmdLineInput");
  IGRstat  retFlag = 0, response;
  IGRchar  response_data[1024];
  IGRint   accept = 0;
  struct GRevent          event;
  IGRint   msg = 0;
  IGRint   loopSts = 0;

  // say hi
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn); 
  }

  /* args check */
  if(!prompt) goto wrapup;
  if(!strcmp(prompt,"")) goto wrapup;
  if(!answer) goto wrapup;

  /* loop around until there is some input */
  while(loopSts == 0) {
    /* notify the user chose browse or input */
    co$getevent (msg = &msg,
		 event_mask = GRm_STRING,
		 prompt = prompt,
		 response = &response,
		 response_data = response_data,
		 event = &event );

    strcpy(answer,event.event.keyin);
    loopSts = strcmp(answer,"");
  }

  retFlag = 1;
  
wrapup:
  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}

/*****************************************************
 *
 * Start browsing for XML/XSL files etc
 *
 *****************************************************/
IGRstat VDtrGetXMLSchemaView(TGRid *xmlSchemaID)
{
  VDASSERT_FN("VDtrGetXMLSchemaView");
  IGRstat  retFlag = 0;
  IGRchar  prompt[1023],pwdPath[1023];
  IGRchar  xmlName[1023],xslName[1023],xmlSchema[1023];
  IGRchar  *p;
  IGRchar  buf[1023];
  IGRint   flag = 0;
  IGRint   selected = 1;
  IGRint   localDir = 1;
  IGRint   sts = 0;
  IGRint   xpos = 0;
  IGRint   ypos = 0;
  IGRint   accept = 0;

  // say hi
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn); 
  }

  /* checks */
  VDASSERTW(xmlSchemaID);

  /* inits */
  pwdPath[0]            = '\0';
  xmlName[0]            = '\0';
  xslName[0]            = '\0';
  buf[0]                = '\0';
  xmlSchemaID->objid    = NULL_OBJID;

top:
  /* start looking for an xml file with the browser */
  UI_status("Browsing for XML files");
  vdfile$BrowseFiles(Dir      = pwdPath,
		     Name     = xmlName,
		     Path     = xmlSchema,
		     Flag     = &flag,
		     Selected = &selected,
		     LocalDir = &localDir);
  if(selected == 0) goto wrapup;
  if(selected == 1) {
    p = strstr(xmlSchema,".xml");
    if(p == NULL) goto top;
    if(strcmp(p,".xml")) goto top;
    VDxdomCreateTreeFromXmlFile(xmlSchema,xmlSchemaID);
    if(xmlSchemaID->objid == NULL_OBJID) goto top;
    sprintf(buf,"Selected: %s File",xmlName);
    UI_status(buf);

    sprintf(prompt,"View this %s File",xmlName);
    sts = vdtr$GetCmdLineYNInput(prompt = prompt);
    if(sts == 1) {
      /* display the TNS form with the stuff in it */
      UI_status("Selected XML File");
      VDtvwCTBSStartItem(xmlSchemaID,&xpos,&ypos,&accept);
    }
  }
  
  /* check if we are done */
  strcpy(prompt,"Get different XML File");
  if(vdtr$GetCmdLineYNInput(prompt = prompt)) {
    /* free the xmlSchemaID and clear stuff up */
    if(xmlSchemaID->objid != NULL_OBJID) {
      VDxdomDeleteNode(xmlSchemaID);
      xmlSchemaID->objid = NULL_OBJID;
    }
    goto top;
  } 
 

wrapup:
  // say bye 

  if(xmlSchemaID->objid != NULL_OBJID) retFlag = 1;
  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}

/*****************************************************
 *
 * Start browsing for XSL files etc
 *
 *****************************************************/
IGRstat VDtrGetXSLStyleSheetView(TGRid *xmlSchemaID,TGRid *xslStyleSheetID)
{
  VDASSERT_FN("VDtrGetXSLStyleSheetView");
  IGRstat  retFlag = 0;
  IGRchar  prompt[1023],pwdPath[1023];
  IGRchar  xslName[1023],xslStyleSheet[1023];
  IGRchar  insideXSL[1023];
  IGRchar  *p,*q;
  IGRchar **instList;
  IGRint   instListCnt;
  IGRchar  buf[1023];
  IGRint   flag = 0;
  IGRint   selected = 1;
  IGRint   localDir = 1;
  IGRint   sts = 0;
  IGRint   xpos = 0;
  IGRint   ypos = 0;
  IGRint   accept = 0;
  IGRint   i;

  // say hi
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn); 
  }

  /* checks */
  VDASSERTW(xslStyleSheetID);

  /* init */
  insideXSL[0] = '\0';

  if(traceFlag) printf("\n\n\n\nxmlSchemaID[%d][%d]\n",
		       xmlSchemaID->osnum,xmlSchemaID->objid);

  /* fetch the style sheet info from the xml tree */
  if(xmlSchemaID) {
    xslStyleSheetID->objid = NULL_OBJID;
    vdtr$GetDocStyleSheetID(xmlID  = xmlSchemaID,
			    filter = "ISDP-stylesheet",
			    xslID  = xslStyleSheetID);

  }
  if(xslStyleSheetID->objid != NULL_OBJID) {
    if(vdtr$GetCmdLineYNInput(prompt = "Use Internal StyleSheet(.xsl)" )) {
      goto wrapup;
    }
  }
  
  if(xslStyleSheetID->objid != NULL_OBJID) {
    VDxdomDeleteNode(xslStyleSheetID);
    xslStyleSheetID->objid = NULL_OBJID;
  }
  


  /* inits */
  pwdPath[0]            = '\0';
  xslName[0]            = '\0';
  xslStyleSheet[0]      = '\0';
  buf[0]                = '\0';
  xslStyleSheetID->objid    = NULL_OBJID;

  

top:

  /* start looking for an xml file with the browser */
  UI_status("Browsing for xsl files");
  vdfile$BrowseFiles(Dir      = pwdPath,
		     Name     = xslName,
		     Path     = xslStyleSheet,
		     Flag     = &flag,
		     Selected = &selected,
		     LocalDir = &localDir);
  
  if(selected == 1) {
    p = strstr(xslStyleSheet,".xsl");
    if(p == NULL) goto top;
    if(strcmp(p,".xsl")) goto top;
    VDxdomCreateStyleSheetFromFile(xslStyleSheet,xslStyleSheetID);
    if(xslStyleSheetID->objid == NULL_OBJID) goto wrapup;
    // strcpy(prompt,"View this xsl StyleSheet");
    sprintf(buf,"Selected: %s StyleSheet",xslName);
    UI_status(buf);
  }


  /* check if we are done */
  sprintf(buf,"Selected: %s StyleSheet",xslName);
    UI_status(buf);
    strcpy(prompt,"Get a different StyleSheet");
  if(vdtr$GetCmdLineYNInput(prompt = prompt)) {
    /* free the xslStyleSheetID and clear stuff up */
    if(xslStyleSheetID->objid != NULL_OBJID) {
      VDxdomDeleteNode(xslStyleSheetID);
      xslStyleSheetID->objid = NULL_OBJID;
    }
    goto top;
  }
  
 

wrapup:
  // say bye 
  if(xslStyleSheetID->objid != NULL_OBJID) retFlag = 1;

  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}

/*****************************************************
 *
 * Get Processing instructions from an xml Document 
 *
 *****************************************************/
IGRstat VDtrGetXMLProcInstDoc(TGRid     *nodeID,
			      IGRchar   *filter,
			      IGRchar ***instList,
			      IGRint    *instListCnt)
{
  VDASSERT_FN("VDtrGetXMLProcInstDoc");
  IGRstat  retFlag = 0;
  IGRint   i,j;
  IGRchar  *buf,nodeType[128];
  TGRid    piID;

  // say hi
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn); 
  }

  /* args and cleanup always start with a new list */
  if(!instList) goto wrapup;
  VDASSERTW(nodeID);
  if(nodeID->objid == NULL_OBJID) goto wrapup;
  if(*instListCnt > 0) {
    _LOOPFREE( *instList,*instListCnt );
  }
  *instListCnt = 0;
  /* inits */
  nodeType[0] = '\0';
  if(traceFlag) printf("getting it \n");

  /* loop through and start getting the piID nodes */
  i = 0;
  VDctxGetNthDocPI(nodeID,i,&piID);
  if(traceFlag) printf("piID[%d] [%d][%d]\n",i,piID.osnum,piID.objid);

  while(piID.objid != NULL_OBJID) {
    
    if(filter) {
      
      VDctxGetNodeType(&piID,nodeType);
      if(!strcmp(nodeType,filter)) {
	VDctxGetContent(&piID,&buf);
	
	vdtvw$AddStrList(item    = buf,
			 List    = instList,
			 ListCnt = instListCnt);
	
	
      }
    } else {
      VDctxGetContent(&piID,&buf);     
      vdtvw$AddStrList(item    = buf,
		       List    = instList,
		       ListCnt = instListCnt);     
    }
  
  
    
    i++;
    VDctxGetNthDocPI(nodeID,i,&piID);
    if(traceFlag) printf("piID[%d] [%d][%d]\n",i,piID.osnum,piID.objid);
  }
  
  
  retFlag = 1;



wrapup:
  if(traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  return retFlag;
}


/*****************************************************
 *
 * Get Processing instructions from an xml Document 
 *
 *****************************************************/
IGRstat VDtrGetXMLProcInstNode(TGRid     *nodeID,
			       IGRchar   *filter,
			       IGRchar ***instList,
			       IGRint    *instListCnt)
{
  VDASSERT_FN("VDtrGetXMLProcInstNode");
  IGRstat  retFlag = 0;
  IGRint   i,j;
  IGRchar  *buf,nodeType[128];
  TGRid    piID;

  // say hi
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn); 
  }

  /* args and cleanup always start with a new list */
  if(!instList) goto wrapup;
  VDASSERTW(nodeID);
  if(nodeID->objid == NULL_OBJID) goto wrapup;
  if(*instListCnt > 0) {
    _LOOPFREE( *instList,*instListCnt );
  }
  *instListCnt = 0;
  /* inits */
  nodeType[0] = '\0';
  if(traceFlag) printf("getting it \n");

  /* loop through and start getting the piID nodes */
  i = 0;
  VDctxGetNthNodePI(nodeID,i,&piID);
  if(traceFlag) printf("piID[%d] [%d][%d]\n",i,piID.osnum,piID.objid);

  while(piID.objid != NULL_OBJID) {
    
    if(filter) {
      
      VDctxGetNodeType(&piID,nodeType);
      if(!strcmp(nodeType,filter)) {
	VDctxGetContent(&piID,&buf);
	
	vdtvw$AddStrList(item    = buf,
			 List    = instList,
			 ListCnt = instListCnt);
	
	
      }
    } else {
      VDctxGetContent(&piID,&buf);     
      vdtvw$AddStrList(item    = buf,
		       List    = instList,
		       ListCnt = instListCnt);     
    }
  
  
    
    i++;
    VDctxGetNthNodePI(nodeID,i,&piID);
    if(traceFlag) printf("piID[%d] [%d][%d]\n",i,piID.osnum,piID.objid);
  }
  
  
  retFlag = 1;



wrapup:
  // say bye 


  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
  
}

/*****************************************************
 *
 * Get a document level xsl style sheet ID 
 * if one exists 
 *
 *****************************************************/
IGRstat VDtrGetDocStyleSheetID(TGRid   *xmlID,
			       IGRchar *filter,
			       TGRid   *xslID,
			       IGRchar *xslSS)
{
  VDASSERT_FN("VDtrGetDocStyleSheetID");
  IGRstat    retFlag = 0;
  IGRchar **instList;
  IGRchar   buf[1023],type[1023],href[1023];
  IGRchar  *p,*q,*r;
  IGRint    instListCnt = 0;
  IGRint    i;

  // say hi
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn); 
  }
  /* some inits */
  VDASSERTW(xslID);
  /* make sure this node is NULL! */
  if(xslID->objid != NULL_OBJID) {
    VDxdomDeleteNode(xslID);
    xslID->objid = NULL_OBJID;
  }
  buf[0]  = '\0';
  type[0] = '\0'; 
  href[0] = '\0'; 
  if(xslSS) xslSS[0] = '\0'; 
  

  /* some args checks */
  VDASSERTW(xmlID);
  if(xmlID->objid == NULL_OBJID) goto wrapup;
  VDASSERTW(filter);
  if( !VD_wordcount( filter ) ) goto wrapup;
  
  /* now lets fetch the ISDP-stylesheet stuff */
  vdtr$GetXMLProcInstDoc(nodeID      = xmlID,
			 filter      = filter,
			 instList    = &instList,
			 instListCnt = &instListCnt);

  if(instListCnt < 1) goto wrapup;
  
  for(i = 0;i < instListCnt;i++) {
    p = NULL;
    q = NULL;
    strcpy(buf,instList[i]);
    p = strstr(buf,"type");
    q = strstr(buf,"href");
    if(p == NULL) continue;
    if(q == NULL) continue;
    if((!(p == NULL)) && (!(q == NULL))){
      
      vdtr$GetDelimitedStr(impStr = p,
			   outStr = type,
			   delChr = '"',
			   posStr = 2); 
      
      vdtr$GetDelimitedStr(impStr = q,
			   outStr = href,
			   delChr = '"',
			   posStr = 2); 
      if(strcmp(type,"text/xsl")) goto wrapup;
      r = NULL;
      r = strstr(href,".xsl");
      if(r == NULL) goto wrapup;
      break;
    }
  }
  /* some final checks */
  if(p == NULL) goto wrapup;
  if(q == NULL) goto wrapup;
  
  /* fetch the xslID */
  VDxdomCreateStyleSheetFromFile(href,xslID);
  if(xslID->objid == NULL_OBJID) goto wrapup;
  
  if(xslSS) {
    strcpy(xslSS,href);
  }
  
  
  retFlag = 1;


wrapup:
  /* instList cleanup */
  if(instListCnt > 0) _LOOPFREE( instList,instListCnt );
  
  // say bye 


  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}
/*****************************************************
 *
 * Save an XML tree to file with  prompts for correctness
 * checks to get the file name and such
 *
 *****************************************************/
IGRstat VDtrSaveXMLTreeToFile(TGRid *xmlID)
{
  VDASSERT_FN("VDtrSaveXMLTreeToFile");
  IGRstat  retFlag = 0;
  IGRstat  loopOK = 0;
  IGRchar  answer[1023],buf[1023],*p,*q;
  IGRint   sts = 0;
  
  retFlag = 1;
  
  // say hi
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn); 
  }
  /* validate the input */
  if(!xmlID) goto wrapup;
  if(xmlID->objid == NULL_OBJID) goto wrapup;
  
  /* begin by asking if you want to save this file */
  if(vdtr$GetCmdLineYNInput(prompt = "Save Created XML File")) {
    while(loopOK == 0) {
      vdtr$GetCmdLineInput(prompt = "Enter File Name",
			   answer = answer);
      
      if(strlen(answer) < 1) {
	if(vdtr$GetCmdLineYNInput(prompt = "Exit without Save")) {
	  goto wrapup;
	}
      } else {
	/* validate the file name */ 
	p = NULL;
	q = NULL;
	p = strrchr(answer,'.');
	if(p == NULL) {
	  /* this is the case of there is not extension definition on the file */
	  strcpy(buf,answer);
	  sprintf(answer,"%s.xml",buf);
	  q = strrchr(answer,'/');
	  if(q == NULL){
	    if(strlen(answer) < 14) loopOK = 1;
	  } else {
	    if(strlen(q) < 13) loopOK = 1;
	  }
	} else {
	  /* this is the case of an extension definition on the file */
	  if(!strcmp(p,".xml")) loopOK = 1;
	}
	if(loopOK == 0) UI_status("Reenter The File Name");
      }
    }
  }

  p = strstr(answer,".xml");
  if(p == NULL) {
    UI_status("File not Saved");
    goto wrapup;
  }
  
  /* show file name and ask for confirm for save */
  sprintf(buf,"Save File %s",answer);
  if(vdtr$GetCmdLineYNInput(prompt = buf)) {
    VDctxSaveTreeToXmlFile(xmlID,answer);
  }
  

  
  retFlag = 1;
wrapup:
  // say bye 
  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}
end implementation Root;


#if 0
/*****************************************************
 *
 * Generic Basic Function Format for copy only
 *
 *****************************************************/
IGRstat VDtrGet()
{
  VDASSERT_FN("VDtrGet");
  IGRstat  retFlag = 0;

  // say hi
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn); 
  }


wrapup:
  // say bye 


  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}
#endif

