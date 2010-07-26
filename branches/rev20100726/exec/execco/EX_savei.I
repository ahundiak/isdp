class implementation EX_save;

#include <OMlimits.h>
#include <OMerrordef.h>
#include <exdef.h>
#include <ex.h>
#include <execmsg.h>
#include <exmacros.h>
#include <exms.h>
#include <msdef.h>
#include <msmacros.h>
#include <string.h>
#include <exproto.h>
#include <stdio.h>

#include "exudata.h"

#define debug  0

#ifdef SUNOS5
%undef sleep
#endif

from module import wake_up,sleep, GRmod_passon;
from OMFiledOS import write;
from cmdserver import sleep_cs;

extern struct module_params **module_data;
extern struct EX_visible_module *module_table;
extern OM_S_OBJID EX_exec_id;

%safe
static int (*EX_call_function_on_save)() = 0;
static int in_save_command = 0;
%endsafe
void EX_in_save_command(flag)
int *flag;
{
    if (in_save_command)
    {
        *flag = TRUE;
        in_save_command = 0;
    }
    else
    {
        *flag = FALSE;
    }
}


/***********************************************************************/
/****************** EX_save execute method ******************************/
/***********************************************************************/

method execute(int *response; char *response_data; int pos)
{
    int num_open, save_all,i,active;
    int save[10];
    int goahead;
    int prompt_status;
    char na_me[OM_K_MAXOSNAME_LEN];
    int status;

    int entry_num;
    char osname[OM_K_MAXOSNAME_LEN];

    exUDataActref rfact;


    in_save_command = 1;
    ex$message(msgnumb = EX_M_Save);
    goahead = FALSE;
    num_open = 0;
    for(i=(EX_MAX_MODULES-1);i>=0;i--)
    {
        save[i] = FALSE;
        if(module_table[i].obj_space_num!=0)   num_open++;
    }

    if (num_open == 1)
    {
        strcpy(na_me,module_data[module_table[active_module_num].obj_space_num]->CS_OS_name);           

        /** Start of RFA **/

        status = exRecvUData(EX_UDATA_ACTREF, (char *)&rfact);
        if (rfact.aflag)
        {
           status = ex$is_invis ( mod_osnum = rfact.osn,index = &entry_num);
           if (status)
           {
              om$os_number_to_name (osnum = rfact.osn, osname = osname);
              do
              {
                  prompt_status = ex$create_prompt(message_no = EX_P_Save,
                                                   left_prompt =EX_P_Yes,
                                                   right_prompt =EX_P_No,
                                                   string = osname,
                                                   response = response,
                                                   response_data=response_data);
                  if(*response == D_RESET || *response == RESET)
                  {
                      response_data[0] = '\0';
                      EX_init_keyboard();
                      UI_echo(" ");
                      *response = TERMINATE;
                      return(1);
                  }
                  else if ( *response == STRING )
                  {
                      if (prompt_status == EX_LEFT_MATCH   ) 
                      {
                          if( module_table[active_module_num].permis_flag == EX_read_only)
                          {
                              ex$message(msgnumb = EX_S_Var1, type="%s",var=osname);
                              ex$message(msgnumb = EX_F_UseSaveas) ;
                              *response = TERMINATE;
                              return(1);
                          }
                          else
                          {
                              ex$save_module(index = entry_num);
                              *response = TERMINATE;
                              return(1);
                          }
                      }
                      else if ( prompt_status == EX_RIGHT_MATCH) 
                      {
                          *response= TERMINATE;
                          return(1);
                      }
                  }                   
              }                      
              while(*response == RESET);
           }
           else
           { 
              *response = TERMINATE;
              return(1);
           }
        }

        /** End of RFA **/
	
        do
        {
            prompt_status = ex$create_prompt(message_no = EX_P_Save,
                                             left_prompt =EX_P_Yes,
                                             right_prompt =EX_P_No,
                                             string = na_me,
                                             response = response,
                                             response_data =response_data);


            if(*response == RESET)
            {
                response_data[0] = '\0';
                EX_init_keyboard();
                UI_echo(" ");
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
                if (prompt_status == EX_LEFT_MATCH   ) 
                {
                    if( module_table[active_module_num].permis_flag == EX_read_only)
                    {
                        na_me[0]='\0';
                        strcpy(na_me,module_data[module_table[active_module_num].obj_space_num]->CS_OS_name);           
                        ex$message(msgnumb = EX_S_Var1, type="%s",var=na_me);
                        ex$message(msgnumb = EX_F_UseSaveas) ;
                        *response = TERMINATE;
                    }
                    else
                    {
                        goahead = TRUE;
                    }
                }
                else if ( prompt_status == EX_RIGHT_MATCH) 
                {
                    *response= TERMINATE;
                }
            }                   /*end if string*/
        }                       /*end do*/
        while(*response == RESET);

        if( goahead )
        {
            ex$message(msgnumb = EX_P_Clear,justification = RIGHT_JUS);
            ex$message(msgnumb = EX_S_SaveInProg);
            active = TRUE;

            EX_save_module(active_module_num,active);
/**** you now have filename in string by keyin,form, or command line***/
/******* or it is a null telling you to exit *************************/

        if ( EX_call_function_on_save )
        {
         status = (*EX_call_function_on_save)(na_me);
         if ( !status )
         {
             printf("error on retrieve call function\n");
         }
     }
            if( EX_clear_command_on_save() ) *response = CLEAR_STACK;

            else 
                *response = TERMINATE;
        }                  
    }
    else                        /* more than one file opened */
    {
        /*UI_prompt("Save all files? y/n >");*/
        ex$message(msgnumb = EX_P_SaveAll,justification = RIGHT_JUS);
        do
        {
            prompt_status = ex$create_prompt(message_no = EX_P_SaveAll,
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
            else if(*response == D_RESET)
            {
                response_data[0] = '\0';
                EX_init_keyboard();
                UI_echo(" ");
                *response = TERMINATE;
            }
            else if ( *response == STRING )
            {
                if ((prompt_status == EX_LEFT_MATCH ) ||
                    (prompt_status == EX_RIGHT_MATCH))
                {
                    goahead = TRUE;
                }
            }
        }
        while(*response == RESET );

        if( goahead )
        {
            save_all = FALSE;
            if (prompt_status == EX_LEFT_MATCH ) /* save all files */

            {
                save_all = TRUE;
            }

            for(i=(EX_MAX_MODULES-1);i>=0;i--)
            {
                if(module_table[i].obj_space_num!=0)
                {
                    if( module_table[i].permis_flag == EX_read_only)
                    {
                        na_me[0]='\0';
                        strcpy(na_me,module_data[module_table[i].obj_space_num]->CS_OS_name);           
                        ex$message(msgnumb = EX_S_Var1, type="%s",var=na_me);
                        ex$message(msgnumb = EX_F_ReadOnly);
                    }
                    else
                    {
                        if ( ! save_all ) /* not all files */
                        {
                            response_data[0] = '\0';
                            strcpy(na_me,module_data[module_table[i].obj_space_num]->CS_OS_name);
                            ex$message(msgnumb = EX_S_Clear);
                            do
                            {
                                prompt_status = ex$create_prompt(message_no  = EX_P_Save,
                                                                 left_prompt = EX_P_Yes,
                                                                 right_prompt = EX_P_No,
                                                                 string = na_me,
                                                                 response = response,
                                                                 response_data = response_data);

                                if(*response == RESET)
                                {
                                    response_data[0] = '\0';
                                    EX_init_keyboard();
                                    UI_echo(" ");
                                }
                                else if ( *response == STRING )
                                {
                                    if (prompt_status == EX_LEFT_MATCH ) /* save */
                                    {
                                        save[i] = TRUE;
                                    }
                                    else if (prompt_status == EX_RIGHT_MATCH ) 
                                    {
                                        goahead = TRUE;
                                    }
                                    else
                                    {
                                        goahead = FALSE;
                                        goto exsaveact;
                                    }
                                }
                                else 
                                {
                                    goahead = FALSE ;
                                    goto exsaveact;
                                }
                            }
                            while( *response == RESET );
                        }
                        else
                        {
                            save[i] = TRUE;
                        }
                    }
                }
            }                   /* end for */
          exsaveact:
            if ( goahead )
            {
                for(i=(EX_MAX_MODULES-1);i>=0;i--)
                {
                    if ( save[i] ) 
                    {
                        /*UI_prompt(" ");*/
                        ex$message(msgnumb = EX_P_Clear,justification = RIGHT_JUS);
                        /*UI_status("Save in progress");*/
                        ex$message(msgnumb = EX_S_SaveInProg);
                        active = ( i == active_module_num) ? TRUE : FALSE;
                        EX_save_module(i , active );

                    }
                }
                if( EX_clear_command_on_save() ) *response = CLEAR_STACK;
                else
                    *response = TERMINATE;
            }
        }
    }
    in_save_command = 0;        /*this flag used in module wake_up to store
                                  windows for journaling*/
    ex$message(msgnumb = EX_S_Clear);
    ex$message(msgnumb = EX_M_Clear);
    return(1);    
}







int  EX_save_module( table_index, active )
    int table_index;
    int active;
{
  char   tmp_file[OM_K_MAXOSNAME_LEN];
  long   status;

    ex$message(msgnumb = EX_S_SaveInProg);

    strcpy(tmp_file, module_data[module_table[table_index].obj_space_num]->
                                                 CS_OS_name);
    UI_echo(tmp_file);

    if( active )
    {
       status = om$send(mode = OM_e_wrt_object,
                msg = message module.sleep(EX_TEMP_SLEEP),
                senderid = EX_exec_id,
                targetid = module_table[table_index].module_my_id,
                targetos = module_table[table_index].obj_space_num);
       check_error_status(status,"IN EXEC exsave (module.sleep) error");
    }

   status = om$send(mode = OM_e_wrt_object,
                     msg = message OMFiledOS.write(tmp_file),
                senderid = EX_exec_id,
                targetid = module_table[table_index].filed_id,
                targetos = module_table[table_index].obj_space_num);

   if (!(1 & status))
   {
      ex$message(msgnumb = EX_F_FileNotSave);
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

      printf("In EXEC exsave (OMFiledOS.write) error %x\n",status);
      om$report_error(sts = status);
   }
   if( active )
   {
      if ( 1 & status )EX_clear_jnl_on_save();
      status = om$send(mode = OM_e_wrt_object,
                        msg = message module.wake_up(2),
                   senderid = EX_exec_id,
                   targetid = module_table[table_index].module_my_id,
                   targetos = module_table[table_index].obj_space_num);
      check_error_status(status,"IN EXEC exsave (module.wake_up) error");
   }
   UI_echo("");
   ex$message(msgnumb = EX_S_Clear);
   return(status);
}



int
EX_save1( fname )
char *fname;
{
   int i;
   int status, os_num, active;
   char *file_in_table;
   char filename[OM_K_MAXOSNAME_LEN];

   status = 0;
   strcpy(filename, fname);
   module_build_path(filename);
   for(i=(EX_MAX_MODULES-1);i>=0 ; i--)
   {
      os_num = module_table[i].obj_space_num;
      if ( os_num != 0 ) 
      {
         file_in_table = module_data[os_num]->CS_OS_name;
         if ( !strcmp( file_in_table,filename ) )
         {
             active = ( i == active_module_num ) ? TRUE : FALSE;
	     EX_save_module(i, active);
             status = 1;
	     break;
         }
      }                         
   }
   return(status);

}


int
EX_saveall( )
{
   int i;
   int status, os_num, active;


   status = 1;
   
   for(i=(EX_MAX_MODULES-1);i>=0 ; i--)
   {
      os_num = module_table[i].obj_space_num;
      if ( os_num != 0 ) 
      {
             active = ( i == active_module_num ) ? TRUE : FALSE;
	     EX_save_module(i, active);
      }                         
   }
   return(status);

}

EX_save_function(function_to_execute,function_previous)
int (*function_to_execute)();
int (**function_previous)();
{
*function_previous = EX_call_function_on_save;
EX_call_function_on_save = function_to_execute;
return(1);
}

end implementation EX_save;





















