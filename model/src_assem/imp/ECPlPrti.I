/*******************************************************************************
*              			       *
* File:   ECPlPrti.I              	       *
*              			       *
* Description:              		       *
*                                                                              *
*     This file contains implementation of the Place part command object       *
*              			       *
*              			       *
* Dependencies:              		       *
*                                                                              *
* Notes:              	               *
*                                                                              *
* History:         19/07/93   Krishna Kumar    creation date                   *
*                  22/06/94   dkk              creating partdefinition in EMS3 *
*                                              files and saving the file       *
*                  05/07/94   Gang             added update part display       *
*******************************************************************************/

class implementation ECPlPrt;
#include "stdio.h"
#include "string.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "tools.h"
#include "FI.h"
#include <exdef.h>
#include <ex.h>
#include <exmacros.h>
#include <gr.h>
#include <grdpbdef.h>
#include <grdpbmacros.h>
#include "DIdef.h"
#include "dpdef.h"
#include "dp.h"
#include "dpmacros.h"
#include "griodef.h"
#include "griomacros.h"
#include "refdef.h"
#include "asmprtmac.h"
#include "asmfilemac.h"
#include "assemdef.h"
#include "assem.h"
#include "assemmacros.h"
#include "EC_P.h"
#include "EC_I.h"
#include "EC_M.h"

#include "lcdef.h"
#include "lc.h"
#include "lcmacros.h"
#include "grmsg.h"

#define EXTERN extern
#include "asmglobals.h"

#define MAXPATHLEN 256

/* command states */
#define FINISHED       -1
#define START           0
#define CREATE_INST  2
#define PLCMNT_OPS      3


  /* Gadget on Main Form */
#define DIR_NAME  11
#define DIR_LIST_BTN  14
#define FILE_MCF  12
#define SELECT_MCF  28
#define CREATE_BTN  30
#define CHANGE_BTN  32
#define DELETE_BTN      13
#define RET_TITLE  21

/* Gadgets for Part Placement */
#define PLACE_TITLE  26

  /* Gadgets on Placement options form */
#define INST_ATTR  11
#define PLCMNT_VIEW     19
#define PLCMNT_BY       1111         /* This gadget is not defined on form */
#define BKGPRT_TOG  14
#define UPDATE_TOG      15


#define CREATE_PART 1
#define CREATE_PART_FILE       4

%safe
static int create_part_in_progress = 0;
%endsafe

from GRgraphics import GRdisplay;
from EMinstance import EMupdatebasis;
from EMSdatpln  import GRptproject, EMget_pln_info;
from EMdescribe import EMget_memb;

extern OMuword OPP_EMSdatpln_class_id, OPP_EMSsubbs_class_id;

int placeprt_notify (form_label, gadget_label, value, form_ptr)
IGRint form_label, gadget_label;
IGRdouble value;
Form  form_ptr;
{
IGRint   	status;
IGRlong   msg_loc;
GRobjid   cmdobj;
GRspacenum   cmdos;

   status = FIf_get_cmd_oid_os (form_ptr, &cmdobj, &cmdos);
   if(status)
    	return (OM_E_ABORT);

   status = om$send (msg = message ECPlPrt.do_form1(&msg_loc, form_label,
      	                gadget_label, value),
  	            senderid = NULL_OBJID, 
  	            targetid = cmdobj,
  	            targetos = cmdos);
  if(! (status & 1))
  	 return (OM_E_ABORT);

   return(OM_S_SUCCESS);
}

