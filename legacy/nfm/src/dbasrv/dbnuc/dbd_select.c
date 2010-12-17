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

#line 1 "dbd_select.rc"
/* $Revision: 1.1 $ */
#include "dba.ext"
#include "dmalloc.def"
#include <stdarg.h>

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

extern char *dba_timestamp_format, *dba_errtxt;


#line 19 "dbd_select.rc"

sqlda dba_d[11];

#line 21 "dbd_select.rc"

int dba_cur_in_use[11];
extern int dba_use_server_flag;
/*
    Function:	dba_ris_select
    Author:	Tim A. Thompson
    Date:	6-AUG-90  (adapted for stand-alone use 22-APR-92)

    Revisions:
	7-1-92  -- Added cursors 5 and 6 for internal use.
	7-20-92 -- Added cursor 7 for internal use.
	1-14-92  -- Moved dba_upgrade_sqltype() to dba_select() from
		    dba_fetch()
*/

int dba_ris_select (curs, in_desc, sqltxt)
int curs;
sqlda **in_desc;

#line 39 "dbd_select.rc"

char * sqltxt;

#line 41 "dbd_select.rc"

{

#line 43 "dbd_select.rc"

sqlda * desc;

#line 45 "dbd_select.rc"

  int status=0, k;


#line 48 "dbd_select.rc"

  
  desc = 0;

  switch (curs) {
    case 0:
      if (dba_cur_in_use[0]) {
        status = dba_scr_close_cursor0 ();
        if (status != RIS_SUCCESS)
          goto sql_error;
      }
{RISint_prepare(&RIScpp_stmt_id0,sqltxt,1,0);
if (RISget_sqlcode() != RIS_SUCCESS) goto sql_error;}

#line 59 "dbd_select.rc"

/* declare for statement id requires no work just return success */
RISint_set_sqlcode(RIS_SUCCESS);

#line 60 "dbd_select.rc"

      desc = &dba_d[curs];
      dba_d[curs].sqld = dba_d[curs].sqln = 0;
{RISint_describe(RIScpp_stmt_id0,desc,1);
if (RISget_sqlcode() != RIS_SUCCESS) goto sql_error;}

#line 63 "dbd_select.rc"

      break;
    case 1:
      if (dba_cur_in_use[1]) {
        status = dba_scr_close_cursor1 ();
        if (status != RIS_SUCCESS)
          goto sql_error;
      }
{RISint_prepare(&RIScpp_stmt_id1,sqltxt,1,0);
if (RISget_sqlcode() != RIS_SUCCESS) goto sql_error;}

#line 71 "dbd_select.rc"

/* declare for statement id requires no work just return success */
RISint_set_sqlcode(RIS_SUCCESS);

#line 72 "dbd_select.rc"

      desc = &dba_d[curs];
      dba_d[curs].sqld = dba_d[curs].sqln = 0;
{RISint_describe(RIScpp_stmt_id1,desc,1);
if (RISget_sqlcode() != RIS_SUCCESS) goto sql_error;}

#line 75 "dbd_select.rc"

      break;
    case 2:
      if (dba_cur_in_use[2]) {
        status = dba_scr_close_cursor2 ();
        if (status != RIS_SUCCESS)
          goto sql_error;
      }
{RISint_prepare(&RIScpp_stmt_id2,sqltxt,1,0);
if (RISget_sqlcode() != RIS_SUCCESS) goto sql_error;}

#line 83 "dbd_select.rc"

/* declare for statement id requires no work just return success */
RISint_set_sqlcode(RIS_SUCCESS);

#line 84 "dbd_select.rc"

      desc = &dba_d[curs];
      dba_d[curs].sqld = dba_d[curs].sqln = 0;
{RISint_describe(RIScpp_stmt_id2,desc,1);
if (RISget_sqlcode() != RIS_SUCCESS) goto sql_error;}

#line 87 "dbd_select.rc"

      break;
    case 3:
      if (dba_cur_in_use[3]) {
        status = dba_scr_close_cursor3 ();
        if (status != RIS_SUCCESS)
          goto sql_error;
      }
{RISint_prepare(&RIScpp_stmt_id3,sqltxt,1,0);
if (RISget_sqlcode() != RIS_SUCCESS) goto sql_error;}

#line 95 "dbd_select.rc"

/* declare for statement id requires no work just return success */
RISint_set_sqlcode(RIS_SUCCESS);

#line 96 "dbd_select.rc"

      desc = &dba_d[curs];
      dba_d[curs].sqld = dba_d[curs].sqln = 0;
{RISint_describe(RIScpp_stmt_id3,desc,1);
if (RISget_sqlcode() != RIS_SUCCESS) goto sql_error;}

#line 99 "dbd_select.rc"

      break;
    case 4:
      if (dba_cur_in_use[4]) {
        status = dba_scr_close_cursor4 ();
        if (status != RIS_SUCCESS)
          goto sql_error;
      }
{RISint_prepare(&RIScpp_stmt_id4,sqltxt,1,0);
if (RISget_sqlcode() != RIS_SUCCESS) goto sql_error;}

#line 107 "dbd_select.rc"

/* declare for statement id requires no work just return success */
RISint_set_sqlcode(RIS_SUCCESS);

#line 108 "dbd_select.rc"

      desc = &dba_d[curs];
      dba_d[curs].sqld = dba_d[curs].sqln = 0;
{RISint_describe(RIScpp_stmt_id4,desc,1);
if (RISget_sqlcode() != RIS_SUCCESS) goto sql_error;}

#line 111 "dbd_select.rc"

      break;
    case 5:
      if (dba_cur_in_use[5]) {
        status = dba_scr_close_cursor5 ();
        if (status != RIS_SUCCESS)
          goto sql_error;
      }
{RISint_prepare(&RIScpp_stmt_id5,sqltxt,1,0);
if (RISget_sqlcode() != RIS_SUCCESS) goto sql_error;}

#line 119 "dbd_select.rc"

/* declare for statement id requires no work just return success */
RISint_set_sqlcode(RIS_SUCCESS);

#line 120 "dbd_select.rc"

      desc = &dba_d[curs];
      dba_d[curs].sqld = dba_d[curs].sqln = 0;
{RISint_describe(RIScpp_stmt_id5,desc,1);
if (RISget_sqlcode() != RIS_SUCCESS) goto sql_error;}

#line 123 "dbd_select.rc"

      break;
    case 6:
      if (dba_cur_in_use[6]) {
        status = dba_scr_close_cursor6 ();
        if (status != RIS_SUCCESS)
          goto sql_error;
      }
{RISint_prepare(&RIScpp_stmt_id6,sqltxt,1,0);
if (RISget_sqlcode() != RIS_SUCCESS) goto sql_error;}

#line 131 "dbd_select.rc"

/* declare for statement id requires no work just return success */
RISint_set_sqlcode(RIS_SUCCESS);

#line 132 "dbd_select.rc"

      desc = &dba_d[curs];
      dba_d[curs].sqld = dba_d[curs].sqln = 0;
{RISint_describe(RIScpp_stmt_id6,desc,1);
if (RISget_sqlcode() != RIS_SUCCESS) goto sql_error;}

#line 135 "dbd_select.rc"

      break;
    case 7:
      if (dba_cur_in_use[7]) {
        status = dba_scr_close_cursor7 ();
        if (status != RIS_SUCCESS)
          goto sql_error;
      }
{RISint_prepare(&RIScpp_stmt_id7,sqltxt,1,0);
if (RISget_sqlcode() != RIS_SUCCESS) goto sql_error;}

#line 143 "dbd_select.rc"

/* declare for statement id requires no work just return success */
RISint_set_sqlcode(RIS_SUCCESS);

#line 144 "dbd_select.rc"

      desc = &dba_d[curs];
      dba_d[curs].sqld = dba_d[curs].sqln = 0;
{RISint_describe(RIScpp_stmt_id7,desc,1);
if (RISget_sqlcode() != RIS_SUCCESS) goto sql_error;}

#line 147 "dbd_select.rc"

      break;
    case 8:
      if (dba_cur_in_use[8]) {
        status = dba_scr_close_cursor8 ();
        if (status != RIS_SUCCESS)
          goto sql_error;
      }
{RISint_prepare(&RIScpp_stmt_id8,sqltxt,1,0);
if (RISget_sqlcode() != RIS_SUCCESS) goto sql_error;}

#line 155 "dbd_select.rc"

/* declare for statement id requires no work just return success */
RISint_set_sqlcode(RIS_SUCCESS);

#line 156 "dbd_select.rc"

      desc = &dba_d[curs];
      dba_d[curs].sqld = dba_d[curs].sqln = 0;
{RISint_describe(RIScpp_stmt_id8,desc,1);
if (RISget_sqlcode() != RIS_SUCCESS) goto sql_error;}

#line 159 "dbd_select.rc"

      break;
    case 9:
      if (dba_cur_in_use[9]) {
        status = dba_scr_close_cursor9 ();
        if (status != RIS_SUCCESS)
          goto sql_error;
      }
{RISint_prepare(&RIScpp_stmt_id9,sqltxt,1,0);
if (RISget_sqlcode() != RIS_SUCCESS) goto sql_error;}

#line 167 "dbd_select.rc"

/* declare for statement id requires no work just return success */
RISint_set_sqlcode(RIS_SUCCESS);

#line 168 "dbd_select.rc"

      desc = &dba_d[curs];
      dba_d[curs].sqld = dba_d[curs].sqln = 0;
{RISint_describe(RIScpp_stmt_id9,desc,1);
if (RISget_sqlcode() != RIS_SUCCESS) goto sql_error;}

#line 171 "dbd_select.rc"

      break;
    case 10:
      if (dba_cur_in_use[10]) {
        status = dba_scr_close_cursor10 ();
        if (status != RIS_SUCCESS)
          goto sql_error;
      }
{RISint_prepare(&RIScpp_stmt_id10,sqltxt,1,0);
if (RISget_sqlcode() != RIS_SUCCESS) goto sql_error;}

#line 179 "dbd_select.rc"

/* declare for statement id requires no work just return success */
RISint_set_sqlcode(RIS_SUCCESS);

#line 180 "dbd_select.rc"

      desc = &dba_d[curs];
      dba_d[curs].sqld = dba_d[curs].sqln = 0;
{RISint_describe(RIScpp_stmt_id10,desc,1);
if (RISget_sqlcode() != RIS_SUCCESS) goto sql_error;}

#line 183 "dbd_select.rc"

      break;
    default:
      strcpy (dba_errtxt, dba_get_msg (DBA_E_SCR_INV_CURSOR, "%ld", 0, 
        (long) curs, NP));
      return (99); }

  dba_d[curs].sqlvar = (sqlvar *) dba_dmalloc
      (dba_d[curs].sqld * sizeof (sqlvar), DM_SQLVAR);
  dba_d[curs].sqln = dba_d[curs].sqld;
  switch (curs) {
    case 0:
{RISint_describe(RIScpp_stmt_id0,desc,1);
if (RISget_sqlcode() != RIS_SUCCESS) goto sql_error;}

#line 195 "dbd_select.rc"

{RISint_execute(&RIScpp_stmt_id0,0,0,7,1,0);
if (RISget_sqlcode() != RIS_SUCCESS) goto sql_error;}

#line 196 "dbd_select.rc"

      break;
    case 1:
{RISint_describe(RIScpp_stmt_id1,desc,1);
if (RISget_sqlcode() != RIS_SUCCESS) goto sql_error;}

#line 199 "dbd_select.rc"

{RISint_execute(&RIScpp_stmt_id1,0,0,7,1,0);
if (RISget_sqlcode() != RIS_SUCCESS) goto sql_error;}

#line 200 "dbd_select.rc"

      break;
    case 2:
{RISint_describe(RIScpp_stmt_id2,desc,1);
if (RISget_sqlcode() != RIS_SUCCESS) goto sql_error;}

#line 203 "dbd_select.rc"

{RISint_execute(&RIScpp_stmt_id2,0,0,7,1,0);
if (RISget_sqlcode() != RIS_SUCCESS) goto sql_error;}

#line 204 "dbd_select.rc"

      break;
    case 3:
{RISint_describe(RIScpp_stmt_id3,desc,1);
if (RISget_sqlcode() != RIS_SUCCESS) goto sql_error;}

#line 207 "dbd_select.rc"

{RISint_execute(&RIScpp_stmt_id3,0,0,7,1,0);
if (RISget_sqlcode() != RIS_SUCCESS) goto sql_error;}

#line 208 "dbd_select.rc"

      break;
    case 4:
{RISint_describe(RIScpp_stmt_id4,desc,1);
if (RISget_sqlcode() != RIS_SUCCESS) goto sql_error;}

#line 211 "dbd_select.rc"

{RISint_execute(&RIScpp_stmt_id4,0,0,7,1,0);
if (RISget_sqlcode() != RIS_SUCCESS) goto sql_error;}

#line 212 "dbd_select.rc"

      break;
    case 5:
{RISint_describe(RIScpp_stmt_id5,desc,1);
if (RISget_sqlcode() != RIS_SUCCESS) goto sql_error;}

#line 215 "dbd_select.rc"

{RISint_execute(&RIScpp_stmt_id5,0,0,7,1,0);
if (RISget_sqlcode() != RIS_SUCCESS) goto sql_error;}

#line 216 "dbd_select.rc"

      break;
    case 6:
{RISint_describe(RIScpp_stmt_id6,desc,1);
if (RISget_sqlcode() != RIS_SUCCESS) goto sql_error;}

#line 219 "dbd_select.rc"

{RISint_execute(&RIScpp_stmt_id6,0,0,7,1,0);
if (RISget_sqlcode() != RIS_SUCCESS) goto sql_error;}

#line 220 "dbd_select.rc"

      break;
    case 7:
{RISint_describe(RIScpp_stmt_id7,desc,1);
if (RISget_sqlcode() != RIS_SUCCESS) goto sql_error;}

#line 223 "dbd_select.rc"

{RISint_execute(&RIScpp_stmt_id7,0,0,7,1,0);
if (RISget_sqlcode() != RIS_SUCCESS) goto sql_error;}

#line 224 "dbd_select.rc"

      break;
    case 8:
{RISint_describe(RIScpp_stmt_id8,desc,1);
if (RISget_sqlcode() != RIS_SUCCESS) goto sql_error;}

#line 227 "dbd_select.rc"

{RISint_execute(&RIScpp_stmt_id8,0,0,7,1,0);
if (RISget_sqlcode() != RIS_SUCCESS) goto sql_error;}

#line 228 "dbd_select.rc"

      break;
    case 9:
{RISint_describe(RIScpp_stmt_id9,desc,1);
if (RISget_sqlcode() != RIS_SUCCESS) goto sql_error;}

#line 231 "dbd_select.rc"

{RISint_execute(&RIScpp_stmt_id9,0,0,7,1,0);
if (RISget_sqlcode() != RIS_SUCCESS) goto sql_error;}

#line 232 "dbd_select.rc"

      break;
    case 10:
{RISint_describe(RIScpp_stmt_id10,desc,1);
if (RISget_sqlcode() != RIS_SUCCESS) goto sql_error;}

#line 235 "dbd_select.rc"

{RISint_execute(&RIScpp_stmt_id10,0,0,7,1,0);
if (RISget_sqlcode() != RIS_SUCCESS) goto sql_error;}

#line 236 "dbd_select.rc"

      break;
  }
  dba_cur_in_use[curs] = 1;
  for (k=0; k<desc->sqld; k++)
    dba_upgrade_sqltype (&desc->sqlvar[k]);

sql_error:

#line 244 "dbd_select.rc"

  if (status || dba_get_sqlcode() != RIS_SUCCESS) {
    dba_cur_in_use[curs] = 0;
    if (dba_d[curs].sqlvar) {
      dba_dfree (dba_d[curs].sqlvar);
      dba_d[curs].sqlvar = 0;
    }
  }

  if (in_desc)
    *in_desc = desc;

  return (status ? status : dba_get_sqlcode());
}


