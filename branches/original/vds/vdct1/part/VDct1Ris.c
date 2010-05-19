/* $Id: VDct1Ris.c,v 1.2 2001/02/11 17:24:17 ahundiak Exp $  */
/***************************************************************************
 * I/VDS
 *
 * File:        vdct1/part/VDct1Ris.c
 *
 * Description: All parts ris queries
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDct1Ris.c,v $
 *      Revision 1.2  2001/02/11 17:24:17  ahundiak
 *      Renamed VDris2 to VDrisc
 *
 *      Revision 1.1  2001/01/12 14:35:59  art
 *      sp merge
 *
 * Revision 1.1  2000/12/07  17:39:48  pinnacle
 * ah
 *
# Revision 1.8  2000/08/24  14:53:12  pinnacle
# js
#
# Revision 1.7  2000/08/23  14:50:00  pinnacle
# ah
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 06/28/00  ah      Creation
 *
 ***************************************************************************/
#include "VDtypedefc.h"
#include "VDassert.h"

#include "VDrisc.h"

#include "VDct1Ris.h"
#include "VDct1Part.h"

VDASSERT_FFN("vds/vdct1/part/VDct1Ris.c");

/* ----------------------------------------------
 * Look up item_type for part cage num
 */
IGRstat VDct1QryItemTypeForPartCageNum(TVDrisInfo  *ris,
				       IGRchar     *part_cage_num,
				       IGRchar     *itemType)
{
  IGRstat retFlag = 0;
  
  // init
  VDrisInitInfo(ris);

  // build the query
  sprintf(ris->sql,
	  "select %s from %s where %s = '%s';",
	  VDCT1_RIS_COLN_ITEMS_ITEM_TYPE,
	  VDCT1_RIS_TBLN_ITEMS,
	  VDCT1_RIS_COLN_ITEMS_ITEM_CAGE_NUM,
	  part_cage_num);
  
  // do it
  VDrisQuery(ris,NULL);
  if (ris->rows < 1) goto wrapup;
  
  // set it
  strcpy(itemType,ris->buf[0]);
  
  // done
  retFlag = 1;
  
wrapup:
  VDrisFreeInfo(ris);
  return retFlag;
  
}

/* -----------------------------------------------
 * Look up misc static attrs for part_cage_num
 */
IGRstat VDct1QryMiscStatAttrsForCageNum(TVDrisInfo *ris,
					IGRchar    *part_cage_num,
					IGRchar    *attrName)
{
  IGRstat retFlag = 0;
  IGRchar buf[256];
  
  // Arg check
  if (ris           == NULL) goto wrapup;
  if (part_cage_num == NULL) goto wrapup;
  
  // Build Query
  sprintf(ris->sql,
	  "Select %s,%s,%s from %s where %s='%s' ",

	  VDCT1_RIS_COLN_MISC_SATTR_ITEM_CAGE_NUM,
	  VDCT1_RIS_COLN_MISC_SATTR_ATTR_NAMES,
	  VDCT1_RIS_COLN_MISC_SATTR_ATTR_VALUE,


	  VDCT1_RIS_TBLN_MISC_SATTR,
	  VDCT1_RIS_COLN_MISC_SATTR_ITEM_CAGE_NUM,
	  part_cage_num);
  
  if (attrName) {
    sprintf(buf, "and %s='%s';",
	    VDCT1_RIS_COLN_MISC_SATTR_ATTR_NAMES,
	    attrName);
    strcat(ris->sql,buf);
  }
  else {
    sprintf(buf, "order by %s;",
	    VDCT1_RIS_COLN_MISC_SATTR_ATTR_NAMES);
    strcat(ris->sql,buf);
  }
  
	    
  // Do It
  VDrisQuery(ris,NULL);
  
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}


/* -----------------------------------------------
 * Look up info for elec dwg number
 */
IGRstat VDct1QryDwgInfoForDwgNum(TVDrisInfo *ris, IGRchar *dwg_num)
{
  IGRstat retFlag = 0;
  IGRchar buf[128];
  
  // Arg check
  if (ris == NULL) goto wrapup;

  // Build Query
  sprintf(ris->sql,
	  "Select %s,%s,%s,%s from %s ",

	  VDCT1_RIS_COLN_ELECDWG_DWG_NUM,
	  VDCT1_RIS_COLN_ELECDWG_DWG_CODE,
	  VDCT1_RIS_COLN_ELECDWG_DWG_TITLE,
	  VDCT1_RIS_COLN_ELECDWG_SECT_NUM,
	  VDCT1_RIS_TBLN_ELECDWG);
  
  // Filter if required
  if (dwg_num) {
    sprintf(buf," where %s = '%s' ",
	    VDCT1_RIS_COLN_ELECDWG_DWG_NUM,dwg_num);
    strcat(ris->sql,buf);
  }
  
  // The order
  sprintf(buf," order by %s;",VDCT1_RIS_COLN_ELECDWG_DWG_NUM);
  strcat(ris->sql,buf);

  // Do It
  VDrisQuery(ris,NULL);
  
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}


