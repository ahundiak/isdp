/* $Id: VDct1Model.I,v 1.2 2001/03/09 19:31:34 jdsauby Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdct1/tree/VDct1Model.I
 *
 * Description: Model Object interface Routines
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDct1Model.I,v $
 *      Revision 1.2  2001/03/09 19:31:34  jdsauby
 *      TR 4841, CRs 4847 (paint attribute), 4850 (Clean up node commands)
 *
 *      Revision 1.1  2001/01/12 15:14:10  art
 *      sp merge
 *
# Revision 1.11  2000/09/07  18:02:38  pinnacle
# js
#
# Revision 1.10  2000/09/04  14:42:50  pinnacle
# js
#
# Revision 1.9  2000/08/25  16:59:26  pinnacle
# js
#
# Revision 1.8  2000/08/24  13:48:16  pinnacle
# ah
#
# Revision 1.7  2000/08/23  19:33:38  pinnacle
# ah
#
# Revision 1.6  2000/08/23  14:51:58  pinnacle
# ah
#
# Revision 1.5  2000/08/17  11:40:08  pinnacle
# js
#
# Revision 1.4  2000/08/15  14:58:36  pinnacle
# js
#
# Revision 1.2  2000/08/11  13:21:30  pinnacle
# js
#
# Revision 1.1  2000/08/10  13:20:28  pinnacle
# Created: vds/vdct1/tree/VDct1Model.I by jdsauby for Service Pack
#
# Revision 1.1  2000/07/25  18:39:02  pinnacle
# ah
#
# Revision 1.4  2000/06/05  21:00:28  pinnacle
# ah
#
# Revision 1.3  2000/05/26  11:39:02  pinnacle
# Replaced: vds/vdct1/set/VDct1Model.I for:  by pnoel for Service Pack
#
# Revision 1.2  2000/05/15  15:26:26  pinnacle
# Replaced: vds/vdct1/set/VDct1Model.I for:  by pnoel for Service Pack
#
# Revision 1.1  2000/04/20  18:43:14  pinnacle
# Created: vds/vdct1/set/VDct1Model.I by pnoel for Service Pack
#
# Revision 1.3  2000/01/11  22:26:02  pinnacle
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
 ***************************************************************************/
class implementation Root;
#include "VDct1.h"
#include "VDobj.h"
#include "VDchn.h"
#include "VDdir.h"
#include "VDppl1.h"
#include "VDsa.h"
#include "v_miscmacros.h"

#include "VDct1Tree.h"
#include "VDct1Tree2.h"
#include "VDct1Forms.h"
#include "VDct1Attrs.h"
#include "VDct1Part.h"

#include "VDct1Trace.h"

#include "VDassert.h"

VDASSERT_FFN("vdct1/tree/VDct1Model.I");

#define MY_TREE VDCT1_TREE_TYPE_ROOT_TREE

// Keep copies of the channel selection
static struct {
  IGRint          init;
  OM_S_CHANSELECT select;
} notifyChn,listenerChn;

from GRnotify import GRntfyconn;
from GRnotify import GRntfydisconn;
from GRvg     import GRputname;

extern VDclassid OPP_VDct1Base_class_id;

from VDct1Base import ACload_macro;
from VDSroot   import VDprocAttr;

/* -------------------------------------------------------------
 * get node data content from model
 * wrapper to get at the om$send function
 * must be in the *.I file to function
 */
static IGRstat getModelPartData(TVDct1JD *nodeJD,VDprcAttr *mp)
{
  VDASSERT_FN("getModelPartData");
  
  IGRstat        retFlag = 0;
  IGRstat        sts,flag;
  TGRobj_env     modelOE;
  TVDct1JD       workJD;
  IGRlong        suc;
  IGRchar        volume[128];
  IGRchar        weight[128];
  
  // Arg Check
  VDASSERTW(nodeJD && nodeJD->cl);
  VDASSERTW(nodeJD->id.objid != NULL_OBJID);
  VDASSERTW(mp);
  
  // say hi
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
  // set the memory available
  memset(mp,0,sizeof(VDprcAttr));
  // get the modelOE
  VDjt1GetModelObject(nodeJD,&modelOE);
  if(modelOE.obj_id.objid == NULL_OBJID) goto wrapup;

  flag = 0xFF;

  // go get the data
  sts = om$send(msg = message VDSroot.VDprocAttr(&suc,&modelOE.mod_env,flag,mp),
		senderid = NULL_OBJID,
		targetid = modelOE.obj_id.objid,
		targetos = modelOE.obj_id.osnum);
  if (!(sts & suc & 1)) goto wrapup;
  
  // Done
  retFlag = 1;
  
wrapup:
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  return retFlag;

}

