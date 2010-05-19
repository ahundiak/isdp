/* $Id: PDUadd_part.c,v 1.3 2002/01/07 18:32:04 jdsauby Exp $ */
/* -------------------------------------------------------------------
 * I/VDS
 *
 * File: vds/emsfixes/pdu/filemgr/PDUadd_part.c
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *       $Log: PDUadd_part.c,v $
 *       Revision 1.3  2002/01/07 18:32:04  jdsauby
 *       JTSMP CR 5865
 *
 *       Revision 1.2  2001/10/29 17:16:23  jdsauby
 *       JTS CR 5552 - jds
 *
 *
 * History:
 *       MM/DD/YY        AUTHOR          DESCRIPTION
 *       10/18/01	 js		 Creation for AIM
 * -------------------------------------------------------------------------*/

#include        <stdio.h>
#include        <FI.h>
#include	<PDUstr.h>
#include        <PDUextdef.h>
#include	<PDUerror.h>
#include        <PDUuser.h>
#include	<PDMtypes.h>
#include	<MEMerrordef.h>
#include        <NFMerrordef.h>
#include        "part_gadgets.h"
#include        "PDUforms.h"
#include        "PDUcommand.h"
#include        "PDUfile_def.h"
#include        "PDUstorage.h"
#include        <exdef.h>
#include        <PDUproto.h>
//#include        <PDMproto.h>
#include        <PDMmessage.h>
#include        <sys/stat.h>

/* Extern */

extern int          PDM_debug_on;
extern int          PDU_add_files;
extern int          PDU_simmode_copy;
extern int          PDU_simmode_checkin;
extern int          PDU_command;
extern int          PDMdebug_on;
extern int          PDU_validate_access;
extern int          new_mode;
extern int          change_mode;
extern int          similar_mode;
extern struct       PDUforms   forms;
extern struct       PDUrefresh    *refresh;
extern struct       PDUuser       *user;
extern struct       PDUstorage    *storage;
extern char        *np_project;
extern char        *np_catalog;
extern char        *nn_itemname;
extern char        *np_rev;
extern char        *np_parttype;
extern char        *np_desc;
extern char        *ep_catalog;
extern char        *en_itemname;
extern char        *ep_rev;
extern char        *ep_parttype;
extern char        *ep_desc;
extern char        *PDU_attr_name;
extern char        *calloc();
extern char        *realloc();
extern MEMptr       PDU_attr_bufr;
extern MEMptr       PDU_data_bufr;
extern MEMptr       PDU_acl_bufr;
extern MEMptr       PDU_stg_bufr;
extern MEMptr       PDU_add_data_bufr;
extern char      ** PDU_attr_row;
extern Form         PDU_form_id;
extern short        PDU_disable_localfn_col;
extern short        PDU_disable_storagefn_col;
extern short        PDU_disable_filetype_col;
extern short        PDU_disable_filedesc_col;

/* SAUBY, added this for AIM CM stuff */
extern long AIMcmAddPart();
extern long VDaimIsAimLoaded();

// added for JTSMP CR 5865, SAUBY
extern long VDpdmInitPtHull();


