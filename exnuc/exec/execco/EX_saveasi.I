class implementation EX_saveas;


#include "exsysdep.h"
#include <stdio.h>
#include <OMlimits.h>
#include <OMerrordef.h>
#include <exdef.h>
#include <ex.h>
#include <execmsg.h>
#include <exmacros.h>
#include <exms.h>
#include <msdef.h>
#include <msmacros.h>
#include <exproto.h>
#include <stdlib.h>
#include <string.h>
#if defined( NT )
#include <io.h>
#endif

#define debug  0

#ifdef SUNOS5
%undef sleep
#endif

from module import wake_up,sleep, GRmod_passon;
from OMFiledOS import write;
from cmdserver import sleep_cs;

extern struct module_params **module_data;
extern struct EX_invisible_module *invisible_table;
extern struct EX_visible_module *module_table;
extern struct EX_global EX_global_var;
extern OM_S_OBJID EX_exec_id;
extern uword EX_active_OS_num;


EXupdatable_exist ()
/*
  This function returns 1 if there is at least on updatable reference file.
*/
{
  int i, status;
  
  for (i = 0, status = 0; i < EX_MAX_INVIS_MODULES; i++)
    if (invisible_table [i].obj_space_num && (invisible_table [i].ref_flag == EX_ref))
      if (invisible_table [i].permis_flag == EX_read_write)
      {
        status = 1;
        break;
      }

  return status;
}


