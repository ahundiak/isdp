/* $Id: VDrrvAttr.c,v 1.6 2002/05/10 19:34:03 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdcty/rrv/VDrrvAttr.c
 *
 * Description: Attributes Utilities for Doom tree
 *
 * Dependencies:
 *
 * Revision History:
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 03/19/01  js      Creation
 ***************************************************************************/
#include "VDtypedefc.h"
#include "VDassert.h"

#include "VDctx.h"
#include "VDdoom.h"
#include "VDxml.h"
#include "VDrisc.h"
#include "VDpdm.h"
#include "VDss.h"
#include "VDDbDef.h"

#include "VDrrvCmd.h"


VDASSERT_FFN("vdcty/rrv/VDrrvAttr.c");

/* -----------------------------------------
 * Process purpose info attribute into purpInfo struct
 * **/
IGRstat VDrrvPurposeAttrToInfo(IGRchar           *attr,
                               TVDpdmPurposeInfo *info)
{
  VDASSERT_FN("VDrrvPurposeAttrToInfo");

  IGRstat retFlag = 0;

  IGRchar *p;
  IGRchar expText[256];
  IGRchab key;

  // Arg check
  VDASSERTW( (attr != NULL) && (*attr != 0) );
  VDASSERTW(info);
  memset(info,0,sizeof(TVDpdmPurposeInfo));
  strcpy(expText,attr);

  // do it
  p = strchr(expText,'|');
  if (p) {
    *p = 0;
    strcpy(key,expText);
    // info->filekey = atoi(key);
    strcpy(expText,p+1);
  }
  p = strchr(expText,'|');
  if (p) {
    *p = 0;
    strcpy(info->purpose,expText);
    strcpy(expText,p+1);
  }
  p = strchr(expText,'|');
  if (p) {
    *p = 0;
    strcpy(info->zone,expText);
    strcpy(expText,p+1);
  }
  p = strchr(expText,'|');
  if (p) {
    *p = 0;
    strcpy(info->unit,expText);
    strcpy(expText,p+1);
  }
  strcpy(info->system,expText);
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}


  
/* ------------------------------------------
 * Process pdm info attribute into pdm info struct
 * **/
IGRstat VDrrvPdmAttrToInfo(IGRchar    *attr,
                           TVDpdmInfo *info)
{
  VDASSERT_FN("VDrrvPdmAttrToInfo");

  IGRstat retFlag = 0;

  IGRchar *p;
  IGRchar expText[256];

  // Arg check
  VDASSERTW( (attr != NULL) && (*attr != 0) );
  VDASSERTW(info);
  memset(info,0,sizeof(TVDpdmInfo));
  strcpy(expText,attr);

  // do it
  p = strchr(expText,'|');
  if (p) {
    *p = 0;
    strcpy(info->catalog,expText);
    strcpy(expText,p+1);
  }
  p = strchr(expText,'|');
  if (p) {
    *p = 0;
    strcpy(info->part,expText);
    strcpy(expText,p+1);
  }
  p = strchr(expText,'|');
  if (p) {
    *p = 0;
    strcpy(info->rev,expText);
    strcpy(expText,p+1);
  }
  p = strchr(expText,'|');
  if (p) {
    *p = 0;
    strcpy(info->filename,expText);
    strcpy(expText,p+1);
  }
  info->filekey = atoi(expText);

  // done
  retFlag = 1;

wrapup:
  return retFlag;
}

  
/* -------------------------------------------
 * Get the purpose attribute
 * **/
