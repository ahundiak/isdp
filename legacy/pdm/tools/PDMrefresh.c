#include <stdio.h>
#include "SQLerrordef.h"
#include "PDMdbs_err.h"
#include "MEMerrordef.h"
#include "MEMstruct.h"
#include "PDUerror.h"
#include "NFMstruct.h"
#include "NFMerrordef.h"
#include "WFstruct.h"
#include "PDUstorage.h"
#include "ERR.h"
#include "PDMproto.h"



#define MAX_BUFFER_SIZE 16384
#define NOT !
#define	TRUE	1
#define FALSE	0

extern long     sqlstatus;
extern struct NFMglobal_st NFMglobal;
extern struct WFstruct WFinfo;
extern int      PDMdebug_on;
extern struct PDMpart_ptr PDMpart;
extern char     PDM_DEBUG_FILE[];
static long     status;
static char     s[1024];
extern struct PDUstorage *storage;
extern PDMexec_ptr PDMexec;
/*
 * Checks for the existence of a catalog Returns PDM_S_SUCCESS if it finds
 * the catalog PDM_E_CATALOG_NOT_FOUND	 if catalog is not found any other
 * code is an error
 */

int             PDMverify_catalog (return_buffer)
MEMptr         *return_buffer;
{
  long            status;
  static char    *fname = "PDMverify_catalog";
  MEMptr          bufr = NULL;
  MEMptr          attr_list = NULL;
  MEMptr          data_list = NULL;
  MEMptr          value_list = NULL;
  char            sql_str[512];
  char          **column_ptr;
  char            state[40];
  char            message[512];
  char          **dataptr;
  char          **data1;
  int             i = 0, n1 = 0, n2 = 0, n3 = 0, n4 = 0;
  _PDMdebug (fname, "ENTER:\n");
  _PDMdebug (fname, "CATALOG is %s\n", PDMexec->catalog);
  if (PDMexec->project)
    _PDMdebug (fname, "project %s\n", PDMexec->project);
  sql_str[0] = '\0';
  sprintf (sql_str, "SELECT n_type FROM nfmcatalogs WHERE n_catalogname = '%s' ", PDMexec->catalog);
  status = SQLquery (sql_str, &bufr, 512);
  if ((status != SQL_S_SUCCESS) && ((!strcmp (PDMexec->project, "")) || PDMexec->project == NULL)) {
    if (status == SQL_I_NO_ROWS_FOUND) {
      MEMclose (&bufr);
      _PDMdebug (fname, "EXIT:CATALOG NOT FOUND\n");
      return (PDM_E_CATALOG_NOT_FOUND);
    }
    else if (status == SQL_E_MESSAGE || status == SQL_E_UNKNOWN_RELATION) {
      MEMclose (&bufr);
      _PDMdebug (fname, "EXIT:CATALOG NOT FOUND\n");
      return (PDM_E_CATALOG_NOT_FOUND);
    }
    else if (status == PDMS_NO_SUCH_ATTRIBUTE) {
      MEMclose (&bufr);
      return (PDM_E_REQ_COLUMN_NOT_FOUND);
    }
    else {
      status = _PDMget_db_error (status);
      if (status != PDM_I_TABLE_LOCKED)
	status = PDM_E_FAILURE;
      MEMclose (&bufr);
      _PDMdebug (fname, "EXIT:AMBIGIOUS ERROR\n");
      return (status);
    }
  }
  MEMclose (&bufr);

  if ((PDMexec->project != NULL) && (strlen (PDMexec->project) > 0) &&
      strcmp (PDMexec->catalog, "") && strcmp (PDMexec->part_num, "") == 0) {
    strcpy (WFinfo.proj_name, PDMexec->project);
    _PDMdebug (fname, "calling PDMcatalog_project_map\n");
    status = PDMcatalog_project_map (PDMexec);
    if (status != PDM_S_SUCCESS) {
      _PDMdebug (fname, "EXIT:CATALOG IS NOT MAPPED TO PROJECT\n");
      return (status);
    }
  }

  _PDMdebug (fname, "checking for NULL\n");
  if ((PDMexec->project != NULL) && (strlen (PDMexec->project) > 0) &&
      strcmp (PDMexec->catalog, "") && strcmp (PDMexec->part_num, "")) {
    /*
     * proj_name in WFinfo structure needs to be cleared for next command.
     * The scenario is like this: o user selects project and catalog to add
     * part o user adds part. o user clears the project and catalog fields
     * for adding part to another catalog _not_ mapped to the previous
     * catalog during the same session. o NFM fails during retrieving
     * attributes for the new catalog because, WFinfo struct still shows the
     * old project name. So, as a temp fix, the project name is blanked out.
     * WFinfo.proj_name[0] = '\0';
     */
    strcpy (WFinfo.proj_name, PDMexec->project);
    _PDMdebug (fname, "calling PDMcatalog_project_map\n");
    status = PDMcatalog_project_map (PDMexec);
    if (status != PDM_S_SUCCESS) {
      _PDMdebug (fname, "EXIT:CATALOG IS NOT MAPPED TO PROJECT\n");
      return (status);
    }
  }
  if ((!strcmp (PDMexec->part_num, "ADDPART")) ||
      (!strcmp (PDMexec->part_num, "CHGPART"))) {
    if (!strcmp (PDMexec->part_num, "ADDPART")) {
      status = PDMsvalidate_user_access_cl (PDMexec->user_id,
					"PDMAdd Part", "", PDMexec->project,
					    PDMexec->catalog, "", "");
      if (status != PDM_S_SUCCESS) {
	_PDMdebug (fname, "PDMsvalid_user_access failed status -> %d \n", status);
	return (status);
      }
    }
    else {
      status = PDMsvalidate_user_access_cl (PDMexec->user_id,
			    "PDMCopy and Change Part", "", PDMexec->project,
					    PDMexec->catalog, "", "");
      if (status != PDM_S_SUCCESS) {
	_PDMdebug (fname, "PDMsvalid_user_access failed status -> %d \n", status);
	return (status);
      }
    }
    status = PDMi_qry_catalog_attributes ("W", &attr_list, &data_list,
					  &value_list);
    if (status != PDM_S_SUCCESS) {
      _PDMdebug (fname, "PDMi_qry_catalog_attributes failed: %d\n", status);
      return (status);
    }

    status = MEMbuild_array (data_list);
    if (status != MEM_S_SUCCESS) {
      _PDMdebug (fname, "MEMbuild_array failed status %d\n", status);
      MEMclose (&attr_list);
      MEMclose (&data_list);
      MEMclose (&value_list);
      return (PDM_E_BUILD_ARRAY);
    }
    column_ptr = (char **) data_list->column_ptr;
    dataptr = (char **) data_list->data_ptr;
    for (i = 0; i < data_list->columns; i++) {
      if (!strcmp (column_ptr[i], "n_stateno"))
	n1 = i;
      else if (!strcmp (column_ptr[i], "n_cocomment"))
	n2 = i;
      else if (!strcmp (column_ptr[i], "n_cofilename"))
	n3 = i;
      else if (!strcmp (column_ptr[i], "n_cifilename"))
	n4 = i;
    }
    if (strcmp (dataptr[n1], "")) {
      sprintf (sql_str,
	       "SELECT n_statename FROM nfmstates WHERE n_stateno = %d",
	       atol (dataptr[n1]));
      status = SQLquery (sql_str, &bufr, 512);
      if (status != SQL_S_SUCCESS) {
	_PDMdebug (fname, "Getting state name failed status %d\n", status);
	MEMclose (&attr_list);
	MEMclose (&data_list);
	MEMclose (&value_list);
	status = _PDMget_db_error (status);
	return (status);
      }
      status = MEMbuild_array (bufr);
      if (status != MEM_S_SUCCESS) {
	_PDMdebug (fname, "MEMbuild_array failed status %d\n", status);
	MEMclose (&attr_list);
	MEMclose (&data_list);
	MEMclose (&value_list);
	return (PDM_E_BUILD_ARRAY);
      }
      state[0] = '\0';
      data1 = (char **) bufr->data_ptr;
      sprintf (state, data1[0]);
    }
    else {
      _PDMdebug (fname, "No state defined\n");
      strcpy (state, "No state defined");
    }
    _PDMdebug (fname, "STATE TO BE ADDED %s\n", state);
    /* State name is loaded in to n_cocomment column */
    /*
     * There is no point in opening another buffer to load the information.
     * The n_cocomment is not used most of the time. Even if it is used the
     * user need view it during review part attributes  - Kumar
     */

    status = MEMwrite_data (data_list, state, 1, n2 + 1);
    if (status != MEM_S_SUCCESS) {
      _PDMdebug (fname, "MEMbuild_array failed status %d\n", status);
      MEMclose (&attr_list);
      MEMclose (&data_list);
      MEMclose (&value_list);
      return (PDM_E_WRITE_ROW);
    }
    MEMclose (&bufr);
    *return_buffer = attr_list;
    status = MEMappend (data_list, *return_buffer);
    if (status != MEM_S_SUCCESS) {
      _PDMdebug (fname, "MEMappend failed status %d\n", status);
      MEMclose (return_buffer);
      MEMclose (&data_list);
      MEMclose (&value_list);
      return (PDM_E_APPEND_BUFFER);
    }
    status = MEMappend (value_list, *return_buffer);
    if (status != MEM_S_SUCCESS) {
      _PDMdebug (fname, "MEMappend failed status %d\n", status);
      MEMclose (return_buffer);
      MEMclose (&value_list);
      return (PDM_E_APPEND_BUFFER);
    }
  }

  if (!strcmp (PDMexec->part_num, "ATTR2")) {
    status = PDMsvalidate_user_access_cl (PDMexec->user_id,
					"PDMAdd Part", "", PDMexec->project,
					  PDMexec->catalog, "", "");
    if (status != PDM_S_SUCCESS) {
      _PDMdebug (fname, "PDMsvalid_user_access failed status -> %d \n", status);
      return (status);
    }
    /*
     * status = PDMget_commandno("Add Item", &command_no); if(status !=
     * PDM_S_SUCCESS) { _PDMdebug(fname,"PDMget_command_no failed status
     * %d\n",status); MEMclose(&attr_list); MEMclose(&data_list);
     * MEMclose(&value_list); _PDMdebug(fname,"command_no
     * %d\n",WFinfo.command); return(PDM_E_GET_DATA); }
     * 
     * WFinfo.command = command_no;
     */
    status = NFMquery_add_item_attributes (PDMexec->user_id,
		     PDMexec->catalog, &attr_list, &data_list, &value_list);
    if (status != NFM_S_SUCCESS) {
      _PDMdebug (fname, "NFMquery_add_item_attributes failed status %d\n", status);
      MEMclose (&attr_list);
      MEMclose (&data_list);
      MEMclose (&value_list);
      _PDMdebug (fname, "command_no %d\n", WFinfo.command);
      if (status == NFM_E_NOT_ACL_USER)
	return (PDM_E_NOT_ACL_USER);
      else if (status == NFM_E_BAD_USER)
	return (PDM_E_BAD_USER);
      else if (status == NFM_E_BAD_CLASS)
	return (PDM_E_BAD_CLASS);
      else if (status == NFM_E_ACL_USER)
	return (PDM_E_ACL_USER);
      else {
	ERRget_specific_number (NFM, &status);
	ERRget_specific_message (NFM, message);
	_PDMdebug (fname, "status = <0x%.8x>\n", status);
	_PDMdebug (fname, "MESSAGE \n%s\n", message);
	_PDMdebug (fname, "****QUERY ATTRIBUTES FAILED *****\n");
	return (status);
      }
    }
    status = MEMbuild_array (data_list);
    if (status != MEM_S_SUCCESS) {
      _PDMdebug (fname, "MEMbuild_array failed status %d\n", status);
      MEMclose (&attr_list);
      MEMclose (&data_list);
      MEMclose (&value_list);
      return (PDM_E_BUILD_ARRAY);
    }
    column_ptr = (char **) data_list->column_ptr;
    dataptr = (char **) data_list->data_ptr;
    for (i = 0; i < data_list->columns; i++) {
      if (!strcmp (column_ptr[i], "n_stateno"))
	n1 = i;
      else if (!strcmp (column_ptr[i], "n_cocomment"))
	n2 = i;
      else if (!strcmp (column_ptr[i], "n_cofilename"))
	n3 = i;
      else if (!strcmp (column_ptr[i], "n_cifilename"))
	n4 = i;
    }
    if (strcmp (dataptr[n1], "")) {
      sprintf (sql_str, "SELECT n_statename FROM nfmstates WHERE n_stateno = %d", atol (dataptr[n1]));
      status = SQLquery (sql_str, &bufr, 512);
      if (status != SQL_S_SUCCESS) {
	_PDMdebug (fname, "Getting state name failed status %d\n", status);
	MEMclose (&attr_list);
	MEMclose (&data_list);
	MEMclose (&value_list);
	status = _PDMget_db_error (status);
	return (status);
      }
      status = MEMbuild_array (bufr);
      if (status != MEM_S_SUCCESS) {
	_PDMdebug (fname, "MEMbuild_array failed status %d\n", status);
	MEMclose (&attr_list);
	MEMclose (&data_list);
	MEMclose (&value_list);
	return (PDM_E_BUILD_ARRAY);
      }
      state[0] = '\0';
      data1 = (char **) bufr->data_ptr;
      sprintf (state, data1[0]);
    }
    else {
      strcpy (state, "No state defined");
    }
    _PDMdebug (fname, "STATE TO BE ADDED %s\n", state);
    /* State name is loaded in to n_cocomment column */
    /*
     * There is no point in opening another buffer to load the information.
     * The n_cocomment is not used most of the time. Even if it is used the
     * user need view it during review part attributes  - Kumar
     */
    status = MEMwrite_data (data_list, state, 1, n2 + 1);
    if (status != MEM_S_SUCCESS) {
      _PDMdebug (fname, "MEMbuild_array failed status %d\n", status);
      MEMclose (&attr_list);
      MEMclose (&data_list);
      MEMclose (&value_list);
      return (PDM_E_WRITE_ROW);
    }
    /*
     * check for automatic filename generation status =
     * PDMcheck_for_autofilename(WFinfo.catalog_no); status =
     * PDMcheck_for_autofilename(PDMexec->catalog); if(status ==
     * PDM_S_SUCCESS) { status = PDMcofilename(cofilename); status =
     * MEMwrite_data(data_list,cofilename, 1,n3+1);      if(status !=
     * MEM_S_SUCCESS) { _PDMdebug(fname,"MEMbuild_array failed status
     * %d\n",status); MEMclose(&attr_list); MEMclose(&data_list);
     * MEMclose(&value_list); return(PDM_E_WRITE_ROW); } status =
     * MEMwrite_data(data_list,cofilename, 1,n4+1);      if(status !=
     * MEM_S_SUCCESS) { _PDMdebug(fname,"MEMbuild_array failed status
     * %d\n",status); MEMclose(&attr_list); MEMclose(&data_list);
     * MEMclose(&value_list); return(PDM_E_WRITE_ROW); } }
     */
    MEMclose (&bufr);
    *return_buffer = attr_list;
    status = MEMappend (data_list, *return_buffer);
    if (status != MEM_S_SUCCESS) {
      _PDMdebug (fname, "MEMappend failed status %d\n", status);
      MEMclose (return_buffer);
      MEMclose (&data_list);
      MEMclose (&value_list);
      return (PDM_E_APPEND_BUFFER);
    }
    status = MEMappend (value_list, *return_buffer);
    if (status != MEM_S_SUCCESS) {
      _PDMdebug (fname, "MEMappend failed status %d\n", status);
      MEMclose (return_buffer);
      MEMclose (&value_list);
      return (PDM_E_APPEND_BUFFER);
    }
  }
  /* WFinfo.proj_name[0] = '\0'; */
  if (status == SQL_I_NO_ROWS_FOUND) {
    status = PDMcheck_for_view (PDMexec->catalog);
    if (status == PDM_I_VIEW_FOUND) {
      _PDMdebug (fname, "Table name %s is a view", PDMexec->catalog);
      _PDMdebug (fname, "EXIT:-SUCCESS it's a view\n");
      /*
       * changed to return SUCCESS by JBP return(PDM_E_CATALOG_NOT_FOUND);
       */
      return (PDM_S_SUCCESS);
    }
    else
      return (PDM_S_SUCCESS);
  }
  _PDMdebug (fname, "EXIT:-SUCCESS- CATALOG EXISTS\n");
  return (PDM_S_SUCCESS);
}


