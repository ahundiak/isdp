#include <stdio.h>
#include "PDUextdef.h"
#include "MEMstruct.h"
#include <PDMcommand.h>
#include "PDUerror.h"
#include "PDUsts_st.h"
#include "MEMerrordef.h"
#include "PDUfile_def.h"
#include "PDMtypes.h"
#include "NFMapi.h"
#include <PDMmessage.h>
#include "part_gadgets.h"
#include "PDUforms.h"
#include "PDUform_def.h"
#include "NFMerrordef.h"
#include "PDUproto.h"
#include "PDMproto.h"
#include "PDUprtdyn.h"

static char s[1024];
static int status;
extern PDUsts_ptr PDUsts;
extern int PDMdebug_on;
extern char PDU_DEBUG_FILE[80];
extern MEMptr PDU_ret_bufr;
extern MEMptr PDU_file_bufr;
extern MEMptr PDU_add_bufr;
extern MEMptr PDU_add_data_bufr;
extern MEMptr PDU_hold_bufr;
extern struct PDUrefresh  *refresh;
extern int    bufr_flag;
extern int    new_mode;
extern int    similar_mode;
extern int    change_mode;
extern int    review_mode;
extern short  PDU_main_form_cat;
extern struct   PDUforms   forms;
extern Form     PDU_form_id;

/* Globals */

extern MEMptr       PDU_copyof_ret_bufr;
extern MEMptr       PDU_states_bufr;
extern MEMptr       add_data_bufr;

extern struct part_dynamic_attrs *part_occur_list;


int PDMverify_project(project,catalog)
  char          *project;
  char          *catalog;
  {
        sprintf (s, "PDMverify_project: project = <%s>\n", project);
        _pdm_debug(s, 0);

        /* Display Message */
        PDUmessage(PDS_M_VERIFY_PROJECT, 's');

	/* load exec structure */
        if (!change_mode)
          PDUload_exec_structure(project, catalog,"MAP", "", "","","",0, 0);
        else
          PDUload_exec_structure(project, catalog,"", "", "","","",0, 0);

        _pdm_debug("calling PDMsverify_project", 0);
        status = PDMsverify_project();
        _pdm_status("PDMsverify_project", status);

        /* DIsplay Message */
        PDUmessage(PDM_E_CLEAR_FIELD,'s');

        return (status);
  }

/* THIS FUNCTION VERIFIES THE EXISTENCE OF A CATALOG

    PDM_S_SUCCESS                       if catalog exists
    PDM_E_CATALOG_NOT_FOUND             if catalog can not be found

    Any other return code can be construed as a failure
    not related to the functionality
*/

int PDMrverify_catalog(project,catalog)

  char          *project;
  char          *catalog;

  {
        sprintf (s, "PDMrverify_catalog: catalog = <%s>\n", catalog);
        _pdm_debug(s, 0);
        sprintf (s, "PDMrverify_catalog: project = <%s>\n", project);
        _pdm_debug(s, 0);

          if (PDU_ret_bufr != NULL)
             {
             MEMclose(&PDU_ret_bufr);
             PDU_ret_bufr = NULL;
             }

       /* Display Message */
       if (PDU_form_id != forms.rev_assy_form_id)
         PDUmessage(PDS_M_VERIFY_CATALOG, 's');
       else
         PDUmessage(PDS_M_GET_TABLE_ATTR, 's');

        /* Test if verifying catalog from main form */
        if (PDU_main_form_cat == TRUE)
        {
        _pdm_debug("entering case for PDU_main_form_cat = TRUE", 0);
        /* load the exec structure */
        PDUload_exec_structure(project, catalog, "", "", "","","",0, 0);

        _pdm_debug("calling PDMverify_catalog", 0);
        status = PDMverify_catalog(&PDU_ret_bufr);
        _pdm_status("PDMverify_catalog", status);

        if (status != PDM_S_SUCCESS)
          {
          if (status == SQL_I_NO_ROWS_FOUND)
            status = PDM_E_CATALOG_NOT_FOUND;
          PDUmessage(status, 's');
          return(status);
          }

        PDU_main_form_cat = FALSE;
        }
        else if (bufr_flag == FALSE)
        {
	/* load the exec structure */
        PDUload_exec_structure(project, catalog, "", "", "","","",0, 0);

        _pdm_debug("calling PDMverify_catalog", 0);
	status = PDMverify_catalog(&PDU_ret_bufr);
        _pdm_status("PDMverify_catalog", status);

	if (status != PDM_S_SUCCESS)
          {
          if (status == SQL_I_NO_ROWS_FOUND)
            status = PDM_E_CATALOG_NOT_FOUND;
          PDUmessage(status, 's');
          return(status);
          }
        }
        else
        {
	  /* load the exec structure */
          PDUload_exec_structure(project, catalog, "ADDPART","","","","",0, 0);
  
          _pdm_debug("calling PDMverify_catalog", 0);
          status = PDMverify_catalog(&PDU_ret_bufr);
          _pdm_status("PDMverify_catalog", status);
  
          if (status != PDM_S_SUCCESS)
            {
            if (status == SQL_I_NO_ROWS_FOUND)
              status = PDM_E_CATALOG_NOT_FOUND;
            PDUmessage(status, 's');
            return(status);
            }
  
          if (PDU_ret_bufr)
             {
             _pdm_debug("copying PDU_ret_bufr to PDU_copyof_ret_bufr", 0);
             MEMsplit_copy_buffer(PDU_ret_bufr, &PDU_copyof_ret_bufr, 1);
             }
	  else
             _pdm_debug("PDU_RET_BUFR IS NULL!!!!!!!!!", 0);

          if (PDMdebug_on)  
             MEMprint_buffers("PDU_RET_BUFR",PDU_ret_bufr,PDU_DEBUG_FILE);
       }

  /* DIsplay Message */
  PDUmessage(PDM_E_CLEAR_FIELD,'s');

  return(PDM_S_SUCCESS);
  }


/* This function checks the existence of a part given the catalog, part number,
   and revision. */
/* It is used to assure that a user will not try to add an existing part to the
   system or change a part that does not exist. */
/* PDM will use the PDMquery_part_info function to accomplish this */

int PDMcheck_partnum(catalog,partnum,revision)

   char *catalog;
   char *partnum;
   char *revision;

{
	int status = PDM_S_SUCCESS;

        sprintf (s, "Enter command: PDMcheck_partnum\n");
        _pdm_debug(s, 0);

       /* Display Message */
       PDUmessage(PDS_M_CHECK_PARTNUM, 's');

	/* load exec structure */
        PDUload_exec_structure("",catalog,partnum,revision, "","","",0, 0);

        if (PDU_ret_bufr != NULL)
        {
        MEMclose(&PDU_ret_bufr);
        PDU_ret_bufr = NULL;
        }

        /* call PDM function */
        _pdm_debug("calling PDMquery_part_info", 0);
        status = PDMquery_part_info(&PDU_ret_bufr);
        _pdm_status("PDMquery_part_info", status);
        if (PDU_form_id != forms.rev_assy_form_id)
          {
          if (status != PDM_S_SUCCESS)
            {
            PDUmessage(status, 's');
            return(status);
            }
          }

        /* DIsplay Message */
        PDUmessage(PDM_E_CLEAR_FIELD,'s');

      return (status);
}

/* This function sends the catalog and part number to PDM which will return a
   buffer containing the latest revision, part type, and description of the 
   part if it is contained within the catalog. */
/* PDM will user the function PDMget_part_info. */

int PDMverify_partnum(catalog,partnum)

  char  *catalog;
  char  *partnum;

{  
	int status = PDM_S_SUCCESS;

        sprintf (s, "Enter command: PDMverify_partnum\n");
        _pdm_debug(s, 0);

       /* Display Message */
       PDUmessage(PDS_M_VERIFY_PARTNUM, 's');

	/* load exec structure */
	PDUload_exec_structure("", catalog, partnum, "", "","","",0, 0);

   	if (PDU_ret_bufr != NULL)
      	{
      	MEMclose(&PDU_ret_bufr);
      	PDU_ret_bufr = NULL;
      	}

	/* call PDM function */
        _pdm_debug("calling PDMget_part_info", 0);
	status = PDMget_part_info(&PDU_ret_bufr);
	_pdm_status("PDMget_part_info", status);

	if (status != PDM_S_SUCCESS)
	  {
	  PDUmessage(status, 's');
	  return(status);
          }

   if (PDMdebug_on)
      MEMprint_buffer("PDU_RET_BUFFER in verify_partnum",PDU_ret_bufr,
                       PDU_DEBUG_FILE);
   /* DIsplay Message */
        PDUmessage(PDM_E_CLEAR_FIELD,'s');

   return (status);

} 

/* This will return the Attribute buffer and the Data buffer */
/* This is used when the mode of operations is similar and the user is entering
   an existing part. This is because the data other than values will come from
   the new part catalog that is or will be entered during this mode. */
/* PDM will use the function: PDMget_table_data */

int PDMget_part_data(catalog,partnum,revision)

   char  *catalog;
   char  *partnum;
   char  *revision;

{
	int status = PDM_S_SUCCESS;

        sprintf (s, "Enter command: PDMget_part_data\n");

        _pdm_debug(s, 0);

       /* Display Message */
       PDUmessage(PDS_M_GET_TABLE_DATA, 's');

	/* load exec structure */
        PDUload_exec_structure("", catalog, partnum, revision, "","","",
			       QUERY_INFO, PDM_PART);

        if (PDU_ret_bufr != NULL)
        {
        MEMclose(&PDU_ret_bufr);
        PDU_ret_bufr = NULL;
        }

        /* call PDM function */
        _pdm_debug("calling PDMsget_table_data", 0);
        status = PDMsget_table_data1(&PDU_ret_bufr);
        _pdm_status("PDMsget_table_data", status);

        if (status != PDM_S_SUCCESS)
          {
          PDUmessage(status, 's');
          return(status);
          }

   if (PDMdebug_on)
      MEMprint_buffers("PDU_ret_bufr in PDMget_part_data",PDU_ret_bufr,PDU_DEBUG_FILE);

   if (PDU_hold_bufr)
     {
     MEMclose(&PDU_hold_bufr);
     PDU_hold_bufr = NULL;
     }

   MEMsplit_copy_buffer(PDU_ret_bufr, &PDU_hold_bufr, 1);

   if (PDMdebug_on)
      MEMprint_buffers("PDU_hold_bufr",PDU_hold_bufr, PDU_DEBUG_FILE);

        /* DIsplay Message */
        PDUmessage(PDM_E_CLEAR_FIELD,'s');

   return (status);
} 

