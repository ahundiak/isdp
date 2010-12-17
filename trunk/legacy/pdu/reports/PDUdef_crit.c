#include	<stdio.h>
#include	<PDUstr.h>
#include	<PDUerror.h>
#include	<PDUfile_def.h>
#include	<MEMerrordef.h>
#include	<PDUproto.h>
#include	<PDMproto.h>

int PDUdefine_criteria_string(nfm_type, pdm_type, name, string, add_mod)
  char		*nfm_type;
  char		*pdm_type;
  char		*name;
  char		*string;
  char		*add_mod;
  {
    int		status;
    MEMptr	report_def = NULL;
/*
    MEMptr	tbl_bufr = NULL;
    MEMptr	grp_bufr = NULL;
    MEMptr	search_name_bufr = NULL;
    MEMptr	search_str_bufr = NULL;
    MEMptr	sort_name_bufr = NULL;
    MEMptr	sort_str_bufr = NULL;
*/
    MEMptr	str_bufr = NULL;
    extern int	PDM_debug_on;
    char        *line = NULL;
    char        *empty_string = NULL;

    _pdm_debug("in the function PDUdefine_criteria_string", 0);

    _pdm_debug("report_name = <%s>", name);

    status = PDUsetup_report_definition(0, &report_def, name, nfm_type, 
					pdm_type, add_mod, "","","","");
    _pdm_status("PDUsetup_report_definition", status);

    if (status != PDM_S_SUCCESS)
      {
      MEMclose(&report_def);
      return(PDM_E_SETUP_RPTDEF);
      }
/*
    status = PDUcreate_table_group_search_sort_buffers( &tbl_bufr, &grp_bufr, 
			&search_name_bufr, &search_str_bufr, &sort_name_bufr, 
			&sort_str_bufr);
    _pdm_status("PDUcreate_table_group_search_sort_buffers", status);

    if ( status != PDM_S_SUCCESS )
      {
        MEMclose(&report_def);
        MEMclose(&tbl_bufr);
        MEMclose(&grp_bufr);
        MEMclose(&search_name_bufr);
        MEMclose(&search_str_bufr);
        MEMclose(&sort_name_bufr);
        MEMclose(&sort_str_bufr);
        return(status);
      }

    if (strcmp( nfm_type, "W") == 0)
      str_bufr = search_str_bufr;

    if (strcmp( nfm_type, "O") == 0)
      str_bufr = sort_str_bufr;

    status = MEMbuild_array(str_bufr);
    _pdm_status("MEMbuild_array", status);

    if ( status == MEM_S_SUCCESS )
      {    
       status = MEMwrite_data(str_bufr,string,1,1);
       _pdm_status("MEMwrite_data", status);
      }

    if (status != MEM_S_SUCCESS)
      {
        MEMclose(&report_def);
        MEMclose(&tbl_bufr);
        MEMclose(&grp_bufr);
        MEMclose(&search_name_bufr);
        MEMclose(&search_str_bufr);
        MEMclose(&sort_name_bufr);
        MEMclose(&sort_str_bufr);
        return(status);
      }
*/

    /* format a buffer for the search string */
    status = PDUformat_buffer (PDU_SAVE_CRITERIA, &str_bufr);
    _pdm_status("PDUformat_buffer", status);

    if (status != PDM_S_SUCCESS)
      {
      PDUmessage(status, 's');
      MEMclose(&report_def);
      return(status);
      }

    line = (char*) malloc (str_bufr->row_size);
    memset(line, NULL, str_bufr->row_size);

    _pdm_debug("writing string to buffer", 0);
    _pdm_debug("search/sort string = <%s>", string);
    PDUfill_in_string(&empty_string, "");

    if (strcmp( nfm_type, "W") == 0)
      {
      sprintf(line, "%s\1%s\1%s\1%s\1%s\1",
                    empty_string,
                    empty_string,
                    string,
                    empty_string,
                    empty_string);
      }
    else
      {
      sprintf(line, "%s\1%s\1%s\1%s\1%s\1",
                    empty_string,
                    empty_string,
                    empty_string,
                    string,
                    empty_string);
      }

    _pdm_debug("line = <%s>", line);
    status = MEMwrite (str_bufr, line);

    if (status != MEM_S_SUCCESS)
      {
      _pdm_debug("Error writing to str buffer", 0);
      _pdm_status("MEMwrite_format ()", status);
      MEMclose(&report_def);
      status = PDM_E_WRITE_BUFFER;
      PDUmessage(status, 's');
      return(status);
      }

    if (PDM_debug_on)
      MEMprint_buffer("criteria buffer", str_bufr, PDU_DEBUG_FILE);

    status = PDMadd_criteria(report_def, str_bufr);
    _pdm_status("PDMadd_criteria", status);

    PDUmessage(status, 's');
/* removed this due to pointer message being printed to the screen - Mychelle*/
    /*MEMclose(&report_def);*/
/*
    MEMclose(&tbl_bufr);
    MEMclose(&grp_bufr);
    MEMclose(&search_name_bufr);
    MEMclose(&search_str_bufr);
    MEMclose(&sort_name_bufr);
    MEMclose(&sort_str_bufr);
*/
    
    return(status);
   }
