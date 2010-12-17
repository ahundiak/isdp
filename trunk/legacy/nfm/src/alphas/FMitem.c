#include "machine.h"
#include "NFMdef.h"
#include "SCstruct.h"
#include "SCdef.h"
#include "NFMRextern.h"
#include "NFMdisplays.h"
#include "NFMRlist.h"
#include "NFMtitles.h"
#include "UMS.h"
#include "WFcommands.h"

long add_item ()

{
long   status;
int    i, j, k,l,n,a,b;
int    tot_data;
int    max_attr_len = 0;
int    max_syn_len = 0;
int    max_dtype_len = 0;
int    pos;
int    count = 0;
int    pcount =0;
int    FORM_FILLED;
struct SCcolumn_data_st data;
char   item_name[NFM_ITEMNAME+1];
char   item_rev[NFM_ITEMREV+1];
char   index_num[20];
char   str[100];
char   **n_data_ptr;
char   **data_ptr;
char   **column_ptr;
MEMptr attr_list = NULL;
MEMptr data_list = NULL;
MEMptr value_list = NULL;
NDXptr index;
static char *fname = "NFAadd_item";

    SCdisplay_msg ("Working..");    

    status = NFMRquery_add_item_attributes (NFMuser_id, NFMcatalog,
                                            &attr_list, &data_list,
                                            &value_list);

    if (status != NFM_S_SUCCESS)
        {
        MEMclose (&attr_list);
        MEMclose (&data_list);
        MEMclose (&value_list);
        return (status);
        }

    status = MEMbuild_array (attr_list);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&attr_list);
        MEMclose (&data_list);
        MEMclose (&value_list);
        ERRload_struct(NFI, NFI_E_MEMORY, "%s%s", "NFMadd_item",
		       "MEMbuild_array");
        return (status);
        }

    data_ptr = (char **) attr_list->data_ptr;
    column_ptr = (char **) attr_list->column_ptr;

    NFMRfill_index (attr_list, &index);

    count = 0;

    for (i=0; i<attr_list->rows*attr_list->columns; i+=attr_list->columns)
        {
        if (strcmp (data_ptr[i+index.w], "Y") == 0)
            ++count;
        }

    _NFIdebug(( fname, "Displayable fields : <%d>\n", count));

    pos = 6;
    data.num_of_rows = count + 2;
    data.num_of_cols = 3;
    tot_data = data.num_of_cols * data.num_of_rows;
    data.freeze_rows_count = 0;
    data.select_set_expected = FALSE;
    data.col_width = (int *) malloc (data.num_of_cols * sizeof (int));
    memset (data.col_width, 0, (data.num_of_cols * sizeof (int)));
    
    status = NFAfind_len (data_ptr, column_ptr, index, 
                          (attr_list->rows*attr_list->columns),
                          attr_list->columns, &max_attr_len, &max_syn_len,
                          &max_dtype_len);
    if( max_syn_len > 23 )
    max_syn_len = 23;
    if( max_dtype_len > 35 )
    max_dtype_len = 35;
    
    data.col_width[0] = max_syn_len + 2;
    data.col_width[1] = 10;
    data.col_width[2] = max_dtype_len;
    data.new_rows_expected = FALSE;
    strcpy (data.title, "Enter Item Information");

    data.selectable = (int *) malloc (tot_data * sizeof (int));
    memset (data.selectable, 0, (tot_data * sizeof (int)));

    for (i=pos+2; i<tot_data; i+=data.num_of_cols)
        data.selectable[i] = 1;

    data.hidden = (int *) malloc (tot_data * sizeof (int));
    memset (data.hidden, 0, (tot_data * sizeof (int)));

    /* allocate and initialize space to store data */

    data.data = (char **) malloc (tot_data * sizeof (char *));
    memset (data.data, NULL, (tot_data * sizeof (char *)));

    NFAput_string (&data.data[0], "Attribute");
    NFAput_string (&data.data[1], "Data Type");


    for (i=pos, j=0; i<tot_data; j+=attr_list->columns)
        {
        if (strcmp (data_ptr[j+index.w], "Y") == 0)
            {
            if (strcmp (data_ptr[j+index.syn], "") != 0)
                NFAput_string (&data.data[i], data_ptr[j+index.syn]);
            else
                NFAput_string (&data.data[i], data_ptr[j+index.name]);
            NFAput_string (&data.data[i+1], data_ptr[j+index.dt]);
            i+=data.num_of_cols;
            }
        }

    /* if attribute is writable but not readable, hide it */
    for (j=pos; j<tot_data; j+=data.num_of_cols)
        {
        for (i=0; i<attr_list->rows*attr_list->columns; i+=attr_list->columns)
            {
            if (((strcmp (data_ptr[i+index.syn], data.data[j]) == 0) ||
                 (strcmp (data_ptr[i+index.nfm], data.data[j]) == 0)) &&
                ((strcmp (data_ptr[i+index.r], "N") == 0) &&
                 (strcmp (data_ptr[i+index.w], "Y") == 0)))
                {
                data.hidden[j+2] = 1;
                break;
                }
            }
        }

    status = MEMbuild_array (data_list);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&attr_list);
        MEMclose (&data_list);
        MEMclose (&value_list);
        NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
        free (data.data);
        ERRload_struct(NFI, NFI_E_MEMORY, "%s%s", "NFMadd_item",
		       "MEMbuild_array");
        return (status);
        }

    n_data_ptr = (char **) data_list->data_ptr;
 
    
    for (i=pos+2, j=0, k=0; i<tot_data; j+=attr_list->columns, ++k)
        {
        if (strcmp (data_ptr[j+index.w], "Y") == 0)
            {
            NFAput_string (&data.data[i], n_data_ptr[k]);

            if (strcmp (data_ptr[j+index.list], "0") != 0)
                {
                /* if there is a value list, display the list and let them
                   choose the value */
                status = NFAget_value_list_index (data_ptr[j+index.list],
                            value_list, data_ptr[j+index.name],
                            data_ptr[j+index.syn], index_num);
                if (status != NFI_S_SUCCESS)
                    {
                    MEMclose (&attr_list);
                    MEMclose (&value_list);
                    MEMclose (&data_list);
                    return (status);
                    }
                NFAput_string (&data.data[i], index_num);
	        data.selectable[i] = 0;		
                }

            i+=data.num_of_cols;
            }
        }

    /* process column form until file_name has been entered */
    do
        {
        FORM_FILLED = TRUE;
        status = SCprocess_column_form (&data, NFMprint_file);
        SCclear_msg ();

        _NFIdebug(( fname, "Return from SCprocess_column_form -> %d\n", 
			data.sts));

        if (data.sts != FORM_CANCELED)
            {
            status = NFAput_and_validate_data (data.data, pos+2, tot_data,
                                               data.num_of_cols);

            /* if attribute is required ("n_null" == "N"),
               user must keyin a value */

            status = NFAvalidate_nulls (attr_list, index, data, pos,
                                        &FORM_FILLED);
            }
        }
    while ((FORM_FILLED == FALSE) && (data.sts != FORM_CANCELED));

    if (data.sts == FORM_CANCELED)
        {
        NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
        free (data.data);
        MEMclose (&attr_list);
        MEMclose (&data_list);
        MEMclose (&value_list);
    	ERRload_struct( NFI, NFI_W_COMMAND_CANCELLED, NULL, NULL );
        return (NFI_W_COMMAND_CANCELLED);
        }

    for (i=pos; i<tot_data; i+=data.num_of_cols)
        {
        for (j=0, k=0; k<data_list->columns; j+=attr_list->columns, ++k)
            {

            if (((strcmp (data_ptr[j+index.syn], data.data[i]) == 0) ||
                 (strcmp (data_ptr[j+index.name], data.data[i]) == 0)) &&
                (strcmp (data_ptr[j+index.w], "Y") == 0))
                {
                status = MEMwrite_data (data_list, data.data[i+2], 1, k+1);
                _NFIdebug((fname, "The value is <%s>\n", data.data[i+2]));
          
                if (status != MEM_S_SUCCESS)
                    {
                    MEMclose (&attr_list);
                    MEMclose (&data_list);
                    MEMclose (&value_list);
                    NFAfree_list(data.data,data.num_of_rows, data.num_of_cols);
                    free (data.data);
                    ERRload_struct( NFI, NFI_E_MEMORY, "%s%s", "NFMadd_item",
				    "MEMwrite_data");
                    return (status);
                    }

                if (strcmp(data_ptr[j+index.name], "n_versionlimit")==0)
                 {
                    l= strlen(data.data[i+2]);
                    for (n=0; n<l; ++n)
                     {
                       if (!isdigit (data.data[i+2][n]))
                       {
                          status = NFI_W_NULL_NUMERIC_FIELD;
                           _NFIdebug((fname,
                           "the string is NULL: returning <0x%.8x>\n",
                             status));
                           if (status !=NFI_S_SUCCESS)
                             {
                               NFAfree_list (data.data, data.num_of_rows,
                                     data.num_of_cols);
                               free (data.data);
                               MEMclose (&attr_list);
                               MEMclose (&value_list);
                               MEMclose (&data_list);
                               NFAset_message();
                               SCdisplay_msg(msg);
                               ERRreset_struct();
                               ERRload_struct(NFI, NFI_W_NULL_NUMERIC_FIELD,
                                     "%s", "n_versionlimit");
                                  return(status);
                             }
                         }
                     }
                  }
                if (strcmp (data_ptr[j+index.nfm], "n_itemname") == 0)
                    strcpy (item_name, data.data[i+2]);
                if (strcmp (data_ptr[j+index.nfm], "n_itemrev") == 0)
                    strcpy (item_rev, data.data[i+2]);
              }

            }

        }

    status = NFMRtic_it( data_list );
    if( status != NFM_S_SUCCESS )
    {
        NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
        free (data.data);
        MEMclose (&attr_list);
        MEMclose (&data_list);
        MEMclose (&value_list);
	ERRload_struct( NFI, NFI_E_ADD_ITEM, "%s%s", item_name, item_rev);
        return( NFI_E_ADD_ITEM );
    }

    SCdisplay_msg ("Working..");    

    status = NFMRadd_item (NFMuser_id, NFMcatalog, attr_list, data_list);

    _NFIdebug(( fname, "Return from NFMadd_item -> 0x%.8x\n", status));

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    MEMclose (&attr_list);
    MEMclose (&data_list);
    MEMclose (&value_list);
    
    if (status != NFM_S_SUCCESS)
        return (status);

    strcpy (NFMitem, item_name);
    strcpy (NFMrev, item_rev);

    NFMset_ind = 0;

    NFAmake_msg (msg);
    _NFIdebug(( fname, "%s\n", msg));
    SCdisplay_ref (msg);
        
    return (NFI_S_SUCCESS);
}


