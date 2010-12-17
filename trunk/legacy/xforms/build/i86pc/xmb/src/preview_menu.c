
                      /********************************/
                      /*                              */
                      /*        preview_btn.c         */
                      /*                              */
                      /*  Programmer: Mack Draper     */
                      /*                              */
                      /*  Date:       Jul. 17, 1991   */
                      /*                              */
                      /********************************/

#include <stdio.h>

#include "FI.h"
#include "UMS.h"
#include "XMB.h"
#include "XMBpriv.h"
#include <X11/Xlib.h>
#include "FImin.h"
#include "FIgadget.h"
#include "FIbtn.h"

#include "XFIproto_pri.h"
#include "XFIproto_pub.h"
#include "XMBproto_pri.h"

Form Preview_form = NULL;
int preview_list[1000];

extern Display *display;
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

/*------------------------------------------------------------------------*/

void kill_preview_outline(void)
{
char t_str[2000];

   FIfld_set_text (Message_form, 11, 0, 0, "", 0);
   FIfld_set_text (Message_form, 22, 0, 0, "", 0);
   FIfld_set_text (Message_form, 44, 0, 0, "", 0);

   UMSGetByNum (t_str, MB_P_SELCOM, 0);
   FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

   if (Preview_form != NULL)
      FIf_erase (Preview_form);

   command_is_active = 0;
   strcpy (current_command_string, "None");
}

/*************************************************************************/

/* ARGSUSED */
void fi_preview_form (int form_label,
                     int gadget_label,
                     double value)
{
   int i, x, xsize, ysize;
   char t_str[500];
   int row, col, pos, state;
   char symbol_file[100];
   int sym_index;
   int num_rows;
   int attr;
   char fontname[20];
   float bodysize;

   FIg_erase (Preview_form, 10);

   switch (gadget_label)
   {
      case 11:
         FIfld_get_active_row (Preview_form, 11, &row, &pos);
         FImcf_get_active_col (Preview_form, 11, &col, &pos);

         if (col == 2)   /* Button type */
         {
            FIfld_get_text (Preview_form, 11, row, col, 200, (unsigned char *)t_str, &state, &pos);
            if (strcmp (t_str, "SUB-PALETTE") == 0)
            {
               FIfld_set_select (Preview_form, 11, row, col, 1);
               UMSGetByNum (t_str, MB_E_NODELPAL, 0);
               FIg_set_text (Preview_form, 10, t_str);
               FIg_display (Preview_form, 10);
            }
            else if (strcmp (t_str, "COMMAND STRING") == 0)
            {
               FIfld_set_text (Preview_form, 11, row, col, "COMMAND KEY", 1);
            }
            else
               FIfld_set_text (Preview_form, 11, row, col, "COMMAND STRING", 1);
         }
      
         if (col == 4)
         {
            FIfld_get_text (Preview_form, 11, row, col, 200, (unsigned char *)t_str, &state, &pos); 
            if (strcmp (t_str, "  TEXT") == 0)
            {
               FIfld_set_text (Preview_form, 11, row, col, " SYMBOL", 1);
               FIfld_set_text (Preview_form, 11, row, 7, "", 0);
               FIg_get_symbol_file (work_form, preview_list[row], symbol_file);
               FIg_get_off_symbol_index (work_form, preview_list[row], &sym_index);
               FIfld_set_text (Preview_form, 11, row, 5, symbol_file, 0);
               sprintf (t_str, "%d", sym_index);
               FIfld_set_text (Preview_form, 11, row, 6, t_str, 0);
            }
            else
            {
               FIfld_set_text (Preview_form, 11, row, col, "  TEXT", 1);
               FIfld_set_text (Preview_form, 11, row, 5, "swiss742b", 0);
               FIfld_set_text (Preview_form, 11, row, 6, "15", 0);
               FIg_get_text (work_form, preview_list[row], t_str);
               FIfld_set_text (Preview_form, 11, row, 7, t_str, 0);
            }
         }
         break;

      case FI_CANCEL:
         FIf_erase (Preview_form);
         FIg_set_state_off (Preview_form, FI_CANCEL);
         kill_preview_outline();
         break;

      case FI_ACCEPT:
         FIfld_get_num_rows (Preview_form, 11, &num_rows);
         for (x = 0; x < num_rows; x++)
         {
            FIg_get_attr (work_form, preview_list[x], &attr);
            FIfld_get_text (Preview_form, 11, x, 2, 200, (unsigned char *)t_str, &state, &pos);
            if (strcmp (t_str, "SUB-PALETTE") == 0)
            {
               /* Nothing need be done for this case */
            }
            else   /* Command string or command key might have changed */
            {
               attr &= ~FI_CMD_STRING;
               attr &= ~FI_CMD_KEY;

               if (strcmp (t_str, "COMMAND STRING") == 0)
                  attr |= FI_CMD_STRING;
               else
                  attr |= FI_CMD_KEY;

               FIfld_get_text (Preview_form, 11, x, 3, 200, (unsigned char *)t_str, &state, &pos);
               FIg_set_command (work_form, preview_list[x], t_str);
            }
            
            FIfld_get_text (Preview_form, 11, x, 4, 200, (unsigned char *)t_str, &state, &pos);
            if (strcmp (t_str, "  TEXT") == 0)
            {
               attr |= FI_TEXT_GADGET;
               FIg_set_attr (work_form, preview_list[x], attr);

               FIfld_get_text (Preview_form, 11, x, 5, 19, (unsigned char *)fontname, &state, &pos);
               FIfld_get_text (Preview_form, 11, x, 6, 200, (unsigned char *)t_str, &state, &pos);
               i = atoi (t_str);
               bodysize = (float)i;
               FIg_set_font (work_form, preview_list[x], fontname, bodysize);
               FIfld_get_text (Preview_form, 11, x, 7, 200, (unsigned char *)t_str, &state, &pos);
               FIg_set_text (work_form, preview_list[x], t_str);
            }
            else   /* symbol button */
            {
               attr &= ~FI_TEXT_GADGET;
               FIg_set_attr (work_form, preview_list[x], attr);

               FIfld_get_text (Preview_form, 11, x, 5, 19, (unsigned char *)fontname, &state, &pos);
               FIfld_get_text (Preview_form, 11, x, 6, 200, (unsigned char *)t_str, &state, &pos);
               i = atoi (t_str);
               FIg_set_symbol_file (work_form, preview_list[x], fontname);
               FIg_set_off_symbol_index (work_form, preview_list[x], i); 
            }
            FIg_activate (work_form, preview_list[x]);
         }
         FIf_erase (Preview_form);
         FIg_set_state_off (Preview_form, FI_ACCEPT);
         kill_preview_outline();

/* FIf_erase immediately followed by FIf_display causes bus error
   So replace this with a call to FIf_paint_area.
               GMD 12/9/91                                           */

/*
         FIf_erase (work_form);
         FIf_display (work_form);
*/
         FIf_get_size (work_form, &xsize, &ysize);
         FIf_paint_area (work_form, 0, 0, xsize, ysize);

         break;
   }
}

