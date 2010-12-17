#include "machine.h"
#include <stdio.h>
#include "UNIX_or_VMS.h"
#include "NFMerrordef.h"
#include "NFMdef.h"
#include "MEMstruct.h"
#include "MEMerrordef.h"
#include "SCstruct.h"
#include "SCdef.h"
#include "NFMRextern.h"
#include "NDXstruct.h"
#include "DEBUG.h"
#include "NFIcommands.h"
#include "NFIerrordef.h"
#include "ERR.h"
#include "NFMstruct.h"

extern long sqlstatus;
extern struct NFMglobal_st NFMglobal;

long ADMrepair_uti ()

{
long   status, status2, status6;
int    i, j, z , k;
int    tot_data;
int    pos;
int    FORM_FILLED;
int    count;
int    NO_ROW_FUND;
int    flag;
int    set_not_found;
int    offset;
struct SCfree_data_st fdata;
char   **column_ptr;
char   **column_ptr1;
char   **column_ptr2;
char   **column_ptr3;
char   **column_ptr4;
char   **column_ptr5;
char   **data_ptr,  **item_buf ,**data;
char   **data_ptr1;
char   **data_ptr2;
char   **data_ptr3;
char   **data_ptr4;
char   **data_ptr5;
char   sql_str[2024] ;
char   qry_str[3024];
char   qry_file[2024];
char   qry_file_to[2024];
char   qry_files[2024] = {0};
char   file_str[2024];
char   sql_string[2024];
char   file_str_1[2024];
char   file_str_2[2024];
char   file_str_3[2024];
char   file_str_4[2024];
char   file_str_5[2024];
char   qry_str_cat[2024];
char   file_strs[2024];
char   file_str_no[2024];
char   qry_str1[2024];
char   sql_str_s[2024];
char   sql_str_s1[2024];
char   sql_str_s4[2024];
char   sql_str_set[2024];
char   sql_str_set1[2024];
char   sql_str_set2[2024];
char   sql_str_set3[2024];
char   qry_cat_name[2024];
char   qry_cat_name_c[2024];
char   sql_act[2024];
char   sql_act1[2024];
int    cosano;
char   couser[50];
char   codate[50];
char   one_or_all[2], str [1024] ;


MEMptr out_list = NULL,  return_buffer = NULL , return_buffer_act = NULL;
MEMptr data_list = NULL, file_buffer = NULL , return_buffer_cat = NULL;
MEMptr return_buffer_cat_n = NULL, return_buffer_act_n = NULL;

static char *fname = "ADMrepair_uti";

    _NFMdebug ((fname, "ENTER\n"));
    
    SCdisplay_msg ("Working..");        

    status = ADMcatalog_list (NFMglobal.NFMuserid, &out_list);

    if (status != NFM_S_SUCCESS)
     {
        _NFMdebug((fname, "ADMcatalog_list:0x%.8x\n", status));	 
        ERRload_struct(NFM, NFM_E_DISPLAY_CATALOGS,NULL, NULL);
        return (status);
      }


    status = MEMbuild_array (out_list);
    
    column_ptr = (char **) out_list->column_ptr;
    data_ptr = (char **) out_list->data_ptr;

	_NFMdebug ((fname,  "Entering Update For Catalog\n")) ;
	
	/* give user choice */
	status = MEMopen (&data_list, 2 * MEM_SIZE);
	if (status != MEM_S_SUCCESS)
	  {
	    _NFMdebug ((fname, "MEM Open : status = <0x%.8x>", status));
	    ERRload_struct (NFM, NFM_E_MEM, "", NULL) ;
	    return (status);          
	  }
      
	status = MEMwrite_format (data_list, "n_catalogname", "char(20)");
	if (status != MEM_S_SUCCESS)
	  {
	    ERRload_struct (NFM, NFM_E_MEM, "", NULL) ;
	    _NFMdebug ((fname, "MEM Wr Format : status = <0x%.8x>", status));
	    MEMclose(data_list);
	    return (status);          
	  }

	status = MEMwrite_format (data_list, "n_itemname", "char(60)");
	if (status != MEM_S_SUCCESS)
	  {
	    ERRload_struct (NFM, NFM_E_MEM, "", NULL) ;
	    _NFMdebug ((fname, "MEM Wr Format : status = <0x%.8x>", status));
	    MEMclose(data_list);
	    return (status);          
	  }
	
	status = MEMwrite_format (data_list, "n_itemrev", "char(60)");
	if (status != MEM_S_SUCCESS)
	  {
             ERRload_struct (NFM, NFM_E_MEM, "", NULL) ;		
	    _NFMdebug ((fname, "MEM Wr Format : status = <0x%.8x>", status));
	    MEMclose(data_list);
	    return (status);          
	  }
	
	status = MEMwrite_format (data_list, "n_status", "char(2)");
	if (status != MEM_S_SUCCESS)
	  {
            ERRload_struct (NFM, NFM_E_MEM, "", NULL) ;
           _NFMdebug ((fname, "MEM Wr Format : status = <0x%.8x>", status));
            MEMclose(data_list);
	    return (status);          
	  }

    NO_ROW_FUND = 0;
	
	for (i=0; i<out_list->rows; i++)
     {
	    
	    sprintf (sql_str,  "SELECT n_itemname, n_itemrev, n_status \
           FROM %s WHERE n_status = 'TI' OR n_status = 'TO' OR n_status = 'TF' \
           OR n_status = 'TM' OR n_status = 'TD'",
            data_ptr [i]) ;

            sprintf (file_str,"SELECT n_itemnum  FROM f_%s \
            WHERE n_fileversion > 0", data_ptr [i]) ;

/*	    _NFNdebug ((fname, "file_str -> %s\n", file_str)) ;*/

	    status =SQLquery (sql_str,  &return_buffer,  2*MEM_SIZE) ;
	    if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
	      {
/*                _NFMdebug((fname, "SQL_S_SUCCESS\n", status));*/
         ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
		MEMclose (&return_buffer);
		return (status) ;
	      }
	    
	    if (status != SQL_I_NO_ROWS_FOUND)
	      {
    		status = MEMbuild_array (return_buffer) ;
            if (status != MEM_S_SUCCESS)
		    {
     		    return (status) ;
    	    }
		
            item_buf = (char **) return_buffer -> data_ptr ;

    		for (z=0; z<return_buffer->rows; z++)
		     {
    		    strcpy (str, data_ptr [i]) ;
		        strcat (str, "\1") ;
     		    strcat (str, item_buf [z*return_buffer->columns]);
    		    strcat (str, "\1");
		        strcat (str, item_buf [z*return_buffer->columns+1]) ;
    		    strcat (str, "\1");
    		    strcat (str, item_buf [z*return_buffer->columns+2]);
    		    strcat (str, "\1");
		
     		    status = MEMwrite (data_list, str);
		        if (status != MEM_S_SUCCESS)
    		      {
        			ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        			_NFMdebug ((fname, "MEMwrite : <0x%.8x>", status));
        			MEMclose(data_list);
        			return (status);
                   }			
           	}  /* for z */
          NO_ROW_FUND = 1;

        } /* if status */
    
	MEMclose (&return_buffer) ;
   } /* for i */

   if (NO_ROW_FUND == 0)
    {
      status = ERRload_struct(NFM, NFM_E_NO_ITEMS_FOUND_IN_CAT, NULL, NULL);
       if(status!=ERR_S_SUCCESS)
       _NFMdebug((fname, "NFM_E_FAILURE <0x%.8x>\n", status));
       return(status);
     }

/* MEMprint_buffers("list2", data_list, "/dev/console");*/

 status = MEMbuild_array(data_list);
  if (status !=MEM_S_SUCCESS)
     {
        ERRload_struct(NFM, NFM_E_MEM, "", NULL);
       _NFMdebug((fname, "MEMbuild_array :0x%.8x\n", status));
        MEMclose(&data_list);
        return(status);
     }
  column_ptr1 = (char **) data_list ->column_ptr;
  data_ptr1 = (char**) data_list -> data_ptr;

    fdata.num_of_rows = data_list->rows;
    fdata.num_of_cols = data_list ->columns;
    tot_data = fdata.num_of_cols * fdata.num_of_rows;
    fdata.freeze_rows_count = 0;
    fdata.freeze_cols_count = 0;
    fdata.max_indent = 0;
    fdata.select_set_expected = SELECT_SET_MULTI_ROW;
    fdata.col_size = (int *) malloc (fdata.num_of_cols * sizeof (int));
    memset (fdata.col_size, 0, (fdata.num_of_cols * sizeof (int)));

    fdata.col_size[0] = 15;
    fdata.col_size[1] = 15;
    fdata.col_size[2] = 15;
    fdata.col_size[3] = 13;

    fdata.col_pos = (int *) malloc (fdata.num_of_cols * sizeof (int));
    memset (fdata.col_pos, 0 , (fdata.num_of_cols * sizeof (int)));


    pos =0;
    for (i=0; i<data_list ->columns; ++i)
     {
        fdata.col_pos[i] =pos;
        pos += fdata.col_size[i] +2;
     }    
   
    fdata.col_just = (int *) malloc (fdata.num_of_cols * sizeof (int));
    memset (fdata.col_just, LEFT_JUSTIFIED, (fdata.num_of_cols * sizeof (int)));

    fdata.h1_pos = (int *) malloc (sizeof (int) + 1);
    memset (fdata.h1_pos, 0, sizeof (int) + 1);
    fdata.h1_pos[0] = 0;
    fdata.h1_pos[1] = -1;

    fdata.h2_pos = (int *) malloc ((fdata.num_of_cols * sizeof (int)) + 1);
    memset (fdata.h2_pos, 0, (fdata.num_of_cols * sizeof (int)) + 1);
    for (i=0; i<data_list->columns; ++i)
	fdata.h2_pos[i] = fdata.col_pos[i];

    fdata.h2_pos[i] = -1;
    
    fdata.h3_pos = (int *) malloc (sizeof (int) + 1);
    memset (fdata.h3_pos, 0, sizeof (int) + 1);
    fdata.h3_pos[0] = 0;
    fdata.h3_pos[1] = -1;
    
    fdata.h1_data = (char **) malloc (sizeof (char *));
    memset (fdata.h1_data, NULL, (sizeof (char *)));
    NFMput_string (&fdata.h1_data[0], "");
    
    fdata.h2_data = (char **) malloc (fdata.num_of_cols * (sizeof (char *)));
    memset (fdata.h2_data, NULL, fdata.num_of_cols * (sizeof (char *)));
    for (i=0; i<data_list->columns; ++i)
         NFMput_string (&fdata.h2_data[i], column_ptr1[i]);
 
    fdata.h3_data = (char **) malloc (sizeof (char *));
    memset (fdata.h3_data, NULL, (sizeof (char *)));
    NFMput_string (&fdata.h3_data[0], "");

    sprintf (fdata.title, "Item Listing");

    fdata.select_set = (int *) malloc (tot_data * sizeof (int));
    memset (fdata.select_set, 0, (tot_data * sizeof (int)));

   /* allocate and initialize space to store data */ 

    fdata.data = (char **) malloc (tot_data * sizeof (char *));
    memset (fdata.data, NULL, (tot_data * sizeof (char *)));
/*  data  */ 

    for (i=0; i<tot_data; ++i)
        NFMput_string (&fdata.data[i], data_ptr1[i]);

/* PS */
    SCdisplay_msg (" ");
    SCdisplay_ref("<PF1> To Select Individual Item(s) Or <PF4> For All Items.");

    status = SCprocess_free_form (&fdata,  NFMprint_file);
    SCclear_ref ();

    if(fdata.sts == FORM_CANCELED)
    {
        _NFMdebug((fname,  "Cancel from form. Return."));
        NFMfree_list (fdata.data,  fdata.num_of_rows,  fdata.num_of_cols);
        free (fdata.data);
        ERRload_struct( NFI,  NFI_W_FORM_CANCELED,  NULL,  NULL );
        return (NFI_W_FORM_CANCELED);
    }
/* PS */
    SCdisplay_msg (" ");
    SCdisplay_msg ("Working..");

    count = 0;
    for (i=0; i<fdata.num_of_rows; ++i)
        {
        if ((fdata.select_set[i] == 1) || (fdata.sts == FORM_SELECTED))
            {
        	    count = i * fdata.num_of_cols;
               _NFMdebug((fname, "Repairing Catalog\n"));

            sprintf (file_str,"SELECT n_itemnum FROM f_%s \
            WHERE n_fileversion > 0", fdata.data [count]) ;

            sprintf (file_strs,"SELECT n_itemnum FROM f_%s \
            WHERE n_fileversion = 0 AND n_fileco IS NULL AND \
            n_couser != '' and n_cosano IS NOT NULL", fdata.data [count]);

            sprintf (file_str_no,"SELECT n_itemnum FROM f_%s \
            WHERE n_fileversion = 0 AND n_filenum = 1", fdata.data[count]);

            _NFMdebug ((fname, "file_str -> %s\n", file_str)) ;

             sprintf(qry_file, "SELECT n_itemno FROM %s WHERE \
                  n_itemname = '%s' and n_status ='%s'"\
                  ,fdata.data[count], fdata.data[count+1],
                  fdata.data[count+3]);

            _NFMdebug ((fname, "file_str -> %s\n", file_str)) ;

           sprintf ( qry_str_cat, "select n_pcatalogno, n_pitemno\
             ,n_citemno from nfmsetcit where n_type = 'P' and \
              (n_pitemno IN (%s) OR n_citemno IN (%s))",qry_file,qry_file);

        status = SQLquery (qry_str_cat,  &return_buffer_cat, 2*MEM_SIZE);
        if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
          {
             MEMclose (&return_buffer_cat);
              ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
             return (NFM_E_SQL_QUERY) ;
          }

        if (status == SQL_I_NO_ROWS_FOUND) {
          set_not_found = 1;
          _NFMdebug ((fname, "Item is not a Set \n")) ;
	} else {
          set_not_found =0;
          _NFMdebug ((fname, "Item is a Set \n")) ;
	}

        if (set_not_found==0)
        {
          status = MEMbuild_array(return_buffer_cat);

          column_ptr3 = (char **) return_buffer_cat->column_ptr;
          data_ptr3 = (char **) return_buffer_cat->data_ptr;

      /*    MEMprint_buffers("act2", return_buffer_cat, "/dev/console");*/

        sprintf(qry_cat_name, "SELECT n_catalogname FROM nfmcatalogs WHERE \
                           n_catalogno = %d", atol(data_ptr3[0]));

        sprintf(qry_files, "SELECT n_itemno FROM %s WHERE \
                 n_itemname = '%s' and n_status = '%s' AND n_itemno =%d\
                  OR n_itemno= %d",
                  fdata.data[count], fdata.data[count+1], fdata.data[count+3],
                  atol(data_ptr3[1]),atol(data_ptr3[2]));
       }
       else
        {
         strcpy(qry_files, "0");
         strcpy(qry_cat_name, "''");
        }
/* Cancel Set Check Out Conditon is also added - PS */
        sprintf (sql_act, " SELECT n_date, n_commandname, n_catalogname \
                from nfmactivity where (n_catalogname IN (%s) \
                OR n_catalogname = '%s') \
                and n_itemname = '%s' and \
                n_itemrev= '%s' and (n_commandname = 'Check Out Item' \
                OR n_commandname = 'Check Out Set' OR n_commandname \
                = 'Check In Item' OR n_commandname = 'Check In Set' \
                OR n_commandname = 'Cancel Set Check Out' \
                 OR n_commandname = 'Add Item') and n_successfail = 0 \
                 order by n_date DESC", qry_cat_name,
                fdata.data[count], fdata.data[count+1],
                fdata.data[count+2]);

        _NFMdebug((fname, "This is buffer from nfmactivity %s\n", sql_act));

        status = SQLquery (sql_act,  &return_buffer_act,  2*MEM_SIZE) ;
        if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
          {
             MEMclose (&return_buffer_act);
              ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
             return (NFM_E_SQL_QUERY) ;
          }
        /*MEMprint_buffers("act1", return_buffer_act, "/dev/console");*/

/**************************
   If no previous item activity can be retrieved from 'nfmactivity',
   ( may be due to purging activity log ) the item is a bad item.
    The item can't be repaired any more.  IGI 20 Dec 94 
**************************/
        if(status == SQL_I_NO_ROWS_FOUND)
        {
             MEMclose (&return_buffer_act);
             ERRload_struct (NFM, NFM_E_BAD_ITEM, "", NULL);
             return (NFM_E_SQL_QUERY) ;
        }

        status2 = MEMbuild_array(return_buffer_act);

        column_ptr2 = (char **) return_buffer_act->column_ptr;
        data_ptr2 = (char **) return_buffer_act->data_ptr;

        _NFMdebug((fname , "The return value is <%s>\n", data_ptr2[1]));

        if (status !=SQL_I_NO_ROWS_FOUND)
          {
           if (strcmp (data_ptr2[1], "Check In Item") == 0)
            {
              sprintf (sql_str,   "UPDATE %s SET n_status = 'I' \
              WHERE n_itemname ='%s' AND n_itemrev = '%s' AND n_status = 'TO' \
              OR n_status = 'TF' OR n_status = 'TD' OR n_status = 'TM'",
               fdata.data [count], fdata.data[count+1],
              fdata.data[count+2]);   

             _NFMdebug ((fname, "I qry - Check In Item  -> %s\n", sql_str)) ;
	 
             status = SQLstmt  (sql_str) ;
             if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
                 {
        	         _NFMdebug ((fname, "SQLstmt failed : status =<0x%.8x>\n",
	                     status)) ;
                      ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
                     return (NFM_E_SQL_QUERY) ;
                 }
            }
/* PS - added Cancel Set Check Out condition which is equivalent to 
Check In Set */
            else if ( ((strcmp (data_ptr2[1], "Check In Set") == 0) ||
                       (strcmp (data_ptr2[1], "Cancel Set Check Out") == 0)) &&
                   set_not_found==0)
             {
/* PS - TI condition added */
               sprintf (sql_str_set,   "UPDATE %s SET n_status = 'I' \
               WHERE n_itemname='%s' AND n_itemrev='%s' \
               AND n_status = 'TO' OR n_status = 'TF' OR n_status = 'TD' \
               OR n_status = 'TM' OR n_status = 'TI' AND n_itemno =%d",
               fdata.data [count],  fdata.data[count+1], fdata.data[count+2],
               atol(data_ptr3[1]));

            _NFMdebug ((fname, "Update qry - Check In Set  -> %s\n", sql_str)) ;

              status = SQLstmt  (sql_str_set) ;
              if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
               {
                  _NFMdebug ((fname, "SQLstmt failed : status = <0x%.8x>\n",
                    status));
                   ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
                  return (NFM_E_SQL_QUERY) ;
                }

              _NFMdebug((fname, "the status is <0x%.8x>\n", status));
              
               sprintf (sql_str_set1,   "UPDATE %s SET n_status = 'I' \
               WHERE n_status = 'TO' OR n_status = 'TF' OR n_status = 'TD' \
               OR n_status = 'TM' AND n_itemno =%d AND '%s' = '%s'",
               fdata.data [count] , atol(data_ptr3[2]), fdata.data[count],
               data_ptr2[2]);



/*              sprintf (sql_str_set1,  "UPDATE %s SET n_status = 'I' WHERE \
              n_status= 'TO' OR n_status = 'TF' OR n_status = 'TD' \  
              AND n_itemno=%d AND '%s' = '%s'",
              fdata.data [count] , atol(data_ptr3[2]), fdata.data[count], 
              data_ptr2[2]);
*/
              status = SQLstmt  (sql_str_set1) ;
              if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
                {
                  _NFMdebug ((fname, "SQLstmt failed : status = <0x%.8x>\n",
                    status));
                   ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
                  return (NFM_E_SQL_QUERY) ;
                }

              _NFMdebug((fname, "The right line\n"));

             _NFMdebug((fname, "the value for itemnum\n"));

             sprintf (sql_str_set2,   "UPDATE %s SET n_status = 'I' \
              WHERE n_itemname='%s' AND n_itemrev='%s' AND n_status = 'TO' \
               OR n_status = 'TF' OR n_status = 'TD' OR n_status = 'TM' \
                AND n_itemno=%d",
                fdata.data [count],  fdata.data[count+1], fdata.data[count+2],
                atol(data_ptr3[2]));

             status = SQLstmt  (sql_str_set2) ;
             if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
              {
                   ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
                  return (NFM_E_SQL_QUERY) ;
               }
               sprintf (sql_str_set3,   "UPDATE %s SET n_status = 'I' \
               WHERE n_status = 'TO' OR n_status = 'TF' OR n_status = 'TD' \
               OR n_status = 'TM' AND '%s' = '%s' \
               AND n_itemno = %d",
               fdata.data[count], fdata.data[count],
               data_ptr2[2], atol(data_ptr3[1]));

              status = SQLstmt  (sql_str_set3) ;
              if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
                {
                  _NFMdebug ((fname, "SQLstmt failed : status = <0x%.8x>\n",
                    status));
                   ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
                  return (NFM_E_SQL_QUERY) ;
                }
             }
          }
        if (strcmp(fdata.data[count+3], "TI")==0)
         {


        sprintf(qry_str, "SELECT n_fileno, n_filenum, n_fileversion, \
            n_cifilesize, n_cifilename, n_cisano, n_cofilename, \
            n_cosano, n_cidate, n_codate, n_ciuser, n_couser,n_fileco \
            FROM f_%s WHERE n_cosano IS NULL and n_couser IS NULL \
            and (n_itemnum IN (%s) OR n_itemnum IN (%s)) and \
            n_fileco = 'N' and n_fileversion = (select max(n_fileversion)\
            from f_%s where n_fileco= 'N' and (n_itemnum IN (%s) OR \
            n_itemnum IN (%s)))",fdata.data[count],
             qry_file,qry_files, fdata.data[count],qry_file, qry_files);
                     
          status = SQLquery (qry_str,  &file_buffer,  2*MEM_SIZE) ;
          if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
           {
             _NFMdebug((fname, "SQL_S_SUCCESS\n", status));
             MEMclose (&file_buffer);
             ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
             return (NFM_E_SQL_QUERY) ;
           }  
          if (status != SQL_I_NO_ROWS_FOUND)
           {
             status = MEMbuild_array(file_buffer);

             if(status != MEM_S_SUCCESS)
              {
                _NFMdebug((fname, "MEMbuild_arry = <0x%.8x>\n", status));
                MEMclose(&file_buffer);
                return(status);
              }

          data = (char **) file_buffer->data_ptr;
             
          for(j=0; j<file_buffer->rows; j++)
           {
             offset = j*file_buffer->columns;

             _NFMdebug((fname, "data : <0x%.8x>\n",j)); 
           /*   MEMprint_buffers("list", file_buffer, "/dev/console"); */
            
             sprintf (qry_str1, "DELETE FROM f_%s WHERE n_fileversion=%d \
                      and (n_itemnum IN (%s) OR n_itemnum IN (%s))", 
                      fdata.data[count], atol(data[offset+2]), qry_file,
                      qry_files);
             status = SQLstmt (qry_str1);
             _NFMdebug((fname, " the verson is <%d>\n", atol(data[offset+2])));
           }   /*for*/
       }  /*rows*/

            sprintf(qry_str, "SELECT n_fileno, n_filenum, n_fileversion, \
               n_cifilesize, n_cifilename, n_cisano, n_cofilename, \
               n_cosano, n_cidate, n_codate, n_ciuser, n_couser,n_fileco \
               FROM f_%s WHERE n_fileco = 'Y' and (n_itemnum IN (%s)OR \
                (n_itemnum IN (%s))) and n_fileversion = \
                (select max(n_fileversion) from \
                f_%s where n_fileco= 'Y' and (n_itemnum IN (%s) OR \
                  (n_itemnum IN (%s))))",
                  fdata.data[count],qry_file,qry_files,fdata.data[count],
                  qry_file, qry_files);
                     
          _NFMdebug((fname, "qry_str->%s\n", qry_str));

          status = SQLquery (qry_str,  &file_buffer,  2*MEM_SIZE) ;

          if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
           {
             _NFMdebug((fname, "SQL_S_SUCCESS\n", status));
             MEMclose (&file_buffer);
             ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
             return (NFM_E_SQL_QUERY) ;
           }  
          if (status != SQL_I_NO_ROWS_FOUND)
           {
             status = MEMbuild_array(file_buffer);
             if(status != MEM_S_SUCCESS)
              {
                _NFMdebug((fname, "MEMbuild_arry = <0x%.8x>\n", status));
                MEMclose(&file_buffer);
                return(status);
              }

             data = (char **) file_buffer->data_ptr;
             
             for(j=0; j<file_buffer->rows; j++)
              {
                offset = j*file_buffer->columns;

                _NFMdebug((fname, "data : <0x%.8x>\n",j)); 
      /*   MEMprint_buffers("list", file_buffer, "/dev/console"); */

                sprintf (qry_str1, "UPDATE f_%s SET n_fileco = 'N' \
                WHERE n_fileversion = %d and n_fileco = 'Y' and \
                (n_itemnum IN(%s) OR n_itemnum IN (%s))", fdata.data[count], 
                atol(data[offset+2]), qry_file, qry_files);
               _NFMdebug((fname, " This is for update f_cat %s\n", qry_str1));
                status = SQLstmt (qry_str1);
              }   /* for*/
        }  /* rows */
     }

/* Cancel Set Check Out Conditon is also added - PS */

        sprintf (sql_act1, " SELECT n_date, n_commandname, n_catalogname \
                from nfmactivity where (n_catalogname IN (%s) \
                OR n_catalogname = '%s') \
                and n_itemname = '%s' and \
                n_itemrev= '%s' and (n_commandname = 'Check Out Item' \
                OR n_commandname = 'Check Out Set' OR n_commandname \
                = 'Check In Item' OR n_commandname = 'Check In Set' \
                OR n_commandname = 'Cancel Set Check Out' \
                 OR n_commandname = 'Add Item') and n_successfail = 0 \
                 order by n_date DESC", qry_cat_name,
                fdata.data[count],fdata.data[count+1], 
                fdata.data[count+2]);

/*  _NFMdebug((fname, "This is buffer from nfmactivity %s\n", sql_act1));*/

        status = SQLquery (sql_act1,  &return_buffer_act,  2*MEM_SIZE) ;
        if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
          {
             MEMclose (&return_buffer_act);
              ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
             return (NFM_E_SQL_QUERY) ;
          }
    /*    MEMprint_buffers("act1", return_buffer_act, "/dev/console"); */
        
        status2 = MEMbuild_array(return_buffer_act);

        column_ptr2 = (char **) return_buffer_act->column_ptr;
        data_ptr2 = (char **) return_buffer_act->data_ptr;

        _NFMdebug((fname , "The return value is <%s>\n", data_ptr2[1]));    

        if (status !=SQL_I_NO_ROWS_FOUND)
          {
            if (strcmp (data_ptr2[1] , "Check Out Item") == 0) 
             {
               sprintf (sql_str,   "UPDATE %s SET n_status = 'O' \
               WHERE n_itemname='%s' AND n_itemrev='%s' AND n_status = 'TI' \
               OR n_status = 'TF' OR n_status ='TM' AND n_itemno IN (%s)",
                fdata.data[count], 
               fdata.data[count+1], fdata.data[count+2],file_str);

              status = SQLstmt  (sql_str) ;
            if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
                {
                   ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
                  return (NFM_E_SQL_QUERY) ;
                }
              _NFMdebug((fname, " The value of here <%s>\n", sql_str));

             }   /* strcmp */

            else if ((strcmp (data_ptr2[1] , "Check Out Set") == 0)||
                 (strcmp (data_ptr2[1] , "Add Item") == 0) && set_not_found==0)
             {
               _NFMdebug((fname, "value is <%s>>\n", data_ptr2[1]));

               sprintf (sql_str_s,   "UPDATE %s SET n_status = 'S' \
               WHERE n_itemname='%s' AND n_itemrev='%s' \
               AND n_status = 'TI' OR n_status = 'TF' AND n_itemno =%d \
                AND n_itemno IN (%s)", fdata.data [count], fdata.data[count+1],
			 fdata.data[count+2], atol(data_ptr3[1]), file_str);

              status = SQLstmt  (sql_str_s) ;
              if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
                {
                  _NFMdebug ((fname, "SQLstmt failed : status = <0x%.8x>\n",
                    status));
                   ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
                  return (NFM_E_SQL_QUERY) ;
                }

              _NFMdebug((fname, "the status is <0x%.8x>\n", status));

              sprintf (sql_str,   "UPDATE %s SET n_status = 'M' \
               WHERE n_status= 'TI' OR n_status = 'TF' OR n_status = 'TM' \
                 AND n_itemno IN (%s) \
               AND n_itemno=%d AND '%s' = '%s' AND n_itemno IN (%s)",
               fdata.data [count] ,file_str, atol(data_ptr3[2]), 
               fdata.data[count], data_ptr2[2], file_str);

              _NFMdebug((fname, "status M->sql_str<%s>\n", sql_str));
              status = SQLstmt  (sql_str) ;
              if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
                {
                  _NFMdebug ((fname, "SQLstmt failed : status = <0x%.8x>\n",
                     status));
                  ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
                  return (NFM_E_SQL_QUERY) ;
                }
               
              _NFMdebug((fname, "The right line\n"));

             _NFMdebug((fname, "the value for itemnum\n"));

             sprintf (sql_str_s4,   "UPDATE %s SET n_status = 'M' \
              WHERE n_itemname='%s' AND n_itemrev='%s' AND n_status = 'TI'\
              OR n_status = 'TF' OR n_status = 'TM' AND n_itemno = %d \
              AND n_itemno IN (%s)",
                fdata.data [count],  fdata.data[count+1], fdata.data[count+2],
                atol(data_ptr3[2]), file_str);

              _NFMdebug((fname, "status M->sql_str_s4<%s>\n", sql_str_s4));
             status = SQLstmt  (sql_str_s4) ;
             if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
              {
                  ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
                  return (NFM_E_SQL_QUERY) ;
              }

               sprintf (sql_str_s,   "UPDATE %s SET n_status = 'S' \
               WHERE n_status = 'TI' OR n_status = 'TF' AND '%s' = '%s' \
               AND n_itemno = %d \
               AND n_itemno IN (%s)",fdata.data[count], fdata.data[count],
               data_ptr2[2], atol(data_ptr3[1]), file_str);

              _NFMdebug((fname, "status S->sql_str_s<%s>\n", sql_str_s));
              status = SQLstmt  (sql_str_s) ;
              if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
                {
                  _NFMdebug ((fname, "SQLstmt failed : status = <0x%.8x>\n",
                    status));
                  ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
                  return (NFM_E_SQL_QUERY) ;
                }             
              sprintf (sql_str_s1,   "UPDATE %s SET n_status = 'SN' \
              WHERE n_itemname = '%s' AND n_itemrev = '%s' AND n_status = 'TI'\
              OR n_status = 'TF' AND n_itemno =%d  AND n_itemno IN (%s)", fdata.               data [count], fdata.data[count+1], fdata.data[count+2],
               atol(data_ptr3[1]), file_strs);

              _NFMdebug((fname, "status SN->sql_str_s1<%s>\n", sql_str_s1));
             status = SQLstmt  (sql_str_s1) ;
             if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
                {
                  _NFMdebug ((fname, "SQLstmt failed : status = <0x%.8x>\n",
                    status));
                   ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
                   return (NFM_E_SQL_QUERY) ;
                }

              sprintf (sql_str,   "UPDATE %s SET n_status = 'MN' \
               WHERE n_status= 'TI' AND n_itemno=%d\
               AND '%s' = '%s' AND n_itemno IN (%s)", fdata.data [count] ,
               atol(data_ptr3[2]), fdata.data[count],data_ptr2[2], file_strs);

              _NFMdebug((fname, "status MN->sql_str<%s>\n", sql_str));
              status = SQLstmt  (sql_str) ;
              if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
                {
                  _NFMdebug ((fname, "SQLstmt failed : status = <0x%.8x>\n",
                     status));
                  ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
                  return (NFM_E_SQL_QUERY) ;
                }

              sprintf (sql_str,   "UPDATE %s SET n_status = 'MN' \
               WHERE n_status= 'TI' AND n_itemname = '%s' AND n_itemrev =\
               '%s' AND n_itemno= %d AND n_itemno IN (%s)", 
               fdata.data [count] , fdata.data[count+1], fdata.data[count+2],
               atol(data_ptr3[2]), file_strs);

              _NFMdebug((fname, "status MN2->sql_str<%s>\n", sql_str));
              status = SQLstmt  (sql_str) ;
              if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
                {
                  _NFMdebug ((fname, "SQLstmt failed : status = <0x%.8x>\n",
                     status));
                  ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
                  return (NFM_E_SQL_QUERY) ;
                }

              sprintf (sql_string,   "UPDATE %s SET n_status = 'SN' \
              WHERE n_status = 'TI' AND '%s' = '%s' AND n_itemno= %d \
              AND n_itemno IN (%s)",
              fdata.data[count], data_ptr2[2], fdata.data[count],
              atol(data_ptr3[1]), file_strs);

              _NFMdebug((fname, "status SN2->sql_string<%s>\n", sql_string));
              status = SQLstmt  (sql_string) ;
              if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
                {
                  _NFMdebug ((fname, "SQLstmt failed : status = <0x%.8x>\n",
                    status));
                   ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
                   return (NFM_E_SQL_QUERY) ;

                }

            } /* strcmp */
          }

             sprintf (sql_str,   "UPDATE %s SET n_status = '' \
             WHERE n_itemname='%s' AND n_itemrev='%s' AND n_status = 'TI'\
             OR n_status = 'TF' OR n_status = 'TM' AND n_itemno NOT IN (%s)",
             fdata.data [count], fdata.data[count+1], fdata.data[count+2],
             file_str);

             status = SQLstmt  (sql_str) ;
             if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
                {
                   _NFMdebug ((fname, "SQLstmt failed : status =<0x%.8x>\n",
                            status));
                  ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
                  return (NFM_E_SQL_QUERY) ;
               }
         _NFMdebug ((fname, "SQLstmt got me here\n"));
         _NFMdebug ((fname, "value for itemname is %s\n", fdata.data[count]));
         _NFMdebug ((fname, "value for itemrev is %s\n", fdata.data[count+1]));

         if (strcmp(data_ptr2[1], "Add Item") == 0 && set_not_found==0)
          {
         _NFMdebug ((fname, "value for itemno is %d\n", atol(data_ptr3[1])));
         _NFMdebug ((fname, "value for itemno is %s\n", file_str));
         _NFMdebug ((fname, "value for commandsis %d\n", data_ptr2[1]));
               
               sprintf (file_str_2,   "UPDATE %s SET n_status = '' \
               WHERE n_itemname='%s' AND n_itemrev='%s' \
               AND n_status = 'TI' OR n_status = 'TF' OR n_status = 'TM' \
               AND n_itemno =%d AND n_itemno IN (%s)", 
               fdata.data [count],  fdata.data[count+1],  
              fdata.data[count+2], atol(data_ptr3[1]), file_str_no);

               _NFMdebug ((fname, "the value of data_ptr3 is :<%d>\n",
                         atol(data_ptr3[1])));           

              status = SQLstmt  (file_str_2) ;
              if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
                {
                  _NFMdebug ((fname, "SQLstmt failed : status = <0x%.8x>\n",
                    status));
                  ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
                  return (NFM_E_SQL_QUERY) ;
                }
              _NFMdebug ((fname, " secound time round\n"));

              sprintf (file_str_3,   "UPDATE %s SET n_status = '' \
               WHERE n_status= 'TI' OR n_status = 'TF' OR n_status = 'TM' \
               AND n_itemno IN (%s) \
               AND n_itemno=%d AND '%s' = '%s'",
               fdata.data [count],  file_str_no, atol(data_ptr3[2]),
               fdata.data[count], data_ptr2[2]);
               
              status = SQLstmt  (file_str_3) ;
              if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
                {
                  _NFMdebug ((fname, "SQLstmt failed : status = <0x%.8x>\n",
                     status));
                  ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
                  return (NFM_E_SQL_QUERY) ;
                }

             sprintf (file_str_4,   "UPDATE %s SET n_status = '' \
              WHERE n_itemname='%s' AND n_itemrev='%s' AND n_status = 'TI' \
              OR n_status = 'TF' OR n_status = 'TM' AND n_itemno = %d \
              AND n_itemno IN (%s)",
                fdata.data [count],  fdata.data[count+1], fdata.data[count+2],
                atol(data_ptr3[2]), file_str_no);

             status = SQLstmt  (file_str_4) ;
             if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
              {
                  ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
                  return (NFM_E_SQL_QUERY) ;
               }
             sprintf (file_str_5,   "UPDATE %s SET n_status = '' \
             WHERE n_status = 'TI' OR n_status = 'TF' OR n_status = 'TM' \
             AND '%s' = '%s' AND n_itemno = %d AND n_itemno IN (%s)",
               fdata.data[count], fdata.data[count], data_ptr2[2], 
               atol(data_ptr3[1]), file_str_no);

              status = SQLstmt  (file_str_5) ;
              if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
                {
                  _NFMdebug ((fname, "SQLstmt failed : status = <0x%.8x>\n",
                    status));
                 ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
                 return (NFM_E_SQL_QUERY) ;
                }
             }
           }
     }

        NFMfree_list (fdata.data,  fdata.num_of_rows,  fdata.num_of_cols);
        free (fdata.data);

  status = MEMclose(&out_list);
/*  MEMprint_buffers("list3", out_list, "/dev/console");*/

  if(status != MEM_S_SUCCESS)
  {
     ERRload_struct (NFM,  NFM_E_MEM,  "",  NULL);
     _NFMdebug ((fname,  "MEMwrite : <0x%.8x>",  status));
     MEMclose(data_list);
     return (status); 
  }

    NFAmake_msg (msg);
    SCdisplay_ref(msg);
    _NFMdebug ((fname, "%s", "EXIT\n"));

     return (NFM_S_SUCCESS);
}
