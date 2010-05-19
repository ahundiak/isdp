 /* $Id: VDct1Xml.C,v 1.2 2001/03/12 20:36:54 jdsauby Exp $  */
/***************************************************************************
 * I/VDS
 *
 * File:        vdct1/set/VDct1Xml.I
 *
 * Description: XML Routines
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDct1Xml.C,v $
 *      Revision 1.2  2001/03/12 20:36:54  jdsauby
 *      Cleaned out unnecessary functions from vdct1/set
 *
 *      Revision 1.1  2001/01/12 14:53:35  art
 *      sp merge
 *
 * Revision 1.2  2000/10/13  12:46:10  pinnacle
 * js
 *
 * Revision 1.1  2000/07/25  18:38:22  pinnacle
 * ah
 *
# Revision 1.1  2000/07/17  19:50:56  pinnacle
# ah
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 07/10/00  ah      Creation
 ***************************************************************************/
 
#include "VDct1.h"
#include "VDobj.h"
#include "VDdir.h"

#include "VDxml.h"
#include "VDct1Xml.h"

#include "VDassert.h"

VDASSERT_FFN("vdct1/set/VDct1Xml.C");
#if 0
/* -------------------------------------------
 * Writes one node to an xml info
 * recursive routine to write sub nodes
 *
 */
IGRstat VDct1WriteXmlNode(TVDxmlFileInfo *fileInfo, TGRid *nodeID)
{
  IGRstat retFlag = 0;
  TVDctBaseInfo baseInfo;

  IGRint  j;

  TVDfldS flds;

  TGRid childID;

  IGRchar objType[64];
  IGRchar *p;
  
  // Make sure got a node
  if ((nodeID == NULL) || (nodeID->objid == NULL_OBJID)) goto wrapup;
  vdct1$GetBaseInfo(objID    =  nodeID,
		    baseInfo = &baseInfo);
  if (*baseInfo.nodeType == 0) goto wrapup;
  
  // The [] stuff used in node types is not legal xml
  strcpy(objType,baseInfo.nodeType);
  //p = strchr(objType,'[');
  //if (p) strcpy(p,p+1);
  //p = strchr(objType,']');
  //if (p) *p = 0;

  // Write header
  vdxml$WriteObjBeg(info = fileInfo, tag = objType, attr = 1, ret = 1);
  
  // Write standard attribute
  vdxml$WriteAtrTxt(info = fileInfo,tag = "node_name",value = baseInfo.nodeName,
		    indent = 1,ret = 1);
  vdxml$WriteAtrTxt(info = fileInfo,tag = "set_name", value = baseInfo.setName, 
		    indent = 1,ret = 1);
  
  // Write rest of the attributes
  vdcol$GetAttrs(objID = nodeID, 
		 cnt   = &flds.cnt, 
		 fld   =  flds.fld);

  for(j = 0; j < flds.cnt; j++) {
    vdxml$WriteAtrTxt(info   = fileInfo,
		      tag    = flds.fld[j].name,
		      value  = flds.fld[j].val.txt,
		      indent = 1,
		      ret    = 1);
  }
  vdxml$WriteAtrEnd(info = fileInfo,indent = 1, ret = 1);
  
  // Write sub objects
  for(j = 0; vdct1$GetTree1Child(objID = nodeID, nth = j, outID = &childID); j++) {
    VDct1WriteXmlNode(fileInfo, &childID);
  }
  
  // Write trailer
  vdxml$WriteObjEnd(info = fileInfo, tag = objType, indent = 1);
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Converts node to xml buffer string
 */
IGRstat VDct1GetXmlNodeBuf(TGRid *nodeID, IGRchar **xmlBuf)
{
  IGRstat retFlag = 0;
  
  TVDxmlFileInfo info;
  
  // Arg check
  if (xmlBuf) *xmlBuf = NULL;
  if (nodeID == NULL) goto wrapup;
  
  // Open the buffer, let it do all the allocating
  vdxml$OpenOutputStream(info = &info);
  
  // Write it out
  VDct1WriteXmlNode(&info,nodeID);

  // Close It
  vdxml$CloseOutputStream(info = &info);
  
  // Error check
  if (info.io.buf == NULL) goto wrapup;
  
  // Call the copics interface
  //VDct1CopPalGenerateCopicsFromBuf(info.io.buf);
#if 1
  // Print It
  printf("----------------------------------------\n");
  fputs(info.io.buf,stdout);
#endif

  // Return it
  if (xmlBuf) *xmlBuf = info.io.buf;
  else        free(info.io.buf);  // Cleanup
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

#endif


