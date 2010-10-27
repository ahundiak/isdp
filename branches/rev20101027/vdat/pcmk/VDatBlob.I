/* $Id: VDatBlob.I,v 1.1 2001/01/11 20:54:46 art Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdat/pcmk/VDatBlob.I
 *
 * Description: More Blob Routines
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDatBlob.I,v $
 *      Revision 1.1  2001/01/11 20:54:46  art
 *      sp merge
 *
# Revision 1.1  2000/11/27  19:35:18  pinnacle
# ah
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 03/28/00  ah      Creation
 ***************************************************************************/

class implementation Root;

#include "VDtypedef.h"
#include "sys/types.h"
#include "sys/stat.h"

#include "VDatPcmk.h"

#include "VDsa.h"
#include "VDmem.h"
#include "VDobj.h"
#include "VDdir.h"
#include "VDxml.h"

#include "VDassert.h"

VDASSERT_FFN("vdat/pcmk/VDatBlob.I");

extern VDclassid OPP_VDbufMacro_class_id;

from GRgraphics import GRputname;

from VDbuf import vdbufSetData;
from VDbuf import vdbufGetData;

/* -----------------------------------------------
 * Wrapper to get the internal data pointer
 */
IGRstat VDblobGetBlobData(TGRid *blobID, IGRint *dataLen, IGRchar **data)
{
  
  VDASSERT_FN("VDblobGetBlobData");
  IGRstat retFlag = 0;
  IGRstat sts;

  IGRchar *buf  = NULL;
  IGRint   len;
  
  // Arg check
  VDASSERTW(dataLen);
  *dataLen = 0;
  VDASSERTW(data);
  *data = 0;
  VDASSERTW(blobID && (blobID->objid != NULL_OBJID));
  
  // Get the buffer pointer
  sts = om$send(msg = message VDbuf.vdbufGetData(1,0,0,&len,NULL,&buf),
		senderid = NULL_OBJID,
		targetid = blobID->objid,
		targetos = blobID->osnum);
  VDASSERTW(sts & 1);

  // Transfer
  *dataLen = len;
  *data = buf;
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Dump the null terminated blob object
 */
IGRstat VDblobSaveToFile(TGRid *blobID, IGRchar *fileName)
{
  VDASSERT_FN("VDblobSaveToFile");
  IGRstat retFlag = 0;
  IGRstat sts;

  IGRchar *buf  = NULL;
  FILE    *file = NULL;

  IGRint len;
  
  // Arg check
  VDASSERTW(blobID && (blobID->objid != NULL_OBJID));
  VDASSERTW(fileName && *fileName);

  // Get the buffer pointer
  sts = om$send(msg = message VDbuf.vdbufGetData(1,0,0,&len,NULL,&buf),
		senderid = NULL_OBJID,
		targetid = blobID->objid,
		targetos = blobID->osnum);
  VDASSERTW(sts & 1);

  if ((len) && (*(buf+len-1) == 0)) len--;
  
  // printf("Buffer Length %d\n",len);

  file = fopen(fileName,"wb");
  if (file == NULL) {
    printf("*** Unable to open %s for writing blob\n",fileName);
    goto wrapup;
  }
  sts = fwrite(buf,len,1,file);
  fclose(file);
  VDASSERTW(sts == 1);
  
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Store contents of a file in a blob object
 * Not sure yet if we should NULL terminate or not
 * Probably best if we do
 */
IGRstat VDblobLoadFromFile(TGRid *blobID, IGRchar *fileName)
{
  VDASSERT_FN("VDblobLoadFromFile");
  IGRstat retFlag = 0;
  IGRstat sts;

  IGRchar *buf  = NULL;
  FILE    *file = NULL;
  
  IGRint len;
  
  struct stat fileStat;

  // Arg check
  VDASSERTW(blobID && (blobID->objid != NULL_OBJID));
  VDASSERTW(fileName && *fileName);
  
  // Need to know file size
  fileStat.st_size = 0;
  stat(fileName,&fileStat);
  len = fileStat.st_size;
  if (len < 1) {
    goto wrapup;
  }
  // printf("File Size %s %d\n",fileName,len);

  // Make sure we can open it
  file = fopen(fileName,"rb");
  VDASSERTW(file);
  
  // Make the buffer
  buf = malloc(len+1);
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
  *(buf+len) = 0;
  
  // Store it
  sts = om$send(msg = message VDbuf.vdbufSetData(1,0,len+1,buf),
		senderid = NULL_OBJID,
		targetid = blobID->objid,
		targetos = blobID->osnum);
  VDASSERTW(sts & 1);

  // Free buffer
  free(buf);
  buf = NULL;
  
  // Done
  retFlag = 1;
  
 wrapup:

  // Clean up
  if (file) fclose(file);
  if (buf)  free(buf);
  
  return retFlag;
}

/* -----------------------------------------------
 * Get an existing blob object
 */
IGRstat VDblobGetBlobObject(TVDosnum osnum, IGRchar *name, TGRid *blobID)
{
  
  VDASSERT_FN("VDblobCreateBlobObject");
  IGRstat retFlag = 0;
  IGRstat sts,msg;
  
  IGRchar path [DI_PATH_MAX];
  IGRchar pathx[DI_PATH_MAX];
  
  // Arg check
  VDASSERTW(blobID);
  blobID->objid = NULL_OBJID;
  VDASSERTW(name && *name);
  
  // Pick os
  if (osnum == OM_K_NOT_AN_OS) ex$get_cur_mod(osnum = &osnum);
  blobID->osnum = osnum;

  // Generate path
  di$give_pathname(osnum = osnum, pathname = path);
  DIstrcat(path,"usr");
  DIstrcat(path,"blobs"); 
  DIstrcat(path,name); 
  
  // Get it
  di$translate(objname = path, p_objid = &blobID->objid);
  if (blobID->objid != NULL_OBJID) {
    retFlag = 1;
    goto wrapup;
  }
  
  // Might be in a reference file
  ex$get_cur_mod  (osnum = &osnum);
  di$give_pathname(osnum =  osnum, pathname = pathx);
  DIstrcat(pathx,"ref");
  DIstrcat(pathx,path);

  di$translate(objname = pathx, p_objid = &blobID->objid);
  if (blobID->objid != NULL_OBJID) {
    retFlag = 1;
    goto wrapup;
  }

  // Not found
  retFlag = 0;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Create an empty blob object
 */
IGRstat VDblobCreateBlobObject(TVDosnum osnum, IGRchar *name, TGRid *blobID)
{
  VDASSERT_FN("VDblobCreateBlobObject");
  IGRstat retFlag = 0;
  IGRstat sts,msg;
  
  IGRchar path [DI_PATH_MAX];
  IGRchar pathx[DI_PATH_MAX];

  TGRid blobIDx;
  
  // Arg check
  VDASSERTW(blobID);
  blobID->objid = NULL_OBJID;
  VDASSERTW(name && *name);

  // Make sure we don't already have one
  VDblobGetBlobObject(osnum,name,&blobIDx);
  VDASSERTW(blobIDx.objid == NULL_OBJID);
  
  // Pick os
  if (osnum == OM_K_NOT_AN_OS) ex$get_cur_mod(osnum = &osnum);
  blobID->osnum = osnum;

  // Create it
  om$construct(classid = OPP_VDbufMacro_class_id,
               osnum   =  osnum,
               p_objid = &blobID->objid);
  VDASSERTW(blobID->objid != NULL_OBJID);
  
  // Name it
  di$give_pathname(osnum = osnum, pathname = path);
  DIstrcat(path,"usr");
  DIstrcat(path,"blobs");    
  di$mkdir(dirname = path);

  di$pwd(dirname = pathx);
  di$cd (dirname = path);

  om$send(msg = message GRgraphics.GRputname(&msg,name),
	  senderid = NULL_OBJID,
	  targetid = blobID->objid,
	  targetos = blobID->osnum);

  di$cd (dirname = pathx);

  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

end implementation Root;
