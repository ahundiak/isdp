#include "machine.h"
#include <stdio.h>
#include "NFMerrordef.h"
#include "MEMstruct.h"
#include "NFMstruct.h"
#include "ERR.h"
#include "DEBUG.h"

#define RET_TABLE_NO 2

extern struct NFMitem_info *NFMitem_ptr;


/* This function returns the <n_name,n_datatype> combination 
   for n_itemno,n_itemname,n_itemrev, given a n_tableno
*/

long _NFMquery_data_defn1 (tabno,itemno,dtype1,
			    itemname,dtype2,itemrev,dtype3)
long	   tabno;
char	   *itemno, *itemname, *itemrev;
char	   *dtype1, *dtype2, *dtype3;
{
  static char *fname = "_NFMquery_data_defn1" ;
  long    status;
  char    sql_str [200];
  MEMptr  list = NULL;
  char    **data;
  int     x, nx;

  _NFMdebug ((fname, "<%s>  ", ""  ));

  itemno[0] = 0; itemname[0] = 0; itemrev[0] = 0;
  dtype1[0] = 0; dtype2[0] = dtype3[0] = 0;

  sprintf (sql_str, 
  "SELECT %s  FROM %s WHERE %s  = %d %s %s %s",
  "n_name,n_datatype ", "nfmattributes",
  " n_tableno ", tabno,
  "AND (n_name = 'n_itemno' ",
  "OR n_name = 'n_itemname' ",
  "OR n_name = 'n_itemrev') ");
  status = SQLquery (sql_str, &list, MEM_SIZE);
  if (status != SQL_S_SUCCESS)
  {
    MEMclose (&list);

    if ((status) == SQL_I_NO_ROWS_FOUND)
    {
      ERRload_struct (NFM, NFM_E_BAD_ATTR_VALUE, "", NULL); 
      _NFMdebug ((fname, "No Such Attr : status = <0x%.8x>\n",
      NFM_E_BAD_ATTR_VALUE));
      return (NFM_E_BAD_ATTR_VALUE);
    }

    ERRload_struct (NFM,  NFM_E_SQL_QUERY, "", NULL); 
    _NFMdebug ((fname, "SQL Query Syntax : status = <0x%.8x>\n",
		status));
    return ( NFM_E_SQL_QUERY);
  }

  status = MEMbuild_array (list);
  if (status != MEM_S_SUCCESS)
  {
    MEMclose (&list);
    ERRload_struct (NFM, NFM_E_MEM, "", NULL); 
    _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
		status));
    return (NFM_E_MEM);
  }

  data = (char **) list -> data_ptr;

  for (x = 0; x < list -> rows; ++x)
  {
    nx = x * list->columns;
    if(!strcmp(data[nx],"n_itemno"))
    {
      strcpy(itemno,data[nx+1]);
      strcpy(dtype1,data[nx+2]);
    }	
    else if(!strcmp(data[nx],"n_itemname"))
    {
      strcpy(itemname,data[nx+1]);
      strcpy(dtype2,data[nx+2]);
    }	
      else if(!strcmp(data[nx],"n_itemrev"))
    {
      strcpy(itemrev,data[nx+1]);
      strcpy(dtype3,data[nx+2]);
    }	
  }

  status = MEMclose (&list);
  if (status != MEM_S_SUCCESS)
  {
    ERRload_struct (NFM, NFM_E_MEM, "", NULL); 
    _NFMdebug ((fname, "MEM Close : status = <0x%.8x>\n", status));
    return (NFM_E_MEM);
  }

  _NFMdebug ((fname, "SUCCESSFUL : status = <0x%.8x>\n",
  NFM_S_SUCCESS));
  return (NFM_S_SUCCESS);
}


long _NFMget_cat_fcat_no (cat_name)

char *cat_name;

