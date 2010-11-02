/*

   Name
        ECsplitlprt   - Split Local Part ( Convert Local Part to File Part )

   Decsription

        This command object drives the Split Local Part. A local part
        can be converted into a standard file part by saving the local
	part graphics to a file and reattaching the new file part to
	the assembly.

   History

      Gang   03/01/94    Creation.

*/ 

class implementation ECsplitlprt;

#include "stdio.h"
#include "string.h"
#include "exdef.h"
#include "exmacros.h"
#include "madef.h"
#include "coparamac.h"
#include "DIdef.h"
#include "DItypedef.h"
#include "DIprims.h"
#include "DIglob.h"
#include "DImacros.h"
#include "FI.h"
#include "dpmacros.h"
#include "OMprimitives.h"
#include "OMminimum.h"
#include "OMmacros.h"
#include "dpstruct.h"
#include "igewindef.h"
#include "igewinmacros.h"
#include "lcdef.h"
#include "lcmacros.h"
#include "igetypedef.h"
#include "griodef.h"
#include "griomacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "emsdef.h"
#include "asdef.h"
#include "AS_status.h"
#include "execmsg.h"
#include "grmsg.h"
#include "EC_I.h"
#include "EC_M.h"
#include "EC_P.h"
#include "assemdef.h"
#include "assem.h"
#include "asmprtmac.h"
#include "assemmacros.h"


enum states {LOC_ELEMENT,
             SHOW_FORM,
             FILE_EXIST,
             GET_VIEW,
             EXE_SPLIT
             };
#define FINISHED -1

/* define constants */

#define Null ((char *)NULL)

#ifdef TRACE
#define trace(x) x
#else
#define trace(x)
#endif


/* define error codes */

#define ASM_INVALID_SEEDFILE 2

/* define main form gadgets */

#define STATIC_ATTRS  12
#define FILENAME      15
#define SEEDFILE      18
#define DYN_ATTRS     19
#define SEARCH        20
#define DELETE        21
#define PLACE_PART    26

/* define status form gadgets */

#define OPTIONS_FIELD 12
#define TITLE_FIELD 11

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
               Interface functions between C-forms and CO
 *~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
typedef double IGRdouble;

ECsplit_local_router(form_label,label,value,form_ptr)
int form_label,label;
IGRdouble value;
char *form_ptr;
{
 int status;
 struct GRid cmd_obj;
 FIf_get_cmd_oid_os(form_ptr,&cmd_obj.objid,&cmd_obj.osnum);
 if(cmd_obj.objid == NULL_OBJID)
  {
     goto quit;
  }
 else
  {
   status = om$send(msg = message ECsplitlprt.split_form_notify
				    (form_label,label,value,form_ptr,TRUE),
		  senderid = NULL_OBJID,
		  targetid = cmd_obj.objid,
		  targetos = cmd_obj.osnum);
  }
quit:
 return(1);
}

ECsplit_status_router(form_label,label,value,form_ptr)
int form_label,label;
IGRdouble value;
char *form_ptr;
{
 int status;
 struct GRid cmd_obj;
 FIf_get_cmd_oid_os(form_ptr,&cmd_obj.objid,&cmd_obj.osnum);
 if(cmd_obj.objid == NULL_OBJID)
  {
     goto quit;
  }
 else
  {
   status = om$send(msg = message ECsplitlprt.status_form_notify
				    (form_label,label,value,form_ptr,TRUE),
		  senderid = NULL_OBJID,
		  targetid = cmd_obj.objid,
		  targetos = cmd_obj.osnum);
   as$status();
  }
quit:
 return(1);
}

static IGRlong ECshow_defaults(char *fp,
	        	       struct GRid *local_part)
{
  IGRlong msg,om_msg;
  IGRint  count,i;
  EMattr  attr1;
  IGRint  part_row, inst_row;
  IGRchar buffer[DI_PATH_MAX];

  if(!fp)
   {
     return(OM_E_ABORT);
   }

  om_msg = OM_S_SUCCESS;
  msg = MSSUCC;
  om_msg = asm$attribute_count(msg = &msg,
			       id = local_part,
			       count = &count);
  if(!(om_msg & msg & 1))
   {
     return(om_msg);
   }

  part_row = 0;
  inst_row = 0;

