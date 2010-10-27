/* $Id: xdom_sax.c,v 1.1 2001/11/16 14:27:51 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vds/vdxdom/xdom_sax.c
 *
 * Description: xdom sax routines
 *
 * Dependencies: 
 *
 * Revision History:
 *      $Log: xdom_sax.c,v $
 *      Revision 1.1  2001/11/16 14:27:51  ahundiak
 *      ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 11/14/01  ah      Created
 ***************************************************************************/
#include "VDtypedefc.h"
#include "VDassert.h"
#include "VDlog.h"
#include "VDxml.h"
#include "VDctx.h"
#include "VDxdom.h"

#include "glib.h"
#include "xdom.h"

#include "libxml/parserInternals.h"

VDASSERT_FFN("xdom_sax.c");

typedef struct
{
  xmlParserCtxtPtr ctxt;
  xmlNodePtr       root;
} TuserData;

static void startElement(void *a_userData, const xmlChar *name, const xmlChar **atts)
{
  TuserData *userData = (TuserData*)a_userData;

  xmlDocPtr  doc;
  xmlNodePtr root;

  IGRint i;

  // Check for multiple calls
  if (userData->root) goto wrapup;
  
  // Make new tree
  doc = xmlNewDoc(NULL);
  g_assert(doc);
  doc->standalone = 1;
  
  // Make the node
  root = xmlNewDocNode(doc,NULL,name,NULL);
  g_assert(root);
  xmlDocSetRootElement(doc,root);
  userData->root = root;

  // Attributes
  if (atts) {    
    for(i = 0; atts[i] && atts[i+1]; i += 2) {

      xmlNewProp(root,atts[i+0],atts[i+1]);
      
    }
  }
  
 wrapup:
  // Stop parsing
  userData->ctxt->disableSAX = 1;
  userData->ctxt->instate = XML_PARSER_EOF;
  
}

/* -----------------------------------------------
 * Want to parse only the root node
 */
void VDxdomCreateRootFromXmlBuf(IGRchar *xmlBuf, TGRid *rootID)
{
  VDASSERT_FN("VDxdomCreateRootFromXmlBuf");

  xmlDocPtr  doc = NULL;
  xmlNodePtr root;

  IGRint len;

  xmlParserCtxtPtr ctxt;
  xmlSAXHandler    sax;
  xmlSAXHandlerPtr saxOld;

  TuserData userData;
  
  // Arg check
  VDASSERTW(rootID); rootID->objid = NULL_OBJID;
  VDASSERTW(xmlBuf && *xmlBuf);

  // Buffer info
  len = strlen(xmlBuf);

  // Init the sax functions
  memset(&sax,0,sizeof(xmlSAXHandler));
  sax.startElement = startElement;

  // Have to mess around with ctx stuff
  ctxt = xmlCreateMemoryParserCtxt(xmlBuf,len);
  if (ctxt == NULL) goto wrapup;

  // Sax info
  saxOld = ctxt->sax;
  ctxt->sax = &sax;
  
  // User data
  memset(&userData,0,sizeof(TuserData));
  userData.ctxt = ctxt;
  ctxt->userData = &userData;
    
  // Parse it
  xmlParseDocument(ctxt);

  // Results
  if (userData.root) {
    xdom_nodeid_set_node(rootID,userData.root);
  }
  
  // Cleanup
  ctxt->sax = saxOld;
  xmlFreeParserCtxt(ctxt);
    
 wrapup:
  return;
}

/* -----------------------------------------------
 * Want to parse only the root node
 */
void VDxdomCreateRootFromXmlFile(IGRchar *xmlFileName, TGRid *rootID)
{
  VDASSERT_FN("VDxdomCreateRootFromXmlFile");

  xmlDocPtr  doc = NULL;
  xmlNodePtr root;

  IGRint len;

  xmlParserCtxtPtr ctxt;
  xmlSAXHandler    sax;
  xmlSAXHandlerPtr saxOld;

  TuserData userData;
  
  // Arg check
  VDASSERTW(rootID); rootID->objid = NULL_OBJID;
  VDASSERTW(xmlFileName && *xmlFileName);

  // Init the sax functions
  memset(&sax,0,sizeof(xmlSAXHandler));
  sax.startElement = startElement;

  // Have to mess around with ctx stuff
  ctxt = xmlCreateFileParserCtxt(xmlFileName);
  if (ctxt == NULL) goto wrapup;

  // Sax info
  saxOld = ctxt->sax;
  ctxt->sax = &sax;
  
  // User data
  memset(&userData,0,sizeof(TuserData));
  userData.ctxt = ctxt;
  ctxt->userData = &userData;
  
  // Parse it
  xmlParseDocument(ctxt);

  // Results
  if (userData.root) {
    xdom_nodeid_set_node(rootID,userData.root);
  }
  
  // Cleanup
  ctxt->sax = saxOld;
  xmlFreeParserCtxt(ctxt);
    
 wrapup:
  return;
}
