/* $Id: xdom_isdp.c,v 1.2 2001/08/31 14:20:22 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vds/vdxdom/xdom_xml.c
 *
 * Description: Some public isdp routines
 *
 * Dependencies: 
 *
 * Revision History:
 *      $Log: xdom_isdp.c,v $
 *      Revision 1.2  2001/08/31 14:20:22  ahundiak
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
#include "VDxdom.h"

#include "glib.h"
#include "xdom.h"

VDASSERT_FFN("vdxdom/xdom_isdp");

/* -----------------------------------------------
 * Convert objid into a node
 */
xmlNodePtr xdom_nodeid_get_node(TGRid *nodeID)
{
  xmlNodePtr node = NULL;

  // Arg check
  if ((nodeID == NULL) || (nodeID->objid == NULL_OBJID)) goto wrapup;
  if (nodeID->osnum != XDOM_OSNUM) goto wrapup;
  
  // Convert it
  node = GUINT_TO_POINTER(nodeID->objid);

 wrapup:
  return node;
}

void xdom_nodeid_set_node(TGRid *nodeID, xmlNodePtr node)
{
  // Arg check
  if (nodeID == NULL) goto wrapup;
  nodeID->osnum = XDOM_OSNUM;

  // Convert it
  if (node) nodeID->objid = GPOINTER_TO_UINT(node);
  else      nodeID->objid = NULL_OBJID;
  
 wrapup:
  return;
  
}