method init(int type; char *str_ptr)
{
  int ret;
  IGRlong msg;
  struct GRmd_env mod_env;
  struct GRid pid;
  char   *file, filepath[OM_K_MAXOSNAME_LEN];
    
    IGRboolean aflag;
    if(aflag = pwIsActivationOn())
     return (OM_S_SUCCESS); 
  /* 
   * Initialise parent stuff 
   */
  ret = om$send(mode = OM_e_wrt_message,
                msg = message COpara.init( type, str_ptr),
                targetid = my_id);
  /*
   * Initialise the instance
   */
  me->num_inst_attrs = 0;
  me->inst_attrs = NULL;
  me->num_sv_ids = 0;
  me->change_itemno = 1;
  me->selected_part[0] = 0;

  /*
   * Check if the current environment has a file_part definition in it
   */
  gr$get_module_env( buffer = &mod_env );

  ret = asm$get_file_part( msg = &msg,
                           mod_env = &mod_env,
                           part_id = &pid );
  if( !(ret & msg & 1 ))
  {
    EMattr attrs[3];

    /* Create a default file part definition in the master file */
    attrs[0].info.type = EM_PART_ATTR;
    attrs[0].value.type = EM_STRING;
    strcpy(attrs[0].info.name, "description");
    strcpy(attrs[0].info.desc, "Part Description");
    strcpy(attrs[0].value.syntax, "File Part");

    attrs[1].info.type = EM_COMMON_ATTR;
    attrs[1].value.type = EM_STRING;
    strcpy(attrs[1].info.name, "itemno");
    strcpy(attrs[1].info.desc, "Item Number");
    strcpy(attrs[1].value.syntax, "1");

    attrs[2].info.type = EM_INSTANCE_ATTR;
    attrs[2].value.type = EM_INTEGER;
    strcpy(attrs[2].info.name, "quantity");
    strcpy(attrs[2].info.desc, "Quantity");
    strcpy(attrs[2].value.syntax, "1");

    ret = ex$filename( name= filepath,
                       len= OM_K_MAXOSNAME_LEN);

    if((file = strrchr(filepath, '/')) != NULL)
        strcpy(filepath, file+1);

    ret = asm$create_file_part( msg = &msg,
                                number = filepath,
                                revision = "1",
                                mod_env = &mod_env,
                                num_attributes = 3,
                                attributes = attrs );

    if( !(ret & msg & 1) )
    {
      ex$message( msgnumb = EMS_S_NoPrtDef );
      return( OM_E_ABORT );
    }
  }
  ret = FIf_new(100, "EMGetPrtFile", placeprt_notify, &me->fp1);
  if(ret)
     return (OM_E_ABORT);

  ret = FIf_set_cmd_oid_os(me->fp1, my_id, OM_Gw_current_OS);
  if(ret) 
     return (OM_E_ABORT);
    
  /*
   * Erase the gadgets that belong to Retrieve only
   */

  me->active_form = 1; 
  me->state = START;

  ret = Init_plprt_form ( me->fp1 );
  if ( !ret )
  {
    Reset_prtDir(); 
    FIf_delete( me->fp1 );
                me->fp1 = NULL;
    return( OM_E_ABORT );
  }

  if (ME.super_cmd->mytype == CREATE_PART)
  {
    create_part_in_progress = 1;
    me->state = START;
    return (OM_S_SUCCESS);
  }
  else
    create_part_in_progress = 0;

  FIf_display( me->fp1 );
  me->form_displayed = 1;

  return( OM_S_SUCCESS );

}

method wakeup( int pos )
{
  if (ME.super_cmd->mytype == CREATE_PART)
  {
     ex$message(field =1, msgnumb = EM_M_CrPart);
     return( OM_S_SUCCESS );
  }
  else
  {
     ex$message(field =1, msgnumb = EM_M_PlPart);

     if( !me->active_form )
       return( OM_S_SUCCESS );
     if( me->fp1 && (me->active_form == 1) && !me->form_displayed )
     {
       FIf_display( me->fp1 );
       FIf_set_cmd_oid_os(me->fp1, my_id, OM_Gw_current_OS);
     }
     else if( me->fp2 && (me->active_form == 2) && !me->form_displayed )
     {
       FIf_display( me->fp2 );
       FIf_set_cmd_oid_os(me->fp2, my_id, OM_Gw_current_OS);
     }

     me->form_displayed = 1;
  }
  return( OM_S_SUCCESS );
}

method sleep( int pos )
{
  int sts;

  if (ME.super_cmd->mytype != CREATE_PART)
  {
    if( me->active_form == 1 )
    {
       if(me->fp1)
       {
         FIf_erase ( me->fp1 );
         FIf_set_cmd_oid_os(me->fp1, my_id, 0);
       }
    }
    else 
      if( me->active_form == 2 )
      {
         if(me->fp2)
         {
            FIf_erase ( me->fp2 );
            FIf_set_cmd_oid_os(me->fp2, my_id, 0);
         }
    }

      me->form_displayed = 0;

  }
  sts = om$send(mode = OM_e_wrt_message,
                msg = message COpara.sleep( pos ),
                targetid = my_id);

  return( OM_S_SUCCESS );
}

method status_disp()
{
  return( OM_S_SUCCESS );
}

method delete( int pos )
{
  int sts;

  if( me->fp1 )
  	FIf_delete( me->fp1 );
  if( me->fp2 )
  	FIf_delete( me->fp2);

  Reset_prtDir(); 
  sts = om$send(msg = message COpara.delete( pos ),
                targetid = my_id,
                mode = OM_e_wrt_message);

  return( sts );
}