  for(i=0; i < count; i++)
    {
       om_msg = asm$get_attribute(msg = &msg,
				  id = local_part,
				  index = i,
				  attribute = &attr1);
       if(!(om_msg & msg & 1))
	{
	   return(om_msg);
        }

       if(attr1.info.type & EM_PART_ATTR)
	{
	   FIfld_set_text(fp,STATIC_ATTRS,part_row,0,attr1.info.name,FALSE);
	   FIfld_set_text(fp,STATIC_ATTRS,part_row,1,attr1.info.desc,FALSE);
	   if(attr1.value.type == EM_STRING)
	    {
	      sprintf(buffer,"\"%s\"", attr1.value.syntax);
	    }
	   else
            {
	      EMrem_syntax_lhs(attr1.value.syntax,buffer);
	    }

           FIfld_set_text(fp,STATIC_ATTRS,part_row,2,buffer,FALSE);

	   part_row += 1;
	}
       else
	if((attr1.info.type & EM_INSTANCE_ATTR) ||
	   (attr1.info.type & EM_COMMON_ATTR))
         {
	   FIfld_set_text(fp,DYN_ATTRS,inst_row,0,attr1.info.name,FALSE);
	   FIfld_set_text(fp,DYN_ATTRS,inst_row,1,attr1.info.desc,FALSE);
	   if(attr1.value.type == EM_STRING)
	    {
	      sprintf(buffer,"\"%s\"", attr1.value.syntax);
	    }
	   else
            {
	      EMrem_syntax_lhs(attr1.value.syntax,buffer);
	    }

           FIfld_set_text(fp,DYN_ATTRS,inst_row,2,buffer,FALSE);

	   inst_row += 1;
	 }
    }

