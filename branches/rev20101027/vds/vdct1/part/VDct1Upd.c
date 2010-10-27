/* $Id: VDct1Upd.c,v 1.2 2001/02/11 17:24:17 ahundiak Exp $  */
/***************************************************************************
 * I/VDS
 *
 * File:        vdct1/part/VDct1Upd.c
 *
 * Description: Load Part Table Processing
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDct1Upd.c,v $
 *      Revision 1.2  2001/02/11 17:24:17  ahundiak
 *      Renamed VDris2 to VDrisc
 *
 *      Revision 1.1  2001/01/12 14:35:59  art
 *      sp merge
 *
 * Revision 1.1  2000/12/07  17:39:48  pinnacle
 * ah
 *
# Revision 1.2  2000/07/13  12:27:16  pinnacle
# Replaced: vds/vdct1/part/VDct1Upd.I for:  by jdsauby for Service Pack
#
# Revision 1.1  2000/07/07  13:47:24  pinnacle
# Created: vds/vdct1/part/VDct1Upd.I by jdsauby for Service Pack
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 07/03/00  js      Creation
 *
 ***************************************************************************/
#include "VDtypedefc.h"
#include "VDassert.h"

#include "VDrisc.h"

#include "VDct1Ris.h"
#include "VDct1Part.h"

IGRstat VDct1DeletePartsTableRecord(TVDct1PartInfo *part)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  IGRchar sqlItems[1064],sqlAttrs[1064];
  IGRstat traceFlag = 0;

  //say hi
  if (traceFlag) printf (">>> Entering VDct1DeletePartsTableRecord\n");

  //Arg Check
  if (part  == NULL) goto wrapup;
 

  //Do it
  //delete item_id from tm_items
  sprintf(sqlItems,"Delete from %s where %s = '%s';",
	  VDCT1_RIS_TBLN_ITEMS,
	  VDCT1_RIS_COLN_ITEMS_ITEM_ID, part->part_id);
  
  sts = VDrisExecute(sqlItems);
  if (!sts) goto wrapup;

  //update item_id_ps in tm_item_ps to new item_id from file
  sprintf(sqlAttrs,"Delete from %s where %s = '%s';",
	  VDCT1_RIS_TBLN_ATTRS,
	  VDCT1_RIS_COLN_ATTRS_PART_ID, part->part_id);
  
  sts = VDrisExecute(sqlAttrs);
  if (!sts) goto wrapup;
  
  // Done
  retFlag = 1;
  goto wrapup;
  
  
wrapup:
    if (traceFlag) printf ("<<< Leaving VDct1DeletePartsTableRecord\n");
    if (!retFlag) printf("Delete Record failed for %s\n",part->part_id);
    return retFlag;
  
}



IGRstat VDct1UpdateProductStructure(TVDct1PartInfo *part,
				    TVDct1PartInfo *partx)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  IGRchar sqlItem[1064],sqlItemPs[1064];
  IGRstat traceFlag = 0;

  //say hi
  if (traceFlag) printf (">>> Entering VDct1UpdateProductStructure\n");

  //Arg Check
  if (part  == NULL) goto wrapup;
  if (partx == NULL) goto wrapup;
  

  //Do it
  //update item_id in tm_item_ps to new item_id from file
  sprintf(sqlItem,"Update tm_item_ps set item_id = '%s' where item_id = '%s';",
	  part->part_id,
	  partx->part_id);
  
  sts = VDrisExecute(sqlItem);
  if (!sts) goto wrapup;

  //update item_id_ps in tm_item_ps to new item_id from file
  sprintf(sqlItemPs,"Update tm_item_ps set item_id_ps = '%s' where item_id_ps = '%s';",
	  part->part_id,
	  partx->part_id);
  
  sts = VDrisExecute(sqlItemPs);
  if (!sts) goto wrapup;
  
  // Done
  retFlag = 1;
  goto wrapup;
  
  
wrapup:
    if (traceFlag) printf ("<<< Leaving VDct1UpdateProductStructure\n");
    if (!retFlag) printf("Update Product structure failed for %s\n",partx->part_id);
    return retFlag;
  
}


