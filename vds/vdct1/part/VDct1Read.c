/* $Id: VDct1Read.c,v 1.2 2001/02/11 17:24:17 ahundiak Exp $  */
/***************************************************************************
 * I/VDS
 *
 * File:        vdct1/part/VDct1Read.I
 *
 * Description: Read Parts From Database Tables
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDct1Read.c,v $
 *      Revision 1.2  2001/02/11 17:24:17  ahundiak
 *      Renamed VDris2 to VDrisc
 *
 *      Revision 1.1  2001/01/12 14:35:59  art
 *      sp merge
 *
 * Revision 1.1  2000/12/07  17:39:48  pinnacle
 * ah
 *
# Revision 1.7  2000/08/24  14:53:30  pinnacle
# js
#
# Revision 1.6  2000/08/23  14:50:00  pinnacle
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

VDASSERT_FFN("vdct1/part/VDct1Read.I");

/* -----------------------------------------------
 * Utility routine to copy single part from 
 * ris buffer to part buffer
 */
IGRstat VDct1CopyPartFromRisBuf(IGRchar **buf, TVDct1PartInfo *part)
{

  strcpy(part->part_id,                 buf[VDCT1_RIS_COLI_ITEMS_ITEM_ID]);
  strcpy(part->part_cage_num,           buf[VDCT1_RIS_COLI_ITEMS_ITEM_CAGE_NUM]);
  strcpy(part->part_cage_code,          buf[VDCT1_RIS_COLI_ITEMS_ITEM_CAGE_CODE]);
  strcpy(part->part_num,                buf[VDCT1_RIS_COLI_ITEMS_ITEM_NUM]);
  strcpy(part->part_rev,                buf[VDCT1_RIS_COLI_ITEMS_ITEM_REV]);
  strcpy(part->cur_rev,                 buf[VDCT1_RIS_COLI_ITEMS_ITEM_CUR_REV]);

  strcpy(part->noun_name,               buf[VDCT1_RIS_COLI_ITEMS_NOUN_NAME]);
  strcpy(part->type,                    buf[VDCT1_RIS_COLI_ITEMS_TYPE]);
  strcpy(part->modifier,                buf[VDCT1_RIS_COLI_ITEMS_MODIFIER]);
  strcpy(part->discipline,              buf[VDCT1_RIS_COLI_ITEMS_DISCIPLINE]);
  strcpy(part->classification,          buf[VDCT1_RIS_COLI_ITEMS_CLASSIFICATION]);

  strcpy(part->unit_of_measure,         buf[VDCT1_RIS_COLI_ITEMS_UNIT_OF_MEASURE]);
  strcpy(part->copics_short_description,buf[VDCT1_RIS_COLI_ITEMS_COPICS_SHORT_DESC]);
  strcpy(part->updatedate,              buf[VDCT1_RIS_COLI_ITEMS_UPDATEDATE]);

  return 1;
}

/* -----------------------------------------------
 * Utility which translates an isdp cage_num to
 * a regular ops cage_num.
 * Usually for struct items VDct1ReadCageNumForIsdpCageNum
 */
IGRstat VDct1ReadCageNumForIsdpCageNum(IGRchar *isdp_cage_num, IGRchar *part_cage_num)
{
  VDASSERT_FN("VDct1ReadCageNumForIsdpCageNum");
  
  IGRstat retFlag = 0;
  IGRstat sts;
  
  IGRchar *p;
  TVDct1RisIOC ioc;

  // Say Hi
  // traceFlag = 1;
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn);
  }
  
  // By default, it stays the same
  if (part_cage_num == NULL) goto wrapup;
  if (isdp_cage_num == NULL) {
    *part_cage_num = 0;
    goto wrapup;
  }
  strcpy(part_cage_num,isdp_cage_num);
  
  // Check for special flags
  p = strstr(isdp_cage_num,VDCT1_ISDP_TYPE_PLATE);
  if (p == NULL) {
    p = strstr(isdp_cage_num,VDCT1_ISDP_TYPE_BEAM);
  }
  if (p == NULL) {
    retFlag = 1;
    goto wrapup;
  }

  // Query it
  //VDct1QryPartCageNumFromIsdpItems(&ris,isdp_cage_num);
  VDct1ReadIOCForPartCageNum(&ioc,
			     VDCT1_RIS_COLI_SIOC_ISDP_CAGE_NUM,
			     isdp_cage_num);
  if (traceFlag) {
    printf("Queried %s to %s\n",ioc.isdp_cage_num,ioc.ops_cage_num);
  }
  if (*ioc.isdp_cage_num == 0) goto wrapup;

  // Get it
  strcpy(part_cage_num,ioc.ops_cage_num);
  if (traceFlag) {
    printf("Converted %s to %s\n",isdp_cage_num,part_cage_num);
  }
  
  // Done
  retFlag = 1;
  
 wrapup:
  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  }
  
  return retFlag;
}

