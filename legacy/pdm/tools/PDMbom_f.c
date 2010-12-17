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
extern PDMexec_ptr PDMexec;


/*
 * Finds the row in pdmboms table and returns p_bomname for the matching row
 * 
 * PDM_S_SUCCEESS PDM_E_BOM_NOT_FOUND
 */

int PDMquery_bom_name(n_catalogname, n_itemname, p_partrev,
		   p_bomname)
	char           *n_catalogname;
	char           *n_itemname;
	char           *p_partrev;
	char           *p_bomname;
{
	char            sql_str[1024];
	char          **data;
	MEMptr          temp_bufr = NULL;
	int             n_catalogno;
	int             n_itemno;

	PDMdebug("ENTER:PDMquery_bom_name\n");
	status = PDMquery_catalog_partnos(n_catalogname,
			     n_itemname, p_partrev, &n_catalogno, &n_itemno);
	if (status != PDM_S_SUCCESS) {
		sprintf(s, "%s %d\n",
			"PDMquery_catalog_partnos failed status ", status);
		PDMdebug(s);
		return (status);
	}
        sql_str [0] = '\0';
	sprintf(sql_str, "%s %s %d %s %d ",
		"SELECT p_bomname FROM pdmboms ",
		"WHERE n_catalogno = ", n_catalogno,
		"AND n_itemno = ", n_itemno);
	status = SQLquery(sql_str, &temp_bufr, 512);
	if (status != SQL_S_SUCCESS) {
		sprintf(s, "SQLquery failed status %d\n", status);
		PDMdebug(s);
		switch (status) {
		case SQL_I_NO_ROWS_FOUND:
			PDMdebug("BOM not found\n");
			return (PDM_E_BOM_NOT_FOUND);
		case PDMS_NO_SUCH_ATTRIBUTE:
			PDMdebug("A req. column is missing in SQL query\n");
			return (PDM_E_REQ_COLUMN_NOT_FOUND);
		case PDMS_NO_SUCH_TABLE:
			PDMdebug("pdmboms table can not be found \n");
			return (PDM_E_UNKNOWN_TABLE);
		default:
			sprintf(s, "%s %d\n",
				"SQLquery failed status ", status);
			PDMdebug(s);
			return (PDM_E_SQL_QUERY);
		}
	}
	status = MEMbuild_array(temp_bufr);
	if (status != MEM_S_SUCCESS) {
		MEMclose(&temp_bufr);
		sprintf(s, "%s %s %s %d\n",
			"PDMquery_bom_name: MEMbuild_array",
			"failed status ", status);
		PDMdebug(s);
		return (PDM_E_BUILD_ARRAY);
	}
	data = (char **) temp_bufr->data_ptr;
	strcpy(p_bomname, data[0]);
	MEMclose(&temp_bufr);
	PDMdebug("EXIT:PDMquery_bom_name\n");
	return (PDM_S_SUCCESS);
}

/*
 * queries for the p_maxlevel of the specified part
 * 
 * if p_maxlevel is not set p_maxlevel = -1;
 * 
 * PDM_S_SUCCESS PDM_E_PART_NOT_FOUND PDM_E_CATALOG_NOT_FOUND
 */