int PDUadd_part()
{
    int           max_rows = 0;
    int           sts;
    int		status = PDM_S_SUCCESS; /* PDM status         */
    long          status1 = NFM_S_SUCCESS; /* NFM status         */
    int           responses[3];
    extern struct PDUrefresh	*refresh; /* refresh area form data */
    char          s[250];
    char        * strings[1];
    int           pos = 0;
    int           max_row_length = 0;
    int           select_flag;
    char        * max_row_text = NULL;
    Form          form;
    int           field = 0;
    int           file_col = 0;
    int           strg_file_col = 0;
    int           file_type_col = 0;
    int           columns;
    int           row;
    void          PDMcancel_modify();
    struct  stat file_status;
    mode_t  mode;
    char    dir_entry_name[256];
    char    *save_filename = NULL;
    char    *stg_file = NULL;
    char    *loc_file = NULL;
    char    *msg = NULL;

    _pdm_debug("In the add_part function",0);

    PDUdisable_gadgets_for_add_part();

    strcpy(s, "");
    form = forms.part_operations_form_id;

    if (new_mode == TRUE)
    {
	field = FILE_INFO_MCF;
	file_col = 1;
	strg_file_col = 2;
	file_type_col = 3;
    }
    else if (similar_mode == TRUE)
    {
	field = SIMILAR_MODE_MCF;
	file_col = 2;
	strg_file_col = 3;
	file_type_col = 4;
    }

    status = PDUget_part_field_info();
    _pdm_status("PDMget_part_field_info", status);

    if (status != PDM_S_SUCCESS)
    {
	PDUmessage(status, 's');
	PDUenable_gadgets_after_add_part();
	return(status);
    }

    if (PDM_debug_on)
    {
	MEMprint_buffer("PDU_attr_bufr", PDU_attr_bufr, PDU_DEBUG_FILE);
	MEMprint_buffer("PDU_data_bufr", PDU_data_bufr, PDU_DEBUG_FILE);
    }

    _pdm_debug("checking for necessary file information", 0);
    FIfld_get_num_rows(form, field, &max_rows);
    for (row = 0; row < max_rows; ++row)
    {
	FIfld_get_text_length(form, field, row,strg_file_col, &max_row_length);
	stg_file = (char *)malloc(sizeof(char)*max_row_length+1);
	memset(stg_file,NULL,sizeof (char) * max_row_length + 1);
	FIfld_get_text (form, field, row, strg_file_col,
		max_row_length+1, (unsigned char *)stg_file, &select_flag, &pos );
	_pdm_debug("stg_file = <%s>", stg_file);

	FIfld_get_text_length(form, field, row,file_col, &max_row_length);
	loc_file = (char *)malloc(sizeof(char)*max_row_length+1);
	memset(loc_file,NULL,sizeof (char) * max_row_length + 1);
	FIfld_get_text (form, field, row, file_col,
		max_row_length+1, (unsigned char *)loc_file, &select_flag, &pos );
	_pdm_debug("loc_file = <%s>", loc_file);

	if ((strlen(stg_file)) && (!(strlen(loc_file))))
	{
	    status = PDM_E_ENTER_LOCAL_FILENAME;
	    PDUmessage(PDM_E_ENTER_LOCAL_FILENAME, 's');
	    msg = (char *) PDUtranslate_message(status);
	    FIg_set_text(PDU_form_id,FI_MSG_FIELD, msg);
	    PDUenable_gadgets_after_add_part();
	    return(status);
	}
    }

    /* Check the attribute values to make sure all required attributes
       have a value. */

    status = PDUcheck_for_required_attributes();
    _pdm_status("PDUcheck_for_required_attributes",status);

    if (status != PDM_S_SUCCESS)
    {
	PDUenable_gadgets_after_add_part();
	PDUmessage(status);
	return(status);
    }

    status = MEMbuild_array(PDU_attr_bufr);
    _pdm_status("MEMbuild_array",status);

    if (status != MEM_S_SUCCESS)
    {
	PDUenable_gadgets_after_add_part();
	return(status);
    }

    status = MEMbuild_array(PDU_data_bufr);
    _pdm_status("MEMbuild_array",status);

    if (status != MEM_S_SUCCESS)
    {
	PDUenable_gadgets_after_add_part();
	return(status);
    }

    status1 = NFMRtic_it(PDU_data_bufr);
    _pdm_status("NFMRtic_it",status1);

    if (status1 != NFM_S_SUCCESS)
    {
	PDUenable_gadgets_after_add_part();
	return(status1);
    }

    if (similar_mode == TRUE)
    {
	FIfld_get_num_rows(form, field, &max_rows);

	if (max_rows == 2)
	{
	    FIfld_get_text_length(form,field,1,file_col,&max_row_length);
	    max_row_text = (char *) malloc (sizeof (char)*max_row_length+1);
	    memset(max_row_text,NULL,sizeof (char) * max_row_length + 1);
	    FIfld_get_text (form, field, 1, file_col, max_row_length+1, 
		    (unsigned char *)max_row_text, &select_flag, &pos );
	    if ((max_row_text == NULL) || (strcmp(max_row_text,"") == 0))
		max_rows = 1;

	    if (max_row_text)
	    {
		free (max_row_text);
		max_row_text = NULL;
	    }
	}
    }

    /* Test to see if first row has text. */
    /* We test the local filename col because it is required to 
       add a file. */

    FIfld_get_text_length(form, field, 0,file_col, &max_row_length);
    max_row_text = (char *) malloc (sizeof (char) * max_row_length + 1);
    memset(max_row_text,NULL,sizeof (char) * max_row_length + 1);

    if (new_mode == TRUE)
	FIfld_get_text (form, field, 0, file_col, max_row_length+1, 
		(unsigned char *)max_row_text, &select_flag, &pos );

    if ((similar_mode == TRUE) && (max_rows == 1)) {
	FIfld_get_text (form, field, 0, file_col, max_row_length+1, 
		(unsigned char *)max_row_text, &select_flag, &pos );
    }

    if (((new_mode == TRUE) &&
		((max_row_text == NULL) || (strcmp(max_row_text,"") == 0))) ||
	    ((similar_mode == TRUE) && (max_rows == 1) &&
	     ((max_row_text == NULL) || (strcmp(max_row_text,"") == 0)))) 
    {
	_pdm_debug("No files will be added while adding the part",0);

	_pdm_debug("checking PDU_add_data_bufr", 0);
	if (PDU_add_data_bufr)
	{
	    _pdm_debug("setting PDU_add_data_bufr to NULL", 0);
	    MEMclose(&PDU_add_data_bufr);
	    PDU_add_data_bufr = NULL;
	}

	/* Call the PDM function to add the part */
	status = PDMradd_part (np_project, np_catalog, nn_itemname, np_rev,
		PDU_attr_bufr, PDU_data_bufr,
		PDU_add_data_bufr);
	_pdm_status("PDMradd_part", status);

	PDUenable_gadgets_after_add_part();

	if (status != PDM_S_SUCCESS)
	{
	    _pdm_debug("PDMradd_part was UNsuccessful",0);
	    FIfld_pos_cursor(PDU_form_id,NP_PARTNUM_FLD,0,0,0,0,1,1);
	    PDUmessage(status, 's');
	    return(status);
	}
    }
    else
    {
	PDUmessage(PDS_M_PROCESS_FILE, 's');

	/* call function to read information in file mcf */
	status = PDUget_file_info_for_add_part();
	_pdm_status("PDUget_file_info_for_add_part", status);

	PDUenable_gadgets_after_add_part();

	if (status == NFM_E_MESSAGE)
	    status = PDM_E_FILE_NOT_FOUND;

	if (status != PDM_S_SUCCESS)
	{
	    PDUmessage(status, 's');
	    return(status);
	}

    }

    if (( status != PDM_S_SUCCESS ) && (status != MEM_S_SUCCESS))
    {
	if (PDU_add_data_bufr)
	{
	    MEMclose(&PDU_add_data_bufr);
	    PDU_add_data_bufr = NULL;
	}

	PDU_add_files = FALSE;

	/* Clear out the following fields */
	FIfld_set_text(forms.part_operations_form_id,NP_PARTNUM_FLD,0,0,"", FALSE);
	FIfld_set_text(forms.part_operations_form_id,NP_REV_FLD,0,0,"", FALSE);
	FIfld_set_text(forms.part_operations_form_id,NP_DESC_FLD,0,0,"", FALSE);

	nn_itemname = NULL_STRING;
	np_rev = NULL_STRING;
	np_desc = NULL_STRING;

	refresh->new_partid = NULL_STRING;
	refresh->new_revision = NULL_STRING;
	refresh->new_description = NULL_STRING;

	if (new_mode)
	    columns = 4;
	else
	    columns = 5;

	FIfld_get_num_rows(form,field, &max_rows);
	PDUremove_data(form,field, max_rows,columns);
	FIg_reset(form,field);
	if (new_mode)
	    FIg_display(form,FILE_INFO_GRP);
	else if (similar_mode)
	    FIg_display(form,SIMILAR_MODE_GRP);

	if (similar_mode && ep_parttype &&
		((strcmp(ep_parttype, "N") == 0) ||
		 (strcmp(ep_parttype, "n") == 0)))
	    FIg_disable(form, SIMMODE_COPY_TGL);

	if (similar_mode)
	{
	    FIfld_set_text(PDU_form_id,SIMILAR_MODE_MCF,0,0,"",FALSE);
	    FIfld_set_text(PDU_form_id,SIMILAR_MODE_MCF,0,1,"",FALSE);
	    FIfld_set_text(PDU_form_id,SIMILAR_MODE_MCF,0,2,"",FALSE);
	    FIfld_set_text(PDU_form_id,SIMILAR_MODE_MCF,0,3,"",FALSE);
	    FIfld_set_text(PDU_form_id,SIMILAR_MODE_MCF,0,4,"",FALSE);
	}

	if (similar_mode != TRUE)
	{
	    /* Blank out the ATTRIBUTE_VALUE_MCF */
	    FIfld_get_num_rows(form, ATTRIBUTE_VALUE_MCF,&max_rows);
	    PDUremove_data(form,ATTRIBUTE_VALUE_MCF, max_rows,2);
	}
    }      
    else /* Adding the part was successful */
    {
	PDU_add_files = FALSE;

	 /*-------------------------------------------------------------
	  * SAUBY:  This looks like a good place to insert the AIM stuff.
	  * Try calling just one function with a status to handle all of it.
	  * Pass the function the modes (new, similar) the CPR info, description,
	  * we have the data, we have the spot.
	  * cm_stat is not used further down, but if we decide to cancel the checkin
	  * because the AIM stuff failed, we can do that within this function.
	  * *****************************************/

	if (VDaimIsAimLoaded()) {
	    AIMcmAddPart(new_mode,similar_mode,
		    refresh->rev_catalog,refresh->rev_partid,refresh->rev_revision,
		    refresh->new_catalog,refresh->new_partid,refresh->new_revision
		    );
	}

	/* Copy the part fields of the newly added part to the refresh structure */
	if ((new_mode) || ((similar_mode) && (PDU_simmode_checkin)))
	{
	    int hull_cfg_on = 0;
	    
	    _pdm_debug("copying refresh_new to refresh_rev", 0);
	    PDUfill_in_string(&refresh->rev_project,refresh->new_project);
	    PDUfill_in_string(&refresh->rev_catalog,refresh->new_catalog);
	    PDUfill_in_string(&refresh->rev_partid,refresh->new_partid);
	    PDUfill_in_string(&refresh->rev_revision,refresh->new_revision);
	    PDUfill_in_string(&refresh->rev_parttype,refresh->new_parttype);
	    PDUfill_in_string(&refresh->rev_description,refresh->new_description);

	    /* SAUBY added for JTSMP CR 5865 */
	    // get hull config mode
	    FIg_get_state(form,87,&hull_cfg_on);
	    if (hull_cfg_on) VDpdmInitPtHull();
	}

	if ((similar_mode == TRUE) && (PDU_simmode_checkin == TRUE))
	{
	    _pdm_debug("checking file permissions for checkin", 0);
	    PDUfill_in_string(&save_filename, refresh->act_filename);
	    PDUfill_in_string(&refresh->act_filename, refresh->rev_filename);
	    status = PDUcheck_file_permissions();
	    _pdm_status("PDUcheck_file_permissions", status);
	    if (!status)
	    {
		_pdm_debug("changing file permissions for <%s>",refresh->rev_filename);
		dir_entry_name[0] = '\0';
		strcpy(dir_entry_name, user->wrkst_cwd);
		strcat(dir_entry_name, "/");
		strcat(dir_entry_name, refresh->rev_filename);
		_pdm_debug("changing permissions on <%s>", dir_entry_name);
		status = stat(dir_entry_name, &file_status);
		if (status == 0)
		{
		    /* Change file permissions to read only */
		    mode = S_IRUSR | S_IRGRP | S_IROTH | S_IWUSR | S_IWGRP;
		    status = PDUchmod(dir_entry_name, mode);
		    _pdm_status("PDUchmod", status);
		    if (status != PDM_S_SUCCESS)
			return(status);
		}
	    }
	    PDUfill_in_string(&refresh->act_filename, save_filename);
	    status = PDM_S_SUCCESS;

	    responses[0] = EX_CMD_KEY;
	    strings[0] = "PDChInPr";
	    sts = PDUprepare_queue(responses,strings,1);
	    _pdm_status("PDMprepare_queue (checkin part)",sts);

	    if (status != PDM_S_SUCCESS)
	    {
		// SAUBY, it never gets here, status = PDM_S_SUCCESS was set
		// just above (11 lines up), and has not changed.
		_pdm_debug("The new part was not checked in successfully",0);
		return(status);
	    }
	    else
		_pdm_debug("The new part was checked in successfully",0);

	    status = FIg_enable(PDU_form_id,SIMMODE_CHECKIN_TGL); 
	    status = FIg_set_state_off(PDU_form_id,SIMMODE_COPY_TGL);
	    status = FIg_set_state_off(PDU_form_id,SIMMODE_CHECKIN_TGL);
	    status = FIg_erase(PDU_form_id,SIMMODE_CHECKIN_TGL); 
	    PDU_simmode_checkin = FALSE;
	    PDU_simmode_copy = FALSE;
	}
	else if (similar_mode == TRUE)
	{
	    status = FIg_set_state_off(PDU_form_id,SIMMODE_COPY_TGL);
	    PDU_simmode_copy = FALSE;
	}

	/* Clear out the following fields */

	FIfld_set_text(forms.part_operations_form_id,NP_PARTNUM_FLD,0,0,"", FALSE);
	FIfld_set_text(forms.part_operations_form_id,NP_REV_FLD,0,0,"", FALSE);
	FIfld_set_text(forms.part_operations_form_id,NP_DESC_FLD,0,0,"", FALSE);

	nn_itemname[0] = '\0';
	np_rev[0] = '\0';
	np_desc[0] = '\0';

	refresh->new_partid = NULL_STRING;
	refresh->new_revision = NULL_STRING;
	refresh->new_description = NULL_STRING;

	if (PDU_command == PDC_M_CREATE_TOP_DOWN)
	{
	    _pdm_debug("Deleting part operations form <%x>", forms.part_operations_form_id);
	    new_mode = FALSE;
	    FIf_erase(forms.part_operations_form_id);
	    FIf_delete(forms.part_operations_form_id);
	    forms.part_operations_form_id = 0;
	    /* 4/jun/94 - raj.	*/
	    forms.part_operations_form_id = 0;
	    refresh->status = status;
	    return(status);
	}
    }

   
    /* Clear out the ATTRIBUT VALUE MCF, FILE INFO MCF, and the ACL INFO MCF. */

    status = PDUsamecat_defaults();
    _pdm_status("PDUsamecat_defaults",status);

    if (status != PDM_S_SUCCESS)
    {
	PDUmessage(status,'s');
	FIfld_pos_cursor(PDU_form_id,NP_PARTNUM_FLD,0,0,0,0,0,0);
	return(status);
    }

    PDUmessage(status,'s');

    if (PDU_add_data_bufr)
    {
	MEMclose(&PDU_add_data_bufr);
	PDU_add_data_bufr = NULL;
    }

    FIfld_pos_cursor(PDU_form_id,NP_PARTNUM_FLD,0,0,0,0,1,1);

    _pdm_debug("np_parttype = <%s>", np_parttype);
    _pdm_debug("refresh->new_parttype = <%s>", refresh->new_parttype);
    _pdm_debug("refresh->rev_parttype = <%s>", refresh->rev_parttype);

    return (status);
}

