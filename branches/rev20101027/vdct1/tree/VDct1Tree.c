 /* $Id: VDct1Tree.c,v 1.6 2001/05/25 14:56:51 jdsauby Exp $  */
/***************************************************************************
 * I/VDS
 *
 * File:        vdct1/tree/VDct1Tree.c
 *
 * Description: Tree Customization
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDct1Tree.c,v $
 *      Revision 1.6  2001/05/25 14:56:51  jdsauby
 *      ETL 2235, Add HVAC tree to OTM
 *
 *      Revision 1.5  2001/04/30 12:27:50  jdsauby
 *      CR 5097, Cable crash when cable is bad, plus get rid of "No GetBaseInfo errors"  - jds
 *
 *      Revision 1.4  2001/03/11 18:37:01  ahundiak
 *      ah
 *
 *      Revision 1.3  2001/02/17 14:48:13  ahundiak
 *      *** empty log message ***
 *
 *      Revision 1.2  2001/01/14 16:29:17  art
 *      sp merge
 *
 *      Revision 1.1  2001/01/12 15:14:11  art
 *      sp merge
 *
 * Revision 1.1  2000/12/08  15:49:42  pinnacle
 * ah
 *
 * Revision 1.7  2000/11/16  20:14:40  pinnacle
 * pn
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 07/10/00  ah      Creation
 * 03/11/01  ah      Moved init stuff to VDct1Init.c
 ***************************************************************************/

#include "VDtypedefc.h"
#include "VDct1.h"
#include "VDct1Tree.h"
#include "VDassert.h"
#include "VDctx.h"

#if 0
static TVDct1RootTreeClass     rootTree;
static TVDct1PlotTreeClass     plotTree;

static TVDct1ProdTreeClass     prodTree;
static TVDct1StdPartsTreeClass stdPartsTree;
static TVDct1StdAssysTreeClass stdAssysTree;
static TVDct1PalAssysTreeClass palAssysTree;

static TVDct1EngTreeClass      engTree;
static TVDct1OutfitTreeClass   outfitTree;
static TVDct1CableTreeClass    cableTree;
static TVDct1WWayTreeClass     wwayTree;
static TVDct1HvacTreeClass     hvacTree;

static initFlag;
#endif

VDASSERT_FFN("vdct1/tree/VDct1Tree.c");

/* -----------------------------------------------
 * "Macro" Interface Access
 */
// Make typecasting class pointer easier
TVDct1RootTreeClass *_RTCJD(TVDct1JD *objJD) 
{ 
  VDASSERT_FN("_RTCJD");
  TVDct1RootTreeClass *cl   = NULL;

  VDASSERTW(objJD); cl = objJD->cl;
  VDASSERTW(cl);

 wrapup:
  return cl; 
}

// Base Interface
TVDct1BaseInterface *_RTCJDB(TVDct1JD *objJD) {

  VDASSERT_FN("_RTCJDB");
  TVDct1RootTreeClass *cl   = NULL;
  TVDct1BaseInterface *base = NULL;
  
  VDASSERTW(objJD); cl = objJD->cl;
  VDASSERTW(cl);    base = &cl->base;
  
 wrapup:
  return base;
}

// Command Interface
TVDct1CmdInterface *_RTCJDC(TVDct1JD *objJD) {

  VDASSERT_FN("_RTCJDC");
  TVDct1RootTreeClass *cl  = NULL;
  TVDct1CmdInterface  *cmd = NULL;
  
  VDASSERTW(objJD); cl = objJD->cl;
  VDASSERTW(cl);    cmd = &cl->cmd;
  
 wrapup:
  return cmd;
}

// XML Interface
TVDct1XmlInterface *_RTCJDX(TVDct1JD *objJD) {

  VDASSERT_FN("_RTCJDX");
  TVDct1RootTreeClass *cl  = NULL;
  TVDct1XmlInterface  *xml = NULL;
  
  VDASSERTW(objJD); cl = objJD->cl;
  VDASSERTW(cl);    xml = &cl->xml;
  
 wrapup:
  return xml;
}

// Production Interface
TVDct1ProdInterface *_PTCJDP(TVDct1JD *objJD) {

  VDASSERT_FN("_PTCJDP");
  TVDct1ProdTreeClass *cl   = NULL;
  TVDct1ProdInterface *prod = NULL;
  
  VDASSERTW(objJD); cl = objJD->cl;
  VDASSERTW(cl);    prod = &cl->prod;
  
 wrapup:
  return prod;
}

