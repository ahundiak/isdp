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
#include "NFIerrordef.h"
#include "NFIcommands.h"
#include "ERR.h"

extern long sqlstatus;
extern char NFMprint_file[] ;

long ADMset_conf ()

{
long   status;
int    i, j, z , k;
int    tot_data;
int    count;
int    pos;
struct SCcolumn_data_st data;
struct SCfree_data_st fdata;
char   sql_str[512];
char   qry_str[512];
char   **data_ptr, **item_buf;
char   **data_ptr1;

int    FORM_FILLED;
MEMptr out_list = NULL, return_buffer = NULL;
MEMptr data_list = NULL;

static char *fname = "ADMset_conf";

    _NFMdebug ((fname, "ENTER\n"));
    
    SCdisplay_msg ("Working..");        

    fdata.num_of_rows =3;
    fdata.num_of_cols =1;
    tot_data = fdata.num_of_cols * fdata.num_of_rows;
    fdata.freeze_rows_count = 0;
    fdata.freeze_cols_count = 0;
    fdata.max_indent = 0;
    fdata.select_set_expected = SELECT_SET_SINGLE_ROW;
    fdata.col_size = (int *) malloc (fdata.num_of_cols * sizeof (int));
    memset (fdata.col_size, 0, (fdata.num_of_cols * sizeof (int)));
 
    fdata.col_size[0] =25;

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
    NFMput_string (&fdata.h2_data[0], "");

    fdata.h3_data = (char **) malloc (sizeof (char *));
    memset (fdata.h3_data, NULL, (sizeof (char *)));
    NFMput_string (&fdata.h3_data[0], "");

    strcpy (fdata.title, " List Of  SetAcess Check Options");

    fdata.select_set = (int *) malloc (tot_data * sizeof (int));
    memset (fdata.select_set, 0, (tot_data * sizeof (int)));

    /* allocate and initialize space to store data */

    fdata.data = (char **) malloc (tot_data * sizeof (char *));
    memset (fdata.data, NULL, (tot_data * sizeof (char *)));

    NFMput_string (&fdata.data[0], "Do Not Check");
    NFMput_string (&fdata.data[1], "Check Primary Only");
    NFMput_string (&fdata.data[2], "Check Secondary & Primary");

    status = SCprocess_free_form (&fdata,  NFMprint_file);
     SCclear_msg ();

    if (fdata.sts == FORM_CANCELED)
     {
        _NFMdebug (( fname, "%s\n", "Cancel from form. Return. "));
        NFMfree_list (fdata.data, fdata.num_of_rows, fdata.num_of_cols);
        free (fdata.data);
        ERRload_struct (NFI, NFI_W_FORM_CANCELED, NULL, NULL);
        return (NFI_W_FORM_CANCELED);
      }

    _NFMdebug((fname,"set1 %d, set2 %d, set3 %d,num.rows %d\n",
               fdata.select_set[0], fdata.select_set[1], fdata.select_set[2],
             fdata.num_of_rows));

     sprintf (qry_str, "SELECT n_description FROM nfmsyscat WHERE \
     n_infotype = 'SET MEMBER ACCESS'");
     status = SQLquery (qry_str, &out_list, 2*MEM_SIZE);
     if (status != SQL_S_SUCCESS)
      {
        free (qry_str);
        ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
        _NFMdebug ((fname, "SQL Qry Syntax : status = <0x%.8x>\n", status));
        return ( NFM_E_SQL_QUERY);
      }

    count = 0;
    for (i =0; i<fdata.num_of_rows; ++i)
      {
        if (fdata.select_set[i] == 1)
         {
           count = i*fdata.num_of_cols;
    
           sprintf (sql_str,"UPDATE nfmsyscat SET n_description='%s'\
            WHERE n_infotype ='SET MEMBER ACCESS'", fdata.data[count]);


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

        NFMfree_list (fdata.data,  fdata.num_of_rows,  fdata.num_of_cols);
        free (fdata.data);

  status = MEMclose(&out_list);

  if(status != MEM_S_SUCCESS)
  {
     ERRload_struct (NFM,  NFM_E_MEM,  "",  NULL);
     _NFMdebug ((fname,  "MEMwrite : <0x%.8x>",  status));
     MEMclose(out_list);
     return (status);
  }

     SCdisplay_msg ("Working..");

    _NFMdebug ((fname, "%s", "EXIT\n"));

     return (NFM_S_SUCCESS);
}
