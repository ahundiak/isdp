 /* $Id: VDct1Node.C,v 1.4 2001/03/12 20:36:50 jdsauby Exp $  */
/***************************************************************************
 * I/VDS
 *
 * File:        vdct1/set/VDct1Node.I
 *
 * Description: Set Routines
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDct1Node.C,v $
 *      Revision 1.4  2001/03/12 20:36:50  jdsauby
 *      Cleaned out unnecessary functions from vdct1/set
 *
 *      Revision 1.3  2001/01/23 14:00:05  ahundiak
 *      mixup
 *
 *      Revision 1.1  2001/01/12 14:53:35  art
 *      sp merge
 *
 * Revision 1.3  2000/08/24  13:48:16  pinnacle
 * ah
 *
 * Revision 1.2  2000/08/04  19:35:34  pinnacle
 * js
 *
 * Revision 1.1  2000/07/25  18:38:22  pinnacle
 * ah
 *
# Revision 1.18  2000/07/20  13:28:18  pinnacle
# ah
#
# Revision 1.17  2000/07/18  19:32:20  pinnacle
# ah
#
# Revision 1.16  2000/07/17  20:52:26  pinnacle
# ah
#
# Revision 1.15  2000/07/14  20:24:22  pinnacle
# pn
#
# Revision 1.14  2000/07/12  11:19:48  pinnacle
# pn
#
# Revision 1.13  2000/07/06  15:49:14  pinnacle
# pn
#
# Revision 1.9  2000/06/05  21:00:28  pinnacle
# ah
#
# Revision 1.1  1999/06/29  18:28:52  pinnacle
# ct
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 06/17/99  ah      Creation
 * 12/16/99  pn      Update Prototypes in VDct1.h
 * 05/23/00  pn      added several ppl wrappers (and their prototypes in VDct1.h)
 *                   for the Freeze and Revise Process
 * 05/31/00  pn      several ppl wrappers associated with the Tree/Lib view
 *                   controls added
 * 06/02/00  ah      PPL wrapper for getPartNum
 * 07/17/00  ah      Tree Interface
 ***************************************************************************/
 
#include "VDct1.h"
#include "VDct1Tree.h"

#include "VDobj.h"
#include "VDdir.h"
#include "VDppl1.h"
#include "VDsa.h"

#include "VDvla.h"

#include "VDassert.h"

VDASSERT_FFN("vdct1/set/VDct1Node.C");

#if 0
/* ------------------------------------------------
 * A bit of DEBUGGING STUFF
 * used for looking at PPL and Struct data
 * Everything defaults NULL unless input
 * backscreen printing 
 * defaults off with status == 0
 */
IGRstat VDct1SR(IGRint           sts,
		IGRchar          loc[128],
		TGRid           *nodeID, 
		TVDctBaseInfo   *baseInfo,
		TGRobj_env      *objOE)
{
  IGRstat retFlag = 0;
  
  if (sts == 0) goto wrapup;
  if ((nodeID) || (baseInfo) || (objOE)) {
    printf("\n<===== Status Report [%s] =====>\n",loc);
    if (nodeID) {
      printf ("<=  nodeID(type)  [%d] [%d]\n",nodeID->osnum,nodeID->objid);
    }
    if (baseInfo) {
      printf("<= baseInfo.setType    = [%s]\n",baseInfo->setType);
      printf("<= baseInfo.setTypeRev = [%s]\n",baseInfo->setTypeRev);
      printf("<= baseInfo.setName    = [%s]\n",baseInfo->setName);
      printf("<= baseInfo.nodeType   = [%s]\n",baseInfo->nodeType);
      printf("<= baseInfo.nodeName   = [%s]\n",baseInfo->nodeName);
      printf("<= baseInfo.baseName   = [%s]\n",baseInfo->baseName);     
    }
    if (objOE) {
      printf ("<= objOE(type)  [%d] [%d]\n",objOE->obj_id.osnum, objOE->obj_id.objid);
    }
    printf("<=== End Status Report [%s] ===>\n\n",loc);
  }

  retFlag = 1;
wrapup:
  return retFlag;
}

#endif

#if 0
/* ---------------------------------------------------------------------------
 *  Turn on the ppl switch to limit tree creation
 */
IGRstat VDct1IsTreeLimitOK(TGRid         *nodeID,
			 TVDctBaseInfo *baseInfo)
{
  IGRint          sts = 0;
  TGRid           pplID;
  IGRint          pplRet;
 
  // args check
  if(nodeID->objid      == NULL_OBJID)   goto wrapup; 
  if(*baseInfo->setType == 0)            goto wrapup; 
  
  // The ppl does the work
  vdppl$Load(name = baseInfo->setType, pplID = &pplID);
  if (pplID.objid == NULL_OBJID) goto wrapup; 
  
  

  vdppl$SetData(pplID = &pplID,
                name  = "ACTION_OK",
                size  = sizeof(IGRstat),
                data  = (IGRchar*)&sts);
 
  // run the ppl
  vdppl$Run(pplID = &pplID, 
	    name  = "isTreeLimitOK", 
	    ret   = &pplRet);
  
  // get the data
  vdppl$GetData(pplID = &pplID,
                name  = "ACTION_OK",
                size  = sizeof(IGRstat),
                data  = (IGRchar*)&sts);

wrapup:
  return sts;
}

#endif

#if 0
/* ----------------------------------------------------------------------------
 * Validate if a part is in OPS Database
 * PPL wrapper
 */
IGRstat VDct1IsPartInOPS(TGRid         *nodeID,
			 TVDctBaseInfo *baseInfo)
{  
  IGRstat         sts       = 1;
  IGRstat         traceFlag = 0;
  TGRid           pplID;
  IGRint          pplRet;

  // say hi
  if(traceFlag) printf(">>> VDct1IsPartInOPS\n");

  // args check
  if(nodeID->objid       == NULL_OBJID) goto wrapup;
  if(*baseInfo->nodeName == 0)          goto wrapup; 

  // The ppl does the work
  vdppl$Load(name = baseInfo->setType, pplID = &pplID);
  if (pplID.objid == NULL_OBJID) goto wrapup;  

  // set up the PPL data
  vdppl$SetData(pplID = &pplID,
                name  = "NODE_ID",
                size  = sizeof(TGRid),
                data  = (IGRchar*)nodeID);

  vdppl$SetData(pplID = &pplID,
                name  = "BASE_INFO",
                size  = sizeof(TVDctBaseInfo),
                data  = (IGRchar*)baseInfo);

  vdppl$SetData(pplID = &pplID,
                name  = "ACTION_OK",
                size  = sizeof(IGRstat),
                data  = (IGRchar*)&sts);
 
  // run the ppl
  vdppl$Run(pplID = &pplID, 
	    name  = "isPartInOPS", 
	    ret   = &pplRet);
  
  // get the data
  vdppl$GetData(pplID = &pplID,
                name  = "ACTION_OK",
                size  = sizeof(IGRstat),
                data  = (IGRchar*)&sts);

wrapup:
  // say bye
  if(traceFlag) printf("<<< VDct1IsPartInOPS(%d)\n",sts);
  return sts;
}

#endif

#if 0
/* ----------------------------------------------------------------------------
 * gets default attributes if any from the PPL 
 * attributes come from parentID and go to nodeID
 * I - NODE_PARENT_ID
 * I - NODE_ID
 */
IGRstat VDct1GetParentAttributes(TGRid *parentID,
				 TGRid *nodeID)
{
  IGRstat         retFlag = 0;
  IGRstat         traceFlag = 0;
  TVDctBaseInfo   baseInfo;
  TGRid           pplID;
  IGRint          pplRet;

  // say hi
  if(traceFlag) printf(">>> IGRstat VDctGetParentAttributes\n");

  // args check
  if(parentID->objid == NULL_OBJID) goto wrapup;
  if(nodeID->objid   == NULL_OBJID) goto wrapup;
  
  // get the base info
  vdct1$GetBaseInfo(objID = nodeID, baseInfo = &baseInfo);
  if (*baseInfo.nodeType == 0) goto wrapup; 
 
  // The ppl does the work
  vdppl$Load(name = baseInfo.setType, pplID = &pplID);
  if (pplID.objid == NULL_OBJID) goto wrapup;  

  // set up the PPL data
  vdppl$SetData(pplID = &pplID,
                name  = "NODE_ID",
                size  = sizeof(TGRid),
                data  = (IGRchar*)nodeID);

  vdppl$SetData(pplID = &pplID,
                name  = "NODE_PARENT_ID",
                size  = sizeof(TGRid),
                data  = (IGRchar*)nodeID);
 
  // run the ppl
  vdppl$Run(pplID = &pplID, 
	    name  = "getParentAttributes", 
	    ret   = &pplRet);

  // success status set
  retFlag = pplRet;  

wrapup:
  // say bye
  if(traceFlag) printf("<<< IGRstat VDctGetParentAttributes(%d)\n",retFlag);
  return retFlag;
  
}
#endif
#if 0
/* ------------------------------------------------
 * PPL wrapper to grab a node and mark it as deleted
 * and wipe out its kids
 */
