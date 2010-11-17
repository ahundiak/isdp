/* ----------------------------------------------
 * Query routines
 */
#include "VDtypedefc.h"
#include "VDrisc.h"
#include "VDdom2.h"

#include "sqlite.h"
#include "part.h"

#include <sys/types.h>
#include <sys/stat.h>

/* ----------------------------------------------
 * Ris Server connection stuff 
 */
static char s_risServerName[32];
static int  s_risIsOpen = 0;

void setRisServer(char *name) { strcpy(s_risServerName,name); return; }

void openRisServer()
{
  int sts;

  if (s_risIsOpen) return;

  sts = VDrisOpenSchema(s_risServerName);
  if (!(sts & 1))
  {
    printf("*** Unable to connect to ris server %s\n",s_risServerName);
    exit(0);
  }
  s_risIsOpen = 1;

wrapup:
  return;
}
void closeRisServer()
{
  if (s_risIsOpen == 0) return;

  VDrisCloseSchema();

  s_risIsOpen = 0;
  return;
}

/* ----------------------------------------------
 * Qry the info for a given part
 */
int qryPartInfo(char *catalog, char *part, char *rev, TpdmInfo *info)
{
  char qry[1024];
  TVDrisInfo ris;
  int i;

  /* Init */
  memset(info,0,sizeof(TpdmInfo));
  strcpy(info->catalog,catalog);
  strcpy(info->part,   part);
  strcpy(info->rev,    rev);

  /* Make sure schema is opened */
  openRisServer();
  
  /* The query */
  sprintf(qry,
    "SELECT n_catalogno,n_itemno,n_fileno, "
    "n_sano,nfmstoragearea.n_nodeno,n_username,n_pathname, "
    "n_nodename,n_cofilename,n_statename,n_cidate, "
    "n_filenum,n_fileversion "
    "FROM %s,f_%s,nfmstoragearea,nfmnodes,nfmstates,nfmcatalogs "
    "WHERE n_itemname = '%s' AND n_itemrev = '%s' "
    "AND n_itemno = n_itemnum "
    "AND n_cisano = n_sano "
    "AND nfmstoragearea.n_nodeno = nfmnodes.n_nodeno "
    "AND %s.n_stateno = nfmstates.n_stateno "
    "AND nfmcatalogs.n_catalogname = '%s' "
    "ORDER BY n_fileversion ",
    catalog,catalog,part,rev,catalog,catalog);

  /* Query it */
  VDrisInitInfo(&ris);
  VDrisQuery(&ris,qry);

  if (ris.rows == 0)
  {
    VDrisFreeInfo(&ris);
    logMsg(1,1,"*** PDM Part Not Found %s %s %s\n",catalog,part,rev);
    return 0;
  }
  /* Only care about the last one */
  i = (ris.rows - 1) * ris.cols;

  /* Probably shoud verify n_filenum is always 1 */

  /* Xfer */ 
  info->catalog_num = atoi(ris.buf[i+0]);
  info->part_num    = atoi(ris.buf[i+1]);
  info->file_num    = atoi(ris.buf[i+2]);

  encode_filename(info->catalog_num,info->file_num,info->sa_file_name);
 
  info->sa_num      = atoi(ris.buf[i+3]);
  info->sa_node_num = atoi(ris.buf[i+4]);

  strcpy(info->sa_user_name,ris.buf[i+5]);
  strcpy(info->sa_node_path,ris.buf[i+6]);
  strcpy(info->sa_node_name,ris.buf[i+7]);

  strcpy(info->co_file_name,ris.buf[i+8]);
  strcpy(info->n_statename, ris.buf[i+9]);
  strcpy(info->sa_file_date,ris.buf[i+10]);

  VDrisFreeInfo(&ris);
  return 1;
}

/* ----------------------------------------------
 * Get a part from pdm and stash locally
 */
int ftpPart(TpdmInfo *info)
{
  int  sts;
  char ts [40];
  char cmd[128];
  char buf[128];
  char xmlFileName [128];
  char isdpFileName[128];

  domNode fileNode;

  struct stat fileStat;

  /* Make sure have something */
  if (*info->co_file_name == 0) return 0;

  /* Local name */
  sprintf(isdpFileName,"%s.%04d",info->co_file_name,info->file_num);
 
  /* If have a cache then use it */
  sprintf(buf,"isdp/%s",isdpFileName);
  if (stat(buf,&fileStat) == 0)
  {
    if (fileStat.st_size) return 1;
  }

  /* Do the ftp thing */
  sts = ftp_get(
    info->sa_node_name,
    info->sa_user_name,
    "millenium",
    info->sa_node_path,
    info->sa_file_name);
  if (!(sts & 1)) return 0;

  /* Rename and unzip */
  sprintf(cmd,"mv %s %s.gz",info->sa_file_name,isdpFileName);
  system (cmd);
  sprintf(cmd,"gunzip -f -q %s.gz",isdpFileName);
  system (cmd);
  sprintf(cmd,"mv %s isdp/%s",isdpFileName,isdpFileName);
  system (cmd);

  /* Build some meta data */
  fileNode = domCreateDoc("file_info");

  domCreateTextAttrNode(fileNode,"catalog",info->catalog);
  domCreateTextAttrNode(fileNode,"part",   info->part);
  domCreateTextAttrNode(fileNode,"rev",    info->rev);

  domCreateTextAttrNode(fileNode,"co_file_name",info->co_file_name);
  domCreateTextAttrNode(fileNode,"state_name",  info->n_statename);

  domCreateTextAttrNode(fileNode,"sa_file_name",info->sa_file_name);
  domCreateTextAttrNode(fileNode,"sa_file_date",info->sa_file_date);

  domCreateTextAttrNode(fileNode,"sa_user_name",info->sa_user_name);
  domCreateTextAttrNode(fileNode,"sa_node_name",info->sa_node_name);
  domCreateTextAttrNode(fileNode,"sa_node_path",info->sa_node_path);

  domCreateIntAttrNode(fileNode,"catalog_num",info->catalog_num);
  domCreateIntAttrNode(fileNode,"part_num",   info->part_num);
  domCreateIntAttrNode(fileNode,"file_num",   info->file_num);
  domCreateIntAttrNode(fileNode,"sa_num",     info->sa_num);
  domCreateIntAttrNode(fileNode,"sa_node_num",info->sa_node_num);

  VDsysGetTimeStamp(ts);
  domCreateTextAttrNode(fileNode,"retrieved",ts);

  sprintf(xmlFileName,"isdp/%s.xml",isdpFileName);
  domSaveDocToFile(fileNode,xmlFileName);
  domFreeDoc(fileNode);

  /* Done */
  return 1;
}