/* --------------------------------------------
 * Delete a node
 */
static IGRstat deleteNode(TVDct1JD *nodeJD)
{
  VDASSERT_FN("deleteNode");
  
  IGRstat retFlag = 0;
  IGRstat sts;

  TVDct1JD   workJD;
  TVDclaType type;
  
  // Arg Check
  VDASSERTW(nodeJD->id.objid != NULL_OBJID);
  VDASSERTW(nodeJD->cl != NULL);
  
  // say hi
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

  // Ignore non VDctBase objects
  vdcla$Get(objID = &nodeJD->id,
	    type  = &type);
  
  if (type == VDCLA_TYPE_NONE) {
    retFlag = 1;
    goto wrapup;
  }
  
  // Disconnect from any listeners
  
  // Disconnect from any parents
  _RTCJDB(nodeJD)->getTreeParent(nodeJD,&workJD);
  _RTCJDB(&workJD)->disconnectTreeChild(&workJD,nodeJD);

  //vdct1$GetTree2Parent(objID = nodeID, outID = &workID);
  //vdct1$DisConnectTree2Child(treeID = &workID, childID = nodeID);

  _RTCJDB(nodeJD)->getMgrParent(nodeJD,&workJD);
  _RTCJDB(&workJD)->disconnectMgrChild(&workJD,nodeJD);
  
  // Delete any children
  while(_RTCJDB(nodeJD)->getTreeChild(nodeJD,0,&workJD)) {
    _RTCJDB(&workJD)->deleteNode(&workJD);
  }
  //while(vdct1$GetTree2Child(objID = nodeID, outID = &workID)) {
  //  vdct1$DeleteNode(nodeID = &workID);
  //}
  while(_RTCJDB(nodeJD)->getMgrChild(nodeJD,0,&workJD)) {
    _RTCJDB(&workJD)->deleteNode(&workJD);
  }

  // And delete
  //  VDct1DeleteRootObject(nodeID);
  om$send(msg = message Root.delete(0),
	  senderid = NULL_OBJID,
	  targetid = nodeJD->id.objid,
	  targetos = nodeJD->id.osnum);
  
  // Done
  retFlag = 1;
  
wrapup:
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  return retFlag;
}


/* ---------------------------------------------
 * Wrapper to GRputname which is required
 * to actually name a node
 * Name is actually the full path
 */
IGRstat VDct1GRputname(TGRid *nodeID, IGRchar *name)
{
  VDASSERT_FN("VDct1GRputname");
  IGRstat retFlag = 0;
  IGRstat sts,msg;
  
  VDASSERTW(nodeID && nodeID->objid != NULL_OBJID);
  VDASSERTW(name);
  
  sts = om$send(msg = message GRvg.GRputname(&msg,name),
		senderid = NULL_OBJID,
		targetid = nodeID->objid,
		targetos = nodeID->osnum);
  VDASSERTW(sts & msg & 1);
  
  retFlag = 1;
  
 wrapup:
  return retFlag;
}


/* ----------------------------------------------
 * cable objects inheret the compt number from
 * the parent equipment.  We need to utilize the VCEquipID
 * function which will return the modelObject of the parent
 * equipment for the cable objects.
 * This function is used only for CableTree
 */
