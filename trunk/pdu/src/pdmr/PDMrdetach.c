#include <stdio.h>

#include "PDMcommand.h"
#include "PDUerror.h"
#include "PDUsts_st.h"
#include "MEMerrordef.h"
#include "PDMmessage.h"
#include <NETerrordef.h>
#include <PDUstr.h>
#include "PDUfile_def.h"
#include "PDUproto.h"
#include "PDMproto.h"
#include "PDUstr.h"

extern PDUsts_ptr PDUsts;
extern int PDMdebug_on;
extern int PDM_debug_on;
extern MEMptr PDU_storage_area;
extern struct PDUrefresh *refresh;


/*
   Author: Jamal Shakra

   Creation Date: 1/28/91
 
   Purpose: 

      Deletes local files that exists on the client upon detaching reference
      files. This a new 1.4.1 feature support. 


   INPUT:

                delete_list             MEMptr

*/
   
int	PDMdetach_part(delete_list)
 
 MEMptr delete_list;
{
	MEMptr		file_buffer = NULL;
	int             status = PDM_S_SUCCESS;

        _pdm_debug("In the function PDMdetach_part",0);

        if (PDM_debug_on)
           MEMprint_buffer("delete list", delete_list, PDU_DEBUG_FILE);

         /* Display message */
         PDUmessage(PDS_M_DETACH_PART, 's');

	/* load exec structure */
   	PDUload_exec_structure("", refresh->act_catalog, refresh->act_partid, 
                               refresh->act_revision, "","","",0, 0);

        PDUdeactivate_stop_sign();
	status = PDMdetach(delete_list, &file_buffer);
	_pdm_status("PDMdetach", status);
        PDUactivate_stop_sign();

	if (status != PDM_S_SUCCESS)
          {
	  PDUmessage(status, 's');
	  MEMclose(&delete_list);
	  MEMclose(&file_buffer);
	  return(status);
          }

        /* Print out file buffer */
        if (PDMdebug_on)
           MEMprint_buffer("detach file buffer:", file_buffer, PDU_DEBUG_FILE);

        /* Display message */
        PDUmessage(PDM_E_CLEAR_FIELD, 's');

        if (file_buffer)
           {
            /* Remove file(s) locally */
            status = PDUremove_files_locally(file_buffer);
            _pdm_status("PDUremove_files_locally", status);
            MEMclose(&file_buffer);
           }

        return (status);
}


