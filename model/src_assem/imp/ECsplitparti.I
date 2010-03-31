
/*

   Name
        ECsplitpart   - Save Element to File.

   Decsription

        This command object drives the Save Element to File. More efficient
      method of saving data to another file. Permits adding data to existing
      file. Automatically copies all associative parents to maintain the
      associativity.

   History

      Gang   07/28/93    Creation.
      bbkr   11/11/96    Modified as create_part = FALSE TR#119602864

*/ 

class implementation ECsplitpart;

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


enum states {LOC_ELEMENT,
             GET_FILE,
             FILE_EXIST,
             EXE_SPLIT
             };

/* define constants */

#define Null ((char *)NULL)

#ifdef TRACE
#define trace(x) x
#else
#define trace(x)
#endif

/* define error codes */

#define ASM_INVALID_SEEDFILE 2

/* define form gadgets */

#define SEEDFILE 13
#define DELETE 15


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
               Interface function between C-form and CO
 *~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

ECsplit_router(form_label,label,value,form_ptr)
int form_label,label;
double value;
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
   status = om$send(msg = message ECsplitpart.form_notification
				    (form_label,label,value,form_ptr,TRUE),
		  senderid = NULL_OBJID,
		  targetid = cmd_obj.objid,
		  targetos = cmd_obj.osnum);
   as$status();
  }
quit:
 return(1);
}


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
                                  init
 *~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method init (int type; char *string_ptr )
{
 int status;

 status = om$send(msg = message COpara.init(type,string_ptr),
		   targetid = my_id,
		   mode = OM_e_wrt_message);

  /* Initialize instances */

  me->num_obj = 0;
  me->split_form_ptr = NULL;
  me->filename[0] = NULL;
  me->seedfile[0] = NULL;
  me->delete = FALSE;

  me->state = LOC_ELEMENT;

  return(status);
}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
                               wakeup
 *~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method wakeup ( IGRint n )
{
 int status;
 ex$message( field = 1,msgnumb = EM_M_SaveElement ); 
 ex$message(field = ERROR_FIELD,msgnumb = GR_P_Clear);

 status = om$send(msg = message COpara.wakeup(n),
		  targetid = my_id,
		  mode = OM_e_wrt_message);

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

 status = om$send(msg = message COpara.delete(n),
		  targetid = my_id,
		  mode = OM_e_wrt_message);

 GRstatus_display_button(0);
 return(status);
}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*

  GRcheck_invalid_chars

      This function will check for the invalid characters in the EMS
    filename. It will return TRUE if the give filename has invalid
    characters, FALSE if not. Following characters are not valid in the
    EMS filename.
      { + - [] ? * : }

 *~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
          
