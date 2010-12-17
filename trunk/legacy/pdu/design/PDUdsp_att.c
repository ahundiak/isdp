#include <stdio.h>
#include <tools.h>
#include "FI.h"
#include "exdef.h"
#include "PDUstr.h"
#include "PDUforms.h"
#include "PDUform_def.h"
#include "PDUcommand.h"
#include "PDUprompt.h"
#include "PDUerror.h"
#include "PDUextdef.h"
#include "PDUpart.h"

extern MEMptr PDU_ret_bufr;
extern struct PDUpart *part;
extern char ***PDU_update_struct;
extern struct PDUpart *part;
extern struct PDUforms forms;
extern struct PDUrefresh *refresh;
extern char *PDU_filename;
extern char *PDU_viewname;
extern char *PDU_checkin_file;

void PDUdisplay_views()

  {
  int status;
  int all_flag;
  char *msg_str;
  char *msg_str2;

  _pdm_debug("In PDUdisplay_views", 0);

  PDUsetup_single_buffer(PDU_ret_bufr);

  PDU_update_struct[0] = &PDU_viewname;

  all_flag = TRUE;

  status = PDUsetup_popup_list(NULL, 0, all_flag, PDU_ret_bufr);
  _pdm_status("PDUsetup_popup_list", status);

  status = PDUsetup_struct_fields(NULL, 0, all_flag, PDU_ret_bufr);
  _pdm_status("PDU_setup_struct_fields", status);

  msg_str = (char *)PDUtranslate_message(PDP_P_SELECT_VIEW_FROM_LIST);
  msg_str2 = (char *)PDUtranslate_message(PDM_I_LIST_VIEWS);
  status = PDUattach_single_list_form(msg_str2,msg_str);
  _pdm_status("PDUattach_single_list_form", status);
  
  _pdm_debug("Exiting PDUdisplay_views", 0);
  }

/*
 * CR #:139525526. 05/sep/95 - raj.
 * New version of PDUdisplay_views() to display form even when there's a single value.
 */

void PDUdisplay_views_single()

  {
  int status;
  int all_flag;
  char *msg_str;
  char *msg_str2;

  _pdm_debug("In PDUdisplay_views_single", 0);

  PDUsetup_single_buffer(PDU_ret_bufr);

  PDU_update_struct[0] = &PDU_viewname;

  all_flag = TRUE;

  status = PDUsetup_popup_list(NULL, 0, all_flag, PDU_ret_bufr);
  _pdm_status("PDUsetup_popup_list", status);

  status = PDUsetup_struct_fields(NULL, 0, all_flag, PDU_ret_bufr);
  _pdm_status("PDU_setup_struct_fields", status);

  msg_str = (char *)PDUtranslate_message(PDP_P_SELECT_VIEW_FROM_LIST);
  msg_str2 = (char *)PDUtranslate_message(PDM_I_LIST_VIEWS);
  status = PDUattach_single_list_form_single(msg_str2,msg_str);
  _pdm_status("PDUattach_single_list_form_single", status);
  
  _pdm_debug("Exiting PDUdisplay_views_single", 0);
  }

void PDUdisplay_files()

  {
  int status;
  int all_flag;
  char *msg_str;
  char *msg_str2;

  _pdm_debug("In PDUdisplay_files", 0);

  PDUsetup_single_buffer(PDU_ret_bufr);

  PDU_update_struct[0] = &PDU_filename;

  all_flag = TRUE;

  status = PDUsetup_popup_list(NULL, 0, all_flag, PDU_ret_bufr);
  _pdm_status("PDUsetup_popup_list", status);

  status = PDUsetup_struct_fields(NULL, 0, all_flag, PDU_ret_bufr);
  _pdm_status("PDU_setup_struct_fields", status);

  msg_str = (char *)PDUtranslate_message(PDP_P_SELECT_FILE_FROM_LIST);
  msg_str2 = (char *)PDUtranslate_message(PDM_I_LIST_FILES);
  status = PDUattach_single_list_form(msg_str2,msg_str);
  _pdm_status("PDUattach_single_list_form", status);

  }

void PDUdisplay_checkin_files()

{
  int status;
  int all_flag;
  int no_headings;
  char **headings = NULL;
  char *msg_str;
  char *msg_str2;

  _pdm_debug("In PDUdisplay_checkin_files", 0);

  PDUsetup_single_buffer(PDU_ret_bufr);

  PDU_update_struct[0] = &PDU_checkin_file;

  all_flag = FALSE;
  no_headings = 1;
  headings = (char **)malloc(sizeof (char *) * no_headings);
  memset(headings, NULL, sizeof (char *) * no_headings);

  PDUfill_in_string(&headings[0], "n_cofilename");

  status = PDUsetup_popup_list(headings, no_headings, all_flag, PDU_ret_bufr);
  _pdm_status("PDUsetup_popup_list", status);

  status = PDUsetup_struct_fields(headings, no_headings,all_flag, PDU_ret_bufr);
  _pdm_status("PDU_setup_struct_fields", status);

  msg_str = (char *)PDUtranslate_message(PDP_P_SELECT_FILE_FROM_LIST);
  msg_str2 = (char *)PDUtranslate_message(PDM_I_LIST_FILES);
  status = PDUattach_single_list_form(msg_str2,msg_str);
  _pdm_status("PDUattach_single_list_form", status);

  FIg_display(forms.single_list_form_id, 12);
  _pdm_debug("Exiting PDUdisplay_views", 0);
  }

