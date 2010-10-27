/* $Id: VDahChn.I,v 1.3 2001/01/11 16:34:30 art Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdah/VDahChn.I
 *
 * Description: channel toolkit
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDahChn.I,v $
 *      Revision 1.3  2001/01/11 16:34:30  art
 *      sp merge
 *
 *      Revision 1.1  2001/01/11 16:20:58  art
 *      s merge
 *
 *      Revision 1.1.1.1  2001/01/04 21:07:40  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.4  1998/04/02  21:19:44  pinnacle
# ah
#
# Revision 1.3  1998/03/15  15:03:58  pinnacle
# Macro Interface
#
# Revision 1.2  1997/12/02  20:19:48  pinnacle
# AssyTree
#
# Revision 1.1  1997/11/25  01:16:10  pinnacle
# AssyTree
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 11/25/97  ah      Creation
 * 03/25/98  ah      Macro interface
 * 03/31/98  ah      Moved macros to VDchn.I
 ***************************************************************************/

class implementation Root;

// #include "VDmaster.h"
#include "VDtypedef.h"
#include "VDvla.h"

#ifndef   v_misc_include
#include "v_miscmacros.h" /* Gets VDmem.h as well */
#endif

#include "VDah.h"

/* -------------------------------------------
 * Get Object at Index
 */
IGRstat VDahGetChnCount(
  TGRid   *chnID,
  IGRchar *chnName,
  IGRuint *chnCount
)
{
  IGRstat retFlag = 0;
  IGRstat sts;

  OM_S_CHANSELECT chnSelect;

  // Arg Check
  *chnCount = 0;
  if ((chnID == NULL) || (chnID->objid == NULL_OBJID)) goto wrapup;

  /* Make a channel selector */
  sts = om$make_chanselect(
    channame     =  chnName, 
    p_chanselect = &chnSelect
  );
  if (!(sts & 1)) {
    printf("Problem making channel selector %s\n",chnName);
    goto wrapup;
  }
  
  sts = om$get_channel_count ( 
    osnum        =  chnID->osnum,
    objid        =  chnID->objid,
    p_chanselect = &chnSelect,
    count        =  chnCount
  );
  if (!(sts & 1)) {
    printf("Problem getting channel count %s\n",chnName);
    goto wrapup;
  }

  retFlag = 1;

wrapup:
  return retFlag;
}

/* -------------------------------------------
 * Get Object at Index
 * Only works on ordered channels
 * notification is not ordered
 *
 * Returns 1 Got Object
 *         2 No object at index
 *         0 Error
 */
IGRstat VDahGetChnObject(
  TGRid   *objID,
  IGRchar *chnName,
  IGRuint  chnObjIndex,
  TGRid   *chnObjID
)
{
  IGRstat retFlag = 0;
  IGRstat sts;

  OM_S_CHANSELECT chnSelect;

  // Arg Check
  chnObjID->objid = NULL_OBJID;
  if ((objID == NULL) || (objID->objid == NULL_OBJID)) goto wrapup;

  /* Make a channel selector */
  sts = om$make_chanselect(
    channame     =  chnName, 
    p_chanselect = &chnSelect
  );
  if (!(sts & 1)) {
    printf("Problem making channel selector %s\n",chnName);
    goto wrapup;
  }

  /* Grab the objects */
  sts = om$get_objid_at_index ( 
    osnum         = objID->osnum,
    objid         = objID->objid,
    p_chanselect  = &chnSelect,
    index         =  chnObjIndex,
    objidaddr     = &chnObjID->objid,
    osnumaddr     = &chnObjID->osnum);

  if (!(sts & 1)) {
    // retFlag = 2;
    goto wrapup;
  }

  retFlag = 1;

wrapup:

  return retFlag;
}

#define VDAH_CHN_LINK_MAX 1024

/* -------------------------------------------
 * Get All Objects on Channel
 * chnIdMax is the number of ids allocated
 * chnIdCnt is the number actually found
 *
 * 0 If error
 * 1 If all  returned
 * 3 If some returned
 *
 * This function is good for when you have a known
 * number of objects attached, no allocing occurs
 */
