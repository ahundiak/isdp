 
           /*************************************/
           /*                                   */
           /*              button.c             */
           /*                                   */
           /*    This file contains all of the  */
           /* functions pertaining to the       */
           /* "place button" and edit button    */
           /* commands.                         */
           /*                                   */
           /*      Programmer: Mack Draper      */
           /*      Date:       Dec. 6, 1988     */
           /*                                   */
           /*************************************/

#include <X11/Xlib.h>

#include <stdio.h>

#include "FI.h"
#include "FIdyn.h"
#include "XMBpriv.h"
#include "UMS.h"
#include "XMB.h"
#include "FImgt.h"
#include "FImin.h"
#include "FIgadget.h"
#include "FIbtn.h"

#include "XFIproto_pri.h"
#include "XFIproto_pub.h"
#include "XMBproto_pri.h"

/*************************/
/*  used by button form  */
/*************************/

#define BTN_ERR_FLD  10
#define FONT_FLD     40
#define SYM_FLD      57
#define SYM_TOG      21
#define FONT_TXT     16
#define TEXT_TXT     14
#define SYM_TXT      15
#define SELECT_BTN   18
#define ADD_DIRECTORY_BTN  30

#define CMD_BTN_TOG   24
#define CMD_TEXT      22
#define PALETTE_TEXT  27
#define COMMAND_FLD   11

#define KEY_OR_STRING_TOG 28

/*************************************/
/* Global variables for this Command */
/*************************************/

unsigned char temp_str[135];
Form button_form = NULL;

char symbol_file [200];
int off_sym_index;
int text_gadget;
int gadget_label;
int edit_hilite_flag;
char off_text[2000];
char palette_or_command_string[2000];
int btn_type;    /* 0 = menu button; 1 = panel palette button */

#define NORMAL_BUTTON    0
#define PALETTE_BUTTON   1

/************************************/
/*  External variable declarations  */
/************************************/

extern struct _FI_sym_st *_FI_symbols;

extern Form work_form;
extern void fi_work_form();
extern int command_is_active;
extern char current_command_string[80];
extern char execute_dir[200];

extern Form Message_form;
extern int edit_hilite_flag;

extern char Global_symbol_file[20];
extern Form Symbol_scroll;
extern Form Sym_dir_form;
extern Display *display;

extern char language[80];
extern int menu_type;

extern int gadget_list[255][100];
extern char palette_name[255][20];
extern int gadget_count[255];
extern int palette_level[255];
extern int group_list[255];
extern int palette_count;

extern int popup_rows;
extern int popup_cols;

extern int displayed_pal_2nd;
extern int displayed_pal_3rd;
extern int displayed_pal_4th;

extern int panel_cols_top;
extern int panel_cols_2nd;
extern int panel_cols_3rd;
extern int panel_cols_4th;
extern int panel_ysize_top;
extern int panel_ysize_2nd;
extern int panel_ysize_3rd;
extern int panel_ysize_4th;

kill_edit_button(void)
{
char t_str[2000];

   command_is_active = 0;
   strcpy (current_command_string, "None");
   
   if ( button_form )
      FIf_erase (button_form);
 
   if ( Symbol_scroll )
      FIf_erase (Symbol_scroll);

   if ( Sym_dir_form )
      FIf_erase (Sym_dir_form);

   if ((edit_hilite_flag == 0) && work_form )
      FIg_unhilite (work_form, gadget_label);      

   FIfld_set_text (Message_form, 11, 0, 0, "", 0);
   FIg_display (Message_form, 11);
   FIfld_set_text (Message_form, 33, 0, 0, "", 0);
   FIg_display (Message_form, 33);
   FIfld_set_text (Message_form, 44, 0, 0, "", 0);
   FIg_display (Message_form, 44);

   UMSGetByNum (t_str, MB_P_SELCOM, 0);
   FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

   if ( work_form )
      Redisplay (work_form);
}

/*--------------------------------------------------------------------*/

