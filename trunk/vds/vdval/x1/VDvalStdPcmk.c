/* $Id: VDvalStdPcmk.c,v 1.3 2002/02/27 16:38:29 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdval/x1/VDvalStdPcmk.c
 *
 * Description:	Standard Piece Mark caching
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDvalStdPcmk.c,v $
 *      Revision 1.3  2002/02/27 16:38:29  ahundiak
 *      ah
 *
 *      Revision 1.2  2001/11/16 14:58:52  ahundiak
 *      ah
 *
 *      Revision 1.1  2001/11/09 14:59:55  ahundiak
 *      ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 05/21/01  ah      Creation
 ***************************************************************************/
#include "VDtypedefc.h"
#include "VDassert.h"
#include "VDlog.h"
#include "VDrisc.h"
#include "VDtest.h"
#include "VDxdom.h"
#include "VDctx.h"
#include "VDval.h"

#include "glib.h"

VDASSERT_FFN("VDvalStdPcmk.c");

typedef struct 
{
  TGRid rdbPcmkIDs;
  TGRid rdbGeomIDs;
  TGRid xmlPcmkIDs;
  TGRid xmlGeomIDs;

  TGRid missingIDs;
  
  TVDctxNodeList xmlPcmkList1; // Geometry
  TVDctxNodeList xmlPcmkList2; // Piece mark

  TVDctxNodeList xmlGeomList;
  
  TGRid findID;
} Tinfo;

static Tinfo *s_info;

/* -----------------------------------------------
 * Return the master data structure
 * Creating and initializing if required
 */
static Tinfo *getInfo()
{
  if (s_info) return s_info;

  s_info = g_new0(Tinfo,1);

  s_info->rdbPcmkIDs.objid = NULL_OBJID;
  s_info->rdbGeomIDs.objid = NULL_OBJID;
  s_info->xmlPcmkIDs.objid = NULL_OBJID;
  s_info->xmlGeomIDs.objid = NULL_OBJID;
  s_info->missingIDs.objid = NULL_OBJID;
  
  VDctxCreateXdomTree("find",NULL,&s_info->findID);
  
  return s_info;
}

/* -----------------------------------------------
 * Empty the cache
 */
void VDvalDeleteStdPcmk2Cache()
{
  // Ignore if no cache
  if (s_info == NULL) goto wrapup;

  // Clear the lists
  VDctxFreeNodeList(&s_info->xmlPcmkList1);
  VDctxFreeNodeList(&s_info->xmlPcmkList2);
  VDctxFreeNodeList(&s_info->xmlGeomList);
  
  // Delete the nodes
  VDctxDeleteNode(&s_info->findID);
  VDctxDeleteNode(&s_info->rdbPcmkIDs);
  VDctxDeleteNode(&s_info->rdbGeomIDs);
  VDctxDeleteNode(&s_info->xmlPcmkIDs);
  VDctxDeleteNode(&s_info->xmlGeomIDs);
  VDctxDeleteNode(&s_info->missingIDs);
  
 wrapup:
  return;
}

/* -----------------------------------------------
 * Get the tree, creating if necessary
 */
static void getRdbPcmkIDs(TGRid *rdbPcmkIDs)
{
  Tinfo *info = getInfo();
  
  if (info->rdbPcmkIDs.objid == NULL_OBJID) {
    VDctxCreateXdomTree("std_pcmks",NULL,&info->rdbPcmkIDs);
  }
  *rdbPcmkIDs = info->rdbPcmkIDs;

 wrapup:
  return;
}
/* -----------------------------------------------
 * Get the tree, creating if necessary
 */
static void getRdbGeomIDs(TGRid *rdbGeomIDs)
{
  Tinfo *info = getInfo();

  if (info->rdbGeomIDs.objid == NULL_OBJID) {
    VDctxCreateXdomTree("std_geoms",NULL,&info->rdbGeomIDs);
  }
  *rdbGeomIDs = info->rdbGeomIDs;

 wrapup:
  return;
}

/* -----------------------------------------------
 * Broken up geometry keys
 */