/* This will return the Attribute buffer, Data buffer, and List buffer */
/* This is used when the mode of operations is change or review. All 
   information on the part form at this time will be from the existing part. */
/* PDM will use the function: PDMquery_item_attr_info */

int PDMget_existing_data(catalog,partnum,revision)

   char  *catalog;
   char  *partnum;
   char  *revision;

{
        sprintf (s, "Enter command: PDMget_existing_data\n");
        _pdm_debug(s, 0);

        PDUmessage(PDS_M_GET_TABLE_DATA,'s');

/* STAN I moved the getting of the attribute information to be the last thing
   you do */

   /*  Send the command to PDM to get second buffer for multiple file per item.
       This buffer will contain a file attribute buffer, file data buffer, and
       file list buffer.  THIS BUFFER IS FOR CHANGE.*/

   /* load exec structure */
   if (change_mode == TRUE)
    PDUload_exec_structure("", catalog, partnum, revision, "", "","",0,
                           NFM_CHANGE_FILE_INFORMATION);
   else if (review_mode || similar_mode)
    {
    _pdm_debug("loading entity with PDM_REVIEW_PART_INFORMATION", 0);
    PDUload_exec_structure("", catalog, partnum, revision, "", "","",0,
                           PDM_REVIEW_PART_INFORMATION); 
    }
   
   if (PDU_file_bufr != NULL)
      {
      MEMclose(&PDU_file_bufr);
      PDU_file_bufr = NULL;
      }

   _pdm_debug("calling PDMprepare_file_info", 0);
   status = PDMprepare_file_info(&PDU_file_bufr);
   _pdm_status("PDMprepare_file_info", status);

   if (review_mode)
     {
     if ((status == NFM_E_DFI_COUSER) ||
         (status == PDM_E_PART_FLAGGED_FOR_ARCHIVE) ||
         (status == PDM_E_PART_FLAGGED_FOR_RESTORE) ||
         (status == PDM_E_PART_FLAGGED_FOR_BACKUP) ||
         (status == NFM_E_ITEM_FLAGGED) ||
         (status == PDM_E_PART_FLAGGED_FOR_DELETE))
       {
       _pdm_debug("setting status to SUCCESS for review_mode", 0);
       status = PDM_S_SUCCESS;
       }
     }
   else if ((status == NFM_E_DFI_COUSER) && (!review_mode))
     status = PDM_E_CHECKOUT_USER;

   if ((PDMdebug_on) && (PDU_file_bufr))
      MEMprint_buffers("The PDU_FILE_BUFR inside PDMget_existing_data",
                       PDU_file_bufr,PDU_DEBUG_FILE);

   if (status == NFM_E_NO_ITEM_FILES_FOUND)
      {
      PDUmessage(status, 's');
      _pdm_debug("no files associated with part; continue", 0);
      if (PDU_file_bufr != NULL)
         {
         MEMclose(&PDU_file_bufr);
         PDU_file_bufr = NULL;
         }
      }
   else if (status != PDM_S_SUCCESS)
      {
      PDUmessage(status, 's');
      if (PDU_file_bufr != NULL)
         {
         MEMclose(&PDU_file_bufr);
         PDU_file_bufr = NULL;
         }
      return(status);
      }

   /* I am not returning an unsuccessful status with PDU_file_bufr if it is
      empty because I still need the PDU_add_bufr */

   /*  Send the command to PDM to get third buffer for multiple file per item.

       This buffer will contain a file attribute buffer, file data buffer, and
       file list buffer.  THIS BUFFER IS FOR ADD.*/

   if ((change_mode == TRUE) || (review_mode == TRUE))
      {
      /* load exec structure */
      if (change_mode)
        PDUload_exec_structure("", catalog, partnum, revision, "", "","",0,
                               NFM_ADD_FILE_TO_ITEM);
      else
        {
        _pdm_debug("loading entity with PDM_REVIEW_PART_INFORMATION", 0);
        PDUload_exec_structure("", catalog, partnum, revision, "", "","",0,
                           PDM_REVIEW_PART_INFORMATION); 
        }

      if (PDU_add_bufr != NULL)
         {
         MEMclose(&PDU_add_bufr);
         PDU_add_bufr = NULL;
         }

      _pdm_debug("calling PDMprepare_file_info to get third buffer", 0);
      status = PDMprepare_file_info(&PDU_add_bufr);
      _pdm_status("PDMprepare_file_info", status);
  
      if ((status == NFM_E_NO_ITEM_FILES_FOUND) ||
          (status == NFM_E_DFI_NO_W))
        {
        _pdm_debug("resetting status to SUCCESS", 0);
        status = PDM_S_SUCCESS;
        }
      else if ((status == NFM_E_DFI_COUSER) && (review_mode == FALSE))
        status = PDM_E_CHECKOUT_USER;
      else if ((status == NFM_E_DFI_NO_W_COFILENAME) && (change_mode))
        {
        _pdm_debug("setting status to SUCCESS for change_mode", 0);
        status = PDM_S_SUCCESS;
        }
      else if (review_mode)
        {
        if ((status == NFM_E_DFI_COUSER) ||
            (status == PDM_E_PART_FLAGGED_FOR_ARCHIVE) ||
            (status == PDM_E_PART_FLAGGED_FOR_RESTORE) ||
            (status == PDM_E_PART_FLAGGED_FOR_BACKUP) ||
            (status == NFM_E_ITEM_FLAGGED) ||
            (status == PDM_E_PART_FLAGGED_FOR_DELETE))
          {
          _pdm_debug("setting status to SUCCESS for review_mode", 0);
          status = PDM_S_SUCCESS;
          }
        }

      if ((PDMdebug_on) && (PDU_add_bufr))
         MEMprint_buffers("The PDU_ADD_BUFR inside PDMget_existing_data",
                          PDU_add_bufr,PDU_DEBUG_FILE);

     if (status != PDM_S_SUCCESS)
        {
        PDUmessage(status, 's');
        if (PDU_add_bufr != NULL)
           {
           MEMclose(&PDU_add_bufr);
           PDU_add_bufr = NULL;
           }
        return(status);
        }
      }

   /*  Send the command to PDM to get first buffer for multiple file per item.
       This buffer will contain a part attribute buffer, part data buffer, and
       part list buffer. */

       /* Display Message */
       PDUmessage(PDS_M_GET_TABLE_DATA, 's');

   if ((change_mode == TRUE) || (review_mode == TRUE))
      /* load exec structure */
      PDUload_exec_structure("", catalog, partnum, revision, "","","",0,0);

   if (PDU_ret_bufr != NULL)
      {
      MEMclose(&PDU_ret_bufr);
      PDU_ret_bufr = NULL;
      }

   _pdm_debug("calling PDMqry_catalog_attributes", 0);

   if (change_mode == TRUE)
      {
      status = PDMqry_catalog_attributes("U",&PDU_ret_bufr);
      _pdm_status("PDMqry_catalog_attributes",status);
      }
   else if (review_mode == TRUE)
      {
      status = PDMqry_catalog_attributes("R",&PDU_ret_bufr);
      _pdm_status("PDMqry_catalog_attributes",status);
      }

   if (status == NFM_E_NO_ACLS_FOUND)
     status = PDM_E_NOT_ACL_USER;

   if (status != PDM_S_SUCCESS)
     {
     PDUmessage(status, 's');
     if (PDU_ret_bufr != NULL)
        {
        MEMclose(&PDU_ret_bufr);
        PDU_ret_bufr = NULL;
        }
     return(status);
     }

   if (PDMdebug_on)
      MEMprint_buffers("PDU_ret_bufr in PDMget_existing_data",PDU_ret_bufr,
                        PDU_DEBUG_FILE);

   if (PDU_hold_bufr)
     {
     MEMclose(&PDU_hold_bufr);
     PDU_hold_bufr = NULL;
     }

   MEMsplit_copy_buffer(PDU_ret_bufr, &PDU_hold_bufr, 1);

   if (PDMdebug_on)
      MEMprint_buffers("PDU_hold_bufr",PDU_hold_bufr, PDU_DEBUG_FILE);

        /* DIsplay Message */
        PDUmessage(PDM_E_CLEAR_FIELD,'s');

   return (status);
}

/* This function will return a PDU_add_data_bufr */

int PDMget_add_buffer(catalog,partnum,revision)

   char  *catalog;
   char  *partnum;
   char  *revision;

{
   int status = PDM_S_SUCCESS;

   sprintf (s, "Enter command: PDMget_add_buffer\n");
   _pdm_debug(s, 0);

   PDUmessage(PDS_M_GET_TABLE_DATA,'s');

   /* load exec structure */
   PDUload_exec_structure("", catalog, partnum, revision, "", "","", 0,
			  NFM_ADD_FILE_TO_ITEM);

   if (add_data_bufr != NULL)
      {
      MEMclose(&add_data_bufr);
      add_data_bufr = NULL;
      }

   _pdm_debug("calling PDMadd_file_bufr", 0);
   status = PDMadd_file_bufr(&add_data_bufr);
   _pdm_status("PDMadd_file_bufr", status);

   if (status != PDM_S_SUCCESS)
     {
     PDUmessage(status, 's');
     return(status);
     }

   if ((PDMdebug_on) && (add_data_bufr))
      MEMprint_buffers("add_data_bufr in PDMget_add_buffer",
                       add_data_bufr,PDU_DEBUG_FILE);
   else
      _pdm_debug("add data buffer is NULL", 0);
 
return(status);
}

/* This function will send the project, catalog, partnum, and revision to PDM
   to check wether the part is in the project. */
/* PDM will use the function: PDMcatalogs_of_proj_part */

int PDMpart_in_project(project,catalog,partnum,revision)

   char  *project;
   char  *catalog;
   char  *partnum;
   char  *revision;

{
        sprintf (s, "Enter command: PDMpart_in_project\n");
        _pdm_debug(s, 0);
   
       /* Display Message */
       PDUmessage(PDS_M_PART_IN_PROJ, 's');

       /* load exec structure */
       PDUload_exec_structure(project, catalog, partnum, revision,"","","",0,0);

       _pdm_debug("calling PDMcatalogs_of_proj_part", 0);
       status = PDMcatalogs_of_proj_part();
       _pdm_status("PDMcatalogs_of_proj_part", status);

       if (status != PDM_S_SUCCESS)
         {
         PDUmessage(status, 's');
         return(status);
         }

        /* DIsplay Message */
        PDUmessage(PDM_E_CLEAR_FIELD,'s');

   return (status);

} 
/* This function send a catalog and description to PDM and expects to receive
   a buffer containing the partnum, revision, and part type back. There may
   be more than one part with the given description. */

int PDMget_part_from_desc(catalog,description)

   char  *catalog;
   char  *description;

