#include <stdio.h>
#include "MEMstruct.h"
#include "PDUerror.h"
#include "MEMerrordef.h"
#include "SQLerrordef.h"
#include "PDMdbs_err.h"
#include "PDMproto.h"
#include "rMRPstr.h"

static	char	s[1024];
static	long	status;
static	int	curbuf_no;

int	PDMappend_10_buffers(ret_bufr,b1,b2,b3,b4,b5,b6,b7,b8,b9,b10)
MEMptr		b1;
MEMptr		b2;
MEMptr		b3;
MEMptr		b4;
MEMptr		b5;
MEMptr		b6;
MEMptr		b7;
MEMptr		b8;
MEMptr		b9;
MEMptr		b10;
MEMptr		*ret_bufr;
{
	PDMdebug("ENTER:PDMappend_10_buffers\n");
	status = MEMsplit_copy_buffer(b1,ret_bufr,0);
	if(status != MEM_S_SUCCESS)
	{
		sprintf(s,"MEMsplit_copy_buffers failed status %d",status);
		PDMdebug(s);
		return(PDM_E_COPY_BUFFER);
	}
	status = MEMappend(b2,*ret_bufr);
	if(status == MEM_S_SUCCESS)
	status = MEMappend(b3,*ret_bufr);
	if(status == MEM_S_SUCCESS)
	status = MEMappend(b4,*ret_bufr);
	if(status == MEM_S_SUCCESS)
	status = MEMappend(b5,*ret_bufr);
	if(status == MEM_S_SUCCESS)
	status = MEMappend(b6,*ret_bufr);
	if(status == MEM_S_SUCCESS)
	status = MEMappend(b7,*ret_bufr);
	if(status == MEM_S_SUCCESS)
	status = MEMappend(b8,*ret_bufr);
	if(status == MEM_S_SUCCESS)
	status = MEMappend(b9,*ret_bufr);
	if(status == MEM_S_SUCCESS)
	status = MEMappend(b10,*ret_bufr);
	if(status != MEM_S_SUCCESS)
	{
		MEMclose(ret_bufr);
		sprintf(s,"MEMappend failed status %d",status);
		PDMdebug(s);
		return(PDM_E_APPEND_BUFFER);
	}
	PDMdebug("EXIT:PDMappend_10_buffers\n");
	return(PDM_S_SUCCESS);
}

/*
	 Internal function to split copy all the 10-report MEMbuffers 
*/

int	PDMsplit_10_buffers(ws_buffer,b1,b2,b3,b4,
				b5,b6,b7,b8,b9,b10)
