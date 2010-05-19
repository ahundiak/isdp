/* $Id: VDatGetStr.I,v 1.1.1.1 2001/01/04 21:07:42 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdat/imp/VDatBasei.I
 *
 * Description: Base Method Implementation
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDatGetStr.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:42  cvs
 *      Initial import to CVS
 *
# Revision 1.2  1998/09/29  21:15:06  pinnacle
# ah
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1998/04/09  14:33:10  pinnacle
# ah
#
# Revision 1.1  1998/04/09  14:28:50  pinnacle
# ah
#
# Revision 1.1  1998/04/09  14:24:26  pinnacle
# ah
#
# Revision 1.9  1998/03/29  14:21:14  pinnacle
# AssyTree
#
# Revision 1.8  1998/03/22  19:14:48  pinnacle
# AssyTree
#
 *
 * History:
 *      MM/DD/YY  AUTHOR  DESCRIPTION
 *      11/25/97  ah      creation
 *
 ***************************************************************************/

class implementation VDatBase;

#include "VDsa.h"

IGRstat VDatGetStruct
(TGRid       *objID,
 IGRchar     *attrName,
 Tret_struct *attrData
)
{
  IGRstat retFlag = 0;

  IGRchar buf[1024];

  IGRint  i;
  
  TGRid   parentID;
  TGRid   childID;
  
  // Init
  *buf = 0;
  
  // Arg Check
  if ((objID == NULL) || (objID->objid == NULL_OBJID)) goto wrapup;
  if ((attrName == NULL) || (*attrName == 0)) goto wrapup;
  if ( attrData == NULL) goto wrapup;

  // Node Path
  if (!strcmp(attrName,VDAT_ATTR_NODE_PATH)) {

    VDatGetNodePath(objID,buf);
    goto got_buf;

  }

  // Node Name
  if (!strcmp(attrName,VDAT_ATTR_NODE_NAME)) {

    VDatGetBaseName(objID,buf);
    goto got_buf;

  }

  // Node type
  if (!strcmp(attrName,VDAT_ATTR_NODE_TYPE)) {

    VDatRDBGetNodeType(objID,buf);
    goto got_buf;

  }

  // Parent seqno
  if (!strcmp(attrName,VDAT_ATTR_PARENT_SEQNO)) {

    VDatGetParentNode(objID,&parentID);
    if (parentID.objid == NULL_OBJID) goto got_buf;
    
    sprintf(buf,"%d",parentID.objid);
    goto got_buf;
  }
  
  // Parent Path
  if (!strcmp(attrName,VDAT_ATTR_PARENT_PATH)) {

    VDatGetParentNode(objID,&parentID);
    if (parentID.objid == NULL_OBJID) goto got_buf;
    
    VDatGetNodePath(&parentID,buf);
    goto got_buf;
  }
  
  // Parent Name
  if (!strcmp(attrName,VDAT_ATTR_PARENT_NAME)) {

    VDatGetParentNode(objID,&parentID);
    if (parentID.objid == NULL_OBJID) goto got_buf;
    
    VDatGetNodeName(&parentID,buf);
    goto got_buf;
  }
  
  // Parent Type
  if (!strcmp(attrName,VDAT_ATTR_PARENT_TYPE)) {

    VDatGetParentNode(objID,&parentID);
    if (parentID.objid == NULL_OBJID) goto got_buf;
    
    VDatRDBGetNodeType(&parentID,buf);
    goto got_buf;
  }
  
  // Node order
  if (!strcmp(attrName,VDAT_ATTR_NODE_ORDER)) {

    VDatGetParentNode(objID,&parentID);
    if (parentID.objid == NULL_OBJID) goto got_buf;
    
    for(i = 0; VDatGetChildObject(&parentID,i,&childID); i++) {
      if (childID.objid == objID->objid) {
	sprintf(buf,"%d",i);
	goto got_buf;
      }
    }
    goto got_buf;
  }

  // Set Name
  if (!strcmp(attrName,VDAT_ATTR_SET_NAME)) {

    VDatGetSetName(objID,buf);
    goto got_buf;
  }
  
  // Set Type
  if (!strcmp(attrName,VDAT_ATTR_SET_TYPE)) {

    VDatGetSetType(objID,buf);
    goto got_buf;
  }

  // Dynamic Table
  if (!strcmp(attrName,VDAT_ATTR_DYN_TABLE)) {

    VDatRDBGetTableName(objID,buf);
    goto got_buf;
  }

  // comp_name is a virtual attribute derived from comp_path
  if (!strcmp(attrName,VDAT_ATTR_COMP_NAME)) {

    VDatGetLeafName(objID,buf);
    goto got_buf;
    
  }
  // comp_path dies a bit of extra processing
  if (!strcmp(attrName,VDAT_ATTR_COMP_PATH)) {

    VDatGetLeafPath(objID,buf);
    goto got_buf;
    
  }
  
  goto wrapup;

/* --------------------------------------------
 * Save from messing around with ret_struct
 */
got_buf:
  strcpy(attrData->var.text_st.text_string,buf);
  attrData->type = text_type;
  retFlag = 1;

wrapup:

  return retFlag;

}

end implementation   VDatBase;

