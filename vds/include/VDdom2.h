/***************************************************************************
 * I/VDS
 *
 * File:        vds/include/VDdom2.h
 *
 * Description: Simple DOM Interface
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDdom2.h,v $
 *      Revision 1.1  2004/03/29 16:23:59  ahundiak
 *      ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 04/17/03  ah      Creation (Originally in AIM)
 ***************************************************************************/
#ifndef VDDOM2_H
#define VDDOM2_H

#ifndef DOM_C
typedef char *domNode;
#endif

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ----------------------------------------------
 * Document creation and destruction
 */
extern domNode domCreateDoc __((char *rootNodeName));

extern domNode domCreateDocFromFile __((char *fileName));

extern void domFreeDoc __((domNode rootNode));

extern void domFreeValue __((char *value));

extern void domSaveDocToFile __((domNode rootNode, char *fileName));
extern void domSaveDocToBuf  __((domNode rootNode, char **buf));

extern void domSuppressErrors __(());

/* --------------------------------------------------------
 * Basic node/prop routines
 */
extern domNode 
domCreateNode __((domNode parentNode, char *name));

extern domNode 
domCreateNodeWithContent __((domNode parentNode, char *name, char *content));

extern char *domGetNodeName __((domNode));

extern char *domGetNodeContent __((domNode node, char *value));
extern void  domSetNodeContent __((domNode node, char *value));

extern domNode domHasNodeProp     __((domNode node, char *name));
extern domNode domHasNodePropDesc __((domNode node, char *name));

extern char *domGetNodeProp __((domNode node, char *name, char *value));
extern void  domSetNodeProp __((domNode node, char *name, char *value));

extern void  
domSetNodeTextProp __((domNode node, char *name, char *value));

extern void  
domSetNodeIntProp  __((domNode node, char *name, int value));

extern char *
domGetNodePropDesc __((domNode node, char *name, char *value));

extern char *
domGetNodeNthPropName __((domNode node, int nth, char *name));

extern int domIsNode     __((domNode node));
extern int domIsNodeName __((domNode node, char *name));

/* ----------------------------------------------
 * To make searching a bit easier
 */
extern domNode domGetNthChildNode           
  __((domNode parentNode, int nth));

extern domNode domGetNthChildNodeForName    
  __((domNode parentNode, char *name, int nth));

extern char *domGetNthChildContentForName 
  __((domNode parentNode, char *name, int nth, char *value));

extern int domGetChildCountForName      
  __((domNode parentNode, char *name));

extern domNode domGetParentNode 
  __((domNode node, char *name)); /* Name is optional */

/* ----------------------------------------------
 * Attr Node Routines
 */
extern domNode domCreateTextAttrNode
  __((domNode parentNode, char *name, char *value));

extern domNode domCreateIntAttrNode
  __((domNode parentNode, char *name, int   value));

extern domNode domGetAttrNode
  __((domNode parentNode, char *name));

extern char *domGetAttrNodeValue
  __((domNode attrNode, char *value));

extern char *domGetAttrNodeName
  __((domNode attrNode, char *name));

extern char *domSetAttrNodeValue
  __((domNode attrNode, char *value));

extern char *domSetAttrNodeName
  __((domNode attrNode, char *name));


extern char *domGetTextAttrNodeValue
  __((domNode parentNode, char *name, char *value));

extern char *domSetTextAttrNodeValue
  __((domNode parentNode, char *name, char *value));


extern int domGetIntAttrNodeValue
  __((domNode parentNode, char *name, int  *value));

extern int domSetIntAttrNodeValue
  __((domNode parentNode, char *name, int   value));



/* ----------------------------------------------
 * Cleanup
 */
#if defined(__cplusplus)
}
#endif
#endif
