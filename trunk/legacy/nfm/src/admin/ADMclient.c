#include "machine.h"
#include <stdio.h>
#include "NFMerrordef.h"
#include "SCstruct.h"
#include "MEMstruct.h"
#include "SCdef.h"
#include "SCdata.h"
#include "NFMerrordef.h"
#include "ERR.h"
#include "MSGstruct.h"
#include "NFIerrordef.h"
#include "NDXstruct.h"
#include "DEBUG.h"

extern struct _ERRstruct _ERRstruct;
extern long sqlstatus;
extern char NFMprint_file [] ;
extern char msg [] ;

extern MSGptr NFMmsg_ptr ;

long ADMclientserver ()

{
long   status;
int    i,k,j;
int    pos;
int    count;
char   net_tcp[2];
char   net_xns[2];
char   net_dec[2];
char   sername [50];
char   tcp_net[14];
int    tot_data;
int    FORM_FILLED =FALSE;
struct SCcolumn_data_st data;
static char *fname = "ADMclientserver";

    _NFMdebug ((fname, "ENTER\n"));

    SCdisplay_msg ("Working..");    

    data.num_of_rows = 3;
    data.num_of_cols = 3;
    tot_data = data.num_of_cols * data.num_of_rows;
    data.freeze_rows_count = 0;
    data.select_set_expected = FALSE;
    data.col_width = (int *) malloc (data.num_of_cols * sizeof (int));
    memset (data.col_width, 0, (data.num_of_cols * sizeof (int)));
    
    data.col_width[0] = 24;
    data.col_width[1] = 10;
    data.col_width[2] = 30;

    data.new_rows_expected = FALSE;
    sprintf (data.title, "%s","I/NFM Server Node Info");

    data.selectable = (int *) malloc (tot_data * sizeof (int));
    memset (data.selectable, 0, (tot_data * sizeof (int)));

    data.selectable[2] = 1;
    data.selectable[5] =1;

    data.hidden = (int *) malloc (tot_data * sizeof (int));
    memset (data.hidden, 0, (tot_data * sizeof (int)));

    
    /* allocate and initialize space to store data */

    data.data = (char **) malloc (tot_data * sizeof (char *));
    memset (data.data, NULL, (tot_data * sizeof (char *)));

   NFMput_string (&data.data[0], "Server Name");
   NFMput_string (&data.data[1], "char(20)");
   NFMput_string (&data.data[2], "");
   NFMput_string (&data.data[3], "TCP/IP");
   NFMput_string (&data.data[4], "char(1)");
   NFMput_string (&data.data[5], "");
   NFMput_string (&data.data[6], "XNS");
   NFMput_string (&data.data[7], "char(1)");
/* HP-PORT IGI 25 Aug 94 */ 
#if (defined(OS_SUNOS) || defined(OS_SOLARIS) || \
     defined(OS_SCO_UNIX) || defined(OS_HPUX))
   NFMput_string (&data.data[8], "N");
#else
   NFMput_string (&data.data[8], "Y");
#endif

    /* process column form until an workflow Name has been entered */
    do
      {
        FORM_FILLED = TRUE;
        status = SCprocess_column_form (&data, NFMprint_file);
        SCclear_msg ();
       _NFMdebug((fname,"return from SCprocess_column_form -> %d\n", data.sts));

        if (data.sts != FORM_CANCELED)
          {
            _NFMdebug ((fname, "data.data[2] = <%s>\n", data.data[2]));
            _NFMdebug ((fname, "data.data[5] = <%s>\n", data.data[5]));
    
            status = NFMvalidate_string("char(20)", data.data[2]);
            _NFMdebug ((fname, "NFMvalidate_string = <0x%.8x>\n", status));

            status = NFMvalidate_string("char(1)", data.data[5]); 
                 _NFMdebug((fname,"%s\n", data.data[5])); 
            _NFMdebug ((fname, "NFMvalidate_string = <0x%.8x>\n", status));

                 _NFMdebug((fname,"first value of %s\n", data.data[2])); 
            if (strcmp (data.data[2], "") == 0)
              {
                FORM_FILLED = FALSE;

                SCdisplay_msg ("NFM:  Must Enter Server Name.");
              }

           else if (strcmp (data.data[5], "") == 0)
                {
                 FORM_FILLED = FALSE;

                SCdisplay_msg ("NFM:  Must Enter Y Or N.");
                }
/*
            status = NFMvalidate_string("char(1)", data.data[5]); 
                 _NFMdebug((fname,"%s\n", data.data[5])); 
            _NFMdebug ((fname, "NFMvalidate_string = <0x%.8x>\n", status));

           else if (strcmp (data.data[5], "") == 0)
                {
                 FORM_FILLED = FALSE;

                SCdisplay_msg ("NFM:  Must Enter Y Or N.");
                }
*/

          }
    }

    while ((FORM_FILLED == FALSE) && (data.sts != FORM_CANCELED));

    if (data.sts == FORM_CANCELED)
     {
       _NFM_str ("NFM : Cancel from form. <%s>.", "Return");
       NFMfree_list (data.data, data.num_of_rows, data.num_of_cols);
       free (data.data);
       ERRload_struct (NFI, NFI_W_FORM_CANCELED, NULL, NULL);
       return (NFI_W_FORM_CANCELED);
     }

     strcpy (sername, data.data[2]);
     strcpy (tcp_net, data.data[5]);
     if ((strcmp(tcp_net, "Y")==0) || (strcmp(tcp_net,"y")==0))
         strcpy(tcp_net, "Y");
/*     else
         strcpy(tcp_net, "");      */

    _NFMdebug ((fname, "Nodename : <%s>\n",sername));
    _NFMdebug ((fname, "tcp_address : <%s>\n", tcp_net));

     NFMfree_list (data.data, data.num_of_rows, data.num_of_cols);
     free (data.data);

    /* Create Server*/

    SCdisplay_msg ("Working..");    

    status = ADMcreate_clientfile(sername,tcp_net);
    if (status != NFM_S_SUCCESS)
     {
       return (status);
     }
    _NFMdebug((fname, "SUCCESSFULL EXIT\n"));
 
    return (NFM_S_SUCCESS);
}




