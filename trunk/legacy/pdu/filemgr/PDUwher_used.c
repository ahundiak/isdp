#include <stdio.h>
#include <FI.h>
#include <tools.h>
#include <PDUerror.h>
#include <PDMtypes.h>
#include <PDUstr.h>
#include <PDUintdef.h>
#include <exdef.h>
#include "PDUform_def.h"
#include <PDUforms.h>
#include <PDUfile_def.h>
#include "PDUproto.h"
#include "PDMproto.h"


/* Gadgets */

#define W_PROJECT          34
#define W_CATALOG          35
#define W_PARTID           36
#define W_REVISION         37
#define W_DESC             12
#define W_PROJECT_BTN      67
#define W_CATALOG_BTN      68
#define W_PARTID_BTN       69
#define W_REVISION_BTN     13
#define CONTAIN_TGL      16


/* Externs */

extern char * calloc();
extern char * realloc();
extern int FIg_get_text_length();
extern int FIg_get_text();
extern int FImcf_get_active_col();
extern int FIg_get_text_length();
extern int FIfld_get_text();
extern int FIg_get_type();
extern short PDU_where_used_created;
extern short PDU_where_used_displayed;
extern int PDU_refresh_gadgets[7];
extern int PDU_active_button;
extern int PDU_command;
extern struct PDUrefresh  *refresh; 
extern struct PDUforms forms;
extern Form PDU_form_id;
extern int PDMdebug_on;
extern short PDU_where_used_perm_window;
extern MEMptr PDU_where_used_bufr;