{

  /***
  This function queriess n_tableno of catalog and fcatalog based on
  given catalog name, and it stores the information in NFMitem_ptr.

  ***/
  static char *fname = "_NFMget_cat_fcat_no" ;
  char   fcat_name[80];
  char   sql_str[300];
  MEMptr list = NULL;
  long   status;
  char   **data;
  int    x, index;

  _NFMdebug ((fname, "catalog name = %s ", cat_name));

  sprintf (fcat_name,"f_%s",cat_name);

  sprintf (sql_str, "SELECT %s FROM %s WHERE %s = '%s' OR %s = '%s'",
           "n_tablename, n_tableno", "nfmtables", "n_tablename",
           cat_name, "n_tablename", fcat_name);

  status = SQLquery (sql_str, &list, MEM_SIZE);
  if (status != SQL_S_SUCCESS)
  {
    MEMclose (&list);
    if (status == SQL_I_NO_ROWS_FOUND)
    {
      _NFMdebug ((fname, "SQLquery : status = <0x%.8x>", NFM_E_BAD_ATTR_VALUE));
      return (NFM_E_BAD_ATTR_VALUE);
    }
    _NFMdebug ((fname, "SQLquery : status = <0x%.8x>", status));
    return (NFM_E_SQL_QUERY);
  }

  status = MEMbuild_array (list);
  if (status != MEM_S_SUCCESS)
  {
    MEMclose (&list);
    _NFMdebug ((fname, "MEMbuild_array : status = <0x%.8x>", status));
    return (NFM_E_MEM);
  }

  data = (char **) list->data_ptr;

  for (x = 0; x < list->rows; x++)
  {
    index = x * list->columns;
    if (! strcmp (cat_name, data[index]))
      NFMitem_ptr->table_no = atoi (data[index+1]);
    else if (! strcmp (fcat_name, data[index]))
      NFMitem_ptr->ftable_no = atoi (data[index+1]);
  }
  status = MEMclose (&list);
  if (status != MEM_S_SUCCESS)
  {
    _NFMdebug ((fname, "MEMclose = <0x%.8x>", status));
    return (NFM_E_MEM);
  }

  _NFMdebug ((fname, "NFMitem_ptr->table_no = %d : NFMitem_ptr->ftable_no = %d : SUCCESSFUL\n",
	      NFMitem_ptr->table_no, NFMitem_ptr->ftable_no));
  return (NFM_S_SUCCESS);
}

long _NFMprepare_item_info (item_name, item_rev)

char *item_name, *item_rev;

