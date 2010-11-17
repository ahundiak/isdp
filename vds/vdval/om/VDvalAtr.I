/***************************************************************************
 * I/VDS
 *
 * File:        vdval/om/VDvalAtr.I
 *
 * Description: Some generic attribute processing
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDvalAtr.I,v $
 *      Revision 1.3.2.1  2003/10/16 16:56:24  anand
 *      Support additional attributes for snapshot.  User specifies
 *      what attributes, for what class of components, and provides
 *      a way for classifying these attributes - all in a XML file
 *      (that will be located in config/xml/ as ss_custom.xml).
 *
 *      User may optionally also specify the name of the attribute
 *      that should appear in the snapshot output file (which is
 *      typically different from what the attribute goes by, in the
 *      ISDP world).
 *
 *      Revision 1.3  2002/03/08 17:03:09  ahundiak
 *      ah
 *
 *      Revision 1.2  2002/03/04 20:53:22  ylong
 *      CR5068 and CR5286
 *
 *      Revision 1.1  2001/08/14 19:16:29  ahundiak
 *      ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 08/03/01  ah      Creation
 * 10/16/03  Anand   Added VDvalAddCustomAttributes
 * 11/17/10  ah      SOL10
 ***************************************************************************/
class implementation Root;

#include "VDtypedef.h"
#include "VDassert.h"
#include "VDlog.h"
#include "VDbuf.h"
#include "VDobj.h"
#include "VDdir.h"
#include "VDexp.h"
#include "VDtest.h"
#include "VDobj2.h"
#include "VDgeomc.h"

#include "VDval.h"
#include "VDvalLike.h"

#include "VDctx.h"
#include "VDss.h"

VDASSERT_FFN("VDvalAtr.I");

from ACncpx import ACget_rep;

/* -------------------------------------------------
 * Add rep attribute
 * Wonder what the difference between ACget_rep and ACget_NV_rep is?
 */