IGRstat VDct1UpdatePartCurRev(TVDct1PartInfo *part,
			      IGRint  curRev)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  IGRchar sqlItems[1064],sqlAttrs[1064];
  IGRstat traceFlag = 0; 
  


  //say hi
  // traceFlag = 1;
  if (traceFlag) printf (">>> Entering VDct1UpdatePartCurRev\n");

  //Arg Check
  if (part   == NULL) goto wrapup;
  //if (curRev == NULL) goto wrapup;
 
  //Do it
  //update tm_items table  
  sprintf(sqlItems,"Update %s set %s = %d where %s = '%s';",
	  VDCT1_RIS_TBLN_ITEMS,
	  VDCT1_RIS_COLN_ITEMS_ITEM_CUR_REV, curRev,
	  VDCT1_RIS_COLN_ITEMS_ITEM_ID, part->part_id); 
  
  sts = VDrisExecute(sqlItems);
  if (!sts) goto wrapup;
  
  //update tm_item_attrs table
  sprintf(sqlAttrs,"Update %s set %s = '%d' where %s = '%s' and %s = '%s';",
	  VDCT1_RIS_TBLN_ATTRS,
	  VDCT1_RIS_COLN_ATTRS_VALUE, curRev,
	  VDCT1_RIS_COLN_ATTRS_PART_ID, part->part_id,
	  VDCT1_RIS_COLN_ATTRS_NAME, VDCT1_RIS_COLN_ITEMS_ITEM_CUR_REV);
 
  sts = VDrisExecute(sqlAttrs);
  if (!sts) goto wrapup;
   
  //Done
  retFlag = 1;
  goto wrapup;
  
wrapup:
  if (traceFlag) printf ("<<< Leaving VDct1UpdatePartCurRev\n");
  return retFlag;
  
}

//static int traceFlagx = 1;
  
IGRstat VDct1ComparePartsTableRecordInfo(TVDct1PartInfo *part,
					 TVDct1PartInfo *partx)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  IGRchar partType[64];
  IGRstat traceFlag = 0;
  IGRint  i = 0;
  TVDct1PartFldInfo fld,fldx;
  
  IGRint flag = 0;
  
  /* Return 1 if records are different
   * Return 0 if records are same
   */
  
  //say hi
  if (traceFlag) printf(">>> Entering VDct1ComparePartsTableRecord\n");


  // Need to save part_type of partx, in case it was changed in DB
  strcpy(partType,partx->item_type);
  strcpy(partx->item_type,part->item_type);
  //solving troubles with br from file that will never be in DB
  strcpy(partx->br,part->br);
  flag = 1;
  
  //Set default values for DB partx
  sts = VDct1SetPartsRecordDefaults(partx);
  if (!sts) {
    printf("Set Default Values failed\n");
    goto wrapup;
  }

  // Do it
  while(VDct1GetPartFldInfoForIdx(i,part,&fld)) {
     
    VDct1GetPartFldInfoForIdx(i,partx,&fldx);  
    if ( strcmp(fld.data,fldx.data) ) {
      // printf("FILE: %s = %s, DB: %s = %s\n",fld.name,fld.data,fldx.name,fldx.data);
      retFlag = 1;
      goto wrapup;
    }
    i++;
  }

wrapup:
  if (traceFlag) printf("<<< Leaving VDct1ComparePartsTableRecord, sts = %d\n",retFlag);
  if (flag) {  
    strcpy(partx->item_type,partType);
    //strcpy(partx->br,part->br);
  }
  return retFlag;
  
}


IGRstat VDct1UpdatePartsTableRecordInfo(TVDct1PartInfo *part,
					TVDct1PartInfo *partx)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  IGRstat traceFlag = 0;
  IGRint  curRev;
  

  //say hi
  if (traceFlag) printf (">>> Entering VDct1UpdatePartsTableRecordInfo\n");
  
  // Arg check
  if (part == NULL) goto wrapup;
  if (partx == NULL) goto wrapup;
 
  //Load part into db, with part_type
  strcpy(part->item_type,partx->item_type);
  //printf("part->item_type = %s\n",part->item_type);
  
  if ( !strcmp(part->part_id,partx->part_id) ) {  //part_id = partx_id
    //Delete record from tables
    sts = VDct1DeletePartsTableRecord(partx);
    if (!sts) goto wrapup;
    
    //Load it
    sts = VDct1LoadPartsTableRecord(part);
    if (!sts) goto wrapup;
    
    //Done
    retFlag = 1;
    goto wrapup;
    
  }
  
  else {                                          //part_id != partx_id
    //Load it
    sts = VDct1LoadPartsTableRecord(part);
    if (!sts) goto wrapup;
    
    //set cur_rev of partx to 0 for not current
    curRev = 0;
    sts = VDct1UpdatePartCurRev(partx, curRev);
    if (!sts) goto wrapup;
    
    //update tm_item_ps, product structure with new
    sts = VDct1UpdateProductStructure(part, partx);     
    if (!sts) goto wrapup;
    
    //Done
    retFlag = 1;
    goto wrapup;
  }
  
  
  
wrapup:
  if (traceFlag) printf ("<<< Leaving VDct1UpdatePartsTableRecordInfo\n");
  if (!retFlag)  printf("Update of part %s failed\n",part->part_cage_num);
  return retFlag;
  
}