int VDvalStdPcmk2CompareGeom(const void *p1, const void *p2)
{
  TGRid *info1ID = (TGRid*)p1;
  TGRid *info2ID = (TGRid*)p2;

  IGRchab buf1,buf2;
  
  IGRint cmp;

  // Macro
  VDctxGetTxtAtr(info1ID,VDCTX_STD_PCMK_ATR_MACRO,buf1);
  VDctxGetTxtAtr(info2ID,VDCTX_STD_PCMK_ATR_MACRO,buf2);
  cmp = strcmp(buf1,buf2);
  if (cmp) return cmp;

  // Family 1
  VDctxGetTxtAtr(info1ID,VDCTX_STD_PCMK_ATR_FAM1,buf1);
  VDctxGetTxtAtr(info2ID,VDCTX_STD_PCMK_ATR_FAM1,buf2);
  cmp = strcmp(buf1,buf2);
  if (cmp) return cmp;

  // Part 1
  VDctxGetTxtAtr(info1ID,VDCTX_STD_PCMK_ATR_PART1,buf1);
  VDctxGetTxtAtr(info2ID,VDCTX_STD_PCMK_ATR_PART1,buf2);
  cmp = strcmp(buf1,buf2);
  if (cmp) return cmp;

  // Family 2
  VDctxGetTxtAtr(info1ID,VDCTX_STD_PCMK_ATR_FAM2,buf1);
  VDctxGetTxtAtr(info2ID,VDCTX_STD_PCMK_ATR_FAM2,buf2);
  cmp = strcmp(buf1,buf2);
  if (cmp) return cmp;

  // Part 2
  VDctxGetTxtAtr(info1ID,VDCTX_STD_PCMK_ATR_PART2,buf1);
  VDctxGetTxtAtr(info2ID,VDCTX_STD_PCMK_ATR_PART2,buf2);
  cmp = strcmp(buf1,buf2);
  if (cmp) return cmp;
  
  return 0;
}

/* -----------------------------------------------
 * Broken up geometry keys
 */
int VDvalStdPcmk2CompareGeomGradeThick(const void *p1, const void *p2)
{
  TGRid *info1ID = (TGRid*)p1;
  TGRid *info2ID = (TGRid*)p2;

  IGRchab buf1,buf2;
  
  IGRint cmp;

  // Geom
  cmp = VDvalStdPcmk2CompareGeom(p1,p2);
  if (cmp) return cmp;
  
  // Grade
  VDctxGetTxtAtr(info1ID,VDCTX_STD_PCMK_ATR_GRADE,buf1);
  VDctxGetTxtAtr(info2ID,VDCTX_STD_PCMK_ATR_GRADE,buf2);
  cmp = strcmp(buf1,buf2);
  if (cmp) return cmp;

  // Thickness
  VDctxGetTxtAtr(info1ID,VDCTX_STD_PCMK_ATR_THICK,buf1);
  VDctxGetTxtAtr(info2ID,VDCTX_STD_PCMK_ATR_THICK,buf2);
  cmp = strcmp(buf1,buf2);
  if (cmp) return cmp;
  
  return 0;
}

/* -----------------------------------------------
 * Just the piece mark
 */
int VDvalStdPcmk2ComparePcmk(const void *p1, const void *p2)
{
  TGRid *info1ID = (TGRid*)p1;
  TGRid *info2ID = (TGRid*)p2;

  IGRchab buf1, buf2;
  IGRint  pcmk1,pcmk2;

  // Pcmk
  VDctxGetTxtAtr(info1ID,VDCTX_STD_PCMK_ATR_PCMK,buf1);
  VDctxGetTxtAtr(info2ID,VDCTX_STD_PCMK_ATR_PCMK,buf2);
  pcmk1 = atoi(buf1);
  pcmk2 = atoi(buf2);
  if (pcmk1 < pcmk2) return -1;
  if (pcmk1 > pcmk2) return  1;
    
  return 0;
}

/* -----------------------------------------------
 * Init the xml tree for pcmks
 */
