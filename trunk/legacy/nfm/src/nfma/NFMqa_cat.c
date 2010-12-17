#include "machine.h"
#include "NFMA.h"

 long NFMquery_catalog_template_n (attr_list,
				   data_list, value_list,
				   application_list) 
   MEMptr   *attr_list, *data_list, *value_list;
   MEMptr   application_list ;
   {
     static char *fname = "NFMquery_catalog_template_n" ;
     long   status;
     char     **data, **column;
     long     a, b, c, x, y, count;
     long     _NFMquery_template_attributes () ;

     _NFMdebug ((fname, "ENTER\n")) ;

     status = _NFMquery_template_attributes   (attr_list, data_list, 
					       value_list,
					       application_list);
     if (status != NFM_S_SUCCESS)
      {
        MEMclose (attr_list);
        MEMclose (data_list);
        MEMclose (value_list);
        _NFMdebug ((fname, "Cond Tab Attr : status = <0x%.8x>\n",
        status));
        return (status);          
      }

     status = MEMbuild_array (*attr_list);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (attr_list);
        MEMclose (data_list);
        MEMclose (value_list);
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
		    status));
        return (NFM_E_MEM);
      }
 
     column = (char **) (*attr_list) -> column_ptr;
     data   = (char **) (*attr_list) -> data_ptr;
  
     a = -1; b = -1; c = -1;

     for (y = 0; y < (*attr_list) -> columns; ++y)
      {
             if (! strcmp (column [y], "n_valueno"))     a = y;
/*        else if (! strcmp (column [y], "n_adviceno"))    b = y; */
        else if (! strcmp (column [y], "n_name"))        c = y;
     }
      
     for (x = 0; x < (*attr_list) -> rows; ++x)
      {
         count = (*attr_list) -> columns * x;

         if ((! strcmp (data [count + c], "n_aclno"))   ||
             (! strcmp (data [count + c], "n_cisano")))
          {
/* disable value list */
            status = MEMwrite_data (*attr_list, "-1", x + 1, a + 1);
            if (status != MEM_S_SUCCESS)
             {
               MEMclose (attr_list);
               MEMclose (data_list);
               MEMclose (value_list);
               ERRload_struct (NFM, NFM_E_MEM, "", NULL);
               _NFMdebug ((fname, "MEM Wr Data : status = <0x%.8x>\n",
			   status));
               return (NFM_E_MEM);
             }
          }
      }

     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);     
   }

 long _NFMquery_template_attributes (attr_list, data_list, value_list,
				     application_list)
   MEMptr   *attr_list, *data_list, *value_list, application_list ;
   {
     static char *fname = "_NFMquery_template_attributes" ;
     long     status;
     long     _NFMget_data_info ();
     long     _NFMget_table_attr_for_appl () ;

     _NFMdebug ((fname, "ENTER\n")) ;

     status = _NFMget_table_attr_for_appl (attr_list, application_list) ;
     if (status != NFM_S_SUCCESS)
       {
	 _NFMdebug ((fname, "get table attr for application failed : status = <0x%.8x>\n",
		     status)) ;
	 return (status) ;
       }

     status = _NFMget_data_info (*attr_list, data_list, value_list);
     if (status != NFM_S_SUCCESS)
      {
        MEMclose (attr_list);
        MEMclose (data_list);
        MEMclose (value_list);
        _NFMdebug ((fname, "Get Data Values : status = <0x%.8x>\n",
        status));
        return (status);          
      }

     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);
   }

 long NFMquery_catalog_template (user_id, attr_list,
                                 data_list, value_list)
   long     user_id;
   MEMptr   *attr_list, *data_list, *value_list;
   {
     static char *fname = "NFMquery_catalog_template" ;
     long   status;
     char   str [100] ;
     MEMptr application = NULL ;

     _NFMdebug ((fname, "ENTER\n")) ;
     user_id = user_id ;
    status = MEMopen (&application, MEM_SIZE);
    if (status != MEM_S_SUCCESS)
      {
        MEMclose (&application);
        _NFMdebug ((fname, "MEMopen : <0x%.8x>",status));
	ERRload_struct (NFM, NFM_E_MEM, "", "") ;
        return (status);
      }

    status = MEMwrite_format (application, "n_type", "char(20)");
    if (status != MEM_S_SUCCESS)
      {
        MEMclose (&application);
	_NFMdebug ((fname, "MEMwrite_format : status = <0x%.8x>\n",
		    status));
	ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	return (NFM_E_MEM) ;
      }

    status = MEMwrite_format (application, "value", "char(20)");
    if (status != MEM_S_SUCCESS)
      {
        MEMclose (&application);
	_NFMdebug ((fname, "MEMwrite_format : status = <0x%.8x>\n",
		    status));
	ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	return (NFM_E_MEM) ;
      }

    strcpy (str, "t_basic\001NFM\001") ;
    status = MEMwrite (application, str);
    if (status != MEM_S_SUCCESS)
      {
        MEMclose (&application);
	_NFMdebug ((fname, "MEMwrite_format : status = <0x%.8x>\n",
		    status));
	ERRload_struct (NFM, NFM_E_MEM, "", "") ;
        return (NFM_E_MEM) ;
      }

     status = NFMquery_catalog_template_n (attr_list,
					  data_list, value_list,
					  application)  ;
     if (status != NFM_S_SUCCESS)
       {
	 MEMclose (&application) ;
	 _NFMdebug ((fname, "Qry Cat Attr : status  = < 0x%.8x >\n",
		     status));
	 return (status);     
       }

     status = MEMclose (&application) ;
     if (status != MEM_S_SUCCESS)
       {
	 _NFMdebug ((fname, "MEMclose : status = <0x%.8x>\n", status)) ;
	 ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	 return (NFM_E_MEM) ;
       }

     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);     
   }



