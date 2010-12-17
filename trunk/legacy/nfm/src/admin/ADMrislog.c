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
#include "NFIcommands.h"

extern struct _ERRstruct _ERRstruct;
extern long sqlstatus;
extern char NFMprint_file [] ;
extern char msg [] ;
extern MSGptr NFMmsg_ptr ;


long ADMris_file ()

{
long   status;
int    tot_data;
int    FORM_FILLED;
struct SCcolumn_data_st data;
FILE   *fopen(), *in_file;
char   ris_file[100];
char   *getenv();
char   *dbpath;
char   env_dir[64];

static char *fname = "ADMris_file";

    _NFMdebug ((fname, "ENTER\n"));

    SCdisplay_msg ("Working..");    

     dbpath = getenv ("DBPATH");
     if (dbpath == NULL)
     {
        _NFMdebug ((fname, "DBPATH not set. \n"));
        dbpath = (char *) malloc ( 80 );
        if (!dbpath)
        {
           status = NFM_E_MEM;
           _NFMdebug ((fname, "Malloc failed : status = <0x%.8x>\n", status));
           ERRload_struct (NFM, status, "",NULL);
           return (status);
        }
        strcpy (dbpath, ".");
     }

    data.num_of_rows = 1;
    data.num_of_cols = 1;
    tot_data = data.num_of_cols * data.num_of_rows;
    data.freeze_rows_count = 0;
    data.select_set_expected = FALSE;
    data.col_width = (int *) malloc (data.num_of_cols * sizeof (int));
    memset (data.col_width, 0, (data.num_of_cols * sizeof (int)));
    
    data.col_width[0] = 18;

    data.new_rows_expected = FALSE;
    sprintf (data.title,"%s","This Command Cleans up ris.log file; PF1 to Continue; PF3 to Cancel.");
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

    strcpy (ris_file, "ris.log");
    _NFMdebug((fname, "the value of ris is %s\n", ris_file));
    sprintf (env_dir, "%s/%s", dbpath, ris_file);
    _NFMdebug ((fname, " This is value for %s\n", env_dir));

    if ((in_file = fopen (env_dir, "w")) == NULL)
     {
       status = NET_E_OPEN_FILENAME;
      _NFMdebug((fname, "File Open Failed File = <%s> : status = <0x%.8x>\n",ris_file,status));   
      ERRload_struct(NFM, status, "%s", ris_file);
      return (status);
    }
    status = fclose(in_file);
    if (status)
     {
       status = NET_E_CLOSE_FILE;
       _NFMdebug ((fname, "File Close : status = <0x%.8x>\n", status));
       ERRload_struct(NETS,status, "%s", in_file);
     }

    _NFMdebug((fname,  "SUCCESSFULL EXIT\n"));
    return (NFM_S_SUCCESS);
}




