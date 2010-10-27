/* $Id: VDTagConi.I,v 1.1.1.1 2001/01/04 21:09:25 cvs Exp $  */

/* $Id: VDTagConi.I,v 1.1.1.1 2001/01/04 21:09:25 cvs Exp $ */ 

/***************************************************************************
 * I/VDS
 *
 * File:        vdtag/VDTagConi.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 * $Log: VDTagConi.I,v $
 * Revision 1.1.1.1  2001/01/04 21:09:25  cvs
 * Initial import to CVS
 *
# Revision 1.1  1998/11/05  17:07:34  pinnacle
# tags
#
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 11/01/98  ah      Created
 ***************************************************************************/

class implementation VDTagCon;

#include "VDobj.h"

/* ----------------------------------------------------
 * In case need to modify from isdp, here is a hook
 */
method access(void *p)
{
  return OM_S_SUCCESS;
}

/* ----------------------------------------------------
 * Similiar to debug but format in a more useful
 * fashion for isdp
 */
method dump()
{
  
  printf("Dumping OMTagCon\n");
  printf("OSNAME: %s\n",me->osname);
  printf("Count: %d\n",me->count);
  
  return 1;
}

/* -----------------------------------------------------
 * Since VDTagCon is just a cloned class, don't want to
 * mess around with the system when deleting,
 */
method delete ( int defer )
{
  om$send ( mode = OM_e_wrt_message,
	    msg = message Root.delete(0),
	    targetid = my_id );

   return OM_S_SUCCESS;
}

extern VDclassid OPP_OMTagCon_class_id;

/* -----------------------------------
 * Show the contents of a VDTagCon object
 */
IGRstar VDtagDumpTagCon(TGRid *tagConID)
{
  IGRstat retFlag = 0;
  IGRstat sts;

  VDclassid tagConCLASS;
  TGRid     cpyID;

  // Init
  cpyID.objid = NULL_OBJID;

  // Check object class
  tagConCLASS = 0;
  om$get_classid(
    objid = tagConID->objid,
    osnum = tagConID->osnum,
    p_classid = &tagConCLASS
  );
  if (tagConCLASS != OPP_OMTagCon_class_id) {
    printf("Object is not a VDTagCon\n");
    goto wrapup;
  }
  
  // Make a copy
  cpyID.objid = NULL_OBJID;
  cpyID.osnum = OM_Gw_current_OS;
  sts = om$construct_and_copy ( 
    objid     =  tagConID->objid,
    obj_osnum =  tagConID->osnum,
    osnum     =  cpyID.osnum,
    p_objid   = &cpyID.objid
  );
  if (cpyID.objid == NULL_OBJID) {
    printf("Problem copying object\n");
    goto wrapup;
  }

  // Chenge class to use new methods
  sts = om$change_class(
    objid = cpyID.objid,
    osnum = cpyID.osnum,
    classname = "VDTagCon"
  );
  if (!(sts & 1)) {
    printf("Problem changing class name for\n");
    goto wrapup;
  }
                              
  // Dump it
  sts = om$send(
    msg = message VDTagCon.dump(),
    senderid = NULL_OBJID,
    targetid = cpyID.objid,
    targetos = cpyID.osnum
  );
  if (!(sts & 1)) {
    printf("Problem dumping\n");
    goto wrapup;
  }

  retFlag = 1;

wrapup:

  // Get rid of copy, causes core dump
#if 0
  if (cpyID.objid != NULL_OBJID) {
    om$send(
      msg = message Root.delete(0),
      senderid = NULL_OBJID,
      targetid = cpyID.objid,
      targetos = cpyID.osnum
    );
  }
#endif
  if (!(retFlag & 1)) 
  {
    vdobj$Print(objID = tagConID);
  }
  
  return retFlag;

}

#if 0
method getText(IGRchar *bufPnt; IGRlong bufMax; IGRlong *bufCnt)
{
  IGRlong noteLen;
  IGRlong i;

  // Get buffer length
  if (bufCnt != NULL) *bufCnt = 0;
  noteLen = om$dimension_of(varray = me->notes);

  // If pointer is null then just return length
  if (bufPnt == NULL) {
    if (bufCnt != NULL) *bufCnt = noteLen;
    return 1;
  }

  // Check on valid max buf size
  if (bufMax <= 0) {
    return 0;
  }
  *bufPnt = 0;
  if (bufCnt != NULL) *bufCnt = noteLen;

  // Have two nulls at very end, drop one off
  noteLen--;

  // Make sure have room in buffer for text plus null
  if (noteLen >= bufMax) {
    noteLen = bufMax - 1;
  }

  // Transfer data
  for(i = 0; i < noteLen; i++) {

    if (me->notes[i] != 0) *bufPnt = me->notes[i];
    else                   *bufPnt = '\n';

    bufPnt++;
  }

  // Terminate NULL
  *bufPnt = 0;

  return 1;
}

