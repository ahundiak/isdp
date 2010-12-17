#include "PDUerror.h"
#include "NFMerrordef.h"
#include "PDMproto.h"

extern int	PDMdebug_on;
extern char PDM_DEBUG_FILE[];
static	long   status;
static  char   s[1024];

int  PDMstop_transaction(pdm_type)
long pdm_type;
{
	PDMdebug("ENTER:PDMstop_transaction\n");
	status = NFMstop_transaction(pdm_type);
	if(status != NFM_S_SUCCESS)
	{
		sprintf(s,"NFMstop_transaction failed status %d\n",status);
		PDMdebug(s);
		return(status);
	}
	PDMdebug("EXIT:PDMstop_transaction\n");
	return(PDM_S_SUCCESS);
}

int  PDMstart_transaction(pdm_type)
long pdm_type;
{
	PDMdebug("ENTER:PDMstart_transaction\n");
	status = NFMstart_transaction(pdm_type);
	if(status != NFM_S_SUCCESS)
	{
		sprintf(s,"NFMstart_transaction failed status %d\n",status);
		PDMdebug(s);
		return(status);
	}
	PDMdebug("EXIT:PDMstart_transaction\n");
	return(PDM_S_SUCCESS);
}

int PDMrollback_transaction(pdm_type)
long	pdm_type;
{
	PDMdebug("ENTER:PDMrollback_transaction\n");
	status = NFMrollback_transaction(pdm_type);
	if(status != NFM_S_SUCCESS)
	{
		sprintf(s,"NFMrollback_transaction failed status %d\n",
		status);
		PDMdebug(s);
		return(status);		
	}
	PDMdebug("EXIT:PDMrollback_transaction\n");
	return(PDM_S_SUCCESS);
}

