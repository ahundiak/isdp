/* ---------------------------------------
 * End treatment processing for production
 */
class implementation Root;

#include "VDtypedef.h"
#include "VDobj.h"
#include "VDchn.h"
#include "VDsa.h"
#include "VDvla2.h"
#include "VDmac.h"

#include "VDmem.h"
#include "VDgeom.h"
#include "VDefp.h"
#include "VSefp.h"

#include "VDdbgProto.h"

#include "vsdpb.h"
#include "vsattr.h"
#include "vsbeam.h"
#include "vsplatedef.h"
#include "vsbeamdef.h"
#include "vsoptdef.h"

#include "EMSopt.h"
#include "EMSlcdef.h"

#include "acdef.h"
#include "acmacros.h"

#include "asmacros.h"
#include "macro.h"
#include "bssfevaln.h"
#include "bsdistptpt.h"
#include "matypemx.h"
#include "maoptsxfo.h"

from EMSsubbs     import EMget_edges;
from EMSedge      import EMgetxyzobj;
from ACrg_collect import ACset_list_attribute;
from GRgencs      import GRgetmatrix;

from ci_macro     import init;

from GRvg         import GRchgdp;
from GRvg         import GRchglevel;
from GRvg         import GRgetsymb;
from GRvg         import GRputsymb;
from GRvg         import GRcenter;
from GRvg         import GRgetattr;

from GRgraphics   import GRchgname;
from GRgraphics   import GRputname;
from ACncpx       import ACmplace;
from GRconnector  import GRrigidconn;
from GRcurve      import GRendpts;

from VSbeam import VSgetSupportSf;
from VSbeam import VSgetSupportAxis;
from VSbeam import VSgetCrossSectionCS;

extern VDclassid OPP_nci_macro_class_id;
extern VDclassid OPP_ACrg_collect_class_id;

extern VDclassid OPP_VSbeam_class_id;
extern VDclassid OPP_VSbeamAxis_class_id;
extern VDclassid OPP_VSsrcBeam_class_id;
extern VDclassid OPP_VSstfBeam_class_id;
extern VDclassid OPP_VStwsBeam_class_id;
extern VDclassid OPP_VSsubBeam_class_id;
extern VDclassid OPP_VSsplBeam_class_id;
extern VDclassid OPP_VSbooBeam_class_id;

static IGRint traceFlag;

/* ------------------------------------------------------------
 * Check 1 parent of the beam to see if it is an end treatment
 */
IGRstat VSefpCheckProcessedMacro(TGRobj_env *beamOE,
				 IGRint      nth,
				 TVDvlaoe   *macVLA)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  
  TGRid      parentID;
  TGRid      macroID;
  
  TGRobj_env macroOE;
  TGRobj_env macroOEx;
  TGRobj_env cutOE;
  TGRobj_env parentOE;
  
  IGRint i;
  
  // Get the cutting object, gives env for the macro
  vdobj$GetTemplate(objOE = beamOE,
		    nth   = nth,
		    templateOE = &cutOE);

  if (cutOE.obj_id.objid == NULL_OBJID) goto wrapup;
  retFlag = 1;
  
  // Want the pretend parent
  vdchn$Get2(objOE  = beamOE,
	     chnIDx = VDCHN_IDX_FATHER,
	     nth    = nth,
	     outID  = &parentID);

  if (parentID.objid == NULL_OBJID) goto wrapup;
  
  // Use this as a trick to get any attached macros
  vdobj$GetPretendParent(pretendID = &parentID, 
			 parentID  = &macroID);
  if (macroID.objid == NULL_OBJID) goto wrapup;
  
  // Xfer the oe info
  macroOE.obj_id  = macroID;
  macroOE.mod_env = cutOE.mod_env; // Always in the same space

#if 0
  printf("### Checking beam parent --------------------------------\n");
  vdobj$Print(objOE =  beamOE);
  vdobj$Print(objOE = &macroOE);
#endif

  // Macros with multiple cutting curves will get picked up multiple times
  for(i = 0; vdvlaoe$GetNth(vla = macVLA, nth = i, data = &macroOEx); i++) {
    if ((macroOEx.obj_id.objid == macroOE.obj_id.objid) &&
	(macroOEx.obj_id.osnum == macroOE.obj_id.osnum)) {
      goto wrapup;
    }
  }

  /* ----------------------------------------------------------------------
   * For now, make the assumption that this et macro belongs to the
   * beam in question and is not in fact being used as a parent of some
   * other beam as well.  
   *
   * What might need to do is to get the macro's first parent then verify that
   * the parent is in the beam tree.  The thing is, not sure that this will
   * actually cover all the cases or not when dealing with things like split beams.
   */
  vdobj$GetTemplate(objOE = &macroOE,
		    nth   = 0,
		    templateOE = &parentOE);
  if (parentOE.obj_id.objid == NULL_OBJID) goto wrapup;
  
  sts = VDobjIsObjectAParent(beamOE,&parentOE,0);
  if (!(sts & 1)) goto wrapup;

  // Got candidate
  vdvlaoe$Append(vla = macVLA, data = &macroOE); 
  // vdobj$Print(objOE = &macroOE);
  