static IGRstat getComptNumberAttrForCableObject(TVDct1JD   *nodeJD,
						TGRobj_env *modelOE,
						IGRchar    *attrCompt)
{
  VDASSERT_FN("getComptNumberAttrForCableObject");

  IGRstat retFlag = 0;
  IGRstat sts;
  IGRlong msg;
    
  IGRchar     comptNumber[64];

  TGRid       equipID;
  TGRid       objID;
    
  VDASSERTW(attrCompt);
  VDASSERTW((modelOE->obj_id.objid != 0) && (modelOE->obj_id.objid != NULL_OBJID));
  
  // say hi
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
  
  // init
  equipID.objid = NULL_OBJID;
  objID         = modelOE->obj_id;
  *attrCompt    = 0;
  
    
  // if it is a VREquipment, then we can get it directly
  sts = vdobj$IsAncestryValid(objID = &objID,
			      superClassName = "VREquipment");
  if (sts & 1) {
    // It's own attribute
    sts = vdsa$GetStruct(objID = &objID, name  = "compt_number", txt = comptNumber);
    if (!(sts & 1)) goto wrapup;
    strcpy(attrCompt,comptNumber);
    retFlag = 1;
    goto wrapup;  
  }

  // if it is a VCRoot, ask the parent VREquipment
  sts = vdobj$IsAncestryValid(objID = &objID,
			      superClassName = "VCMac");
  if (sts & 1) {
    // get the equipment ID
    struct {
      IGRlong *suc;
      TGRid   *mp;
    } msgArgs;

    OM_S_MESSAGE msgMass;

    msgArgs.suc = &msg;
    msgArgs.mp  = &equipID;
    equipID.objid = NULL_OBJID;
    
    sts = om$make_message(classname  = "VCMac",
			  methodname = "VCGetEquipId",
			  size       = sizeof(msgArgs),
			  p_arglist  = &msgArgs,
			  p_msg      = &msgMass);

    sts= om$send(msg      = &msgMass,
		 senderid = NULL_OBJID,
		 targetid = objID.objid,
		 targetos = objID.osnum);
  
    VDASSERTW(equipID.objid != NULL_OBJID);
    if (traceFlag) {
      vdobj$Print(objID = &equipID);
    }
    
    
    // get the compt number for the equipment
    sts = vdsa$GetStruct(objID = &equipID, name  = "compt_number", txt = comptNumber);
    if (traceFlag) printf("### %s %s %s\n",ffn(),fn,comptNumber);
    
    if (!(sts & 1)) goto wrapup;
    strcpy(attrCompt,comptNumber);
    retFlag = 1;
    goto wrapup;  

  }

  // done
  
  
wrapup:
  if (traceFlag) printf("<<< %s %s %d %s\n",ffn(),fn,retFlag,attrCompt);
  return retFlag;
}

/* ----------------------------------------------
 * cable objects inheret the compt number from
 * the parent equipment.  We need to utilize the VCEquipID
 * function which will return the modelObject of the parent
 * equipment for the cable objects.
 * This function is used only for CableTree
 */
static IGRstat getUnitNumberAttrForCableObject(TVDct1JD   *nodeJD,
					       TGRobj_env *modelOE,
					       IGRchar    *attrUnit)
{
  VDASSERT_FN("getUnitNumberAttrForCableObject");

  IGRstat retFlag = 0;
  IGRstat sts;
  IGRlong msg;
    
  IGRchar     unitNumber[64];

  TGRid       equipID;
  TGRid       objID;
    
  VDASSERTW(attrUnit);
  VDASSERTW((modelOE->obj_id.objid != 0) && (modelOE->obj_id.objid != NULL_OBJID));
  
  // say hi
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
  
  // init
  equipID.objid = NULL_OBJID;
  objID         = modelOE->obj_id;
  *attrUnit     = 0;
  
    
  // if it is a VREquipment, then we can get it directly
  sts = vdobj$IsAncestryValid(objID = &objID,
			      superClassName = "VREquipment");
  if (sts & 1) {
    // It's own attribute
    sts = vdsa$GetStruct(objID = &objID, name  = "unit_number", txt = unitNumber);
    if (!(sts & 1)) goto wrapup;
    strcpy(attrUnit,unitNumber);
    retFlag = 1;
    goto wrapup;  
  }

  // if it is a VCRoot, ask the parent VREquipment
  sts = vdobj$IsAncestryValid(objID = &objID,
			      superClassName = "VCMac");
  if (sts & 1) {
    // get the equipment ID
    struct {
      IGRlong *suc;
      TGRid   *mp;
    } msgArgs;

    OM_S_MESSAGE msgMass;

    msgArgs.suc = &msg;
    msgArgs.mp  = &equipID;
    equipID.objid = NULL_OBJID;
    
    sts = om$make_message(classname  = "VCMac",
			  methodname = "VCGetEquipId",
			  size       = sizeof(msgArgs),
			  p_arglist  = &msgArgs,
			  p_msg      = &msgMass);

    sts= om$send(msg      = &msgMass,
		 senderid = NULL_OBJID,
		 targetid = objID.objid,
		 targetos = objID.osnum);
  
    VDASSERTW(equipID.objid != NULL_OBJID);
    if (traceFlag) {
      vdobj$Print(objID = &equipID);
    }
    
    
    // get the unit number for the equipment
    sts = vdsa$GetStruct(objID = &equipID, name  = "unit_number", txt = unitNumber);
    if (traceFlag) printf("### %s %s %s\n",ffn(),fn,unitNumber);
    
    if (!(sts & 1)) goto wrapup;
    strcpy(attrUnit,unitNumber);
    retFlag = 1;
    goto wrapup;  

  }

  // done
  
  
wrapup:
  if (traceFlag) printf("<<< %s %s %d %s\n",ffn(),fn,retFlag,attrUnit);
  return retFlag;
}


