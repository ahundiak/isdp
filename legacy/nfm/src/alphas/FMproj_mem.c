#include "machine.h"
#include <stdio.h>
#include "NFMdef.h"
#include "MEMstruct.h"
#include "SCstruct.h"
#include "SCdef.h"
#include "NFMRextern.h"
#include "NDXstruct.h"
#include "NFMRlist.h"
#include "NFMdisplays.h"

long add_project_members ()

{
long   status;
int    i, j, k, m, n, o;
int    pos;
int    count = 0;
int    tot_data;
int    FORM_FILLED = FALSE;
int    show_form;
struct SCcolumn_data_st data;
struct SCfree_data_st   fdata;
struct SCfree_data_st   cdata;
char   **data_ptr;
char   **column_ptr;
char   **item_ptr;
char   str[1028];
MEMptr attr_list = NULL;
MEMptr data_list = NULL;
MEMptr item_list = NULL;
NFMlist display_struct;

static char *fname = "add_project_members";

    _NFIdebug ((fname, "Enter.\n"));

    SCdisplay_msg ("Working..");    

    status = NFMRquery_project_members (NFMuser_id, NFMproject, &attr_list,
                                        &data_list);

    if (status != NFM_S_SUCCESS)
        {
        MEMclose (&attr_list);
        MEMclose (&data_list);
        return (status);
        }

    status = MEMbuild_array (attr_list);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&attr_list);
        MEMclose (&data_list);
	MEMclose (&item_list);
        ERRload_struct( NFI, NFI_E_MEMORY, "%s%s","NFMadd_project_members",
			"MEMbuild_array");
        return (status);
        }

    status = MEMbuild_array (data_list);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&attr_list);
        MEMclose (&data_list);
	MEMclose (&item_list);
        ERRload_struct( NFI, NFI_E_MEMORY, "%s%s","NFMadd_project_members",
			"MEMbuild_array");
        return (status);
        }

    NFAfill_list_struct (&display_struct, DSP_CATALOGS,
 SELECT_SET_MULTI_ROW, NFM_SHORT_DISPLAY, -1,
  "nfmcatalogs.n_catalogname NOT LIKE '%_rl' ","", "", "", "", "", "", 
 "Choose Catalog(s) Containing Items to be Project Members" );

    status = NFAdisplay_elements (&cdata, display_struct);
       _NFIdebug(( fname, "NFAdisplay_elements <0x%.8x>\n", status ));

    NFAfree_list_struct( &display_struct );
    if (status == NFI_W_COMMAND_CANCELLED)
        {
        _NFIdebug(( fname, "%s\n", "FORM_CANCELED" ));
        return( status );
        }
    if (status != NFI_S_SUCCESS)
        {
          _NFIdebug(( fname, "NFAdisplay_elements : <0x%.8x>\n", status));
          return (status);
        }

for (m = 0; m < cdata.num_of_rows; ++m)
{
  n  = m*cdata.num_of_cols;
  if (cdata.select_set[m] == 1)
  {
    _NFIdebug(( fname, "Process Catalog <%s>\n", cdata.data[n+1] ));

    status = NFMRqry_items_in_cat_for_project (NFMuser_id, NFMproject, 
		cdata.data[n+1], &item_list );

    if (status != NFM_S_SUCCESS)
        {
	MEMclose (&item_list);
	item_list = NULL;
        NFAset_message();
        SCdisplay_msg( msg );
    _NFIdebug(( fname, "Display a error message\n"));
	continue;
        }
    
    status = MEMbuild_array (item_list);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&attr_list);
        MEMclose (&data_list);
	MEMclose (&item_list);
        ERRload_struct( NFI, NFI_E_MEMORY, "%s%s","NFMadd_project_members",
			"MEMbuild_array");
        return (status);
        }