{

  /***
  This function queries the n_name and n_datatype for n_itemname, n_itemrev,
  n_itemno, n_archivestate, n_coout, n_itemlock, n_versionlimit, n_itemnum,
  n_fileversion, n_cifilename, and n_fileclass,
  and it stores the information in NFMitem_ptr.

  ***/
  static char *fname = "_NFMprepare_item_info" ;
  char   sql_str[1024];
  MEMptr list = NULL;
  char   **data;
  long   status;
  int    x, index;

  _NFMdebug ((fname, "Item_name = %s : Item Rev = %s\n", 
	      item_name, item_rev));
  sprintf (sql_str,
           "SELECT %s FROM %s WHERE (%s = %d OR %s = %d) %s %s %s %s %s ",
           "n_name, n_datatype", "nfmattributes",
           "n_tableno", NFMitem_ptr->table_no,
           "n_tableno", NFMitem_ptr->ftable_no,
           "AND (n_name = 'n_itemno' OR n_name = 'n_itemname' ",
           "OR n_name = 'n_itemrev' OR n_name = 'n_archivestate' ",
           "OR n_name = 'n_itemlock' OR n_name = 'n_versionlimit' ",
           "OR n_name = 'n_itemnum' OR n_name = 'n_fileversion' ",
           "OR n_name = 'n_cifilename' ) " );
  status = SQLquery (sql_str, &list, MEM_SIZE);
  if (status != SQL_S_SUCCESS)
  {
    MEMclose (&list);
    if (status != SQL_I_NO_ROWS_FOUND)
    {
      _NFMdebug ((fname, "SQLquery : status = <0x%.8x> ",
		  NFM_E_BAD_ATTR_VALUE));
      return (NFM_E_BAD_ATTR_VALUE);
    }
    _NFMdebug ((fname, "SQLquery = <0x%.8x> ", status));
    return (NFM_E_SQL_QUERY);
  }

  status = MEMbuild_array (list);
  if (status != MEM_S_SUCCESS)
  {
    MEMclose (&list);
    _NFMdebug ((fname, "MEMbuild_array : status = <0x%.8x> ", status));
    return (NFM_E_MEM);
  }
  data = (char **) list->data_ptr;

  for (x = 0; x < list->rows; x++)
  {
    index = x * list->columns;
    if (! strcmp (data[index], "n_itemno"))
    {
      strcpy (NFMitem_ptr->cat_item.n_itemno.attr_name, data[index]);
      strcpy (NFMitem_ptr->cat_item.n_itemno.attr_dtype, data[index+1]);
    }
    else if (! strcmp (data[index], "n_itemname"))
    {
      strcpy (NFMitem_ptr->cat_item.n_itemname.attr_name, data[index]);
      strcpy (NFMitem_ptr->cat_item.n_itemname.attr_dtype, data[index+1]);
    }
    else if (! strcmp (data[index], "n_itemrev"))
    {
      strcpy (NFMitem_ptr->cat_item.n_itemrev.attr_name, data[index]);
      strcpy (NFMitem_ptr->cat_item.n_itemrev.attr_dtype, data[index+1]);
    }
    else if (! strcmp (data[index], "n_archivestate"))
    {
      strcpy (NFMitem_ptr->cat_item.n_archivestate.attr_name, data[index]);
      strcpy (NFMitem_ptr->cat_item.n_archivestate.attr_dtype, data[index+1]);
    }
    else if (! strcmp (data[index], "n_itemlock"))
    {
      strcpy (NFMitem_ptr->cat_item.n_itemlock.attr_name, data[index]);
      strcpy (NFMitem_ptr->cat_item.n_itemlock.attr_dtype, data[index+1]);
    }
    else if (! strcmp (data[index], "n_versionlimit"))
    {
      strcpy (NFMitem_ptr->cat_item.n_versionlimit.attr_name, data[index]);
      strcpy (NFMitem_ptr->cat_item.n_versionlimit.attr_dtype, data[index+1]);
    }
    else if (! strcmp (data[index], "n_itemnum"))
    {
      strcpy (NFMitem_ptr->fcat_item.n_itemnum.attr_name, data[index]);
      strcpy (NFMitem_ptr->fcat_item.n_itemnum.attr_dtype, data[index+1]);
    }
    else if (! strcmp (data[index], "n_fileversion"))
    {
      strcpy (NFMitem_ptr->fcat_item.n_fileversion.attr_name, data[index]);
      strcpy (NFMitem_ptr->fcat_item.n_fileversion.attr_dtype, data[index+1]);
    }
    else if (! strcmp (data[index], "n_cifilename"))
    {
      strcpy (NFMitem_ptr->fcat_item.n_cifilename.attr_name, data[index]);
      strcpy (NFMitem_ptr->fcat_item.n_cifilename.attr_dtype, data[index+1]);
    }
  }
   
  /* the following attributes are not allowed to be changed by applications */

  strcpy (NFMitem_ptr->cat_item.n_coout.attr_name, "n_status");
  strcpy (NFMitem_ptr->cat_item.n_coout.attr_dtype, "char(2)");
 
  strcpy (NFMitem_ptr->fcat_item.n_fileclass.attr_name, "n_fileclass");
  strcpy (NFMitem_ptr->fcat_item.n_fileclass.attr_dtype, "char(1)");
 
  status = MEMclose (&list);
  if (status != MEM_S_SUCCESS)
  {
    _NFMdebug ((fname, "MEMclose :  status = <0x%.8x> ", status));
    return (NFM_E_MEM);
  }

  /*
  _NFMprint_global_item_ptr ();
  */

  _NFMdebug ((fname, "status = <0x%.8x> ", NFM_S_SUCCESS));
  return (NFM_S_SUCCESS);

}


long _NFMprepare_item_values (cat_name, item_name, item_rev)