// Engineering Interface
TVDct1EngInterface *_ETCJDE(TVDct1JD *objJD) {

  VDASSERT_FN("_ETCJDE");
  TVDct1EngTreeClass *cl  = NULL;
  TVDct1EngInterface *eng = NULL;
  
  VDASSERTW(objJD); cl = objJD->cl;
  VDASSERTW(cl);    eng = &cl->eng;
  
 wrapup:
  return eng;
}

// Name of the class is handy for debugging
IGRchar *_RTCJDBC(TVDct1JD *objJD) {

  VDASSERT_FN("_RTCJDBC");
  TVDct1RootTreeClass *cl = NULL;
  IGRchar        *setType = NULL;
  
  VDASSERTW(objJD); cl = objJD->cl;
  VDASSERTW(cl);    setType = cl->base.info.type;
  
 wrapup:
  return setType;
}

/* -----------------------------------------------
 * Get the tree for the node
 */
void *VDct1GetTreeClassForNode(TGRid *nodeID)
{
  VDASSERT_FN("VDct1GetTreeClassForNode");
  
  TVDctxBaseInfo baseInfo;
  IGRstat        sts;
  
  // Arg check
  VDASSERTW(nodeID);

  // can be called with a NULL_OBJID
  if (nodeID->objid == NULL_OBJID) goto wrapup;

  // Make sure the node is a tree node
  sts = VDobjIsAncestryValid(NULL,nodeID,0,"VDct1Base");
  if (!(sts & 1)) {
      // check for an old tree
      sts = VDobjIsAncestryValid(NULL,nodeID,0,"VDctBase");
      if (!(sts & 1)) goto wrapup;
  }

  // Get the set type
  VDctxGetBaseInfo(nodeID,&baseInfo);  
  if (*baseInfo.setType == 0) goto wrapup;
  
  // Use the other one
  return VDct1GetTreeClassForSetType(baseInfo.setType);
  
 wrapup:
  return NULL;
}

/* -----------------------------------------------
 * Gets the parent class of the indicated type
 */
void *VDct1GetParentTreeClassForSetType(IGRchar *setType)
{
  VDASSERT_FN("VDct1GetParentTreeClassForSetType");
  
  TVDct1JD setJD;
  TVDct1JD parentJD;

  parentJD.cl = NULL;
  
  setJD.cl = VDct1GetTreeClassForSetType(setType);
  VDASSERTW(setJD.cl);
  
  parentJD.cl = _RTCJDB(&setJD)->parentCL;
  VDASSERTW(parentJD.cl);

wrapup:
  
  return parentJD.cl;
}

#if 0
IGRstat VDct1TestAssertMgr();

/* -----------------------------------------------
 * Testing interface
 */
IGRstat VDct1TestTreeClassMgr()
{
  IGRstat retFlag = 0;
  TVDct1JD testJD;
  
  // Init
  // VDct1InitTreeClassMgr();
  
  // Test
  testJD.cl = &plotTree;

  _RTCJDB(&testJD)->hello(&testJD);
  
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Make sure asserts work the way I want them to
 */
IGRstat VDct1TestAssert(TVDct1JD *nodeJD)
{
  VDASSERT_FN("VDct1TestAssert");
  
  VDASSERTW((nodeJD) && (nodeJD->cl) && (nodeJD->id.objid != NULL_OBJID));
  
 wrapup:
  return 1;
}
IGRstat VDct1TestAssertMgr()
{
  TVDct1JD nodeJD;
  
  printf("---- Assert due to null\n");
  VDct1TestAssert(NULL);
  printf("---- Assert due to null class\n");
  memset(&nodeJD,0,sizeof(TVDct1JD));
  VDct1TestAssert(&nodeJD);
  printf("---- Assert due to NULL_OBJID\n");
  nodeJD.cl = VDct1GetRootTreeClass();
  nodeJD.id.objid = NULL_OBJID;
  VDct1TestAssert(&nodeJD);
  printf("---- Assert NONE\n");
  nodeJD.id.objid = 1;
  VDct1TestAssert(&nodeJD);
  printf("---- Assert Test Complete\n");
 
  return 1;
}
#endif






