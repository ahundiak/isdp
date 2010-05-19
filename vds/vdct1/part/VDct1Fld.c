/* $Id: VDct1Fld.c,v 1.2 2001/02/11 17:24:16 ahundiak Exp $  */
/***************************************************************************
 * I/VDS
 *
 * File:        vdct1/post/VDct1Fld.c
 *
 * Description: Field Processing Routines
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDct1Fld.c,v $
 *      Revision 1.2  2001/02/11 17:24:16  ahundiak
 *      Renamed VDris2 to VDrisc
 *
 *      Revision 1.1  2001/01/12 14:35:59  art
 *      sp merge
 *
 * Revision 1.1  2000/12/07  17:39:48  pinnacle
 * ah
 *
# Revision 1.3  2000/07/13  12:26:34  pinnacle
# Replaced: vds/vdct1/part/VDct1Fld.I for:  by jdsauby for Service Pack
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 05/31/00  ah      Creation
 *
 ***************************************************************************/
#include "VDtypedefc.h"
#include "VDassert.h"

#include "VDrisc.h"

#include "VDct1Ris.h"
#include "VDct1Part.h"

/* -----------------------------------------------
 * Given a field sort number and an optional
 * parts structure, return all the information
 * about the field
 *
 * Use a function instead of a static array mainly to avoid
 * zdl issues but also to support some processing
 */