int PDUadd_part_to_project()

  {
    int				status = PDM_S_SUCCESS;
    int				status1 = PDM_S_SUCCESS;
    int                         max_rows;
    int                         * fn;
    MEMptr			attr_bufr = NULL;
    MEMptr			data_bufr = NULL;
    MEMptr			list_bufr = NULL;
    char			*string = NULL;
    char			*msg = NULL;
    extern struct PDUrefresh 	*refresh;
    void                         PDMcancel_modify();

    /* get the table attributes */
    status = PDMget_table_attributes(ADD_TABLE, PDM_PROJECT, 
		refresh->rev_catalog, &attr_bufr, &data_bufr, &list_bufr);
    _pdm_status("PDMget_table_attributes", status);

    if ((status == NFM_E_ITEM_LOCKED) || (status == PDM_E_GET_ATTRIBUTES))
      {
      _pdm_debug("resetting status for locked part in project", 0);
      status = PDM_E_LOCKED_PART_IN_PROJ;
      }

    if (status != PDM_S_SUCCESS)
      {
      PDUmessage(status, 's');
      return(status);
      }

    if (PDM_debug_on)
      {
	MEMprint_buffer("attr_bufr", attr_bufr, PDU_DEBUG_FILE);
	MEMprint_buffer("data_bufr", data_bufr, PDU_DEBUG_FILE);
	MEMprint_buffer("list_bufr", list_bufr, PDU_DEBUG_FILE);
      }

    if (!data_bufr)
      {
      _pdm_debug("data buffer is NULL", 0);
      status = PDM_E_NULL_BUFFER;
      PDUmessage(status, 's');
      return(status);
      }

    if (!attr_bufr)
      {
      _pdm_debug("attr buffer is NULL", 0);
      status = PDM_E_NULL_BUFFER;
      PDUmessage(status, 's');
      return(status);
      }

    /* put the project name, catalog, partid, revision in buffer */
    string = (char *) malloc (data_bufr->row_size);
    memset(string, NULL, (data_bufr->row_size));

    sprintf(string, "Add\1\1%s\1%s\1%s\1%s\1%s\1", refresh->rev_project, refresh->rev_catalog,
		refresh->rev_partid, refresh->rev_revision,"R");

    status = MEMwrite(data_bufr, string);
    _pdm_status("MEMwrite", status);

    if (status != MEM_S_SUCCESS)
      return(PDM_E_WRITE_BUFFER);

    status = PDMadd_part_to_project(attr_bufr, data_bufr);
    _pdm_status("PDMadd_part_to_project", status);

    if (status != PDM_S_SUCCESS)
       {
       PDUmessage(status, 's');
       msg = (char *) PDUtranslate_message(status);
       FIg_set_text(forms.part_operations_form_id,FI_MSG_FIELD, msg);
       }

    status1 = PDMcancel_modify_part(refresh->rev_catalog,
                                   refresh->rev_partid,
                                   refresh->rev_revision,
                                   PDU_attr_bufr, PDU_data_bufr);

    _pdm_status("PDMcancel_modify_part",status1);

    fn = (int *)PDMcancel_modify;
    exitdel(fn);

          /* Clear out the following fields */

    FIfld_set_text(PDU_form_id,EP_PARTNUM_FLD,0,0,"", FALSE);
    FIfld_set_text(PDU_form_id,EP_REV_FLD,0,0,"", FALSE);
    FIfld_set_text(PDU_form_id,EP_DESC_FLD,0,0,"", FALSE);

    refresh->rev_partid = NULL_STRING;
    refresh->rev_revision = NULL_STRING;
    refresh->rev_description = NULL_STRING;
    refresh->rev_filename = NULL_STRING;
    en_itemname = NULL_STRING;
    ep_rev = NULL_STRING;
    ep_desc = NULL_STRING;

    FIfld_get_num_rows(PDU_form_id, ATTRIBUTE_VALUE_MCF,&max_rows);
    PDUremove_data(PDU_form_id,ATTRIBUTE_VALUE_MCF, max_rows,2);

    FIfld_get_num_rows(PDU_form_id,FILE_INFO_MCF, &max_rows);
    PDUremove_data(PDU_form_id,FILE_INFO_MCF, max_rows,3);

    FIfld_set_text(PDU_form_id,STORAGE_AREA_FLD,0,0, "",FALSE);
    FIfld_set_text(PDU_form_id,STATE_NAME_FLD,0,0,"", FALSE);
    FIfld_set_text(PDU_form_id,WORKFLOW_FLD,0,0,"", FALSE);
    FIfld_set_text(PDU_form_id,ACL_NAME_FLD,0,0,"", FALSE);

      /*Enable gadgets that were disable during change_mode because
        the part was locked*/

      FIg_enable(PDU_form_id,EP_PROJECT_FLD);
      FIg_enable(PDU_form_id,EP_CATALOG_FLD);
      FIg_enable(PDU_form_id,EP_PARTNUM_FLD);
      FIg_enable(PDU_form_id,EP_REV_FLD);
      FIg_enable(PDU_form_id,EP_PROJECT_BTN);
      FIg_enable(PDU_form_id,EP_CATALOG_BTN);
      FIg_enable(PDU_form_id,EP_PARTNUM_BTN);
      FIg_enable(PDU_form_id,EP_REV_BTN);

     FIfld_pos_cursor(PDU_form_id,EP_PARTNUM_FLD,0,0,0,0,0,0);

     PDUmessage(status,'s');

    MEMclose(&attr_bufr);
    MEMclose(&data_bufr);

    if (PDU_attr_bufr)
      {
      MEMclose(&PDU_attr_bufr);
      PDU_attr_bufr = NULL;
      }
    if (PDU_data_bufr)
      {
      MEMclose(&PDU_data_bufr);
      PDU_data_bufr = NULL;
      }

    PDUmessage(status, 's');
    return(status);
  }

