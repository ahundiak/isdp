/* $Id: VDct1Delim.c,v 1.2 2001/02/11 17:24:16 ahundiak Exp $  */
/***************************************************************************
 * I/VDS
 *
 * File:        vdct1/part/VDct1Delim.c
 *
 * Description: Delimited Part Processing
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDct1Delim.c,v $
 *      Revision 1.2  2001/02/11 17:24:16  ahundiak
 *      Renamed VDris2 to VDrisc
 *
 *      Revision 1.1  2001/01/12 14:35:59  art
 *      sp merge
 *
 * Revision 1.1  2000/12/07  17:39:48  pinnacle
 * ah
 *
# Revision 1.4  2000/07/13  12:26:26  pinnacle
# Replaced: vds/vdct1/part/VDct1Delim.I for:  by jdsauby for Service Pack
#
# Revision 1.3  2000/06/04  17:04:56  pinnacle
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

/* -----------------------------------------------
 * Copies the delimited data from buf to the field specified
 * by idx
 */
IGRstat VDct1LoadDelimitedPartFldInfo(IGRchar **buf, TVDct1PartInfo *part, IGRint idx)
{
  IGRstat retFlag = 0;
  
  IGRchar *p;
  IGRchar *pd;

  IGRchar data[80];
  TVDct1PartFldInfo fld;
  
  // Buffer
  if (buf == NULL) goto wrapup;
  p = *buf;
  if (p == NULL) goto wrapup;

  // Ok from now
  retFlag = 1;
  
  // Might be at end of line
  if (*p == NULL) goto wrapup;
  
  // See if have delim char
  pd = strchr(p,VDCT1_PART_DELIM_CHAR);
  if (pd) *pd = 0;
  else     pd = p + strlen(p) - 1;
  
  // Copy It
  strcpy(data,p);
   
  // Trunc It 
  for(p = data + strlen(data) - 1; (p >= data) && (*p == ' '); p--);
  *(p+1) = 0;

  // Get rid of leading blanks as well
  for(p = data; *p == ' '; p++);
  if (p != data) strcpy(data,p);
  
  // Replace any ' 
  for(p = data; *p; p++) {
    if (*p == '\'') *p = ' ';
  }
  
  // Update pointer
  *buf = (pd+1);
  
  // Now find the part field to map to
  VDct1GetPartFldInfoForIdx(idx,part,&fld);
  if (fld.data) {
    *(data + fld.len) = 0; // Just to make sure
    strcpy(fld.data,data);
  }
  else printf("*** Unknown Delimited Field Index %d\n",idx);
  
  // Done
  // printf("FLD %s\n",data);
  
wrapup:
  return retFlag;
}
  
/* -----------------------------------------------
 * Parse a text buffer into a part info structure
 * buf has already been cleaned up
 * Make a copy because the field extractor changes the data
 */