IGRboolean GRcheck_invalid_chars(filename)
IGRchar *filename;
{
  IGRlong i;
  IGRboolean status;
  IGRchar *file;

  file = NULL;
  status = FALSE;

   file = strrchr(filename,'/');
   if(!file)
    {
      file = filename;
    }

   for(i=0; i < strlen(file); i++)
     { 
        switch(file[i])
         {
            case '+' :
            case '-' :
            case '[' :
            case ']' :
            case '?' :
            case '*' :
            case ':' :
            case ' ' :
            case '\\':
                   status = TRUE;
                   break;
         } 
     }

   return(status);
}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
                              execute
 *~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method execute ( int *response;
                 char *response_data;
                 int  pos)
{
  int n_obj,i;
  int done,object_located;
  IGRlong mask1,mask2;
  IGRlong msg;
  IGRlong rc;
  IGRlong sts;
  IGRboolean create_part;
  struct GRid *objects;
  struct GRevent event;
  char buf[DI_PATH_MAX];
  char active_file[OM_K_MAXOSNAME_LEN];
  char title[32];
  char *file;
  OMuword classid;
  OM_S_CLASSLIST classes;
  IGRlong display_flag;

  n_obj = 0;
  buf[0] = NULL;
  msg = MSSUCC;
  done = FALSE;
  objects = NULL;
  sts = 0;
  object_located = FALSE;

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
                              event1 = &me->event1,
                              event2 = &me->event2,
                              event3 = &me->event3,
                              mask1 = mask1,
                              mask2 = mask2,
                              display_flag = display_flag,
                              response = response,
                              response_data = response_data,
                              hilight_mode = GRhd,
                              unhilight_mode = GRhe,
                              locate_key = GR_P_IdEle,
                              acc_key = GR_P_Acc,
                              relocate_key = GR_I_EleNotFound,
                              attributes = &me->attr,
                              stack = &me->locate_stack,
                              eligible_classes = &classes);

           if(rc != LC_OBJ_LOCATED)
             {
                 goto quit;
             }

            as$start_fence(set = &(me->event3.located_object[0].located_obj),
                           response = (IGRlong *)response,
                           response_data = response_data,
                           nb_obj = &n_obj,
                           p_obj = &objects);

           if(n_obj == 0)
            {
              goto quit;
            }

           sts = om$vla_set_dimension(varray = me->obj_list,
                                        size = n_obj);
           if(!(1&sts))
             {
               trace(printf("vla_set_dimension failed\n"));
               msg = MSFAIL;
               goto quit;
             }
           me->num_obj = n_obj;
           
             if(!objects)
              {
                 goto quit;
              }

             for(i =0; i < n_obj; i++)
               {
                  trace(printf("obj%d: %d\n",i,objects[i].objid));
                  me->obj_list[i].objid = objects[i].objid;
                  me->obj_list[i].osnum = objects[i].osnum;
               }
                              
             ASend_fence();
                     
             me->state = GET_FILE;
             break;

      case GET_FILE:  
            ex$message(field = ERROR_FIELD,msgnumb = GR_P_Clear);
            co$getevent(msg = &msg,
                        event_mask = GRm_STRING,
                        msgnum = GR_P_EntFil,
                        response = response,
                        response_data = response_data,
                        event = &event);

             if  ( event.response == STRING )
              {
                 strcpy ( me->filename, event.event.keyin );
		 if(me->filename[0] == NULL)
		  {
		    me->state = GET_FILE;
		    break;
		  }
                 if(access(me->filename,0) != -1)
		  {
		    ex$filename(name = active_file,
				len = OM_K_MAXOSNAME_LEN);
                    ACpath_to_file(me->filename,buf);
                    if(!(strcmp(buf,active_file)))
		     {
                         ex$message( msgnumb = EX_S_CurrFile,
                                     buff = buf,
                                     buffer_size = DI_PATH_MAX); 
                       
                         ex$message(msgnumb = EX_P_NoticeTitle,
                                    buff = title,
                                    buffer_size = 32);

                         FI_msg_box2(title,FI_BLACK,buf,FI_BLACK);
                         me->state = GET_FILE;
		     }
                    else
                      me->state = FILE_EXIST;
                  }
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

                         me->state = GET_FILE;
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

                            me->state = GET_FILE;
                          }
                         else
                          {
                             me->state = EXE_SPLIT;
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
            co$getevent(msg = &msg,
                        event_mask = GRm_TEXT_VALUE,
                        msgnum = GR_P_FlExOv,
                        response = response,
                        response_data = response_data,
                        event = &event);

            if (event.response == STRING)
            {
              if ( !(strcmp(event.event.keyin, "y")) ||
                   !(strcmp(event.event.keyin, "Y")) )
              {
                me->state = EXE_SPLIT;
              }
              else if ( !(strcmp(event.event.keyin, "n")) ||
                        !(strcmp(event.event.keyin, "N")) )
              {
                me->state = GET_FILE;
              }
              else
                me->state = FILE_EXIST;

            }
            else
            {
              goto quit;
            }
            break;

    case EXE_SPLIT:
          ex$message(field = ERROR_FIELD, msgnumb = EMS_M_SaveElemProgress);
	  create_part = FALSE;
          sts = ASMSplitPart(&msg,&(me->event3.located_object[0].module_info),
                             me->obj_list,&(me->num_obj),me->filename,
                             me->seedfile,&(me->delete), &create_part);

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

                   me->state = GET_FILE;
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
            if(me->delete)
              dp$update(msg = &msg);
            me->state = LOC_ELEMENT;
            break;

    }
  }

quit:
  return(OM_S_SUCCESS);
}

method status_disp()
{
  IGRlong sts;
  IGRint FORM=0;
  sts = MSSUCC;

  if(me->split_form_ptr == NULL)
   {
      FIf_new( FORM, "EMSaveElem", ECsplit_router, &me->split_form_ptr);
      if(me->split_form_ptr == NULL)
       {
         printf("Failed to create status display form\n");
         goto quit;
       }

     FIf_set_cmd_oid_os(me->split_form_ptr,my_id,OM_Gw_current_OS);
   }

  FIf_reset(me->split_form_ptr);
  FIf_display(me->split_form_ptr);

quit:
  return(sts);
}

method form_notification(int f_label,g_label;double value;char *fp;
                         int init_notif)
{
  IGRlong sts;
  IGRint i,sel,del_state;
  IGRchar buf[DI_PATH_MAX];
  i = 0;
  sel = 0;
  del_state = 0;
  buf[0] = NULL;
  sts = OM_S_SUCCESS;

  switch(g_label)
   {
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
          FIfld_get_text(fp,SEEDFILE,0,0,DI_PATH_MAX,me->seedfile,&sel,&i);

          FIg_get_state(fp,DELETE,&del_state); 
          if(del_state == 1)
           {
             me->delete = TRUE;
           }

          FIf_erase(fp);
          break;

     case FI_CANCEL:
          FIf_erase(fp);
          break;

   }

   return(sts);

}

end implementation ECsplitpart;