/*
    function:	dba_ris_fetch
    Author:	Tim A. Thompson
    Date:	8-AUG-90  (adapted for stand-alone use 26-APR-92)

    Revisions:
	7-1-92   -- Added cursors 5 and 6 for internal use.
	7-20-92  -- Call dba_upgrade_sqltype() for passed sqlda.
	7-20-92  -- Added cursor 7 for internal use.
	10-29-92 -- Include "stdarg.h" instead of "sys/varargs.h" and change
		    function declaration to ansi style.  (To fix Sun problem.)
	1-14-92  -- Moved dba_upgrade_sqltype() to dba_select() from
		    dba_fetch()
	9-15-93  -- Was not freeing valptr and indptr.
*/

int dba_ris_fetch (int curs, sqlda *in_desc, va_list ap)
{

#line 278 "dbd_select.rc"

sqlda * desc;

#line 280 "dbd_select.rc"

  int istat, k, coltype, timefetch=0;
  long tmplong;
  char **valptr=0;
  long **indptr;

  if (!dba_cur_in_use[curs]) {
    strcpy (dba_errtxt, dba_get_msg (DBA_E_SCR_CURSOR_NOT_OPEN, "%ld", 0,
      (long) curs, NP));
    return (99);
  }

/*
  va_start (ap, in_desc);
*/
  if (in_desc) {
    desc = in_desc;
/*
    for (k=0; k<desc->sqld; k++)
      dba_upgrade_sqltype (&desc->sqlvar[k]);
*/
  }
  else
  {
    desc = &dba_d[curs];
    valptr = (char **) dba_dmalloc (desc->sqld * sizeof (char *), DM_TMP);
    indptr = (long **) dba_dmalloc (desc->sqld * sizeof (long *), DM_TMP);
    for (k=0; k<desc->sqld; k++) {
      valptr[k] = va_arg (ap, char *);
      indptr[k] = va_arg (ap, long *);
/*
      dba_upgrade_sqltype (&desc->sqlvar[k]);
*/
      coltype = desc->sqlvar[k].sqltype;
      if (coltype == 9) {
        timefetch = 1;
        desc->sqlvar[k].sqldata =
            (char *) dba_dmalloc (desc->sqlvar[k].sqllen, DM_TIMESTAMP_TMP);
      }
      else
      {
        desc->sqlvar[k].sqldata = valptr[k];
        if (coltype == 1)
          valptr[k][desc->sqlvar[k].sqllen] = '\0';
      }
      if (indptr[k])
        desc->sqlvar[k].sqlind = indptr[k];
      else
        desc->sqlvar[k].sqlind = &tmplong;
    }
  }
  switch (curs) {
    case 0:
{RISint_fetch(RIScpp_stmt_id0,0,desc,0,7);
}

#line 333 "dbd_select.rc"

      break;
    case 1:
{RISint_fetch(RIScpp_stmt_id1,0,desc,0,7);
}

#line 336 "dbd_select.rc"

      break;
    case 2:
{RISint_fetch(RIScpp_stmt_id2,0,desc,0,7);
}

#line 339 "dbd_select.rc"

      break;
    case 3:
{RISint_fetch(RIScpp_stmt_id3,0,desc,0,7);
}

#line 342 "dbd_select.rc"

      break;
    case 4:
{RISint_fetch(RIScpp_stmt_id4,0,desc,0,7);
}

#line 345 "dbd_select.rc"

      break;
    case 5:
{RISint_fetch(RIScpp_stmt_id5,0,desc,0,7);
}

#line 348 "dbd_select.rc"

      break;
    case 6:
{RISint_fetch(RIScpp_stmt_id6,0,desc,0,7);
}

#line 351 "dbd_select.rc"

      break;
    case 7:
{RISint_fetch(RIScpp_stmt_id7,0,desc,0,7);
}

#line 354 "dbd_select.rc"

      break;
    case 8:
{RISint_fetch(RIScpp_stmt_id8,0,desc,0,7);
}

#line 357 "dbd_select.rc"

      break;
    case 9:
{RISint_fetch(RIScpp_stmt_id9,0,desc,0,7);
}

#line 360 "dbd_select.rc"

      break;
    case 10:
{RISint_fetch(RIScpp_stmt_id10,0,desc,0,7);
}

#line 363 "dbd_select.rc"

      break;
  }

  if (dba_get_sqlcode() != RIS_SUCCESS && dba_get_sqlcode() != END_OF_DATA) {
    dba_cur_in_use[curs] = 0;
    if (desc->sqlvar) {
      dba_dfree (desc->sqlvar);
      desc->sqlvar = 0;
    }
  }
  else
  {
    if (timefetch) {
      for (k=0; k<desc->sqld; k++) {
        if (desc->sqlvar[k].sqltype == 9) {
          istat = RISdatetime_to_ascii (desc->sqlvar[k].sqldata, valptr[k],
              dba_timestamp_format);
          dba_dfree (desc->sqlvar[k].sqldata);
        }
      }
    }
  }
  if (valptr) {
    dba_dfree (valptr);
    dba_dfree (indptr);
  }
/*
  va_end (ap);
*/
  return (dba_get_sqlcode());
}


