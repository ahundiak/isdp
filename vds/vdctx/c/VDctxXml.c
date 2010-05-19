/* $Id: VDctxXml.c,v 1.4 2001/08/24 20:00:01 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vds/vdctx/c/VDctxXml.c
 *
 * Description: Base XML functions
 *
 * Dependencies: 
 *
 * Revision History:
 *      $Log: VDctxXml.c,v $
 *      Revision 1.4  2001/08/24 20:00:01  ahundiak
 *      ah
 *
 *      Revision 1.3  2001/05/24 18:42:32  ahundiak
 *      ah
 *
 *      Revision 1.2  2001/03/18 22:40:17  ahundiak
 *      ah
 *
 *      Revision 1.1  2001/02/22 22:47:18  ahundiak
 *      *** empty log message ***
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 02/22/01  ah      Creation
 ***************************************************************************/

#include "VDtypedefc.h"
#include "VDassert.h"
#include "VDxml.h"
#include "VDctx.h"
#include "VDlog.h"

VDASSERT_FFN("vdctx/c/VDctxXml.c");

/* --------------------------------------------
 * Recursive writing of a node to an xml stream
 */
static void writeNodeToXmlStream(TGRid *nodeID, TVDxmlFileInfo *xml)
{
  VDASSERT_FN("writeNodeToXmlStream");

  IGRchab nodeType;
  TGRid   childID;
  
  IGRint  cnt,i;
  TVDfld  flds[VDFLD_MAX_CNT];
  
  // Arg check
  VDASSERTW(xml);
  VDASSERTW(nodeID && nodeID->objid != NULL_OBJID);
  
  // Need the node type
  VDctxGetNodeType(nodeID,nodeType);
  VDASSERTW(*nodeType);

  // Get the attributes
  VDctxGetFldAtrs(nodeID,&cnt,flds);

  // Flag if have attributes
  if (cnt == 0) VDxmlWriteObjBeg(xml,nodeType,0,1);
  else          VDxmlWriteObjBeg(xml,nodeType,1,1);
  
  // Write attributes
  for(i = 0; i < cnt; i++) {
    VDxmlWriteAtrTxt(xml,
		     flds[i].name,
		     flds[i].val.txt,
		     1,1);
  }
  // End of attributes
  if (cnt) VDxmlWriteAtrEnd(xml,1,1);
  
  // Cycle through kids
  for(i = 0; VDctxGetNthTreeChild(nodeID,i,&childID); i++) {
    writeNodeToXmlStream(&childID,xml);
  }
  
  // Finish the object
  VDxmlWriteObjEnd(xml,nodeType,1);
  
  // Done
 wrapup:
  return;
}

/* -----------------------------------------------
 * Save the tree into and xml buffer
 * By design, there is no buf length stuff
 * Assume that an xml buffer will be a NULL 
 * terminated string and that is that.
 *
 * Generic writer for om objects
 */
void VDctxSaveTreeToXmlBufPrivate(TGRid *treeID, IGRchar **bufXml)
{
  VDASSERT_FN("VDctxSaveToXmlBufPrivate");
  IGRstat sts;
  
  TVDxmlFileInfo xml;
  IGRchab treeType;
  
  // Init
  memset(&xml,0,sizeof(TVDxmlFileInfo));
  
  // Arg check
  VDASSERTW(bufXml); *bufXml = NULL;
  VDASSERTW(treeID && treeID->objid != NULL_OBJID);
  
  // Need the base information
  VDctxGetNodeType(treeID,treeType);
  VDASSERTW(*treeType);
  
  // Open the xml stream
  sts = VDxmlOpenOutputStream(&xml,NULL,
			      treeType,treeType,
			      NULL,0,0,0,1.0,1);
  VDASSERTW(sts == 1);
  VDASSERTW(xml.io.buf);

  // Cycle through and write out
  writeNodeToXmlStream(treeID,&xml);
  
  // Return the args
  *bufXml = xml.io.buf;
  
  // Done

 wrapup:

  VDxmlCloseOutputStream(&xml);
  
  return;
}

/* -----------------------------------------------
 * Save the tree into an xml file
 * Generic writer for om objects
 */
IGRstat VDctxSaveTreeToXmlFilePrivate(TGRid *treeID, IGRchar *fileName)
{
  VDASSERT_FN("VDctxSaveToXmlBuf");
  IGRstat retFlag = 1;
  IGRstat sts;
  
  IGRchab treeType;
  TVDxmlFileInfo xml;
  
  // Init
  memset(&xml,0,sizeof(TVDxmlFileInfo));
  
  // Arg check
  VDASSERTW(fileName && *fileName);
  VDASSERTW(treeID && treeID->objid != NULL_OBJID);
  
  // Need the base information
  VDctxGetNodeType(treeID,treeType);
  VDASSERTW(*treeType);
  
  // Open the xml stream
  sts = VDxmlOpenOutputStream(&xml,fileName,
			      treeType,treeType,
			      NULL,0,0,0,1.0,1);
  VDASSERTW(sts == 1);
  VDASSERTW(xml.io.file);

  // Cycle through and write out
  writeNodeToXmlStream(treeID,&xml);
  
  // Done
  retFlag = 1;
  
 wrapup:

  VDxmlCloseOutputStream(&xml);
  
  return retFlag;
}

