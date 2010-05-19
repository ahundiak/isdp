/***************************************************************************
 * I/VDS
 *
 * File:        vdval/om/VDvalParent.I
 *
 * Description: Parent Processing Routines
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDvalParent.I,v $
 *      Revision 1.2  2002/06/07 14:48:09  ahundiak
 *      ah
 *
 *      Revision 1.1  2001/08/24 20:01:52  ahundiak
 *      ah
 *
 *      Revision 1.2  2001/08/14 19:15:45  ahundiak
 *      ah
 *
 *      Revision 1.1  2001/08/02 15:33:39  ahundiak
 *      ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 07/13/01  ah      Creation
 ***************************************************************************/

class implementation Root;

#include "VDtypedef.h"
#include "VDassert.h"
#include "VDlog.h"
#include "VDobj.h"
#include "VDchn.h"
#include "VDbuf.h"
#include "VDtest.h"
#include "VDobj2.h"
#include "VDgeomc.h"

#include "VDval.h"
#include "VDvalLike.h"

#include "VDxdom.h"
#include "VDctx.h"
#include "VDss.h"

#include "macro.h"
#include "acmacros.h"

VDASSERT_FFN("VDvalGenEqp.c");

extern VDclassid OPP_ACrg_collect_class_id;
extern VDclassid OPP_ACpretend_class_id;
extern VDclassid OPP_ACheader_class_id;
extern VDclassid OPP_GRgencs_class_id;

from ACrg_collect import AClist_attribute;
from GRgencs      import GRgetmatrix;
from ACncpx       import ACget_rep;
from VDSroot      import VDGetGraphMac;

/* -----------------------------------------------
 * Process a single parent collector
 */
IGRstat VDvalGenProcessParentCollector(TGRobj_env *childOE, 
				       TGRobj_env *parentOE,
				       IGRchar    *parentType,
				       TGRid      *domID)
{
  VDASSERT_FN("VDvalGenProcessParentCollector");
  IGRstat retFlag = 0;
  IGRstat sts,msg;
  
  IGRint i,cnt;
  
  VDclassid classId;
  TGRid     parentID;
  TGRid     nodeID;
  
  IGRint      atrMax = 100;
  TACrg_coll  atrBuf[100];
  TACrg_coll *atrList = NULL;
  TACrg_coll *atr;
  
  IGRchar  buf[128];
  IGRchar *txt;
  
  IGRdouble matrix[16];
  
  // Init
  parentID = parentOE->obj_id;

  // Arg check
  VDASSERTW(domID && domID->objid != NULL_OBJID);
  VDASSERTW(parentOE && parentOE->obj_id.objid != NULL_OBJID);
  
  // Get the class
  sts = som_get_classid(parentID.osnum,NULL,parentID.objid,NULL,&classId);
  VDASSERTW(sts == 1);

  // Collector
  if (classId != OPP_ACrg_collect_class_id) goto wrapup;
  retFlag = 1;
  
  // Get number of attributes
  cnt = 0;
  om$send(msg = message ACrg_collect.
	  AClist_attribute(&msg,0,NULL,&cnt),
	  senderid = NULL_OBJID,
	  targetid = parentID.objid,
	  targetos = parentID.osnum);
  if (cnt < 1) {
    retFlag = 1;
    goto wrapup;
  }
    
  // Alloc
  if (cnt < atrMax) atrList = atrBuf;
  else {
    atrMax = cnt;
    atrList = malloc(cnt * sizeof(TACrg_coll));
    VDASSERTW(atrList);
  }

  // Get em attributes
  cnt = 0;
  om$send(msg = message ACrg_collect.
	  AClist_attribute(&msg,atrMax*sizeof(TACrg_coll),atrList,&cnt),
	  senderid = NULL_OBJID,
	  targetid = parentID.objid,
	  targetos = parentID.osnum);
  if (cnt < 1) goto wrapup;

  // Create the node
  VDctxCreateNode(domID,VDCTX_NODE_TYPE_SS_OM_COLLECTOR,NULL,&nodeID);
  VDASSERTW(nodeID.objid != NULL_OBJID);
  
  // Special type
  if (parentType) VDctxAppTxtAtr(&nodeID,"parent_type",parentType);
    
  // Cycle through
  for(i = 0; i < cnt; i++) {
    atr = &atrList[i];
    switch(atr->desc.type) {
      
      case AC_ATTRIB_TEXT:
	VDctxAppTxtAtr(&nodeID,atr->name,atr->desc.value.att_txt);
	break;
	
      case AC_ATTRIB_DOUBLE: 
	strcpy(buf,"double ");
	VDvalConvertDoubleToText(atr->desc.value.att_exp,6,buf+7);
	VDctxAppTxtAtr(&nodeID,atr->name,buf);
	break;
	
      default:
	VDctxAppTxtAtr(&nodeID,atr->name,"UNKNOWN ATTRIBUTE TYPE");
	VDlogPrintFmt(VDLOG_ERROR,1,"*** Collector has unknown attribute type %s",atr->name);
	
    }
  }

 wrapup:

  if ((atrList) && (atrList != atrBuf)) free(atrList);

  return retFlag;
}

