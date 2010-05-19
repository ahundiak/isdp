/* $Id: VDCbroi.I,v 1.1.1.1 2001/01/04 21:07:57 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdbro/imp/VDCbroi.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDCbroi.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:57  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/10/29  17:22:44  pinnacle
# ah creation
#
 *
 * History:
 *      MM/DD/YY  AUTHOR  DESCRIPTION
 *      10/29/97  ah      added header
 ***************************************************************************/

class implementation VDCbro;

#include "VDmaster.h"
#include "VDmsg.h"

#include "VDbro.h"
#include "VDCbro.h"

extern void COB_FI_form_notification(), COB_FI_initial_form_notification();

// Dumps file to text
IGRstat VDbroFileObj(FILE *file, GRspacenum osnum, GRobjid objid)
{
  VDbroObjInfo info;
  TGRid   id;
  IGRchar desc[16384];

  id.osnum = osnum;
  id.objid = objid;

  if (!VDbroGetObjInfo(&id,&info)) return 0;

  VDbroGetObjDesc(&info,desc);

  fprintf(file,"%s\n",desc);

  // VDartExpObj(file,&info,desc);

  return 1;
}

IGRstat VDCbroSpec()
{
  IGRchar osname[256],*p;
  GRobjid objid_max,objid;

  GRspacenum osnum = 2;
  FILE *file;

  /* Grab the file name */
  om$os_number_to_name(osnum = osnum, osname = osname);
  p = strrchr(osname,'/');
  if (p) strcpy(osname,p+1);
  strcat(osname,"X");

  /* Cycle Through */
  objid_max = OM_GA_OSDs[osnum]->CurSpaceMapSize;

  file = fopen(osname,"wt");

  for(objid = 0; objid < objid_max; objid++) {
    VDbroFileObj(file,osnum,objid);
  }

  fclose(file);

  return 1;
}

/* --------------------------------------------
 * Fills in various form fields
 */
IGRstat VDCbroSetObjForm(VDbroObjInfo *info, IGRboolean expandFlag)
{
  IGRchar work[1024];
  IGRchar desc[1024];
  IGRint  i;

  Form form = info->frmInfo->form;

  if (expandFlag) {
    sprintf(work,"%d",info->id.osnum);
    FIg_set_text(form,VDBRO_FRM_F_OSNUM,work);

    sprintf(work,"%d",info->id.objid);
    FIg_set_text(form,VDBRO_FRM_F_OBJID,work);

    sprintf(work,"b%d_%d.txt",info->id.osnum,info->id.objid);
    FIg_set_text(form,VDBRO_FRM_F_SAVE,work);

    FIg_set_text(form,VDBRO_FRM_F_CLASSNAME,info->className);
    FIg_set_text(form,VDBRO_FRM_F_STATUS,   info->objName);
    FIg_set_text(form,VDBRO_FRM_F_STAT,     info->expStr);
  }

  /* Do the list */
  *work = 0;
  for(i = 0; i < info->frmInfo->indent; i++) {
    strcat(work," ");
  }
  if (expandFlag) strcat(work,"+");
  else            strcat(work,"-");

  VDbroGetObjDesc(info,desc);
  strcat(work,desc);

  if (!expandFlag) {
    FIfld_insert_blank_row(form,VDBRO_FRM_L_OBJ,info->frmInfo->row);
  }
  FIfld_set_text        (form,VDBRO_FRM_L_OBJ,info->frmInfo->row,0,work,FALSE);
  info->frmInfo->row++;

  return 1;
}

/* -----------------------------------------------------
 * Object On Screen 
 */
IGRstat VDCbroSetObj(VDbroFrmInfo *frmInfo, TGRid *id, IGRboolean resetFlag)
{
  VDbroObjInfo objInfo;

  if (resetFlag) {
    frmInfo->row    = 0;
    frmInfo->indent = 0;
    FIfld_set_num_rows(frmInfo->form,VDBRO_FRM_L_OBJ,0);
  }

  VDbroGetObjInfo(id,&objInfo);
  objInfo.frmInfo = frmInfo;
  VDCbroSetObjForm(&objInfo,1);

  if (!(objInfo.sts & 1)) return 1;

  frmInfo->indent += 2;
  VDCbroListChn(id,1,frmInfo);

  return 1;
}

/* ---------------------------------------------
 * Expand/Contract Object Row
 */
IGRstat VDCbroLocRowMinus(VDbroFrmInfo *frmInfo, IGRchar *buf)
{
  char   *p;
  TGRid  id;
  IGRint indent;

  /* Easy filter */
  p = strstr(buf,"-OBJ");
  if (p == NULL) return 0;

  indent = p - buf;

  /* Extrace id */
  id.osnum = atoi(p+4);

  p = strchr(buf,',');
  if (p == NULL) return 0;
  id.objid = atoi(p+1);

  /* Set the indent */
  frmInfo->indent = indent;

  /* Display it */
  VDCbroSetObj(frmInfo,&id,0);
 
  return 1;
}

/* ---------------------------------------------
 * Expand/Contract Object Row
 */
IGRstat VDCbroLocRowPlus(VDbroFrmInfo *frmInfo, IGRchar *buf)
{
  char   *p;
  TGRid  id;
  IGRint indent;

  VDbroObjInfo objInfo;

  /* Easy filter */
  p = strstr(buf,"+OBJ");
  if (p == NULL) return 0;

  indent = p - buf;

  /* Extrace id */
  id.osnum = atoi(p+4);

  p = strchr(buf,',');
  if (p == NULL) return 0;
  id.objid = atoi(p+1);

  /* Set the indent */
  frmInfo->indent = indent;

  VDbroGetObjInfo(&id,&objInfo);
  objInfo.frmInfo = frmInfo;
  VDCbroSetObjForm(&objInfo,1);

  return 1;
}

