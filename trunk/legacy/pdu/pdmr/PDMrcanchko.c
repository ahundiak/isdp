#include <stdio.h>
#include "PDMcommand.h"
#include "PDUerror.h"
#include "PDUsts_st.h"
#include "MEMerrordef.h"
#include <NETerrordef.h>
#include <PDUstr.h>
#include <PDUfile_def.h>
#include <PDMmessage.h>
#include <PDUproto.h>
#include <PDMproto.h>

static char s[1024];
extern PDUsts_ptr PDUsts;
extern int PDMdebug_on;


/*
   Author: Jamal Shakra

   Creation Date: 2/06/91
 
   Purpose: 

      Deletes local files that exists on the client upon executing the 
      cancel checkout command. This a new 1.4.1 feature support. 


   INPUT:

		catalog			char(14)
		part_num		char(14)
		revision		char(14)

		storage_buffer          MEMptr

   OUTPUT:

    file_name_list    *char list of files that need to be deleted locally.
		
	
*/
   
int	PDMrcancel_checkout_part(
                                 catalog,
                                 part_num,
                                 revision,
                                 attach_bufr,
                                 param_cat_list,
                                 file_name_list,
                                 row_count
                                )
 
char	*catalog;
char	*part_num;
char	*revision;
MEMptr  attach_bufr;
struct  PDUcat_node *param_cat_list;
char    ***file_name_list;
int     *row_count;
{
	MEMptr		file_buffer = NULL;
	MEMptr		part_files = NULL;
	char		**data;
        int             i;
        int             status = PDM_S_SUCCESS;
        char            **file_list = NULL;

        _pdm_debug("In the function PDMrcancel_checkout_part",0);

	sprintf (s, "PDMrcancel_checkout_part: catalog = <%s>\n", catalog);
	_pdm_debug (s, 0);
	sprintf (s, "PDMrcancel_checkout_part: part_num = <%s>\n", part_num);
	_pdm_debug (s, 0);
	sprintf (s, "PDMrcancel_checkout_part: revision = <%s>\n", revision);
	_pdm_debug (s, 0);

	PDUprint_storage_area();

        PDUmessage(PDS_M_CANCEL_CHECKOUT_PART, 's');

         if (PDMdebug_on)
            {
             MEMprint_buffer("attach buffer", attach_bufr, PDU_DEBUG_FILE);
            }

	/* load exec structure */
	PDUload_exec_structure("", catalog, part_num, revision, "","","",0, 0);

	_pdm_debug("calling PDMcancel_checkout_part", 0);
        PDUdeactivate_stop_sign();
	status = PDMcancel_checkout_part(
                                         &file_buffer,
                                         attach_bufr,
                                         param_cat_list,
                                         &part_files
                                        );
	_pdm_status("PDMcancel_checkout_part", status);

        PDUactivate_stop_sign();

        if (status != PDM_S_SUCCESS)
          {
           PDUmessage(status, 's');
	   MEMclose(&file_buffer);
           return(status);
          }

        /* Print out part files buffer */
        if (PDMdebug_on)
           MEMprint_buffer("part files buffer:", part_files, PDU_DEBUG_FILE);

        /* Change permissions on part files, if any. */
        status = PDUchange_to_read_only(part_files);
        _pdm_status("PDUchange_to_read_only", status);

        if (status != PDM_S_SUCCESS)
           {
            if (file_buffer)
               MEMclose(&file_buffer);

            if (part_files)
               MEMclose(&part_files);

            return(PDM_E_DELETE_FILES);
           }

        if (file_buffer == NULL)
          {
          _pdm_debug("list of files to delete is empty", 0);

          /* Clear message field */
          PDUmessage(PDM_E_CLEAR_FIELD, 's');

          return(status);
          }

        /* need to extract file name list from file_buffer */
	status = MEMbuild_array(file_buffer);
	if (status != MEM_S_SUCCESS)
	  {
		MEMclose(&file_buffer);
		sprintf (s,
                     "PDMrcancel_checkout_part: MEMbuild_array status = <%d>\n",
			status);
		_pdm_debug (s, 0);
		status = PDM_E_BUILD_ARRAY;

                /* Clear message field */
                PDUmessage(PDM_E_CLEAR_FIELD, 's');

		return(status);
	  }

        /* check to see if file buffer has any rows */
        if (file_buffer->rows == 0)
           {
            _pdm_debug("No list of files found to delete", 0);
            MEMclose(&file_buffer);
            *row_count = 0;

            /* Clear message field */
            PDUmessage(PDM_E_CLEAR_FIELD, 's');

            return(PDM_S_SUCCESS);
           }

        else
           {
            /* print file_buffer */
            if (PDMdebug_on)
               MEMprint_buffer("file name list",file_buffer,PDU_DEBUG_FILE);

            *row_count = file_buffer->rows;
            _pdm_debug("rows found = %d",(char *)*row_count);

            /* allocate space and initialize file_list */
            file_list = (char **) malloc (
                                           file_buffer->rows * sizeof(char *)
                                         ); 
            memset (file_list, NULL,(file_buffer->rows * sizeof(char *)));

            data = (char **) file_buffer->data_ptr;
            for (i = 0; i < file_buffer->rows; ++i)
              {
               if (strcmp(data[(file_buffer->columns * i)+0],"") != 0)
               {
                 _pdm_debug("array index value = %d",(char *)i);
                 _pdm_debug("copying file name to array entry",0);
                 PDUfill_in_string(&file_list[i],
                                   data[(file_buffer->columns * i)+0]);
                 _pdm_debug("extracted file name = <%s>",file_list[i]);
               }
              }

            status = PDM_S_SUCCESS;
            *file_name_list = file_list;
            MEMclose(&file_buffer);
            }

 /* Clear message field */
/*
 PDUmessage(PDM_E_CLEAR_FIELD, 's');
*/
/* ALR  1/14/92  */
 PDUmessage(PDM_S_SUCCESS,'s');
 sleep(3);
 return(status);
}


