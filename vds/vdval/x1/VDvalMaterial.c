/* $Id: VDvalMaterial.c,v 1.3 2001/08/24 20:00:43 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdval/VDvalMaterial.c
 *
 * Description:	Material grade validation routines
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDvalMaterial.c,v $
 *      Revision 1.3  2001/08/24 20:00:43  ahundiak
 *      ah
 *
 *      Revision 1.2  2001/06/22 15:16:50  ahundiak
 *      ah
 *
 *      Revision 1.1  2001/05/24 18:50:21  ahundiak
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

VDASSERT_FFN("VDvalMaterial.c");

typedef struct 
{
  TGRid           materialIDs;
  TGRid           findID;
  TVDctxNodeList  gradeList;
} Tinfo;

static Tinfo *info;

#define VDRIS_TBLN_MATERIAL          "material"
#define VDRIS_COLN_MATERIAL_MATERIAL "n_itemname"
#define VDRIS_COLN_MATERIAL_GRADE    "n_itemrev"
#define VDRIS_COLN_MATERIAL_DENSITY  "density"
#define VDRIS_COLN_MATERIAL_UNITS    "unit"

/* -----------------------------------------------
 * Creates a new xdom tree from database queries
 */
void VDvalQryMaterials(TGRid *materialIDs)
{
  VDASSERT_FN("VDvalQryMaterials");

  TGRid recordIDs;
  TGRid recordID;
  
  TGRid materialID;
  TGRid gradeID;
  
  IGRint i;

  IGRchab material,grade,density,units;
  IGRchab materialx;
  
  IGRchar qry[256];
  
  // Init
  recordIDs.objid = NULL_OBJID;
  
  // Arg check
  VDASSERTW(materialIDs); materialIDs->objid = NULL_OBJID;
  *materialx = 0;
  
  // Must be logged
  if (VDrisIsSchemaOpen() == 0) goto wrapup;
  
  // Create the tree
  VDxdomCreateTree("materials",materialIDs);
  
  // Grab list of matfams
  sprintf(qry,"Select %s,%s,%s,%s from %s order by %s,%s",
	  VDRIS_COLN_MATERIAL_MATERIAL,
	  VDRIS_COLN_MATERIAL_GRADE,
	  VDRIS_COLN_MATERIAL_DENSITY,
	  VDRIS_COLN_MATERIAL_UNITS,
	  VDRIS_TBLN_MATERIAL, 
	  VDRIS_COLN_MATERIAL_MATERIAL,
	  VDRIS_COLN_MATERIAL_GRADE);
  VDrisDomQuery(qry,&recordIDs);
  
  // Cycle through
  for(i = 0; VDctxGetNthTreeChild(&recordIDs,i,&recordID); i++) {

    // Grab some data
    VDctxGetTxtAtr(&recordID,VDRIS_COLN_MATERIAL_MATERIAL,material);
    VDctxGetTxtAtr(&recordID,VDRIS_COLN_MATERIAL_GRADE,   grade);
    VDctxGetTxtAtr(&recordID,VDRIS_COLN_MATERIAL_DENSITY, density);
    VDctxGetTxtAtr(&recordID,VDRIS_COLN_MATERIAL_UNITS,   units);
    
    // Create a new material object if required
    if (strcasecmp(material,materialx)) {
      VDctxCreateNode(materialIDs,"material",NULL,&materialID);
      VDASSERTW(materialID.objid != NULL_OBJID);
      VDctxAppTxtAtr(&materialID,"material",material);
      strcpy(materialx,material);
    }
    
    // Add the grade
    VDctxCreateNode(&materialID,"grade",NULL,&gradeID);
    VDASSERTW(gradeID.objid != NULL_OBJID);
    VDctxAppTxtAtr(&gradeID,"grade",grade);
    VDctxAppTxtAtr(&gradeID,"density",density);
    VDctxAppTxtAtr(&gradeID,"units",  units);

  }
  
 wrapup:
  VDctxDeleteNode(&recordIDs);
  return;
}

  
/* -----------------------------------------------
 * Get the materials from web server
 */
