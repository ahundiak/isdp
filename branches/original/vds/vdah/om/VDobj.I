/* $Id: VDobj.I,v 1.4 2001/10/24 15:52:49 jayadev Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdah/VDobj.I
 *
 * Description:	Object Processing
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDobj.I,v $
 *      Revision 1.4  2001/10/24 15:52:49  jayadev
 *      *** empty log message ***
 *
 *      Revision 1.3  2001/01/11 16:34:31  art
 *      sp merge
 *
 *      Revision 1.1  2001/01/11 16:20:58  art
 *      s merge
 *
 *      Revision 1.1.1.1  2001/01/04 21:07:40  cvs
 *      Initial import to CVS
 *
# Revision 1.7  1999/05/31  16:15:46  pinnacle
# ejm
#
# Revision 1.6  1999/05/24  18:16:34  pinnacle
# ah
#
# Revision 1.5  1999/04/26  20:41:06  pinnacle
# ah
#
# Revision 1.4  1999/01/28  22:28:04  pinnacle
# spades
#
# Revision 1.3  1999/01/27  17:52:44  pinnacle
# spades
#
# Revision 1.2  1998/11/29  14:41:50  pinnacle
# ah
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 04/09/98  ah      Creation
 * 10/08/98  ah      Added get foot routine
 * 04/26/99  ah      Added VDobjGetPretendParent
 * 05/11/99  ah      Added VDobjIsObjectAParent
 * 05/26/99  ejm     VDobjGetParent: moved "retFlag=1" inside IsAncestryValid
 *			check for ACpretendin parent (found during 
 *			CR_179900195 work)
 ***************************************************************************/
class implementation ACncpx;

#include "VDtypedef.h"
#include "VDdir.h"
#include "VDobj.h"
#include "VDchn.h"

#include "VDfld.h"
#include "VDbt.h"

extern GRclassid OPP_expression_class_id;
extern GRclassid OPP_ACcpx_class_id;
extern GRclassid OPP_ACpretend_class_id;
extern GRclassid OPP_ACrg_collect_class_id;

from ACcpx_defn   import ACgive_name;
from ACpretend    import ACgive_downscan;
from expression   import DIgive_output;
from ACrg_collect import AClist_attribute;

// Used to translate to category
extern IGRboolean
VD_compGetCompFromMacro (
	char	*macro,		/* I: macro name  - user allocated buffer */
	int	buf_size,	/* I: length of macro, comp buffers */ 	
        char    **comp      	/* O: component name  - ptr to user buffer */
	);

/* ------------------------------------------------------------
 * Recursive routine to see if 2nd argument is a parent of
 * the first argument connected in the nth slot on the father channel
 * Only check objid's for now
 */
IGRstat VDobjIsObjectAParent(TGRobj_env *childOE, TGRobj_env *parentOE, IGRint nth)
{
  IGRstat retFlag = 0;
 
  TGRobj_env parentOEx;
  
  // Arg check
  if ( childOE == NULL) goto wrapup;
  if (parentOE == NULL) goto wrapup;

  // Might be a direct match
  if ((childOE->obj_id.objid == parentOE->obj_id.objid) && 
      (childOE->obj_id.osnum == parentOE->obj_id.osnum)) {
    retFlag = 1;
    goto wrapup;
  }
  
  // Go up and try again
  vdobj$GetTemplate(objOE = childOE,
		    nth   = nth,
		    templateOE = &parentOEx);
  if (parentOEx.obj_id.objid == NULL_OBJID) goto wrapup;
  
  retFlag = VDobjIsObjectAParent(&parentOEx,parentOE,nth);
  
wrapup:
  return retFlag;
}

/* --------------------------------------------
 * Gets the actual parent of a pretend object
 * possibly going through a reference file
 */