/* --------------------------------------------------------------------
 * Connects a node to a model object
 * Nothing fancy, just makes the connection
 */
static IGRstat connectModelObject(TVDct1JD *nodeJD, TGRobj_env *modelOE)
{
  VDASSERT_FN("connectModelObject");
  
  IGRstat       retFlag = 0;
  IGRstat       sts,msg;
  IGRint        index  = OM_K_MAXINT;
  IGRboolean    tagged = FALSE;
  OMuint        modelTag;
  GRspacenum    prevOS, dummyOS;
  IGRboolean    tagFlag = 0;

  TGRid  nodeID;
  
 

  VDASSERTW(nodeJD->id.objid != NULL_OBJID);  
  nodeID = nodeJD->id;
  VDASSERTW((modelOE->obj_id.objid != 0) && (modelOE->obj_id.objid != NULL_OBJID));

  
  
  // Say Hi
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn);
    vdobj$Print(objID = &nodeID);
    vdobj$Print(objOE = modelOE);
  }
 

  // Init the channels
  if (notifyChn.init == 0) {

    // Make selection
    sts = om$make_chanselect(channame     = "GRnotify.notification", 
			     p_chanselect = &notifyChn.select);
    if (!(sts & 1)) goto wrapup;
    notifyChn.init = 1;
  }
  if (traceFlag) printf("### %s %s notifyChn.init = %d\n",ffn(),fn,notifyChn.init);
  
  if (listenerChn.init == 0) {

    // Make selection
    sts = om$make_chanselect(channame     = "VDct1Base.to_notify", 
			     p_chanselect = &listenerChn.select);
    if (!(sts & 1)) goto wrapup;
    listenerChn.init = 1;
  }
  if (traceFlag) printf("### %s %s listenerChn.init = %d\n",ffn(),fn,notifyChn.init);

  // Arg Check
  if ((nodeJD  == NULL) || (nodeJD->id.objid == NULL_OBJID)) goto wrapup;
  if ((modelOE == NULL) || (modelOE->obj_id.objid == NULL_OBJID)) goto wrapup;

  // Make it a tagged connection if in ref file
  if (modelOE->obj_id.osnum != nodeJD->id.osnum) {

    sts = om$objid_to_tag(osnum = modelOE->obj_id.osnum,
			  objid = modelOE->obj_id.objid,
			  p_tag = &modelTag);
    if (traceFlag) {
    printf(">>> om$objid_to_tag(\n");
    vdobj$Print(objID = &nodeID);
    vdobj$Print(objOE = modelOE);
    }

    if (sts == OM_S_SUCCESS) {

      tagFlag = om$enable_tag_connects( flag = TRUE );

      om$set_tag_os(p_prev_osnum = &prevOS, 
		    osnum        =  modelOE->obj_id.osnum );
  if (traceFlag) {
    printf(">>> om$set_tag_os(\n");
    vdobj$Print(objID = &nodeID);
    vdobj$Print(objOE = modelOE);
  }
  
    }
  }
  
  // Connect it
  if (traceFlag) printf("### %s %s attempting to connect\n",ffn(),fn);
  
  sts = om$send(msg = message
		GRnotify.GRntfyconn(&msg,
				    &nodeID, // &nodeJD->id
				    &listenerChn.select,
				    &index,
				    &tagged,NULL),
		senderid = NULL_OBJID,
		targetid = modelOE->obj_id.objid,
		targetos = modelOE->obj_id.osnum);
  if (traceFlag) {
    printf(">>> om$send .... \n");
    printf("STS came back %d\n",sts);
    vdobj$Print(objID = &nodeID);
    vdobj$Print(objOE = modelOE);
  }
  
  // Reset tag stuff
  if (tagFlag) {
    om$set_tag_os(p_prev_osnum = &dummyOS, osnum = prevOS);
  }
  
  // Check error
  if (!(sts & msg & 1)) {
    printf("*** Node to Model connection failed\n");
    goto wrapup;
  }
  
  // Done
  retFlag = 1;
  
