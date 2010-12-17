#include <stdio.h>

#include "MEMstruct.h"
#include "PDMcommand.h"
#include "PDUerror.h"
#include "PDUsts_st.h"
#include "PDMmessage.h"
#include "MEMerrordef.h"
#include "MSGstruct.h"
#include "PDUproto.h"
#include "PDMproto.h"

extern PDUsts_ptr PDUsts;


/*
	INPUT : MEMptr		pdm_bufr;

			format:     buff_flag		integer;
						search_str		char(512)
						sort_str		char(512)
						type			integer

			 ->	PDMopen_report_buffer(3,&pdm_bufr);			

	OUTPUT:	return_buffer

	return_buffer is split as follows:

(a)	if buff_flag was set to  0

	  PDMsplit_data_buffers(return_buffer,			 
			 page_list,
			 title_list,
			 header_list,
			 footer_list,
			 select_list,
			 grp_begin_list,
			 grp_text_list,
			 eop_text_list,
			 eor_text_list,
			 list);

(b) if buff_flag was set to 1

	  PDMsplit_create_buffers(return_buffer,			 
			 title_list,
			 header_list,
			 footer_list,
			 select_list,
			 grp_begin_list,
			 grp_text_list,
			 eop_text_list,
			 eor_text_list,
			 list);

(c) if buff_flag was set to 2
		
		return_buffer = select buffer ??
*/

int PDMlist_reports(templatetype,return_buffer)

        char            *templatetype;
	MEMptr		*return_buffer;
{
	int		status = PDM_S_SUCCESS;

	_pdm_debug("ENTER:PDMlist_reports", 0);

	/* load exec structure */
	PDUload_exec_structure("", "", "", "", "","",templatetype,0, 0);

        PDUmessage(PDS_M_LIST_REPORTS, 's');

	_pdm_debug("calling PDMslist_reports", 0);
	status = PDMslist_reports(return_buffer);
	_pdm_status("PDMslist_reports", status);

	if (status != PDM_S_SUCCESS)
	  {
	  PDUmessage(status, 's');
	  MEMclose(return_buffer);
	  return(status);
	  }

	_pdm_debug("EXIT:PDMlist_reports", 0);
	return(status);
}

