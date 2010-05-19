/* Id: vdct1set.I 1.1 1999/06/29 18:28:52 pinnacle Exp $  */
/***************************************************************************
 * I/VDS
 *
 * File:        vdct1/set/VDct1Set.I
 *
 * Description: Set Routines
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDct1Set.C,v $
 *      Revision 1.7  2001/10/18 20:49:05  ahundiak
 *      ah
 *
 *      Revision 1.6  2001/03/19 20:29:41  paul_noel
 *      Fix compiler "off" on VDct1Set  1st procedure
 *
 *      Revision 1.5  2001/03/12 20:36:52  jdsauby
 *      Cleaned out unnecessary functions from vdct1/set
 *
 *      Revision 1.4  2001/03/06 15:52:47  ahundiak
 *      ah
 *
 *      Revision 1.3  2001/01/14 16:27:15  art
 *      sp merge
 *
 *      Revision 1.2  2001/01/12 15:46:30  art
 *      sp merge
 *
 *      Revision 1.1  2001/01/12 14:53:35  art
 *      sp merge
 *
 * Revision 1.1  2000/07/25  18:38:22  pinnacle
 * ah
 *
# Revision 1.7  2000/07/24  20:51:58  pinnacle
# ah
#
# Revision 1.6  2000/07/17  20:52:26  pinnacle
# ah
#
# Revision 1.5  2000/07/14  19:09:58  pinnacle
# pn
#
# Revision 1.4  2000/06/30  18:57:12  pinnacle
# pn
#
# Revision 1.1  1999/05/30  14:27:28  pinnacle
# ct
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 05/29/99  ah      Creation
 * 12/16/99  pn      Updated Prototypes in VDct1.h
 * 05/11/00  pn      Updated VDct1.h and Altered Attributes Access
 *                   Includes several PPL wrappers
 * 07/17/00  ah      Tree Interface
 * 01/13/01  ah      sp17, dom VDct1GetSetTree
 * 03/06/01  ah      Moved VDct1GetNodeRange from cmd object
 ***************************************************************************/

#include "VDct1.h"
#include "VDct1Tree.h"

#include "VDobj.h"
#include "VDdir.h"
#include "VDppl1.h"
 
#include "VDassert.h"

VDASSERT_FFN("vdct1/set/VDct1Set.C");

/* ----------------------------------------------------------------
 * Get the range of the objects..
 */
IGRstat VDct1GetNodeRange( TGRid *nodeID, GRrange objRange )
{
  TGRobj_env modelOE;
  IGRint  sts,msg;
  
  /*
   * Check if object is fine ...
   */


  if( ! nodeID ) goto wrapup ;
  if( nodeID->objid == NULL_OBJID ) goto wrapup;
  objRange[0] = objRange[1] = objRange[2] = 0.0;
  objRange[3] = objRange[4] = objRange[5] = 0.0;
  

  /*
   * get model objects from the node.
   */
    // Make sure don't already have a model
  vdct1$GetNodeModelObject(nodeID  = nodeID,
			   modelOE = &modelOE);
  
  if (modelOE.obj_id.objid == NULL_OBJID) {

    goto wrapup;
  }

  sts = VD_getRangeOfComposite( &msg, &modelOE, objRange );
  if( !(sts & msg & 1)) goto wrapup ;

  return MSSUCC ;
  
wrapup:
  return MSFAIL;
}

/* ----------------------------------------
 * Recursive routine to return the root treenode 
 * to which a node belongs
 *
 * 12 Jan 2000 - ah
 * Moved from vdct1/cmd, called from tools directory
 * There should be another routine already that does this
 */
IGRstat VDct1GetTreeTopForNode(TGRid *nodeID, TGRid *treeID)
{
  IGRstat retFlag = 0;
  TGRid   parentID;
  
  // Arg check
  if (treeID == NULL) goto wrapup;
  treeID->objid = NULL_OBJID;
  
  if (nodeID == NULL) goto wrapup;
  if (nodeID->objid == NULL_OBJID) goto wrapup;
  if (nodeID->objid == 0)          goto wrapup;
  
  // Get its parent
  vdct1$GetTree1Parent(objID = nodeID, outID = &parentID);
  if (parentID.objid = NULL_OBJID) {
    *treeID = *nodeID;
    retFlag = 1;
    goto wrapup;
  }
  
  // Recurse up
  retFlag = vdct1$GetTreeTopForNode(nodeID = &parentID,
				    treeID = treeID);
  
  
wrapup:
  return retFlag;
}
#if 0
/* ---------------------------------------------------------------------------
 * PPL wrapper for test to control check if part must be in ops
 * defaults no (if ppl not found)
 */