void VDvalWebMaterials(TGRid *materialIDs)
{
  VDASSERT_FN("VDvalWebMaterials");

  // Arg check
  VDASSERTW(materialIDs); materialIDs->objid = NULL_OBJID;
  
  VDxdomCreateTreeFromWebFile(NULL,"/isdp/materials.xml",materialIDs);

 wrapup:
  return;
}

/* -----------------------------------------------
 * Get the materials from xml file
 */
void VDvalFileMaterials(TGRid *materialIDs)
{
  VDASSERT_FN("VDvalFileMaterials");

  IGRchab path;
  
  // Arg check
  VDASSERTW(materialIDs); materialIDs->objid = NULL_OBJID;

  // Find the file
  VDsysFindFile("config/xml","materials.xml",path);
  if (*path == 0) goto wrapup;
  
  VDxdomCreateTreeFromXmlFile(path,materialIDs);

 wrapup:
  return;
}

/* -----------------------------------------------
 * Index on grade
 */
static IGRint compareGrade(const void *p1, const void *p2) 
{
  TGRid *node1ID = (TGRid*)p1;
  TGRid *node2ID = (TGRid*)p2;
  
  IGRchab grade1,grade2;
  
  VDctxGetTxtAtr(node1ID,"grade",grade1); strupr(grade1);
  VDctxGetTxtAtr(node2ID,"grade",grade2); strupr(grade2);
  
  return strcmp(grade1,grade2);
}

static void indexGrade()
{
  VDASSERT_FN("indexGrade");
  
  // Build the list
  VDctxGetNodeListByType(&info->materialIDs,"grade",&info->gradeList);
  
  // Sort em
  VDctxSortNodeList(&info->gradeList,compareGrade);
  
  // For searching
  VDxdomCreateTree("find",&info->findID);
  
 wrapup:
  return;
}
  
/* -----------------------------------------------
 * get the materials tree, creating one if necessary
 */
void VDvalGetMaterials(TGRid *materialIDs)
{
  VDASSERT_FN("VDvalGetMaterials");

  IGRint flag = 0;
  
  // Arg check
  VDASSERTW(materialIDs); materialIDs->objid = NULL_OBJID;

  // See if loaded
  if (info) {
    
    // Is it already loaded
    *materialIDs = info->materialIDs;
    if ((materialIDs->objid != 0) && (materialIDs->objid != NULL_OBJID)) goto wrapup;
  }
  if (info == NULL) {  
    info = calloc(1,sizeof(Tinfo));
    VDASSERTW(info);
    flag = 1;
  }
  info->materialIDs.objid = NULL_OBJID;
  
  // Query it
  VDvalQryMaterials(materialIDs);
  if (materialIDs->objid != NULL_OBJID) {
    info->materialIDs = *materialIDs;
    if (flag) indexGrade();
    goto wrapup;
  }
  
  // Load in text file
  VDvalFileMaterials(materialIDs);
  if (materialIDs->objid != NULL_OBJID) {
    info->materialIDs = *materialIDs;
    if (flag) indexGrade();
    goto wrapup;
  }

  // Try the web
  VDvalWebMaterials(materialIDs);  
  if (materialIDs->objid != NULL_OBJID) {
    info->materialIDs = *materialIDs;
    if (flag) indexGrade();
    goto wrapup;
  }
  

  // Oops
  VDlogPrintFmt(VDLOG_ERROR,1,"*** Unable to load material cache");
  
 wrapup:
  return;
}

/* -----------------------------------------------
 * Get the grade node
 */