IGRstat VDahGetChnObjects(
  TGRid         *objID,
  IGRchar       *chnName,
  IGRint         chnIdMax,
  TGRid         *chnIds,
  IGRint        *chnIdCnt
)
{
  IGRstat retFlag = 0;
  IGRstat sts;

  OM_S_CHANSELECT chnSelect;
  IGRuint         chnCnt;

  OM_S_OBJECT_LINKAGE   chnLinkStack[VDAH_CHN_LINK_MAX];
  OM_S_OBJECT_LINKAGE  *chnLinks = NULL;
  IGRuint               chnLinkCnt;
  IGRuint               chnLinkSize;
  IGRuint               i;

  // Arg Check
  *chnIdCnt = 0;
  if ((objID == NULL) || (objID->objid == NULL_OBJID)) goto wrapup;

  /* Make a channel selector */
  sts = om$make_chanselect(
    channame     =  chnName, 
    p_chanselect = &chnSelect
  );
  if (!(sts & 1)) {
    printf("Problem making channel selelector %s\n",chnName);
    goto wrapup;
  }

  // How many we got
  chnCnt = 0;
  sts = om$get_channel_count ( 
    osnum        =  objID->osnum,
    objid        =  objID->objid,
    p_chanselect = &chnSelect,
    count        = &chnCnt
  );
  if (!(sts & 1)) goto wrapup;

  // Nothing if channel is empty
  if (chnCnt == 0) {
    retFlag = 1;
    goto wrapup;
  }

  // Adjust link list
  if (chnCnt <= VDAH_CHN_LINK_MAX) {
    chnLinks    = chnLinkStack;
    chnLinkSize = sizeof(chnLinkStack);
  }
  else {
    chnLinks = (OM_S_OBJECT_LINKAGE*)_CALLOC(chnCnt,OM_S_OBJECT_LINKAGE);
    if (chnLinks == NULL) {
      printf("Could not allocate memory for channel objects\n");
      goto wrapup;
    }
    chnLinkSize = chnCnt * sizeof(OM_S_OBJECT_LINKAGE);
  }
  chnLinkCnt = 0;

  /* Grab the objects */
  sts  = om$get_channel_objects(
    osnum = objID->osnum,
    objid = objID->objid,
    p_chanselect = &chnSelect,
    list  =  chnLinks,
    size  =  chnLinkSize,
    count = &chnLinkCnt
  );
  if (!(sts & 1)) {
    printf("Problem getting channel objects\n");
    goto wrapup;
  }

  // Check size limit
  if (chnLinkCnt > chnIdMax) {
    chnLinkCnt = chnIdMax;
    retFlag = 3;
  }
  else {
    retFlag = 1;
  }
  *chnIdCnt = chnLinkCnt;
  
  /* Xfer Over */
  for(i = 0; i < chnLinkCnt; i++) {
    chnIds[i].osnum = chnLinks[i].osnum;
    chnIds[i].objid = chnLinks[i].S_objid;
  }

wrapup:
  if (chnLinks != chnLinkStack) _FREE(chnLinks);

  return retFlag;
}

/* ----------------------------------------------------
 * Start with room allocated but expand
 * if necessary, leave chnIds untouched if error occurs
 *
 * This is good when a large number of objects could be on a channel
 * Usually, no allocating occurs but when needed, array size grows
 * 
 * The user will have to detect and free allocated space
 */
