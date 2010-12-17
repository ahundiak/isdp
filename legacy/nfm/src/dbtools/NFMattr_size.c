#include "machine.h"
#include <stdio.h>
#include "NFMerrordef.h"
#include "MEMstruct.h"
#include "ERR.h"
#include "DEBUG.h"

 long NFMget_max_attr_size (user_id, name, data_type)
   long    user_id;
   char    *name;
   char    *data_type;
   {
     char *fname = "NFMget_max_attr_size" ;
      long    status;
      char    sql_str [1024], temp [20];
      MEMptr  list = NULL;
      char    **data;
      long    x, max_size, size;

      data_type [0] = 0;

      _NFMdebug ((fname, "Attr  Name = <%s>\n", name ));

      sprintf (sql_str, "%s %s (n_datatype) FROM %s WHERE %s = '%s'",
               "SELECT", "DISTINCT",
               "NFMATTRIBUTES", "n_name", name);

      status = SQLquery (sql_str, &list, MEM_SIZE);
      if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
       {
         MEMclose (&list);
	 ERRload_struct (NFM,  NFM_E_SQL_QUERY, "", NULL);
         _NFMdebug ((fname, "SQL Query Syntax : status = <0x%.8x>\n",
          NFM_E_SQL_QUERY));
         return ( NFM_E_SQL_QUERY);
       }

     if ((status) == SQL_I_NO_ROWS_FOUND)
       {
	 MEMclose (&list) ;

	 sprintf (sql_str, "%s %s (n_datatype) FROM %s WHERE %s = '%s'",
		  "SELECT", "DISTINCT",
		  "NFMSYSATTRIBUTES", "n_name", name);

	 status = SQLquery (sql_str, &list, MEM_SIZE);
	 if (status != SQL_S_SUCCESS) 
	   {
	     MEMclose (&list);
	     if (status == SQL_I_NO_ROWS_FOUND)
	       {
		 ERRload_struct (NFM, NFM_E_BAD_ATTRIBUTE, "", NULL);
		 _NFMdebug ((fname, "No Such Attr : status = <0x%.8x>\n",
			     NFM_E_BAD_ATTRIBUTE));
		 return (NFM_E_BAD_ATTRIBUTE);
	       }
	     ERRload_struct (NFM,  NFM_E_SQL_QUERY, "", NULL);
	     _NFMdebug ((fname, "SQL Query Syntax : status = <0x%.8x>\n",
			 NFM_E_SQL_QUERY));
	     return ( NFM_E_SQL_QUERY);
	   }
       }

      status = MEMbuild_array (list);
      if (status != MEM_S_SUCCESS)
       {
         MEMclose (&list);
           ERRload_struct (NFM, NFM_E_MEM, "", NULL);
         _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
         NFM_E_MEM));
         return (NFM_E_MEM);
       }

      data = (char **) list -> data_ptr;

      max_size = 0;

      for (x = 0; x < list -> rows; ++x)
       {
              if (! strcmp  (data [x], "integer"))   size = 15;
         else if (! strcmp  (data [x], "smallint"))  size = 15;
         else if (! strcmp  (data [x], "double"))    size = 50;
         else if (! strcmp  (data [x], "real"))      size = 50;
         else if (! strncmp (data [x], "char", 4))
          {
             sscanf (data [x], "%5s%d", temp, &size);
          }
  
         if (max_size < size)  max_size = size;
       }

      status = MEMclose (&list);
      if (status != MEM_S_SUCCESS)
       {
           ERRload_struct (NFM, NFM_E_MEM, "", NULL);
         _NFMdebug ((fname, "MEM Close : status = <0x%.8x>\n", NFM_E_MEM));
         return (NFM_E_MEM);
       }

      sprintf (data_type, "char(%d)", max_size);
      
      _NFMdebug ((fname, "SUCCESSFUL : datatype %s\n", data_type)) ;
      return (NFM_S_SUCCESS);
   }