IGRstat VDct1SetNodeMarkDeleted(TGRid *nodeID)
{
  IGRstat         retFlag = 0;
  IGRstat         traceFlag = 0;
  TVDctBaseInfo   baseInfo;
  TGRid           pplID;
  IGRint          pplRet;


    // say hi
  if(traceFlag) printf(">>> VDct1SetNodeMarkDeleted\n");

  // args check
  if(nodeID->objid == NULL_OBJID) goto wrapup;

  // get the baseInfo
  vdct1$GetBaseInfo(objID = nodeID, baseInfo = &baseInfo);
  if (*baseInfo.nodeType == 0) goto wrapup;  

  // The ppl does the work
  vdppl$Load(name = baseInfo.setType, pplID = &pplID);
  if (pplID.objid == NULL_OBJID) goto wrapup;  

  // set up the PPL data
  vdppl$SetData(pplID = &pplID,
                name  = "NODE_ID",
                size  = sizeof(TGRid),
                data  = (IGRchar*)nodeID);

  // run the ppl
  vdppl$Run(pplID = &pplID, 
	    name  = "setStatusDeleted", 
	    ret   = &pplRet);

  // success status set
  retFlag = pplRet;
  
wrapup:
  // say bye
  if(traceFlag) printf("<<< VDct1SetNodeMarkDeleted(%d)\n",retFlag);
  return retFlag;
}
#endif

#if 0
/* ------------------------------------------------
 * PPL wrapper for restoring the Deleted status to 
 * Active
 */
IGRstat VDct1SetNodeActive(TGRid *nodeID)
{
  IGRstat         retFlag = 0;
  IGRstat         traceFlag = 0;
  TVDctBaseInfo   baseInfo;
  TGRid           pplID;
  IGRint          pplRet;


    // say hi
  if(traceFlag) printf(">>> VDct1SetNodeActive\n");

  // args check
  if(nodeID->objid == NULL_OBJID) goto wrapup;

  // get the baseInfo
  vdct1$GetBaseInfo(objID = nodeID, baseInfo = &baseInfo);
  if (*baseInfo.nodeType == 0) goto wrapup;  

  // The ppl does the work
  vdppl$Load(name = baseInfo.setType, pplID = &pplID);
  if (pplID.objid == NULL_OBJID) goto wrapup;  

  // set up the PPL data
  vdppl$SetData(pplID = &pplID,
                name  = "NODE_ID",
                size  = sizeof(TGRid),
                data  = (IGRchar*)nodeID);

  // run the ppl
  vdppl$Run(pplID = &pplID, 
	    name  = "setStatusActive", 
	    ret   = &pplRet);

  // success status set
  retFlag = pplRet;
  
wrapup:
  // say bye
  if(traceFlag) printf("<<< VDct1SetNodeActive(%d)\n",retFlag);
  return retFlag;
}
#endif

#if 0

/* ------------------------------------------------
 * moves the attributes of NODE_PARENT_ID to NODE_ID
 * while protecting some attributes
 * used when marking as deleted EA[2] when converted 
 * to EA[6]
 */
IGRstat VDct1SetNodeDeleted(TGRid *parentID,TGRid *nodeID)
{
  TVDctBaseInfo   baseInfo;
  IGRstat         retFlag = 0;
  IGRstat         traceFlag = 0;
  TGRid           pplID;
  IGRint          pplRet;
  
  // say hi
  if(traceFlag) printf(">>> VDct1SetNodeDeleted\n");

  // args check
  if(parentID->objid == NULL_OBJID) goto wrapup;
  if(nodeID->objid   == NULL_OBJID) goto wrapup;

  // get the baseInfo
  vdct1$GetBaseInfo(objID = parentID, baseInfo = &baseInfo);
  if (*baseInfo.nodeType == 0) goto wrapup;  

  // The ppl does the work
  vdppl$Load(name = baseInfo.setType, pplID = &pplID);
  if (pplID.objid == NULL_OBJID) goto wrapup;

  // set up the PPL data
  vdppl$SetData(pplID = &pplID,
                name  = "NODE_ID",
                size  = sizeof(TGRid),
                data  = (IGRchar*)nodeID);

  vdppl$SetData(pplID = &pplID,
                name  = "NODE_PARENT_ID",
                size  = sizeof(TGRid),
                data  = (IGRchar*)parentID);

  // run the ppl
  vdppl$Run(pplID = &pplID, 
	    name  = "convertAttrSet", 
	    ret   = &pplRet);

  retFlag = pplRet;

wrapup:
  // say bye
  if(traceFlag) printf("<<< VDct1SetNodeDeleted(%d)\n",retFlag);
  return retFlag;
}
#endif
/* ------------------------------------------------
 * Checks if the nodeID should be posted to the form 
 * (Tree or Lib forms)
 * returns 1 if the node should be updated and 1 if the
 * ppl does not have a corresponding control device
 * fail safe device ...
 * returns 0 if the node should not be displayed
 */
IGRstat VDct1IsDisplayOK(TGRid *rootID,IGRint *dispOption)
{
  TVDctBaseInfo  baseInfo;
  IGRstat        traceFlag = 0;
  IGRstat        sts = 1;
  TGRid          pplID;
  IGRint         pplRet; 
  TGRid          nodeID;

  // say hi 
  if (traceFlag) {
    printf(">>> VDct1IsDisplayOK \n");
    printf("dispOption = [%d]\n",*dispOption);
    
  }
  

  //args check 
  if(rootID->objid == NULL_OBJID) goto wrapup;

  // Check this for the ppl
  vdct1$GetBaseInfo(objID = rootID, baseInfo = &baseInfo);
  if (*baseInfo.nodeType == 0) goto wrapup;

  // The ppl does the work
  vdppl$Load(name = baseInfo.setType, pplID = &pplID);
  if (pplID.objid == NULL_OBJID) goto wrapup;

  // set the data
  vdppl$SetData(pplID = &pplID,
                name  = "ACTION_OK",
                size  = sizeof(IGRstat),
                data  = (IGRchar*)&sts);

  vdppl$SetData(pplID = &pplID,
                name  = "LIST_IND",
                size  = sizeof(IGRstat),
                data  = (IGRchar*)dispOption);

  vdppl$SetData(pplID = &pplID,
                name  = "NODE_ID",
                size  = sizeof(TGRid),
                data  = (IGRchar*)rootID);

  // run the ppl
  vdppl$Run(pplID = &pplID, 
	    name  = "isDisplayOK", 
	    ret   = &pplRet);

  // get the data
  vdppl$GetData(pplID = &pplID,
                name  = "ACTION_OK",
                size  = sizeof(IGRstat),
                data  = (IGRchar*)&sts);

wrapup:
  // say bye
  if (traceFlag) printf("<<< VDct1IsDisplayOK(%d)\n",sts);
  return sts;
  
}

#if 0
/* ------------------------------------------------
 * Check if the freeze should be done
 * ppl wrapper to determine if a node is proper to freeze
 * return of 1 is OK
 */
IGRstat VDct1IsFreezeOK(TGRid *parentNodeID,TVDctBaseInfo *baseInfo)
{
  IGRstat        traceFlag = 0;
  IGRstat        sts = 1;
  TGRid          pplID;
  IGRint         pplRet;  
  // say hi 
  if (traceFlag) printf(">>>VDct1IsFreezeOK \n");

  // args check
  if ((parentNodeID == NULL) || (baseInfo == NULL)) goto wrapup;

  // The ppl does the work
  vdppl$Load(name = baseInfo->setType, pplID = &pplID);
  if (pplID.objid == NULL_OBJID) goto wrapup;

  // set the data
  vdppl$SetData(pplID = &pplID,
                name  = "ACTION_OK",
                size  = sizeof(IGRstat),
                data  = (IGRchar*)&sts);

  vdppl$SetData(pplID = &pplID,
                name  = "NODE_PARENT_ID",
                size  = sizeof(TGRid),
                data  = (IGRchar*)parentNodeID);

  vdppl$SetData(pplID = &pplID,
                name  = "BASE_INFO",
                size  = sizeof(TVDctBaseInfo),
                data  = (IGRchar*)baseInfo);

  // run the ppl
  vdppl$Run(pplID = &pplID, 
	    name  = "isFreezeOK", 
	    ret   = &pplRet);

  // get the data from the ppl
  vdppl$GetData(pplID = &pplID,
                name  = "ACTION_OK",
                size  = sizeof(IGRstat),
                data  = (IGRchar*)&sts);

  vdppl$GetData(pplID = &pplID,
                name  = "BASE_INFO",
                size  = sizeof(TVDctBaseInfo),
                data  = (IGRchar*)baseInfo);

  vdppl$GetData(pplID = &pplID,
                name  = "NODE_PARENT_ID",
                size  = sizeof(TGRid),
                data  = (IGRchar*)parentNodeID);
wrapup:

  // say bye
  if (traceFlag) {
    printf("pplRet = [%d]\n",pplRet);
    printf("<<< VDct1IsFreezeOK(%d)\n",sts);
  }
  
  return sts;
}
#endif

#if 0
/* -------------------------------------------------
 * Check if this particular node is to be active etc
 */
