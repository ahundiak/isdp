/* $Id: VDct1PalX.C,v 1.2 2001/02/20 15:22:35 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdct1/copics/VDct1PalX.C
 *
 * Description: XML Parseing Rotuines for Pallets
 *
 * Dependencies:
 *
 * Revision History:
 * $Log: VDct1PalX.C,v $
 * Revision 1.2  2001/02/20 15:22:35  ahundiak
 * ah
 *
 * Revision 1.1  2001/01/11 22:16:23  art
 * sp merge
 *
 * Revision 1.2  2000/10/24  14:04:20  pinnacle
 * js
 *
 * Revision 1.1  2000/07/17  19:21:40  pinnacle
 * ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 07/05/00  ah      Creation
 *
 ***************************************************************************/
#include "VDtypedef.h"
#include "VDxml.h"
#include "VDvlaInfo.h"

#include "VDct1Copics.h"

static int traceFlag;

/* -------------------------------------------------
 * Got an attribute for an element in the stack
 */
static IGRstat VDsaxAttribute(TVDct1CopPalInfo *info, 
			      TVDxmlParseInfo  *parseInfo)
{
  IGRstat retFlag = 1;

  IGRchar  *etag = parseInfo->eleInfo.eleType;
  IGRchar   *tag = parseInfo->eleInfo.atrType;
  IGRchar *value = parseInfo->eleInfo.atrValue;
  IGRchar *p;
  
  // Want pallet_code from pallet
  if (!strcmp(etag,XML_COP_PALLET)) {

    if (!strcmp(tag,XML_COP_NODE_NAME)) strcpy(info->pallet_code,value);
    goto wrapup;
  }
  
  /* ---------------------------------------------
   * All other palletable objects become item
   * Rely on item pointer being properly set
   */
  if (!strcmp(etag,XML_COP_ENG_ASSY2) ||
      !strcmp(etag,XML_COP_STD_ASSY2) ||
      !strcmp(etag,XML_COP_PART)) {

    // The item
    TVDct1CopItemInfo *item = info->itemx;
    if (item == NULL) goto wrapup;
    
    // Attributes
    if (!strcmp(tag,XML_COP_NODE_NAME))  strcpy(item->node_name, value);
    if (!strcmp(tag,XML_COP_COMM_CODE))  strcpy(item->comm_code, value);
    if (!strcmp(tag,XML_COP_ZONE_NUM))   strcpy(item->zone_num,  value);
    if (!strcmp(tag,XML_COP_UNIT_NUM))   strcpy(item->unit_num,  value);
    if (!strcmp(tag,XML_COP_COMPT_NUM))  strcpy(item->compt_num, value);
    if (!strcmp(tag,XML_COP_COPICS_NUM)) strcpy(item->copics_num,value);
    
    if (!strcmp(tag,XML_COP_CONTRACT_JOB_NUM)) strcpy(item->contract_job_num,value);
    if (!strcmp(tag,XML_COP_DWG_NUM))          strcpy(item->dwg_num,         value);
    if (!strcmp(tag,XML_COP_HULL_NUM))         strcpy(item->hull_num,        value);

    if (!strcmp(tag,XML_COP_QTY))      strcpy(item->qty,     value);
    if (!strcmp(tag,XML_COP_PCT_MINO)) strcpy(item->pct_mino,value);
    
    goto wrapup;
  }
  
wrapup:
  return retFlag;
}

/* -------------------------------------------------
 * Start a new element
 *
 * Do some error checking here but in fact, there are losts
 * of possibilities and probably want a self contained
 * validate routine
 */
