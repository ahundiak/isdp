/* $Id: VDvalFamily.c,v 1.4 2002/05/01 19:58:11 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdval/VDvalFamily.c
 *
 * Description:	Family validation routines
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDvalFamily.c,v $
 *      Revision 1.4  2002/05/01 19:58:11  ahundiak
 *      ah
 *
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

VDASSERT_FFN("VDvalFamily.c");

static TGRid s_familyIDs;

typedef struct 
{
  TGRid           familyIDs;
  TGRid           findFamilyID;
  TGRid           findPartID;
  TVDctxNodeList  familyMaterialPartList;
} Tinfo;

static Tinfo *info;

#define VDRIS_TBLN_MAT_FAM          "mat_and_fam"
#define VDRIS_COLN_MAT_FAM_MATERIAL "n_itemname"
#define VDRIS_COLN_MAT_FAM_FAMILY   "n_itemrev"
#define VDRIS_COLN_MAT_FAM_TYPE     "vs_type"

#define VDRIS_COLN_FAMILY_PART_NUM  "n_itemname"
#define VDRIS_COLN_FAMILY_MATERIAL  "n_itemrev"
#define VDRIS_COLN_FAMILY_THICKNESS "thickness"

/* -----------------------------------------------
 * Creates a new xdom tree from database queries
 */
void VDvalQryFamilys(TGRid *familyIDs)
{
  VDASSERT_FN("VDvalQryFamilys");

  TGRid matfamIDs;
  TGRid matfamID;
  
  TGRid partIDs;
  TGRid partID;
  
  TGRid familyID;
  TGRid itemID;
  
  IGRint i,j;

  IGRchab family,material,type;
  IGRchab part_num,thickness;
  
  IGRchar qry[256];
  
  // Arg check
  VDASSERTW(familyIDs); familyIDs->objid = NULL_OBJID;
  
  // Must be logged
  if (VDrisIsSchemaOpen() == 0) goto wrapup;
  
  // Create the tree
  VDxdomCreateTree("families",familyIDs);
  
  // Grab list of matfams
  sprintf(qry,"Select %s,%s,%s from %s order by %s,%s,%s",
	  VDRIS_COLN_MAT_FAM_FAMILY,
	  VDRIS_COLN_MAT_FAM_MATERIAL,
	  VDRIS_COLN_MAT_FAM_TYPE,
	  VDRIS_TBLN_MAT_FAM, 
	  VDRIS_COLN_MAT_FAM_TYPE,
	  VDRIS_COLN_MAT_FAM_FAMILY,
	  VDRIS_COLN_MAT_FAM_MATERIAL);
  VDrisDomQuery(qry,&matfamIDs);
  
  // Cycle through
  for(i = 0; VDctxGetNthTreeChild(&matfamIDs,i,&matfamID); i++) {

    // Grab some data
    VDctxGetTxtAtr(&matfamID,VDRIS_COLN_MAT_FAM_FAMILY,  family);
    VDctxGetTxtAtr(&matfamID,VDRIS_COLN_MAT_FAM_MATERIAL,material);
    VDctxGetTxtAtr(&matfamID,VDRIS_COLN_MAT_FAM_TYPE,    type);
  
    // Setup family table query
    if (!strcmp(type,"plate")) {
      sprintf(qry,
	      "Select %s,%s from %s where %s='%s' order by %s",
	      VDRIS_COLN_FAMILY_PART_NUM,
	      VDRIS_COLN_FAMILY_THICKNESS,
	      family,
	      VDRIS_COLN_FAMILY_MATERIAL,
	      material,
	      VDRIS_COLN_FAMILY_PART_NUM);
    }
    else {
      sprintf(qry,
	      "Select %s from %s where %s='%s' order by %s",
	      VDRIS_COLN_FAMILY_PART_NUM,
	      family,
	      VDRIS_COLN_FAMILY_MATERIAL,
	      material,
	      VDRIS_COLN_FAMILY_PART_NUM);
    }
    VDrisDomQuery(qry,&partIDs);

    // Go with lower case just for grins
    // Need to stay with original case to support
    // Later database queries
    // strlwr(type);
    // strlwr(family);
    // strlwr(material);

    // Create the family object
    VDctxCreateNode(familyIDs,"family",NULL,&familyID);
    VDctxAppTxtAtr(&familyID,"family",  family);
    VDctxAppTxtAtr(&familyID,"material",material);
    VDctxAppTxtAtr(&familyID,"type",    type);
    
    // Cycle through
    for(j = 0; VDctxGetNthTreeChild(&partIDs,j,&partID); j++) {
      
      VDctxGetTxtAtr(&partID,VDRIS_COLN_FAMILY_PART_NUM, part_num);
      VDctxGetTxtAtr(&partID,VDRIS_COLN_FAMILY_THICKNESS,thickness);

      // strlwr(part_num);

      VDctxCreateNode(&familyID,"part",NULL,&itemID);

      VDctxAppTxtAtr(&itemID,"part_num",part_num);
      if (thickness) {
	VDctxAppTxtAtr(&itemID,"thickness",thickness);
      }
      
      //if (thickness) printf("matfam %s %s %s %s %s\n",type,family,material,part_num,thickness);
      //else           printf("matfam %s %s %s %s %s\n",type,family,material,part_num);
 
    }
    VDctxDeleteNode(&partIDs);
  }
  VDctxDeleteNode(&matfamIDs);

 wrapup:
  return;
}
/* -----------------------------------------------
 * Get the familys from web server
 */