wrapup:
  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
    vdobj$Print(objID = &nodeID);
    vdobj$Print(objOE = modelOE);
  }
  
  return retFlag;
}

/* ------------------------------------------------------
 * 6 Disconnect Model Node
 * disconnect a model object from its attachment to the model
 * used to allow the user to go back and disconnect a part 
 * that was misconnected
 * nothing too fancy just get the modelOE disconnected
 */
static IGRstat disconnectModelObject(TVDct1JD   *fakeJD,
	                             TGRobj_env *modelOE)
{
  VDASSERT_FN("disconnectModelObject");

  IGRstat        retFlag = 0;
  IGRstat        sts;
  IGRlong        msg;
  TVDct1JD       nodeJD;

  listenerChn.init = 0;

  VDASSERTW((modelOE->obj_id.objid != 0) && (modelOE->obj_id.objid != NULL_OBJID));
  VDASSERTW(fakeJD->cl != NULL);

  // say hi
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
  
  // Make selection
  sts = om$make_chanselect(channame     = "VDct1Base.to_notify", 
		           p_chanselect = &listenerChn.select);
  if (!(sts & 1)) goto wrapup;
  
  listenerChn.init = 1;
  
  // check the model for channel connection
  sts = _RTCJDB(fakeJD)->
           getModelObjectNode(fakeJD,modelOE,NULL,NULL,NULL,NULL,&nodeJD);

  // if it is not here go home
  if (nodeJD.id.objid == NULL_OBJID) goto wrapup;
 
  // disConnect it
  if (traceFlag) printf("Sending the disconnect\n");

  sts = om$send(msg = message
		GRnotify.GRntfydisconn(&msg,
				       &nodeJD.id,
				       &listenerChn.select),
		senderid = NULL_OBJID,
		targetid = modelOE->obj_id.objid,
		targetos = modelOE->obj_id.osnum);

  if (traceFlag) {
    printf(">>> om$send .... \n");
    vdobj$Print(objID = &nodeJD.id);
    vdobj$Print(objOE = modelOE);
  }
 
  // success
  retFlag = 1;

  // oh well
wrapup:
  // say bye
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag); 
  return retFlag;
  
}


/* ----------------------------------------------------------------------
 * Get the model attached to the node
 */ 
static IGRstat getModelObject(TVDct1JD   *nodeJD,
			      TGRobj_env *modelOE)
{
  VDASSERT_FN("getModelObject");
  
  IGRstat retFlag = 0;
  TGRid   modelID;
  TGRid   nodeID;
    
  // Say hi
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

  // Arg check
  VDASSERTW(modelOE);
  modelOE->obj_id.objid = NULL_OBJID;
  VDASSERTW(nodeJD && nodeJD->cl);
    
  // init
  nodeID = nodeJD->id;
  
  // do it
  vdchn$Get2(objID   = &nodeID, 
	     chnName = "VDct1Base.to_notify", 
	     nth     = 0,
	     outID   = &modelID);

  if (modelID.objid == NULL_OBJID) goto wrapup;
  modelOE->obj_id = modelID;
  
  // Fake the enviroment for now
  gr$get_module_env(buffer = &modelOE->mod_env);

  modelOE->mod_env.md_id.osnum = modelID.osnum;
  
  ex$get_modid(mod_osnum =  modelOE->mod_env.md_id.osnum,
	       mod_id    = &modelOE->mod_env.md_id.objid);

  // Done
  retFlag = 1;
  
wrapup:
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  
  return retFlag;
}


/* ------------------------------------------------------------
 * Display a node with recursive flag
 */ 
