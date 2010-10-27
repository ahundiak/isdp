/* $Id: VDatTest.I,v 1.1.1.1 2001/01/04 21:07:43 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdat/set/VDatTest.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDatTest.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:43  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.8  1998/01/25  19:08:30  pinnacle
# AssyTree
#
# Revision 1.7  1998/01/07  17:45:58  pinnacle
# 2.4.3.10
#
# Revision 1.6  1997/12/30  21:29:08  pinnacle
# AssyTree
#
# Revision 1.5  1997/12/10  22:32:12  pinnacle
# AssyTree
#
# Revision 1.4  1997/12/04  15:55:32  pinnacle
# AssyTree
#
# Revision 1.3  1997/12/03  19:26:42  pinnacle
# AssyTree
#
# Revision 1.2  1997/12/01  18:52:42  pinnacle
# AssyTree
#
# Revision 1.1  1997/11/28  21:56:32  pinnacle
# AssyTree
#
 *
 * History:
 *      MM/DD/YY  AUTHOR  DESCRIPTION
 *      11/25/97  ah      creation
 *
 ***************************************************************************/

class implementation VDatBase;

/* -------------------------------------------------
 * Tests some of the rdb stuff
 */

/* -------------------------------------------------
 * Sample for cycling through all leafs in tree/node
 */
IGRstat VDatTestTrees()
{
  IGRstat retFlag = 0;

  TVDvlaID  setVLA;
  TVDvlaID leafVLA;

  TGRid mgrID;
  TGRid setID;
  TGRid leafID;
  TGRid treeID;
  TGRid nodeID;
  TGRid postID;

  IGRint leafI;

  // Init vla
  VDvlaID_Construct(&setVLA);
  VDvlaID_Construct(&leafVLA);

  // Get the manager
  vdat$GetSetMgr(mgrID = &mgrID);
  if (mgrID.objid == NULL_OBJID) {
    printf("Could not find manager\n");
    goto wrapup;
  }
  VDbroPrintObj(&mgrID);

  // Get First set
  VDatGetSetsVLA(&mgrID, &setVLA);
  VDvlaID_GetAt (&setVLA,&setID,0);
  VDbroPrintObj (&setID);

  VDatRDBGetPost(&setID,&postID);
  VDbroPrintObj (&postID);

  // Get tree
  VDatGetTree(&setID,&treeID);
  if (treeID.objid == NULL_OBJID) goto wrapup;
  VDbroPrintObj (&treeID);

  VDatRDBGetPost(&treeID,&postID);
  VDbroPrintObj (&postID);

  // Pick off a node
  VDatGetChildObject(&treeID,1,&nodeID);
  if (nodeID.objid == NULL_OBJID) goto wrapup;
  VDbroPrintObj (&nodeID);

  VDatRDBGetPost(&nodeID,&postID);
  VDbroPrintObj (&postID);

  // Find all leafs in the node
  VDvlaID_Empty  (&leafVLA);
  VDatGetLeafsVLA(&nodeID,&leafVLA);

  // For each leaf
  for(leafI = 0; VDvlaID_GetAt(&leafVLA,&leafID,leafI); leafI++) {
    VDbroPrintObj(&leafID);
    if (leafI == 4) {
      VDatRDBGetPost(&leafID,&postID);
      VDbroPrintObj (&postID);
    }
  }

  printf("\n===================\n");

  // Test the get node
  VDvlaID_Empty  (&leafVLA);
  VDatGetNodesVLA(&nodeID,&leafVLA);

  // For each node
  for(leafI = 0; VDvlaID_GetAt(&leafVLA,&leafID,leafI); leafI++) {
    VDbroPrintObj(&leafID);
  }

wrapup:
  VDvlaID_Delete(&setVLA);
  VDvlaID_Delete(&leafVLA);

  return retFlag;
}

/* ---------------------------------------------
 * Sample for cycling through all leafs in all sets
 */
