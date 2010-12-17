#include "machine.h"
#include <stdio.h>
#include "CLIerror.h"
#include "CLIstruct.h"
#include "NFMerrordef.h"
#include "proto.h"
#include <memcheck.h>
extern short clnt_fd;

long NETbuffer_receive(buffer, bytes)
char *buffer;
long *bytes;
{
	long status;

	status = client_recv_size( clnt_fd, bytes );
	if( status )
	{
  		printf("Error receiving size from server\n");
  		client_stop( clnt_fd );
  		return( NFM_E_FAILURE );
	}

	if( bytes )
	{
  		status = client_recv( clnt_fd, buffer );
  		if( status )
  		{
    			printf("Error receiving data from server\n");
    			client_stop( clnt_fd );
    			return( NFM_E_FAILURE );
  		}
	}
	return(NFM_S_SUCCESS);
}

long NETbuffer_send(buffer,bytes)
char *buffer;
long *bytes;
{
	long status;
  	status = client_send( clnt_fd, buffer, *bytes );
  	if( status )
  	{
    		printf("Error sending message to server\n");
    		client_stop( clnt_fd );
    		return(NFM_E_FAILURE);
  	}
	return(NFM_S_SUCCESS);
}