method do_form1( IGRlong *msg; int form_label; int g_label; double value )
{
   int     sf, rp, i, sts;
   char  text_buff[MAXPATHLEN], tempname[MAXPATHLEN];

   FIg_set_text( me->fp1, FI_MSG_FIELD, "" );

   switch ( g_label )
   {
  	case DIR_NAME:
      FIg_get_text( me->fp1, DIR_NAME, text_buff );
      update_select_mcf( me->fp1, -1 );
      move_to_dir( me->fp1, text_buff );
      break;

    case DIR_LIST_BTN:
      show_dir_listing( me->fp1 );
      break;

    case FILE_MCF:
      update_select_mcf( me->fp1, (int)value );
      for( i = 0; i < 4; i++ )
      	FIfld_set_select( me->fp1,g_label,(int)value,i, 0 );
      break;

    case SELECT_MCF:
      FImcf_get_active_col ( me->fp1, g_label, &i, &sf );
      FIfld_get_text(me->fp1,SELECT_MCF,0,i,MAXPATHLEN,
      		text_buff,&sf,&rp);
      if( text_buff[0] && strpbrk( text_buff, "*?[]" ))
      {
      	ListPrt_Files( me->fp1 );
      	FIfld_erase_cursor( me->fp1, SELECT_MCF );
      }
      break;

    case FI_ACCEPT:
      FIfld_get_text(me->fp1,SELECT_MCF,0,0,MAXPATHLEN,
      		text_buff,&sf,&rp);
      if ( text_buff[0] == 0 ) 
      {
        me->selected_part[0] = 0;
      	FIg_set_text( me->fp1, FI_MSG_FIELD, "Select part to place");
      	break;
      }

      FIg_get_text( me->fp1, DIR_NAME, tempname);
      strcat( tempname, "/");
      strcat( tempname, text_buff);
      strcpy( me->selected_part, tempname );
      FIg_set_text(me->fp1,FI_MSG_FIELD,"Reading partdata...");
      sts = om$send(msg = message ECPlPrt.get_default_attrs(
                                                     msg),
                    targetid = my_id);
      if(!(sts & *msg & 1))
      {
         me->selected_part[0] = 0;
         FIg_set_text(me->fp1, FI_MSG_FIELD, "Selected file is not a filepart");
      }
      else
      {
        int	rsp = EX_FORM_FINISHED;
        long stat;

        FIg_set_text(me->fp1,FI_MSG_FIELD,"");
        FIf_erase( me->fp1 );
        me->form_displayed = 0;
  
        ex$putque(msg = &stat, response = &rsp);
      }
      break;

    case FI_CANCEL:
      FIf_erase(me->fp1);
      FIf_delete(me->fp1);
      me->fp1 = NULL;
      me->selected_part[0] = 0;
      {
        int	rsp = EX_RJT_MOVEON;
        long stat;
  
      	ex$putque(msg = &stat, response = &rsp);
      }
      break;
    }
    return(OM_S_SUCCESS);
}