int PDMfind_maxlevel(n_catalogname, n_itemname,
		 p_partrev, p_maxlevel)
	char           *n_catalogname;
	char           *n_itemname;
	char           *p_partrev;
	long           *p_maxlevel;
{
	char            sql_str[1024];
	char          **data;
	MEMptr          temp_bufr = NULL;

	PDMdebug("ENTER:PDMfind_maxlevel\n");
        sql_str [0] = '\0';
	sprintf(sql_str, "%s %s %s '%s' %s '%s'",
		"SELECT p_maxlevel FROM ", n_catalogname,
		"WHERE n_itemname = ", n_itemname,
		"AND n_itemrev = ", p_partrev);
	status = SQLquery(sql_str, &temp_bufr, 1024);
	if (status != SQL_S_SUCCESS) {
		PDMdebug("PDMfind_maxlevel :\n");
		switch (status) {
		case SQL_I_NO_ROWS_FOUND:
			return (PDM_E_PART_NOT_FOUND);
		case PDMS_NO_SUCH_ATTRIBUTE:
			PDMdebug
				("A req. column is missing in SQL query\n");
			return (PDM_E_REQ_COLUMN_NOT_FOUND);
		case PDMS_NO_SUCH_TABLE:
			sprintf(s, "%s catalog can not be found \n",
				n_catalogname);
			PDMdebug(s);
			return (PDM_E_CATALOG_NOT_FOUND);
		default:
			sprintf(s, "%s %d\n",
				"SQLquery failed status ", status);
			PDMdebug(s);
			return (status);
		}
	}
	status = MEMbuild_array(temp_bufr);
	if (status != MEM_S_SUCCESS) {
		MEMclose(&temp_bufr);
		sprintf(s, "MEMbuild_array failed status %d\n", status);
		PDMdebug(s);
		return (PDM_E_BUILD_ARRAY);
	}
	data = (char **) temp_bufr->data_ptr;
	if (strlen(data[0]))
		*p_maxlevel = atol(data[0]);
	else
		*p_maxlevel = -1;
	MEMclose(&temp_bufr);
	PDMdebug("EXIT:PDMfind_maxlevel\n");
	return (PDM_S_SUCCESS);
}

/*
 * Queries for p_explode of the spec. part
 * 
 * PDM_S_SUCCESS PDM_E_PART_NOT_FOUND PDM_E_CATALOG_NOT_FOUND
 * 
 */

int PDMfind_p_explode(catalog, part_num, part_rev, p_explode)
	char           *catalog;
	char           *part_num;
	char           *part_rev;
	char           *p_explode;
{
	char            sql_str[1024];
	MEMptr          bufr = NULL;
	char          **data;

	PDMdebug("ENTER PDMfind_p_explode \n");
        sql_str [0] = '\0';
	sprintf(sql_str, "%s %s %s '%s' %s '%s'",
		"SELECT p_explode FROM ", catalog,
		"WHERE n_itemname = ", part_num,
		"AND n_itemrev = ", part_rev);
	status = SQLquery(sql_str, &bufr, 512);
	if (status != SQL_S_SUCCESS) {
		MEMclose(&bufr);
		switch (status) {
		case SQL_I_NO_ROWS_FOUND:
			sprintf(s, "%s %s %d \n",
				"PDMfind_p_explode : ",
				"PART NOT FOUND RISstatus ", status);
			PDMdebug(s);
			return (PDM_E_PART_NOT_FOUND);
		case PDMS_NO_SUCH_TABLE:
			sprintf(s, "%s %s %d \n",
				"PDMfind_p_explode : ",
				"CATALOG NOT FOUND RISstatus ", status);
			PDMdebug(s);
			return (PDM_E_CATALOG_NOT_FOUND);
		case PDMS_NO_SUCH_ATTRIBUTE:
			sprintf(s, "%s %s %d \n",
				"PDMfind_p_explode : ",
				"COLUMN NOT FOUND RISstatus ", status);
			PDMdebug(s);
			return (PDM_E_REQ_COLUMN_NOT_FOUND);
		default:
			return (status);
		}

	}
	status = MEMbuild_array(bufr);
	if (status != MEM_S_SUCCESS) {
		MEMclose(&bufr);
		sprintf(s, "%s %s %d \n",
			"PDMfind_p_explode : ",
			"MEMbuild_array_failed status ", status);
		PDMdebug(s);
		return (PDM_E_BUILD_ARRAY);
	}
	data = (char **) bufr->data_ptr;
	strcpy(p_explode, "");
	strcpy(p_explode, data[0]);
	MEMclose(&bufr);
	PDMdebug("EXIT PDMfind_p_explode \n");
	return (PDM_S_SUCCESS);
}

