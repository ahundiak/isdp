/* $Id: VDppl2.I,v 1.3 2001/01/11 16:34:32 art Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdah/VDppl2.I
 *
 * Description: ppl functions to support struct detail macros
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDppl2.I,v $
 *      Revision 1.3  2001/01/11 16:34:32  art
 *      sp merge
 *
 *      Revision 1.1  2001/01/11 16:20:59  art
 *      s merge
 *
 *      Revision 1.1.1.1  2001/01/04 21:07:40  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1999/05/07  15:28:04  pinnacle
# ah
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 05/07/99  ah      Creation
 ***************************************************************************/

class implementation Root;

/* ------------------------------------------
 * For better object manipulation
 */
#include "VDtypedef.h"
#include "VDobj.h"
#include "VDsa.h"
#include "VDppl2.h"

extern VDclassid OPP_ASsource_class_id;
extern VDclassid OPP_ACpretend_class_id;

from NDmacro import ACreturn_foot;
from NDnode  import ASreturn_go;
from NDnode  import NDgive_structure;
from ACcpx   import ACfind_exp_temp_obj;

/* --------------------------------------------
 * Utility for verifying an objects class
 */
IGRstat VDpplVerifyClass(TGRid *objID, IGRchar *className)
{
  // Simple wrapper
  return vdobj$IsAncestryValid(objID = objID, superClassName = className);
}
#if 0
/* --------------------------------------------
 * Utility for extracting obj_env from source
 */
IGRstat VDpplGetObjectEnv(TGRid *objID, TGRobj_env *objOE)
{
  // Simple Wrapper
  return VDahGetObjectEnv(objID,objOE);
}

/* --------------------------------------------
 * Gets the parent of a macro
 */
IGRstat VDpplGetParent(TGRid       *macroID,
		       IGRint      index,
		       TGRobj_env *parentOE)
{

  // Simple wrapper
  return vdobj$GetTemplate(objID      = macroID,
			   nth        = index,
			   templateOE = parentOE);
}
#endif

/* --------------------------------------------
 * Utility for extracting obj_env from source
 */
IGRstat VDpplGetObjectEnv(TGRid *objID, TGRobj_env *objOE)
{
  IGRstat   retFlag;
  IGRstat   sts,msg;
  GRclassid classID;

  // Init
  retFlag = 0;
  objOE->obj_id.objid = NULL_OBJID;

  /* Filter Nulls */
  if ((objID == NULL) ||
      (objID->objid == 0) || 
      (objID->objid == NULL_OBJID)
  ) goto wrapup;

  /* Check to see if ASsource or ACpretend */
  classID = 0;
  om$get_classid(
    objid = objID->objid,
    osnum = objID->osnum,
    p_classid = &classID
  );
  sts = om$is_ancestry_valid(
    subclassid   = classID,
    superclassid = OPP_ASsource_class_id
  );
  if (sts == OM_S_SUCCESS) goto have_source;
  sts = om$is_ancestry_valid(
    subclassid   = classID,
    superclassid = OPP_ACpretend_class_id
  );
  if (sts == OM_S_SUCCESS) goto have_source;

  // Object is in the same os and needs no translation
  objOE->obj_id = *objID;
  gr$get_module_env(buffer = &objOE->mod_env);
  retFlag = 1;
  goto wrapup;

have_source:

  printf("In GetObjEnv with a source object\n");
  
  // Get the object, want the real parent and not the graphical foot
  sts = om$send(msg = message NDmacro.
		ACreturn_foot(&msg,".",
			      &objOE->obj_id,
			      &objOE->mod_env.md_env.matrix_type,
			       objOE->mod_env.md_env.matrix),
		senderid = NULL_OBJID,
		targetid = objID->objid,
		targetos = objID->osnum);

  // Set md_id to the reference file
  objOE->mod_env.md_id.osnum = objOE->obj_id.osnum;
  sts = ex$get_modid(
    mod_osnum =  objOE->mod_env.md_id.osnum, 
    mod_id    = &objOE->mod_env.md_id.objid
  );
  if (!(sts & 1)) goto wrapup;
 
  retFlag = 1;
wrapup:
  return retFlag;
}

/* --------------------------------------------
 * Gets the parent of a macro
 */
