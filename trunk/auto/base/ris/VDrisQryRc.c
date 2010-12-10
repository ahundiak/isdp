/***************************************************************************
 * I/VDS
 *
 * File:        vdris/rc/VDrisQry.rc
 *
 * Description: Query Routines
 *
 * Dependencies:
 *
 * Revision History:
 * $Log: VDrisQry.rc,v $
 * Revision 1.3  2002/05/09 17:45:31  ahundiak
 * ah
 *
 * Revision 1.2  2001/02/11 17:59:58  ahundiak
 * Renamed VDris2 to VDrisc
 *
 * Revision 1.1  2001/02/01 21:58:19  ahundiak
 * ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 02/01/01  ah      Header
 * 05/07/02  ah      Add trace statements
 ***************************************************************************/

#include "VDtypedefc.h"
#include "VDrisc.h"
#include "risapp.h"

static short RIScpp_stmt_id0 = -1;
static short RIScpp_stmt_id1 = -1;
static short RIScpp_stmt_id2 = -1;

#define RSX_SQLDATA_LEN 256
#define RSX_SQLCOLS_LEN  10

static int traceFlag = 0;

/* -------------------------------------------
 * Generic query
 */
int VDrisQuery(TVDrisInfo *info, char *qry)
{
  int retFlag = 0;
  int sts;

  int  cols,row;
  int  i,len;
  char data[256];
  char *p;


sqlda out_desc;

sqlda in_desc;

char * qryx;

char * err_ptr;


  /* ---------------------------------------------
   * Define buffers of reasonable size
   * maoolc if need bigger ones
   */
  sqlvar  sqlvars[RSX_SQLCOLS_LEN];
  sqlvar *sqlvarsp = NULL;

  long    sqlvari[RSX_SQLCOLS_LEN];
  long   *sqlvarip  = NULL;

  char    sqldata[RSX_SQLDATA_LEN];
  char   *sqldatap = NULL;

  /* VLA for storing recordset */
  TVDrisBuf buf;

  /* Init */
  memset(&in_desc, 0,sizeof(sqlda));
  memset(&out_desc,0,sizeof(sqlda));
  memset(&buf,     0,sizeof(TVDrisBuf));

  /* Allow the qry to be in the info structure */
  if (info == NULL) goto wrapup;
  if (qry  == NULL) qry = info->sql;
  info->rows = 0;
  info->cols = 0;
  info->buf  = NULL;

  if (traceFlag) {
    printf("### RIS QRY VDrisQuery ### \n%s\n",qry);
  }

  /* Make sure logged in */
  sts = VDrisIsSchemaOpen();
  if (!(sts & 1)) {
    printf("*** No Open Schema\n%s\n",qry);
    return 0;
  }

  /* Standard error processing */



  /* Basic info */
  qryx = qry;
{RISint_prepare(&RIScpp_stmt_id0,qryx,1,0);
if (RISget_sqlcode() != RIS_SUCCESS) goto error;}


  /* Input descriptor */
{RISint_describe(RIScpp_stmt_id0,&in_desc,0);
if (RISget_sqlcode() != RIS_SUCCESS) goto error;}

  if (in_desc.sqld) {
    printf("*** VDrisQuery does not support input parameters\n");
    printf("    %s\n",qry);
    goto error;
  }

  /* Output descriptor, get number of columns */
{RISint_describe(RIScpp_stmt_id0,&out_desc,1);
if (RISget_sqlcode() != RIS_SUCCESS) goto error;}


  cols = out_desc.sqld;
  if (cols == 0) goto wrapup;
  sqlvarsp = sqlvars;
  sqlvarip = sqlvari;

  if (cols > RSX_SQLCOLS_LEN) {
    sqlvarsp = malloc(cols * sizeof(sqlvar));
    if (sqlvarsp == NULL) goto wrapup;
    sqlvarip = malloc(cols * sizeof(long));
    if (sqlvarip == NULL) goto wrapup;
  }
    
  /* Get lengths of each column */
  out_desc.sqlvar = sqlvarsp;
  out_desc.sqln   = out_desc.sqld;

{RISint_describe(RIScpp_stmt_id0,&out_desc,1);
if (RISget_sqlcode() != RIS_SUCCESS) goto error;}


  /* Need to make a buffer big enough to handle the record */
  len = 0;
  for(i = 0; i < out_desc.sqld; i++) {
    len = len + out_desc.sqlvar[i].sqllen + 1;
  }
  sqldatap = sqldata;
  if (len > RSX_SQLDATA_LEN) {
    sqldatap = malloc(len);
    if (sqldatap == NULL) goto wrapup;
  }

  /* Set the actual data pointers */
  p = sqldatap;
  for(i = 0; i < out_desc.sqld; i++) {
    out_desc.sqlvar[i].sqlind  = &sqlvarip[i];
    out_desc.sqlvar[i].sqldata = p;
    p += out_desc.sqlvar[i].sqllen + 1;
  }

  /* Open the cursor */
/* declare for statement id requires no work just return success */
RISint_set_sqlcode(RIS_SUCCESS);

{RISint_execute(&RIScpp_stmt_id0,0,&in_desc,7,1,0);
if (RISget_sqlcode() != RIS_SUCCESS) goto error;}


  /* Cycle through */
  row = 0;
  while(1) {

    /* fetch a row of output */
{RISint_fetch(RIScpp_stmt_id0,0,&out_desc,0,7);
if (RISget_sqlcode() == END_OF_DATA) goto not_found;
else if (RISget_sqlcode() != RIS_SUCCESS) goto error;}


    /* Cycle through each field */
    for(i = 0; i < cols; i++) {
      VDrisGetDataFromSqlvar(&out_desc.sqlvar[i],data);
      VDrisAddData(data,&buf);
    }
    row++;
  }

  /* No more rows */
not_found:

{RISint_clear(&RIScpp_stmt_id0, 0, 7);
if (RISget_sqlcode() != RIS_SUCCESS) goto error;}


  /* Fill in results structure */
  info->cols = cols;
  info->rows = row;
  info->buf  = realloc(buf.data,(cols * row * sizeof(char *)));
  if (info->buf == NULL) {
    info->cols = 0;
    info->rows = 0;
  }
  if (traceFlag) {
    printf("Rows %d\n",info->rows);
  }

  /* Done */
  retFlag = 1;
  goto wrapup;


error:

RISint_report_error(0,&err_ptr);

  puts(err_ptr);

wrapup:
  /* Clean up memory */
  if ((sqlvarsp) && (sqlvarsp != sqlvars)) free(sqlvarsp);
  if ((sqldatap) && (sqldatap != sqldata)) free(sqldatap);
  if ((sqlvarip) && (sqlvarip != sqlvari)) free(sqlvarip);

  return retFlag;
}


