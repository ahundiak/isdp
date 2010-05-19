 /* $Id: VDct1RootTreeX.c,v 1.1 2001/01/14 16:29:17 art Exp $  */
/***************************************************************************
 * I/VDS
 *
 * File:        vdct1/tree/VDct1RootTreeX.C
 *
 * Description: XML implementations
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDct1RootTreeX.c,v $
 *      Revision 1.1  2001/01/14 16:29:17  art
 *      sp merge
 *
 * Revision 1.3  2000/08/24  13:48:16  pinnacle
 * ah
 *
 * Revision 1.2  2000/08/17  11:39:26  pinnacle
 * js
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 07/10/00  ah      Creation
 ***************************************************************************/
#include "VDtypedefc.h"
#include "VDct1.h"
#include "VDct1Tree.h"
#include "VDct1Forms.h"
#include "VDct1Trace.h"

#include "VDassert.h"

VDASSERT_FFN("vdct1/tree/VDct1RootTreeX.c");

#define MY_TREE VDCT1_TREE_TYPE_ROOT_TREE

/* -------------------------------------------
 * Read xml schema file or buffer and extract
 * the set defination
 */
static IGRstat readSchema(TVDct1JD *nodeJD, IGRchar *fileName, IGRchar *buf)
{
  return 1;
}

/* -------------------------------------------
 * Writes the top set node
 */
