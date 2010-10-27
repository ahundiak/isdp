/* $Id: VDclai.I,v 1.1.1.1 2001/01/04 21:07:58 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdct/imp/VDclai.I
 *
 * Description: Basic Dynamic Class Object
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDclai.I,v $
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

class implementation VDcla;

#include "VDobj.h"
 
/* --------------------------------------------
 * Standard methods
 */
method vdclaGetType(TVDclaType *type)
{
  if (type == NULL) return 0;
  *type = me->vdclaType;
  return 1;
}
method vdclaSetType(TVDclaType type)
{
  me->vdclaType = type;
  return 1;
}
method vdclaGetFlag(TVDclaFlag *flag)
{
  if (flag == NULL) return 0;
  *flag = me->vdclaFlag;
  return 1;
}
method vdclaSetFlag(TVDclaFlag flag)
{
  me->vdclaFlag = flag;
  return 1;
}

/* -----------------------------------------------
 * Get type and or flag
 */
IGRstat VDclaGetTypeFlag(TGRobj_env *a_objOE, // I - target
                         TGRid      *a_objID, // I - target
                         TVDobjid    a_objid, // I - target
                         TVDosnum    a_osnum, // I - target
                         TVDclaType *a_type,  // O - type
                         TVDclaFlag *a_flag)  // O - flag
{
  IGRstat retFlag = 0;
  IGRstat sts;

  // Init output
  if (a_type) *a_type = VDCLA_TYPE_NONE;
  if (a_flag) *a_flag = VDCLA_FLAG_NONE;
  if ((a_type == NULL) && (a_flag == NULL)) goto wrapup;

  // Get target object
  if (a_objOE) {
    a_objid = a_objOE->obj_id.objid;
    a_osnum = a_objOE->obj_id.osnum;
  }
  if (a_objID) {
    a_objid = a_objID->objid;
    a_osnum = a_objID->osnum;
  }
  if (a_objid == NULL_OBJID) goto wrapup;
  if (a_objid == 0)          goto wrapup;

  // Get type
  if (a_type) {

    sts = om$send(msg = message VDcla.vdclaGetType(a_type),
                  senderid = NULL_OBJID,
                  targetid = a_objid,
                  targetos = a_osnum);

    if (!(sts & 1)) goto wrapup;

  }

  // Get flag
  if (a_flag) {

    sts = om$send(msg = message VDcla.vdclaGetFlag(a_flag),
                  senderid = NULL_OBJID,
                  targetid = a_objid,
                  targetos = a_osnum);

    if (!(sts & 1)) goto wrapup;
  }

  // Done
  retFlag = 1;

wrapup:
  
  return retFlag;
}

/* -----------------------------------------------
 * Set type and or flag
 */
IGRstat VDclaSetTypeFlag(TGRobj_env *a_objOE, // I - target
                         TGRid      *a_objID, // I - target
                         TVDobjid    a_objid, // I - target
                         TVDosnum    a_osnum, // I - target
                         TVDclaType  a_type,  // I - type
                         TVDclaFlag  a_flag)  // I - flag
{
  IGRstat retFlag = 0;
  IGRstat sts;

  // Get target object
  if (a_objOE) {
    a_objid = a_objOE->obj_id.objid;
    a_osnum = a_objOE->obj_id.osnum;
  }
  if (a_objID) {
    a_objid = a_objID->objid;
    a_osnum = a_objID->osnum;
  }
  if (a_objid == NULL_OBJID) goto wrapup;
  if (a_objid == 0)          goto wrapup;

  // Set type
  if (a_type != VDCLA_TYPE_NOTUSING) {

    sts = om$send(msg = message VDcla.vdclaSetType(a_type),
                  senderid = NULL_OBJID,
                  targetid = a_objid,
                  targetos = a_osnum);

    if (!(sts & 1)) goto wrapup;

  }

  // Set Flag
  if (a_flag != VDCLA_FLAG_NOTUSING) {

    sts = om$send(msg = message VDcla.vdclaSetFlag(a_flag),
                  senderid = NULL_OBJID,
                  targetid = a_objid,
                  targetos = a_osnum);

    if (!(sts & 1)) goto wrapup;
  }

  // Done
  retFlag = 1;

wrapup:
  
  return retFlag;
}

static int traceFlag;

extern VDclassid OPP_VDcla_class_id;

/* -------------------------------------------------
 * Do some testing
 */
IGRstat VDclaTest()
{
  IGRstat retFlag = 0;
  IGRstat sts;

  TGRid   objID;

  TVDclaType type;
  TVDclaType flag;

  // Trace
  traceFlag = 1;
  printf(">>> VDclaTest\n");

  // Create one
  ex$get_cur_mod(osnum = &objID.osnum);
  objID.objid = NULL_OBJID;

  // Create object
  sts = om$construct(classname = "VDcla",
                     osnum     =  objID.osnum,
                     p_objid   = &objID.objid);
  if (!(sts & 1)) {
    printf("*** Problem creating VDcla test object\n");
    goto wrapup;
  }
  if (objID.objid == NULL_OBJID) {
    printf("*** Construct had ggod status but objif is NULL\n");
    goto wrapup;
  }
  vdobj$Print(objID = &objID);

  // Set type and flag
  type = 27;
  flag = 49;
  vdcla$Set(objID = &objID, type = type, flag = flag);

  // Check em
  type = 13;
  flag = 13;

  vdcla$Get(objID = &objID, type = &type, flag = &flag);
  if (type != 27) {
    printf("*** Bad type %d %d\n",27,type);
  }
  if (flag != 49) {
    printf("*** Bad flag %d %d\n",49,flag);
  }

  // And delete it
  sts = om$send(msg = message Root.delete(0),
                senderid = NULL_OBJID,
                targetid = objID.objid,
                targetos = objID.osnum);
  if (!(sts & 1)) {
    printf("*** Problem deleting object\n");
    goto wrapup;
  }

  // Done
  retFlag = 1;

wrapup:
  printf("### VDclaTest\n");
  return retFlag;
}

end implementation VDcla;