static void clean_up_and_loop(void)
{
   if ( button_form )
      FIf_erase (button_form);

   FIfld_set_text (Message_form, 11, 0, 0, "", 0);
   FIfld_set_text (Message_form, 44, 0, 0, "", 0);
      
   if ( Symbol_scroll )
      FIf_erase (Symbol_scroll);

   if ( Sym_dir_form )
      FIf_erase (Sym_dir_form);

   if ( edit_hilite_flag == 0)
      FIg_unhilite (work_form, gadget_label);

   Redisplay (work_form);
   execute_edit_button();
}

/**********************************************************************/
/*                                                                    */
/*                  setup_old_button_form()                           */
/*                                                                    */
/**********************************************************************/

setup_old_button_form(void)
{  
int attr;
struct FIbtn_obj * gadget; 

   FIg_get_attr (work_form, gadget_label, &attr);

   if (attr & FI_TEXT_GADGET)
   {
      text_gadget = 1;
      FIg_get_text (work_form, gadget_label, off_text);
   }
   else
   {
      text_gadget = 0;
      FIg_get_off_symbol_index (work_form, gadget_label, &off_sym_index);
      FIg_get_symbol_file (work_form, gadget_label, symbol_file);
      if (symbol_file[0] == '\0')
      {
         strcpy (symbol_file, Global_symbol_file);
         off_sym_index = 0;
      }
      off_text[0] = 0;
   }

   gadget = (struct FIbtn_obj *) _FI_g_get_id ((struct FIform_obj *)work_form, gadget_label);
   if ((gadget->FIbtn.menu_button) && gadget->FIbtn.palette[0] )
   {
      btn_type = PALETTE_BUTTON;
      strcpy (palette_or_command_string, gadget->FIbtn.palette);
   }
   else
   {
      btn_type = NORMAL_BUTTON;
      FIg_get_command (work_form, gadget_label, palette_or_command_string);
   }
}

/**********************************************************************/
/*                 show_button_form_info()                            */
/*                                                                    */
/*    This function displays the information contained in the         */
/* current_gadget struct into the button form's gadgets.              */
/**********************************************************************/

show_button_form_info(void) 
{
char t_str[200];
int status;
int attr;

   status = FIg_set_state_off (button_form, SELECT_BTN);
   FIg_set_state_off (button_form, ADD_DIRECTORY_BTN);

   if (text_gadget == 1)  /*  text button  */
   {
      FIg_set_state_off (button_form, SYM_TOG);
      status = FIfld_set_text (button_form, 19, 0, 0, off_text, 0);
            
      Break_up_multi_line_string (button_form, 19, off_text); 
          
      FIg_erase (button_form, SYM_FLD);
      FIg_erase (button_form, SYM_TXT);
      FIg_erase (button_form, FONT_TXT);
      FIg_erase (button_form, FONT_FLD);
      FIg_erase (button_form, SELECT_BTN);
      FIg_erase (button_form, ADD_DIRECTORY_BTN);
            
      FIg_display (button_form, TEXT_TXT);
      FIg_display (button_form, 19);
   }
   else    /*  symbol button  */
   {
      FIg_set_state_on (button_form, SYM_TOG);	
   
      FIg_erase (button_form, TEXT_TXT);
      FIg_erase (button_form, 19);
      FIfld_set_num_rows (button_form, 19, 0);            

      FIfld_set_text (button_form, FONT_FLD, 0, 0, symbol_file, 0);
                            
      FIg_display (button_form, FONT_FLD);
            
      sprintf (t_str, "%d", off_sym_index);
      FIfld_set_text (button_form, SYM_FLD, 0, 0, t_str, 0);
      
      FIg_display (button_form, SYM_FLD);
      FIg_display (button_form, SYM_TXT);
      FIg_display (button_form, FONT_TXT);
      
      FIg_display (button_form, SELECT_BTN);
      FIg_display (button_form, ADD_DIRECTORY_BTN);
   }

   FIg_set_text (button_form, COMMAND_FLD, palette_or_command_string);

   if (btn_type == NORMAL_BUTTON)
   {
      FIg_erase (button_form, PALETTE_TEXT);
      FIg_display (button_form, CMD_TEXT);

      FIg_set_state_off (button_form, CMD_BTN_TOG);
      FIg_get_attr (work_form, gadget_label, &attr);

      if (attr & FI_CMD_KEY)
         FIg_set_state_on (button_form, KEY_OR_STRING_TOG);
      else
         FIg_set_state_off (button_form, KEY_OR_STRING_TOG);

      FIg_display (button_form, KEY_OR_STRING_TOG);
   }
   else   /* btn_type = PALETTE_BUTTON */
   {
      FIg_erase (button_form, CMD_TEXT);
      FIg_display (button_form, PALETTE_TEXT);

      FIg_set_state_on (button_form, CMD_BTN_TOG);
      FIg_erase (button_form, KEY_OR_STRING_TOG);
   }
}