/*
 * Queries for p_explode of the spec. part from the cit
 * 
 * PDM_S_SUCCESS PDM_E_PART_NOT_FOUND PDM_E_CATALOG_NOT_FOUND
 * 
 */

int PDMfind_citp_explode(catalog, part_num, part_rev, p_explode, p_incbom)
	char           *catalog;
	char           *part_num;
	char           *part_rev;
	char           *p_explode;
	char           *p_incbom;
{
	char            sql_str[1024];
	MEMptr          bufr = NULL;
	MEMptr          temp_bufr = NULL;
	char          **data;
	char          **data1;
	long            n_pcatalogno;
	long            n_pitemno;

	PDMdebug("ENTER PDMfind_citp_explode \n");
	status = PDMquery_catalog_partnos(catalog, part_num, part_rev,
					  &n_pcatalogno, &n_pitemno);
	if (status != PDM_S_SUCCESS) {
		return (status);
	}
        sql_str [0] = '\0';
	sprintf(sql_str, "%s %s %d %s %d",
		"SELECT n_citno FROM nfmsetcit ",
		"WHERE n_ccatalogno =", n_pcatalogno,
		"AND n_citemno =", n_pitemno);
	status = SQLquery(sql_str, &temp_bufr, 1024);
	if (status != SQL_S_SUCCESS) {
		if (status == SQL_I_NO_ROWS_FOUND) {
			strcpy(p_explode, "Y");
			strcpy(p_incbom, "Y");
			return (PDM_S_SUCCESS);
		}
		return (PDM_E_SQL_QUERY);
	}
	status = MEMbuild_array(temp_bufr);
	if (status != MEM_S_SUCCESS) {
		MEMclose(&temp_bufr);
		return (PDM_E_BUILD_ARRAY);
	}
	data1 = (char **) temp_bufr->data_ptr;

	sprintf(sql_str, "%s %s  %s ",
		"SELECT p_explode,p_incbom FROM pdmcit",
		"WHERE p_citno = ", data1[0]);
	status = SQLquery(sql_str, &bufr, 512);
	if (status != SQL_S_SUCCESS) {
		MEMclose(&bufr);
		switch (status) {
		case SQL_I_NO_ROWS_FOUND:
			sprintf(s, "%s %s %d \n",
				"PDMfind_p_explode : ",
				"PART NOT FOUND RISstatus ", status);
			PDMdebug(s);
			return (PDM_E_PART_NOT_FOUND);
		case PDMS_NO_SUCH_TABLE:
			sprintf(s, "%s %s %d \n",
				"PDMfind_p_explode : ",
				"CATALOG NOT FOUND RISstatus ", status);
			PDMdebug(s);
			return (PDM_E_CATALOG_NOT_FOUND);
		case PDMS_NO_SUCH_ATTRIBUTE:
			sprintf(s, "%s %s %d \n",
				"PDMfind_p_explode : ",
				"COLUMN NOT FOUND RISstatus ", status);
			PDMdebug(s);
			return (PDM_E_REQ_COLUMN_NOT_FOUND);
		default:
			return (status);
		}

	}
	status = MEMbuild_array(bufr);
	if (status != MEM_S_SUCCESS) {
		MEMclose(&bufr);
		sprintf(s, "%s %s %d \n",
			"PDMfind_p_explode : ",
			"MEMbuild_array_failed status ", status);
		PDMdebug(s);
		return (PDM_E_BUILD_ARRAY);
	}
	data = (char **) bufr->data_ptr;
	strcpy(p_explode, "");
	strcpy(p_explode, data[0]);
	strcpy(p_incbom, "");
	strcpy(p_incbom, data[1]);
	MEMclose(&bufr);
	MEMclose(&temp_bufr);
	PDMdebug("EXIT PDMfind_citp_explode \n");
	return (PDM_S_SUCCESS);
}