/*
    Function:	dba_ris_close_cursor
    Author:	Tim A. Thompson
    Date:	13-AUG-90  (adapted for stand-alone use 25-APR-92)

    Revisions:
	7-1-92  -- Added cursors 5 and 6 for internal use.
	7-20-92 -- Added cursor 7 for internal use.
*/

int dba_ris_close_cursor (curs)
int curs;
{
  int status = 0;

  if (dba_cur_in_use[curs]) {
    switch (curs) {
      case 0:
        status = dba_scr_close_cursor0 ();
        break;
      case 1:
        status = dba_scr_close_cursor1 ();
        break;
      case 2:
        status = dba_scr_close_cursor2 ();
        break;
      case 3:
        status = dba_scr_close_cursor3 ();
        break;
      case 4:
        status = dba_scr_close_cursor4 ();
        break;
      case 5:
        status = dba_scr_close_cursor5 ();
        break;
      case 6:
        status = dba_scr_close_cursor6 ();
        break;
      case 7:
        status = dba_scr_close_cursor7 ();
        break;
      case 8:
        status = dba_scr_close_cursor8 ();
        break;
      case 9:
        status = dba_scr_close_cursor9 ();
        break;
      case 10:
        status = dba_scr_close_cursor10 ();
        break;
    }
  }
  dba_cur_in_use[curs] = 0;
  if (dba_d[curs].sqlvar) {
    dba_dfree (dba_d[curs].sqlvar);
    dba_d[curs].sqlvar = 0;
  }

  return (status);
}


