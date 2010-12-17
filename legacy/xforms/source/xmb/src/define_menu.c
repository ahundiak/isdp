           /*************************************/
           /*                                   */
           /*         define_menu.c             */
           /*                                   */
           /*    This file contains all of the  */
           /* functions pertaining to the       */
           /* "define menu" command.            */
           /*                                   */
           /*      Programmer: Mack Draper      */
           /*      Date:       July 1, 1991     */
           /*                                   */
           /*************************************/

#include <X11/Xlib.h>

#include <sys/types.h>	/*** need these two for stat() call ***/
#include <sys/stat.h>
#include <dirent.h>
#include <stdio.h>

#include "FI.h"
#include "UMS.h"
#include "XMB.h"
#include "FEI.h"
#include "FImin.h"
#include "FIgadget.h"
#include "FIbtn.h"
#include "FIdyn.h"
#include "XMBpriv.h"

#include "XFIproto_pri.h"
#include "XFIproto_pub.h"
#include "XMBproto_pri.h"

#define TRUE  1
#define FALSE 0

/***********************************/
/*                                 */
/*  Gadget labels for define form  */
/*                                 */
/***********************************/

#define BAR_MENU_CK        12
#define PANEL_MENU_CK      13
#define POPUP_MENU_CK      14

#define OPTIONS_BEZEL                 28
#define PANEL_BTN_SIZE_GROUP          48
#define POPUP_MENU_MATRIX_SIZE_GROUP  50

#define STANDARD_BTN_SIZE_BTN   47
#define BTN_PER_ROW_TOP_FLD     26
#define BTN_PER_ROW_2ND_FLD     37
#define BTN_PER_ROW_3RD_FLD     39
#define BTN_PER_ROW_4TH_FLD     41
#define BTN_HEIGHT_TOP_FLD      27
#define BTN_HEIGHT_2ND_FLD      38
#define BTN_HEIGHT_3RD_FLD      40
#define BTN_HEIGHT_4TH_FLD      42

#define DIRECTORY_FLD      17
#define FILENAME_FLD       20
#define FILENAME_LIST_FLD  22

#define NUM_ROWS_TEXT      30
#define NUM_COLS_TEXT      31
#define NUM_ROWS_FLD       32
#define NUM_COLS_FLD       33

#define DECISION_BTN       34
#define YES_BTN            35
#define NO_BTN             36

#define MSG_FLD            10

/*************************************/
/*                                   */
/* Global variables for this Command */
/*                                   */
/*************************************/

char temp_string[135];
extern char dir[256];
Form define_form;
char new_form_name[255];
char form_name[255];
extern char symbol_file[200];
int symbol_number;

int menu_type;
int new_menu;

int orig_popup_rows;
int orig_popup_cols;
int popup_rows;
int popup_cols;

int panel_cols_top;
int panel_cols_2nd;
int panel_cols_3rd;
int panel_cols_4th;
int panel_ysize_top;
int panel_ysize_2nd;
int panel_ysize_3rd;
int panel_ysize_4th;

int level_found_top;
int level_found_2nd;
int level_found_3rd;
int level_found_4th;

/************************************/
/*                                  */
/*  External variable declarations  */
/*                                  */
/************************************/

extern Form work_form;
extern Form Message_form;
extern void fi_work_form();
extern int command_is_active;
extern char current_command_string[80];
extern char *realloc();
extern char *calloc();
extern char *expand_shell_vars();
extern char execute_dir[200];

extern int vs_x_size;
extern int vs_y_size;
extern Form save_form;
extern Display *display;

extern char language[80];

extern int gadget_list [255][100];
extern char palette_name [255][20];
extern int gadget_count [255];
extern int palette_level [255];
extern int palette_count;
extern int group_list[255];


Goober_stop(void)
{
}

/***************************************************************************/
/*                                                                         */
/*                        kill_define_menu()                               */
/*                                                                         */
/*    This function is called by the executive when three conditions are   */
/* met.  First the a new command has been activated by the operator        */
/* pressing a menu button.  Secondly command_is_active flag is set to      */
/* DEFINE_MENU indicating that this command is executing.  Thirdly the     */
/* command autokill flag is set.                                           */
/*                                                                         */
/*    This command provides a graceful freeing up of any resources that    */
/* might be tied up by the define form command.  If the define form is     */
/* still displayed, then it will be deleted.  Also the message prompts     */
/* will be cleared in preparation for the new command, whatever it is.     */
/*                                                                         */
/***************************************************************************/

void kill_define_menu(void)
{
char t_str[2000];

   if (define_form != NULL)
      FIf_erase (define_form);
   
   FIfld_set_text (Message_form, 11, 0, 0, "", 0);
   FIg_display (Message_form, 11);
   FIfld_set_text (Message_form, 33, 0, 0, "", 0);
   FIg_display (Message_form, 33);
   FIfld_set_text (Message_form, 44, 0, 0, "", 0);
   FIg_display (Message_form, 44);

   UMSGetByNum (t_str, MB_P_SELCOM, 0);
   FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);
   
   if (save_form != NULL)
      FIf_erase (save_form);
 
   command_is_active = 0;
   strcpy(current_command_string, "None");
}
/*------------------------------------------------------------------------*/

void Create_blank_button (int label,
                         int x_size,
                         int y_size,
                         int x_pos,
                         int y_pos)
{
int status;
struct standard_st standard_attr;

   status = FIg_new (work_form, FI_BUTTON, label);

   standard_attr.xlo = (short)x_pos;
   standard_attr.ylo = (short)y_pos;
   standard_attr.xhi = (short)(x_pos + x_size);
   standard_attr.yhi = (short)(y_pos + y_size);
   standard_attr.attr_mask = 0;
   standard_attr.value = 0.000000;
   standard_attr.bodysize = 15.000000;
   standard_attr.text = "";
   standard_attr.help_topic = "";
   standard_attr.command = "";
   standard_attr.fontname = "";
   standard_attr.off_color = FI_BLACK;
   standard_attr.on_color = FI_YELLOW;
   standard_attr.symbol_index = 120;     /* Blank slot */
   standard_attr.symbol_index2 = 0;
   standard_attr.next_in_seq = -1;

   FIg_set_standard_variables (work_form, label, &standard_attr);

   FIg_set_attr (work_form, label, FI_INITIAL_NOTIFY |
                                   FI_NO_COMPLETE_NOTIFY);

   FIg_set_erase_color (work_form, label, FI_LT_GREY);

   FIg_set_justification (work_form, label, FI_CENTER_JUSTIFIED);

   FIbtn_set_auto_pop_up_off (work_form, label);

   FIg_activate (work_form, label);
}

/*------------------------------------------------------------------------*/

void Create_initial_blank_menu_bar_buttons(void)
{
int x;
int group_label;
int button_label;

   FIf_get_next_label (work_form, &group_label);
   FIg_new (work_form, FI_GROUP, group_label);
   group_list[0] = group_label;

   FIgrp_set_pass_on (work_form, group_label);
   FIgrp_set_single_select_on (work_form, group_label);

   for (x = 0; x < 11; x++)
   {
      FIf_get_next_label (work_form, &button_label);
      Create_blank_button (button_label, 90, 47, x * 90, 2);
      FIg_add_to_group (work_form, button_label, group_label);
      gadget_list [0][x] = button_label;
   }
   
   gadget_count[0] = 11;
}

/*------------------------------------------------------------------------*/

void Create_initial_blank_menu_panel_buttons(void)
{
int xsize, ysize, x;
int group_label;
int button_label;

   FIf_get_next_label (work_form, &group_label);
   FIg_new (work_form, FI_GROUP, group_label);
   group_list[0] = group_label;

   FIgrp_set_pass_on (work_form, group_label);
   FIgrp_set_single_select_on (work_form, group_label);

      xsize = 180 / panel_cols_top;
      ysize = panel_ysize_top;      

      for (x = 0; x < panel_cols_top; x++)
      {
         FIf_get_next_label (work_form, &button_label);
         Create_blank_button (button_label, xsize, ysize, 
                                            x * xsize, 2);
         FIg_add_to_group (work_form, button_label, group_label);
         gadget_list [0][x] = button_label;
      }
      gadget_count[0] = panel_cols_top;
}

/*------------------------------------------------------------------------*/

void Create_initial_blank_popup_menu_buttons(void)
{
int group_label, button_label;
int x;

   gadget_count[0] = popup_rows * popup_cols;

   FIf_get_next_label (work_form, &group_label);
   FIg_new (work_form, FI_GROUP, group_label);
   group_list[0] = group_label;

   FIgrp_set_pass_on (work_form, group_label);
   FIgrp_set_single_select_on (work_form, group_label);

   for (x = 0; x < gadget_count[0]; x++)
   {
      FIf_get_next_label (work_form, &button_label);
      Create_blank_button (button_label, 43, 45,
                           (x % popup_cols) * 43, 
                           2 + ((x / popup_cols) * 45));
      FIg_add_to_group (work_form, button_label, group_label);
      gadget_list [0][x] = button_label;
   }
}

/*------------------------------------------------------------------------*/

