#include	<stdio.h>
#include	"FI.h"
#include	"PDUerror.h"
#include	"PDUcommand.h"
#include	"PDUintdef.h"
#include	"PDUforms.h"
#include	"MEMerrordef.h"
#include	"MEMstruct.h"
#include        "PDUproto.h"
#include        "PDMproto.h"

#define LIST_MCF                 11
#define MCF_LIST_GRP             65
#define CHECKIN_BTN              33
#define CHECKOUT_BTN             35
#define DELETE_LOCAL_BTN         36
#define COPY_LOCAL_BTN           37
#define DESIGN                   46
#define STRUCTURE_LIST_GRP       71
#define STRUCTURE_MCF            57
#define ROLL_THROUGH             47

extern MEMptr PDU_parts_list_bufr;
extern MEMptr PDU_storage_area;
extern int    PDU_list_files;
extern int    PDU_dwg_mcf_list;
extern int    PDU_mcf_list;
extern int    PDU_selected_rows;
extern short  PDU_structure_list;
extern struct PDUforms   forms;
 
int  PDUlist_files (type)
  int		            type;       /* type of command */
  {
  int		            status = PDM_S_SUCCESS;
  int                       offset = 0;

  _pdm_debug("In the PDUlist_files function", 0);

  PDUmessage(PDM_E_CLEAR_FIELD, 's');

  PDU_list_files = TRUE;
  type = 0;

  PDUclear_mcf();

  FIfld_get_row_offset(forms.local_files_form_id, ROLL_THROUGH, &offset);
  if (offset == 0)
    {
    status = PDMrlist_local_files(&PDU_parts_list_bufr);  
    _pdm_status("PDMrlist_local_files", status);
    }
  else if (offset == 2)
    {
    status = PDMlist_checkedout_files(&PDU_parts_list_bufr);  
    _pdm_status("PDMlist_checkedout_files", status);
    }
  else if (offset == 1)
    {
    status = PDMlist_checkedin_files(&PDU_parts_list_bufr);  
    _pdm_status("PDMlist_checkedin_files", status);
    }

  if ( status != PDM_S_SUCCESS )
    {
      PDUmessage(status, 's');
      MEMclose(&PDU_parts_list_bufr);
      return(status);
    } 

  /* call function to load the buffer into the mcf */
  status = PDUload_local_files_form();
  _pdm_status("PDUload_local_files_form", status);

  if (offset == 1)
    {
    FIg_disable(forms.local_files_form_id, CHECKIN_BTN);
    FIg_disable(forms.local_files_form_id, DESIGN);
    }

  if (offset == 2)
    {
    FIg_disable(forms.local_files_form_id, COPY_LOCAL_BTN);
    FIg_disable(forms.local_files_form_id, CHECKOUT_BTN);
    }

  if (offset == 0)
    {
    FIg_disable(forms.local_files_form_id, COPY_LOCAL_BTN);
    }

  PDU_selected_rows = 0;

  return ( status );
  }