/*
   Function:	dba_scr_close_cursor0
   Author:	Tim A. Thompson
   Date:	24-NOV-91
*/

int dba_scr_close_cursor0 ()
{
  if (dba_d[0].sqlvar) {
    dba_dfree (dba_d[0].sqlvar);
    dba_d[0].sqlvar = 0;
  }
{RISint_close(RIScpp_stmt_id0, 0, 7);
}

#line 471 "dbd_select.rc"

  if (dba_get_sqlcode() != RIS_SUCCESS) {
#if defined RIS4 || defined RIS5
    if (dba_get_sqlcode() == RIS_E_CURSOR_NOT_OPEN)
#else
    if (dba_get_sqlcode() == RISint_CURSOR_NOT_OPEN
        || dba_get_sqlcode() == RISapp_CURSOR_NOT_OPEN)
#endif
      return (0);
    return (dba_get_sqlcode());
  }
{RISint_clear(&RIScpp_stmt_id0, 0, 7);
}

#line 482 "dbd_select.rc"

  if (dba_get_sqlcode() != RIS_SUCCESS) {
#if defined RIS4 || defined RIS5
    if (dba_get_sqlcode()  == RIS_E_CURSOR_NOT_OPEN)
#else
    if (dba_get_sqlcode()  == RISint_CURSOR_NOT_OPEN || dba_get_sqlcode()  == RISapp_CURSOR_NOT_OPEN)
#endif
      return (0);
    return (dba_get_sqlcode());
  }
  return (0);
}


