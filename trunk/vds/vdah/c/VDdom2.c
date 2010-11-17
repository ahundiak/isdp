/* $Id: VDdom2.c,v 1.1 2004/03/29 15:21:15 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vds/vdah/c/VDdom2.c
 *
 * Description: Simple interface to libxml2
 *
 * Dependencies:
 *
 * Revision History:
 * $Log: VDdom2.c,v $
 * Revision 1.1  2004/03/29 15:21:15  ahundiak
 * ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 02/13/04  ah      Creation
 ***************************************************************************/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>

#include <libxml/xmlerror.h>
#include <libxml/xmlmemory.h>
#include <libxml/parser.h>

#define g_assert(x) assert(x)

#define DOM_C
typedef xmlNodePtr domNode;

#include "VDdom2.h"

/* ----------------------------------------------
 * My own create child node routine
 */
domNode domCreateNode(domNode parentNode, char *name)
{
  domNode childNode;

  /* Arg check */
  g_assert(parentNode);
  g_assert(name && *name);

  /* Create it */
  childNode = xmlNewChild(parentNode,NULL,(xmlChar*)name,NULL);
  g_assert(childNode);

  /* Done */
  return childNode;

}

/* ----------------------------------------------
 * Little easier to create with content
 */
domNode domCreateNodeWithContent(domNode parentNode, char *name, char *content)
{
  domNode childNode;

  /* Arg check */
  g_assert(parentNode);
  g_assert(name && *name);

  /* Create it */
  childNode = xmlNewChild(parentNode,NULL,(xmlChar*)name,NULL);
  g_assert(childNode);

  /* Add content if have it */
  if (content && *content) xmlNodeSetContent(childNode,(xmlChar*)content);

  /* Done */
  return childNode;

}

/* ----------------------------------------------
 * Not completely positive about how the tree is
 * origanized.  Use this to make sure you have an
 * element node
 */
int domIsNode(domNode node)
{
  g_assert(node);
  if (node->type != XML_ELEMENT_NODE) return 0;
  return 1;
}
/* ----------------------------------------------
 * Confirms you have a node of a given name
 */
int domIsNodeName(domNode node, char *name)
{
  g_assert(node);
  g_assert(name && *name);

  if (!domIsNode(node)) return 0;
  if (strcmp((char *)node->name,name)) return 0;
  return 1;
}

/* ----------------------------------------------
 * The always important name
 */
char *domGetNodeName(domNode node)
{
  g_assert(node);
  return (char *)node->name;
}

/* ----------------------------------------------
 * Simple interface to getting content
 *
 * Returns value if no content
 *
 * If content is found:
 * Returns value if value is not NULL
 *
 * Otherwise, space is allocated
 * User must free with xmlDomFreeValue
 */
char *domGetNodeContent(domNode node, char *value)
{
  char *valuex;
  
  /* Arg check */
  if (value) *value = 0;
  g_assert(node);

  /* See if have something */
  valuex = (char*)xmlNodeGetContent(node);
  if (!valuex) return value;

  /* Copy if the user provided storage space */
  if (value) {
    strcpy(value,valuex);
    xmlFree((xmlChar*)valuex);
  }
  else value = valuex;

  /* Return it */
  return value;
}
/* ----------------------------------------------
 * Set the content of a node
 */
void domSetNodeContent(domNode node, char *value)
{
  /* Arg check */
  g_assert(node);
  g_assert(value);

  /* Do it */
  xmlNodeSetContent(node,(xmlChar*)value);

  /* Done */
  return;
}
/* ----------------------------------------------
 * returns node if node has the property
 * else retruns NULL
 */
