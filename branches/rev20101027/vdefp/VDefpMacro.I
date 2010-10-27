/* ------------------------------------
 * Some generic macro specific routines
 */
class implementation Root;

#include "VDtypedef.h"
#include "VDobj.h"
#include "VDchn.h"
#include "VDdir.h"

#include "VDmem.h"
#include "VDgeom.h"
#include "VDefp.h"

#include "VDdbgProto.h"

#include "EMSopt.h"
#include "EMSlcdef.h"

#include "acdef.h"
#include "acmacros.h"

#include "asmacros.h"
#include "macro.h"
#include "bssfevaln.h"

from ci_macro   import init;
from GRgraphics import GRputname;

extern VDclassid OPP_nci_macro_class_id;

static IGRint traceFlag;

/* -------------------------------------------------
 * Place a macro using semi-smart default paths
 */
IGRstat VDefpPlaceMacro(IGRchar    *libName,
                        IGRchar    *macName,
                        IGRint      macOptions,
                        IGRint      tplCnt,
                        TGRobj_env *tplOEs,
			TGRobj_env *macOE)
{
  IGRstat retFlag = 0;
  IGRstat sts,msg;
  IGRint  suc;

  IGRchar occName[128];

  IGRchar occPath[DI_PATH_MAX];
  IGRchar pwdPath[DI_PATH_MAX];
  
  TGRsymbology symb1,symb2;
  IGRint       symbFlag = 0;

  TGRid  srcIDs[16];
  TGRid *srcID;
  IGRint srcCnt;

  // Init
  *occPath = 0;
  *pwdPath = 0;

  // Say hi
  traceFlag = VDdbgGetTraceFlag(VDEFP_TRACE_PLACE_MACRO);
  if (traceFlag) {
    if (macName) printf(">>> VDefpPlaceMacro %s\n",macName);
    else         printf(">>> VDefpPlaceMacro NO MACRO NAME\n");
  }

  // Arg check
  if (macOE == NULL) goto wrapup;
  gr$get_module_env(buffer = &macOE->mod_env);
  macOE->obj_id.osnum = macOE->mod_env.md_id.osnum;
  macOE->obj_id.objid = NULL_OBJID;

  if ((tplCnt < 1) || (tplOEs == NULL)) goto wrapup;
  if (macName == NULL) goto wrapup;

  if (macOptions);

  // Source everything
  if (tplCnt > 16) {
    printf("Lots of templates(%d) when placing macro %s\n",tplCnt,macName);
    goto wrapup;
  }
  for(srcCnt = 0; srcCnt < tplCnt; srcCnt++) {
    srcID = &srcIDs[srcCnt];
    srcID->osnum = macOE->obj_id.osnum;
    srcID->objid = NULL_OBJID;

    sts = as$make_source(go_grid =  tplOEs[srcCnt].obj_id,
                         mod_env = &tplOEs[srcCnt].mod_env,
                         as_grid =  srcID);

    if ((!(sts & 1)) || (srcID->objid == NULL_OBJID)) {
      printf("Problem sourcing parent in VDefpPlaceMacro %s\n",macName);
      vdobj$Print(objOE = &tplOEs[srcCnt]);
      goto wrapup;
    }
  }

  // Attach library if necessary
  if ((libName != NULL) && (*libName != 0)) {
    ac$construct_path(mode = AC_ADD_PATH, name = libName);
  }

  /* Construct nci_macro */
  om$construct(classid = OPP_nci_macro_class_id,
               osnum   =  macOE->obj_id.osnum,
               p_objid = &macOE->obj_id.objid);

  if (macOE->obj_id.objid == NULL_OBJID) goto wrapup;

  VDahGetActiveSymbology(&symb1);
  VDahGetActiveSymbology(&symb2);

  // Adjust symbology based on macro name
  if (!strcmp(macName,"efp_beam2d")) {
    symb2.level = 778;
    symb2.display_attr.color  = 3;
    symb2.display_attr.weight = 2;
    symb2.display_attr.style  = 0;
    VDahSetActiveSymbology(&symb2);
    symbFlag = 1;
  }
  if (!strcmp(macName,"efp_beam")) {
    symb2.level = 777;
    symb2.display_attr.color  = 3;
    symb2.display_attr.weight = 2;
    symb2.display_attr.style  = 0;
    VDahSetActiveSymbology(&symb2);
    symbFlag = 1;
  }
  if (!strcmp(macName,"neat_plate") ||
      !strcmp(macName,"neat_plateBS")) {
    symb2.level = 772;
    symb2.display_attr.color  = 3;
    symb2.display_attr.weight = 2;
    symb2.display_attr.style  = 0;
    VDahSetActiveSymbology(&symb2);
    symbFlag = 1;
  }
  if (!strcmp(macName,"neat_plateo")) {
    symb2.level = 773;
    symb2.display_attr.color  = 3;
    symb2.display_attr.weight = 2;
    symb2.display_attr.style  = 0;
    VDahSetActiveSymbology(&symb2);
    symbFlag = 1;
  }
  if (!strcmp(macName,"neat_surf")) {
    symb2.level = 771;
    symb2.display_attr.color  = 4;
    symb2.display_attr.weight = 2;
    symb2.display_attr.style  = 0;
    VDahSetActiveSymbology(&symb2);
    symbFlag = 1;
  }
  if (!strcmp(macName,"nat_edge")) {
    symb2.level = 774;
    symb2.display_attr.color  = 4;
    symb2.display_attr.weight = 2;
    symb2.display_attr.style  = 0;
    VDahSetActiveSymbology(&symb2);
    symbFlag = 1;
  }
  if (!strcmp(macName,"datum_mark")) {
    symb2.level = 775;
    symb2.display_attr.color  = 5;
    symb2.display_attr.weight = 2;
    symb2.display_attr.style  = 0;
    VDahSetActiveSymbology(&symb2);
    symbFlag = 1;
  }
  if (!strcmp(macName,"crv_tran2")) {
    symb2.level = 779;
    symb2.display_attr.color  = 6;
    symb2.display_attr.weight = 2;
    symb2.display_attr.style  = 0;
    VDahSetActiveSymbology(&symb2);
    symbFlag = 1;
  }
  if (!strcmp(macName,"neat_cont")) {
    symb2.level = 776;
    symb2.display_attr.color  = 3;
    symb2.display_attr.weight = 2;
    symb2.display_attr.style  = 0;
    VDahSetActiveSymbology(&symb2);
    symbFlag = 1;
  }

  // Adjust paths
  di$give_pathname(osnum = macOE->obj_id.osnum, pathname = occPath);
  DIstrcat(occPath,"usr");
  DIstrcat(occPath,"efp");    
  di$mkdir(dirname = occPath);
  DIstrcat(occPath,macName);
  di$mkdir(dirname = occPath);

  di$pwd(dirname = pwdPath);
  di$cd (dirname = occPath);

  //printf("occPath %s\n",occPath);
  //printf("pwdPath %s\n",pwdPath);

  // Set the name
  VDahGetNextOccName(macName,NULL,occName);
  om$send(msg = message GRgraphics.
          GRputname(&msg,occName),
    senderid = NULL_OBJID,
    targetid = macOE->obj_id.objid,
    targetos = macOE->obj_id.osnum);

  /* Create macro occurence */
  sts = om$send(msg = message ci_macro.
                init(&suc,0,macName,srcCnt,srcIDs,NULL,&macOE->mod_env),
                mode     = OM_e_wrt_message,
                senderid = NULL_OBJID,
                targetid = macOE->obj_id.objid,
                targetos = macOE->obj_id.osnum);

  if (!(sts & suc & 1)) {
    printf("Problem creating %s macro\n",macName);
    vdobj$Delete(objOE = macOE);
    macOE->obj_id.objid = NULL_OBJID;
    goto wrapup;
  }

  retFlag = 1;

wrapup:

  // Reset symbology
  if (symbFlag)  VDahSetActiveSymbology(&symb1);
  if (*pwdPath)  di$cd(dirname = pwdPath);
 
  if (traceFlag) {
    printf("@@@ VDefpPlaceMacro %d\n",retFlag);
  }

  return retFlag;
}

