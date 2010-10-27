/* $Id: attribute.h,v 1.2 2001/01/12 14:47:06 art Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        include/attribute.h
 *
 * Description: Collector Tree Object
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: attribute.h,v $
 *      Revision 1.2  2001/01/12 14:47:06  art
 *      sp merge
 *
 * Revision 1.13  2000/06/30  18:52:26  pinnacle
 * pn
 *
 * Revision 1.12  2000/06/06  20:29:18  pinnacle
 * ah
 *
 * Revision 1.11  2000/06/05  15:15:16  pinnacle
 * ah
 *
 * Revision 1.10  2000/05/19  15:23:52  pinnacle
 * Replaced: vds/vdct1/ppl/*.h for:  by jdsauby for Service Pack
 *
 * Revision 1.9  2000/05/17  15:57:46  pinnacle
 * Replaced: vds/vdct1/ppl/*.h for:  by jdsauby for Service Pack
 *
 * Revision 1.8  2000/05/17  12:19:34  pinnacle
 * Replaced: vds/vdct1/ppl/*.h for:  by jdsauby for Service Pack
 *
 * Revision 1.7  2000/05/16  14:35:44  pinnacle
 * Replaced: vds/vdct1/ppl/attribute.h for:  by pnoel for Service Pack
 *
 * Revision 1.5  2000/05/10  19:23:10  pinnacle
 * Replaced: vds/vdct1/ppl/attribute.h for:  by jdsauby for Service Pack
 *
 * Revision 1.4  2000/05/09  19:10:26  pinnacle
 * Replaced: vds/vdct1/ppl/attribute.h for:  by pnoel for Service Pack
 *
 * Revision 1.1  2000/04/20  18:48:36  pinnacle
 * Created: vds/vdct1/ppl/attribute.h by pnoel for Service Pack
 *
 * Revision 1.6  2000/03/30  18:41:10  pinnacle
 * pn.
 *
 * Revision 1.4  2000/03/24  20:35:06  pinnacle
 * ah
 *
 * Revision 1.3  2000/03/13  15:43:10  pinnacle
 * ah
 *
 * Revision 1.0  2000/03/10  16:10:30  pinnacle
 * pn
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 03/10/00  pn      Provide Global Variables for PPL/.I file communication of data
 * 03/28/00  pn      Add more attributes
 * 05/10/00  js      revamped and reorganized to suit
 ***************************************************************************/


/* -------------------------------------------------------
 * Special include file which contains all of the standard
 * Attribute names and definitions
 */


// ============== Generic TREE Attributes =================
 
// ----------------------------------------------
 if (!strcmp(ATTR_NAMEX,VDCT1_ATTR_AV_HULL)) {

    vdct1$SetAttrInfo(name = ATTR_NAMEX,
		      len  = 5,
		      base = "AV HULL",
		      desc = "AVONDALE HULL NUMBER",
		      attrInfo = &ATTR_INFO);
    goto wrapup;
  }

// -----------------------------------------------
   if (!strcmp(ATTR_NAMEX,VDCT1_ATTR_CONT_HULL))
     {
       vdct1$SetAttrInfo(name = ATTR_NAMEX,
			 len  = 8,
			 base = "CONTRACT HULL",
			 desc = "CONTRACT HULL",
			 attrInfo = &ATTR_INFO);
      goto wrapup;
     }

// -----------------------------------------------
  if (!strcmp(ATTR_NAMEX,VDCT1_ATTR_ZONE)) {

    vdct1$SetAttrInfo(name = ATTR_NAMEX,
		      len  = 8,
		      base = "ZONE NUM",
		      desc = "DESIGN ZONE NUMBER",
		      attrInfo = &ATTR_INFO);
    goto wrapup;
  }

// ----------------------------------------------
  if (!strcmp(ATTR_NAMEX,VDCT1_ATTR_UNIT)) {

    vdct1$SetAttrInfo(name = ATTR_NAMEX,
		      len  = 4,
		      base = "UNIT NUM",
		      desc = "STRUCTURE UNIT NUMBER",
		      attrInfo = &ATTR_INFO);
    goto wrapup;
  }

// ----------------------------------------------
  if (!strcmp(ATTR_NAMEX,VDCT1_ATTR_COMPARTMENT)) {

    vdct1$SetAttrInfo(name = ATTR_NAMEX,
		      len  = 20,
		      base = "COMPT NUM",
		      desc = "COMPARTMENT NUMBER",
		      attrInfo = &ATTR_INFO);
    goto wrapup;
  }