{
        sprintf (s, "Enter command: PDMget_part_from_desc\n");
        _pdm_debug(s, 0);


       /* Display Message */
       PDUmessage(PDS_M_PART_FROM_DESC, 's');

       /* load exec structure */
       PDUload_exec_structure("", catalog, description, "", "","","",0, 0);

       if (PDU_ret_bufr != NULL)
          {
          MEMclose(&PDU_ret_bufr);
          PDU_ret_bufr = NULL;
          }

       _pdm_debug("calling PDMget_part_rev_type", 0);
       status = PDMget_part_rev_type(&PDU_ret_bufr);
       _pdm_status("PDMget_part_rev_type", status);

       if (status != PDM_S_SUCCESS)
         {
         PDUmessage(status, 's');
         return(status);
         }

        /* DIsplay Message */
        PDUmessage(PDM_E_CLEAR_FIELD,'s');

   return (status);
}

/* This function retrieves a buffer containing the part type and description
   associated with the catalog, part number and new (existing) revision that
   the user entered. */

   int PDMget_pt_desc(catalog,part,rev)

       char  *catalog;
       char  *part;
       char  *rev;

{
        sprintf (s, "Enter command: PDMget_pt_desc\n");
        _pdm_debug(s, 0);

       /* load exec structure */
       PDUload_exec_structure("", catalog, part, rev, "","","",0, 0);

       if (PDU_ret_bufr != NULL)
          {
          MEMclose(&PDU_ret_bufr);
          PDU_ret_bufr = NULL;
          }

       _pdm_debug("calling PDMget_part_type_desc", 0);
       status = PDMget_part_type_desc(&PDU_ret_bufr);
       _pdm_status("PDMget_part_type_desc", status);

       if (status != PDM_S_SUCCESS)
         {
         PDUmessage(status, 's');
         return(status);
         }

        /* DIsplay Message */
        PDUmessage(PDM_E_CLEAR_FIELD,'s');

   return (status);
}

/* This function sends a buffer with a search string consisting of a part
   number or description and/or a project and returns a list of catalogs
   pertaining to the given criteria. The sort string orders the catalogs
   by name. */

int PDMcatalog_list(project, search_str)

   char  *project;
   char  *search_str;

{
   MEMptr buffer = NULL;
   char *  line;

        sprintf (s, "Enter command: PDMcatalog_list\n");
        _pdm_debug(s, 0);

   MEMopen(&buffer,512);

   MEMwrite_format(buffer,"loc_search","char(25)");
   MEMwrite_format(buffer,"loc_sort","char(25)");
   MEMwrite_format(buffer,"cat_search","char(100)");
   MEMwrite_format(buffer,"cat_sort","char(14)");

   line = (char*)malloc(sizeof(char) * buffer->row_size);
 
   sprintf(line,"\1\1%s\1\1",search_str);
   MEMwrite(buffer,line);  

   if (PDMdebug_on)
      MEMprint_buffer("CATALOG_LIST BUFFER",buffer,PDU_DEBUG_FILE);

       /* Display Message */
       PDUmessage(PDS_M_CATALOG_LIST, 's');

   /* load exec structure */
   PDUload_exec_structure(project, "", "", "", "","","",0, 0);

   if (PDU_ret_bufr != NULL)
      {
      MEMclose(&PDU_ret_bufr);
      PDU_ret_bufr = NULL;
      }

   _pdm_debug("calling PDMsearch_for_parts", 0);
   status = PDMsearch_for_parts(buffer, &PDU_ret_bufr);
   _pdm_status("PDMsearch_for_parts", status);

   if (status == PDM_E_SEARCH_CATALOG)
      return(PDM_E_PART_NOT_FOUND);

   if (PDU_ret_bufr == NULL)
      return(PDM_E_NULL_BUFFER);

   if ((PDU_ret_bufr != NULL) && (PDMdebug_on))
      MEMprint_buffer("PDU_RET_BUFR in PDMcatalog_list",PDU_ret_bufr,PDU_DEBUG_FILE);

        /* DIsplay Message */
        PDUmessage(PDM_E_CLEAR_FIELD,'s');

   return (status);
}

/* This function returns a list of projects or catalogs. */

int PDMproject_catalog_listing(project,catalog,flag)

   char  *project;
   char  *catalog;
   char  *flag;

{
        sprintf (s, "Enter command: PDMproject_catalog_listing\n");
        _pdm_debug(s, 0);
        sprintf (s, "Flag %s\n",flag);
        _pdm_debug(s, 0);


       if (PDU_ret_bufr != NULL)
          {
          MEMclose(&PDU_ret_bufr);
          PDU_ret_bufr = NULL;
          }

       /* Display Message */
       PDUmessage(PDS_M_PROJ_OF_CAT_LIST, 's');

      /* load PDMexec structure */
      PDUload_exec_structure(project, catalog, "", "", "","","",0, 0);

   /* This will give a list of all projects */
   if ((strcmp(project,"") == 0) && (strcmp(catalog,"") == 0) &&
       (strcmp(flag,"proj_list") == 0))
      {
      _pdm_debug("calling PDMlist_of_projects", 0);
      status = PDMlist_of_projects(&PDU_ret_bufr);
      _pdm_status("PDMlist_of_projects", status);
      }

   /* This will give a list of all catalogs */
   else if ((strcmp(project,"") == 0) && (strcmp(catalog,"") == 0) &&
            (strcmp(flag,"cat_list") == 0))
      {
      status = PDMcatalogs_in_project(&PDU_ret_bufr);
      _pdm_status("PDMcatalogs_in_project", status);
      }

   /* This will give a list of projects that are associated with the catalog. */
   else if ((strcmp(project,"") == 0) && (strcmp(catalog,"") != 0))
      {
      status = PDMprojects_of_catalog(&PDU_ret_bufr);
      _pdm_status("PDMprojects_of_catalog", status);
      }

   /* This will give a list of catalogs that are associated with the project. */
   else if ((strcmp(project,"") != 0) && (strcmp(catalog,"") == 0))
      {
      status = PDMcatalogs_in_project(&PDU_ret_bufr);
      _pdm_status("PDMcatalogs_in_project", status);
      }

   if (status != PDM_S_SUCCESS)
     {
     PDUmessage(status, 's');
     return(status);
     }

   if (PDMdebug_on)
   MEMprint_buffer("PDU_RET_BUFR in PDMproject_catalog_listing",PDU_ret_bufr,
                    PDU_DEBUG_FILE);

        /* DIsplay Message */
        PDUmessage(PDM_E_CLEAR_FIELD,'s');

   return (status);
}
   
/* This function returns a list of parts, their revisions, their part types,
   and their descriptions that are contained within the entered catalog. */

int PDMparts_listing(catalog)

   char  *catalog;

{
	int status = PDM_S_SUCCESS;

        sprintf (s, "Enter command: PDMpart_listing\n");
        _pdm_debug(s, 0);


	if (PDU_ret_bufr != NULL)
           {
           MEMclose(&PDU_ret_bufr);
           PDU_ret_bufr = NULL;
           }

       /* Display Message */
       PDUmessage(PDS_M_SHOW_PARTS, 's');

       /* load exec structure */
       PDUload_exec_structure("",catalog, "", "", "","","",0, 0);

       _pdm_debug("calling PDMshow_parts", 0);
       status = PDMshow_parts(&PDU_ret_bufr);
       _pdm_status("PDMshow_parts", status);

       if (status != PDM_S_SUCCESS)
         {
         PDUmessage(status, 's');
         return(status);
	 }

   if (PDMdebug_on)
      MEMprint_buffer("PDU_ret_bufr in PDMparts_listing",PDU_ret_bufr,PDU_DEBUG_FILE);

        /* DIsplay Message */
        PDUmessage(PDM_E_CLEAR_FIELD,'s');

   return (status);
}
   
/* This function returns a list of revisions given the catalog and part 
   number. 
   PDM should use the function PDMget_rev. */

int PDMrev_listing(catalog,partnum)

   char  *catalog;
   char  *partnum;

{
          sprintf (s, "Enter command: PDMrev_listing\n");
        _pdm_debug(s, 0);
 

       /* Display Message */
       PDUmessage(PDS_M_GET_REVS, 's');

       /* load exec structure */
       PDUload_exec_structure("",catalog, partnum, "", "","","",0, 0);

       if (PDU_ret_bufr != NULL)
          {
          MEMclose(&PDU_ret_bufr);
          PDU_ret_bufr = NULL;
          }

       _pdm_debug("calling PDMget_rev", 0);
       status = PDMget_rev(&PDU_ret_bufr);
       _pdm_status("PDMget_rev", status);

       if (status != PDM_S_SUCCESS)
         {
         PDUmessage(status, 's');
         return(status);
         }

   if (PDMdebug_on)
      MEMprint_buffer("PDU_ret_bufr inside PDMrev_listing",PDU_ret_bufr,
                       PDU_DEBUG_FILE);

        /* DIsplay Message */
        PDUmessage(PDM_E_CLEAR_FIELD,'s');

   return (status);
}

/* This function will send the catalog name and receive a list of part
   descriptions. */
/* PDM should use the function PDMget_desc. */

int PDMdescription_list(catalog)

   char  *catalog;

{
        sprintf (s, "Enter command: PDMdescription_list\n");
        _pdm_debug(s, 0);

       /* Display Message */
       PDUmessage(PDS_M_GET_DESC, 's');

       /* load exec structure */
       PDUload_exec_structure("",catalog, "", "", "","","",0, 0);

       if (PDU_ret_bufr != NULL)
          {
          MEMclose(&PDU_ret_bufr);
          PDU_ret_bufr = NULL;
          }

       _pdm_debug("calling PDMget_desc", 0);
       status = PDMget_desc(&PDU_ret_bufr);
       _pdm_status("PDMget_desc", status);

       if (status != PDM_S_SUCCESS)
         {
         PDUmessage(status, 's');
         return(status);
         }

   if (PDMdebug_on)
      MEMprint_buffer("PDU_ret_bufr inside PDUdescription_list",PDU_ret_bufr,
                       PDU_DEBUG_FILE);

        /* DIsplay Message */
        PDUmessage(PDM_E_CLEAR_FIELD,'s');

   return (status);
}

/* This function will return the part numbers, revision, part types, 
   descriptions, and flags of those parts within a given catalog. */
/* PDM will use the function PDMparts_of_catalog. */

int PDMparts_in_catalog(catalog)

   char  *catalog;

