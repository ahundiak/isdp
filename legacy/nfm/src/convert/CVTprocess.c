#include "machine.h"
#include "CVT.h"

long CVTprocess_on_transition ()
{
long status;
long CVTcheck_process_tables ();
long last_row;
char status_flag[2];
long CVTprocesses ();
static char *fname = "CVTprocess_on_transition";

fprintf (stderr, "\nConverting programs and processes on transitions...\n");

/* see whether or not programs/processes have been converted */
/* check for CVTSTATUS5 in nfmconvertlog table (already converted) */
status = CVTquery_cvtlog_entry ("CVTSTATUS5", status_flag, &last_row);
if (status == NFM_S_SUCCESS)
    {
    _NFMdebug ((fname, "Programs/Processes have already been converted.\n"));
    fprintf (stderr, "Programs/Processes have already been converted.\n");
    return (status);
    }

status = CVTcheck_process_tables();
if (status!= NFM_S_SUCCESS)
    {
    _NFMdebug((fname,"Some core NFM system tables are not converted.\n"));
    _NFMdebug((fname,"Process on Transition Conversion can begin only after the core tables have been converted.\n"));
    return(status);
    }

status = CVTprocesses ();
_NFMdebug ((fname, "CVTprocess: <0x%.8x>.\n", status));
if (status != NFM_S_SUCCESS)
    {
    _NFMdebug ((fname, "CVTprocesses failure: <0x%.8x>\n", status));
    ERRload_struct (NFM, NFM_E_FAILURE, "", "") ;
    return (status);
    }

status = CVTupdate_cvtlog ("CVTSTATUS5", "C", 0);;

fprintf (stderr, "\nDone converting programs and processes on transitions.\n");
fprintf (stderr, "Log file: <./CVTprocess.log>\n\n");

return (NFM_S_SUCCESS);
}

