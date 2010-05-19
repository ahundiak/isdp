/* $Id: VDct1Model.I,v 1.4 2001/03/12 20:36:48 jdsauby Exp $  */

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
 *      $Log: VDct1Model.I,v $
 *      Revision 1.4  2001/03/12 20:36:48  jdsauby
 *      Cleaned out unnecessary functions from vdct1/set
 *
 *      Revision 1.3  2001/01/12 14:53:35  art
 *      sp merge
 *
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

#include "VDassert.h"

VDASSERT_FFN("vdct1/set/VDct1Model.C");


// Keep copies of the channel selection
static struct {
  IGRint          init;
  OM_S_CHANSELECT select;
} notifyChn,listenerChn;

from GRnotify import GRntfyconn;

IGRstat VDct1CopyAttributesFromModelToNode(TGRid      *nodeID,
					   TGRobj_env *modelOE);

IGRstat VDct1CopyAttributeFromModelToNode(TGRid      *nodeID, 
					  IGRchar    *nodeAttrName,
					  TGRobj_env *modelOE,
					  IGRchar    *modelAttrName);

#if 0
/* --------------------------------------------------
 * Just a wrapper to the ppl
 */ 

IGRstat VDct1GetTypeForModelObject(TGRid         *parentNodeID,
				   TGRobj_env    *modelOE,
				   TVDctNodeType  nodeType)
{
  IGRstat retFlag = 0;
  TGRid   pplID;
  IGRint  pplRet;

  TVDctBaseInfo baseInfo;
 
  // Arg check
  if (parentNodeID->objid == NULL_OBJID) goto wrapup;
  if (nodeType == NULL) goto wrapup;
  *nodeType = 0;

  // Check this for the ppl
  vdct1$GetBaseInfo(objID = parentNodeID, baseInfo = &baseInfo);
  if (*baseInfo.nodeType == 0) goto wrapup;

  // The ppl does the work
  vdppl$Load(name = baseInfo.setType, pplID = &pplID);
  if (pplID.objid == NULL_OBJID) goto wrapup;

  vdppl$SetData(pplID = &pplID,
                name  = "PIECE_OE",
                size  = sizeof(TGRobj_env),
                data  = (IGRchar*)modelOE);

  vdppl$SetData(pplID = &pplID,
                name  = "NODE_PARENT_ID",
                size  = sizeof(TGRid),
                data  = (IGRchar*)parentNodeID);

  vdppl$SetData(pplID = &pplID,
                name  = "BASE_INFO",
                size  = sizeof(TVDctBaseInfo),
                data  = (IGRchar*)&baseInfo);

  vdppl$Run(pplID = &pplID, 
	    name  = "getTypeForModelObject", 
	    ret   = &pplRet);

  vdppl$GetData(pplID = &pplID,
                name  = "NODE_TYPE",
                size  = sizeof(TVDctNodeType),
                data  = (IGRchar*)baseInfo.nodeType);

  strcpy(nodeType,baseInfo.nodeType);
  
  retFlag = 1;


  // Done 

wrapup:  
  return retFlag;
}
#endif 

/* --------------------------------------------------------------------
 * Copies attributes from model to node
 * This needs to call a ppl
 */ //