void VDvalWebFamilys(TGRid *familyIDs)
{
  VDASSERT_FN("VDvalWebFamilys");

  // Arg check
  VDASSERTW(familyIDs); familyIDs->objid = NULL_OBJID;
  
  VDxdomCreateTreeFromWebFile(NULL,"/isdp/familys.xml",familyIDs);

 wrapup:
  return;
}

/* -----------------------------------------------
 * Get the familyss from xml file
 */
void VDvalFileFamilys(TGRid *familyIDs)
{
  VDASSERT_FN("VDvalFileFamilys");

  IGRchab path;
  
  // Arg check
  VDASSERTW(familyIDs); familyIDs->objid = NULL_OBJID;

  // Find the file
  VDsysFindFile("config/xml","familys.xml",path);
  if (*path == 0) goto wrapup;
  
  VDxdomCreateTreeFromXmlFile(path,familyIDs);

 wrapup:
  return;
}

/* -----------------------------------------------
 * Assorted indexes
 * Case insensitive
 */
static IGRint compareFamilyMaterialPart(const void *p1, const void *p2) 
{
  IGRint retFlag;
  
  TGRid *part1ID = (TGRid*)p1;
  TGRid *part2ID = (TGRid*)p2;
  
  TGRid  family1ID;
  TGRid  family2ID;
  
  IGRchab buf1,buf2;

  // Parent is the family
  VDctxGetTreeParent(part1ID,&family1ID);
  VDctxGetTreeParent(part2ID,&family2ID);

  // Family
  VDctxGetTxtAtr(&family1ID,"family",buf1);
  VDctxGetTxtAtr(&family2ID,"family",buf2);
  retFlag = strcasecmp(buf1,buf2);
  if (retFlag) return retFlag;
  
  // Material
  VDctxGetTxtAtr(&family1ID,"material",buf1);
  VDctxGetTxtAtr(&family2ID,"material",buf2);
  retFlag = strcasecmp(buf1,buf2);
  if (retFlag) return retFlag;

  // Part
  VDctxGetTxtAtr(part1ID,"part_num",buf1);
  VDctxGetTxtAtr(part2ID,"part_num",buf2);
  
  return strcasecmp(buf1,buf2);
}

static void indexFamilyMaterialPart()
{
  VDASSERT_FN("indexFamilyMaterialPart");
  
  // Build the list
  VDctxGetNodeListByType(&info->familyIDs,"part",&info->familyMaterialPartList);
  
  // Sort em
  VDctxSortNodeList(&info->familyMaterialPartList,compareFamilyMaterialPart);
  
  // For searching
  VDxdomCreateTree("family",&info->findFamilyID);
  VDctxCreateNode(&info->findFamilyID,"part",NULL,&info->findPartID);
  
 wrapup:
  return;
}

/* -----------------------------------------------
 * get the families tree, creating one if necessary
 */
