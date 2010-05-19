/* $Id: VDbufMacroj.I,v 1.8 2001/08/24 19:59:06 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdah/om/VDbufMacroj.I
 *
 * Description:	Buffer Macro Routines
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDbufMacroj.I,v $
 *      Revision 1.8  2001/08/24 19:59:06  ahundiak
 *      ah
 *
 *      Revision 1.7  2001/08/14 18:58:41  ahundiak
 *      ah
 *
 *      Revision 1.6  2001/07/28 17:30:58  ahundiak
 *      ah
 *
 *      Revision 1.5  2001/07/23 16:00:33  ahundiak
 *      ah
 *
 *      Revision 1.4  2001/06/22 15:10:00  ahundiak
 *      ah
 *
 *      Revision 1.3  2001/06/14 18:46:56  ahundiak
 *      ah
 *
 *      Revision 1.2  2001/06/14 18:32:37  ahundiak
 *      ah
 *
 *      Revision 1.1  2001/06/07 19:30:53  ahundiak
 *      ah
 *
 *      Revision 1.1  2001/06/07 19:05:24  ahundiak
 *      ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 05/14/01  ah      Creation
 ***************************************************************************/

class implementation Root;

#include "VDtypedef.h"
#include "VDassert.h"
#include "VDlog.h"
#include "VDefp.h"
#include "VDbuf.h"

#include "VDobj.h"
#include "VDchn.h"
#include "VDdir.h"

#include "VDctx.h"
#include "VDxdom.h"

#include "acdef.h"
#include "acmacros.h"

#include "asmacros.h"
#include "macro.h"

VDASSERT_FFN("VDbufMacroj.I");

from ci_macro   import init;
from GRgraphics import GRputname;
from VDbufMacro import vdbufSetData;
from VDbufMacro import vdbufGetData;

extern VDclassid OPP_VDbufMacro_class_id;

/* -------------------------------------------------
 * Function interface for getting buf data
 * Returns pointer directly back to internal data
 * Don't free!
 */
IGRstat VDbufGetInternalData(TGRobj_env *bufOE, IGRchar **data)
{
  VDASSERT_FN("VDbufGetData");
  IGRstat retFlag = 0;
  
  // Arg check
  VDASSERTW(data); *data = NULL;
  VDASSERTW(bufOE && bufOE->obj_id.objid != NULL_OBJID);
 
  // Get it
  om$send(msg = message VDbufMacro.vdbufGetData(1,0,0,NULL,NULL,data),
	  senderid = NULL_OBJID,
	  targetid = bufOE->obj_id.objid,
	  targetos = bufOE->obj_id.osnum);

  // Done
  retFlag = 1;

 wrapup:
  return retFlag;
}

/* -------------------------------------------------
 * Function setting buf data
 */
IGRstat VDbufSetTxtData(TGRobj_env *bufOE, IGRchar *data)
{
  VDASSERT_FN("VDbufSetData");
  IGRstat retFlag = 0;
  IGRint len = 0;
  
  // Arg check
  VDASSERTW(bufOE && bufOE->obj_id.objid != NULL_OBJID);

  // Need the length
  if (data) len = strlen(data) + 1;
  
  // Get it
  om$send(msg = message VDbufMacro.vdbufSetData(1,0,len,data),
	  senderid = NULL_OBJID,
	  targetid = bufOE->obj_id.objid,
	  targetos = bufOE->obj_id.osnum);

  // Done
  retFlag = 1;

 wrapup:
  return retFlag;
}
/* -------------------------------------------------
 * Get real dangerous and compress the data before saving
 */