int where_used_notification_routine ( f_label, g_label, value, fp )
  int     f_label;       /* The label of the form   */
  int     g_label;       /* The label of the gadget */
  double  value;         /* The value of the gadget */
  Form    fp;            /* Pointer to the form     */
{
  static char   * text;
  int             length;
  int             select;
  int             pos;
  int             status = PDM_S_SUCCESS; 
  int             state;
  char          * msg = NULL;

  PDU_form_id = fp;
  FIg_set_text(fp, FI_MSG_FIELD, NULL_STRING);
  PDUmessage(PDM_E_CLEAR_FIELD, 's');

  switch ( g_label )
  {
    case FI_HELP:     /* Member of group FI_CTRL_GROUP */

	 f_label = 0;
         value = 0.0;

         _pdm_debug("converting form to permanent window", 0);
         FIf_cvrt_to_perm_win(forms.where_used_form_id);
         PDU_where_used_perm_window = TRUE;
	 status = PDUinitialize_help();
         if (status != PDM_S_SUCCESS)
           {
           PDUmessage(status, 's');
           break;
           }
         Help_topic("part_listing");
         break;

    case FI_CVT_TO_PERM_WIN:     /* Member of group FI_CTRL_GROUP */

         PDU_where_used_perm_window = TRUE;
         break;

    case FI_CANCEL:     /* Member of group FI_CTRL_GROUP */

         _pdm_debug("User selected the cancel button", 0);
         PDUmessage("PDM_E_CMD_CANCELLED", 's');

         if (PDU_where_used_displayed == TRUE)
           {
           FIf_erase ( fp );
           PDU_where_used_displayed = FALSE;
           }
         if (PDU_where_used_created == TRUE)
           {
           FIf_delete ( fp );
           PDU_where_used_created = FALSE;
           }

         if (PDU_where_used_bufr)
           {
           MEMclose(&PDU_where_used_bufr);
           PDU_where_used_bufr = NULL;
           }

         break;

    case FI_ACCEPT:     /* Member of group FI_CTRL_GROUP */

         _pdm_debug("User selected the exit and save button", 0);

         if ((refresh->rev_catalog == NULL) ||
             (strcmp(refresh->rev_catalog, "") == 0))
           {
           msg = (char *)PDUtranslate_message(PDM_I_ENTER_CATALOG);
           FIg_set_text(fp, FI_MSG_FIELD,msg);
           PDUmessage(PDM_I_ENTER_CATALOG, 's');
           FIg_set_state_off(fp, FI_ACCEPT);
           break;
           }

         if ((refresh->rev_partid == NULL) ||
             (strcmp(refresh->rev_partid, "") == 0))
           {
           msg = (char *)PDUtranslate_message(PDM_I_ENTER_PART);
           FIg_set_text(fp, FI_MSG_FIELD,msg);
           PDUmessage(PDM_I_ENTER_PART, 's');
           FIg_set_state_off(fp, FI_ACCEPT);
           break;
           }

         if ((refresh->rev_revision == NULL) ||
             (strcmp(refresh->rev_revision, "") == 0))
           {
           msg = (char *)PDUtranslate_message(PDM_I_ENTER_REVISION);
           FIg_set_text(fp, FI_MSG_FIELD,msg);
           PDUmessage(PDM_I_ENTER_REVISION, 's');
           FIg_set_state_off(fp, FI_ACCEPT);
           break;
           }

         if (PDU_where_used_bufr)
           {
           MEMclose(&PDU_where_used_bufr);
           PDU_where_used_bufr = NULL;
           }

         FIg_get_state(fp, CONTAIN_TGL, &state);
         if (state == TRUE)
           {
           /* get list of children */
           status = PDMrget_cit_children(refresh->rev_catalog, 
                        refresh->rev_partid, refresh->rev_revision, 
                        &PDU_where_used_bufr);
           _pdm_status("PDMrget_cit_children", status);
           }
         else
           {
           /* get list of parents */
           status = PDMrget_cit_parents(refresh->rev_catalog, 
                        refresh->rev_partid, refresh->rev_revision, 
                        &PDU_where_used_bufr);
           _pdm_status("PDMrget_cit_parents", status);
           }

         if (status != PDM_S_SUCCESS)
           {
           PDUmessage(status, 's');
           if (PDU_where_used_bufr)
             {
             MEMclose(&PDU_where_used_bufr);
             PDU_where_used_bufr = NULL;
             }
           }

         if (PDM_debug_on)
           MEMprint_buffer("where used", PDU_where_used_bufr, PDU_DEBUG_FILE);

         if (PDU_where_used_displayed == TRUE)
           {
           FIf_erase ( fp );
           PDU_where_used_displayed = FALSE;
           }
         if (PDU_where_used_created == TRUE)
           {
           FIf_delete ( fp );
           PDU_where_used_created = FALSE;
           }

         break;

    case CONTAIN_TGL:

         break;

    case W_PROJECT:         /* Field Type:    ASCII    */

         refresh->rev_project = NULL;

         FIfld_get_text_length(fp,W_PROJECT,0,0,&length);
         text = (char *) malloc (sizeof (char) * length + 1);
         memset(text, NULL, sizeof (char) * length + 1);
         FIfld_get_text(fp,W_PROJECT,0,0,length,(unsigned char *)text,
                        &select, &pos);

         if ((text == NULL) || (strcmp(text, "") == 0))
           {
           refresh->rev_project = NULL;
           break;
           }

         refresh->rev_filename = NULL;

         _pdm_debug("Entering W_PROJECT",0);

         status = PDUep_proj_fld();
         _pdm_status("PDUep_proj_fld",status);

         if (status == 0)
           break;

         PDUmessage(status,'s');
         break;

    case W_PROJECT_BTN:
         PDU_active_button = W_PROJECT_BTN;

         refresh->rev_filename = NULL;

         _pdm_debug("Entering LIST_W_PROJECTS",0);

         status = PDUep_proj_btn();
         _pdm_status("PDUep_proj_btn",status);

         if (status == PDM_S_SUCCESS)
            FIfld_pos_cursor(PDU_form_id,PDU_refresh_gadgets[1],0,0,0,0,1,1);

         PDUmessage(status,'s');
         break;

    case W_CATALOG: 

         refresh->rev_catalog = NULL;
         refresh->rev_partid = NULL;
         refresh->rev_revision = NULL;
         refresh->rev_description = NULL;
         refresh->rev_filename = NULL;

         FIg_set_text(fp, W_PARTID, "");
         FIg_set_text(fp, W_REVISION, "");
         FIg_set_text(fp, W_DESC, "");

         _pdm_debug("Getting the catalog name", 0);
         FIfld_get_text_length(fp,W_CATALOG,0,0,&length);
         text = (char *) malloc (sizeof (char) * length + 1);
         memset(text, NULL, sizeof (char) * length + 1);
         FIfld_get_text(fp,W_CATALOG,0,0,length,(unsigned char *)text,
                        &select, &pos);

         if ((strcmp(text, "") == 0) || (text == NULL))
           {
           refresh->rev_catalog = NULL;
           break;
           }

         _pdm_debug("Entering W_CATALOG",0);

         status = PDUep_cat_fld();
         _pdm_status("PDUep_cat_fld",status);

         if (status == 0)
           break;

         PDUmessage(status,'s');

         break;

    case W_CATALOG_BTN:
         PDU_active_button = W_CATALOG_BTN;

         refresh->rev_partid = NULL;
         refresh->rev_revision = NULL;
         refresh->rev_description = NULL;
         if (PDU_command == PDC_M_CREATE_TOP_DOWN)
           refresh->rev_filename = NULL;

         FIg_set_text(fp, W_PARTID, "");
         FIg_set_text(fp, W_REVISION, "");
         FIg_set_text(fp, W_DESC, "");

         status = PDUep_cat_btn();
         _pdm_status("PDUep_cat_btn",status);

         if (status == 0)
           break;

         PDUmessage(status,'s');

         break;

    case W_PARTID:     /* Sequenced to FIELD3    */

         refresh->rev_partid = NULL;
         refresh->rev_revision = NULL;
         refresh->rev_description = NULL;
         refresh->rev_filename = NULL;

         FIg_set_text(fp, W_REVISION, "");
         FIg_set_text(fp, W_DESC, "");

         _pdm_debug("Getting the part id", 0);
         FIfld_get_text_length(fp,W_PARTID,0,0,&length);
         text = (char *) malloc (sizeof (char) * length + 1);
         memset(text, NULL, sizeof (char) * length + 1);
         FIfld_get_text(fp,W_PARTID,0,0,length,(unsigned char *)text,
                        &select,&pos);

         if ((strcmp(text, "") == 0) || (text == NULL))
           {
           refresh->rev_partid = NULL;
           break;
           }

         _pdm_debug("Entering PARTNUM",0);

         status = PDUep_part_fld();
         _pdm_status("PDUep_part_fld",status);

         if (status == 0)
           break;

         PDUmessage(status,'s');

         break;

    case W_PARTID_BTN:
         PDU_active_button = W_PARTID_BTN;

         refresh->rev_revision = NULL;
         refresh->rev_description = NULL;
         refresh->rev_filename = NULL;

         FIg_set_text(fp, W_REVISION, "");
         FIg_set_text(fp, W_DESC, "");

         _pdm_debug("Entering LIST_PARTS",0);

         status = PDUep_part_btn();
         _pdm_status("PDUep_part_btn",status);

         if (status == 0)
            break;

         PDUmessage(status,'s');

         break;

    case W_REVISION:     /* Sequenced to FIELD4    */

         refresh->rev_revision = NULL;
         refresh->rev_description = NULL;
         refresh->rev_filename = NULL;

         FIg_set_text(fp, W_DESC, "");

         _pdm_debug("Getting the revision", 0);
         FIfld_get_text_length(fp,W_REVISION,0,0,&length);
         text = (char *) malloc (sizeof (char) * length + 1);
         memset(text, NULL, sizeof (char) * length + 1);
         FIfld_get_text(fp,W_REVISION,0,0,length,(unsigned char *)text,
                        &select,&pos);

         if ((strcmp(text, "") == 0) || (text == NULL))
           {
           refresh->rev_revision = NULL;
           break;
           }

         _pdm_debug("Entering EP_REV_FLD",0);

         status = PDUep_rev_fld();
         _pdm_status("PDUep_rev_fld",status);

         if (status == 0)
            break;

         PDUmessage(status, 's');

         break;

    case W_REVISION_BTN:
         PDU_active_button = W_REVISION_BTN;

         refresh->rev_description = NULL;
         refresh->rev_filename = NULL;

         FIg_set_text(fp, W_DESC, "");

         _pdm_debug("Entering EP_REV_BTN",0);

         status = PDUep_rev_btn();
         _pdm_status("PDUep_rev_btn",status);

         if (status == 0)
            break;

         PDUmessage(status,'s');
         break;

    case W_DESC:

         refresh->rev_description = NULL;
         _pdm_debug("Getting the description", 0);
         FIfld_get_text_length(fp,W_DESC,0,0,&length);
         text = (char *) malloc (sizeof (char) * length + 1);
         memset(text, NULL, sizeof (char) * length + 1);
         FIfld_get_text(fp,W_DESC,0,0,length,(unsigned char *)text,
                        &select,&pos);

         if ((strcmp(text, "") == 0) || (text == NULL))
           {
           refresh->rev_description = NULL;
           break;
           }

         _pdm_debug("Entering EP_W_DESC_BTN",0);

         status = PDUep_desc_fld();
         _pdm_status("PDUep_desc_fld",status);

         if (status == 0)
           break;

         PDUmessage(status,'s');

         break;

  } /* END switch ( g_label ) */


  return(status);

} /* END notification_routine() */

