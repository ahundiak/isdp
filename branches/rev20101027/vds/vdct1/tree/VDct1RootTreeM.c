/* $Id: VDct1RootTreeM.c,v 1.3 2002/05/24 17:47:44 jdsauby Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdct1/tree/VDct1RootTreeM.C
 *
 * Description: Model Object interface Routines
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDct1RootTreeM.c,v $
 *      Revision 1.3  2002/05/24 17:47:44  jdsauby
 *      Added isConnectModelObjectValid per CR6383, JDS
 *
 *      Revision 1.2  2001/05/07 13:57:14  paul_noel
 *      CR 4619 'Not in OPS messages to file'
 *
 *      Revision 1.1  2001/01/14 16:29:17  art
 *      sp merge
 *
 * Revision 1.3  2000/10/24  14:04:42  pinnacle
 * js
 *
 * Revision 1.2  2000/09/07  18:02:38  pinnacle
 * js
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 09/04/00  js      Creation
 * 05/07/01  pn      modified for CR 4619 "Not in OPS" to file
 ***************************************************************************/

#include "VDtypedefc.h"
#include "VDassert.h"
#include "VDobj2.h"

#include "VDct1.h"
#include "VDct1Tree.h"
#include "VDct1Tree2.h"
#include "VDct1Forms.h"
#include "VDct1Attrs.h"
#include "VDct1Part.h"
#include "VDct1Trace.h"


VDASSERT_FFN("vdct1/tree/VDct1RootTreeM.c");

#define MY_TREE VDCT1_TREE_TYPE_ROOT_TREE
extern  VDio_append_named_file();

/* -------------------------------------------
 * check to see if either nodeJD or modelOE
 * is in OPS
 * modelOE takes priority for this check
 * if checking a nodeJD is desired, pass a NULL for modelOE
 */
static IGRstat isPartInOPS(TVDct1JD   *nodeJD,
			   TGRobj_env *modelOE)
{
  VDASSERT_FN("isPartInOPS");
  
  IGRstat retFlag = 0;
  IGRstat sts;
  
  TVDct1_part_fld_part_id       part_id;

  VDASSERTW(modelOE);
  VDASSERTW(nodeJD);
  
  // say hi
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

  // trick to allow re-enable for possible lack of db entries
  if (getenv("VDCT1_OPS_OFF")) retFlag = atoi(getenv("VDCT1_OPS_OFF"));
  else                         retFlag = 0;
  
  
  // Get the object
  if (traceFlag) {
    printf("### %s %s Get Object\n",ffn(),fn);
     VDobjPrint2(NULL,&nodeJD->id);
     VDobjPrint2(modelOE,NULL);
  }
  
  // get the partCageNum and part_id
  if (traceFlag) printf("### %s %s get part cage num\n",ffn(),fn);
  
  VDct1GetPartCageNumForModelObject(modelOE,NULL,NULL,part_id);
  if (*part_id == 0) goto wrapup;

  // done
  retFlag = 1;
  
wrapup:
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  return retFlag;
}

#if 0
/* -------------------------------------------
 * check to see if either nodeJD or modelOE
 * is in OPS
 * modelOE takes priority for this check
 * if checking a nodeJD is desired, pass a NULL for modelOE
 */
