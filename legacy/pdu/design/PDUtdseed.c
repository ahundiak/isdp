#include <stdio.h>
#include <FI.h>
#include "PDUintdef.h"
#include "MEMstruct.h"
#include "MEMerrordef.h"
#include "PDUstr.h"
#include "PDUforms.h"
#include <PDUuser.h>
#include "PDUerror.h"
#include "PDUfile_def.h"
#include "PDMcommand.h"
#include "part_gadgets.h"
#include "PDUform_def.h"
#include <exdef.h>
#include <PDUcommand.h>
#include "sys/types.h"
#include "sys/wait.h"
#include "sys/stat.h"
#include <PDMproto.h>

/* The #DEFINES for the gadgets on this form are in part_gadgets.h */

/* Externs */

extern char * calloc();
extern char * realloc();
extern int    PDM_debug_on;
extern int    FIg_get_text_length();
extern int    FIg_get_text();
extern int    PDU_single_list_displayed;
extern int    PDU_single_list_created;
extern int    PDU_mcf_list_displayed;
extern int    PDU_mcf_list_created;
extern int    PDU_command;
extern int    PDU_check_filename;
extern int    PDMdebug_on;
extern int    PDU_refresh_gadgets[7];
extern int    PDU_validate_access;
extern int    PDU_form_type;
extern int    PDU_search_type;
extern int    PDU_active_button;
extern Form   PDU_calling_form;
extern Form   PDU_struct_type;
extern Form   PDU_form_id;
extern struct PDUrefresh    *refresh;
extern struct PDUforms      forms;
extern struct PDUuser         *user;
extern int    *PDU_gadget_labels;
extern char   *PDU_value_list[605];
extern char *** PDU_update_struct;
extern int    PDU_value_pulldown;
extern short    PDU_list_filenames;
extern MEMptr PDU_ret_bufr;
extern MEMptr PDU_display_buffer;
extern MEMptr PDU_design_parts_bufr;
extern short  PDU_check_file_refresh;

/* Global and static variables */

/*	02/nov/93 - raj. Moved globals to PDUglobals.c	*/
extern	int      topdown_seed_form_created;
extern	int      topdown_seed_form_displayed;
extern	int      topdown_user_seed_file;


/* Initialize the Part Operations Form */

void PDUtopdown_seed_form_init()
{
_pdm_debug("INSIDE the PDUtopdown_seed_form_init function",0);

/*	02/nov/93 - raj. Moved globals to PDUglobals.c	*/
topdown_seed_form_created = FALSE;
topdown_seed_form_displayed = FALSE;

topdown_user_seed_file = FALSE;

PDU_refresh_gadgets[0] = 0;
PDU_refresh_gadgets[1] = NFC_CATALOG_FLD;
PDU_refresh_gadgets[2] = NFC_PART_FLD;
PDU_refresh_gadgets[3] = NFC_REV_FLD;
PDU_refresh_gadgets[5] = NFC_DESC_FLD;
PDU_refresh_gadgets[6] = NFC_FILENAME_FLD;

refresh->act_catalog = NULL;
refresh->act_partid = NULL;
refresh->act_revision = NULL;
refresh->act_description = NULL;
refresh->act_filename = NULL;
refresh->act_parttype = NULL;

/* Fill in refresh->act_filename with the file you want to create */
/* refresh->act_filename is the file being copied TO */
/* refresh->rev_filename is the file being copied FROM after a filename is
   selected on the seed form. This means that after this fill in string, 
   refresh->rev_filename will be overwritten */
PDUfill_in_string1(&refresh->act_filename,refresh->rev_filename);

/* Fill in part info from PDM/PDU Form */
PDUfill_in_string1(&refresh->act_catalog,refresh->rev_catalog);
PDUfill_in_string1(&refresh->act_partid,refresh->rev_partid);
PDUfill_in_string1(&refresh->act_revision,refresh->rev_revision);
PDUfill_in_string1(&refresh->act_description,refresh->rev_description);
PDUfill_in_string1(&refresh->act_parttype,refresh->rev_parttype);

refresh->rev_catalog = NULL;
refresh->rev_partid = NULL;
refresh->rev_revision = NULL;
refresh->rev_description = NULL;
refresh->rev_filename = NULL;
refresh->rev_parttype = NULL;

}