IGRstat VDahGetChnObjects1(
  TGRid         *objID,
  IGRchar       *chnName,
  IGRint         chnIdMax,
  TGRid        **chnIds,
  IGRint        *chnIdCnt
)
{
  IGRstat retFlag = 0;
  IGRstat sts;

  struct {
    IGRuint cnt;
    TGRid  *list,*alloc;
  } chn;


  // Arg Check
  if ((objID == NULL) || (objID->objid == NULL_OBJID)) goto wrapup;

  // Clear everything
  memset(&chn,0,sizeof(chn));

  // Get the count
  sts = VDahGetChnCount(objID,chnName,&chn.cnt);
  if (!(sts & 1)) goto wrapup;

  // Ignore empty channels
  if (chn.cnt == 0) {
    retFlag = 1;
    goto wrapup;
  }

  // See if need to allocate
  if ((*chnIds == NULL) || (chn.cnt > chnIdMax)) {

    chn.alloc = (TGRid*)_CALLOC(chn.cnt,TGRid);

    if (chn.alloc == NULL) {
      printf("Could not allocate memory for channel objects\n");
      goto wrapup;
    }
    chn.list = chn.alloc;
  }
  else {
    chn.list = *chnIds;
  }

  sts = VDahGetChnObjects(objID,chnName,chn.cnt,chn.list,chnIdCnt);
  if (!(sts & 1)) {
    _FREE(chn.alloc);
    goto wrapup;
  }
  *chnIds = chn.list;
  retFlag = 1;

wrapup:
  return retFlag;
}

/* -------------------------------------------
 * Get All Objects on Channel
 * Store in VLA
 *
 * 0 If error
 * 1 Ok
 *
 */
IGRstat VDahGetChnObjs(
  TGRid     *objID,
  IGRchar   *chnName,
  TVDvlaID  *chnVLA
)
{
  IGRstat retFlag = 0;
  IGRstat sts;

  OM_S_CHANSELECT chnSelect;
  IGRuint         chnCnt;
  TGRid           chnID;

  OM_S_OBJECT_LINKAGE   chnLinkStack[VDAH_CHN_LINK_MAX];
  OM_S_OBJECT_LINKAGE  *chnLinks = NULL;
  IGRuint               chnLinkCnt;
  IGRuint               chnLinkSize;
  IGRuint               i;


  // Arg Check
  if ((objID == NULL) || (objID->objid == NULL_OBJID)) goto wrapup;

  /* Make a channel selector */
  sts = om$make_chanselect(
    channame     =  chnName, 
    p_chanselect = &chnSelect
  );
  if (!(sts & 1)) {
    printf("Problem making channel selelector %s\n",chnName);
    goto wrapup;
  }

  // How many we got
  chnCnt = 0;
  sts = om$get_channel_count ( 
    osnum        =  objID->osnum,
    objid        =  objID->objid,
    p_chanselect = &chnSelect,
    count        = &chnCnt
  );
  if (!(sts & 1)) {
    printf("Problem getting channel count\n");
    goto wrapup;
  }

  // Nothing if channel is empty
  if (chnCnt == 0) {
    retFlag = 1;
    goto wrapup;
  }

  // Adjust link list
  if (chnCnt <= VDAH_CHN_LINK_MAX) {
    chnLinks    = chnLinkStack;
    chnLinkSize = sizeof(chnLinkStack);
  }
  else {
    chnLinks = (OM_S_OBJECT_LINKAGE*)_CALLOC(chnCnt,OM_S_OBJECT_LINKAGE);
    if (chnLinks == NULL) {
      printf("Could not allocate memory for channel objects\n");
      goto wrapup;
    }
    chnLinkSize = chnCnt * sizeof(OM_S_OBJECT_LINKAGE);
  }
  chnLinkCnt = 0;

  /* Grab the objects */
  sts  = om$get_channel_objects(
    osnum = objID->osnum,
    objid = objID->objid,
    p_chanselect = &chnSelect,
    list  =  chnLinks,
    size  =  chnLinkSize,
    count = &chnLinkCnt
  );
  if (!(sts & 1)) {
    printf("Problem getting channel objects\n");
    goto wrapup;
  }
  
  /* Xfer Over */
  for(i = 0; i  < chnLinkCnt; i++) {
    chnID.osnum = chnLinks[i].osnum;
    chnID.objid = chnLinks[i].S_objid;
    VDvlaID_Append(chnVLA,&chnID);
  }

  retFlag = 1;

wrapup:
  if (chnLinks != chnLinkStack) _FREE(chnLinks);

  return retFlag;
}

end implementation Root;
