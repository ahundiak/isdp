/* $Id: VDbro.I,v 1.1.1.1 2001/01/04 21:07:57 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdbro/imp/VDbro.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDbro.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:57  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.3  1997/11/28  21:28:18  pinnacle
# AssyTree
#
# Revision 1.2  1997/11/25  01:24:18  pinnacle
# AssyTree
#
# Revision 1.1  1997/10/29  17:13:56  pinnacle
# ah Creation
#
 *
 * History:
 *      MM/DD/YY  AUTHOR  DESCRIPTION
 *      10/29/97  ah      added header
 *      11/25/97  ah      Support for VDatBase object
 ***************************************************************************/

class implementation Root;

#include "VDmaster.h"

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
 * Geneeates 1 line description
 */
IGRstat VDbroGetObjDesc(VDbroObjInfo *info, IGRchar *desc)
{
  IGRchar work[1024];

  sprintf(desc,"OBJ %d,%d",info->id.osnum,info->id.objid);

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
IGRstat VDbroGetObjInfo(TGRid *id, VDbroObjInfo *info)
{
  IGRstat sts;

  TGRid    macId;
  IGRchar *macName;

  /* Reset Info */
  memset(info,0,sizeof(VDbroObjInfo));
  info->id = *id;

  /* Class Id */
  sts = om$get_classid(
    osnum = id->osnum,
    objid = id->objid,
    p_classid = &info->classId
  );
  if (!(sts & 1)) {
    strcpy(info->className,"BAD Class");
    return 0;
  }

  /* Classname */
  sts = om$get_classname(
    classid   = info->classId,
    classname = info->className
  );
  if (!strcmp(info->className,"OMOSCO")) return 0;

  /* Get Macro Name */
  sts = om$is_ancestry_valid(
      subclassid = info->classId,
    superclassid = OPP_ACcpx_class_id);

  if (sts == OM_S_SUCCESS) {

    sts = om$send(
      msg = message ACcpx.find_macro(&macId),
      senderid = NULL_OBJID,
      targetid = id->objid,
      targetos = id->osnum);

    if (!(sts & 1)) {
      strcpy(info->macName,"BAD find_macro");
      goto continue1;
    }

    sts = om$send(
      msg = message ACcpx_defn.ACgive_name(&macName),
      senderid = NULL_OBJID,
      targetid = macId.objid,
      targetos = macId.osnum);

    if (!(sts & 1)) {
      strcpy(info->macName,"BAD ACgive_name");
      goto continue1;
    }

    strcpy(info->macName,macName);
  }
continue1:

  /* Get Downscan Name */
  sts = om$is_ancestry_valid(
      subclassid = info->classId,
    superclassid = OPP_ACpretend_class_id);

  if (sts == OM_S_SUCCESS) {

    sts = om$send(
      msg = message ACpretend.ACgive_downscan(info->downScan),
      senderid = NULL_OBJID,
      targetid = id->objid,
      targetos = id->osnum);

    if (!(sts & 1)) {
      strcpy(info->downScan,"BAD downScan");
    }
  }

  /* Get Tree Name Name */
  sts = om$is_ancestry_valid(
    subclassid     = info->classId,
    superclassname = "VDatBase"
  );

  if (sts == OM_S_SUCCESS) {

    sts = VDatGetBaseName(id,info->downScan);

    if (!(sts & 1)) {
      strcpy(info->downScan,"BAD VDatBase.getName");
    }
  }

#ifdef PRINT_ATTR
  /* Get any attributes */
{
  struct  ACrg_coll collList[1024];
  IGRint  collCount,collInd;
  IGRlong collMsg;
  struct  ACrg_coll *coll;

  sts = om$is_ancestry_valid(
      subclassid = info->classId,
    superclassid = OPP_ACrg_collect_class_id);

  if ((sts == OM_S_SUCCESS) && 0x00) {

    printf("ACrg_collect %d,%d\n",id->objid,id->osnum);

    sts = om$send(
      msg = message ACrg_collect.AClist_attribute(
       &collMsg,
        sizeof(collList),
        collList,
       &collCount
      ),
      senderid = NULL_OBJID,
      targetid = id->objid,
      targetos = id->osnum);

    if (!(sts & collMsg & 1)) {
      printf("Bad ACrg_collect\n");
    }
    else {
      for(collInd = 0; collInd < collCount; collInd++) {

        coll = &collList[collInd];

        printf("%4d %-20s = ",collInd,coll->name);

        switch(coll->desc.type) {
          case AC_ATTRIB_TEXT: 
            printf("'%s' ",coll->desc.value.att_txt); 
          break;

          case AC_ATTRIB_DOUBLE: 
            printf("%8.2f ",coll->desc.value.att_exp); 
          break;

          default:
            printf("UNKNOWN ATTR TYPE ");
        }
        printf("\n"); 
      }
    }
  }
}
#endif

  /* Get any name */
  sts = di$untranslate(
    objname = info->objName,
    objid = id->objid,
    osnum = id->osnum);

  /* Get Any Expression */
  sts = om$is_ancestry_valid(
      subclassid = info->classId,
    superclassid = OPP_expression_class_id);

  if (sts == OM_S_SUCCESS) {

    sts = om$send(
      msg = message expression.DIgive_output(info->expStr),
      senderid = NULL_OBJID,
      targetid = id->objid,
      targetos = id->osnum);

    if (!(sts & 1)) {
      strcpy(info->expStr,"BAD DIgive_output");
    }
  }
  info->sts = 1;
  return 1;
}

IGRstat VDbroGetObjStr(TGRid *id, IGRchar *desc)
{
  IGRstat sts;
  VDbroObjInfo info;

  *desc = 0;
  sts = VDbroGetObjInfo(id,&info);
  VDbroGetObjDesc(&info,desc);

  return sts;
}

IGRstat VDbroPrintObj(TGRid *id)
{
  IGRstat sts;
  VDbroObjInfo info;
  IGRchar desc[1024];

  *desc = 0;
  sts = VDbroGetObjInfo(id,&info);
  VDbroGetObjDesc(&info,desc);
  printf("%s\n",desc);

  return sts;
}

end implementation Root;
