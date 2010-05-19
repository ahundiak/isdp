/* $Id: VDobj2.c,v 1.11 2002/06/10 13:17:15 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdah/VDobj.c
 *
 * Description: Object Routines
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDobj2.c,v $
 *      Revision 1.11  2002/06/10 13:17:15  ahundiak
 *      ah
 *
 *      Revision 1.10  2001/07/23 15:59:54  ahundiak
 *      ah
 *
 *      Revision 1.9  2001/06/14 18:46:51  ahundiak
 *      ah
 *
 *      Revision 1.8  2001/06/07 20:13:10  ahundiak
 *      ah
 *
 *      Revision 1.7  2001/05/17 14:29:11  ahundiak
 *      ah
 *
 *      Revision 1.6  2001/05/02 15:13:20  ahundiak
 *      ah
 *
 *      Revision 1.5  2001/02/01 21:22:52  ahundiak
 *      ah
 *
 *      Revision 1.4  2001/01/14 16:33:27  art
 *      sp merge
 *
 *      Revision 1.3  2001/01/11 16:34:32  art
 *      sp merge
 *
 *      Revision 1.1  2001/01/11 16:20:59  art
 *      s merge
 *
 * Revision 1.1  2000/12/07  17:36:44  pinnacle
 * ah
 *
 * Revision 1.1  2000/12/06  14:51:48  pinnacle
 * ah
 *
 * Revision 1.1  2000/12/01  14:03:18  pinnacle
 * ah
 *
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 11/30/00  ah      Creation
 * 01/12/01  ah      sp17 merge, VD_bulkDisplayByGRobj_envs
 ***************************************************************************/

/* -----------------------------------------------
 * These are stub routines needed by standalone programs
 * which use VDlog functions
 *
 * The real om implementations are in vdahom directory
 * Those functions will override these
 */

#include "VDtypedefc.h"
#include "VDobj2.h"
#include "VDassert.h"

VDASSERT_FFN("vdah/s/VDobj.c");

/* -----------------------------------------------
 * Simple interface for path
 */
IGRstat VDobjGetPath(TGRobj_env *objOE, TGRid *objID, IGRchar *path)
{
  IGRstat retFlag = 0;
  IGRstat msg;
  
  TGRid theID;
  
  // Arg check
  if (path == NULL) goto wrapup;
  *path = 0;
  
  // Get the object
  theID.objid = NULL_OBJID;
  if (objOE) theID =  objOE->obj_id;
  if (objID) theID = *objID;
  if (theID.objid == NULL_OBJID) goto wrapup;
  
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Simple interface for class name
 */
IGRstat VDobjGetClassName(TGRobj_env *objOE, TGRid *objID, IGRchar *className)
{
  IGRstat retFlag = 0;
  
  TGRid theID;
  
  // Arg check
  if (className == NULL) goto wrapup;
  *className = 0;
  
  // Get the object
  theID.objid = NULL_OBJID;
  if (objOE) theID =  objOE->obj_id;
  if (objID) theID = *objID;
  if (theID.objid == NULL_OBJID) goto wrapup;

  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Simple interface for macro name
 */
IGRstat VDobjGetMacroName(TGRobj_env *objOE, TGRid *objID, IGRchar *macName)
{
  IGRstat retFlag = 0;
  
  TGRid    theID;
  TGRid    macID;
  IGRchar *macNamex = NULL;
  
  // Arg check
  if (macName == NULL) goto wrapup;
  *macName = 0;
  
  // Get the object
  theID.objid = NULL_OBJID;
  if (objOE) theID =  objOE->obj_id;
  if (objID) theID = *objID;
  if (theID.objid == NULL_OBJID) goto wrapup;
  
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* ---------------------------------------------
 * Need an easy way to get a sinle attribute from an object
 * Map toVDsa using tyt argument???
 */
IGRstat VDobjGetTxtAtr(TGRobj_env *objOE, TGRid *objID, IGRchar *name, IGRchar *value)
{
  if (value == NULL) return 0;
  *value = 0;
  return 1;
}
IGRstat VDobjGetDblAtr(TGRobj_env *objOE, TGRid *objID, IGRchar *name, IGRdouble *value)
{
  if (value == NULL) return 0;
  *value = 0.0;
  return 1;
}
/* ----------------------------------------------------
 * Validate ancestor with either class id or class name
 */
IGRstat VDobjIsAncestryValid(TGRobj_env *a_objOE, 
			     TGRid      *a_objID,
			     VDclassid   a_classID,
			     IGRchar    *a_className)
{
  return 0;
}

/* ----------------------------------------------------
 * Display an object
 */
IGRstat VD_bulkDisplayByGRobj_envs(enum GRdpmode mode, IGRint cnt, TGRobj_env *objOEs)
{
  VDASSERT_FN("VD_bulkDisplayByGRobj_envs");

 wrapup:
  return 1;
}

/* ----------------------------------------------------
 * Find the actual object from is component path
 */
IGRstat VDobjGetObjFromPath(IGRchar *path, TGRobj_env *modelOE)
{
  return 0;
}

IGRstat VDdrawCurve(void *crv, void *env, TGRid *crvID)
{
  if (crvID) crvID->objid = NULL_OBJID;
  return 0;
}
IGRstat VDdrawLinear(IGRint num, void *pts, void *env, TGRid *ptID)
{
  if (ptID) ptID->objid = NULL_OBJID;
  return 0;
}

IGRstat VDahSetActiveSymbology(TGRsymbology *symb)
{
  return 1;
}
IGRstat VDahGetActiveSymbology(TGRsymbology *symb)
{
  return 1;
}
IGRstat VDefpPlaceMacro(IGRchar    *libName,
			IGRchar    *macName,
			IGRint      flag,
			IGRint      tplCnt,
			TGRobj_env *tplOEs,
			TGRobj_env *macOE)
{
  if (macOE) macOE->obj_id.objid = NULL_OBJID;
  return 0;
}

void VDobjResetOE(TGRobj_env *objOE)
{
  return;
}

