class implementation VDCzupGen;

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


/* ****************************************
method VDCsupDelTrace(int *msg)
{
  IGRint rowNum,pos,i;
  IGRstat sts;

  *msg = MSSUCC;

  sts = FIfld_get_active_row(me->form_ptr,VDSUP_FRM_L_OBJECTS,&rowNum,&pos);
  if (sts != FI_SUCCESS) return MSSUCC;

  FIfld_delete_rows(me->form_ptr,VDSUP_FRM_L_OBJECTS,rowNum,1);

  for(i = VDSUP_I_TRACE_BEG + (rowNum*2); i < (VDSUP_I_TRACE_END - 2); i += 2) {
    me->tl[i  ] = me->tl[i+2];
    me->tl[i+1] = me->tl[i+3];
  }
  me->tl[i]   = NULL_GRIDZ;
  me->tl[i+1] = NULL_GRIDZ;

  return MSSUCC;
}
***************************** */



method VDCsupSetTrace(int *msg; int command)
{

  printf("\n	VDCsupSetTrace:  command = %d\n", command);

  *msg = MSSUCC;
  return MSSUCC;
}


/* ****************************************
method VDCsupSetTraces(int *msg)
{
  TGRobj_env  *locObj;
  IGRint       locNum,locNew,locI,limI;

  TGRid        srcId;
  IGRstat      l_msg;

  /* Grab Located Objects * 
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

  /* Toss out dups * 
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
  
  /* Xfer New Objects * 
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

  /* Refresh list gadget * 
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
***************************************** */


/* -----------------------------------------------------
 * MET VDCsupSetExpForm
 * Handles offset/trim expression from form
 * Always returns success
 */
method VDCsupSetExpForm(int *msg; int rowNum; int index)
{
  IGRchar    str[EXP_MAX_LEN];

  TGRid       expId;

  IGRdouble   value;
  TGRmd_env  *md_env = &me->ModuleInfo;
  IGRstat     sts;

  TGRid       *insId;

  int sel_flag;
  int r_pos;

/*  VDCsupROW   row; */

SetProc( VDCsupSetExpForm ); Begin


  *msg = MSSUCC;

printf("\n	VDCsupSetExpForm:  rowNum = %d,  index = %d\n", rowNum, index);

  /* Get the item (row number) involved *  
  if (!VDCsupGetROW(me->rowList,item,&row)) {
    return MSSUCC;
  }
*/
  insId = &me->tl[index];

  /* Get the string from form, null string clears object */
  *str = NULL;
  FIfld_get_text(me->form_ptr,VDSUP_FRM_L_OBJECTS,rowNum,VDSUP_EXPR_COL,EXP_MAX_LEN,str,&sel_flag,&r_pos);

  printf("\n    VDCsupSetExpForm: column 2 string = %s\n", str);

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

  End

  return MSSUCC;

}



/* -----------------------------------------------------
 * Pulls data from existing support curve
 */
method VDCsupSetSupport (int *msg)
{
  IGRstat sts;
  IGRlong selType = 0;
  IGRlong macType = 0;
  int rowNum;
  VDCsupROW row;

/*  IGRint  i;
  VDCsupROW row;
*/


  TGRid supId = me->event1.located_object[0].located_obj;

SetProc( VDCsupSetSupport ); Begin

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
  me->supId = supId;

  rowNum=0;
  for(;;)
  {
    if (!VDCsupGetROW(me->rowList,rowNum,&row)) break;
    {
       printf("\n             row.item = %d\n\
            row.exp = %d\n\
            row.idx = %d\n\
            row.typ = %d\n\
            row.col = %d\n", row.item, row.exp, row.idx, row.typ, row.col);
       VDCsupSetFormObj(me->form_ptr,VDSUP_FRM_L_OBJECTS,&me->tl[row.idx],rowNum);
    }
    rowNum++;
  }

/*
  for(i = 0; me->rowList[i].fld; i++) {
    row = me->rowList[i];
    if (row.exp) VDCsupSetFormExp(me->form_ptr,row.fld,&me->tl[row.ind]);
    else         VDCsupSetFormObj(me->form_ptr,row.fld,&me->tl[row.ind]);
  }
*/

  VDCsupSetFormObj(me->form_ptr,VDSUP_FRM_F_NAME,&supId,0);

/*  VDCsupListTraces(me->form_ptr,me->tl); */

  End

  *msg = OM_S_SUCCESS;

  return OM_S_SUCCESS;
}