// ----------------------------------------------
  if (!strcmp(ATTR_NAMEX,VDCT1_ATTR_COM_CODE)) {

    vdct1$SetAttrInfo(name = ATTR_NAMEX,
		      len  = 4,
		      base = "COMM CODE",
		      desc = "COMM CODE",
		      attrInfo = &ATTR_INFO);
    goto wrapup;
  }

// ---------------------------------------------  
  if (!strcmp(ATTR_NAMEX,VDCT1_ATTR_COMMODITY)) {
    
    vdct1$SetAttrInfo(name = ATTR_NAMEX,
		      len  = 25,
		      base = "COMMODITY",
		      desc = "COMMODITY",
		      attrInfo = &ATTR_INFO);
    goto wrapup;
  }

// ---------------------------------------------
  if (!strcmp(ATTR_NAMEX,VDCT1_ATTR_COST_CODE)) {

    vdct1$SetAttrInfo(name = ATTR_NAMEX,
		      len  = 8,
		      base = "COST CODE",
		      desc = "COST CODE",
		      attrInfo = &ATTR_INFO);
    goto wrapup;
  }

// ---------------------------------------------
  if (!strcmp(ATTR_NAMEX,VDCT1_ATTR_DWG_NUM)) {

    vdct1$SetAttrInfo(name = ATTR_NAMEX,
		      len  = 30,
		      base = "DRAWING NO.",
		      desc = "DRAWING NUMBER",
		      attrInfo = &ATTR_INFO);
    goto wrapup;
  }

// ---------------------------------------------
  if (!strcmp(ATTR_NAMEX,VDCT1_ATTR_DWG_REV)) {

    vdct1$SetAttrInfo(name = ATTR_NAMEX,
		      len  = 3,
		      base = "DRAWING REV.",
		      desc = "DRAWING REVISION",
		      attrInfo = &ATTR_INFO);
    goto wrapup;
  }

// ---------------------------------------------
   if (!strcmp(ATTR_NAMEX,VDCT1_ATTR_TREE_NUM))
     {
       vdct1$SetAttrInfo(name = ATTR_NAMEX,
			 len  = 5,
			 base = "TREE NUMBER",
			 desc = "TREE NUMBER",
			 attrInfo = &ATTR_INFO);
       goto wrapup;
     }

// --------------------------------------------
   if (!strcmp(ATTR_NAMEX,VDCT1_ATTR_NODE_NUM))
     {
       vdct1$SetAttrInfo(name = ATTR_NAMEX,
			 len  = 5,
			 base = "NODE NUMBER",
			 desc = "NODE NUMBER",
			 attrInfo = &ATTR_INFO);
      goto wrapup;
     }

// ------------------------------------------
   if (!strcmp(ATTR_NAMEX,VDCT1_ATTR_NUM_NEXT))
     {
       vdct1$SetAttrInfo(name = ATTR_NAMEX,
			 len  = 5,
			 base = "NEXT NODE NUM",
			 desc = "NEXT NODE NUM",
			 attrInfo = &ATTR_INFO);
      goto wrapup;
     }

// ------------------------------------------

// =============== Additional Special TREE Attributes ==================
 
 if (!strcmp(ATTR_NAMEX,VDCT1_ATTR_LABOR_CODE)) {

    vdct1$SetAttrInfo(name = ATTR_NAMEX,
		      len  = 2,
		      base = "LABOR CODE",
		      desc = "LABOR CODE",
		      attrInfo = &ATTR_INFO);
    goto wrapup;
  }

// ------------------------------------------
   if (!strcmp(ATTR_NAMEX,VDCT1_ATTR_SPECIAL_CODE))
     {
       vdct1$SetAttrInfo(name = ATTR_NAMEX,
			 len  = 12,
			 base = "SPECIAL CODE",
			 desc = "SPECIAL CODE",
			 attrInfo = &ATTR_INFO);
      goto wrapup;
     }

// ------------------------------------------
  if (!strcmp(ATTR_NAMEX,VDCT1_ATTR_DWG_CODE)) {

    vdct1$SetAttrInfo(name = ATTR_NAMEX,
		      len  = 2,
		      base = "DRAWING CODE",
		      desc = "DRAWING CODE",
		      attrInfo = &ATTR_INFO);
    goto wrapup;
  }
 
// ------------------------------------------
  if (!strcmp(ATTR_NAMEX,VDCT1_ATTR_PAL_GROUP)) {

    vdct1$SetAttrInfo(name = ATTR_NAMEX,
		      len  = 1,
		      base = "PALLET GROUP",
		      desc = "PALLET GROUP",
		      attrInfo = &ATTR_INFO);
    goto wrapup;
  }