method execute( int *response; char *response_data; int pos )
{
  IGRlong      msg, rc;
  IGRint                  i, om_msg, sizbuf, old_sys_mode, status;
  struct GRmd_env         mod_env;
  struct GRid             part_id, inst_id, windid, cnstid;
  IGRint                  props;
  IGRdouble               accept_point[3];
  struct GRevent          cr_event;
  IGRchar      buffer[256], filename[256];
  enum GRdpmode           disp_mode;
  IGRint nbytes = sizeof(struct GRevent);
  
  IGRboolean aflag;
    if(aflag =  pwIsActivationOn() )
    {
     ex$message (in_buff="Deactivate the activated part",
                 field=ERROR_FIELD);
     *response = TERMINATE;
     return (OM_S_SUCCESS);
    }  
    /*
     * Get the current module enviroment.
     */  
    sizbuf = sizeof( struct GRmd_env );
    gr$get_module_env(msg = &msg,
                      sizbuf = &sizbuf,
                      buffer = &mod_env );

    om_msg = OM_S_SUCCESS;
    msg = MSSUCC;

    /*
     * Goto the appropriate state.
     */                
    switch (me->state)
    {
      /*
       * (Re)initialize the command.
       */
      case START:
        if (ME.super_cmd->mytype == CREATE_PART)
        {
          /** Qeury for Filename **/
          status = co$getevent( msg = &rc,
                                prompt = "Enter Filename",
                                event_mask = GRm_STRING,
                                response = response,
                                response_data = response_data,
                                event = &cr_event);

          if (cr_event.response == EX_STRING)
          {
            if (strlen(cr_event.event.keyin) == 0)
            {
               ex$message(field = ERROR_FIELD,
                          msgnumb = EMS_E_NoFileSpecified,
                          time = 3);

               ex$message(field = ERROR_FIELD,
                          msgnumb = EMS_I_ClearStatusField);

               me->state = START;
               break;
            }
            strcpy(filename, cr_event.event.keyin);

            /* bloody kludge until we find out the right fix to avoid
             * cmdserver from grabbing the string entered as a command.
             */
            response_data[0] = '\0';

            /*Intentional block to set scope*/
            {
               char curr_file[2048];
               char cur_file_name[2048];
               char *tmpptr;

               om$os_number_to_name ( osnum = EX_active_OS_num,
                                      osname = cur_file_name);  
               tmpptr = strrchr(cur_file_name,'/');
               if(tmpptr != NULL)
               {
                 tmpptr++;
                 strcpy(curr_file, tmpptr);
               }
               if (!strcmp(curr_file,filename) || (access(filename, 0) == 0))
               {
                  ex$message(field = ERROR_FIELD,
                             msgnumb = GR_E_FileExists,
                             time = 3);
                  ex$message(field = ERROR_FIELD,
                             msgnumb = EMS_I_ClearStatusField);
                  me->state = START;
                  break;
               }
             }
             strcpy(me->selected_part, filename);
             me->state = CREATE_PART_FILE;
             break;
           }
           else
             if (*response == EX_CMD_KEY)
             {
                return(OM_S_SUCCESS);
             }
             else
               if (*response == EX_RJT_MOVEON) 
               {
                 ex$message(field = ERROR_FIELD,
                            msgnumb = EMS_E_NoFileSpecified,
                            time = 3);
                 ex$message(field = ERROR_FIELD,
                            msgnumb = EMS_I_ClearStatusField);

                 me->state = START;
                 break;
               }
               else
               {
                  *response = TERMINATE;
                  me->state = FINISHED;
                  goto quit;
               } 
           }
           else
           {
             ex$message(msgnumb = EMS_P_EnterFormData,
                        buff = buffer);
             om_msg = co$getevent( msg = &msg,
                                   event_mask = ( GRm_FORM_FINISHED | 
                                                     GRm_RJT_MOVEON | 
                                                         GRm_STRING ),
                                   prompt = buffer,
                                   response = response,
                                   response_data = response_data,
                                   event = &cr_event );

             if( cr_event.response == EX_FORM_FINISHED )
                 me->state = PLCMNT_OPS;
             else 
               if( cr_event.response == EX_RJT_MOVEON )
               {
  	             if( me->active_form == 1 )
                 {
                   me->state = FINISHED;
                   *response = TERMINATE;
                 }
                 else
  	             {
                   FIf_set_cmd_oid_os(me->fp1, my_id, OM_Gw_current_OS);
                   FIf_display( me->fp1 );
                   me->active_form = 1;
                 }
               }
            }
            break;

  case PLCMNT_OPS:
      if( me->active_form != 2 )
      {    	
        om_msg = om$send( msg = message ECPlPrt.ECplcmnt_opts(&msg),
                          targetid = my_id );
        if( !( om_msg & msg & 1 )) 
        {
           if (!create_part_in_progress)
           {
              FIf_set_cmd_oid_os(me->fp1, my_id, OM_Gw_current_OS);
  	          me->active_form = 1;
  	          FIf_display( me->fp1 );
           }
           me->state = START;
  	       break;
  	    }
      }
      ex$message(msgnumb = EMS_P_EnterFormData,
                 buff = buffer);
      om_msg = co$getevent( msg = &msg,
                            event_mask = ( GRm_FORM_FINISHED | 
                                              GRm_RJT_MOVEON | GRm_STRING ),
                            prompt = buffer,
                            response = response,
                            response_data = response_data,
                            event = &cr_event );

      if( cr_event.response == EX_FORM_FINISHED )
      {
         me->state = CREATE_INST;
      }
      else 
        if( cr_event.response == EX_RJT_MOVEON)
        {
           if (!(create_part_in_progress))
           {
        	 FIf_set_cmd_oid_os(me->fp1, my_id, OM_Gw_current_OS);
             FIf_display( me->fp1 );
  	         me->active_form = 1;
           }
           me->state = START;
        }
      break;

        case CREATE_PART_FILE:

             
            /* Do a CopyOS here and create the new file*/
            status = rfCreateRefFile(&msg, me->selected_part);
            status = om$send(msg = message ECPlPrt.get_default_attrs(&msg),
                             targetid = my_id);
            me->state = PLCMNT_OPS;
            break;

         case CREATE_INST:
            if( ! me->selected_part[0] )
            {
  	          *response = TERMINATE;
  	          break;
            }
            /*
             * Get the Placement point, Moveon to Restart 
             */
            ex$message( msgnumb = EMS_P_EnterPlPoint,buff = buffer );
            om_msg = co$getevent( msg = &msg,
                                  event_mask = ( GRm_RJT_MOVEON | GRm_DATA ),
                                  prompt = buffer,
                  	              response = response,
                  	              response_data = response_data,
          	                      event = &cr_event );

            if( *response == DATA )
            {
                ex$message(field = ERROR_FIELD, 
                           msgnumb = EMS_I_PlPartinPrgs);
                accept_point[0] = cr_event.event.button.x;
                accept_point[1] = cr_event.event.button.y;
                accept_point[2] = cr_event.event.button.z;
                windid.objid = cr_event.event.button.objid;
                windid.osnum = cr_event.event.button.osnum;

                props = EM_REFERENCE_PART | EM_IN_BOM |
                                EM_DEFAULT_DISPLAY ;

                props = props & ~EM_REFPLANE_DISPLAYED;
                props = props & ~EM_HANDLE_DISPLAYED;

                if( EMbackgrnd_part )
                  props = props | EM_BACKGROUND;
                if(EMread_only_part)
                  props = props | EM_READONLY;

  	            {
  	              char pwd[1024], path[256], *ptr;
  	              struct EX_var_list ex_var[2];
  	              int var_size, bad_var;

                  EXgetcwd(pwd, 1023);
      
                  var_size = sizeof(path);
                  ex_var[0].var = EX_WORKING_DIR;
                  ex_var[0].var_value = path;
                  ex_var[0].num_bytes = &var_size;
      
                  ex_var[1].var = NULL;

                  om_msg = ex$global( var = &ex_var[0],
      		                          which_error = &bad_var );

                  /* If the pwd is same as the invocation directory
                   *remove the path from the filename - 10/04/94.
                   */
                  path[strlen(path)-1] = 0; /* remove "/" at the end */
                  if (!strcmp(pwd, path))
                  {
      	            ptr = strrchr(me->selected_part, '/');
      	            if(ptr)
      		            strcpy(me->selected_part, ptr+1);
                  }
      	
                  om_msg=asm$create_instance(msg = &msg,
                                             mod_env = &mod_env,
                                             filename = me->selected_part,
                                             type = props & EM_PART_TYPES,
                                             display=props & EM_DISPLAY_PROPS,
      		                                 behavior =props&EM_BEHAVIOR_PROPS,
                                             view = EMplacement_view,
                                             origin = accept_point,
                                             window_id = &windid,
                                             num_attributes=me->num_inst_attrs,
                                             attributes = me->inst_attrs,
                                             instance_id = &inst_id);
  	            }

                if( om_msg & msg & 1 )
                {
                    /* Display the part instance */
                    disp_mode = GRbd;
                    om_msg = om$send(msg = message GRgraphics.GRdisplay(
                                                          &msg,
                                                          &mod_env.md_env.matrix_type,
                                                          mod_env.md_env.matrix,
                                                          &disp_mode,
                                                          &mod_env.md_id),
                                      targetid = inst_id.objid,
                                      targetos = inst_id.osnum);

                    om_msg = asm$get_instance_part( msg = &msg,
                                                    instance_id = &inst_id,
                                                    part_id = &part_id );

                    /* 
                     * If this is Create cmd, Make the part the active Part
                     */
                    if (ME.super_cmd->mytype == CREATE_PART)
                    {
                       struct GRid ref_id;
                       EMmemb memb;
                       struct IGRdisplay rfdisp;

                       om$send (msg = message EMdescribe.EMget_memb(&msg,
                                                   "reffile",
                                                   EM_GRAPHIC,
                                                   0,
                                                   &memb),
                                targetid = inst_id.objid,
                                targetos = inst_id.osnum);

                        ref_id.objid = memb.id.objid;
                        ref_id.osnum = memb.id.osnum;

                        /* Update the activation parameters */
                        UpdateActParams(ref_id);

                        /* Activate the Save buton */
                        rfDisplaySaveBtn(TRUE);

                        /* Activate the cursor */
                        rfDefineCursor();

                        /* get the ref.files symbology and the update the 
                         * form 
                         */
                        gr$get_active_display(buffer = &rfdisp);
                        gr$put_active_display(buffer = &rfdisp);
                        gr$get_active_layer(buffer = &rfdisp);
                        gr$put_active_layer(buffer = &rfdisp);

                    }

                    old_sys_mode = EMdesc_set_system_mode(TRUE);
                    for(i=0;i<me->num_inst_attrs;i=i+1)
                    {
                      if( !strcmp(me->inst_attrs[i].info.name,"itemno"))
  	                  {
                        om_msg=asm$mod_attribute(msg = &msg,
              	                                 id = &part_id,
              	                                 name = "itemno",
              	                                 attribute=&me->inst_attrs[i]);
#ifdef DEBUG
                        if( !(om_msg&msg&1) )
      	                   printf("Modify itemno failed\n");
#endif
                      }
                      if( !strcmp(me->inst_attrs[i].info.name,"quantity"))
                      {
                        om_msg=asm$mod_attribute(msg = &msg,
              	                                 id = &inst_id,
              	                                 name = "quantity",
              	                                 attribute=&me->inst_attrs[i]);

#ifdef DEBUG
      	if( !(om_msg&msg&1) )
      	printf("Modify quantity failed\n");
#endif
                      }
  	                }
                    EMdesc_set_system_mode(old_sys_mode);
                    om_msg = asm$instance_count( msg = &msg,
                                                 part_id = &part_id,
                                                 count = &sizbuf );

                    if(om_msg & msg & 1)
                    {
                      if(sizbuf == 1) /* First instance */
                      {
                        /* Check if this is the first part being
                         * placed.
                         */
                        om_msg = asm$part_count( msg = &msg,
                                                 type = EM_CACHED_PART | 
                                                        EM_LOCAL_PART,
                                                 count = &sizbuf );

                        if((om_msg & msg & 1) && (sizbuf == 1))
                        {
                          /* Ground first instance of first part */
                          om_msg = asm$add_constraint(msg = &msg,
                                                      instance2_id = &inst_id,
                                                      constraint_id = &cnstid);
           
                          if( !( om_msg & msg & 1 ))
                          {
                            ex$message( msgnumb = EMS_S_OpFail );
                          }
                          else
                          {
                            /*
                             * update the basis of the instance
                             */
                            om_msg = om$send( msg = message EMinstance.EMupdatebasis(&msg),
                                              targetid = inst_id.objid,
                                              targetos = inst_id.osnum );
#ifdef DEBUG
                            if( !(om_msg & msg & 1 ))
                            printf("EMupdatebasis failed\n");  
#endif
                          }
                        }

                        /* update the part display */
                        om_msg = asm$update_part_display(msg = &msg,
              	                                         part_id= &inst_id,
              	                                         mod_env=&mod_env);
                      }
                      ex$message(field = ERROR_FIELD,
                                 msgnumb = EMS_I_ClearStatusField);
                    }
                }
  	            else
                {
  	              ex$message(field = ERROR_FIELD,
                             msgnumb = EMS_E_OperationFailed);
                                     
  	              me->state = FINISHED;
  	              *response = TERMINATE;
                }
            }
            /* 
             * Reset the State to Start and display Main Form
             */

            if (ME.super_cmd->mytype != CREATE_PART)
            {
              FIf_set_cmd_oid_os(me->fp1, my_id, OM_Gw_current_OS);
              FIg_reset(me->fp1,FI_ACCEPT);
              FIf_display( me->fp1 );
              me->active_form = 1;
              me->form_displayed = 1;
              me->state = START;
            }
            else
            {
              me->state = FINISHED;
              *response = TERMINATE;
            }

      break;
    }
  
quit:
    return( OM_S_SUCCESS );
}

