#include "machine.h"
#include <stdio.h> 
#include "MEMstruct.h"
#include "NFMerrordef.h"
#include "ERR.h"
#include "NFMapi.h"
#include "DEBUG.h"
#include "NFMmach_id.h"

long _NFMretrieve_query (query_name, query_info)
   char     *query_name;             /* I - Query name. */
   struct NFMquery_info *query_info; /* O - Structure pointer of returned 
                                            query info. */

{
long    status;
char    temp_file[NFM_REPORTFILE+1];
char    sql_str[256];
char    **s_data;
MEMptr  sql_buffer = NULL;
long    _NFMread_query_info ();
static  char *fname = "_NFMretrieve_query";

/* This code can be more intelligent by querying the reports table to find the
   query type and returning only the fields that make sense for that query
   type. I'm not sure we want to do this now. */

/* NULL out query_info structure. */
query_info->select_clause = NULL;
query_info->from_clause = NULL;
query_info->where_clause = NULL;
query_info->order_by_clause = NULL;
query_info->prompts = NULL;

/* See if query_name has a 'blank' in it. If so, it is a search string. */

  if (strchr (query_name, ' '))
      {
      _NFMdebug ((fname, "string input: <%s>\n", query_name));
      status = NFMwrite_query_struct (query_info, "", "", query_name, "", "");
      MEMclose (&sql_buffer);
      ERRload_struct (NFM, NFM_S_SUCCESS, NULL);
      return (NFM_S_SUCCESS);
      }

/* Query for report filename. If it exists query_name is a query file;
   if not, assume it is an order by string and insert the string into the
   order_by_clause of the query structure and return. */

sprintf (sql_str, "SELECT %s FROM %s WHERE %s = '%s'",
         "n_reportfile", "NFMREPORTS", "n_reportname", query_name);

_NFMdebug ((fname, "<%s>\n", sql_str));

status = SQLquery (sql_str, &sql_buffer, 256);
if (status != SQL_S_SUCCESS)
    {
    if (status == SQL_I_NO_ROWS_FOUND)
        {
        /* order_by clause */
        status = NFMwrite_query_struct (query_info, "", "", "", query_name, "");
        MEMclose (&sql_buffer);
        ERRload_struct (NFM, NFM_S_SUCCESS, NULL);
        return (NFM_S_SUCCESS);
        }
    else
        {
        MEMclose (&sql_buffer);
        status = NFM_E_SQL_QUERY;
        ERRload_struct (NFM, status, NULL);
        return (status);
        }
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
strcpy (temp_file, s_data[0]);

MEMclose (&sql_buffer);

status = _NFMread_query_info (temp_file, query_info);
if (status != NFM_S_SUCCESS)
    {
    _NFMdebug ((fname, "_NFMread_query_info = <0x%.8x>\n", status)); 
    return (status);
    }

ERRload_struct (NFM, NFM_S_SUCCESS, NULL);
return (NFM_S_SUCCESS);
}


long _NFMretrieve_query_info (query_name, query_type, application, appl_type,
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
long    _NFMread_query_info ();
static  char *fname = "_NFMretrieve_query_info";

_NFMdebug ((fname, "query_name:  <%s>\n", query_name));
_NFMdebug ((fname, "query_type:  <%s>\n", query_type));
_NFMdebug ((fname, "paalication: <%s>\n", application));
_NFMdebug ((fname, "appl_type:   <%s>\n", appl_type));

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
        _NFMdebug ((fname, "string input: <%s>\n", query_name));
        status = NFMwrite_query_struct (query_info, "", "", query_name, "", "");
        MEMclose (&sql_buffer);
        ERRload_struct (NFM, NFM_S_SUCCESS, NULL);
        return (NFM_S_SUCCESS);
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

_NFMdebug ((fname, "<%s>\n", sql_str));

status = SQLquery (sql_str, &sql_buffer, 256);
if (status != SQL_S_SUCCESS)
    {
    if ((status == SQL_I_NO_ROWS_FOUND) &&
        (! (strncmp (query_type, "O", 1))))
        {
        /* order_by clause */
        status = NFMwrite_query_struct (query_info, "", "", "", query_name, "");
        MEMclose (&sql_buffer);
        ERRload_struct (NFM, NFM_S_SUCCESS, NULL);
        return (NFM_S_SUCCESS);
        }
    else
        {
        MEMclose (&sql_buffer);
        status = NFM_E_SQL_QUERY;
        ERRload_struct (NFM, status, NULL);
        return (status);
        }
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
strcpy (query_desc, s_data[0]);
strcpy (temp_file, s_data[1]);
strcpy (owner, s_data[2]);

MEMclose (&sql_buffer);

status = _NFMread_query_info (temp_file, query_info);
if (status != NFM_S_SUCCESS)
    {
    _NFMdebug ((fname, "_NFMread_query_info = <0x%.8x>\n", status)); 
    return (status);
    }

ERRload_struct (NFM, NFM_S_SUCCESS, NULL);
return (NFM_S_SUCCESS);
}


long _NFMread_query_info (report_file, query_struct)
   char   *report_file;
   struct NFMquery_info *query_struct;

{
long    status;
int     ch, i, offset, str_size;
char    temp_path[NFM_PATHNAME+1];
char    query_file[NFM_PATHNAME+NFM_REPORTFILE+2];
FILE    *fopen (), *qry_file;
struct  NFMquery_info *query_info;
static  char *fname = "_NFMread_query_info";

_NFMdebug ((fname, "report_file: <%s>\n", report_file));

query_info = query_struct;

/* find report path */
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

sprintf (query_file, "%s%s%s", temp_path, DELIM, report_file);
_NFMdebug ((fname, "query_file: <%s>\n", query_file));

if (! (qry_file = fopen (query_file, "r")))
    {
    status = NFM_E_QUERY_FILE_NOT_LOCAL; 
    _NFMdebug ((fname, "Open File (NOT LOCAL): <%s>: status = <0x%.8x>\n", 
                query_file, status));
    ERRload_struct (NFM, status, "%s", query_file);
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
    _NFMdebug ((fname, "Fseek File: <%s>: status = <0x%.8x>\n", query_file,
                status));
    ERRload_struct (NFM, status, "%s", query_file);
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
    _NFMdebug ((fname, "Fseek File: <%s>: status = <0x%.8x>\n", query_file,
                status));
    ERRload_struct (NFM, status, "%s", query_file);
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
    _NFMdebug ((fname, "Fseek File: <%s>: status = <0x%.8x>\n", query_file,
                status));
    ERRload_struct (NFM, status, "%s", query_file);
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
    _NFMdebug ((fname, "Fseek File: <%s>: status = <0x%.8x>\n", query_file,
                status));
    ERRload_struct (NFM, status, "%s", query_file);
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
    _NFMdebug ((fname, "Fseek File: <%s>: status = <0x%.8x>\n", query_file,
                status));
    ERRload_struct (NFM, status, "%s", query_file);
    return (status);
    }

i=0;
while ((ch = fgetc (qry_file)) != '\n')
    query_info->prompts[i++] = ch;

query_info->prompts[i] = '\0';

fclose (qry_file);

return (NFM_S_SUCCESS);
}


long _NFMretrieve_ftr_query (query_name, query_type, query_info)
   char     *query_name;             /* I - Query name. */
   char	    *query_type;
   struct NFMquery_ftr_info *query_info; /* O - Structure pointer of returned 
                                            query info. */

{
long    status;
char    temp_file[NFM_REPORTFILE+1];
char    sql_str[256];
char    where_str[100];
char    **s_data;
MEMptr  sql_buffer = NULL;
long    _NFMread_ftr_query_info ();
static  char *fname = "_NFMretrieve_ftr_query";

/* This code can be more intelligent by querying the reports table to find the
   query type and returning only the fields that make sense for that query
   type. I'm not sure we want to do this now. */

/* NULL out query_info structure. */
query_info->select_clause = NULL;
query_info->from_clause = NULL;
query_info->where_clause = NULL;
query_info->order_by_clause = NULL;
query_info->prompts = NULL;
query_info->ftr = NULL;
query_info->aqs = NULL;
query_info->aqf = NULL;
query_info->aqw = NULL;

/* See if query_name has a 'blank' in it. If so, it is a search string. */

  if (strchr (query_name, ' '))
      {
      _NFMdebug ((fname, "string input: <%s>\n", query_name));
      status = NFMwrite_ftr_query_struct (query_info, "", "", query_name,
		 "", "", "", "", "", "");
      MEMclose (&sql_buffer);
      ERRload_struct (NFM, NFM_S_SUCCESS, NULL);
      return (NFM_S_SUCCESS);
      }

/* Query for report filename. If it exists query_name is a query file;
   if not, assume it is an order by string and insert the string into the
   order_by_clause of the query structure and return. */
/* 8/8/94 - JM - also query using type since a search name does not
   have to be unique.
 */

if ((query_type == NULL) || (strcmp (query_type, "") == 0))
    strcpy (where_str, "");
else if (strcmp(query_type, "B") == 0)
    strcpy (where_str, " AND n_type IN ('W', 'A')");
else 
    sprintf (where_str, " AND n_type = '%s'", query_type);
sprintf (sql_str, "SELECT %s FROM %s WHERE %s = '%s'",
         "n_reportfile", "NFMREPORTS", "n_reportname", query_name);
strcat (sql_str, where_str);

_NFMdebug ((fname, "<%s>\n", sql_str));

status = SQLquery (sql_str, &sql_buffer, 256);
if (status != SQL_S_SUCCESS)
    {
    if (status == SQL_I_NO_ROWS_FOUND)
        {
        /* order_by clause */
        status = NFMwrite_ftr_query_struct (query_info, "", "", "", 
			query_name, "", "", "", "", "");
        MEMclose (&sql_buffer);
        ERRload_struct (NFM, NFM_S_SUCCESS, NULL);
        return (NFM_S_SUCCESS);
        }
    else
        {
        MEMclose (&sql_buffer);
        status = NFM_E_SQL_QUERY;
        ERRload_struct (NFM, status, NULL);
        return (status);
        }
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
strcpy (temp_file, s_data[0]);

MEMclose (&sql_buffer);

status = _NFMread_ftr_query_info (temp_file, query_info);
if (status != NFM_S_SUCCESS)
    {
    _NFMdebug ((fname, "_NFMread_query_info = <0x%.8x>\n", status)); 
    return (status);
    }

ERRload_struct (NFM, NFM_S_SUCCESS, NULL);
return (NFM_S_SUCCESS);
}


long _NFMretrieve_ftr_query_info (query_name, query_type, application,
		 appl_type, query_desc, owner, query_info)
   char     *query_name;             /* I - Query name. */
   char     *query_type;             /* I - Query type: W-search, O-order_by. */
   char     *application;            /* I - Application who defined query. */
   char     *appl_type;              /* I - Appl. type assigned to query. */
   char     *query_desc;             /* O - Query description. */
   char     *owner;                  /* O - Owner of the query. */
   struct NFMquery_ftr_info *query_info; /* O - Structure pointer of returned 
                                            query info. */

{
long    status;
char    temp_file[NFM_REPORTFILE+1];
char    sql_str[256];
char    **s_data;
MEMptr  sql_buffer = NULL;
long    _NFMread_ftr_query_info ();
static  char *fname = "_NFMretrieve_ftr_query_info";

_NFMdebug ((fname, "query_name:  <%s>\n", query_name));
_NFMdebug ((fname, "query_type:  <%s>\n", query_type));
_NFMdebug ((fname, "paalication: <%s>\n", application));
_NFMdebug ((fname, "appl_type:   <%s>\n", appl_type));

/* This code can be more intelligent by querying the reports table to find the
   query type and returning only the fields that make sense for that query
   type. I'm not sure we want to do this now. */

/* NULL out query_info structure. */
query_info->select_clause = NULL;
query_info->from_clause = NULL;
query_info->where_clause = NULL;
query_info->order_by_clause = NULL;
query_info->prompts = NULL;
query_info->ftr = NULL;
query_info->aqs = NULL;
query_info->aqf = NULL;
query_info->aqw = NULL;

/* If query_type = W, see if query_name has a 'blank' in it. If so, it is
   a search string. */

if (! strncmp (query_type, "W", 1))
    {
    if (strchr (query_name, ' '))
        {
        _NFMdebug ((fname, "string input: <%s>\n", query_name));
        status = NFMwrite_ftr_query_struct (query_info, "", "", query_name, 
		"", "", "", "", "", "");
        MEMclose (&sql_buffer);
        ERRload_struct (NFM, NFM_S_SUCCESS, NULL);
        return (NFM_S_SUCCESS);
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

_NFMdebug ((fname, "<%s>\n", sql_str));

status = SQLquery (sql_str, &sql_buffer, 256);
if (status != SQL_S_SUCCESS)
    {
    if ((status == SQL_I_NO_ROWS_FOUND) &&
        (! (strncmp (query_type, "O", 1))))
        {
        /* order_by clause */
        status = NFMwrite_ftr_query_struct (query_info, "", "", "",
			query_name, "", "", "", "", "");
        MEMclose (&sql_buffer);
        ERRload_struct (NFM, NFM_S_SUCCESS, NULL);
        return (NFM_S_SUCCESS);
        }
    else
        {
        MEMclose (&sql_buffer);
        status = NFM_E_SQL_QUERY;
        ERRload_struct (NFM, status, NULL);
        return (status);
        }
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
strcpy (query_desc, s_data[0]);
strcpy (temp_file, s_data[1]);
strcpy (owner, s_data[2]);

MEMclose (&sql_buffer);

status = _NFMread_ftr_query_info (temp_file, query_info);
if (status != NFM_S_SUCCESS)
    {
    _NFMdebug ((fname, "_NFMread_ftr_query_info = <0x%.8x>\n", status)); 
    return (status);
    }

ERRload_struct (NFM, NFM_S_SUCCESS, NULL);
return (NFM_S_SUCCESS);
}


long _NFMread_ftr_query_info (report_file, query_struct)
   char   *report_file;
   struct NFMquery_ftr_info *query_struct;

{
long    status;
int     ch, i, offset, str_size;
char    temp_path[NFM_PATHNAME+1];
char    query_file[NFM_PATHNAME+NFM_REPORTFILE+2];
FILE    *fopen (), *qry_file;
struct  NFMquery_ftr_info *query_info;
static  char *fname = "_NFMread_ftr_query_info";

_NFMdebug ((fname, "report_file: <%s>\n", report_file));

query_info = query_struct;

/* find report path */
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

sprintf (query_file, "%s%s%s", temp_path, DELIM, report_file);
_NFMdebug ((fname, "query_file: <%s>\n", query_file));

if (! (qry_file = fopen (query_file, "r")))
    {
    status = NFM_E_QUERY_FILE_NOT_LOCAL; 
    _NFMdebug ((fname, "Open File (NOT LOCAL): <%s>: status = <0x%.8x>\n", 
                query_file, status));
    ERRload_struct (NFM, status, "%s", query_file);
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
    _NFMdebug ((fname, "Fseek File: <%s>: status = <0x%.8x>\n", query_file,
                status));
    ERRload_struct (NFM, status, "%s", query_file);
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
    _NFMdebug ((fname, "Fseek File: <%s>: status = <0x%.8x>\n", query_file,
                status));
    ERRload_struct (NFM, status, "%s", query_file);
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
    _NFMdebug ((fname, "Fseek File: <%s>: status = <0x%.8x>\n", query_file,
                status));
    ERRload_struct (NFM, status, "%s", query_file);
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
    _NFMdebug ((fname, "Fseek File: <%s>: status = <0x%.8x>\n", query_file,
                status));
    ERRload_struct (NFM, status, "%s", query_file);
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
    _NFMdebug ((fname, "Fseek File: <%s>: status = <0x%.8x>\n", query_file,
                status));
    ERRload_struct (NFM, status, "%s", query_file);
    return (status);
    }

i=0;
while ((ch = fgetc (qry_file)) != '\n')
    query_info->prompts[i++] = ch;

query_info->prompts[i] = '\0';

/* get FTR */
i = 1;
while ((ch = fgetc (qry_file)) != ':')
{
    /*  Old search file end here */
    if (ch == EOF)
    {
	query_info->ftr = (char *) malloc (2);
	query_info->aqs = (char *) malloc (2);
	query_info->aqf = (char *) malloc (2);
	query_info->aqw = (char *) malloc (2);
	query_info->ftr[0] = '\0';
	query_info->aqs[0] = '\0';
	query_info->aqf[0] = '\0';
	query_info->aqw[0] = '\0';
	fclose (qry_file);
	return (NFM_S_SUCCESS);
    }
    i++;
}

ch = fgetc (qry_file);
offset = offset + str_size + i + 1;

i = 1;
while ((ch = fgetc (qry_file)) != '\n')
    i++;

str_size = i;
/* malloc size of FTR */
query_info->ftr = (char *) malloc (str_size + 1);

if ((fseek (qry_file, offset, 0)) != 0)
    {
    status = NFM_E_FSEEK_QUERY_FILE; 
    _NFMdebug ((fname, "Fseek File: <%s>: status = <0x%.8x>\n", query_file,
                status));
    ERRload_struct (NFM, status, "%s", query_file);
    return (status);
    }

i=0;
while ((ch = fgetc (qry_file)) != '\n')
    query_info->ftr[i++] = ch;

query_info->ftr[i] = '\0';

/* get AQS */
i = 1;
while ((ch = fgetc (qry_file)) != ':')
    i++;

ch = fgetc (qry_file);
offset = offset + str_size + i + 1;

i = 1;
while ((ch = fgetc (qry_file)) != '\n')
    i++;

str_size = i;
/* malloc size of AQS */
query_info->aqs = (char *) malloc (str_size + 1);

if ((fseek (qry_file, offset, 0)) != 0)
    {
    status = NFM_E_FSEEK_QUERY_FILE; 
    _NFMdebug ((fname, "Fseek File: <%s>: status = <0x%.8x>\n", query_file,
                status));
    ERRload_struct (NFM, status, "%s", query_file);
    return (status);
    }

i=0;
while ((ch = fgetc (qry_file)) != '\n')
    query_info->aqs[i++] = ch;

query_info->aqs[i] = '\0';


/* get AQF */
i = 1;
while ((ch = fgetc (qry_file)) != ':')
    i++;

ch = fgetc (qry_file);
offset = offset + str_size + i + 1;

i = 1;
while ((ch = fgetc (qry_file)) != '\n')
    i++;

str_size = i;
/* malloc size of AQF */
query_info->aqf = (char *) malloc (str_size + 1);

if ((fseek (qry_file, offset, 0)) != 0)
    {
    status = NFM_E_FSEEK_QUERY_FILE; 
    _NFMdebug ((fname, "Fseek File: <%s>: status = <0x%.8x>\n", query_file,
                status));
    ERRload_struct (NFM, status, "%s", query_file);
    return (status);
    }

i=0;
while ((ch = fgetc (qry_file)) != '\n')
    query_info->aqf[i++] = ch;

query_info->aqf[i] = '\0';


/* get AQW */
i = 1;
while ((ch = fgetc (qry_file)) != ':')
    i++;

ch = fgetc (qry_file);
offset = offset + str_size + i + 1;

i = 1;
while ((ch = fgetc (qry_file)) != '\n')
    i++;

str_size = i;
/* malloc size of AQW */
query_info->aqw = (char *) malloc (str_size + 1);

if ((fseek (qry_file, offset, 0)) != 0)
    {
    status = NFM_E_FSEEK_QUERY_FILE; 
    _NFMdebug ((fname, "Fseek File: <%s>: status = <0x%.8x>\n", query_file,
                status));
    ERRload_struct (NFM, status, "%s", query_file);
    return (status);
    }

i=0;
while ((ch = fgetc (qry_file)) != '\n')
    query_info->aqw[i++] = ch;

query_info->aqw[i] = '\0';

fclose (qry_file);

return (NFM_S_SUCCESS);
}