/* -------------------------------------------
 * Execute an sql statement
 */
int VDrisExecute(char *sql)
{
  int retFlag = 0;
  int sts;


char * sqlx;

char * err_ptr;


  /* General error handling */


  /* Make sure logged in */
  sts = VDrisIsSchemaOpen();
  if (!(sts & 1)) {
    printf("*** No Open Schema %s\n",sql);
    return 0;
  }

  /* Grab the input */
  sqlx = sql;

{RISint_prepare(&RIScpp_stmt_id1,sqlx,1,0);
if (RISget_sqlcode() != RIS_SUCCESS) goto error;}

{RISint_execute(&RIScpp_stmt_id1,0,0,7,1,0);
if (RISget_sqlcode() != RIS_SUCCESS && RISget_sqlcode() != END_OF_DATA) goto error;}

{RISint_clear(&RIScpp_stmt_id1, 0, 7);
if (RISget_sqlcode() != RIS_SUCCESS) goto error;}


  if (RISget_sqlcode() == RIS_SUCCESS) retFlag = 1;
  else {
    printf("*** SQL EXECUTE %d\n    %s\n",sql,RISget_sqlcode());
  }

  return retFlag;

error:

RISint_report_error(0,&err_ptr);

  puts(err_ptr);

  return retFlag;

}

/* -------------------------------------------
 * Silently Execute an sql statement
 */
int VDrisExecuteSilent(char *sql)
{
  int retFlag = 0;
  int sts;


char * sqlx;

char * err_ptr;


  /* General error handling */


  /* Grab the input */
  sqlx = sql;

{RISint_prepare(&RIScpp_stmt_id2,sqlx,1,0);
if (RISget_sqlcode() != RIS_SUCCESS) goto error;}

{RISint_execute(&RIScpp_stmt_id2,0,0,7,1,0);
if (RISget_sqlcode() != RIS_SUCCESS && RISget_sqlcode() != END_OF_DATA) goto error;}

{RISint_clear(&RIScpp_stmt_id2, 0, 7);
if (RISget_sqlcode() != RIS_SUCCESS) goto error;}


  if (RISget_sqlcode() == RIS_SUCCESS) retFlag = 1;

  return retFlag;

error:

  return retFlag;

}