wrapup:
  return retFlag;
}

/* ------------------------------------------------------------
 * Recurse routine to find end treatment macros by looking
 * at attached cutting graphics for VSbooBeams
 *
 * Actually return all procecessed macros whose first parent is 
 * in the ancestry of the beam
 */
IGRstat VSefpGetProcessedMacros(TGRobj_env *beamOE, TVDvlaoe *macVLA)
{
  IGRstat retFlag = 1;
  IGRstat sts;

  VDclassid  classID;
  
  TGRobj_env parentOE;
  
  IGRint cutI;
  
  // Arg check
  if (macVLA == NULL) goto wrapup;
  if (beamOE == NULL) goto wrapup;
  
  // Make sure not way off base
  sts = vdobj$IsAncestryValid(objOE = beamOE,
			      superClassID = OPP_VSbeam_class_id);
  if (!(sts & 1)) {
    goto wrapup;
  }
  vdobj$Get(objOE = beamOE, classID = &classID);
  
  // Source and twisted beams are the end of the food chain
  if ((OPP_VSsrcBeam_class_id == classID) ||
      (OPP_VSstfBeam_class_id == classID) ||
      (OPP_VStwsBeam_class_id == classID)) goto wrapup;
  
  // First parent is a beam
  vdobj$GetTemplate(objOE = beamOE,
		    nth   = 0,
		    templateOE = &parentOE);

  /* ---------------------------------------------------------------
   * In theory we should not have to look past splits
   * Not sure if the modelors used the same theory
   */

  if ((OPP_VSsplBeam_class_id == classID) ||
      (OPP_VSsubBeam_class_id == classID)) {

    //retFlag = VSefpGetPossibleEndTreatments(&parentOE,etVLA);
    retFlag = 1;
    goto wrapup;
  }
  
  // Processed macros always generate boo beams (maybe)
  if (OPP_VSbooBeam_class_id != classID) {
    printf("Unexpected beam type while searching for end types\n");
    vdobj$Print(objOE = beamOE);
    goto wrapup;
  }
  
  // Check each of the other parents
  for(cutI = 1; VSefpCheckProcessedMacro(beamOE,cutI,macVLA); cutI++);
    
  // Recurse up looking for more
  retFlag = VSefpGetProcessedMacros(&parentOE,macVLA);
  
wrapup:
  return retFlag;
}

/* ------------------------------------
 * Fills in etInfo structure
 */