static void initXmlPcmks()
{
  IGRchab path;

  Tinfo *info = getInfo();
  
  // See if already done
  if (info->xmlPcmkIDs.objid != NULL_OBJID) return;

  // Find the file
  VDsysFindFile("config/xml","std_pcmk2.xml",path);
  if (*path == 0) goto wrapup;
  
  // Make the tree
  VDxdomCreateTreeFromXmlFile(path,&info->xmlPcmkIDs);

  // Fill the list
  VDctxGetNodeListByType(&info->xmlPcmkIDs,"std_key",&info->xmlPcmkList1);
  VDctxGetNodeListByType(&info->xmlPcmkIDs,"std_key",&info->xmlPcmkList2);
  if (info->xmlPcmkList1.cnt < 1) goto wrapup;
  
  // Sort em
  VDctxSortNodeList(&info->xmlPcmkList1,VDvalStdPcmk2CompareGeomGradeThick);
  VDctxSortNodeList(&info->xmlPcmkList2,VDvalStdPcmk2ComparePcmk);

  // Done
 wrapup:
  return;
}
/* -----------------------------------------------
 * Init the xml tree for geometry
 */
static void initXmlGeoms()
{
  IGRchab path;

  Tinfo *info = getInfo();
  
  // See if already done
  if (info->xmlGeomIDs.objid != NULL_OBJID) return;

  // Find the file
  VDsysFindFile("config/xml","std_geom2.xml",path);
  if (*path == 0) goto wrapup;
  
  // Make the tree
  VDxdomCreateTreeFromXmlFile(path,&info->xmlGeomIDs);

  // Fill the list
  VDctxGetNodeListByType(&info->xmlGeomIDs,"std_info",&info->xmlGeomList);
  if (info->xmlGeomList.cnt < 1) goto wrapup;
  
  // Sort em
  VDctxSortNodeList(&info->xmlGeomList,VDvalStdPcmk2CompareGeom);

  // Done
 wrapup:
  return;
}

/* -----------------------------------------------
 * Find the piece mark for combination
 * of key,grade and thickness
 *
 * By cechking xml file
 */

static void appAtr(TGRid *findID, IGRchar *buf, IGRchar *name)
{
  IGRchar *p;
  IGRint flag = 0;

  // Check for last one
  if (strlen(buf) < 18) {
    VDctxAppTxtAtr(findID,name,buf);
    goto wrapup;
  }
  for(p = buf + 17; (p >= buf) && (*p == ' '); p--);
  *(p+1) = 0;

  VDctxAppTxtAtr(findID,name,buf);
  
  strcpy(buf,buf+18);
  
 wrapup:
  return;
  
}
/* -----------------------------------------------
 * Break a standard geom key into it's parts
 * then add them to the node
 */
void VDvalSaveStdGeomKeyToNode(IGRchar *geom_key, TGRid *infoID)
{
  VDASSERT_FN("VDvalSaveStdGeomKeyToNode");
  
  IGRchab buf;

  // Arg check
  VDASSERTW(geom_key);
  VDASSERTW(infoID && infoID->objid != NULL_OBJID);

  // Break into 5 attributes
  strcpy(buf,geom_key);
  appAtr(infoID,buf,VDCTX_STD_PCMK_ATR_MACRO);
  appAtr(infoID,buf,VDCTX_STD_PCMK_ATR_FAM1);
  appAtr(infoID,buf,VDCTX_STD_PCMK_ATR_PART1);
  appAtr(infoID,buf,VDCTX_STD_PCMK_ATR_FAM2);
  appAtr(infoID,buf,VDCTX_STD_PCMK_ATR_PART2);
   
 wrapup:
  return;
}

/* -----------------------------------------------
 * Make a geom key
 */