domNode domHasNodeProp(domNode node, char *name)
{
  g_assert(node);
  g_assert(name && *name);

  if (xmlHasProp(node,(xmlChar*)name)) return node;

  return NULL;
}
domNode domHasNodePropDesc(domNode node, char *name)
{
  domNode childNode;
  domNode propNode;
  
  g_assert(node);
  g_assert(name && *name);

  if (xmlHasProp(node,(xmlChar*)name)) return node;

  /* Check kids */
  for(childNode = node->xmlChildrenNode; childNode; childNode = childNode->next) 
  {
    if (domIsNode(childNode)) 
    {
      propNode = domHasNodePropDesc(childNode,name);
      if (propNode) return propNode;
    }
  }
  return NULL;
}

/* ----------------------------------------------
 * Simple interface to getting a property
 *
 * Returns value if property is not found
 *
 * If property is found:
 * Returns value if value is not NULL
 *
 * Otherwise, space is allocated
 * User must free with xmlDomFreeValue
 */
char *domGetNodeProp(domNode node, char *name, char *value)
{
  char *valuex;

  /* Arg Check */
  if (value) *value = 0;
  g_assert(name && *name);
  g_assert(node);

  valuex = (char*)xmlGetProp(node,(xmlChar*)name);
  if (!valuex) return value;

  if (value) 
  {
    strcpy(value,valuex);
    xmlFree(valuex);
  }
  else value = valuex;

  return value;
}
/* ----------------------------------------------
 * Check the current node and all it's
 * descendents for a property
 *
 * Returns value if property is not found
 *
 * If property is found:
 * Returns value if value is not NULL
 *
 * Otherwise, space is allocated
 * User must free with xmlDomFreeValue
 */
char *domGetNodePropDesc(domNode node, char *name, char *value)
{
  domNode propNode;
  
  /* Arg Check */
  if (value) *value = 0;
  g_assert(name && *name);
  g_assert(node);

  /* Find node with property */
  propNode = domHasNodePropDesc(node,name);
  if (!propNode) return value;

  return domGetNodeProp(propNode,name,value);
}
/* ----------------------------------------------
 * Returns the name of the nth property
 * returns NULL id no more
 */
char *domGetNodeNthPropName(domNode node, int nth, char *name)
{
  xmlAttr *attr;

  /* Arg Check */
  g_assert(name); *name = 0;
  g_assert(node);
  g_assert(nth >= 0);

  /* Loop through */
  for(attr = node->properties; attr; attr = attr->next, nth--)
  {
    if (!nth) 
    {
      strcpy(name,(char*)attr->name);
      return name;
    }
  }

  return NULL;
}

/* ----------------------------------------------
 * Set a particular property
 */
void domSetNodeProp(domNode node, char *name, char *value)
{
  /* Arg Check */
  g_assert(node);
  g_assert(name && *name);
  g_assert(value);

  xmlSetProp(node,(xmlChar*)name,(xmlChar*)value);

  return;
}
void domSetNodeTextProp(domNode node, char *name, char *value)
{
  /* Arg Check */
  g_assert(node);
  g_assert(name && *name);
  g_assert(value);

  xmlSetProp(node,(xmlChar*)name,(xmlChar*)value);

  return;
}

void domSetNodeIntProp(domNode node, char *name, int value)
{
  char prop[32];

  sprintf(prop,"%d",value);

  domSetNodeProp(node,name,prop);
}
/* ----------------------------------------------
 * To cycle through kids
 */
domNode domGetNthChildNode(domNode parentNode,int nth)
{
  domNode childNode;

  g_assert(parentNode);

  for(childNode = parentNode->xmlChildrenNode; childNode; childNode = childNode->next) {
    if (domIsNode(childNode)) {
      if (!nth--) return childNode;
    }
  } 
  return NULL;
}

/* ----------------------------------------------
 * To cycle kids by name
 */
domNode domGetNthChildNodeForName(domNode parentNode,char *name, int nth)
{
  domNode childNode;

  g_assert(parentNode);
  g_assert(name && *name);

  for(childNode = parentNode->xmlChildrenNode; childNode; childNode = childNode->next) {
    /* For some reason, using g_ascii_strcasecmp gives an assert under VC++ */
    if (domIsNode(childNode) && !strcmp((char*)childNode->name,name)) {
      if (!nth--) return childNode;
    }
  } 
  return NULL;
}
/* ----------------------------------------------
 * Handy for allocting structures
 */
