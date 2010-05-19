/* $Id: cdom_xml.c,v 1.5 2001/06/07 18:56:46 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vds/vdcdom/cdom_xml.c
 *
 * Description: xml2 based routines
 *
 * Dependencies: 
 *
 * Revision History:
 *      $Log: cdom_xml.c,v $
 *      Revision 1.5  2001/06/07 18:56:46  ahundiak
 *      ah
 *
 *      Revision 1.4  2001/05/25 19:40:31  ahundiak
 *      ah
 *
 *      Revision 1.3  2001/05/24 18:41:25  ahundiak
 *      ah
 *
 *      Revision 1.2  2001/05/17 14:45:38  ahundiak
 *      ah
 *
 *      Revision 1.1  2001/05/02 15:07:25  ahundiak
 *      ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 05/14/01  ah      Created
 ***************************************************************************/
#include "VDtypedefc.h"
#include "VDassert.h"
#include "VDlog.h"
#include "VDxml.h"
#include "VDctx.h"
#include "VDcdom.h"

#include "glib.h"
#include "cdom.h"

#include <libxml/xmlerror.h>
#include <libxml/xmlmemory.h>
#include <libxml/parser.h>
#include <libxml/parserInternals.h>

VDASSERT_FFN("cdom_xml.c");

typedef struct 
{
  CDOMnode *tree;
  CDOMnode *node;
} Tdata;

/* -----------------------------------------------
 * Process beginning of element
 */
static void startElement(void *ctx, const xmlChar *name, const xmlChar **atts)
{
  VDASSERT_FN("startElement");

  Tdata *data = (Tdata*)ctx;

  gchar  *eleName = (gchar*)name;
  
  gint   i;
  gchar *atrName;
  gchar *atrValue;

  CDOMnode *parent;
  CDOMnode *node;
  
  // Build new node
  node = cdom_node_new(eleName);

  // fprintf(stderr,"Name %s\n",eleName);
  
  //if (!strcmp(eleName,"PDF_OBJ_TREE_NODE")) {
  //fprintf(stderr,"Tree Node\n");
  //}
  
  // Is it the tree
  if (data->tree == NULL) data->tree = node;
  if (data->node == NULL) data->node = node;
  else {
    cdom_node_append(data->node,node);
    data->node = node;
  }      

  // Attributes
  if (atts) {    
    for(i = 0; atts[i] && atts[i+1]; i += 2) {
      atrName  = (gchar*)atts[i];
      atrValue = (gchar*)atts[i+1];
      node->attrs = cdom_attr_new(node->attrs,atrName,atrValue);      
    }
  }
  
 wrapup:
  return;
  
}

static void endElement(void *ctx, const xmlChar *name)
{
  VDASSERT_FN("endElement");

  Tdata *data = (Tdata*)ctx;

  if (data->node) data->node = cdom_node_get_parent(data->node);  
 
 wrapup:
  return;
  
}

/* ----------------------------------------------------------
 * Note that this can get called multiple times even if
 * there is only one content area, needs to string things
 * together.
 */
static void characters(void *ctx, const xmlChar *ch, int len)
{
  VDASSERT_FN("endElement");

  Tdata *data = (Tdata*)ctx;
  CDOMnode *node;

  gchar *p = NULL;
  gchar buf[256];
  gint  i;
  
  // Ignore if all blank or something
  for(i = 0; (i < len) && (ch[i] <= ' ');i++);
  if (i == len) goto wrapup;
  
  // Allocate a buffer
  if (len > 255) p = g_malloc(len+1);
  else           p = buf;
  
  memcpy(p,ch,len);
  *(p + len) = 0;
  
  // printf("Characters %s\n",p);
  node = data->node;
  if (!node) goto wrapup;
  if (!node->content) node->content = g_string_new(p);
  else                node->content = g_string_append(node->content,p);
  
 wrapup:
  if (p != buf) g_free(p);
  
  return;
}

/* -----------------------------------------------
 * Generate a dom tree from an xml file
 */
void VDcdomCreateTreeFromXmlFile(IGRchar *xmlFileName, TGRid *treeID)
{
  VDASSERT_FN("VDcdomCreateTreeFromXmlFile");
  gint sts;

  xmlSAXHandler sax;
  
  Tdata data;
  
  // Arg check
  VDASSERTW(treeID); treeID->objid = NULL_OBJID;
  VDASSERTW(xmlFileName && *xmlFileName);
  memset(&data,0,sizeof(Tdata));
  
  // Init the sax functions
  memset(&sax,0,sizeof(xmlSAXHandler));
  sax.startElement = startElement;
  sax.endElement   = endElement;
  sax.characters   = characters;

  sax.warning    = xmlParserWarning;
  sax.error      = xmlParserError;
  sax.fatalError = xmlParserError;

  // Parse it    
  sts = xmlSAXUserParseFile(&sax,&data,xmlFileName);
  if (sts) printf("*** Problm parsing file\n");

  // Grab the tree
  if (data.tree == NULL) goto wrapup;
  cdom_nodeid_set_node(treeID,data.tree);
  
 wrapup:
  return;
}

