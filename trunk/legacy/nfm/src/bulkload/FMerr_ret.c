#include "machine.h"
#include "NFMerrordef.h"
#include "MSGstruct.h"
#include "SCstruct.h"
#include "SCdef.h"
#include "SCextern.h"
#include "NFIerrordef.h"

extern MSGptr NFMRmsg_ptr;
extern MSGptr NFMmsg_ptr;
extern MSGptr SQLmsg_ptr;
extern MSGptr DBmsg_ptr;
extern MSGptr MEMmsg_ptr;


long NFMerr_ret (err_no)
    long  err_no;
    {

       switch (err_no)
        {
          case NFM_E_MEM :
              NFMmsg_ptr.error_no = MEMmsg_ptr.error_no;
              strcpy (NFMmsg_ptr.error_msg, MEMmsg_ptr.error_msg);
              break;

          default :
              break;
        }

    return (0);
}

long NFAcreate_error_form (struct_data)
    struct SCcolumn_data_st *struct_data;

{
int   tot_data;
char  error_num[20];
struct SCcolumn_data_st *err_data;

    _NFMR_str ("%s", "NFMerror_form");

    err_data = struct_data;

    err_data->num_of_rows = 4;
    err_data->num_of_cols = 3;
    tot_data = err_data->num_of_cols * err_data->num_of_rows;
    err_data->freeze_rows_count = 0;
    err_data->select_set_expected = FALSE;
    err_data->col_width = (int *) malloc (err_data->num_of_cols * sizeof (int));
    memset (err_data->col_width, 0, (err_data->num_of_cols * sizeof (int)));
    
    err_data->col_width[0] = 4;
    err_data->col_width[1] = 8;
    err_data->col_width[2] = 30;
    err_data->new_rows_expected = FALSE;

    sprintf (err_data->title, "%s", "NFM Error Information");

    err_data->selectable = (int *) malloc (tot_data * sizeof (int));
    memset (err_data->selectable, 0, (tot_data * sizeof (int)));

    err_data->hidden = (int *) malloc (tot_data * sizeof (int));
    memset (err_data->hidden, 0, (tot_data * sizeof (int)));

    /* allocate and initialize space to store data */

    err_data->data = (char **) malloc (tot_data * sizeof (char *));
    memset (err_data->data, NULL, (tot_data * sizeof (char *)));

    NFAput_string (&err_data->data[0], "NFMR");
    sprintf (error_num, "%d", NFMRmsg_ptr.error_no);
    NFAput_string (&err_data->data[1], error_num);
    NFAput_string (&err_data->data[2], NFMRmsg_ptr.error_msg);

    NFAput_string (&err_data->data[3], "NFM");
    sprintf (error_num, "%d", NFMmsg_ptr.error_no);
    NFAput_string (&err_data->data[4], error_num);
    NFAput_string (&err_data->data[5], NFMmsg_ptr.error_msg);

    NFAput_string (&err_data->data[6], "SQL");
    sprintf (error_num, "%d", SQLmsg_ptr.error_no);
    NFAput_string (&err_data->data[7], error_num);
    NFAput_string (&err_data->data[8], SQLmsg_ptr.error_msg);

    NFAput_string (&err_data->data[9], "DB");
    sprintf (error_num, "%d", DBmsg_ptr.error_no);
    NFAput_string (&err_data->data[10], error_num);
    NFAput_string (&err_data->data[11], DBmsg_ptr.error_msg);

    return (NFI_S_SUCCESS);
}