/* -----------------------------------------------
 * Process a single parent
 */
IGRstat VDvalGenProcessParent(TGRobj_env *eqpOE, 
			      TGRobj_env *parentOE,
			      IGRchar    *parentType,
			      TGRid      *eqpID)
{
  VDASSERT_FN("VDvalGenrocessParent");
  IGRstat retFlag = 0;
  IGRstat sts,msg;
  
  IGRint i,cnt;
  
  VDclassid classId;
  TGRid     parentID;
  TGRid     nodeID;
  
  IGRint      atrMax = 100;
  TACrg_coll  atrBuf[100];
  TACrg_coll *atrList = NULL;
  TACrg_coll *atr;
  
  IGRchar  buf[128];
  IGRchar *txt;
  
  IGRdouble matrix[16];
  
  // Init
  parentID = parentOE->obj_id;

  // Arg check
  VDASSERTW(eqpID && eqpID->objid != NULL_OBJID);
  VDASSERTW(parentOE && parentOE->obj_id.objid != NULL_OBJID);
  
  // Get the class
  sts = som_get_classid(parentID.osnum,NULL,parentID.objid,NULL,&classId);
  VDASSERTW(sts == 1);

  // Collector
  if (classId == OPP_ACrg_collect_class_id) {

    // Get number of attributes
    cnt = 0;
    om$send(msg = message ACrg_collect.
	    AClist_attribute(&msg,0,NULL,&cnt),
	    senderid = NULL_OBJID,
	    targetid = parentID.objid,
	    targetos = parentID.osnum);
    if (cnt < 1) {
      retFlag = 1;
      goto wrapup;
    }
    
    // Alloc
    if (cnt < atrMax) atrList = atrBuf;
    else {
      atrMax = cnt;
      atrList = malloc(cnt * sizeof(TACrg_coll));
      VDASSERTW(atrList);
    }

    // Get em attributes
    cnt = 0;
    om$send(msg = message ACrg_collect.
	    AClist_attribute(&msg,atrMax*sizeof(TACrg_coll),atrList,&cnt),
	    senderid = NULL_OBJID,
	    targetid = parentID.objid,
	    targetos = parentID.osnum);
    if (cnt < 1) goto wrapup;

    // Create the node
    VDctxCreateNode(eqpID,VDCTX_NODE_TYPE_SS_OM_COLLECTOR,NULL,&nodeID);
    VDASSERTW(nodeID.objid != NULL_OBJID);
  
    // Special type
    if (parentType) VDctxAppTxtAtr(&nodeID,"parent_type",parentType);
    
    // Cycle through
    for(i = 0; i < cnt; i++) {
      atr = &atrList[i];
      switch(atr->desc.type) {

	case AC_ATTRIB_TEXT:
	  VDctxAppTxtAtr(&nodeID,atr->name,atr->desc.value.att_txt);
	  break;

	case AC_ATTRIB_DOUBLE: 
	  strcpy(buf,"double ");
	  VDvalConvertDoubleToText(atr->desc.value.att_exp,6,buf+7);
	  VDctxAppTxtAtr(&nodeID,atr->name,buf);
	  break;

	default:
	  VDctxAppTxtAtr(&nodeID,atr->name,"UNKNOWN ATTRIBUTE TYPE");
	  VDlogPrintFmt(VDLOG_ERROR,1,"*** Collector has unknown attribute type %s",atr->name);
	  
      }
    }
    retFlag = 1;
    goto wrapup;
  }

  // CS
  if (classId == OPP_GRgencs_class_id) {

    // Grab the matrix
    sts = om$send(msg = message GRgencs.GRgetmatrix(&msg,matrix),
		  senderid = NULL_OBJID,
		  targetid = parentID.objid,
		  targetos = parentID.osnum);		  
    VDASSERTW(sts & msg & 1);
    
    // Make a node
    VDctxCreateNode(eqpID,VDCTX_NODE_TYPE_SS_OM_CS,NULL,&nodeID);
    VDASSERTW(nodeID.objid != NULL_OBJID);

    // Special type
    if (parentType) VDctxAppTxtAtr(&nodeID,"parent_type",parentType);

    // Write it out
    VDvalConvertDoublesToText(16,matrix,9,&txt);
    VDASSERTW(txt);
    VDctxAppTxtAtr(&nodeID,"matrix",txt);
    free(txt); txt = NULL;
    
    retFlag = 1;
    goto wrapup;
  }
  // ACheader, when a component is a parent
  if (classId == OPP_ACheader_class_id) {

    // Ignore for now
    retFlag = 1;
    goto wrapup;
  }
 
  // oops
  VDlogPrintObject(VDLOG_ERROR,1,"Unknown equipment parent type ",parentOE,NULL);
  
 wrapup:

  if ((atrList) && (atrList != atrBuf)) free(atrList);

  return retFlag;
}

end implementation Root;
