/***********************************

		command.c

***********************************/

/*
  History
	04-28-92	sml		already ANSI-ized
*/

/* COMMAND INTERPRETER */

#include <stdio.h>

#include "FI.h"
#include "MI.h"
#include "NFBpriv.h"

#include "XFIproto_pub.h"
#include "XFBproto_pri.h"

char current_command_string[80]; /* Command being executed currently */

int command_is_active = 0; /* Is a command currently being */
/* processed? If so this is its */
/* corresponding command index. */

int autokill_mode = 1; /* 1 = kill current command when */
/* new command is selected. */
/* 0 = ignore new command, deselect */
/* button, and finish current */
/* command. */


/* The command_screen() function first checks global variable */
/* command_is_active. If no command is active, then the function */
/* will return true, allowing the new command to be executed. */
/* If a command is active then the autokill_mode flag will be */
/* examined. If autokill is not set, then the menu system will be told */
/* to pop up the button which was just pressed. A value of false will */
/* be returned, preventing the new command from being executed. */
/* If the autokill flag is set then the current command must be */
/* killed before the new command can begin. The command_is_active flag */
/* doubles as an index which specifies which command is being run. */
/* Each command is responsible for having a kill function which will */
/* allow the command to be terminated gracefully. (i.e. all allocated */
/* memory freed, all forms displayed taken down, etc.) */
/* A giant case statement will be consulted and the appropriate */
/* kill function will be invoked. Then the function will return true, */
/* allowing the new command to be executed. */
/* Note: a special case arises when the operator attempts to select */
/* the exact same command he is currently executing. This can occur */
/* due to a mouse button bouncing or through carelessness of the user. */
/* I propose ignoring such input completely. */