/* -----------------------------------------------------
 * Hooks object to form
 * Always returns success
 */
method VDCsupSetObject (int *msg)
{
  IGRchar   objName[DI_PATH_MAX];
  TGRid     objId,asId;

  IGRlong   l_msg, sts;
  int       rowNum, pos;

  VDCsupROW row;



SetProc( VDCsupSetObject ); Begin

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


  /* Store object names in column 2, object ids in invisible column 4 */

  sts = FIfld_get_active_row(me->form_ptr,VDSUP_FRM_L_OBJECTS,&rowNum,&pos);
  if( sts != FI_SUCCESS ) return MSSUCC;

  FIfld_set_text(me->form_ptr,VDSUP_FRM_L_OBJECTS,rowNum,VDSUP_NAME_COL,objName,FALSE);
/*  FIfld_set_text(me->form_ptr,VDSUP_FRM_L_OBJECTS,rowNum,1,asId,FALSE); */
  FIg_set_text( me->form_ptr, VDSUP_FRM_F_INFO, "" );

  /* Store id away */
  if (!VDCsupGetROW(me->rowList,rowNum,&row)) goto wrapup;

  me->tl[row.idx] = asId;

printf("\n	VDCsupSetObject:  me->tl[%d].objid = %d,  objName=%s\n", row.idx, me->tl[row.idx].objid, objName);

wrapup:
  ASend_fence();
  *msg = OM_S_SUCCESS;

  End

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

  /* Store Base Surface Id in invisible column * 
  FIfld_set_text( me->form_ptr,VDSUP_FRM_L_OBJECTS,0,3,g_VDCsupInfo.baseSurfId,
                  FALSE);
  */

  VDCsupGetObjName(&me->tl[VDSUP_I_SURF],objName);
  if (*objName == 0) {
    strcpy(objName,"Defined");
  }

  FIfld_set_text        (me->form_ptr,VDSUP_FRM_L_OBJECTS,0,1,objName,FALSE);
  /* Default text automatically reinserted into the field if Restore Control */
  /* Bar is selected.                                                        */
  FIfld_set_default_text(me->form_ptr,VDSUP_FRM_L_OBJECTS,0,1,objName,0);
  
  *msg = VDSUP_YES;

  return OM_S_SUCCESS;
}


method VDCsupSetLocateFlag(int *msg; int flag)
{
  me->locateFlag = flag;
  FIg_set_text(me->form_ptr,VDSUP_FRM_F_STATUS,"");
  *msg = OM_S_SUCCESS;
  return OM_S_SUCCESS;
}

/* ---------------------------------------------------
 * ^VDCsupEraseHilite1
 * Cleans ups some highlighting
 */

method VDCsupEraseHilite1(int *msg)
{
  IGRlong loc_msg;

  _VD_SEND_MY(VDS_LOCATE.erase_hilite(&loc_msg));

  *msg = OM_S_SUCCESS;
  return OM_S_SUCCESS;
}

IGRstat VDCsupSetROW(
  VDCsupROW *row, 
  IGRlong item, IGRlong idx, IGRlong exp, IGRlong typ, IGRlong col
)
{
  row->item = item;
  row->idx = idx;
  row->exp = exp;
  row->typ = typ;
  row->col = col;

  return 1;
}

IGRstat VDCsupGetROW(VDCsupROW *rowList, IGRint item, VDCsupROW *row)
{
  int i;

  for(i = 0; rowList[i].item != -1; i++) 
  {
    if (item == rowList[i].item) 
    {
      *row  =  rowList[i];
      return 1;
    }
  }

  *row = rowList[i];
  return 0;
}


/* Set first column of multicolumn field with expected curve inputs and */
/*   indicate with "Y" if it is a required item for current curve type  */

