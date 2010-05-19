/* $Id: VDdomOM.c,v 1.4 2001/03/11 18:35:11 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vds/vddom/VDdom2.c
 *
 * Description: Basic dom/om functions
 *
 * Dependencies: 
 *
 * Revision History:
 *      $Log: VDdomOM.c,v $
 *      Revision 1.4  2001/03/11 18:35:11  ahundiak
 *      ah
 *
 *      Revision 1.3  2001/02/09 22:29:25  ahundiak
 *      ah
 *
 *      Revision 1.2  2001/01/14 16:33:39  art
 *      sp merge
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
 * 03/11/01  ah      Use VDgbl stuff
 ***************************************************************************/

#include "VDtypedefc.h"
#include "VDgbl.h"
#include "VDdom.h"
#include "VDassert.h"

VDASSERT_FFN("vddom/VDdomOM.c");

// Default lowest os number and max number
#define VDDOM_OSNUM_BEG 9000
#define VDDOM_OSNUM_MAX   10

/* Return the master dom trace flag */
IGRint VDdomGetTraceFlag() { return traceFlagx; }

/* ------------------------------------------------------------
 * Get the sub system going by allocating the object space list
 * Make sure thats get's called during startup or problems will occur
 */
IGRstat VDdomInitSystem(IGRint flag, DOM_S_OSNUM osnum_beg, IGRint osnum_cnt)
{
  VDASSERT_FN("VDdomInitSystem");
  
  IGRstat retFlag = 0;
  IGRint i;

  TVDdomStaticData *s = vdGblStaticData01;
  
  // Say hi
  // traceFlagx = traceFlag = 1;
  if (traceFlag) printf(">>> %s\n",fn);
  
  /* -----------------------------------------------------
   * Protect against being called more than once unless
   * the flag is set
   */
  if (flag == 0) {
    if (s) {
      retFlag = 1;
      goto wrapup;
    }
  }

  /* -------------------------------------------
   * Only process for flag = 0, initial startup
   * If the static data is changed for a service pack then
   * need to do some mucking around
   */
  if (flag != 0) {
    retFlag = 1;
    goto wrapup;
  }
  
  // Allocate the global stuff
  vdGblStaticData01 = calloc(1,sizeof(TVDdomStaticData));
  if (vdGblStaticData01 == NULL) {
    printf("*** Major problem initializing dom system memory\n");
    goto wrapup;
  }
  s = vdGblStaticData01;
  s->mgrID.objid = NULL_OBJID;
  
  // Default the count to get going
  if (osnum_beg == 0) osnum_beg = VDDOM_OSNUM_BEG;
  if (osnum_cnt == 0) osnum_cnt = VDDOM_OSNUM_MAX;

  // Reset
  s->osnum_cnt = 0;
  s->osnum_act = osnum_beg;
  s->osnum_beg = osnum_beg;
  s->osnum_end = osnum_beg + osnum_cnt;
  
  // Allocate room for the list
  s->osd_list = calloc(osnum_cnt,sizeof(TVDdomOSD));
  VDASSERTW(s->osd_list);
  s->osnum_cnt = osnum_cnt;
  
  // Init
  for(i = 0; i < osnum_cnt; i++) {
    s->osd_list[i].osnum = osnum_beg + i;
    s->osd_list[i].inc   = 1000;
  }
  
  // Done
  retFlag = 1;
  
wrapup:
  // Say bi
  if (traceFlag) printf("<<< %s %d\n",fn,retFlag);
  return retFlag;
}

/* -----------------------------------------------
 * Returns the active os
 */
DOM_S_OSNUM VDdomGetActiveOsnum(DOM_S_OSNUM *osnum)
{
  TVDdomStaticData *s = vdGblStaticData01;
  if (osnum) *osnum = s->osnum_act;
  return s->osnum_act;
}


/* -------------------------------------------------------
 * Validate an osnum
 */
IGRstat VDdomIsOSValid(DOM_S_OSNUM osnum)
{
  TVDdomStaticData *s = vdGblStaticData01;

  if ((osnum < s->osnum_beg) || (osnum >= s->osnum_end)) return 0;

  return 1;
}

/* -------------------------------------------------------
 * get the osd for an osnum
 */
IGRstat VDdomGetOSD(DOM_S_OSNUM osnum, TVDdomOSD **osd)
{
  VDASSERT_FN("VDdomGetOSD");
  IGRstat retFlag = 0;

  TVDdomStaticData *s = vdGblStaticData01;

  // Say hi
  if (traceFlag) printf(">>> %s\n",fn);

  // Arg check
  VDASSERTW(osd); *osd = NULL;

  // Check the os
  if ((osnum < s->osnum_beg) || (osnum >= s->osnum_end)) goto wrapup;

  // Done
  *osd = &s->osd_list[osnum - s->osnum_beg];
  
  // Done
  retFlag = 1;
  
wrapup:

  // Say bi
  if (traceFlag) printf("<<< %s %d\n",fn,retFlag);

  return retFlag;
}

