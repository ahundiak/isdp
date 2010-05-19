/* $Id: PDUbuffers.c,v 1.1.1.1 2001/01/04 21:07:28 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/emsfixes/pdu / vdpd.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: PDUbuffers.c,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:28  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	04/17/98	HF		Added PDUbuffers.c (TR 179702003)
 *					The file PDUbuffers.c is a stripped down version
 *					(only function kept is PDUsetup_single_buffer)
 *					The 4 functions from file PDUdsp_att.c are appended
 *					at the end. 
 *					
 * -------------------------------------------------------------------*/

#include <stdio.h>
#include "FI.h"
#include "tools.h"
#include "PDUstr.h"
#include <PDUforms.h>
#include "PDUerror.h"
#include "PDUfile_def.h"
#include "PDUcommand.h"
#include "PDUprompt.h"
#include "PDUerror.h"
#include "PDUextdef.h"
#include "PDUpart.h"
#include "MEMstruct.h"
#include "MEMerrordef.h"
#include "part_gadgets.h"
#include "PDMmessage.h"

/* Externs */

extern int PDMdebug_on;
extern short  PDU_default_env;
extern short  PDU_list_filenames;
extern short  PDU_check_file_refresh;
extern short  PDU_second_row;
extern short  PDU_multiple_revs;
extern int    PDU_active_button;
extern int    PDU_active_list;
extern int    PDU_command;
extern int    end_ep_cat_btn_flag;
extern int   PDU_list_cat;
extern Form PDU_form_id;
extern int * PDU_display_column;
extern char **  PDU_data_row;
extern char **  PDU_data_col;
extern char **  PDU_data_format;
extern char *** PDU_update_struct;
extern char *   PDU_popup_list_type;
extern struct   PDUforms   forms;
extern int    * PDU_display_column;
extern int    * PDU_buffer_columns;
extern int    * PDU_struct_fields;
extern int    * PDU_gadget_labels;
extern struct   PDUforms      forms;
extern int      end_np_cat_btn_flag;
extern int      end_np_part_btn_flag;
extern int      end_np_parttype_btn_flag;
extern int      end_ep_proj_btn_flag;
extern int      end_ep_part_fld_flag;
extern int      end_ep_part_btn_flag;
extern int      end_ep_rev_btn_flag;
extern int      end_ep_parttype_btn_flag;
extern int      end_ep_desc_fld_flag;
extern int      end_ep_desc_btn_flag;
extern int      end_stg_area_btn_flag;
extern int      end_acl_wf_btn_flag;
extern int      end_move_to_state_btn_flag;
extern int      pdu_hold_stg_bufr_flag;
extern int      pdu_hold_acl_bufr_flag;
extern int      pdu_ep_stg_bufr_flag;
extern int      pdu_ep_acl_bufr_flag;
extern int      PDU_simmode_cat_bufr;
extern int      PDU_refresh_gadgets[7];
extern int      PDU_mcf_list_created;
extern int      PDU_single_list_created;
extern int      single_flag;
extern int      PDU_login_created;
extern char     *en_itemname;
extern char     *ep_rev;
extern MEMptr   PDU_display_buffer;
extern MEMptr   PDU_ret_bufr;

extern char		***PDU_update_struct;
extern struct  PDUpart    *part;
extern struct  PDUforms    forms;
extern struct  PDUrefresh *refresh;
extern char		  *PDU_filename;
extern char		  *PDU_viewname;
extern char		  *PDU_checkin_file;

void PDUsetup_single_buffer(buffer)
MEMptr    buffer;
{
  int sz = 0;
  
  _pdm_debug("In the function PDUsetup_single_buffer() : buffer = %#x", buffer);

  if ( (buffer) == NULL ) return;		/* HF: 04/17/98		TR 179702003 */

  if ((buffer) && (buffer->rows > 0))
  {
    MEMbuild_array(buffer);
    PDUsetup_buffer(buffer, COL, &PDU_data_col);
    PDUsetup_buffer(buffer, ROW, &PDU_data_row);
    PDUsetup_buffer(buffer, FORMAT, &PDU_data_format);
  }

  sz = sizeof (int) * buffer->columns;

  PDU_display_column = (int *) malloc (sz);
  memset(PDU_display_column, -1, sz);

  PDU_buffer_columns = (int *) malloc (sz);
  memset(PDU_buffer_columns, -1, sz);

  PDU_struct_fields = (int *) malloc (sz);
  memset(PDU_struct_fields, -1, sz);

  PDU_gadget_labels = (int *) malloc (sz);
  memset(PDU_gadget_labels, -1, sz);

  sz = sizeof (char **) * buffer->columns;

  PDU_update_struct = (char ***) malloc (sz);
  memset(PDU_update_struct, NULL, sz);

} /* end PDUsetup_single_buffer */

void PDUdisplay_views()
{
  int status;
  int all_flag;
  char *msg_str;
  char *msg_str2;

  _pdm_debug("In PDUdisplay_views() : PDU_ret_bufr = %#x", PDU_ret_bufr);

  if ( (PDU_ret_bufr) == NULL ) return;		/* HF: 04/17/98		TR 179702003 */

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

  _pdm_debug("In PDUdisplay_views_single() : PDU_ret_bufr = %#x", PDU_ret_bufr);

  if ( (PDU_ret_bufr) == NULL ) return;		/* HF: 04/17/98		TR 179702003 */

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

  _pdm_debug("In PDUdisplay_files() : PDU_ret_bufr = %#x", PDU_ret_bufr);

  if ( (PDU_ret_bufr) == NULL ) return;		/* HF: 04/17/98		TR 179702003 */

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

  _pdm_debug("In PDUdisplay_checkin_files() : PDU_ret_bufr = %#x", PDU_ret_bufr);

  if ( (PDU_ret_bufr) == NULL ) return;		/* HF: 04/17/98		TR 179702003 */

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
