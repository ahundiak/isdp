/* $Id: VDsaUCM.I,v 1.1 2001/01/22 15:27:06 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdsa/ucm/VDsaUCM.I
 *
 * Description: Node Manupilation Form
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDsaUCM.I,v $
 *      Revision 1.1  2001/01/22 15:27:06  ahundiak
 *      ah
 *
# Revision 1.1  2000/10/06  20:39:14  pinnacle
# initial revision
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 09/26/00  pn      Creation
 *****************************************************************************/

/********************************************************************************************
 * A bit of explaination.  This is an engine to secure access to a bunch of data 
 * placing it in a structure with quick pointer access.
 * The structure contains the full path ID data and the full list of node names for the path
 * for a node.   This is used in expression evaluation.  
 * there are only three routines here intended to be accessed from the outside world
 * These are 
 *
 * VDsaLookupExpID which has only one input [nodeID] and one output [NameDT<structure>]
 * full description of the NameData typedef is in VDsaUCM.h 
 *
 * VDsaPrintNameDT  prototyped as vdsa$PrintNameDT(title = <string>); 
 * which requires neither input nor output and prints to the back screen
 * a list of data that is in the structure and is useful for diagnostic purposes only
 * this routine has available a title to help with diagnostic location info.
 * 
 * VDsaGetNameDTData(...) which is prototyped in VDsaUCM.h
 * This routine is protoyped to allow accessing individual items and the use of local 
 * identifiers that improve documentation. 
 *  
 * 
 *
 * Dependency:  This file requires VDsaUCM.h to operate and any PPL which uses these functions will 
 * need to include this PPL.
 *
 ********** NOTE! ********************
 * This set of functions is stream lined to speed it up.  The situation that made it 
 * necessary to do was nothing more nor less than the need for speed.
 * There are many statements used in diagnostic work which are left in but commented out
 * These probably should remain as removing them will make the process of any fixes
 * or diagnostic work slower and as comments they use no computing time
 ************** Process ***************
 * The expression evaluation process is very time consuming requiring as much as 10,000 steps 
 * to compute a single value in a table and requiring these to be repreated for every box on
 * a table which required the same data, it consumed a lot of time
 * by doing the process exactly once the lookup will require many fewer steps and will not 
 * require repeated for all 5 or 10 boxes on a table.  
 * the Value: "NameData" is a static structure.  This allows verification that the data is 
 * already available without repeated lookup.
 * it is intended that this will be accessed by PPL drivers in expressions like this 
 *
 * ustr[%SA_PPL:UCM_SA:material]
 *
 * This process may actually be slower for a specific individual lookup.
 * If only one item occurs in a table it will probably produce no gains.
 * several collumn lookups in a row  will definitely gain speed as there
 * will only be one lookup.  
 *
 * As complexity rises there is another level of speed that can be achieved
 * by development of a second structure which could contain lookup data such as attribute values
 * could be developed making access even faster to data which is repreatedly accessed. 
 * This does not appear to be the case at this time.
 * 
 * ~Paul Noel
 ********************************************************************************************/

class implementation VDatBase;

#include "VDtypedef.h"
#include "VDchn.h"
#include "VDobj.h"
#include "VDfrm.h"
#include "VDsa.h"
#include "VDppl1.h"
#include "VDct1.h"
#include "VDct1Cmd.h"
#include "VDsaUCM.h"

static NameData nameDT;
//static OpCnt    cnt;  // diagnostic info operations only


// ***************  prototypes  of functions **********************
IGRstat VDsaGetNameDTTreeData();
IGRstat VDsaSetupNameDT();
IGRstat VDsaLoadParentID(TGRid *nodeID);
// ************** end prototypes of functions *********************


/***********************************************************************
 * called to fill in the data into nameDT global structure and to    
 * provide external access to the ppl to the data in this structure  
 * This is smart it checks to see if this work has already been done
 * before it does any lookups.  This is to save time as much as possible
 * when this is called by the expression operations  
 ***********************************************************************/