IGRstar VDobjGetPretendParent(TGRid *pretendID, TGRid *parentID)
{
  
  IGRstat retFlag = 0;
  IGRstat sts;
  
  IGRchar className[128];

  IGRint  i;
  
  // Init
  if (parentID == NULL) goto wrapup;
  parentID->objid = NULL_OBJID;
  if (pretendID == NULL) goto wrapup;

  // Check if a source
  vdobj$Get(objID = pretendID, className = className);

  // ACpretend connects via father channel
  if (!strcmp(className,"ACpretend")) {
    
    vdchn$Get2(objID  = pretendID,
	       chnIDx = VDCHN_IDX_FATHER,
	       nth    = 0,
	       outID  = parentID);

    if (parentID->objid != NULL_OBJID) retFlag = 1;
    goto wrapup;
    
  }

  // ACpretendin connects via listener channel
  if (!strcmp(className,"ACpretendin")) {

    TVDvlaID lstVLA;
    TGRid    tryID;
    
    VDvlaID_Construct(&lstVLA);
    
    // Unordered channels suck!
    vdchn$Get2(objID  = pretendID,
	       chnIDx = VDCHN_IDX_LISTENER,
	       outVLA = &lstVLA);
    
    for(i = 0; VDvlaID_GetAt(&lstVLA,&tryID,i); i++) {

      if (vdobj$IsAncestryValid(objID = &tryID, superClassName = "ACncpx")) {

	*parentID = tryID;
	
	VDvlaID_Delete(&lstVLA);
	retFlag = 1;
	goto wrapup;
	
      } 
    }

    VDvlaID_Delete(&lstVLA);
    goto wrapup;
  }

  // Verify it's a pretend
  sts = vdobj$IsAncestryValid(objID        = pretendID,
			      superClassID = OPP_ACpretend_class_id);

  if (!(sts & 1)) goto wrapup;
  
wrapup:

  return retFlag;
}

/* --------------------------------------------
 * Utility for getting a template then
 * changing the id into an oe
 */
IGRstar VDobjGetTemplate(TGRobj_env *objOE,
                         TGRid      *objID, 
                         IGRint      nth, 
                         TGRobj_env *parOE)
{
  IGRstat retFlag = 0;
  TGRid   srcID;
  TGRid   theID;

  // Arg Check
  if (parOE == NULL) goto wrapup;
  parOE->obj_id.objid = NULL_OBJID;

  // Get the object
  theID.objid = NULL_OBJID;
  if (objOE) theID =  objOE->obj_id;
  if (objID) theID = *objID;
  if (theID.objid == NULL_OBJID) goto wrapup;

  // Get the parent
  srcID.objid = NULL_OBJID;
  vdchn$Get(il_objID  = &theID, 
            ic_IDX    = VDCHN_IDX_PARENT, 
            ir_objIDX = nth, 
            or_objID  = &srcID);
  if (srcID.objid == NULL_OBJID) goto wrapup;

  // Unsource it
  VDahGetObjectEnv(&srcID,parOE);
  if (parOE->obj_id.objid == NULL_OBJID) goto wrapup;

  retFlag = 1;

wrapup:
  return retFlag;
}

/* --------------------------------------------
 * Specialized routine for reaching parents
 */