IGRstat VDct1GetPartFldInfoForIdx(IGRint i, TVDct1PartInfo *part, TVDct1PartFldInfo *fld)
{
  IGRstat retFlag = 0;
  
  // Arg check
  if (fld == NULL) goto wrapup;
  memset(fld,0,sizeof(TVDct1PartFldInfo));
  
  // Just a big switch statement
  retFlag = 1;
  switch(i) {
    case VDCT1_PART_FLD_IDX_PART_ID:
      fld->idx = VDCT1_PART_FLD_IDX_PART_ID;
      fld->len = VDCT1_PART_FLD_LEN_PART_ID;
      strcpy(fld->name,VDCT1_PART_FLD_NAME_PART_ID);
      if (part) fld->data = part->part_id;
      break;
      
    case VDCT1_PART_FLD_IDX_PART_CAGE_NUM:
      fld->idx = VDCT1_PART_FLD_IDX_PART_CAGE_NUM;
      fld->len = VDCT1_PART_FLD_LEN_PART_CAGE_NUM;
      strcpy(fld->name,VDCT1_PART_FLD_NAME_PART_CAGE_NUM);
      if (part) fld->data = part->part_cage_num;
      break;

    case VDCT1_PART_FLD_IDX_PART_CAGE_CODE:
      fld->idx = VDCT1_PART_FLD_IDX_PART_CAGE_CODE;
      fld->len = VDCT1_PART_FLD_LEN_PART_CAGE_CODE;
      strcpy(fld->name,VDCT1_PART_FLD_NAME_PART_CAGE_CODE);
      if (part) fld->data = part->part_cage_code;
      break;
      
    case VDCT1_PART_FLD_IDX_PART_NUM:
      fld->idx = VDCT1_PART_FLD_IDX_PART_NUM;
      fld->len = VDCT1_PART_FLD_LEN_PART_NUM;
      strcpy(fld->name,VDCT1_PART_FLD_NAME_PART_NUM);
      if (part) fld->data = part->part_num;
      break;
      
    case VDCT1_PART_FLD_IDX_PART_REV:
      fld->idx = VDCT1_PART_FLD_IDX_PART_REV;
      fld->len = VDCT1_PART_FLD_LEN_PART_REV;
      strcpy(fld->name,VDCT1_PART_FLD_NAME_PART_REV);
      if (part) fld->data = part->part_rev;
      break;
      
    case VDCT1_PART_FLD_IDX_CUR_REV:
      fld->idx = VDCT1_PART_FLD_IDX_CUR_REV;
      fld->len = VDCT1_PART_FLD_LEN_CUR_REV;
      strcpy(fld->name,VDCT1_PART_FLD_NAME_CUR_REV);
      if (part) fld->data = part->cur_rev;
      break;
      
    case VDCT1_PART_FLD_IDX_PART_FAMILY:
      fld->idx = VDCT1_PART_FLD_IDX_PART_FAMILY;
      fld->len = VDCT1_PART_FLD_LEN_PART_FAMILY;
      strcpy(fld->name,VDCT1_PART_FLD_NAME_PART_FAMILY);
      if (part) fld->data = part->part_family;
      break;
      
    case VDCT1_PART_FLD_IDX_NOUN_NAME:
      fld->idx = VDCT1_PART_FLD_IDX_NOUN_NAME;
      fld->len = VDCT1_PART_FLD_LEN_NOUN_NAME;
      strcpy(fld->name,VDCT1_PART_FLD_NAME_NOUN_NAME);
      if (part) fld->data = part->noun_name;
      break;
      
    case VDCT1_PART_FLD_IDX_TYPE:
      fld->idx = VDCT1_PART_FLD_IDX_TYPE;
      fld->len = VDCT1_PART_FLD_LEN_TYPE;
      strcpy(fld->name,VDCT1_PART_FLD_NAME_TYPE);
      if (part) fld->data = part->type;
      break;
      
    case VDCT1_PART_FLD_IDX_MODIFIER:
      fld->idx = VDCT1_PART_FLD_IDX_MODIFIER;
      fld->len = VDCT1_PART_FLD_LEN_MODIFIER;
      strcpy(fld->name,VDCT1_PART_FLD_NAME_MODIFIER);
      if (part) fld->data = part->modifier;
      break;
      
    case VDCT1_PART_FLD_IDX_MATERIAL:
      fld->idx = VDCT1_PART_FLD_IDX_MATERIAL;
      fld->len = VDCT1_PART_FLD_LEN_MATERIAL;
      strcpy(fld->name,VDCT1_PART_FLD_NAME_MATERIAL);
      if (part) fld->data = part->material;
      break;
      
    case VDCT1_PART_FLD_IDX_PART_SIZE:
      fld->idx = VDCT1_PART_FLD_IDX_PART_SIZE;
      fld->len = VDCT1_PART_FLD_LEN_PART_SIZE;
      strcpy(fld->name,VDCT1_PART_FLD_NAME_PART_SIZE);
      if (part) fld->data = part->part_size;
      break;
      
    case VDCT1_PART_FLD_IDX_UNIT_OF_MEASURE:
      fld->idx = VDCT1_PART_FLD_IDX_UNIT_OF_MEASURE;
      fld->len = VDCT1_PART_FLD_LEN_UNIT_OF_MEASURE;
      strcpy(fld->name,VDCT1_PART_FLD_NAME_UNIT_OF_MEASURE);
      if (part) fld->data = part->unit_of_measure;
      break;
      
    case VDCT1_PART_FLD_IDX_PART_STATUS:
      fld->idx = VDCT1_PART_FLD_IDX_PART_STATUS;
      fld->len = VDCT1_PART_FLD_LEN_PART_STATUS;
      strcpy(fld->name,VDCT1_PART_FLD_NAME_PART_STATUS);
      if (part) fld->data = part->part_status;
      break;
      
    case VDCT1_PART_FLD_IDX_REV_APPROVED:
      fld->idx = VDCT1_PART_FLD_IDX_REV_APPROVED;
      fld->len = VDCT1_PART_FLD_LEN_REV_APPROVED;
      strcpy(fld->name,VDCT1_PART_FLD_NAME_REV_APPROVED);
      if (part) fld->data = part->rev_approved;
      break;
      
    case VDCT1_PART_FLD_IDX_SUPERSEDED_BY:
      fld->idx = VDCT1_PART_FLD_IDX_SUPERSEDED_BY;
      fld->len = VDCT1_PART_FLD_LEN_SUPERSEDED_BY;
      strcpy(fld->name,VDCT1_PART_FLD_NAME_SUPERSEDED_BY);
      if (part) fld->data = part->superseded_by;
      break;
      
    case VDCT1_PART_FLD_IDX_ASSEMBLY_REQUIRED:
      fld->idx = VDCT1_PART_FLD_IDX_ASSEMBLY_REQUIRED;
      fld->len = VDCT1_PART_FLD_LEN_ASSEMBLY_REQUIRED;
      strcpy(fld->name,VDCT1_PART_FLD_NAME_ASSEMBLY_REQUIRED);
      if (part) fld->data = part->assembly_required;
      break;
      
    case VDCT1_PART_FLD_IDX_CFE_GFE:
      fld->idx = VDCT1_PART_FLD_IDX_CFE_GFE;
      fld->len = VDCT1_PART_FLD_LEN_CFE_GFE;
      strcpy(fld->name,VDCT1_PART_FLD_NAME_CFE_GFE);
      if (part) fld->data = part->cfe_gfe;
      break;
      
    case VDCT1_PART_FLD_IDX_MAKE_BUY:
      fld->idx = VDCT1_PART_FLD_IDX_MAKE_BUY;
      fld->len = VDCT1_PART_FLD_LEN_MAKE_BUY;
      strcpy(fld->name,VDCT1_PART_FLD_NAME_MAKE_BUY);
      if (part) fld->data = part->make_buy;
      break;
      
    case VDCT1_PART_FLD_IDX_ILS_WORTHY:
      fld->idx = VDCT1_PART_FLD_IDX_ILS_WORTHY;
      fld->len = VDCT1_PART_FLD_LEN_ILS_WORTHY;
      strcpy(fld->name,VDCT1_PART_FLD_NAME_ILS_WORTHY);
      if (part) fld->data = part->ils_worthy;
      break;
      
    case VDCT1_PART_FLD_IDX_SHOCK_GRADE:
      fld->idx = VDCT1_PART_FLD_IDX_SHOCK_GRADE;
      fld->len = VDCT1_PART_FLD_LEN_SHOCK_GRADE;
      strcpy(fld->name,VDCT1_PART_FLD_NAME_SHOCK_GRADE);
      if (part) fld->data = part->shock_grade;
      break;
      
    case VDCT1_PART_FLD_IDX_NATIONAL_STOCK_NUMBER:
      fld->idx = VDCT1_PART_FLD_IDX_NATIONAL_STOCK_NUMBER;
      fld->len = VDCT1_PART_FLD_LEN_NATIONAL_STOCK_NUMBER;
      strcpy(fld->name,VDCT1_PART_FLD_NAME_NATIONAL_STOCK_NUMBER);
      if (part) fld->data = part->national_stock_number;
      break;
      
    case VDCT1_PART_FLD_IDX_HAZARDOUS_MATERIAL:
      fld->idx = VDCT1_PART_FLD_IDX_HAZARDOUS_MATERIAL;
      fld->len = VDCT1_PART_FLD_LEN_HAZARDOUS_MATERIAL;
      strcpy(fld->name,VDCT1_PART_FLD_NAME_HAZARDOUS_MATERIAL);
      if (part) fld->data = part->hazardous_material;
      break;
    
    case VDCT1_PART_FLD_IDX_PRODUCTION_MATERIAL:
      fld->idx = VDCT1_PART_FLD_IDX_PRODUCTION_MATERIAL;
      fld->len = VDCT1_PART_FLD_LEN_PRODUCTION_MATERIAL;
      strcpy(fld->name,VDCT1_PART_FLD_NAME_PRODUCTION_MATERIAL);
      if (part) fld->data = part->production_material;
      break;
 
    case VDCT1_PART_FLD_IDX_ADDITIONAL_DESCRIPTION:
      fld->idx = VDCT1_PART_FLD_IDX_ADDITIONAL_DESCRIPTION;
      fld->len = VDCT1_PART_FLD_LEN_ADDITIONAL_DESCRIPTION;
      strcpy(fld->name,VDCT1_PART_FLD_NAME_ADDITIONAL_DESCRIPTION);
      //if (part) fld->data = part->additional_description;
      break;
      
    case VDCT1_PART_FLD_IDX_CREATION_DATE:
      fld->idx = VDCT1_PART_FLD_IDX_CREATION_DATE;
      fld->len = VDCT1_PART_FLD_LEN_CREATION_DATE;
      strcpy(fld->name,VDCT1_PART_FLD_NAME_CREATION_DATE);
      if (part) fld->data = part->creation_date;
      break;
      
    case VDCT1_PART_FLD_IDX_CREATOR_ID:
      fld->idx = VDCT1_PART_FLD_IDX_CREATOR_ID;
      fld->len = VDCT1_PART_FLD_LEN_CREATOR_ID;
      strcpy(fld->name,VDCT1_PART_FLD_NAME_CREATOR_ID);
      if (part) fld->data = part->creator_id;
      break;
      
    case VDCT1_PART_FLD_IDX_CHANGE_DATE:
      fld->idx = VDCT1_PART_FLD_IDX_CHANGE_DATE;
      fld->len = VDCT1_PART_FLD_LEN_CHANGE_DATE;
      strcpy(fld->name,VDCT1_PART_FLD_NAME_CHANGE_DATE);
      if (part) fld->data = part->change_date;
      break;
      
    case VDCT1_PART_FLD_IDX_CHANGE_ID:
      fld->idx = VDCT1_PART_FLD_IDX_CHANGE_ID;
      fld->len = VDCT1_PART_FLD_LEN_CHANGE_ID;
      strcpy(fld->name,VDCT1_PART_FLD_NAME_CHANGE_ID);
      if (part) fld->data = part->change_id;
      break;
      
    case VDCT1_PART_FLD_IDX_CHANGE_DESCRIPTION:
      fld->idx = VDCT1_PART_FLD_IDX_CHANGE_DESCRIPTION;
      fld->len = VDCT1_PART_FLD_LEN_CHANGE_DESCRIPTION;
      strcpy(fld->name,VDCT1_PART_FLD_NAME_CHANGE_DESCRIPTION);
      //if (part) fld->data = part->change_description;
      break;
      
    case VDCT1_PART_FLD_IDX_INTERCHANGEABILITY_AFFECTED:
      fld->idx = VDCT1_PART_FLD_IDX_INTERCHANGEABILITY_AFFECTED;
      fld->len = VDCT1_PART_FLD_LEN_INTERCHANGEABILITY_AFFECTED;
      strcpy(fld->name,VDCT1_PART_FLD_NAME_INTERCHANGEABILITY_AFFECTED);
      if (part) fld->data = part->interchangeability_affected;
      break;
      
    case VDCT1_PART_FLD_IDX_COPICS_SHORT_DESCRIPTION:
      fld->idx = VDCT1_PART_FLD_IDX_COPICS_SHORT_DESCRIPTION;
      fld->len = VDCT1_PART_FLD_LEN_COPICS_SHORT_DESCRIPTION;
      strcpy(fld->name,VDCT1_PART_FLD_NAME_COPICS_SHORT_DESCRIPTION);
      if (part) fld->data = part->copics_short_description;
      break;
      
    case VDCT1_PART_FLD_IDX_PRESSURE:
      fld->idx = VDCT1_PART_FLD_IDX_PRESSURE;
      fld->len = VDCT1_PART_FLD_LEN_PRESSURE;
      strcpy(fld->name,VDCT1_PART_FLD_NAME_PRESSURE);
      if (part) fld->data = part->pressure;
      break;
      
    case VDCT1_PART_FLD_IDX_COPICS_LONG_DESCRIPTION:
      fld->idx = VDCT1_PART_FLD_IDX_COPICS_LONG_DESCRIPTION;
      fld->len = VDCT1_PART_FLD_LEN_COPICS_LONG_DESCRIPTION;
      strcpy(fld->name,VDCT1_PART_FLD_NAME_COPICS_LONG_DESCRIPTION);
      //if (part) fld->data = part->copics_long_description;
      break;
      
    case VDCT1_PART_FLD_IDX_ISDP_STATUS:
      fld->idx = VDCT1_PART_FLD_IDX_ISDP_STATUS;
      fld->len = VDCT1_PART_FLD_LEN_ISDP_STATUS;
      strcpy(fld->name,VDCT1_PART_FLD_NAME_ISDP_STATUS);
      if (part) fld->data = part->isdp_status;
      break;
      
    case VDCT1_PART_FLD_IDX_GRADE:
      fld->idx = VDCT1_PART_FLD_IDX_GRADE;
      fld->len = VDCT1_PART_FLD_LEN_GRADE;
      strcpy(fld->name,VDCT1_PART_FLD_NAME_GRADE);
      if (part) fld->data = part->grade;
      break;
      
    case VDCT1_PART_FLD_IDX_LENGTH:
      fld->idx = VDCT1_PART_FLD_IDX_LENGTH;
      fld->len = VDCT1_PART_FLD_LEN_LENGTH;
      strcpy(fld->name,VDCT1_PART_FLD_NAME_LENGTH);
      if (part) fld->data = part->length;
      break;
      
    case VDCT1_PART_FLD_IDX_VOLTAGE:
      fld->idx = VDCT1_PART_FLD_IDX_VOLTAGE;
      fld->len = VDCT1_PART_FLD_LEN_VOLTAGE;
      strcpy(fld->name,VDCT1_PART_FLD_NAME_VOLTAGE);
      if (part) fld->data = part->voltage;
      break;
      
    case VDCT1_PART_FLD_IDX_WIDTH:
      fld->idx = VDCT1_PART_FLD_IDX_WIDTH;
      fld->len = VDCT1_PART_FLD_LEN_WIDTH;
      strcpy(fld->name,VDCT1_PART_FLD_NAME_WIDTH);
      if (part) fld->data = part->width;
      break;
      
    case VDCT1_PART_FLD_IDX_DISCIPLINE:
      fld->idx = VDCT1_PART_FLD_IDX_DISCIPLINE;
      fld->len = VDCT1_PART_FLD_LEN_DISCIPLINE;
      strcpy(fld->name,VDCT1_PART_FLD_NAME_DISCIPLINE);
      if (part) fld->data = part->discipline;
      break;
      
    case VDCT1_PART_FLD_IDX_CLASSIFICATION:
      fld->idx = VDCT1_PART_FLD_IDX_CLASSIFICATION;
      fld->len = VDCT1_PART_FLD_LEN_CLASSIFICATION;
      strcpy(fld->name,VDCT1_PART_FLD_NAME_CLASSIFICATION);
      if (part) fld->data = part->classification;
      break;
      
    case VDCT1_PART_FLD_IDX_FAMILY1:
      fld->idx = VDCT1_PART_FLD_IDX_FAMILY1;
      fld->len = VDCT1_PART_FLD_LEN_FAMILY1;
      strcpy(fld->name,VDCT1_PART_FLD_NAME_FAMILY1);
      if (part) fld->data = part->family1;
      break;
      
    case VDCT1_PART_FLD_IDX_FAMILY2:
      fld->idx = VDCT1_PART_FLD_IDX_FAMILY2;
      fld->len = VDCT1_PART_FLD_LEN_FAMILY2;
      strcpy(fld->name,VDCT1_PART_FLD_NAME_FAMILY2);
      if (part) fld->data = part->family2;
      break;
      
    case VDCT1_PART_FLD_IDX_FAMILY3:
      fld->idx = VDCT1_PART_FLD_IDX_FAMILY3;
      fld->len = VDCT1_PART_FLD_LEN_FAMILY3;
      strcpy(fld->name,VDCT1_PART_FLD_NAME_FAMILY3);
      if (part) fld->data = part->family3;
      break;
      
    case VDCT1_PART_FLD_IDX_UPDATEBY:
      fld->idx = VDCT1_PART_FLD_IDX_UPDATEBY;
      fld->len = VDCT1_PART_FLD_LEN_UPDATEBY;
      strcpy(fld->name,VDCT1_PART_FLD_NAME_UPDATEBY);
      if (part) fld->data = part->updateby;
      break;
      
    case VDCT1_PART_FLD_IDX_UPDATEDATE:
      fld->idx = VDCT1_PART_FLD_IDX_UPDATEDATE;
      fld->len = VDCT1_PART_FLD_LEN_UPDATEDATE;
      strcpy(fld->name,VDCT1_PART_FLD_NAME_UPDATEDATE);
      if (part) fld->data = part->updatedate;
      break;
      
    case VDCT1_PART_FLD_IDX_BR:
      fld->idx = VDCT1_PART_FLD_IDX_BR;
      fld->len = VDCT1_PART_FLD_LEN_BR;
      strcpy(fld->name,VDCT1_PART_FLD_NAME_BR);
      if (part) fld->data = part->br;
      break;

    case VDCT1_PART_FLD_IDX_ITEM_TYPE:
      fld->idx = VDCT1_PART_FLD_IDX_ITEM_TYPE;
      fld->len = VDCT1_PART_FLD_LEN_ITEM_TYPE;
      strcpy(fld->name,VDCT1_PART_FLD_NAME_ITEM_TYPE);
      if (part) fld->data = part->item_type;
      break;
        
    default:
      retFlag = 0;
      
  }
  
  // Done
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Given a name, find the desired information
 */
IGRstat VDct1GetPartFldInfoForName(IGRchar *a_name, TVDct1PartInfo *part, TVDct1PartFldInfo *fld)
{
  IGRstat retFlag = 0;
  IGRint  i = 0;
  IGRchar name[32];

  // Arg check
  if (fld == NULL) goto wrapup;
  memset(fld,0,sizeof(TVDct1PartFldInfo));
  
  // Make is case insensitive
  if ((a_name == NULL) || (*a_name == 0)) goto wrapup;
  strcpy(name,a_name);
  strlwr(name);
  
  // Just cycle through
  while(VDct1GetPartFldInfoForIdx(i,part,fld)) {
    if (!strcmp(name,fld->name)) {
      retFlag = 1;
      goto wrapup;
    }
    i++;
  }
  
  // Not found
  memset(fld,0,sizeof(TVDct1PartFldInfo));

 wrapup:
  return retFlag;
}





