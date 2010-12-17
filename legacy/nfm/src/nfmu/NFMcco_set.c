#include "machine.h"
#include "NFMU.h"
#include "NFMfile.h"

 long NFMcancel_co_set (user_id, item_list)
   long      user_id;
   MEMptr    item_list;
   {
     static char *fname= "NFMcancel_co_set";
     long    status ;
     int     x ;
     char    **column, **data ;
     char    catalog_name[30], item_name[NFM_ITEMNAME +1] ;
     char    item_rev[NFM_ITEMREV+1]; 
     MEMptr  attr_list = NULL, data_list = NULL ;
     long    NFMprep_can_co_set () ;
     long    NFMcomplete_can_co_set () ;

     _NFMdebug ((fname, "ENTER\n")) ;

     status = MEMbuild_array (item_list);
     if (status != MEM_S_SUCCESS)
       {
	 ERRload_struct (NFM, NFM_E_MEM, "", "") ;
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n", status));
        return (NFM_E_MEM);
      }

     column = (char **) item_list -> column_ptr;
     data   = (char **) item_list -> data_ptr;

     
     for (x = 0; x < item_list -> columns; ++x)
       {
	 if (! strcmp (column [x], "n_catalogname"))
	   strcpy (catalog_name, data [x]) ;
	 else if (! strcmp (column [x], "n_setname"))
	   strcpy (item_name, data [x]) ;
	 else if (! strcmp (column [x], "n_setrev"))
	   strcpy (item_rev, data [x]) ;
       }

     /* catalog_name, item_name and item_rev must be valid */

     if ((strlen (catalog_name)) && (strlen (item_name)) && (strlen (item_rev)))
       {
	 /* get check in buffers */
	 status = NFMprep_can_co_set  (user_id, catalog_name, item_name,
                                       item_rev, &attr_list, &data_list) ;
	 if (status != NFM_S_SUCCESS)
	   {
	     MEMclose (&attr_list) ;
	     MEMclose (&data_list) ;
	     _NFMdebug ((fname, "Prep Can CO : status = <0x%.8x>\n", 
		       status));
	     return (status) ;
	   }
	 
	 /* perform the cancel checkout set */
	 status = NFMcomplete_can_co_set  (user_id, attr_list, data_list) ;
	 if (status != NFM_S_SUCCESS)
	   {
	     MEMclose (&attr_list) ;
	     MEMclose (&data_list) ;
	     _NFMdebug ((fname, "Compl Can CO : status = <0x%.8x>\n", 
		       status));
	     return (status) ;
	   }

	 MEMclose (&attr_list) ;
	 MEMclose (&data_list) ;

       }
     else 
       {
        ERRload_struct (NFM, NFM_E_BAD_ITEM, "", NULL);
	 _NFMdebug ((fname, "No Active Item : status = <0x%.8x>\n", NFM_E_BAD_ITEM));
	 return (NFM_E_BAD_ITEM) ;
       }
     
     
     _NFMdebug ((fname, "SUCCESSFUL : status = <0x%.8x>\n", NFM_S_SUCCESS));
     return (NFM_S_SUCCESS);
   }


 long NFMprep_can_co_set (user_id, cat_name, item_name, item_rev,
                               attr_list, data_list)
   long    user_id;                           /* input mand */
   char    *cat_name, *item_name, *item_rev;  /*input mand */
   MEMptr  *attr_list, *data_list;            /*output checkin buffers*/
   {
     static char *fname = "NFMprep_can_co_set" ;
     long     status, atol ();
     long     a, b, i, j, k, l, x, y, count;
     char     **column, **data, **data1;
     char     temp_cat [100], co_status [5] ;
     long     item_no;

     _NFMdebug ((fname, "Cat   Name = <%s> : Item Name = <%s> : Item Rev = <%s>\n", 
		 cat_name, item_name, item_rev));

     status = NFMget_item_no (user_id, cat_name,
              item_name, item_rev, &item_no);
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "Get Item No : status = <0x%.8x>\n",
        status));
        return (status);
      }
