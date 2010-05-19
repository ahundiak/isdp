/* $Id: VDCsupGeni.I,v 1.1.1.1 2001/01/04 21:09:23 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdsup/cmd/VDCsupGemi.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDCsupGeni.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:09:23  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.4  1997/11/25  15:18:58  pinnacle
# VDmaster
#
# Revision 1.3  1997/10/29  15:20:46  pinnacle
# Added Headers
#
 *
 * History:
 *      MM/DD/YY  AUTHOR  DESCRIPTION
 *      10/29/97  ah      added header
 *      07/11/97  EJM     CR#179701494  Support curve enhancements
 *                        Added code to handle SWAPUP, SWAPDN and
 *                        CLONE buttons.
 *	11/30/97  ah      Deleted extern NULL_GRID
 ***************************************************************************/

/* ---------------------------------------------------------------------------

  Methods

        VDCsupSwapTrace
        VDCsupDelTrace
	VDCsupSetTraces
	VDCsupSetExpForm
	VDCsupSetSupport
	VDCsupSetObject
	VDCsupIsBaseSurfDefined
	VDCsupSetLocateFlag
	VDCsupEraseHilite1
	init
	delete
	VDCsupSaveFormLoc

  Functions

	VDCsupGetObjName
	VDCsupListTraces
	VDsupTestExp
	VDsupDumpExp
	VDCsupSetFormExp
	VDCsupSetFormObj
	VDCsupSetFBI
	VDCsupGetFBI
	VDsupDispObj
	
-------------------------------------------------------------------------- */

class implementation VDCsupGen;

#include "VDmaster.h"
#include "VDmsg.h"

#include "VDsupMac.h"

#include "VDCsupForm.h"

#define EPS 0.000001

from 	GRvg 		import 	GRcenter,GRgetname;
from 	NDnode 		import 	ASreturn_go,NDget_objects,NDgive_structure;
from 	GRgraphics 	import 	GRaltconstruct,GRdisplay;
from 	NDnode     	import 	NDchg_state;
from 	ACrg_collect	import	AClist_attribute;
from    expression      import  give_formula,give_syntax,DIget_edit_string;

from    VDsupGen        import  VDsupGetTempList,VDsupGetType;

extern GRclassid OPP_expression_class_id;

extern void COB_FI_form_notification(), COB_FI_initial_form_notification();

static  TGRid NULL_GRIDZ;

/* Some static global values */
static struct {
  TGRid baseSurfId;
  IGRint xpos,ypos;
} g_VDCsupInfo;

IGRlong VDCsupGetObjName(TGRid *objId, IGRchar *objName)
{
  TGRid   goId;
  IGRstat sts,l_msg;
  IGRchar full_name[DI_PATH_MAX];
  IGRchar *p;

  /* Seem if original object has a name */
  *full_name = 0;

  om$send(msg = message GRvg.GRgetname(&l_msg,full_name),
    senderid = NULL_OBJID,
    targetid = objId->objid,
    targetos = objId->osnum);

  if (*full_name) {
    p = strrchr(full_name,':');
    if (p) strcpy(objName,p+1);
    else   strcpy(objName,full_name);

    return MSSUCC;
  }

  /* If it is a source, ask graphic for name first
   * Do this to prevent the source object from generating a
   * fake name when the underlying graphic has it's own name
   * only support macros will have named foot objects
   */
  goId = NULL_GRID;
  sts = om$send(
    msg = message NDnode.ASreturn_go(
      &goId,NULL,NULL
    ),
    senderid = NULL_OBJID,
    targetid = objId->objid,
    targetos = objId->osnum
  );
  if ((sts & 1) && (goId.objid != NULL_OBJID)) {

    *full_name = 0;

    om$send(msg = message GRvg.GRgetname(&l_msg,full_name),
      senderid = NULL_OBJID,
      targetid = goId.objid,
      targetos = goId.osnum);

    if (*full_name) {
      p = strrchr(full_name,':');
      if (p) strcpy(objName,p+1);
      else   strcpy(objName,full_name);

      return MSSUCC;
    }
  }

  /* Ask original objects, accept source translations */
  *objName = NULL;
  vd$get_name(obj = objId, name = objName);

  return MSSUCC;
}

