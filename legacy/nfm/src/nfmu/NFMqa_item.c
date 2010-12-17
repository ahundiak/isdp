#include "machine.h"
#include "NFMU.h"
#include "WFstruct.h"

 extern struct WFstruct WFinfo;
 extern struct NFMglobal_st NFMglobal ;

 long NFMquery_add_item_attributes (user_id, cat_name,
				    attr_list, data_list, value_list)
   long     user_id ;
   char     *cat_name;
   MEMptr   *attr_list, *data_list, *value_list;
   {
     static char *fname = "NFMquery_add_item_attributes" ;
     long     status;
     char     user_name [50];
     char     acl_no [50], sa_no [50];
     char     date [50] ;
     char     **data, **column ;
     int      x,y,c,d,count ;
     long     _NFMget_cat_acl_list ();
     long     _NFMget_cat_internal_sa_list ();
     long     _NFMget_proj_acl_list ();
     long     _NFMget_proj_sa_list ();
     long     _NFMquery_catalog_attributes () ;
     long     cat_no, proj_no, no_buffers ;
     MEMptr   list = NULL ;

     _NFMdebug ((fname, "ENTER : Cat  Name = <%s>\n", cat_name )) ;
     user_id = user_id ;
     status = NFMget_catalog_no (NFMglobal.NFMuserid, cat_name, &cat_no) ;
     if (status != NFM_S_SUCCESS)
       {
	 _NFMdebug ((fname, "Bad Catalog No for %s : status = <0x%.8x>\n",
		     cat_name, status)) ;
	 return (status) ;
       }

     status = _NFMquery_catalog_attributes_w (cat_name,
					      attr_list, data_list, 
					      value_list);
     if (status != NFM_S_SUCCESS)
      {
        MEMclose (attr_list);
        MEMclose (data_list);
        MEMclose (value_list);
        _NFMdebug ((fname, "Query Cat Attr : status = <0x%.8x>\n",
        status));
        return (status);          
      }

     strcpy (user_name, NFMglobal.NFMusername) ;


     status = NFMget_datetime (date) ;
     if (status != NFM_S_SUCCESS)
       {
	 _NFMdebug ((fname, "Ris time stamp failed : status = <0x%x.8>\n",
		     status)) ;
	 return (status) ;
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

     status = MEMbuild_array (*data_list);
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

     c = -1; d = -1;

     for (y = 0; y < (*attr_list) -> columns; ++y)
      {
              if (! strcmp (column [y], "n_name"))      c = y;
         else if (! strcmp (column [y], "n_valueno"))       d = y;
      }

     status = WFget_active_proj_no (&proj_no) ;
     if (proj_no  > 0)
      {
        status = _NFMget_proj_acl_list (NFMglobal.NFMuserno, cat_no, proj_no,
					&list);
        if ((status != NFM_S_SUCCESS) || (list -> rows < 1))
         {
           MEMclose (attr_list);
           MEMclose (data_list);
           MEMclose (value_list);
	   if ((status == NFM_S_SUCCESS) && (list -> rows < 1))
	     {
	       MEMclose (&list);
	       /* User is not allowed to add items to this project */
	       _NFMdebug ((fname, "No Acls Available for Active Project\n")) ;
	       ERRload_struct (NFM, NFM_E_NOT_ADD_ITEM_TO_PROJECT, "", "");
	       return (NFM_E_NOT_ADD_ITEM_TO_PROJECT) ;
	     }
           MEMclose (&list);
           _NFMdebug ((fname, "Proj Acl List : status = <0x%.8x>\n",
		       status));
           return (status);          
         }
      }
     else
      {
        status = _NFMget_cat_acl_list (NFMglobal.NFMuserno, cat_no, &list);
        if ((status != NFM_S_SUCCESS) || (list -> rows < 1))
         {
           MEMclose (attr_list);
           MEMclose (data_list);
           MEMclose (value_list);
	   if ((status == NFM_S_SUCCESS) && (list -> rows < 1))
	     {
	       MEMclose (&list);
	       _NFMdebug ((fname, "No Acls Available for New Item\n")) ;
	       ERRload_struct (NFM, NFM_E_BAD_ACL, "", "") ;
	       return (NFM_E_BAD_ACL) ;
	     }
           MEMclose (&list);
           _NFMdebug ((fname, "Cat Acl List : status = <0x%.8x>\n",
           status));
           return (status);          
         }
      }

     if (*value_list)
      {
        status = MEMappend (list, *value_list);
        if (status != MEM_S_SUCCESS)
         {
           MEMclose (&list);
           MEMclose (attr_list);
           MEMclose (data_list);
           MEMclose (value_list);
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
           _NFMdebug ((fname, "MEM Append : status = <0x%.8x>\n",
		       status));
           return (NFM_E_MEM);          
         }
      }
     else
      {
        status = MEMsplit_copy_buffer (list, value_list, 0);
        if (status != MEM_S_SUCCESS)
         {
           MEMclose (&list);
           MEMclose (attr_list);
           MEMclose (data_list);
           MEMclose (value_list);
	   ERRload_struct (NFM, NFM_E_MEM, "", NULL);
           _NFMdebug ((fname, "MEM Copy : status = <0x%.8x>\n",
		       status));
           return (NFM_E_MEM);          
         }
      }
 
     status = MEMclose (&list);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (attr_list);
        MEMclose (data_list);
        MEMclose (value_list);
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Close : status = <0x%.8x>\n", status));
        return (NFM_E_MEM);          
      }

     MEMno_buffers (*value_list, &no_buffers );
     sprintf (acl_no, "%d", no_buffers );

     if (proj_no > 0)
      {
        status = _NFMget_proj_sa_list (cat_no, proj_no, &list);
        if (status != NFM_S_SUCCESS)
         {
           MEMclose (&list);
           MEMclose (attr_list);
           MEMclose (data_list);
           MEMclose (value_list);
           _NFMdebug ((fname, "Proj Ci Sa List : status = <0x%.8x>\n",
           status));
           return (status);          
         }
      }
     else
      {
        status = _NFMget_cat_internal_sa_list (cat_no, &list);
        if (status != NFM_S_SUCCESS)
         {
           MEMclose (&list);
           MEMclose (attr_list);
           MEMclose (data_list);
           MEMclose (value_list);
           _NFMdebug ((fname, "Cat Ci Sa List : status = <0x%.8x>\n",
           status));
           return (status);          
         }
      }

     if (list -> rows < 1)
      {
        MEMclose (&list);
        MEMclose (attr_list);
        MEMclose (data_list);
        MEMclose (value_list);
        ERRload_struct (NFM, NFM_E_CATALOG_ACCESS, "", NULL);
        _NFMdebug ((fname, "User Can't Add Item In Cat : status = <0x%.8x>\n",
        NFM_E_CATALOG_ACCESS));
        return (NFM_E_CATALOG_ACCESS);          
      }

     if (*value_list)
      {
        status = MEMappend (list, *value_list);
        if (status != MEM_S_SUCCESS)
         {
           MEMclose (&list);
           MEMclose (attr_list);
           MEMclose (data_list);
           MEMclose (value_list);
	   ERRload_struct (NFM, NFM_E_MEM, "", NULL);
           _NFMdebug ((fname, "MEM Append : status = <0x%.8x>\n",
		       status));
           return (NFM_E_MEM);          
         }
      }
     else
      {
        status = MEMsplit_copy_buffer (list, value_list, 0);
        if (status != MEM_S_SUCCESS)
         {
           MEMclose (&list);
           MEMclose (attr_list);
           MEMclose (data_list);
           MEMclose (value_list);
	   ERRload_struct (NFM, NFM_E_MEM, "", NULL);
           _NFMdebug ((fname, "MEM Copy : status = <0x%.8x>\n",
		       status));
           return (NFM_E_MEM);          
         }
      }
 
     status = MEMclose (&list);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (attr_list);
        MEMclose (data_list);
        MEMclose (value_list);
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Close : status = <0x%.8x>\n", status));
        return (NFM_E_MEM);          
      }
     MEMno_buffers (*value_list, &no_buffers );
     sprintf (sa_no, "%d", no_buffers );

     for (x = 0; x < (*attr_list) -> rows; ++x)
      {
        count = (*attr_list) -> columns * x;
         
        if (! strcmp (data [count + c], "n_itemlock"))
         {
           status = MEMwrite_data (*data_list, "N", 1, x + 1);
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
        else if (! strcmp (data [count + c], "n_creator"))
         {
           status = MEMwrite_data (*data_list, user_name, 1, x + 1);
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
        else if (! strcmp (data [count + c], "n_creationdate"))
         {
           status = MEMwrite_data (*data_list, date, 1, x + 1);
           if (status != MEM_S_SUCCESS)
            {
              MEMclose (attr_list);
              MEMclose (data_list);
              MEMclose (value_list);         
              _NFMdebug ((fname, "MEM Wr Data : status = <0x%.8x>\n",
              status));
              return (status);          
            }
         }
        else if (! strcmp (data [count + c], "n_aclno"))
         {
           status = MEMwrite_data (*attr_list, acl_no, x + 1, d + 1);
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
        else if (! strcmp (data [count + c], "n_cisano"))
         {
           status = MEMwrite_data (*attr_list, sa_no, x + 1, d + 1);
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

long NFMquery_add_set_attributes (user_id, cat_name,
				  attr_list, data_list, value_list)
   long     user_id;
   char     *cat_name;
   MEMptr   *attr_list, *data_list, *value_list;
{
     static char *fname = "NFMquery_add_set_attributes" ;
     long     status;
     long     c, d, x, y, count;
     long	  no_buffers;
     char     **column, **data;
     MEMptr   list = NULL;
     char     value [50], user_name [50];
     char     acl_no [50], sa_no [50];
     char     date [50], time [50];
     long     NFMget_cat_acl_list ();
     long     NFMget_cat_sa_list ();
     long     NFMget_proj_acl_list ();
     long     NFMget_proj_sa_list ();

     _NFMdebug ((fname, "Cat  Name = <%s>\n", cat_name ));

     status = NFMquery_catalog_attributes (user_id, cat_name, 
              attr_list, data_list, value_list);
     if (status != NFM_S_SUCCESS)
      {
        MEMclose (attr_list);
        MEMclose (data_list);
        MEMclose (value_list);
        _NFMdebug ((fname, "Query Cat Attr : status = <0x%.8x>\n",
        status));
        return (status);          
      }

     strcpy (user_name, NFMglobal.NFMusername) ;

     status = NFMget_datetime (date) ;
     if (status != NFM_S_SUCCESS)
      {
        MEMclose (attr_list);
        MEMclose (data_list);
        MEMclose (value_list);
        _NFMdebug ((fname, "Get Date Time : status = <0x%.8x>\n",
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

     status = MEMbuild_array (*data_list);
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

     c = -1; d = -1;
     
     for (y = 0; y < (*attr_list) -> columns; ++y)
       {
	 if (! strcmp (column [y], "n_name"))      c = y;
         else if (! strcmp (column [y], "n_valueno"))       d = y;
       }

     if (WFinfo.proj_no > 0)
      {
        status = NFMget_proj_acl_list (user_id, cat_name, &list);
        if (status != NFM_S_SUCCESS)
         {
           MEMclose (&list);
           MEMclose (attr_list);
           MEMclose (data_list);
           MEMclose (value_list);
           _NFMdebug ((fname, "Proj Acl List : status = <0x%.8x>\n",
           status));
           return (status);          
         }
      }
     else
      {
        status = NFMget_cat_acl_list (user_id, cat_name, &list);
        if (status != NFM_S_SUCCESS)
         {
           MEMclose (&list);
           MEMclose (attr_list);
           MEMclose (data_list);
           MEMclose (value_list);
           _NFMdebug ((fname, "Cat Acl List : status = <0x%.8x>\n",
           status));
           return (status);          
         }
      }

     if (list -> rows < 1)
      {
        MEMclose (&list);
        MEMclose (attr_list);
        MEMclose (data_list);
        MEMclose (value_list);
        ERRload_struct (NFM, NFM_E_CATALOG_ACCESS, "", NULL);
        _NFMdebug ((fname, "User Can't Add Item In Cat : status = <0x%.8x>\n",
        NFM_E_CATALOG_ACCESS));
        return (NFM_E_CATALOG_ACCESS);          
      }

     if (*value_list)
      {
        status = MEMappend (list, *value_list);
        if (status != MEM_S_SUCCESS)
         {
           MEMclose (&list);
           MEMclose (attr_list);
           MEMclose (data_list);
           MEMclose (value_list);
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
           _NFMdebug ((fname, "MEM Append : status = <0x%.8x>\n",
		       status));
           return (NFM_E_MEM);          
         }
      }
     else
      {
        status = MEMsplit_copy_buffer (list, value_list, 0);
        if (status != MEM_S_SUCCESS)
         {
           MEMclose (&list);
           MEMclose (attr_list);
           MEMclose (data_list);
           MEMclose (value_list);
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
           _NFMdebug ((fname, "MEM Copy : status = <0x%.8x>\n",
		       status));
           return (NFM_E_MEM);          
         }
      }
 
     status = MEMclose (&list);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (attr_list);
        MEMclose (data_list);
        MEMclose (value_list);
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Close : status = <0x%.8x>\n", status));
        return (NFM_E_MEM);          
      }

     MEMno_buffers (*value_list, &no_buffers);
     sprintf (acl_no, "%d", no_buffers);

     if (WFinfo.proj_no > 0)
      {
        status = NFMget_proj_sa_list (user_id, cat_name, &list);
        if (status != NFM_S_SUCCESS)
         {
           MEMclose (&list);
           MEMclose (attr_list);
           MEMclose (data_list);
           MEMclose (value_list);
           _NFMdebug ((fname, "Proj Ci Sa List : status = <0x%.8x>\n",
           status));
           return (status);          
         }
      }
     else
      {
        status = NFMget_cat_sa_list (user_id, cat_name, &list);
        if (status != NFM_S_SUCCESS)
         {
           MEMclose (&list);
           MEMclose (attr_list);
           MEMclose (data_list);
           MEMclose (value_list);
           _NFMdebug ((fname, "Cat Ci Sa List : status = <0x%.8x>\n",
           status));
           return (status);          
         }
      }


     if (list -> rows < 1)
      {
        MEMclose (&list);
        MEMclose (attr_list);
        MEMclose (data_list);
        MEMclose (value_list);
        ERRload_struct (NFM, NFM_E_CATALOG_ACCESS, "", NULL);
        _NFMdebug ((fname, "User Can't Add Item In Cat : status = <0x%.8x>\n",
        NFM_E_CATALOG_ACCESS));
        return (NFM_E_CATALOG_ACCESS);          
      }

     if (*value_list)
      {
        status = MEMappend (list, *value_list);
        if (status != MEM_S_SUCCESS)
         {
           MEMclose (&list);
           MEMclose (attr_list);
           MEMclose (data_list);
           MEMclose (value_list);
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
           _NFMdebug ((fname, "MEM Append : status = <0x%.8x>\n",
		       status));
           return (NFM_E_MEM);          
         }
      }
     else
      {
        status = MEMsplit_copy_buffer (list, value_list, 0);
        if (status != MEM_S_SUCCESS)
         {
           MEMclose (&list);
           MEMclose (attr_list);
           MEMclose (data_list);
           MEMclose (value_list);
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
           _NFMdebug ((fname, "MEM Copy : status = <0x%.8x>\n",
		       status));
           return (NFM_E_MEM);          
         }
      }
 
     status = MEMclose (&list);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (attr_list);
        MEMclose (data_list);
        MEMclose (value_list);
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Close : status = <0x%.8x>\n", status));
        return (NFM_E_MEM);          
      }

     MEMno_buffers (*value_list, &no_buffers);
     sprintf (sa_no, "%d", no_buffers );

     for (x = 0; x < (*attr_list) -> rows; ++x)
       {
	 count = (*attr_list) -> columns * x;
         
	 if (! strcmp (data [count + c], "n_itemlock"))
	   {
	     status = MEMwrite_data (*data_list, "N", 1, x + 1);
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
        else if (! strcmp (data [count + c], "n_setindicator"))
         {
           status = MEMwrite_data (*data_list, "Y", 1, x + 1);
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
        else if (! strcmp (data [count + c], "n_creator"))
         {
           status = MEMwrite_data (*data_list, user_name, 1, x + 1);
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
        else if (! strcmp (data [count + c], "n_creationdate"))
         {
           status = MEMwrite_data (*data_list, date, 1, x + 1);
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
        else if (! strcmp (data [count + c], "n_creationtime"))
         {
           status = MEMwrite_data (*data_list, time, 1, x + 1);
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
        else if (! strcmp (data [count + c], "n_stateno"))
         {
           sprintf (value, "%d", WFinfo.next_state);

           status = MEMwrite_data (*data_list, value, 1, x + 1);
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
        else if (! strcmp (data [count + c], "n_aclno"))
         {
           status = MEMwrite_data (*attr_list, acl_no, x + 1, d + 1);
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
        else if (! strcmp (data [count + c], "n_cisano"))
         {
           status = MEMwrite_data (*attr_list, sa_no, x + 1, d + 1);
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
