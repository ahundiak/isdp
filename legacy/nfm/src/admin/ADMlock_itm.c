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

extern long sqlstatus;
extern char NFMprint_file[] ;

long ADMlock_item_config ()

{
        long   status;
        int    i, j, z , k;
	int    tot_data;
	int    count;
	int    pos;
	struct SCcolumn_data_st data;
	char   sql_str[512];
	char   qry_str[512];
	char   **data_ptr;
	char   **data_ptr1;

	int    FORM_FILLED;
	MEMptr out_list = NULL, return_buffer = NULL;
	MEMptr data_list = NULL;

	static char *fname = "ADMlock_item_conf";


    _NFMdebug ((fname, "ENTER\n"));
    
/*    SCdisplay_msg ("Working..");        */
        
     sprintf (qry_str, "SELECT n_description FROM nfmsyscat WHERE \
     n_infotype = 'COPY ITEM LOCK'");
     status = SQLquery (qry_str, &out_list, 2*MEM_SIZE);
     if (status != SQL_S_SUCCESS)
      {
         ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
        _NFMdebug ((fname, "SQL Qry Syntax : status = <0x%.8x>\n", status));
        return ( NFM_E_SQL_QUERY);
      }

    status = MEMbuild_array(out_list);
    data_ptr = (char **) out_list ->data_ptr;
           
    data.num_of_rows =2;
    data.num_of_cols =2;
    tot_data = data.num_of_cols * data.num_of_rows;
    data.freeze_rows_count = 0;
    data.select_set_expected = FALSE;
    data.col_width = (int *) malloc (data.num_of_cols * sizeof (int));
    memset (data.col_width, 0, (data.num_of_cols * sizeof (int)));
 
    data.col_width[0] =65;
    data.col_width[1] =2;
    data.new_rows_expected = FALSE;
    sprintf (data.title, "%s","Configure The Behavior Of The (LOCK ITEM) Command");
  
    data.selectable = (int *) malloc (tot_data * sizeof (int));
    memset (data.selectable, 0, (tot_data * sizeof (int)));

    data.selectable[3] = 1;
    
    data.hidden = (int *) malloc (tot_data * sizeof (int));
    memset (data.hidden, 0, (tot_data * sizeof (int)));

    /* allocate and initialize space to store data */

    data.data = (char **) malloc (tot_data * sizeof (char *));
    memset (data.data, NULL, (tot_data * sizeof (char *)));

     NFMput_string (&data.data[0], "Current Configuration");
     NFMput_string (&data.data[1], data_ptr[0]);
     NFMput_string (&data.data[2], "Is Copy Of Item Files Allowed On A Locked Item [Y/N]");
      NFMput_string (&data.data[3], "N");
 
    /* process column form  */
    do
      {
        FORM_FILLED = TRUE;
        status = SCprocess_column_form (&data,  NFMprint_file);
        SCclear_msg ();
        _NFMdebug((fname, "return from SCprocess _coluumn <0x%.8x>\n",
data.sts));      
        if (data.sts !=FORM_CANCELED)
         {
             /* make string valid length and strip trailing blanks */
            for (i=0; i<tot_data; i+=data.num_of_cols)
            {
              status = NFMvalidate_string ("char(1)", data.data[3]);
              if ((strcmp (data.data[3], "Y") !=0) &&  
                (strcmp (data.data[3], "N") != 0) && 
                (strcmp (data.data[3], "y") !=0) &&
                (strcmp (data.data[3], "n") !=0))
               {
                FORM_FILLED = FALSE;
                SCdisplay_msg ("Lock Item:  Must Enter [Y/y/N/n] Only.");

               }  
            }
         }
    } while ((FORM_FILLED == FALSE) && (data.sts != FORM_CANCELED));            

       if (data.sts == FORM_CANCELED)
        {

          NFMfree_list (data.data, data.num_of_rows, data.num_of_cols);
          free (data.data);
          ERRload_struct (NFI, NFI_W_FORM_CANCELED, NULL, NULL);
          return (NFI_W_FORM_CANCELED);
        }


    count = 0;
    for (i =0; i<data.num_of_rows; ++i)
      {
        if (data.selectable[i+3] == 1)
         {
             count = i*data.num_of_cols;

             if (strcmp(data.data[count+3], "y") == 0)
                strcpy (data.data[count+3], "Y");
             else if (strcmp (data.data[count+3], "n") == 0)
                strcpy (data.data[count+1], "N");
             else if (strcmp (data.data[count+3],"Y") == 0 ||
                  strcmp(data.data[count+3], "N") == 0)
             ;  /* do nothing */

            sprintf (sql_str,"UPDATE nfmsyscat SET n_description='%s'\
            WHERE n_infotype ='COPY ITEM LOCK'", data.data[count+3]);

             _NFMdebug ((fname, "I qry -> %s\n", sql_str)) ;

             status = SQLstmt  (sql_str) ;
             if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
              {
                _NFMdebug ((fname, "SQLstmt failed : status =<0x%.8x>\n",
                             status)) ;
                return (NFM_E_SQL_QUERY) ;
              }

         }
        else
             _NFMdebug((fname," option %d is NOT selected\n",i));
        }
        NFMfree_list (data.data,  data.num_of_rows,  data.num_of_cols);
        free (data.data);
/*
  status = MEMclose(&out_list);

  if(status != MEM_S_SUCCESS)
  {
     ERRload_struct (NFM,  NFM_E_MEM,  "",  NULL);
     _NFMdebug ((fname,  "MEMwrite : <0x%.8x>",  status));
     MEMclose(out_list);
     return (status);
  }
*/

    _NFMdebug ((fname, "%s", "EXIT\n"));

     return (NFM_S_SUCCESS);
}
