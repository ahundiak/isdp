/* $Id: VDefpCrvLens.I,v 1.1 2001/01/11 19:04:49 art Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdefp/VDefpCrvLens.I
 *
 * Description: Curve Lengths Macro
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDefpCrvLens.I,v $
 *      Revision 1.1  2001/01/11 19:04:49  art
 *      sp merge
 *
# Revision 1.3  2000/10/16  17:21:46  pinnacle
# ah
#
# Revision 1.2  2000/06/19  18:05:52  pinnacle
# ah
#
# Revision 1.1  2000/04/28  19:39:46  pinnacle
# ah
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 04/26/00  ah      Creation
 ***************************************************************************/
class implementation Root;

#include "VDtypedef.h"
#include "VDobj.h"
#include "VDchn.h"
#include "VDexp.h"
#include "VDmem.h"
#include "VDgeom.h"
#include "VDefp.h"

#include "VDdbgProto.h"

static int traceFlag;

/* -----------------------------------------------
 * Compute
 */
IGRstat VDefpComputeCrvAxis(TGRobj_env *macOE,
			    IGRint      opFlag,
			    IGRint     *cnt,
			    TGRid      *ids)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  
  TGRobj_env    crvOE;
  TGRbsp_curve *crv = NULL;
  
  IGRpoint center;
  IGRpoint major;
  IGRpoint minor;
  TGRid    ptID;
  
  // Arg check
  if (cnt == NULL) goto wrapup;
  *cnt = 0;
  if (ids   == NULL) goto wrapup;
  if (macOE == NULL) goto wrapup;
  
  // Get 1st parent, 
  vdobj$GetTemplate(objOE      = macOE,
                    nth        = VDEFP_CRV_AXIS_PARENT_CRV,
                    templateOE = &crvOE);
  if (crvOE.obj_id.objid == NULL_OBJID) goto wrapup;
  
  // Get the geometry
  vdgeom$Get2(objOE = &crvOE, crv = &crv);
  if (crv == NULL) goto wrapup;

  // Get sym point
  VDgeomGetSymCrvAxis(crv,center,major,minor);
  
  // Make it
  VDdrawLinear(1,center,&macOE->mod_env,&ptID);
  if (ptID.objid != NULL_OBJID) {
    ids[*cnt] = ptID;
    *cnt = *cnt + 1;
  }
  VDdrawLinear(1,major,&macOE->mod_env,&ptID);
  if (ptID.objid != NULL_OBJID) {
    ids[*cnt] = ptID;
    *cnt = *cnt + 1;
  }
  VDdrawLinear(1,minor,&macOE->mod_env,&ptID);
  if (ptID.objid != NULL_OBJID) {
    ids[*cnt] = ptID;
    *cnt = *cnt + 1;
  }
    
  // Done
  retFlag = 1;
  
 wrapup:

  _FREE(crv);
  return retFlag;
}

/* -----------------------------------------------
 * Compute
 */
IGRstat VDefpComputeCrvCenter(TGRobj_env *macOE,
			      IGRint      opFlag,
			      IGRint     *cnt,
			      TGRid      *ids)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  
  TGRobj_env    crvOE;
  TGRbsp_curve *crv = NULL;
  
  IGRpoint pt;
  TGRid    ptID;
  
  // Arg check
  if (cnt == NULL) goto wrapup;
  *cnt = 0;
  if (ids   == NULL) goto wrapup;
  if (macOE == NULL) goto wrapup;
  
  // Get 1st parent, 
  vdobj$GetTemplate(objOE      = macOE,
                    nth        = VDEFP_CRV_CENTER_PARENT_CRV,
                    templateOE = &crvOE);
  if (crvOE.obj_id.objid == NULL_OBJID) goto wrapup;
  
  // Get the geometry
  vdgeom$Get2(objOE = &crvOE, crv = &crv);
  if (crv == NULL) goto wrapup;

  // Get sym point
  VDgeomGetSymCrvCenter(crv,pt);
  
  // Make it
  VDdrawLinear(1,pt,&macOE->mod_env,&ptID);
  if (ptID.objid != NULL_OBJID) {
    ids[*cnt] = ptID;
    *cnt = *cnt + 1;
  }
    
  // Done
  retFlag = 1;
  
 wrapup:

  _FREE(crv);
  return retFlag;
}