{
        sprintf (s, "Enter command: PDMparts_in_catalog\n");
        _pdm_debug(s, 0);

       /* Display Message */
       PDUmessage(PDS_M_PARTS_IN_CATALOG, 's');

       /* load exec structure */
       PDUload_exec_structure("",catalog, "", "", "","","",0, 0);

       if (PDU_ret_bufr != NULL)
          {
          MEMclose(&PDU_ret_bufr);
          PDU_ret_bufr = NULL;
          }

       _pdm_debug("calling PDMparts_of_catalog", 0);
       status = PDMparts_of_catalog(&PDU_ret_bufr);
       _pdm_status("PDMparts_of_catalog", status);

       if (status != PDM_S_SUCCESS)
         {
         PDUmessage(status, 's');
         return(status);
         }

        /* DIsplay Message */
        PDUmessage(PDM_E_CLEAR_FIELD,'s');

   return (status);
}

/* This function will receive the list of possible state transitions for the
   part entered. */

int PDMget_trans(catalog,partnum,revision)

   char *catalog;
   char *partnum;
   char *revision;

{
        sprintf (s, "Enter command: PDMget_trans\n");
        _pdm_debug(s, 0);

	/* load exec structure */
       PDUload_exec_structure("", catalog, partnum, revision, "","","",
                              QUERY_DATA, PDM_TRANSITION);

      if (PDU_states_bufr != NULL)
         {
         MEMclose(&PDU_states_bufr);
         PDU_states_bufr = NULL;
         }

       PDUmessage(PDS_M_GET_TRANS, 's');

       _pdm_debug("calling PDMsget_table_data", 0);
       status = PDMsget_table_data1(&PDU_states_bufr);
       _pdm_status("PDMsget_table_data", status);

       PDUmessage(status, 's');

      return (status);
}

/*  Function to find the list of catalogs 

	input:
			search_criteria    
			sort_criteria
			n_type 		   defaulted to "PDM"
	
	output:
			ret_bufr

	A list of catalogs on the server whose n_type = n_type

	format of ret_bufr

	n_catalogname			char(15)
*/

int PDMshow_catalogs(search_criteria,sort_criteria,n_type,ret_bufr)
  char		*search_criteria;
  char		*sort_criteria;
  char		*n_type;
  MEMptr	*ret_bufr;

  {
	 	MEMptr		bufr = NULL;
		char		datatype[30];			
		int			l1,l2, l3;
		int       	status = PDM_S_SUCCESS;

	_pdm_debug("ENTER:PDMshow_catalogs", 0);
	sprintf(s,"Search Criteria %s\n",search_criteria);
	_pdm_debug(s, 0);
	sprintf(s,"Sort Criteria %s\n",sort_criteria);
	_pdm_debug(s, 0);

	PDUsts->MEMstatus	= MEMopen(&bufr,512);
	if(PDUsts->MEMstatus != MEM_S_SUCCESS)
	{
		sprintf (s, "%s %d",
		"MEMopen failed status ",PDUsts->MEMstatus);
		_pdm_debug(s, 0);
		PDUsts->PDMrstatus = PDM_E_OPEN_BUFFER;
		return(PDUsts->PDMrstatus);
	}
	if(search_criteria == NULL)
	{
			l1 = 0;
			sprintf(datatype,"char(%d)",5);	
	}
	else if(!strlen(search_criteria))
	{
			l1 = 0;
			sprintf(datatype,"char(%d)",5);	
	}
	else
	{
			l1 = strlen(search_criteria);
			sprintf(datatype,"char(%d)",l1);	
	}

	PDUsts->MEMstatus	= MEMwrite_format(bufr,"search",datatype);
	if(PDUsts->MEMstatus != MEM_S_SUCCESS)
	{
		MEMclose(&bufr);
		sprintf (s, "%s %d",
		"MEMwrite_format failed status ",PDUsts->MEMstatus);
		_pdm_debug(s, 0);
		PDUsts->PDMrstatus = PDM_E_WRITE_FORMAT;
		return(PDUsts->PDMrstatus);
	}
	if(sort_criteria == NULL)
	{
			l2 = 0;
			sprintf(datatype,"char(%d)",5);	
	}
	else if(!strlen(sort_criteria))
	{
			l2 = 0;
			sprintf(datatype,"char(%d)",5);	
	}
	else
	{
			l2  = strlen(sort_criteria);
			sprintf(datatype,"char(%d)",l2);
	}
	PDUsts->MEMstatus	= MEMwrite_format(bufr,"sort",datatype);
	if(PDUsts->MEMstatus != MEM_S_SUCCESS)
	{
		MEMclose(&bufr);
		sprintf (s, "%s %d",
		"MEMwrite_format failed status ",PDUsts->MEMstatus);
		_pdm_debug(s, 0);
		PDUsts->PDMrstatus = PDM_E_WRITE_FORMAT;
		return(PDUsts->PDMrstatus);
	}
	if(n_type == NULL)
	{
			l3 = 0;
			sprintf(datatype,"char(%d)",5);	
	}
	else if(!strlen(n_type))
	{
			l3 = 0;
			sprintf(datatype,"char(%d)",5);	
	}
	else
	{
			l3  = strlen(n_type);
			sprintf(datatype,"char(%d)",l3);
	}
	PDUsts->MEMstatus = MEMwrite_format(bufr,"n_type",datatype);
	if(PDUsts->MEMstatus != MEM_S_SUCCESS)
	{
		MEMclose(&bufr);
		sprintf (s, "%s %d",
		"MEMwrite_format failed status ",PDUsts->MEMstatus);
		_pdm_debug(s, 0);
		PDUsts->PDMrstatus = PDM_E_WRITE_FORMAT;
		return(PDUsts->PDMrstatus);
	}
	sprintf(s,"\1\1\1");
	PDUsts->MEMstatus	= MEMwrite(bufr,s);
	if(PDUsts->MEMstatus != MEM_S_SUCCESS)
	{
		MEMclose(&bufr);
		sprintf (s, "%s %d",
		"MEMwrite failed status ",PDUsts->MEMstatus);
		_pdm_debug(s, 0);
		PDUsts->PDMrstatus = PDM_E_WRITE_ROW;
		return(PDUsts->PDMrstatus);
	}
	PDUsts->MEMstatus	= MEMbuild_array(bufr);
	if(PDUsts->MEMstatus != MEM_S_SUCCESS)
	{
		MEMclose(&bufr);
		sprintf (s, "%s %d",
		"MEMbuild_array failed status ",PDUsts->MEMstatus);
		_pdm_debug(s, 0);
		PDUsts->PDMrstatus = PDM_E_WRITE_ROW;
		return(PDUsts->PDMrstatus);
	}
    if(l1)
    {
		PDUsts->MEMstatus	= MEMwrite_data(bufr,search_criteria,1,1);
		if(PDUsts->MEMstatus != MEM_S_SUCCESS)
		{
			MEMclose(&bufr);
			sprintf (s, "%s %d",
			"MEMwrite_data failed status ",PDUsts->MEMstatus);
			_pdm_debug(s, 0);
			PDUsts->PDMrstatus = PDM_E_WRITE_COLUMN;
			return(PDUsts->PDMrstatus);
		}
	}
	if(l2)
	{
		PDUsts->MEMstatus	= MEMwrite_data(bufr,sort_criteria,1,2);
		if(PDUsts->MEMstatus != MEM_S_SUCCESS)
		{
			MEMclose(&bufr);
			sprintf (s, "%s %d",
			"MEMwrite_data failed status ",PDUsts->MEMstatus);
			_pdm_debug(s, 0);
			PDUsts->PDMrstatus = PDM_E_WRITE_COLUMN;
			return(PDUsts->PDMrstatus);
		}
	}
	
	if(l3)
	{
		PDUsts->MEMstatus	= MEMwrite_data(bufr,n_type,1,3);
		if(PDUsts->MEMstatus != MEM_S_SUCCESS)
		{
			MEMclose(&bufr);
			sprintf (s, "%s %d",
			"MEMwrite_data failed status ",PDUsts->MEMstatus);
			_pdm_debug(s, 0);
			PDUsts->PDMrstatus = PDM_E_WRITE_COLUMN;
			return(PDUsts->PDMrstatus);
		}
	}
       /* Display Message */
       PDUmessage(PDS_M_SHOW_CATALOGS, 's');

	/* load PDMexec structure */
	PDUload_exec_structure("", "", "", "", "","","",0, 0);

	/* call PDM function */
        _pdm_debug("calling PDMsshow_catalogs", 0);
	status = PDMsshow_catalogs(bufr, ret_bufr);
	_pdm_status("PDMsshow_catalogs", status);

	if (status != PDM_S_SUCCESS)
          {
	  PDUmessage(status, 's');
	  return(status);
          }

        /* DIsplay Message */
        PDUmessage(status, 's');

	_pdm_debug ("EXIT:PDMshow_catalogs", 0);
	return (status);
  }

/* THIS FUNCTION VERIFIES THE EXISTENCE OF A CATALOG and 
   IF SUCCESSFULL CHECKS FOR THE EXISTENCE OF THE PART
   
   Following are the relevant codes.

   PDM_S_SUCCESS  if the part exists in the catalog
   PDM_E_CATALOG_NOT_FOUND	if the catalog itself is missing
   PDM_E_PART_NOT_FOUND	  if the catalog exists but the 
 						  part could not be found 
   Rest of the codes indicate a failure to perform the function
*/

int PDMrverify_part(catalog,n_itemname,n_itemrev)
  char		*catalog;
  char		*n_itemname;
  char		*n_itemrev;
  {
	int status = PDM_S_SUCCESS;

	sprintf (s, "%s %s %s\n",
	"PDMrverify_part: ",	"catalog -> ",catalog);
	_pdm_debug(s, 0);
	sprintf (s, "%s %s %s\n",
	"PDMrverify_part: ",	"Part Num -> ",n_itemname);
	_pdm_debug(s, 0);
	sprintf (s, "%s %s %s\n",
	"PDMrverify_part: ",
	"Part Revision  -> ",n_itemrev);
	_pdm_debug(s, 0);

       /* Display Message */
       PDUmessage(PDS_M_VERIFY_PART, 's');

	/* load exec structure */
        PDUload_exec_structure("", catalog,n_itemname,n_itemrev,"","","",0, 0);

        /* call PDM function */
        _pdm_debug("calling PDMverify_part", 0);
        status = PDMverify_part(catalog, n_itemname, n_itemrev);
        _pdm_status("PDMverify_part", status);

        if (status != PDM_S_SUCCESS)
          {
          PDUmessage(status, 's');
          return(status);
          }

        /* DIsplay Message */
        PDUmessage(status, 's');

	_pdm_debug ("PDMrverify_part: returning SUCCESS", 0);
	return (status);
  }