Setup_sub_palette (Form form,
                   int sub_palette_level,
                   int base_line)
{
char t_str[300];
int group_label;
int my_palette_count;
int x, y, gdt_type;
int num_buttons, temp;
int next_base_line = 0;
int x_pos, y_pos, x_pos2, y_pos2;
int status, button_label;
struct FIgadget_obj * gadget;

   palette_level[palette_count] = sub_palette_level;
   FIf_get_name (form, t_str);
   strcpy (&(palette_name [palette_count][0]), t_str);

   FIf_get_next_label (work_form, &group_label);
   FIg_new (work_form, FI_GROUP, group_label);
   group_list [palette_count] = group_label;
   FIgrp_set_pass_on (work_form, group_label);
   FIgrp_set_single_select_on (work_form, group_label);

   /**************************************************************/
   /*                                                            */
   /* Calculate where the next sub-palette's base_line would be  */
   /* by determining this palette's button size, buttons per row */
   /* and number of buttons to display.  Add this to the current */
   /* palette's base_line to determine the next palette's        */
   /* base_line.                                                 */
   /*                                                            */
   /**************************************************************/

   num_buttons = 0;
   for (x = 11; x < 1000; x++)
   {
      status = FIg_get_type (form, x, &gdt_type);

      if ((status == FI_SUCCESS) &&
          (gdt_type == FI_BUTTON))
          num_buttons++;
   }
   
   if (sub_palette_level == 1)
   {
      next_base_line = base_line + 
                       ((num_buttons / panel_cols_top) * panel_ysize_top);
      if (num_buttons % panel_cols_top)
         next_base_line += panel_ysize_top;
   }

   if (sub_palette_level == 2)
   {
      next_base_line = base_line + 
                       ((num_buttons / panel_cols_2nd) * panel_ysize_2nd);
      if (num_buttons % panel_cols_2nd)
         next_base_line += panel_ysize_2nd;
   }

   if (sub_palette_level == 3)
   {
      next_base_line = base_line + 
                       ((num_buttons / panel_cols_3rd) * panel_ysize_3rd);
      if (num_buttons % panel_cols_3rd)
         next_base_line += panel_ysize_3rd;
   }

   /********************************************************************/
   /*                                                                  */
   /* Sort the gadgets in the gadget_list array, similarly to the way  */
   /* it is handled for popup_menus.                                   */
   /*                                                                  */
   /********************************************************************/

   for (x = 11; x < 1000; x++)
   {
      status = FIg_get_type (form, x, &gdt_type); 
      if ((status == FI_SUCCESS) && (gdt_type == FI_BUTTON))
      {
         gadget_list[palette_count][gadget_count[palette_count]] = x;
         gadget_count[palette_count]++;
      }
   }

   /*******************************************************************/
   /*                                                                 */
   /*  Sort all of the buttons in the gadget_list array in ascending  */
   /*  order depending on their y_position value.                     */
   /*                                                                 */
   /*******************************************************************/

   for (x = 0; x < (gadget_count[0] - 1); x++)
   {
      FIg_get_location (form, gadget_list[palette_count][x], &x_pos, &y_pos);

      for (y = x+1; y < gadget_count[palette_count]; y++)
      {
         FIg_get_location (work_form, gadget_list[palette_count][y], 
                                      &x_pos2, &y_pos2);

         if (y_pos2 < y_pos)
         {
            temp = gadget_list[palette_count][x];
            gadget_list[palette_count][x] = gadget_list[palette_count][y];
            gadget_list[palette_count][y] = temp;
            y_pos = y_pos2;
         }
      }
   }

   /*********************************************************************/
   /*                                                                   */
   /* Now sort gadgets that have the same y values into ascending order */
   /* based on their x value.                                           */
   /*                                                                   */
   /*********************************************************************/

   for (x = 0; x < (gadget_count[palette_count] - 1); x++)
   {
      FIg_get_location (form, gadget_list[palette_count][x], &x_pos, &y_pos);

      for (y = x+1; y < gadget_count[palette_count]; y++)
      {
         FIg_get_location (form, gadget_list[palette_count][y], &x_pos2, &y_pos2);

         if ((y_pos2 == y_pos) && (x_pos2 < x_pos))
         {
            temp = gadget_list[palette_count][x];
            gadget_list[palette_count][x] = gadget_list[palette_count][y];
            gadget_list[palette_count][y] = temp;
            x_pos = x_pos2;
         }
      }
   }

   /*****************************************************************/
   /*                                                               */
   /* Copy all of these gadgets from the temp_form to the work_form */
   /*                                                               */
   /*****************************************************************/

   Goober_stop();

   for (x = 0; x < gadget_count[palette_count]; x++)
   {
   int color, index, xsize = 0, ysize = 0, xpos = 0, ypos = 0;
   int attr;
   char fontname[200];
   float bodysize;
   struct FIbtn_obj * gadget;
   struct FIbtn_obj * new_gadget;
   struct standard_st standard_attr;
   char command[300];

      FIf_get_next_label (work_form, &button_label);
      FIg_new (work_form, FI_BUTTON, button_label);

      if (sub_palette_level == 1)
      {
         xsize = 180 / panel_cols_top;
         ysize = panel_ysize_top;
         xpos = ((x % panel_cols_top) * xsize);
         ypos = base_line + ((x / panel_cols_top) * panel_ysize_top);
      }
      if (sub_palette_level == 2)
      {
         xsize = 180 / panel_cols_2nd;
         ysize = panel_ysize_2nd;
         xpos = ((x % panel_cols_2nd) * xsize);
         ypos = base_line + ((x / panel_cols_2nd) * panel_ysize_2nd);
      }
      if (sub_palette_level == 3)
      {
         xsize = 180 / panel_cols_3rd;
         ysize = panel_ysize_3rd;
         xpos = ((x % panel_cols_3rd) * xsize);
         ypos = base_line + ((x / panel_cols_3rd) * panel_ysize_3rd);
      }
      if (sub_palette_level == 4)
      {
         xsize = 180 / panel_cols_4th;
         ysize = panel_ysize_4th;
         xpos = ((x % panel_cols_4th) * xsize);
         ypos = base_line + ((x / panel_cols_4th) * panel_ysize_4th);
      }

      FIg_get_attr (form, gadget_list[palette_count][x], &attr);

      if (attr & FI_TEXT_GADGET)
      {
         FIg_get_font (form, gadget_list[palette_count][x], fontname, 
                                                            &bodysize);
         FIg_set_font (work_form, button_label, fontname, bodysize);
         FIg_get_text (form, gadget_list[palette_count][x], t_str);
      }
      else
      {
         FIg_get_symbol_file (form, gadget_list[palette_count][x], fontname);
         FIg_get_off_symbol_index (form, gadget_list[palette_count][x], &index);
         bodysize = 15.0;
         t_str[0] = '\0';
      }

      standard_attr.xlo = (short)xpos;
      standard_attr.ylo = (short)ypos;
      standard_attr.xhi = (short)(xpos + xsize);
      standard_attr.yhi = (short)(ypos + ysize);
      standard_attr.attr_mask = attr;
      standard_attr.value = 0.000000;
      standard_attr.bodysize = bodysize;
      standard_attr.text = t_str;
      standard_attr.help_topic = "";
      FIg_get_command (form, gadget_list[palette_count][x], command);
      standard_attr.command = command;
      standard_attr.fontname = fontname;
      FIg_get_off_color (form, gadget_list[palette_count][x], &color);
      standard_attr.off_color = color;
      FIg_get_on_color (form, gadget_list[palette_count][x], &color);
      standard_attr.on_color = color;
      standard_attr.symbol_index = index;
      standard_attr.symbol_index2 = 0;
      standard_attr.next_in_seq = -1;

      FIg_set_standard_variables (work_form, button_label, &standard_attr);

      FIg_set_erase_color (work_form, button_label, FI_LT_GREY);

      FIg_set_justification (work_form, button_label, FI_CENTER_JUSTIFIED);

      FIbtn_set_auto_pop_up_off (work_form, button_label);

      gadget = (struct FIbtn_obj *) _FI_g_get_id ((struct FIform_obj *)form, gadget_list[palette_count][x]);
      new_gadget = (struct FIbtn_obj *) _FI_g_get_id ((struct FIform_obj *)work_form, button_label);

      new_gadget->FIbtn.menu_button = gadget->FIbtn.menu_button;
            
      /* calloc area for palette name to be written to */

      new_gadget->FIbtn.palette = calloc (1, 30);

      if ((gadget->FIbtn.menu_button) &&
          (gadget->FIbtn.palette[0] != (char) NULL))
          strcpy (new_gadget->FIbtn.palette, gadget->FIbtn.palette);

      /* Now replace the gadget_list array entry which points to the  */
      /* temp form, with one pointing to the copied gadget on the     */
      /* work_form.                                                   */

      gadget_list[palette_count][x] = button_label;
      FIg_activate (work_form, button_label);
   }

   /* Now add all gadgets to the newly created group */

   for (x = 0; x < gadget_count[palette_count]; x++)
      FIg_add_to_group (work_form, gadget_list[palette_count][x], group_list[palette_count]);

   /* Only the top palette should be initially displayed */

   if (sub_palette_level > 1)
      FIg_erase (work_form, group_list[palette_count]);

   /* Delete the temp form that button gadgets were copied from */

   FIf_delete (form);

   my_palette_count = palette_count;
   palette_count++;

   /* Finally process any sub-palettes this palette might have */

   for (x = 0; x < gadget_count[my_palette_count]; x++)
   {
   Form temp_form;

      gadget = _FI_g_get_id ((struct FIform_obj *)work_form, gadget_list[my_palette_count][x]);
      if ((((struct FIbtn_obj *)gadget)->FIbtn.menu_button) &&
          (((struct FIbtn_obj *)gadget)->FIbtn.palette[0] != (char) NULL))
      {
         strcpy (t_str, dir);
         strcat (t_str, "/");
         strcat (t_str, ((struct FIbtn_obj *)gadget)->FIbtn.palette);

         status = FIf_new (100,                 /* form label          */
                           t_str,               /* form path           */
                (int (*)())fi_work_form,        /* form input function */
                           &temp_form);         /* pointer to form     */
         Setup_sub_palette (temp_form, sub_palette_level + 1, next_base_line);
      }
   }
}

/*------------------------------------------------------------------------*/