/* -------------------------------------------------------
 * Validate an objid
 * Asserts, call when expect a good object
 */
IGRstat VDdomIsIDValid(DOM_S_OSNUM osnum, DOM_S_OBJID objid)
{
  VDASSERT_FN("VDdomIsIDValid");
  
  IGRstat retFlag = 0;
  
  TVDdomOSD *osd;
  TVDdomEle *ele;
  
  // Say hi
  if (traceFlag) printf(">>> %s\n",fn);

  // Nulls are not
  if (objid == NULL_OBJID) goto wrapup;
  
  // Get ths osd
  VDdomGetOSD(osnum,&osd);
  VDASSERTW(osd);
  
  // Check the objid
  VDASSERTW(objid < osd->cnt);
  ele = osd->ele_list[objid];
  VDASSERTW(ele && *ele->type);
  
  // Done
  retFlag = 1;
  
wrapup:

  // Say bi
  if (traceFlag) printf("<<< %s %d\n",fn,retFlag);

  return retFlag;
}

/* -----------------------------------------------
 * See if it's a dom object or not
 */
IGRstat VDdomIsObjValid(TGRid *nodeID)
{
  VDASSERT_FN("VDdomIsObjValid");
  
  IGRstat retFlag = 0;
  
  TVDdomOSD *osd;
  TVDdomEle *nodeDD;
  
  // Say hi
  if (traceFlag) printf(">>> %s\n",fn);

  // Nulls are not
  VDASSERTW(nodeID);
  if (nodeID->objid == NULL_OBJID) goto wrapup;
  
  // Get ths osd
  VDdomGetOSD(nodeID->osnum,&osd);
  if (osd == NULL) goto wrapup;
  
  // Check the objid
  if (nodeID->objid >= osd->cnt) goto wrapup;
  nodeDD = osd->ele_list[nodeID->objid];
  if ( nodeDD == NULL)    goto wrapup;
  if (*nodeDD->type == 0) goto wrapup;
  
  // Done
  retFlag = 1;
  
wrapup:

  // Say bi
  if (traceFlag) printf("<<< %s %d\n",fn,retFlag);

  return retFlag;
}

/* -------------------------------------------------------
 * Given a TGRid return the actual object pointer
 */
IGRstat VDdomGetObjInstance(TGRid *nodeID, TVDdomEle **nodeDD)
{
  VDASSERT_FN("VDdomGetObjInstance");
  
  IGRstat retFlag = 0;
  IGRstat sts;
  
  TVDdomOSD *osd;
  
  // Say hi
  if (traceFlag) printf(">>> %s\n",fn);

  // Arg check
  VDASSERTW(nodeDD);
  *nodeDD = NULL;
  
  // A NULL_OBJID fails gracefully
  VDASSERTW(nodeID);
  if (nodeID->objid == NULL_OBJID) {
    if (traceFlag) printf("Failing due to NULL_OBJID\n");
    goto wrapup;
  }
  
  // Debug
  sts = VDdomIsIDValid(nodeID->osnum,nodeID->objid);
  if (!(sts & 1)) {
    printf("*** VDdomGetObjInstance %d,%d\n",nodeID->osnum,nodeID->objid);  
    VDASSERTW(0);
  }

  // Get osd
  VDdomGetOSD(nodeID->osnum,&osd);
  
  // Done
  *nodeDD = osd->ele_list[nodeID->objid];
  retFlag = 1;
  
wrapup:

  // Say bi
  if (traceFlag) printf("<<< %s %d\n",fn,retFlag);

  return retFlag;
}

/* -------------------------------------------------------
 * Get the next objid in the given os
 */
