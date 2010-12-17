#include "ris.h"
static short RIScpp_stmt_id0 = -1;
static short RIScpp_stmt_id1 = -1;
static short RIScpp_stmt_id2 = -1;
static short RIScpp_stmt_id3 = -1;
static short RIScpp_stmt_id4 = -1;
static short RIScpp_stmt_id5 = -1;
static short RIScpp_stmt_id6 = -1;
static short RIScpp_stmt_id7 = -1;
static short RIScpp_stmt_id8 = -1;
static short RIScpp_stmt_id9 = -1;
static short RIScpp_stmt_id10 = -1;
static short RIScpp_stmt_id11 = -1;

#line 1 "srv_util.rc"
/* $Revision: 1.1 $ */
/*
Function: DBAccess Server Process RIS Utilities

Description: These functions are called by the DB Access Server to perform
             the sql statements and queries needed by the Client.

Author: T. F. Ezell
Date: 24-Aug-1992
*/
#include <stdio.h>
#include "dba.ext"
#include "dbasrv.h"

extern FILE *dba_log;

/* Function: dba_srv_sql_statement */

int dba_srv_sql_statement(sql_statement)

#line 20 "srv_util.rc"

char * sql_statement;

#line 22 "srv_util.rc"

{
    int length;
    length = strlen(sql_statement);
    if (dba_log) fprintf(dba_log, "dba_srv_execute_sql: %s\n", sql_statement);
    if (dba_log) fprintf(dba_log, "length of sql statement = %d\n", length);    
{RISint_prepare(&RIScpp_stmt_id0,sql_statement,1,0);
}

#line 28 "srv_util.rc"

    if (SQLCODE != RIS_SUCCESS)
    {
        return(SQLCODE);     
    } 
{RISint_execute(&RIScpp_stmt_id0,0,0,7,1,0);
}

#line 33 "srv_util.rc"

    if (SQLCODE != RIS_SUCCESS)
    {
        return(SQLCODE);     
    } 
    if (dba_log) fprintf(dba_log, "exec sql successful..\n");
    return(SQLCODE);     
}
/* Function: dba_srv_sql_report_error */
int dba_srv_sql_report_error(sql_err)
char **sql_err;
{
    int length;

#line 46 "srv_util.rc"

char * err;

#line 48 "srv_util.rc"

RISint_report_error(0,&err);

#line 49 "srv_util.rc"

    length = strlen(err);
    if (dba_log) fprintf(dba_log, "length of error string is %d\n", length);
    *sql_err = err;
    if (dba_log) fprintf(dba_log, "%s\n", *sql_err);
    return(SQLCODE);     
} 
/* Function: dba_srv_sql_prepare */
int dba_srv_sql_prepare(cursor, sql_string)
int cursor;

#line 59 "srv_util.rc"

char * sql_string;

#line 61 "srv_util.rc"