void Setup_palette_arrays (void)
{
int x, y;
int gdt_type;
int x_pos, y_pos;
int x_pos2, y_pos2;
int temp;
int status;
char t_str[300];

   if (menu_type == MENU_BAR)
   {
      palette_count = 1;
      strcpy (&(palette_name[0][0]), form_name);
      gadget_count[0] = 0;

      /*********************************************************************/
      /*                                                                   */
      /* Create the group gadget that all buttons on the menubar belong to */
      /*                                                                   */
      /*********************************************************************/

      FIf_get_next_label (work_form, &(group_list[0]));

      FIg_new (work_form, FI_GROUP, group_list[0]);
      FIgrp_set_pass_on (work_form, group_list[0]);
      FIgrp_set_single_select_on (work_form, group_list[0]);

      /***************************************/
      /*                                     */
      /*  Locate all buttons on the menubar  */
      /*                                     */
      /***************************************/

      for (x = 11; x < 1000; x++)
      {
         status = FIg_get_type (work_form, x, &gdt_type); 
         if ((status == FI_SUCCESS) && (gdt_type == FI_BUTTON))
         {
            gadget_list[0][gadget_count[0]] = x;
            gadget_count[0]++;
         }
      }

      /*******************************************************************/
      /*                                                                 */
      /*  Sort all of the buttons in the gadget_list array in ascending  */
      /*  order depending on their x_position value.                     */
      /*                                                                 */
      /*******************************************************************/

      for (x = 0; x < (gadget_count[0] - 1); x++)
      {
         FIg_get_location (work_form, gadget_list[0][x], &x_pos, &y_pos);

         for (y = x+1; y < gadget_count[0]; y++)
         {
            FIg_get_location (work_form, gadget_list[0][y], &x_pos2, &y_pos2);

            if (x_pos2 < x_pos)
            {
               temp = gadget_list[0][x];
               gadget_list[0][x] = gadget_list[0][y];
               gadget_list[0][y] = temp;
               x_pos = x_pos2;
            }
         }
      }

      /* Now add all gadgets to the newly created group */

      for (x = 0; x < gadget_count[0]; x++)
         FIg_add_to_group (work_form, gadget_list[0][x], group_list[0]);
   }
   else if (menu_type == POPUP_MENU)
   {
      palette_count = 1;
      strcpy (&(palette_name[0][0]), form_name);
      gadget_count[0] = 0;

      /*********************************************************************/
      /*                                                                   */
      /* Create the group gadget that all buttons on the menubar belong to */
      /*                                                                   */
      /*********************************************************************/

      FIf_get_next_label (work_form, &(group_list[0]));

      FIg_new (work_form, FI_GROUP, group_list[0]);
      FIgrp_set_pass_on (work_form, group_list[0]);
      FIgrp_set_single_select_on (work_form, group_list[0]);

      /***************************************/
      /*                                     */
      /*  Locate all buttons on the menubar  */
      /*                                     */
      /***************************************/

      for (x = 11; x < 1000; x++)
      {
         status = FIg_get_type (work_form, x, &gdt_type); 
         if ((status == FI_SUCCESS) && (gdt_type == FI_BUTTON))
         {
            gadget_list[0][gadget_count[0]] = x;
            gadget_count[0]++;
         }
      }

      /*******************************************************************/
      /*                                                                 */
      /*  Sort all of the buttons in the gadget_list array in ascending  */
      /*  order depending on their y_position value.                     */
      /*                                                                 */
      /*******************************************************************/

      for (x = 0; x < (gadget_count[0] - 1); x++)
      {
         FIg_get_location (work_form, gadget_list[0][x], &x_pos, &y_pos);

         for (y = x+1; y < gadget_count[0]; y++)
         {
            FIg_get_location (work_form, gadget_list[0][y], &x_pos2, &y_pos2);

            if (y_pos2 < y_pos)
            {
               temp = gadget_list[0][x];
               gadget_list[0][x] = gadget_list[0][y];
               gadget_list[0][y] = temp;
               y_pos = y_pos2;
            }
         }
      }

      /*********************************************************************/
      /*                                                                   */
      /* Now sort gadgets that have the same y values into ascending order */
      /* based on their x value.                                           */
      /*                                                                   */
      /*********************************************************************/

      for (x = 0; x < (gadget_count[0] - 1); x++)
      {
         FIg_get_location (work_form, gadget_list[0][x], &x_pos, &y_pos);

         for (y = x+1; y < gadget_count[0]; y++)
         {
            FIg_get_location (work_form, gadget_list[0][y], &x_pos2, &y_pos2);

            if ((y_pos2 == y_pos) && (x_pos2 < x_pos))
            {
               temp = gadget_list[0][x];
               gadget_list[0][x] = gadget_list[0][y];
               gadget_list[0][y] = temp;
               x_pos = x_pos2;
            }
         }
      }

      /* Now add all gadgets to the newly created group */

      for (x = 0; x < gadget_count[0]; x++)
         FIg_add_to_group (work_form, gadget_list[0][x], group_list[0]);

      /*************************************************************/
      /*                                                           */
      /* Based on the popup_rows and popup_cols values, alter the  */
      /* size of the form.  Then relocate the gadgets on the form. */
      /* Finally delete any gadgets that exceed the form's space.  */
      /*                                                           */
      /*************************************************************/

       FIf_set_size (work_form, popup_cols * 43,
                                4 + popup_rows * 45);

       for (x = 0; x < popup_cols * popup_rows; x++)
          if (x < gadget_count[0])
             FIg_set_location (work_form, gadget_list[0][x],
                           (x % popup_cols) * 43, 
                           2 + ((x / popup_cols) * 45));

       if (gadget_count[0] > (popup_rows * popup_cols))
       {
          for (x = (popup_rows * popup_cols); x < gadget_count[0]; x++)
              FIg_delete (work_form, gadget_list[0][x]);
          gadget_count[0] = popup_rows * popup_cols;
       }
   }
   else  /* menu_type == MENU_PANEL */
   {
   Form palette_form;

      t_str[0] = '\0';    

      status = FIf_new (100,                    /* form label          */
                        t_str,                  /* form path           */
             (int (*)())fi_work_form,           /* form input function */
                        &work_form);            /* pointer to form     */

      FIf_set_initial_notification_routine (work_form, (int (*)())fi_work_form);

      status = FIf_set_collapse_symbol (work_form, 
                                      "collapse.icon", 2);

      FIf_set_size (work_form, 186, 828);
      FIf_set_location (work_form, 0, 75);

      palette_count = 0;
      for (x = 0; x < 255; x++)
         gadget_count[x] = 0;
     
      strcpy (t_str, dir);
      strcat (t_str, "/");
      strcat (t_str, form_name);

      status = FIf_new (100,                    /* form label          */
                        t_str,                  /* form path           */
             (int (*)())fi_work_form,           /* form input function */
                        &palette_form);         /* pointer to form     */

      strcpy (&(palette_name[0][0]), form_name);

      /*  Recursively call this routine until all sub-palettes have   */
      /*  been processed.   GMD 7/31/91                               */

      /*  Middle parameter is palette level                           */

      /*  The last parameter is the base_line.  This specifies the    */
      /*  Y value to use when placing the first row of buttons for    */
      /*  this sub-palette.                                           */

      XSynchronize (_FI_display, 1);
      Setup_sub_palette (palette_form, 1, 2);
      XSynchronize (_FI_display, 0);
   }
}

/*------------------------------------------------------------------------*/

void Determine_menu_type (Form form,
                         int *type)
{
int all_buttons_on_same_row = 1;
int sub_palette_button_found = 0;
int non_button_gadget_found = 0;
int x, y, i, gdt_type, dummy_int;
int top_row_y_value = -1;
struct FIgadget_obj * gadget;
int status;

   for (i = 11; i < 1000; i++)
   {
      status = FIg_get_type (form, i, &gdt_type);
      if (status == FI_SUCCESS)
      {
         if (gdt_type == FI_GROUP)
             dummy_int = 0;    /* Do nothing */
         else if (gdt_type == FI_BUTTON)
         {
            FIg_get_location (form, i, &x, &y);

            if (top_row_y_value == -1)
               top_row_y_value = y;
            else
               if (y != top_row_y_value)
                  all_buttons_on_same_row = 0;

            gadget = _FI_g_get_id ((struct FIform_obj *)form, i);
            if ((((struct FIbtn_obj *)gadget)->FIbtn.menu_button) &&
                (((struct FIbtn_obj *)gadget)->FIbtn.palette[0] != (char) NULL))
            {
               sub_palette_button_found = 1;
               i = 1000;
            }
         }
         else  /* Not a button gadget */
         {
            non_button_gadget_found = 1;
            i = 1000;
         }
      }
   }

   if (non_button_gadget_found)
      * type = FORM;
   else if (sub_palette_button_found)
      * type = MENU_PANEL;
   else if (all_buttons_on_same_row)
      * type = MENU_BAR;
   else
      * type = POPUP_MENU; 

}

/*------------------------------------------------------------------------*/

/*******************************************************************/
/*                                                                 */
/*                    _is_a_menu (file, directory)                 */
/*                                                                 */
/*    This function determines whether or not a specified file is  */
/* a menu.  The function attempts to open the file.  If it fails   */
/* then a FALSE value will be returned to the caller.              */
/*                                                                 */
/*    If the file exists the both the ascii version and binary     */
/* form headers will be checked for.  If the format is valid then  */
/* a true value will be returned to the caller, otherwise a false  */
/* value will be returned to the caller.                           */
/*                                                                 */
/*    The function expects two string values.  The first is the    */
/* name of the file that you wish to check.  The second is the     */
/* full path of the directory that the file is located in.  If you */
/* wish to look in the current directory, then specify a null      */
/* string for the directory.                                       */
/*                                                                 */
/*******************************************************************/