method VDCsupSwapTrace(int *msg; int gadget_label)
{
  IGRint  rowNum,pos,i,length,sel_flag,r_pos, num_rows;
  IGRchar text1[DI_PATH_MAX], text2[DI_PATH_MAX];
  IGRstat sts;

  TGRid   temptl_1, temptl_2;

  *msg = MSSUCC;

  /* If no row is selected, bottom row is considered active row */
  sts = FIfld_get_active_row( me->form_ptr,VDSUP_FRM_L_TRACE,&rowNum,&pos );
  if (sts != FI_SUCCESS)  return MSSUCC;

  FIg_set_text(me->form_ptr,VDSUP_FRM_F_STATUS," ");

  /* Handle field text */

  FIfld_get_text_length( me->form_ptr,VDSUP_FRM_L_TRACE,rowNum,0,&length );
  FIfld_get_text( me->form_ptr,VDSUP_FRM_L_TRACE,rowNum,0,length+1,text1,&sel_flag,&r_pos );

  if( gadget_label == VDSUP_FRM_B_SWAPDN ){
    FIfld_get_num_rows( me->form_ptr,VDSUP_FRM_L_TRACE,&num_rows );
    if( rowNum == num_rows-1 ) {
      FIg_set_text(me->form_ptr,VDSUP_FRM_F_STATUS,"Can't swap last row down");
      return MSSUCC;
    }
    FIfld_get_text_length( me->form_ptr,VDSUP_FRM_L_TRACE,rowNum+1,0,&length );
    FIfld_get_text( me->form_ptr,VDSUP_FRM_L_TRACE,rowNum+1,0,length+1,text2,&sel_flag,&r_pos );
    FIfld_set_text( me->form_ptr,VDSUP_FRM_L_TRACE,rowNum,0,text2,FALSE );
    FIfld_set_text( me->form_ptr,VDSUP_FRM_L_TRACE,rowNum+1,0,text1,FALSE );
  }
  else {
    if( rowNum == 0 ) {
      FIg_set_text(me->form_ptr,VDSUP_FRM_F_STATUS,"Can't swap first row up");
      return MSSUCC;
    }
    FIfld_get_text_length( me->form_ptr,VDSUP_FRM_L_TRACE,rowNum-1,0,&length );
    FIfld_get_text( me->form_ptr,VDSUP_FRM_L_TRACE,rowNum-1,0,length+1,text2,&sel_flag,&r_pos );
    FIfld_set_text( me->form_ptr,VDSUP_FRM_L_TRACE,rowNum,0,text2,FALSE );
    FIfld_set_text( me->form_ptr,VDSUP_FRM_L_TRACE,rowNum-1,0,text1,FALSE );
  }

  /* Handle template list entry */

  i = VDSUP_I_TRACE_BEG + (rowNum*2);
  temptl_1    = me->tl[i  ];
  temptl_2    = me->tl[i+1];

  if( gadget_label == VDSUP_FRM_B_SWAPDN )
  {
    me->tl[i  ] = me->tl[i+2];
    me->tl[i+1] = me->tl[i+3];
    me->tl[i+2] = temptl_1;
    me->tl[i+3] = temptl_2;
  }
  else
  {
    me->tl[i  ] = me->tl[i-2];
    me->tl[i+1] = me->tl[i-1];
    me->tl[i-2] = temptl_1;
    me->tl[i-1] = temptl_2;
  }

  return MSSUCC;
}

method VDCsupDelTrace(int *msg)
{
  IGRint rowNum,pos,i;
  IGRstat sts;

  *msg = MSSUCC;

  sts = FIfld_get_active_row(me->form_ptr,VDSUP_FRM_L_TRACE,&rowNum,&pos);
  if (sts != FI_SUCCESS) return MSSUCC;

  FIfld_delete_rows(me->form_ptr,VDSUP_FRM_L_TRACE,rowNum,1);

  for(i = VDSUP_I_TRACE_BEG + (rowNum*2); i < (VDSUP_I_TRACE_END - 2); i += 2) {
    me->tl[i  ] = me->tl[i+2];
    me->tl[i+1] = me->tl[i+3];
  }
  me->tl[i]   = NULL_GRIDZ;
  me->tl[i+1] = NULL_GRIDZ;

  return MSSUCC;
}

