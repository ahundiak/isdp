#include <stdio.h>
#include "FI.h"
#include "PDUform_def.h"
#include "PDUforms.h"
#include "PDUstr.h"
#include "MEMstruct.h"
#include "MEMerrordef.h"
#include "PDUerror.h"
#include "PDUfile_def.h"
#include "PDUproto.h"


/* Gadgets */

#define PART_MCF          16

/* Gadgets from TOPDOWN form */
#define TD_CATALOG       34
#define TD_PARTID        35
#define TD_REVISION      36
#define TD_FILENAME      37
#define TD_DESC          12


/* Externs */

extern char * calloc();
extern char * realloc();
extern int FImcf_get_active_col();
extern int FIg_get_text_length();
extern int FIfld_get_text();
extern char    *PDU_assy_catalog;
extern char    *PDU_assy_partid;
extern char    *PDU_assy_revision;
extern char    *PDU_assy_description;
extern short   PDU_parts_list_displayed;
extern short   PDU_parts_list_created;
extern Form    PDU_form_id;
extern MEMptr  PDU_ret_bufr;
extern MEMptr  PDU_parts_list_buffer;
extern struct  PDUrefresh *refresh;
extern struct  PDUforms forms;
extern char    ***PDU_update_struct;
extern int     *PDU_gadget_labels;