extern IGRstar VDobjGetParent
(
 TGRobj_env *a_objOE,
 TGRid      *a_objID,
 IGRint      a_idx,

 TGRid      *a_parentID,
 TGRid      *a_sourceID,
 TGRid      *a_pretendID
 )
{
  IGRstat retFlag = 0;

  TGRid      parentID;
  TGRid      sourceID;
  TGRid      pretendID;
  
  TGRobj_env objOE;
  
  IGRchar    className[128];

  IGRint     i;
  
  // Init
  if (a_parentID)  a_parentID->objid  = NULL_OBJID;
  if (a_sourceID)  a_sourceID->objid  = NULL_OBJID;
  if (a_pretendID) a_pretendID->objid = NULL_OBJID;
  
   sourceID.objid = NULL_OBJID;
   parentID.objid = NULL_OBJID;
  pretendID.objid = NULL_OBJID;
  
  // Arg Check
  objOE.obj_id.objid = NULL_OBJID;
  objOE.mod_env.md_id.objid = NULL_OBJID;
  
  if (a_objOE)  objOE         = *a_objOE;
  if (a_objID)  objOE.obj_id  = *a_objID;

  if (objOE.obj_id.objid == NULL_OBJID) goto wrapup;
  
  // Get the parent
  vdchn$Get(il_objOE  = &objOE,
	    ic_IDX    = VDCHN_IDX_FATHER,
	    ir_objIDX = a_idx,
	    or_objID  = &parentID);

  if (parentID.objid == NULL_OBJID) goto wrapup;

  // Check if a source
  vdobj$Get(objID = &parentID, className = className);
  
  // ACpretend connects via father channel
  if (!strcmp(className,"ACpretend")) {

    pretendID = parentID;
    parentID.objid = NULL_OBJID;
    
    // Get the parent
    vdchn$Get(il_objID  = &pretendID,
	      ic_IDX    = VDCHN_IDX_FATHER,
	      ir_objIDX = 0,
	      or_objID  = &parentID);

    if (parentID.objid == NULL_OBJID) goto wrapup;

    retFlag = 1;
    goto wrapup;
    
  }

  // ACpretendin connects via listener channel
  if (!strcmp(className,"ACpretendin")) {

    TVDvlaID lstVLA;
    TGRid    tryID;
    
    VDvlaID_Construct(&lstVLA);

    pretendID = parentID;
    parentID.objid = NULL_OBJID;
    
    // Unordered channels suck!
    vdchn$Get(il_objID = &pretendID,
	      ic_IDX   = VDCHN_IDX_LISTENER,
	      or_vlaID = &lstVLA);
    
    for(i = 0; VDvlaID_GetAt(&lstVLA,&tryID,i); i++) {

      if (vdobj$IsAncestryValid(objID = &tryID, superClassName = "ACncpx")) {

	parentID = tryID;
	
	VDvlaID_Delete(&lstVLA);
	retFlag = 1;
	goto wrapup;
	
      } 
    }

    VDvlaID_Delete(&lstVLA);
    goto wrapup;
    
  }

wrapup:
  if (a_parentID)  *a_parentID  = parentID;
  if (a_sourceID)  *a_sourceID  = sourceID;
  if (a_pretendID) *a_pretendID = pretendID;

  return retFlag;
}

/* --------------------------------------------
 * Get assorted bits of info
 */
