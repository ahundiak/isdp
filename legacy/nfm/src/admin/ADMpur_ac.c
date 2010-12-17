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
#include "ERR.h"
#include "NFIerrordef.h"
#include "NFIcommands.h"

extern long sqlstatus;
extern char NFMprint_file[] ;

long ADMactivity ()

{
    long   status;
    int    i, j, z , k;
	int    tot_data;
	int    count;
	int    pos;
    int    flag;
	struct SCcolumn_data_st data;
	char   sql_str[512];
	char   qry_str[512];
    char   display_str[20];
    char   datetime_str[20];
    char   datetime[20];
	char   **data_ptr;
        char   user_date[15];
	int    FORM_FILLED;
	MEMptr out_list = NULL;

	static char *fname = "ADMactivity";

    _NFMdebug ((fname, "ENTER\n"));

    SCdisplay_msg ("Working..");   
    status= ADMpurge_activity(NFMuser_id,&out_list);

 if (status != NFM_S_SUCCESS)
     {
        _NFMdebug((fname, "ADMpurge_activity:0x%.8x\n", status));
        ERRload_struct(NFM, NFM_E_ACT_EMPTY, NULL, NULL);
        return (status);
      }

    status = MEMbuild_array (out_list);
    /*MEMprint_buffers("list", out_list, "/dev/console");*/

    data_ptr = (char **) out_list->data_ptr;
 
    data.num_of_rows =2;
    data.num_of_cols =2;
    tot_data = data.num_of_cols * data.num_of_rows;
    data.freeze_rows_count = 0;
    data.select_set_expected = FALSE;
    data.col_width = (int *) malloc (data.num_of_cols * sizeof (int));
    memset (data.col_width, 0, (data.num_of_cols * sizeof (int)));
 
    data.col_width[0] =40;
    data.col_width[1] =20;
    data.new_rows_expected = FALSE;
    sprintf (data.title, "%s","Cleanup NFMactivity Table");
  
    data.selectable = (int *) malloc (tot_data * sizeof (int));
    memset (data.selectable, 0, (tot_data * sizeof (int)));
    data.selectable[3] = 1;
    
    data.hidden = (int *) malloc (tot_data * sizeof (int));
    memset (data.hidden, 0, (tot_data * sizeof (int)));

    /* allocate and initialize space to store data */

    data.data = (char **) malloc (tot_data * sizeof (char *));
    memset (data.data, NULL, (tot_data * sizeof (char *)));

      for(i=0; i<out_list->rows;++i)
      {      
       NFMput_string (&data.data[0], "NFMactivity Table starts On ");
       NFMput_string (&data.data[1],data_ptr[i]);
       NFMput_string (&data.data[2],"Enter The Date You Like To Purge Before");
       NFMput_string (&data.data[3],"");
      }        

    /* process column form  */
    do
      {
        FORM_FILLED = TRUE;
        status = SCprocess_column_form (&data,  NFMprint_file);
        SCclear_msg ();
       _NFMdebug((fname,"return from SCprocess _column <0x%.8x>\n",data.sts));
       
        if (data.sts !=FORM_CANCELED)
         {
             /* make string valid length and strip trailing blanks */

                status = NFMvalidate_string ("char(20)", data.data[3]);

                if (strcmp (data.data[3], "") == 0)
                 {
                   FORM_FILLED = FALSE;
                   SCdisplay_msg ("NFM:  Must Enter Desired Date.");
                 }
          }
     }
     while ((FORM_FILLED == FALSE) && (data.sts != FORM_CANCELED));            

       if (data.sts == FORM_CANCELED)
        {

          NFMfree_list (data.data, data.num_of_rows, data.num_of_cols);
          free (data.data);
          ERRload_struct (NFI, NFI_W_FORM_CANCELED, NULL, NULL);
          return (NFI_W_FORM_CANCELED);
        }
  
         status = NFMascii_to_timestamp_format (data.data[1], display_str);
          
         status = NFMascii_to_timestamp_format (data.data[3], datetime_str);

            sprintf (sql_str,"DELETE FROM nfmactivity\
            WHERE n_date BETWEEN TIMESTAMP '%s' and TIMESTAMP '%s'",
                  display_str, datetime_str);



            status = SQLstmt (sql_str);

             if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
              {
                _NFMdebug ((fname, "SQLstmt failed : status =<0x%.8x>\n",
                             status)) ;
                return (NFM_E_SQL_STMT) ;
              }

        NFMfree_list (data.data,  data.num_of_rows,  data.num_of_cols);
        free (data.data);

    _NFMdebug ((fname, "%s", "EXIT\n"));

     return (NFM_S_SUCCESS);
}
