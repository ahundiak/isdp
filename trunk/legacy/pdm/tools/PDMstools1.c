#include <time.h>
#include <stdio.h>
#define		UNIX	1
#if VMS
#include <types.h>
#include <stat.h>
#endif
#if UNIX
#include <sys/types.h>
#include <sys/stat.h>
#endif

/* This was placed here due to an unresolved symbol when linking the
   PDMinit image. PDMstools1.o is included in the makeinit file and due
   to its useage of NFMRtic_it this must be defined here. */

#include "SQLerrordef.h"
#include "PDMdbs_err.h"
#include "MEMerrordef.h"
#include "MEMstruct.h"
#include "PDUerror.h"
#include "NFMerrordef.h"
#include "NETerrordef.h"
#include "PDMproto.h"

#define MAX_BUFFER_SIZE 16384
#define NOT !
#define	TRUE	1
#define FALSE	0

extern long     sqlstatus;
extern int      PDMdebug_on;
extern char     PDM_DEBUG_FILE[];
static long     status;
static char     s[1024];

PDMget_cwd(cwd)
	char          **cwd;
{
#if UNIX
	*cwd = (char *) getcwd(NULL, 80);
	strcat(*cwd, "/");
#endif

#if VMS
	*cwd = getenv("PATH");
#endif
}

int 
PDMi_get_date(c_date, c_time)
	char           *c_date;
	char           *c_time;
{
	char            date[20];
	int             k;

	PDMget_date_time(date, c_time, ":", 1);
	k = strlen(date);
	date[k - 4] = date[k - 2];
	date[k - 3] = date[k - 1];
	date[k - 2] = '\0';
	strcpy(c_date, date);
	sprintf(s, "date -> %s\n", c_date);
	PDMdebug(s);
	sprintf(s, "time -> %s\n", c_time);
	PDMdebug(s);
	return (PDM_S_SUCCESS);
}

PDMget_date_time(current_date, current_time, delimiter, format_flag)
	char           *current_date;
	char           *current_time;
	char           *delimiter;
	int             format_flag;	/* 0 = yy/mm/dd;  1 = mm/dd/yyyy  */
{
	int             i;
	int            *ptr[3];
	long            clock;
	char           *getenv();
	char           *date_format;
	char           *century = "19";
	char           *my_delimiter = "/";
	struct tm      *today;

	/* Flags  */

	int             bad_input = FALSE;
	int             M_used = FALSE;
	int             D_used = FALSE;
	int             Y_used = FALSE;

	/* Get the system date and time  */

	clock = time((long *) 0);
	today = (struct tm *) localtime(&clock);

	/* Load the current time  */

	sprintf(current_time, "%02d:%02d:%02d",
		today->tm_hour, today->tm_min, today->tm_sec);

	/* Add 1 to the month  */

	++(today->tm_mon);

	/* A zero for format flag overrides DBDATE  */

	if (format_flag == 0) {
		/* This format is used for sorting  */

		sprintf(current_date, "%02d%s%02d%s%02d", today->tm_year, delimiter,
			today->tm_mon, delimiter, today->tm_mday);

		return (PDM_S_SUCCESS);
	}
	/* See if DBDATE is defined  */

	if ((date_format = getenv("DBDATE")) != NULL) {
		/* Make sure it has something in it  */

		if ((strcmp(date_format, "")) != 0) {
			for (i = 0; i < 3; ++i) {
				if (date_format[i] == 'M') {
					if (M_used == TRUE)
						bad_input = TRUE;
					else
						ptr[i] = &(today->tm_mon);

					M_used = TRUE;
				} else if (date_format[i] == 'D') {
					if (D_used == TRUE)
						bad_input = TRUE;
					else
						ptr[i] = &(today->tm_mday);

					D_used = TRUE;
				} else if (date_format[i] == 'Y') {
					if (Y_used == TRUE)
						bad_input = TRUE;
					else
						ptr[i] = &(today->tm_year);

					Y_used = TRUE;
				} else {
					/* Unrecognized characters  */

					bad_input = TRUE;
				}
			}

			/* Check for the number of digits in the year  */

			if ((strlen(date_format)) > 3) {
				if (date_format[3] == '2')
					strcpy(century, "");
			}
			if ((strlen(date_format)) > 4) {
				my_delimiter[0] = date_format[4];
				my_delimiter[1] = NULL;
			}
			if (bad_input == FALSE) {
				sprintf(current_date, "%02d%s%02d%s%s%02d", *(ptr[0]),
					my_delimiter, *(ptr[1]), my_delimiter, century, *(ptr[2]));

				return (PDM_S_SUCCESS);
			}
		}
	}
	/* Default date format  */

	sprintf(current_date, "%02d%s%02d%s19%02d", today->tm_mon,
		delimiter, today->tm_mday, delimiter, today->tm_year);

	return (PDM_S_SUCCESS);
}