IGRstat VDatTestSets()
{
  IGRstat retFlag = 0;

  TVDvlaID  setVLA;
  TVDvlaID leafVLA;

  TGRid mgrID;
  TGRid setID;
  TGRid leafID;
  TGRid postID;

  IGRint setI,leafI;

  IGRchar tableName[128];

  TVDatFld flds[VDAT_FLD_MAX];
  IGRint   fldCnt;

  TGRobj_env modelOE;

  // Init vla
  VDvlaID_Construct(&setVLA);
  VDvlaID_Construct(&leafVLA);

  // Get the manager
  vdat$GetSetMgr(mgrID = &mgrID);
  if (mgrID.objid == NULL_OBJID) {
    printf("Could not find manager\n");
    goto wrapup;
  }
  VDbroPrintObj(&mgrID);

  // Get list of sets
  VDatGetSetsVLA(&mgrID,&setVLA);

  // For each set
  for(setI = 0; VDvlaID_GetAt(&setVLA,&setID,setI); setI++) {

    VDbroPrintObj(&setID);

    // Get post table for set
    VDatRDBGetPost(&setID,&postID);
    VDbroPrintObj(&postID);

    // Name of table
    VDatRDBGetTableName(&postID,tableName);

    // Get list of leafs
    VDvlaID_Empty(&leafVLA);
    VDatGetLeafsVLA(&setID,&leafVLA);

    // For each leaf
    for(leafI = 0; VDvlaID_GetAt(&leafVLA,&leafID,leafI); leafI++) {

      VDbroPrintObj(&leafID);

      // Get All Attributes
      VDatFldGetAllAttrs(&leafID,flds,&fldCnt);

      // Get the object linked to it
      VDatGetLeafObject(&leafID,&modelOE);
    
    }
  }

wrapup:
  VDvlaID_Delete(&setVLA);
  VDvlaID_Delete(&leafVLA);

  return retFlag;
}

/* ---------------------------------------------
 * The first test build routines
 */
IGRstat VDatBuild0(int flag)
{
  IGRstat retFlag = 0;
  IGRstat sts;

  TGRid  mgrID;
  TGRid  set1ID,  set2ID,   set3ID;
  TGRid tree1ID, tree2ID;//tree3ID;
  TGRid leafID;

  TGRid rdbSetID;

  TGRid stagePieceID,stagePanelID;
  TGRid stageUnitID, stageSaID, stagePsaID;
  TGRid stageCpsuID, stagePsuID;
  
  TVDvlaOE   objVLA;
  TGRobj_env objOE;
  IGRuint    i;

  TVDvlaID   childVLA;

  IGRint  saNum;
  IGRchar saName[128];
  TGRid   saID;

  IGRint  psuNum;
  IGRchar psuName[128];
  TGRid   psuID;

  TGRid   pdmID;

  vdat$CreatePdmMgr(mgrID = &pdmID);

  // Init
  VDvlaOE_Construct(&objVLA);
  VDvlaID_Construct(&childVLA);

  // Start over
  vdat$CreateSetMgr(mgrID = &mgrID);
  if (mgrID.objid == NULL_OBJID) goto wrapup;

  // RDB Template Set
  VDatRDBGetSetByType(&mgrID,"AssyTree",&rdbSetID);
  if (rdbSetID.objid == NULL_OBJID) goto wrapup;

  VDatRDBGetNodeByType(&rdbSetID,"PIECE",&stagePieceID);
  VDatRDBGetNodeByType(&rdbSetID,"PL",   &stagePanelID);
  VDatRDBGetNodeByType(&rdbSetID,"PSU",  &stagePsuID);
  VDatRDBGetNodeByType(&rdbSetID,"CPSU", &stageCpsuID);
  VDatRDBGetNodeByType(&rdbSetID,"PAS",  &stagePsaID);
  VDatRDBGetNodeByType(&rdbSetID,"SA",   &stageSaID);
  VDatRDBGetNodeByType(&rdbSetID,"UNIT", &stageUnitID);

  // Make a few sets
  VDatCreateSet(&mgrID,&rdbSetID,"271",&set1ID);
  VDatCreateSet(&mgrID,&rdbSetID,"272",&set2ID);
  VDatCreateSet(&mgrID,&rdbSetID,"273",&set3ID);

  VDatCreateTree(&set1ID,&stageUnitID,"271",&tree1ID);
  VDatCreateTree(&set2ID,&stageUnitID,"272",&tree2ID);
//VDatCreateTree(&set3ID,&stageUnitID,"273",&tree3ID);

  // Grab Plates
  sts = VDahLocObjectsByClass("VSplate",&objVLA);
  if (!(sts & 1)) goto wrapup;
  
  for(i = 0; (i < 30000) && (VDvlaOE_GetAt(&objVLA,&objOE,i)); i++) {

    VDatCreateLeaf(&set1ID,&objOE,&leafID);

    if (flag == 1) {

      // Add to sa
      if ((i % 25) == 0) {
        saNum = (i / 25) + 1;
        sprintf(saName,"%d",saNum);
        VDatCreateNode(&tree1ID,&stageSaID,saName,&saID);
      }

      if ((i % 5) == 0) {
        psuNum = (i / 5) + 1;
        sprintf(psuName,"%d",psuNum);
        VDatCreateNode(&saID,&stagePsuID,psuName,&psuID);
      }

      VDatAddParent(&leafID,&psuID);
    }
  }

  vdat$GetSetMgr(mgrID = &mgrID);
  VDbroPrintObj(&mgrID);

  retFlag = 1;

wrapup:
  VDvlaOE_Delete(&objVLA);
  VDvlaID_Delete(&childVLA);

  return retFlag;
}

end implementation VDatBase;
