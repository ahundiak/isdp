/* -----------------------------
 * Struct edge routines
 */
class implementation Root;

#include "VDtypedef.h"
#include "VDobj.h"
#include "VDchn.h"
#include "VDvla.h"

#include "VDefp.h"
#include "VSefp.h"

extern VDclassid OPP_VSplate_class_id;
extern VDclassid OPP_VSsrcPlate_class_id;
extern VDclassid OPP_VSsubPlate_class_id;
extern VDclassid OPP_ACpretend_class_id;
extern VDclassid OPP_nci_macro_class_id;
extern VDclassid OPP_ACconst_class_id;

from ACpretend import ACgive_downscan;

/* -----------------------------------
 * Debug trace flag
 */
static IGRstat VSefpGetEdgeTraceFlag()
{
  IGRstat retFlag = VDdbgGetTraceDev4();
//retFlag = 1;
  return retFlag;
}

/* -----------------------------------------------------
 * Find neat_plate macro attached to plate
 */
extern IGRstat VSefpGetAttachedNeatPlateMacro(
  IGRchar    *macName,
  VDosnum     macOS,
  TGRobj_env *plateOE,
  IGRint      treeFlag,
  TGRobj_env *macOE)

{
  IGRstat retFlag = 0;
  IGRstat sts;
  
  TGRobj_env parentOE;

  // Use the stabdard check
  sts = vdefp$GetAttachedMacro(macName = macName,
                               macOS   = macOS,
                               tplCnt  = 1,
                               tplOEs  = plateOE,
                               macOE   = macOE);
  if (sts & 1) {
    retFlag = 1;
    goto wrapup;
  }
  
  // Want to look higher in the tree
  if (treeFlag == 0) goto wrapup;
  
  // Is there anything higher
  sts = VSefpIsNeatPlate(plateOE);
  if (sts & 1) goto wrapup;

  // Grab it's first parent
  vdobj$GetTemplate(objOE = plateOE,
                    nth   = 0,
                    templateOE = &parentOE);
  if (parentOE.obj_id.objid == NULL_OBJID) goto wrapup;

  // Verif it's a plate
  sts = vdobj$IsAncestryValid(objOE = &parentOE,
                              superClassID = OPP_VSplate_class_id);
  if (!(sts & 1)) goto wrapup;

  // Recurse
  sts = vsefp$GetAttachedNeatPlateMacro(plateOE  = &parentOE,
					macName  = macName,
                                        macOS    = macOS,
                                        treeFlag = treeFlag,
                                        macOE    = macOE);
  if (sts & 1) retFlag = 1;

wrapup:
  return retFlag;
}

/* --------------------------------------------------------
 * Tries to detrmine if a plate is a neat plate
 * vice a regular processed with cutouts plate
 * Used to output to spades
 * need to move to a ppl
 */