/* This function will delete a single file that was copied local and update
   the local file manager */

PDUtopdown_cancel_seedfile_form ()
{
          
	_pdm_debug("Enter PDUtopdown_cancel_seedfile_form()", 0);

         PDUdismiss_subforms();
         topdown_user_seed_file = FALSE;

         PDUfill_in_string1(&refresh->rev_catalog,refresh->act_catalog);
         PDUfill_in_string1(&refresh->rev_partid,refresh->act_partid);
         PDUfill_in_string1(&refresh->rev_revision,refresh->act_revision);
         PDUfill_in_string1(&refresh->rev_description,refresh->act_description);
         PDUfill_in_string1(&refresh->rev_filename,refresh->act_filename);

         /* reset the refresh 'act' fields */
         refresh->act_catalog = NULL;
         refresh->act_partid = NULL;
         refresh->act_revision = NULL;
         refresh->act_description = NULL;
         refresh->act_filename = NULL;

          /* Erase the displayed form */

         FIf_erase (forms.seed_form_form_id);
         FIf_delete (forms.seed_form_form_id);
	/* TR# 139419796. 4/jun/may - raj.	*/
	forms.seed_form_form_id = 0;

	/* 20/Dec/93 - raj.	TR# 13931 4313.			*/
	/* DO NOT display the PDM Utilities form.		*/
/*         FIf_display(forms.local_files_form_id);	*/
/*							*/
/*         PDUmessage(PDM_E_CLEAR_FIELD,'s');		*/
/*							*/
/*         PDUrefresh_local_files_form();		*/

	/* 20/Dec/93 - raj. TR# 13931 4313.		*/
        PDUmessage(PDM_E_CLEAR_FIELD,'s');

	_pdm_debug("Exit PDUtopdown_cancel_seedfile_form()", 0);

	return (1);
}

