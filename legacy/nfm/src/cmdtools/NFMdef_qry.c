#include "machine.h"
#include <stdio.h>
#include "MEMstruct.h"
#include "NFMerrordef.h"
#include "ERR.h"
#include "NFMapi.h"
#include "DEBUG.h"
#include "NFMmach_id.h"
#include "NFMsysinc.h"

long _NFMdefine_query (query_name, query_desc, query_type, application, 
                       user_name, query_info)
    char  *query_name;               /* I - Name of query bring defined. */
    char  *query_desc;               /* I - Description of the query. */
    short query_type;                /* I - Type of query being defined.
                                        NFM_WHERE_CLAUSE, NFM_ORDER_BY_CLAUSE,
                                        NFM_SIMPLE_QUERY, or NFM_EXPERT_QUERY */
    char  *application;              /* I - Application defining the query. */
    char  *user_name;                /* I - User defining the query. */
    struct NFMquery_info query_info; /* I - A NFMquery_info structure with the
                                            info needed to define the query. */
{
    long   status;
    long   new_query = FALSE;
    long   owner_no;
    long   ret_size;
    int    type_num = 0;
    char   sql_str[256];
    char   temp_path [NFM_PATHNAME+1];
    char   qryfile[NFM_REPORTFILE+1];      /* unique temporary filename  */
    char   tempfile[NFM_PATHNAME+NFM_REPORTFILE+2]; /* unique temporary filename  */
    char   query_file[NFM_REPORTFILE+1];
    char   destfile[NFM_PATHNAME+NFM_REPORTFILE+2]; /* destination filename  */
    char   **s_data;
    MEMptr sql_buffer = NULL;
    static char *fname = "_NFMdefine_query";

    _NFMdebug ((fname, "query_name: <%s>; query_desc: <%s>; query_type: <%d>;application: <%s>;user_name: <%s>\n",
                query_name, query_desc, query_type, application, user_name));
    _NFMdebug ((fname, "select_clause: <%s>\n", query_info.select_clause));
    _NFMdebug ((fname, "from_clause: <%s>\n", query_info.from_clause));
    _NFMdebug ((fname, "where_clause: <%s>\n", query_info.where_clause));
    _NFMdebug ((fname, "order_by_clause: <%s>\n", query_info.order_by_clause));
    _NFMdebug ((fname, "prompts: <%s>\n", query_info.prompts));

    if ((query_type != NFM_WHERE_CLAUSE) &&
        (query_type != NFM_ORDER_BY_CLAUSE) &&
        (query_type != NFM_SIMPLE_QUERY) &&
        (query_type != NFM_EXPERT_QUERY))
        {
        status = NFM_E_INVALID_QUERY_TYPE;
        _NFMdebug ((fname, "Invalid query type <%ld>\n: <0x%.8x>\n", 
                    query_type, status));
        ERRload_struct (NFM, NFM_E_INVALID_QUERY_TYPE, "%ld", query_type);
        return (status);
        }

     status = NFMfind_user_no (user_name, &owner_no);
     if (status != NFM_S_SUCCESS)
         {
         status = NFM_E_BAD_USER;
         ERRload_struct (NFM, status, "%s", user_name);
         _NFMdebug ((fname, "Cannot find user number : status = <0x%.8x>\n", status));
         return (status);
         }

    if (strcmp (query_name, "") == 0)
        {
        status = NFM_E_INVALID_INPUT;
        _NFMdebug ((fname, "Bad query name or query structure: <0x%.8x>\n",
                    status));
        ERRload_struct (NFM, NFM_E_INVALID_INPUT, NULL);
        return (status);
        }

/* Query for the given query_name. If it exists, verify type and write file.
   If not, add entry and write file. */

    sprintf (sql_str, "SELECT %s from %s where n_reportname = '%s'",
             "n_reportname, n_type, n_reportfile", "NFMREPORTS", query_name);
    status = SQLquery (sql_str, &sql_buffer, 256);
    if (status != SQL_S_SUCCESS)
        {
        MEMclose (&sql_buffer);
        _NFMdebug ((fname, "SQLquery = <0x%.8x>\n", status));
        if (status == SQL_I_NO_ROWS_FOUND)
            new_query = TRUE;
        else
            {
            status = NFM_E_SQL_QUERY;
            _NFMdebug ((fname, "Bad query = <0x%.8x>\n", status));
            ERRload_struct (NFM, status, NULL);
            return (status);
            }
        }
    else
        {
        new_query = FALSE;
        /* verify that the query type is the same */
        status = MEMbuild_array (sql_buffer);
        if (status != MEM_S_SUCCESS)
            {
            MEMclose (&sql_buffer);
            _NFMdebug ((fname, "MEMbuild_array = <0x%.8x>\n", status));
            status = NFM_E_MEM;
            ERRload_struct (NFM, status, NULL);
            return (status);
            }

        s_data = (char **) sql_buffer->data_ptr;

             if (strncmp (s_data[1], "W", 1) == 0)
                 type_num = NFM_WHERE_CLAUSE;
        else if (strncmp (s_data[1], "O", 1) == 0)
                 type_num = NFM_ORDER_BY_CLAUSE;
        else if (strncmp (s_data[1], "S", 1) == 0)
                 type_num = NFM_SIMPLE_QUERY;
        else if (strncmp (s_data[1], "E", 1) == 0)
                 type_num = NFM_EXPERT_QUERY;

        strcpy (query_file, s_data[2]);
        MEMclose (&sql_buffer);
        if (type_num != query_type)
            {
            /* query type mismatch */
            _NFMdebug ((fname, "Query type mismatch: <%ld>:<%d> : <0x%.8x>\n",
                        query_type, type_num, status));
            status = NFM_E_QUERY_TYPE_MISMATCH;
            ERRload_struct (NFM, status, "%ld%d", query_type, type_num);
            return (status);
            }
        }

/* Find the pathname for the SYSTEM storage area. */
/* KT - 3/7/92 We are no longer going to query for the pathname. We can 
               build the path name from the default login directory of the 
               nfmadmin user and append the environment name and "system". */

    status = _NFMbuild_system_path ("nfmadmin", temp_path);
    if (status != NFM_S_SUCCESS)
        {
        _NFMdebug ((fname, "_NFMbuild_system_path = <0x%.8x>\n", status)); 
        ERRload_struct (NFM, status, NULL);
        return (status);
        }

    _NFMdebug ((fname, "system_path: <%s>\n", temp_path)); 

    /* Create a temporary file to write the query definitions into. */
    /* The file will be created in the login directory on the server node. */

    tempfile[0] = '\0';
    sprintf (qryfile, "%s", "qryXXXXXX");
    sprintf (tempfile, "%s%s%s", temp_path, DELIM, mktemp (qryfile));

    /* For combines client/server executables, the environment directory 
       is probably not located on the node running the image. Therefore,
       we must create the SYSTEM directory locally to write the query file.
       Then this query can be EXPORTED to the main environment directory. */

    status = NFM_mkpath (tempfile, S_IRWXU | S_IRWXG | S_IROTH | S_IXOTH);
    if (status != NFM_S_SUCCESS)
        {
        /* failure creating query path */
        _NFMdebug ((fname, "NFM_mkpath: <0x%.8x>\n", status));
        ERRload_struct (NFM, status, NULL);
        return (status);
        }

    /* Call NFMwrite_query_file to write the query definitions into */ 
    /* a file. */  

    status = NFMwrite_query_file (tempfile, query_type, query_info);
    if (status != NFM_S_SUCCESS)
        {
        /* failure writing to the query file */
        _NFMdebug ((fname, "NFMwrite_query_file: <0x%.8x>\n", status));
        status = NFM_E_QUERY_WRITE_FILE;
        ERRload_struct (NFM, status, NULL);
        return (status);
        }

    if (new_query)
        {   
        status = NFMadd_query (query_name, query_desc, query_type, application,
                               owner_no, query_file);
        if (status != NFM_S_SUCCESS)
            {
            _NFMdebug ((fname, "NFMadd_query = <0x%.8x>\n", status));
            ERRload_struct (NFM, status, NULL);
            status = unlink (tempfile);
            if(status)
                {
                ERRload_struct(NFM,NFM_E_UNLINK,"%s%d", tempfile, errno);
                _NFMdebug((fname,"Unlink source file <%s> failed: errno <%d>\n",
                          errno,NFM_E_UNLINK));
                return(NFM_E_UNLINK);
                }
            return (status);
            }
        }

    else
        {   
        status = NFMupdate_query (query_name, query_desc, query_type, 
                                  application, owner_no);
        if (status != NFM_S_SUCCESS)
            {
            _NFMdebug ((fname, "NFMupdate_query = <0x%.8x>\n", status));
            ERRload_struct (NFM, status, NULL);
            status = unlink (tempfile);
            if(status)
                {
                ERRload_struct(NFM,NFM_E_UNLINK,"%s%d", tempfile, errno);
                _NFMdebug((fname,"Unlink source file <%s> failed: errno <%d>\n",
                          errno,NFM_E_UNLINK));
                return(NFM_E_UNLINK);
                }
            return (status);
            }
        }

/* move temp file to query_file */
    sprintf (destfile, "%s%s%s", temp_path, DELIM, query_file);
    _NFMdebug ((fname, "%s -> %s\n", tempfile, destfile));

    status = NFMcopy_file (tempfile, destfile, "", &ret_size, 1);

    _NFMdebug ((fname, "SUCCESSFULL status = <0x%.8x>\n", NFM_S_SUCCESS));
    return (NFM_S_SUCCESS);
} 