IGRstat VDvalAddModelRepAttribute(TGRobj_env *modelOE, TGRid *nodeID)
{
  VDASSERT_FN("VDvalAddModelRepAttribute");
  
  IGRstat retFlag = 0;
  IGRint  rep = 0;

  // Arg check
  VDASSERTW(modelOE && modelOE->obj_id.objid != NULL_OBJID);
  VDASSERTW(nodeID  && nodeID->objid         != NULL_OBJID);

  om$send(msg = message ACncpx.ACget_rep(&rep),
	  senderid = NULL_OBJID,
	  targetid = modelOE->obj_id.objid,
	  targetos = modelOE->obj_id.osnum);
  VDctxAppIntAtr(nodeID,"rep",rep);
 
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -------------------------------------------------
 * Add class name attribute
 */
IGRstat VDvalAddModelClassNameAttribute(TGRobj_env *modelOE, TGRid *nodeID)
{
  VDASSERT_FN("VDvalAddModelClassNameAttribute");
  
  IGRstat retFlag = 0;
  IGRchab buf;
  IGRint  rep = 0;

  // Arg check
  VDASSERTW(modelOE && modelOE->obj_id.objid != NULL_OBJID);
  VDASSERTW(nodeID  && nodeID->objid         != NULL_OBJID);

  VDobjGetClassName(modelOE,NULL,buf);
  
  VDctxAppTxtAtr(nodeID,"class_name",buf);
 
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------
 * Add custom attributes
 */
void VDvalAddCustomAttributes(TGRobj_env *modelOE, TGRid *DomID)
{
    VDASSERT_FN("VDvalAddCustomAttribute");

    TGRid classID, nodeID;
    TGRid attrID, ParTypeID;
    int i,j;

    char name[128], xmlname[128];
    char buf [128];

    VDobjGetClassName(modelOE,NULL,name);

    // Arg check
    VDASSERTW(modelOE && modelOE->obj_id.objid != NULL_OBJID);
    VDASSERTW(DomID   && DomID->objid          != NULL_OBJID);

    VDvalGetCustomAttrClassNode(name,&classID);
    if (classID.objid == NULL_OBJID)
	 /* No custom attribute file or (if indeed exists) no entry
	  * corresponding to class id of Isdp Object.
	  */
	goto wrapup;

    /* Since we have a proper class, now iterate for each classification
     * of custom attributes ("parent_type" for the collector).
     */
    for(j = 0; VDctxGetNthTreeChild(&classID,j,&ParTypeID); j++)
    {
	if (ParTypeID.objid == NULL_OBJID )	// Paranoia
	    continue;

	if (!VDctxGetTxtAtr(&ParTypeID,"type",name))
	{
	    /* Child element of "<class>" does not have an attribute
	     * called "type".
	     */
	    name[0] = '\0';
	    continue;
	}

	// Create a node for custom attributes
	nodeID.objid = NULL_OBJID;
	VDctxCreateNode( DomID, VDCTX_NODE_TYPE_SS_OM_COLLECTOR,
			 NULL, &nodeID );
	if (nodeID.objid == NULL_OBJID )
	    continue;

	// Qualify the custom attribute collection.
	VDctxAppTxtAtr(&nodeID,"parent_type",name);

	for(i = 0; VDctxGetNthTreeChild(&ParTypeID,i,&attrID); i++)
	{
	    VDctxGetTxtAtr(&attrID,"isdp_name",name);
	    // Smart attribute should suffice for most cases.
	    VDobjGetTxtAtr(modelOE,NULL,name,buf);
	    if (VDctxGetTxtAtr(&attrID,"xml_name",xmlname))
		VDctxAppTxtAtr(&nodeID,xmlname,buf);
	    else
		VDctxAppTxtAtr(&nodeID,name,buf);
	}
    }

wrapup:
    return;
}

/* -------------------------------------------------
 * Add symbology attribute
 */
IGRstat VDvalAddModelSymbologyAttribute(TGRobj_env *modelOE, TGRid *nodeID)
{
  VDASSERT_FN("VDvalAddModelSymbologyAttribute");
  
  IGRstat retFlag = 0;
  IGRchab buf;
  TGRsymbology symb;

  // Arg check
  VDASSERTW(modelOE && modelOE->obj_id.objid != NULL_OBJID);
  VDASSERTW(nodeID  && nodeID->objid         != NULL_OBJID);

  VDobjGetSymbology(modelOE,NULL,&symb);
  sprintf(buf,"%d:%d:%d:%d:",
	  symb.level,
	  symb.display_attr.color,
	  symb.display_attr.weight,
	  symb.display_attr.style);
  VDctxAppTxtAtr(nodeID,VDCTX_ATR_SS_SYMBOLOGY,buf);

  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -------------------------------------------------
 * Add tag attribute
 */
IGRstat VDvalAddModelTagAttribute(TGRobj_env *modelOE, TGRid *nodeID)
{
  VDASSERT_FN("VDvalAddModelTagAttribute");
  
  IGRstat retFlag = 0;
  IGRchab buf;
  IGRchab fileName;
  
  TVDtag  tag;

  // Arg check
  VDASSERTW(modelOE && modelOE->obj_id.objid != NULL_OBJID);
  VDASSERTW(nodeID  && nodeID->objid         != NULL_OBJID);

  // Use the file name
  VDosGetFileName(modelOE->obj_id.osnum,fileName);
  VDASSERTW(*fileName);
  
  // Tag information
  VDtagGetInfo(modelOE,NULL,&tag,NULL);

  // Kee the file name
  sprintf(buf,":%s:%u:%u:%u:",fileName,modelOE->obj_id.objid,tag.num,tag.ver);
  VDctxAppTxtAtr(nodeID,VDCTX_ATR_SS_COMP_TAG,buf);


  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -------------------------------------------------
 * Add comp path attribute
 */
IGRstat VDvalAddModelCompPathAttribute(TGRobj_env *modelOE, TGRid *nodeID)
{
  VDASSERT_FN("VDvalAddModelCompPathAttribute");
  IGRstat retFlag = 0;
  
  IGRchab buf;
  
  // Arg check
  VDASSERTW(modelOE && modelOE->obj_id.objid != NULL_OBJID);
  VDASSERTW(nodeID  && nodeID->objid         != NULL_OBJID);
  
  // Component path is one way to access the object
  VDctxGetCompPath(&modelOE->obj_id, buf);
  if (*buf == 0) {
    VDlogPrintFmt   (VDLOG_ERROR,1,"*** Cannot get component path for model object");
    VDlogPrintObject(VDLOG_ERROR,1,NULL,modelOE,NULL);
    goto wrapup;
  }
  VDctxAppTxtAtr(nodeID,VDCTX_ATR_SS_COMP_PATH,buf);
  
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -------------------------------------------------
 * Add coordinate system attribute
 */
from GRgencs import GRgetmatrix;
IGRstat VDvalAddCoordMatrixAttribute(TGRobj_env *csOE, TGRid *nodeID)
{
  VDASSERT_FN("VDvalAddCoordMatrixAttribute");
  IGRstat   retFlag = 0;
  IGRlong   sts, msg;
  IGRchar   *txt = NULL;
  IGRdouble matrix[16];
  
  // Arg check
  VDASSERTW(csOE   && csOE->obj_id.objid != NULL_OBJID);
  VDASSERTW(nodeID && nodeID->objid      != NULL_OBJID);
  
  sts = om$send(msg = message GRgencs.GRgetmatrix(&msg,matrix),
                  senderid = NULL_OBJID,
                  targetid = csOE->obj_id.objid,
                  targetos = csOE->obj_id.osnum);
  if ( !(sts&msg&1) ) {
    VDlogPrintFmt   (VDLOG_ERROR,1,"*** Cannot get matrix for coordinate system");
    VDlogPrintObject(VDLOG_ERROR,1,NULL,csOE,NULL);
    goto wrapup;
  }

  VDvalConvertDoublesToText(16,matrix,16,&txt);
  VDASSERTW(txt);
  VDctxAppTxtAtr(nodeID,"matrix",txt);
  free(txt); txt = NULL;

  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}
/* -----------------------------------------------
 * Need a global rep variable for the piece
 * xml macro, tuck it in here because we need a .I
 */
from expression import NDgive_value;

/* -----------------------------------------------
 * Builds the path to the standard flag object
 *
 * For now, use the current os but later have it search
 * for the production file
 */
static void getOS(VDosnum *osnum)
{
  ex$get_cur_mod(osnum = osnum);
  return;
}

static void getXmlPieceRepPath(IGRchar *path)
{
  VDosnum osnum;

  *path = 0;

  getOS(&osnum);
  di$give_pathname(osnum = osnum, pathname = path) ;

  strcat(path,":IGENOD:xmlPieceRep");

  return;
}


/* -----------------------------------------------
 * Returns the rep to use
 */
void VDvalGetXmlPieceRep(IGRint *rep)
{
  VDASSERT_FN("VDvalGetXmlPieceRep");
  
  IGRchar path[128];
  IGRchar buf [128];
  TGRid   expID;
  
  VDosnum osnum;
  
  // Arg check
  VDASSERTW(rep); *rep = 0;
  
  // Need the path
  getXmlPieceRepPath(path);
  
  // Find the object
  expID.objid = NULL_OBJID;
  di$translate(objname =  path,
	       p_osnum = &expID.osnum,
	       p_objid = &expID.objid);

  // Pull the value
  if (expID.objid != NULL_OBJID) {
    vdexp$Get(objID = &expID,txt = buf);
    *rep = atoi(buf);
    goto wrapup;
  }
  
  // Need to create
  getOS(&osnum);
  strcpy(buf,"1");
  
  VDexpCreateTextExp(osnum,path,buf,&expID);
  if (expID.objid == NULL_OBJID) {
    goto wrapup;
  }
  *rep = 1;
  
 wrapup:
  return;
}

/* -----------------------------------------------
 * Sets the rep, creating object if necessary
 */
void VDvalSetXmlPieceRep(IGRint rep)
{
  VDASSERT_FN("VDvalSetXmlPieceRep");
  
  IGRchar path[128];
  IGRchar buf [128];
  TGRid   expID;
  IGRint  repx;
  
  // See if it needs changing
  VDvalGetXmlPieceRep(&repx);
  if (repx == rep) goto wrapup;
  
  // Need the path
  getXmlPieceRepPath(path);
  
  // Find the object, the Get routine should have created it
  expID.objid = NULL_OBJID;
  di$translate(objname =  path,
	       p_osnum = &expID.osnum,
	       p_objid = &expID.objid);

  if (expID.objid == NULL_OBJID) goto wrapup;
  
  // Update it
  sprintf(buf,"%d",rep);
  VDexpModifyTextExp(&expID,buf);
    
 wrapup:
  return;
}

end implementation Root;
