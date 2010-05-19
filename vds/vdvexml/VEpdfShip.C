/* $Id: VEpdfShip.C,v 1.2 2001/02/20 15:20:13 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vexml/VExmlShip.C
 *
 * Description: Ship Object Processing
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VEpdfShip.C,v $
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
 * Process ship object attributes
 */
static IGRstat VEpdfShipFilterAttribute(TVEpdfShip *info, TVDxmlParseInfo *parseInfo)
{
  IGRstat retFlag = 1;

  IGRchar  *etag = parseInfo->eleInfo.eleType;
  IGRchar   *tag = parseInfo->eleInfo.atrType;
  IGRchar *value = parseInfo->eleInfo.atrValue;
  
  // Ship object
  if (!strcmp( etag,XML_PDF_SHIP)) {
    if (!strcmp(tag,XML_PDF_SHIP_NAME))       strcpy(info->name,      value);
    if (!strcmp(tag,XML_PDF_SHIP_OWNER))      strcpy(info->owner,     value);
    if (!strcmp(tag,XML_PDF_SHIP_HULL))       strcpy(info->hull,      value);
    if (!strcmp(tag,XML_PDF_SHIP_HULL_APP))   strcpy(info->hull_app,  value);
    if (!strcmp(tag,XML_PDF_SHIP_DIMENSIONS)) strcpy(info->dimensions,value);

    if (!strcmp(tag,XML_PDF_SHIP_GLOBAL_COORD_SYSTEM)) 
      strcpy(info->global_coord_system,value);

    if (!strcmp(tag,XML_PDF_SHIP_FWD_PERPENDICULAR))   
      strcpy(info->fwd_perpendicular,value);

    goto wrapup;    
  }

wrapup:
  return retFlag;
}

/* -------------------------------------------------
 * Start a new element
 */
static IGRstat VEpdfShipFilterBegElement(TVEpdfShip *info, TVDxmlParseInfo *parseInfo)
{
  IGRchar fn[] = "VEpdfShipFilterBegElement";
  IGRstat retFlag = 1;
  
  IGRchar *tag = parseInfo->eleInfo.eleType;

  // Say hi
  if (traceFlag) printf(">>> %s %s\n",fn,tag);
  
  // Ship object
  if (!strcmp(tag,XML_PDF_SHIP)) {
    memset(info,0,sizeof(TVEpdfShip));
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
static IGRstat VEpdfShipFilterEndElement(TVEpdfShip *info, TVDxmlParseInfo *parseInfo)
{
  IGRchar     fn[] = "VEpdfShipFilterEndElement";
  IGRstat     retFlag = 1;

  IGRchar *tag = parseInfo->eleInfo.eleType;
  
  // Say hi
  if (traceFlag) printf(">>> %s %s\n",fn,tag);
  
  // Ship object
  if (!strcmp(tag,XML_PDF_SHIP)) {
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
static IGRstat VEpdfShipFilterCallback(TVDxmlParseInfo *parseInfo)
{
  IGRchar fn[] = "VExmlShipFilterCallback";
  
  TVEpdfShip *info = parseInfo->data;
  
  //if (traceFlag) printf(">>> %s %d\n",fn,parseInfo->eleInfo.type);
  
  switch(parseInfo->eleInfo.type) {

  case VDXML_TYPE_BEG_ELEMENT:        
    return VEpdfShipFilterBegElement(info,parseInfo);

  case VDXML_TYPE_END_ELEMENT:        
    return VEpdfShipFilterEndElement(info,parseInfo);

  case VDXML_TYPE_ATTRIBUTE:          
    return VEpdfShipFilterAttribute (info,parseInfo);

  }
  
  return 1;
}

/* -------------------------------------------------------
 * Load ship object from xml file
 */
IGRstat VEpdfShipLoad(IGRchar *xmlFileName, TVEpdfShip *info)
{
  IGRchar fn[] = "VEpdfShipLoad";

  IGRstat retFlag = 0;
  IGRstat sts;
  
  TVDxmlParseInfo parseInfo;

  // Say hi
  //traceFlag = 1;
  if (traceFlag) printf(">>> %s %s\n",fn,xmlFileName);
  
  // Init the data structures
  if (info == NULL) goto wrapup;
  memset(info,0,sizeof(TVEpdfShip));

  // Arg check
  if (xmlFileName == NULL) goto wrapup;
  
  // All the real work
  sts = VDxmlParseFile(&parseInfo,xmlFileName,VEpdfShipFilterCallback,info);
  if (!(sts & 1)) goto wrapup;
  
  // Done
  retFlag = 1;
  
wrapup:

  if (traceFlag) printf("<<< %s %d\n",fn,retFlag);
  
  return retFlag;
}