IGRstat VDct1UpdatePartsTableRecord(TVDct1PartInfo *part)
{
  IGRint  retFlag = 0;
  IGRstat sts;
  IGRchar sql[1024],part_idx[128];
  IGRstat traceFlag = 0;
  TVDct1PartInfo partx;

  IGRint  idx;
  
  /* *****************************************************************************
   * for this function, we will return a value related to the action that occurred
   * 0 - Failure of function
   * 1 - Nothing updated or loaded
   * 3 - Part was updated
   * 5 - Part was loaded as new
   ******************************************************************************/

  
  // Entering
  if (traceFlag) printf (">>> Entering VDct1UpdatePartsTableRecord\n");
  
  // Arg check
  if (part == NULL) goto wrapup;

  // Better have an id
  if (*part->part_id == 0) {
    printf("*** Tried to write parts record with no part_id\n");
    goto wrapup;
  }

  // check to see if item exists in DB
  sts = VDct1ReadPartIdForItemCageNum(part->part_cage_num,
				      part_idx);  
  if (sts & 1) {
    // get partx with part_idx
    sts = VDct1ReadPartFromAttrsTable(part_idx,
				      &partx);
    if (!sts) goto wrapup;
    
    //Compare part from file with partx from DB
    sts =  VDct1ComparePartsTableRecordInfo(part, &partx);
    if (sts) {   
      //printf ("Records are different\n");
      sts = VDct1UpdatePartsTableRecordInfo(part, &partx);
      if (!sts) goto wrapup;
      
      printf("Updated Part %s\n",part->part_cage_num);
      retFlag = 3;
      goto wrapup;  
    }
    else {
      retFlag = 1;
      //printf ("Records are the same\n");
      goto wrapup;
    } 
  }  
  else {   
    //part does not exist in DB, and needs to be loaded
    sts = VDct1LoadPartsTableRecord(part);
    if (!sts) goto wrapup;
    
    printf("Loaded  Part %s\n",part->part_cage_num);
    retFlag = 5;
    goto wrapup;

  }
  
  
wrapup:
  if (traceFlag) printf ("<<< Leaving VDct1UpdatePartsTableRecord\n");
  return retFlag;
  
}


/* -----------------------------------------------
 * Loads parts table from dump file
 */
IGRstat VDct1UpdatePartsTable()
{
  IGRstat retFlag = 0;
  IGRstat sts;
  IGRint  action;
  
  TVDct1PartInfos infos;
  TVDct1PartInfo *part;
  
  IGRint i,cnt;
  IGRint update_cnt = 0;
  IGRint loaded_cnt = 0;
  
  FILE *file = NULL;
  IGRchar buf[64];
  
  // Init
  VDct1InitPartInfos(&infos);

  // Load records from file
  UI_status("Reading parts from file...");
  VDct1UpdateDelimitedPartInfos(&infos,0);
  
  // Sort them
  qsort(infos.parts,infos.cnt,sizeof(TVDct1PartInfo*),VDct1SortPartsByPartCageNum);
  sprintf(buf,"Read %d parts",infos.cnt);
  UI_status(buf);
  

  // Dump file
  file = fopen("ops_update.txt","wt");
  if (file == NULL) file = stdout;
  
  // Dump out results
  cnt = infos.cnt;
  
  // if (cnt > 200) cnt = 200;
  for(i = 0; i < cnt; i++) {

    sts = VDct1IsPartCurrent(&infos,i);
    
    if (sts & 1) {
      
      part = infos.parts[i];
      
      sts = VDct1UpdatePartsTableRecord(part);
      if (sts == 3) {
	update_cnt++;
      
	fprintf(file,"Updated: %-4s %-8s %-5s %-19s %s%s %-25s %-2s %-25s %-19s\n",
		part->br,
		part->part_id,
		part->part_cage_code,
		part->part_num,
		part->part_rev,
		part->cur_rev,
		part->noun_name,
		part->unit_of_measure,
		part->copics_short_description,
		part->updatedate);
      }

      if (sts == 5) {
	loaded_cnt++;
      
	fprintf(file,"Loaded:  %-4s %-8s %-5s %-19s %s%s %-25s %-2s %-25s %-19s\n",
		part->br,
		part->part_id,
		part->part_cage_code,
		part->part_num,
		part->part_rev,
		part->cur_rev,
		part->noun_name,
		part->unit_of_measure,
		part->copics_short_description,
		part->updatedate);
      }
      
    }
    if (!(i % 10)) {
      sprintf(buf,"Processing %d of %d",i,infos.cnt);
      UI_status(buf);
    }    
  }
  
  fprintf(file,"### Total Parts Updated %d\n",update_cnt);
  printf(      "### Total Parts Updated %d\n",update_cnt);
  fprintf(file,"### Total Parts Loaded  %d\n",loaded_cnt);
  printf(      "### Total Parts Loaded  %d\n",loaded_cnt);
  sprintf(buf, "Updated %d parts",update_cnt+loaded_cnt);
  UI_status(buf);
   
  // Done
  retFlag =1;
  
 wrapup:
  if ((file) && (file != stdout)) fclose(file);
  
  VDct1FreePartInfos(&infos);
  return retFlag;
}










