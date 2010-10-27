/* $Id: VDCsupGenPl1.I,v 1.1.1.1 2001/01/04 21:09:23 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdsup/cmd/VDCsupGenPl1.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDCsupGenPl1.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:09:23  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.5  1997/11/25  15:18:58  pinnacle
# VDmaster
#
# Revision 1.4  1997/10/29  15:20:46  pinnacle
# Added Headers
#
 *
 * History:
 *      MM/DD/YY  AUTHOR  DESCRIPTION
 *      10/29/97  ah      added header
 *      07/11/97  EJM     CR#179701494  Support curve enhancements
 *                        Added code to handle SWAPUP, SWAPDN and
 *                        CLONE buttons.
 *	11/30/97  ah	  Deleted extern NULL_GRID
 ***************************************************************************/

class implementation VDCsupGenPl;

#include "VDmaster.h"
#include "VDmsg.h"

#include "VDsupMac.h"
#include "VDCsupForm.h"

#define EPS 0.000001

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
  IGRint  l_suc;

  TGRid   supId,colId;

  TGRid   tempListId[VDSUP_MAC_MAX_NUM_TEMP];
  IGRlong tempNum;

  IGRlong macType;

  IGRchar name[DI_PATH_MAX];
  IGRint  cn_type;

  IGRchar form_buff[128];

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
  IGRchar occName[DI_PATH_MAX];

  int i_msg,i_label;

  VDCsupFBI fbi;

  int found=0;
  IGRchar  symb_path[DI_PATH_MAX],symb_dir[NAME_MAX];




  /* Once we get form input then no longer initializing */
  me->initFlag = 0;

  /* See if locate in progreess */
  if ((me->locateFlag) && (gadget_label != FI_CANCEL)) {
    FIg_set_text(form_ptr,VDSUP_FRM_F_STATUS,"Locate in progress, ignoring");
    goto quit;
  }

  /* Check for sleep */
  if ((me->sleepFlag) && (gadget_label != FI_CANCEL)) {
    FIg_set_text(form_ptr,VDSUP_FRM_F_STATUS,"Command is stacked, Left Double Click To Pop");
    goto quit;
  }

  /* Handle clear state */
  if (me->ClearFlag) {

    if (VDCsupGetFBI(me->fbiList,gadget_label,gadget_label,&fbi)) {

      me->tl[fbi.ind].osnum = 0;
      me->tl[fbi.ind].objid = 0;
      FIg_set_text(form_ptr,fbi.fld,"");

    }

    FIg_set_text(form_ptr,VDSUP_FRM_F_STATUS,"");
    me->ClearFlag = 0;
    goto quit;
  }
  me->ClearFlag = 0;

  /* Process most buttons or fields */
  if (VDCsupGetFBI(me->fbiList,gadget_label,gadget_label,&fbi)) {

    /* Geometry object's button was pressed */
    if ((fbi.exp == 0) && (fbi.but == gadget_label)) {
      me->locateFlag = 1;
      FIg_set_text(form_ptr,VDSUP_FRM_F_STATUS,"Locate Object...");
      VDsupDispObj(&me->tl[fbi.ind],&me->ModuleInfo,GRhd,1);
      _put_response( resp = gadget_label );
      goto quit;
    }

    /* Expression object's field was edited */
    if ((fbi.exp == 1) && (fbi.fld == gadget_label)) {
      i_label = gadget_label;
      sts = om$send(
        msg = message VDCsupGen.VDCsupSetExpForm(&i_msg,i_label),
        targetid = my_id
      );
      goto quit;
    }
  }

  switch ( gadget_label ) {

  case VDSUP_FRM_B_CLEAR: {
    me->ClearFlag = 1;
    FIg_set_text(form_ptr,VDSUP_FRM_F_STATUS,"Pick field to clear");
    break;
  }

  case FI_EXECUTE:
    sts = om$send(
      msg = message VDCsupGenPl.PlaceMacro(&msg),
      targetid = my_id
    );
  break;

  case FI_ACCEPT:
    sts = om$send(
      msg = message VDCsupGenPl.PlaceMacro(&msg),
      targetid = my_id
    );
      _put_response(resp = TERMINATE);
  break;

  case FI_CANCEL:
    dp$erase_hilite( msg = &sts );
    _put_response( resp = TERMINATE );
  break;

  case FI_RESET:
    memset(me->tl,0,sizeof(me->tl));
    me->initFlag = 1;
    me->locateFlag = 1;

    VDsupGetNextOccName(NULL, occName);
    FIg_set_text(me->form_ptr, VDSUP_FRM_F_NAME, occName);

    dp$erase_hilite( msg = &sts );
    _put_response( resp = gadget_label );
  break;

  case VDSUP_FRM_B_TRACE_ADD:
    me->locateFlag = 1;
    FIg_set_text(form_ptr,VDSUP_FRM_F_STATUS,"Locate Object...");
    _put_response( resp = gadget_label );
  break;

  case VDSUP_FRM_B_TRACE_DEL:
    sts = om$send(
      msg = message VDCsupGen.VDCsupDelTrace(&i_msg),
      targetid = my_id
    );
  break;

  case VDSUP_FRM_B_SWAPUP:
    sts = om$send(
      msg = message VDCsupGen.VDCsupSwapTrace(&i_msg, gadget_label),
      targetid = my_id
    );
  break;

  case VDSUP_FRM_B_SWAPDN:
    sts = om$send(
      msg = message VDCsupGen.VDCsupSwapTrace(&i_msg, gadget_label),
      targetid = my_id
    );
  break;

  case VDSUP_FRM_B_CLONE:

    /* Set active symbology for macro clone using "SupClone" directory if  */
    /* it exists; First save current directory                             */

    sts = vds$get_path(return_path = symb_path, name_path = symb_dir);

    if(!(sts&1))
    {
      printf("error vds$get_path1, error getting current directory\n");
      goto quit;
    }

    sts = vds$get_path(return_path = symb_path, in_name = "SupClone", 
                             found = &found);
    if(!(sts&1)){
        printf("error vds$get_path2, error getting SupClone directory\n");
        goto quit;
    }
    else if (!found){
      printf("\n  No SupClone dir, will use current dir for clone symbology\n");
    }
    else
    {
      sts = vds$set_act_path(path_name = "SupClone", const_flag = MAIN_PATH);
      if(!(sts&1)){
        printf("error vds$set_act_path1, error setting SupClone dir as active\n");
        goto quit;
      }
    }

    /* Switch mytype so PlaceMacro will execute ACmplace and clone existing */
    /* macro.                                                               */
    switch(me->mytype){
      case VDSUP_CMD_OFF_MD:  me->mytype = VDSUP_CMD_OFF_PL; break;
      case VDSUP_CMD_EQU_MD:  me->mytype = VDSUP_CMD_EQU_PL; break;
      case VDSUP_CMD_CRV_MD:  me->mytype = VDSUP_CMD_CRV_PL; break;
    }

    sts = om$send(
      msg = message VDCsupGenPl.PlaceMacro(&msg),
      targetid = my_id
    );

    switch(me->mytype){
      case VDSUP_CMD_OFF_PL:  me->mytype = VDSUP_CMD_OFF_MD; break;
      case VDSUP_CMD_EQU_PL:  me->mytype = VDSUP_CMD_EQU_MD; break;
      case VDSUP_CMD_CRV_PL:  me->mytype = VDSUP_CMD_CRV_MD; break;
    }

    /* Set active symbology back to previous directory if SupClone dir was used
     */
    if (found) {
      sts = vds$set_act_path(path_name = symb_dir, const_flag = MAIN_PATH);
      if(!(sts&1)) {
        printf("error vds$set_act_path2, error setting previous dir as active\n");
        goto quit;
      }
    }

  break;

  } /* switch gadget_label */

quit:
  return OM_S_SUCCESS;
}

/* ---------------------------------------------------
 * FCT VDsupGetNextOccName
 */
IGRstat	VDsupGetNextOccName(IGRchar *full_name, IGRchar *name)
{
  int     i;
  TGRid   id;
  IGRchar path[DI_PATH_MAX];
  IGRchar full[DI_PATH_MAX];

  IGRstat sts;

  di$pwd(dirname = path);

  for(i = 1; i < 1000; i++) {

    sprintf(full,"%s:supp_%02d",path,i);

    sts = di$translate ( 
      objname = full,
      p_objid = &id.objid,
      p_osnum = &id.osnum 
    );
    if (sts != DIR_S_SUCCESS) {
      if (full_name) strcpy (full_name,full);
      if (name)      sprintf(name,"supp_%02d",i);
      return MSSUCC;
    }
  }

  return MSFAIL;
}

end implementation VDCsupGenPl;

