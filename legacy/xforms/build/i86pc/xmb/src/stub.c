#include <stdio.h>
#include "FI.h"

#include "XFIproto_pri.h"
#include "XFIproto_pub.h"
#include "XMBproto_pri.h"

Form Construct_form = NULL;

extern char execute_dir[300];
extern char language[200];

/* ARGSUSED */
void fi_construct_form (int form_label,
                       int gadget_label,
                       double value)
{
   FIg_set_state_off (Construct_form, FI_ACCEPT);
   FIf_erase (Construct_form);
}

void kill_default_settings(void)
{
   FIf_erase (Construct_form);
}

void kill_HELP(void)
{
   FIf_erase (Construct_form);
}

void execute_default_settings(void)
{
char t_str[300];
int status;

   if (Construct_form == NULL)
   {
      strcpy (t_str, execute_dir);
      strcat (t_str, "/config/");
      strcat (t_str, language);
      strcat (t_str, "/forms/MBConstruct");

      status = FIf_new (100, t_str, (int (*)())fi_construct_form, &Construct_form);

      if (status != 0)
          Report_fatal_form_error (status, t_str);
   }

   FIf_display (Construct_form);
}

void execute_HELP(void)
{
char t_str[300];
int status;

   if (Construct_form == NULL)
   {
      strcpy (t_str, execute_dir);
      strcat (t_str, "/config/");
      strcat (t_str, language);
      strcat (t_str, "/forms/MBConstruct");

      status = FIf_new (100, t_str, (int (*)())fi_construct_form, &Construct_form);

      if (status != 0)
          Report_fatal_form_error (status, t_str);
   }

   FIf_display (Construct_form);
}