MEMptr		ws_buffer;
MEMptr		*b1;
MEMptr		*b2;
MEMptr		*b3;
MEMptr		*b4;
MEMptr		*b5;
MEMptr		*b6;
MEMptr		*b7;
MEMptr		*b8;
MEMptr		*b9;
MEMptr		*b10;
{
	
	PDMdebug("ENTER:PDMsplit_10_buffers\n");
	status = MEMbuild_array(ws_buffer);
	if(status != MEM_S_SUCCESS)
	{
		sprintf(s,"%s %d\n",
		"MEMbuild_array failed status ",status);
		PDMdebug(s);
		return(PDM_E_BUILD_ARRAY);
	}	
	status = MEMsplit_copy_buffer(ws_buffer,b1,0);
	if(status != MEM_S_SUCCESS)
	{
		sprintf(s,"%s %d\n",
		"MEMbuild_array failed status ",status);
		PDMdebug(s);
		return(PDM_E_COPY_BUFFER);
	}
	status = MEMreset_buffer(ws_buffer,&curbuf_no);
	if(status != MEM_S_SUCCESS)
	{
		MEMclose(b1);
		sprintf(s,"%s %d\n",
		"MEMreset_buffer failed status ",status);
		PDMdebug(s);
		return(PDM_E_RESET_BUFFER);
	}	
    status = MEMsplit_copy_buffer(ws_buffer,b2,0);
	if(status != MEM_S_SUCCESS)
	{
		MEMclose(b1);
		sprintf(s,"%s %d\n",
		"MEMsplit_copy_buffer failed status ",status);
		PDMdebug(s);
		return(PDM_E_COPY_BUFFER);
	}
	status = MEMreset_buffer(ws_buffer,&curbuf_no);
	if(status != MEM_S_SUCCESS)
	{
		MEMclose(b1);		MEMclose(b2);
		sprintf(s,"%s %d\n",
		"MEMreset_buffer failed status ",status);
		PDMdebug(s);
		return(PDM_E_RESET_BUFFER);
	}	
    status = MEMsplit_copy_buffer(ws_buffer,b3,0);
	if(status != MEM_S_SUCCESS)
	{
		MEMclose(b1);MEMclose(b2);
		sprintf(s,"%s %d\n",
		"MEMsplit_copy_buffer failed status ",status);
		PDMdebug(s);
		return(PDM_E_COPY_BUFFER);
	}
	status = MEMreset_buffer(ws_buffer,&curbuf_no);
	if(status != MEM_S_SUCCESS)
	{
		MEMclose(b1);	MEMclose(b2); MEMclose(b3);
		sprintf(s,"%s %d\n",
		"MEMreset_buffer failed status ",status);
		PDMdebug(s);
		return(PDM_E_RESET_BUFFER);
	}	
    status = MEMsplit_copy_buffer(ws_buffer,b4,0);
	if(status != MEM_S_SUCCESS)
	{
		MEMclose(b1);	MEMclose(b2);MEMclose(b3);
		sprintf(s,"%s %d\n",
		"MEMsplit_copy_buffer failed status ",status);
		PDMdebug(s);
		return(PDM_E_COPY_BUFFER);
	}
	status = MEMreset_buffer(ws_buffer,&curbuf_no);
	if(status != MEM_S_SUCCESS)
	{
		MEMclose(b1);MEMclose(b2);MEMclose(b3);MEMclose(b4);
		sprintf(s,"%s %d\n",
		"MEMreset_buffer failed status ",status);
		PDMdebug(s);
		return(PDM_E_RESET_BUFFER);
	}	
    status = MEMsplit_copy_buffer(ws_buffer,b5,0);
	if(status != MEM_S_SUCCESS)
	{
		MEMclose(b1);MEMclose(b2);MEMclose(b3);MEMclose(b4);
		sprintf(s,"%s %d\n",
		"MEMsplit_copy_buffer failed status ",status);
		PDMdebug(s);
		return(PDM_E_COPY_BUFFER);
	}
	status = MEMreset_buffer(ws_buffer,&curbuf_no);
	if(status != MEM_S_SUCCESS)
	{
		MEMclose(b1);MEMclose(b2);	MEMclose(b3);MEMclose(b4);
		MEMclose(b5);
		sprintf(s,"%s %d\n",
		"MEMreset_buffer failed status ",status);
		PDMdebug(s);
		return(PDM_E_RESET_BUFFER);
	}	
    status = MEMsplit_copy_buffer(ws_buffer,b6,0);
	if(status != MEM_S_SUCCESS)
	{
		MEMclose(b1);MEMclose(b2);MEMclose(b3);	MEMclose(b4);
		MEMclose(b5);
		sprintf(s,"%s %d\n",
		"MEMsplit_copy_buffer failed status ",status);
		PDMdebug(s);
		return(PDM_E_COPY_BUFFER);
	}
	status = MEMreset_buffer(ws_buffer,&curbuf_no);
	if(status != MEM_S_SUCCESS)
	{
		MEMclose(b1);MEMclose(b2);MEMclose(b3);MEMclose(b4);
		MEMclose(b5);		MEMclose(b6);
		sprintf(s,"%s %d\n",
		"MEMreset_buffer failed status ",status);
		PDMdebug(s);
		return(PDM_E_RESET_BUFFER);
	}	
    status = MEMsplit_copy_buffer(ws_buffer,b7,0);
	if(status != MEM_S_SUCCESS)
	{
		MEMclose(b1);MEMclose(b2);MEMclose(b3);MEMclose(b4);
		MEMclose(b5);MEMclose(b6);
		sprintf(s,"%s %d\n",
		"MEMsplit_copy_buffer failed status ",status);
		PDMdebug(s);
		return(PDM_E_COPY_BUFFER);
	}
	status = MEMreset_buffer(ws_buffer,&curbuf_no);
	if(status != MEM_S_SUCCESS)
	{
		MEMclose(b1);MEMclose(b2);MEMclose(b3);	MEMclose(b4);
		MEMclose(b5);MEMclose(b6);MEMclose(b7);
		sprintf(s,"%s %d\n",
		"MEMreset_buffer failed status ",status);
		PDMdebug(s);
		return(PDM_E_RESET_BUFFER);
	}	
    status = MEMsplit_copy_buffer(ws_buffer,b8,0);
	if(status != MEM_S_SUCCESS)
	{
		MEMclose(b1);MEMclose(b2);	MEMclose(b3);MEMclose(b4);
		MEMclose(b5);MEMclose(b6); MEMclose(b8);
		sprintf(s,"%s %d\n",
		"MEMsplit_copy_buffer failed status ",status);
		PDMdebug(s);
		return(PDM_E_COPY_BUFFER);
	}
	status = MEMreset_buffer(ws_buffer,&curbuf_no);
	if(status != MEM_S_SUCCESS)
	{
		MEMclose(b1);MEMclose(b2);MEMclose(b3);	MEMclose(b4);
		MEMclose(b5);MEMclose(b6);MEMclose(b7);
		sprintf(s,"%s %d\n",
		"MEMreset_buffer failed status ",status);
		PDMdebug(s);
		return(PDM_E_RESET_BUFFER);
	}	
    status = MEMsplit_copy_buffer(ws_buffer,b9,0);
	if(status != MEM_S_SUCCESS)
	{
		MEMclose(b1);MEMclose(b2);	MEMclose(b3);MEMclose(b4);
		MEMclose(b5);MEMclose(b6); MEMclose(b7);MEMclose(b8);
		sprintf(s,"%s %d\n",
		"MEMsplit_copy_buffer failed status ",status);
		PDMdebug(s);
		return(PDM_E_COPY_BUFFER);
	}
	status = MEMreset_buffer(ws_buffer,&curbuf_no);
	if(status != MEM_S_SUCCESS)
	{
		MEMclose(b1);MEMclose(b2);MEMclose(b3);	MEMclose(b4);
		MEMclose(b5);MEMclose(b6);MEMclose(b7); MEMclose(b8);
		MEMclose(b9);
		sprintf(s,"%s %d\n",
		"MEMreset_buffer failed status ",status);
		PDMdebug(s);
		return(PDM_E_RESET_BUFFER);
	}	
    status = MEMsplit_copy_buffer(ws_buffer,b10,0);
	if(status != MEM_S_SUCCESS)
	{
		MEMclose(b1);MEMclose(b2);	MEMclose(b3);MEMclose(b4);
		MEMclose(b5);MEMclose(b6); MEMclose(b7);MEMclose(b8);
		MEMclose(b9);
		sprintf(s,"%s %d\n",
		"MEMsplit_copy_buffer failed status ",status);
		PDMdebug(s);
		return(PDM_E_COPY_BUFFER);
	}
	PDMdebug("EXIT:PDMsplit_10_buffers\n");
	return(PDM_S_SUCCESS);
}

