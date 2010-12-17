#include "machine.h"
#include <stdio.h>
#include <errno.h>
#include "MEMstruct.h"
#include "NFMerrordef.h"
#include "ERR.h"
#include "NFMapi.h"
#include "DEBUG.h"
#include "NFMmach_id.h"

/* 
 Doc: CVTmodify_query
 
 Abstract:
     This function will modify a query for I/NFM. A report file is created and
     the nfmreports entry is modified.
     
 Returns:
       NFM_S_SUCCESS - Success
       Other         - Failure
         
 History:
     kht    2-3-1992    Creation
     
 */
 
long CVTmodify_query (query_name, query_desc, query_type, application, app_type,
                      query_info, new_query_no)
    char  *query_name;               /* I - Name of query bring defined. */
    char  *query_desc;               /* I - Description of the query. */
    char  *query_type;                /* I - Type of query being defined.
                                        NFM_WHERE_CLAUSE, NFM_ORDER_BY_CLAUSE,
                                        NFM_SIMPLE_QUERY, or NFM_EXPERT_QUERY */
    char  *application;              /* I - Application defining the query. */
    char  *app_type;                 /* I - Application type. */
    struct NFMquery_info query_info; /* I - A NFMquery_info structure with the
                                            info needed to define the query. */
    long  *new_query_no;             /* O - New report number. */
{
    long   status;
    long   ret_size;
    long   query_def;
    long   report_no;
    char   sql_str[256];
    char   message[256];
    char   temp_path [NFM_PATHNAME+1];
    char   qryfile[NFM_REPORTFILE+1];      /* unique temporary filename  */
    char   tempfile[NFM_PATHNAME+NFM_REPORTFILE+2]; /* unique temporary filename  */
    char   query_file[NFM_REPORTFILE+1];
    char   destfile[NFM_PATHNAME+NFM_REPORTFILE+2]; /* destination filename  */
    char   **s_data;
    MEMptr sql_buffer = NULL;
    static char *fname = "CVTmodify_query";

    _NFMdebug ((fname, "query_name: <%s>; query_desc: <%s>; query_type: <%s>;application: <%s>\n",
                query_name, query_desc, query_type, application));
    _NFMdebug ((fname, "where_clause: <%s>\n", query_info.where_clause));
    _NFMdebug ((fname, "order_by_clause: <%s>\n", query_info.order_by_clause));

         if (strcmp (query_type, "W") == 0)
             query_def = NFM_WHERE_CLAUSE;
    else if (strcmp (query_type, "O") == 0)
             query_def = NFM_ORDER_BY_CLAUSE;
    else
        {
        status = NFM_E_INVALID_QUERY_TYPE;
        _NFMdebug ((fname, "Invalid query type <%s>\n: <0x%.8x>\n", 
                    query_type, status));
        return (status);
        }

    /* Find the pathname for the SYSTEM storage area. */

    sprintf (sql_str, "SELECT n_pathname from %s where n_saname = '%s'",
             "NFMSTORAGEAREA", "SYSTEM");
    status = SQLquery (sql_str, &sql_buffer, 256);
    if (status != SQL_S_SUCCESS)
        {
        MEMclose (&sql_buffer);
        status = NFM_E_SQL_QUERY;
        return (status);
        }

    status = MEMbuild_array (sql_buffer);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&sql_buffer);
        _NFMdebug ((fname, "MEMbuild_array = <0x%.8x>\n", status)); 
        status = NFM_E_MEM;
        return (status);
        }

    s_data = (char **) sql_buffer->data_ptr;
    strcpy (temp_path, s_data[0]);

    MEMclose (&sql_buffer);

    /* Create a temporary file to write the query definitions into. */
    /* The file will be created in the login directory on the server node. */

    tempfile[0] = '\0';
    sprintf (qryfile, "%s", "qryXXXXXX");
    sprintf (tempfile, "%s%s%s", temp_path, DELIM, mktemp (qryfile));

    /* Call NFMwrite_query_file to write the query definitions into */ 
    /* a file. */  

    status = NFMwrite_query_file (tempfile, query_def, query_info);
    if (status != NFM_S_SUCCESS)
        {
        /* failure writing to the query file */
        _NFMdebug ((fname, "NFMwrite_query_file: <0x%.8x>\n", status));
        status = NFM_E_QUERY_WRITE_FILE;
        return (status);
        }

     status = NFMstop_transaction (0) ;
     if (status != NFM_S_SUCCESS) 
         {
         _NFMdebug ((fname, "NFMstop_transaction : <0x%.8x>\n", status));
         return (status) ;
         }

     status = NFMget_serial_slot (0, "nfmreports", "n_reportno", 
                                  &report_no);
     if (status != NFM_S_SUCCESS)
         {
         _NFMdebug ((fname, "Get Serial No : status = <0x%.8x>\n", status));
         return (status);
         }

     *new_query_no = report_no;

     status = NFMgen_query_file_name ("nfmreports", report_no, query_file);
     if (status != NFM_S_SUCCESS)
         {
         NFMrollback_transaction (0) ;
         _NFMdebug ((fname, "Get Query Filename : status = <0x%.8x>\n", status));
         return (status);
         }