IGRstat VDpplGetParent(TGRid *macroID, IGRint index, TGRobj_env *parentOE)
{
  IGRstat retFlag;
  IGRstat sts;
  IGRint  msg;
  TGRid   parentID;

  // Init
  retFlag = 0;
  parentOE->obj_id.objid = NULL_OBJID;
  parentID.objid = NULL_OBJID;

  // Get the parent object
  sts = om$send( 
    msg = message ACcpx.ACfind_exp_temp_obj(&msg,index,&parentID),
    senderid = NULL_OBJID,
    targetid = macroID->objid,
    targetos = macroID->osnum 
  );
  if (!(sts & msg & 1)) goto wrapup;
  if (parentID.objid == NULL_OBJID) goto wrapup;

  printf("In GetParent\n");
  vdobj$Print(objID = macroID);
  vdobj$Print(objID = &parentID);
  
  // Un Source it
  VDpplGetObjectEnv(&parentID,parentOE);
  if (parentOE->obj_id.objid == NULL_OBJID) goto wrapup;

  retFlag = 1;

wrapup:

  return retFlag;
}
  
/* ------------------------------------------------
 * Gets the structure data for the foot of a macro
 */
IGRstat VDpplGetStructure(TGRobj_env  *objOE,
			  IGRchar     *footName,
			  Tret_struct *data)
{
  IGRstat retFlag;
  IGRint  sts,msg;

  return vdsa$GetStruct(objOE = objOE, name = footName, rs = data);
}

/* ------------------------------------------------
 * Gets the structure data for the foot of a macro
 */
IGRstat VDpplGetFootText(TGRobj_env  *objOE,
			 IGRchar     *footName,
			 IGRchar     *data)
{
  IGRstat retFlag;
  IGRint  sts,msg;

  return vdsa$GetStruct(objOE = objOE, name = footName, txt = data);
}
/* ------------------------------------------------
 * Gets the structure data for the foot of a macro
 */
IGRstat VDpplGetFootDouble(TGRobj_env  *objOE,
			   IGRchar     *footName,
			   IGRdouble   *data)
{
  IGRstat retFlag;
  IGRint  sts,msg;

  return vdsa$GetStruct(objOE = objOE, name = footName, dbl = data);
}

/* =========================================================================
 * This is a function that uses the template index and returns a text string
 * The parent is an expression
 */
IGRstat VDpplGetTextParent(TGRid   *macroID, 
			   IGRint   index, 
			   IGRchar *data)
{
  IGRstat    retFlag;
  IGRstat    sts,suc;
  TGRobj_env parentOE;

  Tret_struct rs;

  // Init
  retFlag = 0;
  *data = 0;

  // Get the object
  vdobj$GetTemplate(objID = macroID, nth = index, templateOE = &parentOE);
  if (parentOE.obj_id.objid == NULL_OBJID) goto wrapup;

  /* Check value */
  sts = om$send(
    msg = message NDnode.NDgive_structure(&suc,&rs,&parentOE.mod_env),
    senderid = NULL_OBJID,
    targetid = parentOE.obj_id.objid,
    targetos = parentOE.obj_id.osnum
  );
  if (!(sts&suc&1)) {
    printf("Bad Give Struct\n");
    goto wrapup;
  }

  // Verify it is text
  if (rs.type != text_type) {
    printf("Bad Struct Type\n");
    goto wrapup;
  }

  // Transfer
  strcpy(data,rs.var.text_st.text_string);
  retFlag = 1;

wrapup:

  return retFlag;
}

/* =========================================================================
 * This is a function that uses the template index and returns a double
 * The parent is an expression
 */
IGRstat VDpplGetDoubleParent(TGRid     *macroID, 
			     IGRint     index, 
			     IGRdouble *data)
{
  IGRstat    retFlag;
  IGRstat    sts,suc;
  TGRobj_env parentOE;

  Tret_struct rs;

  // Init
  retFlag = 0;
  *data = 0.0;

  // Get the object
  vdobj$GetTemplate(objID = macroID, nth = index, templateOE = &parentOE);
  if (parentOE.obj_id.objid == NULL_OBJID) goto wrapup;

  /* Check value */
  sts = om$send(
    msg = message NDnode.NDgive_structure(&suc,&rs,&parentOE.mod_env),
    senderid = NULL_OBJID,
    targetid = parentOE.obj_id.objid,
    targetos = parentOE.obj_id.osnum
  );
  if (!(sts&suc&1)) {
    printf("Bad Give Struct\n");
    goto wrapup;
  }

  // Verify it is a double
  if (rs.type != double_type) {
    printf("Bad Struct Type\n");
    goto wrapup;
  }

  // Transfer
  *data = rs.var.root_pm_st.value;
  retFlag = 1;

wrapup:

  return retFlag;
}

end implementation Root;