/*

 Internal function to split copy all the 15-report MEMbuffers 

*/

int	PDMsplit_16_buffers(ws_buffer,b1,b2,b3,b4,b5,b6,
						b7,b8,b9,b10,b11,b12,b13,b14,b15,b16)
MEMptr		ws_buffer;
MEMptr		*b1;
MEMptr		*b2;
MEMptr		*b3;
MEMptr		*b4;
MEMptr		*b5;
MEMptr		*b6;
MEMptr		*b7;
MEMptr		*b8;
MEMptr		*b9;
MEMptr		*b10;
MEMptr		*b11;
MEMptr		*b12;
MEMptr		*b13;
MEMptr		*b14;
MEMptr		*b15;
MEMptr		*b16;
{
	
	PDMdebug("ENTER:PDMsplit_16_buffers\n");
	status = MEMbuild_array(ws_buffer);
	if(status != MEM_S_SUCCESS)
	{
		PDMdebug("PDMsplit_16_buffers:\n");
		sprintf(s,"%s %d\n",
		"MEMbuild_array failed status ",status);
		PDMdebug(s);
		return(PDM_E_BUILD_ARRAY);
	}	
	status = MEMsplit_copy_buffer(ws_buffer,b1,0);
	if(status != MEM_S_SUCCESS)
	{
		PDMdebug("PDMsplit_16_buffers:\n");
		sprintf(s,"%s %d\n",
		"MEMbuild_array failed status ",status);
		PDMdebug(s);
		return(PDM_E_COPY_BUFFER);
	}
	status = MEMreset_buffer(ws_buffer,&curbuf_no);
	if(status != MEM_S_SUCCESS)
	{
		MEMclose(b1);
		PDMdebug("PDMsplit_16_buffers:\n");
		sprintf(s,"%s %d\n",
		"MEMreset_buffer failed status ",status);
		PDMdebug(s);
		return(PDM_E_RESET_BUFFER);
	}	
    status = MEMsplit_copy_buffer(ws_buffer,b2,0);
	if(status != MEM_S_SUCCESS)
	{
		MEMclose(b1);
		PDMdebug("PDMsplit_16_buffers:\n");
		sprintf(s,"%s %d\n",
		"MEMsplit_copy_buffer failed status ",status);
		PDMdebug(s);
		return(PDM_E_COPY_BUFFER);
	}
	status = MEMreset_buffer(ws_buffer,&curbuf_no);
	if(status != MEM_S_SUCCESS)
	{
		MEMclose(b1);		MEMclose(b2);
		PDMdebug("PDMsplit_16_buffers:\n");
		sprintf(s,"%s %d\n",
		"MEMreset_buffer failed status ",status);
		PDMdebug(s);
		return(PDM_E_RESET_BUFFER);
	}	
    status = MEMsplit_copy_buffer(ws_buffer,b3,0);
	if(status != MEM_S_SUCCESS)
	{
		MEMclose(b1);MEMclose(b2);
		PDMdebug("PDMsplit_16_buffers:\n");
		sprintf(s,"%s %d\n",
		"MEMsplit_copy_buffer failed status ",status);
		PDMdebug(s);
		return(PDM_E_COPY_BUFFER);
	}
	status = MEMreset_buffer(ws_buffer,&curbuf_no);
	if(status != MEM_S_SUCCESS)
	{
		MEMclose(b1);	MEMclose(b2); MEMclose(b3);
		PDMdebug("PDMsplit_16_buffers:\n");
		sprintf(s,"%s %d\n",
		"MEMreset_buffer failed status ",status);
		PDMdebug(s);
		return(PDM_E_RESET_BUFFER);
	}	
    status = MEMsplit_copy_buffer(ws_buffer,b4,0);
	if(status != MEM_S_SUCCESS)
	{
		MEMclose(b1);	MEMclose(b2);MEMclose(b3);
		PDMdebug("PDMsplit_16_buffers:\n");
		sprintf(s,"%s %d\n",
		"MEMsplit_copy_buffer failed status ",status);
		PDMdebug(s);
		return(PDM_E_COPY_BUFFER);
	}
	status = MEMreset_buffer(ws_buffer,&curbuf_no);
	if(status != MEM_S_SUCCESS)
	{
		MEMclose(b1);MEMclose(b2);MEMclose(b3);MEMclose(b4);
		PDMdebug("PDMsplit_16_buffers:\n");
		sprintf(s,"%s %d\n",
		"MEMreset_buffer failed status ",status);
		PDMdebug(s);
		return(PDM_E_RESET_BUFFER);
	}	
    status = MEMsplit_copy_buffer(ws_buffer,b5,0);
	if(status != MEM_S_SUCCESS)
	{
		MEMclose(b1);MEMclose(b2);MEMclose(b3);MEMclose(b4);
		PDMdebug("PDMsplit_16_buffers:\n");
		sprintf(s,"%s %d\n",
		"MEMsplit_copy_buffer failed status ",status);
		PDMdebug(s);
		return(PDM_E_COPY_BUFFER);
	}
	status = MEMreset_buffer(ws_buffer,&curbuf_no);
	if(status != MEM_S_SUCCESS)
	{
		MEMclose(b1);MEMclose(b2);	MEMclose(b3);MEMclose(b4);
		MEMclose(b5);
		PDMdebug("PDMsplit_16_buffers:\n");
		sprintf(s,"%s %d\n",
		"MEMreset_buffer failed status ",status);
		PDMdebug(s);
		return(PDM_E_RESET_BUFFER);
	}	
    status = MEMsplit_copy_buffer(ws_buffer,b6,0);
	if(status != MEM_S_SUCCESS)
	{
		MEMclose(b1);MEMclose(b2);MEMclose(b3);	MEMclose(b4);
		MEMclose(b5);
		PDMdebug("PDMsplit_16_buffers:\n");
		sprintf(s,"%s %d\n",
		"MEMsplit_copy_buffer failed status ",status);
		PDMdebug(s);
		return(PDM_E_COPY_BUFFER);
	}
	status = MEMreset_buffer(ws_buffer,&curbuf_no);
	if(status != MEM_S_SUCCESS)
	{
		MEMclose(b1);MEMclose(b2);MEMclose(b3);MEMclose(b4);
		MEMclose(b5);		MEMclose(b6);
		PDMdebug("PDMsplit_16_buffers:\n");
		sprintf(s,"%s %d\n",
		"MEMreset_buffer failed status ",status);
		PDMdebug(s);
		return(PDM_E_RESET_BUFFER);
	}	
    status = MEMsplit_copy_buffer(ws_buffer,b7,0);
	if(status != MEM_S_SUCCESS)
	{
		MEMclose(b1);MEMclose(b2);MEMclose(b3);MEMclose(b4);
		MEMclose(b5);MEMclose(b6);
		PDMdebug("PDMsplit_16_buffers:\n");
		sprintf(s,"%s %d\n",
		"MEMsplit_copy_buffer failed status ",status);
		PDMdebug(s);
		return(PDM_E_COPY_BUFFER);
	}
	status = MEMreset_buffer(ws_buffer,&curbuf_no);
	if(status != MEM_S_SUCCESS)
	{
		MEMclose(b1);MEMclose(b2);MEMclose(b3);	MEMclose(b4);
		MEMclose(b5);MEMclose(b6);MEMclose(b7);
		PDMdebug("PDMsplit_16_buffers:\n");
		sprintf(s,"%s %d\n",
		"MEMreset_buffer failed status ",status);
		PDMdebug(s);
		return(PDM_E_RESET_BUFFER);
	}	
    status = MEMsplit_copy_buffer(ws_buffer,b8,0);
	if(status != MEM_S_SUCCESS)
	{
		MEMclose(b1);MEMclose(b2);	MEMclose(b3);MEMclose(b4);
		MEMclose(b5);MEMclose(b6); MEMclose(b8);
		PDMdebug("PDMsplit_16_buffers:\n");
		sprintf(s,"%s %d\n",
		"MEMsplit_copy_buffer failed status ",status);
		PDMdebug(s);
		return(PDM_E_COPY_BUFFER);
	}
	status = MEMreset_buffer(ws_buffer,&curbuf_no);
	if(status != MEM_S_SUCCESS)
	{
		MEMclose(b1);MEMclose(b2);MEMclose(b3);	MEMclose(b4);
		MEMclose(b5);MEMclose(b6);MEMclose(b7); MEMclose(b8);
		PDMdebug("PDMsplit_16_buffers:\n");
		sprintf(s,"%s %d\n",
		"MEMreset_buffer failed status ",status);
		PDMdebug(s);
		return(PDM_E_RESET_BUFFER);
	}	
    status = MEMsplit_copy_buffer(ws_buffer,b9,0);
	if(status != MEM_S_SUCCESS)
	{
		MEMclose(b1);MEMclose(b2);MEMclose(b3);	MEMclose(b4);
		MEMclose(b5);MEMclose(b6);MEMclose(b7); MEMclose(b8);
		PDMdebug("PDMsplit_16_buffers:\n");
		sprintf(s,"%s %d\n",
		"MEMsplit_copy_buffer failed status ",status);
		PDMdebug(s);
		return(PDM_E_COPY_BUFFER);
	}
	status = MEMreset_buffer(ws_buffer,&curbuf_no);
	if(status != MEM_S_SUCCESS)
	{
		MEMclose(b1);MEMclose(b2);MEMclose(b3);	MEMclose(b4);
		MEMclose(b5);MEMclose(b6);MEMclose(b7); MEMclose(b8);
		PDMdebug("PDMsplit_16_buffers:\n");
		sprintf(s,"%s %d\n",
		"MEMreset_buffer failed status ",status);
		PDMdebug(s);
		return(PDM_E_RESET_BUFFER);
	}	
    status = MEMsplit_copy_buffer(ws_buffer,b10,0);
	if(status != MEM_S_SUCCESS)
	{
		MEMclose(b1);MEMclose(b2);MEMclose(b3);	MEMclose(b4);
		MEMclose(b5);MEMclose(b6);MEMclose(b7); MEMclose(b8);
		MEMclose(b9);
		PDMdebug("PDMsplit_16_buffers:\n");
		sprintf(s,"%s %d\n",
		"MEMsplit_copy_buffer failed status ",status);
		PDMdebug(s);
		return(PDM_E_COPY_BUFFER);
	}
	status = MEMreset_buffer(ws_buffer,&curbuf_no);
	if(status != MEM_S_SUCCESS)
	{
		MEMclose(b1);MEMclose(b2);MEMclose(b3);	MEMclose(b4);
		MEMclose(b5);MEMclose(b6);MEMclose(b7); MEMclose(b8);
		MEMclose(b9);MEMclose(b10);
		PDMdebug("PDMsplit_16_buffers:\n");
		sprintf(s,"%s %d\n",
		"MEMreset_buffer failed status ",status);
		PDMdebug(s);
		return(PDM_E_RESET_BUFFER);
	}	
    status = MEMsplit_copy_buffer(ws_buffer,b11,0);
	if(status != MEM_S_SUCCESS)
	{
		MEMclose(b1);MEMclose(b2);MEMclose(b3);	MEMclose(b4);
		MEMclose(b5);MEMclose(b6);MEMclose(b7); MEMclose(b8);
		MEMclose(b9);MEMclose(b10);
		PDMdebug("PDMsplit_16_buffers:\n");
		sprintf(s,"%s %d\n",
		"MEMsplit_copy_buffer failed status ",status);
		PDMdebug(s);
		return(PDM_E_COPY_BUFFER);
	}
	status = MEMreset_buffer(ws_buffer,&curbuf_no);
	if(status != MEM_S_SUCCESS)
	{
		MEMclose(b1);MEMclose(b2);MEMclose(b3);	MEMclose(b4);
		MEMclose(b5);MEMclose(b6);MEMclose(b7); MEMclose(b8);
		MEMclose(b9);MEMclose(b10);	MEMclose(b11);
		PDMdebug("PDMsplit_16_buffers:\n");
		sprintf(s,"%s %d\n",
		"MEMreset_buffer failed status ",status);
		PDMdebug(s);
		return(PDM_E_RESET_BUFFER);
	}	
    status = MEMsplit_copy_buffer(ws_buffer,b12,0);
	if(status != MEM_S_SUCCESS)
	{
		MEMclose(b1);MEMclose(b2);MEMclose(b3);	MEMclose(b4);
		MEMclose(b5);MEMclose(b6);MEMclose(b7); MEMclose(b8);
		MEMclose(b9);MEMclose(b10);	MEMclose(b11);MEMclose(b12);
		PDMdebug("PDMsplit_16_buffers:\n");
		sprintf(s,"%s %d\n",
		"MEMsplit_copy_buffer failed status ",status);
		PDMdebug(s);
		return(PDM_E_COPY_BUFFER);
	}
	status = MEMreset_buffer(ws_buffer,&curbuf_no);
	if(status != MEM_S_SUCCESS)
	{
		MEMclose(b1);MEMclose(b2);MEMclose(b3);	MEMclose(b4);
		MEMclose(b5);MEMclose(b6);MEMclose(b7); MEMclose(b8);
		MEMclose(b9);MEMclose(b10);	MEMclose(b11);MEMclose(b12);
		PDMdebug("PDMsplit_16_buffers:\n");
		sprintf(s,"%s %d\n",
		"MEMreset_buffer failed status ",status);
		PDMdebug(s);
		return(PDM_E_RESET_BUFFER);
	}	
    status = MEMsplit_copy_buffer(ws_buffer,b13,0);
	if(status != MEM_S_SUCCESS)
	{
		MEMclose(b1);MEMclose(b2);MEMclose(b3);	MEMclose(b4);
		MEMclose(b5);MEMclose(b6);MEMclose(b7); MEMclose(b8);
		MEMclose(b9);MEMclose(b10);	MEMclose(b11);MEMclose(b12);
		PDMdebug("PDMsplit_16_buffers:\n");
		sprintf(s,"%s %d\n",
		"MEMsplit_copy_buffer failed status ",status);
		PDMdebug(s);
		return(PDM_E_COPY_BUFFER);
	}
	status = MEMreset_buffer(ws_buffer,&curbuf_no);
	if(status != MEM_S_SUCCESS)
	{
		MEMclose(b1);MEMclose(b2);MEMclose(b3);	MEMclose(b4);
		MEMclose(b5);MEMclose(b6);MEMclose(b7); MEMclose(b8);
		MEMclose(b9);MEMclose(b10);	MEMclose(b11);MEMclose(b12);
		MEMclose(b13);
		PDMdebug("PDMsplit_16_buffers:\n");
		sprintf(s,"%s %d\n",
		"MEMreset_buffer failed status ",status);
		PDMdebug(s);
		return(PDM_E_RESET_BUFFER);
	}	
    status = MEMsplit_copy_buffer(ws_buffer,b14,0);
	if(status != MEM_S_SUCCESS)
	{
		MEMclose(b1);MEMclose(b2);MEMclose(b3);	MEMclose(b4);
		MEMclose(b5);MEMclose(b6);MEMclose(b7); MEMclose(b8);
		MEMclose(b9);MEMclose(b10);	MEMclose(b11);MEMclose(b12);
		MEMclose(b13);
		PDMdebug("PDMsplit_16_buffers:\n");
		sprintf(s,"%s %d\n",
		"MEMsplit_copy_buffer failed status ",status);
		PDMdebug(s);
		return(PDM_E_COPY_BUFFER);
	}
	status = MEMreset_buffer(ws_buffer,&curbuf_no);
	if(status != MEM_S_SUCCESS)
	{
		MEMclose(b1);MEMclose(b2);MEMclose(b3);	MEMclose(b4);
		MEMclose(b5);MEMclose(b6);MEMclose(b7); MEMclose(b8);
		MEMclose(b9);MEMclose(b10);	MEMclose(b11);MEMclose(b12);
		MEMclose(b13);MEMclose(b14);
		PDMdebug("PDMsplit_16_buffers:\n");
		sprintf(s,"%s %d\n",
		"MEMreset_buffer failed status ",status);
		PDMdebug(s);
		return(PDM_E_RESET_BUFFER);
	}	
    status = MEMsplit_copy_buffer(ws_buffer,b15,0);
	if(status != MEM_S_SUCCESS)
	{
		MEMclose(b1);MEMclose(b2);MEMclose(b3);	MEMclose(b4);
		MEMclose(b5);MEMclose(b6);MEMclose(b7); MEMclose(b8);
		MEMclose(b9);MEMclose(b10);	MEMclose(b11);MEMclose(b12);
		MEMclose(b13); MEMclose(b14);
		PDMdebug("PDMsplit_16_buffers:\n");
		sprintf(s,"%s %d\n",
		"MEMsplit_copy_buffer failed status ",status);
		PDMdebug(s);
		return(PDM_E_COPY_BUFFER);
	}
	status = MEMreset_buffer(ws_buffer,&curbuf_no);
	if(status != MEM_S_SUCCESS)
	{
		MEMclose(b1);MEMclose(b2);MEMclose(b3);	MEMclose(b4);
		MEMclose(b5);MEMclose(b6);MEMclose(b7); MEMclose(b8);
		MEMclose(b9);MEMclose(b10);	MEMclose(b11);MEMclose(b12);
		MEMclose(b13);MEMclose(b14);MEMclose(b15);
		PDMdebug("PDMsplit_16_buffers:\n");
		sprintf(s,"%s %d\n",
		"MEMreset_buffer failed status ",status);
		PDMdebug(s);
		return(PDM_E_RESET_BUFFER);
	}	
    status = MEMsplit_copy_buffer(ws_buffer,b16,0);
	if(status != MEM_S_SUCCESS)
	{
		MEMclose(b1);MEMclose(b2);MEMclose(b3);	MEMclose(b4);
		MEMclose(b5);MEMclose(b6);MEMclose(b7); MEMclose(b8);
		MEMclose(b9);MEMclose(b10);	MEMclose(b11);MEMclose(b12);
		MEMclose(b13); MEMclose(b14); MEMclose(b15);
		PDMdebug("PDMsplit_16_buffers:\n");
		sprintf(s,"%s %d\n",
		"MEMsplit_copy_buffer failed status ",status);
		PDMdebug(s);
		return(PDM_E_COPY_BUFFER);
	}
	PDMdebug("EXIT:PDMsplit_16_buffers\n");
	return(PDM_S_SUCCESS);
}