extern IGRstar VDobjGet
(
  TGRobj_env    *a_objOE,
  TGRid         *a_objID,
  TGRmd_env     *a_objENV,

  TVDobjInfo    *info,
  IGRchar       *desc,

  IGRchar       *className,
  IGRchar       *category,
  VDclassid     *classID,

  IGRchar       *macName,
  IGRchar       *objName,
  IGRchar       *objPath,
  IGRchar       *disName,
  TGRsymbology  *symb
  )
{
  IGRstat retFlag = 0;
  IGRstat msg;
  
  TGRobj_env objOE;
  TGRid      objID;
  
  TVDobjInfo infox;
  
  IGRchar  data[1024];
  IGRchar *p;

  IGRchar *macNamex = NULL;
  
  // Init
  objOE.obj_id.objid = NULL_OBJID;
  objOE.mod_env.md_id.objid = NULL_OBJID;
  *data = 0;
  
  /* Xfer args */
  if (a_objOE)  objOE         = *a_objOE;
  if (a_objID)  objOE.obj_id  = *a_objID;
  if (a_objENV) objOE.mod_env = *a_objENV;

  // Reset
  if (info) {
    memset(info,0,sizeof(TVDobjInfo));
    info->objOE = objOE;
  }
  if (desc)      *desc = 0;
  if (className) *className = 0;
  if (category)  *category = 0;
  if (classID)   *classID = 0;
  
  if (macName) *macName = 0;
  if (objName) *objName = 0;
  if (objPath) *objPath = 0;
  if (disName) *disName = 0;
  
  if (symb) memset(symb,0,sizeof(TGRsymbology));
  
  // The info
  if (info) {
    VDobjGetInfo(&objOE,info);
    retFlag = 1;
    goto wrapup;
  }
  
  // The description
  if (desc) {
    VDobjGetInfo(&objOE,&infox);
    VDobjGetDesc(&infox,desc);
    retFlag = 1;
    goto wrapup;
  }

  // Need an object for the rest to succede
  objID = objOE.obj_id;
  if (objID.objid == NULL_OBJID) goto wrapup;
  retFlag = 1;
  
  // Class id
  if (classID) {  
    om$get_classid(osnum = objID.osnum,
		   objid = objID.objid,
		   p_classid = classID);
    goto wrapup;
  }

  // Class name
  if (className) {  
    om$get_classname(osnum = objID.osnum,
		     objid = objID.objid,
		     classname = className);
    goto wrapup;
  }

  // Name or path (extend later for return go stuff)
  if (objName || objPath || disName) {
  
    *data = 0;
    
    om$send(msg = message GRgraphics.GRgetname(&msg,data),
	    senderid = NULL_OBJID,
	    targetid = objID.objid,
	    targetos = objID.osnum);

    if (objPath) strcpy(objPath,data);
    
    p = strrchr(data,':');
    if (p) strcpy(data,p+1);
    
    if (objName) strcpy(objName,data);
    
    if (disName) {
      strcpy(disName,data);
      if (*disName == 0) strcpy(disName,"Defined");
    }

    retFlag = 1;
    goto wrapup;
  }

  // The symbology
  if (symb) {
   
    om$send(msg = message GRvg.GRgetsymb(&msg,symb),
	    senderid = NULL_OBJID,
	    targetid = objID.objid,
	    targetos = objID.osnum);

    retFlag = 1;
    goto wrapup;
  }

  // Macro Name
  if (macName || category) {

    TGRid    macID;
    
    macID.objid = NULL_OBJID;
    
    om$send(msg = message 
	    ACcpx.find_macro(&macID),
	    senderid = NULL_OBJID,
	    targetid = objID.objid,
	    targetos = objID.osnum);
    
    if (macID.objid == NULL_OBJID) goto wrapup;
    
    om$send(msg = message 
	    ACcpx_defn.ACgive_name(&macNamex),
	    senderid = NULL_OBJID,
	    targetid = macID.objid,
	    targetos = macID.osnum);
    if (macNamex == NULL) goto wrapup;
    
    if (macName) {
      strcpy(macName,macNamex);
      retFlag = 1;
      goto wrapup;
    }
    
  }

  // Category
  if (category) {

    if (macNamex == NULL) goto wrapup;
    *data = 0;

    p = data;
    
    VD_compGetCompFromMacro (macNamex,128,&p);
    if (*data == 0) goto wrapup;
    
    if (category) strcpy(category,data);
    retFlag = 1;
    goto wrapup;
    
  }
  
wrapup:
  return retFlag;
}

/* --------------------------------------------
 * Internal routine
 * Generates 1 line description
 */
IGRstat VDobjGetDesc(TVDobjInfo *info, IGRchar *desc)
{
  IGRchar work[1024];

  sprintf(desc,"OBJ %d,%d",
          info->objOE.obj_id.osnum,
          info->objOE.obj_id.objid);

  strcpy(work,info->className);
  if (*work) {
    strcat(desc," ");
    strcat(desc,work);
  }

  strcpy(work,info->downScan);
  if (*work) {
    strcat(desc,".");
    strcat(desc,work);
  }

  strcpy(work,info->macName);
  if (*work) {
    strcat(desc," ");
    strcat(desc,work);
  }

  strcpy(work,info->objName);
  if (*work) {
    strcat(desc," ");
    strcat(desc,work);
  }

  strcpy(work,info->expStr);
  if (*work) {
    strcat(desc," ");
    strcat(desc,work);
  }

  return 1;
}

/* --------------------------------------------
 * Internal routine
 * Everything about an object
 */
