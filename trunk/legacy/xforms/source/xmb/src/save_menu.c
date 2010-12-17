 
                      /********************************/
                      /*                              */
                      /*         save_menu.c          */
                      /*                              */
                      /* This set of functions allows */
                      /* the current work_form to be  */
                      /* saved.                       */
                      /*                              */
                      /*  Programmer: Mack Draper     */
                      /*                              */
                      /*  Date:       Jul. 9, 1991    */
                      /*                              */
                      /********************************/

#include <sys/types.h>
#include <dirent.h>

#include <stdio.h>

#include "FI.h"
#include "UMS.h"
#include "XMB.h"
#include "XMBpriv.h"
#include <X11/Xlib.h>
#include "FImin.h"
#include "FIgadget.h"
#include "FIbtn.h"
#include "FIdyn.h"

#include "XFIproto_pri.h"
#include "XFIproto_pub.h"
#include "XMBproto_pri.h"

#define DIR_FLD      14
#define NAME_FLD     15

#define ASCII_TOG    19
#define ERASE_TOG    16
#define WRITE_TOG    13

#define OUTLINE_TOG        20
#define OUTLINE_DIR_TEXT   21
#define OUTLINE_FILE_TEXT  22
#define OUTLINE_DIR_FLD    23
#define OUTLINE_FILE_FLD   24

#define ERR_FLD      10

extern Form work_form;
extern Form Message_form;
extern char current_command_string[80];
extern int command_is_active;
extern char dir[135];
extern char execute_dir[200];
extern void fi_dummy_work_form();
extern int exit_flag;

extern char language[80];
extern int menu_type;
extern char form_name[255];
extern char new_form_name[255];

int save_as_ascii;
int save_as_binary;
int erase_form;

char save_dir[200];
char save_name[200];

char outline_dir[200];
char outline_file[200];

Form save_form = NULL;
FILE * outline_fp;

extern int gadget_list[255][100];
extern char palette_name[255][20];
extern int gadget_count [255];
extern int palette_level [255];
extern int group_list [255];
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

/*------------------------------------------------------------------------*/

void kill_save_menu(void)
{
char t_str[2000];

   if (save_form != NULL)
      FIf_erase (save_form);

   FIfld_set_text (Message_form, 11, 0, 0, "", 0);
   FIfld_set_text (Message_form, 33, 0, 0, "", 0);
   FIfld_set_text (Message_form, 44, 0, 0, "", 0);
   FIg_display (Message_form, 11);
   FIg_display (Message_form, 33);
   FIg_display (Message_form, 44);

   UMSGetByNum (t_str, MB_P_SELCOM, 0);
   FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

   command_is_active = 0;
   strcpy (current_command_string, "None");
}

/*------------------------------------------------------------------------*/

