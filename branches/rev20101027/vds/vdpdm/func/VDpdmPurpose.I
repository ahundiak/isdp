/* $Id: VDpdmPurpose.I,v 1.5 2002/05/10 19:33:50 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdpdm/func/VDpdmPurpose.I
 *
 * Description:	Some pdm Purpose routines
 *
 * Dependencies:
 *
 * Revision History:
 * $Log: VDpdmPurpose.I,v $
 * Revision 1.5  2002/05/10 19:33:50  ahundiak
 * ah
 *
 * Revision 1.4  2001/03/30 20:33:28  jdsauby
 * js sp
 *
 * Revision 1.3  2001/03/07 19:09:16  jdsauby
 * Made better for VDstartup.
 *
 * Revision 1.2  2001/03/05 19:43:55  jdsauby
 * Finish Purpose Info
 *
 * Revision 1.1  2001/03/02 21:45:05  jdsauby
 * Added purpose Info
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 02/28/01  js      Creation
 *
 ***************************************************************************/
class implementation Root;

#include "VDtypedef.h"
#include "VDassert.h"
#include "VDlog.h"

#include "VDobj.h"
#include "VDexp.h"
#include "VDdir.h"
#include "VDos.h"
#include "VDpdm.h"
#include "VDrisc.h"
#include "VDDbDef.h"

VDASSERT_FFN("VDpdmPurpose.I");

/* ----------------------------------------------
 * Simple query for file key
 */
static void getFileKey(VDosnum osnum, IGRint *fileKey)
{
  TVDrisInfo ris;
  TVDpdmInfo info;

  IGRchar qry[256];

  // Init
  VDrisInitInfo(&ris);
  memset(&info,0,sizeof(TVDpdmInfo));
  *fileKey = 0;

  // Need the file
  VDosGetFileName(osnum,info.filename);
  if (*info.filename == 0) goto wrapup;

  // Get the cat/part/rev
  PDMGetPartInfoGivenFileName(info.filename,
                              info.catalog,
                              info.part,
                              info.rev);
  if (*info.catalog == 0) {

    // Might have an expression
    VDpdmGetPdmInfo(osnum,&info);
  }
  if (*info.catalog == 0) goto wrapup;

  // Query
  snprintf(qry,sizeof(qry),
           "select %s from %s where %s='%s' and %s='%s' and %s='%s';",
	   VDPDM_FILE_KEY_COLN_FILE_KEY, VDPDM_FILE_KEY_TABLE_NAME,
	   VDPDM_FILE_KEY_COLN_CATALOG,  info.catalog, 
	   VDPDM_FILE_KEY_COLN_PART,     info.part, 
	   VDPDM_FILE_KEY_COLN_REVISION, info.rev);
   
  VDrisQuery(&ris,qry);

  if (ris.rows) {

    *fileKey = atoi(ris.buf[0]);
    goto wrapup;
  }

  // Useful when testing parts under a different database
  VDpdmSetFileKeyForCPR(info.catalog,info.part,info.rev,fileKey);

wrapup:
  VDrisFreeInfo(&ris);
  return;
}

/* ------------------------------------------------------------------------
 * Returns the path of the purpose info expression
 */
static void getPurposeInfoPath(VDosnum osnum, IGRchar *path)
{
  IGRchar name[1024];
  IGRchar activeName[1024];
  
  VDosnum activeOS;
  
  // Arg check
  if (path == NULL) goto wrapup;
  *path = 0;

  // Default to active space
  VDosGetFileName(osnum,name);
  if (*name == 0) goto wrapup;

  // No need to deal with transient spaces, assume active space is lowest
  ex$get_cur_mod(osnum = &activeOS);
  if (osnum <= activeOS) {
    sprintf(path,":%s:IGENOD:purp_info",name);
    goto wrapup;
  }
  // Build off of the active
  VDosGetFileName(activeOS,activeName);

  sprintf(path,":%s:ref:%s:IGENOD:purp_info",activeName,name);
  
wrapup:
  return;
}

/* ------------------------------------------------------------------------
 * Get the purpose info expression if it exists
 */