void VDvalMakeStdGeomKeyFromStuff(IGRchar *macro,
				  IGRchar *fam1,
				  IGRchar *part1,
				  IGRchar *fam2,
				  IGRchar *part2, 
				  IGRchar *geom_key)
{
  VDASSERT_FN("VDvalMakeStdGeomKeyFromStuff");

  // Arg check
  VDASSERTW(geom_key); *geom_key = 0;
  VDASSERTW(macro && fam1 && part1 && fam2 && part2);

  // Add a trailing character so the keys are always the same width
  // It seems that sometimes the ris query results will drop trailing blanks
  sprintf(geom_key,"%-16s%-16s%-16s%-16s%-16s:",macro,fam1,part1,fam2,part2);
 
 wrapup:
  return;
}
void VDvalMakeStdGeomKeyFromNode(TGRid *infoID, IGRchar *geom_key)
{
  VDASSERT_FN("VDvalMakeStdGeomKey");
  
  IGRchab macro,fam1,fam2,part1,part2;

  // Arg check
  VDASSERTW(geom_key); *geom_key = 0;
  VDASSERTW(infoID && infoID->objid != NULL_OBJID);
  
  VDctxGetTxtAtr(infoID,VDCTX_STD_PCMK_ATR_MACRO,macro);
  VDctxGetTxtAtr(infoID,VDCTX_STD_PCMK_ATR_FAM1, fam1);
  VDctxGetTxtAtr(infoID,VDCTX_STD_PCMK_ATR_PART1,part1);
  VDctxGetTxtAtr(infoID,VDCTX_STD_PCMK_ATR_FAM2, fam2);
  VDctxGetTxtAtr(infoID,VDCTX_STD_PCMK_ATR_PART2,part2);

  VDvalMakeStdGeomKeyFromStuff(macro,fam1,part1,fam2,part2,geom_key);
 
 wrapup:
  return;
}

/* -----------------------------------------------
 * Find the pcmk for a given combo
 */
void VDvalQryXmlStdPcmk2ByGeom(IGRchar *geom_key, IGRchar *grade, IGRchar *thick, IGRchar *pcmk)
{
  VDASSERT_FN("VDvalXmlStdPcmk2");
  
  Tinfo *info = getInfo();
  
  TGRid *foundID;
  
  // Arg check
  VDASSERTW(pcmk); *pcmk = 0;
  VDASSERTW(geom_key && *geom_key);
  VDASSERTW(grade    && *grade);
  VDASSERTW(thick    && *thick);

  // Make sure the tree is initialized
  initXmlPcmks();
  if (info->xmlPcmkList1.cnt < 1) goto wrapup;
  
  // Parse the geom key to setup the search
  VDvalSaveStdGeomKeyToNode(geom_key,&info->findID);
  
  VDctxAppTxtAtr(&info->findID,VDCTX_STD_PCMK_ATR_GRADE,grade);
  VDctxAppTxtAtr(&info->findID,VDCTX_STD_PCMK_ATR_THICK,thick);
  
  foundID = VDctxSearchNodeList(&info->findID,&info->xmlPcmkList1,VDvalStdPcmk2CompareGeomGradeThick);
  if (foundID == NULL) goto wrapup;
  
  VDctxGetTxtAtr(foundID,VDCTX_STD_PCMK_ATR_PCMK,pcmk);
  
 wrapup:
  return;
}

/* -----------------------------------------------
 * Lookup by piece mark in order to cross
 * to the geom table or to verify the piece mark
 */
void VDvalQryXmlStdPcmk2ByPcmk(IGRchar *pcmk, TGRid *pcmkID)
{
  VDASSERT_FN("VDvalQryXmlStdPcmk2ByPcmk");

  IGRstat sts;
  
  Tinfo *info = getInfo();

  IGRchab buf;
  
  TGRid *foundID;

  IGRchab  geom_key;
  
  // Arg check
  VDASSERTW(pcmkID); pcmkID->objid = NULL_OBJID;
  VDASSERTW(pcmk && *pcmk);

  // Make sure the tree is initialized
  initXmlPcmks();
  if (info->xmlPcmkList2.cnt < 1) goto wrapup;
  
  // Search
  VDctxAppTxtAtr(&info->findID,VDCTX_STD_PCMK_ATR_PCMK,pcmk);
  
  foundID = VDctxSearchNodeList(&info->findID,&info->xmlPcmkList2,VDvalStdPcmk2ComparePcmk);
  if (foundID == NULL) goto wrapup;
  *pcmkID = *foundID;
  
  // Make a geometry key
  sts = VDctxHasAttribute(foundID,VDCTX_STD_PCMK_ATR_GEOM_KEY);
  if (!(sts & 1)) {
    VDvalMakeStdGeomKeyFromNode(foundID,geom_key);
    VDctxAppTxtAtr(foundID,VDCTX_STD_PCMK_ATR_GEOM_KEY,geom_key);
  }
    
 wrapup:
  return;
}

