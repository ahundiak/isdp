#include "machine.h"
#include <stdio.h>
#include <ctype.h>
#include <errno.h>
#include <signal.h>
#include <sys/types.h>
#include "UNIX_or_VMS.h"
#include "NFMerrordef.h"
#include "NFMdef.h"
#include "MEMstruct.h"
#include "MEMerrordef.h"
#include "SCstruct.h"
#include "SCdef.h"
#include "NFMRextern.h"
#include "NDXstruct.h"
#include "MSGstruct.h"
#include "ERR.h"
#include "ADMser.h"
#include "DEBUG.h"
#include "NFIcommands.h"
#include "NFIerrordef.h"


server_log()
{

  FILE   *in_file, *fopen();
  long   status;
  struct ps_buffer ps_buf[200];
  int    i,j,z,k;
  int    count, actual_count;
  int    no_row_selected = FALSE;
  int    pcount=0;
  int    selcount;
  char   system_str[250];
  char   ser_file[250];
  short    value_proc;
  char   temp_pid[50];
  char   tmp_connect[5];
  int    tot_data;
  struct SCfree_data_st fdata;
  

  static char *fname = "server_log";

  _NFMdebug((fname, "ENTER\n"));

  SCdisplay_msg ("Working...");

  status = ADMfind_server (ps_buf,&count, &actual_count);
  _NFMdebug((fname, "ADMfind_server:<0x%.8x>, count <%d>\n", status, count));

  if (status != NFM_S_SUCCESS)
     {
        _NFMdebug((fname, "Failure ADMfind_server:0x%.8x\n", status));
        ERRload_struct(NFM, NFM_E_NO_SERVER, NULL, NULL);
        return (status);
      }    

    fdata.num_of_rows = actual_count;
    fdata.num_of_cols = 5;
    tot_data = fdata.num_of_cols * fdata.num_of_rows;
    fdata.freeze_rows_count = 0;
    fdata.freeze_cols_count = 1;
    fdata.max_indent =0;
    fdata.select_set_expected = SELECT_SET_MULTI_ROW;
    fdata.col_size = (int *) malloc (fdata.num_of_cols * sizeof (int));
    memset (fdata.col_size, 0, (fdata.num_of_cols * sizeof (int)));
    
    fdata.col_size[0] = 15;
    fdata.col_size[1] = 15;
    fdata.col_size[2] = 15;
    fdata.col_size[3] = 15;
    fdata.col_size[4] = 35;

    fdata.col_pos = (int *) malloc (fdata.num_of_cols * sizeof (int));
    memset (fdata.col_pos, 0 , (fdata.num_of_cols * sizeof (int)));

    
    pcount = 0;
    for(i=0; i<fdata.num_of_cols; ++i)
     {
        fdata.col_pos[i] = pcount;
        pcount += fdata.col_size[i]+2;
      }

    fdata.col_just = (int *) malloc (fdata.num_of_cols * sizeof (int));
    memset (fdata.col_just, LEFT_JUSTIFIED, (fdata.num_of_cols * sizeof (int)));

    fdata.h1_pos = (int *) malloc (2 * sizeof (int));
    memset (fdata.h1_pos, 0, 2 * sizeof (int));

    fdata.h1_pos[0] = 0;
    fdata.h1_pos[1] = -1;

    fdata.h2_pos = (int *) malloc (((fdata.num_of_cols+1) * sizeof (int)));
    memset (fdata.h2_pos, 0, ((fdata.num_of_cols+1) * sizeof (int)));

    for (i=0; i<fdata.num_of_cols; ++i)
        fdata.h2_pos[i] = fdata.col_pos[i];
    fdata.h2_pos[i] = -1;

    fdata.h3_pos = (int *) malloc (2 * sizeof (int));
    memset (fdata.h3_pos, 0, 2 * sizeof (int));
    fdata.h3_pos[0] = 0;
    fdata.h3_pos[1] = -1;

    fdata.h1_data = (char **) malloc (sizeof (char *));
    memset (fdata.h1_data, NULL, (sizeof (char *)));
    NFMput_string (&fdata.h1_data[0], "");

    fdata.h2_data = (char **) malloc (fdata.num_of_cols * (sizeof (char *)));
    memset (fdata.h2_data, NULL, fdata.num_of_cols * (sizeof (char *)));
   
         NFMput_string (&fdata.h2_data[0], "Client Node");
         NFMput_string (&fdata.h2_data[1], "Date");
         NFMput_string (&fdata.h2_data[2], "Time");
         NFMput_string (&fdata.h2_data[3], "Pid Process");
         NFMput_string (&fdata.h2_data[4], "Path");

    fdata.h3_data = (char **) malloc (sizeof (char *));
    memset (fdata.h3_data, NULL, (sizeof (char *)));
    NFMput_string (&fdata.h3_data[0], "");
    sprintf (fdata.title, "Active Server Processes");

    fdata.select_set = (int *) malloc (tot_data * sizeof (int));
    memset (fdata.select_set, 0, (tot_data * sizeof (int)));

/* allocate a memory location */

    fdata.data = (char **) malloc (tot_data * sizeof (char *));
    memset (fdata.data, NULL, (tot_data * sizeof (char *)));

     _NFMdebug((fname,"Check point 1\n", "", NULL));
j=0;
for ( i= 0; i < count; ++i)
 { 
   if(ps_buf[i].connect == ON)
    {
   
      NFMput_string (&fdata.data[j], ps_buf[i].node);
      _NFMdebug((fname,"Node is %s\n",ps_buf[i].node));
      NFMput_string (&fdata.data[j+1], ps_buf[i].date);
      _NFMdebug((fname,"Date is %s\n",ps_buf[i].date));
      NFMput_string (&fdata.data[j+2], ps_buf[i].time);
      _NFMdebug((fname,"Time is %s\n",ps_buf[i].time));
      sprintf(temp_pid,"%d", ps_buf[i].spid);
      NFMput_string (&fdata.data[j+3], temp_pid);
      _NFMdebug((fname,"Pid is %s\n",temp_pid));      
      NFMput_string (&fdata.data[j+4], ps_buf[i].path);
      _NFMdebug((fname,"Path is %s\n",ps_buf[i].path));

      _NFMdebug((fname,"Value for %d,%d",i,j));
      j+=fdata.num_of_cols;
    }
 }

 if (j== 0)
  {
      NFMfree_list (fdata.data,  fdata.num_of_rows,  fdata.num_of_cols);
      free (fdata.data);
      ERRload_struct(NFM, NFM_E_NO_PROCESS,NULL,NULL);  /*create a message*/
      return(NFM_S_SUCCESS);
   }       


    status = SCprocess_free_form (&fdata,  NFMprint_file);
    SCclear_msg();

    if(fdata.sts == FORM_CANCELED)
     {
        _NFMdebug((fname,  "Cancel from form. Return."));
        NFMfree_list (fdata.data,  fdata.num_of_rows,  fdata.num_of_cols);
        free (fdata.data);
        ERRload_struct( NFI,  NFI_W_FORM_CANCELED,  NULL,  NULL );
        return (NFI_W_FORM_CANCELED);
     }

          sprintf(ser_file, "/usr/tmp/NFMserver.log");
                                             
          in_file = fopen(ser_file,"a");
          if (in_file == NULL)
           {
            unlink (in_file);
            status = ERRload_struct (NFM, NFM_E_OPEN_FILE, "", NULL);
            _NFMdebug ((fname, "fopen : errno  = <%d>\n", errno));
            _NFMdebug ((fname, "fopen : status = <0x%.8x>\n", NFM_E_OPEN_FILE));
             return(NFM_E_OPEN_FILE);
           }
no_row_selected=FALSE;
selcount = 0;
        for (i=0; i<j/fdata.num_of_cols; ++i)
         {
             
           if ((fdata.select_set[i] == 1) || ( fdata.sts == FORM_SELECTED))
            {
               no_row_selected=TRUE;
               selcount = i * fdata.num_of_cols;
              _NFMdebug((fname, "killing NFMserver\n"));
/*
              sprintf(system_str, "%s %s > /dev/null 2>&1", "kill -9", fdata.data[selcount+3]);
           
              status = system(system_str);*/
    
/*          _NFMdebug((fname, "The system_str value is %s\n" , system_str));*/
            _NFMdebug((fname, "This pid %s killed\n", fdata.data[selcount+3]));
             status = kill((pid_t) atoi(fdata.data[selcount+3]),SIGKILL);
/*
              if (status ==-1)
               {
                status = NFM_E_FAILURE;
                _NFMdebug((fname, "Kill Process Error <%d>\n", status));
                ERRload_struct(NFM, NFM_E_NO_PROCESS, NULL, NULL);
                           
                  return (status);
               }
*/

           fprintf(in_file,"\nClient : Node Name %s Date %s Time %s PID %s Path %s Status OFF \n", fdata.data[selcount], fdata.data[selcount+1],fdata.data[selcount+2], fdata.data[selcount+3],fdata.data[selcount+4]);
             fprintf(in_file,"Server : Date %s Time %s pid %s\n",fdata.data[selcount+1], fdata.data[selcount+2],fdata.data[selcount+3]);

           }

      }
   
        if (no_row_selected == FALSE)
         {

          status =NFM_E_NO_SER_PROCESS;
          ERRload_struct(NFM, NFM_E_NO_SER_PROCESS,NULL, NULL); 
          return(status);
         }

        fclose(in_file);

        NFMfree_list (fdata.data,  fdata.num_of_rows,  fdata.num_of_cols);
        free (fdata.data);

        _NFIdebug ((fname, "%s", "EXIT\n"));

        return (NFM_S_SUCCESS);

  }
