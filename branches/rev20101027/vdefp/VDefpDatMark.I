/* ------------------------------------
 * Datum Plane Marking Routines
 */
class implementation Root;

#include "VDtypedef.h"
#include "VDobj.h"
#include "VDmem.h"
#include "VDgeom.h"
#include "VDefp.h"

#include "VDdbgProto.h"
#include "vdAPImacros.h"

#include "EMSopt.h"
#include "EMSlcdef.h"

#include "acdef.h"
#include "acmacros.h"

#include "asmacros.h"
#include "macro.h"
#include "bssfevaln.h"

from EMSsubbs     import EMget_edges;
from EMSedge      import EMgetxyzobj;
from ACrg_collect import ACset_list_attribute;

from ci_macro     import init;
from GRvg         import GRchgdp;
from GRvg         import GRchglevel;
from GRvg         import GRgetsymb;
from GRvg         import GRputsymb;
from GRvg         import GRcenter;
from GRgraphics   import GRchgname;
from GRgraphics   import GRputname;
from ACncpx       import ACmplace;
from GRconnector  import GRrigidconn;

extern VDclassid OPP_nci_macro_class_id;
extern VDclassid OPP_ACrg_collect_class_id;

static IGRint traceFlag;

/* -----------------------------------
 * Debug trace flag
 */
IGRstar VDefpGetDatumMarkTraceFlag()
{
  IGRstat retFlag = VDdbgGetTraceFlag(VDEFP_TRACE_COMPUTE_DATUM_MARK);
//retFlag = 1;
  return  retFlag;
}

/* ------------------------------------
 * Compute function for the datum_mark
 * macros object
 */
IGRstar VDefpComputeDatumMark(TGRobj_env *macOE,
                              IGRint      opFlag,
                              IGRint     *markCnt,
                              TGRid      *markIDs)
{
  IGRstat    retFlag = 0;
  IGRstat    sts;

  TGRobj_env pieceOE;
  TGRobj_env planeOE;

  TGRobj_env srfOE;

  IGRchar    macObjName[128];
  IGRchar    macObjDesc[128];
  IGRchar    buf[128];
  IGRint     i;

  TGRid *intIDs = NULL;

  // Arg check
  if ((markCnt == NULL) || 
      (markIDs == NULL) || 
      (macOE   == NULL)) goto wrapup2;

  // Say hi
  traceFlag = VDefpGetDatumMarkTraceFlag();

  if (traceFlag) {
    printf(">>> Entering VDefpComputeDatumMark\n");
    vdobj$Print(objOE = macOE);
  }
  vdobj$Get(objOE = macOE, objName = macObjName);
  sprintf(macObjDesc,"%d,%d %s",
          macOE->obj_id.osnum,
          macOE->obj_id.objid,
          macObjName);

  sprintf(buf,"Processing %s",macObjDesc);
  UI_status(buf);

  if (traceFlag) printf("%s\n",macObjDesc);

  // Init
  *markCnt = 0;
  if (opFlag);

  srfOE.obj_id.objid = NULL_OBJID;

  // Get the plane parent
  vdobj$GetTemplate(objOE      = macOE,
                    nth        = VDEFP_DATUM_MARK_PARENT_PLANE,
                    templateOE = &planeOE);

  if (planeOE.obj_id.objid == NULL_OBJID) goto wrapup;
  if (traceFlag) {
    vdobj$Print(objOE = &planeOE);
  }

  // Get Piece Parent
  vdobj$GetTemplate(objOE      = macOE,
                    nth        = VDEFP_DATUM_MARK_PARENT_PIECE,
                    templateOE = &pieceOE);

  if (pieceOE.obj_id.objid == NULL_OBJID) goto wrapup;

  if (traceFlag) {
    vdobj$Print(objOE = &pieceOE);
  }

  // Check for plate
  sts = vdobj$IsAncestryValid(objOE          = &pieceOE, 
                              superClassName = "VSplate");

  if (sts & 1) {

    // Hardcode to base surface for now
    vdobj$GetFoot(objOE    = &pieceOE, 
		  footName = VDEFP_PLATE_BASE_SURF_NAME, 
		  footOE   = &srfOE);
  }
  
  // Check for beam
  sts = vdobj$IsAncestryValid(objOE          = &pieceOE, 
                              superClassName = "VSbeam");

  if (sts & 1) {

    // Hardcode to base surface for now
    vdobj$GetFoot(objOE    = &pieceOE, 
		  footName = VDEFP_BEAM_WEB_LEFT_NAME, 
		  footOE   = &srfOE);
  }

  // Make sure got surface
  if (srfOE.obj_id.objid == NULL_OBJID) goto wrapup;

  if (traceFlag) vdobj$Print(objOE = &srfOE);

  // Setup call for intersection
  sts = vd$int2elem(
    elem1 = &srfOE,
    elem2 = &planeOE,
    trim1req =  2,
    trim2req =  0,
    NumbInt  =  markCnt,
    GRidInt  = &intIDs);

  // Xfer results
  if (*markCnt == 0) goto wrapup;
  if (intIDs == NULL) goto wrapup;

  if (*markCnt > VDEFP_DATUM_MARK_FOOT_MAX) {
    *markCnt = VDEFP_DATUM_MARK_FOOT_MAX;
  }

  for(i = 0; i < *markCnt; i++) {
    markIDs[i] = intIDs[i];
  }

  _FREE(intIDs);
 
  // Done
  retFlag = 1;

wrapup:

  if (traceFlag) {
    if (!(retFlag & 1)) printf("FAILED!!!\n");
    printf("@@@ VDefpComputeDatumMark, Mark Cnt %d\n",*markCnt);
  }
  sprintf(buf,"Processed %s, Mark Cnt %d",macObjDesc,*markCnt);
  UI_status(buf);

wrapup2:
  return retFlag;
}

end implementation Root;