/* -----------------------------------------------
 * Get the geometry from the geometry database
 */
void VDvalQryXmlStdGeom2(IGRchar *geom_key, TGRid *geomID)
{
  VDASSERT_FN("VDvalQryXmlStdGeom2");
  
  Tinfo *info = getInfo();

  IGRchab buf;
  
  TGRid *foundID;
  
  // Arg check
  VDASSERTW(geomID); geomID->objid = NULL_OBJID;
  VDASSERTW(geom_key && *geom_key);

  // Make sure the tree is initialized
  initXmlGeoms();
  if (info->xmlGeomList.cnt < 1) goto wrapup;
  
  // Parse the geom key to setup the search
  VDvalSaveStdGeomKeyToNode(geom_key,&info->findID);

  foundID = VDctxSearchNodeList(&info->findID,&info->xmlGeomList,VDvalStdPcmk2CompareGeom);
  if (foundID == NULL) goto wrapup;
  
  // Actually return the parent
  VDctxGetTreeParent(foundID,geomID);
  
 wrapup:
  return;
}
  
/* -----------------------------------------------
 * Find the piece mark for combination
 * of key,grade and thickness
 *
 * Note that non-matching combos are cached as well
 */
void VDvalQryStdPcmk2ByGeom(IGRchar *geom_key, IGRchar *grade, IGRchar *thick, IGRchar *pcmk)
{
  VDASSERT_FN("VDvalQryStdPcmk2ByGeom");
  
  TVDrisInfo ris;
  
  TGRid stdPcmkIDs,stdPcmkID;
  
  IGRint i;
  
  IGRchab gradex,thickx;
  IGRchar *geom_keyx;

  // If no database connection then use xml file
  if (!VDrisIsSchemaOpen()) {
    VDvalQryXmlStdPcmk2ByGeom(geom_key,grade,thick,pcmk);
    return;
  }
  
  // Init
  VDrisInitInfo(&ris);

  // Arg check
  VDASSERTW(pcmk); *pcmk = 0;
  VDASSERTW(geom_key && *geom_key);
  VDASSERTW(grade    && *grade);
  VDASSERTW(thick    && *thick);
  
  // Check the cache
  getRdbPcmkIDs(&stdPcmkIDs);
  for(i = 0; VDctxGetNthTreeChild(&stdPcmkIDs,i,&stdPcmkID); i++) {

    VDctxGetTxtAtrPtr(&stdPcmkID,VDCTX_STD_PCMK_ATR_GEOM_KEY,&geom_keyx);
    VDctxGetTxtAtr   (&stdPcmkID,VDCTX_STD_PCMK_ATR_GRADE,    gradex);
    VDctxGetTxtAtr   (&stdPcmkID,VDCTX_STD_PCMK_ATR_THICK,    thickx);
    
    if (!strcmp(geom_key,geom_keyx) &&
	!strcmp(grade,   gradex) &&
	!strcmp(thick,   thickx)) {

      VDctxGetTxtAtr(&stdPcmkID,VDCTX_STD_PCMK_ATR_PCMK,pcmk);
      goto wrapup;
      
    }
  }
  // Make sure
  if (!VDrisIsSchemaOpen()) goto wrapup;
  
  // Query it
  sprintf(ris.sql,
	  "Select pcmk from std_pcmk2 where grade='%s' and thickness='%s' and geom_key='%s';",
	  grade,thick,geom_key);

  VDrisQuery(&ris,NULL);
  
  // Extract it
  if (ris.rows && ris.cols) {
    strcpy(pcmk,ris.buf[0]);
  }
  
  // Add to cache
  VDctxCreateNode(&stdPcmkIDs,"std_pcmk",NULL,&stdPcmkID);
  VDctxAppTxtAtr (&stdPcmkID, VDCTX_STD_PCMK_ATR_PCMK,    pcmk);
  VDctxAppTxtAtr (&stdPcmkID, VDCTX_STD_PCMK_ATR_GEOM_KEY,geom_key);
  VDctxAppTxtAtr (&stdPcmkID, VDCTX_STD_PCMK_ATR_GRADE,   grade);
  VDctxAppTxtAtr (&stdPcmkID, VDCTX_STD_PCMK_ATR_THICK,   thick);
  
  // Consider breaking the geom_key up here, might be useful

 wrapup:
  VDrisFreeInfo(&ris);
  return;
}