static IGRstat isPartInOPS(TVDct1JD   *nodeJD,
			   TGRobj_env *modelOE)
{
  VDASSERT_FN("isPartInOPS");
  
  IGRstat retFlag = 0;
  IGRstat sts;
  
  TGRid   objID;
  
  TVDct1_part_fld_part_cage_num part_cage_num;
  TVDct1_part_fld_part_id       part_id;
  IGRchar                       partCageNum[64];
  
  TVDrisInfo ris;
  
        
  VDASSERTW((nodeJD->id.objid != NULL_OBJID) ||
	    (modelOE->obj_id.objid != 0) && (modelOE->obj_id.objid != NULL_OBJID));

  // say hi
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

  // trick to allow re-enable for possible lack of db entries
  if (getenv("VDCT1_OPS_OFF"))
    retFlag = atoi(getenv("VDCT1_OPS_OFF"));
  else
    retFlag = 0;
  
  
  // Get the object
  if (traceFlag) {
    printf("### %s %s Get Object\n",ffn(),fn);
    VDobjPrint2(NULL,&nodeJD->id);
    VDobjPrint2(modelOE,NULL);
  }
  
  objID.objid = NULL_OBJID;
  if (nodeJD)  objID = nodeJD->id;
  if (modelOE) objID = modelOE->obj_id;
  if (objID.objid == NULL_OBJID) goto wrapup;
  
  if (traceFlag){
    printf("### %s %s the object\n",ffn(),fn);
    VDobjPrint2(NULL,&objID);
  }
  
  // get the partCageNum and part_id
  if (traceFlag) printf("### %s %s get part cage num\n",ffn(),fn);
  
  VDct1GetPartCageNumForModelObject(modelOE,NULL,part_cage_num,part_id);
  if (*part_id == 0) goto wrapup;
#if 0
  // is the part in the OPS tables
  strcpy(partCageNum,part_cage_num);
  if (traceFlag) printf("### %s %s check if in DB\n",ffn(),fn);
  
  VDct1QryPartIdForItemCageNum(&ris,partCageNum);
  if (ris.rows < 1) goto wrapup;
#endif
  // done
  retFlag = 1;
  
wrapup:
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  return retFlag;
}
#endif  

/* --------------------------------------------
 * can be used to set a parent different
 * than the current active parent
 */
static IGRstat getParentForModelObject(TVDct1JD   *parentJD,
				       TGRobj_env *modelOE)
{
  // default it to the current active parent
  return 1;
}

/* ---------------------------------------------
 * check that the model object is valid to connect
 * - should have same cage-mino (nodename = mat_id_key)
 */
static IGRstat isConnectModelObjectValid(TVDct1JD   *nodeJD,
				         TGRobj_env *modelOE)
{
  VDASSERT_FN("isConnectModelObjectValid");
  
  IGRstat        retFlag = 0;
  IGRstat        sts;
  TVDctBaseInfo  baseInfo;
  IGRchar        buf[128];
    
  VDASSERTW(nodeJD->id.objid != NULL_OBJID);
  VDASSERTW((modelOE->obj_id.objid != 0) && (modelOE->obj_id.objid != NULL_OBJID));
  
  
  // say hi
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

  // Get the info
  _RTCJDB(nodeJD)->getBaseInfo(nodeJD,&baseInfo);
  if (*baseInfo.nodeName == 0) {
      printf("### %s FAILED:  Could not get Node Name\n",fn);
      goto wrapup;
  }

  // get the mat_id_key of the object
  *buf = 0;
  VDobjGetTxtAtr(modelOE,NULL,"mat_id_key",buf);
  if (*buf == 0) {
      printf("### %s FAILED: Could not get mat_id_key\n",fn);
      goto wrapup;
  }

  // compare them
  if (strcmp(baseInfo.nodeName,buf)) {
      printf("### %s FAILED: Node Name <%s> Mat_id_key <%s>\n",
	      fn,baseInfo.nodeName,buf);
      goto wrapup;
  }


  // done
  retFlag = 1;
  
wrapup:
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  return retFlag;
}



/* ---------------------------------------------
 * check that the model object is valid
 * - should not be a CS
 * - should be in OPS
 * - should not already be connected to the tree
 */
