/* $Id: VDct1IOC.c,v 1.2.2.1 2004/03/29 16:22:30 ahundiak Exp $  */
/***************************************************************************
 * I/VDS
 *
 * File:        vdct1/part/VDct1IOC.I
 *
 * Description: IOC Routines
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDct1IOC.c,v $
 *      Revision 1.2.2.1  2004/03/29 16:22:30  ahundiak
 *      ah
 *
 *      Revision 1.2  2001/02/11 17:24:16  ahundiak
 *      Renamed VDris2 to VDrisc
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 08/18/00  ah      Creation
 * 11/17/10  ah      Cage code fomr ship
 ***************************************************************************/

#include "VDtypedefc.h"
#include "VDassert.h"

#include "VDrisc.h"
#include "VDship.h"

#include "VDct1Ris.h"
#include "VDct1Part.h"

VDASSERT_FFN("vdct1/part/VDct1IOC.c");

/* -----------------------------------------------
 * Query IOC for part_cage_num
 *
 * The type_cage_num contains a VDCT1_RIS_COLI_SIOC_XXX_CAGE_NUM
 * Value to decide which of the three cage_nums to query against
 *
 * A NULL for part_cage_num means to get everything
 */
IGRstat VDct1QryIOCForPartCageNum(TVDrisInfo *ris, 
				  IGRint      type_cage_num, 
				  IGRchar    *part_cage_num)
{
  VDASSERT_FN("VDct1QryIOCForPartCageNum");
  
  IGRstat retFlag = 0;
  IGRchar name_cage_num[40];
  IGRchar buf[128];
  
  // Arg check
  VDASSERTW(ris); 
  ris->rows = 0;
  
  // Whick field to query
  *name_cage_num = 0;
  switch(type_cage_num){

    case VDCT1_RIS_COLI_SIOC_ISDP_CAGE_NUM:
      strcpy(name_cage_num,VDCT1_RIS_COLN_SIOC_ISDP_CAGE_NUM);
      break;
    case VDCT1_RIS_COLI_SIOC_OPS_CAGE_NUM:
      strcpy(name_cage_num,VDCT1_RIS_COLN_SIOC_OPS_CAGE_NUM);
      break;
    case VDCT1_RIS_COLI_SIOC_COP_CAGE_NUM:
      strcpy(name_cage_num,VDCT1_RIS_COLN_SIOC_COP_CAGE_NUM);
      break;
  }
  
  // Build Query
  sprintf(ris->sql,
	  "Select %s,%s,%s,%s,%s,%s,%s from %s ",
	  VDCT1_RIS_COLN_SIOC_ISDP_FAMILY,
	  VDCT1_RIS_COLN_SIOC_ISDP_CAGE_NUM,
	  VDCT1_RIS_COLN_SIOC_OPS_CAGE_NUM,
	  VDCT1_RIS_COLN_SIOC_COP_CAGE_NUM,
	  VDCT1_RIS_COLN_SIOC_COP_SIZE,
	  VDCT1_RIS_COLN_SIOC_COP_MAX_X,
	  VDCT1_RIS_COLN_SIOC_COP_MAX_Y,
	  VDCT1_RIS_TBLN_SIOC);

  if (part_cage_num && *name_cage_num) {
    sprintf(buf," where %s = '%s' ",name_cage_num,part_cage_num);
    strcat(ris->sql,buf);
  }
  
  // Tail
  sprintf(buf,"Order by %s;",VDCT1_RIS_COLN_SIOC_ISDP_FAMILY);
  strcat(ris->sql,buf);
  
  // Do It
  VDrisQuery(ris,NULL);
  
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Maps buffer to ioc structure
 */
IGRstat VDct1MapIOCBuffer(IGRchar **buf, TVDct1RisIOC *ioc)
{
  VDASSERT_FN("VDct1MapIOCBuffer");
  IGRstat retFlag = 0;
  
  VDASSERTW(ioc);
  if (buf == NULL) memset(ioc,0,sizeof(TVDct1RisIOC));
  VDASSERTW(buf);
  
  strcpy(ioc->isdp_family,  buf[VDCT1_RIS_COLI_SIOC_ISDP_FAMILY]);
  strcpy(ioc->isdp_cage_num,buf[VDCT1_RIS_COLI_SIOC_ISDP_CAGE_NUM]);
  strcpy(ioc->ops_cage_num, buf[VDCT1_RIS_COLI_SIOC_OPS_CAGE_NUM]);
  strcpy(ioc->cop_cage_num, buf[VDCT1_RIS_COLI_SIOC_COP_CAGE_NUM]);
  strcpy(ioc->cop_size,     buf[VDCT1_RIS_COLI_SIOC_COP_SIZE]);
  strcpy(ioc->cop_max_x,    buf[VDCT1_RIS_COLI_SIOC_COP_MAX_X]);
  strcpy(ioc->cop_max_y,    buf[VDCT1_RIS_COLI_SIOC_COP_MAX_Y]);

  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Reads the RisIOC structure from the database
 *
 * The type_cage_num contains a VDCT1_RIS_COLI_SIOC_XXX_CAGE_NUM
 * Value to decide which of the three cage_nums to query against
 */
IGRstat VDct1ReadIOCForPartCageNum(TVDct1RisIOC *ioc,
				   IGRint        type_cage_num,
				   IGRchar      *part_cage_num)
{
  VDASSERT_FN("VDct1ReadIOCForPartCageNum");
  IGRstat retFlag = 0;
  
  TVDrisInfo ris;
  
  // Say Hi
  // traceFlag = 1;
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
  
  // Init
  VDrisInitInfo(&ris);

  // Arg check
  VDASSERTW(ioc);
  memset(ioc,0,sizeof(TVDct1RisIOC));
  VDASSERTW(part_cage_num);
  if (traceFlag) printf("Locating %s\n",part_cage_num);
  
  // Query
  VDct1QryIOCForPartCageNum(&ris, type_cage_num, part_cage_num);
  if (ris.rows == 0) goto wrapup;
  VDASSERTW(ris.rows == 1);
  
  // Extract
  VDct1MapIOCBuffer(ris.buf,ioc);
  
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
 * Insert IOC into the table
 *
 * Assume it's valid and not a duplicate
 */
IGRstat VDct1InsertIOC(TVDct1RisIOC *ioc)
{
  VDASSERT_FN("VDct1InsertIOC");
  
  IGRstat retFlag = 0;
  IGRchar sql[1024];

  // Arg check
  VDASSERTW(ioc);

  // Build insert
  sprintf(sql,
	  "Insert into %s values "
	  "('%s','%s','%s','%s','%s','%s','%s');",
	  VDCT1_RIS_TBLN_SIOC,
	  ioc->isdp_family,
	  ioc->isdp_cage_num,
	  ioc->ops_cage_num,
	  ioc->cop_cage_num,      
	  ioc->cop_size,
	  ioc->cop_max_x,
	  ioc->cop_max_y);

  // Do It
  VDrisExecute(sql);
  
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Dump the table for debugging
 */
IGRstat VDct1DumpIOCTable()
{
  VDASSERT_FN("VDct1DumpIOCTable");

  IGRstat retFlag = 0;
  IGRint  cnt = 0;
  IGRint  nth;
  
  TVDrisInfo   ris;
  TVDct1RisIOC ioc;
  
  // Init
  VDrisInitInfo(&ris);

  // Say Hi
  printf("----------- IOC Table Listing ----------------\n");

  // Do the query
  VDct1QryIOCForPartCageNum(&ris,NULL,0);
  
  // Cycle throuh
  for(ris.i = 0; ris.i < ris.rows; ris.i++) {

    ris.j = ris.i * ris.cols;

    VDct1MapIOCBuffer(&ris.buf[ris.j],&ioc);
    printf("%-12s %-31s %-25s %-25s %-10s %-10s %-10s\n",
	   ioc.isdp_family,
	   ioc.isdp_cage_num,
	   ioc.ops_cage_num,
	   ioc.cop_cage_num,
	   ioc.cop_size,
	   ioc.cop_max_x,
	   ioc.cop_max_y);	   
  }
  
  printf("Listed %d records\n",ris.rows);
  
  // Done
  retFlag = 1;
  
 wrapup:
  VDrisFreeInfo(&ris);
  return retFlag;
  
}

static IGRint csvLoadCnt;

/* -----------------------------------------------
 * Utility routine to pull one field from the buf
 */
static IGRstat getCSVFld(IGRchar *buf, IGRchar *fld)
{
  IGRstat retFlag = 0;
  IGRchar *p;
  
  *fld = 0;
  p = strchr(buf,',');
  if (p == NULL) goto wrapup;
  *p = 0;
  strcpy(fld,buf);
  strcpy(buf,p+1);
  
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Creates isdp_cage_num
 */
IGRstat VDct1GenerateIsdpCageNum(IGRchar *cage_code,
				 IGRchar *type,
				 IGRchar *grade,
				 IGRchar *part_num,
				 IGRchar *isdp_cage_num)
{
  VDASSERT_FN("VDct1GenerateIsdpCageNum");
  
  IGRstat retFlag = 0;
  
  IGRchar typex[8];

  *isdp_cage_num = 0;

  VDASSERTW(type);
  switch(*type){
    case 'p': 
    case 'P': 
      strcpy(typex,VDCT1_ISDP_TYPE_PLATE);
      break;
    case 'b': 
    case 'B': 
      strcpy(typex,VDCT1_ISDP_TYPE_BEAM);
      break;
    default: 
      VDASSERTW(0);
  }

  VDASSERTW(cage_code && *cage_code);
  VDASSERTW(grade     && *grade);
  VDASSERTW(part_num  && *part_num);
  
  sprintf(isdp_cage_num,"%s%s%s_%s",cage_code,typex,grade,part_num);
  
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Parse out and load one line
 */
IGRstat VDct1LoadIOCFromCSVFileBuf(IGRchar *buf)
{
  VDASSERT_FN("VDct1LoadIOCFromCSVFileBuf");
  
  IGRstat retFlag = 0;
  
  TVDct1RisIOC ioc;
  IGRchar *p;
  IGRchar fld[128];
  IGRchar type     [40];
  IGRchar part_num [40];
  IGRchar grade    [40];
  IGRchar cage_code[32];
  
  // Init
  memset(&ioc,0,sizeof(TVDct1RisIOC));
  VDshipGetCageCode(cage_code);
  
  // First field indicats data
  getCSVFld(buf,fld);
  if (*fld != 'D') goto wrapup;
  
  // Skip UM field
  getCSVFld(buf,fld);

  // Piece Type
  getCSVFld(buf,type);
  
  // Family
  getCSVFld(buf,ioc.isdp_family);
  
  // isdp part_num
  getCSVFld(buf,part_num);
  
  // ops num
  getCSVFld(buf,fld);
  sprintf(ioc.ops_cage_num,"%s-%s",cage_code,fld);
  
  // Copics Num
  getCSVFld(buf,fld);
  sprintf(ioc.cop_cage_num,"%s-%s",cage_code,fld);

  // Grade
  getCSVFld(buf,grade);
  
  // sprintf(ioc.isdp_cage_num,"%s-XX_%s_%s",cage_code,grade,part_num);
  VDct1GenerateIsdpCageNum(cage_code,type,grade,part_num,ioc.isdp_cage_num);
  if (*ioc.isdp_cage_num == 0) goto wrapup;
  
  // Copics stock data
  getCSVFld(buf,ioc.cop_size);
  getCSVFld(buf,ioc.cop_max_x);
  getCSVFld(buf,ioc.cop_max_y);

  // Load it
  printf("%-31s %-25s %-25s\n",
	 ioc.isdp_cage_num,
	 ioc.ops_cage_num,
	 ioc.cop_cage_num);

  VDct1InsertIOC(&ioc);
  csvLoadCnt++;
  
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Load the ioc table from a .csv file
 * Nothing fancy, just empty the table and refill
 */
IGRstat VDct1LoadIOCFromCSVFile(IGRchar *fileName)
{
  VDASSERT_FN("VDct1LoadIOCFromCSVFile");
  
  IGRstat retFlag = 0;
  
  FILE   *file;
  IGRchar buf[256];
  
  // Init
  csvLoadCnt = 0;

  // Empty the table
  sprintf(buf,"Delete from %s;",VDCT1_RIS_TBLN_SIOC);
  VDrisExecute(buf);
  
  // Open
  if (fileName == NULL) fileName = "ioc.csv";
  file = fopen(fileName,"rt");
  if (file == NULL) {
    printf("*** Unable to open %s for reading\n",fileName);
    goto wrapup;
  }
  
  // Cycle through
  while(fgets(buf,sizeof(buf),file)) {
    VDct1LoadIOCFromCSVFileBuf(buf);
  }
  fclose(file);
  
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}







