/* $Id: VDct1Assy.C,v 1.2 2001/03/12 20:36:31 jdsauby Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdct1/set/VDct1Assy.I
 *
 * Description: Set Routines
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDct1Assy.C,v $
 *      Revision 1.2  2001/03/12 20:36:31  jdsauby
 *      Cleaned out unnecessary functions from vdct1/set
 *
 *      Revision 1.1  2001/01/12 14:53:34  art
 *      sp merge
 *
 * Revision 1.1  2000/07/25  18:38:22  pinnacle
 * ah
 *
# Revision 1.2  2000/05/11  13:26:04  pinnacle
# Replaced: vds/vdct1/set/VDct1Assy.I for:  by pnoel for Service Pack
#
# Revision 1.1  2000/04/20  18:40:42  pinnacle
# Created: vds/vdct1/set/VDct1Assy.I by pnoel for Service Pack
#
# Revision 1.2  2000/01/11  22:26:02  pinnacle
# ah
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 08/03/99  ah      Creation
 * 05/11/00  pn      updated much in Attribute mgt and new form changes
 ***************************************************************************/

#include "VDct1.h"
#include "VDobj.h"
#include "VDdir.h"
#include "VDris.h"
#include "VDppl1.h"

#include "VDvla.h"

#include "VDassert.h"

VDASSERT_FFN("vdct1/set/VDct1Assy.C");
#if 0
/* ---------------------------------------------
 * Loads the noun names from the database
 */
IGRstat VDct1AddStandardPartFamilies(TGRid *treeID)
{
  IGRstat retFlag = 0;
  IGRstat sts;

  IGRint  rows,cols,i;
  IGRchar **buf = NULL;
  
  IGRchar qry[256];
  TGRid   nodeID;

  // Arg Check
  if ((treeID == NULL) || (treeID->objid == NULL_OBJID)) goto wrapup;
  sts = VDSverify_login();
  if (!(sts & 1)) goto wrapup;

  // Get the list
  sprintf(qry,"Select distinct noun_name from ost_type4 order by noun_name;");
  
  rows = cols = 0; buf = NULL;
  sts = VDSsql_query(qry, &cols, &rows, &buf);

  // Verify got something
  if (!(sts & 1) || (rows < 0) || (cols != 1) || (buf == NULL)) {
    UI_status("Query for noun_names failed");
    goto wrapup;
  }
  
  // Cycle through
  for(i = 0; i < rows; i = i + 1) {

    vdct1$CreateNode(parentID = treeID,
                     nodeType = "NOUN_NAME",
                     nodeName =  buf[i],
                     nodeID   = &nodeID);

  }
  
  // Free the buffer
  VdsRisFreeBuffer(buf, rows * cols);

  // Done
  retFlag = 1;

wrapup:
  return retFlag;
}
#endif
/* -------------------------------------------
 * Creates the standard library
 */
IGRstat VDct1CreateStandardLibrary()
{
  IGRstat retFlag = 0;
  IGRstat sts;

  TGRid   mgrID;
  TGRid   setID;

  TVDctBaseInfo baseInfo;

  // Do nothing is not logged in
  sts = VDSverify_login();
  if (!(sts & 1)) goto wrapup;

  // See if already have one
  strcpy(baseInfo.setType,"StdParts");
  strcpy(baseInfo.setName,"OPS");
  vdct1$FindSetByName(baseInfo = &baseInfo,
		      setID    = &setID);

  if (setID.objid != NULL_OBJID) {
    vdct1$DeleteNode(nodeID = &setID);
  }

  // Create in transient space
  vdct1$GetManager(osnum = VDtraOS, mgrID = &mgrID);
  if (mgrID.objid == NULL_OBJID) {
    vdct1$CreateManager(osnum = VDtraOS, mgrID = &mgrID);
  }
  if (mgrID.objid == NULL_OBJID) {
    printf("Could not find the transient manager\n");
    goto wrapup;
  }
  
  // Create the set which also creates the noun name listing
  vdct1$CreateSet(mgrID   = &mgrID, 
                  setType = baseInfo.setType, 
                  setName = baseInfo.setName, 
                  setID   = &setID);

  // Done
  retFlag = 1;

wrapup:
  return retFlag;
}
#if 0
/* -------------------------------------------------------------
 * Finds the standard assembly defination node in the given tree
 * Recursive routine
 */
IGRstat VDct1SearchForStandardAssemblyInTree(
  TGRid   *nodeID, 
  IGRchar *name, 
  TGRid   *saID)
{
  IGRstat retFlag = 0;
  TVDctBaseInfo baseInfo;
  IGRchar namex[128];
  IGRchar *p;

  IGRint i;
  TGRid  childID;
  
  // Args are already set

  // Check if done
  if (nodeID->objid == NULL_OBJID) goto wrapup;
  
  // Key off nodeName for now
  vdct1$GetBaseInfo(objID = nodeID, baseInfo = &baseInfo);
  if (!strcmp(baseInfo.nodeType,"ASSY")) {
    
    // Got to sort of cleanup the nodeType
    strcpy(namex,baseInfo.nodeName);
    VDstrupr(namex);
    p = strchr(namex,'.'); if (p) strcpy(namex,p+1);
    p = strchr(namex,'-'); if (p) strcpy(p,p+1);
    
    // Check it
    if (!strcmp(name,namex)) {
      *saID = *nodeID;
      retFlag = 1;
      goto wrapup;
    }
  }
  
  // Try each kid
  for(i = 0; vdct1$GetTree1Child(objID = nodeID, nth = i, outID = &childID); i++) {

    VDct1SearchForStandardAssemblyInTree(&childID,name,saID);
    if (saID->objid != NULL_OBJID) {
      retFlag = 1;
      goto wrapup;
    }
  }
  
wrapup:
  return retFlag;
}
#endif

#if 0
/* -----------------------------------------------------------
 * Finds the standard assembly defination node for the input
 */
IGRstat VDct1SearchForStandardAssembly(IGRchar *a_name, TGRid *a_saID)
{
  IGRstat retFlag = 0;

  IGRint  i;
  VDosnum osnum;
  IGRchar name[128];
  TGRid   mgrID,setID,treeID;
  
  TVDctBaseInfo baseInfo;
  
  // Arg check
  if (a_saID == NULL) goto wrapup;
  a_saID->objid = NULL_OBJID;
  if (a_name == NULL) goto wrapup;
  strcpy(name,a_name);
  VDstrupr(name);
  if (*name == 0) goto wrapup;

  // Find all sa trees
  // Cycle through each os
  for(osnum = 0; vdos$Validate(osnum = osnum); osnum++) {

    // Grab the manager
    vdct1$GetManager(osnum = osnum, mgrID = &mgrID);
    if (mgrID.objid != NULL_OBJID) {
      
      // Cycle through each set
      for(i = 0; vdct1$GetMgrChild(objID = &mgrID, nth = i, outID = &setID); i++) {
	
	// Filter by set type
	vdct1$GetBaseInfo(objID = &setID, baseInfo = &baseInfo);
	if (!strcmp("StdAssys",baseInfo.setType)) {
	  
	  // Get the real tree
	  vdct1$GetMgrChild(objID = &setID, nth = 0, outID = &treeID);
	  
	  // Recursive Search
	  VDct1SearchForStandardAssemblyInTree(&treeID,name,a_saID);
	  if (a_saID->objid != NULL_OBJID) {
	    retFlag = 1;
	    goto wrapup;
	  }
	}
      }
    }
  }

  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

#endif

