int PDMfind_citc_explode(catalog, part_num, part_rev, p_incbom)
	char           *catalog;
	char           *part_num;
	char           *part_rev;
	char           *p_incbom;
{
	char            sql_str[1024];
	MEMptr          bufr = NULL;
	MEMptr          temp_bufr = NULL;
	char          **data;
	char          **data1;
	long            n_ccatalogno;
	long            n_citemno;

	PDMdebug("ENTER PDMfind_citp_explode \n");
	status = PDMquery_catalog_partnos(catalog, part_num, part_rev,
					  &n_ccatalogno, &n_citemno);
	if (status != PDM_S_SUCCESS) {
		return (status);
	}
        sql_str [0] = '\0';
	sprintf(sql_str, "%s %s %d %s %d",
		"SELECT n_citno FROM nfmsetcit ",
		"WHERE n_ccatalogno =", n_ccatalogno,
		"AND n_citemno =", n_citemno);
	status = SQLquery(sql_str, &temp_bufr, 1024);
	if (status != SQL_S_SUCCESS) {
		if (status == SQL_I_NO_ROWS_FOUND) {
			strcpy(p_incbom, "Y");
			return (PDM_S_SUCCESS);
		}
		return (PDM_E_SQL_QUERY);
	}
	status = MEMbuild_array(temp_bufr);
	if (status != MEM_S_SUCCESS) {
		MEMclose(&temp_bufr);
		return (PDM_E_BUILD_ARRAY);
	}
	data1 = (char **) temp_bufr->data_ptr;

	sprintf(sql_str, "%s %s  %s ",
		"SELECT p_incbom FROM pdmcit",
		"WHERE p_citno = ", data1[0]);
	status = SQLquery(sql_str, &bufr, 512);
	if (status != SQL_S_SUCCESS) {
		MEMclose(&bufr);
		switch (status) {
		case SQL_I_NO_ROWS_FOUND:
			sprintf(s, "%s %s %d \n",
				"PDMfind_p_explode : ",
				"PART NOT FOUND RISstatus ", status);
			PDMdebug(s);
			return (PDM_E_PART_NOT_FOUND);
		case PDMS_NO_SUCH_TABLE:
			sprintf(s, "%s %s %d \n",
				"PDMfind_p_explode : ",
				"CATALOG NOT FOUND RISstatus ", status);
			PDMdebug(s);
			return (PDM_E_CATALOG_NOT_FOUND);
		case PDMS_NO_SUCH_ATTRIBUTE:
			sprintf(s, "%s %s %d \n",
				"PDMfind_p_explode : ",
				"COLUMN NOT FOUND RISstatus ", status);
			PDMdebug(s);
			return (PDM_E_REQ_COLUMN_NOT_FOUND);
		default:
			return (status);
		}

	}
	status = MEMbuild_array(bufr);
	if (status != MEM_S_SUCCESS) {
		MEMclose(&bufr);
		sprintf(s, "%s %s %d \n",
			"PDMfind_p_explode : ",
			"MEMbuild_array_failed status ", status);
		PDMdebug(s);
		return (PDM_E_BUILD_ARRAY);
	}
	data = (char **) bufr->data_ptr;
	strcpy(p_incbom, "");
	strcpy(p_incbom, data[0]);
	MEMclose(&bufr);
	MEMclose(&temp_bufr);
	PDMdebug("EXIT PDMfind_citp_explode \n");
	return (PDM_S_SUCCESS);
}
/*
 * if oldbom exists the entry in pdmboms is updated and the oldbom is
 * deleted. if oldbom does not exist a new row is inserted into pdmboms table
 * 
 */