  return(om_msg);
}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
                                  init
 *~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method init (int type; char *string_ptr )
{
 int status;
 IGRlong sts, msg;
 IGRint count = 0;

 status = om$send(msg = message COpara.init(type,string_ptr),
		   targetid = my_id,
		   mode = OM_e_wrt_message);

  /* Initialize instances */

  me->local_part.objid = NULL_OBJID;
  me->split_form_ptr = NULL;
  me->status_form_ptr = NULL;
  me->filename[0] = NULL;
  me->seedfile[0] = NULL;
  me->delete = FALSE;
  me->place_part = FALSE;
  me->view_id.objid = NULL_OBJID;
  me->num_attrs = 0;

  sts = asm$part_count(msg = &msg,
                       type = EM_LOCAL_PART,
		       count = &count);
  if(count)
   me->state = LOC_ELEMENT;
  else
   me->state = FINISHED;

  return(status);
}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
                               wakeup
 *~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method wakeup ( IGRint n )
{
 int status;
 ex$message( field = 1,in_buff = "Split Local Part" ); 
 ex$message(field = ERROR_FIELD,msgnumb = GR_P_Clear);

 status = om$send(msg = message COpara.wakeup(n),
		  targetid = my_id,
		  mode = OM_e_wrt_message);

 if((me->state == SHOW_FORM) && (me->split_form_ptr))
  {
    FIf_display(me->split_form_ptr);
  }

 GRstatus_display_button(1);
 return (status);
}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
                                    sleep                                       
 *~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method sleep ( IGRint n )
{
  int status;

  if(me->split_form_ptr)
    FIf_erase(me->split_form_ptr);
  if(me->status_form_ptr)
    FIf_erase(me->status_form_ptr);

  status = om$send(msg = message COpara.sleep(n),
                   targetid = my_id,
      	           mode = OM_e_wrt_message);
  return (status);
}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
                               delete
 *~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method delete(int n)
{
 int status;

 if(me->split_form_ptr)
  {
    FIf_delete(me->split_form_ptr);
  }

 if(me->status_form_ptr)
  {
    FIf_delete(me->status_form_ptr);
  }

 status = om$send(msg = message COpara.delete(n),
		  targetid = my_id,
		  mode = OM_e_wrt_message);

 GRstatus_display_button(0);
 return(status);
}


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
                              execute
 *~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method execute ( int *response;
                 char *response_data;
                 int  pos)
{
  int n_obj;
  int done,object_located;
  IGRlong mask1,mask2;
  IGRlong msg;
  IGRlong rc;
  IGRint  FORM = 0;
  IGRlong sts;
  struct GRid gr_id;
  char buf[DI_PATH_MAX];
  char title[32];
  char *file;
  OMuword classid;
  OM_S_CLASSLIST classes;
  IGRlong display_flag;
  IGRshort prev_state;
  struct GRevent event1,event2,event3;

  n_obj = 0;
  buf[0] = NULL;
  msg = MSSUCC;
  done = FALSE;
  sts = OM_S_SUCCESS;
  object_located = FALSE;

  if(me->state == FINISHED)
   {
     ex$message(field = ERROR_FIELD, in_buff = "Local Parts Not Defined");
     sts = OM_E_ABORT;
     *response = TERMINATE;
     return(sts);
   }

  me->attr.properties =   LC_RW | LC_LC_ONLY | LC_DP_ONLY;
  me->attr.owner_action = LC_GEOM_MOD|LC_ASSOCIATIVE|LC_EXTERN_CONSTRAINED|
                          LC_REF_HEADER;
  mask1 = mask2  = GRm_DATA | GRm_STRING |GRm_RESET | GRm_BACK_UP|
                   GRm_SPECIFIED_OBJ|GRm_FORM_FINISHED;

  om$get_classid(classname = "GRgraphics",
                  p_classid = &classid);
  classes.p_classes = &classid;
  classes.w_count = 1;
  classes.w_flags = OM_CLST_subclass;

  display_flag = ALL_WINDOWS|ELEM_HILIGHT| LC_ERASE_LOC_ELEMENT |
                 NO_PROJ_ACCEPT_POINT;

  while(!done)
  {
    switch(me->state)
    {
      case LOC_ELEMENT :

             n_obj = 0;
             sts = lc$locate( rc = &rc,
                              event1 = &event1,
                              event2 = &event2,
                              event3 = &event3,
                              mask1 = mask1,
                              mask2 = mask2,
                              display_flag = display_flag,
                              response = response,
                              response_data = response_data,
                              hilight_mode = GRhd,
                              unhilight_mode = GRhe,
                              locate_prompt = "Identify Local Part",
                              acc_key = GR_P_Acc,
                              relocate_prompt = "Local Part not found",
                              attributes = &me->attr,
                              stack = &me->locate_stack,
                              eligible_classes = &classes);

           if(me->local_part.objid == NULL_OBJID)
	    {
              if(rc != LC_OBJ_LOCATED)
               {
                 goto quit;
               }
	      
              gr_id.objid = event3.located_object[0].located_obj.objid;
              gr_id.osnum = event3.located_object[0].located_obj.osnum;

              sts = EMget_localpart_frm_grid(&msg,&gr_id,NULL,&me->local_part);
            }

	   if(me->local_part.objid != NULL_OBJID)
	    {
              me->state = SHOW_FORM;
	      if(!me->split_form_ptr)
	       {
                  FIf_new( FORM, "EMSplitLocPrt", ECsplit_local_router,
			   &me->split_form_ptr);
                  if(me->split_form_ptr == NULL)
                   {
                      trace(printf("Failed to create split localpart form\n"));
                      sts = OM_E_ABORT;
                      *response = TERMINATE;
                      me->state = FINISHED;
                      return(sts);
                   }

	       }
              FIf_set_cmd_oid_os(me->split_form_ptr,my_id,OM_Gw_current_OS);
	      FIf_reset(me->split_form_ptr);
	      ECshow_defaults(me->split_form_ptr,&me->local_part);
	      FIf_display(me->split_form_ptr);
            }
	   else
	    {
	      /* print a message that located object is not belong to any
		 local part. */
              
	      me->state = LOC_ELEMENT;
	    }
           break;

      case SHOW_FORM:  
            ex$message(field = ERROR_FIELD,msgnumb = GR_P_Clear);
            ex$message(msgnumb = EMS_P_EnterFormData,
		       buff = buf);
            sts = co$getevent( msg = &msg,
                               event_mask = ( GRm_FORM_FINISHED | 
					      GRm_RJT_MOVEON | GRm_STRING ),
                               prompt = buf,
	         	       response = response,
			       response_data = response_data,
	   		       event = &event1 );

	    if( event1.response == EX_RJT_MOVEON )
	     {
	       me->local_part.objid = NULL_OBJID;
               me->state = LOC_ELEMENT;
	       goto quit;
	     }

	    if( event1.response == EX_FORM_FINISHED )
             {
                 if(access(me->filename,0) != -1)
                    me->state = FILE_EXIST;
                 else
                   {
                      if( GRcheck_invalid_chars(me->filename) )
                       {
                         ex$message( msgnumb = EX_F_InvalidFilename,
                                     type = "%s",
                                     var = `me->filename`,
                                     buff = buf,
                                     buffer_size = DI_PATH_MAX); 

                         ex$message(msgnumb = EX_P_NoticeTitle,
                                    buff = title,
                                    buffer_size = 32);

                         FI_msg_box2(title,FI_BLACK,buf,FI_BLACK);

			 FIf_display(me->split_form_ptr);
                         me->state = SHOW_FORM;
                       }
                      else
                       {
                         file = NULL;
                         file = strrchr(me->filename,'/');
                         if(file)  
                           file = &file[1];
                         else
                           file = me->filename;
                          
                         if(strlen(file) > 14)
                          {
                            ex$message( msgnumb = EX_F_MaxFileName,
                                        type = "%s",
                                        var = `me->filename`,
                                        buff = buf,
                                        buffer_size = DI_PATH_MAX); 

                            ex$message(msgnumb = EX_P_NoticeTitle,
                                       buff = title,
                                       buffer_size = 32);

                            FI_msg_box2(title,FI_BLACK,buf,FI_BLACK);

			    FIf_display(me->split_form_ptr);
                            me->state = SHOW_FORM;
                          }
                         else
                          {
                             me->state = GET_VIEW;
                          }
                       }
                   }
              }
             else
              {
                goto quit;
              }
             break;

     case FILE_EXIST:
            sts = co$getevent(msg = &msg,
                              event_mask = GRm_TEXT_VALUE,
                              msgnum = GR_P_FlExOv,
                              response = response,
                              response_data = response_data,
                              event = &event1);

            if (event1.response == STRING)
            {
              if ( !(strcmp(event1.event.keyin, "y")) ||
                   !(strcmp(event1.event.keyin, "Y")) )
              {
                me->state = GET_VIEW;
              }
              else if ( !(strcmp(event1.event.keyin, "n")) ||
                        !(strcmp(event1.event.keyin, "N")) )
              {
		FIf_display(me->split_form_ptr);
                me->state = SHOW_FORM;
              }
              else
                me->state = FILE_EXIST;
            }
            else
            {
              goto quit;
            }
            break;

    case GET_VIEW:
            sts = co$getevent(msg = &msg,
                              event_mask = GRm_DATA,
                              prompt = "Select placement view",
                              response = response,
                              response_data = response_data,
                              event = &event1);

            if (event1.response == EX_DATA)
	     {
	       me->view_id.objid = event1.event.button.objid;
	       me->view_id.osnum = event1.event.button.osnum;
	       me->state = EXE_SPLIT;
	     }
	    break;

    case EXE_SPLIT:
         ex$message(field = ERROR_FIELD, in_buff = "Split Local Part in progress...");
         ms$onoff(msg = &rc,
		 prevstate = &prev_state,
		 type = MS_OFF);

	 sts =  ASMConvLocPrt(&msg, &me->local_part,
			      me->filename, me->seedfile,
			      &me->num_attrs, me->attrs,
			      &me->view_id, me->delete,
			      me->place_part);

         ms$onoff(msg = &rc,
		 prevstate = &prev_state,
		 type = MS_ON);

         if(!(1&sts&msg))
          {
            if(msg == ASM_INVALID_SEEDFILE)
             {
                ex$message( msgnumb = EMS_E_InvSeedFile,
                            buff = buf,
                            buffer_size = DI_PATH_MAX); 

                ex$message(msgnumb = EX_P_NoticeTitle,
                           buff = title,
                           buffer_size = 32);

                FI_msg_box2(title,FI_BLACK,buf,FI_BLACK);

		if(me->split_form_ptr)
		 FIf_display(me->split_form_ptr);
                me->state = SHOW_FORM;
                break;
             }
            else
             {
                ex$message(field = ERROR_FIELD, 
                           msgnumb = EMS_E_OperationFailed);
                sts = OM_E_ABORT;
                *response = TERMINATE;
                me->state = LOC_ELEMENT;
                return(sts);
             }
           }

            ex$message(field = ERROR_FIELD, msgnumb = GR_P_Clear);
            if(me->delete || me->place_part)
              dp$update(msg = &msg);
            me->local_part.objid = NULL_OBJID;
	    me->view_id.objid = NULL_OBJID;
            me->state = LOC_ELEMENT;
            break;

    }
  }

quit:
  return(OM_S_SUCCESS);
}

