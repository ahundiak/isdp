/* $Id: VDahExp.I,v 1.3 2001/01/11 16:34:31 art Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdah/VDahExp.I
 *
 * Description: Expression Processing
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDahExp.I,v $
 *      Revision 1.3  2001/01/11 16:34:31  art
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
# Revision 1.1  1997/12/17  18:45:28  pinnacle
# VDsupEtc
#
 *
 * History:
 *      MM/DD/YY  AUTHOR  DESCRIPTION
 *      12/17/97  ah      creation
 *
 ***************************************************************************/
class implementation expression;

#include "VDmaster.h"

extern GRclassid OPP_expression_class_id;

IGRstat VDahMakeExpObject(IGRchar *str, TGRid *expID,     IGRchar *status);
IGRstat VDahTestExpObject(TGRid *expID, IGRdouble *value, IGRchar *status);
IGRstat VDahDumpExpObject(TGRid *exp);

IGRstat VDahGetExpStr (TGRid *expID, IGRchar *str);
IGRstat VDahSetExpForm(TGRid *expID, Form form, IGRint gadget);

/* -----------------------------------------------------
 * Given a string, creates expression object
 * Intended to be used by a command object
 */
IGRstat VDahMakeExpObject(IGRchar *str, TGRid *objID, IGRchar *status)
{
  IGRstat retFlag = 0;
  IGRstat sts;

  TGRid   expID;
  TGRid   srcID;
  TGRid   curID;

  IGRdouble value;

  // Init
  *status = 0;
  objID->objid = NULL_OBJID;
  ex$get_cur_mod(id = &curID.objid, osnum = &curID.osnum);

  // Null string returns null object
  if (*str == NULL) {
    strcpy(status,"Empty Expression");
    retFlag = 1;
    goto wrapup;
  }

  /* Reject = for now */
  if (strchr(str,'=')) {
    strcpy(status,"Expressions with '=' not allowed");
    goto wrapup;
  }

  /* See if it is just the name of an existing expression */
  sts = vds$translate(
    objname =  str, 
    p_objid = &expID.objid, 
    p_osnum = &expID.osnum
  );
  if (!(sts & 1)) {

    /* Create new expression */
    expID.osnum = curID.osnum;
    sts = exp$create(
      exp_syntax =  str,
      p_exp_id   = &expID.objid,
      osnum      =  expID.osnum,
      type_rq    = EXP_DOUBLE
    );
    if (!(sts & 1)) {
      strcpy(status,"Expression Creation Failed");
      goto wrapup;
    }
  }

  /* Test The Expression */
  sts = VDahTestExpObject(&expID,&value,status);
  if (!(sts & 1)) goto wrapup;

  /* Accept it */
  srcID.objid = NULL_OBJID;
  as$make_source( 
    go_grid =  expID,
    as_os   =  curID.osnum,
    as_grid = &srcID
  );
  if (srcID.objid == NULL_OBJID) {
    strcpy(status,"Expression Sourceing Failed");
    goto wrapup;
  }

  *objID = srcID;
  sprintf(status,"Expression: %.2f",value);
  retFlag = 1;

wrapup:
  return retFlag;
}

/* -------------------------------------------------------
 * Verifies the id is a double expression
 * Intended to be used by a command object
 */
IGRstat VDahTestExpObject(TGRid *id, IGRdouble *value, IGRchar *status)
{
  IGRstat retFlag = 0;
  IGRstat sts,suc;

  Tret_struct rs;

  /* Make sure got expression */
  if (!(vd_$is_ancestry_valid(object=id,classid=OPP_expression_class_id))) {
    strcpy(status,"Not an Expression Object ");
    goto wrapup;
  }

  /* Check value */
  sts = om$send(
    msg = message NDnode.NDgive_structure(&suc,&rs,NULL),
    senderid = NULL_OBJID,
    targetid = id->objid,
    targetos = id->osnum
  );
  if (!(sts&suc&1)) {
    strcpy(status,"Error getting value from expression");
    goto wrapup;
  }

  if (rs.type != double_type) {
    strcpy(status,"Expression is not a double");
    goto wrapup;;
  }

  *value = rs.var.root_pm_st.value;

  if (fabs(*value) > 1E+50) {
    strcpy(status,"Double value out of range");
    goto wrapup;
  }
  retFlag = 1;

wrapup:
  return retFlag;
}

/* -------------------------------------------------------
 * Dump Expression out, for debugging
 */
IGRstat VDahDumpExpObject(TGRid *id)
{
  IGRchar str[EXP_MAX_LEN];
  
  printf("-------------------\n");
  printf("Exp Object: %d,%d\n",id->osnum,id->objid);

  *str = NULL;
  om$send(
    msg = message expression.give_formula(str),
    senderid = NULL_OBJID,
    targetid = id->objid,
    targetos = id->osnum
  );
  printf("Formula: '%s'\n",str);

  *str = NULL;
  om$send(
    msg = message expression.DIget_edit_string(str),
    senderid = NULL_OBJID,
    targetid = id->objid,
    targetos = id->osnum
  );
  printf("Edt Str: '%s'\n",str);

  *str = NULL;
  om$send(
    msg = message expression.give_syntax(str),
    senderid = NULL_OBJID,
    targetid = id->objid,
    targetos = id->osnum
  );
  printf("Syntax : '%s'\n",str);
  printf("\n");
  
  return 1;
}

/* -----------------------------------------
 * Returns expression from object
 * Intended to be used by a command object
 * The returned string can be displayed on a form
 */
IGRstat VDahGetExpStr(TGRid *expID, IGRchar *str)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  IGRchar *p;

  // Init
  if (str == NULL) goto wrapup;
  *str = 0;

  // Arg check
  if ((expID == NULL) ||
      (expID->objid == NULL) || 
      (expID->objid == NULL_OBJID)) goto wrapup;

  // Get the string
  sts = om$send(
    msg = message expression.DIget_edit_string(str),
    senderid = NULL_OBJID,
    targetid = expID->objid,
    targetos = expID->osnum
  );
  if (!(sts & 1)) goto wrapup;

  // Show to right or =
  p = strchr(str,'=');
  if (p) strcpy(str,p+1);

  retFlag = 1;

wrapup:
  return retFlag;
}

/* -----------------------------------------
 * Pulls expression from object and displays
 * on the form
 */
IGRstat VDahSetExpForm(TGRid *expID, Form form, IGRint gadget)
{
  IGRstat retFlag = 0;

  IGRchar str[DI_PATH_MAX];

  VDahGetExpStr(expID,str);
  FIg_set_text(form,gadget,str);

  retFlag = 1;
  return retFlag;
}

end implementation expression;

