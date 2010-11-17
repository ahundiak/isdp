#include "stdio.h"
#include "stdlib.h"
#include "string.h"
#include "dirent.h"
#include "VDdom2.h"
#include "sqlite.h"

#include "db.h"
#include "part.h"
#include "extr.h"

/* ----------------------------------------------
 * Callback from extr_part query
 */
int qry_extr_part_cb(void *pArg, int argc, char **argv, char **colNames)
{
  TpdmExtrPart *part = (TpdmExtrPart*)pArg;
  int i;

  /* Should only be called onece */
  if (*part->extr_name) return 0;

  /* Pull data */
  for(i = 0; i < argc; i++) {
    if (!strcmp(colNames[i],"extr_name")) strcpy(part->extr_name,argv[i]);
    if (!strcmp(colNames[i],"extr_set" )) part->extr_set = atoi(argv[i]);
    if (!strcmp(colNames[i],"have_pdm" )) part->have_pdm = atoi(argv[i]);
    if (!strcmp(colNames[i],"have_dup" )) part->have_dup = atoi(argv[i]);
    if (!strcmp(colNames[i],"have_xml" )) part->have_xml = atoi(argv[i]);
    if (!strcmp(colNames[i],"have_mdl" )) part->have_mdl = atoi(argv[i]);
    if (!strcmp(colNames[i],"have_ped" )) part->have_ped = atoi(argv[i]);
  }
  return 0;
}

/* ----------------------------------------------
 * Query a extr_part using extr_name
 */
int qry_extr_part(sqlite *db, char *extr_name, TpdmExtrPart *part)
{
  int retFlag = 0;
  int sts;

  char *errmsg = NULL;

  /* Init */
  memset(part,0,sizeof(TpdmExtrPart));
  if (*extr_name == 0) goto wrapup;

  sts = sqlite_exec_printf(db,
    "SELECT * FROM extr_part WHERE extr_name = %Q;",
    qry_extr_part_cb,part,&errmsg,extr_name);
  if (sts)
  {
    printf("*** %s\n",errmsg);
    printf("QRY extr_part FOR %s\n",extr_name);
    free(errmsg);
    goto wrapup;
  }

  /* Done */
  retFlag = 1;

wrapup:
  return retFlag;
}

/* ----------------------------------------------
 * Process single extracted xml file
 */
int process_extract(sqlite *db,char *dirPath, char *fileName, int extr_set)
{
  int retFlag = 0;
  int sts;

  char *p;
  char xmlFileName[256];

  domNode extrNode = NULL;

  TpdmPart     part;
  TpdmExtrPart extr;
  int haveExtr = 0;
  int haveXml  = 0;
  int havePdm  = 0;
  int haveDup  = 0;

  char extr_name[32];

  char *errmsg = NULL;

  /* Only want xml files */
  p = strrchr(fileName,'.');
  if (p == NULL) goto wrapup;
  if (strcmp(p,".xml")) goto wrapup;
  sprintf(xmlFileName,"%s/%s",dirPath,fileName);
 
  /* Verify in the database */
  strcpy(extr_name,fileName);
  p = strchr(extr_name,'.'); *p = 0;
  qry_pdm_part_by_extr_name(db,extr_name,&part);
  if (*part.num) havePdm = 1;

  /* Might already have extr part */
  qry_extr_part(db,extr_name,&extr);
  if (*extr.extr_name) {
    haveExtr = 1;
    if (extr.extr_set != extr_set) {
      haveDup = extr_set;
#if 0
      printf("*** Extract file duplicated %d %d\n    %s\n",
        extr.extr_set,extr_set,
        xmlFileName);
      goto wrapup;
#endif
    }
  }
  else {
    haveExtr = 0;
    strcpy(extr.extr_name,extr_name);
    extr.extr_set = extr_set;
  }

  /* Create the tree */
  extrNode = domCreateDocFromFile(xmlFileName);
  if (extrNode == NULL) {
    // printf("*** Unable to open/parse xml extract file\n   %s\n",xmlFileName);
    //goto wrapup;
  }
  else {

    /* Know have valid xml file */
    haveXml = 1;

    /* Cleanup a bit */
    domFreeDoc(extrNode); extrNode = NULL;
  }

  /* Count it */
  retFlag = 1;

  /* Insert or update */
  if (haveExtr == 0) {
    extr.have_xml = haveXml;
    extr.have_pdm = havePdm;
    extr.have_dup = haveDup;
    insert_extr_part(db,&extr);
  }
  else {
    if ((extr.have_xml == haveXml) &&
        (extr.have_dup == haveDup) &&
        (extr.have_pdm == havePdm)) goto wrapup;

    extr.have_pdm = havePdm;
    extr.have_dup = haveDup;
    extr.have_xml = haveXml;

    sts = sqlite_exec_printf(db,
      "UPDATE extr_part "
      "SET have_pdm = %d, have_dup = %d, have_xml = %d "
      "WHERE extr_name = %Q;",
      NULL,NULL,&errmsg,
      extr.have_pdm,
      extr.have_dup,
      extr.have_xml,
      extr.extr_name);
    if (sts)
    {
      printf("*** %s\n",errmsg);
      printf("UPD EXTR %s %d\n",extr.extr_name,extr.extr_set);
      free(errmsg);
      goto wrapup;
    }
  }

wrapup:  
  if (extrNode) domFreeDoc(extrNode); 
  return retFlag;
}

