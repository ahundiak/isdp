#include "machine.h"
#include <stdio.h>
#include "MEMstruct.h"
#include "MEMerrordef.h"
#include "NFMerrordef.h"
#include "MSGstruct.h"
#include "DEBUG.h"
#include "ERR.h"
#include "NFMapi.h"

/*  This routine takes the global _ERRstruct, which has been collecting 
 *  NFMserver subsystem status' and messages, builds two MEM buffers and
 *  prepends the return buffers with these error buffers. The first of
 *  the two MEM buffers contains the return status' from the NETS, NFMS,
 *  NFM, SQL, RDB and MEM subsystems. There will always be a status for
 *  each subsystem ( hopefully, SUCCESS ). The buffer is one column/ six
 *  rows. 
 */

extern MSGptr NFMmsg_ptr;
extern struct _ERRstruct _ERRstruct;

long NFMSerror_status_buffer( err_status )
    MEMptr  *err_status;
{
    long    status;
    char    str[100];
    static  char *fname = "NFMSerror_status_buffer";

    status = MEMopen( err_status, MEM_SIZE );
    if( status != MEM_S_SUCCESS )
    {
        _NFMSdebug(( fname, "MEMopen : <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
    }

    status = MEMwrite_format( *err_status, "status", "integer" );
    if( status != MEM_S_SUCCESS )
    {
        _NFMSdebug(( fname, "MEMwrite_format:<0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
    }   
    _NFMSdebug(( fname, "NETSstatus <0x%.8x>\n", _ERRstruct.NETSstatus)); 
    sprintf( str, "%ld", _ERRstruct.NETSstatus );
    strcat( str, "\1" );
    status = MEMwrite( *err_status, str );
    if( status != MEM_S_SUCCESS )
    {
        _NFMSdebug(( fname, "MEMwrite NETS: <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
    }
 

    _NFMSdebug(( fname, "NFMSstatus <0x%.8x>\n", _ERRstruct.NFMSstatus)) 
    sprintf( str, "%ld", _ERRstruct.NFMSstatus );
    strcat( str, "\1" );
    status = MEMwrite( *err_status, str );
    if( status != MEM_S_SUCCESS )
    {
        _NFMSdebug(( fname, "MEMwrite NFMS:<0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
    }
 

    _NFMSdebug(( fname, "NFMstatus <0x%.8x>\n", _ERRstruct.NFMstatus)); 
    sprintf( str, "%ld", _ERRstruct.NFMstatus );
    strcat( str, "\1" );
    status = MEMwrite( *err_status, str );
    if( status != MEM_S_SUCCESS )
    {
        _NFMSdebug(( fname, "MEMwrite NFM: <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
    }
 
    _NFMSdebug(( fname, "SQLstatus <0x%.8x>\n", _ERRstruct.SQLstatus)); 
    sprintf( str, "%ld", _ERRstruct.SQLstatus );
    strcat( str, "\1" );
    status = MEMwrite( *err_status, str );
    if( status != MEM_S_SUCCESS )
    {
        _NFMSdebug(( fname, "MEMwrite SQL: <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
    }
 
    _NFMSdebug(( fname, "MEMstatus <0x%.8x>\n", _ERRstruct.MEMstatus)); 
    sprintf( str, "%ld", _ERRstruct.MEMstatus );
    strcat( str, "\1" );
    status = MEMwrite( *err_status, str );
    if( status != MEM_S_SUCCESS )
    {
        _NFMSdebug(( fname, "MEMwrite MEM: <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
    }

    _NFMSdebug(( fname, "UTIstatus <0x%.8x>\n", _ERRstruct.UTIstatus)); 
    sprintf( str, "%ld", _ERRstruct.UTIstatus );
    strcat( str, "\1" );
    status = MEMwrite( *err_status, str );
    if( status != MEM_S_SUCCESS )
    {
        _NFMSdebug(( fname, "MEMwrite UTI: <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
    }

    return( NFM_S_SUCCESS );
}
/*  This routine builds the second error return buffer which will be
 *  appended to the above status buffer. This may be an empty buffer
 *  (i.e., opened but never written to ) if all status' are SUCCESS.
 *  When there is Context Specific Data (csd) to return to the requestor,
 *  the buffer has six columns, each named for a subsystem, and the
 *  number of rows equal to the subsystem with the most pieces of data.
 *  A row is written for each piece of data and for the subsystems not
 *  having a piece of data, a "\1" is the place holder.
 */
long NFMSerror_csd_buffer( err_csd )
    MEMptr  *err_csd;
{
    long    status;

    int	    i;
    int	    len;
    int     longest;
    int	    max_rows;
    int	    argc;

    char    str[500];
    static  char *fname = "NFMSerror_csd_buffer";

    status = MEMopen( err_csd, MEM_SIZE );
    if( status != MEM_S_SUCCESS )
    {
        _NFMSdebug(( fname, "MEMopen : <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
    }

/*  Determine which subsystem errors need to be sent back to the 
 *  requestor, get the longest piece of data and then write the format.
 */
    max_rows = 0;

    if( _ERRstruct.NETSargv == NULL )
    {
	argc = 0;
    }
    else
        argc = (int)_ERRstruct.NETSargv[0];

    if( argc > 0 )
    {
        if( argc > max_rows )
	    max_rows = argc;

	/*  Find the longest piece of data in the argument vector */
	longest = strlen( _ERRstruct.NETSargv[1] );
	for( i=2; i<=argc; ++i )
	{
	    len = strlen( _ERRstruct.NETSargv[i] );
	    if( len > longest )
	 	longest = len;
	}
	sprintf( str, "char(%d)", longest );
        status = MEMwrite_format( *err_csd, "NETS", str );
        if( status != MEM_S_SUCCESS )
        {
            _NFMSdebug(( fname, "MEMwrite_format:<0x%.8x>\n",status ));
            ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
            return (NFM_E_MEM);
 	}
    }   
    else
    {
        status = MEMwrite_format( *err_csd, "NETS", "char(1)" );
        if( status != MEM_S_SUCCESS )
        {
            _NFMSdebug(( fname, "MEMwrite_format:<0x%.8x>\n",status ));
            ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
            return (NFM_E_MEM);
 	}
    }

    if( _ERRstruct.NFMSargv == NULL )
    {
        argc = 0;
    }

    else
        argc = (int)_ERRstruct.NFMSargv[0];

    if( argc > 0 )
    {
       if( argc > max_rows )
            max_rows = argc;

	/*  Find the longest piece of data in the argument vector */
	longest = strlen( _ERRstruct.NFMSargv[1] );
	for( i=2; i<=argc; ++i )
	{
	    len = strlen( _ERRstruct.NFMSargv[i] );
	    if( len > longest )
	 	longest = len;
	}
	sprintf( str, "char(%d)", longest );
        status = MEMwrite_format( *err_csd, "NFMS", str );
        if( status != MEM_S_SUCCESS )
        {
            _NFMSdebug(( fname, "MEMwrite_format:<0x%.8x>\n", status ));
            ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
            return (NFM_E_MEM);
 	}
    }
    else
    {
        status = MEMwrite_format( *err_csd, "NFMS", "char(1)" );
        if( status != MEM_S_SUCCESS )
        {
            _NFMSdebug(( fname, "MEMwrite_format:<0x%.8x>\n",status ));
            ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
            return (NFM_E_MEM);
 	}
    }

    if( _ERRstruct.NFMargv == NULL )
    {
        argc = 0;
    }
    else
        argc = (int)_ERRstruct.NFMargv[0];

    if( argc > 0 )
    {
        if( argc > max_rows )
            max_rows = argc;

/*  Find the longest piece of data in the argument vector */
	longest = strlen( _ERRstruct.NFMargv[1] );
	for( i=2; i<=argc; ++i )
	{
	    len = strlen( _ERRstruct.NFMargv[i] );
	    if( len > longest )
	 	longest = len;
	}

	sprintf( str, "char(%d)", longest );
        status = MEMwrite_format( *err_csd, "NFM", str );
        if( status != MEM_S_SUCCESS )
        {
            _NFMSdebug(( fname, "MEMwrite_format:<0x%.8x>\n", status));
            ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
            return (NFM_E_MEM);
 	}
    }
    else
    {
        status = MEMwrite_format( *err_csd, "NFM", "char(1)" );
        if( status != MEM_S_SUCCESS )
        {
            _NFMSdebug(( fname, "MEMwrite_format:<0x%.8x>\n", status));
            ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
            return (NFM_E_MEM);
 	}
    }


    if( _ERRstruct.SQLargv == NULL )
    {
        argc = 0;
    }
    else
        argc = (int)_ERRstruct.SQLargv[0];

    if( argc > 0 )
    {
       if( argc > max_rows )
            max_rows = argc;

	/*  Find the longest piece of data in the argument vector */
	longest = strlen( _ERRstruct.SQLargv[1] );
	for( i=2; i<=argc; ++i )
	{
	    len = strlen( _ERRstruct.SQLargv[i] );
	    if( len > longest )
	 	longest = len;
	}
	sprintf( str, "char(%d)", longest );
        status = MEMwrite_format( *err_csd, "SQL", str );
        if( status != MEM_S_SUCCESS )
        {
            _NFMSdebug(( fname, "MEMwrite_format:<0x%.8x>\n",status ));
            ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
            return (NFM_E_MEM);
 	}
    }
    else
    {
        status = MEMwrite_format( *err_csd, "SQL", "char(1)" );
        if( status != MEM_S_SUCCESS )
        {
            _NFMSdebug(( fname, "MEMwrite_format:<0x%.8x>\n",status ));
            ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
            return (NFM_E_MEM);
 	}
    }

    if( _ERRstruct.MEMargv == NULL )
    {
        argc = 0;
    }
    else
        argc = (int)_ERRstruct.MEMargv[0];

    if( argc > 0 )
    {
       if( argc > max_rows )
            max_rows = argc;

	/*  Find the longest piece of data in the argument vector */
	longest = strlen( _ERRstruct.MEMargv[1] );
	for( i=2; i<=argc; ++i )
	{
	    len = strlen( _ERRstruct.MEMargv[i] );
	    if( len > longest )
	 	longest = len;
	}
	sprintf( str, "char(%d)", longest );
        status = MEMwrite_format( *err_csd, "MEM", str );
        if( status != MEM_S_SUCCESS )
        {
            _NFMSdebug(( fname, "MEMwrite_format:<0x%.8x>\n", status ));
            ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
            return (NFM_E_MEM);
 	}
    }   
    else
    {
        status = MEMwrite_format( *err_csd, "MEM", "char(1)" );
        if( status != MEM_S_SUCCESS )
        {
            _NFMSdebug(( fname, "MEMwrite_format:<0x%.8x>\n", status ));
            ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
            return (NFM_E_MEM);
 	}
    }

   
    if( _ERRstruct.UTIargv == NULL )
    {
        argc = 0;
    }
    else
        argc = (int)_ERRstruct.UTIargv[0];

    if( argc > 0 )
    {
       if( argc > max_rows )
            max_rows = argc;

	/*  Find the longest piece of data in the argument vector */
	longest = strlen( _ERRstruct.UTIargv[1] );
	for( i=2; i<=argc; ++i )
	{
	    len = strlen( _ERRstruct.UTIargv[i] );
	    if( len > longest )
	 	longest = len;
	}
	sprintf( str, "char(%d)", longest );
        status = MEMwrite_format( *err_csd, "UTI", str );
        if( status != MEM_S_SUCCESS )
        {
            _NFMSdebug(( fname, "MEMwrite_format:<0x%.8x>\n",status ));
            ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
            return (NFM_E_MEM);
 	}
    }   
    else
    {
        status = MEMwrite_format( *err_csd, "UTI", "char(1)" );
        if( status != MEM_S_SUCCESS )
        {
            _NFMSdebug(( fname, "MEMwrite_format:<0x%.8x>\n", status ));
            ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
            return (NFM_E_MEM);
 	}
    }

 
/*  If there is no CSD, everything was successful and the CSD buffer is 
 *  not written to. However, it is still appended to the status buffer 
 *  because the requestor is looking for it.
 */
    if( max_rows > 0 )
    {
/*  Now write the rows which will be the maximum number of argv vectors
 *  for any one subsystem.
 */
	_NFMSdebug(( fname, "Max rows <%d>\n", max_rows));

        for( i=1; i<=max_rows; ++i ) 
        { 
   	    strcpy( str, "" );
	    if( _ERRstruct.NETSargv != NULL )
	    {
	        if( (int)_ERRstruct.NETSargv[0] >= i )
		{
		    strcat( str, _ERRstruct.NETSargv[i] );
		    strcat( str, "\1" );
		}
		else
		    strcat( str, "\1" );
	    }
	    else
		strcat( str, "\1" );

	    if( _ERRstruct.NFMSargv != NULL )
	    {
                if( (int)_ERRstruct.NFMSargv[0] >= i )
                {
                    strcat( str, _ERRstruct.NFMSargv[i] );
                    strcat( str, "\1" );
                }
                else
                    strcat( str, "\1" );
	    }
	    else
		strcat( str, "\1" );

	    if( _ERRstruct.NFMargv != NULL )
	    {
                if( (int)_ERRstruct.NFMargv[0] >= i )
                {
                    strcat( str, _ERRstruct.NFMargv[i] );
                    strcat( str, "\1" );
                }
                else
                    strcat( str, "\1" );
	    }
	    else
		strcat( str, "\1" );

	    if( _ERRstruct.SQLargv != NULL )
	    {
                if( (int)_ERRstruct.SQLargv[0] >= i )
                {
                    strcat( str, _ERRstruct.SQLargv[i] );
                    strcat( str, "\1" );
                }
                else
                    strcat( str, "\1" );
	    }
	    else
		strcat( str, "\1" );

	    if( _ERRstruct.MEMargv != NULL )
	    {
                if( (int)_ERRstruct.MEMargv[0] >= i )
                {
                    strcat( str, _ERRstruct.MEMargv[i] );
                    strcat( str, "\1" );
                }
                else
                    strcat( str, "\1" );
	    }
	    else
		strcat( str, "\1" );

	    if( _ERRstruct.UTIargv != NULL )
	    {
                if( (int)_ERRstruct.UTIargv[0] >= i )
                {
                    strcat( str, _ERRstruct.UTIargv[i] );
                    strcat( str, "\1" );
                }
                else
                    strcat( str, "\1" );
	    }
	    else
		strcat( str, "\1" );

	    _NFMSdebug((fname, "str <%s>\n", str ));
  
            status = MEMwrite( *err_csd, str );
            if( status != MEM_S_SUCCESS )
            {
                _NFMSdebug((fname, "MEMwrite : <0x%.8x>\n",status));
         	ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
                return (NFM_E_MEM);
             }
	} /* end  for( i=1; i<=max_rows; ++i ) */
    } /* end if( max_rows> 0 ) */

    if( max_rows == 0 )
	_NFMSdebug((fname, "%s\n", "No CSD data "));

    return( NFM_S_SUCCESS );
}