int PDMquery_dynamic_attrs(catalog,n_itemname,n_itemrev,
                           dynamic_attrs_buffer, dynamic_data_buffer,
                           dynamic_list_buffer, p_explode)
  char		*catalog;
  char		*n_itemname;
  char		*n_itemrev;
  MEMptr        *dynamic_attrs_buffer;
  MEMptr        *dynamic_data_buffer;
  MEMptr        *dynamic_list_buffer;
  char          **p_explode;
  {
  MEMptr        p_explode_buffer = NULL;
  char          **p_explode_data = NULL; 
  long          status = PDM_S_SUCCESS;
  struct        part_dynamic_attrs *part_occur;

 
        _pdm_debug("In the function PDMquery_dynamic_attrs",0);
	sprintf (s, "%s %s %s\n",
	"PDMquery_dynamic_attrs: ",	"catalog -> ",catalog);
	_pdm_debug(s, 0);
	sprintf (s, "%s %s %s\n",
	"PDMquery_dynamic_attrs: ",	"Part Num -> ",n_itemname);
	_pdm_debug(s, 0);
	sprintf (s, "%s %s %s\n",
	"PDMquery_dynamic_attrs: ",
	"Part Revision  -> ",n_itemrev);
	_pdm_debug(s, 0);

       /* Display Message */
       PDUmessage(PDS_M_GET_DYNAMIC_ATTR, 's');

      /* ALR  8/30/93  Check to see if the dynamic attribute information
        is already known. If so, do not call PDMquery_dynamic_attributes. 
     */

      if (part_occur_list)
      {
       _pdm_debug("PDMquery_dynamic_attrs:  check part occurrence",0);
       if (pdmcheck_part_occurrence(catalog, &part_occur))
       {
           _pdm_debug("PDMquery_dynamic_attrs: found attributes",0);
           status = MEMopen(&(*dynamic_attrs_buffer),512); 
           status = MEMsplit_copy_buffer(part_occur->attr_buff,&(*dynamic_attrs_buffer),1);
           status = MEMopen(&(*dynamic_data_buffer),512);
           status = MEMsplit_copy_buffer(part_occur->data_buff,&(*dynamic_data_buffer),1);
           status = MEMopen(&(*dynamic_list_buffer),512);
           status = MEMsplit_copy_buffer(part_occur->list_buff,&(*dynamic_list_buffer),1);

           *p_explode = (char *)malloc(sizeof(char) * strlen(part_occur->p_explode) + 1);
           strcpy(*p_explode,part_occur->p_explode);
           status = PDM_S_SUCCESS; 
           /* DIsplay Message */
           PDUmessage(status, 's');

	   _pdm_debug ("PDMquery_dynamic_attrs: returning SUCCESS", 0);
           return(status);
       }
      }
	/* load exec structure */
        PDUload_exec_structure("",catalog,n_itemname,n_itemrev, "","","",0, 0);

        _pdm_debug("calling PDMquery_dynamic_attributes", 0);
        status = PDMquery_dynamic_attributes(dynamic_attrs_buffer,
                  dynamic_data_buffer, dynamic_list_buffer, &p_explode_buffer);
        _pdm_status("PDMquery_dynamic_attributes", status);

        if (status != PDM_S_SUCCESS)
          {
          PDUmessage(PDM_E_CLEAR_FIELD, 's');
          return(status);
          }

        if (PDMdebug_on)
           MEMprint_buffer ("PDMquery_dynamic_attrs: dynamic_attrs_buffer",
                   *dynamic_attrs_buffer,PDU_DEBUG_FILE);

	if (!(*dynamic_attrs_buffer) || ((*dynamic_attrs_buffer)->rows == 0))
	  {
		MEMclose(dynamic_attrs_buffer);
		*dynamic_attrs_buffer = NULL;
	  }
		
          _pdm_debug("print dynamic_data_buffer",0);
            if (PDMdebug_on)
              MEMprint_buffer ("PDMquery_dynamic_attrs: dynamic_data_buffer",
                   *dynamic_data_buffer,PDU_DEBUG_FILE);

	if (!(*dynamic_data_buffer) || ((*dynamic_data_buffer)->rows == 0))
	  {
		MEMclose(dynamic_attrs_buffer);
		*dynamic_attrs_buffer = NULL;
	  }
		
          _pdm_debug("print dynamic_list_buffer",0);
            if (PDMdebug_on)
              MEMprint_buffer ("PDMquery_dynamic_attrs: dynamic_list_buffer",
                   *dynamic_list_buffer,PDU_DEBUG_FILE);

          if (p_explode_buffer == NULL)
           {
            MEMclose (&p_explode_buffer);
            *p_explode = NULL;
            PDUfill_in_string(p_explode,"Y");
            PDUmessage(PDM_E_CLEAR_FIELD, 's');
            /*return(PDM_S_SUCCESS); */
           }

          if (p_explode_buffer != NULL)
          {
            _pdm_debug("print p_explode_buffer",0);
            if (PDMdebug_on)
              MEMprint_buffer ("PDMquery_dynamic_attrs: p_explode_buffer",
                   p_explode_buffer,PDU_DEBUG_FILE);


         /*  extract p_explode value from p_explode buffer*/ 
          status = MEMbuild_array(p_explode_buffer);
          _pdm_status("MEMbuild_array",status);
          if (status != MEM_S_SUCCESS)
           { 
            MEMclose (&p_explode_buffer);
            PDUmessage(PDM_E_CLEAR_FIELD, 's');
            return (PDM_E_BUILD_BUFFER_ARRAY);
           }

           p_explode_data = (char **) p_explode_buffer->data_ptr;
           if (strcmp(p_explode_data[(p_explode_buffer->columns * 0)+0], "")
            != 0)
            {
             *p_explode = NULL;
             PDUfill_in_string(p_explode,p_explode_data[(p_explode_buffer->
                columns * 0) + 0]);
             _pdm_debug("p_explode = <%s>", *p_explode);
              /* DIsplay Message */
             PDUmessage(status, 's');
            }
          
           else 
            {
             MEMclose (&p_explode_buffer);
             *p_explode = NULL;
             PDUfill_in_string(p_explode,"Y");
             PDUmessage(PDM_E_CLEAR_FIELD, 's');
             /*  return(PDM_S_SUCCESS);  */
            }
           }

     /* ALR  8/30/93  Build the global linked list of information for a part */
       
        _pdm_debug("PDMquery_dynamic_attrs: call build_part_occurrence_list",0);   
        if (*dynamic_attrs_buffer)
        { 
          status = build_part_occurrence_list(catalog,n_itemname,n_itemrev,*dynamic_attrs_buffer,*dynamic_data_buffer,*dynamic_list_buffer,*p_explode); 
          if (status != PDM_S_SUCCESS)
           {
             _pdm_debug("PDMquery_dynamic_attrs: status build_part_occurrence_list <0x%.8x> \n",status); 
             part_occur_list = NULL;
           }
         }

        /* DIsplay Message */
        PDUmessage(status, 's');

	_pdm_debug ("PDMquery_dynamic_attrs: returning SUCCESS", 0);
	return (status);
  }

/* ALR 8/30/93   Build a linked list of part information for place part */

int build_part_occurrence_list(cat,part,rev,attr_list,data_list,list_list,p_exp)
char *cat, *part, *rev, *p_exp;
MEMptr attr_list, data_list, list_list;
{
  struct part_dynamic_attrs *part_ptr;

   _pdm_debug("build_part_occurrence_list: ENTER",0);

   if (part_occur_list == NULL)
    {
      part_ptr = (struct part_dynamic_attrs *)malloc(sizeof(struct part_dynamic_attrs));
      part_occur_list = part_ptr;
      part_ptr->next = NULL;
      part_occur_list->attr_buff = NULL;
      part_occur_list->data_buff = NULL;
      part_occur_list->list_buff = NULL;
    }
   else
    {
       part_ptr = (struct part_dynamic_attrs *)malloc(sizeof(struct part_dynamic_attrs));

       part_ptr->next = part_occur_list;
       part_occur_list = part_ptr; 
       part_occur_list->attr_buff = NULL;
       part_occur_list->data_buff = NULL;
       part_occur_list->list_buff = NULL;
    }

    _pdm_debug("build_part_occurrence_list: add information",0);

    strcpy(part_ptr->catalog,cat);
    strcpy(part_ptr->part, part);
    strcpy(part_ptr->revision,rev);
    strcpy(part_ptr->p_explode,p_exp);

    status = MEMopen(&(part_ptr->attr_buff),512);
    if (status != MEM_S_SUCCESS)
      {
        _pdm_debug("build_part_occurrence_list status <0x%.8x>",status);
        return(status);
      }
    status = MEMsplit_copy_buffer(attr_list,&(part_ptr->attr_buff),1);
    if (status != MEM_S_SUCCESS)
     {
      _pdm_debug("build_part_occurence_list status <0x%.8x>",status);
      return(status);
     }
    status = MEMopen(&(part_ptr->data_buff),512);
    if (status != MEM_S_SUCCESS)
      {
        _pdm_debug("build_part_occurrence_list status <0x%.8x>",status);
        return(status);
      }
    status = MEMsplit_copy_buffer(data_list,&(part_ptr->data_buff),1);
    if (status != MEM_S_SUCCESS)
     {
      _pdm_debug("build_part_occurence_list status <0x%.8x>",status);
      return(status);
     }
    status = MEMopen(&(part_ptr->list_buff),512);
    if (status != MEM_S_SUCCESS)
      {
        _pdm_debug("build_part_occurrence_list status <0x%.8x>",status);
        return(status);
      }
    status = MEMsplit_copy_buffer(list_list,&(part_ptr->list_buff),1);      
    if (status != MEM_S_SUCCESS)
     {
      _pdm_debug("build_part_occurence_list status <0x%.8x>",status);
      return(status);
     }

   _pdm_debug("build_part_occurrence_list: EXIT",0);

  return(PDM_S_SUCCESS);
}


/* ALR   8/30/93    Check to see if the part information is available.
   If the catalog, part and revision are available, return a pointer
   to the location in the list of this part information.
*/

int pdmcheck_part_occurrence(catalog,place_part_info)
char *catalog;
struct part_dynamic_attrs **place_part_info;
{
 struct part_dynamic_attrs *part_ptr;

 _pdm_debug("pdmcheck_part_occurrence : Enter",0);

 *place_part_info = NULL;
 part_ptr = part_occur_list;
 if (part_ptr == NULL)
  return(FALSE);

 while (part_ptr != NULL)
  {
    if (strcmp(part_ptr->catalog,catalog) == 0)
       {
         *place_part_info = part_ptr;
         _pdm_debug("PDMcheck_part_occurrence: EXIT TRUE",0);
         return(TRUE);
       }
    part_ptr = part_ptr->next; 
  }
  _pdm_debug("PDMcheck_part_occurrence: EXIT FALSE",0);
  return(FALSE);
}