IGRstar VSefpIsNeatPlate(TGRobj_env *plateOE)
{
  IGRstat retFlag = 0;
  IGRstat sts;

  IGRstat traceFlag = VSefpGetEdgeTraceFlag();
  
  VDclassid classID;

  TGRid pretendID;
  TGRid macroID;
  
  IGRchar macroName[64];
  IGRchar downScan[128];

  // traceFlag = 1;
  
  // Init
  pretendID.objid = NULL_OBJID;
  macroID.objid   = NULL_OBJID;
  *macroName = 0;
  
  if (traceFlag || 0) {
    printf(">>> VSefpIsNeatPlate\n");
    vdobj$Print(objOE = plateOE);
  }

  // Arg Check
  if (plateOE == NULL) goto wrapup;
  
  sts = vdobj$IsAncestryValid(objOE        = plateOE, 
                              superClassID = OPP_VSplate_class_id);
  if (!(sts & 1)) {
    printf("Problem in VSefpIsNeatPlate for \n");
    vdobj$Print(objOE = plateOE);
    goto wrapup;
  }
  
  // Is it a source plate or sub plate?
  vdobj$Get(objOE = plateOE, classID = &classID);

  if ((classID == OPP_VSsrcPlate_class_id) ||
      (classID == OPP_VSsubPlate_class_id)) {
     
    // Got it
    retFlag = 1;
    goto wrapup;
  }

  // If have a neat plate macro attached then stop
  sts = vdefp$GetAttachedMacro(macName = VDEFP_NEAT_PLATE_MACRO_NAME,
                               tplOEs  = plateOE);
  if (sts & 1) {
    retFlag = 1;
    goto wrapup;
  }

  // Maybe should check all additional parents here for safety

  // Check second parent
  vdchn$Get2(objOE  = plateOE,
	     chnIDx = VDCHN_IDX_FATHER,
	     nth    = 1,
	     outID  = &pretendID );

  if (pretendID.objid == NULL_OBJID) goto wrapup;

  if (traceFlag) {
    vdobj$Print(objID = &pretendID);
  }
  
  sts = vdobj$IsAncestryValid(objID        = &pretendID, 
                              superClassID = OPP_ACpretend_class_id);
  if (!(sts & 1)) goto wrapup;

  /* Check it's downscan, 'Plate' is assumed to
   * be a boolean op against another plate solid
   * i.e. a trim operation
   *
   * Add plate:offset and plate:base as well
   */
  *downScan = 0;
  om$send(msg = message ACpretend.ACgive_downscan(downScan),
	  senderid = NULL_OBJID,
	  targetid = pretendID.objid,
	  targetos = pretendID.osnum);
  
  if ((!strcmp(downScan,"plate")) ||
      (!strcmp(downScan,"plate:offset")) ||
      (!strcmp(downScan,"plate:base")))
  {
    // Got it
    retFlag = 1;
    goto wrapup;
  }

  // Get the parent macro object
  vdchn$Get2(objID  = &pretendID, 
	     chnIDx = VDCHN_IDX_PARENT, 
	     nth    = 0, 
	     outID  = &macroID);
  if (macroID.objid == NULL_OBJID) goto wrapup;

  if (traceFlag) {
    vdobj$Print(objID = &macroID);
  }
  
  // nci_macros are used for some surface edge trimming
  sts = vdobj$IsAncestryValid(objID        = &macroID, 
                              superClassID = OPP_nci_macro_class_id);
  if (sts & 1) {

    // Go based on name
    vdobj$Get(objID = &macroID, macName = macroName);

    if (traceFlag) {
      printf("nci_macro %s\n",macroName);
    }
   
    // pla_offset is the only known neater for now
    if (!strcmp(macroName,"pla_offext")) {
      retFlag = 1;
      goto wrapup;
    }

    // A reverse normal is assumed to be attached to a plate surface
    if (!strcmp(macroName,"rev_normal")) {
      retFlag = 1;
      goto wrapup;
    }
  }
  
  
  // The edge_cut macro is attached as an ACconst
  sts = vdobj$IsAncestryValid(objID        = &macroID, 
			      superClassID = OPP_ACconst_class_id);

    
  if (sts & 1) {

    // Go based on name
    vdobj$Get(objID = &macroID, macName = macroName);

    if (traceFlag) {
      printf("ACconst %s\n",macroName);
    }
   
    // pla_offset is the only known neater for now
    if (!strcmp(macroName,"edge_cut")) {
      retFlag = 1;
      goto wrapup;
    }
  }
  
wrapup:

  if (traceFlag) {
    printf("@@@ VSefpIsNeatPlate, %d\n",retFlag);
  }
  // traceFlag = 0;
  
  return retFlag;
}

/* --------------------------------------------------------
 * Gets the neat plate and/or a list of all plates
 * from the input plate and the neat plate
 * recursive routine
 */
IGRstar VSefpGetNeatPlate(TGRobj_env *plateOE,
                          TGRobj_env *neatOE, 
                          TVDvlaOE   *plateVLA)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  
  TGRobj_env parentOE;
  
  // Arg Check
  if (neatOE) neatOE->obj_id.objid = NULL_OBJID;
  if ((plateOE == NULL) || (plateOE->obj_id.objid == NULL_OBJID)) goto wrapup;
  
  // Just to make sure
  sts = vdobj$IsAncestryValid(objOE        = plateOE,
                              superClassID = OPP_VSplate_class_id);
  if (!(sts & 1)) goto wrapup;

  // Init
  if (plateVLA) {
    vdvla_oe$Append(vla = plateVLA, objOE = plateOE);
  }

  // Check if done
  sts = VSefpIsNeatPlate(plateOE);
  if (sts & 1) {
    if (neatOE) *neatOE = *plateOE;
    retFlag = 1;
    goto wrapup;
  }
  
  // Grab it's first parent
  vdobj$GetTemplate(objOE = plateOE,
                    nth = 0,
                    templateOE = &parentOE);

  if (parentOE.obj_id.objid == NULL_OBJID) goto wrapup;
  
  // Recurse
  retFlag = VSefpGetNeatPlate(&parentOE,neatOE,plateVLA);
  
wrapup:
  return retFlag;
}

end implementation Root;





