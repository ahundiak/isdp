#include "machine.h"
#include <stdio.h>
#include "NFMapi.h"
#include "NFMschema.h"
#include "NFMerrordef.h"
#include "DEBUG.h"
#include "ERR.h"
#include "MEMstruct.h"

long CVTsearch_files ()
{
long status;
long cnt, i, last_row;
long CONTINUE = TRUE;
long new_search_no;
char sql_str[1024];
char reportname[NFM_REPORTNAME+1];
char type[NFM_TYPE+1];
char application[NFM_APPLICATION+1];
char apptype[NFM_APPTYPE+1];
char query_desc[NFM_REPORTDESC+1];
char itemnum[10];
char tablenum[10];
char report_file[100];
char status_flag[2];
char *tmp_search_str = NULL;
char *search_str = NULL;
char *new_search_str = NULL;
char **rep_ptr;
struct NFMquery_info query_info;
MEMptr rep_buff = NULL;
long CVTget_report_name ();
FILE *fopen(), *out_file;
static char *fname = "CVTsearch_files";

_NFMdebug ((fname, "Enter.\n"));

/* see whether or not search criterias have been converted */
status = CVTquery_cvtlog_entry ("search_criteria", status_flag, &last_row);
if (status == NFM_S_SUCCESS)
    {
    _NFMdebug ((fname, "Search Criterias have already been converted.\n"));
    fprintf (stderr, "Search Criterias have already been converted.\n");
    return (NFM_S_SUCCESS);
    }

/* KT - 7/27/92 Define the default search criteries */
  status = NFMdefault_queries ();
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "NFMdefault_queries Failed : status = <0x%.8x>\n",
		  status));
      return (status) ;
    }

sprintf (sql_str, "select %s from o_nfmtables where n_tablename = '%s'",
         "n_tableno", "nfmsyscat");
_NFMdebug ((fname, "SQLquery: <%s>\n", sql_str));
status = SQLquery (sql_str, &rep_buff, 1024);
if (status != SQL_S_SUCCESS)
    {
    _NFMdebug ((fname, "SQLquery failure: <0x%.8x>\n", status));
    status = ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "");
    return (status);
    }

/* MEMprint_buffers ("REPORT LIST", rep_buff, "/dev/ttx03"); */
status = MEMbuild_array (rep_buff);
if (status != MEM_S_SUCCESS)
    {
    _NFMdebug ((fname, "MEMbuild_array failure: <0x%.8x>\n", status));
    status = ERRload_struct (NFM, NFM_E_MEM, "", "");
    return (status);
    }

rep_ptr = (char **) rep_buff->data_ptr;
strcpy (tablenum, rep_ptr[0]);
_NFMdebug ((fname, "n_tableno: <%s>\n", tablenum));

MEMclose (&rep_buff);
sql_str[0] = 0;

sprintf (sql_str, "select %s from o_nfmreports where n_type = 'W'",
         "n_reportname, n_type, n_application, n_apptype, n_itemno");
_NFMdebug ((fname, "SQLquery: <%s>\n", sql_str));
status = SQLquery (sql_str, &rep_buff, 1024);
if (status != SQL_S_SUCCESS)
    {
    if (status != SQL_I_NO_ROWS_FOUND)
        {
        _NFMdebug ((fname, "SQLquery failure: <0x%.8x>\n", status));
        status = ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "");
        return (status);
        }
    else
        {
        _NFMdebug ((fname, "SQLquery: No search criterias found: <0x%.8x>\n",
                    status));
        return (NFM_S_SUCCESS);
        }
    }

/* MEMprint_buffers ("REPORT LIST", rep_buff, "/dev/ttx03"); */
status = MEMbuild_array (rep_buff);
if (status != MEM_S_SUCCESS)
    {
    _NFMdebug ((fname, "MEMbuild_array failure: <0x%.8x>\n", status));
    status = ERRload_struct (NFM, NFM_E_MEM, "", "");
    return (status);
    }

rep_ptr = (char **) rep_buff->data_ptr;