/* -----------------------------------------------
 * Find the piece mark for combination
 * of key,grade and thickness
 *
 * Note that non-matching combos are cached as well
 */
void VDvalQryStdPcmk2ByPcmk(IGRchar *pcmk, TGRid *pcmkID)
{
  VDASSERT_FN("VDvalQryStdPcmk2ByPcmk");
  
  TVDrisInfo ris;
  
  TGRid stdPcmkIDs,stdPcmkID;
  
  IGRint i;
  
  IGRchab pcmkx,geom_keyx,gradex,thickx;

  // If no database connection then use xml file
  if (!VDrisIsSchemaOpen()) {
    VDvalQryXmlStdPcmk2ByPcmk(pcmk,pcmkID);
    return;
  }
  
  // Init
  VDrisInitInfo(&ris);

  // Arg check
  VDASSERTW(pcmkID); pcmkID->objid = NULL_OBJID;
  VDASSERTW(pcmk);
  
  // Check the cache
  getRdbPcmkIDs(&stdPcmkIDs);
  for(i = 0; VDctxGetNthTreeChild(&stdPcmkIDs,i,&stdPcmkID); i++) {

    VDctxGetTxtAtr(&stdPcmkID,VDCTX_STD_PCMK_ATR_PCMK,pcmkx);
    
    if (!strcmp(pcmk,pcmkx)) {
      *pcmkID = stdPcmkID;
      goto wrapup;
    }
  }
  // Make sure
  if (!VDrisIsSchemaOpen()) goto wrapup;
  
  // Query it
  sprintf(ris.sql,
	  "Select geom_key,grade,thickness from std_pcmk2 where pcmk=%s;",
	  pcmk);

  VDrisQuery(&ris,NULL);
  
  // Extract it
  if (ris.rows && ris.cols) {
    strcpy(geom_keyx,ris.buf[0]);
    strcpy(gradex,   ris.buf[1]);
    strcpy(thickx,   ris.buf[2]);
  }
  else {
    *geom_keyx = 0;
    *gradex = 0;
    *thickx = 0;
  }
  
  // Add to cache
  VDctxCreateNode(&stdPcmkIDs,"std_pcmk",NULL,&stdPcmkID);
  VDctxAppTxtAtr (&stdPcmkID, VDCTX_STD_PCMK_ATR_PCMK,pcmk);
  if (*geom_keyx) {    
    VDctxAppTxtAtr(&stdPcmkID,VDCTX_STD_PCMK_ATR_GEOM_KEY,geom_keyx);
    VDctxAppTxtAtr(&stdPcmkID,VDCTX_STD_PCMK_ATR_GRADE,   gradex);
    VDctxAppTxtAtr(&stdPcmkID,VDCTX_STD_PCMK_ATR_THICK,   thickx);
  }
  *pcmkID = stdPcmkID;
  
  // Consider breaking the geom_key up here, might be useful

 wrapup:
  VDrisFreeInfo(&ris);
  return;
}

/* -----------------------------------------------
 * Find the geometry for the given key
 * Uses a simple cache
 * Note that non-matching combos are cached as well
 */
