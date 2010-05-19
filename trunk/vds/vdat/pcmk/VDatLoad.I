/* $Id: VDatLoad.I,v 1.1 2001/01/11 20:54:46 art Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdat/pcmk/VDatInfo.I
 *
 * Description: Piece Mark Processing
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDatLoad.I,v $
 *      Revision 1.1  2001/01/11 20:54:46  art
 *      sp merge
 *
# Revision 1.1  2000/11/27  19:35:18  pinnacle
# ah
#
# Revision 1.1  2000/06/27  17:34:38  pinnacle
# ah
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 03/28/00  ah      Creation
 ***************************************************************************/

class implementation Root;

#include "VDtypedef.h"
#include "VDatPcmk.h"

#include "VDsa.h"
#include "VDmem.h"
#include "VDobj.h"
#include "VDdir.h"
#include "VDchn.h"

#include "VDassert.h"

VDASSERT_FFN("vdat/pcmk/VDatInfo.I");

from NDmacro    import ACtest_consumed;
from GRgraphics import GRgetname;

/* -------------------------------------------------------------
 * Finds the child who consumed the parent.
 *
 * Will only work if the child is in the same file as the parent.
 *
 * The basic idea is that the GRgetname of the child will match that
 * of it's consumed parent
 */
IGRstar VDobjGetConsumingChild(TGRobj_env *parentOE, TGRobj_env *childOE)
{
  VDASSERT_FN("VDobjGetConsumingChild");
  IGRstat retFlag = 0;
  IGRstat sts,msg;
  
  IGRchar parentPath[DI_PATH_MAX];
  IGRchar childPath [DI_PATH_MAX];
  
  TGRid   childID;
  IGRint  i;

  TGRobj_env parentOEx;
  
  // Arg check
  VDASSERTW(parentOE);
  VDASSERTW(childOE);  
  *childOE = *parentOE;
  
  // Verify parent is consumed
  msg = 0;
  sts = om$send(msg = message NDmacro.ACtest_consumed(&msg),
		senderid = NULL_OBJID,
		targetid = parentOE->obj_id.objid,
		targetos = parentOE->obj_id.osnum);

  // If not consumed then just return itself
  if (!(sts & msg & 1)) {
    retFlag = 1;
    goto wrapup;
  }
  
  // Get the parent's path
  *parentPath = 0;
  om$send(msg = message GRgraphics.GRgetname(&msg,parentPath),
	  senderid = NULL_OBJID,
	  targetid = parentOE->obj_id.objid,
	  targetos = parentOE->obj_id.osnum);

  // Without a path, this won't work
  if (*parentPath == 0) {
    goto wrapup;
  }
  
  // Cycle through kids
  for(i = 0; VDahGetChnObject(&parentOE->obj_id,"NDchildren.children",i,&childID); i++) {
    *childPath = 0;

    om$send(msg = message GRgraphics.GRgetname(&msg,childPath),
	    senderid = NULL_OBJID,
	    targetid = childID.objid,
	    targetos = childID.osnum);
    
    if (!strcmp(parentPath,childPath)) {
      
      // Got it
      childOE->obj_id = childID;
      
      // Recurse incase child itself is consumed
      parentOEx = *childOE;
      return VDobjGetConsumingChild(&parentOEx,childOE);
      
    }
    
  }
  
  // Child not found, just return itself

wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Given a full path (including file name)
 * Return the oe
 */
IGRstat VDobjGetObjectByPath(IGRchar *path, TGRobj_env *a_objOE)
{
  VDASSERT_FN("VDobjGetObjectByPath");

  IGRstat retFlag = 0;
  VDosnum osnum;
  IGRchar osFileName[128];
  IGRchar newPath[DI_PATH_MAX];

  TGRobj_env objOE;
  TGRobj_env childOE;
  
  IGRchar *p;
  
  // Arg check
  VDASSERTW(a_objOE);
  a_objOE->obj_id.objid = NULL_OBJID;
  VDASSERTW(path);
  if (*path == 0) goto wrapup;
  
  // First check in local file
  di$translate(objname =  path,
	       p_objid = &objOE.obj_id.objid,
	       p_osnum = &objOE.obj_id.osnum);

  if (objOE.obj_id.objid != NULL_OBJID) goto got_it;
  
  // Check in reference file
  ex$get_cur_mod  (osnum = &osnum);
  di$give_pathname(osnum =  osnum, pathname = osFileName);

  // Get just the file
  p = strrchr(osFileName,':');
  if (p) p++;
  else   p = osFileName;
  
  sprintf(newPath,":%s:ref%s",p,path);
  
  di$translate(objname =  newPath,
	       p_objid = &objOE.obj_id.objid,
	       p_osnum = &objOE.obj_id.osnum);

  if (objOE.obj_id.objid != NULL_OBJID) goto got_it;
  
  // Give up
  // printf("*** Could not find %s\n",path);
  goto wrapup;
  
  // -----------------------------------------------
  // Got a new piece so attach it
got_it:

  // Matrix should not be really important (I hope)
  gr$get_module_env(buffer = &objOE.mod_env);

  objOE.mod_env.md_id.osnum = objOE.obj_id.osnum;
  
  ex$get_modid(mod_osnum =  objOE.mod_env.md_id.osnum, 
	       mod_id    = &objOE.mod_env.md_id.objid);

  // This guy could be consumed
  VDobjGetConsumingChild(&objOE,&childOE);

  // Store it
  *a_objOE = childOE;
  
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Load info previously dumped out
 */
IGRstat VDatLinkPcmkInfoToSet(TVDatPcmkInfo *info, TGRid *setID)
{
  VDASSERT_FN("VDatLinkPcmkInfoToSet");
  IGRstat retFlag = 0;

  TGRobj_env pieceOE;
  TGRid leafID;
  
  TVDatPcmkLeafInfo *leaf;
  
  // Arg check
  VDASSERTW(setID);
  VDASSERTW(info->leaf);
  leaf = info->leaf;

  // Reset some stuff
  leaf->leafID.objid         = NULL_OBJID;
  leaf->pieceOE.obj_id.objid = NULL_OBJID;

  // Get the current pieceOE
  VDobjGetObjectByPath(leaf->piecePath, &pieceOE);
  if (pieceOE.obj_id.objid == NULL_OBJID) {
    printf("Could not find piece %s\n",leaf->piecePath);
    goto wrapup;
  }
  leaf->pieceOE = pieceOE;
  //printf("Found %s\n",leaf->piecePath);
  //vdobj$Print(objOE = &pieceOE);
  
  // Now for the leaf
  VDatGetObjectLeaf(&pieceOE, setID, &leafID);
  if (leafID.objid == NULL_OBJID) {
    printf("Could not find leaf object for\n");
    vdobj$Print(objOE = &pieceOE);
    goto wrapup;
  }
  leaf->leafID = leafID;
  // vdobj$Print(objID = &leafID);
  
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Load info previously dumped out
 */
IGRstat VDatLoadPcmksFromXmlFile(IGRchar *setName)
{
  VDASSERT_FN("VDatLoadPcmksFromXmlFile");
  
  IGRstat retFlag = 0;
  
  TVDatPcmkInfos infos;
  TVDatPcmkInfo *info;

  IGRchar fileName[256];
  IGRchar buf[256];
  IGRchar *p;
  
  IGRint i,cnt;
  
  TGRid setID;
  
  // Init
  memset(&infos,0,sizeof(TVDatPcmkInfos));
   
  // Make the file name
  sprintf(fileName,"%s_pcmk.xml",setName);

  // See how many are needed
  VDatGetNumLeafsInXmlFile(fileName,&cnt);
  if (cnt == 0) {
    sprintf(buf,"No leafs in %s!",fileName);
    UI_status(buf);
    goto wrapup;
  }
  sprintf(buf,"Loading %d pieces from %s...",cnt,fileName);
  UI_status(buf);
  
  // Pointer list
  infos.infos = calloc(cnt,sizeof(TVDatPcmkInfo));
  VDASSERTW(infos.infos);
  
  // Leaf list
  infos.leafs = calloc(cnt,sizeof(TVDatPcmkLeafInfo));
  VDASSERTW(infos.leafs);

  // Attr list
  infos.attrs = calloc(cnt,sizeof(TVDatPcmkAttrInfo));
  VDASSERTW(infos.attrs);
   
  // Attach leafs,attrs to main list
  for(i = 0; i < cnt; i++) {

    infos.infos[i].leaf = &infos.leafs[i];
    infos.infos[i].attr = &infos.attrs[i];

    // Init some stuff to be safe
    infos.leafs[i].leafID.objid         = NULL_OBJID;
    infos.leafs[i].pieceOE.obj_id.objid = NULL_OBJID;
    infos.leafs[i].pieceName = infos.leafs[i].piecePath;

  }
  infos.max = cnt;
  infos.cnt = 0;

  // Load em up
  VDatLoadPcmkInfosFromXmlFile(fileName,&infos);

  // Link pcmk infos to current file
  VDatGetSetByTypeName("StagingTree",setName,&setID);
  if (setID.objid == NULL_OBJID) {
    printf("*** Unable to get set for %s\n",setName);
    goto wrapup;
  }

  // Cycle through
  for(i = 0; i < infos.cnt; i++) {

    // Find piece and leaf obejcts
    VDatLinkPcmkInfoToSet(&infos.infos[i],&setID);

    // Set the not like flag
    VDatGetPcmkNotLikeInfo(&infos.infos[i]);

  }
  
  // Done
  sprintf(buf,"Loaded %d pieces from %s",cnt,fileName);
  UI_status(buf);
  retFlag = 1;
  
 wrapup:

  // Free the stuff
  VDatFreePcmkInfos(&infos);

  return retFlag;
}

/* -----------------------------------------------
 * Load info previously dumped out
 */
IGRstat VDatLoadPcmks(IGRchar *setName)
{
  IGRstat retFlag = 0;
  
  TVDatPcmkInfos infos;
  TVDatPcmkInfo *info;

  FILE   *file = NULL;
  IGRchar buf[256];
  IGRchar *p;
  
  IGRint i;
  
  // Init
  memset(&infos,0,sizeof(TVDatPcmkInfos));
   
  // Open files
  sprintf(buf,"%s_pcmk.dat",setName);
  file = fopen(buf,"rb");
  if (file == NULL) {
    printf("*** Problem opening %s for writing\n",buf);
    goto wrapup;
  }
  // Get the count
  fread(&infos.cnt,sizeof(IGRint),1,file);
  if (infos.cnt < 1) {
    UI_status("No records in dump file");
    fclose(file);
    goto wrapup;
  }
  sprintf(buf,"Reading %d items ...",infos.cnt);
  UI_status(buf);
  
  // Pointer list
  infos.infos = calloc(infos.cnt,sizeof(TVDatPcmkInfo));
  if (infos.infos == NULL) {
    printf("*** Problem allocating list of piece marks\n");
    goto wrapup;
  }
  
  // Leaf list
  infos.leafs = calloc(infos.cnt,sizeof(TVDatPcmkLeafInfo));
  if (infos.leafs == NULL) {
    printf("*** Problem allocating list of leaf piece marks\n");
    goto wrapup;
  }

  // Attr list
  infos.attrs = calloc(infos.cnt,sizeof(TVDatPcmkAttrInfo));
  if (infos.attrs == NULL) {
    printf("*** Problem allocating list of attr piece marks\n");
    goto wrapup;
  }
 
  // Attach leafs,attrs to main list
  for(i = 0; i < infos.cnt; i++) {
    infos.infos[i].leaf = &infos.leafs[i];
    infos.infos[i].attr = &infos.attrs[i];
  }
  infos.max = infos.cnt;
  
  // Cycle through
  for(i = 0; i < infos.cnt; i++) {

    info = &infos.infos[i];

    fread(info->leaf,sizeof(TVDatPcmkLeafInfo),1,file);
    fread(info->attr,sizeof(TVDatPcmkAttrInfo),1,file);

    p = strrchr(info->leaf->piecePath,':');
    if (p) info->leaf->pieceName = p;
    else   info->leaf->pieceName = info->leaf->piecePath;
    
  }

  // Close up
  fclose(file); file = NULL;
  sprintf(buf,"Read %d items",infos.cnt);
  UI_status(buf);
  
  // Process
  // VDatTestCriteria(&infos);
  VDatWritePcmkInfosToXmlFile(setName,&infos);
  
  // Done  
  retFlag = 1;
  
 wrapup:

  // Close up
  if (file) fclose(file);
  
  // Free the stuff
  VDatFreePcmkInfos(&infos);
  
  return retFlag;
}


end implementation Root;
