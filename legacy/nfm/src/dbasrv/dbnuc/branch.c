/* $Revision: 1.1 $ */
#include "dba.ext"
#include "keys.def"
#include "stdarg.h"

#if defined RIS4
#include "sql.h"
#include "ris_err.h"
#elif defined RIS5
#include "ris.h"
#include "ris_err.h"
#else
#include "RISint_err.h"
#include "RISapp_err.h"
#endif

/*
    The purpose of this set of functions is to decide whether to use
    the RIS connection directly to communicate with the database or
    divert the calls through a Server.
*/    
extern int dba_use_server_flag;

/*
    Function:	dba_select
*/

int dba_select (curs, in_desc, sqltxt)
int curs;
sqlda **in_desc;
char *sqltxt;
{
    int status;
#if defined __WIN32__
    int (*func)();
    
    func = dba_inq_service (DBA_SRV_SELECT);
    if (dba_use_server_flag && func)
      status = (*func) (curs, in_desc, sqltxt);
    else
#endif
      status = dba_ris_select(curs, in_desc, sqltxt);

    return(status);
}


/*
    function:   dba_fetch
    Author:     Tim A. Thompson
    Date:       8-4-94
*/

int dba_fetch (int curs, sqlda *in_desc, ...)
{
    va_list args;
    int status;
#if defined __WIN32__
    int (*func)();
#endif

    va_start (args, in_desc);
#if defined __WIN32__
    func = dba_inq_service (DBA_SRV_FETCH);
    if (dba_use_server_flag && func)
      status = (*func) (curs, in_desc, args);
    else
#endif
      status = dba_ris_fetch (curs, in_desc, args);
    va_end(args);

    return (status);
}

/*
    Function:	dba_close_cursor
*/

int dba_close_cursor (int curs)
{
    int status;
#if defined __WIN32__
    int (*func)();
    
    func = dba_inq_service (DBA_SRV_CLOSE_CURSOR);
    if (dba_use_server_flag && func)
      status = (*func) (curs);
    else
#endif
      status = dba_ris_close_cursor(curs);

    return (status);
}


/* 
    Function:    dba_sql 
*/

int dba_sql (sqlptr)
char *sqlptr;
{
    int status;
#if defined __WIN32__
    int (*func)();
    
    func = dba_inq_service (DBA_SRV_SQL);
    if (dba_use_server_flag && func)
      status = (*func) (sqlptr);
    else
#endif
      status = dba_ris_sql(sqlptr);

    return(status);
}


/*   Function:    dba_exec_sql */

int dba_exec_sql (char *sqlptr)
{
    int status;
#if defined __WIN32__
    int (*func)();
    
    func = dba_inq_service (DBA_SRV_EXEC_SQL);
    if (dba_use_server_flag && func)
      status = (*func) (sqlptr);
    else
#endif
      status = dba_ris_exec_sql(sqlptr);

    return(status);
}


/* Function:	dba_prepare_sql */

int dba_prepare_sql (sqlptr)
char *sqlptr;
{
    int status;
#if defined __WIN32__
    int (*func)();
    
    func = dba_inq_service (DBA_SRV_PREPARE_SQL);
    if (dba_use_server_flag && func)
      status = (*func) (sqlptr);
    else
#endif
      status = dba_ris_prepare_sql(sqlptr);

    return (status);
}


/* Function:	dba_report_ris_error */

int dba_report_ris_error (sqlptr)
char *sqlptr;
{
    int status;
#if defined __WIN32__
    int (*func)();
    
    func = dba_inq_service (DBA_SRV_REPORT_RIS_ERROR);
    if (dba_use_server_flag && func)
      status = (*func) (sqlptr);
    else
#endif
      status = dba_ris_report_ris_error (sqlptr);

    return (status);
}