int command_screen (char *cmd)
{
  if (strcmp (cmd, "GROUP OPERATIONS") == 0)
  {
    MS_swap_menu (BAR_MENU, "BAR_MENU2");
    return (0); /* Forget new command */
  }

  if (strcmp (cmd, "FENCE OPERATIONS") == 0)
  {
    MS_swap_menu (BAR_MENU, "BAR_MENU3");
    return (0); /* Forget new command */
  }

  if (strcmp (cmd, "SINGLE OPERATIONS") == 0)
  {
    MS_swap_menu (BAR_MENU, "BAR_MENU");
    return (0); /* Forget new command */
  }

  if ( strcmp ( cmd, current_command_string ) == 0 )
  {
    /* You tried to execute the same command that's running now. */

    return (0); /* Forget new command */
  }
  else
  {
    if (command_is_active == 0) /* No command currently active */
    {
      return(1); /* Proceed with new command */
    }
    else
    {
      if (autokill_mode == 0) /* Do not autokill current command */
      {
        /* To keep the user from thinking that he is processing the new command */
        MS_pop_up_last_button();

        return(0); /* Forget new command */
      }
      else /* Kill current command */
      {
        switch (command_is_active)
        {
        case DEFINE_FORM:
          kill_define_form();
          break;

        case SAVE_FORM:
          kill_save_form();
          break;

        case EXIT_FB:
          kill_exit_fb();
          break;

        case PLACE_BUTTON:
          kill_place_button();
          break;

        case PREVIEW_FORM:
          kill_preview_form();
          break;

        case PLACE_FIELD:
          kill_place_field();
          break;

        case PLACE_CHECKLIST:
          kill_place_cklist();
          break;

        case PLACE_TEXT:
          kill_place_text();
          break;

        case CHANGE_PV:
          kill_change_pv();
          break;

        case PLACE_SYMBOL:
          kill_place_symbol();
          break;

        case PLACE_TOGGLE:
          kill_place_toggle();
          break;

        case PLACE_CBAR:
          kill_place_cbar();
          break;

        case PLACE_SLIDER:
          kill_place_slider();
          break;

        case PLACE_DIAL:
          kill_place_dial();
          break;

        case PLACE_RECTANGLE:
          kill_place_rectangle();
          break;

        case PLACE_LINE:
          kill_place_line();
          break;

        case PLACE_PALETTE:
          kill_place_palette();
          break;

        case FIT_FORM:
          kill_fit_form();
          break;

        case PLACE_BEZEL:
          kill_place_bezel();
          break;

        case MOVE_GADGET:
          kill_move_gadget();
          break;

        case DELETE_GADGET:
          kill_delete_gadget();
          break;

        case COPY_GADGET:
          kill_copy_gadget();
          break;

        case PLACE_MULTI_COL:
          kill_place_multi_col_field();
          break;

        case FENCE_MOVE:
          kill_fence_move();
          break;

        case EDIT_GADGET:
          kill_edit_gadget();
          break;

        case SAVE_PV:

          kill_save_pv();
          break;

        case PLACE_GAUGE:

          kill_place_gauge();
          break;

        case CREATE_SEQUENCE:

          kill_create_sequence();
          break;

        case DELETE_SEQUENCE:

          kill_delete_sequence();
          break;

        case REVIEW_SEQUENCE:

          kill_review_sequence();
          break;

        case CREATE_DATA_LINK:

          kill_create_data_link();
          break;

        case DELETE_DATA_LINK:

          kill_delete_data_link();
          break;

        case REVIEW_DATA_LINK:

          kill_delete_data_link();
          break;

        case CREATE_GROUP:

          kill_create_group();
          break;

        case DROP_FROM_GROUP:

          kill_drop_from_group();
          break;

        case DELETE_GROUP:

          kill_delete_group();
          break;

        case FENCE_COPY:

          kill_fence_copy();
          break;

        case FENCE_DELETE:

          kill_fence_delete();
          break;

        case GROUP_MOVE:

          kill_group_move();
          break;

        case GROUP_COPY:

          kill_group_copy();
          break;

        case GROUP_DELETE:

          kill_group_delete();
          break;

        case PLACE_SCROLL:

          kill_place_scroll();
          break;

        case EXPANDED_PREVIEW:

          kill_expanded_preview();
          break;

        case UNDELETE_GADGET:

          kill_undelete_gadget();
          break;

        case FENCE_UNDELETE:

          kill_fence_undelete();
          break;

        case GROUP_UNDELETE:

          kill_group_undelete();
          break;

        case SHOW_GROUP:

          kill_show_group();
          break;

        case FENCE_EDIT:

          kill_fence_edit();
          break;

        case GROUP_EDIT:

          kill_group_edit();
          break;

        case DELETE_FORM:

          kill_delete_form();
          break;

        case COPY_FORM:

          kill_copy_form();
          break;
        }

        return(1); /* Proceed with new command */
      }
    }
  }
}

/*------------------------------------------------------------------------*/

/* This function is called by the Menu Subsystem. The Menu Subsystem */
/* calls this routine because in FEI_enter this functions pointer was */
/* stored in the structure passed to the Menu Subsystem in */
/* MS_setup_functions. */

/* The first action that the APP_process_command should take is to */
/* call the command_screen function. This will let you know whether */
/* to allow the command to execute or not. */

/* If command_screen() returned a zero then this function will exit */
/* without invoking a new command. If command_screen() returned a one, */
/* then the following actions will be taken. */
/* First the command string will be saved into the global variable */
/* "current_command_string." Then a search for the command string will */
/* be performed. When a match is found, store the command index into */
/* the global variable "command_is_active." Finally invoke the */
/* command's execute method to cause the command to be performed. */

/* Note: the most frequently used commands (i.e. place commands) */
/* should be searched for first. */

