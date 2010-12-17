#include "machine.h"
#include <stdio.h>
#include "UNIX_or_VMS.h"
#include "NFMerrordef.h"
#include "NFMdef.h"
#include "MEMstruct.h"
#include "MEMerrordef.h"
#include "NFMstruct.h"
#include "SCstruct.h"
#include "SCdef.h"
#include "ERR.h"
#include "NFIcommands.h"
#include "NFIerrordef.h"
#include "DEBUG.h"

/*      Added by MVR  on 19/11/93 for declaring NFMprint_file  */
#include "NFMRextern.h"
/* end of addition */

extern long sqlstatus;

long NFMget_env()

{
long   status;
int    i, j, k;
int    tot_data;
int    FORM_FILLED;
struct SCfree_data_st fdata;
struct SCcolumn_data_st data;
char   env_name[20];
char   msg[200];
MEMptr output_buffer = NULL ;
char   **data1 ;
char   **data2;
char   **col_name ;
char   column [100] ;
MEMptr schema = NULL;
static char   *fname = "NFMget_env";

    _NFMdebug ((fname, "ENTER\n"));

    status = NETLs_nodes_nfme("nfme_", &output_buffer);
    if (status != NFM_S_SUCCESS)
     {
/*       ERRload_struct( NFM, NFM_E_FAILURE, NULL, NULL);*/
       /* The error message changed as followos - SSRS 1 May 94 */
       ERRload_struct( NFM, status, "%s", "NFMowne.dat");
       MEMclose(&output_buffer);
       return(NFM_E_MEM);
     }
     _NFMdebug((fname, "output_buffer:<0x%.8x>\n",output_buffer));
    
     status = MEMbuild_array (output_buffer);
     if (status != MEM_S_SUCCESS)
      {
       MEMclose (&output_buffer);
       _NFMdebug ((fname, "MEMbuild array failed :<0x%.8x>\n", status));
       ERRload_struct( NFM, NFM_E_MEM, "%s%s","NFMget_env","MEMbuild_array Failed" );
       return (status);
      }

     _NFMdebug((fname, "output_buffer:<0x%.8x>\n",output_buffer));
     _NFMdebug ((fname, "NFMLs_nodes_nfme : <0x%.8x>\n", status));

    data1 = (char **) output_buffer->data_ptr ;

/*    MEMprint_buffers ("nodes", output_buffer, "/dev/console") ;*/

    if (output_buffer->rows==0)
     {
       status = NFM_E_BAD_ENV;
       _NFMdebug((fname, "no.of.row\n"));
       ERRload_struct(NFM, NFM_E_BAD_ENV, NULL, NULL);
       return (status);
     }
    fdata.num_of_rows = output_buffer->rows;
    fdata.num_of_cols = 1;
    tot_data = fdata.num_of_cols * fdata.num_of_rows;
    fdata.freeze_rows_count = 0;
    fdata.freeze_cols_count = 0 ;
    fdata.max_indent = 0;
    fdata.select_set_expected = SELECT_SET_SINGLE_ROW;
    fdata.col_size = (int *) malloc (fdata.num_of_cols * sizeof (int));
    memset (fdata.col_size, 0, (fdata.num_of_cols * sizeof (int)));
    
    fdata.col_size[0] = 25;

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
    NFMput_string (&fdata.h2_data[0], "Valid I/NFM Environments :");
    
    fdata.h3_data = (char **) malloc (sizeof (char *));
    memset (fdata.h3_data, NULL, (sizeof (char *)));
    NFMput_string (&fdata.h3_data[0], "");
    
    sprintf (fdata.title, "Choose Environment File");

    fdata.select_set = (int *) malloc (tot_data * sizeof (int));
    memset (fdata.select_set, 0, (tot_data * sizeof (int)));

    /* allocate and initialize space to store data */

    fdata.data = (char **) malloc (tot_data * sizeof (char *));
    memset (fdata.data, NULL, (tot_data * sizeof (char *)));
/*
    status = MEMbuild_array (output_buffer) ;
    if (status != MEM_S_SUCCESS)
      {
	_NFMdebug ((fname, "MEMbuild_array : <0x%.8x>\n", status));
        ERRload_struct (NFM, NFM_E_MEM, "%s%s", fname, "MEMbuild_array");
	return (NFM_E_MEM) ;
      }

    data1 = (char **) output_buffer->data_ptr ;*/

    for (i=0; i<output_buffer->rows; i++)
      {
	NFMput_string (&fdata.data[i], data1 [i]) ;
	_NFMdebug ((fname, "data : <%s>\n", data1 [i]));
      }

    MEMclose (&output_buffer) ;

    do
     {
        FORM_FILLED = FALSE;      /* It was FALES */

/* The missing second parameter is added to avoid SEGV fault -  MVR 19/11/93 */
        status = SCprocess_free_form (&fdata, NFMprint_file);

/*      end of modified portion -- MVR */

        SCclear_msg ();

        if (fdata.sts == FORM_CANCELED)
         {
          _NFMdebug ((fname, "Cancel from form. Return.\n"));
          NFMfree_list (fdata.data, fdata.num_of_rows, fdata.num_of_cols);
          free (fdata.data);
          ERRload_struct (NFI, NFI_W_FORM_CANCELED, NULL, NULL);
          return (NFI_W_FORM_CANCELED);
         }

        if (fdata.sts == FORM_ACCEPTED)
          {
            for (i=0; i<fdata.num_of_rows; ++i)
                {
                if (fdata.select_set[i] == 1)
                    {
                     FORM_FILLED = TRUE;
                     strcpy (env_name, fdata.data[i]);
                     break;
                    }
                 else
                    FORM_FILLED = FALSE;
                    SCdisplay_msg ("NFM:  Must Choose Environment Node.");
                }
            }

        }
    while ((FORM_FILLED == FALSE) && (fdata.sts != FORM_CANCELED));

    if (fdata.sts == FORM_CANCELED)
        {
        _NFMdebug ((fname, "Cancel from form. Return.\n"));
        NFMfree_list (fdata.data, fdata.num_of_rows, fdata.num_of_cols);
        free (fdata.data);
        ERRload_struct (NFI, NFI_W_FORM_CANCELED, NULL, NULL);
        return (NFI_W_FORM_CANCELED);
        }

    _NFIdebug ((fname, "Environment Name : <%s>\n", env_name));

    NFMfree_list (fdata.data, fdata.num_of_rows, fdata.num_of_cols);
    free (fdata.data);

    SCdisplay_msg ("Working..");    

    status = NFMget_schema_envinfo (env_name,&schema);
    if (status != NFM_S_SUCCESS)
        {
        _NFIdebug ((fname, "NFMget_schema_envinfo : <0x%.8x>\n", status));
        ERRload_struct (NFM, NFM_E_FAILURE, NULL, NULL);
        MEMclose (&schema) ;
        return (NFM_E_FAILURE);
        }

/*    MEMprint_buffers ("nodename",schema, "/dev/console");  */

    data.num_of_rows = schema->columns - 6;
    data.num_of_cols = 2;
    tot_data = data.num_of_cols * data.num_of_rows;
    data.freeze_rows_count = 0;
    data.select_set_expected = FALSE;
    data.col_width = (int *) malloc (data.num_of_cols * sizeof (int));
    memset (data.col_width, 0, (data.num_of_cols * sizeof (int)));
    
    data.col_width[0] = 20;
    data.col_width[1] = 18;

    data.new_rows_expected = FALSE;
    sprintf (data.title, "%s",
             "Enter Your Information For a Node You Selected");
         
    data.selectable = (int *) malloc (tot_data * sizeof (int));
    memset (data.selectable, 0, (tot_data * sizeof (int)));

    for (i=1; i<tot_data; i+=data.num_of_cols)
        {
        data.selectable[i] = 1;
        }

    data.hidden = (int *) malloc (tot_data * sizeof (int));
    memset (data.hidden, 0, (tot_data * sizeof (int)));

    /* allocate and initialize space to store data */

    data.data = (char **) malloc (tot_data * sizeof (char *));
    memset (data.data, NULL, (tot_data * sizeof (char *)));

    status = MEMbuild_array (schema);
    if (status != MEM_S_SUCCESS)
      {
	_NFMdebug ((fname, "NFMschema : MEMbuild_array : <0x%.8x>\n", status));
        ERRload_struct (NFM, NFM_E_MEM, "%s%s", fname, "MEMbuild_array");
        MEMclose (&schema) ;
        return (NFM_E_MEM);
      }

    col_name = (char **) schema->column_ptr ;
    data2 =(char **) schema->data_ptr ;

/* column name */
    for (j=6,  k=0 ; j<schema->columns; j++,  k++)
      {
        if (strcmp (col_name [j],  "NETPROP11") == 0)
		strcpy (column,  "RDBMS TYPE");
        else if (strcmp (col_name[j], "NETPROP13") == 0)
                    strcpy (column, "RDBMS HOME DIR");
        else if (strcmp(col_name[j], "NETPROP14") == 0)
                    strcpy (column, "DATABASE PATH");
          if (strcmp(col_name[j], "NETPROP16") == 0)
                    strcpy (column, "RIS NET TYPE");
        else if (strcmp(col_name[j], "NETPROP17") == 0)
                    strcpy (column, "RISDBA USER");
        else if (strcmp(col_name[j], "NETPROP18") == 0)
                    strcpy (column, "RISDBA PASSWORD");
        else if (strcmp(col_name[j], "NETPROP20") == 0)  
                    strcpy (column, "NFM SCHEMA NAME");
        else if (strcmp(col_name[j], "NETPROP21") == 0)  
                    strcpy (column, "NFM SCHEMA PASSWORD");
        else if (strcmp(col_name[j], "NETPROP22") == 0)
                    strcpy (column, "NFM SCHEMA USER");
        else strcpy (column,  col_name[j]) ;

        NFMput_string (&data.data[k*2], column);
      }

/* data */
    for (j=6,  k=0; j<schema->columns; j++,  k++)
      {
        NFMput_string (&data.data[(k*2)+1], data2 [j]);
      }

    /* process column form until an Env Name has been entered */
    do
        { 
          FORM_FILLED = TRUE;
/* The missing second parameter is added to avoid SEGV fault -  MVR 19/11/93 */

          status = SCprocess_column_form (&data, NFMprint_file);

/*  End of modified portion - MVR  */
          SCclear_msg ();
        }
    while ((FORM_FILLED == FALSE) && (data.sts != FORM_CANCELED));

    if (data.sts == FORM_CANCELED)
        {
        NFMfree_list (data.data, data.num_of_rows, data.num_of_cols);
        free (data.data);
        ERRload_struct (NFI, NFI_W_FORM_CANCELED, NULL, NULL);
        MEMclose (&schema) ;
        return (NFI_W_FORM_CANCELED);
        }


   _NFMdebug ((fname, "TOTAL DAT IS %d\n", tot_data));

   for (i=0, k=7; i<tot_data; i+=data.num_of_cols,  ++k)
       {
       if(data.data [i+1] !=NULL)
          {
          _NFIdebug ((fname, "MEMwrite_data : <%s>\n", data.data[i+1]));

          status = MEMwrite_data (schema, data.data[i+1], 1, k);
          if(status != MEM_S_SUCCESS)
              { 
	      NFMfree_list (data.data,  data.num_of_rows,  data.num_of_cols);
  	      free(data.data);
              ERRload_struct (NFM, NFM_E_MEM, "%s%s", fname, "MEMwrite_data");
              MEMclose (&schema) ;
              return (NFM_E_MEM);
              }
          } 
      }

   NFMfree_list(data.data,  data.num_of_rows, data.num_of_cols);
   free(data.data);

/*   MEMprint_buffers ("before NFMcreate",  schema,  "/dev/console") ;*/

/* write to file */

    status = NFMcreate_env_node(env_name, schema); 

    if (status != NFM_S_SUCCESS)
    {
	_NFMdebug ((fname, "NFMcreate_env_node :<0x%.8x>\n", status));
        ERRload_struct (NFM, NFM_E_FAILURE, NULL, NULL);
        MEMclose (&schema) ;
	return (NFM_E_FAILURE);
    }

    MEMclose (&schema) ;
 
    return(NFM_S_SUCCESS);
}
