#include <stdio.h>
#include "FI.h"
#include "tools.h"
#include "PDUstr.h"
#include "PDUerror.h"
#include "PDUforms.h"
#include "PDUintdef.h"
#include "PDUform_def.h"
#include "PDUfile_def.h"
#include "PDMtypes.h"
#include "MEMstruct.h"
#include "MEMerrordef.h"
#include "PDUproto.h"

/* Gadgets */

#define PART_SORT                16
#define PART_SORT2               33
#define PART_SORT3               34
#define PART_SORT4               35
#define PART_SORT5               36
#define PART_SORT_LIST_BTN       44
#define PART_SORT2_LIST_BTN      45
#define PART_SORT3_LIST_BTN      46
#define PART_SORT4_LIST_BTN      47
#define PART_SORT5_LIST_BTN      48
#define LOAD_BTN                 49
#define SAVE_BTN                 13
#define PART_ATTR_ASSOC_FLD      52

/* Externs */

extern char *    calloc();
extern char *    realloc();
extern char *    PDU_part_sort_conds;
extern char **   PDU_part_sort_attr;
extern char **   PDU_data_row;
extern char **   AttrList;
extern char **   AttrSynonym;
extern char    * PDU_part_sort_string;
extern int       PDU_prev_part_sort;
extern int       FIg_get_text_length();
extern int       FIg_get_text();
extern int       FIg_get_text_length();
extern int       FIg_get_type();
extern int       PDU_sort_created;
extern int       PDU_sort_displayed;
extern int       PDU_part_attr_pulldown;
extern int       PDU_part_displayed;
extern int       NumAttribs;
extern struct    PDUforms   forms;
extern MEMptr    PDU_ret_bufr;
extern struct PDUrefresh   *refresh;
extern short     PDU_save_sort_mode;
extern short     PDU_sort_perm_window;

/* Global and static variables */

extern  int             PDU_num_of_part_rows;
extern  int             PDU_part_row;


