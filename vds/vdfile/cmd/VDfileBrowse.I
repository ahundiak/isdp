/* $Id: VDfileBrowse.I,v 1.8 2002/04/26 16:58:37 ylong Exp $  */


/***************************************************************************
 * I/VDS
 *
 * File:        vdct1/tools/VDfileBrowse.I
 *
 * Description: generic file browser tool form management tools
 *              drives file VDgfile.frm
 *              returns data from the form via structure
 *              TVDfileInfo
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 04/16/01  pn      Creation
 ***************************************************************************/

// Generic node operations routines

class implementation Root;
#include "VDtypedef.h"
#include "VDmem.h"
#include "VDassert.h"
#include "VDfrm.h"
#include <sys/stat.h>
#include "ci.h"
#include <dirent.h>
#include "VDppl1.h"
#include "vdtvwtools.h"
#include "vdtr_macros.h"
#include "VDfile.h"

FILE   *VDtrCmdSetOpenListOfSets();
#define WC_CMD   "wild_cards"
#define F_CMD    "file_path"
#define LOC_FILE ".File_Path"
#define LOC_PATH ""
#define SYS_FILE "FilePath"
#define SYS_PATH "config/sets"

VDASSERT_FFN("vds/vdfile/VDfileBrowse.I");

IGRint VDfileGetFormData(IGRchar *dir,
			  IGRchar *name, 
			  IGRchar *type,
			  IGRchar *path,
			  IGRint  *flag,
			  IGRint  *done);

IGRint VDfileSetFormData(IGRchar *dir,
			  IGRchar *name,
			  IGRchar *type,
			  IGRchar *path,
			  IGRint *flag);

IGRint VDfileSetInitFormData(IGRchar *dir, 
			      IGRchar *name,
			      IGRchar *type,
			      IGRint  *flag);

IGRint VDfileInitForm(char *form);

IGRint VDfileDeleteForm(char *form);

IGRint VDfileSleepForm(char *form);

IGRint VDfileWakeForm(char *form);

IGRint VDfileStoreForm(char *form);

IGRint VDfileAddFileType(char   *form, 
			  IGRint  gadget, 
			  IGRchar *ftype);

IGRint VDfileUpdateFileType(char  *form, 
			     IGRint gadget);

IGRint VDfileGetDirInfo(IGRchar   *dir_name,
			 IGRchar ***dirList,
			 IGRchar ***fileList, 
			 IGRint    *dirCnt, 
			 IGRint    *fileCnt,
			 IGRint    *typeFlag);

IGRint VDfileDisplayDirPaths(char    *form, 
			      IGRint   gadget,
			      IGRchar *dirPath,
			      IGRint  *dispFlag);

IGRint VDfileDisplayFiles(char    *form, 
			   IGRint   gadget,
			   IGRint   source,
			   IGRchar *filePath,
			   IGRint  *fileFlag);

IGRint VDfileRetieveDirPath(char    *form,
			     IGRint   gadget,
			     IGRchar *dirPath);

IGRint VDfileCountOffset(IGRchar *dirPath);

IGRint VDfileDisplayPath(char   *form,
			  IGRint  gadget, 
			  IGRint  source);

IGRint VDfileClipFrontSpaces(IGRchar *buffer);

IGRint VDfileDisplayFile(char    *form,
			  IGRint   gadget, 
			  IGRint   source);

IGRint VDfileFilterNames(IGRchar   *filter,
			  IGRchar  **inList,
			  IGRchar ***outList,
			  IGRint    *inCnt,
			  IGRint    *outCnt);

IGRint VDfileGetFilters(IGRchar   *filter,
			  IGRchar ***filterList,
			  IGRint    *filterCnt);

IGRint VDfileGetFilterSplit(IGRchar *filter,
			     IGRchar *frontFilter,
			     IGRchar *backFilter);

IGRint VDfileIsFilterMatch(IGRchar *filter,
			    IGRchar *name);

IGRint VDfileIsPath(IGRchar *path);

IGRint VDfileLimitTypeSel(IGRchar  *fileSel, 
			   IGRint    flag);

IGRint VDfileSetDir(IGRchar *dir);

IGRint VDfileNotifyForm(char   *form,
			IGRint  gadget);

IGRint VDfileSplitPath(IGRchar *path,
		       IGRchar *dir,
		       IGRchar *file);

IGRint VDfileGetLocalPath(IGRchar *path, 
			  IGRchar *dir, 
			  IGRchar *file);

IGRstat VDfileUpdatePathFromFileList(char *form);

IGRstat VDfileSavePathToLocalFile(char    *form,
				  IGRchar *cmdType,
				  IGRchar *localFile,
				  IGRchar *localPPath);

IGRstat VDfileGetPathsFromFiles(char    *form,
				IGRint   gadget,
				IGRchar *cmdType,
				IGRchar *localFile,
				IGRchar *localPPath,
				IGRchar *serverFile,
				IGRchar *serverPPath);

IGRstat VDfileGetListCommands(IGRchar   *command,
			      IGRchar ***strList,
			      IGRint    *strListCnt,
			      IGRchar ***cmdList,
			      IGRint    *cmdListCnt,
			      IGRint    *cmdFound);

IGRstat VDfileIsStingInList(IGRchar  *item,
			    IGRchar **strList,
			    IGRint    strListCnt);

IGRstat VDfileRemoveItemFromFile(IGRchar *item,
				 IGRchar *command,
				 IGRchar *fileName, 
				 IGRchar *filePPath);

IGRstat VDfileDeleteFileFilter(char    *form,
			       IGRint   gadget,
			       IGRchar *command,
			       IGRchar *localFile,
			       IGRchar *localPPath);

IGRstat VDfileSaveFileFilter(char    *form,
			     IGRint   gadget,
			     IGRchar *command,
			     IGRchar *localFile,
			     IGRchar *localPPath);

IGRstat VDfileShowFileFilter(char    *form,
			     IGRint   gadget,
			     IGRint   mkFile,
			     IGRchar *command,
			     IGRchar *localFile,
			     IGRchar *localPPath);

IGRstat VDfileAddItemToFile(IGRchar *item,
			    IGRchar *command,
			    IGRchar *fileName, 
			    IGRchar *filePPath);

IGRstat VDfileDisplayListItem(char    *form,
			      IGRint   gadget,
			      IGRchar *item,
			      IGRint   flag,
			      IGRchar *msg,
			      IGRint   msgGadget);

IGRstat VDfileCleanItemFromList(char    *form,
				IGRint   gadget,
				IGRchar *item);

%safe 
static IGRint IS_ACCEPTED = 0;
static IGRint FORM_NOTIFICATION = 0;

%endsafe

static char    *form_ptr;
static TVDfileInfo fileInfo;

#define DIRECTORY_BIT	0x4000

typedef	  char	UNIX_NAME[16];

IGRint VDfileSetForm(char *form) 
{
  form_ptr = form;
  return 1;
}

/*****************************************************
 *
 * does the list of stings contain this string?
 *
 *****************************************************/
IGRstat VDfileIsStingInList(IGRchar  *item,
			    IGRchar **strList,
			    IGRint    strListCnt)
{
  VDASSERT_FN("VDfileIsStringInList");
  IGRstat  retFlag = 0;
  IGRint   i;
  
  // say hi
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn); 
  }

  /* some args checks */
  VDASSERTW(item);
  if(strListCnt < 1) goto wrapup;
  VDASSERTW(strList);
  if(!strcmp(item,"")) goto wrapup;
  for(i = 0;i < strListCnt;i++) {
    if(!strcmp(strList[i],item)) {
      retFlag = 1;
      goto wrapup;
    }
  }

wrapup:
  // say bye 
  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}


/*****************************************************
 *
 * Clip out of a file listing only the items 
 * which match to the file command "% <command>"
 *
 *****************************************************/
IGRstat VDfileGetListCommands(IGRchar   *command,
			      IGRchar ***strList,
			      IGRint    *strListCnt,
			      IGRchar ***cmdList,
			      IGRint    *cmdListCnt,
			      IGRint    *cmdFound)
{
  VDASSERT_FN("VDfileGetListCommands");
  IGRstat  retFlag = 0;
  IGRchar  buf[1023];
  IGRint   commandOK = 0;
  IGRchar  *p,*q;
  IGRint   i,j,strLength;

   
  
  // say hi
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn); 
  }

  /* startup */
  *cmdFound = -1;
  VDASSERTW(strList);
  VDASSERTW(command);

  /* no data we go home */
  if(*strListCnt < 1) {
    goto wrapup;
  }

  /* clean up any strange things */
  if(*cmdListCnt > 0) {
    _LOOPFREE( *cmdList,*cmdListCnt );
  }
  *cmdListCnt = 0;

  /* go through the string list and determine if each string is useful etc */
  for(i = 0;i < *strListCnt;i++) {
    p = (*strList)[i];
    if(*p == '%') {
      if(commandOK == 1) {
	retFlag = 1;
	goto wrapup;
      }
      strLength = strlen(p);
      if(strLength > 1) p++;
      strLength = strlen(p);
      buf[0] = '\0';
      for(j = 0;j < strLength;j++) {
	if((!(*p == ' ')) && (!(*p == '\n'))) sprintf(buf,"%s%c",buf,*p);
	p++;
      }
      if(!strcmp(buf,"")) continue;
      if(!strcmp(buf,command)) {
	commandOK = 1;
	*cmdFound = i;
      }
      
    } else if(*p == '#') {
      if(commandOK == 1) {
	strcpy(buf,"");
	strLength = strlen(p);
	if(strLength > 1) p = p + 2;
	strLength = strlen(p);
	for(j = 0;j < strLength;j++) {
	  if(!(*p == '\n')) sprintf(buf,"%s%c",buf,*p);
	  p++;
	}
	if((strlen(buf)) >0) {
	  vdtvw$AddStrListUnique(item    = buf,
				 List    = cmdList,
				 ListCnt = cmdListCnt);
	}
      }
    }
  }
  retFlag = 1;
  
wrapup:
  // say bye 


  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}
/************************************************
 * 
 * Get the current local path and file etc
 * may be pretty useful because it fetches 
 * the Unix path and file that corresponds to
 * the currently active file 
 *
 ************************************************/