IGRstat VDsaLookupExpID(TGRid *nodeID)
 {
  IGRstat retFlag = 0;
  
  
  // IGRstat traceFlag = 1;
  //IGRchar fx[128];
  
  //strcpy(fx,"VDsaLookupExpID");
  
  // say hi
  // if(traceFlag) printf(">>> %s\n",fx);
  // cnt.callCount++;
  
  // args checking
  if(!nodeID) goto wrapup;
  //#if 0
  // if the nameDT already has nodeID in it, go to wrapup;
  // printf("nameDT.nodeID.objid[%d] nodeID->objid[%d]\n",nameDT.nodeID.objid,nodeID->objid);
  
  if(nameDT.nodeID.objid == nodeID->objid) {
    retFlag = 1;
    // if(traceFlag) printf("OOOOOOOOOOO Going Home! No work to do! OOOOOOOOOOOOOOOOO\n");
    goto wrapup;
  }
  //#endif

  // do the setup operation since nodeID does not match
  VDsaSetupNameDT();

  // now go get the data to fill up the structure nameDT
  nameDT.modelOE.obj_id.osnum = nodeID->osnum;
  nameDT.modelOE.obj_id.objid = nodeID->objid;  
  nameDT.nodeID.osnum = nodeID->osnum;
  nameDT.nodeID.objid = nodeID->objid;

  // now go get the nodeIDs of the tree
  VDsaGetNameDTTreeData();
  //strcpy(FieldValue,nameDT.pmName);
  retFlag = 1;
wrapup:
  // say bye
  // if(traceFlag) printf("<<< %s(%d)\n",fx,retFlag);
/*
  printf("\n*************************\n");
  printf("lookup [%d] search [%d] call [%d] clear [%d]\n",cnt.lookupCount,cnt.searchCount,cnt.callCount,cnt.clearCount);
  printf("*************************\n");
*/
  return retFlag;
}

/*****************************************************
 * Fill up the structure with the rest of the data 
 *****************************************************/
IGRstat VDsaGetNameDTTreeData() 
{
  IGRstat     retFlag = 0;
  IGRint      sts,i;
  //IGRstat     traceFlag = 1;
  IGRchar     setType[128],nodeType[128],nodeName[128];
  TGRid       tmpID;
  TVDvlaID    leafVLA;
  TGRid       leafID,parentID,nodeID;
  //IGRint      counter = 0;
  
  
  //IGRchar     fx[128];
  //strcpy(fx,"VDsaGetNameDTTreeData");
  
  // say hi
  //if(traceFlag) printf(">>> %s\n",fx);

  //
  parentID.objid = NULL_OBJID;
  leafID.objid = NULL_OBJID;

  nodeID.osnum  = nameDT.nodeID.osnum;
  nodeID.objid = nameDT.nodeID.objid;

  //if(traceFlag) printf("objOE is ready for leaf [%d] [%d]\n",objOE.obj_id.osnum,objOE.obj_id.objid);
  
  // make up leafVLA
  VDvlaID_Construct(&leafVLA);
  VDatGetObjectLeafsVLA(&nameDT.modelOE.obj_id,&leafVLA);
  //if(traceFlag) printf("WE are just before  leafID\n");
  
  // start looping through the leafVLA until the last one
  for(i = 0; VDvlaID_GetAt(&leafVLA,&leafID,i); i = i + 1)
    {
      // if(traceFlag) printf("Inside the loop leafID [%d] [%d]\n",leafID.osnum,leafID.objid);
      //counter = i;
      VDatGetNodeType(&leafID,nodeType);
      //VDatGetNodeName(&leafID,nodeName);
       // printf("XXXXXXXXBBBBBBXXXXXXX [%s] [%s] node[%d] [%d]\n",nodeType,nodeName,leafID.osnum,leafID.objid);
       // I wonder if this is all that is needed for this selection???
       if(!strcmp("PM",nodeType)) {
         VDsaLoadParentID(&leafID);
         // if(traceFlag) printf("We have a live one!!!!!!!!!!!!!!!!\n");
         // break;
       }
    }  // end of the leafVLA loop
  //if (traceFlag) printf("The leaf VLA search object went to [%d] leafs\n",i);
  
  retFlag = 1;
wrapup:
  // get rid of the vla object
  VDvlaID_Delete(&leafVLA);
  // say bye
  //if(traceFlag) printf("<<< %s(%d)\n",fx,retFlag);
  return retFlag;
}