long delete_item ()

{
long   status;
int    confirm;
static char *fname = "NFAdelete_item";

    NFAconfirm( "delete this item", &confirm );
    if( confirm == 0 )
	return( NFI_S_SUCCESS );

    SCdisplay_msg ("Working..");    
 
#ifdef COMBINED_CLIENT_SERVER
    {
    long return_value;
    status = NFMdelete_item (NFMuser_id, NFMcatalog, NFMitem, NFMrev,
                             &return_value);
    }
#else
    status = NFMRdelete_item (NFMuser_id, NFMcatalog, NFMitem, NFMrev);
#endif

    _NFIdebug(( fname, "Return from NFMdelete_item -> 0x%.8x\n", status));

    if (status != NFM_S_SUCCESS)
        return (status);

    strcpy (NFMitem, "");
    strcpy (NFMrev, "");

    NFMset_ind = 0;

    NFAmake_msg (msg);
    _NFIdebug(( fname, "%s\n", msg));
    SCdisplay_ref (msg);
        
    return (NFI_S_SUCCESS);
}

long delete_item_from_list ()

{
int    i;
int    j;
int    k;
int    count;
int    confirm;
int    subsystem;
long   err_no;
long   return_value;
long   status;
char   title[80];
static char *fname = "NFAdelete_item_from_list";
struct SCfree_data_st data;
struct SCfree_data_st err_data;
NFMlist display_struct;

    if ((status = (long) UMSGetByNum
        (title, NFT_P_LIST_ITEMS, "%s", NFMcatalog)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        sprintf (title, "List of Items in Catalog <%s>", NFMcatalog );
      }

    NFAfill_list_struct (&display_struct, DSP_ITEMS, SELECT_SET_MULTI_ROW,
 NFM_FULL_DISPLAY, -1, NFMsearch_name, NFMsort_name, NFMcatalog, "", "", 
 "", "", title);

    status = NFAdisplay_elements (&data, display_struct);
    if (status == NFI_W_COMMAND_CANCELLED)
        {
        _NFIdebug(( fname, "%s\n", "FORM_CANCELED" ));
        NFAfree_list_struct (&display_struct);
        return( status );
        }

    if (status != NFI_S_SUCCESS)
        {
        _NFIdebug(( fname, "NFAdisplay_elements : <0x%.8x>\n", status));
        NFAfree_list_struct (&display_struct);
        return (status);
        }

    for( i=0,count=0; i<data.num_of_rows; ++i )
     {
        if(( data.select_set[i] == 1 ) || (data.sts == FORM_SELECTED))
            ++count;
     }
    if( count == 0 )
    {
        NFAfree_list_struct (&display_struct);
        return( NFI_S_SUCCESS );
    }

    NFAconfirm( "delete these item(s)", &confirm );
    if( confirm == 0 )
    {
	NFAfree_list_struct( &display_struct );
	return( NFI_S_SUCCESS );
    }

    /* set up error form */
    NFAprepare_error_form ( data, &err_data, count, 
			    "Status of Delete Item(s)");

    strcpy( title, "Working" );

    for (i=0,k=0; i<data.num_of_rows; ++i)
    {
        j = i * data.num_of_cols;
        if ((data.select_set[i] == 1) || (data.sts == FORM_SELECTED))
        {
	    strcat( title, "." );
	    SCdisplay_msg( title );

            NFAput_string( &err_data.data[k], data.data[j+NFMitem_loc] );
            NFAput_string( &err_data.data[k+1], data.data[j+NFMrev_loc] );

            status = NFAalpha_validate_user_access (NFMuser_id, DELETE_ITEM,
                     NFMworkflow, NFMproject, NFMcatalog, 
		     data.data[j+NFMitem_loc], data.data[j+NFMrev_loc] );
            if (status != NFI_S_SUCCESS)
        	    {
            		NFAset_message();
            		NFAput_string( &err_data.data[k+2], msg );
            	  	break;
           	    }
            _NFIdebug((fname, "Return status is <%s>\n", msg));
#ifdef COMBINED_CLIENT_SERVER
	    status = NFMdelete_item (NFMuser_id, NFMcatalog,
			data.data[j+NFMitem_loc], data.data[j+NFMrev_loc], 
			&return_value);
#else
    	    status = NFMRdelete_item (NFMuser_id, NFMcatalog,
			data.data[j+NFMitem_loc], data.data[j+NFMrev_loc]);
     
           _NFIdebug(( fname, "Return first from NFMdelete_item -> 0x%.8x\n",
            status));
#endif
	    if( status == NFM_S_SUCCESS )
	    {
    		if( (strcmp( NFMitem, data.data[j+NFMitem_loc]) == 0 ) &&
		    (strcmp( NFMrev,  data.data[j+NFMrev_loc] ) == 0 ))
    		{
	 	      strcpy (NFMitem, data.data[j+NFMitem_loc]);
		      strcpy (NFMrev, data.data[j+NFMrev_loc]);
              strcpy (NFMitem, "");
              strcpy (NFMrev, "");
    		}
	    }

	    _NFIdebug(( fname, "Return from NFMdelete_item -> 0x%.8x\n", 
			status));

            NFAset_message();
    	    NFAput_string( &err_data.data[k+2], msg );
            ERRget_number( &err_no, &subsystem );
            NFAalpha_set_to_state ( err_no, msg );
	        k+=err_data.num_of_cols;
        }
    }

    /* process error form */
    SCdisplay_msg ("<PF1> or <PF3> to Cancel Form.");
    status = SCprocess_free_form (&err_data, NFMprint_file);
    SCclear_msg ();
    NFAfree_list (err_data.data, err_data.num_of_rows, err_data.num_of_cols);
    free (err_data.data);

    NFAfree_list_struct (&display_struct);
        
    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);
/*
    if (status != NFM_S_SUCCESS)
        return (status);*/

    strcpy (NFMitem, "");
    strcpy (NFMrev, "");

    NFAmake_msg (msg);
    _NFIdebug(( fname, "%s\n", msg));
    SCdisplay_ref (msg);
        
    return (NFI_S_SUCCESS);
}