int domGetChildCountForName(domNode parentNode, char *name)
{
  int cnt = 0;
  domNode childNode;

  g_assert(parentNode);
  g_assert(name && *name);

  for(childNode = parentNode->xmlChildrenNode; childNode; childNode = childNode->next) {
    if (domIsNode(childNode) && !strcmp((char*)childNode->name,name)) {
      cnt++;
    }
  } 
  return cnt;
}
/* ----------------------------------------------
 * Handy for writing
 *
 * Returns value if content is not found
 *
 * If content is found:
 * Returns value if value is not NULL
 *
 * Otherwise, space is allocated
 * User must free with xmlDomFreeValue
 */
char *domGetNthChildContentForName(domNode parentNode,char *name, int nth, char *value)
{
  domNode childNode;

  /* Arg Check */
  if (value) *value = 0;
  g_assert(parentNode);
  g_assert(name && *name);

  /* get the node */
  childNode = domGetNthChildNodeForName(parentNode,name,nth);
  if (!childNode) return value;

  /* And the content */
  return domGetNodeContent(childNode,value);
}
/* ----------------------------------------------
 * Get parent node
 * name is optional
 */
domNode domGetParentNode(domNode node,char *name)
{
  domNode parentNode;

  /* Arg check */
  g_assert(node);
 
  /* Get the parent */
  parentNode = node->parent;
  if (!parentNode) return NULL;

  /* Check optional name */
  if (!name) return parentNode;
  if (domIsNodeName(parentNode,name)) return parentNode;

  /* recurse up */
  return domGetParentNode(parentNode,name);

}

/* ----------------------------------------------
 * Document creation and destruction
 */
domNode domCreateDoc(char *rootNodeName)
{
  xmlDocPtr doc;
  domNode   rootNode;
  
  /* Arg check */
  g_assert(rootNodeName && *rootNodeName);

  /* Make the doc */
  doc = xmlNewDoc(NULL);
  g_assert(doc);
  doc->standalone = 1;

  /* The root */
  rootNode = xmlNewDocNode(doc,NULL,(xmlChar*)rootNodeName,NULL);
  g_assert(rootNode);
  xmlDocSetRootElement(doc,rootNode);

  /* Done */
  return rootNode;
}

/* ----------------------------------------------
 * Intercept xml error messages
 */
static void domGenericErrorFunc(void *ctx, const char *msg, ...)
{
  // printf("XML ERROR %s\n",msg);
  return;
}
void domSuppressErrors()
{
  xmlSetGenericErrorFunc(NULL,domGenericErrorFunc);
  return;
}

/* ----------------------------------------------
 * Create a document from an xml file
 * returns the root node
 */
domNode domCreateDocFromFile(char *fileName)
{  
  xmlDocPtr doc;
  domNode   rootNode = NULL;
 
  /* Arg check */
  g_assert(fileName && *fileName);
  
  /* Load it */
  doc = xmlParseFile(fileName);
  if (doc == NULL) return rootNode;

  /* Save the root node */
  rootNode = xmlDocGetRootElement(doc);
  g_assert(rootNode);

  /* Done */
  return rootNode;
}
/* ----------------------------------------------
 * Frees entire document structure
 */
void domFreeDoc(domNode rootNode)
{
  g_assert(rootNode && rootNode->doc);

  xmlFreeDoc(rootNode->doc);
}
/* ----------------------------------------------
 * Free strings allocated from either content
 * or property values
 */
void domFreeValue(char *value)
{
  if (value) xmlFree((xmlChar*)value);
  return;
}
/* ----------------------------------------------
 * Save the tree in an xml file
 */
