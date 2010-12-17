#include "machine.h"
#include "MEMstruct.h"
#include "NETdef.h"
#include "NFMerrordef.h"
#include "NFMSextern.h"
#include "DEBUG.h"
#include "ERR.h"

/*
 Doc: NFMSclient_info

 Abstract:
     This function will sign a user off given the buffers returned from
     NFMquery_signoff_attributes.
*/

long NFMSclient_info (in_list)

     MEMptr in_list;   /* input mand */
{
  long status;
  long ret_status = 0;
  long administrator = 0;
  long rows = 0;
  long do_not_register = 0;
  char str[20];
  MEMptr data_list = NULL;
  
  static char *fname = "NFMSclient_info";

  status = NFMclient_info (in_list, &administrator, &rows, &do_not_register);
  if( status != NFM_S_SUCCESS )
  {
	_NFMSdebug(( fname, "NFMclient_info  <0x%.8x>\n", status ));
	return( status );
  }  

  status = MEMopen (&data_list, MEM_SIZE);
  if (status != MEM_S_SUCCESS)
    {
    _NFMSdebug(( fname, "MEMopen : <0x%.8x>\n", status));
    ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
    return (NFM_E_MEM);
    }
    
  status = MEMwrite_format (data_list, "admin", "char(10)");
  if (status != MEM_S_SUCCESS)
    {
    _NFMSdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
    ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
    return (NFM_E_MEM);
    }

  status = MEMwrite_format (data_list, "rows", "char(10)");
  if (status != MEM_S_SUCCESS)
    {
    _NFMSdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
    ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
    return (NFM_E_MEM);
    }

  status = MEMwrite_format (data_list, "register", "char(10)");
  if (status != MEM_S_SUCCESS)
    {
    _NFMSdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
    ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
    return (NFM_E_MEM);
    }
    
  _NFMSdebug(( fname, "Administrator <%ld>\n", administrator ));
  _NFMSdebug(( fname, "Query Rows <%ld>\n", rows ));
  _NFMSdebug(( fname, "Do NOT Register PDM <%ld>\n", do_not_register ));


  sprintf (str, "%ld\1%ld\1%ld\1", administrator, rows, do_not_register);

  status = MEMwrite (data_list, str);
  if (status != MEM_S_SUCCESS)
    {
    _NFMSdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
    ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
    return (NFM_E_MEM);
    }
    
  ret_status = NFMSsend_one_buffer( ret_status , data_list );
  _NFMSdebug(( fname, "NFMSsend_one_buffer <0x%.8x>\n", ret_status));

  MEMclose( &data_list );

  return( ret_status );
}





