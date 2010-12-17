#include "machine.h"
#include "NFMA.h"

  extern struct NFMglobal_st NFMglobal ;

 long NFMquery_project_members (user_id, project_name, attr_list, data_list)
   long     user_id;
   char     *project_name;
   MEMptr   *attr_list, *data_list;
   {
      char *fname="NFMquery_project_members";
      long     status;

      _NFMdebug ((fname,"Project Name = <%s> ", project_name ));
      user_id = user_id ;

      status = _NFMquery_project_members (NFMglobal.NFMuserid, project_name, 
					  attr_list, data_list) ;
      if (status != NFM_S_SUCCESS)
	{
	  _NFMdebug ((fname, "_NFMquery_project_members failed : status = <0x%.8x>\n",
		      status)) ;
	  return (status) ;
	}

      _NFMdebug ((fname, "SUCCESSFUL\n")) ;
      return (NFM_S_SUCCESS) ;
    }


 long NFMquery_changeto_lop_attributes (user_id, proj_name, 
                                        attr_list, data_list, value_list)
   long     user_id;
   char     *proj_name;
   MEMptr   *attr_list, *data_list, *value_list;
   {
     static char *fname = "NFMquery_changeto_lop_attributes" ;
     long     status;
     char     *sql_str, sql_str1 [1024];
     char     **column, **data;
     char     lop_name [NFM_TABLENAME+1] ;
     long     x, y, count, a, b ;

     sprintf (lop_name, "%s", "NFMPROJECTS");

     _NFMdebug ((fname, "Proj Name  = <%s>\n", proj_name)) ;

     status = NFMquery_table_attributes (user_id, "NFMSYSTEM", lop_name,
              attr_list, data_list, value_list);
     if (status != NFM_S_SUCCESS)
      {
        MEMclose (attr_list);
        MEMclose (data_list);
        MEMclose (value_list);
        _NFMdebug ((fname, "Tab Attr : status = <0x%.8x>\n", status));
        return (status);          
      }

     status = MEMclose (data_list);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (attr_list);
        MEMclose (value_list);
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Close : status = <0x%.8x>\n", status)) ;
        return (NFM_E_MEM);           
      }
      *data_list = NULL;

     status = MEMbuild_array (*attr_list);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (attr_list);
        MEMclose (value_list);
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
		    status));
        return (NFM_E_MEM);                     
      }

     column = (char **) (*attr_list) -> column_ptr;
     data   = (char **) (*attr_list) -> data_ptr;

     a = -1 ; b = -1 ;
     for (y = 0; y < (*attr_list) -> columns; ++y)
      {
             if (! strcmp (column [y], "n_name"))      a = y;
        else if (! strcmp (column [y], "n_datatype"))  b = y;
      }

     sql_str = (char *) malloc (2 * MEM_SIZE + (*attr_list) -> rows * 50);
     if (! sql_str)
      {
        MEMclose (attr_list);
        MEMclose (value_list);
        ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
        _NFMdebug ((fname, "Malloc Failed : status = <0x%.8x>\n",
		    NFM_E_MALLOC)) ;
        return (NFM_E_MALLOC);           
      }
     sql_str [0] = 0;

     sprintf (sql_str,  "SELECT ");
     sprintf (sql_str1, " FROM %s WHERE ", lop_name);

     for (x = 0; x < (*attr_list) -> rows; ++x)
      {
        count = (*attr_list) -> columns * x;

        if (x) strcat (sql_str, ", ");

        strcat (sql_str, data [count + a]);

        if (! strcmp (data[count + a], "n_projectname"))
        {
           strcat (sql_str1, data[count + a]);
           strcat (sql_str1, " = ");

           if ((! strncmp (data[count + b], "char", 4)) ||
               (! strncmp (data[count + b], "date", 4)))
            {
               strcat (sql_str1, "'");
               strcat (sql_str1, proj_name);
               strcat (sql_str1, "'");
            }
            else
               strcat (sql_str1, proj_name);
        }
      }

     strcat (sql_str, sql_str1);

     status = SQLquery (sql_str, data_list, MEM_SIZE);
     if (status != SQL_S_SUCCESS)
      {
        free (sql_str);
        MEMclose (attr_list);
        MEMclose (data_list);
        MEMclose (value_list);

        if ((status) == SQL_I_NO_ROWS_FOUND)
         {
        ERRload_struct (NFM, NFM_E_PROJ_NOT_IN_LOP, "", NULL);
           _NFMdebug ((fname, "No Such Lop Entry : status = <0x%.8x>\n",
           NFM_E_PROJ_NOT_IN_LOP));
           return (NFM_E_PROJ_NOT_IN_LOP);           
         }

        ERRload_struct (NFM,  NFM_E_SQL_QUERY, "", NULL);
        _NFMdebug ((fname, "SQL Query Failed : status = <0x%.8x>\n",
		    status));
        return ( NFM_E_SQL_QUERY);           
      }

     free (sql_str);

     status = MEMbuild_array (*data_list);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (attr_list);
        MEMclose (data_list);
        MEMclose (value_list);
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n", status));
        return (NFM_E_MEM);           
      }

     sql_str = (char *) malloc ((*data_list) -> row_size);
     if (! sql_str)
      {
        MEMclose (attr_list);
        MEMclose (data_list);
        MEMclose (value_list);
        ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
        _NFMdebug ((fname, "Malloc Failed : status = <0x%.8x>\n", NFM_E_MALLOC));
        _NFMdebug ((fname, "*(data_list)->row_size = <%d>\n", 
                  (*data_list)->row_size));
        return (NFM_E_MALLOC);           
      }
     sql_str [0] = 0;

     data = (char **) (*data_list) -> data_ptr;

     for (y = 0; y < (*data_list) -> columns; ++y)
      {
        strcat (sql_str, data [y]);
        strcat (sql_str, "\1");
      }

     status = MEMwrite (*data_list, sql_str);
     if (status != MEM_S_SUCCESS)
      {
        free (sql_str);
        MEMclose (attr_list);
        MEMclose (data_list);
        MEMclose (value_list);
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEMwrite : status = <0x%.8x>\n", status));
        return (NFM_E_MEM);           
      }

     free (sql_str);

     _NFMdebug ((fname, "SUCCESSFUL\n"));
     return (NFM_S_SUCCESS);
   }