char _is_a_menu (char *file,
                 char *directory)
{
    char path[100];
    extern	stat();
    int type, status;

    if (strlen (directory))
    {
	strcpy (path, directory);
	strcat (path, "/");
	strcat (path, file);		
    }
    else
    {
	strcpy (path, file);
    }

	/*** see if this file exists, and is a regular file, or a ***/
	/***   symbolic link                                      ***/

    status = FIf_new (100, path, (int (*)())fi_work_form, &work_form);

    if (status == FI_SUCCESS)
    {
       Determine_menu_type (work_form, &type);

       FIf_delete (work_form);
       work_form = NULL;
    }
    else
    {
       work_form = NULL;
       type = 0;
    }

    if (type > 0)   /* type 0 is a regular I/FORM, not a menu */
       return (TRUE);
    
    return ( FALSE );
}

/*-------------------------------------------------------------------------*/

/**********************************************************************/
/*                                                                    */
/*                            list_directory()                        */
/*                                                                    */
/*    This function is used to read the contents of a directory and   */
/* then list all valid form files to the define form's multi-line     */
/* FORM_LIST gadget.  The directory to be searched is contained in    */
/* the global variable dir.                                           */
/*                                                                    */
/**********************************************************************/

int list_directory(void)
{
    int	   x;
    struct dirent     *dp;
    DIR    *dirp;
    int status;

    /* New for 1.2.0 --- GMD */

    char form_filename[1000][20];
    char temp_filename[20];
    int y, z;

    dirp = opendir ( dir );
    if ( dirp == NULL )
    {
       UMSGetByNum (temp_string, MB_E_BADOPNDIR, 0);
       print_error (define_form, MSG_FLD, temp_string);
       FIfld_set_num_rows (define_form, FILENAME_LIST_FLD, 0);
       return (FI_SUCCESS);
    }
    else
    {
        UMSGetByNum (temp_string, MB_I_SCANFILE, 0);

	x = 0;
	while (( dp = readdir ( dirp )) != NULL )
	{	
	    if (( strcmp ( dp->d_name, ".." ) != (int) NULL ) &&
		( strcmp ( dp->d_name, "." ) != (int) NULL ))
	    {
	        if ( _is_a_menu ( dp->d_name, dir ) )
		{
                   strcpy(&(form_filename[x][0]),dp->d_name);
                   x++;
		}
	    }
	}

	if ( x )   /* There are forms in the directory */
	{
           FIfld_set_num_rows (define_form, FILENAME_LIST_FLD, 0);
           
           if (x == 1)   /* Only one entry, so no need to sort */
	   {
              strcpy(temp_string, &(form_filename[0][0]));

              status = FIfld_set_text(define_form, FILENAME_LIST_FLD, 0, 0, 
                                      temp_string, 0);
	   }
           else   /* Need to sort the files into alphabetical order */
           {      /* before placing them into the form.             */

              for (y=0; y < x - 1; y++)
              {
                 for (z=y+1; z < x; z++)
                 {
                    if (strcmp (&(form_filename[y][0]),
                                &(form_filename[z][0])) > 0)
                    {
                       strcpy(temp_filename, &(form_filename[y][0]));
                       strcpy(&(form_filename[y][0]),&(form_filename[z][0]));
                       strcpy(&(form_filename[z][0]),temp_filename);
                    }
                 }
              }

              /* Now that they are sorted, place them into the form */

              FIg_erase (define_form, FILENAME_LIST_FLD);

              for (y = 0; y < x; y++)
              {
                 strcpy(temp_string, &(form_filename[y][0]));

                 status = FIfld_set_text(define_form, FILENAME_LIST_FLD, y, 0, 
                                         temp_string, 0);
              }
           }
           status = FIfld_set_num_rows (define_form, FILENAME_LIST_FLD, x);

           status = FIfld_set_active_row (define_form, FILENAME_LIST_FLD, 0, 0);
             
           FIg_display (define_form, FILENAME_LIST_FLD);
           
           status = FIg_erase(define_form, MSG_FLD);
	}
	else
	{
           UMSGetByNum (temp_string, MB_E_NOMENUS, 0);
	   print_error (define_form, MSG_FLD, temp_string);
	   
	   FIfld_set_num_rows (define_form, FILENAME_LIST_FLD, 0);
        }

	closedir ( dirp );
    }
    return ( FI_SUCCESS );
}

/*-------------------------------------------------------------------------*/

/*************************************************************************/
/*                                                                       */
/*                        init_define_form()                             */
/*                                                                       */
/*    This function performs operations that need to be done as soon as  */
/* the define form is displayed, but before the operator can interact    */
/* with the define form.  There are several hidden gadgets that need     */
/* to be displayed, as well as setting up the default directory and      */
/* form filelist.                                                        */
/*                                                                       */
/*************************************************************************/

void init_define_form(void)
{
    char str[200];
    int status;
 
    strcpy (str, dir);
    status = FIfld_set_text (define_form, DIRECTORY_FLD, 0, 0, str, 0);

    list_directory();
}

void Determine_button_size (Form palette_form,
                           int pal_level)
{
int x, status;
int xsize, ysize;
int gdt_type;
struct FIgadget_obj * gadget; 
Form sub_palette_form;
char t_str[300];

   for (x = 11; x < 1000; x++)
   {
      status = FIg_get_type (palette_form, x, &gdt_type);

      if (status == FI_SUCCESS)
      {
         if (gdt_type == FI_BUTTON)
         {
            FIg_get_size (palette_form, x, &xsize, &ysize);

            if (pal_level == 1)
            {
               panel_cols_top  = 180 / xsize;
               if (panel_cols_top < 1)
                  panel_cols_top = 1;
               panel_ysize_top = ysize;
            }
            if (pal_level == 2)
            {
               panel_cols_2nd  = 180 / xsize;
               if (panel_cols_2nd < 1)
                  panel_cols_2nd = 1;
               panel_ysize_2nd = ysize;
               level_found_2nd = 1;
            }
            if (pal_level == 3)
            {
               panel_cols_3rd  = 180 / xsize;
               if (panel_cols_3rd < 1)
                  panel_cols_3rd = 1;
               panel_ysize_3rd = ysize;
               level_found_3rd = 1;
            }
            if (pal_level == 4)
            {
               panel_cols_4th  = 180 / xsize;
               if (panel_cols_4th < 1)
                  panel_cols_4th = 1;
               panel_ysize_4th = ysize;
               level_found_4th = 1;
            }
 
            /**********************************************/
            /*                                            */
            /*  See if the button has a palette attached  */
            /*                                            */
            /**********************************************/

            gadget = _FI_g_get_id ((struct FIform_obj *)palette_form, x);
            if ((((struct FIbtn_obj *)gadget)->FIbtn.menu_button) &&
                (((struct FIbtn_obj *)gadget)->FIbtn.palette[0] != (char) NULL))
            {
               strcpy (t_str, dir);
               strcat (t_str, "/");
               strcat (t_str, ((struct FIbtn_obj *)gadget)->FIbtn.palette);

               status = FIf_new (100,
                                 t_str,
                      (int (*)())fi_work_form,
                                 &sub_palette_form);

               if (status == FI_SUCCESS)
                  Determine_button_size (sub_palette_form, pal_level + 1);
            }
         }
      }
   }
   FIf_delete (palette_form);
}

/*-------------------------------------------------------------------------*/

void Determine_panel_button_sizes (void)
{
Form palette_form;
int pal_level;
char t_str[300];
int status;

   level_found_top = 1;
   level_found_2nd = 0;
   level_found_3rd = 0;
   level_found_4th = 0;

   pal_level = 1;

   strcpy (t_str, dir);
   strcat (t_str, "/");
   strcat (t_str, form_name);

   status = FIf_new (100,
                     t_str,
          (int (*)())fi_work_form,
                     &palette_form);

   /****************************************************************/
   /*                                                              */
   /*  Recursive routine that will go though each sub palette and  */
   /*  determine its size.                                         */
   /*                                                              */
   /****************************************************************/

   Determine_button_size (palette_form, pal_level);
}

/*-------------------------------------------------------------------------*/

/*************************************************************************/
/*                                                                       */
/*                     setup_new_define_form()                           */
/*                                                                       */
/*    This function is called each time the operator types in a          */
/* non-existant filename, or the name of a file that is not a form       */
/* definition file.  It prepares the form_attr structure with default    */
/* settings which will be displayed in the define form's fields when the */
/* show_define_form_info() function is called immediately after this     */
/* function finishes.  How is that for a run-on sentence?                */
/*                                                                       */
/*************************************************************************/

void setup_new_define_form(void)
{
    strcpy (new_form_name, form_name);
    form_name[0] = '\0';

    menu_type = MENU_BAR;
    new_menu = 1;

    popup_rows = 4;
    popup_cols = 4;

    panel_cols_top = 4;
    panel_cols_2nd = 3;
    panel_cols_3rd = 3;
    panel_cols_4th = 2;
    panel_ysize_top = 30;
    panel_ysize_2nd = 40;
    panel_ysize_3rd = 50;
    panel_ysize_4th = 60;

    level_found_top = 1;
    level_found_2nd = 1;
    level_found_3rd = 1;
    level_found_4th = 1;
}
 
/*--------------------------------------------------------------------------*/

/*************************************************************************/
/*                                                                       */
/*                     setup_old_define_form()                           */
/*                                                                       */
/*    This function is called each time the operator types in a          */
/* the name of a form file or selects a form from the form list multi-   */
/* line field.  It prepares the form_attr structure by loading in the    */
/* existing settings from the form file.  First a new form is built.     */
/* Next a variety of FIf_get_*() calls are made to determine the         */
/* form's current settings.  These settings are stored in the form_attr  */
/* structure.  The settings will be used to alter the define form's      */
/* fields when the show_define_form_info function is called immediately  */
/* after this function concludes.                                        */
/*                                                                       */
/*************************************************************************/

