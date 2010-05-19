/* $Id: VDatXml.I,v 1.2 2001/02/20 15:22:59 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdat/pcmk/VDatXml.I
 *
 * Description: XML Routines
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDatXml.I,v $
 *      Revision 1.2  2001/02/20 15:22:59  ahundiak
 *      ah
 *
 *      Revision 1.1  2001/01/11 20:54:46  art
 *      sp merge
 *
# Revision 1.1  2000/11/27  19:35:40  pinnacle
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
#include "VDxml.h"

#include "VDassert.h"

VDASSERT_FFN("vdat/pcmk/VDatXml.I");

#define VDXML_LEAF_PIECES   "leaf_pieces"
#define VDXML_LEAF_SET_NAME "set_name"
#define VDXML_LEAF_BEAMS    "leaf_beams"
#define VDXML_LEAF_BEAM     "leaf_beam"
#define VDXML_LEAF_PLATES   "leaf_plates"
#define VDXML_LEAF_PLATE    "leaf_plate"

#define VDXML_LEAF_PCMK      "pcmk"
#define VDXML_LEAF_PIECE_ID  "piece_id"
#define VDXML_LEAF_PATH      "path"

#define VDXML_LEAF_FAMILY    "family"
#define VDXML_LEAF_PART_NUM  "part_num"
#define VDXML_LEAF_MATERIAL  "material"
#define VDXML_LEAF_GRADE     "grade"

#define VDXML_LEAF_THICKNESS "thickness"
#define VDXML_LEAF_AREA      "area"
#define VDXML_LEAF_IS_PLANAR "is_planar"

#define VDXML_LEAF_LENGTH    "length"
#define VDXML_LEAF_HEIGHT    "height"
#define VDXML_LEAF_ET0       "et0"
#define VDXML_LEAF_EI0       "ei0"
#define VDXML_LEAF_ET1       "et1"
#define VDXML_LEAF_EI1       "ei1"

/* -------------------------------------------------
 * Call back for filling in pcmk infos attributes
 */