/*  Display and choose items to add to project
 */
    item_ptr   = (char**) item_list->data_ptr;

    fdata.num_of_rows = item_list->rows;
    fdata.num_of_cols = 3;
    tot_data = fdata.num_of_rows * fdata.num_of_cols;
    fdata.freeze_rows_count = 0;
    fdata.freeze_cols_count = 1;
    fdata.max_indent = 0;
    fdata.select_set_expected = SELECT_SET_MULTI_ROW;
    fdata.col_size = (int*)malloc( fdata.num_of_cols * sizeof(int) );
    memset( fdata.col_size, 0, (fdata.num_of_cols * sizeof(int) ) );

    fdata.col_size[0] = 20;
    fdata.col_size[1] = 15;
    fdata.col_size[2] = 20;

    fdata.col_pos = (int*) malloc( fdata.num_of_cols * sizeof(int) );
    memset( fdata.col_pos, 0, ( fdata.num_of_cols * sizeof(int) ) );

    count = 0;
    for( i=0; i<fdata.num_of_cols; ++i )
    {
 	fdata.col_pos[i] = count;
	count += fdata.col_size[i] + 2;
    }

    fdata.col_just = (int*)malloc(fdata.num_of_cols*sizeof(int));
    memset( fdata.col_just, LEFT_JUSTIFIED, (fdata.num_of_cols*sizeof(int)));

    fdata.h1_pos = (int*)malloc( sizeof(int) + 1 );
    memset( fdata.h1_pos, 0, sizeof(int) + 1 );
    fdata.h1_pos[0] = 0;
    fdata.h1_pos[1] = -1;

    fdata.h2_pos = (int*)malloc((fdata.num_of_cols * sizeof( int) ) + 1 );
    memset( fdata.h2_pos, 0, (fdata.num_of_cols*sizeof(int)) + 1 );
    count = 0;
    for( i=0; i<fdata.num_of_cols; ++i )
    {
	fdata.h2_pos[i] = count;
	count += fdata.col_size[i] + 2;
    }
    fdata.h2_pos[i] = -1;

    fdata.h3_pos = (int*)malloc( sizeof(int) + 1 );
    memset( fdata.h3_pos, 0, sizeof( int ) + 1 );
    fdata.h3_pos[0] = 0;
    fdata.h3_pos[1] = -1;

    fdata.h1_data = (char**) malloc( sizeof(char*) );
    memset( fdata.h1_data, NULL, (sizeof(char*)));
    NFAput_string( &fdata.h1_data[0], "" );

    fdata.h2_data = (char**) malloc(fdata.num_of_cols*sizeof(char*)+1 );
    memset( fdata.h2_data, NULL, (fdata.num_of_cols*sizeof(char*))+1);

    NFAput_string( &fdata.h2_data[0], "Catalog Name" );
    NFAput_string( &fdata.h2_data[1], "Item Name" );
    NFAput_string( &fdata.h2_data[2], "Item Revision" );

    fdata.h3_data = (char**) malloc( sizeof(char*) );
    memset( fdata.h3_data, NULL, (sizeof(char*)));
    NFAput_string( &fdata.h3_data[0], "" );

    sprintf( fdata.title, "Item(s) Available for Project \'%s\'",
	     NFMproject );

    fdata.select_set = (int*) malloc( tot_data * sizeof(int) );
    memset( fdata.select_set, 0, ( tot_data * sizeof(int) ) );

    fdata.data = (char**) malloc ( tot_data * sizeof(char*) );
    memset( fdata.data, NULL, ( tot_data * sizeof(char*) ) );

    _NFIdebug ((fname, "Load data : \n" ));
    for( i=0,j=0; i<tot_data; i+=fdata.num_of_cols,j+=item_list->columns )
    {
        NFAput_string( &fdata.data[i],   cdata.data[n+1] );
        NFAput_string( &fdata.data[i+1], item_ptr[j] );
        NFAput_string( &fdata.data[i+2], item_ptr[j+1] );
    }
    _NFIdebug ((fname, "Process Form : \n" ));
    status = SCprocess_free_form( &fdata, NFMprint_file );
    if( fdata.sts == FORM_CANCELED )
    {
        NFAfree_list( fdata.data, fdata.num_of_rows, fdata.num_of_cols );
	free( fdata.data );
        NFAfree_list( cdata.data, cdata.num_of_rows, cdata.num_of_cols );
	free( cdata.data );
	MEMclose( &attr_list );
	MEMclose( &data_list );
	MEMclose( &item_list );
 	ERRload_struct( NFI, NFI_W_COMMAND_CANCELLED, NULL, NULL );
	return( NFI_W_COMMAND_CANCELLED );
    }