/* ALR  8/30/93   Free the global part_occur_list pointer. This is done
   on a context used specific basis.
*/

void pdmfree_part_occurrence()
{
  struct part_dynamic_attrs *part_ptr;

  part_ptr = part_occur_list;
  if (part_ptr)
   {
     while (part_ptr != NULL)
     {
       part_occur_list = part_occur_list->next;
       MEMclose(&(part_ptr->attr_buff));
       MEMclose(&(part_ptr->data_buff));
       MEMclose(&(part_ptr->list_buff));
       free(part_ptr);
       part_ptr = part_occur_list;
     }
     part_occur_list = NULL; 
   }
}


/* To execute an SQL - query on the server */

int PDMsql_query(table_name,
				attribute_list,
				search_criteria,sort_criteria,ret_bufr)
  char		*table_name;
  char		*attribute_list;
  char		*search_criteria;
  char		*sort_criteria;
  MEMptr	*ret_bufr;
  {
	 	MEMptr		bufr = NULL;
		char		datatype[30];
		int			l1,l2;

	_pdm_debug("ENTER:PDMsql_query", 0);
	sprintf (s, "table = <%s>\n", table_name);
	_pdm_debug(s, 0);
	sprintf(s,"Attribute_list %s\n",attribute_list);
	_pdm_debug(s, 0);
	sprintf(s,"Search Criteria %s\n",search_criteria);
	_pdm_debug(s, 0);
        if (sort_criteria)
          {
	  sprintf(s,"Sort Criteria %s\n",sort_criteria);
          }
        else
          {
          sprintf(s,"Sort Criteria is NULL\n");
          }
        _pdm_debug(s, 0);

	status = MEMopen(&bufr,512);
	if(status != MEM_S_SUCCESS)
	{
		sprintf (s, "%s %d", "MEMopen failed status ",status);
		_pdm_debug(s, 0);
		status = PDM_E_OPEN_BUFFER;
		return(status);
	}

	if(attribute_list == NULL)
	{
		status = PDM_S_SUCCESS;
		return(status);
	}
	l1 = strlen(attribute_list);
	sprintf(datatype,"char(%d)",l1);	

	status = MEMwrite_format(bufr,"attr_list",datatype);
	if(status != MEM_S_SUCCESS)
	{
		MEMclose(&bufr);
		sprintf (s, "%s %d",
		"MEMwrite_format failed status ",status);
		_pdm_debug(s, 0);
		status = PDM_E_WRITE_FORMAT;
		return(status);
	}
	if(search_criteria == NULL)
	{
			l1 = 0;
			sprintf(datatype,"char(%d)",5);	
	}
	else if(!strlen(search_criteria))
	{
			l1 = 0;
			sprintf(datatype,"char(%d)",5);	
	}
	else
	{
			l1 = strlen(search_criteria);
			sprintf(datatype,"char(%d)",l1);	
	}
	status = MEMwrite_format(bufr,"search",datatype);
	if(status != MEM_S_SUCCESS)
	{
		MEMclose(&bufr);
		sprintf (s, "%s %d",
		"MEMwrite_format failed status ",status);
		_pdm_debug(s, 0);
		status = PDM_E_WRITE_FORMAT;
		return(status);
	}
	if(sort_criteria == NULL)
	{
			l2 = 0;
			sprintf(datatype,"char(%d)",5);	
	}
	else if(!strlen(sort_criteria))
	{
			l2 = 0;
			sprintf(datatype,"char(%d)",5);	
	}
	else
	{
			l2  = strlen(sort_criteria);
			sprintf(datatype,"char(%d)",l2);
	}
	status = MEMwrite_format(bufr,"sort",datatype);
	if(status != MEM_S_SUCCESS)
	{
		MEMclose(&bufr);
		sprintf (s, "%s %d",
		"MEMwrite_format failed status ",status);
		_pdm_debug(s, 0);
		status = PDM_E_WRITE_FORMAT;
		return(status);
	}
	sprintf(s,"\1\1\1");
	status = MEMwrite(bufr,s);
	if(status != MEM_S_SUCCESS)
	{
		MEMclose(&bufr);
		sprintf (s, "%s %d",
		"MEMwrite failed status ",status);
		_pdm_debug(s, 0);
		status = PDM_E_WRITE_ROW;
		return(status);
	}
	status = MEMbuild_array(bufr);
	if(status != MEM_S_SUCCESS)
	{
		MEMclose(&bufr);
		sprintf (s, "%s %d",
		"MEMbuild_array failed status ",status);
		_pdm_debug(s, 0);
		status = PDM_E_BUILD_ARRAY;
		return(status);
	}
	status = MEMwrite_data(bufr,attribute_list,1,1);
	if(status != MEM_S_SUCCESS)
	{
		MEMclose(&bufr);
		sprintf (s, "%s %d",
		"MEMwrite_data failed status ",status);
		_pdm_debug(s, 0);
		status = PDM_E_WRITE_COLUMN;
		return(status);
	}
    if(l1)
    {
		status	= MEMwrite_data(bufr,search_criteria,1,2);
		if(status != MEM_S_SUCCESS)
		{
			MEMclose(&bufr);
			sprintf (s, "%s %d",
			"MEMwrite_data failed status ",status);
			_pdm_debug(s, 0);
			status = PDM_E_WRITE_COLUMN;
			return(status);
		}
	}
	if(l2)
	{
		status	= MEMwrite_data(bufr,sort_criteria,1,3);
		if(status != MEM_S_SUCCESS)
		{
			MEMclose(&bufr);
			sprintf (s, "%s %d",
			"MEMwrite_data failed status ",status);
			_pdm_debug(s, 0);
			status = PDM_E_WRITE_COLUMN;
			return(status);
		}
	}

       /* Display Message */
       PDUmessage(PDS_M_QUERY_TABLE, 's');

       /* load exec structure */
       PDUload_exec_structure("", table_name, "", "", "","","",0, 0);

       _pdm_debug("calling PDMs_sql_query", 0);
       status = PDMs_sql_query(bufr, ret_bufr);
       _pdm_status("PDMs_sql_query", status);

       if (status != PDM_S_SUCCESS)
         {
         PDUmessage(status, 's');
         return(status);
         }

        /* DIsplay Message */
        PDUmessage(PDM_E_CLEAR_FIELD, 's');

	_pdm_debug ("EXIT:PDMsql_query", 0);
	return (status);
  }

/* 
   A function that returns a MEMbuffer
   type -> 1 child_buffer
   type -> 2 attach_buffer
   type -> 3 view_buffer
   type -> 4 strg_buffer
   type -> 5 wf_buffer
*/

/* Internal functions */

int	PDMopen_copy_buffer3(n_cofilename,storage_name,
			node_name,user_name,passwd,path_name,strg_buffer)
char	*n_cofilename;
char	*storage_name;
char	*node_name;
char	*user_name;
char	*passwd;
char	*path_name;
MEMptr	*strg_buffer;
{

	_pdm_debug("ENTER:PDMopen_copy_buffer3", 0);
	PDUsts->PDMrstatus = MEMopen(strg_buffer,512);
	if(PDUsts->PDMrstatus != MEM_S_SUCCESS)
	{
		sprintf(s,"MEMbuild_array failed status %d\n",status);
		_pdm_debug(s, 0);
		PDUsts->PDMrstatus = PDM_E_BUILD_ARRAY;
		return(PDUsts->PDMrstatus);
	}
	PDUsts->PDMrstatus = MEMwrite_format
					(*strg_buffer,"n_cofilename","char(20)");
	if(PDUsts->PDMrstatus != MEM_S_SUCCESS)
	{
 		MEMclose(*strg_buffer);
		sprintf(s,"MEMwrite_format failed status %d\n",status);
		_pdm_debug(s, 0);
		PDUsts->PDMrstatus = PDM_E_WRITE_FORMAT;
		return(PDUsts->PDMrstatus);
	}
	PDUsts->PDMrstatus = MEMwrite_format
					(*strg_buffer,"storage_name","char(14)");
	if(PDUsts->PDMrstatus != MEM_S_SUCCESS)
	{
 		MEMclose(*strg_buffer);
		sprintf(s,"MEMwrite_format failed status %d\n",status);
		_pdm_debug(s, 0);
		PDUsts->PDMrstatus = PDM_E_WRITE_FORMAT;
		return(PDUsts->PDMrstatus);
	}
	PDUsts->PDMrstatus = MEMwrite_format
					(*strg_buffer,"node_name","char(14)");
	if(PDUsts->PDMrstatus != MEM_S_SUCCESS)
	{
		MEMclose(*strg_buffer);
		sprintf(s,"MEMwrite_format failed status %d\n",status);
		_pdm_debug(s, 0);
		PDUsts->PDMrstatus = PDM_E_WRITE_FORMAT;
		return(PDUsts->PDMrstatus);
	}

	PDUsts->PDMrstatus = MEMwrite_format
					(*strg_buffer,"user_name","char(14)");
	if(PDUsts->PDMrstatus != MEM_S_SUCCESS)
	{
		MEMclose(*strg_buffer);
		sprintf(s,"MEMwrite_format failed status %d\n",status);
		_pdm_debug(s, 0);
		PDUsts->PDMrstatus = PDM_E_WRITE_FORMAT;
		return(PDUsts->PDMrstatus);
	}
	PDUsts->PDMrstatus = MEMwrite_format
					(*strg_buffer,"passwd","char(25)");
	if(PDUsts->PDMrstatus != MEM_S_SUCCESS)
	{
		MEMclose(*strg_buffer);
		sprintf(s,"MEMwrite_format failed status %d\n",status);
		_pdm_debug(s, 0);
		PDUsts->PDMrstatus = PDM_E_WRITE_FORMAT;
		return(PDUsts->PDMrstatus);
	}
	PDUsts->PDMrstatus = MEMwrite_format
					(*strg_buffer,"path_name","char(100)");
	if(PDUsts->PDMrstatus != MEM_S_SUCCESS)
	{
		MEMclose(*strg_buffer);
		sprintf(s,"MEMwrite_format failed status %d\n",status);
		_pdm_debug(s, 0);
		PDUsts->PDMrstatus = PDM_E_WRITE_FORMAT;
		return(PDUsts->PDMrstatus);
	}
	sprintf(s,"%s\1%s\1%s\1%s\1%s\1%s\1",n_cofilename,
	storage_name,node_name,user_name,passwd,path_name);
	PDUsts->PDMrstatus = MEMwrite(*strg_buffer,s);
	if(PDUsts->PDMrstatus != MEM_S_SUCCESS)
	{
		MEMclose(*strg_buffer);
		sprintf(s,"MEMwrite_format failed status %d\n",status);
		_pdm_debug(s, 0);
		PDUsts->PDMrstatus = PDM_E_WRITE_ROW;
		return(PDUsts->PDMrstatus);
	}	
	_pdm_debug("EXIT:PDMopen_copy_buffer3", 0);
	return(PDM_S_SUCCESS);
}