// ------------------------------------------
  if (!strcmp(ATTR_NAMEX,VDCT1_ATTR_PAL_STAGE)) {

    vdct1$SetAttrInfo(name = ATTR_NAMEX,
		      len  = 1,
		      base = "PALLET STAGE",
		      desc = "PALLET STAGE",
		      attrInfo = &ATTR_INFO);
    goto wrapup;
  }

// ------------------------------------------

// ================== GROUP Attributes ======================

   if (!strcmp(ATTR_NAMEX,VDCT1_ATTR_FROZEN))
     {
       vdct1$SetAttrInfo(name = ATTR_NAMEX,
			 len  = 6,
			 base = "FROZEN",
			 desc = "FROZEN",
			 attrInfo = &ATTR_INFO);
      goto wrapup;
     }

// ------------------------------------------

// ================ ASSEMBLY Attributes ====================

  if (!strcmp(ATTR_NAMEX,VDCT1_ATTR_COUNT)) {
  
    vdct1$SetAttrInfo(name = ATTR_NAMEX,
		      len  = 3,
		      base = "COUNT",
		      desc = "COUNT OF CHILDREN",
		      attrInfo = &ATTR_INFO);
    goto wrapup;
  }

// -------------------------------------------------
  if (!strcmp(ATTR_NAMEX,VDCT1_ATTR_WEIGHT)) {

    vdct1$SetAttrInfo(name = ATTR_NAMEX,
		      len  = 20,
		      base = "WEIGHT",
		      desc = "WEIGHT",
		      attrInfo = &ATTR_INFO);
    goto wrapup;
  }

// ------------------------------------------
   if (!strcmp(ATTR_NAMEX,VDCT1_ATTR_COPICS_NUM))
     {
       vdct1$SetAttrInfo(name = ATTR_NAMEX,
			 len  = 19,
			 base = "COPICS NUM",
			 desc = "COPICS NUMBER",
			 attrInfo = &ATTR_INFO);
      goto wrapup;
     }

// ------------------------------------------

   if (!strcmp(ATTR_NAMEX,VDCT1_ATTR_IN_COPICS))
     {
       vdct1$SetAttrInfo(name = ATTR_NAMEX,
			 len  = 3,
			 base = "IN COPICS",
			 desc = "IN COPICS",
			 attrInfo = &ATTR_INFO);
      goto wrapup;
     }

// -------------------------------------------
  if (!strcmp(ATTR_NAMEX,VDCT1_ATTR_FIAN)) {

    vdct1$SetAttrInfo(name = ATTR_NAMEX,
		      len  = 20,
		      base = "FIAN",
		      desc = "FIAN",
		      attrInfo = &ATTR_INFO);
    goto wrapup;
  }

// -------------------------------------------
  if (!strcmp(ATTR_NAMEX,VDCT1_ATTR_LINE_IDENT)) {

    vdct1$SetAttrInfo(name = ATTR_NAMEX,
		      len  = 19,
		      base = "LINE IDENT",
		      desc = "LINE IDENT",
		      attrInfo = &ATTR_INFO);
    goto wrapup;
  }

// ------------------------------------------
  if (!strcmp(ATTR_NAMEX,VDCT1_ATTR_ASSY_DESCR)) {

    vdct1$SetAttrInfo(name = ATTR_NAMEX,
		      len  = 80,
		      base = "ASSY DESCR",
		      desc = "ASSEMBLY DESCRIPTION",
		      attrInfo = &ATTR_INFO);
    goto wrapup;
  }

// -------------------------------------------
   if (!strcmp(ATTR_NAMEX,VDCT1_ATTR_ASSY_REMARKS))
     {
       vdct1$SetAttrInfo(name = ATTR_NAMEX,
			 len  = 80,
			 base = "ASSY REMARKS",
			 desc = "ASSEMBLY REMARKS",
			 attrInfo = &ATTR_INFO);
      goto wrapup;
     }

// ------------------------------------------
  if (!strcmp(ATTR_NAMEX,VDCT1_ATTR_ASSY_DATE)) {

    vdct1$SetAttrInfo(name = ATTR_NAMEX,
		      len  = 20,
		      base = "ASSY DATE",
		      desc = "DATE CREATED OR MODIFIED (YYYYMMDD)",
		      attrInfo = &ATTR_INFO);
    goto wrapup;
  }

