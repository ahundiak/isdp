/* $Id: VDlnki.I,v 1.1.1.1 2001/01/04 21:07:58 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdct/imp/VDlnki.I
 *
 * Description: Basic Linking Object
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDlnki.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:58  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1999/05/28  13:59:18  pinnacle
# ct
#
 * Revision 1.1  1999/05/28  12:43:54  pinnacle
 * ct
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 05/28/99  ah      Creation
 ***************************************************************************/

class implementation VDlnk;

#include "VDtypedef.h"
#include "VDobj.h"
#include "VDlnk.h"

// Static list of channel selectors
static struct {
  IGRint          init;
  OM_S_CHANSELECT select;
} chnSelects[16];

static int traceFlag;

/* -------------------------------------------------
 * Channel select sub system
 * Only need to make a select one time
 * Returns pointer directly to internal static data
 * so be careful
 */
IGRstat VDlnkGetChnSelect(IGRint nth, OM_S_CHANSELECT **chnSelectp)
{
  IGRstat retFlag = 0;
  IGRstat sts;

  IGRchar chnName[32];

  // Arg check
  if (chnSelectp == NULL) goto wrapup;
  *chnSelectp = NULL;
  if ((nth < 0) || (nth > 15)) goto wrapup;

  // Return pointer if inited
  *chnSelectp = &chnSelects[nth].select;
  if (chnSelects[nth].init != 0) {
    retFlag = 1;
    goto wrapup;
  }

  // Get channel name
  *chnName = 0;
  switch(nth) {

  case VDLNK_NTH_TO_RIGHT0: strcpy(chnName,VDLNK_NAME_TO_RIGHT0); break;
  case VDLNK_NTH_TO_LEFT0:  strcpy(chnName,VDLNK_NAME_TO_LEFT0);  break;
  case VDLNK_NTH_TO_RIGHT1: strcpy(chnName,VDLNK_NAME_TO_RIGHT1); break;
  case VDLNK_NTH_TO_LEFT1:  strcpy(chnName,VDLNK_NAME_TO_LEFT1);  break;
  case VDLNK_NTH_TO_RIGHT2: strcpy(chnName,VDLNK_NAME_TO_RIGHT2); break;
  case VDLNK_NTH_TO_LEFT2:  strcpy(chnName,VDLNK_NAME_TO_LEFT2);  break;
  case VDLNK_NTH_TO_RIGHT3: strcpy(chnName,VDLNK_NAME_TO_RIGHT3); break;
  case VDLNK_NTH_TO_LEFT3:  strcpy(chnName,VDLNK_NAME_TO_LEFT3);  break;
  case VDLNK_NTH_TO_RIGHT4: strcpy(chnName,VDLNK_NAME_TO_RIGHT4); break;
  case VDLNK_NTH_TO_LEFT4:  strcpy(chnName,VDLNK_NAME_TO_LEFT4);  break;
  case VDLNK_NTH_TO_RIGHT5: strcpy(chnName,VDLNK_NAME_TO_RIGHT5); break;
  case VDLNK_NTH_TO_LEFT5:  strcpy(chnName,VDLNK_NAME_TO_LEFT5);  break;
  case VDLNK_NTH_TO_RIGHT6: strcpy(chnName,VDLNK_NAME_TO_RIGHT6); break;
  case VDLNK_NTH_TO_LEFT6:  strcpy(chnName,VDLNK_NAME_TO_LEFT6);  break;
  case VDLNK_NTH_TO_RIGHT7: strcpy(chnName,VDLNK_NAME_TO_RIGHT7); break;
  case VDLNK_NTH_TO_LEFT7:  strcpy(chnName,VDLNK_NAME_TO_LEFT7);  break;

  }

  // Make selection
  sts = om$make_chanselect(
    channame     =  chnName, 
    p_chanselect = *chnSelectp
  );

  if (!(sts & 1)) {
    printf("Problem making channel selector %s\n",chnName);
    *chnSelectp = NULL;
    goto wrapup;
  }

  chnSelects[nth].init = 1;
  retFlag = 1;

wrapup:
  return retFlag;
}

