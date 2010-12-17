#include <stdio.h>

#include "FI.h"
#include "MI.h"

#include "XMBpriv.h"

#include "XFIproto_pri.h"
#include "XFIproto_pub.h"
#include "XMBproto_pri.h"

char current_command_string[80]; /* Command being executed currently */

int command_is_active = 0;  /* Is a command currently being     */
                            /* processed?  If so this is its    */
                            /* corresponding command index.     */
                                        
			/* 	command.c 	*/
			/* COMMAND INTERPRETER */
				
int command_screen(char *cmd)
{
   if ( strcmp ( cmd, current_command_string ) == 0 )  /* You tried to     */
   {                                                   /* execute the same */
      return (0);   /* Forget new command */           /* command that you */
   }                                                   /* are doing now.   */
   else
   {
      if (command_is_active == 0)  /* No command currently active */
      {
      	 return(1);  /* Proceed with new command */
      }
      else  /* Kill current command */
      {
         switch (command_is_active)
         {
            case DEFINE_MENU:
                  kill_define_menu();
                  break;        

            case SAVE_MENU:
                  kill_save_menu();
                  break;

            case RELOAD_SYMBOLS:
                  kill_reload_symbols();
                  break;

            case ADD_BUTTON:
                  kill_add_button();
                  break;

            case CUT_BUTTON:
                  kill_cut_button();
                  break;

            case SWAP_BUTTONS:
                  kill_swap_buttons();
                  break;

            case EDIT_BUTTON:
                  kill_edit_button();
                  break;

            case PASTE_BUTTON:
                  kill_paste_button();
                  break;

            case HELP:
                  kill_HELP();
                  break;

            case EXIT:
                  kill_EXIT();
                  break;

            case PREVIEW_OUTLINE:
                  kill_preview_outline();
                  break;
         }
         return(1);  /* Proceed with new command */
      }
   }
}

/*------------------------------------------------------------------------*/

/* This function is called by the Menu Subsystem.  The Menu Subsystem calls 
   this routine because in FEI_enter this functions pointer was stored in the
   structure passed to the Menu Subsystem in MS_setup_functions.	*/
   
/*    The first action that the APP_process_command should take is to   */
/* call the command_screen function.  This will let you know whether    */
/* to allow the command to execute or not.                              */
/*                                                                      */
/*    If command_screen() returned a zero then this function will exit  */
/* without invoking a new command.  If command_screen() returned a one, */
/* then the following actions will be taken.                            */
/*                                                                      */
/*    First the command string will be saved into the global variable   */
/* "current_command_string."  Then a search for the command string will */
/* be performed.  When a match is found, store the command index into   */
/* the global variable "command_is_active."  Finally invoke the         */
/* command's execute method to cause the command to be performed.       */
/*                                                                      */
/*    Note: the most frequently used commands (i.e. place commands)     */
/* should be searched for first.                                        */
 
/* ARGSUSED */
APP_process_command (int  cmd_type,
                     char *cmd)
{
   int status;

   status = command_screen (cmd);
   
   if (status == 0)  /* cancel this command request */
   {
      return(FI_SUCCESS);
   }
   else              /* process the command */
   {
      strcpy (current_command_string, cmd);

      if (strcmp (cmd, "define menu") == 0)
         {
            command_is_active = DEFINE_MENU;
            execute_define_menu();
            return(FI_SUCCESS);
         }

      if (strcmp (cmd, "save menu") == 0)
         {
            command_is_active = SAVE_MENU;
            execute_save_menu();
            return(FI_SUCCESS);
         }

      if (strcmp (cmd, "reload symbols") == 0)
         {
            command_is_active = RELOAD_SYMBOLS;
            execute_reload_symbols();
            return(FI_SUCCESS);
         }

      if (strcmp (cmd, "add button") == 0)
         {
            command_is_active = ADD_BUTTON;
            execute_add_button();
            return(FI_SUCCESS);
         }

      if (strcmp (cmd, "cut button") == 0)
         {
            command_is_active = CUT_BUTTON;
            execute_cut_button();
            return(FI_SUCCESS);
         }

      if (strcmp (cmd, "swap buttons") == 0)
         {
            command_is_active = SWAP_BUTTONS;
            execute_swap_buttons();
            return(FI_SUCCESS);
         }

      if (strcmp (cmd, "edit button") == 0)
         {
            command_is_active = EDIT_BUTTON;
            execute_edit_button();
            return(FI_SUCCESS);
         }

      if (strcmp (cmd, "paste button") == 0)
         {
            command_is_active = PASTE_BUTTON;
            execute_paste_button();
            return(FI_SUCCESS);
         }

      if (strcmp (cmd, "HELP") == 0)
         {
            command_is_active = HELP;
            execute_HELP();
            return(FI_SUCCESS);
         }

      if (strcmp (cmd, "EXIT") == 0)
         {
            command_is_active = EXIT;
            execute_EXIT();
            return(FI_SUCCESS);
         }

      if (strcmp (cmd, "preview outline") == 0)
         {
            command_is_active = PREVIEW_OUTLINE;
            execute_preview_outline();
            return(FI_SUCCESS);
         }         
   }
   return(FI_SUCCESS); /* sml:11-15-94:added for ANSI */
} 