/* -----------------------------------------------------
 * Picked a row
 */
IGRstat VDCbroLocRow (VDbroFrmInfo *frmInfo)
{
  IGRint  pos;
  IGRstat sts;
  IGRchar buf[1024];

  IGRint  sel_flag,r_pos;

  sts = FIfld_get_active_row(frmInfo->form,VDBRO_FRM_L_OBJ,&frmInfo->row,&pos);
  if (sts != FI_SUCCESS) return 0;

  *buf = 0;
  sts = FIfld_get_text(
    frmInfo->form,VDBRO_FRM_L_OBJ,
    frmInfo->row,0,1024,buf,&sel_flag,&r_pos);

  if (VDCbroLocRowMinus(frmInfo,buf)) return 1;
  if (VDCbroLocRowPlus (frmInfo,buf)) return 1;

  /* Done */
  return 1;
}


/* ----------------------------------------------------------
 * Look up object by id
 */
IGRstat VDCbroLookObj(VDbroFrmInfo *frmInfo)
{
  TGRid   id;
  IGRchar work[1024];

  FIg_get_text(frmInfo->form,VDBRO_FRM_F_OSNUM,work);
  id.osnum = atoi(work);

  FIg_get_text(frmInfo->form,VDBRO_FRM_F_OBJID,work);
  id.objid = atoi(work);

  VDCbroSetObj(frmInfo,&id,1);

  return 1;
}

/* -----------------------------------------------------
 * Picked an object
 */
method VDCbroLocObj (int *msg)
{
  TGRid id = me->event1.located_object[0].located_obj;

  VDCbroSetObj(&me->frmInfo,&id,1);

  *msg = 1;
  return 1;
}

/* ------------------------------------------------------
 * Save a text file
 */
IGRstat VDCbroSaveFile(VDbroFrmInfo *frmInfo)
{
  IGRint  rowNum;
  IGRint  sel_flag,r_pos;

  IGRchar fileName[32];
  FILE   *fileOut;
  IGRchar work[1024];

  FIg_get_text(frmInfo->form,VDBRO_FRM_F_SAVE,fileName);
  fileOut = fopen(fileName,"wt");
  if (fileOut == 0) {
    sprintf(work,"Could Not Open %s",fileName);
    UI_status(work);
    return 0;
  }

  for(rowNum = 0; 
      (FIfld_get_text(
        frmInfo->form,VDBRO_FRM_L_OBJ,
        rowNum,0,1024,work,&sel_flag,&r_pos
        ) == FI_SUCCESS); 
      rowNum++) {

    fprintf(fileOut,"%s\n",work);
  }
  
  fclose(fileOut);
  sprintf(work,"Saved To %s",fileName);
  UI_status(work);
  return 1;

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

  switch ( gadget_label ) {

    case VDBRO_FRM_B_SPEC: {
      VDCbroSpec();
      break;
    }

    case VDBRO_FRM_B_OBJ:
    case VDBRO_FRM_F_OBJID: {
      VDCbroLookObj(&me->frmInfo);
      break;
    }

    case VDBRO_FRM_B_SAVE:
    case VDBRO_FRM_F_SAVE: {
      VDCbroSaveFile(&me->frmInfo);
      break;
    }

    case VDBRO_FRM_L_OBJ: {
      VDCbroLocRow(&me->frmInfo);
      break;
    }

    case FI_CANCEL: {
      dp$erase_hilite( msg = &sts );
      _put_response( resp = TERMINATE );
      break;
    }

  }

quit:
  return OM_S_SUCCESS;
}

/* ------------------------------------------------------
 * MET init
 */
method init ( int type ; char * str_ptr )
{
  IGRstat sts;
  Form form = NULL;

  /* Init Parent */
  sts  = om$send( 
    msg = message CEO_LOCATE.init( type, str_ptr ),
    targetid = my_id,
    mode = OM_e_wrt_message
  );
  __CheckSTS(sts,"Initing",failed);

  /* Get Form Started */
  sts = FIf_new(1,"VDbro.frm",COB_FI_form_notification,&me->frmInfo.form);
  form     = me->frmInfo.form;
  if (sts) goto failed;
  
  sts = FIf_set_cmd_oid_os (form, my_id, OM_Gw_current_OS );
  if (sts) goto failed;

  sts = FIf_set_initial_notification_routine ( 
    form,
    COB_FI_initial_form_notification 
  );
  if (sts) goto failed;

  FIg_set_text(form,VDBRO_FRM_F_OSNUM,"2");

  FIf_display(form);
  
  return OM_S_SUCCESS;

failed:
  if (form) {
    FIf_delete(form);
    me->frmInfo.form = NULL;
  }
  me->state = _terminate;
  return OM_I_STOP_SENDING;
} 

/* -----------------------------------------------
 * MET delete Called when command exits
 */
method delete ( int f_defer_flag )
{
  IGRstat sts;

  if (me->frmInfo.form) FIf_delete(me->frmInfo.form);

  sts = om$send( 
    msg = message CEO_LOCATE.delete ( 0 ),
    targetid = my_id,
    mode   = OM_e_wrt_message
  );

  return OM_S_SUCCESS;
}

end implementation VDCbro;