IGRstat VDct1IsNodeActivateOK(TGRid *nodeID)
{
  IGRstat        traceFlag = 0;
  IGRstat        sts = 1;
  TGRid          pplID;
  IGRint         pplRet;
  TVDctBaseInfo  baseInfo;
  
      
  // say hi 
  if (traceFlag) printf(">>> VDct1IsNodeActivateOK\n");

  // args check
  if (nodeID == NULL) goto wrapup;

  // Check this for the ppl
  vdct1$GetBaseInfo(objID = nodeID, baseInfo = &baseInfo);
  if (*baseInfo.nodeType == 0) goto wrapup;

  // The ppl does the work
  vdppl$Load(name = baseInfo.setType, pplID = &pplID);

  if (pplID.objid == NULL_OBJID) goto wrapup;

  // set the data
  vdppl$SetData(pplID = &pplID,
                name  = "ACTION_OK",
                size  = sizeof(IGRstat),
                data  = (IGRchar*)&sts);

  vdppl$SetData(pplID = &pplID,
                name  = "NODE_ID",
                size  = sizeof(TGRid),
                data  = (IGRchar*)nodeID);

  // run the ppl
  vdppl$Run(pplID = &pplID, 
	    name  = "isNodeActivateOK", 
	    ret   = &pplRet);

  vdppl$GetData(pplID = &pplID,
                name  = "ACTION_OK",
                size  = sizeof(IGRstat),
                data  = (IGRchar*)&sts);

wrapup:

  // say bye
  if (traceFlag) printf("<<< VDct1IsNodeActivateOK(%d)\n",sts);
  return sts;
}
#endif

#if 0
/* ------------------------------------------------
 * Check if the revise should be done
 * ppl wrapper to determine if  a node is proper to revise
 * return of 1 is OK
 */
IGRstat VDct1IsReviseOK(TGRid *parentNodeID,TVDctBaseInfo *baseInfo, IGRint *revNum)
{
  IGRstat        traceFlag;
  IGRstat        sts = 1;
  TGRid          pplID;
  IGRint         pplRet, revCheck;
  IGRchar        revCheckStr[128];
  
  traceFlag = 0;
  
  // say hi 
  if (traceFlag) printf(">>> VDct1IsReviseOK\n");

 
  
  // args check
  if ((parentNodeID == NULL) || (baseInfo == NULL)) {
    if(traceFlag)  printf("Went home without trying\n\n");
   
    goto wrapup;
  }
  
  // The ppl does the work
  vdppl$Load(name = baseInfo->setType, pplID = &pplID);
  if (pplID.objid == NULL_OBJID) goto wrapup;

  // set the data
  vdppl$SetData(pplID = &pplID,
                name  = "ACTION_OK",
                size  = sizeof(IGRstat),
                data  = (IGRchar*)&sts);

  vdppl$SetData(pplID = &pplID,
                name  = "NODE_PARENT_ID",
                size  = sizeof(TGRid),
                data  = (IGRchar*)parentNodeID);

  vdppl$SetData(pplID = &pplID,
                name  = "BASE_INFO",
                size  = sizeof(TVDctBaseInfo),
                data  = (IGRchar*)baseInfo);

   if (traceFlag)  printf("\nrevNum = [%d]\n\n",*revNum);
  
  vdppl$SetData(pplID = &pplID,
                name  = "LIST_IND",
                size  = sizeof(IGRint),
                data  = (IGRchar*)revNum);

  // run the ppl
  vdppl$Run(pplID = &pplID, 
	    name  = "isReviseOK", 
	    ret   = &pplRet);

  // get the data from the ppl
  vdppl$GetData(pplID = &pplID,
                name  = "ACTION_OK",
                size  = sizeof(IGRstat),
                data  = (IGRchar*)&sts);

  vdppl$GetData(pplID = &pplID,
                name  = "BASE_INFO",
                size  = sizeof(TVDctBaseInfo),
                data  = (IGRchar*)baseInfo);

  vdppl$GetData(pplID = &pplID,
                name  = "NODE_PARENT_ID",
                size  = sizeof(TGRid),
                data  = (IGRchar*)parentNodeID);

wrapup:

  // say bye
  if (traceFlag) printf("<<< VDct1IsReviseOK(%d)\n",sts);
  return sts;
}

#endif

#if 0
/* ------------------------------------------------
 * isPartConValid?
 * wrapper for PPL 
 * checkes to see if a part is valid for connection
 * works by exception in that it returns a valid connection
 * unless a rule stops the connection  Made this way because
 * pasting of nodes is fairly automatic in the PalAssys.u segment
 * This can be reversed in the PPL if the user wishes to 
 * make the rules detect the conditions which permit returning 0 if the 
 * conditons are not met
 * this PPL allows access to all incoming data as outgoing as well
 * this allows the programmer to alter data in the PPL and access it in the 
 * program operations.
 */
IGRstat VDct1IsPartConValid(TGRid *nodeID, TVDctBaseInfo *baseInfo, TGRobj_env *modelOE)
{
  IGRstat        traceFlag  = 0;
  IGRstat        sts        = 1;
  TGRid          pplID;
  IGRint         pplRet;

  if (traceFlag) printf(">>> VDct1IsPartConValid\n");

    // arg check
  if (nodeID->objid == NULL_OBJID)  goto wrapup; 
  if (modelOE->obj_id.objid == NULL_OBJID) goto wrapup;
  if (baseInfo->nodeType == NULL) goto wrapup;
 
  // The ppl does the work
  vdppl$Load(name = baseInfo->setType, pplID = &pplID);
  if (pplID.objid == NULL_OBJID) goto wrapup;

  // set the data
  vdppl$SetData(pplID = &pplID,
                name  = "ACTION_OK",
                size  = sizeof(IGRstat),
                data  = (IGRchar*)&sts);

  vdppl$SetData(pplID = &pplID,
                name  = "NODE_ID",
                size  = sizeof(TGRid),
                data  = (IGRchar*)nodeID);

  vdppl$SetData(pplID = &pplID,
                name  = "BASE_INFO",
                size  = sizeof(TVDctBaseInfo),
                data  = (IGRchar*)baseInfo);

  vdppl$SetData(pplID = &pplID,
                name  = "PIECE_OE",
                size  = sizeof(TGRobj_env),
                data  = (IGRchar*)modelOE);

  // run the ppl
  vdppl$Run(pplID = &pplID, 
	    name  = "isPartConValid", 
	    ret   = &pplRet);

  // get the data from the ppl
  vdppl$GetData(pplID = &pplID,
                name  = "ACTION_OK",
                size  = sizeof(IGRstat),
                data  = (IGRchar*)&sts);

#if 0
  vdppl$GetData(pplID = &pplID,
                name  = "BASE_INFO",
                size  = sizeof(TVDctBaseInfo),
                data  = (IGRchar*)baseInfo);

  vdppl$GetData(pplID = &pplID,
                name  = "NODE_ID",
                size  = sizeof(TGRid),
                data  = (IGRchar*)nodeID);

  vdppl$GetData(pplID = &pplID,
                name  = "PIECE_OE",
                size  = sizeof(TGRobj_env),
                data  = (IGRchar*)modelOE);
#endif

wrapup:
  if (traceFlag) printf("<<< VDct1IsPartConValid(%d)\n",sts);
  return sts;
  
}
#endif

#if 0
/* -----------------------------------------------
 *  Updates the attributes of the specific node in question 
 *  looks up in database and supplies values
 */
IGRstat VDct1UpdateAttributes(TGRid *nodeID)
{
  IGRstat        retFlag = 0;
  TGRid          pplID;
  IGRint         pplRet;
  TGRid          parentIDx;
  TVDctBaseInfo  baseInfo;
  

  retFlag = 0;

  // arg check
  if (nodeID->objid == NULL_OBJID)  goto wrapup; 
 
  // Check this for the ppl
  vdct1$GetBaseInfo(objID = nodeID, baseInfo = &baseInfo);
  if (*baseInfo.nodeType == 0) goto wrapup;

  // The ppl does the work
  vdppl$Load(name = baseInfo.setType, pplID = &pplID);
  if (pplID.objid == NULL_OBJID) goto wrapup;

  vdppl$SetData(pplID = &pplID,
                name  = "NODE_ID",
                size  = sizeof(TGRid),
                data  = (IGRchar*)nodeID);

  vdppl$SetData(pplID = &pplID,
                name  = "BASE_INFO",
                size  = sizeof(TVDctBaseInfo),
                data  = (IGRchar*)&baseInfo);

  vdppl$Run(pplID = &pplID, 
	    name  = "updateNodeAttributes", 
	    ret   = &pplRet);

  vdppl$GetData(pplID = &pplID,
                name  = "BASE_INFO",
                size  = sizeof(TVDctBaseInfo),
                data  = (IGRchar*)&baseInfo);

  vdppl$GetData(pplID = &pplID,
                name  = "NODE_ID",
                size  = sizeof(TGRid),
                data  = (IGRchar*)nodeID);
 
    retFlag = 1;
  
 
  // oh well
wrapup:
 
  // say bye
  return retFlag;  
}
#endif

#if 0
/* ------------------------------------------------------
 * Checks the baseInfo.nodeType to see if a change should occur
 * Creates the nodeName based upon attribute VDCT1_ATTR_TREE_NUM
 * called by PPL
 */ 

IGRstat VDct1MakeNodeName(TGRid         *parentID,
			  TVDctBaseInfo *baseInfo)

