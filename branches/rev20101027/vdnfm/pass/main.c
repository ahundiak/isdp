/* $Id: VDnfmEnv.c,v 1.2 2001/02/11 17:59:46 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vds/vdnfm/dat/main.c
 *
 * Description: NFM Env DAT Generator
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDnfmEnv.c,v $
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 02/21/05  ah      Creation
 ***************************************************************************/

#include "VDtypedefc.h"
#include "VDrisc.h"
#include "VDnfmc.h"

static IGRstat setInfo_lpdhsv(TVDnfmEnvInfo *info)
{
    memset(info,0,sizeof(TVDnfmEnvInfo));

    strcpy(info->envName,"pdme_lpdhsv");
    strcpy(info->appName,"PDM");
    strcpy(info->srvNode,"pcc0405");
    strcpy(info->schName,"lpdhsv");
    strcpy(info->schPass,"lpdhsv");
    strcpy(info->nfmName,"nfmadmin");
    strcpy(info->nfmPass,"millenium");

    return 0;
}
static IGRstat setInfo_twr04(TVDnfmEnvInfo *info)
{
    memset(info,0,sizeof(TVDnfmEnvInfo));

    strcpy(info->envName,"pdme_twr04");
    strcpy(info->appName,"PDM");
    strcpy(info->srvNode,"mlcsdb");
    strcpy(info->schName,"twr04");
    strcpy(info->schPass,"twr04");
    strcpy(info->nfmName,"nfmadmin");
    strcpy(info->nfmPass,"nfm.admin1");

    return 0;
}
static IGRstat setInfo_twr(TVDnfmEnvInfo *info)
{
    memset(info,0,sizeof(TVDnfmEnvInfo));

    strcpy(info->envName,"pdme_twr");
    strcpy(info->appName,"PDM");
    strcpy(info->srvNode,"mlcsdb");
    strcpy(info->schName,"twr");
    strcpy(info->schPass,"twr");
    strcpy(info->nfmName,"nfmadmin");
    strcpy(info->nfmPass,"nfm.admin1");

    return 0;
}

/* -----------------------------------------------
 * Encode env_dat line
 * Note that while the encrypted string differ from those
 * produced by the other dat generator, this encoding
 * does indeed work
 */
IGRstat VDnfmEncodeEnvInfoLine(TVDnfmEnvInfo *info, char *line)
{
  IGRstat retFlag = 0;

  IGRchar *p;
  IGRint   i;

  IGRchar buf[128];

  /* Start */
  p = line;
  *p = 0;

  strcpy(p,info->envName);
  p += strlen(p);
  *p++ = '\001';

  strcpy(p,info->appName);
  p += strlen(p);
  *p++ = '\001';

  strcpy(p,info->srvNode);
  p += strlen(p);
  *p++ = '\001';

  VDnfmEncrypt(info->schName,buf);
  strcpy(p,buf);
  p += strlen(p);
  *p++ = '\001';

  VDnfmEncrypt(info->schPass,buf);
  strcpy(p,buf);
  p += strlen(p);
  *p++ = '\001';

  VDnfmEncrypt(info->nfmName,buf);
  strcpy(p,buf);
  p += strlen(p);
  *p++ = '\001';

  VDnfmEncrypt(info->nfmPass,buf);
  strcpy(p,buf);
  p += strlen(p);
  *p++ = '\001';

  *p = '\n';


  return 0;
}


main()
{
    IGRchar buf1[128];
    IGRchar buf2[128];

    strcpy(buf1,"Z]H5lCxa0I)\"lBc+09l9>GAg;");
    VDnfmDecrypt(buf1,buf2);
    printf("Password: %s\n",buf2);

    VDnfmEncrypt("nfm.admin1",buf2);
    printf("Password nfm.admin1 is: %s\n",buf2);
}