IGRstat VDct1LoadDelimitedPartInfo(TVDct1PartInfos *infos, IGRchar *buf, IGRint filter1)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  
  IGRint  i;
  IGRchar *p;
  IGRchar bufx[1024];
  IGRchar part_id[40];
  
  TVDct1PartInfo *part = NULL;
  
  // Arg check
  if (infos == NULL) goto wrapup;
  if (buf   == NULL) goto wrapup;
  
  //printf("BUF %s\n",buf);
  
  // Get a part
  part = calloc(1,sizeof(TVDct1PartInfo));
  if (part == NULL) goto wrapup;
  
  // Copy the buf because the field processor changes it
  strcpy(bufx,buf);
  p = bufx;
  
  // Go field by field because things change

  // Convert cur_rev to integer (faster database ops)
  VDct1LoadDelimitedPartFldInfo(&p,part,VDCT1_PART_FLD_IDX_CUR_REV);
  if (*part->cur_rev == 'Y') strcpy(part->cur_rev,"1");
  else                       strcpy(part->cur_rev,"0");
  
  // Add ops tag to part_id
  VDct1LoadDelimitedPartFldInfo(&p,part,VDCT1_PART_FLD_IDX_PART_ID);
  sprintf(part_id,"9-%s",part->part_id);
  strcpy(part->part_id,part_id);
  
  // Mino id
  VDct1LoadDelimitedPartFldInfo(&p,part,VDCT1_PART_FLD_IDX_PART_CAGE_CODE);
  VDct1LoadDelimitedPartFldInfo(&p,part,VDCT1_PART_FLD_IDX_PART_NUM);
  VDct1LoadDelimitedPartFldInfo(&p,part,VDCT1_PART_FLD_IDX_PART_REV);

  // Build cage_num
  sprintf(part->part_cage_num,"%s-%s",part->part_cage_code,part->part_num);
  
  // Rest
  VDct1LoadDelimitedPartFldInfo(&p,part,VDCT1_PART_FLD_IDX_PART_FAMILY);
  VDct1LoadDelimitedPartFldInfo(&p,part,VDCT1_PART_FLD_IDX_NOUN_NAME);
  VDct1LoadDelimitedPartFldInfo(&p,part,VDCT1_PART_FLD_IDX_TYPE);
  VDct1LoadDelimitedPartFldInfo(&p,part,VDCT1_PART_FLD_IDX_MODIFIER);
  VDct1LoadDelimitedPartFldInfo(&p,part,VDCT1_PART_FLD_IDX_MATERIAL);
  VDct1LoadDelimitedPartFldInfo(&p,part,VDCT1_PART_FLD_IDX_PART_SIZE);
  VDct1LoadDelimitedPartFldInfo(&p,part,VDCT1_PART_FLD_IDX_UNIT_OF_MEASURE);
  VDct1LoadDelimitedPartFldInfo(&p,part,VDCT1_PART_FLD_IDX_PART_STATUS);
  VDct1LoadDelimitedPartFldInfo(&p,part,VDCT1_PART_FLD_IDX_REV_APPROVED);
  VDct1LoadDelimitedPartFldInfo(&p,part,VDCT1_PART_FLD_IDX_SUPERSEDED_BY);
  VDct1LoadDelimitedPartFldInfo(&p,part,VDCT1_PART_FLD_IDX_ASSEMBLY_REQUIRED);
  VDct1LoadDelimitedPartFldInfo(&p,part,VDCT1_PART_FLD_IDX_CFE_GFE);
  VDct1LoadDelimitedPartFldInfo(&p,part,VDCT1_PART_FLD_IDX_MAKE_BUY);
  VDct1LoadDelimitedPartFldInfo(&p,part,VDCT1_PART_FLD_IDX_ILS_WORTHY);
  VDct1LoadDelimitedPartFldInfo(&p,part,VDCT1_PART_FLD_IDX_SHOCK_GRADE);
  VDct1LoadDelimitedPartFldInfo(&p,part,VDCT1_PART_FLD_IDX_NATIONAL_STOCK_NUMBER);
  VDct1LoadDelimitedPartFldInfo(&p,part,VDCT1_PART_FLD_IDX_HAZARDOUS_MATERIAL);
  VDct1LoadDelimitedPartFldInfo(&p,part,VDCT1_PART_FLD_IDX_PRODUCTION_MATERIAL);

  VDct1LoadDelimitedPartFldInfo(&p,part,VDCT1_PART_FLD_IDX_CREATION_DATE);
  VDct1LoadDelimitedPartFldInfo(&p,part,VDCT1_PART_FLD_IDX_CREATOR_ID);
  VDct1LoadDelimitedPartFldInfo(&p,part,VDCT1_PART_FLD_IDX_CHANGE_DATE);
  VDct1LoadDelimitedPartFldInfo(&p,part,VDCT1_PART_FLD_IDX_CHANGE_ID);
  VDct1LoadDelimitedPartFldInfo(&p,part,VDCT1_PART_FLD_IDX_INTERCHANGEABILITY_AFFECTED);
  VDct1LoadDelimitedPartFldInfo(&p,part,VDCT1_PART_FLD_IDX_COPICS_SHORT_DESCRIPTION);
  VDct1LoadDelimitedPartFldInfo(&p,part,VDCT1_PART_FLD_IDX_PRESSURE);
  VDct1LoadDelimitedPartFldInfo(&p,part,VDCT1_PART_FLD_IDX_ISDP_STATUS);
  VDct1LoadDelimitedPartFldInfo(&p,part,VDCT1_PART_FLD_IDX_GRADE);
  VDct1LoadDelimitedPartFldInfo(&p,part,VDCT1_PART_FLD_IDX_LENGTH);
  VDct1LoadDelimitedPartFldInfo(&p,part,VDCT1_PART_FLD_IDX_VOLTAGE);
  VDct1LoadDelimitedPartFldInfo(&p,part,VDCT1_PART_FLD_IDX_WIDTH);
  VDct1LoadDelimitedPartFldInfo(&p,part,VDCT1_PART_FLD_IDX_DISCIPLINE);
  VDct1LoadDelimitedPartFldInfo(&p,part,VDCT1_PART_FLD_IDX_CLASSIFICATION);
  VDct1LoadDelimitedPartFldInfo(&p,part,VDCT1_PART_FLD_IDX_UPDATEBY);
  VDct1LoadDelimitedPartFldInfo(&p,part,VDCT1_PART_FLD_IDX_UPDATEDATE);
  VDct1LoadDelimitedPartFldInfo(&p,part,VDCT1_PART_FLD_IDX_BR);

  // Check fields
  if (strcmp(part->br,"<br>")) {
    printf("*** Record Not Loaded Properly \n"
	   "NUM %-19s, REV %-2s, CDESC %s BR %s\n",
	   part->part_num,part->part_rev,part->copics_short_description,part->br);
    free(part);
    goto wrapup;
  }
  
  // filter1 means only use current records
  if ((filter1) && (*part->cur_rev != '1')) {
    free(part);
    goto wrapup;
  }
  
  //set default values
  VDct1SetPartsRecordDefaults(part);
 

  // Add it to the list
  VDct1AddPartInfo(infos,part);
  
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Load in next text record which is terminated by a <br>
 * In some cases, need to concat multiple lines in the file
 * to get 1 record
 */