static IGRstat isModelObjectValid(TVDct1JD   *nodeJD,
				  TGRobj_env *modelOE)
{
  VDASSERT_FN("isModelObjectValid");
  
  IGRstat        retFlag = 0;
  IGRstat        sts;
  IGRchar        fileName[24];
  IGRchar        fileData[128];
  TVDct1JD       local_nodeJD;
  TGRobj_env     local_modelOE;
  TVDctBaseInfo  baseInfo;
  IGRchar        buf[64],*p;
    
  VDASSERTW(nodeJD->id.objid != NULL_OBJID);
  VDASSERTW((modelOE->obj_id.objid != 0) && (modelOE->obj_id.objid != NULL_OBJID));
  
  fileName[0] = '\0';
  
  // say hi
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

  // init (make some local copies)
  local_modelOE = *modelOE;
  local_nodeJD  = *nodeJD;

  // make a treeName
  // Get the info
  _RTCJDB(nodeJD)->getBaseInfo(nodeJD,&baseInfo);
  p = baseInfo.setType;
  sprintf(fileName,"%c%s.txt",*p,baseInfo.setName);

  // filter out unwanted objects
  // get the modelOE className
  VDobjGetClassName(&local_modelOE,NULL,buf);
  if (traceFlag) printf("modelOE className = %s\n",buf);
  
  // we don't want CS
  if (!strcmp(buf,"GRgencs")) {
    sprintf(fileData,"Invalid Model Object: (%d,%d) Coordinate System\n",
	    modelOE->obj_id.osnum,
	    modelOE->obj_id.objid);
    printf(fileData);

    goto wrapup;
  }
  
  // is it in OPS
  if (traceFlag) printf("### %s %s checking OPS\n",ffn(),fn);
  
  sts = _RTCJDB(&local_nodeJD)->isPartInOPS(&local_nodeJD,&local_modelOE);
  if (!(sts & 1)) {
    /* modified for CR4619 pn 05/07/01 */
    sprintf(fileData,"Invalid Model Object: (%d,%d) Not in OPS\n",
	   modelOE->obj_id.osnum,
	   modelOE->obj_id.objid);
    printf(fileData);

    VDio_append_named_file(fileName,
			   fileData);
    /* appends file per request to allow user a file to view messages */
    goto wrapup;
  }
  
  // is it already connected
  sts = _RTCJDB(&local_nodeJD)->
    getModelObjectNode(&local_nodeJD,&local_modelOE,NULL,NULL,NULL,NULL,&local_nodeJD);
  if (sts) {
    sprintf(fileData,"Invalid Model Object: (%d,%d) Already in Tree\n",
	   modelOE->obj_id.osnum,
	   modelOE->obj_id.objid);
    printf(fileData);

    goto wrapup;
  }
  

  // done
  retFlag = 1;
  
wrapup:
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  return retFlag;
}

/* ----------------------------------------------
 * get the node name for the model object,
 * default will be the OPS cage-mino
 */
static IGRstat getNodeNameForModelObject(TVDct1JD      *nodeJD,
					 TGRobj_env    *modelOE,
					 TVDctNodeName  nodeName)
{
  VDASSERT_FN("getNodeNameForModelObject");
  
  IGRstat retFlag = 0;
  IGRstat sts;

  TVDct1_part_fld_part_cage_num part_cage_num;
  TVDct1_part_fld_part_id       part_id;
  IGRchar                       partCageNum[64];
  
  TVDrisInfo ris;
  
  TVDctBaseInfo  baseInfo;
  
  VDASSERTW(nodeJD->id.objid != NULL_OBJID);
  VDASSERTW((modelOE->obj_id.objid != 0) && (modelOE->obj_id.objid != NULL_OBJID));
  VDASSERTW(nodeName);
  
  // say hi
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
  
  // get the name
  VDct1GetPartCageNumForModelObject(modelOE,NULL,part_cage_num,part_id);
  if (part_cage_num == NULL) goto wrapup;
  
  // set it
  strcpy(nodeName,part_cage_num);
  
  
  // done
  retFlag = 1;
  
wrapup:
  if (traceFlag) printf("<<< %s %s %s\n",ffn(),fn,nodeName);
  return retFlag;
}


/* --------------------------------------------------
 * get the node type for the model object,
 * default will be to check if it is a std_assy
 * and set it to the correct assy type.
 * if it is not a std_assy, then it will be a part
 */ 
