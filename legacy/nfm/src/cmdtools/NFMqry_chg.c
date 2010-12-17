#include "machine.h"
#include <stdio.h>
#include "MEMstruct.h"
#include "MEMerrordef.h"
#include "NFMdb.h"
#include "NFMerrordef.h"
#include "MSGstruct.h"
#include "SQLerrordef.h"
#include "ERR.h"
#include "DEBUG.h"

long NFMj_query_attributes ( table_name, table_type, nname, 
			    ret_name, attr_list )
    char   *table_name;
    char   *table_type ;
    char   *nname;
    char   *ret_name;
    MEMptr *attr_list;
{
  static char *fname = "NFMj_query_attributes" ;
    long   status;

    int    r;
    int    c;

    char   sql_string[500];

    char   **data;

    MEMptr attr     = NULL;
    MEMptr buffer   = NULL;

    _NFMdebug ((fname, "Table name  = <%s> : Table Type = <%s> : NFM name = <%s>\n",
		table_name, table_type, nname));

    if (strcmp (table_type, "nfmsystem") == 0)
      {
	sprintf( sql_string, "SELECT n_name,n_datatype,n_synonym,n_application,n_read,n_write,n_update,n_delete,n_null,n_checkin,n_checkout,n_seqno,n_attrno,n_tableno FROM nfmsysattributes WHERE n_tableno IN ( SELECT n_tableno FROM nfmtables where n_tablename='%s') ", table_name );
      }
    else
      {
	sprintf( sql_string, "SELECT n_name,n_datatype,n_synonym,n_application,n_read,n_write,n_update,n_delete,n_null,n_checkin,n_checkout,n_seqno, n_attrno, n_tableno FROM nfmattributes WHERE n_tableno IN ( SELECT n_tableno FROM nfmtables where n_tablename='%s') ", table_name );
      }

    status = SQLquery( sql_string, &buffer, MEM_SIZE );
    if( status != SQL_S_SUCCESS )
    {
        _NFMdebug ((fname, "SQLquery = <0x%.8x>", status));
        MEMclose (&buffer);
	ERRload_struct( NFM, NFM_E_MAP_ATTRIBUTE_NAMES, NULL, NULL );
        return( NFM_E_MAP_ATTRIBUTE_NAMES );
    }

    MEMbuild_array (buffer);
    data = (char**) buffer->data_ptr;

    status = MEMopen( &attr, MEM_SIZE );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( &attr );
	MEMclose( &buffer );
        _NFMdebug ((fname, "MEMopen : <0x%.8x>", status ));
        return( status );
    }

    status = MEMwrite_format( attr, "n_name", "char(20)" );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( &attr );
	MEMclose( &buffer );
        _NFMdebug ((fname, "MEMwrite_format:<0x%.8x>", 
	 	   status ));
        return( status );
    }    	
    status = MEMwrite_format( attr, "n_datatype", "char(15)" );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( &attr );
	MEMclose( &buffer );
        _NFMdebug ((fname, "MEMwrite_format:<0x%.8x>", 
	 	   status ));
        return( status );
    }    	
    status = MEMwrite_format( attr, "n_synonym", "char(40)" );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( &attr );
	MEMclose( &buffer );
        _NFMdebug ((fname, "MEMwrite_format:<0x%.8x>", 
	 	   status ));
        return( status );
    }

    status = MEMwrite_format( attr, "n_application", "char(3)" );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( &attr );
	MEMclose( &buffer );
        _NFMdebug ((fname, "MEMwrite_format:<0x%.8x>", 
	 	   status ));
        return( status );
    }
    	
    status = MEMwrite_format( attr, "n_read", "char(1)" );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( &attr );
	MEMclose( &buffer );
        _NFMdebug ((fname, "MEMwrite_format:<0x%.8x>", 
	 	   status ));
        return( status );
    }    	
    status = MEMwrite_format( attr, "n_write", "char(1)" );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( &attr );
	MEMclose( &buffer );
        _NFMdebug ((fname, "MEMwrite_format:<0x%.8x>", 
	 	   status ));
        return( status );
    }    	
    status = MEMwrite_format( attr, "n_update", "char(1)" );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( &attr );
	MEMclose( &buffer );
        _NFMdebug ((fname, "MEMwrite_format:<0x%.8x>", 
	 	   status ));
        return( status );
    }    	
    status = MEMwrite_format( attr, "n_delete", "char(1)" );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( &attr );
	MEMclose( &buffer );
        _NFMdebug ((fname, "MEMwrite_format:<0x%.8x>", 
	 	   status ));
        return( status );
    }    	
    status = MEMwrite_format( attr, "n_null", "char(1)" );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( &attr );
	MEMclose( &buffer );
        _NFMdebug ((fname, "MEMwrite_format:<0x%.8x>", 
	 	   status ));
        return( status );
    }    	

    status = MEMwrite_format( attr, "n_checkin", "char(1)" );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( &attr );
	MEMclose( &buffer );
        _NFMdebug ((fname, "MEMwrite_format:<0x%.8x>", 
	 	   status ));
        return( status );
    }    	
    status = MEMwrite_format( attr, "n_checkout", "char(1)" );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( &attr );
	MEMclose( &buffer );
        _NFMdebug ((fname, "MEMwrite_format:<0x%.8x>", 
	 	   status ));
        return( status );
    }    	

    status = MEMwrite_format( attr, "n_seqno", "integer" );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( &attr );
	MEMclose( &buffer );
        _NFMdebug ((fname, "MEMwrite_format:<0x%.8x>", 
	 	   status ));
        return( status );
    }
    status = MEMwrite_format( attr, "n_attrno", "integer" );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( &attr );
	MEMclose( &buffer );
        _NFMdebug ((fname, "MEMwrite_format:<0x%.8x>", 
	 	   status ));
        return( status );
    }    	

    status = MEMwrite_format( attr, "n_tableno", "integer" );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( &attr );
	MEMclose( &buffer );
        _NFMdebug ((fname, "MEMwrite_format:<0x%.8x>", 
	 	   status ));
        return( status );
    }    	
    	
    status = MEMwrite_format( attr, "n_valueno", "integer" );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( &attr );
	MEMclose( &buffer );
        _NFMdebug ((fname, "MEMwrite_format:<0x%.8x>", 
	 	   status ));
        return( status );
    }    	

    status = MEMwrite_format( attr, "n_adviceno", "integer" );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( &attr );
	MEMclose( &buffer );
        _NFMdebug ((fname, "MEMwrite_format:<0x%.8x>", 
	 	   status ));
        return( status );
    }    	


    for( r = 0; r < (buffer->rows*buffer->columns); r+=buffer->columns )
    {
      sql_string [0] = 0 ;
      for( c = 0; c < (buffer->columns); ++c )
	{
	    strcat( sql_string, data[r+c] );
	    strcat( sql_string, "\001" );
	}
	/* n_valueno = 0 */
	strcat( sql_string, "0\001" );
	/* n_adviceno = 0 */
        strcat( sql_string, "0\001" );

	status = MEMwrite( attr, sql_string );
        if( status != MEM_S_SUCCESS )
        {
            MEMclose( &attr );
	    MEMclose( &buffer );
            _NFMdebug ((fname, "MEMwrite_format:<0x%.8x>", 
			status ));
            return( status );
	}    	
    }
    MEMclose( &buffer );

    status = MEMsplit_copy_buffer( attr, attr_list, 0 );
    if (status != MEM_S_SUCCESS)
    {
        MEMclose( &attr );
        _NFMdebug ((fname, "MEMsplit_copy_buffer : <0x%.8x>",
		   status));
        return (status);
    }

    MEMclose( &attr );

    _NFMdebug ((fname, "SUCCESSFUL\n")) ;
    return( NFM_S_SUCCESS );
}
/* This routine searches the input string for tic marks and preceeds each
 * tic mark with another one so that it can be inserted into the
 * database.
 */

NFMj_tic_search( pwd, temp )
   char  *pwd;
   char  *temp;
{
   while( *pwd )
   {
	if( *pwd == '\'' )
	{
	   *temp = '\'';
	   ++temp;
	}
	*temp++ = *pwd++;
   }
   *temp = '\0';
}