void  VDsupSetItemMCField( IGRchar *form_ptr, int type )
{

  int i, row;
  char trace_string[16];
  char buff[3];

  printf("\n	Begin  VDsupSetItemMCField:\n");

  if (type == VDSUP_CMD_CRV_PL || type == VDSUP_CMD_CRV_MD)
  {
    FIfld_set_text( form_ptr, VDSUP_FRM_L_OBJECTS, 0, 0, "Base Surface",    0 );
    FIfld_set_text( form_ptr, VDSUP_FRM_L_OBJECTS, 1, 0, "Base Object",     0 );
    FIfld_set_text( form_ptr, VDSUP_FRM_L_OBJECTS, 2, 0, "Tracking  Point", 0 );
    FIfld_set_text( form_ptr, VDSUP_FRM_L_OBJECTS, 3, 0, "Trace Object 1",  0 );
    FIfld_set_text( form_ptr, VDSUP_FRM_L_OBJECTS, 4, 0, "Trace Object 2",  0 );
    FIfld_set_text( form_ptr, VDSUP_FRM_L_OBJECTS, 5, 0, "Cutback Value 1", 0 );
    FIfld_set_text( form_ptr, VDSUP_FRM_L_OBJECTS, 6, 0, "Cutback Value 2", 0 );

    FIfld_set_text( form_ptr, VDSUP_FRM_L_OBJECTS, 0, 3, "Y",0 );
    FIfld_set_text( form_ptr, VDSUP_FRM_L_OBJECTS, 1, 3, "Y",0 );

    row = 7;
    LISTTRACES(row);  /* macro from VDCzupForm.h */
  }
  else if (type == VDSUP_CMD_OFF_PL || type == VDSUP_CMD_OFF_MD)
  {
    FIfld_set_text( form_ptr, VDSUP_FRM_L_OBJECTS, 0, 0, "Base Surface",    0 );
    FIfld_set_text( form_ptr, VDSUP_FRM_L_OBJECTS, 1, 0, "Base Object",     0 );
    FIfld_set_text( form_ptr, VDSUP_FRM_L_OBJECTS, 2, 0, "Direction Point", 0 );
    FIfld_set_text( form_ptr, VDSUP_FRM_L_OBJECTS, 3, 0, "Tracking  Point", 0 );
    FIfld_set_text( form_ptr, VDSUP_FRM_L_OBJECTS, 4, 0, "Trace Object 1",  0 );
    FIfld_set_text( form_ptr, VDSUP_FRM_L_OBJECTS, 5, 0, "Trace Object 2",  0 );
    FIfld_set_text( form_ptr, VDSUP_FRM_L_OBJECTS, 6, 0, "Cutback Value 1", 0 );
    FIfld_set_text( form_ptr, VDSUP_FRM_L_OBJECTS, 7, 0, "Cutback Value 2", 0 );
    FIfld_set_text( form_ptr, VDSUP_FRM_L_OBJECTS, 8, 0, "Offset Dist 1",   0 );
    FIfld_set_text( form_ptr, VDSUP_FRM_L_OBJECTS, 9, 0, "Offset Dist 2",   0 );
    FIfld_set_text( form_ptr, VDSUP_FRM_L_OBJECTS, 10,0, "Num of Curves",   0 );

    FIfld_set_text( form_ptr, VDSUP_FRM_L_OBJECTS, 0, 3, "Y",0 );
    FIfld_set_text( form_ptr, VDSUP_FRM_L_OBJECTS, 1, 3, "Y",0 );
    FIfld_set_text( form_ptr, VDSUP_FRM_L_OBJECTS, 4, 3, "Y",0 );
    FIfld_set_text( form_ptr, VDSUP_FRM_L_OBJECTS, 5, 3, "Y",0 );
    FIfld_set_text( form_ptr, VDSUP_FRM_L_OBJECTS, 8, 3, "Y",0 );
    FIfld_set_text( form_ptr, VDSUP_FRM_L_OBJECTS,10, 3, "Y",0 );

    row = 11;
    LISTTRACES(row);
  }
  else
  {
    FIfld_set_text( form_ptr, VDSUP_FRM_L_OBJECTS, 0, 0, "Base Surface",    0 );
    FIfld_set_text( form_ptr, VDSUP_FRM_L_OBJECTS, 1, 0, "Base Object",     0 );
    FIfld_set_text( form_ptr, VDSUP_FRM_L_OBJECTS, 2, 0, "Base Object 2",   0 );
    FIfld_set_text( form_ptr, VDSUP_FRM_L_OBJECTS, 3, 0, "Direction Point", 0 );
    FIfld_set_text( form_ptr, VDSUP_FRM_L_OBJECTS, 4, 0, "Tracking  Point", 0 );
    FIfld_set_text( form_ptr, VDSUP_FRM_L_OBJECTS, 5, 0, "Trace Object 1",  0 );
    FIfld_set_text( form_ptr, VDSUP_FRM_L_OBJECTS, 6, 0, "Trace Object 2",  0 );
    FIfld_set_text( form_ptr, VDSUP_FRM_L_OBJECTS, 7, 0, "Cutback Value 1", 0 );
    FIfld_set_text( form_ptr, VDSUP_FRM_L_OBJECTS, 8, 0, "Cutback Value 2", 0 );
    FIfld_set_text( form_ptr, VDSUP_FRM_L_OBJECTS, 9, 0, "Num of Curves",   0 );

    FIfld_set_text( form_ptr, VDSUP_FRM_L_OBJECTS, 0, 3, "Y",0 );
    FIfld_set_text( form_ptr, VDSUP_FRM_L_OBJECTS, 1, 3, "Y",0 );
    FIfld_set_text( form_ptr, VDSUP_FRM_L_OBJECTS, 2, 3, "Y",0 );
    FIfld_set_text( form_ptr, VDSUP_FRM_L_OBJECTS, 5, 3, "Y",0 );
    FIfld_set_text( form_ptr, VDSUP_FRM_L_OBJECTS, 6, 3, "Y",0 );
    FIfld_set_text( form_ptr, VDSUP_FRM_L_OBJECTS, 9, 3, "Y",0 );

    row = 10;
    LISTTRACES(row);
  }
}