{
    if (dba_log) fprintf(dba_log, "%s\n", sql_string);
    switch(cursor)
    {
	case 0:
{RISint_prepare(&RIScpp_stmt_id1,sql_string,1,0);
}

#line 67 "srv_util.rc"

          return(SQLCODE);
	case 1:
{RISint_prepare(&RIScpp_stmt_id2,sql_string,1,0);
}

#line 70 "srv_util.rc"

          return(SQLCODE);
	case 2:
{RISint_prepare(&RIScpp_stmt_id3,sql_string,1,0);
}

#line 73 "srv_util.rc"

          return(SQLCODE);
	case 3:
{RISint_prepare(&RIScpp_stmt_id4,sql_string,1,0);
}

#line 76 "srv_util.rc"

          return(SQLCODE);
	case 4:
{RISint_prepare(&RIScpp_stmt_id5,sql_string,1,0);
}

#line 79 "srv_util.rc"

          return(SQLCODE);
	case 5:
{RISint_prepare(&RIScpp_stmt_id6,sql_string,1,0);
}

#line 82 "srv_util.rc"

          return(SQLCODE);
	case 6:
{RISint_prepare(&RIScpp_stmt_id7,sql_string,1,0);
}

#line 85 "srv_util.rc"

          return(SQLCODE);
	case 7:
{RISint_prepare(&RIScpp_stmt_id8,sql_string,1,0);
}

#line 88 "srv_util.rc"

          return(SQLCODE);
	case 8:
{RISint_prepare(&RIScpp_stmt_id9,sql_string,1,0);
}

#line 91 "srv_util.rc"

          return(SQLCODE);
	case 9:
{RISint_prepare(&RIScpp_stmt_id10,sql_string,1,0);
}

#line 94 "srv_util.rc"

          return(SQLCODE);
	case 10:
{RISint_prepare(&RIScpp_stmt_id11,sql_string,1,0);
}

#line 97 "srv_util.rc"

          return(SQLCODE);

        default:
          return(DBA_NET_NO_SUCH_CURSOR);
     }
}
/* Function: dba_srv_sql_declare */
dba_srv_sql_declare(cursor)
int cursor;
{
    switch(cursor)
    {
	case 0:
/* declare for statement id requires no work just return success */
RISint_set_sqlcode(RIS_SUCCESS);

#line 111 "srv_util.rc"

          return(SQLCODE);
	case 1:
/* declare for statement id requires no work just return success */
RISint_set_sqlcode(RIS_SUCCESS);

#line 114 "srv_util.rc"

          return(SQLCODE);
	case 2:
/* declare for statement id requires no work just return success */
RISint_set_sqlcode(RIS_SUCCESS);

#line 117 "srv_util.rc"

          return(SQLCODE);
	case 3:
/* declare for statement id requires no work just return success */
RISint_set_sqlcode(RIS_SUCCESS);

#line 120 "srv_util.rc"

          return(SQLCODE);
	case 4:
/* declare for statement id requires no work just return success */
RISint_set_sqlcode(RIS_SUCCESS);

#line 123 "srv_util.rc"

          return(SQLCODE);
	case 5:
/* declare for statement id requires no work just return success */
RISint_set_sqlcode(RIS_SUCCESS);

#line 126 "srv_util.rc"

          return(SQLCODE);
	case 6:
/* declare for statement id requires no work just return success */
RISint_set_sqlcode(RIS_SUCCESS);

#line 129 "srv_util.rc"

          return(SQLCODE);
	case 7:
/* declare for statement id requires no work just return success */
RISint_set_sqlcode(RIS_SUCCESS);

#line 132 "srv_util.rc"

          return(SQLCODE);
	case 8:
/* declare for statement id requires no work just return success */
RISint_set_sqlcode(RIS_SUCCESS);

#line 135 "srv_util.rc"

          return(SQLCODE);
	case 9:
/* declare for statement id requires no work just return success */
RISint_set_sqlcode(RIS_SUCCESS);

#line 138 "srv_util.rc"

          return(SQLCODE);
	case 10:
/* declare for statement id requires no work just return success */
RISint_set_sqlcode(RIS_SUCCESS);

#line 141 "srv_util.rc"

          return(SQLCODE);
        default:
          return(DBA_NET_NO_SUCH_CURSOR);
     }
}
/* Function: dba_srv_sql_describe */
dba_srv_sql_describe(cursor, in_desc)
int cursor;
sqlda *in_desc;
{

#line 152 "srv_util.rc"

sqlda * desc;

#line 154 "srv_util.rc"

    
    desc = in_desc;
    switch(cursor)
    {
	case 0:
{RISint_describe(RIScpp_stmt_id1,desc,1);
}

#line 160 "srv_util.rc"

          return(SQLCODE);
	case 1:
{RISint_describe(RIScpp_stmt_id2,desc,1);
}

#line 163 "srv_util.rc"

          return(SQLCODE);
	case 2:
{RISint_describe(RIScpp_stmt_id3,desc,1);
}

#line 166 "srv_util.rc"

          return(SQLCODE);
	case 3:
{RISint_describe(RIScpp_stmt_id4,desc,1);
}

#line 169 "srv_util.rc"

          return(SQLCODE);
	case 4:
{RISint_describe(RIScpp_stmt_id5,desc,1);
}

#line 172 "srv_util.rc"

          return(SQLCODE);
	case 5:
{RISint_describe(RIScpp_stmt_id6,desc,1);
}

#line 175 "srv_util.rc"

          return(SQLCODE);
	case 6:
{RISint_describe(RIScpp_stmt_id7,desc,1);
}

#line 178 "srv_util.rc"

          return(SQLCODE);
	case 7:
{RISint_describe(RIScpp_stmt_id8,desc,1);
}

#line 181 "srv_util.rc"

          return(SQLCODE);
	case 8:
{RISint_describe(RIScpp_stmt_id9,desc,1);
}

#line 184 "srv_util.rc"

          return(SQLCODE);
	case 9:
{RISint_describe(RIScpp_stmt_id10,desc,1);
}

#line 187 "srv_util.rc"

          return(SQLCODE);
	case 10:
{RISint_describe(RIScpp_stmt_id11,desc,1);
}

#line 190 "srv_util.rc"

          return(SQLCODE);
        default:
          return(DBA_NET_NO_SUCH_CURSOR);
     }
}
/* Function: dba_srv_sql_open */
dba_srv_sql_open(cursor)
int cursor;
{
    switch(cursor)
    {
	case 0:
{RISint_execute(&RIScpp_stmt_id1,0,0,7,1,0);
}

#line 203 "srv_util.rc"

          return(SQLCODE);
	case 1:
{RISint_execute(&RIScpp_stmt_id2,0,0,7,1,0);
}

#line 206 "srv_util.rc"

          return(SQLCODE);
	case 2:
{RISint_execute(&RIScpp_stmt_id3,0,0,7,1,0);
}

#line 209 "srv_util.rc"

          return(SQLCODE);
	case 3:
{RISint_execute(&RIScpp_stmt_id4,0,0,7,1,0);
}

#line 212 "srv_util.rc"

          return(SQLCODE);
	case 4:
{RISint_execute(&RIScpp_stmt_id5,0,0,7,1,0);
}

#line 215 "srv_util.rc"

          return(SQLCODE);
	case 5:
{RISint_execute(&RIScpp_stmt_id6,0,0,7,1,0);
}

#line 218 "srv_util.rc"

          return(SQLCODE);
	case 6:
{RISint_execute(&RIScpp_stmt_id7,0,0,7,1,0);
}

#line 221 "srv_util.rc"

          return(SQLCODE);
	case 7:
{RISint_execute(&RIScpp_stmt_id8,0,0,7,1,0);
}

#line 224 "srv_util.rc"

          return(SQLCODE);
	case 8:
{RISint_execute(&RIScpp_stmt_id9,0,0,7,1,0);
}

#line 227 "srv_util.rc"

          return(SQLCODE);
	case 9:
{RISint_execute(&RIScpp_stmt_id10,0,0,7,1,0);
}

#line 230 "srv_util.rc"

          return(SQLCODE);
	case 10:
{RISint_execute(&RIScpp_stmt_id11,0,0,7,1,0);
}

#line 233 "srv_util.rc"

          return(SQLCODE);
        default:
          return(DBA_NET_NO_SUCH_CURSOR);
     }
}
/* Function: dba_srv_sql_close */
dba_srv_sql_close(cursor)
int cursor;
{
    switch(cursor)
    {
	case 0:
{RISint_close(RIScpp_stmt_id1, 0, 7);
}

#line 246 "srv_util.rc"

          return(SQLCODE);
	case 1:
{RISint_close(RIScpp_stmt_id2, 0, 7);
}

#line 249 "srv_util.rc"

          return(SQLCODE);
	case 2:
{RISint_close(RIScpp_stmt_id3, 0, 7);
}

#line 252 "srv_util.rc"

          return(SQLCODE);
	case 3:
{RISint_close(RIScpp_stmt_id4, 0, 7);
}

#line 255 "srv_util.rc"

          return(SQLCODE);
	case 4:
{RISint_close(RIScpp_stmt_id5, 0, 7);
}

#line 258 "srv_util.rc"

          return(SQLCODE);
	case 5:
{RISint_close(RIScpp_stmt_id6, 0, 7);
}

#line 261 "srv_util.rc"

          return(SQLCODE);
	case 6:
{RISint_close(RIScpp_stmt_id7, 0, 7);
}

#line 264 "srv_util.rc"

          return(SQLCODE);
	case 7:
{RISint_close(RIScpp_stmt_id8, 0, 7);
}

#line 267 "srv_util.rc"

          return(SQLCODE);
	case 8:
{RISint_close(RIScpp_stmt_id9, 0, 7);
}

#line 270 "srv_util.rc"

          return(SQLCODE);
	case 9:
{RISint_close(RIScpp_stmt_id10, 0, 7);
}

#line 273 "srv_util.rc"

          return(SQLCODE);
	case 10:
{RISint_close(RIScpp_stmt_id11, 0, 7);
}

#line 276 "srv_util.rc"

          return(SQLCODE);
        default:
          return(DBA_NET_NO_SUCH_CURSOR);
     }
}
/* Function: dba_srv_sql_clear */
dba_srv_sql_clear(cursor)
int cursor;
{
    switch(cursor)
    {
	case 0:
{RISint_clear(&RIScpp_stmt_id1, 0, 7);
}

#line 289 "srv_util.rc"

          return(SQLCODE);
	case 1:
{RISint_clear(&RIScpp_stmt_id2, 0, 7);
}

#line 292 "srv_util.rc"

          return(SQLCODE);
	case 2:
{RISint_clear(&RIScpp_stmt_id3, 0, 7);
}

#line 295 "srv_util.rc"

          return(SQLCODE);
	case 3:
{RISint_clear(&RIScpp_stmt_id4, 0, 7);
}

#line 298 "srv_util.rc"

          return(SQLCODE);
	case 4:
{RISint_clear(&RIScpp_stmt_id5, 0, 7);
}

#line 301 "srv_util.rc"

          return(SQLCODE);
	case 5:
{RISint_clear(&RIScpp_stmt_id6, 0, 7);
}

#line 304 "srv_util.rc"

          return(SQLCODE);
	case 6:
{RISint_clear(&RIScpp_stmt_id7, 0, 7);
}

#line 307 "srv_util.rc"

          return(SQLCODE);
	case 7:
{RISint_clear(&RIScpp_stmt_id8, 0, 7);
}

#line 310 "srv_util.rc"

          return(SQLCODE);
	case 8:
{RISint_clear(&RIScpp_stmt_id9, 0, 7);
}

#line 313 "srv_util.rc"

          return(SQLCODE);
	case 9:
{RISint_clear(&RIScpp_stmt_id10, 0, 7);
}

#line 316 "srv_util.rc"

          return(SQLCODE);
	case 10:
{RISint_clear(&RIScpp_stmt_id11, 0, 7);
}

#line 319 "srv_util.rc"

          return(SQLCODE);
        default:
          return(DBA_NET_NO_SUCH_CURSOR);
     }
}
/* Function: dba_srv_sql_fetch */
dba_srv_sql_fetch(cursor, in_desc)
int cursor;
sqlda *in_desc;
{

#line 330 "srv_util.rc"

sqlda * desc;

#line 332 "srv_util.rc"

    desc = in_desc;
    switch(cursor)
    {
	case 0:
{RISint_fetch(RIScpp_stmt_id1,0,desc,0,7);
}

#line 337 "srv_util.rc"

          return(SQLCODE);
	case 1:
{RISint_fetch(RIScpp_stmt_id2,0,desc,0,7);
}

#line 340 "srv_util.rc"

          return(SQLCODE);
	case 2:
{RISint_fetch(RIScpp_stmt_id3,0,desc,0,7);
}

#line 343 "srv_util.rc"

          return(SQLCODE);
	case 3:
{RISint_fetch(RIScpp_stmt_id4,0,desc,0,7);
}

#line 346 "srv_util.rc"

          return(SQLCODE);
	case 4:
{RISint_fetch(RIScpp_stmt_id5,0,desc,0,7);
}

#line 349 "srv_util.rc"

          return(SQLCODE);
	case 5:
{RISint_fetch(RIScpp_stmt_id6,0,desc,0,7);
}

#line 352 "srv_util.rc"

          return(SQLCODE);
	case 6:
{RISint_fetch(RIScpp_stmt_id7,0,desc,0,7);
}

#line 355 "srv_util.rc"

          return(SQLCODE);
	case 7:
{RISint_fetch(RIScpp_stmt_id8,0,desc,0,7);
}

#line 358 "srv_util.rc"

          return(SQLCODE);
	case 8:
{RISint_fetch(RIScpp_stmt_id9,0,desc,0,7);
}

#line 361 "srv_util.rc"

          return(SQLCODE);
	case 9:
{RISint_fetch(RIScpp_stmt_id10,0,desc,0,7);
}

#line 364 "srv_util.rc"

          return(SQLCODE);
	case 10:
{RISint_fetch(RIScpp_stmt_id11,0,desc,0,7);
}

#line 367 "srv_util.rc"

          return(SQLCODE);
        default:
          return(DBA_NET_NO_SUCH_CURSOR);
     }
}
