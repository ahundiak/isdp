
                      /********************************/
                      /*                              */
                      /*           cut_btn.c          */
                      /*                              */
                      /*  Programmer: Mack Draper     */
                      /*                              */
                      /*  Date:       Jul. 23, 1991   */
                      /*                              */
                      /********************************/

#include <stdio.h>

#include <X11/Xlib.h>
#include "FI.h"
#include "UMS.h"
#include "XMB.h"
#include "XMBpriv.h"
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

void kill_cut_button(void)
{
char t_str[2000];

   FIfld_set_text (Message_form, 11, 0, 0, "", 0);
   FIg_display (Message_form, 11);
   FIfld_set_text (Message_form, 22, 0, 0, "", 0);
   FIg_display (Message_form, 22);
   FIfld_set_text (Message_form, 44, 0, 0, "", 0);
   FIg_display (Message_form, 44);

   UMSGetByNum (t_str, MB_P_SELCOM, 0);
   FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

   command_is_active = 0;
   strcpy (current_command_string, "None");
}

/*************************************************************************/

void Cut_button_from_menu_bar (int label)
{
int menu_x_size, menu_y_size;
int new_x_size;
int x;
int xsize, ysize;
float float_xsize;
int xpos;
int label_ptr, index = 0;

   /*************************************/
   /*                                   */
   /* Erase all gadgets on the menu bar */
   /*                                   */
   /*************************************/

   FIg_erase (work_form, group_list[0]);

   /*******************************************************/
   /*                                                     */
   /* If there is a gadget at label -1000 then delete it. */
   /* Then copy the selected gadget to gadget label -1000 */
   /*                                                     */
   /*******************************************************/

   FIg_delete (work_form, -1000);
   label_ptr = -1000;
   FIg_set_state_off (work_form, label);
   FIg_unhilite (work_form, label);
   FIg_copy (work_form, label, &label_ptr, 0);
   FIg_delete (work_form, label);

   /*******************************************************************/
   /*                                                                 */
   /* Shuffle the gadgets in the gadget_list array to fill in the gap */
   /* left by the deleted gadget.  Decrement the gadget_count.        */
   /*                                                                 */
   /*******************************************************************/

   for (x = 0; x < gadget_count[0]; x++)
      if (gadget_list[0][x] == label)
      {
         index = x;
         x = gadget_count[0];   /* break out of loop */
      }

   if (index < (gadget_count[0] - 1))
   {
      for (x = index; x < gadget_count[0]; x++)
         gadget_list[0][x] = gadget_list[0][x+1];
   }
   gadget_count[0]--;

   /*******************************************************************/
   /*                                                                 */
   /*  Resize all of the gadgets that are left to fill in the space.  */
   /*  Redisplay all gadgets.                                         */
   /*                                                                 */
   /*******************************************************************/

   FIf_get_size (work_form, &menu_x_size, &menu_y_size);
   float_xsize = (float)(menu_x_size - 6) / (float)(gadget_count[0]);
   new_x_size = (int)float_xsize;
   FIg_erase (work_form, group_list[0]);

   for (x = 0; x < gadget_count[0]; x++)
   {
      FIg_get_size (work_form, gadget_list[0][x], &xsize, &ysize);
      FIg_set_size (work_form, gadget_list[0][x], new_x_size, ysize);
      xpos = 3 + (int)((float_xsize * (float)x));
      FIg_set_location (work_form, gadget_list[0][x], xpos, 2);
   }

   FIg_display (work_form, group_list[0]);
}

void Cut_button_from_popup_menu (int label)
{
int x;
int label_ptr, index = 0;

   /******************************************************/
   /*                                                    */
   /* Erase all gadgets from the selected button on down */
   /*                                                    */
   /******************************************************/

   for (x = 0; x < gadget_count[0]; x++)
      if (gadget_list[0][x] == label)
         index = x;

   XSynchronize (display, 1);

    for (x = index; x < gadget_count[0]; x++)
      FIg_erase (work_form, gadget_list[0][x]);

   XSynchronize (display, 0);

   /*******************************************************/
   /*                                                     */
   /* If there is a gadget at label -1000 then delete it. */
   /* Then copy the selected gadget to gadget label -1000 */
   /*                                                     */
   /*******************************************************/

   FIg_delete (work_form, -1000);
   label_ptr = -1000;
   FIg_set_state_off (work_form, label);
   FIg_unhilite (work_form, label);
   FIg_copy (work_form, label, &label_ptr, 0);
   FIg_delete (work_form, label);

   /*******************************************************************/
   /*                                                                 */
   /* Shuffle the gadgets in the gadget_list array to fill in the gap */
   /* left by the deleted gadget.  Decrement the gadget_count.        */
   /*                                                                 */
   /*******************************************************************/

   if (index < (gadget_count[0] - 1))
   {
      for (x = index; x < gadget_count[0]; x++)
         gadget_list[0][x] = gadget_list[0][x+1];
   }
   gadget_count[0]--;

   /*****************************************************/
   /*                                                   */
   /*  Move all of the gadgets to fill in the space.    */
   /*  Redisplay affected gadgets.                      */
   /*                                                   */
   /*****************************************************/

   for (x = index; x < gadget_count[0]; x++)
   {
      FIg_set_location (work_form, gadget_list[0][x],
                           (x % popup_cols) * 43, 
                           2 + ((x / popup_cols) * 45));
      FIg_display (work_form, gadget_list[0][x]);
   }
}

