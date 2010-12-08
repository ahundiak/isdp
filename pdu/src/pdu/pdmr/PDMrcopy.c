#include <stdio.h>
#include "PDMcommand.h"
#include "PDUerror.h"
#include "PDUsts_st.h"
#include "PDUuser.h"
#include "MEMerrordef.h"
#include <NETerrordef.h>
#include <PDUstr.h>
#include <PDUfile_def.h>
#include <PDMmessage.h>
#include <PDUproto.h>
#include <PDMproto.h>

extern PDUsts_ptr PDUsts;
extern int PDMdebug_on;


/* 
   Copies all the files of the assembly structure.
   The CIT attachements (1-level) and if it exists 
   (REVIEW) BOM attachments (n-th level) are handled.
   If the part happens to be atomic the graphics-file 
   associated with it is sent as a copy .

   INPUT:
		catalog			char(14)
		part_num		char(14)
		revision		char(14)
                storage_area            MEMptr
   OUTPUT:
	n_cofilename		*char;
	-> n_cofilename in "catalog"  of part_num,revision
*/
   
int	PDMcopy(file_list, file_buffer)
MEMptr  file_list;
MEMptr  *file_buffer;
{
int     status = PDM_S_SUCCESS;

  _pdm_debug("in the function PDMcopy", 0);

  if (PDMdebug_on)
    {
    PDUprint_storage_area();
    MEMprint_buffer("file buffer", file_list, PDU_DEBUG_FILE);
    }

  /* Display Message */
  PDUmessage(PDS_M_COPY_FILE, 's');

  /* load exec structure */
  PDUload_exec_structure("", "", "", "", "","","",0, 0);

  /* call PDM function */
  _pdm_debug("calling PDMcopy_file", 0);
  PDUdeactivate_stop_sign();
  status = PDMcopy_file(file_list, file_buffer);
  _pdm_status("PDMcopy_file", status);
  PDUactivate_stop_sign();

  if (PDMdebug_on)
    MEMprint_buffer("filename buffer", *file_buffer, PDU_DEBUG_FILE);

  if (status != PDM_S_SUCCESS)
    {
    MEMclose(file_buffer);
    if (file_list)
      MEMclose(&file_list);
    PDUmessage(status, 's');
    return(status);
    }

  /* Display Message */
  PDUmessage(PDM_E_CLEAR_FIELD, 's');

  _pdm_debug ("PDMcopy: returning SUCCESS", 0);
  return (status);
  }
  
/* 
   IF p_seqno = 0
	
		The 1-level file will be sent to the WS
		catalog,part_num,revision will specify the part
		whose file needs to be copied

   ELSE p_seqno = "p_seqno" in ACTIVE BOM of the part specified

		IF attach_type  = 0
		
		   	The 1-level file will be sent to the WS

		ELSE

			The assembly structure of the part is scanned 
			and all the attached ref-files are sent to WS

		For both the cases :

		catalog,part_num,revision determine the part whose 
		BOM is to be queried

		AND the part info is from the A-BOM

   INPUT:

		p_seqno			integer
		attach_type		integer
		catalog			char(14)
		part_num		char(14)
		revision		char(14)
		storage_name	char(14)
		node_name		char(14)
		user_name		char(14)
		passwd			char(25)
		path_name		char(100)

   OUTPUT:

   file_bufr contains the parts & file descriptions.
   The first row is for the part in question

	format of the file_bufr is as follows:
	
	n_catalogname		char(14)
	n_itemname			char(14)
	n_itemrev			char(14)
	p_seqno				integer   = 0 for cit attachment
								  > 0 for bom attachment 
	n_cofilename		char(14)  name of the file on WS
	
	p_parttype			char(1)
*/
   
int	PDMrcopy_attach(local_files, status_buffer)

MEMptr *status_buffer;
MEMptr local_files;
  
{
        extern struct PDUrefresh *refresh;
        extern int      PDM_debug_on;
        extern MEMptr   PDU_storage_area;
	int status = PDM_S_SUCCESS;

        _pdm_debug("In the PDMrcopy_attach function", 0);

        if (PDM_debug_on)
           MEMprint_buffer("local files buffer", local_files, PDU_DEBUG_FILE);

  	/* Display Message */
  	PDUmessage(PDS_M_COPY_ATTACH, 's');

	/* load exec structure */
	PDUload_exec_structure("", "", "", "", "","","",0, 0);

	status = PDMcopy_attach(local_files, status_buffer);
	_pdm_status("PDMcopy_attach", status);
  
	if (status != PDM_S_SUCCESS)
          {
          PDUmessage(status, 's');
          return(status);
          }

  	/* Display Message */
  	PDUmessage(PDM_E_CLEAR_FIELD, 's');

	_pdm_debug ("PDMrcopy_attach: returning SUCCESS", 0);
	return (status);
}

