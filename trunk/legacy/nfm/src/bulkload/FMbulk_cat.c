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
#include "ERR.h"
#include "NFIcommands.h"
#include "NFMdisplays.h"
#include "NFIerrordef.h"
#include "DEBUG.h"
#include "NFMbulk.h"

extern long sqlstatus;

long NFMget_big_list_catalog (max_directory_size)
    long   max_directory_size;

{
int    tot_data;
int    i, j, pos, offset;
int    ROW_CHOSEN = FALSE;
long   status;
long   local_filesize;
char   str_qry[1024];
struct SCfree_data_st fdata;
char   buffer_size [100];
char   tmp[10];
char   str[100];
char   **data;
char   **data1;
char   **column_ptr1;
char   **column_ptr;

MEMptr buffer= NULL;
MEMptr temp_buffer = NULL;

static  char *fname = "NFMbig_catalog";

      _NFMdebug ((fname, "Enter\n"));

 
     strcpy(str_qry,  "SELECT a.n_tablename,  b.n_datatype FROM \
                 nfmtables a,  nfmattributes b WHERE b.n_tableno \
                 in (SELECT n_tableno FROM nfmtables WHERE \
                 n_tablename LIKE 'f_%' AND n_tabletype = 'f_catalog') \
                 AND b.n_name = 'n_cofilename' AND a.n_tableno=b.n_tableno");

      strcpy(buffer_size, "1024");

      status = NFMRsqlquery (str_qry,  buffer_size,  &temp_buffer);
      if(status != NFM_S_SUCCESS)
       {
         _NFMR_str ("The size of %s\n", buffer_size);
          MEMclose (&temp_buffer);
          return(status);
       }  
      _NFMR_str ("%s", "this is str_qry size");

      status = MEMbuild_array(temp_buffer);

      _NFMR_str ("%s",  "Let Bild a array");
      if (status != MEM_S_SUCCESS)
       {
	 _NFMR_num("The status : <0x%.8x>",  status);
         MEMclose (&temp_buffer);
         return(NFM_E_MEM);
       }

      MEMprint_buffer("buffer",  temp_buffer,  "/dev/console");

      data1 = (char ** )temp_buffer->data_ptr;
      column_ptr1 = (char **)temp_buffer->column_ptr;

      _NFMR_str("%s", "Just TO see");

      status = MEMopen (&buffer, 2 * MEM_SIZE) ;
      if (status != MEM_S_SUCCESS)
      {
        _NFMdebug ((fname,  "MEM Open : status = <0x%.8x>",  status));
        ERRload_struct (NFM,  NFM_E_MEM,  "",  NULL) ;
        return (status);
      }

      status = MEMwrite_format (buffer, "n_catalogname","char(20)") ;
      if (status != MEM_S_SUCCESS)
      {
        ERRload_struct (NFM,  NFM_E_MEM,  "",  NULL) ;
        _NFMdebug ((fname,  "MEM Wr Format : status = <0x%.8x>",  status));
        MEMclose(buffer);
        return(status);
      }

      for (i=0; i<temp_buffer->rows; ++i)
      {
        offset = i*temp_buffer->columns;
        sscanf (data1 [offset+1], "%5s%d",tmp, &local_filesize);

        if (local_filesize >= max_directory_size)
         {
	   sprintf (str,  "%s\001",  &data1[offset][2]) ;
	
	   _NFMR_str("The BIG catalog is %s\n",  &data1[offset][2]);
	    status = MEMwrite (buffer,  str) ;
            if (status != MEM_S_SUCCESS)
             {
	       MEMclose (&buffer) ;
               ERRload_struct (NFM,  NFM_E_MEM,  "",  NULL);
               _NFMdebug ((fname,  "MEMwrite : <0x%.8x>",  status));
                MEMclose(temp_buffer);
                return (status);
              }
           _NFMR_str ("Catalog %s n_cofilename is ok", &data1[offset][2]);
         }
       }

       MEMclose(&temp_buffer);

       if (buffer->rows == 0)
       { 
	   _NFMR_str ("There are no catalogs with sufficient space",0);
       }

    MEMbuild_array (buffer) ;
     
    data = (char ** )buffer->data_ptr;
    column_ptr = (char **)buffer->column_ptr;

    fdata.num_of_rows = buffer->rows;
    fdata.num_of_cols = buffer->columns;
    tot_data = fdata.num_of_cols * fdata.num_of_rows;
    fdata.freeze_rows_count = 0;
    fdata.freeze_cols_count = 0;
    fdata.max_indent = 0;
    fdata.select_set_expected = SELECT_SET_SINGLE_ROW;
    fdata.col_size = (int *) malloc (fdata.num_of_cols * sizeof (int));
    memset (fdata.col_size, 0, (fdata.num_of_cols * sizeof (int)));

    fdata.col_size[0] = 15;
    fdata.col_size[1] = 15;

    fdata.col_pos = (int *) malloc (fdata.num_of_cols * sizeof (int));

    pos = 0;
    for (i=0; i<buffer->columns; ++i)
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
    for (i=0; i<buffer->columns; ++i)
        fdata.h2_pos[i] = fdata.col_pos[i];

    fdata.h2_pos[i] = -1;

    fdata.h3_pos = (int *) malloc (sizeof (int) + 1);

    memset (fdata.h3_pos, 0, sizeof (int) + 1);
    fdata.h3_pos[0] = 0;
    fdata.h3_pos[1] = -1;

    fdata.h1_data = (char **) malloc (sizeof (char *));
    memset (fdata.h1_data, NULL, (sizeof (char *)));
    NFAput_string (&fdata.h1_data[0], "");

    fdata.h2_data = (char **) malloc (fdata.num_of_cols * (sizeof (char *)));
    memset (fdata.h2_data, NULL, fdata.num_of_cols * (sizeof (char *)));
    for (i=0; i<buffer->columns; ++i)
        NFAput_string (&fdata.h2_data[i], column_ptr[i]);

    fdata.h3_data = (char **) malloc (sizeof (char *));
    memset (fdata.h3_data, NULL, (sizeof (char *)));
    NFAput_string (&fdata.h3_data[0], "");

    sprintf (fdata.title, "Catalog List");

    fdata.select_set = (int *) malloc (tot_data * sizeof (int));
    memset (fdata.select_set, 0, (tot_data * sizeof (int)));

    /* allocate and initialize space to store data */

    fdata.data = (char **) malloc (tot_data * sizeof (char *));
    memset (fdata.data, NULL, (tot_data * sizeof (char *)));

    for (i=0; i<tot_data; ++i)
        NFAput_string (&fdata.data[i], data[i]);


     status = SCprocess_free_form (&fdata, NFMprint_file);
     SCclear_ref();
    
    j = 0; 
    for (i=0; i<fdata.num_of_rows; ++i)
        {
          j = i * fdata.num_of_cols;
          if (fdata.select_set[i] == 1)
            {
              ROW_CHOSEN = TRUE;
              _NFMR_str ( "This is NFMcatalog %s\n",  NFMcatalog);
              _NFMR_str ( " This is active NFMstorage %s\n",  NFMstorage);
              strcpy (NFMcatalog, fdata.data[j]);
              _NFMR_str ( "This is NFMcatalog %s\n",  NFMcatalog);
              _NFMR_str ( "This is NFMstorage %s\n", NFMstorage);
              break;
            }
        }
  MEMprint_buffers("list3",  buffer,  "/dev/console");

    NFAfree_list (fdata.data, fdata.num_of_rows, fdata.num_of_cols);
    free (fdata.data);

  status = MEMclose(&buffer);

  if(status != MEM_S_SUCCESS)
  {
     ERRload_struct (NFM,   NFM_E_MEM,   "",   NULL);
     _NFMdebug ((fname,   "MEMwrite : <0x%.8x>",   status));
     MEMclose(buffer);
     return (status);
  }

    _NFMR_str ("%s", "Exiting This Functions\n");
    return(NFM_S_SUCCESS);

}
