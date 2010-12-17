#include "machine.h"
#include <stdio.h>
#include <pwd.h>
#include "MEMstruct.h"
#include "NFMerrordef.h"
#include "ERR.h"
#include "NFMapi.h"
#include "DEBUG.h"
#include "NFMstruct.h"

extern struct NFMglobal_st NFMglobal;

/* 
 Doc: NFM query tools
*/
 
long NFMfind_user_no (user_name, user_no)
    char  *user_name;  /* I - User name. */
    long  *user_no;    /* O - Returned user number. */
                             
{
    long   status;
    char   sql_str[256];
    char   **s_data;
    MEMptr sql_buffer = NULL;
    static char *fname = "NFMfind_user_no";

    _NFMdebug ((fname, "user_name: <%s>\n", user_name));

/* Query for the n_userno of the given user_name. */

    sprintf (sql_str, "SELECT n_userno from NFMUSERS where n_username = '%s'",
             user_name);
    status = SQLquery (sql_str, &sql_buffer, 256);
    if (status != SQL_S_SUCCESS)
        {
        status = NFM_E_SQL_QUERY;
        _NFMdebug ((fname, "Bad Username = <0x%.8x>\n", status));
        ERRload_struct (NFM, status, NULL);
        return (status);
        }

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
    *user_no = atoi (s_data[0]);
    MEMclose (&sql_buffer);

    _NFMdebug ((fname, "SUCCESSFULL: n_userno: <%d>: <0x%.8x>\n", *user_no,
                NFM_S_SUCCESS));
    return (NFM_S_SUCCESS);
} 


long NFMgen_query_file_name (table_name, table_index, query_file)
    char  *table_name;   /* I - Table name. */
    long  table_index;   /* I - Table index. */
    char  *query_file;   /* O - Query file name. */

{
    long   status;
    long   table_no;
    char   sql_str[256];
    char   **s_data;
    MEMptr sql_buffer = NULL;
    static char *fname = "NFMgen_query_file_name";

    _NFMdebug ((fname, "table_name: <%s>; table_index: <%ld>\n", table_name,
                table_index));

/* Query for the n_tableno of the given table_name. */

    sprintf (sql_str, "SELECT n_tableno from NFMTABLES where n_tablename = '%s'",
             table_name);
    status = SQLquery (sql_str, &sql_buffer, 256);
    if (status != SQL_S_SUCCESS)
        {
        status = NFM_E_SQL_QUERY;
        _NFMdebug ((fname, "Bad Table = <0x%.8x>\n", status));
        ERRload_struct (NFM, status, NULL);
        return (status);
        }

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
    table_no = atoi (s_data[0]);
    MEMclose (&sql_buffer);

    _NFMdebug ((fname, "n_tableno: <%d>\n", table_no));

    status = NFMnew_file_name (0, table_no, table_index, query_file);
    if (status != NFM_S_SUCCESS)
        {
        _NFMdebug ((fname, "NFMnew_file_name = <0x%.8x>\n", status));
        ERRload_struct (NFM, status, NULL);
        return (status);
        }

    _NFMdebug ((fname, "query_file: <%s>\n", query_file));

    _NFMdebug ((fname, "SUCCESSFULL: query_file: <%s>: <0x%.8x>\n", query_file,
                NFM_S_SUCCESS));
    return (NFM_S_SUCCESS);
} 

long NFMget_query_filename (query_name, file_name)
   char    *query_name;
   char    *file_name;
   {
     static char *fname = "NFMget_query_filename";
     long status, atol ();
     long _NFMbuild_system_path ();
     char sql_str [1024];
     char file [NFM_REPORTFILE+1];
     char path_name [NFM_PATHNAME+1];    
     char **data;
     MEMptr   buffer = NULL;

     _NFMdebug ((fname, "query_name = <%s>\n", query_name));

     sprintf (sql_str, "SELECT n_reportfile FROM nfmreports WHERE %s = '%s'", 
              "n_reportname", query_name); 

     if ((status = SQLquery (sql_str, &buffer, MEM_SIZE)) != SQL_S_SUCCESS)
         {
         _NFMdebug ((fname, "SQLquery = <0x%.8x>\n", status));
         MEMclose (&buffer);
         ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
         return ( NFM_E_SQL_QUERY);
         }

     if ((status = MEMbuild_array (buffer)) != MEM_S_SUCCESS)
         {
         _NFMdebug ((fname, "MEMbuild_array = <0x%.8x>\n", status));
         MEMclose (&buffer);
         ERRload_struct (NFM, NFM_E_MEM, "", NULL);
         return (NFM_E_MEM);
         }

     data = (char **) buffer->data_ptr;
     strcpy (file, data[0]);

     MEMclose (&buffer);

/* find report path */
/* KT - 3/7/92 We are no longer going to query for the pathname. We can 
               build the path name from the default login directory of the 
               nfmadmin user and append the environment name and "system". */

    status = _NFMbuild_system_path ("nfmadmin", path_name);
    if (status != NFM_S_SUCCESS)
        {
        _NFMdebug ((fname, "_NFMbuild_system_path = <0x%.8x>\n", status)); 
        ERRload_struct (NFM, status, NULL);
        return (status);
        }

    _NFMdebug ((fname, "system_path: <%s>\n", path_name)); 

     MEMclose (&buffer);

     sprintf (file_name, "%s/%s", path_name, file);

     _NFMdebug ((fname, "File Name = <%s> : SUCCESSFUL\n", file_name));

     return (NFM_S_SUCCESS);
   }