// ------------------------------------------
  if (!strcmp(ATTR_NAMEX,VDCT1_ATTR_ASSY_REV)) {

    vdct1$SetAttrInfo(name = ATTR_NAMEX,
		      len  = 3,
		      base = "ASSY REV",
		      desc = "ASSEMBLY REVISION",
		      attrInfo = &ATTR_INFO);
    goto wrapup;
  }
 
// ------------------------------------------

// ================= Additional Pallet Attributes ====================
  if (!strcmp(ATTR_NAMEX,VDCT1_ATTR_PALLET)) {

    vdct1$SetAttrInfo(name = ATTR_NAMEX,
		      len  = 19,
		      base = "PALLET CODE",
		      desc = "PALLET CODE",
		      attrInfo = &ATTR_INFO);
    goto wrapup;
  }

// ---------------------------------------------
  if (!strcmp(ATTR_NAMEX,VDCT1_ATTR_TREE_INDEX)) {

    vdct1$SetAttrInfo(name = ATTR_NAMEX,
		      len  = 40,
		      base = "TREE INDEX",
		      desc = "TREE INDEX",
		      attrInfo = &ATTR_INFO);
    goto wrapup;
  }

  
// ------------------------------------------

// ================= PART ATTRIBUTES ==============================

  if (!strcmp(ATTR_NAMEX,VDCT1_ATTR_QTY)) {

    vdct1$SetAttrInfo(name = ATTR_NAMEX,
		      len  = 20,
		      base = "QTY MTL",
		      desc = "QUANTITY PER PART",
		      attrInfo = &ATTR_INFO);
    goto wrapup;
  }

// ------------------------------------------
  if (!strcmp(ATTR_NAMEX,VDCT1_ATTR_UNIT_MEASURE)) {

    vdct1$SetAttrInfo(name = ATTR_NAMEX,
		      len  = 2,
		      base = "UNIT MEASURE",
		      desc = "QUANTITY UNITS FOR BOM",
		      attrInfo = &ATTR_INFO);
    goto wrapup;
  }
 
// ------------------------------------------
  if (!strcmp(ATTR_NAMEX,VDCT1_ATTR_SIZE)) {
    
    vdct1$SetAttrInfo(name = ATTR_NAMEX,
		      len  = 40,
		      base = "SIZE",
		      desc = "PART SIZE",
		      attrInfo = &ATTR_INFO);
    goto wrapup;
  } 

// ------------------------------------------
  if (!strcmp(ATTR_NAMEX,VDCT1_ATTR_MATERIAL)) {

    vdct1$SetAttrInfo(name = ATTR_NAMEX,
		      len  = 25,
		      base = "MATERIAL",
		      desc = "MATERIAL",
		      attrInfo = &ATTR_INFO);
    goto wrapup;
  }

// ------------------------------------------
  if (!strcmp(ATTR_NAMEX,VDCT1_ISDP_ATTR_GRADE)) {

    vdct1$SetAttrInfo(name = ATTR_NAMEX,
		      len  = 8,
		      base = "GRADE",
		      desc = "MATERIAL GRADE",
		      attrInfo = &ATTR_INFO);
    goto wrapup;
  }

// ------------------------------------------
  if (!strcmp(ATTR_NAMEX,VDCT1_ISDP_ATTR_PLATE_THK)) {

    vdct1$SetAttrInfo(name = ATTR_NAMEX,
		      len  = 20,
		      base = "PLATE THK",
		      desc = "PLATE THICKNESS",
		      attrInfo = &ATTR_INFO);
    goto wrapup;
  }

// ------------------------------------------
  if (!strcmp(ATTR_NAMEX,VDCT1_ISDP_ATTR_TREATMENT)) {

    vdct1$SetAttrInfo(name = ATTR_NAMEX,
		      len  = 80,
		      base = "TREATMENT",
		      desc = "BEAM END TREATMENT INFO",
		      attrInfo = &ATTR_INFO);
    goto wrapup;
  }

// ------------------------------------------
  if (!strcmp(ATTR_NAMEX,VDCT1_ATTR_PAINT_REF)) {

    vdct1$SetAttrInfo(name = ATTR_NAMEX,
		      len  = 24,
		      base = "PAINT REF",
		      desc = "PAINT REFERENCE",
		      attrInfo = &ATTR_INFO);
    goto wrapup;
  }

// ------------------------------------------
  if (!strcmp(ATTR_NAMEX,VDCT1_ATTR_MINO)) {

    vdct1$SetAttrInfo(name = ATTR_NAMEX,
		      len  = 19,
		      base = "MINO",
		      desc = "MATERIAL IDENTIFICATION NUMBER",
		      attrInfo = &ATTR_INFO);
    goto wrapup;
  }
 
