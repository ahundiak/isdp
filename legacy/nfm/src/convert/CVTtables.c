#include "machine.h"
#include "CVT.h"

extern struct CVTglobal_st CVTglobal;

/* 
 Doc: CVTcreate_cvtlog_tables
 
 Abstract:
     This function will create the tables used during the I/NFM datebase
     conversion.

     step 1. We don't want to create the tables if they have already been
             created. After a successful creation, I will input the 
             nfmconvertlog table with the tables just created.

             First query for the entries. If the tables have not been 
             created, the query will fail because the table doesn't exist!

     step 2. Create the tables: nfmconvertlog and nfmconvertindex.

     step 3. Create unique index on nfmconvertlog.n_tablename.

     step 4. Update the nfmconvertlog table.
     
 Returns:
       NFM_S_SUCCESS - Success
       Other         - Failure
         
 History:
     kht    3-11-1992    Creation
     
*/
 
long CVTcreate_cvtlog_tables ()

{
    long   status;
    long   CVTupdate_cvtlog ();
    long   CVTupdate_cvtindex ();
    char   date[40];
    char   sql_str[1024];
    MEMptr buffer = NULL;
    static char *fname = "CVTcreate_cvtlog_tables";

    _NFMdebug ((fname, "Enter.\n"));

/* See if tables exist by querying the nfmconvertlog table. If it fails,
   create the tables. */

    status = SQLquery ("SELECT * FROM nfmconvertlog WHERE n_tablename = \
'nfmconvertlog' OR n_tablename = 'nfmconvertindex'", &buffer, NULL);
    if (status == SQL_S_SUCCESS)
        {
        fprintf (stdout, "%s: Convert Tables Exist.\n", fname);
        MEMclose (&buffer);
        return (NFM_S_SUCCESS);
        }

    status = SQLstmt ("create table nfmconvertlog (n_tablename char(20) \
not null, n_cvtstatus char(1), n_date timestamp, n_lastrowdone integer)");
    if ((status != SQL_S_SUCCESS)  && (status != SQL_E_TABLE_EXISTS))
        {
        fprintf (stdout, "%s: Cannot create table <%s>.\n", fname, 
                 "nfmconvertlog");
        return (NFM_E_FAILURE);
        }

    if (status != SQL_E_TABLE_EXISTS)
      {
        status = SQLstmt ("create unique index cvttable on nfmconvertlog \
                           (n_tablename)");
        if (status != SQL_S_SUCCESS)
          {
            fprintf (stdout, "%s: Cannot create index on table <%s>.\n", fname, 
                     "nfmconvertindex");
            return (NFM_E_FAILURE);
          }
      }
/***********
    status = SQLstmt ("create table nfmconvertindex (n_column char(41), \
n_oldvalue integer, n_newvalue integer)");
    if ((status != SQL_S_SUCCESS) && (status != SQL_E_TABLE_EXISTS))
        {
        fprintf (stdout, "%s: Cannot create table <%s>.\n", fname, 
                 "nfmconvertindex");
        return (NFM_E_FAILURE);
        }
***************/
    /* Find current date/time */
    status = NFMget_RISdatetime (date);
    if (status != NFM_S_SUCCESS)
        {
        fprintf (stdout, "%s: NFMget_RISdatetime <0x%.8x>.\n", fname);
        return (status);
        }

    sprintf (sql_str, "INSERT INTO nfmconvertlog (n_tablename, \
n_cvtstatus, n_date, n_lastrowdone) VALUES ('nfmconvertlog', 'C', \
TIMESTAMP '%s', 0)", date);
    status = SQLstmt (sql_str);
    if (status != SQL_S_SUCCESS)
        {
        fprintf (stdout, "%s: SQLstmt <0x%.8x>.\n", fname);
        fprintf (stdout, "%s: Cannot update nfmconvertlog.\n", fname);
        return (NFM_E_FAILURE);
        }
/***********
    sprintf (sql_str, "INSERT INTO nfmconvertlog (n_tablename, \
n_cvtstatus, n_date, n_lastrowdone) VALUES ('nfmconvertindex', 'C', \
TIMESTAMP '%s', 0)", date);
    status = SQLstmt (sql_str);
    if (status != SQL_S_SUCCESS)
        {
        fprintf (stdout, "%s: SQLstmt <0x%.8x>.\n", fname);
        fprintf (stdout, "%s: Cannot update nfmconvertlog.\n", fname);
        return (NFM_E_FAILURE);
        }
*************/
    _NFMdebug ((fname, "Returning NFM_S_SUCCESS.\n"));
    return (NFM_S_SUCCESS);
} 