/*
   Function:	dba_scr_close_cursor1
   Author:	Tim A. Thompson
   Date:	29-JAN-91
*/

int dba_scr_close_cursor1 ()
{
  if (dba_d[1].sqlvar) {
    dba_dfree (dba_d[1].sqlvar);
    dba_d[1].sqlvar = 0;
  }
{RISint_close(RIScpp_stmt_id1, 0, 7);
}

#line 508 "dbd_select.rc"

  if (dba_get_sqlcode()  != RIS_SUCCESS) {
#if defined RIS4 || defined RIS5
    if (dba_get_sqlcode()  == RIS_E_CURSOR_NOT_OPEN)
#else
    if (dba_get_sqlcode()  == RISint_CURSOR_NOT_OPEN || dba_get_sqlcode()  == RISapp_CURSOR_NOT_OPEN)
#endif
      return (0);
    return (dba_get_sqlcode());
  }
{RISint_clear(&RIScpp_stmt_id1, 0, 7);
}

#line 518 "dbd_select.rc"

  if (dba_get_sqlcode()  != RIS_SUCCESS) {
#if defined RIS4 || defined RIS5
    if (dba_get_sqlcode()  == RIS_E_CURSOR_NOT_OPEN)
#else
    if (dba_get_sqlcode()  == RISint_CURSOR_NOT_OPEN || dba_get_sqlcode()  == RISapp_CURSOR_NOT_OPEN)
#endif
      return (0);
    return (dba_get_sqlcode());
  }
  return (0);
}


