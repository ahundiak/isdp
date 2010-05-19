/* $Id: VDobj2.I,v 1.12 2002/04/18 16:32:09 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdah/VDobj2.I
 *
 * Description:	Simple Object Processing
 *
 * Dependencies:
 *
 * Revision History:
 * $Log: VDobj2.I,v $
 * Revision 1.12  2002/04/18 16:32:09  ahundiak
 * ah
 *
 * Revision 1.11  2002/01/03 14:44:41  ahundiak
 * ah
 *
 * Revision 1.10  2001/11/09 14:24:12  ahundiak
 * ah
 *
 * Revision 1.9  2001/10/19 18:30:21  ahundiak
 * ah
 *
 * Revision 1.8  2001/06/03 14:41:33  ahundiak
 * ah
 *
 * Revision 1.7  2001/05/02 15:14:06  ahundiak
 * ah
 *
 * Revision 1.6  2001/02/26 15:50:22  ahundiak
 * ah
 *
 * Revision 1.5  2001/02/17 14:01:12  ahundiak
 * *** empty log message ***
 *
 * Revision 1.4  2001/01/14 16:33:27  art
 * sp merge
 *
 * Revision 1.3  2001/01/11 16:34:31  art
 * sp merge
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 11/28/00  ah      Creation
 * 01/12/01  ah      sp17 merge, added additional routines
 * 04/25/01  ah      Added some new functions
 * 05/31/01  ah      Added VDobjGetRep
 * 10/18/01  ah      Remove VDdoM support
 * 11/08/01  ah      Made VOobjGetDblAtr consistent with VDctx routines
 ***************************************************************************/
class implementation Root;

#include "VDtypedef.h"
#include "VDobj.h"
#include "VDdir.h"
#include "VDctx.h"
#include "VDsa.h"

#include "VDobj2.h"
#include "VDos.h"

#include "VDassert.h"
#include "coparamac.h"

from ACcpx_defn import ACgive_name;
from ACcpx      import find_macro;
from GRgraphics import GRgetname;
from GRvg       import GRgetsymb;

VDASSERT_FFN("VDobj2.I");

/* ---------------------------------------------
 * Given a choice between an oe or id, return the id
 */