/* 
 Doc: CVTupdate_cvtlog
 
 Abstract:
     This function will update the nfmconvertlog table with the given
     table name, status_flag and last row done.

     If status_flag = B, the convert on this table is just beginning.
     If status_flag = E, an error or interrupt has occured during the 
                         conversion of this table. The last row updated
                         will input to n_lastrowdone.
     If status_flag = U, the old table has been unloaded.
     If status_flag = D, the old table has been dropped.
     If status_flag = R, the old table has been renamed in the dump file.
     if status_flag = T, the old table is loaded
     If status_flag = N, the new table has been created from the template.
     If status_flag = M, the new table has been loaded with data from the
                         old table.
     If status_flag = C, the table has been converted successfully.
     If status_flag = I, an error occurred creating an index.
	 If status_flag = A, an error occured during resolving file 
						 attributes.
     If status_flag = K, an error occured during dropping old catalog
						 and old f_catalog.
     If status_flag = L, an error occured during update to f_catalog 
                                                 (n_convertind)
     If status_flag = Y, an insert statement has been written to the
						 CVTbad_in.ris file.

 Returns:
       NFM_S_SUCCESS - Success
       Other         - Failure
         
 History:
     kht    3-11-1992    Creation
     
*/
 
long CVTupdate_cvtlog (table_name, status_flag, last_row)
    char *table_name;    /* i - the table being converted */
    char *status_flag;   /* i - B - beginning convert; not yet complete;
                                E - error or interrupt during conversion;
                                U - the old table has been unloaded;
                                D - the old table has been dropped;
                                R - the old table has been renamed in the 
                                    dump file;
                                T - the old table is loaded
                                N - the new table has been created from the 
                                    template (no data).
                                M - the new table has been loaded with data 
                                    from the old table.
                                C - convert complete */
    int  last_row;       /* i - used only when status_flag = E */

{
    long   status;
    char   date[40];
    char   sql_str[1024];
    static char *fname = "CVTupdate_cvtlog";

    _NFMdebug ((fname, "Enter.\n"));
    _NFMdebug ((fname, "table <%s>; status_flag <%s>; last_row <%d>\n",
                table_name, status_flag, last_row));

    /* Find current date/time */
    status = NFMget_RISdatetime (date);
    if (status != NFM_S_SUCCESS)
        {
        fprintf (stdout, "%s: NFMget_RISdatetime <0x%.8x>.\n", fname);
        CVTcheck_nfm_stop_convert();
        return (status);
        }

    if ((strncmp (status_flag, "B", 1) != 0) &&
        (strncmp (status_flag, "E", 1) != 0) &&
        (strncmp (status_flag, "U", 1) != 0) &&
        (strncmp (status_flag, "D", 1) != 0) &&
        (strncmp (status_flag, "R", 1) != 0) &&
        (strncmp (status_flag, "T", 1) != 0) &&
        (strncmp (status_flag, "N", 1) != 0) &&
        (strncmp (status_flag, "M", 1) != 0) && 
        (strncmp (status_flag, "C", 1) != 0) &&
	(strncmp (status_flag, "I", 1) != 0) &&
	(strncmp (status_flag, "A", 1) != 0) &&
        (strncmp (status_flag, "K", 1) != 0) &&
        (strncmp (status_flag, "Z", 1) != 0) &&
		(strncmp (status_flag, "Y", 1) != 0) &&
	(strncmp (status_flag, "L", 1) != 0))
         {
         fprintf (stdout, "%s: Bad status_flag <%s>.\n", fname, 
                  status_flag);
         CVTcheck_nfm_stop_convert();
         return (NFM_E_FAILURE);
         }


    sprintf (sql_str, "UPDATE nfmconvertlog SET n_cvtstatus = '%s', \
n_date = TIMESTAMP '%s', n_lastrowdone = %d WHERE n_tablename = '%s'", 
             status_flag, date, last_row, table_name);
    status = SQLstmt (sql_str);
    if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
        {
        fprintf (stdout, "%s: SQLstmt <0x%.8x>.\n", fname);
        fprintf (stdout, "%s: Cannot update nfmconvertlog.\n", fname);
        CVTcheck_nfm_stop_convert();
        return (NFM_E_FAILURE);
        }

    if (status == SQL_I_NO_ROWS_FOUND)
        {
        sprintf (sql_str, "INSERT INTO nfmconvertlog (n_tablename, \
n_cvtstatus, n_date, n_lastrowdone) VALUES ('%s', '%s', TIMESTAMP '%s', 0)", 
                 table_name, status_flag, date);
        status = SQLstmt (sql_str);
        if (status != SQL_S_SUCCESS)
            {
            fprintf (stdout, "%s: SQLstmt <0x%.8x>.\n", fname);
            fprintf (stdout, "%s: Cannot update nfmconvertlog.\n", fname);
            CVTcheck_nfm_stop_convert();
            return (NFM_E_FAILURE);
            }
        }

    CVTcheck_nfm_stop_convert();
    _NFMdebug ((fname, "Returning NFM_S_SUCCESS.\n"));
    return (NFM_S_SUCCESS);
} 


