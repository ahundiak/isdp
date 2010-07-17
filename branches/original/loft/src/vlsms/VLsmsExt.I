/* $Id: VLsmsExt.I,v 1.4 2002/04/09 20:54:13 ahundiak Exp $  */

/***************************************************************************
 * I/LOFT
 *
 * File:        vlext/VLextMark.I
 *
 * Description: Low level attribute extraction
 *              Used to be in VLsmsExt.u
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VLsmsExt.I,v $
 *      Revision 1.4  2002/04/09 20:54:13  ahundiak
 *      ah
 *
 *      Revision 1.3  2001/07/10 20:46:13  ahundiak
 *      ah
 *
 *      Revision 1.2  2001/07/10 19:18:01  ahundiak
 *      ah
 *
 *      Revision 1.1  2001/01/18 17:55:32  art
 *      ah
 *
# Revision 1.2  2000/12/15  20:03:00  pinnacle
# ah
#
# Revision 1.1  2000/11/27  20:25:38  pinnacle
# ah
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 11/15/00  ah      Creation
 *
 ***************************************************************************/

class implementation Root;

#include "VDtypedef.h"
#include "VDobj.h"
#include "VDat.h"
#include "VDsa.h"

#include "VLsms.h"
#include "VDpdm.h"

#include "VDassert.h"
#include "time.h"

VDASSERT_FFN("src/vlsms/VLsmsExt.I");

/* --------------------------------------
 * Utility structure for organizing stuff
 */
typedef struct {
  TGRid   id;
  IGRchar type [128];
  IGRchar name [128];
  IGRchar pcmk [128];
  IGRchar path [128];
  IGRchar desc [128];
  IGRchar stage[128];
  IGRint  qty;

  // Few more bits for Fil
  IGRchar family  [32];
  IGRchar part_num[32];
  IGRchar grade   [32];

  IGRdouble length;
  
} TVPextNodeData;

static IGRstat getNodeQty(TGRid *qtyID, IGRint  *qty);
static IGRstat getDupStr (TGRid *dupID, IGRchar *dupStr);

static IGRstat processNodeData(TVPextNodeData *node);

/* -----------------------------------------------------------------
 * Build a spades file name based on set
 */