/* 
	This function returns a buffer containing the projects.
    (n_project_name,n_application,n_projectdesc)
 
    If there are no projects  returns PDM_E_NO_PROJECTS
*/

/*
int PDMshow_projects(ret_bufr)
  MEMptr	*ret_bufr;

  {
	_pdm_debug("ENTER:PDMshow_projects", 0);

       PDUmessage(PDS_M_SHOW_PROJECTS, 's');

	if ((PDUsts->PDMrstatus = PDMsend_command (PDM_SHOW_PROJECTS,"",
		"", "", "", "","","",0, 0, NULL)) != PDM_S_SUCCESS)
	  {
		sprintf (s, "%s %d",
		"PDMsend_command status ",PDUsts->PDMrstatus);
		_pdm_debug(s, 0);
		return (PDUsts->PDMrstatus);
	  }

	if ((PDUsts->PDMrstatus = PDMreceive_status (ret_bufr)) 
		!= PDM_S_SUCCESS)
	  {
		sprintf (s, "%s %d\n",
		"PDMreceive_status status ",PDUsts->PDMrstatus);
		_pdm_debug(s, 0);
		return (PDUsts->PDMrstatus);
	  }

        PDUmessage(PDUsts->PDMrstatus, 's');

	_pdm_debug ("EXIT:PDMshow_projects", 0);
	return (PDUsts->PDMrstatus);
  }
*/

/* 
   Given p_catalog,n_itemname,n_itemrev,p_bomtype
   p_bomtype == A   for Active Bom
   p_bomtype == R   for Review Bom

   returns the name of the bomtable
   p_bomname is malloced if successfull

   If BOM doesnot exist p_bomname is NULL
   and return code  is PDM_E_BOM_NOT_FOUND
*/

/*
int PDMfind_bomtable(p_catalog,n_itemname,n_itemrev,
					 p_bomtype,p_bomname)
char	*p_catalog;
char	*n_itemname;
char	*n_itemrev;
char	*p_bomtype;
char	**p_bomname;
{
	int		p_operation;
	MEMptr	ret_bufr = NULL;
	char	**data;

	_pdm_debug("ENTER:PDMfind_bomtable", 0);
	sprintf(s,"catalog name %s\n",p_catalog);
	_pdm_debug(s, 0);
	sprintf(s,"part num %s\n",n_itemname);
	_pdm_debug(s, 0);
	sprintf(s,"part revision %s\n",n_itemrev);
	_pdm_debug(s, 0);
	sprintf(s,"bom type %s\n",p_bomtype);
	_pdm_debug(s, 0);

	if(!strncmp(p_bomtype,"A",1))
	{
		p_operation = 0;
	}
	else if(!strncmp(p_bomtype,"R",1))
	{
		p_operation = 1;
	}
	else
	{
		PDUsts->PDMrstatus = PDM_E_FAILURE;
		_pdm_debug("Unknown BOM Type ", 0);
		return(PDUsts->PDMrstatus);
	}

       PDUmessage(PDS_M_FIND_BOMNAME, 's');

	if ((PDUsts->PDMrstatus = PDMsend_command 
		(PDM_FIND_BOMNAME,"",p_catalog, n_itemname, n_itemrev, "","","",
		 p_operation,0, NULL)) != PDM_S_SUCCESS)
	  {
		sprintf (s, "%s %d\n",
		"PDMsend_command status = ",PDUsts->PDMrstatus);
		_pdm_debug(s, 0);
		return (PDUsts->PDMrstatus);
	  }

	if ((PDUsts->PDMrstatus = PDMreceive_status 
			(&ret_bufr)) != PDM_S_SUCCESS)
	{
		MEMclose(&ret_bufr);
		sprintf (s, "%s %d\n",
		"PDMrecieve_status status = ",PDUsts->PDMrstatus);
		_pdm_debug(s, 0);
		return (PDUsts->PDMrstatus);
    }

	if ((PDUsts->PDMrstatus = MEMbuild_array(ret_bufr)) != MEM_S_SUCCESS)
	{
		MEMclose(&ret_bufr);
		sprintf (s, "%s %d\n",
		"MEMbuild_array status = ",PDUsts->PDMrstatus);
		_pdm_debug(s, 0);
		PDUsts->PDMrstatus = PDM_E_BUILD_ARRAY;
		return (PDUsts->PDMrstatus);
    }
	data = (char **) ret_bufr->data_ptr;
	*p_bomname = (char *) malloc(strlen(data[0]) + 10);
	if(*p_bomname == NULL)
	{
		MEMclose(&ret_bufr);
		PDUsts->PDMrstatus = PDM_E_COULD_NOT_MALLOC;
		sprintf (s, "%s %d\n",
		"malloc failed status = ",PDUsts->PDMrstatus);
		_pdm_debug(s, 0);
		return (PDUsts->PDMrstatus);
    }
	strcpy(*p_bomname,data[0]);
	MEMclose(&ret_bufr);
	_pdm_debug("EXIT:PDMfind_bomtable", 0);
        if (PDUsts->PDMrstatus == MEM_S_SUCCESS)
           PDUsts->PDMrstatus = PDM_S_SUCCESS;
        PDUmessage(PDUsts->PDMrstatus, 's');

	return(PDUsts->PDMrstatus);
}
*/

int PDMcheck_item(catalog,n_itemname,n_itemrev,command_no,username)
  char		*catalog;
  char		*n_itemname;
  char		*n_itemrev;
  int           command_no;
  char		*username;
  {
  MEMptr        buffer = NULL;
  /*char          datatype[30];					APOGEE */

	_pdm_debug("ENTER:PDMcheck_item", 0);
	sprintf (s, "%s %s %s\n",
	"PDMcheck_item: ",	"catalog -> ",catalog);
	_pdm_debug(s, 0);
	sprintf (s, "%s %s %s\n",
	"PDMcheck_item: ",	"Part Num -> ",n_itemname);
	_pdm_debug(s, 0);
	sprintf (s, "%s %s %s\n",
	"PDMcheck_item: ",
	"Part Revision  -> ",n_itemrev);
	_pdm_debug(s, 0);
	sprintf (s, "%s %s %d\n",
	"PDMcheck_item: ",	"Command Num -> ",command_no);
	_pdm_debug(s, 0);
	sprintf (s, "%s %s %s\n",
	"PDMcheck_item: ",	"User Name -> ",username);
	_pdm_debug(s, 0);

	PDUsts->PDMrstatus = MEMopen(&buffer,512);
	if(PDUsts->PDMrstatus != MEM_S_SUCCESS)
	{
		sprintf(s,"%s %d \n",
		"MEMopen failed status ",PDUsts->PDMrstatus);
		_pdm_debug(s, 0);
		PDUsts->PDMrstatus = PDM_E_OPEN_BUFFER;
		return(PDUsts->PDMrstatus);
	}
	PDUsts->PDMrstatus = MEMwrite_format(buffer,
					"command_no","integer");
	if(PDUsts->PDMrstatus != MEM_S_SUCCESS)
	{
		MEMclose(&buffer);
		sprintf(s,"%s %d \n",
		"MEMwrite_format failed status ",PDUsts->PDMrstatus);
		_pdm_debug(s, 0);
		PDUsts->PDMrstatus = PDM_E_WRITE_FORMAT;
		return(PDUsts->PDMrstatus);
	}
	PDUsts->PDMrstatus = MEMwrite_format(buffer,
					"username","char(40)");
	if(PDUsts->PDMrstatus != MEM_S_SUCCESS)
	{
		MEMclose(&buffer);
		sprintf(s,"%s %d \n",
		"MEMwrite_format failed status ",PDUsts->PDMrstatus);
		_pdm_debug(s, 0);
		PDUsts->PDMrstatus = PDM_E_WRITE_FORMAT;
		return(PDUsts->PDMrstatus);
	}
	sprintf(s,"%d\1%s",command_no,username);
	PDUsts->PDMrstatus = MEMwrite(buffer,s);
	if(PDUsts->PDMrstatus != MEM_S_SUCCESS)
	{
		MEMclose(&buffer);
		sprintf(s,"%s %d \n",
		"MEMwrite failed status ",PDUsts->PDMrstatus);
		_pdm_debug(s, 0);
		PDUsts->PDMrstatus = PDM_E_WRITE_ROW;
		return(PDUsts->PDMrstatus);
	}

       /* Display Message */
       PDUmessage(PDS_M_CHECK_ITEM, 's');

	/*  Send the command to PDM  */

	/*if ((PDUsts->PDMrstatus = PDMsend_command (PDM_CHECK_ITEM,"",
		catalog, n_itemname, n_itemrev, "","","",
                0, 0, buffer)) != PDM_S_SUCCESS)
	  {
		sprintf (s, "%s %s %d",
		"PDMcheck_item: ",
		"PDMsend_command status ",PDUsts->PDMrstatus);
		_pdm_debug(s, 0);
		return (PDUsts->PDMrstatus);
	  }*/

	/*  Receive the status from PDM  */

	/*if ((PDUsts->PDMrstatus = PDMreceive_status (NULL)) != PDM_S_SUCCESS)
	  {
		sprintf (s, "%s %s %d\n",
		"PDMcheck_item: ",
		"PDMreceive_status status ",PDUsts->PDMrstatus);
		_pdm_debug(s, 0);
		return (PDUsts->PDMrstatus);
	  }*/

        /* DIsplay Message */
        PDUmessage(PDUsts->PDMrstatus, 's');

	_pdm_debug ("PDMcheck_item: returning SUCCESS", 0);
	return (PDUsts->PDMrstatus);
  }

/*
int PDMgenerate_filename(filename_buffer)
  MEMptr	*filename_buffer;
  {

       PDUmessage(PDS_M_GENERATE_FILENAME, 's');

	if ((PDUsts->PDMrstatus = PDMsend_command 
	     (PDM_GENERATE_FILENAME,"","", "", "", "","","",
			0, 0, NULL)) != PDM_S_SUCCESS)
	  {
		sprintf (s, "PDMgenerate_filename: PDMsend_command status = <%d>\n",
			PDUsts->PDMrstatus);
		_pdm_debug(s, 0);
		return (PDUsts->PDMrstatus);
	  }

	if ((PDUsts->PDMrstatus = PDMreceive_status 
					(filename_buffer)) != PDM_S_SUCCESS)
	  {
		sprintf (s, "PDMgenerate_filename: PDMreceive_status status = <%d>\n",
			PDUsts->PDMrstatus);
		_pdm_debug(s, 0);
		return (PDUsts->PDMrstatus);
	  }

        PDUmessage(PDUsts->PDMrstatus, 's');

	_pdm_debug ("PDMgenerate_filename: returning SUCCESS", 0);
	return (PDUsts->PDMrstatus);
  }
*/

