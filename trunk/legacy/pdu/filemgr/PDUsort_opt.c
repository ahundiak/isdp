#include <stdio.h>
#include "FI.h"
#include "tools.h"
#include "PDUerror.h"
#include <PDUforms.h>
#include "PDMtypes.h"
#include "PDUfile_def.h"
#include <PDUform_def.h>
#include "PDUintdef.h"
#include "PDUextdef.h"
#include "MEMstruct.h"
#include "MEMerrordef.h"
#include "PDUproto.h"
#include "PDMproto.h"


/* Gadgets */

#define PART                        15
#define PART_BTN                    17
#define PART_BTN_ASSOC_FLD          20
#define SAVE_TITLE                  11
#define READ_IN_TITLE               18
#define PART_TEXT                   13

/* Other Gadgets */
#define PART_SORT                16
#define PART_SORT2               33
#define PART_SORT3               34
#define PART_SORT4               35
#define PART_SORT5               36
#define PART_SORT2_LIST_BTN      45
#define PART_SORT3_LIST_BTN      46
#define PART_SORT4_LIST_BTN      47
#define PART_SORT5_LIST_BTN      48


/* Externs */

extern char * calloc();
extern char * realloc();
extern int FIg_get_text_length();
extern int FIg_get_text();
extern MEMptr  PDU_ret_bufr;
extern struct  PDUforms forms;
extern short   PDU_save_sort_mode;
extern short   PDU_search_all_catalogs;
extern short   PDU_sort_opt_perm_window;
extern int     PDU_sort_options_displayed;
extern int     PDU_sort_options_created;
extern int     PDU_part_sort_pulldown;
extern int     PDU_part_search_flag;
extern int     PDU_search_type;
extern int     PDU_part_sort_rows;
extern int     PDU_num_of_cat_rows;
extern int     PDU_num_of_part_rows;
extern int     PDU_prev_part_sort;
extern int     PDU_part_displayed;
extern int     AttrList_size;
extern char   *PDU_part_sort_conds;
extern char   **PDU_part_sort_list;
extern char  **PDU_part_sort_attr;
extern char  **AttrList;
extern char  **AttrSynonym;