IGRstat VSefpGetEtInfo(TGRobj_env *beamOE, TGRobj_env *etOE, TVSefpEtInfo *etInfo)
{
  IGRstat retFlag = 0;
  IGRstat sts,msg;
  BSrc    rc;
  
  IGRchar buf[128];
  TGRid   et_typeID;
  
  // Init Trace
  traceFlag = VDdbgGetTraceFlag(VDEFP_TRACE_VERIFY_PIECE);
  if (traceFlag) {
    printf(">>> VSefpGetEtInfo\n");
  }
  *buf = 0;
  
  // Arg check
  if (etInfo == NULL) goto wrapup;
  memset(etInfo,0,sizeof(TVSefpEtInfo));
  if (beamOE == NULL) goto wrapup;
  if (etOE   == NULL) goto wrapup;

  // Verify it's and end treatment by looking for et_type
  vdmac$Get(objOE = etOE, footName = "et_type", footID = &et_typeID);
  if (et_typeID.objid == NULL_OBJID) goto wrapup;
  
  // Xfer some stuff
  etInfo->beamOE = *beamOE;
  etInfo->etOE   = *etOE;

  if (traceFlag) {
    vdobj$Print(objOE = etOE);
  }
  
  // Store the macro information
  vdmac$Get(objOE = etOE, defName = etInfo->macType);
  vdobj$Get(objOE = etOE, objName = etInfo->macName);
   
  // Get it's cs
  vdmac$Get(objOE = etOE, footName = "cs", footID = &etInfo->csID);
  if (etInfo->csID.objid == NULL_OBJID) {
    strcpy(buf,"Unable to find cs for et macro");
    goto wrapup;
  }
  if (traceFlag) {
    vdobj$Print(objID = &etInfo->csID);
  }
    
  // Get the cs matrix 
  sts = om$send(msg = message GRgencs.GRgetmatrix(&msg,etInfo->csMatrix.matrix),
		senderid = NULL_OBJID,
		targetid = etInfo->csID.objid,
		targetos = etInfo->csID.osnum);
  if (!(sts & 1)) {
    strcpy(buf,"Problem getting cs matrix");
    goto wrapup;
  }
  MAtypemx(&rc,etInfo->csMatrix.matrix,&etInfo->csMatrix.matrix_type);
    
  // Stash origin
  etInfo->csOrg[0] = etInfo->csMatrix.matrix[ 3];
  etInfo->csOrg[1] = etInfo->csMatrix.matrix[ 7];
  etInfo->csOrg[2] = etInfo->csMatrix.matrix[11];
  
  // Grab the type
  vdmac$Get(objOE = etOE, footName = "et_type", footID = &etInfo->et_typeID);
  if (etInfo->et_typeID.objid == NULL_OBJID) {
    strcpy(buf,"Unable to find et_type for et macro");
    goto wrapup;
  }
  if (traceFlag) {
    vdobj$Print(objID = &etInfo->et_typeID);
  }
  vdsa$Get(objID = &etInfo->et_typeID, name = "id", txt = etInfo->etType);

  //vdobj$Print(objID = &etInfo->et_typeID);
  //printf("et_type id '%s'\n",txt);
#if 0
  printf("ET %6d %s %s %s\n",
	 etOE->obj_id.objid,
	 etInfo->macType,
	 etInfo->macName,
	 etInfo->etType);
#endif

  // Get the output info
  vdmac$Get(objOE = etOE, footName = "et_output", footID = &etInfo->et_outputID);
  if (etInfo->et_outputID.objid != NULL_OBJID) {
    vdsa$Get(objID = &etInfo->et_outputID, name = "xbase",  dbl = &etInfo->xbase);
    vdsa$Get(objID = &etInfo->et_outputID, name = "xweb",   dbl = &etInfo->xweb);
    vdsa$Get(objID = &etInfo->et_outputID, name = "xflg0",  dbl = &etInfo->xflg0);
    vdsa$Get(objID = &etInfo->et_outputID, name = "xflg1",  dbl = &etInfo->xflg1);
    vdsa$Get(objID = &etInfo->et_outputID, name = "m1",     dbl = &etInfo->m1);
    vdsa$Get(objID = &etInfo->et_outputID, name = "m2",     dbl = &etInfo->m2);
    vdsa$Get(objID = &etInfo->et_outputID, name = "m3",     dbl = &etInfo->m3);
    vdsa$Get(objID = &etInfo->et_outputID, name = "m4",     dbl = &etInfo->m4);
    vdsa$Get(objID = &etInfo->et_outputID, name = "angle0", dbl = &etInfo->angle0);
    vdsa$Get(objID = &etInfo->et_outputID, name = "angle2", dbl = &etInfo->angle2);
  }
  
  // Get the params info
  vdmac$Get(objOE = etOE, footName = "et_params", footID = &etInfo->et_paramsID);
  if (etInfo->et_paramsID.objid != NULL_OBJID) {
    vdsa$Get(objID = &etInfo->et_paramsID, name = "r_scallop", dbl = &etInfo->r_scallop);
    vdsa$Get(objID = &etInfo->et_paramsID, name = "r_snipe",   dbl = &etInfo->r_snipe);
    vdsa$Get(objID = &etInfo->et_paramsID, name = "flg_angle", dbl = &etInfo->flg_angle);
    vdsa$Get(objID = &etInfo->et_paramsID, name = "w_snipe",   dbl = &etInfo->w_snipe);
  }
  
  // Get the free info
  vdmac$Get(objOE = etOE, footName = "et_free", footID = &etInfo->et_freeID);
  if (etInfo->et_paramsID.objid != NULL_OBJID) {
    vdsa$Get(objID = &etInfo->et_freeID, name = "web_angle", dbl = &etInfo->web_angle);
    vdsa$Get(objID = &etInfo->et_freeID, name = "d_lower",   dbl = &etInfo->d_lower);
    vdsa$Get(objID = &etInfo->et_freeID, name = "d_upper",   dbl = &etInfo->d_upper);
    vdsa$Get(objID = &etInfo->et_freeID, name = "r_upper",   dbl = &etInfo->r_upper);
  }
  
  // printf("ET angles %f %f\n",etInfo->angle0,etInfo->angle2);
  
  // Done
  retFlag = 1;
  
wrapup:

  if (traceFlag) {
    if (*buf) {
      printf("*** %s\n",buf);
    }
    
    printf("<<< VSefpGetEtInfo %d\n",retFlag);
  }
  else {
    if (*buf) {
      printf("------- Problem getting end treatment info -------------\n");
      vdobj$Print(objOE = etOE);
      printf("*** %s\n",buf);
      printf("-----\n");
    }
  }
  
  return retFlag;
}

end implementation Root;









