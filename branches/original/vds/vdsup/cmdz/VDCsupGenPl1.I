class implementation VDCzupGenPl;

from 	GRvg 		import 	GRcenter,GRchgname;
from 	NDnode 		import 	ASreturn_go,NDget_objects;
from 	GRgraphics 	import 	GRaltconstruct,GRdisplay;
from 	NDnode     	import 	NDchg_state,NDconnect;
from 	ACrg_collect	import	AClist_attribute,ACadd_list_attribute,ACget_named_attribute;
from    ACncpx          import  ACmplace;

from    VDsupGen        import  VDsupSetType;
from    VDsupGen        import  VDsupSetTempList;
from    VDsupGen        import  VDsupChkMinInput;

extern GRclassid OPP_VDsupGen_class_id;

/* ------------------------------------------------------
 * MET PlaceMacro
 * Pulls info from the form and places the macro
 */

method PlaceMacro (int *msg)
{
  IGRstat sts,l_msg;
  IGRint  l_suc, i;

  TGRid   supId,colId;

  TGRid   tempListId[VDSUP_MAC_MAX_NUM_TEMP];
  IGRlong tempNum;

  IGRlong macType;

  IGRchar name[DI_PATH_MAX];
  IGRint  cn_type;

  IGRchar form_buff[128];

SetProc( PlaceMacro ); Begin

  /* See if modify */
  switch(me->mytype) {
    case VDSUP_CMD_CRV_MD:
    case VDSUP_CMD_OFF_MD:
    case VDSUP_CMD_EQU_MD:

    supId = me->supId;

    /* Check for required inputs to command */
    sts = om$send(
      msg = message VDsupGen.VDsupChkMinInput(&l_suc, me->tl, form_buff),
        senderid = NULL_OBJID,
        targetid = supId.objid,
        targetos = supId.osnum 
    );
    if(!(l_suc&1))
    {
      FIg_set_text(me->form_ptr, VDSUP_FRM_F_STATUS, form_buff);
      goto quit;
    }

    /* Make new template list */
    sts = om$send(
      msg = message VDsupGen.VDsupSetTempList(
        me->tl,
        VDSUP_I_MAX,
        NULL,
       &tempNum,
        tempListId),
      senderid = NULL_OBJID,
      targetid = supId.objid,
      targetos = supId.osnum 
    );

    /* Reconnect */
    sts = om$send(
      msg = message NDnode.NDconnect(
        tempNum,tempListId,NULL_GRID,ND_FULL
      ),
      senderid = NULL_OBJID,
      targetid = supId.objid,
      targetos = supId.osnum 
    );

    /* Recompute */
    cn_type = ND_COMP;

    nd$wait_batch(
      type = GR_GEOM_POSTED,
      nb_obj     = 1,
      l_object   = &supId,
      l_obj_info = &cn_type
    );

    nd$exec_batch();

    goto quit;
  }

  /* Construct Collection Object */
  colId.osnum = me->ModuleInfo.md_id.osnum;
  sts = om$construct(
    classid = OPP_ACrg_collect_class_id,
    osnum   =  colId.osnum,
    p_objid = &colId.objid
  );
  om$send( 
    msg = message NDnode.NDchg_state(ND_DEL_NO_CH, ND_DEL_NO_CH ),
    targetid = colId.objid,
    targetos = colId.osnum 
  );
  me->tl[VDSUP_I_COL] = colId;
  
  /* Make the support object */
  supId.osnum = me->ModuleInfo.md_id.osnum;

  sts = om$construct( 
    classid = OPP_VDsupGen_class_id,
    osnum   =  supId.osnum,
    p_objid = &supId.objid 
  );
  if (!(sts&1)) {
    UI_status("Unable to Create Support Macro");
    goto quit;
  }

  /* Set The Type */
  macType = 0;
  switch(me->mytype) {
    case VDSUP_CMD_CRV_PL: macType = VDSUP_MAC_TYPE_CRV; break;
    case VDSUP_CMD_OFF_PL: macType = VDSUP_MAC_TYPE_OFF; break;
    case VDSUP_CMD_EQU_PL: macType = VDSUP_MAC_TYPE_EQU; break;
  }

  sts = om$send(
    msg = message VDsupGen.VDsupSetType(macType),
    senderid = NULL_OBJID,
    targetid = supId.objid,
    targetos = supId.osnum
  );

  /* Check for required inputs to command */
  sts = om$send(
    msg = message VDsupGen.VDsupChkMinInput(&l_suc, me->tl, form_buff),
    senderid = NULL_OBJID,
    targetid = supId.objid,
    targetos = supId.osnum
  );
  if(!(l_suc&1))
  {
    FIg_set_text(me->form_ptr, VDSUP_FRM_F_STATUS, form_buff);
    vd_$bulk_delete(theEnv = &me->ModuleInfo, grids = &supId);
    goto quit;
  }

  /* Generate template List */
  sts = om$send(
    msg = message VDsupGen.VDsupSetTempList(
      me->tl,
      VDSUP_I_MAX,
      NULL,
     &tempNum,
      tempListId),
    senderid = NULL_OBJID,
    targetid = supId.objid,
    targetos = supId.osnum 
  );

printf("\n  return from VDsupSetTempList:\n");
printf("\n  tempNum = %d\n", tempNum);

for(i=0; i < tempNum; i++)
  printf("\n  tempListId[%d].objid  = %d\n", i, tempListId[i].objid);

   
  VDsupGetNextOccName(name,NULL);

  om$send(
    msg = message GRgraphics.GRchgname(&l_msg, &me->ModuleInfo, name ),
    senderid = NULL_OBJID,
    targetid = supId.objid,
    targetos = supId.osnum 
  );

  sts = om$send(  
    msg  = message ACncpx.ACmplace(
      &l_suc,
       AChdr_noprotect, 0,
       VDSUP_MAC_NAME,
       tempNum,
       tempListId,
      &me->ModuleInfo 
    ),
    targetid = supId.objid,
    targetos = supId.osnum 
  );

  if (!(sts&l_suc&1)) {
    UI_status("Unable to Place Support Macro");
    vd_$bulk_delete(theEnv = &me->ModuleInfo, grids = &supId);
    goto quit;
  }

  VDsupGetNextOccName(NULL,name);
  FIg_set_text(me->form_ptr,VDSUP_FRM_F_NAME,name);

quit:
  *msg = MSSUCC;

   End

   return OM_S_SUCCESS;
}
 