void Save_palette_to_outline_file (char *palette,
                                  int level)
{
int x, y, index = 0;
struct FIbtn_obj * gadget;
char line[200];
int attr;
int sym_index;
char command[200], text_string[200];
char symbol_file[20], index_string[20];
char t_str[2000];
int start_pos, str_length;

   /**************************************************************/
   /*                                                            */
   /* Determine the index associated with the given palette name */
   /*                                                            */
   /**************************************************************/

   for (x = 0; x < palette_count; x++)
      if (strcmp (palette, &(palette_name[x][0])) == 0)
      {
         index = x;
         x = palette_count;
      }

   for (x = 0; x < gadget_count[index]; x++)
   {
   /************************************************************************/
   /*                                                                      */
   /* Insert the correct number of TAB characters on the beginning of line */
   /*                                                                      */
   /************************************************************************/

      for (y = 0; y < 200; y++)
         line[y] = '\0';

      for (y = 0; y < level; y++)
         line[y] = '\t';

      gadget = (struct FIbtn_obj *) _FI_g_get_id ((struct FIform_obj *)work_form, gadget_list[index][x]);
      FIg_get_attr (work_form, gadget_list[index][x], &attr);

      if ((gadget->FIbtn.menu_button) &&
          (gadget->FIbtn.palette[0] != (char) NULL))
      {
          strcat (line, gadget->FIbtn.palette);
          strcat (line, ",");
      }
      else   /* first parameter is command key or string */
      {
         FIg_get_command (work_form, gadget_list[index][x], command);

         if (attr & FI_CMD_STRING)
         {
            strcat (line, "\"");
            strcat (line, command);
            strcat (line, "\",");
         }
         else
         {
            strcat (line, command);
            strcat (line, ",");
         }
      }  

      if (attr & FI_TEXT_GADGET)
      {
         FIg_get_text (work_form, gadget_list[index][x], text_string);

         t_str[0] = '\0';
         start_pos = 0;

         /* Replace all carriage return characters with "\n"      */

         str_length = strlen (text_string);
         for (y = 0; y < str_length; y++)
         {
            if (text_string[y] == '\n')
            {
               if (y != start_pos)
               {
                  text_string[y] = 0;
                  strcat (t_str, &(text_string[start_pos]));
               }
               strcat (t_str, "\\n");
               start_pos = y + 1;
            }

            if (y == str_length - 1)  /* At the end of the string */
            {
               if ((text_string[y] != 0) &&
                   (text_string[y] != '\n'))
                  strcat (t_str, &(text_string[start_pos]));
            }
         }
         strcat (line, "\"");
         strcat (line, t_str);
         strcat (line, "\",swiss742b,15");
      }
      else
      {
         FIg_get_symbol_file (work_form, gadget_list[index][x], symbol_file);
         FIg_get_off_symbol_index (work_form, gadget_list[index][x], &sym_index);
         strcat (line, symbol_file);
         strcat (line, ",");
         sprintf (index_string, "%d", sym_index);
         strcat (line, index_string);
         strcat (line, ",-1");
      }

      fprintf (outline_fp, "%s\n", line);

      if ((gadget->FIbtn.menu_button) &&
          (gadget->FIbtn.palette[0] != (char) NULL))
          Save_palette_to_outline_file (gadget->FIbtn.palette, level + 1);
   }
}

/*------------------------------------------------------------------------*/

void FIf_dump_menu_outline (void)
{
int x, y, wd, ht;

   outline_fp = fopen (outline_dir, "w");
   
   if (menu_type == MENU_PANEL)
   {
      FIf_get_location (work_form, &x, &y);

      fprintf (outline_fp, 
        "PANEL, 1.3, X = %d, Y = %d, FONT = swiss742b, SIZE = 15, \\\n", x, y);
      fprintf (outline_fp,
        "            NUM = %d, HT = %d, NUM2 = %d, HT2 = %d, \\\n",
           panel_cols_top, panel_ysize_top, panel_cols_2nd, panel_ysize_2nd);
      fprintf (outline_fp,
        "            NUM3 = %d, HT3 = %d, NUM4 = %d, HT4 = %d\n",
           panel_cols_3rd, panel_ysize_3rd, panel_cols_4th, panel_ysize_4th);
      Save_palette_to_outline_file (&(palette_name[0][0]), 1);  /* level 1 */
   }

   if (menu_type == MENU_BAR)
   {
      FIf_get_location (work_form, &x, &y);
      FIg_get_size (work_form, gadget_list[0][0], &wd, &ht);

      fprintf (outline_fp, 
        "BAR, 1.3, X = %d, Y = %d, FONT = swiss742b, SIZE = 15, \\ \n", x, y);
      fprintf (outline_fp,
        "          NUM = %d, HT = %d \n", gadget_count[0], ht);
      Save_palette_to_outline_file (&(palette_name[0][0]), 1);  /* level 1 */
   }

   if (menu_type == POPUP_MENU)
   {
      FIf_get_location (work_form, &x, &y);
      FIg_get_size (work_form, gadget_list[0][0], &wd, &ht);

      fprintf (outline_fp, 
        "POCKET, 1.3, X = %d, Y = %d, FONT = swiss742b, SIZE = 15, \\ \n", x, y);
      fprintf (outline_fp,
        "             NUM = %d, HT = %d \n", popup_cols, ht);
      Save_palette_to_outline_file (&(palette_name[0][0]), 1);  /* level 1 */
   }
   fclose (outline_fp);   
}