/* -----------------------------------------------
 * Reads a single part from the parts table
 */
IGRstat VDct1ReadPartForPartCageNum(IGRchar *part_cage_num, TVDct1PartInfo *part)
{
  VDASSERT_FN("VDct1ReadPartForPartCageNum");
  
  IGRstat retFlag = 0;
  IGRstat sts;
  
  TVDrisInfo ris;
  
  IGRint rows,cols;
  
  IGRchar sql[256];
  IGRchar **buf = NULL;

  TVDct1_part_fld_part_cage_num part_cage_numx;

  // Say Hi
  // traceFlag = 1;
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn);
  }
  
  // Init
  VDrisInitInfo(&ris);
  
  // Arg check
  if (part == NULL) goto wrapup;
  memset(part,0,sizeof(TVDct1PartInfo));
  if ((part_cage_num == NULL) || (*part_cage_num == 0)) goto wrapup;

  // Translate any isdp cage numbers
  VDct1ReadCageNumForIsdpCageNum(part_cage_num,part_cage_numx);

  // Query it
  VDct1QryPartCageNumFromItems(&ris,part_cage_numx);
  if (traceFlag) {
    printf("Queried %s %s %d\n",part_cage_num,part_cage_numx,ris.rows);
  }
  
  if (ris.rows < 1) goto wrapup;
  
  // Copy data over
  VDct1CopyPartFromRisBuf(ris.buf,part);
  
  // Done
  retFlag = 1;
  
 wrapup:
  VDrisFreeInfo(&ris);  
  if (traceFlag) {
    printf("<<< %s %s\n",ffn(),fn);
  }
  return retFlag;
}

/* -----------------------------------------------
 * Given a part_num (mino) read just the part_id
 * from the parts table
 */
IGRstat VDct1ReadPartIdForPartNum(IGRchar *part_num, IGRchar *part_id)
{
  IGRstat retFlag = 0;

  TVDrisInfo ris;

  // Init
  VDrisInitInfo(&ris);
  
  // Arg check
  if (part_id == NULL) goto wrapup;
  *part_id = 0;
  if ((part_num == NULL) || (*part_num == 0)) goto wrapup;

  // Query it
  VDct1QryPartIdForPartNum(&ris,part_num);
  if (ris.rows < 1) goto wrapup;
  
  // Get It
  strcpy(part_id,ris.buf[0]);
  
  // Done
  retFlag = 1;
  
 wrapup:
  VDrisFreeInfo(&ris);
  return retFlag;
}

/* -----------------------------------------------
 * Given a part_cage_num read just the part_id
 * from the parts table
 */
IGRstat VDct1ReadPartIdForPartCageNum(IGRchar *part_cage_num, IGRchar *part_id)
{
  VDASSERT_FN("VDct1ReadPartIdForPartCageNum");
  
  IGRstat retFlag = 0;
  
  TVDrisInfo ris;

  TVDct1_part_fld_part_cage_num part_cage_numx;
  
  // Say Hi
  // traceFlag = 1;
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn);
  }
  
  // Init
  VDrisInitInfo(&ris);
  
  // Arg check
  if (part_id == NULL) goto wrapup;
  *part_id = 0;
  if ((part_cage_num == NULL) || (*part_cage_num == 0)) goto wrapup;

  // Translate any isdp cage numbers
  VDct1ReadCageNumForIsdpCageNum(part_cage_num,part_cage_numx);
  if (traceFlag) {
    printf("--- %s Querying for '%s' '%s'\n",fn,part_cage_num,part_cage_numx);
  }
  
  // Query it
  /* ---------------------------------------------------
   * 21 Aug 2000 - This was looking up part_cage_num and not
   * part-cage_numx.  Why?  It was working before.  Did the change
   * not get checked in?
   */
  // VDct1QryPartIdForPartCageNum(&ris,part_cage_num);
  //VDct1QryPartIdForPartCageNum(&ris,part_cage_numx);

  /* ------------------------------------------------
   * changed to this independent of item_type so that we could
   * still get IDs for assemblies -- JDS 23 Aug 2000
   */
  VDct1QryPartIdForItemCageNum(&ris,part_cage_numx);
  if (ris.rows < 1) goto wrapup;
  
  // Pull data
  strcpy(part_id,ris.buf[0]);
  
  
  // Done
  retFlag = 1;
  
 wrapup:
  VDrisFreeInfo(&ris);
  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  }
  
  return retFlag;
}

/* -----------------------------------------------
 * Given a part_cage_num read just the part_id
 * from the parts table
 */