/* ----------------------------------------------
 * Process an extract directory
 */
int process_extracts(sqlite *db, char *dataPath, char *xmlPath, int extr_set)
{
  int retFlag = 0;
  int sts;
  int cnt = 0;

  struct dirent	*dirEntry;
  DIR		*dirInfo = NULL;

  char           xmlDataPath[256];

  /* Full path */
  sprintf(xmlDataPath,"%s/%s",dataPath,xmlPath);
  dirInfo = opendir(xmlDataPath);
  if (dirInfo == NULL) {
    printf("*** No xml files in %s\n",xmlDataPath);
    goto wrapup;
  }
  /* Cycle through */
  while((dirEntry = readdir(dirInfo)) && (cnt < 10000000)) {

    sts = process_extract(db,xmlDataPath,dirEntry->d_name,extr_set);
    if (sts & 1) cnt++;

  }
  closedir(dirInfo); dirInfo = NULL;

  printf("Processed %s %d extracted xml files\n",xmlPath,cnt);
  fflush(stdout);

  retFlag = 1;

wrapup:
  return retFlag;
}

/* ----------------------------------------------
 * Check through the extract results
 */
static int check_extract_cb(void *pArg, int argc, char **argv, char **colNames)
{
  char *msg = (char *)pArg;
  TpdmExtrPart extr;

  /* Pull the data */
  memset(&extr,0,sizeof(TpdmExtrPart));
  qry_extr_part_cb(&extr,argc,argv,colNames);

  printf("%s %s %d\n",msg,extr.extr_name,extr.extr_set);

  return 0;
}

static int check_extractx(sqlite *db, char *msg, char *sql)
{
  int sts;
  char *errmsg = NULL;

  sts = sqlite_exec_printf(db,sql,check_extract_cb,msg,&errmsg);
  if (sts)
  {
    printf("*** %s\n",errmsg);
    free(errmsg);
    return 0;
  }
  return 1;
}

int check_extracts(sqlite *db)
{
/*
  check_extractx(db,"NO  PDM PART",
    "SELECT * FROM extr_part WHERE have_pdm = 0 ORDER BY extr_name;");
*/
  check_extractx(db,"BAD XML FILE",
    "SELECT * FROM extr_part WHERE have_xml = 0 ORDER BY extr_name;");
/*
  check_extractx(db,"DUP XML FILE",
    "SELECT * FROM extr_part WHERE have_dup > 0 ORDER BY extr_name;");
*/
  return 1;
}

/* ----------------------------------------------
 * Insert a new part, maybe should make
 * this an insert/update routine
 */
int insert_extr_part(sqlite *db, TpdmExtrPart *part)
{
  int  retFlag = 0;
  int  sts;

  char *errmsg = NULL;

  sts = sqlite_exec_printf(db,
    "INSERT INTO extr_part (" 
    " extr_name,extr_set,"
    " have_pdm,have_dup,have_xml,have_mdl,have_ped"
    ") "
    "VALUES(%Q,%d,%d,%d,%d,%d,%d);",
    NULL,NULL,&errmsg,
    part->extr_name,
    part->extr_set,
    part->have_pdm,
    part->have_dup,
    part->have_xml,
    part->have_mdl,
    part->have_ped);
  if (sts)
  {
    printf("*** %s\n",errmsg);
    printf("INS EXTR %s %d\n",part->extr_name,part->extr_set);
    free(errmsg);
    goto wrapup;
  }

  /* Done */
  retFlag = 1;
wrapup:
  return retFlag;
}

/* ----------------------------------------------
 * Create extr table
 */
int create_extr_table(sqlite *db)
{
  int retFlag = 0;
  int sts;

  char *errmsg = NULL;

  /* Add some tables */
  sts = sqlite_exec_printf(db,
    "CREATE  TABLE extr_part ("
    "extr_name CHAR(16), "
    "extr_set  INTEGER,  "
    "have_pdm  INTEGER,  "
    "have_dup  INTEGER,  "
    "have_xml  INTEGER,  "
    "have_mdl  INTEGER,  "
    "have_ped  INTEGER   "
    ");",
    NULL,NULL,&errmsg);
  if (sts)
  {
    printf("*** %s\n",errmsg);
    free(errmsg);
    goto wrapup;
  }

  /* Index */
  sts = sqlite_exec_printf(db,
    "CREATE UNIQUE INDEX extr_part_i1 ON extr_part(extr_name);",
    NULL,NULL,&errmsg);
  if (sts)
  {
    printf("*** %s\n",errmsg);
    free(errmsg);
    goto wrapup;
  }

  retFlag = 1;

wrapup:
  return retFlag;
}