PDUtopdown_accept_seed_file_form (Form fp, char *seedfile)
{
	char            string[50];
	char            seed_file_path[80];
	int             status = PDM_S_SUCCESS;
	int             state = 0;
  	short           delete_file = FALSE;    
	
         _pdm_debug("INSIDE the FI_ACCEPT for the seed form",0);

	/*
	 * Get the state of SEED FILE TOGGLE.
	 */
	status = FIg_get_state(fp,SEED_FILE_TGL,&state);
        if (status != FI_SUCCESS)
        {
		PDUmessage(status,'s');
		return (0);
        }

	/*
	 * It is possible that user never touched this and refresh structure
	 * has some previous values.
	 */
	if (state == 0)
	{
            _pdm_debug("The SEED_FILE_TGL is set to Default EMS seed file",0);
 
            topdown_user_seed_file = FALSE;

            refresh->rev_catalog = NULL;
            refresh->rev_partid = NULL;
            refresh->rev_revision = NULL;
            refresh->rev_description = NULL;
            refresh->rev_filename = NULL;
          
        }

         if (topdown_user_seed_file == TRUE)
            {
            _pdm_debug("refresh->rev_catalog = <%s>", refresh->rev_catalog);
            _pdm_debug("refresh->rev_partid = <%s>", refresh->rev_partid);
            _pdm_debug("refresh->rev_revision = <%s>", refresh->rev_revision);
            _pdm_debug("refresh->rev_filename = <%s>", refresh->rev_filename);

            if ((refresh->rev_catalog == NULL) || 
                (strcmp(refresh->rev_catalog,"") == 0))
               {
               FIg_set_text(forms.seed_form_form_id, FI_MSG_FIELD,
               "User must enter a catalog name");
               FIg_set_state_off(forms.seed_form_form_id,FI_ACCEPT);
               return (0);
               }

            if ((refresh->rev_partid == NULL) || 
                (strcmp(refresh->rev_partid,"") == 0))
               {
               FIg_set_text(forms.seed_form_form_id, FI_MSG_FIELD,
               "User must enter a part number");
               FIg_set_state_off(forms.seed_form_form_id,FI_ACCEPT);
               return (0);
               }

            if ((refresh->rev_revision == NULL) || 
                (strcmp(refresh->rev_revision,"") == 0))
               {
               FIg_set_text(forms.seed_form_form_id, FI_MSG_FIELD,
               "User must enter a revision");
               FIg_set_state_off(forms.seed_form_form_id,FI_ACCEPT);
               return (0);
               }

            if ((refresh->rev_filename == NULL) || 
                (strcmp(refresh->rev_filename,"") == 0))
               {
               FIg_set_text(forms.seed_form_form_id, FI_MSG_FIELD,
               "User must enter a filename");
               FIg_set_state_off(forms.seed_form_form_id,FI_ACCEPT);
               return (0);
               }
            }

         if (topdown_user_seed_file == FALSE)
            {
            _pdm_debug("Taking the option to use the EMS seed file",0);
            FIf_erase(forms.seed_form_form_id);
            FIf_delete(forms.seed_form_form_id);
	    /* TR# 139419796. 4/jun/may - raj.	*/
	    forms.seed_form_form_id = 0;

            PDUfill_in_string1(&refresh->rev_catalog,refresh->act_catalog);
            PDUfill_in_string1(&refresh->rev_partid,refresh->act_partid);
            PDUfill_in_string1(&refresh->rev_revision,refresh->act_revision);
            PDUfill_in_string1(&refresh->rev_description,
                               refresh->act_description);
            PDUfill_in_string1(&refresh->rev_filename,refresh->act_filename);
            
            return (1);
            }
          
         _pdm_debug("Taking the option to use a user defined seed file",0);

         /* Check if file is already local */
         status = PDUverify_file(refresh->rev_filename);
         _pdm_status("PDUverify_file",status);

         if (status != PDM_S_SUCCESS)
            {
            delete_file = TRUE;
            _pdm_debug("PDMscopy is called",0);
            _pdm_debug("Copying file locally",0);
            status = PDMscopy(refresh->rev_catalog,refresh->rev_partid, 
                              refresh->rev_revision, refresh->rev_filename);
            _pdm_status("PDMscopy",status);

            if (status != PDM_S_SUCCESS)
               {
               _pdm_debug("The PDMscopy was UNsuccessful",0);
               PDUmessage(status, 's');
               FIg_set_state_off(forms.seed_form_form_id,FI_ACCEPT);
               return (0);
               }

            /* Verify that the file was actually copied */
            status = PDUverify_file(refresh->rev_filename);
            _pdm_status("PDUverify_file",status);
   
            PDUmessage(status, 's');
   
            if (status != PDM_S_SUCCESS)
               {
               _pdm_debug("File <%s> does not exist",refresh->rev_filename);
               sprintf(string,"File <%s> does not exist",
                       refresh->rev_filename);
               FIg_set_text(PDU_form_id,FI_MSG_FIELD,string);
               FIg_set_text(PDU_form_id,NFC_FILENAME_FLD,"");
               refresh->rev_filename = NULL_STRING;
               FIg_set_state_off(forms.seed_form_form_id,FI_ACCEPT);
               return (0);
               }
            }
         else
            delete_file = FALSE;

         _pdm_debug("File <%s> was copied locally",refresh->rev_filename);
 
         /* Save the seed file name and path so the seed file can be
            removed later */

         sprintf(seed_file_path,"%s/%s",user->wrkst_cwd,
                                        refresh->rev_filename);

         status = PDUcheck_if_graphic(refresh->rev_filename);
         _pdm_status("PDUcheck_if_graphic",status);

         if (status != PDM_S_SUCCESS)
            {
            PDUmessage(status, 's');
            _pdm_debug("File <%s> is not graphic",refresh->rev_filename);
            sprintf(string,"File <%s> is not graphic", refresh->rev_filename);
            FIg_set_text(PDU_form_id,FI_MSG_FIELD,string);
            FIg_set_text(PDU_form_id,NFC_FILENAME_FLD,"");
            FIg_set_state_off(forms.seed_form_form_id,FI_ACCEPT);
            refresh->rev_filename = NULL_STRING;

            if (delete_file == TRUE)
             {
             status = PDUdelete_single_local_file(refresh->rev_catalog,
                                 refresh->rev_partid, refresh->rev_revision,
                                 refresh->rev_filename, seed_file_path);
             _pdm_status("PDUdelete_single_local_file",status);
             }
 
            return (0);
            }

         _pdm_debug("File <%s> is graphic",refresh->rev_filename);

	/* Copy seedfile name into argument before refresh->rev_catalog is reset.	*/
	strcpy (seedfile, refresh->rev_filename);
	
         /* Erase the displayed form */
         FIf_erase ( fp );
         FIf_delete ( fp );
	/* TR# 139419796. 4/jun/may - raj.	*/
	forms.seed_form_form_id = 0;

         PDUfill_in_string1(&refresh->rev_catalog,refresh->act_catalog);
         PDUfill_in_string1(&refresh->rev_partid,refresh->act_partid);
         PDUfill_in_string1(&refresh->rev_revision,refresh->act_revision);
         PDUfill_in_string1(&refresh->rev_description,
                            refresh->act_description);
         PDUfill_in_string1(&refresh->rev_filename,refresh->act_filename);

	 return (1);
}

