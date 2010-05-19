/* $Id: VDatXml.c,v 1.2 2001/02/11 17:44:09 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdat/post/VDatPdm.I
 *
 * Description: XML Processing
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDatXml.c,v $
 *      Revision 1.2  2001/02/11 17:44:09  ahundiak
 *      Renamed VDris2 to VDrisc
 *
 *      Revision 1.1  2001/01/11 21:06:42  art
 *      sp merge
 *
 * Revision 1.1  2000/10/15  13:51:40  pinnacle
 * ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 09/26/00  ah      creation
 ***************************************************************************/
#include "VDtypedefc.h"
#include "VDxml.h"
#include "VDrisc.h"
#include "VDat.h"
#include "VDassert.h"

VDASSERT_FFN("vdat/post/VDatXml.c");

/* -----------------------------------------------
 * Recursive routine to write an xml node
 */
static IGRstat VDatWriteNodeToXmlFile(TVDxmlFileInfo *info, TGRid *nodeID)
{
  VDASSERT_FN("VDatWriteNodeToXmlFile");
  
  IGRstat retFlag = 0;
  TGRid   childID;
  IGRint  i;
  
  IGRchar nodeType[40];

  TVDatFld  flds[32];
  TVDatFld *fld;
  IGRint    cnt;
  
  // Arg check
  VDASSERTW(nodeID);
  
  // See if done
  if (nodeID->objid == NULL_OBJID) {
    retFlag = 1;
    goto wrapup;
  }

  // Need node type 
  VDatRDBGetNodeType(nodeID,nodeType);
  if (*nodeType == 0) {
    retFlag = 1;
    goto wrapup;
  }  
  VDxmlWriteObjBeg(info,nodeType,1,1);

  // Get the attributes
  VDatFldGetAllAttrs(nodeID,flds,&cnt);
  VDASSERTW(cnt < 32);
  for(i = 0; i < cnt; i++) {
    fld = &flds[i];

    switch(fld->type) {
      
      case VDAT_FLD_TYPE_CHAR:
	VDxmlWriteAtrTxt(info,fld->name,fld->valueTxt,1,1);
	break;

      case VDAT_FLD_TYPE_SMALLINT:
      case VDAT_FLD_TYPE_INT:
	VDxmlWriteAtrInt(info,fld->name,fld->valueInt,1,1);
	break;

      case VDAT_FLD_TYPE_REAL:
      case VDAT_FLD_TYPE_DOUBLE:
	VDxmlWriteAtrDbl(info,fld->name,fld->valueDbl,1,1);
      break;

      default:
	printf("Unknown field type, AT Tree To XML %s\n",fld->name);
    }
  }
  VDxmlWriteAtrEnd(info,1,1);
  
  // Cycle through kids
  for(i = 0; VDatGetChildObject(nodeID,i,&childID); i++) {
    VDatWriteNodeToXmlFile(info,&childID);
  }
  
  // Done with object
  VDxmlWriteObjEnd(info,nodeType,1);
  
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Write an xml file for set
 */
IGRstat VDatWriteXmlFile(IGRchar *setType, IGRchar *setName, IGRchar *fileName)
{
  VDASSERT_FN("VDatWriteXmlFile");
  
  IGRstat retFlag = 0;
  TGRid   setID;
  TGRid   treeID;
  
  TVDxmlFileInfo info;
  IGRchar cmd[256];
  
  // Arg check
  VDASSERTW( setType &&  *setType);
  VDASSERTW( setName &&  *setName);
  VDASSERTW(fileName && *fileName);
  
  // Say Hi
  if (traceFlag) {
    printf(">>> %s %s %s\n",fn,setType,setName);
  }

  // Grab the set
  VDatGetSetByTypeName(setType,setName,&setID);
  VDASSERTW(setID.objid != NULL_OBJID);
  //printf("Object %d,%d\n",setID.osnum,setID.objid);
  
  // Grab the tree
  VDatGetTree(&setID,&treeID);
  VDASSERTW(treeID.objid != NULL_OBJID);
  //printf("Object %d,%d\n",treeID.osnum,treeID.objid);

  // Open
  VDxmlOpenOutputFile(&info,fileName,setType,setType);
  VDxmlWriteObjBeg(&info,setType,0,1);

  // Write it
  VDatWriteNodeToXmlFile(&info,&treeID);
  
  // Close
  VDxmlWriteObjEnd(&info,setType,0);
  VDxmlCloseOutputFile(&info);

  // Set the permissions
  sprintf(cmd,"/bin/chmod 777 %s 2> /dev/null",fileName);  
  system (cmd);

  // Done
  // system("cat test.xml");
  retFlag = 1;
  
 wrapup:
  if (traceFlag) {
    printf(">>> %s %s %s %d\n",fn,setType,setName,retFlag);
  }
  return retFlag;
}

/* -----------------------------------------------
 * Test the xml stuff
 */
IGRstat VDatTestWriteXmlFile()
{
  VDASSERT_FN("VDatTestWriteXmlFile");
  
  IGRstat retFlag = 0;
  IGRchar set_name[20];
  IGRchar set_type[20];
  
  strcpy(set_type,"StagingTree");
  VDatGetSetNameForType(set_type,set_name);
  VDASSERTW(*set_name);
  
  printf("------------%s %s----------------------------\n",fn,set_name);
  
  VDatWriteXmlFile(set_type,set_name,"test.xml");
  
  retFlag = 1;
  
 wrapup:
  return retFlag;
}




