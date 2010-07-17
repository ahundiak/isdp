/* $Id: VLsmsLog.c,v 1.2 2002/04/24 15:12:51 ahundiak Exp $  */

/***************************************************************************
 * I/LOFT
 *
 * File:        vlext/VLextMark.I
 *
 * Description: Low level attribute extraction
 *              Used to be in VLsmsExt.u
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VLsmsLog.c,v $
 *      Revision 1.2  2002/04/24 15:12:51  ahundiak
 *      ah
 *
 *      Revision 1.1  2001/09/14 13:42:56  ahundiak
 *      ah
 *
 *      Revision 1.1  2001/01/18 17:55:32  art
 *      ah
 *
# Revision 1.1  2000/11/27  20:25:38  pinnacle
# ah
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 11/15/00  ah      Creation
 *
 ***************************************************************************/

#include "VDtypedefc.h"
#include "VLsmsLog.h"
#include "VDassert.h"
#include "VDobj2.h"

#include "stdarg.h"

VDASSERT_FFN("src/vlsms/VLsmsLog.c");

/* -----------------------------------------------
 * Try keeping the file stuff local
 * Just to prevent having to carry around file stuff
 */
static FILE *s_file0;
static FILE *s_file1;
static FILE *s_file2;
static FILE *s_file3;
static FILE *s_file4;

/* -----------------------------------------------
 * Return file pointer for whomever wants it
 */
FILE *VLsmsGetLogFile(IGRint nth)
{
  FILE *file = NULL;
  
  switch(nth) {
  case 0: file = s_file0; break;
  case 1: file = s_file1; break;
  case 2: file = s_file2; break;
  case 3: file = s_file3; break;
  case 4: file = s_file4; break;
  }
  if (file == NULL) file = stdout;
  
  return file;
}

/* -----------------------------------------------
 * Set a log file pointer
 */
IGRstat VLsmsSetLogFile(IGRint nth, FILE *file)
{ 
  switch(nth) {
  case 0: s_file0 = file; break;
  case 1: s_file1 = file; break;
  case 2: s_file2 = file; break;
  case 3: s_file3 = file; break;
  case 4: s_file4 = file; break;
  }
  
  return 1;
}

/* -----------------------------------------------
 * Print an object description
 */
IGRstat VLsmsLog2(IGRint     type, 
		  IGRint     stdOut, 
		  IGRchar    *pre, 
		  TGRobj_env *objOE, 
		  TGRid      *objID)
{
  IGRstat retFlag = 1;
  IGRstat msg;
  
  TGRid theID;

  IGRchar buf[256];
  IGRchar path[128];
  IGRchar *p;
  IGRchar className[32];
  IGRchar   macName[32];
  
  // Pull out the object
  theID.objid = NULL_OBJID;
  if (objOE) theID =  objOE->obj_id;
  if (objID) theID = *objID;
  if (theID.objid == NULL_OBJID) {
    strcpy(buf,"NULL OBJECT");
    goto doit;
  }
  
  // Get some info
  *path = 0;
  VDobjGetClassName(NULL,&theID,className);
  VDobjGetMacroName(NULL,&theID,  macName);
  VDobjGetPath     (NULL,&theID,     path);
  
  // Start putting together
  sprintf(buf,"%d,%d %s",theID.osnum,theID.objid,className);
	    
  // Add macro name
  if ((*macName) && (strcmp(className,macName))) {
    strcat(buf," ");
    strcat(buf,macName);
  }
  
  // Strip ref from the path
  p = strstr(path,":ref:");
  if (p) p += 4;
  else   p = path;
  if (*p) {
    strcat(buf," ");
    strcat(buf,p);
  }
  
  // Do It
doit:
  if (pre) VLsmsLog1(type,stdOut,"%s %s\n",pre,buf);
  else     VLsmsLog1(type,stdOut,"%s\n",buf);
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * General purpose logger
 */
IGRstat VLsmsLog1(IGRint type, IGRint stdOut, IGRchar *fmt, ...)
{
  IGRstat retFlag = 0;
   
  IGRchar buf[256];

  FILE *file0;
  
  va_list ap;
  
  // Buf the message
  va_start(ap, fmt);
  vsprintf(buf,fmt, ap);  
  va_end(ap);

  // Get the files
  file0 = VLsmsGetLogFile(0);

  // Write it out
  fputs(buf,file0);

  // Dump to back screen
  if (stdOut && (file0 != stdout)) fputs(buf,stdout);
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Initialize Log System
 */
IGRstat VLsmsInitLogFiles()
{
  IGRstat retFlag = 0;

  FILE *file;
  
  // Keep it simple for now
  file = fopen("extract.log","wt");
  if (file == NULL) {
    UI_status("Could not open spades.log");
    goto wrapup;
  }
  VLsmsSetLogFile(0,file);
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Close all open log files
 */
IGRstat VLsmsCloseLogFiles()
{
  IGRstat retFlag = 0;
  
  IGRint i;
  FILE *file;
  
  // Cycle through
  for(i = 0; i < 5; i++) {
    file = VLsmsGetLogFile(i);
    if (file == stdout) file = NULL;
    if (file) {
      fflush(file);
      fclose(file);
    }
    VLsmsSetLogFile(i,NULL);
  }
  
  // Done
  retFlag = 1;
  
wrapup:
  
  return retFlag;
}