/* -----------------------------------------------------
 * Establish connection between two objects
 * leftID->to_right => rightID
 * rightID->to_left => leftID
 *
 * pair is 0 - 7
 */
IGRstat VDlnkConnect(IGRint pair, TGRid *leftID, TGRid *rightID)
{
  IGRstat retFlag = 0;
  IGRstat sts;

  OM_S_CHANSELECT *to_left  = NULL;
  OM_S_CHANSELECT *to_right = NULL;

  // Arg check
  if ((leftID == NULL) || (rightID == NULL)) goto wrapup;
  if ((leftID->objid  == NULL_OBJID) || 
      (rightID->objid == NULL_OBJID)) goto wrapup;
  if ((leftID->objid  == 0) || 
      (rightID->objid == 0)) goto wrapup;

  // Get the channels
  pair *= 2;
  VDlnkGetChnSelect(pair+0,&to_right);
  VDlnkGetChnSelect(pair+1,&to_left);
  if ((to_left == NULL) || (to_right == NULL)) goto wrapup;

  // Connect up
  sts = om$send(msg = message 
		Root.connect(*to_left, OM_K_MAXINT,
			      leftID->objid, 
			      leftID->osnum,
			     *to_right,OM_K_MAXINT),
		senderid = NULL_OBJID,
		targetid = rightID->objid,
		targetos = rightID->osnum
  );
  if (!(sts & 1)) {
    goto wrapup;
  }
  if (traceFlag) {
    printf("Connected %d %d %d\n",pair/2,leftID->objid,rightID->objid);
  }
  retFlag = 1;

wrapup:
  return retFlag;
}

/* -----------------------------------------------------
 * Drop connection between two objects
 * leftID->to_right => rightID
 * rightID->to_left => leftID
 *
 * pair is 0 - 7
 */