char *cat_name, *item_name, *item_rev;
{
  /***
  This function queries the values for n_itemno, n_itemlock, n_archivestate
  n_coout, and n_versionlimit  for the item,
  and stores the information in NFMitem_ptr.

  ***/
  static char *fname = "_NFMprepare_item_values" ;
  char   sql_str[300];
  char   sub_str[300];
  MEMptr list = NULL;
  char   **data;
  long   status;
 
  _NFMdebug ((fname, ": enter..."));

  if (! strncmp (NFMitem_ptr->cat_item.n_itemname.attr_dtype, "char", 4))
    sprintf (sub_str, "WHERE %s = '%s'",
                       NFMitem_ptr->cat_item.n_itemname.attr_name, item_name);
  else
    sprintf (sub_str, "WHERE %s = %s",
                       NFMitem_ptr->cat_item.n_itemname.attr_name, item_name);

  strcat (sub_str, " AND ");
  strcat (sub_str, NFMitem_ptr->cat_item.n_itemrev.attr_name);
  strcat (sub_str, " = ");

  if (! strncmp (NFMitem_ptr->cat_item.n_itemrev.attr_dtype, "char", 4))
  {
    strcat (sub_str, "'");
    strcat (sub_str, item_rev);
    strcat (sub_str, "'");
  }
  else
    strcat (sub_str, item_rev);
  sprintf (sql_str, "SELECT %s, %s, %s, %s, %s, %s FROM %s %s",
           NFMitem_ptr->cat_item.n_itemno.attr_name,
           NFMitem_ptr->cat_item.n_itemlock.attr_name,
           NFMitem_ptr->cat_item.n_archivestate.attr_name,
           NFMitem_ptr->cat_item.n_coout.attr_name,
           NFMitem_ptr->cat_item.n_versionlimit.attr_name,
           "n_pendingflag",     /* n_pendingflag is not expected to change */
           cat_name, sub_str);
  status = SQLquery (sql_str, &list, MEM_SIZE);
  if (status != SQL_S_SUCCESS)
  {
    MEMclose (&list);
    if (status != SQL_I_NO_ROWS_FOUND)
    {
      ERRload_struct (NFM, NFM_E_BAD_ATTR_VALUE, "", NULL);
      _NFMdebug ((fname, "SQLquery :status = <0x%.8x> ",
		  NFM_E_BAD_ATTR_VALUE));
      return (NFM_E_BAD_ATTR_VALUE);
    }
    ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
    _NFMdebug ((fname, "SQLquery : status = <0x%.8x> ", status));
    return (NFM_E_SQL_QUERY);
  }

  status = MEMbuild_array (list);
  if (status != MEM_S_SUCCESS)
  {
    MEMclose (&list);
    ERRload_struct (NFM, NFM_E_MEM, "", NULL);
    _NFMdebug ((fname, "MEMbuild_array : status = <0x%.8x> ", status));
    return (NFM_E_MEM);
  }
  data = (char **) list->data_ptr;

  if (strlen (data[0]))
  {
    NFMitem_ptr->cat_item.n_itemno.data_value = (char *)
                                                malloc (strlen (data[0])+1);
    strcpy (NFMitem_ptr->cat_item.n_itemno.data_value, data[0]);
    NFMitem_ptr->cat_item.n_itemno.data_count ++;
  }
  if (strlen (data[1]))
  {
    NFMitem_ptr->cat_item.n_itemlock.data_value = (char *)
                                                malloc (strlen (data[1])+1);
    strcpy (NFMitem_ptr->cat_item.n_itemlock.data_value, data[1]);
    NFMitem_ptr->cat_item.n_itemlock.data_count ++;
  }
  if (strlen (data[2]))
  {
    NFMitem_ptr->cat_item.n_archivestate.data_value = (char *)
                                                malloc (strlen (data[2])+1);
    strcpy (NFMitem_ptr->cat_item.n_archivestate.data_value, data[2]);
    NFMitem_ptr->cat_item.n_archivestate.data_count ++;
  }

  if (strlen (data[3]))
  {
    NFMitem_ptr->cat_item.n_coout.data_value = (char *) 
                                              malloc (strlen (data[3])+1);
    strcpy (NFMitem_ptr->cat_item.n_coout.data_value, data[3]);
    NFMitem_ptr->cat_item.n_coout.data_count ++;
  }

  if (strlen (data[4]))
  {
    NFMitem_ptr->cat_item.n_versionlimit.data_value = (char *) 
                                              malloc (strlen (data[4])+1);
    strcpy (NFMitem_ptr->cat_item.n_versionlimit.data_value, data[4]);
    NFMitem_ptr->cat_item.n_versionlimit.data_count ++;
  }

  if (strlen (data[5]))
  {
    NFMitem_ptr->cat_item.n_pendingflag.data_value = (char *) 
                                              malloc (strlen (data[4])+1);
    strcpy (NFMitem_ptr->cat_item.n_pendingflag.data_value, data[4]);
    NFMitem_ptr->cat_item.n_pendingflag.data_count ++;
  }

  status = MEMclose (&list);
  if (status != MEM_S_SUCCESS)
  {
    ERRload_struct (NFM, NFM_E_MEM, "", NULL);
    _NFMdebug ((fname, "MEMclose : status = <0x%.8x> ", status));
    return (NFM_E_MEM);
  }

  /*
  _NFMprint_global_item_ptr ();
  */
  _NFMdebug ((fname, ": exit, status = <0x%.8x> ", NFM_S_SUCCESS));
  return (NFM_S_SUCCESS);


}


