/* $Id: VDct1Load.c,v 1.2 2001/02/11 17:24:16 ahundiak Exp $  */
/***************************************************************************
 * I/VDS
 *
 * File:        vdct1/part/VDct1Load.I
 *
 * Description: Load Part Table Processing
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDct1Load.c,v $
 *      Revision 1.2  2001/02/11 17:24:16  ahundiak
 *      Renamed VDris2 to VDrisc
 *
 *      Revision 1.1  2001/01/12 14:35:59  art
 *      sp merge
 *
 * Revision 1.1  2000/12/07  17:39:48  pinnacle
 * ah
 *
# Revision 1.5  2000/07/13  12:26:42  pinnacle
# Replaced: vds/vdct1/part/VDct1Load.I for:  by jdsauby for Service Pack
#
# Revision 1.4  2000/06/30  17:28:24  pinnacle
# ah
#
# Revision 1.3  2000/06/04  17:04:56  pinnacle
# ah
#
# Revision 1.2  2000/06/02  14:35:42  pinnacle
# ah
#
# Revision 1.1  2000/05/31  21:04:10  pinnacle
# ah
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

/* ------------------------------------------------------
 * Load a single attribute into the part attributes table
 */
IGRstat VDct1LoadAttrsTableRecord(TVDct1PartInfo *part, IGRint idx)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  
  IGRchar sql[256];

  TVDct1PartFldInfo fld;
  
  // Arg check
  if ((part == NULL) || (*part->part_id == 0)) goto wrapup;
  
  // Get the field
  VDct1GetPartFldInfoForIdx(idx,part,&fld);
  if (fld.data == NULL) goto wrapup;

  // Skip empty fields
  if (*fld.data == 0) goto wrapup;

  // Do it
  sprintf(sql,"Insert into %s values('%s','%s','%s',%d,'%s');",
	  VDCT1_RIS_TBLN_ATTRS,
	  part->part_id,
	  fld.name,
	  fld.data,
	  fld.idx,
	  fld.info);
  
  sts = VDrisExecute(sql);
  
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

IGRstat VDct1SetPartsRecordDefaults(TVDct1PartInfo *part)
{
  IGRstat retFlag = 0;
  
  if (*part->discipline     == 0) strcpy(part->discipline,    "0");
  if (*part->classification == 0) strcpy(part->classification,"0");
  if (*part->updatedate     == 0) strcpy(part->updatedate,part->creation_date);
  if (*part->item_type      == 0) strcpy(part->item_type,   "4");

  // Done
  retFlag = 1;
   
wrapup:
  return retFlag;
}


/* -----------------------------------------------
 * Load a single part into the database table
 * Already tested for being logged in
 */
IGRstat VDct1LoadPartsTableRecord(TVDct1PartInfo *a_part)
				  
{
  IGRstat retFlag = 0;
  IGRstat sts;
  IGRchar sql[1024];
  
  IGRint  idx;
  TVDct1PartInfo part;
  
  // Arg check
  if (a_part == NULL) goto wrapup;
  part = *a_part;
  
  // Better have an id
  if (*part.part_id == 0) {
    printf("*** Tried to write parts record with no part_id\n");
    goto wrapup;
  }
  
  // Some default values
  sts = VDct1SetPartsRecordDefaults(&part);
  if (!sts) {
    printf("Set Default Values failed\n");
    goto wrapup;
  }
 
  // Doit
  sprintf(sql,
	  "Insert into %s values "
	  "('%s',%d,%d,'%s','%s','%s','%s',%d,'%s','%s','%s','%s',%s,%s,'%s','%s','%s');",
	  VDCT1_RIS_TBLN_ITEMS,
	  part.part_id,
	  atoi(part.item_type),
          9,                       // item_src
	  part.part_cage_num,
	  part.part_cage_code,
	  part.part_num,
	  part.part_rev,
          atoi(part.cur_rev),

	  part.noun_name,
	  part.type,
	  part.modifier,
	  "",                      // comm_code

	  part.discipline,
	  part.classification,

	  part.unit_of_measure,
	  part.copics_short_description,
	  part.updatedate);
  
  sts = VDrisExecute(sql);
  if (!(sts & 1)) {
    printf("*** Problem writing parts record to database table\n");
    printf("PART %s\n",part.part_num);
    goto wrapup;
  }
  
  // Now fill in the attr table
  for(idx = 0; idx < VDCT1_PART_FLD_IDX_LAST; idx++) {
    VDct1LoadAttrsTableRecord(&part,idx);
  }

  // Done
  retFlag = 1;
  
 wrapup:

  return retFlag;
}

/* -----------------------------------------------
 * Loads parts table from dump file
 */
IGRstat VDct1LoadPartsTable()
{
  IGRstat retFlag = 0;
  IGRstat sts;
  
  TVDct1PartInfos infos;
  TVDct1PartInfo *part;
  
  IGRint i,cnt;
  IGRint current_cnt = 0;
  
  
  FILE *file = NULL;
  IGRchar buf[64];
  
  // Init
  VDct1InitPartInfos(&infos);

  // Load records from file
  UI_status("Reading parts from file...");
  VDct1LoadDelimitedPartInfos(&infos,0);
  
  // Sort them
  qsort(infos.parts,infos.cnt,sizeof(TVDct1PartInfo*),VDct1SortPartsByPartCageNum);
  sprintf(buf,"Read %d parts",infos.cnt);
  UI_status(buf);
  
  // Empty the table
  VDct1EmptyPartsTable();
  
  // Dump file
  file = fopen("ops_load.txt","wt");
  if (file == NULL) file = stdout;
  
  // Dump out results
  cnt = infos.cnt;
  // if (cnt > 200) cnt = 200;
  for(i = 0; i < cnt; i++) {

    sts = VDct1IsPartCurrent(&infos,i);
    if (sts & 1) {
      
      part = infos.parts[i];
      current_cnt++;

      VDct1LoadPartsTableRecord(part);
        
      fprintf(file,"%-4s %-8s %-5s %-19s %s%s %-25s %-2s %-25s %-19s\n",
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
    if (!(i % 10)) {
      sprintf(buf,"Processing %d of %d",i,infos.cnt);
      UI_status(buf);
    }    
  }
  
  fprintf(file,"### Total Parts Loaded %d\n",current_cnt);
   printf(     "### Total Parts Loaded %d\n",current_cnt);
   sprintf(buf,"Loaded %d parts",current_cnt);
   UI_status(buf);
   
  // Done
  retFlag =1;
  
 wrapup:
  if ((file) && (file != stdout)) fclose(file);
  
  VDct1FreePartInfos(&infos);
  return retFlag;
}

/* -----------------------------------------------
 * Empty the parts tables
 */
IGRstat VDct1EmptyPartsTable()
{
  IGRstat retFlag = 0;
  IGRstat sts;

  IGRchar sql[256];
  
  // Do it
  sprintf(sql,"Delete from %s;",VDCT1_RIS_TBLN_ITEMS);
  sts = VDrisExecute(sql);

  sprintf(sql,"Delete from %s;",VDCT1_RIS_TBLN_ATTRS);
  sts = VDrisExecute(sql);

  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}












