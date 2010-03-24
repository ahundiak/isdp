class implementation EX_close;

#include <OMlimits.h>
#include <OMerrordef.h>
#include <exdef.h>
#include <ex.h>
#include <execmsg.h>
#include <exmacros.h>
#include <expriv.h>
#include <EXproduct.h>
#include <exms.h>
#include <msdef.h>
#include <msmacros.h>
#include <stdio.h>
#include <exproto.h>
#include <string.h>

from module import  GRmd_active;
/*helpnt*/
extern int Help_active();
extern int Help_remove();
extern struct module_params      **module_data;
extern struct EX_visible_module  *module_table;
extern OM_S_OBJID                EX_exec_id;
extern struct EX_global          EX_global_var;
extern int                       no_modules;
extern uword                     EX_ACTINV_OS_num;
extern int                       EX_help_proc_exist;

/************************************************************/

/*
 *  This code was added because display list needs to know
 *  if we're closing or exiting.
 */

%safe
static int      were_exiting = 0;
%endsafe

void    WereClosing() { were_exiting = 0; }
void    WereExiting() { were_exiting = 1; }

int	WeAreExiting() { return were_exiting; }

/************************************************************/

method execute (int *response; char *response_data; int pos)
{
   long  num_byte,
         msg;
   int   status, j,
         resp,
         goahead,
         prompt_status,
         close_flag;
   char  *tttmp,
         tmp_file[OM_K_MAXOSNAME_LEN],
         buf[10],
         na_me[100];

WereClosing();
   ex$message(msgnumb = EX_M_Close);
   close_flag = 0;   /*tells close_visible not to save file*/
   goahead = FALSE;
   strcpy(tmp_file,
      module_data[module_table[active_module_num].obj_space_num]->CS_OS_name);
   do
   {
      prompt_status = ex$create_prompt(message_no = EX_P_Save,
                                       left_prompt = EX_P_Yes,
                                       right_prompt = EX_P_No,
                                       string = tmp_file,
                                       response = response,
                                       response_data = response_data);
      if (*response == RESET)
      {
         response_data[0] = '\0';
	 EX_init_keyboard();
	 UI_echo(" ");
      }
      else if (*response == D_RESET)
      {
	 response_data[0] = '\0';
	 EX_init_keyboard();
	 UI_echo(" ");
	 *response = TERMINATE;
      }
      else if (*response == STRING)
      {
         if (prompt_status == EX_LEFT_MATCH)
         {
            if (module_table[active_module_num].permis_flag == EX_read_only)
            {
               na_me[0]='\0';
               strcpy(na_me,
                  module_data[module_table[active_module_num].
                     obj_space_num]->CS_OS_name);           
               ex$message(msgnumb = EX_S_Var1, type="%s",var=na_me);
               ex$message(msgnumb = EX_F_UseSaveas);
               *response = TERMINATE;
            }
            else
	    {
               goahead = TRUE;
               close_flag = EX_saveOnClose; /*tells close_visible to save file*/
	    }
         }
         else if (prompt_status == EX_RIGHT_MATCH)
         {
            goahead = TRUE;
            close_flag = 0;   /*tells close_visible not to save file*/
         }
      }
   }
   while (*response == RESET);

   if (goahead)
   {
      ex$message(msgnumb = EX_P_Clear, justification = RIGHT_JUS);
      ex$message(msgnumb = EX_S_CloseInProg);		    

      close_visible(close_flag, EX_exec_id);

      for (j=EX_MAX_MODULES - 1; j >= 0; j--)
      {
         if (module_table[j].obj_space_num != 0)
         {
            if (active_module_num == (EX_MAX_MODULES - 1))
               active_module_num = (-1);
            active_module_num = j;
            EX_active_module = module_table[active_module_num].module_my_id;
            EX_active_OS_num = module_table[active_module_num].obj_space_num;
            EX_ACTINV_OS_num = EX_active_OS_num;
            strcpy(EX_global_var.working_dir,
               module_data[module_table[active_module_num].
               obj_space_num]->CS_OS_name);
            tttmp = (char *)strrchr(EX_global_var.working_dir,'/');
            strcpy(EX_global_var.filename, tttmp + 1 );
            *(tttmp + 1) = '\0';

            status=om$send(mode = OM_e_wrt_object,
               msg = message module.GRmd_active(),
               senderid = my_id,
               targetid = module_table[active_module_num].module_my_id,
               targetos = module_table[active_module_num].obj_space_num);

            check_error_status(status,
               "IN EXEC wake_up (module.active) error");
            break;
         }
      }
      *response = TERMINATE;
   }
   ex$message(msgnumb = EX_S_Clear);
   ex$message(msgnumb = EX_M_Clear);	       
   if (no_modules == 1)
   {
      if (EX_help_proc_exist == 1)
      {
         int help_active_flag;

         Help_active(&help_active_flag);        
         if (help_active_flag == 1)
            Help_remove();
      }

      *response = CLEAR_STACK;
      resp = EX_CMDSVR_RETURN;
      num_byte = sizeof(buf);
      strcpy(buf, "EX_return");
      status = ex$putque(msg = &msg, pos=FRONT, response=&resp,
         byte=&num_byte, buffer=buf); 
      if (!(1&status))
         printf("IN EX_close  can not put q EX_return\n");
   }
   return(1);    
}


int EX_close1(last, flag)
int   flag;
int   *last;
{
   int   j, status;
   char  *tttmp;

   close_visible(flag, EX_exec_id);
   for (j=EX_MAX_MODULES - 1; j>= 0; j--)
   {
      if (module_table[j].obj_space_num != 0)
      {
         if (active_module_num == (EX_MAX_MODULES - 1))
            active_module_num = (-1);

         active_module_num = j;
         EX_active_module = module_table[active_module_num].module_my_id;
         EX_active_OS_num = module_table[active_module_num].obj_space_num;
         EX_ACTINV_OS_num = EX_active_OS_num;
         strcpy(EX_global_var.working_dir,
            module_data[module_table[active_module_num].
            obj_space_num]->CS_OS_name);
         tttmp = (char *)strrchr(EX_global_var.working_dir,'/');
         strcpy(EX_global_var.filename, tttmp + 1);
         *(tttmp + 1) = '\0';

         status = om$send(mode = OM_e_wrt_object,
            msg = message module.GRmd_active(),
            senderid = EX_exec_id,
            targetid = module_table[active_module_num].module_my_id,
            targetos = module_table[active_module_num].obj_space_num);

         check_error_status(status,
            "IN EXEC wake_up (module.active) error");
      }
   }
   if (no_modules == 1)
   {
      /* return something to caller to indicate no more active module */

      *last = 1;
   }
   else
      *last = 0;
   return(1);      
}

end implementation EX_close;