PDUtopdown_seed_file_toggle ()
{
  int             status = PDM_S_SUCCESS;
  int             state = 0;

          _pdm_debug("ENTER: SEED_FILE_TGL",0);

         status = FIg_get_state(PDU_form_id,SEED_FILE_TGL,&state);

         if (status != FI_SUCCESS)
            {
            PDUmessage(status,'s');
            return (0);
            }

         if (state == 0)
            {
            _pdm_debug("The SEED_FILE_TGL is set to Default EMS seed file",0);
 
            topdown_user_seed_file = FALSE;

            status = FIg_erase(PDU_form_id,NFC_PART_GRP);

            if (status != FI_SUCCESS)
               {
               PDUmessage(status,'s');
               return (0);
               }

            FIfld_set_text(PDU_form_id,NFC_CATALOG_FLD,0,0,"",FALSE);
            FIfld_set_text(PDU_form_id,NFC_PART_FLD,0,0,"",FALSE);
            FIfld_set_text(PDU_form_id,NFC_REV_FLD,0,0,"",FALSE);
            FIfld_set_text(PDU_form_id,NFC_FILENAME_FLD,0,0,"",FALSE);
            FIfld_set_text(PDU_form_id,NFC_DESC_FLD,0,0,"",FALSE);

            refresh->rev_catalog = NULL;
            refresh->rev_partid = NULL;
            refresh->rev_revision = NULL;
            refresh->rev_description = NULL;
            refresh->rev_filename = NULL;
            }
         else if (state == 1)
            {
            topdown_user_seed_file = TRUE;

            _pdm_debug("The SEED_FILE_TGL is set to User defined seed file",0);

            status = FIg_display(PDU_form_id,NFC_PART_GRP);

            if (status != FI_SUCCESS)
               {
               PDUmessage(status,'s');
               return (0);
               }

            FIfld_pos_cursor(PDU_form_id,NFC_CATALOG_FLD,0,0,0,0,0,0);

            }

	return (1);
}

PDUtopdown_catalog_field (Form fp)
{
  int             status = PDM_S_SUCCESS;

         _pdm_debug("Entering CATALOG",0);

	 refresh->rev_catalog = NULL;
         refresh->rev_partid = NULL;
         refresh->rev_revision = NULL;
         refresh->rev_description = NULL;
         refresh->rev_filename = NULL;
 
         FIg_set_text(fp, NFC_PART_FLD, "");
         FIg_set_text(fp, NFC_REV_FLD, "");
         FIg_set_text(fp, NFC_FILENAME_FLD, "");
         FIg_set_text(fp, NFC_DESC_FLD, "");

         status = PDUep_cat_fld();
         _pdm_status("PDUep_cat_fld",status);

         if (status == 0)
           return (0);

         PDUmessage(status,'s');

	return (1);
}

PDUtopdown_part_field (Form fp)
{
  int             status = PDM_S_SUCCESS;

         _pdm_debug("Entering PARTNUM",0);

         refresh->rev_partid = NULL;
         refresh->rev_revision = NULL;
         refresh->rev_description = NULL;
         refresh->rev_filename = NULL;
 
         FIg_set_text(fp, NFC_REV_FLD, "");
         FIg_set_text(fp, NFC_FILENAME_FLD, "");
         FIg_set_text(fp, NFC_DESC_FLD, "");

         status = PDUep_part_fld();
         _pdm_status("PDUep_part_fld",status);

         if (status == 0)
           return (0);

         PDUmessage(status,'s');
         status = PDUcheck_file_commands();
         _pdm_status("PDUcheck_file_commands", status);

	return (1);
}