/* 
 Doc: _NFMbuild_system_path
 
 Abstract:
      This function will build the pathname of the nfm "SYSTEM" storage area
      relative to the local nfmadmin login directory. This will be used for
      writing search/sort criteria files and adding programs to be tied to
      workflow transitions. 

      We need to use this function instead of quering the database for the
      combined client/server images that need to write files locally instead
      of on the environment node (where the environment was initialized).
     
 Returns:
       NFM_S_SUCCESS - Success
       Other - Failure
*/
 
long _NFMbuild_system_path (admin_user, path)

char *admin_user; /* i - the system username of the nfmadmin user - 
                         for future use since currently it must be 
                         'nfmadmin'. */
char *path;       /* o - the "system" storage area path relative to the local
                         nfmadmin login directory */

{
struct passwd *pw_entry;
static char *fname = "_NFMbuild_system_path";

    _NFMdebug ((fname, "Enter.\n"));

    pw_entry = getpwnam (admin_user);
    if (pw_entry == NULL)
      {
      _NFMdebug ((fname, "Cannot access local passwd file\n"));
      ERRload_struct(NFM, NFM_E_FAILURE, "%s%s",
               "Build System Path", "Cannot access passwd file");
      return (NFM_E_FAILURE);
      }

    sprintf (path, "%s/%s/%s", pw_entry->pw_dir, NFMglobal.environment_name, 
             "system");

    _NFMdebug ((fname, "Path: <%s>\n", path));
    _NFMdebug ((fname, "Returning: NFM_S_SUCCESS.\n"));
    return (NFM_S_SUCCESS);
}

long NFMget_ftr_query_filename (query_name, query_type, file_name)
   char    *query_name;
   char    *query_type;
   char    *file_name;
   {
     static char *fname = "NFMget_ftr_query_filename";
     long status, atol ();
     long _NFMbuild_system_path ();
     char sql_str [1024];
     char file [NFM_REPORTFILE+1];
     char path_name [NFM_PATHNAME+1];    
     char **data;
     MEMptr   buffer = NULL;

     _NFMdebug ((fname, "query_name = <%s>\n", query_name));
     _NFMdebug ((fname, "query_type = <%s>\n", query_type));

     sprintf (sql_str, "SELECT n_reportfile FROM nfmreports WHERE %s = '%s' AND n_type = '%s'", "n_reportname", query_name, query_type); 

     if ((status = SQLquery (sql_str, &buffer, MEM_SIZE)) != SQL_S_SUCCESS)
         {
         _NFMdebug ((fname, "SQLquery = <0x%.8x>\n", status));
         MEMclose (&buffer);
         ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
         return ( NFM_E_SQL_QUERY);
         }

     if ((status = MEMbuild_array (buffer)) != MEM_S_SUCCESS)
         {
         _NFMdebug ((fname, "MEMbuild_array = <0x%.8x>\n", status));
         MEMclose (&buffer);
         ERRload_struct (NFM, NFM_E_MEM, "", NULL);
         return (NFM_E_MEM);
         }

     data = (char **) buffer->data_ptr;
     strcpy (file, data[0]);

     MEMclose (&buffer);

/* find report path */
/* KT - 3/7/92 We are no longer going to query for the pathname. We can 
               build the path name from the default login directory of the 
               nfmadmin user and append the environment name and "system". */

    status = _NFMbuild_system_path ("nfmadmin", path_name);
    if (status != NFM_S_SUCCESS)
        {
        _NFMdebug ((fname, "_NFMbuild_system_path = <0x%.8x>\n", status)); 
        ERRload_struct (NFM, status, NULL);
        return (status);
        }

    _NFMdebug ((fname, "system_path: <%s>\n", path_name)); 

     MEMclose (&buffer);

     sprintf (file_name, "%s/%s", path_name, file);

     _NFMdebug ((fname, "File Name = <%s> : SUCCESSFUL\n", file_name));

     return (NFM_S_SUCCESS);
   }