int PDMswap_bom_tables(p_catalog, n_itemname, p_partrev,
		    oldbom, newbom)
	char           *p_catalog;
	char           *n_itemname;
	char           *p_partrev;
	char           *oldbom;
	char           *newbom;
{
	char            sql_str[1024];
	int             catno;
	int             partno;
	char            cr_date[25], datetime[50];

	PDMdebug("ENTER:PDMswap_bom_tables\n");
         datetime[0] = '\0';
	status = PDMquery_catalog_partnos(p_catalog, n_itemname,
					  p_partrev, &catno, &partno);
	if (status != PDM_S_SUCCESS) {
		sprintf(s, "%s %d \n",
			"PDMquery_catalog_partnos failed status ",
			status);
		PDMdebug(s);
		return (status);
	}
/*
	status = PDMget_date_time(cr_date, cr_time, ":", 1);
	if (status != PDM_S_SUCCESS) {
		sprintf(s, "PDMget_date_time failed status %d\n", status);
		PDMdebug(s);
		return (status);
	}
*/
	status = NFMget_datetime(cr_date);
	if (status != NFM_S_SUCCESS) {
		sprintf(s, "PDMget_date_time failed status %d\n", status);
		PDMdebug(s);
		return (status);
	}
       PDMdebug("Calling change to ascii \n");
      status = NFMascii_to_timestamp_format (cr_date, datetime);
  if (status != NFM_S_SUCCESS)
  {
		sprintf(s, "PDMget_date_time failed status %d\n", status);
		PDMdebug(s);
    return (NFM_E_SYS_TIME);
  }
	if (strlen(oldbom) || strcmp(oldbom, "")) {
		/*
		 * oldbom exists delete oldbom make newbom the bom of the
		 * part
		 */

		/* drop old bom */
        sql_str [0] = '\0';

		sprintf(sql_str, "DROP TABLE %s", oldbom);
		status = SQLstmt(sql_str);

		sprintf(sql_str,
		      "%s '%s',%s TIMESTAMP'%s',%s '%s' %s %d %s %d %s '%s'",
			"UPDATE pdmboms SET p_bomname = ", newbom,
			"p_createdate = ", datetime,
			"p_locked = ", "N",
			"WHERE n_catalogno = ", catno,
		     "AND n_itemno = ", partno, "AND p_bomname = ", oldbom);
		status = SQLstmt(sql_str);
		if (status != SQL_S_SUCCESS) {
			return (PDM_E_SQL_STMT);
		}
	} else 
            {
		/*
		 * oldbom does not exist add newbom as the bom of the part
		 */

			sprintf(sql_str,
			"%s (%s %s) VALUES('%s',TIMESTAMP'%s','%s',%d,%d)",
				"INSERT INTO pdmboms ",
			    "p_bomname,p_createdate,p_locked,",
				"n_catalogno,n_itemno",
			 newbom, datetime,  "N", catno, partno);
		status = SQLstmt(sql_str);
		if (status != SQL_S_SUCCESS) {
			sprintf(s, "SQLstmt failed status %d\n", status);
			PDMdebug(s);
			return (PDM_E_SQL_STMT);
		}
             }
	PDMdebug("EXIT:PDMswap_bom_tables\n");
	return (PDM_S_SUCCESS);
}

/*
 * delete the bom specified First the bom is deleted and then the entry in
 * pdmboms table is deleted The part is specified thru PDMexec structure
 * PDMexec->operation is expected to be set as follows set to "0" to indicate
 * active bom of the part or	set to "1" to indicate review bom of the part
 * or	set to "2" to indicate both boms of the part
 */

int PDMdelete_bom()
{
	long            n_catalogno;
	long            n_itemno;

	PDMdebug("ENTER:PDMdelete_bom\n");

	/* set n_itemno and n_catalogno */

	status = PDMquery_catalog_partnos(PDMexec->catalog,
				       PDMexec->part_num, PDMexec->revision,
					  &n_catalogno, &n_itemno);
	if (status != PDM_S_SUCCESS) {
		PDMdebug("PDMdelete_bom:\n");
		sprintf(s, "%s %d \n",
			"PDMquery_catalog_partnos failed status", status);
		PDMdebug(s);
		return (status);
	}
	/* set the type of the BOM */

		status = PDMdrop_bom(n_catalogno, n_itemno);

		if (status != PDM_S_SUCCESS) {
			sprintf(s, "PDMdrop_bom failed status %d\n", status);
			PDMdebug(s);
			return (status);
		}
	PDMdebug("EXIT:PDMdelete_bom\n");
	return (PDM_S_SUCCESS);
}

