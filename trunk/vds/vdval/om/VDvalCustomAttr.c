/* $Id: VDvalCustomAttr.c,v 1.1.2.2 2004/11/29 16:17:31 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdval/om/VDvalCustomAttr.c
 *
 * Description:	Be able to specify additional attributes dumped by Snapshot.
 *
 * Dependencies:
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 *
 * 10/10/03  Anand   Creation
 * 09/27/04  ah      Removed warning when file not found
 ***************************************************************************/

#include "VDtypedefc.h"
#include "VDassert.h"
#include "VDlog.h"
#include "VDrisc.h"
#include "VDtest.h"
#include "VDxdom.h"
#include "VDctx.h"
#include "VDval.h"

VDASSERT_FFN("VDvalCustomAttr.c");

static struct 
{
  TGRid           CustomIDs;
  TGRid		  findID;
  TVDctxNodeList  nameList;
} *info;

/* -----------------------------------------------
 * Get the tolerances from xml file
 */
static void VDvalFileCustomAttr(TGRid *CustomIDs)
{
  VDASSERT_FN("VDvalFileCustomAttr");

  IGRchab path;
  
  // Arg check
  VDASSERTW(CustomIDs); CustomIDs->objid = NULL_OBJID;

  // Find the file
  VDsysFindFile("config/xml","ss_custom.xml",path);
  if (*path == 0)
      goto wrapup;
  
  VDxdomCreateTreeFromXmlFile(path,CustomIDs);

wrapup:
  return;
}
/* -----------------------------------------------
 * Index on name
 */
static IGRint compareName(const void *p1, const void *p2) 
{
  TGRid *node1ID = (TGRid*)p1;
  TGRid *node2ID = (TGRid*)p2;
  
  IGRchab name1,name2;
  
  VDctxGetTxtAtr(node1ID,"name",name1); strlwr(name1);
  VDctxGetTxtAtr(node2ID,"name",name2); strlwr(name2);
  
  return strcmp(name1,name2);
}

static void indexName()
{
  VDASSERT_FN("indexName");
  
  // Build the list
  VDctxGetNodeListByType(&info->CustomIDs,"class",&info->nameList);
  
  // Sort em
  VDctxSortNodeList(&info->nameList,compareName);
  
  // For searching
  VDxdomCreateTree("find",&info->findID);
  
wrapup:
  return;
}

/* -----------------------------------------------
 * get the Custom Attribute tree, creating one if necessary
 */
void VDvalGetCustomAttributeTree(TGRid *CustomIDs)
{
    VDASSERT_FN("VDvalGetCustomAttributeTree");

    // Arg check
    VDASSERTW(CustomIDs); CustomIDs->objid = NULL_OBJID;

    // See if it is already loaded
    if (info)
    {
	*CustomIDs = info->CustomIDs;
	goto wrapup;
    }

    // If it gets here, info needs to be allocated.
    info = calloc(1,sizeof *info);
    VDASSERTW(info);
    info->CustomIDs.objid = NULL_OBJID;

    // Load in text file
    VDvalFileCustomAttr(&info->CustomIDs);
    if (info->CustomIDs.objid == NULL_OBJID) 
    {
	// Do the warning 
/*
	VDlogPrintFmt(VDLOG_WARN, 1,
		      "*** Unable to load custom attribute (ss_custom.xml)");
*/
	goto wrapup;
    }
    indexName();
    *CustomIDs = info->CustomIDs;

wrapup:
    return;
}


IGRstat VDvalGetCustomAttrClassNode(IGRchar *className, TGRid *classID)
{
    VDASSERT_FN("VDvalGetCustomAttrClassNode");

    IGRstat retFlag = 0;

    TGRid  CustomIDs;
    TGRid *foundID=NULL;

    // Argcheck
    VDASSERTW(classID); classID->objid = NULL_OBJID;
    VDASSERTW(className && *className);

    // Verify that the Custom Attribute tree exists.
    VDvalGetCustomAttributeTree(&CustomIDs);
    if (CustomIDs.objid == NULL_OBJID) goto wrapup;

    // Use the indexed info
    VDctxAppTxtAtr(&info->findID,"name",className);  
    foundID = VDctxSearchNodeList(&info->findID,&info->nameList,compareName);
    if (foundID != NULL)
    {
	// Get it
	classID->objid = foundID->objid;
	classID->osnum = foundID->osnum;
	retFlag = 1;
    }

wrapup:
    return retFlag;
}