/*
     sprintf (sql_str, "UPDATE NFMREPORTS SET n_reportno = %d, n_reportdesc = \
'%s', n_owner = 1, n_reportfile = '%s' WHERE (n_reportname = '%s' AND n_type = \
'%s' AND n_application = '%s' AND n_apptype = '%s')",
              report_no, query_desc, query_file, query_name, query_type,
              application, app_type);
*/

     sprintf (sql_str, "INSERT INTO NFMREPORTS (n_reportno, n_reportname, \
n_reportdesc, n_type, n_application, n_apptype, n_owner, n_reportfile) VALUES \
(%d, '%s', '%s', '%s', '%s', '%s', 1, '%s')",
              report_no, query_name, query_desc, query_type, application, 
              app_type, query_file);

     _NFMdebug ((fname, "sql_str: <%s>\n", sql_str));

     status = SQLstmt (sql_str);
     if (status != SQL_S_SUCCESS)
         {
         NFMrollback_transaction (0) ;
         _NFMdebug ((fname, "SQL Stmt Syntax : status = <0x%.8x>\n", status));
         return (NFM_E_SQL_STMT);
         }

     status = NFMstart_transaction(0);
     if (status != NFM_S_SUCCESS)
         {
         NFMrollback_transaction(0);
         _NFMdebug ((fname, "Commit Work : status = <0x%.8x>\n", status));
         return (status);
         }

     _NFMdebug ((fname, "SUCCESSFUL : status = <0x%.8x>\n", NFM_S_SUCCESS));

/* move temp file to query_file */
    sprintf (destfile, "%s%s%s", temp_path, DELIM, query_file);
    _NFMdebug ((fname, "%s -> %s\n", tempfile, destfile));

    status = NFMcopy_file (tempfile, destfile, "", &ret_size, 1);

/* KT - 7/15/92 Must change ownership to be able to modify query 
   KT - 7/24/92 Removing this because 'main' will now populate
                the NFMuser_info structure used by NFMcopy_file.
                Previously, the structure was initialized to 0,
                causing the search/sort files to be owned by root.

    status = (long) chown (destfile, (int) getuid (), (int) getgid());
    if (status)
        {
        sprintf (message, "Could not change owner of %s : errno %d", 
                 destfile, errno) ;
        _NFMdebug ((fname, "%s\n", message)) ;
        ERRload_struct (NFM, NFM_E_MESSAGE, "%s", message) ;
        return (NFM_E_MESSAGE) ;
        }
*/

    _NFMdebug ((fname, "SUCCESSFULL status = <0x%.8x>\n", NFM_S_SUCCESS));
    return (NFM_S_SUCCESS);
} 