int parts_list_notification_routine ( f_label, g_label, value, fp )
  int     f_label;       /* The label of the form   */
  int     g_label;       /* The label of the gadget */
  double  value;         /* The value of the gadget */
  Form    fp;            /* Pointer to the form     */
{
  int             length;
  int             select;
  int             pos;
  int             status = PDM_S_SUCCESS;
  int             no_headings;
  int             all_flag = FALSE;
  int             column;
  int             act_row, act_pos;
  int             mcf_select = FALSE;
  char            **headings;
  char            *msg = NULL;
  static char     *text;

  switch ( g_label )
  {
    case PART_MCF:     /* Sequenced to     */

         FIfld_get_active_row(fp, PART_MCF, &act_row, &act_pos);
         FImcf_set_active_col(fp, PART_MCF, 0, 0);
         FIfld_get_select(fp, PART_MCF, act_row, 0, &mcf_select);

         if (mcf_select == TRUE)
           {
           /* loop through columns in mcf to get data selected */
           for (column = 0; column < 4; ++column)
              {
              FImcf_set_active_col( fp, PART_MCF, column, column);
              FIfld_get_text_length(fp,PART_MCF,act_row,column,&length);
              text = (char *) malloc (sizeof (char) * length + 1);
              memset(text, NULL, sizeof (char) * length + 1);
              FIfld_get_text(fp,PART_MCF,act_row,column,length,
                            (unsigned char *)text,&select, &pos);

              /* update the structure */
              switch (column)
                {
                case 0:
                     PDUfill_in_string(&PDU_assy_catalog, text);
                     _pdm_debug("catalog = <%s>", PDU_assy_catalog);
                     break;
                case 1:
                     PDUfill_in_string(&PDU_assy_partid, text);
                     _pdm_debug("part num = <%s>", PDU_assy_partid);
                     break;
                case 2:
                     PDUfill_in_string(&PDU_assy_revision, text);
                     _pdm_debug("revision = <%s>", PDU_assy_revision);
                     break;
                case 3:
                     PDUfill_in_string(&PDU_assy_description,text);
                     _pdm_debug("description = <%s>", PDU_assy_description);
                     break;
                }
              }  /* end for column */
           }  /* end if select */
         else
           {
           PDU_assy_catalog = NULL;
           PDU_assy_partid = NULL;
           PDU_assy_revision = NULL;
           PDU_assy_description = NULL_STRING;
           }

         break;

    case FI_HELP:     /* Member of group FI_CTRL_GROUP */

	 f_label = 0;
	 value = 0.0;

         status = PDUinitialize_help();
         if (status != PDM_S_SUCCESS)
           {
           PDUmessage(status, 's');
           break;
           }
         Help_topic("part_listing");
         break;

    case FI_CANCEL:     /* Member of group FI_CTRL_GROUP */

          /* Erase the displayed form */
         _pdm_debug("form was cancelled", 0);

         if (PDU_parts_list_displayed == TRUE)
           {
           FIf_erase ( fp );
           PDU_parts_list_displayed = FALSE;
           }
         if (PDU_parts_list_created == TRUE)
           {
           FIf_delete ( fp );
           PDU_parts_list_created = FALSE;
           }

         PDU_assy_catalog = NULL;
         PDU_assy_partid = NULL;
         PDU_assy_revision = NULL;
         PDU_assy_description = NULL_STRING;

         FIf_display(PDU_form_id);

         break;

    case FI_ACCEPT:     /* Member of group FI_CTRL_GROUP */

         _pdm_debug("checking to see if a part is selected", 0);
         if ((PDU_assy_catalog == NULL) ||
             (PDU_assy_partid == NULL) ||
             (PDU_assy_revision == NULL))
           {
           msg = (char *)PDUtranslate_message(PDM_E_NO_PARTS_SELECTED);
           FIg_set_text(fp, FI_MSG_FIELD, msg);
           FIg_set_state_off(fp, FI_ACCEPT);
           break;
           }

          /* Erase the displayed form */

         if (PDU_parts_list_displayed == TRUE)
           {
           FIf_erase ( fp );
           PDU_parts_list_displayed = FALSE;
           }

          PDUfill_in_string(&refresh->rev_catalog, PDU_assy_catalog);
          PDUfill_in_string(&refresh->rev_partid, PDU_assy_partid);
          PDUfill_in_string(&refresh->rev_revision, PDU_assy_revision);
          PDUfill_in_string(&refresh->rev_description, PDU_assy_description);

          /* Process form data */
          FIg_set_text( PDU_form_id, TD_CATALOG, PDU_assy_catalog);
          FIg_set_text( PDU_form_id, TD_PARTID, PDU_assy_partid);
          FIg_set_text( PDU_form_id, TD_REVISION, PDU_assy_revision);
          FIg_set_text( PDU_form_id, TD_DESC, PDU_assy_description);

          PDU_assy_catalog = NULL;
          PDU_assy_partid = NULL;
          PDU_assy_revision = NULL;
          PDU_assy_description = NULL_STRING;

          if (PDU_parts_list_created == TRUE)
            {
            FIf_delete ( fp );
            PDU_parts_list_created = FALSE;
            }

          FIf_display(PDU_form_id);

          _pdm_debug("calling function to get filenames", 0);
          if ((refresh->rev_catalog && 
               refresh->rev_partid &&
               refresh->rev_revision &&
               (strcmp(refresh->rev_catalog, "") != 0) &&
               (strcmp(refresh->rev_partid, "") != 0) &&
               (strcmp(refresh->rev_revision, "") != 0)))
            {
            if (PDU_ret_bufr)
              {
              MEMclose(&PDU_ret_bufr);
              PDU_ret_bufr = NULL;
              }
            status = PDMget_filenames(refresh->rev_catalog,refresh->rev_partid,
                         refresh->rev_revision, &PDU_ret_bufr);
            _pdm_status("PDMget_filenames", status);

            if ( status != PDM_S_SUCCESS )
              {
              msg = (char *)PDUtranslate_message(status);
              FIg_set_text(PDU_form_id,FI_MSG_FIELD,msg);
              MEMclose(&PDU_ret_bufr);
              break;
              }

            if ((PDU_ret_bufr == NULL) && (PDU_ret_bufr->rows))
              {
              msg = (char *)PDUtranslate_message(PDM_E_NO_PART_FILES);
              FIg_set_text(PDU_form_id, FI_MSG_FIELD,msg);
              break;
              }
   
            PDUsetup_single_buffer(PDU_ret_bufr);
            PDU_gadget_labels[0] = TD_FILENAME;
            PDU_update_struct[0] = &refresh->rev_filename;
   
            all_flag = FALSE;
            no_headings = 1;
            headings = (char **) malloc (sizeof (char *) * no_headings);
            memset(headings, NULL, sizeof (char *) * no_headings);
   
            PDUfill_in_string(&headings[0], "n_cofilename");
   
            PDUsetup_popup_list(headings, no_headings, all_flag, PDU_ret_bufr);
            PDUsetup_form_fields(headings, no_headings, all_flag, PDU_ret_bufr);
            PDUsetup_struct_fields(headings, no_headings, all_flag, PDU_ret_bufr);

            PDUfree_string_array(&headings, no_headings);

            status = PDUsingle_list_form();

            }

         break;

  } /* END switch ( g_label ) */

  return(status);

} /* END notification_routine() */

int PDUparts_list_form()
{
  int  sts = PDM_S_SUCCESS;

  if (PDU_parts_list_created == TRUE)
    return(PDM_S_SUCCESS);

  PDU_parts_list_created = FALSE;
  PDU_parts_list_displayed = FALSE;

  PDU_assy_catalog = NULL;
  PDU_assy_partid = NULL;
  PDU_assy_revision = NULL;
  PDU_assy_description = NULL_STRING;

  sts = FIf_new(PARTS_LIST_FORM, "parts_list",
                parts_list_notification_routine,
                &forms.parts_list_form_id);

  _pdm_debug("Creating parts_list form", 0);
  PDU_parts_list_created = TRUE;

  return(PDM_S_SUCCESS);
}