void domSaveDocToFile(domNode rootNode, char *fileName)
{
  g_assert(rootNode);
  g_assert(fileName && *fileName);
  
  xmlIndentTreeOutput = 1;
  xmlSaveFormatFile(fileName,rootNode->doc,1);

  return;
}
void domSaveDocToBuf(domNode rootNode, char **buf)
{
  int len;

  g_assert(rootNode);
  g_assert(buf); *buf = NULL;

  xmlIndentTreeOutput = 1;
  xmlDocDumpFormatMemory(rootNode->doc,(xmlChar**)buf,&len,1);

  return;
}

/* ----------------------------------------------
 * Creates an attribute node
 * sort of like an ACrg_coll
 */
domNode domCreateTextAttrNode(domNode parentNode, char *name, char *value)
{
  domNode attrNode;

  attrNode = domCreateNode(parentNode,"attr");
  domSetNodeProp(attrNode,"name", name);
  domSetNodeProp(attrNode,"value",value);

  return attrNode;
}
domNode domCreateIntAttrNode(domNode parentNode, char *name, int value)
{
  domNode attrNode;

  attrNode = domCreateNode(parentNode,"attr");
  domSetNodeProp   (attrNode,"name", name);
  domSetNodeIntProp(attrNode,"value",value);

  return attrNode;
}

/* ----------------------------------------------
 * Look for an attr node with a given name and return it
 */
domNode domGetAttrNode(domNode parentNode, char *name)
{
  int  i;
  char attrName[64];

  domNode attrNode = NULL;

  g_assert(name && *name);
  g_assert(parentNode);

  for(i = 0; attrNode = domGetNthChildNode(parentNode,i); i++)
  {
    domGetNodeProp(attrNode,"name",attrName);
    if (!strcasecmp(attrName,name)) goto wrapup;
  }

wrapup:
  return attrNode;
}
/* ----------------------------------------------
 * Sets the value of the attr node of the given name
 * create if necessary
 */
char *domSetTextAttrNodeValue(domNode parentNode, char *name, char *value)
{
  domNode attrNode;

  g_assert(value);
  g_assert(name && *name);
  g_assert(parentNode);

  /* Get it */
  attrNode = domGetAttrNode(parentNode,name);
  if (attrNode == NULL)
  {
    attrNode = domCreateNode(parentNode,"attr");
    domSetNodeProp(attrNode,"name", name);
  }
  domSetNodeProp(attrNode,"value", value);

  return value;
}

/* ----------------------------------------------
 * Look for a text attr node for the given name
 * and return the value
 */
char *domGetTextAttrNodeValue(domNode parentNode, char *name, char *value)
{
  domNode attrNode;

  g_assert(value); *value = 0;
  g_assert(name && *name);
  g_assert(parentNode);

  attrNode = domGetAttrNode(parentNode,name);
  if (attrNode)
  {
    domGetNodeProp(attrNode,"value",value);
  }

  return value;
}
/* ----------------------------------------------
 * Look for a int attr node for the given name
 * and return the value
 */
int domGetIntAttrNodeValue(domNode parentNode, char *name, int *value)
{
  char buf[128];

  domNode attrNode;

  int valuex;

  if (value == NULL) value = &valuex;
  *value = 0;

  g_assert(name && *name);
  g_assert(parentNode);

  attrNode = domGetAttrNode(parentNode,name);
  if (attrNode)
  {
    domGetNodeProp(attrNode,"value",buf);
    *value = atoi(buf);
  }

  return *value;
}

/* ----------------------------------------------
 * These work directly on the attr node itself
 */
char *domGetAttrNodeValue(domNode attrNode, char *value)
{
  g_assert(value); *value = 0;
  g_assert(attrNode);

  domGetNodeProp(attrNode,"value",value);
  return value;
}
char *domSetAttrNodeValue(domNode attrNode, char *value)
{
  g_assert(value);
  g_assert(attrNode);

  domSetNodeProp(attrNode,"value",value);
  return value;
}

