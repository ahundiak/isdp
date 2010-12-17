#include "machine.h"
#include <stdio.h>
#include <stdlib.h>
#include "MEMstruct.h"
#include "NFMerrordef.h"
#include "DEBUG.h"
#include "ERR.h"
#include "SQLerrordef.h"
#define ATTR 4  

long CVTrename_attr ()
{
  long status, i, y;
  char *fname = "CVTrename_attr";
  char sql_str[500];
  int offset;
  MEMptr buffer = NULL;
  char **data, **column, dat[100];
  long CVTdelete_attr ();


  sprintf(sql_str, "Select n_attrno, n_name, n_datatype From \
  nfmattributes"); 
  status = SQLquery(sql_str, &buffer, MEM_SIZE);
  if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
  {
	ERRload_struct(NFM, NFM_E_SQL_QUERY, "", "");
    _NFMdebug((fname, "SQL query : status = <0x%.8x>\n", status ));
    return (NFM_E_SQL_QUERY);
  }

  status = MEMbuild_array(buffer);
  if (status != MEM_S_SUCCESS)
  {
	ERRload_struct(NFM, NFM_E_MEM, "", "");
    _NFMdebug ((fname, "MEMbuild_array : status = <0x%.8x>\n", status));
    return (NFM_E_MEM);
  }

  data = (char **) buffer -> data_ptr ;
  column = (char **) buffer -> column_ptr ;
  
  status = NFMset_autocommit_off (0);
  if (status != NFM_S_SUCCESS)
  {
	_NFMdebug((fname, "Failure : status = <0x%.8x>\n", status));
	return (status);
  }

  for (i=0; i<buffer -> rows; i++)
  {
	offset = i*buffer -> columns;
	for (y=0; y<buffer -> columns; y++)
	{
	  if (strcmp(column[y], "n_name") == 0)
	  {
		if (strcmp(data[offset+y], "n_coout") == 0)
		{
		  strcpy(dat, "n_status");
		  strcpy(data[offset+y+3], "Status");
		  sprintf(sql_str, "Update nfmattributes set n_name = '%s', n_synonym = '%s' where n_attrno = %s", dat, data[offset+y+3], data[offset+y-1]); 
		  status = SQLstmt(sql_str);
		  if (status != SQL_S_SUCCESS)
		  {
			ERRload_struct (NFM, NFM_E_SQL_STMT, "", "");
			_NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
			return (NFM_E_SQL_STMT);
          }
        }
		else if (strcmp(data[offset+y], "n_pendinguser") == 0)
		{
		  strcpy(dat, "n_convertind");
		  strcpy(data[offset+y+1], "char(10)");
		  strcpy(data[offset+y+2], "Convert Indicator");
		  sprintf(sql_str, "Update nfmattributes set n_name = '%s', n_datatype = '%s', n_synonym = '%s' where n_attrno = %s", dat, data[offset+y+1],data[offset+y+2], data[offset+y-1]);
		  status = SQLstmt(sql_str);
		  if (status != SQL_S_SUCCESS)
		  {
			ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");
			_NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
			return (NFM_E_SQL_STMT);
          }
        }
		else if (strcmp(data[offset+y], "n_creationdate") == 0)
		{
		  strcpy(data[offset+y+1], "timestamp");
		  sprintf(sql_str, "Update nfmattributes set n_datatype = '%s' where n_attrno = %s", data[offset+y+1], data[offset+y-1]);
		  status = SQLstmt(sql_str);
		  if (status != SQL_S_SUCCESS)
		  {
			ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");
			_NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
			return (NFM_E_SQL_STMT);
          }
        }
		else if (strcmp(data[offset+y], "n_updatedate") == 0)
		{
		  strcpy(data[offset+y+1], "timestamp");
		  sprintf(sql_str, "Update nfmattributes set n_datatype = '%s' where n_attrno = %s", data[offset+y+1], data[offset+y-1]);
		  status = SQLstmt(sql_str);
		  if (status != SQL_S_SUCCESS)
		  {
			ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");
			_NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
			return (NFM_E_SQL_STMT);
          }
        }
		else if (strcmp(data[offset+y], "n_cidate") == 0)
		{
		  strcpy(data[offset+y+1], "timestamp");
		  sprintf(sql_str, "Update nfmattributes set n_datatype = '%s' where n_attrno = %s", data[offset+y+1], data[offset+y-1]);
		  status = SQLstmt(sql_str);
		  if (status != SQL_S_SUCCESS)
		  {
			ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");
			_NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
			return (NFM_E_SQL_STMT);
          }
        }
		else if (strcmp(data[offset+y], "n_codate") == 0)
		{
		  strcpy(data[offset+y+1], "timestamp");
		  sprintf(sql_str, "Update nfmattributes set n_datatype = '%s' where n_attrno = %s", data[offset+y+1], data[offset+y-1]);
		  status = SQLstmt(sql_str);
		  if (status != SQL_S_SUCCESS)
		  {
			ERRload_struct(NFM,NFM_E_SQL_STMT, "", "");
			_NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
			return (NFM_E_SQL_STMT);
          }
        }
      }
    }
  }
  status = CVTdelete_attr ();
  if (status != NFM_S_SUCCESS)
  {
	ERRload_struct(NFM, NFM_E_MESSAGE, "%s", "Deleting datatypes failed in nfmattributes table");
	_NFMdebug ((fname, "Delete nfmattribute datatype failed : status = <0x%.8x>\n", status));
	return (NFM_E_MESSAGE);
  }
  status = NFMset_autocommit_on (0);
  if (status != NFM_S_SUCCESS)
  {
	_NFMdebug((fname, "Failure : status = <0x%.8x>\n",status));
	return (status);
  }
  _NFMdebug((fname, "SUCCESSFUL\n"));
  return (NFM_S_SUCCESS);
}

long CVTdelete_attr ()
{
  static char *fname = "CVTdelete_attr";
  char sql_str[500], del[5][30];
  long status, x;

  strcpy(del[0], "n_creationtime");
  strcpy(del[1], "n_updatetime");
  strcpy(del[2], "n_citime");
  strcpy(del[3], "n_cotime");

  for (x=0; x<ATTR; x++)
  {
	sprintf(sql_str, "Delete from nfmattributes where n_name = '%s'", del[x]);
	status = SQLstmt(sql_str);
	if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
	{
	  ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");
	  _NFMdebug ((fname, "Delete SQL Failed : status = <0x%.8x>\n", status));
	  return (NFM_E_SQL_STMT);
    }
  }
  strcpy(sql_str, "delete from nfmattributes where n_name = 'n_pendingflag' and n_tableno in (select n_tableno from nfmtables where n_tablename like 'f_%')");
  status = SQLstmt(sql_str);
  if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
  {
	ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");
	_NFMdebug((fname, "Delete SQL Failed : status = <0x%.8x>\n", status));
	return (NFM_E_SQL_STMT);
  }
  return (NFM_S_SUCCESS) ;
}