IGRstat VDct1CopyAttributesFromModelToNode(TGRid      *nodeID,
					   TGRobj_env *modelOE)
{
  IGRstat retFlag = 0;
  IGRchar buf[256],tmp[256];
  
  TVDfld fld;

  TVDctBaseInfo baseInfo;

  // Arg check
  if (nodeID  == NULL) goto wrapup;
  if (modelOE == NULL) goto wrapup;
  
  // Build the isdp_name
  vdsa$GetStruct(objOE = modelOE, name = "eqp_family", txt = tmp);
  strcpy(buf,tmp);
  strcat(buf,":");
  vdsa$GetStruct(objOE = modelOE, name = "eqp_partno", txt = tmp);
  strcat(buf,tmp);
  strcat(buf,":");
  vdsa$GetStruct(objOE = modelOE, name = "eqp_partrev", txt = tmp);
  strcat(buf,tmp);
  strcat(buf,":");
  vdobj$Get(objOE = modelOE, objName = tmp);
  strcat(buf,tmp);
  
  vdcol$GetAttr(objID = nodeID, name = "teng_isdp_name", fld = &fld);
  if (*fld.name) {
    VDstrupr(buf);
    strcpy(fld.val.txt,buf);
    vdcol$UpdAttrs(objID = nodeID, cnt = 1, fld = &fld);
  }
  
  // Add the path
  vdobj$Get(objOE = modelOE, objPath = tmp);
  
  vdcol$GetAttr(objID = nodeID, name = "teng_isdp_path", fld = &fld);
  if (*fld.name) {
    VDstrupr(tmp);
    strcpy(fld.val.txt,tmp);
    vdcol$UpdAttrs(objID = nodeID, cnt = 1, fld = &fld);
  }
  
  // Other attributes
  
  //VDct1CopyAttributeFromModelToNode(nodeID,
  //			    "teng_unit_num",
  //			    modelOE,
  //			    "unit_number");
  vdct1$CopyAttributeFromModelToNode(nodeID        = nodeID,
				     nodeAttrName  = "teng_unit_num",
				     modelOE       = modelOE,
				     modelAttrName = "unit_number"
				     );
  

    //VDct1CopyAttributeFromModelToNode(nodeID,
    //			    "teng_compt_num",
    //			    modelOE,
    //			    "compt_number");
  vdct1$CopyAttributeFromModelToNode(nodeID        = nodeID,
				     nodeAttrName  = "teng_compt_num",
				     modelOE       =  modelOE,
				     modelAttrName = "compt_number"
				     );
  
  // Pull zone from 
  vdct1$GetBaseInfo(objID = nodeID, baseInfo = &baseInfo);
  sprintf(buf,"%s:%s:%s:%s:",
	  baseInfo.setType,
	  baseInfo.setName,
	  baseInfo.nodeType,
	  baseInfo.nodeName);

  vdcol$GetAttr(objID = nodeID, name = "teng_isdp_zone", fld = &fld);
  if (*fld.name) {
    VDstrupr(buf);
    strcpy(fld.val.txt,buf);
    vdcol$UpdAttrs(objID = nodeID, cnt = 1, fld = &fld);
  }
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* --------------------------------------------------------------------
 * Transfer attribute from model to node
 */
IGRstat VDct1CopyAttributeFromModelToNode(TGRid      *nodeID, 
					  IGRchar    *nodeAttrName,
					  TGRobj_env *modelOE,
					  IGRchar    *modelAttrName)
{
  IGRstat retFlag = 0;
  TVDfld  fld;

  IGRchar buf[128];
  
  // Start by getting the node attribute
  vdcol$GetAttr(objID = nodeID, name = nodeAttrName, fld = &fld);
  if (*fld.name == 0) goto wrapup;
  
  // Get from model
  vdsa$GetStruct(objOE = modelOE, name = modelAttrName, txt = buf);
  
  // Copy data
  strcpy(fld.val.txt,buf);
  VDstrupr(fld.val.txt);
  
  // And update
  vdcol$UpdAttrs(objID = nodeID, cnt = 1, fld = &fld);
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* --------------------------------------------------------------------
 * Connects a node to a model object
 * Nothing fancy, just makes the connection
 *
 * 30 Dec 1999 - Added the tagged connection code
 */
IGRstat VDct1ConnectNodeToModelObject(TGRid *nodeID, TGRobj_env *modelOE)
{
  VDASSERT_FN("VDct1ConnectNodeToModelObject");
  
  IGRstat       retFlag = 0;
  IGRstat       sts,msg;
  IGRint        index  = OM_K_MAXINT;
  IGRboolean    tagged = FALSE;
  OMuint        modelTag;
  GRspacenum    prevOS, dummyOS;
  IGRboolean    tagFlag = 0;
  TVDctBaseInfo baseInfo;
  
  // Say Hi
  traceFlag = 0;
  if (traceFlag) {
    printf(">>> VDct1ConnectNodeToModelObject\n");
    vdobj$Print(objID = nodeID);
    vdobj$Print(objOE = modelOE);
  }
  
  // Quick check to make sure not already connected
  vdct$GetBaseInfo(objID = nodeID, baseInfo = &baseInfo);
#if 0
  sts = VDct1GetModelObjectNode(modelOE,NULL,baseInfo.setType,NULL,NULL,NULL);
  if (sts & 1) {
    printf("*** Already connected\n");
    goto wrapup;
  }
#endif

  // Init the channels
  if (notifyChn.init == 0) {

    // Make selection
    sts = om$make_chanselect(channame     = "GRnotify.notification", 
			     p_chanselect = &notifyChn.select);
    if (!(sts & 1)) goto wrapup;
    notifyChn.init = 1;
  }
  if (listenerChn.init == 0) {

    // Make selection
    sts = om$make_chanselect(channame     = "VDct1Base.to_notify", 
			     p_chanselect = &listenerChn.select);
    if (!(sts & 1)) goto wrapup;
    listenerChn.init = 1;
  }

  if (traceFlag) {
    printf(">>> Args check\n");
    vdobj$Print(objID = nodeID);
    vdobj$Print(objOE = modelOE);
  }
  
  // Arg Check
  if ((nodeID  == NULL) || (nodeID->objid == NULL_OBJID)) goto wrapup;
  if ((modelOE == NULL) || (modelOE->obj_id.objid == NULL_OBJID)) goto wrapup;

  // Make it a tagged connection if in ref file
  if (modelOE->obj_id.osnum != nodeID->osnum) {

    sts = om$objid_to_tag(osnum = modelOE->obj_id.osnum,
			  objid = modelOE->obj_id.objid,
			  p_tag = &modelTag);
  if (traceFlag) {
    printf(">>> om$objid_to_tag((((\n");
    vdobj$Print(objID = nodeID);
    vdobj$Print(objOE = modelOE);
  }
  
    if (sts == OM_S_SUCCESS) {
      if (traceFlag) printf("Successful send of tag\n");
      
      // tagged = TRUE;
      
      tagFlag = om$enable_tag_connects( flag = TRUE );

      om$set_tag_os(p_prev_osnum = &prevOS, 
		    osnum        =  modelOE->obj_id.osnum );
  if (traceFlag) {
    printf(">>> om$set_tag_os(\n");
    vdobj$Print(objID = nodeID);
    vdobj$Print(objOE = modelOE);
  }
  

    }
  }
  
  // Connect it
  if (traceFlag) printf("Sending the connect\n");

  sts = om$send(msg = message
		GRnotify.GRntfyconn(&msg,
				     nodeID,
				    &listenerChn.select,
				    &index,
				    &tagged,NULL),
		senderid = NULL_OBJID,
		targetid = modelOE->obj_id.objid,
		targetos = modelOE->obj_id.osnum);
  if (traceFlag) {
    printf(">>> om$send .... \n");
    printf("STS came back %d\n",sts);
    vdobj$Print(objID = nodeID);
    vdobj$Print(objOE = modelOE);
  }
  
  if (traceFlag) printf("Returned from connect\n");

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
    printf("<<< VDct1ConnectNodeToModelObject %d\n",retFlag);
    vdobj$Print(objID = nodeID);
    vdobj$Print(objOE = modelOE);
  }
  
  return retFlag;
}

/* ----------------------------------------------------------------------
 * Get the model attached to the node
 */ 
IGRstat VDct1GetNodeModelObject(TGRid *nodeID, TGRobj_env *modelOE)
{
  IGRstat retFlag = 0;
  TGRid   modelID;
  
  // Arg check
  if (modelOE == NULL) goto wrapup;
  modelOE->obj_id.objid = NULL_OBJID;

  if ((nodeID == NULL) || (nodeID->objid == NULL_OBJID)) goto wrapup;

  vdchn$Get2(objID   = nodeID, 
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
  return retFlag;
}

#if 0
/* ------------------------------------------------------------
 * Display a node with recursive flag
 */ 
IGRstat VDct1DisplayNode(TGRid *nodeID, enum GRdpmode mode, IGRint flag)
{
  IGRstat retFlag = 1;
  
  TGRobj_env modelOE;
  TGRid      childID;
  IGRint     i;

  // Get the model
  vdct1$GetNodeModelObject(nodeID  = nodeID,
			   modelOE = &modelOE);
  

  // Display it
  if (modelOE.obj_id.objid != NULL_OBJID) {

    vd_$bulk_display(dpmode = mode, objenvs = &modelOE);
    
  }

  // If no recursion then done
  if (flag == 0) goto wrapup;

  for(i = 0; 
      vdct1$GetTree1Child(objID = nodeID, nth = i, outID = &childID);
      i++) {

    vdct1$DisplayNode(nodeID = &childID, 
		      mode =  mode, 
		      flag = flag);
  }

  // Done

wrapup:
  return retFlag;
}
#endif
extern VDclassid OPP_VDct1Base_class_id;

/* ------------------------------------------------------------
 * Little helper to do the filtering
 */
IGRstat VDct1GetModelObjectNodeFilter(TGRid           *nodeID,    // I - node object
				      TVDctSetType     setType,   // I - filter
				      TVDctSetTypeRev  setRev,    // I - filter
				      TVDctSetName     setName)   // I - filter
{
  IGRstat retFlag = 0;
  IGRstat sts;

  TVDctBaseInfo baseInfo;
  
  // Make sure its a base object
  sts = vdobj$IsAncestryValid(objID        = nodeID,
			      superClassID = OPP_VDct1Base_class_id);
  if (!(sts & 1)) goto wrapup;
  
  // Get the info
  vdct$GetBaseInfo(objID = nodeID, baseInfo = &baseInfo);
  
  // Check the filters
  if (setType && strcmp(setType,baseInfo.setType))    goto wrapup;
  if (setName && strcmp(setName,baseInfo.setName))    goto wrapup;
  if (setRev  && strcmp(setRev, baseInfo.setTypeRev)) goto wrapup;
    
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}


/* ------------------------------------------------------------
 * Given a model object, find the tree it is attached to
 * Allow filtering by set type,name and ver
 */
IGRstat VDct1GetModelObjectNode(TGRobj_env      *a_modelOE, // I - model object
				TGRid           *a_modelID, // I - model object
				TVDctSetType     setType,   // I - filter
				TVDctSetTypeRev  setRev,    // I - filter
				TVDctSetName     setName,   // I - filter
				TGRid           *nodeID)    // O - The node
{
  IGRstat         retFlag    = 0;
  IGRstat         traceFlag  = 0;
  
  IGRstat sts;
  
  TGRid   modelID;

  TVDvlaID  notifyVLA;
  TGRid     notifyID;
  
  IGRint    i;
  
  // say hi
  if (traceFlag) printf(">>> VDct1GetModelObjectNode\n");

  // Init
  vdvla_id$Construct(vla = &notifyVLA);
  
  // Arg check
  if (nodeID) nodeID->objid = NULL_OBJID;

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
    sts = VDct1GetModelObjectNodeFilter(&notifyID,setType,setRev,setName);
    if (sts & 1) {
      if (nodeID) *nodeID = notifyID;
      retFlag = 1;
      goto wrapup;
    }
  }
  
  // Done, not found
  
wrapup:
  vdvla_id$Delete(vla = &notifyVLA);   
  // say bye
  if (traceFlag) printf("<<< VDct1GetModelObjectNode %d\n\n",retFlag);
  return retFlag;
}
end implementation Root;