/* -------------------------------------------
 * Just a dummy for now
 * have it if we need it
 */
method setText(IGRchar *bufPnt; IGRlong bufCnt)
{
  return 1;
}

extern VDclassid OPP_GRnb_class_id;

IGRstat VDnbGetTextFromID  (TGRid   *nbID, IGRint textSize, IGRchar *text);
IGRstat VDnbGetTextFromPath(IGRchar *path, IGRint textSize, IGRchar *text);

IGRstat VDnbGetTextTest()
{
  IGRchar buf[1024];

  VDnbGetTextFromPath(":junk2.m:ref:junk.m:NoteBook:NoteBook",1024,buf);

  printf("BUF\n%s\n",buf);

  return 1;
}

/* -----------------------------------
 * Gets a copy of the text buffer
 * Given a path to the notebook object
 */
IGRstat VDnbGetTextFromPath(IGRchar *path, IGRint textSize, IGRchar *text)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  TGRid   nbID;

  if (text) *text = 0;

  nbID.objid = NULL_OBJID;
  sts = di$translate(	
    objname =  path,
    p_osnum = &nbID.osnum,
    p_objid = &nbID.objid
  );

  if (nbID.objid == NULL_OBJID) {
    // printf("Could not find notebook object for %s\n",path);
    goto wrapup;
  }

  retFlag = VDnbGetTextFromID(&nbID,textSize,text);

wrapup:
  return retFlag;
}

/* -----------------------------------
 * Gets a copy of the text buffer
 * Given an id
 */
IGRstat VDnbGetTextFromID(TGRid *nbID, IGRint textSize, IGRchar *text)
{
  IGRstat retFlag = 0;
  IGRstat sts;

  VDclassid nbCLASS;
  TGRid     nbIDcopy;

  // Init
  nbIDcopy.objid = NULL_OBJID;

  // Empty buffer
  if (text) *text = 0;

  // Check args
  if ((textSize < 1) || (text == NULL)) {
    printf("No text buffer for notebook object\n");
    goto wrapup;
  }

  // Check object class
  nbCLASS = 0;
  om$get_classid(
    objid = nbID->objid,
    osnum = nbID->osnum,
    p_classid = &nbCLASS
  );
  if (nbCLASS != OPP_GRnb_class_id) {
    printf("Object is not a notebook\n");
    VDbroPrintObj(nbID);
    goto wrapup;
  }

  // Make a copy
  nbIDcopy.objid = NULL_OBJID;
  nbIDcopy.osnum = OM_Gw_current_OS;
  sts = om$construct_and_copy ( 
    objid     = nbID->objid,
    obj_osnum = nbID->osnum,
    osnum   =  nbIDcopy.osnum,
    p_objid = &nbIDcopy.objid
  );
  if (nbIDcopy.objid == NULL_OBJID) {
    printf("Problem copying object\n");
    VDbroPrintObj(nbID);
    goto wrapup;
  }

  // Chenge class to use new methods
  sts = om$change_class(
    objid = nbIDcopy.objid,
    osnum = nbIDcopy.osnum,
    classname = "VDnb"
  );
  if (!(sts & 1)) {
    printf("Problem changing class name for\n");
    VDbroPrintObj(nbID);
    goto wrapup;
  }
                              
  // Get the buffer
  sts = om$send(
    msg = message VDnb.getText(text,textSize,NULL),
    senderid = NULL_OBJID,
    targetid = nbIDcopy.objid,
    targetos = nbIDcopy.osnum
  );
  if (!(sts & 1)) {
    printf("Problem getting text for\n");
    VDbroPrintObj(nbID);
    goto wrapup;
  }

  retFlag = 1;

wrapup:

  // Get rid of copy
  if (nbIDcopy.objid != NULL_OBJID) {
    om$send(
      msg = message Root.delete(0),
      senderid = NULL_OBJID,
      targetid = nbIDcopy.objid,
      targetos = nbIDcopy.osnum
    );
  }

  return retFlag;

}
#endif

end implementation VDTagCon;