/*--------------------------------------------------------------------*/

change_button_gadget(void)
{
  int attr;
  int state;
  int x, index = 0;
  struct FIbtn_obj * gadget;
  int pal_index = 0;


   FIg_get_attr (work_form, gadget_label, &attr);

   if ( text_gadget )
   {
      attr |= FI_TEXT_GADGET;

      Form_multi_line_string (button_form, 19, off_text);	
      FIg_set_text (work_form, gadget_label, off_text);
      FIg_set_font (work_form, gadget_label, "swiss742b", (float)15.0);
   }
   else
   {
      attr |= FI_TEXT_GADGET;
      attr -= FI_TEXT_GADGET;

      FIg_set_symbol_file (work_form, gadget_label, symbol_file);
      FIg_set_off_symbol_index (work_form, gadget_label, off_sym_index);
   }
   FIg_set_attr (work_form, gadget_label, attr);

   if (btn_type == NORMAL_BUTTON)
   {
      /* Set command key/command string here */

      attr &= 0xffff ^ FI_CMD_STRING;
      attr &= 0xffff ^ FI_CMD_KEY;

      FIg_get_state (button_form, KEY_OR_STRING_TOG, &state);

      if (state == 0)
         attr |= FI_CMD_STRING;
      else
         attr |= FI_CMD_KEY;

      FIg_set_attr (work_form, gadget_label, attr);
      FIg_set_command (work_form, gadget_label, palette_or_command_string);

      /* If the gadget used to have a sub-palette, then erase the */
      /* palette and set the palette name to be a NULL string.    */

      gadget = (struct FIbtn_obj *) _FI_g_get_id ((struct FIform_obj *)work_form, gadget_label);
      gadget->FIbtn.menu_button = 0;

      if (gadget->FIbtn.palette != NULL)
      {
         for (x = 0; x < palette_count; x++)
            if (strcmp (gadget->FIbtn.palette, &(palette_name[x][0])) == 0)
            {
               pal_index = x;
               break;
            }

         if (pal_index == displayed_pal_2nd)
         {
            FIg_erase (work_form, group_list[displayed_pal_2nd]);
            FIg_set_state_off (work_form, group_list[displayed_pal_2nd]);
            displayed_pal_2nd = 0;
            if (displayed_pal_3rd != 0)
            {
               FIg_erase (work_form, group_list[displayed_pal_3rd]);
               FIg_set_state_off (work_form, group_list[displayed_pal_3rd]);
               displayed_pal_3rd = 0;
            }
            if (displayed_pal_4th != 0)
            {
               FIg_erase (work_form, group_list[displayed_pal_4th]);
               FIg_set_state_off (work_form, group_list[displayed_pal_4th]);
               displayed_pal_4th = 0;
            }
         }
         if (pal_index == displayed_pal_3rd)
         {
            FIg_erase (work_form, group_list[displayed_pal_3rd]);
            FIg_set_state_off (work_form, group_list[displayed_pal_3rd]);
            displayed_pal_3rd = 0;
            if (displayed_pal_4th != 0)
            {
               FIg_erase (work_form, group_list[displayed_pal_4th]);
               FIg_set_state_off (work_form, group_list[displayed_pal_4th]);
               displayed_pal_4th = 0;
            }
         }
         if (pal_index == displayed_pal_4th)
         {
            FIg_erase (work_form, group_list[displayed_pal_4th]);
            FIg_set_state_off (work_form, group_list[displayed_pal_4th]);
            displayed_pal_4th = 0;
         }
         gadget->FIbtn.palette = NULL;
      }
   }
  else  /* Panel palette button */
   {
   int palette_found = 0;
   int ok_to_create;
   char old_palette_name[20];
      
      gadget = (struct FIbtn_obj *) _FI_g_get_id ((struct FIform_obj *)work_form, gadget_label);

      gadget->FIbtn.menu_button = 1;
      if ((gadget->FIbtn.palette == NULL) ||
          (strlen (gadget->FIbtn.palette) == 0))   /* GMD 10/9/91 */
      {
         ok_to_create = 1;
         gadget->FIbtn.palette = calloc (1, 30);
      }
      else
      {
         ok_to_create = 0;
      }

      strcpy (old_palette_name,  gadget->FIbtn.palette);
      strcpy (gadget->FIbtn.palette, palette_or_command_string);

      /*  See if the panel already exists.  If it does, then arrange it  */
      /*  and its dependants based on the current baseline and number    */
      /*  of buttons contained in the parent palette.  This is necessary */
      /*  because now I am allowing you to change the name of a palette, */
      /*  As a result you could delete a palette, change the menus       */
      /*  around, and reinstall it and everything could have changed.    */

      palette_found = 0;

      for (x = 0; x < palette_count; x++)
         if (strcmp (&(palette_name[x][0]), palette_or_command_string) == 0)
         {
            index = x;
            palette_found = 1;
         }

      if (palette_found == 1)
      {
      int pal_level;
      int panel_cols = 1, ysize = 0;
      int baseline, state;
      int xpos, ypos;

         /* Need recursive routine to insure that all sub palettes  */
         /* are located correctly.                                  */

         /* First determine the baseline of the palette for the     */
         /* button being edited.  Then check the y location of the  */
         /* sub-palette that is being restored.  If they match,     */
         /* then no action needs to be taken.                       */
         /*                                                         */
         /* If they don't match then see if the palette needs to    */
         /* move up or down and call Move_palette_up or             */
         /* Move_palette_down accordingly.                          */

         Find_palette_and_level (gadget_label, &pal_index, &pal_level);
         FIg_get_location (work_form, gadget_list[pal_index][0], &xpos, &ypos);

         if (pal_level == 1)
         {
            panel_cols = panel_cols_top;
            ysize = panel_ysize_top;
         }
         if (pal_level == 2)
         {
            panel_cols = panel_cols_2nd;
            ysize = panel_ysize_2nd;
         }
         if (pal_level == 3)
         {
            panel_cols = panel_cols_3rd;
            ysize = panel_ysize_3rd;
         }

         baseline = ypos + ysize * (gadget_count[pal_index] / panel_cols);
         if ((gadget_count[pal_index] % panel_cols) != 0)
            baseline += ysize;   

         /* Now see if sub-palette's ypos matches baseline */

         FIg_get_location (work_form, gadget_list[index][0], &xpos, &ypos);

         if (ypos != baseline)
         {
            if (ypos > baseline)
               Move_palette_up (palette_or_command_string, ypos - baseline);
            else
               Move_palette_down (palette_or_command_string, baseline - ypos);
         }

         /* If the parent button is selected, display the palette   */

         FIg_get_state (work_form, gadget_label, &state);
         if (state)
            FIg_display (work_form, group_list[index]);
      }
      else if (ok_to_create)  /* Create a new palette */
      {
      int pal_level;
      int panel_cols = 1, xsize, ysize = 0;
      int baseline, x, state;
      int sub_panel_cols = 1, sub_panel_ysize = 0;
      int group_label, button_label;
      int xpos, ypos;
      int attr;

         Find_palette_and_level (gadget_label, &pal_index, &pal_level);

         FIg_get_location (work_form, gadget_list[pal_index][0], &xpos, &ypos);

         if ( pal_level == 1 )
         {
            panel_cols = panel_cols_top;
            ysize = panel_ysize_top;
            sub_panel_cols = panel_cols_2nd;
            sub_panel_ysize = panel_ysize_2nd;
         }
         if ( pal_level == 2 )
         {
            panel_cols = panel_cols_2nd;
            ysize = panel_ysize_2nd;
            sub_panel_cols = panel_cols_3rd;
            sub_panel_ysize = panel_ysize_3rd;
         }
         if ( pal_level == 3 )
         {
            panel_cols = panel_cols_3rd;
            ysize = panel_ysize_3rd;
            sub_panel_cols = panel_cols_4th;
            sub_panel_ysize = panel_ysize_4th;
         }

         baseline = ypos + ysize * (gadget_count[pal_index] / panel_cols);
         if ((gadget_count[pal_index] % panel_cols) != 0)
            baseline += ysize;

         /* Now create a new row of buttons for the new palette */

         FIf_get_next_label (work_form, &group_label);
         FIg_new (work_form, FI_GROUP, group_label);
         group_list[palette_count] = group_label;
 
         FIgrp_set_pass_on (work_form, group_label);
         FIgrp_set_single_select_on (work_form, group_label);

         xsize = 180 / sub_panel_cols;
         ysize = sub_panel_ysize;      

         for (x = 0; x < sub_panel_cols; x++)
         {
            FIf_get_next_label (work_form, &button_label);
            Create_blank_button (button_label, xsize, ysize, 
                                            x * xsize, baseline);
            FIg_add_to_group (work_form, button_label, group_label);
            gadget_list [palette_count][x] = button_label;
         }
         gadget_count[palette_count] = sub_panel_cols;

         /* Erase or display the gadgets in the new palette, based   */
         /* on whether its parent's state.                           */

         FIg_get_state (work_form, gadget_label, &state);
         if (state == 1)
         {
            FIg_display (work_form, group_list[palette_count]);
            if (pal_level == 1)
               displayed_pal_2nd = palette_count;
            if (pal_level == 2)
               displayed_pal_3rd = palette_count;
            if (pal_level == 3)
               displayed_pal_4th = palette_count;
         }
         else
         {
            for (x = 0; x < gadget_count[palette_count]; x++)
            {
               FIg_get_attr (work_form, gadget_list[palette_count][x], &attr);
               attr |= FI_NOT_DISPLAYED;
               FIg_set_attr (work_form, gadget_list[palette_count][x], attr);
            }
         }

         strcpy (&(palette_name[palette_count][0]), palette_or_command_string);
         palette_level[palette_count] = pal_level + 1;
         palette_count++;
      }
      else  /* Just want to rename palette */
      {
         for (x = 0; x < palette_count; x++)
            if (strcmp (&(palette_name[x][0]), old_palette_name) == 0)
            {
               index = x;
            }
         strcpy (&(palette_name[index][0]), palette_or_command_string);
      }
   }

   FIg_activate (work_form, gadget_label);
   FIg_display (work_form, gadget_label);
}