/*------------------------------------------------------------------------*/

void Move_palette_up (char * pal_name,
                     int ysize)
{
int pal_index;
int x, y;
struct FIbtn_obj * gadget;

   for (x = 0; x < palette_count; x++)
      if (strcmp (&(palette_name[x][0]), pal_name) == 0)
      {
         pal_index = x;
         if ((pal_index == displayed_pal_2nd) ||
             (pal_index == displayed_pal_3rd) ||
             (pal_index == displayed_pal_4th))
             FIg_erase (work_form, group_list[pal_index]);

         for (y = 0; y < gadget_count[pal_index]; y++)
         {
         int xpos, ypos;

            FIg_get_location (work_form, gadget_list[pal_index][y],
                                         &xpos, &ypos);
            FIg_set_location (work_form, gadget_list[pal_index][y],
                                         xpos, ypos - ysize);
         }

         if ((pal_index == displayed_pal_2nd) ||
             (pal_index == displayed_pal_3rd) ||
             (pal_index == displayed_pal_4th))
             FIg_display (work_form, group_list[pal_index]);

         for (y = 0; y < gadget_count[pal_index]; y++)
         {
            gadget = (struct FIbtn_obj *) _FI_g_get_id ((struct FIform_obj *)work_form, gadget_list[pal_index][y]);
            if ((gadget->FIbtn.menu_button) &&
                (gadget->FIbtn.palette[0] != (char) NULL))
            {
            char t_str[300];

               strcpy (t_str, (char *)gadget->FIbtn.palette);
               Move_palette_up (t_str, ysize);
            }
         }
         x = palette_count;
      }
}

/*------------------------------------------------------------------------*/

