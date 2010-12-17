#include	<stdio.h>
#include	"SQLerrordef.h"
#include	"MEMerrordef.h"
#include	"NFMerrordef.h"
#include	"PDMdbs_err.h"
#include	"MEMstruct.h"
#include	"PDMproto.h"
#include	"PDUerror.h"

static long     status;
static char     s[1024];

int PDMi_find_tablename(catalog, part_num,
		    revision, p_tabletype, p_tablename)
	char           *catalog;
	char           *part_num;
	char           *revision;
	char           *p_tabletype;
	char           *p_tablename;
{
	MEMptr          bufr = NULL;
	char          **data;
	char            sql_str[1024];
	int             n_catalogno;
	int             n_itemno;

	PDMdebug("ENTER:PDMi_find_tablename\n");

	/* set n_itemno and n_catalogno */

	status = PDMquery_catalog_partnos(catalog,
					  part_num,
					  revision,
					  &n_catalogno, &n_itemno);
	if (status != PDM_S_SUCCESS) {
		sprintf(s, "%s %d \n",
			"PDMquery_catalog_partnos failed status", status);
		PDMdebug(s);
		return (status);
	}
	sql_str[0] = '\0';
	sprintf(sql_str, "%s %d %s %d %s '%s'",
		"SELECT p_tablename FROM pdmtables WHERE n_catalogno = ",
		n_catalogno, "AND n_itemno = ",
		n_itemno, "AND p_tabletype = ", p_tabletype);
	status = SQLquery(sql_str, &bufr, 512);
	if (status != SQL_S_SUCCESS) {
		MEMclose(&bufr);
		switch (status) {
		case SQL_I_NO_ROWS_FOUND:
			PDMdebug("No entry found in pdmtables table \n");
			return (PDM_E_BOM_NOT_FOUND);
		case PDMS_NO_SUCH_ATTRIBUTE:
			PDMdebug("A req. column is missing in SQL query\n");
			return (PDM_E_REQ_COLUMN_NOT_FOUND);
		case PDMS_NO_SUCH_TABLE:
			PDMdebug("pdmtables table can not be found \n");
			return (PDM_E_UNKNOWN_TABLE);
		default:
			sprintf(s, "%s %d\n",
				"SQLquery failed status ", status);
			PDMdebug(s);
			return (PDM_E_SQL_QUERY);
		}
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
	strcpy(p_tablename, data[0]);
	MEMclose(&bufr);
	PDMdebug("ENTER:PDMi_find_tablename\n");
	return (PDM_S_SUCCESS);
}

int 
PDMi_find_tableinfo(catalog, part_num,
		    revision, p_tabletype,
		    p_tablename, p_createdate)
	char           *catalog;
	char           *part_num;
	char           *revision;
	char           *p_tabletype;
	char           *p_tablename;
	char           *p_createdate;
{
	MEMptr          bufr = NULL;
	char          **data;
	char            sql_str[1024];
	int             n_catalogno;
	int             n_itemno;

	PDMdebug("ENTER:PDMi_find_tableinfo\n");

	/* set n_itemno and n_catalogno */

	status = PDMquery_catalog_partnos(catalog,
					  part_num,
					  revision,
					  &n_catalogno, &n_itemno);
	if (status != PDM_S_SUCCESS) {
		sprintf(s, "%s %d \n",
			"PDMquery_catalog_partnos failed status", status);
		PDMdebug(s);
		return (status);
	}
	sql_str[0] = '\0';
	sprintf(sql_str, "%s %s %d %s %d %s '%s'",
		"SELECT p_tablename,p_createdate ",
		"FROM pdmtables WHERE n_catalogno = ",
		n_catalogno, "AND n_itemno = ",
		n_itemno, "AND p_tabletype = ", p_tabletype);
	status = SQLquery(sql_str, &bufr, 512);
	if (status != SQL_S_SUCCESS) {
		MEMclose(&bufr);
		switch (status) {
		case SQL_I_NO_ROWS_FOUND:
			PDMdebug("No entry found in pdmtables table \n");
			return (PDM_I_NO_ROWS_FOUND);
		case PDMS_NO_SUCH_ATTRIBUTE:
			PDMdebug("A req. column is missing in SQL query\n");
			return (PDM_E_REQ_COLUMN_NOT_FOUND);
		case PDMS_NO_SUCH_TABLE:
			PDMdebug("pdmtables table can not be found \n");
			return (PDM_E_UNKNOWN_TABLE);
		default:
			sprintf(s, "%s %d\n",
				"SQLquery failed status ", status);
			PDMdebug(s);
			return (PDM_E_SQL_QUERY);
		}
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
	strcpy(p_tablename, data[0]);
	strcpy(p_createdate, data[1]);
	MEMclose(&bufr);
	PDMdebug("ENTER:PDMi_find_tableinfo\n");
	return (PDM_S_SUCCESS);
}

int 
PDMi_insert_pdmtables(catalog, part_num, revision,
		      p_tabletype, p_tablename)
	char           *catalog;
	char           *part_num;
	char           *revision;
	char           *p_tabletype;
	char           *p_tablename;
{
	char            p_createdate[20];
	char            datetime[50];
	char            sql_str[1024];
	int             n_catalogno;
	int             n_itemno;

	PDMdebug("ENTER:PDMi_insert_pdmtables\n");

	/* set n_itemno and n_catalogno */

	status = PDMquery_catalog_partnos(catalog,
					  part_num,
					  revision,
					  &n_catalogno, &n_itemno);
	if (status != PDM_S_SUCCESS) {
		sprintf(s, "%s %d \n",
			"PDMquery_catalog_partnos failed status", status);
		PDMdebug(s);
		return (status);
	}
        status = NFMget_datetime(p_createdate);
        if (status != NFM_S_SUCCESS) {
                sprintf(s, "PDMget_date_time failed status %d\n", status);
                PDMdebug(s);
                return (status);
        }
       PDMdebug("Calling change to ascii \n");
      status = NFMascii_to_timestamp_format (p_createdate, datetime);
       if (status != NFM_S_SUCCESS)
          {
                sprintf(s, "PDMget_date_time failed status %d\n", status);
                PDMdebug(s);
                return (NFM_E_SYS_TIME);
          }
	sql_str[0] = '\0';
	sprintf(sql_str, "%s %d %s %d %s '%s'",
		"DELETE FROM pdmtables WHERE n_catalogno = ", n_catalogno,
		"AND n_itemno = ", n_itemno,
		"AND p_tabletype = ", p_tabletype);
	status = SQLstmt(sql_str);
	if (status != SQL_S_SUCCESS && status != SQL_I_NO_ROWS_FOUND)
         {
	sprintf(sql_str, "DROP TABLE %s", p_tablename);
	   SQLstmt(sql_str);
	if (status != SQL_S_SUCCESS) {
	   }
          return (status);
         }
	sql_str[0] = '\0';
	sprintf(sql_str,
           "INSERT INTO pdmtables %s %s VALUES(%d,%d,'%s','%s',TIMESTAMP'%s')",
		"(n_catalogno,n_itemno,p_tablename, ",
		"p_tabletype,p_createdate)",
		n_catalogno, n_itemno, p_tablename, p_tabletype,
		datetime);
	status = SQLstmt(sql_str);
	if (status != SQL_S_SUCCESS) {
		switch (status) {
		case PDMS_NO_SUCH_ATTRIBUTE:
			PDMdebug("A req. column is missing in SQL query\n");
			return (PDM_E_REQ_COLUMN_NOT_FOUND);
		case PDMS_NO_SUCH_TABLE:
			PDMdebug("pdmtables table can not be found \n");
			return (PDM_E_UNKNOWN_TABLE);
		default:
			sprintf(s, "%s %d\n",
				"SQLstmt failed status ", status);
			PDMdebug(s);
			return (PDM_E_SQL_STMT);
		}
	}
	PDMdebug("ENTER:PDMi_insert_pdmtables\n");
	return (PDM_S_SUCCESS);
}

/* Kumar 9.21.92 */
int 
PDMget_ris_datatype(table_name, column_name, type)
	char           *table_name;
	char           *column_name;
	char           *type;
{
        char          *fname = "PDMget_ris_datatype";
        int           rows,out_err, free_flag;
        char          *type1,*type2, *ptr, *ptr1;
	char            sql_str[512];

	_PDMdebug(fname,"ENTER:\n");

        free_flag = 0;
	sql_str[0] = '\0';

/* RIS dictionary tables in V5 named different. 26/apr/95 - raj. */

#if defined ( RISV4 )

	sprintf(sql_str, "Select ris_type_string FROM ris_columns WHERE table_name = '%s' AND column_name = '%s'", table_name, column_name);

#elif defined ( RISV5 )

	sprintf(sql_str, "Select ris_type_string FROM ris5columns WHERE table_name = '%s' AND column_name = '%s'", table_name, column_name);

#else
#error "RIS version must be defined"
#endif

	status = PDMquery(sql_str, &rows, &type1, &out_err, '~');
	if (status != SQL_S_SUCCESS) {
	_PDMdebug(fname, "PDMget_ris_datatype failed status", status);
		return (status);
	}
          ptr = (char *) NULL;
          ptr = (char *) strtok(type1,"~");
         if(ptr == NULL) return(SQL_I_NO_ROWS_FOUND);
          else
          {
        if(!strcmp(ptr,"char"))
           {
	sql_str[0] = '\0';

/* RIS dictionary tables in V5 named different. 26/apr/95 - raj. */

#if defined ( RISV4 )

	sprintf(sql_str, "Select char_max_length FROM ris_columns WHERE table_name = '%s' AND column_name = '%s'", table_name, column_name);

#elif defined ( RISV5 )

	sprintf(sql_str, "Select char_max_length FROM ris5columns WHERE table_name = '%s' AND column_name = '%s'", table_name, column_name);

#else
#error "RIS version must be defined"
#endif

       status = PDMquery(sql_str, &rows, &type2, &out_err, '~');
	if (status != SQL_S_SUCCESS) {
	_PDMdebug(fname, "PDMget_ris_datatype failed status", status);
		return (status);
	}
	     _PDMdebug(fname,"type2 %s:\n", type2);
          ptr1 = (char *) NULL;
          ptr1 = (char *) strtok(type2,"~");
         if(ptr1 == NULL) return(SQL_I_NO_ROWS_FOUND);
          else
              {
               type[0]='\0';
              sprintf(type,"%s(%s)",ptr,ptr1);
	     _PDMdebug(fname,"type %s:\n",type);
              }
            }
          else
            {
	     _PDMdebug(fname,"ptr %s:\n", ptr);
              strcpy(type, ptr);
             }
            
            free(type1);
            if (free_flag) free(type2);
           
          }
	_PDMdebug(fname,"EXIT:\n");
	return (PDM_S_SUCCESS);
}

/* this function removes an entry from pdmtables for older
   or erron* pdma/b* entry */

int PDMi_delete_from_pdmtables(catalog, part_num, revision,
		                 p_tabletype, p_tablename)
char           *catalog;
char           *part_num;
char           *revision;
char           *p_tabletype;
char           *p_tablename;
{
	char		*fn = "PDMi_delete_from_pdmtables";
	char            sql_str[1024];
	int             n_catalogno;
	int             n_itemno;

   _PDMdebug("ENTER", "%s\n", fn);

   /* set n_itemno and n_catalogno */

   status = PDMquery_catalog_partnos(catalog, part_num, revision,
                                              &n_catalogno, &n_itemno);
   if (status != PDM_S_SUCCESS) {
      _PDMdebug (fn, "%s %d \n",
         "PDMquery_catalog_partnos failed status", status);
      return (status);
   }

   sql_str[0] = '\0';
   sprintf(sql_str, "%s %d %s %d %s '%s'",
      "DELETE FROM pdmtables WHERE n_catalogno = ", n_catalogno,
      "AND n_itemno = ", n_itemno,
      "AND p_tabletype = ", p_tabletype);

   status = SQLstmt(sql_str);
   if (status != SQL_S_SUCCESS) {
      if  (status == SQL_I_NO_ROWS_FOUND) {
      _PDMdebug("EXIT", "%s\n", fn);
      return (PDM_S_SUCCESS);
      }
      _PDMdebug (fn, "%s %d \n",
         "SQLstmt failed: status:", status);
        return (status);
      }

    sprintf(sql_str, "DROP TABLE %s", p_tablename);
    SQLstmt(sql_str);

   _PDMdebug("EXIT", "%s\n", fn);
   return (PDM_S_SUCCESS);
}
