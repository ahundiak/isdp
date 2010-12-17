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
#include "NFMstruct.h"
/* Following line is added by MVR for getting the NFMprint_file declaration 
    18/11/93*/
#include "NFMRextern.h"
extern long sqlstatus;
extern struct NFMglobal_st NFMglobal;
char   flag_env=1;

long ADMget_env(envname)
char   *envname;
{
long   status;
int    i, j, k, count;
int    confirm;
int    tot_data;
int    FORM_FILLED;
struct SCfree_data_st fdata;
struct SCcolumn_data_st data;
char   env_name[20];
char   msg[200];
MEMptr output_buffer = NULL ;
char   **data1 ;
char   **data2;
char   **data3;
char   str[200];
char   sql_str[200];

static char   *fname = "NFMget_env";

    _NFMdebug ((fname, "ENTER\n"));

    status = NETLs_nodes_nfme("nfme_",&output_buffer);
 
    if (status != NFM_S_SUCCESS)
     {
        _NFMdebug((fname, "NETLs_nodes_nfme Is Empty\n"));
        ERRload_struct(NFM, NFM_E_FAILURE, "",NULL );
        return (status);
     }
 
    _NFMdebug ((fname, "NFMLs_nodes_nfme : <0x%.8x>\n", status));

    status = MEMbuild_array (output_buffer) ;
    if (status != MEM_S_SUCCESS)
      {
	_NFMdebug ((fname, "MEMbuild_array : <0x%.8x>\n", status));
        ERRload_struct (NFM, NFM_E_MEM, "%s%s", fname, "MEMbuild_array");
	return (NFM_E_MEM) ;
      }

    data1 = (char **) output_buffer->data_ptr ;

/*    MEMprint_buffers ("nodes", output_buffer, "/dev/console") ;*/
   
    _NFMdebug ((fname, "Get me here\n"));
    if (output_buffer->rows==0)
     {

       status = NFM_E_BAD_ENV;
       _NFMdebug((fname, "no.of.row\n"));
       ERRload_struct(NFM, NFM_E_BAD_ENV,NULL, NULL);
       return (status);
     }
  _NFMdebug((fname, "Return Empty From List.\n"));

    fdata.num_of_rows = output_buffer->rows;         /* was = count */;
    fdata.num_of_cols = 1;
    tot_data = fdata.num_of_cols * fdata.num_of_rows;
    fdata.freeze_rows_count = 0;
    fdata.freeze_cols_count = 0 ;
    fdata.max_indent = 0;
    fdata.select_set_expected = SELECT_SET_SINGLE_ROW;
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


    for (i=0; i<output_buffer->rows; i++)
      {
           	NFMput_string (&fdata.data[i], data1 [i]) ;

        	_NFMdebug ((fname, "data : <%s>\n", data1 [i]));
      }
  
/*    MEMclose(&output_buffer);*/

    do
        {
          FORM_FILLED = FALSE;
         /* The missing second parameter added by MVR on 18/11/93 */
          status = SCprocess_free_form (&fdata,  NFMprint_file);
          SCclear_msg ();

          if (fdata.sts == FORM_ACCEPTED)
            {
            for (i=0; i<fdata.num_of_rows; ++i)
             {
                if (fdata.select_set[i] == 1)
                    {
                      FORM_FILLED = TRUE;
                      strcpy (env_name, fdata.data[i]);
                      break;
                    }
              }
            }
                if (FORM_FILLED == FALSE)
                     SCdisplay_msg ("NFM:  Must Choose Environment Node.");
      }
    while ((FORM_FILLED == FALSE) && (fdata.sts != FORM_CANCELED));

/*  The following if statement is inserted by MVR. otherwise a SEGV comes
    when a FROM_CANCELED happens -- MVR 18/11/93  */

    if (fdata.sts != FORM_CANCELED)
        strcpy (NFMglobal.environment_name, fdata.data[i]);
    if (fdata.sts == FORM_CANCELED)
        {
        _NFMdebug ((fname, "Cancel from form. Return.\n"));
        NFMfree_list (fdata.data, fdata.num_of_rows, fdata.num_of_cols);
        free (fdata.data);
        ERRload_struct (NFI, NFI_W_FORM_CANCELED, NULL, NULL);
        return (NFI_W_FORM_CANCELED);
        }

    NFMfree_list (fdata.data, fdata.num_of_rows, fdata.num_of_cols);
    free (fdata.data);

    _NFIdebug ((fname, "Environment Name : <%s>\n", env_name));

    ADMconfirm("delete this environment", &confirm);
    if (confirm == 0)
     { 
       return(status);
     }

    SCdisplay_msg ("Working..");    
  
    status = ADMdel_login ();

    if (status != NFM_S_SUCCESS)
     {
       return(status);
     }

    status = ADMdrop_table(NFMglobal.NFMuserid, env_name);

    if (status != NFM_S_SUCCESS)
     {
       return(status);
     }

    return(NFM_S_SUCCESS);
}
