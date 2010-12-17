#include "machine.h"
#include "SCstruct.h"
#include "SCdef.h"
#include "NFMRextern.h"
#include "NFMRlist.h"
#include "NFMtitles.h"
#include "NFMdisplays.h"
#include "UMS.h"

long create_catalog ()

{
long   status;
long   user_id ;
int    i, j, k;
int    tot_data;
int    max_attr_len = 0;
int    max_syn_len = 0;
int    max_dtype_len = 0;
int    pos;
int    count = 0;
int    old_row_count = 0;
int    FORM_FILLED;
int    next_highest;
struct SCcolumn_data_st data;
char   **n_data_ptr;
char   **data_ptr;
char   **column_ptr;
char   str[1028];
char   catalog_name[21];
char   seqno[10];
char   loc_name[21]; 
char   index_num[20];
char   t_basic[20];
char   t_appl[20];
MEMptr loc_attr = NULL;
MEMptr loc_data = NULL;
MEMptr loc_value = NULL;
MEMptr attr_list = NULL;
MEMptr data_list = NULL;
MEMptr value_list = NULL;
MEMptr application = NULL ;
NDXptr index;
static char *fname = "NFAcreate_catalog";

    SCdisplay_msg ("Working..");    

    user_id = 0 ;

    status = NFMRquery_addto_loc_attributes (user_id, loc_name,
					     &loc_attr, &loc_data, &loc_value);

    if (status != NFM_S_SUCCESS)
        {
        MEMclose (&loc_attr);
        MEMclose (&loc_data);
        MEMclose (&loc_value);
        return (status);
        }

    status = MEMopen (&application, MEM_SIZE);
    if (status != MEM_S_SUCCESS)
    {
        ERRload_struct( NFI, NFI_E_MEMORY, "%s%s", "NFAcreate_catalog",
			"MEMopen (application)" );
        MEMclose (&application);
        MEMclose (&loc_attr);
        MEMclose (&loc_data);
        MEMclose (&loc_value);
        return (NFI_E_MEMORY);
    }

    status = MEMwrite_format (application, "n_type", "char(20)");
    if (status != MEM_S_SUCCESS)
    {
        ERRload_struct( NFI, NFI_E_MEMORY, "%s%s", "NFAcreate_catalog",
			"MEMwrite_format" );
        MEMclose (&application);
        MEMclose (&loc_attr);
        MEMclose (&loc_data);
        MEMclose (&loc_value);
        return (NFI_E_MEMORY);
    }

    status = MEMwrite_format (application, "value", "char(20)");
    if (status != MEM_S_SUCCESS)
    {
        ERRload_struct( NFI, NFI_E_MEMORY, "%s%s", "NFAcreate_catalog",
			"MEMwrite_format" );
        MEMclose (&application);
        MEMclose (&loc_attr);
        MEMclose (&loc_data);
        MEMclose (&loc_value);
        return (NFI_E_MEMORY);
    }

    status = MEMbuild_array (loc_attr);
    if( status != MEM_S_SUCCESS )
    {
        ERRload_struct( NFI, NFI_E_MEMORY, "%s%s", "NFAcreate_catalog",
			"MEMbuild_array (loc_attr)" );
	MEMclose (&application);
        MEMclose (&loc_attr);
        MEMclose (&loc_data);
        MEMclose (&loc_value);
        return (NFI_E_MEMORY);
    }
    status = MEMbuild_array (loc_value);
    if( status != MEM_S_SUCCESS )
    {
        ERRload_struct( NFI, NFI_E_MEMORY, "%s%s", "NFAcreate_catalog",
			"MEMbuild_array (loc_value)" );
	MEMclose (&application);
        MEMclose (&loc_attr);
        MEMclose (&loc_data);
        MEMclose (&loc_value);
        return (NFI_E_MEMORY);
    }
    data_ptr = (char **) loc_attr->data_ptr;

    NFMRfill_index (loc_attr, &index);

    status = MEMbuild_array (loc_data);
    if( status != MEM_S_SUCCESS )
    {
        ERRload_struct( NFI, NFI_E_MEMORY, "%s%s", "NFAcreate_catalog",
			"MEMbuild_array (loc_data)" );
	MEMclose (&application);
        MEMclose (&loc_attr);
        MEMclose (&loc_data);
        MEMclose (&loc_value);
        return (NFI_E_MEMORY);
    }

    strcpy (t_basic, "");
    strcpy (t_appl, "");

    n_data_ptr = (char **) loc_data->data_ptr;
    tot_data   = loc_attr->rows * loc_attr->columns;
    for ( j=0; j<tot_data; j+=loc_attr->columns)
    {
        if ((strcmp (data_ptr[j+index.r], "Y") == 0) ||
            (strcmp (data_ptr[j+index.w], "Y") == 0))
        {
            if (strcmp (data_ptr[j+index.list], "0") != 0)
            {
                /* if there is a value list, display the list and let them
                   choose the value. If the 'n_name' is 't_appl' or 't_basic',
		   multiple values could be chosen and these values need
		   to be put in the application buffer.

                   KT 3/4/92 - This function returns the t_basic/t_appl names
                               instead of numbers because that's all the values
                               list has! We need to save this info for the
                               second form.
                               NOTE: t_basic cannot be NULL; t_appl can be!
		 */
		if( strcmp( data_ptr[j+index.name], "t_basic" ) == 0 )
		{
                    status = NFAget_value_list_index (data_ptr[j+index.list],
                            loc_value, data_ptr[j+index.name],
                            data_ptr[j+index.syn], index_num);
                    if (status != NFI_S_SUCCESS)
                    {
                        MEMclose (&loc_attr);
                        MEMclose (&loc_value);
                        MEMclose (&loc_data);
		        MEMclose (&application);
                        return (status);
                    }
                    _NFIdebug(( fname, "Chosen Value for t_basic <%s>\n",
			    index_num));
                    strcpy (t_basic, index_num);
		    sprintf(str, "t_basic\1%s\1", index_num) ;
  		    status = MEMwrite (application, str);
		    if (status != MEM_S_SUCCESS)
		    {
		        ERRload_struct( NFI, NFI_E_MEMORY, "%s%s", 
				"NFAcreate_catalog","MEMwrite" );
			MEMclose (&application);
		        MEMclose (&loc_attr);
		        MEMclose (&loc_data);
		        MEMclose (&loc_value);
		        return (NFI_E_MEMORY);
		    }
		}
		else if( strcmp( data_ptr[j+index.name], "t_appl" ) == 0 )
		{
                    strcpy (index_num, "");
		    _NFIdebug(( fname, "Name <%s>\n", data_ptr[j+index.name]));
                    status = NFAget_value_list_index (data_ptr[j+index.list],
                            loc_value, data_ptr[j+index.name],
                            data_ptr[j+index.syn], index_num);

/* KT - 3/8/93 - NFI_E_FAILURE is returned if no row is selected. This is OK.
                    if (status != NFI_S_SUCCESS)
                    {
                        MEMclose (&loc_attr);
                        MEMclose (&loc_value);
                        MEMclose (&loc_data);
		        MEMclose (&application);
                        return (status);
                    }
*/
                    _NFIdebug(( fname, "Chosen Value for t_appl <%s>\n",
			    index_num));
                    strcpy (t_appl, index_num);
		    sprintf(str, "t_appl\1%s\1", index_num) ;
  		    status = MEMwrite (application, str);
		    if (status != MEM_S_SUCCESS)
		    {
		        ERRload_struct( NFI, NFI_E_MEMORY, "%s%s", 
				"NFAcreate_catalog","MEMwrite" );
			MEMclose (&application);
		        MEMclose (&loc_attr);
		        MEMclose (&loc_data);
		        MEMclose (&loc_value);
		        return (NFI_E_MEMORY);
		    }
		}
	    }
	}
    }

    SCdisplay_msg ("Working..");    
    status = NFMRquery_catalog_template_n (&attr_list, &data_list,
	         			      &value_list, 
					      application);

    if (status != NFM_S_SUCCESS)
        {
        MEMclose (&loc_attr);
        MEMclose (&loc_data);
        MEMclose (&loc_value);
        MEMclose (&attr_list);
        MEMclose (&data_list);
        MEMclose (&value_list);
        return (status);
        }

    MEMclose (&application);

    status = MEMbuild_array (loc_attr);

    data_ptr = (char **) loc_attr->data_ptr;

    status = MEMbuild_array (loc_value);

    NFMRfill_index (loc_attr, &index);

    count = 0;
    for (i=0; i<loc_attr->rows*loc_attr->columns; i+=loc_attr->columns)
        {
        if ((strcmp (data_ptr[i+index.r], "Y") == 0) ||
            (strcmp (data_ptr[i+index.w], "Y") == 0))
            ++count;
        }

    _NFIdebug ((fname, "Displayable fields : <%d>\n", count));

    pos = 6;
    data.num_of_rows = count + 2;
    data.num_of_cols = 3;
    tot_data = data.num_of_cols * data.num_of_rows;
    _NFIdebug ((fname, "tot data is %d\n", tot_data));
    data.freeze_rows_count = 0;
    data.select_set_expected = FALSE;
    data.col_width = (int *) malloc (data.num_of_cols * sizeof (int));
    memset (data.col_width, 0, (data.num_of_cols * sizeof (int)));

    status = NFAfind_len (data_ptr, column_ptr, index, 
                          (loc_attr->rows*loc_attr->columns),
                          loc_attr->columns, &max_attr_len, &max_syn_len,
                          &max_dtype_len);
    _NFIdebug ((fname, "max %d\n", max_syn_len));
    if( max_syn_len > 23 )
    {
	_NFIdebug(( fname, "%s\n", "Changing max_syn_len to 23" ));
	max_syn_len = 23;
    }
    if( max_dtype_len > 35 )
    {
	_NFIdebug(( fname, "%s\n", "Changing max_dtype_len to 35" ));
	max_dtype_len = 35;
    }

    data.col_width[0] = max_syn_len + 2;
    data.col_width[1] = 10;
    data.col_width[2] = max_dtype_len;
    data.new_rows_expected = FALSE;
    strcpy (data.title, "Enter Catalog Information");

    data.selectable = (int *) malloc (tot_data * sizeof (int));
    memset (data.selectable, 0, (tot_data * sizeof (int)));

    for (i=pos+2; i<tot_data; i+=data.num_of_cols)
        data.selectable[i] = 1;

    data.hidden = (int *) malloc (tot_data * sizeof (int));
    memset (data.hidden, 0, (tot_data * sizeof (int)));

    /* allocate and initialize space to store pdata */

    data.data = (char **) malloc (tot_data * sizeof (char *));
    memset (data.data, NULL, (tot_data * sizeof (char *)));
    NFAput_string (&data.data[0], "Attribute");
    NFAput_string (&data.data[1], "Data Type");

    for (i=pos, j=0; i<tot_data; j+=loc_attr->columns)
        {
        if ((strcmp (data_ptr[j+index.r], "Y") == 0) ||
            (strcmp (data_ptr[j+index.w], "Y") == 0))
            {
	      _NFIdebug ((fname, "%s :\n", data_ptr[j+index.syn]));
	      _NFIdebug ((fname, "%s\n", data_ptr[j+index.dt]));
            NFAput_string (&data.data[i], data_ptr[j+index.syn]);
            NFAput_string (&data.data[i+1], data_ptr[j+index.dt]);
            i+=data.num_of_cols;
            }
        }

    /* if attribute is writable but not readable, hide it */
    for (j=pos; j<tot_data; j+=data.num_of_cols)
        {
        for (i=0; i<loc_attr->rows*loc_attr->columns; i+=loc_attr->columns)
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

    /* if attribute is readable but not writeable, suppress input */
    for (j=pos; j<tot_data; j+=data.num_of_cols)
        {
        for (i=0; i<loc_attr->rows*loc_attr->columns; i+=loc_attr->columns)
            {
            if (((strcmp (data_ptr[i+index.syn], data.data[j]) == 0) ||
                 (strcmp (data_ptr[i+index.nfm], data.data[j]) == 0)) &&
                ((strcmp (data_ptr[i+index.r], "Y") == 0) &&
                 (strcmp (data_ptr[i+index.w], "N") == 0)))
                {
                data.selectable[j+2] = 0;
                break;
                }
            }
      }

    status = MEMbuild_array (loc_data);

    n_data_ptr = (char **) loc_data->data_ptr;

    for (i=pos+2, j=0, k=0; i<tot_data; j+=loc_attr->columns, ++k)
        {
        if ((strcmp (data_ptr[j+index.r], "Y") == 0) ||
            (strcmp (data_ptr[j+index.w], "Y") == 0))
            {
            NFAput_string (&data.data[i], n_data_ptr[k]);

            /* KT - 3/4/93 - Don't redisplay the list for t_basic and t_appl */

            if ((strcmp (data_ptr[j+index.list], "0") != 0) &&
                ((strcmp (data_ptr[j+index.name], "t_basic") != 0) &&
                 (strcmp (data_ptr[j+index.name], "t_appl") != 0)))
                {
                /* if there is a value list, display the list and let them
                   choose the value */
		  _NFIdebug ((fname, "%s \n",
			     data_ptr[j+index.name]));
		  _NFIdebug ((fname, "%s\n",
			     data_ptr[j+index.list]));
		  _NFIdebug ((fname, "%d\n", index.list));
		  _NFIdebug ((fname, "j %d\n", j));
                status = NFAget_value_list_index (data_ptr[j+index.list],
                            loc_value, data_ptr[j+index.name],
                            data_ptr[j+index.syn], index_num);
                if (status != NFI_S_SUCCESS)
                    {
                    MEMclose (&attr_list);
                    MEMclose (&value_list);
                    MEMclose (&data_list);
                    return (status);
                    }
                NFAput_string (&data.data[i], index_num);
                }

            i+=data.num_of_cols;
	  }
      }

/* KT - 3/4/93 - Adding this to display the chosen t_basic and t_appl to the 
                 form. Default values are "NFM".
*/

    for (i=pos+2, j=0, k=0; i<tot_data; j+=loc_attr->columns, ++k)
        {
        if ((strcmp (data_ptr[j+index.r], "Y") == 0) ||
            (strcmp (data_ptr[j+index.w], "Y") == 0))
            {
                 if (strcmp (data_ptr[j+index.name], "t_basic") == 0)
                     NFAput_string (&data.data[i], t_basic);

            else if (strcmp (data_ptr[j+index.name], "t_appl") == 0)
                     NFAput_string (&data.data[i], t_appl);

            i+=data.num_of_cols;
            }
      }


    /* process column form until all has been entered */
    do
        {
        FORM_FILLED = TRUE;
        status = SCprocess_column_form (&data, NFMprint_file );
        SCclear_msg ();

        _NFIdebug ((fname, "SCprocess_column_form -> %d\n", data.sts));

        if (data.sts != FORM_CANCELED)
            {
            status = NFAput_and_validate_data (data.data, pos+2, tot_data,
                                               data.num_of_cols);

            /* if attribute is required ("n_null" == "N"),
               user must keyin a value */

            status = NFAvalidate_nulls (loc_attr, index, data, pos,
                                        &FORM_FILLED);
            }
        }
    while ((FORM_FILLED == FALSE) && (data.sts != FORM_CANCELED));

    if (data.sts == FORM_CANCELED)
        {
        NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
        free (data.data);
        MEMclose (&loc_attr);
        MEMclose (&loc_data);
        MEMclose (&loc_value);
        MEMclose (&attr_list);
        MEMclose (&data_list);
        MEMclose (&value_list);
        ERRload_struct( NFI, NFI_W_COMMAND_CANCELLED, NULL, NULL );
        return (NFI_W_COMMAND_CANCELLED);
        }

    for (i=pos+2, j=0, k=0; k<loc_data->columns; j+=loc_attr->columns, ++k)
        {
        if (strcmp (data_ptr[j+index.w], "Y") == 0)
            {
            /* save new catalog name */
            if (strcmp (data_ptr[j+index.name], "n_catalogname") == 0)
                {
                lowcase (data.data[i]);
                strcpy (catalog_name, data.data[i]);
                }

            status = MEMwrite_data (loc_data, data.data[i], 1, k+1);
            if (status != MEM_S_SUCCESS)
                {
                MEMclose (&loc_attr);
                MEMclose (&loc_data);
                MEMclose (&loc_value);
                MEMclose (&attr_list);
                MEMclose (&data_list);
                MEMclose (&value_list);
                NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
                free (data.data);
                ERRload_struct( NFI, NFI_E_MEM, "%s%s", "NFMcreate_catalog",
			        "MEMwrite_data");
                return (status);
                }
            i+=data.num_of_cols;
	  }
	else if (strcmp (data_ptr[j+index.r], "Y") == 0)
	  {
	    i+=data.num_of_cols ;
	  }
        }
    
        _NFIdebug((fname, " catalog name is <%s>\n", catalog_name));
        if (strcmp(t_basic, "REDLINE")==0)
        {
           if ((strcmp (&(catalog_name[strlen (catalog_name) -3]), "_rl"))!=0)
             {
                  _NFIdebug((fname, "catalog name doesn't end in _rl\n"));
                  status = NFI_W_REDLINE_CATNAME;
                  ERRload_struct (NFI,status, NULL);
                  return(status);
             }
        }                
    SCdisplay_msg ("Working..");    

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

/*********************************************************************
  Enter Attribute Information - Attribute Name, Data Type, and Synonym
**********************************************************************/

    status = MEMbuild_array (attr_list);

    data_ptr = (char **) attr_list->data_ptr;
    column_ptr = (char **) attr_list->column_ptr;
    
    NFMRfill_index (attr_list, &index);

    _NFIdebug ((fname, "Displayable fields : <%d>\n", attr_list->rows));

    pos = 6;
    data.num_of_rows = attr_list->rows + 2;
    old_row_count = data.num_of_rows;
    data.num_of_cols = 3;
    tot_data = data.num_of_cols * data.num_of_rows;
    data.freeze_rows_count = 2;
    data.select_set_expected = FALSE;
    data.new_rows_expected = TRUE;
    data.col_width = (int *) malloc (data.num_of_cols * sizeof (int));
    memset (data.col_width, 0, (data.num_of_cols * sizeof (int)));
    
    status = NFAfind_len (data_ptr, column_ptr, index, 
                          (attr_list->rows*attr_list->columns),
                          attr_list->columns, &max_attr_len, &max_syn_len,
                          &max_dtype_len);
    
    if( max_syn_len > 23 )
    {
        _NFIdebug(( fname, "%s\n", "Changing max_syn_len to 23" ));
        max_syn_len = 23;
    }
    if( max_dtype_len > 35 )
    {
	_NFIdebug(( fname, "%s\n", "Changing max_dtype_len to 35" ));
	max_dtype_len = 35;
    }

    data.col_width[0] = max_syn_len + 2;
    data.col_width[1] = 10;
    data.col_width[2] = max_dtype_len;
    strcpy (data.title, "Enter Attribute Information");

    data.selectable = (int *) malloc (tot_data * sizeof (int));
    memset (data.selectable, 0, (tot_data * sizeof (int)));

    for (i=pos; i<tot_data; i+=data.num_of_cols)
        {
        data.selectable[i+1] = 1;
        data.selectable[i+2] = 1;
        }

    data.hidden = (int *) malloc (tot_data * sizeof (int));
    memset (data.hidden, 0, (tot_data * sizeof (int)));

    /* allocate and initialize space to store data */

    data.data = (char **) malloc (tot_data * sizeof (char *));
    memset (data.data, NULL, (tot_data * sizeof (char *)));

    NFAput_string (&data.data[0], "Attribute");
    NFAput_string (&data.data[1], "Data Type");
    NFAput_string (&data.data[2], "Synonym");

    for (i=pos, j=0; i<tot_data; j+=attr_list->columns, i+=data.num_of_cols)
        {
        NFAput_string (&data.data[i], data_ptr[j+index.name]);
        NFAput_string (&data.data[i+1], data_ptr[j+index.dt]);
        NFAput_string (&data.data[i+2], data_ptr[j+index.syn]);
        }
	
    /* process column form until all info has been entered */
    do
        {
        FORM_FILLED = TRUE;
        status = SCprocess_column_form (&data, NFMprint_file);
        SCclear_msg ();

        _NFIdebug ((fname, "SCprocess_column_form -> %d\n", data.sts));

        if (data.sts != FORM_CANCELED)
            {
            /* make string valid length and strip trailing blanks */
            for (i=pos;
                 i<data.num_of_cols*data.num_of_rows;
                 i+=data.num_of_cols)
                {
                /* attribute name */
                status = NFAvalidate_string ("char(20)", data.data[i]);

                /* data type */
                status = NFAvalidate_string ("char(15)", data.data[i+1]);

                /* syn_name */
                status = NFAvalidate_string ("char(40)", data.data[i+2]);

                status = NFAvalidate_data_type (data.data[i+1]);
                if (status != NFI_S_SUCCESS)
                    {
                    FORM_FILLED = FALSE;
                    sprintf (msg, 
                             "NFM:  Invalid data type for attribute \"%s\"",
                             data.data[i]);
                    SCdisplay_msg (msg);
                    break;
                    }
		/* check for a attribute ending with 'date' and force it
		 * to char(10)
		 */
/******* not necessary 
		if( (NFMRsearch_for_date( data.data[i] )) == 1 )
		{
		    status = NFAget_date_len( data.data[i+1], &len );
                    if ((len < 10) && (NFMRglobal.override == 0))
                    {
                        FORM_FILLED = FALSE;
                        sprintf (msg, 
                             "NFM:  Date attribute \"%s\" must be char(10) or greater", data.data[i]);
                        SCdisplay_msg (msg);
                        break;
                    }
		}
****************************/
                } /* end for */
            }
        }
    while ((FORM_FILLED == FALSE) && (data.sts != FORM_CANCELED));

    if (data.sts == FORM_CANCELED)
        {
        NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
        free (data.data);
        MEMclose (&loc_attr);
        MEMclose (&loc_data);
        MEMclose (&loc_value);
        MEMclose (&attr_list);
        MEMclose (&data_list);
        MEMclose (&value_list);
        ERRload_struct( NFI, NFI_W_COMMAND_CANCELLED, NULL, NULL );
        return (NFI_W_COMMAND_CANCELLED);
        }

    status = MEMbuild_array (data_list);

    n_data_ptr = (char **) data_list->data_ptr;

    /* fill buffer with old/new attributes, data types, synonyms */

    for (i=pos, j=0; j<attr_list->rows; ++j, i+=data.num_of_cols)
        {
        status = MEMwrite_data (attr_list, data.data[i], j+1, index.name+1);
        if (status != MEM_S_SUCCESS)
            {
            MEMclose (&loc_attr);
            MEMclose (&loc_data);
            MEMclose (&loc_value);
            MEMclose (&attr_list);
            MEMclose (&data_list);
            MEMclose (&value_list);
            NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
            free (data.data);
            ERRload_struct( NFI, NFI_E_MEM, "%s%s", "NFMcreate_catalog",
			    "MEMwrite_data");
            return (status);
            }

        status = MEMwrite_data (attr_list, data.data[i+1], j+1, index.dt+1);
        if (status != MEM_S_SUCCESS)
            {
            MEMclose (&loc_attr);
            MEMclose (&loc_data);
            MEMclose (&loc_value);
            MEMclose (&attr_list);
            MEMclose (&data_list);
            MEMclose (&value_list);
            NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
            free (data.data);
            ERRload_struct( NFI, NFI_E_MEM, "%s%s", "NFMcreate_catalog",
			    "MEMwrite_data");
            return (status);
            }

        status = MEMwrite_data (attr_list, data.data[i+2], j+1, index.syn+1);
        if (status != MEM_S_SUCCESS)
            {
            MEMclose (&loc_attr);
            MEMclose (&loc_data);
            MEMclose (&loc_value);
            MEMclose (&attr_list);
            MEMclose (&data_list);
            MEMclose (&value_list);
            NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
            free (data.data);
            ERRload_struct( NFI, NFI_E_MEM, "%s%s", "NFMcreate_catalog",
			    "MEMwrite_data");
            return (status);
            }

        }  /* end for filling new attribute, data type synonym values */

    _NFAfind_higest_seqno (attr_list, &next_highest);

    if (old_row_count < data.num_of_rows)
        {
        /* user attributes have been added */
        /* add the new rows to the attribute buffer */
        
        for (i=old_row_count; i<data.num_of_rows; ++i)
            {
            str[0] = 0;
            _NFIdebug((fname, "what is old row <%d>\n", old_row_count));

            k = i * data.num_of_cols;
            for (j=0; j<attr_list->columns; ++j)
                {
                     if (strcmp (column_ptr[j], "n_name") == 0)
                         strcat (str, data.data[k]);
                else if (strcmp (column_ptr[j], "n_datatype") == 0)
                         strcat (str, data.data[k+1]);
                else if (strcmp (column_ptr[j], "n_synonym") == 0)
		{
		     _NFIdebug ((fname, "FMcreate_catalog : Syn_len <%d>\n",
			strlen( data.data[k+2] ) ));
		     if( strlen( data.data[k+2] ) > 0 )
                         strcat (str, data.data[k+2]);
		     else
			 strcat (str, data.data[k] );
		}
                else if (strcmp (column_ptr[j], "n_nfmname") == 0)
                         strcat (str, data.data[k]);
                else if (strcmp (column_ptr[j], "n_opentonfm") == 0)
                         strcat (str, "Y");
                else if (strcmp (column_ptr[j], "n_application") == 0)
                         strcat (str, "USR");
                else if (strcmp (column_ptr[j], "n_read") == 0)
                         strcat (str, "Y");
                else if (strcmp (column_ptr[j], "n_write") == 0)
                         strcat (str, "Y");
                else if (strcmp (column_ptr[j], "n_update") == 0)
                         strcat (str, "Y");
                else if (strcmp (column_ptr[j], "n_delete") == 0)
                         strcat (str, "Y");
                else if (strcmp (column_ptr[j], "n_null") == 0)
                         strcat (str, "Y");
                else if (strcmp (column_ptr[j], "n_keyin") == 0)
                         strcat (str, "0");
                else if (strcmp (column_ptr[j], "n_checkin") == 0)
                         strcat (str, "N");
                else if (strcmp (column_ptr[j], "n_checkout") == 0)
                         strcat (str, "N");
                else if (strcmp (column_ptr[j], "n_seqno") == 0)
                         {
                           _NFIdebug (( fname, " column ptr <%d>\n",
                                    column_ptr[j]));

                         ++next_highest;
                         sprintf (seqno, "%d", next_highest);

                         _NFIdebug (( fname, "the value for i <%d>\n", i-2));
                         strcat (str, seqno);
                         _NFIdebug ((fname, " value for str <%s>\n", str));
                         }
                else if (strcmp (column_ptr[j], "n_listno") == 0)
                         strcat (str, "0");
                else
                         strcat (str, "");

                strcat (str, "\1");

                }  /* end for */

            _NFIdebug ((fname, "MEMwrite string -> %s\n", str));

            status = MEMwrite (attr_list, str);
            if (status != MEM_S_SUCCESS)
                {
                MEMclose (&loc_attr);
                MEMclose (&loc_data);
                MEMclose (&loc_value);
                MEMclose (&attr_list);
                MEMclose (&data_list);
                MEMclose (&value_list);
                NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
                free (data.data);
                ERRload_struct( NFI, NFI_E_MEM, "%s%s", "NFMcreate_catalog",
				"MEMwrite");
                return (status);
                }

            status = MEMbuild_array (attr_list);

            data_ptr = (char **) attr_list->data_ptr;
            column_ptr = (char **) attr_list->column_ptr;

            }  /* end for */

        /* build a new data buffer with all old attributes plus new ones */

        status = NFMRrebuild_data_buffer (attr_list, &data_list);
        if (status != NFM_S_SUCCESS)
            {
            MEMclose (&loc_attr);
            MEMclose (&loc_data);
            MEMclose (&loc_value);
            MEMclose (&attr_list);
            MEMclose (&data_list);
            MEMclose (&value_list);
            NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
            free (data.data);
            ERRload_struct( NFI, NFI_E_REBUILD_DATA_BUFFER, "%s",
			    "NFMcreate_catalog");
            return (status);
            }

        }  /* end if old_row_count < data.num_of_rows */

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    SCdisplay_msg ("Working..");    

/*********************************************************************
  Enter Attribute Information  - Read, Write, Update, Delete, Nulls
**********************************************************************/

    status = MEMbuild_array (attr_list);

    data_ptr = (char **) attr_list->data_ptr;
    column_ptr = (char **) attr_list->column_ptr;
    
    NFMRfill_index (attr_list, &index);

    _NFIdebug ((fname, "Displayable fields : <%d>\n", attr_list->rows));

    pos = 12;
    data.num_of_rows = attr_list->rows + 2;
    data.num_of_cols = 6;
    tot_data = data.num_of_cols * data.num_of_rows;
    data.freeze_rows_count = 2;
    data.select_set_expected = FALSE;
    data.new_rows_expected = FALSE;
    data.col_width = (int *) malloc (data.num_of_cols * sizeof (int));
    memset (data.col_width, 0, (data.num_of_cols * sizeof (int)));
    
    data.col_width[0] = 20;
    data.col_width[1] = 7;
    data.col_width[2] = 7;
    data.col_width[3] = 7;
    data.col_width[4] = 7;
    data.col_width[5] = 7;
    strcpy (data.title, "Enter Attribute Information");

    data.selectable = (int *) malloc (tot_data * sizeof (int));
    memset (data.selectable, 0, (tot_data * sizeof (int)));

    for (i=pos+1; i<tot_data; i+=data.num_of_cols)
        {
        data.selectable[i] = 1;
/* Making all the fields selectable unconditionally - IGI 26 Dec 94 */
        data.selectable[i+1] = 1;
        data.selectable[i+2] = 1;
        data.selectable[i+3] = 1;
        data.selectable[i+4] = 1;
/*
        if (i >= (old_row_count*data.num_of_cols))
            {
            data.selectable[i+1] = 1;
            data.selectable[i+2] = 1;
            data.selectable[i+3] = 1;
            data.selectable[i+4] = 1;
            }
*/
        }

    data.hidden = (int *) malloc (tot_data * sizeof (int));
    memset (data.hidden, 0, (tot_data * sizeof (int)));

    /* allocate and initialize space to store data */

    data.data = (char **) malloc (tot_data * sizeof (char *));
    memset (data.data, NULL, (tot_data * sizeof (char *)));

    NFAput_string (&data.data[0], "Attribute");
    NFAput_string (&data.data[1], "Read?");
    NFAput_string (&data.data[2], "Write?");
    NFAput_string (&data.data[3], "Update?");
    NFAput_string (&data.data[4], "Delete?");
    NFAput_string (&data.data[5], "Nulls?");

    for (i=pos, j=0; i<tot_data; j+=attr_list->columns, i+=data.num_of_cols)
        {
        NFAput_string (&data.data[i], data_ptr[j+index.name]);
        NFAput_string (&data.data[i+1], data_ptr[j+index.r]);
        NFAput_string (&data.data[i+2], data_ptr[j+index.w]);
        NFAput_string (&data.data[i+3], data_ptr[j+index.u]);
        NFAput_string (&data.data[i+4], data_ptr[j+index.d]);
        NFAput_string (&data.data[i+5], data_ptr[j+index.nul]);
        }

    /* process column form until all info has been entered */
    do
        {
        FORM_FILLED = TRUE;
        status = SCprocess_column_form (&data, NFMprint_file );
        SCclear_msg ();

        _NFIdebug ((fname, "SCprocess_column_form -> %d\n", data.sts));

        if (data.sts != FORM_CANCELED)
            {
            /* make string valid length and strip trailing blanks */
            for (i=pos;
                 i<data.num_of_cols*data.num_of_rows;
                 i+=data.num_of_cols)
                {
                /* read */
                status = NFAvalidate_Y_or_N (data.data[i+1]);
                if (status != NFI_S_SUCCESS)
                    {
                    FORM_FILLED = FALSE;
                    sprintf (msg, "NFM:  Invalid 'READ' for attribute \"%s\"",
                             data.data[i]);
                    SCdisplay_msg (msg);
                    break;
                    }

                /* write */
                status = NFAvalidate_Y_or_N (data.data[i+2]);
                if (status != NFI_S_SUCCESS)
                    {
                    FORM_FILLED = FALSE;
                    sprintf (msg, "NFM:  Invalid 'WRITE' for attribute \"%s\"",
                             data.data[i]);
                    SCdisplay_msg (msg);
                    break;
                    }

                /* update */
                status = NFAvalidate_Y_or_N (data.data[i+3]);
                if (status != NFI_S_SUCCESS)
                    {
                    FORM_FILLED = FALSE;
                    sprintf (msg, "NFM:  Invalid 'UPDATE' for attribute \"%s\"",
                             data.data[i]);
                    SCdisplay_msg (msg);
                    break;
                    }

                /* delete */
                status = NFAvalidate_Y_or_N (data.data[i+4]);
                if (status != NFI_S_SUCCESS)
                    {
                    FORM_FILLED = FALSE;
                    sprintf (msg, "NFM:  Invalid 'DELETE' for attribute \"%s\"",
                             data.data[i]);
                    SCdisplay_msg (msg);
                    break;
                    }

                /* nulls */
                status = NFAvalidate_Y_or_N (data.data[i+5]);
                if (status != NFI_S_SUCCESS)
                    {
                    FORM_FILLED = FALSE;
                    sprintf (msg, "NFM:  Invalid 'NULLS' for attribute \"%s\"",
                             data.data[i]);
                    SCdisplay_msg (msg);
                    break;
                    }

                } /* end for */
            }
        }
    while ((FORM_FILLED == FALSE) && (data.sts != FORM_CANCELED));

    if (data.sts == FORM_CANCELED)
        {
        NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
        free (data.data);
        MEMclose (&loc_attr);
        MEMclose (&loc_data);
        MEMclose (&loc_value);
        MEMclose (&attr_list);
        MEMclose (&data_list);
        MEMclose (&value_list);
        ERRload_struct( NFI, NFI_W_COMMAND_CANCELLED, NULL, NULL );
        return (NFI_W_COMMAND_CANCELLED);
        }

    /* fill buffer with old/new data for read,write,update,nulls... */

    for (i=pos, j=0; j<attr_list->rows; ++j, i+=data.num_of_cols)
        {
        status = MEMwrite_data (attr_list, data.data[i+1], j+1, index.r+1);
        if (status != MEM_S_SUCCESS)
            {
            MEMclose (&loc_attr);
            MEMclose (&loc_data);
            MEMclose (&loc_value);
            MEMclose (&attr_list);
            MEMclose (&data_list);
            MEMclose (&value_list);
            NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
            free (data.data);
            ERRload_struct( NFI, NFI_E_MEM, "%s%s", "NFMcreate_catalog",
			    "MEMwrite_data");
            return (status);
            }

        /* only write the write, update, delete, null fields if 'USR' attr */

        if (strcmp (data_ptr[(j*attr_list->columns)+index.app], "USR") == 0)
            {
            status = MEMwrite_data (attr_list, data.data[i+2], j+1, index.w+1);
            if (status != MEM_S_SUCCESS)
                {
                MEMclose (&loc_attr);
                MEMclose (&loc_data);
                MEMclose (&loc_value);
                MEMclose (&attr_list);
                MEMclose (&data_list);
                MEMclose (&value_list);
                NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
                free (data.data);
                ERRload_struct( NFI, NFI_E_MEM, "%s%s","NFMcreate_catalog",
				"MEMwrite_data");
                return (status);
                }

            status = MEMwrite_data (attr_list, data.data[i+3], j+1, index.u+1);
            if (status != MEM_S_SUCCESS)
                {
                MEMclose (&loc_attr);
                MEMclose (&loc_data);
                MEMclose (&loc_value);
                MEMclose (&attr_list);
                MEMclose (&data_list);
                MEMclose (&value_list);
                NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
                free (data.data);
                ERRload_struct( NFI, NFI_E_MEM, "%s%s", "NFMcreate_catalog",
				"MEMwrite_data");
                return (status);
                }

            status = MEMwrite_data (attr_list, data.data[i+4], j+1, index.d+1);
            if (status != MEM_S_SUCCESS)
                {
                MEMclose (&loc_attr);
                MEMclose (&loc_data);
                MEMclose (&loc_value);
                MEMclose (&attr_list);
                MEMclose (&data_list);
                MEMclose (&value_list);
                NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
                free (data.data);
                ERRload_struct( NFI, NFI_E_MEM, "%s%s", "NFMcreate_catalog",
				"MEMwrite_data");
                return (status);
                }

            status = MEMwrite_data (attr_list, data.data[i+5], j+1, index.nul+1);
            if (status != MEM_S_SUCCESS)
                {
                MEMclose (&loc_attr);
                MEMclose (&loc_data);
                MEMclose (&loc_value);
                MEMclose (&attr_list);
                MEMclose (&data_list);
                MEMclose (&value_list);
                NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
                free (data.data);
                ERRload_struct( NFI, NFI_E_MEM, "%s%s", "NFMcreate_catalog",
				"MEMwrite_data");
                return (status);
                }

            }  /* end if j >= old_row_count */

        }  /* end for filling new attribute, data type synonym values */

    /*  Search for tic marks in the data */

    status = NFMRtic_it( loc_data );
    if( status != NFM_S_SUCCESS )
    {
	_NFIdebug ((fname, "Bad tic mark replacement : <0x%.8x>\n", status));
        MEMclose (&loc_attr);
        MEMclose (&loc_data);
        MEMclose (&loc_value);
        MEMclose (&attr_list);
        MEMclose (&data_list);
        MEMclose (&value_list);
        NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
        free (data.data);
        return (status);
    }

    status = NFMRtic_it( data_list );
    if( status != NFM_S_SUCCESS )
    {
	_NFIdebug ((fname, "Bad tic mark replacement : <0x%.8x>\n", status));
        MEMclose (&loc_attr);
        MEMclose (&loc_data);
        MEMclose (&loc_value);
        MEMclose (&attr_list);
        MEMclose (&data_list);
        MEMclose (&value_list);
        NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
        free (data.data);
        return (status);
    }

    status = NFMRtic_it( attr_list );
    if( status != NFM_S_SUCCESS )
    {
	_NFIdebug ((fname, "Bad tic mark replacement : <0x%.8x>\n", status));
        MEMclose (&loc_attr);
        MEMclose (&loc_data);
        MEMclose (&loc_value);
        MEMclose (&attr_list);
        MEMclose (&data_list);
        MEMclose (&value_list);
        NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
        free (data.data);
        return (status);
    }

    SCdisplay_msg ("Working..");    

    status = NFMRcreate_catalog (NFMuser_id, loc_attr, loc_data,
                                 attr_list, data_list, value_list);

    _NFIdebug ((fname, "NFMcreate_catalog -> <0x%.8x>\n", status));

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    MEMclose (&loc_attr);
    MEMclose (&loc_data);
    MEMclose (&loc_value);
    MEMclose (&attr_list);
    MEMclose (&data_list);
    MEMclose (&value_list);
    
    if (status != NFM_S_SUCCESS)
        return (status);

    strcpy (NFMcatalog, catalog_name);
    strcpy (NFMitem, "");
    strcpy (NFMrev, "");
    strcpy (NFMset, "" );
    strcpy (NFMset_rev, "" );

    NFAmake_msg (msg);
    _NFIdebug ((fname, "%s\n", msg));
    SCdisplay_ref (msg);
        
    return (NFI_S_SUCCESS);
}


long delete_catalog ()

{
long    status;
int     i, j;
char    catalog[30];
char    title[80];
NFMlist list_struct;
struct  SCfree_data_st data;

static  char *fname = "FMdelete_catalog";

    SCdisplay_msg ("Working..");

    if ((status = (long) UMSGetByNum
        (title, NFT_P_LIST_CATALOGS, NULL)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        strcpy (title, "List of I/NFM Catalogs" );
      }

    SCdisplay_msg ("Working..");

    NFAfill_list_struct (&list_struct, DSP_CATALOGS, SELECT_SET_SINGLE_ROW,
                NFM_SHORT_DISPLAY, -1, "nfmcatalogs.n_catalogname NOT LIKE '%_rl' ", "", "", "", "", "", "", title);

    status = NFAdisplay_elements (&data, list_struct);

    NFAfree_list_struct (&list_struct);

    if (status != NFI_S_SUCCESS)
        return (status);

    for (i=0; i<data.num_of_rows; ++i)
        {
        j = i * data.num_of_cols;
        if (data.select_set[i] == 1)
            {
            strcpy (catalog, data.data[j+1]);
            break;
            }
        }

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    SCdisplay_msg ("Working..");    

#ifdef COMBINED_CLIENT_SERVER
    {
    long return_value;
    status = NFMdelete_catalog (NFMuser_id, catalog, &return_value);
    }
#else
    status = NFMRdelete_catalog (NFMuser_id, catalog);
#endif

    _NFIdebug ((fname, "NFMdelete_catalog -> <0x%.8x>\n", status));

    if (status != NFM_S_SUCCESS)
        return (status);

    if( strcmp( catalog, NFMcatalog ) == 0 )
    {
        strcpy (NFMcatalog, "");
        strcpy (NFMitem, "");
        strcpy (NFMrev, "");
    }

    NFAmake_msg (msg);
    _NFIdebug ((fname, "%s\n", msg));
    SCdisplay_ref (msg);
        
    return (NFI_S_SUCCESS);
}