/* 
 Doc: CVTupdate_cvtindex
 
 Abstract:
     This function will update the nfmconvertindex table with the given
     'tablename.columnname', old index value, and new index value.

     It will be used to store the "old to new" index mappings for those
     that change.
     ie. There have been several commands removed from the nfmcommands 
         table. The converter will resequence the reamining commands.
         If "Add Item" used to be command number 100, and with resequencing
         its new command number is 96, all references to command number
         100 in other tables (nfmtransitions), need to be changed to 96.

     Sample table entry:

     n_column                 n_oldvalue   n_newvalue

     nfmcommands.n_commandno     100           96

     
 Returns:
       NFM_S_SUCCESS - Success
       Other         - Failure
         
 History:
     kht    3-11-1992    Creation
     
*/
 
long CVTupdate_cvtindex (tabcolumn, oldvalue, newvalue)
    char *tabcolumn;    /* i - the table.column being mapped */
    int  oldvalue;      /* i - the old index value */
    int  newvalue;      /* i - the new index value */

{
    long   status;
    char   sql_str[1024];
    static char *fname = "CVTupdate_cvtindex";

    _NFMdebug ((fname, "Enter.\n"));
    _NFMdebug ((fname, "tabcolumn <%s>; oldvalue <%d>; newvalue <%d>\n",
                tabcolumn, oldvalue, newvalue));

    sprintf (sql_str, "INSERT INTO nfmconvertindex (n_column, n_oldvalue, \
n_newvalue) VALUES ('%s', %d, %d)", tabcolumn, oldvalue, newvalue);
    status = SQLstmt (sql_str);
    if (status != SQL_S_SUCCESS)
        {
        fprintf (stdout, "%s: SQLstmt <0x%.8x>.\n", fname);
        fprintf (stdout, "%s: Cannot update nfmconvertindex.\n", fname);
        return (NFM_E_FAILURE);
        }
       
    _NFMdebug ((fname, "Returning NFM_S_SUCCESS.\n"));
    return (NFM_S_SUCCESS);
} 


/* 
 Doc: CVTquery_cvtlog_entry
 
 Abstract:
     This function will query the nfmconvertlog table for the given
     table. The current conversion status of the table is returned.

 Returns:
       NFM_S_SUCCESS       - Success
       NFM_I_NO_ROWS_FOUND - No entry for the table
       Other               - Failure
         
 History:
     kht    3-11-1992    Creation
     
*/
 
long CVTquery_cvtlog_entry (table, status_flag, last_row)
    char *table;        /* i - the requested table */
    char *status_flag;  /* o - the convert status of the table */
    long  *last_row;     /* o - the value in n_lastrowdone */