/* -----------------------------------------------
 * Generate a dom tree from an xml buffer
 */
void VDcdomCreateTreeFromXmlBuf(IGRchar *xmlBuf, TGRid *treeID)
{
  VDASSERT_FN("VDcdomCreateTreeFromXmlBuf");
  gint sts;

  xmlSAXHandler sax;
  
  Tdata data;
  IGRint size;
  
  // Arg check
  VDASSERTW(treeID); treeID->objid = NULL_OBJID;
  VDASSERTW(xmlBuf && *xmlBuf);
  memset(&data,0,sizeof(Tdata));
  
  // Init the sax functions
  memset(&sax,0,sizeof(xmlSAXHandler));
  sax.startElement = startElement;
  sax.endElement   = endElement;
  sax.characters   = characters;

  sax.warning    = xmlParserWarning;
  sax.error      = xmlParserError;
  sax.fatalError = xmlParserError;

  // Parse it 
  size = strlen(xmlBuf);
  sts = xmlSAXUserParseMemory(&sax,&data,xmlBuf,size);
  if (sts) printf("*** Problm parsing buffer\n");

  // Grab the tree
  if (data.tree == NULL) goto wrapup;
  cdom_nodeid_set_node(treeID,data.tree);
  
 wrapup:
  return;
}

/* -----------------------------------------------
 * Grab an xml file from a server then convert
 * to a cdom tree, max file size of 100K for now
 */
void VDcdomCreateTreeFromWebFile(IGRchar *server, IGRchar *fileName, TGRid *treeID)
{
  VDASSERT_FN("VDcdomCreateTreeFromWebFile");

  IGRchar *buf = NULL;
  IGRint   size = 100000;
  
  // Arg check
  VDASSERTW(treeID); treeID->objid = NULL_OBJID;
  VDASSERTW(fileName && *fileName);

  // Check for default server
  if (server == NULL) server = getenv("ISDP_WEB_SERVER");
  if (server == NULL) goto wrapup;
  VDASSERTW(*server);
  
  // Alloc
  buf = malloc(size);
  VDASSERTW(buf);

  // Get the file
  VDhttpDoGet(server,80,fileName,size,buf);
  if (*buf == 0) goto wrapup;
  
  // Convert to tree
  VDcdomCreateTreeFromXmlBuf(buf,treeID);

 wrapup:
  if (buf) free(buf);
}
/* --------------------------------------------
 * Recursive writing of a node to an xml stream
 */
void VDcdomWriteNodeToXmlStream(TGRid *nodeID, TVDxmlFileInfo *xml)
{
  VDASSERT_FN("VDcdomWriteToXmlStream");

  TGRid   childID;
  IGRint  i;
  
  CDOMnode *node;
  CDOMattr *attr;
  
  // Arg check
  VDASSERTW(xml);
  VDASSERTW(nodeID && nodeID->objid != NULL_OBJID);
  
  // Get the actual node
  node = cdom_nodeid_get_node(nodeID);
  VDASSERTW(node);

  // Flag if have attributes
  attr = node->attrs;
  if (attr) VDxmlWriteObjBeg(xml,node->name->str,1,1);
  else      VDxmlWriteObjBeg(xml,node->name->str,0,1);
  
  while(attr) {
    
    // Write attributes
    VDxmlWriteAtrTxt(xml,attr->name->str,attr->txt->str,1,1);
    attr = attr->next;
    
  }
  // End of attributes
  if (node->attrs) VDxmlWriteAtrEnd(xml,1,1);
  
  // Cycle through kids
  for(i = 0; VDctxGetNthTreeChild(nodeID,i,&childID); i++) {
    VDcdomWriteNodeToXmlStream(&childID,xml);
  }
  
  // Finish the object
  VDxmlWriteObjEnd(xml,node->name->str,1);
  
  // Done
 wrapup:
  return;
}

/* -----------------------------------------------
 * Save the tree into and xml buffer
 * By design, there is no buf length stuff
 * Assume that an xml buffer will be a NULL 
 * terminated string and that is that.
 */
void VDcdomSaveTreeToXmlBuf(TGRid *treeID, IGRchar **bufXml)
{
  VDASSERT_FN("VDcdomSaveToXmlBuf");
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
  VDcdomWriteNodeToXmlStream(treeID,&xml);
  
  // Return the args
  *bufXml = xml.io.buf;
  
  // Done

 wrapup:

  VDxmlCloseOutputStream(&xml);
  
  return;
}

/* -----------------------------------------------
 * Save the tree into an xml file
 */
void VDcdomSaveTreeToXmlFile(TGRid *treeID, IGRchar *fileName)
{
  VDASSERT_FN("VDcdomSaveToXmlBuf");
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
  VDcdomWriteNodeToXmlStream(treeID,&xml);
  
 wrapup:

  VDxmlCloseOutputStream(&xml);
  
  return;
}
