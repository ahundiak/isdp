#ifndef _DBADEV_H
#define _DBADEV_H

#include "dba_error.h"

/* DBA keyin modes */

#define DBA_CHANGE_ALL 		121
#define DBA_NO_OVERRIDE		123
#define DBA_ADD_QUERY 		126
#define DBA_CHANGE_ROW 		136
#define DBA_UPDATE_ACTIVE 	138
#define DBA_KEY_COLUMN 		147

/* DBA template types */

#define DBA_REPORTS 0
#define DBA_DATABASE_RPT 1
#define DBA_USERDATA_RPT 2
#define DBA_ASCII_RPT 3
#define DBA_USERDATA_STRUCTURE 4
#define DBA_ASCII_STRUCTURE 5
#define DBA_MENU 6
#define DBA_SQL 7
#define DBA_QUERY 8
#define DBA_SCRIPT 9
#define DBA_OPTIONS 10
#define DBA_ALL_TEMPLATES 100

/* DBA field types */

#define DBA_TEXT 1
#define DBA_COLUMN 2
#define DBA_DATE 3
#define DBA_TIME 4
#define DBA_PAGE 5
#define DBA_COUNTER 6
#define DBA_TOTAL 7
#define DBA_DERIVED 8

/* DBA template structure */

struct dba_template { 

  char name[21];		/* DBA template name */
  char description[51];		/* DBA template description */
  int time_val;			/* DBA template creation date/time */
  int type; };			/* DBA template type */

/* DBA default options structure */

struct dba_default_options {

  char table[32];		/* report table */
  char template_name[21];	/* DBA template name */
  char description[51];		/* DBA template description */
  char output[101];		/* output file name */
  char title[121];		/* title of report (ignored if lines == 0) */
  int subtotals;		/* 0 - no subtotal lines
                                   1-n - subtotals based on sort key 1-n */
  int totals;			/* 0 - no total lines
                                   1 - total line printed */
  int width;			/* determines columns per page */
  int lines; };			/* determines lines per page (0 for no headers,
				   no formfeeds */

/* DBA default list structure */

struct dba_default_list {

  char name[32];		/* column name */
  char header[31];		/* header for this column */
  int type;			/* field type (DBA_COLUMN or DBA_COUNTER) */
  int start;			/* field start position (relative to 1) */
  int length;			/* field length (default calculated by 
				   dba_format_default() based on column type */
  int decimal;			/* decimal places for floating point */
  int sort;			/* 0 - don't sort by this column value 
				   1-n - sequential sort key number */
  int subtotal; 		/* 0 - don't subtotal this field
				   1 - subtotal this field */
  int total; };			/* 0 - don't total this field
				   1 - total this field */

#endif /* _DBADEV_H */