method execute(int *response; char *response_data; int pos)
{
  int result , active,status;
  int  use_current_file = 0;
  int goahead;
  char     string[OM_K_MAXOSNAME_LEN];
  char     fname[OM_K_MAXOSNAME_LEN];
  int prompt_status;
  
  ex$message(msgnumb = EX_M_SaveAs);
  if (EXupdatable_exist ())
  {
    ex$message ( msgnumb = EX_S_RefOver );
    prompt_status = ex$create_prompt(message_no = EX_P_Continue,
       left_prompt = EX_P_Yes,
       right_prompt = EX_P_No,
       response = response,
       response_data = response_data );
    if(*response == D_RESET)
    {
      response_data [0] = '\0';
      EX_init_keyboard();
      UI_echo(" ");
      goahead = FALSE;
    }
    else 
      if (*response == STRING)
        goahead = prompt_status == EX_LEFT_MATCH;
      else
        goahead = FALSE;
    if (!goahead)
      *response = TERMINATE;
  }
  else
    goahead = TRUE;
    
  if (goahead)
  {
    ex$message(msgnumb = EX_P_NewFileName,justification = RIGHT_JUS);
    string[0] = '\0';
    EX_get_input(response,response_data,0);
    if(*response == RESET)
    {
      response_data[0] = '\0';
      use_current_file = 1;
      strcpy(response_data,
          module_data[module_table[active_module_num].obj_space_num]->CS_OS_name);
      ex$message( msgnumb = EX_S_Var1, type="%s",var=response_data);
      ex$message(msgnumb = EX_P_Clear);
      if( module_table[active_module_num].permis_flag == EX_read_only)
      {
#ifndef NT
        sleep(2);
#else
        _sleep(2);
#endif
        ex$message(msgnumb = EX_F_ReadOnly);
        *response = TERMINATE;
      }
      else
      {
        goahead = TRUE;
      }
    }
    else if(*response == D_RESET)
    {
      response_data[0] = '\0';
      EX_init_keyboard();
      UI_echo(" ");
      *response = TERMINATE;
    }
    else if ( *response == STRING )
    {
  

      if(! EX_invalid_char_in_filename(response_data))
      {
        ex$message(msgnumb = EX_F_InvalidFilename,type ="%s%",
                                                 var=response_data);
        *response = TERMINATE;
        ex$message(msgnumb = EX_S_Clear);
        ex$message(msgnumb = EX_M_Clear);
  
        return 1;

      }
      status = EX_set_up_full_path_for_filename(response_data);
         if (status == EX_F_MaxPathFilename)
         {
         ex$message(msgnumb = EX_F_MaxPathFilename,type ="%s%",
                                                 var=response_data);
         *response = TERMINATE;
         ex$message(msgnumb = EX_S_Clear);
         ex$message(msgnumb = EX_M_Clear);
         return(OM_S_SUCCESS);
         }

         if (status == EX_F_MaxFileName)
         {
         ex$message(msgnumb =  EX_F_MaxFileName,type ="%s%",
                                                 var=response_data);
         *response = TERMINATE;
         ex$message(msgnumb = EX_S_Clear);
         ex$message(msgnumb = EX_M_Clear);
         return(OM_S_SUCCESS);
         }




      if( response_data[0] == '\0')
      {
        use_current_file = 1;
        strcpy(response_data,
            module_data[module_table[active_module_num].obj_space_num]->CS_OS_name);
        ex$message( msgnumb = EX_S_Var1, type="%s",var=response_data);
        ex$message(msgnumb = EX_P_Clear);
        if( module_table[active_module_num].permis_flag == EX_read_only)
        {
#ifndef NT
          sleep(2);
#else
        _sleep(2);
#endif
          ex$message(msgnumb = EX_F_ReadOnly);
          *response = TERMINATE;
        }
        else
        {
          goahead = TRUE;
        }
      }
      else
      {
        if( response_data[0] != '/' ) /* user did not specify full path */
        {
          if( EX_use_default_dir() )
          {
            strcpy(string , EX_global_var.working_dir);
          }
          else
          {
            strcpy(string,getenv("PWD"));
            strcat(string,"/");
          }
        }
        strcat(string,response_data);
  
        ex$message( msgnumb = EX_S_Var1, type="%s",var=string);
        ex$message(msgnumb = EX_P_Clear);
  
        result = EX_check_file(string,TRUE);
        if ( result > 1 ) /* error occured */
        {
          ex$message(msgnumb = result,justification=LEFT_JUS,time=4);
          *response = TERMINATE;
        }
        if ( result == 1 )
        {
          *response = TERMINATE;
        }
  
        if (result <= 0)  /* file is not on disk */
        {
          goahead = TRUE;
        }
      }
    }
  
    if ( goahead )
    {
      ex$message(msgnumb = EX_P_Clear,justification = RIGHT_JUS);
      strcpy(response_data,"y");
      ex$message( msgnumb = EX_S_Var1, type="%s",var=string);
      result=file_exists(string,0,0,fname);
      if(!result)
      {
        goahead = FALSE;
        do
        {
          prompt_status = ex$create_prompt(message_no = EX_P_FileExist,
              left_prompt = EX_P_Yes,
              right_prompt = EX_P_No,
              response = response,
              response_data = response_data);
  
  
          if(*response == RESET)
          {
            response_data[0] = '\0';
            EX_init_keyboard();
            UI_echo(" ");
          }
          else if( *response == STRING )
          {
            if ( prompt_status == EX_LEFT_MATCH )
            {
#ifndef NT
              if ( access(string,2) == 0 ) /* has write perm */
#else
              if ( _access(string,2) == 0 ) /* has write perm */	      
#endif
              {
                goahead = TRUE;
              }
              else
              {
                goahead = FALSE;
                ex$message(msgnumb= EX_S_NoWritePerm);
                UI_echo(string);
                ex$message(msgnumb = EX_F_FileNotSave );
                UI_echo(" ");
              }
  
            }
            else if ( prompt_status == EX_RIGHT_MATCH )
            {
              goahead = FALSE;
              *response = TERMINATE;
            }
          }
        }            while( *response == RESET );
        ex$message(msgnumb = EX_P_Clear,justification = RIGHT_JUS);
      }
      if( goahead )
      {
        if ( use_current_file )
        {
          active = TRUE;
          EX_save_module(active_module_num, active);
        }
        else
        {
          EX_saveas1( string );
        }
        *response = TERMINATE;
      }
    }
  }
  ex$message(msgnumb = EX_S_Clear);
  ex$message(msgnumb = EX_M_Clear);
  
  return 1;
}