void setup_old_define_form(void)
{
   char t_str[2000];
   int status, x, y;
   
    panel_cols_top = 1;
    panel_cols_2nd = 1;
    panel_cols_3rd = 1;
    panel_cols_4th = 1;
    panel_ysize_top = 97;
    panel_ysize_2nd = 98;
    panel_ysize_3rd = 99;
    panel_ysize_4th = 100;

   strcpy (new_form_name, form_name);
   
   strcpy (t_str, dir);
   strcat (t_str, "/");
   strcat (t_str, form_name);

   status = FIf_new (100,
                     t_str,
          (int (*)())fi_work_form,
                     &work_form);
                    
   if (status != 0) 
   {
      form_name[0] = '\0';
      new_form_name[0] = '\0';	
   
      UMSGetByNum (temp_string, MB_E_BADFRMT, "%d", status);
      print_error (define_form, MSG_FLD, temp_string);
      
      FIfld_set_text (define_form, FILENAME_FLD, 0, 0, "", 0); 
    
      work_form = NULL;
      return;
   } 

   /************************************************************/
   /*                                                          */
   /* Need some way of checking which type of menu this is:    */
   /* If it is a Menu Panel, then determine what the top       */
   /* level's button size is and select that button on the     */
   /* define form.  Also display the different menu size       */
   /* buttons.       GMD 6/28/91                               */
   /*                                                          */
   /************************************************************/
   
   Determine_menu_type (work_form, &menu_type);

   if (menu_type == 0)
   {
      form_name[0] = '\0';
      new_form_name[0] = '\0';	

      UMSGetByNum (temp_string, MB_E_NOTAMENU, 0);
      print_error (define_form, MSG_FLD, temp_string);
   }
   else
   {
      if (menu_type == MENU_PANEL)
      {
          /*************************************************************/
          /*                                                           */
          /*  Determine what the button sizes for the various levels   */
          /*  of the menu panel are.  The steps needed to calculate    */
          /*  this are similar to the steps needed to initialize the   */
          /*  gadget array.  So maybe you should go ahead and          */
          /*  calculate it here, since you need to anyway to determine */
          /*  the size of the buttons.    GMD 7/29/91                  */
          /*                                                           */
          /*************************************************************/

          Determine_panel_button_sizes ();
      }

      if (menu_type == POPUP_MENU)
      {
      int x_list[50];
      int y_list[50];
      int x_list_count = 0;
      int y_list_count = 0;
      int xpos, ypos, match;
      int gdt_type;

         /***********************************************************/
         /*                                                         */
         /* Determine how many rows and columns the popup menu has. */
         /* To determine the number of rows, check all button y     */
         /* location values.  Each different y value that you find  */
         /* represents a different row.  Then check each group of   */
         /* buttons that all have the same y value.  Whichever      */
         /* group has the most buttons, represents the number of    */
         /* columns for the popup menu.                             */
         /*                                                         */
         /***********************************************************/

         for (x = 11; x < 1000; x++)
         {
            status = FIg_get_type (work_form, x, &gdt_type); 
            if ((status == FI_SUCCESS) && (gdt_type == FI_BUTTON))
            {
               FIg_get_location (work_form, x, &xpos, &ypos);

               if (x_list_count == 0)
               {
                  x_list[x_list_count] = xpos;
                  x_list_count++;
               }
               else
               {
                  match = 0;
                  for (y = 0; y < x_list_count; y++)
                     if (x_list[y] == xpos)
                        match = 1;

                  if (match == 0)
                  {
                     x_list[x_list_count] = xpos;
                     x_list_count++;
                  }
               }

               if (y_list_count == 0)
               {
                  y_list[y_list_count] = ypos;
                  y_list_count++;
               }
               else
               {
                  match = 0;
                  for (y = 0; y < y_list_count; y++)
                     if (y_list[y] == ypos)
                        match = 1;

                  if (match == 0)
                  {
                     y_list[y_list_count] = ypos;
                     y_list_count++;
                  }
               }
            }
         }
         popup_rows = y_list_count;
         popup_cols = x_list_count;
         orig_popup_rows = popup_rows;
         orig_popup_cols = popup_cols;
      }
   }

   FIf_delete (work_form);

   work_form = NULL;
   new_menu = 0;
}

/*--------------------------------------------------------------------------*/

/*************************************************************************/
/*                                                                       */
/*                    show_define_form_info()                            */
/*                                                                       */
/*    This function displays the information contained in the            */
/* form_attr structure in the various corresponding define form fields.  */
/*                                                                       */
/*************************************************************************/

void show_define_form_info(void) 
{
   FIg_erase (define_form, DECISION_BTN);
   FIg_erase (define_form, YES_BTN);
   FIg_erase (define_form, NO_BTN);

   FIg_set_state_off (define_form, BAR_MENU_CK);
   FIg_set_state_off (define_form, PANEL_MENU_CK);
   FIg_set_state_off (define_form, POPUP_MENU_CK);

   if (menu_type == MENU_BAR)
      FIg_set_state_on (define_form, BAR_MENU_CK);
   
   if (menu_type == MENU_PANEL)
      FIg_set_state_on (define_form, PANEL_MENU_CK);

   if (menu_type == POPUP_MENU)
      FIg_set_state_on (define_form, POPUP_MENU_CK);

   if (menu_type == MENU_PANEL)
   {
      if (level_found_top)
      {
         FIg_set_value (define_form, BTN_PER_ROW_TOP_FLD, (double)panel_cols_top);
         FIg_set_value (define_form, BTN_HEIGHT_TOP_FLD, (double)panel_ysize_top);
      }

      if (level_found_2nd)
      {
         FIg_set_value (define_form, BTN_PER_ROW_2ND_FLD, (double)panel_cols_2nd);
         FIg_set_value (define_form, BTN_HEIGHT_2ND_FLD, (double)panel_ysize_2nd);
      }
      else
      {
         panel_cols_2nd = panel_cols_top;
         panel_ysize_2nd  = panel_ysize_top + 10;
         FIg_set_text (define_form, BTN_PER_ROW_2ND_FLD, "");
         FIg_set_text (define_form, BTN_HEIGHT_2ND_FLD, "");
      }

      if (level_found_3rd)
      {
         FIg_set_value (define_form, BTN_PER_ROW_3RD_FLD, (double)panel_cols_3rd);
         FIg_set_value (define_form, BTN_HEIGHT_3RD_FLD, (double)panel_ysize_3rd);
      }
      else
      {
         panel_cols_3rd = panel_cols_2nd;
         panel_ysize_3rd  = panel_ysize_2nd + 10;
         FIg_set_text (define_form, BTN_PER_ROW_3RD_FLD, "");
         FIg_set_text (define_form, BTN_HEIGHT_3RD_FLD, "");
      }

      if (level_found_4th)
      {
         FIg_set_value (define_form, BTN_PER_ROW_4TH_FLD, (double)panel_cols_4th);
         FIg_set_value (define_form, BTN_HEIGHT_4TH_FLD, (double)panel_ysize_4th);
      }
      else
      {
         panel_cols_4th = panel_cols_3rd;
         panel_ysize_4th  = panel_ysize_3rd + 10;
         FIg_set_text (define_form, BTN_PER_ROW_4TH_FLD, "");
         FIg_set_text (define_form, BTN_HEIGHT_4TH_FLD, "");
      }

      FIg_erase (define_form, POPUP_MENU_MATRIX_SIZE_GROUP);

      FIg_display (define_form, OPTIONS_BEZEL);
      FIg_display (define_form, PANEL_BTN_SIZE_GROUP);
   }
   else if (menu_type == POPUP_MENU)
   {
      FIg_erase (define_form, PANEL_BTN_SIZE_GROUP);

      FIg_set_value (define_form, NUM_ROWS_FLD, (double)popup_rows);
      FIg_set_value (define_form, NUM_COLS_FLD, (double)popup_cols);

      FIg_display (define_form, OPTIONS_BEZEL);
      FIg_display (define_form, POPUP_MENU_MATRIX_SIZE_GROUP);      
   }
   else
   {
      FIg_erase (define_form, OPTIONS_BEZEL);
      FIg_erase (define_form, PANEL_BTN_SIZE_GROUP);
      FIg_erase (define_form, POPUP_MENU_MATRIX_SIZE_GROUP);
   }
}

/*-------------------------------------------------------------------------*/

/*********************************************************************/
/*                                                                   */
/*                        create_work_form()                         */
/*                                                                   */
/*    This function creates the form that the operator wishes to     */
/* define/modify.  At the present time only one form can be worked   */
/* on at a time.  This may be expanded in the future.                */
/*                                                                   */
/*********************************************************************/