IGRstat VDCsupListTraces(IGRchar *form_ptr, TGRid *tl)
{
  IGRint  rowNum;
  IGRint  num_rows;
  IGRint  i;
  IGRchar name[DI_PATH_MAX];
  IGRchar desc[DI_PATH_MAX];
  TGRid   srcId;

  /* Refresh list gadget */
  rowNum = 0;
  FIfld_set_num_rows(form_ptr,VDSUP_FRM_L_TRACE,rowNum);

  for(i = VDSUP_I_TRACE_BEG;
     (i < VDSUP_I_TRACE_END) && (tl[i].objid);
      i += 2) {

    srcId = tl[i];
 
    *name = 0;
    VDCsupGetObjName(&srcId,name);
    if (*name == 0) strcpy(name,"Defined");

    sprintf(
      desc,"%d,%d %s",
      srcId.osnum,
      srcId.objid,
      name
    );
/*
    FIfld_set_text(form_ptr,VDSUP_FRM_L_TRACE,rowNum,0,desc,FALSE);
*/
    FIfld_set_text(form_ptr,VDSUP_FRM_L_TRACE,rowNum,0,name,FALSE);

    /* Make sure last trace curve added is visible */
    FIfld_get_num_vis_rows( form_ptr, VDSUP_FRM_L_TRACE, &num_rows );
    FIfld_set_active_row(form_ptr,VDSUP_FRM_L_TRACE,rowNum,num_rows - 1 );

    rowNum++;
    }
  FIfld_pos_cursor(form_ptr,VDSUP_FRM_L_TRACE,rowNum,0,0,0,0,0);

  return 1;
}

method VDCsupSetTraces(int *msg)
{
  TGRobj_env  *locObj;
  IGRint       locNum,locNew,locI,limI;

  TGRid        srcId;
  IGRstat      l_msg;

  /* Grab Located Objects */
  as$start_fence(
    set       = &me->event1.located_object[0].located_obj,
    set_env   = &me->event1.located_object[0].module_info,
    nb_obj    = &locNum,
    p_obj_env = &locObj,
    response  = me->response,
    response_data = me->response_data
  );

  if (locNum == 0) {
    me->ret = *msg = MSFAIL;
    ex$message(msgnumb = VD_E_supNoLocObj);
    goto quit;
  }

  /* Toss out dups */
  locNew = locNum;
  
  for(locI = 0; locI < locNum; locI++) {

    as$make_source( go_grid =  locObj[locI].obj_id,
                    mod_env = &locObj[locI].mod_env,
                    as_os   =  me->ModuleInfo.md_id.osnum ,
                    as_grid = &srcId);

    for (limI = VDSUP_I_TRACE_BEG; 
        (limI < VDSUP_I_TRACE_END) && (me->tl[limI].objid); 
         limI += 2) {
      if (
          (me->tl[limI].objid == srcId.objid) &&
          (me->tl[limI].osnum == srcId.osnum)
      ) {
        locObj[locI].obj_id.objid = NULL_OBJID;
        locNew--;
      }
    }
  }
  if (locNew == 0) {
    me->ret = *msg = MSFAIL;
    ex$message(msgnumb = VD_E_supNoLocObj);
    goto quit;
  }

  for(limI = VDSUP_I_TRACE_BEG; 
     (limI < VDSUP_I_TRACE_END) && (me->tl[limI].objid); 
      limI += 2);
  
  /* Xfer New Objects */
  for(locI = 0; locI < locNum; locI++) {

    if (locObj[locI].obj_id.objid != NULL_OBJID) {

      as$make_source( go_grid =  locObj[locI].obj_id,
                      mod_env = &locObj[locI].mod_env,
                      as_os   =  me->ModuleInfo.md_id.osnum ,
                      as_grid = &srcId);

      if (limI < VDSUP_I_TRACE_END) {
        me->tl[limI] = srcId;
        limI += 2;
      }
    }
  }

  /* Refresh list gadget */
  VDCsupListTraces(me->form_ptr,me->tl);

  me->ret = *msg = MSSUCC;

quit:
  ASend_fence();
  dp$erase_hilite(
    msg = &l_msg,
    objid = me->ModuleInfo.md_id.objid,
    osnum = me->ModuleInfo.md_id.osnum
  );

  return MSSUCC;
}

