/* $Id: VDsys.c,v 1.2 2001/02/22 22:51:30 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdah/c/VDsys.c
 *
 * Description: Some Misc System Routines
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDsys.c,v $
 *      Revision 1.2  2001/02/22 22:51:30  ahundiak
 *      *** empty log message ***
 *
 *      Revision 1.1  2001/02/17 13:58:14  ahundiak
 *      *** empty log message ***
 *
 *      Revision 1.1  2001/02/08 15:19:10  ahundiak
 *      *** empty log message ***
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 02/02/01  ah      creation
 ***************************************************************************/
#include "VDtypedefc.h"
#include "VDassert.h"
#include "VDsys.h"

#include "time.h"

VDASSERT_FFN("vdah/c/VDsys.c");

/* -----------------------------------------------
 * Generate a time stamp
 */
void VDsysGetTimeStamp(IGRchar *ts)
{
  VDASSERT_FN("ctxComputeDate");
  IGRstat sts;

  IGRchar buf[128];
  
  time_t current_time;
  struct tm *tm;

  // Arg check
  VDASSERTW(ts); *ts = 0;
  
  // Date time stamp
  time(&current_time);
  tm = localtime(&current_time);
  sprintf(buf,
	  "%4d-%02d-%02d %02d:%02d:%02d",
	  tm->tm_year+1900,tm->tm_mon+1,tm->tm_mday,
	  tm->tm_hour,tm->tm_min,tm->tm_sec);

  // Update
  strcpy(ts,buf);
  
wrapup:
  return;
}

/* -----------------------------------------------
 * Find the full path to an executable file
 */
IGRstat VDsysFindExeFile(IGRchar *file_name, IGRchar *file_path)
{
  VDASSERT_FN("VDsysFindExeFile");

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
IGRstat VDsysCompressOrUncompressFile(IGRint option, IGRchar *file_name)
{
  VDASSERT_FN("VDsysCompressOrUncompressFile");
  
  IGRstat retFlag = 0;
  
  IGRchar cmd_file[ 32];
  IGRchar cmd_path[256];
  IGRchar cmd[256];
  
  // Arg check
  VDASSERTW(file_name && *file_name);
  
  // Compress or uncompress
  switch(option){
    case VDSYS_OPTION_COMPRESS:   strcpy(cmd_file,"gzip");   break;
    case VDSYS_OPTION_UNCOMPRESS: strcpy(cmd_file,"gunzip"); break;
    default: VDASSERTW(0);
  }
  
  // Find the executable
  VDsysFindExeFile(cmd_file,cmd_path);
  VDASSERTW(*cmd_path);
  
  // Do it, f to force, q to suppress warnings
  sprintf(cmd,"%s -q -f %s 2> /dev/null",cmd_path,file_name);
  system (cmd);

  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

IGRstat VDsysCompressFile(IGRchar *file_name)
{
  return VDsysCompressOrUncompressFile(VDSYS_OPTION_COMPRESS,file_name);
}
IGRstat VDsysUncompressFile(IGRchar *file_name)
{
  return VDsysCompressOrUncompressFile(VDSYS_OPTION_UNCOMPRESS,file_name);
}

/* -----------------------------------------------
 * Copy File Interface
 */
IGRstat VDsysCopyFile(IGRchar *srcName, IGRchar *desName)
{
  VDASSERT_FN("VDsysCopyFile");

  IGRstat retFlag = 0;
  
  IGRchar cmd[2048];

  // Arg check
  VDASSERTW(srcName && *srcName);
  VDASSERTW(desName && *desName);
  
  // Just use the system
  sprintf(cmd,"/bin/cp %s %s 2> /dev/null",srcName,desName);
  system (cmd);

  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Change file mode interface
 */
IGRstat VDsysChmod(IGRchar *mode, IGRchar *path)
{
  VDASSERT_FN("VDsysChmod");

  IGRstat retFlag = 0;
  
  IGRchar cmd[2048];

  // Arg check
  VDASSERTW(mode && *mode);
  VDASSERTW(path && *path);
  
  // Just use the system
  sprintf(cmd,"/bin/chmod %s %s 2> /dev/null",mode,path);
  system (cmd);

  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Make a directory
 */
IGRstat VDsysMkdir(IGRchar *path)
{
  VDASSERT_FN("VDsysMkdir");

  IGRstat retFlag = 0;
  
  IGRchar cmd[2048];

  // Arg check
  VDASSERTW(path && *path);
  
  // Just use the system
  sprintf(cmd,"/bin/mkdir -p %s 2> /dev/null",path);
  system (cmd);

  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Delete a file
 */
IGRstat VDsysDeleteFile(IGRchar *path)
{
  VDASSERT_FN("VDsysDeleteFile");

  IGRstat retFlag = 0;
  
  IGRchar cmd[2048];

  // Arg check
  VDASSERTW(path && *path);
  
  // Just use the system
  sprintf(cmd,"/bin/rm %s 2> /dev/null",path);
  system (cmd);

  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Returns the file extension of a compressed file
 */
void VDsysGetCompressedFileExt(IGRchar *ext)
{
  VDASSERT_FN("VDsysGetCompressedFileExt");

  VDASSERTW(ext);

  strcpy(ext,"gz");
  
 wrapup:
  return;
}
