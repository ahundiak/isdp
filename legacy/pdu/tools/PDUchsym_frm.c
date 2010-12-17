#include <stdio.h>
#include <tools.h>
#include <FI.h>
#include <PDUerror.h>
#include <PDUstr.h>
#include <PDUcommand.h>
#include <PDUforms.h>
#include "PDUform_def.h"
#include <MEMerrordef.h>
#include "PDUfile_def.h"
#include "PDUproto.h"


/* Gadgets */

#define SYMBOLOGY_MCF  11


/* Externs */

extern char * calloc();
extern char * realloc();
extern int FImcf_get_active_col();

extern struct PDUforms forms;
extern Form PDU_calling_form;


int change_symbology_notification_routine ( f_label, g_label, value, fp )
  int     f_label;       /* The label of the form   */
  int     g_label;       /* The label of the gadget */
  double  value;         /* The value of the gadget */
  Form    fp;            /* Pointer to the form     */
{
  static char   * text;
  int             length;
  int             select;
  int             pos;
  int             status;

  switch ( g_label )
  {
    case FI_CANCEL:     /* Member of group FI_CTRL_GROUP */
                             /* Sequenced to    */

          /* Erase the displayed form */

         FIf_delete ( fp );
         FIf_display(PDU_calling_form);

         break;

    case FI_ACCEPT:     /* Member of group FI_CTRL_GROUP */
                             /* Sequenced to    */

          /* Erase the displayed form */

         FIf_delete ( fp );

          /* Process form data */
         FIf_display(PDU_calling_form);

         break;

    case SYMBOLOGY_MCF:     /* Sequenced to     */

          /* Get the text string */

          FIfld_get_text_length(fp,SYMBOLOGY_MCF,0,0,&length);
          text = (char *) malloc (sizeof (char) * length + 1);
          memset(text, NULL, sizeof (char) * length + 1);
          FIfld_get_text(fp,SYMBOLOGY_MCF,0,0,length,(unsigned char *)text,&select,&pos);

          if ( status != FI_SUCCESS )
            {
              /* Code to handle error */

              break;
            }

          /* Code to process text string "text" */

         break;

  } /* END switch ( g_label ) */
  return(1);
} /* END notification_routine() */

int change_symbology_form()
{
  int  status;

  status = FIf_new(CHANGE_SYMBOLOGY_FORM, "MOaMldSym",
                change_symbology_notification_routine,
                &forms.change_symbology_form_id);

  _pdm_debug("Creating Change Symbology Form", 0);

  _pdm_debug("Displaying the Change Symbology Form", 0);

  status = FIf_display(forms.change_symbology_form_id);

  return(status);

}

int PDUchange_symbology()

{
  int status;

  status = change_symbology_form();
  _pdm_status("change_symbology_form", status);

  if (status == FI_SUCCESS)
    status = PDM_S_SUCCESS;

  return(status);
 }