PDUtopdown_revision_field (Form fp)
{
  int             status = PDM_S_SUCCESS;

         _pdm_debug("Entering EP_REV_FLD",0);

         refresh->rev_revision = NULL;
         refresh->rev_description = NULL;
         refresh->rev_filename = NULL;
 
         FIg_set_text(fp, NFC_FILENAME_FLD, "");
         FIg_set_text(fp, NFC_DESC_FLD, "");

         PDUfill_in_string1(&refresh->rev_filename,"");
         FIfld_set_text(PDU_form_id,NFC_FILENAME_FLD,0,0,
                        "",FALSE);

         status = PDUep_rev_fld();
         _pdm_status("PDUep_rev_fld",status);

         if (status == 0)
            return (0);

         PDUmessage(status,'s');
         status = PDUcheck_file_commands();
         _pdm_status("PDUcheck_file_commands", status);

	return (1);
}

PDUtopdown_filename_field (Form fp)
{
  int             status = PDM_S_SUCCESS;
  int             select, pos, length;
  static char   * text = NULL_STRING;

         /* verify part is in part selection area */
          if ((refresh->rev_catalog == NULL) ||
              (strcmp(refresh->rev_catalog, "") == 0))
            {
            FIg_set_text(fp, FI_MSG_FIELD,
            "User must enter catalog/part/revision before entering a filename");
            return (0);
            }

          if ((refresh->rev_partid == NULL) ||
              (strcmp(refresh->rev_partid, "") == 0))
            {
            FIg_set_text(fp, FI_MSG_FIELD,
            "User must enter catalog/part/revision before entering a filename");
            return (0);
            }

          if ((refresh->rev_revision == NULL) ||
              (strcmp(refresh->rev_revision, "") == 0))
            {
            FIg_set_text(fp, FI_MSG_FIELD,
            "User must enter catalog/part/revision before entering a filename");
            return (0);
          }

          FIfld_get_text_length(fp, NFC_FILENAME_FLD, 0, 0, &length);
          text = (char *) malloc (sizeof (char) * length + 1);
          memset(text, NULL, sizeof (char) * length + 1);
          FIfld_get_text(fp, NFC_FILENAME_FLD,0,0,length, 
                         (unsigned char *)text, &select, &pos);

         if ((text == NULL) || (strcmp(text, "") == 0))
           {
           refresh->rev_filename = NULL;
           return (0);
           }

         status = PDUvalid_filename(text);
         _pdm_status("PDUvalid_filename", status);

         if (status != PDM_S_SUCCESS)
            {
            FIg_set_text(fp, NFC_FILENAME_FLD, "");
            FIfld_pos_cursor(fp, NFC_FILENAME_FLD, 0,0,0,0,0,0);
            PDUmessage(status, 's');
            return (0);
            }

         PDUfill_in_string(&refresh->rev_filename, text);

	return (1);
}

PDUtopdown_desc_field (Form fp)
{
  int             status = PDM_S_SUCCESS;

         _pdm_debug("Entering EP_DESC_BTN",0);

         refresh->rev_description = NULL;
         refresh->rev_filename = NULL;
         FIg_set_text(fp, NFC_FILENAME_FLD, "");

         status = PDUep_desc_fld();
         _pdm_status("PDUep_desc_fld",status);

         if (status == 0)
           return (0);

         PDUmessage(status,'s');
         status = PDUcheck_file_commands();
         _pdm_status("PDUcheck_file_commands", status);

	return (1);
}

PDUtopdown_catalog_btn (Form fp)
{
  int             status = PDM_S_SUCCESS;

         PDU_active_button = NFC_CATALOG_BTN;

         PDU_check_file_refresh = TRUE;

         refresh->rev_partid = NULL;
         refresh->rev_revision = NULL;
         refresh->rev_description = NULL;
         refresh->rev_filename = NULL;
 
         FIg_set_text(fp, NFC_PART_FLD, "");
         FIg_set_text(fp, NFC_REV_FLD, "");
         FIg_set_text(fp, NFC_DESC_FLD, "");
         FIg_set_text(fp, NFC_FILENAME_FLD, "");

         _pdm_debug("Entering PDUep_cat_btn",0);

         status = PDUep_cat_btn();
         _pdm_status("PDUep_cat_btn",status);

         if (status == 0)
            return (0);

         PDUmessage(status,'s');

	return (1);
}