IGRstat VDlnkDisconnect(IGRint pair, TGRid *leftID, TGRid *rightID)
{
  IGRstat retFlag = 0;
  IGRstat sts;

  OM_S_CHANSELECT *to_left  = NULL;
  OM_S_CHANSELECT *to_right = NULL;

  // Arg check
  if ((leftID == NULL) || (rightID == NULL)) goto wrapup;
  if ((leftID->objid  == NULL_OBJID) || 
      (rightID->objid == NULL_OBJID)) goto wrapup;
  if ((leftID->objid  == 0) || 
      (rightID->objid == 0)) goto wrapup;

  // Get the channels
  pair *= 2;
  VDlnkGetChnSelect(pair+0,&to_right);
  VDlnkGetChnSelect(pair+1,&to_left);
  if ((to_left == NULL) || (to_right == NULL)) goto wrapup;

  // Disconnect
  sts = om$send(msg = message 
		Root.disconnect(
			        *to_left,
			         leftID->objid, 
			         leftID->osnum,
			        *to_right),
		senderid = NULL_OBJID,
		targetid = rightID->objid,
		targetos = rightID->osnum);

  if (!(sts & 1)) {
    printf("Problem disconnecting VDlnk objects\n");
    goto wrapup;
  }
  if (traceFlag) {
    printf("Disonnected %d %d %d\n",pair/2,leftID->objid,rightID->objid);
  }

  retFlag = 1;

wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Get either object or count on specified chanel
 * later might want to add getting list
 */
IGRstat VDlnkGet(TGRid  *objID, // I - Target
                 IGRint  chn,   // I - Channel number
                 IGRint  nth,   // I - Which object on channel
                 IGRint *cnt,   // O - Number of objects on channel
                 TGRid  *outID) // O - Requested object
{
  IGRstat retFlag = 0;
  IGRstat sts;

  OM_S_CHANSELECT *chnSelect = NULL;

  // Arg check
  if (cnt) *cnt = 0;
  if (outID) outID->objid = NULL_OBJID;
  if (objID == NULL)              goto wrapup;
  if (objID->objid == NULL_OBJID) goto wrapup;
  if (objID->objid == 0)          goto wrapup;

  // Get the channel select
  VDlnkGetChnSelect(chn,&chnSelect);
  if (chnSelect == NULL) goto wrapup;

  // Want count?
  if (cnt) {

    sts = om$get_channel_count( 
      osnum        = objID->osnum,
      objid        = objID->objid,
      p_chanselect = chnSelect,
      count        = (IGRuint*)cnt);
    if (!(sts & 1)) goto wrapup;
  }

  // Want object
  if (outID) {

    sts = om$get_objid_at_index ( 
      osnum         =  objID->osnum,
      objid         =  objID->objid,
      p_chanselect  =  chnSelect,
      index         =  nth,
      objidaddr     = &outID->objid,
      osnumaddr     = &outID->osnum);

    if (!(sts & 1)) {
      outID->objid = NULL_OBJID;
      goto wrapup;
    }
    if (outID->objid == NULL_OBJID) goto wrapup;
  }

  retFlag = 1;

wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Create a link object (usually for testing)
 */
IGRstat VDlnkConstructObject(TGRid *objID)
{
  IGRstat retFlag = 0;
  IGRstat sts;

  // Arg check
  if (objID == NULL) goto wrapup;
  
  // Create one
  ex$get_cur_mod(osnum = &objID->osnum);
  objID->objid = NULL_OBJID;

  // Create object
  sts = om$construct(classname = "VDlnk",
                     osnum     =  objID->osnum,
                     p_objid   = &objID->objid);
  if (!(sts & 1)) {
    printf("*** Problem creating VDlnk object\n");
    goto wrapup;
  }
  if (traceFlag) {
    printf("Constructed ");
    vdobj$Print(objID = objID);
  }
  retFlag = 1;

wrapup:
  return retFlag;
}

/* ----------------------------------------------
 * Delete one, eventually want to empty all the
 * channels before actually deleting
 * Maybe we should override Root.delete?
 */
IGRstat VDlnkDeleteObject(TGRid *objID)
{
  IGRstat retFlag = 0;
  IGRstat sts;

  // Arg check
  if (objID == NULL) goto wrapup;

  if (traceFlag) {
    printf("Deleting ");
    vdobj$Print(objID = objID);
  }

  // Do it
  sts = om$send(msg = message Root.delete(0),
                senderid = NULL_OBJID,
                targetid = objID->objid,
                targetos = objID->osnum);

  if (!(sts & 1)) {
    printf("*** Problem deleting VDlnk object\n");
    goto wrapup;
  }
  if (traceFlag) printf("Object deleted\n");
  retFlag = 1;

wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Test Routine
 */
IGRstat VDlnkTest()
{
  IGRstat retFlag = 0;

  TGRid rightID1,rightID2;
  TGRid leftID;

  // Say hi
  printf(">>> VDlnkTest\n");
  traceFlag = 1;

  // Make some
  VDlnkConstructObject(&rightID1);
  VDlnkConstructObject(&rightID2);
  VDlnkConstructObject(&leftID);

  // Link em
  VDlnkConnect(VDLNK_NTH_PAIR0,&leftID,&rightID1);
  VDlnkConnect(VDLNK_NTH_PAIR0,&leftID,&rightID2);

  VDlnkDisconnect(VDLNK_NTH_PAIR0,&leftID,&rightID1);

  // Delete em
#if 0
  VDlnkDeleteObject(&rightID1);
  VDlnkDeleteObject(&rightID2);
  VDlnkDeleteObject(&leftID);
#endif

  // Done
  retFlag = 1;

//wrapup:
  printf("<<< VDlnkTest\n");
  return retFlag;
}

end implementation VDlnk;