method status_disp()
{
  IGRlong sts,msg;
  IGRint FORM=0;
  EMattr attr1, attr2;
  IGRint i,count;
  struct GRid part_id;
  IGRchar loc_part[DI_PATH_MAX];

  msg = MSSUCC;
  sts = OM_S_SUCCESS;
  count = 0;

  if(me->state == LOC_ELEMENT)
   {
     if(me->status_form_ptr == NULL)
      {
        FIf_new( FORM, "GRStatus", ECsplit_status_router, &me->status_form_ptr);
        if(me->status_form_ptr == NULL)
         {
           trace(printf("Failed to create status display form\n"));
           goto quit;
         }

        FIf_set_cmd_oid_os(me->status_form_ptr,my_id,OM_Gw_current_OS);
     }

     FIg_reset(me->status_form_ptr,OPTIONS_FIELD);
     FIfld_set_mode(me->status_form_ptr,OPTIONS_FIELD,0,FI_SINGLE_SELECT);
     FIg_erase(me->status_form_ptr,TITLE_FIELD);

     sprintf(loc_part,"Local Parts");
     FIg_set_text(me->status_form_ptr,TITLE_FIELD,loc_part);
     FIg_display(me->status_form_ptr,TITLE_FIELD);

     sts = asm$part_count(msg = &msg,
	                  type = EM_LOCAL_PART,
			  count = &count);
			  
     if(!(sts & msg & 1))
       goto quit;

     for(i=0; i < count; i++)
      {
	 sts = asm$get_part(msg = &msg,
			    type = EM_LOCAL_PART,
			    index = i,
			    part_id = &part_id);
         if(!(sts & msg & 1))
           goto quit;

	 sts = asm$get_part_identity(msg = &msg,
				     part_id = &part_id,
				     number = &attr1,
				     revision = &attr2);
         if(!(sts & msg & 1))
           goto quit;

         strcpy(loc_part,attr1.value.syntax);
	 strcat(loc_part," | ");
	 strcat(loc_part,attr2.value.syntax);

	 sts = asm$get_attribute(msg = &msg,
				 id = &part_id,
				 name = "description",
				 attribute = &attr1);
         if(sts & msg & 1)
	  {
	     strcat(loc_part," | ");
             strcat(loc_part,attr1.value.syntax);
	  }

         FIfld_set_text(me->status_form_ptr,OPTIONS_FIELD,i,0,loc_part,0);
      }

     FIf_display(me->status_form_ptr);
   }

quit:
  return(sts);
}