static IGRstat displayNode(TVDct1JD      *nodeJD,
			   enum GRdpmode mode,
			   IGRint        flag)
{
  VDASSERT_FN("displayNode");
  
  IGRstat retFlag = 1;
  
  TGRobj_env modelOE;
  TVDct1JD   childJD;
  IGRint     i;

  // Get the model
  _RTCJDB(nodeJD)->getModelObject(nodeJD,&modelOE);
  

  // Display it
  if (modelOE.obj_id.objid != NULL_OBJID) {

    vd_$bulk_display(dpmode = mode, objenvs = &modelOE);
    
  }

  // If no recursion then done
  if (flag == 0) goto wrapup;

  for(i = 0; 
      _RTCJDB(nodeJD)->getTreeChild(nodeJD,i,&childJD);
      i++) {

    _RTCJDB(&childJD)->displayNode(&childJD,mode,flag);
  }

  // Done

wrapup:
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  
  return retFlag;
}

extern VDclassid OPP_VDct1Base_class_id;


/* ------------------------------------------------------------
 * Given a model object, find the tree it is attached to
 * Allow filtering by set type,name and ver
 */
static IGRstat getModelObjectNode(TVDct1JD        *fakeJD,    // just for the class
				  TGRobj_env      *a_modelOE, // I - model object
				  TGRid           *a_modelID, // I - model object
				  TVDctSetType     setType,   // I - filter
				  TVDctSetTypeRev  setRev,    // I - filter
				  TVDctSetName     setName,   // I - filter
				  TVDct1JD        *nodeJD)    // O - The node
{
  VDASSERT_FN("getModelObjectNode");

  IGRstat         retFlag    = 0;
  
  IGRstat sts;
  
  TGRid   modelID;

  TVDvlaID  notifyVLA;
  TGRid     notifyID;
  TVDct1JD  notifyJD;
    
  IGRint    i;
  
  // say hi
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

  // Init
  vdvla_id$Construct(vla = &notifyVLA);
  
  // Arg check
  if (nodeJD) nodeJD->id.objid = NULL_OBJID;

  // Get the model object
  modelID.objid = NULL_OBJID;
  if (a_modelOE) modelID =  a_modelOE->obj_id;
  if (a_modelID) modelID = *a_modelID;
  if (modelID.objid == NULL_OBJID) goto wrapup;

  // Cycle through listener looking for ACpretendins
  vdchn$Get2(objID  = &modelID,
	     chnIDx = VDCHN_IDX_NOTIFICATION,
	     outVLA = &notifyVLA);

 
  for(i = 0; 
      vdvla_id$GetAt(vla   = &notifyVLA,
		     nth   =  i,
		     objID = &notifyID); 
      i++) {
    
    // Check the filters
    notifyJD.id = notifyID;
    notifyJD.cl = VDct1GetTreeClassForNode(&notifyID);
    if (notifyJD.cl) {
      
      sts = _RTCJDB(&notifyJD)->
	getModelObjectNodeFilter(&notifyJD,setType,setRev,setName);
      if (sts & 1) {
	if (nodeJD) *nodeJD = notifyJD;
	
	retFlag = 1;
	goto wrapup;
      }
    }
  }
  
  // Done, not found
  
wrapup:
  vdvla_id$Delete(vla = &notifyVLA);   
  // say bye
  if (traceFlag) printf("<<< %s %s %d\n\n",ffn(),fn,retFlag);
  return retFlag;
}

/* -----------------------------------------------
 * Inits these pointers
 */
IGRstat VDct1InitModel(TVDct1RootTreeClass *cl)
{
  VDASSERT_FN("VDct1InitModel");
  
  IGRstat retFlag = 0;


  traceFlagx = traceFlag = VDct1TraceFlag(VDCT1_TRACE_TREE_BASE);
     
  // Fill up pointers
  cl->base.connectModelObject            = connectModelObject;
  cl->base.disconnectModelObject         = disconnectModelObject;
  cl->base.getModelObject                = getModelObject;
  cl->base.displayNode                   = displayNode;

  cl->base.getModelObjectNode            = getModelObjectNode;

  cl->base.getComptNumberAttrForCableObject = getComptNumberAttrForCableObject;
  cl->base.getUnitNumberAttrForCableObject  = getUnitNumberAttrForCableObject;

  cl->base.deleteNode        = deleteNode;
  cl->base.getModelPartData  = getModelPartData;
     
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}


end implementation Root;