int             PDMi_verify_catalog (catalog)
char           *catalog;
{
  long            status;
  MEMptr          bufr = NULL;
  char            sql_str[512];
  PDMdebug ("ENTER:PDMi_verify_catalog\n");
  sql_str[0] = '\0';
  sprintf (sql_str, "%s %s %s",
	   "SELECT n_itemname FROM ", catalog,
	   "WHERE n_itemname = '100'");
  status = SQLquery (sql_str, &bufr, 512);
  if (status != SQL_S_SUCCESS) {
    if (status == SQL_I_NO_ROWS_FOUND) {
      MEMclose (&bufr);
      PDMdebug ("EXIT:PDMi_verify_catalog\n");
      return (status);
    }
    else if (status == PDMS_NO_SUCH_TABLE) {
      MEMclose (&bufr);
      return (PDM_E_CATALOG_NOT_FOUND);
    }
    else if (status == PDMS_NO_SUCH_ATTRIBUTE) {
      MEMclose (&bufr);
      return (PDM_E_REQ_COLUMN_NOT_FOUND);
    }
    else {
      MEMclose (&bufr);
      status = _PDMget_db_error (status);
      if (status != PDM_I_TABLE_LOCKED)
	status = PDM_E_FAILURE;
      return (status);
    }
  }
  MEMclose (&bufr);

  PDMdebug ("EXIT:PDMi_verify_catalog\n");
  return (PDM_S_SUCCESS);
}