IGRstar VDobjGetInfo(
  TGRobj_env *objOE,
  TVDobjInfo *info)
{
  IGRstat retFlag = 0;
  IGRstat sts;

  TGRid    objID;
  IGRchar *macName;

  /* Reset Info */
  memset(info,0,sizeof(TVDobjInfo));
  info->objOE = *objOE;
  
  /* Get the obj */
  objID = info->objOE.obj_id;
  if (objID.objid == NULL_OBJID) {
    strcpy(info->className,"NULL OBJID");
    goto wrapup;
  }

  /* Class Id */
  sts = om$get_classid(
    osnum = objID.osnum,
    objid = objID.objid,
    p_classid = &info->classID
  );
  if (!(sts & 1)) {
    strcpy(info->className,"BAD CLASS");
    return 0;
  }

  /* Classname */
  sts = om$get_classname(
    classid   = info->classID,
    classname = info->className
  );
  if (!strcmp(info->className,"OMOSCO")) goto wrapup;

  /* Get Macro Name */
  sts = om$is_ancestry_valid(
      subclassid = info->classID,
    superclassid = OPP_ACcpx_class_id);

  if (sts == OM_S_SUCCESS) {

    sts = om$send(
      msg = message ACcpx.find_macro(&info->macID),
      senderid = NULL_OBJID,
      targetid = objID.objid,
      targetos = objID.osnum);

    if (!(sts & 1)) {
      strcpy(info->macName,"BAD find_macro");
      goto continue1;
    }

    sts = om$send(
      msg = message ACcpx_defn.ACgive_name(&macName),
      senderid = NULL_OBJID,
      targetid = info->macID.objid,
      targetos = info->macID.osnum);

    if (!(sts & 1)) {
      strcpy(info->macName,"BAD ACgive_name");
      goto continue1;
    }

    strcpy(info->macName,macName);
  }
continue1:

  /* Get Downscan Name */
  sts = om$is_ancestry_valid(
      subclassid = info->classID,
    superclassid = OPP_ACpretend_class_id);

  if (sts == OM_S_SUCCESS) {

    sts = om$send(
      msg = message ACpretend.ACgive_downscan(info->downScan),
      senderid = NULL_OBJID,
      targetid = objID.objid,
      targetos = objID.osnum);

    if (!(sts & 1)) {
      strcpy(info->downScan,"BAD downScan");
    }
  }

  /* Get Tree Name Name */
  sts = om$is_ancestry_valid(
    subclassid     = info->classID,
    superclassname = "VDatBase"
  );

  if (sts == OM_S_SUCCESS) {

    sts = VDatGetBaseName(&objID,info->downScan);

    if (!(sts & 1)) {
      strcpy(info->downScan,"BAD VDatBase.getName");
    }
  }

  /* Get Tree Name Name */
  sts = om$is_ancestry_valid(
    subclassid     = info->classID,
    superclassname = "VDbtBase"
  );

  if (sts == OM_S_SUCCESS) {
    
    sts = vdbt$GetBase(objID = &objID, name = info->downScan);

    if (!(sts & 1)) {
      strcpy(info->downScan,"BAD VDbtBase.getName");
    }
  }

  /* Get any name */
  sts = di$untranslate(
    objname = info->objName,
    objid = objID.objid,
    osnum = objID.osnum);

  /* Get Any Expression */
  sts = om$is_ancestry_valid(
      subclassid = info->classID,
    superclassid = OPP_expression_class_id);

  if (sts == OM_S_SUCCESS) {

    sts = om$send(
      msg = message expression.DIgive_output(info->expStr),
      senderid = NULL_OBJID,
      targetid = objID.objid,
      targetos = objID.osnum);

    if (!(sts & 1)) {
      strcpy(info->expStr,"BAD DIgive_output");
    }
  }
  info->sts = 1;

wrapup:
  return retFlag;
}

/* -----------------------------------------------------------
 * Pretty print an object
 */
IGRstat VDobjPrint(
  TGRobj_env    *a_objOE,
  TGRid         *a_objID,
  TGRmd_env     *a_objENV,

  IGRboolean     a_trace,
  IGRboolean     a_cr,

  IGRchar       *a_buf,
  FILE          *a_file,
  TVDobjInfo    *a_info
)
{
  IGRstat sts = 0;
  IGRchar buf[1024];
  TVDobjInfo info;

  TGRobj_env objOE;
  
  // Ignore completely of trace is off
  if (a_trace == FALSE) goto wrapup;
  
  // Init
  objOE.obj_id.objid = NULL_OBJID;
  objOE.mod_env.md_id.objid = NULL_OBJID;

  /* Xfer args */
  if (a_objOE)  objOE         = *a_objOE;
  if (a_objID)  objOE.obj_id  = *a_objID;
  if (a_objENV) objOE.mod_env = *a_objENV;

  // Not sure about error checking, just return the code
  sts = VDobjGetInfo(&objOE,&info);

  // Copy the info
  if (a_info) *a_info = info;

  // Sprintf if desired
  if ((a_buf == NULL) && (a_file == NULL)) goto wrapup;

  // Get the desc
  VDobjGetDesc(&info,buf);

  // Add cr
  if (a_cr) strcat(buf,"\n");
  
  // Xfer to buf 
  if (a_buf) {
    strcpy(a_buf,buf);
    goto wrapup;
  }

  // Print to file
  fputs(buf,a_file);
  
wrapup:
  return sts;
}

