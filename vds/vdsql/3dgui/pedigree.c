/* ----------------------------------------------
 * Bounce pedigree files against master part list
 */
#include "stdio.h"
#include "stdlib.h"
#include "string.h"
#include "dirent.h"
#include "VDdom2.h"
#include "sqlite.h"

#include "db.h"
#include "part.h"

/* ----------------------------------------------
 * Process one pedigree file
 */
int process_pedigree(sqlite *db,char *dirPath, char *fileName)
{
  int retFlag = 0;
  int sts;

  char *p;
  char xmlFileName[256];

  domNode pedNode = NULL;

  TpdmPart part1;
  TpdmPart part2;

  char *errmsg = NULL;

  /* Only want xml files */
  p = strrchr(fileName,'.');
  if (p == NULL) goto wrapup;
  if (strcmp(p,".xml")) goto wrapup;

  /* Create the tree */
  sprintf(xmlFileName,"%s%s",dirPath,fileName);
  pedNode = domCreateDocFromFile(xmlFileName);
  if (pedNode == NULL) {
    printf("*** Unable to open xml pedigree file %s\n",xmlFileName);
    goto wrapup;
  }

  /* Xfer the data */
  memset(&part1,0,sizeof(TpdmPart));
  domGetTextAttrNodeValue(pedNode,"catalog",part1.cat_name);
  domGetTextAttrNodeValue(pedNode,"part",   part1.num);
  domGetTextAttrNodeValue(pedNode,"rev",    part1.rev);

  domGetTextAttrNodeValue(pedNode,"co_file_name",part1.file_name);
  strcpy(part1.extr_name,part1.file_name);
  p = strrchr(part1.extr_name,'.');
  if (p) *p = 0;

  domGetTextAttrNodeValue(pedNode,"state_name",  part1.state);

  domGetTextAttrNodeValue(pedNode,"sa_file_date",part1.file_date);
  domGetTextAttrNodeValue(pedNode,"retrieved",   part1.extr_date);
  *(part1.file_date+10) = ' ';

  domGetIntAttrNodeValue(pedNode,"file_num",&part1.file_ver);

  /* Cleanup a bit */
  domFreeDoc(pedNode); pedNode = NULL;

  /* Lookup in database */
  qry_pdm_part(db,part1.num,&part2);
  if (*part2.num == 0) {
    /* This is ok, only process ones already in the table */
    printf("Skipping %s\n",fileName);
    goto wrapup;
  }

  /* See if file_ver needs to be adjusted */
  if (*part2.file_name) {
    if (part2.file_ver >= part1.file_ver) goto wrapup;
  }
  sts = sqlite_exec_printf(db,
    "UPDATE pdm_part "
    "SET "
    "extr_name = %Q, "
    "file_name = %Q, "
    "file_ver  = %d, "
    "file_date = %Q, "
    "extr_date = %Q  "
    "WHERE part_num = %Q;",
    NULL,NULL,&errmsg,
    part1.extr_name,
    part1.file_name,
    part1.file_ver,
    part1.file_date,
    part1.extr_date,
    part1.num);
  if (sts)
  {
    printf("*** %s\n",errmsg);
    free(errmsg);
    goto wrapup;
  }

  /* Done */
  retFlag = 1;

wrapup:
  if (pedNode) domFreeDoc(pedNode);
  return retFlag;
}

/* ----------------------------------------------
 * Handles all the pedigrees in a directory
 */
int process_pedigrees(sqlite *db, char *xmlDir)
{
  int retFlag = 0;
  int sts;
  int cnt = 0;

  struct dirent	*dirEntry;
  DIR		*dirInfo = NULL;
  char           dirPath[256];

  /* Full path */
  sprintf(dirPath,"%s/",xmlDir);
  dirInfo = opendir(xmlDir);
  if (dirInfo == NULL) {
    printf("*** No xml files in %s\n",xmlDir);
    goto wrapup;
  }
  /* Cycle through */
  while((dirEntry = readdir(dirInfo)) && (cnt < 10000000)) {

    sts = process_pedigree(db,dirPath,dirEntry->d_name);
    if (sts & 1) cnt++;

  }
  closedir(dirInfo); dirInfo = NULL;

  printf("Processed %d pedigree files\n",cnt);

  retFlag = 1;

wrapup:
  return retFlag;
}

/* ----------------------------------------------
 * Checking one pedigree file
 */
static int check_pedigree(void *pArg, int argc, char **argv, char **colNames)
{
  int *cnt = (int*)pArg;
  int i;
  char *errmsg = NULL;

  TpdmPart part;

  /* Pull data */
  memset(&part,0,sizeof(TpdmPart));
  for(i = 0; i < argc; i++) {
    if (!strcmp(colNames[i],"part_cat_name")) strcpy(part.cat_name,argv[i]);
    if (!strcmp(colNames[i],"part_num"))      strcpy(part.num,     argv[i]);
    if (!strcmp(colNames[i],"part_rev"))      strcpy(part.rev,     argv[i]);
  }
  printf("*** Pedigree File For %s %s %s\n",
    part.cat_name,part.num,part.rev);

  *cnt = *cnt + 1;

  /* Put in a fake extr_name just for the index */

  return 0;
}

/* ----------------------------------------------
 * Check pedigrees via a query
 */
int check_pedigrees(sqlite *db)
{
  int retFlag = 0;
  int cnt = 0;
  int sts;

  char *errmsg = NULL;

  sts = sqlite_exec_printf(db,
    "SELECT part_cat_name,part_num,part_rev "
    "FROM   pdm_part "
    "WHERE  file_ver = 0;",
    check_pedigree,&cnt,&errmsg);
  if (sts)
  {
    printf("*** %s\n",errmsg);
    printf("QRY Checking Pedigrees\n");
    free(errmsg);
    goto wrapup;
  }
  if (cnt) printf("*** Missing Pedigree files %d\n",cnt);
  else     printf("### All pedigree files found\n");

  retFlag = 1;
wrapup:
  return retFlag;
}