IGRstat VDct1MustPartBeInOPS(TGRid *nodeID)
{  
  TGRid         pplID;
  IGRint        pplRet;
  TVDctBaseInfo baseInfo;
  IGRstat       sts       = 0; 
  IGRint        traceFlag = 0;

  // say hi
  if(traceFlag) printf(">>> VDct1MustPartBeInOPS()\n");

  // arg check
  if(nodeID == NULL) goto wrapup;

  // get baseInfo for nodeID;
  vdct1$GetBaseInfo(objID = nodeID, baseInfo = &baseInfo);
  if(*baseInfo.setType == 0) goto wrapup;

 // The ppl does the work
  vdppl$Load(name = baseInfo.setType, pplID = &pplID);
  if (pplID.objid == NULL_OBJID) goto wrapup;

 // set the data
  vdppl$SetData(pplID = &pplID,
                name  = "ACTION_OK",
                size  = sizeof(IGRstat),
                data  = (IGRchar*)&sts);

  // run the ppl
  vdppl$Run(pplID = &pplID, 
	    name  = "mustPartBeInOPS",
	    ret   = &pplRet);

  // get the data from the ppl
  vdppl$GetData(pplID = &pplID,
                name  = "ACTION_OK",
                size  = sizeof(IGRstat),
                data  = (IGRchar*)&sts);
  
  // oh well
wrapup:
  // say bye
  if(traceFlag) printf("<<< VDct1MustPartBeInOPS(%d)\n",sts);
  return sts;
}

 // -----------------------------------------------------------------------  
// wrapper for ppl rules
IGRstat VDct1TreeMakeAName(TGRid         *a_activeNodeID,
			   TVDctBaseInfo *a_baseInfo, 
			   IGRchar       *a_location)
{
  TGRid   pplID;
  IGRint  pplRet;

  TVDctBaseInfo parentBaseInfo;
  IGRstat sts = 0; 
  IGRchar location[128];
  IGRint  traceFlag = 0;
  
  // The ppl does the work
  vdppl$Load(name = a_baseInfo->setType, pplID = &pplID);
  if (pplID.objid == NULL_OBJID) goto wrapup;

  // set the data
  vdppl$SetData(pplID = &pplID,
                name  = "ACTION_OK",
                size  = sizeof(IGRstat),
                data  = (IGRchar*)&sts);

  vdppl$SetData(pplID = &pplID,
                name  = "NODE_ID",
                size  = sizeof(TGRid),
                data  = (IGRchar*)a_activeNodeID);


  vdppl$SetData(pplID = &pplID,
                name  = "BASE_INFO",
                size  = sizeof(TVDctBaseInfo),
                data  = (IGRchar*)a_baseInfo);

  strcpy(location,a_location);
  vdppl$SetData(pplID = &pplID,
                name  = "LOCATION",
                size  = 128,
                data  = a_location);

  // run the ppl
  vdppl$Run(pplID = &pplID, 
	    name  = "treeMakeAName",
	    ret   = &pplRet);

  // get the data from the ppl
  vdppl$GetData(pplID = &pplID,
                name  = "ACTION_OK",
                size  = sizeof(IGRstat),
                data  = (IGRchar*)&sts);
 
  vdppl$GetData(pplID = &pplID,
                name  = "BASE_INFO",
                size  = sizeof(TVDctBaseInfo),
                data  = (IGRchar*)a_baseInfo);
  
wrapup:
  if (traceFlag) printf("Leaving TreeMakeAName(%d)\n",sts);
  
  return sts;
  
}
/* ----------------------------------------------------
 * Checks if the first letter is a <= (str) <= Z or 0 <= (str) <= 9
 */