// ------------------------------------------
  if (!strcmp(ATTR_NAMEX,VDCT1_ATTR_CAGE)) {

    vdct1$SetAttrInfo(name = ATTR_NAMEX,
		      len  = 5,
		      base = "CAGE",
		      desc = "CAGE",
		      attrInfo = &ATTR_INFO);
    goto wrapup;
  }
  
// ------------------------------------------
  if (!strcmp(ATTR_NAMEX,VDCT1_ATTR_NOMENCLATURE)) {

    vdct1$SetAttrInfo(name = ATTR_NAMEX,
		      len  = 80,
		      base = "NOMENCLATURE",
		      desc = "NOMENCLATURE",
		      attrInfo = &ATTR_INFO);
    goto wrapup;
  }

// -------------------------------------------
  if (!strcmp(ATTR_NAMEX,VDCT1_ATTR_PART_DESCR)) {

    vdct1$SetAttrInfo(name = ATTR_NAMEX,
		      len  = 80,
		      base = "PART DESCR",
		      desc = "PART DESCRIPTION",
		      attrInfo = &ATTR_INFO);
    goto wrapup;
  }
 
// ------------------------------------------
  if (!strcmp(ATTR_NAMEX,VDCT1_ATTR_PART_REMARKS)) {

    vdct1$SetAttrInfo(name = ATTR_NAMEX,
		      len  = 80,
		      base = "PART REMARKS",
		      desc = "PART REMARKS",
		      attrInfo = &ATTR_INFO);
    goto wrapup;
  }
 
// ------------------------------------------
  if (!strcmp(ATTR_NAMEX,VDCT1_ATTR_PART_REV)) {

    vdct1$SetAttrInfo(name = ATTR_NAMEX,
		      len  = 3,
		      base = "PART REV",
		      desc = "PART REVISION",
		      attrInfo = &ATTR_INFO);
    goto wrapup;
  }

// ------------------------------------------
  if (!strcmp(ATTR_NAMEX,VDCT1_ATTR_PART_NO)) {

    vdct1$SetAttrInfo(name = ATTR_NAMEX,
		      len  = 24,
		      base = "PART NO",
		      desc = "USER DEFINED ID NUMBER",
		      attrInfo = &ATTR_INFO);
    goto wrapup;
  }

// ------------------------------------------
  if (!strcmp(ATTR_NAMEX,VDCT1_ATTR_ISDP_NAME)) {

    vdct1$SetAttrInfo(name = ATTR_NAMEX,
		      len  = 80,
		      base = "ISDP NAME",
		      desc = "ISDP FAMILY:PART:REV:NAME",
		      attrInfo = &ATTR_INFO);
    goto wrapup;
  }
 
// ------------------------------------------
  if (!strcmp(ATTR_NAMEX,VDCT1_ATTR_ISDP_PATH)) {

    vdct1$SetAttrInfo(name = ATTR_NAMEX,
		      len  = 80,
		      base = "ISDP PATH",
		      desc = "ISDP OBJECT OCCURANCE PATH",
		      attrInfo = &ATTR_INFO);
    goto wrapup;
  }

// ------------------------------------------
  if (!strcmp(ATTR_NAMEX,VDCT1_ATTR_STOCK)) {

    vdct1$SetAttrInfo(name = ATTR_NAMEX,
		      len  = 25,
		      base = "STOCK",
		      desc = "STOCK",
		      attrInfo = &ATTR_INFO);
    goto wrapup;
  }

// ------------------------------------------
  if (!strcmp(ATTR_NAMEX,VDCT1_ATTR_PCT_MINO)) {

    vdct1$SetAttrInfo(name = ATTR_NAMEX,
		      len  = 25,
		      base = "PCT OF MINO",
		      desc = "PCT OF MINO",
		      attrInfo = &ATTR_INFO);
    goto wrapup;
  }
  // ------------------------------------------


// =============Additional PIPE attributes ----------------
  if (!strcmp(ATTR_NAMEX,VDCT1_ATTR_MOD_LENGTH)) {
  
    vdct1$SetAttrInfo(name = ATTR_NAMEX,
		      len  = 25,
		      base = "MOD LENGTH",
		      desc = "MODIFIED LENGTH",
		      attrInfo = &ATTR_INFO);
    goto wrapup;
  }

// ------------------------------------------------
  if (!strcmp(ATTR_NAMEX,VDCT1_ATTR_DETAIL_TYPE)) {
    vdct1$SetAttrInfo(name = ATTR_NAMEX,
		      len  = 8,
		      base = "DETAIL TYPE",
		      desc = "DETAIL TYPE",
		      attrInfo = &ATTR_INFO);
    goto wrapup;
  }
       