IGRstat VDdomGetNextObjid(DOM_S_OSNUM osnum, DOM_S_OBJID *objid)
{
  VDASSERT_FN("VDdomGetNextObjid");
  IGRstat retFlag = 0;

  TVDdomOSD  *osd;
  TVDdomEle **ele_list;
  TVDdomEle  *eleDD;
  
  IGRint i,j;
  
  // Say hi
  if (traceFlag) printf(">>> %s\n",fn);

  // Arg check
  VDASSERTW(objid);
  *objid = NULL_OBJID;

  // Get ths osd
  VDdomGetOSD(osnum,&osd);
  VDASSERTW(osd);
  
  // Return a free one if available
  if (osd->ele_free) {
    eleDD = osd->ele_free;
    osd->ele_free = eleDD->parent;
    eleDD->parent = NULL;
    *objid = eleDD->eleID.objid;
    retFlag = 1;
    goto wrapup;
  }
  
  // See if have one allocated but never used
  if (osd->cnt < osd->max) {
    *objid = osd->cnt;
    osd->cnt++;
    retFlag = 1;
    goto wrapup;
  }

  // Alloc room for more
  ele_list = realloc(osd->ele_list,(osd->max + osd->inc)*sizeof(TVDdomEle*));
  VDASSERTW(ele_list);
  
  // Alloc the actual object room
  for(i = 0; i < osd->inc; i++) {
   
    // Point 
    j = osd->max + i;
    
    // Grab the space
    ele_list[j] = calloc(1,sizeof(TVDdomEle));
    VDASSERTW(ele_list[j]);

    // This should stay set for ever more
    ele_list[j]->eleID.osnum = osnum;
    ele_list[j]->eleID.objid = osd->cnt + i;    
  }

  // Tidy up
  osd->ele_list = ele_list;
  osd->max += osd->inc;
  *objid = osd->cnt;
  osd->cnt++;
  
  // Done
  retFlag = 1;
  
wrapup:

  // Say bi
  if (traceFlag) printf("<<< %s %d\n",fn,retFlag);

  return retFlag;
}

/* -------------------------------------------------------
 * Recursive routine to free a tree
 *
 * Warning: Use only for complete trees.  Given a root node with no
 * siblings this will free it.
 *
 * However, trying to free a node in the middle of the tree
 * with links to the parent node and siblings will fail.
 */
IGRstat VDdomFreeTreeEle(TVDdomEle *treeDD)
{
  VDASSERT_FN("VDdomFreeTreeEle");
  IGRstat retFlag = 1;

  TVDdomAtr *nodeAD, *nextAD;
  TVDdomEle *childDD,*nextDD;

  TGRid treeID;

  TVDdomOSD *osd;
  
  // Say hi
  if (traceFlag) printf(">>> %s\n",fn);

  // Arg check
  if (treeDD == NULL) goto wrapup;
  
  // Free attributes
  nodeAD = treeDD->atrs;
  while(nodeAD) {
    nextAD = nodeAD->next;

    // Free by adding to list of free attributes
    VDdomFreeAtr(nodeAD);
    nodeAD = nextAD;
  }
  
  // Free the kids
  childDD = treeDD->children;
  while(childDD) {
    nextDD  = childDD->sibling;
    VDdomFreeTreeEle(childDD);
    childDD = nextDD;
  }

  // The only thing that survives is the objid
  treeID = treeDD->eleID;
  memset(treeDD,0,sizeof(TVDdomEle));
  treeDD->eleID = treeID;
  
  // Add to free list
  VDdomGetOSD(treeID.osnum,&osd);
  if (osd == NULL) goto wrapup;
  
  treeDD->parent = osd->ele_free;
  osd->ele_free  = treeDD;

  // printf("Free objid %2d\n",treeID.objid);
    
  // Done
  retFlag = 1;
  
wrapup:

  // Say bi
  if (traceFlag) printf("<<< %s %d\n",fn,retFlag);

  return retFlag;
}

/* -------------------------------------------------------
 * This actually frees the objects from the list
 *
 * Usually called right before the program shuts down
 * It includes a check to see if all allocted items
 * are attached to the free list
 */
IGRstat VDdomFreeObjList()
{
  VDASSERT_FN("VDdomFreeObjList");
  IGRstat retFlag = 0;

  TVDdomEle *ele1,*ele2;
  IGRint     cnt;
  
  DOM_S_OSNUM osnum;
  TVDdomOSD  *osd;

  TVDdomStaticData *s = vdGblStaticData01;
  
  // Say hi
  if (traceFlag) printf(">>> %s\n",fn);

  // Make sure initted
  if (s == NULL) goto wrapup;
  
  // Cycle through each os
  for(osnum = 0; osnum < s->osnum_cnt; osnum++) {

    osd = &s->osd_list[osnum];
    
    // Go through free list
    ele1 = osd->ele_free;
    cnt = 0;
    while(ele1) {
      ele2 = ele1->parent;
      free (ele1);
      ele1 = ele2;
      cnt++;
    }
    if (cnt != osd->cnt) {
      printf("*** DOM Element   Count Mismatch %6d %6d\n",osd->cnt,cnt);
    }
    if (osd->ele_list) free(osd->ele_list);

  }

  // Reset
  free(s->osd_list);
  s->osd_list = NULL;
  s->osnum_cnt = 0;
  
  // Done
  retFlag = 1;
  
 wrapup:

  // Say bi
  if (traceFlag) printf("<<< %s %d\n",fn,retFlag);

  return retFlag;
}

/* -----------------------------------------------
 * Free the various lists
 */
IGRstat VDdomFreeLists()
{
  VDdomFreeAtrList();
  VDdomFreeObjList();
  return 1;
}