{
  IGRstat        retFlag = 0;
  TGRid          pplID;
  IGRint         pplRet;


  retFlag = 0;

  // arg check
  if ((parentID == NULL) || (parentID->objid == NULL_OBJID)) goto wrapup; 

  // The ppl does the work
  vdppl$Load(name = baseInfo->setType, pplID = &pplID);
  if (pplID.objid == NULL_OBJID) goto wrapup;

  vdppl$SetData(pplID = &pplID,
                name  = "NODE_PARENT_ID",
                size  = sizeof(TGRid),
                data  = (IGRchar*)parentID);

  vdppl$SetData(pplID = &pplID,
                name  = "BASE_INFO",
                size  = sizeof(TVDctBaseInfo),
                data  = (IGRchar*)baseInfo);
  
  vdppl$Run(pplID = &pplID, 
	    name  = "computeNodeName", 
	    ret   = &pplRet);

  vdppl$GetData(pplID = &pplID,
                name  = "BASE_INFO",
                size  = sizeof(TVDctBaseInfo),
                data  = (IGRchar*)baseInfo);
  
    
  retFlag = 1;
  
 
  // oh well
wrapup:
 
  // say bye
  return retFlag;  
}

#endif



/* ------------------------------------------------------
 * Updates the attributes of a node 
 * called by PPL
 */ 

IGRstat VDct1SummaryNode(TGRid *parentID)
{
  IGRstat        retFlag = 0;
  IGRstat        traceFlag = 0;
  TGRid          pplID;
  IGRint         pplRet;
  TVDctBaseInfo  baseInfo;
TGRid parentIDx;

  // arg check
  if ((parentID == NULL) || (parentID->objid == NULL_OBJID)) {
    if (traceFlag) {
      printf("ParentID test failed to allow another run\n");
    }
    
    goto wrapup;
  }
  

  // Check this for the ppl
  vdct1$GetBaseInfo(objID = parentID, baseInfo = &baseInfo);
  if (*baseInfo.nodeType == 0) goto wrapup;

  // The ppl does the work
  vdppl$Load(name = baseInfo.setType, pplID = &pplID);
  if (pplID.objid == NULL_OBJID) goto wrapup;

  vdppl$SetData(pplID = &pplID,
                name  = "NODE_PARENT_ID",
                size  = sizeof(TGRid),
                data  = (IGRchar*)parentID);

  vdppl$SetData(pplID = &pplID,
                name  = "BASE_INFO",
                size  = sizeof(TVDctBaseInfo),
                data  = (IGRchar*)&baseInfo);
  
  vdppl$Run(pplID = &pplID, 
	    name  = "summaryNode", 
	    ret   = &pplRet);

  vdppl$GetData(pplID = &pplID,
                name  = "NODE_PARENT_ID",
                size  = sizeof(TGRid),
                data  = (IGRchar*)&parentIDx);

  if (pplRet == 0) parentIDx.objid = NULL_OBJID;

  if (parentIDx.objid != NULL_OBJID) {
    VDct1SummaryNode(&parentIDx);
    
    retFlag = 1;
    
  }
 
  // oh well
wrapup:

  // say bye
  return retFlag;  
}



#if 0
/* ------------------------------------------------------
 * RET_FLAG is the return value
 * Reports back 1 if valid to make
 * Reports back 0 if not valid to make
 * Just a wrapper to the ppl
 */ 

IGRstat VDct1IsChildTypeValid(TGRid *parentID,TVDctNodeType childType)
{
  IGRstat retFlag = 0;
  TGRid   pplID;
  IGRint  pplRet;

  TVDctBaseInfo baseInfo;
  TVDct1JD parentJD;
  
  // Arg check
  if ((parentID == NULL) || (parentID->objid == NULL_OBJID)) goto wrapup;
 
  // Try for a tree
  parentJD.cl = VDct1GetTreeClassForNode(parentID);
  if (parentJD.cl) {
    parentJD.id = *parentID;
    return _RTCJDB(&parentJD)->isChildTypeValid(&parentJD,childType);
  }

  // Check this for the ppl
  vdct1$GetBaseInfo(objID = parentID, baseInfo = &baseInfo);
  if (*baseInfo.nodeType == 0) goto wrapup;

  // The ppl does the work
  vdppl$Load(name = baseInfo.setType, pplID = &pplID);
  if (pplID.objid == NULL_OBJID) goto wrapup;

  vdppl$SetData(pplID = &pplID,
                name  = "NODE_PARENT_ID",
                size  = sizeof(TGRid),
                data  = (IGRchar*)parentID);

  vdppl$SetData(pplID = &pplID,
                name  = "BASE_INFO",
                size  = sizeof(TVDctBaseInfo),
                data  = (IGRchar*)&baseInfo);

  vdppl$SetData(pplID = &pplID,
                name  = "NODE_TYPE",
                size  = sizeof(TVDctNodeType),
                data  = (IGRchar*)childType);

 
  
  vdppl$Run(pplID = &pplID, 
	    name  = "isChildTypeValid", 
	    ret   = &pplRet);

  if (pplRet==1) retFlag = 1;


  // Done 

wrapup:  
  return retFlag;
}
#endif

#if 0
/* ------------------------------------------------------
 * Compute (or recompute a node)
 * Just a wrapper to the ppl
 */ 
IGRstat VDct1ComputeNode(TGRid *nodeID)
{
  IGRstat retFlag = 0;
  TGRid   pplID;
  IGRint  pplRet;

  TVDctBaseInfo baseInfo;
  
  TGRobj_env modelOE;
  
  // Arg check
  if ((nodeID == NULL) || (nodeID->objid == NULL_OBJID)) goto wrapup; 

  // Check this for the ppl
  vdct1$GetBaseInfo(objID = nodeID, baseInfo = &baseInfo);
  if (*baseInfo.nodeType == 0) goto wrapup;
 
  // The ppl does the work
  vdppl$Load(name = baseInfo.setType, pplID = &pplID);
  if (pplID.objid == NULL_OBJID) goto wrapup;

  vdppl$SetData(pplID = &pplID,
                name  = "NODE_ID",
                size  = sizeof(TGRid),
                data  = (IGRchar*)nodeID);

  vdppl$SetData(pplID = &pplID,
                name  = "BASE_INFO",
                size  = sizeof(TVDctBaseInfo),
                data  = (IGRchar*)&baseInfo);

  vdct1$GetNodeModelObject(nodeID  = nodeID,
			   modelOE = &modelOE);

  vdppl$SetData(pplID = &pplID,
                name  = "PIECE_OE",
                size  = sizeof(TGRobj_env),
                data  = (IGRchar*)&modelOE);
  
  
  vdppl$Run(pplID = &pplID, name = "computeNode", ret = &pplRet);
  
  // Done
  retFlag = 1;

wrapup:
  return retFlag;
}

#endif

#if 0
/* ------------------------------------------------------
 * PPL Wrapper for computeNodeName()
 */

IGRstat VDct1computeNodeName(TGRid *parentID, TVDctBaseInfo *baseInfo)
{
  IGRstat       retFlag = 0;
  TGRid         pplID;
  IGRint        pplRet;
  IGRchar       buf[128];
  TVDctBaseInfo parentBaseInfo;
  // The ppl does the work
  vdppl$Load(name = parentBaseInfo.setType, pplID = &pplID);
  if (pplID.objid == NULL_OBJID) goto wrapup;

  vdppl$SetData(pplID = &pplID,
                name  = "NODE_PARENT_ID",
                size  = sizeof(TGRid),
                data  = (IGRchar*)parentID);

  vdppl$SetData(pplID = &pplID,
                name  = "BASE_INFO",
                size  = sizeof(TVDctBaseInfo),
                data  = (IGRchar*)&baseInfo);
  
  vdppl$Run(pplID = &pplID, name = "computeNodeName", ret = &pplRet);

  vdppl$GetData(pplID = &pplID,
                name  = "BASE_INFO",
                size  = sizeof(TVDctBaseInfo),
                data  = (IGRchar*)&baseInfo); 

  strcpy(buf,baseInfo->nodeName);
  if (!strcmp(buf,"" )) goto wrapup;

  // Done
  retFlag = 1;

wrapup:
  return retFlag;
}
#endif

#if 0

/* ------------------------------------------------------
 * Want to post a node to the database
 * Just a wrapper to the ppl
 */ 
IGRstat VDct1PostNode(TGRid *nodeID)
{
  IGRstat retFlag = 0;
  TGRid   pplID;
  IGRint  pplRet;

  TVDctBaseInfo baseInfo;
  
  // Arg check
  if ((nodeID == NULL) || (nodeID->objid == NULL_OBJID)) goto wrapup; 

  // Check this for the ppl
  vdct1$GetBaseInfo(objID = nodeID, baseInfo = &baseInfo);
  if (*baseInfo.nodeType == 0) goto wrapup;
 
  // The ppl does the work
  vdppl$Load(name = baseInfo.setType, pplID = &pplID);
  if (pplID.objid == NULL_OBJID) goto wrapup;

  vdppl$SetData(pplID = &pplID,
                name  = "NODE_ID",
                size  = sizeof(TGRid),
                data  = (IGRchar*)nodeID);

  vdppl$SetData(pplID = &pplID,
                name  = "BASE_INFO",
                size  = sizeof(TVDctBaseInfo),
                data  = (IGRchar*)&baseInfo);
  
  vdppl$Run(pplID = &pplID, name = "postNode", ret = &pplRet);

  // Done
  retFlag = 1;

wrapup:
  return retFlag;
}
#endif


/* ------------------------------------------------------
 * The user has clicked on the expand column in a tree form
 * Just a wrapper to the ppl
 */ 
