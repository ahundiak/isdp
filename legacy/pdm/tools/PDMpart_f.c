#include <stdio.h>
#include "SQLerrordef.h"
#include "PDMdbs_err.h"
#include "MEMerrordef.h"
#include "MEMstruct.h"
#include <PDUerror.h>
#include "PDMexec.h"
#include "NFMerrordef.h"
#include "SQLstruct.h"

#define MAX_BUFFER_SIZE 16384
#define NOT !
#define	TRUE	1
#define FALSE	0

extern long     sqlstatus;
extern int      PDMdebug_on;
extern char     PDM_DEBUG_FILE[];
static long     status;
static char     s[1024];
extern PDMexec_ptr PDMexec;

/* this decl added to support query of db error message MaC 051593 */
extern struct SQLglobal_st      SQLglobal;


int PDMquery_assembly_ind(catalog, n_itemname, n_itemrev,
		      n_setindicator)
	char           *catalog;
	char           *n_itemname;
	char           *n_itemrev;
	char           *n_setindicator;
{
	char          **data;
	char            sql_str[1024];
	MEMptr          temp_bufr = NULL;

	long            status;

	PDMdebug("ENTER:PDMquery_assembly_ind\n");

	/* get n_setindicator from the catalog */

	sql_str[0] = '\0';
	sprintf(sql_str, "%s FROM %s %s '%s' %s '%s'",
		"SELECT n_setindicator ", catalog,
		"WHERE n_itemname = ", n_itemname,
		"AND n_itemrev = ", n_itemrev);

	status = SQLquery(sql_str, &temp_bufr, 512);
	if (status != SQL_S_SUCCESS) {
		MEMclose(&temp_bufr);
		switch (status) {
		case SQL_I_NO_ROWS_FOUND:
	sprintf(sql_str, "SELECT n_setindicator FROM e_%s where n_itemname =  '%s' AND n_itemrev =  '%s'", catalog, n_itemname, n_itemrev);
	status = SQLquery(sql_str, &temp_bufr, 512);
                 if(status != SQL_S_SUCCESS)
                        {
			sprintf(s, "%s %s %s %s \n",
				"PDMquery_assembly_ind : ",
				"Could not find Part ",
				n_itemname, n_itemrev);
			PDMdebug(s);
			return (PDM_E_PART_NOT_FOUND);
                        }
                        else break;
		case PDMS_NO_SUCH_TABLE:
			sprintf(s, "%s %s \n",
			   "PDMquery_assembly_ind: Could not find Catalog ",
				catalog);
			PDMdebug(s);
			return (PDM_E_CATALOG_NOT_FOUND);
		default:
			return (status);
		}
	}
	status = MEMbuild_array(temp_bufr);
	if (status != MEM_S_SUCCESS) {
		MEMclose(&temp_bufr);
		sprintf(s, "%s %s %d\n",
			"PDMquery_assembly_ind: MEMbuild_array ",
			"failed status ", status);
		PDMdebug(s);
		return (PDM_E_BUILD_ARRAY);
	}
	data = (char **) temp_bufr->data_ptr;
	strcpy(n_setindicator, data[0]);
	MEMclose(&temp_bufr);
	PDMdebug("EXIT:PDMquery_assembly_ind\n");
	return (PDM_S_SUCCESS);
}

/* Written to support CID && EID part number entry in e_catalog table
   Kumar - 11/12/92 */

int PDMquery_itemno_assind
(
	char           *catalog,
	char           *n_itemname,
	char           *n_itemrev,
	char           *type,
	char           *n_setindicator,
        int            *n_itemno
)
{
	char          **data , **e_data;
	char            sql_str[1024];
        char          e_cat[23];
        char          cr_date[23];
        int           itemno = 0;
        char          *fname = "PDMquery_itemno_assind";
	MEMptr          temp_bufr = NULL;
	MEMptr          e_bufr = NULL;
        int		_PDMget_db_error ();
	/*char		*n_itemdesc;*/

	long            status;

	_PDMdebug(fname, "ENTER:\n");

	/* get n_setindicator from the catalog */
       _PDMdebug (fname, "cat[%s]item[%s]rec[%s]type[%s]\n", catalog,
                                     n_itemname, n_itemrev, type);

	sql_str[0] = '\0';
       if(!strcmp(type,"CID") || !strcmp(type,"EID"))
       {
        sprintf(e_cat, "e_%s",catalog);
	sprintf(sql_str, "SELECT n_setindicator, n_itemno FROM e_%s where n_itemname =  '%s' AND n_itemrev =  '%s'", catalog, n_itemname, n_itemrev);
	status = SQLquery(sql_str, &temp_bufr, 512);
	if (status != SQL_S_SUCCESS) {
		MEMclose(&temp_bufr);
		switch (status) {
		case SQL_I_NO_ROWS_FOUND:
                   {
                   _PDMdebug(fname, 
                    "Adding the entry for part %s %s to e_%s", 
                                         n_itemname, n_itemrev, catalog);
                     /*status = PDMris_maxrow_no(e_cat,"n_itemno",&itemno);*/
                     status = PDMi_maxrow_no(e_cat, "n_itemno", &itemno);
	             if (status != PDM_S_SUCCESS && 
                         status != SQL_I_NO_ROWS_FOUND) {
                       _PDMdebug(fname, 
                          "Could not add Part %s %s ", n_itemname, n_itemrev);
                       return(status);
                       }

                  if(itemno == -1) itemno = 0;
                  *n_itemno = itemno +1;
/* fix added to get the description: MaC 060393
                  if (!Getpartnumber (catalog, &n_itemdesc)) {
                    _PDMdebug (fname, "Getpartnumber failed \n");
                   }
                  _PDMdebug (fname, "n_itemdesc[%s]\n", n_itemdesc);
*/
                  sql_str[0]='\0';
                  sprintf(sql_str, 
                  "SELECT n_itemdesc, n_creator, n_creationdate, n_stateno, \
                   n_aclno, n_versionlimit from e_%s where n_itemno = -1",
                                                             catalog );
                  status = SQLquery(sql_str,&e_bufr,512);
                  if(status != SQL_S_SUCCESS) {
                    sql_str[0]='\0';
                    sprintf(sql_str,
                       "INSERT INTO e_%s (n_itemno, n_itemname,n_itemrev, \
                        n_setindicator,p_parttype) \
                        VALUES (%d,'%s','%s','N','P')", 
                         catalog, *n_itemno, n_itemname,n_itemrev);
                    status = SQLstmt(sql_str);
                    if(status != SQL_S_SUCCESS) {
                      _PDMdebug(fname,
                       "Couldn't add the Computed Id part to %s\n",catalog);
                      _PDMdebug(fname,"SQLstmt failed status %d\n",status);
                      return(status);
                       }
                   }
                    status = MEMbuild_array(e_bufr);
                    if(status != MEM_S_SUCCESS)
                    {
                     MEMclose(&e_bufr);
                      _PDMdebug(fname,
                         "Couldn't add the Computed Id part to %s\n",catalog);
                      _PDMdebug(fname,"MEMbuild failed status %d\n",status);
                       return(status);
                     }
                  NFMRtic_it (e_bufr);
                  e_data = (char **) e_bufr->data_ptr;
                  cr_date[0] = '\0';
                  status = NFMascii_to_timestamp_format ( e_data[2], cr_date) ;
                  if (status != NFM_S_SUCCESS) {
                       _PDMdebug (fname, 
                          "ascii to timestamp:status = <0x%.8x>\n", status);
                    return (status) ;
                    }

                   _PDMdebug (fname, "cr_date [%s]\n", cr_date);

                   sql_str[0]='\0';
                   sprintf(sql_str,"INSERT INTO e_%s (n_itemno, n_itemname,n_itemrev,n_itemdesc,n_creator,n_creationdate,n_stateno,n_aclno,n_versionlimit, n_setindicator, p_parttype) VALUES (%d,'%s','%s','%s','%s',TIMESTAMP'%s',%s,%s,%s,'N','P')", 
                   catalog, *n_itemno, n_itemname,n_itemrev, e_data[0],
                       e_data[1],cr_date,e_data[3],e_data[4],e_data[5]);
                   status = SQLstmt(sql_str);
                   if(status != SQL_S_SUCCESS) {
                     MEMclose(&e_bufr);
                     _PDMdebug(fname,
                        "Couldn't add the Computed Id part to %s\n",catalog);
                     _PDMdebug(fname,"SQLstmt failed status %d\n",status);
                     return(status);
                       }
                     MEMclose(&e_bufr);
	             strcpy(n_setindicator, "N");
                    _PDMdebug(fname,
                        "Added the Computed Id part %s %s to %s\n", 
                         n_itemname, n_itemrev, catalog);
	            _PDMdebug(fname, "EXIT:\n");
	            return (PDM_S_SUCCESS);
                        }
	default:
           status = _PDMget_db_error (status);
           if (status != PDM_I_TABLE_LOCKED) status = PDM_E_PART_NOT_FOUND;
           _PDMdebug(fname,"Couldn't find the table e_%s for view catalog \n",
                                            catalog);
	   return (status);
       	   }
	}
	status = MEMbuild_array(temp_bufr);
	if (status != MEM_S_SUCCESS) {
		MEMclose(&temp_bufr);
	_PDMdebug(fname, "MEMbuild_array failed status %d \n", status);
		return (PDM_E_BUILD_ARRAY);
	}
	data = (char **) temp_bufr->data_ptr;
	strcpy(n_setindicator, data[0]);
        *n_itemno = atoi(data[1]);
	MEMclose(&temp_bufr);
       }
       else
        {
	sprintf(sql_str, "%s FROM %s %s '%s' %s '%s'",
		"SELECT n_setindicator,n_itemno ", catalog,
		"WHERE n_itemname = ", n_itemname,
		"AND n_itemrev = ", n_itemrev);

	status = SQLquery(sql_str, &temp_bufr, 512);
	if (status != SQL_S_SUCCESS) {
		MEMclose(&temp_bufr);
		switch (status) {
		case SQL_I_NO_ROWS_FOUND:
_PDMdebug(fname, "Could not find Part %s %s ", n_itemname, n_itemrev);
			return (PDM_E_PART_NOT_FOUND);
		default:
                   status = _PDMget_db_error (status);
		   return (status);
		}
	}
	status = MEMbuild_array(temp_bufr);
	if (status != MEM_S_SUCCESS) {
		MEMclose(&temp_bufr);
	_PDMdebug(fname, "MEMbuild_array failed status %d \n", status);
		return (PDM_E_BUILD_ARRAY);
	}
	data = (char **) temp_bufr->data_ptr;
	strcpy(n_setindicator, data[0]);
        *n_itemno = atoi(data[1]);
	MEMclose(&temp_bufr);
        }
	_PDMdebug(fname, "EXIT:\n");
	return (PDM_S_SUCCESS);
}

int PDMquery_assyind_parttype
 (
	char           *catalog,
	char           *n_itemname,
	char           *n_itemrev,
	char           *n_setindicator,
	char           *p_parttype
  )
{
	char          **data;
        char          *fname = "PDMquery_assyind_parttype";
	char          sql_str[1024];
	MEMptr        temp_bufr = NULL;

	long            status;

	_PDMdebug(fname,"ENTER:\n");

	/* get n_setindicator from the catalog */

	sql_str[0] = '\0';
	sprintf(sql_str, "%s FROM %s %s '%s' %s '%s'",
		"SELECT n_setindicator,p_parttype ", catalog,
		"WHERE n_itemname = ", n_itemname,
		"AND n_itemrev = ", n_itemrev);

	status = SQLquery(sql_str, &temp_bufr, 512);
	if (status != SQL_S_SUCCESS) {
		MEMclose(&temp_bufr);
		switch (status) {
		case SQL_I_NO_ROWS_FOUND:
                       {
         MEMclose(&temp_bufr);
	sql_str[0] = '\0';
	sprintf(sql_str, "%s FROM e_%s %s '%s' %s '%s'",
		"SELECT n_setindicator,p_parttype ", catalog,
		"WHERE n_itemname = ", n_itemname,
		"AND n_itemrev = ", n_itemrev);

	status = SQLquery(sql_str, &temp_bufr, 512);
	if (status != SQL_S_SUCCESS) {
	                 strcpy(n_setindicator, "Y");
                         strcpy(p_parttype, "P");
                             
			_PDMdebug(fname, "%s %s %s %s \n",
				"PDMquery_assyind_parttype : ",
				"Could not find Part ",
				n_itemname, n_itemrev);
			return (PDM_S_SUCCESS);
                                     }
                           else
                               break;
                      } 
		case PDMS_NO_SUCH_TABLE:
			_PDMdebug(fname, "%s %s \n",
			   "PDMquery_assyind_parttype: Could not find Catalog ",
				catalog);
			return (PDM_E_CATALOG_NOT_FOUND);
		default:
			return (status);
		}
	}
	status = MEMbuild_array(temp_bufr);
	if (status != MEM_S_SUCCESS) {
		MEMclose(&temp_bufr);
		_PDMdebug(fname, "%s %s %d\n",
			"PDMquery_assyind_parttype: MEMbuild_array ",
			"failed status ", status);
		return (PDM_E_BUILD_ARRAY);
	}
	data = (char **) temp_bufr->data_ptr;
	strcpy(n_setindicator, data[0]);
	strcpy(p_parttype, data[1]);
	MEMclose(&temp_bufr);
	_PDMdebug(fname,"EXIT\n");
	return (PDM_S_SUCCESS);
}