static IGRstat writeSetBeg(TVDct1JD *nodeJD, TVDxmlFileInfo *xml)
{
  IGRstat retFlag = 0;

  TVDctBaseInfo baseInfo;
  
  // Make sure got a node
  if ((nodeJD == NULL) || (nodeJD->id.objid == NULL_OBJID)) goto wrapup;

  // Need the base info
  _RTCJDB(nodeJD)->getBaseInfo(nodeJD,&baseInfo);
  if (*baseInfo.setType == 0) goto wrapup;

  // Write header
  VDxmlWriteObjBeg(xml,baseInfo.setType,1,0);
  VDxmlWriteAtrTxt(xml,"set_type", baseInfo.setType, 0,0);
  VDxmlWriteAtrTxt(xml,"set_name", baseInfo.setName, 0,0);
  VDxmlWriteAtrEnd(xml,0,1);

  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -------------------------------------------
 * Writes the top set node ending
 */
static IGRstat writeSetEnd(TVDct1JD *nodeJD, TVDxmlFileInfo *xml)
{
  IGRstat retFlag = 0;

  TVDctBaseInfo baseInfo;
  
  // Make sure got a node
  if ((nodeJD == NULL) || (nodeJD->id.objid == NULL_OBJID)) goto wrapup;

  // Need the base info
  _RTCJDB(nodeJD)->getBaseInfo(nodeJD,&baseInfo);
  if (*baseInfo.setType == 0) goto wrapup;

  // Write Trailer
  VDxmlWriteObjEnd(xml,baseInfo.setType,1);

  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -------------------------------------------
 * Writes one node to an xml info
 * recursive routine to write sub nodes
 */
static IGRstat writeNode(TVDct1JD *nodeJD, TVDxmlFileInfo *xml)
{
  IGRstat retFlag = 0;

  TVDctBaseInfo baseInfo;

  IGRint  j;

  TVDfldS flds;

  TVDct1JD childJD;
  
  // Make sure got a node
  if ((nodeJD == NULL) || (nodeJD->id.objid == NULL_OBJID)) goto wrapup;

  // Need the base info
  _RTCJDB(nodeJD)->getBaseInfo(nodeJD,&baseInfo);
  if (*baseInfo.nodeType == 0) goto wrapup;

  // Write header
  VDxmlWriteObjBeg(xml,baseInfo.nodeType,1,1);
  
  // Write standard attribute
  VDxmlWriteAtrTxt(xml,"node_type",baseInfo.nodeType,1,0);
  VDxmlWriteAtrTxt(xml,"node_name",baseInfo.nodeName,1,1);
  VDxmlWriteAtrTxt(xml,"set_type", baseInfo.setType, 1,0);
  VDxmlWriteAtrTxt(xml,"set_name", baseInfo.setName, 1,1);

  // Write rest of the attributes
  VDctxGetAttrs(&nodeJD->id,&flds.cnt,flds.fld);

  for(j = 0; j < flds.cnt; j++) {
    VDxmlWriteAtrTxt(xml,flds.fld[j].name,flds.fld[j].val.txt,1,1);
  }
  VDxmlWriteAtrEnd(xml,1,1);
  
  // Write sub objects
  childJD.cl = nodeJD->cl;
  for(j = 0; _RTCJDB(nodeJD)->getTreeChild(nodeJD,j,&childJD); j++) {
    writeNode(&childJD,xml);
  }
  
  // Write trailer
  VDxmlWriteObjEnd(xml,baseInfo.nodeType,1);
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Converts node to xml buffer string
 */
static IGRstat writeBuf(TVDct1JD *nodeJD, IGRchar **xmlBuf)
{
  VDASSERT_FN("writeBuf");
  IGRstat retFlag = 0;
  IGRstat sts;
  
  TVDxmlFileInfo xml;

  // Arg check
  if (xmlBuf) *xmlBuf = NULL;
  if ((nodeJD == NULL) || (nodeJD->cl)) goto wrapup;
  
  // Open the buffer, let it do all the allocating
  sts = VDxmlOpenOutputStream(&xml,NULL,NULL,NULL,NULL,0,0,0,1.0,1);
  VDASSERTW(sts & 1);
  
  // Write it out
  writeSetBeg(nodeJD,&xml);
  _RTCJDX(nodeJD)->writeNode  (nodeJD,&xml);
  writeSetEnd(nodeJD,&xml);

  // Close It
  VDxmlCloseOutputStream(&xml);
  
  // Error check
  if (xml.io.buf == NULL) goto wrapup;
  
#if 1
  // Print It
  printf("----------------------------------------\n");
  fputs(xml.io.buf,stdout);
#endif

  // Return it
  if (xmlBuf) *xmlBuf = xml.io.buf;
  else        free(xml.io.buf);  // Cleanup
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Write out schema file
 */
static IGRstat writeFile(TVDct1JD *setJD,
			 IGRchar  *fileName,
			 IGRchar  *results)
{
  VDASSERT_FN("writeFile");
  
  IGRstat retFlag = 0;
  IGRstat sts;
  
  IGRchar fileNamex[128];

  IGRchar msg[256],*p;

  TVDxmlFileInfo xml;
  TVDctBaseInfo baseInfo;
  
  // Init
  memset(&xml,0,sizeof(TVDxmlFileInfo));

  // Arg check
  if (results == NULL) results = msg;
  *results = 0;
  
  // Need a node type and name
  _RTCJDB(setJD)->getBaseInfo(setJD,&baseInfo);
  if (*baseInfo.setType == 0) {
    sprintf(results,"Node Not selected");
    goto wrapup;
  }
  
  // Use passed name or make it's own
  if (fileName == NULL) {  
    // Build the filename
    fileName = fileNamex;
    sprintf(fileName,"%s_%s.xml",baseInfo.setType,baseInfo.setName);
  }
  
  // Open it
  sts = VDxmlOpenOutputStream(&xml,fileName,NULL,NULL,NULL,0,0,0,1.0,1);	
  if (!(sts & 1)) {
    sprintf(results,"Problem opening %s",fileName);
    goto wrapup;
  }
  
  // Hand off for the real work
  writeSetBeg(setJD,&xml);
  _RTCJDX(setJD)->writeNode  (setJD,&xml);
  writeSetEnd(setJD,&xml);
  
  // Close and done
  VDxmlCloseOutputStream(&xml);
  sprintf(results,"WROTE %s",fileName);
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Write out schema for a node
 */
static IGRstat writeSchemaNode(TVDct1JD          *setJD,
			       TVDxmlFileInfo    *xml,
			       TVDctNodeTypeInfo *nodeTypeInfo)
{
  IGRstat retFlag = 0;
  
  IGRint i;
  IGRchar   name[80];
  TVDctAttrInfo info;
  
  // Arg check
  if (xml == NULL)          goto wrapup;
  if (nodeTypeInfo == NULL) goto wrapup;
  
  // Dump the node
  VDxmlWriteObjBeg(xml,"node",1,0);
  VDxmlWriteAtrTxt(xml,"node_type", nodeTypeInfo->type, 0,0);
  VDxmlWriteAtrTxt(xml,"node_desc", nodeTypeInfo->desc, 0,0);    
  VDxmlWriteAtrTxt(xml,"node_level",nodeTypeInfo->level,0,0);
  VDxmlWriteAtrTxt(xml,"node_table",nodeTypeInfo->table,0,0);
  VDxmlWriteAtrEnd(xml,0,1);

  // Cycle through attributes
  for(i = 0; 
      _RTCJDB(setJD)->getNodeAttrName(setJD,nodeTypeInfo->type,i,name);
      i++ ){

    // Get full info for each attribute
    _RTCJDB(setJD)->getNodeAttrInfo(setJD,name,&info);

    // Write it out
    VDxmlWriteObjBeg(xml,"attr",1,0);
    VDxmlWriteAtrTxt(xml,"attr_name",info.name,0,0);
    VDxmlWriteAtrInt(xml,"attr_type",info.type,0,0);
    VDxmlWriteAtrInt(xml,"attr_len", info.len, 0,0);
    VDxmlWriteAtrTxt(xml,"attr_base",info.base,0,0);
    VDxmlWriteAtrTxt(xml,"attr_desc",info.desc,0,0);
    VDxmlWriteAtrEnd(xml,0,0);    
    VDxmlWriteObjEnd(xml,"attr",0);
  }
    
  // End of node
  VDxmlWriteObjEnd(xml,"node",1);

  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Write out schema for the complete set
 */
static IGRstat writeSchemaSet(TVDct1JD       *setJD,
			      TVDxmlFileInfo *xml)
{
  IGRstat retFlag = 0;

  IGRint i;
  
  TVDctSetTypeInfo   setTypeInfo;
  TVDctNodeTypeInfo nodeTypeInfo;
  
  // Arg check
  if (xml == NULL) goto wrapup;

  // Get the info
  _RTCJDB(setJD)->getSetTypeInfo(setJD,&setTypeInfo);
  
  // The set object
  VDxmlWriteObjBeg(xml,"set",1,0);


  VDxmlWriteAtrTxt(xml,"set_type",setTypeInfo.type,0,0);
  VDxmlWriteAtrTxt(xml,"set_rev", setTypeInfo.rev, 0,0);
  VDxmlWriteAtrTxt(xml,"set_desc",setTypeInfo.desc,0,0);

  VDxmlWriteAtrTxt(xml,"set_node_table",setTypeInfo.nodeTable,0,0);
  VDxmlWriteAtrTxt(xml,"set_leaf_table",setTypeInfo.leafTable,0,0);

  VDxmlWriteAtrEnd(xml,0,1);
 
  // Cycle through nodes
  for(i = 0;
      _RTCJDB(setJD)->getNodeTypeInfo(setJD,i,NULL,&nodeTypeInfo);
      i++) {

    // Hand it off
    _RTCJDX(setJD)->writeSchemaNode(setJD,xml,&nodeTypeInfo);
    
  }
  
  // Finish set object
  VDxmlWriteObjEnd(xml,"set",1);

  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Write out schema file
 */
static IGRstat writeSchemaFile(TVDct1JD *setJD,
			       IGRchar  *fileName,
			       IGRchar  *results)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  
  IGRchar fileNamex[128];

  IGRchar msg[256],*p;

  TVDxmlFileInfo xml;

  // Init
  memset(&xml,0,sizeof(TVDxmlFileInfo));

  // Arg check
  if (results == NULL) results = msg;
  *results = 0;
  
  // Use passed name or make it's own
  if (fileName == NULL) {
    
    // Build the filename
    fileName = fileNamex;
    sprintf(fileName,"%s.xml",_RTCJDBC(setJD));
  }
  
  // Open it
  sts = VDxmlOpenOutputStream(&xml,fileName,NULL,NULL,NULL,0,0,0,1.0,1);	 
  if (!(sts & 1)) {
    sprintf(results,"Problem opening %s",fileName);
    goto wrapup;
  }
  
  // Hand off for the real work
  _RTCJDX(setJD)->writeSchemaSet(setJD,&xml);
  
  // Close and done
  VDxmlCloseOutputStream(&xml);
  sprintf(results,"WROTE %s",fileName);
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Inits these pointers
 */
IGRstat VDct1InitRootTreeClassX(TVDct1RootTreeClass *cl)
{
  VDASSERT_FN("VDct1InitRootTreeClassX");
  
  IGRstat retFlag = 0;

  // Tracing
  traceFlagx = traceFlag = VDct1TraceFlag(VDCT1_TRACE_TREE_XML);

  // Fill up pointers

  // XML Output
  cl->xml.writeBuf  = writeBuf;
  cl->xml.writeFile = writeFile;
  cl->xml.writeNode = writeNode;

  // XML Schema Output
  cl->xml.writeSchemaFile = writeSchemaFile;
  cl->xml.writeSchemaSet  = writeSchemaSet;
  cl->xml.writeSchemaNode = writeSchemaNode;

  // XML Input
  cl->xml.readSchema = readSchema;
  
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}