method status_form_notify(int f_label, g_label; double value; char *fp;
			  int init_notif)
{
  IGRlong msg, sts = OM_S_SUCCESS;
  IGRint resp,sel,pos,row;
  IGRchar buf[DI_PATH_MAX];
  struct GRid part_id;

  msg = MSSUCC;
  buf[0] = NULL;

    switch(g_label)
      {
	 case FI_ACCEPT:
	      FIf_erase(fp);
	      resp = EX_FORM_FINISHED;
	      ex$putque(msg = &msg, response = &resp);
	      break;

         case OPTIONS_FIELD :
	      row = (IGRint)value;
	      FIfld_get_text(fp,g_label,row,0,DI_PATH_MAX,buf,&sel,&pos);

              if(buf[0] != NULL)
	       {
		  sts = asm$get_part(msg = &msg,
				     type = EM_LOCAL_PART,
				     index = row,
				     part_id = &part_id);
                  if(sts & msg & 1)
		   {
		      me->local_part.objid = part_id.objid;
		      me->local_part.osnum = part_id.osnum;

	              FIf_erase(fp);
	              resp = EX_FORM_FINISHED;
	              ex$putque(msg = &msg, response = &resp);
		   }
	       }
	      break;
      }

  return(sts);
}

method split_form_notify(int f_label,g_label;double value;char *fp;
                         int init_notif)
{
  IGRlong sts,msg;
  IGRint i,j,sel,state;
  IGRchar buf[DI_PATH_MAX];
  IGRchar seedfile[DI_PATH_MAX];
  EMattr number, revision, *attribs;
  EMattr attr;
  IGRint num_attribs, response;
  IGRchar response_data[DI_PATH_MAX];
  IGRint pos, act_row, act_col,num_rows;
  IGRint num_stat_attrs, num_dyn_attrs; 
  IGRint num_attrs;


  i = 0;
  sel = 0;
  pos = 0;
  act_row = act_col = 0;
  num_rows = 0;
  state = 0;
  buf[0] = NULL;
  seedfile[0] = NULL;
  attribs = NULL;
  response_data[0] = NULL;
  sts = OM_S_SUCCESS;

  /* clear message field. */
  FIfld_set_text(fp,FI_MSG_FIELD,0,0,"",0);

  switch(g_label)
   {
     case SEARCH :
          FIf_erase(fp);
	  sts = ex$prtfile_form(title = "Local Parts",
				returned_filename = seedfile,
				number = &number,
				revision = &revision,
				attribs = &attribs,
				numattr = &num_attribs,
				response = &response,
				response_data = response_data);
          FIf_display(fp);
	  if(seedfile[0])
	   {
	     FIfld_set_text(fp,SEEDFILE,0,0,seedfile,0);
	   }

          FIg_set_state_off(fp,SEARCH);
	  break;

     case STATIC_ATTRS :
     case DYN_ATTRS    :
	  /* don't allow to change the name of the system attributes. */

          FIfld_get_active_row (fp, g_label, &act_row, &pos );
	  FImcf_get_active_col (fp, g_label, &act_col, &pos );
	  /*
	   * If an attribute name is removed, delete the row
           */
          buf[0] = 0;
	  if( act_col == 0 )
	    {
              FIfld_get_text (fp, g_label, act_row,0,256, buf, &sel, &pos);
	      if( act_row == 0 )
               {
                if((g_label == STATIC_ATTRS) && strcmp( buf,"number"))
                    FIfld_set_text( fp, g_label, 0, 0, "number", 0 );
                if((g_label == DYN_ATTRS) && strcmp( buf,"itemno"))
                    FIfld_set_text( fp, g_label, 0, 0, "itemno", 0 );
                break;
               }
              else if( act_row == 1 && g_label == STATIC_ATTRS)
               {
                if( strcmp( buf,"revision") )
                    FIfld_set_text( fp, g_label, 1, 0, "revision", 0 );
                break;
               }
              if( buf[0] == 0 )
	       {
                  FIfld_get_num_rows(fp,g_label,&num_rows);
                
	          for (i=act_row; i<num_rows-1; i=i+1)
                   {
                      for (j=0; j<3; j=j+1)
                       {
                    	  FIfld_get_text (fp, g_label, i+1, j, 256, buf,
					     &sel, &pos);
                          FIfld_set_text (fp, g_label, i, j, buf, FALSE);
       		       }       
                   }
                  for (i=0; i<3; i=i+1)
		    FIfld_set_text (fp,g_label, num_rows-1, i, "", FALSE);
  	       }
             }   
	    else 
	      if ((act_col == 2) && (act_row == 0) && (g_label == DYN_ATTRS))
	       {
                  FIfld_get_text (fp, g_label, 0, 2, 
              		                 256, buf, &sel, &pos);
	          /* Validate the itemno keyed in */
                  if (!EMitem_string_unique (buf))
                   {
                     FIg_set_text (fp, FI_MSG_FIELD, "Itemno not unique");
                     sts = EMnext_itemno_attribute (&msg, NULL, &attr);
                     if((sts & msg & 1))
                       sprintf( buf, "\"%s\"", attr.value.syntax);
                     FIfld_set_text (fp, DYN_ATTRS, 0, 2, buf, FALSE);
                   }
               }
	  break;

     case SEEDFILE :
          FIfld_get_text(fp,SEEDFILE,0,0,DI_PATH_MAX,buf,&sel,&i);
          if(buf[0] == NULL)
             FIfld_set_text(fp,FI_MSG_FIELD,0,0,"",0);
          else
            if(access(buf,0) == -1)
             {
               FIfld_set_text(fp,SEEDFILE,0,0,"",0);
               ex$message(msgnumb = GR_E_FlNotFnd, buff = buf);
               FIfld_set_text(fp,FI_MSG_FIELD,0,0,buf,0);
             }
            else
               FIfld_set_text(fp,FI_MSG_FIELD,0,0,"",0);
          break;

     case FI_ACCEPT :

          FIfld_get_text(fp,FILENAME,0,0,DI_PATH_MAX,me->filename,&sel,&i);
	  if(me->filename[0] == NULL)
	   {
              FIfld_set_text(fp,FI_MSG_FIELD,0,0,"Filename is not optional",0);
	      break;
	   }
          FIfld_get_text(fp,SEEDFILE,0,0,DI_PATH_MAX,me->seedfile,&sel,&i);

          FIg_get_state(fp,PLACE_PART,&state);
          if(state == 1)
           {
            char numb[MAX_VALUE], rev[MAX_VALUE];
            struct GRid part_id;

	      me->place_part = TRUE;
              numb[0] = rev[0] = 0;
	      /* Check if the part number/revision is unique  - 09/15/94 */
	      FIfld_get_text (fp, STATIC_ATTRS, 0, 2, MAX_VALUE,
				    numb, &sel, &pos);
	      FIfld_get_text (fp, STATIC_ATTRS, 0, 2, MAX_VALUE,
				    rev, &sel, &pos);

              if ((numb[0] == 0) || (rev[0] == 0)) 
              {
                 FIg_set_text(fp, FI_MSG_FIELD, "Keyin partnumber/revision");
                 break;
              }      
            
	      sts = asm$get_part(msg = &msg,
				     type = EM_PART_TYPES,
                                     number = numb,
                                     revision = rev,
				     part_id = &part_id);
              if (sts & msg & 1)
              {
                 FIg_set_text(fp, FI_MSG_FIELD, "Part Number/Revision not unique");
                 break;
              }      
           }
          FIg_get_state(fp,DELETE,&state); 
	  if(state == 1)
	   {
             me->delete = TRUE;
           }

          /* get the part attributes */
	  FIfld_get_num_rows(fp,STATIC_ATTRS, &num_stat_attrs);
	  FIfld_get_num_rows(fp,DYN_ATTRS, &num_dyn_attrs);
	  num_rows = num_stat_attrs + num_dyn_attrs;
	  sts = om$vla_set_dimension(varray = me->attrs,
				     size = num_rows);
          if(sts)
	   {
	      me->num_attrs = num_rows;
	      num_attrs = 0;

              for (i=0; i<num_stat_attrs; i=i+1)
		{
		    me->attrs[num_attrs].info.type = EM_PART_ATTR;
		    
		    FIfld_get_text (fp,
				    STATIC_ATTRS,
				    i, 0, MAX_VALUE,
				    me->attrs[num_attrs].info.name,
				    &sel, &pos);

		    if (me->attrs[num_attrs].info.name[0] != '\0')
		    {
			FIfld_get_text (fp,
					STATIC_ATTRS,
					i, 1, MAX_VALUE,
					me->attrs[num_attrs].info.desc,
					&sel, &pos);
			
			FIfld_get_text (fp,
					STATIC_ATTRS,
					i, 2, MAX_VALUE,
					me->attrs[num_attrs].value.syntax,
					&sel, &pos);

			if(remove_quotes( me->attrs[num_attrs].value.syntax ))
			    me->attrs[num_attrs].value.type = EM_STRING;
                        else
			    me->attrs[num_attrs].value.type = EM_DOUBLE;
			
			num_attrs = num_attrs + 1;
		    }
		}

              for (i=0; i<num_dyn_attrs; i=i+1)
		{
		    me->attrs[num_attrs].info.type = EM_INSTANCE_ATTR;

		    FIfld_get_text (fp,
				    DYN_ATTRS,
				    i, 0, MAX_VALUE,
				    me->attrs[num_attrs].info.name,
				    &sel, &pos);
		    
		    if (me->attrs[num_attrs].info.name[0] != '\0')
		    {
			if( !strcmp( me->attrs[num_attrs].info.name, "itemno") )
			    me->attrs[num_attrs].info.type = EM_COMMON_ATTR; 
		
			FIfld_get_text (fp,
					DYN_ATTRS,
					i, 1, MAX_VALUE,
					me->attrs[num_attrs].info.desc,
					&sel, &pos);
		
			FIfld_get_text (fp,
					DYN_ATTRS,
					i, 2, MAX_VALUE,
					me->attrs[num_attrs].value.syntax,
					&sel, &pos);

			if(remove_quotes( me->attrs[num_attrs].value.syntax ))
			    me->attrs[num_attrs].value.type = EM_STRING;
                        else
			    me->attrs[num_attrs].value.type = EM_DOUBLE;

			num_attrs = num_attrs + 1;
		    }
		}
           }
          FIf_erase(fp);

	  response = EX_FORM_FINISHED;
	  ex$putque(msg = &sts, response = &response);
          break;

     case FI_CANCEL:
          FIf_erase(fp);
	  response = EX_RJT_MOVEON;
	  ex$putque(msg = &sts, response = &response);
          break;

   }

   return(sts);

}

end implementation ECsplitlprt;
