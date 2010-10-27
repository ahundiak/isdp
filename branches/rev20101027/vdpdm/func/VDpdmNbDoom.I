/* $Id: VDpdmNbDoom.I,v 1.1 2001/10/03 13:53:13 jdsauby Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vds/vdpdm/func/VDpdmNbDoom.I
 *
 * Description: DOM - OM Object Notebook Routines
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDpdmNbDoom.I,v $
 *      Revision 1.1  2001/10/03 13:53:13  jdsauby
 *      JTS MP CR5448, Database Notebooks
 *
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 09/25/01  js      Creation
 ***************************************************************************/

class implementation Root;

#include "VDtypedef.h"
#include "VDassert.h"
#include "VDlog.h"

#include "sys/types.h"
#include "sys/stat.h"

#include "VDdir.h"
#include "VDobj.h"
#include "VDctx.h"
#include "VDdoom.h"
#include "VDtest.h"

VDASSERT_FFN("VDpdmNbDoom.I");

from GRgraphics import GRputname;

from VDbuf import vdbufSetData;
from VDbuf import vdbufGetData;

extern VDclassid OPP_VDbufMacro_class_id;

/* -----------------------------------------------
 * For a given osnum, generate a path
 */
IGRstat VDpdmGetDoomNbPathOS(VDosnum getOS, IGRchar *path)
{
  VDASSERT_FN("VDpdmGetDoomNbPathOS");
  IGRstat retFlag = 0;
  
  VDosnum currentOS;
  IGRchar pathx[DI_PATH_MAX];
  
  // Arg check
  VDASSERTW(path); *path = 0;
  
  // Grab the current os
  ex$get_cur_mod(osnum = &currentOS);
  
  // Allow for non-specified os
  if (getOS == OM_K_NOT_AN_OS) getOS = currentOS;
  
  // Always start in current file
  di$give_pathname(osnum = currentOS, pathname = path);
  VDASSERTW(*path);
  
  // Might be in a reference file
  if (getOS != currentOS) {
    di$give_pathname(osnum = getOS, pathname = pathx);
    VDASSERTW(*pathx);
    DIstrcpy(path,pathx);
  }
  
  // Add on actual path
  DIstrcat(path,"VDNbDooms");

  // Done
  retFlag = 1;
  
wrapup:
  if (retFlag != 1) *path = 0;
  return retFlag;
}

/* -----------------------------------------------
 * Get an existing doom object
 */