/**********************************************************************/
/*                           fi_button_form()                         */
/*                                                                    */
/*  This function works in the same manner as the form_input method   */
/* did in the OM world. (Boo! Hiss!!!)                                */
/*                                                                    */
/*    This form is used to allow the operator to change the default   */
/* settings for a new button gadget, or alter the settings of an      */
/* existing button gadget.                                            */
/**********************************************************************/

/* ARGSUSED */
void fi_button_form (int form_label,
                     int label,
                     double value,
                     Form form)
{
    int num_flag, i, j, x;
    char sym_name[200];
    int sym_value;
    int status;
    int state;
    char t_str[200], old_str[200];
    int dummy_int;
   struct FIbtn_obj * gadget;

   FIg_erase (button_form, BTN_ERR_FLD);

   switch (label)
   {
      case CMD_BTN_TOG:

         if ((int)value == 1)     /* PALETTE BUTTON */
         {
            if (menu_type != MENU_PANEL)
            {
               UMSGetByNum (t_str, MB_E_ONLYPANEL, 0);
               print_error (button_form, BTN_ERR_FLD, t_str);
               FIg_set_state_off (button_form, CMD_BTN_TOG);
            }
            else
            {
            int pal_index, pal_level;

               /* May not set a palette for a 4th level button */

               Find_palette_and_level (gadget_label, &pal_index, &pal_level);

               if (pal_level == 4)
               {
                  UMSGetByNum (t_str, MB_E_NOTON4TH, 0);
                  print_error (button_form, BTN_ERR_FLD, t_str);
                  FIg_set_state_off (button_form, CMD_BTN_TOG);  
               }
               else
               {
                  FIg_erase (button_form, CMD_TEXT);
                  FIg_erase (button_form, KEY_OR_STRING_TOG);
                  FIg_display (button_form, PALETTE_TEXT);
                  btn_type = PALETTE_BUTTON;
                  gadget = (struct FIbtn_obj *) _FI_g_get_id ((struct FIform_obj *)work_form, gadget_label);

                  if (gadget->FIbtn.palette == NULL)
                     FIg_set_text (button_form, COMMAND_FLD, "");
                  else
                  {
                     FIg_set_text (button_form, COMMAND_FLD, 
                                                gadget->FIbtn.palette);
                     strcpy (palette_or_command_string, gadget->FIbtn.palette);
                  }
               }
            }
         }
         else
         {
            FIg_erase (button_form, PALETTE_TEXT);
            FIg_display (button_form, KEY_OR_STRING_TOG);
            FIg_display (button_form, CMD_TEXT);
            btn_type = NORMAL_BUTTON;
            FIg_get_command (work_form, gadget_label, t_str);
            FIg_set_text (button_form, COMMAND_FLD, t_str);
            strcpy (palette_or_command_string, t_str);
         }
         break;

      case COMMAND_FLD:

         FIg_get_state (button_form, CMD_BTN_TOG, &state);
         if (state == 0)    /* Command button, unrestricted  */
            FIg_get_text (button_form, COMMAND_FLD, palette_or_command_string);
         else    /* Palette button, max 14 characters */
         {
         int pal_index, pal_level;

            strcpy (old_str, palette_or_command_string);
            FIg_get_text (button_form, COMMAND_FLD, palette_or_command_string);
            if (strlen (palette_or_command_string) > 14)
            {
               UMSGetByNum (t_str, MB_E_MAX14CHARS, 0);
               print_error (button_form, BTN_ERR_FLD, t_str);
               FIg_set_text (button_form, COMMAND_FLD, old_str);
            }
           
            /********************************************************/
            /* If the palette already exists, insure that it is one */
            /* level below the palette the edit button is on.       */
            /********************************************************/

            Find_palette_and_level (gadget_label, &pal_index, &pal_level);

            for (x = 0; x < palette_count; x++)
            {
               if (strcmp (&(palette_name[x][0]), palette_or_command_string) == 0)
               {
                  if (palette_level[x] != pal_level + 1)
                  {
                     UMSGetByNum (t_str, MB_E_BADLEVEL, 0);
                     print_error (button_form, BTN_ERR_FLD, t_str);
                     FIg_set_text (button_form, COMMAND_FLD, old_str);
                  }
                  x = palette_count;
               }
            }
         }
         break;

      case ADD_DIRECTORY_BTN:

         if ((int)value == 1)
            Display_symbol_dir_form();
         else
            FIf_erase (Sym_dir_form);
         break;

      case SELECT_BTN:
      
         if ((int)value == 1)
         {
            if (Symbol_scroll == NULL)
            {
               strcpy (t_str, execute_dir);
               strcat (t_str, "/config/");
               strcat (t_str, language);
               strcat (t_str, "/forms/MBSymSel");
               status = FIf_new (444, t_str, (int (*)())fi_symbol_scroll, &Symbol_scroll);
            
               if (status != 0)
                  Report_fatal_form_error (status, t_str);
            }

            Init_scroll_area (symbol_file, 
                              off_sym_index);
            FIf_display (Symbol_scroll);
         }
         else
         {
            if (Symbol_scroll != NULL)
               FIf_erase (Symbol_scroll);
         }
         break;

      case SYM_TOG:
         
         if ((int)value == 0)
         {
            if (Symbol_scroll != NULL)
               FIf_erase (Symbol_scroll);

            if (Sym_dir_form != NULL)
               FIf_erase (Sym_dir_form);

            text_gadget = 1;   /*  text button */	
         
            FIfld_set_text (button_form, FONT_FLD, 0, 0, off_text, 0);
            
            FIg_erase (button_form, SELECT_BTN);
            FIg_set_state_off (button_form, SELECT_BTN);
            FIg_erase (button_form, ADD_DIRECTORY_BTN);
            FIg_set_state_off (button_form, ADD_DIRECTORY_BTN);
            FIg_erase (button_form, SYM_FLD);
            FIg_erase (button_form, SYM_TXT);
            FIg_erase (button_form, FONT_TXT);
            FIg_erase (button_form, 40); 
           
            FIg_display (button_form, TEXT_TXT);
            FIg_display (button_form, 19);
         }
         else
         {
            text_gadget = 0;     /* symbol button */
           
            FIg_erase (button_form, TEXT_TXT);
            FIg_erase (button_form, 19); 
           
            FIfld_set_text (button_form, FONT_FLD, 0, 0,
                            symbol_file, 0);
                            
            FIg_display (button_form, FONT_FLD);
            
            sprintf (t_str, "%d", off_sym_index);
            FIfld_set_text (button_form, SYM_FLD, 0, 0,
                            t_str, 0);
                     
            FIg_display (button_form, SYM_FLD);
            FIg_display (button_form, SYM_TXT);
            FIg_display (button_form, FONT_TXT);
            FIg_display (button_form, SELECT_BTN);
            FIg_display (button_form, ADD_DIRECTORY_BTN);
            FIg_display (button_form, 40);            
         }
         break;
         
      case 19:   /* Set button's text */
      
         FIfld_get_text (button_form, 19, 0, 0, 135, (unsigned char *)t_str, 
                         &dummy_int, &dummy_int);
    
         strcpy (off_text, t_str);
         break; 
        
      case FONT_FLD:   /* Set symbol file */
      
         FIfld_get_text (button_form, FONT_FLD, 0, 0, 135, (unsigned char *)t_str, 
                         &dummy_int, &dummy_int); 
    
         strcpy (symbol_file, t_str);
         strcpy (Global_symbol_file, t_str);
         if (Symbol_scroll != NULL)
            Set_scroll_symbol_file (t_str);
         break;
         
      case SYM_FLD:
       
	 num_flag = 1;
    	 i = 0;   j = 0;
    	            
 	 status = FIfld_get_text(button_form, SYM_FLD, 0, 0, 135,
 		        (unsigned char *)t_str, &dummy_int, 
 		                 &dummy_int);
    	           
       	 if ((t_str[0] == '\'') || 
	     (t_str[0] == '\\'))
	 {
	    i = 1;
	    if (t_str[1] == '\\')
	       i = 2;
         }
	 while ((t_str[i] != '\0') && 
	        (num_flag))
	 {
	    if (t_str[i] != '\'')
	    {
	       if (isdigit (t_str[i]))
	       {
		  if (( t_str[0] == '\'' ) && 
		      ( t_str[1] == '\\'))
		  {
		     sym_name[i - 2] = t_str[i];
	          }
		  else if ( t_str[0] == '\\' )
		  {
		     sym_name[i - 1] = t_str[i];
		  }
		  else
	          {
		     sym_name[ i ] = t_str[i];
		  }
		  j++;
	       }
	       else
	       {
		  num_flag = 0;
	       }
	    }
	    i = i + 1;
	 }
	 
       	 if ( num_flag )
         {
	    sym_name[j] = (char) NULL;
	    if (( t_str[0] == '\'' ) || 
	        ( t_str[0] == '\\'))
	    {
	       sscanf ( sym_name, "%o", &sym_value );
            }
	    else
	    {
	       sscanf (t_str, "%d", &sym_value);
       	    }

            if ((sym_value < 0) ||
                (sym_value > 255))
            {
               UMSGetByNum (t_str, MB_E_RANGE255, 0);
               print_error (button_form, BTN_ERR_FLD, t_str);
	    }
            else
            {
               off_sym_index = sym_value;
               
               if (Symbol_scroll != NULL)
                  Set_scroll_view_area (sym_value);
            }
         }
         else
         {
            UMSGetByNum (t_str, MB_E_INVALIDSYM, 0);
	    print_error (button_form, BTN_ERR_FLD, t_str);
         }
         break;

       case FI_HELP:
        
          /*  Help_topic ("Button")  */
          break; 
     
       case FI_CANCEL:
   
          FIg_unhilite (work_form, gadget_label);
                
          FIg_set_state_off (button_form, FI_CANCEL);

          clean_up_and_loop();
          break; 
         
       case FI_ACCEPT:	
       
          FIf_erase (button_form); 
          
          if ( Symbol_scroll )
             FIf_erase (Symbol_scroll); 
        
          if ( Sym_dir_form )
             FIf_erase (Sym_dir_form);

          change_button_gadget();

          FIg_set_state_off (button_form, FI_ACCEPT);
          
          clean_up_and_loop();

          break;
   }
}