long _NFMdefine_ftr_query (query_name, query_desc, query_type, application, 
                       user_name, query_info)
    char  *query_name;               /* I - Name of query bring defined. */
    char  *query_desc;               /* I - Description of the query. */
    short query_type;                /* I - Type of query being defined.
                                        NFM_WHERE_CLAUSE, NFM_ORDER_BY_CLAUSE,
                                        NFM_SIMPLE_QUERY, NFM_EXPERT_QUERY 
					or NFM_FTR_QUERY */
    char  *application;              /* I - Application defining the query. */
    char  *user_name;                /* I - User defining the query. */
    struct NFMquery_ftr_info query_info; /* I - A NFMquery_info structure with the
                                            info needed to define the query. */
{
    long   status;
    long   new_query = FALSE;
    long   owner_no;
    long   ret_size;
    int    type_num = 0;
    char   qType[5];  
    char   sql_str[256];
    char   temp_path [NFM_PATHNAME+1];
    char   qryfile[NFM_REPORTFILE+1];      /* unique temporary filename  */
    char   tempfile[NFM_PATHNAME+NFM_REPORTFILE+2]; /* unique temporary filename  */
    char   query_file[NFM_REPORTFILE+1];
    char   destfile[NFM_PATHNAME+NFM_REPORTFILE+2]; /* destination filename  */
    char   **s_data;
    MEMptr sql_buffer = NULL;
    static char *fname = "_NFMdefine_ftr_query";

    _NFMdebug ((fname, "query_name: <%s>; query_desc: <%s>; query_type: <%d>;application: <%s>;user_name: <%s>\n",
                query_name, query_desc, query_type, application, user_name));
    _NFMdebug ((fname, "select_clause: <%s>\n", query_info.select_clause));
    _NFMdebug ((fname, "from_clause: <%s>\n", query_info.from_clause));
    _NFMdebug ((fname, "where_clause: <%s>\n", query_info.where_clause));
    _NFMdebug ((fname, "order_by_clause: <%s>\n", query_info.order_by_clause));
    _NFMdebug ((fname, "prompts: <%s>\n", query_info.prompts));
    _NFMdebug ((fname, "ftr: <%s>\n", query_info.ftr));
    _NFMdebug ((fname, "aqs: <%s>\n", query_info.aqs));
    _NFMdebug ((fname, "aqf: <%s>\n", query_info.aqf));
    _NFMdebug ((fname, "aqw: <%s>\n", query_info.aqw));

    if ((query_type != NFM_WHERE_CLAUSE) &&
        (query_type != NFM_ORDER_BY_CLAUSE) &&
        (query_type != NFM_SIMPLE_QUERY) &&
        (query_type != NFM_EXPERT_QUERY) &&
        (query_type != NFM_FTR_QUERY) &&
	(query_type != NFM_ADV_QUERY))
        {
        status = NFM_E_INVALID_QUERY_TYPE;
        _NFMdebug ((fname, "Invalid query type <%ld>\n: <0x%.8x>\n", 
                    query_type, status));
        ERRload_struct (NFM, NFM_E_INVALID_QUERY_TYPE, "%ld", query_type);
        return (status);
        }

     status = NFMfind_user_no (user_name, &owner_no);
     if (status != NFM_S_SUCCESS)
         {
         status = NFM_E_BAD_USER;
         ERRload_struct (NFM, status, "%s", user_name);
         _NFMdebug ((fname, "Cannot find user number : status = <0x%.8x>\n", status));
         return (status);
         }

    if (strcmp (query_name, "") == 0)
        {
        status = NFM_E_INVALID_INPUT;
        _NFMdebug ((fname, "Bad query name or query structure: <0x%.8x>\n",
                    status));
        ERRload_struct (NFM, NFM_E_INVALID_INPUT, NULL);
        return (status);
        }
    if (query_type == NFM_WHERE_CLAUSE)
        strcpy( qType, "W" );
    else if (query_type == NFM_ORDER_BY_CLAUSE)
        strcpy( qType, "O" );
    else if (query_type == NFM_SIMPLE_QUERY)
        strcpy( qType, "S" );
    else if (query_type == NFM_EXPERT_QUERY)
        strcpy( qType, "E" );
    else if (query_type == NFM_ADV_QUERY)
        strcpy( qType, "A" );
    else if (query_type == NFM_FTR_QUERY)
        strcpy( qType, "F" );
    else
        strcpy( qType, "W" );

/* Query for the given query_name. If it exists, verify type and write file.
   If not, add entry and write file. */

    sprintf (sql_str, "SELECT %s FROM %s WHERE n_reportname = '%s' AND n_type = '%s'", "n_reportname, n_reportfile", "NFMREPORTS", query_name, qType);
    status = SQLquery (sql_str, &sql_buffer, 256);
    if (status != SQL_S_SUCCESS)
        {
        MEMclose (&sql_buffer);
        _NFMdebug ((fname, "SQLquery = <0x%.8x>\n", status));
        if (status == SQL_I_NO_ROWS_FOUND)
            new_query = TRUE;
        else
            {
            status = NFM_E_SQL_QUERY;
            _NFMdebug ((fname, "Bad query = <0x%.8x>\n", status));
            ERRload_struct (NFM, status, NULL);
            return (status);
            }
        }
    else
        {
        new_query = FALSE;
        status = MEMbuild_array (sql_buffer);
        if (status != MEM_S_SUCCESS)
            {
            MEMclose (&sql_buffer);
            _NFMdebug ((fname, "MEMbuild_array = <0x%.8x>\n", status));
            status = NFM_E_MEM;
            ERRload_struct (NFM, status, NULL);
            return (status);
            }

        s_data = (char **) sql_buffer->data_ptr;
        strcpy (query_file, s_data[1]);
        MEMclose (&sql_buffer);
        }

/* Find the pathname for the SYSTEM storage area. */
/* KT - 3/7/92 We are no longer going to query for the pathname. We can 
               build the path name from the default login directory of the 
               nfmadmin user and append the environment name and "system". */

    status = _NFMbuild_system_path ("nfmadmin", temp_path);
    if (status != NFM_S_SUCCESS)
        {
        _NFMdebug ((fname, "_NFMbuild_system_path = <0x%.8x>\n", status)); 
        ERRload_struct (NFM, status, NULL);
        return (status);
        }

    _NFMdebug ((fname, "system_path: <%s>\n", temp_path)); 

    /* Create a temporary file to write the query definitions into. */
    /* The file will be created in the login directory on the server node. */

    tempfile[0] = '\0';
    sprintf (qryfile, "%s", "qryXXXXXX");
    sprintf (tempfile, "%s%s%s", temp_path, DELIM, mktemp (qryfile));

    /* For combines client/server executables, the environment directory 
       is probably not located on the node running the image. Therefore,
       we must create the SYSTEM directory locally to write the query file.
       Then this query can be EXPORTED to the main environment directory. */

    status = NFM_mkpath (tempfile, S_IRWXU | S_IRWXG | S_IROTH | S_IXOTH);
    if (status != NFM_S_SUCCESS)
        {
        /* failure creating query path */
        _NFMdebug ((fname, "NFM_mkpath: <0x%.8x>\n", status));
        ERRload_struct (NFM, status, NULL);
        return (status);
        }

    /* Call NFMwrite_query_file to write the query definitions into */ 
    /* a file. */  

    status = NFMwrite_ftr_query_file (tempfile, query_type, query_info);
    if (status != NFM_S_SUCCESS)
        {
        /* failure writing to the query file */
        _NFMdebug ((fname, "NFMwrite_ftr_query_file: <0x%.8x>\n", status));
        status = NFM_E_QUERY_WRITE_FILE;
        ERRload_struct (NFM, status, NULL);
        return (status);
        }

    if (new_query)
        {   
        status = NFMadd_query (query_name, query_desc, query_type, application,
                               owner_no, query_file);
        if (status != NFM_S_SUCCESS)
            {
            _NFMdebug ((fname, "NFMadd_query = <0x%.8x>\n", status));
            ERRload_struct (NFM, status, NULL);
            status = unlink (tempfile);
            if(status)
                {
                ERRload_struct(NFM,NFM_E_UNLINK,"%s%d", tempfile, errno);
                _NFMdebug((fname,"Unlink source file <%s> failed: errno <%d>\n",
                          errno,NFM_E_UNLINK));
                return(NFM_E_UNLINK);
                }
            return (status);
            }
        }

    else
        {   
        status = NFMupdate_query (query_name, query_desc, query_type, 
                                  application, owner_no);
        if (status != NFM_S_SUCCESS)
            {
            _NFMdebug ((fname, "NFMupdate_query = <0x%.8x>\n", status));
            ERRload_struct (NFM, status, NULL);
            status = unlink (tempfile);
            if(status)
                {
                ERRload_struct(NFM,NFM_E_UNLINK,"%s%d", tempfile, errno);
                _NFMdebug((fname,"Unlink source file <%s> failed: errno <%d>\n",
                          errno,NFM_E_UNLINK));
                return(NFM_E_UNLINK);
                }
            return (status);
            }
        }

/* move temp file to query_file */
    sprintf (destfile, "%s%s%s", temp_path, DELIM, query_file);
    _NFMdebug ((fname, "%s -> %s\n", tempfile, destfile));

    status = NFMcopy_file (tempfile, destfile, "", &ret_size, 1);

    _NFMdebug ((fname, "SUCCESSFULL status = <0x%.8x>\n", NFM_S_SUCCESS));
    return (NFM_S_SUCCESS);
} 
