#include "machine.h"
#include <stdio.h>
#include "NFMdef.h"
#include "SCstruct.h"
#include "SCdef.h"
#include "NFMRextern.h"

long add_files_to_item ()

{
long   status;
int    i, j, k, m;
int    tot_data;
int    max_len = 0;
int    pos = 0;
int    len;
int    count = 0;
struct SCcolumn_data_st data;
int    FORM_FILLED;
char   str[200];
char   **data_ptr;
char   **attr_ptr;
char   **column_ptr;
char   **format_ptr;
MEMptr  attr_list = NULL;
MEMptr  data_list = NULL;
MEMptr  value_list = NULL;
NDXnptr index;
static char *fname = "NFIadd_files_to_item";

    SCdisplay_msg ("Working..");    

    status = NFMRget_file_information (NFMcatalog, NFMitem, NFMrev,
                 NFM_ADD_FILE_TO_ITEM, &attr_list, &data_list, &value_list);
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
        _NFIdebug((fname,  " catalog name <%s>, item name <%s>, rev <%s>\n", NFMcatalog, NFMitem, NFMrev));

        if( status != NFM_S_SUCCESS )
            _NFIdebug(( fname, "NFMRreset_file_information <0x%.8x>\n",
                        status ));
        MEMclose (&attr_list);
        MEMclose (&data_list);
        MEMclose (&value_list);
        ERRload_struct( NFI, NFI_E_MEMORY, "%s%s", fname, "MEMbuild" );
        return( NFI_E_MEMORY );
    }

    attr_ptr = (char **) attr_list->data_ptr;
    column_ptr = (char **) attr_list->column_ptr;

    status = MEMbuild_array (data_list);
    if( status != MEM_S_SUCCESS )
    {
        status = NFMRreset_file_information (NFMcatalog, NFMitem, NFMrev);
        if( status != NFM_S_SUCCESS )
            _NFIdebug(( fname, "NFMRreset_file_information <0x%.8x>\n",
                        status ));
        MEMclose (&attr_list);
        MEMclose (&data_list);
        MEMclose (&value_list);
        _NFIdebug(( fname, "MEMbuild <0x%.8x>\n", status ));
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
    data.select_set_expected = SELECT_SET_MULTI_ROW; /* needed for PF4 key */
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
    strcpy (data.title, "Add File(s) to Item  (<PF1> to accept  <PF4> to stop adding files) ");

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

    /* Insert Data */
    for (i=0, k=0, m=0; i<(attr_list->rows*attr_list->columns); 
		   i+=attr_list->columns, ++m)
    {
	if( strcmp( attr_ptr[i+index.r], "Y" ) == 0 )
	{
	  if( strcmp( attr_ptr[i+index.list], "" ) != 0 )
	  {
		_NFIdebug(( fname, "list_no <%s>\n", attr_ptr[i+index.list]));
              status = NFAget_value_list_index_name (attr_ptr[i+index.list],
                            value_list, attr_ptr[i+index.syn],
                            attr_ptr[i+index.syn], str);
              if (status != NFI_S_SUCCESS)
                  {
		      status = NFMRreset_file_information (NFMcatalog, NFMitem,
							   NFMrev );
		      if( status != NFM_S_SUCCESS )
		          _NFIdebug(( fname, "NFMRreset_file_information <0x%.8x>\n",status ));
                  MEMclose (&attr_list);
                  MEMclose (&value_list);
                  MEMclose (&data_list);
                  return (status);
                  }
	      _NFIdebug(( fname, "Inserting Data <%s>\n", str ));
              NFAput_string (&data.data[k+1], str );
 	      data.selectable[k+1] = 0;
	  }
	  else
	  {
	      _NFIdebug(( fname, "Inserting Data <%s>\n", data_ptr[m] ));
              NFAput_string (&data.data[k+1], data_ptr[m]);
          }
	  k+=data.num_of_cols;
	}
    }
    _NFIdebug(( fname, "%s\n", "Call SCprocess" ));

    /* process column form until file_name has been entered */
    pos = 0;
    count = 0;
do
{
    do
    {
	FORM_FILLED = TRUE;
        status = SCprocess_column_form (&data, NFMprint_file);
        SCclear_msg ();

        _NFIdebug(( fname, "return from SCprocess_column_form -> %d\n", 
			data.sts));

        if (data.sts == FORM_ACCEPTED)
        {
            /* if attribute is required ("n_null" == "N"),
               user must keyin a value */
            status = NFAvalidate_new_nulls (attr_list, index, data, pos,
                                        &FORM_FILLED);
        }
    }
    while ((data.sts == FORM_ACCEPTED) && (FORM_FILLED == FALSE));

    if( (data.sts == FORM_ACCEPTED) && (FORM_FILLED) )
    {
      str [0] = 0 ;
      _NFIdebug((fname,  "return value for str is <%s>\n", data.data[1]));
      for( i=0, m=0, j=0; i<(attr_list->rows*attr_list->columns); 
		      i+=attr_list->columns, ++j)
 	{
	  if( strcmp( attr_ptr[i+index.r],  "Y" ) == 0 )
	   {
	     _NFIdebug ((fname,  "m is <%d> : data is <%s>\n",  
		m,  data.data [m+1] )) ;
	     strcat( str, data.data[m+1] );
             strcat( str, "\1" );
	     m+= data.num_of_cols;
	    }
	   else
	    {
	      /* look in data list buffer in column i, row 1 */
            _NFIdebug ((fname,  "i is <%d> : writing <%s>\n", 
			i, data_ptr[j]));
	     strcat( str, data_ptr [j] );
	    strcat( str, "\1" );
            }
          }
/*        _NFIdebug((fname,  " value of str <%s>\n", str));*/
/*        MEMprint_buffers("data_list",  data_list,  "/dev/console");*/
          status = MEMwrite (data_list, str);
          if (status != MEM_S_SUCCESS)
           {
	    _NFIdebug((fname, "MEMwrite status <0x%.8x>\n", status));
            status = NFMRreset_file_information (NFMcatalog, NFMitem, NFMrev);
            if( status != NFM_S_SUCCESS )
                 _NFIdebug(( fname, "NFMRreset_file_information <0x%.8x>\n",
                        status ));

            MEMclose (&attr_list);
            MEMclose (&data_list);
            MEMclose (&value_list);
            NFAfree_list(data.data,data.num_of_rows, 
			     data.num_of_cols);
            free (data.data);
            ERRload_struct( NFI, NFI_E_MEMORY, "%s%s", fname, "MEMwrite" );
            return (NFI_E_MEMORY);
        }
        ++count;
        SCdisplay_msg ("File Information Accepted..");    

    } /*  if( data.sts == FORM_ACCEPTED ) */
    status = MEMbuild_array (data_list) ;
    if (status != MEM_S_SUCCESS)
      {
	_NFIdebug((fname, "MEMwrite status <0x%.8x>\n", status));
	status = NFMRreset_file_information (NFMcatalog, NFMitem, NFMrev);
	if( status != NFM_S_SUCCESS )
	  _NFIdebug(( fname, "NFMRreset_file_information <0x%.8x>\n",
		     status ));
	
	MEMclose (&attr_list);
	MEMclose (&data_list);
	MEMclose (&value_list);
	NFAfree_list(data.data,data.num_of_rows, 
		     data.num_of_cols);
	free (data.data);
	ERRload_struct( NFI, NFI_E_MEMORY, "%s%s", fname, "MEMwrite" );
	return (NFI_E_MEMORY);
      }
    data_ptr = (char **) data_list -> data_ptr ;
}
while( data.sts == FORM_ACCEPTED );

    if( (data.sts == FORM_CANCELED) || (count == 0) )
        {
        status = NFMRreset_file_information (NFMcatalog, NFMitem, NFMrev );
	if( status != NFM_S_SUCCESS )
	    _NFIdebug(( fname, "NFMRreset_file_information <0x%.8x>\n",
			status ));
        NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
        free (data.data);
	ERRload_struct( NFI, NFI_W_COMMAND_CANCELLED, NULL, NULL );
        MEMclose (&attr_list);
        MEMclose (&data_list);
        MEMclose (&value_list);
        return (NFI_W_COMMAND_CANCELLED);
        }

    if( _NFMdebug_st.NFIdebug_on )
	MEMprint_buffers( "DATA LIST", data_list, _NFMdebug_st.NFIdebug_file);

    SCdisplay_msg ("Working..");    

    status = NFMRdefine_file_information (NFMcatalog, NFMitem, NFMrev,
			NFM_ADD_FILE_TO_ITEM, data_list);

    _NFIdebug(( fname, "return from NFMRdefine_file_information -> 0x%.8x\n", 
		status));

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


