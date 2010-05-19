/* $Id: VDdomAtr.c,v 1.4 2001/03/11 18:35:11 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vds/vdxml/VDdomAtr.c
 *
 * Description: Low Level Attribute Processing
 *
 * Dependencies: 
 *
 * Revision History:
 *      $Log: VDdomAtr.c,v $
 *      Revision 1.4  2001/03/11 18:35:11  ahundiak
 *      ah
 *
 *      Revision 1.3  2001/02/17 14:39:59  ahundiak
 *      *** empty log message ***
 *
 *      Revision 1.2  2001/02/09 22:29:25  ahundiak
 *      ah
 *
 *      Revision 1.1  2001/01/11 19:28:37  art
 *      sp merge
 *
 * Revision 1.1  2000/12/06  15:01:08  pinnacle
 * ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 08/01/00  ah      Creation
 * 03/11/01  ah      Use VDgbl 
 ***************************************************************************/

#include "VDtypedefc.h"
#include "VDgbl.h"
#include "VDdom.h"

#include "VDassert.h"

VDASSERT_FFN("vds/vddom/VDdomAtr.c");

/* -------------------------------------------------------
 * Release a single attribute
 * Just adds it to the list for later reuse
 */
void VDdomFreeAtr(TVDdomAtr *atr)
{
  TVDdomStaticData *s = vdGblStaticData01;

  if (atr == NULL) return;
  memset(atr,0,sizeof(atr));
  atr->parent = s->atr_list;
  s->atr_list = atr;
}

/* -------------------------------------------------------
 * This actually frees the attributes from the list
 *
 * Usually called right before the program shuts down
 * It includes a check to see if all allocted items
 * are attached to the free list
 */
IGRstat VDdomFreeAtrList()
{
  VDASSERT_FN("VDdomFreeAtrList");
  IGRstat retFlag = 0;

  TVDdomAtr *atr1,*atr2;
  IGRint     cnt;
  IGRint     atr_cnt;

  TVDdomStaticData *s = vdGblStaticData01;

  // Say Hi
  traceFlag = VDdomGetTraceFlag();
  if (traceFlag) printf(">>> %s\n",fn);

  // Cycle through attributes
  cnt = 0;
  atr1 = s->atr_list;
  while(atr1) {
    cnt++;
    atr2 = atr1->parent;
    free(atr1);
    atr1 = atr2;
  }

  // Check the count
  atr_cnt = s->atr_cnt;
  if (cnt != atr_cnt) {
    printf("*** DOM Attribute Count Mismatch %6d %6d\n",atr_cnt,cnt);
  }

  // Reset
  s->atr_list = NULL;
  s->atr_cnt  = 0;
  
  // Done
  retFlag = 1;
  
 wrapup:

  // Say Bi
  if (traceFlag) printf("<<< %s %d\n",fn,retFlag);

  return retFlag;
}

/* -------------------------------------------------------
 * Create an attribute using the list stuff
 */
IGRstat VDdomCreateAtr(TVDdomTagType  type, 
		       TVDdomAtrValue value, 
		       TVDdomAtr    **newAtr)
{
  VDASSERT_FN("VDdomCreateAtr");
  IGRstat retFlag = 0;

  TVDdomAtr *atr = NULL;

  TVDdomStaticData *s = vdGblStaticData01;

  // Say Hi
  traceFlag = VDdomGetTraceFlag();
  if (traceFlag) printf(">>> %s\n",fn);

  // Arg check
  VDASSERTW(newAtr);
  *newAtr = NULL;
  VDASSERTW(type && *type);
  
  // Pop off stack
  atr = s->atr_list;
  if (atr) {
    s->atr_list = atr->parent;
    memset(atr,0,sizeof(TVDdomAtr));
  }
  else {
    atr = calloc(1,sizeof(TVDdomAtr));
    VDASSERTW(atr);
    s->atr_cnt++;
  }
  
  // Set the type and value
  strcpy(atr->type, type);
  if (value) strcpy(atr->value,value);
  
  // Done
  *newAtr = atr;
  retFlag = 1;
  
wrapup:

  // Say Bi
  if (traceFlag) printf("<<< %s %d\n",fn,retFlag);

  return retFlag;
}

/* -------------------------------------------------------
 * Append an attribute to the object
 */
IGRstat VDdomAppendAtr(TGRid         *nodeID, 
		       TVDdomTagType  type, 
		       TVDdomAtrValue value)
{
  VDASSERT_FN("VDdomAppendAtr");
  IGRstat retFlag = 0;

  TVDdomAtr *nodeAD,*nextAD;
  TVDdomEle *nodeDD;
  
  // Say Hi
  traceFlag = VDdomGetTraceFlag();
  if (traceFlag) printf(">>> %s\n",fn);

  // Arg check
  VDdomGetObjInstance(nodeID,&nodeDD);
  VDASSERTW(nodeDD);
  
  // Create one
  VDdomCreateAtr(type,value,&nodeAD);
  VDASSERTW(nodeAD);
  nodeAD->parent = nodeDD;
  
  // Add to attribute list
  if (nodeDD->atrs == NULL) nodeDD->atrs = nodeAD;
  else {
    for(nextAD = nodeDD->atrs; nextAD->next; nextAD = nextAD->next);
    nextAD->next = nodeAD;
  }

  // Done
  retFlag = 1;
  
wrapup:

  // Say Bi
  if (traceFlag) printf("<<< %s %d\n",fn,retFlag);

  return retFlag;
}