{
    long   status;
    char   lastrow[10];
    char   sql_str[1024];
    char   **data_ptr;
    MEMptr buffer = NULL;
    static char *fname = "CVTquery_cvtlog_entry";

    _NFMdebug ((fname, "Enter.\n"));
    _NFMdebug ((fname, "table <%s>\n", table));

    sprintf (sql_str, "SELECT n_cvtstatus, n_lastrowdone FROM nfmconvertlog \
WHERE n_tablename = '%s'", table);
    status = SQLquery (sql_str, &buffer, NULL) ;
    if (status != SQL_S_SUCCESS)
      {
        if (status == SQL_I_NO_ROWS_FOUND)
          {
            _NFMdebug ((fname, "SUCCESSFUL - NO ROWS FOUND\n")) ;
            return (NFM_I_NO_ROWS_FOUND);
          }
    
        fprintf (stdout, "%s: SQLquery <0x%.8x>.\n", fname, status);
        MEMclose (&buffer);
        ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
        return (NFM_E_SQL_QUERY);
      }

    status = MEMbuild_array (buffer);
    if (status != MEM_S_SUCCESS)
      {
        fprintf (stdout, "%s: MEMbuild_array <0x%.8x>.\n", fname, status);
        MEMclose (&buffer);
        return (status);
      }
    data_ptr = (char **) buffer->data_ptr;
    strcpy (status_flag, data_ptr[0]);
    strcpy (lastrow, data_ptr[1]);
    *last_row = atol (lastrow);

    MEMclose (&buffer);

    _NFMdebug ((fname, "Returning NFM_S_SUCCESS.\n"));
    return (NFM_S_SUCCESS);
} 


/* 
 Doc: CVTprint_cvtlog
 
 Abstract:
     This function will print all nfmconvertlog table entries.

 Returns:
       NFM_S_SUCCESS       - Success
       Other               - Failure
         
 History:
     kht    3-11-1992    Creation
     
*/
 
long CVTprint_cvtlog ()

{
    long   status;
    int    i, j;
    char   sql_str[512];
    char   table[21] ;
    char   date[31];
    char   cvtstatus[10];
    char   **data_ptr;
    MEMptr buffer = NULL;
    static char *fname = "CVTprint_cvtlog";

    _NFMdebug ((fname, "Enter.\n"));

    strcpy (sql_str, "SELECT n_tablename, n_cvtstatus, n_date, n_lastrowdone \
FROM nfmconvertlog");
    status = SQLquery (sql_str, &buffer, NULL);
    if (status != SQL_S_SUCCESS)
      {
        if (status == SQL_I_NO_ROWS_FOUND)
          {
            _NFMdebug ((fname, "No rows found\n")) ;
            return (NFM_S_SUCCESS) ;
          }
        fprintf (stdout, "%s: SQLquery <0x%.8x>.\n", fname, status);
        MEMclose (&buffer);
        return (NFM_E_SQL_QUERY);
      }
    
    status = MEMbuild_array (buffer);
    if (status != MEM_S_SUCCESS)
      {
        fprintf (stdout, "%s: MEMbuild_array <0x%.8x>.\n", fname, status);
        MEMclose (&buffer);
        return (status);
      }
    data_ptr = (char **) buffer->data_ptr;

    fprintf (stdout, "\nConvert Log:\n\n");
    fprintf (stdout, "Table                 Status    Date\n");
    fprintf (stdout, "-----                 ------    ----\n");

    for (i=0; i<buffer->rows; ++i)
      {
        j = i * buffer->columns;
        sprintf (table, "%20-s", data_ptr[j]);
        sprintf (cvtstatus, "%6-s", data_ptr[j+1]);
        sprintf (date, "%30-s", data_ptr[j+2]);

        fprintf (stdout, "%s  %s    %s\n", table, cvtstatus, date);
      }

    status = MEMclose (&buffer);
    if (status != MEM_S_SUCCESS)
      {
        _NFMdebug ((fname, "MEMclose : status = <0x%.8x>\n",
                    status)) ;
        ERRload_struct (NFM, NFM_E_MEM, "", "") ;
        return (NFM_E_MEM) ;
      }

    fflush (stdout) ;

    _NFMdebug ((fname, "Returning NFM_S_SUCCESS.\n"));
    return (NFM_S_SUCCESS);
} 

CVTcheck_nfm_stop_convert()
{
    char *fname="CVTcheck_nfm_stop_convert";
    _NFMdebug((fname,"Entry\n"));
        if( CVTglobal.NFM_STOP_CONVERT == TRUE)
          {
            _NFMdebug((fname,"User requested to stop: Exiting. . .\n"));
            fprintf(stderr,"TERMINATION REQUEST RECEIVED :Exiting. . .\n");
            CVTlogout(1);
          }
    _NFMdebug((fname,"Exit: status <0x%.8x>\n",NFM_S_SUCCESS));
    return(NFM_S_SUCCESS);
}