void VDvalQryStdGeom2(IGRchar *a_geom_key, TGRid *a_stdGeomID)
{
  VDASSERT_FN("VDvalQryStdGeom2");
  
  IGRstat sts;
  
  TGRid stdGeomIDs,stdGeomID;
  
  IGRint i;
  
  IGRchar *geom_key;
  IGRchar *data = NULL;

  // If no database connection then use xml file
  if (!VDrisIsSchemaOpen()) {
    VDvalQryXmlStdGeom2(a_geom_key,a_stdGeomID);
    return;
  }
  
  // Arg check
  VDASSERTW(a_stdGeomID); a_stdGeomID->objid = NULL_OBJID;
  VDASSERTW(a_geom_key && *a_geom_key);
  
  // Check the cache
  getRdbGeomIDs(&stdGeomIDs);
  for(i = 0; VDctxGetNthTreeChild(&stdGeomIDs,i,&stdGeomID); i++) {

    VDctxGetTxtAtrPtr(&stdGeomID,VDCTX_STD_PCMK_ATR_GEOM_KEY,&geom_key);    
    if (strcmp(a_geom_key,geom_key)) {

      // Make sure have an actual contour
      // Recall the we cache unknown geom_keys
      sts = VDctxHasAttribute(&stdGeomID,VDCTX_STD_PCMK_ATR_OUTER_CONTOUR);
      if (!(sts & 1)) goto wrapup;
      *a_stdGeomID = stdGeomID;
      goto wrapup;
    }
  }
  // Make sure
  if (!VDrisIsSchemaOpen()) goto wrapup;

  // Add to cache
  VDctxCreateNode(&stdGeomIDs,"std_pcmk",NULL,&stdGeomID);
  VDctxAppTxtAtr (&stdGeomID, VDCTX_STD_PCMK_ATR_GEOM_KEY,a_geom_key);

  // Consider breaking the geom_key up here, might be useful
  
  // Query the geometry
  VDrisSelectStdGeom2(a_geom_key,&data);
  if (data == NULL) goto wrapup;
  VDctxAppTxtAtr(&stdGeomID,VDCTX_STD_PCMK_ATR_OUTER_CONTOUR,data);
  g_free(data);

  // Only return if have the contour
  *a_stdGeomID = stdGeomID;
  
 wrapup:
  return;
}

/* -----------------------------------------------
 * Macro Family Part Routines
 */
static int compareFamPart1(const void *p1, const void *p2)
{
  TGRid *info1ID = (TGRid*)p1;
  TGRid *info2ID = (TGRid*)p2;

  IGRchab buf1,buf2;
  
  IGRint cmp;

  // Macro
  VDctxGetTxtAtr(info1ID,VDCTX_STD_PCMK_ATR_MACRO,buf1);
  VDctxGetTxtAtr(info2ID,VDCTX_STD_PCMK_ATR_MACRO,buf2);
  cmp = strcmp(buf1,buf2);
  if (cmp) return cmp;

  // Family 1
  VDctxGetTxtAtr(info1ID,VDCTX_STD_PCMK_ATR_FAM1,buf1);
  VDctxGetTxtAtr(info2ID,VDCTX_STD_PCMK_ATR_FAM1,buf2);
  cmp = strcmp(buf1,buf2);
  if (cmp) return cmp;

  // Part 1
  VDctxGetTxtAtr(info1ID,VDCTX_STD_PCMK_ATR_PART1,buf1);
  VDctxGetTxtAtr(info2ID,VDCTX_STD_PCMK_ATR_PART1,buf2);
  cmp = strcmp(buf1,buf2);
  if (cmp) return cmp;

  return 0;
}

static int compareFamPart2(const void *p1, const void *p2)
{
  TGRid *info1ID = (TGRid*)p1;
  TGRid *info2ID = (TGRid*)p2;

  IGRchab buf1,buf2;
  
  IGRint cmp;

  // Macro
  VDctxGetTxtAtr(info1ID,VDCTX_STD_PCMK_ATR_MACRO,buf1);
  VDctxGetTxtAtr(info2ID,VDCTX_STD_PCMK_ATR_MACRO,buf2);
  cmp = strcmp(buf1,buf2);
  if (cmp) return cmp;

  // Family 2
  VDctxGetTxtAtr(info1ID,VDCTX_STD_PCMK_ATR_FAM2,buf1);
  VDctxGetTxtAtr(info2ID,VDCTX_STD_PCMK_ATR_FAM2,buf2);
  cmp = strcmp(buf1,buf2);
  if (cmp) return cmp;

  // Part 2
  VDctxGetTxtAtr(info1ID,VDCTX_STD_PCMK_ATR_PART2,buf1);
  VDctxGetTxtAtr(info2ID,VDCTX_STD_PCMK_ATR_PART2,buf2);
  cmp = strcmp(buf1,buf2);
  if (cmp) return cmp;

  return 0;
}