int             PDMverify_part (catalog, partnum, revision)
char           *catalog;
char           *partnum;
char           *revision;
{
  long            status;
  MEMptr          bufr = NULL;
  PDMdebug ("ENTER:PDMverify_part\n");
  s[0] = '\0';
  sprintf (s, "%s %s %s '%s' %s '%s'",
	   "SELECT n_itemname,n_itemrev FROM ", catalog,
	   "WHERE n_itemname = ", partnum,
	   "AND n_itemrev = ", revision);
  status = SQLquery (s, &bufr, 512);
  if (status != SQL_S_SUCCESS) {
    if (status == SQL_I_NO_ROWS_FOUND) {
      MEMclose (&bufr);
      return (PDM_E_PART_NOT_FOUND);
    }
    else if (status == PDMS_NO_SUCH_TABLE) {
      MEMclose (&bufr);
      return (PDM_E_CATALOG_NOT_FOUND);
    }
    else if (status == PDMS_NO_SUCH_ATTRIBUTE) {
      MEMclose (&bufr);
      return (PDM_E_REQ_COLUMN_NOT_FOUND);
    }
    else {
      MEMclose (&bufr);
      status = _PDMget_db_error (status);
      if (status != PDM_I_TABLE_LOCKED)
	status = PDM_E_PART_NOT_FOUND;
      return (status);
    }
  }
  MEMclose (&bufr);
  PDMdebug ("EXIT:PDMverify_part\n");
  return (PDM_S_SUCCESS);
}


int             PDMquery_part_status ()
{
  long            status;
  char            sql_str[512];
  MEMptr          bufr = NULL;
  MEMptr          file_bufr = NULL;
  char          **data, **file_data;
  PDMdebug ("ENTER:PDMquery_part_status\n");
  sprintf (sql_str, "SELECT n_status, n_itemno FROM %s WHERE n_itemname = '%s' AND n_itemrev = '%s' ", PDMexec->catalog, PDMexec->part_num, PDMexec->revision);
  status = SQLquery (sql_str, &bufr, 512);
  if (status != SQL_S_SUCCESS) {
    sprintf (s, "%s %d\n",
	     "PDMquery_part_status failed ", status);
    PDMdebug (s);
    status = _PDMget_db_error (status);
    return (status);
  }
  status = MEMbuild_array (bufr);
  if (status != MEM_S_SUCCESS) {
    MEMclose (&bufr);
    sprintf (s, "%s %d\n",
	     "MEMbuild_array failed ", status);
    PDMdebug (s);
    return (status);
  }
  data = (char **) bufr->data_ptr;
  sprintf (sql_str, "SELECT n_couser FROM f_%s WHERE n_itemnum = %s and n_fileversion = (select max(n_fileversion) from f_%s where n_itemnum  = %s)", PDMexec->catalog, data[1], PDMexec->catalog, data[1]);
  status = SQLquery (sql_str, &file_bufr, 512);
  if (status != SQL_S_SUCCESS) {
    MEMclose (&file_bufr);
    sprintf (s, "%s %d\n",
	     "PDMquery_part_status failed ", status);
    PDMdebug (s);
    status = _PDMget_db_error (status);
    return (status);
  }
  status = MEMbuild_array (file_bufr);
  if (status != MEM_S_SUCCESS) {
    MEMclose (&bufr);
    MEMclose (&file_bufr);
    sprintf (s, "%s %d\n",
	     "MEMbuild_array failed ", status);
    PDMdebug (s);
    return (status);
  }
  file_data = (char **) file_bufr->data_ptr;

  if (!strcmp (data[0], "I")) {
    status = PDM_E_NOTCHECK_OUT;
    goto wrap;
  }
  else if (!strcmp (data[0], "")) {
    status = PDM_E_NOTCHECK_IN;
    goto wrap;
  }
  else if (!strcmp (data[0], "O")) {
    if (!strcmp (file_data[0], PDMexec->project)) {
      status = PDM_E_PART_CHECKED_OUT;
      goto wrap;
    }
    else {
      status = PDM_E_NOT_CO_USER;
      goto wrap;
    }
  }
  else if (!strcmp (data[0], "S")) {
    if (!strcmp (file_data[0], PDMexec->project)) {
      status = PDM_E_ASSEMBLY_CHECKED_OUT;
      goto wrap;
    }
    else {
      status = PDM_E_NOT_CO_USER;
      goto wrap;
    }
  }
  else if (!strcmp (data[0], "M")) {
    status = PDM_E_MEMBER_CHECKED_OUT;
    goto wrap;
  }
  else if (!strcmp (data[0], "MN")) {
    status = PDM_E_NO_PART_FILE;
    goto wrap;
  }
  else if (!strcmp (data[0], "TI")) {
    status = PDM_E_ON_TRANSFER;
    goto wrap;
  }
  else if (!strcmp (data[0], "TO")) {
    status = PDM_E_ON_TRANSFER;
    goto wrap;
  }
  else if (!strcmp (data[0], "TF")) {
    status = PDM_E_FILES_BEING_ADDED;
    goto wrap;
  }
  else if (!strcmp (data[0], "TM")) {
    status = PDM_E_FILES_BEING_DELETED;
    goto wrap;
  }
  else if (!strcmp (data[0], "ON")) {
    status = PDM_E_NO_FILES;
    goto wrap;
  }
  if (!strcmp (file_data[0], PDMexec->project)) {
    return (PDM_E_PART_CHECKED_OUT);
  }


wrap:
  MEMclose (&file_bufr);
  MEMclose (&bufr);
  _PDMdebug ("", "PART status = <0x%.8x>\n", status);

  PDMdebug ("EXIT:PDMquery_part_status\n");
  return (status);
}
/*
 * Modified by Kumar to return the catalog desc also 9/3/91
 */
int             PDMsshow_catalogs (bufr, temp_bufr)
MEMptr          bufr;
MEMptr         *temp_bufr;
{
  char          **data;
  char           *sql_str;
  char            type_str[512];
  char            search_str[1250];
  char            n_search[1024];
  char            n_app[6];
  char            n_app1[6];
  char            sort_str[250];
  PDMdebug ("ENTER:PDMsshow_catalogs\n");
  n_search[0] = '\0';
  sort_str[0] = '\0';
  search_str[0] = '\0';
  type_str[0] = '\0';
  *temp_bufr = NULL;
  status = MEMbuild_array (bufr);
  if (status != MEM_S_SUCCESS) {
    MEMclose (&bufr);
    sprintf (s, "MEMbuild_array failed status %d\n", status);
    PDMdebug (s);
    return (PDM_E_BUILD_ARRAY);
  }
  data = (char **) bufr->data_ptr;
  PDMdebug ("After MEMbuild_array\n");

  /* check if n_type is given */

  if (strlen (data[2])) {
    strcpy (n_app, data[2]);
    strcpy (n_app1, data[2]);
  }
  else {
    strcpy (n_app, "PDM");
    strcpy (n_app1, "pdm");
  }
  PDMdebug (n_app);
  PDMdebug ("After n_app\n");
  if (strlen (data[0])) {
    strcpy (n_search, data[0]);
  }
  else {
    strcpy (n_search, "");
  }
  if (strlen (data[0])) {
    sprintf (search_str, "WHERE %s", n_search);
  }
  else {
    sprintf (search_str, "%s", n_search);
  }
  PDMdebug ("After n_search\n");
  if (strlen (data[1])) {
    PDMdebug ("Inside data1\n");
    strcpy (sort_str, data[1]);
  }
  else {
    PDMdebug ("Inside else data1\n");
    strcpy (sort_str, "");
    PDMdebug ("Inside else1 data1\n");
    sprintf (sort_str, "n_catalogname");
  }
  PDMdebug ("After sort_str\n");
  if (!strlen (search_str)) {
    if (strlen (data[2]))
      sprintf (type_str, "WHERE n_identifier = '%s' ", data[2]);
    else
      sprintf (type_str, "(WHERE n_identifier = '%s' OR n_identifier = '%s')", "PDM", "pdm");
    PDMdebug ("Inside search_str\n");

  }
  else if (strlen (data[0])) {
    if (strlen (data[2]))
      sprintf (type_str, "AND n_identifier = '%s' ", data[2]);
    else
      sprintf (type_str, "(AND n_identifier = '%s' OR n_identifier = '%s')", n_app, n_app1);
    PDMdebug ("Inside data0\n");
  }
  PDMdebug ("After type_str\n");
  sql_str = (char *) malloc (bufr->row_size + 3500);
  if (sql_str == NULL) {
    MEMclose (&bufr);
    PDMdebug ("Could not malloc \n");
    return (PDM_E_COULD_NOT_MALLOC);
  }
  memset (sql_str, NULL, (bufr->row_size + 3500));
  sprintf (sql_str, "SELECT %s FROM %s %s %s ORDER BY %s",
	   "n_catalogname,n_catalogdesc", "nfmcatalogs",
	   search_str, type_str, sort_str);
  MEMclose (&bufr);
  bufr = NULL;
  status = SQLquery (sql_str, temp_bufr, 1024);
  if (status != SQL_S_SUCCESS) {
    switch (status) {
    case SQL_I_NO_ROWS_FOUND:
      free (sql_str);
      MEMclose (temp_bufr);
      PDMdebug ("No catalogs found \n");
      return (PDM_E_NO_CATALOGS_FOUND);
    case PDMS_NO_SUCH_ATTRIBUTE:
      free (sql_str);
      MEMclose (temp_bufr);
      sprintf (s, " %s  \n",
	       "Required column is missing");
      PDMdebug (s);
      return (PDM_E_REQ_COLUMN_NOT_FOUND);
    case PDMS_NO_SUCH_TABLE:
      free (sql_str);
      MEMclose (temp_bufr);
      PDMdebug ("nfmcatalogs can not be found \n");
      return (PDM_E_TABLE_NOT_FOUND);
    default:
      free (sql_str);
      MEMclose (temp_bufr);
      status = _PDMget_db_error (status);
      return (status);
    }
  }
  status = MEMbuild_array (*temp_bufr);
  if (status != MEM_S_SUCCESS) {
    MEMclose (temp_bufr);
    return (PDM_E_BUILD_ARRAY);
  }
  free (sql_str);
  PDMdebug ("EXIT:PDMsshow_catalogs\n");
  return (PDM_S_SUCCESS);
}