IGRstat VDct1PreExpandContractNode(TGRid *nodeID, IGRchar *op)
{
  IGRstat retFlag = 0;
  TGRid   pplID;
  IGRint  pplRet;

  IGRchar opx[16];

  TVDctBaseInfo baseInfo;
  TVDct1JD nodeJD;
  
  // Arg check
  if ((nodeID == NULL) || (nodeID->objid == NULL_OBJID)) goto wrapup; 
  if (op == NULL) goto wrapup;
  strcpy(opx,op);

  // Try for a tree
  nodeJD.cl = VDct1GetTreeClassForNode(nodeID);
  if (nodeJD.cl) {
    nodeJD.id = *nodeID;
    return _RTCJDB(&nodeJD)->preExpandContractNode(&nodeJD,op);
  }

  // Check this for the ppl
  vdct1$GetBaseInfo(objID = nodeID, baseInfo = &baseInfo);
  if (*baseInfo.nodeType == 0) goto wrapup;
 
  // The ppl does the work
  vdppl$Load(name = baseInfo.setType, pplID = &pplID);
  if (pplID.objid == NULL_OBJID) goto wrapup;

  vdppl$SetData(pplID = &pplID,
                name  = "NODE_ID",
                size  = sizeof(TGRid),
                data  = (IGRchar*)nodeID);

  vdppl$SetData(pplID = &pplID,
                name  = "BASE_INFO",
                size  = sizeof(TVDctBaseInfo),
                data  = (IGRchar*)&baseInfo);

  vdppl$SetData(pplID = &pplID,
                name  = "OP",
                size  =  16,
                data  = (IGRchar*)opx);
  
  vdppl$Run(pplID = &pplID, name = "preExpandContractNode", ret = &pplRet);

  vdppl$GetData(pplID = &pplID,
                name  = "OP",
                size  =  16,
                data  = (IGRchar*)opx);
  strcpy(op,opx);
  
  // Done
  retFlag = 1;

wrapup:
  return retFlag;
}

/* ------------------------------------------------------
 * Delete a node
 * No ppl interface for now
 *
 * Deletes all children as well
 */ 
#argsused
IGRstat VDct1DeleteNode(TGRid *nodeID)
{
  IGRstat retFlag = 0;
  
  TGRid      workID;
  TVDclaType type;
  
  // Arg check
  if (nodeID == NULL) goto wrapup;
  if (nodeID->objid == NULL_OBJID) goto wrapup;

  // Ignore non VDctBase objects
  vdcla$Get(objID = nodeID,
	    type  = &type);
  
  if (type == VDCLA_TYPE_NONE) {
    retFlag = 1;
    goto wrapup;
  }

  // Disconnect from any listeners

  // Disconnect from any parents
  vdct1$GetTree1Parent(objID = nodeID, outID = &workID);
  vdct1$DisConnectTree1Child(treeID = &workID, childID = nodeID);

  vdct1$GetTree2Parent(objID = nodeID, outID = &workID);
  vdct1$DisConnectTree2Child(treeID = &workID, childID = nodeID);

  vdct1$GetMgrParent(objID = nodeID, outID = &workID);
  vdct1$DisConnectMgrChild(mgrID = &workID, childID = nodeID);
  
  // Delete any children
  while(vdct1$GetTree1Child(objID = nodeID, outID = &workID)) {
    vdct1$DeleteNode(nodeID = &workID);
  }
  while(vdct1$GetTree2Child(objID = nodeID, outID = &workID)) {
    vdct1$DeleteNode(nodeID = &workID);
  }
  while(vdct1$GetMgrChild (objID = nodeID, outID = &workID)) {
    vdct1$DeleteNode(nodeID = &workID);
  }

  // And delete
  VDct1DeleteRootObject(nodeID);

  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}



/* ------------------------------------------------------
 * Creates a new node
 */ 
#argsused
IGRstat VDct1CreateNode(TGRid   *parentID,
			IGRchar *nodeType,
			IGRchar *nodeName,
			TGRid   *nodeID)
{
  VDASSERT_FN("VDct1CreateNode");
  IGRstat retFlag = 0;
  TGRid   pplID;
  IGRint  pplRet;

  TVDctBaseInfo    baseInfo;

  TGRid setID;
  TGRid parentIDx;

  TVDct1JD parentJD,nodeJD;
  
  // Arg check
  if (nodeID == NULL) goto wrapup; 
  nodeID->objid = NULL_OBJID;
  if ((parentID == NULL) || (parentID->objid == NULL_OBJID)) goto wrapup;
  if ((nodeType  == NULL) || (*nodeType == 0)) goto wrapup;
  if ((nodeName  == NULL) || (*nodeName == 0)) goto wrapup;

  if (traceFlag) {
    printf(">>> VDct1CreateNode %s %s\n",nodeType,nodeName);
  }

  // Try tree interface
  parentJD.cl = VDct1GetTreeClassForNode(parentID);
  if (parentJD.cl) {
    parentJD.id = *parentID;
    nodeJD.id.objid = NULL_OBJID;
    _RTCJDB(&parentJD)->createNode(&parentJD,
				    nodeType, 
				    nodeName,
				   &nodeJD);
    *nodeID = nodeJD.id;
    return 1;
  }

  // Grab the parents info
  vdct1$GetBaseInfo(objID = parentID, baseInfo = &baseInfo);
  
  // Use this to determine a regular node or a top node is being created
  if (*baseInfo.nodeType == 0) {
    setID = *parentID;
    parentIDx.objid = NULL_OBJID;
  }
  else {
    setID.objid = NULL_OBJID;
    parentIDx = *parentID;
  }
  
  // The ppl does the work
  vdppl$Load(name = baseInfo.setType, pplID = &pplID);
  if (pplID.objid == NULL_OBJID) goto wrapup;

  vdppl$SetData(pplID = &pplID,
                name  = "SET_ID",
                size  = sizeof(TGRid),
                data  = (IGRchar*)&setID);

  vdppl$SetData(pplID = &pplID,
                name  = "NODE_PARENT_ID",
                size  = sizeof(TGRid),
                data  = (IGRchar*)&parentIDx);

  // Just to be safe, copy into standard size buffer
  strcpy(baseInfo.nodeType,nodeType);
  strcpy(baseInfo.nodeName,nodeName);

  vdppl$SetData(pplID = &pplID,
                name  = "NODE_TYPE",
                size  = sizeof(TVDctNodeType),
                data  = baseInfo.nodeType);

  vdppl$SetData(pplID = &pplID,
                name  = "NODE_NAME",
                size  = sizeof(TVDctNodeName),
                data  = baseInfo.nodeName);
  
  vdppl$Run(pplID = &pplID, name = "createNode", ret = &pplRet);

  vdppl$GetData(pplID = &pplID,
                name  = "NODE_ID",
                size  = sizeof(TGRid),
                data  = (IGRchar*)nodeID);
  
  if (nodeID->objid == NULL_OBJID) goto wrapup;
  
  // Done
  retFlag = 1;

wrapup:
  if (traceFlag) {
    printf("<<< VDct1CreateNode %d\n",retFlag);
  }
  return retFlag;
}


#if 0
/* ----------------------------------------------------------
 * Gets Node Attribute values puts them in the NODE_ID attributes
 * Then totals the various node  values from database
 * no return value changes only input
 * PPL wrapper
 * I - nodeID;  I - parentID;
 */ 
IGRstat VDct1ComputeNodeAttr(TGRid *nodeID, TVDctBaseInfo *baseInfo, TGRid *parentID)		  
{
  IGRstat          retFlag = 0;
  TGRid            pplID;
  IGRint           pplRet;
  TVDctBaseInfo    parentBaseInfo;

  // Arg check
  if (nodeID->objid == NULL_OBJID)   goto wrapup;
  if (parentID->objid == NULL_OBJID) goto wrapup;

  // get the baseInfo
  vdct1$GetBaseInfo(objID    = parentID, 
		    baseInfo = &parentBaseInfo);

  // check the pointers
  if (*parentBaseInfo.setType == 0) goto wrapup; 

  // Open ppl
  vdppl$Load(name  = baseInfo->setType,
	     pplID = &pplID);

  if (pplID.objid == NULL_OBJID) goto wrapup;

  // Set the NODE_ID
  vdppl$SetData(pplID = &pplID,
                name  = "NODE_ID",
                size  = sizeof(TGRid),
                data  = (IGRchar*)nodeID);

  // Set the BASE_INFO
  vdppl$SetData(pplID = &pplID,
                name  = "BASE_INFO",
                size  = sizeof(TVDctBaseInfo),
                data  = (IGRchar*)baseInfo);

  // Set the NODE_ID
  vdppl$SetData(pplID = &pplID,
                name  = "NODE_PARENT_ID",
                size  = sizeof(TGRid),
                data  = (IGRchar*)parentID);

  // Do It
  vdppl$Run(pplID = &pplID, name = "computeNodeAttr", ret = &pplRet);
  
  // Done
  retFlag = 1;

wrapup:
  return retFlag;
}
#endif

#if 0

/* ----------------------------------------------------------
 * Gets the node type information for a given node type index
 */ 