/* -----------------------------------------------
 * The geometry key is not in the database
 * Determine if fam1/part1 is missing or fam2/part2
 * or possibly both
 */
void VDvalQryMissingStdGeom2(IGRchar *geom_key, IGRchar *fam_part1, IGRchar *fam_part2)
{
  VDASSERT_FN("VDvalQryMissingStdGeom2");

  Tinfo *info = getInfo();

  TVDrisInfo ris;
  
  TGRid missingID;
  TGRid childID;
  IGRint i;
  
  IGRchab fam,part,macro;
  
  // Init
  VDrisInitInfo(&ris);

  // Arg check
  VDASSERTW(macro);     *macro = 0;
  VDASSERTW(fam_part1); *fam_part1 = 0;
  VDASSERTW(fam_part2); *fam_part2 = 0;
  VDASSERTW(geom_key && *geom_key);
  
  // Get missing tree
  if (info->missingIDs.objid == NULL_OBJID) {
    if (!VDrisIsSchemaOpen()) {
      initXmlGeoms();
      info->missingIDs = info->xmlGeomIDs;
    }
    else {

      // Query for all geom_keys
      sprintf(ris.sql,"Select geom_key from std_pcmk2 order by geom_key;");
      VDrisQuery(&ris,NULL);
      if (ris.rows == 0) goto wrapup;
      
      // Make the tree
      VDctxCreateXdomTree("geoms",NULL,&info->missingIDs);
      for(i = 0; i < ris.rows; i++) {
	VDctxCreateNode(&info->missingIDs,"geom",NULL,&missingID);
	VDctxAppTxtAtr(&missingID,VDCTX_STD_PCMK_ATR_GEOM_KEY,ris.buf[i]);
	VDvalSaveStdGeomKeyToNode(ris.buf[i],&missingID);
      }
      // printf("Created missing tree, %d rows\n",ris.rows);
    }
  }
  if (info->missingIDs.objid == NULL_OBJID) goto wrapup;
  
  // Break up key into find node
  VDvalSaveStdGeomKeyToNode(geom_key,&info->findID);
  
  // Setup return keys
  VDctxGetTxtAtr(&info->findID,VDCTX_STD_PCMK_ATR_MACRO,macro);

  VDctxGetTxtAtr(&info->findID,VDCTX_STD_PCMK_ATR_FAM1, fam);
  VDctxGetTxtAtr(&info->findID,VDCTX_STD_PCMK_ATR_PART1,part);
  sprintf(fam_part1,"%-14s %-14s %-14s",macro,fam,part);

  VDctxGetTxtAtr(&info->findID,VDCTX_STD_PCMK_ATR_FAM2, fam);
  VDctxGetTxtAtr(&info->findID,VDCTX_STD_PCMK_ATR_PART2,part);
  sprintf(fam_part2,"%-14s %-14s %-14s",macro,fam,part);
  
  // Cycle through
  for(i = 0; VDctxGetNthTreeChild(&info->missingIDs,i,&missingID); i++) {
    
    // Bit of a hack
    if (VDctxIsNodeType(&missingID,"ss_om_plate")) {
      VDctxGetNthTreeChild(&missingID,0,&childID);
      missingID = childID;
    }
      
    // Check keys
    if (!compareFamPart1(&info->findID,&missingID)) *fam_part1 = 0;
    if (!compareFamPart2(&info->findID,&missingID)) *fam_part2 = 0;
#if 0
    VDctxGetTxtAtr(&missingID,VDCTX_STD_PCMK_ATR_MACRO,macro);
    VDctxGetTxtAtr(&missingID,VDCTX_STD_PCMK_ATR_FAM2, fam);
    VDctxGetTxtAtr(&missingID,VDCTX_STD_PCMK_ATR_PART2,part);
    printf("### %-14s %-14s %-14s\n",macro,fam,part);
#endif
  }
  
 wrapup:
  VDrisFreeInfo(&ris);
  return;
}

  