PDMcheck_for_double_quotes(s1, s2)
	char           *s1;
	char           *s2;
{
	int             i, j;
	int             number_of_quotes = 0;

	for (i = 0, j = 0; i < strlen(s2); ++i) {
		s1[j] = s2[i];
		++j;

		if (s2[i] == '"') {
			s1[j] = '"';
			++j;
			++number_of_quotes;
		}
	}

	s1[strlen(s2) + number_of_quotes] = NULL;

	return (PDM_S_SUCCESS);
}

int 
PDMgen_bomtable_name(temp_table)
	char           *temp_table;
{
	long            status;
	char            table[40];

	PDMdebug("ENTER:PDMgen_bomtable_name\n");
	status = PDMgen_file_name(table);
	if (status != PDM_S_SUCCESS) {
		sprintf(s, "%s %d\n",
			"PDMgen_table_name : failed status", status);
		PDMdebug(s);
	}
	sprintf(temp_table, "BOM_%s", table);
	PDMdebug("EXIT:PDMgen_bomtable_name\n");
	return (PDM_S_SUCCESS);
}

int 
PDMgen_table_name(temp_table)
	char           *temp_table;
{
	long            status;

	PDMdebug("ENTER:PDMgen_table_name\n");
	status = PDMgen_file_name(temp_table);
	if (status != PDM_S_SUCCESS) {
		sprintf(s, "%s %d\n",
			"PDMgen_table_name : failed status", status);
		PDMdebug(s);
	}
	PDMdebug("EXIT:PDMgen_table_name\n");
	return (PDM_S_SUCCESS);
}

int 
PDMgen_file_name(file_name)
	char           *file_name;
{
	int             i, j;
	char            cr_time[40];
	char            cr_date[40];

	cr_date[0] = '\0';
	cr_time[0] = '\0';
	file_name[0] = '\0';
	j = 0;

	PDMdebug("ENTER:PDMgen_file_name\n");
	PDMget_date_time(cr_date, cr_time, "/", 1);
	for (i = 0; i < strlen(cr_time); i++) {
		if (cr_time[i] != ':')
			file_name[j++] = cr_time[i];
	}
	for (i = 0; i < strlen(cr_date); i++) {
		if (cr_date[i] != '/')
			file_name[j++] = cr_date[i];
	}
	file_name[j] = '\0';
	sleep(5);
	PDMdebug("EXIT:PDMgen_file_name\n");
	return (PDM_S_SUCCESS);
}

/*
 * Creates table <table_name> using bufr1,bufr2 and bufr3 formats. Loads data
 * from buffers padding whenever required
 */

