/* $Id: VDct1EngAttrs.c,v 1.8 2001/10/03 15:15:46 jdsauby Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdct1/tree/VDct1EngAttrs.C
 *
 * Description: Engineering Attribute Information
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDct1EngAttrs.c,v $
 *      Revision 1.8  2001/10/03 15:15:46  jdsauby
 *      JTS MP CR 5571
 *
 *      Revision 1.7  2001/08/24 15:10:02  jdsauby
 *      CR 5541, added eqpt_weight attribute - jds
 *
 *      Revision 1.6  2001/07/18 19:44:04  jdsauby
 *      CR 5290
 *
 *      Revision 1.5  2001/06/08 12:46:23  jdsauby
 *      CR5298, Added EQPT_MINO
 *
 *      Revision 1.4  2001/06/07 18:12:16  jdsauby
 *      CR3931, HVAC Tree, completed - jds
 *
 *      Revision 1.3  2001/05/25 14:56:47  jdsauby
 *      ETL 2235, Add HVAC tree to OTM
 *
 *      Revision 1.2  2001/02/14 16:45:40  paul_noel
 *      Added CHG_AUTH attribute to OutfitTree
 *
 *      Revision 1.1  2001/01/14 16:29:16  art
 *      sp merge
 *
 * Revision 1.4  2000/09/04  14:42:24  pinnacle
 * js
 *
 * Revision 1.3  2000/08/25  16:58:52  pinnacle
 * js
 *
 * Revision 1.2  2000/08/10  13:23:02  pinnacle
 * js
 *
 * Revision 1.1  2000/07/24  21:08:26  pinnacle
 * ah
 *
# Revision 1.2  2000/07/17  20:54:22  pinnacle
# ah
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 07/13/00  ah      Creation
 ***************************************************************************/
#include "VDtypedefc.h"
#include "VDassert.h"

#include "VDct1.h"
#include "VDct1Tree.h"
#include "VDct1Attrs.h"

VDASSERT_FFN("vdct1/tree/VDct1EngAttrs.C");

/* --------------------------------------------------
 * For a given set wide attribute name, fill in the info
 */
