#include "machine.h"
#include "CVT.h"

#ifndef NFM_DEBUG_SUBSYSTEMS
#define NFM_DEBUG_SUBSYSTEMS 15
#endif

long CVTsearch_sort_files ()
{
long status;
long last_row;
long CVTget_report_name ();
char status_flag[2];
static char *fname = "CVTsearch_sort_files";

fprintf (stderr, "\nConverting search and sort criterias...\n\n");

/* check for CVTSTATUS4 in nfmconvertlog table (already converted) */
status = CVTquery_cvtlog_entry ("CVTSTATUS4", status_flag, &last_row);
if (status == NFM_S_SUCCESS)
    {
    _NFMdebug ((fname, "Search/Sort Criterias have already been converted.\n"));
    fprintf (stderr, "Search/Sort Criterias have already been converted.\n");
    return (NFM_S_SUCCESS);
    }

status = CVTcheck_reports_start();
if (status!= NFM_S_SUCCESS)
    {
    _NFMdebug((fname,"Some core NFM system tables are not converted.\n"));
    _NFMdebug((fname,"Search/Sort Criteria Conversion can begin only after the core tables have been converted.\n"));
    return(status);
    }

status = CVTsearch_files ();
_NFMdebug ((fname, "CVTsearch_files: <0x%.8x>.\n", status));
if (status != NFM_S_SUCCESS)
    {
    _NFMdebug ((fname, "CVTsearch_files failure: <0x%.8x>\n", status));
    return (status);
    }

status = CVTsort_files ();
_NFMdebug ((fname, "CVTsort_files: <0x%.8x>.\n", status));
if (status != NFM_S_SUCCESS)
    {
    _NFMdebug ((fname, "CVTsort_files failure: <0x%.8x>\n", status));
    return (status);
    }

status = CVTupdate_cvtlog ("CVTSTATUS4", "C", 0);;
fprintf (stderr, "\nDone converting search and sort criterias.\n");
fprintf (stderr, "Log file: <./CVTreports.log>\n\n");

return (NFM_S_SUCCESS);
}


long CVTget_report_name (tableno, fileno, report_file)
    int  tableno;
    int  fileno;
    char *report_file;
{
long status;
char sql_str[1024];
char filenum[10];
char filename[NFM_FILENAME+1];
char pathname[NFM_PATHNAME+1];
char **data_ptr;
MEMptr buff = NULL;
static char *fname = "CVTget_report_name";

    sprintf (sql_str, "select MAX (%s) from f_nfmsyscat where n_itemnum = %d",
             "n_fileno", fileno);
    _NFMdebug ((fname, "SQLquery: <%s>\n", sql_str));
    status = SQLquery (sql_str, &buff, 1024);
    if (status != SQL_S_SUCCESS)
        {
        _NFMdebug ((fname, "SQLquery failure: <0x%.8x>\n", status));
        ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
        return (NFM_E_SQL_QUERY);
        }

    status = MEMbuild_array (buff);
    if (status != MEM_S_SUCCESS)
        {
        _NFMdebug ((fname, "MEMbuild_array failure: <0x%.8x>\n", status));
        ERRload_struct (NFM, NFM_E_MEM, "", "") ;
        return (NFM_E_MEM);
        }

    data_ptr = (char **) buff->data_ptr;
    strcpy (filenum, data_ptr[0]);
    _NFMdebug ((fname, "filenum: <%s>\n", filenum));

    status = NFMget_file_name (0, tableno, (atoi (filenum)), filename);
    _NFMdebug ((fname, "filename: <%s>\n", filename));
    MEMclose (&buff);

    sql_str[0] = 0;
    sprintf (sql_str, "select %s from o_nfmstoragearea where n_saname = '%s'",
             "n_pathname", "REPORTS");
    _NFMdebug ((fname, "SQLquery: <%s>\n", sql_str));
    status = SQLquery (sql_str, &buff, 1024);
    if (status != SQL_S_SUCCESS)
        {
        _NFMdebug ((fname, "SQLquery failure: <0x%.8x>\n", status));
        ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
        return (NFM_E_SQL_QUERY);
        }

    status = MEMbuild_array (buff);
    if (status != MEM_S_SUCCESS)
        {
        _NFMdebug ((fname, "MEMbuild_array failure: <0x%.8x>\n", status));
        ERRload_struct (NFM, NFM_E_MEM, "", "") ;
        return (NFM_E_MEM);
        }

    data_ptr = (char **) buff->data_ptr;
    strcpy (pathname, data_ptr[0]);

    _NFMdebug ((fname, "pathname: <%s>\n", pathname));
    sprintf (report_file, "%s/%s", pathname, filename);

    _NFMdebug ((fname, "report_file: <%s>\n", report_file));
    MEMclose (&buff);

    return (NFM_S_SUCCESS);
}