IGRstat VDct1GetNodeTypeInfo(IGRchar           *setType, 
			     IGRint             nodeInd,
			     TVDctNodeTypeInfo *nodeTypeInfo)
{
  IGRstat retFlag = 0;

  TGRid  pplID;
  IGRint pplRet;

  TVDct1JD nodeJD;
  IGRint   nodeCnt;
  
  // Arg check
  if (nodeTypeInfo == NULL) goto wrapup;
  memset(nodeTypeInfo,0,sizeof(TVDctNodeTypeInfo));
  if ((setType == NULL) || (*setType == 0)) goto wrapup;

  // Tree interface 
  nodeJD.cl = VDct1GetTreeClassForSetType(setType);
  if (nodeJD.cl) {
    nodeJD.id.objid = NULL_OBJID;
    return _RTCJDB(&nodeJD)->getNodeTypeInfo(&nodeJD, 
					     nodeInd,
					     &nodeCnt,
					     nodeTypeInfo);
  }

  // Open ppl
  vdppl$Load(name = setType, pplID = &pplID);
  if (pplID.objid == NULL_OBJID) goto wrapup;

  // Set the index
  vdppl$SetData(pplID = &pplID,
                name  = "NODE_INDEX",
                size  = sizeof(IGRint),
                data  = (IGRchar*)&nodeInd);

  // Do It
  vdppl$Run(pplID = &pplID, name = "getNodeTypeInfo", ret = &pplRet);

  // Pull results
  vdppl$GetData(pplID = &pplID,
                name  = "NODE_TYPE_INFO",
                size  = sizeof(TVDctNodeTypeInfo),
                data  = (IGRchar*)nodeTypeInfo);

  // 0 If no more
  if (*nodeTypeInfo->type == 0) goto wrapup;
  
  // Done
  retFlag = 1;

wrapup:
  return retFlag;
}
#endif

#if 0
/* ----------------------------------------------------------
 * Gets the node type information for a given node name
 */ 
IGRstat VDct1GetNodeTypeInfoByType(IGRchar           *setType, 
				   IGRchar           *nodeType,
				   TVDctNodeTypeInfo *nodeTypeInfo)
{
  IGRstat retFlag = 0;
  IGRint  i;
  
  // Arg check
  if ( setType == NULL) goto wrapup;
  if (nodeType == NULL) goto wrapup;
  if (nodeTypeInfo == NULL) goto wrapup;
  
  // Just cycle through
  for(i = 0; vdct1$GetNodeTypeInfo(setType      = setType,
				   nodeInd      = i,
				   nodeTypeInfo = nodeTypeInfo);i++) {
    if (!strcmp(nodeType,nodeTypeInfo->type)) {
      retFlag = 1;
      goto wrapup;
    }
  }
  
wrapup:
  return retFlag;
}

/* ---------------------------------------------
 * Determines what type of node to create when
 * Pasting a node from one tree to another
 */
IGRstat VDct1GetNodeTypeToCreateForCopy(TGRid *parentID, 
					TGRid *copyID, 
					TVDctNodeTypeInfo *nodeTypeInfo)
{
  VDASSERT_FN("VDct1GetNodeTypeToCreateForCopy");
  IGRstat        retFlag = 0;
  TVDctBaseInfo  parentBaseInfo;
  TVDctBaseInfo  copyBaseInfo;
  TVDctBaseInfo  pasteBaseInfo;

  TGRid          pplID;
  IGRint         pplRet;
 
  TVDct1JD       parentJD;
  TVDct1JD       copyJD;
  

  // Say Hi
  // traceFlag = 0;
  if (traceFlag) {
    printf(">>> VDct1GetNodeTypeToCreateForCopy\n");
  }

   // Arg check
  if (nodeTypeInfo == NULL) goto wrapup;
  *nodeTypeInfo->type = 0;
  
  // Tree interface 
  parentJD.cl = VDct1GetTreeClassForNode(parentID);
  if (parentJD.cl) {
    
    copyJD.cl = VDct1GetTreeClassForNode(copyID);
    if (copyJD.cl == NULL) {
      printf("No Tree Class for copied object\n");
      goto wrapup;
    }
    
    parentJD.id = *parentID;
    copyJD.id = *copyID;
    
    return _RTCJDC(&parentJD)->getPasteNodeType(&parentJD, 
						&copyJD,
						nodeTypeInfo);
  }
  
 
  // Need the infos
  vdct1$GetBaseInfo(objID = parentID, baseInfo = &parentBaseInfo);
  vdct1$GetBaseInfo(objID = copyID,   baseInfo = &copyBaseInfo);

  // The ppl does the work
  vdppl$Load(name = parentBaseInfo.setType, pplID = &pplID);
  if (pplID.objid == NULL_OBJID) goto try_old;

  // Set the data
  vdppl$SetData(pplID = &pplID,
                name  = "NODE_PARENT_ID",
                size  = sizeof(TGRid),
                data  = (IGRchar*)parentID);

  vdppl$SetData(pplID = &pplID,
                name  = "NODE_ID",
                size  = sizeof(TGRid),
                data  = (IGRchar*)copyID);

  vdppl$SetData(pplID = &pplID,
                name  = "BASE_INFO_PARENT",
                size  = sizeof(TVDctBaseInfo),
                data  = (IGRchar*)&parentBaseInfo);

  vdppl$SetData(pplID = &pplID,
                name  = "BASE_INFO",
                size  = sizeof(TVDctBaseInfo),
                data  = (IGRchar*)&copyBaseInfo);

  // Run the ppl
  vdppl$Run(pplID = &pplID, 
	    name  = "getPasteNodeType", 
	    ret   = &pplRet);

  // Get the data
  vdppl$GetData(pplID = &pplID,
                name  = "NODE_TYPE_INFO",
                size  = sizeof(TVDctNodeTypeInfo),
                data  = (IGRchar*)nodeTypeInfo);

  if (*nodeTypeInfo->type == 0) goto try_old;
  retFlag = 1;
  goto wrapup;
  
  /* ---------------------------------------------
   * If the ppl has no opinion just see
   * if the tree contains a node type that matches
   */
 try_old:

  vdct1$GetNodeTypeInfoByType(setType      = parentBaseInfo.setType,
			      nodeType     = copyBaseInfo.nodeType,
			      nodeTypeInfo = nodeTypeInfo);
  if (*nodeTypeInfo->type == 0) goto wrapup;
  
  // Done
  retFlag = 1;
  
 wrapup:
  // Say Bye
  if (traceFlag) {
    printf("<<< VDct1GetNodeTypeToCreateForCopy %s\n",nodeTypeInfo->type);
  }
  return retFlag;
}
#endif

#if 0
/* ----------------------------------------------------------------------
 * Transfer same name name attributes
 */ 
IGRstat VDct1CopyNodeAttributes(TGRid *desID, TGRid *srcID)
{
  VDASSERT_FN("VDct1CopyNodeAttributes");
  
  IGRstat retFlag = 0;
  
  IGRint  desI,srcI;
  TVDfldS  desFlds,srcFlds;
  TVDfld  *desFld,*srcFld;
  
  // Arg check
  if (desID == NULL) goto wrapup;
  if (srcID == NULL) goto wrapup;

  if (traceFlag) {
    printf(">>> VDct1CopyNodeAttributes\n");
    vdobj$Print(objID = desID);
    vdobj$Print(objID = srcID);
  }
  
  // Get the attributes
  vdcol$GetAttrs(objID = desID, cnt = &desFlds.cnt, fld = desFlds.fld);
  vdcol$GetAttrs(objID = srcID, cnt = &srcFlds.cnt, fld = srcFlds.fld);

  // Cycle through destination
  for(desI = 0; desI < desFlds.cnt; desI++) {
    
    desFld = &desFlds.fld[desI];
    
    // Find source
    for(srcI = 0; srcI < srcFlds.cnt; srcI++) {

      srcFld = &srcFlds.fld[srcI];
      
      if (!strcmp(desFld->name,srcFld->name)) {
	strcpy(desFld->val.txt,srcFld->val.txt);
	srcI = srcFlds.cnt;
      }
    }
  }

  // Update the destination
  vdcol$UpdAttrs(objID = desID, cnt = desFlds.cnt, fld = desFlds.fld);
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}
/*---------------------------------------------------  
 * Checks for a set of matching attributes
 * if found return is 1
 * default return is 0
 * setting dupSwitch = 1 turns on the other duplicate Check
 * setting dupSwitch = 0 turns it off
 * setting pplID = 1 reports match found
 * PPL Wrapper
 */
IGRstat VDct1CheckNodeAttrForMatch(TGRid   *parentID,
				   TGRid   *childID,
				   TGRid   *nodeID,
				   IGRint  *dupSwitch)
{
  TVDctBaseInfo  baseInfo, parBI, childBI;
  TGRid          pplID;
  IGRint         pplRet;   
  IGRstat        traceFlag = 0;

  // say hi
  if(traceFlag) printf(">>> VDct1CheckNodesAttrForMatch\n");

  // args check
  if(nodeID == NULL) {
    goto wrapup;
  }
  
  if(childID == NULL) {
    goto wrapup;
  }
  

  // set up
  pplRet = 0;

  // get the base info
  vdct1$GetBaseInfo(objID = parentID, baseInfo = &baseInfo);
  if (*baseInfo.nodeType == 0) goto wrapup; 
  vdct1$GetBaseInfo(objID = childID, baseInfo = &childBI);
  vdct1$GetBaseInfo(objID = parentID, baseInfo = &parBI); 
 
  // The ppl does the work
  vdppl$Load(name = baseInfo.setType, pplID = &pplID);
  if (pplID.objid == NULL_OBJID) goto wrapup;

  // set the data
  vdppl$SetData(pplID = &pplID,
                name  = "ACTION_OK",
                size  = sizeof(IGRstat),
                data  = (IGRchar*)dupSwitch);

  vdppl$SetData(pplID = &pplID,
                name  = "NODE_PARENT_ID",
                size  = sizeof(TGRid),
                data  = (IGRchar*)childID);

  vdppl$SetData(pplID = &pplID,
                name  = "NODE_ID",
                size  = sizeof(TGRid),
                data  = (IGRchar*)nodeID);

  // run the ppl
  vdppl$Run(pplID = &pplID, 
	    name  = "isAttrSetMatched",
	    ret   = &pplRet);

  // get the data from the ppl
  vdppl$GetData(pplID = &pplID,
                name  = "ACTION_OK",
                size  = sizeof(IGRstat),
                data  = (IGRchar*)dupSwitch);
  
wrapup:
  // say hi
  if(traceFlag) {
    printf("<<< VDct1CheckNodesAttrForMatch(%d)\n\n",pplRet);
  }
  
  return pplRet;
}

