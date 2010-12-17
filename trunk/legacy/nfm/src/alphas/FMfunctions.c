#include "machine.h"
#include "NFMdef.h"
#include "NFMRextern.h"
#include "SCstruct.h"
#include "SCdef.h"
#include "SCextern.h"
#include "NFMRlist.h"
#include "NFMdisplays.h"
#include "NFMtitles.h"
#include "UMS.h"

extern  struct NFMwf_info    NFAwf_info;
extern  struct NFMoperation  NFAoperation;

long sqlstatus;
char title[80];

long NFAget_st_area_name (storage_name)
    char *storage_name;

{
int     i, j;
long    status = NFI_S_SUCCESS;
long    NFAfill_list_struct ();
long    NFAfree_list_struct ();
struct  SCfree_data_st fdata;
NFMlist list_struct;
static  char *fname = "NFAget_st_area_name";

    if (strcmp (NFMstorage, "") != 0)
        {
        strcpy (storage_name, NFMstorage);
        return (NFI_S_SUCCESS);
        }
    if ((status = (long) UMSGetByNum
        (title, NFT_P_LIST_SA, NULL)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        strcpy (title, "List of I/NFM Storage Areas" );
      }

    NFAfill_list_struct (&list_struct, DSP_STORAGE_AREAS, 
SELECT_SET_SINGLE_ROW, NFM_SHORT_DISPLAY, -1, "", "", "", 
"", "", "", "", title);

    status = NFAdisplay_elements (&fdata, list_struct);

    NFAfree_list_struct (&list_struct);

    if (status != NFI_S_SUCCESS)
        {
	ERRload_struct( NFI, NFI_E_LIST_STORAGE_AREAS, NULL, NULL );
        return (status);
        }

    for (i=0; i<fdata.num_of_rows; ++i)
        {
        j = i * fdata.num_of_cols;
        if (fdata.select_set[i] == 1)
            {
            strcpy (storage_name, fdata.data[j+1]);
            break;
            }
        }

    NFAfree_list (fdata.data, fdata.num_of_rows, fdata.num_of_cols);
    free (fdata.data);

    return (NFI_S_SUCCESS);
}


long NFAget_storage_info (storage_num, storage_name, temp_node, temp_user,
                          temp_passwd, temp_path, mode)
    char *storage_num;
    char *storage_name;
    char *temp_node;
    char *temp_user;
    char *temp_passwd;
    char *temp_path;
    int  mode;        /* 0 - checkin, 1 - checkout, 2 - copy */

{
int   i;
int   tot_data;
int   FORM_FILLED;
long  status = NFI_S_SUCCESS;
struct SCcolumn_data_st data;
static char *fname = "NFAget_storage_info";

    _NFIdebug(( fname, "storage num : %s\n", storage_num));

    if (strcmp (storage_num, "") != 0)
        {
        status = NFMRget_sa_name (NFMuser_id, storage_num, storage_name);
        if (status != NFM_S_SUCCESS)
            {
            return (status);
            }
        }
    else
        strcpy (storage_name, NFMstorage);

    _NFIdebug(( fname, "storage name : %s\n", storage_name));

    strcpy (temp_node, "");
    strcpy (temp_user, "");
    strcpy (temp_passwd, "");
    strcpy (temp_path, "");
    
    data.num_of_rows = 5;
    data.num_of_cols = 2;
    tot_data = data.num_of_cols * data.num_of_rows;
    data.freeze_rows_count = 0;
    data.select_set_expected = FALSE;
    data.col_width = (int *) malloc (data.num_of_cols * sizeof (int));
    memset (data.col_width, 0, (data.num_of_cols * sizeof (int)));
    
    data.col_width[0] = 18;
    data.col_width[1] = 30;
    data.new_rows_expected = FALSE;

    switch (mode)
        {
        case 0:
            sprintf (data.title, "%s", "Where File is to be Checked In From:");
            break;
        case 1:
            sprintf (data.title, "%s", "Where File is to be Checked Out To:");
            break;
        case 2:
            sprintf (data.title, "%s", "Where File is to be Checked Copied To:");
            break;
        default:
            sprintf (data.title, "%s", "Enter Storage Area Information:");
            break;
        }


    data.selectable = (int *) malloc (tot_data * sizeof (int));
    memset (data.selectable, 0, (tot_data * sizeof (int)));

    for (i=0; i<tot_data; i+=data.num_of_cols)
        data.selectable[i+1] = 1;

    data.hidden = (int *) malloc (tot_data * sizeof (int));
    memset (data.hidden, 0, (tot_data * sizeof (int)));
    data.hidden[7] = 1;

    /* allocate and initialize space to store data */

    data.data = (char **) malloc (tot_data * sizeof (char *));
    memset (data.data, NULL, (tot_data * sizeof (char *)));

    NFAput_string (&data.data[0], "Storage Name");
    NFAput_string (&data.data[1], storage_name);
    NFAput_string (&data.data[2], "    Temp Node");
    NFAput_string (&data.data[4], "    Temp User");
    NFAput_string (&data.data[6], "    Temp Password");
    NFAput_string (&data.data[8], "    Temp Pathname");

    /* process column form until an Report Name has been entered */
    do
        {
        FORM_FILLED = TRUE;
        status = SCprocess_column_form (&data, NFMprint_file);
        SCclear_msg ();

        _NFIdebug(( fname, "Return from SCprocess_column_form -> %d\n", 
			data.sts));

        if (data.sts != FORM_CANCELED)
            {
            status = NFAvalidate_string ("char(14)", data.data[1]);
            status = NFAvalidate_string ("char(30)", data.data[3]);
            status = NFAvalidate_string ("char(14)", data.data[5]);
            status = NFAvalidate_string ("char(14)", data.data[7]);
            status = NFAvalidate_string ("char(50)", data.data[9]);
            }
        }
    while ((FORM_FILLED == FALSE) && (data.sts != FORM_CANCELED));

    if (data.sts == FORM_CANCELED)
        {
        NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
        free (data.data);
	ERRload_struct( NFI, NFI_W_COMMAND_CANCELLED, NULL, NULL );
        return (NFI_W_COMMAND_CANCELLED);
        }

    if (data.data[1] != NULL)
        strcpy (storage_name, data.data[1]);
    if (data.data[3] != NULL)
        strcpy (temp_node, data.data[3]);
    if (data.data[5] != NULL)
        strcpy (temp_user, data.data[5]);
    if (data.data[7] != NULL)
        strcpy (temp_passwd, data.data[7]);
    if (data.data[9] != NULL)
        strcpy (temp_path, data.data[9]);

    _NFIdebug(( fname, "storage name : <%s>\n", storage_name));
    _NFIdebug(( fname, "temp node : <%s>\n", temp_node));
    _NFIdebug(( fname, "temp user : <%s>\n", temp_user));
    _NFIdebug(( fname, "temp path : <%s>\n", temp_path));

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    return (NFI_S_SUCCESS);
}


long NFAget_node_info (node_name, node_num)
    char *node_name;
    char *node_num;

{
int   i, j;
long  NFAfill_list_struct ();
long  NFAfree_list_struct ();
long  status = NFI_S_SUCCESS;
struct SCfree_data_st fdata;
NFMlist list_struct;
static char *fname = "NFAget_node_info";

    if ((status = (long) UMSGetByNum
        (title, NFT_P_LIST_NODES, NULL)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        strcpy (title, "List of I/NFM Nodes" );
      }

    NFAfill_list_struct (&list_struct, DSP_NODES, SELECT_SET_SINGLE_ROW, 
	NFM_SHORT_DISPLAY, -1, "", "", "", "", "", "", "", title);

    status = NFAdisplay_elements (&fdata, list_struct);

    NFAfree_list_struct (&list_struct);

    if (status != NFI_S_SUCCESS)
        {
	ERRload_struct( NFI, NFI_E_LIST_NODES, NULL, NULL );
        return (status);
        }

    for (i=0; i<fdata.num_of_rows; ++i)
        {
        j = i * fdata.num_of_cols;
        if (fdata.select_set[i] == 1)
            {
            strcpy (node_num, fdata.data[j]);
            strcpy (node_name, fdata.data[j+1]);
            break;
            }
        }

    NFAfree_list (fdata.data, fdata.num_of_rows, fdata.num_of_cols);
    free (fdata.data);

    return (NFI_S_SUCCESS);
}


long NFAget_search_name (search_name)
    char *search_name;

{
int     i, j;
long    status = NFI_S_SUCCESS;
long    NFAfill_list_struct ();
long    NFAfree_list_struct ();
struct  SCfree_data_st fdata;
NFMlist list_struct;
static  char *fname = "NFAget_search_name";

    if (strcmp (NFMsearch_name, "") != 0)
        {
        strcpy (search_name, NFMsearch_name);
        return (NFI_S_SUCCESS);
        }

    if ((status = (long) UMSGetByNum
        (title, NFT_P_LIST_SEARCH, NULL)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        strcpy (title, "List of Search Criteria Names" );
      }

    NFAfill_list_struct (&list_struct, DSP_SEARCH, SELECT_SET_SINGLE_ROW, 
	NFM_SHORT_DISPLAY, -1, "", "", "", "", "", "", "", title);

    status = NFAdisplay_elements (&fdata, list_struct);

    NFAfree_list_struct (&list_struct);

    if (status != NFI_S_SUCCESS)
        {
	ERRload_struct( NFI, NFI_E_LIST_REPORTS, NULL, NULL );
        return (status);
        }

    for (i=0; i<fdata.num_of_rows; ++i)
        {
        j = i * fdata.num_of_cols;
        if (fdata.select_set[i] == 1)
            {
            strcpy (search_name, fdata.data[j]);
            break;
            }
        }

    NFAfree_list (fdata.data, fdata.num_of_rows, fdata.num_of_cols);
    free (fdata.data);

    return (NFI_S_SUCCESS);
}

long NFAconfirm( title, confirmed )
    char *title;
    int  *confirmed;

{
int     tot_data;
long    status = NFI_S_SUCCESS;
struct  SCfree_data_st data;

    data.num_of_rows = 2;
    data.num_of_cols = 1;
    tot_data = data.num_of_rows * data.num_of_cols;
    data.freeze_rows_count = 0;
    data.freeze_cols_count = 0;
    data.select_set_expected = SELECT_SET_SINGLE_ROW;
    data.max_indent = 0;

    data.col_size = (int*) malloc (data.num_of_cols * sizeof(int));
    memset( data.col_size, 0, (data.num_of_cols * sizeof(int)));
    data.col_size[0] = 5;

    data.col_pos = (int*) malloc (data.num_of_cols * sizeof(int));
    memset( data.col_pos, 0, (data.num_of_cols * sizeof(int)));
    data.col_pos[0] = 0;

    data.col_just = (int*) malloc( data.num_of_cols * sizeof( int ));
    memset( data.col_just, LEFT_JUSTIFIED, (data.num_of_cols * sizeof( int )));

    data.h1_pos = (int*)malloc( sizeof(int) + 1 );
    memset( data.h1_pos, 0, sizeof(int) + 1 );
    data.h1_pos[0] = 0;
    data.h1_pos[1] = -1;
         
    data.h2_pos = (int*)malloc( sizeof(int) + 1 );
    memset( data.h2_pos, 0, sizeof(int) + 1 );
    data.h2_pos[0] = 0;
    data.h2_pos[1] = -1;

    data.h3_pos = (int*)malloc( sizeof(int) + 1 );
    memset( data.h3_pos, 0, sizeof(int) + 1 );
    data.h3_pos[0] = 0;
    data.h3_pos[1] = -1;
 
    data.h1_data = (char**)malloc( sizeof(char*) );
    memset( data.h1_data, NULL, sizeof(char*) );
    NFAput_string( &data.h1_data[0], "" );
    
    data.h2_data = (char**)malloc( sizeof(char*) );
    memset( data.h2_data, NULL, sizeof(char*) );
    NFAput_string( &data.h2_data[0], "" );

    data.h3_data = (char**)malloc( sizeof(char*) );
    memset( data.h3_data, NULL, sizeof(char*) );
    NFAput_string( &data.h3_data[0], "" );

    sprintf (data.title, "Are you SURE you want to %s?", title );

    data.select_set = (int*) malloc( tot_data * sizeof(int));
    memset( data.select_set, 0, tot_data * sizeof(int) );

    data.data = (char **) malloc ( tot_data * sizeof (char *));
    memset (data.data, NULL, tot_data * sizeof (char *));

    NFAput_string (&data.data[0], "Yes" );
    NFAput_string (&data.data[1], "No" );

    status = SCprocess_free_form( &data, NFMprint_file );
    *confirmed = 0;

    if( data.select_set[0] == 1 )
	*confirmed = 1;

    else if( data.select_set[1] == 1 )
	*confirmed = 0;

    if( data.sts == FORM_CANCELED || (*confirmed == 0) )
    {
        NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
        free (data.data);
	ERRload_struct( NFI, NFI_W_COMMAND_CANCELLED, NULL, NULL );
	*confirmed = 0;
	return( NFI_W_COMMAND_CANCELLED );
    }

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    return (NFI_S_SUCCESS);
}

long NFAchoose_set_flagging_level( level )
    int  *level; 	/*  1 - primary members only
			 *  0 - primary and secondary members
			 */
{
int     tot_data;
long    status = NFI_S_SUCCESS;
struct  SCfree_data_st data;

    *level = 1;

    return( NFI_S_SUCCESS );

    data.num_of_rows = 2;
    data.num_of_cols = 1;
    tot_data = data.num_of_rows * data.num_of_cols;
    data.freeze_rows_count = 0;
    data.freeze_cols_count = 0;
    data.select_set_expected = SELECT_SET_SINGLE_ROW;
    data.max_indent = 0;

    data.col_size = (int*) malloc (data.num_of_cols * sizeof(int));
    memset( data.col_size, 0, (data.num_of_cols * sizeof(int)));
    data.col_size[0] = 40;

    data.col_pos = (int*) malloc (data.num_of_cols * sizeof(int));
    memset( data.col_pos, 0, (data.num_of_cols * sizeof(int)));
    data.col_pos[0] = 0;

    data.col_just = (int*) malloc( data.num_of_cols * sizeof( int ));
    memset( data.col_just, LEFT_JUSTIFIED, (data.num_of_cols * sizeof( int )));

    data.h1_pos = (int*)malloc( sizeof(int) + 1 );
    memset( data.h1_pos, 0, sizeof(int) + 1 );
    data.h1_pos[0] = 0;
    data.h1_pos[1] = -1;
         
    data.h2_pos = (int*)malloc( sizeof(int) + 1 );
    memset( data.h2_pos, 0, sizeof(int) + 1 );
    data.h2_pos[0] = 0;
    data.h2_pos[1] = -1;

    data.h3_pos = (int*)malloc( sizeof(int) + 1 );
    memset( data.h3_pos, 0, sizeof(int) + 1 );
    data.h3_pos[0] = 0;
    data.h3_pos[1] = -1;
 
    data.h1_data = (char**)malloc( sizeof(char*) );
    memset( data.h1_data, NULL, sizeof(char*) );
    NFAput_string( &data.h1_data[0], "" );
    
    data.h2_data = (char**)malloc( sizeof(char*) );
    memset( data.h2_data, NULL, sizeof(char*) );
    NFAput_string( &data.h2_data[0], "" );

    data.h3_data = (char**)malloc( sizeof(char*) );
    memset( data.h3_data, NULL, sizeof(char*) );
    NFAput_string( &data.h3_data[0], "" );

    strcpy (data.title, "Choose Member Types to Flag");

    data.select_set = (int*) malloc( tot_data * sizeof(int));
    memset( data.select_set, 0, tot_data * sizeof(int) );

    data.data = (char **) malloc ( tot_data * sizeof (char *));
    memset (data.data, NULL, tot_data * sizeof (char *));

    NFAput_string (&data.data[0], "Flag Primary and Secondary Members" );
    NFAput_string (&data.data[1], "Flag Primary Members Only" );

    status = SCprocess_free_form( &data, NFMprint_file );
    *level = 0;

    if( data.select_set[0] == 1 )
	*level = 0;

    else if( data.select_set[1] == 1 )
	*level = 1;

    if( data.sts == FORM_CANCELED )
    {
        NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
        free (data.data);
	ERRload_struct( NFI, NFI_W_COMMAND_CANCELLED, NULL, NULL );
	return( NFI_W_COMMAND_CANCELLED );
    }

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    return (NFI_S_SUCCESS);
}


long NFAcol_width (data_ptr1, data_ptr2, max_len)

    char  *data_ptr1;
    char  *data_ptr2;
    int   *max_len;
    
{
int temp_len;
char str[5];

    if (strlen (data_ptr1) > *max_len)
        *max_len = strlen (data_ptr1);

    temp_len = 0;

         if (strncmp (data_ptr2, "char", 4) == 0)
             {
             strncpy (str, data_ptr2 + 5, (strlen (data_ptr2) - 6));
             str[strlen(data_ptr2) - 6] = '\0';
             temp_len = atoi (str);
             }

    else if ((strncmp (data_ptr2, "int", 3) == 0) ||
             (strncmp (data_ptr2, "smallint", 8) == 0))
             temp_len = 12;

    else if (strncmp (data_ptr2, "timestamp", 9) == 0)
             temp_len = 20 ;

    else if ((strncmp (data_ptr2, "double", 6)  == 0) ||
             (strncmp (data_ptr2, "real", 4)    == 0) ||
             (strncmp (data_ptr2, "decimal", 7) == 0))
             temp_len = 25;

    if (temp_len > *max_len)
        *max_len = temp_len;

    if (*max_len > 40)
        *max_len = 40;

    return (NFI_S_SUCCESS);
}


long NFAget_dtype_len (data_ptr1, data_ptr2, len)

    char  *data_ptr1;
    char  *data_ptr2;
    int   *len;
    
{
int  temp_len1;
int  temp_len2;
char str[5];

    *len = 0;
    temp_len1 = 0;
    temp_len2 = 0;
    
         if (strncmp (data_ptr1, "char", 4) == 0)
             {
             strncpy (str, data_ptr1 + 5, (strlen (data_ptr1) - 6));
             str[strlen(data_ptr1) - 6] = '\0';
             temp_len1 = atoi (str);
             }

    else if ((strncmp (data_ptr1, "int", 3) == 0) ||
             (strncmp (data_ptr1, "smallint", 8) == 0))
             temp_len1 = 12;

    else if (strncmp (data_ptr1, "timestamp", 9) == 0)
             temp_len1 = 20;

    else if ((strncmp (data_ptr1, "double", 6)  == 0) ||
             (strncmp (data_ptr1, "real", 4)    == 0) ||
             (strncmp (data_ptr1, "decimal", 7) == 0))
             temp_len1 = 25;

    temp_len2 = strlen (data_ptr2);
    
    if (temp_len1 >= temp_len2)
        *len = temp_len2;
    else
        *len = temp_len1;
        
    return (NFI_S_SUCCESS);
}


long NFAdtype_length (data_ptr, len)

    char  *data_ptr;
    int   *len;
    
{
char str[5];

    *len = 10;
    
         if (strncmp (data_ptr, "char", 4) == 0)
             {
             strncpy (str, data_ptr + 5, (strlen (data_ptr) - 6));
             str[strlen(data_ptr) - 6] = '\0';
             *len = atoi (str);
             }

    else if ((strncmp (data_ptr, "int", 3) == 0) ||
             (strncmp (data_ptr, "smallint", 8) == 0))
             *len = 12;

    else if (strncmp (data_ptr, "timestamp", 9) == 0)
             *len = 20;

    else if ((strncmp (data_ptr, "double", 6)  == 0) ||
             (strncmp (data_ptr, "real", 4)    == 0) ||
             (strncmp (data_ptr, "decimal", 7) == 0))
             *len = 25;

    return (NFI_S_SUCCESS);
}


long NFAfind_len (data_ptr, column_ptr, index, rows, cols, max_attr_len,
                  max_syn_len, max_dtype_len)

    char  **data_ptr;
    NDXptr index;
    int   rows;
    int   cols;
    int   *max_attr_len, *max_syn_len, *max_dtype_len;
    
{
int  i;
int  temp_len;
char str[5];

for (i=0; i<rows; i+=cols)
    {
    if (strlen (data_ptr[i+index.name]) > *max_attr_len)
        *max_attr_len = strlen (data_ptr[i+index.name]);

    if (strlen (data_ptr[i+index.syn]) > *max_syn_len)
        *max_syn_len = strlen (data_ptr[i+index.syn]);

    temp_len = 0;

         if (strncmp (data_ptr[i+index.dt], "char", 4) == 0)
             {
             strncpy (str, data_ptr[i+index.dt] + 5,
                      (strlen (data_ptr[i+index.dt]) - 6));
             temp_len = atoi (str);
             }

    else if ((strncmp (data_ptr[i+index.dt], "int", 3) == 0) ||
             (strncmp (data_ptr[i+index.dt], "smallint", 8) == 0))
             temp_len = 12;

    else if (strncmp (data_ptr[i+index.dt], "timestamp",9) == 0)
             temp_len = 20 ;

    else if ((strncmp (data_ptr[i+index.dt], "double", 6)  == 0) ||
             (strncmp (data_ptr[i+index.dt], "real", 4)    == 0) ||
             (strncmp (data_ptr[i+index.dt], "decimal", 7) == 0))
             temp_len = 25;

    if (temp_len > *max_dtype_len)
        *max_dtype_len = temp_len;

    }

if (*max_dtype_len > 40)
    *max_dtype_len = 40;

return (NFI_S_SUCCESS);
}


long NFAfind_new_len (data_ptr, column_ptr, index, rows, cols, max_attr_len,
                      max_syn_len, max_dtype_len)

    char  **data_ptr;
    NDXnewptr index;
    int   rows;
    int   cols;
    int   *max_attr_len, *max_syn_len, *max_dtype_len;
    
{
int  i;
int  temp_len;
char str[5];

for (i=0; i<rows; i+=cols)
    {
    if (strlen (data_ptr[i+index.name]) > *max_attr_len)
        *max_attr_len = strlen (data_ptr[i+index.name]);

    if (strlen (data_ptr[i+index.syn]) > *max_syn_len)
        *max_syn_len = strlen (data_ptr[i+index.syn]);

    temp_len = 0;

         if (strncmp (data_ptr[i+index.dt], "char", 4) == 0)
             {
             strncpy (str, data_ptr[i+index.dt] + 5,
                      (strlen (data_ptr[i+index.dt]) - 6));
             temp_len = atoi (str);
             }

    else if ((strncmp (data_ptr[i+index.dt], "int", 3) == 0) ||
             (strncmp (data_ptr[i+index.dt], "smallint", 8) == 0))
             temp_len = 12;

    else if (strncmp (data_ptr[i+index.dt], "timestamp", 9) == 0)
             temp_len = 20 ;

    else if ((strncmp (data_ptr[i+index.dt], "double", 6)  == 0) ||
             (strncmp (data_ptr[i+index.dt], "real", 4)    == 0) ||
             (strncmp (data_ptr[i+index.dt], "decimal", 7) == 0))
             temp_len = 25;

    if (temp_len > *max_dtype_len)
        *max_dtype_len = temp_len;

    }

if (*max_dtype_len > 40)
    *max_dtype_len = 40;

return (NFI_S_SUCCESS);
}

long NFAfind_max_len (column_ptr, format_ptr, data_ptr, cols,
		      max_col_len, max_dtype_len)
    char  **column_ptr;
    char  **format_ptr;
    char  **data_ptr;
    int   cols;
    int   *max_col_len;
    int   *max_dtype_len;
    
{
    int  i;
    int  temp_len;
    char str[5];
  
    for (i=0; i<cols; ++i)
    {
         if (strlen (column_ptr[i]) > *max_col_len)
             *max_col_len = strlen (column_ptr[i]);

         temp_len = 0;

         if (strncmp (format_ptr[i], "char", 4) == 0)
         {
             strncpy (str, format_ptr[i] + 5,(strlen (format_ptr[i]) - 6));
             temp_len = atoi (str);
         }

         else if ((strncmp (format_ptr[i], "int", 3) == 0) ||
                  (strncmp (format_ptr[i], "smallint", 8) == 0))
             temp_len = 12;

	 else if (strncmp (format_ptr[i], "timestamp", 9) == 0)
	     temp_len = 20 ;

         else if ((strncmp (format_ptr[i], "double", 6) == 0) ||
                 (strncmp (format_ptr[i], "real", 4)    == 0) ||
                 (strncmp (format_ptr[i], "decimal", 7) == 0))
             temp_len = 25;

        if (temp_len > *max_dtype_len)
            *max_dtype_len = temp_len;

    }

    if (*max_dtype_len > 40)
        *max_dtype_len = 40;

return (NFI_S_SUCCESS);
}

/*  This routine finds the maximum data length in a column and uses this
 *  to determine the column size. 
 */
long NFAfind_max_data_len (column_ptr,data_ptr,start,cols,rows,max_data_len )
    char  **column_ptr;
    char  **data_ptr;
    int   start;
    int   cols;
    int   *max_data_len;
    
{
    int  i;
    int  max_col_len;
    int  temp_len;
static char *fname = "NFAfind_max_data";

    max_col_len = strlen (column_ptr[start]);

    _NFIdebug ((fname, "start <%d>\n", start));
    _NFIdebug ((fname, "col_size <%d>\n", max_col_len));

    for (i=start; i<cols*rows; i+=cols)
    {
        temp_len = strlen( data_ptr[i] );
	if( temp_len > max_col_len )
	    max_col_len = temp_len;
    }
    *max_data_len = max_col_len;

    _NFIdebug ((fname, "max_data_len <%d>\n", max_col_len));    

    return (NFI_S_SUCCESS);
}


long NFAvalidate_data_type (data_type)

    char *data_type;

{
if (data_type == 0)
    {
    return (NFI_E_FAILURE);
    }
    
if (((strncmp (data_type, "char(", 5) == 0) &&
    (data_type[strlen(data_type)-1] == ')')) ||
    (strncmp (data_type, "smallint", 8) == 0) ||
    (strncmp (data_type, "integer", 7) == 0) ||
    (strncmp (data_type, "double", 6) == 0) ||
    (strncmp (data_type, "date", 4) == 0) ||
    (strncmp (data_type, "timestamp", 9) == 0) ||
    (strncmp (data_type, "real", 4) == 0) ||
    (strncmp (data_type, "decimal", 7) == 0))
    {
    return (NFI_S_SUCCESS);
    }
else
    {
    return (NFI_E_FAILURE);
    }
}


long NFAfill_list_struct (list, rep_type, select_set, select_type, rows,
		search_str, sort_str, catalog, item, rev, workflow, acl, title)

    NFMlist *list;
    int     rep_type;
    int     select_set;
    int     select_type;
    long    rows;
    char    *search_str;
    char    *sort_str;
    char    *catalog;
    char    *item;
    char    *rev;
    char    *workflow;
    char    *acl;
    char    *title;
{
static char *fname = "NFAfill_list_struct";

    _NFIdebug ((fname, "rep_type    : <%d>\n", rep_type));
    _NFIdebug ((fname, "select_set  : <%d>\n", select_set));
    _NFIdebug ((fname, "select_type : <%d>\n", select_type));
    _NFIdebug ((fname, "rows        : <%ld>\n", rows));
    _NFIdebug ((fname, "search      : <%s>\n", search_str));
    _NFIdebug ((fname, "sort        : <%s>\n", sort_str));
    _NFIdebug ((fname, "catalog     : <%s>\n", catalog));
    _NFIdebug ((fname, "item        : <%s>\n", item));
    _NFIdebug ((fname, "rev         : <%s>\n", rev));
    _NFIdebug ((fname, "workflow    : <%s>\n", workflow));
    _NFIdebug ((fname, "acl         : <%s>\n", acl));
    _NFIdebug ((fname, "title       : <%s>\n", title));

    list->rep_type    = rep_type;
    list->select_set  = select_set;
    list->select_type = select_type;
    list->rows        = rows;

    list->search = (char *) malloc (2 + (strlen (search_str)));
    strcpy (list->search, search_str);

    list->sort = (char *) malloc (2 + (strlen (sort_str)));
    strcpy (list->sort, sort_str);

    strcpy (list->catalog, catalog);
    strcpy (list->item, item);
    strcpy (list->rev, rev);
    strcpy (list->wf_name, workflow);
    strcpy (list->acl_name, acl);
    strcpy (list->title, title );

    return (NFI_S_SUCCESS);
 }


long NFAfree_list_struct (list)
    NFMlist *list;

{
if (list->search != NULL)
    free (list->search);

if (list->sort != NULL)
    free (list->sort);

return (NFI_S_SUCCESS);
}


long NFAvalidate_nulls (attr_list, index, data, pos, filled)

    MEMptr attr_list;
    NDXptr index;
    struct SCcolumn_data_st data;
    int  pos;
    int  *filled;

{
int  i, j;
int  tot_data;
char **data_ptr;
char msg[128];

tot_data = data.num_of_cols * data.num_of_rows;
data_ptr = (char **) attr_list->data_ptr;

for (j=pos; j<tot_data; j+=data.num_of_cols)
    {
    for (i=0; i<attr_list->rows*attr_list->columns; i+=attr_list->columns)
        {
        if (((strcmp (data_ptr[i+index.syn], data.data[j]) == 0) ||
             (strcmp (data_ptr[i+index.nfm], data.data[j]) == 0)) &&
             (strcmp (data.data[j+2], "") == 0) &&
             (strcmp (data_ptr[i+index.w], "Y") == 0) &&
             (strcmp (data_ptr[i+index.nul], "N") == 0))
            {
            *filled = FALSE;
            if (strcmp (data_ptr[i+index.syn], "") != 0)
                sprintf (msg, "NFM:  Must enter \"%s\".",
                         data_ptr[i+index.syn]);
            else
                sprintf (msg, "NFM:  Must enter \"%s\".",
                         data_ptr[i+index.nfm]);
            SCdisplay_msg (msg);
            break;
            }

        if (!(*filled))
            break;
        }
    }

return (NFI_S_SUCCESS);
}

/*  This function validates nulls for the struct 'NDXnptr' which is 
 *  used for the attribute lists returned from 'NFMRget_file_information'
 */
long NFAvalidate_new_nulls (attr_list, index, data, pos, filled)

    MEMptr  attr_list;
    NDXnptr index;
    struct  SCcolumn_data_st data;
    int     pos;
    int     *filled;
{
int  i, j;
int  tot_data;
char **data_ptr;
char msg[128];

tot_data = data.num_of_cols * data.num_of_rows;
data_ptr = (char **) attr_list->data_ptr;

for (j=pos; j<tot_data; j+=data.num_of_cols)
    {
    for (i=0; i<(attr_list->rows*attr_list->columns); i+=attr_list->columns)
    {
        if ((strcmp (data_ptr[i+index.syn], data.data[j]) == 0) &&
            (strcmp (data.data[j+1], "") == 0) &&
            (strcmp (data_ptr[i+index.null], "N") == 0))
        {
            *filled = FALSE;
            sprintf (msg, "NFM:  Must enter \"%s\".", data_ptr[i+index.syn]);
            SCdisplay_msg (msg);
            break;
        }

        if (!(*filled))
            break;
    }
}

return (NFI_S_SUCCESS);
}


long NFAvalidate_member_type (type)

    char *type;

{
if (type == 0)
    {
    return (NFI_E_FAILURE);
    }

if ((strncmp (type, "P", 1) == 0) ||
    (strncmp (type, "p", 1) == 0) ||
    (strncmp (type, "S", 1) == 0) ||
    (strncmp (type, "s", 1) == 0))
    {
    type[1] = '\0';
    return (NFI_S_SUCCESS);
    }
else
    {
    return (NFI_E_FAILURE);
    }
}


long NFAvalidate_proj_member_type (type)

    char *type;

{
if (type == 0)
    {
    return (NFI_E_FAILURE);
    }

if ((strncmp (type, "O", 1) == 0) ||
    (strncmp (type, "o", 1) == 0) ||
    (strncmp (type, "R", 1) == 0) ||
    (strncmp (type, "r", 1) == 0))
    {
    type[1] = '\0';
    return (NFI_S_SUCCESS);
    }
else
    {
    return (NFI_E_FAILURE);
    }
}


long NFAget_server_name (server_list, server_name)

  MEMptr server_list;
  char   *server_name;
  
{
long   status = NFI_S_SUCCESS;
int    i, j;
int    tot_data;
int    FORM_FILLED = FALSE;
char   **data_ptr;
struct SCfree_data_st data;
static char *fname = "NFAget_server_name";

    data_ptr = (char **) server_list->data_ptr;

    /* if there is only one valid I/NFM server, return it;
       else, make them choose */

    if (server_list->rows == 1)
        {
        strcpy (server_name, data_ptr[0]);
        _NFIdebug(( fname, "server : <%s>\n", server_name));
        return (NFI_S_SUCCESS);
        }

    data.num_of_rows = server_list->rows;
    data.num_of_cols = 1;
    tot_data = data.num_of_cols * data.num_of_rows;
    data.freeze_rows_count = 0;
    data.freeze_cols_count = 0;
    data.max_indent = 0;
    data.select_set_expected = SELECT_SET_SINGLE_ROW;
    data.col_size = (int *) malloc (data.num_of_cols * sizeof (int));
    memset (data.col_size, 0, (data.num_of_cols * sizeof (int)));
    
    data.col_size[0] = 25;

    data.col_pos = (int *) malloc (data.num_of_cols * sizeof (int));
    memset (data.col_pos, 0 , (data.num_of_cols * sizeof (int)));
    
    data.col_pos[0] = 0;

    data.col_just = (int *) malloc (data.num_of_cols * sizeof (int));
    memset (data.col_just, LEFT_JUSTIFIED, (data.num_of_cols * sizeof (int)));
    
    data.h1_pos = (int *) malloc (sizeof (int) + 1);
    memset (data.h1_pos, 0, sizeof (int) + 1);
    data.h1_pos[0] = 0;
    data.h1_pos[1] = -1;

    data.h2_pos = (int *) malloc ((data.num_of_cols * sizeof (int)) + 1);
    memset (data.h2_pos, 0, (data.num_of_cols * sizeof (int)) + 1);
    data.h2_pos[0] = 0;
    data.h2_pos[1] = -1;
    
    data.h3_pos = (int *) malloc (sizeof (int) + 1);
    memset (data.h3_pos, 0, sizeof (int) + 1);
    data.h3_pos[0] = 0;
    data.h3_pos[1] = -1;
    
    data.h1_data = (char **) malloc (sizeof (char *));
    memset (data.h1_data, NULL, (sizeof (char *)));
    NFAput_string (&data.h1_data[0], "");
    
    data.h2_data = (char **) malloc (tot_data * (sizeof (char *)));
    memset (data.h2_data, NULL, tot_data * (sizeof (char *)));
    NFAput_string (&data.h2_data[0], "Valid I/NFM Servers :");
    
    data.h3_data = (char **) malloc (sizeof (char *));
    memset (data.h3_data, NULL, (sizeof (char *)));
    NFAput_string (&data.h3_data[0], "");
    
    sprintf (data.title, "Choose I/NFM Connection Server");

    data.select_set = (int *) malloc (tot_data * sizeof (int));
    memset (data.select_set, 0, (tot_data * sizeof (int)));

    /* allocate and initialize space to store data */

    data.data = (char **) malloc (tot_data * sizeof (char *));
    memset (data.data, NULL, (tot_data * sizeof (char *)));

    for (i=0, j=0; i<tot_data;
         i+=data.num_of_cols, j+=server_list->columns)
        {
        NFAput_string (&data.data[i], data_ptr[j]);
        }
        
    do
        {
        FORM_FILLED = FALSE;
        status = SCprocess_free_form (&data, NFMprint_file);
        SCclear_msg ();

        if (data.sts == FORM_ACCEPTED)
            {
            for (i=0; i<data.num_of_rows; ++i)
                {
                if (data.select_set[i] == 1)
                    {
                    FORM_FILLED = TRUE;
                    strcpy (server_name, data.data[i]);
                    break;
                    }
                }
            }

        if (FORM_FILLED == FALSE)
            SCdisplay_msg ("NFM:  Must Choose I/NFM Server.");
        }
    while ((FORM_FILLED == FALSE) && (data.sts != FORM_CANCELED));

    if (data.sts == FORM_CANCELED)
        {
        NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
        free (data.data);
	ERRload_struct( NFI, NFI_W_COMMAND_CANCELLED, NULL, NULL );
        return (NFI_W_COMMAND_CANCELLED);
        }

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    _NFIdebug(( fname, "server : <%s>\n", server_name));

return (NFI_S_SUCCESS);
}


long NFAget_env_name (env_list, env_name)

  MEMptr env_list;
  char   *env_name;
  
{
long   status = NFI_S_SUCCESS;
int    i, j;
int    tot_data;
int    FORM_FILLED = FALSE;
char   **data_ptr;
struct SCfree_data_st data;
static char *fname = "NFAget_env_name";

    data_ptr = (char **) env_list->data_ptr;

    /* if there is only one valid I/NFM env, return it;
       else, make them choose */

    if (env_list->rows == 1)
        {
        strcpy (env_name, data_ptr[0]);
        _NFIdebug(( fname, "env : <%s>\n", env_name));
        return (NFI_S_SUCCESS);
        }

    data.num_of_rows = env_list->rows;
    data.num_of_cols = 1;
    tot_data = data.num_of_cols * data.num_of_rows;
    data.freeze_rows_count = 0;
    data.freeze_cols_count = 0;
    data.max_indent = 0;
    data.select_set_expected = SELECT_SET_SINGLE_ROW;
    data.col_size = (int *) malloc (data.num_of_cols * sizeof (int));
    memset (data.col_size, 0, (data.num_of_cols * sizeof (int)));
    
    data.col_size[0] = 30;

    data.col_pos = (int *) malloc (data.num_of_cols * sizeof (int));
    memset (data.col_pos, 0 , (data.num_of_cols * sizeof (int)));
    
    data.col_pos[0] = 0;

    data.col_just = (int *) malloc (data.num_of_cols * sizeof (int));
    memset (data.col_just, LEFT_JUSTIFIED, (data.num_of_cols * sizeof (int)));
    
    data.h1_pos = (int *) malloc (sizeof (int) + 1);
    memset (data.h1_pos, 0, sizeof (int) + 1);
    data.h1_pos[0] = 0;
    data.h1_pos[1] = -1;

    data.h2_pos = (int *) malloc ((data.num_of_cols * sizeof (int)) + 1);
    memset (data.h2_pos, 0, (data.num_of_cols * sizeof (int)) + 1);
    data.h2_pos[0] = 0;
    data.h2_pos[1] = -1;
    
    data.h3_pos = (int *) malloc (sizeof (int) + 1);
    memset (data.h3_pos, 0, sizeof (int) + 1);
    data.h3_pos[0] = 0;
    data.h3_pos[1] = -1;
    
    data.h1_data = (char **) malloc (sizeof (char *));
    memset (data.h1_data, NULL, (sizeof (char *)));
    NFAput_string (&data.h1_data[0], "");
    
    data.h2_data = (char **) malloc (tot_data * (sizeof (char *)));
    memset (data.h2_data, NULL, tot_data * (sizeof (char *)));
    NFAput_string (&data.h2_data[0], "Valid I/NFM Environments :");
    
    data.h3_data = (char **) malloc (sizeof (char *));
    memset (data.h3_data, NULL, (sizeof (char *)));
    NFAput_string (&data.h3_data[0], "");
    
    sprintf (data.title, "Choose I/NFM Environment");

    data.select_set = (int *) malloc (tot_data * sizeof (int));
    memset (data.select_set, 0, (tot_data * sizeof (int)));

    /* allocate and initialize space to store data */

    data.data = (char **) malloc (tot_data * sizeof (char *));
    memset (data.data, NULL, (tot_data * sizeof (char *)));

    for (i=0, j=0; i<tot_data;
         i+=data.num_of_cols, j+=env_list->columns)
        {
        NFAput_string (&data.data[i], data_ptr[j]);
        }
        
    do
        {
        FORM_FILLED = FALSE;
        status = SCprocess_free_form (&data, NFMprint_file);
        SCclear_msg ();

        if (data.sts == FORM_ACCEPTED)
            {
            for (i=0; i<data.num_of_rows; ++i)
                {
                if (data.select_set[i] == 1)
                    {
                    FORM_FILLED = TRUE;
                    strcpy (env_name, data.data[i]);
                    break;
                    }
                }
            }

        if (FORM_FILLED == FALSE)
            SCdisplay_msg ("NFM:  Must Choose I/NFM Environment.");
        }
    while ((FORM_FILLED == FALSE) && (data.sts != FORM_CANCELED));

    if (data.sts == FORM_CANCELED)
        {
        NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
        free (data.data);
	ERRload_struct( NFI, NFI_W_COMMAND_CANCELLED, NULL, NULL );
        return (NFI_W_COMMAND_CANCELLED);
        }

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    _NFIdebug(( fname, "env : <%s>\n", env_name));

return (NFI_S_SUCCESS);
}


long NFAvalidate_env_name (env_list, env_name)

  MEMptr env_list;
  char   *env_name;
  
{
long   status = NFI_S_SUCCESS;
int    i;
char   **data_ptr;
static char *fname = "NFAvalidate_env_name";

    _NFIdebug(( fname, "env_name <%s>\n", env_name));

    data_ptr = (char **) env_list->data_ptr;

    for (i=0; i<env_list->rows; ++i)
        {
        if (strcmp (env_name, data_ptr[i]) == 0)
            break;
        }

    if (i < env_list->rows)
        return (NFI_S_SUCCESS);

    status = NFAget_env_name (env_list, env_name);
    if (status != NFI_S_SUCCESS)
        {
        _NFIdebug(( fname, "NFAget_env_name : <0x%.8x>\n", status));
        return (status);
        }

return (NFI_S_SUCCESS);
}


long NFAget_user_variables (user_var_list)

  MEMptr *user_var_list;
  
{
long   status = NFI_S_SUCCESS;
int    i, j, k;
int    tot_data;
int    FORM_FILLED = FALSE;
char   **data_ptr;
MEMptr var_list = NULL;
struct SCcolumn_data_st data;

static char *fname = "NFAget_user_variables";

    status = MEMbuild_array (*user_var_list);
    if (status != MEM_S_SUCCESS)
        {
        ERRload_struct( NFI, NFI_E_MEMORY, "%s%s", "NFAget_user_variables",
			"MEMbuild_array" );
        return (status);
        }

    var_list = *user_var_list;

    data_ptr = (char **) var_list->data_ptr;

    /* if there is only one valid I/NFM env, return it;
       else, make them choose */

    if (var_list->rows == 0)
        {
        _NFIdebug(( fname, "<%s>\n", "no user variables"));
        return (NFI_S_SUCCESS);
        }

    data.num_of_rows = var_list->rows;
    data.num_of_cols = 2;
    tot_data = data.num_of_cols * data.num_of_rows;
    data.freeze_rows_count = 0;
    data.select_set_expected = FALSE;
    data.col_width = (int *) malloc (data.num_of_cols * sizeof (int));
    memset (data.col_width, 0, (data.num_of_cols * sizeof (int)));
    
    data.col_width[0] = 15;
    data.col_width[1] = 60;

    data.new_rows_expected = FALSE;

    sprintf (data.title, "Fill In Report Variables");

    data.selectable = (int *) malloc (tot_data * sizeof (int));
    memset (data.selectable, 0, (tot_data * sizeof (int)));

    for (i=0; i<tot_data; i+=data.num_of_cols)
        data.selectable[i+1] = 1;

    data.hidden = (int *) malloc (tot_data * sizeof (int));
    memset (data.hidden, 0, (tot_data * sizeof (int)));

    /* allocate and initialize space to store data */

    data.data = (char **) malloc (tot_data * sizeof (char *));
    memset (data.data, NULL, (tot_data * sizeof (char *)));

    for (i=0, j=0; i<tot_data;
         i+=data.num_of_cols, j+=var_list->columns)
        {
        NFAput_string (&data.data[i], data_ptr[j]);
        }
        
    /* process column form until an Report Name has been entered */
    do
        {
        FORM_FILLED = TRUE;
        status = SCprocess_column_form (&data, NFMprint_file);
        SCclear_msg ();

        _NFIdebug(( fname, "Return from SCprocess_column_form -> %d\n", 
		data.sts));

        if (data.sts != FORM_CANCELED)
            {
            for (i=0; i<data.num_of_rows; i+=data.num_of_cols)
                {
                status = NFAvalidate_string ("char(100)", data.data[i+1]);
                }
            }
        }
    while ((FORM_FILLED == FALSE) && (data.sts != FORM_CANCELED));

    if (data.sts == FORM_CANCELED)
        {
        NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
        free (data.data);
	ERRload_struct( NFI, NFI_W_COMMAND_CANCELLED, NULL, NULL );
        return (NFI_W_COMMAND_CANCELLED);
        }

    for (i=0, j=1, k=2; i<tot_data; i+=data.num_of_cols, ++j)
        {
        if (data.data[i+1] != NULL)
            {
            status = MEMwrite_data (var_list, data.data[i+1], j, k);
            if (status != MEM_S_SUCCESS)
                {
                NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
                free (data.data);
	        ERRload_struct(NFI, NFI_E_MEMORY, "%s%s", 
		"NFAget_user_variables", "MEMwrite_data" );
                return (status);
                }
            }
        }

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    user_var_list = &var_list;

    if (_NFMdebug_st.NFIdebug_on)
        MEMprint_buffer ("USER VARIABLE_LIST", *user_var_list, 
			 _NFMdebug_st.NFIdebug_file);

return (NFI_S_SUCCESS);
}


long NFMRset_error (status, message)
    long status;
    char *message;

{
    char msg_str[150];

    strcpy (msg_str, "NFMRset_error : ");
    strcat (msg_str, message);
    strcat (msg_str, " -> <\0x%.8x>");

    return (NFI_S_SUCCESS);
}


lowcase (str)
    char *str;
{
/* Translate the string into lowercase.  Don't want any of them critters
 * with their permanently stuck caps lock keys to suffer.
   -Dave Wiley */

    int i;
    char c;

    for (i=0; ; ++i)
    {
    c = *(str + i);

    if (c == (char) 0)
        break;
    else if ((c >= 'A') && (c <= 'Z'))
        *(str + i) = c - 'A' + 'a';
    }
}

long NFAget_date_len (data_ptr1,len)

    char  *data_ptr1;
    int   *len;
    
{
int  temp_len1;
char str[5];

    *len = 0;
    temp_len1 = 0;
    
    if (strncmp (data_ptr1, "char", 4) == 0)
    {
        strncpy (str, data_ptr1 + 5, (strlen (data_ptr1) - 6));
        str[strlen(data_ptr1) - 6] = '\0';
        temp_len1 = atoi (str);
        *len = temp_len1;
    }
    return (NFI_S_SUCCESS);
}

long NFAset_global_config_info( wf_use, command, wf_name, project_name,
				application )
    short  wf_use;
    char   *command;
    char   *wf_name;
    char   *project_name;
    char   *application;
{
    static char *fname = "NFAset_global_config_info";

    _NFIdebug(( fname, "WF Use  <%d>\n", wf_use ));
    _NFIdebug(( fname, "Command <%s>\n", command ));
    _NFIdebug(( fname, "WF Name <%s>\n", wf_name ));
    _NFIdebug(( fname, "Project <%s>\n", project_name ));
    _NFIdebug(( fname, "App     <%s>\n", application ));

    NFAwf_info.workflow = wf_use;
    strcpy( NFAwf_info.command, command );
    strcpy( NFAwf_info.workflow_name, wf_name );
    strcpy( NFAwf_info.project_name, project_name );
    strcpy( NFAwf_info.app_name, application );

    NFAoperation.transfer = NFM_CONDITIONAL_TRANSFER;
    NFAoperation.delete   = NFM_CONDITIONAL_DELETE;
    NFAoperation.purge    = NFM_PURGE;

    return( NFI_S_SUCCESS );
}

long NFAalpha_defaults_logout( logout )
    MEMptr *logout;
{
    long   status;

    char   str[80];
    
    static char *fname = "NFAalpha_defaults";

    status = MEMopen (logout, MEM_SIZE);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (logout);
        _NFIdebug(( fname, "MEMopen : <0x%.8x>\n", status));
	ERRload_struct( NFI, NFI_E_MEMORY, "%s%s", fname, "MEMopen" );
	return( NFI_E_MEMORY );
        }
    
    status = MEMwrite_format (*logout, "def_name", "char(100)");
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (logout);
        _NFIdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
        ERRload_struct( NFI, NFI_E_MEMORY, "%s%s", fname, "MEMwrite_format" );
        return( NFI_E_MEMORY );
        }

    if( strcmp( NFMstorage, "" ) )
        strcpy (str, NFMstorage );
    else
	strcpy (str, NFM_DEFAULT_NULL );
    strcat (str, "\1");

    status = MEMwrite (*logout, str);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (logout);
        _NFIdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
        ERRload_struct( NFI, NFI_E_MEMORY, "%s%s", fname, "MEMwrite" );
        return( NFI_E_MEMORY );
        }
    
    if( strcmp( NFMcatalog, "" ) )
        strcpy (str, NFMcatalog );
    else
	strcpy (str, NFM_DEFAULT_NULL );
    strcat (str, "\1");

    status = MEMwrite (*logout, str);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (logout);
        _NFIdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
        ERRload_struct( NFI, NFI_E_MEMORY, "%s%s", fname, "MEMwrite" );
        return( NFI_E_MEMORY );
        }
    
    if( strcmp( NFMitem, "" ))
        strcpy (str, NFMitem );
    else
	strcpy (str, NFM_DEFAULT_NULL );
    strcat (str, "\1");

    status = MEMwrite (*logout, str);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (logout);
        _NFIdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
        ERRload_struct( NFI, NFI_E_MEMORY, "%s%s", fname, "MEMwrite" );
        return( NFI_E_MEMORY );
        }
    
    if( strcmp( NFMrev, "" ))
        strcpy (str, NFMrev );
    else
	strcpy (str, NFM_DEFAULT_NULL );
    strcat (str, "\1");

    status = MEMwrite (*logout, str);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (logout);
        _NFIdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
        ERRload_struct( NFI, NFI_E_MEMORY, "%s%s", fname, "MEMwrite" );
        return( NFI_E_MEMORY );
        }
    
    if( strcmp( NFMset_cat, "" ))
        strcpy (str, NFMset_cat );
    else
	strcpy (str, NFM_DEFAULT_NULL );
    strcat (str, "\1");

    status = MEMwrite (*logout, str);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (logout);
        _NFIdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
        ERRload_struct( NFI, NFI_E_MEMORY, "%s%s", fname, "MEMwrite" );
        return( NFI_E_MEMORY );
        }
    
    if( strcmp( NFMset, "" ))
        strcpy (str, NFMset );
    else
	strcpy (str, NFM_DEFAULT_NULL );
    strcat (str, "\1");

    status = MEMwrite (*logout, str);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (logout);
        _NFIdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
        ERRload_struct( NFI, NFI_E_MEMORY, "%s%s", fname, "MEMwrite" );
        return( NFI_E_MEMORY );
        }
    
    if( strcmp( NFMset_rev, "" ))
        strcpy (str, NFMset_rev );
    else
	strcpy (str, NFM_DEFAULT_NULL );
    strcat (str, "\1");

    status = MEMwrite (*logout, str);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (logout);
        _NFIdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
        ERRload_struct( NFI, NFI_E_MEMORY, "%s%s", fname, "MEMwrite" );
        return( NFI_E_MEMORY );
        }
    
    if( strcmp( NFMproject, "" ) )
        strcpy (str, NFMproject );
    else
	strcpy (str, NFM_DEFAULT_NULL );
    strcat (str, "\1");

    status = MEMwrite (*logout, str);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (logout);
        _NFIdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
        ERRload_struct( NFI, NFI_E_MEMORY, "%s%s", fname, "MEMwrite" );
        return( NFI_E_MEMORY );
        }
    
    if( strcmp( NFMsearch_name, "" ) )
        strcpy (str, NFMsearch_name );
    else
	strcpy (str, NFM_DEFAULT_NULL );
    strcat (str, "\1");

    status = MEMwrite (*logout, str);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (logout);
        _NFIdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
        ERRload_struct( NFI, NFI_E_MEMORY, "%s%s", fname, "MEMwrite" );
        return( NFI_E_MEMORY );
        }
    
    if( strcmp( NFMsort_name, "" ) )
        strcpy (str, NFMsort_name );
    else
	strcpy (str, NFM_DEFAULT_NULL );
    strcat (str, "\1");

    status = MEMwrite (*logout, str);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (logout);
        _NFIdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
        ERRload_struct( NFI, NFI_E_MEMORY, "%s%s", fname, "MEMwrite" );
        return( NFI_E_MEMORY );
        }
    
    if( strcmp( NFMworkflow, "" ) )
        strcpy (str, NFMworkflow );
    else
	strcpy (str, NFM_DEFAULT_NULL );
    strcat (str, "\1");

    status = MEMwrite (*logout, str);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (logout);
        _NFIdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
        ERRload_struct( NFI, NFI_E_MEMORY, "%s%s", fname, "MEMwrite" );
        return( NFI_E_MEMORY );
        }
        
    
    if( strcmp( NFMacl, "" ) )
        strcpy (str, NFMacl );
    else
	strcpy (str, NFM_DEFAULT_NULL );
    strcat (str, "\1");

    status = MEMwrite (*logout, str);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (logout);
        _NFIdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
        ERRload_struct( NFI, NFI_E_MEMORY, "%s%s", fname, "MEMwrite" );
        return( NFI_E_MEMORY );
        }
        
    
    if( strcmp( NFMnode, "" ) )
        strcpy (str, NFMnode );
    else
	strcpy (str, NFM_DEFAULT_NULL );
    strcat (str, "\1");

    status = MEMwrite (*logout, str);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (logout);
        _NFIdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
        ERRload_struct( NFI, NFI_E_MEMORY, "%s%s", fname, "MEMwrite" );
        return( NFI_E_MEMORY );
        }
        
    
    if( strcmp( NFMworking, "" ) )
        strcpy (str, NFMworking );
    else
	strcpy (str, NFM_DEFAULT_NULL );
    strcat (str, "\1");

    status = MEMwrite (*logout, str);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (logout);
        _NFIdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
        ERRload_struct( NFI, NFI_E_MEMORY, "%s%s", fname, "MEMwrite" );
        return( NFI_E_MEMORY );
        }
