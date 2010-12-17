#include <stdio.h>
#include "MEMstruct.h"
#include "PDUerror.h"
#include "MEMerrordef.h"
#include "SQLerrordef.h"
#include "NFMerrordef.h"
#include "NFMapi.h"
#include "PDUris_incl.h"
#include "PDMproto.h"

static char		s[1024];
static long		status;
/*static int		curbuf_no;*/

extern  int PDMdebug_on;
extern  char	PDM_DEBUG_FILE[];
extern  PDMexec_ptr PDMexec;


int PDMslist_reports(output_buffers)
MEMptr		*output_buffers;
{
        char            sql_str[512];
        char             apptype[3] = "";

	PDMdebug("ENTER:PDMslist_reports\n");
        sql_str[0] = '\0';
      
       sprintf(apptype, "%cF", PDMexec->drevision[0]);
 
     sprintf(sql_str, "%s ( %s = '%s' OR %s = '%s' ) %s ",
     "SELECT p_templatename, p_description FROM psurptopts WHERE ",
     " p_templatetype ", PDMexec->drevision,
     " p_templatetype ", apptype,
     " ORDER BY p_templatename");
        status = SQLquery(sql_str, output_buffers, 512);
	if(status != SQL_S_SUCCESS)
	{
		sprintf(s, "%s %d\n", 
		"SQLquery failed status ", status);
		PDMdebug(s);
		return(PDM_E_LIST_REPORTS);
	}			 
	PDMdebug("EXIT:PDMslist_reports\n");
	return(PDM_S_SUCCESS);


 }
