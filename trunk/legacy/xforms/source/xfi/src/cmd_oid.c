#include "FImin.h"

#include "XFIproto_pri.h"
#include "XFIproto_pub.h"

/* FIf_set/get_cmd_oid_os - JAJ:01-05-89 */
/* Functions needed by COB and CI in order to more */
/* efficiently handle forms in the wonderful world */
/* of IGE and OM. */

/* dmb:10/01/92:Changed type of cmd_os for ANSI build */
/* We can't change the existing prototypes, but this is WRONG! */

int FIf_set_cmd_oid_os (Form form,
                        unsigned int cmd_oid,
                        unsigned int cmd_os)
{
   ((struct FIform_obj *) form)->cmd_oid = cmd_oid;
/* dmb:10/01/92:Added cast for ANSI build */
   ((struct FIform_obj *) form)->cmd_os = (short)cmd_os;
   return (FI_SUCCESS);
}

/* dmb:10/01/92:Added for ANSI build */

int FIf_set_cmd_oid_os_ANSI (Form            form,
                             unsigned int    cmd_oid,
                             unsigned short  cmd_os)
{
   ((struct FIform_obj *) form)->cmd_oid = cmd_oid;
   ((struct FIform_obj *) form)->cmd_os = cmd_os;
   return (FI_SUCCESS);
}


int FIf_get_cmd_oid_os (Form             form,
                        unsigned int    *cmd_oid,
                        unsigned short  *cmd_os)
{
   *cmd_oid = ((struct FIform_obj *) form)->cmd_oid;
   *cmd_os = ((struct FIform_obj *) form)->cmd_os;
   return (FI_SUCCESS);
}

int FIg_get_help_topic (Form   form,
                        int    label,
                        char  *help_topic)
{
   struct FIgadget_obj *gadget;

   gadget = _FI_g_get_id ( (struct FIform_obj *) form, label);

   if (! gadget)
	  return (FI_NO_SUCH_GADGET);

   strcpy (help_topic, gadget->FIgadget.help_topic);

   return (FI_SUCCESS);
}

int FIg_get_command (Form   form,
                     int    label,
                     char  *command)
{
   struct FIgadget_obj *gadget;

   gadget = _FI_g_get_id ( (struct FIform_obj *) form, label);

   if (! gadget)
	  return (FI_NO_SUCH_GADGET);

   strcpy (command, gadget->FIgadget.command);

   return (FI_SUCCESS);
}

int FIg_set_help_topic (Form   form,
                        int    label,
                        char  *help_topic)
{
   struct FIgadget_obj *gadget;

   gadget = _FI_g_get_id ( (struct FIform_obj *) form, label);

   if (! gadget)
	  return (FI_NO_SUCH_GADGET);

   _FI_s_rep (&gadget->FIgadget.help_topic, help_topic);

   return (FI_SUCCESS);
}

int FIg_set_command (Form   form,
                     int    label,
                     char  *command)
{
   struct FIgadget_obj *gadget;

   gadget = _FI_g_get_id ( (struct FIform_obj *) form, label);

   if (! gadget)
	  return (FI_NO_SUCH_GADGET);

   _FI_s_rep (&gadget->FIgadget.command, command);

   return (FI_SUCCESS);
}

int FIg_get_help_topic_length (Form   form,
                               int    label,
                               int   *help_topic_length)
{
   struct FIgadget_obj *gadget;

   gadget = _FI_g_get_id ( (struct FIform_obj *) form, label);

   if (! gadget)
	  return (FI_NO_SUCH_GADGET);

   *help_topic_length = strlen (gadget->FIgadget.help_topic) + 1;

   return (FI_SUCCESS);
}

int FIg_get_command_length (Form  form,
                            int   label,
                            int  *command_length)
{
   struct FIgadget_obj *gadget;

   gadget = _FI_g_get_id ( (struct FIform_obj *) form, label);

   if (! gadget)
	  return (FI_NO_SUCH_GADGET);

   *command_length = strlen (gadget->FIgadget.command) + 1;

   return (FI_SUCCESS);
}