long CVTcheck_process_tables ()
{
    char *fname="CVTcheck_processes_tables";
    int status,i,j,count;
static char *sql_str= "SELECT n_tablename, n_cvtstatus FROM nfmconvertlog \
WHERE n_tablename  in ('nfmprograms','nfmprocesses','nfmtransitions',\
'nfmtables','nfmsyscat')";
    char   **data;
    MEMptr buffer = NULL;


    _NFMdebug((fname,"Entry\n"));

/* Figure out if 
        nfmprograms
        nfmprocesses
        nfmtransitions
        nfmtables
        nfmsyscat
   are done 
   then and only then we convert the programs/processes
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
        return (status);
        }

    data = (char **) buffer->data_ptr;
    
    j = 0;
    for(i=0;i < buffer->rows; i++)
        {
        count = buffer->columns * i;
        _NFMdebug((fname,"Table <%s> : cvtstatus <%s>\n",data[count],data[count+1]));
             if ((strcmp (data[count],"nfmprograms") == 0 ) &&
                 (strcmp (data[count+1], "N") == 0)) j++;
        else if ((strcmp (data[count],"nfmprocesses") == 0 ) &&
                 (strcmp (data[count+1], "M") == 0)) j++;
        else if ((strcmp (data[count],"nfmtransitions") == 0 ) &&
                 ((strcmp (data[count+1], "M") == 0) ||
                  (strcmp (data[count+1], "C") == 0))) j++;
        else if ((strcmp (data[count],"nfmtables") == 0 ) &&
                 (strcmp (data[count+1], "M") == 0)) j++;
        else if ((strcmp (data[count],"nfmsyscat") == 0 ) &&
                 (strcmp (data[count+1], "N") == 0)) j++;
        else
        if(strcmp(data[count+1],"M") == 0 ) j++;
        else
            {
        _NFMdebug((fname,"Table <%s> : cvtstatus <%s> != <M>\n",data[count],data[count+1]));
        _NFMdebug((fname,
"<<<<ERROR>>>>Processes on Transition cannot be converted until \
system table <%s> is converted properly\n and n_cvtstatus is <M> in table \
<nfmconvertlog>: Current n_cvtstatus is <%s> \n",data[count],data[count+1]));
        fprintf(stderr,
"<<<<ERROR>>>>Processes on Transition cannot be converted until \
system table <%s> is converted properly\n and n_cvtstatus is <M> in table \
<nfmconvertlog>: Current n_cvtstatus is <%s> \n",data[count],data[count+1]);
 
            }    
        }

    MEMclose (&buffer);
    if (j==5) return(NFM_S_SUCCESS);
    else return(NFM_E_FAILURE);
}

long CVTprocesses ()
{
long status;
long cnt, i;
long CONTINUE = TRUE;
char sql_str[1024];
char programname[NFM_PROGRAMNAME+1];
char programdesc[NFM_PROGRAMDESC+1];
char itemnum[10];
char tablenum[10];
char program_file[100];
char **proc_ptr;
MEMptr process_buff = NULL;
long CVTmodify_program ();
static char *fname = "CVTprocesses";

_NFMdebug ((fname, "Enter.\n"));

sprintf (sql_str, "select %s from o_nfmtables where n_tablename = '%s'",
         "n_tableno", "nfmsyscat");
_NFMdebug ((fname, "SQLquery: <%s>\n", sql_str));
status = SQLquery (sql_str, &process_buff, 1024);
if (status != SQL_S_SUCCESS)
    {
    _NFMdebug ((fname, "SQLquery failure: <0x%.8x>\n", status));
    status = ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "");
    return (status);
    }

status = MEMbuild_array (process_buff);
if (status != MEM_S_SUCCESS)
    {
    _NFMdebug ((fname, "MEMbuild_array failure: <0x%.8x>\n", status));
    status = ERRload_struct (NFM, NFM_E_MEM, "", "");
    return (status);
    }

proc_ptr = (char **) process_buff->data_ptr;
strcpy (tablenum, proc_ptr[0]);
_NFMdebug ((fname, "n_tableno: <%s>\n", tablenum));

MEMclose (&process_buff);
sql_str[0] = 0;

sprintf (sql_str, "select %s from o_nfmprograms", 
         "n_programname, n_programdesc, n_itemno");
_NFMdebug ((fname, "SQLquery: <%s>\n", sql_str));
status = SQLquery (sql_str, &process_buff, 1024);
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
        _NFMdebug ((fname, "SQLquery: No programs found: <0x%.8x>\n",
                    status));
        return (NFM_S_SUCCESS);
        }
    }

status = MEMbuild_array (process_buff);
if (status != MEM_S_SUCCESS)
    {
    _NFMdebug ((fname, "MEMbuild_array failure: <0x%.8x>\n", status));
    status = ERRload_struct (NFM, NFM_E_MEM, "", "");
    return (status);
    }

proc_ptr = (char **) process_buff->data_ptr;

/* for each program, convert the data */
for (i=0; i<process_buff->rows; ++i)
    {
    CONTINUE = TRUE;
    programname[0] = 0;
    programdesc[0] = 0;
    itemnum[0] = 0;
    cnt = i * process_buff->columns;
    strcpy (programname, proc_ptr[cnt]);
    strcpy (programdesc, proc_ptr[cnt+1]);
    strcpy (itemnum, proc_ptr[cnt+2]);
    _NFMdebug ((fname, "\nprogramname: <%s>\n", programname));
    _NFMdebug ((fname, "programdesc:   <%s>\n", programdesc));
    _NFMdebug ((fname, "itemnum:       <%s>\n", itemnum));

    _NFMdebug ((fname, "\nConverting program <%s>...\n", programname));
    fprintf (stderr, "\nConverting program <%s>...\n", programname);

    /* find OLD program filename */
    status = CVTget_report_name ((atoi (tablenum)), (atoi (itemnum)),
                                  program_file);
    if (status != NFM_S_SUCCESS)
        {
        _NFMdebug ((fname, "CVTget_report_name failure: <0x%.8x>\n", status));
        fprintf (stderr, "CVTget_report_name failure: <0x%.8x>\n", status);
        CONTINUE = FALSE;
        }

    if (CONTINUE)
        {
        /* move old file to new file */

        strcat (programdesc, ": 3.0");
        _NFMdebug ((fname, "Modifying program entry...\n"));
        fprintf (stderr, "Modifying program entry...\n");
        status = CVTmodify_program (programname, programdesc, program_file,
                                itemnum);
        if (status != NFM_S_SUCCESS)
            {
            _NFMdebug ((fname, "CVTmodify_program failure: <0x%.8x>\n", status));
            fprintf (stderr, "CVTmodify_program failure: <0x%.8x>\n", status);
            CONTINUE = FALSE;
            }
        }

    if (CONTINUE)
        {
        _NFMdebug ((fname, "Done converting <%s>.\n", programname));
        fprintf (stderr, "Done converting <%s>.\n", programname);
        }
    }

MEMclose (&process_buff);

return (NFM_S_SUCCESS);
}

long CVTmodify_program (program_name, program_desc, old_prog_file, 
                        old_prog_num)
    char  *program_name;   /* I - Name of program. */
    char  *program_desc;   /* I - Description of the program. */
    char  *old_prog_file;  /* I - Old Program file name. */
    char  *old_prog_num;   /* I - Old Program number. */