int             PDMshow_parts (bufr)
MEMptr         *bufr;
{
  char            sql_str[1024], type[6];
  int             catno;
  PDMdebug ("ENTER:PDMshow_parts\n");

  *bufr = NULL;

  status = PDMget_catno_type (PDMexec->catalog, &catno, type);
  if (status != SQL_S_SUCCESS) {
    PDMdebug ("No catalog found \n");
    return (PDM_E_TABLE_NOT_FOUND);

  }
  sql_str[0] = '\0';
  if (!strcmp (type, "CID") || !strcmp (type, "EID"))
    sprintf (sql_str, "SELECT DISTINCT %s FROM e_%s where n_itemno != -1 ORDER BY n_itemname", "(n_itemname), n_itemrev,p_parttype,n_itemdesc  ", PDMexec->catalog);
  else
    sprintf (sql_str, "SELECT DISTINCT %s FROM %s ORDER BY n_itemname", "(n_itemname), n_itemrev,p_parttype,n_itemdesc  ", PDMexec->catalog);
  status = SQLquery (sql_str, bufr, 1024);
  if (status != SQL_S_SUCCESS) {
    switch (status) {
    case SQL_I_NO_ROWS_FOUND:
      PDMdebug ("No Parts found \n");
      return (PDM_E_NO_PARTS_FOUND);
    case PDMS_NO_SUCH_ATTRIBUTE:
      MEMclose (bufr);
      sprintf (s, " %s  \n",
	       "Required column is missing");
      PDMdebug (s);
      return (PDM_E_REQ_COLUMN_NOT_FOUND);
    case SQL_E_UNKNOWN_RELATION:
      MEMclose (bufr);
      sprintf (s, "%s not found\n", PDMexec->catalog);
      PDMdebug (s);
      return (PDM_E_TABLE_NOT_FOUND);
    default:
      MEMclose (bufr);
      status = _PDMget_db_error (status);
      return (status);
    }
  }
  if ((*bufr)->rows > 2000) {
    MEMclose (bufr);
    PDMexec->return_buffer = NULL;
    PDMdebug ("EXIT:PDMshow_parts \n");
    return (PDM_E_TOO_MANY_PARTS);
  }
  PDMdebug ("EXIT:PDMshow_parts \n");
  return (PDM_S_SUCCESS);
}

int             PDMs_sql_query (bufr, return_buffer)
MEMptr          bufr;
MEMptr         *return_buffer;
{
  char           *sql_str;
  char           *fname = "PDMs_sql_query";
  char          **data;
  MEMptr          temp_bufr = NULL;
  int             size;
  _PDMdebug (fname, "ENTER:\n");

  *return_buffer = NULL;

  status = MEMbuild_array (bufr);
  if (status != MEM_S_SUCCESS) {
    _PDMdebug (fname, "MEMbuild_array failed status %d\n", status);
    return (PDM_E_BUILD_ARRAY);
  }
  size = 512;
  sql_str = (char *) malloc (size + bufr->row_size);
  if (sql_str == NULL) {
    _PDMdebug (fname, "Could not malloc \n");
    return (PDM_E_COULD_NOT_MALLOC);
  }
  memset (sql_str, "NULL", (size + bufr->row_size));
  data = (char **) bufr->data_ptr;
  strcpy (sql_str, "SELECT ");
  strcat (sql_str, data[0]);
  strcat (sql_str, " FROM ");
  strcat (sql_str, PDMexec->catalog);
  strcat (sql_str, " ");
  if (strlen (data[1])) {
    strcat (sql_str, data[1]);
    strcat (sql_str, " ");
    if (strlen (data[2])) {
      strcat (sql_str, data[2]);
    }
  }
  else {
    if (strlen (data[2])) {
      strcat (sql_str, data[2]);
    }
  }
  status = SQLquery (sql_str, &temp_bufr, 1024);
  free (sql_str);
  if (status != SQL_S_SUCCESS) {
    switch (status) {
    case SQL_I_NO_ROWS_FOUND:
      _PDMdebug (fname, "No Parts found \n");
      *return_buffer = temp_bufr;
      return (PDM_S_SUCCESS);
    case PDMS_NO_SUCH_ATTRIBUTE:
      _PDMdebug (fname, " %s  \n", "Required column is missing");
      return (PDM_E_REQ_COLUMN_NOT_FOUND);
    case PDMS_NO_SUCH_TABLE:
      _PDMdebug (fname, "%s not found\n", PDMexec->catalog);
      return (PDM_E_TABLE_NOT_FOUND);
    default:
      status = _PDMget_db_error (status);
      return (status);
    }
  }
  *return_buffer = temp_bufr;
  _PDMdebug (fname, "EXIT:\n");
  return (PDM_S_SUCCESS);
}


int             PDMs_sql_distinct (bufr, return_buffer)
MEMptr          bufr;
MEMptr         *return_buffer;
{
  char           *sql_str;
  char          **data;
  int             size;
  PDMdebug ("ENTER:PDMs_sql_distinct\n");

  *return_buffer = NULL;

  status = MEMbuild_array (bufr);
  if (status != MEM_S_SUCCESS) {
    MEMclose (&bufr);
    sprintf (s, "MEMbuild_array failed status %d\n", status);
    PDMdebug (s);
    return (PDM_E_BUILD_ARRAY);
  }
  size = 512;
  sql_str = (char *) malloc (size + bufr->row_size);
  if (sql_str == NULL) {
    MEMclose (&bufr);
    PDMdebug ("Could not malloc \n");
    return (PDM_E_COULD_NOT_MALLOC);
  }
  memset (sql_str, "NULL", (size + bufr->row_size));
  data = (char **) bufr->data_ptr;
  strcpy (sql_str, "SELECT DISTINCT ");
  strcat (sql_str, data[0]);
  strcat (sql_str, " FROM ");
  strcat (sql_str, PDMexec->catalog);
  strcat (sql_str, " ");
  if (strlen (data[1])) {
    strcat (sql_str, data[1]);
    strcat (sql_str, " ");
    if (strlen (data[2])) {
      strcat (sql_str, data[2]);
    }
  }
  else {
    if (strlen (data[2])) {
      strcat (sql_str, data[2]);
    }
  }
  MEMclose (&bufr);
  bufr = NULL;
  status = SQLquery (sql_str, &bufr, 1024);
  free (sql_str);
  if (status != SQL_S_SUCCESS) {
    switch (status) {
    case SQL_I_NO_ROWS_FOUND:
      PDMdebug ("No Parts found \n");
      *return_buffer = bufr;
      return (PDM_S_SUCCESS);
    case PDMS_NO_SUCH_ATTRIBUTE:
      MEMclose (&bufr);
      sprintf (s, " %s  \n",
	       "Required column is missing");
      PDMdebug (s);
      return (PDM_E_REQ_COLUMN_NOT_FOUND);
    case PDMS_NO_SUCH_TABLE:
      MEMclose (&bufr);
      sprintf (s, "%s not found\n", PDMexec->catalog);
      PDMdebug (s);
      return (PDM_E_TABLE_NOT_FOUND);
    default:
      MEMclose (&bufr);
      status = _PDMget_db_error (status);
      return (status);
    }
  }
  *return_buffer = bufr;
  PDMdebug ("EXIT:PDMs_sql_distinct \n");
  return (PDM_S_SUCCESS);
}
/*
 * Get a list of valid catalogs associated with the project entered. This is
 * done by making a join of nfmcatalogs,nfmprojects,
 * nfmprojectsamap,nfmcatalogsamap and giving one query. Performance was
 * evaluated between four queries with no join and one query with four joins.
 * Joins were faster in this case for a limited number of catalogs in the
 * nfmcatalogs table. In the future if the rows in the nfmcatalogs table
 * exceed more than say 500, it's better to eliminate the join. Kumar
 * 09/25/91
 */