void create_work_form(void) 
{
    char        t_str[200];
    int         status;
    int         symbol_number;

    /******************************/
    /*                            */
    /*  Create the new work form  */
    /*                            */
    /******************************/

    if (form_name[0] != '\0')
    {
       strcpy (t_str, dir);
       strcat (t_str, "/");
       strcat (t_str, form_name);
    }
    else   /* New form */
    {
       t_str[0] = '\0';
    }

    status = FIf_new (100,                    /* form label          */
                      t_str,                  /* form path           */
           (int (*)())fi_work_form,           /* form input function */
                      &work_form);            /* pointer to form     */

    FIf_set_initial_notification_routine (work_form, (int (*)())fi_work_form);

    /*******************************************/
    /*                                         */
    /*  Override default settings with those   */
    /*  obtained from the define form.         */
    /*                                         */
    /*******************************************/

    if (menu_type == MENU_BAR)
       symbol_number = 1;
    else
       symbol_number = 2;

    status = FIf_set_collapse_symbol (work_form, 
                                      "collapse.icon",
                                      symbol_number);

    /******************************************************************/
    /*                                                                */
    /*  Set the size and location of the form based on the menu type  */
    /*                                                                */
    /******************************************************************/

    if (menu_type == MENU_BAR)
    {
       FIf_set_size (work_form, 993, 51);
       FIf_set_location (work_form, 0, 75);

       palette_count = 1;
       palette_level[0] = 1;   /* top level */
       strcpy (&(palette_name[0][0]), new_form_name);

       Create_initial_blank_menu_bar_buttons();
    }

    if (menu_type == MENU_PANEL)
    {
       palette_count = 1;
       palette_level[0] = 1;
       strcpy (&(palette_name[0][0]), new_form_name);

       FIf_set_size (work_form, 184, 828);
       FIf_set_location (work_form, 0, 75);

       Create_initial_blank_menu_panel_buttons();
    }

    if (menu_type == POPUP_MENU)
    {
       palette_count = 1;
       palette_level[0] = 1;   /* top level */
       strcpy (&(palette_name[0][0]), new_form_name);

       FIf_set_size (work_form, popup_cols * 43,
                                4 + popup_rows * 45);
       FIf_set_location (work_form, 0, 70);

       Create_initial_blank_popup_menu_buttons();
    }

    /****************************/
    /*                          */
    /* Finally display the form */
    /*                          */
    /****************************/

    status = FIf_display (work_form);
}

/*--------------------------------------------------------------------------*/
/* ARGSUSED */
void fi_background_form (int form_label,
                        int gadget_label,
                        double value)
{
   /*  Dummy routine needed to poke new form's boundaries  */
}

/*---------------------------------------------------------------------------*/

void Verify_name_field(void)
{
int dummy_int;
int status;

    status = FIfld_get_text(define_form, FILENAME_FLD, 0, 0, 135,
 		             (unsigned char *)temp_string, &dummy_int, 
 		                                      &dummy_int);
	
    if (strlen(temp_string) > 14)
    {
       UMSGetByNum (temp_string, MB_E_BADMNUNAME, 0);
       print_error (define_form, MSG_FLD, temp_string);
 		    
       status = FIfld_set_text(define_form, FILENAME_FLD, 0, 0, 
                                            "", 0);
    }
    else
       if (strcmp(temp_string, form_name))
       {
          strcpy(form_name, temp_string);

          if (form_name[0] == '\0')
              new_form_name[0] = '\0';

          is_it_a_new_form();
       }
}

/*************************************************************************/
/*                                                                       */
/*                           fi_define_form()                            */
/*                                                                       */
/*    This massive function works in the same manner as the form_input   */
/* method did in the OM world. (Boo! Hiss!!!)                            */
/*                                                                       */
/*    There is quite a collection of gadgets, so rather than talking     */
/* about them all up here I have incorporated comments with some of the  */
/* more difficult or important gadgets that are being serviced by this   */
/* routine.                                                              */
/*                                                                       */
/*    The naming convention for all of my gadget notification routines   */
/* will start with "fi" for form input.                                  */
/*                                                                       */
/*************************************************************************/

