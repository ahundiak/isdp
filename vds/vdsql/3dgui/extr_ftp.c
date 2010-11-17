#include "stdio.h"
#include "stdlib.h"
#include "string.h"
#include "dirent.h"
#include "VDdom2.h"
#include "sqlite.h"

#include "db.h"
#include "part.h"
#include "extr.h"

int ftp_extract_cb(void *pArg, int argc, char **argv, char **colNames)
{
  int *cnt = (int*)pArg;
  int i;

  TpdmPart part;
  TpdmInfo info;

  /* Pull the info */
  memset(&part,0,sizeof(TpdmPart));
  memset(&info,0,sizeof(TpdmInfo));

  qry_pdm_part_one(&part,argc,argv,colNames);
  if (*part.num == 0) goto wrapup;
  *cnt = *cnt + 1;

  /* Qry pdm */
  qryPartInfo(part.cat_name,part.num,part.rev,&info);
  if (*info.part == 0) goto wrapup;

  /* and ftp it */
  ftpPart(&info);

  printf("%3d %s %s %s\n",*cnt,part.cat_name,part.num,info.sa_file_name);
 
wrapup:
  return 0;
} 

/* ----------------------------------------------
 * ftp the files that have bad xmls
 */
int ftp_extracts(sqlite *db)
{
  int sts;
  int cnt = 0;
  char *errmsg = NULL;

  sts = sqlite_exec_printf(db,
    "SELECT part_cat_name,part_num,part_rev FROM pdm_part "
    "LEFT JOIN extr_part USING(extr_name) "
    "WHERE have_xml = 0 OR have_xml ISNULL "
    "ORDER BY part_num,part_rev;",
    ftp_extract_cb,&cnt,&errmsg);
  if (sts)
  {
    printf("*** %s\n",errmsg);
    free(errmsg);
    return 0;
  }
  return 1;
}

