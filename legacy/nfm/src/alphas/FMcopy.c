#include "machine.h"
#include "NFMdef.h"
#include "SCstruct.h"
#include "SCdef.h"
#include "NFMRextern.h"

/* added external declaration for solar port on 28.12.93 ..KMM */

extern int SCprocess_column_form();

long copy_item ()

{
long   status;
int    i, j, k;
int    tot_data;
int    max_attr_len = 0;
int    max_syn_len = 0;
int    max_dtype_len = 0;
int    pos;
int    count = 0;
int    fcount = 0;
int    FORM_FILLED;
int    skip_file = 0;
int    rows    = 0;
int    columns = 0;
struct SCcolumn_data_st data;
struct SCcolumn_data_st fdata;
char   action[10];
char   item_name[50];
char   item_rev[50];
char   **n_data_ptr;
char   **data_ptr;
char   **column_ptr;
char   **format_ptr;
char   **column;
char   **f_data;
char   **format;
MEMptr attr_list = NULL;
MEMptr data_list = NULL;
MEMptr value_list = NULL;
MEMptr attr_f_list = NULL;
MEMptr data_f_list = NULL;
MEMptr data_f_list2 = NULL;
MEMptr value_f_list = NULL;
NDXptr index;
NDXptr f_index;
long   action_col, offset ;
char   *sql_str ;

static char *fname = "NFAcopy_item";

    _NFIdebug(( fname, " Enter...\n"));
    SCdisplay_msg ("Working..");    

    status = NFMRget_item_attr_for_copy (NFMcatalog, NFMitem, NFMrev,
                                 &attr_list, &data_list, &value_list,
                                 &attr_f_list, &data_f_list, &value_f_list);
    _NFIdebug(( fname, " At first NFMitem  and NFMrev are  <%s%s>\n",
                  NFMitem, NFMrev));
    if (status != NFM_S_SUCCESS)
        {
        MEMclose (&attr_list);
        MEMclose (&data_list);
        MEMclose (&value_list);
        MEMclose (&attr_f_list);
        MEMclose (&data_f_list);
        MEMclose (&value_f_list);
        return (status);
        }

    status = MEMbuild_array (attr_list);

    data_ptr = (char **) attr_list->data_ptr;
    column_ptr = (char **) attr_list->column_ptr;

    NFMRfill_index (attr_list, &index);

    status = MEMbuild_array (data_list);

    n_data_ptr = (char **) data_list->data_ptr;

    count = 0;

    for (i=0; i<attr_list->rows*attr_list->columns; i+=attr_list->columns)
        {
        if (strcmp (data_ptr[i+index.w], "Y") == 0)
            ++count;
        }

    _NFIdebug(( fname, "Displayable fields : <%d>\n", count));

    pos = 0;
    data.num_of_rows = count;
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
    strcpy (data.title, "Choose Item Information to Copy");

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
            /* In the following line 'strcmp' is replaced by 'strlen'.
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
                 (strcmp (data_ptr[i+index.w], "Y") == 0)))
                {
                data.hidden[j+2] = 1;
                break;
                }
            }
        }

    /* insert data */

    for (i=pos+2, j=0, k=0; i<tot_data; j+=attr_list->columns, ++k)
        {
        if (strcmp (data_ptr[j+index.w], "Y") == 0)
            {
            NFAput_string (&data.data[i], n_data_ptr[k]);
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
        MEMclose (&attr_list);
        MEMclose (&data_list);
        MEMclose (&value_list);
        MEMclose (&attr_f_list);
        MEMclose (&data_f_list);
        MEMclose (&value_f_list);
        return (NFI_W_COMMAND_CANCELLED);
        }

    for (i=pos; i<tot_data; i+=data.num_of_cols)
        {
        for (j=0, k=0; k<data_list->columns; j+=attr_list->columns, ++k)
            {
            if (((strcmp (data_ptr[j+index.syn], data.data[i]) == 0) ||
                 (strcmp (data_ptr[j+index.name], data.data[i]) == 0)) &&
                ((strcmp (data_ptr[j+index.w], "Y") == 0)))
                {
                status = MEMwrite_data (data_list, data.data[i+2], 1, k+1);
                if (status != MEM_S_SUCCESS)
                    {
	            MEMclose (&attr_list);
     	            MEMclose (&data_list);
 	            MEMclose (&value_list);
 	            MEMclose (&attr_f_list);
	            MEMclose (&data_f_list);
	            MEMclose (&value_f_list);
                    NFAfree_list(data.data,data.num_of_rows, data.num_of_cols);
                    free (data.data);
   		    ERRload_struct( NFI, NFI_E_MEMORY, "%s%s","NFAcopy_item",
				    "MEMwrite_data");
	            return (status);
                    }

                /* save the copy item name and revison for later */

                if (strcmp (data_ptr[j+index.nfm], "n_itemname") == 0)
                 {
                  strcpy (item_name, data.data[i+2]);
                 _NFIdebug((fname, "what is item name<%s>\n",item_name));
                 }
                if (strcmp (data_ptr[j+index.nfm], "n_itemrev")== 0)
                 {
                   strcpy(item_rev, data.data[i+2]);
                  _NFIdebug((fname, " the item rev is <%s>\n", item_rev));
                 }
                break;
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
        MEMclose (&attr_f_list);
        MEMclose (&data_f_list);
        MEMclose (&value_f_list);
        ERRload_struct( NFI, NFI_E_COMPLETE_ITEM_COPY, "%s%s",NFMitem,NFMrev);
        return( NFI_E_COMPLETE_ITEM_COPY );
    }

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

/*  Now do the file catalog buffers */
/*  If there are no files for this item, the data_f_list will have no
 *  rows.
 */
    status = MEMbuild_array (data_f_list);
    _NFIdebug(( fname, "No of rows <%d>\n", data_f_list->rows ));

    if( data_f_list->rows != 0 )
    {
        n_data_ptr = (char **) data_f_list->data_ptr;

        status = MEMbuild_array (attr_f_list);

        data_ptr = (char **) attr_f_list->data_ptr;
        column_ptr = (char **) attr_f_list->column_ptr;
        format_ptr = (char **) attr_f_list->format_ptr;

        NFMRfill_index (attr_f_list, &f_index);

        count = 0;

        for (i=0; i<attr_f_list->rows*attr_f_list->columns;
	     i+=attr_f_list->columns)
            {
            if (strcmp (data_ptr[i+f_index.w], "Y") == 0)
                ++count;
            }

        _NFIdebug(( fname, "Displayable fields : <%d>\n", count));

    pos = 0;
    fdata.num_of_rows = count;
    fdata.num_of_cols = 3;
    tot_data = fdata.num_of_cols * fdata.num_of_rows;
    fdata.freeze_rows_count = 0;
    fdata.select_set_expected = FALSE;
    fdata.col_width = (int *) malloc (fdata.num_of_cols * sizeof (int));
    memset (fdata.col_width, 0, (fdata.num_of_cols * sizeof (int)));
    
    status = NFAfind_len (data_ptr, column_ptr, f_index, 
                          (attr_f_list->rows*attr_f_list->columns),
                          attr_f_list->columns, &max_attr_len, &max_syn_len,
                          &max_dtype_len);
    
    if( max_syn_len > 23 )
        max_syn_len = 23;
    if( max_dtype_len > 35 )
        max_dtype_len = 35;

    fdata.col_width[0] = max_syn_len + 2;
    fdata.col_width[1] = 10;
    fdata.col_width[2] = max_dtype_len;
    fdata.new_rows_expected = FALSE;

    strcpy (fdata.title, "Enter Copy Information ( <PF3> to Skip this File )");

    fdata.selectable = (int *) malloc (tot_data * sizeof (int));
    memset (fdata.selectable, 0, (tot_data * sizeof (int)));

    for (i=pos+2; i<tot_data; i+=fdata.num_of_cols)
        fdata.selectable[i] = 1;

    fdata.hidden = (int *) malloc (tot_data * sizeof (int));
    memset (fdata.hidden, 0, (tot_data * sizeof (int)));

    /* allocate and initialize space to store data */

    fdata.data = (char **) malloc (tot_data * sizeof (char *));
    memset (fdata.data, NULL, (tot_data * sizeof (char *)));

    NFAput_string (&fdata.data[0], "Attribute");
    NFAput_string (&fdata.data[1], "Data Type");

    for (i=pos, j=0; i<tot_data; j+=attr_list->columns)
        {
        if (strcmp (data_ptr[j+f_index.w], "Y") == 0)
            {
	    if (strcmp (data_ptr[j+f_index.syn]) != 0)
                NFAput_string (&fdata.data[i], data_ptr[j+f_index.syn]);
	    else
		NFAput_string (&fdata.data[i], data_ptr[j+f_index.name]);

            NFAput_string (&fdata.data[i+1], data_ptr[j+index.dt]);
            i+=fdata.num_of_cols;
            }
        }

        /* insert data */

        _NFIdebug(( fname, "%s\n", "Insert data" ));

fcount =0;

for( columns=0,rows=0; columns<(data_f_list->rows*data_f_list->columns);
     columns+=data_f_list->columns, ++rows )
{
  skip_file = 0;

  for (i=pos, j=0, k=columns; i<tot_data; j+=attr_f_list->columns, ++k)
  {
    if (strcmp (data_ptr[j+f_index.w], "Y") == 0)
    {
        NFAput_string (&fdata.data[i+2], n_data_ptr[k]);
        i+=fdata.num_of_cols;
    }
  }

  do
  {
    FORM_FILLED = TRUE;
    status = SCprocess_column_form (&fdata, NFMprint_file);
    SCclear_msg ();

    _NFIdebug(( fname, "return from SCprocess_column_form -> %d\n",fdata.sts));
    if (fdata.sts != FORM_CANCELED)
       status = NFAvalidate_nulls (attr_f_list, f_index, fdata, pos,
                                        &FORM_FILLED);
/*  Validate the items having associated value lists here
    status = NFAvalidate_in_value_list( value_f_list, f_index, fdata,
					&FORM_FILLED );
*/
   }
  while ((FORM_FILLED == FALSE) && (fdata.sts != FORM_CANCELED));

 /* FORM_CANCELED means this file not added */
  strcpy( action, "ADD" );

  if (fdata.sts == FORM_CANCELED) 
  {
     _NFIdebug(( fname, "%s\n", "Skipping this file" ));
     skip_file = 1;
     strcpy( action, "" );
  }
  else fcount++;
   
    for (i=pos; i<tot_data; i+=fdata.num_of_cols)
    {
       for(j=0, k=0;k<data_f_list->columns;j+=attr_f_list->columns,++k)
       {
	 _NFIdebug(( fname, "index.name <%s>\n", data_ptr[j+f_index.name]));
         if (((strcmp (data_ptr[j+f_index.syn], fdata.data[i]) == 0) ||
              (strcmp (data_ptr[j+f_index.name], fdata.data[i]) == 0)) &&
              ((strcmp (data_ptr[j+f_index.w], "Y") == 0)))
         {
	   _NFIdebug(( fname, "row <%d>  column <%d>  data <%s>\n", 
			rows, k, fdata.data[i+2] ));
	   if( !skip_file )
           {
	    
             status=MEMwrite_data (data_f_list, fdata.data[i+2], rows+1, k+1);
             if (status != MEM_S_SUCCESS)
             {
               MEMclose (&attr_list);
               MEMclose (&data_list);
               MEMclose (&value_list);
               MEMclose (&attr_f_list);
               MEMclose (&data_f_list);
               MEMclose (&value_f_list);
               NFAfree_list(fdata.data, fdata.num_of_rows, fdata.num_of_cols);
               free (fdata.data);
               ERRload_struct( NFI, NFI_E_MEMORY, "%s%s",
			     "NFAcopy_item", "MEMwrite_data"); 
               return (status);
             }
	   } /* end if( !skip_file ) */
         }
         else if (strcmp (data_ptr[j+f_index.name], "n_action" ) == 0)
         {
             status = MEMwrite_data (data_f_list, action, rows+1, k+1);
             if (status != MEM_S_SUCCESS)
             {
                 MEMclose (&attr_list);
                 MEMclose (&data_list);
                 MEMclose (&value_list);
                 MEMclose (&attr_f_list);
                 MEMclose (&data_f_list);
                 MEMclose (&value_f_list);
                 NFAfree_list(fdata.data,fdata.num_of_rows, fdata.num_of_cols);
                 free (fdata.data);
                 ERRload_struct( NFI, NFI_E_MEMORY, "%s%s",
          			"NFAcopy_item", "MEMwrite_data");
                 return (status);
             }
	     break;
          }
       }
     }
} /* end columns loop -- going through ALL files for this item */
   
    status = NFMRtic_it( data_f_list );
    if( status != NFM_S_SUCCESS )
    {
        NFAfree_list (fdata.data, fdata.num_of_rows, fdata.num_of_cols);
        free (fdata.data);
        MEMclose (&attr_list);
        MEMclose (&data_list);
        MEMclose (&value_list);
        MEMclose (&attr_f_list);
        MEMclose (&data_f_list);
        MEMclose (&value_f_list);
        ERRload_struct( NFI, NFI_E_COMPLETE_ITEM_COPY, "%s%s",
		    NFMitem, NFMrev);
        return( NFI_E_COMPLETE_ITEM_COPY );
    }

    NFAfree_list (fdata.data, fdata.num_of_rows, fdata.num_of_cols);
    free (fdata.data);

} /* end no_rows in data_list loop */

 f_data = (char **) data_f_list->data_ptr;
 column =( char **) data_f_list->column_ptr;
 format = (char **) data_f_list->format_ptr;

  if((status=MEMopen(&data_f_list2, 4*MEM_SIZE)) !=MEM_S_SUCCESS )
    {
       _NFIdebug((fname, "MEMopen failed for data_f_list2 status <0x%.8x>\n", status));
       ERRload_struct(MEM, status, "", NULL);
       return(status);
     }

/* write the format */
    action_col = -1;
    for(i=0 ; i < data_f_list-> columns; i++)
     {
  _NFIdebug ((fname, "column is %s\n", column[i])) ;
       if (strcmp (column[i], "n_action") == 0)
       {
	 action_col = i ;
       }
       if((status = MEMwrite_format(data_f_list2,column[i],
            format[i])) != MEM_S_SUCCESS)
        {
           _NFIdebug((fname, "MEMwrite_format failed for data_f_list2 column <%s> status =<0x%.8x>\n", status));
            ERRload_struct(MEM,status,"",NULL);
            MEMclose(&data_f_list2);
            return(status);
         }
       }
_NFIdebug ((fname, "action is %d\n", action_col)) ;

       sql_str = (char *) malloc (data_f_list->columns*200) ;
       if (sql_str == NULL)
       {
         ERRload_struct (NFI, NFI_E_MALLOC, "", "") ;
         _NFIdebug ((fname, "Failure : Malloc : status = <0x%.8x>\n", status));
         return (NFI_E_MALLOC) ;
       }

       for (i=0; i<data_f_list->rows; i++)
       {
         offset = i*data_f_list->columns ;
     _NFIdebug ((fname, "comparing %s\n", f_data [offset+action_col])) ;
         if (strcmp (f_data [offset+action_col], "ADD") == 0)
         {
	   _NFIdebug ((fname, "copying row %d\n", i)) ;
	   sql_str [0] = 0 ;
	   for (j=0; j<data_f_list->columns; j++)
	     {
	       strcat (sql_str, f_data[offset+j]) ;
	       strcat (sql_str, "\001") ;
	       _NFIdebug ((fname, "catting %s\n", f_data [offset+j])) ;
	     }
	   status = MEMwrite (data_f_list2, sql_str) ;
	   if (status != MEM_S_SUCCESS)
	     {
	       free (sql_str) ;
	       _NFIdebug ((fname, "Failure : MEMwrite : status = <0x%.8x>\n",
			   status)) ;
	       ERRload_struct (NFI, NFI_E_MEM, "", "") ;
	       return (NFI_E_MEM) ;
	     }
	 }
       }

        free (sql_str) ;

	if( _NFMdebug_st.NFIdebug_on )
         {
 	MEMprint_buffers( "FILE DATA LIST", data_f_list,
        _NFMdebug_st.NFIdebug_file );
 	MEMprint_buffers( "FILE DATA LIST2", data_f_list2,
		_NFMdebug_st.NFIdebug_file );
	 }
    SCdisplay_msg ("Working..");    
/* change calling buffers */

      status = NFMRcopy_item_n (NFMcatalog, attr_list, data_list, attr_f_list,
			      data_f_list2);
			
    _NFIdebug(( fname, "return from NFMRcopy_item_n -> 0x%.8x\n", status));

    MEMclose (&attr_list);
    MEMclose (&data_list);
    MEMclose (&value_list);
    MEMclose (&attr_f_list);
    MEMclose (&data_f_list);
    MEMclose (&data_f_list2);
    MEMclose (&value_f_list);
    
    if (status != NFM_S_SUCCESS)
        return (status);
    strcpy (NFMitem, item_name);
    _NFIdebug((fname, " The last value for NFMitem is <%s>\n", NFMitem));
    strcpy (NFMrev, item_rev);
    _NFIdebug((fname, " The last value for NFMrev is <%s>\n", NFMrev));

    NFMset_ind = 0;

    NFAmake_msg (msg);
    _NFIdebug(( fname, "%s\n", msg));
    SCdisplay_ref (msg);
        
    return (NFI_S_SUCCESS);
}


