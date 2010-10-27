/* $Id: VDpdm.I,v 1.8 2002/02/28 16:13:54 jdsauby Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdpdm/func/VDpdm.I
 *
 * Description:	Some pdm routines
 *
 * Dependencies:
 *
 * Revision History:
 * $Log: VDpdm.I,v $
 * Revision 1.8  2002/02/28 16:13:54  jdsauby
 * TR 6059 and 6053
 *
 * Revision 1.7  2001/03/07 19:09:14  jdsauby
 * Made better for VDstartup.
 *
 * Revision 1.6  2001/03/07 00:27:37  ahundiak
 * ah
 *
 * Revision 1.5  2001/03/01 16:10:07  jdsauby
 * Fixed Infinite loop for non pdm managed parts
 *
 * Revision 1.4  2001/02/23 16:11:09  jdsauby
 * Added CheckRefFiles to updatepdminfo for startup
 *
 * Revision 1.3  2001/02/21 21:58:18  jdsauby
 * Just keeping the server up to date
 *
 * Revision 1.2  2001/02/21 13:02:18  jdsauby
 * CR4088
 *
 * Revision 1.1  2001/02/12 20:44:58  jdsauby
 * Moved from vds/vdah/om  js
 *
 * Revision 1.3  2001/01/11 16:34:32  art
 * sp merge
 *
 * Revision 1.1  2001/01/11 16:20:59  art
 * s merge
 *
 * Revision 1.1.1.1  2001/01/04 21:07:40  cvs
 * Initial import to CVS
 *
# Revision 1.2  2000/04/04  21:11:52  pinnacle
# ah
#
# Revision 1.1  2000/03/09  21:39:14  pinnacle
# ah
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 03/08/00  ah      Creation
 * 03/06/01  ah      VDpdmGetPdmInfo now does no ris lookups
 ***************************************************************************/
class implementation Root;

#include "VDtypedef.h"

#include "VDobj.h"
#include "VDexp.h"
#include "VDdir.h"
#include "VDos.h"
#include "VDpdm.h"
#include "PDUuser.h"

extern struct PDUuser   *user;

/* --------------------------------------------------------------
 * Returns pdu username and user_id
 * **/
IGRstat VDpdmGetUsernameID( IGRchar *username, IGRlong *userid )
{
    IGRstat retFlag = 0;
    IGRstat sts;

    // Arg check
    if (username == NULL) goto wrapup;
    if (userid   == NULL) goto wrapup;
    username[0] = '\0';

    // verify logged in
    sts = VDpdmVerifyLogin();
    if (!(sts & 1)) goto wrapup;

    // do it
    strcpy(username,user->username);
    *userid = user->user_id;

    // check
    if (*username == 0) goto wrapup;

    // done
    retFlag = 1;

wrapup:
    return retFlag;
}

/* ------------------------------------------------------------------------
 * Returns the path of the pdm expression, if in this routine,
 * then we are looking for a refname with a 1, 2, or etc... added
 * to it, which is similar to the filename of the osnum passed as an
 * argument.  For example:
 *    osnum ==> refname.a, refname.a was not found, so look for refname.a1
 */
static IGRstat getPdmInfoPathx(VDosnum osnum, IGRchar *path, TGRid *expID)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  IGRchar name[1024];
  IGRchar activeName[1024];
  IGRchar listPath[1024];
  IGRchar **listNames;
  IGRint  numList = 0;
  IGRint  i;
  IGRchar *p;
  IGRchar buf[1024];
  
  VDosnum activeOS;
  
  // Arg check
  if (path == NULL) goto wrapup;
  *path = 0;

  // get some file names
  ex$get_cur_mod(osnum = &activeOS);
  if (osnum == OM_K_NOT_AN_OS) goto wrapup;
  
  // of os sent
  VDosGetFileName(osnum,name);
  if (*name == 0) goto wrapup;

  // of activeOS
  *activeName = 0;
  VDosGetFileName(activeOS,activeName);
  if (*activeName == 0) goto wrapup;
  
  // No need to deal with transient spaces, assume active space is lowest
  if (osnum <= activeOS) {
      // should not actually reach here, but just in case
      sprintf(path,":%s:IGENOD:pdm_info",name);
      retFlag = 1;
      goto wrapup;
  }

  // Build off of the active
  sprintf(listPath,":%s:ref:*",activeName);

  // list this directory to find
  sts = di$ls( regexp = listPath,
	       lines  = &listNames,
	       ptr    = &numList );

  // check them
  for (i = 0; i < numList; i++)
  {
      strcpy(buf,listNames[i]);
      p = strrchr(buf,':');
      if (p) {
	  //p = p - 1;
	  *p = 0;
	  //strcpy(buf,p);
	  p = strrchr(buf,':');
	  if (p) {
	      p++;
	      strcpy(buf,p);
	  }
	  else *buf = 0;
      }
      if (*buf == 0) goto wrapup;

      if (!(strncmp(buf,name,strlen(name)))) {
	  sprintf(path,":%s:ref:%s:IGENOD:pdm_info",activeName,buf);

	  // is it the one
	  expID->osnum = osnum;
	  expID->objid = NULL_OBJID;
	  sts = di$translate(objname = path,
	                     p_objid = &expID->objid);
	  if (sts & 1) {
	      retFlag = 1;
	      goto wrapup;
	  }
      }
	  
  }

  // done, none found
  
