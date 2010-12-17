
                      /********************************/
                      /*                              */
                      /*         paste_btn.c          */
                      /*                              */
                      /*  Programmer: Mack Draper     */
                      /*                              */
                      /*  Date:       Jul. 23, 1991   */
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

extern int panel_cols_top;
extern int panel_cols_2nd;
extern int panel_cols_3rd;
extern int panel_cols_4th;
extern int panel_ysize_top;
extern int panel_ysize_2nd;
extern int panel_ysize_3rd;
extern int panel_ysize_4th;

extern int displayed_pal_2nd;
extern int displayed_pal_3rd;
extern int displayed_pal_4th;

/*------------------------------------------------------------------------*/

void kill_paste_button(void)
{
char t_str[2000];

   FIfld_set_text (Message_form, 11, 0, 0, "", 0);
   FIg_display (Message_form, 11);
   FIfld_set_text (Message_form, 22, 0, 0, "", 0);
   FIg_display (Message_form, 22);
   FIfld_set_text (Message_form, 33, 0, 0, "", 0);
   FIg_display (Message_form, 33);
   FIfld_set_text (Message_form, 44, 0, 0, "", 0);
   FIg_display (Message_form, 44);

   UMSGetByNum (t_str, MB_P_SELCOM, 0);
   FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

   command_is_active = 0;
   strcpy (current_command_string, "None");
}

/*************************************************************************/

void Paste_button_to_menu_bar (void)
{
int menu_x_size, menu_y_size;
int new_x_size;
int x;
int xsize, ysize;
int label, status;
float float_xsize;
int xpos, gdt_type;

   status = FIg_get_type (work_form, -1000, &gdt_type);
   
   if (status == FI_SUCCESS)
   {
      /*******************************************************************/
      /*                                                                 */
      /* First see how many gadgets are currently on the menu bar, then  */
      /* resize them and shuffle them to the left to make room for the   */
      /* new menu bar button.                                            */
      /*                                                                 */
      /*******************************************************************/

      FIf_get_size (work_form, &menu_x_size, &menu_y_size);
      float_xsize = (float)(menu_x_size - 6) / (float)(gadget_count[0] + 1);
      new_x_size = (int)float_xsize;
      FIg_erase (work_form, group_list[0]);

      for (x = 0; x < gadget_count[0]; x++)
      {
         FIg_get_size (work_form, gadget_list[0][x], &xsize, &ysize);
         FIg_set_size (work_form, gadget_list[0][x], new_x_size, ysize);
         xpos = 3 + (int)((float_xsize * (float)x));
         FIg_set_location (work_form, gadget_list[0][x], xpos, 2);
      }

      FIg_copy (work_form, -1000, &label, 1);

      xpos = 3 + (int)((float_xsize * (float)gadget_count[0]));

      FIg_set_location (work_form, label, xpos, 2);
      FIg_set_size (work_form, label, new_x_size, ysize);

      gadget_list[0][gadget_count[0]] = label;
      gadget_count[0]++;
      FIg_add_to_group (work_form, label, group_list[0]);
      FIg_display (work_form, group_list[0]);
   }
}

void Paste_button_to_popup_menu(void)
{
int label, status;
int gdt_type;

   status = FIg_get_type (work_form, -1000, &gdt_type);
   
   if ((status == FI_SUCCESS) &&
       (gadget_count[0] < (popup_rows * popup_cols)))
   {
      FIg_copy (work_form, -1000, &label, 1);

      FIg_set_location (work_form, label,
                           (gadget_count[0] % popup_cols) * 43, 
                           2 + ((gadget_count[0] / popup_cols) * 45));

      gadget_list[0][gadget_count[0]] = label;
      gadget_count[0]++;
      FIg_add_to_group (work_form, label, group_list[0]);
      FIg_display (work_form, label);
   }
}

/*--------------------------------------------------------------------------*/

void Move_palette_down (pal_name, ysize)
char * pal_name;
int ysize;
{
int pal_index;
int x, y;
struct FIbtn_obj * gadget;

   for (x = 0; x < palette_count; x++)
      if (strcmp (&(palette_name[x][0]), pal_name) == 0)
      {
         pal_index = x;

         for (y = 0; y < gadget_count[pal_index]; y++)
         {
         int xpos, ypos;

            FIg_get_location (work_form, gadget_list[pal_index][y],
                                         &xpos, &ypos);
            FIg_set_location (work_form, gadget_list[pal_index][y],
                                         xpos, ypos + ysize);
         }

         for (y = 0; y < gadget_count[pal_index]; y++)
         {
            gadget = (struct FIbtn_obj *) _FI_g_get_id ((struct FIform_obj *)work_form, gadget_list[pal_index][y]);
            if ((gadget->FIbtn.menu_button) &&
                (gadget->FIbtn.palette[0] != (char) NULL))
            {
            char t_str[300];

               strcpy (t_str, (char *)gadget->FIbtn.palette);
               Move_palette_down (t_str, ysize);
            }
         }
         x = palette_count;
      }
}

/*------------------------------------------------------------------------*/

