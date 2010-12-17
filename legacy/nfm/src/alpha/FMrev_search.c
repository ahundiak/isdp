#include "machine.h"
#include "NFMdef.h"
#include "SCstruct.h"
#include "SCdef.h"
#include "NFMRextern.h"

long review_search ()

{
long   status;
int    tot_data;
int    where_rows;
int    i;
int    j;
char   where_clause[60];
char   desc[NFM_DESCRIPTION+1];
char   owner[NFM_USERNAME+1];
struct NFMquery_info *query_struct;
static char *fname = "NFAreview_search";
struct SCfree_data_st fdata;

    SCdisplay_msg ("Working..");    

    query_struct =(struct NFMquery_info *)malloc(sizeof( struct NFMquery_info ));
    
    status = NFMRretrieve_query_info( NFMsearch_name, "W", "NFM", "NFM",
				      desc, owner, query_struct );
    if (status != NFM_S_SUCCESS)
        return (status);

    _NFIdebug(( fname, "Owner <%s>\n", owner));
    _NFIdebug(( fname, "Description <%s>\n", desc));
    _NFIdebug(( fname, "select_clause <%s>\n", query_struct->select_clause));
    _NFIdebug(( fname, "from_clause <%s>\n", query_struct->from_clause));
    _NFIdebug(( fname, "where_clause <%s>\n", query_struct->where_clause));
    _NFIdebug(( fname, "order_by_clause <%s>\n",query_struct->order_by_clause));
    _NFIdebug(( fname, "prompts <%s>\n", query_struct->prompts));

    if (status != NFM_S_SUCCESS)
        return (status);

    where_rows = ( strlen( query_struct->where_clause )/50 ) + 1 ;
    _NFIdebug(( fname, "Where rows <%d>\n", where_rows ));
    fdata.num_of_rows = 2 + where_rows;
    fdata.num_of_cols = 2;
    tot_data = fdata.num_of_cols * fdata.num_of_rows;
    fdata.freeze_rows_count = 0;
    fdata.freeze_cols_count = 1;
    fdata.max_indent = 0;
    fdata.select_set_expected = FALSE;
    fdata.col_size = (int *) malloc (fdata.num_of_cols * sizeof (int));
    memset (fdata.col_size, 0, (fdata.num_of_cols * sizeof (int)));
    
    fdata.col_size[0] = 15;
    fdata.col_size[1] = 50;

    fdata.col_pos = (int *) malloc (fdata.num_of_cols * sizeof (int));
    memset (fdata.col_pos, 0 , (fdata.num_of_cols * sizeof (int)));
    
    fdata.col_pos[0] = 0;
    fdata.col_pos[1] = 17;

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
    NFAput_string (&fdata.h1_data[0], "");
    
    fdata.h2_data = (char **) malloc (tot_data * (sizeof (char *)));
    memset (fdata.h2_data, NULL, tot_data * (sizeof (char *)));
    NFAput_string (&fdata.h2_data[0], "");
    
    fdata.h3_data = (char **) malloc (sizeof (char *));
    memset (fdata.h3_data, NULL, (sizeof (char *)));
    NFAput_string (&fdata.h3_data[0], "");
    
    sprintf (fdata.title, "Search Information for <%s>", NFMsearch_name);

    fdata.select_set = (int *) malloc (tot_data * sizeof (int));
    memset (fdata.select_set, 0, (tot_data * sizeof (int)));

    /* allocate and initialize space to store data */

    fdata.data = (char **) malloc (tot_data * sizeof (char *));
    memset (fdata.data, NULL, (tot_data * sizeof (char *)));

    NFAput_string (&fdata.data[0], "Owner");
    NFAput_string (&fdata.data[1], owner );
    NFAput_string (&fdata.data[2], "Description");
    NFAput_string (&fdata.data[3], desc );
    NFAput_string (&fdata.data[4], "Search");
    for( i=0,j=0; i<where_rows; ++i,j+=fdata.num_of_cols )
    {
	strncpy( where_clause, (query_struct->where_clause+(i*50)), 50 );
        NFAput_string (&fdata.data[5+j], where_clause );
    }

    /* process free form */
    status = SCprocess_free_form (&fdata, NFMprint_file);

    NFAfree_list (fdata.data, fdata.num_of_rows, fdata.num_of_cols);
    free (fdata.data);

    NFAmake_msg (msg);
    _NFIdebug(( fname, "%s\n", msg));
    SCdisplay_ref (msg);

    return (NFI_S_SUCCESS);
}


