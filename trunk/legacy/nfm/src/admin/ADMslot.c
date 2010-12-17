#include "machine.h"
#include <stdio.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/stat.h>
#include "NFMerrordef.h"
#include "MEMstruct.h"
#include "MEMerrordef.h"
#include "SCstruct.h"
#include "SCdef.h"
#include "NFIerrordef.h"
#include "NDXstruct.h"
#include "ERR.h"
#include "WFcommands.h"
#include "MSGstruct.h"
#include "DEBUG.h"

extern struct _ERRstruct _ERRstruct;
extern long sqlstatus;
extern char NFMprint_file [] ;
extern char msg [] ;
extern MSGptr NFMmsg_ptr ;


long ADMempty_slot ()

{
long   status;
int    tot_data;
int    FORM_FILLED;
struct SCcolumn_data_st data;

static char *fname = "ADMempty_slot";

    _NFMdebug ((fname, "ENTER\n"));

    data.num_of_rows = 1;
    data.num_of_cols = 1;
    tot_data = data.num_of_cols * data.num_of_rows;
    data.freeze_rows_count = 0;
    data.select_set_expected = FALSE;
    data.col_width = (int *) malloc (data.num_of_cols * sizeof (int));
    memset (data.col_width, 0, (data.num_of_cols * sizeof (int)));
  
    data.col_width[0] = 18;
    data.new_rows_expected = FALSE;
    sprintf (data.title, "%s", "Press PF1 To CleanUp Nfmindex Table");
    data.selectable = (int *) malloc (tot_data * sizeof (int));
    memset (data.selectable, 0, (tot_data * sizeof (int)));
    data.hidden = (int *) malloc (tot_data * sizeof (int));
    memset (data.hidden, 0, (tot_data * sizeof (int)));

    /* allocate and initialize space to store data */

    data.data = (char **) malloc (tot_data * sizeof (char *));
    memset (data.data, NULL, (tot_data * sizeof (char *)));


    /* process column form until an info has been entered */
    do
     {
       FORM_FILLED = TRUE;
       status = SCprocess_column_form (&data, NFMprint_file);
       SCclear_msg ();
     }

    while ((FORM_FILLED == FALSE) && (data.sts != FORM_CANCELED));

    if (data.sts == FORM_CANCELED)
     {
       NFMfree_list (data.data, data.num_of_rows, data.num_of_cols);
       free (data.data);
       ERRload_struct( NFI,  NFI_W_FORM_CANCELED,  NULL,  NULL );
       return (NFI_W_FORM_CANCELED);
     }

    NFMfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    SCdisplay_msg ("Working..");    

    status = ADMindex_comp();

    if (status !=NFM_S_SUCCESS)
    {
      return (status);
    }


    _NFMdebug((fname,  "SUCCESSFULL EXIT\n"));
    return (NFM_S_SUCCESS);
}