/*
   Function:	dba_scr_close_cursor2
   Author:	Tim A. Thompson
   Date:	29-JAN-91
*/

int dba_scr_close_cursor2 ()
{
  if (dba_d[2].sqlvar) {
    dba_dfree (dba_d[2].sqlvar);
    dba_d[2].sqlvar = 0;
  }
{RISint_close(RIScpp_stmt_id2, 0, 7);
}

#line 544 "dbd_select.rc"

  if (dba_get_sqlcode()  != RIS_SUCCESS) {
#if defined RIS4 || defined RIS5
    if (dba_get_sqlcode()  == RIS_E_CURSOR_NOT_OPEN)
#else
    if (dba_get_sqlcode()  == RISint_CURSOR_NOT_OPEN || dba_get_sqlcode()  == RISapp_CURSOR_NOT_OPEN)
#endif
      return (0);
    return (dba_get_sqlcode());
  }
{RISint_clear(&RIScpp_stmt_id2, 0, 7);
}

#line 554 "dbd_select.rc"

  if (dba_get_sqlcode()  != RIS_SUCCESS) {
#if defined RIS4 || defined RIS5
    if (dba_get_sqlcode()  == RIS_E_CURSOR_NOT_OPEN)
#else
    if (dba_get_sqlcode()  == RISint_CURSOR_NOT_OPEN || dba_get_sqlcode()  == RISapp_CURSOR_NOT_OPEN)
#endif
      return (0);
    return (dba_get_sqlcode());
  }
  return (0);
}


/*
   Function:	dba_scr_close_cursor3
   Author:	Tim A. Thompson
   Date:	24-NOV-91
*/

int dba_scr_close_cursor3 ()
{
  if (dba_d[3].sqlvar) {
    dba_dfree (dba_d[3].sqlvar);
    dba_d[3].sqlvar = 0;
  }
{RISint_close(RIScpp_stmt_id3, 0, 7);
}

#line 580 "dbd_select.rc"

  if (dba_get_sqlcode()  != RIS_SUCCESS) {
#if defined RIS4 || defined RIS5
    if (dba_get_sqlcode()  == RIS_E_CURSOR_NOT_OPEN)
#else
    if (dba_get_sqlcode()  == RISint_CURSOR_NOT_OPEN || dba_get_sqlcode()  == RISapp_CURSOR_NOT_OPEN)
#endif
      return (0);
    return (dba_get_sqlcode());
  }
{RISint_clear(&RIScpp_stmt_id3, 0, 7);
}

#line 590 "dbd_select.rc"

  if (dba_get_sqlcode()  != RIS_SUCCESS) {
#if defined RIS4 || defined RIS5
    if (dba_get_sqlcode()  == RIS_E_CURSOR_NOT_OPEN)
#else
    if (dba_get_sqlcode()  == RISint_CURSOR_NOT_OPEN || dba_get_sqlcode()  == RISapp_CURSOR_NOT_OPEN)
#endif
      return (0);
    return (dba_get_sqlcode());
  }
  return (0);
}


/*
   Function:	dba_scr_close_cursor4
   Author:	Tim A. Thompson
   Date:	24-NOV-91
*/