static IGRstat VDsaxBegElement(TVDct1CopPalInfo *info, 
			       TVDxmlParseInfo  *parseInfo)
{
  IGRchar fn[] = "VDct1CopPalFilterBegElement";
  IGRstat retFlag = 1;
  
  IGRchar   *tag = parseInfo->eleInfo.eleType;

  TVDxmlTagType  parentEleType;
  IGRchar        err[128];
  
  // Init
  *err = 0;
  
  // Say hi
  if (traceFlag) printf(">>> %s %s\n",fn,tag);
  
  // All Palletable Objects
  if (!strcmp(tag,XML_COP_ENG_ASSY2) ||
      !strcmp(tag,XML_COP_STD_ASSY2) || 
      !strcmp(tag,XML_COP_PART)) {

    // Turn off attribute processing
    info->itemx = NULL;

    // Parent should be pallet elements
    VDxmlParseGetParentEleType(parseInfo,1,parentEleType);
    if (strcmp(parentEleType,XML_COP_PALLET)) {
     
      // Ignore these nested items
      goto wrapup;
    }

    // Create a new item
    info->itemx = calloc(1,sizeof(TVDct1CopItemInfo));
    if (info->itemx == NULL) {
      sprintf(err,"*** Problem alocating memory for pallet item\n");
      goto wrapup;
    }
    
    // Init pallet code
    strcpy(info->itemx->pallet_code,info->pallet_code);

    // Default format and qty
    strcpy(info->itemx->um, "EA");
    strcpy(info->itemx->qty,"1.0");
    
    // Add to list and done
    vdvla$AppendInfo(info = &info->items, data = info->itemx);
    goto wrapup;
    
  }


  /* Done */
  retFlag = 1;
  
wrapup:

  if (*err) {  
    fputs(err,info->file.err);
    fputs(err,stderr);    
  }
  
  if (traceFlag) printf("<<< %s %d\n",fn,retFlag);
  return retFlag;
}

/* -------------------------------------------------
 * End an element, nothing to do really
 */
static IGRstat VDsaxEndElement(TVDct1CopPalInfo *info, 
			       TVDxmlParseInfo  *parseInfo)
{
  IGRchar     fn[] = "VDct1CopPalFilterEndElement";
  IGRstat     retFlag = 1;

  /* Done */
  retFlag = 1;
  
wrapup:
  
  return retFlag;
}

/* -------------------------------------------------
 * End the attribute portion of an element
 * 
 * Possible to add some more error checking here
 * to turn off part/assy input but not worry about
 * that for now
 */
static IGRstat VDsaxEndElementAttrs(TVDct1CopPalInfo *info, 
				    TVDxmlParseInfo  *parseInfo)
{
  IGRchar fn[] = "VDct1CopPalFilterEndElementAttrs";
  IGRstat retFlag = 1;

  IGRchar *tag = parseInfo->eleInfo.eleType;
  
  // Part or standard assembly object
  if (!strcmp(tag,XML_COP_ENG_ASSY2) || 
      !strcmp(tag,XML_COP_STD_ASSY2) || 
      !strcmp(tag,XML_COP_PART)) {

    // Turn off nesting attributes
    info->itemx = NULL;
    
    // Done
    goto wrapup;
    
  }
    
  // Done
  retFlag = 1;
  
wrapup:

  if (traceFlag) printf("<<< %s %d\n",fn,retFlag);
  return retFlag;
}

/* -------------------------------------------------
 * Callback traffic director
 * The only public routine here
 */
IGRstat VDct1CopPalSaxCallback(TVDxmlParseInfo *parseInfo)
{
  IGRchar fn[] = "VDct1CopPalFilterCallback";
  
  TVDct1CopPalInfo *info = parseInfo->data;
  
  //if (traceFlag) printf(">>> %s %d\n",fn,parseInfo->eleInfo.type);
  
  switch(parseInfo->eleInfo.type) {

  case VDXML_TYPE_BEG_ELEMENT:        
    return VDsaxBegElement(info,parseInfo);

  case VDXML_TYPE_END_ELEMENT:        
    return VDsaxEndElement(info,parseInfo);

  case VDXML_TYPE_ATTRIBUTE:          
    return VDsaxAttribute (info,parseInfo);

  case VDXML_TYPE_END_ELEMENT_ATTRS:  
    return VDsaxEndElementAttrs(info,parseInfo);
  }
  
  return 1;
}