// ------------------------------------------------
  if (!strcmp(ATTR_NAMEX,VDCT1_ATTR_DETAIL_SEQ)) {
    vdct1$SetAttrInfo(name = ATTR_NAMEX,
		      len  = 8,
		      base = "DETAIL SEQ",
		      desc = "DETAIL SEQUENCE NUMBER",
		      attrInfo = &ATTR_INFO);
    goto wrapup;
  }
       
// ------------------------------------------------
  if (!strcmp(ATTR_NAMEX,VDCT1_ATTR_DETAIL_DIR)) {
    vdct1$SetAttrInfo(name = ATTR_NAMEX,
		      len  = 8,
		      base = "DETAIL DIR",
		      desc = "DETAIL DIRECTION",
		      attrInfo = &ATTR_INFO);
    goto wrapup;
  }
        
// ------------------------------------------------
  if (!strcmp(ATTR_NAMEX, VDCT1_ATTR_DETAIL_LOC)) {
    vdct1$SetAttrInfo(name = ATTR_NAMEX,
		      len  = 40,
		      base = "DETAIL LOC",
		      desc = "DETAIL LOCATION",
		      attrInfo = &ATTR_INFO);
    goto wrapup;
  }
        
// ------------------------------------------------
  if (!strcmp(ATTR_NAMEX,VDCT1_ATTR_DETAIL_USR)) {
    
    vdct1$SetAttrInfo(name = ATTR_NAMEX,
		      len  = 8,
		      base = "DETAIL USR",
		      desc = "DETAIL USER",
		      attrInfo = &ATTR_INFO);
    goto wrapup;
  }    
 
// ------------------------------------------------
  if (!strcmp(ATTR_NAMEX,VDCT1_ATTR_DETAIL_NO)) {
	       
    vdct1$SetAttrInfo(name = ATTR_NAMEX,
		      len  = 19,
		      base = "DETAIL NO",
		      desc = "DETAIL NUMBER",
		      attrInfo = &ATTR_INFO);
    goto wrapup;
  }     



// ============== Attributes that have not yet found a home, but
// ======may be used at a later time, so we will keep the around.

  if (!strcmp(ATTR_NAMEX,VDCT1_ATTR_MINO_ISDP)) {

    vdct1$SetAttrInfo(name = ATTR_NAMEX,
		      len  = 80,
		      base = "MINO ISDP",
		      desc = "MINO ISDP",
		      attrInfo = &ATTR_INFO);
    goto wrapup;
  }

// ------------------------------------------

  if (!strcmp(ATTR_NAMEX,VDCT1_ATTR_COG)) {

    vdct1$SetAttrInfo(name = ATTR_NAMEX,
		      len  = 19,
		      base = "COG",
		      desc = "COG",
		      attrInfo = &ATTR_INFO);
    goto wrapup;
  }
  // ------------------------------------------


  if (!strcmp(ATTR_NAMEX,VDCT1_ATTR_SPEC_CODE)) {

    vdct1$SetAttrInfo(name = ATTR_NAMEX,
		      len  = 25,
		      base = "SPEC CODE",
		      desc = "SPEC ORDERING DATA",
		      attrInfo = &ATTR_INFO);
    goto wrapup;
  }

  // ------------------------------------------
  if (!strcmp(ATTR_NAMEX,VDCT1_ATTR_LOCATION)) {

    vdct1$SetAttrInfo(name = ATTR_NAMEX,
		      len  = 20,
		      base = "LOCATION",
		      desc = "LOCATION",
		      attrInfo = &ATTR_INFO);
    goto wrapup;
  }

  // ------------------------------------------
  if (!strcmp(ATTR_NAMEX,VDCT1_ATTR_SHORT_DRAW)) {

    vdct1$SetAttrInfo(name = ATTR_NAMEX,
		      len  = 20,
		      base = "SHORT DWG NUM",
		      desc = "SHORT DWG NUM",
		      attrInfo = &ATTR_INFO);
    goto wrapup;
  }


  // ------------------------------------------
  if (!strcmp(ATTR_NAMEX,VDCT1_ATTR_WEIGHT_UNITS)) {

    vdct1$SetAttrInfo(name = ATTR_NAMEX,
		      len  = 8,
		      base = "WEIGHT UNITS",
		      desc = "UNIT WEIGHT UNITS",
		      attrInfo = &ATTR_INFO);
    goto wrapup;
  }