IGRstat VDct1ReadPartIdForItemCageNum(IGRchar *part_cage_num, IGRchar *part_id)
{
  IGRstat retFlag = 0;
  
  TVDrisInfo ris;

  TVDct1_part_fld_part_cage_num part_cage_numx;
  
  // Init
  VDrisInitInfo(&ris);
  
  // Arg check
  if (part_id == NULL) goto wrapup;
  *part_id = 0;
  if ((part_cage_num == NULL) || (*part_cage_num == 0)) goto wrapup;

  // Translate any isdp cage numbers
  VDct1ReadCageNumForIsdpCageNum(part_cage_num,part_cage_numx);
  
  // Query it
  VDct1QryPartIdForItemCageNum(&ris,part_cage_num);
  
  if (ris.rows < 1) goto wrapup;
  
  // Pull data
  strcpy(part_id,ris.buf[0]);
  
  
  // Done
  retFlag = 1;
  
 wrapup:
  VDrisFreeInfo(&ris);
  return retFlag;
}


/* -----------------------------------------------
 * Maps field from attributes table to record
 * Protect against overflows
 */
IGRstat VDct1ReadPartAttrsTableFld(IGRchar *name, IGRchar *value, TVDct1PartInfo *part)
{
  IGRstat retFlag = 0;
  IGRstat traceFlag = 0;
  
  IGRint  len;
  
  TVDct1PartFldInfo fld;

  // say hi
  if (traceFlag) printf (">>> Entering VDct1ReadPartAttrsTableFld\n");
  
  
  // Lookup by name
  VDct1GetPartFldInfoForName(name,part,&fld);
  if (fld.data) {
    len = strlen(value);
    if (len > fld.len) len = fld.len;
    memcpy(fld.data,value,len);
    *(fld.data + len) = 0;
    retFlag = 1;
  }


  // Done
  
 wrapup:
  if (traceFlag) printf("<<< leaving VDct1ReadPartAttrsTableFld\n");
  
  return retFlag;
}

/* -----------------------------------------------
 * Reads a single part from the part attributes table
 */
IGRstat VDct1ReadPartFromAttrsTable(IGRchar *part_id, TVDct1PartInfo *part)
{
  IGRstat retFlag = 0;
  IGRstat traceFlag = 0;
  
  IGRstat sts;

  TVDrisInfo ris;
  
  //say hi
  if (traceFlag) printf(">>> Entering VDct1ReadPartFromAttrsTable\n");
  

  // Init
  VDrisInitInfo(&ris);
  
  // Arg check
  if (part == NULL) goto wrapup;
  memset(part,0,sizeof(TVDct1PartInfo));
  if ((part_id == NULL) || (*part_id == 0)) goto wrapup;
  
  // Query it
  VDct1QryAttrsForPartId(&ris,part_id);

  // Cycle through
  for(ris.i = 0; ris.i < ris.rows; ris.i++) {
    ris.j = ris.i * ris.cols;
   
    // Translate to part record 
    VDct1ReadPartAttrsTableFld(ris.buf[ris.j+VDCT1_RIS_COLI_ATTRS_NAME],
			       ris.buf[ris.j+VDCT1_RIS_COLI_ATTRS_VALUE],
			       part);
    
  }
  
  // Done
  retFlag = 1;
  
 wrapup:
  VDrisFreeInfo(&ris);
  if (traceFlag) printf ("<<< Leaving VDct1ReadPartFromAttrsTable\n");
  return retFlag;
}

/* -----------------------------------------------
 * Dumps out the part table
 */
IGRstat VDct1DumpPartsTable(IGRchar *noun_name, IGRchar *fileName)
{
  IGRstat retFlag = 0;
  IGRstat sts;

  TVDrisInfo ris;
  
  FILE *file = NULL;

  TVDct1PartInfo partx;
  TVDct1PartInfo *part;
  
  // Init
  VDrisInitInfo(&ris);
  part = &partx;
  
  // Open output file
  if (fileName) file = fopen(fileName,"wt");
  if (file == NULL) file = stdout;
  
  // Make the query
  VDct1QryNounNameFromItems(&ris,noun_name);
  
  // Cycle through
  for(ris.i = 0; ris.i < ris.rows; ris.i++) {
    ris.j = ris.i * ris.cols;

    VDct1CopyPartFromRisBuf(&ris.buf[ris.j],part);

    fprintf(file,"%-8s %-5s %-19s %s %-25s %-2s %-25s %-19s\n",
	    part->part_id,
	    part->part_cage_code,
	    part->part_num,
	    part->part_rev,
	    part->noun_name,
	    part->unit_of_measure,
	    part->copics_short_description,
	    part->updatedate);
    
  }
  fprintf(file,"### Total Parts Dumped %d\n",ris.rows);
  printf(      "### Total Parts Dumped %d\n",ris.rows);
  
  // Done
  retFlag = 1;
  
 wrapup:
  
  // Clean up
  VDrisFreeInfo(&ris);
  
  // Close up
  if ((file) && (file != stdout)) fclose(file);
  return retFlag;
}