/* ARGSUSED */
void fi_define_form (int form_label,
                    int gadget_label,
                    double value)
{
   int status;
   int i, x;
   char t_str[500];
   int dummy_int;
   double val;

    FIg_erase (define_form, MSG_FLD);
    
	    switch ( gadget_label )
	    {
                case BTN_PER_ROW_TOP_FLD:
                   FIg_get_value (define_form, BTN_PER_ROW_TOP_FLD, &val);
                   if ((int)val < panel_cols_2nd)
                   {
                      UMSGetByNum (t_str, MB_E_GENEXT, 0);
                      FIg_set_text (define_form, MSG_FLD, t_str);
                      FIg_display (define_form, MSG_FLD);
                      sprintf (t_str, "%d", panel_cols_top);
                      FIg_set_text (define_form, BTN_PER_ROW_TOP_FLD, t_str);
                   }
                   else if ((val < 1) || (val > 10))
                   {
                      UMSGetByNum (t_str, MB_E_1THRU10, 0);
                      FIg_set_text (define_form, MSG_FLD, t_str);
                      FIg_display (define_form, MSG_FLD);
                      sprintf (t_str, "%d", panel_cols_top);
                      FIg_set_text (define_form, BTN_PER_ROW_TOP_FLD, t_str);
                   }
                   else
                      panel_cols_top = (int)val;
                   break;

                case BTN_PER_ROW_2ND_FLD:
                   FIg_get_value (define_form, BTN_PER_ROW_2ND_FLD, &val);
                   if ((int)val > panel_cols_top)
                   {
                      UMSGetByNum (t_str, MB_E_LEPREV, 0);
                      FIg_set_text (define_form, MSG_FLD, t_str);
                      FIg_display (define_form, MSG_FLD);
                      sprintf (t_str, "%d", panel_cols_2nd);
                      FIg_set_text (define_form, BTN_PER_ROW_2ND_FLD, t_str);
                   }
                   else if ((int)val < panel_cols_3rd)
                   {
                      UMSGetByNum (t_str, MB_E_GENEXT, 0);
                      FIg_set_text (define_form, MSG_FLD, t_str);
                      FIg_display (define_form, MSG_FLD);
                      sprintf (t_str, "%d", panel_cols_2nd);
                      FIg_set_text (define_form, BTN_PER_ROW_2ND_FLD, t_str);
                   }
                   else if ((val < 1) || (val > 10))
                   {
                      UMSGetByNum (t_str, MB_E_1THRU10, 0);
                      FIg_set_text (define_form, MSG_FLD, t_str);
                      FIg_display (define_form, MSG_FLD);
                      sprintf (t_str, "%d", panel_cols_2nd);
                      FIg_set_text (define_form, BTN_PER_ROW_2ND_FLD, t_str);
                   }
                   else
                      panel_cols_2nd = (int)val;
                   break;

                case BTN_PER_ROW_3RD_FLD:
                   FIg_get_value (define_form, BTN_PER_ROW_3RD_FLD, &val);
                   if ((int)val > panel_cols_2nd)
                   {
                      UMSGetByNum (t_str, MB_E_LEPREV, 0);
                      FIg_set_text (define_form, MSG_FLD, t_str);
                      FIg_display (define_form, MSG_FLD);
                      sprintf (t_str, "%d", panel_cols_3rd);
                      FIg_set_text (define_form, BTN_PER_ROW_3RD_FLD, t_str);
                   }
                   else if ((int)val < panel_cols_4th)
                   {
                      UMSGetByNum (t_str, MB_E_GENEXT, 0);
                      FIg_set_text (define_form, MSG_FLD, t_str);
                      FIg_display (define_form, MSG_FLD);
                      sprintf (t_str, "%d", panel_cols_3rd);
                      FIg_set_text (define_form, BTN_PER_ROW_3RD_FLD, t_str);
                   }
                   else if ((val < 1) || (val > 10))
                   {
                      UMSGetByNum (t_str, MB_E_1THRU10, 0);
                      FIg_set_text (define_form, MSG_FLD, t_str);
                      FIg_display (define_form, MSG_FLD);
                      sprintf (t_str, "%d", panel_cols_3rd);
                      FIg_set_text (define_form, BTN_PER_ROW_3RD_FLD, t_str);
                   }
                   else
                      panel_cols_3rd = (int)val;
                   break;

                case BTN_PER_ROW_4TH_FLD:
                   FIg_get_value (define_form, BTN_PER_ROW_4TH_FLD, &val);

                   if ((int)val > panel_cols_3rd)
                   {
                      UMSGetByNum (t_str, MB_E_LEPREV, 0);
                      FIg_set_text (define_form, MSG_FLD, t_str);
                      FIg_display (define_form, MSG_FLD);
                      sprintf (t_str, "%d", panel_cols_4th);
                      FIg_set_text (define_form, BTN_PER_ROW_4TH_FLD, t_str);
                   }
                   else if ((val < 1) || (val > 10))
                   {
                      UMSGetByNum (t_str, MB_E_1THRU10, 0);
                      FIg_set_text (define_form, MSG_FLD, t_str);
                      FIg_display (define_form, MSG_FLD);
                      sprintf (t_str, "%d", panel_cols_4th);
                      FIg_set_text (define_form, BTN_PER_ROW_4TH_FLD, t_str);
                   }
                   else
                      panel_cols_4th = (int)val;
                   break;

                case BTN_HEIGHT_TOP_FLD:
                   FIg_get_value (define_form, BTN_HEIGHT_TOP_FLD, &val);
                   if ((int)val >= panel_ysize_2nd)
                   {
                      UMSGetByNum (t_str, MB_E_LTNEXT, 0);
                      FIg_set_text (define_form, MSG_FLD, t_str);
                      FIg_display (define_form, MSG_FLD);
                      sprintf (t_str, "%d", panel_ysize_top);
                      FIg_set_text (define_form, BTN_HEIGHT_TOP_FLD, t_str);
                   }
                   else if (val < 10)
                   {
                      UMSGetByNum (t_str, MB_E_GE10, 0);
                      FIg_set_text (define_form, MSG_FLD, t_str);
                      FIg_display (define_form, MSG_FLD);
                      sprintf (t_str, "%d", panel_ysize_top);
                      FIg_set_text (define_form, BTN_HEIGHT_TOP_FLD, t_str);
                   }
                   else
                      panel_ysize_top = (int)val;
                   break;

                case BTN_HEIGHT_2ND_FLD:
                   FIg_get_value (define_form, BTN_HEIGHT_2ND_FLD, &val);
                   if ((int)val <= panel_ysize_top)
                   {
                      UMSGetByNum (t_str, MB_E_GTPREV, 0);
                      FIg_set_text (define_form, MSG_FLD, t_str);
                      FIg_display (define_form, MSG_FLD);
                      sprintf (t_str, "%d", panel_ysize_2nd);
                      FIg_set_text (define_form, BTN_HEIGHT_2ND_FLD, t_str);
                   }
                   else if ((int)val >= panel_ysize_3rd)
                   {
                      UMSGetByNum (t_str, MB_E_LTNEXT, 0);
                      FIg_set_text (define_form, MSG_FLD, t_str);
                      FIg_display (define_form, MSG_FLD);
                      sprintf (t_str, "%d", panel_ysize_2nd);
                      FIg_set_text (define_form, BTN_HEIGHT_2ND_FLD, t_str);
                   }
                   else if (val < 10)
                   {
                      UMSGetByNum (t_str, MB_E_GE10, 0);
                      FIg_set_text (define_form, MSG_FLD, t_str);
                      FIg_display (define_form, MSG_FLD);
                      sprintf (t_str, "%d", panel_ysize_2nd);
                      FIg_set_text (define_form, BTN_HEIGHT_2ND_FLD, t_str);
                   }
                   else
                      panel_ysize_2nd = (int)val;
                   break;

                case BTN_HEIGHT_3RD_FLD:
                   FIg_get_value (define_form, BTN_HEIGHT_3RD_FLD, &val);
                   if ((int)val <= panel_ysize_2nd)
                   {
                      UMSGetByNum (t_str, MB_E_GTPREV, 0);
                      FIg_set_text (define_form, MSG_FLD, t_str);
                      FIg_display (define_form, MSG_FLD);
                      sprintf (t_str, "%d", panel_ysize_3rd);
                      FIg_set_text (define_form, BTN_HEIGHT_3RD_FLD, t_str);
                   }
                   else if ((int)val >= panel_ysize_4th)
                   {
                      UMSGetByNum (t_str, MB_E_LTNEXT, 0);
                      FIg_set_text (define_form, MSG_FLD, t_str);
                      FIg_display (define_form, MSG_FLD);
                      sprintf (t_str, "%d", panel_ysize_3rd);
                      FIg_set_text (define_form, BTN_HEIGHT_3RD_FLD, t_str);
                   }
                   else if (val < 10)
                   {
                      UMSGetByNum (t_str, MB_E_GE10, 0);
                      FIg_set_text (define_form, MSG_FLD, t_str);
                      FIg_display (define_form, MSG_FLD);
                      sprintf (t_str, "%d", panel_ysize_3rd);
                      FIg_set_text (define_form, BTN_HEIGHT_3RD_FLD, t_str);
                   }
                   else
                      panel_ysize_3rd = (int)val;
                   break;

                case BTN_HEIGHT_4TH_FLD:
                   FIg_get_value (define_form, BTN_HEIGHT_4TH_FLD, &val);

                   if ((int)val <= panel_ysize_3rd)
                   {
                      UMSGetByNum (t_str, MB_E_GTPREV, 0);
                      FIg_set_text (define_form, MSG_FLD, t_str);
                      FIg_display (define_form, MSG_FLD);
                      sprintf (t_str, "%d", panel_ysize_4th);
                      FIg_set_text (define_form, BTN_HEIGHT_4TH_FLD, t_str);
                   }
                   else if (val < 10)
                   {
                      UMSGetByNum (t_str, MB_E_GE10, 0);
                      FIg_set_text (define_form, MSG_FLD, t_str);
                      FIg_display (define_form, MSG_FLD);
                      sprintf (t_str, "%d", panel_ysize_4th);
                      FIg_set_text (define_form, BTN_HEIGHT_4TH_FLD, t_str);
                   }
                   else
                      panel_ysize_4th = (int)val;
                   break;

                case STANDARD_BTN_SIZE_BTN:
                   panel_cols_top = 4;
                   panel_cols_2nd = 3;
                   panel_cols_3rd = 3;
                   panel_cols_4th = 2;
                   panel_ysize_top = 30;
                   panel_ysize_2nd = 40;
                   panel_ysize_3rd = 50;
                   panel_ysize_4th = 60;
      FIg_set_value (define_form, BTN_PER_ROW_TOP_FLD, (double)panel_cols_top);
      FIg_set_value (define_form, BTN_PER_ROW_2ND_FLD, (double)panel_cols_2nd);
      FIg_set_value (define_form, BTN_PER_ROW_3RD_FLD, (double)panel_cols_3rd);
      FIg_set_value (define_form, BTN_PER_ROW_4TH_FLD, (double)panel_cols_4th);
      FIg_set_value (define_form, BTN_HEIGHT_TOP_FLD, (double)panel_ysize_top);
      FIg_set_value (define_form, BTN_HEIGHT_2ND_FLD, (double)panel_ysize_2nd);
      FIg_set_value (define_form, BTN_HEIGHT_3RD_FLD, (double)panel_ysize_3rd);
      FIg_set_value (define_form, BTN_HEIGHT_4TH_FLD, (double)panel_ysize_4th);
                   FIg_set_state_off (define_form, STANDARD_BTN_SIZE_BTN);
                   break;

                case NO_BTN:
                   FIg_set_state_off (define_form, NO_BTN);
                   FIg_erase (define_form, DECISION_BTN);
                   FIg_erase (define_form, NO_BTN);
                   FIg_erase (define_form, YES_BTN);

                   for (x = 5; x < 34; x++)
                      FIg_enable (define_form, x);
                   break;

                case YES_BTN:
                   FIg_set_state_off (define_form, YES_BTN);
                   orig_popup_rows = 0;
                   orig_popup_cols = 0;
                   fi_define_form (100, FI_ACCEPT, 1.0);

                   for (x = 5; x < 34; x++)
                      FIg_enable (define_form, x);
                   break;

                case DECISION_BTN:
                   FIg_set_state_on (define_form, DECISION_BTN);
                   break;

                case NUM_ROWS_FLD:
                   FIg_get_value (define_form, NUM_ROWS_FLD, &val);
                   if ((val < 1) || (val > 10))
                   {
                      UMSGetByNum (t_str, MB_E_1THRU10, 0);
                      FIg_set_text (define_form, MSG_FLD, t_str);
                      FIg_display (define_form, MSG_FLD);
                      sprintf (t_str, "%d", popup_rows);
                      FIg_set_text (define_form, NUM_ROWS_FLD, t_str);
                   }
                   else
                      popup_rows = (int)val;
                   break;

                case NUM_COLS_FLD:
                   FIg_get_value (define_form, NUM_COLS_FLD, &val);
                   if ((val < 1) || (val > 10))
                   {
                      UMSGetByNum (t_str, MB_E_1THRU10, 0);
                      FIg_set_text (define_form, MSG_FLD, t_str);
                      FIg_display (define_form, MSG_FLD);
                      sprintf (t_str, "%d", popup_cols);
                      FIg_set_text (define_form, NUM_COLS_FLD, t_str);
                   }
                   else
                      popup_cols = (int)val;
                   break;

                case BAR_MENU_CK:
 
                   if (new_menu == 1)
                   {
                      menu_type = MENU_BAR;

                      FIg_erase (define_form, OPTIONS_BEZEL);
                      FIg_erase (define_form, PANEL_BTN_SIZE_GROUP);
                      FIg_erase (define_form, POPUP_MENU_MATRIX_SIZE_GROUP);
                   }
                   else if (menu_type != MENU_BAR)
                   {
                        UMSGetByNum (temp_string, MB_E_NOCHANGE, 0);
                    	print_error (define_form, MSG_FLD, temp_string);
		        
                        FIg_set_state_off (define_form, BAR_MENU_CK);
                        if (menu_type == MENU_PANEL)
                           FIg_set_state_on (define_form, PANEL_MENU_CK);
                        else
                           FIg_set_state_on (define_form, POPUP_MENU_CK);
                   }
                   break;   

                case PANEL_MENU_CK:

                   if (new_menu == 1)
                   {
                      menu_type = MENU_PANEL;

      FIg_set_value (define_form, BTN_PER_ROW_TOP_FLD, (double)panel_cols_top);
      FIg_set_value (define_form, BTN_PER_ROW_2ND_FLD, (double)panel_cols_2nd);
      FIg_set_value (define_form, BTN_PER_ROW_3RD_FLD, (double)panel_cols_3rd);
      FIg_set_value (define_form, BTN_PER_ROW_4TH_FLD, (double)panel_cols_4th);
      FIg_set_value (define_form, BTN_HEIGHT_TOP_FLD, (double)panel_ysize_top);
      FIg_set_value (define_form, BTN_HEIGHT_2ND_FLD, (double)panel_ysize_2nd);
      FIg_set_value (define_form, BTN_HEIGHT_3RD_FLD, (double)panel_ysize_3rd);
      FIg_set_value (define_form, BTN_HEIGHT_4TH_FLD, (double)panel_ysize_4th);

                      FIg_erase (define_form, POPUP_MENU_MATRIX_SIZE_GROUP);

                      FIg_display (define_form, OPTIONS_BEZEL);
                      FIg_display (define_form, PANEL_BTN_SIZE_GROUP);
                   }
                   else if (menu_type != MENU_PANEL)
                   {
                        UMSGetByNum (temp_string, MB_E_NOCHANGE, 0);
                    	print_error (define_form, MSG_FLD, temp_string);
		        
                        FIg_set_state_off (define_form, PANEL_MENU_CK);
                        if (menu_type == MENU_BAR)
                           FIg_set_state_on (define_form, BAR_MENU_CK);
                        else
                           FIg_set_state_on (define_form, POPUP_MENU_CK);
                   }
                   break;

                case POPUP_MENU_CK:

                   if (new_menu == 1)
                   {
                      menu_type = POPUP_MENU;

                      FIg_erase (define_form, PANEL_BTN_SIZE_GROUP);

                      FIg_set_value (define_form, NUM_ROWS_FLD, (double)popup_rows);
                      FIg_set_value (define_form, NUM_COLS_FLD, (double)popup_cols);

                      FIg_display (define_form, OPTIONS_BEZEL);
                      FIg_display (define_form, POPUP_MENU_MATRIX_SIZE_GROUP);
                   }
                   else if (menu_type != POPUP_MENU)
                   {
                        UMSGetByNum (temp_string, MB_E_NOCHANGE, 0);
                    	print_error (define_form, MSG_FLD, temp_string);
		        
                        FIg_set_state_off (define_form, POPUP_MENU_CK);
                        if (menu_type == MENU_BAR)
                           FIg_set_state_on (define_form, BAR_MENU_CK);
                        else
                           FIg_set_state_on (define_form, PANEL_MENU_CK);
                   }
                   break;

 		case DIRECTORY_FLD:
 		
 		  /* Find out what the operator just typed in */
 		  
 		  status = FIfld_get_text(define_form, DIRECTORY_FLD, 0, 0, 135,
 		              (unsigned char *)temp_string, &dummy_int, 
 		                                       &dummy_int);

		  /* Expand the shell variables to full path and put back 
		     into field */

                  strcpy(dir, expand_shell_vars(temp_string));
                
                  status = FIfld_set_text(define_form, DIRECTORY_FLD, 0, 0, dir, 0);
                  
                  list_directory();

                  break;

      	       case FILENAME_LIST_FLD:   /* value contains the index of the
      	                                  item which was just selected     */
                  i = (int)value;
         
 		  status = FIfld_get_text(define_form, FILENAME_LIST_FLD, i, 0, 135,
 		               (unsigned char *)temp_string, &dummy_int, 
 		                                       &dummy_int);

		  strcpy ( form_name, temp_string);

                  status = FIfld_set_text(define_form, FILENAME_FLD, 0, 0, 
                                             temp_string, 0);

                  is_it_a_new_form();
                  break;

		case FILENAME_FLD:

                  Verify_name_field();
		  break;

		case FI_ACCEPT:
		
                   FIg_set_state_off (define_form, FI_ACCEPT);	

                   if ((popup_rows * popup_cols) < 
                       (orig_popup_rows * orig_popup_cols) &&
                       (new_menu == 0) &&
                       (menu_type == POPUP_MENU))
                   {
                   char t_str2[100];
                   int x;

                      strcpy (t_str, "WARNING:\n\n");
                      strcat (t_str, "The settings for rows and columns reduce\n");
                      strcat (t_str, "the number of button slots available to\n");
                      strcat (t_str, "the popup menu.  Some buttons may be\n");
                      strcat (t_str, "deleted if accepted. Is this OK?\n\n");

                      sprintf (t_str2, "old rows = %d, new rows = %d\n",
                                      orig_popup_rows, popup_rows);
                      strcat (t_str, t_str2);

                      sprintf (t_str2, "old cols = %d, new cols = %d\n",
                                      orig_popup_cols, popup_cols);
                      strcat (t_str, t_str2);

                      for (x = 5; x < 34; x++)
                         FIg_disable (define_form, x);

                      FIg_set_text (define_form, DECISION_BTN, t_str);
                      FIg_display (define_form, DECISION_BTN);
                      FIg_display (define_form, YES_BTN);
                      FIg_display (define_form, NO_BTN);
                      return;
                   }


      status = FIfld_get_text (define_form, FILENAME_FLD, 0, 0, 135,
 		                       (unsigned char *)temp_string, &dummy_int, 
 		                                      &dummy_int);

		    if ( temp_string[0] == '\0' )
		    {
                        UMSGetByNum (temp_string, MB_E_NONAME, 0);
                    	print_error (define_form, MSG_FLD, temp_string);
		        return;
		    }
                    else
                    {
                       FIf_erase (define_form);
                      
                        /* At this point, all is ready            */
                        /* so let's create the new work_form !!!  */

                       if (new_menu == 1)
                       {
                          long attr;

                          UMSGetByNum (t_str, MB_I_DEFINE, 0);
                          FIfld_set_text (Message_form, 11, 0, 0, t_str, 0);
                          UMSGetByNum (t_str, MB_I_DISPWRKFRM, 0);
                          FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);
 
                          create_work_form();

                          FIf_get_attr (work_form, &attr);
                          attr |= FI_NOT_SCALABLE;
                          attr |= FI_NOT_RESIZABLE;
                          FIf_set_attr (work_form, attr);
                       } 
                       else
                       {
                          long attr;

                          if ((menu_type == POPUP_MENU) ||
                              (menu_type == MENU_BAR))
                          {
                             FIg_get_text (define_form, DIRECTORY_FLD, t_str);
                             strcat (t_str, "/");
                             strcat (t_str, temp_string);
                             status = FIf_new (1, t_str, (int (*)())fi_work_form, &work_form);

                             FIf_get_attr (work_form, &attr);
                             attr |= FI_NOT_SCALABLE;
                             attr |= FI_NOT_RESIZABLE;
                             FIf_set_attr (work_form, attr);
                          }

                          Setup_palette_arrays ();
                          FIf_display (work_form);
                       }

                       FIfld_set_text (Message_form, 11, 0, 0, "", 0);
                       FIfld_set_text (Message_form, 44, 0, 0, "", 0);
                       UMSGetByNum (t_str, MB_P_SELCOM, 0);
                       FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);
                       
                       command_is_active = 0;
                       strcpy(current_command_string, "None");
                    }
		    break;

		case FI_HELP:

                /*
		    Help_topic ( "Define" );   */
		    
                    status = FIg_erase(define_form, MSG_FLD);
		    break;

		case FI_CANCEL:

                    new_form_name[0] = 0;   /* Clear form name */
                    form_name[0] = 0;       /* Clear form name */
                    kill_define_menu();
                    FIg_set_state_off (define_form, FI_CANCEL);
		    break;

                /* These gadgets are new for version 1.2 --- GMD */
            }
}