IGRstat VDct1IsFirstLetterOK(IGRchar *test)
{
  IGRstat     retFlag    = 0;
  IGRstat     traceFlag = 0;
  
  IGRchar     buf[128];
  
  // say hi
  if (traceFlag) printf(">>> VDct1IsFirstLetterOK\n");
  
  // copy it in
  strcpy(buf,test);
  
  // if NULL
  if (!strcmp(buf,"")){
    if (traceFlag) printf("Failed empty string test\n");
    goto wrapup;
  }
  
  // Test it
  if (traceFlag) printf("This is buf = %s\n",buf);
  
  if (( buf[0] < 'A') || (buf[0] > 'Z')) {  
    if (( buf[0] < 'a') || (buf[0] > 'z')) {   
      if(( buf[0] < '0') || (buf[0] > '9')) {
	goto wrapup;
      }
    }
  }
  
  // success
  retFlag = 1;
  
  // oh well
wrapup:

  //say bye
  if (traceFlag) printf("<<< VDct1IsFirstLetterOK %d\n",retFlag);
  return retFlag;
  
}
#endif
/* ------------------------------------------------------
 * Gets the tree from the set
 * DOM Adjusted
 */
IGRstat VDct1GetSetTree(TGRid *setID,
			TGRid *treeID)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  
  // Arg check
  if (setID  == NULL) goto wrapup;
  if (treeID == NULL) goto wrapup;
  treeID->objid = NULL_OBJID;
  
  // For now, only child is a tree
  vdct1$GetMgrChild(objID = setID,outID = treeID);
  
  if (treeID->objid == NULL_OBJID) goto wrapup;

  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* ------------------------------------------------------
 * Creates a new set
 */
#argsused
IGRstat VDct1CreateSet(TGRid   *mgrID,
                       IGRchar *setType,
                       IGRchar *setTypeRev,
                       IGRchar *setName,
                       TGRid   *setID)
{
  IGRstat retFlag = 0;
  TGRid   pplID;
  IGRint  pplRet;
  IGRstat traceFlag = 0;
  
  TVDctSetTypeRev setTypeRevx;

  TVDct1JD mgrJD,setJD;
  
  // Arg check
  if (setID == NULL) goto wrapup; 
  setID->objid = NULL_OBJID;
  if ((mgrID == NULL) || (mgrID->objid == NULL_OBJID)) goto wrapup;
  if ((setType == NULL) || (*setType == 0)) goto wrapup;
  if ((setName == NULL) || (*setName == 0)) goto wrapup;

  if (traceFlag) {
    printf(">>> VDct1CreateSet %s %s\n",setType,setName);
  }

  // Tree interface
  mgrJD.cl = VDct1GetTreeClassForSetType(setType);
  if (mgrJD.cl) {
    mgrJD.id = *mgrID;
    setJD.id.objid = NULL_OBJID;
    _RTCJDB(&mgrJD)->createSet(&mgrJD,setType,setTypeRev,setName,&setJD);
    *setID = setJD.id;
    return 1;
  }

  // The ppl does the work
  vdppl$Load(name = setType, pplID = &pplID);
  if (pplID.objid == NULL_OBJID) goto wrapup;

  vdppl$SetData(pplID = &pplID,
                name  = "MGR_ID",
                size  = sizeof(TGRid),
                data  = (IGRchar*)mgrID);

  vdppl$SetData(pplID = &pplID,
                name  = "SET_TYPE",
                size  = sizeof(TVDctSetType),
                data  = setType);

  if (setTypeRev) strcpy(setTypeRevx,setTypeRev);
  else            strcpy(setTypeRevx,"");
  
  vdppl$SetData(pplID = &pplID,
                name  = "SET_TYPE_REV",
                size  = sizeof(TVDctSetTypeRev),
                data  = setTypeRevx);

  vdppl$SetData(pplID = &pplID,
                name  = "SET_NAME",
                size  = sizeof(TVDctSetName),
                data  = setName);
  
  vdppl$Run(pplID = &pplID, name = "createSet", ret = &pplRet);

  vdppl$GetData(pplID = &pplID,
                name  = "SET_ID",
                size  = sizeof(TGRid),
                data  = (IGRchar*)setID);

  if (traceFlag) vdobj$Print(objID = setID);

  if (setID->objid == NULL_OBJID) goto wrapup;

  // Done
  retFlag = 1;

wrapup:
  if (traceFlag) {
    printf("<<< VDct1CreateSet %d\n",retFlag);
  }
  return retFlag;
}
#if 0
/* ---------------------------------------------------
 * Gets the set type information for a given set type
 */
