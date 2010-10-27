/* $Id: VDexp.I,v 1.4 2001/08/02 15:31:14 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdah/VDexp.I
 *
 * Description:	Expression Processing
 *
 * Dependencies:
 *
 * Revision History:
 * $Log: VDexp.I,v $
 * Revision 1.4  2001/08/02 15:31:14  ahundiak
 * ah
 *
 * Revision 1.3  2001/01/11 16:34:31  art
 * sp merge
 *
 * Revision 1.1  2001/01/11 16:20:58  art
 * s merge
 *
# Revision 1.1  2000/12/06  14:53:10  pinnacle
# ah
#
# Revision 1.2  2000/07/08  14:53:42  pinnacle
# ah
#
# Revision 1.1  2000/04/28  19:11:36  pinnacle
# ah
#
# Revision 1.2  2000/03/09  21:39:00  pinnacle
# ah
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1998/04/23  23:11:06  pinnacle
# ah
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 04/23/98  ah      Creation
 * 04/26/00  ah      Problem with getting double expressions
 * 07/08/00  ah      Problem with expression.S
 * 08/01/01  ah      Added VDexpCreateDoubleExp
 ***************************************************************************/
class implementation expression;

#include "VDtypedef.h"

#include "VDobj.h"
#include "VDexp.h"
#include "VDos.h"
#include "VDdir.h"

// Get a warning with this, undeclared class name without it
from text_exp import create;

extern VDclassid OPP_expression_class_id;

/* ------------------------------------------------------------------------
 * Modify an existing text expression
 */
IGRstat VDexpModifyTextExp(TGRid   *expID, 
			   IGRchar *expText)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  IGRshort rc;
  
  IGRchar expName[256];
  
  // Arg check
  if ((expID == NULL) || (expID->objid == NULL_OBJID)) goto wrapup;
  if (expText == NULL) goto wrapup;
  
  // Need the name
  vdobj$Get(objID = expID, objName = expName);
  if (*expName == 0) goto wrapup;
  
  // Doit
  sts = om$send(msg = message text_exp.modify(expName, expText, &rc),
		senderid = NULL_OBJID,
		targetid = expID->objid,
		targetos = expID->osnum);
  if (!(sts & rc & 1)) {
    goto wrapup;
  }
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}


/* ------------------------------------------------------------------------
 * Create a text expression
 *
 */
IGRstat VDexpCreateTextExp(VDosnum osnum, IGRchar *name, IGRchar *text, TGRid *expID)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  IGRshort rc;
  
  // Arg check
  if (expID == NULL) goto wrapup;
  if (osnum == OM_K_NOT_AN_OS) ex$get_cur_mod(osnum = &osnum);
  expID->osnum = osnum;
  expID->objid = NULL_OBJID;
  if (text == NULL) goto wrapup;
  if (name == NULL) goto wrapup;
  
  // Create it
  sts = om$construct(classid = OPP_text_exp_class_id,
		     osnum   =  expID->osnum,
		     p_objid = &expID->objid);

  if (expID->objid == NULL_OBJID) goto wrapup;
  if (!(sts & 1)) goto wrapup;
  
  // Set it
  sts = om$send(msg = message text_exp.create(name, text, &rc),
		senderid = NULL_OBJID,
		targetid = expID->objid,
		targetos = expID->osnum);
  if (!(sts & rc & 1)) {
    sts = om$send(msg = message Root.delete(0),
		  senderid = NULL_OBJID,
		  targetid = expID->objid,
		  targetos = expID->osnum) ;
    goto wrapup;
  }
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}
/* ------------------------------------------------------------------------
 * Create a double expression
 * Note: Never been tested.  Let the user beware.
 *
 */
IGRstat VDexpCreateDoubleExp(VDosnum osnum, IGRchar *name, IGRdouble dbl, TGRid *expID)
{
  IGRstat  retFlag = 0;
  IGRstat  sts;
  IGRshort rc;
  
  // Arg check
  if (expID == NULL) goto wrapup;
  if (osnum == OM_K_NOT_AN_OS) ex$get_cur_mod(osnum = &osnum);
  expID->osnum = osnum;
  expID->objid = NULL_OBJID;
  
  // Create it
  sts = om$construct(classid = OPP_expression_class_id,
		     osnum   =  expID->osnum,
		     p_objid = &expID->objid);

  if (expID->objid == NULL_OBJID) goto wrapup;
  if (!(sts & 1)) goto wrapup;
  
  // Set it
  sts = om$send(msg = message expression.NDset_value(name,dbl,NULL,&rc),
		senderid = NULL_OBJID,
		targetid = expID->objid,
		targetos = expID->osnum);
  if (!(sts & rc & 1)) {
    sts = om$send(msg = message Root.delete(0),
		  senderid = NULL_OBJID,
		  targetid = expID->objid,
		  targetos = expID->osnum) ;
    goto wrapup;
  }
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* ------------------------------------------------------------------------
 * Get routine
 */
IGRstat VDexpGet
(TGRobj_env *a_objOE,
 TGRid      *a_objID,
    
 IGRchar    *a_txt,
 IGRdouble  *a_dbl,
 IGRint     *a_jnt

 )
{
  IGRstat retFlag = 0;
  
  TGRid     objID;
  VDclassid classID;
  
  IGRchar   buf[1024],*p;
  IGRdouble dbl;
  
  // Init
  if (a_txt) *a_txt = 0;
  if (a_dbl) *a_dbl = 0.0;
  if (a_jnt) *a_jnt = 0;
    
  // Arg Check
  objID.objid = NULL_OBJID;
  
  if (a_objOE) objID  =  a_objOE->obj_id;
  if (a_objID) objID  = *a_objID;

  if (objID.objid == NULL_OBJID) goto wrapup;
  
  // Syntax is the key for text expressions
  if (a_txt) {  
    *buf = 0;

    /* ----------------------------------------------
     * expression.S objects (sometimes found as macro templates)
     * are different then text_exp objects
     * Wish they had defined a give_text method
     */
    vdobj$Get(objID = &objID, classID = &classID);
    if (classID == OPP_expression_class_id) {
      om$send(msg = message expression.DIget_edit_string(buf),
	      senderid = NULL_OBJID,
	      targetid = objID.objid,
	      targetos = objID.osnum);
      p = strchr(buf,'=');
      if (p) strcpy(buf,p+1);
    }
    else {  
      om$send(msg = message expression.give_syntax(buf),
	      senderid = NULL_OBJID,
	      targetid = objID.objid,
	      targetos = objID.osnum);
    }
    
    strcpy(a_txt,buf);
    retFlag = 1;
  }
  
  // Use value for doubles and ints
  if ((a_dbl) || (a_jnt)) {
    om$send(msg = message expression.NDgive_value(&dbl),
	    senderid = NULL_OBJID,
	    targetid = objID.objid,
	    targetos = objID.osnum);

    if (a_dbl) *a_dbl = dbl;
    if (a_jnt) *a_jnt = dbl;

    retFlag = 1;
  }
  
wrapup:

  return retFlag;
}

end implementation expression;