/* -----------------------------------------------------
 * True if the macro is of the given type with parent
 */
IGRstar VDefpIsMacroAttached(IGRchar    *macNamex,
		             TGRid      *macID,
	                     VDosnum     macOS,
                             IGRint      tplCnt,
                             TGRobj_env *tplOEs,
		             TGRobj_env *macOE)
{
  IGRstat retFlag = 0;

  TGRobj_env parentOE;
  IGRchar    macName[128];
  IGRint     i;

  // Only want specified macro
  vdobj$Get(objID = macID, macName = macName);  
  if (strcmp(macNamex,macName)) goto wrapup;
  
  // Maybe only want macros in the same os
  if (macOS != OM_K_NOT_AN_OS) {
    if (macID->osnum != macOS) goto wrapup;
  }
  
  // Verify parent is the plate
  if (tplCnt < 1) goto wrapup;
  for(i = 0; i < tplCnt; i++) {
    vdobj$GetTemplate(objID      = macID,
                      nth        = i,
                      templateOE = &parentOE);

    if ((parentOE.obj_id.objid != tplOEs[i].obj_id.objid) ||
        (parentOE.obj_id.osnum != tplOEs[i].obj_id.osnum)) goto wrapup;
  }

  retFlag = 1;
  
  // Fill in macOE data if requested
  if (macOE == NULL) goto wrapup;
  
  macOE->obj_id  = *macID;
  macOE->mod_env = tplOEs[0].mod_env; // Assume matrix is the same
  macOE->mod_env.md_id.osnum = macID->osnum;
  ex$get_modid(mod_osnum =  macOE->mod_env.md_id.osnum, 
	       mod_id    = &macOE->mod_env.md_id.objid);

  // Done

wrapup:
  return retFlag;
}

/* -----------------------------------------------------
 * Finds given macro attached to object
 * Use whan want to prevent placing a macro more than once
 */
IGRstat VDefpGetAttachedMacro(IGRchar    *macName,
		              VDosnum     macOS,
                              IGRint      tplCnt,
                              TGRobj_env *tplOEs,
              		      IGRint      treeFlag, 
			      TGRobj_env *macOE)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  
  IGRint i;

  TVDvlaID macVLA;
  TGRid    macID;
  
  // Arg check
  vdvla_id$Construct(vla = &macVLA);
  if (macOE) macOE->obj_id.objid = NULL_OBJID;
  if (tplCnt < 1) goto wrapup;

  // Find all possible macros
  vdchn$GetChildrenByClass(objOE     = &tplOEs[0],
                           className = "nci_macro",
                           vla       = &macVLA);

  for(i = 0; 
      vdvla_id$GetAt(vla = &macVLA, nth = i, objID = &macID); 
      i++) {
      
    sts = VDefpIsMacroAttached(macName,&macID,macOS,tplCnt,tplOEs,macOE);

    if (sts & 1) {
      retFlag = 1;
      goto wrapup;
    }
  }
  
  // Want to look higher in the tree
  if (treeFlag == 0) goto wrapup;
  
  // Implement later if needed
  
wrapup:
  vdvla_id$Delete(vla = &macVLA);  
  return retFlag;
}

end implementation Root;

