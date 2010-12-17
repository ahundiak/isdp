/* $Revision: 1.7 $ */
/*
Description:  A copy of this process is started for each client that connects. 
              This is accomplished by using inetd. A port number of 764 is 
              assigned to this process in /etc/services and is associated with 
              the name dbasrv. When a client tries to connect to port number 
              764, that is translated to dbasrv and then the inetd.conf file 
              is consulted to find the name of the executable file on disk.

Author: T. F. Ezell
Date: 06-Jun-1992
*/

#include "machine.h"
#include "NFMRinclude.h"
#include "MEMstruct.h"

#include <stdio.h>
#include <varargs.h>
#include <time.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <signal.h>
#include "dba.ext"
#include "dbasrv.h"
#include "rislimit.h"

#if defined RIS4
#include "sql.h"
#elif defined RIS5
#include "ris.h"
#else
#include "sql.h"
#include "RISerror.h"
#endif

/*
	Global log file pointer and request counter
*/
FILE *dba_log = (void *)0;
int dba_request_count = 0;
int dba_no_user_load;
int dba_net_buffer_size=DBA_NET_BUFFER_SIZE;
/*
	Global sqlda and sqlvars
*/
sqlda dba_srv_desc;
sqlvar *dba_srv_sqlvars = (void *)0;
int dba_srv_num_vars = 0;
/* Added __ Rajesh -- 30TH Aug., 1995 */
static struct timeval timeout;
/* END */

/* Function: main       DB Access Server */