/* -------------------------------------------------------
 * Verifies the id is a double expression
 */
IGRstat VDsupTestExp(TGRid *id, IGRdouble *value, IGRchar *status)
{
  Tret_struct rs;
  IGRstat sts,l_msg;

  /* Make sure got expression */
  if (!(vd_$is_ancestry_valid(object=id,classid=OPP_expression_class_id))) {
    strcpy(status,"Not an Expression Object ");
    return MSFAIL;
  }

  /* Check value */
  sts = om$send(
    msg = message NDnode.NDgive_structure(&l_msg,&rs,NULL),
    senderid = NULL_OBJID,
    targetid = id->objid,
    targetos = id->osnum
  );

  if (!(sts&l_msg&1)) {
    strcpy(status,"Error returning from NDnode.NDgive_structure");
    return MSFAIL;
  }

  if (rs.type != double_type) {
    strcpy(status,"Expression is not a double");
    return MSFAIL;
  }

  *value = rs.var.root_pm_st.value;

  if (fabs(*value) > 1E+50) {
    strcpy(status,"Double value out of range");
    return MSFAIL;
  }

  return MSSUCC;
}

/* -------------------------------------------------------
 * Dump Expression out
 */
IGRstat VDsupDumpExp(TGRid *id)
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
  
  return MSSUCC;
}

/* -----------------------------------------------------
 * MET VDCsupSetExpForm
 * Handles offset/trim expression from form
 * Always returns success
 */
method VDCsupSetExpForm(int *msg; int label)
{
  IGRchar     str[EXP_MAX_LEN];

  TGRid       expId;

  IGRdouble   value;
  TGRmd_env  *md_env = &me->ModuleInfo;
  IGRstat     sts;

  TGRid       *insId;
  VDCsupFBI   fbi;

  *msg = MSSUCC;

  /* Get the item involved */
  if (!VDCsupGetFBI(me->fbiList,label,0,&fbi)) {
    return MSSUCC;
  }
  insId = &me->tl[fbi.ind];

  /* Get the string from form, null string clears object */
  *str = NULL;
  FIg_get_text(me->form_ptr,label,str);
  if (*str == NULL) {
    *insId =  NULL_GRIDZ;
    FIg_set_text(me->form_ptr,VDSUP_FRM_F_STATUS,"Expression Cleared");
    return MSSUCC;
  }

  /* Reject = for now */
  if (strchr(str,'=')) {
    FIg_set_text(me->form_ptr,VDSUP_FRM_F_STATUS,"'=' Not Allowed In Expression");
    return MSSUCC;
  }

  /* See if it is just the name of an existing expression */
  sts = vds$translate(
    objname =  str, 
    p_objid = &expId.objid, 
    p_osnum = &expId.osnum
  );

  if (!(sts & 1)) {

    /* Create new expression */
    expId.osnum = md_env->md_id.osnum;
    sts = exp$create(
      exp_syntax =  str,
      p_exp_id   = &expId.objid,
      osnum      =  expId.osnum,
      type_rq    = EXP_DOUBLE
    );
    if (!(sts & 1)) {
      FIg_set_text(me->form_ptr,VDSUP_FRM_F_STATUS,"Bad Expression");
      return MSSUCC;
    }
  }

  /* Test The Expression */
  sts = VDsupTestExp(&expId,&value,str);
  if (!(sts & 1)) {
    FIg_set_text(me->form_ptr,VDSUP_FRM_F_STATUS,str);
    return MSSUCC;
  }

  /* Accept it */
  as$make_source( 
    go_grid =  expId,
    as_os   =  me->ModuleInfo.md_id.osnum ,
    as_grid =  insId
  );
/*
  VDsupDumpExp(insId);
*/
  sprintf(str,"Exp: %.2f",value);

  FIg_set_text(me->form_ptr,VDSUP_FRM_F_STATUS,str);

  return MSSUCC;
}