long _NFMg_fileversion (cat_name)

char *cat_name;

{
  /***
  This function queries the MAX value for n_fileversion
  and stores the information in NFMitem_ptr.

  ***/
  static char *fname = "_NFMg_fileversion" ;
  char   sql_str[300];
  char   sub_str[300];
  MEMptr list = NULL;
  char   **data;
  long   status;

  _NFMdebug ((fname, ": enter ..."));

  if (! strncmp (NFMitem_ptr->fcat_item.n_itemnum.attr_dtype, "char", 4))
    sprintf (sub_str, "WHERE %s = '%s'",
                       NFMitem_ptr->fcat_item.n_itemnum.attr_name,
                       NFMitem_ptr->cat_item.n_itemno.data_value );
  else
    sprintf (sub_str, "WHERE %s = %s",
                       NFMitem_ptr->fcat_item.n_itemnum.attr_name,
                       NFMitem_ptr->cat_item.n_itemno.data_value );

  strcat (sub_str, " AND ");
  strcat (sub_str, NFMitem_ptr->fcat_item.n_fileclass.attr_name);
  strcat (sub_str, " = ");

  strcat (sub_str, "'C'");

  sprintf (sql_str, "SELECT MAX(%s) FROM f_%s %s",
                    NFMitem_ptr->fcat_item.n_fileversion.attr_name,
                    cat_name, sub_str);
  status = SQLquery (sql_str, &list, MEM_SIZE);
  if (status != SQL_S_SUCCESS)
  {
    MEMclose (&list);
    if (status != SQL_I_NO_ROWS_FOUND)
    {
      ERRload_struct(NFM, NFM_E_BAD_ATTR_VALUE, "", NULL);

      _NFMdebug ((fname, "SQLquery : status = <0x%.8x> ", NFM_E_BAD_ATTR_VALUE));
      return (NFM_E_BAD_ATTR_VALUE);
    }
    ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
    _NFMdebug ((fname, "SQLquery : status = <0x%.8x> ", status));
    return (NFM_E_SQL_QUERY);
  }
  status = MEMbuild_array (list);
  if (status != MEM_S_SUCCESS)
  {
    MEMclose (&list);
    ERRload_struct (NFM, NFM_E_MEM, "", NULL);
    _NFMdebug ((fname, "MEMbuild_array : status = <0x%.8x> ", status));
    return (NFM_E_MEM);
  }
  data = (char **) list->data_ptr;

  if (strlen (data[0])) /* this check should be unnecessary, just to be safe */
  {
    NFMitem_ptr->fcat_item.n_fileversion.data_value = (char *)
                                                      malloc (strlen (data[0])+1);
    strcpy (NFMitem_ptr->fcat_item.n_fileversion.data_value, data[0]);
    NFMitem_ptr->fcat_item.n_fileversion.data_count ++;
  }

  status = MEMclose (&list);
  if (status != MEM_S_SUCCESS)
  {
    ERRload_struct (NFM, NFM_E_MEM, "", NULL);
    _NFMdebug ((fname, "MEMclose : status = <0x%.8x> ", status));
    return (NFM_E_MEM);
  }
  _NFMdebug ((fname, ": exit, status = <0x%.8x> ", NFM_S_SUCCESS));
  return (NFM_S_SUCCESS);

}