/*        
    if( strcmp( NFMuser, "" ) )
        strcpy (str, NFMuser );
    else*/
	strcpy (str, NFM_DEFAULT_NULL );
    strcat (str, "\1");

    status = MEMwrite (*logout, str);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (logout);
        _NFIdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
        ERRload_struct( NFI, NFI_E_MEMORY, "%s%s", fname, "MEMwrite" );
        return( NFI_E_MEMORY );
        }

    return( NFI_S_SUCCESS );
}

long NFAalpha_defaults_login( login_defaults )
    MEMptr   login_defaults;
{
    long    status;

    char    **data;

    static  char *fname = "NFAalpha_defaults_login";

    status = MEMbuild_array( login_defaults );
    if( status != MEM_S_SUCCESS )
    {
        _NFIdebug(( fname, "MEMbuild : <0x%.8x>\n", status));
        ERRload_struct( NFI, NFI_E_MEMORY, "%s%s", fname, "MEMbuild" );
        return( NFI_E_MEMORY );
    }

    data = (char**)login_defaults->data_ptr;

    if( strcmp( data[0], NFM_DEFAULT_NULL ) )
	strcpy( NFMstorage, data[0] );

    if( strcmp( data[1], NFM_DEFAULT_NULL ) )
	strcpy( NFMcatalog, data[1] );

    if( strcmp( data[2], NFM_DEFAULT_NULL ) )
	strcpy( NFMitem, data[2] );

    if( strcmp( data[3], NFM_DEFAULT_NULL ) )
	strcpy( NFMrev, data[3] );

    if( strcmp( data[4], NFM_DEFAULT_NULL ) )
	strcpy( NFMset_cat, data[4] );

    if( strcmp( data[5], NFM_DEFAULT_NULL ) )
	strcpy( NFMset,data[5] );

    if( strcmp( data[6], NFM_DEFAULT_NULL ) )
	strcpy( NFMset_rev, data[6] );

    if( strcmp( data[7], NFM_DEFAULT_NULL ) )
	strcpy( NFMproject, data[7] );

    if( strcmp( data[8], NFM_DEFAULT_NULL ) )
	strcpy( NFMsearch_name, data[8] );

    if( strcmp( data[9], NFM_DEFAULT_NULL ) )
	strcpy( NFMsort_name, data[9] );

    if( strcmp( data[10], NFM_DEFAULT_NULL ) )
	strcpy( NFMworkflow, data[10] );

    if( strcmp( data[11], NFM_DEFAULT_NULL ) )
	strcpy( NFMacl, data[11] );

    if( strcmp( data[12], NFM_DEFAULT_NULL ) )
	strcpy( NFMnode, data[12] );

    if( strcmp( data[13], NFM_DEFAULT_NULL ) )
	strcpy( NFMworking, data[13] );
/*
    if( strcmp( data[14], NFM_DEFAULT_NULL ) )
	strcpy( NFMuser, "" );
*/
    return( NFI_S_SUCCESS );
}