IGRstat VDCsupSetFormExp(IGRchar *form, IGRlong gadget, TGRid *id)
{
  IGRchar str[DI_PATH_MAX],*p;

  if ((id->objid == NULL) || (id->objid == NULL_OBJID)) {
    FIg_set_text(form,gadget,"");
    return 0;
  }

  *str = NULL;
  om$send(
    msg = message expression.DIget_edit_string(str),
    senderid = NULL_OBJID,
    targetid = id->objid,
    targetos = id->osnum
  );

  p = strchr(str,'=');
  if (p) strcpy(str,p+1);

  FIg_set_text(form,gadget,str);
  return 1;
}

IGRstat VDCsupSetFormObj(IGRchar *form, IGRlong gadget, TGRid *id)
{
  IGRchar name[DI_PATH_MAX];

  if ((id->objid == NULL) || (id->objid == NULL_OBJID)) {
    FIg_set_text(form,gadget,"");
    return 0;
  }

  *name = 0;
  VDCsupGetObjName(id,name);
  if (*name == 0) strcpy(name,"Defined");

  FIg_set_text(form,gadget,name);

  return 1;
}

/* -----------------------------------------------------
 * Pulls data from existing support curve
 */
method VDCsupSetSupport (int *msg)
{
  IGRstat sts;
  IGRlong selType = 0;
  IGRlong macType = 0;
  IGRint  i;
  VDCsupFBI fbi;

  TGRid supId = me->event1.located_object[0].located_obj;

  if ((supId.objid == NULL) || (supId.objid == NULL_OBJID)) return 0;

  /* Check the type */
  sts = om$send(
    msg = message VDsupGen.VDsupGetType(&selType),
    senderid = NULL_OBJID,
    targetid = supId.objid,
    targetos = supId.osnum
  );

  switch(me->mytype) {
    case VDSUP_CMD_CRV_MD: macType = VDSUP_MAC_TYPE_CRV; break;
    case VDSUP_CMD_OFF_MD: macType = VDSUP_MAC_TYPE_OFF; break;
    case VDSUP_CMD_EQU_MD: macType = VDSUP_MAC_TYPE_EQU; break;
  }
  if (selType != macType) {
    FIg_set_text(me->form_ptr,VDSUP_FRM_F_STATUS, 
      "Wrong Type of Support Curve");
   *msg = 0;
    return 0;
  }

  /* Get list of templates */
  memset(me->tl,0,VDSUP_I_MAX * sizeof(TGRid));
  sts = om$send(
    msg = message VDsupGen.VDsupGetTempList(me->tl,VDSUP_I_MAX,NULL),
    senderid = NULL_OBJID,
    targetid = supId.objid,
    targetos = supId.osnum
  );
  /* Note: By not checking for error here, allow modifying macros
   * in which one parent has been deleted.
   */
  me->supId = supId;

  for(i = 0; me->fbiList[i].fld; i++) {
    fbi = me->fbiList[i];
    if (fbi.exp) VDCsupSetFormExp(me->form_ptr,fbi.fld,&me->tl[fbi.ind]);
    else         VDCsupSetFormObj(me->form_ptr,fbi.fld,&me->tl[fbi.ind]);
  }

  VDCsupSetFormObj(me->form_ptr,VDSUP_FRM_F_NAME,&supId);

  VDCsupListTraces(me->form_ptr,me->tl);

  *msg = OM_S_SUCCESS;
  return OM_S_SUCCESS;
}

/* -----------------------------------------------------
 * Hooks object to form
 * Always returns success
 */