int PDMset_n_setindicator(catalog, n_itemname, n_itemrev,
		  n_setindicator)
	char           *catalog;
	char           *n_itemname;
	char           *n_itemrev;
	char           *n_setindicator;
{
	char            sql_str[1024];
	long            status;

	PDMdebug("ENTER:PDMset_n_setindicator\n");

	/* set n_setindicator from the catalog */

	sql_str[0] = '\0';
	sprintf(sql_str, "%s %s %s '%s' %s '%s' %s '%s'",
		"UPDATE ", catalog, "SET n_setindicator = ", n_setindicator,
		"WHERE n_itemname = ", n_itemname,
		"AND n_itemrev = ", n_itemrev);
	status = SQLstmt(sql_str);
	if (status != SQL_S_SUCCESS) {
		switch (status) {
		case PDMS_NO_SUCH_TABLE:
			sprintf(s, "%s %s \n",
				"PDMset_n_setindicator: Could not find Catalog ",
				catalog);
			PDMdebug(s);
			return (PDM_E_CATALOG_NOT_FOUND);
		default:
			break;
		}
	}
	PDMdebug("EXIT:PDMset_n_setindicator\n");
	return (PDM_S_SUCCESS);
}

int PDMquery_catalog_partnos(catalog, n_itemname, n_itemrev,
			 n_catalogno, n_itemno)
	char           *catalog;
	char           *n_itemname;
	char           *n_itemrev;
	int            *n_itemno;
	int            *n_catalogno;
{
	char          **data;
	char            sql_str[1024];
	char            *fn = "PDMquery_catalog_partnos";
	MEMptr          temp_bufr = NULL;
        int		catno, partno;

	long            status;

	PDMdebug("ENTER:PDMquery_catalog_partnos:\n");

_PDMdebug (fn, "catalog = %s, n_itemname = %s & n_itemrev = %s\n",
                catalog, n_itemname, n_itemrev);
	/* get n_setindicator n_itemno from the catalog */

	sql_str[0] = '\0';
	sprintf(sql_str, "%s FROM %s %s '%s' %s '%s'",
		"SELECT n_itemno ", catalog,
		"WHERE n_itemname = ", n_itemname,
		"AND n_itemrev = ", n_itemrev);

	status = SQLquery(sql_str, &temp_bufr, 512);
	if (status != SQL_S_SUCCESS) {
		MEMclose(&temp_bufr);
		switch (status) {
		case SQL_I_NO_ROWS_FOUND:
	sprintf(sql_str, "%s FROM e_%s %s '%s' %s '%s'",
		"SELECT n_itemno ", catalog,
		"WHERE n_itemname = ", n_itemname,
		"AND n_itemrev = ", n_itemrev);
	status = SQLquery(sql_str, &temp_bufr, 512);
	if (status != SQL_S_SUCCESS) {

			sprintf(s, "%s %s %s %s \n",
				"PDMquery_catalog_partnos:",
				"Could not find Part ",
				n_itemname, n_itemrev);
			PDMdebug(s);
			return (PDM_E_PART_NOT_FOUND);
                         }
                         else break;
		case PDMS_NO_SUCH_TABLE:
			sprintf(s, "%s %s \n",
			"PDMquery_catalog_partnos: Could not find Catalog ",
				catalog);
			PDMdebug(s);
			return (PDM_E_CATALOG_NOT_FOUND);
		default:
                 MEMclose(&temp_bufr);
	sprintf(sql_str, "%s FROM e_%s %s '%s' %s '%s'",
		"SELECT n_itemno ", catalog,
		"WHERE n_itemname = ", n_itemname,
		"AND n_itemrev = ", n_itemrev);
	status = SQLquery(sql_str, &temp_bufr, 512);
	if (status != SQL_S_SUCCESS) {

			sprintf(s, "%s %s %s %s \n",
				"PDMquery_catalog_partnos:",
				"Could not find Part ",
				n_itemname, n_itemrev);
			PDMdebug(s);
			return (PDM_E_PART_NOT_FOUND);
                         }
                         else break;
		}
	}
	status = MEMbuild_array(temp_bufr);
	if (status != MEM_S_SUCCESS) {
		MEMclose(&temp_bufr);
		sprintf(s, "%s %s %d\n",
			"PDMquery_catalog_partnos: MEMbuild_array ",
			"failed status ", status);
		PDMdebug(s);
		return (PDM_E_BUILD_ARRAY);
	}
	data = (char **) temp_bufr->data_ptr;
        partno = atol (data[0]);
	*n_itemno = atol(data[0]);
	MEMclose(&temp_bufr);

	temp_bufr = NULL;
	/* get n_catalogno */
	sql_str[0] = '\0';
	sprintf(sql_str, "%s FROM %s %s '%s'",
		"SELECT n_catalogno ", "nfmcatalogs",
		"WHERE n_catalogname = ", catalog);
	status = SQLquery(sql_str, &temp_bufr, 512);
	if (status != SQL_S_SUCCESS) {
		MEMclose(&temp_bufr);
		switch (status) {
		case SQL_I_NO_ROWS_FOUND:
			sprintf(s, "%s %s %s \n",
				"PDMquery_catalog_partnos: ",
				"Could not find Catalog entry ",
				catalog);
			PDMdebug(s);
			return (PDM_E_NO_CAT_ENTRY);
		case PDMS_NO_SUCH_TABLE:
			sprintf(s, "%s %s %s\n",
				"PDMquery_catalog_partnos: ",
				"Could not find Catalog ",
				catalog);
			PDMdebug(s);
			return (PDM_E_CATALOG_NOT_FOUND);
		default:
			return (status);
		}
	}
	status = MEMbuild_array(temp_bufr);
	if (status != MEM_S_SUCCESS) {
		MEMclose(&temp_bufr);
		sprintf(s, "%s %d\n",
			"PDMquery_catalog_partnos: MEMbuild_array failed status ", status);
		PDMdebug(s);
		return (PDM_E_BUILD_ARRAY);
	}
	data = (char **) temp_bufr->data_ptr;
        catno = atol (data[0]);
	*n_catalogno = atol(data[0]);
_PDMdebug (fn, "n_itemno = %d & n_catalogno = %d\n",
                partno, catno);
	MEMclose(&temp_bufr);
	PDMdebug("EXIT:PDMquery_catalog_partnos:\n");
	return (PDM_S_SUCCESS);
}

int PDMquery_catalogno(catalog, n_catalogno)
	char           *catalog;
	int            *n_catalogno;
{
	char          **data;
	char            sql_str[1024];
	MEMptr          temp_bufr = NULL;

	long            status;

	PDMdebug("ENTER:PDMquery_catalogno\n");
	/* get n_catalogno */
	sql_str[0] = '\0';
	sprintf(sql_str, "%s FROM %s %s '%s'",
		"SELECT n_catalogno ", "nfmcatalogs",
		"WHERE n_catalogname = ", catalog);
	status = SQLquery(sql_str, &temp_bufr, 512);
	if (status != SQL_S_SUCCESS) {
		MEMclose(&temp_bufr);
		switch (status) {
		case SQL_I_NO_ROWS_FOUND:
			sprintf(s, "%s %s %s \n",
			"PDMquery_catalogno: Could not find Catalog entry ",
				catalog);
			PDMdebug(s);
			return (PDM_E_NO_CAT_ENTRY);
		case PDMS_NO_SUCH_TABLE:
			sprintf(s, "%s %s \n",
			      "PDMquery_catalogno: Could not find Catalog ",
				catalog);
			PDMdebug(s);
			return (PDM_E_CATALOG_NOT_FOUND);
		default:
                        status = _PDMget_db_error (status);
                        return(status);
		}
	}
	status = MEMbuild_array(temp_bufr);
	if (status != MEM_S_SUCCESS) {
		MEMclose(&temp_bufr);
		sprintf(s, "%s %d\n",
			"PDMquery_catalog_partnos: MEMbuild_array failed status ", status);
		PDMdebug(s);
		return (PDM_E_BUILD_ARRAY);
	}
	data = (char **) temp_bufr->data_ptr;
	*n_catalogno = atol(data[0]);
	MEMclose(&temp_bufr);
	PDMdebug("EXIT:PDMquery_catalogno:\n");
	return (PDM_S_SUCCESS);
}


int 
PDMstorage_location_check(catalog, n_itemnum, n_cisano)
	char           *catalog;
	int             n_itemnum;
	int            *n_cisano;
{
	char          **data;
	char            sql_str[1024];
	MEMptr          temp_bufr = NULL;

	long            status;

	PDMdebug("ENTER:PDMstorage_location_check\n");
	/* get n_cisano */
	sql_str[0] = '\0';
	sprintf(sql_str, "%s FROM %s%s %s %d",
	 "SELECT n_cisano ", "f_", catalog, "WHERE n_itemnum =", n_itemnum);
	status = SQLquery(sql_str, &temp_bufr, 512);
	if (status != SQL_S_SUCCESS) {
		MEMclose(&temp_bufr);
		switch (status) {
		case SQL_I_NO_ROWS_FOUND:
			sprintf(s, "%s %s %s \n",
				"PDMstorage_location_check: Could not find Catalog entry ",
				catalog);
			PDMdebug(s);
			return (PDM_E_NO_STO_LOC);
		case PDMS_NO_SUCH_TABLE:
			sprintf(s, "%s %s \n",
			"PDMstorage_location_check: Could not find Catalog ",
				catalog);
			PDMdebug(s);
			return (PDM_E_CATALOG_NOT_FOUND);
		default:
                        status = _PDMget_db_error (status);
                        return(status);
		}
	}
	status = MEMbuild_array(temp_bufr);
	if (status != MEM_S_SUCCESS) {
		MEMclose(&temp_bufr);
		sprintf(s, "%s %d\n",
			"PDMstorage_location_check: MEMbuild_array failed status ", status);
		PDMdebug(s);
		return (PDM_E_BUILD_ARRAY);
	}
	data = (char **) temp_bufr->data_ptr;
	*n_cisano = atol(data[0]);
	MEMclose(&temp_bufr);
	PDMdebug("EXIT:PDMstorage_location_check:\n");
	return (PDM_S_SUCCESS);
}

int PDMquery_partno(catalog, part, rev, n_itemno)
char           *catalog;
char           *part;
char           *rev;
int            *n_itemno;
{
	char		*fn = "PDMquery_partno";
	char            **data;
	char            sql_str[1024];
	MEMptr          temp_bufr = NULL;

	long            status;
	char		e_catalog[25];
	char		type[25];
        int		itemno;
        int		catno;

	PDMdebug("ENTER:PDMquery_partno\n");

	/* get n_itemno  */

	sql_str[0] = '\0';
	sprintf(sql_str, "%s FROM %s %s '%s' %s '%s'",
		"SELECT n_itemno ", catalog,
		"WHERE n_itemname = ", part,
		"AND n_itemrev = ", rev);
	status = SQLquery(sql_str, &temp_bufr, 512);
	if ((status != SQL_S_SUCCESS) 
                   && (status != SQL_I_NO_ROWS_FOUND)) {
	  MEMclose(&temp_bufr);
	  switch (status) {
	  case SQL_I_NO_ROWS_FOUND:
		  _PDMdebug (fn, "Could not find Catalog entry %s\n", catalog);
	  	return (PDM_E_NO_CAT_ENTRY);
	  case PDMS_NO_SUCH_TABLE:
	  	_PDMdebug (fn, "Could not find Catalog %s\n", catalog);
	  	return (PDM_E_CATALOG_NOT_FOUND);
	  default:
                        status = _PDMget_db_error (status);
                        return(status);
	  }
	}

/* Added code to check whether the catalog is EID or CID MaC 061593 */

     if (status == SQL_I_NO_ROWS_FOUND) {

       if (temp_bufr) MEMclose (&temp_bufr);
      
       type[0] = '\0';
       status = PDMquery_catalogtype_no (catalog, type, &catno);
       if (status != PDM_S_SUCCESS) {
	   MEMclose(&temp_bufr);
	   _PDMdebug (fn, "MEMbuild_array failed status 0x%.8x\n", status);
	   return (PDM_E_CATALOG_NOT_FOUND);
	}

       _PDMdebug (fn, "catalog type[%s]\n", type);

       if (!strcmp (type, "CID") || !strcmp(type, "EID")) {
        e_catalog[0] = '\0';
        sprintf (e_catalog, "e_%s", catalog);
        status = PDMquery_partno(e_catalog, part, rev, &itemno);
        if (status != PDM_S_SUCCESS) {
	   _PDMdebug (fn, "MEMbuild_array failed status 0x%.8x\n", status);
	   return (status);
	  }
        _PDMdebug (fn, "cat[%s]part[%s]rev[%s]itmno[%d]\n",
                                       e_catalog, part, rev, itemno);
        *n_itemno = itemno;
        _PDMdebug(fn, "EXIT:\n");
        return (PDM_S_SUCCESS);
        }        
        else {
	  _PDMdebug (fn, "Could not find Catalog entry %s\n", catalog);
	 return (PDM_E_NO_CAT_ENTRY);
         }
       }
        
	status = MEMbuild_array(temp_bufr);
	if (status != MEM_S_SUCCESS) {
	   MEMclose(&temp_bufr);
	   _PDMdebug (fn, "MEMbuild_array failed status 0x%.8x\n", status);
	   return (PDM_E_BUILD_ARRAY);
	}
	data = (char **) temp_bufr->data_ptr;
	*n_itemno = atol(data[0]);
	MEMclose(&temp_bufr);
PDMdebug("EXIT:PDMquery_partno:\n");
return (PDM_S_SUCCESS);
}

int 
PDMprint_exec(s1, PDMexec)
	char            s1[200];
PDMexec_ptr     PDMexec;
{
	FILE           *fp1, *fopen();

	fp1 = fopen("addr.dbg", "a");
	if (fp1 != NULL) {
		fprintf(fp1, "********************\n");
		fprintf(fp1, "%s\n", s1);
		fprintf(fp1, "catalog addr %d\n", PDMexec->catalog);
		fprintf(fp1, "part_num addr %d\n", PDMexec->part_num);
		fprintf(fp1, "revision addr %d\n", PDMexec->revision);
		fprintf(fp1, "ws_bufr addr %d\n\n", (PDMexec->ws_buffer));
		if (PDMexec->ws_buffer != NULL) {
			fprintf(fp1, "\tcolumn_ ptr %d\n",
				(PDMexec->ws_buffer)->column_ptr);
			fprintf(fp1, "\tformat ptr %d\n",
				(PDMexec->ws_buffer)->format_ptr);
			fprintf(fp1, "\tdata ptr %d\n",
				(PDMexec->ws_buffer)->data_ptr);
		}
		fprintf(fp1, "\n");
		fprintf(fp1, "ret_bufr addr %d\n\n", (PDMexec->return_buffer));
		if (PDMexec->return_buffer != NULL) {
			fprintf(fp1, "\tcolumn_ ptr %d\n",
				(PDMexec->return_buffer)->column_ptr);
			fprintf(fp1, "\tformat ptr %d\n",
				(PDMexec->return_buffer)->format_ptr);
			fprintf(fp1, "\tdata ptr %d\n",
				(PDMexec->return_buffer)->data_ptr);
		}
		fprintf(fp1, "********************\n");
		fclose(fp1);
	}
        return(PDM_S_SUCCESS);
}