int plcmntops_form_notif( f_label, g_label, value, fp )
int  	f_label;
int  	g_label;
IGRdouble  	value;
Form  	fp;	
{
  IGRint   	status;
  IGRlong   msg_loc;
  GRobjid   cmdobj;
  GRspacenum   cmdos;

  status = FIf_get_cmd_oid_os (fp, &cmdobj, &cmdos);
  if(status)
    return (OM_E_ABORT);

  status = om$send (msg = message ECPlPrt.do_form2(&msg_loc, f_label,
      	                g_label, value),
    	            senderid = NULL_OBJID, 
    	            targetid = cmdobj,
    	            targetos = cmdos);
  if(! (status & 1))
  	 return (OM_E_ABORT);

   return(OM_S_SUCCESS);
}

method do_form2( IGRlong *msg; int form_label; int g_label; double value )
{
char text_buff[MAXPATHLEN];
int  sf,rp, i;
int  row, pos;
Form fp;
        
        fp = me->fp2;
  FIg_set_text(fp,FI_MSG_FIELD,"");
  switch( g_label )
  {
  	case INST_ATTR:
      FIfld_get_active_row( fp, g_label, &row, &pos );
      FIfld_get_text(fp,g_label,row,0,MAXPATHLEN,
      	   		text_buff, &sf,&rp);

      if( text_buff[0] && !strcmp( text_buff, "itemno" ) )
      {
      	if( !me->change_itemno )
      	{
      	    FIg_set_text(fp,FI_MSG_FIELD,"Cannot change itemno");
      	    sprintf(text_buff, "\"%s\"", me->itemno );
      	    FIfld_set_text(fp,g_label,row,1,text_buff,0);
      	}
      	else
      	{
  	            FIfld_get_text(fp,g_label,row,1,MAXPATHLEN,
      	        		text_buff, &sf,&rp);
      	    remove_quotes(text_buff);
      	    if(!EMitem_string_unique(text_buff))
      	    {
      		sprintf(text_buff, "\"%s\"", me->itemno );
      		FIfld_set_text(fp,g_label,row,1,text_buff,0);
      	    }
      	}
      }
      break;

  	case PLCMNT_VIEW:
      FIg_get_text( fp, PLCMNT_VIEW, EMplacement_view);
      break;

  	case PLCMNT_BY:
      FIg_get_text( fp, PLCMNT_VIEW, text_buff);
      if( !strcmp( text_buff, "Constraints" ) )
      	EMplacement_type = EM_CONSTRAINED;
      else
      	EMplacement_type = EM_VIEWALIGNED;
      break;

  	case BKGPRT_TOG:
                        FIg_get_state(fp,BKGPRT_TOG, &EMbackgrnd_part);
      break;

                case UPDATE_TOG:
      FIg_get_state(fp,UPDATE_TOG, &EMread_only_part);
      break;

  	case FI_ACCEPT:
      for ( i = 0; i < me->num_inst_attrs; i ++ )
      {
      	FIfld_get_text(fp,INST_ATTR,i,1,MAXPATHLEN,
                 text_buff, &sf,&rp);
      	remove_quotes( text_buff );
      	strcpy( me->inst_attrs[i].value.syntax, text_buff );
      }
      {
          int	rsp = EX_FORM_FINISHED;
      long 	stat;
  
      	ex$putque(msg = &stat, response = &rsp);
      }
      FIf_erase( me->fp2 );	
      FIf_delete( me->fp2 );
                        me->fp2 = NULL;
      me->form_displayed = 0;
      break;

  	case FI_CANCEL:
      FIf_erase( me->fp2 );	
      FIf_delete( me->fp2 );
            me->fp2 = NULL;
            
            if (!create_part_in_progress)
               FIg_reset(me->fp1,FI_ACCEPT);

      me->form_displayed = 0;
      {
          int	rsp = EX_RJT_MOVEON;
      long 	stat;
  
      	ex$putque(msg = &stat, response = &rsp);
      }
      break;
  }
  return( OM_S_SUCCESS );
}