method VDCsupSetObject (int *msg; int gadget)
{
  IGRchar   objName[DI_PATH_MAX];
  TGRid     objId,asId;

  IGRlong   l_msg;
  VDCsupFBI fbi;

  objId = me->event1.located_object[0].located_obj;

  /* Source It */
  as$make_source( go_grid = objId,
                  mod_env = &me->event1.located_object[0].module_info,
                  as_os   =  me->ModuleInfo.md_id.osnum ,
                  as_grid = &asId);
  
  _VD_SEND_MY(VDS_LOCATE.erase_hilite(&l_msg));

  /* find the object name */
  VDCsupGetObjName(&asId, objName);
  if (*objName == 0) {
    strcpy(objName,"Defined");
  }
  FIg_set_text(me->form_ptr,gadget,objName);

  /* Store id away */
  if (!VDCsupGetFBI(me->fbiList,gadget,0,&fbi)) goto wrapup;

  me->tl[fbi.ind] = asId;

  if (fbi.ind == VDSUP_I_SURF) {
    g_VDCsupInfo.baseSurfId = asId;
  }

wrapup:
  ASend_fence();
  *msg = OM_S_SUCCESS;
  return OM_S_SUCCESS;
}

/* ---------------------------------------------------
 * MET VDCsupIsBaseSurfDefined
 * If hull surface has been previously picked
 * transfer id and update the form
 */
method VDCsupIsBaseSurfDefined(int *msg)
{
  char  objName[DI_PATH_MAX];

  /* See if have a base surface already */
  if ((g_VDCsupInfo.baseSurfId.objid == 0) ||
      (g_VDCsupInfo.baseSurfId.objid == NULL_OBJID)) {
    *msg = VDSUP_NO;
    return OM_S_SUCCESS;
  }
  me->tl[VDSUP_I_SURF] = g_VDCsupInfo.baseSurfId;

  VDCsupGetObjName(&me->tl[VDSUP_I_SURF],objName);
  if (*objName == 0) {
    strcpy(objName,"Defined");
  }

  FIfld_set_text        (me->form_ptr,VDSUP_FRM_F_BASE_SURF,0,0,objName,FALSE);
  FIfld_set_default_text(me->form_ptr,VDSUP_FRM_F_BASE_SURF,0,0,objName,0,0);
  
  *msg = VDSUP_YES;

  return OM_S_SUCCESS;
}

/* ---------------------------------------------------
 * ^VDCsupEraseHilite1
 * Cleans ups some highliting
 */
method VDCsupSetLocateFlag(int *msg; int flag)
{
  me->locateFlag = flag;
  FIg_set_text(me->form_ptr,VDSUP_FRM_F_STATUS,"");
  *msg = OM_S_SUCCESS;
  return OM_S_SUCCESS;
}

method VDCsupEraseHilite1(int *msg)
{
  IGRlong loc_msg;

  _VD_SEND_MY(VDS_LOCATE.erase_hilite(&loc_msg));

  *msg = OM_S_SUCCESS;
  return OM_S_SUCCESS;
}

IGRstat VDCsupSetFBI(
  VDCsupFBI *fbi, 
  IGRlong fld, IGRlong but, IGRlong ind, IGRlong exp
)
{
  fbi->fld = fld;
  fbi->but = but;
  fbi->ind = ind;
  fbi->exp = exp;

  return 1;
}

IGRstat VDCsupGetFBI(VDCsupFBI *fbiList, IGRlong fld, IGRlong but, VDCsupFBI *fbi)
{
  int i;

  for(i = 0; fbiList[i].fld; i++) {

    if (fld == fbiList[i].fld) {
      *fbi  =  fbiList[i];
      return 1;
    }

    if (but == fbiList[i].but) {
      *fbi  =  fbiList[i];
      return 1;
    }
  }

  *fbi = fbiList[i];
  return 0;
}

/* ------------------------------------------------------
 * MET init
 */