int	PDMappend_16_buffers(ret_bufr,b1,b2,b3,b4,b5,b6,b7,
	b8,b9,b10,b11,b12,b13,b14,b15,b16)
MEMptr		b1;
MEMptr		b2;
MEMptr		b3;
MEMptr		b4;
MEMptr		b5;
MEMptr		b6;
MEMptr		b7;
MEMptr		b8;
MEMptr		b9;
MEMptr		b10;
MEMptr		b11;
MEMptr		b12;
MEMptr		b13;
MEMptr		b14;
MEMptr		b15;
MEMptr		b16;
MEMptr		*ret_bufr;
{

	PDMdebug("ENTER:PDMappend_16_buffers\n");
	status = MEMsplit_copy_buffer(b1,ret_bufr,0);
	if(status != MEM_S_SUCCESS)
	{
		PDMdebug("PDMappend_16_buffers\n");
		sprintf(s,"MEMsplit_copy_buffers failed status %d",status);
		PDMdebug(s);
		return(PDM_E_COPY_BUFFER);
	}
	if(status == MEM_S_SUCCESS)
	status = MEMappend(b2,*ret_bufr);
	if(status == MEM_S_SUCCESS)
	status = MEMappend(b3,*ret_bufr);
	if(status == MEM_S_SUCCESS)
	status = MEMappend(b4,*ret_bufr);
	if(status == MEM_S_SUCCESS)
	status = MEMappend(b5,*ret_bufr);
	if(status == MEM_S_SUCCESS)
	status = MEMappend(b6,*ret_bufr);
	if(status == MEM_S_SUCCESS)
	status = MEMappend(b7,*ret_bufr);
	if(status == MEM_S_SUCCESS)
	status = MEMappend(b8,*ret_bufr);
	if(status == MEM_S_SUCCESS)
	status = MEMappend(b9,*ret_bufr);
	if(status == MEM_S_SUCCESS)
	status = MEMappend(b10,*ret_bufr);
	if(status == MEM_S_SUCCESS)
	status = MEMappend(b11,*ret_bufr);
	if(status == MEM_S_SUCCESS)
	status = MEMappend(b12,*ret_bufr);
	if(status == MEM_S_SUCCESS)
	status = MEMappend(b13,*ret_bufr);
	if(status == MEM_S_SUCCESS)
	status = MEMappend(b14,*ret_bufr);
	if(status == MEM_S_SUCCESS)
	status = MEMappend(b15,*ret_bufr);
	if(status == MEM_S_SUCCESS)
	status = MEMappend(b16,*ret_bufr);
	if(status != MEM_S_SUCCESS)
	{
		MEMclose(ret_bufr);
		PDMdebug("PDMappend_16_buffers\n");
		sprintf(s,"MEMappend failed status %d",status);
		PDMdebug(s);
		return(PDM_E_APPEND_BUFFER);
	}
	PDMdebug("EXIT:PDMappend_16_buffers\n");
	return(PDM_S_SUCCESS);
}




