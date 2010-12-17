#include "machine.h"
#include "NFMRextern.h"

long NFMRtic_it( buffer )
    MEMptr  buffer;
{
    int     i;
    int     j;
    int     k;

    long    status;

    char    s[1024];
    static  char *fname = "NFMRtic_it";
    char    **data_ptr;
    char    **fmt_ptr;

    _NFMRdebug(( fname, "%s\n", "Entering ..." ));

    if( buffer == NULL )
	return( NFM_S_SUCCESS );

    status = MEMbuild_array( buffer );
    if( status != MEM_S_SUCCESS )
    {
        _NFMRdebug(( fname, "MEMbuild <0x%.8x>\n", status ));
	ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
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
		NFMRtic_to_tics( data_ptr[j], s );
		status = MEMwrite_data( buffer, s, k, i+1 );
		if( status != MEM_S_SUCCESS )
		{
		    _NFMRdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
		    ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
		    return( NFM_E_MEM );
		}
	    }
	}
    }
    _NFMRdebug(( fname, "%s\n", "Exiting ..." ));
    return( NFM_S_SUCCESS );
}

NFMRtic_to_tics( in, out )
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