/* -----------------------------------------------
 * Compute
 */
IGRstat VDefpComputeCrvLens(TGRobj_env *macOE,
			    IGRint      opFlag,
			    IGRint     *cnt,
			    TGRid      *ids)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  
  TGRobj_env    expOE;
  TGRobj_env    crvOE;
  TGRbsp_curve *crv = NULL;
  
  TVDgeomArcLens lens;
  IGRdouble      lensBuf[512];

  IGRpoint pt;
  TGRid    ptID;

  IGRint segs = 0;
  
  IGRchar buf[32];
  
  // Init
  VDgeomInitCrvLens(&lens,lensBuf,512);
  
  // Arg check
  if (cnt == NULL) goto wrapup;
  *cnt = 0;
  if (ids   == NULL) goto wrapup;
  if (macOE == NULL) goto wrapup;
  
  // Get 1st parent, 
  vdobj$GetTemplate(objOE      = macOE,
                    nth        = VDEFP_CRV_LENS_PARENT_CRV,
                    templateOE = &crvOE);
  if (crvOE.obj_id.objid == NULL_OBJID) goto wrapup;
  
  // Get the geometry
  vdgeom$Get2(objOE = &crvOE, crv = &crv);
  if (crv == NULL) goto wrapup;
  
  // Control number of segments
  vdobj$GetTemplate(objOE      = macOE,
                    nth        = VDEFP_CRV_LENS_PARENT_EXP,
                    templateOE = &expOE);

  if (expOE.obj_id.objid != NULL_OBJID) {
    vdobj$Print(objOE = &expOE);
    vdexp$Get(objOE = &expOE, jnt = &segs);
    printf("Number segments %d\n",segs);
  }
  
  
  // Get the lengths
  vdgeom$GetArcLens(crv = crv, numSegs = segs, lens = &lens);
  if (lens.cnt >= VDEFP_CRV_LENS_FOOT_MAX) {
    lens.cnt = VDEFP_CRV_LENS_FOOT_MAX;
  }
  
  // Cycle through
  for(lens.i = 0; lens.i < lens.cnt; lens.i++) {

    printf("Len %2d %8.2f\n",lens.i,lens.lens[lens.i]);
    
    // Get the point
    vdgeom$GetCrvArcParPt(crv = crv,
			  len = lens.lens[lens.i],
			  pt  = pt);
    
    // Make it
    VDdrawLinear(1,pt,&macOE->mod_env,&ptID);
    if (ptID.objid != NULL_OBJID) {
      ids[*cnt] = ptID;
      *cnt = *cnt + 1;
    }
  }
    
  // Done
  retFlag = 1;
  
 wrapup:

  _FREE(crv);
  VDgeomFreeCrvLens(&lens);
  return retFlag;
  
}
/* -----------------------------------------------
 * Compute Knots
 */
IGRstat VDefpComputeCrvKnots(TGRobj_env *macOE,
			    IGRint      opFlag,
			    IGRint     *cnt,
			    TGRid      *ids)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  
  TGRobj_env    expOE;
  TGRobj_env    crvOE;
  TGRbsp_curve *crv = NULL;
  
  TVDgeomKnots knots;
  IGRdouble    bufKnots[512];

  IGRpoint pt;
  TGRid    ptID;

  IGRchar buf[32];
  IGRint  cntx,i;
  
  // Init
  VDgeomInitKnots(&knots,bufKnots,512);
  
  // Arg check
  if (cnt == NULL) goto wrapup;
  *cnt = 0;
  if (ids   == NULL) goto wrapup;
  if (macOE == NULL) goto wrapup;
  
  // Get 1st parent, 
  vdobj$GetTemplate(objOE      = macOE,
                    nth        = VDEFP_CRV_LENS_PARENT_CRV,
                    templateOE = &crvOE);
  if (crvOE.obj_id.objid == NULL_OBJID) goto wrapup;
  
  // Get the geometry
  vdgeom$Get2(objOE = &crvOE, crv = &crv);
  if (crv == NULL) goto wrapup;

  // Get the knots
  vdgeom$GetKnotsFromCurve(crv = crv, knots = &knots);

  // Prevent Over folws
  cntx = knots.cnt;
  if (cntx >= VDEFP_CRV_KNOTS_FOOT_MAX) {
    cntx = VDEFP_CRV_KNOTS_FOOT_MAX;
  }
  
  // Cycle through
  for(i = 0; i < cntx; i++) {

    // Get the point
    VDgeomGetCrvPt(crv,knots.knots[i],pt);
    
    // Make it
    VDdrawLinear(1,pt,&macOE->mod_env,&ptID);
    if (ptID.objid != NULL_OBJID) {
      ids[*cnt] = ptID;
      *cnt = *cnt + 1;
    }
  }
    
  // Done
  retFlag = 1;
  
 wrapup:

  _FREE(crv);
  VDgeomFreeKnots(&knots);
  return retFlag;
  
}