/* ARGSUSED */
int APP_process_command (int cmd_type,
                         char * cmd)
{
  int status;

  status = command_screen (cmd);

  if (status == 0) /* cancel this command request */
  {
    return FI_SUCCESS;
  }
  else /* process the command */
  {
    strcpy (current_command_string, cmd);

    if (strcmp (cmd, "define form") == 0)
    {
      command_is_active = DEFINE_FORM;
      execute_define_form();
    }
    else if (strcmp(cmd, "save form") == 0)
    {
      command_is_active = SAVE_FORM;
      execute_save_form();
    }
    else if (strcmp(cmd, "exit fb") == 0)
    {
      command_is_active = EXIT_FB;
      execute_exit_fb();
    }
    else if (strcmp(cmd, "place button") == 0)
    {
      command_is_active = PLACE_BUTTON;
      execute_place_button();
    }
    else if (strcmp (cmd, "preview form") == 0)
    {
      command_is_active = PREVIEW_FORM;
      execute_preview_form();
    }
    else if (strcmp (cmd, "place field") == 0)
    {
      command_is_active = PLACE_FIELD;
      execute_place_field();
    }
    else if (strcmp (cmd, "place checklist") == 0)
    {
      command_is_active = PLACE_CHECKLIST;
      execute_place_cklist();
    }
    else if (strcmp (cmd, "place text") == 0)
    {
      command_is_active = PLACE_TEXT;
      execute_place_text();
    }
    else if (strcmp (cmd, "change pv") == 0)
    {
      command_is_active = CHANGE_PV;
      execute_change_pv();
    }
    else if (strcmp (cmd, "place symbol") == 0)
    {
      command_is_active = PLACE_SYMBOL;
      execute_place_symbol();
    }
    else if (strcmp (cmd, "place toggle") == 0)
    {
      command_is_active = PLACE_TOGGLE;
      execute_place_toggle();
    }
    else if (strcmp (cmd, "place ctrlbar") == 0)
    {
      command_is_active = PLACE_CBAR;
      execute_place_cbar();
    }
    else if (strcmp (cmd, "place slider") == 0)
    {
      command_is_active = PLACE_SLIDER;
      execute_place_slider();
    }
    else if (strcmp (cmd, "place dial") == 0)
    {
      command_is_active = PLACE_DIAL;
      execute_place_dial();
    }
    else if (strcmp (cmd, "place rectangle") == 0)
    {
      command_is_active = PLACE_RECTANGLE;
      execute_place_rectangle();
    }
    else if (strcmp (cmd, "place line") == 0)
    {
      command_is_active = PLACE_LINE;
      execute_place_line();
    }
    else if (strcmp (cmd, "place button palette") == 0)
    {
      command_is_active = PLACE_PALETTE;
      execute_place_palette();
    }
    else if (strcmp (cmd, "fit form") == 0)
    {
      command_is_active = FIT_FORM;
      execute_fit_form();
    }
    else if (strcmp (cmd, "place message field") == 0)
    {
      command_is_active = PLACE_ERROR_FIELD;
      execute_place_err_msg_flds();
    }
    else if (strcmp (cmd, "place bezel") == 0)
    {
      command_is_active = PLACE_BEZEL;
      execute_place_bezel();
    }
    else if (strcmp (cmd, "move") == 0)
    {
      command_is_active = MOVE_GADGET;
      execute_move_gadget();
    }
    else if (strcmp (cmd, "delete") == 0)
    {
      command_is_active = DELETE_GADGET;
      execute_delete_gadget();
    }
    else if (strcmp (cmd, "copy") == 0)
    {
      command_is_active = COPY_GADGET;
      execute_copy_gadget();
    }
    else if (strcmp (cmd, "place multi column field") == 0)
    {
      command_is_active = PLACE_MULTI_COL;
      execute_place_multi_col_field();
    }
    else if (strcmp (cmd, "fence move") == 0)
    {
      command_is_active = FENCE_MOVE;
      execute_fence_move();
    }
    else if (strcmp (cmd, "characteristics") == 0)
    {
      command_is_active = DISPLAY_CHAR;
      execute_display_characteristics_form();
      command_is_active = 0;
    }
    else if (strcmp (cmd, "edit") == 0)
    {
      command_is_active = EDIT_GADGET;
      execute_edit_gadget();
    }
    else if (strcmp (cmd, "save presentation variables") == 0)
    {
      command_is_active = SAVE_PV;
      execute_save_pv();
    }
    else if (strcmp (cmd, "grid") == 0)
    {
      toggle_grid_mode();
      current_command_string[0] = '\0';
    }
    else if (strcmp (cmd, "place gauge") == 0)
    {
      command_is_active = PLACE_GAUGE;
      execute_place_gauge();
    }
    else if (strcmp (cmd, "create sequence") == 0)
    {
      command_is_active = CREATE_SEQUENCE;
      execute_create_sequence();
    }
    else if (strcmp (cmd, "delete sequence") == 0)
    {
      command_is_active = DELETE_SEQUENCE;
      execute_delete_sequence();
    }
    else if (strcmp (cmd, "review sequence") == 0)
    {
      command_is_active = REVIEW_SEQUENCE;
      execute_review_sequence();
    }
    else if (strcmp (cmd, "create data link") == 0)
    {
      command_is_active = CREATE_DATA_LINK;
      execute_create_data_link();
    }
    else if (strcmp (cmd, "delete data link") == 0)
    {
      command_is_active = DELETE_DATA_LINK;
      execute_delete_data_link();
    }
    else if (strcmp (cmd, "review data link") == 0)
    {
      command_is_active = REVIEW_DATA_LINK;
      execute_review_data_link();
    }
    else if (strcmp (cmd, "create group") == 0)
    {
      command_is_active = CREATE_GROUP;
      execute_create_group();
    }
    else if (strcmp (cmd, "drop from group") == 0)
    {
      command_is_active = DROP_FROM_GROUP;
      execute_drop_from_group();
    }
    else if (strcmp (cmd, "delete group") == 0)
    {
      command_is_active = DELETE_GROUP;
      execute_delete_group();
    }
    else if (strcmp (cmd, "fence copy") == 0)
    {
      command_is_active = FENCE_COPY;
      execute_fence_copy();
    }
    else if (strcmp (cmd, "fence delete") == 0)
    {
      command_is_active = FENCE_DELETE;
      execute_fence_delete();
    }
    else if (strcmp (cmd, "group move") == 0)
    {
      command_is_active = GROUP_MOVE;
      execute_group_move();
    }
    else if (strcmp (cmd, "group copy") == 0)
    {
      command_is_active = GROUP_COPY;
      execute_group_copy();
    }
    else if (strcmp (cmd, "group delete") == 0)
    {
      command_is_active = GROUP_DELETE;
      execute_group_delete();
    }
    else if (strcmp (cmd, "place scroll bar") == 0)
    {
      command_is_active = PLACE_SCROLL;
      execute_place_scroll();
    }
    else if (strcmp (cmd, "expanded preview") == 0)
    {
      command_is_active = EXPANDED_PREVIEW;
      execute_expanded_preview();
    }
    else if (strcmp (cmd, "undelete") == 0)
    {
      command_is_active = UNDELETE_GADGET;
      execute_undelete_gadget();
    }
    else if (strcmp (cmd, "fence undelete") == 0)
    {
      command_is_active = FENCE_UNDELETE;
      execute_fence_undelete();
    }
    else if (strcmp (cmd, "group undelete") == 0)
    {
      command_is_active = GROUP_UNDELETE;
      execute_group_undelete();
    }
    else if (strcmp (cmd, "show group") == 0)
    {
      command_is_active = SHOW_GROUP;
      execute_show_group();
    }
    else if (strcmp (cmd, "fence edit") == 0)
    {
      command_is_active = FENCE_EDIT;
      execute_fence_edit();
    }
    else if (strcmp (cmd, "group edit") == 0)
    {
      command_is_active = GROUP_EDIT;
      execute_group_edit();
    }
    else if (strcmp (cmd, "delete form") == 0)
    {
      command_is_active = DELETE_FORM;
      execute_delete_form();
    }
    else if (strcmp (cmd, "copy form") == 0)
    {
      command_is_active = COPY_FORM;
      execute_copy_form();
    }
    /*
else if (strcmp (cmd, "help") == 0)
{
FB_activate_help();
current_command_string[0]='\0';
}
*/
  }
  return FI_SUCCESS;
}