{
    long   status;
    long   ret_size;
    long   program_no;
    FILE   *fopen(), *out_file;
    char   sql_str[256];
    char message[256];
    char   new_path [NFM_PATHNAME+1];
    char   new_prog_file[NFM_PROGRAMFILE+1];
    char   destfile[NFM_PATHNAME+NFM_PROGRAMFILE+2]; /* destination filename  */
    char   **s_data;
    MEMptr sql_buffer = NULL;
    static char *fname = "CVTmodify_program";

    _NFMdebug ((fname, "program_name: <%s>; program_desc: <%s>; old_prog_file: <%s>\n",
                program_name, program_desc, old_prog_file));

    /* Find the pathname for the new SYSTEM storage area. */

    sprintf (sql_str, "SELECT n_pathname from %s where n_saname = '%s'",
             "NFMSTORAGEAREA", "SYSTEM");
    status = SQLquery (sql_str, &sql_buffer, 256);
    if (status != SQL_S_SUCCESS)
        {
        MEMclose (&sql_buffer);
        status = NFM_E_SQL_QUERY;
        ERRload_struct (NFM, status, "", "") ;
        return (status);
        }

    status = MEMbuild_array (sql_buffer);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&sql_buffer);
        _NFMdebug ((fname, "MEMbuild_array = <0x%.8x>\n", status)); 
        status = NFM_E_MEM;
        ERRload_struct (NFM, status, "", "") ;
        return (status);
        }

    s_data = (char **) sql_buffer->data_ptr;
    strcpy (new_path, s_data[0]);

    MEMclose (&sql_buffer);

     status = NFMstop_transaction (0) ;
     if (status != NFM_S_SUCCESS) 
         {
         _NFMdebug ((fname, "NFMstop_transaction : <0x%.8x>\n", status));
         return (status) ;
         }

     status = NFMget_serial_slot (0, "nfmprograms", "n_programno", 
                                  &program_no);
     if (status != NFM_S_SUCCESS)
         {
         _NFMdebug ((fname, "Get Serial No : status = <0x%.8x>\n", status));
         return (status);
         }

     status = NFMgen_query_file_name ("nfmprograms", program_no, new_prog_file);
     if (status != NFM_S_SUCCESS)
         {
         NFMrollback_transaction (0) ;
         _NFMdebug ((fname, "Get Query Filename : status = <0x%.8x>\n", status));
         ERRload_struct (NFM, status, "", "") ;
         return (status);
         }

     sprintf (sql_str, "INSERT INTO NFMPROGRAMS (n_programno, n_programname, \
n_programdesc, n_programfile) VALUES (%d, '%s', '%s', '%s')",
              program_no, program_name, program_desc, new_prog_file);

     _NFMdebug ((fname, "sql_str: <%s>\n", sql_str));

     status = SQLstmt (sql_str);
     if (status != SQL_S_SUCCESS)
         {
         NFMrollback_transaction (0) ;
         _NFMdebug ((fname, "SQL Stmt Syntax : status = <0x%.8x>\n", status));
         ERRload_struct (NFM, NFM_E_SQL_STMT, "", "") ;
         return (NFM_E_SQL_STMT);
         }

     sprintf (sql_str, "UPDATE NFMPROCESSES SET n_programno = %d WHERE \
n_programno = %s", program_no, old_prog_num);

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

     status = NFMstart_transaction(0);
     if (status != NFM_S_SUCCESS)
         {
         NFMrollback_transaction(0);
         _NFMdebug ((fname, "Commit Work : status = <0x%.8x>\n", status));
         ERRload_struct (NFM, status, "", "") ;
         return (status);
         }

     _NFMdebug ((fname, "SUCCESSFUL : status = <0x%.8x>\n", NFM_S_SUCCESS));

    /* move old_path/old_prog_file to new_path/new_prog_file */

    sprintf (destfile, "%s/%s", new_path, new_prog_file);
    _NFMdebug ((fname, "%s -> %s\n", old_prog_file, destfile));

    status = NFMcopy_file (old_prog_file, destfile, "", &ret_size, 0);
    if (status != NFM_S_SUCCESS)
        {
        _NFMdebug ((fname, "NFMcopy_file : status = <0x%.8x>\n", status));
        status = ERRload_struct (NFM, status, "", "");
        return (status);
        }

/* KT - 7/15/92 change ownership
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

    if ((out_file = fopen ("./CVTprocess.log", "a")) == 0)
        {
        _NFMdebug ((fname, "Fopen Failed CVT log file.\n"));
        status = ERRload_struct (NFM, NFM_E_FAILURE, "", "");
        return (NFM_E_FAILURE);
        }
    fprintf (out_file, "\nConverting Program <%s>:\n", program_name);
    fprintf (out_file, "    program file: <%s> -> <%s>\n", old_prog_file,
             destfile);
    fclose (out_file);

    _NFMdebug ((fname, "SUCCESSFULL status = <0x%.8x>\n", NFM_S_SUCCESS));
    return (NFM_S_SUCCESS);
} 