/*--------------------------------------------------------------------------*/

/*************************************************************************/
/*                                                                       */
/*                       is_it_a_new_form()                              */
/*                                                                       */
/*    This function is deceptively named.  What it actually does is to   */
/* change the values displayed in the define form whenever the form name */
/* field on the define form is altered.                                  */
/*                                                                       */
/*************************************************************************/

void is_it_a_new_form(void) 
{
    char  directory[200];
    char path[1000];
    FILE * fp;

    if (dir[0] == '.')
       directory[0] = '\0';
    else
       strcpy(directory, dir);
       
    if (_is_a_menu (form_name, directory))    /* form exists */
    {
       setup_old_define_form();
       show_define_form_info();
    }
    else
    {
       if (strlen (directory))
       {
  	   strcpy (path, directory);
	   strcat (path, "/");
	   strcat (path, form_name);		
       }
       else
       {
	   strcpy (path, form_name);
       }
       
       if (( fp = fopen(path,"r")) != NULL )
       {
          form_name[0] = (char) NULL;
          new_form_name[0] = (char) NULL;      
          fclose (fp);

          UMSGetByNum (temp_string, MB_E_NOTIFORMS, 0);          
          print_error (define_form, MSG_FLD, temp_string);
          return;
       }

       setup_new_define_form();
       show_define_form_info();
    }
}

/*------------------------------------------------------------------------*/

/*************************************************************************/
/*                                                                       */
/*                     execute_define_form()                             */
/*                                                                       */
/*    This function is called by the executive command handler routine.  */
/* It initializes the define form then displays the define form, then    */
/* exits.  After that point, the fi_define_form gadget notification      */
/* routine will be in control.  That is to say, every time the operator  */
/* alters a gadget on the define form the fi_define_form() function will */
/* be invoked.                                                           */
/*                                                                       */
/*************************************************************************/

void execute_define_menu(void)
{
char t_str[200];
int status;

   if (work_form != NULL)   /* Form already displayed */
   {
      execute_save_menu();
   }
   else
   {
      new_form_name[0] = '\0';   /* Blank this item */ 
 
      UMSGetByNum (t_str, MB_I_DEFINE, 0);
      FIfld_set_text (Message_form, 11, 0, 0, t_str, 0);
      UMSGetByNum (t_str, MB_I_DEFFRM, 0);
      FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

      if (define_form == NULL)
      {
         strcpy (t_str, execute_dir);
         strcat (t_str, "/config/");
         strcat (t_str, language);
         strcat (t_str, "/forms/MBDefine");

         status = FIf_new (100, t_str, (int (*)())fi_define_form, &define_form);

         if (status != 0)
            Report_fatal_form_error (status, t_str);
      }

      /* Now display the default define form */
    
      FIg_erase (define_form, 10);   /* Error field */ 

      FIfld_set_text (define_form, FILENAME_FLD, 0, 0, "", 0);

      init_define_form();         /* List forms in global dir */
   
      setup_new_define_form();    /* Sets up blank define form */
   
      show_define_form_info();    /* Places values into gadgets */   
   
      FIf_display (define_form);

      /********************************************/
      /*                                          */
      /* Need to set Help topic to "Define" here  */
      /*                                          */
      /********************************************/
   
      UMSGetByNum (t_str, MB_I_DEFINE, 0);
      FIfld_set_text (Message_form, 11, 0, 0, t_str, 0);
      UMSGetByNum (t_str, MB_P_FILLDEFFRM, 0);
      FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);
   }
}


