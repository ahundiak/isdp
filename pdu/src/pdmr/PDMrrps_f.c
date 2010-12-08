#include <stdio.h>

#include "MEMstruct.h"
#include "PDMcommand.h"
#include "PDUerror.h"
#include "PDUsts_st.h"
#include "MEMerrordef.h"
#include "PDUproto.h"
#include "PDMproto.h"

static long status;
extern PDUsts_ptr PDUsts;

int PDMopen_report_buffer(type,bufr)
int		type;
MEMptr	*bufr;
{
	switch(type)
	{
		case 0:
				status = MEMopen(bufr,1024);
				if(status != MEM_S_SUCCESS)
				{
					return(PDM_E_OPEN_BUFFER);
				}

				status = MEMwrite_format(*bufr,"report_name","char(20)");
				if(status == MEM_S_SUCCESS)
				status = MEMwrite_format(*bufr,"n_application","char(3)");
				if(status == MEM_S_SUCCESS)
				status = MEMwrite_format(*bufr,"n_type","char(1)");
				if(status == MEM_S_SUCCESS)
				status = MEMwrite_format(*bufr,"n_apptype","char(1)");
				if(status == MEM_S_SUCCESS)
				status = MEMwrite_format(*bufr,"n_addmod","char(1)");
				if(status == MEM_S_SUCCESS)
				status = MEMwrite_format(*bufr,"n_saname","char(40)");
				if(status != MEM_S_SUCCESS)
				{
					MEMclose(bufr);
					return(PDM_E_WRITE_FORMAT);
				}
				break;
		case 1:
				status = MEMopen(bufr,1024);
				if(status != MEM_S_SUCCESS)
				{
					return(PDM_E_OPEN_BUFFER);
				}
				status = MEMwrite_format(*bufr,"report_name","char(20)");
				if(status == MEM_S_SUCCESS)
				status = MEMwrite_format(*bufr,"n_application","char(3)");
				if(status == MEM_S_SUCCESS)
				status = MEMwrite_format(*bufr,"n_type","char(1)");
				if(status == MEM_S_SUCCESS)
				status = MEMwrite_format(*bufr,"n_apptype","char(1)");
				if(status == MEM_S_SUCCESS)
				status = MEMwrite_format(*bufr,"n_saname","char(40)");
				if(status != MEM_S_SUCCESS)
				{
					MEMclose(bufr);
					return(PDM_E_WRITE_FORMAT);
				}
				break;
		case 2:
				status = MEMopen(bufr,1024);
				if(status != MEM_S_SUCCESS)
				{
					return(PDM_E_OPEN_BUFFER);
				}
				status = MEMwrite_format(*bufr,"report_name","char(20)");
				if(status == MEM_S_SUCCESS)
				status = MEMwrite_format(*bufr,"table_name","char(40)");
				if(status  == MEM_S_SUCCESS)
				status = MEMwrite_format(*bufr,"grp_name","char(40)");
				if(status != MEM_S_SUCCESS)
				{
					MEMclose(bufr);
					return(PDM_E_WRITE_FORMAT);
				}
				break;
	case 3:
				status = MEMopen(bufr,1024);
				if(status != MEM_S_SUCCESS)
				{
					return(PDM_E_OPEN_BUFFER);
				}
				status = MEMwrite_format(*bufr,"buff_flag","integer");
				if(status == MEM_S_SUCCESS)
				status = MEMwrite_format
						(*bufr,"search_str","char(512)");
				if(status == MEM_S_SUCCESS)
				status = MEMwrite_format
						(*bufr,"sort_str","char(512)");
				if(status == MEM_S_SUCCESS)
				status = MEMwrite_format(*bufr,"type","integer");
			    if(status != MEM_S_SUCCESS)
				{
					MEMclose(bufr);
					return(PDM_E_WRITE_FORMAT);
				}
				break;

		default:
				return(PDM_E_FAILURE);

	}
	return(PDM_S_SUCCESS);
}

