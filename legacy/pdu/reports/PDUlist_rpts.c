#include	<stdio.h>
#include	"PDUerror.h"
#include        "PDUcommand.h"
#include	"PDUfile_def.h"
#include	"PDUstr.h"
#include	"MEMerrordef.h"
#include	"PDUproto.h"
#include	"PDMproto.h"

int PDUlist_reports(type, list, count)
  int		type; /* i - type of report */
  char		***list; /* o - list of report names */
  int		*count; /* i - number of report names */
  {
    int		status = PDM_S_SUCCESS;
    int		row;
    char	*search_str = NULL;
    /*char	*sort_str = NULL;			APOGEE */
    /*MEMptr	rep_def = NULL;				APOGEE */
    MEMptr	output_bufr = NULL;
    /*int	col;					APOGEE */
    char	**data;
    /*char	**col_data;				APOGEE */
    char	**names;
    extern int	PDM_debug_on;

    /* setup the search and sort criteria */    
    switch (type)
      {
	case LOC_FORMAT_LIST:
		search_str = 
	  "where n_application = 'PDM' and n_type = 'R' and n_apptype = 'L'";
		break;

        case PDC_M_DELETE_BOM_FORMAT:
		search_str = 
	  "where n_application = 'PDM' and n_type = 'R' and n_apptype = 'B'";
		break;

	case PDC_M_BOM_PRINT:
        case PDC_M_DELETE_BOMPRINT_FORMAT:
		search_str = 
	  "where n_application = 'PDM' and n_type = 'R' and n_apptype = 'P'";
		break;

	case PDC_M_BOM_SUMMARY_BOM:
        case PDC_M_DEL_BOM_SUM_PR_FORM:
		search_str = 
	  "where n_application = 'PDM' and n_type = 'R' and n_apptype = 'S'";
		break;

	case PDC_M_BOM_WHERE_USED_ASSEM:
        case PDC_M_DEL_BOM_WHERE_USED_PR_FORM:
		search_str = 
	  "where n_application = 'PDM' and n_type = 'R' and n_apptype = 'U'";
		break;

	case PDC_M_BOM_WHERE_HIGH_LEV:
        case PDC_M_DEL_BOM_WHERE_BOM_PR_FORM:
		search_str = 
	  "where n_application = 'PDM' and n_type = 'R' and n_apptype = 'W'";
		break;

	case PDC_M_BOM_PARTS_LIST:
        case PDC_M_DEL_BOM_PARTS_LIST_PR_FORM:
		search_str = 
	  "where n_application = 'PDM' and n_type = 'R' and n_apptype = 'O'";
		break;

	case LOC_SEARCH_LIST:
		search_str = 
	  "where n_application = 'PDM' and n_type = 'W' and n_apptype = 'L'";
		break;

	case LOC_SORT_LIST:
		search_str = 
	  "where n_application = 'PDM' and n_type = 'O' and n_apptype = 'L'";
		break;

	case CAT_FORMAT_LIST:
		search_str = 
	  "where n_application = 'PDM' and n_type = 'R' and n_apptype = 'C'";
		break;
 
	case CAT_SEARCH_LIST:
		search_str = 
	  "where n_application = 'PDM' and n_type = 'W' and n_apptype = 'C'";
		break;

	case CAT_SORT_LIST:
		search_str = 
	  "where n_application = 'PDM' and n_type = 'O' and n_apptype = 'C'";
		break;

	default:
		return(PDM_E_INVALID_TYPE);
      }
 
    /* prepare the report definition buffer */
/*
    status = PDUsetup_report_definition(3, &rep_def, "", "", "", "",
					"", "", search_str, "n_reportname");
    _pdm_status("PDUsetup_report_definition", status);

    status = PDMlist_reports(rep_def, &output_bufr);
    _pdm_status("PDMlist_reports", status);
*/
    status = PDMsql_query("nfmreports", 
	"n_reportname, n_type, n_application, n_apptype",
	search_str, "order by n_reportname", &output_bufr);
    _pdm_status("PDMsql_query", status);

    if (status != PDM_S_SUCCESS)
      {
/*
        MEMclose(&rep_def);
*/
	MEMclose(&output_bufr);
        return(status);
      }

    if (PDM_debug_on)
      MEMprint_buffer("output list", output_bufr, PDU_DEBUG_FILE);
/*    
    status = MEMreset_buffer_no(output_bufr, 2);
    _pdm_status("MEMreset_buffer_no", status);

    if (status != MEM_S_SUCCESS)
      {
        MEMclose(&rep_def);
        return(PDM_E_RESET_BUFFER);
      }
*/

    if (output_bufr->rows == 0)
      {
	*list = NULL;
        *count = 0;
        return(PDM_S_SUCCESS);
      }

    status = MEMbuild_array(output_bufr);
    _pdm_status("MEMbuild_array", status);

    data = (char **) output_bufr->data_ptr;
/*
    col_data = (char **) output_bufr->column_ptr;

    for (col = 0; col < output_bufr->columns; ++col)
      if (strcmp(col_data[col], PDU_NFM_RPTNAME) == 0)
        break;
*/
    names = (char **) malloc ( output_bufr->rows * sizeof(char *));
    memset(names, NULL, (output_bufr->rows * sizeof(char *)));
  
    for (row = 0; row < output_bufr->rows; ++row)
      PDUfill_in_string(&names[row], data[(output_bufr->columns * row) + 0]);

    *list = names;
    *count = output_bufr->rows;

    return(PDM_S_SUCCESS);
  }

int PDUlist_report_buffer(type, output_bufr)
  int		type;                    /* type of report */
  MEMptr       *output_bufr;
  {
    int		status = PDM_S_SUCCESS;
    char	*search_str = NULL;
    extern int	PDM_debug_on;

    _pdm_debug("In the function PDUlist_report_buffer", 0);

    /* setup the search and sort criteria */    
    switch (type)
      {
	case LOC_SEARCH_LIST:
		search_str = 
  	"where n_application = 'PDM' and n_type = 'W' and n_reportdesc = 'L'";
		break;

	case LOC_SORT_LIST:
		search_str = 
  	"where n_application = 'PDM' and n_type = 'O' and n_reportdesc = 'L'";
		break;

	case CAT_SEARCH_LIST:
		search_str = 
	  "where n_application = 'PDM' and n_type = 'W' and n_reportdesc = 'C'";
		break;

	case CAT_SORT_LIST:
		search_str = 
	  "where n_application = 'PDM' and n_type = 'O' and n_reportdesc = 'C'";
		break;

	default:
		return(PDM_E_INVALID_TYPE);
      }
 
    status = PDMsql_query("nfmreports", "n_reportname",
	/*"n_reportname, n_type, n_application, n_reportdesc",*/
	search_str, "order by n_reportname", output_bufr);
    _pdm_status("PDMsql_query", status);

    if (status != PDM_S_SUCCESS)
      {
	MEMclose(output_bufr);
        return(status);
      }

    if (PDM_debug_on)
      MEMprint_buffer("output list", *output_bufr, PDU_DEBUG_FILE);

    if ((*output_bufr)->rows == 0)
        *output_bufr = NULL;

    return(PDM_S_SUCCESS);
}