int PDMcreate_ris_table(table_name, bufr1, bufr2, bufr3)
	char           *table_name;
	MEMptr          bufr1;
	MEMptr          bufr2;
	MEMptr          bufr3;
{
	long            status;
	int             i, j, maxrows;
	int             size;
	char           *sql_str, *sql_str1, *sql_str2;
	char          **format_ptr1 = NULL, **format_ptr2 = NULL; 
	char	      **format_ptr3 = NULL;
	char          **column_ptr1 = NULL, **column_ptr2 = NULL; 
	char	      **column_ptr3 = NULL;
	char          **data1 = NULL, **data2 = NULL, **data3 = NULL;
        int             nxi;

	PDMdebug("ENTER : PDMcreate_ris_table \n");
	if (bufr1 == NULL && bufr2 == NULL && bufr3 == NULL) {
		PDMdebug("All the buffers are null \n");
		return (PDM_E_FAILURE);
	}
	/* Create Table */

	size = 0;
	if (bufr1 != NULL) {
                NFMRtic_it (bufr1);
		status = MEMbuild_array(bufr1);
		if (status != MEM_S_SUCCESS) {
			sprintf(s, "%s %s %d \n",
				"PDMcreate_ris_table : ",
				"MEMbuild_array failed status ",
				status);
			PDMdebug(s);
			return (status);
		}
		column_ptr1 = (char **) bufr1->column_ptr;
		format_ptr1 = (char **) bufr1->format_ptr;
		data1 = (char **) bufr1->data_ptr;
		for (i = 0; i < bufr1->columns; i++) {
			size = size + strlen(column_ptr1[i]) + 3;
			size = size + strlen(format_ptr1[i]) + 3;
		}
	}
	if (bufr2 != NULL) {
                 NFMRtic_it (bufr2);
		status = MEMbuild_array(bufr2);
		if (status != MEM_S_SUCCESS) {
			sprintf(s, "%s %s %d \n",
				"PDMcreate_ris_table : ",
				"MEMbuild_array failed status ",
				status);
			PDMdebug(s);
			return (status);
		}
		column_ptr2 = (char **) bufr2->column_ptr;
		format_ptr2 = (char **) bufr2->format_ptr;
		data2 = (char **) bufr2->data_ptr;
		for (i = 0; i < bufr2->columns; i++) {
			size = size + strlen(column_ptr2[i]) + 3;
			size = size + strlen(format_ptr2[i]) + 3;
		}
	}			/* if there is a second buffer */
	if (bufr3 != NULL) {
                 NFMRtic_it (bufr3);
		status = MEMbuild_array(bufr3);
		if (status != MEM_S_SUCCESS) {
			sprintf(s, "%s %s %d \n",
				"PDMcreate_ris_table : ",
				"MEMbuild_array failed status ",
				status);
			PDMdebug(s);
			return (status);
		}
		column_ptr3 = (char **) bufr3->column_ptr;
		format_ptr3 = (char **) bufr3->format_ptr;
		for (i = 0; i < bufr3->columns; i++) {
			size = size + strlen(column_ptr3[i]) + 3;
			size = size + strlen(format_ptr3[i]) + 3;
		}
	}			/* if there is a third buffer */
	sql_str = (char *) malloc(size + 100);
	if (sql_str == NULL) {
		PDMdebug("PDMcreate_ris_table : Failed to malloc\n");
		return (PDM_E_COULD_NOT_MALLOC);
	}
	sql_str[0] = '\0';
	sprintf(sql_str, "CREATE TABLE %s (", table_name);
	if (bufr1 != NULL) {
		for (i = 0; i < bufr1->columns; i++) {
			strcat(sql_str, column_ptr1[i]);
			strcat(sql_str, " ");
			strcat(sql_str, format_ptr1[i]);
			if (i != bufr1->columns - 1)
				strcat(sql_str, ",");
		}
	}
	if (bufr2 != NULL) {
		strcat(sql_str, ", ");
		for (i = 0; i < bufr2->columns; i++) {
			strcat(sql_str, column_ptr2[i]);
			strcat(sql_str, " ");
			strcat(sql_str, format_ptr2[i]);
			if (i != bufr2->columns - 1)
				strcat(sql_str, ",");
		}
	}
	if (bufr3 != NULL) {
		strcat(sql_str, ", ");
		for (i = 0; i < bufr3->columns; i++) {
			strcat(sql_str, column_ptr3[i]);
			strcat(sql_str, " ");
			strcat(sql_str, format_ptr3[i]);
			if (i != bufr3->columns - 1)
				strcat(sql_str, ",");
		}
	}
	strcat(sql_str, " )");
	status = SQLstmt(sql_str);
	if (status != SQL_S_SUCCESS) {
		free(sql_str);
		sprintf(s, "%s %s %d",
			"PDMcreate_ris_table : SQLstmt <CREATE TABLE> ",
			"failed status ",
			status);
		PDMdebug(s);
		return (status);
	}
	/* Figure the max no of rows */

	if (bufr1 != NULL) {
		maxrows = bufr1->rows;
	} else {
		maxrows = 0;
	}
	if (bufr2 != NULL) {
		if (maxrows < bufr2->rows) {
			maxrows = bufr2->rows;
		}
	}
	if (bufr3 != NULL) {
		if (maxrows < bufr3->rows) {
			maxrows = bufr3->rows;
		}
	}
	if (maxrows == 0) {
		free(sql_str);
		PDMdebug("EXIT:PDMcreate_ris_table\n");
		return (PDM_S_SUCCESS);
	}
	sql_str[0] = '\0';
	if (bufr1 != NULL) {
		for (i = 0; i < bufr1->columns; i++) {
			strcat(sql_str, column_ptr1[i]);
			strcat(sql_str, " ");
			if (i != bufr1->columns - 1)
				strcat(sql_str, ",");
		}
	}
	if (bufr2 != NULL) {
		strcat(sql_str, ", ");
		for (i = 0; i < bufr2->columns; i++) {
			strcat(sql_str, column_ptr2[i]);
			strcat(sql_str, " ");
			if (i != bufr2->columns - 1)
				strcat(sql_str, ",");
		}
	}
	if (bufr3 != NULL) {
		strcat(sql_str, ", ");
		for (i = 0; i < bufr3->columns; i++) {
			strcat(sql_str, column_ptr3[i]);
			strcat(sql_str, " ");
			if (i != bufr3->columns - 1)
				strcat(sql_str, ",");
		}
	}
	size = 0;
	if (bufr1 != NULL) {
		size = bufr1->row_size;
	}
	if (bufr2 != NULL) {
		size = size + bufr2->row_size;
	}
	if (bufr3 != NULL) {
		size = size + bufr3->row_size;
	}
	sql_str1 = (char *) malloc(size + 100);
	if (sql_str1 == NULL) {
		free(sql_str);
		PDMdebug("PDMcreate_ris_table : Failed to malloc\n");
		return (PDM_E_COULD_NOT_MALLOC);
	}
	sql_str2 = (char *) malloc(strlen(sql_str) + size + 200);
	if (sql_str2 == NULL) {
		free(sql_str);
		free(sql_str1);
		PDMdebug("PDMcreate_ris_table : Failed to malloc\n");
		return (PDM_E_COULD_NOT_MALLOC);
	}
	for (i = 0; i < maxrows; i++) {
		sql_str1[0] = '\0';
                nxi = i * bufr1->columns;
		if (bufr1 != NULL) {
			for (j = 0; j < bufr1->columns; j++) {
				if (!strncmp(format_ptr1[j], "char", 4)) {
					strcat(sql_str1, "'");
					strcat(sql_str1, data1[nxi + j]);
					strcat(sql_str1, "'");
				} else {
					if (strlen(data1[nxi + j]))
						strcat(sql_str1, data1[nxi + j]);
					else
						strcat(sql_str1, "null");
				}
				if (j != bufr1->columns - 1)
					strcat(sql_str1, ",");
			}
                } 
          
/* COMMENT OUT (on) -- 5/24/91

		 else {
			for (j = 0; j < bufr1->columns; j++) {
				if (!strncmp(format_ptr1[j], "char", 4)) {
					strcat(sql_str1, "'");
					strcat(sql_str1, "'");
				} else {
					strcat(sql_str1, "null");
				}
				if (j != bufr1->columns - 1)
					strcat(sql_str1, ",");
			}
		}

    COMMENT OUT (off) */

		if ((bufr1 != NULL) && ((bufr2 != NULL) || (bufr3 != NULL))){
			strcat(sql_str1, ",");
		}
		if (bufr2 != NULL) {
			for (j = 0; j < bufr2->columns; j++) {
				if (!strncmp(format_ptr2[j], "char", 4)) {
					strcat(sql_str1, "'");
					strcat(sql_str1, data2[j]);
					strcat(sql_str1, "'");
				} else {
					if (strlen(data2[j]))
						strcat(sql_str1, data2[j]);
					else
						strcat(sql_str1, "null");
				}
				if (j != bufr2->columns - 1)
					strcat(sql_str1, ",");
			}
                }

/* COMMENT OUT (on) -- 5/24/91

		 else {
			for (j = 0; j < bufr2->columns; j++) {
				if (!strncmp(format_ptr2[j], "char", 4)) {
					strcat(sql_str1, "'");
					strcat(sql_str1, "'");
				} else {
					strcat(sql_str1, "null");
				}
				if (j != bufr2->columns - 1)
					strcat(sql_str1, ",");
			}
		}

    COMMENT OUT (off) */

		if ((bufr2 != NULL) && (bufr3 != NULL)){
			strcat(sql_str1, ",");
		}
		if (bufr3 != NULL) {
			for (j = 0; j < bufr3->columns; j++) {
				if (!strncmp(format_ptr3[j], "char", 4)) {
					strcat(sql_str1, "'");
					strcat(sql_str1, data3[j]);
					strcat(sql_str1, "'");
				} else {
					if (strlen(data3[j]))
						strcat(sql_str1, data3[j]);
					else
						strcat(sql_str1, "null");
				}
				if (j != bufr3->columns - 1)
					strcat(sql_str1, ",");
			}
               }

/*  COMMENT OUT (on) -- 5/24/91

		 else {
			for (j = 0; j < bufr3->columns; j++) {
				if (!strncmp(format_ptr3[j], "char", 4)) {
					strcat(sql_str1, "'");
					strcat(sql_str1, "'");
				} else {
					strcat(sql_str1, "null");
				}
				if (j != bufr3->columns - 1)
					strcat(sql_str1, ",");
			}

		}

    COMMENT OUT (off) */

		sprintf(sql_str2, "INSERT INTO %s (%s) VALUES(%s)",
			table_name, sql_str, sql_str1);
		status = SQLstmt(sql_str2);
		if (status != SQL_S_SUCCESS) {
			free(sql_str);
			free(sql_str1);
			free(sql_str2);
			return (status);
		}
	}
	free(sql_str);
	free(sql_str1);
	free(sql_str2);
	PDMdebug("EXIT : PDMcreate_ris_table \n");
	return (PDM_S_SUCCESS);
}