/* -----------------------------------------------
 * Set the value of an attribute
 * Optionally creating one if one is not found
 */
IGRstat VDdomSetTxtAtr(TGRid *nodeID, IGRint createFlag, IGRchar *type, IGRchar *value)
{
  VDASSERT_FN("VDdomGetAttributeByType");
  IGRstat retFlag = 0;

  TVDdomAtr *nodeAD;
  
  // Say Hi
  traceFlag = VDdomGetTraceFlag();
  if (traceFlag) printf(">>> %s\n",fn);

  // Arg check
  VDASSERTW(type);
  VDASSERTW(value);
  
  // Cycle through
  VDdomGetFirstAtr(nodeID,&nodeAD);
  while(nodeAD) {
    
    if (!strcmp(nodeAD->type,type)) {

      // Got it
      strcpy(nodeAD->value,value);
      retFlag = 1;
      goto wrapup;
    }
    nodeAD = nodeAD->next;
  }
  
  // Done (no match)
  if (createFlag) retFlag = VDdomAppendAtr(nodeID,type,value);

 wrapup:

  // Say Bi
  if (traceFlag) printf("<<< %s %d\n",fn,retFlag);

  return retFlag;
}

/* -----------------------------------------------
 * Get the first attribute in the list
 */
IGRstat VDdomGetFirstAtr(TGRid *nodeID, TVDdomAtr **nodeAD)
{
  VDASSERT_FN("VDdomGetNthAtr");
  IGRstat retFlag = 0;

  TVDdomEle *nodeDD;
  
  // Say Hi
  traceFlag = VDdomGetTraceFlag();
  if (traceFlag) printf(">>> %s\n",fn);

  // Arg check
  VDASSERTW(nodeAD);
  *nodeAD = NULL;

  // Instance pointer
  VDdomGetObjInstance(nodeID,&nodeDD);
  VDASSERTW(nodeDD);

  // Done
  *nodeAD = nodeDD->atrs;
  retFlag = 1;
  
wrapup:

  // Say Bi
  if (traceFlag) printf("<<< %s %d\n",fn,retFlag);

  return retFlag;
}

/* -----------------------------------------------
 * Given an attribute, get next one in list
 */
TVDdomAtr *VDdomGetNextAtr(TVDdomAtr *nodeAD)
{
  if (nodeAD) return nodeAD->next;
  return NULL;
}

/* -----------------------------------------------
 * Usual way to get attributes
 */
IGRstat VDdomGetNthAtr(TGRid *nodeID, IGRint nth, TVDdomAtr **a_nodeAD)
{
  VDASSERT_FN("VDdomGetNthAtr");
  IGRstat retFlag = 0;

  TVDdomAtr *nodeAD;
  
  // Say Hi
  traceFlag = VDdomGetTraceFlag();
  if (traceFlag) printf(">>> %s\n",fn);

  // Arg check
  VDASSERTW(a_nodeAD);
  *a_nodeAD = NULL;
  VDASSERTW(nth >= 0);
  
  // First attribute
  VDdomGetFirstAtr(nodeID,&nodeAD);
  while(nodeAD) {
    
    if (nth == 0) {
      *a_nodeAD = nodeAD;
      retFlag = 1;
      goto wrapup;
    }
    nth--;
    nodeAD = nodeAD->next;
  }
  
  // Done
wrapup:

  // Say Bi
  if (traceFlag) printf("<<< %s %d\n",fn,retFlag);

  return retFlag;
}

/* -----------------------------------------------
 * Search the attributes of an element for a 
 * particular one
 */
IGRstat VDdomGetAtrByType(TGRid *nodeID, IGRchar *type, TVDdomAtr **a_nodeAD)
{
  VDASSERT_FN("VDdomGetAttributeByType");
  IGRstat retFlag = 0;

  TVDdomAtr *nodeAD;
  
  // Say Hi
  traceFlag = VDdomGetTraceFlag();
  if (traceFlag) printf(">>> %s\n",fn);

  // Arg check
  VDASSERTW(a_nodeAD);
  *a_nodeAD = NULL;  
  VDASSERTW(type);
  
  // Cycle through
  VDdomGetFirstAtr(nodeID,&nodeAD);
  while(nodeAD) {
    
    if (!strcmp(nodeAD->type,type)) {

      // Got it
      *a_nodeAD = nodeAD;
      retFlag = 1;
      goto wrapup;
    }
    nodeAD = nodeAD->next;
  }
  
  // Done (no match)

 wrapup:

  // Say Bi
  if (traceFlag) printf("<<< %s %d\n",fn,retFlag);

  return retFlag;
}

/* -----------------------------------------------
 * Count the number of attributes
 */
IGRstat VDdomGetAtrCount(TGRid *nodeID, IGRint *atrCnt)
{
  VDASSERT_FN("VDdomGetAtrCount");
  IGRstat retFlag = 0;
  
  TVDdomAtr *nodeAD;
 
  // Say Hi
  traceFlag = VDdomGetTraceFlag();
  if (traceFlag) printf(">>> %s\n",fn);

  // Arg check
  VDASSERTW(atrCnt); 
  *atrCnt = 0;
  
  // get the first
  VDdomGetFirstAtr(nodeID,&nodeAD);
  
  // Cycle through
  while(nodeAD) {
    *atrCnt = *atrCnt + 1;
    nodeAD = nodeAD->next;
  }

  // Done
  retFlag = 1;
  
 wrapup:

  // Say Bi
  if (traceFlag) printf("<<< %s %d\n",fn,retFlag);

  return retFlag;
}


