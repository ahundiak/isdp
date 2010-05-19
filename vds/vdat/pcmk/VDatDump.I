/* $Id: VDatDump.I,v 1.1 2001/01/11 20:54:46 art Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdat/pcmk/VDatInfo2.I
 *
 * Description: Piece Mark Processing
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDatDump.I,v $
 *      Revision 1.1  2001/01/11 20:54:46  art
 *      sp merge
 *
# Revision 1.1  2000/11/27  19:35:18  pinnacle
# ah
#
# Revision 1.1  2000/06/27  17:34:38  pinnacle
# ah
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 03/28/00  ah      Creation
 ***************************************************************************/

class implementation Root;

#include "VDtypedef.h"
#include "VDatPcmk.h"

#include "VDsa.h"
#include "VDmem.h"
#include "VDobj.h"
#include "VDassert.h"

VDASSERT_FFN("vdat/pcmk/VDatDump.I");

#define DOIT 1

/* -----------------------------------------------
 * Dump the given set to a xml file and to
 * an internal blob object
 */
IGRstat VDatDumpPcmks(IGRchar *setName)
{
  VDASSERT_FN("VDatDumpPcmks");
  
  IGRstat retFlag = 0;
  IGRstat sts;
  
  TVDatPcmkInfos infos;
  TVDatPcmkInfo *info;
  
  TGRid   setID;
  TGRid   blobID;
  
  IGRchar buf[64];
  IGRchar blobName[64];
  IGRchar fileName[256];
  
  IGRint i;
  
  // Init
  VDatResetPcmkInfos(&infos);
  
  // Get the set
  VDASSERTW(setName);
  if (*setName == 0) goto wrapup;
  VDatGetSetByTypeName("StagingTree",setName,&setID);
  if (setID.objid == NULL_OBJID) {
    printf("*** Unable to get set for %s\n",setName);
    goto wrapup;
  }

  // Get the infos
  UI_status("Getting piece information ...");
  sts = VDatGetPcmkInfos(&setID,&infos);
  if (infos.infos == NULL) {
    printf("Problem getting list of piece mark information\n");
    goto wrapup;
  }
  if (!(sts & 1)) goto wrapup;

  // Fill in standard parts
  UI_status("Getting standard parts ...");
  sts = VDatGetStandardPcmkInfos(&infos);
  if (!(sts & 1)) goto wrapup;

  // Fill in attributes
  UI_status("Filling in attributes ...");
  sts = VDatGetPcmkAttrInfos(&infos);
  if (!(sts & 1)) goto wrapup;

  // Fill in notLike flag
  UI_status("Filling in not like ...");
  sts = VDatGetPcmkNotLikeInfos(&infos);
  if (!(sts & 1)) goto wrapup;

  // Sort them
  UI_status("Sorting ...");
  qsort(infos.infos,infos.cnt,sizeof(TVDatPcmkInfo),VDatSortPcmkInfo1);

  // XML Them
  sprintf(fileName,"%s_pcmk_02.xml",setName);
  sts = VDatWritePcmkInfosToXmlFile(fileName,&infos);
  if (!(sts & 1)) goto wrapup;

  // Get the blob
  sprintf(blobName,"%s_pcmk_02",setName);
  VDblobGetBlobObject(setID.osnum,blobName,&blobID);
  if (blobID.objid == NULL_OBJID) {
    VDblobCreateBlobObject(setID.osnum,blobName,&blobID);
  }
  VDASSERTW(blobID.objid != NULL_OBJID);
  
  // Load It
  VDblobLoadFromFile(&blobID,fileName);

  // Just for grins, save it again
  strcat(fileName,"x");
  VDblobSaveToFile(&blobID,fileName);
  
  // Done
  sprintf(buf,"Wrote %d items",infos.cnt);
  UI_status(buf);  
  retFlag = 1;
  
 wrapup:

  // Free the stuff
  VDatFreePcmkInfos(&infos);

  // Status
  if (!(retFlag & 1)) UI_status("Done");
  
  return retFlag;
}
#if 0
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
#endif

end implementation Root;