/***************************************************************************************
 * Loads the structure with the appropriate data in the appropriate locations
 ***************************************************************************************/
IGRstat VDsaLoadParentID(TGRid *nodeID)
{
  IGRstat     retFlag = 0;
  //IGRstat     traceFlag = 1;
  IGRchar     setType[128],nodeType[128],nodeName[128];
  TGRid       nID,pID,*xID;
  IGRchar     fx[128];
  
  

  //strcpy(fx,"VDsaLoadParentID");

  // say hi
  // if(traceFlag) {
  //  printf(">>> %s\n",fx);
  //  printf("### nodeID [%d] [%d] \n",nodeID->osnum,nodeID->objid);
  // }
  
    // args check
    if(!nodeID) goto wrapup;
    if(nodeID->objid == NULL_OBJID) goto wrapup;
    
    // get it local
    nID.osnum = nodeID->osnum;
    nID.objid = nodeID->objid;
    
    //cnt.searchCount++;
    
    // put it in a loop!
    while(nID.objid != NULL_OBJID) {
      //cnt.lookupCount++;
      
      // get the data for comparison
      VDatGetNodeType(&nID,nodeType);
      //VDatGetNodeName(&nID,nodeName);    
      //VDatGetSetType(&nID,setType);
      
      
      // if(traceFlag) {
      //  printf("\n***********************************\n");
      //  printf("The Node [%d] [%d] nodeType [%s] nodeName[%s] setType [%s] \n",nID.osnum,nID.objid,nodeType,nodeName,setType);
      //  printf("***********************************\n\n");
      // }
      // ************  add any new node types here  **********************
      // ************  be sure to update the structure to handle any new types too!
      if(!strcmp(nodeType,"PSU")) {
        nameDT.psuID.osnum = nID.osnum;
        nameDT.psuID.objid = nID.objid;
      }
      else if(!strcmp(nodeType,"CPSU")) {
        nameDT.cpsuID.osnum = nID.osnum;
        nameDT.cpsuID.objid = nID.objid;
      }
      else if(!strcmp(nodeType,"SA")) {
        nameDT.saID.osnum = nID.osnum;
        nameDT.saID.objid = nID.objid;
      }
      else if(!strcmp(nodeType,"SAM")) {
        nameDT.samID.osnum = nID.osnum;
        nameDT.samID.objid = nID.objid;
      }
      else if(!strcmp(nodeType,"SAF")) {
        nameDT.safID.osnum = nID.osnum;
        nameDT.safID.objid = nID.objid;
      }
      else if(!strcmp(nodeType,"SAE")) {
        nameDT.saeID.osnum = nID.osnum;
        nameDT.saeID.objid = nID.objid;
      }
      else if(!strcmp(nodeType,"PSA")) {
        nameDT.psaID.osnum = nID.osnum;
        nameDT.psaID.objid = nID.objid;
      }
      else if(!strcmp(nodeType,"PM")) {
        nameDT.pmID.osnum = nID.osnum;
        nameDT.pmID.objid = nID.objid;
      }
      else if(!strcmp(nodeType,"UNIT")) {
        nameDT.unitID.osnum = nID.osnum;
        nameDT.unitID.objid = nID.objid;
        break;
      }

      // generate the next nID
      VDatGetParentNode(&nID,&pID);
      xID = &pID;
      nID = *xID;
    } // end of the loop 
    
    retFlag = 1;
  
 wrapup:
    // say bye
    //if(traceFlag) printf("<<< %s(%d)\n",fx,retFlag);
    return retFlag;
}
// setup the nameDT clear of any values
IGRstat VDsaSetupNameDT()
{
  // cnt.clearCount++;
  nameDT.modelOE.obj_id.objid = NULL_OBJID;
  nameDT.nodeID.objid         = NULL_OBJID; 
  nameDT.saID.objid           = NULL_OBJID;
  nameDT.psuID.objid          = NULL_OBJID;
  nameDT.cpsuID.objid         = NULL_OBJID;
  nameDT.pmID.objid           = NULL_OBJID;
  nameDT.unitID.objid         = NULL_OBJID;
  nameDT.safID.objid          = NULL_OBJID;
  nameDT.saeID.objid          = NULL_OBJID;
  nameDT.samID.objid          = NULL_OBJID;
  nameDT.psaID.objid          = NULL_OBJID;
  return 1;  
}