IGRstat VDct1LoadDelimitedPartTextRecord(FILE *file, IGRchar *buf)
{
  IGRstat retFlag = 0;
  
  IGRchar bufx[1024];
  IGRchar *p;
  
  // Read it
 loop1:
  p = fgets(buf,1024,file);
  if (p == NULL) goto wrapup;  // End of file
  
  // Clean it
  for(p = buf; *p >= ' '; p++); *p = 0;
  if (*buf == 0)        goto loop1;
  if (strlen(buf) < 10) goto loop1;

  // Convert the cog-mino to cog|mino
  // if (*(buf+5) == '-') *(buf+5) = VDCT1_PART_DELIM_CHAR;

  // <br> is end of record
 loop2:
  p = buf + strlen(buf) - 4;
  if (!strcmp(p,"<br>")) {
    //sprintf(p,"%c<br>",VDCT1_PART_DELIM_CHAR);
    retFlag = 1;
    goto wrapup;
  }
  // printf("BUF: %s\n",buf);
  
  // Multiple text lines make up the file
  p = fgets(bufx,1024,file);
  if (p == NULL) goto wrapup;

  // Clean
  for(p = bufx; *p >= ' '; p++); *p = 0;
  
  // Concat
  strcat(buf,bufx);
  
  // Look again for end of record
  goto loop2;
  

 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Loads in list of part infos from file
 */
IGRstat VDct1LoadDelimitedPartInfosFromFile(TVDct1PartInfos *infos, IGRchar *fileName, IGRint filter1)
{
  IGRstat retFlag = 0;
  FILE *file = NULL;
  IGRchar buf[1024];
  
  IGRint cnt = 0;
  
  // Arg check
  if (infos == NULL) goto wrapup;
  if (fileName == NULL) goto wrapup;
  
  // Open
  file = fopen(fileName,"rt");
  if (file == NULL) {
    printf("*** Unable to open %s for reading\n",fileName);
    goto wrapup;
  }
  
  // Cycle through
  while(VDct1LoadDelimitedPartTextRecord(file,buf)) {

    // Add the buffer to the list
    // VDct1LoadFixedWidthPartInfo(infos,buf);

    // Add the buffer to the list
    VDct1LoadDelimitedPartInfo(infos,buf,filter1);

    if (cnt > 2000000) goto wrapup;
    cnt++;
    
  }
  
  // Done
  retFlag = 1;
  
 wrapup:
  if (file) fclose(file);
  return retFlag;
}

/* -----------------------------------------------
 * Loads in list of part infos
 * Understands all the files which contain data
 */
IGRstat VDct1LoadDelimitedPartInfos(TVDct1PartInfos *infos, IGRint filter1)
{
  IGRstat retFlag = 0;

  // Load records from file
  // VDct1LoadPartInfosFromFile(&infos,"ISDP_Staging_tree_Info_Equipment.txt");
  VDct1LoadDelimitedPartInfosFromFile(infos,"all_records.txt",filter1);
  
  // Done
  retFlag = 1;
  
 wrapup:

  return retFlag;
}

/* -----------------------------------------------
 * Loads in list of part infos for updates
 * Understands all the files which contain data
 */
IGRstat VDct1UpdateDelimitedPartInfos(TVDct1PartInfos *infos, IGRint filter1)
{
  IGRstat retFlag = 0;

  // Load records from file
  // VDct1LoadPartInfosFromFile(&infos,"ISDP_Staging_tree_Info_Equipment.txt");
  VDct1LoadDelimitedPartInfosFromFile(infos,"upd_records.txt",filter1);
  
  // Done
  retFlag = 1;
  
 wrapup:

  return retFlag;
}


/* -----------------------------------------------
 * Loads in list of part infos
 */
IGRstat VDct1TestLoadDelimitedPartInfos()
{
  IGRstat retFlag = 0;
  IGRstat sts;
  
  TVDct1PartInfos infos;
  TVDct1PartInfo *part;
  
  IGRint i;
  IGRint current_cnt = 0;
  
  FILE *file = NULL;
  
  // Init
  VDct1InitPartInfos(&infos);

  // Load records from file
  // VDct1LoadPartInfosFromFile(&infos,"ISDP_Staging_tree_Info_Equipment.txt");
  VDct1LoadDelimitedPartInfos(&infos,0);
  
  // Sort them
  qsort(infos.parts,infos.cnt,sizeof(TVDct1PartInfo*),VDct1SortPartsByPartCageNum);

  // Quality Check
  // VDct1TestForDupPartNums(&infos);
  
  // Dump file
  file = fopen("ops_load.txt","wt");
  if (file == NULL) file = stdout;
  
  // Dump out results
  for(i = 0; i < infos.cnt; i++) {

    sts = VDct1IsPartCurrent(&infos,i);
    if (sts & 1) {
      
      part = infos.parts[i];
      current_cnt++;
      
#if 0
      fprintf(file,"ITEM %s %-5s %-10s %-2s %-20s %-2s %-4s %-8s %-8s %s\n",
	      part->br,
	      part->part_cage_code,
	      part->part_num,
	      part->part_rev,
	      part->noun_name,
	      part->unit_of_measure,
	      part->make_buy,
	      part->creator_id,
	      part->change_id,
	      part->copics_short_description);
#endif

      fprintf(file,"%-4s %-5s %-19s %-2s %-2s %-20s %-2s %-25s %-19s\n",
	      part->br,
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
  
  fprintf(file,"### Total Parts Loaded %d\n",current_cnt);
   printf(     "### Total Parts Loaded %d\n",current_cnt);

  // Open up for noun check
  if (file != stdout) {
    fclose(file);
    file = NULL;

    file = fopen("ops_noun.txt","wt");
    if (file == NULL) file = stdout;

  }
  
  // Sort em
  qsort(infos.parts,infos.cnt,sizeof(TVDct1PartInfo*),VDct1SortPartsByNoun);

  // Cycle through
  for(i = 0; i < infos.cnt; i++) {

    sts = VDct1IsNounDistinct(&infos,i);
    if (sts & 1) {
      
      part = infos.parts[i];
      fprintf(file,"%-25s %-25s %-25s\n",part->noun_name,part->type,part->modifier);
    }
    
  }
  
  // Done
  retFlag =1;
  
 wrapup:
  if ((file) && (file != stdout)) fclose(file);
  
  VDct1FreePartInfos(&infos);
  return retFlag;
}


