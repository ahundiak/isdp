#include "machine.h"
#include "NFMA.h"

  extern struct NFMglobal_st NFMglobal ;

 long NFMquery_add_st_area_attributes (user_id, attr_list, 
                                       data_list, value_list)
   long    user_id;
   MEMptr  *attr_list, *data_list, *value_list;
   {
     static char *fname = "NFMquery_add_st_area_attributes" ;
     long     status, column_of_valueno, row_of_nodeno, a, row_of_owner ;
     long     count, y, x ;
     char     **column, **data, sql_str1 [512] ;

     _NFMdebug ((fname, "ENTER\n")) ;

      status = NFMquery_table_attributes_value2 (user_id, "NFMSYSTEM",
						 "NFMSTORAGEAREA", attr_list, 
						 data_list, value_list);
      if (status != NFM_S_SUCCESS)
       {
         MEMclose (attr_list);
         MEMclose (attr_list);
         MEMclose (attr_list);
         _NFMdebug ((fname, "Qry Cond Attr : status = <0x%.8x>\n", status));
         return (status);
       }

     status = MEMbuild_array (*attr_list);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (attr_list);
        MEMclose (data_list);
        MEMclose (value_list);
        ERRload_struct(NFM,status,"",NULL);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
        status));
        return (NFM_E_MEM) ;
      }

     column = (char **) (*attr_list) -> column_ptr;
     data   = (char **) (*attr_list) -> data_ptr;

     a = -1; column_of_valueno = -1 ;

     for (y = 0; y < (*attr_list) -> columns; ++y)
      {
             if (! strcmp (column [y], "n_name"))        a = y;
        else if (! strcmp (column [y], "n_valueno")) column_of_valueno = y+1 ;
      }

     row_of_nodeno = -1 ; row_of_owner = -1;

     for (x = 0; x < (*attr_list) -> rows; ++x)
      {
         count = (*attr_list) -> columns * x;

         if (! strcmp (data [count + a], "n_nodeno"))
	   {
	     row_of_nodeno = x +1 ;
	   }
         else if (! strcmp (data [count + a], "n_owner"))
	   {
	     row_of_owner = x + 1 ;
	   }
       }  

     strcpy (sql_str1, 
	     "select n_nodeno, n_nodename, n_nodedesc from nfmnodes order by n_nodeno") ;

     status = _NFMadd_to_value_list_from_query (attr_list,
                                                value_list,
                                                sql_str1,
                                                row_of_nodeno,
                                                column_of_valueno) ;
     if (status != NFM_S_SUCCESS)
       {
         _NFMdebug ((fname, "Corrupted value buffer : status = <0x%.8x>\n",
                     status)) ;
         return (status) ;
       }

     strcpy (sql_str1, 
	     "select n_userno, n_username from nfmusers order by n_userno") ;

     status = _NFMadd_to_value_list_from_query (attr_list,
                                                value_list,
                                                sql_str1,
                                                row_of_owner,
                                                column_of_valueno) ;
     if (status != NFM_S_SUCCESS)
       {
         _NFMdebug ((fname, "Corrupted value buffer : status = <0x%.8x>\n",
                     status)) ;
         return (status) ;
       }

     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);
   }   

 long NFMadd_storage_area (user_id, attr_list, data_list)
   long    user_id;
   MEMptr  attr_list, data_list;
   {
     static char *fname = "NFMadd_storage_area" ;
      long      status;

     _NFMdebug ((fname, "ENTER\n")) ;

     status =  _NFMadd_storage_area (user_id, attr_list, data_list) ;
     if (status != NFM_S_SUCCESS)
       {
         _NFMdebug ((fname, "_NFMadd storage area failed : status = <0x%.8x>\n",
		     status)) ;
         return (NFM_E_MEM);         
       }

      _NFMdebug ((fname, "SUCCESSFUL\n")) ;
      return (NFM_S_SUCCESS);
   }