/* returns p_attached from pdmcit of p_citno */

int PDMquery_cit_attachment(p_citno, p_attached)
	long            p_citno;
	char           *p_attached;
{
	MEMptr          bufr = NULL;
	char            sql_str[512];
	char          **data;
	char		*fn = "PDMquery_cit_attachment";

	PDMdebug("ENTER:PDMquery_cit_attachment\n");
	sql_str[0] = '\0';
	sprintf(sql_str, "%s %s %d",
		"SELECT p_attached FROM pdmcit ",
		"WHERE p_citno = ", p_citno);
	status = SQLquery(sql_str, &bufr, 512);
	if (status != SQL_S_SUCCESS) {
		if (status == SQL_I_NO_ROWS_FOUND) {
			MEMclose(&bufr);
			_PDMdebug (fn, "p_citno <%d> in pdmcit is not found\n",
				p_citno);
			return (PDM_E_FAILURE);
		} else {
			return (PDM_E_SQL_QUERY);
		}
	}
	status = MEMbuild_array(bufr);
	if (status != MEM_S_SUCCESS) {
		MEMclose(&bufr);
		_PDMdebug (fn, "MEMbuild_array failed status %d\n", status);
		return (PDM_E_BUILD_ARRAY);
	}
	data = (char **) bufr->data_ptr;
	strcpy(p_attached, data[0]);
        _PDMdebug (fn, "p_attached = %s\n", p_attached );
	MEMclose(&bufr);
	PDMdebug("EXIT:PDMquery_cit_attachment\n");
	return (PDM_S_SUCCESS);
}