int CVTcheck_reports_start ()
{
    char *fname="CVTcheck_reports_start";
    int status,i,j,count;
static char *sql_str= "SELECT n_tablename, n_cvtstatus FROM nfmconvertlog \
WHERE n_tablename  in ('nfmreports','nfmstoragearea','nfmsyscat','nfmtables')";
    char   **data;
    MEMptr buffer = NULL;


    _NFMdebug((fname,"Entry\n"));

/* Figure out if 
        nfmreports
        nfmstoragearea
        nfmsyscat
        nfmtables
   are done 
   then and only then we convert the search and sort files
*/
    status = SQLquery (sql_str, &buffer, NULL) ;
    if (status != SQL_S_SUCCESS)
        {
        if (status == SQL_I_NO_ROWS_FOUND)
            {
            _NFMdebug ((fname, "SUCCESSFUL - NO ROWS FOUND\n")) ;
            ERRload_struct (NFM, NFM_I_NO_ROWS_FOUND, "", "") ;
            return (NFM_I_NO_ROWS_FOUND);
            }
        fprintf (stderr, "%s: SQLquery <0x%.8x>.\n", fname, status);
        MEMclose (&buffer);
        ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
        return (NFM_E_SQL_QUERY);
        }

    status = MEMbuild_array (buffer);
    if (status != MEM_S_SUCCESS)
        {
        fprintf (stderr, "%s: MEMbuild_array <0x%.8x>.\n", fname, status);
        MEMclose (&buffer);
        ERRload_struct (NFM, NFM_E_MEM, "", "") ;
        return (NFM_E_MEM);
        }

    data = (char **) buffer->data_ptr;
    
    j = 0;
    for(i=0;i < buffer->rows; i++)
        {
        count = buffer->columns * i;
        _NFMdebug((fname,"Table <%s> : cvtstatus <%s>\n",data[count],data[count+1]));

             if ((strcmp (data[count],"nfmreports") == 0 ) &&
                 (strcmp (data[count+1], "N") == 0)) j++;
        else if ((strcmp (data[count],"nfmstoragearea") == 0 ) &&
                 (strcmp (data[count+1], "M") == 0)) j++;
        else if ((strcmp (data[count],"nfmsyscat") == 0 ) &&
                 (strcmp (data[count+1], "N") == 0)) j++;
        else if ((strcmp (data[count],"nfmtables") == 0 ) &&
                 (strcmp (data[count+1], "M") == 0)) j++;
        else
            {
            _NFMdebug((fname,"Table <%s> : cvtstatus <%s> != <M>\n",data[count],data[count+1]));
            _NFMdebug((fname,"<<<<ERROR>>>>Search/Sort Criterias cannot be converted until\
 system table <%s> is converted properly\n and n_cvtstatus is <M> in table \
<nfmconvertlog>: Current n_cvtstatus is <%s> \n",data[count],data[count+1]));
            fprintf(stderr,"<<<<ERROR>>>>Search/Sort Criterias cannot be converted until\
 system table <%s> is converted properly\n and n_cvtstatus is <M> in table \
<nfmconvertlog>: Current n_cvtstatus is <%s> \n",data[count],data[count+1]);

            }    
        }

    MEMclose (&buffer);
    if ( j==4) return(NFM_S_SUCCESS);
    else return(NFM_E_FAILURE);
}



