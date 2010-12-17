#include "machine.h"
#include <stdio.h>
#include "NFMerrordef.h"
#include "MEMstruct.h"
#include "MEMerrordef.h"
#include "SCstruct.h"
#include "SCdef.h"
#include "SCdata.h"
#include "NFIerrordef.h"
#include "ERR.h"
#include "WFcommands.h"
#include "MSGstruct.h"
#include "DEBUG.h"
#include "NFIerrordef.h"
#include "NFIcommands.h"

extern struct _ERRstruct _ERRstruct;
extern long sqlstatus;
extern char NFMprint_file [] ;
extern char msg [] ;
extern long NFMuser_id ;
extern MSGptr NFMmsg_ptr ;

long ADMload_program ()

{
long   status;
int    tot_data;
int    FORM_FILLED;
struct SCcolumn_data_st data;
char   sa_name[25];
char   program_name[25];
char   program_desc[40];
char   file_name[25];
static char *fname = "ADMload_program";

    _NFMdebug ((fname, "ENTER\n"));

    SCdisplay_msg ("Working..");    

    data.num_of_rows = 3;
    data.num_of_cols = 2;
    tot_data = data.num_of_cols * data.num_of_rows;
    data.freeze_rows_count = 0;
    data.select_set_expected = FALSE;
    data.col_width = (int *) malloc (data.num_of_cols * sizeof (int));
    memset (data.col_width, 0, (data.num_of_cols * sizeof (int)));
    
    data.col_width[0] = 18;
    data.col_width[1] = 50;
    data.new_rows_expected = FALSE;
    sprintf (data.title, "%s",
             "Enter Loading Information.");

    data.selectable = (int *) malloc (tot_data * sizeof (int));
    memset (data.selectable, 0, (tot_data * sizeof (int)));

    data.selectable[1] = 1;
    data.selectable[3] = 1;
    data.selectable[5] = 1;

    data.hidden = (int *) malloc (tot_data * sizeof (int));
    memset (data.hidden, 0, (tot_data * sizeof (int)));

    /* allocate and initialize space to store data */

    data.data = (char **) malloc (tot_data * sizeof (char *));
    memset (data.data, NULL, (tot_data * sizeof (char *)));

    NFMput_string (&data.data[0], "Program Name");
    NFMput_string (&data.data[1], "");
    NFMput_string (&data.data[2], "Program Desc");
    NFMput_string (&data.data[3], "");
    NFMput_string (&data.data[4], "File Name");
    NFMput_string (&data.data[5], "");

/* PS */
    SCdisplay_msg ("Working..");
 
    /* process column form until an workflow Name has been entered */
    do
        {
        FORM_FILLED = TRUE;
        status = SCprocess_column_form (&data, NFMprint_file);
        SCclear_msg ();

        if (data.sts != FORM_CANCELED)
            {
            status = NFMvalidate_string ("char(20)", data.data[1]);

            if (strcmp (data.data[1], "") == 0)
                {
                FORM_FILLED = FALSE;
                SCdisplay_msg ("NFM:  Must Enter Program Name.");
                }
            status = NFMvalidate_string ("char(40)", data.data[3]);

            status = NFMvalidate_string ("char(128)", data.data[5]);

            if (strcmp (data.data[5], "") == 0)
               {
                FORM_FILLED = FALSE;
                SCdisplay_msg ("NFM:  Must Enter Program Filename");
               }

            }
        }
    while ((FORM_FILLED == FALSE) && (data.sts != FORM_CANCELED));

    if (data.sts == FORM_CANCELED)
        {
        NFMfree_list (data.data, data.num_of_rows, data.num_of_cols);
        free (data.data);
        ERRload_struct (NFI, NFI_W_FORM_CANCELED, NULL, NULL);
        return (NFI_W_FORM_CANCELED);
        }

    strcpy (program_name, data.data[1]);
    if (strcmp(data.data[3], "") !=0)
        strcpy (program_desc, data.data[3]);
    else
        strcpy (program_desc, "");
    strcpy (file_name, data.data[5]);
  
    _NFMdebug ((fname, "Program Name : <%s>\n", program_name));
    _NFMdebug ((fname, "Program Desc : <%s>\n", program_desc));
    _NFMdebug ((fname, "File Name : <%s>\n", file_name));

    NFMfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    SCdisplay_msg ("Working..");    
    status = NFMload_program (NFMuser_id, "", program_name, 
			      program_desc, file_name);

    if (status != NFM_S_SUCCESS)
        {
          _NFMdebug ((fname, "NFMload_program : <0x%.8x>\n", status));
          return (status);
        }

    _NFMdebug ((fname, "EXIT\n"));
    ERRload_struct (NFM, NFM_S_SUCCESS, NULL, NULL) ;        
    return (NFM_S_SUCCESS);
}




