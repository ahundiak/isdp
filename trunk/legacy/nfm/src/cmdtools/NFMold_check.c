#include "machine.h"
#include <stdio.h>
#include "MEMstruct.h"
#include "NFMerrordef.h"
#include "ERR.h"
#include "NFMlocks.h"
#include "NFMfile.h"
#include <errno.h>
#include <sys/types.h>
#include <sys/times.h>
#include <sys/param.h>
#include "WFstruct.h"
#include "NFMstruct.h"
#include "NFMattr_def.h"
#include "DEBUG.h"

struct set_list *LIST_items=NULL;
struct files_list *LIST_files=NULL;
extern struct NFMglobal_st NFMglobal ;

 long NFMset_temp_flag (user_id, cat_name, item_no, temp_state)
   long    user_id;
   char    *cat_name;
   long    item_no;
   char    *temp_state;
   {
     char *fname = "NFMset_temp_flag" ;
     long    status;
     char    sql_str [1024], value [50];

     _NFMdebug ((fname, "Cat  Name  = <%s>  : Item No <%d> : Temp State <%s>\n",
		 cat_name, item_no, temp_state)) ;
     user_id = user_id ;
     sprintf (value, "%d", item_no);

     sprintf (sql_str,  "UPDATE %s SET %s = '%s' WHERE %s = %s ",
	      cat_name, "n_status", temp_state, "n_itemno", value);

     status = SQLstmt (sql_str);
     if (status != SQL_S_SUCCESS)
      {
        ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
        _NFMdebug ((fname, "SQL Stmt Syntax : status = <0x%.8x>\n", 
		    status)) ;
        return (NFM_E_SQL_STMT);
      }

     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);
   }  

 long NFMquery_ci_attributes (user_id, cat_name, attr_list, data_list)
   long     user_id;
   char     *cat_name;
   MEMptr   *attr_list, *data_list;
   {
     char *fname = "NFMquery_ci_attributes" ;
     long     status;
     char     **column, **data;
     long     a, b,  count, x, y;
     char     *cat_str, *lvl_str, *row_str;
     char     *sts_str, *typ_str;
     char     sql_str [2048];
     char     file_cat [100];
     char     template_name [NFM_TABLENAME+1] ;
     char     f_template_name [NFM_TABLENAME+1] ;
     long     tab_no1, tab_no2;
     char     data_type [50];

     _NFMdebug ((fname, "Cat  Name = <%s>\n", cat_name)) ;

     status = NFMquery_table_template (user_id, attr_list);
     if (status != NFM_S_SUCCESS)
      {
        MEMclose (attr_list);
        _NFMdebug ((fname, "Qry Tab Temp : status = <0x%.8x>\n", status));
        return (status);
      }

     status = MEMbuild_array (*attr_list);
     if (status != MEM_S_SUCCESS)
      {
         MEMclose (attr_list);
         ERRload_struct (NFM, NFM_E_MEM, "", NULL);
         _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n", 
		     status)) ;
         return (NFM_E_MEM);        
      }

     cat_str = (char *) malloc ((*attr_list) -> row_size);
     if (! cat_str)
      {
         MEMclose (attr_list);
         ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
         _NFMdebug ((fname, "Malloc Failed\n")) ;
         return (NFM_E_MALLOC);        
      }

     lvl_str = (char *) malloc ((*attr_list) -> row_size);
     if (! lvl_str)
      {
         free (cat_str);
         MEMclose (attr_list);
         ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
         _NFMdebug ((fname, "Malloc Failed\n")) ;
         return (NFM_E_MALLOC);        
      }

     row_str = (char *) malloc ((*attr_list) -> row_size);
     if (! row_str)
      {
         free (cat_str);
         free (lvl_str);
         MEMclose (attr_list);
         ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
         _NFMdebug ((fname, "Malloc Failed\n")) ;
         return (NFM_E_MALLOC);        
      }

     typ_str = (char *) malloc ((*attr_list) -> row_size);
     if (! typ_str)
      {
         free (cat_str);
         free (lvl_str);
         free (row_str);
         MEMclose (attr_list);
         ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
         _NFMdebug ((fname, "Malloc Failed\n")) ;
         return (NFM_E_MALLOC);        
      }

     sts_str = (char *) malloc ((*attr_list) -> row_size);
     if (! sts_str)
      {
         free (cat_str);
         free (lvl_str);
         free (row_str);
         free (typ_str);
         MEMclose (attr_list);
         ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
         _NFMdebug ((fname, "Malloc Failed\n")) ;
         return (NFM_E_MALLOC);        
      }

     cat_str [0] = 0; lvl_str [0] = 0; row_str [0] = 0;
     typ_str [0] = 0; sts_str [0] = 0;

     column = (char **) (*attr_list) -> column_ptr;

     for (y = 0; y < (*attr_list) -> columns; ++y)
      {
        if (! strcmp (column [y], "n_name"))
         {
           strcat (cat_str, "n_catalogname"); 
           strcat (lvl_str, "n_level");
           strcat (row_str, "n_citno");
           strcat (sts_str, "n_status1");
           strcat (typ_str, "n_type");
         }
        else if (! strcmp (column [y], "n_datatype"))
         {
           strcat (cat_str, "char(20)");  strcat (lvl_str, "integer");
           strcat (row_str, "integer");   strcat (sts_str, "char(10)");
           strcat (typ_str, "char(1)");
         }
        else if (! strcmp (column [y], "n_synonym")) 
         {
           strcat (cat_str, "Catalog Name");  strcat (lvl_str, "Level");
           strcat (row_str, "Row No");       strcat (sts_str, "Status");
           strcat (typ_str, "MEM Type");
         }
        else if (! strcmp (column [y], "n_application"))
         {
           strcat (cat_str, "NFM");   strcat (lvl_str, "NFM");
           strcat (row_str, "NFM");   strcat (sts_str, "NFM");
           strcat (typ_str, "NFM");
         }
        else if (! strcmp (column [y], "n_read"))
         {
           strcat (cat_str, "Y");   strcat (lvl_str, "N");
           strcat (row_str, "N");   strcat (sts_str, "N");
           strcat (typ_str, "Y");
         }
        else if (! strcmp (column [y], "n_write"))
         {
           strcat (cat_str, "N");   strcat (lvl_str, "N");
           strcat (row_str, "N");   strcat (sts_str, "N");
           strcat (typ_str, "N");
         }
        else if (! strcmp (column [y], "n_update"))
         {
           strcat (cat_str, "N");   strcat (lvl_str, "N");
           strcat (row_str, "N");   strcat (sts_str, "N");
           strcat (typ_str, "N");
         }
        else if (! strcmp (column [y], "n_delete"))
         {
           strcat (cat_str, "N");   strcat (lvl_str, "N");
           strcat (row_str, "N");   strcat (sts_str, "N");
           strcat (typ_str, "N");
         }
        else if (! strcmp (column [y], "n_null"))
         {
           strcat (cat_str, "N");   strcat (lvl_str, "N");
           strcat (row_str, "N");   strcat (sts_str, "N");
           strcat (typ_str, "N");
         }
/***********
        else if (! strcmp (column [y], "n_keyin"))
         {
           strcat (cat_str, "0");   strcat (lvl_str, "0");
           strcat (row_str, "0");   strcat (sts_str, "0");
           strcat (typ_str, "0");
         }
**************/
        else if (! strcmp (column [y], "n_checkin"))
         {
           strcat (cat_str, "N");   strcat (lvl_str, "N");
           strcat (row_str, "N");   strcat (sts_str, "N");
           strcat (typ_str, "N");
         }
        else if (! strcmp (column [y], "n_checkout"))
         {
           strcat (cat_str, "N");   strcat (lvl_str, "N");
           strcat (row_str, "N");   strcat (sts_str, "N");
           strcat (typ_str, "N");
         }
        else if (! strcmp (column [y], "n_seqno"))
         {
           strcat (cat_str, "0");   strcat (lvl_str, "0");
           strcat (row_str, "0");   strcat (sts_str, "0");
           strcat (typ_str, "0");
         }
        else if (! strcmp (column [y], "n_adviceno"))
         {
           strcat (cat_str, "0");   strcat (lvl_str, "0");
           strcat (row_str, "0");   strcat (sts_str, "0");
           strcat (typ_str, "0");
         }
        else if (! strcmp (column [y], "n_valueno"))
         {
           strcat (cat_str, "0");   strcat (lvl_str, "0");
           strcat (row_str, "0");   strcat (sts_str, "0");
           strcat (typ_str, "0");
         }
         
        strcat (cat_str, "\1");     strcat (lvl_str, "\1");
        strcat (row_str, "\1");     strcat (sts_str, "\1");
        strcat (typ_str, "\1");
      }

     status = MEMwrite (*attr_list, sts_str);
     if (status != MEM_S_SUCCESS)
      {
        free (cat_str);   free (lvl_str);
        free (row_str);   free (sts_str);
        free (typ_str);
        MEMclose (attr_list);
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Write : status = <0x%.8x>\n", status)) ;
        return(NFM_E_MEM);
      }

     status = MEMwrite (*attr_list, lvl_str);
     if (status != MEM_S_SUCCESS)
      {
        free (cat_str);   free (lvl_str);
        free (row_str);   free (sts_str);
        free (typ_str);
        MEMclose (attr_list);
         ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Write : status = <0x%.8x>\n", status)) ;
        return (NFM_E_MEM);
      }

     status = MEMwrite (*attr_list, row_str);
     if (status != MEM_S_SUCCESS)
      {
        free (cat_str);   free (lvl_str);
        free (row_str);   free (sts_str);
        free (typ_str);
        MEMclose (attr_list);
         ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Write : status = <0x%.8x>\n", status)) ;
        return (NFM_E_MEM);
      }

     status = MEMwrite (*attr_list, cat_str);
     if (status != MEM_S_SUCCESS)
      {
        free (cat_str);   free (lvl_str);
        free (row_str);   free (sts_str);
        free (typ_str);
        MEMclose (attr_list);
         ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Write : status = <0x%.8x>\n", status)) ;
        return (NFM_E_MEM);
      }

     status = MEMwrite (*attr_list, typ_str);
     if (status != MEM_S_SUCCESS)
      {
        free (cat_str);   free (lvl_str);
        free (row_str);   free (sts_str);
        free (typ_str);
        MEMclose (attr_list);
         ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Write : status = <0x%.8x>\n", status)) ;
        return (NFM_E_MEM);
      }

     free (cat_str);   free (lvl_str);
     free (row_str);   free (sts_str);
     free (typ_str);

     NFMlower_case (cat_name, template_name) ;
     if (strcmp (template_name, "catalog") == 0)
       {
	 status = _NFMget_template_no ("t_basic", "catalog", "NFM",&tab_no1);
	 if (status != NFM_S_SUCCESS)
	   {
	     _NFMdebug ((fname, "Get Table No : status = <0x%.8x>\n", status)) ;
	     return (status);
	   }
       }
     else
       {
	 status = NFMget_table_no (user_id, "catalog", cat_name, &tab_no1);
	 if (status != NFM_S_SUCCESS)
	   {
	     _NFMdebug ((fname, "Get Table No : status = <0x%.8x>\n", status)) ;
	     return (status);
	   }
       }

     sprintf (file_cat, "f_%s", cat_name);

     NFMlower_case (file_cat, f_template_name) ;
     if (strcmp (f_template_name, "f_catalog") == 0)
       {
	 status = _NFMget_template_no ("t_basic", "f_catalog", 
				      "NFM", &tab_no2);
	 if (status != NFM_S_SUCCESS)
	   {
	     _NFMdebug ((fname, "Get Table No : status = <0x%.8x>\n", status)) ;
	     return (status);
	   }
       }
     else
       {
	 status = NFMget_table_no (user_id, "f_catalog", file_cat, &tab_no2);
	 if (status != NFM_S_SUCCESS)
	   {
	     _NFMdebug ((fname, "Get Table No : status = <0x%.8x>\n", status));
	     return (status);
	   }
       }

     sprintf (sql_str, 
     " (n_tableno = %d OR n_tableno = %d) AND (%s = 'Y' OR %s = 'U')",
     tab_no1, tab_no2, "n_checkin", "n_checkin");

     status = NFMquery_condition_definition (user_id, "", "",
              sql_str, "", attr_list);
     if (status != NFM_S_SUCCESS)
      {
         MEMclose (attr_list);
         _NFMdebug ((fname, "Cond Attr : status = <0x%.8x>\n", status));
         return (status);
      }

     status = MEMbuild_array (*attr_list);
     if (status != MEM_S_SUCCESS)
      {
         MEMclose (attr_list);
         ERRload_struct (NFM, NFM_E_MEM, "", NULL);
         _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n", status));
         return (NFM_E_MEM);        
      }

     column = (char **) (*attr_list) -> column_ptr;
     data   = (char **) (*attr_list) -> data_ptr;

     a = -1; b = -1; 

     for (y = 0; y < (*attr_list) -> columns; ++y)
      {
             if (! strcmp (column [y], "n_name"))      a = y;
        else if (! strcmp (column [y], "n_datatype"))  b = y;
      }

     if (! strcmp (cat_name, "catalog"))
      {
        for (x = 0; x < (*attr_list) -> rows; ++x)
         {
           count = (*attr_list) -> columns * x;           
 
           if ((! strcmp (data [count + a], "n_itemname")) ||
               (! strcmp (data [count + a], "n_itemrev")))
            {
              status = NFMget_max_attr_size (user_id, data [count + a],
                       data_type);
              if (status != NFM_S_SUCCESS)
               {
                 MEMclose (attr_list);
                 _NFMdebug ((fname, "Max Size : status = <0x%.8x>\n",
                 status));
                 return (status);        
               }

              status = MEMwrite_data (*attr_list, data_type,
                       x + 1, b + 1);
/* DUR 1/5/91 if (status != NFM_S_SUCCESS)*/
              if (status != MEM_S_SUCCESS)
               {
                 MEMclose (attr_list);
                 _NFMdebug ((fname, "Max Size : status = <0x%.8x>\n",
                 status));
                 return (NFM_E_MEM);        
               }
            }
         }
      }

     status = MEMopen (data_list, 2 * MEM_SIZE);
     if (status != MEM_S_SUCCESS)
      {
         MEMclose (attr_list);
         ERRload_struct (NFM, NFM_E_MEM, "", NULL);
         _NFMdebug ((fname, "MEM Open Failed : status = <0x%.8x>\n",
		     status)) ;
	 return (NFM_E_MEM);        
      }

     for (x = 0; x < (*attr_list) -> rows; ++x)
      {
        count = (*attr_list) -> columns * x;

        status = MEMwrite_format (*data_list,
                 data [count + a], data [count + b]);
        if (status != MEM_S_SUCCESS)
         {
            MEMclose (attr_list);
            MEMclose (data_list);
         ERRload_struct (NFM, NFM_E_MEM, "", NULL);
            _NFMdebug ((fname, "MEM Write Format : status = <0x%.8x>\n",
			status));
            return (NFM_E_MEM);        
         }
      }
          
     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);
   }

 long NFMget_item_ci_list (user_id, cat_name, item_no,
           ctype, level, row_id, attr_list, data_list)
   long     user_id;
   char     *cat_name;
   long     item_no;
   char     *ctype, *level, *row_id;
   MEMptr   attr_list, data_list;
   {
     char *fname = "NFMget_item_ci_list" ;
     long    status;
     char    file_cat [100];
     long    a, b, d, x, y, z, count, count1, comma, found, offset ;
     char    **column, **data, **data1, **data2, **column1 ;
     MEMptr  cat_list = NULL, file_list = NULL;
     long    i, j, k, l;
     char    *sql_str, sql_str1 [1024];
     char    attr [50], value [50];
     MEMptr  list = NULL;

     _NFMdebug ((fname, "Cat  Name = <%s> : Item No = <%d> : C type <%s> : Level <%s> : Row Id = <%s>\n", 
		 cat_name, item_no, ctype, level, row_id));

     sprintf (file_cat, "f_%s", cat_name);

     status = MEMbuild_array (attr_list);
     if (status != MEM_S_SUCCESS)
      {
         ERRload_struct (NFM, NFM_E_MEM, "", NULL);
         _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n", status));
         return (NFM_E_MEM);
      }

     column = (char **) attr_list -> column_ptr;
     data   = (char **) attr_list -> data_ptr;

     a = -1; b = -1; d = -1;

     for (y = 0; y < attr_list -> columns; ++y)
      {
             if (! strcmp (column [y], "n_name"))          a = y;
        else if (! strcmp (column [y], "n_datatype"))      b = y;
        else if (! strcmp (column [y], "n_application"))   d = y;
      }

     status = NFMquery_attributes_definition (user_id, "CATALOG",
              cat_name, &cat_list);
     if (status != NFM_S_SUCCESS)
      {
         MEMclose (&cat_list);
         _NFMdebug ((fname, "Query Cat Def : status = <0x%.8x>\n", status));
         return (status);
      }

     status = NFMquery_attributes_definition (user_id, "F_CATALOG",
              file_cat, &file_list);
     if (status != NFM_S_SUCCESS)
      {
         MEMclose (&cat_list);
         MEMclose (&file_list);
         _NFMdebug ((fname, "Query Cat Def : status = <0x%.8x>\n", status));
         return (status);
      }

     status = MEMbuild_array (cat_list);
     if (status != MEM_S_SUCCESS)
      {
         MEMclose (&cat_list);
         MEMclose (&file_list);
         ERRload_struct (NFM, NFM_E_MEM, "", NULL);
         _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n", status));
         return (NFM_E_MEM);
      }

     status = MEMbuild_array (file_list);
     if (status != MEM_S_SUCCESS)
      {
         MEMclose (&cat_list);
         MEMclose (&file_list);
         ERRload_struct (NFM, NFM_E_MEM, "", NULL);
         _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n", status));
         return (NFM_E_MEM);
      }

     data1 = (char **) cat_list  -> data_ptr;
     data2 = (char **) file_list -> data_ptr;

     sql_str = (char *) malloc (attr_list -> rows * 100 + MEM_SIZE);
     if (! sql_str)
      {
         MEMclose (&cat_list);
         MEMclose (&file_list);
         ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
         _NFMdebug ((fname, "Malloc Failed\n")) ;
         return (NFM_E_MALLOC);
      }
     sql_str [0] = 0;

     sprintf (sql_str, "SELECT ");
     comma = 0;

     /****************  Added by DUR 8/1/90  **************************/

     j = -1; k = -1; l = -1; i=-1;

     /************ end of code added by DUR  ************************/

     for (x = 5; x < attr_list -> rows; ++x)
      {
        count = attr_list -> columns * x;

/*        _NFMdebug ((fname, "Attr Name : <%s>", data [count + a])); */
        found = 0;

		/*  Loop through the file attributes looking for a match against
            the current item attribute.  */

        for (y = 0; (y < file_list -> rows) && (! found); ++y)
         {
          /***
             This loop circulates once for every attribute in the list.
             I believe this can be rewritten to be more efficient.
          ***/
           count1 = file_list -> columns * y;

                if (! strcmp (data [count + a], "n_itemnum"))     j = y;
           else if (! strcmp (data [count + a], "n_fileclass"))   k = y;
           else if (! strcmp (data [count + a], "n_fileversion")) l = y;

           if ((! strcmp (data [count + a], data2 [count1 + 2])) &&
               (! strcmp (data [count + d], "NFM")))
            {
              if (comma) strcat (sql_str, ", ");
              comma = 1;
 
              strcat (sql_str, file_cat);
              strcat (sql_str, ".");
              strcat (sql_str, data2 [count1]);

              found = 1;
            } /* if */
         } /* for */

        for (y = 0; (y < cat_list -> rows) && (! found); ++y)
         {
           count1 = cat_list -> columns * y;

           if (! strcmp (data [count + a], "n_itemno"))     i = y;

           if ((! strcmp (data [count + a], data1 [count1 + 2])) &&
               (! strcmp (data [count + d], "NFM")))
            {
              if (comma) strcat (sql_str, ", ");
              comma = 1;
 
              strcat (sql_str, cat_name);
              strcat (sql_str, ".");
              strcat (sql_str, data1 [count1]);

              found = 1;
            }
           else if (! strcmp (data [count + a], data1 [count1]))
            {
              if (comma) strcat (sql_str, ", ");
              comma = 1;
 
              strcat (sql_str, cat_name);
              strcat (sql_str, ".");
              strcat (sql_str, data1 [count1]);

              found = 1;
            }
         }

        if (! found)
         {
           free (sql_str);
           MEMclose (&cat_list);
           MEMclose (&file_list);
         ERRload_struct (NFM, NFM_E_CORRUPTED_SYSTEM, "", NULL);
           _NFMdebug ((fname, "System Is Corrupted 1 \n")) ;
           return (NFM_E_CORRUPTED_SYSTEM);             
         }
      }

     strcat (sql_str, " FROM ");
     strcat (sql_str, cat_name);
     strcat (sql_str, ",  ");
     strcat (sql_str, file_cat);

     strcat (sql_str, " WHERE ");

                             /* modify the query to improve the performance */
     strcat (sql_str, file_cat);
     strcat (sql_str, ".");
     strcat (sql_str, data2 [(file_list->columns*j)]);
     strcat (sql_str, " = ");

     sprintf (value, "%d", item_no);

     if (! strncmp (data2 [(file_list -> columns * j) + 1], "char", 4))
      {
        strcat (sql_str, "'");
        strcat (sql_str, value);
        strcat (sql_str, "'");
      }
     else
        strcat (sql_str, value);

     strcat (sql_str, " AND ");
     strcat (sql_str, file_cat);
     strcat (sql_str, ".");
     strcat (sql_str, data2 [(file_list -> columns * k)]);
     strcat (sql_str, " = ");

     if (! strncmp (data2 [(file_list -> columns * k) + 1], "char", 4))
        strcat (sql_str, "'C'");
     else
        strcat (sql_str, "C");

     sql_str1 [0] = 0;

     strcat (sql_str1, " WHERE ");
     strcat (sql_str1, data2 [(file_list -> columns * j)]);
     strcat (sql_str1, " = ");
            
     if (! strncmp (data2 [(file_list -> columns * j) + 1], "char", 4))
      {
         strcat (sql_str1, "'");
         strcat (sql_str1, value);
         strcat (sql_str1, "'");
      }
     else
         strcat (sql_str1, value);

     strcat (sql_str1, " AND ");
     strcat (sql_str1, file_cat);
     strcat (sql_str1, ".");
     strcat (sql_str1, data2 [(file_list -> columns * k)]);
     strcat (sql_str1, " = ");

     if (! strncmp (data2 [(file_list -> columns * k) + 1], "char", 4))
        strcat (sql_str1, "'C'");
     else
        strcat (sql_str1, "C");

     sprintf (attr, "MAX(%s)", data2 [(file_list -> columns * l)]);

     status = NFMget_attr_value (user_id, file_cat, 
              attr, sql_str1, value);
     if (status != NFM_S_SUCCESS)
      {
        free (sql_str);
        MEMclose (&cat_list);
        MEMclose (&file_list);
    
        if (status == NFM_I_BAD_CONDITION)
         {
         ERRload_struct (NFM, NFM_E_BAD_FILE, "", NULL);
           _NFMdebug ((fname, "No Such File : status = <0x%.8x>\n", status));
           return (NFM_E_BAD_FILE);             
         }

        _NFMdebug ((fname, "Get Attr Value : status = <0x%.8x>\n", status));
        return (status);             
      }

     strcat (sql_str, " AND ");
     strcat (sql_str, file_cat);
     strcat (sql_str, ".");
     strcat (sql_str, data2 [(file_list -> columns * l)]);
     strcat (sql_str, " = ");

     if (! strncmp (data2 [(file_list -> columns * l) + 1], "char", 4))
      {
        strcat (sql_str, "'");
        strcat (sql_str, value);
        strcat (sql_str, "'");
      }
     else
        strcat (sql_str, value);

     strcat (sql_str, " AND ");
     strcat (sql_str, file_cat);
     strcat (sql_str, ".");
     strcat (sql_str, data2 [(file_list -> columns * j)]);
     strcat (sql_str, " = ");
     strcat (sql_str, cat_name);
     strcat (sql_str,".");
     strcat (sql_str, data1 [(cat_list -> columns * i)]);

     status = MEMclose (&cat_list);
     if (status != MEM_S_SUCCESS)
      {
        free (sql_str);
        MEMclose (&file_list);
         ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Close : status = <0x%.8x>\n", status));
        return (NFM_E_MEM);       
      }

     status = MEMclose (&file_list);
     if (status != MEM_S_SUCCESS)
      {
        free (sql_str);
         ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Close : status = <0x%.8x>\n", status));
        return (NFM_E_MEM);       
      }

     status = SQLquery (sql_str, &list, 2 * MEM_SIZE);
     if (status != SQL_S_SUCCESS)
      {
        free (sql_str);
        MEMclose (&list);
 
        if ((status ) == SQL_I_NO_ROWS_FOUND)
         {
	   ERRload_struct (NFM, NFM_E_CORRUPTED_CATALOG, "", NULL);
           _NFMdebug ((fname, "Cat Entries Are Bad : status = <0x%.8x>\n",
		       status));
           return (NFM_E_CORRUPTED_CATALOG);
         }

         ERRload_struct (NFM,  NFM_E_SQL_QUERY, "", NULL);
        _NFMdebug ((fname, "SQL Query Failed : status = <0x%.8x>\n", status));
        return ( NFM_E_SQL_QUERY);
      }

     status = MEMbuild_array (list);
     if (status != MEM_S_SUCCESS)
      {
        free (sql_str);
        MEMclose (&list);
         ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n", status));
        return (NFM_E_MEM);       
      }

     data1 = (char **) list -> data_ptr;
     column1 = (char **) list-> column_ptr ;

     free (sql_str);

     sql_str = (char *) malloc (data_list -> row_size * 2);
     if (! sql_str)
      {
        MEMclose (&list);
         ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
        _NFMdebug ((fname, "Malloc Failed\n")) ;
        return (NFM_E_MALLOC);       
      }

     for (i=0; i<list->rows; i++)
       {
	 offset = i*list->columns ;
	 sql_str [0] = 0 ;

	 for (y = 0; y < attr_list -> rows; ++y)
	   {
	     count1 = attr_list -> columns * y;
	     
	     if (! strcmp (data [count1 + a], "n_catalogname"))
	       strcat (sql_str, cat_name);
	     else if (! strcmp (data [count1 + a], "n_level"))
	       strcat (sql_str, level);
	     else if (! strcmp (data [count1 + a], "n_citno"))
	       strcat (sql_str, row_id);
	     else if (! strcmp (data [count1 + a], "n_type"))
	       strcat (sql_str, ctype);
	     else if (! strcmp (data [count1 + a], "n_status1"))
	       strcat (sql_str, "");
	     else
	       {
		 for (z=0; z<list->columns; z++)
		   {
		     count = offset + z ;
		     _NFMdebug ((fname, "comparing %s : %s\n",
				 data [count1 +a],
				 column1 [z])) ;
		     if (! strcmp (data [count1 + a], column1 [z]))
		       {
			 strcat (sql_str, data1 [count]) ;
			 break ;
		       }
		   }
	       }
	     strcat (sql_str, "\1");
	   }
	 
	 
	 status = MEMwrite (data_list, sql_str);
	 if (status != MEM_S_SUCCESS)
	   {
	     free (sql_str);
	     MEMclose (&list);
	     ERRload_struct (NFM, NFM_E_MEM, "", NULL);
	     _NFMdebug ((fname, "MEM Write : status = <0x%.8x>\n", status)) ;
	     return (NFM_E_MEM);       
	   }
       }

     free (sql_str);
     
     status = MEMclose (&list);
     if (status != MEM_S_SUCCESS)
      {
         ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Close : status = <0x%.8x>\n", status));
        return (NFM_E_MEM);       
      }

     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);
   }

 long NFMget_ci_files_list (user_id, i_row, f_row,
            attr_list, data_list, file_list, type)
   long    user_id;
   long    i_row, f_row;
   MEMptr  attr_list, data_list, file_list;
   long    type;
   {
     char *fname = "NFMget_ci_files_list" ;
     long    status;
     char    **column, **data, **data1, **column2;
     long    a, b, y, x, count;
     long    i1, j1, k1, l1, m1;
     long    i2, j2, k2, l2;
     long    i3, j3, k3, l3, m3, n3, o3, p3, q3, r3, s3;
     char    cat_name [100];
     long    cat_no, item_no, item_ver, new_ver, file_no;
     char    *sql_str;
     char    node_name [50], user_name [50], passwd [50];
     char    path_name [50], device_type [10];
     char    mach_id [20], op_sys [20];
     char    net_xns [10], net_tcp [10], net_dec [10];
     char    filename [50], value [50];
     char    file_type [20];
     long    NFMmake_file_cat_entry ();

     _NFMdebug ((fname, "Init  Row  = <%d> : Final Row = <%d> : Type = <%d>\n",
		 i_row, f_row, type)) ;

     column = (char **) attr_list -> column_ptr;
     data   = (char **) attr_list -> data_ptr;

     data1  = (char **) data_list -> data_ptr;

     a = -1; b = -1; 

     for (y = 0; y < attr_list -> columns; ++y)
      {
             if (! strcmp (column [y], "n_name"))        a = y;
        else if (! strcmp (column [y], "n_datatype"))    b = y;
      }

     i1 = -1; j1 = -1; k1 = -1; l1 = -1; m1 = -1;
     i2 = -1; j2 = -1; k2 = -1; l2 = -1;
     i3 = -1; j3 = -1; k3 = -1; l3 = -1; m3 = -1;
     n3 = -1; o3 = -1; p3 = -1; q3 = -1; r3 = -1; s3 = -1;

     for (x = 0; x < attr_list -> rows; ++x)
      {
        count = attr_list -> columns * x;

             if (! strcmp (data [count + a], "n_catalogname"))    i1 = x;
        else if (! strcmp (data [count + a], "n_status1"))         j1 = x;
        else if (! strcmp (data [count + a], "n_type"))            k1 = x;
        else if (! strcmp (data [count + a], "n_level"))          l1 = x;
        else if (! strcmp (data [count + a], "n_citno"))          m1 = x;

        else if (! strcmp (data [count + a], "n_itemno"))         i2 = x;
        else if (! strcmp (data [count + a], "n_itemname"))       j2 = x;
        else if (! strcmp (data [count + a], "n_itemrev"))        k2 = x;
        else if (! strcmp (data [count + a], "n_status"))          l2 = x;
          /* n_coout */
        else if (! strcmp (data [count + a], "n_itemnum"))        i3 = x;
        else if (! strcmp (data [count + a], "n_fileno"))         j3 = x;
        else if (! strcmp (data [count + a], "n_fileco"))         k3 = x;
        else if (! strcmp (data [count + a], "n_fileversion"))    l3 = x;
        else if (! strcmp (data [count + a], "n_cisano"))         m3 = x;
        else if (! strcmp (data [count + a], "n_cifilename"))     n3 = x;
        else if (! strcmp (data [count + a], "n_cofilename"))     o3 = x;
        else if (! strcmp (data [count + a], "n_cifilesize"))     p3 = x;
        else if (! strcmp (data [count + a], "n_fileclass"))      q3 = x;
        else if (! strcmp (data [count + a], "n_filetype"))       r3 = x;
        else if (! strcmp (data [count + a], "n_setindicator"))   s3 = x;
      }

     sprintf (cat_name, "%s", 
              data1 [(data_list -> columns * i_row) + i1]);

     item_no  = atol (data1 [(data_list -> columns * i_row) + i2]);
     item_ver = atol (data1 [(data_list -> columns * i_row) + l3]);
     new_ver  = item_ver + 1;

     status = NFMget_catalog_no (user_id, cat_name, &cat_no);
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "Get Catalog No : status = <0x%.8x>\n",
        status));
        return (status);        
      }

     sql_str = (char *) malloc (2 * MEM_SIZE + file_list -> row_size);
     if (! sql_str)
      {
         ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
        _NFMdebug ((fname, "Malloc Failed\n")) ;
        return (NFM_E_MALLOC);        
      }

     for (x = i_row; x < f_row; ++x)
      {
        count = data_list -> columns * x;

        status = MEMbuild_array (file_list);
        if (status != MEM_S_SUCCESS)
         {
           free (sql_str);
         ERRload_struct (NFM, NFM_E_MEM, "", NULL);
           _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
		       status));
           return (NFM_E_MEM);        
         }

        column2 = (char **) file_list -> column_ptr;

        if (strcmp (data1 [count + i1], cat_name))
         {
           free (sql_str);
         ERRload_struct (NFM, NFM_E_CORRUPTED_BUFFERS, "", NULL);
           _NFMdebug ((fname, "Cat Is Bad In Buff : status = <0x%.8x>\n",
           NFM_E_CORRUPTED_BUFFERS));
           return (NFM_E_CORRUPTED_BUFFERS);        
         }

        if (atol (data1 [count + i2]) != item_no)
         {
           free (sql_str);
         ERRload_struct (NFM, NFM_E_CORRUPTED_BUFFERS, "", NULL);
           _NFMdebug ((fname, "Num Is Bad In Buff : status = <0x%.8x>\n",
           NFM_E_CORRUPTED_BUFFERS));
           return (NFM_E_CORRUPTED_BUFFERS);        
         }

        if (atol (data1 [count + l3]) != item_ver)
         {
           free (sql_str);
         ERRload_struct (NFM, NFM_E_CORRUPTED_BUFFERS, "", NULL);
           _NFMdebug ((fname, "Ver Is Bad In Buff : status = <0x%.8x>\n",
           NFM_E_CORRUPTED_BUFFERS));
           return (NFM_E_CORRUPTED_BUFFERS);        
         }

        if ( (!strcmp (data1[count+s3],"Y")) && (!strcmp (data1[count+l2],"SN")) )
        {
          strcpy (node_name, "");
          strcpy (user_name, "");
          strcpy (passwd, "");
          strcpy (path_name, "");
          strcpy (device_type, "");
          strcpy (mach_id, "");
          strcpy (op_sys, "");
          strcpy (net_tcp, "");
          strcpy (net_xns, "");
          strcpy (net_dec, "");
        }
        else
        {
          status = NFMget_sa_no_info (user_id,
                   atol (data1 [count + m3]),
                   node_name, user_name, passwd, path_name, device_type,
                   mach_id, op_sys, net_tcp, net_xns, net_dec);
          if (status != NFM_S_SUCCESS)
          {
             free (sql_str);
             _NFMdebug ((fname, "St No Info : status = <0x%.8x>\n",
             status));
             return (status);        
          }
        }

	strcpy (file_type, data1 [count + r3]) ;
        
        NFMchange_case (data1 [count + j1], 0);

        _NFMdebug ((fname, "Type = <%s>\n", data1 [count + j1]));

        if (! strcmp (data1 [count + j1], "drop"))
         {
           if (type)
            {
              free (sql_str);
         ERRload_struct (NFM, NFM_E_MOD_ITEM_DEF, "", NULL);
              _NFMdebug ((fname, "Can Not Mod Def : status = <0x%.8x>\n",
              NFM_E_MOD_ITEM_DEF));
              return (NFM_E_MOD_ITEM_DEF);      
            }
         
           sql_str [0] = 0;
 
           for (y = 0; y < file_list -> columns; ++y)
            {
              if (! strcmp (column2 [y], "n_status1"))
                strcat (sql_str, "delete");
              else if (! strcmp (column2 [y], "n_fileno"))
                strcat (sql_str, data1 [count + j3]);
              else if (! strcmp (column2 [y], "n_sano"))
                strcat (sql_str, data1 [count + m3]);
              else if (! strcmp (column2 [y], "n_nodename"))
                strcat (sql_str, node_name);
              else if (! strcmp (column2 [y], "n_username"))
                strcat (sql_str, user_name);
              else if (! strcmp (column2 [y], "n_passwd"))
                strcat (sql_str, passwd);
              else if (! strcmp (column2 [y], "n_pathname"))
                strcat (sql_str, path_name);
              else if (! strcmp (column2 [y], "n_devicetype"))
                strcat (sql_str, device_type);
              else if (! strcmp (column2 [y], "n_machid"))
                strcat (sql_str, mach_id);
              else if (! strcmp (column2 [y], "n_opsys"))
                strcat (sql_str, op_sys);
              else if (! strcmp (column2 [y], "n_tcpip"))
                strcat (sql_str, net_tcp);
              else if (! strcmp (column2 [y], "n_xns"))
                strcat (sql_str, net_xns);
              else if (! strcmp (column2 [y], "n_decnet"))
                strcat (sql_str, net_dec);
              else if (! strcmp (column2 [y], "n_cifilename"))
                strcat (sql_str, data1 [count + n3]);
              else if (! strcmp (column2 [y], "n_cofilename"))
               {
                 if (! strlen (data1 [count + o3]))
                  {
                    free (sql_str);
         ERRload_struct (NFM, NFM_E_BAD_FILE_NAME, "", NULL);
                    _NFMdebug ((fname, "No Co F Name : status = <0x%.8x>\n",
                    NFM_E_BAD_FILE_NAME));
                    return (NFM_E_BAD_FILE_NAME);      
                  }

                 strcat (sql_str, data1 [count + o3]);
               }
              else if (! strcmp (column2 [y], "n_cifilesize"))
                strcat (sql_str, "");
              else if (! strcmp (column2 [y], "n_filetype"))
                strcat (sql_str, file_type);

              strcat (sql_str, "\1");
            }

           status = MEMwrite (file_list, sql_str);
           if (status != MEM_S_SUCCESS)
            {
              free (sql_str);
         ERRload_struct (NFM, NFM_E_MEM, "", NULL);
              _NFMdebug ((fname, "MEM Write : status = <0x%.8x>\n",
			  status));
              return (NFM_E_MEM);      
            }
         }
        else if (((! strcmp (data1 [count + l2], "SN"))   ||
                  (! strcmp (data1 [count + l2], "MN")))  &&
                 (! strlen (data1 [count + o3])))
         {
           sql_str [0] = 0;

           for (y = 0; y < file_list -> columns; ++y)
            {
              _NFMdebug ((fname, "Col Name = <%s>", column2 [y]));

              if (! strcmp (column2 [y], "n_status1"))
                strcat (sql_str, "none");
              else if (! strcmp (column2 [y], "n_fileno"))
                strcat (sql_str, data1 [count + j3]);
              else if (! strcmp (column2 [y], "n_sano"))
                strcat (sql_str, data1 [count + m3]);
              else if (! strcmp (column2 [y], "n_nodename"))
                strcat (sql_str, node_name);
              else if (! strcmp (column2 [y], "n_username"))
                strcat (sql_str, user_name);
              else if (! strcmp (column2 [y], "n_passwd"))
                strcat (sql_str, passwd);
              else if (! strcmp (column2 [y], "n_pathname"))
                strcat (sql_str, path_name);
              else if (! strcmp (column2 [y], "n_devicetype"))
                strcat (sql_str, device_type);
              else if (! strcmp (column2 [y], "n_machid"))
                strcat (sql_str, mach_id);
              else if (! strcmp (column2 [y], "n_opsys"))
                strcat (sql_str, op_sys);
              else if (! strcmp (column2 [y], "n_tcpip"))
                strcat (sql_str, net_tcp);
              else if (! strcmp (column2 [y], "n_xns"))
                strcat (sql_str, net_xns);
              else if (! strcmp (column2 [y], "n_decnet"))
                strcat (sql_str, net_dec);
              else if (! strcmp (column2 [y], "n_cifilename"))
                strcat (sql_str, data1 [count + n3]);
              else if (! strcmp (column2 [y], "n_cofilename"))
                strcat (sql_str, data1 [count + o3]);
               else if (! strcmp (column2 [y], "n_cifilesize"))
                strcat (sql_str, "");
              else if (! strcmp (column2 [y], "n_filetype"))
                strcat (sql_str, file_type);

              strcat (sql_str, "\1");
            }

           status = MEMwrite (file_list, sql_str);
           if (status != MEM_S_SUCCESS)
            {
              free (sql_str);
         ERRload_struct (NFM, NFM_E_MEM, "", NULL);
              _NFMdebug ((fname, "MEM Write : status = <0x%.8x>\n",
			  status));
              return (NFM_E_MEM);      
            }            
         }
        else if (! strcmp (data1 [count + k1], "S"))
         {
           sql_str [0] = 0;

           for (y = 0; y < file_list -> columns; ++y)
            {
              _NFMdebug ((fname, "Col Name = <%s>", column2 [y]));

              if (! strcmp (column2 [y], "n_status1"))
               {
                 if (! strcmp (data1 [count + k3], "N"))
                   strcat (sql_str, "none");
                 else
                   strcat (sql_str, "delete");
               }
              else if (! strcmp (column2 [y], "n_fileno"))
                strcat (sql_str, data1 [count + j3]);
              else if (! strcmp (column2 [y], "n_sano"))
                strcat (sql_str, data1 [count + m3]);
              else if (! strcmp (column2 [y], "n_nodename"))
                strcat (sql_str, node_name);
              else if (! strcmp (column2 [y], "n_username"))
                strcat (sql_str, user_name);
              else if (! strcmp (column2 [y], "n_passwd"))
                strcat (sql_str, passwd);
              else if (! strcmp (column2 [y], "n_pathname"))
                strcat (sql_str, path_name);
              else if (! strcmp (column2 [y], "n_devicetype"))
                strcat (sql_str, device_type);
              else if (! strcmp (column2 [y], "n_machid"))
                strcat (sql_str, mach_id);
              else if (! strcmp (column2 [y], "n_opsys"))
                strcat (sql_str, op_sys);
              else if (! strcmp (column2 [y], "n_tcpip"))
                strcat (sql_str, net_tcp);
              else if (! strcmp (column2 [y], "n_xns"))
                strcat (sql_str, net_xns);
              else if (! strcmp (column2 [y], "n_decnet"))
                strcat (sql_str, net_dec);
              else if (! strcmp (column2 [y], "n_cifilename"))
                strcat (sql_str, data1 [count + n3]);
              else if (! strcmp (column2 [y], "n_cofilename"))
                strcat (sql_str, data1 [count + o3]);
               else if (! strcmp (column2 [y], "n_cifilesize"))
                strcat (sql_str, "");
              else if (! strcmp (column2 [y], "n_filetype"))
                strcat (sql_str, file_type);

              strcat (sql_str, "\1");
            }

           status = MEMwrite (file_list, sql_str);
           if (status != MEM_S_SUCCESS)
            {
              free (sql_str);
         ERRload_struct (NFM, NFM_E_MEM, "", NULL);
              _NFMdebug ((fname, "MEM Write : status = <0x%.8x>\n",
			  status));
              return (NFM_E_MEM);      
            }            
         }
        else
         {
           status = NFMmake_file_cat_entry (user_id, cat_name, item_no,
                    new_ver, &file_no);
           if (status != NFM_S_SUCCESS)
            {
              free (sql_str);
              _NFMdebug ((fname, "New File Entry : status = <0x%.8x>\n",
              status));
              return (status);      
            }

           status = NFMget_file_name (user_id, cat_no, file_no, filename);
           if (status != NFM_S_SUCCESS)
            {
              free (sql_str);
              _NFMdebug ((fname, "Get File Name : status = <0x%.8x>\n",
              status));
              return (status);      
            }

           sprintf (value, "%d", file_no);

           _NFMdebug ((fname, "File Name = <%s>", filename));

           sql_str [0] = 0;

           for (y = 0; y < file_list -> columns; ++y)
            {
              _NFMdebug ((fname, "Col Name = <%s>", column2 [y]));

              if (! strcmp (column2 [y], "n_status1"))
               {
                 if ((! strcmp (data1 [count + k3], "Y")) ||
                     (! strcmp (data1 [count + l2], ""))  ||
                     (! strcmp (data1 [count + l3], "0")))
                   strcat (sql_str, "move");
                 else
                   strcat (sql_str, "copy");
               }
              else if (! strcmp (column2 [y], "n_fileno"))
                strcat (sql_str, value);
              else if (! strcmp (column2 [y], "n_sano"))
                strcat (sql_str, data1 [count + m3]);
              else if (! strcmp (column2 [y], "n_nodename"))
                strcat (sql_str, node_name);
              else if (! strcmp (column2 [y], "n_username"))
                strcat (sql_str, user_name);
              else if (! strcmp (column2 [y], "n_passwd"))
                strcat (sql_str, passwd);
              else if (! strcmp (column2 [y], "n_pathname"))
                strcat (sql_str, path_name);
              else if (! strcmp (column2 [y], "n_devicetype"))
                strcat (sql_str, device_type);
              else if (! strcmp (column2 [y], "n_machid"))
                strcat (sql_str, mach_id);
              else if (! strcmp (column2 [y], "n_opsys"))
                strcat (sql_str, op_sys);
              else if (! strcmp (column2 [y], "n_tcpip"))
                strcat (sql_str, net_tcp);
              else if (! strcmp (column2 [y], "n_xns"))
                strcat (sql_str, net_xns);
              else if (! strcmp (column2 [y], "n_decnet"))
                strcat (sql_str, net_dec);
              else if (! strcmp (column2 [y], "n_cifilename"))
               {
                 if (strlen (data1 [count + n3]))
                  {
/*
                    free (sql_str);
                    _NFMdebug ((fname, "Ci File Name : <%d>\n",
                    -1));
                    return (-1);                    
*/
                    strcat (sql_str, data1 [count + n3]);
                  }
                 else 
                   strcat (sql_str, filename);
               }
              else if (! strcmp (column2 [y], "n_cofilename"))
               {
/***
                 if ((strcmp (data1 [count + k3], "Y")) &&
                     (strcmp (data1 [count + l3], "0")))
                  {
                    if (strlen (data1 [count + n3]))
                     {
                       free (sql_str);
                       _NFMdebug ((fname,  
                       "Copy Ci File Name : <%d>\n",
                       -1));
                       return (-1);                    
                     }
                    else
                     {
                       status = NFMget_file_name (user_id, cat_no,
                                atol (data1 [count + j3]), filename1);
                       if (status != NFM_S_SUCCESS)
                        {
                          free (sql_str);
                          _NFMdebug ((fname, "Get FNme : status = <0x%.8x>\n",
                          status));
                          return (status);      
                        }

                       _NFMdebug ((fname, "File Name = <%s>",
                       filename1));

                       strcat (sql_str, filename1);
                     }
                  }
                 else
                  {
***/
                    if (! strlen (data1 [count + o3]))
                     {
                       free (sql_str);
         ERRload_struct (NFM, NFM_E_BAD_FILE_NAME, "", NULL);
                       _NFMdebug
                       ((fname, "No COF Name : status = <0x%.8x>\n",
                       NFM_E_BAD_FILE_NAME));
                       return (NFM_E_BAD_FILE_NAME);      
                     }
                    else
                       strcat (sql_str, data1 [count + o3]);
/***
                  }
***/
               }
              else if (! strcmp (column2 [y], "n_cifilesize"))
                strcat (sql_str, "-1");
              else if (! strcmp (column2 [y], "n_filetype"))
                strcat (sql_str, file_type);
 
              strcat (sql_str, "\1");
            }

           status = MEMwrite (file_list, sql_str);
           if (status != MEM_S_SUCCESS)
            {
              free (sql_str);
         ERRload_struct (NFM, NFM_E_MEM, "", NULL);
              _NFMdebug ((fname, "MEM Write : status = <0x%.8x>\n",
			  status));
              return (NFM_E_MEM);      
            }           
         }
      }

     free (sql_str);
     
     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);    
   }

 long NFMmake_file_cat_entry (user_id, cat_name, item_no,
                              item_ver, file_no)
   long      user_id;
   char      *cat_name;
   long      item_no, item_ver;
   long      *file_no;
   {
     char *fname = "NFMmake_file_cat_entry" ;
     long     status;
     char     file_cat [100];
     MEMptr   attr_list = NULL;
     char     **column, **data;
     long     x, count, comma;
     char     *sql_str, sql_str1 [1024], value [50];

     *file_no = 0;

     _NFMdebug ((fname, "Cat  Name = <%s>  : Item No = <%d> : Item Ver = <%d> : File No <%d>\n",
		 cat_name, item_no, item_ver, *file_no));

     sprintf (file_cat, "f_%s", cat_name);

     status = NFMquery_attributes_definition (user_id,
              "F_CATALOG", file_cat, &attr_list);
     if (status != NFM_S_SUCCESS)
      {
        MEMclose (&attr_list);
        _NFMdebug ((fname, "Qry Tab Attr : status = <0x%.8x>\n",
        status));
        return (status);
      }

     status = MEMbuild_array (attr_list);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (&attr_list);
         ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
		    status));
        return (NFM_E_MEM);
      }

     column = (char **) attr_list -> column_ptr;
     data   = (char **) attr_list -> data_ptr;

     sql_str = (char *) malloc (2 * MEM_SIZE * attr_list -> rows * 50);
     if (! sql_str)
      {
        MEMclose (&attr_list);
         ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
        _NFMdebug ((fname, "Malloc Failed : status = <0x%.8x>\n",
		    status));
        return (NFM_E_MALLOC);
      }

     sprintf (sql_str, "INSERT INTO f_%s (", cat_name);
     sprintf (sql_str1, ") VALUES (");

     comma = 0;

     for (x = 0; x < attr_list -> rows; ++x)
      {
        count = attr_list -> columns * x;

        if (! strcmp (data [count + 2], "n_fileno"))
         {
           if (comma) 
            {
              strcat (sql_str, ", ");
              strcat (sql_str1, ", ");
            }

           comma = 1;

/**
           status = NFMget_serial_slot (user_id, file_cat,
                    data [count], file_no);
**/
/***
           sprintf (sql_str2, " WHERE n_itemnum = %d",
                    item_no);
***/
           status = NFMget_attr_value (user_id, file_cat, "MAX(n_fileno)",
                    "", value);
           
           if (status != NFM_S_SUCCESS)
            {
              free (sql_str);
              MEMclose (&attr_list);
              _NFMdebug ((fname, "Get Ser Slot : status = <0x%.8x>\n",
              status));
              return (status);
            }

/***
           sprintf (value, "%d", *file_no);
***/
           *file_no = atol (value);
           ++ (*file_no);
           sprintf (value, "%d", *file_no);
           _NFMdebug ((fname, "char value of fileno = <%s>  ", value));
           _NFMdebug ((fname, "int value of fileno = <%d>  ", *file_no));

           strcat (sql_str, data [count]);

           if (! strncmp (data [count + 1], "char", 4))
            {
               strcat (sql_str1, "'");
               strcat (sql_str1, value);
               strcat (sql_str1, "'");
            }
           else
               strcat (sql_str1, value); 
         }
        else if (! strcmp (data [count + 2], "n_itemnum"))
         {
           if (comma) 
            {
              strcat (sql_str, ", ");
              strcat (sql_str1, ", ");
            }

           comma = 1;

           strcat (sql_str, data [count]);

           sprintf (value, "%d", item_no);

           if (! strncmp (data [count + 1], "char", 4))
            {
               strcat (sql_str1, "'");
               strcat (sql_str1, value);
               strcat (sql_str1, "'");
            }
           else
               strcat (sql_str1, value); 
         }        
        else if (! strcmp (data [count + 2], "n_fileversion"))
         {
           if (comma) 
            {
              strcat (sql_str, ", ");
              strcat (sql_str1, ", ");
            }

           comma = 1;

           strcat (sql_str, data [count]);

           sprintf (value, "%d", item_ver);

           if (! strncmp (data [count + 1], "char", 4))
            {
               strcat (sql_str1, "'");
               strcat (sql_str1, value);
               strcat (sql_str1, "'");
            }
           else
               strcat (sql_str1, value); 
         }
      }

     strcat (sql_str, sql_str1);
     strcat (sql_str, ")");

     status = SQLstmt (sql_str);
     if (status != SQL_S_SUCCESS)
      {
        free (sql_str);
        MEMclose (&attr_list);
         ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
        _NFMdebug ((fname, "SQL Query Failed : status = <0x%.8x>\n",
		    status));
        return (NFM_E_SQL_STMT);       
      }

     free (sql_str);

     status = MEMclose (&attr_list);
     if (status != MEM_S_SUCCESS)
      {
         ERRload_struct (NFM, NFM_E_MEM, "", NULL);
         _NFMdebug ((fname, "MEM Close : status = <0x%.8x>\n", status));
         return (NFM_E_MEM);
      } 

     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);    
   }

 long NFMupdate_ci_file_cat (user_id, c_user, c_date, c_time, sa_no,
                             i_row, f_row, cat_name, item_no,
                             attr_list, data_list, file_list)
   long      user_id;
   char      *c_user, *c_date, *c_time;
   long      sa_no, i_row, f_row;
   char      *cat_name;
   long      item_no;
   MEMptr    attr_list, data_list, file_list;
   {
     char *fname = "NFMupdate_ci_file_cat" ;
     long     status;
     char     file_cat [100];
     char     **column, **data, **data1;
     char     **column2, **data2;
     char     **column3, **data3;
     long     a, b, d, x, y, z;
     long     count, count1, count2, count3;
     long     i, j, k ;
     MEMptr   list = NULL;
     char     *sql_str, sql_str1 [1024], value [50];
     char     sql_str2 [1024], sql_str3 [1024];
     long     update, update1, comma, found;

     _NFMdebug ((fname, "User       = <%s> : Date = <%s> : Time = <%s> : Sa No = <%d> : Init Row = <%d> : Final Row = <%d> : Cat Name = <%s> : Item No = <%d> \n",
		 c_user, c_date, c_time, sa_no, i_row, f_row, cat_name,
		 item_no)) ;

     sprintf (file_cat, "f_%s", cat_name);

     status = MEMbuild_array (file_list);
     if (status != MEM_S_SUCCESS)
      {
         ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
		    status));
        return (NFM_E_MEM);
      }

     column = (char **) attr_list -> column_ptr;
     data   = (char **) attr_list -> data_ptr;

     data1   = (char **) data_list -> data_ptr;

     column2 = (char **) file_list -> column_ptr;
     data2   = (char **) file_list -> data_ptr;

     a = -1; b = -1; d = -1;

     for (y = 0; y < attr_list -> columns; ++y)
      {
             if (! strcmp (column [y], "n_name"))          a = y;
        else if (! strcmp (column [y], "n_datatype"))      b = y;
        else if (! strcmp (column [y], "n_application"))   d = y;
      }

     i = -1; j = -1; k = -1;

     for (y = 0; y < file_list -> columns; ++y)
      {
             if (! strcmp (column2 [y], "n_fileno"))      i = y;
        else if (! strcmp (column2 [y], "n_cifilesize"))  j = y;
        else if (! strcmp (column2 [y], "n_status1"))      k = y;
      }

     status = NFMquery_attributes_definition (user_id, "F_CATALOG",
              file_cat, &list);
     if (status != NFM_S_SUCCESS)
      {
        MEMclose (&list);
        _NFMdebug ((fname, "Qry Cat Attr : status = <0x%.8x>\n", status));
        return (status);
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

     column3 = (char **) list -> column_ptr;
     data3   = (char **) list -> data_ptr;

     sql_str = (char *) malloc (data_list -> row_size +
                                attr_list -> rows * 50 + MEM_SIZE);     
     if (! sql_str)
      {
        MEMclose (&list);
         ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
        _NFMdebug ((fname, "Malloc Failed\n")) ;
        return (NFM_E_MALLOC);
      }

     status = NFMstop_transaction (0);
     if (status != NFM_S_SUCCESS)
     {
        MEMclose (&list);
        ERRload_struct (NFM, NFM_E_FAILURE, "", NULL);
        _NFMdebug ((fname, "Malloc Failed\n")) ;
        return (NFM_E_FAILURE);
      }

     for (x = i_row; x < f_row; ++x)
      {
        count1 = data_list -> columns * x;
        count2 = file_list -> columns * x;

        update1 = 0; comma = 0;

        sql_str  [0] = 0; sql_str1 [0] = 0;
        sql_str2 [0] = 0; sql_str3 [0] = 0;

        sprintf (sql_str,  "UPDATE %s SET ", file_cat);
        sprintf (sql_str1, " WHERE ");

        sprintf (sql_str2,  "UPDATE %s SET ", file_cat);
        sprintf (sql_str3, " WHERE ");

        if ((! strcmp (data2 [count2 + k], "move"))   ||
            (! strcmp (data2 [count2 + k], "copy"))   ||
            (! strcmp (data2 [count2 + k], "delete")) ||
            (! strcmp (data2 [count2 + k], "none")))
         {
           for (y = 0; y < attr_list -> rows; ++y)
            {
              count = attr_list -> columns * y;
              update = 0; found = 0;

              for (z = 0; ((z < list -> rows) && (! found)); ++z)
               {
                 count3 = list -> columns * z;
                 found = 0;
   
                 if ((! strcmp (data [count + a], data3 [count3 + 2])) &&
                     (! strcmp (data [count + d], "NFM")))
                  {
                    found = 1;

                    if (! strcmp (data [count + a], "n_fileno"))
                     {
                       strcat (sql_str1, data3 [count3]);
                       strcat (sql_str1, " = ");

                       if (! strncmp (data3 [count3 + 1], "char", 4))
                        {
                          strcat (sql_str1, "'");
                          strcat (sql_str1, data2 [count2 + i]);
                          strcat (sql_str1, "'");
                        }
                       else
                          strcat (sql_str1, data2 [count2 + i]);

                       strcat (sql_str3, data3 [count3]);
                       strcat (sql_str3, " = ");

                       if (! strncmp (data3 [count3 + 1], "char", 4))
                        {
                          strcat (sql_str3, "'");
                          strcat (sql_str3, data1 [count1 + y]);
                          strcat (sql_str3, "'");
                        }
                       else
                          strcat (sql_str3, data1 [count1 + y]);
                     }
                    else if (! strcmp (data [count + a], "n_ciuser"))
                     {
                       sprintf (value, "%s", c_user);
                       update = 1;
                     }
                    else if (! strcmp (data [count + a], "n_cidate"))
                     {
                       sprintf (value, "%s", c_date);
                       update = 1;
                     }
                    else if (! strcmp (data [count + a], "n_citime"))
                     {
                       sprintf (value, "%s", c_time);
                       update = 1;
                     }
                    else if (! strcmp (data [count + a], "n_cisano"))
                     {
                       sprintf (value, "%s", data1 [count1 + y]);
                       update = 1;
                     }
                    else if (! strcmp (data [count + a], "n_cosano"))
                     {
                       sprintf (value, "%d", sa_no);                      
                       update = 1;
                     }
                    else if (! strcmp (data [count + a], "n_cifilename"))
                     {
                       sprintf (value, "%s", data1 [count1 + y]);
                       update = 1;
                     }
                    else if (! strcmp (data [count + a], "n_cofilename"))
                     {
                       sprintf (value, "%s", data1 [count1 + y]);
                       update = 1;
                     }
                    else if (! strcmp (data [count + a], "n_cifilesize"))
                     {
                       sprintf (value, "%s", data2 [count2 + j]);
                       update = 1;
                     }
                    else if (! strcmp (data [count + a], "n_fileco"))
                     {
                       sprintf (value, "%s", "");
                       update = 1;

                       if (! strcmp (data1 [count1 + y], "Y"))
                        {
                          update1 = 1;

                          strcat (sql_str2, data3 [count3]);
                          strcat (sql_str2, " = ");
   
                          if (! strncmp (data3 [count3 + 1], "char", 4))
                           {
                             strcat (sql_str2, "'");
                             strcat (sql_str2, "'");
                           }
                          else
                             strcat (sql_str2, "null");
                        }
                     }
                    else if (! strcmp (data [count + a], "n_filetype"))
                     {
                       sprintf (value, "%s", data1 [count1 + y]);
                       update = 1;
                     }
                    else if (! strcmp (data [count + a], "n_fileclass"))
                     {
                       sprintf (value, "%s", "C");
                       update = 1;
                     }
                  }
               }

              if (update)
               {
                 if (comma) strcat (sql_str, ", ");
                 comma = 1;

                 strcat (sql_str, data3 [count3]);
                 strcat (sql_str, " = ");
   
                 if (! strncmp (data3 [count3 + 1], "char", 4))
                  {
                    strcat (sql_str, "'");
                    strcat (sql_str, value);
                    strcat (sql_str, "'");
                  }
                 else
                  {
                    if (! strlen (value)) strcat (sql_str, "null");
                    else                  strcat (sql_str, value);
                  }
               }
            }

           if ((! strcmp (data2 [count2 + k], "move")) ||
               (! strcmp (data2 [count2 + k], "copy")))
            {
              strcat (sql_str, sql_str1);

              status = NFMlock_table (file_cat);
              if (status != NFM_S_SUCCESS)
               {
                 free (sql_str);
                 ERRload_struct (NFM, NFM_E_FAILURE, "", NULL);
                 _NFMdebug ((fname, "Stmt Failed : status = <0x%.8x>\n",
                 NFM_E_FAILURE));
                 return (NFM_E_FAILURE);
               }
 
              status = SQLstmt (sql_str);
              if (status != SQL_S_SUCCESS)
               {
                 free (sql_str);
         ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
                 _NFMdebug ((fname, "Stmt Failed : status = <0x%.8x>\n",
			     status));
                 return (NFM_E_SQL_STMT);
               }
              status = SQLstmt ("COMMIT WORK");
              if (status != SQL_S_SUCCESS)
               {
                 free (sql_str);
                  ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
                 _NFMdebug ((fname, "Stmt Failed : status = <0x%.8x>\n",
			     status));
                 return (NFM_E_SQL_STMT);
               }
            
            }

           if (update1)
            {
              strcat (sql_str2, sql_str3);

              status = NFMlock_table (file_cat);
              if (status != NFM_S_SUCCESS)
               {
                 free (sql_str);
                 ERRload_struct (NFM, NFM_E_FAILURE, "", NULL);
                 _NFMdebug ((fname, "Stmt Failed : status = <0x%.8x>\n",
                 NFM_E_FAILURE));
                 return (NFM_E_FAILURE);
               }

              status = SQLstmt (sql_str2);
              if (status != SQL_S_SUCCESS)
               {
                 free (sql_str);
         ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
                 _NFMdebug ((fname, "SQL Stmt : status = <0x%.8x>\n",
			     status));
                 return (NFM_E_SQL_STMT);
               }
              status = SQLstmt ("COMMIT WORK");
              if (status != SQL_S_SUCCESS)
               {
                 free (sql_str);
                 ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
                 _NFMdebug ((fname, "Stmt Failed : status = <0x%.8x>\n",
			     status));
                 return (NFM_E_SQL_STMT);
               }

            }
         }
      }
     status = NFMstart_transaction (0);
     if (status != NFM_S_SUCCESS)
     {
        MEMclose (&list);
        ERRload_struct (NFM, NFM_E_FAILURE, "", NULL);
        _NFMdebug ((fname, "Malloc Failed\n")) ;
        return (NFM_E_FAILURE);
      }


     status = MEMclose (&list);
     if (status != MEM_S_SUCCESS)
      {
        free (sql_str);
        MEMclose (&list);
        _NFMdebug ((fname, "Qry Cat Attr : status = <0x%.8x>\n", status));
        return (status);
      }

     status = NFMquery_attributes_definition (user_id, "CATALOG",
              cat_name, &list);
     if (status != NFM_S_SUCCESS)
      {
        free (sql_str);
        MEMclose (&list);
        _NFMdebug ((fname, "Qry Cat Attr : status = <0x%.8x>\n", status));
        return (status);
      }
 
     status = MEMbuild_array (list);
/*     if (status != NFM_S_SUCCESS)  DUR 1/5/91 */
     if (status != MEM_S_SUCCESS)
      {
        free (sql_str);
        MEMclose (&list);
         ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
		    status));
        return (NFM_E_MEM);
      }

     column3 = (char **) list -> column_ptr;
     data3   = (char **) list -> data_ptr;

     status = NFMstop_transaction (0);
     if (status != NFM_S_SUCCESS)
     {
        MEMclose (&list);
        ERRload_struct (NFM, NFM_E_FAILURE, "", NULL);
        _NFMdebug ((fname, "Malloc Failed : status = <0x%.8x>\n", 
        NFM_E_FAILURE));
        return (NFM_E_FAILURE);
      }
     for (x = i_row; x < i_row + 1; ++x)
      {
        count1 = data_list -> columns * x;
        count2 = file_list -> columns * x;
 
        update1 = 0; comma = 0;
  
        sql_str  [0] = 0; sql_str1 [0] = 0;

        sprintf (sql_str,  "UPDATE %s SET ", cat_name);
        sprintf (sql_str1, " WHERE ");

        for (y = 0; y < attr_list -> rows; ++y)
         {
           count = attr_list -> columns * y;

           found = 0;

           for (z = 0; ((z < list -> rows) && (! found)); ++z)
            {
              count3 = list -> columns * z;

              if (! strcmp (data [count + d], "NFM"))
               {
                 if (! strcmp (data [count + a], data3 [count3 + 2]))
                  {
                    found = 1;

                    if (! strcmp (data [count + a], "n_itemno"))
                     {
                       strcat (sql_str1, data3 [count3]);
                       strcat (sql_str1, " = ");
    
                       if (! strncmp (data3 [count3 + 1], "char", 4))
                        {
                          strcat (sql_str1, "'");
                          strcat (sql_str1, data1 [count1 + y]);
                          strcat (sql_str1, "'");
                        }
                       else
                          strcat (sql_str1, data1 [count1 + y]);
                     }
                    else if (! strcmp (data [count + a], "n_status")) 
		             /* n_coout */
                     {
                       if (comma) strcat (sql_str, ", ");
                       comma = 1;
   
                       strcat (sql_str, data3 [count3]);
                       strcat (sql_str, " = ");
    
                       if (! strncmp (data3 [count3 + 1], "char", 4))
                        {
                          strcat (sql_str, "'");
   
                          if ((! strcmp (data1 [count1 + y], "SN")) ||
                              (! strcmp (data1 [count1 + y], "MN")))
                            strcat (sql_str, "");
                          else
                            strcat (sql_str, "I");
   
                          strcat (sql_str, "'");
                        }
                       else
                        {
                          if ((! strcmp (data1 [count1 + y], "SN")) ||
                              (! strcmp (data1 [count1 + y], "MN")))
                            strcat (sql_str, "%s", "");
                          else
                            strcat (sql_str, "%s", "I");
                        }
                     }
                    else if (! strcmp (data [count + a], "n_colevel"))
                     {
                       if (comma) strcat (sql_str, ", ");
                       comma = 1;
   
                       strcat (sql_str, data3 [count3]);
                       strcat (sql_str, " = ");
    
                       if (! strncmp (data3 [count3 + 1], "char", 4))
                        {
                          strcat (sql_str, "'");
                          strcat (sql_str, "");
                          strcat (sql_str, "'");
                        }
                       else
                          strcat (sql_str, "null");
                     }
                  }
               }
              else
               {
                 if (! strcmp (data3 [count3], data [count + a]))
                  {
                    found = 1;

                    if (comma) strcat (sql_str, ", ");
                    comma = 1;

                    strcat (sql_str, data3 [count3]);
                    strcat (sql_str, " = ");
   
                    if (! strncmp (data3 [count3 + 1], "char", 4))
                     {
                       strcat (sql_str, "'");
                       strcat (sql_str, data1 [count1 + y]);
                       strcat (sql_str, "'");
                     }
                    else
                     {
                       if (! strlen (data1 [count1 + y]))
                         strcat (sql_str, "null");
                       else
                         strcat (sql_str, data1 [count1 + y]);
                     }
                  }
               }
            }
         }

        strcat (sql_str, sql_str1);


              status = NFMlock_table (cat_name);
              if (status != NFM_S_SUCCESS)
               {
                 free (sql_str);
                 ERRload_struct (NFM, NFM_E_FAILURE, "", NULL);
                 _NFMdebug ((fname, "Stmt Failed : status = <0x%.8x>\n",
                 NFM_E_FAILURE));
                 return (NFM_E_FAILURE);
               }

        status = SQLstmt (sql_str);
        if (status != SQL_S_SUCCESS)
         {
            free (sql_str);
         ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
            _NFMdebug ((fname, "SQL Stmt Failed : status = <0x%.8x>\n",
			status));
            return (NFM_E_SQL_STMT);
         }
              status = SQLstmt ("COMMIT WORK");
              if (status != SQL_S_SUCCESS)
               {
                 free (sql_str);
                 ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
                 _NFMdebug ((fname, "Stmt Failed : status = <0x%.8x>\n",
			     status));
                 return (NFM_E_SQL_STMT);
               }

      }
     status = NFMstart_transaction (0);
     if (status != NFM_S_SUCCESS)
     {
        MEMclose (&list);
        ERRload_struct (NFM, NFM_E_FAILURE, "", NULL);
        _NFMdebug ((fname, "Malloc Failed\n")) ;
        return (NFM_E_FAILURE);
      }

     free (sql_str);

     status = MEMclose (&list);
     if (status != MEM_S_SUCCESS)
      {
         ERRload_struct (NFM, NFM_E_MEM, "", NULL);
         _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
		     status));
         return (NFM_E_MEM);
      }
 
     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);
   }

 long NFMcheck_in_user (user_id, attr_list, data_list)
  long    user_id;
  MEMptr  attr_list, data_list;
  {
    char *fname = "NFMcheck_in_user" ;
    long     status;
    char     **column, **data, **data1;
    char     user_name [100];
    long     x, y, count, i, j, a;

    _NFMdebug ((fname, "ENTER\n")) ;
    user_id = user_id ;
    strcpy (user_name, NFMglobal.NFMusername) ;

    status = MEMbuild_array (attr_list);
    if (status != MEM_S_SUCCESS)
     {
         ERRload_struct (NFM, NFM_E_MEM, "", NULL);
       _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
		   status));
       return (NFM_E_MEM);       
     }

    status = MEMbuild_array (data_list);
    if (status != MEM_S_SUCCESS)
     {
         ERRload_struct (NFM, NFM_E_MEM, "", NULL);
       _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
		   status));
       return (NFM_E_MEM);       
     }
    column = (char **) attr_list -> column_ptr;
    data   = (char **) attr_list -> data_ptr;

    data1  = (char **) data_list -> data_ptr;

    a = -1;

    for (y = 0; y < attr_list -> columns; ++y)
      if (! strcmp (column [y], "n_name"))   a = y;


    i = -1; j = -1;

    for (x = 0; x < attr_list -> rows; ++x)
     {
       count = attr_list -> columns * x;

            if (! strcmp (data [count + a], "n_couser"))   i = x;
      else if (! strcmp (data [count + a], "n_fileco"))   j = x;  

     }

    for (x = 0; x < data_list -> rows; ++x)
     {
       count = data_list -> columns * x;

       _NFMdebug ((fname, "Co Stat = <%s> : Co User = <%s> : User = <%s>\n", 
		   data1 [count + j], data1[count+i], user_name));

       if (! strcmp (data1 [count + j], "Y"))
        {
          if (strcmp (data1 [count + i], user_name))
           {
         ERRload_struct (NFM, NFM_E_NOT_CO_USER, "", NULL);
              _NFMdebug ((fname, "Not CO Out User : status = <0x%.8x>\n",
              NFM_E_NOT_CO_USER));
              return (NFM_E_NOT_CO_USER);
           }
        }
     }

    _NFMdebug ((fname, "SUCCESSFUL\n")) ;
    return (NFM_S_SUCCESS);     
  }

 long NFMquery_co_attributes (user_id, cat_name, attr_list, data_list)
   long     user_id;
   char     *cat_name;
   MEMptr   *attr_list, *data_list;
   {
     char *fname = "NFMquery_co_attributes" ;
     long     status;
     char     **column, **data;
     long     a, b, x, y, count;
     char     *cat_str, *lvl_str, *row_str;
     char     *sts_str, *typ_str;
     char     sql_str [2048];
     char     file_cat [100];
     long     tab_no1, tab_no2;
     char     data_type [50];

     _NFMdebug ((fname, "Cat  Name = <%s>\n", cat_name));

     status = NFMquery_table_template (user_id, attr_list);
     if (status != NFM_S_SUCCESS)
      {
        MEMclose (attr_list);
        _NFMdebug ((fname, "Qry Tab Temp : status = <0x%.8x>\n", status));
        return (status);
      }

     status = MEMbuild_array (*attr_list);
     if (status != MEM_S_SUCCESS)
      {
         MEMclose (attr_list);
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
         _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n", status));
         return (NFM_E_MEM);        
      }

     cat_str = (char *) malloc ((*attr_list) -> row_size);
     if (! sql_str)
      {
         MEMclose (attr_list);
        ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
         _NFMdebug ((fname, "Malloc Failed\n")) ;
         return (NFM_E_MALLOC);        
      }

     lvl_str = (char *) malloc ((*attr_list) -> row_size);
     if (! sql_str)
      {
         free (cat_str);
         MEMclose (attr_list);
        ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
         _NFMdebug ((fname, "Malloc Failed \n")) ;
         return (NFM_E_MALLOC);        
      }

     row_str = (char *) malloc ((*attr_list) -> row_size);
     if (! sql_str)
      {
         free (cat_str);
         free (lvl_str);
         MEMclose (attr_list);
        ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
         _NFMdebug ((fname, "Malloc Failed\n")) ;
         return (NFM_E_MALLOC);        
      }

     typ_str = (char *) malloc ((*attr_list) -> row_size);
     if (! sql_str)
      {
         free (cat_str);
         free (lvl_str);
         free (row_str);
         MEMclose (attr_list);
        ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
         _NFMdebug ((fname, "Malloc Failed\n")) ;
         return (NFM_E_MALLOC);        
      }

     sts_str = (char *) malloc ((*attr_list) -> row_size);
     if (! sql_str)
      {
         free (cat_str);
         free (lvl_str);
         free (row_str);
         free (typ_str);
         MEMclose (attr_list);
        ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
         _NFMdebug ((fname, "Malloc Failed\n")) ;
         return (NFM_E_MALLOC);        
      }

     cat_str [0] = 0; lvl_str [0] = 0; row_str [0] = 0;
     typ_str [0] = 0; sts_str [0] = 0;

     column = (char **) (*attr_list) -> column_ptr;

     for (y = 0; y < (*attr_list) -> columns; ++y)
      {
        if (! strcmp (column [y], "n_name"))
         {
           strcat (cat_str, "n_catalogname");
           strcat (lvl_str, "n_level");
           strcat (row_str, "n_citno");
           strcat (sts_str, "n_status1");
           strcat (typ_str, "n_type");
         }
        else if (! strcmp (column [y], "n_datatype"))
         {
           strcat (cat_str, "char(20)");  strcat (lvl_str, "integer");
           strcat (row_str, "integer");   strcat (sts_str, "char(10)");
           strcat (typ_str, "char(1)");
         }
        else if (! strcmp (column [y], "n_synonym")) 
         {
           strcat (cat_str, "Catalog Name");  strcat (lvl_str, "Level");
           strcat (row_str, "Row No");       strcat (sts_str, "Status");
           strcat (typ_str, "MEM Type");
         }
        else if (! strcmp (column [y], "n_opentonfm"))
         {
           strcat (cat_str, "N");   strcat (lvl_str, "N");
           strcat (row_str, "N");   strcat (sts_str, "N");
           strcat (typ_str, "N");
         }
        else if (! strcmp (column [y], "n_application"))
         {
           strcat (cat_str, "NFM");   strcat (lvl_str, "NFM");
           strcat (row_str, "NFM");   strcat (sts_str, "NFM");
           strcat (typ_str, "NFM");
         }
        else if (! strcmp (column [y], "n_read"))
         {
           strcat (cat_str, "Y");   strcat (lvl_str, "N");
           strcat (row_str, "N");   strcat (sts_str, "N");
           strcat (typ_str, "Y");
         }
        else if (! strcmp (column [y], "n_write"))
         {
           strcat (cat_str, "N");   strcat (lvl_str, "N");
           strcat (row_str, "N");   strcat (sts_str, "N");
           strcat (typ_str, "N");
         }
        else if (! strcmp (column [y], "n_update"))
         {
           strcat (cat_str, "N");   strcat (lvl_str, "N");
           strcat (row_str, "N");   strcat (sts_str, "N");
           strcat (typ_str, "N");
         }
        else if (! strcmp (column [y], "n_delete"))
         {
           strcat (cat_str, "N");   strcat (lvl_str, "N");
           strcat (row_str, "N");   strcat (sts_str, "N");
           strcat (typ_str, "N");
         }
        else if (! strcmp (column [y], "n_null"))
         {
           strcat (cat_str, "N");   strcat (lvl_str, "N");
           strcat (row_str, "N");   strcat (sts_str, "N");
           strcat (typ_str, "N");
         }
        else if (! strcmp (column [y], "n_keyin"))
         {
           strcat (cat_str, "0");   strcat (lvl_str, "0");
           strcat (row_str, "0");   strcat (sts_str, "0");
           strcat (typ_str, "0");
         }
        else if (! strcmp (column [y], "n_checkin"))
         {
           strcat (cat_str, "N");   strcat (lvl_str, "N");
           strcat (row_str, "N");   strcat (sts_str, "N");
           strcat (typ_str, "N");
         }
        else if (! strcmp (column [y], "n_checkout"))
         {
           strcat (cat_str, "N");   strcat (lvl_str, "N");
           strcat (row_str, "N");   strcat (sts_str, "N");
           strcat (typ_str, "N");
         }
        else if (! strcmp (column [y], "n_seqno"))
         {
           strcat (cat_str, "0");   strcat (lvl_str, "0");
           strcat (row_str, "0");   strcat (sts_str, "0");
           strcat (typ_str, "0");
         }
        else if (! strcmp (column [y], "n_listno"))
         {
           strcat (cat_str, "0");   strcat (lvl_str, "0");
           strcat (row_str, "0");   strcat (sts_str, "0");
           strcat (typ_str, "0");
         }
         
        strcat (cat_str, "\1");     strcat (lvl_str, "\1");
        strcat (row_str, "\1");     strcat (sts_str, "\1");
        strcat (typ_str, "\1");
      }

     status = MEMwrite (*attr_list, sts_str);
     if (status != MEM_S_SUCCESS)
      {
        free (cat_str);   free (lvl_str);
        free (row_str);   free (sts_str);
        free (typ_str);
        MEMclose (attr_list);
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Write : status = <0x%.8x>\n", status));
        return (NFM_E_MEM);
      }

     status = MEMwrite (*attr_list, lvl_str);
     if (status != MEM_S_SUCCESS)
      {
        free (cat_str);   free (lvl_str);
        free (row_str);   free (sts_str);
        free (typ_str);
        MEMclose (attr_list);
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Write : status = <0x%.8x>\n", status));
        return (NFM_E_MEM);
      }

     status = MEMwrite (*attr_list, row_str);
     if (status != MEM_S_SUCCESS)
      {
        free (cat_str);   free (lvl_str);
        free (row_str);   free (sts_str);
        free (typ_str);
        MEMclose (attr_list);
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Write : status = <0x%.8x>\n", status));
        return (NFM_E_MEM);
      }

     status = MEMwrite (*attr_list, cat_str);
     if (status != MEM_S_SUCCESS)
      {
        free (cat_str);   free (lvl_str);
        free (row_str);   free (sts_str);
        free (typ_str);
        MEMclose (attr_list);
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Write : status = <0x%.8x>\n", status)) ;
        return (NFM_E_MEM);
      }

     status = MEMwrite (*attr_list, typ_str);
     if (status != MEM_S_SUCCESS)
      {
        free (cat_str);   free (lvl_str);
        free (row_str);   free (sts_str);
        free (typ_str);
        MEMclose (attr_list);
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Write : status = <0x%.8x>\n", status));
        return (NFM_E_MEM);
      }

     free (cat_str);   free (lvl_str);
     free (row_str);   free (sts_str);
     free (typ_str);

     status = NFMget_table_no (user_id, "CATALOG", cat_name, &tab_no1);
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "Get Table No : status = <0x%.8x>\n", status));
        return (status);
      }

     sprintf (file_cat, "f_%s", cat_name);

     status = NFMget_table_no (user_id, "F_CATALOG", file_cat, &tab_no2);
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "Get Table No : status = <0x%.8x>\n", status));
        return (status);
      }
     
     sprintf (sql_str,
     " (n_tableno = %d OR n_tableno = %d) AND (%s = 'Y' OR %s = 'U')",
     tab_no1, tab_no2, "n_checkout", "n_checkout");

     status = NFMquery_condition_definition (user_id, "", "", sql_str, "",
              attr_list);
     if (status != NFM_S_SUCCESS)
      {
         MEMclose (attr_list);
         _NFMdebug ((fname, "Cond Attr : status = <0x%.8x>\n", status));
         return (status);
      }

     status = MEMbuild_array (*attr_list);
     if (status != MEM_S_SUCCESS)
      {
         MEMclose (attr_list);
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
         _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
		     status));
         return (NFM_E_MEM);        
      }

     column = (char **) (*attr_list) -> column_ptr;
     data   = (char **) (*attr_list) -> data_ptr;

     a = -1; b = -1;

     for (y = 0; y < (*attr_list) -> columns; ++y)
      {
             if (! strcmp (column [y], "n_name"))      a = y;
        else if (! strcmp (column [y], "n_datatype"))  b = y;
      }

     if (! strcmp (cat_name, "catalog"))
      {
        for (x = 0; x < (*attr_list) -> rows; ++x)
         {
           count = (*attr_list) -> columns * x;           
 
           if ((! strcmp (data [count + a], "n_itemname")) ||
               (! strcmp (data [count + a], "n_itemrev")))
            {
              status = NFMget_max_attr_size (user_id, data [count + a],
                       data_type);
              if (status != NFM_S_SUCCESS)
               {
                 MEMclose (attr_list);
                 _NFMdebug ((fname, "Max Size : status = <0x%.8x>\n",
                 status));
                 return (status);        
               }

              status = MEMwrite_data (*attr_list, data_type,
                       x + 1, b + 1);
              if (status != MEM_S_SUCCESS)
               {
                 MEMclose (attr_list);
                 _NFMdebug ((fname, "Max Size : status = <0x%.8x>\n",
                 status));
                 return (NFM_E_MEM);        
               }
            }
         }
      }

     status = MEMopen (data_list, 2 * MEM_SIZE);
     if (status != MEM_S_SUCCESS)
      {
         MEMclose (attr_list);
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
         _NFMdebug ((fname, "MEM Open Failed : status = <0x%.8x>\n",
		     status));
         return (NFM_E_MEM);        
      }

     for (x = 0; x < (*attr_list) -> rows; ++x)
      {
        count = (*attr_list) -> columns * x;

        status = MEMwrite_format (*data_list,
                 data [count + a], data [count + b]);
        if (status != MEM_S_SUCCESS)
         {
            MEMclose (attr_list);
            MEMclose (data_list);
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
            _NFMdebug ((fname, "MEM Write Format : status = <0x%.8x>\n",
			status));
            return (NFM_E_MEM);        
         }
      }
          
     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);
   }

 long NFMget_item_co_list (user_id, cat_name, item_no,
                           ctype, level, row_id, attr_list, data_list,
                           type)
   long     user_id;
   char     *cat_name;
   long     item_no;
   char     *ctype, *level, *row_id;
   MEMptr   attr_list, data_list;
   long     type;
   {
     char *fname = "NFMget_item_co_list" ;
     long    status;
     char    file_cat [100];
     long    a, b, d, y, x, z, count;
     long    count1, comma, found;
     long    i, j, k, l;
     char    **column, **data, **data1, **data2;
     char    *sql_str, sql_str1 [1024];
     MEMptr  cat_list = NULL, file_list = NULL;
     char    attr [50], value [50];
     MEMptr  list = NULL;

     _NFMdebug ((fname, "Cat  Name = <%s> : Item No <%d> : C Type <%s> : Level <%s> : Row Id <%s> : Type <%d>\n", 
		 cat_name, item_no, ctype, level, row_id, type));

     sprintf (file_cat, "f_%s", cat_name);

     status = MEMbuild_array (attr_list);
     if (status != MEM_S_SUCCESS)
      {
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
         _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n", 
		     status)) ;
         return (NFM_E_MEM);
      }

     column = (char **) attr_list -> column_ptr;
     data   = (char **) attr_list -> data_ptr;

     a = -1; b = -1; d = -1;

     for (y = 0; y < attr_list -> columns; ++y)
      {
             if (! strcmp (column [y], "n_name"))          a = y;
        else if (! strcmp (column [y], "n_datatype"))      b = y;
        else if (! strcmp (column [y], "n_application"))   d = y;
      }

     status = NFMquery_attributes_definition (user_id, "CATALOG",
              cat_name, &cat_list);
     if (status != NFM_S_SUCCESS)
      {
         MEMclose (&cat_list);
         _NFMdebug ((fname, "Query Cat Def : status = <0x%.8x>\n", status));
         return (status);
      }

     status = NFMquery_attributes_definition (user_id, "F_CATALOG",
              file_cat, &file_list);
     if (status != NFM_S_SUCCESS)
      {
         MEMclose (&cat_list);
         MEMclose (&file_list);
         _NFMdebug ((fname, "Query Cat Def : status = <0x%.8x>\n", status));
         return (status);
      }

     status = MEMbuild_array (cat_list);
     if (status != MEM_S_SUCCESS)
      {
         MEMclose (&cat_list);
         MEMclose (&file_list);
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
         _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n", status));
         return (NFM_E_MEM);
      }

     status = MEMbuild_array (file_list);
     if (status != MEM_S_SUCCESS)
      {
         MEMclose (&cat_list);
         MEMclose (&file_list);
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
         _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n", status));
         return (NFM_E_MEM);
      }

     data1 = (char **) cat_list -> data_ptr;
     data2 = (char **) file_list -> data_ptr;
     
     sql_str = (char *) malloc (attr_list -> rows * 100 + MEM_SIZE);
     if (! sql_str)
      {
         MEMclose (&cat_list);
         MEMclose (&file_list);
        ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
         _NFMdebug ((fname, "Malloc Failed\n")) ;
         return (NFM_E_MALLOC);
      }
     sql_str [0] = 0;

     sprintf (sql_str, "SELECT ");
     comma = 0;

     for (x = 5; x < attr_list -> rows; ++x)
      {
        count = attr_list -> columns * x;
        found = 0;

        for (y = 0; (y < file_list -> rows) && (! found); ++y)
         {
           count1 = file_list -> columns * y;

                if (! strcmp (data [count + a], "n_itemnum"))     j = y;
           else if (! strcmp (data [count + a], "n_fileclass"))   k = y;
           else if (! strcmp (data [count + a], "n_fileversion")) l = y;
           
           if ((! strcmp (data [count + a], data2 [count1 + 2])) &&
               (! strcmp (data [count + d], "NFM")))
            {
              if (comma) strcat (sql_str, ", ");
              comma = 1;

              strcat (sql_str, file_cat);
              strcat (sql_str, ".");
              strcat (sql_str, data2 [count1]);

              found = 1;
            }
         }

        for (y = 0; (y < cat_list -> rows) && (! found); ++y)
         {
           count1 = cat_list -> columns * y;

           if (! strcmp (data [count + a], "n_itemno"))     i = y;

           if ((! strcmp (data [count + a], data1 [count1 + 2])) &&
               (! strcmp (data [count + d], "NFM")))
            {
              if (comma) strcat (sql_str, ", ");
              comma = 1;

              strcat (sql_str, cat_name);
              strcat (sql_str, ".");
              strcat (sql_str, data1 [count1]);

              found = 1;
            }
           else if (! strcmp (data [count + a], data1 [count1]))
            {
              if (comma) strcat (sql_str, ", ");
              comma = 1;

              strcat (sql_str, cat_name);
              strcat (sql_str, ".");
              strcat (sql_str, data1 [count1]);

              found = 1;
            }
         }

        if (! found)
         {
           free (sql_str);
           MEMclose (&cat_list);
           MEMclose (&file_list);
        ERRload_struct (NFM, NFM_E_CORRUPTED_SYSTEM, "", NULL);
           _NFMdebug ((fname, "System Is Corrupted 1 : status = <0x%.8x>\n",
           NFM_E_CORRUPTED_SYSTEM));
           return (NFM_E_CORRUPTED_SYSTEM);
         }
      }

     strcat (sql_str, " FROM ");
     strcat (sql_str, cat_name);
     strcat (sql_str, ",  ");
     strcat (sql_str, file_cat);
     strcat (sql_str, " WHERE ");

                      /* modify the query to improve the performance */
     strcat (sql_str, file_cat);
     strcat (sql_str, ".");
     strcat (sql_str, data2 [(file_list -> columns * j)]);
     strcat (sql_str, " = ");

     sprintf (value, "%d", item_no);

     if (! strncmp (data2 [(file_list -> columns * j) + 1], "char", 4))
      {
         strcat (sql_str, "'");
         strcat (sql_str, value);
         strcat (sql_str, "'");
      }
     else
         strcat (sql_str, value);

     if (type)
      {
        strcat (sql_str, " AND ");
        strcat (sql_str, file_cat);
        strcat (sql_str, ".");
        strcat (sql_str, data2 [(file_list -> columns * k)]);
        strcat (sql_str, " = ");

        if (! strncmp (data2 [(file_list -> columns * k) + 1], "char", 4))
           strcat (sql_str, "'C'");
        else
           strcat (sql_str, "C");
      }

     sql_str1 [0] = 0;

     strcat (sql_str1, " WHERE ");
     strcat (sql_str1, data2 [(file_list -> columns * j)]);
     strcat (sql_str1, " = ");
            
     if (! strncmp (data2 [(file_list -> columns * j) + 1], "char", 4))
      {
         strcat (sql_str1, "'");
         strcat (sql_str1, value);
         strcat (sql_str1, "'");
      }
     else
         strcat (sql_str1, value);

     if (type)
      {
        strcat (sql_str1, " AND ");
        strcat (sql_str1, file_cat);
        strcat (sql_str1, ".");
        strcat (sql_str1, data2 [(file_list -> columns * k)]);
        strcat (sql_str1, " = ");

        if (! strncmp (data2 [(file_list -> columns * k) + 1], "char", 4))
           strcat (sql_str1, "'C'");
        else
           strcat (sql_str1, "C");
      }

     sprintf (attr, "MAX(%s)", data2 [(file_list -> columns * l)]);

     status = NFMget_attr_value (user_id, file_cat,
              attr, sql_str1, value);
     if (status != NFM_S_SUCCESS)
      {
        free (sql_str);
        MEMclose (&cat_list);
        MEMclose (&file_list);
    
        if (status == NFM_I_BAD_CONDITION)
         {
        ERRload_struct (NFM, NFM_E_BAD_FILE, "", NULL);
           _NFMdebug ((fname, "No Such File : status = <0x%.8x>\n", NFM_E_BAD_FILE));
           return (NFM_E_BAD_FILE);             
         }

        _NFMdebug ((fname, "Get Attr Value : status = <0x%.8x>\n", status));
        return (status);             
      }

     strcat (sql_str, " AND ");
     strcat (sql_str, file_cat);
     strcat (sql_str, ".");
     strcat (sql_str, data2 [(file_list -> columns * l)]);
     strcat (sql_str, " = ");

     if (! strncmp (data2 [(file_list -> columns * l) + 1], "char", 4))
      {
        strcat (sql_str, "'");
        strcat (sql_str, value);
        strcat (sql_str, "'");
      }
     else
        strcat (sql_str, value);

     strcat (sql_str, " AND ");
     strcat (sql_str, file_cat);
     strcat (sql_str, ".");
     strcat (sql_str, data2 [(file_list -> columns * j)]);
     strcat (sql_str, " = ");
     strcat (sql_str, cat_name);
     strcat (sql_str,".");
     strcat (sql_str, data1 [(cat_list -> columns * i)]);

     status = MEMclose (&cat_list);
     if (status != MEM_S_SUCCESS)
      {
        free (sql_str);
        MEMclose (&file_list);
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Close : status = <0x%.8x>\n", status));
        return (NFM_E_MEM);       
      }

     status = MEMclose (&file_list);
     if (status != MEM_S_SUCCESS)
      {
        free (sql_str);
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Close : status = <0x%.8x>\n", status));
        return (NFM_E_MEM);       
      }

     status = SQLquery (sql_str, &list, 2 * MEM_SIZE);
     if (status != SQL_S_SUCCESS)
      {
        free (sql_str);
        MEMclose (&list);
 
        if ((status) == SQL_I_NO_ROWS_FOUND)
         {
        ERRload_struct (NFM, NFM_E_CORRUPTED_CATALOG, "", NULL);
           _NFMdebug ((fname, "Cat Entries Are Bad : status = <0x%.8x>\n",
           NFM_E_CORRUPTED_CATALOG));
           return (NFM_E_CORRUPTED_CATALOG);
         }

        ERRload_struct (NFM,  NFM_E_SQL_QUERY, "", NULL);
        _NFMdebug ((fname, "SQL Query Failed : status = <0x%.8x>\n",  
		    status)) ;
        return ( NFM_E_SQL_QUERY);
      }


     status = MEMbuild_array (list);
     if (status != MEM_S_SUCCESS)
      {
        free (sql_str);
        MEMclose (&list);
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n", status));
        return (NFM_E_MEM);       
      }

     data1 = (char **) list -> data_ptr;

     free (sql_str);

     sql_str = (char *) malloc (data_list -> row_size * 2);
     if (! sql_str)
      {
        MEMclose (&list);
        ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
        _NFMdebug ((fname, "Malloc Failed\n")) ;
        return (NFM_E_MALLOC);       
      }

     for (x = 0; x < list -> rows; ++x)
      {
        count = list -> columns * x;
        sql_str [0] = 0; z = 0;

        for (y = 0; y < attr_list -> rows; ++y)
         {
           count1 = attr_list -> columns * y;

           if (! strcmp (data [count1 + a], "n_catalogname"))
             strcat (sql_str, cat_name);
           else if (! strcmp (data [count1 + a], "n_level"))
             strcat (sql_str, level);
           else if (! strcmp (data [count1 + a], "n_citno"))
             strcat (sql_str, row_id);
           else if (! strcmp (data [count1 + a], "n_type"))
             strcat (sql_str, ctype);
           else if (! strcmp (data [count1 + a], "n_status1"))
             strcat (sql_str, "");
           else
            {
              strcat (sql_str, data1 [count + z]);
              z++;
            }

           strcat (sql_str, "\1");
         }

        status = MEMwrite (data_list, sql_str);
        if (status != MEM_S_SUCCESS)
         {
           free (sql_str);
           MEMclose (&list);
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
           _NFMdebug ((fname, "MEM Write : status = <0x%.8x>\n", status));
           return (NFM_E_MEM);       
         }
      }

     free (sql_str);
 
     status = MEMclose (&list);
     if (status != MEM_S_SUCCESS)
      {
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Close : status = <0x%.8x>\n", status)) ;
        return (NFM_E_MEM);       
      }

     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);
   }

  long NFMget_co_files_list (user_id, i_row, f_row,
             attr_list, data_list, file_list, type)
   long    user_id;
   long    i_row, f_row;
   MEMptr  attr_list, data_list, file_list;
   long    type;
   {
     char *fname = "NFMget_co_files_list" ;
     long    status;

     char    **column, **data, **data1, **column2;
     long    a, b, x, y, count;
     long    i1, j1, k1, l1, m1;
     long    i2, j2, k2, l2;
     long    i3, j3, k3, l3, m3, n3, o3, p3, q3, r3, s3;
     char    cat_name [100];
     long    cat_no, item_no, item_ver;
     char    *sql_str;
     char    node_name [50], user_name [50], passwd [50];
     char    path_name [50], device_type [10];
     char    mach_id [20], op_sys [20];
     char    net_xns [10], net_tcp [10], net_dec [10];
     char    filename [50], file_type [20];

     _NFMdebug ((fname, "Init  Row  = <%d> : Final Row = <%d> : Type = <%d>\n",
		 i_row, f_row, type)) ;
     column = (char **) attr_list -> column_ptr;
     data   = (char **) attr_list -> data_ptr;

     data1  = (char **) data_list -> data_ptr;

     a = -1; b = -1; 

     for (y = 0; y < attr_list -> columns; ++y)
      {
             if (! strcmp (column [y], "n_name"))        a = y;
        else if (! strcmp (column [y], "n_datatype"))    b = y;
      }

     i1 = -1;  j1 = -1; k1 = -1; l1 = -1; m1 = -1;
     i2 = -1;  j2 = -1; k2 = -1; l2 = -1;
     i3 = -1;  j3 = -1; k3 = -1; l3 = -1; m3 = -1;
     n3 = -1;  o3 = -1; p3 = -1; q3 = -1; r3 = -1;

     for (x = 0; x < attr_list -> rows; ++x)
      {
        count = attr_list -> columns * x;

             if (! strcmp (data [count + a], "n_catalogname"))    i1 = x;
        else if (! strcmp (data [count + a], "n_status1"))         j1 = x;
        else if (! strcmp (data [count + a], "n_type"))           k1 = x;
        else if (! strcmp (data [count + a], "n_level"))          l1 = x;
        else if (! strcmp (data [count + a], "n_citno"))          m1 = x;

        else if (! strcmp (data [count + a], "n_itemno"))         i2 = x;
        else if (! strcmp (data [count + a], "n_itemname"))       j2 = x;
        else if (! strcmp (data [count + a], "n_itemrev"))        k2 = x;
        else if (! strcmp (data [count + a], "n_status"))          l2 = x;
                    /* n_coout */
        else if (! strcmp (data [count + a], "n_itemnum"))        i3 = x;
        else if (! strcmp (data [count + a], "n_fileno"))         j3 = x;
        else if (! strcmp (data [count + a], "n_fileco"))         k3 = x;
        else if (! strcmp (data [count + a], "n_fileversion"))    l3 = x;
        else if (! strcmp (data [count + a], "n_cisano"))         m3 = x;
        else if (! strcmp (data [count + a], "n_cifilename"))     n3 = x;
        else if (! strcmp (data [count + a], "n_cofilename"))     o3 = x;
        else if (! strcmp (data [count + a], "n_cifilesize"))     p3 = x;
        else if (! strcmp (data [count + a], "n_fileclass"))      q3 = x;
        else if (! strcmp (data [count + a], "n_filetype"))       r3 = x;
        else if (! strcmp (data [count + a], "n_setindicator"))   s3 = x;
      }

     sprintf (cat_name,  "%s",
              data1 [(data_list -> columns * i_row) + i1]);

     item_no  = atol (data1 [(data_list -> columns * i_row) + i2]);
     item_ver = atol (data1 [(data_list -> columns * i_row) + l3]);

     status = NFMget_catalog_no (user_id, cat_name, &cat_no);
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "Get Cat No : status = <0x%.8x>\n", status));
        return (status);        
      }

     sql_str = (char *) malloc (2 * MEM_SIZE + file_list -> row_size);
     if (! sql_str)
      {
        ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
        _NFMdebug ((fname, "Malloc Failed\n")) ;
        return (NFM_E_MALLOC);        
      }

     for  (x = i_row; x < f_row; ++x)
      {
        count = data_list -> columns * x;

        status = MEMbuild_array (file_list);
        if (status != MEM_S_SUCCESS)
         {
           free (sql_str);
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
           _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
		       status));
           return (NFM_E_MEM);        
         }

        column2 = (char **) file_list -> column_ptr;

        if (strcmp (data1 [count + i1], cat_name))
         {
           free (sql_str);
        ERRload_struct (NFM, NFM_E_CORRUPTED_BUFFERS, "", NULL);
           _NFMdebug ((fname, "Cat Is Bad In Buf : status = <0x%.8x>\n",
           NFM_E_CORRUPTED_BUFFERS));
           return (NFM_E_CORRUPTED_BUFFERS);        
         }

        if (atol (data1 [count + i2]) != item_no)
         {
           free (sql_str);
        ERRload_struct (NFM, NFM_E_CORRUPTED_BUFFERS, "", NULL);
           _NFMdebug ((fname, "No Is Bad In Buf : status = <0x%.8x>\n",
           NFM_E_CORRUPTED_BUFFERS));
           return (NFM_E_CORRUPTED_BUFFERS);        
         }

        if (atol (data1 [count + l3]) != item_ver)
         {
           free (sql_str);
        ERRload_struct (NFM, NFM_E_CORRUPTED_BUFFERS, "", NULL);
           _NFMdebug ((fname, "Ver Is Bad In Buf : status = <0x%.8x>\n",
           NFM_E_CORRUPTED_BUFFERS));
           return (NFM_E_CORRUPTED_BUFFERS);        
         }

        
        if ( (!strcmp (data1[count+s3], "Y")) && (!strcmp (data1[count+l2], "")) )
        {
          strcpy (node_name, "");
          strcpy (user_name, "");
          strcpy (passwd, "");
          strcpy (path_name, "");
          strcpy (device_type, "");
          strcpy (mach_id, "");
          strcpy (op_sys, "");
          strcpy (net_tcp, "");
          strcpy (net_xns, "");
          strcpy (net_dec, "");
        }

        else
        {
          status = NFMget_sa_no_info (user_id,
                   atol (data1 [count + m3]),
                   node_name, user_name, passwd, path_name, device_type,
                   mach_id, op_sys, net_tcp, net_xns, net_dec);
          if (status != NFM_S_SUCCESS)
           {
             free (sql_str);
             _NFMdebug ((fname, "St No Info : status = <0x%.8x>\n",
             status));
             return (status);        
           }
        }

	strcpy (file_type, data1 [count + r3]) ;

        if (! strcmp (data1 [count + k3], "N"))
         {
           sql_str [0] = 0;

           for (y = 0; y < file_list -> columns; ++y)
            {
              if (! strcmp (column2 [y], "n_status1"))
                strcat (sql_str, "none");
              else if (! strcmp (column2 [y], "n_fileno"))
                strcat (sql_str, data1 [count + j3]);
              else if (! strcmp (column2 [y], "n_sano"))
                strcat (sql_str, data1 [count + m3]);
              else if (! strcmp (column2 [y], "n_nodename"))
                strcat (sql_str, node_name);
              else if (! strcmp (column2 [y], "n_username"))
                strcat (sql_str, user_name);
              else if (! strcmp (column2 [y], "n_passwd"))
                strcat (sql_str, passwd);
              else if (! strcmp (column2 [y], "n_pathname"))
                strcat (sql_str, path_name);
              else if (! strcmp (column2 [y], "n_devicetype"))
                strcat (sql_str, device_type);
              else if (! strcmp (column2 [y], "n_machid"))
                strcat (sql_str, mach_id);
              else if (! strcmp (column2 [y], "n_opsys"))
                strcat (sql_str, op_sys);
              else if (! strcmp (column2 [y], "n_tcpip"))
                strcat (sql_str, net_tcp);
              else if (! strcmp (column2 [y], "n_xns"))
                strcat (sql_str, net_xns);
              else if (! strcmp (column2 [y], "n_decnet"))
                strcat (sql_str, net_dec);
              else if (! strcmp (column2 [y], "n_cifilename"))
                strcat (sql_str, data1 [count + n3]);
              else if (! strcmp (column2 [y], "n_cofilename"))
                strcat (sql_str, data1 [count + o3]);
              else if (! strcmp (column2 [y], "n_cifilesize"))
                strcat (sql_str, "");
              else if (! strcmp (column2 [y], "n_filetype"))
                strcat (sql_str, file_type);

              strcat (sql_str, "\1");
            }

           status = MEMwrite (file_list, sql_str);
           if (status != MEM_S_SUCCESS)
            {
              free (sql_str);
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
              _NFMdebug ((fname, "MEM Write : status = <0x%.8x>\n",
			  status));
              return (NFM_E_MEM);      
            }
         }
        else if (! strlen (data1 [count + l2]))
         {
           if (! type)
            {
              free (sql_str);
        ERRload_struct (NFM, NFM_E_NO_FILE, "", NULL);
              _NFMdebug ((fname, "Item No File : status = <0x%.8x>\n",
              NFM_E_NO_FILE));
              return (NFM_E_NO_FILE);      
            }

           sql_str [0] = 0;

           for (y = 0; y < file_list -> columns; ++y)
            {
              if (! strcmp (column2 [y], "n_status1"))
                strcat (sql_str, "none");
              else if (! strcmp (column2 [y], "n_fileno"))
                strcat (sql_str, data1 [count + j3]);
              else if (! strcmp (column2 [y], "n_sano"))
                strcat (sql_str, data1 [count + m3]);
              else if (! strcmp (column2 [y], "n_nodename"))
                strcat (sql_str, node_name);
              else if (! strcmp (column2 [y], "n_username"))
                strcat (sql_str, user_name);
              else if (! strcmp (column2 [y], "n_passwd"))
                strcat (sql_str, passwd);
              else if (! strcmp (column2 [y], "n_pathname"))
                strcat (sql_str, path_name);
              else if (! strcmp (column2 [y], "n_devicetype"))
                strcat (sql_str, device_type);
              else if (! strcmp (column2 [y], "n_machid"))
                strcat (sql_str, mach_id);
              else if (! strcmp (column2 [y], "n_opsys"))
                strcat (sql_str, op_sys);
              else if (! strcmp (column2 [y], "n_tcpip"))
                strcat (sql_str, net_tcp);
              else if (! strcmp (column2 [y], "n_xns"))
                strcat (sql_str, net_xns);
              else if (! strcmp (column2 [y], "n_decnet"))
                strcat (sql_str, net_dec);
              else if (! strcmp (column2 [y], "n_cifilename"))
                strcat (sql_str, data1 [count + n3]);
              else if (! strcmp (column2 [y], "n_cofilename"))
                strcat (sql_str, data1 [count + o3]);
              else if (! strcmp (column2 [y], "n_cifilesize"))
                strcat (sql_str, "");
              else if (! strcmp (column2 [y], "n_filetype"))
                strcat (sql_str, file_type);
 
              strcat (sql_str, "\1");
            }

           status = MEMwrite (file_list, sql_str);
           if (status != MEM_S_SUCCESS)
            {
              free (sql_str);
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
              _NFMdebug ((fname, "MEM Write : status = <0x%.8x>\n",
			  status));
              return (NFM_E_MEM);      
            }            
         }
        else
         {
           status = NFMget_file_name (user_id, cat_no,
                    atol (data1 [count + j3]), filename);
           if (status != NFM_S_SUCCESS)
            {
              free (sql_str);
              _NFMdebug ((fname, "Get File Name : status = <0x%.8x>\n",
              status));
              return (status);      
            }

           sql_str [0] = 0;

           for (y = 0; y < file_list -> columns; ++y)
            {
              if (! strcmp (column2 [y], "n_status1"))
                strcat (sql_str, "move");
              else if (! strcmp (column2 [y], "n_fileno"))
                strcat (sql_str, data1 [count + j3]);
              else if (! strcmp (column2 [y], "n_sano"))
                strcat (sql_str, data1 [count + m3]);
              else if (! strcmp (column2 [y], "n_nodename"))
                strcat (sql_str, node_name);
              else if (! strcmp (column2 [y], "n_username"))
                strcat (sql_str, user_name);
              else if (! strcmp (column2 [y], "n_passwd"))
                strcat (sql_str, passwd);
              else if (! strcmp (column2 [y], "n_pathname"))
                strcat (sql_str, path_name);
              else if (! strcmp (column2 [y], "n_devicetype"))
                strcat (sql_str, device_type);
              else if (! strcmp (column2 [y], "n_machid"))
                strcat (sql_str, mach_id);
              else if (! strcmp (column2 [y], "n_opsys"))
                strcat (sql_str, op_sys);
              else if (! strcmp (column2 [y], "n_tcpip"))
                strcat (sql_str, net_tcp);
              else if (! strcmp (column2 [y], "n_xns"))
                strcat (sql_str, net_xns);
              else if (! strcmp (column2 [y], "n_decnet"))
                strcat (sql_str, net_dec);
              else if (! strcmp (column2 [y], "n_cifilename"))
               {
/*
                 if (strlen (data1 [count + n3]))
                  {
                    free (sql_str);
                    _NFMdebug ((fname, "Ci File Name : <%d>\n", -1));
                    return (-1);                    
                  }
*/
                 if (strlen (data1 [count + n3]))
                    strcat (sql_str, data1 [count + n3]);
                 else
                    strcat (sql_str, filename);
               }
              else if (! strcmp (column2 [y], "n_cofilename"))
               {
                 if (! strlen (data1 [count + o3]))
                  {
                    free (sql_str);
        ERRload_struct (NFM, NFM_E_BAD_FILE_NAME, "", NULL);
                    _NFMdebug ((fname, "No FName : status = <0x%.8x>\n",
                    NFM_E_BAD_FILE_NAME));
                    return (NFM_E_BAD_FILE_NAME);      
                  }
                 else
                    strcat (sql_str, data1 [count + o3]);
               }
              else if (! strcmp (column2 [y], "n_cifilesize"))
                strcat (sql_str, "-1");
              else if (! strcmp (column2 [y], "n_filetype"))
                strcat (sql_str, file_type);
 
              strcat (sql_str, "\1");
            }

           status = MEMwrite (file_list, sql_str);
           if (status != MEM_S_SUCCESS)
            {
              free (sql_str);
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
              _NFMdebug ((fname, "MEM Write : status = <0x%.8x>\n",
			  status));
              return (NFM_E_MEM);      
            }           
         }
      }

     free (sql_str);
     
     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);    
   }

 long NFMupdate_co_file_cat (user_id, c_user, c_date, c_time, sa_no,
                             i_row, f_row, level, type, 
                             cat_name, item_no, 
                             attr_list, data_list, file_list)
   long      user_id;
   char      *c_user, *c_date, *c_time;
   long      sa_no, i_row, f_row;
   char      *level;
   long      type;
   char      *cat_name;
   long      item_no;
   MEMptr    attr_list, data_list, file_list;
   {
     char *fname = "NFMupdate_co_file_cat" ;
     long     status;
     char     file_cat [100];
     char     **column, **data, **data1;
     char     **column2, **data2;
     char     **column3, **data3;
     long     a, b, d, x, y, z;
     long     count, count1, count2, count3;
     long     comma, found, update;
     long     i, j, k;
     MEMptr   list = NULL;
     char     *sql_str, sql_str1 [1024], value [50];

     _NFMdebug ((fname, "User = <%s> : Date = <%s> : Time = <%s> : Sa No = <%s> : Init Row = <%d> : Final Row = <%d> : Level = <%s> : Type = <%d> : Cat Name = <%s> : Item No <%d>\n", 
		 c_user, c_time, sa_no, i_row, f_row, level, type, cat_name, item_no)) ;

     sprintf (file_cat, "f_%s", cat_name);

     status = MEMbuild_array (file_list);
     if (status != MEM_S_SUCCESS)
      {
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
		    status)) ;
        return (NFM_E_MEM);
      }

     column = (char **) attr_list -> column_ptr;
     data   = (char **) attr_list -> data_ptr;

     data1   = (char **) data_list -> data_ptr;

     column2 = (char **) file_list -> column_ptr;
     data2   = (char **) file_list -> data_ptr;

     a = -1; b = -1; d = -1;

     for (y = 0; y < attr_list -> columns; ++y)
      {
             if (! strcmp (column [y], "n_name"))          a = y;
        else if (! strcmp (column [y], "n_datatype"))      b = y;
        else if (! strcmp (column [y], "n_application"))   d = y;
      }

     i = -1; j = -1; k = -1;

     for (y = 0; y < file_list -> columns; ++y)
      {
             if (! strcmp (column2 [y], "n_fileno"))      i = y;
        else if (! strcmp (column2 [y], "n_cifilesize"))  j = y;
        else if (! strcmp (column2 [y], "n_status1"))      k = y;
      }


     status = NFMquery_attributes_definition (user_id, "F_CATALOG",
              file_cat, &list);
     if (status != NFM_S_SUCCESS)
      {
        MEMclose (&list);
        _NFMdebug ((fname, "Qry Cat Attr : status = <0x%.8x>\n", status));
        return (status);
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

     column3 = (char **) list -> column_ptr;
     data3   = (char **) list -> data_ptr;

     sql_str = (char *) malloc (data_list -> row_size +
                                attr_list -> rows * 50 + MEM_SIZE);     
     if (! sql_str)
      {
        MEMclose (&list);
        ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
        _NFMdebug ((fname, "Malloc Failed\n")) ;
        return (NFM_E_MALLOC);
      }

     status = NFMstop_transaction (0);
     if (status != NFM_S_SUCCESS)
     {
        MEMclose (&list);
        ERRload_struct (NFM, NFM_E_FAILURE, "", NULL);
        _NFMdebug ((fname, "Malloc Failed\n")) ;
        return (NFM_E_FAILURE);
      }

     for (x = i_row; x < f_row; ++x)
      {
        count1 = data_list -> columns * x;
        count2 = file_list -> columns * x;

        comma = 0;
        sql_str  [0] = 0; sql_str1 [0] = 0;

        sprintf (sql_str,  "UPDATE %s SET ", file_cat);
        sprintf (sql_str1, " WHERE ");

        if (strcmp (data2 [count2 + k], "none"))
         {
           for (y = 0; y < attr_list -> rows; ++y)
            {
               count = attr_list -> columns * y;
               update = 0; found = 0;

               for (z = 0; ((z < list -> rows) && (! found)); ++z)
                {
                   count3 = list -> columns * z;

                   if (! strcmp (data3 [count3 + 2], data [count + a]))
                    {
                      found = 1;

                      if (! strcmp (data [count + a], "n_fileno"))
                       {
                         strcat (sql_str1, data3 [count3]);
                         strcat (sql_str1, " = ");
   
                         if (! strncmp (data3 [count3 + 1], "char", 4))
                          {
                            strcat (sql_str1, "'");
                            strcat (sql_str1, data1 [count1 + y]);
                            strcat (sql_str1, "'");
                          }
                         else
                            strcat (sql_str1, data1 [count1 + y]);
                       }
                      else if (! strcmp (data [count + a], "n_couser"))
                       {
                         sprintf (value, "%s", c_user);
                         update = 1;
                       }
                      else if (! strcmp (data [count + a], "n_codate"))
                       {
                         sprintf (value, "%s", c_date);
                         update = 1;
                       }
                      else if (! strcmp (data [count + a], "n_cotime"))
                       {
                         sprintf (value, "%s", c_time);
                         update = 1;
                       }
                      else if (! strcmp (data [count + a], "n_cosano"))
                       {
                         sprintf (value, "%d", sa_no);
                         update = 1;
                       }
                      else if 
                            (! strcmp (data [count + a], "n_cofilename"))
                       {
                         sprintf (value, "%s", data1 [count1 + y]);
                         update = 1;
                       }
                      else if (! strcmp (data [count + a], "n_fileco"))
                       {
                         sprintf (value, "%s", "Y");
                         update = 1;
                       }
                      else if (! strcmp (data [count + a], "n_cocomment"))
                       {
                         sprintf (value, "%s", data1 [count1 + y]);
                         update = 1;
                       }
                    }
		 }

               if (update)
                {
                  if (comma) strcat (sql_str, ", ");
                  comma = 1;

                  strcat (sql_str, data3 [count3]);
                  strcat (sql_str, " = ");
    
                  if (! strncmp (data3 [count3 + 1], "char", 4))
                   {
                     strcat (sql_str, "'");
                     strcat (sql_str, value);
                     strcat (sql_str, "'");
                   }
                  else
                   {
                     if (! strlen (value))
                       strcat (sql_str, "null");
                     else
                       strcat (sql_str, value);
                   }
                }
	     }

           strcat (sql_str, sql_str1);
  
           status = NFMlock_table (file_cat);
           if (status != NFM_S_SUCCESS)
            {
              free (sql_str);
              ERRload_struct (NFM, NFM_E_FAILURE, "", NULL);
              _NFMdebug ((fname, "failed  <0x%.8x>\n",
			  NFM_E_FAILURE));
              return (NFM_E_FAILURE);
            }
           
           status = SQLstmt (sql_str);
           if (status != SQL_S_SUCCESS)
            {
              free (sql_str);
        ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
              _NFMdebug ((fname, "SQL Stmt Failed : status = <0x%.8x>\n",
			  status));
              return (NFM_E_SQL_STMT);
            }
            status = SQLstmt ("COMMIT WORK");
            if (status != SQL_S_SUCCESS)
            {
              free (sql_str);
              ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
              _NFMdebug ((fname, "SQL Stmt Failed : status = <0x%.8x>\n",
			  status));
              return (NFM_E_SQL_STMT);
            }
   
         }
	else
	  {
	    for (y = 0; y < attr_list -> rows; ++y)
	      {
               count = attr_list -> columns * y;
               update = 0; found = 0;

               for (z = 0; ((z < list -> rows) && (! found)); ++z)
                {
                   count3 = list -> columns * z;

                   if (! strcmp (data3 [count3 + 2], data [count + a]))
                    {
                      found = 1;

                      if (! strcmp (data [count + a], "n_fileno"))
                       {
                         strcat (sql_str1, data3 [count3]);
                         strcat (sql_str1, " = ");
   
                         if (! strncmp (data3 [count3 + 1], "char", 4))
                          {
                            strcat (sql_str1, "'");
                            strcat (sql_str1, data1 [count1 + y]);
                            strcat (sql_str1, "'");
                          }
                         else
                            strcat (sql_str1, data1 [count1 + y]);
                       }
                      else if (! strcmp (data [count + a], "n_fileco"))
                       {
                         sprintf (value, "%s", "N");
                         update = 1;
                       }
                    }
		 }

               if (update)
                {
                  if (comma) strcat (sql_str, ", ");
                  comma = 1;

                  strcat (sql_str, data3 [count3]);
                  strcat (sql_str, " = ");
    
                  if (! strncmp (data3 [count3 + 1], "char", 4))
                   {
                     strcat (sql_str, "'");
                     strcat (sql_str, value);
                     strcat (sql_str, "'");
                   }
                  else
                   {
                     if (! strlen (value))
                       strcat (sql_str, "null");
                     else
                       strcat (sql_str, value);
                   }
                }
	     }

           strcat (sql_str, sql_str1);
  
           status = NFMlock_table (file_cat);
           if (status != NFM_S_SUCCESS)
            {
              free (sql_str);
              ERRload_struct (NFM, NFM_E_FAILURE, "", NULL);
              _NFMdebug ((fname, "Failed : <0x%.8x>\n",
              NFM_E_FAILURE));
              return (NFM_E_FAILURE);
            }

           status = SQLstmt (sql_str);
           if (status != SQL_S_SUCCESS)
            {
              free (sql_str);
              _NFMdebug ((fname, "SQL Stmt Failed : status = <0x%.8x>\n",
			  status)) ;
              return (NFM_E_SQL_STMT);
            }
            status = SQLstmt ("COMMIT WORK");
            if (status != SQL_S_SUCCESS)
            {
              free (sql_str);
              ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
              _NFMdebug ((fname, "SQL Stmt Failed : status = <0x%.8x>\n",
			  status)) ;
              return (NFM_E_SQL_STMT);
            }
	  }
      }
     status = NFMstart_transaction (0);
     if (status != NFM_S_SUCCESS)
     {
        MEMclose (&list);
        ERRload_struct (NFM, NFM_E_FAILURE, "", NULL);
        _NFMdebug ((fname, "Malloc Failed\n")) ;
        return (NFM_E_FAILURE);
      }


     status = MEMclose (&list);
     if (status != MEM_S_SUCCESS)
      {
        free (sql_str);
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Close : status = <0x%.8x>\n",
		    status)) ;
        return (NFM_E_MEM);
      }

     status = NFMquery_attributes_definition (user_id,
              "CATALOG", cat_name, &list);
     if (status != NFM_S_SUCCESS)
      {
        free (sql_str);
        MEMclose (&list);
        _NFMdebug ((fname, "Query Table Def : status = <0x%.8x>\n",
        status));
        return (status);
      }

     status = MEMbuild_array (list);
     if (status != MEM_S_SUCCESS)
      {
        free (sql_str);
        MEMclose (&list);
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
		    status));
        return (NFM_E_MEM);
      }

     data3 = (char **) list -> data_ptr;

     status = NFMstop_transaction (0);
     if (status != NFM_S_SUCCESS)
     {
        MEMclose (&list);
        ERRload_struct (NFM, NFM_E_FAILURE, "", NULL);
        _NFMdebug ((fname, "Malloc Failed\n")) ;
        return (NFM_E_FAILURE);
      }
     for (x = i_row; x < i_row + 1; ++x)
      {
        count1 = data_list -> columns * x;
        count2 = file_list -> columns * x;
 
        comma = 0; update = 0;

        sql_str  [0] = 0; sql_str1 [0] = 0;

        sprintf (sql_str,  "UPDATE %s SET ", cat_name);
        sprintf (sql_str1, " WHERE ");

        for (y = 0; y < attr_list -> rows; ++y)
         {
           count = attr_list -> columns * y;
           found = 0;

           for (z = 0; ((z < list -> rows) && (! found)); ++z)
            {
               count3 = list -> columns * z;

               if (! strcmp (data [count + d], "NFM"))
                {
                  if (! strcmp (data [count + a], data3 [count3 + 2]))
                   {
                     found = 1;

                     if (! strcmp (data [count + a], "n_itemno"))
                      {
                        strcat (sql_str1, data3 [count3]);
                        strcat (sql_str1, " = ");
    
                        if (! strncmp (data3 [count3 + 1], "char", 4))
                         {
                           strcat (sql_str1, "'");
                           strcat (sql_str1, data1 [count1 + y]);
                           strcat (sql_str1, "'");
                         }
                        else
                           strcat (sql_str1, data1 [count1 + y]);
                      }
                     else if (! strcmp (data [count + a], "n_status"))
/* n_coout */
                      {
                        if (comma) strcat (sql_str, ", ");
                        comma = 1;
   
                        strcat (sql_str, data3 [count3]);
                        strcat (sql_str, " = ");
    
                        if (! strncmp (data3 [count3 + 1], "char", 4))
                         {
                           strcat (sql_str, "'");
   
                           if (! type)  strcat (sql_str, "O");
                           else if (type == 1)
                            {
                              if (! strlen (data1 [count1 + y]))
                                strcat (sql_str, "SN");
                              else
                                strcat (sql_str, "S");
                            }
                           else if (type == 2)
                            {
                              if (! strlen (data1 [count1 + y]))
                                strcat (sql_str, "MN");
                              else
                                strcat (sql_str, "M");
                            }

                           strcat (sql_str, "'");
                         }
                        else
                         {
                           if (! type) strcat (sql_str, "O");
                           else if (type == 1)
                            {
                              if (! strlen (data1 [count1 + y]))
                                strcat (sql_str, "P");
                              else
                                strcat (sql_str, "SN");
                            }
                           else if (type == 2)
                            {
                              if (! strlen (data1 [count1 + y]))
                                strcat (sql_str, "P");
                              else
                                strcat (sql_str, "SN");
                            }
                         }
                      }
                     else if (! strcmp (data [count + a], "n_colevel"))
                      {
                        if (comma) strcat (sql_str, ", ");
                        comma = 1;
   
                        strcat (sql_str, data3 [count3]);
                        strcat (sql_str, " = ");
   
                        if (! strncmp (data3 [count3 + 1], "char", 4))
                         {
                           strcat (sql_str, "'");
                           strcat (sql_str, level);
                           strcat (sql_str, "'");
                         }
                        else
                         {
                           if (! strlen (level))
                             strcat (sql_str, "null");
                           else   
                             strcat (sql_str, level);
                         }
                      }
                   }
                }
               else
                {
                  if (! strcmp (data [count + a], data3 [count3]))
                   {
                     found = 1;

                     if (comma) strcat (sql_str, ", ");
                     comma = 1;
		     /* fix for TR90W2524 (sql_str was mistyped as sql_str1 )*/
                     strcat (sql_str, data3 [count3]);
                     strcat (sql_str, " = ");
   
                     if (! strncmp (data3 [count3 + 1], "char", 4))
                      {
                        strcat (sql_str, "'");
                        strcat (sql_str, data1 [count1 + y]);
                        strcat (sql_str, "'");
                      }
                     else
                      {
                        if (! strlen (data1 [count1 + y]))
                          strcat (sql_str, "null");
                        else
                          strcat (sql_str, data1 [count1 + y]);
                      }
		     /***/
                   }                
                }
            }
         }

        strcat (sql_str, sql_str1);

        status = NFMlock_table (cat_name);
        if (status != NFM_S_SUCCESS)
        {
           free (sql_str);
           ERRload_struct (NFM, NFM_E_FAILURE, "", NULL);
           _NFMdebug ((fname, "Failed : <0x%.8x>\n",
           NFM_E_FAILURE));
           return (NFM_E_FAILURE);
        }


        status = SQLstmt (sql_str);
        if (status != SQL_S_SUCCESS)
         {
            free (sql_str);
        ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
            _NFMdebug ((fname, "SQL Stmt Failed : status = <0x%.8x>\n",
			status));
            return (NFM_E_SQL_STMT);
         }
            status = SQLstmt ("COMMIT WORK");
            if (status != SQL_S_SUCCESS)
            {
              free (sql_str);
              ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
              _NFMdebug ((fname, "SQL Stmt Failed : status = <0x%.8x>\n",

			  status));
              return (NFM_E_SQL_STMT);
            }

      }
     status = NFMstart_transaction (0);
     if (status != NFM_S_SUCCESS)
     {
        MEMclose (&list);
        ERRload_struct (NFM, NFM_E_FAILURE, "", NULL);
        _NFMdebug ((fname, "Malloc Failed\n")) ;
        return (NFM_E_FAILURE);
      }
     
     free (sql_str);

     status = MEMclose (&list);
     if (status != MEM_S_SUCCESS)
      {
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
         _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
		     status));
         return (NFM_E_MEM);
      }
 
     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);
   }

 long NFMconvert_to_set (user_id, cat_name, item_name, item_rev)
   long    user_id;
   char    *cat_name, *item_name,  *item_rev;
   {
     char *fname = "NFMconvert_to_set" ;
      long     status;
      char     sql_str [1024], value [50];
      long     cat_no, item_no;

      _NFMdebug ((fname, "Table Name = <%s> : Item Name = <%s> : Item Rev = <%s>\n", 
		  cat_name, item_name, item_rev) );

      status = NFMget_catalog_no (user_id, cat_name, &cat_no);
      if (status != NFM_S_SUCCESS)
       {
         _NFMdebug ((fname, "Get Cat No : status  = < 0x%.8x >\n", status));
         return (status);
       }

      status = NFMget_item_no (user_id, cat_name,
               item_name, item_rev, &item_no);
      if (status != NFM_S_SUCCESS)
       {
         _NFMdebug ((fname, "Get Item No : status  = < 0x%.8x >\n", status)) ;
         return (status);
       }
  
      status = NFMcheck_item_setindicator (user_id, cat_name, item_no);
      if ((status != NFM_S_SUCCESS) && (status != NFM_E_NOT_SET))
       {
         _NFMdebug ((fname, "Check Set Ind : status  = < 0x%.8x >\n", status));
         return (status);
       }


      sprintf (sql_str, "UPDATE %s SET %s = 'Y'", cat_name, "n_setindicator");


      strcat (sql_str, " WHERE ");
      strcat (sql_str, "n_itemno");
      strcat (sql_str, " = ");

      sprintf (value, "%d", item_no);

      strcat (sql_str, value);

      status = SQLstmt (sql_str);
      if (status != SQL_S_SUCCESS)
       {
         ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
         _NFMdebug ((fname, "SQL Stmt Syntax : status  = < 0x%.8x >\n",
		     status));
         return (NFM_E_SQL_STMT);
       }

      _NFMdebug ((fname, "SUCCESSFUL\n")) ;
      return (NFM_S_SUCCESS);
   }

 long NFMget_set_ci_list (user_id, cat_name, item_no, item_name, item_rev,
                          attr_list, data_list)
   long    user_id;
   char    *cat_name;
   long    item_no;
   char    *item_name, *item_rev;
   MEMptr  attr_list, data_list;
   {
     char *fname = "NFMget_set_ci_list" ;
     long    status ;
     MEMptr  set_attr = NULL, set_data = NULL;
     char    **column, **data, **data1;
     long    a, x, y, count;
     long    i, j, k, l, m, n;
     long    level;
     long    NFMget_set_checkout_level ();

     _NFMdebug ((fname, "Cat  Name = <%s> : Item No = <%d> : Item Name = <%s> : Item Rev <%s>\n", 
		 cat_name, item_no, item_name, item_rev));

     status = NFMget_set_checkout_level (user_id, cat_name,
              item_no, &level);
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "Get Check Out Level : status = <0x%.8x>\n",
        status));
        return (status);
      }

     status = NFMquery_set_members (user_id, cat_name,
              item_name, item_rev, level, 1, 
              &set_attr, &set_data);
     if (status != NFM_S_SUCCESS)
      {
        MEMclose (&set_attr);
        MEMclose (&set_data);
        _NFMdebug ((fname, "Query Set Members : status = <0x%.8x>\n",
        status));
        return (status);
      }    

     status = MEMbuild_array (set_attr);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (&set_attr);
        MEMclose (&set_data);
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
		    status));
        return (NFM_E_MEM);
      }

     status = MEMbuild_array (set_data);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (&set_attr);
        MEMclose (&set_data);
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
		    status));
        return (NFM_E_MEM);
      }

     column = (char **) set_attr -> column_ptr;
     data   = (char **) set_attr -> data_ptr;

     data1  = (char **) set_data -> data_ptr;

     a = -1;

     for (y = 0; y < set_attr -> columns; ++y)
       if (! strcmp (column [y], "n_name"))     a = y;

     i = -1; j = -1; k = -1; l = -1; m = -1; n = -1;

     for (x = 0; x < set_attr -> rows; ++x)
      {
        count = set_attr -> columns * x;

             if (! strcmp (data [count + a], "n_catalogname"))   i = x;
        else if (! strcmp (data [count + a], "n_itemname"))      j = x;
        else if (! strcmp (data [count + a], "n_itemrev"))       k = x;
        else if (! strcmp (data [count + a], "n_type"))          l = x;
        else if (! strcmp (data [count + a], "n_level"))         m = x;
        else if (! strcmp (data [count + a], "n_citno"))         n = x;
      }


     for (x = 0; x < set_data -> rows; ++x)
      {
        count = set_data -> columns * x;

        status = NFMget_item_no (user_id, data1 [count + i],
                 data1 [count + j], data1 [count + k], &item_no);
        if (status != NFM_S_SUCCESS)
         {
           MEMclose (&set_attr);
           MEMclose (&set_data);
           _NFMdebug ((fname, "Get Item No : status = <0x%.8x>\n",
           status));
           return (status);
         }

        status = NFMget_item_ci_list (user_id, data1 [count + i],
                 item_no, data1 [count + l], data1 [count + m],
                 data1 [count + n], attr_list, data_list);
        if (status != NFM_S_SUCCESS)
         {
           MEMclose (&set_attr);
           MEMclose (&set_data);
           _NFMdebug ((fname, "Get Set Item Ci In : status = <0x%.8x>\n",
           status));
           return (status);
         }
      }

     status = MEMclose (&set_attr);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (&set_data);
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Close : status = <0x%.8x>\n", status));
        return (NFM_E_MEM);
      }

     status = MEMclose (&set_data);
     if (status != MEM_S_SUCCESS)
      {
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Close : status = <0x%.8x>\n", status));
        return (NFM_E_MEM);
      }
        
     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);
   }

 long NFMget_set_checkout_level (user_id, cat_name, item_no, level)
   long     user_id;
   char     *cat_name;
   long     item_no;
   long     *level;
   {
     char *fname = "NFMget_set_checkout_level" ;
      long    status ;
      char    sql_str [1024], value [50];

      *level = 0;

      _NFMdebug ((fname, "Cat   Name = <%s>  : Item No = <%d> : Level = <%d>\n",
		  cat_name, item_no, *level)) ;

      sprintf (sql_str, " WHERE %s = %d", "n_itemno", item_no);


      status = NFMget_attr_value (user_id, cat_name, "n_colevel",
               sql_str, value);
      if (status != NFM_S_SUCCESS)
       {
          if (status == NFM_I_BAD_CONDITION)
           {
        ERRload_struct (NFM, NFM_E_BAD_ITEM, "", NULL);
             _NFMdebug ((fname, "No Such Item : status = <0x%.8x>\n",
             NFM_E_BAD_ITEM));
             return (NFM_E_BAD_ITEM);      
           }

          _NFMdebug ((fname, "Get Attr Value : status = <0x%.8x>\n",
          status));
          return (status);      
       }

      *level = atol (value);

      _NFMdebug ((fname, "SUCCESSFUL : Co Level = <%d>\n", *level));
      return (NFM_S_SUCCESS);      
   }

 long NFMconvert_to_item (user_id, cat_name, item_name, item_rev)
   long    user_id;
   char    *cat_name, *item_name,  *item_rev;
   {
     char *fname = "NFMconvert_to_item" ;
      long     status;
      char     sql_str [1024], value [50], co_status [10];
      long     cat_no, item_no;
      long     NFMreset_co_out_set_item ();

      _NFMdebug ((fname, "Table Name = <%s>  : Item Name = <%s> : Item Rev = <%s>\n", 
		  cat_name, item_name, item_rev));

      status = NFMget_catalog_no (user_id, cat_name, &cat_no);
      if (status != NFM_S_SUCCESS)
       {
         _NFMdebug ((fname, "Get Cat No : status = <0x%.8x>\n", status));
         return (status);
       }

      status = NFMget_item_no (user_id, cat_name,
               item_name, item_rev, &item_no);
      if (status != NFM_S_SUCCESS)
       {
         _NFMdebug ((fname, "Get Item No : status = <0x%.8x>\n", status));
         return (status);
       }
  
      status = NFMcheck_item_setindicator (user_id, cat_name, item_no);
      if ((status != NFM_S_SUCCESS) && (status != NFM_E_SET))
       {
         _NFMdebug ((fname, "Check Set Ind : status = <0x%.8x>\n", status));
         return (status);
       }

      status = NFMcheck_item_set_parent (user_id, cat_no, item_no);
      if (status != NFM_E_NOT_SET_PARENT)
       {
         _NFMdebug ((fname, "Check Item Set Parent : status = <0x%.8x>\n",
         status));
         return (status);
       }

      status = NFMcheck_co_status (user_id, cat_name, item_no, co_status);
      if (status != NFM_S_SUCCESS && status != NFM_E_NO_FILE         &&
          status != NFM_E_ITEM_IN && status != NFM_E_ITEM_OUT        &&
          status != NFM_E_SET_OUT && status != NFM_E_SET_OUT_NO_FILE &&
          status != NFM_E_MEM_OUT && status != NFM_E_MEM_OUT_NO_FILE)

       {
         _NFMdebug ((fname, "Check Co Out : status = <0x%.8x>\n", status));
         return (status);
       }

      if (status == NFM_E_SET_OUT || status == NFM_E_SET_OUT_NO_FILE)
       {
         status = NFMreset_co_out_set_item (user_id,
                  cat_name, item_no, status);
         if (status != NFM_S_SUCCESS)
          {
            _NFMdebug ((fname, "Check Co Out : status = <0x%.8x>\n", status));
            return (status);
          }
       }

      sprintf (sql_str, "UPDATE %s SET %s = ''", cat_name, "n_setindicator");

      strcat (sql_str, " WHERE ");
      strcat (sql_str, "n_itemno");
      strcat (sql_str, " = ");

      sprintf (value, "%d", item_no);

      strcat (sql_str, value);

      status = SQLstmt (sql_str);
      if (status != SQL_S_SUCCESS)
       {
         ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
         _NFMdebug ((fname, "SQL Stmt Syntax : status = <0x%.8x>\n", 
		     status));
         return (NFM_E_SQL_STMT);
       }

      _NFMdebug ((fname, "SUCCESSFUL\n")) ;
      return (NFM_S_SUCCESS);
   }

 long NFMreset_co_out_set_item (user_id, cat_name, item_no, co_status)
   long    user_id;
   char    *cat_name;
   long    item_no;
   long    co_status;
   {
     char *fname = "NFMreset_co_out_set_item" ;
      long    status;
      char    sql_str [1024], value1 [50], value2 [50];
      char    file_cat [100];

      _NFMdebug ((fname, "Cat  Name = <%s> : Item No = <%d> : Co Stat = <%d>\n", 
		  cat_name, item_no, co_status));
      user_id = user_id ;
      if (co_status == NFM_E_SET_OUT)
       {
	 sprintf (value1, "'O'");

	 sprintf (value2, "null");
       }
      else if (co_status == NFM_E_SET_OUT_NO_FILE)
       {
	 sprintf (value1, "''");

	 sprintf (value2, "null");
       }

      sprintf (sql_str, "UPDATE %s SET %s = %s, %s = %s WHERE %s = %d",
	       cat_name, "n_status", value1, "n_colevel", value2, "n_itemno", item_no);

      status = SQLstmt (sql_str);
      if (status != SQL_S_SUCCESS)
       {
         ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
         _NFMdebug ((fname, "SQL Stmt Syntax : status = <0x%.8x>\n", status));
         return (NFM_E_SQL_STMT);
       }

      if (co_status == NFM_E_SET_OUT_NO_FILE)
       {
         sprintf (file_cat, "f_%s", cat_name);


	 sprintf (value1, "''");
	 sprintf (value2, "'Y'");

	 sprintf (sql_str,
		  "UPDATE %s SET %s = %s WHERE %s = '%d' AND %s = %s",
		  cat_name, "n_fileco", value1,
		  "n_itemnum", item_no, "n_fileco", value2);

         status = SQLstmt (sql_str);
         if (status != SQL_S_SUCCESS)
          {
         ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
            _NFMdebug ((fname, "SQL Stmt Syntax : status = <0x%.8x>\n", status));
            return (NFM_E_SQL_STMT);
          }
       }

      _NFMdebug ((fname, "SUCCESSFUL\n")) ;
      return (NFM_S_SUCCESS);     
   }

 int NFM_SET_CO_LEVEL = 0;

 long NFMget_set_co_list (user_id, cat_name, item_no, item_name, item_rev,
                          level, attr_list, data_list, type)
   long    user_id;
   char    *cat_name;
   long    item_no;
   char    *item_name, *item_rev;
   long    level;
   MEMptr  attr_list, data_list;
   long    type;
   {
     char *fname = "NFMget_set_co_list" ;
     long    status;
     MEMptr  set_attr = NULL, set_data = NULL;
     char    **column, **data, **data1;
     long    x, y, count;
     long    i, j, k, l, m, n, a ;
     
     _NFMdebug ((fname, "Cat  Name = <%s> : Item No = <%d> : Item Name = <%s> : Item Rev = <%s> : Level = <%d> : Type = <%d>\n",
		 cat_name, item_no, item_name, item_rev, level,type));

     status = NFMquery_set_members (user_id, cat_name,
              item_name, item_rev, level, 1,
              &set_attr, &set_data);
     if (status != NFM_S_SUCCESS)
      {
        MEMclose (&set_attr);
        MEMclose (&set_data);
        _NFMdebug ((fname, "Query Set Members : status = <0x%.8x>\n",
        status));
        return (status);
      }    

     status = MEMbuild_array (set_attr);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (&set_attr);
        MEMclose (&set_data);
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
		    status));
        return (NFM_E_MEM);
      }

     status = MEMbuild_array (set_data);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (&set_attr);
        MEMclose (&set_data);
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
		    status));
        return (NFM_E_MEM);
      }

     column = (char **) set_attr -> column_ptr;
     data   = (char **) set_attr -> data_ptr;

     data1  = (char **) set_data -> data_ptr;

     a = -1 ;

     for (y = 0; y < set_attr -> columns; ++y)
       if (! strcmp (column [y], "n_name"))     a = y;
     i = -1; j = -1; k = -1; l = -1; m = -1; n = -1;

     for (x = 0; x < set_attr -> rows; ++x)
      {
        count = set_attr -> columns * x;

             if (! strcmp (data [count + a], "n_catalogname"))   i = x;
        else if (! strcmp (data [count + a], "n_itemname"))      j = x;
        else if (! strcmp (data [count + a], "n_itemrev"))       k = x;
        else if (! strcmp (data [count + a], "n_type"))          l = x;
        else if (! strcmp (data [count + a], "n_level"))         m = x;
        else if (! strcmp (data [count + a], "n_citno"))         n = x;
      }

     for (x = 0; x < set_data -> rows; ++x)
      {
        count = set_data -> columns * x;

        if (! type)
         {
           status = MEMwrite_data (set_data, "S", x + 1, l + 1);
           if (status != MEM_S_SUCCESS)
            {
              MEMclose (&set_attr);
              MEMclose (&set_data);
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
              _NFMdebug ((fname, "MEM Wr Data : status = <0x%.8x>\n",
			  status));
              return (NFM_E_MEM);
            }
         }

        status = NFMget_item_no (user_id, data1 [count + i],
                 data1 [count + j], data1 [count + k], &item_no);
        if (status != NFM_S_SUCCESS)
         {
           MEMclose (&set_attr);
           MEMclose (&set_data);
           _NFMdebug ((fname, "Get Item No : status = <0x%.8x>\n",
           status));
           return (status);
         }

        status = NFMget_item_co_list (user_id, data1 [count + i],
                 item_no, data1 [count + l], data1 [count + m],
                 data1 [count + n], attr_list, data_list, type);
        if (status != NFM_S_SUCCESS)
         {
           MEMclose (&set_attr);
           MEMclose (&set_data);
           _NFMdebug ((fname, "Get Set Item Ci In : status = <0x%.8x>\n",
           status));
           return (status);
         }
      }

     status = MEMclose (&set_attr);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (&set_data);
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Close : status = <0x%.8x>\n", status));
        return (NFM_E_MEM);
      }

     status = MEMclose (&set_data);
     if (status != MEM_S_SUCCESS)
      {
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Close : status = <0x%.8x>\n", status));
        return (NFM_E_MEM);
      }
        
     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);
   }