/*  Pick up files that were chosen
 */ 
    count = 0;
    for( i=0; i<fdata.num_of_rows; ++i )
    {
	if( fdata.select_set[i] == 1 )
	  ++count;
    }

    _NFIdebug ((fname, "Count <%d>\n", count));
    pos = 8;
    data.num_of_rows = count + 2;
    data.num_of_cols = 4;
    tot_data = data.num_of_rows * data.num_of_cols;
    data.freeze_rows_count = 0;
    data.select_set_expected = FALSE;
    data.col_width = (int *) malloc (data.num_of_cols * sizeof (int));
    memset (data.col_width, 0, (data.num_of_cols * sizeof (int)));
    
    data.col_width[0] = 20;
    data.col_width[1] = 15;
    data.col_width[2] = 15;
    data.col_width[3] = 6;

    data.new_rows_expected = FALSE;
    sprintf (data.title, "Is Item OWNED or REFERENCED by Project \'%s\'?",
             NFMproject);

    data.selectable = (int *) malloc (tot_data * sizeof (int));
    memset (data.selectable, 0, (tot_data * sizeof (int)));

    for (i=pos+3,j=2,k=0; k<fdata.num_of_rows; j+=item_list->columns, ++k)
    {
	if( fdata.select_set[k] == 1 )
	{
	    if( strcmp( item_ptr[j], "O" ) == 0 )
	    {
		_NFIdebug ((fname, "Selectable <%s>\n", item_ptr[j-2]));
                data.selectable[i] = 1;
	    }
            i+=data.num_of_cols;
	}
    }

    data.hidden = (int *) malloc (tot_data * sizeof (int));
    memset (data.hidden, 0, (tot_data * sizeof (int)));

    /* allocate and initialize space to store data */

    data.data = (char **) malloc (tot_data * sizeof (char *));
    memset (data.data, NULL, (tot_data * sizeof (char *)));


    NFAput_string (&data.data[0], "Catalog Name");
    NFAput_string (&data.data[1], "Item Name");
    NFAput_string (&data.data[2], "Item Revision");
    NFAput_string (&data.data[3], "O or R");

    show_form = 0;
    for( i=0,k=0,j=pos; i<fdata.num_of_rows; k+=item_list->columns, ++i)
    {
	if( fdata.select_set[i] == 1 )
	{
	NFAput_string (&data.data[j],   cdata.data[n+1] );
	NFAput_string (&data.data[j+1], item_ptr[k] );
	NFAput_string (&data.data[j+2], item_ptr[k+1]);
        NFAput_string (&data.data[j+3], item_ptr[k+2]);
	if( strcmp( item_ptr[k+2], "O" ) == 0 )
	    show_form = 1;
	j+=data.num_of_cols;
        }
    }

    /* process column form until file_name has been entered */
  if( show_form )
  {
    do
        {
        FORM_FILLED = TRUE;
        status = SCprocess_column_form (&data, NFMprint_file);
        SCclear_msg ();

        _NFIdebug ((fname, "SCprocess_column_form -> %d\n", data.sts));

        if (data.sts != FORM_CANCELED)
            {
            for (i=pos+3; i<tot_data; i+=data.num_of_cols)
                {
                /* owned or referenced */
                status = NFAvalidate_proj_member_type (data.data[i]);
                if (status != NFI_S_SUCCESS)
                    {
                    FORM_FILLED = FALSE;
                    NFAput_string (&data.data[i], "");
                    SCdisplay_msg ("NFM:  Invalid Member Type.");
                    }
                }
            }
        }
    while ((FORM_FILLED == FALSE) && (data.sts != FORM_CANCELED));

    if (data.sts == FORM_CANCELED)
        {
        NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
        NFAfree_list (fdata.data, fdata.num_of_rows, fdata.num_of_cols);
        NFAfree_list (cdata.data, cdata.num_of_rows, cdata.num_of_cols);
        free (cdata.data);
        free (data.data);
	free (fdata.data);
        MEMclose (&attr_list);
        MEMclose (&data_list);
	MEMclose (&item_list);
	ERRload_struct( NFI, NFI_W_COMMAND_CANCELLED, NULL, NULL );
        return (NFI_W_COMMAND_CANCELLED);
        }
  } /* end if( show_form ) */

    /* add the new rows to the project buffer for each new member */

    data_ptr = (char **) data_list->data_ptr;
    column_ptr = (char **) data_list->column_ptr;

    for (i=2; i<data.num_of_rows; ++i)
        {
        str[0] = 0;
        k = i * data.num_of_cols;
        for (j=0; j<data_list->columns; ++j)
            {
		_NFIdebug(( fname, "column <%s>\n", column_ptr[j] ));
                 if (strcmp (column_ptr[j], "n_status") == 0)
                     strcat (str, "ADD");
            else if (strcmp (column_ptr[j], "n_projectname") == 0)
                     strcat (str, NFMproject);
            else if (strcmp (column_ptr[j], "n_catalogname") == 0)
                     strcat (str, cdata.data[n+1]);
            else if (strcmp (column_ptr[j], "n_itemname") == 0)
                     strcat (str, data.data[k+1]);
            else if (strcmp (column_ptr[j], "n_itemrev") == 0)
                     strcat (str, data.data[k+2]);
            else if (strcmp (column_ptr[j], "n_type") == 0)
                     strcat (str, data.data[k+3]);

            strcat (str, "\1");
        _NFIdebug ((fname, "string : <%s>\n", str));

            }  /* end for */

        _NFIdebug ((fname, "string : <%s>\n", str));

        status = MEMwrite (data_list, str);
        if (status != MEM_S_SUCCESS)
            {
            MEMclose (&attr_list);
            MEMclose (&data_list);
    	    MEMclose (&item_list);
            NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
            free (data.data);
            NFAfree_list (cdata.data, cdata.num_of_rows, cdata.num_of_cols);
            free (cdata.data);
            ERRload_struct( NFI, NFI_E_MEMORY, "%s%s","NFMadd_project_members",
			    "MEMwrite");
            return (status);
            }

        status = MEMbuild_array (data_list);

        data_ptr = (char **) data_list->data_ptr;
        column_ptr = (char **) data_list->column_ptr;

        }  /* end for */

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    NFAfree_list (fdata.data, fdata.num_of_rows, fdata.num_of_cols);
    NFAfree_list (cdata.data, cdata.num_of_rows, cdata.num_of_cols);
    free (cdata.data);
    free (data.data);
    free (fdata.data);

    } /* end if( catalog selected ) */

  MEMclose( &item_list );
  item_list = NULL;

  }  /* end catalog loop */


    if (_NFMdebug_st.NFIdebug_on)
        MEMprint_buffer ("PROJECT MEMBER DATA", data_list, _NFMdebug_st.NFIdebug_file);

    SCdisplay_msg ("Working..");    

    status = NFMRupdate_project_members (NFMuser_id, attr_list, data_list);

    if (status != NFM_S_SUCCESS)
      return(status);

    _NFIdebug ((fname, "NFMRupdate_project_members -> <0x%.8x>\n", status));

