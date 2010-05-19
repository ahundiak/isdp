/* $Id: VDnfmEnv.c,v 1.2 2001/02/11 17:59:46 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdah/VDnfmEnv.c
 *
 * Description: Info about nfm/ris enviroments
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDnfmEnv.c,v $
 *      Revision 1.2  2001/02/11 17:59:46  ahundiak
 *      Renamed VDris2 to VDrisc
 *
 *      Revision 1.1  2001/02/01 21:58:19  ahundiak
 *      ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 01/26/01  ah      Creation
 ***************************************************************************/

#include "VDtypedefc.h"
#include "VDrisc.h"
#include "VDnfmc.h"
#include "ris.h"

/* -----------------------------------------------
 * Just a fake callback
 */
static void showStatusx(IGRchar *buf) 
{
  return;
}

/* -----------------------------------------------
 * Real simpler routine for logging into database
 * Usually for automatic logins on startup
 */
IGRstat VDnfmOpenEnv(IGRchar *a_envName, 
		     void (*showStatus)(IGRchar *buf),
		     TVDnfmEnvInfo *info)
{
  IGRstat retFlag = 0;
  IGRstat sts;

  IGRchar envName[128];
  IGRchar *p;
  
  TVDnfmEnvInfo infox;
  
  // Init
  if (showStatus == NULL) showStatus = showStatusx;
  if (info == NULL) info = &infox;
  memset(info,0,sizeof(TVDnfmEnvInfo));
  
  // Get the name
  if (a_envName) strcpy(envName,a_envName);
  else           *envName = 0;
  
  // Use env
  if (*envName == 0) {
    p = getenv("ISDP_NFM_ENV");
    if (p) strcpy(envName,p);
  }
  if (*envName == 0) {
    (*showStatus)("No NFM Env Name for logging in");
    goto wrapup;
  }

  // Should support ENV:USER:PASS

  // Grab the info
  sts = VDnfmGetEnvInfoForPdmEnv(envName,info,showStatus);
  if (!(sts & 1)) goto wrapup;

  // Locate schema file
  sts = VDnfmLocateSchemaFile(info,showStatus);
  if (!(sts & 1)) goto wrapup;
  
  // Open it
  sts = VDnfmOpenSchema(info,showStatus);
  if (!(sts & 1)) goto wrapup;
  
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Validate the user
 */
IGRstat VDnfmValidateUser(TVDnfmEnvInfo *info, void (*showStatus)(IGRchar *buf))
{
  IGRstat retFlag = 0;
  IGRstat sts;
  
  IGRchar buf[128];
  IGRint  i;

  TVDrisInfo risInfo;
  
  // Init
  VDrisInitInfo(&risInfo);
  if (showStatus == NULL) showStatus = showStatusx;
  
  // Arg check
  if (info == NULL) goto wrapup;
  info->pdmNum = 0;
  
  if (*info->schName == 0) goto wrapup;
  if (*info->pdmName == 0) goto wrapup;

  // Verified Opened
  VDrisGetOpenSchema(buf);
  if (strcmp(buf,info->schName)) {
    retFlag = 0;
    goto wrapup;
  }
      
  // Open it   
  sprintf(buf,"Validating user %s ...",info->pdmName);
  (*showStatus)(buf);
  
  // Query
  sprintf(risInfo.sql,
	  "Select n_userno,n_passwd from nfmusers where n_username = '%s';",
	  info->pdmName);  
  VDrisQuery(&risInfo,NULL);
  if (risInfo.rows != 1) goto wrapup;

  // Check password
  VDnfmDecrypt(risInfo.buf[1],buf);
  if (!strcmp (risInfo.buf[1],buf)) goto wrapup;
    
  // Done
  info->pdmNum = atoi(risInfo.buf[0]);
  retFlag = 1;
  
 wrapup:

  if (info) {  
    if (retFlag) sprintf(buf,"Validated User %s",info->pdmName);
    else         sprintf(buf,"Invalid User %s",  info->pdmName);
    (*showStatus)(buf);
  }
  
  VDrisFreeInfo(&risInfo);
   
  return retFlag;
}

/* -----------------------------------------------
 * Setup a call to the locate schema file
 */
IGRstat VDnfmOpenSchema(TVDnfmEnvInfo *info, void (*showStatus)(IGRchar *buf))
{
  IGRstat retFlag = 0;
  IGRstat sts;
  
  IGRchar buf[128];
  IGRint  i;
  
  // Init
  if (showStatus == NULL) showStatus = showStatusx;
  
  // Arg check
  if ((info == NULL) || (*info->schName == 0)) goto wrapup;

  // Check if already opened (maybe should be silent)
  VDrisGetOpenSchema(buf);
  if (!strcmp(buf,info->schName)) {
    retFlag = 1;
    goto wrapup;
  }
      
  // Open it
  sprintf(buf,"Opening %s %s ...",info->envName,info->schName);
  (*showStatus)(buf);

  sprintf(buf,"default schema %s.%s",info->schName,info->schPass);

  // Try as many as three times
  for(i = 0; i < 3; i++) {
    sts = VDrisExecuteSilent(buf);
    if (sts & 1) {
      retFlag = 1;
      goto wrapup;
    }
  }
    
  // Done (Failed)
  
 wrapup:
  if (info) {
    if (retFlag) sprintf(buf,"Opened Schema %s %s",        info->envName,info->schName);
    else         sprintf(buf,"Failed to Open Schema %s %s",info->envName,info->schName);
    (*showStatus)(buf);
  }
  
  return retFlag;
}

/* -----------------------------------------------
 * Setup a call to the locate schema file
 */
IGRstat VDnfmLocateSchemaFile(TVDnfmEnvInfo *info, void (*showStatus)(IGRchar *buf))
{
  IGRstat retFlag = 0;
  
  schema_file_parms parms;

  IGRchar buf[128];
  
  // Init
  if (showStatus == NULL) showStatus = showStatusx;
  
  // Arg check
  if ((info == NULL) || (*info->srvNode == 0)) goto wrapup;

  // Only do the locate if necessary
  memset(&parms,0,sizeof(schema_file_parms));
  RISget_schema_file_location(&parms);
  if (!strcmp(parms.address,info->srvNode)) {
    retFlag = 1;
    goto wrapup;
  }
  
  // Setup
  memset(&parms,0,sizeof(schema_file_parms));
  parms.protocol = 'T';
  strcpy(parms.address, info->srvNode);
  strcpy(parms.username,info->nfmName);
  strcpy(parms.password,info->nfmPass);
  strcpy(parms.password,info->nfmPass);
  strcpy(parms.filename,"schemas");

  sprintf(buf,"Locating Schema File %s %s ...",info->envName,info->schName);
  (*showStatus)(buf);
    
  RISlocate_schema_file(&parms);

  if (RISget_sqlcode() != RIS_SUCCESS) {
    goto wrapup;
  }
  
  // Done
  retFlag = 1;
  
 wrapup:
  if (info) {
    if (retFlag) sprintf(buf,"Located Schema File %s %s",         info->envName,info->schName);
    else         sprintf(buf,"Failed to Locate Schema File %s %s",info->envName,info->schName);
    (*showStatus)(buf);
  }
  
  return retFlag;
}

/* -----------------------------------------------
 * Print out envdat structure
 */
IGRstat VDnfmPrintEnvInfo(FILE *file, TVDnfmEnvInfo *info)
{
  IGRstat retFlag = 0;
  
  // Arg check
  if (file == NULL) file = stdout;
  if (info == NULL) goto wrapup;
  
  fprintf(file,"ENV '%s', APP '%s' SERVER NODE '%s'\n",
	  info->envName,
	  info->appName,
	  info->srvNode);

  fprintf(file,"SCH '%s' '%s'\n",
	  info->schName,info->schPass);

  fprintf(file,"NFM '%s' '%s'\n",
	  info->nfmName,info->nfmPass);

  fprintf(file,"\n");
  
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Decode env_dat line
 */
IGRstat VDnfmDecodeEnvInfoLine(char *a_line, TVDnfmEnvInfo *info)
{
  IGRstat retFlag = 0;

  IGRchar *p;
  IGRint   i;

  IGRchar line[256];
  
  IGRchar buf0[100];
  IGRchar buf1[100];
  IGRchar buf2[100];
  
  // Arg check
  if (info == NULL) goto wrapup;
  memset(info,0,sizeof(TVDnfmEnvInfo));
  if (a_line == NULL) goto wrapup;
  strcpy(line,a_line);

  // Ignore comments and such
  if ((*line != 'p') && (*line != 'n')) goto wrapup;
    
  // Get rid of eol
  p = strchr(line,'\n');
  if (p) *p = 0;
    
  // Break it up
  i = 0;
  for(p = strchr(line,'\001'); p; p = strchr(line,'\001')) {
    *p = 0;
    strcpy(buf0,line);

    if (i > 2) {
      sprintf(buf1,"%*.*s", 25, 25, buf0);
      VDnfmDecrypt(buf1,buf2);
      strcpy(buf0,buf2);
    }
  
    switch(i) {
      case 0: strcpy(info->envName,buf0); break;
      case 1: strcpy(info->appName,buf0); break;
      case 2: strcpy(info->srvNode,buf0); break;
      case 3: strcpy(info->schName,buf0); break;
      case 4: strcpy(info->schPass,buf0); break;
      case 5: strcpy(info->nfmName,buf0); break;
      case 6: strcpy(info->nfmPass,buf0); break;
    }
    	
    strcpy(line,p+1);
    i++;
  }
  
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Dump out env dat line
 */
IGRstat VDnfmDumpEnvInfoLine(FILE *file, IGRchar *line)
{
  IGRstat retFlag = 0;

  TVDnfmEnvInfo info;
  
  // Arg check
  if (file == NULL) file = stdout;
  if (line == NULL) goto wrapup;

  // Ignore comments and such
  if ((*line != 'p') && (*line != 'n')) goto wrapup;
  
  // Fill Struct
  VDnfmDecodeEnvInfoLine(line,&info);

  // Print it
  VDnfmPrintEnvInfo(file,&info);
  
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Dump out env dat file
 */
IGRstat VDnfmDumpEnvInfoFile(FILE *file_out, IGRchar *file_name)
{
  IGRstat retFlag = 0;
  FILE   *file = NULL;
  IGRchar buf[256];
  
  // Arg check
  if (file_out  == NULL) file_out = stdout;
  if (file_name == NULL) goto wrapup;
  
  // Open
  file = fopen(file_name,"rt");
  if (file == NULL) {
    printf("*** Could not open %s for reading\n",file_name);
    goto wrapup;
  }
  printf("------- Dumping %s --------\n",file_name);
  
  // Cycle through
  while(fgets(buf,sizeof(buf),file)) {
    VDnfmDumpEnvInfoLine(file_out,buf);
  }
  
  // Done
  fclose(file);
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * From the ris parms file
 *
SCHEMA_FILE_PROTOCOL  T
SCHEMA_FILE_ADDRESS   pcc0405
SCHEMA_FILE_USERNAME  nfmadmin
SCHEMA_FILE_PASSWORD  Jt/M`jkY9@^q}{jJHfty%rRbb"?6,]E4HajU8
SCHEMA_FILE_NAME      schemas
*/

/* -----------------------------------------------
 * From NFMenv.dat
pdme_lpdaug06PDMpcc0405___big long encrypt string 

 Need the .dat file for the clh stuff to work
 Have not tried the ris stuff yet but probably need
 it to connect to the ris schemas

 So the actual schema info is in NFMenv.dat
 I think the parms password is probably the nfmadmin unix
*/

/* -----------------------------------------------
 * Return a path to the nfm env file
 */
IGRstat VDnfmGetEnvInfoFileName(IGRchar *file_name)
{
  IGRstat retFlag = 0;
  
  if (file_name == NULL) goto wrapup;

  strcpy(file_name,"/opt/ingr/nfm/NFMenv.dat");

  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Returns schema password for given schema
 */
IGRstat VDnfmGetSchemaPassword(IGRchar *schema, IGRchar *password)
{
  IGRstat retFlag = 0;

  IGRchar file_name[128];
  IGRchar buf[256];
  
  FILE *file;

  TVDnfmEnvInfo info;
  
  // Arg check
  if (password == NULL) goto wrapup;
  *password = 0;
  if (schema == NULL) goto wrapup;
  
  // Open the data file
  VDnfmGetEnvInfoFileName(file_name);
  if (*file_name == 0) goto wrapup;
  
  file = fopen(file_name,"rt");
  if (file == NULL) goto wrapup;
  
  // Cycle through
  while(fgets(buf,sizeof(buf),file)) {
    
    // Get the data
    VDnfmDecodeEnvInfoLine(buf, &info);
    if (!strcmp(info.schName,schema)) {
      strcpy(password,info.schPass);
      fclose(file);
      retFlag = 1;
      goto wrapup;
    }
  }
  
  // Not found
  fclose(file);
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Returns env info for given pdm enviroment
 */
IGRstat VDnfmGetEnvInfoForPdmEnv(IGRchar *env, TVDnfmEnvInfo *a_info, void (*showStatus)(IGRchar *buf))
{
  IGRstat retFlag = 0;

  IGRchar fileName[128];
  IGRchar envName [128];
  IGRchar buf[256];
  
  FILE *file;

  TVDnfmEnvInfo info;

  // Init
  if (showStatus == NULL) showStatus = showStatusx;
  
  // Arg check
  if (a_info == NULL) goto wrapup;
  memset(a_info,0,sizeof(TVDnfmEnvInfo));
  
  if (env == NULL) goto wrapup;

  // Make the prefix optional
  if (!strncmp(env,"pdme_",5)) strcpy (envName,env);
  else                         sprintf(envName,"pdme_%s",env);
  
  // Open the data file
  VDnfmGetEnvInfoFileName(fileName);
  file = fopen(fileName,"rt");
  if (file == NULL) goto wrapup;
  
  // Cycle through
  while(fgets(buf,sizeof(buf),file)) {
    
    // Get the data
    VDnfmDecodeEnvInfoLine(buf, &info);
    if (!strcmp(info.envName,envName)) {
      *a_info = info;
      fclose(file);
      retFlag = 1;
      goto wrapup;
    }
  }
  
  // Not found
  fclose(file);
  
 wrapup:
  if (env) {
    if (retFlag) sprintf(buf,"Found enviroment for %s",env);
    else         sprintf(buf,"Could not find enviroment for %s",env);
    (*showStatus)(buf);
  }
  
  return retFlag;
}






