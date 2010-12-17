#include "machine.h"
#include "NFMRinclude.h"
#include "RPSerrordef.h"
#include "UTIerrordef.h"
#include "ERR.h"

NFMRload_ERRstruct( status_buffer, csd_buffer )
    MEMptr  status_buffer;
    MEMptr  csd_buffer;
{
    int     i;
    int     j;
    int     k;
    int     total_data;
    int	    subtype;

    long    status;
    long    buff_status;

    char    format[(MAX_ARGS*2)+1];

    char    **status_ptr;
    char    **csd_ptr;
    char    **csd_col;

    static  char *args[MAX_ARGS] = { NULL, NULL, NULL, NULL,
                                     NULL, NULL, NULL, NULL,
                                     NULL, NULL, NULL, NULL,
                                     NULL, NULL, NULL, NULL };

/*  Now build the status and the csd buffers and load the information
 *  back into  _ERRstruct.
 */
    _NFMR_str( "%s", "Enter NFMRload_ERRstruct : " );

    status = MEMbuild_array (status_buffer);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&status_buffer);
	MEMclose (&csd_buffer);
        _NFMR_num ("NFMRload_ERRstruct : MEMbuild_array1 : <0x%.8x>", status);
        return (status);
        }
    status = MEMbuild_array (csd_buffer);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&status_buffer);
	MEMclose (&csd_buffer);
        _NFMR_num ("NFMRload_ERRstruct : MEMbuild_array2 : <0x%.8x>", status);
        return (status);
        }

    status_ptr = (char**) status_buffer->data_ptr;

    for( i=0; i<status_buffer->rows; ++i )
    {
	status = atol( status_ptr[i] );
	_NFMR_num ("NFMRload_ERRstruct : Status Buffer : <0x%.8x>",status);
    }
    csd_ptr    = (char**) csd_buffer->data_ptr;
    csd_col    = (char**) csd_buffer->column_ptr;
    total_data = csd_buffer->rows*csd_buffer->columns;

/*  For any buffer data with no value, load in the NULL pointer. Also,
 *  build the format string based on the number of pieces of data.
 */
    for( i=0; i<status_buffer->rows; ++i )
    {
	strcpy( format, "" );
	k = 0;
	for( j=i; j<total_data; j+=csd_buffer->columns, ++k )
	{
	    if( !strlen( csd_ptr[j] ))
	    {
		args[k] = csd_ptr[j];
	        strcat( format, "%s" );
		_NFMR_str( "NFMRload_ERRstruct : Load <%s>", args[k]);
	    }
	    else
		args[k] = NULL;
	} /* end rows loop */

/*  Load the error structure but only load a status if it is not successful
 *  for that subsystem. We don't want to overwrite pre-existing information
 *  (i.e., set_to_state overwriting results of a command ).
 */
	buff_status = atol( status_ptr[i] );
   	if( strcmp( csd_col[i], "NETS" ) == 0 )
	{
	    subtype  = NETS;
	    if( buff_status == NET_S_SUCCESS )
		continue;
	}
   	else if( strcmp( csd_col[i], "NFMS" ) == 0 )
	{
            subtype  = NFMS;
            if( buff_status == NFM_S_SUCCESS )
                continue;
        }

	else if( strcmp( csd_col[i], "NFM" ) == 0 )
        {
            subtype  = NFM;
            if( buff_status == NFM_S_SUCCESS )
                continue;
        }

	else if( strcmp( csd_col[i], "RDB" ) == 0 )
        {
	    subtype = RDB;
            if( buff_status == NFM_S_SUCCESS )
                continue;
        }

   	else if( strcmp( csd_col[i], "SQL" ) == 0 )
        {
	    subtype = SQL;
            if( buff_status == SQL_S_SUCCESS )
                continue;
        }

 	else if( strcmp( csd_col[i], "MEM" ) == 0 )
        {
	    subtype = MEM;
            if( buff_status == MEM_S_SUCCESS )
                continue;
        }

 	else if( strcmp( csd_col[i], "RPS" ) == 0 )
        {
	    subtype = RPS;
            if( buff_status == RPS_S_SUCCESS )
                continue;
        }

 	else if( strcmp( csd_col[i], "UTI" ) == 0 )
        {
	    subtype = UTI;
            if( buff_status == UTI_S_SUCCESS )
                continue;
        }


	_NFMR_str( "NFMRload_ERRstruct : Format <%s>", format);
	_NFMR_str( "NFMRload_ERRstruct : Column type <%s>", csd_col[i]);
	_NFMR_num( "NFMRload_ERRstruct : Status <0x%.8x>", buff_status );

	if( strlen( format ) == 0 )
  	    status = ERRload_struct( subtype, buff_status, NULL,
				 args[0],  args[1],  args[2],  args[3],
				 args[4],  args[5],  args[6],  args[7],
				 args[8],  args[9],  args[10], args[11],
				 args[12], args[13], args[14], args[15]);

	else	
	    status = ERRload_struct( subtype, buff_status, format,
				 args[0],  args[1],  args[2],  args[3],
				 args[4],  args[5],  args[6],  args[7],
				 args[8],  args[9],  args[10], args[11],
				 args[12], args[13], args[14], args[15]);
	if( status != ERR_S_SUCCESS )
	{
	    _NFMR_num( "NFMRload_buff : ERRload_struct <0x%.8x>", status );
	    return( status );
	}
    } /* end columns loop */

    return( NFM_S_SUCCESS );
}