int             PDMcatalogs_in_project (temp_bufr)
MEMptr         *temp_bufr;
{
  char           *fname = "PDMcatalogs_in_project";
  char            sql_str[1024];
  _PDMdebug (fname, "ENTER:\n");

  *temp_bufr = NULL;

  sql_str[0] = '\0';
  if (strlen (PDMexec->project) > 1) {
    sprintf (sql_str, "SELECT nfmcatalogs.n_catalogname FROM nfmcatalogs,nfmprojects,nfmcatalogsamap,nfmprojectsamap WHERE nfmprojects.n_projectname = '%s' AND nfmprojectsamap.n_projectno = nfmprojects.n_projectno AND nfmcatalogsamap.n_mapno = nfmprojectsamap.n_mapno AND nfmcatalogsamap.n_catalogno = nfmcatalogs.n_catalogno ORDER BY n_catalogname ",PDMexec->project);
	     }
  else {
    sprintf (sql_str, "SELECT n_catalogname FROM nfmcatalogs WHERE n_identifier = 'PDM'  ORDER BY n_catalogname");
  }
  status = SQLquery (sql_str, temp_bufr, 1024);
  if (status != SQL_S_SUCCESS) {
    switch (status) {
    case SQL_I_NO_ROWS_FOUND:
      {
	MEMclose (temp_bufr);
	sprintf (sql_str, "SELECT n_catalogname  FROM nfmcatalogs  WHERE n_identifier = 'PDM' ORDER BY n_catalogname");
	status = SQLquery (sql_str, temp_bufr, 512);
	if (status != SQL_S_SUCCESS) {
	  switch (status) {
	  case SQL_I_NO_ROWS_FOUND:
	    MEMclose (temp_bufr);
	    PDMdebug ("No catalogs found \n");
	    return (PDM_E_NO_CATALOGS);
	  case PDMS_NO_SUCH_ATTRIBUTE:
	    MEMclose (temp_bufr);
	    sprintf (s, " %s  \n",
		     "Required column is missing");
	    PDMdebug (s);
	    return (PDM_E_REQ_COLUMN_NOT_FOUND);
	  case PDMS_NO_SUCH_TABLE:
	    MEMclose (temp_bufr);
	    PDMdebug ("nfmprojects can not be found \n");
	    return (PDM_E_TABLE_NOT_FOUND);
	  default:
	    MEMclose (temp_bufr);
	    return (PDM_E_SQL_QUERY);
	  }
	}
	PDMdebug ("PDMprojects_of_catalog \n");
	return (PDM_S_SUCCESS);
      }
    case PDMS_NO_SUCH_ATTRIBUTE:
      MEMclose (temp_bufr);
      sprintf (s, " %s  \n",
	       "Required column is missing");
      PDMdebug (s);
      return (PDM_E_REQ_COLUMN_NOT_FOUND);
    case PDMS_NO_SUCH_TABLE:
      MEMclose (temp_bufr);
      PDMdebug ("nfmprojects can not be found \n");
      return (PDM_E_TABLE_NOT_FOUND);
    default:
      MEMclose (temp_bufr);
      status = _PDMget_db_error (status);
      return (status);
    }
  }
  _PDMdebug (fname, "EXIT:\n");
  return (PDM_S_SUCCESS);
}


/*
 * Get a list of projects associated with the catalog entered. This is done
 * by making a join of nfmcatalogs,nfmprojects,
 * nfmprojectsamap,nfmcatalogsamap and giving one query. Performance was
 * evaluated between four queries with no join and one query with four joins.
 * Joins were faster in this case for a limited number of catalogs in the
 * nfmcatalogs table. In the future if the rows in the nfmcatalogs table
 * exceed more than say 500, it's better to eliminate the join. Kumar
 * 09/25/91
 */

int             PDMprojects_of_catalog (temp_bufr)
MEMptr         *temp_bufr;
{
  char           *fname = "PDMprojects_of_catalog";
  char            sql_str[1024];
  _PDMdebug (fname, "ENTER:\n");

  *temp_bufr = NULL;

  sql_str[0] = '\0';
  sprintf (sql_str, "SELECT DISTINCT (nfmprojects.n_projectname) FROM nfmcatalogs,nfmprojects,nfmcatalogsamap,nfmprojectsamap WHERE nfmcatalogs.n_catalogname = '%s' AND nfmprojectsamap.n_projectno = nfmprojects.n_project no AND nfmcatalogsamap.n_mapno = nfmprojectsamap.n_mapno AND nfmcatalogsamap.n_catalogno = nfmcatalogs.n_catalogno ",PDMexec->catalog);
	   status = SQLquery (sql_str, temp_bufr, 1024);
  if (status != SQL_S_SUCCESS) {
    switch (status) {
    case SQL_I_NO_ROWS_FOUND:
      {
	MEMclose (temp_bufr);
	PDMdebug ("No projects mapped to this catalog \n");
	return (PDM_E_NO_PROJECTS_MAPPED);
      }
      /*
       * sprintf(sql_str,"SELECT %s FROM nfmprojects ",
       * "n_projectname,n_projectdesc "); status =
       * SQLquery(sql_str,temp_bufr,512);
       * 
       * if(status != SQL_S_SUCCESS) { switch(status) { case SQL_I_NO_ROWS_FOUND
       * : MEMclose(temp_bufr); PDMdebug("No catalogs found \n");
       * return(PDM_E_NO_PROJECTS); case PDMS_NO_SUCH_ATTRIBUTE:
       * MEMclose(temp_bufr); sprintf(s," %s  \n", "Required column is
       * missing"); PDMdebug(s); return(PDM_E_REQ_COLUMN_NOT_FOUND); case
       * PDMS_NO_SUCH_TABLE: MEMclose(temp_bufr); PDMdebug("nfmprojects can
       * not be found \n"); return(PDM_E_TABLE_NOT_FOUND); default:
       * MEMclose(temp_bufr); return(PDM_E_SQL_QUERY); }
       * _PDMdebug(fname,"EXIT-SUCCESS \n"); return(PDM_S_SUCCESS); }
       */
    case PDMS_NO_SUCH_ATTRIBUTE:
      MEMclose (temp_bufr);
      sprintf (s, " %s  \n",
	       "Required column is missing");
      PDMdebug (s);
      return (PDM_E_REQ_COLUMN_NOT_FOUND);
    case PDMS_NO_SUCH_TABLE:
      MEMclose (temp_bufr);
      PDMdebug ("nfmprojects can not be found \n");
      return (PDM_E_TABLE_NOT_FOUND);
    default:
      MEMclose (temp_bufr);
      status = _PDMget_db_error (status);
      return (PDM_E_SQL_QUERY);
    }
  }
  _PDMdebug (fname, "EXIT:\n");
  return (PDM_S_SUCCESS);
}


int             PDMlist_of_projects (temp_bufr)
MEMptr         *temp_bufr;
{
  char           *fname = "PDMlist_of_projects";
  char            sql_str[512];
  _PDMdebug (fname, "ENTER:\n");

  *temp_bufr = NULL;
  sprintf (sql_str, "SELECT DISTINCT (nfmprojects.n_projectname) FROM nfmprojects ");
  status = SQLquery (sql_str, temp_bufr, 1024);
  if (status != SQL_S_SUCCESS) {
    switch (status) {
    case SQL_I_NO_ROWS_FOUND:
      MEMclose (temp_bufr);
      PDMdebug ("No catalogs found \n");
      return (PDM_E_NO_PROJECTS);
    case PDMS_NO_SUCH_ATTRIBUTE:
      MEMclose (temp_bufr);
      _PDMdebug (fname, " %s  \n", "Required column is missing");
      return (PDM_E_REQ_COLUMN_NOT_FOUND);
    case PDMS_NO_SUCH_TABLE:
      MEMclose (temp_bufr);
      PDMdebug ("nfmprojects can not be found \n");
      return (PDM_E_TABLE_NOT_FOUND);
    default:
      MEMclose (temp_bufr);
      status = _PDMget_db_error (status);
      return (PDM_E_SQL_QUERY);
    }
  }
  _PDMdebug (fname, "EXIT:\n");
  return (PDM_S_SUCCESS);
}
/*
 * If a catalog name has been entered and the user enters a project name this
 * function checks that the catalog and the project are associated Kumar
 * 09/26/91
 */

int             PDMcatalog_project_map (PDMexec)
PDMexec_ptr     PDMexec;
{
  MEMptr          temp_bufr = NULL;
  char           *fname = "PDMcatalog_project_map";
  char            sql_str[1024];
  _PDMdebug (fname, "ENTER:\n");
  sprintf (sql_str, "SELECT nfmcatalogs.n_catalogname FROM nfmcatalogs,nfmprojects,nfmcatalogsamap,nfmprojectsamap WHERE nfmprojects.n_projectname = '%s' AND nfmprojectsamap.n_projectno = nfmprojects.n_projectno AND nfmcatalogsamap.n_mapno = nfmprojectsamap.n_mapno AND nfmcatalogsamap.n_catalogno = nfmcatalogs.n_catalogno AND nfmcatalogs.n_catalogname = '%s' ",PDMexec->project,PDMexec->catalog);
	   status = SQLquery (sql_str, &temp_bufr, 1024);
  if (status != SQL_S_SUCCESS) {
    switch (status) {
    case SQL_I_NO_ROWS_FOUND:
      MEMclose (&temp_bufr);
      PDMdebug ("No catalogs found \n");
      return (PDM_E_NO_CATALOG);
    case PDMS_NO_SUCH_ATTRIBUTE:
      MEMclose (&temp_bufr);
      sprintf (s, " %s  \n",
	       "Required column is missing");
      PDMdebug (s);
      return (PDM_E_REQ_COLUMN_NOT_FOUND);
    case PDMS_NO_SUCH_TABLE:
      MEMclose (&temp_bufr);
      PDMdebug ("nfmprojects can not be found \n");
      return (PDM_E_TABLE_NOT_FOUND);
    default:
      MEMclose (&temp_bufr);
      status = _PDMget_db_error (status);
      return (status);
    }
  }
  PDMexec->return_buffer = temp_bufr;
  _PDMdebug (fname, "EXIT:\n");
  return (PDM_S_SUCCESS);
}
/*
 * If the user enters a project name by itself, verify that it exists - Kumar
 * 09/25/91
 */

