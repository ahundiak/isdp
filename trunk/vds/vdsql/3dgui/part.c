#include "stdio.h"
#include "stdlib.h"
#include "string.h"
#include "VDdom2.h"
#include "sqlite.h"

#include "db.h"
#include "part.h"

/* ----------------------------------------------
 * Callback from pdm_part query
 */
int qry_pdm_part_one(void *pArg, int argc, char **argv, char **colNames)
{
  TpdmPart *part = (TpdmPart*)pArg;
  int i;

  /* Should only be called onece */
  if (*part->num) return 0;

  /* Pull data */
  for(i = 0; i < argc; i++) {
    if (!strcmp(colNames[i],"part_cat_name")) strcpy(part->cat_name, argv[i]);
    if (!strcmp(colNames[i],"part_num"))      strcpy(part->num,      argv[i]);
    if (!strcmp(colNames[i],"part_rev"))      strcpy(part->rev,      argv[i]);
    if (!strcmp(colNames[i],"part_desc"))     strcpy(part->desc,     argv[i]);
    if (!strcmp(colNames[i],"part_state"))    strcpy(part->state,    argv[i]);
    if (!strcmp(colNames[i],"extr_name"))     strcpy(part->extr_name,argv[i]);
    if (!strcmp(colNames[i],"file_name"))     strcpy(part->file_name,argv[i]);
    if (!strcmp(colNames[i],"file_date"))     strcpy(part->file_date,argv[i]);
    if (!strcmp(colNames[i],"extr_date"))     strcpy(part->extr_date,argv[i]);

    if (!strcmp(colNames[i],"part_zone"))     part->zone     = atoi(argv[i]);
    if (!strcmp(colNames[i],"part_unit"))     part->unit     = atoi(argv[i]);
    if (!strcmp(colNames[i],"part_type"))     part->type     = atoi(argv[i]);
    if (!strcmp(colNames[i],"file_ver"))      part->file_ver = atoi(argv[i]);
    if (!strcmp(colNames[i],"file_key"))      part->file_key = atoi(argv[i]);

    if (!strcmp(colNames[i],"pdm_part.part_cat_name")) strcpy(part->cat_name, argv[i]);
    if (!strcmp(colNames[i],"pdm_part.part_num"))      strcpy(part->num,      argv[i]);
    if (!strcmp(colNames[i],"pdm_part.part_rev"))      strcpy(part->rev,      argv[i]);
    if (!strcmp(colNames[i],"pdm_part.part_desc"))     strcpy(part->desc,     argv[i]);
    if (!strcmp(colNames[i],"pdm_part.part_state"))    strcpy(part->state,    argv[i]);
    if (!strcmp(colNames[i],"pdm_part.extr_name"))     strcpy(part->extr_name,argv[i]);
    if (!strcmp(colNames[i],"pdm_part.file_name"))     strcpy(part->file_name,argv[i]);
    if (!strcmp(colNames[i],"pdm_part.file_date"))     strcpy(part->file_date,argv[i]);
    if (!strcmp(colNames[i],"pdm_part.extr_date"))     strcpy(part->extr_date,argv[i]);

    if (!strcmp(colNames[i],"pdm_part.part_zone"))     part->zone     = atoi(argv[i]);
    if (!strcmp(colNames[i],"pdm_part.part_unit"))     part->unit     = atoi(argv[i]);
    if (!strcmp(colNames[i],"pdm_part.part_type"))     part->type     = atoi(argv[i]);
    if (!strcmp(colNames[i],"pdm_part.file_ver"))      part->file_ver = atoi(argv[i]);
    if (!strcmp(colNames[i],"pdm_part.file_key"))      part->file_key = atoi(argv[i]);
   }
  return 0;
}
/* ----------------------------------------------
 * Query a pdm_part using part_num
 */
int qry_pdm_part(sqlite *db, char *part_num, TpdmPart *part)
{
  int retFlag = 0;
  int sts;
  char *errmsg = NULL;

  /* Init */
  memset(part,0,sizeof(TpdmPart));
  if (*part_num == 0) goto wrapup;

  sts = sqlite_exec_printf(db,
    "SELECT * FROM pdm_part WHERE part_num = %Q;",
    qry_pdm_part_one,part,&errmsg,part_num);
  if (sts)
  {
    printf("*** %s\n",errmsg);
    printf("QRY pdm_part FOR %s\n",part_num);
    free(errmsg);
    goto wrapup;
  }

  /* Done */
  retFlag = 1;

wrapup:
  return retFlag;
}
/* ----------------------------------------------
 * Query a pdm_part using extr_name
 */
int qry_pdm_part_by_extr_name(sqlite *db, char *extr_name, TpdmPart *part)
{
  int retFlag = 0;
  int sts;
  char *errmsg = NULL;

  /* Init */
  memset(part,0,sizeof(TpdmPart));
  if (*extr_name == 0) goto wrapup;

  sts = sqlite_exec_printf(db,
    "SELECT * FROM pdm_part WHERE extr_name = %Q;",
    qry_pdm_part_one,part,&errmsg,extr_name);
  if (sts)
  {
    printf("*** %s\n",errmsg);
    printf("QRY pdm_part FOR %s\n",extr_name);
    free(errmsg);
    goto wrapup;
  }

  /* Done */
  retFlag = 1;

wrapup:
  return retFlag;
}

