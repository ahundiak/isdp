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
extern MSGptr NFMmsg_ptr;


long ADMvalidate_storage()

{
long   status;
int    i,j;
int    status4;
int    tot_data;
int    pos;
int    q;
int    count;
int    pcount;
int    err_pos;
int    ROW_SELECT=TRUE;
char   msg_str[500];
char   *d_sano;
char   *s_sano;
char   file[50];
char   new_file[50];
char   sql_str[1024];
struct SCfree_data_st fdata;
struct SCcolumn_data_st err_data;
int    tot_err_data;
int    FORM_FILLED = FALSE;
char   err_str[200];
char   **column_ptr;
char   **data_ptr;
MEMptr out_list = NULL;
static char *fname = "ADMvalidate_storage";


    _NFMdebug ((fname, "%s", "ENTER\n"));

/*AV message working added            */
    SCdisplay_msg ("Working..");
  
  sprintf(sql_str, "SELECT nfmnodes.n_nodename ,\
          nfmstoragearea.n_saname,nfmstoragearea.n_sano,\
    nfmstoragearea.n_devicetype, nfmstoragearea.n_pathname ,\
    nfmstoragearea.n_type, nfmstoragearea.n_nodeno \
    FROM nfmstoragearea, nfmnodes  WHERE \
    nfmstoragearea.n_devicetype ='%s' AND \
    nfmstoragearea.n_nodeno = nfmnodes.n_nodeno","HD");

  status = SQLquery (sql_str, &out_list, MEM_SIZE);
  if ((status != SQL_S_SUCCESS) && ((status) != SQL_I_NO_ROWS_FOUND))
   {
     MEMclose(&out_list);    
     ERRload_struct (NFM, NFM_E_BAD_ST_AREA, "", NULL);
    _NFMdebug ((fname,"NO Such Node : status = <0x%.8x>\n",NFM_E_BAD_ST_AREA));
     return (NFM_E_SQL_QUERY);
   }

/*    MEMprint_buffers("list", out_list, "/dev/console");*/
    MEMbuild_array (out_list);

    column_ptr = (char **) out_list->column_ptr;
    data_ptr = (char **) out_list->data_ptr;
   
    fdata.num_of_rows = out_list->rows;
    fdata.num_of_cols = out_list->columns;
    tot_data = fdata.num_of_cols * fdata.num_of_rows;
    fdata.freeze_rows_count = 0;
    fdata.freeze_cols_count =2 ;
    fdata.max_indent = 0;
    fdata.select_set_expected = SELECT_SET_MULTI_ROW;
    fdata.col_size = (int *) malloc (fdata.num_of_cols * sizeof (int));
    memset (fdata.col_size, 0, (fdata.num_of_cols * sizeof (int)));
    
    fdata.col_size[0] = 15;
    fdata.col_size[1] = 15;
    fdata.col_size[2] = 15;
    fdata.col_size[3] = 13;
    fdata.col_size[4] = 30;
    fdata.col_size[5] = 13;

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
    
    sprintf (fdata.title, "Storage Area Listing");

    fdata.select_set = (int *) malloc (tot_data * sizeof (int));
    memset (fdata.select_set, 0, (tot_data * sizeof (int)));

    /* allocate and initialize space to store data */

    fdata.data = (char **) malloc (tot_data * sizeof (char *));
    memset (fdata.data, NULL, (tot_data * sizeof (char *)));
    
    for (i=0; i<tot_data; ++i)
        NFMput_string (&fdata.data[i], data_ptr[i]);
/*AV clear message added            */
    SCdisplay_msg ("");
  SCdisplay_ref("<Enter> to Select; <PF1> to Accept; <PF4> to Select All; <PF3> to Cancel");

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
/* PS */
     SCdisplay_msg("Working..");
         
    /* set up error data form */
    q=0;
    err_data.num_of_rows = fdata.num_of_rows+2  ;
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

    NFMput_string (&err_data.data[0], "NFMstorage");
    NFMput_string (&err_data.data[1], "Status");
    NFMput_string (&err_data.data[2], "");
    NFMput_string (&err_data.data[3], "");

    count =0;

    for (i=0, q=4; i<fdata.num_of_rows; ++i)
     {
      
       if ((fdata.select_set[i] == 1) || (fdata.sts == FORM_SELECTED))
        {
         count = i * fdata.num_of_cols;

         status = ADMget_adm_file_in(NFMuser_id, atol (fdata.data[count+2]));
         ROW_SELECT = FALSE;
         NFMput_string(&err_data.data[q],fdata.data[count+1]);         
         
         if (status != NFM_S_SUCCESS)
          {
            sprintf(msg_str, "FAILED For Storage Area <%s>...", fdata.data[count+1]);
          SCdisplay_msg (msg_str);
/*          ERRget_message(msg);
          sprintf(err_str, "validate : %s", msg);*/
          ADMset_message();
          NFMput_string(&err_data.data[q+1],msg);
         _NFMdebug((fname, " value of err_data is  <%d>\n", err_data.data[q+1] ));
         q+=err_data.num_of_cols;
         
          }          
         else
         {
          sprintf(msg_str, "SUCCESSFUL For Storage Area<%s>....",fdata.data[count+1]);

          SCdisplay_msg (msg_str);   
          NFMput_string(&err_data.data[q+1], "Successful completion");
          _NFMdebug((fname,"This is SUCCESS: <%d> \n", i));    
          q+= err_data.num_of_cols;
         }
      }
    
      }
   
   if (ROW_SELECT == FALSE)
   {
    SCdisplay_msg ("<PF1> or <PF3> to cancel form.");
    status = SCprocess_column_form (&err_data, NFMprint_file);
     
   NFMfree_list (fdata.data, fdata.num_of_rows, fdata.num_of_cols);
   free (fdata.data);

   NFMfree_list (err_data.data, err_data.num_of_rows, err_data.num_of_cols);
   free (err_data.data);
   }
   else
     return (NFM_S_SUCCESS);

   _NFMdebug ((fname, "%s", "EXIT\n"));

   return (NFM_S_SUCCESS);
 }


