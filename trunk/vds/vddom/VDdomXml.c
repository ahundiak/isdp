/* $Id: VDdomXml.c,v 1.5 2001/03/11 18:35:11 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vds/vddom/VDdomTest.c
 *
 * Description: Basic dom/tree functions
 *
 * Dependencies: 
 *
 * Revision History:
 *      $Log: VDdomXml.c,v $
 *      Revision 1.5  2001/03/11 18:35:11  ahundiak
 *      ah
 *
 *      Revision 1.4  2001/02/20 15:20:29  ahundiak
 *      ah
 *
 *      Revision 1.3  2001/02/09 22:29:25  ahundiak
 *      ah
 *
 *      Revision 1.2  2001/01/14 16:33:39  art
 *      sp merge
 *
 *      Revision 1.1  2001/01/11 19:28:37  art
 *      sp merge
 *
 * Revision 1.1  2000/12/06  15:01:08  pinnacle
 * ah
 *
 * Revision 1.1  2000/12/01  14:00:28  pinnacle
 * ah
 *
 * Revision 1.1  2000/08/05  16:35:24  pinnacle
 * ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 08/01/00  ah      Creation
 ***************************************************************************/

#include "VDtypedefc.h"
#include "VDdom.h"
#include "VDxml.h"

#include "VDassert.h"

VDASSERT_FFN("vds/vddom/VDdomXml.c");

/* -------------------------------------------------
 * Call back for filling in pcmk infos
 */
static IGRstat xmlCallBackCreateDomTree(TVDxmlParseInfo *parseInfo)
{
  VDASSERT_FN("xmlCallBackCreateDomTree");
  
  IGRstat retFlag = 0;
  
  TGRid *nodeID = parseInfo->data;
  TGRid  newID;
  TGRid  parentID;

  // Say Hi
  traceFlag = VDdomGetTraceFlag();
  if (traceFlag) printf(">>> %s\n",fn);
  
  switch(parseInfo->eleInfo.type) {

    case VDXML_TYPE_BEG_ELEMENT:        
      VDdomCreateObj(nodeID,parseInfo->eleInfo.eleType,&newID);
      VDASSERTW(newID.objid != NULL_OBJID);
#if 0
      printf("New ele %s %d,%d %d,%d\n",
	     parseInfo->eleInfo.eleType,
	     nodeID->osnum,nodeID->objid,
	     newID.osnum,  newID.objid);
#endif      
      *nodeID = newID;
      break;

    case VDXML_TYPE_END_ELEMENT:
      VDdomGetObjParent(nodeID,&parentID);
#if 0
      printf("End ele %s %d,%d %d,%d\n",
	     parseInfo->eleInfo.eleType,
	     nodeID->osnum, nodeID->objid,
	     parentID.osnum,parentID.objid);
#endif
      if (parentID.objid != NULL_OBJID) *nodeID = parentID;
      break;
      
    case VDXML_TYPE_ATTRIBUTE: 
      VDdomAppendAtr(nodeID,
		     parseInfo->eleInfo.atrType,
		     parseInfo->eleInfo.atrValue);
      break;
      
  }
  retFlag = 1;
  
 wrapup:

  if (retFlag == 0) parseInfo->retFlag = 1;

  // Say Bi
  if (traceFlag) printf("<<< %s\n",fn,retFlag);
  return retFlag;
}

/* -------------------------------------------------
 * Create a dom tree from an xml file
 *
 * Break this out from the internal xml parser
 *
 * Use active dom os for now
 * treeID->osnum must be correctly set
 */
IGRstat VDdomCreateTreeFromXmlFile(IGRchar *fileName, TGRid *a_treeID)
{
  VDASSERT_FN("VDdomCreateTreeFromXmlFile");
  IGRstat retFlag = 0;
  TVDxmlParseInfo parseInfo;

  TGRid treeID;
  
  // Say Hi
  traceFlag = VDdomGetTraceFlag();
  if (traceFlag) printf(">>> %s\n",fn);
  
  // Arg check
  VDASSERTW(a_treeID); 
  a_treeID->objid = NULL_OBJID;
  VDASSERTW(fileName && *fileName);
  
  // Do It
  VDdomGetActiveOsnum(&treeID.osnum);
  //treeID.osnum = a_treeID->osnum;
  treeID.objid = NULL_OBJID;
  VDxmlParseFile(&parseInfo,fileName,xmlCallBackCreateDomTree,&treeID);

  // The results
  *a_treeID = treeID;

  // Done
  retFlag = 1;
  
 wrapup:

  // Say Bi
  if (traceFlag) printf("<<< %s %d\n",fn,retFlag);
  
  return retFlag;
}