int sort_notification_routine ( f_label, g_label, value, fp )
  int     f_label;       /* The label of the form   */
  int     g_label;       /* The label of the gadget */
  double  value;         /* The value of the gadget */
  Form    fp;            /* Pointer to the form     */
{
  int             status = PDM_S_SUCCESS;
  int             list_row;
  int             row;
  int             sort_length;
  int             length;
  int             found = FALSE;
  int		  index;
  char          * sort_string = NULL;
  char          * msg = NULL;
 
  FIg_set_text(fp, FI_MSG_FIELD, NULL_STRING);
  FIg_set_text(fp, FI_PROMPT_FIELD, NULL_STRING);
  PDUmessage(PDM_E_CLEAR_FIELD, 's');

  switch ( g_label )
  {
    case FI_HELP:     /* Member of group FI_CTRL_GROUP */

         f_label = 0;
         value = 0.0;

         _pdm_debug ("User selected the HELP button", 0);
         if (PDU_sort_perm_window == FALSE)
           {
           FIf_cvrt_to_perm_win(forms.sort_form_id);
           PDU_sort_perm_window = TRUE;
           }
         status = PDUinitialize_help();
         if (status != PDM_S_SUCCESS)
           {
           PDUmessage(status, 's');
           break;
           }
         Help_topic("sort");
         break;

    case FI_CANCEL:     /* Member of group FI_CTRL_GROUP */

          /* Erase the displayed form */

         _pdm_debug("User selected the cancel button", 0);
         refresh->status = PDM_I_FORM_CANCEL;

         if (PDU_sort_displayed == TRUE)
           FIf_erase( fp );
         if (PDU_sort_created == TRUE)
           FIf_delete( fp );
 
         GRdelete_pull_down_list(PDU_part_attr_pulldown);

         _pdm_debug("freeing AttrList and AttrSynonym", 0);
         PDUfree_string_array(&PDU_part_sort_attr, 5);
         PDUfree_string(&PDU_part_sort_string);
         PDU_part_sort_string = NULL;

         break;

    case FI_RESET:     /* Member of group FI_CTRL_GROUP */

         PDU_prev_part_sort = FALSE;
         PDU_part_sort_attr = NULL;
         PDU_part_displayed = FALSE;
       
         PDU_part_sort_string = NULL;
         PDU_part_sort_conds = NULL;

         _pdm_debug("freeing PDU_part_sort_attr", 0);
         PDUfree_string_array(&PDU_part_sort_attr, 5);
         PDU_part_sort_attr = (char **) malloc (sizeof (char *) * 5);
         memset(PDU_part_sort_attr, NULL, sizeof (char *) * 5);

	 break;

    case FI_ACCEPT:     /* Member of group FI_CTRL_GROUP */

          _pdm_debug("User selected the exit & save button", 0);

          if (PDU_part_sort_attr[0] == NULL)
            {
            FIg_set_state_off(fp, FI_ACCEPT);
            msg = (char *)PDUtranslate_message(PDM_E_NO_CRITERIA_DEFINED);
            FIg_set_text(fp, FI_MSG_FIELD, msg);
            break;
            }

          /* process the part sort conditions */
          if (PDU_part_displayed == TRUE)
            {
            /* calculate the length of the sort criteria string */
            sort_length = 1;
            row = 0;

            _pdm_debug("number of rows selected = %d", 
                       (char *)PDU_num_of_part_rows);
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
               _pdm_debug("AttrList[row] = <%s>", (char *)AttrList[row]);
               }
            _pdm_debug("sort length = %d", (char *)sort_length);

            /* concatenate the attributes together seperated by commas */
            _pdm_debug("mallocing space for sort string", 0);
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

            length = strlen(sort_string) + 15;
            PDU_part_sort_string = (char *) malloc (sizeof (char) * length);
            memset(PDU_part_sort_string, NULL, sizeof (char) * length);

            strcpy(PDU_part_sort_string, "order by");
            strcat(PDU_part_sort_string, sort_string);
            _pdm_debug("Part sort string = <%s>", PDU_part_sort_string);

            if (sort_string)
              free(sort_string);
            } /* end_if */

         if (PDU_sort_displayed == TRUE)
           FIf_erase( fp );
         if (PDU_sort_created == TRUE)
           FIf_delete( fp );

         GRdelete_pull_down_list(PDU_part_attr_pulldown);

         _pdm_debug("freeing PDU_part_sort_attr", 0);
         for (index = 0; index < 5; ++index)
            if (PDU_part_sort_attr[index])
              free(PDU_part_sort_attr[index]);

          break;

    case PART_SORT_LIST_BTN:

         PDU_part_row = 0;
         /* set the number of rows that have been defined */
         if (PDU_num_of_part_rows <= (PDU_part_row))
           PDU_num_of_part_rows = PDU_part_row + 1;

         FIg_set_state_off(fp, PART_SORT_LIST_BTN);

         /* put the values in the pull down list */
/*
          GRchange_pull_down_text(PDU_part_attr_pulldown, AttrSynonym,
                                  NumAttribs);
*/

         /* display the pulldown list */
         GRproc_pull_down_list(PDU_part_attr_pulldown);
         
         break;

    case PART_ATTR_ASSOC_FLD:
         list_row = value - 1;

         _pdm_debug("checking for attributes already in list", 0);
         for (row = 0; row < 5; ++row)
            {
            if ((PDU_part_sort_attr[row]) && (strcmp(PDU_part_sort_attr[row], 
                 AttrSynonym[list_row]) == 0))
              {
              found = TRUE;
              msg = (char *)PDUtranslate_message(PDM_E_ATTR_IN_SORT_LIST);
              FIg_set_text(fp, FI_MSG_FIELD, msg);
              break;
              }
            }
         if (found == TRUE)
           {
          if ((PDU_num_of_part_rows - 1) <= (PDU_part_row))
            PDU_num_of_part_rows = PDU_num_of_part_rows - 1;
           break;
           }

         _pdm_debug("filling in form field", 0);
         _pdm_debug("list_row = %d", (char *)list_row);
         switch (PDU_part_row)
          {
            case 0:
                 FIg_set_text(fp, PART_SORT,AttrSynonym[list_row]);
                 PDUfill_in_string(&PDU_part_sort_attr[PDU_part_row],
                                   AttrSynonym[list_row]);
                 FIg_display(forms.sort_form_id, PART_SORT2);
                 FIg_display(forms.sort_form_id, PART_SORT2_LIST_BTN);
                 break;

            case 1:
                 FIg_set_text(fp, PART_SORT2, AttrSynonym[list_row]);
                 PDUfill_in_string(&PDU_part_sort_attr[PDU_part_row],
                                   AttrSynonym[list_row]);
                 FIg_display(forms.sort_form_id, PART_SORT3);
                 FIg_display(forms.sort_form_id, PART_SORT3_LIST_BTN);
                 break;

            case 2:
                 FIg_set_text(fp, PART_SORT3,AttrSynonym[list_row]);
                 PDUfill_in_string(&PDU_part_sort_attr[PDU_part_row],
                                   AttrSynonym[list_row]);
                 FIg_display(forms.sort_form_id, PART_SORT4);
                 FIg_display(forms.sort_form_id, PART_SORT4_LIST_BTN);
                 break;

            case 3:
                 FIg_set_text(fp, PART_SORT4,AttrSynonym[list_row]);
                 PDUfill_in_string(&PDU_part_sort_attr[PDU_part_row],
                                   AttrSynonym[list_row]);
                 FIg_display(forms.sort_form_id, PART_SORT5);
                 FIg_display(forms.sort_form_id, PART_SORT5_LIST_BTN);
                 break;

            case 4:
                 FIg_set_text(fp, PART_SORT5,AttrSynonym[list_row]);
                 PDUfill_in_string(&PDU_part_sort_attr[PDU_part_row],
                                   AttrSynonym[list_row]);
                 break;
          } /* end switch */
         _pdm_debug("selected attribute = <%s>", AttrSynonym[list_row]);
         PDU_part_displayed = TRUE;
         break;

    case PART_SORT2_LIST_BTN:

         PDU_part_row = 1;
         /* set the number of rows that have been defined */
         if (PDU_num_of_part_rows <= (PDU_part_row))
           PDU_num_of_part_rows = PDU_part_row + 1;

         FIg_set_state_off(fp, PART_SORT2_LIST_BTN);

         /* put the values in the pull down list */
/*
         GRchange_pull_down_text(PDU_part_attr_pulldown, AttrSynonym,
                                 NumAttribs);
*/

         GRproc_pull_down_list(PDU_part_attr_pulldown);

         break;

    case PART_SORT3_LIST_BTN:

         PDU_part_row = 2;
         /* set the number of rows that have been defined */
         if (PDU_num_of_part_rows <= (PDU_part_row))
           PDU_num_of_part_rows = PDU_part_row + 1;

           FIg_set_state_off(fp, PART_SORT3_LIST_BTN);

           /* put the values in the pull down list */
/*
           GRchange_pull_down_text(PDU_part_attr_pulldown, AttrSynonym,
                                   NumAttribs);
*/

           /* display the pulldown list */
           GRproc_pull_down_list(PDU_part_attr_pulldown);

         break;

    case PART_SORT4_LIST_BTN:

         PDU_part_row = 3;
         /* set the number of rows that have been defined */
         if (PDU_num_of_part_rows <= (PDU_part_row))
           PDU_num_of_part_rows = PDU_part_row + 1;

           FIg_set_state_off(fp, PART_SORT4_LIST_BTN);

           /* put the values in the pull down list */
/*
           GRchange_pull_down_text(PDU_part_attr_pulldown, AttrSynonym,
                                   NumAttribs);
*/

           /* display the pulldown list */
           GRproc_pull_down_list(PDU_part_attr_pulldown);

         break;

    case PART_SORT5_LIST_BTN:

         PDU_part_row = 4;
         /* set the number of rows that have been defined */
         if (PDU_num_of_part_rows <= (PDU_part_row))
           PDU_num_of_part_rows = PDU_part_row + 1;

           FIg_set_state_off(fp, PART_SORT5_LIST_BTN);

           /* put the values in the pull down list */
/*
           GRchange_pull_down_text(PDU_part_attr_pulldown, AttrSynonym,
                                   NumAttribs);
*/

           /* display the pulldown list */
           GRproc_pull_down_list(PDU_part_attr_pulldown);

         break;

    case LOAD_BTN:

         _pdm_debug("calling sort options form", 0);
         PDU_save_sort_mode = FALSE;
         FIf_erase(fp);
         status = PDUsort_options_form();
         _pdm_status("PDUsort_options_form", status);
         break;

    case SAVE_BTN:

	 if (PDU_part_displayed == FALSE)
           {
           msg = (char *)PDUtranslate_message(PDM_E_NO_CRITERIA_DEFINED);
           FIg_set_text(forms.sort_form_id, FI_MSG_FIELD,msg);
           break;
           }

         _pdm_debug("calling sort options form", 0);
         PDU_save_sort_mode = TRUE;
         FIf_erase(fp);
         status = PDUsort_options_form();
         _pdm_status("PDUsort_options_form", status);
         break;

  } /* END switch ( g_label ) */

  return(status);

} /* END notification_routine() */