long NFAfind_attributes ( data_list )
    MEMptr  *data_list;
{
int    i;
long   status;
char   **col_ptr;
MEMptr new_data_list;
static char *fname = "NFAfind_attributes";

    status = MEMbuild_array( *data_list );
    if( status != MEM_S_SUCCESS )
    {
	_NFIdebug(( fname, "MEMbuild_array <0x%.8x>\n", status ));
	return( status );
    }
    new_data_list = *data_list;

    col_ptr = (char**)new_data_list->column_ptr;

    for( i=0; i<new_data_list->columns; ++i )
    {
	if( strcmp( col_ptr[i], "n_itemname" ) == 0 )
	    NFMitem_loc = i;
	else if( strcmp( col_ptr[i], "n_itemrev" ) == 0 )
	    NFMrev_loc  = i;
    }

    _NFIdebug(( fname, "Item Loc <%d>\n", NFMitem_loc ));
    _NFIdebug(( fname, "Rev  Loc <%d>\n", NFMrev_loc ));

    return (NFI_S_SUCCESS);
 }

NFAset_message()
{
    int   subsystem;
    long  error_number;
    long  status;
    char  error_message[512];
    char  id[20];

    static char *fname = "NFAget_message";

    ERRget_number( &error_number, &subsystem );
    _NFIdebug(( fname, "Error Number <0x%.8x>\n", error_number ));
    _NFIdebug(( fname, "Subsystem    <0x%.8x>\n", subsystem ));

    status = UMSMsgCode( id, error_number,UMS_SUPPRESS_COMP|UMS_SUPPRESS_EXT,
                         NULL, NULL, NULL  );
    if( status != UMS_S_SUCCESS )
    {
	strcpy( id, "" );
        _NFIdebug(( fname, "%s\n", "Error determining message severity" ));
    }

    _NFIdebug(( fname, "Message Type <%s>\n", id ));

    if( strcmp( id, "W" ) == 0 )
	sprintf( msg, "Warning - " );
    else if( strcmp( id, "I" ) == 0 )
	sprintf( msg, "Informational - " );
    else 
	strcpy( msg, "" );

    ERRget_message( error_message );
    strncat( msg, error_message, (sizeof (msg) -1) );

    return( NFI_S_SUCCESS );
}