method ECplcmnt_opts( IGRlong *rc ) 
{
int        sts, i;
char       buffer[256];

        *rc = MSSUCC;

  sts = FIf_new( 101, "EMPlcmntOpts", plcmntops_form_notif, &me->fp2);

  if (sts != FI_SUCCESS)
  {
  	fprintf (stderr, "FIf_new failed: sts = %d\n",sts);
                *rc = MSFAIL;
  	return( OM_E_ABORT );
  }

    FIf_set_cmd_oid_os(me->fp2, my_id, OM_Gw_current_OS);
        me->active_form = 2;

        /* Set the Form gadgets to the globals */

  if( EMplacement_type == EM_VIEWALIGNED )
  	FIg_set_text( me->fp2, PLCMNT_BY, "View Alignment" );
  else if( EMplacement_type == EM_CONSTRAINED )
  	FIg_set_text( me->fp2, PLCMNT_BY, "Constraints" );

  if( EMbackgrnd_part )
  	FIg_set_state_on( me->fp2, BKGPRT_TOG );
  else
  	FIg_set_state_off( me->fp2, BKGPRT_TOG );

        if(EMread_only_part)
  	FIg_set_state_on( me->fp2, UPDATE_TOG );
  else
  	FIg_set_state_off( me->fp2, UPDATE_TOG );

  if( EMplacement_view[0] != NULL )
  	FIg_set_text( me->fp2, PLCMNT_VIEW, EMplacement_view );
  for( i = 0; i < me->num_sv_ids; i++ )
  {
          FIfld_set_list_text(me->fp2,PLCMNT_VIEW,i,0,me->saved_views[i],FALSE);
  }

  for( i = 0; i < me->num_inst_attrs; i++ )
  {
      	FIfld_set_text(me->fp2,INST_ATTR,i,0,me->inst_attrs[i].info.name,0);
  	if( me->inst_attrs[i].value.type == EM_STRING )
      sprintf( buffer, "\"%s\"", me->inst_attrs[i].value.syntax);
  	else
  	{
      EMrem_syntax_lhs( me->inst_attrs[i].value.syntax, buffer );
  	}
  	FIfld_set_text(me->fp2,INST_ATTR,i,1,buffer,0);
  }    

  FIf_display( me->fp2 );

  return ( OM_S_SUCCESS );
}

