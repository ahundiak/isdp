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
#include "NFMstruct.h"
#include "DEBUG.h"
#include "ERR.h"
#include "NFIcommands.h"
#include "NFIerrordef.h" 
extern long sqlstatus;


extern struct NFMglobal_st NFMglobal;
long ADMnfs_clean()

{
long   status;
long   status4;
int    i,j;
int    tot_data;
int    pos;
int    count;
int    ret_status;
int    ROW_SELECT=TRUE;
struct SCfree_data_st fdata;
struct SCcolumn_data_st err_data;
int    tot_err_data;
char   **column_ptr;
char   **data_ptr;
char   **data;
char   msg[500];
char   msg_str[100];
char   mess[500];
char   err_str[150];
char   sql_str[1024];
char   user_name[100];
char   passwd[100];
MEMptr out_list = NULL;
MEMptr list = NULL;

static char *fname = "ADMnfs_clean";

    _NFMdebug ((fname, "%s", "ENTER\n"));

    SCdisplay_msg ("Working..");    


    status = ADMnode_list (NFMglobal.NFMuserid,&out_list);
    if (status != NFM_S_SUCCESS)
     {
        _NFMdebug((fname, "NFMlist_f status is :<0x%.8x>\n", status));
        ERRload_struct(NFM, NFM_E_DISPLAY_NODES, "", NULL);
        return(NFM_E_DISPLAY_NODES);
     }
    status = MEMbuild_array (out_list);
    if (status != MEM_S_SUCCESS)
     {
       _NFMdebug((fname, "MEMbuild_array status is : <0x%.8x>\n", status));
       ERRload_struct(NFM, NFM_E_MEM, NULL, NULL);
       return (status);
     }
    
    column_ptr = (char **) out_list->column_ptr;
    data_ptr = (char **) out_list->data_ptr;
    
    fdata.num_of_rows = out_list->rows;
    fdata.num_of_cols = out_list->columns;
    tot_data = fdata.num_of_cols * fdata.num_of_rows;
    fdata.freeze_rows_count = 0;
    fdata.freeze_cols_count = 0;
    fdata.max_indent = 0;
    fdata.select_set_expected =  SELECT_SET_MULTI_ROW;;
    fdata.col_size = (int *) malloc (fdata.num_of_cols * sizeof (int));
    memset (fdata.col_size, 0, (fdata.num_of_cols * sizeof (int)));
    
    fdata.col_size[0] = 15;
    
    fdata.col_pos = (int *) malloc (fdata.num_of_cols * sizeof (int));
    memset (fdata.col_pos, 0 , (fdata.num_of_cols * sizeof (int)));
    
    pos = 0;
    for (i=0; i<out_list->columns; ++i)
        {
        fdata.col_pos[i] = pos;
        pos += fdata.col_size[i] + 2;
        }

    fdata.col_just = (int *) malloc (fdata.num_of_cols * sizeof (int));
    memset (fdata.col_just, LEFT_JUSTIFIED, (fdata.num_of_cols * sizeof (int)));
    
    fdata.h1_pos = (int *) malloc (sizeof (int) + 1);
    memset (fdata.h1_pos, 0, sizeof (int) + 1);
    fdata.h1_pos[0] = 0;
    fdata.h1_pos[1] = -1;

    fdata.h2_pos = (int *) malloc ((fdata.num_of_cols * sizeof (int)) + 1);
    memset (fdata.h2_pos, 0, (fdata.num_of_cols * sizeof (int)) + 1);
    for (i=0; i<out_list->columns; ++i)
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
    for (i=0; i<out_list->columns; ++i)
        NFMput_string (&fdata.h2_data[i], column_ptr[i]);
    
    fdata.h3_data = (char **) malloc (sizeof (char *));
    memset (fdata.h3_data, NULL, (sizeof (char *)));
    NFMput_string (&fdata.h3_data[0], "");
    
    sprintf (fdata.title, "List of I/NFM nodes");

    fdata.select_set = (int *) malloc (tot_data * sizeof (int));
    memset (fdata.select_set, 0, (tot_data * sizeof (int)));

    /* allocate and initialize space to store data */

    fdata.data = (char **) malloc (tot_data * sizeof (char *));
    memset (fdata.data, NULL, (tot_data * sizeof (char *)));

    for (i=0; i<tot_data; ++i)
        NFMput_string (&fdata.data[i], data_ptr[i]);

SCdisplay_ref("<Enter> to Select; <PF1> to Accept; <PF4> to Select All; <PF3>  to Cancel");

    status = SCprocess_free_form (&fdata, NFMprint_file);
    SCclear_ref();
    
    if(fdata.sts == FORM_CANCELED)
    {
       _NFMdebug((fname,  "Cancel from form. Return."));
       NFMfree_list (fdata.data,  fdata.num_of_rows,  fdata.num_of_cols);
       free (fdata.data);
       ERRload_struct( NFI,  NFI_W_FORM_CANCELED,  NULL,  NULL );
       return (NFI_W_FORM_CANCELED);
    }

      SCclear_ref();
      SCdisplay_msg("Working...");

    /* set up error data form */

    err_data.num_of_rows = fdata.num_of_rows+2;
    err_data.num_of_cols = 2;
    tot_err_data = err_data.num_of_cols * err_data.num_of_rows;
    err_data.freeze_rows_count = 2;
    err_data.select_set_expected = FALSE;
    err_data.col_width = (int *) malloc (err_data.num_of_cols * sizeof (int));
    memset (err_data.col_width, 0, (err_data.num_of_cols * sizeof (int)));
    err_data.col_width[0] = 15;
    err_data.col_width[1] = 65;
    err_data.new_rows_expected = FALSE;
    strcpy (err_data.title, "Status/Error Information");
    err_data.selectable = (int *) malloc (tot_err_data * sizeof (int));
    memset (err_data.selectable, 0, (tot_err_data * sizeof (int)));

    err_data.hidden = (int *) malloc (tot_err_data * sizeof (int));
    memset (err_data.hidden, 0, (tot_err_data * sizeof (int)));

    /* allocate and initialize space to store data */

    err_data.data = (char **) malloc ((tot_err_data )* sizeof (char *));
    memset (err_data.data, NULL, ((tot_err_data ) * sizeof (char *)));

    NFMput_string (&err_data.data[0], "Nodename");
    NFMput_string (&err_data.data[1], "Status");
    NFMput_string (&err_data.data[2], "");
    NFMput_string (&err_data.data[3], "");

    status4= NFM_S_SUCCESS;   

    j=4;
    count = 0;
    for (i=0;i<fdata.num_of_rows; ++i)
     {
       if ((fdata.select_set[i] == 1) || (fdata.sts == FORM_SELECTED))
        {
          ROW_SELECT=FALSE;
          count = i * fdata.num_of_cols;
          sprintf (sql_str,   "SELECT DISTINCT n_username, n_passwd, %d\
          FROM nfmstoragearea WHERE n_nodeno = %d",
          atol(fdata.data[count+1]),atol(fdata.data[count+1]));
        
/* Call the SQL functions */

          status=SQLquery (sql_str, &list, 2* MEM_SIZE);
          if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
           {
             _NFMdebug((fname, "SQL query failed status <0x%.8x>\n", status));
              MEMclose (&list);
              return (status) ;
           }

        if (status == SQL_I_NO_ROWS_FOUND)
          {
            ERRload_struct(NFM, NFM_E_MESSAGE,  "%s",
            "No storage area exist for this node; No need to CLEANUP.", NULL);
            ERRget_message(msg);
            NFMput_string(&err_data.data[j], fdata.data[count]);
            NFMput_string(&err_data.data[j+1], msg);
            j= j+2;
            _NFMdebug(( fname, "NFAdisplay_elements : <0x%.8x>\n", status));
            continue;
          }

        status = MEMbuild_array(list);
        if (status != MEM_S_SUCCESS)
        {
          return(status);
         }
        data = (char **)list->data_ptr;
       _NFMdebug((fname, "I qry ->%s\n", sql_str));
       _NFMdebug((fname,"username is %s and passwd is %s and nodename is %s\n",
        data[0], data[1], fdata.data[count]));

       status = NFMfs_nfs_cleanup(fdata.data[count], data[0], data[1]);
       _NFMdebug((fname, "the value of node is <%s>, user name is <%s>, \
       passwd is <%s>\n", fdata.data[count], data[0], data[1]));

      if (status != NFM_S_SUCCESS)
        {
         sprintf(msg_str, "FAILED For Node <%s>...", fdata.data[count]);
         ERRget_message(msg);
         NFMput_string(&err_data.data[j],fdata.data[count]);
         NFMput_string(&err_data.data[j+1], msg);
         j= j+2;
         SCdisplay_msg (msg_str);
         _NFMdebug((fname,"This is FAILURE: <%d> \n", i));
         _NFMdebug((fname, "%d\n", status));
         status4 = status;
         }

         else
         {
          sprintf(msg_str, "SUCCESSFUL For Node <%s>..",fdata.data[count]);

          NFMput_string(&err_data.data[j],fdata.data[count]);
          ERRreset_struct();
          ERRget_message(msg);
          NFMput_string(&err_data.data[j+1], msg);
          j= j+2;
          _NFMdebug((fname,"This is SUCCESS: <%d> \n", i));
          SCdisplay_msg(msg_str);
          }

        MEMclose(&list);
    }
  }

   if (ROW_SELECT==FALSE)
    {
      SCdisplay_msg ("<PF1> or <PF3> to cancel form.");

      status = SCprocess_column_form (&err_data, NFMprint_file);

      NFMfree_list (fdata.data, fdata.num_of_rows, fdata.num_of_cols);
      free (fdata.data);

      NFMfree_list (err_data.data, err_data.num_of_rows, err_data.num_of_cols);
      free (err_data.data);
     }           
    else
      return(status);
      _NFMdebug ((fname, "%s", "EXIT\n"));
      return (NFM_S_SUCCESS);
 }


