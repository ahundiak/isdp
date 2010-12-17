#include		<stdio.h>
#include		"PDUerror.h"
#include		"MEMstruct.h"
#include		"MEMerrordef.h"
#include		"NFMerrordef.h"
#include		"SQLerrordef.h"
#include		"PDMproto.h"
#include		"PDUpdmrpro.h"

/* APOGEE START static 	long		RIScode; APOGEE END */
static  long		status;
/* APOGEE START static  int		curbuf_no; APOGEE END */
static  char		s[1024];
extern  int			PDMdebug_on;
extern	char		PDM_DEBUG_FILE[];


int	 PDMcopy_data_buffer(bufr1,bufr2)
MEMptr	bufr1;
MEMptr	*bufr2;
{
	char	**column_ptr;
	char	**format_ptr;
	char	**data;
	int		i;

	PDMdebug("ENTER:PDMcopy_data_buffer\n");
	status = MEMbuild_array(bufr1);
	if(status != MEM_S_SUCCESS)
	{
		sprintf(s,"MEMbuild_array failed status %d\n",status);
		PDMdebug(s);
		return(PDM_E_BUILD_ARRAY);
	}
	status = MEMopen(bufr2);
	if(status != MEM_S_SUCCESS)
	{
		sprintf(s,"MEMopen failed status %d\n",status);
		PDMdebug(s);
		return(PDM_E_BUILD_ARRAY);
	}
	column_ptr = (char **) bufr1->column_ptr;
	format_ptr = (char **) bufr1->format_ptr;
	data = (char **) bufr1->data_ptr;
	for(i=0;i<bufr1->columns;i++)
	{
		status = MEMwrite_format(*bufr2,column_ptr[i],format_ptr[i]);
		if(status != MEM_S_SUCCESS)
		{
			MEMclose(bufr2);
			sprintf(s,"MEMwrite_format failed status %d\n",status);
			PDMdebug(s);
			return(PDM_E_WRITE_FORMAT);
		}
	}
	PDMdebug("EXIT:PDMcopy_data_buffer\n");
	return(PDM_S_SUCCESS);
}
