#include "machine.h"
#include <stdio.h>
#include "MEMstruct.h"
#include "NFMerrordef.h"
#include "DEBUG.h"
#include "NFMapi.h"
#include "ERR.h"

 
long NFMadd_query (query_name, query_desc, query_type, application, owner_no, query_file)
    char  *query_name;   /* I - Name of query. */
    char  *query_desc;   /* I - Description of query. */
    short query_type;    /* I - Type of query. */
    char  *application;  /* I - Application. */
    long  owner_no;      /* I - n_userno of user adding the query. */
    char  *query_file;   /* I - Name of Query file. */

{
     long   status;
     long   report_no;
     char   type_str[NFM_TYPE+1];
     char   sql_str[256];
     static char *fname = "NFMadd_query";

     _NFMdebug ((fname, "query_name: <%s>; query_type: <%d>; application: <%s>; owner_no: <%ld>\n", 
                 query_name, query_type, application, owner_no));

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

     /* Find correct query type value. */
          if (query_type == NFM_WHERE_CLAUSE)
              strcpy (type_str, "W");
     else if (query_type == NFM_ORDER_BY_CLAUSE)
              strcpy (type_str, "O");
     else if (query_type == NFM_SIMPLE_QUERY)
              strcpy (type_str, "S");
     else if (query_type == NFM_EXPERT_QUERY)
              strcpy (type_str, "E");
     else if (query_type == NFM_FTR_QUERY)
              strcpy (type_str, "F");
     else if (query_type == NFM_ADV_QUERY)
              strcpy (type_str, "A");

     status = NFMgen_query_file_name ("nfmreports", report_no, query_file);
     if (status != NFM_S_SUCCESS)
         {
         NFMrollback_transaction (0) ;
         _NFMdebug ((fname, "Get Query Filename : status = <0x%.8x>\n", status));
         return (status);
         }

     sprintf (sql_str, "INSERT INTO NFMREPORTS (n_reportno, n_reportname, \
n_reportdesc, n_type, n_owner, n_application, n_reportfile) VALUES (%d, '%s', \
'%s', '%s', %d, '%s', '%s')",
              report_no, query_name, query_desc, type_str, owner_no, 
              application, query_file);

     status = SQLstmt (sql_str);
     if (status != SQL_S_SUCCESS)
         {
         NFMrollback_transaction (0) ;
         ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
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
     return (NFM_S_SUCCESS);
}


long NFMupdate_query (query_name, query_desc, query_type, application, 
                      owner_no)
    char  *query_name;   /* I - Name of query. */
    char  *query_desc;   /* I - Description of query. */
    short query_type;    /* I - Type of query. */
    char  *application;  /* I - Application. */
    long  owner_no;      /* I - n_userno of user adding the query. */

{
     long   status;
     char   type_str[NFM_TYPE+1];
     char   sql_str[256];
     static char *fname = "NFMupdate_query";

     _NFMdebug ((fname, "query_name: <%s>; query_type: <%d>; application: <%s>; owner_no: <%ld>\n", 
                 query_name, query_type, application, owner_no));

     status = NFMstop_transaction (0) ;
     if (status != NFM_S_SUCCESS) 
         {
         _NFMdebug ((fname, "NFMstop_transaction : <0x%.8x>\n", status));
         return (status) ;
         }

     /* Find correct query type value. */
          if (query_type == NFM_WHERE_CLAUSE)
              strcpy (type_str, "W");
     else if (query_type == NFM_ORDER_BY_CLAUSE)
              strcpy (type_str, "O");
     else if (query_type == NFM_SIMPLE_QUERY)
              strcpy (type_str, "S");
     else if (query_type == NFM_EXPERT_QUERY)
              strcpy (type_str, "E");
     else if (query_type == NFM_FTR_QUERY)
              strcpy (type_str, "F");
     else if (query_type == NFM_ADV_QUERY)
              strcpy (type_str, "A");

     sprintf (sql_str, "UPDATE NFMREPORTS SET n_reportdesc = '%s', n_owner = \
%ld WHERE (n_reportname = '%s' AND n_type = '%s' AND n_application = '%s')",
              query_desc, owner_no, query_name, type_str, application);

     status = SQLstmt (sql_str);
     if (status != SQL_S_SUCCESS)
         {
         NFMrollback_transaction (0) ;
         ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
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
     return (NFM_S_SUCCESS);
}