int PDUget_attachments_for_simmode_copy()
{
  int    status = PDM_S_SUCCESS;
  int    file_col = 0;
  int    cat_col = 0;
  int    catno_col = 0;
  int    part_col = 0;
  int    partno_col = 0;
  int    rev_col = 0;
  int    level_col = 0;
  int    row = 0;
  int    char_index = 0;
  int    level = 0;
  char   *catalogno = NULL;
  char   *catalog = NULL;
  char   *partno = NULL;
  char   *rev = NULL;
  char   *part = NULL;
  char   *file = NULL;
  char   *line = NULL;
  char   *prevcat = NULL_STRING;
  char   *prevpart = NULL_STRING;
  char   *prevrev = NULL_STRING;
  char   **data_row;
  MEMptr assy_bufr = NULL;
  MEMptr attach_bufr = NULL;
  MEMptr status_bufr = NULL;

  _pdm_debug("in the function PDUget_attachments_for_simmode_copy", 0);

  _pdm_debug("retrieving structure of part <%s>", refresh->rev_partid);
  status = PDMget_assembly_structure(refresh->rev_catalog,
            refresh->rev_partid, refresh->rev_revision, 50, &assy_bufr, 0);
  _pdm_status("PDMget_assembly_structure", status);

  if (status != PDM_S_SUCCESS)
    return(status);

  if (!(assy_bufr))
    return(PDM_E_RETRIEVE_ASSEMBLY);

  if ((assy_bufr) && (assy_bufr->rows == 1))
    return(PDM_S_SUCCESS);

  _pdm_debug("setting up assy buffer", 0);
  status = MEMbuild_array(assy_bufr);
  _pdm_status("MEMbuild_array", status);
  if (status != MEM_S_SUCCESS)
    return(PDM_E_BUILD_BUFFER_ARRAY);

  PDUsetup_buffer(assy_bufr, ROW, &data_row);
  status = PDUget_buffer_col(assy_bufr, "p_level", &level_col);
  if (status != PDM_S_SUCCESS)
    return(status);
  status = PDUget_buffer_col(assy_bufr, "n_catalogname", &cat_col);
  if (status != PDM_S_SUCCESS)
    return(status);
  status = PDUget_buffer_col(assy_bufr, "n_ccatalogno", &catno_col);
  if (status != PDM_S_SUCCESS)
    return(status);
  status = PDUget_buffer_col(assy_bufr, "n_citemno", &partno_col);
  if (status != PDM_S_SUCCESS)
    return(status);
  status = PDUget_buffer_col(assy_bufr, "n_itemname", &part_col);
  if (status != PDM_S_SUCCESS)
    return(status);
  status = PDUget_buffer_col(assy_bufr, "n_itemrev", &rev_col);
  if (status != PDM_S_SUCCESS)
    return(status);
  status = PDUget_buffer_col(assy_bufr, "n_cofilename", &file_col);
  if (status != PDM_S_SUCCESS)
    return(status);

  _pdm_debug("formatting attach buffer", 0);
  PDMopen_buffer(7, &attach_bufr);
  line = (char *) malloc (attach_bufr->row_size);

  for (row = 1; row < assy_bufr->rows; ++row)
     {
     memset (line, NULL, attach_bufr->row_size);
     char_index = 0;

     level = atoi(data_row[(assy_bufr->columns * row) + level_col]);
     _pdm_debug("level = %d", (char *) level);
     if (level != 1)
       continue;

     PDUfill_in_string(&catalog, 
                       data_row[(assy_bufr->columns * row) + cat_col]);
     PDUfill_in_string(&part, 
                       data_row[(assy_bufr->columns * row) + part_col]);
     PDUfill_in_string(&rev, 
                       data_row[(assy_bufr->columns * row) + rev_col]);

     if ((strcmp(catalog, prevcat) == 0) &&
         (strcmp(part, prevpart) == 0) &&
         (strcmp(rev, prevrev) == 0))
       {
       _pdm_debug("skipping multiple occurence of part", 0);
       continue;
       }

     PDUfill_in_string(&catalogno, 
                       data_row[(assy_bufr->columns * row) + catno_col]);
     PDUfill_in_string(&partno, 
                       data_row[(assy_bufr->columns * row) + partno_col]);
     PDUfill_in_string(&file, 
                       data_row[(assy_bufr->columns * row) + file_col]);


     if (catalogno)
       PDUadd_buffer_string(line, &char_index, catalogno);
     else
       line[char_index++] = '\1';

     if (partno)
       PDUadd_buffer_string(line, &char_index, partno);
     else
       line[char_index++] = '\1';

     if (catalog)
       PDUadd_buffer_string(line, &char_index, catalog);
     else
       line[char_index++] = '\1';

     if (part)
       PDUadd_buffer_string(line, &char_index, part);
     else
       line[char_index++] = '\1';

     if (rev)
       PDUadd_buffer_string(line, &char_index, rev);
     else
       line[char_index++] = '\1';

     if (file)
       PDUadd_buffer_string(line, &char_index, file);
     else
       line[char_index++] = '\1';

     line[char_index++] = '\1';  /* entry for p_action */

     _pdm_debug("line = <%s>", line);
     status = MEMwrite (attach_bufr, line);
     _pdm_status("MEMwrite", status);
 
     if (status != MEM_S_SUCCESS)
       {
       status = PDM_E_WRITE_BUFFER;
       _pdm_debug("Error writing to attach buffer", 0);
       return(status);
       }

     PDUfill_in_string(&prevcat, catalog);
     PDUfill_in_string(&prevpart, part);
     PDUfill_in_string(&prevrev, rev);
     }

  if (PDMdebug_on)
    MEMprint_buffer("attach_bufr", attach_bufr, PDU_DEBUG_FILE);

  _pdm_debug("calling PDMcopy_attach", 0);
  status = PDMcopy_attach(attach_bufr, &status_bufr);
  _pdm_status("PDMcopy_attach", status);

  if (attach_bufr)
    MEMclose(&attach_bufr);
  if (assy_bufr)
    MEMclose(&assy_bufr);

  if (catalog) free(catalog);
  if (part) free(part);
  if (rev) free(rev);
  if (partno) free(partno);
  if (catalogno) free(catalogno);
  if (file) free(file);
  if (line) free(line);
  if (prevcat) free(prevcat);
  if (prevpart) free(prevpart);
  if (prevrev) free(prevrev);

  return(status);
}