int PDMquery_bom_attachment(review_bom, n_itemname, n_itemrev, catalog, level, p_attached)
	char           *review_bom;
	char           *n_itemname;
	char           *n_itemrev;
	char           *catalog;
	int             level;
	char           *p_attached;
{
	MEMptr          bufr = NULL;
	char            sql_str[512];
	char          **data;

	PDMdebug("ENTER:PDMquery_bom_attachment\n");
	sql_str[0] = '\0';
	sprintf(sql_str, "%s %s %s '%s' %s '%s' %s '%s' %s %d",
		"SELECT p_attached FROM ", review_bom,
		"WHERE n_catalogname =", catalog,
		"AND  n_itemname = ", n_itemname,
		"AND n_itemrev = ", n_itemrev,
		"AND p_level = ", level);
	status = SQLquery(sql_str, &bufr, 512);
	if (status != SQL_S_SUCCESS) {
		if (status == SQL_I_NO_ROWS_FOUND) {
			MEMclose(&bufr);
			return (PDM_E_FAILURE);
		} else {
			return (PDM_E_SQL_QUERY);
		}
	}
	status = MEMbuild_array(bufr);
	if (status != MEM_S_SUCCESS) {
		MEMclose(&bufr);
		sprintf(s, "MEMbuild_array failed status %d\n", status);
		PDMdebug(s);
		return (PDM_E_BUILD_ARRAY);
	}
	data = (char **) bufr->data_ptr;
	strcpy(p_attached, data[0]);
	MEMclose(&bufr);
	PDMdebug("EXIT:PDMquery_bom_attachment\n");
	return (PDM_S_SUCCESS);
}