IGRint VDfileGetLocalPath(IGRchar *path, 
			  IGRchar *dir, 
			  IGRchar *file)
{
  VDASSERT_FN("VDfileGetLocalPath");
  IGRint  retFlag = 0;
  
  // say hi
  if (traceFlag) {
    printf("**>> %s %s\n",ffn(),fn); 
  }
  
  /* everybody must be present */
  VDASSERTW(path);
  VDASSERTW(dir);
  VDASSERTW(file);
  path[0] = '\0';
  dir[0] = '\0';
  file[0] = '\0';

  /* fetch the local file complete path */
  ex$filename( name = path,
	       len  = 1023);

  /* just be a bit careful */
  if(!strcmp(path,"")) goto wrapup;

  /* cut it up */
  VDfileSplitPath(path,dir,file);
  
  retFlag = 1;
 
wrapup:
  // say bye 


  if (traceFlag) {
    printf("<<** %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}


/*****************************************************
 *
 * Assumptions
 * Splits a path into a dir and a file 
 * Assumptions 
 * [1] There must be a check to see if the first 
 *     character is a '/' already done
 * [2] There must be a fileName in the string that
 *     occurs after the last '/' in the string 
 *     This means that whatever occurs after the last '/'
 *     will be returned as a fileName
 * [3] Whatever is before the last '/' is a directory path
 *    
 * Invalid paths will return a blank dir and a blank file
 *
 *****************************************************/
IGRint VDfileSplitPath(IGRchar *path,IGRchar *dir,IGRchar *file)
{
  VDASSERT_FN("VDfileSplitPath");
  IGRchar  dirPath[1023];
  IGRchar  fileName[24];
  IGRint  retFlag = 0;
  IGRint  strLen = 0;
  IGRint  i;
  IGRchar *p,*p1;
  
  // say hi
  if (traceFlag) {
    printf("**>> %s %s\n",ffn(),fn); 
  }
  
  /* everybody must be present */
  VDASSERTW(path);
  VDASSERTW(dir);
  VDASSERTW(file);
  if(!strcmp(path,"")) goto wrapup;
  
  /* inits */ 
  strcpy(dir,"");
  strcpy(file,"");
  strcpy(dirPath,"");
  strcpy(fileName,"");

  /* does it have the '/' first */
  if(!VDfileIsPath(path))  goto wrapup;
  
  /* set up the string searching */
  p = path;
  strLen = strlen(path);
  
  /* get the location of the last '/' */
  p1 = strrchr(path,'/');
  if(p1 == NULL) goto wrapup;
  
  /* special case of start path */
  if(p == p1) {
    strcpy(dir,"/");
    p1++;
    strcpy(file,p1);
    retFlag = 1;
    goto wrapup;
  }
  
  /* start clipping */
  for(i = 0;i < strLen;i++) {
    if(p == p1) {
      p1++;
      strcpy(file,p1);
      break;
    }
    sprintf(dir,"%s%c",dir,*p);
    p++;
  }
 
  retFlag = 1;
  
wrapup:
  // say bye 


  if (traceFlag) {
    printf("<<** %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}

/*****************************************************
 *
 * Retrieves the data for the user from the form after 
 * it has been accepted and deleted
 * the function return value is the IS_ACCEPTED
 *
 *****************************************************/
IGRint VDfileGetFormData(IGRchar *dir,
			  IGRchar *name, 
			  IGRchar *type,
			  IGRchar *path,
			  IGRint  *flag,
			  IGRint  *done)
{
  VDASSERT_FN("VDfileGetFormData");
  IGRchar  dirPath[1023];
  IGRint   usrFlag;
  IGRint  retFlag = 0;
      
  // say hi
  if (traceFlag) {
    printf("**>> %s %s\n",ffn(),fn); 
  }

  if(dir) strcpy(dir,fileInfo.fdir);
  if(name) strcpy(name,fileInfo.fname);
  if(type) strcpy(type,fileInfo.ftype);
  if(flag) *flag = fileInfo.ftog;
  if(path) {
    strcpy(dirPath,"");
    if((strcmp(fileInfo.fname,"")) && (strcmp(fileInfo.fdir,""))) {
      sprintf(dirPath,"%s/%s",fileInfo.fdir,fileInfo.fname);
      strcpy(path,dirPath);
    } else {
      strcpy(path,"");
    }
    
  }
  if(done) *done = FORM_NOTIFICATION;
  //FORM_NOTIFICATION = 0;
  retFlag = IS_ACCEPTED;
  
wrapup:
  // say bye 


  if (traceFlag) {
    printf("<<** %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}

/*****************************************************
 *
 * Set up the structure data from user input
 * sets fileInfo and defaults if the user
 * sends in blank data
 * This is for the user to reset the form settings 
 * will ignore the dir and name if a path is supplied
 *
 *****************************************************/
IGRint VDfileSetFormData(IGRchar *dir,
			  IGRchar *name,
			  IGRchar *type,
			  IGRchar *path,
			  IGRint *flag)
{
  VDASSERT_FN("VDfileSetFormData");
  IGRchar  dirPath[1023];
  IGRchar  fileType[80];
  IGRchar  fileName[80];
  IGRchar  buf[128];
  IGRchar  *p,*p1;
  IGRint   usrFlag;
  IGRint  retFlag = 0;
  IGRint   row,rows,selFlag,pos,i,strLen;
     
  // say hi
  if (traceFlag) {
    printf("**>> %s %s\n",ffn(),fn); 
  }

  /* 
   * note if any of the data is not sent defaults are used 
   * so set the file defaults first 
   */

  /* 
   * setup the default with all access ok
   * start at root, allow any file, allow any user input
   */
  strcpy(dirPath,"/");
  strcpy(fileName,"");
  strcpy(fileType,"*.*");
  usrFlag = 0;
  buf[0] = '\0';
  
  if(!path) {
    /* if there is a dir */
    if(dir) {
      if(strcmp(dir,"")) strcpy(dirPath,dir);
    }
    /* if there is a name */
    if(name) {
      if(strcmp(name,"")) strcpy(fileName,name);
    }
  } else {
    /* there was a path supplied */
    if(VDfileIsPath(path)) {
      /* this is tested to be a valid path */
      strLen = strlen(path);
      p = path;
      p1 = strrchr(path,'/');
      /* is it only a path */
      if(p == p1) {
	strcpy(dirPath,path);
      } else {
	/* no it does have a name */
	strcpy(dirPath,"");
	for(i = 0;i < strLen;i++) {
	  sprintf(dirPath,"%s%c",dirPath,*p);
	  if(p == p1) {
	    // printf("Testing Path Decomp.. dirPath [%s]\n",dirPath);
	    break;
	  }
	  p++;
	}
	p1++;
	strcpy(fileName,p1);
	//printf("Testing Path Decomp.. fileName [%s]\n",fileName);
      }
    } else {
      /* this is not a valid path */
      /* if there is a dir */
      if(dir) {
	if(strcmp(dir,"")) strcpy(dirPath,dir);
      }
      /* if there is a name */
      if(name) {
	if(strcmp(name,"")) strcpy(fileName,name);
      }
    }
  }
  
  /* if there is a type supplied and it is not blank
   * set the type to the supplied type
   */
  if(type) {
    if(strcmp(type,"")) strcpy(fileType,type);
  }
  
  /* 
   * if there is a flag supplied and it is 1 set 
   * the flag to 1
   */
  
  if(flag) {
    if(*flag == 1) usrFlag = 1;
  }

  /* set the fileInfo data */
  fileInfo.ftog = usrFlag;
  strcpy(fileInfo.fdir,dirPath);
  strcpy(fileInfo.ftype,fileType);
  strcpy(fileInfo.fname,"");
  
 
  /* update the accepted status to 0 */
  IS_ACCEPTED = 0;
  
  retFlag = 1;
  
wrapup:
  // say bye 


  if (traceFlag) {
    printf("<<** %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}


/*****************************************************
 *
 * Set up the structure data from user input
 * sets fileInfo and defaults if the user
 * sends in blank data
 *
 *****************************************************/
IGRint VDfileSetInitFormData(IGRchar *dir,IGRchar *name,IGRchar *type,IGRint *flag)
{
  VDASSERT_FN("VDfileSetInitFormData");
  IGRchar  dirPath[1023];
  IGRchar  fileType[80];
  IGRchar  fileName[80];
  IGRint   usrFlag;
  IGRint  retFlag = 0;
   
  // say hi
  if (traceFlag) {
    printf("**>> %s %s\n",ffn(),fn); 
  }

  /* 
   * note if any of the data is not sent defaults are used 
   * so set the file defaults first 
   */

  /* 
   * setup the default with all access ok
   * start at root, allow any file, allow any user input
   */
  strcpy(dirPath,"/");
  strcpy(fileName,"");
  strcpy(fileType,"*.* *");
  usrFlag = 0;
  
  /* 
   * if there is a path supplied and it is not blank 
   * set the path to the supplied path
   */
  if(dir) {
    if(strcmp(dir,"")) strcpy(dirPath,dir);
  }

  /*
   * if there is a name supplied and it is not blank
   * set the name to the supplied name
   */
  if(name) {
    if(strcmp(name,"")) strcpy(fileName,name);
  }
  
  /* if there is a type supplied and it is not blank
   * set the type to the supplied type
   */
  if(type) {
    if(strcmp(type,"")) strcpy(fileType,type);
  }
  
  /* 
   * if there is a flag supplied and it is 1 set 
   * the flag to 1
   */
  
  if(flag) {
    if(*flag == 1) usrFlag = 1;
  }

  /* set the fileInfo data */
  if(!IS_ACCEPTED) {
    fileInfo.ftog = usrFlag;
    strcpy(fileInfo.fdir,dirPath);
    strcpy(fileInfo.ftype,fileType);
    strcpy(fileInfo.fname,"");
  }
  
  retFlag = 1;
  
wrapup:
  // say bye 


  if (traceFlag) {
    printf("<<** %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}
/*****************************************************
 *
 * Sets form directory to start browse
 *
 *****************************************************/
IGRint VDfileSetDir(IGRchar *dir)
{
  VDASSERT_FN("VDfileSetDir");
  IGRchar  dirPath[1023];
  IGRint  retFlag = 0;
     
  // say hi
  if (traceFlag) {
    printf("**>> %s %s\n",ffn(),fn); 
  }
  /* setup the default */
  if(dir) {
    if(!strcmp(dir,"")) {
      strcpy(dirPath,"/");
    } else {
      strcpy(dirPath,dir);
    } 
  }

  /* display the results */
  VIg_set_text(form_ptr,VDTR_FILE_T_DIR,dirPath);
  
  

  retFlag = 1;
  
wrapup:
  // say bye 


  if (traceFlag) {
    printf("<<** %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}
/*****************************************************
 *
 * Set form file type selection limits
 * flag = 0 allows user input 
 * flag = 1 prohibits user input 
 * this involves  the selection of additional criterion
 * user set filters for file selection.
 *
 *****************************************************/
IGRint VDfileLimitTypeSel(IGRchar *fileSel,IGRint flag)
{
  VDASSERT_FN("VDfileLimitTypeSel");
  IGRint i;
  IGRchar buf[128];
  IGRint  retFlag = 0;
     
  // say hi
  if (traceFlag) {
    printf("**>> %s %s\n",ffn(),fn); 
  }

  /* args check */
  VDASSERTW(fileSel);
  if(flag > 1) flag = 0;
  if(flag < 0) flag = 0;

  /* copy it over */
  strcpy(buf,"*.*");
  if(strcmp(fileSel,"")) strcpy(buf,fileSel);
  /* set up the data */
  FIfld_set_mode(form_ptr,VDTR_FILE_T_TYPE,0,0);
  VDfileAddFileType(form_ptr,VDTR_FILE_T_TYPE,buf);
  /* lock up the selections now */
  FIfld_set_mode(form_ptr, VDTR_FILE_T_TYPE, 0, flag);
  fileInfo.ftog = flag;
  retFlag = 1;
  
wrapup:
  // say bye 


  if (traceFlag) {
    printf("<<** %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}

/*****************************************************
 *
 * check string against filter
 * no memory allocation
 *
 *****************************************************/
IGRint VDfileIsFilterMatch(IGRchar *filter,IGRchar *name)
{
  VDASSERT_FN("VDfileIsFilterMatch");
  IGRint  retFlag = 0;
  IGRchar  *p,*p1,*p2;
  IGRchar  buf[1023],filterClip[1023],nameClip[1023];
  IGRint   i,j;
  IGRint   strLen = 0;
  IGRint   tstLen = 0;
  IGRint   nameLen = 0;
  IGRint   bufLen  = 0;
  IGRint   flag = 0;
     
  // say hi
  if (traceFlag) {
    printf("**>> %s %s\n",ffn(),fn); 
  }

  /* args check */
  VDASSERTW(filter);
  VDASSERTW(name);

  /* init */
  buf[0] = '\0';
  filterClip[0] = '\0';
  nameClip[0] = '\0';  

  /* check the wierd case if it actually is identical all the way */
  if(!strcmp(filter,name)) {
    retFlag = 1;
    goto wrapup;
  }
  
  /* check to see if there is only "*" */
  retFlag = !strcmp(filter,"*");
  if(retFlag == 1) {
    goto wrapup;
  }
  
  
  /* 
   *check for if there are multiple  conditions as the "*" condition is already
   * gone away 
   */
  strLen = strlen(filter);
  p = strrchr(filter,'*');
  if(p != NULL){
    

  }
  /* 
   * we have wildcards somewhere in the filter but more than one character 
   */
  
  /* loop through the filter and check for matches to strings */
  strcpy(filterClip,"");
  strcpy(nameClip,"");
  if(filter) strcpy(filterClip,filter);
  if(name) strcpy(nameClip,name);
  strLen = strlen(filterClip);
  p = filterClip;
  p += strLen -1;
  p1 = nameClip;
  strcpy(buf,"");
  flag = 0;
  for(i = 0;i < strLen;i++) {
    /* check for '*' */
    if(*p == '*') {
      flag = 1;
    } else {
      /* no need to test this pointer as there is nothing to match to */
      if(!strcmp(nameClip,"")) goto wrapup;
      p1 = strrchr(nameClip,*p);
      if(p1 == NULL) goto wrapup;
      nameLen = strlen(nameClip);
      if(flag == 1) {
	flag = 0;
      } else {
	p2 = nameClip;
	p2 += nameLen-1;
	if(!(p1 == p2)) goto wrapup;
      }
      nameLen--;
      strcpy(buf,"");
      p2 = nameClip;
      for(j = 0;j < nameLen;j++) 
      {
	if(p1 == p2) break;
	sprintf(buf,"%s%c",buf,*p2);
	p2++;
      }
      strcpy(nameClip,buf);
    }
    p--;
  }
  nameLen = strlen(nameClip);
  if(nameLen > 0) {
    if(flag == 0) goto wrapup;
  }

  retFlag = 1;
  
wrapup:
  // say bye 


  if (traceFlag) {
    printf("<<** %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}

/*****************************************************
 *
 * split the filters around the '.'
 * no memory allocation 
 *
 *****************************************************/
IGRint VDfileGetFilterSplit(IGRchar *filter,
			     IGRchar *frontFilter,
			     IGRchar *backFilter)
{
  VDASSERT_FN("VDfileGetFilterSplit");
  IGRint  retFlag = 0;
  IGRint   strLen = 0;
  IGRint   i;
  IGRchar  buf[1023];
  IGRchar  *p;
  IGRchar  *p1;
     
  // say hi
  if (traceFlag) {
    printf("**>> %s %s\n",ffn(),fn); 
  }
  
  /* args check */
  VDASSERTW(filter);
  VDASSERTW(frontFilter);
  VDASSERTW(backFilter);
  
  /* inits */
  frontFilter[0] = '\0';
  backFilter[0] = '\0';
  buf[0] = '\0';
  
  /* check the incoming */
  if(filter[0] == '\0') goto wrapup;
  strLen = strlen(filter);
  /* get the frontFilter */
  strcpy(buf,"");
  p1 = strrchr(filter,'.');
  p = filter;
  if(p1 == NULL) {
    /* frontFilter is it */
    strcpy(frontFilter,filter);
    strcpy(backFilter,"");
    retFlag = 1;
    goto wrapup;
  }
  
  if(*p == '.') {
    /* the back filter is it */
    //p++;
    strcpy(backFilter,p);
    strcpy(frontFilter,"");
    retFlag = 1;
    goto wrapup;
  }
  for(i = 0;i < strLen;i++) {
    if(p == p1) {
      break;
    }
    sprintf(buf,"%s%c",buf,*p);
    p++;
  }
  strcpy(frontFilter,buf);
  
  /* get the backFilter */
  p1++;
  strcpy(buf,p1);
  strLen = strlen(buf);
  if(strLen > 0) strcpy(backFilter,buf);
  
  retFlag = 1;
  
wrapup:
  // say bye 
  if (traceFlag) {
    printf("<<** %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}

/*****************************************************
 *
 * Clip the filter list string into a list of individual
 * string clips for filtering
 * MEMORY ALLOCATION (filterList)
 *
 *****************************************************/
IGRint VDfileGetFilters(IGRchar   *filter,
			 IGRchar ***filterList,
			 IGRint    *filterCnt)
{
  VDASSERT_FN("VDfileGetFilters");
  IGRint  retFlag = 0;
  IGRint   strLen = 0;
  IGRint   count = 0;
  IGRint   flag = 0;
  IGRint   i,j;
  IGRchar  buf[128],tmp[128],*p,*p1,*p2;
     
  // say hi
  if (traceFlag) {
    printf("**>> %s %s\n",ffn(),fn); 
  }

  /* args checks */
  VDASSERTW(filter);
  VDASSERTW(filterCnt);

  /* inits */
  *filterCnt = 0;
  buf[0] = '\0';
  tmp[0] = '\0';

  /* make sure we have a string to work with */
  strLen = strlen(filter);
  if(strLen < 1) goto wrapup;

  /* loop through and count up the buffers needed */
  p = filter;
  for(i = 0;i < strLen;i++) {
    if(*p == ' ') {
      flag = 0;
    } else {
      if(flag == 0) {
	flag = 1;
	count++;
      }
    }
    p++;
  }
  
  /* say goodbye if there is nothing to do */
  if(count < 1) goto wrapup;

  /* allocate the memory for the (**) pointers */
  *filterList = _MALLOC( count, IGRchar *  );

  /* reset count */
  count = 0;
  
  /* loop through and fill up the data */
  p = filter;
  for(i = 0;i < strLen;i++) {
    if(*p == ' ') { 
      if(flag & 1) { 
	/* set flag = 0 */ 
	flag = 0;
	/* allocate the memory for the string (***) pointer */
	if( !( (*filterList)[count] = _MALLOC( (sizeof(buf) + 1), IGRchar  )))  {
	  printf("\nERROR: unable to allocate memory for [%s]\n\n",buf);
	  goto wrapup;
	}
	/* send string to list */
	strcpy((*filterList)[count],buf);
	/* increment the string count up one */
	count++;
	/* clear the buf */
	buf[0] = '\0';
      } 
    } else {
      if(flag & 1) {
	/* add on to this string */
	sprintf(buf,"%s%c",buf,*p);
      } else {
	/* set the flag to 1 */ 
	flag = 1;
	/* add to the new string */
	sprintf(buf,"%c",*p);
      }
    }
    p++;
  }  
  strLen = strlen(buf);
  if(strLen > 0) {
    /* allocate the memory for the string (***) pointer */
    if( !( (*filterList)[count] = _MALLOC( (sizeof(buf) + 1), IGRchar  )))  {
      printf("\nERROR: unable to allocate memory for [%s]\n\n",buf);
      goto wrapup;
    }
    /* send string to list */
    strcpy((*filterList)[count],buf);
    count++;
  }
  
  
  
  *filterCnt = count;
  retFlag = 1;
  
wrapup:
  // say bye 
  if (traceFlag) {
    printf("<<** %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}



/*****************************************************
 *
 * Filter the fileNames to match the input filter string
 * this string can be pretty simple or pretty complex
 * the delimit between any filter and its individual filters 
 * is a space.
 * ALLOCATES MEMORY (outList)
 *
 *****************************************************/
IGRint VDfileFilterNames(IGRchar   *filter,
			  IGRchar  **inList,
			  IGRchar ***outList,
			  IGRint    *inCnt,
			  IGRint    *outCnt)
{
  VDASSERT_FN("VDfileFilterNames");
  IGRint  retFlag = 0;
  IGRchar  **filterList;
  IGRchar  buf[1023],buf1[1023],*p,*p1;
  IGRchar  frontFilter[1023],backFilter[1023];
  IGRchar  frontName[1023],backName[1023];
  IGRint   filterCnt = 0;
  IGRint   i,j;
  IGRint   filterFlag = 1;
  IGRint   count = 0;
  IGRint   strLen = 0;
  IGRint   matchOK = 0;
  IGRint   sts1,sts2;
     
  // say hi
  if (traceFlag) {
    printf("**>> %s %s\n",ffn(),fn); 
  }

  /* args checks */
  VDASSERTW(filter);
  VDASSERTW(inCnt);
  VDASSERTW(outCnt);
  if(*inCnt < 1) goto wrapup;
  
  /* inits */
  *outCnt = 0;
  buf[0] = '\0';
  buf1[0] = '\0';
  frontFilter[0] = '\0';
  backFilter[0] = '\0';
  frontName[0] = '\0';
  backName[0] = '\0';
  /* get a list of filters out of the filter */
  VDfileGetFilters(filter,
		   &filterList,
		   &filterCnt);
  
  /* check for the '*.*' and no filter */
  /* this is for handling the special case filters */
  if(filterCnt == 0) {
    filterFlag = 0;
  } else {
    for(i = 0;i < filterCnt;i++) {
      strcpy(buf,filterList[i]);
      if(!strcmp(buf,"*.*")) {
	filterFlag = -1;
	break;
      }
      
      if(!strcmp(buf,"*")) {
	filterFlag = 0;
	break;
      }
    }
  }
  /* 
   * if there is no filter
   */

  if(filterFlag == 0) {
  /* 
    /* allocate the space (**) pointers */
    *outList = _MALLOC( *inCnt, IGRchar *  );
    /* notify of counts */
    *outCnt = *inCnt;
    /* loop through and add the new info */
    for(i = 0;i < *inCnt;i++) {
      /* allocate the memory for the (***) pointer */
      strcpy(buf,inList[i]);
      if( !( (*outList)[i] = _MALLOC( (sizeof(buf) + 1), IGRchar  )))  {
	printf("\nERROR: unable to allocate memory for [%s]\n\n",buf);
	goto wrapup;
      }
      /* copy the stuff across */
     	strcpy((*outList)[i],buf);
    }
  retFlag = 1;
  }

  /* 
   * if there must be an extension 
   */
  if(filterFlag == -1) {
    /* loop through and count up the applicable strings */
    count = 0;
    for(i = 0;i < *inCnt;i++) {
      strcpy(buf,inList[i]);
      p = buf;
      /* filter out anybody with a '.' at the start */
      if(*p == '.') continue;
      /* filter out anybody without a '.' in him */
      p1 = strrchr(buf,'.');
      if((p1 == NULL) || (*p1 == '\0')) continue;
      /* filter out anybody ending in a '.' */
      strcpy(buf1,p1);
      strLen = strlen(buf1);
      if(strLen < 2) continue;     
      count++;
    }
    if(count == 0) goto wrapup;
   
    /* allocate the memory for the outList (**) pointers */
    *outList = _MALLOC( count, IGRchar *  );
    *outCnt = count;
    count = 0;
    /* loop through and copy across the applicable strings */
    for(i = 0;i < *inCnt;i++) {
      strcpy(buf,inList[i]);
      p = buf;
      /* filter out anybody with a '.' at the start */
      if(*p == '.') continue;
      p1 = strrchr(buf,'.');
      /* filter out anybody without a '.' in him */
      if((p1 == NULL) || (*p1 == '\0')) continue;
      /* filter out anybody ending in a '.' */
      strcpy(buf1,p1);
      strLen = strlen(buf1);
      if(strLen < 2) continue;
      /* allocate the memory for the outList (***) pointer */
      if( !( (*outList)[count] = _MALLOC( (sizeof(buf) + 1), IGRchar  )))  {
	printf("\nERROR: unable to allocate memory for [%s]\n\n",buf);
	goto wrapup;
      }
      /* send string to list */
      strcpy((*outList)[count],buf);
      /* increment the string count up one */
      count++;
      /* clean out buf */
      buf[0] = '\0';
    }
  retFlag = 1;
  } 
  
  /* 
   * if there are specialized filters 
   */
  if(filterFlag == 1) {
    /* loop through the items and split them  and count them*/
    count = 0;
    for(i = 0;i < *inCnt;i++) {
      /* split out the string to see if it has any information */
      strcpy(buf,inList[i]);
      matchOK = 0;
      frontName[0] = '\0';
      backName[0] = '\0';
      VDfileGetFilterSplit(buf,
			   frontName,
			   backName);
      /* loop through the filters and split them */
      for(j = 0;j < filterCnt;j++) {
	strcpy(buf1,filterList[j]);
	frontFilter[0] = '\0';
	backFilter[0] = '\0'; 
	VDfileGetFilterSplit(buf1,
			     frontFilter,
			     backFilter);
	/* check to see if the strings match */
	
	sts1 = VDfileIsFilterMatch(frontFilter,frontName);
	sts2 = VDfileIsFilterMatch(backFilter,backName);
	if(sts1 & sts2 & 1) {
	  matchOK = 1;
	  break;
	}
       
      }
      if(matchOK & 1) count++;
    }
 
    /* go home if there is nothing to do */
    if(count < 1) goto wrapup;
    
    /* allocate the memory for the outList (**) pointers */
    *outList = _MALLOC( count, IGRchar *  );
    *outCnt = count;
    count = 0;

    /* loop through the items and send them out*/
    count = 0;
    for(i = 0;i < *inCnt;i++) {
      /* split out the string to see if it has any information */
      strcpy(buf,inList[i]);
      matchOK = 0;
      VDfileGetFilterSplit(buf,
			   frontName,
			   backName);
      /* loop through the filters and split them */
      for(j = 0;j < filterCnt;j++) {
	buf1[0] = '\0';
	sprintf(buf1,"%s",filterList[j]);
	VDfileGetFilterSplit(buf1,
			     frontFilter,
			     backFilter);
	/* check to see if the strings match */
	
	sts1 = VDfileIsFilterMatch(frontFilter,frontName);
	sts2 = VDfileIsFilterMatch(backFilter,backName);
	if(sts1 & sts2 & 1) {
	  matchOK = 1;
	  break;
	}
	
      }
      if(matchOK & 1) {
	/* allocate the memory for the outList (***) pointer */
	if( !( (*outList)[count] = _MALLOC( (sizeof(buf) + 1), IGRchar  )))  {
	  printf("\nERROR: unable to allocate memory for [%s]\n\n",buf);
	  goto wrapup;
	}
	/* send string to list */
	strcpy((*outList)[count],buf);
	/* increment the string count up one */
	count++;
	/* clean out buf */
	buf[0] = '\0';
      }
    }


 
    retFlag = 1;
  }
 

  
wrapup:
  // say bye 
  if( filterCnt ) _LOOPFREE ( filterList,filterCnt );
  if( *inCnt ) _LOOPFREE ( inList,*inCnt );
  if (traceFlag) {
    printf("<<** %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}

/*****************************************************
 *
 * Place the file selected  on the form in the proper place
 *
 *****************************************************/
IGRint VDfileDisplayFile(char *form,IGRint gadget, IGRint source)
{
  VDASSERT_FN("VDfileDisplayFile");
  IGRint  retFlag = 0;
  IGRchar  fileName[1028],*p;
  IGRint   row = 0;
  IGRint   rows = 0;
  IGRint   selFlag = 0;
  IGRint   pos = 0;
     
  // say hi
  if (traceFlag) {
    printf("**>> %s %s\n",ffn(),fn); 
  }
  /* args checks */
  VDASSERTW(form);
  if(gadget < 11) goto wrapup;
  if(source < 11) goto wrapup;

  /* inits */
  fileName[0] = '\0';

  FIfld_get_active_row( form, source, &row, &pos );
  VIfld_get_text(form, source,row,0, 1028, fileName,&selFlag,&pos);

  if(selFlag == 0) fileName[0] = '\0';

  /* display the results */
  VIg_set_text(form,gadget,fileName);
  
  
  retFlag = 1;
  
wrapup:
  // say bye 
  if (traceFlag) {
    printf("<<** %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}

/*****************************************************
 *
 * Clip the blanks on the front of a string
 *
 *****************************************************/
IGRint VDfileClipFrontSpaces(IGRchar *buffer)
{
  VDASSERT_FN("VDfileClipFrontSpaces");
  IGRint  retFlag = 0;
  IGRint   i,strLen = 0;
  IGRchar  *p;
     
  if(!buffer) goto wrapup;

  // say hi
  if (traceFlag) {
    printf("**>> %s %s\n",ffn(),fn); 
  }
    /* args check */
  VDASSERTW(buffer);
  

  /* get the strLen */
  strLen = strlen(buffer);
  
  if(strLen < 1) goto wrapup;
  p = buffer;
  for(i = 0;i < strLen;i++) {
    if(!(*p == ' ')) {
      strcpy(buffer,p);
      break;
    }
    
    p++;
  }
  
  retFlag = 1;
  
wrapup:
  // say bye 


  if (traceFlag) {
    printf("<<** %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}

/*****************************************************
 *
 * Place the dirPath on the form in the proper place
 *
 *
 *****************************************************/
IGRint VDfileDisplayPath(char *form,IGRint gadget, IGRint source)
{
  VDASSERT_FN("VDfileDisplayPath");
  IGRint  retFlag = 0;
  IGRchar  dirPath[1023],*p;

  // say hi
  if (traceFlag) {
    printf("**>> %s %s\n",ffn(),fn); 
  }
  /* args checks */
  VDASSERTW(form);
  if(gadget < 11) goto wrapup;
  if(source < 11) goto wrapup;

  /* inits */
  dirPath[0] = '\0';
  
  /* use the fileInfo.fbrowse switch to control this */
  if(fileInfo.fbrowse == -1) goto wrapup;
  
  /* go get the data */
  VDfileRetieveDirPath(form,source,dirPath);

  /* if there is null data returned from for example a null selection */
  if(dirPath[0] == '\0') {
    retFlag = 1;
    goto wrapup;
  }

  /* display the results */
  VIg_set_text(form,gadget,dirPath);
  
  
  retFlag = 1;
  
wrapup:
  // say bye 
  if (traceFlag) {
    printf("<<** %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}

/*****************************************************
 *
 * count the number of spaces in the front of a string
 * returns -1 if the string is blank.
 * returns -1 if the string is all spaces.
 * returns the count of spaces befor the first non-space
 *
 *****************************************************/
IGRint VDfileCountOffset(IGRchar *dirPath)
{
  VDASSERT_FN("VDfileCountOffset");
  IGRint  retFlag = -1;
  IGRint   strLen = 0;
  IGRint   i;
  IGRchar  *p;
       
  if(!dirPath) goto wrapup;

  // say hi
  if (traceFlag) {
    printf("**>> %s %s\n",ffn(),fn); 
  }

  /* args check */
  VDASSERTW(dirPath);
  if(!strcmp(dirPath,"")) goto wrapup;
  
  strLen = strlen(dirPath);
  p = dirPath;
  for(i = 0;i < strLen;i++) {
    if(!(*p == ' ')) break;
    p++;
    retFlag = i + 1;
  }

  if(retFlag == strLen) retFlag = -1;
  
wrapup:
  // say bye 


  if (traceFlag) {
    printf("<<** %s %s [%d] offset out\n",ffn(),fn,retFlag);
  }
  return retFlag;
}

/*****************************************************
 *
 * Retrieve directory from form (a set of individual offset paths)
 * returns blank if none selected on form.
 *
 *****************************************************/
IGRint VDfileRetieveDirPath(char *form,IGRint gadget,IGRchar *dirPath)
{
  VDASSERT_FN("VDfileRetieveDirPath");
  IGRint  retFlag = 0;
  IGRint   rows = 0;
  IGRint   row = 0;
  IGRint   i;
  IGRint   curOffset = 0;
  IGRint   offset = 0;
  IGRint   selFlag = 0;
  IGRint   pos = 0;
  IGRchar  rowText[1028];
  IGRchar  workingPath[1023],buf[1023],*p;
     
  // say hi
  if (traceFlag) {
    printf("**>> %s %s\n",ffn(),fn); 
  }
  /* inits */
  rowText[0] = '\0';
  workingPath[0] = '\0';
  dirPath[0] = '\0';
  buf[0] = '\0';

  /* get the number of rows */
  VIfld_get_num_rows(form, gadget, &rows);

  /* loop down and find the selected row - get its data */
  selFlag = 0;
  for(row = 0;row < rows;row++) {
    VIfld_get_text(form, gadget,row,0, 1028, rowText,&selFlag,&pos);
    if(selFlag == 1){
      break;
    } else {
      rowText[0] = '\0';
    }
  }

  /* if there is no selection return a null */
  if(selFlag == 0) {
    retFlag = 1;
    dirPath[0] = '\0';
    goto wrapup;
  }

  /* special case  if the row is #0 */
  if(row == 0) {
    strcpy(dirPath,rowText);
    retFlag = 1;
    goto wrapup;
  }

  /* measure the number of spaces in the front of the data */
  curOffset = VDfileCountOffset(rowText);
  VDfileClipFrontSpaces(rowText);
  if(curOffset == -1) {
    /* errors get fixed to main directory */
    strcpy(dirPath,"/");
    retFlag = 1;
    goto wrapup;
  }

  /* store the data to the buffer */
  VDfileClipFrontSpaces(rowText);
  strcpy(workingPath,rowText);

  /* begin looping back up checking the spaces */
  offset = curOffset;
  for(i = (row -1);i > 0;i--){
    VIfld_get_text(form, gadget,i,0, 1028, rowText,&selFlag,&pos);
      curOffset = VDfileCountOffset(rowText);
      VDfileClipFrontSpaces(rowText);
      if(curOffset < offset) {
	/* reset the offset and store the data to the buffer */
	offset = curOffset;
	sprintf(buf,"%s%s",rowText,workingPath);
	strcpy(workingPath,buf);
      }
      
  }
  /* copy the workingPath out */
  strcpy(dirPath,workingPath);
  retFlag = 1;
  
wrapup:
  // say bye 


  if (traceFlag) {
    printf("<<** %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}

/*****************************************************
 *
 * Display files from a given path to the form gadget
 * has filters for selection for display
 *
 *****************************************************/
IGRint VDfileDisplayFiles(char    *form, 
			   IGRint   gadget,
			   IGRint   source,
			   IGRchar *filePath,
			   IGRint  *fileFlag)
{
  VDASSERT_FN("VDfileDisplayFiles");
  IGRint  retFlag = 0, sts;
  IGRchar buf[80],listData[80];
  IGRint  row = 0,
          i = 0,
          flag = 0;
  IGRchar *p;
  IGRchar **dirList;
  IGRchar **fileList;
  IGRchar **filteredFileList;
  IGRchar newLine[128],filter[128];
  IGRint  dirCnt = 0;
  IGRint  fileCnt = 0;
  IGRint  filteredFileCnt = 0;
     
  // say hi
  if (traceFlag) {
    printf("**>> %s %s\n",ffn(),fn); 
  }
  /* inits */
  buf[0] = '\0';
  listData[0] = '\0';
  filter[0] = '\0';

  /* clean up the form */
  VIfld_set_num_rows(form,gadget,0);
 
  /* args checks */
  VDASSERTW(form);
  VDASSERTW(filePath);
  if(gadget < 11) goto wrapup;
  if(source < 11) goto wrapup;
  
  /* validate fileFlag stuff */
  if(fileFlag) {
    flag = *fileFlag;
    if((flag > 2) || (flag < 0)) flag = 0;
  }
  
  /* validate the filePath issues */
  p = NULL;
  p = strrchr(filePath,'/');
  if(p = NULL) { 
    goto wrapup;
  }
  
  /* fetch the file list */
  sts =
  VDfileGetDirInfo(filePath,
		   &dirList,
		   &fileList, 
		   &dirCnt, 
		   &fileCnt,
		   &flag);

  /* if no data go home */
  if(!sts || fileCnt == 0) {
    goto wrapup;
  }

  /* get the filter from the form */
  VIg_get_text(form,source,filter);

  /* clip the lists to match the filter */
  VDfileFilterNames(filter,
		    fileList,
		    &filteredFileList,
		    &fileCnt,
		    &filteredFileCnt);
  if(filteredFileCnt == 0) goto wrapup;
 
  /* set up the rows on the form */
   VIfld_set_num_rows(form,gadget,filteredFileCnt);

   /* loop around and put the data in the form */
   for(i = 0;i < filteredFileCnt;i++) {
     strcpy(newLine,filteredFileList[i]);
     VIfld_set_text(form, gadget, row, 0, newLine, 0);
     row++;
   }
   VDfileOrderFileList(form,VDTR_FILE_L_NAME,NULL,NULL);
  retFlag = 1;
  
wrapup:
  // say bye 
  /* clean up the memory issues */
  if( filteredFileCnt ) _LOOPFREE ( filteredFileList,filteredFileCnt );
  if( fileCnt ) _LOOPFREE ( fileList,fileCnt );
  if( dirCnt )  _LOOPFREE ( dirList,dirCnt);

  if (traceFlag) {
    printf("<<** %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}

/*****************************************************
 *
 * Display file info on form
 * given any input directory splits down the path
 * offsets the path
 * looks up sub files and displays them
 *
 *****************************************************/
IGRint VDfileDisplayDirPaths(char *form, IGRint gadget, IGRchar *dirPath, IGRint *dispFlag)
{
  VDASSERT_FN("VDfileDisplayDirPaths");
  IGRint  retFlag = 0, sts;
  IGRchar  **dirList;
  IGRchar  **fileList;
  IGRchar  buf[128],offsetSpace[128],sp[128],newLine[128],partPath[80];
  IGRchar  fullPath[1023];
  IGRchar  *p1,*p2;
  
  IGRint   row = 0,
           rows  = 0,
           selFlag = 0,
           pos = 0,
           dirCnt = 0,
           fileCnt = 0,
           offsets = 0,
           offset_spaces = 2,
           dir_lines = 0,
           strLen = 0,
           form_lines = 0,
           flag = 0,
           i,j;

   
       
  // say hi
  if (traceFlag) {
    printf("**>> %s %s\n",ffn(),fn); 
  }
  /* inits */
  buf[0] = '\0';
  partPath[0] = '\0';
  offsetSpace[0] = '\0';
  strcpy(sp," ");
  strcpy(offsetSpace,"");
  strcpy(newLine,"");
  if(dispFlag) flag = *dispFlag;
  
  
  /* args checks */
  VDASSERTW(form);
  VDASSERTW(dirPath);
  if(gadget < 11) goto wrapup;

  if(traceFlag) printf("dirPath [%s]\n",dirPath);

  /* set up the data (be extra careful) */
  if(!strcmp(dirPath,"")) strcpy(dirPath,"/");
  p1 = dirPath;
  if(!(*p1 == '/')) goto wrapup;
  /* lookup the subdirectories if any */
  sts =
  VDfileGetDirInfo(dirPath,
		   &dirList,
		   &fileList, 
		   &dirCnt, 
		   &fileCnt,
		   &flag);
  if( !sts ) goto wrapup;
  
  /* count up the offsets in the path */
  strLen = strlen(dirPath);
  for(i = 0;i < strLen;i++) {
    if(*p1 == '/') offsets++;
    p1++;
  }
  /* handle the "/" directory at the front */
  if(strLen > 1) offsets++;
  /* clear the form and set the number of lines for the form to display */
  form_lines = offsets + dirCnt;

  VIfld_set_num_rows(form,gadget,0);
  if(form_lines < 1) goto wrapup;
  VIfld_set_num_rows(form,gadget,form_lines);
  /* display the first line (always the same) */
  if(strLen > 1) {
    VIfld_set_text(form, gadget, 0, 0, "/", 0);
  } else {
    VIfld_set_text(form, gadget, 0, 0, "/", 1);
  }
  
  row = 1;
  
  /* start cutting up the path and displaying it */
  p1 = dirPath;
  /* if this is not the top directory */
  if(strLen > 1) {
    p1 = dirPath;
    strcpy(buf,"");
    /* get each character */
    for(i = 0;i < strLen;i++) {
      /* if it is starting a new string */
      if(*p1 == '/') {
	if(strcmp(buf,"")) {
	  sprintf(offsetSpace,"%s%s",offsetSpace,sp);
	  sprintf(newLine,"%s%s",offsetSpace,buf);
	  VIfld_set_text(form, gadget, row, 0, newLine, 0);
	  row++;
	}
	strcpy(buf,"");
      }
      sprintf(buf,"%s%c",buf,*p1);
      p1++;
    }
    sprintf(offsetSpace,"%s%s",offsetSpace,sp);
    sprintf(newLine,"%s%s",offsetSpace,buf);
    VIfld_set_text(form, gadget, row, 0, newLine, 1);
    row++;
  }
  
  /* create the open set of files below here */
  sprintf(offsetSpace,"%s%s",offsetSpace,sp);
  for(i = 0;i < dirCnt;i++) {
    strcpy(fullPath,dirList[i]);
    p1 = fullPath;
    p2 = p1;
    strLen = strlen(fullPath);
    for(j = 0;j < strLen;j++) {
      p1++;
      if(*p1 == '/') p2 = p1;
    }
    sprintf(newLine,"%s%s",offsetSpace,p2);
    //if(!(*p1 == '.')) {
      VIfld_set_text(form, gadget, row, 0, newLine, 0);
      row++;
      // }
  }
  
  
  vdtr$FixScrollBar(form = form,gadget = gadget);
  retFlag = 1;
  
wrapup:
  /* clean up the memory issues */
  if( fileCnt ) _LOOPFREE ( fileList,fileCnt );
  if( dirCnt )  _LOOPFREE ( dirList,dirCnt);

  // say bye 
  if (traceFlag) {
    printf("<<** %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}


/*****************************************************
 *
 * Gets the Dir Info /no hidden files/
 * does not display anything just gets the data!
 *
 *****************************************************/
IGRint VDfileGetDirInfo(IGRchar *dir_name,
			 IGRchar ***dirList,
			 IGRchar ***fileList, 
			 IGRint *dirCnt, 
			 IGRint *fileCnt,
			 IGRint *typeFlag)
{
  VDASSERT_FN("VDfileGetDirInfo");
  IGRint        retFlag = 0;
  DIR           *dir_id; 
  UNIX_NAME	*file_list,
                *dir_list; 
  IGRchar       text[128],test[128];
  IGRchar       *p1,*p2;
  IGRint 	file_count = 0,
		dir_count = 0,
		i,status;
  IGRint        strLen;
  IGRint        flag = 0;
  IGRint        lineFlag = 0;
  struct stat   stat_buf;
  struct dirent *dp;
     
  // say hi
  if (traceFlag) {
    printf("**>> %s %s\n",ffn(),fn); 
  }
  /* inits */
  *dirCnt = 0;
  *fileCnt = 0;
  dir_count = 0;
  file_count = 0;
  *dirList = NULL;
  *fileList = NULL;
  
  /* note: the 
   * (*typeFlag == 0)  directs that only visible files are included
   * (*typeFlag == 1)  directs that all files are included
   * (*typeFlag == 2)  directs that only the hidden files are included
   */
  if(typeFlag) {
    if(*typeFlag == 1) flag = 1;
    if(*typeFlag == 2) flag = 2;
  }
  
  /* make sure no directory blank, but start at top if blank */
  if(!strcmp(dir_name,"")) strcpy(dir_name,"/");

  /* open the dir and see what we get */
  if ( (dir_id = opendir(dir_name)) == NULL ) {
	strcpy(text,"Can not open directory: ");
	strcat(text,dir_name);
	VDGetFile_form_error(text);
	status = 0; goto wrapup; 
  }

/*** 	Get the number of entries. Alocate enough memory  ***/

  while ( (dp = readdir ( dir_id )) ) {
    strcpy(text, dir_name);
    strcat(text, "/"); 
    strcat(text, dp->d_name); 
    stat(text,&stat_buf);
    
    /* remove the '//' if it exists */
    p1 = strrchr(text,'/');
    strcpy(text,p1);
    if(*p1 == '/') p1++;

  /* check the status of the file */
    lineFlag = 0;
    if(*p1 == '.') {
      lineFlag = 1;
    }
    
    if(!(((flag == 0) && (lineFlag == 1)) ||
	 ((flag == 2) && (lineFlag == 0)))) {
      
      /* count them up */
      if( (stat_buf.st_mode & DIRECTORY_BIT) ) {
	dir_count++;
      }
      else {
	file_count++;
      }
    }
  }
  *fileCnt = file_count;
  *dirCnt = dir_count;

  /* go home if there is nothing to do */
  if((dir_count == 0) && (file_count == 0)) goto wrapup;

  /* allocate the memory for the (**) pointers */
  if(*fileCnt) {
    *fileList = _MALLOC( *fileCnt, IGRchar *  );
    if(*fileList == NULL) goto wrapup;
  }

  if(*dirCnt) {
    *dirList = _MALLOC( *dirCnt, IGRchar *  );
    if(*dirList == NULL) goto wrapup;
  }

  /* reread the file to get the data into the (***) buffers */
  rewinddir( dir_id); 
  dir_count = 0;
  file_count = 0;

  while ( (dp = readdir ( dir_id )) ) {
    strcpy(text, dir_name);
    strcat(text, "/"); 
    strcat(text, dp->d_name); 
    stat(text,&stat_buf);
    
    /* remove the '//' if it exists */
    p1 = strrchr(text,'/');
    strcpy(text,p1);
    
    /* check the status of the file */
    lineFlag = 0;
    if(*p1 == '/') p1++;
    if(*p1 == '.') lineFlag = 1;
    if(!(((flag == 0) && (lineFlag == 1)) ||
	 ((flag == 2) && (lineFlag == 0)))) {
      if( (stat_buf.st_mode & DIRECTORY_BIT) ) {
	/* allocate the memory for the (***) pointer */
	if( !( (*dirList)[dir_count] = _MALLOC( (sizeof(text) + 1), IGRchar  )))  {
	  printf("\nERROR: unable to allocate memory for [%s]\n\n",text);
	  goto wrapup;
	}
	strcpy((*dirList)[dir_count],text);
	dir_count++;
      }
      else {
	/* allocate the memory for the (***) pointer */
	if( !( (*fileList)[file_count] = _MALLOC( (sizeof(text) + 1), IGRchar  )))  {
	  printf("\nERROR: unable to allocate memory for [%s]\n\n",text);
	  goto wrapup;
	}
	p1 = text;
	p1++;
	strcpy(text,p1);
	strcpy((*fileList)[file_count],text);
	file_count++;
      }
    } 
  }
  *dirCnt = dir_count;
  *fileCnt = file_count;
  retFlag = 1;

wrapup:
  // say bye 


  if (traceFlag) {
    printf("<<** %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}


/*****************************************************
 *
 * Updates the file type selections in the box
 * does not execute the search
 *
 *****************************************************/
IGRint VDfileUpdateFileType(char *form, IGRint gadget)
{
  VDASSERT_FN("VDfileUpdateFileType");
  IGRint  retFlag = 0;
  IGRchar buf[80],listData[80];
  IGRint  row,rows,selFlag,pos;
     
  // say hi
  if (traceFlag) {
    printf("**>> %s %s\n",ffn(),fn); 
  }
  /* inits */
  *buf = '\0';
 
 
  /* args checks */
  VDASSERTW(form);
  if(gadget < 11) goto wrapup;

  /* update the input to the selection list */
  VIg_get_text(form,gadget,buf);
  if(!strcmp(buf,"")) {
    /* pick up row[o] if it exists */
    FIfld_get_list_text(form, gadget, 0,0, 80, (unsigned char *)buf, &selFlag);
    if(!strcmp(buf,"")) {
      strcpy(buf,"*.* *");
      VDfileAddFileType(form,gadget,buf);
    }
    FIg_set_text(form,gadget,buf);
    goto wrapup;
  }
  
  VDfileAddFileType(form, gadget, buf);
  

  /* get the item and select it  */
  FIfld_get_list_num_rows(form, gadget, 0, &rows);
  for(row = 0;row < rows;row++) {
    FIfld_get_list_text(form, gadget, row, 0, 80, (unsigned char *)listData, &selFlag);
    if(!strcmp(buf,listData)) {
      FIfld_set_list_select(form, gadget, row, 0, 1);
      VIg_set_text(form,gadget,buf);
    } else {
      FIfld_set_list_select(form, gadget, row, 0, 0);
    }
  }
  

 
  retFlag = 1;
  
wrapup:
  // say bye 


  if (traceFlag) {
    printf("<<** %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}

/*****************************************************
 *
 * Adds item to file type selection box
 * if none is selected selects the 1st one and hilite
 * else hilite becomes box selection
 * Also detects if item is already in the list and only 
 * adds it if it is not in the list
 *
 *****************************************************/
IGRint VDfileAddFileType(char *form, IGRint gadget, IGRchar *ftype)
{
  VDASSERT_FN("VDfileAddFileType");
  IGRint  retFlag = 0;
  IGRchar  *file_types;
  IGRint  row,rows,cols,selFlag = 0,pos = 0;
  IGRchar buf[80];
  IGRint  mode = 0;
     
  // say hi
  if (traceFlag) {
    printf("**>> %s %s\n",ffn(),fn); 
  }
  /* args checks */
  VDASSERTW(form);
  if(gadget < 11) goto wrapup;
  /* init */
  *buf = '\0';
  
  /* check mode */
  FIfld_get_mode(form,gadget,0,&mode);
  if(mode == 1) goto wrapup;

  if(ftype) {
    rows = 0;
    FIfld_get_list_num_rows(form, gadget, 0, &rows);
    /* loop through and get the text in the pulldown */
    for(row = 0; row < rows; row++) {
      FIfld_get_list_text(form, gadget, row, 0, 80, (unsigned char *)buf, &selFlag);
      /* if it is already in the list goto wrapup */
      if(!strcmp(buf,ftype))	goto wrapup;
    }
    /* add it to the list */
    selFlag = 0;
    FIfld_set_list_text( form,
			 gadget,  
			 rows,
			 0,
			 (unsigned char *)ftype,
			 selFlag );
  }
  /* loop through and check to see if any are selected */
  selFlag = 0;
  FIfld_get_list_num_rows(form, gadget, 0, &rows);
  for(row = 0; row < rows; row++) {
    FIfld_get_list_text(form, gadget, row, 0, 80, (unsigned char *)buf, &selFlag);
    if(selFlag == 1) break;
  }

  if(selFlag == 1) {
    VIg_set_text(form,gadget,buf);
  } else {
    FIfld_get_list_text(form, gadget, 0, 0, 80, (unsigned char *)buf, &selFlag);
    FIfld_set_list_select(form, gadget, 0, 0, 1);

    VIg_set_text(form,gadget,buf);
  }

  retFlag = 1;
  
wrapup:
  // say bye 
  if (traceFlag) {
    printf("<<** %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}

/*****************************************************
 *
 * Starts up the file browser
 * fully protected with default input values
 * no user imput is required
 * prototyped in VDfile.h as 
 * vdfile$BrowseBegin with all input pointers 
 * default to null! 
 * will ignore the dir and name if a path is supplied
 *
 *****************************************************/
IGRint VDfileBrowseBegin(IGRchar *dir,
			 IGRchar *name,
			 IGRchar *type,
			 IGRchar *path,
			 IGRchar *sFile,
			 IGRchar *lFile,
			 IGRint  *flag)
{
  VDASSERT_FN("VDfileBrowseBegin");
  IGRint  retFlag = 0;
  IGRchar  fileType[80];
  IGRchar  filePath[1023];
  IGRchar  fileName[80];
  IGRchar  *p,*p1;
  IGRint   fileCnt = 0;
  IGRint   fileFlag = 0;
  IGRint   i,strLen;
  IGRlong     msg;
  IGRint      size;  
  IGRlong     response;                 
  IGRchar     response_data; 
  IGRlong     mask; 
  struct GRevent event; 
 
   
  
  // say hi
  if (traceFlag) {
    printf("**>> %s %s\n",ffn(),fn); 
  }
  /* initialize the form pointer to null */
  form_ptr = NULL;

  /* set up the defaults if no imput is sent in */
  strcpy(fileType,"");
  strcpy(fileName,"");
  strcpy(filePath,"/");

  if(!path) {
    /* if there is a dir */
    if(dir) {
      if(strcmp(dir,"")) strcpy(filePath,dir);
    }
    /* if there is a name */
    if(name) {
      if(strcmp(name,"")) strcpy(fileName,name);
    }
  } else {
    /* there was a path supplied */
    if(VDfileIsPath(path)) {
      /* this is tested to be a valid path */
      VDfileSplitPath(path,filePath,fileName);
      
    } else {
      /* this is not a valid path */
      /* if there is a dir */
      if(dir) {
	if(strcmp(dir,"")) strcpy(filePath,dir);
      }
      /* if there is a name */
      if(name) {
	if(strcmp(name,"")) strcpy(fileName,name);
      }
    }
  }

  
  /* if there is a type */
  if(type) {
    if(strcmp(type,"")) strcpy(fileType,type);
  }
  /* it there is a flag */
  if(flag) {
    if(*flag == 1) fileFlag = 1;
  }

  VDfileSetInitFormData(filePath, 
			fileName,
			fileType,
			&fileFlag);

  

  retFlag = 1;
  
wrapup:
  // say bye 


  if (traceFlag) {
    printf("<<** %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}


/* ----------------------------------------
 * form notification routine
 * ***/
IGRint VDfileNotifyForm(char *form,IGRint gadget)
{
    VDASSERT_FN("notifyForm");

    IGRint retFlag = 1;
    IGRint sts,rows,selFlag,pos;
    IGRchar DirName[1023],type[128],*p;
    IGRint  flag = 0;
     
     /* say hi */
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
    /* be a bit paranoid */
    form_ptr = form;
    if(traceFlag) printf("at Line[%d]\n",__LINE__);
    FIg_set_text(form,22,"");
    if(traceFlag) printf("at Line[%d]\n",__LINE__);
    FORM_NOTIFICATION = 0;

    switch(gadget) {
      /* the cancel button was selected */
      case FI_CANCEL:
	IS_ACCEPTED = 0;
	VDfileStoreForm( form );
	break;

        /*the ACCEPT button was selected */
      case FI_ACCEPT:
	/* do the action here */
	VDfileStoreForm( form );
	IS_ACCEPTED = 1;
	FORM_NOTIFICATION = 1;
        break;

	/* the file name box was selected */
      case VDTR_FILE_T_NAME:
	break;

	/* the file type box was selected */
      case VDTR_FILE_T_TYPE:
	if(traceFlag) printf("VDTR_FILE_T_TYPE selection\n");
	/* update the gadget selection list */
	VDfileUpdateFileType( form, VDTR_FILE_T_TYPE);

	/* alphabetize the associated list flag (show text already in box) addItem (no) */
	vdtvw$FormMakeTextItemsUniqueAUp(form    = form,
					 gadget  = VDTR_FILE_T_TYPE,
					 flag    = 0,
					 addItem = 0);
	  /* go get the data */
	VIg_get_text(form,VDTR_FILE_T_DIR,DirName);

	VDfileDisplayDirPaths(form, 
			      VDTR_FILE_L_DIR,
			      DirName,
			      &flag);
	VDfileDisplayFiles(form,
			   VDTR_FILE_L_NAME,
			   VDTR_FILE_T_TYPE,
			   DirName,
			   &flag);

	VDfileDisplayFile(form,VDTR_FILE_T_NAME,VDTR_FILE_L_NAME);
	vdtr$FixScrollBar(form = form,gadget = VDTR_FILE_L_NAME);
	vdtr$FixScrollBar(form = form,gadget = VDTR_FILE_L_DIR);
	VDfileShowFileFilter(form,
			     VDTR_FILE_T_TYPE,
			     1,
			     WC_CMD,
			     LOC_FILE,
			     LOC_PATH);
	
	VDfileShowFileFilter(form,
			     VDTR_FILE_T_TYPE,
			     0,
			     WC_CMD,
			     SYS_FILE,
			     SYS_PATH);

	VDfileStoreForm( form );
	break;

	/* the dir box was selected */
      case VDTR_FILE_T_DIR:
	break;

	/* the name list box was selected */
      case VDTR_FILE_L_NAME:
	VDfileDisplayFile(form,VDTR_FILE_T_NAME,VDTR_FILE_L_NAME);
	VDfileStoreForm( form );
	break;

	/* the dir list box was selected */
      case VDTR_FILE_L_DIR:
	if(traceFlag) printf("VDTR_FILE_L_DIR selection\n");
	VDfileDisplayPath(form,VDTR_FILE_T_DIR,VDTR_FILE_L_DIR);
	/* read the dir gadget on the form for information */
	VIg_get_text(form,VDTR_FILE_T_DIR,DirName);
	if(!strcmp(DirName,"")) goto wrapup;
	
	VDfileDisplayDirPaths(form, 
			      VDTR_FILE_L_DIR,
			      DirName,
			      &flag);
	VDfileDisplayFiles(form,
			   VDTR_FILE_L_NAME,
			   VDTR_FILE_T_TYPE,
			   DirName,
			   &flag);
	VDfileDisplayFile(form,VDTR_FILE_T_NAME,VDTR_FILE_L_NAME);
	VDfileStoreForm( form );
	break;
      case VDTR_FILE_B_SAVE:
	/* get the text to save from the gadget */
	FIg_get_text(form,VDTR_FILE_T_DIR,DirName);
	p = DirName;
	if(!(*p == '/')) {
	  goto wrapup;
	}
	
	
	/* activate the save a path button */
	VDfileSavePathToLocalFile(form,
				  F_CMD,
				  LOC_FILE,
				  LOC_PATH);

	/* load up the file paths */
	VDfileGetPathsFromFiles(form,VDTR_FILE_T_PATHS,F_CMD,
				LOC_FILE,LOC_PATH,
				SYS_FILE,SYS_PATH);


	FIg_set_text(form,VDTR_FILE_T_PATHS,DirName);
	
	break;
      case VDTR_FILE_B_DEL:
	/* activate the remove a path button */
	/* get the data from the gadget */
	VIg_get_text(form,VDTR_FILE_T_DIR,DirName);
	if(!strcmp(DirName,"")) goto wrapup;
	FIg_reset( form,VDTR_FILE_T_PATHS );
	/* get rid of it */
	VDfileRemoveItemFromFile(DirName,F_CMD,LOC_FILE,LOC_PATH);
	/* load up the file paths */
	VDfileGetPathsFromFiles(form,VDTR_FILE_T_PATHS,F_CMD,
				LOC_FILE,LOC_PATH,
				SYS_FILE,SYS_PATH);
	
	VIfld_get_num_rows(form,VDTR_FILE_T_PATHS, &rows);
	if(traceFlag) printf("\n\nrows found[%d]\n",rows);

	if(rows == 0) {
	  FIg_set_text(form,VDTR_FILE_T_PATHS,"");
	  FIg_disable(form,VDTR_FILE_T_PATHS);
	}
	if(rows > 0) {
	  VIfld_get_text(form,VDTR_FILE_T_PATHS,0,0,1028,DirName,&selFlag,&pos);
	  if(traceFlag) printf("xDirName[%s]\n",DirName);
	  FIg_set_text(form,VDTR_FILE_T_PATHS,DirName);
	  if(strcmp(DirName,"")) {
	    FIg_enable(form,VDTR_FILE_T_PATHS);
	  } else {
	    FIg_disable(form,VDTR_FILE_T_PATHS);
	  }
	  
	}
	VIg_get_text(form,VDTR_FILE_T_DIR,DirName);
	/* make the text box do its stuff properly */
	VDfileDisplayListItem(form,VDTR_FILE_T_PATHS,DirName,0,
			      "System Protected this Path",22);
	break;
      case VDTR_FILE_T_PATHS:
	/* activated the text gadget selection */
	VDfileUpdatePathFromFileList(form);
	break;

      case VDTR_FILE_B_FSAVE:
	/* the filter save button activated */
	if(traceFlag) printf("at Line[%d]\n",__LINE__);
	VDfileSaveFileFilter(form,VDTR_FILE_T_TYPE,WC_CMD,
			     LOC_FILE,LOC_PATH);
	if(traceFlag) printf("at Line[%d]\n",__LINE__);
	VDfileShowFileFilter(form,
			     VDTR_FILE_T_TYPE,
			     0,
			     WC_CMD,
			     LOC_FILE,
			     LOC_PATH);
	if(traceFlag) printf("at Line[%d]\n",__LINE__);
	VDfileShowFileFilter(form,
			     VDTR_FILE_T_TYPE,
			     1,
			     WC_CMD,
			     LOC_FILE,
			     LOC_PATH);
	if(traceFlag) printf("at Line[%d]\n",__LINE__);
	break;
      case VDTR_FILE_B_FDEL:
	if(traceFlag) printf("at Line[%d]\n",__LINE__);
	/* the filter delete button activated */
	if(traceFlag) printf("VDTR_FILE_B_FDEL:\n");
	
	VIg_get_text(form,VDTR_FILE_T_TYPE,type);
	VDfileDeleteFileFilter(form,VDTR_FILE_T_TYPE,WC_CMD,
			       LOC_FILE,LOC_PATH);
	/* update the gadget selection list */
	VDfileUpdateFileType( form, VDTR_FILE_T_TYPE);
	  /* go get the data */
	VIg_get_text(form,VDTR_FILE_T_DIR,DirName);
	VDfileCleanItemFromList(form,VDTR_FILE_T_TYPE,type);
	VDfileShowFileFilter(form,
			     VDTR_FILE_T_TYPE,
			     1,
			     WC_CMD,
			     LOC_FILE,
			     LOC_PATH);
	
	VDfileShowFileFilter(form,
			     VDTR_FILE_T_TYPE,
			     0,
			     WC_CMD,
			     SYS_FILE,
			     SYS_PATH);
	VDfileStoreForm( form );
	if(traceFlag) printf("just before update type[%s]\n",type);

	/* make the text box do its stuff properly */
	VDfileDisplayListItem(form,VDTR_FILE_T_TYPE,type,0,
			      "System Protected this selection",22);
	
	VDfileDisplayDirPaths(form, 
			      VDTR_FILE_L_DIR,
			      DirName,
			      &flag);
	VDfileDisplayFiles(form,
			   VDTR_FILE_L_NAME,
			   VDTR_FILE_T_TYPE,
			   DirName,
			   &flag);
	VDfileDisplayFile(form,VDTR_FILE_T_NAME,VDTR_FILE_L_NAME);
	vdtr$FixScrollBar(form = form,gadget = VDTR_FILE_L_NAME);
	vdtr$FixScrollBar(form = form,gadget = VDTR_FILE_L_DIR);
	
	break;
	

        /* default does nothing */
      default:
        break;

    }
    
wrapup:
    /* say bye */
    if (traceFlag) printf("<<< %s %s(%d)\n",ffn(),fn,retFlag);
    return retFlag;
}

/*****************************************************
 *
 * Init the form
 *
 *****************************************************/
IGRint VDfileInitForm(char *form)
{
  VDASSERT_FN("VDfileInitForm");
  IGRint   retFlag = 0;
  IGRint    formFlag = 1;
  IGRint    row,rows,pos = 0,selFlag,notify = 0;
  IGRint   sts = 0;
  IGRchar   pplName[128],buf[128],dirBuf[1023];
  IGRint    disp_flag = 0;
  IGRint    status;
  IGRchar   DirName[1023];
  IGRchar   ftype[80];
  IGRchar   *tag_dir,*ptr,**tags;
  IGRint    count,strLen;
  IGRchar   **dirList;
  IGRchar   **fileList;
  IGRint    dirCnt;
  IGRint    fileCnt;
  IGRint    flag = 0;
  IGRint    offset = 0,steps = 0;
    
  // say hi
  if (traceFlag) {
    printf("**>> %s %s\n",ffn(),fn); 
  }

  /* init */
  pplName[0] = '\0';
  buf[0] = '\0';
  selFlag = 0;

  /* start up the form */
  form_ptr = form;

  /* update any data to init */
  VDfileLimitTypeSel(fileInfo.ftype,fileInfo.ftog);

  VDfileShowFileFilter(form,
		       VDTR_FILE_T_TYPE,
		       1,
		       WC_CMD,
		       LOC_FILE,
		       LOC_PATH);
  
  VDfileShowFileFilter(form,
		       VDTR_FILE_T_TYPE,
		       0,
		       WC_CMD,
		       SYS_FILE,
		       SYS_PATH);
  

  /* set the file directory for use from fileInfo */
  VDfileSetDir(fileInfo.fdir);


  /* set the file path list up for use */
  VDfileUpdatePathFromFileList(form);

  /* set the paths on the form from fileInfo */
  VDfileDisplayDirPaths(form, 
			VDTR_FILE_L_DIR,
			fileInfo.fdir,
			&flag);

  /* set the files to display on the form from fileInfo */
  VDfileDisplayFiles(form,
		     VDTR_FILE_L_NAME,
		     VDTR_FILE_T_TYPE,
		     fileInfo.fdir,
		     &flag);
  if(traceFlag) printf("IS ACCEPTED is [%d]\n",IS_ACCEPTED);
  
   if(IS_ACCEPTED) {
 
    
    if(strcmp(fileInfo.fname,"")) {
      /* set the fname into the gadget */
      VIg_set_text(form,VDTR_FILE_T_NAME,fileInfo.fname);
      
      /* hilite the fname in the list */
      VIfld_get_num_rows(form,VDTR_FILE_L_NAME,&rows);
      for(row = 0;row < rows;row++){
	/* get the row content */
	VIfld_get_text(form,VDTR_FILE_L_NAME,row,0, 80, buf,&selFlag,&pos);
	if(!strcmp(buf,fileInfo.fname)) {
	  VIfld_set_text(form, VDTR_FILE_L_NAME, row, 0, buf, 1);
	  break;
	}
      }
    } 
  }
 
  /* load up the file paths */
  VDfileGetPathsFromFiles(form,VDTR_FILE_T_PATHS,F_CMD,
			  LOC_FILE,LOC_PATH,
			  SYS_FILE,SYS_PATH);

  VIfld_get_num_rows(form,VDTR_FILE_T_PATHS, &rows);
  if(rows == 0) {
    FIg_set_text(form,VDTR_FILE_T_PATHS,"");
    FIg_disable(form,VDTR_FILE_T_PATHS);
  }
  else {
    FIg_enable(form,VDTR_FILE_T_PATHS);
  }

  FIg_get_text(form,VDTR_FILE_T_DIR,DirName);
  FIg_set_text(form,VDTR_FILE_T_PATHS,DirName);
  
  retFlag = 1;
  
wrapup:
  // say bye
  if (traceFlag) {
    printf("<<** %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}
/*****************************************************
 *
 * Wake the form
 *
 *****************************************************/
IGRint VDfileWakeForm(char *form)
{
  VDASSERT_FN("VDfileWakeForm");
  IGRint  retFlag = 0;

  // say hi
  if (traceFlag) {
    printf("**>> %s %s\n",ffn(),fn); 
  }

  /* make the form appear */
  VIf_display(form);
  
  retFlag = 1;
  
wrapup:
  // say bye 


  if (traceFlag) {
    printf("<<** %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}

/*****************************************************
 *
 * Sleep the form
 *
 *****************************************************/
IGRint VDfileSleepForm(char *form)
{
  VDASSERT_FN("VDfileSleepForm");
  IGRint  retFlag = 0;

  // say hi
  if (traceFlag) {
    printf("**>> %s %s\n",ffn(),fn); 
  }

  /* make the form disappear */ 
  vdfrm$EraseForm(form = form,show = 0,flag = NULL);
  
  
  retFlag = 1;
  
wrapup:
  // say bye 


  if (traceFlag) {
    printf("<<** %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}

/*****************************************************
 *
 * Destroy the form
 *
 *****************************************************/
IGRint VDfileDeleteForm(char *form)
{
  VDASSERT_FN("VDfileDeleteForm");
  IGRint  retFlag = 0;

  // say hi
  if (traceFlag) {
    printf("**>> %s %s\n",ffn(),fn); 
  }
  /* store away the data from the form */
  if(traceFlag) printf("storing the form \n");
  VDfileStoreForm( form );
  if(traceFlag) printf("deleting the form \n");
  /* actually delete the form */
  VDfrmDeleteForm( form, 0 );
  retFlag = 1;
  
wrapup:
  // say bye 
  if (traceFlag) {
    printf("<<** %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}
/*****************************************************
 *
 * Store the default form data 
 *
 *****************************************************/
IGRint VDfileStoreForm(char *form)
{
  VDASSERT_FN("VDfileStoreForm");
  IGRint  retFlag = 0;
     
  // say hi
  if (traceFlag) {
    printf("**>> %s %s\n",ffn(),fn); 
  }
  /* get the fname and store it */
  VIg_get_text(form,VDTR_FILE_T_NAME,fileInfo.fname);

  /* get the ftype and store it */
  VIg_get_text(form,VDTR_FILE_T_TYPE,fileInfo.ftype);

  /* get the fdir and store it */
  VIg_get_text(form,VDTR_FILE_T_DIR,fileInfo.fdir);

  /* get the ftog and store it */
  FIfld_get_mode(form,VDTR_FILE_T_TYPE,0,&fileInfo.ftog);

  retFlag = 1;
  
wrapup:
  // say bye 
  if (traceFlag) {
    printf("<<** %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}
/*****************************************************
 *
 * Tells if a string is really a path
 * the function return value is the useful part
 *
 *****************************************************/
IGRint VDfileIsPath(IGRchar *path)
{
  VDASSERT_FN("VDfileIsPath");
  IGRchar *p;
  IGRint  retFlag = 0;
     
  // say hi
  if (traceFlag) {
    printf("**>> %s %s\n",ffn(),fn); 
  }

  VDASSERTW(path);
  
  p = path;
  /* if the first character is not a '/' it is not a path */
  if(!(*p == '/')) goto wrapup;
  
  retFlag = 1;
  
wrapup:
  // say bye 


  if (traceFlag) {
    printf("<<** %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}

/*****************************************************
 *
 * DRIVE the Whole Thing 
 * Runs the entire Operation in one location
 * No input values are required It will operate
 * more to user satisfaction if these values are 
 * set to the user needs.
 * all values are output and all values are input
 * It is most likely that the user will want to set 
 * the values so:
 * *Flag == 1;  This turns off user selection of File Types
 * *Path is most likely better if it has no value
 * *Dir should be set to the starting directory for browsing
 * *Name probably should have no initial value
 *       it can have a value but is likely to result in no value
 * *Type This should be set to all of the selection filters at 
 *       one time.  If Flag != 1 it will not be limited to this filter set
 *       The user selection is limited to this set if an entry is made
 *       Entries should look like standard file filtering phrases with 
 *       '*' for wildcards and any text format as desired.
 *       '*.*' fetches any file name which has a extension
 *       '*'   fetches any file name 
 *       '*.txt' will fetch all files with the extension '.txt'
 *       '.txt' will only fetch a file named '.txt'
 *       '*12.*txt'  will fetch any file name with the prefix ending in '12' and any 
 *                   extension ending in 'txt'  
 *       There is no limit to the sequencing of these filters.
 *       It is a valid filter for example to say 'A.12*.B*.x.*txt*'  It might not be useful
 *       but the filter is valid.
 * *LocalDir is used to set a flag to lookup and limit input to the local directory
 *          if(*LocalDir != 0) sets Dir to the vds local directory
 *          if(*LocalDir == -1) will only look in the vds local directory
 *          if(*LocalDir == 0) will use the Dir sent in or the default as
 *          the case may be. IS NOT REQUIRED!
 *
 *****************************************************/
IGRint VDfileBrowseFiles(IGRchar *Dir,
			 IGRchar *Name, 
			 IGRchar *Type, 
			 IGRchar *Path, 
			 IGRchar *sFile,
			 IGRchar *lFile,
			 IGRint  *Flag,
			 IGRint  *Selected,
			 IGRint  *LocalDir)
{
  VDASSERT_FN("VDfileBrowseFiles");
  IGRchar *p,pplName[128];
  IGRint  retFlag = 0;
  IGRchar funcName[128];
  IGRint  limitLocal = 0;
  IGRchar fullPath[1023];
     
  
  
  // say hi
  if (traceFlag) {
    printf("**>> %s %s\n",ffn(),fn); 
  }
  /* inits */
  pplName[0] = '\0';
  funcName[0] = '\0';
  fullPath[0] = '\0';

  if(Selected) *Selected = 0;
  if(LocalDir) {
    limitLocal = *LocalDir;
    /* limit the input to the safe ranges */
    if(limitLocal < -1) limitLocal = -1;
    if(limitLocal > 1) limitLocal = 1;
  }
  if(limitLocal != 0) {
    VDfileGetLocalPath(fullPath, 
		       Dir, 
		       Name);
    /* turn of the default to the path if local vds path selected */
    if(Path) Path[0] = '\0';
  } 
  /* set the data up to the form */
  fileInfo.fbrowse = limitLocal;
  
  /* set up the default dat to match the inputs */
  /* none of these have to be here */
  IS_ACCEPTED = 0;
  vdfile$BrowseBegin(dir  = Dir,
		     name = Name,
		     type = Type,
		     path = Path,
		     flag = Flag);

  /* set up the ppl name */
  strcpy(pplName,"COzBrowse");
  strcpy(funcName,"main");
  
  ci$exec( file_name = pplName,
	   sender_id = NULL_OBJID,
	   entry     = funcName  );

  vdfile$GetFormData(dir  = Dir,
		     name = Name,
		     type = Type,
		     path = Path,
		     flag = Flag);


  if(Selected) *Selected = FORM_NOTIFICATION;
 
  retFlag = FORM_NOTIFICATION;
  FORM_NOTIFICATION = 0;
  
wrapup:
  // say bye 


  if (traceFlag) {
    printf("<<** %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}

/***************************************************
 *
 * Update the filePath data from the selection 
 * to the actual working text and activate the
 * form updates 
 *
 ***************************************************/
IGRstat VDfileUpdatePathFromFileList(char *form)
{
  IGRstat retFlag = 0, sts;
  VDASSERT_FN("VDfileSavePathToLocalFile");
  IGRchar name[1023],*p,buf[1023];
  IGRint  flag = 0;

    
    
  
  // say hi
  if (traceFlag) {
    printf("**>> %s %s\n",ffn(),fn); 
  }

  /* fetch the text from the gadget */
  FIg_get_text(form,VDTR_FILE_T_PATHS,name);
  if(!strcmp(name,"")) goto wrapup;
  p = name;

  /* double protect the data */
  if(!(*p == '/')) goto wrapup;
  if(traceFlag) printf("\n\n\t%s %sname[%s]\n\n",ffn(),fn,name);
  
  /* update the file directory list */
  sts =
  VDfileDisplayDirPaths(form, 
			VDTR_FILE_L_DIR,
			name,
			&flag);
  if(!sts) goto wrapup;

  sts =
  VDfileDisplayFiles(form,
		     VDTR_FILE_L_NAME,
		     VDTR_FILE_T_TYPE,
		     name,
		     &flag);
  if(!sts) goto wrapup;

  FIg_set_text(form,VDTR_FILE_T_DIR,name);

  VDfileDisplayFile(form,VDTR_FILE_T_NAME,VDTR_FILE_L_NAME);
  vdtr$FixScrollBar(form = form,gadget = VDTR_FILE_L_NAME);
  vdtr$FixScrollBar(form = form,gadget = VDTR_FILE_L_DIR);
  VDfileStoreForm( form );

  retFlag = 1;
 wrapup:
  // say bye 


  if (traceFlag) {
    printf("<<** %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}


/***************************************************
 *
 * Fetch the path from the selection gadget and
 * save it to the file
 *
 ***************************************************/
IGRstat VDfileSavePathToLocalFile(char    *form,
				  IGRchar *cmdType,
				  IGRchar *localFile,
				  IGRchar *localPPath)
{
  IGRstat retFlag = 0;
  VDASSERT_FN("VDfileSavePathToLocalFile");
  IGRchar **fileLines,DirName[1023],buf[1023],*p,*tmp;
  IGRint  lineCnt = 0;
  IGRint  cmdFound = 0;
  IGRint  fileSts = 0;
  IGRint  i,q,count = 0;
  IGRchar **cmdList;
  IGRint  cmdListCnt = 0;
  IGRint  bottom = 0,swaps = 0,top = 0;
   
   
  
  // say hi
  if (traceFlag) {
    printf("**>> %s %s\n",ffn(),fn); 
  }

  /* args check */
  VDASSERTW(cmdType);
  if(!strcmp(cmdType,"")) goto wrapup;
  
  /* get the file text from the gadget */
  VIg_get_text(form,VDTR_FILE_T_DIR,DirName);

  /* validate the path if it is not blank */
  if(!strcmp(DirName,"")) goto wrapup;

  /* read the file into a buffer */
  fileSts = vdio$ReadAnyFile(fileName  = localFile,
                             partPath  = localPPath,
                             fileLines = &fileLines,
                             lineCnt   = &lineCnt);
  cmdListCnt = 0;
  cmdFound = 0;
  if(lineCnt > 0) {
    /* clip out the commands */
    VDfileGetListCommands(cmdType,
			  &fileLines,
			  &lineCnt,
			  &cmdList,
			  &cmdListCnt,
			  &cmdFound);
    /* go away if we don't need to do anything */
    if(VDfileIsStingInList(DirName,
			   cmdList,
			   cmdListCnt)) goto wrapup;
    
  }
  /* if we don't have a command add it */
  if(cmdFound < 0) {
    sprintf(buf,"\n%c %s\n",'%',cmdType);
    vdtvw$AddStrList(item    = buf,
		     List    = &fileLines,
		     ListCnt = &lineCnt);  
  }

  /* unconditionally add the item to the bottom of the list */
  sprintf(buf,"%c %s\n",'#',DirName);
  vdtvw$AddStrList(item    = buf,
		   List    = &fileLines,
		   ListCnt = &lineCnt);  

  /* do some pointer things if already had a command */
  if(!(cmdFound < 0)) {
    /* calculate the action to be done */
    top = cmdFound + 1;
    bottom = lineCnt - 1;
    swaps = bottom - top;
    if(swaps > 0 ) {
      for(i = bottom;i > top;i--) {
	tmp = fileLines[i];
	fileLines[i] = fileLines[i -1];
	fileLines[i -1] = tmp;
      }
    }
  }
  
  if(traceFlag) printf("\n\n%s %s:\nlocalFile[%s] localPPath[%s]\n",
		       ffn(),fn,localFile,localPPath);
  /* save the path to the local file */
  if(count < lineCnt) {
    vdio$WriteAnyFile(fileName  = localFile,
		      partPath  = localPPath,
		      fileLines = fileLines,
		      lineCnt   = &lineCnt);
      }

  
  retFlag = 1;
wrapup:
  // say bye 
  if(lineCnt > 0) _LOOPFREE( fileLines, lineCnt);
  if(cmdListCnt > 0) _LOOPFREE( cmdList,cmdListCnt);
  
  if (traceFlag) {
    printf("<<** %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}


/***************************************************
 *
 * Fetch the file data for the associated list 
 * organize the list data
 * keep the text in the box if it is valid (not blank etc)
 *
 ***************************************************/
IGRstat VDfileGetPathsFromFiles(char    *form,
				IGRint   gadget,
				IGRchar *cmdType,
				IGRchar *localFile,
				IGRchar *localPPath,
				IGRchar *serverFile,
				IGRchar *serverPPath)
{
  IGRstat retFlag = 0;
  VDASSERT_FN("VDfileGetPathsFromFiles");
  IGRchar **fileLines,name[1023],buf[1023],bufStr[1023],bufIt[1023],*p;
  IGRchar **cmdList;
  IGRint  cmdFound = 0;
  IGRint  cmdListCnt = 0;
  IGRint  fileLinesCnt = 0;
  IGRint  cnt = 0,isFilePathOK = 0,isFileTypeOK = 0;
  IGRint  i,j,rows,flag = 0,selFlag = 0;
   
  
  // say hi
  if (traceFlag) {
    printf("**>> %s %s\n",ffn(),fn); 
  }

  /* save the gadget text */
  FIg_get_text(form,VDTR_FILE_T_PATHS,name);

  /* reset the gadget */
  FIg_reset(form,VDTR_FILE_T_PATHS);

  /* read the localFile  */
  vdio$ReadAnyFile(fileName  = localFile,
		   partPath  = localPPath,
		   fileLines = &fileLines,
		   lineCnt   = &fileLinesCnt);
  if(fileLinesCnt > 0) {
    cmdListCnt = 0;
    cmdFound = 0;
    /* clip out the commands */
    VDfileGetListCommands(cmdType,
			  &fileLines,
			  &fileLinesCnt,
			  &cmdList,
			  &cmdListCnt,
			  &cmdFound);
  }
  

  if(cmdListCnt > 0) {
    for(i = 0;i < cmdListCnt;i++) {
      bufStr[0] = '\0';
      bufIt[0] = '\0';
      strcpy(buf,cmdList[i]);
      p = buf;
      if(traceFlag) printf("buf[%s]\n",buf);
      if(!(*p == '/')) continue;
      for(j = 0; j < strlen(buf);j++) {
	if(*p == '\0') continue;
	if(*p == '\n') continue;
	if(*p == ' ') continue;
	sprintf(bufStr,"%s%c",bufIt,*p);
	strcpy(bufIt,bufStr);
	p++;
      }
      if(strlen(bufStr) > 0) {
	p = bufStr;
	if(*p == '/') {
	  FIfld_set_list_text( form,
			       VDTR_FILE_T_PATHS,
			       cnt,
			       0,
			       (unsigned char *)bufStr,
			       selFlag );
	  cnt++;
	}
      }
    }
  }

  /* free the lists */
  if(cmdListCnt > 0) _LOOPFREE( cmdList,cmdListCnt );  
  cmdListCnt = 0;
  if(fileLinesCnt > 0) _LOOPFREE( fileLines,fileLinesCnt );  
  fileLinesCnt = 0;
  vdio$ReadAnyFile(fileName  = serverFile,
		   partPath  = serverPPath,
		   fileLines = &fileLines,
	  	   lineCnt   = &fileLinesCnt);

  if(traceFlag) printf("AV fileLinesCnt[%d]\n",fileLinesCnt);
  if(fileLinesCnt > 0) {
    cmdListCnt = 0;
    cmdFound = 0;
    /* clip out the commands */
    VDfileGetListCommands(F_CMD,
			  &fileLines,
			  &fileLinesCnt,
			  &cmdList,
			  &cmdListCnt,
			  &cmdFound);
  }
  
  if(traceFlag) printf("AV cnt[%d] cmdFound[%d] cmdListCnt[%d]\n",cnt,cmdFound,cmdListCnt);
  
  if(cmdListCnt > 0) {
    for(i = 0;i < cmdListCnt;i++) {
      
      bufStr[0] = '\0';
      bufIt[0] = '\0';
      strcpy(buf,cmdList[i]);
      p = buf;
      if(traceFlag) printf("buf[%s]\n",buf);
      if(!(*p == '/')) continue;
      for(j = 0; j < strlen(buf);j++) {
	if(*p == '\0') continue;
	if(*p == '\n') continue;
	if(*p == ' ') continue;
	sprintf(bufStr,"%s%c",bufIt,*p);
	strcpy(bufIt,bufStr);
	p++;
      }
      if((strlen(bufIt)) > 0) {
	p = bufIt;
	if(*p == '/') {
	  FIfld_set_list_text( form,
			       VDTR_FILE_T_PATHS,
			       cnt,
			       0,
			       (unsigned char *)bufIt,
			       selFlag );
	  cnt++;
	}
      }
    }
  }
  
  if(fileLinesCnt > 0) _LOOPFREE( fileLines,fileLinesCnt );  
  fileLinesCnt = 0;

  /* bat cleanup on the display order on this box */
  VIg_set_text(form,VDTR_FILE_T_PATHS,name);
  if(!strcmp(name,"")) flag = 1;
  vdtvw$FormMakeTextItemsUniqueAUp(form    = form,
				   gadget  = VDTR_FILE_T_PATHS,
				   flag    = flag,
				   addItem = 0);
  retFlag = 1;
wrapup:
  VIfld_get_num_rows(form,VDTR_FILE_T_PATHS, &rows);
  if(rows == 0) {
    FIg_set_text(form,VDTR_FILE_T_PATHS,"");
    FIg_disable(form,VDTR_FILE_T_PATHS);
  }
  if(rows > 0) FIg_enable(form,VDTR_FILE_T_PATHS);

  // say bye 

  if (traceFlag) {
    printf("<<** %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}



/*********************************************************
 *
 * Remove a text item
 * make sure to remove it from the specific 
 * segment of the list it should be removed from
 * and not from any other location
 * will remove duplicate entries under the segment
 * checks all items under the segment
 *
 *********************************************************/
IGRstat VDfileRemoveItemFromFile(IGRchar *item,
				 IGRchar *command,
				 IGRchar *fileName, 
				 IGRchar *filePPath)
{
  IGRstat retFlag = 0;
  VDASSERT_FN("VDfileRemoveItemFromFile");
  IGRint    delOK = 1;
  IGRchar **fileLines,**cmdList,**newLines;
  IGRint    fileLinesCnt = 0,cmdListCnt = 0,newLinesCnt = 0,cmdFound = -1;
  IGRchar  *p,buf[4096],buffer[4096];
  IGRint    i,j;
  
   
  
  // say hi
  if (traceFlag) {
    printf("**>> %s %s\n",ffn(),fn); 
  }

  /* args check */
  VDASSERTW(item);
  VDASSERTW(command);
  VDASSERTW(fileName);
  VDASSERTW(filePPath);
  /* init */
  buf[0] = '\0';
 
  /* read the localFile  */
  vdio$ReadAnyFile(fileName  = fileName,
		   partPath  = filePPath,
		   fileLines = &fileLines,
		   lineCnt   = &fileLinesCnt);

  /* no lines no action */
  if(fileLinesCnt < 1) goto wrapup;
  

  /* clip out the commands */
  VDfileGetListCommands(command,
			&fileLines,
			&fileLinesCnt,
			&cmdList,
			&cmdListCnt,
			&cmdFound);

  /* no command no action */
  if(cmdFound < 0) goto wrapup;
  /* no cmdLines no action */
  if(cmdListCnt < 1) goto wrapup;
  
  /* loop through and see if the command is in the list */
  for(i = 0;i < fileLinesCnt;i++) {
		p = fileLines[i];
    if(i > cmdFound) {
      if(delOK == 0) {
	/* just add these guys to the list */
	vdtvw$AddStrList(item    = fileLines[i],
			 List    = &newLines,
			 ListCnt = &newLinesCnt);  
	continue;
      } else {
	/* we need to check these guys */
	if(*p == '%'){
	  /* add this guy and stop deletion checks */
	  vdtvw$AddStrList(item    = fileLines[i],
			   List    = &newLines,
			   ListCnt = &newLinesCnt);  
	  delOK = 0;
	  continue;
	} else if(*p == '#') {
	  p++;
	  for(j = 0;j < strlen(p);j++) {
	    if(!(*p == ' ')) break;
	    p++;
	  }
	  
	  buf[0] = '\0';
	  strcpy(buffer,p);
	  p = buffer;
	  for(j = 0;j < strlen(buffer);j++) {
	    if(!((*p == '\n') || (*p == '\0')))   sprintf(buf,"%s%c",buf,*p);
	    p++;
	  }
	  if(traceFlag) printf("%s %s\n",buf,item);
	  if((strlen(buf)) > 0) {
	    if(!strcmp(buf,item)) {
	      continue;
	    }
	  }
	  
	  /* add this guy  */
	  vdtvw$AddStrList(item    = fileLines[i],
			   List    = &newLines,
			   ListCnt = &newLinesCnt);  
	  continue; 
	} else {  
	  /* add this guy  */
	  vdtvw$AddStrList(item    = fileLines[i],
			   List    = &newLines,
			   ListCnt = &newLinesCnt);  
	}
      }
    } else {
      /* just add these guys to the list */
      vdtvw$AddStrList(item    = fileLines[i],
		       List    = &newLines,
		       ListCnt = &newLinesCnt);  
      continue;
    }
  }

  if(newLinesCnt > 0) {
    /* write the file */
  if(traceFlag) printf("\n\n%s %s:\nfileName[%s] filePPath[%s]\n",
		       ffn(),fn,fileName,filePPath);
    vdio$WriteAnyFile(fileName  = fileName,
		      partPath  = filePPath,
		      fileLines = newLines,
		      lineCnt   = &newLinesCnt);
  }
  
  retFlag = 1;
wrapup:
  // say bye 
  if(newLinesCnt > 0)     _LOOPFREE( newLines,newLinesCnt );
  if(cmdListCnt > 0)      _LOOPFREE( cmdList,cmdListCnt );
  if(fileLinesCnt > 0)    _LOOPFREE( fileLines,fileLinesCnt );
  
  if (traceFlag) {
    printf("<<** %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}

/*********************************************************
 *
 * Add a text item
 * finds the command and adds the item under that command
 *
 *********************************************************/
IGRstat VDfileAddItemToFile(IGRchar *item,
			    IGRchar *command,
			    IGRchar *fileName, 
			    IGRchar *filePPath)
{
  IGRstat retFlag = 0;
  VDASSERT_FN("VDfileAddItemToFile");
  IGRint    delOK = 1;
  IGRchar **fileLines,**cmdList,*tmp;
  IGRint    fileLinesCnt = 0,cmdListCnt = 0,cmdFound = -1;
  IGRchar  *p,buf[4096],buffer[4096];
  IGRint    i,start = 0,stop = 0,swaps = -1;
  
  // say hi
  if (traceFlag) {
    printf("**>> %s %s\n",ffn(),fn); 
  }

  /* args check */
  VDASSERTW(item);
  VDASSERTW(command);
  VDASSERTW(fileName);
  VDASSERTW(filePPath);
  /* init */
  buf[0] = '\0';
 
  if(traceFlag) printf("\n\n\tAdd Item[%s] to command[%s] \n\tin File[%s] [%s]\n\n",
		       item,command,fileName,filePPath);

  /* read the localFile  */
  vdio$ReadAnyFile(fileName  = fileName,
		   partPath  = filePPath,
		   fileLines = &fileLines,
		   lineCnt   = &fileLinesCnt);

  /* no lines no action */
  if(fileLinesCnt < 1) goto wrapup;
  

  /* clip out the commands */
  VDfileGetListCommands(command,
			&fileLines,
			&fileLinesCnt,
			&cmdList,
			&cmdListCnt,
			&cmdFound);
  if(traceFlag) printf("command is after VDfileGetListCommands [%s]\n",command);
  
  if(traceFlag){
    printf("\n\ncmdFound[%d] cmdListCnt[%d]\n",cmdFound,cmdListCnt);
    for(i = 0;i < cmdListCnt;i++) {
      printf("cmdList[%d] [%s]\n",i,cmdList[i]);
      
    }
    printf("\n\n");
    
  }
  

  /* check to see if the item is in the list (if yes, we are done) */
  if(cmdListCnt > 0) {
    if(VDfileIsStingInList(item,
			   cmdList,
			   cmdListCnt)) goto wrapup;
  }
  
  if(traceFlag) printf("tested item (not in list)[%s]\n",item);
  
  /* this is the case of needing to add the command */
  if(cmdFound < 0) {
    buf[0] = '\0';
    *p = '%';
    if(traceFlag) printf("buf[%s] command[%s]\n",buf,command);
    
    sprintf(buf,"\n%c %s\n",*p,command);
    /* add this guy  */
    if(traceFlag) printf("adding command[%s] to the file\n",buf);
    vdtvw$AddStrList(item    = buf,
		     List    = &fileLines,
		     ListCnt = &fileLinesCnt);  
  } 
  buf[0] = '\0';
  *p = '#';
  sprintf(buf,"%c %s\n",*p,item);
  /* add this guy  */
    if(traceFlag) printf("adding item[%s] to the file\n",buf);
  vdtvw$AddStrList(item    = buf,
		   List    = &fileLines,
		   ListCnt = &fileLinesCnt);
  /* 
   * we have a command already in the list so we need to move the
   * item up to its rightful place in the list 
   */
  if(cmdFound > -1) {
    start = cmdFound + 1;
    stop = fileLinesCnt -1;
    swaps = stop - start;
    if(swaps > 0) {
      /* do the swaps */
      for(i = stop;i > start;i--) {
	tmp = fileLines[i];
	fileLines[i] = fileLines[i -1];
	fileLines[i -1] = tmp;
      }
    }
  }
  if(fileLinesCnt > 0) {
    /* write the file */
  if(traceFlag) printf("\n\n%s %s:\nfileName[%s] filePPath[%s]\n",
		       ffn(),fn,fileName,filePPath);

    vdio$WriteAnyFile(fileName  = fileName,
		      partPath  = filePPath,
		      fileLines = fileLines,
		      lineCnt   = &fileLinesCnt);
  } 

  retFlag = 1;
  
wrapup:
  // say bye 
  if(cmdListCnt > 0)      _LOOPFREE( cmdList,cmdListCnt );
  if(fileLinesCnt > 0)    _LOOPFREE( fileLines,fileLinesCnt );
  
  if (traceFlag) {
    printf("<<** %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}


/*********************************************************
 *
 * Delete the File Filter in the gadget from the associated 
 * list 
 * there are 3 sources for the presentation list
 * [1] User current input 
 * [2] System input /software added on startup
 * [3] The local file
 * minimum of wildcard '*.* *' if all are removed 
 *
 *********************************************************/
IGRstat VDfileDeleteFileFilter(char    *form,
			       IGRint   gadget,
			       IGRchar *command,
			       IGRchar *localFile,
			       IGRchar *localPPath)
{
  IGRstat retFlag = 0;
  VDASSERT_FN("VDfileDeleteFileFilter");
  IGRint     row,rows,i,selFlag,pos;
  IGRchar    wildCard[128],buf[128],*p;
   
  
  // say hi
  if (traceFlag) {
    printf("**>> %s %s\n",ffn(),fn); 
  }

  /* args check */
  VDASSERTW(form);
  VDASSERTW(localFile);
  VDASSERTW(localPPath);
  VDASSERTW(command);
  if(gadget < 11) goto wrapup;
  if(!strcmp(command,"")) goto wrapup;
  if(!strcmp(localFile,"")) goto wrapup;

  /* first things first  read the gadget */
  VIg_get_text(form,gadget,wildCard);

  /* remove the text item from the file */
  VDfileRemoveItemFromFile(wildCard,
			   command,
			   localFile, 
			   localPPath);
  retFlag = 1;
  
wrapup:
  // say bye 
  if (traceFlag) {
    printf("<<** %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}
/*********************************************************
 *
 * Add the File Filter to the list storage 
 *
 *********************************************************/
IGRstat VDfileSaveFileFilter(char    *form,
			     IGRint   gadget,
			     IGRchar *command,
			     IGRchar *localFile,
			     IGRchar *localPPath)
{
  IGRstat retFlag = 0;
  VDASSERT_FN("VDfileSaveFileFilter");
  IGRchar  item[128];
   
       
  // say hi
  if (traceFlag) {
    printf("**>> %s %s\n",ffn(),fn); 
  }

  /* args check */
  VDASSERTW(form);
  VDASSERTW(localFile);
  VDASSERTW(localPPath);
  VDASSERTW(command);
  if(gadget < 11) goto wrapup;
  if(!strcmp(command,"")) goto wrapup;
  if(!strcmp(localFile,"")) goto wrapup;

  /* get the item from the gadget */
  VIg_get_text(form,gadget,item);
  
  /* check the item */
  if(!strcmp(item,"")) goto wrapup;

  /* add the item to the file */
  if(traceFlag) printf("item[%s]\ncommand[%s]\nlocalFile[%s]\nlocalPPath[%s]\n",
		       item,
		       command,
		       localFile, 
		       localPPath);
  VDfileAddItemToFile(item,
		      command,
		      localFile, 
		      localPPath);
  
  retFlag = 1;
  
wrapup:
  // say bye 
  if (traceFlag) {
    printf("<<** %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}

/*********************************************************
 *
 * Add the content of the file (list of filters) 
 * to the gadget 
 * (do not delete anybody just add these guys)
 * then clean up the gadget list (UniqueAUp)
 *
 *********************************************************/
IGRstat VDfileShowFileFilter(char    *form,
			     IGRint   gadget,
			     IGRint   mkFile,
			     IGRchar *command,
			     IGRchar *localFile,
			     IGRchar *localPPath)
{
  IGRstat retFlag = 0;
  VDASSERT_FN("VDfileShowFileFilter");
  IGRchar    **fileLines;
  IGRint       fileLinesCnt = 0;
  IGRchar    **cmdList;
  IGRint       cmdListCnt = 0;
  IGRint       cmdFound = -1;
  IGRint       i,row,rows,count,start,max,fileSts = 0,selFlag = 0;

   
  
  // say hi
  if (traceFlag) {
    printf("**>> %s %s\n",ffn(),fn); 
  }

  /* args check */
  VDASSERTW(form);
  VDASSERTW(localFile);
  VDASSERTW(localPPath);
  VDASSERTW(command);
  if(gadget < 11) goto wrapup;
  if(!strcmp(command,"")) goto wrapup;
  if(!strcmp(localFile,"")) goto wrapup;

  /* read the File */
  fileSts = vdio$ReadAnyFile(fileName  = localFile,
                             partPath  = localPPath,
                             fileLines = &fileLines,
                             lineCnt   = &fileLinesCnt);
  if(fileSts == 0) {
    if(traceFlag) printf("failed to open [%s]\n",localFile);
    if(mkFile == 0) goto wrapup;
    /* 
     * this case we need to write the file starting with a blank line 
     * and reread the new file 
     */
    if(traceFlag) printf("\n\n\ngoing to create [%s]\n\n",localFile);
    if(VDfileCreateLocalNewFile(localFile)) {
      fileSts = vdio$ReadAnyFile(fileName  = localFile,
				 partPath  = localPPath,
				 fileLines = &fileLines,
				 lineCnt   = &fileLinesCnt);
      if(fileSts == 0) goto wrapup;
    }
    

  }
  
  if(fileLinesCnt < 1) goto wrapup;
  
  cmdListCnt = 0;
  cmdFound = 0;

  /* clip out the commands */
  VDfileGetListCommands(command,
			&fileLines,
			&fileLinesCnt,
			&cmdList,
			&cmdListCnt,
			&cmdFound);
  if(cmdListCnt < 1) goto wrapup;
  if(cmdFound < 0) goto wrapup;
  
  /* get the number of rows in the gadget */
  FIfld_get_list_num_rows(form,gadget,0,&rows);
  start = rows;
  max = rows + cmdListCnt;

  /* loop through and add the list stuff */
  i = 0;
  for(row = start;row < max;row++) {
    FIfld_set_list_text( form,
			 gadget,  
			 row,
			 0,
			 (unsigned char *)cmdList[i],
			 selFlag ); 
    i++;
    if(i == cmdListCnt) break;
  }
  
  /* alphabetize the associated list flag (show text already in box) addItem (no) */
  vdtvw$FormMakeTextItemsUniqueAUp(form    = form,
				   gadget  = gadget,
				   flag    = 0,
				   addItem = 0);
  retFlag = 1;
  
wrapup:
  if(cmdListCnt > 0)  _LOOPFREE( cmdList,cmdListCnt );
  if(fileLinesCnt >0) _LOOPFREE( fileLines,fileLinesCnt );

  // say bye 
  if (traceFlag) {
    printf("<<** %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}
/*************************************************************
 *
 * Is the item in the associated list, display it
 * flag states:
 * 0   Display the item if found else the first item in the list
 * 1   Display only the item if found no change otherwise
 * -1  Display only the item if found blank otherwise.
 *
 **************************************************************/
IGRstat VDfileDisplayListItem(char    *form,
			      IGRint   gadget,
			      IGRchar *item,
			      IGRint   flag,
			      IGRchar *msg,
			      IGRint   msgGadget)
{
  IGRstat retFlag = 0;
  VDASSERT_FN("VDfileDisplayListItem");
  IGRint       row,rows,selFlag;
  IGRchar      buf[128];
  IGRint       success = 0;
   
    
  // say hi
  if (traceFlag) {
    printf("**>> %s %s\n",ffn(),fn); 
  }

  /* args check */
  if(gadget < 11) goto wrapup;
  VDASSERTW(form);
  VDASSERTW(item);

  /* checks */
  if(flag > 1) flag = 1;
  if(flag < -1) flag = -1;

  /* inits */
  buf[0] = '\0';
  if(traceFlag) printf("\n\nchecking [%s]\n\n",item);
  
 
  /* get the data on the number of rows */
  FIfld_get_list_num_rows(form, gadget, 0, &rows);
  /* if there is no associated list data to check */
  if(rows < 1) {
    /* no list and blank set */
    FIg_set_text(form,gadget,"");
    goto wrapup;
  }
  /* check the rows now */
  for(row = 0;row < rows;row++) {
   FIfld_get_list_text(form, gadget, row, 0, 80, (unsigned char *)buf, &selFlag); 
   if(traceFlag) printf("buf is[%s] item[%s]\n",buf,item);
   if(!strcmp(buf,item)) {
     if(traceFlag) printf("setting success == 1\n");
     success = 1;
     break;
   }
  }
  
  if(traceFlag) printf("the item success[%d]\n",success);

  /* if we found it */
  if(success == 1) {
    if(traceFlag) printf("we found the item in the list\n");
    FIg_set_text(form,gadget,item);
    if(msg) {
      FIg_set_text(form,msgGadget,msg);
    }
    retFlag = 1;
    goto wrapup;
  } 
  if(traceFlag) printf("we did not find the item\n");
  /* we did not find it */
  if(flag == 1) {
    retFlag = 1;
    goto wrapup;
  }
  if(flag == -1) {
    FIg_set_text(form,gadget,"");
    retFlag = 1;
    goto wrapup;
  }

  FIfld_get_list_text(form, gadget, 0, 0, 80, (unsigned char *)buf, &selFlag); 
  if(traceFlag) printf("buf[%s]\n",buf);
  FIg_set_text(form,gadget,buf);
  
  retFlag = 1;
wrapup:
  // say bye 
  if (traceFlag) {
    printf("<<** %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}
/*******************************************************
 *
 * clean item from associated list of a text gadget
 *
 *******************************************************/
IGRstat VDfileCleanItemFromList(char    *form,
				IGRint   gadget,
				IGRchar *item)
{
  IGRstat retFlag = 0;
  VDASSERT_FN("VDfileCleanItemFromList");
  IGRint       row,rows,selFlag;
  IGRchar      buf[1028],text[1028];
  IGRchar      **textList;
  IGRint       textListCnt = 0;
  IGRint       success = 0;

   
  
  // say hi
  if (traceFlag) {
    printf("**>> %s %s\n",ffn(),fn); 
  } 

 /* args check */	
  VDASSERTW(form);
  if(gadget < 11) goto wrapup;
  VDASSERTW(item);

  /* get the data on the number of rows */
  FIfld_get_list_num_rows(form, gadget, 0, &rows);  
  if(rows < 1) goto wrapup;
  
  /* loop through and fill up a text list excluding the item */
  for(row = 0;row < rows;row++) {
   FIfld_get_list_text(form, gadget, row, 0, 1028, (unsigned char *)buf, &selFlag);
   if(traceFlag) printf("item[%s] buf[%s]\n",item,buf);
   if(!(strcmp(item,buf))) continue;
   
     if(traceFlag) printf("adding buf[%s] to the textList\n",buf);
     vdtvw$AddStrListUnique(item    = buf,
			    List    = &textList,
			    ListCnt = &textListCnt); 
   
  }
  if(traceFlag) printf("textListCnt[%d]\n",textListCnt);
  
  /* protect the original text in the gadget */
  VIg_get_text(form,gadget,text);
  /* clean out the gadget */
  FIg_reset( form,gadget );
  /* fix the displayed text back in the box as is */
  VIg_set_text(form,gadget,text);
  
  if(textListCnt ==  0) goto wrapup;
  /* put the stuff back in the associated list */
  for(row = 0;row < textListCnt;row++) {
    if(traceFlag) printf("replacing [%s] in row[%d]\n",textList[row],row);
    FIfld_set_list_text( form,
			 gadget,
			 row,
			 0,
			 (unsigned char *)textList[row],
			 selFlag );
  }
  
  /* get the data on the number of rows */
  FIfld_get_list_num_rows(form, gadget, 0, &rows);  
  FIfld_set_num_rows( form, gadget,rows );
  retFlag = 1;
wrapup:
  
  if(textListCnt > 0) _LOOPFREE( textList,textListCnt);
  
  // say bye 
  if (traceFlag) {
    printf("<<** %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}
end implementation Root;