static IGRstat getTypeForModelObject(TVDct1JD      *parentNodeJD,
				     TGRobj_env    *modelOE,
				     TVDctNodeType nodeType)
{
  VDASSERT_FN("getTypeForModelObject");
  
  IGRstat retFlag = 0;

  TVDctBaseInfo baseInfo;
 
  // Arg check
  VDASSERTW(parentNodeJD->id.objid != NULL_OBJID);
  VDASSERTW(nodeType);

  // init
  *nodeType = 0;

  // just set it equal to a part
  strcpy(nodeType,VDCT1_ENG_NODE_TYPE_PART);

  // Done 
  retFlag = 1;

wrapup:  
  if (traceFlag) printf("<<< %s %s %s\n",ffn(),fn,nodeType);
  
  return retFlag;
}
 
/* --------------------------------------------------------------------
 * Copies attributes from model to node
 * This needs to call a ppl
 */
static IGRstat copyAttributesFromModelToNode(TVDct1JD   *nodeJD,
					     TGRobj_env *modelOE)
{
  VDASSERT_FN("copyAttributesFromModelToNode");
  
  IGRstat retFlag = 0;
  IGRchar buf[256],tmp[256];
  IGRchar *p;
  
  TVDfld fld;

  IGRchar nodeAttrName[128];
  IGRchar modelAttrName[128];
  
  TVDctBaseInfo baseInfo;

  TGRid nodeID;
  
  // Arg check
  VDASSERTW(nodeJD->id.objid != NULL_OBJID);
  VDASSERTW((modelOE->obj_id.objid != 0) && (modelOE->obj_id.objid != NULL_OBJID));

  // say hi
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
  
  // init
  nodeID = nodeJD->id;
  
  // Build the isdp_name
  VDobjGetTxtAtr(modelOE,NULL,"eqp_family",tmp);
  strcpy(buf,tmp);
  strcat(buf,":");
  VDobjGetTxtAtr(modelOE,NULL,"eqp_partno",tmp);
  strcat(buf,tmp);
  strcat(buf,":");
  VDobjGetTxtAtr(modelOE,NULL,"eqp_partrev",tmp);
  strcat(buf,tmp);
  strcat(buf,":");
  VDobjGetPath(modelOE,NULL,tmp);
  p = strrchr(tmp,':');
  if (p) strcat(buf,p+1);
  else   strcat(buf,tmp);
  
  VDctxGetAttr(&nodeID,"teng_isdp_name",&fld);
  if (*fld.name) {
    strupr(buf);
    strcpy(fld.val.txt,buf);
    VDctxUpdAttrs(&nodeID,1,&fld);
  }
  
  // Add the path
  VDobjGetPath(modelOE,NULL,tmp);
  VDctxGetAttr(&nodeID,"teng_isdp_path",&fld);
  if (*fld.name) {
    strupr(tmp);
    strcpy(fld.val.txt,tmp);
    VDctxUpdAttrs(&nodeID,1,&fld);
  }
  
  // Other attributes
  //unit
  strcpy(nodeAttrName,"teng_unit_num");
  strcpy(modelAttrName,"unit_number");
  _RTCJDB(nodeJD)->
    copyAttributeFromModelToNode(nodeJD,nodeAttrName,modelOE,modelAttrName);
  
  //compartment
  strcpy(nodeAttrName,"teng_compt_num");
  strcpy(modelAttrName,"compt_number");
  _RTCJDB(nodeJD)->
    copyAttributeFromModelToNode(nodeJD,nodeAttrName,modelOE,modelAttrName);

  
  // Pull zone from 
  VDctxGetAttr(&nodeID,"teng_isdp_zone",&fld);
  if (*fld.name) {
    strupr(buf);
    strcpy(fld.val.txt,buf);
    VDctxUpdAttrs(&nodeID,1,&fld);
  }
  
  // Done
  retFlag = 1;
  
wrapup:
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  
  return retFlag;
}

