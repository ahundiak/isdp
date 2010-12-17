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
#include "ERR.h"
#include "NFIcommands.h"
#include "NDXstruct.h"
#include "NFIerrordef.h"
#include "ERRproto.h"
#include "DEBUG.h"

#define  NFM_DEBUG_SUBSYSTEMS 15

extern struct _ERRstruct _ERRstruct;
extern MSGptr NFMRmsg_ptr;

extern long sqlstatus;

long ADMdebug_on ()

{
long   status;
int    i, j;
int    tot_data;
int    pos;
int    count = 0;
struct SCcolumn_data_st data;
struct SCfree_data_st fdata;
int    FORM_FILLED;
static char *fname = "ADMdebug_on";

    _NFMdebug ((fname, "ENTER\n"));

    fdata.num_of_rows = 6;
    fdata.num_of_cols = 1;
    tot_data = fdata.num_of_cols * fdata.num_of_rows;
    fdata.freeze_rows_count = 0;
    fdata.freeze_cols_count = 0;
    fdata.max_indent = 0;
    fdata.select_set_expected = SELECT_SET_MULTI_ROW;
    fdata.col_size = (int *) malloc (fdata.num_of_cols * sizeof (int));
    memset (fdata.col_size, 0, (fdata.num_of_cols * sizeof (int)));
    
    fdata.col_size[0] = 9;

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
    
    strcpy (fdata.title, "Choose Subsystem(s) For Server Debug");

    fdata.select_set = (int *) malloc (tot_data * sizeof (int));
    memset (fdata.select_set, 0, (tot_data * sizeof (int)));

    /* allocate and initialize space to store data */

    fdata.data = (char **) malloc (tot_data * sizeof (char *));
    memset (fdata.data, NULL, (tot_data * sizeof (char *)));

    NFMput_string (&fdata.data[0], "NFM Debug");
    NFMput_string (&fdata.data[1], "NET Debug");
    NFMput_string (&fdata.data[2], "SQL Debug");
    NFMput_string (&fdata.data[3], "MEM Debug");
    NFMput_string (&fdata.data[4], "ERR Debug");
    NFMput_string (&fdata.data[5], "ADM Debug");

    /* process free form */

    status = SCprocess_free_form (&fdata, NFMprint_file);

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
            if ((fdata.select_set[i] == 1) || (fdata.sts == FORM_SELECTED))
            ++count;
        }