wrapup:
  return retFlag;
}


/* ------------------------------------------------------------------------
 * Returns the path of the pdm expression
 */
static IGRstat VDpdmGetPdmInfoPath(VDosnum osnum, IGRchar *path)
{
  IGRstat retFlag = 0;
  IGRchar name[1024];
  IGRchar activeName[1024];
  
  VDosnum activeOS;
  
  // Arg check
  if (path == NULL) goto wrapup;
  *path = 0;

  // Default to active space
  ex$get_cur_mod(osnum = &activeOS);
  if (osnum == OM_K_NOT_AN_OS) osnum = activeOS;
  VDosGetFileName(osnum,name);
  if (*name == 0) goto wrapup;

  // No need to deal with transient spaces, assume active space is lowest
  if (osnum <= activeOS) {
    sprintf(path,":%s:IGENOD:pdm_info",name);
    retFlag = 1;
    goto wrapup;
  }
  // Build off of the active
  VDosGetFileName(activeOS,activeName);

  sprintf(path,":%s:ref:%s:IGENOD:pdm_info",activeName,name);
  //printf("Path '%s'\n",path);
  
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* ------------------------------------------------------------------------
 * Get the pdm info expression if it exists
 */
IGRstat VDpdmGetPdmInfoExp(VDosnum  a_osnum, 
			   TGRid   *a_expID,
			   IGRchar *a_expPath,
			   IGRchar *a_expText)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  
  TGRid   expID;
  IGRchar path[128];
  
  // Arg check
  if (a_expID) a_expID->objid = NULL_OBJID;
  if (a_expText) *a_expText = 0;
  if (a_expPath) *a_expPath = 0;
  
  // Get the path
  if (a_osnum == OM_K_NOT_AN_OS) ex$get_cur_mod(osnum = &a_osnum);
  VDpdmGetPdmInfoPath(a_osnum,path);
  if (*path == 0) goto wrapup;
  if (a_expPath) strcpy(a_expPath,path);
  
  // Get the expression
  expID.osnum = a_osnum;
  expID.objid = NULL_OBJID;
  sts = di$translate(objname = path,
		     p_objid = &expID.objid);
  
  /* Changed for TR 6059 */
  //if (!(sts & 1)) goto wrapup;
  //if (expID.objid == NULL_OBJID) goto wrapup;
  if ( (!(sts & 1)) || (expID.objid == NULL_OBJID) )
  {
      // try to get from the list of reference file in the directory system
      *path = 0;
      sts = getPdmInfoPathx(a_osnum,path,&expID);
      if (*path == 0) goto wrapup;
      if (expID.objid == NULL_OBJID) goto wrapup;
      if (a_expPath) strcpy(a_expPath,path);

      
      
  }
  /* end of TR 6059 */
  
  if (a_expID) *a_expID = expID;
  
  // Get the text
  if (a_expText) {  
    vdexp$Get(objID = &expID, txt = a_expText);
    if (*a_expText == 0) goto wrapup;
  }
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* ------------------------------------------------------------------------
 * Verifies logged into pdm
 */
IGRstat VDpdmVerifyLogin()
{
  IGRstat retFlag = 0;
  IGRstat sts;

  sts = VDSverify_login();
  if (sts & 1) retFlag = 1;
  
  return retFlag;
}

/* ------------------------------------------------------------------------
 * Creates, validates or updates the pdm info expression
 * Designed to be called during file retrieval to ensure
 * the expression is up to date
 */
IGRstat VDpdmUpdatePdmInfo(VDosnum osnum)
{
  IGRstat retFlag = 1;
  IGRstat sts;

  IGRchar expPath[128];
  IGRchar expText[128];
  TGRid   expID;
  
  IGRchar fileName[256];
  
  TVDpdmInfo pdmInfo;
  IGRchar    pdmText[128];
  VDosnum    cur_os;
  
  IGRchar    msg[80];
  
  // Say hi
  //printf(">>> VDpdmUpdatePdmInfo\n");
  strcpy(msg,"Updating PDM Information");
  UI_status(msg);

  // Init
  expID.objid = NULL_OBJID;
  
  // Need to be logged into pdm
  sts = VDpdmVerifyLogin();
  if (!(sts & 1)) {
     //printf("Not logged in\n");
    goto wrapup;
  }
  
  // get the current os
  ex$get_cur_mod(osnum = &cur_os);
  
  // Get the pdm info expression
  if (osnum == OM_K_NOT_AN_OS) osnum = cur_os;
  VDpdmGetPdmInfoExp(osnum, &expID, expPath, expText);
#if 0
  if (*expText) printf("Expression '%s'\n",expText);
#endif  
  // Get the actual data
  memset(&pdmInfo,0,sizeof(pdmInfo));
  
  VDosGetFileName(osnum,pdmInfo.filename);
  if (*pdmInfo.filename == 0) goto wrapup;
  
  PDMGetPartInfoGivenFileName(pdmInfo.filename,pdmInfo.catalog,pdmInfo.part,pdmInfo.rev);
  if (*pdmInfo.catalog == 0) {

    // If we have an expression then get catalog/part.rev from it
    // This is a hack just to get the expressions to update
    if (*expText == 0) goto wrapup;
    VDpdmGetPdmInfo(osnum,&pdmInfo);

#if 0
    printf("%s %s %s %s %d\n",
	  pdmInfo.catalog,pdmInfo.part,pdmInfo.rev,pdmInfo.filename,pdmInfo.filekey);
#endif
	   
    // Just to be really sure
    if (*pdmInfo.catalog == 0) goto wrapup;
  }
  
  VDpdmGetFileKeyForCPR(pdmInfo.catalog,pdmInfo.part,pdmInfo.rev,&pdmInfo.filekey);
  if (pdmInfo.filekey == 0) goto wrapup;

  // Build the text string
  sprintf(pdmText,"%s|%s|%s|%s|%d",
	  pdmInfo.catalog,pdmInfo.part,pdmInfo.rev,pdmInfo.filename,pdmInfo.filekey);

  // If the expression does not exist, create it
  if (expID.objid == NULL_OBJID) {

    vdexp$CreateTextExp(osnum = osnum,
			name  = expPath,
			text  = pdmText,
			objID = &expID);

    //vdobj$Print(objID = &expID);
    retFlag = 1;
    goto wrapup;
  }
  // If the expression exists then see if it's valid
  if (!strcmp(expText,pdmText)) {
    //printf("Expression is ok\n");
    retFlag = 1;
    goto wrapup;
  }
  
  // Update it
  vdexp$ModifyTextExp(objID = &expID, text = pdmText);
  
  // printf("Updated pdmText %s\n",pdmText);
  
  // Done

wrapup:
  //if ( (osnum == cur_os) && (expID.objid != NULL_OBJID) ) VDpdmCheckApprCfgForRefFiles();
  //if ( expID.objid != NULL_OBJID ) VDpdmUpdatePurposeInfo( osnum );
  return retFlag;
}

/* -----------------------------------------------
 * Standard interface for getting pdm info
 */
IGRstat VDpdmGetPdmInfo(VDosnum osnum, TVDpdmInfo *pdmInfo)
{
  IGRstat retFlag = 0;
  IGRchar expPath[256],expText[256];
  TGRid   expID;
  IGRchar *p;
  
  // Arg check
  if (pdmInfo == NULL) goto wrapup;
  memset(pdmInfo,0,sizeof(TVDpdmInfo));
  
  // Default to active
  if (osnum == OM_K_NOT_AN_OS) ex$get_cur_mod(osnum = &osnum);
  VDpdmGetPdmInfoExp(osnum,&expID,expPath,expText);
  
  if (*expText == 0) {
#if 0   
    // Update and try again
    VDpdmUpdatePdmInfo(osnum);
    VDpdmGetPdmInfoExp(osnum,&expID,expPath,expText);
#endif
    goto wrapup;
  }
  if (*expPath == 0) {
      goto wrapup;
  }

  // Parse out
  p = strchr(expText,'|');
  if (p) {
    *p = 0;
    strcpy(pdmInfo->catalog,expText);
    strcpy(expText,p+1);
  }
  p = strchr(expText,'|');
  if (p) {
    *p = 0;
    strcpy(pdmInfo->part,expText);
    strcpy(expText,p+1);
  }
  p = strchr(expText,'|');
  if (p) {
    *p = 0;
    strcpy(pdmInfo->rev,expText);
    strcpy(expText,p+1);
  }
  else {
    // Old style without file name or key
    strcpy(pdmInfo->rev,expText);
    VDosGetFileName(osnum,pdmInfo->filename);
  }
  p = strchr(expText,'|');
  if (p) {
    *p = 0;
    strcpy(pdmInfo->filename,expText);
    strcpy(expText,p+1);
  }
  pdmInfo->filekey = atoi(expText);

#if 0  
  // Always want filekey from current database (if logged in)
  if (VDpdmVerifyLogin()) {  

    /* --------------------------------------------------
     * ah - I really don't think we need this
     * The key is validated when the file is started
     * So the expression should always be correct
     * By the time some calls this function
     */
    VDpdmGetFileKeyForCPR(pdmInfo->catalog,pdmInfo->part,
			  pdmInfo->rev,&pdmInfo->filekey);
  }  
  if (pdmInfo->filekey == 0) goto wrapup;
#endif
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}


end implementation Root;






