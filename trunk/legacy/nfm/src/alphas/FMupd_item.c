#include "machine.h"
#include "NFMdef.h"
#include "SCstruct.h"
#include "SCdef.h"
#include "NFMRextern.h"
#include "NFIerrordef.h"

long update_item ()

{
long   astatus;
long   status;
long   value=0;
int    i, j, k,l,n;
int    tot_data;
int    max_attr_len = 0;
int    max_syn_len = 0;
int    max_dtype_len = 0;
int    pos;
int    count = 0;
struct SCcolumn_data_st data;
int    FORM_FILLED;
char   index_num[INTEGER+1];
char   seqno[16];
char   str[50];
char   **n_data_ptr;
char   **data_ptr;
char   **column_ptr;
MEMptr attr_list = NULL;
MEMptr data_list = NULL;
MEMptr value_list = NULL;
NDXptr index;

static char *fname = "NFAupdate_item";

    SCdisplay_msg ("Working..");    

    status = NFMRprepare_update_item (NFMuser_id, NFMcatalog, NFMitem, NFMrev,
                                      &attr_list, &data_list, &value_list);
    if (status != NFM_S_SUCCESS)
        {
          MEMclose (&attr_list);
          MEMclose (&data_list);
          MEMclose (&value_list);
          return (status);
        }

    status = MEMbuild_array (attr_list);
    if( status != MEM_S_SUCCESS )
    {	
	_NFIdebug(( fname, "MEMbuild <0x%.8x>\n", status ));
	ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        MEMclose (&attr_list);
        MEMclose (&data_list);
        MEMclose (&value_list);
	return( NFM_E_MEM );   
    }
    data_ptr = (char **) attr_list->data_ptr;
    column_ptr = (char **) attr_list->column_ptr;

    NFMRfill_index (attr_list, &index);

    status = MEMbuild_array (data_list);
    if( status != MEM_S_SUCCESS )
    {	
    	_NFIdebug(( fname, "MEMbuild <0x%.8x>\n", status ));
       	ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        MEMclose (&attr_list);
        MEMclose (&data_list);
        MEMclose (&value_list);
    	return( NFM_E_MEM );   
    }

    n_data_ptr = (char **) data_list->data_ptr;

    count = 0;

    for (i=0; i<attr_list->rows*attr_list->columns; i+=attr_list->columns)
        {
        if ((strcmp (data_ptr[i+index.w], "Y") == 0) &&
            (strcmp (data_ptr[i+index.u], "Y") == 0))
            ++count;
        }

    _NFIdebug(( fname, "Displayable fields : <%d>\n", count));

    pos = 0;
    data.num_of_rows = count ;
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
    strcpy (data.title, "Change Item Information");

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
          if ((strcmp (data_ptr[j+index.w], "Y") == 0) &&
            (strcmp (data_ptr[j+index.u], "Y") == 0))
            {
            /* In the following line function 'strcmp' is replaced by 'strlen'.
               SSRS - 23/11/93
            */
	    /*if (strcmp (data_ptr[j+index.syn]) != 0)*/
	    if (strlen (data_ptr[j+index.syn]) != 0)
                NFAput_string (&data.data[i], data_ptr[j+index.syn]);
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
                 (strcmp (data_ptr[i+index.w], "Y") == 0) &&
                 (strcmp (data_ptr[i+index.u], "Y") == 0)))
                {
                data.hidden[j+2] = 1;
                break;
                }
            }
        }

    /* insert data */
    for (i=pos+2, j=0, k=0; i<tot_data; j+=attr_list->columns, ++k)
        {
        if ((strcmp (data_ptr[j+index.w], "Y") == 0) &&
            (strcmp (data_ptr[j+index.u], "Y") == 0))
            {
 	      if( (strcmp( data_ptr[j+index.list], "" ) != 0 ) &&
		  (strcmp( data_ptr[j+index.list], "0") != 0 ))
	      {
	         _NFIdebug(( fname, "list_no <%s>\n",data_ptr[j+index.list]));
                  status = NFAget_value_list_index (data_ptr[j+index.list],
                         value_list, data_ptr[j+index.syn],
			 data_ptr[j+index.syn], index_num);
                  if (status != NFI_S_SUCCESS)
                      {
	              astatus = NFMRcancel_update_item (NFMuser_id, attr_list,
							data_list);
  		      NFAfree_list (data.data, data.num_of_rows, 
				    data.num_of_cols);
		      free (data.data);
                      MEMclose (&attr_list);
                      MEMclose (&value_list);
                      MEMclose (&data_list);
                      return (status);
                      }
   	          _NFIdebug(( fname, "Inserting Data <%s>\n", index_num ));
                  NFAput_string (&data.data[i], index_num );
 	          data.selectable[i] = 0;
	      }
    	      else
	      {
	          _NFIdebug(( fname, "Inserting Data <%s>\n", n_data_ptr[k] ));
                  NFAput_string (&data.data[i], n_data_ptr[k]);
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

        _NFIdebug(( fname, "return from SCprocess_column_form -> %d\n", 
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
	ERRload_struct( NFI, NFI_W_COMMAND_CANCELLED, NULL, NULL );
        astatus = NFMRcancel_update_item (NFMuser_id, attr_list, data_list);
        MEMclose (&attr_list);
        MEMclose (&data_list);
        MEMclose (&value_list);
	if( astatus != NFM_S_SUCCESS )
	{
	    ERRload_struct( NFI, NFI_E_CANCEL_UPDATE_ITEM, "%s%s", NFMitem,
			    NFMrev );
	    return( NFI_E_CANCEL_UPDATE_ITEM );
	}
        return (NFI_W_COMMAND_CANCELLED);
        }
    
    for (i=pos; i<tot_data; i+=data.num_of_cols)
        {
        for (j=0, k=0; k<data_list->columns; j+=attr_list->columns, ++k)
            {
            if (((strcmp (data_ptr[j+index.syn], data.data[i]) == 0) ||
                 (strcmp (data_ptr[j+index.name], data.data[i]) == 0)) &&
                ((strcmp (data_ptr[j+index.w], "Y") == 0) &&
                 (strcmp (data_ptr[j+index.u], "Y") == 0)))
                {
                status = MEMwrite_data (data_list, data.data[i+2], 1, k+1);
                if (status != MEM_S_SUCCESS)
                    {
                    MEMclose (&attr_list);
                    MEMclose (&data_list);
                    MEMclose (&value_list);
                    NFAfree_list(data.data,data.num_of_rows, data.num_of_cols);
                    free (data.data);
		    ERRload_struct( NFI, NFI_E_MEMORY, "%s%s","NFMupdate_item",
				    "MEMwrite_data");
                    astatus = NFMRcancel_update_item (NFMuser_id, attr_list,
						     data_list);
		    if( astatus != NFM_S_SUCCESS )
			ERRload_struct( NFI, NFI_E_CANCEL_UPDATE_ITEM,
					"%s%s", NFMitem, NFMrev );
	            return (status);
                    }
                if (strcmp( data_ptr[j+index.name], "n_versionlimit")==0)
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
                               astatus = NFMRcancel_update_item (NFMuser_id,
                               attr_list, data_list);
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
                 break;
                }
           }
        }
    status = NFMRtic_it( data_list );
    if( status != NFM_S_SUCCESS )
    {
        astatus = NFMRcancel_update_item (NFMuser_id, attr_list,
		     data_list);
        if( astatus != NFM_S_SUCCESS )
    	ERRload_struct( NFI, NFI_E_CANCEL_UPDATE_ITEM,"%s%s",NFMitem, NFMrev );
        NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
        free (data.data);
        MEMclose (&attr_list);
        MEMclose (&data_list);
        MEMclose (&value_list);
        ERRload_struct( NFI, NFI_E_UPDATE_ITEM, "%s%s",NFMitem,NFMrev  );
        return( status );
    }

    SCdisplay_msg ("Working..");    

    status = NFMRupdate_item (NFMuser_id, NFMcatalog, attr_list, data_list);

    _NFIdebug(( fname, "return from NFMupdate_item -> 0x%.8x\n", status));

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    MEMclose (&attr_list);
    MEMclose (&data_list);
    MEMclose (&value_list);
    
    if (status != NFM_S_SUCCESS)
        return (status);

    NFAmake_msg (msg);
    _NFIdebug(( fname, "%s\n", msg));
    SCdisplay_ref (msg);
        
    return (NFI_S_SUCCESS);
}