/* -------------------------------------------------------------
 * recursive engine to provide all the kids of a parent node 
 * this is recursive calls
 * the attribute match routine vdct1$CheckNodeAttrsForMatch 
 * don't mess with the dupSwitch unless you want the other check
 * based upon nodeName and nodeType to work (set = 1 if you do)
 */
IGRstat VDct1SearchNodesForAttrMatch(TGRid   *parentID,
				     TGRid   *nodeID,
				     IGRint  *dupSwitch)
{
  IGRstat sts = 0;
  IGRstat traceFlag = 0;
  IGRstat i;
  TGRid   childID, testID;
  
  // say hi
  if(traceFlag) printf(">>> VDct1SearchNodesAttrMatch\n");
  
  // args check
  if(parentID == NULL) {
    goto wrapup;
  }
  
  if(nodeID   == NULL) {
    goto wrapup;
  }
  

  // init
  testID = *parentID;

  // time to call the kids
  for(i = 0;vdct1$GetTree1Child(objID = &testID, 
				nth   = i, 
				outID = &childID); i++) {

    // check this kid for matched attribute set per PPL list
    sts = vdct1$CheckNodeAttrForMatch(parentID  = parentID,
				      childID   = &childID,
				      nodeID    = nodeID,
				      dupSwitch = dupSwitch);

    // success
    if(sts & 1) {
      if(traceFlag) printf("going to wrapup with sts = 1 from (0)\n");
      goto wrapup;
    }
    

    // go lookup it's kids
    sts = vdct1$SearchNodesForAttrMatch(parentID  = &childID,
					nodeID    = nodeID,
					dupSwitch = dupSwitch);

    // success
    if(sts & 1) {
      goto wrapup;
    }
    
  }
  
wrapup:
  // say bye
  if(traceFlag) printf("<<< VDct1SearchNodesAttrMatch(%d)\n",sts);
  return sts;
}

#endif
/* -----------------------------------------------------------
 * Recursive search for node in tree
 *
 * Make it case insenitive
 */
IGRstat VDct1SearchForNodeInTree(TGRid        *a_treeID,
				 TGRid        *a_testID,
				 TVDctNodeType a_nodeType,
				 TVDctNodeType b_nodeType,
				 TVDfld       *a_fld,
				 TVDfld       *b_fld,
				 IGRint        a_descendFlag,
				 TGRid        *a_nodeID)
{
  IGRstat retFlag = 1;
  IGRstat traceFlag = 0;
  
  TGRid   childID;
  IGRint  i;
  
  TVDctNodeType nodeType;
  TVDctNodeType nodeTypeb;
  TVDctBaseInfo baseInfo,baseInfoB;
  TVDfld  fldx;
  TVDfld  fld;
  TVDfld  fldb;

  // init
  //fldb = *b_fld;
  
  // Arg check
  if (a_nodeID == NULL) {
 
    goto wrapup;
  }
  
  a_nodeID->objid = NULL_OBJID;
  
  // Upper case node type
  if (a_nodeType == NULL) {
  
    goto wrapup;
  }
  
  strcpy(nodeType,a_nodeType);
  VDstrupr(nodeType);
 
  // Lower name, upper value
  if (a_fld == NULL) {
    memset(a_fld,0,sizeof(TVDfld));
    strcpy(a_fld->val.txt,"0");
  }
  

  strcpy(fld.name,   a_fld->name);
  strcpy(fld.val.txt,a_fld->val.txt);
  VDstrlwr(fld.name);
  VDstrupr(fld.val.txt);

  // Check the tree
  if (a_treeID == NULL) goto wrapup;
  if (a_treeID->objid == NULL_OBJID) goto wrapup;

  // Check the node type
  vdct1$GetBaseInfo(objID = a_treeID, baseInfo = &baseInfo);
  // vdct1$GetBaseInfo(objID = a_testID, baseInfo = &baseInfoB);
  VDstrupr(baseInfo.nodeType); 
  // VDstrupr(baseInfo.nodeTypeB); 
  if (!strcmp(nodeType,baseInfo.nodeType)) {
    if (!strcmp(fld.val.txt,"0")) {
	  
	// Got IT!!!
	*a_nodeID = *a_treeID;
	retFlag = 1;
	goto wrapup;
      }
    // Get the attribute
    vdsa$GetStruct(objID = a_treeID, name = fld.name, txt = fldx.val.txt);
    
    if (*fldx.val.txt) {
      if (traceFlag) printf("if (*fldx.name) is true \n");   
     
      // Check the value
      VDstrupr(fldx.val.txt);

      if (!strcmp(fld.val.txt,fldx.val.txt)) {
	  
	// Got IT!!!
	*a_nodeID = *a_treeID;
	retFlag = 1;
	goto wrapup;
      }
    }
    

    // Unless descendFlag is set, stop at first level found
     if (a_descendFlag == 0) goto wrapup;  
  }
  
  // Try each kid
  for(i = 0; vdct1$GetTree1Child(objID = a_treeID, nth = i, outID = &childID); i++) { 
    vdct1$SearchForNodeInTree(a_treeID      = &childID,
			      a_testID      = a_testID,
			      a_nodeType    = nodeType,
			      a_fld         = &fld,
			      a_descendFlag = a_descendFlag,
			      a_nodeID      = a_nodeID);

    if (a_nodeID->objid != NULL_OBJID) {
      retFlag = 1;
      goto wrapup;
    }
  }

  // Oh well
wrapup:
   if (traceFlag){
    printf("\n <<< VDct1SearchForNodeInTree <<< %d\n\n",retFlag);
  }
  
  return retFlag;

}
#if 0
/* --------------------------------------------------------------------
 * Find node in some tree somewhere
 */
IGRstat VDct1SearchForNode(TVDctSetType  treeType,
			   TVDctNodeType nodeType,
			   IGRchar      *attrName,
			   IGRchar      *attrValue,
			   IGRint        descendFlag,
			   TGRid        *nodeID)
{
  IGRstat retFlag = 0;
  VDosnum osnum;
  IGRint  i;
  
  TGRid mgrID;
  TGRid setID;
  TGRid treeID;
  
  TVDctBaseInfo baseInfo;
  TVDfld fld;
  
  // Arg check
  if (nodeID == NULL) goto wrapup;
  nodeID->objid = NULL_OBJID;

  if (treeType  == NULL) goto wrapup;
  if (nodeType  == NULL) goto wrapup;
  if (attrName  == NULL) goto wrapup;
  if (attrValue == NULL) goto wrapup;


  // Name in lower case, value in upper case
    strcpy(fld.name,attrName);
  VDstrlwr(fld.name);
  
    strcpy(fld.val.txt,attrValue);
  VDstrupr(fld.val.txt);
  
  // Cycle through each os
  for(osnum = 0; VDosValidate(osnum); osnum++) {

    // Grab the manager
    vdct1$GetManager(osnum = osnum, mgrID = &mgrID);
    if (mgrID.objid != NULL_OBJID) {
      
      // Cycle through each set
      for(i = 0; vdct1$GetMgrChild(objID = &mgrID, nth = i, outID = &setID); i++) {
	
    printf("\n <<< Goodbye <<<\n\n");
	// Filter by set type
	vdct1$GetBaseInfo(objID = &setID, baseInfo = &baseInfo);
	if (!strcmp(treeType,baseInfo.setType)) {
	  
	  // Get the real tree
	  vdct1$GetMgrChild(objID = &setID, nth = 0, outID = &treeID);
	  
	  // Recursive Search
	  vdct1$SearchForNodeInTree(a_treeID      = &treeID,
				    a_nodeType    = nodeType,
				    a_fld         = &fld,
				    a_descendFlag = descendFlag,
				    a_nodeID      = nodeID);
	  

	  if (nodeID->objid != NULL_OBJID) {
	    retFlag = 1;
	    goto wrapup;
	  }
	}
      }
    }
  }
  
  // Done

wrapup:
  return retFlag;
}


/* --------------------------------------------------------
 * Return a list of all nodes under (and including)
 * this node



 * Support either type of vla
 */