void Paste_button_to_panel_menu(void)
{
int label, status;
int gdt_type;
int xsize, ysize;
int pal_index = 0, pal_level = 0;
char t_str[300];
int base_line;
int panel_cols = 0;
struct FIbtn_obj * gadget;
int xpos, x;

   status = FIg_get_type (work_form, -1000, &gdt_type);
   
   if (status == FI_SUCCESS)
   {
      /***************************************************************/
      /*                                                             */
      /*  Figure out the level of the button by looking at its size  */
      /*                                                             */
      /***************************************************************/

      FIg_get_size (work_form, -1000, &xsize, &ysize);
      if (ysize == panel_ysize_top)
         pal_level = 1;
      if (ysize == panel_ysize_2nd)
         pal_level = 2;
      if (ysize == panel_ysize_3rd)
         pal_level = 3;
      if (ysize == panel_ysize_4th)
         pal_level = 4;

      /***************************************************************/
      /*                                                             */
      /*  If there is no palette currently displayed at this level,  */
      /* alert the operator and abort the paste operation.           */
      /*                                                             */
      /***************************************************************/

      if (((pal_level == 2) && (displayed_pal_2nd == 0)) ||
          ((pal_level == 3) && (displayed_pal_3rd == 0)) ||
          ((pal_level == 4) && (displayed_pal_4th == 0)))
      {
         UMSGetByNum (t_str, MB_E_PALNOTDISP, 0);
         Report_nonfatal_error (t_str);
         return;
      }

      FIg_copy (work_form, -1000, &label, 1);

      /***********************************************/
      /*                                             */
      /*  Determine location to place pasted button  */
      /*                                             */
      /***********************************************/

      if (pal_level == 1)
      {
         pal_index = 0;
         xsize = 180 / panel_cols_top;
         ysize = panel_ysize_top;
         panel_cols = panel_cols_top;
      }
      if (pal_level == 2)
      {
         pal_index = displayed_pal_2nd;
         xsize = 180 / panel_cols_2nd;
         ysize = panel_ysize_2nd;
         panel_cols = panel_cols_2nd;
      }
      if (pal_level == 3)
      {
         pal_index = displayed_pal_3rd;
         xsize = 180 / panel_cols_3rd;
         ysize = panel_ysize_3rd;
         panel_cols = panel_cols_3rd;
      }
      if (pal_level == 4)
      {
         pal_index = displayed_pal_4th;
         xsize = 180 / panel_cols_4th;
         ysize = panel_ysize_4th;
         panel_cols = panel_cols_4th;
      }

      FIg_get_location (work_form, gadget_list[pal_index][0], &xpos, &base_line);

      FIg_set_location (work_form, label,
                           (gadget_count[pal_index] % panel_cols) * xsize, 
                 base_line + ((gadget_count[pal_index] / panel_cols) * ysize));

      gadget_list[pal_index][gadget_count[pal_index]] = label;
      gadget_count[pal_index]++;
      FIg_add_to_group (work_form, label, group_list[pal_index]);

      /*****************************************************************/
      /*                                                               */
      /*   Before displaying the new button, it is necessary to shift  */
      /*   any subpalettes it might have downwards if necessary.       */
      /*                                                               */
      /*****************************************************************/

      if ((gadget_count[pal_index] % panel_cols) == 1)
      {
         if ((pal_level < 4) && (displayed_pal_4th))
            FIg_erase (work_form, group_list[displayed_pal_4th]);
         if ((pal_level < 3) && (displayed_pal_3rd))
            FIg_erase (work_form, group_list[displayed_pal_3rd]);
         if ((pal_level < 2) && (displayed_pal_2nd))
            FIg_erase (work_form, group_list[displayed_pal_2nd]);

         XSync (_FI_display, 0);

         for (x = 0; x < gadget_count[pal_index]; x++)
         {
            gadget = (struct FIbtn_obj *) _FI_g_get_id ((struct FIform_obj *)work_form, gadget_list[pal_index][x]);
            if ((gadget->FIbtn.menu_button) &&
                (gadget->FIbtn.palette[0] != (char) NULL))
            {
            char t_str[300];

               strcpy (t_str, (char *)gadget->FIbtn.palette);
               Move_palette_down (t_str, ysize);
            }
         }
         if ((pal_level < 2) && (displayed_pal_2nd))
            FIg_display (work_form, group_list[displayed_pal_2nd]);
         if ((pal_level < 3) && (displayed_pal_3rd))
            FIg_display (work_form, group_list[displayed_pal_3rd]);
         if ((pal_level < 4) && (displayed_pal_4th))
            FIg_display (work_form, group_list[displayed_pal_4th]);
      }

      FIg_display (work_form, label);

      /******************************************************************/
      /*                                                                */
      /* If this button was had a subpalette, then delete gadget 1000   */
      /* to prevent multiple buttons from pointing to the same          */
      /* sub-palette.                                                   */
      /*                                                                */
      /******************************************************************/

      gadget = (struct FIbtn_obj *) _FI_g_get_id ((struct FIform_obj *)work_form, label);
      if ((gadget->FIbtn.menu_button) &&
          (gadget->FIbtn.palette[0] != (char) NULL))
         FIg_delete (work_form, -1000);
   }
}

/*************************************************************************/

void execute_paste_button(void)
{
   char t_str[200];


   if (work_form == NULL)
   {
      sleep (1);
      kill_paste_button();
   }
   else
   {
      UMSGetByNum (t_str, MB_I_PASTEBTN, 0);
      FIfld_set_text (Message_form, 11, 0, 0, t_str, 0);

      if (menu_type == MENU_BAR)
         Paste_button_to_menu_bar();
      
      if (menu_type == POPUP_MENU)
         Paste_button_to_popup_menu();

      if (menu_type == MENU_PANEL)
         Paste_button_to_panel_menu();

      kill_paste_button();   
   }
}