int sort_options_notification_routine ( f_label, g_label, value, fp )
  int     f_label;       /* The label of the form   */
  int     g_label;       /* The label of the gadget */
  double  value;         /* The value of the gadget */
  Form    fp;            /* Pointer to the form     */
{
  static char   * text;
  int             status = PDM_S_SUCCESS;
  int             row;
  int             list_row;
  int             sort_length;
  int             select, pos, length;
  int             act_row;
  int             index;
  char            *sort_string = NULL;
  char            *sort_name = NULL;
  char            *string = NULL;
  char            **data_row;
  char            add_mod[2];
  char            sort_type[2];
  char            *msg = NULL;
  MEMptr          ret_bufr = NULL;

  FIg_set_text(fp, FI_MSG_FIELD, NULL_STRING);
  FIg_set_text(fp, FI_PROMPT_FIELD, NULL_STRING);
  fp = forms.sort_options_form_id;

  switch ( g_label )
  {
    case FI_HELP:     /* Member of group FI_CTRL_GROUP */

	 f_label = 0;

         if (PDU_sort_opt_perm_window == FALSE)
           {
           FIf_cvrt_to_perm_win(forms.sort_options_form_id);
           PDU_sort_opt_perm_window = TRUE;
           }
         status = PDUinitialize_help();
         if (status != PDM_S_SUCCESS)
           {
           PDUmessage(status, 's');
           break;
           }
         Help_topic("sort_options");
         break;


    case FI_CANCEL:     /* Member of group FI_CTRL_GROUP */

         if (PDU_sort_options_displayed == TRUE)
           {
           FIf_erase ( fp );
           PDU_sort_options_displayed = FALSE;
           }
         if (PDU_sort_options_created == TRUE)
           {
           FIf_delete(fp);
           PDU_sort_options_created = FALSE;
           }

         if (PDU_save_sort_mode == FALSE)
           GRdelete_pull_down_list(PDU_part_sort_pulldown);

         FIf_display(forms.sort_form_id);

         break;

    case FI_ACCEPT:     /* Member of group FI_CTRL_GROUP */

         PDUmessage(PDM_E_CLEAR_FIELD, 's');

         /* check the part field */
         _pdm_debug("a part condition name is required", 0);
         FIfld_get_text_length(fp, PART, 0, 0, &length);
         text = (char *) malloc (sizeof (char) * length + 1);
         memset(text, NULL, sizeof (char) * length + 1);
         FIfld_get_text(fp, PART, 0, 0, length, (unsigned char *)text, 
                        &select, &pos);
         if ((text == NULL) || (strcmp(text, "") == 0))
           {
           FIg_set_state_off(fp, FI_ACCEPT);
           FIfld_pos_cursor(fp, PART, 0,0,0,0,1,1);
           msg = (char *)PDUtranslate_message(PDM_E_ENTER_SORT_NAME);
           FIg_set_text(fp, FI_MSG_FIELD,msg);
           break;
           }

         /* save part sort conditions */
         if (PDU_save_sort_mode == TRUE)
           {
           _pdm_debug("saving part sort conditions", 0);
         FIfld_get_text_length(fp,PART,0,0,&length);
         text = (char *) malloc (sizeof (char) * length + 1);
         memset(text, NULL, sizeof (char) * length + 1);
         FIfld_get_text(fp,PART,0,0,length,(unsigned char *)text,
                        &select,&pos);

           PDUfill_in_string(&sort_name, text);
           _pdm_debug("part sort name = <%s>", sort_name);
           PDUfree_string(&text);

           if ((sort_name != NULL) && (strcmp(sort_name, "") != 0))
             {
	     /* calculate the length of the sort criteria string */
             sort_length = 1;
             row = 0;

             for (index = 0; index < PDU_num_of_part_rows; ++index)
                {
                row = 0;
                while ((PDU_part_sort_attr[index]) &&
                       (AttrSynonym[row]) && 
                       (strcmp(PDU_part_sort_attr[index],
                        AttrSynonym[row]) != 0))
                   ++row;
 
                sort_length = sort_length + strlen(AttrList[row]);
                sort_length = sort_length + 2;
                _pdm_debug("AttrList[row] = <%s>", AttrList[row]);
                }

             _pdm_debug("sort_length = %d", (char *)sort_length);
 
             /* concatenate the attributes together seperated by commas */
             sort_string = (char *) malloc (sort_length + 1);
             memset(sort_string, NULL, (sort_length + 1));
 
             strcpy(sort_string, " ");
 
             for (index = 0; index < PDU_num_of_part_rows; ++index)
                {
                row = 0;
                if (index != 0)
                  strcat(sort_string, ", ");
 
                while ((PDU_part_sort_attr[index]) &&
                       (AttrSynonym[row]) && 
                       (strcmp(PDU_part_sort_attr[index],
                        AttrSynonym[row]) != 0))
                   ++row;
 
                strcat(sort_string, AttrList[row]);
                _pdm_debug("AttrList[row] = <%s>", AttrList[row]);
                }

             _pdm_debug("Sort Criteria string = <%s>", sort_string);

             strcpy(sort_type, "C");

             /* Determine if the sort conditions are to be added or
                modified */
             status = PDUlist_report_buffer(CAT_SORT_LIST, &ret_bufr);
             _pdm_status("PDUlist_report_buffer", status);
  
             if (status != PDM_S_SUCCESS)
               {
               _pdm_debug("error retrieving report names", 0);
               status = PDM_E_ATTR_NOT_FOUND;
               FIg_set_state_off(fp, FI_ACCEPT);
               PDUmessage(status, 's');
               break;
               }
  
             if ((ret_bufr == NULL) || (ret_bufr->rows < 1))
               strcpy(add_mod, "A");
             else
               {
               strcpy(add_mod, "A");
               MEMbuild_array(ret_bufr);
               PDUsetup_buffer(ret_bufr, ROW, &data_row);

               /* copy the buffer to a list */
               for (row = 0; row < ret_bufr->rows; ++row)
                  {
                  if (strcmp(data_row[(ret_bufr->columns * row) + 0],
                      sort_name) == 0)
                  strcpy(add_mod, "M");
                  }
               }
  
             _pdm_debug("sort string = <%s>", sort_string);
             _pdm_debug("sort name = <%s>", sort_name);
             _pdm_debug("add_mod = <%s>", add_mod);
             status = PDUdefine_criteria_string("O",sort_type,
                              sort_name, sort_string, add_mod);
             _pdm_status("PDUdefine_criteria_string", status);

             if (status != PDM_S_SUCCESS)
               {
               _pdm_debug("error defining sort conditions", 0);
               FIg_set_state_off(fp, FI_ACCEPT);
               PDUmessage(status, 's');
               break;
               }

             PDUfill_in_string(&PDU_part_sort_conds,sort_name);
             _pdm_debug("Part sort name = <%s>", PDU_part_sort_conds);

             PDUfree_string(&sort_string);
             }
           sort_name = NULL;
           }
         else  /* retrieve sort conditions */
           {
           PDUmessage(PDM_E_CLEAR_FIELD, 's');

           if ((PDU_part_sort_conds == NULL) ||
               (strcmp(PDU_part_sort_conds, "") == 0))
             {
             FIg_set_state_off(fp, FI_ACCEPT);
             msg = (char *)PDUtranslate_message(PDM_E_ENTER_SORT_NAME);
             FIg_set_text(fp, FI_MSG_FIELD,msg);
             FIfld_pos_cursor(fp, PART, 0,0,0,0,1,1);
             break;
             }

           /* display part sort conditions in sort fields */
           status = PDUdisplay_part_sort_conditions();
           _pdm_status("PDUdisplay_part_sort_conditions", status);

           if (status != PDM_S_SUCCESS)
             {
             FIg_set_state_off(fp, FI_ACCEPT);
             break;
             }

           PDUmessage(status, 's');
           }

         if (PDU_sort_options_displayed == TRUE)
           {
           FIf_erase ( fp );
           PDU_sort_options_displayed = FALSE;
           }
         if (PDU_sort_options_created == TRUE)
           {
           FIf_delete(fp);
           PDU_sort_options_created = FALSE;
           }

         if (PDU_save_sort_mode == FALSE)
           GRdelete_pull_down_list(PDU_part_sort_pulldown);

         FIf_display(forms.sort_form_id);
         PDUmessage(status, 's');

         break;

    case PART:         /* Field Type:    ASCII    */

         _pdm_debug("getting the part", 0);
         FIfld_get_active_row(fp, PART, &act_row, &act_row);
         FIfld_get_text_length(fp, PART, act_row, 0, &length);
         text = (char *) malloc (sizeof (char) * length + 1);
         memset(text, NULL, sizeof (char) * length + 1);
         FIfld_get_text(fp, PART, act_row, 0, length, (unsigned char *)text, 
                        &select, &pos);
         if ((text == NULL) || (strcmp(text, "") == 0))
           break;

	 /* check value for spaces */
         status = PDUvalidate_criteria(fp, text);
         _pdm_status("PDUvalidate_criteria", status);

         if (status != PDM_S_SUCCESS)
           {
           PDUmessage(status, 's');
           break;
           }

         if (PDU_save_sort_mode == FALSE)
           {
           /* erase any fields that might already be displayed */
           PDUreset_part_sort_fields();

           _pdm_debug("processing part condition name for loading", 0);

           /* validate the part sort string */
           status = PDMvalidate_criteria_name(text, "O", "C");
           _pdm_status("PDMvalidate_criteria_name", status);

           if (status != PDM_S_SUCCESS)
             {
             _pdm_debug("User specified non-existant part sort criteria", 0);
             FIfld_set_text(fp, PART, 0, 0, "", FALSE);
             FIfld_pos_cursor(fp, PART, 0,0,0,0,1,1);
             PDUmessage(status, 's');
             }

           PDUfill_in_string(&PDU_part_sort_conds, text);
           }
         break;

    case PART_BTN:

         /* reset the part sort fields */
         PDUreset_part_sort_fields();

         /* retrieve a list of defined part sort criteria */
         if (PDU_ret_bufr != NULL)
           {
           MEMclose(&PDU_ret_bufr);
           PDU_ret_bufr = NULL;
           }
         status = PDUlist_report_buffer(CAT_SORT_LIST, &PDU_ret_bufr);
         _pdm_status("PDUlist_report_buffer", status);

         if (status == PDM_E_INVALID_TYPE)
           {
           _pdm_debug("invalid report type", 0);
           FIg_set_state_off(fp, PART_BTN);
           break;
           }

         if (PDU_ret_bufr == NULL)
           {
           msg = (char *)PDUtranslate_message(PDM_E_NO_CRITERIA_DEFINED);
           FIg_set_text(forms.sort_options_form_id, FI_MSG_FIELD,msg);
           FIg_set_state_off(fp, PART_BTN);
           break;
           }

         MEMbuild_array(PDU_ret_bufr);
         PDUsetup_buffer(PDU_ret_bufr, ROW, &data_row);

         /* if the return buffer only has one row, default it */
         if (PDU_ret_bufr->rows == 1)
           {
            PDUfill_in_string(&string,
                              data_row[(PDU_ret_bufr->columns * 0) + 0]);
            if ((string != NULL) && (strcmp(string, "") != 0))
              {
              FIfld_set_text(fp, PART, 0, 0, string, FALSE);
              PDUfill_in_string(&PDU_part_sort_conds, string);
              PDUmessage(status, 's');
              }
           FIg_set_state_off(fp, PART_BTN);
           break;
           }

         PDU_part_sort_rows = PDU_ret_bufr->rows;
         PDU_part_sort_list = (char **)malloc(sizeof(char*)*PDU_part_sort_rows);
         memset(PDU_part_sort_list, NULL, sizeof (char *) * PDU_part_sort_rows);

         /* copy the buffer to a list */
         for (row = 0; row < PDU_ret_bufr->rows; ++row)
            {
            PDUfill_in_string(&PDU_part_sort_list[row],
                       data_row[(PDU_ret_bufr->columns * row) + 0]);
            }

         FIg_set_state_off(fp, PART_BTN);

         /* put the values in the pull down list */
          GRchange_pull_down_text(PDU_part_sort_pulldown, PDU_part_sort_list,
                                      PDU_part_sort_rows);

         /* display the pulldown list */
         GRproc_pull_down_list(PDU_part_sort_pulldown);

         PDU_prev_part_sort = TRUE;
         PDU_part_displayed = TRUE;
         break;

    case PART_BTN_ASSOC_FLD:

         FIg_set_state_off(fp, PART_BTN);

         list_row = value - 1;
         FIfld_set_text(fp, PART, 0, 0, PDU_part_sort_list[list_row], FALSE);
         PDUfill_in_string(&PDU_part_sort_conds, PDU_part_sort_list[list_row]);

         PDUmessage(status, 's');

         /* clean out list */
         PDUfree_string_array(&PDU_part_sort_list, PDU_ret_bufr->rows);
         MEMclose(&PDU_ret_bufr);
         PDU_ret_bufr = NULL;

         break;


  } /* END switch ( g_label ) */

  return(status);

} /* END notification_routine() */

