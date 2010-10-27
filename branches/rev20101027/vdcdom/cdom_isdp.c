/* $Id: cdom_isdp.c,v 1.2 2001/08/15 23:54:04 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vds/vdcdom/cdom_xml.c
 *
 * Description: Some public isdp routines
 *
 * Dependencies: 
 *
 * Revision History:
 *      $Log: cdom_isdp.c,v $
 *      Revision 1.2  2001/08/15 23:54:04  ahundiak
 *      ah
 *
 *      Revision 1.1  2001/05/17 14:45:38  ahundiak
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
#include "VDcdom.h"

#include "glib.h"
#include "cdom.h"

VDASSERT_FFN("vdcdom/cdom_isdp");

typedef struct
{
  IGRint type;
  IGRint stdoutFlag;
} TlogData;

/* -----------------------------------------------
 * Print node
 */
static gboolean printNode(CDOMnode *node, gpointer data)
{
  gboolean retFlag = 0;
  
  gint indent,i;

  gchar blanks[128];
  gchar buf[82];
  
  CDOMattr *attr;
  TlogData *logData = (TlogData*)data;
  
  // The indent
  indent = cdom_node_depth(node) - 1;
  if (indent > 100) indent = 100;
  for(i = 0; i < indent; i++) blanks[i] = ' ';
  blanks[i] = 0;
  
  // The node
  VDlogPrintFmt(logData->type,logData->stdoutFlag,
		"%s%s",blanks,
		node->name->str);
  
  // Any attributes
  for(attr= node->attrs; attr; attr = attr->next) {

    // Guard against long strings
    if (strlen(attr->txt->str) < 80) strcpy(buf,attr->txt->str);
    else {
      memcpy(buf,attr->txt->str,80);
      *(buf+80) = 0;
    }
    
    VDlogPrintFmt(logData->type,logData->stdoutFlag,
		  "%s %s = %s",blanks,
		  attr->name->str,buf);
  }

 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Print a tree using the logging functions
 */
void VDcdomPrintTree(IGRint type, IGRint stdoutFlag, TGRid *treeID)
{
  CDOMnode *tree;
  TlogData logData;
  
  // get the node
  tree = cdom_nodeid_get_node(treeID);
  if (tree == NULL) goto wrapup;

  // Log info
  logData.type = type;
  logData.stdoutFlag = stdoutFlag;
  
  // Do it
  cdom_node_traverse(tree,G_PRE_ORDER,G_TRAVERSE_ALL,-1,printNode,&logData);

 wrapup:
  return;
  
}

/* -----------------------------------------------
 * Create a new cdom node
 * Append to optional parent
 *
 * Note that is really no need for the calling program to check if the node
 * was actually created, the program will abort with g_assert if creation fails
 */
void VDcdomCreateNode(TGRid *parentID, IGRchar *eleName, TGRid *nodeID)
{
  VDASSERT_FN("VDcdomCreateNode");
  
  CDOMnode *node;
  CDOMnode *parent;
  
  // Arg check
  VDASSERTW(nodeID); nodeID->objid = NULL_OBJID;
  VDASSERTW(eleName && *eleName);
  
  // Make the node
  node = cdom_node_new(eleName);
  VDASSERTW(node);
  cdom_nodeid_set_node(nodeID,node);

  // Have a parent
  if (parentID == NULL) goto wrapup;
  parent = cdom_nodeid_get_node(parentID);
  VDASSERTW(parent);  
  cdom_node_append(parent,node);
    
  // Done
 wrapup:
  return;
}

/* -----------------------------------------------
 * Delete a node and all it's children
 */
void VDcdomDeleteNode(TGRid *nodeID)
{
  CDOMnode *node;
  
  // Ok not to have one
  node = cdom_nodeid_get_node(nodeID);
  if (node == NULL) goto wrapup;
  
  // This should do it
  cdom_node_destroy(node);
  
 wrapup:
  return;
}