/* This function loads/creates, initializes, and displays the sort form. */

int PDUsort_form(NumAttribs, AttrList, AttrSynonym)
  int  NumAttribs;
  char **AttrList;
  char **AttrSynonym;
{
  int  sts = PDM_S_SUCCESS;
  int  index;

  PDU_sort_created = FALSE;
  PDU_sort_displayed = FALSE;
  PDU_prev_part_sort = FALSE;
  PDU_part_sort_attr = NULL;
  PDU_part_displayed = FALSE;
  PDU_sort_perm_window = FALSE;

  PDU_part_sort_string = NULL;
  PDU_part_sort_conds = NULL;

  _pdm_debug("NumAttribs = %d", NumAttribs);

    if (NumAttribs == 0)
    {
    _pdm_debug("attribute list is empty", 0);
    sts = PDM_E_ATTR_LIST_EMPTY;
    PDUmessage(sts, 's');
    return(sts);
    }

  if ((AttrList[0] == NULL) || (strcmp(AttrList[0], "") == 0) ||
      (AttrSynonym[0] == NULL) || (strcmp(AttrSynonym[0], "") == 0))
    {
    _pdm_debug("attribute list is empty", 0);
    _pdm_debug("NumAttribs = %d", NumAttribs);
    sts = PDM_E_ATTR_LIST_EMPTY;
    PDUmessage(sts, 's');
    return(sts);
    }

  PDU_part_sort_attr = (char **) malloc (sizeof (char *) * 5);
  memset(PDU_part_sort_attr, NULL, sizeof (char *) * 5);

  sts = FIf_new(SORT_FORM, "sort", sort_notification_routine,
                &forms.sort_form_id);

  _pdm_debug("Creating sort form", 0);
  PDU_sort_created = TRUE;

  _pdm_debug("number of entries = %d", (char *)NumAttribs);
  if (PDM_debug_on)
    {
    for (index = 0; index < NumAttribs; ++index)
       _pdm_debug("attr list entry = <%s>", AttrList[index]);
    for (index = 0; index < NumAttribs; ++index)
       _pdm_debug("synonym list entry = <%s>", AttrSynonym[index]);
    }

  /* Create pull down list for part sort attributes */
  GRcreate_pull_down_list(SORT_FORM, forms.sort_form_id, PART_ATTR_ASSOC_FLD,
                          MAX_ROWS, VIS_ROWS, AttrSynonym, 
                          NumAttribs, 1, &PDU_part_attr_pulldown);

  /* Display the sort form and set the displayed flag to TRUE. */
  _pdm_debug("Displaying the sort form", 0);

  sts = FIf_display(forms.sort_form_id);
  PDU_sort_displayed = TRUE;

  sts = PDM_S_SUCCESS;
  return(sts);
}