/*************************************************************************/

void Init_preview_form(void)
{
int x, y;
int attr;
struct FIbtn_obj * gadget; 
int gadget_label;
int num_rows = 0;
char fontname[200];
float bodysize;
char t_str[200];
int index;

   FIfld_set_num_rows (Preview_form, 11, 0);

   for (x = 0; x < palette_count; x++)
   {
      for (y = 0; y < gadget_count[x]; y++)
      {
         FIfld_set_text (Preview_form, 11, num_rows, 0, &(palette_name[x][0]), 0);
         sprintf (t_str, "  %d", palette_level[x]);
         FIfld_set_text (Preview_form, 11, num_rows, 1, t_str, 0);

         gadget_label = gadget_list[x][y];
         preview_list[num_rows] = gadget_label;
         FIg_get_attr (work_form, gadget_label, &attr);

         if (attr & FI_TEXT_GADGET)
         {
            FIfld_set_text (Preview_form, 11, num_rows, 4, "  TEXT", 1);
            FIg_get_font (work_form, gadget_label, fontname, &bodysize);
            FIfld_set_text (Preview_form, 11, num_rows, 5, fontname, 0);
            sprintf (t_str, "%d", (int)bodysize);
            FIfld_set_text (Preview_form, 11, num_rows, 6, t_str, 0);
            FIg_get_text (work_form, gadget_label, t_str);
            FIfld_set_text (Preview_form, 11, num_rows, 7, t_str, 0);
         }
         else  /* Symbol gadget */
         {
            FIg_get_symbol_file (work_form, gadget_label, fontname);
            FIg_get_off_symbol_index (work_form, gadget_label, &index);
            FIfld_set_text (Preview_form, 11, num_rows, 4, " SYMBOL", 1);
            FIfld_set_text (Preview_form, 11, num_rows, 5, fontname, 0);
            sprintf (t_str, "%d", index);
            FIfld_set_text (Preview_form, 11, num_rows, 6, t_str, 0);
         }

         gadget = (struct FIbtn_obj *) _FI_g_get_id ((struct FIform_obj *)work_form, gadget_label);
         if ((gadget->FIbtn.menu_button) &&
            (gadget->FIbtn.palette[0] != (char) NULL))
         {
            /* button has a sub-palette */
            FIfld_set_text (Preview_form, 11, num_rows, 2, "SUB-PALETTE", 1);
            FIfld_set_text (Preview_form, 11, num_rows, 3, 
                                          gadget->FIbtn.palette, 0);
         }
         else
         {
            if (attr & FI_CMD_STRING)
               FIfld_set_text (Preview_form, 11, num_rows, 2, "COMMAND STRING", 1);
            else
               FIfld_set_text (Preview_form, 11, num_rows, 2, "COMMAND KEY", 1);
            FIg_get_command (work_form, gadget_label, t_str);
            FIfld_set_text (Preview_form, 11, num_rows, 3, t_str, 0);
         }
         num_rows++;
      }
   }
   FIfld_set_max_num_rows (Preview_form, 11, num_rows);
}

/*************************************************************************/

void execute_preview_outline(void)
{
   int status;	
   char t_str[200];


   if (work_form == NULL)
   {
      kill_preview_outline();
   }
   else
   {
      UMSGetByNum (t_str, MB_I_PREVIEW, 0);
      FIfld_set_text (Message_form, 11, 0, 0, t_str, 0);
      UMSGetByNum (t_str, MB_I_FILLPREVIEW, 0);
      FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

      if (Preview_form == NULL)
      {
         strcpy (t_str, execute_dir);
         strcat (t_str, "/config/");
         strcat (t_str, language);
         strcat (t_str, "/forms/MBPreview");

         status = FIf_new (100, t_str, (int (*)())fi_preview_form, &Preview_form);

         if (status != 0)
            Report_fatal_form_error (status, t_str);
      }
      FIg_erase (Preview_form, 10);   /* Error field */ 
      Init_preview_form();
      FIf_display (Preview_form);
   }
}
