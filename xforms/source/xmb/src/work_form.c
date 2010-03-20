
#include <stdio.h>
#include "FI.h"
#include "FIdyn.h"
#include "FImin.h"
#include "FIgadget.h"
#include "FIbtn.h"
                  
#include "XFIproto_pri.h"
#include "XFIproto_pub.h"
#include "XMBproto_pri.h"

Form work_form = NULL;

extern int command_is_active;
extern Form Message_form;

extern int gadget_list[255][100];
extern char palette_name[255][20];
extern int gadget_count[255];
extern int palette_level[255];
extern int group_list[255];
extern int palette_count;

int displayed_pal_2nd = 0;
int displayed_pal_3rd = 0;
int displayed_pal_4th = 0;

/*------------------------------------------------------------------------*/

void Find_palette_and_level (int gadget_label,
                            int *pal_index,
                            int *pal_level)
{
int x, y;

   for (x = 0; x < palette_count; x++)
      for (y = 0; y < gadget_count[x]; y++)
         if (gadget_list[x][y] == gadget_label)
         {
            *pal_index = x;
            *pal_level = palette_level[x];

            y = gadget_count[x];
            x = palette_count;
         }
}

/*------------------------------------------------------------------------*/
/* ARGSUSED */
void fi_work_form (int form_label,
                  int gadget_label,
                  double value)
{
struct FIbtn_obj * gadget;
int pal_level, pal_index;
int x;

   if (palette_count > 1)
   {
      Find_palette_and_level (gadget_label, &pal_index, &pal_level);

      /* Erase any subpalettes that the previously selected button at   */
      /* this level had below it.                                       */

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

      gadget = (struct FIbtn_obj *) _FI_g_get_id ((struct FIform_obj *)work_form, gadget_label);

      if ((gadget->FIbtn.menu_button) &&
          (gadget->FIbtn.palette[0] != NULL))
      {
         for (x = 0; x < palette_count; x++)
            if (strcmp (gadget->FIbtn.palette, &(palette_name[x][0])) == 0)
            {
               FIg_display (work_form, group_list[x]);
               if (pal_level == 1)
                  displayed_pal_2nd = x;
               if (pal_level == 2)
                  displayed_pal_3rd = x;
               if (pal_level == 3)
                  displayed_pal_4th = x;

               x = palette_count;
            }
      }
   }
}

/* ARGSUSED */
void fi_dummy_work_form (int form_label,
                        int gadget_label,
                        double value)
{
}

/* ARGSUSED */
void fi_message_form (int form_label,
                     int gadget_label,
                     double value)
{
}