/*
 * Internal function
 */

int PDMdrop_bom(n_catalogno, n_itemno)
	int             n_catalogno;
	int             n_itemno;
{
	char            sql_str[1024];
	char          **data;
	char            p_bomname[50];
	MEMptr          temp_bufr = NULL;

	PDMdebug("ENTER:PDMdrop_bom\n");

	/* query pdmboms table for BOM name */

	sql_str[0] = '\0';
	sprintf(sql_str, "%s %d %s %d ",
	      "SELECT p_bomname,p_locked FROM pdmboms WHERE n_catalogno = ",
		n_catalogno, "AND n_itemno = ",
		n_itemno);
	status = SQLquery(sql_str, &temp_bufr, 512);
	if (status != SQL_S_SUCCESS) {
		switch (status) {
		case SQL_I_NO_ROWS_FOUND:
			PDMdebug("No entry found in pdmboms table \n");
			return (PDM_E_BOM_NOT_FOUND);
		case PDMS_NO_SUCH_ATTRIBUTE:
			PDMdebug("A req. column is missing in SQL query\n");
			return (PDM_E_REQ_COLUMN_NOT_FOUND);
		case PDMS_NO_SUCH_TABLE:
			PDMdebug("pdmboms table can not be found \n");
			return (PDM_E_UNKNOWN_TABLE);
		default:
			sprintf(s, "%s %d\n",
				"SQLquery failed status ", status);
			PDMdebug(s);
			return (PDM_E_SQL_QUERY);
		}
	}
	status = MEMbuild_array(temp_bufr);
	if (status != MEM_S_SUCCESS) {
		MEMclose(&temp_bufr);
		sprintf(s, "MEMbuild_array failed status %d\n", status);
		PDMdebug(s);
		return (PDM_E_BUILD_ARRAY);
	}
	data = (char **) temp_bufr->data_ptr;
	p_bomname[0] = '\0';
	strcpy(p_bomname, data[0]);
	MEMclose(&temp_bufr);

	/* locked or not delete it */

	/* drop BOM table */

	sprintf(sql_str, "DROP TABLE %s", p_bomname);
	status = SQLstmt(sql_str);
	if (status != SQL_S_SUCCESS) {
		switch (status) {
		case SQL_I_NO_ROWS_FOUND:
			PDMdebug("No entry found in pdmboms table \n");
			return (PDM_E_BOM_NOT_FOUND);
		case PDMS_NO_SUCH_TABLE:
			PDMdebug("pdmboms table can not be found \n");
			return (PDM_E_UNKNOWN_TABLE);
		default:
			sprintf(s, "%s %d\n",
				"SQLquery failed status ", status);
			PDMdebug(s);
			return (PDM_E_SQL_QUERY);
		}
	}
	if (status != SQL_S_SUCCESS) {
		sprintf(s, "failed to delete %s \n", p_bomname);
		PDMdebug(s);
	}
	/* delete entry in pdmboms */

	sql_str[0] = '\0';
	sprintf(sql_str, "%s %s %d %s %d ",
		"DELETE FROM pdmboms ", "WHERE n_catalogno = ",
		n_catalogno, "AND n_itemno = ", n_itemno);
	status = SQLstmt(sql_str);
	if (status != SQL_S_SUCCESS) {
		switch (status) {
		case SQL_I_NO_ROWS_FOUND:
			PDMdebug("No entry found in pdmboms table \n");
			return (PDM_E_BOM_NOT_FOUND);
		case PDMS_NO_SUCH_ATTRIBUTE:
			PDMdebug("A req. column is missing in SQL query\n");
			return (PDM_E_REQ_COLUMN_NOT_FOUND);
		case PDMS_NO_SUCH_TABLE:
			PDMdebug("pdmboms table can not be found \n");
			return (PDM_E_UNKNOWN_TABLE);
		default:
			sprintf(s, "%s %d\n",
				"SQLquery failed status ", status);
			PDMdebug(s);
			return (PDM_E_SQL_QUERY);
		}
	}
	PDMdebug("EXIT:PDMdrop_bom\n");
	return (PDM_S_SUCCESS);
}