IGRstat VDpdmGetDoomNbObjectByNameOS(VDosnum osnum, IGRchar *name, TGRid *doomID)
{
  
  VDASSERT_FN("VDpdmGetDoomNbObjectByNameOS");
  IGRstat retFlag = 0;
  IGRstat sts,msg;
  
  IGRchar path[DI_PATH_MAX];
  
  // Arg check
  VDASSERTW(doomID); doomID->objid = NULL_OBJID;
  VDASSERTW(name && *name);

  
  // Pick os
  if (osnum == OM_K_NOT_AN_OS) ex$get_cur_mod(osnum = &osnum);
  doomID->osnum = osnum;

  // Generate path
  VDpdmGetDoomNbPathOS(osnum,path);
  VDASSERTW(*path);

  DIstrcat(path,name); 
  

  // Get it
  di$translate(objname = path, p_objid = &doomID->objid);
  if (doomID->objid != NULL_OBJID) {
    retFlag = 1;
    goto wrapup;
  }

  // Not found
  retFlag = 0;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Create an empty doom object
 */
IGRstat VDpdmCreateDoomNbObjectOS(VDosnum osnum, IGRchar *a_name, TGRid *doomID)
{
  VDASSERT_FN("VDpdmCreateDoomNbObjectOS");
  IGRstat retFlag = 0;
  IGRstat sts,msg;
  
  IGRchar path1[DI_PATH_MAX];
  IGRchar path2[DI_PATH_MAX];
  IGRchar name [DI_PATH_MAX];

  TGRid doomIDx;
  
  // Arg check
  VDASSERTW(doomID); doomID->objid = NULL_OBJID;
  VDASSERTW(a_name);

  // Pick os
  if (osnum == OM_K_NOT_AN_OS) ex$get_cur_mod(osnum = &osnum);
  doomID->osnum = osnum;

#if 0
  // Optional name
  if (a_name == NULL) VDdoomGetNextNameOS(osnum,name);
  else {
    // Make sure it's not a dup
    strcpy(name,a_name);
    VDdoomGetDoomObjectByNameOS(osnum,name,&doomIDx);
    VDASSERTW(doomIDx.objid == NULL_OBJID);
  }
#endif
    
  strcpy(name,a_name);
  VDASSERTW(*name);

  // Create it
  om$construct(classid = OPP_VDbufMacro_class_id,
               osnum   =  osnum,
               p_objid = &doomID->objid);
  VDASSERTW(doomID->objid != NULL_OBJID);
  
  // Name it
  VDpdmGetDoomNbPathOS(osnum,path1);
  VDASSERTW(*path1);

  di$mkdir(dirname = path1);
  di$pwd  (dirname = path2);
  di$cd   (dirname = path1);

  om$send(msg = message GRgraphics.GRputname(&msg,name),
	  senderid = NULL_OBJID,
	  targetid = doomID->objid,
	  targetos = doomID->osnum);

  di$cd(dirname = path2);

  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Get the nth object
 */
IGRstat VDpdmGetNthDoomNbObjectOS(VDosnum osnum, IGRint nth, TGRid *doomID)
{
  VDASSERT_FN("VDpdmGetNthDoomNbObjectOS");

  IGRstat retFlag = 0;
  
  IGRchar path[DI_PATH_MAX];
  
  DIgrid *doomIDs = NULL;
  IGRint  cnt;

  // Arg check
  VDASSERTW(doomID); doomID->objid = NULL_OBJID;
  VDASSERTW(nth >= 0);
  
  // get the os
  if (osnum == OM_K_NOT_AN_OS) ex$get_cur_mod(osnum = &osnum);
  
  // Get the search path
  VDpdmGetDoomNbPathOS(osnum,path);
  DIstrcat(path,"*");

  // List
  di$dump(regexp = path, grids = &doomIDs, ptr = &cnt);
  
  if (nth >= cnt) goto wrapup;
  
  // Xfer
  doomID->osnum = doomIDs[nth].osnum;
  doomID->objid = doomIDs[nth].objid;

  // Done
  retFlag = 1;
  
wrapup:

  if (doomIDs) free(doomIDs);

  return retFlag;
}

/* -----------------------------------------------
 * Count the dooms
 */
void VDpdmGetDoomNbCntOS(VDosnum osnum, IGRint *cnt)
{
  VDASSERT_FN("VDpdmGetDoomNbCntOS");

  IGRstat retFlag = 0;
  
  IGRchar path[DI_PATH_MAX];
  
  // Arg check
  VDASSERTW(cnt); *cnt = 0;
  
  // get the os
  if (osnum == OM_K_NOT_AN_OS) ex$get_cur_mod(osnum = &osnum);
  
  // Get the search path
  VDpdmGetDoomNbPathOS(osnum,path);
  DIstrcat(path,"*");
  
  // List
  di$dump(regexp = path, ptr = cnt);
  
  // Done
  
wrapup:

  return;
}

/* -----------------------------------------------
 * List the doom objects
 */
IGRstat VDpdmListDoomNbObjectsOS(VDosnum osnum)
{
  VDASSERT_FN("VDpdmListDoomNbObjectsOS");

  IGRstat retFlag = 0;
  
  IGRchar path[DI_PATH_MAX];
  IGRchar name[DI_PATH_MAX];
  
  DIgrid *doomIDs = NULL;
  IGRint  cnt,i;
  IGRint  num;
  IGRchar *p;
  
  TGRid  doomID;
  IGRint nth;
  
  // get the os
  if (osnum == OM_K_NOT_AN_OS) ex$get_cur_mod(osnum = &osnum);
  
  // Cycle through
  for(i = 0; VDpdmGetNthDoomNbObjectOS(osnum,i,&doomID); i++) {

    // The name
    VDobjGetName(NULL,&doomID,name);

    // Pull out macro number
    for(p = name; (*p) && ((*p < '1') || (*p > '9')); p++);
    if (p) num = atoi(p);
    else   num = 0;
    
    printf("%2d %s %2d\n",i,name,num);
 
  }
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}
#if 0
/* -----------------------------------------------
 * Generate the next name by checking all the macros
 * and using the next available number
 */
IGRstat VDdoomGetNextNameOS(VDosnum osnum, IGRchar *a_name)
{
  VDASSERT_FN("VDdoomGetNextNameOS");

  IGRstat retFlag = 0;
  
  IGRchar path[DI_PATH_MAX];
  IGRchar name[DI_PATH_MAX];
  
  DIgrid *doomIDs = NULL;
  IGRint  cnt,i;
  IGRint  num;
  IGRint  max = 0;
  IGRchar *p;
  
  TGRid doomID;

  // Arg check
  VDASSERTW(a_name); *a_name = 0;
  
  // get the os
  if (osnum == OM_K_NOT_AN_OS) ex$get_cur_mod(osnum = &osnum);
  
  // Get the path
  VDdoomGetDoomPathOS(osnum,path);
  DIstrcat(path,"doom*");
  
  // List
  di$dump(regexp = path, grids = &doomIDs, ptr = &cnt);
  
  for(i = 0; i < cnt; i++) {
    doomID.osnum = doomIDs[i].osnum;
    doomID.objid = doomIDs[i].objid;
    VDobjGetName(NULL,&doomID,name);

    // Pull out macro number
    for(p = name; (*p) && ((*p < '1') || (*p > '9')); p++);
    if (p) num = atoi(p);
    else   num = 0;
    
    if (num > max) max = num;
    
  }
  
  // Free up
  if (doomIDs) free(doomIDs);
  doomIDs = NULL;

  // Use next one
  max++;
  sprintf(a_name,"doom%04d",max);
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}
#endif
#if 0
/* -----------------------------------------------
 * Wrapper to get the internal data pointer
 * Careful, it returns the actual instance data pointer
 */
IGRstat VDdoomGetData(TGRid *doomID, IGRint *dataLen, IGRchar **data)
{
  
  VDASSERT_FN("VDdoomGetData");
  IGRstat retFlag = 0;
  IGRstat sts;

  IGRchar *buf  = NULL;
  IGRint   len;
  
  // Arg check
  if (dataLen) *dataLen = 0;
  if (data)    *data = NULL;

  VDASSERTW(doomID && (doomID->objid != NULL_OBJID));
  
  // Get the buffer pointer
  sts = om$send(msg = message VDbuf.vdbufGetData(1,0,0,&len,NULL,&buf),
		senderid = NULL_OBJID,
		targetid = doomID->objid,
		targetos = doomID->osnum);
  VDASSERTW(sts & 1);
  
  // Transfer
  if (dataLen) *dataLen = len;
  if (data)    *data    = buf;
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Wrapper to set internal data
 * a len of -1 assumes NULL terminsted string
 */
IGRstat VDdoomSetData(TGRid *doomID, IGRint dataLen, IGRchar *data)
{
  
  VDASSERT_FN("VDdoomGetData");
  IGRstat retFlag = 0;
  IGRstat sts;

  // Arg check
  VDASSERTW(data);
  if (dataLen < 0) dataLen = strlen(data) + 1;
  VDASSERTW(doomID && (doomID->objid != NULL_OBJID));
  
  // Get the buffer pointer
  sts = om$send(msg = message VDbuf.vdbufSetData(1,0,dataLen,data),
		senderid = NULL_OBJID,
		targetid = doomID->objid,
		targetos = doomID->osnum);
  VDASSERTW(sts & 1);

  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Store contents of a file in a doom object
 * Flag controls the NULL termination
 * mode == 0 means to NULL terminate
 */
IGRstat VDdoomLoadFile(IGRint mode, TGRid *doomID, IGRchar *fileName)
{
  VDASSERT_FN("VDdoomLoadFile");
  IGRstat retFlag = 0;
  IGRstat sts;

  IGRchar *buf  = NULL;
  FILE    *file = NULL;
  
  IGRint len;
  IGRint lenx;
  
  struct stat fileStat;

  // Arg check
  VDASSERTW(doomID && (doomID->objid != NULL_OBJID));
  VDASSERTW(fileName && *fileName);
  
  // Need to know file size
  fileStat.st_size = 0;
  stat(fileName,&fileStat);
  len = fileStat.st_size;
  if (len < 1) goto wrapup;

  // Make sure we can open it
  file = fopen(fileName,"rb");
  VDASSERTW(file);
  
  // Make the buffer
  if (mode == 0) lenx = len + 1;
  else           lenx = len;
  buf = malloc(lenx);
  VDASSERTW(buf);
  
  // Fill it
  sts = fread(buf,len,1,file);
  if (sts != 1) {
    printf("*** Problem reading %s\n",fileName);
    goto wrapup;
  }
  fclose(file);
  file = NULL;

  // Null terminate
  if (mode == 0) *(buf+len) = 0;
  
  // Store it
  sts = om$send(msg = message VDbuf.vdbufSetData(1,0,lenx,buf),
		senderid = NULL_OBJID,
		targetid = doomID->objid,
		targetos = doomID->osnum);
  VDASSERTW(sts & 1);
  
  // Done
  retFlag = 1;
  
 wrapup:

  // Clean up
  if (file) fclose(file);
  if (buf)  free(buf);
  
  return retFlag;
}

/* -----------------------------------------------
 * Dump to a file
 */
IGRstat VDdoomSaveFile(IGRint mode, TGRid *doomID, IGRchar *fileName)
{
  VDASSERT_FN("VDdoomSaveFile");
  IGRstat retFlag = 0;
  IGRstat sts;

  IGRchar *buf  = NULL;
  FILE    *file = NULL;

  IGRint len;
  
  // Arg check
  VDASSERTW(doomID && (doomID->objid != NULL_OBJID));
  VDASSERTW(fileName && *fileName);

  // Get the buffer pointer
  sts = om$send(msg = message VDbuf.vdbufGetData(1,0,0,&len,NULL,&buf),
		senderid = NULL_OBJID,
		targetid = doomID->objid,
		targetos = doomID->osnum);
  VDASSERTW(sts & 1);

  // Drop the NULL
  if (mode == 0) {  
    if ((len) && (*(buf+len-1) == 0)) len--;
  }

  // Open and write
  file = fopen(fileName,"wb");
  VDASSERTW(file);
  
  sts = fwrite(buf,len,1,file);
  VDASSERTW(sts == 1);
  
  // Done
  retFlag = 1;
  
 wrapup:
  if (file) fclose(file);
  
  return retFlag;
}

/* -----------------------------------------------
 * Create a doom object from a tree
 */
void VDdoomCreateFromTree(TGRid *treeID, TGRid *doomID)
{
  VDASSERT_FN("VDdoomCreateFromTree");
  IGRstat retFlag = 0;
  IGRstat sts;
  
  IGRchar *bufXml = NULL;
  
  // Arg check
  VDASSERTW(doomID);  doomID->objid  = NULL_OBJID;
  VDASSERTW(treeID && treeID->objid != NULL_OBJID);
  
  // Convert to xml
  VDctxSaveTreeToXmlBuf(treeID, &bufXml);
  VDASSERTW(bufXml);
  // printf("%s\n",bufXml);
  
  // Store in doom
  VDdoomCreateDoomObject(NULL,doomID);
  VDASSERTW(doomID->objid != NULL_OBJID);
  sts = VDdoomSetData(doomID,-1,bufXml);
  VDASSERTW(sts == 1);
  
  // Done
  
 wrapup:
  if (bufXml) free(bufXml);
  
  return;
}

#define VDDOOM_TEST_STR "This is the initial test\nString For Doom\n"

/* -----------------------------------------------
 * Simple test for empty file
 */
void VDtestDoom(TVDtestTestInfo *testInfo)
{
  VDASSERT_FN("VDtestDoom");
  
  IGRstat sts;

  TGRid   doomID;
  
  TGRid   doomID0;
  TGRid   doomID1;
  TGRid   doomID2;
  TGRid   doomID3;
  TGRid   doomID4;
  IGRint  i;
  
  IGRchar name[256];
  IGRchar *buf;
  IGRint  len;
  IGRint  lenx;

  // Check the path
  VDdoomGetDoomPath(name);
  VDASSERTW(!strcmp(name,":test_doom.m:usr:dooms"));
  
  // Create some
  VDdoomCreateDoomObject("doom0001",&doomID);
  VDdoomCreateDoomObject("doom0002",&doomID);
  VDdoomCreateDoomObject("doom0073",&doomID);
  VDdoomCreateDoomObject(NULL,      &doomID);

  // Get em
  VDdoomGetNthObject(0,&doomID0);
  VDdoomGetNthObject(1,&doomID1);
  VDdoomGetNthObject(2,&doomID2);
  VDdoomGetNthObject(3,&doomID3);
  VDdoomGetNthObject(4,&doomID4);

  VDASSERTW(doomID0.objid != NULL_OBJID);
  VDASSERTW(doomID1.objid != NULL_OBJID);
  VDASSERTW(doomID2.objid != NULL_OBJID);
  VDASSERTW(doomID3.objid != NULL_OBJID);
  VDASSERTW(doomID4.objid == NULL_OBJID);

  VDobjGetName(NULL,&doomID0,name); VDASSERTW(!strcmp(name,"doom0001"));
  VDobjGetName(NULL,&doomID1,name); VDASSERTW(!strcmp(name,"doom0002"));
  VDobjGetName(NULL,&doomID2,name); VDASSERTW(!strcmp(name,"doom0073"));
  VDobjGetName(NULL,&doomID3,name); VDASSERTW(!strcmp(name,"doom0074"));

  // Set and get some data
  sts = VDdoomSetData(&doomID1,-1,VDDOOM_TEST_STR);
  VDASSERTW(sts == 1);
  lenx = strlen(VDDOOM_TEST_STR) + 1;
  
  sts = VDdoomGetData(&doomID1,&len,&buf);
  VDASSERTW(sts == 1);
  VDASSERTW(len == lenx);
  VDASSERTW(buf);
  VDASSERTW(!strcmp(buf,VDDOOM_TEST_STR));

  // Save/Load file
  sts = VDdoomSaveFile(0,&doomID1,"doom.txt");
  VDASSERTW(sts == 1);
  sts = VDdoomLoadFile(0,&doomID3,"doom.txt");
  VDASSERTW(sts == 1);

  sts = VDdoomGetData(&doomID3,&len,&buf);
  VDASSERTW(sts == 1);
  VDASSERTW(len == lenx);
  VDASSERTW(buf);
  VDASSERTW(!strcmp(buf,VDDOOM_TEST_STR));
  
  // Worked
  testInfo->worked = 1;
  
wrapup:
  return;
}
#endif
      
end implementation Root;
