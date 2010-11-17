#include "stdio.h"
#include "stdlib.h"
#include "string.h"
#include "dirent.h"
#include "VDdom2.h"
#include "sqlite.h"

#include "db.h"
#include "part.h"
#include "extr.h"

typedef struct
{
  FILE *both;
  FILE *copy;
  FILE *extract;
  int   cnt;
  char  dataPath[128];
} Tinfo;

/* ----------------------------------------------
 * Process one file at a time
 */
static int make_batch_cb(void *pArg, int argc, char **argv, char **colNames)
{
  Tinfo *info = (Tinfo*)pArg;
  int i;

  TpdmPart part;

  /* Pull data */
  memset(&part,0,sizeof(TpdmPart));
  for(i = 0; i < argc; i++) {
    if (!strcmp(colNames[i],"part_num"))  strcpy(part.num,      argv[i]);
    if (!strcmp(colNames[i],"part_rev"))  strcpy(part.rev,      argv[i]);
    if (!strcmp(colNames[i],"file_name")) strcpy(part.file_name,argv[i]);
    if (!strcmp(colNames[i],"file_ver"))  part.file_ver =  atoi(argv[i]);
  }
  if (*part.file_name == 0) goto wrapup;

  //printf("*** Batch %s %d\n",part.file_name,part.file_ver);
  fprintf(info->copy,"/bin/cp isdp/%s.%04d extract/%s\n",
    part.file_name,
    part.file_ver,
    part.file_name);

  fprintf(info->both,"/bin/cp isdp/%s.%04d extract/%s\n",
    part.file_name,
    part.file_ver,
    part.file_name);

  fprintf(info->copy,"/bin/cp isdp/%s.%04d.xml extract/pedigree/%s.xml\n",
    part.file_name,
    part.file_ver,
    part.file_name);

  fprintf(info->both,"/bin/cp isdp/%s.%04d.xml extract/pedigree/%s.xml\n",
    part.file_name,
    part.file_ver,
    part.file_name);

  fprintf(info->extract,
    "cd extract; extract.sh %s; /bin/rm %s; /bin/rm *.jnl; cd ..\n",
    part.file_name,
    part.file_name);

  fprintf(info->both,
    "cd extract; extract.sh %s; /bin/rm %s; /bin/rm *.jnl; cd ..\n",
    part.file_name,
    part.file_name);

  info->cnt++;

wrapup:
  return 0;
}

/* ----------------------------------------------
 * Make the batch files to copy and extract
 * unprocessed files
 */
int make_batch(sqlite *db)
{  
  int retFlag = 0;
  int sts;
  char *errmsg = NULL;

  Tinfo info;

  memset(&info,0,sizeof(Tinfo));

  info.both    = fopen("both.sh",   "wt");
  info.copy    = fopen("copy.sh",   "wt");
  info.extract = fopen("extract.sh","wt");

  sts = sqlite_exec_printf(db,
    "SELECT file_name,file_ver "
    "FROM pdm_part "
    "LEFT JOIN extr_part USING(extr_name) "
    "WHERE have_xml = 0 OR have_xml ISNULL "
    "ORDER BY file_name;",

    make_batch_cb,&info,&errmsg);
  if (sts)
  {
    printf("*** %s\n",errmsg);
    free(errmsg);
    goto wrapup;
  }
  fclose(info.both);
  fclose(info.copy);
  fclose(info.extract);

  system("chmod +x both.sh");
  system("chmod +x copy.sh");
  system("chmod +x extract.sh");

  printf("Batched %d\n",info.cnt);
  retFlag = 1;

wrapup:
  return retFlag;
}