void VDvalGetGrade(IGRchar *grade, TGRid *gradeID)
{
  VDASSERT_FN("VDvalGetGrade");
  
  TGRid materialIDs;
  TGRid *foundID;
  
  // Arg check
  VDASSERTW(gradeID); gradeID->objid = NULL_OBJID;
  VDASSERTW(grade);

  // Get the tree
  VDvalGetMaterials(&materialIDs);
  VDASSERTW(materialIDs.objid != NULL_OBJID);

  // Use the indexed info
  VDctxAppTxtAtr(&info->findID,"grade",grade);  
  foundID = VDctxSearchNodeList(&info->findID,&info->gradeList,compareGrade);
  if (foundID) *gradeID = *foundID;
  
 wrapup:
  return;
}

/* -----------------------------------------------
 * Get the material for a grade
 */
void VDvalGetGradeMaterial(IGRchar *grade, IGRchar *material)
{
  VDASSERT_FN("VDvalGetGradeMaterial");

  TGRid gradeID;
  TGRid materialID;
  
  // Argcheck
  VDASSERTW(material); *material = 0;
  VDASSERTW(grade);
  
  // Get the grade
  VDvalGetGrade(grade,&gradeID);
  if (gradeID.objid == NULL_OBJID) goto wrapup;
  
  // Get the material
  VDctxGetTreeParent(&gradeID,&materialID);
  VDASSERTW(materialID.objid != NULL_OBJID);
  
  VDctxGetTxtAtr(&materialID,"material",material);
  
 wrapup:
  return;
}

/* -----------------------------------------------
 * Get the density of a grade
 */
IGRstat VDvalGetGradeDensity(IGRchar *grade, IGRdouble *density, IGRchar *units)
{
  VDASSERT_FN("VDvalGetGradeDensity");

  IGRstat retFlag = 0;
  
  TGRid gradeID;
  IGRchar buf[32];
  
  // Argcheck
  VDASSERTW(density); *density = 1.0;
  if (units) *units = 0;
  VDASSERTW(grade);
  
  // Get the grade
  VDvalGetGrade(grade,&gradeID);
  if (gradeID.objid == NULL_OBJID) goto wrapup;
  
  // Get the density
  VDctxGetDblAtr(&gradeID,"density",density);
  
  // And the units
  if (units) {
    VDctxGetTxtAtr(&gradeID,"units",buf);
    *units = *buf;
  }
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Override the regular density routine
 */
IGRstat VDdenGetDensity(IGRchar   *material, 
			IGRchar   *grade, 
			IGRdouble *density, 
			IGRchar   *unit)
{
  return VDvalGetGradeDensity(grade,density,unit);
}

/* -----------------------------------------------
 * Allow creating xml tree from queried data
 */
void VDvalCreateMaterialXmlFile()
{
  TGRid materialIDs;
  
  // Fresh query
  VDvalQryMaterials(&materialIDs);
  
  // Put it out
  VDctxSaveTreeToXmlFile(&materialIDs,"materials.xml");

  // Free up
  VDctxDeleteNode(&materialIDs);
  
 wrapup:
  return;
}

/* -----------------------------------------------
 * Utility to find a file
 */
void VDsysFindFile(IGRchar *dir, IGRchar *name, IGRchar *path)
{
  VDASSERT_FN("VDsysFindFile");
  FILE *file;
  IGRchab buf;
  IGRchab pathx;
  IGRint i;
  
  // Arg check
  VDASSERTW(path); *path = 0;
  VDASSERTW(name && *name);
  VDASSERTW(dir  && *dir);
  
  // Might get lucky
  file = fopen(name,"rb");
  if (file) {
    fclose(file);
    strcpy(path,name);
    goto wrapup;
  }
  
  // Cycle through -S options
  for(i = 0; EX_getpath(i,buf,sizeof(buf),0); i++) {
    sprintf(pathx,"%s%s/%s",buf,dir,name);
    file = fopen(pathx,"rb");
    if (file) {
      fclose(file);
      strcpy(path,pathx);
      goto wrapup;
    }
  }

 wrapup:
  return;
}