static void getPurposeInfoExpID(VDosnum  a_osnum, 
	                        TGRid   *a_expID,
			        IGRchar *a_expPath,
			        IGRchar *a_expText)
{
  IGRstat sts;

  TGRid   expID;
  IGRchar path[128];
  
  // Arg check
  if (a_expID) a_expID->objid = NULL_OBJID;
  if (a_expText) *a_expText = 0;
  if (a_expPath) *a_expPath = 0;
  
  // Get the path
  if (a_osnum == OM_K_NOT_AN_OS) ex$get_cur_mod(osnum = &a_osnum);
  getPurposeInfoPath(a_osnum,path);
  if (*path == 0) goto wrapup;
  if (a_expPath) strcpy(a_expPath,path);
  
  // Get the expression
  expID.osnum = a_osnum;
  expID.objid = NULL_OBJID;
  sts = di$translate(objname = path,
		     p_objid = &expID.objid);
  if (!(sts & 1)) goto wrapup;
  if (expID.objid == NULL_OBJID) goto wrapup;
  
  if (a_expID) *a_expID = expID;
  
  // Get the text
  if (a_expText) {  
    vdexp$Get(objID = &expID, txt = a_expText);
    if (*a_expText == 0) goto wrapup;
  }
  
wrapup:
  return;
}

/* ------------------------------------------------------------------------
 * Query the database for purpose info, given a fileKey
 * ***/
static void qryPurposeInfoDB(IGRint fileKey, TVDpdmPurposeInfo *purpInfo)
{
  IGRchar     sql[1024];
  TVDrisInfo  ris;

  // Init
  VDrisInitInfo( &ris );

  // build the query
  snprintf(sql,sizeof(sql),
          "Select %s,%s,%s,%s from %s where %s=%d;",
	   VDPDM_PURP_INFO_COLN_PURPOSE,
	   VDPDM_PURP_INFO_COLN_ZONE,
	   VDPDM_PURP_INFO_COLN_UNIT,
	   VDPDM_PURP_INFO_COLN_SYSTEM,
           VDPDM_PURP_INFO_TABLE_NAME,
	   VDPDM_PURP_INFO_COLN_FILEKEY,fileKey);

  // query it
  VDrisQuery( &ris, sql );
  if (ris.rows < 1) goto wrapup;

  // extract
  strcpy(purpInfo->purpose,ris.buf[0]);
  strcpy(purpInfo->zone,   ris.buf[1]);
  strcpy(purpInfo->unit,   ris.buf[2]);
  strcpy(purpInfo->system, ris.buf[3]);

wrapup:
  VDrisFreeInfo( &ris );
  return;
}

/* ------------------------------------------------------------------------
 * Query the database for purpose info, given an osnum
 * ***/
static void getPurposeInfoDB(VDosnum osnum, TVDpdmPurposeInfo *purpInfo)
{
  IGRint fileKey;

  // Need file key
  getFileKey(osnum,&fileKey);
  if (fileKey == 0) goto wrapup;

  // Doit
  qryPurposeInfoDB(fileKey,purpInfo);

wrapup:
  return;
}

/* -----------------------------------------------
 * Gets the purpose info from the text expression
 */
static void getPurposeInfoExp(VDosnum osnum, TVDpdmPurposeInfo *purpInfo)
{
  IGRchar expPath[256],expText[256];
  TGRid   expID;
  IGRchar *p;
  
  // Default to active
  getPurposeInfoExpID(osnum,&expID,expPath,expText);  
  if (*expText == 0) goto wrapup;

  // Parse out
  p = strchr(expText,'|');
  if (p) strcpy(expText,p+1);

  p = strchr(expText,'|');
  if (p) {
    *p = 0;
    strcpy(purpInfo->purpose,expText);
    strcpy(expText,p+1);
  }
  p = strchr(expText,'|');
  if (p) {
    *p = 0;
    strcpy(purpInfo->zone,expText);
    strcpy(expText,p+1);
  }
  p = strchr(expText,'|');
  if (p) {
    *p = 0;
    strcpy(purpInfo->unit,expText);
    strcpy(expText,p+1);
  }
  strcpy(purpInfo->system,expText);
  
wrapup:
  return;
}

/* ------------------------------------------------------------------------
 * Updates the expression for the purpose info
 */
