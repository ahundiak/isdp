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

long ADMblock_conf ()

{
        long   status;
        int    i, j, z , k;
	int    tot_data;
	int    count;
	int    pos;
    int    tot_bdata;
    long   next_row_no;
    long   block_type [50] ;
	struct SCcolumn_data_st data;
	struct SCcolumn_data_st bdata;

	char   sql_str[512];
	char   qry_str[512];
	char   **data_ptr;

	int    FORM_FILLED;
	MEMptr out_list = NULL;

	static char *fname = "ADMblock_conf";


    _NFMdebug ((fname, "ENTER\n"));
    
    SCdisplay_msg ("Working..");        

    status = ADMadd_block_type (&next_row_no, block_type) ;
    /*MEMprint_buffers("list", out_list, "/dev/console");*/

    data.num_of_rows =2;
    data.num_of_cols =2;
    tot_data = data.num_of_cols * data.num_of_rows;
    data.freeze_rows_count = 0;
    data.select_set_expected = FALSE;
    data.col_width = (int *) malloc (data.num_of_cols * sizeof (int));
    memset (data.col_width, 0, (data.num_of_cols * sizeof (int)));

    data.col_width[0] =50;
    data.col_width[1] =16;
 
    data.new_rows_expected = FALSE;

    sprintf (data.title, "%s","Choose block size for display commands");
  
    data.selectable = (int *) malloc (tot_data * sizeof (int));
    memset (data.selectable, 0, (tot_data * sizeof (int)));

    data.selectable[3] = 1;
    
    data.hidden = (int *) malloc (tot_data * sizeof (int));
    memset (data.hidden, 0, (tot_data * sizeof (int)));

    /* allocate and initialize space to store data */

    data.data = (char **) malloc (tot_data * sizeof (char *));
    memset (data.data, NULL, (tot_data * sizeof (char *)));

      NFMput_string (&data.data[0],"This Is The Current Block Listing");
      NFMput_string (&data.data[1], block_type) ;
      NFMput_string (&data.data[2],"Would Like To Change The Block Size [Y/N]"); 
      NFMput_string (&data.data[3],"Y");

/* PS */
    SCdisplay_msg (" ");        
 
    /* process column form  */
    do
      {
        FORM_FILLED = TRUE;
        status = SCprocess_column_form (&data,  NFMprint_file);
        SCclear_msg ();
        _NFMdebug((fname, "return from SCprocess _column <0x%.8x>\n",data.sts));
        if (data.sts !=FORM_CANCELED)
         {
            status = NFMvalidate_string ("char(1)", data.data[3]);
            if ((strcmp (data.data[3], "Y") !=0) &&  
            (strcmp (data.data[3], "N") != 0) && 
            (strcmp (data.data[3], "y") !=0) &&
            (strcmp (data.data[3], "n") !=0))
              {
                FORM_FILLED = FALSE;
                SCdisplay_msg ("Block Size: Must Enter [Y/y/N/n] Only.");
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

         if((strcmp(data.data[3], "y") == 0) ||
          (strcmp (data.data[3], "Y") == 0))
        {

          bdata.num_of_rows = 1;
          bdata.num_of_cols = 2;
          tot_bdata = bdata.num_of_rows * bdata.num_of_cols;
          bdata.freeze_rows_count = 0;
          bdata.select_set_expected = FALSE;
          bdata.col_width = (int *) malloc (bdata.num_of_cols * sizeof (int));
          memset (bdata.col_width, 0, (bdata.num_of_cols * sizeof (int)));

          bdata.col_width[0] =50;
          bdata.col_width[1] =16;
          bdata.new_rows_expected = FALSE;

          sprintf (bdata.title, "%s","Enter block size for display commands");

          bdata.selectable = (int *) malloc (tot_bdata * sizeof (int));
          memset (bdata.selectable, 0, (tot_bdata * sizeof (int)));

          bdata.selectable[1] = 1;

          bdata.hidden = (int *) malloc (tot_bdata * sizeof (int));
          memset (bdata.hidden, 0, (tot_bdata * sizeof (int)));

     /* allocate and initialize space to store data */

          bdata.data = (char **) malloc (tot_bdata * sizeof (char *));
          memset (bdata.data, NULL, (tot_bdata * sizeof (char *)));

          NFMput_string (&bdata.data[0],"Number Of Rows");
          NFMput_string (&bdata.data[1], "") ;
   
       /* process column form  */
    do
      {

          FORM_FILLED = TRUE;
          status = SCprocess_column_form (&bdata,  NFMprint_file);
          SCclear_msg ();
          _NFMdebug((fname, "return from SCprocess _column <0x%.8x>\n",bdata.sts));
          if (bdata.sts !=FORM_CANCELED)
           {
              /* make string valid length and strip trailing blanks */
              status = NFMvalidate_string ("char(256)", bdata.data[1]);
              _NFMdebug ((fname, "bdata.data[1] = <%s>\n", bdata.data[1]));

           }
          if (strcmp (bdata.data[1], "") == 0)
            {
                FORM_FILLED = FALSE;

                SCdisplay_msg ("NFM:  Must Enter Rows Number.");
             }
   } while ((FORM_FILLED == FALSE) && (bdata.sts != FORM_CANCELED));       

       if (bdata.sts == FORM_CANCELED)
        {
          NFMfree_list (bdata.data, bdata.num_of_rows, bdata.num_of_cols);
          free (bdata.data);
          ERRload_struct (NFI, NFI_W_FORM_CANCELED, NULL, NULL);
          return (NFI_W_FORM_CANCELED);
        }
/* PS */
    SCdisplay_msg ("Working..");        
 
          _NFMdebug((fname, "Changing Query Display Rows Count\n"));
          sprintf (qry_str,"UPDATE nfmsyscat SET n_description='%s'\
          WHERE n_infotype ='QUERY_ROW'", bdata.data[1]);

         _NFMdebug ((fname, "I qry -> %s\n", sql_str)) ;
         status = SQLstmt  (qry_str) ;
         if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
          {
            _NFMdebug ((fname, "SQLstmt failed : status =<0x%.8x>\n", status)) ;
             return (NFM_E_SQL_QUERY) ;
           }

        NFMfree_list (bdata.data,  bdata.num_of_rows,  bdata.num_of_cols);
        free (bdata.data);
      }

        NFMfree_list (data.data,  data.num_of_rows,  data.num_of_cols);
        free (data.data);

        _NFMdebug ((fname, "%s", "EXIT\n"));

     return (NFM_S_SUCCESS);
}
