/* $Id: VEpdfSetup.C,v 1.2 2001/02/20 15:20:13 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vexml/VExmlSetup.C
 *
 * Description: Setup Object Processing
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VEpdfSetup.C,v $
 *      Revision 1.2  2001/02/20 15:20:13  ahundiak
 *      ah
 *
 *      Revision 1.1.1.1  2001/01/04 21:09:32  cvs
 *      Initial import to CVS
 *
 * Revision 1.1  2000/03/31  17:06:38  pinnacle
 * ah
 *
 * Revision 1.1  2000/03/24  15:49:10  pinnacle
 * ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 03/14/00  ah      Creation
 *
 ***************************************************************************/

#include "VDtypedef.h"
#include "VDobj.h"
#include "VDvla.h"
#include "VDsa.h"
#include "VDppl1.h"

#include "VDxml.h"
#include "VDcvg.h"
#include "VEsms.h"

static int traceFlag;

/* -------------------------------------------------
 * Process setup object attributes
 */
static IGRstat VEpdfSetupFilterAttribute(TVEpdfSetup *info, TVDxmlParseInfo *parseInfo)
{
  IGRstat retFlag = 1;

  IGRchar  *etag = parseInfo->eleInfo.eleType;
  IGRchar   *tag = parseInfo->eleInfo.atrType;
  IGRchar *value = parseInfo->eleInfo.atrValue;
  
  // Setup object
  if (!strcmp( etag,XML_PDF_SETUP)) {

    if (!strcmp(tag,XML_PDF_SETUP_INTERNAL_UNITS)) 
      strcpy(info->internal_units,value);

    if (!strcmp(tag,XML_PDF_SETUP_DATE)) strcpy(info->date,value);

    if (!strcmp(tag,XML_PDF_SETUP_PDF_NAME))   {
      // VLsmsDxfFilterAttributeReplace(info->unitReal,info->unitTest,value);
      strcpy(info->pdf_name,value);
    }
    
    if (!strcmp(tag,XML_PDF_SETUP_FILE_NAME))  strcpy(info->file_name, value);
    if (!strcmp(tag,XML_PDF_SETUP_PDM_CAT))    strcpy(info->pdm_cat,   value);
    if (!strcmp(tag,XML_PDF_SETUP_PDM_PART))   strcpy(info->pdm_part,  value);
    if (!strcmp(tag,XML_PDF_SETUP_PDM_REV))    strcpy(info->pdm_rev,   value);
    if (!strcmp(tag,XML_PDF_SETUP_PDM_STATUS)) strcpy(info->pdm_status,value);
    goto wrapup;
  }

wrapup:
  return retFlag;
}

/* -------------------------------------------------
 * Start a new element
 */
static IGRstat VEpdfSetupFilterBegElement(TVEpdfSetup *info, TVDxmlParseInfo *parseInfo)
{
  IGRchar fn[] = "VEpdfSetupFilterBegElement";
  IGRstat retFlag = 1;
  
  IGRchar *tag = parseInfo->eleInfo.eleType;

  // Say hi
  if (traceFlag) printf(">>> %s %s\n",fn,tag);
  
  // Setup object
  if (!strcmp(tag,XML_PDF_SETUP)) {
    memset(info,0,sizeof(TVEpdfSetup));
    info->flag = 1;
    goto wrapup;
  }
  
wrapup:
  if (traceFlag) printf("<<< %s %d\n",fn,retFlag);
  return retFlag;
}

/* -------------------------------------------------
 * End an element
 */
static IGRstat VEpdfSetupFilterEndElement(TVEpdfSetup *info, TVDxmlParseInfo *parseInfo)
{
  IGRchar     fn[] = "VEpdfSetupFilterEndElement";
  IGRstat     retFlag = 1;

  IGRchar *tag = parseInfo->eleInfo.eleType;
  
  // Say hi
  if (traceFlag) printf(">>> %s %s\n",fn,tag);
  
  // Setup object
  if (!strcmp(tag,XML_PDF_SETUP)) {
    info->flag = 3;
    parseInfo->retFlag = 3; // Triggers parser exit
    
    // Done
    retFlag = 3;  // Clean exit
    goto wrapup;
    
  }
  
wrapup:
  
  return retFlag;
}

/* -------------------------------------------------
 * Callback traffic director
 */
static IGRstat VEpdfSetupFilterCallback(TVDxmlParseInfo *parseInfo)
{
  IGRchar fn[] = "VExmlSetupFilterCallback";
  
  TVEpdfSetup *info = parseInfo->data;
  
  //if (traceFlag) printf(">>> %s %d\n",fn,parseInfo->eleInfo.type);
  
  switch(parseInfo->eleInfo.type) {

  case VDXML_TYPE_BEG_ELEMENT:        
    return VEpdfSetupFilterBegElement(info,parseInfo);

  case VDXML_TYPE_END_ELEMENT:        
    return VEpdfSetupFilterEndElement(info,parseInfo);

  case VDXML_TYPE_ATTRIBUTE:          
    return VEpdfSetupFilterAttribute (info,parseInfo);

  }
  
  return 1;
}

/* -------------------------------------------------------
 * Load setup object from xml file
 */
IGRstat VEpdfSetupLoad(IGRchar *xmlFileName, TVEpdfSetup *info)
{
  IGRchar fn[] = "VEpdfSetupLoad";

  IGRstat retFlag = 0;
  IGRstat sts;
  
  TVDxmlParseInfo parseInfo;

  // Say hi
  //traceFlag = 1;
  if (traceFlag) printf(">>> %s %s\n",fn,xmlFileName);
  
  // Init the data structures
  if (info == NULL) goto wrapup;
  memset(info,0,sizeof(TVEpdfSetup));

  // Arg check
  if (xmlFileName == NULL) goto wrapup;
  
  // All the real work
  sts = VDxmlParseFile(&parseInfo,xmlFileName,VEpdfSetupFilterCallback,info);
  if (!(sts & 1)) goto wrapup;
  
  // Done
  retFlag = 1;
  
wrapup:

  if (traceFlag) printf("<<< %s %d\n",fn,retFlag);
  
  return retFlag;
}




