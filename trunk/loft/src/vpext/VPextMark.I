
class implementation VDbtBase;

#include "VDtypedef.h"
#include "VDobj.h"
#include "VDchn.h"
#include "VDmem.h"
#include "VDsa.h"
#include "VDgeom.h"

#include "VPextInfo.h"
#include "VPpdf.h"

#include "vs.h"
#include "vsdef.h"
#include "vsplatedef.h"
#include "vsmiscmacros.h"

#include "vlmark.h"

#include "bscvmidpt.h"

from ACrg_collect import ACshow_data;
from ACrg_collect import AClist_attribute;
from ACrg_collect import ACget_named_attribute;

from GRcurve      import GRendpts;
from GRvg         import GRdetplane;

extern GRclassid OPP_GR3dlinestr_class_id;

static int traceFlag;

/* -----------------------------------------------
 * Dump the collectors of a marking line
 */
IGRstar VPextDumpMarkingLine(TGRobj_env *markOE)
{
  IGRstat msg;
  
  TGRid colID;

  printf("============================\n");
  vdobj$Print(objOE = markOE);
  
  // Get the collector 
  vdchn$Get(il_objID  = &markOE->obj_id,
	    ic_IDX    = VDCHN_IDX_PARENT,
	    ir_objIDX = 0,
	    or_objID  = &colID );

  om$send(msg = message ACrg_collect.ACshow_data(&msg),
	  senderid = NULL_OBJID,
	  targetid = colID.objid,
	  targetos = colID.osnum);

  // Get the collector 
  vdchn$Get(il_objID  = &markOE->obj_id,
	    ic_IDX    = VDCHN_IDX_TO_COMPONENTS,
	    ir_objIDX = 1,
	    or_objID  = &colID );

  om$send(msg = message ACrg_collect.ACshow_data(&msg),
	  senderid = NULL_OBJID,
	  targetid = colID.objid,
	  targetos = colID.osnum);

  return 1;
}

/* ------------------------------------------------
 * Get the normal vector of the plate surface
 */
IGRstat VPextGetPlateNormal(TGRobj_env *plateOE, IGRdouble *srfNormal)
{
  IGRstat retFlag = 0;
  IGRstat sts,msg;

  TGRplane   srfPlane;
  TGRobj_env srfOE;
  IGRdouble  srfPoint[3];

  // Arg check
  if (srfNormal == NULL) goto wrapup;
  if (plateOE   == NULL) goto wrapup;

  // Get its base surface
  vdobj$GetFoot(objOE    =  plateOE, 
		footName =  VS_K_plBotSfPath, 
		footOE   = &srfOE);

  // vdobj$Print(objOE = srfOE);
  if (srfOE.obj_id.objid == NULL_OBJID) goto wrapup;
  
  // For planar plates, get surface normal and point
  srfPlane.point  = srfPoint;
  srfPlane.normal = srfNormal;
  
  sts = om$send(msg = message GRvg. 
		GRdetplane(&msg,
			   &srfOE.mod_env.md_env.matrix_type,
			    srfOE.mod_env.md_env.matrix,
			   &srfPlane),
		senderid = NULL_OBJID,
		targetid = srfOE.obj_id.objid,
		targetos = srfOE.obj_id.osnum);

  if (!(sts & msg & 1)) {
    printf("Marking Plate surface is not planar\n");
    goto wrapup;
  }

  retFlag = 1;

wrapup:
  return retFlag;
}

/* -----------------------------------------------------
 * Gets a single possible marking line
 */