/* -----------------------------------------------
 * Look up info for comm_code
 */
IGRstat VDct1QryCodesForCommCode(TVDrisInfo *ris, IGRchar *comm_code)
{
  IGRstat retFlag = 0;
  IGRchar buf[64];
  
  // Arg check
  if (ris == NULL) goto wrapup;

  // Build Query
  sprintf(ris->sql,
	  "Select %s,%s,%s,%s from %s ",

	  VDCT1_RIS_COLN_COMMS_COMM_CODE,
	  VDCT1_RIS_COLN_COMMS_COST_CODE,
	  VDCT1_RIS_COLN_COMMS_COMMODITY,
	  VDCT1_RIS_COLN_COMMS_SEQUENCE_NO,
	  VDCT1_RIS_TBLN_COMMS);
  
  // Filter if required
  if (comm_code) {
    sprintf(buf," where %s = '%s' ",
	    VDCT1_RIS_COLN_COMMS_COMM_CODE,comm_code);
    strcat(ris->sql,buf);
  }
  
  // The order
  sprintf(buf," order by %s;",VDCT1_RIS_COLN_COMMS_COMM_CODE);
  strcat(ris->sql,buf);

  // Do It
  VDrisQuery(ris,NULL);
  
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Look up attrs for part_id
 */
IGRstat VDct1QryAttrsForPartId(TVDrisInfo *ris, IGRchar *part_id)
{
  IGRstat retFlag = 0;
  
  // Arg check
  if (ris     == NULL) goto wrapup;
  if (part_id == NULL) goto wrapup;
  
  // Build Query
  sprintf(ris->sql,
	  "Select %s,%s,%s,%s,%s from %s where %s='%s' order by %s;",

	  VDCT1_RIS_COLN_ATTRS_PART_ID,
	  VDCT1_RIS_COLN_ATTRS_NAME,
	  VDCT1_RIS_COLN_ATTRS_VALUE,
	  VDCT1_RIS_COLN_ATTRS_SORT,
	  VDCT1_RIS_COLN_ATTRS_INFO,

	  VDCT1_RIS_TBLN_ATTRS,
	  VDCT1_RIS_COLN_ATTRS_PART_ID,
	  part_id,
	  VDCT1_RIS_COLN_ATTRS_SORT);

  // Do It
  VDrisQuery(ris,NULL);
  
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Look up part_id for part_cage_num
 */
IGRstat VDct1QryPartIdForPartCageNum(TVDrisInfo *ris, IGRchar *part_cage_num)
{
  
  IGRstat retFlag = 0;
  
  // Arg check
  if (ris           == NULL) goto wrapup;
  if (part_cage_num == NULL) goto wrapup;
  
  // Build Query
  sprintf(ris->sql,
	  "Select %s from %s where %s=1 and %s=4 and %s='%s';",
	  VDCT1_RIS_COLN_ITEMS_ITEM_ID,
	  VDCT1_RIS_TBLN_ITEMS,
	  VDCT1_RIS_COLN_ITEMS_ITEM_CUR_REV,
	  VDCT1_RIS_COLN_ITEMS_ITEM_TYPE,
	  VDCT1_RIS_COLN_ITEMS_ITEM_CAGE_NUM,
	  part_cage_num);
  
  // Do It
  VDrisQuery(ris,NULL);
  
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Look up part_id for assy_cage_num
 */
IGRstat VDct1QryPartIdForAssyCageNum(TVDrisInfo *ris, IGRchar *part_cage_num)
{
  
  IGRstat retFlag = 0;
  
  // Arg check
  if (ris           == NULL) goto wrapup;
  if (part_cage_num == NULL) goto wrapup;
  
  // Build Query
  sprintf(ris->sql,
	  "Select %s from %s where %s=1 and %s=2 and %s='%s';",
	  VDCT1_RIS_COLN_ITEMS_ITEM_ID,
	  VDCT1_RIS_TBLN_ITEMS,
	  VDCT1_RIS_COLN_ITEMS_ITEM_TYPE,
	  VDCT1_RIS_COLN_ITEMS_ITEM_CUR_REV,
	  VDCT1_RIS_COLN_ITEMS_ITEM_CAGE_NUM,
	  part_cage_num);
  
  // Do It
  VDrisQuery(ris,NULL);
  
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}


/* -----------------------------------------------
 * Look up part_id for item_cage_num
 */
IGRstat VDct1QryPartIdForItemCageNum(TVDrisInfo *ris, IGRchar *part_cage_num)
{
  
  IGRstat retFlag = 0;
  
  // Arg check
  if (ris           == NULL) goto wrapup;
  if (part_cage_num == NULL) goto wrapup;
  
  // Build Query
  sprintf(ris->sql,
	  "Select %s from %s where %s=1 and %s='%s';",
	  VDCT1_RIS_COLN_ITEMS_ITEM_ID,
	  VDCT1_RIS_TBLN_ITEMS,
	  VDCT1_RIS_COLN_ITEMS_ITEM_CUR_REV,
	  VDCT1_RIS_COLN_ITEMS_ITEM_CAGE_NUM,
	  part_cage_num);
  
  // Do It
  VDrisQuery(ris,NULL);
  
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}


/* -----------------------------------------------
 * Look up part_id for part_num
 */
IGRstat VDct1QryPartIdForPartNum(TVDrisInfo *ris, IGRchar *part_num)
{
  
  IGRstat retFlag = 0;
  
  // Arg check
  if (ris      == NULL) goto wrapup;
  if (part_num == NULL) goto wrapup;
  
  // Build Query
  sprintf(ris->sql,
	  "Select %s from %s where %s=1 and %s=4 and %s='%s';",
	  VDCT1_RIS_COLN_ITEMS_ITEM_ID,
	  VDCT1_RIS_TBLN_ITEMS,
	  VDCT1_RIS_COLN_ITEMS_ITEM_CUR_REV,
	  VDCT1_RIS_COLN_ITEMS_ITEM_TYPE,
	  VDCT1_RIS_COLN_ITEMS_ITEM_NUM,
	  part_num);

  // Do It
  VDrisQuery(ris,NULL);
  
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Look up part_cage_num in tm_items table
 * Control fields being returned
 */
IGRstat VDct1QryPartCageNumFromItems(TVDrisInfo *ris, IGRchar *part_cage_num)
{
  
  IGRstat retFlag = 0;
  IGRchar qry[512];
  
  // Arg check
  if (ris           == NULL) goto wrapup;
  if (part_cage_num == NULL) goto wrapup;
  
  // Build Query
  sprintf(qry,
	  "Select %s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s "
	  "from %s where %s=1 and %s=4 and %s='%s';",

	  VDCT1_RIS_COLN_ITEMS_ITEM_ID,
	  VDCT1_RIS_COLN_ITEMS_ITEM_TYPE,
	  VDCT1_RIS_COLN_ITEMS_ITEM_SRC,
	  VDCT1_RIS_COLN_ITEMS_ITEM_CAGE_NUM,
	  VDCT1_RIS_COLN_ITEMS_ITEM_CAGE_CODE,
	  VDCT1_RIS_COLN_ITEMS_ITEM_NUM,
	  VDCT1_RIS_COLN_ITEMS_ITEM_REV,
	  VDCT1_RIS_COLN_ITEMS_ITEM_CUR_REV,
	  VDCT1_RIS_COLN_ITEMS_NOUN_NAME,
	  VDCT1_RIS_COLN_ITEMS_TYPE,
	  VDCT1_RIS_COLN_ITEMS_MODIFIER,
	  VDCT1_RIS_COLN_ITEMS_COMM_CODE,
	  VDCT1_RIS_COLN_ITEMS_DISCIPLINE,
	  VDCT1_RIS_COLN_ITEMS_CLASSIFICATION,
	  VDCT1_RIS_COLN_ITEMS_UNIT_OF_MEASURE,
	  VDCT1_RIS_COLN_ITEMS_COPICS_SHORT_DESC,
	  VDCT1_RIS_COLN_ITEMS_UPDATEDATE,

	  VDCT1_RIS_TBLN_ITEMS,

	  VDCT1_RIS_COLN_ITEMS_ITEM_CUR_REV,
	  VDCT1_RIS_COLN_ITEMS_ITEM_TYPE,
	  VDCT1_RIS_COLN_ITEMS_ITEM_CAGE_NUM,
	  part_cage_num);

  // Do It
  VDrisQuery(ris,qry);
  
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Returns list of noun names
 */
IGRstat VDct1QryDistinctNounNamesFromItems(TVDrisInfo *ris)
{
  IGRstat retFlag = 0;
  
  // Arg check
  if (ris == NULL) goto wrapup;
  
  // Build the query
  sprintf(ris->sql,
	  "Select distinct %s from %s where %s=1 and %s=4 order by %s;",
	  VDCT1_RIS_COLN_ITEMS_NOUN_NAME,
	  VDCT1_RIS_TBLN_ITEMS,
	  VDCT1_RIS_COLN_ITEMS_ITEM_CUR_REV,
	  VDCT1_RIS_COLN_ITEMS_ITEM_TYPE,
	  VDCT1_RIS_COLN_ITEMS_NOUN_NAME);

  // Do It
  VDrisQuery(ris,NULL);
  
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* ----------------------------------------------- 
 * Helper function for item_type where clause
 */
static IGRstat generateItemTypeWhereClause(IGRint item_type, IGRchar *buf)
{
  VDASSERT_FN("generateItemTypeWhereClause");
  IGRstat retFlag;
  
  VDASSERTW(buf);
  *buf = 0;
  
  // Filter by type
  switch(item_type) {
    case VDCT1_ITEM_TYPE_2:
      sprintf(buf," and %s=2 ",VDCT1_RIS_COLN_ITEMS_ITEM_TYPE);
      break;

    case VDCT1_ITEM_TYPE_4:
      sprintf(buf," and %s=4 ",VDCT1_RIS_COLN_ITEMS_ITEM_TYPE);
      break;
      
    case VDCT1_ITEM_TYPE_6:
      sprintf(buf," and %s=6 ",VDCT1_RIS_COLN_ITEMS_ITEM_TYPE);
      break;
  
    case VDCT1_ITEM_TYPE_2OR6:
      sprintf(buf," and (%s=2 or %s=6) ",
	      VDCT1_RIS_COLN_ITEMS_ITEM_TYPE,
	      VDCT1_RIS_COLN_ITEMS_ITEM_TYPE);
      break;
  }

  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Generic distinc query
 */
IGRstat VDct1QryDistinctItems(TVDrisInfo *ris, IGRint item_type, IGRchar *name)
{
  VDASSERT_FN("VDct1QryDistinctItems");
  
  IGRstat retFlag = 0;
  IGRchar buf[128];
  
  // Arg check
  VDASSERTW(ris);
  ris->rows = 0;
  VDASSERTW(name);
  
  // Build the query
  sprintf(ris->sql,
	  "Select distinct %s from %s where %s=1 ",
	  name,
	  VDCT1_RIS_TBLN_ITEMS,
	  VDCT1_RIS_COLN_ITEMS_ITEM_CUR_REV);

  // Filter by type
  generateItemTypeWhereClause(item_type,buf);
  if (*buf) {
    strcat(ris->sql,buf);
  }
  
  // Sort
  sprintf(buf," order by %s;",name);
  strcat(ris->sql,buf);
  
  // Do It
  VDrisQuery(ris,NULL);
  
  retFlag = 1;
  
 wrapup:
  return retFlag;
}
    
/* -----------------------------------------------
 * Generic query allowing selecting by type and by
 * an optional filter field
 *
 * Limit to current items for now
 */
IGRstat VDct1QryItems(TVDrisInfo *ris, IGRint item_type, IGRchar *name, IGRchar *value)
{
  
  IGRstat retFlag = 0;
  IGRchar qry[512];
  IGRchar buf[128];
  
  // Arg check
  if (ris == NULL) goto wrapup;
  
  // Build Query
  sprintf(qry,
	  "Select %s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s "
	  "from %s where %s=1 ",

	  VDCT1_RIS_COLN_ITEMS_ITEM_ID,
	  VDCT1_RIS_COLN_ITEMS_ITEM_TYPE,
	  VDCT1_RIS_COLN_ITEMS_ITEM_SRC,
	  VDCT1_RIS_COLN_ITEMS_ITEM_CAGE_NUM,
	  VDCT1_RIS_COLN_ITEMS_ITEM_CAGE_CODE,
	  VDCT1_RIS_COLN_ITEMS_ITEM_NUM,
	  VDCT1_RIS_COLN_ITEMS_ITEM_REV,
	  VDCT1_RIS_COLN_ITEMS_ITEM_CUR_REV,
	  VDCT1_RIS_COLN_ITEMS_NOUN_NAME,
	  VDCT1_RIS_COLN_ITEMS_TYPE,
	  VDCT1_RIS_COLN_ITEMS_MODIFIER,
	  VDCT1_RIS_COLN_ITEMS_COMM_CODE,
	  VDCT1_RIS_COLN_ITEMS_DISCIPLINE,
	  VDCT1_RIS_COLN_ITEMS_CLASSIFICATION,
	  VDCT1_RIS_COLN_ITEMS_UNIT_OF_MEASURE,
	  VDCT1_RIS_COLN_ITEMS_COPICS_SHORT_DESC,
	  VDCT1_RIS_COLN_ITEMS_UPDATEDATE,

	  VDCT1_RIS_TBLN_ITEMS,
	  VDCT1_RIS_COLN_ITEMS_ITEM_CUR_REV);

  // Filter by type
  generateItemTypeWhereClause(item_type,buf);
  if (*buf) strcat(qry,buf);
   
  // Filter by value
  if (name && *name && value && *value) {
    sprintf(buf,"and %s='%s' ",name,value);
    strcat(qry,buf);
  }

  // And the sort
  sprintf(buf,"order by %s;",VDCT1_RIS_COLN_ITEMS_ITEM_CAGE_NUM);
  strcat(qry,buf);
  
  // Do It
  VDrisQuery(ris,qry);
  
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Look up items for noun_name
 */
IGRstat VDct1QryNounNameFromItems(TVDrisInfo *ris, IGRchar *noun_name)
{
  
  IGRstat retFlag = 0;
  IGRchar qry[512];
  IGRchar buf[128];
  
  // Arg check
  if (ris == NULL) goto wrapup;
  
  // Build Query
  sprintf(qry,
	  "Select %s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s "
	  "from %s ",

	  VDCT1_RIS_COLN_ITEMS_ITEM_ID,
	  VDCT1_RIS_COLN_ITEMS_ITEM_TYPE,
	  VDCT1_RIS_COLN_ITEMS_ITEM_SRC,
	  VDCT1_RIS_COLN_ITEMS_ITEM_CAGE_NUM,
	  VDCT1_RIS_COLN_ITEMS_ITEM_CAGE_CODE,
	  VDCT1_RIS_COLN_ITEMS_ITEM_NUM,
	  VDCT1_RIS_COLN_ITEMS_ITEM_REV,
	  VDCT1_RIS_COLN_ITEMS_ITEM_CUR_REV,
	  VDCT1_RIS_COLN_ITEMS_NOUN_NAME,
	  VDCT1_RIS_COLN_ITEMS_TYPE,
	  VDCT1_RIS_COLN_ITEMS_MODIFIER,
	  VDCT1_RIS_COLN_ITEMS_COMM_CODE,
	  VDCT1_RIS_COLN_ITEMS_DISCIPLINE,
	  VDCT1_RIS_COLN_ITEMS_CLASSIFICATION,
	  VDCT1_RIS_COLN_ITEMS_UNIT_OF_MEASURE,
	  VDCT1_RIS_COLN_ITEMS_COPICS_SHORT_DESC,
	  VDCT1_RIS_COLN_ITEMS_UPDATEDATE,

	  VDCT1_RIS_TBLN_ITEMS);

  //sprintf(qry,"Select * from %s ",VDCT1_RIS_TBLN_ITEMS);
  
  if (noun_name) {
    sprintf(buf,
	    "where %s='%s' order by %s;",
	    VDCT1_RIS_COLN_ITEMS_NOUN_NAME,
	    noun_name,
	    VDCT1_RIS_COLN_ITEMS_ITEM_CAGE_NUM);
  }
  else {
    sprintf(buf,"order by %s;",VDCT1_RIS_COLN_ITEMS_ITEM_CAGE_NUM);
  }
  strcat(qry,buf);
  
  // Do It
  VDrisQuery(ris,qry);
  
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Look up isdp_cage_num in isdp_item table
 */
IGRstat VDct1QryPartCageNumFromIsdpItems(TVDrisInfo *ris, IGRchar *isdp_cage_num)
{
  IGRstat retFlag = 0;
  
  // Arg check
  if (ris           == NULL) goto wrapup;
  if (isdp_cage_num == NULL) goto wrapup;
  
  // Build query
  sprintf(ris->sql,
	  "Select item_cage_num from tm_isdp_item where isdp_cage_num='%s';",
	  VDCT1_RIS_COLN_ISDPITEMS_ITEM_CAGE_NUM,
	  VDCT1_RIS_TBLN_ISDPITEMS,
	  VDCT1_RIS_COLN_ISDPITEMS_ISDP_CAGE_NUM,
	  isdp_cage_num);

  // Do It
  VDrisQuery(ris,NULL);
  
  retFlag = 1;
  
 wrapup:
  return retFlag;
}