/***********************************************************************
    Get Debug output file information
***********************************************************************/

    pos = 0;
    data.num_of_rows = count;
    data.num_of_cols = 2;
    tot_data = data.num_of_cols * data.num_of_rows;
    data.freeze_rows_count = 0;
    data.select_set_expected = FALSE;
    data.col_width = (int *) malloc (data.num_of_cols * sizeof (int));
    memset (data.col_width, 0, (data.num_of_cols * sizeof (int)));
    
    data.col_width[0] = 10;
    data.col_width[1] = 40;
    data.new_rows_expected = FALSE;
    strcpy (data.title, "Enter Debug File Names");

    data.selectable = (int *) malloc (tot_data * sizeof (int));
    memset (data.selectable, 0, (tot_data * sizeof (int)));

    for (i=pos+1; i<tot_data; i+=data.num_of_cols)
          data.selectable[i] = 1;

    data.hidden = (int *) malloc (tot_data * sizeof (int));
    memset (data.hidden, 0, (tot_data * sizeof (int)));

    /* allocate and initialize space to store data */

    data.data = (char **) malloc (tot_data * sizeof (char *));
    memset (data.data, NULL, (tot_data * sizeof (char *)));

    for (i=0, j=0; i<fdata.num_of_rows; ++i)
        {
          if ((fdata.select_set[i] == 1) || (fdata.sts == FORM_SELECTED))
            {
            NFMput_string (&data.data[j], fdata.data[i*fdata.num_of_cols]);
            NFMput_string (&data.data[j+1], "/dev/console");
            j+=data.num_of_cols;
        }
      }

    /* process column form until all info has been entered */
    do
      {
          FORM_FILLED = TRUE;
          status = SCprocess_column_form (&data, NFMprint_file);
          SCclear_msg ();

        if (data.sts != FORM_CANCELED)
          {
            /* 48 character file limit because of MSGstruct.h */
            for (i=pos; i<tot_data; i+=data.num_of_cols)
                status = NFMvalidate_string ("char(48)", data.data[i+1]);
          }
      }
    while ((FORM_FILLED == FALSE) && (data.sts != FORM_CANCELED));

    if (data.sts == FORM_CANCELED)
        {
          _NFMdebug ((fname, "%s\n", "Cancel from form. Return."));
          NFMfree_list (fdata.data, fdata.num_of_rows, fdata.num_of_cols);
          free (fdata.data);
          NFMfree_list (data.data, data.num_of_rows, data.num_of_cols);
          free (data.data);
          ERRload_struct( NFI, NFI_W_FORM_CANCELED, NULL, NULL );
          return (NFI_W_FORM_CANCELED);
        }

    SCdisplay_msg ("Working..");

    for (i=0; i<tot_data; i+=data.num_of_cols)
        {
             if (strncmp (data.data[i], "NFM", 3) == 0)
                 {
/*
                   NFMmsg_ptr.debug_on = 1;
                   strncpy (NFMmsg_ptr.debug_file, data.data[i+1],
                         (sizeof (NFMmsg_ptr.debug_file) - 1));
*/
	           _NFMdebug_st.NFMdebug_on = 1 ;
		   strcpy (_NFMdebug_st.NFMdebug_file,data.data[i+1]) ;
           _NFMdebug ((fname, "This contain %s\n", data.data[i+1]));
                 }

        else if (strncmp (data.data[i], "NET", 3) == 0)
             {
/*                NETmsg_ptr.debug_on = 1;
                strncpy (NETmsg_ptr.debug_file, data.data[i+1],
                         (sizeof (NETmsg_ptr.debug_file) - 1));
*/
		_NFMdebug_st.NETSdebug_on = 1 ;
	        strcpy (_NFMdebug_st.NETSdebug_file, data.data[i+1]);
           _NFMdebug ((fname, "This contain %s\n", data.data[i+1]));

             }

        else if (strncmp (data.data[i], "SQL", 3) == 0)
             {
/*
                SQLmsg_ptr.debug_on = 1;
                strncpy (SQLmsg_ptr.debug_file, data.data[i+1],
                         (sizeof (SQLmsg_ptr.debug_file) - 1));
*/
		_NFMdebug_st.SQLdebug_on = 1 ;
		strcpy (_NFMdebug_st.SQLdebug_file,data.data[i+1]) ;
        _NFMdebug ((fname, "This contain %s\n", data.data[i+1]));
             }

        else if (strncmp (data.data[i], "MEM", 3) == 0)
             {
/*
                 MEMmsg_ptr.debug_on = 1;
                strncpy (MEMmsg_ptr.debug_file, data.data[i+1],
                         (sizeof (MEMmsg_ptr.debug_file) - 1));
*/
                _NFMdebug_st.MEMdebug_on =1 ;
                strcpy (_NFMdebug_st.MEMdebug_file,data.data[i+1]);
                _NFMdebug ((fname, "This contain %s\n", data.data[i+1]));
             }

        else if (strncmp (data.data[i], "ERR", 3) == 0)
             {

/*                _ERRstruct.debug_on = 1;
                strncpy (_ERRstruct.debug_file, data.data[i+1],
                         (sizeof (_ERRstruct.debug_file) - 1));
*/

                _NFMdebug_st.ERRdebug_on =1 ;
                strcpy (_NFMdebug_st.ERRdebug_file,data.data[i+1]);
            _NFMdebug ((fname, "This contain of ERR : %s\n", data.data[i+1]));
             }
        else if (strncmp (data.data[i], "ADM", 3) == 0)
                {
                _NFMdebug_st.NFIdebug_on = 1;
               strcpy (_NFMdebug_st.NFIdebug_file, "/dev/console");
                strcpy (_NFMdebug_st.NFIdebug_file, data.data[i+1],
                         (sizeof (_NFMdebug_st.NFIdebug_file) - 1));

        _NFMdebug ((fname, "This contain ADM %s\n", data.data[i+1]));
      }
        }

    NFMfree_list (fdata.data, fdata.num_of_rows, fdata.num_of_cols);
    free (fdata.data);
    NFMfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    SCdisplay_msg ("Successful Completion.");

    return (NFM_S_SUCCESS);
}


long ADMdebug_off ()

{
static char *fname = "ADMdebug_off";

    _NFMdebug ((fname, "ENTER\n"));
/*
    NFMmsg_ptr.debug_on = 0;
    NETmsg_ptr.debug_on = 0;
    SQLmsg_ptr.debug_on = 0;
    MEMmsg_ptr.debug_on = 0;
*/
    _NFMdebug_st.NFMdebug_on = 0;
    _NFMdebug_st.ERRdebug_on = 0;
    _NFMdebug_st.NETSdebug_on = 0;
    _NFMdebug_st.SQLdebug_on = 0;
    _NFMdebug_st.MEMdebug_on = 0;
    _NFMdebug_st.NFIdebug_on = 0;
 
    SCdisplay_msg ("Successful Completion.");

    return (NFM_S_SUCCESS);
}