main(argc, argv)
int argc;
char **argv;
{
             time_t current_time;
             char *time_string;
             fd_set fdvar;

    char net_buffer[DBA_NET_BUFFER_SIZE], *ptr, *string, 
        *err, c_name[35], logfile[30], text[200];
    short num_rows = 0, cursor;
    int done = 0, nb_read, nb_data, i, status, offset, start_offset, sqln=0,
        nfm_status, write_count, first, row_size = 0, tot_read;

     /* Added -- 1st Sept., 1995 -- Rajesh */
     /* START */
     int time_out;
     /* END  */

    long *rcode, *wcnt, lcnt;
    void dba_srv_crash();

/* OV - IGI-320. */
    int toggles[NFM_DEBUG_SUBSYSTEMS];
    char files[NFM_DEBUG_SUBSYSTEMS][NFM_DEBUG_FILE_SIZE] ;
/* END OV - IGI-320. */

    if (argc > 1) {
      if (strcmp (argv[1], "PID") == 0) {
        sprintf (logfile, "/usr/tmp/dbasrv%d", getpid());
        dba_log = fopen(logfile, "w");
        if (!dba_log) goto nolog;
      }
      else if (strcmp (argv[1], "NONE") == 0) ;
      else {
        strcpy (logfile, argv[1]);
        dba_log = fopen(logfile, "w");
        if (!dba_log) goto nolog;
      }
    }
    if (argc > 2 && strcmp (argv[2], "NO_USER_LOAD") == 0)
      dba_no_user_load = 1;
    if (argc > 3)
      sscanf (argv[3], "%d", &dba_net_buffer_size);
    
    if (dba_log) {
	 fprintf(dba_log, "DBAserver\n\n");
	 fflush(dba_log);
    }

/* ADDED -- 1st Sept., 1995 */
    if (argc > 4)
      sscanf(argv[4], "%d", &time_out);
    else
      time_out = 10;    /* In Minutes */
/* END */

    sigset (SIGBUS, dba_srv_crash);
    sigset (SIGEMT, dba_srv_crash);
    sigset (SIGSEGV, dba_srv_crash);
    sigset (SIGILL, dba_srv_crash);

/* OV - IGI-320. */
        for (i = 0; i < NFM_DEBUG_SUBSYSTEMS; ++i)
        {
            toggles[i] = 0;
            files[i][0] = '\0';
        }
        toggles[2] = 1;
        toggles[3] = 1;
        toggles[5] = 1;
        strcpy(files[2], "/usr/tmp/debug32.dat");
        strcpy(files[3], "/usr/tmp/debug33.dat");
        strcpy(files[5], "/usr/tmp/debug35.dat");
        status = NFMRclient_debug ( toggles, files );
/* END OV - IGI-320. */

    ptr = net_buffer;
    wcnt = (long *)ptr;
    offset = sizeof(long);
    ptr += offset;
    rcode = (long *)ptr;

        FD_SET(0, &fdvar);
        timeout.tv_sec = time_out * 60; /* time_out in Minutes converted to Seco
nds */
        timeout.tv_usec = 0;    /* Microseconds */

    while (!done)
    {
             time(&current_time);
             time_string=ctime(&current_time);
             fprintf(dba_log, "TIME BEFORE READ :: %s.\n",time_string);
             fflush(dba_log);

        ptr = net_buffer;

        status = 0;
        status = select(1, &fdvar, (fd_set *) 0, (fd_set *) 0, &timeout);

        /* IF Status  < 0, Select has Failed, 0 for TIMEDOUT, 1 for SUCCESS */
                if (status < 1)
                {
                        time(&current_time);
                        time_string=ctime(&current_time);
                        fprintf(dba_log, "\n\nSELECT Failed :: STATUS :: %d\n",
status);
                        fflush(dba_log);
                        fprintf(dba_log, "SELECT Failed :: TIME   :: %s\n", time_string);
                        fflush(dba_log);
                        goto exit_dbasrv;
                }

        nb_read = read(0, ptr, sizeof (long));

             time(&current_time);
             time_string=ctime(&current_time);
             fprintf(dba_log, "TIME AFTER READ :: %s.\n",time_string);
             fflush(dba_log);

        tot_read = nb_read;
        if (nb_read <= 0) {
          if (dba_log) {
              fprintf (dba_log, "\nread returned zero\n");
              fprintf (dba_log, "\nConnection Lost\n");
              fprintf (dba_log, "\nExiting\n");
              fflush (dba_log);
              goto exit_dbasrv;
          }
        }
        dba_int_swap_bytes (wcnt);
        if (dba_log) {
          fprintf (dba_log, "Initial read... read %d of %d\n", nb_read, *wcnt);
          fflush (dba_log);
        }
        ptr += nb_read;
        while (tot_read < *wcnt) {
          nb_read = read(0, ptr, DBA_NET_BUFFER_SIZE);
          if (nb_read <= 0) {
              if (dba_log) {
                  fprintf (dba_log, "\nread returned zero\n");
                  fprintf (dba_log, "\nConnection Lost\n");
                  fprintf (dba_log, "\nExiting\n");
                  fflush (dba_log);
                  goto exit_dbasrv;
              }
          }
          tot_read += nb_read;
          ptr += nb_read;
          if (dba_log) {
            fprintf (dba_log, "Loop... read %d of %d\n", nb_read, *wcnt);
            fflush (dba_log);
          }
        }
        ptr = net_buffer;
        nb_read = tot_read;
        dba_int_swap_bytes (rcode);
        if (nb_read) 
        {
            ++dba_request_count;
	    if (dba_log) {
              fprintf(dba_log, 
                "||----------- Request %d ----------||\n", dba_request_count);
	      fprintf(dba_log, "Bytes Read is %d\n", nb_read);
              fflush(dba_log);	    
	      fprintf(dba_log, "Byte Count is %ld\n", *wcnt);
              fflush(dba_log);
	      fprintf(dba_log, "Request Code is %ld\n", *rcode);
              fflush(dba_log);
            }
        }
        switch(*rcode) {
            case DBA_SERVER_EXIT:
	    
              ptr = net_buffer;
              offset = sizeof(long) * 2;
              string = ptr + offset;
              if (dba_log) {
                fprintf(dba_log,"DB Access Server Exiting\n");
                fflush(dba_log);
              }
	      strcpy(string, "DBAccess Server Exiting");
              *rcode = DBA_NET_SUCCESS;
              *wcnt = offset + strlen(string) + 1;
              done = 1;
              break;

            case DBA_SQL_STATEMENT:
	    
              if (dba_log) fprintf(dba_log,"DBA_SQL_STATEMENT\n");
              ptr = net_buffer;
              offset = sizeof(long) * 2;
              string = ptr + offset;
              if (dba_log) {
                fprintf(dba_log,"  \"%s\"\n", string);
                fflush(dba_log);
              }
              status = dba_srv_sql_statement(string);
              *rcode = status;
              *wcnt = offset;
              break;
	      
            case DBA_SQL_REPORT_ERROR:
	    
              if (dba_log) fprintf(dba_log,"DBA_SQL_REPORT_ERROR\n");
              ptr = net_buffer;
              offset = sizeof(long) * 2;
              string = ptr + offset;
              status = dba_srv_sql_report_error(&err);
	      if (strlen(err) > (DBA_NET_BUFFER_SIZE - offset - 1))
              {
	          strcpy(string, "Buffer Overflow");
	      }
              else
              {
                  strcpy(string, err);
              }
              *rcode = status;
              *wcnt = offset + strlen(string) + 1;
              break;

            case DBA_SQL_PREPARE:

              if (dba_log) fprintf(dba_log,"DBA_SQL_PREPARE\n");
	      
              ptr = net_buffer;
              offset = sizeof(long) * 2;
	      memcpy(&cursor, ptr + offset, 
                     sizeof(short));
              dba_short_swap_bytes (&cursor);
              if (dba_log) fprintf(dba_log, "cursor = %d\n", cursor);
	      offset += sizeof(short);
              string = ptr + offset;
              if (dba_log) fprintf(dba_log,"  \"%s\"\n", string);
              status = dba_srv_sql_prepare(cursor, string);
              if (dba_log) {
                fprintf(dba_log,"return code = %d\n", status);
                fflush(dba_log);
              }
              *wcnt = (sizeof(long) * 2);
              *rcode = status;
              break;
	      
            case DBA_SQL_DESCRIBE:
	    
              if (dba_log) fprintf(dba_log,"DBA_SQL_DESCRIBE\n");
              ptr = net_buffer;
              offset = sizeof(long) * 2;	      
/*
	Get the cursor number
*/
	      memcpy(&cursor, ptr + offset, sizeof(short));
              dba_short_swap_bytes (&cursor);
              if (dba_log) fprintf(dba_log, "cursor = %d\n", cursor);
	      offset += sizeof(short);
/*
	Get the incoming sqlda
*/
              memcpy(&dba_srv_desc, ptr + offset, sizeof(sqlda));
              offset += sizeof(sqlda);
              dba_short_swap_bytes (&dba_srv_desc.sqln);
              dba_short_swap_bytes (&dba_srv_desc.sqld);
/*
	Check to see if we have enough sqlvars to handle it
*/
              dba_srv_check_var_count();
              dba_srv_desc.sqlvar = (sqlvar *)dba_srv_sqlvars;
/*
	Do the SQL describe and load the return code in the nework buffer
*/
              if (dba_log) {
                fprintf(dba_log, "before sqln = %d\n", dba_srv_desc.sqln);
                fprintf(dba_log, "before sqld = %d\n", dba_srv_desc.sqld);
		fflush(dba_log);
              }
              status = dba_srv_sql_describe(cursor, &dba_srv_desc);
              *rcode = status;
              if (dba_log) {
                fprintf(dba_log, "after sqln = %d\n", dba_srv_desc.sqln);
                fprintf(dba_log, "after sqld = %d\n", dba_srv_desc.sqld);
		fflush(dba_log);
              }
/*
	Now load the sqlda back into the net buffer for return
*/
              sqln = dba_srv_desc.sqln;
              dba_short_swap_bytes (&dba_srv_desc.sqln);
              dba_short_swap_bytes (&dba_srv_desc.sqld);
              offset = (sizeof(long) * 2) + sizeof(short);
              memcpy(ptr + offset, &dba_srv_desc, sizeof(sqlda));
/*
	Now load all the sqlvars into the net buffer to be returned
*/

	      for (i = 0; i < sqln; ++i) {
                if (dba_log) {
                  strncpy(c_name, dba_srv_sqlvars[i].sqlname.sqlnamec, 
                    dba_srv_sqlvars[i].sqlname.sqlnamel);
                  c_name[dba_srv_sqlvars[i].sqlname.sqlnamel] = '\0';
                  fprintf(dba_log, "sqlname = %s\n", c_name);
                  fprintf(dba_log, "sqltype = %d\n", 
                    dba_srv_sqlvars[i].sqltype);
                  fprintf(dba_log, "sqllen = %d\n", 
                    dba_srv_sqlvars[i].sqllen);
		fflush(dba_log);
                }
                dba_short_swap_bytes (&dba_srv_sqlvars[i].sqltype);
                dba_short_swap_bytes (&dba_srv_sqlvars[i].sqlnull);
                dba_short_swap_bytes (&dba_srv_sqlvars[i].sqllen);
                dba_short_swap_bytes (&dba_srv_sqlvars[i].sqlscale);
                dba_short_swap_bytes (&dba_srv_sqlvars[i].sqlname.sqlnamel);
              }
              if (dba_log) fflush(dba_log);

              offset += sizeof(sqlda);
              memcpy(ptr + offset, (char *)dba_srv_sqlvars, 
                             sizeof(sqlvar) * sqln);
              offset += sizeof(sqlvar) * sqln;
              *wcnt = offset;

              break;
	      
            case DBA_SQL_DECLARE:
	    
              if (dba_log) fprintf(dba_log,"DBA_SQL_DECLARE\n");
              ptr = net_buffer;
              offset = sizeof(long) * 2;	      
	      memcpy(&cursor, ptr + offset, 
                       sizeof(short));
              dba_short_swap_bytes (&cursor);
              if (dba_log) {
                fprintf(dba_log, "cursor = %d\n", cursor);
                fflush(dba_log);
              }
              status = dba_srv_sql_declare(cursor);
              *rcode = status;	      
              *wcnt = sizeof(long) * 2;
              break;
	      
            case DBA_SQL_OPEN:
	    
              if (dba_log) fprintf(dba_log,"DBA_SQL_OPEN\n");
              ptr = net_buffer;
              offset = sizeof(long) * 2;	      
	      memcpy(&cursor, ptr + offset, sizeof(short));
              dba_short_swap_bytes (&cursor);
              if (dba_log) fprintf(dba_log, "cursor = %d\n", cursor);
              status = dba_srv_sql_open(cursor);
              if (dba_log) {
                fprintf(dba_log, "status = %d\n", status);
                fflush(dba_log);
              }
              *rcode = status;
              *wcnt = (sizeof(long) * 2);
              break;

	    case DBA_SQL_FETCH:
	    
              if (dba_log) {
                fprintf(dba_log, "DBA_SQL_FETCH\n");
                fflush(dba_log);
              }
/*
	Setup the pointer to the start of the buffer and offset to point
        just past the request code
*/
              ptr = net_buffer;
              offset = sizeof(long) * 2;	      
/*
	Get the cursor number
*/
	      memcpy(&cursor, ptr + offset, sizeof(short));
              dba_short_swap_bytes (&cursor);
              if (dba_log) fprintf(dba_log, "cursor = %d\n", cursor);
	      offset += sizeof(short);	      
/*
	Get the incoming sqlda structure
*/
              if (dba_log) {
                fprintf(dba_log, "Get the incoming sqlda\n");
                fflush(dba_log);
              }
              memcpy(&dba_srv_desc, ptr + offset, sizeof(sqlda));
              offset += sizeof(sqlda);

              dba_short_swap_bytes (&dba_srv_desc.sqln);
              dba_short_swap_bytes (&dba_srv_desc.sqld);

	      if (dba_log) {
                fprintf(dba_log, "sqld = %d\n", dba_srv_desc.sqld);
	        fprintf(dba_log, "sqln = %d\n", dba_srv_desc.sqln);
              }
/*
		See if we have enough sqlvars allocated
*/
              if (dba_log) {
                fprintf(dba_log, "Check for sqlvars\n");
                fflush(dba_log);
              }
              dba_srv_check_var_count();
/*
	Load the incoming sqlvar information
*/
              dba_srv_desc.sqlvar = (sqlvar *)dba_srv_sqlvars;	
              memcpy(dba_srv_sqlvars, ptr + offset, 
                         sizeof(sqlvar) * dba_srv_desc.sqln);
	      offset += sizeof(sqlvar) * dba_srv_desc.sqln;
              if (dba_log) 
                fprintf(dba_log, "offset after incoming sqlvar = %d\n", offset);
/*
	Setup the sqlvars with pointers to the network buffer and
        let the sql fetch put the data directly in there
*/
              nb_data = 0;
              start_offset = offset;	      
              if (dba_log) 
                fprintf(dba_log, "start offset  = %d\n", start_offset);

              status = RIS_SUCCESS;
              first = 1;
              num_rows = 0;

#if defined sol
              for (i = 0; i < dba_srv_desc.sqln; ++i) {
                dba_short_swap_bytes (&dba_srv_sqlvars[i].sqltype);
                dba_short_swap_bytes (&dba_srv_sqlvars[i].sqlnull);
                dba_short_swap_bytes (&dba_srv_sqlvars[i].sqllen);
                dba_short_swap_bytes (&dba_srv_sqlvars[i].sqlscale);
                dba_short_swap_bytes (&dba_srv_sqlvars[i].sqlname.sqlnamel);
              }
#endif

              while (first || status == RIS_SUCCESS &&
                  offset + row_size < dba_net_buffer_size) {
                for (i = 0; i < dba_srv_desc.sqln; ++i) {
/*
	The buffer pointer is already aligned on an 8 byte boundary because it
        came from malloc. Now be sure the offset is aligned appropriately for
        each data type.
*/
                  ALIGN_OFFSET(offset, dba_srv_sqlvars[i].sqltype, 
                                     dba_srv_sqlvars[i].sqllen);
	          dba_srv_sqlvars[i].sqldata = ptr + offset;
                  offset += dba_srv_sqlvars[i].sqllen;
/*
	Load the sqlind data into the network buffer directly following 
        the column data.
*/
                  ALIGN_OFFSET(offset, INTEGER, sizeof(long));
	          dba_srv_sqlvars[i].sqlind = (long *)(ptr + offset);
                  offset += sizeof(long);
                }
/*
	Force the offset back to 8 byte boundary for next row
*/
                ALIGN_OFFSET(offset, DOUBLE, sizeof(double));
                if (first) {
                  first = 0;
                  row_size = offset - start_offset;
                }
                if (dba_log) fprintf(dba_log, "offset = %d\n", offset);
/*
	Perform the sql fetch and load the return code in the network buffer
*/
                if (dba_log) fprintf(dba_log, "Do the RIS fetch\n");
                status = dba_srv_sql_fetch(cursor, &dba_srv_desc);
                if (dba_log) {
                  fprintf(dba_log, "Fetch status = %d\n", status);
                  fflush(dba_log);
                }
                *rcode = status;
                if (status == RIS_SUCCESS)
                  num_rows++;
#if defined sol
                for (i = 0; i < dba_srv_desc.sqln; ++i) {
                  dba_int_swap_bytes (dba_srv_desc.sqlvar[i].sqlind);
		  switch(dba_srv_desc.sqlvar[i].sqltype) {
		    case INTEGER:
                      dba_int_swap_bytes (dba_srv_desc.sqlvar[i].sqldata);
                      break;
		    case DOUBLE:
                      dba_double_swap_bytes (dba_srv_desc.sqlvar[i].sqldata);
                      break;
		  }
                }
#endif
              }
              nb_data += offset - start_offset;
              if (dba_log) fprintf(dba_log, "nb_data  = %d\n", nb_data);
/*
	Now load up the sqlda and the sqlvar information to go back
        the data itself is already where it belongs.
*/	      
              if (dba_log) fprintf(dba_log, "num_rows = %d\n", num_rows);
              dba_short_swap_bytes (&num_rows);
              offset = sizeof(long) * 2;
              *(short *)(ptr + offset) = num_rows;
              dba_short_swap_bytes (&dba_srv_desc.sqln);
              dba_short_swap_bytes (&dba_srv_desc.sqld);
              offset += sizeof(short);
              memcpy(ptr + offset, &dba_srv_desc, sizeof(sqlda));

              for (i = 0; i < sqln; ++i) {
                dba_short_swap_bytes (&dba_srv_sqlvars[i].sqltype);
                dba_short_swap_bytes (&dba_srv_sqlvars[i].sqlnull);
                dba_short_swap_bytes (&dba_srv_sqlvars[i].sqllen);
                dba_short_swap_bytes (&dba_srv_sqlvars[i].sqlscale);
                dba_short_swap_bytes (&dba_srv_sqlvars[i].sqlname.sqlnamel);
              }
              offset += sizeof(sqlda);
              memcpy(ptr + offset, (char *)dba_srv_sqlvars, 
                           sizeof(sqlvar) * sqln);
              offset += sizeof(sqlvar) * sqln;

              *wcnt = offset + nb_data;
              break;

            case DBA_SQL_CLOSE:

              if (dba_log) fprintf(dba_log,"DBA_SQL_CLOSE\n");
              ptr = net_buffer;
              offset = sizeof(long) * 2;	      
	      memcpy(&cursor, ptr + offset, sizeof(short));
              dba_short_swap_bytes (&cursor);
              if (dba_log) fprintf(dba_log, "cursor = %d\n", cursor);
              status = dba_srv_sql_close(cursor);
              *rcode = status;
              *wcnt = (sizeof(long) * 2);
              break;
	      
            case DBA_SQL_CLEAR:
	    
              if (dba_log) fprintf(dba_log,"DBA_SQL_CLEAR\n");
              ptr = net_buffer;
              offset = sizeof(long) * 2;	      
	      memcpy(&cursor, ptr + offset, 
                     sizeof(short));
              dba_short_swap_bytes (&cursor);
              if (dba_log) fprintf(dba_log, "cursor = %d\n", cursor);
              status = dba_srv_sql_clear(cursor);
              *rcode = status;
              *wcnt = sizeof(long) * 2;
              break;
	      
            default:
	    
              status = dba_nfm_calls(*rcode, net_buffer, 
                                      &write_count, &nfm_status);
              if (status)
              {
                  if (dba_log){
		      fprintf(dba_log,"Unknown Request Code : %ld\n", *rcode);
		      fflush(dba_log);
		  }
                  *rcode = DBA_NET_UNKNOWN_REQUEST;
                  *wcnt = sizeof(long) * 2;	      		  
              }
	      else
              {
	          *rcode = nfm_status;
                  *wcnt = write_count;
              }
              break;
        }
	if (dba_log) {
          fprintf(dba_log, "Write Count = %d\n", *wcnt);
          fprintf(dba_log, "Return Code = %d\n", *rcode);
	  fprintf(dba_log, "||--------- Finished Request %d----------||\n\n", 
                      dba_request_count);
          fflush(dba_log);
        }
        lcnt = *wcnt;
        dba_int_swap_bytes (wcnt);
        dba_int_swap_bytes (rcode);
        write(1, net_buffer, lcnt);
    }
    if (dba_log) {
      fprintf(dba_log,"\n.\n.\nDBASRV exiting....\n");
      fclose(dba_log);
    }
    goto exit_dbasrv;
nolog:
    sprintf (text, 
      "echo DBASRV failed to open log file \"%s\". > /dev/console", 
      logfile);
    system(text);
    system("echo exiting ... > /dev/console");
exit_dbasrv:
    RISterminate ();
    exit(0);
}
int dba_srv_check_var_count()
{
    if (dba_log)
        fprintf(dba_log, "dba_srv_num_vars = %d\n", dba_srv_num_vars);

    if (dba_srv_num_vars < dba_srv_desc.sqln)
    {
        if (!dba_srv_num_vars)
	{
	    if (dba_log) {
              fprintf(dba_log, "malloc space for the sqlvars\n");
	      fprintf(dba_log, "sqln = %d\n", dba_srv_desc.sqln);
            }
	    dba_srv_sqlvars = (sqlvar *) 
                      malloc(sizeof(sqlvar) * dba_srv_desc.sqln);
            dba_srv_num_vars = dba_srv_desc.sqln;
        }
        else
	{
	    if (dba_log) {
              fprintf(dba_log, "realloc space for the sqlvars\n");
	      fprintf(dba_log, "sqln = %d\n", dba_srv_desc.sqln);
	    }
            dba_srv_sqlvars = (sqlvar *) realloc(dba_srv_sqlvars, 
                                 sizeof(sqlvar) * dba_srv_desc.sqln);
            dba_srv_num_vars = dba_srv_desc.sqln;
        }
    }
    return(0);
}
/* Function:	dba_srv_crash */
void dba_srv_crash ()
{
    if (dba_log) {
      fprintf (dba_log, "\n.\n.\n.\nDBASRV fatal error.\n");
      fflush(dba_log);
    }
    if (!dba_log)
      system("echo DBASRV fatal error. > /dev/console");

    RISterminate ();
    exit(0);
}