int             PDMsverify_project ()
{
  char           *fname = "PDMsverify_project";
  MEMptr          temp_bufr = NULL;
  char            sql_str[1024];
  _PDMdebug (fname, "ENTER:\n");

  sprintf (sql_str, "SELECT n_projectno FROM nfmprojects WHERE n_projectname = '%s' ", PDMexec->project);
  status = SQLquery (sql_str, &temp_bufr, 512);
  if (status != SQL_S_SUCCESS) {
    switch (status) {
    case SQL_I_NO_ROWS_FOUND:
      MEMclose (&temp_bufr);
      _PDMdebug (fname, "No catalogs found \n");
      return (PDM_E_NO_PROJECT);
    case PDMS_NO_SUCH_TABLE:
      MEMclose (&temp_bufr);
      _PDMdebug (fname, "nfmprojects can not be found \n");
      return (PDM_E_TABLE_NOT_FOUND);
    default:
      MEMclose (&temp_bufr);
      status = _PDMget_db_error (status);
      return (status);
    }
  }
  MEMclose (&temp_bufr);
  if (((strlen (PDMexec->project) > 0) && PDMexec->project != NULL)
      && (strcmp (PDMexec->catalog, "") && PDMexec->catalog != NULL)) {
    sql_str[0] = '\0';
    if (!strcmp (PDMexec->part_num, "MAP")) {
      sprintf (sql_str, " %s %s %s '%s' %s %s %s %s '%s' ",
	       "SELECT nfmcatalogs.n_catalogname FROM nfmcatalogs, ",
	       " nfmprojects,nfmcatalogsamap,nfmprojectsamap  ",
	       " WHERE nfmprojects.n_projectname =  ",
	       PDMexec->project,
	    "  AND nfmprojectsamap.n_projectno = nfmprojects.n_projectno  ",
	       " AND nfmcatalogsamap.n_mapno = nfmprojectsamap.n_mapno  ",
	     " AND nfmcatalogsamap.n_catalogno = nfmcatalogs.n_catalogno  ",
	       " AND nfmcatalogs.n_catalogname = ",
	       PDMexec->catalog);

      status = SQLquery (sql_str, &temp_bufr, 512);
      if (status != SQL_S_SUCCESS) {
	switch (status) {
	case SQL_I_NO_ROWS_FOUND:
	  MEMclose (&temp_bufr);
	  _PDMdebug (fname, "No Projects found \n");
	  return (PDM_E_NO_PROJECTS_MAPPED);
	default:
	  MEMclose (&temp_bufr);
	  status = _PDMget_db_error (status);
	  return (status);
	}
      }

      MEMclose (&temp_bufr);
      _PDMdebug (fname, "EXIT:\n");
    }
  }
  _PDMdebug (fname, "EXIT:\n");
  return (PDM_S_SUCCESS);
}

int             convert_toupper (string, string1)
char           *string;
char           *string1;
{
  int             i;
  for (i = 0; i < strlen (string); i++)
    string1[i] = toupper (string[i]);
  string1[i] = 0;
  return (PDM_S_SUCCESS);
}


int             PDMparts_of_catalog (bufr)
MEMptr         *bufr;
{
  char            sql_str1[1024];
  *bufr = NULL;

  PDMdebug ("ENTER:PDMparts_of_catalog\n");
  sql_str1[0] = '\0';
  sprintf (sql_str1, "SELECT DISTINCT (%s), %s FROM %s,F_%s ",
	   "n_itemname,n_itemrev", "p_parttype,n_itemdesc,n_pendingflag", PDMexec->catalog, PDMexec->catalog);
  status = SQLquery (sql_str1, bufr, 1024);
  if (status != SQL_S_SUCCESS) {
    switch (status) {
    case SQL_I_NO_ROWS_FOUND:
      PDMdebug ("No Parts found \n");
      return (PDM_E_NO_PARTS_FOUND);
    case PDMS_NO_SUCH_ATTRIBUTE:
      MEMclose (bufr);
      sprintf (s, " %s  \n",
	       "Required column is missing");
      PDMdebug (s);
      return (PDM_E_REQ_COLUMN_NOT_FOUND);
    case PDMS_NO_SUCH_TABLE:
      MEMclose (bufr);
      sprintf (s, "%s not found\n", PDMexec->catalog);
      PDMdebug (s);
      return (PDM_E_TABLE_NOT_FOUND);
    default:
      MEMclose (bufr);
      status = _PDMget_db_error (status);
      return (status);
    }
  }
  PDMdebug ("EXIT:PDMparts_of_catalog \n");
  return (PDM_S_SUCCESS);
}

int             PDMget_desc (bufr)
MEMptr         *bufr;
{
  char            sql_str1[1024];
  *bufr = NULL;

  PDMdebug ("ENTER:PDMget_desc\n");
  sql_str1[0] = '\0';
  sprintf (sql_str1, "SELECT DISTINCT n_itemdesc FROM %s ", PDMexec->catalog);
  status = SQLquery (sql_str1, bufr, 1024);
  if (status != SQL_S_SUCCESS) {
    switch (status) {
    case SQL_I_NO_ROWS_FOUND:
      PDMdebug ("No Parts found \n");
      return (PDM_E_NO_PARTS_FOUND);
    case PDMS_NO_SUCH_ATTRIBUTE:
      MEMclose (bufr);
      sprintf (s, " %s  \n",
	       "Required column is missing");
      PDMdebug (s);
      return (PDM_E_REQ_COLUMN_NOT_FOUND);
    case PDMS_NO_SUCH_TABLE:
      MEMclose (bufr);
      sprintf (s, "%s not found\n", PDMexec->catalog);
      PDMdebug (s);
      return (PDM_E_TABLE_NOT_FOUND);
    default:
      MEMclose (bufr);
      status = _PDMget_db_error (status);
      return (status);
    }
  }
  PDMdebug ("EXIT:PDMget_desc \n");
  return (PDM_S_SUCCESS);
}



int             PDMget_state_name (bufr)
MEMptr         *bufr;
{
  char            sql_str1[1024];
  PDMdebug ("ENTER:PDMget_state_name\n");

  *bufr = NULL;

  sql_str1[0] = '\0';
  sprintf (sql_str1, "SELECT nfmstates.n_statename FROM %s ,nfmstates WHERE %s.n_itemname = '%s' AND %s.n_itemrev = '%s' AND nfmstates.n_stateno = %s.n_stateno", PDMexec->catalog, PDMexec->catalog, PDMexec->part_num, PDMexec->catalog, PDMexec->revision, PDMexec->catalog);
  status = SQLquery (sql_str1, bufr, 1024);
  if (status != SQL_S_SUCCESS) {
    switch (status) {
    case SQL_I_NO_ROWS_FOUND:
      PDMdebug ("No Parts found \n");
      return (PDM_E_NO_PARTS_FOUND);
    case PDMS_NO_SUCH_ATTRIBUTE:
      MEMclose (bufr);
      sprintf (s, " %s  \n",
	       "Required column is missing");
      PDMdebug (s);
      return (PDM_E_REQ_COLUMN_NOT_FOUND);
    case PDMS_NO_SUCH_TABLE:
      MEMclose (bufr);
      sprintf (s, "%s not found\n", PDMexec->catalog);
      PDMdebug (s);
      return (PDM_E_TABLE_NOT_FOUND);
    default:
      MEMclose (bufr);
      status = _PDMget_db_error (status);
      return (status);
    }
  }
  PDMdebug ("EXIT:PDMget_state_name \n");
  return (PDM_S_SUCCESS);
}



/*
 * Kumar - to return the only the catalog acls 2/9/92
 */

int             PDMshow_catalog_acls (return_buffer)
MEMptr         *return_buffer;
{
  MEMptr          temp_bufr = NULL;
  char            sql_str[512];
  PDMdebug ("ENTER:PDMshow_catalog_acls\n");

  /* initialize return buffer */
  *return_buffer = NULL;

  sql_str[0] = '\0';
  /*
   * Added support to include userno also in the query. MaC 012894...
   * sprintf(sql_str,"select distinct (nfmacls.n_aclno), nfmacls.n_aclname
   * from nfmacls, nfmworkflow where nfmacls.n_complete = 'Y' and
   * nfmworkflow.n_workflowno = nfmacls.n_workflowno and
   * nfmworkflow.n_workflowtype = 'C'");
   */
  sprintf (sql_str,
	   "select distinct (nfmacls.n_aclno), nfmacls.n_aclname  \
         from nfmacls, nfmworkflow, nfmaclusers where \
         nfmacls.n_complete = 'Y' \
         and nfmworkflow.n_workflowno = nfmacls.n_workflowno \
	   and nfmworkflow.n_workflowtype = 'C' \
	   and nfmaclusers.n_aclno = nfmacls.n_aclno \
	   and nfmaclusers.n_userno = %d ",  PDMexec->user_id); 

	   status = SQLquery (sql_str, &temp_bufr, 1024);
  if (status != SQL_S_SUCCESS) {
    switch (status) {
    case SQL_I_NO_ROWS_FOUND:
      MEMclose (&temp_bufr);
      PDMdebug ("No catalogs found \n");
      return (PDM_E_NO_ACLS_AVAIL);
    case PDMS_NO_SUCH_ATTRIBUTE:
      MEMclose (&temp_bufr);
      sprintf (s, " %s  \n",
	       "Required column is missing");
      PDMdebug (s);
      return (PDM_E_REQ_COLUMN_NOT_FOUND);
    case PDMS_NO_SUCH_TABLE:
      MEMclose (&temp_bufr);
      PDMdebug ("nfmcatalogs can not be found \n");
      return (PDM_E_TABLE_NOT_FOUND);
    default:
      MEMclose (&temp_bufr);
      status = _PDMget_db_error (status);
      return (status);
    }
  }
  *return_buffer = temp_bufr;
  PDMdebug ("EXIT:PDMshow_catalog_acls\n");
  return (PDM_S_SUCCESS);
}


