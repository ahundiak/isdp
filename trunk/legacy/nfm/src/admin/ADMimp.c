#include "machine.h"
#include <stdio.h>
#include "UNIX_or_VMS.h"
#include "NFMerrordef.h"
#include "NFMdef.h"
#include "MEMstruct.h"
#include "MEMerrordef.h"
#include "SCstruct.h"
#include "SCdef.h"
#include "ERR.h"
#include "NFIcommands.h"
#include "NFIerrordef.h"
#include "DEBUG.h"
#include  "NFMstruct.h"

extern struct NFMglobal_st NFMglobal;
extern long sqlstatus;
extern char NFMprint_file[];

long ADMget_heard_env()

{
long   status;
int    i, j, k, pos=0;
int    tot_data;
int    FORM_FILLED;
long   count = 0;
struct SCfree_data_st fdata;
struct SCcolumn_data_st data;
char   env_name[20];
char   node_name[30];
char   user_name[40];
char   passwd[40];
char   type[10];
MEMptr output_buffer = NULL ;
MEMptr list = NULL ;
char   **n_data ;
char   **data1 ;
char   **data2;
char   **col_name ;
char   cmd_line_passwd[30];


static char   *fname = "ADMget_heard_env";

    _NFMdebug ((fname, "ENTER\n"));

    data.num_of_rows = 1;
    data.num_of_cols =2;
    tot_data = data.num_of_cols * data.num_of_rows;
    data.freeze_rows_count = 0;
    data.select_set_expected = FALSE;
    data.col_width = (int *) malloc (data.num_of_cols * sizeof (int));
    memset (data.col_width, 0, (data.num_of_cols * sizeof (int)));

    data.col_width[0] = 60;
    data.col_width[1] = 10;
    data.new_rows_expected = FALSE;
    sprintf(data.title,"");

    data.selectable = (int *) malloc (tot_data * sizeof (int));
    memset (data.selectable, 0, (tot_data * sizeof (int)));

    data.selectable[1] = 1;

    data.hidden = (int *) malloc (tot_data * sizeof (int));
    memset (data.hidden, 0, (tot_data * sizeof (int)));

    /* allocate and initialize space to store data */

    data.data = (char **) malloc (tot_data * sizeof (char *));
    memset (data.data, NULL, (tot_data * sizeof (char *)));

    NFMput_string (&data.data[0], "Please Enter nfmadmin's UNIX Password For This Node.");
    NFMput_string (&data.data[1], "");

    /* hide password */
    data.hidden[1] = 1;

    /* process column form until an workflow Name has been entered */
    do
        {
        FORM_FILLED = TRUE;
        status = SCprocess_column_form (&data, NFMprint_file);
        SCclear_msg ();

        _NFMdebug ((fname,"return from SCprocess_column_form -> %d\n", data.sts));

        if (data.sts != FORM_CANCELED)
            {
             _NFMdebug ((fname, "data.data[1] = <%s>\n", data.data[1]));
               status = NFMvalidate_string ("char(10)", data.data[1]);
               if (strcmp (data.data[1], "") == 0)
                 {
                   _NFMdebug ((fname, "data.data[1] = <%s>\n", data.data[1]));
                    FORM_FILLED = FALSE;
                    SCdisplay_msg ("NFM:  Must Enter Your Passwd.");
                 }
            }
      }
    while ((FORM_FILLED == FALSE) && (data.sts != FORM_CANCELED));

    if (data.sts == FORM_CANCELED)
        {
        NFMfree_list (data.data, data.num_of_rows, data.num_of_cols);
        free (data.data);
        ERRload_struct( NFI, NFI_W_FORM_CANCELED, NULL, NULL );
        return (NFI_W_FORM_CANCELED);
        }
     /*  save the passwd */
    
     strcpy (cmd_line_passwd, data.data[1]);

  SCclear_ref ();
  SCdisplay_msg ("Working..");

  NFMfree_list (data.data, data.num_of_rows, data.num_of_cols);
  free (data.data);

    status = NETLs_nodes_nfmh("nfme_",&output_buffer);
    if (status != NFM_S_SUCCESS)
     {
        return (status);
     }
 
    _NFMdebug ((fname, "NFMLs_nodes_nfmh : <0x%.8x>\n", status));

/*    MEMprint_buffers ("nodes", output_buffer, "/dev/console") ;*/
       
    if (output_buffer->rows==0)
     {
       status = NFM_E_BAD_ENV;
       _NFMdebug((fname, "no.of.row\n"));
       ERRload_struct(NFM, NFM_E_BAD_ENV, NULL, NULL);
       return (status);
     }

    fdata.num_of_rows = output_buffer->rows;
    fdata.num_of_cols = 1;
    tot_data = fdata.num_of_cols * fdata.num_of_rows;
    fdata.freeze_rows_count = 0;
    fdata.freeze_cols_count = 0 ;
    fdata.max_indent = 0;
    fdata.select_set_expected = SELECT_SET_MULTI_ROW;
    fdata.col_size = (int *) malloc (fdata.num_of_cols * sizeof (int));
    memset (fdata.col_size, 0, (fdata.num_of_cols * sizeof (int)));
    
    fdata.col_size[0] = 25;

    fdata.col_pos = (int *) malloc (fdata.num_of_cols * sizeof (int));
    memset (fdata.col_pos, 0 , (fdata.num_of_cols * sizeof (int)));
    
    fdata.col_pos[0] = 0;

    fdata.col_just = (int *) malloc (fdata.num_of_cols * sizeof (int));
    memset (fdata.col_just, LEFT_JUSTIFIED, (fdata.num_of_cols * sizeof (int)));
    
    fdata.h1_pos = (int *) malloc (sizeof (int) + 1);
    memset (fdata.h1_pos, 0, sizeof (int) + 1);
    fdata.h1_pos[0] = 0;
    fdata.h1_pos[1] = -1;

    fdata.h2_pos = (int *) malloc ((fdata.num_of_cols * sizeof (int)) + 1);
    memset (fdata.h2_pos, 0, (fdata.num_of_cols * sizeof (int)) + 1);
    fdata.h2_pos[0] = 0;
    fdata.h2_pos[1] = -1;
    
    fdata.h3_pos = (int *) malloc (sizeof (int) + 1);
    memset (fdata.h3_pos, 0, sizeof (int) + 1);
    fdata.h3_pos[0] = 0;
    fdata.h3_pos[1] = -1;
    
    fdata.h1_data = (char **) malloc (sizeof (char *));
    memset (fdata.h1_data, NULL, (sizeof (char *)));
    NFMput_string (&fdata.h1_data[0], "");
    
    fdata.h2_data = (char **) malloc (tot_data * (sizeof (char *)));
    memset (fdata.h2_data, NULL, tot_data * (sizeof (char *)));
    NFMput_string (&fdata.h2_data[0], "Valid I/NFM Environments :");
    
    fdata.h3_data = (char **) malloc (sizeof (char *));
    memset (fdata.h3_data, NULL, (sizeof (char *)));
    NFMput_string (&fdata.h3_data[0], "");
    
    sprintf (fdata.title, "Choose Environment File");

    fdata.select_set = (int *) malloc (tot_data * sizeof (int));
    memset (fdata.select_set, 0, (tot_data * sizeof (int)));

    /* allocate and initialize space to store data */

    fdata.data = (char **) malloc (tot_data * sizeof (char *));
    memset (fdata.data, NULL, (tot_data * sizeof (char *)));

    status = MEMbuild_array (output_buffer) ;
    if (status != MEM_S_SUCCESS)
      {
    	_NFMdebug ((fname, "MEMbuild_array : <0x%.8x>\n", status));
        ERRload_struct (NFM, NFM_E_MEM, "%s%s", fname, "MEMbuild_array");
    	return (NFM_E_MEM) ;
      }

    data1 = (char **) output_buffer->data_ptr ;
    for (i=0; i<output_buffer->rows; i++)
      {
    	NFMput_string (&fdata.data[i], data1 [i]) ;
    	_NFMdebug ((fname, "data : <%s>\n", data1 [i]));
      }

    MEMclose (&output_buffer) ;

/*       The missong second parameter added by MVR on 19/11/93 */
        status = SCprocess_free_form (&fdata,  NFMprint_file);
        SCclear_msg ();

    if (fdata.sts == FORM_CANCELED)
        {
          _NFMdebug ((fname, "%s\n", "Cancel from form. Return."));
          NFMfree_list (fdata.data, fdata.num_of_rows, fdata.num_of_cols);
          free (fdata.data);
          ERRload_struct( NFI, NFI_W_FORM_CANCELED, NULL, NULL );
          return (NFI_W_FORM_CANCELED);
        }

         count = 0;
         for (i=0; i<fdata.num_of_rows; ++i)
           {
             if (fdata.select_set[i] == 1)
               {
                 count=i *fdata.num_of_rows;
                 strcpy (env_name, fdata.data[i]);
                 status = ADMget_import_info (env_name,cmd_line_passwd);
                 _NFMdebug((fname, " This a value for passwd <%s>\n", cmd_line_passwd));
/*
                 if (status!= NFM_S_SUCCESS)
                  {
                    ERRload_struct(NFM, NFM_E_INVALID_PASSWD, "", NULL);
                    return(NFM_E_INVALID_PASSWD);
                  }
*/
               }
           }

    _NFIdebug ((fname, "Environment Name : <%s>\n", env_name));

    NFMfree_list (fdata.data, fdata.num_of_rows, fdata.num_of_cols);
    free (fdata.data);

    SCdisplay_msg ("Working..");    

    return(NFM_S_SUCCESS);
}
