/* $Id: VDxmlDom.C,v 1.4 2001/10/18 20:29:33 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vds/vdxml/VDxmlDom.C
 *
 * Description: Basic xml dom/tree functions
 *
 * Dependencies: 
 *
 * Revision History:
 *      $Log: VDxmlDom.C,v $
 *      Revision 1.4  2001/10/18 20:29:33  ahundiak
 *      ah
 *
 *      Revision 1.3  2001/02/20 15:19:40  ahundiak
 *      *** empty log message ***
 *
 *      Revision 1.2  2001/01/11 21:30:18  art
 *      sp merge
 *
 * Revision 1.1  2000/04/25  16:20:48  pinnacle
 * ah
 *
 * Revision 1.1  2000/02/18  16:26:44  pinnacle
 * sms
 *
 * Revision 1.1  2000/01/26  15:36:20  pinnacle
 * ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 01/26/99  ah      Changed to .C for stand alone programs
 * 02/19/01  ah      These are obsolete, use the VDxdom stuff
 ***************************************************************************/

#include "VDtypedef.h"
#include "VDxml.h"

static int traceFlag;
#if 0
/* -------------------------------------------------------
 * Recursive routine to free a tree
 *
 * Warning: Use only for complete trees.  Given a root node with no
 * siblings this will free it.
 *
 * However, trying to free a node in the middle of the tree
 * with links to the parent node and siblings will fail.
 */
IGRstat VDxmlDomFreeTree(TVDxmlEle *nodeEle)
{
  IGRstat retFlag = 1;

  TVDxmlAtr *nodeAtr, *nextAtr;
  TVDxmlEle *childEle,*nextEle;
  
  // Arg check
  if (nodeEle == NULL) goto wrapup;
  
  // Free attributes
  nodeAtr = nodeEle->atrs;
  while(nodeAtr) {
    nextAtr = nodeAtr->next;
    free(nodeAtr);
    nodeAtr = nextAtr;
  }
  
  // Free the kids
  childEle = nodeEle->children;
  while(childEle) {
    nextEle = childEle->sibling;
    VDxmlDomFreeTree(childEle);
    childEle = nextEle;
  }
  
  // Free myseld
  free(nodeEle);
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* -------------------------------------------------------
 * Recursive routine to print a tree
 */
IGRstat VDxmlDomPrintNode(TVDxmlEle *nodeEle, 
			  IGRint     printKids, 
			  IGRint    *a_indent, 
			  FILE      *a_file)
{
  IGRstat   retFlag = 1;
  IGRint    i,indent;
  TVDxmlEle *childEle;
  TVDxmlAtr *nodeAtr;
  
  FILE *file;
  
  // Arg check
  if (nodeEle == NULL) goto wrapup;
  if (a_indent) indent = *a_indent;
  else          indent = 0;
  if (a_file)   file = a_file;
  else          file = stdout;

  // Tab over and print name
  for(i = 0; i < indent; i++) fputc(' ',file);
  indent++;
  
  fprintf(file,"ELE %s\n",nodeEle->type);

  // Do the attributes
  nodeAtr = nodeEle->atrs;
  while(nodeAtr) {
    for(i = 0; i < indent; i++) fputc(' ',file);
    fprintf(file,"ATR %s = \"%s\"\n",nodeAtr->type,nodeAtr->value);
    nodeAtr = nodeAtr->next;
  }
  
  // Recurse?
  if ((!printKids & 1)) {
    retFlag = 1;
    goto wrapup;
  }
  
  // Do each child
  for(childEle = nodeEle->children;childEle; childEle = childEle->sibling) {
    VDxmlDomPrintNode(childEle,printKids,&indent,file);
  }

  // Done
  retFlag = 1;

wrapup:
  return retFlag;
}

/* ----------------------------------------------
 * Append attribute
 */
IGRstat VDxmlDomAppendAttribute(TVDxmlEle *nodeEle, TVDxmlAtr *newAtr)
{
  IGRstat retFlag = 0;
  TVDxmlAtr *nextAtr;
  TVDxmlAtr *sibAtr;
  
  // Arg check
  if (newAtr == NULL) goto wrapup;
  newAtr->parent = nodeEle;
  newAtr->next = NULL;
  if (nodeEle == NULL) goto wrapup;
  
  // See if first
  sibAtr = nodeEle->atrs;
  if (sibAtr == NULL) {
    nodeEle->atrs = newAtr;
    retFlag = 1;
    goto wrapup;
  }
  // Find the last
  nextAtr = sibAtr->next;
  while(nextAtr) {
    sibAtr  = nextAtr;
    nextAtr = sibAtr->next;
  }
  sibAtr->next = newAtr;
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* ----------------------------------------------
 * Append child element
 */
IGRstat VDxmlDomAppendChildNode(TVDxmlEle *parentEle, TVDxmlEle *childEle)
{
  IGRstat    retFlag = 0;
  TVDxmlEle *sibEle;
  TVDxmlEle *nextEle;
  
  // Arg check
  if (childEle  == NULL) goto wrapup;
  childEle->sibling = NULL;
  childEle->parent  = parentEle;
  if (parentEle == NULL) goto wrapup;
  
  // Check for first one
  sibEle = parentEle->children;
  if (sibEle == NULL) {
    parentEle->children = childEle;
    retFlag = 1;
    goto wrapup;
  }
  // Get the last sibling of the children
  nextEle = sibEle->sibling;
  while(nextEle) {
    sibEle  = nextEle;
    nextEle = sibEle->sibling;
  }
  sibEle->sibling = childEle;

  // Done
  retFlag == 1;
  
wrapup:
  return retFlag;
}
#endif