int             PDMget_part_type_desc (bufr)
MEMptr         *bufr;
{
  char            sql_str[512];
  *bufr = NULL;

  PDMdebug ("ENTER:PDMget_part_type_desc\n");
  sql_str[0] = '\0';
  sprintf (sql_str, "SELECT  %s FROM %s WHERE n_itemname = '%s' AND n_itemrev = '%s' ", "p_parttype,n_itemdesc  ", PDMexec->catalog, PDMexec->part_num, PDMexec->revision);
  status = SQLquery (sql_str, bufr, 1024);
  if (status != SQL_S_SUCCESS) {
    switch (status) {
    case SQL_I_NO_ROWS_FOUND:
      PDMdebug ("No Parts found \n");
      return (PDM_E_NO_PARTS_FOUND);
    case PDMS_NO_SUCH_ATTRIBUTE:
      MEMclose (bufr);
      sprintf (s, " %s  \n",
	       "Required column is missing");
      PDMdebug (s);
      return (PDM_E_REQ_COLUMN_NOT_FOUND);
    case PDMS_NO_SUCH_TABLE:
      MEMclose (bufr);
      sprintf (s, "%s not found\n", PDMexec->catalog);
      PDMdebug (s);
      return (PDM_E_TABLE_NOT_FOUND);
    default:
      MEMclose (bufr);
      status = _PDMget_db_error (status);
      return (status);
    }
  }
  PDMdebug ("EXIT:PDMget_part_type_desc \n");
  return (PDM_S_SUCCESS);
}

/* Kumar - 6/3/92- To support PDU 1.4.3 - 2.0.0 conversion 
   Modified to add support for view catalog types. MaC 061594 */

int             PDMsget_catno_partno (ret_bufr)
MEMptr         *ret_bufr;
{
  char            *fn = "PDMsget_catno_partno";
  int             catno, n_itemno;
  char            s[100];
  PDMdebug ("ENTER:PDMsget_catno_partno\n");

  *ret_bufr = NULL;

  status = PDMris_get_catno (PDMexec->catalog, &catno);
  if (status == PDM_E_CATALOG_NOT_FOUND) {
    _PDMdebug (fn, "Catalog %s not found\n", PDMexec->catalog);
    return (status);
  }
  else if (status == SQL_I_NO_ROWS_FOUND) {
    return (PDM_E_CATALOG_NOT_FOUND);
  }
  else if (status != SQL_S_SUCCESS) {
    _PDMdebug (fn, "PDMris_get_catno failed: 0x%.8x\n", status);
    return (status);
  }

  status = PDMquery_partno (PDMexec->catalog, PDMexec->part_num,
			    PDMexec->revision, &n_itemno);
  if (status != PDM_S_SUCCESS) {
    _PDMdebug (fn, "PDMquery_partno failed status %d\n", status);
    return (status);
  }

  status = MEMopen (ret_bufr, 512);
  if (status != MEM_S_SUCCESS) {
    _PDMdebug (fn, "MEMopen failed status %d\n", status);
    return (PDM_E_OPEN_BUFFER);
  }

  status = MEMwrite_format (*ret_bufr, "n_catalogno", "integer");
  if (status != MEM_S_SUCCESS) {
    _PDMdebug (fn, "MEMwrite_format failed status %d\n", status);
    MEMclose (ret_bufr);
    return (PDM_E_WRITE_FORMAT);
  }

  status = MEMwrite_format (*ret_bufr, "n_itemno", "integer");
  if (status != MEM_S_SUCCESS) {
    _PDMdebug (fn, "MEMwrite_format failed status %d\n", status);
    MEMclose (ret_bufr);
    return (PDM_E_WRITE_FORMAT);
  }

  sprintf (s, "%d\1%d\1", catno, n_itemno);

  status = MEMwrite (*ret_bufr, s);
  if (status != MEM_S_SUCCESS) {
    _PDMdebug (fn, "MEMwrite failed status %d\n", status);
    MEMclose (ret_bufr);
    return (PDM_E_WRITE_ROW);
  }

  PDMdebug ("EXIT:PDMsget_catno_partno \n");
  return (PDM_S_SUCCESS);
}



