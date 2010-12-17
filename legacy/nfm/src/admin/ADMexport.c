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

extern long sqlstatus;
extern NFMprint_file[];
extern struct NFMglobal_st NFMglobal;

long ADMget_exp_env()

{
long   status;
int    i, j, k;
int    pos = 0;
int    count=0;
int    tot_data;
int    FORM_FILLED;
struct SCfree_data_st fdata;
struct SCfree_data_st edata;
struct SCcolumn_data_st data;
char   env_name[20];
char   *dbpath;
char   *clh_status, *clh_vbyop();
char   NAME_SER [50];
char   SER_NAME[50];
MEMptr buffer = NULL ;
MEMptr output_buffer = NULL ;
MEMptr buffer2 = NULL;
char   cmd_line_passwd[30];
char   **data1 ;
char   **data2;
char   **datac2;
char   ENV_NAME[20];
char   msg[300];

static char   *fname = "ADMget_exp_env";
  
    _NFMdebug ((fname, "ENTER\n"));

    status = ADMfind_export_files("nfme_",&output_buffer);
   
    if (status != NFM_S_SUCCESS)
     {
        _NFMdebug((fname, "ADMfind_export_files status is :<0x%.8x>\n", status));
        return(status);
     }
     
    _NFMdebug ((fname, "ADMfind_export_files : <0x%.8x>\n", status));

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

    do
      {
        FORM_FILLED = FALSE;
       /* The missing second parameter  added by MVR  on 19/11/93 */
        status = SCprocess_free_form (&fdata, NFMprint_file);
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

    if (fdata.sts == FORM_CANCELED)
     {
        _NFMdebug ((fname, "Cancel from form. Return.\n"));
        NFMfree_list (fdata.data, fdata.num_of_rows, fdata.num_of_cols);
        free (fdata.data);
        ERRload_struct (NFI, NFI_W_FORM_CANCELED, NULL, NULL);
        return (NFI_W_FORM_CANCELED);
     }
/* set the env name only if status is not FORM_CANCELLED - PS IGI*/
    strcpy (NFMglobal.environment_name, fdata.data[i]);

    _NFIdebug ((fname, "Environment Name : <%s>\n", env_name));

    NFMfree_list (fdata.data, fdata.num_of_rows, fdata.num_of_cols);
    free (fdata.data);

    SCdisplay_msg ("Working..");    

    status = ADMLs_nodes_nfmexp ("nfms_",&buffer);
    if (status != NFM_S_SUCCESS)
      {
        _NFIdebug ((fname, "ADMLs_nodes_nfmexp : <0x%.8x>\n", status));
        ERRload_struct (NFM, NFM_E_FAILURE, NULL, NULL);
        return (NFM_E_FAILURE);
      }

    status = ADMLs_nodes_nfmexp ("nfmc_",&buffer2);
    if (status != NFM_S_SUCCESS)
      {
        _NFIdebug ((fname, "ADMLs_nodes_nfmexp : <0x%.8x>\n", status));
        ERRload_struct (NFM, NFM_E_FAILURE, NULL, NULL);
        return (NFM_E_FAILURE);
      }

    if (buffer->rows==0)
     {
       status = NFM_E_BAD_ENV;
       _NFMdebug((fname, "no.of.row\n"));
       ERRload_struct(NFM, NFM_E_BAD_ENV, NULL, NULL);
       return (status);
     }
    
    edata.num_of_rows = buffer->rows + buffer2->rows;
    edata.num_of_cols = 1;
    tot_data = edata.num_of_cols * edata.num_of_rows;
    edata.freeze_rows_count = 0;
    edata.freeze_cols_count = 0 ;
    edata.max_indent = 0;
    edata.select_set_expected = SELECT_SET_MULTI_ROW;
    edata.col_size = (int *) malloc (edata.num_of_cols * sizeof (int));
    memset (fdata.col_size, 0, (edata.num_of_cols * sizeof (int)));
    
    edata.col_size[0] = 25;

    edata.col_pos = (int *) malloc (edata.num_of_cols * sizeof (int));
    memset (fdata.col_pos, 0 , (edata.num_of_cols * sizeof (int)));
    
    edata.col_pos[0] = 0;

    edata.col_just = (int *) malloc (edata.num_of_cols * sizeof (int));
    memset (edata.col_just, LEFT_JUSTIFIED, (edata.num_of_cols * sizeof (int)));
    
    edata.h1_pos = (int *) malloc (sizeof (int) + 1);
    memset (fdata.h1_pos, 0, sizeof (int) + 1);
    edata.h1_pos[0] = 0;
    edata.h1_pos[1] = -1;

    edata.h2_pos = (int *) malloc ((edata.num_of_cols * sizeof (int)) + 1);
    memset (edata.h2_pos, 0, (edata.num_of_cols * sizeof (int)) + 1);
    edata.h2_pos[0] = 0;
    edata.h2_pos[1] = -1;
    
    edata.h3_pos = (int *) malloc (sizeof (int) + 1);
    memset (edata.h3_pos, 0, sizeof (int) + 1);
    edata.h3_pos[0] = 0;
    edata.h3_pos[1] = -1;
    
    edata.h1_data = (char **) malloc (sizeof (char *));
    memset (edata.h1_data, NULL, (sizeof (char *)));
    NFMput_string (&edata.h1_data[0], "");
    
    edata.h2_data = (char **) malloc (tot_data * (sizeof (char *)));
    memset (edata.h2_data, NULL, tot_data * (sizeof (char *)));
    NFMput_string (&edata.h2_data[0], "Valid I/NFM Server :");
    
    edata.h3_data = (char **) malloc (sizeof (char *));
    memset (edata.h3_data, NULL, (sizeof (char *)));
    NFMput_string (&edata.h3_data[0], "");
    
    sprintf (edata.title, "Choose Server File");

    edata.select_set = (int *) malloc (tot_data * sizeof (int));
    memset (edata.select_set, 0, (tot_data * sizeof (int)));

    /* allocate and initialize space to store data */

    edata.data = (char **) malloc (tot_data * sizeof (char *));
    memset (edata.data, NULL, (tot_data * sizeof (char *)));

    status = MEMbuild_array (buffer) ;
    if (status != MEM_S_SUCCESS)
      {
    	_NFMdebug ((fname, "MEMbuild_array : <0x%.8x>\n", status));
        ERRload_struct (NFM, NFM_E_MEM, "%s%s", fname, "MEMbuild_array");
    	return (NFM_E_MEM) ;
      }

    status = MEMbuild_array (buffer2);
    if (status != MEM_S_SUCCESS)
     {
        _NFMdebug ((fname, "MEMbuild_array : <0x%.8x>\n", status));
        ERRload_struct (NFM, NFM_E_MEM, "%s%s", fname, "MEMbuild_array");
        return (NFM_E_MEM) ;
      }
    _NFMdebug ((fname, "MEMbuild_array : <0x%.8x>\n", status));

    data2 = (char **) buffer->data_ptr ;
    datac2 = (char **) buffer2->data_ptr;

    for (i=0; i<buffer->rows; i++)
      {
    	NFMput_string (&edata.data[i], data2 [i]) ;
    	_NFMdebug ((fname, "data : <%s>\n", data2 [i]));
      }

    j = buffer->rows;
   
    for (i=0; i<buffer2->rows; i++)
      {
    	NFMput_string (&edata.data[j], datac2 [i]) ;
        j++;
    	_NFMdebug ((fname, "data : <%s>\n", datac2 [i]));
      }
/*
    MEMclose (&buffer2);
    _NFMdebug((fname, "MEMclose for buffer2 was success\n"));

    MEMclose (&buffer) ;
    _NFMdebug((fname, "MEMclose for buffer was success\n"));    
*/
        status = SCprocess_free_form (&edata, NFMprint_file);
        SCclear_msg ();

    if (fdata.sts == FORM_CANCELED)
      {
        _NFMdebug ((fname, "%s\n", "Cancel from form. Return."));
        NFMfree_list (edata.data, edata.num_of_rows, edata.num_of_cols);
        free (edata.data);
        ERRload_struct( NFI, NFI_W_FORM_CANCELED, NULL, NULL );
        return (NFI_W_FORM_CANCELED);
      }

    /*MEMprint_buffer ("buffer" , buffer, "/dev/console");
    MEMprint_buffer ("buffer2" , buffer, "/dev/console");*/

    count = 0;
    for (i=0; i<edata.num_of_rows; ++i)
     {
       if (edata.select_set[i] == 1)
        {
          if (i<buffer->rows)
           {
             sprintf(ENV_NAME, "nfms_%s", edata.data[i]);
             _NFMdebug((fname, "Print server name %s %d\n", ENV_NAME, i));
           }
          else
           {
             sprintf(ENV_NAME, "nfmc_%s", edata.data[i]);
             _NFMdebug((fname, "Print client name %s%d\n", ENV_NAME, i));
           }
          break;
        }
     }

    _NFIdebug ((fname, "Environment Name : <%s>\n", env_name));

    MEMclose (&buffer2);
    _NFMdebug((fname, "MEMclose for buffer2 was success\n"));

    MEMclose (&buffer) ;
    _NFMdebug((fname, "MEMclose for buffer was success\n"));    

    NFMfree_list (edata.data, edata.num_of_rows, edata.num_of_cols);
    free (edata.data);

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

    for (i=pos+1; i<tot_data; i+=data.num_of_cols)
    data.selectable[i] = 1;

    data.hidden = (int *) malloc (tot_data * sizeof (int));
    memset (data.hidden, 0, (tot_data * sizeof (int)));

    /* allocate and initialize space to store data */

    data.data = (char **) malloc (tot_data * sizeof (char *));
    memset (data.data, NULL, (tot_data * sizeof (char *)));


    data.data = (char **) malloc (tot_data * sizeof (char *));
    memset (data.data, NULL, (tot_data * sizeof (char *)));

    NFMput_string (&data.data[0], "Please Enter nfmadmin's UNIX Password For Remote Node.");
    NFMput_string (&data.data[1], "");

    /* hide password */
    data.hidden[1] = 1;

/* process column form until an workflow Name has been entered */
    do
        {
          FORM_FILLED = TRUE;
          status = SCprocess_column_form (&data, NFMprint_file);
          SCclear_msg ();

          _NFM_num ("return from SCprocess_column_form -> %d", data.sts);

        if (data.sts != FORM_CANCELED)
            {
              status = NFMvalidate_string ("char(30)", data.data[1]);
              if (strcmp (data.data[1], "") == 0)
                {
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

  SCdisplay_msg ("Working..");    

/*  sprintf(SER_NAME, "nfms_%s",ENV_NAME);*/

    strcpy ( SER_NAME, ENV_NAME);

  _NFMdebug ((fname, "Server Name = <%s>\n", SER_NAME));

  clh_status = clh_vbyop (SER_NAME, "Nodename", NAME_SER, 25);
  if (clh_status)
   {
     ERRload_struct (NETS, NET_E_MESSAGE, "%s", clh_status) ;
     status = ERRload_struct (NFM, NFM_E_CLH, "%s%s", "TEMPLATE", "NODENAME");
    _NFMdebug ((fname, "Get Nodename of Server: status = <0x%.8x>",NFM_E_CLH));
     return (NFM_E_CLH);
   }

  strcpy (SER_NAME,NAME_SER); 
   
  status = ADMexport_env(SER_NAME,"nfmadmin", cmd_line_passwd,env_name);
  _NFMRdebug((fname, "SER NAME is %s\n", SER_NAME)); 
  if (status != NFM_S_SUCCESS)
   {
     return (status);
   }
  return(NFM_S_SUCCESS);
}