execute_edit_button(void)
{
char t_str[200];
int status;
int xsize, ysize, display_flag;
int  accept_x, accept_y, mode;

   if (work_form == NULL)
   {
      kill_edit_button();
      return(FI_SUCCESS);
   }

   UMSGetByNum (t_str, MB_I_EDBTN, 0);
   FIfld_set_text (Message_form, 11, 0, 0, t_str, 0);

   /***********************************************/
   /*  First you need to select a button to edit. */
   /*  kill_edit_button() needs to be called if   */
   /*  a button is not selected.                  */ 
   /***********************************************/
   
   UMSGetByNum (t_str, MB_P_SELGDT, 0);
   FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);
 

   mode = 0;    /* Force operator to select a point */

   status = Select_gadget (&gadget_label, &xsize, &ysize, &display_flag,
                           &edit_hilite_flag, &accept_x, &accept_y, mode);
   
   if (status != 2)  /* Failure */
   {
      if (command_is_active == EDIT_BUTTON)
         kill_edit_button();
      return(FI_SUCCESS);
   }

   UMSGetByNum (t_str, MB_I_GENCUR, 0);
   FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

   if (button_form == NULL)
   {
      strcpy (t_str, execute_dir);
      strcat (t_str, "/config/");
      strcat (t_str, language);
      strcat (t_str, "/forms/MBPlBtn");
      status = FIf_new (100, t_str, (int (*)())fi_button_form, &button_form);
            
      if (status != 0)
         Report_fatal_form_error (status, t_str); 
   }         
            
   setup_old_button_form();

   show_button_form_info();

   FIf_display (button_form); 

   FIfld_set_text (Message_form, 33, 0, 0, "", 0);
   UMSGetByNum (t_str, MB_E_FILLBUT, 0);
   FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

   return(FI_SUCCESS); /* sml:11-15-94:added for ANSI */
}

