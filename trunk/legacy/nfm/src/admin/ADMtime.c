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

long ADMtime_conf ()

{
        long   status;
        int    i, j, z , k;
	int    tot_data;
	int    count;
	int    pos;
    long   next_row_no;
    char   date_type [50] ;
	struct SCcolumn_data_st data;
	struct SCfree_data_st fdata;

	char   sql_str[512];
	char   qry_str[512];
	char   **data_ptr;

	int    FORM_FILLED;
	MEMptr out_list = NULL;

	static char *fname = "ADMtime_conf";


    _NFMdebug ((fname, "ENTER\n"));
    
    SCdisplay_msg ("Working..");        

  status = ADMadd_time_type (&next_row_no, date_type) ;

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

    sprintf (data.title, "%s","Configure The Time Format");
  
    data.selectable = (int *) malloc (tot_data * sizeof (int));
    memset (data.selectable, 0, (tot_data * sizeof (int)));

    data.selectable[3] = 1;
    
    data.hidden = (int *) malloc (tot_data * sizeof (int));
    memset (data.hidden, 0, (tot_data * sizeof (int)));

    /* allocate and initialize space to store data */

    data.data = (char **) malloc (tot_data * sizeof (char *));
    memset (data.data, NULL, (tot_data * sizeof (char *)));

      NFMput_string (&data.data[0],"This Is The Current Time Format");
      NFMput_string (&data.data[1], date_type) ;
      NFMput_string (&data.data[2],"Would Like To Change The Time Format [Y/N]"); 
      NFMput_string (&data.data[3],"Y");

    /* process column form  */
    do
      {
        FORM_FILLED = TRUE;
        status = SCprocess_column_form (&data,  NFMprint_file);
        SCclear_msg ();
        _NFMdebug((fname, "return from SCprocess _coluumn <0x%.8x>\n",data.sts));      
        if (data.sts !=FORM_CANCELED)
         {
             /* make string valid length and strip trailing blanks */
           for (i =1; i<tot_data; i+= data.num_of_cols)
            {
              if ( data.data[i] == 0)
               NFMput_string (&data.data[i], "");
              else 
                 status = NFMvalidate_string ("char(256)", data.data[i]);
             }

              status = NFMvalidate_string ("char(1)", data.data[3]);
              if ((strcmp (data.data[3], "Y") !=0) &&  
                (strcmp (data.data[3], "N") != 0) && 
                (strcmp (data.data[3], "y") !=0) &&
                (strcmp (data.data[3], "n") !=0))
               {
                FORM_FILLED = FALSE;
                SCdisplay_msg ("Date Format: Must Enter [Y/y/N/n] Only.");

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

          fdata.num_of_rows = 2;
          fdata.num_of_cols = 1;
          tot_data = fdata.num_of_rows * fdata.num_of_cols;
          fdata.freeze_rows_count = 0;
          fdata.freeze_cols_count = 0;
          fdata.max_indent = 0;
          fdata.select_set_expected = SELECT_SET_SINGLE_ROW;
          fdata.col_size = (int*) malloc (fdata.num_of_cols * sizeof(int));
          memset( fdata.col_size, 0, (fdata.num_of_cols * sizeof(int)));

          fdata.col_size[0] = 20;

          fdata.col_pos = (int*) malloc (fdata.num_of_cols * sizeof(int));
          memset( fdata.col_pos, 0, (fdata.num_of_cols * sizeof(int)));

          fdata.col_pos[0] = 0;

          fdata.col_just = (int*) malloc( fdata.num_of_cols * sizeof( int ));
          memset( fdata.col_just, LEFT_JUSTIFIED, (fdata.num_of_cols * sizeof(int )));

          fdata.h1_pos = (int *) malloc ( sizeof(int) * 2 );
          memset( fdata.h1_pos, 0, sizeof(int) * 2);
          fdata.h1_pos[0] = 0;
          fdata.h1_pos[1] = -1;
         fdata.h2_pos = (int *) malloc ((fdata.num_of_cols +1 ) * sizeof (int));
          memset (fdata.h2_pos, 0, (fdata.num_of_cols +1) * sizeof (int));
         fdata.h2_pos[0] = 0;
         fdata.h2_pos[1] = -1;
     
          fdata.h3_pos = (int*)malloc( sizeof(int) * 2);
          memset( fdata.h3_pos, 0, sizeof(int) * 2);
          fdata.h3_pos[0] = 0;
          fdata.h3_pos[1] = -1;

          fdata.h1_data = (char**) malloc ( sizeof(char*) );
          memset( fdata.h1_data, NULL, (sizeof (char*)));
          NFMput_string( &fdata.h1_data[0], "" );

          fdata.h2_data = (char**) malloc( tot_data * (sizeof(char*)));
          memset (fdata.h2_data, NULL, tot_data * (sizeof (char *)));
          NFMput_string (&fdata.h2_data[0], "");

          fdata.h3_data = (char**)malloc( sizeof(char*) );
          memset( fdata.h3_data, NULL, (sizeof(char*)));
          NFMput_string( &fdata.h3_data[0], "" );

          sprintf (fdata.title, "%s","Select Desired Time Format");

          fdata.select_set = (int*) malloc( tot_data * sizeof(int));
          memset( fdata.select_set, 0 , (tot_data * sizeof(int)));

          /* allocate and initialize space to store data */

          fdata.data = (char **) malloc ( tot_data * sizeof (char *));
          memset (fdata.data, NULL, (tot_data * sizeof (char *)));

          NFMput_string (&fdata.data[0], "24HR" );
          NFMput_string (&fdata.data[1], "12HR" );

          _NFMdebug((fname, "%s%s", fdata.data[0],fdata.data[1]));
          status = SCprocess_free_form( &fdata, NFMprint_file );
          SCclear_msg ();
          if(fdata.sts == FORM_CANCELED)
          {
           _NFMdebug((fname,  "Cancel from form. Return."));
           NFMfree_list (fdata.data,  fdata.num_of_rows,  fdata.num_of_cols);
           free (fdata.data);
           ERRload_struct( NFI,  NFI_W_FORM_CANCELED,  NULL,  NULL );
           return (NFI_W_FORM_CANCELED);
          }   
         count = 0;
         _NFMdebug ((fname, "This is a value of no of rows %d\n", fdata.num_of_rows));
         for (i =0; i < 2; ++i)
         _NFMdebug (( fname, " %d: select set <%d>\n", i,fdata.select_set[i]));

         for (i=0; i<fdata.num_of_rows; ++i)
          {      

            if (fdata.select_set[i] == 1)
             {
               count = i * fdata.num_of_cols;

              _NFMdebug((fname, "Changing The Date Format\n"));
              sprintf (qry_str,"UPDATE nfmsyscat SET n_description='%s'\
               WHERE n_infotype ='TIME_FORMAT'", fdata.data[count]);

             _NFMdebug ((fname, "I qry -> %s\n", sql_str)) ;

             status = SQLstmt  (qry_str) ;
               if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
                {
                  _NFMdebug ((fname, "SQLstmt failed : status =<0x%.8x>\n", status)) ;
                  return (NFM_E_SQL_QUERY) ;
                 }
             }
          }
        NFMfree_list (fdata.data,  fdata.num_of_rows,  fdata.num_of_cols);
        free (fdata.data);
       }

        NFMfree_list (data.data,  data.num_of_rows,  data.num_of_cols);
        free (data.data);

        _NFMdebug ((fname, "%s", "EXIT\n"));

     return (NFM_S_SUCCESS);
}
