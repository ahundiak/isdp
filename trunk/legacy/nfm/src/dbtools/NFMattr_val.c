#include "machine.h"
#include "DBTOOLS.h"
  
  long NFMget_attr_value (user_id, cat_name, attr, cond_str, value)
long     user_id;
char     *cat_name, *attr, *cond_str;
char     *value;
{
  char *fname = "NFMget_attr_value" ;
  long    status;
  char    sql_str [1024];
  MEMptr  list = NULL;
  char    **data;
  
  value [0] = 0;
  
  _NFMdebug ((fname, "Cat  Name  = <%s>  : Attr = <%s> : Cond Str = <%s>\n",
	      cat_name, attr, cond_str)) ;
  user_id = user_id ;
  
  sprintf (sql_str, "SELECT %s FROM %s %s", attr, cat_name, cond_str);
  
  status = SQLquery (sql_str, &list, MEM_SIZE);
  if (status != SQL_S_SUCCESS)
    {
      MEMclose (&list);
      
      if ((status ) == SQL_I_NO_ROWS_FOUND)
	{
	  _NFMdebug ((fname, "Attr Has No Value : status = <0x%.8x>\n",
		      NFM_I_BAD_CONDITION));
	  return (NFM_I_BAD_CONDITION);
	}
      
      ERRload_struct (NFM, NFM_E_SQL_QUERY, "",NULL);
      _NFMdebug ((fname, "Query Syntax : status = <0x%.8x>\n", 
		  status));
      return (NFM_E_SQL_QUERY);
    }
  
  status = MEMbuild_array (list);
  if (status != MEM_S_SUCCESS)
    {
      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
      _NFMdebug ((fname, "MEMBuild Array : status = <0x%.8x>\n", status));
      return (NFM_E_MEM);
    }
  
  data = (char **) list -> data_ptr;
  
  sprintf (value, data [0]);
  
  MEMclose (&list);
  
  _NFMdebug ((fname, "SUCCESSFUL : Value = <%s>\n", value));
  return (NFM_S_SUCCESS);
}