IGRstat VDobjGetID(TGRobj_env *objOE, TGRid *objID, TGRid *theID)
{
  IGRstat retFlag = 0;

  // Arg check
  if (theID == NULL) goto wrapup;
  theID->objid = NULL_OBJID;

  // One or the other
  if (objOE) *theID = objOE->obj_id;
  if (objID) *theID = *objID;

  // Done
  if (theID->objid == NULL_OBJID) goto wrapup;  
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* ---------------------------------------------
 * Need an easy way to get a sigle attribute from an object
 * Should probably replace with VDctxGetTxtAtr
 */
IGRstat VDobjGetTxtAtr(TGRobj_env *objOE, TGRid *objID, IGRchar *name, IGRchar *value)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  
  // Arg check
  if (value == NULL) goto wrapup;
  *value = 0;
  
  // Two choices
  if (objOE) retFlag = vdsa$GetStruct(objOE = objOE, name = name, tyt = value);
  if (objID) retFlag = vdsa$GetStruct(objID = objID, name = name, tyt = value);
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Run this through the text attribute call just to
 * pretend that the double was actually stored as a string
 * This will reduce suprises when converting to xml
 * I think
 */
IGRstat VDobjGetDblAtr(TGRobj_env *objOE, TGRid *objID, IGRchar *name, IGRdouble *value)
{
  IGRstat retFlag = 0;
  IGRchar buf[128];
  
  // Arg check
  if (value == NULL) goto wrapup;
  *value = 0.0;

  retFlag = VDobjGetTxtAtr(objOE,objID,name,buf);
  *value = atof(buf);
    
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Simple interface for fence
 */
IGRint VDstart_var_fence(TGRobj_env  *setOE, 
			 IGRint      *locNum, 
			 TGRobj_env **locOEs)
{
  IGRint sts;
  
  sts = as$start_fence(set       = &setOE->obj_id,
		       set_env   = &setOE->mod_env,
		       nb_obj    = locNum,
		       p_obj_env = locOEs);

  return sts;
}

/* -----------------------------------------------
 * Simple interface for que
 */
extern IGRint VDputResponse(IGRint response)
{
  IGRstat msg;
  
  return ex$putque(msg = &msg, response = &response);
}

/* -----------------------------------------------
 * Simple interface for path
 */
IGRstat VDobjGetPath(TGRobj_env *objOE, TGRid *objID, IGRchar *path)
{
  IGRstat retFlag = 0;
  IGRstat msg;
  IGRstat sts;
  
  TGRid theID;
  
  // Arg check
  if (path == NULL) goto wrapup;
  *path = 0;
  
  // Get the object
  VDobjGetID(objOE,objID,&theID);
  if (theID.objid == NULL_OBJID) goto wrapup;

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

  if (*path) {
    retFlag = 1;
    goto wrapup;
  }
    
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}
/* -----------------------------------------------
 * Simple interface for name
 */
IGRstat VDobjGetName(TGRobj_env *objOE, TGRid *objID, IGRchar *name)
{
  IGRstat retFlag = 0;

  IGRchar path[512];
  IGRchar *p;
  
  // Arg check
  if (name == NULL) goto wrapup;
  *name = 0;
  
  // Get the path
  VDobjGetPath(objOE,objID,path);
  if (*path == 0) goto wrapup;
  
  // Extract name
  p = strrchr(path,':');
  if (p) strcpy(name,p+1);
  else   strcpy(name,path);
  
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
  IGRstat sts;
  
  TGRid theID;
  
  // Arg check
  if (className == NULL) goto wrapup;
  *className = 0;
  
  // Get the object
  VDobjGetID(objOE,objID,&theID);
  if (theID.objid == NULL_OBJID) goto wrapup;
  
  // Pull the name
  om$get_classname(osnum = theID.osnum,
		   objid = theID.objid,
		   classname = className);
  
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
  VDobjGetID(objOE,objID,&theID);
  if (theID.objid == NULL_OBJID) goto wrapup;
  
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

  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}
/* -----------------------------------------------
 * Simple interface for symbology
 */
IGRstat VDobjGetSymbology(TGRobj_env *objOE, TGRid *objID, TGRsymbology *symb)
{
  IGRstat retFlag = 0;
  IGRstat sts,msg;
  
  TGRid theID;
  
  // Arg check
  if (symb == NULL) goto wrapup;
  memset(symb,0,sizeof(TGRsymbology));
  
  // Get the object
  VDobjGetID(objOE,objID,&theID);
  if (theID.objid == NULL_OBJID) goto wrapup;

  // Get symbology
  sts = om$send(msg = message GRvg.GRgetsymb(&msg,symb),
		senderid = NULL_OBJID,
		targetid = theID.objid,
		targetos = theID.osnum);
  if (!(sts & msg & 1)) goto wrapup;
  
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Simplified print wrapper
 */
IGRstat VDobjPrint2(TGRobj_env *objOE,TGRid *objID)
{
  IGRstat sts;
  
  TGRid theID;

  // Get the object
  VDobjGetID(objOE,objID,&theID);
  if (theID.objid != NULL_OBJID) {
  }
  
  // Pass on
  return vdobj$Print(objOE = objOE, objID = objID);
}

/* ----------------------------------------------
 * Simplified wrapper for di$translate
 */
IGRint VDtranslate(IGRchar *path, TGRid *objID)
{
  IGRstat retFlag = 0;

  // Arg check
  if (objID == NULL) goto wrapup;
  objID->objid = NULL_OBJID;
  if ((path == NULL) || (*path == 0)) goto wrapup;
  
  // Do it
  di$translate(objname = path,
	       p_osnum = &objID->osnum,
	       p_objid = &objID->objid);
  if (objID->objid == NULL_OBJID) goto wrapup;
  
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

from NDmacro import ACtest_consumed;
from ACncpx  import ACget_NV_rep;

/* -----------------------------------------------
 * Wrapper to see if object is consumed
 */
IGRstat VDobjIsConsumed(TGRobj_env *objOE,TGRid *objID)
{
  IGRstat retFlag = 0;
  
  IGRstat sts,msg;
  
  TGRid theID;

  // Get the object
  VDobjGetID(objOE,objID,&theID);
  if (theID.objid == NULL_OBJID) goto wrapup;

  sts = om$send(msg = message NDmacro.ACtest_consumed(&msg),
		senderid = NULL_OBJID,
		targetid = theID.objid,
		targetos = theID.osnum);

  if (sts & msg & 1) retFlag = 1;
    
  // Pass on
 wrapup:
  return retFlag;
  
}

/* -----------------------------------------------
 * Wrapper to get object's rep
 * Rep is a single character
 */
IGRstat VDobjGetRep(TGRobj_env *objOE,TGRid *objID, IGRuchar *rep)
{
  IGRstat retFlag = 0;
  
  IGRstat sts;
  
  TGRid theID;

  // Get the object
  if (rep == NULL) goto wrapup;
  *rep = 0;
  
  VDobjGetID(objOE,objID,&theID);
  if (theID.objid == NULL_OBJID) goto wrapup;

  sts = om$send(msg = message ACncpx.ACget_NV_rep(rep),
		senderid = NULL_OBJID,
		targetid = theID.objid,
		targetos = theID.osnum);

  if (sts & 1) retFlag = 1;
    
  // Pass on
 wrapup:
  return retFlag;
  
}

/* -----------------------------------------------
 * Given a filled in objOE->obj_id.osnum, reset
 * the matrix and other stuff
 */
void VDobjResetOE(TGRobj_env *objOE)
{
  gr$get_module_env(buffer = &objOE->mod_env);

  objOE->mod_env.md_id.osnum = objOE->obj_id.osnum;
  
  ex$get_modid(mod_osnum =  objOE->mod_env.md_id.osnum,
	       mod_id    = &objOE->mod_env.md_id.objid);

  return;
}

/* -------------------------------------------------------------
 * Finds the child who consumed the parent.
 *
 * Will only work if the child is in the same file as the parent.
 *
 * The basic idea is that the GRgetname of the child will match that
 * of it's consumed parent
 *
 * 18 Apr 2002 - ah
 * This used to be in vdat/pcmk
 * Does not look like it's really being used though it
 * probably should be.
 */
IGRstat VDobjGetConsumingChild(TGRobj_env *parentOE, TGRobj_env *childOE)
{
  VDASSERT_FN("VDobjGetConsumingChild");
  IGRstat retFlag = 0;
  IGRstat sts,msg;
  
  IGRchar parentPath[DI_PATH_MAX];
  IGRchar childPath [DI_PATH_MAX];
  
  TGRid   childID;
  IGRint  i;

  TGRobj_env parentOEx;
  
  // Arg check
  VDASSERTW(parentOE);
  VDASSERTW(childOE);  
  *childOE = *parentOE;
  
  // Verify parent is consumed
  msg = 0;
  sts = om$send(msg = message NDmacro.ACtest_consumed(&msg),
		senderid = NULL_OBJID,
		targetid = parentOE->obj_id.objid,
		targetos = parentOE->obj_id.osnum);

  // If not consumed then just return itself
  if (!(sts & msg & 1)) {
    retFlag = 1;
    goto wrapup;
  }
  
  // Get the parent's path
  *parentPath = 0;
  om$send(msg = message GRgraphics.GRgetname(&msg,parentPath),
	  senderid = NULL_OBJID,
	  targetid = parentOE->obj_id.objid,
	  targetos = parentOE->obj_id.osnum);

  // Without a path, this won't work
  if (*parentPath == 0) {
    goto wrapup;
  }
  
  // Cycle through kids
  for(i = 0; VDahGetChnObject(&parentOE->obj_id,"NDchildren.children",i,&childID); i++) {
    *childPath = 0;

    om$send(msg = message GRgraphics.GRgetname(&msg,childPath),
	    senderid = NULL_OBJID,
	    targetid = childID.objid,
	    targetos = childID.osnum);
    
    if (!strcmp(parentPath,childPath)) {
      
      // Got it
      childOE->obj_id = childID;
      
      // Recurse incase child itself is consumed
      parentOEx = *childOE;
      return VDobjGetConsumingChild(&parentOEx,childOE);
      
    }
    
  }
  
  // Child not found, just return itself

wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Given a full path (including file name)
 * Return the oe
 *
 * 18 Apr 2002 - ah
 * This used to be in vdat/pcmk
 * Does not look like it's really being used though it
 * probably should be.
 */
IGRstat VDobjGetObjectByPath(IGRchar *path, TGRobj_env *a_objOE)
{
  VDASSERT_FN("VDobjGetObjectByPath");

  IGRstat retFlag = 0;
  VDosnum osnum;
  IGRchar osFileName[128];
  IGRchar newPath[DI_PATH_MAX];

  TGRobj_env objOE;
  TGRobj_env childOE;
  
  IGRchar *p;
  
  // Arg check
  VDASSERTW(a_objOE);
  a_objOE->obj_id.objid = NULL_OBJID;
  VDASSERTW(path);
  if (*path == 0) goto wrapup;
  
  // First check in local file
  di$translate(objname =  path,
	       p_objid = &objOE.obj_id.objid,
	       p_osnum = &objOE.obj_id.osnum);

  if (objOE.obj_id.objid != NULL_OBJID) goto got_it;
  
  // Check in reference file
  ex$get_cur_mod  (osnum = &osnum);
  di$give_pathname(osnum =  osnum, pathname = osFileName);

  // Get just the file
  p = strrchr(osFileName,':');
  if (p) p++;
  else   p = osFileName;
  
  sprintf(newPath,":%s:ref%s",p,path);
  
  di$translate(objname =  newPath,
	       p_objid = &objOE.obj_id.objid,
	       p_osnum = &objOE.obj_id.osnum);

  if (objOE.obj_id.objid != NULL_OBJID) goto got_it;
  
  // Give up
  // printf("*** Could not find %s\n",path);
  goto wrapup;
  
  // -----------------------------------------------
  // Got a new piece so attach it
got_it:

  // Matrix should not be really important (I hope)
  gr$get_module_env(buffer = &objOE.mod_env);

  objOE.mod_env.md_id.osnum = objOE.obj_id.osnum;
  
  ex$get_modid(mod_osnum =  objOE.mod_env.md_id.osnum, 
	       mod_id    = &objOE.mod_env.md_id.objid);

  // This guy could be consumed
  VDobjGetConsumingChild(&objOE,&childOE);

  // Store it
  *a_objOE = childOE;
  
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

end implementation Root;




