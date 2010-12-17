#include	<stdio.h>
#include	<PDUstr.h>
#include	<PDUerror.h>
#include	<PDUfile_def.h>
#include	<MEMerrordef.h>
#include	<PDUproto.h>
#include	<PDMproto.h>

extern int PDM_debug_on;

int PDUsetup_report_definition(type, report_def, report_name, nfm_type, 
				pdm_type, add_mod, table_name, grp_name, 
				search_string, sort_string)
  int		type;
  MEMptr	*report_def;
  char		*report_name;
  char		*nfm_type;
  char		*pdm_type;
  char		*add_mod;
  char		*table_name;
  char		*grp_name;
  char		*search_string;
  char		*sort_string;
  {
   int		status;
   MEMptr	rpt_def;
   char		*string = NULL;
   int		char_index = 0;

   if ((type != 3) && (strcmp(report_name,"") == 0))
     {
       *report_def = NULL;
       return(PDM_E_REPORT_NAME_NULL);
     }

   if ((type == 0) || (type == 1))
     {
        if ((strcmp(add_mod,"") == 0) && (type == 0))
          {
	    *report_def = NULL;
	    return(PDM_E_FAILURE); 
/*
            return(PDM_E_ADD_MOD_NULL);
*/
          }

	if (strcmp(nfm_type,"") == 0)
          {
	    *report_def = NULL;
            return(PDM_E_NFM_TYPE_NULL);
          }

	if (strcmp(pdm_type,"") == 0)
          {
	    *report_def = NULL;
            return(PDM_E_PDM_TYPE_NULL);
          } 
    }

    status = PDMopen_report_buffer(type, &rpt_def);
    _pdm_status("PDMopen_report_buffer", status);

    if (status != PDM_S_SUCCESS)
      {
	*report_def = NULL;
        MEMclose(&rpt_def);
        return(status);
      }
    
    if (PDM_debug_on)
      MEMprint_buffer("report definition", rpt_def,PDU_DEBUG_FILE);
  
    string = (char *) malloc (rpt_def->row_size);
    memset(string, NULL, rpt_def->row_size);

    char_index = 0;

    switch (type)
      {
	case 0:
        case 1:
		PDUadd_buffer_string(string, &char_index, report_name);
		PDUadd_buffer_string(string, &char_index, "PDM");
		PDUadd_buffer_string(string, &char_index, nfm_type);
		PDUadd_buffer_string(string, &char_index, pdm_type);
		if (type == 0)
  		  PDUadd_buffer_string(string, &char_index, add_mod);
		string[char_index++]= PDM_BUFFER_TERM;
		break;

        case 2:
		PDUadd_buffer_string(string, &char_index, report_name);
		PDUadd_buffer_string(string, &char_index, table_name);
		PDUadd_buffer_string(string, &char_index, grp_name);
		break;

	case 3:
                PDUadd_buffer_string(string, &char_index, "1");
		PDUadd_buffer_string(string, &char_index, search_string);
		PDUadd_buffer_string(string, &char_index, sort_string);
                PDUadd_buffer_string(string, &char_index, "0");
		break;

	default:
		*report_def = NULL;
		MEMclose(&rpt_def);
		return(PDM_E_INVALID_TYPE);
      }

    _pdm_debug("string <%s>", string);

    status = MEMwrite(rpt_def, string);
    _pdm_status("MEMwrite", status);

    free(string);

    if (status != MEM_S_SUCCESS)
      {
	*report_def = NULL;
 	MEMclose(&rpt_def);
	return(PDM_E_WRITE_BUFFER);
      }

    *report_def = rpt_def;

    return(PDM_S_SUCCESS);
  }
