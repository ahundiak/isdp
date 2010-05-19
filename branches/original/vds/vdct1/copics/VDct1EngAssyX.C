/* $Id: VDct1EngAssyX.C,v 1.2 2001/02/20 15:22:35 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdct1/copics/VDct1AssyX.C
 *
 * Description: XML Parseing Rotuines for Eng Assys
 *
 * Dependencies:
 *
 * Revision History:
 * $Log: VDct1EngAssyX.C,v $
 * Revision 1.2  2001/02/20 15:22:35  ahundiak
 * ah
 *
 * Revision 1.1  2001/01/11 22:16:23  art
 * sp merge
 *
 * Revision 1.3  2000/10/24  14:04:20  pinnacle
 * js
 *
 * Revision 1.2  2000/10/11  20:22:34  pinnacle
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
static IGRstat VDsaxAttribute(TVDct1CopEngInfo *info, 
			      TVDxmlParseInfo  *parseInfo)
{
  IGRstat retFlag = 1;

  IGRchar  *etag = parseInfo->eleInfo.eleType;
  IGRchar   *tag = parseInfo->eleInfo.atrType;
  IGRchar *value = parseInfo->eleInfo.atrValue;
  IGRchar *p;
  
  // Assembly object
  if (!strcmp( etag,XML_COP_ENG_ASSY2)) {

    // Just in case
    TVDct1CopAssyInfo *assy = info->assyx;
    if (assy == NULL) goto wrapup;
    
    if (!strcmp(tag,XML_COP_NODE_NAME))  strcpy(assy->node_name, value);
    if (!strcmp(tag,XML_COP_COMM_CODE))  strcpy(assy->comm_code, value);
    if (!strcmp(tag,XML_COP_ZONE_NUM))   strcpy(assy->zone_num,  value);
    if (!strcmp(tag,XML_COP_UNIT_NUM))   strcpy(assy->unit_num,  value);
    if (!strcmp(tag,XML_COP_COMPT_NUM))  strcpy(assy->compt_num, value);
    if (!strcmp(tag,XML_COP_COPICS_NUM)) strcpy(assy->copics_num,value);
    goto wrapup;
  }

  // Part or standard assembly object
  if (!strcmp( etag,XML_COP_STD_ASSY2) || 
      !strcmp( etag,XML_COP_PART)) {

    // Just in case
    TVDct1CopPartInfo *part = info->partx;
    if (part == NULL) goto wrapup;

    if (!strcmp(tag,XML_COP_NODE_NAME))  strcpy(part->node_name, value);
    if (!strcmp(tag,XML_COP_UM))         strcpy(part->um,        value);
    if (!strcmp(tag,XML_COP_QTY))        strcpy(part->qty,       value);
    if (!strcmp(tag,XML_COP_PCT_MINO))   strcpy(part->pct_mino,  value);
    if (!strcmp(tag,XML_COP_COPICS_NUM)) strcpy(part->copics_num,value);
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
static IGRstat VDsaxBegElement(TVDct1CopEngInfo *info, 
				    TVDxmlParseInfo  *parseInfo)
{
  IGRchar fn[] = "VDct1CopAssyFilterBegElement";
  IGRstat retFlag = 1;
  
  IGRchar   *tag = parseInfo->eleInfo.eleType;

  TVDxmlTagType  parentEleType;
  IGRchar        err[128];
  
  // Init
  *err = 0;
  
  // Say hi
  if (traceFlag) printf(">>> %s %s\n",fn,tag);
  
  // Assy Object
  if (!strcmp(tag,XML_COP_ENG_ASSY2)) {

    // Turn off attribute processing
    info->assyx = NULL;
    info->partx = NULL;

    // Parent should be group elements
    VDxmlParseGetParentEleType(parseInfo,1,parentEleType);
    if (strcmp(parentEleType,XML_COP_GROUP)) {
     
      // Flag this as an error
      sprintf(err,"*** Have ENGASSY2 whose parent is not a GROUP\n");
      goto wrapup;
    }

    // Create a new assembly
    info->assyx = calloc(1,sizeof(TVDct1CopAssyInfo));
    if (info->assyx == NULL) {
      sprintf(err,"*** Problem alocating memory for assy\n");
      goto wrapup;
    }
    vdvla$InitInfo(info = &info->assyx->parts);
    
    // Add to list and done
    vdvla$AppendInfo(info = &info->assys, data = info->assyx);
    goto wrapup;
    
  }

  // Child Object
  if (!strcmp(tag,XML_COP_STD_ASSY2) || 
      !strcmp(tag,XML_COP_PART)) {

    // Parent should be ENG_ASSY2
    VDxmlParseGetParentEleType(parseInfo,1,parentEleType);
    if (strcmp(parentEleType,XML_COP_ENG_ASSY2)) {
    
      // Not an error, just not interested in these
      info->partx = NULL;
      goto wrapup;
      
    }

    // Just to make sure
    if (info->assyx == NULL) {

      // Not an error, just not interested in these
      info->partx = NULL;
      goto wrapup;
    }
    
    // Create a new part
    info->partx = calloc(1,sizeof(TVDct1CopPartInfo));
    if (info->partx == NULL) {
      sprintf(err,"*** Problem alocating memory for part\n");
      goto wrapup;
    }

    // Add to list and done
    vdvla$AppendInfo(info = &info->assyx->parts, data = info->partx);
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
static IGRstat VDsaxEndElement(TVDct1CopEngInfo *info, 
			       TVDxmlParseInfo  *parseInfo)
{
  IGRchar     fn[] = "VDct1CopAssyFilterEndElement";
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
static IGRstat VDsaxEndElementAttrs(TVDct1CopEngInfo *info, 
				    TVDxmlParseInfo  *parseInfo)
{
  IGRchar fn[] = "VDct1CopAssyFilterEndElementAttrs";
  IGRstat retFlag = 1;

  IGRchar *tag = parseInfo->eleInfo.eleType;
  
  // Part or standard assembly object
  if (!strcmp(tag,XML_COP_STD_ASSY2) || 
      !strcmp(tag,XML_COP_PART)) {
    
    // Turn off nesting attributes
    info->partx = NULL;
    
    // Done
    goto wrapup;
    
  }
  
  // Assy Object
  if (!strcmp(tag,XML_COP_ENG_ASSY2)) {

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
 */
IGRstat VDct1CopEngAssySaxCallback(TVDxmlParseInfo *parseInfo)
{
  IGRchar fn[] = "VDct1CopAssyFilterCallback";
  
  TVDct1CopEngInfo *info = parseInfo->data;
  
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