int             PDMcheck_part_status ()
{
  char           *fname = "PDMcheck_part_status";
  long            status;
  char            sql_str[512];
  MEMptr          bufr = NULL;
  MEMptr          file_bufr = NULL;
  char          **data, **file_data;

  _PDMdebug (fname, "ENTER:\n");

  /* this query did not have join clause in where MaC 061892 */
  /*
   * sprintf(sql_str,"SELECT t1.n_status, t1.n_itemno, t2.n_couser FROM %s t1
   * ,f_%s t2 WHERE t1.n_itemname = '%s' AND t1.n_itemrev = '%s'",
   * PDMexec->catalog, PDMexec->catalog,PDMexec->part_num,
   * PDMexec->revision);
   */
/* Add support for checking Max File Version MaC */



  sprintf (sql_str,
"SELECT %s FROM %s t1 ,f_%s t2 WHERE %s '%s' %s '%s' %s AND t2.n_fileversion = (SELECT MAX(n_fileversion) FROM f_%s t2 WHERE t1.n_itemno = t2.n_itemnum) ",
	   " t1.n_status, t1.n_itemno, t2.n_couser  ",
	   PDMexec->catalog, PDMexec->catalog,
	   "t1.n_itemname = ", PDMexec->part_num,
	   " AND t1.n_itemrev = ", PDMexec->revision,
	   " AND t1.n_itemno = t2.n_itemnum",
           PDMexec->catalog);

  status = SQLquery (sql_str, &bufr, 512);
  if (status != SQL_S_SUCCESS) {
    if (status == SQL_I_NO_ROWS_FOUND)
      return (PDM_E_PART_NOT_FOUND);
    else
      _PDMdebug (fname, "%s %d\n", "PDMquery_part_status failed ", status);
    status = _PDMget_db_error (status);
    return (status);
  }

  status = MEMbuild_array (bufr);
  if (status != MEM_S_SUCCESS) {
    MEMclose (&bufr);
    _PDMdebug (fname, "%s %d\n", "MEMbuild_array failed ", status);
    return (status);
  }

  data = (char **) bufr->data_ptr;

  if (!strcmp (data[0], "")) {
    MEMclose (&bufr);
    _PDMdebug ("PART is", "NEVER BEEN CHECKED IN \n");
    return (PDM_I_NEVER_CHECKED_IN);
  }

  sprintf (sql_str, "SELECT t1.n_co,t1.n_copy,t1.n_sano, t1.n_ref FROM nfmsafiles t1, nfmcatalogs t2 WHERE t1.n_sano = %d AND t1.n_itemno = %s AND t2.n_catalogname = '%s' AND t2.n_catalogno = t1.n_catalogno ", storage->storage_no, data[1], PDMexec->catalog);
  status = SQLquery (sql_str, &file_bufr, 512);
  if (status != SQL_S_SUCCESS) {
    MEMclose (&file_bufr);
    if (status == SQL_I_NO_ROWS_FOUND) {
      sprintf (sql_str, "SELECT t1.n_co,t1.n_copy,t1.n_sano, t1.n_ref FROM nfmsafiles t1, nfmcatalogs t2 WHERE t1.n_itemno = %s AND t2.n_catalogname = '%s' AND t2.n_catalogno = t1.n_catalogno ", data[1], PDMexec->catalog);

      status = SQLquery (sql_str, &file_bufr, 512);
      if (status != SQL_S_SUCCESS) {
	MEMclose (&file_bufr);
	if (status == SQL_I_NO_ROWS_FOUND) {
	  if ((!strcmp (data[0], "O") || !strcmp (data[0], "S"))) {
	    MEMclose (&bufr);
	    _PDMdebug ("PART has", "NO LOCAL FILE MANAGER ENTRY\n");
	    return (PDM_I_OUT_NO_LFM_ENTRY);
	  }
	  else if (!strncmp (data[0], "T", 1)) {
	    MEMclose (&bufr);
	    _PDMdebug ("PART is", "ON TRANSFER\n");
	    return (PDM_I_OUT_NO_LFM_ENTRY);
	  }
	  else if (!strcmp (data[0], "I"))
	    return (PDM_I_CHECKED_IN);
	  else
	    return (PDM_I_NEVER_CHECKED_IN);
	}
	_PDMdebug (fname, "%s %d\n", "PDMquery_part_status failed ", status);
	return (status);
      }

      status = MEMbuild_array (file_bufr);
      if (status != MEM_S_SUCCESS) {
	MEMclose (&bufr);
	MEMclose (&file_bufr);
	_PDMdebug (fname, "%s %d\n", "MEMbuild_array failed ", status);
	return (status);
      }

      file_data = (char **) file_bufr->data_ptr;

      if (PDMdebug_on) {
	_PDMdebug (fname, "PART's n_status -> %s\n", data[0]);
	_PDMdebug (fname, 
              "PART's <n_co -> %s> <n_copy->%s> <n_sano->%s> <n_ref->%s>\n", 
              file_data[0], file_data[1], file_data[2], file_data[3]);
      }

      if (!strcmp (data[0], "O") || !strcmp (data[0], "S")) {
	if (atoi (file_data[2]) == storage->storage_no) {
	  if (!strcmp (file_data[0], "Y") || !strcmp (file_data[0], "y")) {
            /* Added another fix to check the co user id MaC*/
            _PDMdebug (fname, "cousr[%s] : curusr[%s]\n",
                        data[2], NFMglobal.NFMusername);
	    if (!strcmp (data[2], NFMglobal.NFMusername)) {
	      MEMclose (&file_bufr);
	      MEMclose (&bufr);
	      _PDMdebug ("PART is", "CHECKED OUT BY YOU\n");
	      return (PDM_I_CHECKED_OUT_BY_YOU);
            }
            else
                {
	      _PDMdebug ("PART is", "CHECKED OUT BY Someone else\n");
              return (PDM_I_CHECKED_OUT_BY_ANOTHER_USER);
               }
	  }
	  else {
	    if (!strcmp (file_data[1], "Y") || !strcmp (file_data[1], "y")) {
	      MEMclose (&file_bufr);
	      MEMclose (&bufr);
	      _PDMdebug ("PART is", "COPIED BY YOU\n");
	      return (PDM_I_COPIED_TO_LOCAL_BY_YOU);
	    }
	  }
	}
	else {
	  MEMclose (&file_bufr);
	  MEMclose (&bufr);
	  _PDMdebug ("PART is", "CHECKED OUT BY SOME ELSE\n");
	  return (PDM_I_CHECKED_OUT_BY_ANOTHER_USER);
	}
      }
      else if (!strncmp (data[0], "I", 1)) {
	MEMclose (&file_bufr);
	MEMclose (&bufr);
	_PDMdebug ("PART is", "CHECKED IN, BUT COPIED to another STATION\n");
	return (PDM_I_CHECKED_IN);
      }
      else {
	if (!strncmp (data[0], "T", 1)) {
	  MEMclose (&file_bufr);
	  MEMclose (&bufr);
	  _PDMdebug ("PART is", "ON TRANFER\n");
	  return (PDM_I_ON_TRANSFER);
	}
	MEMclose (&file_bufr);
	MEMclose (&bufr);
	return (PDM_I_CHECKED_OUT_BY_ANOTHER_USER);
      }
    }
    _PDMdebug (fname, "%s %d\n", "PDMquery_part_status failed ", status);
    status = _PDMget_db_error (status);
    return (status);
  }
  else {
    status = MEMbuild_array (file_bufr);
    if (status != MEM_S_SUCCESS) {
      MEMclose (&bufr);
      MEMclose (&file_bufr);
      _PDMdebug (fname, "%s %d\n", "MEMbuild_array failed ", status);
      return (status);
    }
    file_data = (char **) file_bufr->data_ptr;
    if (PDMdebug_on) {
      _PDMdebug (fname, "PART's n_status -> %s\n", data[0]);
      _PDMdebug (fname, "PART's <n_co -> %s> <n_copy->%s> <n_sano->%s> <n_ref->%s>\n", file_data[0], file_data[1], file_data[2], file_data[3]);
    }
    if (!strcmp (data[0], "O") || !strcmp (data[0], "S")) {
      if (atoi (file_data[2]) == storage->storage_no) {
	if (!strcmp (file_data[0], "Y") || !strcmp (file_data[0], "y")) {
            /* Added another fix to check the co user id MaC*/
            _PDMdebug (fname, "cousr[%s] : curusr[%s]\n",
                        data[2], NFMglobal.NFMusername);
	    if (!strcmp (data[2], NFMglobal.NFMusername)) {
	      MEMclose (&file_bufr);
	      MEMclose (&bufr);
	      _PDMdebug ("PART is", "CHECKED OUT BY YOU - II\n");
	      return (PDM_I_CHECKED_OUT_BY_YOU);
            }
            else
                {
	      _PDMdebug ("PART is", "CHECKED OUT BY Someone else\n");
              return (PDM_I_CHECKED_OUT_BY_ANOTHER_USER);
               }
	}
	else {
	  if (!strcmp (file_data[1], "Y") || !strcmp (file_data[1], "y")) {
	    MEMclose (&file_bufr);
	    MEMclose (&bufr);
	    _PDMdebug ("PART is", "COPIED BY YOU\n");
	    return (PDM_I_COPIED_TO_LOCAL_BY_YOU);
	  }
	}
      }
      else {
	MEMclose (&file_bufr);
	MEMclose (&bufr);
	if (!strcmp (NFMglobal.NFMusername, data[2])) {
	  _PDMdebug ("PART is", "CHECKED OUT BY SAME USER IN ANOTHER PLACE\n");
	  return (PDM_E_CO_SAME_USER_DIFF_SA);
	}
	else {
	  _PDMdebug ("PART is", "CHECKED OUT BY SOME ELSE\n");
	  return (PDM_I_CHECKED_OUT_BY_ANOTHER_USER);
	}
      }
    }
    else if (!strcmp (data[0], "I")) {
      if (atoi (file_data[2]) == storage->storage_no) {
	if (!strcmp (file_data[1], "Y") || !strcmp (file_data[1], "y")) {
	  MEMclose (&file_bufr);
	  MEMclose (&bufr);
	  _PDMdebug ("PART is", "COPIED BY YOU\n");
	  return (PDM_I_COPIED_TO_LOCAL_BY_YOU);
	}
	else if (atoi (file_data[3]) > 0) {
	  MEMclose (&file_bufr);
	  MEMclose (&bufr);
	  _PDMdebug ("PART is", "ATTACHED TO SOME LOCAL ASSEMBLY\n");
	  return (PDM_I_ATTACHED_TO_LOCAL_ASSY);
	}
      }
      else {
	MEMclose (&file_bufr);
	MEMclose (&bufr);
	_PDMdebug ("PART is", "CHECKED IN and COPIED TO LOCAL somewhere\n");
	return (PDM_I_CHECKED_IN);
      }
    }
    else {
      if (!strncmp (data[0], "T", 1)) {
	MEMclose (&file_bufr);
	MEMclose (&bufr);
	_PDMdebug ("PART is", "ON TRANFER\n");
	return (PDM_I_ON_TRANSFER);
      }
      MEMclose (&file_bufr);
      MEMclose (&bufr);
      return (PDM_I_CHECKED_OUT_BY_ANOTHER_USER);
    }
  }
  _PDMdebug (fname, "%s %d\n", "PDMquery_part_status failed ", status);
  _PDMdebug (fname, "Exit-ERROR \n");
  return (status);
}



int             PDMquery_lower_case_catalogname (catname)
char           *catname;
{
  char           *fn = "PDMquery_lower_case_catalogname";
  long            status;
  char            sql_str[512];
  char            lower_catname[128];
  MEMptr          table_name_bufr = NULL;
  PDMdebug ("ENTER: PDMquery_lower_case_catalogname\n");

  _PDMdebug (fn, "catname[%s]\n", catname);

  lower_catname[0] = '\0';
  sql_str[0] = '\0';

  PDMconvert_to_lower (catname, lower_catname);
  /*
   * sprintf(sql_str, "Select table_name FROM ris_tables WHERE table_name =
   * '%s' or upper_table_name = '%s'", catname, lower_catname);
   */

/* RIS dictionary tables in V5 named different. 26/apr/95 - raj. */

#if defined ( RISV4 )

  sprintf (sql_str,
	   "SELECT table_name FROM ris_tables WHERE table_name = '%s'",
	   lower_catname);

#elif defined ( RISV5 )

  sprintf (sql_str,
	   "SELECT table_name FROM ris5tables WHERE table_name = '%s'",
	   lower_catname);

#else
#error "RIS version must be defined"
#endif

  status = SQLquery (sql_str, &table_name_bufr, 1024);
  if (status != SQL_S_SUCCESS) {
    if (status == SQL_I_NO_ROWS_FOUND) {
      MEMclose (&table_name_bufr);
      _PDMdebug (fn, "EXIT:CATALOG NOT FOUND\n");
      return (PDM_E_CATALOG_NOT_FOUND);
    }
    MEMclose (&table_name_bufr);
    _PDMdebug (fn,
    "Querying the ristables for lower case catalog name existance 0x%.8x\n",
	       status);
    return (status);
  }

  MEMclose (&table_name_bufr);
  _PDMdebug (fn, "Catalog found %s\n", lower_catname);
  _PDMdebug (fn, "Exit \n");
  return (PDM_S_SUCCESS);
}