static void setPurposeInfoExp(VDosnum osnum, TVDpdmPurposeInfo *info)
{
  IGRchar expPath[128];
  IGRchar expText[128];
  TGRid   expID;
  
  IGRchar purpText[128];
  
  // Build the text string
  snprintf(purpText,sizeof(purpText),"%d|%s|%s|%s|%s",
          -1,
          info->purpose,
	  info->zone,
          info->unit,
          info->system);

  // If the expression does not exist, create it
  getPurposeInfoExpID(osnum, &expID, expPath, expText);
  if (expID.objid == NULL_OBJID) {

    vdexp$CreateTextExp(osnum = osnum,
			name  = expPath,
			text  = purpText,
			objID = &expID);

    goto wrapup;
  }

  // If the expression exists then see if it's valid
  if (!strcmp(expText,purpText)) goto wrapup;
  
  // Update it
  vdexp$ModifyTextExp(objID = &expID, text = purpText);
  
wrapup:
  return;
}

/* ----------------------------------------------
 * Updates or adds purpose info to database 
 */
static void setPurposeInfoDB(VDosnum osnum, TVDpdmPurposeInfo  *info)
{
  IGRchar    sql[256];
  TVDrisInfo ris;

  IGRint fileKey;

  // Init
  VDrisInitInfo( &ris );

  // Get the file key
  getFileKey(osnum,&fileKey);
  if (fileKey == 0) goto wrapup;

  // update existing entry
  snprintf(ris.sql,sizeof(ris.sql),
	  "Select * from %s where %s=%d;",
	  VDPDM_PURP_INFO_TABLE_NAME,
	  VDPDM_PURP_INFO_COLN_FILEKEY,fileKey);

  VDrisQuery( &ris, NULL );

  if (ris.rows > 0) {
    // update it
    snprintf(sql,sizeof(sql),
             "Update %s set %s='%s',%s='%s',%s='%s',%s='%s' where %s=%d;",
	     VDPDM_PURP_INFO_TABLE_NAME,
	     VDPDM_PURP_INFO_COLN_PURPOSE, info->purpose,
	     VDPDM_PURP_INFO_COLN_ZONE,    info->zone,
	     VDPDM_PURP_INFO_COLN_UNIT,    info->unit,
	     VDPDM_PURP_INFO_COLN_SYSTEM,  info->system,
	     VDPDM_PURP_INFO_COLN_FILEKEY, fileKey );
    VDrisExecute( sql );
    goto wrapup;
  }

  // insert a new entry
  snprintf(sql,sizeof(sql),
	  "Insert into %s values (%d,'%s','%s','%s','%s');",
	  VDPDM_PURP_INFO_TABLE_NAME,
	  fileKey, 
          info->purpose, 
          info->zone,
	  info->unit,
          info->system);

  VDrisExecute(sql);

wrapup:
  VDrisFreeInfo(&ris);
  return;
}

/* -----------------------------------------------
 * Set osnum to active if it's a null
 */
static void setDefaultOS(VDosnum *osnum)
{
  if (*osnum == NULL_OSNUM) ex$get_cur_mod(osnum = osnum);
  return;
}

/* -----------------------------------------------
 * Set the purpose info updating both the database and
 * the text expression
 */
void VDpdmSetPurposeInfo(VDosnum osnum, TVDpdmPurposeInfo *purpInfo)
{
  VDASSERT_FN("VDpdmSetPurposeInfo");

  // Arg check
  VDASSERTW(purpInfo);

  // Default to current osnum
  setDefaultOS(&osnum);

  // Expression
  setPurposeInfoExp(osnum,purpInfo);

  // Database
  if (!VDpdmVerifyLogin()) goto wrapup;
  setPurposeInfoDB(osnum,purpInfo);
    
wrapup:
  return;
}

/* -----------------------------------------------
 * Standard interface for getting purpose info
 * From the expression or the database
 */
void VDpdmGetPurposeInfo(VDosnum osnum, TVDpdmPurposeInfo *purpInfo)
{
  // Arg check
  if (purpInfo == NULL) goto wrapup;
  memset(purpInfo,0,sizeof(TVDpdmPurposeInfo));

  // Default to current osnum
  setDefaultOS(&osnum);

  // Try expression
  getPurposeInfoExp(osnum,purpInfo);
  if (*purpInfo->purpose) goto wrapup;

  // Try database
  if (!VDpdmVerifyLogin()) goto wrapup;
  getPurposeInfoDB(osnum,purpInfo);
  if (*purpInfo->purpose == 0) goto wrapup;

  // Update expression for next time
  setPurposeInfoExp(osnum,purpInfo);
  
wrapup:
  return;
}