IGRstat VDct1EngTreeGetAttrInfo(IGRchar       *name, 
				TVDctAttrInfo *info)
{ 
  IGRstat retFlag = 0;
  
  // Arg check
  if (info == NULL) goto wrapup;
  if (name == NULL) goto wrapup;
  
  // Just compares
  retFlag = 1;
 
  // ----------------------------------------------
  if (!strcmp(name,VDCT1_ATTR_AV_HULL)) {
    VDctxSetAttrInfo(name,5,"AV HULL","AVONDALE HULL NUMBER",info);
    goto wrapup;
  }

  // -----------------------------------------------
  if (!strcmp(name,VDCT1_ATTR_CONT_HULL)) {
    VDctxSetAttrInfo(name,8,"CONTRACT HULL","CONTRACT HULL",info);
    goto wrapup;
  }

  // -----------------------------------------------
  if (!strcmp(name,VDCT1_ATTR_ZONE)) {
    VDctxSetAttrInfo(name,8,"ZONE NUM","DESIGN ZONE NUMBER",info);
    goto wrapup;
  }

  // ----------------------------------------------
  if (!strcmp(name,VDCT1_ATTR_UNIT)) {
    VDctxSetAttrInfo(name,4,"UNIT NUM","STRUCTURE UNIT NUMBER",info);
    goto wrapup;
  }

  // ----------------------------------------------
  if (!strcmp(name,VDCT1_ATTR_COMPARTMENT)) {
    VDctxSetAttrInfo(name,20,"COMPT NUM","COMPARTMENT NUMBER",info);
    goto wrapup;
  }

  // ----------------------------------------------
  if (!strcmp(name,VDCT1_ATTR_COM_CODE)) {
    VDctxSetAttrInfo(name,4,"COMM CODE","COMM CODE",info);
    goto wrapup;
  }

  // ---------------------------------------------  
  if (!strcmp(name,VDCT1_ATTR_COMMODITY)) {
    VDctxSetAttrInfo(name,25,"COMMODITY","COMMODITY",info);
    goto wrapup;
  }

  // ---------------------------------------------
  if (!strcmp(name,VDCT1_ATTR_COST_CODE)) {
    VDctxSetAttrInfo(name,8,"COST CODE","COST CODE",info);
    goto wrapup;
  }

  // ---------------------------------------------
  if (!strcmp(name,VDCT1_ATTR_DWG_NUM)) {
    VDctxSetAttrInfo(name,30,"DRAWING NO.","DRAWING NUMBER",info);
    goto wrapup;
  }

  // ---------------------------------------------
  if (!strcmp(name,VDCT1_ATTR_DWG_TITLE)) {
    VDctxSetAttrInfo(name,240,"DRAWING TITLE","DRAWING TITLE",info);
    goto wrapup;
  }
  
  // ---------------------------------------------
  if (!strcmp(name,VDCT1_ATTR_DWG_REV)) {
    VDctxSetAttrInfo(name,3,"DRAWING REV.","DRAWING REVISION",info);
    goto wrapup;
  }

  // ---------------------------------------------
  if (!strcmp(name,VDCT1_ATTR_CHG_AUTH)) {
    VDctxSetAttrInfo(name,15,"CHG AUTH","CHANGE AUTHORITY",info);
    goto wrapup;
  }

  // ---------------------------------------------
  if (!strcmp(name,VDCT1_ATTR_TREE_NUM)) {
    VDctxSetAttrInfo(name,5,"TREE NUMBER","TREE NUMBER",info);
    goto wrapup;
  }

  // --------------------------------------------
  if (!strcmp(name,VDCT1_ATTR_NODE_NUM)) {
    VDctxSetAttrInfo(name,5,"NODE NUMBER","NODE NUMBER",info);
    goto wrapup;
  }

  // ------------------------------------------
  if (!strcmp(name,VDCT1_ATTR_NUM_NEXT)) {
    VDctxSetAttrInfo(name,5,"NEXT NODE NUM","NEXT NODE NUM",info);
    goto wrapup;
  }


  // =============== Additional Special TREE Attributes ==================
 
  // ------------------------------------------
  if (!strcmp(name,VDCT1_ATTR_LABOR_CODE)) {
    VDctxSetAttrInfo(name,2,"LABOR CODE","LABOR CODE",info);
    goto wrapup;
  }

  // ------------------------------------------
  if (!strcmp(name,VDCT1_ATTR_SPECIAL_CODE)) {
    VDctxSetAttrInfo(name,12,"SPECIAL CODE","SPECIAL CODE",info);
    goto wrapup;
  }

  // ------------------------------------------
  if (!strcmp(name,VDCT1_ATTR_DWG_CODE)) {
    VDctxSetAttrInfo(name,2,"DRAWING CODE","DRAWING CODE",info);
    goto wrapup;
  }
 
  // ------------------------------------------
  if (!strcmp(name,VDCT1_ATTR_PAL_GROUP)) {
    VDctxSetAttrInfo(name,1,"PALLET GROUP","PALLET GROUP",info);
    goto wrapup;
  }

  // ------------------------------------------
  if (!strcmp(name,VDCT1_ATTR_PAL_STAGE)) {
    VDctxSetAttrInfo(name,1,"PALLET STAGE","PALLET STAGE",info);
    goto wrapup;
  }

  // ================== GROUP Attributes ======================

  // ------------------------------------------
  if (!strcmp(name,VDCT1_ATTR_FROZEN)) {
    VDctxSetAttrInfo(name,6,"STATUS","STATUS",info);
    goto wrapup;
  }

  // ================ ASSEMBLY Attributes ====================
  
  // ------------------------------------------
  if (!strcmp(name,VDCT1_ATTR_COUNT)) {
    VDctxSetAttrInfo(name,3,"COUNT","COUNT OF CHILDREN",info);
    goto wrapup;
  }

  // -------------------------------------------------
  if (!strcmp(name,VDCT1_ATTR_WEIGHT)) {
    VDctxSetAttrInfo(name,20,"WEIGHT","WEIGHT",info);
    goto wrapup;
  }

  // -------------------------------------------------
  if (!strcmp(name,VDCT1_ATTR_WET_WEIGHT)) {
    VDctxSetAttrInfo(name,20,"WET_WEIGHT","WET_WEIGHT",info);
    goto wrapup;
  }

  // ------------------------------------------
  if (!strcmp(name,VDCT1_ATTR_COPICS_NUM)) {
    VDctxSetAttrInfo(name,19,"COPICS NUM","COPICS NUMBER",info);
    goto wrapup;
  }

  // ------------------------------------------
  if (!strcmp(name,VDCT1_ATTR_IN_COPICS)) {
    VDctxSetAttrInfo(name,3,"IN COPICS","IN COPICS",info);
    goto wrapup;
  }

  // -------------------------------------------
  if (!strcmp(name,VDCT1_ATTR_FIAN)) {
    VDctxSetAttrInfo(name,20,"FIAN","FIAN",info);
    goto wrapup;
  }

  // -------------------------------------------
  if (!strcmp(name,VDCT1_ATTR_LINE_IDENT)) {
    VDctxSetAttrInfo(name,19,"LINE IDENT","LINE IDENT",info);
    goto wrapup;
  }

  // ------------------------------------------
  if (!strcmp(name,VDCT1_ATTR_ASSY_DESCR)) {
    VDctxSetAttrInfo(name,80,"ASSY DESCR","ASSEMBLY DESCRIPTION",info);
    goto wrapup;
  }

  // -------------------------------------------
  if (!strcmp(name,VDCT1_ATTR_ASSY_REMARKS)) {
    VDctxSetAttrInfo(name,80,"ASSY REMARKS","ASSEMBLY REMARKS",info);
    goto wrapup;
  }

  // ------------------------------------------
  if (!strcmp(name,VDCT1_ATTR_ASSY_DATE)) {
    VDctxSetAttrInfo(name,20,"ASSY DATE","DATE CREATED OR MODIFIED (YYYYMMDD)",info);
    goto wrapup;
  }

  // ------------------------------------------
  if (!strcmp(name,VDCT1_ATTR_ASSY_REV)) {
    VDctxSetAttrInfo(name,3,"ASSY REV","ASSEMBLY REVISION",info);
    goto wrapup;
  }

   // ------------------------------------------
  if (!strcmp(name,VDCT1_ATTR_ASSY_REV)) {
    VDctxSetAttrInfo(name,15,"ASSY REV","ASSEMBLY REVISION",info);
    goto wrapup;
  }
  // ================= Additional Pallet Attributes ====================

  // ------------------------------------------
  if (!strcmp(name,VDCT1_ATTR_PALLET)) {
    VDctxSetAttrInfo(name,19,"PALLET CODE","PALLET CODE",info);
    goto wrapup;
  }

  // ---------------------------------------------
  if (!strcmp(name,VDCT1_ATTR_TREE_INDEX)) {
    VDctxSetAttrInfo(name,40,"TREE INDEX","TREE INDEX",info);
    goto wrapup;
  }

  // ================= PART ATTRIBUTES ==============================

  // ------------------------------------------
  if (!strcmp(name,VDCT1_ATTR_QTY)) {
    VDctxSetAttrInfo(name,20,"QTY","QUANTITY PER PART",info);
    goto wrapup;
  }

  // ------------------------------------------
  if (!strcmp(name,VDCT1_ATTR_UNIT_MEASURE)) {
    VDctxSetAttrInfo(name,2,"UNIT MEASURE","QUANTITY UNITS FOR BOM",info);
    goto wrapup;
  }
 
  // ------------------------------------------
  if (!strcmp(name,VDCT1_ATTR_SIZE)) {
    VDctxSetAttrInfo(name,40,"SIZE","PART SIZE",info);
    goto wrapup;
  }
  
  // ------------------------------------------
  if (!strcmp(name,VDCT1_ATTR_MATERIAL)) {
    VDctxSetAttrInfo(name,25,"MATERIAL","MATERIAL",info);
    goto wrapup;
  }

  // ------------------------------------------
  if (!strcmp(name,VDCT1_ISDP_ATTR_GRADE)) {
    VDctxSetAttrInfo(name,8,"GRADE","MATERIAL GRADE",info);
    goto wrapup;
  }

  // ------------------------------------------
  if (!strcmp(name,VDCT1_ISDP_ATTR_PLATE_THK)) {
    VDctxSetAttrInfo(name,20,"PLATE THK","PLATE THICKNESS",info);
    goto wrapup;
  }

  // ------------------------------------------
  if (!strcmp(name,VDCT1_ISDP_ATTR_TREATMENT)) {
    VDctxSetAttrInfo(name,80,"TREATMENT","BEAM END TREATMENT INFO",info);
    goto wrapup;
  }

  // ------------------------------------------
  if (!strcmp(name,VDCT1_ATTR_PAINT_REF)) {
    VDctxSetAttrInfo(name,24,"PAINT REF","PAINT REFERENCE",info);
    goto wrapup;
  }
   
  // ------------------------------------------
  if (!strcmp(name,VDCT1_ATTR_MINO)) {
    VDctxSetAttrInfo(name,19,"MINO","MATERIAL IDENTIFICATION NUMBER",info);
    goto wrapup;
  }
 
  // ------------------------------------------
  if (!strcmp(name,VDCT1_ATTR_CAGE)) {
    VDctxSetAttrInfo(name,5,"CAGE","CAGE",info);
    goto wrapup;
  }
  
  // ------------------------------------------
  if (!strcmp(name,VDCT1_ATTR_NOMENCLATURE)) {
    VDctxSetAttrInfo(name,80,"NOMENCLATURE","NOMENCLATURE",info);
    goto wrapup;
  }
   
  // -------------------------------------------
  if (!strcmp(name,VDCT1_ATTR_PART_DESCR)) {
    VDctxSetAttrInfo(name,80,"PART DESCR","PART DESCRIPTION",info);
    goto wrapup;
  }
   
  // ------------------------------------------
  if (!strcmp(name,VDCT1_ATTR_PART_REMARKS)) {
    VDctxSetAttrInfo(name,80,"PART REMARKS","PART REMARKS",info);
    goto wrapup;
  }
 
  // ------------------------------------------
  if (!strcmp(name,VDCT1_ATTR_PART_REV)) {
    VDctxSetAttrInfo(name,3,"PART REV","PART REVISION",info);
    goto wrapup;
  }

  // ------------------------------------------
  if (!strcmp(name,VDCT1_ATTR_PART_NO)) {
    VDctxSetAttrInfo(name,24,"PART NO","USER DEFINED ID NUMBER",info);
    goto wrapup;
  }

  // ------------------------------------------
  if (!strcmp(name,VDCT1_ATTR_ISDP_NAME)) {
    VDctxSetAttrInfo(name,80,"ISDP NAME","ISDP FAMILY:PART:REV:NAME",info);
    goto wrapup;
  }
 
  // ------------------------------------------
  if (!strcmp(name,VDCT1_ATTR_ISDP_PATH)) {
    VDctxSetAttrInfo(name,80,"ISDP PATH","ISDP OBJECT OCCURANCE PATH",info);
    goto wrapup;
  }

  // ------------------------------------------
  if (!strcmp(name,VDCT1_ATTR_STOCK)) {
    VDctxSetAttrInfo(name,25,"STOCK","STOCK",info);
    goto wrapup;
  }
  // ------------------------------------------
  if (!strcmp(name,VDCT1_ATTR_PCT_MINO)) {
    VDctxSetAttrInfo(name,25,"PCT OF MINO","PCT OF MINO",info);
    goto wrapup;
  }

  // =============Additional PIPE attributes ----------------
   
  // ------------------------------------------
  if (!strcmp(name,VDCT1_ATTR_MOD_LENGTH)) {
    VDctxSetAttrInfo(name,25,"MOD LENGTH","MODIFIED LENGTH",info);
    goto wrapup;
  }

  // ------------------------------------------------
  if (!strcmp(name,VDCT1_ATTR_DETAIL_TYPE)) {
    VDctxSetAttrInfo(name,8,"DETAIL TYPE","DETAIL TYPE",info);
    goto wrapup;
  }
       
  // ------------------------------------------------
  if (!strcmp(name,VDCT1_ATTR_DETAIL_SEQ)) {
    VDctxSetAttrInfo(name,8,"DETAIL SEQ","DETAIL SEQUENCE NUMBER",info);
    goto wrapup;
  }
       
  // ------------------------------------------------
  if (!strcmp(name,VDCT1_ATTR_DETAIL_DIR)) {
    VDctxSetAttrInfo(name,8,"DETAIL DIR","DETAIL DIRECTION",info);
    goto wrapup;
  }
        
  // ------------------------------------------------
  if (!strcmp(name, VDCT1_ATTR_DETAIL_LOC)) {
    VDctxSetAttrInfo(name,40,"DETAIL LOC","DETAIL LOCATION",info);
    goto wrapup;
  }
        
  // ------------------------------------------------
  if (!strcmp(name,VDCT1_ATTR_DETAIL_USR)) {
    VDctxSetAttrInfo(name,8,"DETAIL USR","DETAIL USER",info);
    goto wrapup;
  }    
 
  // ------------------------------------------------
  if (!strcmp(name,VDCT1_ATTR_DETAIL_NO)) {
    VDctxSetAttrInfo(name,19,"DETAIL NO","DETAIL NUMBER",info);
    goto wrapup;
  }     

  // ============== Attributes that have not yet found a home, but
  // ======may be used at a later time, so we will keep the around.

  if (!strcmp(name,VDCT1_ATTR_MINO_ISDP)) {
    VDctxSetAttrInfo(name,80,"MINO ISDP","MINO ISDP",info);
    goto wrapup;
  }

  // Added for CR 5298 -----------------------
  if (!strcmp(name,VDCT1_ATTR_EQPT_MINO)) {
    VDctxSetAttrInfo(name,40,"EQPT_MINO","EQPT_MINO",info);
    goto wrapup;
  }

  // Added for CR 5541 -----------------------
  if (!strcmp(name,VDCT1_ATTR_EQPT_WEIGHT)) {
    VDctxSetAttrInfo(name,40,"EQPT_WEIGHT","EQPT_WEIGHT",info);
    goto wrapup;
  }


  // ------------------------------------------
  if (!strcmp(name,VDCT1_ATTR_COG)) {
    VDctxSetAttrInfo(name,19,"COG","COG",info);
    goto wrapup;
  }

  // ------------------------------------------
  if (!strcmp(name,VDCT1_ATTR_SPEC_CODE)) {
    VDctxSetAttrInfo(name,25,"SPEC CODE","SPEC ORDERING DATA",info);
    goto wrapup;
  }

  // ------------------------------------------
  if (!strcmp(name,VDCT1_ATTR_LOCATION)) {
    VDctxSetAttrInfo(name,20,"LOCATION","LOCATION",info);
    goto wrapup;
  }

  // ------------------------------------------
  if (!strcmp(name,VDCT1_ATTR_SHORT_DRAW)) {
    VDctxSetAttrInfo(name,20,"SHORT DWG NUM","SHORT DWG NUM",info);
    goto wrapup;
  }

  // ------------------------------------------
  if (!strcmp(name,VDCT1_ATTR_WEIGHT_UNITS)) {
    VDctxSetAttrInfo(name,8,"WEIGHT UNITS","UNIT WEIGHT UNITS",info);
    goto wrapup;
  }

  // ------------------------------------------
  if (!strcmp(name,VDCT1_ATTR_PART_TYPE)) {
    VDctxSetAttrInfo(name,4,"PART_TYPE","FABRICATED OR PURCHASED",info);
    goto wrapup;
  }

  // ------------------------------------------
  if (!strcmp(name,VDCT1_ATTR_PART_DATE)) {
    VDctxSetAttrInfo(name,20,"PART DATE","DATE CREATED OR MODIFIED (YYYYMMDD)",info);
    goto wrapup;
  }

  // ------------------------------------------
  if (!strcmp(name,VDCT1_ATTR_CONTRACT_JOB)) {
    VDctxSetAttrInfo(name,8,"CONTRACTJOB NUM","CONTRACT JOB NUMBER",info);
    goto wrapup;
  }

  // ------------------------------------------
  if (!strcmp(name,VDCT1_ATTR_HULL_JOB)) {
    VDctxSetAttrInfo(name,8,"JOB HULL NUM","JOB HULL NUMBER",info);
    goto wrapup;
  }

  // ------------------------------------------
  if (!strcmp(name,VDCT1_ATTR_ENG_DATE)) {
    VDctxSetAttrInfo(name,20,"ENG  DATE","DATE CREATED OR MODIFIED (YYYYMMDD)",info);
    goto wrapup;
  }
 
  // ------------------------------------------
  if (!strcmp(name,VDCT1_ATTR_PAL_DATE)) {
    VDctxSetAttrInfo(name,20,"PAL  DATE","DATE CREATED OR MODIFIED (YYYYMMDD)",info);
    goto wrapup;
  }

  // ------------------------------------------
  if (!strcmp(name,VDCT1_ATTR_DWG_NUM)) {
    VDctxSetAttrInfo(name,8,"DWG NUM","DRAWING NUMBER",info);
    goto wrapup;
  }

  // ------------------------------------------
  if (!strcmp(name,VDCT1_ATTR_GROUP_CODE)) {
    VDctxSetAttrInfo(name,2,"GROUP CODE","GROUP CODE",info);
    goto wrapup;
  }

  // ------------------------------------------
  if (!strcmp(name,VDCT1_ATTR_MAT1)) {
    VDctxSetAttrInfo(name,80,"MAT1 COORD","MAT1 COORD",info);
    goto wrapup;
  }

  // ------------------------------------------
  if (!strcmp(name,VDCT1_ATTR_MAT2)) {
    VDctxSetAttrInfo(name,80,"MAT2 COORD","MAT2 COORD",info);
    goto wrapup;
  }

  // ------------------------------------------
  if (!strcmp(name,VDCT1_ATTR_MAT3)) {
    VDctxSetAttrInfo(name,80,"MAT3 COORD","MAT3 COORD",info);
    goto wrapup;
  }

  // ------------------------------------------
  if (!strcmp(name,VDCT1_ATTR_MAT4)) {
    VDctxSetAttrInfo(name,80,"MAT4 COORD","MAT4 COORD",info);
    goto wrapup;
  }

  /* ==========================================
   * Attributes applied several levels
   */

  // ------------------------------------------
  if (!strcmp(name,VDCT1_ATTR_UNIT_WT)) {
    VDctxSetAttrInfo(name,2,"UNIT OF WT","UNIT OF WT",info);
    goto wrapup;
  }

  // ------------------------------------------
  if (!strcmp(name,VDCT1_ATTR_WEIGHT_ASSY)) {
    VDctxSetAttrInfo(name,20,"WEIGHT ASSY","WEIGHT ASSY",info);
    goto wrapup;
  }

  // ===============================================
  // Standard item attributes

  // ------------------------------------------
  if (!strcmp(name,VDCT1_ATTR_ITEM_CAGE_NUM)) {
    VDctxSetAttrInfo(name,25,"ITEM CAGE NUMBER","MASTER ID NUMBER",info);
    goto wrapup;
  }

  // ------------------------------------------
  if (!strcmp(name,VDCT1_ATTR_ITEM_CAGE_CODE)) {
    VDctxSetAttrInfo(name,5,"ITEM CAGE CODE","ITEM CAGE CODE",info);
    goto wrapup;
  }

  // ------------------------------------------
  if (!strcmp(name,VDCT1_ATTR_PROJ_CODE)) {
    VDctxSetAttrInfo(name,10,"PROJECT CODE","PROJECT CODE",info);
    goto wrapup;
  }

  // ------------------------------------------
  if (!strcmp(name,VDCT1_ATTR_ITEM_NUM)) {
    VDctxSetAttrInfo(name,19,"ITEM NUMBER","MATERIAL IDENTIFICATION NUMBER",info);
    goto wrapup;
  }
  
  // ------------------------------------------
  if (!strcmp(name,VDCT1_ATTR_ITEM_DESC)) {
    VDctxSetAttrInfo(name,25,"ITEM DESC","ITEM DESCRIPTION",info);
    goto wrapup;
  }

  // ------------------------------------------
  if (!strcmp(name,VDCT1_ATTR_ITEM_UM)) {
    VDctxSetAttrInfo(name,2,"ITEM UM","UNIT OF MEASURE",info);
    goto wrapup;
  }

  // ------------------------------------------
  if (!strcmp(name,VDCT1_ATTR_ITEM_REV)) {
    VDctxSetAttrInfo(name,4,"ITEM REV","ITEM REVISION",info);
    goto wrapup;
  }

  // ------------------------------------------
  if (!strcmp(name,VDCT1_ATTR_ITEM_DATE)) {
    VDctxSetAttrInfo(name,19,"ITEM DATE","ITEM DATE",info);
    goto wrapup;
  }

  // ------------------------------------------
  if (!strcmp(name,VDCT1_ATTR_ITEM_QTY)) {
    VDctxSetAttrInfo(name,19,"ITEM QTY","ITEM QUANTITY",info);
    goto wrapup;
  }

  // ------------------------------------------
  if (!strcmp(name,VDCT1_ATTR_TIER_SPACING)) {
    VDctxSetAttrInfo(name,19,"TIER SPACING","TIER SPACING",info);
    goto wrapup;
  }

  // ------------------------------------------
  if (!strcmp(name,VDCT1_ATTR_METHOD_NO)) {
    VDctxSetAttrInfo(name,19,"METHOD NO","METHOD NO",info);
    goto wrapup;
  }

  // ------------------------------------------
  if (!strcmp(name,VDCT1_ATTR_METHOD_TYPE)) {
    VDctxSetAttrInfo(name,19,"METHOD TYPE","METHOD TYPE",info);
    goto wrapup;
  }

  // ------------------------------------------
  if (!strcmp(name,VDCT1_ATTR_PACKING_METHOD)) {
    VDctxSetAttrInfo(name,19,"PACKING METHOD","PACKING METHOD",info);
    goto wrapup;
  }

  // ------------------------------------------
  if (!strcmp(name,VDCT1_ATTR_COLLAR_TYPE)) {
    VDctxSetAttrInfo(name,19,"COLLAR TYPE","COLLAR TYPE",info);
    goto wrapup;
  }

  // ------------------------------------------
  if (!strcmp(name,VDCT1_ATTR_HOLE_NO)) {
    VDctxSetAttrInfo(name,19,"HOLE NO","PENETRATION HOLE NO",info);
    goto wrapup;
  }

  // ------------------------------------------
  if (!strcmp(name,VDCT1_ATTR_WELD_SYMBOL)) {
    VDctxSetAttrInfo(name,19,"WELD SYMBOL","WELD SYMBOL",info);
    goto wrapup;
  }

  // ------------------------------------------
  if (!strcmp(name,VDCT1_ATTR_ORIENTATION)) {
    VDctxSetAttrInfo(name,19,"ORIENTATION","ORIENTATION",info);
    goto wrapup;
  }

  // ------------------------------------------
  if (!strcmp(name,VDCT1_ATTR_MODEL_ID)) {
    VDctxSetAttrInfo(name,32,"MODEL ID","MODEL ID",info);
    goto wrapup;
  }
  
  // ------------------------------------------
  if (!strcmp(name,VDCT1_ATTR_SYSTEM_CLASS)) {
    VDctxSetAttrInfo(name,24,"SYSTEM CLASS","SYSTEM CLASS",info);
    goto wrapup;
  }
  
  /* ----------------- Added For HVAC Tree ---------------*/
  // ------------------------------------------
  if (!strcmp(name,VDCT1_ATTR_NEXT_VD)) {
    VDctxSetAttrInfo(name,12,"NEXT VD","NEXT VENT DETAIL NUMBER",info);
    goto wrapup;
  }

  // ------------------------------------------
  if (!strcmp(name,VDCT1_ATTR_COMP_CODE)) {
    VDctxSetAttrInfo(name,24,"COMP CODE","COMPONENT CODE",info);
    goto wrapup;
  }

  // ------------------------------------------
  if (!strcmp(name,VDCT1_ATTR_SPEC_NAME)) {
    VDctxSetAttrInfo(name,48,"SPEC NAME","SPEC NAME",info);
    goto wrapup;
  }

  // ------------------------------------------
  if (!strcmp(name,VDCT1_ATTR_DUCT_MATL)) {
    VDctxSetAttrInfo(name,48,"DUCT MATL","DUCT MATERIAL",info);
    goto wrapup;
  }

  // ------------------------------------------
  if (!strcmp(name,VDCT1_ATTR_SEQ_NUMBER)) {
    VDctxSetAttrInfo(name,48,"SEQ NUMBER","SEQUENCE NUMBER",info);
    goto wrapup;
  }

  // ------------------------------------------
  if (!strcmp(name,VDCT1_ATTR_SURF_AREA)) {
    VDctxSetAttrInfo(name,48,"SURF AREA","SURFACE AREA",info);
    goto wrapup;
  }

  // ------------------------------------------
  if (!strcmp(name,VDCT1_ATTR_DUCT_LENGTH)) {
    VDctxSetAttrInfo(name,48,"DUCT LENGTH","DUCT LENGTH",info);
    goto wrapup;
  }

  // ------------------------------------------
  if (!strcmp(name,VDCT1_ATTR_BEND_SWEEP)) {
    VDctxSetAttrInfo(name,48,"BEND SWEEP","BEND SWEEP",info);
    goto wrapup;
  }

  // ------------------------------------------
  if (!strcmp(name,VDCT1_ATTR_THROAT_RAD)) {
    VDctxSetAttrInfo(name,48,"THROAT RAD","THROAT RADIUS",info);
    goto wrapup;
  }

  // ------------------------------------------
  if (!strcmp(name,VDCT1_ATTR_TRANS_LEN)) {
    VDctxSetAttrInfo(name,48,"TRANS LEN","TRANSITION LENGTH",info);
    goto wrapup;
  }

  // ------------------------------------------
  if (!strcmp(name,VDCT1_ATTR_CORNER_RAD)) {
    VDctxSetAttrInfo(name,48,"CORNER RAD","CORNER RADIUS",info);
    goto wrapup;
  }

  // ------------------------------------------
  if (!strcmp(name,VDCT1_ATTR_WIDTH_1)) {
    VDctxSetAttrInfo(name,48,"WIDTH_1","WIDTH_1",info);
    goto wrapup;
  }

  // ------------------------------------------
  if (!strcmp(name,VDCT1_ATTR_WIDTH_2)) {
    VDctxSetAttrInfo(name,48,"WIDTH_2","WIDTH_2",info);
    goto wrapup;
  }

  // ------------------------------------------
  if (!strcmp(name,VDCT1_ATTR_WIDTH_3)) {
    VDctxSetAttrInfo(name,48,"WIDTH_3","WIDTH_3",info);
    goto wrapup;
  }

  // ------------------------------------------
  if (!strcmp(name,VDCT1_ATTR_WIDTH_4)) {
    VDctxSetAttrInfo(name,48,"WIDTH_4","WIDTH_4",info);
    goto wrapup;
  }

  // ------------------------------------------
  if (!strcmp(name,VDCT1_ATTR_DEPTH_1)) {
    VDctxSetAttrInfo(name,48,"DEPTH_1","DEPTH_1",info);
    goto wrapup;
  }

  // ------------------------------------------
  if (!strcmp(name,VDCT1_ATTR_DEPTH_2)) {
    VDctxSetAttrInfo(name,48,"DEPTH_2","DEPTH_2",info);
    goto wrapup;
  }

  // ------------------------------------------
  if (!strcmp(name,VDCT1_ATTR_DEPTH_3)) {
    VDctxSetAttrInfo(name,48,"DEPTH_3","DEPTH_3",info);
    goto wrapup;
  }

  // ------------------------------------------
  if (!strcmp(name,VDCT1_ATTR_DEPTH_4)) {
    VDctxSetAttrInfo(name,48,"DEPTH_4","DEPTH_4",info);
    goto wrapup;
  }

  // ------------------------------------------
  if (!strcmp(name,VDCT1_ATTR_COATING)) {
    VDctxSetAttrInfo(name,48,"COATING","COATING",info);
    goto wrapup;
  }

  // ------------------------------------------
  if (!strcmp(name,VDCT1_ATTR_MAKE_BUY)) {
    VDctxSetAttrInfo(name,48,"MAKE_BUY","MAKE_BUY",info);
    goto wrapup;
  }

  // ------------------------------------------
  if (!strcmp(name,VDCT1_ATTR_RESERVED)) {
    VDctxSetAttrInfo(name,48,"RESERVED","RESERVED",info);
    goto wrapup;
  }

  // No Match
  retFlag = 0;
  
 wrapup:
  if ((info) && (retFlag == 0)) {
    memset(info,0,sizeof(TVDctAttrInfo));
  }
  
  return retFlag;
}