static int load_part_list_item(sqlite *db, char *buf)
{
  int retFlag = 1;
  int sts;

  TpdmPart part;

  char *p;
  char part_num[32];

  memset(&part,0,sizeof(TpdmPart));

  /* Catalog */
  p = strchr(buf,'|');
  if (p == NULL) goto wrapup; *p = 0;
  strcpy(part.cat_name,buf);
  strcpy(buf,p+1);
  if (!strcasecmp(part.cat_name,"Catalog")) goto wrapup;

  /* Part */
  p = strchr(buf,'|');
  if (p == NULL) goto wrapup; *p = 0;
  strcpy(part.num,buf);
  strcpy(buf,p+1);

  /* Rev */
  p = strchr(buf,'|');
  if (p == NULL) goto wrapup; *p = 0;
  strcpy(part.rev,buf);
  strcpy(buf,p+1);

  /* Description */
  p = strchr(buf,'|');
  if (p == NULL) goto wrapup;*p = 0;
  strcpy(part.desc,buf);
  strcpy(buf,p+1);

  /* State */
  for(p = buf; *p >= ' '; p++); *p = 0;
  strcpy(part.state,buf);

  /* Zone */
  strcpy(part_num,part.num);
  if (strlen(part_num) > 4) {
    *(part_num+4) = 0;
    part.zone = atoi(part_num);
  }
  /* Type */
  strcpy(part_num,part.num);
  if (strlen(part_num) > 7) {
    strcpy(part_num,part_num+4);
    *(part_num+3) = 0;
    part.type = atoi(part_num);
  }
  /* Be nice if the unit could be pulled from type and desc */

  /* Save it */
  // printf("%s %s %d %d %s\n",part.cat_name,part.num,part.zone,part.type,part.rev);
  sts = insert_part(db,&part);
  if (!(sts & 1)) exit(0);

  /* All Done */
  retFlag = 1;

wrapup:
  return retFlag;
}
     
int load_part_list_file(sqlite *db, char *fileName)
{
  int retFlag = 0;
  int cnt = 0;
  int sts;

  FILE *file = NULL;
  char buf[128];

  /* Open the list */
  file = fopen(fileName,"rt");
  if (file == NULL) {
    printf("*** Unable to open %s for reading\n",fileName);
    goto wrapup;
  }

  /* Cycle through */
  while(fgets(buf,sizeof(buf),file))
  {
    sts = load_part_list_item(db,buf);
    if (sts & 1) cnt++;
  }
  fclose(file); file = NULL;
  retFlag = 1;

  printf("### Inserted from %s, parts %d\n",fileName,cnt);

wrapup:
  if (file) fclose(file);
  return retFlag;
}

int insert_part(sqlite *db, TpdmPart *part)
{
  int  retFlag = 0;
  int  sts;
  char sql[512];

  char *errmsg = NULL;

  strcpy(sql,
    "INSERT INTO pdm_part " 
    "(part_cat_name,part_num,part_rev,"
    " part_desc,part_zone,part_unit,part_type,part_state,"
    " extr_name,file_name,file_ver,file_date,extr_date) "
    "VALUES(%Q,%Q,%Q,%Q,%d,%d,%d,%Q,%Q,%Q,%d,%Q,%Q);");

  sts = sqlite_exec_printf(db,sql,NULL,NULL,&errmsg,
    part->cat_name,part->num,part->rev,
    part->desc,part->zone,part->unit,part->type,part->state,
    part->extr_name,
    part->file_name,part->file_ver,
    part->file_date,part->extr_date);
  if (sts)
  {
    printf("*** %s\n",errmsg);
    printf("INS %s %s %s\n",part->cat_name,part->num,part->rev);
    free(errmsg);
    goto wrapup;
  }

  /* Done */
  retFlag = 1;
wrapup:
  return retFlag;
}

int create_part_table(sqlite *db)
{
  int retFlag = 0;
  int sts;

  char sql[512];
  char *errmsg = NULL;

  /* Add some tables */
  sprintf(sql,
    "CREATE  TABLE pdm_part ("
    "part_cat_name CHAR(20), "
    "part_num      CHAR(16), "
    "part_rev      CHAR( 8), "
    "part_desc     CHAR(40), "
    "part_zone     INTEGER,  "
    "part_unit     INTEGER,  "
    "part_type     INTEGER,  "
    "part_state    CHAR(16), "
    "extr_name     CHAR(16), "
    "file_name     CHAR(16), "
    "file_ver      INTEGER,  "
    "file_date     CHAR(20), "
    "extr_date     CHAR(20)  "
    ")");

  sts = sqlite_exec_printf(db,sql,NULL,NULL,&errmsg);
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
int create_part_indexes(sqlite *db)
{
  int retFlag = 0;
  int sts;

  char *errmsg = NULL;

  /* Index */
  sts = sqlite_exec_printf(db,
    "CREATE UNIQUE INDEX pdm_part_i1 ON pdm_part(part_cat_name,part_num,part_rev);",
     NULL,NULL,&errmsg);
  if (sts)
  {
    printf("*** %s\n",errmsg);
    free(errmsg);
    goto wrapup;
  }
  sts = sqlite_exec_printf(db,
    "CREATE UNIQUE INDEX pdm_part_i2 ON pdm_part(part_num);",
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