/* --------------------------------------------------------------------
 * Transfer attribute from model to node
 */
static IGRstat copyAttributeFromModelToNode(TVDct1JD   *nodeJD, 
					    IGRchar    *nodeAttrName,
					    TGRobj_env *modelOE,
					    IGRchar    *modelAttrName)
{
  VDASSERT_FN("copyAttributeFromModelToNode");
  
  IGRstat retFlag = 0;
  TVDfld  fld;

  TGRid nodeID;
  
  IGRchar buf[128];
  
  // Arg check
  VDASSERTW(nodeJD->id.objid != NULL_OBJID);
  VDASSERTW(nodeAttrName);
  VDASSERTW((modelOE->obj_id.objid != 0) && (modelOE->obj_id.objid != NULL_OBJID));
  VDASSERTW(modelAttrName);
  
  // init
  nodeID = nodeJD->id;
  
  // Start by getting the node attribute
  VDctxGetAttr(&nodeID,nodeAttrName,&fld);
  if (*fld.name == 0) goto wrapup;
  
  // Get from model
  VDobjGetTxtAtr(modelOE,NULL,modelAttrName,buf);
  
  // Copy data
  strcpy(fld.val.txt,buf);
  strupr(fld.val.txt);
  
  // And update
  VDctxUpdAttrs(&nodeID,1,&fld);
  
  // Done
  retFlag = 1;
  
wrapup:
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  
  return retFlag;
}

extern VDclassid OPP_VDct1Base_class_id;

/* ------------------------------------------------------------
 * Little helper to do the filtering
 */
static IGRstat getModelObjectNodeFilter(TVDct1JD        *nodeJD,    // I - node object
					TVDctSetType     setType,   // I - filter
					TVDctSetTypeRev  setRev,    // I - filter
					TVDctSetName     setName)   // I - filter
{
  VDASSERT_FN("getModelObjectNodeFilter");
  
  IGRstat retFlag = 0;
  IGRstat sts;
  TGRid   nodeID;
  
  TVDctBaseInfo baseInfo;
  
  VDASSERTW(nodeJD->id.objid != NULL_OBJID);
  nodeID = nodeJD->id;
  
  // Make sure its a base object
  sts = VDobjIsAncestryValid(NULL,&nodeID,OPP_VDct1Base_class_id,NULL);
  if (!(sts & 1)) goto wrapup;
  
  // Get the info
  _RTCJDB(nodeJD)->getBaseInfo(nodeJD,&baseInfo);
  
  // Check the filters
  if (setType && strcmp(setType,baseInfo.setType))    goto wrapup;
  if (setName && strcmp(setName,baseInfo.setName))    goto wrapup;
  if (setRev  && strcmp(setRev, baseInfo.setTypeRev)) goto wrapup;
    
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Inits these pointers
 */
IGRstat VDct1InitRootTreeClassM(TVDct1RootTreeClass *cl)
{
  VDASSERT_FN("VDct1InitRootTreeClassM");
  
  IGRstat retFlag = 0;

  traceFlagx = traceFlag = VDct1TraceFlag(VDCT1_TRACE_TREE_BASE);
     
  // Fill up pointers
  cl->base.getTypeForModelObject         = getTypeForModelObject;
  cl->base.copyAttributesFromModelToNode = copyAttributesFromModelToNode;
  cl->base.copyAttributeFromModelToNode  = copyAttributeFromModelToNode;

  cl->base.getModelObjectNodeFilter      = getModelObjectNodeFilter;

  cl->base.getNodeNameForModelObject     = getNodeNameForModelObject;
  cl->base.isModelObjectValid            = isModelObjectValid;
  cl->base.isConnectModelObjectValid     = isConnectModelObjectValid;
  cl->base.getParentForModelObject       = getParentForModelObject;
  cl->base.isPartInOPS                   = isPartInOPS;
     
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}