PDUtopdown_part_btn (Form fp)
{
  int             status = PDM_S_SUCCESS;

         PDU_active_button = NFC_PART_BTN;

         PDU_check_file_refresh = TRUE;

         refresh->rev_revision = NULL;
         refresh->rev_description = NULL;
         refresh->rev_filename = NULL;
 
         FIg_set_text(fp, NFC_REV_FLD, "");
         FIg_set_text(fp, NFC_DESC_FLD, "");
         FIg_set_text(fp, NFC_FILENAME_FLD, "");

         _pdm_debug("Entering PDUep_part_btn",0);

         status = PDUep_part_btn();
         _pdm_status("PDUep_part_btn",status);

         if (status == 0)
            return (0);

         PDUmessage(status,'s');

	return (1);
}

PDUtopdown_revision_btn (Form fp)
{
  int             status = PDM_S_SUCCESS;

         PDU_active_button = NFC_REV_BTN;

         PDU_check_file_refresh = TRUE;

         refresh->rev_description = NULL;
         refresh->rev_filename = NULL;
 
         FIg_set_text(fp, NFC_DESC_FLD, "");
         FIg_set_text(fp, NFC_FILENAME_FLD, "");

         _pdm_debug("Entering PDUep_rev_btn",0);

         status = PDUep_rev_btn();
         _pdm_status("PDUep_rev_btn",status);

         if (status == 0)
            return (0);

         PDUmessage(status,'s');

	return (1);
}

PDUtopdown_filename_btn (Form fp)
{
  int             status = PDM_S_SUCCESS;
  int             all_flag;
  int             no_headings;
  char         ** headings;

         PDU_active_button = NFC_FILENAME_BTN;

         if (refresh->rev_catalog == NULL)
           {
           _pdm_debug("No catalog",0);
           FIg_set_text(fp, FI_MSG_FIELD,
            "User must enter catalog/part/revision before entering a filename");
           return (0);
           }

         if (refresh->rev_partid == NULL)
           {
           _pdm_debug("No partid",0);
           FIg_set_text(fp, FI_MSG_FIELD,
            "User must enter catalog/part/revision before entering a filename");
           return (0);
           }

         if (refresh->rev_revision == NULL)
           {
           _pdm_debug("No rev",0);
           FIg_set_text(fp, FI_MSG_FIELD,
            "User must enter catalog/part/revision before entering a filename");
           return (0);
           }

         /* call PDM function to retrieve a list of filenames */
         if (PDU_ret_bufr != NULL)
           {
           MEMclose(&PDU_ret_bufr);
           PDU_ret_bufr = NULL;
           }

         _pdm_debug("Call PDMget_filenames",0);
         status = PDMget_filenames(refresh->rev_catalog,refresh->rev_partid,
                         refresh->rev_revision, &PDU_ret_bufr);
         _pdm_status("PDMget_filenames", status);

         if ( status != PDM_S_SUCCESS )
           {
           FIg_set_text(fp,FI_MSG_FIELD,
                        "Could not retrieve list of filenames");
           MEMclose(&PDU_ret_bufr);
           return (0);
           }

         if (PDU_ret_bufr == NULL)
           {
           FIg_set_text(forms.seed_form_form_id, FI_MSG_FIELD,
                        "There are not any files for current part");
           return (0);
           }

         PDUsetup_single_buffer(PDU_ret_bufr);
         PDU_form_id = forms.seed_form_form_id;
         PDU_gadget_labels[0] = NFC_FILENAME_FLD;
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

         PDU_list_filenames = TRUE;

         _pdm_debug("Call PDUsingle_list_form",0);
         status = PDUsingle_list_form();


	return (1);
}

PDUtopdown_search_btn (Form fp)
{
         PDU_form_id = forms.seed_form_form_id;
         PDU_form_type = SEED_FORM;
         PDU_search_type = PARTS;
         PDU_calling_form = forms.seed_form_form_id;

         FIf_erase(PDU_form_id);
         FIf_erase(forms.local_files_form_id);

         _pdm_debug("calling part selection form", 0);

         SelectOrPlacePart(TRUE, TRUE, fp);


	return (1);
}