int 
PDMquery_parttype(catalog, partnum, partrev, parttype)
	char           *catalog;
	char           *partnum;
	char           *partrev;
	char           *parttype;
{
	char            sql_str[512];
	char          **data;
	MEMptr          bufr = NULL;

	PDMdebug("ENTER:PDMquery_parttype\n");
	sql_str[0] = '\0';
	sprintf(sql_str, "%s %s %s '%s' %s '%s'",
		"SELECT p_parttype FROM ",
		catalog, "WHERE n_itemname = ", partnum,
		"AND n_itemrev = ", partrev);
	status = SQLquery(sql_str, &bufr, 512);
	if (status != SQL_S_SUCCESS) {
                        status = _PDMget_db_error (status);
                        return(status);
	}
	status = MEMbuild_array(bufr);
	if (status != MEM_S_SUCCESS) {
		sprintf(s, "MEMbuild_array failed status %d\n", status);
		PDMdebug(s);
		MEMclose(&bufr);
		return (PDM_E_BUILD_ARRAY);
	}
	data = (char **) bufr->data_ptr;
	strcpy(parttype, data[0]);
	MEMclose(&bufr);
	PDMdebug("EXIT:PDMquery_parttype\n");
	return (PDM_S_SUCCESS);
}

int 
PDMset_parttype(catalog, partnum, partrev, parttype)
	char           *catalog;
	char           *partnum;
	char           *partrev;
	char           *parttype;
{
	char            sql_str[512];

	PDMdebug("ENTER:PDMset_parttype\n");
	sql_str[0] = '\0';
	sprintf(sql_str, "%s %s %s '%s' %s '%s' %s '%s'",
		"UPDATE ", catalog, "SET p_parttype = ", parttype,
		"WHERE n_itemname = ", partnum,
		"AND n_itemrev = ", partrev);
	status = SQLstmt(sql_str);
	if (status != SQL_S_SUCCESS) {
                        status = _PDMget_db_error (status);
                        return(status);
	}
	PDMdebug("EXIT:PDMset_parttype\n");
	return (PDM_S_SUCCESS);
}