int PDUsort_options_form()
{
  int  sts = PDM_S_SUCCESS;
  int  list_size;

  if (PDU_sort_options_created == TRUE)
    return(PDM_S_SUCCESS);

  PDU_part_sort_conds = NULL;
  if (PDU_ret_bufr)
    {
    MEMclose(&PDU_ret_bufr);
    PDU_ret_bufr = NULL;
    }

  PDU_sort_options_created = FALSE;
  PDU_sort_options_displayed = FALSE;

  sts = FIf_new(SORT_OPTIONS_FORM, "sort_options",
                sort_options_notification_routine,
                &forms.sort_options_form_id);

  _pdm_debug("Creating sort_options form", 0);
  PDU_sort_options_created = TRUE;

  if (PDU_save_sort_mode == FALSE)
    {
    list_size = 0;
    /* Create pull down list for part sort list button */
    PDU_part_sort_list = (char **)malloc(sizeof(char*)*1);
    memset(PDU_part_sort_list, NULL, sizeof (char *) * 1);
    GRcreate_pull_down_list(SORT_OPTIONS_FORM, forms.sort_options_form_id, 
                            PART_BTN_ASSOC_FLD, MAX_ROWS, VIS_ROWS,
                            PDU_part_sort_list, list_size, 1,
                            &PDU_part_sort_pulldown);
    PDUfree_string_array(&PDU_part_sort_list, 1);

    }

  /* display form title */
  if (PDU_save_sort_mode == FALSE)
    {
    FIg_display(forms.sort_options_form_id, SAVE_TITLE);
    }
  else
    {
    FIg_display(forms.sort_options_form_id, READ_IN_TITLE);
    FIg_erase(forms.sort_options_form_id, SAVE_TITLE);
    FIg_erase(forms.sort_options_form_id, PART_BTN);
    }

  /* Display the sort options form and set the displayed flag to TRUE. */
  _pdm_debug("Displaying the sort options form", 0);

  sts = FIf_display(forms.sort_options_form_id);
  PDU_sort_options_displayed = TRUE;

  return(PDM_S_SUCCESS);
}

int PDUreset_part_sort_fields()
{
 /* erase any fields that might already be displayed */
 FIg_erase(forms.sort_form_id, PART_SORT2);
 FIg_erase(forms.sort_form_id, PART_SORT3);
 FIg_erase(forms.sort_form_id, PART_SORT4);
 FIg_erase(forms.sort_form_id, PART_SORT5);
 FIg_erase(forms.sort_form_id, PART_SORT2_LIST_BTN);
 FIg_erase(forms.sort_form_id, PART_SORT3_LIST_BTN);
 FIg_erase(forms.sort_form_id, PART_SORT4_LIST_BTN);
 FIg_erase(forms.sort_form_id, PART_SORT5_LIST_BTN);
 FIfld_set_text(forms.sort_form_id, PART_SORT, 0, 0, "", FALSE);
 FIfld_set_text(forms.sort_form_id, PART_SORT2, 0, 0, "", FALSE);
 FIfld_set_text(forms.sort_form_id, PART_SORT3, 0, 0, "", FALSE);
 FIfld_set_text(forms.sort_form_id, PART_SORT4, 0, 0, "", FALSE);
 FIfld_set_text(forms.sort_form_id, PART_SORT5, 0, 0, "", FALSE);
 return(PDM_S_SUCCESS);
}