int dba_scr_close_cursor4 ()
{
  if (dba_d[4].sqlvar) {
    dba_dfree (dba_d[4].sqlvar);
    dba_d[4].sqlvar = 0;
  }
{RISint_close(RIScpp_stmt_id4, 0, 7);
}

#line 616 "dbd_select.rc"

  if (dba_get_sqlcode()  != RIS_SUCCESS) {
#if defined RIS4 || defined RIS5
    if (dba_get_sqlcode()  == RIS_E_CURSOR_NOT_OPEN)
#else
    if (dba_get_sqlcode()  == RISint_CURSOR_NOT_OPEN ||  == RISapp_CURSOR_NOT_OPEN)
#endif
      return (0);
    return (dba_get_sqlcode());
  }
{RISint_clear(&RIScpp_stmt_id4, 0, 7);
}

#line 626 "dbd_select.rc"

  if (dba_get_sqlcode()  != RIS_SUCCESS) {
#if defined RIS4 || defined RIS5
    if (dba_get_sqlcode()  == RIS_E_CURSOR_NOT_OPEN)
#else
    if (dba_get_sqlcode()  == RISint_CURSOR_NOT_OPEN || dba_get_sqlcode()  == RISapp_CURSOR_NOT_OPEN)
#endif
      return (0);
    return (dba_get_sqlcode());
  }
  return (0);
}


/*
   Function:	dba_scr_close_cursor5
   Author:	Tim A. Thompson
   Date:	01-JUL-92
*/

int dba_scr_close_cursor5 ()
{
  if (dba_d[5].sqlvar) {
    dba_dfree (dba_d[5].sqlvar);
    dba_d[5].sqlvar = 0;
  }
{RISint_close(RIScpp_stmt_id5, 0, 7);
}

#line 652 "dbd_select.rc"

  if (dba_get_sqlcode()  != RIS_SUCCESS) {
#if defined RIS4 || defined RIS5
    if (dba_get_sqlcode()  == RIS_E_CURSOR_NOT_OPEN)
#else
    if (dba_get_sqlcode()  == RISint_CURSOR_NOT_OPEN || dba_get_sqlcode()  == RISapp_CURSOR_NOT_OPEN)
#endif
      return (0);
    return (dba_get_sqlcode());
  }
{RISint_clear(&RIScpp_stmt_id5, 0, 7);
}

#line 662 "dbd_select.rc"

  if (dba_get_sqlcode()  != RIS_SUCCESS) {
#if defined RIS4 || defined RIS5
    if (dba_get_sqlcode()  == RIS_E_CURSOR_NOT_OPEN)
#else
    if (dba_get_sqlcode()  == RISint_CURSOR_NOT_OPEN || dba_get_sqlcode()  == RISapp_CURSOR_NOT_OPEN)
#endif
      return (0);
    return (dba_get_sqlcode());
  }
  return (0);
}


/*
   Function:	dba_scr_close_cursor6
   Author:	Tim A. Thompson
   Date:	01-JUL-92
*/

int dba_scr_close_cursor6 ()
{
  if (dba_d[6].sqlvar) {
    dba_dfree (dba_d[6].sqlvar);
    dba_d[6].sqlvar = 0;
  }
{RISint_close(RIScpp_stmt_id6, 0, 7);
}

#line 688 "dbd_select.rc"

  if (dba_get_sqlcode()  != RIS_SUCCESS) {
#if defined RIS4 || defined RIS5
    if (dba_get_sqlcode()  == RIS_E_CURSOR_NOT_OPEN)
#else
    if (dba_get_sqlcode()  == RISint_CURSOR_NOT_OPEN || dba_get_sqlcode()  == RISapp_CURSOR_NOT_OPEN)
#endif
      return (0);
    return (dba_get_sqlcode());
  }
{RISint_clear(&RIScpp_stmt_id6, 0, 7);
}

#line 698 "dbd_select.rc"

  if (dba_get_sqlcode()  != RIS_SUCCESS) {
#if defined RIS4 || defined RIS5
    if (dba_get_sqlcode()  == RIS_E_CURSOR_NOT_OPEN)
#else
    if (dba_get_sqlcode()  == RISint_CURSOR_NOT_OPEN || dba_get_sqlcode()  == RISapp_CURSOR_NOT_OPEN)
#endif
      return (0);
    return (dba_get_sqlcode());
  }
  return (0);
}


/*
    Function:	dba_scr_close_cursor7
    Author:	Tim A. Thompson
    Date:	20-JUL-92
*/

int dba_scr_close_cursor7 ()
{
  if (dba_d[7].sqlvar) {
    dba_dfree (dba_d[7].sqlvar);
    dba_d[7].sqlvar = 0;
  }
{RISint_close(RIScpp_stmt_id7, 0, 7);
}

#line 724 "dbd_select.rc"

  if (dba_get_sqlcode()  != RIS_SUCCESS) {
#if defined RIS4 || defined RIS5
    if (dba_get_sqlcode()  == RIS_E_CURSOR_NOT_OPEN)
#else
    if (dba_get_sqlcode()  == RISint_CURSOR_NOT_OPEN || dba_get_sqlcode()  == RISapp_CURSOR_NOT_OPEN)
#endif
      return (0);
    return (dba_get_sqlcode());
  }
{RISint_clear(&RIScpp_stmt_id7, 0, 7);
}

#line 734 "dbd_select.rc"

  if (dba_get_sqlcode()  != RIS_SUCCESS) {
#if defined RIS4 || defined RIS5
    if (dba_get_sqlcode()  == RIS_E_CURSOR_NOT_OPEN)
#else
    if (dba_get_sqlcode()  == RISint_CURSOR_NOT_OPEN || dba_get_sqlcode()  == RISapp_CURSOR_NOT_OPEN)
#endif
      return (0);
    return (dba_get_sqlcode());
  }
  return (0);
}