gboolean xdom_nodeid_is_node(TGRid *nodeID)
{
  gboolean retFlag = 0;
  
  if ((nodeID == NULL) || (nodeID->objid == NULL_OBJID)) goto wrapup;
  if (nodeID->osnum != XDOM_OSNUM) goto wrapup;

  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Create a new xdom node
 * Append to optional parent
 *
 * If there is no parent then actually create a document
 * and return the root element
 *
 * This should actually never be called without a parent
 * but keep like this for now
 *
 * Note that is really no need for the calling program to check if the node
 * was actually created, the program will abort with g_assert if creation fails
 */
void VDxdomCreateNode(TGRid *parentID, IGRchar *name, TGRid *nodeID)
{
  VDASSERT_FN("VDxdomCreateNode");
  
  IGRstat retFlag = 0;
  
  xmlDocPtr  doc;
  xmlNodePtr node;
  xmlNodePtr parent;
  
  // Arg check
  VDASSERTW(nodeID); nodeID->objid = NULL_OBJID;
  VDASSERTW(name && *name);

  // Have parent
  parent = xdom_nodeid_get_node(parentID);
  if (parent) {

    // Get the parent pointer
    node = xmlNewChild(parent,NULL,(xmlChar*)name,NULL);
    g_assert(node);

    xdom_nodeid_set_node(nodeID,node);
    
    retFlag = 1;
    goto wrapup;

  }
  
  // Make a document
  doc = xmlNewDoc(NULL);
  g_assert(doc);
  doc->standalone = 1;
  
  // Make the node
  node = xmlNewDocNode(doc,NULL,(xmlChar*)name,NULL);
  g_assert(node);
  xmlDocSetRootElement(doc,node);
  
  // Done
  xdom_nodeid_set_node(nodeID,node);
  retFlag = 1;
    
 wrapup:

  g_assert(retFlag);
  
  return;
}

/* -----------------------------------------------
 * Create a new xdom tree
 * Creates a document as well but returns the root tree node
 */
void VDxdomCreateTree(IGRchar *name, TGRid *nodeID)
{
  VDASSERT_FN("VDxdomCreateTree");
  
  IGRstat retFlag = 0;
  
  xmlDocPtr  doc;
  xmlNodePtr node;
  xmlNodePtr parent;
  
  // Arg check
  VDASSERTW(nodeID); nodeID->objid = NULL_OBJID;
  VDASSERTW(name && *name);
  
  // Make a document
  doc = xmlNewDoc(NULL);
  g_assert(doc);
  doc->standalone = 1;
  
  // Make the node
  node = xmlNewDocNode(doc,NULL,(xmlChar*)name,NULL);
  g_assert(node);
  xmlDocSetRootElement(doc,node);
  
  // Done
  xdom_nodeid_set_node(nodeID,node);
  retFlag = 1;
    
 wrapup:

  g_assert(retFlag);
  
  return;
}

/* -----------------------------------------------
 * Delete a node and all it's children
 * Right now it actually deletes the entire document
 */
void VDxdomDeleteNode(TGRid *nodeID)
{
  xmlNodePtr node;
  
  // Ok not to have one
  node = xdom_nodeid_get_node(nodeID);
  if (node == NULL) goto wrapup;
  
  // This should do it
  if (node->doc) xmlFreeDoc (node->doc);
  else           xmlFreeNode(node);
  
 wrapup:
  return;
}
#if 0
/* -----------------------------------------------
 * This stuff was cut out of the actual libxml2 
 * source code.  Added a binary data pointer to the attribute
 * structure as well as an optional free routine
 */

/*
 * A attribute of an XML node.
 */
typedef struct _xmlAttrBin xmlAttrBin;
typedef xmlAttrBin *xmlAttrBinPtr;
struct _xmlAttrBin {
#ifndef XML_WITHOUT_CORBA
    void           *_private;	/* for Corba, must be first ! */
#endif
    xmlElementType   type;      /* XML_ATTRIBUTE_NODE, must be second ! */
    const xmlChar   *name;      /* the name of the property */
    struct _xmlNode *children;	/* the value of the property */
    struct _xmlNode *last;	/* NULL */
    struct _xmlNode *parent;	/* child->parent link */
    struct _xmlAttr *next;	/* next sibling link  */
    struct _xmlAttr *prev;	/* previous sibling link  */
    struct _xmlDoc  *doc;	/* the containing document */
    xmlNs           *ns;        /* pointer to the associated namespace */
    xmlAttributeType atype;     /* the attribute type if validating */

  void *binData;
  void (*binFree)(void *data);
  
};

xmlAttrPtr
xmlNewProp(xmlNodePtr node, const xmlChar *name, const xmlChar *value) {
    xmlAttrPtr cur;
    xmlDocPtr doc = NULL;

    if (name == NULL) {
#ifdef DEBUG_TREE
        xmlGenericError(xmlGenericErrorContext,
		"xmlNewProp : name == NULL\n");
#endif
	return(NULL);
    }

    /*
     * Allocate a new property and fill the fields.
     */
    cur = (xmlAttrPtr) xmlMalloc(sizeof(xmlAttrBin));
    if (cur == NULL) {
        xmlGenericError(xmlGenericErrorContext,
		"xmlNewProp : malloc failed\n");
	return(NULL);
    }
    memset(cur, 0, sizeof(xmlAttrBin));
    cur->type = XML_ATTRIBUTE_NODE;

    cur->parent = node; 
    if (node != NULL) {
	doc = node->doc;
	cur->doc = doc;
    }
    cur->name = xmlStrdup(name);
    if (value != NULL) {
	xmlChar *buffer;
	xmlNodePtr tmp;

	buffer = xmlEncodeEntitiesReentrant(doc, value);
	cur->children = xmlStringGetNodeList(doc, buffer);
	cur->last = NULL;
	tmp = cur->children;
	while (tmp != NULL) {
	    tmp->parent = (xmlNodePtr) cur;
	    tmp->doc = doc;
	    if (tmp->next == NULL)
		cur->last = tmp;
	    tmp = tmp->next;
	}
	xmlFree(buffer);
    }	

    /*
     * Add it at the end to preserve parsing order ...
     */
    if (node != NULL) {
	if (node->properties == NULL) {
	    node->properties = cur;
	} else {
	    xmlAttrPtr prev = node->properties;

	    while (prev->next != NULL) prev = prev->next;
	    prev->next = cur;
	    cur->prev = prev;
	}
    }
    return(cur);
}
xmlAttrPtr
xmlNewNsProp(xmlNodePtr node, xmlNsPtr ns, const xmlChar *name,
           const xmlChar *value) {
    xmlAttrPtr cur;

    if (name == NULL) {
#ifdef DEBUG_TREE
        xmlGenericError(xmlGenericErrorContext,
		"xmlNewProp : name == NULL\n");
#endif
	return(NULL);
    }
    // printf(">>> xmlNewNsProp %s\n",name);
    
    /*
     * Allocate a new property and fill the fields.
     */
    cur = (xmlAttrPtr) xmlMalloc(sizeof(xmlAttrBin));
    if (cur == NULL) {
        xmlGenericError(xmlGenericErrorContext,
		"xmlNewProp : malloc failed\n");
	return(NULL);
    }
    memset(cur, 0, sizeof(xmlAttrBin));
    cur->type = XML_ATTRIBUTE_NODE;

    cur->parent = node; 
    if (node != NULL)
	cur->doc = node->doc; 
    cur->ns = ns;
    cur->name = xmlStrdup(name);
    if (value != NULL) {
	xmlChar *buffer;
	xmlNodePtr tmp;

	buffer = xmlEncodeEntitiesReentrant(node->doc, value);
	cur->children = xmlStringGetNodeList(node->doc, buffer);
	cur->last = NULL;
	tmp = cur->children;
	while (tmp != NULL) {
	    tmp->parent = (xmlNodePtr) cur;
	    if (tmp->next == NULL)
		cur->last = tmp;
	    tmp = tmp->next;
	}
	xmlFree(buffer);
    }

    /*
     * Add it at the end to preserve parsing order ...
     */
    if (node != NULL) {
	if (node->properties == NULL) {
	    node->properties = cur;
	} else {
	    xmlAttrPtr prev = node->properties;

	    while (prev->next != NULL) prev = prev->next;
	    prev->next = cur;
	    cur->prev = prev;
	}
    }
    return(cur);
}
xmlAttrPtr
xmlNewDocProp(xmlDocPtr doc, const xmlChar *name, const xmlChar *value) {
    xmlAttrPtr cur;

    if (name == NULL) {
#ifdef DEBUG_TREE
        xmlGenericError(xmlGenericErrorContext,
		"xmlNewProp : name == NULL\n");
#endif
	return(NULL);
    }

    /*
     * Allocate a new property and fill the fields.
     */
    cur = (xmlAttrPtr) xmlMalloc(sizeof(xmlAttrBin));
    if (cur == NULL) {
        xmlGenericError(xmlGenericErrorContext,
		"xmlNewProp : malloc failed\n");
	return(NULL);
    }
    memset(cur, 0, sizeof(xmlAttrBin));
    cur->type = XML_ATTRIBUTE_NODE;

    cur->name = xmlStrdup(name);
    cur->doc = doc; 
    if (value != NULL) {
	xmlNodePtr tmp;

	cur->children = xmlStringGetNodeList(doc, value);
	cur->last = NULL;

	tmp = cur->children;
	while (tmp != NULL) {
	    tmp->parent = (xmlNodePtr) cur;
	    if (tmp->next == NULL)
		cur->last = tmp;
	    tmp = tmp->next;
	}
    }
    return(cur);
}
void
xmlFreeProp(xmlAttrPtr cur) {

  xmlAttrBinPtr bin;
  
    if (cur == NULL) {
#ifdef DEBUG_TREE
        xmlGenericError(xmlGenericErrorContext,
		"xmlFreeProp : property == NULL\n");
#endif
	return;
    }
    /* Check for ID removal -> leading to invalid references ! */
    if ((cur->parent != NULL) && 
        (xmlIsID(cur->parent->doc, cur->parent, cur)))
        xmlRemoveID(cur->parent->doc, cur);
    if (cur->name != NULL) xmlFree((char *) cur->name);
    if (cur->children != NULL) xmlFreeNodeList(cur->children);

    // Free any bin data
    bin = (xmlAttrBinPtr) cur;
    if (bin->binData) {
      if (bin->binFree) (*bin->binFree)(bin->binData);
      else                        free (bin->binData);
    }
    xmlFree(cur);
}

void *xmlGetBinProp(xmlNodePtr node, xmlChar *name)
{
  xmlAttrPtr attr;

  if (node == NULL) return NULL;
  attr = xmlHasProp(node,name);
  if (attr == NULL) return NULL;

  return ((xmlAttrBin*)attr)->binData;
}

void xmlSetBinProp(xmlNodePtr node, xmlChar *name, void *binData, void (*binFree)(void *data))
{
  xmlAttrPtr attr;

  if (node == NULL) return;
  attr = xmlHasProp(node,name);
  if (attr == NULL) return;

  ((xmlAttrBin*)attr)->binData = binData;
  ((xmlAttrBin*)attr)->binFree = binFree;
}
#endif