/* ------------------------------------------------------------------------
 * Creates, validates or updates the pdm info expression
 * Designed to be called during file retrieval to ensure
 * the expression is up to date
 */
void VDpdmUpdatePurposeInfo(VDosnum osnum)
{
  TVDpdmPurposeInfo purpInfo;
  
  // Need to be logged into pdm
  if (!VDpdmVerifyLogin()) goto wrapup;

  // Default osnum
  setDefaultOS(&osnum);
  
  // Data in database?
  memset(&purpInfo,0,sizeof(TVDpdmPurposeInfo));
  getPurposeInfoDB(osnum,&purpInfo);
  if (*purpInfo.purpose) {
    setPurposeInfoExp(osnum,&purpInfo);
    goto wrapup;
  }

  // Data in expression?
  getPurposeInfoExp(osnum,&purpInfo);
  if (*purpInfo.purpose == 0) goto wrapup;
  setPurposeInfoDB(osnum,&purpInfo);

wrapup:
  return;
}

/* -------------------------------------------
 * The existing command object likes to query
 * directly on file keys
 */
void VDpdmQryPurposeInfo(IGRint fileKey, TVDpdmPurposeInfo *info)
{
  VDASSERT_FN("VDpdmQryPurposeInfo");

  // Arg check
  VDASSERTW(info); memset(info,0,sizeof(TVDpdmPurposeInfo));
  if (fileKey == 0) goto wrapup;
  if (!VDpdmVerifyLogin()) goto wrapup;

  qryPurposeInfoDB(fileKey,info);

wrapup:
  return;
}

/* -------------------------------------------
 * Open the vdpdm_purp.txt file for list of valid purposes
 * ***/
FILE *VDpdmOpenPurpListFile()
{
    IGRint i;
    IGRchar buf[1024];
    FILE *file;

    // Look in local directory
    file = fopen("vdpdm_purp.txt","rt");
    if (file) return file;

    // Look in config directory
    for(i = 0; 1; i++) {

	// Product specific loading
	*buf = 0;
	EX_getpath(i,buf,sizeof(buf),EX_CONFIG_PATH);
	if (*buf == 0) {
	    file = NULL;
	    return file;
	}

	strcat(buf,"config/sets/vdpdm_purp.txt");
	//printf("Directory for vdpdm_purp.txt file is [%s]\n",buf);

	file = fopen(buf,"rt");
	if (file != NULL) return file;
    }
}

/* ------------------------------------------
 * Check zone, unit, or system values depending on
 * purpose
 * **/
IGRstat VDrrvCheckPurposeValues( TVDpdmPurposeInfo *info,
                                 IGRchar           *msg )
{
    IGRstat retFlag = 0;

    if (info == NULL) goto wrapup;
    if (*info->purpose == 0) goto wrapup;
    if (msg) *msg = 0;


    // check the length of the purpose string
    if ( strlen(info->purpose) > 12 ) {
        strcpy(msg,"Purpose must be 12 characters or less");
	goto wrapup;
    }

    // check for unit
    if ( !strncmp(info->purpose,"unit",4) ) {
	if (*info->unit == 0) {
	    strcpy(msg,"Must have a unit for this purpose");
	    goto wrapup;
	}
    }

    // check for zone
    if ( !strncmp(info->purpose,"zone",4) ) {
	if (*info->zone == 0) {
	    strcpy(msg,"Must have a zone for this purpose");
	    goto wrapup;
	}
    }
    
    // check for unit
    if ( !strncmp(info->purpose,"sys",3) ) {
	if (*info->system == 0) {
	    strcpy(msg,"Must have a system for this purpose");
	    goto wrapup;
	}
    }

    // check for at least one
    if ( (*info->unit == 0) &&
	 (*info->zone == 0) &&
	 (*info->system == 0) ) {
	strcpy(msg,"Must have at least one zone/unit/system");
	goto wrapup;
    }

    // done, valid purpose
    retFlag = 1;
    strcpy(msg,"Valid Purpose");

wrapup:
    return retFlag;
}

end implementation Root;