method get_default_attrs( IGRlong *rc )
{
  struct  GRid partid;
  int     sts,i,fileno,flag;
  long    msg;

  long    count,num;
  IGRchar buffer[256];
  struct  GRid sv_ids[20];
  struct  var_list var[2];

  if( !(get_filepart_id( me->selected_part, &partid, &fileno, &flag ) ))
  {
  	/* printf("given file is not a filepart\n");*/
                ex$close_module(ftype = EX_invisible, index = fileno);
  	return( OM_E_ABORT );
  }
  	
  sts = asm$attribute_count( msg = &msg,
             id = &partid,
             type = EM_INSTANCE_ATTR | EM_COMMON_ATTR,
             count = &me->num_inst_attrs );
  if( !( sts & msg & 1 ) )
  {
#ifdef DEBUG
  	printf("attribute count failed\n");
#endif
  	return( OM_E_ABORT );
  }

        if(me->inst_attrs)
         free(me->inst_attrs);
  me->inst_attrs = ( EMattr * )malloc( sizeof( EMattr ) * me->num_inst_attrs );

  for( i = 0 ; i < me->num_inst_attrs; i++ )
  {
/* added EM_COMMON_ATTR to facilitate "itemno" to be part of inst_attrs - kk */
  	sts = asm$get_attribute (msg = &msg,
  	                         id = &partid,
      		 type = EM_INSTANCE_ATTR | EM_COMMON_ATTR,
  	                         index = i,
  	                         attribute = &me->inst_attrs[i]);
  	if( !(sts & msg & 1 ))
  	{
#ifdef DEBUG
  	  	printf("Error getting attribute at %d\n",i);
#endif
      continue;
  	}
  	if( !strcmp( me->inst_attrs[i].info.name, "itemno" ) )
  	{
      me->change_itemno = generate_itemno( &partid, &me->itemno );
  	        strcpy( me->inst_attrs[i].value.syntax,me->itemno );
  	}
  	if( !strcmp( me->inst_attrs[i].info.name, "quantity" ) )
  	{
      if( !strlen( me->inst_attrs[i].value.syntax ))
      {
      	strcpy( me->inst_attrs[i].value.syntax,"1" );
      	me->inst_attrs[i].value.data.i = 1;
      }
  	}
  }
  /* Get the saved views in the part file */
        me->num_sv_ids = 0;
        {
          struct GRid mod_id;
          mod_id.osnum = partid.osnum;
          ex$get_modid(mod_osnum = mod_id.osnum,
                       mod_id = &mod_id.objid);
                         
          dp$get_gragad_id(msg = &msg,
                           mod_GRid = &mod_id, 
                           name = "*",
                           numberofids = &count,
                           array_size = 20,
                           found_GRids = sv_ids);

          var[0].var = GRAGAD_NAME;
          var[0].num_bytes = sizeof(char) * DI_PATH_MAX;
          var[0].var_ptr = buffer;
          var[0].bytes_returned = &num;
          var[1].var = END_PARAM;

          if((1& msg) && count)
           {
              for(i=0; i < count; i++)
               {
                    dp$inq_set_gragad(msg = &msg,
                                      osnum = mod_id.osnum,
                                      gragad_objid = sv_ids[i].objid,
                                      which_error = &msg,
                                      var_list = var);
                   if(1&msg)
                    {
                       strcpy(me->saved_views[me->num_sv_ids],buffer);
                       me->num_sv_ids++;
                    }
               }
           }

          count = 0;
        }
        
        dp$total_num_saved_vw (msg = &msg,
                               total_num = &count,
                               osnum = &partid.osnum);

        if (count)
        {
            
            dp$get_saved_vw_id(msg = &msg, 
                               osnum = partid.osnum,
                               name = "*",
                               numberofids = (IGRlong *)&count,
                               found_GRids = sv_ids,
                               array_size = 20, 
                               total_num = &count);
            
            var[0].var = SAV_VW_NAME;
            var[0].num_bytes = sizeof(char) * DI_PATH_MAX;
            var[0].var_ptr = buffer;
            var[0].bytes_returned = &count;
            var[1].var = END_PARAM;

            for (i=0; i<count; i=i+1)
            {
                buffer[0] = '\0';
                
                dp$inq_set_saved_view (msg = &msg,
                                       inq0_set1 = 0,
                                       osnum = partid.osnum,
                                       vw_objid = sv_ids[i].objid,
                                       which_error = &msg,
                                       var_list = var);
                
                if (buffer[0] != '\0')
                {
      strcpy( me->saved_views[me->num_sv_ids], buffer );
      me->num_sv_ids++;
                }
            }
        }
  if( me->saved_views[0][0] )
  	strcpy( EMplacement_view, me->saved_views[0] );
  else
  	strcpy( EMplacement_view, "front");

        /* Save the module if the part definition is created now */
        ex$close_module( ftype = EX_invisible, flag = flag, index = fileno );
  
  *rc = MSSUCC;
  return( OM_S_SUCCESS );
}

