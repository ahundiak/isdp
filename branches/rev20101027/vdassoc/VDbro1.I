/* $Id: VDbro1.I,v 1.1.1.1 2001/01/04 21:07:41 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdassoc/VDbro1.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDbro1.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:41  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1998/03/06  16:08:30  pinnacle
# Browser
#
# Revision 1.2  1998/02/25  23:12:40  pinnacle
# ah
#
# Revision 1.1  1998/02/24  22:29:30  pinnacle
# ah
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 10/29/97  ah      added header
 * 11/25/97  ah      Support for VDatBase object
 * 03/06/98  ah      Move to vdassoc to assist in debugging
 ***************************************************************************/

class implementation Root;

#include "VDmaster.h"
#include "VDbro1.h"

extern GRclassid OPP_expression_class_id;
extern GRclassid OPP_ACcpx_class_id;
extern GRclassid OPP_ACpretend_class_id;
extern GRclassid OPP_ACrg_collect_class_id;

from ACcpx        import find_macro;
from ACcpx_defn   import ACgive_name;
from ACpretend    import ACgive_downscan;
from expression   import DIgive_output;
from ACrg_collect import AClist_attribute;

/* --------------------------------------------
 * Generates 1 line description
 */
IGRstat VDbroGetObjDesc1(TVDbroObjInfo *info, IGRchar *desc)
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
 * Everything about an object
 */
IGRstat VDbroGetObjInfo1(
  TGRobj_env    *a_objOE,
  TGRid         *a_objID, 
  TGRmd_env     *a_objENV,
  TVDbroObjInfo *info)
{
  IGRstat retFlag = 0;
  IGRstat sts;

  TGRid    objID;
  IGRchar *macName;

  /* Reset Info */
  memset(info,0,sizeof(TVDbroObjInfo));
  info->objOE.obj_id.objid = NULL_OBJID;
  info->objOE.mod_env.md_id.objid = NULL_OBJID;
  info->macID.objid = NULL_OBJID;

  /* Xfer args */
  if (a_objOE)  info->objOE         = *a_objOE;
  if (a_objID)  info->objOE.obj_id  = *a_objID;
  if (a_objENV) info->objOE.mod_env = *a_objENV;

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

  /* Make it assembly tree aware */
  sts = om$is_ancestry_valid(
    subclassid     = info->classID,
    superclassname = "VDatBase"
  );

  if (sts == OM_S_SUCCESS) {
#if 0
    sts = VDatGetBaseName(&objID,info->downScan);

    if (!(sts & 1)) {
      strcpy(info->downScan,"BAD VDatBase.getName");
    }
#endif
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

IGRstat VDbroPrintObject(
  TGRobj_env    *a_objOE,
  TGRid         *a_objID,
  TGRmd_env     *a_objENV,

  IGRboolean     a_trace,
  IGRboolean     a_cr,

  IGRchar       *a_buf,
  FILE          *a_file,
  TVDbroObjInfo *a_info
)
{
  IGRstat sts = 0;
  IGRchar buf[1024];
  TVDbroObjInfo info;

  // Ignore completely of trace is off
  if (a_trace == FALSE) goto wrapup;
  
  // Not sure about error checking, just return the code
  sts = VDbroGetObjInfo1(a_objOE,a_objID,a_objENV,&info);

  // Copy the info
  if (a_info) *a_info = info;

  // Sprintf if desired
  if ((a_buf == NULL) && (a_file == NULL)) goto wrapup;

  // Get the desc
  VDbroGetObjDesc1(&info,buf);

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

IGRstat VDbroPrintObj1(TGRid *a_objID)
{
  return VDbroPrintObject(NULL,a_objID,NULL,TRUE,TRUE,NULL,stdout,NULL);
}


end implementation Root;






