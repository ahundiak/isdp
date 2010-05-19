/* $Id: VDcol1.I,v 1.1.1.1 2001/01/04 21:07:58 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdct/imp/VDcol1.I
 *
 * Description: Basic Collector Object
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDcol1.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:58  cvs
 *      Initial import to CVS
 *
# Revision 1.2  1999/05/30  14:24:46  pinnacle
# ct
#
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

class implementation VDcol;

#include "VDcol.h"

static int traceFlag;

/* ------------------------------------------------
 * Get an attribute
 *
 */
IGRstar VDcolGetAttr(TGRobj_env *objOE,
		     TGRid      *objID,
		     TVDobjid    objid,
		     TVDosnum    osnum,
		     IGRint      vla_type,
		     IGRint      i_nth,
		     IGRchar    *name,
		     IGRint     *o_nth,
		     TVDfld     *fld,
		     TVDfld     **fldp
)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  
  // Init
  if(o_nth) *o_nth = -1;
  if(fld)  memset(fld,0,sizeof(TVDfld));
  if(fldp) *fldp = NULL;
 
  // Get the target object
  if (objOE){
    objid = objOE->obj_id.objid;
    osnum = objOE->obj_id.osnum;
  }
  if (objID){
    objid = objID->objid;
    osnum = objID->osnum;
  }

  if (objid == NULL_OBJID) goto wrapup;
  if (objid == 0)          goto wrapup;

  // Get it
  sts = om$send(msg = message
		VDcol.vdcolGetAttr(vla_type, name,i_nth, o_nth, fld, fldp),
		senderid = NULL_OBJID,
		targetid = objid,
		targetos = osnum);
  if (!(sts & 1)) goto wrapup;
  
  retFlag = 1;
  
 wrapup:
  return retFlag;
}


/* ------------------------------------------------
 * Get a list of the attributes of an Object
 *
 */
IGRstar VDcolGetAttrs(TGRobj_env *objOE,
		      TGRid      *objID,
		      TVDobjid    objid,
		      TVDosnum    osnum,
		      IGRint      vla_type,
		      IGRint      cntMax,
		      IGRint     *cnt,
		      TVDfld     *fld,
		      TVDfld     **fldp
)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  
  // Say Hi
  traceFlag = VDdbgGetTraceFlag(40);
  if(traceFlag) {
    printf(">>>> VDcolGetAttrs\n");
  }
  
  // Init
  if (cnt)  *cnt = -1;
  if (fld)  memset(fld,0,sizeof(TVDfld));
  if (fldp) *fldp = NULL;

  // Get the target object
  if (objOE){
    objid = objOE->obj_id.objid;
    osnum = objOE->obj_id.osnum;
  }
  if (objID){
    objid = objID->objid;
    osnum = objID->osnum;
  }

  if (objid == NULL_OBJID) goto wrapup;
  if (objid == 0)          goto wrapup;
  
  // Get it
  sts = om$send(msg = message
		VDcol.vdcolGetAttrs(vla_type, cntMax, cnt, fld, fldp),
		senderid = NULL_OBJID,
		targetid = objid,
		targetos = osnum);
  if (!(sts & 1)) goto wrapup;
  
  retFlag = 1;
  
 wrapup:

  if(traceFlag) {
    printf("<<<< VDcolSetAttrs\n");
  }

  return retFlag;
}


/* ------------------------------------------------
 * Set a list of attributes for object
 *
 */
IGRstar VDcolSetAttrs(TGRobj_env *objOE,
		      TGRid      *objID,
		      TVDobjid    objid,
		      TVDosnum    osnum,
		      IGRint      vla_type,
		      TVDfld     *a_fld,
		      IGRint      a_cnt,
		      TVDflds    *a_flds
		     )
{
  IGRstat retFlag = 0;
  IGRstat sts;

  TVDfld *fld = NULL;
  IGRint  cnt = -1;
  
  // Say Hi
  traceFlag = VDdbgGetTraceFlag(40);
  if(traceFlag) {
    printf(">>>> VDcolSetAttrs\n");
  }
  
  if (a_flds) {
    cnt = a_flds->cnt;
    fld = a_flds->fld;
  }
  if (a_fld) {
    cnt = a_cnt;
    fld = a_fld;
  }

  // Get the target object
  if (objOE){
    objid = objOE->obj_id.objid;
    osnum = objOE->obj_id.osnum;
  }
  if (objID){
    objid = objID->objid;
    osnum = objID->osnum;
  }

  if (objid == NULL_OBJID) goto wrapup;
  if (objid == 0)          goto wrapup;

  // Passing through fld == NULL will reset list of attributes
  sts = om$send(msg = message
		VDcol.vdcolSetAttrs(vla_type, cnt, fld),
		senderid = NULL_OBJID,
		targetid = objid,
		targetos = osnum);
  
  if (!(sts & 1)) goto wrapup;
  
  retFlag = 1;
  
 wrapup:

  if(traceFlag) {
    printf("<<<< VDcolSetAttrs\n");
  }
  return retFlag;
}