/** Look for an existing instance of part with the given number & revision,
    if found, return its itemno and return 0(cannot change), otherwise 
    increment the system itemno and return the default and return 1
**/

int generate_itemno( partid, itemno )
struct GRid *partid;
char **itemno;
{
  long   om_msg, msg;
  EMattr  lattr;
  EMattr  number, revision;
  struct  GRid loc_pid;

        /*
         * Get the number and revision of the part
         */
        om_msg = asm$get_attribute( msg = &msg,
                                    name = "number",
                                    attribute = &number,
                                    id = partid );

        om_msg = asm$get_attribute( msg = &msg,
                                    name = "revision",
                                    attribute = &revision,
                                    id = partid );
        /*
         * Try to find the part in the assembly directory. 
         */
  loc_pid.objid = NULL_OBJID;
        om_msg = asm$get_part (msg = &msg,
            type = EM_CACHED_PART,
                              number = number.value.syntax,
                              revision = revision.value.syntax,
                              part_id = &loc_pid);

  if( (om_msg & msg & 1) && (loc_pid.objid != NULL_OBJID) ) /* Found the part with given number & rev */
  {     
  	om_msg = asm$get_attribute( msg = &msg,
      		type = EM_COMMON_ATTR,
      		name = "itemno",
      		attribute = &lattr,
      		id = &loc_pid );
  	if( om_msg & msg & 1 )
  	{
                        *itemno = (char *)malloc( strlen( lattr.value.syntax ) + 1 );
                        strcpy( *itemno, lattr.value.syntax );
      return( 0 ); /* Donot allow to change itemno */
  	}
  }

        EMnext_itemno_attribute(&msg, NULL, &lattr);
        *itemno = (char *)malloc( strlen( lattr.value.syntax ) + 1 );
        strcpy(*itemno, lattr.value.syntax);

  return( 1 ); /* Can change the generated itemno */
}

end implementation ECPlPrt;
