/* $Id: VDobj2.c,v 1.1 2001/02/01 21:23:50 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdah/d/VDobj2.c
 *
 * Description: Duumy Routines for service pack loading
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDobj2.c,v $
 *      Revision 1.1  2001/02/01 21:23:50  ahundiak
 *      ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 02/01/01  ah      Creation
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

VDASSERT_FFN("vdah/d/VDobj2.c");

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

#if 0
  // Get the path
  om$send(msg = message GRgraphics.GRgetname(&msg,path),
	  senderid = NULL_OBJID,
	  targetid = theID.objid,
	  targetos = theID.osnum);
  if (*path) {
    retFlag = 1;
    goto wrapup;
  }
  
  // If the above fails, use an untranslate
  di$untranslate(objname = path,
		 objid = theID.objid,
		 osnum = theID.osnum);
#endif
  
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

#if 0  
  // Pull the name
  om$get_classname(osnum = theID.osnum,
		   objid = theID.objid,
		   classname = className);
#endif

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
  
#if 0
  // Get the macro
  macID.objid = NULL_OBJID;
  om$send(msg = message 
	  ACcpx.find_macro(&macID),
	  senderid = NULL_OBJID,
	  targetid = theID.objid,
	  targetos = theID.osnum);
  if (macID.objid == NULL_OBJID) goto wrapup;
    
  // Get the name
  om$send(msg = message 
	  ACcpx_defn.ACgive_name(&macNamex),
	  senderid = NULL_OBJID,
	  targetid = macID.objid,
	  targetos = macID.osnum);
  if (macNamex == NULL) goto wrapup;
    
  strcpy(macName,macNamex);
#endif

  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}
