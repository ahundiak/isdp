/* This function is added to provide support for dynamic part manipulation. 
  
   Author: Jamal Shakra
   Date: 11/28/1990
*/

#include <stdio.h>

#include "MEMstruct.h"
#include "PDMcommand.h"
#include "PDUerror.h"
#include "PDUsts_st.h"
#include "MEMerrordef.h"
#include "PDUfile_def.h"
#include "PDUproto.h"
#include "PDMproto.h"

static char s[1024];
extern PDUsts_ptr PDUsts;
extern int PDMdebug_on;


int PDMget_dyn_attr_names(catalog, n_itemname,n_itemrev,dynamic_attr_buffer) 
					 
  char		*catalog;
  char		*n_itemname;
  char		*n_itemrev;
  MEMptr        *dynamic_attr_buffer;
  {
   int          status = PDM_S_SUCCESS;
   char         *dyn_table = NULL;


        _pdm_debug("In the function PDMget_dyn_attr_names",0);

	sprintf (s, "PDMget_dyn_attr_names: catalog = <%s>\n", catalog);
	_pdm_debug(s, 0);
	sprintf (s, "PDMget_dyn_attr_names: part num = <%s>\n", n_itemname);
	_pdm_debug(s, 0);
	sprintf (s, "PDMget_dyn_attr_names: revision = <%s>\n", n_itemrev);
	_pdm_debug(s, 0);

        /* Load PDUexec structure */
        PDUload_exec_structure("", catalog, "", "", "","", "", 0, 0);

        /* Get dynamic table name */
        status = PDMdyntable_for_catalog(&dyn_table);
        _pdm_status("PDMdyntable_for_catalog", status);

        if ( (status == PDM_S_SUCCESS) && (dyn_table) )
           {
            /* Get dynamic attr buffer */
            status = PDMget_pdcattr_buffer(dyn_table, dynamic_attr_buffer);
            _pdm_status("PDMget_pdcattr_buffer", status);
            if (*dynamic_attr_buffer == NULL)
              {
              _pdm_debug("dynamic attribute buffer is NULL", 0);
              status = PDM_S_SUCCESS;
              }
           }

        else
           {
            _pdm_debug("catalog <%s> has no dyn attrs", catalog);
            return(PDM_S_SUCCESS);
           }

        if (PDMdebug_on)
        MEMprint_buffer("dynamic_attr_buffer",*dynamic_attr_buffer,PDU_DEBUG_FILE);
	return (status);
  }