/* --------------------------------------------------------------------
 * My own ancestry valid with various inputs
 */
IGRstar VDobjIsAncestryValid
  (TGRobj_env *a_objOE, 
   TGRid      *a_objID,
   VDclassid   a_classID,
   IGRchar    *a_className)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  
  TGRid   objID;
  
  VDclassid superClassID;
  VDclassid   subClassID;
  
  // Get the object in question
  objID.objid = NULL_OBJID;
  if (a_objOE) objID =  a_objOE->obj_id;
  if (a_objID) objID = *a_objID;
  if (objID.objid == NULL_OBJID) goto wrapup;
  
  // Get the sub class id
  sts = om$get_classid(osnum     = objID.osnum,
		       objid     = objID.objid,
		       p_classid = &subClassID);
  if (!(sts & 1)) goto wrapup;

  // Get the super class id
  if (a_className == NULL) superClassID = a_classID;
  else {
    sts = om$get_classid(classname = a_className,
			 p_classid = &superClassID);
    if (!(sts & 1)) goto wrapup;
  }
  
  // Test It
  sts = om$is_ancestry_valid(subclassid   = subClassID,
			     superclassid = superClassID);
  if (sts != OM_S_SUCCESS) goto wrapup;
  
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* ------------------------------------------------------------------------
 * Change the name with the option of preserving it's directory
 */
IGRstat VDobjChgName
(
 IGRlong    *a_msg,
 TGRobj_env *a_objOE,
 TGRid      *a_objID,
 IGRchar    *newName,
 IGRint      keepDir
 )
{
  IGRstat retFlag = 0;
  IGRlong sts,msg;
  
  TGRobj_env objOE;
  
  IGRchar pwdPath[DI_PATH_MAX];
  IGRchar objPath[DI_PATH_MAX];
  IGRchar *p;
    
  // Init
  *pwdPath = 0;
  *objPath = 0;
  if (a_msg == NULL) a_msg = &msg;
  
  // Arg Check
  if (newName == NULL) goto wrapup;
  
  // Get the object
  objOE.obj_id.objid = NULL_OBJID;
  
  if (a_objOE) objOE = *a_objOE;

  if (a_objID) {
    
    // Default mod env should be ok
    objOE.obj_id = *a_objID;
    gr$get_module_env(buffer = &objOE.mod_env);
    
  }
  if (objOE.obj_id.objid == NULL_OBJID) goto wrapup;
  
  // Switch to objects directory 
  if (keepDir) {

    om$send(msg	= message 
	    GRvg.GRgetname(a_msg, objPath),
	    senderid = NULL_OBJID,
	    targetid = objOE.obj_id.objid,
	    targetos = objOE.obj_id.osnum) ;
    
    //printf("Changing name to %s,%s\n",newName,objPath);

    if (*objPath) {

      // Drop the name
      p = strrchr(objPath,':');
      if (p) *p = 0;
      
      // Change to ti
      di$pwd(dirname = pwdPath);
      di$cd( dirname = objPath);
    }
    
  }
  
  // Name It
  sts = om$send(msg = message 
		GRgraphics.GRchgname(a_msg,
				     &objOE.mod_env,
                                     newName),
		senderid = NULL_OBJID,
		targetid = objOE.obj_id.objid,
		targetos = objOE.obj_id.osnum) ;


  // Back to original directory
  if (*pwdPath) di$cd(dirname = pwdPath);
  
  retFlag = sts;
  		
wrapup:
  return retFlag;
}