long  NFAdisplay_set_messages( title, msg_list )
    char    *title;
    MEMptr  msg_list;
{
    int   i;
    int   j;
    int   tot_data;
    long  status;
    char  **data_ptr;
    struct SCcolumn_data_st data;
    static char *fname = "NFAdisplay_set_messages";

    _NFIdebug(( fname, "%s\n", "Entering ..." ));

    status = MEMbuild_array( msg_list );
    if( status != MEM_S_SUCCESS )
    {
	_NFIdebug(( fname, "MEMbuild <0x%.8x>\n", status ));
/*	Don't load an error */
	return( status );
    }

    data_ptr = (char**)msg_list->data_ptr;

    if( msg_list->rows == 0 )
    {
	_NFIdebug(( fname, "%s\n", "No rows in message buffer" ));
	return( NFI_S_SUCCESS );
    }

    data.num_of_rows = msg_list->rows*2;
    data.num_of_cols = 1;
    tot_data = data.num_of_cols * data.num_of_rows;
    data.freeze_rows_count = 0;
    data.select_set_expected = FALSE;
    data.col_width = (int *) malloc (data.num_of_cols * sizeof (int));
    memset (data.col_width, 0, (data.num_of_cols * sizeof (int)));
    
    data.col_width[0] = 80;

    data.new_rows_expected = FALSE;

    strcpy (data.title, title );

    data.selectable = (int *) malloc (tot_data * sizeof (int));
    memset (data.selectable, 0, (tot_data * sizeof (int)));

    for (i=0; i<tot_data; i+=data.num_of_cols)
        data.selectable[i] = 0;

    data.hidden = (int *) malloc (tot_data * sizeof (int));
    memset (data.hidden, 0, (tot_data * sizeof (int)));

    /* allocate and initialize space to store data */

    data.data = (char **) malloc (tot_data * sizeof (char *));
    memset (data.data, NULL, (tot_data * sizeof (char *)));

    for (i=0,j=0; i<msg_list->rows; ++i,j+=2 )
        {
        NFAput_string (&data.data[j], data_ptr[i]);
	NFAput_string (&data.data[j+1],"--------------------------------" );
        }

    SCdisplay_msg ("<PF1> or <PF3> to Cancel Form.");
    status = SCprocess_column_form (&data, NFMprint_file);
    SCclear_msg ();

    _NFIdebug(( fname, "Return from SCprocess_column_form -> %d\n", data.sts));

    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);

    return( NFI_S_SUCCESS );
}