IGRstat VDct1GetSetTypeInfo(IGRchar *setType, TVDctSetTypeInfo *setTypeInfo)
{
  IGRstat retFlag = 0;

  TGRid  pplID;
  IGRint pplRet;

  TVDct1JD setJD;
  
  // Arg check
  if (setTypeInfo == NULL) goto wrapup;
  memset(setTypeInfo,0,sizeof(TVDctSetTypeInfo));
  if ((setType == NULL) || (*setType == 0)) goto wrapup;

  // Tree interface
  setJD.cl = VDct1GetTreeClassForSetType(setType);
  if (setJD.cl) {
    setJD.id.objid = NULL_OBJID;
    _RTCJDB(&setJD)->getSetTypeInfo(&setJD,setTypeInfo);
    return 1;
  }

  // Open ppl
  vdppl$Load(name = setType, pplID = &pplID);
  if (pplID.objid == NULL_OBJID) goto wrapup;

  // Do It
  vdppl$Run(pplID = &pplID, name = "getSetTypeInfo", ret = &pplRet);

  // Pull results
  vdppl$GetData(pplID = &pplID,
                name  = "SET_TYPE_INFO",
                size  = sizeof(TVDctSetTypeInfo),
                data  = (IGRchar*)setTypeInfo);

  // Done
  retFlag = 1;

wrapup:
  return retFlag;
}
#endif

/* ---------------------------------------------------------------
 * Finds the set and or tree by searching through all
 * os's for it
 *
 * Not case sensitive
 */
IGRstat VDct1FindSetByName(TVDctBaseInfo *a_baseInfo,
			   TGRid         *a_setID,
			   TGRid         *a_treeID)
{
  IGRstat retFlag = 0;
  VDosnum osnum;
  IGRint  i;
  
  TGRid mgrID,setID,treeID;
  TVDctBaseInfo baseInfo;
  TVDctBaseInfo baseInfox;
  
  // Arg check
  if (a_setID)  a_setID->objid  = NULL_OBJID;
  if (a_treeID) a_treeID->objid = NULL_OBJID;
  if (a_baseInfo == NULL) goto wrapup;
  
  // Upper case checking
  strcpy(baseInfox.setType,a_baseInfo->setType);
  strcpy(baseInfox.setName,a_baseInfo->setName);
  VDstrupr(baseInfox.setType);
  VDstrupr(baseInfox.setName);
  
  // Cycle through each os
  for(osnum = 0; vdos$Validate(osnum = osnum); osnum++) {

    // Grab the manager
    vdct1$GetManager(osnum = osnum, mgrID = &mgrID);
    if (mgrID.objid != NULL_OBJID) {
      
      // Cycle through each set
      for(i = 0; vdct1$GetMgrChild(objID = &mgrID, nth = i, outID = &setID); i++) {
	
	// Filter by set type
	vdct1$GetBaseInfo(objID = &setID, baseInfo = &baseInfo);
	VDstrupr(baseInfo.setType);
	VDstrupr(baseInfo.setName);
	if ((!strcmp(baseInfox.setType,baseInfo.setType)) &&
	    (!strcmp(baseInfox.setName,baseInfo.setName))) {
	  
	  // Get the real tree
	  vdct1$GetMgrChild(objID = &setID, nth = 0, outID = &treeID);

	  // Return the ids
	  if (a_setID)  *a_setID  = setID;
	  if (a_treeID) *a_treeID = treeID;
	  retFlag = 1;
	  goto wrapup;
	}
      }
    }
  }
  

  // Done
wrapup:
  return retFlag;
}


/* ------------------------------------------------------
 * Return the treeID for the top of the tree
 */

IGRstat VDct1GetTreeForNode(TGRid *nodeID, TGRid *treeID)
  {
    TGRid parentID;    IGRstat retFlag = 0;
    IGRstat traceFlag = 0;
    
    
    // get parentID
    vdct1$GetTree1Parent(objID = nodeID,
			 outID = &parentID);
 

    // are we at the top node?  if so get out of here
    if (parentID.objid == NULL_OBJID) {
      
      // got it!
      *treeID = *nodeID;
      retFlag = 1;
      goto wrapup;
    }
    if (traceFlag){
      printf(">>> going to VDct1GetTreeForNode \n\n");
    }
    
    // well we had better check again
    
    vdct1$GetTreeForNode(nodeID = &parentID,
			 treeID = treeID); 

    //oh well
  wrapup:
    return retFlag;
    
  }

// end of IGRstat VDct1GetTreeForNode(TGRid *nodeID, TGRid *treeID)