static IGRstat xmlCallBackLoadPcmkInfosAttribute(TVDxmlParseInfo *parseInfo)
{ 
  IGRstat retFlag = 1;
  
  IGRchar *tag = parseInfo->eleInfo.eleType;
  IGRchar *atr = parseInfo->eleInfo.atrType;
  IGRchar *val = parseInfo->eleInfo.atrValue;

  TVDatPcmkInfos *infos = parseInfo->data;
  TVDatPcmkInfo  *info;

  IGRchar *p;
  
  // Make sure doing an expected leaf object
  if ((strcmp(tag,VDXML_LEAF_BEAM)) &&
      (strcmp(tag,VDXML_LEAF_PLATE))) goto wrapup;

  // Be really safe
  if (infos->cnt >= infos->max) goto wrapup;
  info = &infos->infos[infos->cnt];
  retFlag = 1;
  
  // Check attributes
  if (!strcmp(atr,VDXML_LEAF_PATH)) {
    // printf("%s\n",val);
    strcpy(info->leaf->piecePath,val);
    p = strrchr(info->leaf->piecePath,':');
    if (p) info->leaf->pieceName = p;
    else   info->leaf->pieceName = info->leaf->piecePath;
    goto wrapup;
  }
  if (!strcmp(atr,VDXML_LEAF_PCMK)) {
    info->leaf->pcmk1 = atoi(val);
    goto wrapup;
  }  
  if (!strcmp(atr,VDXML_LEAF_FAMILY)) {
    strcpy(info->attr->family,val);
    goto wrapup;
  }
  if (!strcmp(atr,VDXML_LEAF_PART_NUM)) {
    strcpy(info->attr->part_num,val);
    goto wrapup;
  }
  if (!strcmp(atr,VDXML_LEAF_MATERIAL)) {
    strcpy(info->attr->material,val);
    goto wrapup;
  }
  if (!strcmp(atr,VDXML_LEAF_GRADE)) {
    strcpy(info->attr->grade,val);
    goto wrapup;
  }
  if (!strcmp(atr,VDXML_LEAF_THICKNESS)) {
    info->attr->type.plate.thickness = atof(val);
    goto wrapup;
  }
  if (!strcmp(atr,VDXML_LEAF_AREA)) {
    info->attr->type.plate.area = atof(val);
    goto wrapup;
  }
  if (!strcmp(atr,VDXML_LEAF_IS_PLANAR)) {
    info->attr->type.plate.isPlanar = atoi(val);
    goto wrapup;
  }
  if (!strcmp(atr,VDXML_LEAF_LENGTH)) {
    info->attr->type.beam.length = atof(val);
    goto wrapup;
  }
  if (!strcmp(atr,VDXML_LEAF_HEIGHT)) {
    info->attr->type.beam.height = atof(val);
    goto wrapup;
  }

  if (!strcmp(atr,VDXML_LEAF_ET0)) {
    strcpy(info->attr->type.beam.et0,val);
    goto wrapup;
  }
  if (!strcmp(atr,VDXML_LEAF_EI0)) {
    strcpy(info->attr->type.beam.ei0,val);
    goto wrapup;
  }
  if (!strcmp(atr,VDXML_LEAF_ET1)) {
    strcpy(info->attr->type.beam.et1,val);
    goto wrapup;
  }
  if (!strcmp(atr,VDXML_LEAF_EI1)) {
    strcpy(info->attr->type.beam.ei1,val);
    goto wrapup;
  }
  
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -------------------------------------------------
 * Call back for filling in pcmk infos
 */
static IGRstat xmlCallBackLoadPcmkInfos(TVDxmlParseInfo *parseInfo)
{ 
  IGRchar        *tag   = parseInfo->eleInfo.eleType;
  TVDatPcmkInfos *infos = parseInfo->data;
  
  switch(parseInfo->eleInfo.type) {

    // At element end, move onto next one
    case VDXML_TYPE_END_ELEMENT:        
      if (!strcmp(tag,VDXML_LEAF_BEAM))  {
	if (infos->cnt < infos->max) {
	  infos->infos[infos->cnt].leaf->pieceType = VDAT_PCMK_INFO_PIECE_TYPE_BEAM;
	  infos->cnt++;
	}
      }
    
      if (!strcmp(tag,VDXML_LEAF_PLATE)) {
	if (infos->cnt < infos->max) {
	  infos->infos[infos->cnt].leaf->pieceType = VDAT_PCMK_INFO_PIECE_TYPE_PLATE;
	  infos->cnt++;  
	}
      }   
      break;


    case VDXML_TYPE_ATTRIBUTE: 
      return xmlCallBackLoadPcmkInfosAttribute(parseInfo);
      
  }
  
  return 1;
}

/* -------------------------------------------------
 * Fill in the already allocated info structure
 * by reading the xml file
 */
IGRstat VDatLoadPcmkInfosFromXmlFile(IGRchar *fileName, TVDatPcmkInfos *infos)
{
  VDASSERT_FN("VDatLoadPcmkInfosFromXmlFile");
  IGRstat retFlag = 0;
  TVDxmlParseInfo parseInfo;
  
  // Arg check
  VDASSERTW(infos);
  VDASSERTW(fileName);
  
  // Do It
  VDxmlParseFile(&parseInfo,fileName,xmlCallBackLoadPcmkInfos,infos);
  
  // Done
  retFlag = 0;
  
 wrapup:
  return retFlag;
}

/* -------------------------------------------------
 * Callback traffic director
 */
static IGRstat xmlCallBackGetNumLeafs(TVDxmlParseInfo *parseInfo)
{
  IGRchar *tag = parseInfo->eleInfo.eleType;
  IGRint  *cnt = parseInfo->data;
  
  switch(parseInfo->eleInfo.type) {

  case VDXML_TYPE_BEG_ELEMENT:        
    if (!strcmp(tag,VDXML_LEAF_BEAM))  *cnt = *cnt + 1;
    if (!strcmp(tag,VDXML_LEAF_PLATE)) *cnt = *cnt + 1;    
    break;
  }
  
  return 1;
}

/* -----------------------------------------------
 * Count the number of leafs in an xml file
 */
IGRstat VDatGetNumLeafsInXmlFile(IGRchar *fileName, IGRint *cnt)
{
  VDASSERT_FN("VDatGetNumLeafsInXmlFile");
  IGRstat retFlag = 0;
  TVDxmlParseInfo info;
  
  // Arg check
  VDASSERTW(cnt);
  *cnt = 0;
  VDASSERTW(fileName);
  
  // Do It
  VDxmlParseFile(&info,fileName,xmlCallBackGetNumLeafs,cnt);
  
  // Done
  retFlag = 0;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Given either a file name or a blob name
 * Load up the infos structure
 */
IGRstat VDatLoadPcmkInfosFromXml(IGRchar *fileName, IGRchar *blobName, TVDatPcmkInfos *infos)
{
  VDASSERT_FN("VDatLoadPcmkInfosFromXml");
  IGRstat retFlag = 0;

  TGRid blobID;

  IGRchar *data = NULL;
  IGRint   dataLen;
  
  // Arg check
  VDASSERTW(infos);
  VDatResetPcmkInfos(infos);

  // If it's a blob then get the blob object
  if (blobName) {

    // Get the object
    VDblobGetBlobObject(OM_K_NOT_AN_OS,blobName,&blobID);
    VDASSERTW(blobID.objid == NULL_OBJID);

    // Get the data
    VDblobGetBlobData(&blobID,&dataLen,&data);
    if (dataLen == 0) goto wrapup;
    
  }
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Write the pcmk info to an xml stream
 */
static IGRstat xmlWritePcmkInfoToXmlStream(TVDxmlFileInfo *file, TVDatPcmkInfo *info)
{
  VDASSERT_FN("VDatWritePcmkInfosToXmlFile");
  IGRstat retFlag = 0;

  TVDatPcmkLeafInfo *leaf;
  TVDatPcmkAttrInfo *attr;

  IGRchar buf[128];
  
  // Arg check
  VDASSERTW(file);
  VDASSERTW(info);  
  VDASSERTW(info->leaf);
  VDASSERTW(info->attr);

  // Easier
  leaf = info->leaf;
  attr = info->attr;

  // Plate or beam
  switch(leaf->pieceType) {

    // Plate
    case VDAT_PCMK_INFO_PIECE_TYPE_PLATE:
      VDxmlWriteObjBeg(file,VDXML_LEAF_PLATE,1,0);
      break;
      
    // Beam
    case VDAT_PCMK_INFO_PIECE_TYPE_BEAM:
      VDxmlWriteObjBeg(file,VDXML_LEAF_BEAM,1,0);
      break;

    default:
      VDASSERTW(NULL);
      
  }

  // Common Attributes
  VDxmlWriteAtrInt(file,VDXML_LEAF_PCMK,leaf->pcmk1,0,0);

  // Just for debugging
  sprintf(buf,"%d,%d",
	  leaf->pieceOE.obj_id.osnum,
	  leaf->pieceOE.obj_id.objid);
  VDxmlWriteAtrTxt(file,VDXML_LEAF_PIECE_ID,buf,0,1);

  // The real key is the name
  VDxmlWriteAtrTxt(file,VDXML_LEAF_PATH,leaf->piecePath,1,1);

  VDxmlWriteAtrTxt(file,VDXML_LEAF_FAMILY,  attr->family,  1,0);
  VDxmlWriteAtrTxt(file,VDXML_LEAF_PART_NUM,attr->part_num,0,1);
  VDxmlWriteAtrTxt(file,VDXML_LEAF_MATERIAL,attr->material,1,0);
  VDxmlWriteAtrTxt(file,VDXML_LEAF_GRADE,   attr->grade,   0,1);

  // Plate or beam
  switch(leaf->pieceType) {

    // Plate
    case VDAT_PCMK_INFO_PIECE_TYPE_PLATE:
      VDxmlWriteAtrDbl(file,VDXML_LEAF_THICKNESS,attr->type.plate.thickness,1,0);
      VDxmlWriteAtrDbl(file,VDXML_LEAF_AREA,     attr->type.plate.area,     0,0);
      VDxmlWriteAtrInt(file,VDXML_LEAF_IS_PLANAR,attr->type.plate.isPlanar, 0,0);
      VDxmlWriteAtrEnd(file,0,1);
      VDxmlWriteObjEnd(file,VDXML_LEAF_PLATE,1);
      break;
      
    // Beam
    case VDAT_PCMK_INFO_PIECE_TYPE_BEAM:
      VDxmlWriteAtrDbl(file,VDXML_LEAF_LENGTH,attr->type.beam.length,1,0);
      VDxmlWriteAtrDbl(file,VDXML_LEAF_HEIGHT,attr->type.beam.height,0,1);
      VDxmlWriteAtrTxt(file,VDXML_LEAF_ET0,   attr->type.beam.et0,   1,0);
      VDxmlWriteAtrTxt(file,VDXML_LEAF_EI0,   attr->type.beam.ei0,   0,1);
      VDxmlWriteAtrTxt(file,VDXML_LEAF_ET1,   attr->type.beam.et1,   1,0);
      VDxmlWriteAtrTxt(file,VDXML_LEAF_EI1,   attr->type.beam.ei1,   0,0);
      VDxmlWriteAtrEnd(file,1,1);
      VDxmlWriteObjEnd(file,VDXML_LEAF_BEAM,1);
      break;
      
  }

  // Done
  retFlag = 1;
  
 wrapup:
  retFlag = 0;
}

/* -----------------------------------------------
 * Write the pcmk infos to an xml file
 */
IGRstat VDatWritePcmkInfosToXmlFile(IGRchar *fileName, TVDatPcmkInfos *infos)
{
  VDASSERT_FN("VDatWritePcmkInfosToXmlFile");
  IGRstat retFlag = 0;
  IGRstat sts;

  IGRchar buf[128];
  TVDxmlFileInfo file;
  
  IGRint i;
  TVDatPcmkInfo *info;
  
  // Arg check
  VDASSERTW(infos);
  VDASSERTW(fileName && *fileName);
  
  // Open it
  sts = vdxml$OpenOutputStream(info     = &file, 
			       fileName = fileName,
			       docType  = "StagingTree");
  if (!(sts & 1)) goto wrapup;

  // Status
  sprintf(buf,"Writing %s...",fileName);
  UI_status(buf);

  // Write It
  VDxmlWriteObjBeg(&file,VDXML_LEAF_PIECES,1,0);
  // VDxmlWriteAtrTxt(&file,VDXML_LEAF_SET_NAME,setName,0,0);
  VDxmlWriteAtrEnd(&file,0,1);

  // Do Beams
  VDxmlWriteObjBeg(&file,VDXML_LEAF_BEAMS,0,1);
  for(i = 0; i < infos->cnt; i++) {
    info = &infos->infos[i];
    VDASSERTW(info->leaf);
    VDASSERTW(info->attr);
    if (info->leaf->pieceType == VDAT_PCMK_INFO_PIECE_TYPE_BEAM) {
      xmlWritePcmkInfoToXmlStream(&file,info);  
    }
  }
  VDxmlWriteObjEnd(&file,VDXML_LEAF_BEAMS,1);  

  // Do Plates
  VDxmlWriteObjBeg(&file,VDXML_LEAF_PLATES,0,1);
  for(i = 0; i < infos->cnt; i++) {
    info = &infos->infos[i];
    VDASSERTW(info->leaf);
    VDASSERTW(info->attr);
    if (info->leaf->pieceType == VDAT_PCMK_INFO_PIECE_TYPE_PLATE) {
      xmlWritePcmkInfoToXmlStream(&file,info);  
    }
  }
  
  VDxmlWriteObjEnd(&file,VDXML_LEAF_PLATES,1);  

  // Close
  VDxmlWriteObjEnd(&file,VDXML_LEAF_PIECES,1);  
  vdxml$CloseOutputStream(info = &file);

  // Status
  sprintf(buf,"Wrote %s",fileName);
  UI_status(buf);
  
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

end implementation Root;

