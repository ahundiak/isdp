#include "machine.h"
#include <stdio.h>
#include <errno.h>

#include "MEMstruct.h"
#include "NETdef.h"
#include "NFMerrordef.h"
#include "NFMSextern.h"
#include "DEBUG.h"

#define    BUFFER_SIZE    1000

/* 
 Doc: NFMSbuild_error_buffer
 
 Abstract:
     This function will build an error buffer to be returned to the
     requester function
     
 Returns:
       0 - Success
      <0 - Failure
         
 History:
     kht    8-31-1989    Creation
     
 */
 
long NFMSbuild_error_buffer (error_list)

MEMptr  *error_list;   /* o - list of errors */

{
char   str[512];
long   status = 0;
char   long_value[20];

    static char *fname = "NFMSbuild_error_buffer";

    status = MEMopen (error_list, BUFFER_SIZE);
    if (status != MEM_S_SUCCESS)
        {
        _NFMSdebug(( fname, "MEMopen : <0x%.8x>\n", status));
        return (status);
        }
    
    status = MEMwrite_format (*error_list, "nfm_error_no", "char(20)");
    if (status != MEM_S_SUCCESS)
        {
        _NFMSdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        return (status);
        }
    
    status = MEMwrite_format (*error_list, "nfm_error_msg", "char(80)");
    if (status != MEM_S_SUCCESS)
        {
        _NFMSdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        return (status);
        }
    
    status = MEMwrite_format (*error_list, "sql_error_no", "char(20)");
    if (status != MEM_S_SUCCESS)
        {
        _NFMSdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        return (status);
        }
    
    status = MEMwrite_format (*error_list, "sql_error_msg", "char(80)");
    if (status != MEM_S_SUCCESS)
        {
        _NFMSdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        return (status);
        }
    
    status = MEMwrite_format (*error_list, "db_error_no", "char(20)");
    if (status != MEM_S_SUCCESS)
        {
        _NFMSdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        return (status);
        }
    
    status = MEMwrite_format (*error_list, "db_error_msg", "char(80)");
    if (status != MEM_S_SUCCESS)
        {
        _NFMSdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        return (status);
        }
 
    sprintf (long_value, "%ld", NFMmsg_ptr.error_no);
    strcpy (str, long_value);
    strcat (str, "\1");
    strcat (str, NFMmsg_ptr.error_msg);
    strcat (str, "\1");

    sprintf (long_value, "%ld", NFMmsg_ptr.error_no);
    strcat (str, long_value);
    strcat (str, "\1");
    strcat (str, NFMmsg_ptr.error_msg);
    strcat (str, "\1");

    sprintf (long_value, "%ld", NFMmsg_ptr.error_no);
    strcat (str, long_value);
    strcat (str, "\1");
    strcat (str, NFMmsg_ptr.error_msg);
    strcat (str, "\1");

    status = MEMwrite (*error_list, str);
    if (status != MEM_S_SUCCESS)
        {
        _NFMSdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
        return (status);
        }
    
    return (NFM_S_SUCCESS); 
}