// ------------------------------------------
  if (!strcmp(ATTR_NAMEX,VDCT1_ATTR_PART_TYPE)) {

    vdct1$SetAttrInfo(name = ATTR_NAMEX,
		      len  = 4,
		      base = "PART_TYPE",
		      desc = "FABRICATED OR PURCHASED",
		      attrInfo = &ATTR_INFO);
    goto wrapup;
  }

// ------------------------------------------
  if (!strcmp(ATTR_NAMEX,VDCT1_ATTR_PART_DATE)) {

    vdct1$SetAttrInfo(name = ATTR_NAMEX,
		      len  = 20,
		      base = "PART DATE",
		      desc = "DATE CREATED OR MODIFIED (YYYYMMDD)",
		      attrInfo = &ATTR_INFO);
    goto wrapup;
  }

// ------------------------------------------
  if (!strcmp(ATTR_NAMEX,VDCT1_ATTR_CONTRACT_JOB)) {

    vdct1$SetAttrInfo(name = ATTR_NAMEX,
		      len  = 8,
		      base = "CONTRACTJOB NUM",
		      desc = "CONTRACT JOB NUMBER",
		      attrInfo = &ATTR_INFO);
    goto wrapup;
  }

// ------------------------------------------
  if (!strcmp(ATTR_NAMEX,VDCT1_ATTR_HULL_JOB)) {

    vdct1$SetAttrInfo(name = ATTR_NAMEX,
		      len  = 8,
		      base = "JOB HULL NUM",
		      desc = "JOB HULL NUMBER",
		      attrInfo = &ATTR_INFO);
    goto wrapup;
  }

// ------------------------------------------
  if (!strcmp(ATTR_NAMEX,VDCT1_ATTR_ENG_DATE)) {

    vdct1$SetAttrInfo(name = ATTR_NAMEX,
		      len  = 20,
		      base = "ENG  DATE",
		      desc = "DATE CREATED OR MODIFIED (YYYYMMDD)",
		      attrInfo = &ATTR_INFO);
    goto wrapup;
  }
 
// ------------------------------------------
  if (!strcmp(ATTR_NAMEX,VDCT1_ATTR_PAL_DATE)) {

    vdct1$SetAttrInfo(name = ATTR_NAMEX,
		      len  = 20,
		      base = "PAL  DATE",
		      desc = "DATE CREATED OR MODIFIED (YYYYMMDD)",
		      attrInfo = &ATTR_INFO);
    goto wrapup;
  }

// ------------------------------------------
  if (!strcmp(ATTR_NAMEX,VDCT1_ATTR_DWG_NUM)) {

    vdct1$SetAttrInfo(name = ATTR_NAMEX,
		      len  = 8,
		      base = "DWG NUM",
		      desc = "DRAWING NUMBER",
		      attrInfo = &ATTR_INFO);
    goto wrapup;
  }

// ------------------------------------------
  if (!strcmp(ATTR_NAMEX,VDCT1_ATTR_GROUP_CODE)) {

    vdct1$SetAttrInfo(name = ATTR_NAMEX,
		      len  = 2,
		      base = "GROUP CODE",
		      desc = "GROUP CODE",
		      attrInfo = &ATTR_INFO);
    goto wrapup;
  }

// ------------------------------------------
  if (!strcmp(ATTR_NAMEX,VDCT1_ATTR_MAT1)) {

    vdct1$SetAttrInfo(name = ATTR_NAMEX,
		      len  = 80,
		      base = "MAT1 COORD",
		      desc = "MAT1 COORD",
		      attrInfo = &ATTR_INFO);
    goto wrapup;
  }

// ------------------------------------------
  if (!strcmp(ATTR_NAMEX,VDCT1_ATTR_MAT2)) {

    vdct1$SetAttrInfo(name = ATTR_NAMEX,
		      len  = 80,
		      base = "MAT2 COORD",
		      desc = "MAT2 COORD",
		      attrInfo = &ATTR_INFO);
    goto wrapup;
  }

// ------------------------------------------
  if (!strcmp(ATTR_NAMEX,VDCT1_ATTR_MAT3)) {

    vdct1$SetAttrInfo(name = ATTR_NAMEX,
		      len  = 80,
		      base = "MAT3 COORD",
		      desc = "MAT3 COORD",
		      attrInfo = &ATTR_INFO);
    goto wrapup;
  }

// ------------------------------------------
  if (!strcmp(ATTR_NAMEX,VDCT1_ATTR_MAT4)) {

    vdct1$SetAttrInfo(name = ATTR_NAMEX,
		      len  = 80,
		      base = "MAT4 COORD",
		      desc = "MAT4 COORD",
		      attrInfo = &ATTR_INFO);
    goto wrapup;
  }
