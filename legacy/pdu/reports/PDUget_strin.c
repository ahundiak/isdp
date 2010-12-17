#include	<stdio.h>
#include	<PDUstr.h>
#include	<PDUerror.h>
#include	<PDUfile_def.h>
#include	<MEMerrordef.h>
#include	<PDUproto.h>
#include	<PDMproto.h>

extern int PDM_debug_on;

int PDUget_criteria_string(nfm_type, pdm_type, name, string)
  char		*nfm_type;
  char		*pdm_type;
  char		*name;
  char		**string;
  {
   int		status = PDM_S_SUCCESS;
   MEMptr	str_bufr = NULL;
   char		**str_data;
   int          column;

  _pdm_debug("pdm_type = <%s>", pdm_type);
/*
   status = PDUsetup_report_definition(1, &report_def, name, nfm_type, 
					pdm_type, "", "", "", "", "");
   _pdm_status("PDUsetup_report_definition", status);

   if ( status != PDM_S_SUCCESS )
     {
      *string = NULL;
      MEMclose(&report_def);
      return(PDM_E_SETUP_RPTDEF);
     }
*/

   status = PDMread_criteria(name, &str_bufr);
   _pdm_status("PDMread_criteria", status);

   if ( status != PDM_S_SUCCESS )
     {
       *string = NULL;
       MEMclose(&str_bufr);
       return(status);
     }   

   PDUmessage(status, 's');

   if (PDM_debug_on)
     MEMprint_buffer("string buffer", str_bufr, PDU_DEBUG_FILE);

   status = MEMbuild_array(str_bufr);
   _pdm_status("MEMbuild_array", status);
   
   if (status != MEM_S_SUCCESS)
     {
       MEMclose(&str_bufr);
       return(PDM_E_BUILD_BUFFER_ARRAY);
     }

   if (strcmp(nfm_type, "W") == 0)
     PDUget_buffer_col(str_bufr, "where_clause", &column);
   else
     PDUget_buffer_col(str_bufr, "order_by_clause", &column);

   PDUsetup_buffer(str_bufr, ROW, &str_data);
      
   if (column != -1)
     PDUfill_in_string(string, str_data[(str_bufr->columns * 0) + column]);
   else
     {
     status = PDM_E_COL_NOT_IN_BUFFER;
     return(status);
     }

   _pdm_debug("search/sort string = <%s>", *string);

   MEMclose(&str_bufr);

   return(PDM_S_SUCCESS);

  }
