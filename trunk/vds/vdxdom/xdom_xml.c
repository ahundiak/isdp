/* $Id: xdom_xml.c,v 1.5 2002/01/04 16:38:55 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vds/vdxdom/xdom_xml.c
 *
 * Description: xml2 based routines
 *
 * Dependencies: 
 *
 * Revision History:
 *      $Log: xdom_xml.c,v $
 *      Revision 1.5  2002/01/04 16:38:55  ahundiak
 *      ah
 *
 *      Revision 1.4  2001/10/19 20:32:16  ahundiak
 *      ah
 *
 *      Revision 1.3  2001/09/14 13:28:52  ahundiak
 *      ah
 *
 *      Revision 1.2  2001/09/13 21:08:13  ahundiak
 *      ah
 *
 *      Revision 1.1  2001/08/24 20:08:07  ahundiak
 *      ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 08/20/01  ah      Created
 ***************************************************************************/
#include "VDtypedefc.h"
#include "VDassert.h"
#include "VDlog.h"
#include "VDxml.h"
#include "VDctx.h"
#include "VDxdom.h"

#include "glib.h"
#include "xdom.h"

VDASSERT_FFN("xdom_xml.c");

/* -----------------------------------------------
 * Generate a dom tree from an xml file
 */
void VDxdomCreateTreeFromXmlFile(IGRchar *xmlFileName, TGRid *treeID)
{
  VDASSERT_FN("VDxdomCreateTreeFromXmlFile");

  xmlDocPtr  doc = NULL;
  xmlNodePtr root;

  // Arg check
  VDASSERTW(treeID); treeID->objid = NULL_OBJID;
  VDASSERTW(xmlFileName && *xmlFileName);

  // Parse it
  xmlKeepBlanksDefault(0);
  doc = xmlParseFile(xmlFileName);
  if (doc == NULL) {
    VDlogPrintFmt(VDLOG_ERROR,1,"Problem parsing xml file %s\n",xmlFileName);
    goto wrapup;
  }

  // Return root
  root = xmlDocGetRootElement(doc);
  xdom_nodeid_set_node(treeID,root);
  
 wrapup:
  return;
}

/* -----------------------------------------------
 * Generate a dom tree from an xml file
 */
void VDxdomCreateTreeFromXmlBuf(IGRchar *xmlBuf, TGRid *treeID)
{
  VDASSERT_FN("VDxdomCreateTreeFromXmlBuf");

  xmlDocPtr  doc = NULL;
  xmlNodePtr root;

  IGRint len;
  
  // Arg check
  VDASSERTW(treeID); treeID->objid = NULL_OBJID;
  VDASSERTW(xmlBuf && *xmlBuf);

  // Parse it
  xmlKeepBlanksDefault(0);
  len = strlen(xmlBuf);
  doc = xmlParseMemory(xmlBuf,len);
  if (doc == NULL) {
    VDlogPrintFmt(VDLOG_ERROR,1,"Problem parsing xml buffer\n");
    goto wrapup;
  }

  // Return root
  root = xmlDocGetRootElement(doc);
  xdom_nodeid_set_node(treeID,root);
  
 wrapup:
  return;
}

/* -----------------------------------------------
 * Grab an xml file from a server then convert
 * to a xdom tree, 
 *
 * Now uses the nanohttp stuff in libxml2
 */
void VDxdomCreateTreeFromWebFile(IGRchar *server, IGRchar *fileName, TGRid *treeID)
{
  VDASSERT_FN("VDxdomCreateTreeFromWebFile");

  IGRchar url[128];
  
  // Arg check
  VDASSERTW(treeID); treeID->objid = NULL_OBJID;
  VDASSERTW(fileName && *fileName);

  // Check for default server
  if (server == NULL) server = getenv("ISDP_WEB_SERVER");
  if (server == NULL) goto wrapup;
  VDASSERTW(*server);
  
  // Build the url
  sprintf(url,"http://%s%s",server,fileName);
  
  // Convert to tree
  VDxdomCreateTreeFromXmlFile(url,treeID);

 wrapup:
  return;
}


/* -----------------------------------------------
 * Make a copy of the tree if the node is not the root node
 */
static xmlDocPtr makeCopyIfNotRoot(xmlNodePtr tree)
{
  VDASSERT_FN("makeCopyIfNotRoot");
  
  xmlNodePtr root;
  xmlDocPtr  docCopy = NULL;  /* Possible copy */
  
  // See if doing the entire tree or not
  root = xmlDocGetRootElement(tree->doc);
  if (root == tree) goto wrapup;
  
  // Copy it
  docCopy = xmlCopyDoc(tree->doc,0);
  VDASSERTW(docCopy);
  root = xmlCopyNode(tree,1);
  VDASSERTW(root);
  xmlDocSetRootElement(docCopy,root);
    
 wrapup:
  
  return docCopy;
}

/* -----------------------------------------------
 * Save the tree into and xml buffer
 * By design, there is no buf length stuff
 * Assume that an xml buffer will be a NULL 
 * terminated string and that is that.
 *
 * Always indent even though it uses a bit more memory
 * There are times when the buffer ends up getting dumped
 * to a file for viewing, the indenting is nice
 */
void VDxdomSaveTreeToXmlBuf(TGRid *treeID, IGRchar **bufXml)
{
  VDASSERT_FN("VDxdomSaveToXmlBuf");
  
  xmlNodePtr tree;
  xmlDocPtr  docCopy = NULL;  /* Possible copy */
  
  IGRint len;
  IGRint indent;
  
  // Arg check
  VDASSERTW(bufXml); *bufXml = NULL;
  VDASSERTW(treeID && treeID->objid != NULL_OBJID);

  // Get the node
  tree = xdom_nodeid_get_node(treeID);
  VDASSERTW(tree && tree->doc);

  // Copy if not the root
  docCopy = makeCopyIfNotRoot(tree);

  // Always indent
  indent = xmlIndentTreeOutput;
  xmlIndentTreeOutput = 1;
      
  // Doit
  if (docCopy == NULL) xmlDocDumpFormatMemory(tree->doc,(xmlChar**)bufXml,&len,1);
  else {
    xmlDocDumpFormatMemory(docCopy,(xmlChar**)bufXml,&len,1);
    xmlFreeDoc(docCopy);
  }
  xmlIndentTreeOutput = indent;
  
 wrapup:
  
  return;
}

/* -----------------------------------------------
 * Save the tree into an xml file
 */
void VDxdomSaveTreeToXmlFile(TGRid *treeID, IGRchar *fileName)
{
  VDASSERT_FN("VDxdomSaveToXmlBuf");
  
  xmlNodePtr tree;
  xmlDocPtr  docCopy = NULL;  /* Possible copy */
  
  IGRint len;
  IGRint indent;
  
  // Arg check
  VDASSERTW(fileName && *fileName);
  VDASSERTW(treeID && treeID->objid != NULL_OBJID);
  
  // Get the tree and doc pointer
  tree = xdom_nodeid_get_node(treeID);
  VDASSERTW(tree && tree->doc);

  // Copy if not the root
  docCopy = makeCopyIfNotRoot(tree);

  // Always indent
  indent = xmlIndentTreeOutput;
  xmlIndentTreeOutput = 1;
  
  // Doit
  if (docCopy == NULL) len = xmlSaveFormatFile(fileName,tree->doc,1);
  else {
    len = xmlSaveFormatFile(fileName,docCopy,1);
    xmlFreeDoc(docCopy);
  }
  xmlIndentTreeOutput = indent;
  VDASSERTW(len != -1);
  
 wrapup:
  
  return;
}