/* 
 * Attributes applied several levels
 */

// ------------------------------------------
   if (!strcmp(ATTR_NAMEX,VDCT1_ATTR_UNIT_WT))
     {
       vdct1$SetAttrInfo(name = ATTR_NAMEX,
			 len  = 2,
			 base = "UNIT OF WT",
			 desc = "UNIT OF WT",
			 attrInfo = &ATTR_INFO);
      goto wrapup;
     }

// ------------------------------------------
   if (!strcmp(ATTR_NAMEX,VDCT1_ATTR_WEIGHT_ASSY))
     {
       vdct1$SetAttrInfo(name = ATTR_NAMEX,
			 len  = 20,
			 base = "WEIGHT ASSY",
			 desc = "WEIGHT ASSY",
			 attrInfo = &ATTR_INFO);
      goto wrapup;
     }
// ------------------------------------------

// ===============================================
// Standard item attributes

  // ------------------------------------------
  if (!strcmp(ATTR_NAMEX,VDCT1_ATTR_ITEM_CAGE_NUM)) {

    vdct1$SetAttrInfo(name = ATTR_NAMEX,
		      len  = 25,
		      base = "ITEM CAGE NUMBER",
		      desc = "MASTER ID NUMBER",
		      attrInfo = &ATTR_INFO);
    goto wrapup;
  }
  // ------------------------------------------
  if (!strcmp(ATTR_NAMEX,VDCT1_ATTR_ITEM_CAGE_CODE)) {

    vdct1$SetAttrInfo(name = ATTR_NAMEX,
		      len  =  5,
		      base = "ITEM CAGE CODE",
		      desc = "ITEM CAGE CODE",
		      attrInfo = &ATTR_INFO);
    goto wrapup;
  }
  // ------------------------------------------
  if (!strcmp(ATTR_NAMEX,VDCT1_ATTR_PROJ_CODE)) {

    vdct1$SetAttrInfo(name = ATTR_NAMEX,
		      len  =  10,
		      base = "PROJECT CODE",
		      desc = "PROJECT CODE",
		      attrInfo = &ATTR_INFO);
    goto wrapup;
  }
  // ------------------------------------------
  if (!strcmp(ATTR_NAMEX,VDCT1_ATTR_ITEM_NUM)) {

    vdct1$SetAttrInfo(name = ATTR_NAMEX,
		      len  = 19,
		      base = "ITEM NUMBER",
		      desc = "MATERIAL IDENTIFICATION NUMBER",
		      attrInfo = &ATTR_INFO);
    goto wrapup;
  }
  // ------------------------------------------
  if (!strcmp(ATTR_NAMEX,VDCT1_ATTR_ITEM_DESC)) {

    vdct1$SetAttrInfo(name = ATTR_NAMEX,
		      len  = 25,
		      base = "ITEM DESC",
		      desc = "ITEM DESCRIPTION",
		      attrInfo = &ATTR_INFO);
    goto wrapup;
  }
  // ------------------------------------------
  if (!strcmp(ATTR_NAMEX,VDCT1_ATTR_ITEM_UM)) {

    vdct1$SetAttrInfo(name = ATTR_NAMEX,
		      len  = 2,
		      base = "ITEM UM",
		      desc = "UNIT OF MEASURE",
		      attrInfo = &ATTR_INFO);
    goto wrapup;
  }
  // ------------------------------------------
  if (!strcmp(ATTR_NAMEX,VDCT1_ATTR_ITEM_REV)) {

    vdct1$SetAttrInfo(name = ATTR_NAMEX,
		      len  = 4,
		      base = "ITEM REV",
		      desc = "ITEM REVISION",
		      attrInfo = &ATTR_INFO);
    goto wrapup;
  }
  // ------------------------------------------
  if (!strcmp(ATTR_NAMEX,VDCT1_ATTR_ITEM_DATE)) {

    vdct1$SetAttrInfo(name = ATTR_NAMEX,
		      len  = 19,
		      base = "ITEM DATE",
		      desc = "ITEM DATE",
		      attrInfo = &ATTR_INFO);
    goto wrapup;
  }
  // ------------------------------------------
  if (!strcmp(ATTR_NAMEX,VDCT1_ATTR_ITEM_QTY)) {

    vdct1$SetAttrInfo(name = ATTR_NAMEX,
		      len  = 19,
		      base = "ITEM QTY",
		      desc = "ITEM QUANTITY",
		      attrInfo = &ATTR_INFO);
    goto wrapup;
  }