/*
 * function to delete a bom given its name note that since bom name is unique
 * the entries in pdmboms are unique on p_bomname
 */

int PDMdrop_a_bom(bom)
	char           *bom;
{
	char            sql_str[512];
/* APOGEE STRAT char            p_bomname[40]; APOGEE END */

	PDMdebug("EXIT:PDMdrop_a_bom\n");
	sprintf(sql_str, "DROP TABLE %s", bom);
	status = SQLstmt(sql_str);
	if (status != SQL_S_SUCCESS) {
	}
	sprintf(sql_str, "%s '%s'",
		"DELETE FROM pdmboms WHERE p_bomname = ", bom);
	status = SQLstmt(sql_str);
	if (status != SQL_S_SUCCESS) {

		switch (status) {
		case SQL_I_NO_ROWS_FOUND:
			PDMdebug("No entry found in pdmboms table \n");
			return (PDM_E_BOM_NOT_FOUND);
		case PDMS_NO_SUCH_ATTRIBUTE:
			PDMdebug("A req. column is missing in SQL query\n");
			return (PDM_E_REQ_COLUMN_NOT_FOUND);
		case PDMS_NO_SUCH_TABLE:
			PDMdebug("pdmboms table can not be found \n");
			return (PDM_E_UNKNOWN_TABLE);
		default:
			sprintf(s, "%s %d\n",
				"SQLquery failed status ", status);
			PDMdebug(s);
			return (PDM_E_SQL_QUERY);
		}
	}
	PDMdebug("EXIT:PDMdrop_a_bom\n");
	return (PDM_S_SUCCESS);
}