void VDvalGetFamilys(TGRid *familyIDs)
{
  VDASSERT_FN("VDvalGetFamilys");

  IGRint flag = 0;
  
  // Arg check
  VDASSERTW(familyIDs); familyIDs->objid = NULL_OBJID;

  // See if loaded
  if (info) {
    
    // Is it already loaded
    *familyIDs = info->familyIDs;
    if ((familyIDs->objid != 0) && (familyIDs->objid != NULL_OBJID)) goto wrapup;
  }
  if (info == NULL) {  
    info = calloc(1,sizeof(Tinfo));
    VDASSERTW(info);
    flag = 1;
  }
  info->familyIDs.objid = NULL_OBJID;

  // Query it
  VDvalQryFamilys(familyIDs);
  if (familyIDs->objid != NULL_OBJID) {
    info->familyIDs = *familyIDs;
    if (flag) indexFamilyMaterialPart();
    goto wrapup;
  }
    
  // Load in text file
  VDvalFileFamilys(familyIDs);
  if (familyIDs->objid != NULL_OBJID) {
    info->familyIDs = *familyIDs;
    if (flag) indexFamilyMaterialPart();
    goto wrapup;
  }

  // Try the web
  VDvalWebFamilys(familyIDs);
  if (familyIDs->objid != NULL_OBJID) {
    info->familyIDs = *familyIDs;
    if (flag) indexFamilyMaterialPart();
    goto wrapup;
  }

  // Oops
  VDlogPrintFmt(VDLOG_ERROR,1,"*** Unable to load piece family cache");
  
 wrapup:
  return;
}

/* -----------------------------------------------
 * Allow creating xml tree from queried data
 */
void VDvalCreateFamilyXmlFile()
{
  TGRid familyIDs;
  
  // Fresh query
  VDvalQryFamilys(&familyIDs);
  
  // Put it out
  VDctxSaveTreeToXmlFile(&familyIDs,"familys.xml");

  // Free up
  VDctxDeleteNode(&familyIDs);
  
 wrapup:
  return;
}

/* -----------------------------------------------
 * Get the part object
 */
void VDvalGetPart(IGRchar *family, 
		  IGRchar *part_num, 
		  IGRchar *material, 
		  TGRid   *partID)
{
  VDASSERT_FN("VDvalGetPart");

  TGRid familyIDs;
  TGRid *foundID;
  
  // Arg check
  VDASSERTW(partID); partID->objid = NULL_OBJID;
  VDASSERTW(family);
  VDASSERTW(part_num);
  VDASSERTW(material);

  // Get the tree
  VDvalGetFamilys(&familyIDs);
  VDASSERTW(familyIDs.objid != NULL_OBJID);

  // Use the indexed info
  VDctxAppTxtAtr(&info->findFamilyID,"family",  family);  
  VDctxAppTxtAtr(&info->findFamilyID,"material",material);  
  VDctxAppTxtAtr(&info->findPartID,  "part_num",part_num);
 
  foundID = VDctxSearchNodeList(&info->findPartID,&info->familyMaterialPartList,compareFamilyMaterialPart);
  if (foundID) *partID = *foundID;
  
 wrapup:
  return;
}

/* -----------------------------------------------
 * Simple wrapper to determine if combo is valid
 */
IGRstat VDvalIsPartFamilyMaterialValid(IGRchar *family, 
				       IGRchar *part_num, 
				       IGRchar *material)
{
  IGRstat retFlag = 0;
  
  TGRid partID;

  VDvalGetPart(family,part_num,material,&partID);
  if (partID.objid != NULL_OBJID) retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Get a thickness
 */
IGRstat VDvalGetPartThickness(IGRchar   *family, 
			      IGRchar   *part_num, 
			      IGRchar   *material, 
			      IGRdouble *thickness)
{
  VDASSERT_FN("VDvalGetPartThickness");
  IGRstat retFlag = 0;

  TGRid partID;

  // Arg check
  VDASSERTW(thickness);
  *thickness = 0.0;
  
  // Get the part
  VDvalGetPart(family,part_num,material,&partID);
  if (partID.objid == NULL_OBJID) goto wrapup;
  
  // And the thickness
  VDctxGetDblAtr(&partID,"thickness",thickness);
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Determines if this combination is valid
 */
IGRstat VDvalIsPartFamilyMaterialThicknessValid(IGRchar  *family, 
						IGRchar  *part_num, 
						IGRchar  *material, 
						IGRdouble thickness)
{
  VDASSERT_FN("VDvalIsPartFamilyMaterialThicknessValid");
  IGRstat retFlag = 0;

  TGRid partID;

  IGRdouble thicknessx;

  // Get the part
  VDvalGetPart(family,part_num,material,&partID);
  if (partID.objid == NULL_OBJID) goto wrapup;
  
  // Check thickness
  VDctxGetDblAtr(&partID,"thickness",&thicknessx);
  if (fabs(thickness - thicknessx) >= .01) {
    goto wrapup;
  }
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

  
  