static IGRstat getPurposeAttr(TGRid   *treeID,
                              VDosnum osnum,
                              IGRchar *attr)
{
  VDASSERT_FN("getPurposeAttr");
  IGRstat retFlag = 0;
  IGRstat sts;

  TVDpdmPurposeInfo purpInfo;
  TVDctxBaseInfo    baseInfo;
  IGRchab           purp;
  IGRchab           buf;

  // Arg check
  VDASSERTW(attr); *attr = 0;
  VDASSERTW(treeID->objid != NULL_OBJID);
  *purp = 0;

#if 0
  // try purpose from purpose info
  sts = VDpdmGetPurposeInfo(osnum,&purpInfo);
  if (sts) {
      retFlag = 1;
      strcpy(purp,"ss_");

      // unit
      if (*purpInfo.unit != 0) {
	  sprintf(buf,"unit_%s",purpInfo.purpose);
	  strcat(purp,buf);
	  strcpy(attr,purp);
	  goto wrapup;
      }
      
      // zone
      if (*purpInfo.zone != 0) {
	  sprintf(buf,"zone_%s",purpInfo.purpose);
	  strcat(purp,buf);
	  strcpy(attr,purp);
	  goto wrapup;
      }

      // system
      if (*purpInfo.system != 0) {
	  sprintf(buf,"sys_%s",purpInfo.purpose);
	  strcat(purp,buf);
	  strcpy(attr,purp);
	  goto wrapup;
      }
	  
  }
#endif
  // use setType from baseInfo
  VDctxGetBaseInfo(treeID,&baseInfo);
  if (*baseInfo.setType == 0) goto wrapup;

  strcpy(attr,baseInfo.setType);

  // done
  retFlag = 1;

wrapup:
  return retFlag;
}

/* -------------------------------------------
 * Get the purpose Info attribute
 * **/
static IGRstat getPurposeInfoAttr(VDosnum osnum,
                                  IGRchar *attr)
{
  VDASSERT_FN("getPurposeInfoAttr");
  IGRstat retFlag = 0;

  TVDpdmPurposeInfo info;
  IGRchab           purpText;

  // Arg check
  VDASSERTW(attr); *attr = 0;
  *purpText = 0;

  // get info
  VDpdmGetPurposeInfo(osnum,&info);
  if (*info.purpose == 0) goto wrapup;

  // build the attribute string
  sprintf(purpText,"%d|%s|%s|%s|%s",
	  -1,
          info.purpose,
	  info.zone,
          info.unit,
          info.system);

  strcpy(attr,purpText);

  // done
  retFlag = 1;

wrapup:
  return retFlag;
}

/* -------------------------------------------
 * Get the pdm Info attribute
 * **/
static IGRstat getPdmInfoAttr(VDosnum osnum,
                              IGRchar *attr)
{
  VDASSERT_FN("getPdmInfoAttr");
  IGRstat retFlag = 0;
  IGRstat sts;

  TVDpdmInfo info;
  IGRchab    pdmText;

  // Arg check
  VDASSERTW(attr); *attr = 0;
  *pdmText = 0;

  // get info
  sts = VDpdmGetPdmInfo(osnum,&info);
  if (!(sts & 1)) goto wrapup;

  // build the attribute string
  sprintf(pdmText,
	  "%s|%s|%s|%s|%d",
	  info.catalog,info.part,info.rev,info.filename,info.filekey);

  strcpy(attr,pdmText);

  // done
  retFlag = 1;

wrapup:
  return retFlag;
}

/* --------------------------------------------
 * Add attributes to a Dom tree
 * **/
void VDrrvAddAttrsToDomTree(TGRid  *treeID,
                            VDosnum osnum)
{
  VDASSERT_FN("VDrrvAddAttrsToDomTree");

  IGRchab  attr;

  TVDctxBaseInfo  info;

  // Arg Check
  VDASSERTW(treeID->objid != NULL_OBJID);
  VDASSERTW(osnum         != OM_K_NOT_AN_OS);

  // Start adding some attributes

  // Add date time stamp
  VDsysGetTimeStamp(attr);
  VDctxAppTxtAtr(treeID,VDCTX_ATR_SS_CREATION_TIMESTAMP,attr); 

  // Add Pdm Info attribute
  getPdmInfoAttr(osnum,attr);
  VDctxAppTxtAtr(treeID,VDCTX_ATR_SS_PDM_INFO,attr);
  
  // Add purpose Info attribute
  getPurposeInfoAttr(osnum,attr);
  VDctxAppTxtAtr(treeID,VDCTX_ATR_SS_PURPOSE_INFO,attr);
  
  // Add Purpose attribute
  getPurposeAttr(treeID,osnum,attr);
  VDctxAppTxtAtr(treeID,VDCTX_ATR_SS_PURPOSE,attr);
  
  // done
wrapup:
  return;
}