IGRstat VDct1GetNodesVLA(TGRid    *nodeID, 
			 TVDvlaID *nodeVLA1,
			 TVDvlaid *nodeVLA2)
{
  IGRstat retFlag = 0;
  
  IGRint i;
  TGRid  childID;
  
  // Arg check
  if ((nodeID == NULL) || (nodeID->objid == NULL_OBJID)) goto wrapup;
  
  // Add this one
  if (nodeVLA1) vdvla_id$Append(vla = nodeVLA1, objID = nodeID);
  if (nodeVLA2)  vdvlaid$Append(vla = nodeVLA2, data  = nodeID);

  // Cycle through kids
  for(i = 0; vdct1$GetTree1Child(objID = nodeID, nth = i, outID = &childID); i++) {
    VDct1GetNodesVLA(&childID,nodeVLA1,nodeVLA2);
  }
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

#endif
#if 0
/* -------------------------------------------
 * If the node has a part number then extract it
 *
 * Use a ppl interface for it
 */
IGRstat VDct1GetPartNumForNode(TGRid *nodeID, IGRchar *part_num)
{
  IGRstat retFlag = 0;
  TVDfld  fld;
  
  TGRid          pplID;
  IGRint         pplRet; 

  TVDctBaseInfo  baseInfo;

  // Arg Check
  if (part_num == NULL) goto wrapup;
  *part_num = 0;
  if (nodeID == NULL)   goto wrapup;
  
  // Check this for the ppl
  vdct1$GetBaseInfo(objID = nodeID, baseInfo = &baseInfo);
  if (*baseInfo.nodeType == 0) goto wrapup;

  // The ppl does the work
  vdppl$Load(name = baseInfo.setType, pplID = &pplID);
  if (pplID.objid == NULL_OBJID) goto wrapup;

  // Set the data
  vdppl$SetData(pplID = &pplID,
                name  = "NODE_ID",
                size  = sizeof(TGRid),
                data  = (IGRchar*)nodeID);

  vdppl$SetData(pplID = &pplID,
                name  = "BASE_INFO",
                size  = sizeof(TVDctBaseInfo),
                data  = (IGRchar*)&baseInfo);

  // Run the ppl
  vdppl$Run(pplID = &pplID, 
	    name  = "getPartNum", 
	    ret   = &pplRet);

  // get the data
  *fld.val.txt = 0;
  vdppl$GetData(pplID = &pplID,
                name  = "FLD",
                size  = sizeof(TVDfld),
                data  = (IGRchar*)&fld);

  // Check
  if (fld.val.txt == 0) goto wrapup;
  strcpy(part_num,fld.val.txt);
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
  
}
#endif

/* -------------------------------------------
 * If the node has a part cage number then extract it
 *
 * Use tree interface for it
 */
IGRstat VDct1GetPartCageNumForNode(TGRid *nodeID, IGRchar *part_cage_num)
{
  IGRstat retFlag = 0;
  TVDfld  fld;
  
  TGRid          pplID;
  IGRint         pplRet; 

  TVDctBaseInfo  baseInfo;

  TVDct1JD nodeJD;
  
  // Arg Check
  if (part_cage_num == NULL) goto wrapup;
  *part_cage_num = 0;
  if (nodeID == NULL)   goto wrapup;

  // Tree
  nodeJD.cl = VDct1GetTreeClassForNode(nodeID);
  if (nodeJD.cl) {
    nodeJD.id = *nodeID;
    return _PTCJDP(&nodeJD)->getCageNum(&nodeJD,part_cage_num);
  }
  
  // Check this for the ppl
  vdct1$GetBaseInfo(objID = nodeID, baseInfo = &baseInfo);
  if (*baseInfo.nodeType == 0) goto wrapup;

  // The ppl does the work
  vdppl$Load(name = baseInfo.setType, pplID = &pplID);
  if (pplID.objid == NULL_OBJID) goto wrapup;

  // Set the data
  vdppl$SetData(pplID = &pplID,
                name  = "NODE_ID",
                size  = sizeof(TGRid),
                data  = (IGRchar*)nodeID);

  vdppl$SetData(pplID = &pplID,
                name  = "BASE_INFO",
                size  = sizeof(TVDctBaseInfo),
                data  = (IGRchar*)&baseInfo);

  // Run the ppl
  vdppl$Run(pplID = &pplID, 
	    name  = "getPartCageNum", 
	    ret   = &pplRet);

  // get the data
  *fld.val.txt = 0;
  vdppl$GetData(pplID = &pplID,
                name  = "FLD",
                size  = sizeof(TVDfld),
                data  = (IGRchar*)&fld);

  // Check
  if (fld.val.txt == 0) goto wrapup;
  strcpy(part_cage_num,fld.val.txt);
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
  
}

#if 0
/* ---------------------------------------------------------------
 * finds if a particular node is below a parent
 * node must have ass_rev attribute and
 * match baseInfo.nodeType and baseInfo.nodeName
 */
IGRstat VDct1FindNodeWithRev(TVDctBaseInfo *baseInfo,TGRid *parentID,TGRid *copiedNodeID)
{
  TVDctBaseInfo  childBaseInfo, parentBaseInfo;
  TVDfld         fld;
  IGRstat        retFlag = 0;
  IGRstat        traceFlag = 0;
  IGRstat        sts;
  IGRint         i;
  TGRid          childID,copyID;
  

  // say hi
  if(traceFlag) printf(">>> VDct1FindNodeWithRev\n");

  // args check
  if(parentID->objid == NULL_OBJID) goto wrapup;
  if(copiedNodeID->objid == NULL_OBJID) goto wrapup;
    vdct1$GetBaseInfo(objID = parentID, baseInfo = &parentBaseInfo);

  // copy in the baseInfo for the next call
  parentBaseInfo = *baseInfo;

  // time to do the kids
  for(i = 0;vdct1$GetTree1Child(objID = parentID, 
				nth   = i, 
				outID = &childID); i++) {
    // no more kids
    if(childID.objid == NULL_OBJID) goto wrapup;
  
    // get the attribute
    vdcol$GetAttr(objID = &childID, name = "assy_rev", fld = &fld);

    // get the childBaseInfo
    vdct1$GetBaseInfo(objID = &childID, baseInfo = &childBaseInfo);

    // if found
    if (  (!strcmp(baseInfo->baseName,childBaseInfo.baseName)) &&
	  (!strcmp(baseInfo->setName,childBaseInfo.setName))   &&
	  (childID.objid == copiedNodeID->objid)               &&
	  (*fld.name)) {
      retFlag = 1;
      goto wrapup;
    }

    // call myself
    copyID = *copiedNodeID;
    sts = VDct1FindNodeWithRev(&parentBaseInfo,&childID,&copyID);

    if(sts & 1) {
      // successful find has occurred
      retFlag = 1;
      goto wrapup;
    }
  }// looking up the kids
  

wrapup:
  // say bye
  if(traceFlag) printf("<<< VDct1FindNodeWithRev(%d)\n",retFlag);
  return retFlag;  
}


/* ---------------------------------------------------------------
 * gets the highest parent with and assy_rev attribute
 */
IGRstat VDct1GetHighestParentRev(TGRid *nodeID)
{
  IGRstat        retFlag = 0;
  IGRstat        traceFlag = 0;
  IGRstat        sts;
  TVDfld         fld;
  TGRid          parID;
  TVDctBaseInfo  baseInfo;
 
  // say hi
  if(traceFlag) printf(">>>  VDct1GetHighestParentRev\n");
  
  //args check
  if(nodeID->objid == NULL_OBJID) goto wrapup;

  // get the baseInfo of the node
  vdct1$GetBaseInfo(objID = nodeID, baseInfo = &baseInfo);  

  // at the tree top
  if(!strcmp(baseInfo.nodeType,baseInfo.setType)) goto wrapup;

  // get the parID
  vdct1$GetTree1Parent(objID = nodeID, outID = &parID);

  // if parID is null
  if(parID.objid == NULL_OBJID) goto wrapup;
  
  // get the attribute
  vdcol$GetAttr(objID = &parID, name = "assy_rev", fld = &fld);

  // call myself if attribute present
  if(*fld.name) {
    VDct1GetHighestParentRev(&parID);
    // look up this node it has a assy_rev
    *nodeID = parID;
    retFlag = 1;
 
  }

wrapup:
  // say bye
  if(traceFlag) printf(">>>  VDct1GetHighestParentRev\n");
  return retFlag;
  
}


/* ---------------------------------------------------------------
 * Finds if a particular node is a child of a particular Parent
 * filters to make sure that the revNum exists (keeps revisions together)
 * this prevents looking into group and trees also prevents looking into
 * parts
 */

IGRstat VDct1FindChildUnderParentRev(TGRid *nodeID,TVDctBaseInfo *baseInfo,TGRid *copiedNodeID)
{
  IGRstat        retFlag = 0;
  IGRstat        traceFlag = 0;
  IGRstat        sts;
  TGRid          childID, parID, copyID;
  IGRint         i;
  TVDfld         attrFld;
  TVDctBaseInfo  disBaseInfo;
  
  
  // say Hi
  if(traceFlag) printf(">>>  VDct1FindChildUnderParentRev\n");
  if(nodeID->objid == NULL_OBJID) goto wrapup;

  if(traceFlag) printf("passed args checks\n");

  // paste it up
  parID = *nodeID;
  copyID = *copiedNodeID;
 
  vdct1$SR(sts    = traceFlag,
	   loc    = "Above GetHighest",
	   nodeID = &parID);
  
  // get the highest parent
  sts = VDct1GetHighestParentRev(&parID);

  vdct1$GetBaseInfo(objID = &parID, baseInfo = &disBaseInfo);  

  // find out if the node exists below the parID 
  sts = VDct1FindNodeWithRev(baseInfo,&parID,&copyID);

  // report results
  retFlag = sts;

wrapup:
  //say bye
  if(traceFlag) printf("<<<  VDct1FindChildUnderParentRev(%d)\n",retFlag);
  return retFlag;
}

#endif