IGRstat VDbufSetCompressedTxtData(TGRobj_env *bufOE, IGRchar *data)
{
  VDASSERT_FN("VDbufSetCompressedData");
  IGRstat retFlag = 0;
  IGRint len = 0;

  IGRchar *datax;
  IGRint   lenx;
  IGRint  *len2;
  IGRint   intSize1 = sizeof(IGRint);
  IGRint   intSize2 = sizeof(IGRint) * 2;
  
  // Arg check
  VDASSERTW(bufOE && bufOE->obj_id.objid != NULL_OBJID);

  // Need the length
  if (data) len = strlen(data) + 1;
  
  // Comnpress
  lenx = (len * 1.01) + 14;  // Bit conserative
  datax = malloc(lenx + intSize2);
  VDASSERTW(datax);
  compress(datax+intSize2,&lenx,data,len);
  
  // Store uncompressed length and flag
  *(IGRint*)(datax) = 2756;
  *(IGRint*)(datax+intSize1) = len;
  
  // Get it
  om$send(msg = message VDbufMacro.vdbufSetData(1,0,lenx+intSize2,datax),
	  senderid = NULL_OBJID,
	  targetid = bufOE->obj_id.objid,
	  targetos = bufOE->obj_id.osnum);
  free(datax);
  
  // Done
  retFlag = 1;

 wrapup:
  return retFlag;
}

/* -------------------------------------------------
 * Pull out the compressed data then uncompress it
 */
IGRstat VDbufGetCompressedTxtData(TGRobj_env *bufOE, IGRchar **data)
{
  VDASSERT_FN("VDbufGetCompressedData");
  IGRstat retFlag = 0;

  IGRint len = 0;
  IGRint hdr;
  
  IGRchar *datax;
  IGRint   lenx;

  IGRint   intSize1 = sizeof(IGRint);
  IGRint   intSize2 = sizeof(IGRint) * 2;
  
  // Arg check
  VDASSERTW(bufOE && bufOE->obj_id.objid != NULL_OBJID);
  VDASSERTW(data); *data = NULL;

  // Get it
  om$send(msg = message VDbufMacro.vdbufGetData(1,0,0,&lenx,NULL,&datax),
	  senderid = NULL_OBJID,
	  targetid = bufOE->obj_id.objid,
	  targetos = bufOE->obj_id.osnum);
  VDASSERTW(datax);
  
  // Need the uncompressed length
  hdr = *(IGRint*)(datax);
  len = *(IGRint*)(datax+intSize1);
  
  // Uncompress
  *data = malloc(len);
  VDASSERTW(*data);
  
  uncompress(*data,&len,datax+intSize2,lenx-intSize2);
  
  // Done
  retFlag = 1;

 wrapup:
  return retFlag;
}

/* -------------------------------------------------
 * Use this to pull a tree out of a buf object
 */
void VDbufGetDomTree(TGRobj_env *bufOE, TGRid *treeID)
{
  VDASSERT_FN("VDbufGetDomTree");

  IGRchar *txt;
  
  // Arg check
  VDASSERTW(treeID); treeID->objid = NULL_OBJID;
  VDASSERTW(bufOE && bufOE->obj_id.objid != NULL_OBJID);
  
  // Get the text
  VDbufGetCompressedTxtData(bufOE,&txt);
  if (txt == NULL) goto wrapup;
  
  // Convert
  VDxdomCreateTreeFromXmlBuf(txt,treeID);
  free(txt);
  
 wrapup:
  return;
}

/* -------------------------------------------------
 * Use this to store a tree in a buf object
 */
void VDbufSetDomTree(TGRobj_env *bufOE, TGRid *treeID)
{
  VDASSERT_FN("VDbufSetDomTree");

  IGRchar *txt;
  
  // Arg check
  VDASSERTW(treeID && treeID->objid != NULL_OBJID);
  VDASSERTW(bufOE && bufOE->obj_id.objid != NULL_OBJID);

  // Convert to text
  VDctxSaveTreeToXmlBuf(treeID,&txt);
  VDASSERTW(txt);

  // Set it
  VDbufSetCompressedTxtData(bufOE,txt);
  free(txt);
  
 wrapup:
  return;
}

/* -------------------------------------------------
 * Place a macro using semi-smart default paths
 */