/* -----------------------------------------------
 * Compute an expanded curve
 */
IGRstat VDefpComputeCrvExpand(TGRobj_env *macOE,
			      IGRint      opFlag,
			      IGRint     *cnt,
			      TGRid      *ids)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  
  TGRobj_env    expOE;
  TGRobj_env    crvOE;
  TGRbsp_curve *crv = NULL;
  IGRdouble     exp = 3.0;
  
  IGRpoint center;
  TGRid    footID;
  
  TVDgeomSym sym;
  
  // Arg check
  if (cnt == NULL) goto wrapup;
  *cnt = 0;
  if (ids   == NULL) goto wrapup;
  if (macOE == NULL) goto wrapup;
  
  // Get 1st parent, 
  vdobj$GetTemplate(objOE      = macOE,
                    nth        = VDEFP_CRV_EXPAND_PARENT_CRV,
                    templateOE = &crvOE);
  if (crvOE.obj_id.objid == NULL_OBJID) goto wrapup;
  
  // Get the geometry
  vdgeom$Get2(objOE = &crvOE, crv = &crv);
  if (crv == NULL) goto wrapup;
  
  // The Expansion Factor
  vdobj$GetTemplate(objOE      = macOE,
                    nth        = VDEFP_CRV_EXPAND_PARENT_EXP,
                    templateOE = &expOE);

  if (expOE.obj_id.objid != NULL_OBJID) {
    //vdobj$Print(objOE = &expOE);
    vdexp$Get(objOE = &expOE, dbl = &exp);
    if (exp < .01) exp = 1.5;
  }
  //printf("--------------------------\n");
  //vdgeom$Print(crv = crv);

  // Make sure it's exactly closed
  VDgeomCloseCurve(crv);
  
  // Need center
  VDgeomGetSymCrvCenter(crv,center);
  
  // Expand it
  VDgeomExpandSymCrv(crv,center,exp);
  //vdgeom$Print(crv = crv);

  // Convert to parametric
  VDgeomIsCrvSym(crv,0.0,&sym);
  switch(sym.type) {

    case VDGEOM_SYM_TYPE_CIRCLE: 
      UI_status("CIRCLE");
      break;

    case VDGEOM_SYM_TYPE_ELLIPSE: 
      UI_status("ELLIPSE");
      break;

    case VDGEOM_SYM_TYPE_OVAL: 
      UI_status("OVAL");
      break;

    case VDGEOM_SYM_TYPE_NONE:
      UI_status("NOT PARAMETRIC");
      break;
  }
  
  // Make it
  /* 15 Oct 2000 - Added env */
  if (sym.bsp) VDdrawCurve(sym.bsp,&macOE->mod_env,&footID);
  else         VDdrawCurve(crv,    &macOE->mod_env,&footID);
  if (footID.objid != NULL_OBJID) {
    ids[*cnt] = footID;
    *cnt = *cnt + 1;
  }
    
  // Done
  retFlag = 1;
  
 wrapup:

  _FREE(crv);

  return retFlag;
  
}

end implementation Root;