/* for each search string, convert the report */
for (i=0; i<rep_buff->rows; ++i)
    {
    CONTINUE = TRUE;
    reportname[0] = 0;
    type[0] = 0;
    application[0] = 0;
    apptype[0] = 0;
    itemnum[0] = 0;
    cnt = i * rep_buff->columns;
    strcpy (reportname, rep_ptr[cnt]);
    strcpy (type, rep_ptr[cnt+1]);
    strcpy (application, rep_ptr[cnt+2]);
    strcpy (apptype, rep_ptr[cnt+3]);
    strcpy (itemnum, rep_ptr[cnt+4]);
    _NFMdebug ((fname, "\nreportname:   <%s>\n", reportname));
    _NFMdebug ((fname, "type:         <%s>\n", type));
    _NFMdebug ((fname, "application:  <%s>\n", application));
    _NFMdebug ((fname, "apptype:      <%s>\n", apptype));
    _NFMdebug ((fname, "itemnum:      <%s>\n", itemnum));

    if ((out_file = fopen ("./CVTreports.log", "a")) == 0)
        {
        _NFMdebug ((fname, "Fopen Failed CVT log file.\n"));
        fprintf (stderr, "Fopen Failed CVT log file.\n");
        status = ERRload_struct (NFM, NFM_E_FOPEN, "", "");
        return (status);
        }

    _NFMdebug ((fname, "\nConverting search criteria <%s>...\n", reportname));
    fprintf (stderr, "\nConverting search criteria <%s>...\n", reportname);
    fprintf (out_file, "\nConverting Search Report <%s>:\n", reportname);

    /* find OLD report filename */
    status = CVTget_report_name ((atoi (tablenum)), (atoi (itemnum)),
                                  report_file);
    if (status != NFM_S_SUCCESS)
        {
        _NFMdebug ((fname, "CVTget_report_name failure: <0x%.8x>\n", status));
        fprintf (stderr, "CVTget_report_name failure: <0x%.8x>\n", status);
        fprintf (out_file, "CVTget_report_name failure.\n", status);
        fclose (out_file);
        CONTINUE = FALSE;
        }

    if (CONTINUE)
        {
        /* read OLD report */
        status = CVTread_report_search (report_file, reportname, &tmp_search_str);
        if (status != NFM_S_SUCCESS)
            {
            _NFMdebug ((fname, "CVTread_report_search failure: <0x%.8x>\n", status));
            fprintf (stderr, "CVTread_report_search failure: <0x%.8x>\n", status);
            fprintf (out_file, "CVTread_report_search failure: <%s>\n",
                     report_file);
            fclose (out_file);
            CONTINUE = FALSE;
            }
        }

    if (CONTINUE)
        {
        /* add parenthesis around the search string */
        search_str = (char *) malloc (strlen (tmp_search_str) + 3);
        sprintf (search_str, "(%s)", tmp_search_str);

        _NFMdebug ((fname, "search_str: <%s>\n", search_str));

        /* convert the old string inserting catalog aliases */
    
        status = CVTload_definition (search_str, &new_search_str);

        NFMwrite_query_struct (&query_info, "", "CATALOG_NAME a", new_search_str, 
                               "", "");
        }

    if (CONTINUE)
        {
        fprintf (out_file, "    report file: <%s>\n", report_file);
        fprintf (out_file, "    old search : <%s>\n", tmp_search_str);
        fprintf (out_file, "    new search : <%s>\n", new_search_str);

        free (tmp_search_str);
        free (search_str);
        free (new_search_str);

        sprintf (query_desc, "%s: converted to 3.0", reportname);
        _NFMdebug ((fname, "Modifying report entry...\n"));
        fprintf (stderr, "Modifying report entry...\n");
        status = CVTmodify_query (reportname, query_desc, type, application, 
                                  apptype, query_info, &new_search_no);
        if (status != NFM_S_SUCCESS)
            {
            _NFMdebug ((fname, "CVTmodify_query failure: <0x%.8x>\n", status));
            fprintf (stderr, "CVTmodify_query failure: <0x%.8x>\n", status);
            fprintf (out_file, "CVTmodify_query failure.\n");
            fclose (out_file);
            CONTINUE = FALSE;
            }

        NFMfree_query_struct (&query_info);
        }


    if (CONTINUE)
        {
        /* update nfmusers table -> set old n_searchno to new one */
        sprintf (sql_str, "UPDATE NFMUSERS SET n_searchno = %d WHERE \
n_searchno = %s", new_search_no, itemnum);

        _NFMdebug ((fname, "sql_str: <%s>\n", sql_str));

        status = SQLstmt (sql_str);
        if (status != SQL_S_SUCCESS)
            {
            if (status != SQL_I_NO_ROWS_FOUND)
                {
                NFMrollback_transaction (0) ;
                _NFMdebug ((fname, "SQL Stmt Syntax : status = <0x%.8x>\n", status));
                ERRload_struct (NFM, NFM_E_SQL_STMT, "", "") ;
                return (NFM_E_SQL_STMT);
                }
            }

        fprintf (out_file, "Update nfmusers table.\n");

        _NFMdebug ((fname, "Done converting <%s>.\n", reportname));
        fprintf (stderr, "Done converting <%s>.\n", reportname);
        fprintf (out_file, "Done converting <%s>.\n\n", reportname);
        fclose (out_file);
        }
    }

MEMclose (&rep_buff);

status = CVTupdate_cvtlog ("search_criteria", "C", 0);;

return (NFM_S_SUCCESS);
}