int PDMi_delete_rows(buffer, table_name, n)
	MEMptr          buffer;
	char           *table_name;
	int             n;
{
	char          **data, **format, **column;
	char            s1[200], sql_str[300];
	int             nx, i;

	PDMdebug("ENTER:PDMi_delete_rows\n");
	status = MEMbuild_array(buffer);
	if (status != MEM_S_SUCCESS) {
		sprintf(s, "MEMbuild_array  failed status %d\n",
			status);
		PDMdebug(s);
		return (PDM_E_BUILD_ARRAY);
	}
	data = (char **) buffer->data_ptr;
	column = (char **) buffer->column_ptr;
	format = (char **) buffer->format_ptr;
	sprintf(s, "DELETE FROM %s WHERE %s = ",
		table_name, column[n]);
	if (!strncmp(format[n], "char", 4)) {
		for (i = 0; i < buffer->rows; i++) {
			nx = i * buffer->columns;
			sprintf(sql_str, "%s '%s'",
				s1, data[nx + n]);
			status = SQLstmt(sql_str);
			if (status != SQL_S_SUCCESS) {
			}
		}
	} else {
		for (i = 0; i < buffer->rows; i++) {
			nx = i * buffer->columns;
			sprintf(sql_str, "%s %s",
				s1, data[nx + n]);
			status = SQLstmt(sql_str);
			if (status != SQL_S_SUCCESS) {
			}
		}
	}
	PDMdebug("EXIT:PDMi_delete_rows\n");
	return (PDM_S_SUCCESS);
}