int PDMrcheck_dup_sa_fname(catalog,part_num,rev,filename,saname)

  char          *catalog;
  char          *part_num;
  char          *rev;
  char          *filename;
  char          *saname;
  {

  _pdm_debug("Entering PDMrcheck_dup_sa_fname",0);

  _pdm_debug("storage area name = <%s>", saname);
  _pdm_debug("filename = <%s>", filename);

  /* load exec struct */

  PDUload_exec_structure("",catalog,part_num,rev,"","","",0,0);

  _pdm_debug("CALL: PDMcheck_dup_sa_fname",0);

  PDUmessage(PDS_M_VALIDATE_STG_FILENAME, 's');

  status = PDMcheck_dup_sa_fname(filename,saname);
  _pdm_status("PDMcheck_dup_sa_fname",status);

  if (status != PDM_S_SUCCESS)
     {
     PDUmessage(status,'s');
     return(status);
     }

  /* Display Message */
     PDUmessage(PDM_E_CLEAR_FIELD,'s');

  return (status);
  }

int PDMsql_distinct(table_name, attribute_list,
				search_criteria,sort_criteria,ret_bufr)
  char		*table_name;
  char		*attribute_list;
  char		*search_criteria;
  char		*sort_criteria;
  MEMptr	*ret_bufr;
  {
	 	MEMptr		bufr = NULL;
		char		datatype[30];
		int			l1,l2;

	_pdm_debug("ENTER:PDMsql_distinct", 0);
	sprintf (s, "table = <%s>\n", table_name);
	_pdm_debug(s, 0);
	sprintf(s,"Attribute_list %s\n",attribute_list);
	_pdm_debug(s, 0);
        if (search_criteria)
          {
	  sprintf(s,"Search Criteria %s\n",search_criteria);
          }
        else
          {
	  sprintf(s,"Search Criteria is NULL\n");
          }
	_pdm_debug(s, 0);
        if (sort_criteria)
          {
	  sprintf(s,"Sort Criteria %s\n",sort_criteria);
          }
        else
          {
          sprintf(s,"Sort Criteria is NULL\n");
          }
        _pdm_debug(s, 0);

	PDUsts->MEMstatus = MEMopen(&bufr,512);
	if(PDUsts->MEMstatus != MEM_S_SUCCESS)
	{
		sprintf (s, "%s %d",
		"MEMopen failed status ",PDUsts->MEMstatus);
		_pdm_debug(s, 0);
		PDUsts->PDMrstatus = PDM_E_OPEN_BUFFER;
		return(PDUsts->PDMrstatus);
	}
	if(attribute_list == NULL)
	{
		PDUsts->PDMrstatus = PDM_S_SUCCESS;
		return(PDUsts->PDMrstatus);
	}
	l1 = strlen(attribute_list);
	sprintf(datatype,"char(%d)",l1);	

	PDUsts->MEMstatus = MEMwrite_format(bufr,"attr_list",datatype);
	if(PDUsts->MEMstatus != MEM_S_SUCCESS)
	{
		MEMclose(&bufr);
		sprintf (s, "%s %d",
		"MEMwrite_format failed status ",PDUsts->MEMstatus);
		_pdm_debug(s, 0);
		PDUsts->PDMrstatus = PDM_E_WRITE_FORMAT;
		return(PDUsts->PDMrstatus);
	}
	if(search_criteria == NULL)
	{
			l1 = 0;
			sprintf(datatype,"char(%d)",5);	
	}
	else if(!strlen(search_criteria))
	{
			l1 = 0;
			sprintf(datatype,"char(%d)",5);	
	}
	else
	{
			l1 = strlen(search_criteria);
			sprintf(datatype,"char(%d)",l1);	
	}
	PDUsts->MEMstatus = MEMwrite_format(bufr,"search",datatype);
	if(PDUsts->MEMstatus != MEM_S_SUCCESS)
	{
		MEMclose(&bufr);
		sprintf (s, "%s %d",
		"MEMwrite_format failed status ",PDUsts->MEMstatus);
		_pdm_debug(s, 0);
		PDUsts->PDMrstatus = PDM_E_WRITE_FORMAT;
		return(PDUsts->PDMrstatus);
	}
	if(sort_criteria == NULL)
	{
			l2 = 0;
			sprintf(datatype,"char(%d)",5);	
	}
	else if(!strlen(sort_criteria))
	{
			l2 = 0;
			sprintf(datatype,"char(%d)",5);	
	}
	else
	{
			l2  = strlen(sort_criteria);
			sprintf(datatype,"char(%d)",l2);
	}
	PDUsts->MEMstatus = MEMwrite_format(bufr,"sort",datatype);
	if(PDUsts->MEMstatus != MEM_S_SUCCESS)
	{
		MEMclose(&bufr);
		sprintf (s, "%s %d",
		"MEMwrite_format failed status ",PDUsts->MEMstatus);
		_pdm_debug(s, 0);
		PDUsts->PDMrstatus = PDM_E_WRITE_FORMAT;
		return(PDUsts->PDMrstatus);
	}
	sprintf(s,"\1\1\1");
	PDUsts->MEMstatus = MEMwrite(bufr,s);
	if(PDUsts->MEMstatus != MEM_S_SUCCESS)
	{
		MEMclose(&bufr);
		sprintf (s, "%s %d",
		"MEMwrite failed status ",PDUsts->MEMstatus);
		_pdm_debug(s, 0);
		PDUsts->PDMrstatus = PDM_E_WRITE_ROW;
		return(PDUsts->PDMrstatus);
	}
	PDUsts->MEMstatus = MEMbuild_array(bufr);
	if(PDUsts->MEMstatus != MEM_S_SUCCESS)
	{
		MEMclose(&bufr);
		sprintf (s, "%s %d",
		"MEMbuild_array failed status ",PDUsts->MEMstatus);
		_pdm_debug(s, 0);
		PDUsts->PDMrstatus = PDM_E_BUILD_ARRAY;
		return(PDUsts->PDMrstatus);
	}
	PDUsts->MEMstatus = MEMwrite_data(bufr,attribute_list,1,1);
	if(PDUsts->MEMstatus != MEM_S_SUCCESS)
	{
		MEMclose(&bufr);
		sprintf (s, "%s %d",
		"MEMwrite_data failed status ",PDUsts->MEMstatus);
		_pdm_debug(s, 0);
		PDUsts->PDMrstatus = PDM_E_WRITE_COLUMN;
		return(PDUsts->PDMrstatus);
	}
    if(l1)
    {
		PDUsts->MEMstatus	= MEMwrite_data(bufr,search_criteria,1,2);
		if(PDUsts->MEMstatus != MEM_S_SUCCESS)
		{
			MEMclose(&bufr);
			sprintf (s, "%s %d",
			"MEMwrite_data failed status ",PDUsts->MEMstatus);
			_pdm_debug(s, 0);
			PDUsts->PDMrstatus = PDM_E_WRITE_COLUMN;
			return(PDUsts->PDMrstatus);
		}
	}
	if(l2)
	{
		PDUsts->MEMstatus	= MEMwrite_data(bufr,sort_criteria,1,3);
		if(PDUsts->MEMstatus != MEM_S_SUCCESS)
		{
			MEMclose(&bufr);
			sprintf (s, "%s %d",
			"MEMwrite_data failed status ",PDUsts->MEMstatus);
			_pdm_debug(s, 0);
			PDUsts->PDMrstatus = PDM_E_WRITE_COLUMN;
			return(PDUsts->PDMrstatus);
		}
	}

       /* Display Message */
       PDUmessage(PDS_M_QUERY_DISTINCT_TABLE, 's');

       /* load exec structure */
       PDUload_exec_structure("", table_name, "", "", "","","",0, 0);

       _pdm_debug("calling PDMs_sql_distinct", 0);
       status = PDMs_sql_distinct(bufr, ret_bufr);
       _pdm_status("PDMs_sql_distinct", status);

       if (status != PDM_S_SUCCESS)
         {
         PDUmessage(status, 's');
         return(status);
         }

        /* DIsplay Message */
        PDUmessage(PDM_E_CLEAR_FIELD, 's');

	_pdm_debug ("EXIT:PDMsql_distinct", 0);
	return (status);
  }

/* This function strips extra buffers out of PDU_ret_bufr (NFM 3.0) */
/* JAMAL SHAKRA */
int PDUstrip_buffer(buffer)

  MEMptr  *buffer;

  {
   int    current_mem_buf;
   MEMptr attr_buffer = NULL;
   MEMptr data_buffer = NULL;
   MEMptr storage_buffer = NULL;
   MEMptr list_buffer = NULL;

   _pdm_debug("In the PDUstrip_buffer function", 0);

   MEMreset_buffer (*buffer, &current_mem_buf);
   /* Copy attr buffer to attr_buffer */
   MEMsplit_copy_buffer(*buffer, &attr_buffer, 0);
     status = MEMbuild_array(attr_buffer);

   /* Copy data buffer to data_buffer */
   MEMreset_buffer (*buffer, &current_mem_buf);
   MEMsplit_copy_buffer(*buffer, &data_buffer, 0);

   /* Skip extra NFM 3.0 buffers 
   for (i = 0; i < attr_buffer->rows; ++ i)
       {
        MEMreset_buffer (*buffer, &current_mem_buf);
       }
        */
        MEMreset_buffer_no (*buffer, attr_buffer->rows);
   MEMreset_buffer (*buffer, &current_mem_buf);

   /* Copy ACL to list_buffer */
   MEMsplit_copy_buffer(*buffer, &list_buffer, 0);
   MEMreset_buffer (*buffer, &current_mem_buf);

   /* Copy storage buffer to storage_buffer */
    MEMsplit_copy_buffer(*buffer, &storage_buffer, 0);

   /* Append storage buffer to list buffer */
   MEMappend(storage_buffer, list_buffer);

   /* Construct attr,data,and list appended buffer */
   MEMappend(list_buffer, data_buffer);
   MEMappend(data_buffer, attr_buffer);

   MEMclose(buffer);
   MEMsplit_copy_buffer(attr_buffer, buffer, 1);

   if (PDMdebug_on)
      MEMprint_buffers("Modified PDU_RET_BUFR", *buffer, PDU_DEBUG_FILE);

   return(status);
  }