int PDMget_templateno ( psurpt, tempno, tmptype )
 struct PSUrpt *psurpt;
 int *tempno;
 int tmptype;
{
   static char *fn = "PDMget_templateno";
long status;
char sql_str[900];
int  tmpno;
char **data;
MEMptr qry_bufr = NULL;

   _PDMdebug(fn,"ENTER\n");
   sql_str [0] = '\0';
   *tempno = 0;
   tmpno = 0;
   if ( tmptype == 1 )
   sprintf( sql_str, 
   "select p_templateno from psurptopts where p_templatename = '%s' AND p_templatetype = '%s'", 
     (psurpt->options).template_name, psurpt->templatetype);
   else
      strcpy( sql_str, "select max(p_templateno) from psurptopts");
   _PDMdebug(fn,"sql_str = %s\n", sql_str);

    tmpno = 0;
     status = SQLquery (sql_str, &qry_bufr, 1024);
      if(status != SQL_S_SUCCESS) {
         MEMclose(&qry_bufr);
         _PDMdebug(fn,  "SQLstmt failed while getting tempno:status %d\n",
                                                                    status);
         return(status);
         }
     status = MEMbuild_array(qry_bufr);
     if(status != MEM_S_SUCCESS) {
       MEMclose(&qry_bufr);
       _PDMdebug (fn, "%s %d\n", "MEMbuild_array failed status ",status);
       return(PDM_E_BUILD_ARRAY);
          }	
     data = (char **) qry_bufr->data_ptr;
     *tempno = atol (data[0]);
   
     MEMclose (&qry_bufr);
     _PDMdebug (fn, "temp[%d]\n", *tempno);
   

  _PDMdebug (fn, "EXIT");
  return (PDM_S_SUCCESS);
}

