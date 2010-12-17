#include <stdio.h>
#include "MEMstruct.h"
#include "NFMerrordef.h"
#include "ERR.h"
#include "NFMapi.h"
#include "DEBUG.h"
#include "NFMmach_id.h"
#include "PDUstorage.h"
#include "PDUerror.h"
#include "PDMproto.h"
#include "PDMmach_id.h"
#include        <sys/types.h>
#include        <sys/stat.h>

extern struct   PDUstorage   *storage;

long PDMdefine_query (query_name, query_desc, query_type, application, 
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
    long   status = PDM_S_SUCCESS;
    long   new_query = FALSE;
    long   owner_no;
    long   ret_size;
    int    type_num = 0;
    char   sql_str[256];
    char   qryfile[NFM_REPORTFILE+1];      /* unique temporary filename  */
    char   tempfile[NFM_PATHNAME+NFM_REPORTFILE+2]; /* unique temporary filename  */
    char   query_file[NFM_REPORTFILE+1];
    char   destfile[NFM_PATHNAME+NFM_REPORTFILE+2]; /* destination filename  */
    char   **s_data;
    MEMptr sql_buffer = NULL;
    static char *fname = "_PDMdefine_query";
    char *cwd_dir;



    _PDMdebug(fname, "query_name: <%s>; query_desc: <%s>; query_type: <%d>;application: <%s>;user_name: <%s>\n", 
                query_name, query_desc, query_type, application, user_name);
    _PDMdebug(fname, "select_clause: <%s>\n", query_info.select_clause);
    _PDMdebug(fname, "from_clause: <%s>\n", query_info.from_clause);
    _PDMdebug(fname, "where_clause: <%s>\n", query_info.where_clause);
    _PDMdebug(fname, "order_by_clause: <%s>\n", query_info.order_by_clause);
    _PDMdebug(fname, "prompts: <%s>\n", query_info.prompts);

    if ((query_type != NFM_WHERE_CLAUSE) &&
        (query_type != NFM_ORDER_BY_CLAUSE) &&
        (query_type != NFM_SIMPLE_QUERY) &&
        (query_type != NFM_EXPERT_QUERY))
        {
 _PDMdebug(fname, "Invalid query type <%ld>\n: <0x%.8x>\n", query_type, status);
        return (NFM_E_INVALID_QUERY_TYPE);
        }

     status = NFMfind_user_no (user_name, &owner_no);
     if (status != NFM_S_SUCCESS)
         {
         status = NFM_E_BAD_USER;
     _PDMdebug(fname, "Cannot find user number : status = <0x%.8x>\n", status);
         return (status);
         }

    if (strcmp (query_name, "") == 0)
        {
        status = NFM_E_INVALID_INPUT;
      _PDMdebug(fname, "Bad query name or query structure: <0x%.8x>\n", status);
        return (status);
        }

    /* ALR  2/3/94 This function does a chdir and does not return us.
       TR 139307264 and TR 139416524 is due to this. */

       cwd_dir = (char *)PDUgetcwd((char *)NULL,64);

       status = NFMload_user_info(storage->user_name);
        if (status != NFM_S_SUCCESS)
            {
            _PDMdebug(fname, "NFMload_user_info = <0x%.8x>\n", status);
            status = NFM_E_MEM;
            return (status);
            }
        /* return to previous cwd */

        chdir(cwd_dir);
       
/* Query for the given query_name. If it exists, verify type and write file.
   If not, add entry and write file. */

    sprintf (sql_str, "SELECT %s from %s where n_reportname = '%s'", 
             "n_reportname, n_type, n_reportfile", "NFMREPORTS", query_name);
    status = SQLquery (sql_str, &sql_buffer, 256);
    if (status != SQL_S_SUCCESS)
        {
        MEMclose (&sql_buffer);
        _PDMdebug(fname, "SQLquery = <0x%.8x>\n", status);
        if (status == SQL_I_NO_ROWS_FOUND)
            new_query = TRUE;
        else
            {
            status = NFM_E_SQL_QUERY;
            _PDMdebug(fname, "Bad query = <0x%.8x>\n", status);
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
            _PDMdebug(fname, "MEMbuild_array = <0x%.8x>\n", status);
            status = NFM_E_MEM;
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
            _PDMdebug(fname, "Query type mismatch: <%ld>:<%d> : <0x%.8x>\n", 
                        query_type, type_num, status);
            status = NFM_E_QUERY_TYPE_MISMATCH;
            return (status);
            }
        }



    /* Create a temporary file to write the query definitions into. */
    /* The file will be created in the login directory on the server node. */

    tempfile[0] = '\0';
    sprintf (qryfile, "%s", "qryXXXXXX");
    sprintf (tempfile, "%s%s%s", storage->path_name, DELIM, mktemp (qryfile));

    _PDMdebug(fname, "system_path: <%s>\n", tempfile); 

    /* Call NFMwrite_query_file to write the query definitions into */ 
    /* a file. */  

    status = NFMwrite_query_file (tempfile, query_type, query_info);
    if (status != NFM_S_SUCCESS)
        {
        /* failure writing to the query file */
        _PDMdebug(fname, "NFMwrite_query_file: <0x%.8x>\n", status);
        status = NFM_E_QUERY_WRITE_FILE;
        return (status);
        }

    if (new_query)
        {   
        status = NFMadd_query (query_name, query_desc, query_type, application, 
                               owner_no, query_file);
        if (status != NFM_S_SUCCESS)
            {
            _PDMdebug(fname, "NFMadd_query = <0x%.8x>\n", status);
            status = unlink (tempfile);
            if(status)
                {
                _PDMdebug(fname, "Unlink source file \n");
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
            _PDMdebug(fname, "NFMupdate_query = <0x%.8x>\n", status);
            status = unlink (tempfile);
            if(status)
                {
                _PDMdebug(fname, "Unlink source file failed\n");
                return(NFM_E_UNLINK);
                }
            return (status);
            }
        }

    /* move temp file to query_file */
    sprintf (destfile, "%s%s%s", storage->path_name, DELIM, query_file);
    _PDMdebug(fname, "%s -> %s\n", tempfile, destfile);

    status = NFMcopy_file (tempfile, destfile, "", &ret_size, 1);


    status = PDMmove_rpt_file(storage->storage_name, "SYSTEM", query_file);
        if (status != PDM_S_SUCCESS) {
                _PDMdebug(fname, "PDMmove_rpt_file falied status %d\n", status);
               return(NFM_E_QUERY_WRITE_FILE);
        }
            status = unlink (destfile);
            if(status)
                {
                _PDMdebug(fname, "Unlink source file failed\n");
                return(NFM_E_UNLINK);
                }
    _PDMdebug(fname, "SUCCESSFULL status = <0x%.8x>\n", PDM_S_SUCCESS);
    return (PDM_S_SUCCESS);
} 

long PDMretrieve_query (query_name, query_info)
char     *query_name;             /* I - Query name. */
struct NFMquery_info *query_info; /* O - Structure pointer of returned 
                                            query info. */
{
long    status;
char    temp_file[NFM_REPORTFILE+1];
char    sql_str[256];
char    **s_data;
MEMptr  sql_buffer = NULL;
long    _PDMread_query_info ();
static  char *fname = "PDMretrieve_query";

/* NULL out query_info structure. */
query_info->select_clause = NULL;
query_info->from_clause = NULL;
query_info->where_clause = NULL;
query_info->order_by_clause = NULL;
query_info->prompts = NULL;

/* See if query_name has a 'blank' in it. If so, it is a search string. */

  if (strchr (query_name, ' '))
      {
      _PDMdebug(fname, "string input: <%s>\n", query_name);
      status = NFMwrite_query_struct (query_info, "", "", query_name, "", "");
      MEMclose (&sql_buffer);
      return (PDM_S_SUCCESS);
      }

/* Query for report filename. If it exists query_name is a query file;
   if not, assume it is an order by string and insert the string into the
   order_by_clause of the query structure and return. */

sprintf (sql_str, "SELECT %s FROM %s WHERE %s = '%s'", 
         "n_reportfile", "NFMREPORTS", "n_reportname", query_name);

status = SQLquery (sql_str, &sql_buffer, 256);
if (status != SQL_S_SUCCESS)
    {
    if (status == SQL_I_NO_ROWS_FOUND)
        {
        /* order_by clause */
        status = NFMwrite_query_struct (query_info, "", "", "", query_name, "");
        MEMclose (&sql_buffer);
        return (PDM_S_SUCCESS);
        }
    else
        {
        MEMclose (&sql_buffer);
        status = NFM_E_SQL_QUERY;
        return (status);
        }
    }
status = MEMbuild_array (sql_buffer);
if (status != MEM_S_SUCCESS)
    {
    MEMclose (&sql_buffer);
    _PDMdebug(fname, "MEMbuild_array = <0x%.8x>\n", status); 
    return (status);
    }

s_data = (char **) sql_buffer->data_ptr;
strcpy (temp_file, s_data[0]);

MEMclose (&sql_buffer);

status = _PDMread_query_info (temp_file, query_info);
if (status != PDM_S_SUCCESS)
    {
    _PDMdebug(fname, "_PDMread_query_info = <0x%.8x>\n", status); 
    return (status);
    }

return (PDM_S_SUCCESS);
}


long PDMretrieve_query_info (query_name, query_type, application, appl_type, 
                              query_desc, owner, query_info)
char     *query_name;             /* I - Query name. */
char     *query_type;             /* I - Query type: W-search, O-order_by. */
char     *application;            /* I - Application who defined query. */
char     *appl_type;              /* I - Appl. type assigned to query. */
char     *query_desc;             /* O - Query description. */
char     *owner;                  /* O - Owner of the query. */
struct NFMquery_info *query_info; /* O - Structure pointer of returned 
                                            query info. */
{
long    status;
char    temp_file[NFM_REPORTFILE+1];
char    sql_str[256];
char    **s_data;
MEMptr  sql_buffer = NULL;
long    _PDMread_query_info ();
static  char *fname = "PDMretrieve_query_info";

_PDMdebug(fname, "query_name:  <%s>\n", query_name);
_PDMdebug(fname, "query_type:  <%s>\n", query_type);
_PDMdebug(fname, "paalication: <%s>\n", application);
_PDMdebug(fname, "appl_type:   <%s>\n", appl_type);

/* This code can be more intelligent by querying the reports table to find the
   query type and returning only the fields that make sense for that query
   type. I'm not sure we want to do this now. */

/* NULL out query_info structure. */
query_info->select_clause = NULL;
query_info->from_clause = NULL;
query_info->where_clause = NULL;
query_info->order_by_clause = NULL;
query_info->prompts = NULL;

/* If query_type = W, see if query_name has a 'blank' in it. If so, it is
   a search string. */

if (! strncmp (query_type, "W", 1))
    {
    if (strchr (query_name, ' '))
        {
        _PDMdebug(fname, "string input: <%s>\n", query_name);
        status = NFMwrite_query_struct (query_info, "", "", query_name, "", "");
        MEMclose (&sql_buffer);
        return (PDM_S_SUCCESS);
        }
    }

/* Query for report filename. If it exists query_name is a query file;
   if not, assume it is an order by string and insert the string into the
   order_by_clause of the query structure and return. */

sprintf (sql_str, "SELECT %s FROM %s WHERE (%s = '%s' AND %s = '%s' AND \
%s = '%s' AND %s = %s)", 
   "a.n_reportdesc, a.n_reportfile, b.n_username", 
   "NFMREPORTS a, NFMUSERS b", "a.n_reportname", query_name, 
   "a.n_type", query_type, "a.n_application", application, "a.n_owner", 
   "b.n_userno");

status = SQLquery (sql_str, &sql_buffer, 256);
if (status != SQL_S_SUCCESS)
    {
    if ((status == SQL_I_NO_ROWS_FOUND) &&
        (! (strncmp (query_type, "O", 1))))
        {
        /* order_by clause */
        status = NFMwrite_query_struct (query_info, "", "", "", query_name, "");
        MEMclose (&sql_buffer);
        return (PDM_S_SUCCESS);
        }
    else
        {
        MEMclose (&sql_buffer);
        status = NFM_E_SQL_QUERY;
        return (status);
        }
    }

status = MEMbuild_array (sql_buffer);
if (status != MEM_S_SUCCESS)
    {
    MEMclose (&sql_buffer);
    _PDMdebug(fname, "MEMbuild_array = <0x%.8x>\n", status); 
    status = NFM_E_MEM;
    return (status);
    }

s_data = (char **) sql_buffer->data_ptr;
strcpy (query_desc, s_data[0]);
strcpy (temp_file, s_data[1]);
strcpy (owner, s_data[2]);

MEMclose (&sql_buffer);

status = _PDMread_query_info (temp_file, query_info);
if (status != PDM_S_SUCCESS)
    {
    _PDMdebug(fname, "_PDMread_query_info = <0x%.8x>\n", status); 
    return (status);
    }

return (PDM_S_SUCCESS);
}


long _PDMread_query_info (report_file, query_struct)
char   *report_file;
struct NFMquery_info *query_struct;
{
long    status;
int     ch, i, offset, str_size;
char    query_file[NFM_PATHNAME+NFM_REPORTFILE+2];
FILE    *fopen (), *qry_file;
struct  NFMquery_info *query_info;
static  char *fname = "_PDMread_query_info";
struct stat file_status;

_PDMdebug(fname, "report_file: <%s>\n", report_file);

query_info = query_struct;

  status = PDMmove_rpt_file("SYSTEM", storage->storage_name, report_file);
       if (status != PDM_S_SUCCESS) {
                _PDMdebug(fname, "PDMmove_rpt_file falied status %d\n", status);
               return(NFM_E_QUERY_WRITE_FILE);
        }

sprintf (query_file, "%s%s%s", storage->path_name, DELIM, report_file);
_PDMdebug(fname, "query_file: <%s>\n", query_file);
if (! (qry_file = fopen (query_file, "r")))
    {
    status = NFM_E_FOPEN_QUERY_FILE; 
    _PDMdebug(fname, "Open File: <%s>: status = <0x%.8x>\n", query_file, 
                status);
    return (status);
    }

     /* get SELECT clause */
     i = 1;
while ((ch = fgetc (qry_file)) != ':')
    i++;

ch = fgetc (qry_file);
offset = i+1;

i = 1;
while ((ch = fgetc (qry_file)) != '\n')
    i++;

str_size = i;
/* malloc size of SELECT clause */
query_info->select_clause = (char *) malloc (str_size + 1);

if ((fseek (qry_file, offset, 0)) != 0)
    {
    status = NFM_E_FSEEK_QUERY_FILE; 
  _PDMdebug(fname, "Fseek File: <%s>: status = <0x%.8x>\n", query_file, status);
    return (status);
    }

i=0;
while ((ch = fgetc (qry_file)) != '\n')
    query_info->select_clause[i++] = ch;

query_info->select_clause[i] = '\0';

/* get FROM clause */
i = 1;
while ((ch = fgetc (qry_file)) != ':')
    i++;

ch = fgetc (qry_file);
offset = offset + str_size + i + 1;

i = 1;
while ((ch = fgetc (qry_file)) != '\n')
    i++;

str_size = i;
/* malloc size of FROM clause */
query_info->from_clause = (char *) malloc (str_size + 1);

if ((fseek (qry_file, offset, 0)) != 0)
    {
    status = NFM_E_FSEEK_QUERY_FILE; 
  _PDMdebug(fname, "Fseek File: <%s>: status = <0x%.8x>\n", query_file, status);
    return (status);
    }

i=0;
while ((ch = fgetc (qry_file)) != '\n')
    query_info->from_clause[i++] = ch;

query_info->from_clause[i] = '\0';

/* get WHERE clause */
i = 1;
while ((ch = fgetc (qry_file)) != ':')
    i++;

ch = fgetc (qry_file);
offset = offset + str_size + i + 1;

i = 1;
while ((ch = fgetc (qry_file)) != '\n')
    i++;

str_size = i;
/* malloc size of WHERE clause */
query_info->where_clause = (char *) malloc (str_size + 1);

if ((fseek (qry_file, offset, 0)) != 0)
    {
    status = NFM_E_FSEEK_QUERY_FILE; 
    _PDMdebug(fname, "Fseek File: <%s>: status = <0x%.8x>\n", query_file, 
                status);
    return (status);
    }

i=0;
while ((ch = fgetc (qry_file)) != '\n')
    query_info->where_clause[i++] = ch;

query_info->where_clause[i] = '\0';

/* get ORDER BY clause */
i = 1;
while ((ch = fgetc (qry_file)) != ':')
    i++;

ch = fgetc (qry_file);
offset = offset + str_size + i + 1;

i = 1;
while ((ch = fgetc (qry_file)) != '\n')
    i++;

str_size = i;
/* malloc size of ORDER BY clause */
query_info->order_by_clause = (char *) malloc (str_size + 1);

if ((fseek (qry_file, offset, 0)) != 0)
    {
    status = NFM_E_FSEEK_QUERY_FILE; 
    _PDMdebug(fname, "Fseek File: <%s>: status = <0x%.8x>\n", query_file, 
                status);
    return (status);
    }

i=0;
while ((ch = fgetc (qry_file)) != '\n')
    query_info->order_by_clause[i++] = ch;

query_info->order_by_clause[i] = '\0';

/* get PROMPTS */
i = 1;
while ((ch = fgetc (qry_file)) != ':')
    i++;

ch = fgetc (qry_file);
offset = offset + str_size + i + 1;

i = 1;
while ((ch = fgetc (qry_file)) != '\n')
    i++;

str_size = i;
/* malloc size of PROMPTS */
query_info->prompts = (char *) malloc (str_size + 1);

if ((fseek (qry_file, offset, 0)) != 0)
    {
    status = NFM_E_FSEEK_QUERY_FILE; 
    _PDMdebug(fname, "Fseek File: <%s>: status = <0x%.8x>\n", query_file, 
                status);
    return (status);
    }

i=0;
while ((ch = fgetc (qry_file)) != '\n')
    query_info->prompts[i++] = ch;

query_info->prompts[i] = '\0';

fclose (qry_file);

             _PDMdebug(fname, "removing query_file\n");
             status = stat(query_file, &file_status);
             if (status == 0) /* file exists */
                {
                 /* delete file locally */
                 status = unlink(query_file);
                 if (status == 0)
                    _PDMdebug(fname, "file removal succeeded\n");
                 else
                    _PDMdebug(fname, "file removal failed\n");
                }
             else
                _PDMdebug(fname, "file was not found\n");


return (PDM_S_SUCCESS);
}

