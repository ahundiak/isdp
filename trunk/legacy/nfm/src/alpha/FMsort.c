#include "machine.h"
#include <stdio.h>
#include "NFMerrordef.h"
#include "NFMdef.h"
#include "MEMstruct.h"
#include "SCstruct.h"
#include "SCdef.h"
#include "NFMRextern.h"
#include "NDXstruct.h"
#include "ERR.h"
#include "DEBUG.h"


/* NFMporttypes.h  contains all the OS specific type definitions */
/* M. S. Sai Prasad.  9 Dec 93.                                  */

#include "NFMporttypes.h"

NFAdefine_sort (sort_string, attr_buffer)
    char **sort_string;
    MEMptr attr_buffer;

{
int    status, i, j;
int    string_size;
int    FIRST_ONE = TRUE;
struct SCfree_data_st data;
char   **column_ptr;
char   **format_ptr;
char   **data_ptr;
NDXptr index;
static char *fname = "NFAdefine_sort";

/*******************************************************************/


    /* set up attribute form -> data */
    
    status = NFAsort_attr_form (&data, attr_buffer);
    if (status != NFI_S_SUCCESS)
        {
        return (status);
        }

    status = MEMbuild_array (attr_buffer);
    if (status != MEM_S_SUCCESS)
        {
        ERRload_struct( NFI, NFI_E_MEMORY, "%s%s","NFAdefine_sort",
			"MEMbuild_array");
        return (status);
        }
 
    column_ptr = (char **) attr_buffer->column_ptr;
    format_ptr = (char **) attr_buffer->format_ptr;
    data_ptr = (char **) attr_buffer->data_ptr;
        
    NFMRfill_index (attr_buffer, &index);

    status = SCprocess_free_form (&data, NFMprint_file);

    if (data.sts == FORM_CANCELED)
        {
        NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
        free (data.data);
	ERRload_struct( NFI, NFI_W_COMMAND_CANCELLED, NULL, NULL );
        return (NFI_W_COMMAND_CANCELLED);
        }
 
    string_size = 2;
    *sort_string = (char *) malloc (string_size);
    strcpy (*sort_string, "");

    FIRST_ONE = TRUE;

    for (i=0, j=0; j<attr_buffer->rows*attr_buffer->columns;
         j+=attr_buffer->columns)
        {
        if (strcmp (data_ptr[j+index.r], "Y") == 0)
            {
            if ((data.select_set[i] == 1) || (data.sts == FORM_SELECTED))
                {
                _NFIdebug(( fname, "Selected attribute : <%s>\n", 
			    data.data[i*data.num_of_cols]));
                string_size += strlen (NFMcatalog) +
                               strlen (data_ptr[j+index.name]) + 3;

    /*  Porting for solaris. Fixed parameter type for realloc().  */
    /*  M.S. Sai Prasad.  9 Dec 93.                               */

                *sort_string = (char *) realloc (*sort_string, 
                               (NFM_SIZE_T) string_size);

                _NFIdebug(( fname, "Entered attribute : <%s>\n", 
			    data_ptr[j+index.name]));
                
                if (!FIRST_ONE)
                    strcat (*sort_string, ",");

                strcat (*sort_string, "a.");
                strcat (*sort_string, data_ptr[j+index.name]);
                FIRST_ONE = FALSE;
                }
            ++i;
            }
        }
        
    NFAfree_list (data.data, data.num_of_rows, data.num_of_cols);
    free (data.data);
    
    return (NFI_S_SUCCESS); 
}



