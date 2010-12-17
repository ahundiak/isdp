
                      /********************************/
                      /*                              */
                      /*          swap_btn.c          */
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

#include "XFIproto_pri.h"
#include "XFIproto_pub.h"
#include "XMBproto_pri.h"

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

/*------------------------------------------------------------------------*/

void kill_swap_buttons(void)
{
char t_str[2000];

   FIfld_set_text (Message_form, 11, 0, 0, "", 0);
   FIfld_set_text (Message_form, 22, 0, 0, "", 0);
   FIfld_set_text (Message_form, 33, 0, 0, "", 0);
   FIfld_set_text (Message_form, 44, 0, 0, "", 0);
   FIg_display (Message_form, 11);
   FIg_display (Message_form, 22);
   FIg_display (Message_form, 33);
   FIg_display (Message_form, 44);

   UMSGetByNum (t_str, MB_P_SELCOM, 0);
   FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

   command_is_active = 0;
   strcpy (current_command_string, "None");
}

/*************************************************************************/

void swap_buttons (int first,
                  int second)
{
   int first_slot = 0, second_slot = 0;
   int x, temp;
   int x1, y1, x2, y2;

   if ((menu_type == MENU_BAR) || (menu_type == POPUP_MENU))
   {
      FIg_erase (work_form, first);
      FIg_erase (work_form, second);
      FIg_unhilite (work_form, first);
      FIg_unhilite (work_form, second);

      for (x=0; x < gadget_count[0]; x++)
          if (gadget_list[0][x] == first)
          {
             first_slot = x;
             x = gadget_count[0];
          }   
   
      for (x=0; x < gadget_count[0]; x++)
          if (gadget_list[0][x] == second)
          {
             second_slot = x;
             x = gadget_count[0];
          }

      temp = gadget_list[0][first_slot];
      gadget_list[0][first_slot] = gadget_list[0][second_slot];
      gadget_list[0][second_slot] = temp;

      FIg_get_location (work_form, first, &x1, &y1);
      FIg_get_location (work_form, second, &x2, &y2);
      FIg_set_location (work_form, first, x2, y2);
      FIg_set_location (work_form, second, x1, y1);
      FIg_display (work_form, first);
      FIg_display (work_form, second);
   }
   else    /* Panel Menu */
   {
      int pal_index, pal_index2;
      int pal_level, pal_level2;
      char t_str[300];

      Find_palette_and_level (first, &pal_index, &pal_level);
      Find_palette_and_level (second, &pal_index2, &pal_level2);

      if (pal_index != pal_index2)
      {
         UMSGetByNum (t_str, MB_E_SWAPPANEL, 0);
         FIfld_set_text (Message_form, 22, 0, 0, t_str, 0);
         FIg_unhilite (work_form, first);
         FIg_unhilite (work_form, second);
      }
      else
      {
         FIg_erase (work_form, first);
         FIg_erase (work_form, second);
         FIg_unhilite (work_form, first);
         FIg_unhilite (work_form, second);

         for (x=0; x < gadget_count[pal_index]; x++)
            if (gadget_list[pal_index][x] == first)
            {
               first_slot = x;
               x = gadget_count[pal_index];
            }   
   
         for (x=0; x < gadget_count[pal_index]; x++)
            if (gadget_list[pal_index][x] == second)
            {
               second_slot = x;
               x = gadget_count[pal_index];
            }

         temp = gadget_list[pal_index][first_slot];
         gadget_list[pal_index][first_slot] = gadget_list[pal_index][second_slot];
         gadget_list[pal_index][second_slot] = temp;

         FIg_get_location (work_form, first, &x1, &y1);
         FIg_get_location (work_form, second, &x2, &y2);
         FIg_set_location (work_form, first, x2, y2);
         FIg_set_location (work_form, second, x1, y1);
         FIg_display (work_form, first);
         FIg_display (work_form, second);
      }
   }
}

/*************************************************************************/

void execute_swap_buttons(void)
{
   int status;	
   char t_str[200];
   int not_finished;
   int first_gadget, second_gadget;
   int dummy_int;
   int mode;

   if (work_form == NULL)
   {
      kill_swap_buttons();
   }
   else
   {
      UMSGetByNum (t_str, MB_I_SWAPBTNS, 0);
      FIfld_set_text (Message_form, 11, 0, 0, t_str, 0);

      not_finished = 1; 

      mode = 0;    /* Force operator to select a point */

      while (not_finished)
      {
         UMSGetByNum (t_str, MB_P_SELGDT, 0);
         FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

         status = Select_gadget (&first_gadget, &dummy_int, &dummy_int, 
                                 &dummy_int, &dummy_int, 
                                 &dummy_int, &dummy_int, mode);
   
         if (status == 2)  /* Success */
         {
            FIfld_set_text (Message_form, 22, 0, 0, "", 0);

            status = Select_gadget (&second_gadget, &dummy_int, &dummy_int, 
                                    &dummy_int, &dummy_int, 
                                    &dummy_int, &dummy_int, mode);

            if (status == 2)
            {
               if (second_gadget != first_gadget)
                  swap_buttons (first_gadget, second_gadget);
               else
               {
                  UMSGetByNum (t_str, MB_E_SELDIFFGDT, 0);
                  FIfld_set_text (Message_form, 22, 0, 0, t_str, 0);

                  FIg_unhilite (work_form, first_gadget);
               }
            }
            else
               FIg_unhilite (work_form, first_gadget);
         }
         else
         {
            not_finished = 0;  /* done */
         }
      }

      if (command_is_active == SWAP_BUTTONS)   
         kill_swap_buttons();   
   }
}