int PDMi_query_passwd(username, passwd)
	char           *username;
	char           *passwd;
{
	MEMptr          bufr = NULL;
	char            sql_str[200];
	char          **data;

	PDMdebug("ENTER:PDMi_query_passwd\n");
	sprintf(sql_str, "%s %s '%s'",
		"SELECT n_passwd FROM nfmusers ",
		"WHERE n_username = ", username);
	status = SQLquery(sql_str, &bufr, 512);
	if (status != SQL_S_SUCCESS) {
		MEMclose(&bufr);
		if (status == SQL_I_NO_ROWS_FOUND) {
			sprintf(s,
			   "No entry found with username <%s>\n", username);
			PDMdebug(s);
			return (PDM_E_USERNAME_NOT_FOUND);
		}
		sprintf(s, "SQLquery failed status %d\n", status);
		PDMdebug(s);
		return (PDM_E_SQL_QUERY);
	}
	status = MEMbuild_array(bufr);
	if (status != MEM_S_SUCCESS) {
		MEMclose(&bufr);
		sprintf(s, "MEMbuild_array failed status %d\n",
			status);
		PDMdebug(s);
		return (PDM_E_BUILD_ARRAY);
	}
	data = (char **) bufr->data_ptr;
	status = NFMdecrypt(data[0], passwd);
	if (status != NFM_S_SUCCESS) {
		MEMclose(&bufr);
		sprintf(s, "NFMdecrypt faile status %d\n", status);
		PDMdebug(s);
		return (status);
	}
	MEMclose(&bufr);
	PDMdebug("EXIT:PDMi_query_passwd\n");
	return (PDM_S_SUCCESS);
}

/*
 * Deletes entry in pdmwsfiles if and only if there is no refernce to it in
 * pdmfmgr
 */

int PDMi_delete_fileno(p_fileno)
	char           *p_fileno;
{
	char            sql_str[200];
	MEMptr          bufr = NULL;

	PDMdebug("ENTER:PDMi_delete_fileno \n");
	sprintf(sql_str, "%s %d",
	"SELECT n_itemname  FROM pdmfmgr WHERE p_fileno = ", atol(p_fileno));
	status = SQLquery(sql_str, &bufr, 512);
	if (status != SQL_S_SUCCESS) {
		MEMclose(&bufr);
		if (status == SQL_I_NO_ROWS_FOUND) {
			sprintf(sql_str, "%s %d",
				"DELETE FROM pdmwsfiles WHERE p_fileno = ", atol(p_fileno));
			status = SQLstmt(sql_str);
			if (status != SQL_S_SUCCESS) {
				sprintf(s, "SQLstmt failed status %d \n", status);
				PDMdebug(s);
				sprintf(s, "%s <%d>\n",
				    "Failed to delete entry in pdmwsfiles ",
					atoi(p_fileno));
				PDMdebug(s);
				return (PDM_E_SQL_STMT);
			}
			PDMdebug("EXIT:PDMi_delete_fileno \n");
			return (PDM_S_SUCCESS);
		}
		return (PDM_E_SQL_QUERY);
	}
	PDMdebug("EXIT:PDMi_delete_fileno \n");
	return (PDM_S_SUCCESS);
}

/*
 * Deletes entry in pdmwsparts if and only if there is no refernce to it in
 * pdmfmgr
 */

int PDMi_delete_partnum(n_itemname)
	char           *n_itemname;
{
	MEMptr          bufr = NULL;
	char            sql_str[200];

	PDMdebug("ENTER:PDMi_delete_partnum \n");
	sprintf(sql_str, "%s %d",
		"SELECT n_itemname  FROM pdmfmgr WHERE n_itemname = ", atol(n_itemname));
	status = SQLquery(sql_str, &bufr, 512);
	if (status != SQL_S_SUCCESS) {
		MEMclose(&bufr);
		if (status == SQL_I_NO_ROWS_FOUND) {
			sprintf(sql_str, "%s %d",
				"DELETE FROM pdmwsparts WHERE n_itemname = ", atol(n_itemname));
			status = SQLstmt(sql_str);
			if (status != SQL_S_SUCCESS) {
				sprintf(s, "SQLstmt failed status %d \n", status);
				PDMdebug(s);
				sprintf(s, "%s <%d>\n",
				    "Failed to delete entry in pdmwsparts ",
					atoi(n_itemname));
				PDMdebug(s);
				return (PDM_E_SQL_STMT);
			}
			PDMdebug("EXIT:PDMi_delete_partnum\n");
			return (PDM_S_SUCCESS);
		}
		return (PDM_E_SQL_QUERY);
	}
	MEMclose(&bufr);
	PDMdebug("EXIT:PDMi_delete_partnum \n");
	return (PDM_S_SUCCESS);
}