IGRstat VLsmsExtGenFileName(TGRid   *setID, 
			    IGRchar *fileHull,
			    IGRchar *fileWhat,
			    IGRchar *fileStamp,
			    IGRchar *fileName)
{
  VDASSERT_FN("VLsmsExtGenFileName");
  
  IGRstat  retFlag = 0;
  
  IGRchar  hull[16];
  IGRchar  app [16];
  IGRchar  unit[16];
  IGRchar  what[16];
  
  time_t current_time;
  struct tm *tm;

  // Arg check
  VDASSERTW(fileName);
  strcpy(fileName,"ProdData");
  VDASSERTW(fileStamp);
  *fileStamp = 0;
  
  VDASSERTW(setID);
  VDASSERTW(fileHull);
  VDASSERTW(fileWhat);
  
  // Date time stamp
  time(&current_time);
  tm = localtime(&current_time);
  sprintf(fileStamp,
	  "%4d%02d%02d.%02d%02d%02d",
	  tm->tm_year+1900,tm->tm_mon+1,tm->tm_mday,
	  tm->tm_hour,     tm->tm_min,  tm->tm_sec);

  // Get the unit for set
  vdsa$GetStruct(objID = setID, name = "node_name", txt = unit);
  if (*unit == 0) goto wrapup;

#if 0  
  // Hull and app
  strcpy(hull,"lp17");
  if (!strncmp(fileHull,"LPD",3)) {
    sprintf(hull,"lp%s",fileHull+3);
  }
  
  // Applicability
  strcpy(app, "a");
#endif

  // Hull is actually the class
  strcpy(hull,"lp17");

  // Applicability determines which ship
  *app = 'a' + atoi(fileHull+3) - 17;
  *(app+1) = 0;
  
  // Translate FILE_TYPE into standard name
  strcpy(what,"NONE");
  if (!strcmp(fileWhat,"Tree"))   strcpy(what,"tree");
  if (!strcmp(fileWhat,"Pieces")) strcpy(what,"part");
  if (!strcmp(fileWhat,"Plates")) strcpy(what,"plat");
  if (!strcmp(fileWhat,"Beams"))  strcpy(what,"beam");
  if (!strcmp(fileWhat,"All"))    strcpy(what,"allx");

  // Put it all together
  sprintf(fileName,"%s.%s.%s.%s.%s",hull,app,unit,what,fileStamp);
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* -----------------------------------------------------------------
 * Extracts Ship Information
 */
IGRstat VLsmsExtExtractShip(TVDxmlFileInfo *xml,
			    IGRchar        *hull)
{
  VDASSERT_FN("VLsmsExtExtractShip");
  
  IGRstat  retFlag = 0;
  IGRchar  app[32];
  
  // Arg check
  VDASSERTW(xml);
  VDASSERTW(hull && *hull);

  // Start
  VDxmlWriteObjBeg(xml,XML_PDF_SHIP,1,1);

  // Hull Info
#if 0
  if (!strcmp(hull,"INGR13")) {
    VDxmlWriteAtrTxt(xml,XML_PDF_SHIP_NAME,    "USS INTERGRAPH",1,1);
    VDxmlWriteAtrTxt(xml,XML_PDF_SHIP_OWNER,   "US NAVY",       1,1);
    VDxmlWriteAtrTxt(xml,XML_PDF_SHIP_HULL,    "INGR",          1,1);
    VDxmlWriteAtrTxt(xml,XML_PDF_SHIP_HULL_APP,"AB",            1,1);
  }
  else {    
    VDxmlWriteAtrTxt(xml,XML_PDF_SHIP_NAME,    "SAN ANTONIO",1,1);
    VDxmlWriteAtrTxt(xml,XML_PDF_SHIP_OWNER,   "US NAVY",    1,1);
    VDxmlWriteAtrTxt(xml,XML_PDF_SHIP_HULL,    "LP17",       1,1);
    VDxmlWriteAtrTxt(xml,XML_PDF_SHIP_HULL_APP,"ABC",        1,1);
  }
#endif

  // Hull Info
  *app = 'A' + atoi(hull+3) - 17;
  *(app+1) = 0;
  
  VDxmlWriteAtrTxt(xml,XML_PDF_SHIP_NAME,    "USS INTERGRAPH",1,1);
  VDxmlWriteAtrTxt(xml,XML_PDF_SHIP_OWNER,   "US NAVY",       1,1);
  VDxmlWriteAtrTxt(xml,XML_PDF_SHIP_HULL,    hull,            1,1);
  VDxmlWriteAtrTxt(xml,XML_PDF_SHIP_HULL_APP,app,             1,1);
  
  VDxmlWriteAtrTxt(xml,XML_PDF_SHIP_DIMENSIONS,         "PRINCIPAL DIMENSIONS",1,1);
  VDxmlWriteAtrTxt(xml,XML_PDF_SHIP_GLOBAL_COORD_SYSTEM,"XF ZU YP",1,1);
  VDxmlWriteAtrDbl(xml,XML_PDF_SHIP_FWD_PERPENDICULAR,  0.0,1,1);

  // Done
  VDxmlWriteAtrEnd(xml,1,1);
  VDxmlWriteObjEnd(xml,XML_PDF_SHIP,1);
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* -----------------------------------------------------------------
 * Extracts the setup information
 */
IGRstat VLsmsExtExtractSetup(TVDxmlFileInfo *xml,
			     IGRchar        *stamp,
			     IGRchar        *spadesFileName,
			     IGRchar        *fileStatus,
			     IGRint          preTranslate)
{
  VDASSERT_FN("VLsmsExtExtractSetup");
  
  IGRstat retFlag = 0;
  IGRstat sts;

  IGRchar buf[256],*p;
  
  TVDpdmInfo pdmInfo;

  // Arg check
  VDASSERTW(xml);
  VDASSERTW(stamp          && *stamp);
  VDASSERTW(spadesFileName && *spadesFileName);
  VDASSERTW(fileStatus     && *fileStatus);
  
  // Cheat with internal units for now
  VDxmlWriteObjBeg(xml,XML_PDF_SETUP,1,1);
  VDxmlWriteAtrTxt(xml,
		   XML_PDF_SETUP_INTERNAL_UNITS,
		   XML_PDF_SETUP_INTERNAL_UNITS_METRIC,1,1);

  // Date time stamp
  VDxmlWriteAtrTxt(xml,XML_PDF_SETUP_DATE,    stamp,         1,1);
  VDxmlWriteAtrTxt(xml,XML_PDF_SETUP_PDF_NAME,spadesFileName,1,1);

  // Current file name
  ex$filename(name = buf, len = sizeof(buf));
  p = strrchr(buf,'/');
  if (p) strcpy(buf,p+1);
  
  VDxmlWriteAtrTxt(xml,XML_PDF_SETUP_FILE_NAME,buf,1,1);

  // Toss in pdm information
  vdpdm$GetPdmInfo(pdmInfo = &pdmInfo);  
  VDxmlWriteAtrTxt(xml,XML_PDF_SETUP_PDM_CAT, pdmInfo.catalog,1,1);
  VDxmlWriteAtrTxt(xml,XML_PDF_SETUP_PDM_PART,pdmInfo.part,   1,1);
  VDxmlWriteAtrTxt(xml,XML_PDF_SETUP_PDM_REV, pdmInfo.rev,    1,1);

  // User controlled file status
  strcpy(buf,fileStatus);
  *(buf+1) = 0;
  
  VDxmlWriteAtrTxt(xml,XML_PDF_SETUP_PDM_STATUS,buf, 1,1);

  // Write out translate flag
  VDxmlWriteAtrInt(xml,XML_PDF_SETUP_PRE_TRANSLATE,preTranslate,1,1);

  // Done
  VDxmlWriteAtrEnd(xml,1,1);
  VDxmlWriteObjEnd(xml,XML_PDF_SETUP,1);

wrapup:
  return retFlag;
}


/* -----------------------------------------------
 * Check the fab object to see if the process
 * has been specified
 */
static IGRstat buildProcess(TGRid *fabID, IGRchar *name, IGRchar *process)
{
  VDASSERT_FN("buildProcess");
  IGRstat retFlag = 1;
  
  IGRchar buf[128];
  IGRchar *p;
  
  // Get the attribute
  vdsa$Get(objID = fabID, name = name, txt = buf);
  if ((*buf != 'y') && (*buf != 'Y')) goto wrapup;

  // Let the attribute name be the key
  strcpy(buf,name);
  p = strchr(buf,'_');
  if (p) strcpy(buf,p+1);
  VDstrupr(buf);
  
  // Append it
  if (*process) strcat(process," ");
  strcat(process,buf);
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Writes out primary and secondary processes
 */
static IGRstat writeProcessesForBeam(TVDxmlFileInfo *xml,
				     TVPextNodeData *node)
{
  VDASSERT_FN("writeProcessesForBeam");
  
  IGRstat retFlag = 0;
  TGRid   fabID;
  IGRchar buf[256];
  IGRchar *p;
  
  TGRobj_env pieceOE;
  IGRint dumpFlag = 0;
  
  // Init
  pieceOE.obj_id.objid = NULL_OBJID;
  
  // Only beams for now though plates could be done as well
  if (strcmp(node->type,"BEAM")) goto wrapup;
  
  // Want either plate or beam
  VDatGetLeafObject(&node->id,&pieceOE);
  if (pieceOE.obj_id.objid == NULL_OBJID) {
    VLsmsLog1(1,1,"*** Unable to get model object, Piece %s\n",node->pcmk);
    dumpFlag = 1;
    goto wrapup;
  }
  
  // Just to speed things up, get the fab data object
  VDatGetObjectLeafForSetType(&pieceOE,"FabData",&fabID);
  if (fabID.objid == NULL_OBJID) {
    VLsmsLog1(1,1,"*** Beam is not in FabData set, Piece %s\n",node->pcmk);
    dumpFlag = 1;
    goto wrapup;
  }

  // See if incorrect processes have been applied
  *buf = 0;
  buildProcess(&fabID,"u_nest", buf);
  buildProcess(&fabID,"u_servo",buf);
  if (*buf) {
    VLsmsLog1(1,1,"*** Invalid Primary Process, Piece %s '%s'\n",node->pcmk,buf);
    dumpFlag = 1;
    goto wrapup;
  }
  
  // Primary Process
  *buf = 0;
  buildProcess(&fabID,"u_temp",    buf);
  buildProcess(&fabID,"u_sketch",  buf);
  buildProcess(&fabID,"u_beamline",buf);
  buildProcess(&fabID,"u_frbd",    buf);
  if (*buf == 0) {
    VLsmsLog1(1,1,"*** No Primary Process For Piece %s\n",node->pcmk);
    dumpFlag = 1;
  }
  p = strchr(buf,' ');
  if (p) {
    VLsmsLog1(1,1,"*** Multiple Primary Processes For Piece %s '%s'\n",node->pcmk,buf);
    dumpFlag = 1;
    *p = 0;
  }
  VDxmlWriteAtrTxt(xml,XML_PDF_PIECE_PRI_PROCESS,buf,1,1);

  // Secondary Process (no error checking. ok if there is none)
  *buf = 0;
  buildProcess(&fabID,"u_knuckle", buf);
  buildProcess(&fabID,"u_roll",    buf);
  buildProcess(&fabID,"u_form",    buf);
  buildProcess(&fabID,"u_machine", buf);
  buildProcess(&fabID,"u_punch",   buf);
  VDxmlWriteAtrTxt(xml,XML_PDF_PIECE_SEC_PROCESS,buf,1,1);
  
  // Done
  retFlag = 1;

  /* ---------------------------------------------
   * For reporting errors
   */
wrapup:

  if (dumpFlag) {
    VLsmsLog2(1,1,NULL,NULL,&node->id);
    VLsmsLog2(1,1,NULL,&pieceOE,NULL);
    VLsmsLog1(1,1,"---\n");
  }
  
  return retFlag;
}

/* -----------------------------------------------
 * Writes out primary and secondary processes
 */
static IGRstat writeProcessesForPlate(TVDxmlFileInfo *xml,
				     TVPextNodeData *node)
{
  VDASSERT_FN("writeProcessesForPlate");
  
  IGRstat retFlag = 0;
  TGRid   fabID;
  IGRchar buf[256];
  IGRchar *p;
  
  TGRobj_env pieceOE;
  IGRint dumpFlag = 0;
  
  // Init
  pieceOE.obj_id.objid = NULL_OBJID;
  
  // Only beams for now though plates could be done as well
  if (strcmp(node->type,"PLATE")) goto wrapup;
  
  // Want either plate or beam
  VDatGetLeafObject(&node->id,&pieceOE);
  if (pieceOE.obj_id.objid == NULL_OBJID) {
    VLsmsLog1(1,1,"*** Unable to get model object, Piece %s\n",node->pcmk);
    dumpFlag = 1;
    goto wrapup;
  }
  
  // Just to speed things up, get the fab data object
  VDatGetObjectLeafForSetType(&pieceOE,"FabData",&fabID);
  if (fabID.objid == NULL_OBJID) {
    VLsmsLog1(1,1,"*** Plate is not in FabData set, Piece %s\n",node->pcmk);
    dumpFlag = 1;
    goto wrapup;
  }

  // See if incorrect processes have been applied
  *buf = 0;
  buildProcess(&fabID,"u_sketch",  buf);
  buildProcess(&fabID,"u_beamline",buf);
  buildProcess(&fabID,"u_frbd",    buf);
  if (*buf) {
    VLsmsLog1(1,1,"*** Invalid Primary Process, Piece %s '%s'\n",node->pcmk,buf);
    dumpFlag = 1;
    goto wrapup;
  }
  
  // Primary Process
  *buf = 0;
  buildProcess(&fabID,"u_nest",  buf);
  buildProcess(&fabID,"u_temp",  buf);
  buildProcess(&fabID,"u_notemp",buf);
  buildProcess(&fabID,"u_servo", buf);

  if (*buf == 0) {
    VLsmsLog1(1,1,"*** No Primary Process For Piece %s\n",node->pcmk);
    dumpFlag = 1;
  }
  p = strchr(buf,' ');
  if (p) {
    VLsmsLog1(1,1,"*** Multiple Primary Processes For Piece %s '%s'\n",node->pcmk,buf);
    dumpFlag = 1;
    *p = 0;
  }
  VDxmlWriteAtrTxt(xml,XML_PDF_PIECE_PRI_PROCESS,buf,1,1);

  // Secondary Process (no error checking. ok if there is none)
  *buf = 0;
  buildProcess(&fabID,"u_knuckle", buf);
  buildProcess(&fabID,"u_roll",    buf);
  buildProcess(&fabID,"u_form",    buf);
  buildProcess(&fabID,"u_machine", buf);
  buildProcess(&fabID,"u_punch",   buf);
  buildProcess(&fabID,"u_lineheat",buf);
  VDxmlWriteAtrTxt(xml,XML_PDF_PIECE_SEC_PROCESS,buf,1,1);
  
  // Done
  retFlag = 1;

  /* ---------------------------------------------
   * For reporting errors
   */
wrapup:

  if (dumpFlag) {
    VLsmsLog2(1,1,NULL,NULL,&node->id);
    VLsmsLog2(1,1,NULL,&pieceOE,NULL);
    VLsmsLog1(1,1,"---\n");
  }
  
  return retFlag;
}

/* -----------------------------------------------------------------
 * Extracts an assembly tree node
 *
 * A return of 0 means the node was not written which implies
 * that qty was > 1 and one version was already written
 *
 * Calling routines do use this return value
 */
IGRstat VLsmsExtExtractTreeNode(TVDxmlFileInfo *xml,
				TGRid          *nodeID)
{
  VDASSERT_FN("VLsmsExtExtractTreeNode");
  IGRstat retFlag = 0;
  
  IGRint type;
  
  TVPextNodeData node;
  TVPextNodeData parent;

  IGRchar buf[256];
  IGRint  seq;
  
  // Arg check
  VDASSERTW(xml);
  VDASSERTW(nodeID);
  
  // Make things easier
  memset(&node,0,sizeof(node));
  node.id = *nodeID;

  /* ---------------------------------------------
   * Counts total number for the piece mark
   * Ensures that only the first is actually written
   * Trick is to return a qty of 0 if not the first
   */
  getNodeQty(&node.id,&node.qty);
  if (node.qty == 0) goto wrapup;
  
  
  // Common for both nodes and leafs
  vdsa$GetStruct(objID=&node.id, name="node_type", txt=node.type);
  vdsa$GetStruct(objID=&node.id, name="node_type", txt=node.type);
  vdsa$GetStruct(objID=&node.id, name="node_name", txt=node.name);
  vdsa$GetStruct(objID=&node.id, name="node_path", txt=node.path);
//vdsa$GetStruct(objID=&node.id, name="u_notes",   txt=node.desc);
  vdsa$GetStruct(objID=&node.id, name="pcmk",      txt=node.pcmk);
  
  processNodeData(&node);

  /* ---------------------------------------------
   * It can happen that an object that a leaf is pointing
   * to is no longer attached, this means the staging tree is out of date
   * 
   * Really should not allow extractions at all but let it slide for now
   *
   * the processNodeData will have transformed PM to either PLATE or BEAM
   */
  if (!strcmp(node.type,"PM")) goto wrapup;

  // Need the parent info
  memset(&parent,0,sizeof(parent));
  VDatGetParentNode(&node.id,&parent.id);

  vdsa$GetStruct(objID=&parent.id, name="node_type", txt=parent.type);
  vdsa$GetStruct(objID=&parent.id, name="node_name", txt=parent.name);

  processNodeData(&parent);

  // Pump out common attributes
  VDxmlWriteObjBeg(xml,XML_PDF_TREE_NODE,1,1);
  VDxmlWriteAtrTxt(xml,XML_PDF_TREE_NODE_TYPE,  node.type,1,1);
  VDxmlWriteAtrTxt(xml,XML_PDF_TREE_NODE_NAME,  node.name,1,1);
  VDxmlWriteAtrTxt(xml,XML_PDF_TREE_NODE_STAGE, node.stage,1,1);
  VDxmlWriteAtrTxt(xml,XML_PDF_TREE_NODE_PARENT,parent.stage,1,1);
  VDxmlWriteAtrTxt(xml,XML_PDF_TREE_NODE_PATH,  node.path,1,1);
  VDxmlWriteAtrInt(xml,XML_PDF_TREE_NODE_QTY,   node.qty,1,1);

  // Handle nodes and leafs differently
  VDatGetBaseType(&node.id,&type);

  switch(type) {
    
  case VDAT_CLASSI_TREE:
  case VDAT_CLASSI_NODE:

    vdsa$GetStruct(objID = &node.id, name = "u_desc", txt = buf);
    VDxmlWriteAtrTxt(xml,XML_PDF_TREE_NODE_DESC,buf,1,1);

    vdsa$GetStruct(objID = &node.id, name = "u_notes", txt = buf);
    VDxmlWriteAtrTxt(xml,XML_PDF_TREE_NODE_NOTES,buf,1,1);

    vdsa$GetStruct(objID = &node.id, name = "u_notes_2", txt = buf);
    if (*buf) {  
      VDxmlWriteAtrTxt(xml,XML_PDF_TREE_NODE_NOTES2,buf,1,1);
    }
    vdsa$GetStruct(objID = &node.id, name = "u_notes_3", txt = buf);
    if (*buf) {  
      VDxmlWriteAtrTxt(xml,XML_PDF_TREE_NODE_NOTES3,buf,1,1);
    }
    vdsa$GetStruct(objID = &node.id, name = "u_notes_4", txt = buf);
    if (*buf) {  
      VDxmlWriteAtrTxt(xml,XML_PDF_TREE_NODE_NOTES4,buf,1,1);
    }
    vdsa$GetStruct(objID = &node.id, name = "u_notes_5", txt = buf);
    if (*buf) {  
      VDxmlWriteAtrTxt(xml,XML_PDF_TREE_NODE_NOTES5,buf,1,1);
    }

    vdsa$GetStruct(objID = &node.id, name = "u_platen", txt = buf);
    VDxmlWriteAtrTxt(xml,XML_PDF_TREE_NODE_PLATEN,buf,1,1);

    /* Sequence is actually text
     * This conversion should have worked
     */
    // vdsa$GetStruct(objID = &node.id, name = "u_sequence", jnt = &seq);
    vdsa$GetStruct(objID = &node.id, name = "u_sequence", txt = buf);
    seq = atoi(buf);
    VDxmlWriteAtrInt(xml,XML_PDF_TREE_NODE_SEQUENCE,seq,1,1);

    break;
    
  case VDAT_CLASSI_LEAF:

    vdsa$GetStruct(objID = &node.id, name = "pcmk", txt = buf);
    VDxmlWriteAtrTxt(xml,XML_PDF_TREE_NODE_PCMK,buf,1,1);

    vdsa$GetStruct(objID = &node.id, name = "u_notes", txt = buf);
    VDxmlWriteAtrTxt(xml,XML_PDF_TREE_NODE_NOTES,buf,1,1);

    vdsa$GetStruct(objID = &node.id, name = "u_notes_2", txt = buf);
    if (*buf) {  
      VDxmlWriteAtrTxt(xml,XML_PDF_TREE_NODE_NOTES2,buf,1,1);
    }
    vdsa$GetStruct(objID = &node.id, name = "u_notes_3", txt = buf);
    if (*buf) {  
      VDxmlWriteAtrTxt(xml,XML_PDF_TREE_NODE_NOTES3,buf,1,1);
    }
    vdsa$GetStruct(objID = &node.id, name = "u_notes_4", txt = buf);
    if (*buf) {  
      VDxmlWriteAtrTxt(xml,XML_PDF_TREE_NODE_NOTES4,buf,1,1);
    }
    vdsa$GetStruct(objID = &node.id, name = "u_notes_5", txt = buf);
    if (*buf) {  
      VDxmlWriteAtrTxt(xml,XML_PDF_TREE_NODE_NOTES5,buf,1,1);
    }
    
    vdsa$GetStruct(objID = &node.id, name = "u_destination", txt = buf);
    VDxmlWriteAtrTxt(xml,XML_PDF_TREE_NODE_DESTINATION,buf,1,1);

    // Couple more
    VDxmlWriteAtrTxt(xml,XML_PDF_TREE_NODE_FAMILY,  node.family,  1,1);
    VDxmlWriteAtrTxt(xml,XML_PDF_TREE_NODE_PART_NUM,node.part_num,1,1);
    VDxmlWriteAtrTxt(xml,XML_PDF_TREE_NODE_GRADE,   node.grade,   1,1);

    // Lengths and processes for beams
    if (!strcmp(node.type,"BEAM")) {
      VDxmlWriteAtrDbl(xml,XML_PDF_BEAM_3D_LENGTH,node.length,1,1);
      writeProcessesForBeam(xml,&node);
    }

    // Process for plates
    if (!strcmp(node.type,"PLATE")) {
      VDxmlWriteAtrDbl(xml,XML_PDF_BEAM_3D_LENGTH,node.length,1,1);
      writeProcessesForPlate(xml,&node);
    }

    
    break;
    
  }
  VDxmlWriteAtrEnd(xml,1,1);

  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* ---------------------------------------
 * need to do some special processing for
 * extracting the data to spades
 */
static IGRstat processNodeData(TVPextNodeData *node)
{
  VDASSERT_FN("processNodeData");
  IGRstat retFlag = 0;
  IGRstat sts;

  IGRchar *p;
  IGRchar  buf[128];
  IGRint   len;

  TGRobj_env pieceOE;

  // Arg check
  VDASSERTW(node);
  
  // Drop the prefix for node path
  p = strchr(node->path,' ');
  if (p) strcpy(node->path,p+1);

  // Split type and name for sa stuff
  if ((!strncmp(node->type,"SA",2)) && (strlen(node->type) == 3)) {
    strcpy(node->name,node->type+2);
    *(node->type+2) = 0;
  }

  // Format psu a bit special
  if (!strcmp(node->type,"PSU")) {
    len = strlen(node->name);
    if (len < 3) {
      strcpy(buf,"000");
      strcpy(buf + (3 - len),node->name);
      strcpy(node->name,buf);
    }
  }

  // Build the stage
  if (*node->type == 0) {
    strcpy(node->stage,"UNIT MD01");
  }
  else {
    if (*node->name == 0) strcpy(node->stage,node->type);
    else sprintf(node->stage,"%s %s",node->type,node->name);
  }

  // For pieces, got a bit further
  if (strcmp(node->type,"PM")) return 1;

  // Want either plate or beam
  VDatGetLeafObject(&node->id,&pieceOE);
  if (pieceOE.obj_id.objid == NULL_OBJID) return 1;

  sts = vdobj$IsAncestryValid(objOE = &pieceOE, superClassName = "VSplate");
  if (sts & 1) strcpy(node->type,"PLATE");

  sts = vdobj$IsAncestryValid(objOE = &pieceOE, superClassName = "VSbeam");
  if (sts & 1) {
    strcpy(node->type,"BEAM");
    vdsa$GetStruct(objOE = &pieceOE, name = "memb_cut_leng", dbl = &node->length);
    if (node->length < 10.0) {
      VLsmsLog1(1,1,"*** Invalid beam length(%.2f) for Piece %d\n",
		node->length,
		node->pcmk);
      VLsmsLog2(1,1,NULL,&pieceOE,NULL);
      VLsmsLog1(1,1,"---\n");
    }
  }
  sprintf(node->stage,"%s %s",node->type,node->pcmk);

  // Few extra attributes
  vdsa$GetStruct(objOE = &pieceOE, name = "family_name", txt = node->family);
  vdsa$GetStruct(objOE = &pieceOE, name = "part_num",    txt = node->part_num);
  vdsa$GetStruct(objOE = &pieceOE, name = "grade",       txt = node->grade);

  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* --------------------------------------------
 * Generates a string for testing for dups
 */
static IGRstat getDupStr(TGRid *dupID, IGRchar *dupStr)
{
  VDASSERT_FN("getDupStr");
  IGRstat retFlag = 1;

  IGRchar dupType[32];
  IGRchar dupName[32];

  vdsa$GetStruct(objID = dupID, name = "node_type", txt = dupType);
  vdsa$GetStruct(objID = dupID, name = "pcmk",      txt = dupName);
  if (*dupName == 0) {
    vdsa$GetStruct(objID = dupID, name = "node_name",txt = dupName);
  }
  sprintf(dupStr,"%s %s",dupType,dupName);

wrapup:
  return retFlag;
}

/* --------------------------------------------
 * Gets the node_qty for a given node
 * Came from ppl so does not use recursion
 */
static IGRstat getNodeQty(TGRid *qtyID, IGRint *qty)
{
  VDASSERT_FN("getNodeQty");
  
  IGRstat retFlag = 1;
  
  IGRstat flag;
  IGRint  i;

  TGRid qtyParentID;
  TGRid wrkID;

  IGRchar qtyStr[128];
  IGRchar wrkStr[128];

  // Usual case
  *qty = 1;

  // With respect to the parent
  VDatGetParentNode(qtyID,&qtyParentID);
  if (qtyParentID.objid == NULL_OBJID) goto wrapup;
  
  // Compare against siblings
  flag = 0;
  getDupStr(qtyID,qtyStr);
  //printf("Dup Str %s\n",qtyStr);
  
  for(i = 0; VDatGetChildObject(&qtyParentID,i,&wrkID); i++) {

    // Get myself?
    if (qtyID->objid == wrkID.objid) {
      flag = 1;
    }
    else {
      getDupStr(&wrkID,wrkStr);
      if (!strcmp(qtyStr,wrkStr)) {

        if (flag) *qty = *qty + 1;
        else {
          *qty = 0;
          goto wrapup;
        }
      }
    }
  }

  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

end implementation Root;
