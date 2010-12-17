
                      /********************************/
                      /*                              */
                      /*          exit_fb.c           */
                      /*                              */
                      /* This set of functions allows */
                      /* the form builder program to  */
                      /* be exited.                   */
                      /*                              */
                      /*  Programmer: Mack Draper     */
                      /*                              */
                      /*  Date:       Nov. 1, 1988    */
                      /*                              */
                      /********************************/

#include <stdio.h>

#include "FI.h"
#include "XMBpriv.h"
#include "UMS.h"
#include "XMB.h"

#include "XFIproto_pri.h"
#include "XFIproto_pub.h"
#include "XMBproto_pri.h"


extern Form work_form;
extern char current_command_string[80];
extern int command_is_active;
extern int exit_flag;
extern char menu_locations[256];

extern Form save_form;

/*------------------------------------------------------------------------*/

void execute_EXIT(void)
{
   if (work_form != NULL)
   {
      execute_save_menu();
   }
   else
   {
      command_is_active = 0;
      strcpy(current_command_string, "None");
      exit_flag = 1;

      MS_save_locations( menu_locations );
      exit(0);  /* dmb:04/13/93:Added arg to satisfy ANSI build on SUNOS5 */

   }
}

/*------------------------------------------------------------------------*/


void kill_EXIT(void)
{
char t_str[2000];

   if (save_form != NULL)
      FIf_erase (save_form);
   
   UMSGetByNum (t_str, MB_P_SELCOM, 0);
   fprintf (stderr, "%s\n", t_str);

   command_is_active = 0;
   strcpy (current_command_string, "None");
}