int PDMcofilename(cofilename)
   char *cofilename;
{
   int          x = 0, y = 0, z = 0;
   int 		tmp_file;
   char		sql_str[512];
   char         filename[15];
   char         leadzero[15];
   char   	**data;
   MEMptr	bufr = NULL;

	PDMdebug("ENTER:PDMgenerate_filename \n");
	sprintf(sql_str,"SELECT p_cofilename FROM pdmfilename\n");
	status = SQLquery(sql_str,&bufr,512);
	if (status != SQL_S_SUCCESS)
	{
		sprintf(s,"SQLstmt failed status %d\n",status);
		PDMdebug(s);
		PDMdebug("sql string :");
		PDMdebug(sql_str); 
		PDMdebug("\n");
		return(PDM_E_SQL_STMT);
	}
	status = MEMbuild_array(bufr);
	if (status != MEM_S_SUCCESS)
	{
		sprintf(s,"MEMbuild_array failed status %d\n",status);
		PDMdebug(s);
		MEMclose(&bufr);
		return(PDM_E_BUILD_ARRAY);
	}
	data = (char **) bufr->data_ptr;
	strcpy(filename, data[0]);
	strcpy(cofilename, data[0]);
	tmp_file = atoi(filename);
	++tmp_file;
	sprintf(filename,"%d",tmp_file);
 
/* This section facilitates the placement of leading zeros in front of the
   system generated filename/number */
  
        x = strlen(filename);
        if ((y = (14 - x)) > 0) 
        {
        	for (z = 0; z < y; ++z)
			leadzero[z] = '0';
        }
        leadzero[z] = '\0';
        strcat(leadzero,filename);
	sql_str[0] = '\0';
	sprintf(sql_str,"UPDATE pdmfilename SET p_cofilename = '%s'\n",leadzero);
	status = SQLstmt(sql_str);
	if (status != SQL_S_SUCCESS)
	{
		sprintf(s,"SQLstmt failed status %d\n",status);
		PDMdebug(s);
		PDMdebug("sql string :");
		PDMdebug(sql_str);
		PDMdebug("\n");
		return(PDM_E_SQL_STMT);
	}
        if (PDMdebug_on)
          MEMprint_buffer("PDMFILENAME :",bufr,PDM_DEBUG_FILE);
	PDMdebug("EXIT:PDMgenerate_filename\n");
	return(PDM_S_SUCCESS);

}


int PDMcheck_for_autofilename(cat)
 char *cat;
{
   int catno;
   char		sql_str[512];
   char   	**data;
   MEMptr	bufr = NULL;

	PDMdebug("ENTER:PDMgenerate_filename \n");
          PDMris_get_catno(cat,&catno);
	sprintf(sql_str,"SELECT p_autofilename FROM pdmcatalogs WHERE n_catalogno = %d",catno);
	status = SQLquery(sql_str,&bufr,512);
	if (status != SQL_S_SUCCESS)
	{
		sprintf(s,"SQLstmt failed status %d\n",status);
		PDMdebug(s);
		PDMdebug("sql string :");
		PDMdebug(sql_str); 
		PDMdebug("\n");
		return(PDM_E_SQL_STMT);
	}
	status = MEMbuild_array(bufr);
	if (status != MEM_S_SUCCESS)
	{
		sprintf(s,"MEMbuild_array failed status %d\n",status);
		PDMdebug(s);
		MEMclose(&bufr);
		return(PDM_E_BUILD_ARRAY);
	}
	data = (char **) bufr->data_ptr;
         if(!strcmp(data[0],"Y") || !strcmp(data[0],"y")) 
         {
           MEMclose(&bufr);
	PDMdebug("EXIT:PDMgenerate_filename - YES\n");
	return(PDM_S_SUCCESS);
         }
          else
         {
           MEMclose(&bufr);
	PDMdebug("EXIT:PDMgenerate_filename-NO\n");
	return(PDM_E_SQL_STMT);
         }
         

}