void Cut_button_from_panel_menu (int label)
{
int x;
int label_ptr;
int index = 0;
int pal_index, pal_level;
char t_str[300];
int base_line, cols = 0, xsize = 0, ysize = 0;
struct FIbtn_obj * gadget;
int state;

   Find_palette_and_level (label, &pal_index, &pal_level);

   /***************************************************/
   /*                                                 */
   /* Don't let them erase the last button in a panel */
   /*                                                 */
   /***************************************************/

   if (gadget_count[pal_index] == 1)
   {
      UMSGetByNum (t_str, MB_E_NOTLAST, 0);
      FIfld_set_text (Message_form, 22, 0, 0, t_str, 0);
      FIg_unhilite (work_form, label);
      return;
   }

   /******************************************************/
   /*                                                    */
   /* Erase all gadgets from the selected button on down */
   /*                                                    */
   /******************************************************/

   for (x = 0; x < gadget_count[pal_index]; x++)
      if (gadget_list[pal_index][x] == label)
         index = x;

    for (x = index; x < gadget_count[pal_index]; x++)
      FIg_erase (work_form, gadget_list[pal_index][x]);

   XSync (display, 0);

   /********************************************************************/
   /*                                                                  */
   /* If the button selected for deletion has a state of one, then any */
   /* displayed sub-palettes need to be erased, since their parent     */
   /* button is now gone.                                              */
   /*                                                                  */
   /********************************************************************/

   FIg_get_state (work_form, label, &state);
   if (state == 1)
   {
      if ((pal_level < 4) &&
          (displayed_pal_4th != 0))
      {
         FIg_erase (work_form, group_list[displayed_pal_4th]);
         FIg_set_state_off (work_form, group_list[displayed_pal_4th]);
         displayed_pal_4th = 0;
      }

      if ((pal_level < 3) &&
          (displayed_pal_3rd != 0))
      {
         FIg_erase (work_form, group_list[displayed_pal_3rd]);
         FIg_set_state_off (work_form, group_list[displayed_pal_3rd]);
         displayed_pal_3rd = 0;
      }

      if ((pal_level < 2) &&
          (displayed_pal_2nd != 0))
      {
         FIg_erase (work_form, group_list[displayed_pal_2nd]);
         FIg_set_state_off (work_form, group_list[displayed_pal_2nd]);
         displayed_pal_2nd = 0;
      }

      FIg_set_state_off (work_form, label);
   }

   /*****************************************************************/
   /*                                                               */
   /*  Determine the base_line of this palette by looking at the Y  */
   /*  position of the first gadget in the palette.                 */
   /*                                                               */
   /*****************************************************************/

   FIg_get_location (work_form, gadget_list[pal_index][0], &x, &base_line);

   /*******************************************************/
   /*                                                     */
   /* If there is a gadget at label -1000 then delete it. */
   /* Then copy the selected gadget to gadget label -1000 */
   /*                                                     */
   /*******************************************************/

   FIg_delete (work_form, -1000);
   label_ptr = -1000;
   FIg_set_state_off (work_form, label);
   FIg_unhilite (work_form, label);
   FIg_copy (work_form, label, &label_ptr, 0);
   FIg_delete (work_form, label);

   /*******************************************************************/
   /*                                                                 */
   /* Shuffle the gadgets in the gadget_list array to fill in the gap */
   /* left by the deleted gadget.  Decrement the gadget_count.        */
   /*                                                                 */
   /*******************************************************************/

   if (index < (gadget_count[pal_index] - 1))
   {
      for (x = index; x < gadget_count[pal_index]; x++)
         gadget_list[pal_index][x] = gadget_list[pal_index][x+1];
   }
   gadget_count[pal_index]--;

   /*****************************************************/
   /*                                                   */
   /*  Move all of the gadgets to fill in the space.    */
   /*  Redisplay affected gadgets.                      */
   /*                                                   */
   /*****************************************************/

   if (pal_level == 1)
   {
      cols = panel_cols_top;
      xsize = 180 / panel_cols_top;
      ysize = panel_ysize_top;
   }
   if (pal_level == 2)
   {
      cols = panel_cols_2nd;
      xsize = 180 / panel_cols_2nd;
      ysize = panel_ysize_2nd;
   }
   if (pal_level == 3)
   {
      cols = panel_cols_3rd;
      xsize = 180 / panel_cols_3rd;
      ysize = panel_ysize_3rd;
   }
   if (pal_level == 4)
   {
      cols = panel_cols_4th;
      xsize = 180 / panel_cols_4th;
      ysize = panel_ysize_4th;
   }

   for (x = index; x < gadget_count[pal_index]; x++)
   {
      FIg_set_location (work_form, gadget_list[pal_index][x],
                           (x % cols) * xsize, 
                           base_line + ((x / cols) * ysize));
      FIg_display (work_form, gadget_list[pal_index][x]);
   }

   /**************************************************************/
   /*                                                            */
   /* If the panel loses a row due to the button being deleted,  */
   /* Then shift the location of all children of the palette     */
   /* upwards by one row.  Erase any that are currently          */
   /* displayed first.  Then redisplay after they have been      */
   /* moved.                                                     */
   /*                                                            */
   /**************************************************************/

   if ((gadget_count[pal_index] % cols) == 0)
   {
      for (x = 0; x < gadget_count[pal_index]; x++)
      {
         gadget = (struct FIbtn_obj *) _FI_g_get_id ((struct FIform_obj *)work_form, gadget_list[pal_index][x]);
         if ((gadget->FIbtn.menu_button) &&
             (gadget->FIbtn.palette[0] != (char) NULL))
         {
         char t_str[300];

            strcpy (t_str, (char *)gadget->FIbtn.palette);
            Move_palette_up (t_str, ysize);
         }
      }

      gadget = (struct FIbtn_obj *) _FI_g_get_id ((struct FIform_obj *)work_form, -1000);
      if ((gadget->FIbtn.menu_button) &&
          (gadget->FIbtn.palette[0] != (char) NULL))
      {
      char t_str[300];

         strcpy (t_str, (char *)gadget->FIbtn.palette);
         Move_palette_up (t_str, ysize);
      }
   }
}

/*************************************************************************/

void execute_cut_button(void)
{
   int status;	
   char t_str[200];
   int gadget_label;

   int xsize, ysize, display_flag;
   int  accept_x, accept_y, mode;
   int edit_hilite_flag;
   int loop_again = 1;

   if (work_form == NULL)
   {
      kill_cut_button();
   }
   else
   {
      UMSGetByNum (t_str, MB_I_CUTBTN, 0);
      FIfld_set_text (Message_form, 11, 0, 0, t_str, 0);

   /***********************************************/
   /*                                             */
   /*  First you need to select a button to cut.  */
   /*  kill_cut_button() needs to be called if    */
   /*  a button is not selected.                  */ 
   /*                                             */
   /***********************************************/
   
      UMSGetByNum (t_str, MB_P_SELGDT, 0);
      FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);
 

      mode = 0;    /* Force operator to select a point */

      while (loop_again)
      {
         status = Select_gadget (&gadget_label, &xsize, &ysize, &display_flag,
                                 &edit_hilite_flag, &accept_x, &accept_y, mode);
   
         if (status != 2)  /* Failure */
         {
            if (command_is_active == CUT_BUTTON)
               kill_cut_button();
            return;
         }

         if (menu_type == MENU_BAR)
            Cut_button_from_menu_bar (gadget_label);
      
         if (menu_type == POPUP_MENU)
            Cut_button_from_popup_menu (gadget_label);

         if (menu_type == MENU_PANEL)
            Cut_button_from_panel_menu (gadget_label);   
      }
   }
}
