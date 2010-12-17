#include "ris.h"
static short RIScpp_stmt_id0 = -1;

#line 1 "r_exec.rc"
/* $Revision: 1.1 $ */
#include "dba.ext"
#include <stdio.h>

extern char *dba_errtxt;
extern int dba_error;

/* Function:	dba_ris_exec_sql

Description: This function passes the input string along to RIS.

Author: T. F. Ezell
Date: 10-Mar-90 */

int dba_ris_exec_sql(string)


#line 17 "r_exec.rc"

char * string;

#line 19 "r_exec.rc"


{

#line 22 "r_exec.rc"

{RISint_prepare(&RIScpp_stmt_id0,string,1,0);
if (RISget_sqlcode() != RIS_SUCCESS) goto sql_error;}

#line 23 "r_exec.rc"

{RISint_execute(&RIScpp_stmt_id0,0,0,7,1,0);
if (RISget_sqlcode() != RIS_SUCCESS && RISget_sqlcode() != END_OF_DATA) goto sql_error;}

#line 24 "r_exec.rc"

    return(0);

sql_error:
    return(99);
}
