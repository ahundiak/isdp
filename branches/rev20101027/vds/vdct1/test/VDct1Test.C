 /* $Id: VDct1Test.C,v 1.1 2001/01/12 15:02:14 art Exp $  */
/***************************************************************************
 * I/VDS
 *
 * File:        vdct1/tree/VDct1Test.I
 *
 * Description: Unit Tree Testing
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDct1Test.C,v $
 *      Revision 1.1  2001/01/12 15:02:14  art
 *      sp merge
 *
 * Revision 1.2  2000/09/14  20:38:50  pinnacle
 * js
 *
 * Revision 1.1  2000/08/15  18:27:10  pinnacle
 * ah
 *
 * Revision 1.1  2000/07/24  21:12:30  pinnacle
 * ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 07/10/00  ah      Creation
 ***************************************************************************/
 
#include "VDct1.h"
#include "VDct1Tree.h"
#include "VDct1Tree2.h"
#include "VDct1Test.h"
#include "VDobj.h"

#include "VDassert.h"

VDASSERT_FFN("vdct1/test/VDct1Test.C");


/* -----------------------------------------------
 * Test the setting of an attribute
 */
IGRstat VDct1TestSetAttr(TVDct1JD *nodeJD,
			 IGRchar  *name,
			 IGRchar  *value)
{
  VDASSERT_FN("VDct1TestFindNode");

  IGRstat retFlag = 0;
  IGRstat sts;
  
  IGRchar valuex[128];
  
  // Arg check
  VDASSERTW(nodeJD && nodeJD->cl);
  
  // Set It
  VDjt1SetAttr(nodeJD,name,value);
  
  // Then check it
  VDjt1GetAttr(nodeJD,name,valuex);
  VDASSERTW(value && !strcmp(value,valuex));
  
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Test the find node stuff
 */
IGRstat VDct1TestGetTreeForSet(TVDct1JD *setJD,
			       TVDct1JD *treeJD)
{
  
  VDASSERT_FN("VDct1TestFindNode");

  IGRstat retFlag = 0;

  // Get it
  _RTCJDB(setJD)->getNodeForSet(setJD,treeJD);
  VDASSERTW(treeJD);
  VDASSERTW(treeJD->id.objid != NULL_OBJID);

  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Test the find node stuff
 */
IGRstat VDct1TestFindNode(TVDct1JD *searchJD, 
			  IGRchar  *nodeType, 
			  IGRchar  *nodeName,
			  TVDct1JD *foundJD)
{
  
  VDASSERT_FN("VDct1TestFindNode");

  IGRstat retFlag = 0;
  IGRstat sts;
  
  // Say Hi
  if (traceFlag) {  
    printf(">>> %s %s\n",ffn(),fn);
  }
  
  // Look up some nodes
  _RTCJDB(searchJD)->
    findNodeByTypeName(searchJD,0,VDCT1_FIND_NODE_OPT_ENTIRE_TREE,
		       nodeType,nodeName,foundJD);
  VDASSERTW(foundJD);
  VDASSERTW(foundJD->id.objid != NULL_OBJID);

  // Done
  retFlag = 1;
  
 wrapup:
  if (traceFlag) {  
    printf("<<< %s %s\n",ffn(),fn);
  }
  return retFlag;
}

/* -----------------------------------------------
 * Test the create node stuff
 */
IGRstat VDct1TestCreateNode(TVDct1JD *parentJD, 
			    IGRchar  *nodeType, 
			    IGRchar  *nodeName, 
			    TVDct1JD *createdJD)
{
  
  VDASSERT_FN("VDct1TestCreateNode");

  IGRstat retFlag = 0;
  IGRstat sts;
  
  // Say Hi
  if (traceFlag) {  
    printf(">>> %s %s\n",ffn(),fn);
  }
  
  // Add some nodes
  _RTCJDB(parentJD)->createNode(parentJD,nodeType,nodeName,createdJD);
  VDASSERTW(createdJD);
  VDASSERTW(createdJD->id.objid != NULL_OBJID);
  

  // Done
  retFlag = 1;
  
 wrapup:
  if (traceFlag) {  
    printf("<<< %s %s\n",ffn(),fn);
  }
  return retFlag;
}

/* -----------------------------------------------
 * Test the set name validator
 * Assume an existing set name is passed
 * 
 * GENERIC
 */
IGRstat VDct1TestIsSetNameValid(IGRchar *setType, 
				IGRchar *setName)
{
  
  VDASSERT_FN("VDct1IsSetNameValid");

  IGRstat retFlag = 0;
  IGRstat sts;
  
  TVDct1JD setJD,setJDx;

  IGRchar results[128];
  IGRchar setNamex[64];
  
  // Say Hi
  traceFlag = 1;
  if (traceFlag) {  
    printf(">>> %s %s %s %s\n",ffn(),fn,setType,setName);
  }
  // Init
  *results = 0;
  
  // Need class pointer (looking at current file only for now)
  setJD.cl = VDct1GetTreeClassForSetType(setType);
  VDASSERTW(setJD.cl);
  setJD.id.objid = NULL_OBJID;
  ex$get_cur_mod(osnum = &setJD.id.osnum);

  // Look for it
  strcpy(setNamex,setName);
  sts = _RTCJDB(&setJD)->isSetNameValid(&setJD,setType,setNamex,results);
  VDASSERTW(!(sts & 1));
  if (*results) printf("Results '%s'\n",results);

  // Change it a bit
  sprintf(setNamex,"%sX",setName);
  sts = _RTCJDB(&setJD)->isSetNameValid(&setJD,setType,setNamex,results);
  VDASSERTW(sts & 1);
  if (*results) printf("Results '%s'\n",results);

  // Through some invalid args at it
  sts = _RTCJDB(&setJD)->isSetNameValid(NULL,setType,setNamex,results);
  VDASSERTW(!(sts & 1));

  sts = _RTCJDB(&setJD)->isSetNameValid(&setJD,setType,setNamex,NULL);
  VDASSERTW(!(sts & 1));

  sts = _RTCJDB(&setJD)->isSetNameValid(&setJD,NULL,setNamex,results);
  VDASSERTW(!(sts & 1));

  sts = _RTCJDB(&setJD)->isSetNameValid(&setJD,setType,NULL,results);
  VDASSERTW(!(sts & 1));

  strcpy(setNamex,setName);
  sts = _RTCJDB(&setJD)->isSetNameValid(&setJD,setNamex,setType,results);
  VDASSERTW(!(sts & 1));

  // Done
  retFlag = 1;
  
wrapup:
  
  if (traceFlag) {  
    printf("<<< %s %s %d \n",ffn(),fn,retFlag);
    fflush(stdout);
  }
  
  return retFlag;
}

/* -----------------------------------------------
 * Test the find set functionality
 *
 * GENERIC
 */
IGRstat VDct1TestFindSet(IGRchar *setType, IGRchar *setName, TVDct1JD *setJDy)
{
  VDASSERT_FN("VDct1TestFindSet");

  IGRstat retFlag = 0;
  TVDct1JD setJD,setJDx;

  IGRint isCase = 0;
  IGRchar buf[40];
  
  // Say Hi
  traceFlag = 1;
  if (traceFlag) {  
    printf(">>> %s %s %s %s\n",ffn(),fn,setType,setName);
  }

  // Arg check
  VDASSERTW(setJDy);
  memset(setJDy,0,sizeof(TVDct1JD));
  setJDy->id.objid = NULL_OBJID;
  
  // Need class pointer
  setJD.cl = VDct1GetTreeClassForSetType(setType);
  VDASSERTW(setJD.cl);
  setJD.id.objid = NULL_OBJID;
  ex$get_cur_mod(osnum = &setJD.id.osnum);

  // Kick off a standard locate
  memset(&setJDx,0,sizeof(TVDct1JD));
  _RTCJDB(&setJD)->findSetByTypeName(&setJD,isCase,
				     VDCT1_FIND_SET_OPT_ALL_FILES,
				     setType,setName,&setJDx);
  VDASSERTW(setJDx.id.objid != NULL_OBJID);
  VDASSERTW(setJDx.cl);
  *setJDy = setJDx;

  // Reset and look only in current file
  memset(&setJDx,0,sizeof(TVDct1JD));
  _RTCJDB(&setJD)->findSetByTypeName(&setJD,isCase,
				     VDCT1_FIND_SET_OPT_CUR_FILE,
				     setType,setName,&setJDx);
  VDASSERTW(setJDx.id.objid != NULL_OBJID);
  VDASSERTW(setJDx.cl);
  *setJDy = setJDx;
  
  // Check case insensitivty
  memset(&setJDx,0,sizeof(TVDct1JD));
  strcpy(buf,setName);
  VDstrlwr(buf);
  _RTCJDB(&setJD)->findSetByTypeName(&setJD,isCase,
				     VDCT1_FIND_SET_OPT_CUR_FILE,
				     setType,buf,&setJDx);
  VDASSERTW(setJDx.id.objid != NULL_OBJID);
  VDASSERTW(setJDx.cl);
  VDASSERTW((setJDx.id.objid == setJDy->id.objid) &&
	    (setJDx.id.osnum == setJDy->id.osnum));

  // Try again with iscase set
  memset(&setJDx,0,sizeof(TVDct1JD));
  strcpy(buf,setName);
  VDstrlwr(buf);
  _RTCJDB(&setJD)->findSetByTypeName(&setJD,1,
				     VDCT1_FIND_SET_OPT_CUR_FILE,
				     setType,buf,&setJDx);
  VDASSERTW(setJDx.id.objid == NULL_OBJID);
  
  // Try unknown set
  memset(&setJDx,0,sizeof(TVDct1JD));
  sprintf(buf,"%sX",setName);
  _RTCJDB(&setJD)->findSetByTypeName(&setJD,isCase,
				     VDCT1_FIND_SET_OPT_CUR_FILE,
				     setType,buf,&setJDx);
  VDASSERTW(setJDx.id.objid == NULL_OBJID);
  memset(&setJDx,0,sizeof(TVDct1JD));
  sprintf(buf,"%sX",setName);
  _RTCJDB(&setJD)->findSetByTypeName(&setJD,isCase,
				     VDCT1_FIND_SET_OPT_ALL_FILES,
				     setType,buf,&setJDx);
  VDASSERTW(setJDx.id.objid == NULL_OBJID);
  
  // Some bad data
  _RTCJDB(&setJD)->findSetByTypeName(NULL,isCase,
				     VDCT1_FIND_SET_OPT_ALL_FILES,
				     setType,setName,&setJDx);
  VDASSERTW(setJDx.id.objid == NULL_OBJID);
  _RTCJDB(&setJD)->findSetByTypeName(&setJD,isCase,
				     -1,
				     setType,setName,&setJDx);
  VDASSERTW(setJDx.id.objid == NULL_OBJID);
  _RTCJDB(&setJD)->findSetByTypeName(&setJD,isCase,
				     VDCT1_FIND_SET_OPT_ALL_FILES,
				     NULL,setName,&setJDx);
  VDASSERTW(setJDx.id.objid == NULL_OBJID);
  _RTCJDB(&setJD)->findSetByTypeName(&setJD,isCase,
				     VDCT1_FIND_SET_OPT_ALL_FILES,
				     setType,NULL,&setJDx);
  VDASSERTW(setJDx.id.objid == NULL_OBJID);
  _RTCJDB(&setJD)->findSetByTypeName(&setJD,isCase,
				     VDCT1_FIND_SET_OPT_ALL_FILES,
				     setName,setType,&setJDx);
  VDASSERTW(setJDx.id.objid == NULL_OBJID);
  _RTCJDB(&setJD)->findSetByTypeName(&setJD,isCase,
				     VDCT1_FIND_SET_OPT_ALL_FILES,
				     setName,setType,NULL);
  setJDx = setJD;
  setJDx.cl = NULL;
  _RTCJDB(&setJD)->findSetByTypeName(&setJDx,isCase,
				     VDCT1_FIND_SET_OPT_ALL_FILES,
				     setType,setName,&setJDx);
  VDASSERTW(setJDx.id.objid == NULL_OBJID);
    
  // Done
  retFlag = 1;
  
wrapup:
  if (traceFlag) {  
    printf("<<< %s %s %d \n",ffn(),fn,retFlag);
  }
  return retFlag;
}

/* -----------------------------------------------
 * Test the Create Set Interface
 *
 * GENERIC
 */
IGRstat VDct1TestCreateSet(IGRchar *setType, IGRchar *setName, TVDct1JD *a_setJD)
{
  VDASSERT_FN("VDct1TestCreateSet");

  IGRstat retFlag = 0;
  TVDct1JD setJD;

  TVDct1JD mgrJD;
  
  // Say Hi
  traceFlag = 1;
  if (traceFlag) {  
    printf(">>> %s %s %s %s\n",ffn(),fn,setType,setName);
  }

  // Start with getting the class
  mgrJD.cl = VDct1GetTreeClassForSetType(setType);
  mgrJD.id.objid = NULL_OBJID;
  VDASSERTW(mgrJD.cl);
  
  // Need a manager
  ex$get_cur_mod(osnum = &mgrJD.id.osnum);
  _RTCJDB(&mgrJD)->getManager(&mgrJD);
  VDASSERTW(mgrJD.id.objid != NULL_OBJID);
  
  // Create it
  _RTCJDB(&mgrJD)->createSet(&mgrJD,setType,NULL,setName,&setJD);
  VDASSERTW(setJD.id.objid != NULL_OBJID);
 
  // Return it
  if (a_setJD) *a_setJD = setJD;
  vdobj$Print(objID = &setJD.id);
  
  // Throw some bad data at it
  _RTCJDB(&mgrJD)->createSet(NULL,setType,NULL,setName,&setJD);
  VDASSERTW(setJD.id.objid == NULL_OBJID);
  _RTCJDB(&mgrJD)->createSet(&mgrJD,NULL,NULL,setName,&setJD);
  VDASSERTW(setJD.id.objid == NULL_OBJID);
  _RTCJDB(&mgrJD)->createSet(&mgrJD,setType,NULL,NULL,&setJD);
  VDASSERTW(setJD.id.objid == NULL_OBJID);
  _RTCJDB(&mgrJD)->createSet(&mgrJD,setType,NULL,setName,NULL);

  // Really need to test the revisioning stuff

  // Done
  retFlag = 1;
  
wrapup:
  if (traceFlag) {  
    printf("<<< %s %s %d \n",ffn(),fn,retFlag);
  }
  return retFlag;
}

/* -----------------------------------------------
 * Checks the manager code
 *
 * GENERIC
 */
IGRstat VDct1TestManager()
{
  VDASSERT_FN("testManager");
  
  IGRstat  retFlag = 0;
  TVDct1JD mgrJD,mgrJDx;

  IGRchar buf[128];
  IGRchar *p;
  
  // Say Hi
  traceFlag = 1;
  if (traceFlag) {  
    printf(">>> %s %s\n",ffn(),fn);
  }
  
  // Start by getting abstract class pointer
  mgrJD.cl = VDct1GetRootTreeClass();
  mgrJD.id.objid = NULL_OBJID;
  ex$get_cur_mod(osnum = &mgrJD.id.osnum);
  VDASSERTW(mgrJD.cl);

  // See if we got one
  _RTCJDB(&mgrJD)->getManager(&mgrJD);
  if (mgrJD.id.objid == NULL_OBJID) {
    
    // Create One (up to the user to ensure test file has no manager   
    _RTCJDB(&mgrJD)->createManager(&mgrJD);
    VDASSERTW(mgrJD.id.objid != NULL_OBJID);
  
  }

  // Get It Again just to be sure
  mgrJDx = mgrJD;
  mgrJDx.id.objid = NULL_OBJID;
  _RTCJDB(&mgrJDx)->getManager(&mgrJDx);
  VDASSERTW(mgrJD.id.objid == mgrJDx.id.objid);
  
  // An attempt to create should fail
  mgrJDx.id.objid = NULL_OBJID;
  _RTCJDB(&mgrJDx)->createManager(&mgrJDx);
  VDASSERTW(mgrJDx.id.objid == NULL_OBJID);

  // test for invalid inputs ???
  _RTCJDB(&mgrJD)->getManager   (NULL);
  _RTCJDB(&mgrJD)->createManager(NULL);

  mgrJDx.cl = NULL;
  _RTCJDB(&mgrJD)->getManager   (&mgrJDx);
  _RTCJDB(&mgrJD)->createManager(&mgrJDx);

  mgrJDx = mgrJD;
  mgrJDx.id.objid = NULL_OBJID;
  mgrJDx.id.osnum = -1;
  _RTCJDB(&mgrJD)->getManager   (&mgrJDx);
  _RTCJDB(&mgrJD)->createManager(&mgrJDx);
  VDASSERTW(mgrJDx.id.objid == NULL_OBJID);
  
  // Done
  retFlag = 1;
  
wrapup:
  if (traceFlag) {  
    printf("<<< %s %s %d \n",ffn(),fn,retFlag);
  }
  
  return retFlag;
}
/* -----------------------------------------------
 * Test Model Model Object
 * This one needs to be adjusted and sent to 
 * a production tree file
 */
#if 0
IGRstat VDct1TestConnectModelObject(TVDct1JD *setJD)
{
  VDASSERT_FN("VDct1ConnectModelObject");

  IGRstat retFlag = 0;
  IGRstat sts;
  
  TVDct1JD treeJD;
  TVDct1JD nodeJD;
  
  TGRobj_env modelOE;
  
  // Say Hi
  traceFlag = 1;
  if (traceFlag) {  
    printf(">>> %s %s\n",ffn(),fn);
  }

  // Get the tree for the set  
  _RTCJDB(setJD)->getNodeForSet(setJD,&treeJD);
  VDASSERTW(treeJD.id.objid != NULL_OBJID);
  
  // Look up some nodes
  _RTCJDB( &treeJD)->
    findNodeByTypeName(&treeJD,0,VDCT1_FIND_NODE_OPT_ENTIRE_TREE,
		       "SHEET","SHT01",&nodeJD);
  VDASSERTW(nodeJD.id.objid != NULL_OBJID);

  // Fake a model object
  modelOE.obj_id.osnum = 2;
  modelOE.obj_id.objid = 1011;
  
  // Connect It
  sts = _RTCJDB(&nodeJD)->connectModelObject(&nodeJD,&modelOE);
  VDASSERTW(sts & 1);
  
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
  
}
#endif




