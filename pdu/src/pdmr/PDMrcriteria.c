#include <stdio.h>
#include "MEMstruct.h"
#include <PDMcommand.h>
#include <PDUcommand.h>
#include "PDMmessage.h"
#include "PDUerror.h"
#include "PDUsts_st.h"
#include "PDUstr.h"
#include "MEMerrordef.h"
#include "MSGstruct.h"
#include <PDUproto.h>
#include <PDMproto.h>

extern PDUsts_ptr PDUsts;
extern struct PDUrefresh  *refresh;


/*
	DESCRIPTION: This function reads an existing search/sort 
				 criteria.
	INPUT:
			char           Name of criteria report
	OUTPUT:
			MEMptr		criteria_buffer;			
*/

int	PDMread_criteria(crit_name,criteria_buffer)
	char		*crit_name;
	MEMptr		*criteria_buffer;
{
	int 		status = PDM_S_SUCCESS;

	_pdm_debug("ENTER:PDMread_criteria", 0);

        PDUmessage(PDS_M_READ_CRITERIA, 's');

	/* load exec structure */
	PDUload_exec_structure("",crit_name,"","", "", "", "", 0, 0);

	_pdm_debug("calling PDMsread_criteria", 0);
	status = PDMsread_criteria(criteria_buffer);
        _pdm_status("PDMsread_criteria", status);

	if (status != PDM_S_SUCCESS)
	  {
          PDUmessage(status, 's');
          return(status);
          }

        PDUmessage(PDM_E_CLEAR_FIELD, 's');

	_pdm_debug("EXIT:PDMread_criteria", 0);
	return(PDM_S_SUCCESS);
}

/*
	 This function is for adding a criteria on the server
	 the format is given in input buffers

	INPUT:

	MEMptr		pdm_bufr; -> PDMopen_report_buffer(0,&pdm_bufr)
	The fifth column is n_addmod should be 
					('M' or 'm' or 'A' or 'a')

	MEMptr		criteria_bufr -> search/sort buffer

	OUTPUT:
				return codes
*/

int	PDMadd_criteria(pdm_bufr,criteria_bufr)

	MEMptr		pdm_bufr;
	MEMptr		criteria_bufr;
{

	int		status = PDM_S_SUCCESS;

	_pdm_debug("ENTER:PDMadd_criteria", 0);

        if (refresh->command != PDC_M_SEARCH_ACROSS_CATS)
          PDUmessage(PDS_M_ADD_CRITERIA, 's');
	
	/* load exec structure */
	PDUload_exec_structure("","","","", "", "", "", 0, 0);

	_pdm_debug("calling PDMsadd_criteria", 0);
	status = PDMsadd_criteria(pdm_bufr, criteria_bufr);
        _pdm_status("PDMsadd_criteria", status);

	if (status != PDM_S_SUCCESS)
	  {
          PDUmessage(status, 's');
          return(status);
          }

        PDUmessage(PDM_E_CLEAR_FIELD, 's');
	_pdm_debug("EXIT:PDMadd_criteria", 0);
	return(status);
}

int PDMvalidate_criteria_name(name, nfm_type, pdm_type)
  char     *name;
  char     *nfm_type;
  char     *pdm_type;
{
  int		status = PDM_S_SUCCESS;

  _pdm_debug("in the function PDMvalidate_criteria_name", 0);

  _pdm_debug("criteria name = <%s>", name);
  _pdm_debug("nfm_type = <%s>", nfm_type);
  _pdm_debug("pdm_type = <%s>", pdm_type);

  /* Display Message */
  PDUmessage(PDS_M_VALID_CRITERIA, 's');

  /* load exec structure */
  PDUload_exec_structure("", name, nfm_type, pdm_type, "", "", "", 0, 0);

  _pdm_debug("calling PDMvalidate_querys", 0);
  status = PDMvalidate_querys();
  _pdm_status("PDMvalidate_querys", status);

   if (status != PDM_S_SUCCESS)
     {
     PDUmessage(status, 's');
     return(status);
     }

  /* Display Message */
  PDUmessage(PDM_E_CLEAR_FIELD, 's');

  _pdm_debug ("PDMvalidate_criteria_name: returning SUCCESS", 0);
  return (status);
}