int 
PDMi_query_parmtype(family_name, attr_name, p_iotype)
	char           *family_name;
	char           *attr_name;
	char           *p_iotype;
{
	long            p_flyno;
	MEMptr          bufr = NULL;
	char          **data;
	char            sql_str[512];

	PDMdebug("ENTER:PDMi_query_parmtype\n");
	status = PDMi_query_familyno(family_name, &p_flyno);
	if (status != PDM_S_SUCCESS) {
		return (status);
	}
	sprintf(sql_str, "%s %s %d %s '%s'",
		"SELECT p_iotype FROM pdmparameters WHERE ",
		"p_familyno = ", p_flyno,
		"AND p_name = ", attr_name);
	status = SQLquery(sql_str, &bufr, 512);
	if (status != SQL_S_SUCCESS) {
		MEMclose(&bufr);
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
	strcpy(p_iotype, data[0]);
	sprintf(s, " name %s type %s\n", attr_name, p_iotype);
	PDMdebug(s);
	MEMclose(&bufr);
	PDMdebug("EXIT:PDMi_query_parmtype\n");
	return (PDM_S_SUCCESS);
}

int 
PDMi_get_partnum_rev(catalog, n_itemno, part_num, part_rev)
	char           *catalog;
	int             n_itemno;
	char           *part_num;
	char           *part_rev;
{
	char            sql_str[512];
	MEMptr          bufr = NULL;
	char          **data;

	PDMdebug("ENTER:PDMi_get_partnum_rev\n");
	sprintf(sql_str, "%s %s %s %d",
		"SELECT n_itemname,n_itemrev FROM ", catalog,
		"WHERE n_itemno = ", n_itemno);
	status = SQLquery(sql_str, &bufr, 512);
	if (status != SQL_S_SUCCESS) {
		MEMclose(&bufr);
	        sprintf(sql_str, "%s e_%s %s %d",
		"SELECT n_itemname,n_itemrev FROM ", catalog,
		"WHERE n_itemno = ", n_itemno);
	status = SQLquery(sql_str, &bufr, 512);
	if (status != SQL_S_SUCCESS) {
		MEMclose(&bufr);
		sprintf(s, "SQLquery failed status %d\n", status);
		PDMdebug(s);
                        status = _PDMget_db_error (status);
                        return(status);
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
	strcpy(part_num, data[0]);
	strcpy(part_rev, data[1]);
	PDMdebug("EXIT:PDMi_get_partnum_rev\n");
	return (PDM_S_SUCCESS);
}

/* Written to support BOM genereation - Kumar 070593 */

int PDMget_partnum_rev_CID(catalog, n_itemno, part_num, part_rev)
char           *catalog;
int             n_itemno;
char           *part_num;
char           *part_rev;
{
	char		*fn = "PDMget_partnum_rev_CID";
	char            sql_str[512];
	MEMptr          bufr = NULL;
	char          **data;

    PDMdebug("ENTER:PDMi_get_partnum_rev_CID\n");
    sprintf(sql_str, "%s e_%s %s %d",
    	"SELECT n_itemname,n_itemrev FROM ", catalog,
    	"WHERE n_itemno = ", n_itemno);

    status = SQLquery(sql_str, &bufr, 512);
    if (status != SQL_S_SUCCESS) {
      MEMclose(&bufr);
      sprintf(sql_str, "%s %s %s %d",
        "SELECT n_itemname,n_itemrev FROM ", catalog,
        "WHERE n_itemno = ", n_itemno);

      status = SQLquery(sql_str, &bufr, 512);
      if (status != SQL_S_SUCCESS) {
        MEMclose(&bufr);
        _PDMdebug (fn, "SQLquery failed status %d\n", status);
                        status = _PDMget_db_error (status);
                        return(status);
        }
    }

    status = MEMbuild_array(bufr);
    if (status != MEM_S_SUCCESS) {
        MEMclose(&bufr);
        _PDMdebug (fn, "MEMbuild_array failed status %d\n", status);
        return (PDM_E_BUILD_ARRAY);
    }
    data = (char **) bufr->data_ptr;
    strcpy(part_num, data[0]);
    strcpy(part_rev, data[1]);
    PDMdebug("EXIT:PDMget_partnum_rev_CID\n");
    return (PDM_S_SUCCESS);
}

int 
PDMi_get_cidate(catalog, part_num, part_rev, n_cidate, n_citime)
	char           *catalog;
	char           *part_num;
	char           *part_rev;
	char           *n_cidate;
	char           *n_citime;
{
	char            sql_str[512];
	int             n_itemno;
	MEMptr          bufr = NULL;
	char          **data;
	char            date2[20];
	char            time2[20];
	int             i, nx;

	PDMdebug("ENTER:PDMi_get_cidate\n");
	status = PDMquery_partno(catalog, part_num, part_rev, &n_itemno);
	if (status != PDM_S_SUCCESS) {
		sprintf(s, "PDMquery_partno failed status %d\n",
			status);
		PDMdebug(s);
		return (status);
	}
	i = 0;
	sprintf(sql_str, "%s f_%s %s %d %s %d",
		"SELECT n_cidate,n_citime,n_fileno FROM ", catalog,
		"WHERE n_itemnum = ", n_itemno,
		"AND n_fileversion > ", i);
	status = SQLquery(sql_str, &bufr, 512);
	if (status != SQL_S_SUCCESS) {
		MEMclose(&bufr);
		sprintf(s, "SQLquery failed status %d\n", status);
		PDMdebug(s);
                        status = _PDMget_db_error (status);
                        return(status);
	}
	status = MEMbuild_array(bufr);
	if (status != MEM_S_SUCCESS) {
		MEMclose(&bufr);
		sprintf(s, "MEMbuild_array failed status %d\n", status);
		PDMdebug(s);
		return (PDM_E_BUILD_ARRAY);
	}
	data = (char **) bufr->data_ptr;
	strcpy(date2, data[0]);
	strcpy(time2, data[1]);
	for (i = 1; i < bufr->rows; i++) {
		nx = i * bufr->columns;
		status = PDMi_compare_dates(date2, time2, data[nx], data[nx + 1]);
		if (status == 1) {
			strcpy(date2, data[nx]);
			strcpy(time2, data[nx + 1]);
		} else if (status == -1) {
			PDMdebug("PDMcompare_dates failed\n");
		}
	}
	MEMclose(&bufr);
	strcpy(n_cidate, date2);
	strcpy(n_citime, time2);
	PDMdebug("EXIT:PDMi_get_cidate\n");
	return (PDM_S_SUCCESS);
}

int 
PDMi_find_cofilename(catalog, part_num,
		     part_rev, filename)
	char           *catalog;
	char           *part_num;
	char           *part_rev;
	char           *filename;
{
	char            sql_str[512];
	int             n_itemno;
	MEMptr          bufr = NULL;
	char          **data;
	int             n_fileversion;

	PDMdebug("ENTER:PDMi_find_cofilename\n");
	status = PDMquery_partno(catalog, part_num, part_rev, &n_itemno);
	if (status != PDM_S_SUCCESS) {
		sprintf(s, "PDMquery_partno failed status %d\n",
			status);
		PDMdebug(s);
		return (status);
	}
	sprintf(sql_str, "%s f_%s %s %d ",
		"SELECT MIN(n_fileversion) FROM ", catalog,
		"WHERE n_itemnum = ", n_itemno);
	status = SQLquery(sql_str, &bufr, 512);
	if (status != SQL_S_SUCCESS) {
		MEMclose(&bufr);
		sprintf(s, "SQLquery failed status %d\n", status);
		PDMdebug(s);
                        status = _PDMget_db_error (status);
                        return(status);
	}
	status = MEMbuild_array(bufr);
	if (status != MEM_S_SUCCESS) {
		MEMclose(&bufr);
		sprintf(s, "MEMbuild_array failed status %d\n", status);
		PDMdebug(s);
		return (PDM_E_BUILD_ARRAY);
	}
	data = (char **) bufr->data_ptr;
	n_fileversion = atol(data[0]);
	MEMclose(&bufr);
	bufr = NULL;
	sprintf(sql_str, "%s f_%s %s %d %s %d ORDER BY n_cofilename",
		"SELECT n_cofilename FROM ", catalog,
		"WHERE n_itemnum = ", n_itemno,
		"AND n_fileversion = ", n_fileversion);
	status = SQLquery(sql_str, &bufr, 512);
	if (status != SQL_S_SUCCESS) {
		MEMclose(&bufr);
		sprintf(s, "SQLquery failed status %d\n", status);
		PDMdebug(s);
                        status = _PDMget_db_error (status);
                        return(status);
	}
	status = MEMbuild_array(bufr);
	if (status != MEM_S_SUCCESS) {
		MEMclose(&bufr);
		sprintf(s, "MEMbuild_array failed status %d\n", status);
		PDMdebug(s);
		return (PDM_E_BUILD_ARRAY);
	}
	data = (char **) bufr->data_ptr;
	strcpy(filename, data[0]);
	MEMclose(&bufr);
	PDMdebug("EXIT:PDMi_find_cofilename\n");
	return (PDM_S_SUCCESS);
}

/*
 * part_no is used to load cols item_name,item_rev in bufr
 */

int 
PDMload_partdata(bufr)
	MEMptr          bufr;
{
	char            sql_str[512];
	int             i, j, nxj, nxi;
	int             n1, n2, n3, n4;
	char          **data, **column, **data1;
	MEMptr          bufr1 = NULL;
        char           *fname = "PDMload_partdata";

	_PDMdebug(fname,"ENTER:\n");
	status = MEMbuild_array(bufr);
	if (status != MEM_S_SUCCESS) {
		_PDMdebug(fname, "MEMbuild_array failed status %d\n", status);
		return (PDM_E_BUILD_ARRAY);
	}
	column = (char **) bufr->column_ptr;
	n1 = -1;
	n2 = -1;
	n3 = -1;
	n4 = -1;
	for (i = 0; i < bufr->columns; i++) {
		if (!strcmp(column[i], "n_catalogname"))
			n1 = i;
		if (!strcmp(column[i], "n_itemno"))
			n2 = i;
		if (!strcmp(column[i], "n_itemname"))
			n3 = i;
		if (!strcmp(column[i], "n_itemrev"))
			n4 = i;
	}
	if (n1 == -1 || n2 == -1 || n3 == -1 || n4 == -1) {
		PDMdebug("Couldnot find reqd columns in <bufr>\n");
		return (PDM_E_BUFFER_FORMAT);
	}
	data = (char **) bufr->data_ptr;
	for (i = 0; i < bufr->rows; i++)
          {
	   nxi = i * bufr->columns;
	   status = MEMwrite_data(bufr, "", i + 1, n3 + 1);
	   if (status != MEM_S_SUCCESS)
           {
	   _PDMdebug(fname, "MEMwrite_data failed status %d\n", status);
	    return (PDM_E_WRITE_COLUMN);
	    }
	}
	for (i = 0; i < bufr->rows; i++)
          {
	nxi = i * bufr->columns;
	if (!strlen(data[nxi + n3])) 
          {
	  sprintf(sql_str, "%s %s %s %s ",
		"SELECT n_itemname,n_itemrev FROM ", data[nxi + n1],
				"WHERE n_itemno = ", data[nxi + n2]);
		status = SQLquery(sql_str, &bufr1, 512);
		if (status != SQL_S_SUCCESS)
                  {
		   MEMclose(&bufr1);
		   _PDMdebug(fname, "SQLquery failed status %d\n", status);
                        status = _PDMget_db_error (status);
                        return(status);
		   }
		status = MEMbuild_array(bufr1);
		if (status != MEM_S_SUCCESS)
                  {
		   MEMclose(&bufr1);
                   /* Cleaning up the local filemanager */
                sprintf(sql_str,"delete from nfmsafiles where n_itemno = %s and n_catalogno = (select n_catalogno from nfmcatalogs where n_catalogname = '%s')",data[nxi+n2],data[nxi+n1]);
                   SQLstmt(sql_str);
	          _PDMdebug(fname, "MEMbuild_array failed status %d\n", status);
                    continue;
		   }
		   data1 = (char **) bufr1->data_ptr;
		   for (j = 0; j < bufr->rows; j++)
                   {
		   nxj = j * bufr->columns;
		   if (!strlen(data[nxj + n3]) &&
		      !strcmp(data[nxj + n1], data[nxi + n1]) &&
		      !strcmp(data[nxj + n2], data[nxi + n2])) 
                     {
		      status = MEMwrite_data(bufr, data1[0], j + 1, n3 + 1);
		      if (status != MEM_S_SUCCESS)
                      {
		      MEMclose(&bufr1);
	           _PDMdebug(fname, "MEMwrite_data failed status %d\n", status);
			return (PDM_E_WRITE_COLUMN);
		       }
	              status = MEMwrite_data(bufr, data1[1], j + 1, n4 + 1);
		      if (status != MEM_S_SUCCESS)
                        {
			MEMclose(&bufr1);
     		   _PDMdebug(fname, "MEMwrite_data failed status %d\n", status);
			return (PDM_E_WRITE_COLUMN);
			}
		      }
		    }
		    MEMclose(&bufr1);
		    bufr1 = NULL;
	     }
	  }
	_PDMdebug(fname,"EXIT:\n");
	return (PDM_S_SUCCESS);
}

/*
 * bufr should have the following columns
 * 
 * n_catalogname   or n_catalogname n_itemname		or n_itemname
 * n_itemrev       or n_itemrev n_catalogno n_itemno
 * 
 */

int 
PDMload_partnos(bufr)
	MEMptr          bufr;
{
	int             i, j, nxj, nxi;
	int             n1, n2, n3, n4, n5;
	char          **data, **column;
	char            s_catno[40], s_partno[40];
	int             catno, partno;

	PDMdebug("ENTER:PDMload_partnos\n");
	status = MEMbuild_array(bufr);
	if (status != MEM_S_SUCCESS) {
		sprintf(s, "MEMbuild_array failed status %d\n",
			status);
		PDMdebug(s);
		return (PDM_E_BUILD_ARRAY);
	}
	column = (char **) bufr->column_ptr;
	n1 = -1;
	n2 = -1;
	n3 = -1;
	n4 = -1;
	n5 = -1;
	for (i = 0; i < bufr->columns; i++) {
	if (!strcmp(column[i], "n_catalogname")) n1 = i;
        else	if (!strcmp(column[i], "n_itemname") ) n2 = i;
        else	if (!strcmp(column[i], "n_itemrev") ) n3 = i;
        else	if (!strcmp(column[i], "n_catalogno") ) n4 = i;
        else	if (!strcmp(column[i], "n_itemno") ) n5 = i;
	}
	if (n1 == -1 || n2 == -1 || n3 == -1 ||
	    n4 == -1 || n5 == -1) {
		PDMdebug("Couldnot find reqd columns in <bufr>\n");
		return (PDM_E_BUFFER_FORMAT);
	}
	data = (char **) bufr->data_ptr;
	for (i = 0; i < bufr->rows; i++) {
		nxi = i * bufr->columns;
		if (!strlen(data[nxi + n4])) {
			s_catno[0] = '\0';
			s_partno[0] = '\0';
			status = PDMquery_catalog_partnos(
					     data[nxi + n1], data[nxi + n2],
					   data[nxi + n3], &catno, &partno);
			if (status != PDM_S_SUCCESS) {
				sprintf(s, "%s %d \n",
				  "PDMquery_catalog_partnos failed status ",
					status);
				PDMdebug(s);
				return (status);
			}
			sprintf(s_catno, "%d", catno);
			sprintf(s_partno, "%d", partno);

			for (j = 0; j < bufr->rows; j++) {
				nxj = j * bufr->columns;
				if (!strcmp(data[nxi + n1], data[nxj + n1]) &&
				  !strcmp(data[nxi + n2], data[nxj + n2]) &&
				  !strcmp(data[nxi + n3], data[nxj + n3])) {
					sprintf(s, "s_catno -> %s\n", s_catno);
					PDMdebug(s);
					sprintf(s, "s_partno -> %s\n", s_partno);
					PDMdebug(s);
					status = MEMwrite_data(bufr, s_catno, j + 1, n4 + 1);
					if (status == MEM_S_SUCCESS)
						status = MEMwrite_data(bufr, s_partno, j + 1, n5 + 1);
					if (status != MEM_S_SUCCESS) {
						sprintf(s, "MEMwrite_data failed status %d\n",
							status);
						PDMdebug(s);
						return (PDM_E_WRITE_COLUMN);
					}
				}
			}
		}
	}
	PDMdebug("EXIT:PDMload_partnos\n");
	return (PDM_S_SUCCESS);
}

/*
 * Loads n_itemname from pdmfmgr
 * 
 * bufr should have the following columns
 * 
 * part_num	  (n_itemname of pdmfmgr) n_catalogno n_itemno
 * 
 */

int 
PDMload_partnums(bufr)
	MEMptr          bufr;
{
	int             i, j, nxj, nxi;
	int             n3, n4, n5;
	char          **data, **column;
	char            s_part_num[40];
	int             part_num;

	PDMdebug("ENTER:PDMload_partnums\n");
	if (PDMdebug_on) {
		MEMprint_buffer("bufr at ENTER", bufr, PDM_DEBUG_FILE);
	}
	status = MEMbuild_array(bufr);
	if (status != MEM_S_SUCCESS) {
		sprintf(s, "MEMbuild_array failed status %d\n",
			status);
		PDMdebug(s);
		return (PDM_E_BUILD_ARRAY);
	}
	column = (char **) bufr->column_ptr;
	n3 = -1;
	n4 = -1;
	n5 = -1;
	for (i = 0; i < bufr->columns; i++) {
		if (!strcmp(column[i], "part_num"))
			n3 = i;
		if (!strcmp(column[i], "n_catalogno"))
			n4 = i;
		if (!strcmp(column[i], "n_itemno"))
			n5 = i;
	}
	if (n3 == -1 || n4 == -1 || n5 == -1) {
		PDMdebug("Couldnot find reqd columns in <bufr>\n");
		return (PDM_E_BUFFER_FORMAT);
	}
	data = (char **) bufr->data_ptr;
	for (i = 0; i < bufr->rows; i++) {
		nxi = i * bufr->columns;
		if (!strlen(data[nxi + n3])) {
			s_part_num[0] = '\0';
			status = PDMi_find_partnum(
						   atol(data[nxi + n4]),
					   atol(data[nxi + n5]), &part_num);
			if (status != PDM_S_SUCCESS) {
				sprintf(s, "%s %d \n",
					"PDMi_find_partnum failed status ",
					status);
				PDMdebug(s);
				return (status);
			}
			sprintf(s_part_num, "%d", part_num);
			for (j = 0; j < bufr->rows; j++) {
				nxj = j * bufr->columns;
				if (!strcmp(data[nxi + n4], data[nxj + n4]) &&
				  !strcmp(data[nxi + n5], data[nxj + n5])) {
					status = MEMwrite_data(bufr, s_part_num, j + 1, n3 + 1);
					if (status != MEM_S_SUCCESS) {
						sprintf(s, "MEMwrite_data failed status %d\n",
							status);
						PDMdebug(s);
						return (PDM_E_WRITE_COLUMN);
					}
				}
			}
		}
	}
	if (PDMdebug_on) {
		MEMprint_buffer("bufr at EXIT", bufr, PDM_DEBUG_FILE);
	}
	PDMdebug("EXIT:PDMload_partnums\n");
	return (PDM_S_SUCCESS);
}

/*
 * Loads p_filenos from pdmfmgr
 * 
 * bufr should have the following columns
 * 
 * part_num	  (n_itemname of pdmfmgr) p_fileno
 */

int 
PDMload_filenos(p_sano, bufr)
	int             p_sano;
	MEMptr          bufr;
{
	MEMptr          bufr3 = NULL;
	char            sql_str[300];
	int             i, j, nxj, nxi;
	int             n1, n2, n3, n4;
	char          **data, **column;
	char          **data1;

	PDMdebug("ENTER:PDMload_filenos\n");
	if (PDMdebug_on) {
		MEMprint_buffer("bufr at ENTER", bufr, PDM_DEBUG_FILE);
	}
	status = MEMbuild_array(bufr);
	if (status != MEM_S_SUCCESS) {
		sprintf(s, "MEMbuild_array failed status %d\n",
			status);
		PDMdebug(s);
		return (PDM_E_BUILD_ARRAY);
	}
	column = (char **) bufr->column_ptr;
	n1 = -1;
	n2 = -1;
	n3 = -1;
	n4 = -1;
	for (i = 0; i < bufr->columns; i++) {
		if (!strcmp(column[i], "n_catalogno"))
			n1 = i;
		if (!strcmp(column[i], "n_itemno"))
			n2 = i;
		if (!strcmp(column[i], "p_fileno"))
			n3 = i;
		if (!strcmp(column[i], "part_num"))
			n4 = i;
	}
	if (n1 == -1 || n2 == -1 || n3 == -1 || n4 == -1) {
		PDMdebug("Couldnot find reqd columns in <bufr>\n");
		return (PDM_E_BUFFER_FORMAT);
	}
	data = (char **) bufr->data_ptr;
	for (i = 0; i < bufr->rows; i++) {
		nxi = i * bufr->columns;
		if (!strlen(data[nxi + n3])) {
			sprintf(sql_str, "%s %s %d %s %d",
				"SELECT p_fileno FROM pdmfmgr ",
				"WHERE p_sano = ", p_sano,
				"AND n_itemname = ", atol(data[nxi + n4]));
			status = SQLquery(sql_str, &bufr3, 1024);
			if (status != SQL_S_SUCCESS) {
				MEMclose(&bufr3);
				bufr3 = NULL;
				if (status != SQL_I_NO_ROWS_FOUND) {
					sprintf(s, "SQLquery failed status %d \n", status);
					PDMdebug(s);
                        status = _PDMget_db_error (status);
                        return(status);
				} else {
					sprintf(s, "%s %d %s %d\n",
						"No p_fileno in pdmfmgr for partnum ",
						atol(data[nxi + n4]), " and p_sano ", p_sano);
					PDMdebug(s);
				}
			} else {
				status = MEMbuild_array(bufr3);
				if (status != MEM_S_SUCCESS) {
					sprintf(s, "MEMbuild_array failed status %d\n",
						status);
					PDMdebug(s);
					return (PDM_E_BUILD_ARRAY);
				}
				data1 = (char **) bufr3->data_ptr;
				for (j = 0; j < bufr->rows; j++) {
					nxj = j * bufr->columns;
					if (!strcmp(data[nxi + n1], data[nxj + n1]) &&
					    !strcmp(data[nxi + n2], data[nxj + n2])) {
						status = MEMwrite_data(bufr, data1[0], j + 1, n3 + 1);
						if (status != MEM_S_SUCCESS) {
							MEMclose(&bufr3);
							sprintf(s, "MEMwrite_data failed status %d\n",
								status);
							PDMdebug(s);
							return (PDM_E_WRITE_COLUMN);
						}
					}
				}
				MEMclose(&bufr3);
				bufr3 = NULL;
			}
		}
	}
	if (PDMdebug_on) {
		MEMprint_buffer("bufr at EXIT", bufr, PDM_DEBUG_FILE);
	}
	PDMdebug("EXIT:PDMload_filenos\n");
	return (PDM_S_SUCCESS);
}

int 
PDMi_query_catalogname(catno, catalog)
	char           *catno;
	char           *catalog;
{
	char          **data;
	char            sql_str[1024];
	MEMptr          temp_bufr = NULL;

	long            status;

	PDMdebug("ENTER:PDMi_query_catalogname\n");

	/* get n_setindicator from the catalog */

	sql_str[0] = '\0';
	sprintf(sql_str, "SELECT n_catalogname FROM nfmcatalogs %s %s",
		"WHERE n_catalogno = ", catno);
	status = SQLquery(sql_str, &temp_bufr, 512);
	if (status != SQL_S_SUCCESS) {
		MEMclose(&temp_bufr);
		switch (status) {
		case SQL_I_NO_ROWS_FOUND:
			sprintf(s, "%s n_catalogno <%d> \n",
			     "Could not find CatalogName in nfmsetcit for ",
				atoi(catno));
			PDMdebug(s);
			return (PDM_I_NO_ROWS_FOUND);
		case PDMS_NO_SUCH_TABLE:
			sprintf(s, "%s \n",
				"Could not find nfmsetcit ");
			PDMdebug(s);
			return (PDM_E_TABLE_NOT_FOUND);
		default:
                        status = _PDMget_db_error (status);
                        return(status);
		}
	}
	status = MEMbuild_array(temp_bufr);
	if (status != MEM_S_SUCCESS) {
		MEMclose(&temp_bufr);
		sprintf(s, "%s %d\n",
			"MEMbuild_array failed status ", status);
		PDMdebug(s);
		return (PDM_E_BUILD_ARRAY);
	}
	data = (char **) temp_bufr->data_ptr;
	strcpy(catalog, data[0]);
	MEMclose(&temp_bufr);
	PDMdebug("EXIT:PDMi_query_catalogname\n");
	return (PDM_S_SUCCESS);
}

int 
PDMi_query_partnumrev(catno, catalog, n_itemno,
		      n_itemname, n_itemrev)
	char           *catno;
	char           *catalog;
	char           *n_itemno;
	char           **n_itemname;
	char           **n_itemrev;
{
	char          **data;
	char            sql_str[1024];
	MEMptr          temp_bufr = NULL;
	long            status;

	PDMdebug("ENTER:PDMi_query_partnumrev\n");

/* COMMENT OUT (on) -- 6/5/91

	status = MEMopen(&bufr1, 1024);
	if (status != MEM_S_SUCCESS) {
		sprintf(s, "MEMopen failed status %d\n",
			status);
		PDMdebug(s);
		return (PDM_E_OPEN_BUFFER);
	}
	status = MEMwrite_format(bufr1, "n_nfmname", "char(40)");
	if (status == MEM_S_SUCCESS)
		status = MEMwrite_format(bufr1, "n_tableno", "integer");
	if (status == MEM_S_SUCCESS)
		status = MEMwrite_format(bufr1, "n_tablename", "char(40)");
	if (status == MEM_S_SUCCESS)
		status = MEMwrite_format(bufr1, "n_tabletype", "char(40)");
	if (status == MEM_S_SUCCESS)
		status = MEMwrite_format(bufr1, "n_name", "char(40)");
	if (status != MEM_S_SUCCESS) {
		MEMclose(&bufr1);
		sprintf(s, "MEMwrite_format failed status %d\n",
			status);
		PDMdebug(s);
		return (PDM_E_OPEN_BUFFER);
	}
	sprintf(s, "%s\1\1%s\1%s\1\1", "n_itemname", catno, "nfmattributes", "");
	status = MEMwrite(bufr1, s);
	if (status != MEM_S_SUCCESS) {
		MEMclose(&bufr1);
		sprintf(s, "MEMwrite failed status %d\n",
			status);
		PDMdebug(s);
		return (PDM_E_WRITE_ROW);
	}
	sprintf(s, "%s\1\1%s\1%s\1\1", "n_itemrev", catno, "nfmattributes", "");
	status = MEMwrite(bufr1, s);
	if (status != MEM_S_SUCCESS) {
		MEMclose(&bufr1);
		sprintf(s, "MEMwrite failed status %d\n",
			status);
		PDMdebug(s);
		return (PDM_E_WRITE_ROW);
	}
	sprintf(s, "%s\1\1%s\1%s\1\1", "n_itemno", catno, "nfmattributes", "");
	status = MEMwrite(bufr1, s);
	if (status != MEM_S_SUCCESS) {
		MEMclose(&bufr1);
		sprintf(s, "MEMwrite failed status %d\n",
			status);
		PDMdebug(s);
		return (PDM_E_WRITE_ROW);
	}
	status = PDMload_nnames(bufr1);
	{
		sprintf(s, "PDMload_nnames failed status %d\n",
			status);
		PDMdebug(s);
		return (status);
	}
	status = MEMbuild_array(bufr1);
	if (status != MEM_S_SUCCESS) {
		MEMclose(&bufr1);
		sprintf(s, "MEMbuild_array failed status %d\n",
			status);
		PDMdebug(s);
		return (PDM_E_BUILD_ARRAY);
	}
	data = (char **) bufr1->data_ptr;
	for (i = 0; i < bufr1->rows; i++) {
		n[i] = i * bufr1->columns + 4;
	}
	sql_str[0] = '\0';
	sprintf(sql_str, "SELECT %s,%s FROM %s WHERE %s = %s",
		data[n[0]], data[n[1]], catalog, data[n[2]], n_itemno);
	MEMclose(&bufr1);

   COMMENT OUT (off) */

/* ADDED NEXT 3 LINES -- 6/5/91 */

	sql_str[0] = '\0';
	sprintf(sql_str, "SELECT %s,%s FROM %s WHERE %s = %s",
		"n_itemname","n_itemrev",catalog,"n_itemno",n_itemno);
	status = SQLquery(sql_str, &temp_bufr, 512);
	if (status != SQL_S_SUCCESS) {
		MEMclose(&temp_bufr);
		switch (status) {
		case SQL_I_NO_ROWS_FOUND:
			sprintf(s, "%s \n",
				"Could not find Part ");
			PDMdebug(s);
			return (PDM_E_PART_NOT_FOUND);
		case PDMS_NO_SUCH_TABLE:
			sprintf(s, "%s %s \n",
				"Could not find Catalog ", catalog);
			PDMdebug(s);
			return (PDM_E_CATALOG_NOT_FOUND);
		default:
                        status = _PDMget_db_error (status);
                        return(status);
		}
	}
	status = MEMbuild_array(temp_bufr);
	if (status != MEM_S_SUCCESS) {
		MEMclose(&temp_bufr);
		sprintf(s, "%s %d\n",
			"MEMbuild_array failed status ", status);
		PDMdebug(s);
		sprintf(s, "%s \n", catno);
		PDMdebug(s);
		return (PDM_E_BUILD_ARRAY);
	}
	if (PDMdebug_on)
		MEMprint_buffer("TEMP_BUFR", temp_bufr, PDM_DEBUG_FILE);

	data = (char **) temp_bufr->data_ptr;
	*n_itemname = (char *) malloc(strlen(data[0]) + 5);
	if (n_itemname == NULL) {
		MEMclose(&temp_bufr);
		PDMdebug("Could not malloc \n");
		return (PDM_E_COULD_NOT_MALLOC);
	}
	*n_itemrev = (char *) malloc(strlen(data[1]) + 5);
	if (n_itemrev == NULL) {
		free(n_itemname);
		MEMclose(&temp_bufr);
		PDMdebug("Could not malloc \n");
		return (PDM_E_COULD_NOT_MALLOC);
	}
	strcpy(*n_itemname, data[0]);
        sprintf(s,"P_PARTNUM = %s\n",*n_itemname);
        PDMdebug(s);
	strcpy(*n_itemrev, data[1]);
        sprintf(s,"P_REVISION = %s\n",*n_itemrev);
        PDMdebug(s);
	MEMclose(&temp_bufr);
	PDMdebug("EXIT:PDMi_query_partnumrev\n");
	return (PDM_S_SUCCESS);
}

int 
PDMquery_table_no(table, p_tableno)
	char           *table;
	int            *p_tableno;
{
	char          **data;
	char            sql_str[1024];
	MEMptr          temp_bufr = NULL;

	long            status;

	PDMdebug("ENTER:PDMquery_tableno\n");
	/* get p_tableno */
	sql_str[0] = '\0';
	sprintf(sql_str, "%s FROM %s %s '%s'",
		"SELECT n_tableno ", "nfmtables",
		"WHERE n_tablename = ", table);
	status = SQLquery(sql_str, &temp_bufr, 512);
	if (status != SQL_S_SUCCESS) {
		MEMclose(&temp_bufr);
		switch (status) {
		case SQL_I_NO_ROWS_FOUND:
			sprintf(s, "%s %s\n",
			  "PDMquery_tableno: Could not find Catalog entry ",
				table);
			PDMdebug(s);
			return (PDM_E_NO_CAT_ENTRY);
		case PDMS_NO_SUCH_TABLE:
			sprintf(s, "%s %s \n",
				"PDMquery_tableno: Could not find Catalog ",
				table);
			PDMdebug(s);
			return (PDM_E_CATALOG_NOT_FOUND);
		default:
                        status = _PDMget_db_error (status);
                        return(status);
		}
	}
	status = MEMbuild_array(temp_bufr);
	if (status != MEM_S_SUCCESS) {
		MEMclose(&temp_bufr);
		sprintf(s, "%s %d\n",
			"PDMquery_table_partnos: MEMbuild_array failed status ", status);
		PDMdebug(s);
		return (PDM_E_BUILD_ARRAY);
	}
	data = (char **) temp_bufr->data_ptr;
	*p_tableno = atol(data[0]);
	MEMclose(&temp_bufr);
	PDMdebug("EXIT:PDMquery_tableno:\n");
	return (PDM_S_SUCCESS);
}

int 
PDMquery_file_status(catalog, n_itemname, n_itemrev,
		     n_status)
	char           *catalog;
	char           *n_itemname;
	char           *n_itemrev;
	char          **n_status;
{
	char          **data;
	char            sql_str[1024];
	MEMptr          temp_bufr = NULL;

	long            status;

	PDMdebug("ENTER:PDMquery_file_status\n");

	/* get n_setindicator from the catalog */

	sql_str[0] = '\0';
	sprintf(sql_str, "%s FROM %s %s '%s' %s '%s'",
		"SELECT n_status ", catalog,
		"WHERE n_itemname = ", n_itemname,
		"AND n_itemrev = ", n_itemrev);

	status = SQLquery(sql_str, &temp_bufr, 512);
	if (status != SQL_S_SUCCESS) {
		MEMclose(&temp_bufr);
		switch (status) {
		case SQL_I_NO_ROWS_FOUND:
			sprintf(s, "%s %s %s %s \n",
				"PDMquery_assembly_ind : ",
				"Could not find Part ",
				n_itemname, n_itemrev);
			PDMdebug(s);
			return (PDM_E_PART_NOT_FOUND);
		case PDMS_NO_SUCH_TABLE:
			sprintf(s, "%s %s \n",
			    "PDMquery_file_status: Could not find Catalog ",
				catalog);
			PDMdebug(s);
			return (PDM_E_CATALOG_NOT_FOUND);
		default:
                        status = _PDMget_db_error (status);
                        return(status);
		}
	}
	status = MEMbuild_array(temp_bufr);
	if (status != MEM_S_SUCCESS) {
		MEMclose(&temp_bufr);
		sprintf(s, "%s %s %d\n",
			"PDMquery_file_status: MEMbuild_array ",
			"failed status ", status);
		PDMdebug(s);
		return (PDM_E_BUILD_ARRAY);
	}
	data = (char **) temp_bufr->data_ptr;
	*n_status = (char *) malloc(sizeof(char) * 3);
        memset(*n_status,NULL,(sizeof(char) * 3));
	strcpy(*n_status, data[0]);
	sprintf("File status %s\n", *n_status);
	PDMdebug(s);
	MEMclose(&temp_bufr);
	PDMdebug("EXIT:PDMquery_file_status\n");
	return (PDM_S_SUCCESS);
}



/* This function returns the latest revision[first row],part type,
and the description of the part number, once the catalog has been 
entered
Kumar 9/27/91*/
/* If a catalog name has been entered and the user enter a part number,
verify that the catalog contains the part number. Then display the 
latest revision,part_type, and description */

int PDMget_part_info(temp_bufr)
  MEMptr *temp_bufr;
{
  char   sql_str[512];

  *temp_bufr = NULL;
sprintf(sql_str,"%s FROM %s %s '%s' %s ",
   "SELECT n_itemrev,n_itemdesc,p_parttype ",PDMexec->catalog,
   "WHERE n_itemname = ",PDMexec->part_num,
   "ORDER BY  n_itemrev");

   status = SQLquery(sql_str,temp_bufr,512);
   if(status != SQL_S_SUCCESS)
   {
                MEMclose(temp_bufr);
                switch(status)
                {
                        case SQL_I_NO_ROWS_FOUND :
                                 sprintf(s,"%s %s %s %s \n",
                                 "PDMget_children: Could not find Part ",
                                 PDMexec->part_num,PDMexec->revision);
                                 PDMdebug(s);
                                 return(PDM_E_PART_NOT_FOUND);
                        case PDMS_NO_SUCH_TABLE:
                                 sprintf(s,"%s %s \n",
                                 "PDMget_children: Could not find Catalog ",
                                 PDMexec->catalog);
                                 PDMdebug(s);
                                 return(PDM_E_CATALOG_NOT_FOUND);
                        default:
                        status = _PDMget_db_error (status);
                        return(status);
                }
   }
     PDMdebug("EXIT: PDMget_part_info\n");
     return(PDM_S_SUCCESS);
}


int PDMget_file_names(temp_bufr)
  MEMptr *temp_bufr;
{
  char   sql_str[512];
  char   *fn = "PDMget_file_names";
  char   **temp_data, **macro_data;
  MEMptr temp_bufr1 = NULL;

  *temp_bufr = NULL;
  _PDMdebug (fn, "ENTER\n");

sprintf(sql_str," SELECT f_%s.n_cofilename,f_%s.n_filetype FROM f_%s,%s WHERE %s.n_itemname = '%s' AND %s.n_itemrev = '%s' AND %s.n_itemno = f_%s.n_itemnum  AND f_%s.n_fileversion = (SELECT MAX(n_fileversion) FROM f_%s WHERE %s.n_itemno = f_%s.n_itemnum) ORDER BY n_cofilename",PDMexec->catalog, PDMexec->catalog, PDMexec->catalog,PDMexec->catalog, PDMexec->catalog,PDMexec->part_num,PDMexec->catalog,PDMexec->revision,PDMexec->catalog,PDMexec->catalog, PDMexec->catalog,PDMexec->catalog,PDMexec->catalog,PDMexec->catalog);

   status = SQLquery(sql_str,temp_bufr,512);
   if(status != SQL_S_SUCCESS)
   {
                MEMclose(temp_bufr);
                switch(status)
                {
                        case SQL_I_NO_ROWS_FOUND :
                                 sprintf(s,"%s %s %s %s \n",
                                 "PDMget_children: Could not find Part ",
                                 PDMexec->part_num,PDMexec->revision);
                                 PDMdebug(s);
                                 return(PDM_I_NO_FILES_FOUND);
                        case PDMS_NO_SUCH_TABLE:
                                 sprintf(s,"%s %s \n",
                                 "PDMget_children: Could not find Catalog ",
                                 PDMexec->catalog);
                                 PDMdebug(s);
                                 return(PDM_E_CATALOG_NOT_FOUND);
                        default:
                           {
        sprintf(sql_str,"SELECT p_macrocat,p_macropartno,p_macrorev FROM pdmparamloc WHERE n_catalogname = '%s'", PDMexec->catalog);
         status = SQLquery(sql_str,&temp_bufr1,512);
            if(status != SQL_S_SUCCESS)
                   return(PDM_E_SQL_QUERY);
          else
             {
              status = MEMbuild_array(temp_bufr1);
               if(status != MEM_S_SUCCESS)
                {
                  MEMclose(&temp_bufr1);
                  return(status);
                }
             macro_data = (char **) temp_bufr1->data_ptr;
sprintf(sql_str," SELECT t2.n_cofilename,t2.n_filetype FROM f_%s t2,%s t1 WHERE t1.n_itemname = '%s' AND t1.n_itemrev = '%s' AND t1.n_itemno = t2.n_itemnum  AND t2.n_fileversion = (SELECT MAX(n_fileversion) FROM f_%s t2 WHERE t1.n_itemno = t2.n_itemnum) ORDER BY n_cofilename",macro_data[0], macro_data[0], macro_data[1],macro_data[2],macro_data[0]);
              if (*temp_bufr != NULL) MEMclose(temp_bufr);
         status = SQLquery(sql_str,temp_bufr,512);
                  if(status != SQL_S_SUCCESS)
                       {
                         MEMclose(temp_bufr);
                        status = _PDMget_db_error (status);
                        return(status);
                       }
                   MEMclose(&temp_bufr1);
                }
               }
             }
     }
     if((*temp_bufr)->rows == 1) 
       {
         status = MEMbuild_array(*temp_bufr);
          if(status != MEM_S_SUCCESS)
           {
             MEMclose(temp_bufr);
            sprintf(s,"%s \n", "PDMget_file_names: Could not get file names ");
                                 PDMdebug(s);
                                 return(PDM_I_NO_FILES_FOUND);
           }
               temp_data = (char**) (*temp_bufr)->data_ptr;
           if(!strcmp(temp_data[0],"") || (temp_data[0] == NULL))
              {
                 MEMclose(temp_bufr);
                 PDMdebug("EXIT: PDMget_file_names-Filename is null \n");
                 return(PDM_I_NO_FILES_FOUND);
               }
        }
          
     PDMdebug("EXIT: PDMget_file_names\n");
     return(PDM_S_SUCCESS);
}


/* This function returns the latest revision[first row],part type,
and the  part number, once the catalog and the part desc has been 
entered
Kumar 9/30/91*/

PDMget_part_rev_type(temp_bufr)
  MEMptr *temp_bufr;
{
  char   sql_str[512];

  *temp_bufr = NULL;

sprintf(sql_str,"%s FROM %s %s '%s' %s ",
   "SELECT n_itemname,n_itemrev,p_parttype ",PDMexec->catalog,
   "WHERE n_itemdesc = ",PDMexec->part_num,
   "ORDER BY  n_itemrev");

   status = SQLquery(sql_str,temp_bufr,512);
   if(status != SQL_S_SUCCESS)
   {
                MEMclose(temp_bufr);
                switch(status)
                {
                        case SQL_I_NO_ROWS_FOUND :
                                 sprintf(s,"%s %s %s %s \n",
                                 "PDMget_children: Could not find Part ",
                                 PDMexec->part_num,PDMexec->revision);
                                 PDMdebug(s);
                                 return(PDM_E_PART_NOT_FOUND);
                        case PDMS_NO_SUCH_TABLE:
                                 sprintf(s,"%s %s \n",
                                 "PDMget_children: Could not find Catalog ",
                                 PDMexec->catalog);
                                 PDMdebug(s);
                                 return(PDM_E_CATALOG_NOT_FOUND);
                        default:
                        status = _PDMget_db_error (status);
                        return(status);
                }
   }
     PDMdebug("EXIT: PDMget_part_rev_type\n");
     return(PDM_S_SUCCESS);
}


/* This function returns the valid revisions[first row - latest ]
once the catalog and the part number has been 
entered
Kumar 9/30/91*/

PDMget_rev(temp_bufr)
  MEMptr *temp_bufr;
{
  char   sql_str[512];

  *temp_bufr = NULL;

sprintf(sql_str,"%s FROM %s %s '%s' %s ",
   "SELECT n_itemrev ",PDMexec->catalog,
   "WHERE n_itemname = ",PDMexec->part_num,
   "ORDER BY  n_itemrev");

   status = SQLquery(sql_str,temp_bufr,512);
   if(status != SQL_S_SUCCESS)
   {
                MEMclose(temp_bufr);
                switch(status)
                {
                        case SQL_I_NO_ROWS_FOUND :
                                 sprintf(s,"%s %s %s %s \n",
                                 "PDMget_children: Could not find Part ",
                                 PDMexec->part_num,PDMexec->revision);
                                 PDMdebug(s);
                                 return(PDM_E_PART_NOT_FOUND);
                        case PDMS_NO_SUCH_TABLE:
                                 sprintf(s,"%s %s \n",
                                 "PDMget_children: Could not find Catalog ",
                                 PDMexec->catalog);
                                 PDMdebug(s);
                                 return(PDM_E_CATALOG_NOT_FOUND);
                        default:
                        status = _PDMget_db_error (status);
                        return(status);
                }
   }
     PDMdebug("EXIT: PDMget_rev\n");
     return(PDM_S_SUCCESS);
}

/*
If a project name has been entered and the user enters a part number,
and a project name, check for existence
Kumar 09/28/91 - MOD 5/6/92 */

PDMcatalogs_of_proj_part()
{

  char  sql_str[512];
  MEMptr bufr = NULL;
  int   proj_no,item_no;

   status = PDMris_get_pitemno(&item_no,PDMexec->catalog,PDMexec->part_num,
                              PDMexec->revision);
    if(status != SQL_S_SUCCESS)
       {
         sprintf(s,"PDMris_get_itemno failed status %d\n",status);
         PDMdebug(s);
         return(PDM_E_PART_NOT_FOUND);
        }
    status = PDMris_get_projectno(PDMexec->project,&proj_no);
    if(status != SQL_S_SUCCESS)
       {
         sprintf(s,"PDMris_get_projectno failed status %d\n",status);
         PDMdebug(s);
         return(PDM_E_PROJECT_NOT_FOUND);
        }
    sprintf(sql_str,"SELECT n_citno FROM NFMPROJECTCIT WHERE n_projectno = %d AND  AND n_itemno = %d",proj_no,item_no);
     status = SQLquery(sql_str,&bufr,512);
       if(status != SQL_S_SUCCESS)
        {
            MEMclose(&bufr);
            return(PDM_I_NO_ROWS_FOUND);
          }
            MEMclose(&bufr);
        return(PDM_S_SUCCESS);
}


int PDMget_ems_files (temp_bufr, temp_bufr1)
MEMptr *temp_bufr;
MEMptr *temp_bufr1;
{
  char   *fn = "PDMget_ems_files";
  char   sql_str[1024];
  char   **data;
    
   _PDMdebug("PDMget_ems_files_views", "ENTER:\n");

   sql_str[0] = '\0';

/* Modified since in 3.0, OS does not contain itemno. Instead of 
   itemno, we will be using partnum and rev. MaC 101593....
   sprintf(sql_str,"%s  %s %s %d AND (n_status != '' or n_status is not NULL)",
   "SELECT n_status FROM ",
   PDMexec->catalog,"WHERE n_itemno = ",PDMexec->entity);
*/

   sprintf(sql_str,
   "%s %s %s '%s' AND %s '%s' AND (n_status != '' or n_status is not NULL)",
   "SELECT n_status, n_itemno FROM ",
   PDMexec->catalog, "WHERE n_itemname = ", PDMexec->part_num,
   "n_itemrev = ", PDMexec->revision);

   status = SQLquery(sql_str,temp_bufr,512);
   if(status != SQL_S_SUCCESS)
   {
                switch(status)
                {
                        case SQL_I_NO_ROWS_FOUND :
                                 return(PDM_E_PART_NOT_CHECKEDIN);
                        default:
                        status = _PDMget_db_error (status);
                        return(status);
                }
   }

   status = MEMbuild_array((*temp_bufr));
   if (status != MEM_S_SUCCESS) {
       MEMclose(&temp_bufr);
       _PDMdebug (fn, "MEMbuild_array (temp_bufr) failed status 0x%.8x",  
                                                                  status);
       return (PDM_E_BUILD_ARRAY);
       }

   data = (char **)(*temp_bufr)->data_ptr;
   PDMexec->entity = atol (data[1]);
   _PDMdebug (fn, "itemno = %s\n", data[1]);

   MEMclose(temp_bufr); /* *temp_bufr = NULL; */

   sql_str[0] = '\0';
   sprintf(sql_str,"%s v_%s %s %d",
   "SELECT DISTINCT( p_viewname ) FROM ",
   PDMexec->catalog,"WHERE n_itemno = ",PDMexec->entity);
   status = SQLquery(sql_str,temp_bufr,512);
   if(status != SQL_S_SUCCESS)
   {
                switch(status)
                {
                        case SQL_I_NO_ROWS_FOUND :
           /* Put code for checking the checked in status */
                                 sprintf(s,"%s \n",
                                 "No views defined found ");
                                 PDMdebug(s);
                                 return(PDM_E_NO_VIEWS_DEFINED);
                        case PDMS_NO_SUCH_TABLE:
                                 sprintf(s,"%s %s \n",
                      "PDMshow_saved_views: Could not find ",PDMexec->catalog);
                                 PDMdebug(s);
                                 return(PDM_E_VIEWS_TABLE_NOT_FOUND);
                        default:
                        status = _PDMget_db_error (status);
                        return(status);
                }
   }

sql_str[0] = '\0';

sprintf(sql_str," SELECT n_cofilename  FROM f_%s WHERE n_itemnum = %d AND n_fileversion = (SELECT MAX(n_fileversion) FROM f_%s WHERE n_itemnum = %d) ORDER BY n_cofilename",PDMexec->catalog, PDMexec->entity, PDMexec->catalog, PDMexec->entity);
   status = SQLquery(sql_str,temp_bufr1,512);
   if(status != SQL_S_SUCCESS)
   {
                switch(status)
                {
                        case SQL_I_NO_ROWS_FOUND :
                                 sprintf(s,"%s %s %s %s \n",
                                 "PDMget_children: Could not find Part ",
                                 PDMexec->part_num,PDMexec->revision);
                                 PDMdebug(s);
                                 return(PDM_E_PART_NOT_FOUND);
                        case PDMS_NO_SUCH_TABLE:
                                 sprintf(s,"%s %s \n",
                                 "PDMget_children: Could not find Catalog ",
                                 PDMexec->catalog);
                                 PDMdebug(s);
                                 return(PDM_E_CATALOG_NOT_FOUND);
                        default:
                        status = _PDMget_db_error (status);
                        return(status);
                }
   }
     return(PDM_S_SUCCESS);
}


long PDMval_part_for_copy(n_catalogname,n_itemno)
char *n_catalogname;
int   n_itemno;
{
  char   sql_str[512];
  MEMptr temp_bufr = NULL;
   char  **data; 
  
    
       _PDMdebug("PDMval_part_for_copy", "ENTER:\n");
        sql_str[0]='\0';

sprintf(sql_str," SELECT %s.n_status,v_%s.p_viewname  FROM %s,v_%s WHERE %s.n_itemno = %d AND v_%s.n_itemno = %d ",n_catalogname, n_catalogname, n_catalogname,n_catalogname, n_catalogname,n_itemno,n_catalogname,n_itemno);

   status = SQLquery(sql_str,&temp_bufr,512);
   if(status != SQL_S_SUCCESS)
   {
                MEMclose(&temp_bufr);
                switch(status)
                {
                        case SQL_I_NO_ROWS_FOUND :
                                 sprintf(s,"%s %d in %s  \n",
                                 "No views defined for Item no ",
                                 n_itemno,n_catalogname);
                                 PDMdebug(s);
                                 return(PDM_E_NO_VALID_VIEWS);
                        case PDMS_NO_SUCH_TABLE:
                                 sprintf(s,"%s %s \n",
                                 " Could not find Catalog ",
                                 n_catalogname);
                                 PDMdebug(s);
                                 return(PDM_E_CATALOG_NOT_FOUND);
                        default:
                        status = _PDMget_db_error (status);
                        return(status);
                }
   }
       status = MEMbuild_array(temp_bufr);
        if (status != MEM_S_SUCCESS) {
                MEMclose(&temp_bufr);
                sprintf(s, "%s %s %d\n",
                        "PDMquery_file_status: MEMbuild_array ",
                        "failed status ", status);
                PDMdebug(s);
                return (PDM_E_BUILD_ARRAY);
        }
       data = (char **)temp_bufr->data_ptr;
      if (!strcmp(data[0], ""))
       {
        MEMclose(&temp_bufr);
        PDMdebug("EXIT: PDMval_part_for_copy\n");
        return (PDM_E_NOTCHECK_IN);
        } 
        sprintf("File status %s\n", data[0]);
        PDMdebug(s);
        MEMclose(&temp_bufr);
     PDMdebug("EXIT: PDMval_part_for_copy\n");
     return(PDM_S_SUCCESS);
}

int PDMi_get_partnum_rev_desc (catalog, n_itemno, 
                                   part_num, part_rev, part_desc)
        char           *catalog;
        int             n_itemno;
        char           *part_num;
        char           *part_rev;
        char           *part_desc;
{
        char            *fn = "PDMi_get_partnum_rev_desc";
        char            sql_str[512];
        MEMptr          bufr = NULL;
        char          **data;

        PDMdebug("ENTER:PDMi_get_partnum_rev\n");
        sprintf(sql_str, "%s %s %s %d",
           "SELECT n_itemname, n_itemrev, n_itemdesc FROM ", catalog,
           "WHERE n_itemno = ", n_itemno);
        status = SQLquery(sql_str, &bufr, 512);
        if (status != SQL_S_SUCCESS) {
           MEMclose(&bufr);
           _PDMdebug (fn, "SQLquery failed status %d\n", status);
                        status = _PDMget_db_error (status);
                        return(status);
        }
        status = MEMbuild_array(bufr);
        if (status != MEM_S_SUCCESS) {
           MEMclose(&bufr);
           _PDMdebug (fn, "MEMbuild_array failed status %d\n", status);
           return (PDM_E_BUILD_ARRAY);
        }
        data = (char **) bufr->data_ptr;
        strcpy(part_num, data[0]);
        strcpy(part_rev, data[1]);
        strcpy(part_desc, data[2]);
      _PDMdebug (fn, "part[%s.%s.%s]\n", part_num, part_rev, part_desc);
        PDMdebug("EXIT:PDMi_get_partnum_rev\n");
        return (PDM_S_SUCCESS);
}

/*
This function has been added to get part_num, part_rev and parttype
given catalog and item_no. This is to support copy_assy_to_local functionality
for PDM21.
used in:
cicocp/PDMfcopy_m.c
MaC 09/20/92
*/


int PDMi_get_partnum_rev_type (catalog, n_itemno,
                                        part_num, part_rev, part_type)
char           *catalog;
int             n_itemno;
char           *part_num;
char           *part_rev;
char           *part_type;
{
        char            *fn = "PDMi_get_partnum_rev_type";
        char            sql_str[512];
        MEMptr          bufr = NULL;
        char          **data;

        PDMdebug("ENTER:PDMi_get_partnum_rev_desc\n");
        sprintf(sql_str, "%s %s %s %d",
                "SELECT n_itemname, n_itemrev, p_parttype FROM ", catalog,
                "WHERE n_itemno = ", n_itemno);
        status = SQLquery(sql_str, &bufr, 512);
        if (status != SQL_S_SUCCESS) {
                MEMclose(&bufr);
                _PDMdebug (fn, "SQLquery failed status %d\n", status);
                        status = _PDMget_db_error (status);
                        return(status);
        }
        status = MEMbuild_array(bufr);
        if (status != MEM_S_SUCCESS) {
                MEMclose(&bufr);
                _PDMdebug (fn, "MEMbuild_array failed status %d\n", status);
                return (PDM_E_BUILD_ARRAY);
        }
        data = (char **) bufr->data_ptr;
        strcpy(part_num, data[0]);
        strcpy(part_rev, data[1]);
        sprintf(sql_str, "%s %s %s %d",
                "SELECT n_itemname, n_itemrev, p_parttype FROM ", catalog,
                "WHERE n_itemno = ", n_itemno);
        status = SQLquery(sql_str, &bufr, 512);
        if (status != SQL_S_SUCCESS) {
                MEMclose(&bufr);
                _PDMdebug (fn, "SQLquery failed status %d\n", status);
                return (PDM_E_SQL_QUERY);
        }
        status = MEMbuild_array(bufr);
        if (status != MEM_S_SUCCESS) {
                MEMclose(&bufr);
                _PDMdebug (fn, "MEMbuild_array failed status %d\n", status);
                return (PDM_E_BUILD_ARRAY);
        }
        data = (char **) bufr->data_ptr;
        strcpy(part_num, data[0]);
        strcpy(part_rev, data[1]);
strcpy(part_type, data[2]);
        _PDMdebug (fn, "part_num[%s.%s.%s]\n",
                          part_num, part_rev, part_type);
        PDMdebug("EXIT:PDMi_get_partnum_rev_desc\n");
        return (PDM_S_SUCCESS);
}


int PDMload_partno_filename(bufr)
	MEMptr          bufr;
{
	int             i, j, k, nxj, nxi;
	int             n1, n2, n3, n4, n5, n6;
	char          **data, **column, **fcat_data, sql_str[512];
	char            s_catno[40], s_partno[40];
	int             catno, partno;
        MEMptr          fcat_bufr = NULL;

	PDMdebug("ENTER:PDMload_partno_filename\n");
	status = MEMbuild_array(bufr);
	if (status != MEM_S_SUCCESS) {
		sprintf(s, "MEMbuild_array failed status %d\n",
			status);
		PDMdebug(s);
		return (PDM_E_BUILD_ARRAY);
	}
	column = (char **) bufr->column_ptr;
	n1 = -1;
	n2 = -1;
	n3 = -1;
	n4 = -1;
	n5 = -1;
	n6 = -1;
	for (i = 0; i < bufr->columns; i++) {
	if (!strcmp(column[i], "n_catalogname")) n1 = i;
        else	if (!strcmp(column[i], "n_itemname") ) n2 = i;
        else	if (!strcmp(column[i], "n_itemrev") ) n3 = i;
        else	if (!strcmp(column[i], "n_catalogno") ) n4 = i;
        else	if (!strcmp(column[i], "n_itemno") ) n5 = i;
        else	if (!strcmp(column[i], "n_cofilename") ) n6 = i;
	}
	if (n1 == -1 || n2 == -1 || n3 == -1 ||
	    n4 == -1 || n5 == -1) {
		PDMdebug("Couldnot find reqd columns in <bufr>\n");
		return (PDM_E_BUFFER_FORMAT);
	}
	data = (char **) bufr->data_ptr;
	for (i = 0; i < bufr->rows; i++) 
        {
	nxi = i * bufr->columns;
	if (!strlen(data[nxi + n4])) {
	s_catno[0] = '\0';
	s_partno[0] = '\0';
	status = PDMquery_catalog_partnos( data[nxi + n1], data[nxi + n2],
					   data[nxi + n3], &catno, &partno);
	if (status != PDM_S_SUCCESS) {
    sprintf(s, "%s %d \n", "PDMquery_catalog_partnos failed status ", status);
		PDMdebug(s); return (status);
			}
			sprintf(s_catno, "%d", catno);
			sprintf(s_partno, "%d", partno);
	for (j = 0; j < bufr->rows; j++)
     {
	nxj = j * bufr->columns;
	if (!strcmp(data[nxi + n1], data[nxj + n1]) &&
	  !strcmp(data[nxi + n2], data[nxj + n2]) &&
	  !strcmp(data[nxi + n3], data[nxj + n3])) {
	sprintf(s, "s_catno -> %s\n", s_catno);
		PDMdebug(s);
		sprintf(s, "s_partno -> %s\n", s_partno);
			PDMdebug(s);
		status = MEMwrite_data(bufr, s_catno, j + 1, n4 + 1);
	if (status == MEM_S_SUCCESS)
	status = MEMwrite_data(bufr, s_partno, j + 1, n5 + 1);
		if (status != MEM_S_SUCCESS) {
		sprintf(s, "MEMwrite_data failed status %d\n", status);
		PDMdebug(s); return (PDM_E_WRITE_COLUMN);
				}
			}
			}
		}
	}
	for (i = 0; i < bufr->rows; i++) 
        {
	nxi = i * bufr->columns;
	if (!strlen(data[nxi + n6]))
         {

     sprintf(sql_str,"SELECT DISTINCT n_cofilename FROM f_%s WHERE n_itemnum = %s ORDER BY n_cofilename",data[nxi+n1],data[nxi+n5]);
         
status = SQLquery(sql_str,&fcat_bufr,512);
             if(status != SQL_S_SUCCESS)
              {
                 if(status ==  SQL_I_NO_ROWS_FOUND )
                   {
                     MEMclose(&fcat_bufr);
                     continue;
                    }
                    else 
                   {
                     MEMclose(&fcat_bufr);
                     return(status);
                    }
                 }
                  
               status = MEMbuild_array(fcat_bufr);
               if (status != MEM_S_SUCCESS)
                {
                MEMclose(&fcat_bufr);
                sprintf(s,"MEMwrite_format failed status %d\n",status);
                PDMdebug(s);
                return(PDM_E_BUILD_ARRAY);
                }
                fcat_data = (char **)fcat_bufr->data_ptr;
              
		status = MEMwrite_data(bufr, fcat_data[0], i + 1, n6 + 1);
		if (status != MEM_S_SUCCESS)
                   {
		sprintf(s, "MEMwrite_data failed status %d\n", status);
		PDMdebug(s); return (PDM_E_WRITE_COLUMN);
		    }
                 if(fcat_bufr->rows > 1)
                    {
                     for (k = 1 ; k < fcat_bufr->rows; k++)
                       {
                      sql_str[0]='\0';
                    sprintf(sql_str,"%s\1%s\1%s\1%s\1%s\1%s\1\1",
                            data[nxi+n4],data[nxi+n5],data[nxi+n1],
                            data[nxi+n2],data[nxi+n3],fcat_data[k]);
		status = MEMwrite(bufr, sql_str);
		if (status != MEM_S_SUCCESS)
                   {
		sprintf(s, "MEMwrite_data failed status %d\n", status);
		PDMdebug(s); return (PDM_E_WRITE_COLUMN);
		    }
                      
                       }
                     }
                       MEMclose(&fcat_bufr);
            }
          }
		
	PDMdebug("EXIT:PDMload_partno_filename\n");
	return (PDM_S_SUCCESS);
}


int PDMget_storageno (strg_name, sano)
char             *strg_name;
int             *sano;
{
	char          *fn   = "PDMget_storageno";
	MEMptr          bufr = NULL;
	char            sql_str[512];
	char          **data;

	PDMdebug("ENTER:PDMget_storageno\n");

	sprintf(sql_str, 
        "SELECT n_sano FROM nfmstoragearea WHERE n_saname = '%s' ",
                                                          strg_name);
	status = SQLquery(sql_str, &bufr, 1024);
	if (status != SQL_S_SUCCESS) {
		MEMclose(&bufr);
		if (status == SQL_I_NO_ROWS_FOUND) {
			return (PDM_I_NO_ROWS_FOUND);
		}
		_PDMdebug (fn, "SQLquery failed status %d\n", status);
                        status = _PDMget_db_error (status);
                        return(status);
	}
	status = MEMbuild_array(bufr);
	if (status != MEM_S_SUCCESS) {
		MEMclose(&bufr);
		_PDMdebug (fn, "MEMbuild_array failed status %d\n", status);
		return (PDM_E_BUILD_ARRAY);
	}
	data = (char **) bufr->data_ptr;
        _PDMdebug (fn, "sano = %d\n", atol (data[0]));
	*sano = atol(data[0]);
	MEMclose(&bufr);
	PDMdebug("EXIT:PDMi_find_sano\n");
	return (PDM_S_SUCCESS);
}



/*
  This function is used to check whether part exists in a given
  catalog. Irrespective of revision. This is at a request from 
  Stan, to check while user switches from New mode to similar mode.
  -MaC 121592 */


int PDMcheck_partnum_without_rev (catalog, n_itemname)
char           *catalog;
char           *n_itemname;
{
	char		*fn = "PDMcheck_partnum_without_rev";
	char            sql_str[1024];
	MEMptr          temp_bufr = NULL;

	long            status;

	_PDMdebug(fn, "ENTER\n");

	sql_str[0] = '\0';
	sprintf(sql_str, "%s FROM %s %s '%s' ",
		"SELECT n_itemname ", catalog,
		"WHERE n_itemname = ", n_itemname);

	status = SQLquery(sql_str, &temp_bufr, 512);
	if (status != SQL_S_SUCCESS) {
	   MEMclose(&temp_bufr);
	   if (status == SQL_I_NO_ROWS_FOUND) {
               _PDMdebug (fn, "Part does not exist\n");
		return (PDM_S_SUCCESS);
               }
            else {
		_PDMdebug (fn, "SQLquery: %d\n", status);
		return (status);
		}
	    }
	MEMclose(&temp_bufr);
	_PDMdebug(fn, "EXIT\n");
return (PDM_E_PART_EXISTS);
}

int PDMquery_dyn_table_no (dyn_table, p_dyn_tableno)
	char           *dyn_table;
	int            *p_dyn_tableno;
{
	char		*fn = "PDMquery_dyn_table_no";
	char          **data;
	char            sql_str[1024];
	char            low_dyn_table[50];
	MEMptr          temp_bufr = NULL;

	long            status;
	int 		PDMconvert_to_lower ();

	_PDMdebug("ENTER", "%s\n", fn);

	/* get p_dyn_tableno */

	sql_str[0] = '\0';

   sprintf(sql_str, "%s FROM %s %s '%s'",
   	"SELECT n_tableno ", "nfmtables",
   	"WHERE n_tablename = ", dyn_table);

   status = SQLquery(sql_str, &temp_bufr, 512);
  if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND) ) {
     MEMclose(&temp_bufr);
    switch (status) {
     case PDMS_NO_SUCH_TABLE:
            _PDMdebug (fn, "Could not find Table %s \n", dyn_table);
            return (PDM_E_CATALOG_NOT_FOUND);
        default:
           _PDMdebug (fn, "Could not access the table %d\n", status);
                        status = _PDMget_db_error (status);
                        return(status);
           }
         }

   if (status == SQL_I_NO_ROWS_FOUND) {
     low_dyn_table[0] = '\0';
     PDMconvert_to_lower(dyn_table, low_dyn_table); 

   sprintf(sql_str, "%s FROM %s %s '%s'",
   	    "SELECT n_tableno ", "nfmtables",
   	    "WHERE n_tablename = ", low_dyn_table);

   status = SQLquery(sql_str, &temp_bufr, 512);
   if (status != SQL_S_SUCCESS)  {
     MEMclose(&temp_bufr);
     switch (status) {
     case SQL_I_NO_ROWS_FOUND:
  	      _PDMdebug (fn, "Could not find Table entry %s\n", low_dyn_table);
  	  return (PDM_E_NO_CAT_ENTRY);
     case PDMS_NO_SUCH_TABLE:
           _PDMdebug (fn, "Could not find Table %s \n", dyn_table);
           return (PDM_E_CATALOG_NOT_FOUND);
      default:
           _PDMdebug (fn, "Could not access the table %d\n", status);
                        status = _PDMget_db_error (status);
                        return(status);
        }
      }
     }

  status = MEMbuild_array(temp_bufr);
  if (status != MEM_S_SUCCESS) {
    MEMclose(&temp_bufr);
    _PDMdebug (fn, "MEMbuild_array failed status %d", status);
    return (PDM_E_BUILD_ARRAY);
    }

  data = (char **) temp_bufr->data_ptr;

  *p_dyn_tableno = atol(data[0]);

  MEMclose(&temp_bufr);
  _PDMdebug("ENTER", "%s\n", fn);
  return (PDM_S_SUCCESS);
}

/* These two fns are added because they are called in here. And,
also, this file is used in PDMinit */



int PDMconvert_to_lower (string, string1)
char *string ;
char *string1 ;
{
int i ;

  for (i=0; i<strlen(string) ; i++ )
    string1[i] = tolower (string[i]) ;
  string1[i] = '\0' ;
  return(1);
}




int	_PDMget_db_error (status2)
int	status2;
{
	char	*fn = "_PDMget_db_error";
	int	errorno = 0;
	int	errorno1 = 0;
	int	status1 = 0;

      if (status2 != SQL_I_NO_ROWS_FOUND) {
        errorno = (SQLglobal.DBerror_no >> 16);
        errorno1 = SQLglobal.DBerror_no;
        _PDMdebug (fn, "sql_global_error = %d \n", SQLglobal.DBerror_no);
        _PDMdebug ("Printing SQLglobal struct", "\nris_print_format[%s]\n", 
         SQLglobal.ris_print_format); 
        _PDMdebug ("Printing SQLglobal struct", "\nDBerrorno[%d]\n", 
         SQLglobal.DBerror_no);
        _PDMdebug ("Printing SQLglobal struct", "\nDBerror_msg[%s]\n", 
         SQLglobal.DBerror_msg); 
        _PDMdebug ("Printing SQLglobal struct", "\ndb_type[%c]\n", 
         SQLglobal.db_type);

        _PDMdebug (fn, "errorno [%d]\n", errorno);
        _PDMdebug (fn, "errorno1 [%d]\n", errorno1);

        if ( (errorno == 107) || (errorno == 113) 
                 || (errorno == 233) || (errorno == 271) ) {
           status1 = PDM_I_TABLE_LOCKED;
          }
         else {
          if (status2 == SQL_E_MESSAGE) status1 = PDM_E_SQL_QUERY;
          else  status1 = status2;
          }
        }
      else status1 = status2;
     
      /* initialising the dberror no */
      SQLglobal.DBerror_no = 0;

      return(status1);
}

                                               
/* this function takes a cpr and an attribute and gets the
   value for that attr. The value is always char MaC 052793*/

int _PDMget_attribute_value (catalog, part, rev, attr, value)
char           *catalog;
char           *part;
char           *rev;
char           *attr;
char           *value;
{
	char		*fn = "_PDMget_attribute_value";
	char          **data;
	char            sql_str[1024];
        int            _PDMget_db_error();
	MEMptr          temp_bufr = NULL;

	long            status;

	_PDMdebug(fn, "ENTER\n");

        _PDMdebug (fn, "getting value for %s\n", attr);

	sql_str[0] = '\0';
	sprintf(sql_str, "SELECT %s FROM %s %s '%s' %s '%s'",
		attr, catalog,
		"WHERE n_itemname = ", part,
		"AND n_itemrev = ", rev);

	status = SQLquery(sql_str, &temp_bufr, 512);
	if (status != SQL_S_SUCCESS) {
	   MEMclose(&temp_bufr);
	   switch (status) {
	   case SQL_I_NO_ROWS_FOUND:
	   	_PDMdebug (fn, "%s %s %s \n",
	   	   "Could not find item[%s] entry in [%s]",  part, catalog);
	   	return (PDM_E_NO_CAT_ENTRY);
	   case PDMS_NO_SUCH_TABLE:
	   	_PDMdebug (fn, "%s %s \n",
	   		"Could not find Catalog ", catalog);
	   	return (PDM_E_CATALOG_NOT_FOUND);
	   default:
                _PDMdebug (fn, "SQLqry %d\n", status);
                        status = _PDMget_db_error (status);
                        return(status);
	   }
	}

	status = MEMbuild_array(temp_bufr);
	if (status != MEM_S_SUCCESS) {
	   MEMclose(&temp_bufr);
	   _PDMdebug (fn, "%s %d\n",
	   	"MEMbuild_array failed status ", status);
	   return (PDM_E_BUILD_ARRAY);
	}

	data = (char **) temp_bufr->data_ptr;

        value[0] = '\0';
        strcpy (value, data[0]);

        _PDMdebug (fn, "value for %s is [%s]\n", attr, value);

	MEMclose(&temp_bufr);
	_PDMdebug (fn, "EXIT\n");
	return (PDM_S_SUCCESS);
}


int PDMquery_catalogtype_no (catalog, type, catno)
char           *catalog;
char           *type;
int            *catno;
{
	char		*fn = "PDMquery_catalogtype_no";
	char          **data;
	char            sql_str[1024];
	MEMptr          temp_bufr = NULL;
        int            _PDMget_db_error();

	long            status;

	_PDMdebug (fn, "ENTER\n");

	/* get n_type */

	sql_str[0] = '\0';
	sprintf(sql_str, "%s FROM %s %s '%s'",
		"SELECT n_type, n_catalogno ", "nfmcatalogs",
		"WHERE n_catalogname = ", catalog);

	status = SQLquery(sql_str, &temp_bufr, 512);
	if (status != SQL_S_SUCCESS) {
		MEMclose(&temp_bufr);
		switch (status) {
		case SQL_I_NO_ROWS_FOUND:
		   _PDMdebug (fn, "Could not find Catalog entry %s\n",
		   	catalog);
		   return (PDM_E_NO_CAT_ENTRY);

		case PDMS_NO_SUCH_TABLE:
		   _PDMdebug (fn, "Could not find Catalog %s\n",
		     	catalog);
		   return (PDM_E_CATALOG_NOT_FOUND);
		default:
                        status = _PDMget_db_error (status);
                        return(status);
		}
	}
	status = MEMbuild_array(temp_bufr);
	if (status != MEM_S_SUCCESS) {
	  MEMclose(&temp_bufr);
	  _PDMdebug (fn, "MEMbuild_array failed status 0x%.8x", status);
	  return (PDM_E_BUILD_ARRAY);
	}

	data = (char **) temp_bufr->data_ptr;

        type [0] = '\0';
	strcpy (type, data[0]);
        *catno = atol(data[1]);

        _PDMdebug (fn, "catalog[%s]->type[%s] catno[%d]\n", 
                                          catalog, type, *catno);

	MEMclose(&temp_bufr);
	_PDMdebug(fn, "EXIT:\n");
	return (PDM_S_SUCCESS);
}






int PDMQueryAssyIndPTypePDesc (
	char           *catalog,
	char           *n_itemname,
	char           *n_itemrev,
	char           *n_setindicator,
	char           *p_parttype,
	char           *n_itemdesc
  )
{
char          **data;
char          *fn = "PDMQueryAssyIndPTypePDesc";
char          sql_str[1024];
MEMptr        temp_bufr = NULL;
long            status;

  _PDMdebug(fn,"ENTER:\n");

     _PDMdebug ("Getting assyind, ptype & desc for", "[%s].[%s].[%s]\n",
                             catalog, n_itemname, n_itemrev);

  /* get n_setindicator from the catalog */

  sql_str[0] = '\0';
  sprintf(sql_str, "%s FROM %s %s '%s' %s '%s'",
    "SELECT n_setindicator, p_parttype, n_itemdesc ", catalog,
    "WHERE n_itemname = ", n_itemname,
    "AND n_itemrev = ", n_itemrev);

  status = SQLquery(sql_str, &temp_bufr, 512);
  if (status != SQL_S_SUCCESS) {
    MEMclose(&temp_bufr);
    switch (status) {
    case SQL_I_NO_ROWS_FOUND:
                       {
         MEMclose(&temp_bufr);
         sql_str[0] = '\0';
         sprintf(sql_str, "%s FROM e_%s %s '%s' %s '%s'",
           "SELECT n_setindicator, p_parttype, n_itemdesc ", catalog,
           "WHERE n_itemname = ", n_itemname,
           "AND n_itemrev = ", n_itemrev);
       
         status = SQLquery(sql_str, &temp_bufr, 512);
         if (status != SQL_S_SUCCESS) {
            strcpy(n_setindicator, "Y");
            strcpy(p_parttype, "P");
            _PDMdebug(fn, "Could not find Part [%s].[%s]\n", 
                                           n_itemname, n_itemrev);
             return (PDM_S_SUCCESS);
             }
         else
            break;
      } 
    case PDMS_NO_SUCH_TABLE:
      _PDMdebug(fn, "PDMquery_assyind_parttype: Could not find Catalog [%s]\n",
        catalog);
      return (PDM_E_CATALOG_NOT_FOUND);

    default:
      return (status);
    }
  }

  status = MEMbuild_array(temp_bufr);
  if (status != MEM_S_SUCCESS) {
    MEMclose(&temp_bufr);
    _PDMdebug(fn, "%s %s %d\n",
      "PDMquery_assyind_parttype: MEMbuild_array ",
      "failed status ", status);
    return (PDM_E_BUILD_ARRAY);
  }

  data = (char **) temp_bufr->data_ptr;

  n_setindicator[0] = '\0';
  p_parttype[0] = '\0';
  n_itemdesc[0] = '\0';

  strcpy(n_setindicator, data[0]);
  strcpy(p_parttype, data[1]);
  strcpy(n_itemdesc, data[2]);

  MEMclose(&temp_bufr);

  _PDMdebug(fn,"EXIT\n");
  return (PDM_S_SUCCESS);
}



int PDMQueryAssyIndPFlag (
	char           *catalog,
	char           *n_itemname,
	char           *n_itemrev,
	char           *n_setindicator,
	char           *n_pendingflag
  )
{
char          **data;
char          *fn = "PDMQueryAssyIndPFlag";
char          sql_str[1024];
MEMptr        temp_bufr = NULL;
long            status;

  _PDMdebug(fn,"ENTER:\n");

     _PDMdebug ("Getting assyind, & pendinfflag for", "[%s].[%s].[%s]\n",
                             catalog, n_itemname, n_itemrev);

  /* get n_setindicator from the catalog */

  sql_str[0] = '\0';
  sprintf(sql_str, "%s FROM %s %s '%s' %s '%s'",
    "SELECT n_setindicator, n_pendingflag ", catalog,
    "WHERE n_itemname = ", n_itemname,
    "AND n_itemrev = ", n_itemrev);

  status = SQLquery(sql_str, &temp_bufr, 512);
  if (status != SQL_S_SUCCESS) {
    MEMclose(&temp_bufr);
    switch (status) {
    case SQL_I_NO_ROWS_FOUND:
                       {
         MEMclose(&temp_bufr);
         sql_str[0] = '\0';
         sprintf(sql_str, "%s FROM e_%s %s '%s' %s '%s'",
           "SELECT n_setindicator, n_pendingflag ", catalog,
           "WHERE n_itemname = ", n_itemname,
           "AND n_itemrev = ", n_itemrev);
       
         status = SQLquery(sql_str, &temp_bufr, 512);
         if (status == SQL_S_SUCCESS) {
            break;
             }
         else  {
           _PDMdebug (fn, "Failed status 0x%.8x\n", status);
           return (status);
          }
      } 
    case PDMS_NO_SUCH_TABLE:
      _PDMdebug(fn, "Could not find Catalog [%s]\n", catalog);
      return (PDM_E_CATALOG_NOT_FOUND);

    default:
      return (status);
    }
  }

  status = MEMbuild_array(temp_bufr);
  if (status != MEM_S_SUCCESS) {
    MEMclose(&temp_bufr);
    _PDMdebug(fn, "%s %s %d\n",
      "PDMquery_assyind_parttype: MEMbuild_array ",
      "failed status ", status);
    return (PDM_E_BUILD_ARRAY);
  }

  data = (char **) temp_bufr->data_ptr;

  n_setindicator[0] = '\0';
  n_pendingflag[0] = '\0';

  strcpy(n_setindicator, data[0]);
  strcpy(n_pendingflag, data[1]);

  MEMclose(&temp_bufr);

  _PDMdebug(fn,"EXIT\n");
  return (PDM_S_SUCCESS);
}


int PDMQueryAssyIndGivenPartno (
	char           *catalog,
	int		itemno,
	char           *n_setindicator
         )
{
char          **data;
char          *fn = "PDMQueryAssyIndGivenPartno";
char          sql_str[1024];
MEMptr        temp_bufr = NULL;
long            status;

  _PDMdebug(fn,"ENTER:\n");

     _PDMdebug ("Getting assyind for", "[%s].[%d]\n",
                             catalog, itemno);

  /* get n_setindicator from the catalog */

  sql_str[0] = '\0';
  sprintf(sql_str, "%s FROM %s %s %d ",
    "SELECT n_setindicator ", catalog,
    "WHERE n_itemno = ", itemno);

  status = SQLquery(sql_str, &temp_bufr, 512);
  if (status != SQL_S_SUCCESS) {
    MEMclose(&temp_bufr);
    switch (status) {
    case SQL_I_NO_ROWS_FOUND:
                       {
         MEMclose(&temp_bufr);
         sql_str[0] = '\0';
         sprintf(sql_str, "%s FROM e_%s %s %d ",
           "SELECT n_setindicator ", catalog,
           "WHERE n_itemno = ", itemno);
       
         status = SQLquery(sql_str, &temp_bufr, 512);
         if (status == SQL_S_SUCCESS) {
            break;
             }
         else  {
           _PDMdebug (fn, "Failed status 0x%.8x\n", status);
           return (status);
          }
      } 
    case PDMS_NO_SUCH_TABLE:
      _PDMdebug(fn, "Could not find Catalog [%s]\n", catalog);
      return (PDM_E_CATALOG_NOT_FOUND);

    default:
      return (status);
    }
  }

  status = MEMbuild_array(temp_bufr);
  if (status != MEM_S_SUCCESS) {
    MEMclose(&temp_bufr);
    _PDMdebug(fn, "MEMbuild_array failed : status 0x%.8x\n", status);
    return (PDM_E_BUILD_ARRAY);
  }

  data = (char **) temp_bufr->data_ptr;

  n_setindicator[0] = '\0';

  strcpy(n_setindicator, data[0]);

  MEMclose(&temp_bufr);

  _PDMdebug(fn,"EXIT\n");
  return (PDM_S_SUCCESS);
}

