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

#include "SQLerrordef.h"
#include "PDMdbs_err.h"
#include "MEMerrordef.h"
#include "MEMstruct.h"
#include "PDUerror.h"
#include "NFMerrordef.h"
#include "PDMproto.h"

extern int      PDMdebug_on;
extern char     PDM_DEBUG_FILE[];
static long     status;
static char     s[1024];
extern PDMexec_ptr PDMexec;


int 
PDMi_find_nodeno(n_nodename, n_nodeno)
	char           *n_nodename;
	int            *n_nodeno;
{
	MEMptr          bufr = NULL;
	char            sql_str[1024];
	char          **data;

	PDMdebug("ENTER:PDMi_find_nodeno\n");
        sql_str[0] = '\0';
	*n_nodeno = -1;
	sprintf(sql_str, "%s %s '%s'",
		"SELECT n_nodeno FROM nfmnodes ",
		"WHERE n_nodename = ", n_nodename);
	status = SQLquery(sql_str, &bufr, 1024);
	if (status != SQL_S_SUCCESS) {
		MEMclose(&bufr);
		if (status == SQL_I_NO_ROWS_FOUND) {
			return (status);
		}
		sprintf(s, "SQLquery failed status %d\n",
			status);
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
	*n_nodeno = atoi(data[0]);
	MEMclose(&bufr);
	PDMdebug("EXIT:PDMi_find_nodeno\n");
	return (PDM_S_SUCCESS);
}

int 
PDMi_find_partnum(n_catalogno, n_itemno, n_itemname)
	int             n_catalogno;
	int             n_itemno;
	int            *n_itemname;
{
	MEMptr          bufr = NULL;
	char            sql_str[1024];
	char          **data;

	PDMdebug("ENTER:PDMi_find_partnum\n");

        sql_str[0] = '\0';
	sprintf(sql_str, "%s %s %d %s %d ",
		"SELECT n_itemname FROM pdmwsparts ",
		"WHERE n_catalogno = ", n_catalogno,
		"AND n_itemno = ", n_itemno);
	status = SQLquery(sql_str, &bufr, 1024);
	if (status != SQL_S_SUCCESS) {
		MEMclose(&bufr);
		if (status == SQL_I_NO_ROWS_FOUND) {
			return (PDM_I_NO_ROWS_FOUND);
		}
		sprintf(s, "SQLquery failed status %d\n",
			status);
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
	*n_itemname = atoi(data[0]);
	MEMclose(&bufr);
	PDMdebug("EXIT:PDMi_find_partnum\n");
	return (PDM_S_SUCCESS);
}

int 
PDMi_find_fileno(n_itemname, p_sano, p_fileno)
	int             n_itemname;
	int             p_sano;
	int            *p_fileno;
{
	MEMptr          bufr = NULL;
	char            sql_str[512];
	char          **data;

	PDMdebug("ENTER:PDMi_find_fileno\n");
        sql_str[0] = '\0';
	sprintf(sql_str, "%s %s %d %s %d ",
		"SELECT p_fileno FROM pdmfmgr ",
		"WHERE n_itemname = ", n_itemname,
		"AND p_sano = ", p_sano);
	status = SQLquery(sql_str, &bufr, 1024);
	if (status != SQL_S_SUCCESS) {
		MEMclose(&bufr);
		if (status == SQL_I_NO_ROWS_FOUND) {
			return (PDM_I_NO_ROWS_FOUND);
		}
		sprintf(s, "SQLquery failed status %d\n",
			status);
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
	*p_fileno = atoi(data[0]);
	MEMclose(&bufr);
	PDMdebug("EXIT:PDMi_find_fileno\n");
	return (PDM_S_SUCCESS);
}

int 
PDMi_find_filenos(n_itemname, p_sano, bufr)
	int             n_itemname;
	int             p_sano;
	MEMptr         *bufr;
{
	char            sql_str[512];

	PDMdebug("ENTER:PDMi_find_filenos\n");

        sql_str[0] = '\0';
	sprintf(sql_str, "%s %s %d %s %d ",
		"SELECT p_fileno FROM pdmfmgr ",
		"WHERE n_itemname = ", n_itemname,
		"AND p_sano = ", p_sano);
	status = SQLquery(sql_str, bufr, 1024);
	if (status != SQL_S_SUCCESS) {
		MEMclose(bufr);
		if (status == SQL_I_NO_ROWS_FOUND) {
			return (PDM_I_NO_ROWS_FOUND);
		}
		sprintf(s, "SQLquery failed status %d\n",
			status);
		PDMdebug(s);
		return (PDM_E_SQL_QUERY);
	}
	PDMdebug("EXIT:PDMi_find_filenos\n");
	return (PDM_S_SUCCESS);
}

int 
PDMi_find_references(n_itemname, p_sano,
		     p_ref1, p_ref2)
	int             n_itemname;
	int             p_sano;
	int            *p_ref1;
	int            *p_ref2;
{
	MEMptr          bufr = NULL;
	char            sql_str[1024];
	char          **data;

	PDMdebug("ENTER:PDMi_find_references\n");
        sql_str[0] = '\0';
	sprintf(sql_str, "%s %s %d %s %d ",
		"SELECT p_ref1, p_ref2 FROM pdmfmgr ",
		"WHERE p_sano = ", p_sano,
		"AND n_itemname = ", n_itemname);
	status = SQLquery(sql_str, &bufr, 1024);
	if (status != SQL_S_SUCCESS) {
		MEMclose(&bufr);
		if (status == SQL_I_NO_ROWS_FOUND) {
			return (PDM_I_NO_ROWS_FOUND);
		}
		sprintf(s, "SQLquery failed status %d\n",
			status);
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
	*p_ref1 = atoi(data[0]);
	*p_ref2 = atoi(data[1]);
	MEMclose(&bufr);
	PDMdebug("EXIT:PDMi_find_references\n");
	return (PDM_S_SUCCESS);
}

int PDMi_find_allrefs(n_itemname, p_sano, p_ref1, p_ref2)
	int             n_itemname;
	int             p_sano;
	int            *p_ref1;
	int            *p_ref2;
{
	MEMptr          bufr = NULL;
	char            sql_str[1024];
	char          **data;

	PDMdebug("ENTER:PDMi_find_allrefs\n");
        sql_str[0] = '\0';
	sprintf(sql_str, "%s %s %d %s %d ",
		"SELECT p_ref1,p_ref2 FROM pdmfmgr ",
		"WHERE p_sano = ", p_sano,
		"AND n_itemname = ", n_itemname);
	status = SQLquery(sql_str, &bufr, 1024);
	if (status != SQL_S_SUCCESS) {
		MEMclose(&bufr);
		if (status == SQL_I_NO_ROWS_FOUND) {
			return (PDM_I_NO_ROWS_FOUND);
		}
		sprintf(s, "SQLquery failed status %d\n",
			status);
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
	if (strlen(data[0])) {
		*p_ref1 = atol(data[0]);
	} else {
		*p_ref1 = 0;
	}
	if (strlen(data[1])) {
		*p_ref2 = atol(data[1]);
	} else {
		*p_ref2 = 0;
	}
	MEMclose(&bufr);
	PDMdebug("EXIT:PDMi_find_allrefs\n");
	return (PDM_S_SUCCESS);
}

int PDMi_update_references(n_itemname, p_sano, p_type)
	int             n_itemname;
	int             p_sano;
	int             p_type;
{
	int             p_ref1, p_ref2;
	char            sql_str[512];
	MEMptr          filenos = NULL;
	int             i;
	char          **data;

	PDMdebug("ENTER:PDMi_update_references\n");
        sql_str[0] = '\0';
	if (p_type != 1 && p_type != 2) {
		sprintf(s, "Unknown p_type <%d> \n", p_type);
		return (PDM_E_FAILURE);
	}
	status = PDMi_find_allrefs(n_itemname, p_sano, &p_ref1, &p_ref2);
	if (status != PDM_S_SUCCESS) {
		sprintf(s, "PDMi_find_allrefs failed status %d\n",
			status);
		PDMdebug(s);
		return (status);
	}
	/* there are no references to this part on WS */

	if (p_ref2 == 0) {
		status = PDMi_find_filenos(n_itemname, p_sano, &filenos);
		if (status != PDM_S_SUCCESS) {
			sprintf(s, "PDMi_find_filenos failed status %d\n",
				status);
			PDMdebug(s);
			return (status);
		}
		status = MEMbuild_array(filenos);
		if (status != MEM_S_SUCCESS) {
			MEMclose(&filenos);
			sprintf(s, "MEMbuild_array failed status %d\n",
				status);
			PDMdebug(s);
			return (PDM_E_BUILD_ARRAY);
		}
		sprintf(sql_str, "%s %d",
		    "DELETE FROM pdmwsparts WHERE n_itemname = ", n_itemname);
		status = SQLstmt(sql_str);
		if (status != SQL_S_SUCCESS) {
			sprintf(s, "SQLstmt failed status %d\n", status);
			PDMdebug(s);
			sprintf(s, "Could not delete from pdmwsparts \n");
			PDMdebug(s);
		}
		sprintf(sql_str, "%s %d %s %d",
			"DELETE FROM pdmfmgr WHERE n_itemname = ", n_itemname,
			"AND p_sano = ", p_sano);
		status = SQLstmt(sql_str);
		if (status != SQL_S_SUCCESS) {
			sprintf(s, "SQLstmt failed status %d\n", status);
			PDMdebug(s);
			sprintf(s, "Could not delete from pdmfmgr \n");
			PDMdebug(s);
		}
		data = (char **) filenos->data_ptr;
		for (i = 0; i < filenos->rows; i++) {
			sprintf(sql_str, "%s %s",
			"DELETE FROM pdmwsfiles WHERE p_fileno = ", data[i]);
			status = SQLstmt(sql_str);
			if (status != SQL_S_SUCCESS) {
				sprintf(s, "SQLstmt failed status %d\n", status);
				PDMdebug(s);
				sprintf(s, "Could not delete from pdmwsfiles \n");
				PDMdebug(s);
			}
		}
		MEMclose(&filenos);
	}
        else 
            if (p_ref2 > 0)
                {
		sprintf(sql_str, "%s %d %s %d",
                "UPDATE pdmfmgr SET p_ref1 = 0 WHERE n_itemname = ",n_itemname,
                "AND p_sano = ",p_sano);
		status = SQLstmt(sql_str);
		if (status != SQL_S_SUCCESS) {
			sprintf(s, "SQLstmt failed status %d\n", status);
			PDMdebug(s);
			sprintf(s, "Could not update the pdmfmgr \n");
			PDMdebug(s);
		}
               }
                    
	PDMdebug("EXIT:PDMi_update_references\n");
	return (PDM_S_SUCCESS);
}

int PDMi_next_negativeno(table, p_citno)
	char           *table;
	int            *p_citno;
{
	MEMptr          bufr = NULL;
	char            sql_str[512];
	char          **data;

	PDMdebug("ENTER:PDMi_next_negativeno\n");
        sql_str[0] = '\0';
	sprintf(sql_str, "%s %s",
		"SELECT MIN(p_citno) FROM ", table);
	status = SQLquery(sql_str, &bufr, 512);
	if (status != SQL_S_SUCCESS) {
		MEMclose(&bufr);
		if (status == SQL_I_NO_ROWS_FOUND) {
			*p_citno = -1;
			PDMdebug("EXIT:PDMi_next_negativeno\n");
			return (PDM_S_SUCCESS);
		}
		sprintf(s, "SQLquery failed status %d\n",
			status);
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
	*p_citno = atol(data[0]);
	MEMclose(&bufr);
	*p_citno = *p_citno - 1;
	PDMdebug("EXIT:PDMi_next_negativeno\n");
        return(PDM_S_SUCCESS);
}

int PDMi_find_sano(n_nodeno, n_username, n_pathname, n_sano)
	int             n_nodeno;
	char           *n_username;
	char           *n_pathname;
	int            *n_sano;
{
	MEMptr          bufr = NULL;
	char            sql_str[1024];
	char          **data;

	PDMdebug("ENTER:PDMi_find_sano\n");
	*n_sano = -1;
        sql_str[0] = '\0';
	sprintf(sql_str, "%s %s %d %s '%s' %s '%s'",
		"SELECT n_sano FROM nfmstoragearea ",
		"WHERE n_nodeno = ", n_nodeno,
		"AND n_username = ", n_username,
		"AND n_pathname = ", n_pathname);
	status = SQLquery(sql_str, &bufr, 1024);
	if (status != SQL_S_SUCCESS) {
		MEMclose(&bufr);
		if (status == SQL_I_NO_ROWS_FOUND) {
			return (PDM_I_NO_SAREA_FOUND);
		}
		sprintf(s, "SQLquery failed status %d\n",
			status);
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
	*n_sano = atoi(data[0]);
	MEMclose(&bufr);
	PDMdebug("EXIT:PDMi_find_sano\n");
	return (PDM_S_SUCCESS);
}

int PDMi_copy_format(bufr1, bufr2)
	MEMptr          bufr1;
	MEMptr         *bufr2;
{
	int             i;
	char          **column, **format;

	PDMdebug("ENTER:PDMi_copy_format\n");
	status = MEMbuild_array(bufr1);
	if (status != MEM_S_SUCCESS) {
		sprintf(s, "MEMbuild_array failed status %d\n", status);
		PDMdebug(s);
		return (PDM_E_BUILD_ARRAY);
	}
	status = MEMopen(bufr2, 1024);
	if (status != MEM_S_SUCCESS) {
		sprintf(s, "MEMopen failed status %d\n", status);
		PDMdebug(s);
		return (PDM_E_OPEN_BUFFER);
	}
	format = (char **) bufr1->format_ptr;
	column = (char **) bufr1->column_ptr;
	for (i = 0; i < bufr1->columns; i++) {
		status = MEMwrite_format(*bufr2, column[i], format[i]);
		if (status != MEM_S_SUCCESS) {
			MEMclose(bufr2);
			sprintf(s, "MEMwrite_format failed status %d\n", status);
			PDMdebug(s);
			return (PDM_E_WRITE_FORMAT);
		}
	}
	PDMdebug("EXIT:PDMi_copy_format\n");
	return (PDM_S_SUCCESS);
}


/*
 * compares <date1,time1> with <date2,time2> returns -> 0 if equal returns ->
 * 1 if <date1,time1> is before <date2,time2> returns -> 2 if <date1,time1>
 * is after <date2,time2>
 * 
 * date -> month:day:year time -> hours:minutes:seconds
 */

int PDMi_compare_dates(date1, date2)
	char           *date1;
	char           *date2;
{
	int             a1, a2;
	char            t_s[3];

	PDMdebug("ENTER:PDMi_compare_dates:\n");

	sprintf(s, "<date1>  <%s!>\n", date1);
	PDMdebug(s);
	sprintf(s, "<date2>  <%s!!>\n", date2);
	PDMdebug(s);

	/* check format */

	if (strlen(date1) < 19  ||
	    strlen(date2) < 19 ) {
		PDMdebug("Incorrect formats \n");
		return (-1);
	}
	/* compare years */

	t_s[0] = date1[2];
	t_s[1] = date1[3];
	t_s[2] = '\0';
	a1 = atoi(t_s);

	t_s[0] = date2[2];
	t_s[1] = date2[3];
	t_s[2] = '\0';
	a2 = atoi(t_s);

	if (a1 < a2) {
		return (1);
	} else if (a1 > a2) {
		return (2);
	}
	/* compare months */

	t_s[0] = date1[5];
	t_s[1] = date1[6];
	t_s[2] = '\0';
	a1 = atoi(t_s);

	t_s[0] = date2[5];
	t_s[1] = date2[6];
	t_s[2] = '\0';
	a2 = atoi(t_s);

	if (a1 < a2) {
		return (1);
	} else if (a1 > a2) {
		return (2);
	}
	/* compare days */

	t_s[0] = date1[8];
	t_s[1] = date1[9];
	t_s[2] = '\0';
	a1 = atoi(t_s);

	t_s[0] = date2[8];
	t_s[1] = date2[9];
	t_s[2] = '\0';
	a2 = atoi(t_s);

	if (a1 < a2) {
		return (1);
	} else if (a1 > a2) {
		return (2);
	}
	/* compare hours */

	t_s[0] = date1[11];
	t_s[1] = date1[12];
	t_s[2] = '\0';
	a1 = atoi(t_s);

	t_s[0] = date2[11];
	t_s[1] = date2[12];
	t_s[2] = '\0';
	a2 = atoi(t_s);

	if (a1 < a2) {
		return (1);
	} else if (a1 > a2) {
		return (2);
	}
	/* compare mins */

	t_s[0] = date1[14];
	t_s[1] = date1[15];
	t_s[2] = '\0';
	a1 = atoi(t_s);

	t_s[0] = date2[14];
	t_s[1] = date2[15];
	t_s[2] = '\0';
	a2 = atoi(t_s);

	if (a1 < a2) {
		return (1);
	} else if (a1 > a2) {
		return (2);
	}
	/* compare seconds */

	t_s[0] = date1[17];
	t_s[1] = date1[18];
	t_s[2] = '\0';
	a1 = atoi(t_s);

	t_s[0] = date2[17];
	t_s[1] = date2[18];
	t_s[2] = '\0';
	a2 = atoi(t_s);

	if (a1 < a2) {
		return (1);
	} else if (a1 > a2) {
		return (2);
	}
	return (0);
}

int PDMi_update_attachments(n_itemname, p_sano)
	int             n_itemname;
	int             p_sano;
{
	int             p_ref1, p_ref2;
	char            sql_str[512];

	PDMdebug("ENTER:PDMi_update_attachments\n");
	status = PDMi_find_allrefs(n_itemname, p_sano, &p_ref1, &p_ref2);
	if (status != PDM_S_SUCCESS) {
		sprintf(s, "PDMi_find_allrefs failed status %d\n",
			status);
		PDMdebug(s);
		return (status);
	}
	if (p_ref2 != 0) {
		p_ref2 = p_ref2 - 1;
	}
        sql_str[0] = '\0';
	p_ref1 = p_ref1;
	sprintf(sql_str, "%s %d ,%s %d %s %d %s %d ",
		"UPDATE pdmfmgr SET p_ref2 = ", p_ref2, "p_ref1 = ", p_ref1,
		"WHERE p_sano = ", p_sano,
		"AND n_itemname = ", n_itemname);
	status = SQLstmt(sql_str);
	if (status != SQL_S_SUCCESS) {
		sprintf(s, "SQLstmt failed status %d\n",
			status);
		PDMdebug(s);
		return (PDM_E_SQL_STMT);
	}
	PDMdebug("EXIT:PDMi_update_attachments\n");
	return (PDM_S_SUCCESS);
}

int PDMsano_to_name
 (
	int             n_sano,
	char           *p_local
 )
{
	MEMptr          bufr = NULL;
	char            sql_str[512];
        char            path[94];
        char            *fname = "PDMsano_to_name";
	char          **data;

	_PDMdebug(fname,"ENTER:\n");
        sql_str[0] = '\0';
	sprintf(sql_str,"SELECT t2.n_nodename, t1.n_pathname FROM  nfmstoragearea t1, nfmnodes t2  WHERE t1.n_sano = %d AND t1.n_nodeno = t2. n_nodeno ", n_sano);
	status = SQLquery(sql_str, &bufr, 512);
	if (status != SQL_S_SUCCESS) {
		MEMclose(&bufr);
                 strcpy(p_local, "OUT ELSEWHERE");
		return (PDM_S_SUCCESS);
	}
	status = MEMbuild_array(bufr);
	if (status != MEM_S_SUCCESS) {
		MEMclose(&bufr);
	_PDMdebug(fname, "MEMbuild_array failed status %d\n", status);
		return (PDM_E_BUILD_ARRAY);
	}
	data = (char **) bufr->data_ptr;
         strncpy(path,data[1],93);
         sprintf(p_local,"OUT@%s:%s",data[0],path);
	MEMclose(&bufr);
	_PDMdebug(fname,"EXIT:\n");
	return (PDM_S_SUCCESS);
}

/* The following two functions were added to support OSpace
   update after creating assy nongraphically. If the
   database (CIT) is updated and OS is not then the p_incpartrpt
   is set to "U" and once it is updated, it is reset to "".
                                                    Kumar (MaC 052793) */

int PDMcheck_to_update()
{
 char *fname = "PDMcheck_to_update";
 char sql_str[250];

  _PDMdebug(fname,"ENTER:\n");

        sql_str[0] = '\0';
  sprintf(sql_str,"UPDATE %s SET p_incpartrpt = ' ' where n_itemname = '%s' and n_itemrev = '%s' and p_incpartrpt = 'U'",PDMexec->catalog, PDMexec->part_num,PDMexec->revision);
    status = SQLstmt(sql_str);
      if(status != SQL_S_SUCCESS)
     {
       if(status == SQL_I_NO_ROWS_FOUND)
       {
      _PDMdebug(fname,"EXIT-SUCCESS - NO NEED TO UPDATE STRUCTURE\n");
        return(0);
        }
       else
        {
         _PDMdebug(fname,"No such part\n");
         return(PDM_E_PART_NOT_FOUND);
         }
       }
      _PDMdebug(fname,"EXIT-SUCCESS - UPDATE STRUCTURE\n");
       return(1);
}


int PDMupdate_to_define()
{
 char *fname = "PDMupdate_to_define";
 char sql_str[250];

  _PDMdebug(fname,"ENTER:\n");

        sql_str[0] = '\0';
  sprintf(sql_str,"UPDATE %s SET p_incpartrpt = 'U' where n_itemname = '%s' and n_itemrev = '%s'",PDMexec->catalog, PDMexec->part_num,PDMexec->revision);
    status = SQLstmt(sql_str);
      if(status != SQL_S_SUCCESS)
     {
       if(status == SQL_I_NO_ROWS_FOUND)
       {
      _PDMdebug(fname,"EXIT-SUCCESS - NO SUCH PART\n");
         return(PDM_E_PART_NOT_FOUND);
        }
       else
        {
         _PDMdebug(fname,"No such part\n");
         return(status);
         }
       }
      _PDMdebug(fname,"EXIT-SUCCESS - UPDATED STRUCTURE\n");
       return(0);
}


      
      

   

 /* There is a problem if the user checked out/activated and then
    did a cancel part checkout. Now, neither db or os has the
    knowledge. To offset this, the following alg is followed:
    1. User creates assy nongraphically, CIT is updated and
       p_incpartrpt is set to "U"
    2. User brings the part local, activates and PDU queries for this
       flag; since it is set to "U", updates the OS. Then PDU 
       updates p_incpartrpt to "P". 
    3. If update is successful, during checkin, PDU updates 
       p_incpartrpt to "".
    4. If the user does a cancel part checkout, PDM checks to see
       if the flag is set to "P". If it is, it is updated back
       to "U" so that the next activation still updates the 
       the OS.
                                                    MaC (052793) 
if (PDMupdate_os_necessary())
 status = PDMreset_update_os_flag("U");
     This can also fecilitate recovery during exceptions: the
     terminate can update this flag to U if it is P.
                                                       */



int PDMupdate_os_necessary ()
{
 char *fn = "PDMupdate_os_necessary";
 char value[250];

  _PDMdebug(fn, "ENTER:\n");
  
  value [0] = '\0';

  status = _PDMget_attribute_value (PDMexec->catalog, 
                                    PDMexec->part_num,
                                    PDMexec->revision,
                                    "p_incpartrpt", value);
  if (status != PDM_S_SUCCESS) {
     _PDMdebug (fn, "_PDMget_attrubute value failed %d \n", status);
     /*return(PDM_E_PART_NOT_FOUND);*/
     return(0);
     }

   _PDMdebug (fn, "attr[%s] : value[%s]\n", "p_incpartrpt", value);

   if (!strcmp (value, "U")) {
      _PDMdebug(fn, "EXIT-SUCCESS - UPDATE NECESSARY\n");
      return (1);
         }
/*
   else if (!strcmp (value, "P")) {
      _PDMdebug(fn, "EXIT-SUCCESS - UPDATE NECESSARY\n");
      return (1);
         }
*/
    else {
      _PDMdebug(fn, "EXIT-SUCCESS - NO UPDATE NECESSARY\n");
       return(0);
    }
}


int PDMset_update_os_flag (flag)
char	*flag;
{
 char *fn = "PDMset_update_os_flag";
 char sql_str[250];

  _PDMdebug(fn,"ENTER:\n");

  _PDMdebug (fn, "p_incpartrpt will be set to %s\n", flag);

  sql_str[0] = '\0';

  /*  state trans

       "U" -> "P" -> part save&restore but not checked in
       " " -> "U" -> assy created non gr in CIT
       "P" -> " " -> part checked in succ after os update
       "P" -> "U" -> rollback: either cancel co or exception
   */
      
    

  if (!strcmp (flag, "U")) {
  sprintf(sql_str,
     "UPDATE %s SET p_incpartrpt = '%s' where n_itemname = '%s' and n_itemrev = '%s' AND p_incpartrpt = 'P' ",
      PDMexec->catalog, flag, PDMexec->part_num,PDMexec->revision);
  }
  else if (!strcmp (flag, "P")) {
  sprintf(sql_str,
     "UPDATE %s SET p_incpartrpt = '%s' where n_itemname = '%s' and n_itemrev = '%s' AND p_incpartrpt = 'U' ",
      PDMexec->catalog, flag, PDMexec->part_num,PDMexec->revision);
  }
  else  {
   /* flag = "" */
  sprintf(sql_str,
     "UPDATE %s SET p_incpartrpt = '' where n_itemname = '%s' and n_itemrev = '%s' AND p_incpartrpt = 'P' ",
      PDMexec->catalog, PDMexec->part_num,PDMexec->revision);
  }
  
  _PDMdebug ("sql_str", "%s\n", sql_str);

  status = SQLstmt(sql_str);
  if(status != SQL_S_SUCCESS) {
     if(status == SQL_I_NO_ROWS_FOUND) {
         _PDMdebug(fn,"EXIT-SUCCESS: Update unnecessary \n");
         return(0);
        }
     else {
         _PDMdebug(fn,"SQLstmt %d\n", status);
         return(status);
         }
     }

    _PDMdebug(fn,"EXIT-SUCCESS\n");
    return(0);
}