int  EX_saveas1( string )
char *string;
{
  char     old_file_name[OM_K_MAXOSNAME_LEN];
  char     fname[OM_K_MAXOSNAME_LEN];
  char     na_me[256];
  long     status;
  int      retstat;
  OMuword  act_os;
  
            retstat = 1;
 	    ex$message(msgnumb = EX_S_SaveAsInProg);

            strcpy(fname,string);

            status = om$send(mode = OM_e_wrt_object,
			 msg = message module.sleep(EX_TEMP_SLEEP),
		    senderid = EX_exec_id,
		    targetid = module_table[active_module_num].module_my_id,
		    targetos = module_table[active_module_num].obj_space_num);
            check_error_status(status,
                     "IN EXEC save as (module.sleep) error");
            if (! 1&status)
            {
               ex$message(msgnumb = EX_F_FileNotSave);
               printf("IN EXEC save as send to module sleep failed,status = %d\n",status);
               retstat = 0;
            }
            else
            {
                act_os = module_table[active_module_num].obj_space_num;
                strcpy(old_file_name,module_data[act_os]->CS_OS_name);

                /*  Here we use a special kludged enum value of 77 to  */
                /*  tell change_os_name to keep hold of this internal  */
                /*  OS name since we will be changing back in the      */
                /*  code just below - this is needed to keep the same  */
                /*  internal name to preserve associativity via the    */
                /*  ISO and TagCon logic                               */

                status=om$change_os_name( osnum = act_os,
                                     new_osname = fname,
				     overwrite = (OM_e_OVRWRT_FLG)77 );
                if( !( 1 & status) )
		{
		    printf("In save and rename can not change to new file name \n");
		    ex$message(msgnumb = EX_F_FileNotSave);
                    om$report_error(sts = status); 
                    if( status == OM_W_ISODIRONOS)
		    {
                       printf("No ISO allowed in object space for this operation.\n");
		    }
                    fflush(stdout);
                    retstat = 0;
		}						  
                else
		{
		    status = om$send(mode = OM_e_wrt_object,
				 msg = message OMFiledOS.write(fname),
			    senderid = EX_exec_id,
		 	    targetid =module_table[active_module_num].filed_id,
			    targetos = act_os);
		    if (!(1&status))
		    {
                        retstat = 0;
                        ex$message(msgnumb = EX_F_FileNotSave);
		        if ( status == OM_E_BADSTATE )
                        {
                           ex$message(msgnumb = EX_F_BadState);
		        }
			else if ( status == OM_E_NO_DISK_SPACE )
                        {
                           ex$message(msgnumb = EX_F_NoDiskSpace);
			}
			else if ( status == OM_E_WRITE_ERROR ||
                                  status == OM_E_IOERR )
			{
                           ex$message(msgnumb = EX_F_WriteErr);
		        }
			printf("IN EXEC save and rename (OMFiled.write) error %x\n",status);
			om$report_error(sts = status);
		    }

                    /*  Here we use a special kludged enum value of 78 to  */
                    /*  tell change_os_name to restore the original        */
                    /*  internal OS name                                   */

                    status=om$change_os_name( osnum = act_os,
					 new_osname = old_file_name,
				     overwrite = (OM_e_OVRWRT_FLG)78 );
	            if( !( 1 & status) )
	            {
	   	        printf("In save and rename can not change file name back\n");
	  	        om$report_error(sts = status); 
		        if( status == OM_W_ISODIRONOS)
		        {
		           printf("No ISO allowed in object space for this operation.\n");
		        }
		    }						  
         	}
                ex$message( msgnumb = EX_S_CurFile, buff=na_me);
                strcat(na_me, module_data[module_table[active_module_num].obj_space_num]->CS_OS_name);
                ex$message( msgnumb = EX_S_Var1, type="%s", var=na_me, justification=CENTER_JUS,time = 4);

                status = om$send(mode = OM_e_wrt_object,
			    msg = message module.wake_up(2),
		       senderid = EX_exec_id,
		       targetid = module_table[active_module_num].module_my_id,
		       targetos = module_table[active_module_num].obj_space_num);
                check_error_status(status,"IN EXEC save as (module.wake_up) error");

            }
      return(retstat);
}


end implementation EX_saveas;