method init ( int type ; char * str_ptr )
{
  IGRint  status;
  IGRchar formName [32];
  IGRchar formTitle[40];
  IGRchar occName [DI_PATH_MAX];

  /* Init Parent */
  status  = om$send( 
    msg = message CEO_LOCATE.init( type, str_ptr ),
    targetid = my_id,
    mode = OM_e_wrt_message
  );
  as$status (sts = status);

  /* Init field button index data */
  VDCsupSetFBI(&me->fbiList[ 0], VDSUP_FRM_F_BASE_SURF, VDSUP_FRM_B_BASE_SURF, VDSUP_I_SURF,   0);
  VDCsupSetFBI(&me->fbiList[ 1], VDSUP_FRM_F_BASE_OBJ1, VDSUP_FRM_B_BASE_OBJ1, VDSUP_I_REF1,   0);
  VDCsupSetFBI(&me->fbiList[ 2], VDSUP_FRM_F_BASE_OBJ2, VDSUP_FRM_B_BASE_OBJ2, VDSUP_I_REF2,   0);
  VDCsupSetFBI(&me->fbiList[ 3], VDSUP_FRM_F_DIR,       VDSUP_FRM_B_DIR,       VDSUP_I_PT_DIR, 0);
  VDCsupSetFBI(&me->fbiList[ 4], VDSUP_FRM_F_SEL,       VDSUP_FRM_B_SEL,       VDSUP_I_PT_SEL, 0);
  VDCsupSetFBI(&me->fbiList[ 5], VDSUP_FRM_F_TRIM1,     VDSUP_FRM_B_TRIM1,     VDSUP_I_TRIM1,  0);
  VDCsupSetFBI(&me->fbiList[ 6], VDSUP_FRM_F_TRIM2,     VDSUP_FRM_B_TRIM2,     VDSUP_I_TRIM2,  0);
  VDCsupSetFBI(&me->fbiList[ 7], VDSUP_FRM_F_CUT1,      VDSUP_FRM_B_CUT1,      VDSUP_I_CUT1,   1);
  VDCsupSetFBI(&me->fbiList[ 8], VDSUP_FRM_F_CUT2,      VDSUP_FRM_B_CUT2,      VDSUP_I_CUT2,   1);
  VDCsupSetFBI(&me->fbiList[ 9], VDSUP_FRM_F_DIS1,      VDSUP_FRM_B_DIS1,      VDSUP_I_DIS1,   1);
  VDCsupSetFBI(&me->fbiList[10], VDSUP_FRM_F_DIS2,      VDSUP_FRM_B_DIS2,      VDSUP_I_DIS2,   1);
  VDCsupSetFBI(&me->fbiList[11], VDSUP_FRM_F_CNT,       VDSUP_FRM_B_CNT,       VDSUP_I_CNT,    1);
  VDCsupSetFBI(&me->fbiList[12], 0,0,0,0);

  switch(me->mytype) {

    case VDSUP_CMD_CRV_PL: {
      strcpy(formName, "VDsupCrv.frm"); 
      strcpy(formTitle,"Place Support Curve"); 
      break;
    }
    case VDSUP_CMD_OFF_PL: {
      strcpy(formName, "VDsupOff.frm"); 
      strcpy(formTitle,"Place Support Offset Curve"); 
      break;
    }
    case VDSUP_CMD_EQU_PL: {
      strcpy(formName, "VDsupEqu.frm"); 
      strcpy(formTitle,"Place Support Equidistance Curve"); 
      break;
    }

    case VDSUP_CMD_CRV_MD: {
      strcpy(formName, "VDsupCrv.frm"); 
      strcpy(formTitle,"Modify Support Curve"); 
      break;
    }
    case VDSUP_CMD_OFF_MD: {
      strcpy(formName, "VDsupOff.frm"); 
      strcpy(formTitle,"Modify Support Offset Curve"); 
      break;
    }
    case VDSUP_CMD_EQU_MD: {
      strcpy(formName, "VDsupEqu.frm"); 
      strcpy(formTitle,"Modify Support Equidistance Curve"); 
      break;
    }
  }


  /* Get Form Started */
  status = FIf_new(1,formName,
    COB_FI_form_notification,
    &me->form_ptr
  );

  if ( status ) {
    me->form_ptr = NULL;
    me->state = _terminate;
    return ( OM_I_STOP_SENDING );
  } 
	
  /*** tell the form which cmd it's talking to ***/
  status = FIf_set_cmd_oid_os (  
    me->form_ptr, 
    my_id, 
    OM_Gw_current_OS 
  );

  if ( status ) {
    me->state = _terminate;
    return ( OM_I_STOP_SENDING );
  }
     	  
  /* Form Location */
  if((g_VDCsupInfo.xpos != 0) || (g_VDCsupInfo.ypos != 0)) {
     FIf_set_location( me->form_ptr, g_VDCsupInfo.xpos, g_VDCsupInfo.ypos );
  }

  status = FIf_set_initial_notification_routine ( 
    me->form_ptr,
    COB_FI_initial_form_notification 
  );

  if ( status ) {
    me->state = _terminate;
    return ( OM_I_STOP_SENDING );
  }
       
  FIg_set_text(me->form_ptr,VDSUP_FRM_T_TITLE,formTitle);

  switch(me->mytype){
    case VDSUP_CMD_CRV_PL:
    case VDSUP_CMD_OFF_PL:
    case VDSUP_CMD_EQU_PL:
    FIg_erase(me->form_ptr, VDSUP_FRM_B_CLONE);
  }

  strcpy(occName,"CLINTON");
  VDsupGetNextOccName(NULL, occName);
  FIg_set_text(me->form_ptr, VDSUP_FRM_F_NAME, occName);

  FIf_display( me->form_ptr );

  me->locateFlag = 1;

  return OM_S_SUCCESS;

}