int PDUcheck_for_required_attributes()
{
  int   status = PDM_S_SUCCESS;
  int	i;
  int	n_name_col;
  int	n_syn_col;
  int	n_attr_col = 0;
  int	n_status_col;
  int	n_write_col;
  int	n_update_col;
  int	n_null_col;
  char       ** attr_bufr_row;
  char       ** attr_bufr_col;
  char       ** data_bufr_row;
  char       ** data_bufr_col;
  char          attr_name[250];
  char          syn_name[250];

  _pdm_debug("in the function PDUcheck_for_required_attributes", 0);

  status = MEMbuild_array(PDU_attr_bufr);
  _pdm_status("MEMbuild_array",status);

  if (status != MEM_S_SUCCESS)
     return(status);

  attr_bufr_row = (char **) PDU_attr_bufr->data_ptr;
  attr_bufr_col = (char **) PDU_attr_bufr->column_ptr;

  status = MEMbuild_array(PDU_data_bufr);
  _pdm_status("MEMbuild_array",status);

  if (status != MEM_S_SUCCESS)
     return(status);

  data_bufr_row = (char **) PDU_data_bufr->data_ptr;
  data_bufr_col = (char **) PDU_data_bufr->column_ptr;

  _pdm_debug("resetting n_status", 0);
  status = PDUget_buffer_col(PDU_data_bufr,"n_status",&n_status_col);
  _pdm_status("PDUget_buffer_col",status);
  if (status != PDM_S_SUCCESS)
     return (status);

  status = MEMwrite_data(PDU_data_bufr, NULL_STRING, 1, n_status_col + 1);
  _pdm_status("MEMwrite_data", status);
  if (status != MEM_S_SUCCESS)
    {
    PDUmessage(PDM_E_WRITE_BUFFER, 's');
    return(PDM_E_WRITE_BUFFER);
    }

  status = PDUget_col_number(PDU_attr_bufr,"n_name",attr_bufr_col, &n_name_col);
  _pdm_status("PDUget_col_number",status);

  if (status != PDM_S_SUCCESS)
     return (status);

  status = PDUget_col_number(PDU_attr_bufr,"n_synonym",attr_bufr_col,
                             &n_syn_col);
  _pdm_status("PDUget_col_number",status);

  if (status != PDM_S_SUCCESS)
     return (status);

  status = PDUget_col_number(PDU_attr_bufr,"n_null",attr_bufr_col,
                             &n_null_col);
  _pdm_status("PDUget_col_number",status);

  if (status != PDM_S_SUCCESS)
     return (status);

  if ((new_mode == TRUE) || (similar_mode == TRUE))
     {
     status = PDUget_buffer_col(PDU_attr_bufr,"n_write", &n_write_col);
     _pdm_status("PDUget_buffer_col",status);
     if (status != PDM_S_SUCCESS)
        return (status);
     n_attr_col = n_write_col;
     }
  else if (change_mode == TRUE)
     {
     status = PDUget_col_number(PDU_attr_bufr,"n_update",attr_bufr_col,
                                &n_update_col);
     if (status != PDM_S_SUCCESS)
        return (status);
     n_attr_col = n_update_col;
     }

  for (i = 0; i < PDU_attr_bufr->rows; ++i)
     {
     if (strcmp(attr_bufr_row[(PDU_attr_bufr->columns * i) + n_attr_col],
         "Y") == 0)
        {
        if ((strcmp(attr_bufr_row[(PDU_attr_bufr->columns * i) +
             n_name_col], "n_itemname")) &&
           (strcmp(attr_bufr_row[(PDU_attr_bufr->columns * i) + n_name_col],
                   "n_itemrev")) &&
           (strcmp(attr_bufr_row[(PDU_attr_bufr->columns * i) + n_name_col],
                   "p_parttype")) &&
/*
           (strcmp(attr_bufr_row[(PDU_attr_bufr->columns * i) + n_name_col],
                   "n_itemdesc")) &&
           (strcmp(attr_bufr_row[(PDU_attr_bufr->columns * i) + n_name_col],
                   "n_filetype")) &&
           (strcmp(attr_bufr_row[(PDU_attr_bufr->columns * i) + n_name_col],
                   "p_filedesc")) &&
*/
           (strcmp(attr_bufr_row[(PDU_attr_bufr->columns * i) + n_name_col],
                   "n_aclno")) &&
           (strcmp(attr_bufr_row[(PDU_attr_bufr->columns * i) + n_name_col],
                   "n_cifilename")) &&
           (strcmp(attr_bufr_row[(PDU_attr_bufr->columns * i) + n_name_col],
                   "n_cisano")) &&
           (strcmp(attr_bufr_row[(PDU_attr_bufr->columns * i) + n_name_col],
                   "n_cofilename")))
           {
           if (strcmp(attr_bufr_row[(PDU_attr_bufr->columns * i) + 
               n_null_col], "N") == 0)
              {
              if (strcmp(data_bufr_row[(PDU_data_bufr->columns * 0) + i],
                  "") == 0)
                 {
                 PDU_attr_name = NULL_STRING;
                 if (strcmp(attr_bufr_row[(PDU_attr_bufr->columns * i) +
                     n_syn_col],"") == 0)
                    {
                    strcpy(attr_name,
                           attr_bufr_row[(PDU_attr_bufr->columns * i) +
                           n_name_col]);
                    PDUfill_in_string(&PDU_attr_name, attr_name);
                    _pdm_debug("attr_name = <%s>", PDU_attr_name);
                    }
                 else
                    {
                    strcpy(syn_name,
                           attr_bufr_row[(PDU_attr_bufr->columns * i) +
                                         n_syn_col]);
                    PDUfill_in_string(&PDU_attr_name, syn_name);
                    _pdm_debug("syn_name = <%s>", PDU_attr_name);
                    }
                 status = PDM_E_REQ_ATTR_VALUE;
                 PDUmessage(status,'s');
                 refresh->status = status;
                 FIfld_pos_cursor(forms.part_operations_form_id,
                                  ATTRIBUTE_VALUE_MCF,0,0,0,0,0,0);
                 return(status);
                 }
              }
           }
        } 
     }
  return(status);
}