/* This function loads/creates, initializes, and displays the where_used form */

int PDUwhere_used_form()
{
  int  sts = PDM_S_SUCCESS;

  if (PDU_where_used_displayed == TRUE)
    return(sts);

  _pdm_debug("preprocessing PDUwhere_used_form", 0);

  PDU_where_used_created = FALSE;
  PDU_where_used_displayed = FALSE;

  _pdm_debug("Creating where_used form", 0);
  sts = FIf_new(WHERE_USED_FORM, "where_used", where_used_notification_routine,
                &forms.where_used_form_id);
  PDU_where_used_created = TRUE;

  /* initialize refresh gadgets */
  PDU_refresh_gadgets[0] = W_PROJECT;
  PDU_refresh_gadgets[1] = W_CATALOG;
  PDU_refresh_gadgets[2] = W_PARTID;
  PDU_refresh_gadgets[3] = W_REVISION;
  PDU_refresh_gadgets[5] = W_DESC;

  if (PDMdebug_on)
    {
    _pdm_debug("converting form to permanent window", 0);
    FIf_cvrt_to_perm_win(forms.where_used_form_id);
    PDU_where_used_perm_window = TRUE;
    }

  if ((refresh->rev_catalog) && (strcmp(refresh->rev_catalog, "") != 0))
    {
    FIg_set_text(forms.where_used_form_id, W_CATALOG, refresh->rev_catalog);
    FIfld_pos_cursor(forms.where_used_form_id, W_PARTID, 0,0,0,0,1,1);
    }
  else
    FIfld_pos_cursor(forms.where_used_form_id, W_CATALOG, 0,0,0,0,1,1);

  _pdm_debug("Displaying the where_used form", 0);
  sts = FIf_display(forms.where_used_form_id);
  PDU_where_used_displayed = TRUE;

  return(sts); 
}