/* ----------------------------------------------------
 * Generic method for getting named foot with md_env
 * filled in properly
 */
IGRstat VDobjGetFoot(TGRobj_env *a_objOE, 
		     TGRid      *a_objID,
		     IGRchar    *footName,
		     TGRobj_env *footOE)
{
  IGRstat retFlag = 0;
  IGRstat sts,msg;
  
  TGRid objID;
  
  // Init
  if (footName == NULL) footName = ".";
  if (footOE   == NULL) goto wrapup;
  footOE->obj_id.objid = NULL_OBJID;
  
  // Source Object
  objID.objid = NULL_OBJID;
  
  if (a_objOE)  objID  =  a_objOE->obj_id;
  if (a_objID)  objID  = *a_objID;

  if (objID.objid == NULL_OBJID) goto wrapup;
  
  // Get the foot
  sts = om$send(	
    msg	= message NDmacro.ACreturn_foot(
      &msg, 
       footName,
      &footOE->obj_id,
      &footOE->mod_env.md_env.matrix_type,
       footOE->mod_env.md_env.matrix
    ),
    senderid= NULL_OBJID,
    targetid= objID.objid,
    targetos= objID.osnum 
  );
  if (!(sts & msg & 1)) goto wrapup;
  
  // Fill in rest of md_env
  footOE->mod_env.md_id.osnum = footOE->obj_id.osnum;
  ex$get_modid(
    mod_osnum =  footOE->mod_env.md_id.osnum,
    mod_id    = &footOE->mod_env.md_id.objid
  );
  retFlag = 1;
  
wrapup:
  return retFlag;
  
}

/* -----------------------------------------------------------------
 * Deletes one object
 */
IGRstar VDobjDeleteOne(TGRid *objID, TGRmd_env *objENV)
{
  IGRstat sts,msg;

  sts = om$send(msg = message GRgraphics.GRdelete(&msg,objENV),
		senderid = objID->objid,
		targetid = objID->objid,
		targetos = objID->osnum);

  if (sts & msg & 1) return 1;
  
  sts = om$send(msg = message Root.delete(0),
		senderid = objID->objid,
		targetid = objID->objid,
		targetos = objID->osnum) ;

  return 1;
}

/* -----------------------------------------------------------------
 * Generic routine for deleting one or more objects
 */
IGRstar VDobjDelete(TGRobj_env *objOEs, 
		    TGRid      *objIDs, 
		    OM_S_OBJID *objSIDs,
		    TGRmd_env  *objENV,
		    IGRint      objCNT,
		    TVDvlaID   *vlaID,
		    TVDvlaOE   *vlaOE)
{
  IGRstat    retFlag = 0;
  IGRint     i;
  TGRid      delID;
  TGRobj_env delOE;

  // VLA of oe's
  if (vlaOE) {
    for(i = 0; vdvla_oe$GetAt(vla = vlaOE, nth = i, objOE = &delOE); i++) {
      VDobjDeleteOne(&delOE.obj_id,&delOE.mod_env);
    }
  }
  
  // VLA of id's
  if ((vlaID) && (objENV)) {
    for(i = 0; vdvla_id$GetAt(vla = vlaID, nth = i, objID = &delID); i++) {
      VDobjDeleteOne(&delID,objENV);
    }
  }

  // List of oes
  if (objOEs) {
    for(i = 0; i < objCNT; i++) {
      VDobjDeleteOne(&objOEs[i].obj_id,&objOEs[i].mod_env);
    }
  }
  
  // List of ids
  if ((objIDs) && (objENV)) {
    for(i = 0; i < objCNT; i++) {
      VDobjDeleteOne(&objIDs[i],objENV);
    }
  }

  // List of OM_S_OBJIDs
  if ((objSIDs) && (objENV)) {

    delID.osnum = objENV->md_id.osnum;
    
    for(i = 0; i < objCNT; i++) {
      delID.objid = objSIDs[i];      
      VDobjDeleteOne(&delID,objENV);
    }
  }
  
  // Done
  retFlag = 1;
  return retFlag;
}

end implementation ACncpx;