/************************ mms 5/21/91 ************************
     status = NFMcheck_item (user_id, cat_name, item_no, NFM_SET_IN);
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "Check Item : status = <0x%.8x>\n",
        status));
        return (status);
      }
**************************************************************/
  status = NFMcheck_co_status (user_id, cat_name, item_no, co_status);
  if ((status != NFM_S_SUCCESS) && (status != NFM_E_SET_OUT) &&
      (status != NFM_E_SET_OUT_NO_FILE))
    {
      ERRload_struct (NFM, status, "", NULL) ;
      _NFMdebug ((fname, "Check Item : status = <0x%.8x>\n", status));
      return (status);
    }
    
     status = NFMquery_ci_attributes (user_id, "catalog",
              attr_list, data_list);
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "Get Ci Attr : status = <0x%.8x>\n",
        status));
        return (status);
      }

     status = NFMget_set_ci_list (user_id, cat_name,
				  item_no, item_name, item_rev,
				  *attr_list, *data_list);
     if (status != NFM_S_SUCCESS)
       {
	 _NFMdebug ((fname, "Get Ci Attr : status = <0x%.8x>\n",
		   status));
	 return (status);
       }
     
     status = MEMbuild_array (*attr_list);
     if (status != MEM_S_SUCCESS)
      {
	ERRload_struct (NFM, NFM_E_MEM, "", "") ;
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
		    status));
        return (NFM_E_MEM);
      }

     status = MEMbuild_array (*data_list);
     if (status != MEM_S_SUCCESS)
      {
	ERRload_struct (NFM, NFM_E_MEM, "", "") ;
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
		    status));
        return (NFM_E_MEM);
      }

     column = (char **) (*attr_list) -> column_ptr;
     data   = (char **) (*attr_list) -> data_ptr;

     data1  = (char **) (*data_list) -> data_ptr;

     a = -1; b = -1; 

     for (y = 0; y < (*attr_list) -> columns; ++y)
      {
              if (! strcmp (column [y], "n_name"))       a = y;
         else if (! strcmp (column [y], "n_datatype"))   b = y;
      }

     i = -1;  j = -1; k = -1; l = -1;

     for (x = 0; x < (*attr_list) -> rows; ++x)
      {
        count = (*attr_list) -> columns * x;

             if (! strcmp (data [count + a], "n_catalogname"))   i = x;
        else if (! strcmp (data [count + a], "n_itemno"))        j = x;
        else if (! strcmp (data [count + a], "n_status"))         k = x;
        else if (! strcmp (data [count + a], "n_type"))          l = x;
      }

     temp_cat [0] = 0; item_no = 0;

     for (x = 0; x < (*data_list) -> rows; ++x)
      {
        count = (*data_list) -> columns * x;

        if ((! strcmp (temp_cat,  data1 [count + i])) &&
            (item_no ==  atol (data1 [count + j])));
        else if (! x)
         {
           sprintf (temp_cat,  "%s", data1 [count + i]);
           item_no = atol (data1 [count + j]);
/***************************
           status = NFMcheck_item (user_id, temp_cat,
                    item_no, NFM_SET_IN);
           if (status != NFM_S_SUCCESS)
            {
              _NFMdebug ((fname, "Check Item : status = <0x%.8x>\n",
              status));
              return (status);
            }               
*******************************/
	   status = NFMcheck_co_status (user_id, temp_cat, item_no, co_status);
	   if ((status != NFM_S_SUCCESS) && (status != NFM_E_SET_OUT) &&
	       (status != NFM_E_SET_OUT_NO_FILE))
	     {
	       ERRload_struct (NFM, status, "", NULL) ;
	       _NFMdebug ((fname, "Check Item : status = <0x%.8x>\n", status));
	       return (status);
	     }
         }
        else
         {
           sprintf (temp_cat,  "%s", data1 [count + i]);
           item_no = atol (data1 [count + j]);

           if (! strcmp (data1 [count + l], "P"))
            {
/********************************************************
              status = NFMcheck_item (user_id, temp_cat, item_no,
                       NFM_MEM_IN);
              if (status != NFM_S_SUCCESS)
               {
                 _NFMdebug ((fname, "Chk Item : status = <0x%.8x>\n",
                 status));
                 return (status);
               }
**********************************************************/
	      status = NFMcheck_co_status (user_id, temp_cat, item_no, co_status);
	      if ((status != NFM_S_SUCCESS) && (status != NFM_E_MEM_OUT) &&
		  (status != NFM_E_MEM_OUT_NO_FILE))
		{
		  ERRload_struct (NFM, status, "", NULL) ;
		  _NFMdebug ((fname, "Check Item : status = <0x%.8x>\n", status));
		  return (status);
		}
            }
           else
            {
              status = NFMcheck_item (user_id, temp_cat, item_no,
                       NFM_MEM_COPY);
              if (status != NFM_S_SUCCESS)
               {
                 _NFMdebug ((fname, "Chk Item : status = <0x%.8x>\n",
                 status));
                 return (status);
               }
            }
         }
      }

     _NFMdebug ((fname, "SUCCESSFUL : status = <0x%.8x>\n",
     NFM_S_SUCCESS));
     return (NFM_S_SUCCESS);
   }


 long NFMcomplete_can_co_set  (user_id, 
                                attr_list, data_list)
   long      user_id;
   MEMptr    attr_list, data_list;
   {
     static char *fname = "NFMcomplete_can_co_set" ;
      long       status, atol ();
      long       item_no ;
      char       **column, **data, **data1;
      long       a, b, x, y, count;
      long       i, j, k;
      long       row_init ;
      char       cat_name [100], mem_type [10] ;
      long       NFMupd_cancel_co_file () ;

     _NFMdebug ((fname, "ENTER\n")) ;
      status = MEMbuild_array (attr_list);
      if (status != MEM_S_SUCCESS)
       {
	 ERRload_struct (NFM, NFM_E_MEM, "", "") ;
         _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
		     status));
         return (NFM_E_MEM);
       }

      status = MEMbuild_array (data_list);
      if (status != MEM_S_SUCCESS)
       {
	 ERRload_struct (NFM, NFM_E_MEM, "", "") ;
         _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
		     status));
         return (NFM_E_MEM);
       }

      column = (char **) attr_list -> column_ptr;
      data   = (char **) attr_list -> data_ptr;

      data1  = (char **) data_list -> data_ptr;

      a = -1; b = -1; 

      for (y = 0; y < attr_list -> columns; ++y)
       {
              if (! strcmp (column [y], "n_name"))      a = y;
         else if (! strcmp (column [y], "n_datatype"))  b = y;
       }

      i = -1; j = -1; k = -1;

      for (x = 0; x < attr_list -> rows; ++x)
       {
         count = attr_list -> columns * x;

              if (! strcmp (data [count + a], "n_catalogname"))  i = x;
         else if (! strcmp (data [count + a], "n_itemno"))       j = x;
         else if (! strcmp (data [count + a], "n_type"))         k = x;
       }

      row_init = 0;

      sprintf (cat_name,  "%s", data1 [i]);
      item_no = atol (data1 [j]);
      sprintf (mem_type, "%s", data1 [k]);

      status = NFMstop_transaction (0);
      if (status != NFM_S_SUCCESS)
	{
	  _NFMdebug ((fname, "Stop Transaction : status = <%d>\n",
		    status));
	  return (status);
	}

      for (x = 0; x < data_list -> rows; ++x)
       {
         count = data_list -> columns * x;
         
         if ((! strcmp (data1 [count + i], cat_name))  &&
             (item_no == atol (data1 [count + j])));
         else
          {
            if (! strcmp (mem_type, "P"))
             {
               status = NFMupd_cancel_co_file(user_id,
                        row_init, x,  
                        cat_name, item_no,
                        attr_list, data_list) ;
               if (status != NFM_S_SUCCESS)
                {
		  NFMrollback_transaction (0);
                  _NFMdebug ((fname, "Get Ci File Lst : status = <0x%.8x>\n",
                  status));
                  return (status);               
                }

             }
 
            sprintf (cat_name,  "%s", data1 [count + i]);
            item_no = atol (data1 [count + j]);
            sprintf (mem_type, "%s", data1 [count + k]);

            row_init = x;
          }
       }

      if (! strcmp (mem_type, "P"))
       {
         status = NFMupd_cancel_co_file (user_id, 
                  row_init, data_list -> rows, 
                  cat_name, item_no, attr_list, data_list) ;
         if (status != NFM_S_SUCCESS)
          {          
	    NFMrollback_transaction (0);
             _NFMdebug ((fname, "Get Ci F List : status = <0x%.8x>\n",
             status));
             return (status);               
          }
       }

      status = NFMstart_transaction (0);
      if (status != NFM_S_SUCCESS)
	{
          _NFMdebug ((fname, "Start Transaction : status = <%d>\n",
		    status));
          return (status);
	}
      
      _NFMdebug ((fname, "SUCCESFUL : status = <0x%.8x>\n",
      NFM_S_SUCCESS));
      return (NFM_S_SUCCESS);
   }