/*
    Function:	dba_scr_close_cursor8
    Author:	Tim A. Thompson
    Date:	20-JUL-92
*/

int dba_scr_close_cursor8 ()
{
  if (dba_d[8].sqlvar) {
    dba_dfree (dba_d[8].sqlvar);
    dba_d[8].sqlvar = 0;
  }
{RISint_close(RIScpp_stmt_id8, 0, 7);
}

#line 759 "dbd_select.rc"

  if (dba_get_sqlcode()  != RIS_SUCCESS) {
#if defined RIS4 || defined RIS5
    if (dba_get_sqlcode()  == RIS_E_CURSOR_NOT_OPEN)
#else
    if (dba_get_sqlcode()  == RISint_CURSOR_NOT_OPEN || dba_get_sqlcode()  == RISapp_CURSOR_NOT_OPEN)
#endif
      return (0);
    return (dba_get_sqlcode());
  }
{RISint_clear(&RIScpp_stmt_id8, 0, 7);
}

#line 769 "dbd_select.rc"

  if (dba_get_sqlcode()  != RIS_SUCCESS) {
#if defined RIS4 || defined RIS5
    if (dba_get_sqlcode()  == RIS_E_CURSOR_NOT_OPEN)
#else
    if (dba_get_sqlcode()  == RISint_CURSOR_NOT_OPEN || dba_get_sqlcode()  == RISapp_CURSOR_NOT_OPEN)
#endif
      return (0);
    return (dba_get_sqlcode());
  }
  return (0);
}

/*
    Function:	dba_scr_close_cursor9
    Author:	Tim A. Thompson
    Date:	20-JUL-92
*/

int dba_scr_close_cursor9 ()
{
  if (dba_d[9].sqlvar) {
    dba_dfree (dba_d[9].sqlvar);
    dba_d[9].sqlvar = 0;
  }
{RISint_close(RIScpp_stmt_id9, 0, 7);
}

#line 794 "dbd_select.rc"

  if (dba_get_sqlcode()  != RIS_SUCCESS) {
#if defined RIS4 || defined RIS5
    if (dba_get_sqlcode()  == RIS_E_CURSOR_NOT_OPEN)
#else
    if (dba_get_sqlcode()  == RISint_CURSOR_NOT_OPEN || dba_get_sqlcode()  == RISapp_CURSOR_NOT_OPEN)
#endif
      return (0);
    return (dba_get_sqlcode());
  }
{RISint_clear(&RIScpp_stmt_id9, 0, 7);
}

#line 804 "dbd_select.rc"

  if (dba_get_sqlcode()  != RIS_SUCCESS) {
#if defined RIS4 || defined RIS5
    if (dba_get_sqlcode()  == RIS_E_CURSOR_NOT_OPEN)
#else
    if (dba_get_sqlcode()  == RISint_CURSOR_NOT_OPEN || dba_get_sqlcode()  == RISapp_CURSOR_NOT_OPEN)
#endif
      return (0);
    return (dba_get_sqlcode());
  }
  return (0);
}

/*
    Function:	dba_scr_close_cursor10
    Author:	Tim A. Thompson
    Date:	20-JUL-92
*/

int dba_scr_close_cursor10 ()
{
  if (dba_d[10].sqlvar) {
    dba_dfree (dba_d[10].sqlvar);
    dba_d[10].sqlvar = 0;
  }
{RISint_close(RIScpp_stmt_id10, 0, 7);
}

#line 829 "dbd_select.rc"

  if (dba_get_sqlcode()  != RIS_SUCCESS) {
#if defined RIS4 || defined RIS5
    if (dba_get_sqlcode()  == RIS_E_CURSOR_NOT_OPEN)
#else
    if (dba_get_sqlcode()  == RISint_CURSOR_NOT_OPEN || dba_get_sqlcode()  == RISapp_CURSOR_NOT_OPEN)
#endif
      return (0);
    return (dba_get_sqlcode());
  }
{RISint_clear(&RIScpp_stmt_id10, 0, 7);
}

#line 839 "dbd_select.rc"

  if (dba_get_sqlcode()  != RIS_SUCCESS) {
#if defined RIS4 || defined RIS5
    if (dba_get_sqlcode()  == RIS_E_CURSOR_NOT_OPEN)
#else
    if (dba_get_sqlcode()  == RISint_CURSOR_NOT_OPEN || dba_get_sqlcode()  == RISapp_CURSOR_NOT_OPEN)
#endif
      return (0);
    return (dba_get_sqlcode());
  }
  return (0);
}
