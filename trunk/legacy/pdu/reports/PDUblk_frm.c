#include <stdio.h>
#include <tools.h>
#include <FI.h>
#include <FIdyn.h>
#include <PDUerror.h>
#include <PDUcommand.h>
#include <PDUforms.h>
#include <PDUform_def.h>
#include <PDUfile_def.h>
#include <PDUstr.h>
#include <PDUproto.h>

#define BLANK_FORM	222

/* Global Variables */
Form PDU_blank_report_form_id;
int TITLE;

extern Form psu_format_id;
extern char *PDU_report_title;
extern struct PDUforms forms;
extern char **rpt_value_list;
extern int PSU_attr_total;

/* Gadgets */



int blank_form_notification_routine ( f_label, g_label, value, fp )
  int     f_label;       /* The label of the form   */
  int     g_label;       /* The label of the gadget */
  double  value;         /* The value of the gadget */
  Form    fp;            /* Pointer to the form     */
{

  switch ( g_label )
  {
    case FI_CANCEL:     /* Member of group FI_CTRL_GROUP */

          /* Erase the displayed form */
         _pdm_debug("f_label = <%d>", (char *)f_label);
         value = 0.0;

         PDUfree_string_array(&rpt_value_list, PSU_attr_total);

         FIf_erase(psu_format_id);
         FIf_erase(fp);
         FIf_delete ( fp );
         FIf_delete ( psu_format_id );

         /* clear out global variables */
         FIf_display(forms.report_form_id);
         break;

    case FI_ACCEPT:     /* Member of group FI_CTRL_GROUP */

          /* Erase the displayed form */

         PDUfree_string_array(&rpt_value_list, PSU_attr_total);

         FIf_delete ( fp );
         FIf_delete ( psu_format_id );

         /* call function to finish defining report */
         PDUfinish_define_format();

         break;

  } /* END switch ( g_label ) */
  return(1);
} /* END notification_routine() */

int PDUblank_report_form()

  {
  int status;

  status = FIf_new(BLANK_FORM, "psu_format1", blank_form_notification_routine,
                   &PDU_blank_report_form_id);

  _pdm_debug("Creating blank form", 0);


  /* dynamically create Title of form */

  status = FIf_display(PDU_blank_report_form_id);

  if (status == FI_SUCCESS)
    status = PDM_S_SUCCESS;
 
  return(status);
  }

