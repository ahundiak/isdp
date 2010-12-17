
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

#include "FImgt.h"
#include "FIext.h"

#include "XFIproto_pri.h"
#include "XFIproto_pub.h"
#include "XMBproto_pri.h"


extern Display *display;
extern Form work_form;
extern Form Message_form;
extern Form Menubar_form;
extern Form define_form;
extern Form Preview_form;
extern Form button_form;
extern Form Construct_form;
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

void kill_reload_symbols(void)
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

void execute_reload_symbols(void)
{
   char t_str[200];
   int x, y, ii;

   if (work_form == NULL)
   {
      sleep (1);
      kill_reload_symbols();
   }
   else
   {
      UMSGetByNum (t_str, MB_I_RELOAD, 0);
      FIfld_set_text (Message_form, 11, 0, 0, t_str, 0);

      if (_FI_next_symbol > 0)
      {
         for (x = 0; x < _FI_next_symbol; x++)
         {
            for (y = 0; y < 256; y++)
            {
               if (_FI_symbols[x].sym_slot[y].bitmap)
                  free (_FI_symbols[x].sym_slot[y].bitmap);

/* dmb:09/01/92:This needs work */
               for (ii=0; ii < 8; ii++)
               {
                 if (_FI_symbols[x].sym_slot[y].pixmap[ii])
                    XFreePixmap (display, _FI_symbols[x].sym_slot[y].pixmap[ii]);
               }
            }
            memset (&(_FI_symbols[x]), 0, sizeof (_FI_symbols[x]));
         }
      }

      _FI_next_symbol = 0;
      
      FIg_activate (Menubar_form, 0);
      Redisplay (Menubar_form);

      if (Preview_form != NULL)
         FIg_activate (Preview_form, 0);

      if (button_form != NULL)
         FIg_activate (button_form, 0);

      if (Construct_form != NULL)
         FIg_activate (Construct_form, 0);

      if (define_form != NULL)
      {
         FIg_activate (define_form, 0);
      }

      if (work_form != NULL)
      {
         FIg_activate (work_form, 0);
         Redisplay (work_form);
      }

      kill_reload_symbols();   
   }
}