/************************************************************************************************
 * This routine is diagnostic only
 * It serves to provide a snapshot of the structure data in a user friendly form
 * It is prototyped vdsa$PrintNameDT(title = <string>); in VDsaUCM.h
 * This allows the calling location to be identified
 ************************************************************************************************/
IGRstat VDsaPrintNameDT(IGRchar *title)
{
  if(title) {
    printf("********** nameDT[%s] Print **************\n",title);
  }
  else {
    printf("********** nameDT Print **************\n");
  }
  
  printf("nodeID  [%d] [%d]\n",nameDT.nodeID.osnum,nameDT.nodeID.objid);
  printf("saID    [%d] [%d]\n",nameDT.saID.osnum,nameDT.saID.objid);
  printf("psuID   [%d] [%d]\n",nameDT.psuID.osnum,nameDT.psuID.objid);
  printf("cpsuID  [%d] [%d]\n",nameDT.cpsuID.osnum,nameDT.cpsuID.objid);
  printf("pmID    [%d] [%d]\n",nameDT.pmID.osnum,nameDT.pmID.objid);
  printf("unitID  [%d] [%d]\n",nameDT.unitID.osnum,nameDT.unitID.objid);
  printf("saeID   [%d] [%d]\n",nameDT.saeID.osnum,nameDT.saeID.objid);
  printf("safID   [%d] [%d]\n",nameDT.safID.osnum,nameDT.safID.objid);
  printf("samID   [%d] [%d]\n",nameDT.samID.osnum,nameDT.samID.objid);
  printf("psaID   [%d] [%d]\n",nameDT.psaID.osnum,nameDT.psaID.objid);
  printf("modelOE [%d] [%d]\n",nameDT.modelOE.obj_id.osnum,nameDT.modelOE.obj_id.objid);
  if(title) {
    printf("******* end nameDT[%s] Print**************\n",title);
  }
  else {
    printf("******* end nameDT Print**************\n");
  }
  
  return 1;
}


/**********************************************************************************************
 *  This routine is used to bring the data from the structure out to access in the ppl
 *  add any changes to the structure to this segment
 *  This provides the ability to name the items realistically for easy understanding
 *  in the PPL and with short address names not long structure complications
 *********************************************************************************************/
IGRstat VDsaGetNameDTData(TGRid *nodeID,TGRid *pmID,TGRid *saID,TGRid *psuID,TGRid *cpsuID,TGRid *unitID,TGRid *saeID,
                          TGRid *safID,TGRid *samID,TGRid *psaID,TGRobj_env *modelOE)
{
  if(nodeID)  *nodeID  = nameDT.nodeID;
  if(pmID)    *pmID    = nameDT.pmID;
  if(saID)    *saID    = nameDT.saID;
  if(psuID)   *psuID   = nameDT.psuID;
  if(cpsuID)  *cpsuID  = nameDT.cpsuID;
  if(unitID)  *unitID  = nameDT.unitID;
  if(saeID)   *saeID   = nameDT.saeID;
  if(safID)   *safID   = nameDT.safID;
  if(samID)   *samID   = nameDT.samID;
  if(psaID)   *psaID   = nameDT.psaID;
  if(modelOE) *modelOE = nameDT.modelOE;
  
  return 1;
}



end implementation VDatBase;















