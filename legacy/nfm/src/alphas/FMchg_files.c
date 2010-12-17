#include "machine.h"
#include "SCstruct.h"
#include "SCdef.h"
#include "NFMRextern.h"

long change_file_attributes ()

{
long   status;
int    i, j, k, m, n;
int    tot_data;
int    max_len = 0;
int    pos = 0;
int    len;
int    count = 0;
struct SCcolumn_data_st data;
int    FORM_FILLED;
char   index_name[100];
char   **attr_ptr;
char   **data_ptr;
char   **column_ptr;
char   **format_ptr;
MEMptr  attr_list = NULL;
MEMptr  data_list = NULL;
MEMptr  value_list = NULL;
NDXnptr index;
static char *fname = "NFIchange_file_attributes";

    SCdisplay_msg ("Working..");    

    status = NFMRget_file_information (NFMcatalog, NFMitem, NFMrev,
         NFM_CHANGE_FILE_INFORMATION, &attr_list, &data_list, &value_list);
    if (status != NFM_S_SUCCESS)
        {
	_NFIdebug(( fname, "NFMRget_file_information  <0x%.8x>\n", status ));
        MEMclose (&attr_list);
        MEMclose (&data_list);
        MEMclose (&value_list);
        return (status);
        }

    status = MEMbuild_array (attr_list);
    if( status != MEM_S_SUCCESS )
    {

        _NFIdebug(( fname, "MEMbuild <0x%.8x>\n", status ));
        status = NFMRreset_file_information (NFMcatalog, NFMitem, NFMrev);

        _NFIdebug((fname,  "STATUS FOR FIRST CALL IS <%d>\n", status));
        _NFIdebug((fname,  " catalog name <%s>, item name <%s>, rev<%s>\n", NFMcatalog, NFMitem, NFMrev));

        if( status != NFM_S_SUCCESS )
          _NFIdebug(( fname, "NFMRreset_file_information <0x%.8x>\n",status ));
        MEMclose (&attr_list);
        MEMclose (&data_list);
        MEMclose (&value_list);
        _NFIdebug(( fname, "MEMbuild <0x%.8x>\n", status ));
        ERRload_struct( NFI, NFI_E_MEMORY, "%s%s", fname, "MEMbuild" );
        return( NFI_E_MEMORY );
    }

    attr_ptr = (char **) attr_list->data_ptr;
    column_ptr = (char **) attr_list->column_ptr;

    status = MEMbuild_array (data_list);
    if( status != MEM_S_SUCCESS )
    {
        _NFIdebug(( fname, "MEMbuild <0x%.8x>\n", status ));

        status = NFMRreset_file_information (NFMcatalog, NFMitem, NFMrev);
        if( status != NFM_S_SUCCESS )
          _NFIdebug(( fname, "NFMRreset_file_information <0x%.8x>\n",status ));
        MEMclose (&attr_list);
        MEMclose (&data_list);
        MEMclose (&value_list);
        ERRload_struct( NFI, NFI_E_MEMORY, "%s%s", fname, "MEMbuild" );
        return( NFI_E_MEMORY );
    }

    data_ptr = (char **) data_list->data_ptr;
    format_ptr = (char **) data_list->format_ptr;

    NFMRfill_newer_index( attr_list, &index );
    
    /*  Get number of readable attributes */
    for( i=0,count=0; i<(attr_list->rows*attr_list->columns); 
		      i+=attr_list->columns)
	if( strcmp( attr_ptr[i+index.r], "Y" ) == 0 )
	    ++count;

    _NFIdebug(( fname, "Count <%d>\n", count ));

    data.num_of_rows = count;
    data.num_of_cols = 2;
    tot_data = data.num_of_cols * data.num_of_rows;
    data.freeze_rows_count = 0;
    data.select_set_expected = FALSE;
    data.col_width = (int *) malloc (data.num_of_cols * sizeof (int));
    memset (data.col_width, 0, (data.num_of_cols * sizeof (int)));

    max_len = 0;
    for (i=0,j=0; i<(attr_list->rows*attr_list->columns); 
		  i+=attr_list->columns, ++j)
    {
	if( strcmp( attr_ptr[i+index.r], "Y" ) == 0 )
	{
	    len     = 0;
            status = NFAcol_width (attr_ptr[i], format_ptr[j], &len);
            if (len > max_len)
                max_len = len;
	}
    }
    if( max_len > 35 )
	max_len = 35;

    data.col_width[0] = 25;
    data.col_width[1] = max_len;

    data.new_rows_expected = FALSE;
    strcpy (data.title, "Change File Information  (<PF1> to accept  <PF3> to skip)");

    data.selectable = (int *) malloc (tot_data * sizeof (int));
    memset (data.selectable, 0, (tot_data * sizeof (int)));

    for (i=0; i<tot_data; i+=data.num_of_cols)
        data.selectable[i+1] = 1;

    data.hidden = (int *) malloc (tot_data * sizeof (int));
    memset (data.hidden, 0, (tot_data * sizeof (int)));

    /* allocate and initialize space to store data */

    data.data = (char **) malloc (tot_data * sizeof (char *));
    memset (data.data, NULL, (tot_data * sizeof (char *)));

    /* Load Synonym Titles */
    for (i=0,j=0; i<(attr_list->rows*attr_list->columns);i+=attr_list->columns)
    {
   	  if( strcmp( attr_ptr[i+index.r], "Y" ) == 0 )
	   {
	    _NFIdebug(( fname, "Loading Title <%s>\n", attr_ptr[i] ));
	    NFAput_string (&data.data[j], attr_ptr[i]);
	    j+=data.num_of_cols;
	   }
     }
    count = 0;

/* Start Loop of ALL rows of data */
for( i=0,n=0; i<(data_list->rows*data_list->columns); 
	      i+=data_list->columns,++n )
{
	_NFIdebug ((fname,  " value of i <%d> and n %d and file name %s\n", 
	   i, n, data_ptr[i+2]));
	
    /* Build Form using this row */
    for (j=0, k=0, m=0; j<(attr_list->rows*attr_list->columns); 
		   j+=attr_list->columns, ++m)
    {
	if( strcmp( attr_ptr[j+index.r], "Y" ) == 0 )
	{
            if (strcmp (attr_ptr[j+index.list], "") != 0)
                {
                /* if there is a value list, display the list and let them
                   choose the value */
                   status = NFAget_value_list_index_name_new (
                            attr_ptr[j+index.list], 
                            value_list, data_ptr[i+2], attr_ptr[j+index.syn],
                            attr_ptr[j+index.syn], index_name);
                if (status != NFI_S_SUCCESS)
                 {

                   status = NFMRreset_file_information (NFMcatalog, NFMitem, 
                                      NFMrev );
                      if( status != NFM_S_SUCCESS )
                      _NFIdebug(( fname, "NFMRreset_file_information<0x%.8x>\n",status ));
                    MEMclose (&attr_list);
                    MEMclose (&value_list);
                    MEMclose (&data_list);
                    return (status);
                    }
                NFAput_string (&data.data[k+1], index_name);
     	        data.selectable[k+1] = 0;		
                }
     	     else
         		{
  	             _NFIdebug(( fname, "Inserting Data <%s>\n", data_ptr[i+m] ));
                 NFAput_string (&data.data[k+1], data_ptr[i+m]);
        		}
	            k+=data.num_of_cols;
    	}
    }
    _NFIdebug(( fname, "%s\n", "Call SCprocess" ));

    /* process column form until needed information has been entered */
    pos = 0;

    do
    {
    	FORM_FILLED = TRUE;
        status = SCprocess_column_form (&data, NFMprint_file);
        SCclear_msg ();

        _NFIdebug(( fname, "return from SCprocess_column_form -> %d\n", data.sts));
        if (data.sts == FORM_ACCEPTED)
        {
            /* if attribute is required ("n_null" == "N"),
               user must keyin a value */
            status = NFAvalidate_new_nulls (attr_list, index, data, pos,
                                        &FORM_FILLED);
        }
    }
    while ((data.sts == FORM_ACCEPTED) && (FORM_FILLED == FALSE));

    if (data.sts == FORM_CANCELED)

 	continue;  /*  Skip Changing this file */

    SCdisplay_msg ("File Information Accepted..");    

    /* Now write changed data into that row in the data_list */
  if( (data.sts == FORM_ACCEPTED) && (FORM_FILLED) )
   {
    for( j=0, k=0, m=0; j<(attr_list->rows*attr_list->columns);
			j+=attr_list->columns, ++m )
    {
	  if( strcmp( attr_ptr[j+index.r], "Y" ) == 0 )
   	   {
	    _NFIdebug(( fname, "Writing <%s> into row <%d> col <%d>\n",
			data.data[k+1], n+1, m+1 ));
	    status = MEMwrite_data( data_list, data.data[k+1], n+1, m+1 );
	    if( status != MEM_S_SUCCESS )
	     {
    		_NFIdebug(( fname, "MEMwrite_data <0x%.8x>\n", status ));
    		MEMclose( &attr_list );
    		MEMclose( &data_list );
    		MEMclose( &value_list );
	        status = NFMRreset_file_information (NFMcatalog, NFMitem, 
						     NFMrev );
	        if( status != NFM_S_SUCCESS )
            _NFIdebug(( fname, "NFMRreset_file_information <0x%.8x>\n", status ));
	        NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
	        free (data.data);
	        ERRload_struct( NFI, NFI_E_MEMORY,"%s%s", fname, "MEMwrite_data" );
    		return( NFI_E_MEMORY ); 
	     }
	    k+=data.num_of_cols;
      } /* end of writing data into buffer */
   }

    /*  Now write "Y"es into 'n_status' attribute */
    _NFIdebug(( fname, "Write YES into row <%d> column <%d>\n", (n+1),data_list->columns ));
    status = MEMwrite_data( data_list, "Y", n+1, data_list->columns );
    if( status != MEM_S_SUCCESS )
    {
        _NFIdebug(( fname, "MEMwrite_data <0x%.8x>\n", status ));
        MEMclose( &attr_list );
        MEMclose( &data_list );
        MEMclose( &value_list );
        status = NFMRreset_file_information (NFMcatalog, NFMitem,   NFMrev );
        if( status != NFM_S_SUCCESS )
         _NFIdebug(( fname, "NFMRreset_file_information <0x%.8x>\n", status ));
        NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
        free (data.data);
        ERRload_struct( NFI, NFI_E_MEMORY,"%s%s", fname,  "MEMwrite_data" );
        return( NFI_E_MEMORY ); 
      }
    ++count;
     }   /* FORM ACCEPTED */

 } /* end Data Rows Loop */
    
    if( (data.sts == FORM_CANCELED) || (count == 0) )
     {
        status = NFMRreset_file_information (NFMcatalog, NFMitem, NFMrev);
        if( status != NFM_S_SUCCESS )
         _NFIdebug(( fname, "NFMRreset_file_information <0x%.8x>\n", status ));
        NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
        free (data.data);
        ERRload_struct( NFI, NFI_W_COMMAND_CANCELLED, NULL, NULL );
        MEMclose (&attr_list);
        MEMclose (&data_list);
        MEMclose (&value_list);
        return (NFI_W_COMMAND_CANCELLED);
        }

    _NFIdebug(( fname, "Rows changed <%d>\n", count ));

    if( _NFMdebug_st.NFIdebug_on )
	MEMprint_buffers( "DATA LIST", data_list, _NFMdebug_st.NFIdebug_file);

    SCdisplay_msg ("Working..");    

    status = NFMRdefine_file_information (NFMcatalog, NFMitem, NFMrev,
			NFM_CHANGE_FILE_INFORMATION, data_list);

    _NFIdebug(( fname, "return from NFMRdefine_file_information -> 0x%.8x\n", status));

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