#define ATTR_MCF	18

int PDUcheck_for_required_attributes2()
{
  int   status = PDM_S_SUCCESS;
  int	i;
  int	n_name_col;
  int	n_syn_col;
  int	n_attr_col = 0;
  int	n_status_col;
  int	n_write_col;
  int	n_null_col;
  char       ** attr_bufr_row;
  char       ** attr_bufr_col;
  char       ** data_bufr_row;
  char       ** data_bufr_col;
  char          attr_name[250];
  char          syn_name[250];

  _pdm_debug("in the function PDUcheck_for_required_attributes2", 0);

  status = MEMbuild_array(PDU_attr_bufr);
  _pdm_status("MEMbuild_array",status);

  if (status != MEM_S_SUCCESS)
     return(status);

  attr_bufr_row = (char **) PDU_attr_bufr->data_ptr;
  attr_bufr_col = (char **) PDU_attr_bufr->column_ptr;

  status = MEMbuild_array(PDU_data_bufr);
  _pdm_status("MEMbuild_array",status);

  if (status != MEM_S_SUCCESS)
     return(status);

  data_bufr_row = (char **) PDU_data_bufr->data_ptr;
  data_bufr_col = (char **) PDU_data_bufr->column_ptr;

  _pdm_debug("resetting n_status", 0);
  status = PDUget_buffer_col(PDU_data_bufr,"n_status",&n_status_col);
  _pdm_status("PDUget_buffer_col",status);
  if (status != PDM_S_SUCCESS)
     return (status);

  status = MEMwrite_data(PDU_data_bufr, NULL_STRING, 1, n_status_col + 1);
  _pdm_status("MEMwrite_data", status);
  if (status != MEM_S_SUCCESS)
    {
    PDUmessage(PDM_E_WRITE_BUFFER, 's');
    return(PDM_E_WRITE_BUFFER);
    }

  status = PDUget_col_number(PDU_attr_bufr,"n_name",attr_bufr_col, &n_name_col);
  _pdm_status("PDUget_col_number",status);

  if (status != PDM_S_SUCCESS)
     return (status);

  status = PDUget_col_number(PDU_attr_bufr,"n_synonym",attr_bufr_col,
                             &n_syn_col);
  _pdm_status("PDUget_col_number",status);

  if (status != PDM_S_SUCCESS)
     return (status);

  status = PDUget_col_number(PDU_attr_bufr,"n_null",attr_bufr_col,
                             &n_null_col);
  _pdm_status("PDUget_col_number",status);

  if (status != PDM_S_SUCCESS)
     return (status);

  status = PDUget_buffer_col(PDU_attr_bufr,"n_write", &n_write_col);
  _pdm_status("PDUget_buffer_col",status);
  if (status != PDM_S_SUCCESS)
    return (status);
  n_attr_col = n_write_col;

  for (i = 0; i < PDU_attr_bufr->rows; ++i)
     {
     if (strcmp(attr_bufr_row[(PDU_attr_bufr->columns * i) + n_attr_col],
         "Y") == 0)
        {
        if ((strcmp(attr_bufr_row[(PDU_attr_bufr->columns * i) +
             n_name_col], "n_itemname")) &&
           (strcmp(attr_bufr_row[(PDU_attr_bufr->columns * i) + n_name_col],
                   "n_itemdesc")) &&
           (strcmp(attr_bufr_row[(PDU_attr_bufr->columns * i) + n_name_col],
                   "n_itemrev")) &&
           (strcmp(attr_bufr_row[(PDU_attr_bufr->columns * i) + n_name_col],
                   "n_cifilename")) &&
           (strcmp(attr_bufr_row[(PDU_attr_bufr->columns * i) + n_name_col],
                   "n_cofilename")))
           {
           if (strcmp(attr_bufr_row[(PDU_attr_bufr->columns * i) + 
               n_null_col], "N") == 0)
              {
              if (strcmp(data_bufr_row[(PDU_data_bufr->columns * 0) + i],
                  "") == 0)
                 {
                 PDU_attr_name = NULL_STRING;
                 if (strcmp(attr_bufr_row[(PDU_attr_bufr->columns * i) +
                     n_syn_col],"") == 0)
                    {
                    strcpy(attr_name,
                           attr_bufr_row[(PDU_attr_bufr->columns * i) +
                           n_name_col]);
                    PDUfill_in_string(&PDU_attr_name, attr_name);
                    _pdm_debug("attr_name = <%s>", PDU_attr_name);
                    }
                 else
                    {
                    strcpy(syn_name,
                           attr_bufr_row[(PDU_attr_bufr->columns * i) +
                                         n_syn_col]);
                    PDUfill_in_string(&PDU_attr_name, syn_name);
                    _pdm_debug("syn_name = <%s>", PDU_attr_name);
                    }
                 status = PDM_E_REQ_ATTR_VALUE;
                 PDUmessage(status,'s');
                 refresh->status = status;
                 FIfld_pos_cursor(PDU_form_id, ATTR_MCF,0,0,0,0,0,0);
                 return(status);
                 }
              }
           }
        } 
     }
  return(status);
}