/* ----------------------------------------------------------
 * MET form_notification
 */
method form_notification ( 
  int     form_label ; 
  int     gadget_label ; 
  double  value ;
  char   *form_ptr 
)
{
  IGRlong sts,status;
  IGRlong msg;

  int i_msg;
  int rowNum, colNum, pos;
  IGRchar info_buff[128];

  VDCsupROW row;


SetProc( form_notification ); Begin

  printf("\n   form_notification:  value  = %f\n", value);

  /* See if locate in progress */
  if ((me->locateFlag) && (gadget_label != FI_CANCEL)) {
/*  FIg_set_text(form_ptr,VDSUP_FRM_F_STATUS,"Locate in progress, ignoring"); */
    _put_response( resp = MOVE_ON );
/*  goto quit; */
  }

  /* Check for sleep */
  if (me->sleepFlag) {
    FIg_set_text(form_ptr,VDSUP_FRM_F_STATUS,"Quiet, the baby is asleep :-)");
    goto quit;
  }


  sts = FIfld_get_active_row(me->form_ptr,VDSUP_FRM_L_OBJECTS,&rowNum,&pos);
  if( sts != FI_SUCCESS ) return MSSUCC;
  sts = FImcf_get_active_col(me->form_ptr,VDSUP_FRM_L_OBJECTS,&colNum,&pos);
  if( sts != FI_SUCCESS ) return MSSUCC;

  printf("\n   form_notification:  rowNum = %d  colNum = %d\n", rowNum, colNum);

  switch ( gadget_label ) 
  {
    case VDSUP_FRM_L_OBJECTS:

      if (VDCsupGetROW(me->rowList,rowNum,&row))
      {
  printf("\n   case VDSUP_FRM_L_OBJECTS:\n");
  printf("\n            row.col = %d\n\
            row.typ = %d\n\
            row.idx = %d\n", row.col, row.typ, row.idx);

        /* Objects's expression field was edited */ 
        if (colNum == 2)
        {
          if (row.col == VDSUP_EXPR_COL) {
            sts = om$send(msg = message
                          VDCzupGen.VDCsupSetExpForm(&i_msg,rowNum,row.idx),
                     targetid = my_id
          );
          }
          else
          {
            FIg_set_text(form_ptr, VDSUP_FRM_F_STATUS, "Expression not applicable for this item.");
          }
          goto quit;
        } /* colNum = 2 */


        if (colNum == 0)
        {
          if (row.col == VDSUP_ITEM_COL) 
          {
            FIg_set_text(form_ptr,VDSUP_FRM_F_STATUS," Locate Object...");
	    VDCsupPlaceItemInfo( row.typ, info_buff );
	    FIg_set_text( form_ptr, VDSUP_FRM_F_INFO, info_buff );
            VDsupDispObj(&me->tl[row.idx],&me->ModuleInfo,GRhd,1);
            me->locateFlag = 1;
            /* go to state locate_object */
            _put_response( resp = gadget_label );
          }
          else
          {
	    VDCsupPlaceItemInfo( row.typ, info_buff );
	    FIg_set_text( form_ptr, VDSUP_FRM_F_INFO, info_buff );
            FIg_set_text(form_ptr, VDSUP_FRM_F_STATUS, "Input an expression.");
          }
        } /* colNum = 0 */
      } /* VDCsupGetROW */
    break;

    case VDSUP_FRM_B_CLEAR:


      if (VDCsupGetROW(me->rowList,rowNum,&row))
      {
	me->tl[row.idx].osnum = 0;
	me->tl[row.idx].objid = 0;
        FIfld_set_text( form_ptr,VDSUP_FRM_L_OBJECTS,rowNum,VDSUP_NAME_COL,"",FALSE );
        FIfld_set_text( form_ptr,VDSUP_FRM_L_OBJECTS,rowNum,VDSUP_EXPR_COL,"",FALSE );
	FIg_set_text( form_ptr, VDSUP_FRM_F_INFO, "" );
        FIg_set_text( form_ptr, VDSUP_FRM_F_STATUS, "" );
      }
    break;
  
    case FI_EXECUTE:
      sts = om$send(
        msg = message VDCzupGenPl.PlaceMacro(&msg),
        targetid = my_id
      );
    break;
  
    case FI_ACCEPT:
      sts = om$send(
        msg = message VDCzupGenPl.PlaceMacro(&msg),
        targetid = my_id
      );
      _put_response(resp = TERMINATE);
    break;
  
    case FI_CANCEL:
      dp$erase_hilite( msg = &sts );
      _put_response( resp = TERMINATE );
    break;
  
 /* 
    case VDSUP_FRM_B_TRACE_ADD:
      me->locateFlag = 1;
      FIg_set_text(form_ptr,VDSUP_FRM_F_STATUS,"Locate Object...");
      _put_response( resp = gadget_label );
    break;
  
    case VDSUP_FRM_B_TRACE_DEL:
      sts = om$send(
        msg = message VDCzupGen.VDCsupDelTrace(&i_msg),
        targetid = my_id
      );
    break;
*/

  } /* switch */

quit:

  End

  return OM_S_SUCCESS;
}

end implementation VDCzupGenPl;

