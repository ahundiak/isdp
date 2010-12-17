#include "machine.h"
#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include "NFMerrordef.h"
#include "DEBUG.h"
#include "NFMschema.h"
#include "ERR.h"

extern char NFM_SRV_NODE[100];      /* nodename of server */
extern char NFM_ENV_NODE[100];      /* nodename where schema definition(risschema) */
                              /* for environment resides */


/* 
 Doc: NFMdelete_query
 
 Abstract:
     This function will delete a query for I/NFM. The report file is also
     deleted.
     
 Returns:
       NFM_S_SUCCESS - Success
       Other         - Failure
         
 History:
     kht    9-30-1991    Creation
     
 */
 
long NFMdelete_query (query_name)
  char   *query_name;
 {
    long   status;
    char   file_name [NFM_PATHNAME+NFM_FILENAME+1];
    char   sql_str [150];
    struct stat buf;
    static char *fname = "NFMdelete_query";

    _NFMdebug ((fname, "query_name: <%s>\n", query_name));

    /* Call NFMget_query_filename to get the operating system name
       of the file to delete from the server.                        */

    status = NFMget_query_filename (query_name, file_name);
    if (status != NFM_S_SUCCESS)
        {
        _NFMdebug ((fname, "NFMget_query_filename = <0x%.8x%>\n", status)); 
        return (status);
        }

     status = NFMstop_transaction (0);
     if (status != NFM_S_SUCCESS) 
         {
         _NFMdebug ((fname, "NFMstop_transaction: status = <0x%.8x>\n",status));
         return (status);
         }

     /* delete the row from NFMREPORTS */  
      
     sprintf (sql_str, "DELETE FROM NFMREPORTS WHERE n_reportname = '%s'",
              query_name); 
     status = SQLstmt (sql_str);
     if (status != SQL_S_SUCCESS)
         {
         _sql_error (status);
         NFMrollback_transaction (0);
         _NFMdebug ((fname, "SQL Stmt : status = <0x%.8x>\n", status));
         status = NFM_E_SQL_STMT;
         return (status);
         }

     status  = (long) stat (file_name, &buf) ;
     if (status)
         {
         NFMrollback_transaction (0);
         _NFMdebug ((fname, "report does not exist\n")) ;
/*
	 if(strcmp(NFM_SRV_NODE, NFM_ENV_NODE) == 0 )
         	ERRload_struct (NFM, NFM_E_STAT, "", "") ;
	 else
*/
		ERRload_struct(NFM,NFM_E_QUERY_FILE_NOT_LOCAL,"%s",file_name);
         return (NFM_E_STAT) ;
         }

     status = unlink (file_name);  /* remove the file. */
     if (status) /* OK */
         {
         NFMrollback_transaction (0);
         status = NFM_E_UNLINK_FILE;
         _NFMdebug ((fname, "unlink Failed : status = <0x%.8x>\n", status));
         ERRload_struct (NFM, NFM_E_UNLINK_FILE, "", "") ;
         return (status);
         }

     status = NFMstart_transaction (0);
     if (status != NFM_S_SUCCESS) 
         {
         _NFMdebug ((fname, "NFMstart_transaction: status = <0x%.8x>\n",status));
         return (status);
         }

    _NFMdebug ((fname, "SUCCESSFULL status = <0x%.8x%>\n", NFM_S_SUCCESS)); 
    return (NFM_S_SUCCESS);
 } 

/* 
 Doc: NFMdelete_ftr_query
 
 Abstract:
     This function will delete a query for DM/Manager. The report file is also
     deleted.
     
 Returns:
       NFM_S_SUCCESS - Success
       Other         - Failure
         
 History:
     kht    9-30-1991    Creation
     
 */
 
long NFMdelete_ftr_query (query_name, query_type)
  char   *query_name;
  char   *query_type;
 {
    long   status;
    char   file_name [NFM_PATHNAME+NFM_FILENAME+1];
    char   sql_str [150];
    struct stat buf;
    static char *fname = "NFMdelete_ftr_query";

    _NFMdebug ((fname, "query_name: <%s>\n", query_name));
    _NFMdebug ((fname, "query_name: <%s>\n", query_type));

    /* Call NFMget_query_filename to get the operating system name
       of the file to delete from the server.                        */

    status = NFMget_ftr_query_filename (query_name, query_type, file_name);
    if (status != NFM_S_SUCCESS)
        {
        _NFMdebug ((fname, "NFMget_ftr_query_filename = <0x%.8x%>\n", status)); 
        return (status);
        }

     status = NFMstop_transaction (0);
     if (status != NFM_S_SUCCESS) 
         {
         _NFMdebug ((fname, "NFMstop_transaction: status = <0x%.8x>\n",status));
         return (status);
         }

     /* delete the row from NFMREPORTS */  
      
     sprintf (sql_str, "DELETE FROM NFMREPORTS WHERE n_reportname = '%s' AND n_type = '%s'", query_name, query_type); 
     status = SQLstmt (sql_str);
     if (status != SQL_S_SUCCESS)
         {
         _sql_error (status);
         NFMrollback_transaction (0);
         _NFMdebug ((fname, "SQL Stmt : status = <0x%.8x>\n", status));
         status = NFM_E_SQL_STMT;
         return (status);
         }

     status  = (long) stat (file_name, &buf) ;
     if (status)
         {
         NFMrollback_transaction (0);
         _NFMdebug ((fname, "report does not exist\n")) ;
 	 ERRload_struct(NFM,NFM_E_QUERY_FILE_NOT_LOCAL,"%s",file_name);
         return (NFM_E_STAT) ;
         }

     status = unlink (file_name);  /* remove the file. */
     if (status) /* OK */
         {
         NFMrollback_transaction (0);
         status = NFM_E_UNLINK_FILE;
         _NFMdebug ((fname, "unlink Failed : status = <0x%.8x>\n", status));
         ERRload_struct (NFM, NFM_E_UNLINK_FILE, "", "") ;
         return (status);
         }

     status = NFMstart_transaction (0);
     if (status != NFM_S_SUCCESS) 
         {
         _NFMdebug ((fname, "NFMstart_transaction: status = <0x%.8x>\n",status));
         return (status);
         }

    _NFMdebug ((fname, "SUCCESSFULL status = <0x%.8x%>\n", NFM_S_SUCCESS)); 
    return (NFM_S_SUCCESS);
 } 