/* ------------------------------------------------
 * Update a list of attributes for object
 *
 */
IGRstar VDcolUpdAttrs(TGRobj_env *objOE,
		      TGRid      *objID,
		      TVDobjid    objid,
		      TVDosnum    osnum,
		      IGRint      vla_type,
		      TVDfld     *a_fld,
		      IGRint      a_cnt,
		      TVDflds    *a_flds
)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  
  TVDfld *fld = NULL;
  IGRint  cnt = -1;
  
  // Arg eheck
  if (a_flds) {
    cnt = a_flds->cnt;
    fld = a_flds->fld;
  }
  if (a_fld) {
    cnt = a_cnt;
    fld = a_fld;
  }

  // Get the target object
  if (objOE){
    objid = objOE->obj_id.objid;
    osnum = objOE->obj_id.osnum;
  }
  if (objID){
    objid = objID->objid;
    osnum = objID->osnum;
  }

  if (objid == NULL_OBJID) goto wrapup;
  if (objid == 0)          goto wrapup;
  
  if (fld == NULL) goto wrapup;
  if (cnt <= 0)    goto wrapup;
  
  // Update it
  sts = om$send(msg = message
		VDcol.vdcolUpdAttrs(vla_type, cnt, fld),
		senderid = NULL_OBJID,
		targetid = objid,
		targetos = osnum);
  
  if (!(sts & 1)) goto wrapup;
  
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* ------------------------------------------------
 * Delete all attributes for object
 *
 */

IGRstar VDcolDelAttrs(TGRobj_env *objOE,
		      TGRid      *objID,
		      TVDobjid    objid,
		      TVDosnum    osnum,
		      IGRint      vla_type,
		      TVDfld      *a_fld,
		      IGRint       a_cnt,
		      TVDflds     *a_flds
)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  
  TVDfld *fld = NULL;
  IGRint  cnt = -1;

  // Arg Check
  if (a_flds) {
    cnt = a_flds->cnt;
    fld = a_flds->fld;
  }
  if (a_fld) {
    cnt = a_cnt;
    fld = a_fld;
  }

  // Get the target object
  if (objOE){
    objid = objOE->obj_id.objid;
    osnum = objOE->obj_id.osnum;
  }
  if (objID){
    objid = objID->objid;
    osnum = objID->osnum;
  }

  if (objid == NULL_OBJID) goto wrapup;
  if (objid == 0)          goto wrapup;

  if (fld == NULL) goto wrapup;
  if (cnt <= 0)    goto wrapup;
  
  // Delete  all attributes
  sts = om$send(msg = message
		VDcol.vdcolDelAttrs(vla_type, cnt, fld),
		senderid = NULL_OBJID,
		targetid = objid,
		targetos = osnum);
  
  if (!(sts & 1)) goto wrapup;
  
  retFlag = 1;
  
 wrapup:
  return retFlag;
}	

/* -------------------------------------------------------
 * Test Routine
 */
IGRstat VDcolTest()
{
  IGRstat retFlag = 0;
  IGRstat sts;
  
  TGRid   objID;
  
  IGRint  ind_ret;
  TVDfld  col;
  
  // Create one
  ex$get_cur_mod(osnum = &objID.osnum);
  objID.objid = NULL_OBJID;
  
  // Create object
  sts = om$construct(classname = "VDcol",
                     osnum     =  objID.osnum,
                     p_objid   = &objID.objid);
  if (!(sts & 1)) {
    printf("*** Problem creating VDcol test object\n");
    goto wrapup;
  }
  if (objID.objid == NULL_OBJID) {
    printf("*** Construct had good status but objid is NULL\n");
    goto wrapup;
  }
  // vdobj$Print(objID = &objID);
  
  strcpy(col.name, "Testprop");
  col.type = VDFLD_TYPE_CHAR;
  strcpy(col.val.txt, "Test");
  
  vdcol$SetAttrs(objID = &objID, fld = &col, cnt = 1);
  
  vdcol$GetAttr(objID = &objID, 
		name  = "Testprop", 
		o_nth = &ind_ret, 
		fld   = &col);
  
  // And delete it
  sts = om$send(msg = message Root.delete(0),
                senderid = NULL_OBJID,
                targetid = objID.objid,
                targetos = objID.osnum);
  if (!(sts & 1)) {
    printf("*** Problem deleting object\n");
    goto wrapup;
  }
  
  retFlag = 1;
wrapup:
  return retFlag;
}

end implementation VDcol;












