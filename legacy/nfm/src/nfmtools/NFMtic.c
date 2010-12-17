#include "machine.h"
#include <stdio.h>
#include "MEMstruct.h"
#include "NFMerrordef.h"
#include "ERR.h"

long NFMtic_it( buffer )
    MEMptr  buffer;
{
    int     i;
    int     j;
    int     k;

    long    status;

    char    s[1024];
    static  char *fname = "NFMtic_it";
    char    **data_ptr;
    char    **fmt_ptr;

    status = MEMbuild_array( buffer );
    if( status != MEM_S_SUCCESS )
    {
	ERRload_struct( NFM, NFM_E_MEM, "%s%s", "NFMtic_it", 
			"MEMbuild_array");    
	return( NFM_E_MEM ); 
    }

    data_ptr = (char**) buffer->data_ptr;
    fmt_ptr  = (char**) buffer->format_ptr;

    for( i=0; i<buffer->columns; ++i )
    {
	if( strncmp( fmt_ptr[i], "char", 4 ) == 0 )
	{
	    for( j=i,k=1; j<buffer->rows*buffer->columns;
		 j+=buffer->columns,++k )
	    {
		NFMtic_to_tics( data_ptr[j], s );
		status = MEMwrite_data( buffer, s, k, i+1 );
		if( status != MEM_S_SUCCESS )
		{
		    ERRload_struct( NFM, NFM_E_MEM, "%s%s", "NFMtic_it",
  	                            "MEMwrite_data");
		    return( NFM_E_MEM );
		}
	    }
	}
    }
    return( NFM_S_SUCCESS );
}

NFMtic_to_tics( in, out )
    char *in;
    char *out;
{
    while( *in )
    {
	if( *in == '\'' )
	{
	    *out = '\'';
	    ++out;
	}
	*out++ = *in++;
    }    
    *out = '\0';

    return( NFM_S_SUCCESS );
}