IGRstat VDbufPlaceMacro2(IGRchar    *libName,
			 IGRchar    *macName,
			 IGRchar    *name,
			 IGRchar    *data,
			 TGRid      *treeID,
			 IGRint      tplCnt,
			 TGRobj_env *tplOEs,
			 TGRobj_env *macOE)
{
  VDASSERT_FN("VDbufPlaceMacro2");
  
  IGRstat retFlag = 0;
  IGRstat sts,msg;
  IGRint  suc;

  IGRchar occName[128];
  IGRchar occWork[128];
  
  IGRchar occPath[DI_PATH_MAX];
  IGRchar pwdPath[DI_PATH_MAX];
  
  TGRsymbology symb1,symb2;
  IGRint       symbFlag = 0;

  TGRid  srcIDs[100];
  TGRid *srcID;
  IGRint srcCnt;
  
  // Init
  *occPath = 0;
  *pwdPath = 0;

  // Say hi
  traceFlag = VDdbgGetTraceFlag(VDEFP_TRACE_PLACE_MACRO);
  if (traceFlag) {
    if (macName) printf(">>> %s %s\n",fn,macName);
    else         printf(">>> %s NO MACRO NAME\n",fn);
  }

  // Arg check
  VDASSERTW(macOE);
  if (macOE == NULL) goto wrapup;
  gr$get_module_env(buffer = &macOE->mod_env);
  macOE->obj_id.osnum = macOE->mod_env.md_id.osnum;
  macOE->obj_id.objid = NULL_OBJID;
  VDASSERTW(macName && *macName);
    
  // Attach library if necessary
  if ((libName != NULL) && (*libName != 0)) {
    ac$construct_path(mode = AC_ADD_PATH, name = libName);
  }

  // Source stuff
  if (tplCnt > 100) tplCnt = 100;
  for(srcCnt = 0; srcCnt < tplCnt; srcCnt++) {
    srcID = &srcIDs[srcCnt];
    srcID->osnum = macOE->obj_id.osnum;
    srcID->objid = NULL_OBJID;

    sts = as$make_source(go_grid =  tplOEs[srcCnt].obj_id,
                         mod_env = &tplOEs[srcCnt].mod_env,
                         as_grid =  srcID);

    if ((!(sts & 1)) || (srcID->objid == NULL_OBJID)) {
      printf("Problem sourcing parent in VDbufPlaceMacro %s\n",macName);
      vdobj$Print(objOE = &tplOEs[srcCnt]);
      goto wrapup;
    }
  }

  /* Construct nci_macro */
  om$construct(classid = OPP_VDbufMacro_class_id,
               osnum   =  macOE->obj_id.osnum,
               p_objid = &macOE->obj_id.objid);

  if (macOE->obj_id.objid == NULL_OBJID) goto wrapup;

  /* Save the data */
  if (data)   VDbufSetCompressedTxtData(macOE,data);
  if (treeID) VDbufSetDomTree          (macOE,treeID);
  
  // Symbology
  VDahGetActiveSymbology(&symb1);
  VDahGetActiveSymbology(&symb2);

  // Adjust symbology based on macro name
  if (!strcmp(macName,"unw_spades")) {
    symb2.level = 768;
    symb2.display_attr.color  = 3;
    symb2.display_attr.weight = 2;
    symb2.display_attr.style  = 0;
    VDahSetActiveSymbology(&symb2);
    symbFlag = 1;
  }
  if (!strcmp(macName,"xml_piece")) {
    symb2.level = 768;
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

  // Set the name
  if (name) sprintf(occWork,"%s_%s",macName,name);
  else      strcpy (occWork,macName);  
  VDahGetNextOccName(occWork,NULL,occName);
  om$send(msg = message GRgraphics.GRputname(&msg,occName),
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
    printf("<<< %s %d\n",fn,retFlag);
  }

  return retFlag;
}

/* -------------------------------------------------
 * Place a macro using semi-smart default paths
 */
IGRstat VDbufPlaceMacro(IGRchar    *libName,
			IGRchar    *macName,
			IGRchar    *name,
			IGRchar    *data,
			TGRid      *treeID,
			TGRobj_env *macOE)
{
  VDASSERT_FN("VDbufPlaceMacro");
  
  IGRstat retFlag = 0;
  IGRstat sts,msg;
  IGRint  suc;

  IGRchar occName[128];
  IGRchar occWork[128];
  
  IGRchar occPath[DI_PATH_MAX];
  IGRchar pwdPath[DI_PATH_MAX];
  
  TGRsymbology symb1,symb2;
  IGRint       symbFlag = 0;
  
  // Init
  *occPath = 0;
  *pwdPath = 0;

  // Say hi
  traceFlag = VDdbgGetTraceFlag(VDEFP_TRACE_PLACE_MACRO);
  if (traceFlag) {
    if (macName) printf(">>> %s %s\n",fn,macName);
    else         printf(">>> %s NO MACRO NAME\n",fn);
  }

  // Arg check
  VDASSERTW(macOE);
  if (macOE == NULL) goto wrapup;
  gr$get_module_env(buffer = &macOE->mod_env);
  macOE->obj_id.osnum = macOE->mod_env.md_id.osnum;
  macOE->obj_id.objid = NULL_OBJID;
  VDASSERTW(macName && *macName);
    
  // Attach library if necessary
  if ((libName != NULL) && (*libName != 0)) {
    ac$construct_path(mode = AC_ADD_PATH, name = libName);
  }

  /* Construct nci_macro */
  om$construct(classid = OPP_VDbufMacro_class_id,
               osnum   =  macOE->obj_id.osnum,
               p_objid = &macOE->obj_id.objid);

  if (macOE->obj_id.objid == NULL_OBJID) goto wrapup;

  /* Save the data */
  if (data)   VDbufSetCompressedTxtData(macOE,data);
  if (treeID) VDbufSetDomTree          (macOE,treeID);
  
  // Symbology
  VDahGetActiveSymbology(&symb1);
  VDahGetActiveSymbology(&symb2);

  // Adjust symbology based on macro name
  if (!strcmp(macName,"unw_spades")) {
    symb2.level = 768;
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

  // Set the name
  if (name) sprintf(occWork,"%s_%s",macName,name);
  else      strcpy (occWork,macName);  
  VDahGetNextOccName(occWork,NULL,occName);
  om$send(msg = message GRgraphics.GRputname(&msg,occName),
	  senderid = NULL_OBJID,
	  targetid = macOE->obj_id.objid,
	  targetos = macOE->obj_id.osnum);

  /* Create macro occurence */
  sts = om$send(msg = message ci_macro.
                init(&suc,0,macName,0,NULL,NULL,&macOE->mod_env),
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
    printf("<<< %s %d\n",fn,retFlag);
  }

  return retFlag;
}

extern VDclassid OPP_VDdrwGm_class_id;
extern VDclassid OPP_ACrg_collect_class_id;
extern VDclassid OPP_GRgrgrp_class_id;
extern VDclassid OPP_GRgrset_class_id;

from ACcpx       import ACload_macro;
from GRconnector import GRrigidconn;
from GRgraphics  import GRconstruct;

/* -----------------------------------------------
 * Just for grins, try using a graphical group
 */
IGRstat VDbufCreateGraphicGroup(TGRmd_env *env, TGRid *groupID)
{
  VDASSERT_FN(" VDbufCreateGraphicGroup");
  
  IGRstat retFlag = 0;
  IGRstat msg;

  TGRvg_construct cnst_list;
  
  // Arg check
  VDASSERTW(groupID);
  groupID->objid = NULL_OBJID;
  groupID->osnum = env->md_id.osnum;

  // Setup construction props
  cnst_list.env_info   = env;
  cnst_list.properties = GRIS_NEW ;
  cnst_list.msg        = &msg;
  cnst_list.newflag    = FALSE;
  cnst_list.name       = NULL;
  cnst_list.geometry   = NULL;
  cnst_list.display    = NULL;
  cnst_list.class_attr = NULL;

  // And do it
  om$construct(classid = OPP_GRgrgrp_class_id,
	       msg 	= message GRgraphics.GRconstruct( &cnst_list ),
	       p_objid = &groupID->objid,
	       osnum	= groupID->osnum );
  VDASSERTW(groupID->objid != NULL_OBJID);
  
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * The feet of the buf macros will quite often be
 * generic geometry collectors so put a few interface routines here
 *
 * This routine create a geometry object
 */
IGRstat VDbufCreateDrawingGeometry(VDosnum osnum, IGRint size, TGRid *drwGmID)
{
  VDASSERT_FN(" VDbufCreateDrawingGeometry");
  
  IGRstat retFlag = 0;
  IGRstat msg;
  
  IGRchar name[128];
  
  TGRid   defID;
  
  // Just use the current one for now
  if (osnum == OM_K_NOT_AN_OS) VDosGetCurrentOS(&osnum);
  
  // Arg check
  VDASSERTW(drwGmID);
  drwGmID->objid = NULL_OBJID;
  drwGmID->osnum = osnum;
  
  // Get the macro to use
  VD_drwGeomGiveMacroBySize(&msg,size,name);
  VDASSERTW(*name);
  
  // Need the def macro
  defID.objid = NULL_OBJID;
  ac$find_macro_defn(action           = ACfind_load,
		     macro_name       = name,
		     p_macro_defn_id  = &defID);
  VDASSERTW(defID.objid != NULL_OBJID);
  
  // Construct and load
  om$construct(classid	= OPP_VDdrwGm_class_id,
	       osnum    =  drwGmID->osnum,
	       p_objid  = &drwGmID->objid,
	       msg	= message ACcpx.ACload_macro(defID));
  VDASSERTW(drwGmID->objid != NULL_OBJID);
  
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Easy way to make a collector
 */
IGRstat VDbufCreateCollector(VDosnum osnum, TGRid *colID)
{
  VDASSERT_FN(" VDbufCreateCollector");
  
  IGRstat retFlag = 0;
  IGRstat msg;
  
  // Just use the current one for now
  if (osnum == OM_K_NOT_AN_OS) VDosGetCurrentOS(&osnum);
  
  // Arg check
  VDASSERTW(colID);
  colID->objid = NULL_OBJID;
  colID->osnum = osnum;
  
  
  // Construct and load
  om$construct(classid	= OPP_ACrg_collect_class_id,
	       osnum    =  colID->osnum,
	       p_objid  = &colID->objid);
  VDASSERTW(colID->objid != NULL_OBJID);
  
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Connects object to the geometry object
 */
IGRstat VDbufAddGeometryChild(TGRid *drwGmID, TGRid *childID)
{
  VDASSERT_FN("VDbufAddGeometryChild");
  IGRstat retFlag = 0;
  IGRstat msg,sts;
  IGRstat max = OM_K_MAXINT;
  
  // Arg check
  VDASSERTW(drwGmID && drwGmID->objid != NULL_OBJID);
  VDASSERTW(childID && childID->objid != NULL_OBJID);
  
  // Send a rigid connect message
  sts = om$send(msg = message GRconnector.GRrigidconn(&msg,drwGmID,&max),
		senderid = NULL_OBJID,
		targetid = childID->objid,
		targetos = childID->osnum);
  if (!(sts & msg & 1)) {
    VDlogPrintFmt   (VDLOG_ERROR,1,"*** GRconnector.GRrigidconn failed in %s",fn);
    VDlogPrintObject(VDLOG_ERROR,1,"    Geom  ",NULL,drwGmID);
    VDlogPrintObject(VDLOG_ERROR,1,"    Child ",NULL,childID);
    goto wrapup;
  }
  
  // Donw
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

end implementation Root;