/*
     NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
     free (data.data);
     NFAfree_list (fdata.data, fdata.num_of_rows, fdata.num_of_cols);
     free (fdata.data);
     NFAfree_list (cdata.data, cdata.num_of_rows, cdata.num_of_cols);
     free (cdata.data);
*/
    MEMclose (&attr_list);
    MEMclose (&data_list);
    MEMclose (&item_list);    

    if (status != NFM_S_SUCCESS)
        return (status);

    _NFIdebug((fname, "Before make message\n"));
    NFAmake_msg (msg);
    _NFIdebug((fname, "After make message\n"));
    _NFIdebug ((fname, "%s\n", msg));
    SCdisplay_ref (msg);
        
    return (NFI_S_SUCCESS);
}


long delete_project_members ()

{
long   status;
int    i, j, k, m;
int    tot_data;
struct SCfree_data_st data;
char   **data_ptr;
char   **column_ptr;
MEMptr attr_list = NULL;
MEMptr data_list = NULL;
NDXptr index;
static char *fname = "delete_project_members";

    _NFIdebug ((fname, "Enter.\n"));

    SCdisplay_msg ("Working..");    

    status = NFMRquery_project_members (NFMuser_id, NFMproject, &attr_list,
                                        &data_list);

    if (status != NFM_S_SUCCESS)
        {
        MEMclose (&attr_list);
        MEMclose (&data_list);
        return (status);
        }

    status = MEMbuild_array (attr_list);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&attr_list);
        MEMclose (&data_list);
        ERRload_struct( NFI, NFI_E_MEMORY, "%s%s","NFMdelete_project_members",
			"MEMbuild_array");
        return (status);
        }

    status = MEMbuild_array (data_list);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&attr_list);
        MEMclose (&data_list);
        ERRload_struct( NFI, NFI_E_MEMORY, "%s%s","NFMdelete_project_members",
			"MEMbuild_array");
        return (status);
        }

    data_ptr = (char **) data_list->data_ptr;
    column_ptr = (char **) data_list->column_ptr;
    
    NFMRfill_index (attr_list, &index);

    if( data_list->rows == 0 )
    {
        MEMclose (&attr_list);
        MEMclose (&data_list);
	ERRload_struct( NFM, NFM_E_NO_MEMBERS_IN_PROJECT, 
			"%s", NFMproject );
	return( NFM_E_NO_MEMBERS_IN_PROJECT );
    }
    data.num_of_rows = data_list->rows;
    data.num_of_cols = 4;
    tot_data = data.num_of_cols * data.num_of_rows;
    data.freeze_rows_count = 0;
    data.freeze_cols_count = 2;
    data.max_indent = 0;
    data.select_set_expected = SELECT_SET_MULTI_ROW;

    data.col_size = (int *) malloc (data.num_of_cols * sizeof (int));
    memset (data.col_size, 0, (data.num_of_cols * sizeof (int)));
    data.col_size[0] = 15;
    data.col_size[1] = 15;
    data.col_size[2] = 15;
    data.col_size[3] = 11;

    data.col_pos = (int *) malloc (data.num_of_cols * sizeof (int));
    memset (data.col_pos, 0 , (data.num_of_cols * sizeof (int)));
    data.col_pos[0] = 0;
    data.col_pos[1] = 17;
    data.col_pos[2] = 34;
    data.col_pos[3] = 51;

    data.col_just = (int *) malloc (data.num_of_cols * sizeof (int));
    memset (data.col_just, LEFT_JUSTIFIED, (data.num_of_cols * sizeof (int)));
    
    data.h1_pos = (int *) malloc (sizeof (int) + 1);
    memset (data.h1_pos, 0, sizeof (int) + 1);
    data.h1_pos[0] = 0;
    data.h1_pos[1] = -1;

    data.h2_pos = (int *) malloc ((data.num_of_cols * sizeof (int)) + 1);
    memset (data.h2_pos, 0, (data.num_of_cols * sizeof (int)) + 1);
    data.h2_pos[0] = 0;
    data.h2_pos[1] = 17;
    data.h2_pos[2] = 34;
    data.h2_pos[3] = 51;
    data.h2_pos[4] = -1;
    
    data.h3_pos = (int *) malloc (sizeof (int) + 1);
    memset (data.h3_pos, 0, sizeof (int) + 1);
    data.h3_pos[0] = 0;
    data.h3_pos[1] = -1;
    
    data.h1_data = (char **) malloc (sizeof (char *));
    memset (data.h1_data, NULL, (sizeof (char *)));
    NFAput_string (&data.h1_data[0], "");
    
    data.h2_data = (char **) malloc (data.num_of_cols * (sizeof (char *)));
    memset (data.h2_data, NULL, data.num_of_cols * (sizeof (char *)));
    NFAput_string (&data.h2_data[0], "Member Name");
    NFAput_string (&data.h2_data[1], "Member Revision");
    NFAput_string (&data.h2_data[2], "Member Catalog");
    NFAput_string (&data.h2_data[3], "Member Type");
    
    data.h3_data = (char **) malloc (sizeof (char *));
    memset (data.h3_data, NULL, (sizeof (char *)));
    NFAput_string (&data.h3_data[0], "");
    
    strcpy (data.title, "Choose Members to Delete");

    data.select_set = (int *) malloc (tot_data * sizeof (int));
    memset (data.select_set, 0, (tot_data * sizeof (int)));

    /* allocate and initialize space to store data */

    data.data = (char **) malloc (tot_data * sizeof (char *));
    memset (data.data, NULL, (tot_data * sizeof (char *)));

    for (i=0, k=0; i<tot_data; i+=data.num_of_cols, ++k)
        {
        m = k * data_list->columns;
        for (j=0; j<data_list->columns; ++j)
            {
                 if (strcmp (column_ptr[j], "n_itemname") == 0)
                     NFAput_string (&data.data[i], data_ptr[m+j]);
            else if (strcmp (column_ptr[j], "n_itemrev") == 0)
                     NFAput_string (&data.data[i+1], data_ptr[m+j]);
            else if (strcmp (column_ptr[j], "n_catalogname") == 0)
                     NFAput_string (&data.data[i+2], data_ptr[m+j]);
            else if (strcmp (column_ptr[j], "n_type") == 0)
                     NFAput_string (&data.data[i+3], data_ptr[m+j]);
            }
        }

    /* process free form */
    status = SCprocess_free_form (&data, NFMprint_file);

    if (data.sts == FORM_CANCELED)
        {
        NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
        free (data.data);
        MEMclose (&attr_list);
        MEMclose (&data_list);
	ERRload_struct( NFI, NFI_W_COMMAND_CANCELLED, NULL, NULL );
        return (NFI_W_COMMAND_CANCELLED);
        }

    /* add the new rows to the project buffer for each new member */

    for (i=0; i<data.num_of_rows; ++i)
        {
        if ((data.select_set[i] == 1) || (data.sts == FORM_SELECTED))
            {
            for (j=0; j<data_list->columns; ++j)
                {
                if (strcmp (column_ptr[j], "n_status") == 0)
                    break;
                }  /* end for */

            status = MEMwrite_data (data_list, "DROP", i+1, j+1);
            if (status != MEM_S_SUCCESS)
                {
                MEMclose (&attr_list);
                MEMclose (&data_list);
                NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
                free (data.data);
	        ERRload_struct( NFI, NFI_E_MEMORY, "%s%s",
				"NFMdelete_project_members","MEMwrite_data");
                return (status);
                }

            status = MEMbuild_array (data_list);
            if (status != MEM_S_SUCCESS)
                {
                MEMclose (&attr_list);
                MEMclose (&data_list);
                NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
                free (data.data);
	        ERRload_struct( NFI, NFI_E_MEMORY, "%s%s",
				"NFMdelete_project_members","MEMbuild_array");
                return (status);
                }

            data_ptr = (char **) data_list->data_ptr;
            column_ptr = (char **) data_list->column_ptr;

            }  /* end if select_set */

        }  /* end for */

    if (_NFMdebug_st.NFIdebug_on)
        MEMprint_buffers ("PROJECT DATA", data_list, _NFMdebug_st.NFIdebug_file);

    SCdisplay_msg ("Working..");    

    status = NFMRupdate_project_members (NFMuser_id, attr_list, data_list);

    _NFIdebug ((fname, "NFMRupdate_project_members -> <0x%.8x>\n", status));

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    MEMclose (&attr_list);
    MEMclose (&data_list);
    
    if (status != NFM_S_SUCCESS)
        return (status);

    NFAmake_msg (msg);
    _NFIdebug ((fname, "%s\n", msg));
    SCdisplay_ref (msg);
        
    return (NFI_S_SUCCESS);
}