long NFAprepare_error_form (data_data, struct_data, count, title)
    struct SCfree_data_st data_data;
    struct SCfree_data_st *struct_data;
    int    count;
    char   *title;
{
int    tot_data;
struct SCfree_data_st *err_data;
static char *fname = "NFMRprepare_error_form";

    _NFIdebug(( fname, "col_size[0] <%d>\n", data_data.col_size[0]));
    _NFIdebug(( fname, "col_size[1] <%d>\n", data_data.col_size[1]));

    err_data = struct_data;

    err_data->num_of_rows = count;
    err_data->num_of_cols = 3;
    tot_data = err_data->num_of_cols * err_data->num_of_rows;

    err_data->freeze_rows_count = 0;
    err_data->freeze_cols_count = 0;

    err_data->max_indent = 0;
    err_data->select_set_expected = FALSE;

    err_data->col_size = (int *) malloc (err_data->num_of_cols * sizeof (int));
    memset (err_data->col_size, 0, (err_data->num_of_cols * sizeof (int)));

    err_data->col_size[0] = data_data.col_size[0];
    err_data->col_size[1] = data_data.col_size[1];
    err_data->col_size[2] = 40;

    err_data->col_pos = (int *) malloc (err_data->num_of_cols * sizeof (int));
    memset (err_data->col_pos, 0 , (err_data->num_of_cols * sizeof (int)));
    err_data->col_pos[0] = 0;
    err_data->col_pos[1] = err_data->col_size[0]+3;
    err_data->col_pos[2] = err_data->col_pos[1]+err_data->col_size[1]+3;

    err_data->col_just = (int *) malloc (err_data->num_of_cols * sizeof (int));
    memset (err_data->col_just, LEFT_JUSTIFIED,
            (err_data->num_of_cols * sizeof (int)));
    
    err_data->h1_pos = (int *) malloc (sizeof (int) + 1);
    memset (err_data->h1_pos, 0, sizeof (int) + 1);
    err_data->h1_pos[0] = 0;
    err_data->h1_pos[1] = -1;

    err_data->h2_pos = (int *) malloc ((err_data->num_of_cols * sizeof (int)) + 1);
    memset (err_data->h2_pos, 0, (err_data->num_of_cols * sizeof (int)) + 1);
    err_data->h2_pos[0] = 0;
    err_data->h2_pos[1] = err_data->col_pos[1];
    err_data->h2_pos[2] = err_data->col_pos[2];
    err_data->h2_pos[3] = -1;
    
    err_data->h3_pos = (int *) malloc (sizeof (int) + 1);
    memset (err_data->h3_pos, 0, sizeof (int) + 1);
    err_data->h3_pos[0] = 0;
    err_data->h3_pos[1] = -1;
    
    err_data->h1_data = (char **) malloc (sizeof (char *));
    memset (err_data->h1_data, NULL, (sizeof (char *)));
    NFAput_string (&err_data->h1_data[0], "");
    
    err_data->h2_data = (char **) malloc (err_data->num_of_cols * (sizeof (char *)));
    memset (err_data->h2_data, NULL, err_data->num_of_cols * (sizeof (char *)));
    NFAput_string (&err_data->h2_data[0], "Item");
    NFAput_string (&err_data->h2_data[1], "Revision");
    NFAput_string (&err_data->h2_data[2], "Command Status");
    
    err_data->h3_data = (char **) malloc (sizeof (char *));
    memset (err_data->h3_data, NULL, (sizeof (char *)));
    NFAput_string (&err_data->h3_data[0], "");
    
    strcpy (err_data->title, title);

    err_data->select_set = (int *) malloc (tot_data * sizeof (int));
    memset (err_data->select_set, 0, (tot_data * sizeof (int)));

    /* allocate and initialize space to store data */

    err_data->data = (char **) malloc (tot_data * sizeof (char *));
    memset (err_data->data, NULL, (tot_data * sizeof (char *)));

    return (NFI_S_SUCCESS);
}

long NFAclear_globals()
{

   NFMuser_id  = 0;
   NFMitem_loc = 0;
   NFMrev_loc  = 1;
   NFMset_ind  = 0;
   NFMlist_driven = 0;

   strcpy( NFMnode, "" );
   strcpy( NFMstorage, "" );
   strcpy( NFMworking, "" );
   strcpy( NFMloc, "" );
   strcpy( NFMproject, "" );
   strcpy( NFMcatalog, "" );
   strcpy( NFMitem, "" );
   strcpy( NFMrev, "" );
   strcpy( NFMset_cat, "" );
   strcpy( NFMset, "" );
   strcpy( NFMset_rev, "" );
   strcpy( NFMsearch_name, "" );
   strcpy( NFMsort_name, "" );
   strcpy( NFMworkflow, "" );
   strcpy( NFMacl, "" );
   strcpy( NFMprint_file, "" );

   return( NFI_S_SUCCESS );
}
