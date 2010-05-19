/* $Id: VDatImp.c,v 1.2 2001/02/11 17:44:08 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdat/post/VDatImp.I
 *
 * Description: Some Misc Routines, Move to imp after service pack
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDatImp.c,v $
 *      Revision 1.2  2001/02/11 17:44:08  ahundiak
 *      Renamed VDris2 to VDrisc
 *
 *      Revision 1.1  2001/01/11 21:06:42  art
 *      sp merge
 *
 * Revision 1.2  2000/12/15  20:02:26  pinnacle
 * ah
 *
 * Revision 1.1  2000/10/15  13:51:40  pinnacle
 * ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 09/26/00  ah      creation
 ***************************************************************************/
#include "VDtypedefc.h"
#include "VDxml.h"
#include "VDrisc.h"
#include "VDat.h"
#include "VDassert.h"

VDASSERT_FFN("vdat/post/VDatImp.c");

/* -----------------------------------------------
 * Find the full path to an executable file
 */
IGRstat VDatFindExeFile(IGRchar *file_name, IGRchar *file_path)
{
  VDASSERT_FN("VDatFindExeFile");

  IGRstat retFlag = 0;

  IGRchar buf [4096];
  IGRchar path[1024];
  IGRchar *p;
  IGRint  i;
  
  FILE *file;
  
  // Arg check
  VDASSERTW(file_path);
  *file_path = 0;
  VDASSERTW(file_name && *file_name);

  // Get the system path
  p = getenv("PATH");
  if (p) strcpy(buf,p);
  else  *buf = 0;
  
  // Try each one
  while(*buf) {
    
    p = strchr(buf,':');
    if (p) *p = 0;
    
    sprintf(path,"%s/%s",buf,file_name);
    file = fopen(path,"rb");
    if (file) {
      fclose(file);
      strcpy(file_path,path);
      retFlag = 1;
      goto wrapup;
    }
    
    if (p) strcpy(buf,p+1);
    else *buf = 0;
  }
  
  // Cycle through -S options
  for(i = 0; EX_getpath(i,buf,sizeof(buf),0); i++) {
    sprintf(path,"%sbin/%s",buf,file_name);
    file = fopen(path,"rb");
    if (file) {
      fclose(file);
      strcpy(file_path,path);
      retFlag = 1;
      goto wrapup;
    }
  }
  
  // Done
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Compress or uncompress File
 * 1 = Compress
 * 2 = Un compress
 */
IGRstat VDatCompressFile(IGRint option, IGRchar *file_name)
{
  VDASSERT_FN("VDatCompressFile");
  
  IGRstat retFlag = 0;
  
  IGRchar cmd_file[ 32];
  IGRchar cmd_path[256];
  IGRchar cmd[256];
  
  // Arg check
  VDASSERTW(file_name && *file_name);
  
  // Compress or uncompress
  switch(option){
    case 1: strcpy(cmd_file,"gzip");   break;
    case 2: strcpy(cmd_file,"gunzip"); break;
    default: VDASSERTW(0);
  }
  
  // Find the executable
  VDatFindExeFile(cmd_file,cmd_path);
  VDASSERTW(*cmd_path);
  
  // Do it, f to force, q to suppress warnings
  sprintf(cmd,"%s -q -f %s 2> /dev/null",cmd_path,file_name);
  system (cmd);

  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Quick and dirty file compare
 * result = 0 - Error
 * result = 1 - They match
 * result = 3 - Difference found
 */
IGRstat VDatCompareFiles(IGRchar *file_name1, IGRchar *file_name2, IGRint *results)
{
  VDASSERT_FN("VDatCompareFiles");
  
  IGRstat retFlag = 0;
  FILE  *file1 = NULL;
  FILE  *file2 = NULL;
  IGRint data1, data2;
  IGRint flag;
  
  VDASSERTW(results);
  *results = 0;
  VDASSERTW(file_name1);
  VDASSERTW(file_name2);

  file1 = fopen(file_name1,"rb");
  VDASSERTW(file1);
  file2 = fopen(file_name2,"rb");
  VDASSERTW(file2);
  
  flag = 1;
  while(flag) {
    
    data1 = fgetc(file1);
    data2 = fgetc(file2);

    if (data1 != data2) {
      *results = 3;
      retFlag = 1;
      goto wrapup;
    }
    if (data1 == EOF) flag = 0;    
  }
  
  // Done
  *results = 1;
  retFlag = 1;
  
 wrapup:
  if (file1) fclose(file1);
  if (file2) fclose(file2);
  return retFlag;
}

/* -----------------------------------------------
 * Search through all os's to find a set of a given type
 * Return the name of the first set found
 * If more than one such set exists, then don't return a name
 */
IGRstat VDatGetSetNameForType(IGRchar *setType, IGRchar *setName)
{
  IGRstat retFlag = 0;
  VDosnum osnum;
  
  TGRid mgrID,setsID,setID;
 
  IGRint i;
  
  IGRchar setTypex[64];
  IGRchar setNamex[64];
  
  IGRint cnt = 0;
  
  // Arg check
  if (setName == NULL) goto wrapup; *setName = 0;
  if (setType == NULL) goto wrapup;

  // Cycle through each os
  for(osnum = 0; VDosValidate(osnum); osnum++) {

    VDatGetSetMgr(osnum,&mgrID);

    if (mgrID.objid != NULL_OBJID) {

      VDatGetSets(&mgrID,&setsID);

      if (setsID.objid != NULL_OBJID) {

	// Cycle through
	for(i = 0; VDatGetChildObject(&setsID,i,&setID); i++) {

	  VDatRDBGetSetType(&setID,setTypex);    
	  if (!strcmp(setType,setTypex)) {

	    VDatGetBaseName(&setID,setNamex);
	    cnt++;
	    
	  } // settyupe == setTypex
	}  // Test setID
      }  // If setsID
    } // If mgrID
  } // Each OS
  
  // One and only one
  if (cnt != 1) goto wrapup;
  
  // Done
  strcpy(setName,setNamex);
  retFlag = 1;
  
wrapup:
  return retFlag;
}