/* ------------------------------------------------------
 * MET init
 */
method init ( int type ; char * str_ptr )
{
  IGRint  status;
  IGRchar formName [32];
  IGRchar formTitle[40]; 
  IGRchar occName [32];

  IGRlong index;
  int n;


SetProc( method init ); Begin


  /* Init Parent */
  status  = om$send( 
    msg = message CEO_LOCATE.init( type, str_ptr ),
    targetid = my_id,
    mode = OM_e_wrt_message
  );
  as$status (sts = status);

  /* Init field row index data */

  if (type == VDSUP_CMD_CRV_PL || type == VDSUP_CMD_CRV_MD)
  {
    VDCsupSetROW(&me->rowList[ 0], 0, VDSUP_I_SURF, 0, VDSUP_OBJ_BASE_SURF, VDSUP_ITEM_COL);
    VDCsupSetROW(&me->rowList[ 1], 1, VDSUP_I_REF1, 0, VDSUP_OBJ_BASE_OBJ1, VDSUP_ITEM_COL);
    VDCsupSetROW(&me->rowList[ 2], 2, VDSUP_I_PT_SEL, 0, VDSUP_OBJ_SEL, VDSUP_ITEM_COL);
    VDCsupSetROW(&me->rowList[ 3], 3, VDSUP_I_TRIM1, 0, VDSUP_OBJ_TRACE1, VDSUP_ITEM_COL);
    VDCsupSetROW(&me->rowList[ 4], 4, VDSUP_I_TRIM2, 0, VDSUP_OBJ_TRACE2, VDSUP_ITEM_COL);
    VDCsupSetROW(&me->rowList[ 5], 5, VDSUP_I_CUT1, 0, VDSUP_OBJ_CUT1, VDSUP_EXPR_COL);
    VDCsupSetROW(&me->rowList[ 6], 6, VDSUP_I_CUT2, 0, VDSUP_OBJ_CUT2, VDSUP_EXPR_COL);

    n = 7;
    for( index = VDSUP_I_TRACE_BEG + 4; index < VDSUP_I_TRACE_END; index += 2)
    {
      VDCsupSetROW(&me->rowList[n], n, index, 0, VDSUP_OBJ_TRACE, VDSUP_ITEM_COL);
      n++;
    }
    printf("  n = %d\n", n );
    VDCsupSetROW(&me->rowList[n],-1,0,0,0,0);
  }

  if (type == VDSUP_CMD_OFF_PL || type == VDSUP_CMD_OFF_MD)
  {
    VDCsupSetROW(&me->rowList[ 0], 0, VDSUP_I_SURF, 0, VDSUP_OBJ_BASE_SURF, VDSUP_ITEM_COL);
    VDCsupSetROW(&me->rowList[ 1], 1, VDSUP_I_REF1, 0, VDSUP_OBJ_BASE_OBJ1, VDSUP_ITEM_COL);
    VDCsupSetROW(&me->rowList[ 2], 2, VDSUP_I_PT_DIR, 0, VDSUP_OBJ_DIR, VDSUP_ITEM_COL);
    VDCsupSetROW(&me->rowList[ 3], 3, VDSUP_I_PT_SEL, 0, VDSUP_OBJ_SEL, VDSUP_ITEM_COL);
    VDCsupSetROW(&me->rowList[ 4], 4, VDSUP_I_TRIM1, 0, VDSUP_OBJ_TRACE1, VDSUP_ITEM_COL);
    VDCsupSetROW(&me->rowList[ 5], 5, VDSUP_I_TRIM2, 0, VDSUP_OBJ_TRACE2, VDSUP_ITEM_COL);
    VDCsupSetROW(&me->rowList[ 6], 6, VDSUP_I_CUT1, 0, VDSUP_OBJ_CUT1, VDSUP_EXPR_COL);
    VDCsupSetROW(&me->rowList[ 7], 7, VDSUP_I_CUT2, 0, VDSUP_OBJ_CUT2, VDSUP_EXPR_COL);
    VDCsupSetROW(&me->rowList[ 8], 8, VDSUP_I_DIS1, 0, VDSUP_OBJ_DIS1, VDSUP_EXPR_COL);
    VDCsupSetROW(&me->rowList[ 9], 9, VDSUP_I_DIS2, 0, VDSUP_OBJ_DIS2, VDSUP_EXPR_COL);
    VDCsupSetROW(&me->rowList[10],10, VDSUP_I_CNT, 0, VDSUP_OBJ_CNT, VDSUP_EXPR_COL);

    n = 11;
    for( index = VDSUP_I_TRACE_BEG + 4; index < VDSUP_I_TRACE_END; index += 2)
    {
      VDCsupSetROW(&me->rowList[n], n, index, 0, VDSUP_OBJ_TRACE, VDSUP_ITEM_COL);
      n++;
    }
    printf("  n = %d\n", n );
    VDCsupSetROW(&me->rowList[n], -1,0,0,0,0);
  }

  if (type == VDSUP_CMD_EQU_PL || type == VDSUP_CMD_EQU_MD)
  {
    VDCsupSetROW(&me->rowList[ 0], 0, VDSUP_I_SURF, 0, VDSUP_OBJ_BASE_SURF, VDSUP_ITEM_COL);
    VDCsupSetROW(&me->rowList[ 1], 1, VDSUP_I_REF1, 0, VDSUP_OBJ_BASE_OBJ1, VDSUP_ITEM_COL);
    VDCsupSetROW(&me->rowList[ 2], 2, VDSUP_I_REF2, 0, VDSUP_OBJ_BASE_OBJ2, VDSUP_ITEM_COL);
    VDCsupSetROW(&me->rowList[ 3], 3, VDSUP_I_PT_DIR, 0, VDSUP_OBJ_DIR, VDSUP_ITEM_COL);
    VDCsupSetROW(&me->rowList[ 4], 4, VDSUP_I_PT_SEL, 0, VDSUP_OBJ_SEL, VDSUP_ITEM_COL);
    VDCsupSetROW(&me->rowList[ 5], 5, VDSUP_I_TRIM1, 0, VDSUP_OBJ_TRACE1, VDSUP_ITEM_COL);
    VDCsupSetROW(&me->rowList[ 6], 6, VDSUP_I_TRIM2, 0, VDSUP_OBJ_TRACE2, VDSUP_ITEM_COL);
    VDCsupSetROW(&me->rowList[ 7], 7, VDSUP_I_CUT1, 0, VDSUP_OBJ_CUT1, VDSUP_EXPR_COL);
    VDCsupSetROW(&me->rowList[ 8], 8, VDSUP_I_CUT2, 0, VDSUP_OBJ_CUT2, VDSUP_EXPR_COL);
    VDCsupSetROW(&me->rowList[ 9], 9, VDSUP_I_CNT, 0, VDSUP_OBJ_CNT, VDSUP_EXPR_COL);

    n = 10;
    for( index = VDSUP_I_TRACE_BEG + 4; index < VDSUP_I_TRACE_END; index += 2)
    {
      VDCsupSetROW(&me->rowList[n], n, index, 0, VDSUP_OBJ_TRACE, VDSUP_ITEM_COL);
      n++;
    }
    printf("  n = %d\n", n );
    VDCsupSetROW(&me->rowList[n], -1,0,0,0,0);
  }


  switch(me->mytype) {

    case VDSUP_CMD_CRV_PL: {
      strcpy(formTitle,"Place Support Curve"); 
      break;
    }
    case VDSUP_CMD_OFF_PL: {
      strcpy(formTitle,"Place Support Offset Curve"); 
      break;
    }
    case VDSUP_CMD_EQU_PL: {
      strcpy(formTitle,"Place Support Equidistance Curve"); 
      break;
    }
    case VDSUP_CMD_CRV_MD: {
      strcpy(formTitle,"Modify Support Curve"); 
      break;
    }
    case VDSUP_CMD_OFF_MD: {
      strcpy(formTitle,"Modify Support Offset Curve"); 
      break;
    }
    case VDSUP_CMD_EQU_MD: {
      strcpy(formTitle,"Modify Supp Equidistance Curve"); 
      break;
    }
  }

  strcpy(formName, "VDCzup.frm"); 


  /* Get Form Started */
  status = FIf_new(1, formName,
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

  FIf_display( me->form_ptr );

  /* Fill Item column of multi-column field gadget with list of expected    */
  /* entries, depending upon command type.                                  */

  VDsupSetItemMCField( me->form_ptr, me->mytype );

  strcpy(occName,"BLANK");
  VDsupGetNextOccName(NULL, occName);
  FIg_set_text(me->form_ptr, VDSUP_FRM_F_NAME, occName);

  me->locateFlag = 0;

  End

  return OM_S_SUCCESS;

} /* end method init */

/* -----------------------------------------------
 * MET delete Called when command exits
 */
method delete ( int f_defer_flag )
{
  IGRstat sts;

  sts = om$send( 
    msg = message VDCzupGen.VDCsupSaveFormLoc(),
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


method VDCsupSaveFormLoc()
{
  int x_form, y_form;

SetProc( VDCsupSaveFormLoc ); Begin

  FIf_get_location( me->form_ptr, &x_form, &y_form );

  g_VDCsupInfo.xpos = x_form;
  g_VDCsupInfo.ypos = y_form;

  End

  return MSSUCC;

}

void VDCsupPlaceItemInfo( IGRlong row_typ, IGRchar *form_buff )
{
  IGRlong msgnumb = 0;


  switch(row_typ)
  {
    case VDSUP_OBJ_BASE_SURF: msgnumb = VD_I_supBaseSurf;  break;
    case VDSUP_OBJ_BASE_OBJ1: msgnumb = VD_I_supBaseObj1;  break;
    case VDSUP_OBJ_BASE_OBJ2: msgnumb = VD_I_supBaseObj2;  break;
    case VDSUP_OBJ_DIR:       msgnumb = VD_I_supDir;       break;
    case VDSUP_OBJ_SEL:       msgnumb = VD_I_supSel;       break;
    case VDSUP_OBJ_TRACE1:    msgnumb = VD_I_supTrace1;    break;
    case VDSUP_OBJ_TRACE2:    msgnumb = VD_I_supTrace2;    break;
    case VDSUP_OBJ_CUT1:      msgnumb = VD_I_supCut1;      break;
    case VDSUP_OBJ_CUT2:      msgnumb = VD_I_supCut2;      break;
    case VDSUP_OBJ_DIS1:      msgnumb = VD_I_supDis1;      break;
    case VDSUP_OBJ_DIS2:      msgnumb = VD_I_supDis2;      break;
    case VDSUP_OBJ_CNT:       msgnumb = VD_I_supCnt;       break;
    case VDSUP_OBJ_TRACE:     msgnumb = VD_I_supTraces;    break;
  }

  *form_buff = 0;

  ex$message(msgnumb = msgnumb, buff = form_buff);

}

end implementation VDCzupGen;