/* -----------------------------------------------
 * MET delete Called when command exits
 */
method delete ( int f_defer_flag )
{
  IGRstat sts;

  sts = om$send( 
    msg = message VDCsupGen.VDCsupSaveFormLoc(),
    targetid = my_id,
  );

  if (me->form_ptr) FIf_delete(me->form_ptr);
/*
  _FREE(me->tl);
*/
  sts = om$send( 
    msg = message CEO_LOCATE.delete ( 0 ),
    targetid = my_id,
    mode   = OM_e_wrt_message
  );

  return OM_S_SUCCESS;
}

/* -------------------------------------------------------
 * Displays a single object with some matrix nonsense
 * Copied from VLdispObj
 * Changed the GRdpmode from a pointer to data value
 */

void VDsupDispObj( obj,module,mode,code)
struct GRid 	*obj;
struct GRmd_env *module;
enum GRdpmode    mode;
int		 code;
{
  int	loc_msg;
  int	dim;
  IGRlong	msg,status;
  IGRshort	mat_type,mm_type;
  IGRdouble	mat[16], *mm;
  struct GRid   buff;

  if (obj->objid == NULL_OBJID) return;
  if (obj->objid == 0) return ;

  if (code) {
    status = dp$erase_hilite(msg=&loc_msg,
                             objid = module->md_id.objid,
                             osnum = module->md_id.osnum);
  }
/*
  vd_$bulk_display(dpmode = mode, count = 1, grids = obj, theEnv = module);
  if (1) return;
*/
  buff = *obj;
  status = om$send(  msg = message NDnode.ASreturn_go
				(&buff,&mat_type,mat),
                        targetid = obj->objid,
		        targetos = obj->osnum,
			senderid = NULL_OBJID);

/* This always seems to fail, not sure why, original code
 * had no check
  if (!(status & msg & 1)) return;
 */
/*
  if (!(status & msg & 1)) printf("ASreturn_go failed\n");
  else                     printf("ASreturn_go passed\n");
*/

  if (mat_type != MAIDMX ) {
    if (module->md_env.matrix_type != MAIDMX ) {
      dim = 4;
      MAmulmx(&loc_msg,&dim,&dim,&dim,module->md_env.matrix, mat,mat);
      MAtypemx( &loc_msg, mat, &mat_type);
      mm = mat;
      mm_type = mat_type;
    }
    else {
      mm = mat;
      mm_type = mat_type;
    }
  }
  else {
    mm = module->md_env.matrix;
    mm_type = module->md_env.matrix_type;
  }
   status =
        om$send(msg = message GRgraphics.GRdisplay(
                             &msg,
                             &mm_type,
                             mm,
                             &mode,
                             &module->md_id ),
               targetid = buff.objid,
               targetos = buff.osnum,
               senderid = NULL_OBJID);

          if (!(status & msg & 1)) {
            ex$message( msgnumb = VD_E_supDispObj );
	  }
}

method VDCsupSaveFormLoc()
{
  int x_form, y_form;

  FIf_get_location( me->form_ptr, &x_form, &y_form );

  g_VDCsupInfo.xpos = x_form;
  g_VDCsupInfo.ypos = y_form;

  return MSSUCC;

}

end implementation VDCsupGen;