int Save_menu_panel (char * panel_name)
{
int x, y;
Form new_form;
char t_str[300];
int pal_index, pal_level;
int status = 0;
extern void fi_work_form();
int button_label;
struct FIbtn_obj * gadget; 

   for (x = 0; x < palette_count; x++)
      if (strcmp (&(palette_name[x][0]), panel_name) == 0)
      {
         pal_index = x;

         /* Create new form to place gadgets on */

         t_str[0] = '\0';    

         status = FIf_new (100,                /* form label          */
                           t_str,              /* form path           */
                (int (*)())fi_work_form,       /* form input function */
                           &new_form);         /* pointer to form     */

         status = FIf_set_collapse_symbol (new_form, "collapse.icon", 2);

         FIf_set_size (new_form, 186, 828);
         FIf_set_location (new_form, 0, 75);
/*
         FIf_display (new_form);
*/

         /* copy gadgets to the new form */

   Find_palette_and_level (gadget_list[x][0], &pal_index, &pal_level);

   for (y = 0; y < gadget_count[pal_index]; y++)
   {
   int attr;
   int color, index, xsize = 0, ysize = 0, xpos = 0, ypos = 0;
   char fontname[200];
   float bodysize;
   struct FIbtn_obj * gadget;
   struct FIbtn_obj * new_gadget;
   struct standard_st standard_attr;
   char command[300];

      FIf_get_next_label (new_form, &button_label);
      FIg_new (new_form, FI_BUTTON, button_label);

      if (pal_level == 1)
      {
         xsize = 180 / panel_cols_top;
         ysize = panel_ysize_top;
         xpos = 3 + ((y % panel_cols_top) * xsize);
         ypos = 2 + ((y / panel_cols_top) * panel_ysize_top);
      }
      if (pal_level == 2)
      {
         xsize = 180 / panel_cols_2nd;
         ysize = panel_ysize_2nd;
         xpos = 3 + ((y % panel_cols_2nd) * xsize);
         ypos = 2 + ((y / panel_cols_2nd) * panel_ysize_2nd);
      }
      if (pal_level == 3)
      {
         xsize = 180 / panel_cols_3rd;
         ysize = panel_ysize_3rd;
         xpos = 3 + ((y % panel_cols_3rd) * xsize);
         ypos = 2 + ((y / panel_cols_3rd) * panel_ysize_3rd);
      }
      if (pal_level == 4)
      {
         xsize = 180 / panel_cols_4th;
         ysize = panel_ysize_4th;
         xpos = 3 + ((y % panel_cols_4th) * xsize);
         ypos = 2 + ((y / panel_cols_4th) * panel_ysize_4th);
      }

      FIg_get_attr (work_form, gadget_list[pal_index][y], &attr);

      if (attr & FI_TEXT_GADGET)
      {
         FIg_get_font (work_form, gadget_list[pal_index][y], fontname, 
                                                            &bodysize);
         FIg_set_font (new_form, button_label, fontname, bodysize);
         FIg_get_text (work_form, gadget_list[pal_index][y], t_str);
      }
      else
      {
         FIg_get_symbol_file (work_form, gadget_list[pal_index][y], fontname);
         FIg_get_off_symbol_index (work_form, gadget_list[pal_index][y], &index);
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
      FIg_get_command (work_form, gadget_list[pal_index][y], command);
      standard_attr.command = command;
      standard_attr.fontname = fontname;
      FIg_get_off_color (work_form, gadget_list[pal_index][y], &color);
      standard_attr.off_color = color;
      FIg_get_on_color (work_form, gadget_list[pal_index][y], &color);
      standard_attr.on_color = color;
      standard_attr.symbol_index = index;
      standard_attr.symbol_index2 = 0;
      standard_attr.next_in_seq = -1;

      FIg_set_standard_variables (new_form, button_label, &standard_attr);

      FIg_set_erase_color (new_form, button_label, FI_LT_GREY);

      FIg_set_justification (new_form, button_label, FI_CENTER_JUSTIFIED);

      FIbtn_set_auto_pop_up_off (new_form, button_label);

      gadget = (struct FIbtn_obj *) _FI_g_get_id ((struct FIform_obj *)work_form, gadget_list[pal_index][y]);
      new_gadget = (struct FIbtn_obj *) _FI_g_get_id ((struct FIform_obj *)new_form, button_label);

      new_gadget->FIbtn.menu_button = gadget->FIbtn.menu_button;
            
      /* calloc area for palette name to be written to */

      new_gadget->FIbtn.palette = calloc (1, 30);

      if ((gadget->FIbtn.menu_button) &&
          (gadget->FIbtn.palette[0] != (char) NULL))
          strcpy (new_gadget->FIbtn.palette, gadget->FIbtn.palette);

      FIg_activate (new_form, button_label);
      FIg_display (new_form, button_label);
      FIg_set_state_off (new_form, button_label);
   }
         /* Save out the new form */

            strcpy (t_str, save_dir);
            strcat (t_str, "/");
            strcat (t_str, panel_name);
	
            status = FIf_save (new_form, t_str);
            FIf_delete (new_form);

         /* Finally process any sub-palettes this panel might have */

         for (y = 0; y < gadget_count[pal_index]; y++)
         {
            gadget = (struct FIbtn_obj *) _FI_g_get_id ((struct FIform_obj *)work_form, gadget_list[pal_index][y]);
            if ((gadget->FIbtn.menu_button) &&
                (gadget->FIbtn.palette[0] != (char ) NULL))
            {
            char t_str[300];

               strcpy (t_str, (char *)gadget->FIbtn.palette);
               Save_menu_panel (t_str);
            }
         }
         x = palette_count;
      }
   return (status);
}

/*------------------------------------------------------------------------*/
/*************************************************************************/
/*                                                                       */
/*                           fi_save_form()                              */
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
void fi_save_form (int form_label,
                  int gadget_label,
                  double value)
{
char t_str[200];
int status, type;
char filepath[200];
long form_mask;
DIR    *dirp;
char temp_dir[200];
int state, dummy_int;

   FIg_erase (save_form, ERR_FLD);

   switch (gadget_label)
   {
      case FI_HELP:
         break;

      case FI_CANCEL:

         kill_save_menu();
         FIg_set_state_off (save_form, FI_CANCEL);
         break;

      case FI_ACCEPT:

         FIg_get_state (save_form, OUTLINE_TOG, &state);
         
         if (state == 1)
         {
            strcat (outline_dir, "/");
            strcat (outline_dir, outline_file);
            
/*            FIf_dump_menu_outline (outline_dir); dmb:09/01/92:fixed */
            FIf_dump_menu_outline ();
         }

         /**************************************************************/
         /*                                                            */
         /* If a button gadget is being held in the cut buffer, now is */
         /* the time to get rid of it.                                 */
         /*                                                            */
         /**************************************************************/

         status = FIg_get_type (work_form, -1000, &type);
         
         if (status == FI_SUCCESS)
            FIg_delete (work_form, -1000);

         /************************************************/
         /*                                              */
         /*  Now start the business of saving the form   */
         /*                                              */
         /************************************************/

         if (command_is_active != SAVE_MENU)
         {
            form_name[0] = 0;
            new_form_name[0] = '\0';
         }

         if (save_as_binary == 1)
         {
            strcpy (filepath, save_dir);
            strcat (filepath, "/");
            strcat (filepath, save_name);	


            if ((menu_type == MENU_BAR) ||
                (menu_type == POPUP_MENU))
            {
            int x;

               /* Make sure that no entries are selected before saving */

               FIg_set_state (work_form, group_list[0], 0);

               /* Bar Menu and Panel Menu must not have groups */

               FIgrp_delete (work_form, group_list[0]);

               status = FIf_save (work_form, filepath);

               /* Restore group in case this is just a save command */
               /* and not a save and delete command.                */

               FIg_new (work_form, FI_GROUP, group_list[0]);
               FIgrp_set_single_select_on (work_form, group_list[0]);
               FIgrp_set_pass_on (work_form, group_list[0]);

               for (x = 0; x < gadget_count[0]; x++)
                 FIg_add_to_group (work_form, gadget_list[0][x], group_list[0]);
            }
            else     /* PANEL_MENU */
            {
               strcpy (&(palette_name[0][0]), save_name);

               /* Recursive function to save all palettes as separate files */

               status = Save_menu_panel (save_name);
            }

            if (status != 0)
            {
               FIg_set_state_off (save_form, FI_ACCEPT);
               UMSGetByNum (t_str, MB_E_STSOFSAV, "%d", status);
               print_error (save_form, ERR_FLD, t_str);
               return;
            }
         }

         if (erase_form == 1)
         {
            FIf_delete (work_form);
            
            work_form = NULL;
         }
         else if (command_is_active != SAVE_MENU)
         {
            FIf_set_notification_routine (work_form, (int (*)())fi_dummy_work_form);

            FIf_get_attr (work_form, &form_mask);
            form_mask |= FI_NOT_SCALABLE;
            form_mask |= FI_NOT_RESIZABLE;
            FIf_set_attr (work_form, form_mask);
            work_form = NULL;
         }
         
         if (command_is_active == EXIT)
         {
            work_form = NULL;
            exit_flag = 1;
            command_is_active = 0;
            strcpy (current_command_string, "None");
            execute_EXIT();
         }
         
         if (command_is_active == DEFINE_MENU)
         {
            FIf_erase (save_form);
            FIg_set_state_off (save_form, FI_ACCEPT);
            execute_define_menu();
            return;
         }
         FIg_set_state_off (save_form, FI_ACCEPT);
         kill_save_menu();
         break;

      case OUTLINE_TOG:
      
         if ((int)value == 0)
         {
            FIg_erase (save_form, OUTLINE_DIR_TEXT);
            FIg_erase (save_form, OUTLINE_FILE_TEXT);
            FIg_erase (save_form, OUTLINE_DIR_FLD);
            FIg_erase (save_form, OUTLINE_FILE_FLD);
         }
         else
         {
            FIg_display (save_form, OUTLINE_DIR_TEXT);
            FIg_display (save_form, OUTLINE_FILE_TEXT);
            FIg_display (save_form, OUTLINE_DIR_FLD);
            FIg_display (save_form, OUTLINE_FILE_FLD);
         }
         break;

      case ASCII_TOG:

         save_as_ascii = (int)value;
         print_error (save_form, ERR_FLD, 
                      "Ascii file not currently supported");
         FIg_set_state_off (save_form, ASCII_TOG);
         break;

      case ERASE_TOG:

         erase_form = (int)value;
         break;

      case WRITE_TOG:

         save_as_binary = (int)value;
         break;

      case DIR_FLD:

         /* Find out what the operator just typed in */
 		  
         status = FIfld_get_text (save_form, DIR_FLD, 0, 0, 135,
 		            (unsigned char *)t_str, &dummy_int, &dummy_int);

        /* Expand the shell variables to full path and put back 
		     into field */

        strcpy (temp_dir, expand_shell_vars(t_str));
                
        dirp = opendir ( temp_dir );
        if ( dirp == NULL )
        {
           UMSGetByNum (t_str, MB_E_BADOPNDIR, 0);
           print_error (save_form, ERR_FLD, t_str);
        }
        else
        {
           FIfld_set_text (save_form, DIR_FLD, 0, 0, temp_dir, 0);
           strcpy (save_dir, temp_dir);
           closedir (dirp);
        }
        break;

      case NAME_FLD:

         status = FIfld_get_text(save_form, NAME_FLD, 0, 0, 135,
 		            (unsigned char *)t_str, &dummy_int, &dummy_int);
	
	 if ((strlen (t_str) > 14) ||
             (strlen (t_str) == 0))
         {
            UMSGetByNum (t_str, MB_E_BADMNUNAME, 0);
            print_error (save_form, ERR_FLD, t_str);
 		     
            status = FIfld_set_text(save_form, ERR_FLD, 0, 0, t_str, 0);

            status = FIg_display(save_form, ERR_FLD);
 		    
            status = FIfld_set_text(save_form, NAME_FLD, 0, 0, "", 0);
		     break;
         }
         else
            strcpy (save_name, t_str);

         break;
         
      case OUTLINE_DIR_FLD:

         /* Find out what the operator just typed in */
 		  
         status = FIfld_get_text (save_form, OUTLINE_DIR_FLD, 0, 0, 135,
 		            (unsigned char *)t_str, &dummy_int, &dummy_int);

        /* Expand the shell variables to full path and put back 
		     into field */

        strcpy (temp_dir, expand_shell_vars(t_str));
                
        dirp = opendir ( temp_dir );
        if ( dirp == NULL )
        {
           UMSGetByNum (t_str, MB_E_BADOPNDIR, 0);
           print_error (save_form, ERR_FLD, t_str);
        }
        else
        {
           FIfld_set_text (save_form, OUTLINE_DIR_FLD, 0, 0, temp_dir, 0);
           strcpy (outline_dir, temp_dir);
           closedir (dirp);
        }
        break;

      case OUTLINE_FILE_FLD:

         status = FIfld_get_text(save_form, OUTLINE_FILE_FLD, 0, 0, 135,
 		            (unsigned char *)t_str, &dummy_int, &dummy_int);
	
	 if ((strlen (t_str) > 14) ||
             (strlen (t_str) == 0))
         {
            UMSGetByNum (t_str, MB_E_OUTLNAME, 0);
 		     
            status = FIfld_set_text(save_form, ERR_FLD, 0, 0, t_str, 0);

            status = FIg_display(save_form, ERR_FLD);
 		    
            status = FIfld_set_text(save_form, NAME_FLD, 0, 0, "", 0);
		     break;
         }
         else
            strcpy (outline_file, t_str);

         break;
        
   }
}

/*************************************************************************/

void execute_save_menu(void)
{
   int status;	
   char t_str[200];

   if (work_form == NULL)
   {
      kill_save_menu();
   }
   else
   {
      UMSGetByNum (t_str, MB_I_SAVEMENU, 0);
      FIfld_set_text (Message_form, 11, 0, 0, t_str, 0);
      FIfld_set_text (Message_form, 33, 0, 0, "", 0);

      save_as_ascii = 0;
      save_as_binary = 1;
      erase_form = 1;

      if (save_form == NULL)
      {
         strcpy (t_str, execute_dir);
         strcat (t_str, "/config/");
         strcat (t_str, language);
         strcat (t_str, "/forms/MBExSvFrm");
         status = FIf_new (100, t_str, (int (*)())fi_save_form, &save_form);

         if (status != 0)
            Report_fatal_form_error (status, t_str);
      }

      FIg_erase (save_form, 10);   /* Error field */
      FIg_erase (save_form, ERASE_TOG);

      if (command_is_active == SAVE_MENU)
      {
         FIg_erase (save_form, ERASE_TOG);
         FIg_erase (save_form, WRITE_TOG);
         erase_form = 0;
      }
      else
      {
/*       FIg_display (save_form, ERASE_TOG);  */
         FIg_display (save_form, WRITE_TOG);
         FIg_set_state_on (save_form, ERASE_TOG);
         FIg_set_state_on (save_form, WRITE_TOG);
         erase_form = 1;
      }
      
      FIfld_set_text (save_form, DIR_FLD, 0, 0, dir, 0);

      FIfld_set_text (save_form, NAME_FLD, 0, 0, new_form_name, 0);
   
      FIfld_set_text (save_form, OUTLINE_DIR_FLD, 0, 0, dir, 0);
      
      strcpy (outline_dir, dir);
      strcpy (outline_file, new_form_name);
      if (strlen (outline_file) > 11)
         outline_file[11] = 0;
      strcat (outline_file, ".ol");
 
      FIfld_set_text (save_form, OUTLINE_FILE_FLD, 0, 0, outline_file, 0); 

      FIg_set_state_off (save_form, OUTLINE_TOG);
      FIg_erase (save_form, OUTLINE_DIR_TEXT);
      FIg_erase (save_form, OUTLINE_FILE_TEXT);
      FIg_erase (save_form, OUTLINE_DIR_FLD);
      FIg_erase (save_form, OUTLINE_FILE_FLD);

      /* Now display the save form */
 
      FIf_display (save_form);

      /********************************************/
      /*                                          */
      /* Need to set Help topic to "Save" here    */
      /*                                          */
      /********************************************/
   
      UMSGetByNum (t_str, MB_P_FILLSVEFRM, 0);
      FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

      strcpy (save_dir, dir);
      strcpy (save_name, new_form_name);

   }
}