IGRstar VPextGetPlateMarkLine(TVPextPlateInfo *plateInfo,
                              TGRobj_env      *plateOE, 
 			      TGRid           *markID)
{
  IGRstat retFlag = 0;
  IGRstat msg,sts;
  
  TGRid parentID;
  TGRid colID;
  
  TGRobj_env markOE;
  TGRobj_env footOE;
  TGRobj_env parentOE;
  TGRobj_env parentOEx;
  
  TGRbsp_curve *crv = NULL;

  IGRdouble     dirNormal[3];
  IGRdouble     dirPt[3];
  IGRdouble     dirPar;
  IGRdouble     dirDistance;
  
  IGRchar buf[128];
  
  IGRint     numAtt;
  TACrg_coll lstAtts[2];
  
  IGRint material = 0;
  IGRint i;
  BSrc   rc;
  
  // Say hi
  // vdobj$Print(objID = bevelID);
  if (plateInfo);

  /* --------------------------------------------------------
   * Verify plate is the actual main parent and not connected
   * somehow as the second parent
   * Somtimes, they are out to get you
   */
  vdobj$GetParent(objID = markID, idx = 1, parentID = &parentID);
  if (parentID.objid == NULL_OBJID) goto wrapup;
  if (parentID.objid != plateOE->obj_id.objid) goto wrapup;
  if (parentID.osnum != plateOE->obj_id.osnum) goto wrapup;

  // No way of knowing matrix for sure, assume it's the same as the plate
  markOE.mod_env =  plateOE->mod_env;
  markOE.obj_id  = *markID;
  
  markOE.mod_env.md_id.osnum = markID->osnum;
  ex$get_modid(mod_osnum =  markID->osnum, 
	       mod_id    = &markOE.mod_env.md_id.objid);

  // Get it's graphic foot, for now just assume one line
  vdobj$GetFoot(objOE    = &markOE,
		footName =  VLFullLineName,
		footOE   = &footOE);

  if (footOE.obj_id.objid == NULL_OBJID) goto wrapup;

  // Verify foot is a linestr
  sts = vdobj$IsAncestryValid(objOE = &footOE, superClassID = OPP_GR3dlinestr_class_id);
  if (!(sts & 1)) {    
    vdobj$Print(objOE = &markOE);
    vdobj$Print(objOE = &footOE);
  }
  vdgeom$Get2(objOE = &footOE, crv = &crv);
  
  // Get second parent
  vdobj$GetParent(objID = markID, idx = 2, parentID = &parentID);
  if (parentID.objid == NULL_OBJID) goto wrapup;
  VDahGetObjectEnv(&parentID,&parentOE);

  VDatGetConsumingChild(&parentOE,&parentOEx);  // Just in case it's been processed

  // Get the collector info
  vdchn$Get2(objID  = &markOE.obj_id,
	     chnIDx = VDCHN_IDX_PARENT,
	     nth    = 0,
	     outID  = &colID );

  sts = om$send(msg = message 
		ACrg_collect.AClist_attribute(&msg,
					      2,
					      lstAtts,
					      &numAtt),
		senderid = NULL_OBJID,
		targetid = colID.objid,
		targetos = colID.osnum);

  // Setup material side
  if (plateInfo->presentOffset) {
    material = 1;
    if (lstAtts[0].desc.value.att_exp > .5) material = 0;
  }
  else {
    material = 0;
    if (lstAtts[0].desc.value.att_exp > .5) material = 1;
  }

  // Now make a direction point
  BScvmidpt(crv,&dirPar,dirPt,&rc);
  VPextGetPlateNormal(&parentOE,dirNormal);
  vdsa$GetStruct(objOE = &parentOE, name = "plate_thk", dbl = &dirDistance);

#if 0
  printf("dirNormal %10.2f %10.2f %10.2f\n",
          dirNormal[0],dirNormal[1],dirNormal[2]);

  printf("dirPt     %10.2f %10.2f %10.2f\n",
          dirPt[0],dirPt[1],dirPt[2]);
#endif

  for(i = 0; i < 3; i++) {
    dirPt[i] += (dirDistance * dirNormal[i]);
  }

#if 0
  printf("dirPt     %10.2f %10.2f %10.2f\n",
          dirPt[0],dirPt[1],dirPt[2]);
#endif
  //VPextDumpMarkingLine(&markOE);
  
#if 0  
  printf("--------------  MARK  ----------------------\n");
  vdobj$Print(objOE = &markOE);
  vdobj$Print(objOE =  plateOE);
  vdobj$Print(objOE = &parentOEx);
#endif

  // Dump it
  VPpdfWriteObjBeg(PDF_OBJ_MARKING_LINE);

  strcpy(buf,"UNKNOWN");
  sts = vdobj$IsAncestryValid(objOE = &parentOEx, superClassName = "VSplate");
  if (sts & 1) strcpy(buf,"PLATE");
  sts = vdobj$IsAncestryValid(objOE = &parentOEx, superClassName = "VSbeam");
  if (sts & 1) strcpy(buf,"BEAM");
  
  VPpdfWriteAttrText(PDF_ATR_MARKING_LINE_TYPE,buf);
  
  vdsa$GetStruct(objOE = &parentOEx, name = "SA_AST:StagingTree:0:node_name", txt = buf);
  VPpdfWriteAttrText(PDF_ATR_TREE_NODE_NAME,buf);

  vdsa$GetStruct(objOE = &parentOEx, name = "SA_AST:StagingTree:0:pcmk", txt = buf);
  VPpdfWriteAttrText(PDF_ATR_TREE_NODE_PCMK,buf);

  VPpdfWriteAttrInt(PDF_ATR_MARKING_LINE_MTL_SURFACE,material);

  VPpdfWriteBspCurve3D(PDF_ATR_MARKING_LINE_CURVE,      crv);
  VPpdfWrite3dPt      (PDF_ATR_MARKING_LINE_MTL_POINT,1,dirPt);
  
  VPpdfWriteObjEnd(PDF_OBJ_MARKING_LINE);
  
  // Just make sure it only has one real line
  vdobj$GetFoot(objOE    = &markOE,
		footName = VLSecondMrkName,
		footOE   = &footOE);

  if (footOE.obj_id.objid != NULL_OBJID) {
#if 0
    printf("############################### SECOND FOOT ############################\n");
    vdobj$Print(objOE = &footOE);
#endif
  }

  // Done
  retFlag = 1;

wrapup:

  _FREE(crv);
  return retFlag;
}

/* -----------------------------------------------------
 * Given a tree of plates, find all bevels
 * Call them bevels to avoid confusing with edges
 */
IGRstar VPextGetPlateMarkLines(TVPextPlateInfo *plateInfo)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  
  IGRint i,j;

  TVPextPlates *plates = &plateInfo->plates;
  TGRobj_env plateOE;

  TVDvlaID markVLA;
  TGRid    markID;
  
  // Init
  traceFlag = 0;
  vdvla_id$Construct(vla = &markVLA);
  
  // Process each plate in tree
  for(i = 0; i < plates->cnt; i++) {

    plateOE = plates->plateOEs[i];

    vdvla_id$Empty(vla = &markVLA);

    vdchn$GetChildrenByClass(objOE     = &plateOE,
                             className = "VLmrkLine",
                             vla       = &markVLA);

    for(j = 0; 
        vdvla_id$GetAt(vla = &markVLA, nth = j, objID = &markID); 
        j++) {

      sts = VPextGetPlateMarkLine(plateInfo,&plateOE,&markID);

    }
  }

  retFlag = 1;

  return retFlag;
}

end implementation VDbtBase;