int PDMi_find_bomtable(catalog, part_num,
		   revision, p_bomtype, p_bomname)
	char           *catalog;
	char           *part_num;
	char           *revision;
	char           *p_bomtype;
	char           *p_bomname;
{
	MEMptr          bufr = NULL;
	char          **data;
	char            sql_str[1024];
	int             n_catalogno;
	int             n_itemno;

	PDMdebug("ENTER:PDMi_find_bom_table\n");

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
		"SELECT p_bomname FROM pdmboms WHERE n_catalogno = ",
		n_catalogno, "AND n_itemno = ",
		n_itemno, "AND p_bomtype = ", p_bomtype);
	status = SQLquery(sql_str, &bufr, 512);
	if (status != SQL_S_SUCCESS) {
		MEMclose(&bufr);
		switch (status) {
		case SQL_I_NO_ROWS_FOUND:
			PDMdebug("No entry found in pdmboms table \n");
			return (PDM_E_BOM_NOT_FOUND);
		case PDMS_NO_SUCH_ATTRIBUTE:
			PDMdebug("A req. column is missing in SQL query\n");
			return (PDM_E_REQ_COLUMN_NOT_FOUND);
		case PDMS_NO_SUCH_TABLE:
			PDMdebug("pdmboms table can not be found \n");
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
	strcpy(p_bomname, data[0]);
	MEMclose(&bufr);
	PDMdebug("ENTER:PDMi_find_bom_table\n");
	return (PDM_S_SUCCESS);
}


int PDMi_find_bominfo(catalog, part_num,
		  revision, p_bomname, p_createdate)
	char           *catalog;
	char           *part_num;
	char           *revision;
	char           *p_bomname;
	char           *p_createdate;
{
	MEMptr          bufr = NULL;
	char          **data;
	char            sql_str[1024];
	int             n_catalogno;
	int             n_itemno;

	PDMdebug("ENTER:PDMi_find_bominfo\n");

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
	sprintf(sql_str, "%s %s %d %s %d ",
		"SELECT p_bomname,p_createdate ",
		"FROM pdmboms WHERE n_catalogno = ",
		n_catalogno, "AND n_itemno = ",
		n_itemno);
	status = SQLquery(sql_str, &bufr, 512);
	if (status != SQL_S_SUCCESS) {
		MEMclose(&bufr);
		switch (status) {
		case SQL_I_NO_ROWS_FOUND:
			PDMdebug("No entry found in pdmboms table \n");
			return (PDM_I_NO_ROWS_FOUND);
		case PDMS_NO_SUCH_ATTRIBUTE:
			PDMdebug("A req. column is missing in SQL query\n");
			return (PDM_E_REQ_COLUMN_NOT_FOUND);
		case PDMS_NO_SUCH_TABLE:
			PDMdebug("pdmboms table can not be found \n");
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
	strcpy(p_bomname, data[0]);
	strcpy(p_createdate, data[1]);
	MEMclose(&bufr);
	PDMdebug("EXIT:PDMi_find_bominfo\n");
	return (PDM_S_SUCCESS);
}

int PDMverify_bomlock(catalog, partnum, revision)
	char           *catalog;
	char           *partnum;
	char           *revision;
{
	int             catno;
	int             partno;
	MEMptr          bufr = NULL;
	char            sql_str[512];
	char          **data;

	PDMdebug("ENTER:PDMverify_bomlock\n");
	status = PDMquery_catalog_partnos(catalog, partnum,
					  revision, &catno, &partno);
	if (status != PDM_S_SUCCESS) {
		sprintf(s, "PDMquery_catalog_partnos failed status %d\n",
			status);
		PDMdebug(s);
		return (status);
	}
	sprintf(sql_str, "%s %s %d %s %d ",
		"SELECT p_locked FROM pdmboms ",
		"WHERE n_catalogno = ", catno,
		"AND n_itemno = ", partno);
	status = SQLquery(sql_str, &bufr, 512);
	if (status != SQL_S_SUCCESS) {
		MEMclose(&bufr);
		if (status == SQL_I_NO_ROWS_FOUND) {
                       /*
			sprintf(sql_str, "%s (%s) VALUES (%d,%d)",
				"INSERT INTO pdmboms ",
				"n_catalogno,n_itemno",
				catno, partno);
			status = SQLstmt(sql_str);
			if (status != SQL_S_SUCCESS) {
				sprintf(s, "SQLstmt failed status %d\n", status);
				PDMdebug(s);
				return (PDM_E_SQL_STMT);
			} else {
				PDMdebug("EXIT:PDMverify_bomlock\n");
				return (PDM_S_SUCCESS);
			} */
				PDMdebug("EXIT:PDMverify_bomlock\n");
				return (PDM_S_SUCCESS);
		}
		sprintf(s, "SQLquery failed status %d\n", status);
		PDMdebug(s);
		return (status);
	} else {
		status = MEMbuild_array(bufr);
		if (status != MEM_S_SUCCESS) {
			MEMclose(&bufr);
			sprintf(s, "MEMBUILD_ARRAY failed status %d\n",
				status);
			PDMdebug(s);
			return (PDM_E_BUILD_ARRAY);
		}
		data = (char **) bufr->data_ptr;
		if (!strlen(data[0]) || strcmp(data[0], "Y")) {
			MEMclose(&bufr);
			sprintf(sql_str, "%s %s %d %s %d ",
				"UPDATE pdmboms SET p_locked = 'Y'",
				"WHERE n_catalogno = ", catno,
				"AND n_itemno = ", partno);
			status = SQLstmt(sql_str);
			if (status != SQL_S_SUCCESS) {
				sprintf(s, "SQLstmt failed status %d\n", status);
				PDMdebug(s);
				return (PDM_E_SQL_STMT);
			}
			PDMdebug("EXIT:PDMverify_bomlock\n");
			return (PDM_S_SUCCESS);
		} else {
			MEMclose(&bufr);
			PDMdebug("EXIT:PDMverify_bomlock\n");
			return (PDM_E_BOM_LOCKED);
		}
	}
}
