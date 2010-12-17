#include	<PDUerror.h>
#include	<PDUstr.h>
#include	<PDUcommand.h>
#include        <part_gadgets.h>
#include        <PDUforms.h>
#include        <PDUform_def.h>
#include        "PDUproto.h"
#include        "PDMproto.h"

extern Form PDU_form_id;
extern struct PDUrefresh  *refresh;
extern int    PDU_part_flagged;
extern int    change_mode;
extern int    review_mode;
extern char     *en_itemname;
extern char     *ep_rev;
extern char     *ep_parttype;
extern char     *ep_desc;
extern struct  PDUforms forms;
extern int  PDU_command;

int  PDUflag_part(type)
  int			    type;
  {
  int		            status = PDM_S_SUCCESS;
  int		            sts = PDM_S_SUCCESS;
  char                      *state = NULL;
  char                      *status_msg = NULL;

  _pdm_debug("In the PDUflag_part function", 0);

  if (PDU_form_id == forms.local_files_form_id)
    {
    PDUmessage(type, 'c');

    if (refresh->rev_parttype && ((strcmp(refresh->rev_parttype, "P") == 0) ||
        (strcmp(refresh->rev_parttype, "p") == 0)))
      {
      status = PDM_E_FLAG_PARAM_PART;
      PDUmessage(status, 's');
      sleep(3);
      return(status);
      }

    _pdm_debug("validating access", 0);
    status = PDUmessage_trans(PDU_command, 'v');
    _pdm_status("PDUmessage_trans", status);
    if (status != PDM_S_SUCCESS)
      {
      PDUmessage(status, 's');
      return(status);
      }
    }
  
  status = PDUget_file_status(refresh->rev_catalog, refresh->rev_partid,
                              refresh->rev_revision, &state);
  _pdm_status("PDUget_file_status", status);
         
  if ((state) && (strcmp(state, "") != 0) && (strcmp(state, "I") != 0))
    {
    _pdm_debug("part is not checked in", 0);
    status = PDM_E_PART_NOT_CHECKEDIN;
    PDUmessage(status, 's');
    return(status);
    }
    

  switch ( type )
    {
    case PDC_M_ARCHIVE_PENDING:
         status = PDMflag_part_archive(refresh->rev_catalog,
				         refresh->rev_partid,
				         refresh->rev_revision);
         _pdm_status("PDMflag_part_archive", status);
            
         if (status == PDM_E_FILE_NOT_FOUND)
           status = PDM_E_PART_NOT_CHECKEDIN;

         break;

    case PDC_M_RETRIEVE_PENDING:
         status = PDMflag_part_restore(refresh->rev_catalog,
			        refresh->rev_partid,
			        refresh->rev_revision);
         _pdm_status("PDMflag_part_restore", status);
         if (status == PDM_E_ITEM_FLAGGED)
           status = PDM_E_ITEM_FLAG_RESTORE;
         break;

    case PDC_M_BACKUP_PENDING:
         status = PDMflag_part_backup(refresh->rev_catalog,
				        refresh->rev_partid,
				        refresh->rev_revision);
         _pdm_status("PDMflag_part_backup", status);

         break;

    case PDC_M_DELETE_PENDING:

         /* check if part occurs in assembly */
         status = PDMcheck_delete_part(refresh->rev_catalog,
                                       refresh->rev_partid,
                                       refresh->rev_revision);
          _pdm_status("PDMcheck_delete_part",status);


         if (status == PDM_S_SUCCESS)
           /* part does not occur in assembly */
           {
           status = PDMflag_part_delete(refresh->rev_catalog,
                                        refresh->rev_partid,
                                        refresh->rev_revision);
           _pdm_status("PDMflag_part_delete",status);              	
            }

         break;

    case PDC_M_UNFLAG_ARCHIVE:
         status = PDMUnflag_part_archive(refresh->rev_catalog,
                                         refresh->rev_partid,
                                         refresh->rev_revision);
         _pdm_status("PDMUnflag_part_archive", status);
         break;
 
    case PDC_M_UNFLAG_RESTORE:
         status = PDMUnflag_part_restore(refresh->rev_catalog,
                                         refresh->rev_partid,
                                         refresh->rev_revision);
         _pdm_status("PDMUnflag_part_restore", status);
         break;
 
    case PDC_M_UNFLAG_BACKUP:
         status = PDMUnflag_part_backup(refresh->rev_catalog,
                                        refresh->rev_partid,
                                        refresh->rev_revision);
         _pdm_status("PDMUnflag_part_backup", status);
         break;

    case PDC_M_UNFLAG_DELETE:
         status = PDMUnflag_part_delete(refresh->rev_catalog,
                                        refresh->rev_partid,
                                        refresh->rev_revision);
         _pdm_status("PDMUnflag_part_delete", status);
         break;

    default:
      break;
    }      

  PDUmessage(status, 's');

  if ((PDU_part_flagged == TRUE) && 
      (PDU_form_id == forms.part_operations_form_id))
     {
     PDU_part_flagged = FALSE;
     PDUupdate_part_form_change_mode();
     FIfld_pos_cursor(PDU_form_id,EP_PARTNUM_FLD,0,0,0,0,0,0);
     }

  if (PDU_form_id == forms.local_files_form_id)
    {
    _pdm_debug("setting the state", 0);
    status_msg = (char *) PDUtranslate_message(status);
    _pdm_debug("Error string = <%s>", status_msg);
 
    sts = PDMset_to_state ( status, "PDM", status_msg );
    _pdm_status ("PDMset_to_state", sts);
    }

  return ( status );
  }

